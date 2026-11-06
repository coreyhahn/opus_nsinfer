#!/usr/bin/python3.12
"""Stage 5 silicon signal set: the X310 transmits it on RF A TX/RX (Replay block DRAM -> DUC#0 -> Radio#0, timed),
the loop cable (>= 30 dB) brings it back to RF A RX2, the nsclf block classifies it live, and the host captures the
same samples through the raw path (radio0.out_0 -> ep0) with the MISR window and the events armed.

  gen      write the TX waveform + schedule for a seed (no device): <out>.tx.npz / <out>.tx.json
  run      one TX->RX capture: upload the seed's waveform, play it at T + PRE, capture n_rx samples from T
  cal      CW at full digital amplitude only (a level check): prints the received power over the noise floor

Signal set (PLAN D-S5-SIG, the classes and parameters of ref/x310/x310_data.py make_stream): gaps of zeros
U(0.2, 2) us between pulses of class 1..3, CW 0.5-5 us at -15..15 MHz, LFM span 5-30 MHz over 0.5-5 us with rate
>= 10 MHz/us inside +/-15 MHz, BPSK (rectangular chips, 5-20 Mchip/s at -10..10 MHz; half Barker-13 x 1-4, half
13-64 random chips). Each pulse has a random phase and a digital amplitude 10^(a/20), a ~ U(-ATT_DB, 0), at
peak AMP of DAC full scale: the received SNR then spans ATT_DB (set the top with the TX gain). The real channel
(DAC, UBX TX/RX, cable, attenuator, ADC, CFO from the shared reference, IQ imbalance, DC) replaces the channel model.
The schedule records every pulse (start, length, class, parameters, amplitude, BPSK chip boundaries and bits) so
the analysis can label windows by the same rules as the training set (D-S5-DATA).
"""
from __future__ import annotations

import argparse
import json
import sys
import time
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
sys.path.insert(0, str(ROOT / 'ref/x310'))
sys.path.insert(0, str(HERE))

FS = 200e6
BARKER13 = np.array([1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1], np.float64)
SEED_BASE = 20261103
PRE = 4000          # TX starts PRE samples after the RX capture start (20 us of noise first)


def make_tx(seed: int, n: int, amp: float, att_db: float, gap_us=(0.2, 2.0)):
    """Clean TX waveform (complex, |x| <= amp), per-sample label, pulse list."""
    import x310_data as xd
    P = xd.P
    rng = np.random.default_rng([SEED_BASE, seed])
    s = np.zeros(n, np.complex128)
    lab = np.zeros(n, np.int8)
    pulses = []
    pos = int(10e-6 * FS)
    end = n - int(10e-6 * FS)
    while True:
        pos += int(rng.uniform(*gap_us) * 1e-6 * FS)
        cls = int(rng.integers(1, 4))
        a_db = float(rng.uniform(-att_db, 0.0))
        rec = {'cls': cls, 'a_db': a_db}
        if cls == 1:
            nn = int(rng.uniform(0.5, 5.0) * 1e-6 * FS)
            f = float(rng.uniform(*P['cw_f_mhz']) * 1e6)
            seg = np.exp(2j * np.pi * f * np.arange(nn) / FS)
            rec.update(f_hz=f)
        elif cls == 2:
            while True:
                B = rng.uniform(*P['lfm_span_mhz']) * 1e6
                T = rng.uniform(*P['lfm_dur_us']) * 1e-6
                if B / T >= P['lfm_rate_min_mhz_per_us'] * 1e12:
                    break
            nn = int(T * FS)
            t = np.arange(nn) / FS
            flo = rng.uniform(-P['lfm_band_mhz'] * 1e6, P['lfm_band_mhz'] * 1e6 - B)
            k = B / T
            up = bool(rng.random() < 0.5)
            ph = flo * t + 0.5 * k * t ** 2 if up else (flo + B) * t - 0.5 * k * t ** 2
            seg = np.exp(2j * np.pi * ph)
            rec.update(f_lo_hz=float(flo), span_hz=float(B), rate_hz_per_s=float(k if up else -k))
        else:
            rc = float(rng.uniform(*P['bpsk_chip_rate_mchip']) * 1e6)
            barker = bool(rng.random() < P['bpsk_barker_frac'])
            bits = np.tile(BARKER13, int(rng.integers(1, 5))) if barker else rng.choice([-1.0, 1.0], int(rng.integers(13, 65)))
            nn = int(len(bits) / rc * FS)
            t = np.arange(nn) / FS
            f = float(rng.uniform(*P['bpsk_f_mhz']) * 1e6)
            seg = bits[np.minimum((t * rc).astype(np.int64), len(bits) - 1)] * np.exp(2j * np.pi * f * t)
            rec.update(chip_rate=rc, f_hz=f, barker=barker, bits=bits.astype(int).tolist())
        if pos + nn > end:
            break
        s[pos:pos + nn] = seg * np.exp(1j * rng.uniform(0, 2 * np.pi)) * 10 ** (a_db / 20)
        lab[pos:pos + nn] = cls
        rec.update(start=pos, len=nn)
        pulses.append(rec)
        pos += nn
    return (amp * s).astype(np.complex64), lab, pulses


def cmd_gen(a):
    x, lab, pulses = make_tx(a.seed, a.n_tx, a.amp, a.att_db, a.gap_us)
    out = Path(a.out)
    np.savez_compressed(out.with_suffix('.tx.npz'), x=x, lab=lab)
    out.with_suffix('.tx.json').write_text(json.dumps({'seed': a.seed, 'n_tx': a.n_tx, 'amp': a.amp,
                                                       'att_db': a.att_db, 'gap_us': a.gap_us, 'pulses': pulses}) + '\n')
    print(f'{len(pulses)} pulses, classes {np.bincount([p["cls"] for p in pulses], minlength=4)[1:]}, '
          f'samples labelled {np.bincount(lab, minlength=4)}')


def setup(a, uhd):
    import nsclf_host as nh
    from uhd.usrp import dram_utils
    g = nh.open_graph(a.args)
    n = nh.find_nsclf(g)
    radio = uhd.rfnoc.RadioControl(g.get_block('0/Radio#0'))
    radio.set_rx_frequency(a.freq, 0)
    radio.set_rx_gain(a.rx_gain, 0)
    radio.set_rx_antenna('RX2', 0)
    radio.set_rx_dc_offset(a.dc_offset == 'auto', 0)
    radio.set_tx_frequency(a.freq, 0)
    radio.set_tx_gain(a.tx_gain, 0)
    radio.set_tx_antenna('TX/RX', 0)
    dram = dram_utils.DramTransmitter(g, ['0/Radio#0:0'], cpu_format='fc32')
    duc = dram.duc_chan_pairs[0]
    if duc:
        duc[0].set_input_rate(FS, duc[1])
        duc[0].set_output_rate(FS, duc[1])
    rx = g.create_rx_streamer(1, uhd.usrp.StreamArgs('sc16', 'sc16'))
    edges = uhd.rfnoc.get_block_chain(g, radio.get_unique_id(), 0, True)
    g.connect(edges[-1].src_blockid, edges[-1].src_port, rx, 0)
    # Always connect the event stream (ep6), even when it is not read: an unconnected SEP6 keeps the stream
    # configuration of an earlier session and sends events to a stale host endpoint, which broke the RX and
    # control traffic of later sessions (2026-11-03). Undrained, flow control stalls it and the block counts drops.
    ev = nh.EventReceiver(g, n, False)
    g.commit()
    n.wr('CHAN', 0)
    n.wr('K', a.k)
    # VERSION 2.0 (event revision): events are off at reset and stay off until capture() has the receiver running;
    # with --no-events they stay off (no event traffic at all, which avoids the D-S5-EVK host swamp at K = 16)
    n.set_events(False, a.evt_flush)
    return g, n, radio, dram, rx, ev


def capture(a, uhd, g, n, radio, dram, rx, ev, x_tx, n_rx):
    import nsclf_host as nh
    tick = radio.get_tick_rate()
    T = int(radio.get_ticks_now() + a.delay * tick)
    t_tap0 = T - nh.RADIO_RX_OFFSET
    win_start, win_n = t_tap0 + nh.W - 1, n_rx - (nh.W - 1)
    n.arm(win_start, win_n)
    if not a.no_events:
        ev.start()
        n.set_events(True)
    if x_tx is not None:
        sc = uhd.types.StreamCMD(uhd.types.StreamMode.num_done)
        # x_tx carries a.lead zeros first (TX running before the signal set): sample a.lead plays at T + PRE
        sc.num_samps = len(x_tx)
        sc.stream_now = False
        sc.time_spec = uhd.types.TimeSpec.from_ticks(T + PRE - a.lead, tick)
        dram.issue_stream_cmd(sc)
    cmd = uhd.types.StreamCMD(uhd.types.StreamMode.num_done)
    cmd.num_samps = n_rx
    cmd.stream_now = False
    cmd.time_spec = uhd.types.TimeSpec.from_ticks(T, tick)
    rx.issue_stream_cmd(cmd)
    dt = np.dtype([('re', np.int16), ('im', np.int16)])
    data = np.zeros(n_rx, dtype=dt)
    md = uhd.types.RXMetadata()
    got, first_ts, errs = 0, None, []
    t_end = time.monotonic() + a.delay + 5 + n_rx / tick
    while got < n_rx and time.monotonic() < t_end:
        # one recv into the rest of the capture: UHD fills many packets per call (a per-packet Python loop is
        # ~10 us per 2k-sample packet, no margin at 200 MS/s); md.time_spec is the first sample of this call
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
        if n.status()['done']:
            break
        time.sleep(0.01)
    win = n.window()
    regs = {'LATENCY': n.rd('LATENCY'), 'BUILD': n.rd('BUILD'), 'K': n.rd('K'), 'CHAN': n.rd('CHAN'),
            'DEC': n.rd64('DEC_LO'), **n.evt_regs()}
    n.set_events(False)          # stop new records; the last open packet leaves after EVT_FLUSH cycles
    drain = nh.drain_events(n, ev) if not a.no_events else None
    tx_async = []
    try:
        amd = uhd.types.TXAsyncMetadata()
        while dram.tx_streamer.recv_async_msg(amd, 0.05):
            tx_async.append(str(amd.event_code))
    except Exception as e:  # noqa: BLE001
        tx_async.append(f'recv_async_msg: {e}')
    return {'T': T, 'tick': tick, 't_tap0': t_tap0, 'first_ts': first_ts, 'got': got, 'errs': errs, 'data': data,
            'win': {'t_start': win_start, 'n': win_n, **win}, 'regs': regs, 'tx_async': tx_async,
            'events': None if a.no_events else ev.events, 'ev_ts_bad': None if a.no_events else ev.ts_bad,
            'ev_calls': None if a.no_events else ev.calls, 'ev_errors': None if a.no_events else ev.errors,
            'drain': drain}


def save(a, r, tx_meta: dict):
    out = Path(a.out)
    d = r.pop('data')
    np.savez_compressed(out.with_suffix('.npz'), i=d['re'][:r['got']], q=d['im'][:r['got']])
    meta = {'tool': 'sw/x310/nsclf_txrx.py', 'args': a.args, 'chan': 0, 'freq': a.freq, 'gain': a.rx_gain,
            'rx_gain': a.rx_gain, 'tx_gain': a.tx_gain, 'dc_offset': a.dc_offset, 'k': a.k, 'tick_rate': r['tick'],
            'T_host_first_sample': r['T'], 'first_packet_ticks': r['first_ts'], 'radio_rx_offset': 6,
            'tap_time_first_sample': r['t_tap0'], 'n_requested': a.n_rx, 'n_received': r['got'],
            'errors': r['errs'], 'tx_async': r['tx_async'], 'tx_start_host_ticks': r['T'] + PRE, 'tx_lead': a.lead,
            'tx_burst_start_host_ticks': r['T'] + PRE - a.lead, 'tx': tx_meta,
            'window': r['win'], 'registers': r['regs'], 'events': r['events'],
            'events_timestamp_mismatch': r['ev_ts_bad'], 'event_recv_calls': r['ev_calls'],
            'event_recv_errors': r['ev_errors'], 'events_drain': r['drain'], 'date': time.strftime('%Y-%m-%dT%H:%M:%S')}
    out.with_suffix('.json').write_text(json.dumps(meta, indent=1) + '\n')
    w = r['win']
    print(f"capture {r['got']}/{a.n_rx} first ticks {r['first_ts']} (requested {r['T']}) errors {r['errs'][:3]} "
          f"tx_async {r['tx_async'][:4]}")
    print(f"window [{w['t_start']}, +{w['n']}): status {w['status']} count {w['count']} misr {w['misr']:#018x} "
          f"hist {w['hist']}")
    if r['events'] is not None:
        print(f"events received {len(r['events'])} (ts != word0: {r['ev_ts_bad']}), generated "
              f"{r['regs']['EVT_SEQ']}, dropped {r['regs']['EVT_DROP']}")
    ok = r['got'] == a.n_rx and r['first_ts'] == r['T'] and w['status']['done'] and not w['status']['late'] \
        and w['count'] == w['n']
    print('CAPTURE OK' if ok else 'CAPTURE INCOMPLETE')
    return 0 if ok else 1


def cmd_run(a):
    import uhd
    if a.cal:
        n_tx = a.n_tx
        x = np.zeros(n_tx, np.complex64)
        x[int(10e-6 * FS):n_tx - int(10e-6 * FS)] = a.amp * np.exp(2j * np.pi * a.cal_f * np.arange(
            n_tx - int(20e-6 * FS)) / FS)
        tx_meta = {'cal': True, 'f_hz': a.cal_f, 'amp': a.amp, 'n_tx': n_tx}
    else:
        x, lab, pulses = make_tx(a.seed, a.n_tx, a.amp, a.att_db, a.gap_us)
        tx_meta = {'seed': a.seed, 'n_tx': a.n_tx, 'amp': a.amp, 'att_db': a.att_db, 'gap_us': a.gap_us,
                   'n_pulses': len(pulses)}
    if a.n_rx < len(x) + PRE + 2000:
        sys.exit(f'n_rx {a.n_rx} too short for the TX waveform ({len(x)} + {PRE} + 2000)')
    g, n, radio, dram, rx, ev = setup(a, uhd)
    t0 = time.monotonic()
    xu = np.concatenate([np.zeros(a.lead, np.complex64), x]) if a.lead else x
    dram.upload(xu)
    print(f'uploaded {len(xu)} samples ({a.lead} lead zeros + {len(x)}; {xu.nbytes / 2**20:.1f} MiB fc32) in {time.monotonic() - t0:.1f} s')
    r = capture(a, uhd, g, n, radio, dram, rx, ev, xu, a.n_rx)
    rc = save(a, r, tx_meta)
    if a.cal:
        d = np.load(Path(a.out).with_suffix('.npz'))
        y = d['i'].astype(float) + 1j * d['q'].astype(float)
        on = y[PRE + 4000:PRE + len(x) - 4000]
        off = y[:PRE - 500]
        ps, pn = np.mean(np.abs(on) ** 2), np.mean(np.abs(off) ** 2)
        print(f'cal: on rms {np.sqrt(ps):.1f} ({20 * np.log10(np.sqrt(ps) / 32768):.1f} dBFS), off rms '
              f'{np.sqrt(pn):.1f} ({20 * np.log10(np.sqrt(pn) / 32768):.1f} dBFS), (S+N)/N {10 * np.log10(ps / pn):.1f} dB, '
              f'max |I|,|Q| {np.abs(d["i"]).max()},{np.abs(d["q"]).max()}')
    return rc


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--args', default='addr=192.168.40.2,recv_buff_size=100000000')
    sub = ap.add_subparsers(dest='cmd', required=True)
    for name in ('gen', 'run'):
        p = sub.add_parser(name)
        p.add_argument('--seed', type=int, default=0)
        p.add_argument('--n-tx', type=int, default=1 << 22)
        p.add_argument('--amp', type=float, default=0.5, help='peak digital amplitude (fraction of full scale)')
        p.add_argument('--att-db', type=float, default=30.0, help='per-pulse digital attenuation range')
        p.add_argument('--gap-us', type=float, nargs=2, default=[0.2, 2.0], help='noise gap range between pulses')
        p.add_argument('--out', required=True)
        if name == 'run':
            p.add_argument('--n-rx', type=int, default=(1 << 22) + 16384)
            p.add_argument('--freq', type=float, default=1e9)
            p.add_argument('--rx-gain', type=float, default=10.0)
            p.add_argument('--tx-gain', type=float, default=0.0)
            p.add_argument('--dc-offset', choices=('auto', 'off'), default='auto')
            p.add_argument('--k', type=int, default=16, help='hysteresis; use 60000 for dense runs on a VERSION 1.0 '
                           'image (events swamp the host: ~1e6 event packets/s, 2026-11-03); VERSION 2.0 packs up '
                           'to 16 records per packet')
            p.add_argument('--delay', type=float, default=0.5)
            p.add_argument('--lead', type=int, default=0,
                           help='zeros the TX plays before the signal set (TX on, so the UBX TX DC/LO leakage it adds '
                           'at RX is settled by rx_dcoffset, tau 2^20 samples, before the capture; 2026-11-03)')
            p.add_argument('--no-events', action='store_true',
                           help='do not read events; on a VERSION 2.0 image EVT_EN stays 0, so none are sent')
            p.add_argument('--evt-flush', type=int, default=None,
                           help='REG_EVT_FLUSH in cycles (VERSION 2.0; default: keep, 4096 at reset)')
            p.add_argument('--cal', action='store_true', help='CW at --cal-f instead of the signal set')
            p.add_argument('--cal-f', type=float, default=5e6)
        p.set_defaults(func=cmd_gen if name == 'gen' else cmd_run)
    a = ap.parse_args()
    sys.exit(a.func(a) or 0)


if __name__ == '__main__':
    main()
