"""Pick the HGQ2 checkpoint to freeze (rule in docs/PLAN.md §A.1).

Validation split only: the lowest-EBOPs Pareto checkpoint across all HGQ runs
whose validation accuracy is within --margin points of the float64
baseline's best validation accuracy. Test accuracy is reported for the
chosen model and the float baseline, once, after the choice.
"""

import argparse
import json
import os
import re
import shutil
from pathlib import Path

os.environ.setdefault('KERAS_BACKEND', 'jax')
import jax  # noqa: E402

jax.config.update('jax_enable_x64', True)
import keras  # noqa: E402
import numpy as np  # noqa: E402

keras.config.set_floatx('float64')

HERE = Path(__file__).parent
PAT = re.compile(r'e(\d+)_acc([\d.]+)_ebops(\d+)\.keras')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--runs', type=Path, default=HERE / 'runs')
    ap.add_argument('--margin', type=float, default=0.4)
    a = ap.parse_args()

    d = np.load(HERE / 'data/jsc_split.npz')
    flog = json.loads((a.runs / 'float/train_log.json').read_text())
    float_val = max(flog['history']['val_accuracy'])
    fmodel = keras.models.load_model(a.runs / 'float/best.keras')
    float_test = float(np.mean(np.argmax(fmodel.predict(d['x_test'], batch_size=16384, verbose=0), 1) == d['y_test']))

    cands = []
    for p in sorted(a.runs.glob('hgq_*/pareto/*.keras')):
        m = PAT.match(p.name)
        if m:
            cands.append((int(m.group(3)), float(m.group(2)), p))
    thresh = float_val - a.margin / 100
    ok = sorted(c for c in cands if c[1] >= thresh)
    assert ok, f'no checkpoint within {a.margin} points of float val {float_val:.5f}'
    ebops, val, path = ok[0]
    shutil.copy(path, a.runs / 'chosen.keras')
    res = {
        'float_best_val_accuracy': float_val,
        'float_test_accuracy': float_test,
        'margin_points': a.margin,
        'threshold_val_accuracy': thresh,
        'n_candidates': len(cands),
        'chosen': str(path.relative_to(HERE)),
        'chosen_val_accuracy': val,
        'chosen_train_ebops': ebops,
        'pareto_within_margin': [(e, v, str(p.relative_to(HERE))) for e, v, p in ok[:10]],
    }
    (HERE / 'jsc_selection.json').write_text(json.dumps(res, indent=1))
    print(json.dumps(res, indent=1))


if __name__ == '__main__':
    main()
