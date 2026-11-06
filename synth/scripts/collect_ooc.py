"""Collect OOC sweep results into evidence/<stage>/ooc/ and a markdown table.

For every synth/out_<name>/summary.json: copies summary + route timing and
utilisation reports into evidence/stage0/ooc/<name>/, refusing any report
older than its post_route checkpoint (stale-report guard). Cycles come from
the Verilator impulse measurement (evidence/stage0/verilator/*_seed0_run1.log),
not from metadata, so the table carries the simulated count.

  python3 synth/scripts/collect_ooc.py [prefix ...]                 Stage 0 (jsc)
  STAGE=stage2 python3 synth/scripts/collect_ooc.py q2_ q3_        Stage 2 (qec_d3_top): cycles are
      the decision (flip register) count from the Verilator LATENCY line, one more than the logit
  STAGE=stage5 python3 synth/scripts/collect_ooc.py x5_            Stage 5 (x310_stream top): cycles are the
      stream Verilator LATENCY (last window sample at the ports -> decision), x310_stream_lc<c>_seed0_run1.log
"""

import json
import re
import shutil
import sys
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EV = ROOT / 'evidence' / os.environ.get('STAGE', 'stage0')


def sim_cycles(design: str, lc: str, gen_dir: str = '') -> int | None:
    if design == 'x310_clf':
        # Stage 5: the over-budget rule-1 core (.scratch/x310/rule1/gen) has its own Verilator logs
        vdir = 'verilator_rule1' if '/x310/rule1/' in gen_dir else 'verilator'
        log = EV / f'{vdir}/x310_stream_lc{lc}_seed0_run1.log'
        if not log.exists():
            return None
        t = log.read_text()
        m = re.search(r'LATENCY cycles=(\d+)', t)
        return int(m.group(1)) if m and re.search(r'RESULT .* mismatches=0 class_mismatches=0 ', t) else None
    log = EV / f'verilator/{design}_lc{lc}_seed0_run1.log'
    if not log.exists():
        return None
    t = log.read_text()
    if design == 'qec_d3':
        m = re.search(r'LATENCY cycles=\d+ logit, (\d+) flip', t)
        return int(m.group(1)) if m and re.search(r'RESULT .* mismatches=0 flip_checked=\d+ flip_mismatches=0', t) else None
    m = re.search(r'RESULT .* mismatches=0 latency=(\d+)', t)
    return int(m.group(1)) if m else None


def main():
    prefixes = sys.argv[1:] or ['']
    rows = []
    for d in sorted((ROOT / 'synth').glob('out_*')):
        name = d.name[4:]
        if not any(name.startswith(p) for p in prefixes):
            continue
        sj = d / 'summary.json'
        if not sj.exists():
            rows.append(dict(name=name, status='no summary'))
            continue
        s = json.loads(sj.read_text())
        dcp = d / 'post_route.dcp'
        for rpt in ('timing_route.rpt', 'util_route.rpt'):
            if (d / rpt).stat().st_mtime < dcp.stat().st_mtime - 1:
                raise SystemExit(f'STALE report {d / rpt}')
        dst = EV / 'ooc' / name
        dst.mkdir(parents=True, exist_ok=True)
        for f in ('summary.json', 'timing_route.rpt', 'util_route.rpt', 'util_synth.rpt', 'clock.xdc'):
            shutil.copy2(d / f, dst / f)
        design, lc = re.search(r'(jsc|qec_d3|x310_clf)_lc([\d.]+)$', s['gen_dir']).groups()
        cyc = sim_cycles(design, lc, s['gen_dir'])
        per = float(s['period_ns'])
        wns = float(s['wns_ns'])
        rows.append(dict(
            name=name, part=s['part'], lc=lc, retime=bool(s.get('retime', 0)), period=per, mhz=1000 / per, wns=wns, whs=float(s['whs_ns']),
            met=wns >= 0 and float(s['whs_ns']) >= 0, fmax=1000 / (per - wns), lut=s['lut'], ff=s['ff'], dsp=s['dsp'],
            cycles=cyc, ns=None if cyc is None else cyc * per, date=s['date'],
        ))
    (EV / 'ooc_results.json').write_text(json.dumps(rows, indent=1))
    hdr = '| build | part | cutoff | retime | target MHz | cycles (sim) | latency ns | WNS ns | WHS ns | met | Fmax MHz | LUT | FF | DSP |'
    print(hdr)
    print('|' + '---|' * 14)
    for r in rows:
        if 'part' not in r:
            print(f"| {r['name']} | {r['status']} |")
            continue
        ns = '—' if r['ns'] is None else f"{r['ns']:.1f}"
        print(f"| {r['name']} | {r['part']} | {r['lc']} | {'yes' if r['retime'] else 'no'} | {r['mhz']:.0f} | {r['cycles']} | {ns} | {r['wns']:.3f} | {r['whs']:.3f} | "
              f"{'yes' if r['met'] else 'NO'} | {r['fmax']:.0f} | {r['lut']} | {r['ff']} | {r['dsp']} |")


if __name__ == '__main__':
    main()
