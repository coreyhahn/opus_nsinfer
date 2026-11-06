"""Recover pad loop delays and pin-to-pin latency from a phase sweep (docs/MEASUREMENT.md §2a).

Input: TRIAL lines `TRIAL pos=<PS_POS> kh= kb= kc= pg= pd= ...` from the
Verilator testbench (tb/tb_harness.sv) or the galen host tool
(sw/galen/jsc_host.py); each trial is one armed launch at phase step `pos`.

Model (φ = clk_ps edge delay after the clk_net edge, in [0, T)):
  ΔB = K_B − K_H = ceil((φ + d_B)/T) − ceil((φ + d_H)/T)
  ΔC = P_D − P_G = ceil((d_C − φ)/T) − ceil((d_G − φ)/T)
d_B: pin B loop (launch OPFF on clk_ps -> pad -> IPFF on clk_net);
d_C: pin C loop (OPFF on clk_net -> pad -> IPFF on clk_ps);
d_H, d_G: the fabric reference crossings (l_tw -> h_ff, c_tw -> g_ff),
taken from Vivado's routed timing (model) — they anchor φ, so they are the
only model inputs besides t_out_C − t_out_B. Over a sweep, ΔB has an up-step
at the B transition and a down-step at the H transition; ΔC has a down-step
at D and an up-step at G. Per trial,
  L_pp = (K_C − K_H + ceil((φ + d_H)/T))·T − φ + (t_out_C − t_out_B)
is pad B rising to pad C rising; over a uniform sweep of φ it is the
latency distribution seen by an asynchronous source.

  python3 sw/analysis/timed_solve.py LOG [--d-h NS] [--d-g NS] [--dtout NS] [--json OUT]
  python3 sw/analysis/timed_solve.py LOG --d-h-range MIN MAX --d-g-range MIN MAX [--dtout NS]

With the ranges (Vivado fast/slow corner d_eff of each anchor), the sweep's
model-free d_H + d_G (silicon) fixes where between the corners the part sits:
d_H is interpolated at the same fraction as the measured sum, and bounded by
max(d_H_min, sum - d_G_max) .. min(d_H_max, sum - d_G_min). L_pp is reported
at the estimate and at both bounds (`anchor_bracket`).
"""

import argparse
import json
import math
import re
import statistics
import sys
from collections import defaultdict
from pathlib import Path

KV = re.compile(r'(\w+)=(-?[\d.]+)')


def parse(path):
    trials, meta = [], {}
    for line in Path(path).read_text().splitlines():
        if line.startswith('TRIAL '):
            d = {k: float(v) for k, v in KV.findall(line)}
            trials.append(d)
        elif line.startswith('RESULT timed') or line.startswith('# SWEEP'):
            meta.update({k: float(v) for k, v in KV.findall(line)})
    return trials, meta


def transitions(levels, S):
    """levels: [(q, fraction_high)] sorted by q in [0, S), one period, circular.

    Returns [(q_cross mod S, +1 up | -1 down)] where the fraction crosses 0.5,
    interpolated linearly between neighbouring positions.
    """
    out = []
    n = len(levels)
    for i in range(n):
        (q0, f0), (q1, f1) = levels[i], levels[(i + 1) % n]
        if i == n - 1:
            q1 += S
        if (f0 < 0.5) != (f1 < 0.5):
            q = q0 + (0.5 - f0) / (f1 - f0) * (q1 - q0)
            out.append((q % S, +1 if f1 > f0 else -1))
    return out


def two_levels(vals, name):
    lv = sorted(set(vals))
    if len(lv) > 2 or (len(lv) == 2 and lv[1] - lv[0] != 1):
        raise SystemExit(f'{name}: expected two adjacent levels, got {lv}')
    return lv


def solve(trials, T, S, d_h, d_g, dtout, n_core_exp=None):
    step = T / S
    by_q = defaultdict(list)
    for t in trials:
        by_q[int(t['pos']) % S].append(t)
    qs = sorted(by_q)
    if len(qs) < 8:
        raise SystemExit('need a sweep over at least 8 phase positions')
    n_core = sorted({int(t['kc'] - t['kb']) for t in trials})
    if len(n_core) != 1 or (n_core_exp is not None and n_core[0] != n_core_exp):
        raise SystemExit(f'N_core not constant / not as expected: {n_core} vs {n_core_exp}')

    res = {'T_ns': T, 'steps_per_period': S, 'step_ps': step * 1e3, 'n_core': n_core[0],
           'n_trials': len(trials), 'n_positions': len(qs), 'model_inputs': {'d_H_ns': d_h, 'd_G_ns': d_g, 'dtout_ns': dtout}}

    # ---- pin B loop, anchored on the H crossing ----
    dB = {q: [t['kb'] - t['kh'] for t in by_q[q]] for q in qs}
    lvB = two_levels([v for vs in dB.values() for v in vs], 'K_B-K_H')
    if len(lvB) != 2:
        raise SystemExit('K_B-K_H never changes: sweep does not cover a period')
    trB = transitions([(q, sum(v == lvB[1] for v in dB[q]) / len(dB[q])) for q in qs], S)
    ups, downs = [q for q, s in trB if s > 0], [q for q, s in trB if s < 0]
    if len(ups) != 1 or len(downs) != 1:
        raise SystemExit(f'K_B-K_H: expected one up and one down transition per period, got {trB}')
    qB, qH = ups[0], downs[0]
    phi_h = lambda q: (T - d_h + (q - qH) * step) % T  # noqa: E731
    phiB = phi_h(qB)
    cH = math.ceil((phiB + d_h) / T - 1e-12)
    k = lvB[1] + cH - 1
    d_B = k * T - phiB
    res['pin_B'] = {'q_B_step': qB, 'q_H_step': qH, 'levels': lvB, 'd_B_ns': d_B,
                    'd_B_minus_d_H_ns': d_B - d_h}

    # ---- pin C loop, anchored on the G crossing ----
    dC = {q: [t['pd'] - t['pg'] for t in by_q[q]] for q in qs}
    lvC = two_levels([v for vs in dC.values() for v in vs], 'P_D-P_G')
    if len(lvC) == 2:
        trC = transitions([(q, sum(v == lvC[1] for v in dC[q]) / len(dC[q])) for q in qs], S)
        ups, downs = [q for q, s in trC if s > 0], [q for q, s in trC if s < 0]
        if len(ups) != 1 or len(downs) != 1:
            raise SystemExit(f'P_D-P_G: expected one up and one down transition per period, got {trC}')
        qG, qD = ups[0], downs[0]
        phi_g = lambda q: (d_g + (q - qG) * step) % T  # noqa: E731
        phiD = phi_g(qD)
        g = 1 if phiD < d_g else 0
        j = lvC[0] + g
        d_C = phiD + j * T
        # anchor consistency: both anchors predict the same φ for every q only if d_H + d_G is right
        anchor_err = ((phi_h(qs[0]) - phi_g(qs[0]) + T / 2) % T) - T / 2
        res['pin_C'] = {'q_D_step': qD, 'q_G_step': qG, 'levels': lvC, 'd_C_ns': d_C,
                        'd_C_minus_d_G_ns': d_C - d_g,
                        'anchor_disagreement_ns': anchor_err,
                        'measured_d_H_plus_d_G_ns': (d_h + d_g) + anchor_err}
    else:
        res['pin_C'] = {'error': 'P_D-P_G never changes'}

    # ---- per-trial pad-to-pad latency ----
    # launch edge count = K_H - ceil((φ+d_H)/T), or K_B - ceil((φ+d_B)/T): whichever crossing is
    # farther from its own transition (at its transition a crossing resolves on either edge, so
    # its count is ambiguous by one cycle while the other one is deterministic)
    def edge_dist(x):
        f = (x / T) % 1.0
        return min(f, 1.0 - f) * T
    n_from_b = 0
    for t in trials:
        phi = phi_h(int(t['pos']) % S)
        if edge_dist(phi + d_h) >= edge_dist(phi + d_B):
            launch = t['kh'] - math.ceil((phi + d_h) / T - 1e-12)
        else:
            launch = t['kb'] - math.ceil((phi + d_B) / T - 1e-12)
            n_from_b += 1
        t['L_pp_ns'] = (t['kc'] - launch) * T - phi + dtout
    res['launch_from_B_trials'] = n_from_b
    # distribution over exactly one period of phase positions (a sweep longer than one period
    # would weight its overlap twice); per-trial L_pp is still written for every trial
    p0 = min(int(t['pos']) for t in trials)
    lpp = sorted(t['L_pp_ns'] for t in trials if int(t['pos']) - p0 < S)
    res['L_pp_ns'] = {'min': lpp[0], 'median': statistics.median(lpp), 'max': lpp[-1],
                      'mean': statistics.fmean(lpp), 'n_trials_one_period': len(lpp),
                      'formula_min_NcoreT_plus_dB_plus_dtout': n_core[0] * T + d_B + dtout}
    return res


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('log')
    ap.add_argument('--T-ns', type=float)
    ap.add_argument('--steps', type=int)
    ap.add_argument('--n-core', type=int)
    ap.add_argument('--d-h', type=float, default=0.0, help='l_tw -> h_ff effective delay, ns (model)')
    ap.add_argument('--d-g', type=float, default=0.0, help='c_tw -> g_ff effective delay, ns (model)')
    ap.add_argument('--dtout', type=float, default=0.0, help='t_out_C - t_out_B, ns (model)')
    ap.add_argument('--d-h-range', type=float, nargs=2, metavar=('MIN', 'MAX'), help='d_H model corners, ns')
    ap.add_argument('--d-g-range', type=float, nargs=2, metavar=('MIN', 'MAX'), help='d_G model corners, ns')
    ap.add_argument('--check-sim', action='store_true', help='compare with the testbench ground truth')
    ap.add_argument('--json')
    a = ap.parse_args()
    trials, meta = parse(a.log)
    T = a.T_ns or meta['T_NS']
    S = a.steps or int(meta['PS_STEPS'])
    n_core = a.n_core or (int(meta['n_core']) if 'n_core' in meta else None)
    if a.d_h_range or a.d_g_range:
        if not (a.d_h_range and a.d_g_range):
            raise SystemExit('--d-h-range and --d-g-range go together')
        (hl, hh), (gl, gh) = a.d_h_range, a.d_g_range
        first = solve(trials, T, S, (hl + hh) / 2, (gl + gh) / 2, a.dtout, n_core)
        if 'measured_d_H_plus_d_G_ns' not in first['pin_C']:
            raise SystemExit('pin C loop did not resolve; cannot use the measured anchor sum')
        tot = first['pin_C']['measured_d_H_plus_d_G_ns']
        span = (hh - hl) + (gh - gl)
        f = (tot - hl - gl) / span if span > 0 else 0.5
        lo, hi = max(hl, tot - gh), min(hh, tot - gl)
        inside = lo <= hi
        est = hl + min(max(f, 0.0), 1.0) * (hh - hl)
        if not inside:
            lo = hi = est
        runs = {k: solve(trials, T, S, d, tot - d, a.dtout, n_core) for k, d in (('lo', lo), ('hi', hi), ('est', est))}  # est last: solve() writes per-trial L_pp
        res = runs['est']
        res['anchor_bracket'] = {
            'model_corners_ns': {'d_H': [hl, hh], 'd_G': [gl, gh]},
            'measured_d_H_plus_d_G_ns': tot, 'corner_fraction': f, 'sum_inside_corners': inside,
            'd_H_ns': {'lo': lo, 'est': est, 'hi': hi},
            'L_pp_ns': {k: r['L_pp_ns'] for k, r in runs.items()},
            'd_B_ns': {k: r['pin_B']['d_B_ns'] for k, r in runs.items()},
            'd_C_ns': {k: r['pin_C'].get('d_C_ns') for k, r in runs.items()}}
    else:
        res = solve(trials, T, S, a.d_h, a.d_g, a.dtout, n_core)
    if a.check_sim:
        errs = {'d_B_err_ps': (res['pin_B']['d_B_ns'] - meta['D_B']) * 1e3,
                'd_C_err_ps': (res['pin_C']['d_C_ns'] - meta['D_C']) * 1e3,
                'L_pp_max_abs_err_ps': max(abs(t['L_pp_ns'] - t['lpp_ns']) for t in trials) * 1e3}
        res['sim_check'] = errs
        tol = res['step_ps']
        ok = abs(errs['d_B_err_ps']) <= tol and abs(errs['d_C_err_ps']) <= tol and errs['L_pp_max_abs_err_ps'] <= tol
        res['sim_check']['tolerance_ps'] = tol
        res['sim_check']['pass'] = ok
    out = json.dumps(res, indent=1)
    print(out)
    if a.json:
        Path(a.json).write_text(out + '\n')
    if a.check_sim and not res['sim_check']['pass']:
        sys.exit(1)


if __name__ == '__main__':
    main()
