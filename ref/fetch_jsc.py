"""Freeze the hls4ml HLF jet-substructure dataset (OpenML 42468
'hls4ml_lhc_jets_hlf', CC-BY, DOI 10.5281/zenodo.3602260) into the
train/val/test split used at every stage.

Input: ref/data/dataset_42468.pq, downloaded from
https://data.openml.org/datasets/0004/42468/dataset_42468.pq (the ARFF
endpoint streams at <1 kB/s from this lab). Its SHA-256 is recorded. Then freeze the train/val/test split used at every stage.

Split: the hls4ml tutorial convention (test_size=0.2, random_state=42), then
10% of train held out for validation (random_state=42). Features are
standardised with a StandardScaler fitted on train only. The frozen arrays and
their SHA-256 are written to ref/data/ (git-ignored; the hash is committed).
"""

import hashlib
import json
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler

OUT = Path(__file__).parent / 'data'


def main():
    OUT.mkdir(exist_ok=True)
    src = OUT / 'dataset_42468.pq'
    df = pd.read_parquet(src)
    feats = [c for c in df.columns if c != 'class']
    x = df[feats].to_numpy(np.float64)
    le = LabelEncoder()
    y = le.fit_transform(df['class'].astype(str)).astype(np.int64)
    x_tr, x_te, y_tr, y_te = train_test_split(x, y, test_size=0.2, random_state=42)
    x_tr, x_va, y_tr, y_va = train_test_split(x_tr, y_tr, test_size=0.1, random_state=42)
    sc = StandardScaler().fit(x_tr)
    arrs = dict(
        x_train=sc.transform(x_tr), y_train=y_tr,
        x_val=sc.transform(x_va), y_val=y_va,
        x_test=sc.transform(x_te), y_test=y_te,
    )
    np.savez(OUT / 'jsc_split.npz', **arrs)
    meta = {
        'source': 'OpenML 42468 hls4ml_lhc_jets_hlf v1 (parquet)',
        'sha256_source': hashlib.sha256(src.read_bytes()).hexdigest(),
        'features': feats,
        'classes': list(le.classes_),
        'n': {k: int(v.shape[0]) for k, v in arrs.items() if k.startswith('x')},
        'scaler_mean': sc.mean_.tolist(),
        'scaler_scale': sc.scale_.tolist(),
        'sha256_npz': hashlib.sha256((OUT / 'jsc_split.npz').read_bytes()).hexdigest(),
    }
    (Path(__file__).parent / 'jsc_split_meta.json').write_text(json.dumps(meta, indent=1))
    print(json.dumps({k: meta[k] for k in ('source', 'sha256_source', 'classes', 'n', 'sha256_npz')}, indent=1))


if __name__ == '__main__':
    main()
