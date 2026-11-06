"""Stage 4 silicon summary: every evidence/stage4/silicon/s4_lc3bc_*_cable_run*.json (s3_analyze.py --d 5 output)
-> evidence/stage4/silicon/summary.json and the markdown table in evidence/stage4/README.md section 3.
Set 0 = the golden set (s4_lc3bc_d_cable_run<r>), set k = tb/s4_vector_sets.py (s4_lc3bc_set<k>_d_cable_run<r>).
  python3 sw/analysis/s4_summary.py"""
import json, re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
S = ROOT / 'evidence/stage4/silicon'
rows = []
for f in sorted(S.glob('s4_lc3bc_*d_cable_run*.json')):
    m = re.search(r's4_lc3bc_(?:(set\d)_)?d_cable_run(\d)', f.name)
    vs, run = m.group(1) or 'set0', int(m.group(2))
    for x in json.loads(f.read_text()):
        rows.append({'set': int(vs[-1]), 'run': run, 'mode': x['run'], 'pass': x['pass'], 'n_good': x['n_good'],
                     'sig': x['signature'], 'sim_sig': x['sim_signature'], 'cyc': x['loop_cycles'], 'ns': x['loop_ns'],
                     'b_dec': x['b_decode_path_cycles'], 'flips': x['flips_checked'], 'flip_bad': x['flip_mismatches'],
                     'clk_ns': x['clk_a_period_ns'], 'b_ppm': x['b_ppm_vs_a'], 'json': f.name})
for r in rows:
    if r['mode'].startswith('decode'):
        e = next(q for q in rows if (q['set'], q['run'], q['mode']) == (r['set'], r['run'], 'echo_gap63'))
        r['dec_minus_echo_mean'] = r['cyc']['mean'] - e['cyc']['mean']
summ = {'n_runs': len(rows), 'n_pass': sum(r['pass'] for r in rows), 'shots_per_run': 131072,
        'n_sets': len({r['set'] for r in rows}), 'max_cycles': max(r['cyc']['max'] for r in rows),
        'max_ns': max(r['ns']['max'] for r in rows), 'rows': rows}
(S / 'summary.json').write_text(json.dumps(summ, indent=1) + '\n')
f = lambda r: f"{r['cyc']['p50']} cyc = {r['ns']['p50']:.1f} ns ({r['cyc']['min']} … {r['cyc']['max']})"
print('| Set | Run | Echo loop, GAP 63 | Decode loop, GAP 63 | Decode loop, GAP 7 | Decode − echo (means) | Decode signature = sim |')
print('|---|---|---|---|---|---|---|')
for vs, run in sorted({(r['set'], r['run']) for r in rows}):
    g = {r['mode']: r for r in rows if (r['set'], r['run']) == (vs, run)}
    d = g['decode_gap63']
    print(f"| {vs} | {run} | {f(g['echo_gap63'])} | {f(d)} | {f(g['decode_gap7'])} | {d['dec_minus_echo_mean']:.2f} | `{d['sig']}` |")
print(f"\n{summ['n_pass']} of {summ['n_runs']} PASS over {summ['n_sets']} sets; worst shot {summ['max_cycles']} cycles = {summ['max_ns']:.1f} ns;"
      f" side B decode path {sorted({tuple(r['b_dec']) for r in rows if r['mode'].startswith('decode')})};"
      f" B vs A {min(r['b_ppm'] for r in rows):+.2f} … {max(r['b_ppm'] for r in rows):+.2f} ppm")
