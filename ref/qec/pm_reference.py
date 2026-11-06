"""PyMatching reference logical error rates (no NN) for any distance, same circuits and noise as
qec_data.py, on fresh held-out shots (test seeds). Writes evidence/stage2/pymatching_d<d>.json.

  uv run python ref/qec/pm_reference.py --d 5 --shots 1e7
"""

import argparse
import json
import sys
import time
from pathlib import Path

import numpy as np
import pymatching
import stim

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'ref/qec'))
from qec_data import CHUNK, P_LIST, SEED_BASE, circuit, ptag  # noqa: E402


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--d', type=int, required=True)
    ap.add_argument('--shots', type=float, default=1e7)
    a = ap.parse_args()
    out = {'distance': a.d, 'rounds': a.d, 'stim': stim.__version__, 'pymatching': pymatching.__version__,
           'noise': 'uniform circuit-level p (qec_data.py)', 'p': {}}
    for i, p in enumerate(P_LIST):
        c = circuit(a.d, p)
        m = pymatching.Matching.from_detector_error_model(c.detector_error_model(decompose_errors=True))
        s = c.compile_detector_sampler(seed=SEED_BASE['test'] + 1000 * a.d + i)
        err = done = 0
        t0 = time.time()
        while done < int(a.shots):
            n = min(CHUNK, int(a.shots) - done)
            det, obs = s.sample(n, separate_observables=True)
            err += int(np.sum(m.decode_batch(det)[:, 0] != obs[:, 0]))
            done += n
        ler = err / done
        out['p'][ptag(p)] = {'p': p, 'num_detectors': c.num_detectors, 'shots': done, 'pm_errors': err, 'pm_ler': ler,
                             'pm_ler_per_round': (1 - (1 - 2 * ler) ** (1 / a.d)) / 2,
                             'decode_s_per_shot': (time.time() - t0) / done}
        print(f'd={a.d} p={p}: PyMatching LER {ler:.4e} ({err} / {done})', flush=True)
    (ROOT / f'evidence/stage2/pymatching_d{a.d}.json').write_text(json.dumps(out, indent=1) + '\n')


if __name__ == '__main__':
    main()
