"""da4ml LUT-cost estimate of Stage 5 candidate checkpoints (for the resource bound of D-S5-SEL, amended).

EBOPs are a poor LUT proxy for these nets (the rule-1 pick: 61k EBOPs, da4ml estimate 50.8k LUT, mostly
1-2-bit weights at 37 % density). For each candidate it does what the export does, without writing
anything: trace_minmax over the training split (calibration), then the da4ml trace from 16-bit inputs, and
records sol.cost (da4ml's LUT estimate of the core), the comb latency and the calibrated EBOPs.
Candidates: W's checkpoints from ref/x310/x310_candidates.json with val accuracy at SNR >= 10 dB >= --hi and
EBOPs < --max-ebops. Validation-derived selection inputs only; no test data is read.

  python ref/x310/cost_x310.py --w 64 --max-ebops 61468 --shard 0 --nshard 8   # -> ref/runs/x310/cost/w64_0of8.json
  python ref/x310/cost_x310.py --w 64 --merge --nshard 8                         # -> ref/x310/x310_cost.json
"""

import argparse
import json
import os
import sys
import time
from pathlib import Path

os.environ.setdefault('KERAS_BACKEND', 'jax')
import jax  # noqa: E402

jax.config.update('jax_enable_x64', True)
import keras  # noqa: E402
import hgq  # noqa: E402,F401
import numpy as np  # noqa: E402

keras.config.set_floatx('float64')

from da4ml.converter import trace_model  # noqa: E402
from da4ml.trace import comb_trace  # noqa: E402
from hgq.utils import trace_minmax  # noqa: E402

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'ref/x310'))
import x310_data as xd  # noqa: E402

OUT = ROOT / f'ref/runs/x310{xd.TAG}/cost'


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--w', type=int, default=64)
    ap.add_argument('--hi', type=float, default=0.95)
    ap.add_argument('--max-ebops', type=int, default=10 ** 9)
    ap.add_argument('--shard', type=int, default=0)
    ap.add_argument('--nshard', type=int, default=1)
    ap.add_argument('--merge', action='store_true')
    a = ap.parse_args()
    dst = ROOT / f'ref/x310/x310{xd.TAG}_cost.json'
    if a.merge:
        old = {r['file']: r for r in json.loads(dst.read_text())} if dst.exists() else {}
        for i in range(a.nshard):
            for r in json.loads((OUT / f'w{a.w}_{i}of{a.nshard}.json').read_text()):
                old[r['file']] = r
        dst.write_text(json.dumps(sorted(old.values(), key=lambda r: r['file']), indent=1) + '\n')
        print(f'{len(old)} cost records in {dst.relative_to(ROOT)}')
        return
    cands = [c for c in json.loads((ROOT / f'ref/x310/x310{xd.TAG}_candidates.json').read_text())
             if c['w'] == a.w and c['val']['acc_hi'] >= a.hi and c['ebops'] < a.max_ebops]
    done = {(r['file'], r['size']) for r in json.loads(dst.read_text())} if dst.exists() else set()
    cands = sorted((c for c in cands if (c['file'], c['size']) not in done), key=lambda c: c['file'])[a.shard::a.nshard]
    tr = xd.load(a.w, 'train')
    xin = {b: xd.model_input(tr['x'], bool(b)) for b in {c['bfp'] for c in cands}}
    OUT.mkdir(parents=True, exist_ok=True)
    res = []
    (OUT / f'w{a.w}_{a.shard}of{a.nshard}.json').write_text('[]\n')
    for c in cands:
        t0 = time.time()
        m = keras.models.load_model(ROOT / c['file'])
        ebops = int(trace_minmax(m, xin[c['bfp']], batch_size=16384))
        sol = comb_trace(*trace_model(m, inputs_kif=(1, 0, 15)))
        res.append({'file': c['file'], 'size': c['size'], 'ebops_train': c['ebops'], 'ebops_calibrated': ebops,
                    'da4ml_cost_lut_est': float(sol.cost), 'da4ml_comb_latency': float(sol.latency[1]),
                    'val_acc': c['val']['acc'], 'val_acc_hi': c['val']['acc_hi']})
        print(f"{c['file']}: EBOPs {c['ebops']} -> cost {sol.cost:.0f} LUT ({time.time() - t0:.0f} s)", flush=True)
        (OUT / f'w{a.w}_{a.shard}of{a.nshard}.json').write_text(json.dumps(res, indent=1) + '\n')


if __name__ == '__main__':
    main()
