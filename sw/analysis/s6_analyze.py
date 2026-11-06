"""Stage 6 silicon analysis: parse sw/bcu/desk.sh run logs of sw/bcu/s6_measure.cmd (docs/PLAN.md D-S6-MEAS).

Two kinds of section:
  * `ECHO run <name>` (echo_gap63, decode_gap63, decode_gap7): the Stage 3/4 loop runs, checked exactly as
    sw/analysis/s3_analyze.py does (n_good = NVEC, every error counter 0, histogram total, signature = the Verilator
    loop's, the flag-RAM sample = the golden decisions, side B's decode path constant DEC_LAT + 1), with the sim
    signatures taken from evidence/stage6/verilator (tb_s6_loop logs of the same cutoff and shot count).
    Loop latency: start = clk edge at which side A's TX word is accepted by link end A (tvalid & tready); stop = clk
    edge at which the response is registered by side A from link end A's RX; instrument = side A's cycle counter,
    1-cycle histogram; clk = the one loop clock (TX user clock), period from FREQ_A against the 100 MHz init clock.
  * `ECHO probe <name>` ... `ECHO probe_end <name>`: the one-way probe (s6_probe). pb_* = A -> B (stamped at end A's
    TX accept edge, read at end B's RX register edge, same counter), pa_* = B -> A (or A -> A in near-end PMA
    loopback). 32-bin histogram from the section's hbase.

  python3 sw/analysis/s6_analyze.py [--lc 8] [--d 3] evidence/stage6/silicon/<run>.log [...] --json out.json
"""

import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def sim_signatures(lc, d, nvec):
    sig = {'echo': None, 'decode': None}
    pat = f's6_loop_lc{lc}_n{nvec}_*.log' if d == 3 else f's6d5_loop_lc{lc}_n{nvec}_*.log'
    for f in sorted((ROOT / 'evidence/stage6/verilator').glob(pat)):
        t = f.read_text()
        for mode, case in (('echo', 'echo_gap7'), ('decode', 'dec_gap7')):
            m = re.search(rf'RESULT case={case} [^\n]* sig_exp=([0-9a-f]{{8}})', t)
            if m:
                if sig[mode] not in (None, m.group(1)):
                    raise SystemExit(f'sim logs disagree on the {mode} signature')
                sig[mode] = m.group(1)
    return sig


def parse(log):
    secs, cur, board = [], None, {}
    for line in Path(log).read_text().splitlines():
        f = line.split()
        if not f:
            continue
        if f[0] == 'ECHO' and len(f) > 2 and f[1] in ('run', 'probe'):
            cur = {'kind': f[1], 'name': f[2], 'args': dict(x.split('=') for x in f[3:] if '=' in x), 'reg': {},
                   'hist': {}, 'flips': {}}
            secs.append(cur)
        elif f[0] == 'ECHO' and len(f) > 1 and f[1] == 'board':
            cur = None
        elif f[0] == 'ECHO':
            cur = {'kind': 'misc', 'name': f[1], 'reg': {}, 'hist': {}, 'flips': {}}
            secs.append(cur)
        elif f[0] == 'R' and len(f) >= 4:
            (cur['reg'] if cur else board)[f[3]] = int(f[2], 16)
        elif f[0] == 'HIST' and cur:
            cur['hist'][int(f[1])] = int(f[2])
        elif f[0] == 'FLIP' and cur:
            cur['flips'][int(f[1])] = (int(f[2]), int(f[3]))
    return board, secs


def pct(hist, base, q):
    tot = sum(hist.values())
    acc = 0
    for b in sorted(hist):
        acc += hist[b]
        if acc >= q * tot:
            return base + b
    return None


def run_row(log, r, board, dec, sim, t_ns):
    g = r['reg']
    nvec, dlat = board['NVEC'], board['DEC_LAT']
    base = g.get('HIST_BASE', 0)
    hist = {b: c for b, c in r['hist'].items() if c}
    mean = ((g['lat_sum_hi'] << 32) | g['lat_sum_lo']) / g['n_good'] if g['n_good'] else None
    mode = 'echo' if r['name'].startswith('echo') else 'decode'
    errs = {k: g[k] for k in ('mism', 'err_tag', 'err_range', 'err_overrun', 'err_dup', 'err_echo', 'hist_under',
                              'hist_over', 'b_err_tag', 'b_fifo_ovf', 'b_collide')}
    flip_bad = [s for s, (seen, fl) in r['flips'].items() if not seen or (mode == 'decode' and fl != dec[s])
                or (mode == 'echo' and fl != 0)]
    bdec = (g['b_dec'] >> 16, g['b_dec'] & 0xFFFF)
    checks = {
        'all_good': g['n_good'] == nvec and g['n_sent'] == nvec,
        'errors_zero': all(v == 0 for v in errs.values()),
        'hist_total': sum(hist.values()) == g['n_good'],
        'signature_eq_sim': f"{g['sig']:08x}" == sim[mode],
        'flip_sample_eq_golden': not flip_bad,
        'b_decode_path_const': mode == 'echo' or bdec == (dlat + 1, dlat + 1),
    }
    cyc = {'min': g['lat_min'], 'p50': pct(hist, base, 0.5), 'p90': pct(hist, base, 0.9), 'p99': pct(hist, base, 0.99),
           'max': g['lat_max'], 'mean': mean}
    return {'log': str(log), 'kind': 'run', 'run': r['name'], 'mode': mode, 'gap': g['GAP'], 'nvec': nvec,
            'n_good': g['n_good'], 'errors': errs, 'signature': f"{g['sig']:08x}", 'sim_signature': sim[mode],
            'flips_checked': len(r['flips']), 'flip_mismatches': len(flip_bad), 'clk_period_ns': t_ns,
            'loop_cycles': cyc, 'loop_ns': {k: (None if v is None else v * t_ns) for k, v in cyc.items()},
            'b_decode_path_cycles': bdec, 'link': g.get('LINK'), 'hist': hist, 'checks': checks,
            'pass': all(checks.values())}


def probe_row(log, r, t_ns):
    g, base = r['reg'], int(r['args'].get('hbase', 0))
    out = {'log': str(log), 'kind': 'probe', 'probe': r['name'], 'period': int(r['args'].get('period', -1)),
           'hbase': base, 'clk_period_ns': t_ns, 'dirs': {}}
    loop = r['name'].startswith(('pmaloop', 'pcsloop'))
    for p, name in (('pb', 'a_to_b'), ('pa', ('a_to_a_' + r['name'][:3] + '_loopback') if loop else 'b_to_a')):
        if loop and p == 'pb':
            continue
        hist = {k: g[f'{p}_hist{k}'] for k in range(32) if g.get(f'{p}_hist{k}', 0)}
        n = g[f'{p}_n_rx']
        sent = g['pa_n_tx' if (p == 'pb' or loop) else 'pb_n_tx']
        mean = ((g[f'{p}_lat_sum_hi'] << 32) | g[f'{p}_lat_sum_lo']) / n if n else None
        full = sum(hist.values()) == n and n > 0
        cyc = {'min': g[f'{p}_lat_min'] if n else None, 'p50': pct(hist, base, 0.5) if full else None,
               'p90': pct(hist, base, 0.9) if full else None, 'max': g[f'{p}_lat_max'] if n else None, 'mean': mean}
        out['dirs'][name] = {
            'sent': sent, 'received': n, 'bad': g[f'{p}_n_bad'], 'hist_complete': full, 'hist': hist,
            'cycles': cyc, 'ns': {k: (None if v is None else v * t_ns) for k, v in cyc.items()},
            'pass': n > 0 and n == sent and g[f'{p}_n_bad'] == 0}
    out['link_errors'] = {k: g.get(k) for k in ('a_n_unlock', 'a_n_sh_bad', 'a_n_idle_bad', 'b_n_unlock', 'b_n_sh_bad',
                                                 'b_n_idle_bad', 'a_n_bufrst', 'b_n_bufrst', 'a_bufstat', 'b_bufstat')}
    out['pass'] = all(d['pass'] for d in out['dirs'].values())
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('logs', nargs='+')
    ap.add_argument('--json')
    ap.add_argument('--lc', default='8')
    ap.add_argument('--d', type=int, choices=(3, 5), default=3)
    ap.add_argument('--dec', type=Path)
    a = ap.parse_args()
    dec = [int(x, 16) for x in (a.dec or ROOT / f'ref/golden/qec_d{a.d}_golden_dec.hex').read_text().split()]
    rows = []
    for log in a.logs:
        board, secs = parse(log)
        t_ns = 2 ** 24 * 10.0 / board['FREQ_A']
        sim = sim_signatures(a.lc, a.d, board['NVEC'])
        for r in secs:
            if r['kind'] == 'run':
                row = run_row(log, r, board, dec, sim, t_ns)
                c, n = row['loop_cycles'], row['loop_ns']
                print(f"{Path(log).name:30s} {r['name']:13s} good={row['n_good']} errs={sum(row['errors'].values())} "
                      f"sig={row['signature']} cyc min/p50/p90/max {c['min']}/{c['p50']}/{c['p90']}/{c['max']} mean {c['mean']:.3f}"
                      f" ns p50 {n['p50']:.1f} flips {row['flips_checked']}/{row['flip_mismatches']} bad "
                      f"{'PASS' if row['pass'] else 'FAIL ' + str([k for k, v in row['checks'].items() if not v])}")
            elif r['kind'] == 'probe':
                row = probe_row(log, r, t_ns)
                for name, dd in row['dirs'].items():
                    c = dd['cycles']
                    print(f"{Path(log).name:30s} probe {r['name']:18s} {name:20s} sent={dd['sent']} rx={dd['received']} bad={dd['bad']}"
                          f" cyc min/p50/p90/max {c['min']}/{c['p50']}/{c['p90']}/{c['max']} mean {c['mean'] if c['mean'] is None else round(c['mean'], 3)}"
                          f" {'PASS' if dd['pass'] else 'FAIL'}")
            else:
                continue
            rows.append(row)
    if a.json:
        Path(a.json).write_text(json.dumps(rows, indent=1) + '\n')


if __name__ == '__main__':
    main()
