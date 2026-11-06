"""Solve every Stage 1 silicon sweep with its build's model inputs, and tabulate.

For each (build, tag) it reads synth/out_<build>/summary.json (anchor corners d_H / d_G as d_eff
min..max, t_out_C - t_out_B as the mean of its two corners) and runs timed_solve.py's bracket mode
on evidence/stage1/silicon/timed_<tag>_*.log (and timed_<tag>.log), writing <log>_solve.json and
evidence/stage1/silicon/summary.json.

  python3 sw/analysis/solve_stage1.py s1_p300_lc3_f1:p300 s1_p200_lc5_f1:p200 ...
"""

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EV = ROOT / 'evidence/stage1/silicon'


def main():
    rows = []
    for arg in sys.argv[1:]:
        build, tag = arg.split(':')
        sj = json.loads((ROOT / f'synth/out_{build}/summary.json').read_text())
        dh = [sj['d_H']['min']['d_eff_ns'], sj['d_H']['max']['d_eff_ns']]
        dg = [sj['d_G']['min']['d_eff_ns'], sj['d_G']['max']['d_eff_ns']]
        pp = sj['pad_paths']
        dt_c = [pp['tout_c_minus_tout_b_min_ns'], pp['tout_c_minus_tout_b_max_ns']]
        dtout = sum(dt_c) / 2
        logs = sorted(EV.glob(f'timed_{tag}_*.log')) + sorted(EV.glob(f'timed_{tag}.log'))
        for log in logs:
            out = log.with_name(log.stem + '_solve.json')
            subprocess.run([sys.executable, str(ROOT / 'sw/analysis/timed_solve.py'), str(log),
                            '--d-h-range', *map(str, dh), '--d-g-range', *map(str, dg),
                            '--dtout', str(dtout), '--json', str(out)], check=True, stdout=subprocess.DEVNULL)
            r = json.loads(out.read_text())
            b = r['anchor_bracket']
            rows.append({
                'build': build, 'log': log.name, 'f_net_mhz': sj['f_net_mhz'], 'lc': sj['lc'],
                'lat_net': sj['lat_net'], 'arg_lat': sj['arg_lat'], 'n_core': r['n_core'],
                'trials': r['n_trials'], 'trials_one_period': r['L_pp_ns']['n_trials_one_period'],
                'step_ps': r['step_ps'],
                'd_H_plus_d_G_silicon_ns': b['measured_d_H_plus_d_G_ns'], 'corner_fraction': b['corner_fraction'],
                'sum_inside_corners': b['sum_inside_corners'],
                'd_B_ns': b['d_B_ns'], 'd_C_ns': b['d_C_ns'],
                'L_pp_ns': {k: {s: b['L_pp_ns'][k][s] for s in ('min', 'median', 'max', 'mean')} for k in ('lo', 'est', 'hi')},
                'model_inputs': {'d_H_corners_ns': dh, 'd_G_corners_ns': dg, 'dtout_ns': dtout, 'dtout_corners_ns': dt_c},
                'ooc_prediction_ns': sj['lat_net'] * 1000.0 / sj['f_net_mhz'],
                'wns_ns': sj['wns_ns'], 'whs_ns': sj['whs_ns'], 'wpws_ns': sj['wpws_ns'], 'lut': sj['lut'], 'ff': sj['ff']})
            e = rows[-1]['L_pp_ns']['est']
            print(f"{build:22s} {log.name:22s} N_core={r['n_core']:3d} sum={b['measured_d_H_plus_d_G_ns']:.3f} "
                  f"dB={b['d_B_ns']['est']:.3f} dC={b['d_C_ns']['est']:.3f} "
                  f"L_pp min/med/max {e['min']:.3f}/{e['median']:.3f}/{e['max']:.3f} "
                  f"[min {b['L_pp_ns']['lo']['min']:.3f}..{b['L_pp_ns']['hi']['min']:.3f}] launch_from_B={r['launch_from_B_trials']}")
    (EV / 'summary.json').write_text(json.dumps(rows, indent=1) + '\n')


if __name__ == '__main__':
    main()
