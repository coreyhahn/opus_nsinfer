#!/usr/bin/env python3
"""Replay a host capture of radio0 (sw/x310/nsclf_host.py capture) through the nsclf RTL in Verilator and compare
with what the block reported on silicon: the MISR window (MISR, count, per-class counts, first / last tau) and
the event records.

  replay <stem>   <stem>.npz + <stem>.json from nsclf_host.py; runs `make -C tb nsclf_replay` on snoke
                  --dump: the tb also writes every decision (tau, {logits, cls}); the MISR, count, per-class counts
                  and first / last tau are recomputed from that dump in Python (nsclf_model.window) and must equal
                  the silicon read-back, which proves the dumped decisions are the silicon decisions; the dump is
                  kept as <work>/decisions.npz (tau0, words uint64) for sw/x310/nsclf_analyze.py
                  --flip-sample k [--flip-bit b]: negative control, flips I bit b (default 13) of capture sample k
  selftest        fabricates a "capture" from the golden stream (samples, host time T, the Python model's window
                  and events standing in for silicon), replays it: must PASS; then with one sample bit flipped:
                  must FAIL. This exercises the packing, the time alignment and the window definition without an X310.

The silicon side (replay of a real capture) is UNTESTED: no X310 was reachable (2026-10-30). selftest runs in sim.

Alignment (evidence/stage5/block/README.md section 3): capture sample k has host time T + k and tap time
T - RADIO_RX_OFFSET + k; the replay drives sample k on the radio port at radio_time T - 6 + k (one per clock, as
on the X310), so every decision's tau in the replay equals the silicon tau. The window is the one nsclf_host.py
armed: T_start = T - 6 + 63, N = n - 63 (all decisions whose 64-sample windows lie inside the capture).
Events: the silicon hysteresis state at the capture's start depends on samples before it; the replay starts from
reset (smoothed class 0), with EVT_EN written 1 during its configuration (VERSION 2.0 RTL; the tb's default with no
EVT_EN schedule). Records are compared as a list, so how silicon or the replay packed them into packets
(EVT_BATCH, EVT_FLUSH, back pressure) does not matter; the replay's own packets are checked against the packet rules. Once both have emitted an event with the same tau and new class, their states are equal,
so the events after that one must match exactly (the run length of that first common event is not compared).
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import nsclf_model as m  # noqa: E402

ROOT = HERE.parents[1]
W = 64
RADIO_RX_OFFSET = 6
M64 = (1 << 64) - 1


def write_stim(d: Path, i, q, t_tap0: int, t_start: int, n: int):
    d.mkdir(parents=True, exist_ok=True)
    m.write_hex(d / 'samples.hex', [m.radio_word(int(a), int(b)) for a, b in zip(i, q)], 8)
    m.write_hex(d / 'toff.hex', range(len(i)), 8)
    (d / 'windows.hex').write_text(f'{t_start:016x} {n:08x} ' + ' '.join(['0'] * 8) + '\n')


def run_replay(d: Path, ns: int, t_tap0: int, k: int, lc: str, host: str, dump: Path | None = None) -> Path:
    log = d / 'replay.log'
    mk = (f'make -C tb nsclf_replay LC={lc} RNS={ns} RSTIM={d} RT0={t_tap0:x} RK={k} RLOG={log} JOBS=16'
          + (f' RDUMP={dump}' if dump else ''))
    cmd = ['ssh', host, f'cd {ROOT} && {mk}'] if host else ['bash', '-c', f'cd {ROOT} && {mk}']
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        print(r.stdout[-3000:], r.stderr[-3000:])
        raise SystemExit(f'replay run failed (rc {r.returncode}), log {log}')
    return log


def parse_log(log: Path):
    """Window 0 and the event records of a replay tb log. Events come as packets (EVTPKT + EVT lines, VERSION 2.0 RTL:
    up to EVT_BATCH records each); every packet is parsed and checked (timestamp = first record's tau, whole
    records, order) by nsclf_model.parse_packet / check_packets; v1 logs (EVT lines only) parse as 1-record packets."""
    win = None
    for line in log.read_text().splitlines():
        if line.startswith('WINDOW 0 '):
            g = dict(re.findall(r'(\w+)=([0-9a-fA-F,]+)', line))
            win = {'misr': int(g['misr'], 16), 'count': int(g['count']), 'hist': [int(x) for x in g['hist'].split(',')],
                   'tfirst': int(g['tfirst'], 16), 'tlast': int(g['tlast'], 16), 'status': int(g['status'], 16)}
    if 'PASS' not in log.read_text():
        raise SystemExit(f'replay tb did not PASS its own checks: {log}')
    try:
        raw, _, _, _ = m.read_tb_events(log)
        pkts = [(ts, m.parse_packet(ts, w)) for ts, w in raw]
    except ValueError as e:
        raise SystemExit(f'replay tb event packets malformed ({e}): {log}')
    cfg = re.search(r'^EVTCFG batch=(\d+) aw=\d+ flush=(\d+)', log.read_text(), re.M)
    if cfg:
        perr = m.check_packets(pkts, int(cfg.group(1)), int(cfg.group(2)))
        if perr:
            raise SystemExit(f'replay tb event packets break the packet rules ({perr[0]}): {log}')
    ev = [r for _, recs in pkts for r in recs]
    sizes = [len(r) for _, r in pkts]
    print(f'REPLAY EVENT PACKETS {len(pkts)} records {len(ev)} max/packet {max(sizes) if sizes else 0}')
    return win, ev


def compare(sil_win: dict, sim_win: dict, sil_ev: list[dict] | None, sim_ev: list[dict], t_start: int, t_last: int):
    err = []
    for f in ('misr', 'count', 'hist', 'tfirst', 'tlast'):
        if sil_win[f] != sim_win[f]:
            a, b = sil_win[f], sim_win[f]
            err.append(f'window {f}: silicon {a:#x} sim {b:#x}' if isinstance(a, int) else f'window {f}: silicon {a} sim {b}')
    n_cmp = 0
    if sil_ev is not None:
        se = [e for e in sil_ev if t_start <= e['tau'] <= t_last]
        key = {(e['tau'], e['new']): j for j, e in enumerate(sim_ev)}
        start = next(((i, key[(e['tau'], e['new'])]) for i, e in enumerate(se) if (e['tau'], e['new']) in key), None)
        if start is None and se:
            err.append('no common event between silicon and replay')
        elif start is not None:
            i0, j0 = start
            a, b = se[i0:], sim_ev[j0:]
            if len(a) != len(b):
                err.append(f'events after the first common one: silicon {len(a)} replay {len(b)}')
            for x, (p, q) in enumerate(zip(a, b)):
                for f in ('tau', 'new', 'old', 'k') + (('run',) if x > 0 else ()):
                    if p[f] != q[f]:
                        err.append(f'event {x} after sync: {f} silicon {p[f]} replay {q[f]}')
                n_cmp += 1
    return err, n_cmp


HEX_LUT = None


def _hex64(cols):
    """(n, 16) ASCII hex digit columns -> uint64."""
    import numpy as np
    v = HEX_LUT[cols]
    if (v > 15).any():
        raise SystemExit('dump: non-hex character')
    out = np.zeros(len(cols), np.uint64)
    for c in range(16):
        out = (out << np.uint64(4)) | v[:, c].astype(np.uint64)
    return out


def check_dump(txt: Path, t_tap0: int, ns: int, sil: dict, t_start: int, n: int, keep_txt: bool) -> list[str]:
    """Parse the tb's decision dump, recompute the silicon window from it, save decisions.npz."""
    global HEX_LUT
    import numpy as np
    HEX_LUT = np.full(256, 255, np.uint8)
    HEX_LUT[48:58] = np.arange(10)
    HEX_LUT[97:103] = np.arange(10, 16)
    raw = np.fromfile(txt, dtype=np.uint8)
    if len(raw) % 34:
        return [f'dump {txt}: size {len(raw)} not a multiple of 34']
    a = raw.reshape(-1, 34)
    if not ((a[:, 16] == 32).all() and (a[:, 33] == 10).all()):
        return [f'dump {txt}: bad line format']
    tau, words = _hex64(a[:, 0:16]), _hex64(a[:, 17:33])
    err = []
    nd = ns - (W - 1)
    if len(tau) != nd:
        err.append(f'dump: {len(tau)} decisions, expected {nd}')
    exp_tau = np.uint64(t_tap0 + W - 1) + np.arange(len(tau), dtype=np.uint64)
    if not np.array_equal(tau, exp_tau):
        err.append(f'dump: tau not t_tap0 + 63 + j ({int(np.sum(tau != exp_tau))} differ)')
    wl = [int(x) for x in words]
    r = m.window([int(x) for x in tau], wl, [x & 3 for x in wl], t_start, n)
    for f in ('misr', 'count', 'hist', 'tfirst', 'tlast'):
        if r[f] != sil[f]:
            err.append(f'dump-recomputed window {f}: dump {r[f]} silicon {sil[f]}')
    np.savez_compressed(txt.with_name('decisions.npz'), tau0=np.uint64(int(tau[0])), words=words,
                        t_tap0=np.int64(t_tap0))
    print(f"DUMP decisions={len(tau)} tau0={int(tau[0])} misr(recomputed from dump)={r['misr']:#018x} "
          f"count={r['count']} hist={r['hist']} -> {'EQUALS' if not err else 'DIFFERS FROM'} the silicon read-back; "
          f"saved {txt.with_name('decisions.npz')}")
    if not keep_txt:
        txt.unlink()
    return err


def cmd_replay(a):
    stem = Path(a.stem)
    meta = json.loads(stem.with_suffix('.json').read_text())
    import numpy as np  # only for reading the capture (darthplagueis)
    z = np.load(stem.with_suffix('.npz'))
    i, q = z['i'].copy(), z['q'].copy()
    ns = len(i)
    t_tap0 = int(meta['T_host_first_sample']) - int(meta.get('radio_rx_offset', RADIO_RX_OFFSET)) + a.extra_offset
    wn = meta['window']
    print(f"CAPTURE {stem.name}: {ns} samples, T={meta['T_host_first_sample']} tap0={t_tap0} "
          f"(offset {meta.get('radio_rx_offset', RADIO_RX_OFFSET)}, extra {a.extra_offset}) K={meta['k']} "
          f"window t_start={wn['t_start']} n={wn['n']} silicon misr={wn['misr']:#018x} count={wn['count']} "
          f"hist={wn['hist']} status={wn['status']} errors={meta.get('errors')} tx={meta.get('tx')}")
    if a.extra_offset:
        print(f'NEGATIVE CONTROL: replay tap time shifted by {a.extra_offset} sample(s)')
    if a.flip_sample is not None:
        old = int(i[a.flip_sample])
        i[a.flip_sample] = np.int16(np.uint16(old & 0xFFFF) ^ np.uint16(1 << a.flip_bit))
        print(f'NEGATIVE CONTROL: capture sample {a.flip_sample} I bit {a.flip_bit} flipped ({old} -> {int(i[a.flip_sample])})')
    d = Path(a.work or (ROOT / '.scratch' / 'nsclf_replay' / stem.name)).resolve()   # make runs in tb/
    write_stim(d, i, q, t_tap0, wn['t_start'], wn['n'])
    dump = d / 'decisions.txt' if a.dump else None
    log = run_replay(d, ns, t_tap0, int(meta['k']), a.lc, a.host, dump)
    for line in log.read_text().splitlines():
        if line.startswith('# host=') or line.startswith('RESULT '):
            print('TB', line)
    sim_win, sim_ev = parse_log(log)
    sil = {k: wn[k] for k in ('misr', 'count', 'hist', 'tfirst', 'tlast')}
    sev = meta.get('events')
    if sev is not None:
        seqs = [e['seq'] for e in sev]
        gaps = sum(1 for x, y in zip(seqs, seqs[1:]) if y != x + 1)
        print(f"SILICON EVENTS received={len(sev)} seq {seqs[0] if seqs else None}..{seqs[-1] if seqs else None} "
              f"seq gaps={gaps} nonzero drop fields={sum(1 for e in sev if e['drops'])} "
              f"EVT_SEQ={meta['registers']['EVT_SEQ']} EVT_DROP={meta['registers']['EVT_DROP']} "
              f"EVT_PKTS={meta['registers'].get('EVT_PKTS', 'n/a (VERSION 1.0)')} "
              f"host ts!=word0 count={meta.get('events_timestamp_mismatch')}")
    err, n_cmp = compare(sil, sim_win, sev, sim_ev, wn['t_start'], wn['t_start'] + wn['n'] - 1)
    if dump:
        err += check_dump(dump, t_tap0, ns, sil, wn['t_start'], wn['n'], a.keep_txt)
    report(err, sim_win, n_cmp, log)


def report(err, sim_win, n_cmp, log):
    for e in err[:20]:
        print('MISMATCH', e)
    print(f"REPLAY window count={sim_win['count']} misr={sim_win['misr']:#018x} hist={sim_win['hist']} "
          f"events compared={n_cmp} errors={len(err)} log={log}")
    print('PASS' if not err else 'FAIL')
    if err:
        sys.exit(1)


def cmd_selftest(a):
    """Golden stream as a fake capture; the Python model stands in for silicon."""
    samp, logits, cls, Wm, out_w = m.load_stream()
    assert Wm == W
    T = 0x0000_0001_0000_0000 + 12345           # host timestamp of the first captured sample
    t_tap0 = T - RADIO_RX_OFFSET
    ns = len(samp)
    t_start, n = t_tap0 + W - 1, ns - (W - 1)
    taus = [t_tap0 + W - 1 + d for d in range(len(cls))]
    words = [m.dec_word(l, c, out_w) for l, c in zip(logits, cls)]
    sil_win = m.window(taus, words, cls, t_start, n)
    sil_ev = m.hysteresis(taus, cls, a.k)
    i = [s[0] for s in samp]
    q = [s[1] for s in samp]
    tag = ''
    if a.flip is not None:
        # bit 13: the model ignores sample LSBs (its input quantizer keeps 1-5 bits per lane after BFP), so an LSB
        # flip need not change any logit; a high bit changes the BFP shift and the kept bits of 64 windows
        i[a.flip] ^= 1 << 13
        tag = f'_flip{a.flip}'
        print(f'NEGATIVE CONTROL: capture sample {a.flip} I bit 13 flipped (silicon values unchanged)')
    if a.shift:
        tag += f'_shift{a.shift}'
        print(f'NEGATIVE CONTROL: replay tap time shifted by {a.shift} sample(s) against the silicon window')
    d = Path(a.work or (ROOT / '.scratch' / 'nsclf_replay' / ('selftest' + tag))).resolve()
    write_stim(d, i, q, t_tap0 + a.shift, t_start, n)
    log = run_replay(d, ns, t_tap0 + a.shift, a.k, a.lc, a.host)
    sim_win, sim_ev = parse_log(log)
    err, n_cmp = compare(sil_win, sim_win, sil_ev, sim_ev, t_start, t_start + n - 1)
    report(err, sim_win, n_cmp, log)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--lc', default='2')
    ap.add_argument('--host', default='snoke', help="host for Verilator ('' = local)")
    ap.add_argument('--work', default=None)
    sub = ap.add_subparsers(dest='cmd', required=True)
    r = sub.add_parser('replay')
    r.add_argument('stem')
    r.add_argument('--extra-offset', type=int, default=0, help='diagnostic: shift the assumed tap time')
    r.add_argument('--dump', action='store_true', help='dump every decision, recompute the silicon window from it')
    r.add_argument('--keep-txt', action='store_true', help='keep the text dump next to decisions.npz')
    r.add_argument('--flip-sample', type=int, default=None, help='negative control: flip one I bit of this sample')
    r.add_argument('--flip-bit', type=int, default=13)
    r.set_defaults(func=cmd_replay)
    s = sub.add_parser('selftest')
    s.add_argument('--k', type=int, default=16)
    s.add_argument('--flip', type=int, default=None, help='negative control: flip I bit 13 of this sample')
    s.add_argument('--shift', type=int, default=0, help='negative control: misalign the replay by this many samples')
    s.set_defaults(func=cmd_selftest)
    a = ap.parse_args()
    a.func(a)


if __name__ == '__main__':
    main()
