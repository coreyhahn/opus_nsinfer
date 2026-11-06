"""Stage 6 silicon summary: collect the per-run JSON files of sw/analysis/s6_analyze.py into one table.

  python3 sw/analysis/s6_summary.py evidence/stage6/silicon/s6_lc8_b_cable_run*.json --out evidence/stage6/silicon/summary_lc8_b.json

Per run: the three s3 loop runs (min / p50 / p90 / max / mean cycles and ns, pass) and the probes (one-way per direction).
Derived: link round trip = echo median - 1 (Stage 3's convention, side B's echo register), one way = that / 2.
"""
import argparse
import json
from pathlib import Path


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('jsons', nargs='+')
    ap.add_argument('--out')
    a = ap.parse_args()
    runs = []
    for j in a.jsons:
        rows = json.loads(Path(j).read_text())
        r = {'json': j, 'loop': {}, 'probe': {}, 'pass': all(x['pass'] for x in rows)}
        for x in rows:
            if x['kind'] == 'run':
                r['loop'][x['run']] = {'cycles': x['loop_cycles'], 'ns': x['loop_ns'], 'pass': x['pass'],
                                       'signature': x['signature']}
                r['clk_period_ns'] = x['clk_period_ns']
            else:
                for d, v in x['dirs'].items():
                    r['probe'][f"{x['probe']}:{d}"] = {'cycles': v['cycles'], 'ns': v['ns'], 'pass': v['pass'],
                                                        'received': v['received']}
        e = r['loop'].get('echo_gap63')
        if e:
            t = r['clk_period_ns']
            rt = e['cycles']['p50'] - 1
            r['derived'] = {'link_round_trip_cycles': rt, 'link_round_trip_ns': rt * t,
                            'one_way_cycles': rt / 2, 'one_way_ns': rt / 2 * t}
        runs.append(r)
        lp = r['loop']
        print(f"{Path(j).name:32s} pass={r['pass']} echo p50 {lp['echo_gap63']['cycles']['p50']} "
              f"decode p50 {lp['decode_gap63']['cycles']['p50']} / {lp['decode_gap7']['cycles']['p50']} "
              f"one-way(derived) {r['derived']['one_way_ns']:.1f} ns; probes "
              + ' '.join(f"{k.split(':')[0].replace('cable_', '')}:{k.split(':')[1][:6]}={v['cycles']['p50']}/{v['cycles']['max']}"
                         for k, v in r['probe'].items()))
    if a.out:
        Path(a.out).write_text(json.dumps(runs, indent=1) + '\n')


if __name__ == '__main__':
    main()
