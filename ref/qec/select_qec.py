"""Pick the d = 3 (or, with --d 5, the d = 5) HGQ2 checkpoint to freeze (rules in docs/PLAN.md §B.1, §B.4).
Validation tables only.

Every Pareto checkpoint of every HGQ run is re-scored on the validation tables (NN / PyMatching
logical errors per p). Chosen: the lowest-EBOPs checkpoint whose geometric-mean ratio is within
--margin of the best float64 baseline's, and whose worst per-p ratio is <= --max-ratio. Test
numbers are reported once, for the chosen model and the float baseline, after the choice.

  uv run python ref/qec/select_qec.py --margin 0.02 --max-ratio 1.05
  python ref/qec/select_qec.py --d 5 --margin 0.10 --max-ratio 100   # runs *_d5*; outputs qec_d5_*.json, chosen_d5.keras
"""

import argparse
import json
import os
import re
import shutil
import sys
from pathlib import Path

os.environ.setdefault('KERAS_BACKEND', 'jax')
import jax  # noqa: E402

jax.config.update('jax_enable_x64', True)
import keras  # noqa: E402
import hgq  # noqa: E402,F401  (registers QDense for load_model)
import numpy as np  # noqa: E402

keras.config.set_floatx('float64')

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'ref/qec'))
import train_qec  # noqa: E402
from train_qec import errors, load  # noqa: E402

PAT = re.compile(r'e(\d+)_r([\d.]+)_ebops(\d+)\.keras')
PT = ['1e-3', '2e-3', '3e-3', '5e-3', '7e-3', '10e-3']


def score(model, tabs):
    r = {t: (lambda e: e[0] / e[1])(errors(model, tab)) for t, tab in tabs.items()}
    return float(np.exp(np.mean(np.log(list(r.values()))))), r


def test_tabs():
    if train_qec.D == 5:
        return load('test', PT)
    z = np.load(ROOT / 'ref/golden/qec_d3_test.npz')
    return {t: {f: z[f'{t}_{f}'] for f in ('keys', 'n0', 'n1', 'pm')} for t in PT}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--runs', type=Path, default=ROOT / 'ref/runs/qec')
    ap.add_argument('--margin', type=float, default=0.02)
    ap.add_argument('--max-ratio', type=float, default=1.05)
    ap.add_argument('--d', type=int, choices=(3, 5), default=3)
    ap.add_argument('--max-ebops', type=int, default=0,
                    help='D-S4-SEL amended: best val geomean among checkpoints with EBOPs <= this (routability bound B); '
                         'replaces the margin rule')
    a = ap.parse_args()
    train_qec.D, train_qec.ND = a.d, {3: 24, 5: 120}[a.d]
    sfx = '' if a.d == 3 else '_d5'
    is_d5 = lambda d: '_d5' in d.name  # float_d5_*, hgq_d5_*, hgq_d5w_* (WRAP warm start), hgq_d5s_* (SAT)
    mine = (lambda d: not is_d5(d)) if a.d == 3 else is_d5
    val = load('val', PT)
    floats = {}
    for d in sorted(x for x in a.runs.glob('float_*/best.keras') if mine(x.parent)):
        floats[d.parent.name] = score(keras.models.load_model(d), val)
    fbest = min(floats, key=lambda k: floats[k][0])
    limit = floats[fbest][0] + a.margin
    print(f'float baseline {fbest}: val geomean NN/PM {floats[fbest][0]:.4f} -> limit {limit:.4f}')
    # Every candidate's validation score is cached in ref/qec/qec_candidates.json (keyed by file and
    # size) so the rule can be re-applied without re-scoring; the cache holds validation numbers only.
    cache_f = ROOT / f'ref/qec/qec{sfx}_candidates.json'
    cache = {c['file']: c for c in json.loads(cache_f.read_text())} if cache_f.exists() else {}
    cands = []
    for f in sorted(x for x in a.runs.glob('hgq_*/pareto/*.keras') if mine(x.parent.parent)):
        m = PAT.match(f.name)
        if not m:
            continue
        k = str(f.relative_to(ROOT))
        if k in cache and cache[k].get('size') == f.stat().st_size:
            cands.append(cache[k])
            continue
        try:  # a running sweep's ParetoFront deletes checkpoints it no longer keeps
            g, r = score(keras.models.load_model(f), val)
        except ValueError:
            if f.exists():
                raise
            print(f'  {k}: removed by its run while scoring, skipped')
            continue
        cands.append({'file': k, 'size': f.stat().st_size, 'epoch': int(m[1]), 'ebops': int(m[3]),
                      'val_geomean': g, 'val_max': max(r.values()), 'val_ratio': r})
    cache_f.write_text(json.dumps(cands, indent=1) + '\n')
    if a.max_ebops:
        ok = [c for c in cands if c['ebops'] <= a.max_ebops and c['val_max'] <= a.max_ratio]
        print(f'routability bound: EBOPs <= {a.max_ebops}, best val geomean wins')
    else:
        ok = [c for c in cands if c['val_geomean'] <= limit and c['val_max'] <= a.max_ratio]
    print(f'{len(cands)} Pareto checkpoints, {len(ok)} pass')
    for c in sorted(ok, key=lambda c: c['ebops'])[:10]:
        print(f"  {c['ebops']:7d} geomean {c['val_geomean']:.4f} max {c['val_max']:.4f}  {c['file']}")
    if not ok:
        sys.exit('no checkpoint passes the rule')
    ch = (min(ok, key=lambda c: (c['val_geomean'], c['ebops'])) if a.max_ebops
          else min(ok, key=lambda c: (c['ebops'], c['val_geomean'])))
    dst = ROOT / f'ref/runs/qec/chosen{sfx}.keras'
    shutil.copy(ROOT / ch['file'], dst)
    tt = test_tabs()
    ch['test_geomean'], ch['test_ratio'] = score(keras.models.load_model(dst), tt)
    fb = {'run': fbest, 'val_geomean': floats[fbest][0], 'val_ratio': floats[fbest][1]}
    fb['test_geomean'], fb['test_ratio'] = score(keras.models.load_model(a.runs / fbest / 'best.keras'), tt)
    rule = (f'best val geomean NN/PM with EBOPs <= {a.max_ebops} (routability bound) and every val p <= {a.max_ratio}'
            if a.max_ebops else f'lowest EBOPs with val geomean NN/PM <= best float + {a.margin} and every val p <= {a.max_ratio}')
    rep = {'rule': rule,
           'chosen': ch, 'float_baseline': fb, 'float_runs': {k: v[0] for k, v in floats.items()},
           'n_candidates': len(cands), 'n_pass': len(ok)}
    (ROOT / f'ref/qec/qec{sfx}_selection.json').write_text(json.dumps(rep, indent=1) + '\n')
    print(json.dumps({k: rep[k] for k in ('rule', 'chosen', 'float_baseline')}, indent=1))


if __name__ == '__main__':
    main()
