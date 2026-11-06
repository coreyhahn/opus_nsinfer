"""Stim syndromes + PyMatching reference for the d = 5 decoder (120 detectors), Stage 4.

Same circuit, noise and seeds as qec_data.py (d = 3), with detection-event vectors bit-packed
(np.packbits, little bit order: detector j = bit j % 8 of byte j // 8, 15 bytes). Each split is a
multiset over distinct vectors with counts n0 / n1, as at d = 3 (deduplication by the 15-byte row;
at p = 1 % most d = 5 rows are distinct, at 0.1 % most are not). The six noise strengths are
sampled in parallel processes.

Writes ref/qec/circuits/d5_*.stim (committed), ref/data/qec/d5_{train,val,test}_p*.npz (keys =
packed uint8 [n, 15], n0, n1, pm; not committed: regenerated from the seeds, sha256 recorded) and
ref/golden/qec_d5_data.json (committed: per-p counts, PyMatching LER, file hashes).

  python ref/qec/qec_data_d5.py --train-shots 3e7 --val-shots 2e6 --test-shots 5e6
"""

import argparse
import json
import time
from multiprocessing import Pool
from pathlib import Path

import numpy as np
import pymatching
import stim

from qec_data import P_LIST, SEED_BASE, circuit, ptag, sha256

ROOT = Path(__file__).resolve().parents[2]
CHUNK = 1_000_000
D = 5
NB = 15  # bytes per packed 120-bit vector


def packed(det):
    return np.packbits(det.astype(np.uint8), axis=1, bitorder='little')


def unpack(keys, nd):
    return np.unpackbits(keys, axis=1, bitorder='little', count=nd)


def unique_rows(k, w=None):
    """Distinct 16-byte rows (15 packed + 1 observable byte) of k, with summed weights."""
    v = np.ascontiguousarray(k).view(np.dtype((np.void, k.shape[1])))[:, 0]
    u, inv = np.unique(v, return_inverse=True)
    cnt = np.bincount(inv, weights=w, minlength=len(u)).astype(np.int64)
    return u.view(np.uint8).reshape(len(u), k.shape[1]), cnt


def sample_table(c, shots, seed):
    s = c.compile_detector_sampler(seed=seed)
    rows, cnts, done = [], [], 0
    while done < shots:
        n = min(CHUNK, shots - done)
        det, obs = s.sample(n, separate_observables=True)
        k = np.concatenate([packed(det), obs[:, :1].astype(np.uint8)], axis=1)
        u, cnt = unique_rows(k)
        rows.append(u); cnts.append(cnt)
        done += n
        if len(rows) >= 10:
            u, cnt = unique_rows(np.concatenate(rows), np.concatenate(cnts))
            rows, cnts = [u], [cnt]
    u, cnt = unique_rows(np.concatenate(rows), np.concatenate(cnts))
    ob = u[:, NB]
    keys, c0 = unique_rows(u[:, :NB], cnt * (ob == 0))
    _, c1 = unique_rows(u[:, :NB], cnt * (ob == 1))
    assert c0.sum() + c1.sum() == shots
    return keys, c0, c1


def one_p(args):
    i, p, shots_by_split = args
    c = circuit(D, p)
    cdir = ROOT / 'ref/qec/circuits'
    cf = cdir / f'd{D}_p{ptag(p)}.stim'
    cf.write_text(str(c))
    nd = c.num_detectors
    m = pymatching.Matching.from_detector_error_model(c.detector_error_model(decompose_errors=True))
    info = {'p': p, 'num_detectors': nd, 'circuit_file': str(cf.relative_to(ROOT)), 'circuit_sha256': sha256(cf)}
    for split, shots in shots_by_split:
        t0 = time.time()
        seed = SEED_BASE[split] + i
        keys, n0, n1 = sample_table(c, int(shots), seed)
        pm = np.concatenate([m.decode_batch(unpack(keys[j:j + 200_000], nd))[:, 0]
                             for j in range(0, len(keys), 200_000)]).astype(np.uint8)
        err_pm = int(np.where(pm == 1, n0, n1).sum())
        f = ROOT / f'ref/data/qec/d{D}_{split}_p{ptag(p)}.npz'
        np.savez_compressed(f, keys=keys, n0=n0, n1=n1, pm=pm)
        info[split] = {'seed': seed, 'shots': int(shots), 'distinct': int(len(keys)), 'pm_errors': err_pm,
                       'pm_ler': err_pm / shots, 'file': str(f.relative_to(ROOT)), 'sha256': sha256(f)}
        print(f'd={D} p={p} {split}: {len(keys)} distinct, PyMatching LER {err_pm / shots:.4e} {time.time() - t0:.0f}s', flush=True)
    return ptag(p), info


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--train-shots', type=float, default=3e7)
    ap.add_argument('--val-shots', type=float, default=2e6)
    ap.add_argument('--test-shots', type=float, default=5e6)
    a = ap.parse_args()
    (ROOT / 'ref/data/qec').mkdir(parents=True, exist_ok=True)
    splits = (('test', a.test_shots), ('val', a.val_shots), ('train', a.train_shots))
    with Pool(len(P_LIST)) as pool:
        res = dict(pool.map(one_p, [(i, p, splits) for i, p in enumerate(P_LIST)]))
    meta = {'circuit': 'surface_code:rotated_memory_z', 'distance': D, 'rounds': D,
            'noise': 'uniform circuit-level p, as qec_data.py', 'packing': 'np.packbits(bitorder=little), 15 bytes',
            'stim': stim.__version__, 'pymatching': pymatching.__version__, 'seed_base': SEED_BASE,
            'shots': {k: int(v) for k, v in splits}, 'p': res}
    (ROOT / 'ref/golden/qec_d5_data.json').write_text(json.dumps(meta, indent=1) + '\n')


if __name__ == '__main__':
    main()
