"""Pick the Stage 5 classifier: one HGQ2 checkpoint per W, then W (rule D-S5-SEL in docs/PLAN.md).

Validation split only for the choice:
  per W: float baseline = best val accuracy over that W's float runs (float_w<W>_*/best.keras, re-scored);
         eligible = HGQ Pareto checkpoints (hgq_w<W>_*/pareto/*.keras, re-scored) with val accuracy
         >= float - --margin points; pick = the lowest-EBOPs eligible checkpoint whose val accuracy on the
         SNR >= 10 dB windows is >= --hi (if any), else the lowest-EBOPs eligible one (flagged).
  W:     the smallest W whose pick meets both criteria (else the W whose pick has the best SNR >= 10 dB val
         accuracy, flagged).
Then, once: test accuracy (overall, SNR >= 10 dB, per SNR bin, per class, confusion) for the chosen
checkpoint and its W's float baseline. Accuracy vs SNR on VALIDATION for every W's float baseline and pick.
Every candidate's validation score is cached in ref/x310/x310_candidates.json (validation numbers only).

  python ref/x310/select_x310.py            # -> ref/x310/x310_selection.json, ref/runs/x310/chosen.keras
  python ref/x310/select_x310.py --no-test  # interim look while sweeps run (validation only)
  python ref/x310/select_x310.py --max-cost 22000   # D-S5-SEL amended (resource bound; needs ref/x310/x310_cost.json)
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
sys.path.insert(0, str(ROOT / 'ref/x310'))
import x310_data as xd  # noqa: E402

PAT = re.compile(r'e(\d+)_acc([\d.]+)_hi([\d.]+)_ebops(\d+)\.keras')
BINS = np.arange(-5.0, 25.01, 2.5)
SNR_HI = 10.0


def run_info(run_dir: Path):
    m = re.search(r'_w(\d+)', run_dir.name)
    return int(m[1]), (0 if '_bfp0' in run_dir.name else 1)


def scores(model, x, d):
    """Accuracy overall, at SNR >= 10 dB, per SNR bin, per class, and the confusion matrix."""
    pred = np.argmax(np.asarray(model.predict(x, batch_size=16384, verbose=0)), 1)
    y, snr = d['y'], d['snr_db']
    ok = pred == y
    b = np.clip(np.digitize(snr, BINS) - 1, 0, len(BINS) - 2)
    conf = np.zeros((4, 4), np.int64)
    np.add.at(conf, (y, pred), 1)
    return {'acc': float(ok.mean()), 'acc_hi': float(ok[snr >= SNR_HI].mean()),
            'acc_by_snr': [float(ok[b == i].mean()) for i in range(len(BINS) - 1)],
            'acc_by_class': [float(ok[y == c].mean()) for c in range(4)],
            'acc_by_class_hi': [float(ok[(y == c) & (snr >= SNR_HI)].mean()) for c in range(4)],
            'confusion_true_by_pred': conf.tolist()}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--runs', type=Path, default=ROOT / f'ref/runs/x310{xd.TAG}')
    ap.add_argument('--margin', type=float, default=1.0, help='points below the float baseline')
    ap.add_argument('--hi', type=float, default=0.95, help='val accuracy required at SNR >= 10 dB')
    ap.add_argument('--max-cost', type=float, default=0,
                    help='D-S5-SEL amended: resource bound on the da4ml LUT estimate (ref/x310/x310_cost.json); the pick is the '
                         'best val accuracy among the chosen W\'s checkpoints with val acc at SNR >= 10 dB >= --hi and cost <= this')
    ap.add_argument('--no-test', action='store_true', help='interim look while sweeps run: validation only, nothing copied or written but the cache')
    a = ap.parse_args()

    cache_f = ROOT / f'ref/x310/x310{xd.TAG}_candidates.json'
    cache = {c['file']: c for c in json.loads(cache_f.read_text())} if cache_f.exists() else {}
    val, inputs = {}, {}

    def x_of(W, bfp):
        if (W, bfp) not in inputs:
            if W not in val:
                val[W] = xd.load(W, 'val')
            inputs[(W, bfp)] = xd.model_input(val[W]['x'], bool(bfp))
        return inputs[(W, bfp)]

    rep = {'rule': (f'per W: lowest-EBOPs HGQ Pareto checkpoint with val acc >= best float - {a.margin} pt and val acc '
                    f'at SNR >= {SNR_HI} dB >= {a.hi} (if any, else lowest-EBOPs within the margin, flagged); '
                    f'W = smallest W whose pick meets both'),
           'snr_bins_db': BINS.tolist(), 'per_w': {}}
    cands = []
    for W in xd.WS:
        floats = {}
        for f in sorted(a.runs.glob(f'float_w{W}_*/best.keras')):
            Wf, bfp = run_info(f.parent)
            assert Wf == W
            s = scores(keras.models.load_model(f), x_of(W, bfp), val[W])
            floats[f.parent.name] = dict(s, bfp=bfp, file=str(f.relative_to(ROOT)))
        if not floats:
            print(f'W={W}: no float runs, skipped')
            continue
        fb = max(floats, key=lambda k: floats[k]['acc'])
        limit = floats[fb]['acc'] - a.margin / 100
        cw = []
        for f in sorted(a.runs.glob(f'hgq_w{W}_*/pareto/*.keras')):
            m = PAT.match(f.name)
            if not m:
                continue
            _, bfp = run_info(f.parent.parent)
            k = str(f.relative_to(ROOT))
            if k in cache and cache[k].get('size') == f.stat().st_size:
                cw.append(cache[k])
                continue
            try:  # a running sweep's ParetoFront deletes checkpoints it no longer keeps
                s = scores(keras.models.load_model(f), x_of(W, bfp), val[W])
            except ValueError:
                if f.exists():
                    raise
                continue
            cw.append({'file': k, 'size': f.stat().st_size, 'w': W, 'bfp': bfp, 'epoch': int(m[1]), 'ebops': int(m[4]), 'val': s})
        cands += cw
        elig = [c for c in cw if c['val']['acc'] >= limit]
        hi_ok = [c for c in elig if c['val']['acc_hi'] >= a.hi]
        pick = min(hi_ok or elig, key=lambda c: (c['ebops'], -c['val']['acc'])) if elig else None
        rep['per_w'][W] = {'float_baseline': fb, 'float_val': floats[fb], 'float_runs': {k: {'acc': v['acc'], 'acc_hi': v['acc_hi'], 'bfp': v['bfp']} for k, v in floats.items()},
                           'limit_val_acc': limit, 'n_candidates': len(cw), 'n_eligible': len(elig), 'n_eligible_hi': len(hi_ok),
                           'pick': pick, 'pick_meets_hi': bool(hi_ok),
                           'eligible_lowest_ebops': [(c['ebops'], c['val']['acc'], c['val']['acc_hi'], c['file'])
                                                     for c in sorted(elig, key=lambda c: c['ebops'])[:8]]}
        print(f"W={W}: float {fb} val acc {floats[fb]['acc']:.4f} hi {floats[fb]['acc_hi']:.4f}; {len(cw)} HGQ checkpoints, "
              f"{len(elig)} within {a.margin} pt, {len(hi_ok)} also >= {a.hi} at SNR >= {SNR_HI}")
        if pick:
            print(f"   pick {pick['file']} EBOPs {pick['ebops']} val acc {pick['val']['acc']:.4f} hi {pick['val']['acc_hi']:.4f}"
                  f"{'' if hi_ok else '  (SNR >= 10 dB criterion NOT met)'}")
    cache_f.write_text(json.dumps(sorted(cands, key=lambda c: c['file']), indent=1) + '\n')

    ok_w = [W for W, r in rep['per_w'].items() if r['pick'] and r['pick_meets_hi']]
    if ok_w:
        W = min(ok_w)
        rep['w_rule'] = f'smallest W whose pick meets both criteria: {W}'
    else:
        have = [W for W, r in rep['per_w'].items() if r['pick']]
        if not have:
            sys.exit('no W has an eligible checkpoint')
        W = max(have, key=lambda w: rep['per_w'][w]['pick']['val']['acc_hi'])
        rep['w_rule'] = f'NO W meets the SNR >= 10 dB criterion; W = {W} has the best pick at SNR >= 10 dB (flagged)'
    ch = rep['per_w'][W]['pick']
    if a.max_cost:
        cost = {r['file']: r for r in json.loads((ROOT / f'ref/x310/x310{xd.TAG}_cost.json').read_text())}
        bycand = {c['file']: c for c in cands}
        inb = [bycand[f] for f, r in cost.items() if f in bycand and bycand[f]['w'] == W and r['size'] == bycand[f]['size']
               and r['da4ml_cost_lut_est'] <= a.max_cost and bycand[f]['val']['acc_hi'] >= a.hi]
        if not inb:
            sys.exit(f'no W = {W} checkpoint with cost <= {a.max_cost} and val acc at SNR >= {SNR_HI} dB >= {a.hi}')
        rep['rule1_pick'] = {'file': ch['file'], 'ebops_train': ch['ebops'], 'val': {k: ch['val'][k] for k in ('acc', 'acc_hi')},
                             'da4ml_cost_lut_est': cost.get(ch['file'], {}).get('da4ml_cost_lut_est'),
                             'record': f'ref/x310/x310{xd.TAG}_selection_rule1_overbudget.json'}
        ch = max(inb, key=lambda c: (c['val']['acc'], -cost[c['file']]['da4ml_cost_lut_est']))
        ch = dict(ch, da4ml_cost_lut_est=cost[ch['file']]['da4ml_cost_lut_est'])
        rep['rule'] += (f' | AMENDED (D-S5-SEL amended): W = {W} checkpoints with val acc at SNR >= {SNR_HI} dB >= {a.hi} and da4ml '
                        f'LUT estimate <= {a.max_cost:g}: the highest overall val accuracy; the 1-point margin is reported, not required')
        rep['w_rule'] += f'; amended pick under the resource bound: {len(inb)} checkpoints inside it'
        rep['n_in_bound'] = len(inb)
        rep['in_bound_best'] = [(cost[c['file']]['da4ml_cost_lut_est'], c['ebops'], c['val']['acc'], c['val']['acc_hi'], c['file'])
                                for c in sorted(inb, key=lambda c: -c['val']['acc'])[:10]]
        print(f"amended pick {ch['file']}: cost {ch['da4ml_cost_lut_est']:.0f} LUT, EBOPs {ch['ebops']}, val acc {ch['val']['acc']:.4f} hi {ch['val']['acc_hi']:.4f}")
    if a.no_test:
        print(rep['w_rule'], '(interim, --no-test: no test numbers, nothing copied)')
        return
    dst = a.runs / 'chosen.keras'
    shutil.copy(ROOT / ch['file'], dst)
    te = xd.load(W, 'test')
    test_ch = scores(keras.models.load_model(dst), xd.model_input(te['x'], bool(ch['bfp'])), te)
    fbr = rep['per_w'][W]
    test_fb = scores(keras.models.load_model(ROOT / fbr['float_val']['file']), xd.model_input(te['x'], bool(fbr['float_val']['bfp'])), te)
    rep['chosen'] = {'w': W, 'bfp': ch['bfp'], 'file': ch['file'], 'ebops_train': ch['ebops'], 'val': ch['val'],
                     'da4ml_cost_lut_est': ch.get('da4ml_cost_lut_est'),
                     'test_before_calibration': test_ch, 'copied_to': str(dst.relative_to(ROOT))}
    rep['chosen_float_baseline'] = {'run': fbr['float_baseline'], 'val': fbr['float_val'], 'test': test_fb}
    (ROOT / f'ref/x310/x310{xd.TAG}_selection.json').write_text(json.dumps(rep, indent=1) + '\n')
    print(rep['w_rule'])
    print(f"chosen W={W} {ch['file']} EBOPs {ch['ebops']}: test acc {test_ch['acc']:.4f} hi {test_ch['acc_hi']:.4f} | "
          f"float {fbr['float_baseline']} test acc {test_fb['acc']:.4f} hi {test_fb['acc_hi']:.4f}")


if __name__ == '__main__':
    main()
