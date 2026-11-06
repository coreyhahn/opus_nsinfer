#!/usr/bin/env python3
"""Reference model of the nsclf RFNoC block's user logic (rtl/x310/nsclf_core.sv), bit for bit.

What it models (evidence/stage5/block/README.md has the definitions):
  * decision d of the sliding-window classifier is the window whose NEWEST sample is sample d + W - 1;
    its tap time tau(d) is the radio_time value in the clock cycle in which that sample is on
    radio_rx_data at the block's radio_in port (with radio_rx_stb high);
  * MISR window [T_start, T_start + N): the decisions with T_start <= tau <= T_start + N - 1;
    64-bit Galois MISR, seed all ones, polynomial x^64 + x^63 + x^61 + x^60 + 1 (XAPP052 taps 64,63,61,60),
    one step per decision with data word {logits[61:0], cls[1:0]}; per-class counts, count, first/last tau;
  * hysteresis: the smoothed class changes to c at decision d when d is the K-th consecutive raw decision
    equal to c (c != current); an event record (tau(d), new, old, K, prev run length, seq) is emitted;
  * (2026-11 event revision, block VERSION 2.0) EVT_EN (REG_CTRL bit 2, 0 at reset): a change makes an event (record,
    EVT_SEQ step) only while EVT_EN = 1; the hysteresis itself always runs. Records leave in CHDR packets of up to
    EVT_BATCH records (timestamp = first record's tau, 24 bytes per record); a packet closes at EVT_BATCH records or
    when its oldest record has waited EVT_FLUSH cycles (EVT_FLUSH = 0: one record per packet). The packet boundaries
    depend on cycle timing and back pressure: tb/tb_nsclf.sv checks them cycle by cycle; here the packet structure
    rules are checked (check_packets).

Also the CLI that makes the Verilator stimulus and expected-value files (tb/tb_nsclf.sv), and checks a
Verilator or silicon capture. No hardware access here.
"""
from __future__ import annotations

import argparse
import json
import random
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
GOLDEN = ROOT / 'ref' / 'golden'

MISR_POLY = 0xB000000000000001          # x^64 + x^63 + x^61 + x^60 + 1, lower 64 coefficients
MISR_SEED = 0xFFFFFFFFFFFFFFFF
M64 = (1 << 64) - 1
M32 = (1 << 32) - 1


# ----------------------------------------------------------------------------------------------- data
def s16(v: int) -> int:
    return v - 0x10000 if v & 0x8000 else v


def load_stream(golden: Path = GOLDEN):
    """Golden stream: samples [(I, Q)] int16; per-window logits (int, OUT_W bits) and classes. Standard library
    only (snoke's python3 has no numpy)."""
    raw = [int(l, 16) for l in (golden / 'x310_stream_in.hex').read_text().split()]
    samp = [(s16(r & 0xFFFF), s16((r >> 16) & 0xFFFF)) for r in raw]   # hex word = {Q[31:16], I[15:0]}
    logits = [int(l, 16) for l in (golden / 'x310_stream_out.hex').read_text().split()]
    cls = [int(l, 16) for l in (golden / 'x310_stream_dec.hex').read_text().split()]
    meta = json.loads((golden / 'x310_golden.json').read_text())
    return samp, logits, cls, int(meta['w']), int(meta['out_width_bits'])


def radio_word(i: int, q: int) -> int:
    """sc16 item at the X310 radio io_port: I in [31:16], Q in [15:0] (fe_control.v, rx_frontend_gen3)."""
    return ((i & 0xFFFF) << 16) | (q & 0xFFFF)


def dec_word(logit: int, c: int, out_w: int) -> int:
    """MISR data word {logits, cls}; wider than 64 bits (out_w > 62), bits 64.. are XORed into the top bits so cls
    stays in [1:0] (rtl/x310/nsclf_core.sv dword)."""
    dw = out_w + 2
    assert dw <= 126
    w = ((logit & ((1 << out_w) - 1)) << 2) | (c & 3)
    if dw <= 64:
        return w
    return (w & M64) ^ (((w >> 64) << (128 - dw)) & M64)


# ----------------------------------------------------------------------------------------------- MISR
def misr_step(s: int, d: int) -> int:
    s2 = (s << 1) & M64
    if s >> 63:
        s2 ^= MISR_POLY
    return s2 ^ d


def window(taus, words, cls, t_start: int, n: int) -> dict:
    """MISR, counts, first/last tau over the decisions with t_start <= tau <= t_start + n - 1."""
    t_last = (t_start + n - 1) & M64
    s, cnt, hist, tf, tl = MISR_SEED, 0, [0, 0, 0, 0], None, None
    for t, w, c in zip(taus, words, cls):
        if t_start <= t <= t_last:
            s = misr_step(s, w)
            cnt += 1
            hist[c] += 1
            tf = t if tf is None else tf
            tl = t
    return {'misr': s, 'count': cnt, 'hist': hist, 'tfirst': tf, 'tlast': tl}


# ----------------------------------------------------------------------------------------------- hysteresis
def hysteresis(taus, cls, k: int, cur0: int = 0, en0: bool = True, switches=()) -> list[dict]:
    """Events of the K-consecutive rule (k <= 1: every raw change is an event). Same state machine as RTL.
    EVT_EN: en0 is its state before the first decision; switches = [(t_sw, en), ...] sorted: from the first decision
    with tau >= t_sw on, EVT_EN = en. A change while EVT_EN = 0 updates the state but makes no event and no seq step."""
    sw = sorted(switches)
    isw, en = 0, bool(en0)
    keff = max(1, k)
    cur, cand, cnt, run, seq, ev = cur0, 0, 0, 0, 0, []
    for t, c in zip(taus, cls):
        while isw < len(sw) and t >= sw[isw][0]:
            en = bool(sw[isw][1])
            isw += 1
        if c == cur:
            cnt = 0
            run = min(run + 1, M32)
            continue
        ncnt = cnt + 1 if (c == cand and cnt != 0) else 1
        if ncnt >= keff:
            if en:
                ev.append({'tau': t, 'new': c, 'old': cur, 'k': keff, 'run': run, 'seq': seq})
                seq += 1
            cur, cnt, run = c, 0, 1
        else:
            cand, cnt = c, ncnt
            run = min(run + 1, M32)
    return ev


# ----------------------------------------------------------------------------------------------- event records
EVT_WORDS = 3


def evt_words(e: dict, drops: int) -> list[int]:
    """The 3 x 64-bit payload words of one event record (rtl/x310/nsclf_core.sv)."""
    w0 = e['tau'] & M64
    w1 = ((e['run'] & M32) << 32) | ((e['k'] & 0xFFFF) << 16) | (1 << 8) | ((e['old'] & 0xF) << 4) | (e['new'] & 0xF)
    w2 = ((e['seq'] & M32) << 32) | (drops & M32)
    return [w0, w1, w2]


def evt_packet_words(recs: list[tuple[dict, int]]) -> list[int]:
    """Payload of one event packet: the records' 3-word groups back to back (CHDR timestamp = recs[0] tau)."""
    out = []
    for e, d in recs:
        out += evt_words(e, d)
    return out


def parse_packet(ts: int, w: list[int]) -> list[dict]:
    """One event packet (CHDR timestamp ts, payload words w) -> records; raises ValueError on a malformed packet."""
    if not w or len(w) % EVT_WORDS:
        raise ValueError(f'packet with {len(w)} payload words, not a positive multiple of {EVT_WORDS}')
    recs = [parse_evt(w[i:i + EVT_WORDS]) for i in range(0, len(w), EVT_WORDS)]
    if recs[0]['tau'] != ts:
        raise ValueError(f'CHDR timestamp {ts:#x} != first record tau {recs[0]["tau"]:#x}')
    return recs


def check_packets(pkts: list[tuple[int, list[dict]]], batch: int, flush: int) -> list[str]:
    """Packet structure: 1 <= n <= nbmax (EVT_FLUSH 0: 1), timestamp = first record's tau (checked by the parser),
    records in a packet in seq order, tau not decreasing."""
    nbmax = 1 if flush == 0 else batch
    err = []
    for i, (ts, recs) in enumerate(pkts):
        if not 1 <= len(recs) <= nbmax:
            err.append(f'packet {i} (ts {ts:#x}): {len(recs)} records, allowed 1..{nbmax}')
        for a, b in zip(recs, recs[1:]):
            if b['seq'] <= a['seq'] or b['tau'] < a['tau']:
                err.append(f'packet {i}: records out of order (seq {a["seq"]} -> {b["seq"]})')
    return err


def parse_evt(w: list[int]) -> dict:
    return {'tau': w[0], 'run': w[1] >> 32, 'k': (w[1] >> 16) & 0xFFFF, 'ver': (w[1] >> 8) & 0xF,
            'old': (w[1] >> 4) & 0xF, 'new': w[1] & 0xF, 'seq': w[2] >> 32, 'drops': w[2] & M32}


def check_events(model: list[dict], got: list[dict], drop_reg: int, seq_reg: int) -> list[str]:
    """Every received record equals the model's record with the same seq; seqs strictly increase; the
    drop counter equals the number of model events not received; the seq register equals their total."""
    err = []
    last = -1
    for g in got:
        s = g['seq']
        if s <= last:
            err.append(f'event seq {s} not increasing (previous {last})')
        last = s
        if s >= len(model):
            err.append(f'event seq {s} beyond the model\'s {len(model)} events')
            continue
        m = model[s]
        for f in ('tau', 'new', 'old', 'k', 'run'):
            if g[f] != m[f]:
                err.append(f'event seq {s} field {f}: got {g[f]} model {m[f]}')
    if seq_reg != len(model):
        err.append(f'EVT_SEQ register {seq_reg} != model events {len(model)}')
    if drop_reg != len(model) - len(got):
        err.append(f'EVT_DROP register {drop_reg} != model {len(model)} - received {len(got)}')
    return err


# ----------------------------------------------------------------------------------------------- stimulus
def make_taus(n: int, t0: int, seed: int, gap_p: float) -> list[int]:
    """Tap time of each sample. gap_p 0: one sample per clock (the X310: rx_stb is constant 1); else before
    each sample an idle cycle follows with probability gap_p, repeatedly (geometric), random.Random(seed)."""
    if gap_p <= 0:
        return [t0 + k for k in range(n)]
    rng = random.Random(20261030 * 1000 + seed)
    out, t = [], t0 - 1
    for _ in range(n):
        t += 1
        while rng.random() < gap_p:
            t += 1
        out.append(t)
    return out


def pick_windows(taus_dec: list[int], seed: int, slack: int) -> list[tuple[int, int, int]]:
    """(T_start, N, late) per window, sequential, with >= slack cycles between one window's last decision
    and the next one's start (for readback and re-arm). seed 0: one window over the whole stream."""
    first, last = taus_dec[0], taus_dec[-1]
    if seed == 0:
        return [(first - 5, last - first + 11, 0)]
    rng = random.Random(20261030 * 1000 + 77 * 100 + seed)
    out, t = [], first + 300
    sizes = [1, 64, 1000, 7, 12000, 333]
    for n in sizes:
        ts = t + rng.randrange(2000)
        if ts + n + slack > last:
            break
        out.append((ts, n, 0))
        t = ts + n + slack
    # one window ending past the last decision (end of stream): done never arrives; read when idle
    out.append((last - 50, 1000, 0))
    return out


def pick_switches(ev_taus: list[int], first: int, last: int, fracs: list[float], margin: int) -> list[int]:
    """EVT_EN switch tap times: for each fraction f of [first, last], the first time x >= first + f (last - first)
    (and after the previous switch) with no hysteresis change (enabled or not) within margin ticks of it, so the
    ctrlport write's timing jitter (a few cycles) cannot change which events are enabled."""
    out = []
    edges = sorted(ev_taus) + [last + 2 * margin]
    for f in fracs:
        t = max(first + int(f * (last - first)), out[-1] + margin if out else first)
        prev = None
        for b in edges:
            if b < t:
                prev = b
                continue
            x = t if prev is None else max(t, prev + margin)
            if b - x >= margin:
                out.append(x)
                break
            prev = b
        else:
            raise SystemExit(f'pick_switches: no quiet gap of {2 * margin} ticks after fraction {f}')
        if out[-1] > last:
            raise SystemExit(f'pick_switches: no quiet gap of {2 * margin} ticks after fraction {f} in the stream')
    for x in out:
        assert not [e for e in ev_taus if abs(e - x) < margin], x
    return out


def write_hex(path: Path, vals, digits: int):
    path.write_text(''.join(f'{int(v):0{digits}x}\n' for v in vals))


def cmd_stim(a):
    samp, logits, cls, W, out_w = load_stream(Path(a.golden))
    n = len(samp)
    t0 = int(a.t0, 0)
    taus = make_taus(n, t0, a.seed, a.gap_p)
    taus_dec = [int(t) for t in taus[W - 1:]]
    words = [dec_word(l, c, out_w) for l, c in zip(logits, cls)]
    od = Path(a.out)
    od.mkdir(parents=True, exist_ok=True)
    # per sample: radio word {I, Q} and its cycle offset from t0
    write_hex(od / 'samples.hex', [radio_word(i, q) for i, q in samp], 8)
    write_hex(od / 'toff.hex', [int(t) - t0 for t in taus], 8)
    write_hex(od / 'dec.hex', [(w) for w in words], 16)
    wins = pick_windows(taus_dec, a.seed, a.slack)
    exp = []
    for ts, nn, late in wins:
        r = window(taus_dec, words, cls, ts, nn)
        exp.append({'t_start': ts, 'n': nn, **r})
    # EVT_EN schedule: 'on' = written 1 at configuration (before the stream); 'toggle:f1,f2,..' = off from reset,
    # flipped at the tap times picked after those fractions of the decision tau range (first switch turns it on)
    if a.evt_en == 'on':
        en0, sw_t = True, []
    elif a.evt_en.startswith('toggle:'):
        en0 = False
        all_ev = hysteresis(taus_dec, cls, a.k)
        sw_t = pick_switches([e['tau'] for e in all_ev], taus_dec[0], taus_dec[-1],
                             [float(x) for x in a.evt_en[7:].split(',')], a.sw_margin)
    else:
        raise SystemExit(f'--evt-en {a.evt_en}: expected on | toggle:f1,f2,...')
    switches = [(t, (i + 1) % 2 == 1) for i, t in enumerate(sw_t)]
    ev = hysteresis(taus_dec, cls, a.k, en0=en0, switches=switches)
    with open(od / 'evten.hex', 'w') as f:
        for t, v in switches:
            f.write(f'{t:016x} {int(v):016x}\n')
    # window file for the tb: t_start n misr count h0..h3 tfirst tlast (hex, one window per line)
    with open(od / 'windows.hex', 'w') as f:
        for e in exp:
            tf = e['tfirst'] if e['tfirst'] is not None else 0
            tl = e['tlast'] if e['tlast'] is not None else 0
            f.write(f"{e['t_start']:016x} {e['n']:08x} {e['misr']:016x} {e['count']:08x} "
                    + ' '.join(f'{h:08x}' for h in e['hist']) + f' {tf:016x} {tl:016x}\n')
    meta = {'seed': a.seed, 't0': t0, 'gap_p': a.gap_p, 'k': a.k, 'n_samples': n, 'w': W, 'out_w': out_w,
            'n_decisions': len(words), 'n_windows': len(exp), 'n_events': len(ev),
            'evt_en': a.evt_en, 'evt_en0': en0, 'evt_switches': [[hex(t), int(v)] for t, v in switches],
            'evt_flush': a.flush, 'evt_batch': a.batch,
            'windows': [{k: (v if not isinstance(v, int) or v < (1 << 53) else hex(v)) for k, v in e.items()}
                        for e in exp]}
    (od / 'meta.json').write_text(json.dumps(meta, indent=1) + '\n')
    (od / 'events_model.json').write_text(json.dumps(ev) + '\n')
    print(f"STIM seed={a.seed} t0={t0:#x} gap_p={a.gap_p} samples={n} decisions={len(words)} windows={len(exp)} "
          f"events(K={a.k})={len(ev)} last_tau={taus_dec[-1]:#x} evt_en={a.evt_en} switches={len(switches)} "
          f"flush={a.flush} batch={a.batch}")


def read_tb_events(log: Path):
    """EVTPKT / EVT / EVTREG lines of a tb log -> packets [(ts, [words...])], drop_reg, seq_reg, pkts_reg.
    'EVTPKT <ts> <n>' opens a packet of n records, each an 'EVT <ts> <w0> <w1> <w2>' line; an EVT line without a
    preceding EVTPKT (v1 logs, VERSION 1.0 images) is a one-record packet."""
    pkts, drop_reg, seq_reg, pkts_reg, cur, want = [], None, None, None, None, 0
    for line in Path(log).read_text().splitlines():
        p = line.split()
        if not p:
            continue
        if p[0] == 'EVTPKT':                    # EVTPKT <ts> <n>
            if want:
                raise ValueError(f'EVTPKT before the previous packet had all its records: {line}')
            cur, want = (int(p[1], 16), []), int(p[2])
            pkts.append(cur)
        elif p[0] == 'EVT':                     # EVT <ts> <w0> <w1> <w2>
            ts, w = int(p[1], 16), [int(x, 16) for x in p[2:5]]
            if not want:
                cur, want = (ts, []), 1
                pkts.append(cur)
            if ts != cur[0]:
                raise ValueError(f'EVT line timestamp {ts:#x} != its packet timestamp {cur[0]:#x}')
            cur[1].extend(w)
            want -= 1
        elif p[0] == 'EVTREG':                  # EVTREG drop=<d> seq=<s> [pkts=<p>]
            kv = dict(x.split('=') for x in p[1:])
            drop_reg, seq_reg = int(kv['drop']), int(kv['seq'])
            pkts_reg = int(kv['pkts']) if 'pkts' in kv else None
    if want:
        raise ValueError('log ends inside a packet')
    return pkts, drop_reg, seq_reg, pkts_reg


def cmd_check_events(a):
    """Compare the tb's received event packets / records (EVTPKT, EVT lines in its log) with the model."""
    model = json.loads(Path(a.model).read_text())
    mp = Path(a.model).with_name('meta.json')
    meta = json.loads(mp.read_text()) if mp.exists() else {}
    batch = a.batch if a.batch is not None else int(meta.get('evt_batch', 1))
    flush = a.flush if a.flush is not None else int(meta.get('evt_flush', 0))
    try:
        raw, drop_reg, seq_reg, pkts_reg = read_tb_events(Path(a.log))
    except ValueError as e:
        print(f'FAIL: {e}')
        sys.exit(1)
    if drop_reg is None:
        print('FAIL: no EVTREG line in the log')
        sys.exit(1)
    if a.corrupt_pkt:
        # negative control: one bit of the second record of the first multi-record packet, as received
        j = next((i for i, (ts, w) in enumerate(raw) if len(w) >= 2 * EVT_WORDS), None)
        if j is None:
            print('FAIL: --corrupt-pkt: no packet with 2 or more records in the log')
            sys.exit(1)
        raw[j][1][EVT_WORDS + 1] ^= 1 << 32
        print(f'NEGATIVE CONTROL: packet {j} ({len(raw[j][1]) // EVT_WORDS} records): record 1 run length bit 0 flipped')
    pkts, err = [], []
    for ts, w in raw:
        try:
            pkts.append((ts, parse_packet(ts, w)))
        except ValueError as e:
            err.append(f'packet ts {ts:#x}: {e}')
    got = [r for _, recs in pkts for r in recs]
    if a.corrupt is not None and model:
        model[a.corrupt % len(model)]['run'] ^= 1
        print(f'NEGATIVE CONTROL: model event {a.corrupt % len(model)} run length corrupted')
    err += check_packets(pkts, batch, flush)
    err += check_events(model, got, drop_reg, seq_reg)
    if pkts_reg is not None and pkts_reg != len(pkts):
        err.append(f'EVT_PKTS register {pkts_reg} != packets received {len(pkts)}')
    for e in err[:10]:
        print('MISMATCH', e)
    sizes = [len(r) for _, r in pkts]
    nbmax = 1 if flush == 0 else batch
    print(f'PACKETS n={len(pkts)} records={len(got)} batch={batch} flush={flush} full={sum(1 for x in sizes if x == nbmax)} '
          f'partial={sum(1 for x in sizes if x < nbmax)} max={max(sizes) if sizes else 0} '
          f'mean={len(got) / len(pkts) if pkts else 0:.2f} pkts_reg={pkts_reg}')
    print(f'EVENTS model={len(model)} received={len(got)} drop_reg={drop_reg} seq_reg={seq_reg} errors={len(err)}')
    if err:
        print('FAIL')
        sys.exit(1)
    print('PASS')


def cmd_ksweep(a):
    """Events on the golden stream per K, against the true segment changes (to choose the K default)."""
    samp, logits, cls, W, out_w = load_stream(Path(a.golden))
    taus = list(range(len(cls)))
    raw_changes = sum(1 for x, y in zip(cls, cls[1:]) if x != y)
    print(f'decisions={len(cls)} raw class changes={raw_changes}')
    for k in a.k:
        ev = hysteresis(taus, cls, k)
        print(f'K={k:3d} events={len(ev):6d} min_run={min([e["run"] for e in ev[1:]] or [0]):6d}')


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest='cmd', required=True)
    s = sub.add_parser('stim', help='Verilator stimulus + expected values for tb_nsclf')
    s.add_argument('--golden', default=str(GOLDEN))
    s.add_argument('--out', required=True)
    s.add_argument('--seed', type=int, default=0)
    s.add_argument('--gap-p', type=float, default=0.0)
    s.add_argument('--t0', default='0xFFFFF000')
    s.add_argument('--k', type=int, default=16)
    s.add_argument('--slack', type=int, default=600)
    s.add_argument('--evt-en', default='on', help="EVT_EN schedule: 'on' (written 1 before the stream) or "
                   "'toggle:f1,f2,...' (off from reset, flipped at quiet points after those fractions of the stream)")
    s.add_argument('--sw-margin', type=int, default=48, help='EVT_EN switches: free ticks around each switch')
    s.add_argument('--flush', type=int, default=4096, help='REG_EVT_FLUSH the tb writes (recorded in meta.json)')
    s.add_argument('--batch', type=int, default=16, help='EVT_BATCH of the RTL (recorded in meta.json)')
    s.set_defaults(func=cmd_stim)
    c = sub.add_parser('check-events', help='compare the EVT lines of a tb log with the model')
    c.add_argument('--model', required=True)
    c.add_argument('--log', required=True)
    c.add_argument('--corrupt', type=int, default=None)
    c.add_argument('--corrupt-pkt', action='store_true', help='negative control: corrupt a record inside a '
                   'multi-record packet of the log')
    c.add_argument('--batch', type=int, default=None, help='EVT_BATCH (default: the model dir meta.json, else 1)')
    c.add_argument('--flush', type=int, default=None, help='EVT_FLUSH (default: the model dir meta.json, else 0)')
    c.set_defaults(func=cmd_check_events)
    k = sub.add_parser('ksweep', help='event count vs K on the golden stream')
    k.add_argument('--golden', default=str(GOLDEN))
    k.add_argument('--k', type=int, nargs='+', default=[1, 2, 4, 8, 12, 16, 24, 32, 48, 64])
    k.set_defaults(func=cmd_ksweep)
    a = ap.parse_args()
    a.func(a)


if __name__ == '__main__':
    main()
