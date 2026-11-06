#!/usr/bin/python3.12
"""Host side of the nsclf RFNoC block on the X310 (UHD 4.9 Python API).

*** UNTESTED: no X310 was reachable when this was written (2026-10-30). Nothing here has run against hardware. ***

Environment (darthplagueis): source .scratch/uhd-install/env.sh, run with /usr/bin/python3.12. The X310 must run
the nsclf image (.scratch/s5_build/<build>/..., loaded by sw/x310/program_x310_jtag.sh, never uhd_image_loader).

  info     find the block (NOC ID 0x4E53C1F0), print its constant and status registers
  peek     peek32 <addr>;  poke <addr> <value>
  capture  timed capture of radio0 channel CHAN (sc16, 200 MS/s, N samples at T = now + DELAY) through the image's
           raw path (radio0.out_0 -> ep0, no DDC: rfnoc/icores/x310_XG_nsclf.yml), with the MISR window armed on
           exactly the decisions whose 64-sample windows lie inside the capture, and the event records received
           from nsclf0.evt -> ep6 at the same time; everything saved to <out>.npz + <out>.json for nsclf_replay.py.

Timing (evidence/stage5/block/README.md section 3): the radio stamps the sample that was on the radio io_port at
tap time t with host time t + RADIO_RX_OFFSET (6: the radio's RX complex-gain pipeline, EN_COMP_GAIN_RX = 1;
shown by tb/tb_radio_ts.sv on UHD's radio_core in xsim). A decision's tau is the tap time of its window's newest
sample. So capture sample k (host time T + k) has tap time T - 6 + k, and the decisions fully inside the capture
are those with tau in [T - 6 + 63, T - 6 + N - 1].

Event revision (block VERSION 2.0, 2026-11; evidence/stage5/block/README.md section 5a): events are OFF at reset
(REG_CTRL bit 2 EVT_EN); every tool that wants events writes EVT_EN = 1 after setting K (set_events) and EVT_EN = 0
when done; a CHDR event packet carries up to EVT_BATCH records of 3 words (timestamp = the first record's tau),
closed after REG_EVT_FLUSH cycles at the latest. The receiver parses records in 6-item groups, so packet boundaries
do not matter to it. VERSION 1.0 images (events always on, one record per packet) still work: the EVT_EN write is
ignored there and the new registers are not read.
"""
from __future__ import annotations

import argparse
import json
import sys
import threading
import time
from pathlib import Path

import numpy as np

try:
    import uhd
except ImportError as e:  # pragma: no cover
    sys.exit(f'import uhd failed ({e}): source .scratch/uhd-install/env.sh and use /usr/bin/python3.12')

NOC_ID = 0x4E53C1F0
ID_VALUE = 0x6E73636C
W = 64
RADIO_RX_OFFSET = 6
REG = dict(ID=0x00, VERSION=0x04, BUILD=0x08, LATENCY=0x0C, CHAN=0x10, K=0x14, CTRL=0x18, CUR=0x1C,
           T_START_LO=0x20, T_START_HI=0x24, N=0x28, ARM=0x2C, STATUS=0x30, WIN_COUNT=0x34, MISR_LO=0x38,
           MISR_HI=0x3C, CNT0=0x40, CNT1=0x44, CNT2=0x48, CNT3=0x4C, TFIRST_LO=0x50, TFIRST_HI=0x54,
           TLAST_LO=0x58, TLAST_HI=0x5C, EVT_DROP=0x60, EVT_SEQ=0x64, DEC_LO=0x68, DEC_HI=0x6C,
           TIME_LO=0x70, TIME_HI=0x74, EVT_FLUSH=0x78, EVT_CFG=0x7C, EVT_PKTS=0x80)
VERSION_EVT = 0x00020000      # first VERSION with EVT_EN / batched event packets
CTRL_EVT_EN = 1 << 2


class Nsclf:
    def __init__(self, blk):
        self.b = blk

    def rd(self, name):
        return int(self.b.peek32(REG[name]))

    def wr(self, name, v):
        self.b.poke32(REG[name], int(v) & 0xFFFFFFFF)

    def rd64(self, lo):              # the LO read latches HI for DEC and TIME; the others are stable when read
        a = self.rd(lo)
        return a | (self.rd(lo.replace('_LO', '_HI')) << 32)

    def status(self):
        s = self.rd('STATUS')
        return {'armed': s & 1, 'active': (s >> 1) & 1, 'done': (s >> 2) & 1, 'late': (s >> 3) & 1, 'raw': s}

    def window(self):
        return {'misr': self.rd64('MISR_LO'), 'count': self.rd('WIN_COUNT'),
                'hist': [self.rd(f'CNT{c}') for c in range(4)], 'tfirst': self.rd64('TFIRST_LO'),
                'tlast': self.rd64('TLAST_LO'), 'status': self.status()}

    def version(self):
        return self.rd('VERSION')

    def evt_rev(self):
        """True for an image with EVT_EN and batched event packets (VERSION >= 2.0)."""
        return self.version() >= VERSION_EVT

    def set_events(self, on: bool, flush=None):
        """EVT_EN on/off (REG_CTRL bit 2; bits 0/1 written 0, so no hysteresis reset or counter clear), and optionally
        REG_EVT_FLUSH (cycles). On a VERSION 1.0 image the CTRL write has no effect (events are always on there)."""
        if flush is not None and self.evt_rev():
            self.wr('EVT_FLUSH', flush)
        self.wr('CTRL', CTRL_EVT_EN if on else 0)

    def evt_regs(self) -> dict:
        r = {'VERSION': self.version(), 'EVT_SEQ': self.rd('EVT_SEQ'), 'EVT_DROP': self.rd('EVT_DROP')}
        if r['VERSION'] >= VERSION_EVT:
            c = self.rd('EVT_CFG')
            r.update(EVT_EN=(self.rd('CTRL') >> 2) & 1, EVT_FLUSH=self.rd('EVT_FLUSH'), EVT_PKTS=self.rd('EVT_PKTS'),
                     EVT_CFG=c, EVT_BATCH=c & 0xFF)
        return r

    def arm(self, t_start, n):
        self.wr('T_START_LO', t_start & 0xFFFFFFFF)
        self.wr('T_START_HI', t_start >> 32)
        self.wr('N', n)
        self.wr('ARM', 1)


def open_graph(args: str):
    return uhd.rfnoc.RfnocGraph(args)


def find_nsclf(graph) -> Nsclf:
    for bid in graph.find_blocks(''):
        blk = graph.get_block(bid)
        if blk.get_noc_id() == NOC_ID:
            n = Nsclf(blk)
            if n.rd('ID') != ID_VALUE:
                raise RuntimeError(f'{bid}: NOC ID matches but REG_ID = {n.rd("ID"):#x}')
            return n
    raise RuntimeError(f'no block with NOC ID {NOC_ID:#x}: is the nsclf image loaded?')


def cmd_info(a):
    g = open_graph(a.args)
    n = find_nsclf(g)
    b = n.rd('BUILD')
    print(f"block {n.b.get_unique_id()}  ID {n.rd('ID'):#010x}  VERSION {n.rd('VERSION'):#010x}")
    print(f"BUILD: cutoff {((b >> 24) & 0xFF) / 10:g}  W {(b >> 16) & 0xFF}  CORE_LAT {(b >> 8) & 0xFF}  "
          f"IN_REG {(b >> 4) & 0xF}  BFP_PIPE {b & 0xF}")
    print(f"LATENCY {n.rd('LATENCY')} cycles (radio_rx_data port -> decision valid)")
    print(f"CHAN {n.rd('CHAN')}  K {n.rd('K')}  CUR {n.rd('CUR'):#010x}  STATUS {n.status()}")
    print(f"decisions {n.rd64('DEC_LO')}  events {n.rd('EVT_SEQ')}  dropped {n.rd('EVT_DROP')}  "
          f"time {n.rd64('TIME_LO')} (block tick rate {n.b.get_tick_rate()})")
    if n.evt_rev():
        c = n.rd('EVT_CFG')
        print(f"event revision: EVT_EN {(n.rd('CTRL') >> 2) & 1}  EVT_FLUSH {n.rd('EVT_FLUSH')} cycles  "
              f"EVT_CFG {c:#010x} (batch {c & 0xFF} records/packet, FIFO 2^{(c >> 8) & 0xFF}, "
              f"{(c >> 16) & 0xF} words/record v{(c >> 20) & 0xF}, wait counter {(c >> 24) & 0xFF} bits)  "
              f"packets {n.rd('EVT_PKTS')}")
    else:
        print('VERSION 1.0 image: events always on, one record per packet (no EVT_EN / EVT_FLUSH registers)')


def cmd_peek(a):
    n = find_nsclf(open_graph(a.args))
    print(f'{int(a.addr, 0):#06x}: {n.b.peek32(int(a.addr, 0)):#010x}')


def cmd_poke(a):
    n = find_nsclf(open_graph(a.args))
    n.b.poke32(int(a.addr, 0), int(a.value, 0))


def decode_events(items: np.ndarray) -> list[dict]:
    """sc16 items from the event stream -> 3-word records. Each 64-bit CHDR payload word carries two 32-bit
    items, the first in bits [31:0]; an sc16 item is {I[31:16], Q[15:0]} (convert_common.hpp). The word order
    is checked by the caller (word 0 must equal the packet timestamp); --swap-words flips it if not."""
    u = ((items['re'].astype(np.uint32) & 0xFFFF) << 16) | (items['im'].astype(np.uint32) & 0xFFFF)
    w = u[0::2].astype(np.uint64) | (u[1::2].astype(np.uint64) << np.uint64(32))
    out = []
    for i in range(0, len(w) - 2, 3):
        w0, w1, w2 = (int(x) for x in w[i:i + 3])
        out.append({'tau': w0, 'run': w1 >> 32, 'k': (w1 >> 16) & 0xFFFF, 'ver': (w1 >> 8) & 0xF,
                    'old': (w1 >> 4) & 0xF, 'new': w1 & 0xF, 'seq': w2 >> 32, 'drops': w2 & 0xFFFFFFFF})
    return out


def ts_matches(tau: int, full_secs: int, frac_secs: float, tick_rate: float = 200e6):
    """Does the recv metadata time of a buffer's first event packet equal its record's word 0 (tau)?

    The block runs under UHD's default block controller (no controller for NOC ID 0x4E53C1F0), whose timebase is a
    graph clock that nothing sets: `info` reads `get_tick_rate()` = 0.0 on silicon (nsclf_info_1.log, 2026-11-03),
    so the event streamer most likely never gets a usable tick rate and converts the CHDR timestamp with its default of 1.0
    (rx_streamer_zero_copy.hpp: `_tick_rate = 1.0`; `time_spec_t::from_ticks(tsf, 1.0)` = tsf whole seconds).
    The capture tool compared with `to_ticks(200e6)`, which counted every recv call as a mismatch (9 and 10 calls of
    up to 64 records for 550 and 581 events on 2026-11-03). Returns 'tick' (converted at tick_rate), 'raw1'
    (time spec = tsf seconds, the default-rate case) or None (a real mismatch)."""
    if full_secs == tau and frac_secs == 0.0:
        return 'raw1'
    rate_i = int(tick_rate)
    ticks = full_secs * rate_i + int(round(full_secs * (tick_rate - rate_i) + frac_secs * tick_rate))
    return 'tick' if ticks == tau else None


def drain_events(n, ev, timeout: float = 20.0) -> dict:
    """After set_events(False): wait until the receiver holds every record the block generated (EVT_SEQ - EVT_DROP,
    read once the last open packet has left), then stop it. A Python receiver lags the block at dense pulse rates
    (2026-11-03: 12,544 of 22,009 records had been read when the capture ended), so it must not be stopped early."""
    time.sleep(0.01)                             # > EVT_FLUSH (4096 cycles = 20 us): the last packet is out
    want = n.rd('EVT_SEQ') - n.rd('EVT_DROP')
    t0 = time.time()
    while len(ev.events) < want and time.time() - t0 < timeout:
        time.sleep(0.05)
    time.sleep(0.1)
    ev.stop.set()
    ev.join(1.0)
    return {'records_expected': int(want), 'records_received': len(ev.events), 'drain_s': round(time.time() - t0, 3),
            'complete': len(ev.events) >= want}


class EventReceiver(threading.Thread):
    """Event records from nsclf0.evt -> ep6. One record = 3 words = 6 sc16 items; a packet holds 1..EVT_BATCH
    records (VERSION 2.0) and the buffer is a whole number of records, so a recv call never splits a record. UHD
    fills the buffer from several packets and returns the first packet's time; a call that starts with the rest of a
    packet the previous call could not hold (more_fragments) has no packet timestamp of its own (match 'fragment')."""

    def __init__(self, graph, nsclf, swap):
        super().__init__(daemon=True)
        self.rx = graph.create_rx_streamer(1, uhd.usrp.StreamArgs('sc16', 'sc16'))
        graph.connect(nsclf.b.get_unique_id(), 0, self.rx, 0)
        self.stop = threading.Event()
        self.events, self.ts_bad, self.swap = [], 0, swap
        self.calls = []                        # per recv call: items, has_time, full secs, frac secs, match kind
        self.errors = []

    def run(self):
        buf = np.zeros(6 * 256, dtype=np.dtype([('re', np.int16), ('im', np.int16)]))
        md = uhd.types.RXMetadata()
        frag = False                           # the previous call ended inside a packet
        while not self.stop.is_set():
            n = self.rx.recv(buf, md, 0.1)
            if md.error_code not in (uhd.types.RXMetadataErrorCode.none, uhd.types.RXMetadataErrorCode.timeout):
                self.errors.append(str(md.error_code))
            if n == 0:
                continue
            if n % 6:
                self.errors.append(f'recv returned {n} items, not a whole number of 6-item records')
            recs = []
            for k in range(0, n - 5, 6):       # one record = 3 words = 6 items
                rec = decode_events(buf[k:k + 6])[0]
                if self.swap:
                    rec = decode_events(buf[k:k + 6][[1, 0, 3, 2, 5, 4]])[0]
                recs.append(rec)
            # the metadata time belongs to the first packet of the buffer
            kind = None
            if frag:
                kind, full, frac = 'fragment', None, None
            elif md.has_time_spec and recs:
                full, frac = int(md.time_spec.get_full_secs()), float(md.time_spec.get_frac_secs())
                kind = ts_matches(recs[0]['tau'], full, frac)
                if kind is None:
                    self.ts_bad += 1
            else:
                full, frac = None, None
            frag = bool(md.more_fragments)
            self.calls.append({'items': int(n), 'has_time': bool(md.has_time_spec), 'full': full, 'frac': frac,
                               'match': kind, 'more_fragments': frag})
            self.events.extend(recs)


def cmd_capture(a):
    g = open_graph(a.args)
    n = find_nsclf(g)
    radio = uhd.rfnoc.RadioControl(g.get_block('0/Radio#0'))
    chan = a.chan
    if chan != 0:
        print('WARNING: channel 1 of radio0 goes through ddc0 in this image; ddc0 is not bit-transparent, so the '
              'capture cannot be replayed bit-exactly. Use channel 0.')
    tick = radio.get_tick_rate()
    if abs(tick - 200e6) > 1:
        print(f'WARNING: tick rate {tick} != 200e6')
    radio.set_rx_frequency(a.freq, chan)
    radio.set_rx_gain(a.gain, chan)
    if a.antenna:
        radio.set_rx_antenna(a.antenna, chan)
    if a.dc_offset is not None:
        radio.set_rx_dc_offset(a.dc_offset == 'auto', chan)
    rx = g.create_rx_streamer(1, uhd.usrp.StreamArgs('sc16', 'sc16'))
    edges = uhd.rfnoc.get_block_chain(g, radio.get_unique_id(), chan, True)
    g.connect(edges[-1].src_blockid, edges[-1].src_port, rx, 0)
    # always connect ep6 (an unconnected SEP6 keeps an earlier session's destination: see nsclf_txrx.py setup)
    ev_rx = EventReceiver(g, n, a.swap_words)
    ev = None if a.no_events else ev_rx
    g.commit()
    n.wr('CHAN', chan)
    n.wr('K', a.k)
    n.set_events(False, a.evt_flush)   # VERSION 2.0: off at reset; switched on below once the receiver runs
    time.sleep(0.01)
    ns = a.n
    t_now = radio.get_ticks_now()
    T = int(t_now + a.delay * tick)
    t_tap0 = T - RADIO_RX_OFFSET
    win_start, win_n = t_tap0 + W - 1, ns - (W - 1)
    n.arm(win_start, win_n)
    if ev:
        ev.start()
        n.set_events(True)             # after K (written above) and with the receiver listening
    cmd = uhd.types.StreamCMD(uhd.types.StreamMode.num_done)
    cmd.num_samps = ns
    cmd.stream_now = False
    cmd.time_spec = uhd.types.TimeSpec.from_ticks(T, tick)
    rx.issue_stream_cmd(cmd)
    dt = np.dtype([('re', np.int16), ('im', np.int16)])
    data = np.zeros(ns, dtype=dt)
    md = uhd.types.RXMetadata()
    got, first_ts, errs = 0, None, []
    t_end = time.monotonic() + a.delay + 5 + ns / tick
    while got < ns and time.monotonic() < t_end:
        # one recv into the rest of the capture (UHD fills many packets per call; per-packet Python is too slow)
        k = rx.recv(data[got:], md, a.delay + 1.0)
        if md.error_code != uhd.types.RXMetadataErrorCode.none:
            errs.append(str(md.error_code))
            if md.error_code != uhd.types.RXMetadataErrorCode.timeout:
                break
        if k:
            ts = md.time_spec.to_ticks(tick)
            if first_ts is None:
                first_ts = ts
            if ts != T + got:
                errs.append(f'discontinuity at sample {got}: packet ticks {ts}, expected {T + got}')
                break
            got += k
    for _ in range(200):
        st = n.status()
        if st['done']:
            break
        time.sleep(0.01)
    win = n.window()
    regs = {'LATENCY': n.rd('LATENCY'), 'BUILD': n.rd('BUILD'), 'K': n.rd('K'), 'CHAN': n.rd('CHAN'),
            'DEC': n.rd64('DEC_LO'), **n.evt_regs()}
    n.set_events(False)                          # stop new records; the last open packet leaves after EVT_FLUSH
    drain = drain_events(n, ev) if ev else None
    out = Path(a.out)
    np.savez_compressed(out.with_suffix('.npz'), i=data['re'][:got], q=data['im'][:got])
    meta = {'untested_tool': True, 'args': a.args, 'chan': chan, 'freq': a.freq, 'gain': a.gain, 'k': a.k,
            'tick_rate': tick, 'T_host_first_sample': T, 'first_packet_ticks': first_ts,
            'radio_rx_offset': RADIO_RX_OFFSET, 'tap_time_first_sample': t_tap0, 'n_requested': ns,
            'n_received': got, 'errors': errs, 'window': {'t_start': win_start, 'n': win_n, **win},
            'registers': regs, 'events': ev.events if ev else None,
            'events_timestamp_mismatch': ev.ts_bad if ev else None, 'events_drain': drain,
            'event_recv_calls': ev.calls if ev else None, 'event_recv_errors': ev.errors if ev else None,
            'date': time.strftime('%Y-%m-%dT%H:%M:%S')}
    out.with_suffix('.json').write_text(json.dumps(meta, indent=1) + '\n')
    print(f"capture: {got}/{ns} samples, first packet ticks {first_ts} (requested {T}), errors {errs[:3]}")
    print(f"window [{win_start}, +{win_n}): status {win['status']} count {win['count']} misr {win['misr']:#018x} "
          f"hist {win['hist']}")
    if ev:
        print(f"events received {len(ev.events)} (timestamp != word 0: {ev.ts_bad}), generated {regs['EVT_SEQ']}, "
              f"dropped {regs['EVT_DROP']}")
    ok = got == ns and first_ts == T and win['status']['done'] and not win['status']['late'] and win['count'] == win_n
    print('CAPTURE OK' if ok else 'CAPTURE INCOMPLETE (see errors / status)')
    return 0 if ok else 1


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--args', default='addr=192.168.40.2,recv_buff_size=100000000', help='UHD device args')
    sub = ap.add_subparsers(dest='cmd', required=True)
    sub.add_parser('info').set_defaults(func=cmd_info)
    p = sub.add_parser('peek')
    p.add_argument('addr')
    p.set_defaults(func=cmd_peek)
    p = sub.add_parser('poke')
    p.add_argument('addr')
    p.add_argument('value')
    p.set_defaults(func=cmd_poke)
    c = sub.add_parser('capture')
    c.add_argument('--n', type=int, default=1 << 20, help='samples (at 200 MS/s; 2^20 = 5.2 ms)')
    c.add_argument('--delay', type=float, default=0.5, help='seconds from now to the capture start')
    c.add_argument('--chan', type=int, default=0)
    c.add_argument('--freq', type=float, required=True)
    c.add_argument('--gain', type=float, default=10.0)
    c.add_argument('--antenna', default=None)
    c.add_argument('--k', type=int, default=16)
    c.add_argument('--dc-offset', choices=('auto', 'off'), default=None,
                   help='rx_frontend DC-offset correction (UHD default: auto). The tap sees what it outputs.')
    c.add_argument('--no-events', action='store_true', help='leave EVT_EN = 0 (VERSION 2.0 images: no events at all)')
    c.add_argument('--evt-flush', type=int, default=None,
                   help='REG_EVT_FLUSH in cycles (VERSION 2.0; default: keep, 4096 at reset; 0 = one record per packet)')
    c.add_argument('--swap-words', action='store_true', help='if word 0 != timestamp on the first silicon run')
    c.add_argument('--out', required=True, help='output stem (.npz samples + .json metadata)')
    c.set_defaults(func=cmd_capture)
    a = ap.parse_args()
    sys.exit(a.func(a) or 0)


if __name__ == '__main__':
    main()
