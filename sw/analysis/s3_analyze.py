"""Stage 3 silicon analysis: parse sw/bcu/desk.sh run logs of sw/bcu/s3_measure.cmd.

Per run (echo_gap63, decode_gap63, decode_gap7): counts, errors, signature, the loop latency
histogram (clk_a cycles; 1-cycle bins from HIST_BASE) -> min / median / p99 / max / mean in
cycles and ns, the ns scale being the measured clk_a period (FREQ_A against the 100 MHz init_clk).
Checks: n_good = NVEC, every error counter 0, histogram total = n_good with no under/overflow,
signatures equal the Verilator loop's (evidence/stage3/verilator logs), the sampled flag-RAM
entries equal ref/golden/qec_d3_golden_dec.hex, side B's decode-path count constant = DEC_LAT + 1.

  python3 sw/analysis/s3_analyze.py evidence/stage3/silicon/<run>.log [...] [--json out.json]
  python3 sw/analysis/s3_analyze.py --d 5 --lc 3bc evidence/stage4/silicon/<run>.log [...]   (Stage 4)
  python3 sw/analysis/s3_analyze.py --d 5 --lc 3bc_set1 --dec .scratch/qec_d5_set1_dec.hex <log>  (vector set 1)
"""

import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SIM_SIG = {'echo': None, 'decode': None}


def sim_signatures(lc, d, nvec):
    pat = f's3_loop_lc{lc}_n{nvec}_*.log' if d == 3 else f's3d5_loop_lc{lc}_n{nvec}_*.log'
    for f in sorted((ROOT / f'evidence/stage{3 if d == 3 else 4}/verilator').glob(pat)):
        t = f.read_text()
        for mode, case in (('echo', 'echo_gap7'), ('decode', 'dec_gap7')):
            m = re.search(rf'RESULT case={case} [^\n]* sig_exp=([0-9a-f]{{8}})', t)
            if m:
                SIM_SIG[mode] = m.group(1)


def parse(log):
    runs, cur, board = [], None, {}
    for line in Path(log).read_text().splitlines():
        f = line.split()
        if not f:
            continue
        if f[0] == 'ECHO' and len(f) > 2 and f[1] == 'run':
            cur = {'name': f[2], 'reg': {}, 'hist': {}, 'flips': {}}
            runs.append(cur)
        elif f[0] == 'R' and len(f) >= 4:
            (cur['reg'] if cur else board)[f[3]] = int(f[2], 16)
        elif f[0] == 'HIST':
            cur['hist'][int(f[1])] = int(f[2])
        elif f[0] == 'FLIP':
            cur['flips'][int(f[1])] = (int(f[2]), int(f[3]))
    return board, runs


def pct(hist, base, q):
    tot = sum(hist.values())
    acc = 0
    for b in sorted(hist):
        acc += hist[b]
        if acc >= q * tot:
            return base + b
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('logs', nargs='+')
    ap.add_argument('--json')
    ap.add_argument('--lc', default='8')
    ap.add_argument('--d', type=int, choices=(3, 5), default=3)
    ap.add_argument('--dec', type=Path, help='expected decisions (default ref/golden/qec_d<d>_golden_dec.hex; Stage 4 set k:'
                                             ' .scratch/qec_d5_set<k>_dec.hex, sha256 in ref/golden/qec_d5_sets.json)')
    a = ap.parse_args()
    dec = [int(x, 16) for x in (a.dec or ROOT / f'ref/golden/qec_d{a.d}_golden_dec.hex').read_text().split()]
    out = []
    for log in a.logs:
        board, runs = parse(log)
        nvec, dlat = board['NVEC'], board['DEC_LAT']
        sim_signatures(a.lc, a.d, nvec)
        fa = board['FREQ_A']
        t_ns = 2 ** 24 * 10.0 / fa          # clk_a period from 2^24 init_clk (10 ns) cycles
        for r in runs:
            g = r['reg']
            base = g.get('HIST_BASE', 0)
            hist = {b: c for b, c in r['hist'].items() if c}
            mean = ((g['lat_sum_hi'] << 32) | g['lat_sum_lo']) / g['n_good'] if g['n_good'] else None
            mode = 'echo' if r['name'].startswith('echo') else 'decode'
            errs = {k: g[k] for k in ('mism', 'err_tag', 'err_range', 'err_overrun', 'err_dup', 'err_echo',
                                      'hist_under', 'hist_over', 'b_err_tag', 'b_fifo_ovf', 'b_collide')}
            flip_bad = [s for s, (seen, fl) in r['flips'].items() if not seen or (mode == 'decode' and fl != dec[s])
                        or (mode == 'echo' and fl != 0)]
            bdec = (g['b_dec'] >> 16, g['b_dec'] & 0xFFFF)
            checks = {
                'all_good': g['n_good'] == nvec and g['n_sent'] == nvec,
                'errors_zero': all(v == 0 for v in errs.values()),
                'hist_total': sum(hist.values()) == g['n_good'],
                'signature_eq_sim': f"{g['sig']:08x}" == SIM_SIG[mode],  # no sim log -> fail
                'flip_sample_eq_golden': not flip_bad,
                'b_decode_path_const': mode == 'echo' or bdec == (dlat + 1, dlat + 1),
            }
            row = {
                'log': str(log), 'run': r['name'], 'mode': mode, 'gap': g['GAP'], 'nvec': nvec,
                'n_good': g['n_good'], 'errors': errs, 'signature': f"{g['sig']:08x}", 'sim_signature': SIM_SIG[mode],
                'flips_checked': len(r['flips']), 'flip_mismatches': len(flip_bad),
                'clk_a_period_ns': t_ns, 'freq_a_counts': fa, 'freq_b_counts': board['FREQ_B'],
                'b_ppm_vs_a': (board['FREQ_B'] / fa - 1) * 1e6,
                'loop_cycles': {'min': g['lat_min'], 'p50': pct(hist, base, 0.5), 'p99': pct(hist, base, 0.99),
                                'max': g['lat_max'], 'mean': mean},
                'b_decode_path_cycles': bdec, 'b_echo_path_cycles': (g['b_echo'] >> 16, g['b_echo'] & 0xFFFF),
                'hist': hist, 'checks': checks, 'pass': all(checks.values()),
            }
            row['loop_ns'] = {k: (None if v is None else v * t_ns) for k, v in row['loop_cycles'].items()}
            out.append(row)
            c, n = row['loop_cycles'], row['loop_ns']
            print(f"{Path(log).name:34s} {r['name']:13s} good={g['n_good']} errs={sum(errs.values())} sig={row['signature']}"
                  f" cyc min/p50/p99/max {c['min']}/{c['p50']}/{c['p99']}/{c['max']} mean {c['mean']:.3f}"
                  f" ns min/p50/max {n['min']:.1f}/{n['p50']:.1f}/{n['max']:.1f} flips {len(r['flips'])}/{len(flip_bad)} bad"
                  f" {'PASS' if row['pass'] else 'FAIL ' + str([k for k, v in checks.items() if not v])}")
    if a.json:
        Path(a.json).write_text(json.dumps(out, indent=1) + '\n')


if __name__ == '__main__':
    main()
