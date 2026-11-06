"""Stim surface-code memory experiment + PyMatching reference (Stage 2, PLAN.md §B.1).

Circuit: `surface_code:rotated_memory_z`, distance d, d rounds, uniform circuit-level
depolarising noise of strength p on all four Stim knobs (after_clifford_depolarization,
before_round_data_depolarization, before_measure_flip_probability, after_reset_flip_probability).
Detectors: 24 at d = 3, 120 at d = 5; one observable (logical Z).

At d = 3 every split is stored as a multiset: the distinct detection-event vectors seen, each
with n0 / n1 = the number of shots whose observable did not / did flip. This is lossless for
everything Stage 2 needs (a decoder is a function of the detection events, so its logical error
count is sum over vectors of n_{1-decision}), and it is small (a few 10^5 rows from 10^8 shots).

  uv run python ref/qec/qec_data.py --d 3            # train / val / test tables + PyMatching
Writes ref/qec/circuits/*.stim (committed), ref/data/qec/d3_{train,val}_p*.npz (not committed),
ref/golden/qec_d3_test.npz + qec_d3_test.json (committed, hashed).
"""

import argparse
import hashlib
import json
import time
from pathlib import Path

import numpy as np
import pymatching
import stim

ROOT = Path(__file__).resolve().parents[2]
P_LIST = (0.001, 0.002, 0.003, 0.005, 0.007, 0.01)
SEED_BASE = {'train': 100_000, 'val': 200_000, 'test': 300_000}
CHUNK = 1_000_000


def circuit(d: int, p: float) -> stim.Circuit:
    return stim.Circuit.generated('surface_code:rotated_memory_z', distance=d, rounds=d,
                                  after_clifford_depolarization=p, before_round_data_depolarization=p,
                                  before_measure_flip_probability=p, after_reset_flip_probability=p)


def ptag(p: float) -> str:
    return f'{p * 1000:g}e-3'.replace('.', 'p')


def keys_of(det: np.ndarray) -> np.ndarray:
    """Detection events (n, nd <= 63) -> int64 key, detector j at bit j."""
    w = (1 << np.arange(det.shape[1], dtype=np.int64))
    return det.astype(np.int64) @ w


def bits_of(keys: np.ndarray, nd: int) -> np.ndarray:
    return ((keys[:, None] >> np.arange(nd, dtype=np.int64)) & 1).astype(np.uint8)


def sample_table(c: stim.Circuit, shots: int, seed: int):
    """Sample `shots` in chunks; return (keys, n0, n1) over distinct detection-event vectors."""
    keys_all, cnt_all = [], []
    s = c.compile_detector_sampler(seed=seed)
    done = 0
    while done < shots:
        n = min(CHUNK, shots - done)
        det, obs = s.sample(n, separate_observables=True)
        k = keys_of(det) * 2 + obs[:, 0].astype(np.int64)  # observable in the LSB
        u, cnt = np.unique(k, return_counts=True)
        keys_all.append(u); cnt_all.append(cnt)
        done += n
        if len(keys_all) >= 20:  # merge periodically to bound memory
            u, inv = np.unique(np.concatenate(keys_all), return_inverse=True)
            keys_all, cnt_all = [u], [np.bincount(inv, weights=np.concatenate(cnt_all)).astype(np.int64)]
    u, inv = np.unique(np.concatenate(keys_all), return_inverse=True)
    cnt = np.bincount(inv, weights=np.concatenate(cnt_all)).astype(np.int64)
    det_key, ob = u >> 1, u & 1
    keys, inv = np.unique(det_key, return_inverse=True)
    n0 = np.bincount(inv, weights=cnt * (ob == 0), minlength=len(keys)).astype(np.int64)
    n1 = np.bincount(inv, weights=cnt * (ob == 1), minlength=len(keys)).astype(np.int64)
    assert n0.sum() + n1.sum() == shots
    return keys, n0, n1


def sha256(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--d', type=int, default=3)
    ap.add_argument('--train-shots', type=float, default=1e8)
    ap.add_argument('--val-shots', type=float, default=1e7)
    ap.add_argument('--test-shots', type=float, default=1e7)
    a = ap.parse_args()
    assert a.d == 3, 'table form is for d = 3 (24 detectors); d = 5 streams in its own script'
    cdir = ROOT / 'ref/qec/circuits'; cdir.mkdir(parents=True, exist_ok=True)
    ddir = ROOT / 'ref/data/qec'; ddir.mkdir(parents=True, exist_ok=True)
    gdir = ROOT / 'ref/golden'
    test = {}
    meta = {'circuit': 'surface_code:rotated_memory_z', 'distance': a.d, 'rounds': a.d,
            'noise': 'uniform circuit-level: after_clifford_depolarization = before_round_data_depolarization = '
                     'before_measure_flip_probability = after_reset_flip_probability = p',
            'stim': stim.__version__, 'pymatching': pymatching.__version__, 'seed_base': SEED_BASE,
            'shots': {'train': int(a.train_shots), 'val': int(a.val_shots), 'test': int(a.test_shots)}, 'p': {}}
    for i, p in enumerate(P_LIST):
        c = circuit(a.d, p)
        cf = cdir / f'd{a.d}_p{ptag(p)}.stim'
        cf.write_text(str(c))
        nd = c.num_detectors
        m = pymatching.Matching.from_detector_error_model(c.detector_error_model(decompose_errors=True))
        info = {'num_detectors': nd, 'circuit_file': str(cf.relative_to(ROOT)), 'circuit_sha256': sha256(cf)}
        for split, shots in (('train', a.train_shots), ('val', a.val_shots), ('test', a.test_shots)):
            t0 = time.time()
            seed = SEED_BASE[split] + i
            keys, n0, n1 = sample_table(c, int(shots), seed)
            pm = m.decode_batch(bits_of(keys, nd))[:, 0].astype(np.uint8)
            err_pm = int(np.where(pm == 1, n0, n1).sum())
            err_mle = int(np.minimum(n0, n1).sum())  # in-sample lookup-table bound (optimistic)
            info[split] = {'seed': seed, 'distinct': int(len(keys)), 'pm_errors': err_pm,
                           'pm_ler': err_pm / shots, 'table_mle_errors_in_sample': err_mle}
            if split == 'test':
                test[ptag(p)] = (keys, n0, n1, pm)
            else:
                np.savez_compressed(ddir / f'd{a.d}_{split}_p{ptag(p)}.npz', keys=keys, n0=n0, n1=n1, pm=pm)
            print(f'd={a.d} p={p} {split}: {len(keys)} distinct, PyMatching LER {err_pm / shots:.4e} '
                  f'(in-sample table bound {err_mle / shots:.4e}) {time.time() - t0:.0f}s', flush=True)
        meta['p'][ptag(p)] = dict(info, p=p)
    out = gdir / f'qec_d{a.d}_test.npz'
    np.savez_compressed(out, **{f'{k}_{f}': v for k, t in test.items() for f, v in zip(('keys', 'n0', 'n1', 'pm'), t)})
    meta['test_file'] = str(out.relative_to(ROOT)); meta['test_sha256'] = sha256(out)
    (gdir / f'qec_d{a.d}_test.json').write_text(json.dumps(meta, indent=1) + '\n')


if __name__ == '__main__':
    main()
