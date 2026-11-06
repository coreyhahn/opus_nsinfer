#!/usr/bin/env python3
"""Stage 4 silicon vector sets 1..3 (CHARTER rule (c): >= 4 vector sets, each run twice without reprogramming).

Set 0 is the committed golden set (ref/golden/qec_d5_golden_{in,dec}.hex, 131,072 vectors). Sets 1..3 are
uniform draws without replacement of 131,072 vectors from the full distinct test set (.scratch/qec_d5_full_*,
ref/golden/qec_d5_full.json), Python random.Random(seed).sample with seed = set number, in draw order, with
the full set's Keras decisions. They are derived files (.scratch/qec_d5_set<k>_{in,dec}.hex, ~4 MB each);
ref/golden/qec_d5_sets.json records the method and their sha256, so a rerun must reproduce them byte for byte.
  python3 tb/s4_vector_sets.py            (checks the full set's sha256 against qec_d5_full.json first)
"""
import hashlib, json, random
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
N, SETS = 131072, (1, 2, 3)


def sha(p):
    h = hashlib.sha256()
    with open(p, 'rb') as f:
        for b in iter(lambda: f.read(1 << 22), b''):
            h.update(b)
    return h.hexdigest()


full = json.loads((ROOT / 'ref/golden/qec_d5_full.json').read_text())
fin, fdec = ROOT / '.scratch/qec_d5_full_in.hex', ROOT / '.scratch/qec_d5_full_dec.hex'
for p in (fin, fdec):
    assert sha(p) == full['sha256'][str(p.relative_to(ROOT))], f'{p} does not match ref/golden/qec_d5_full.json'
vin, vdec = fin.read_text().split(), fdec.read_text().split()
assert len(vin) == len(vdec) == full['n_vectors']
rec = {'method': __doc__.split('\n\n')[0], 'n_vectors': N, 'source': 'ref/golden/qec_d5_full.json',
       'full_sha256_in': full['sha256'][str(fin.relative_to(ROOT))], 'sets': {}}
for k in SETS:
    idx = random.Random(k).sample(range(len(vin)), N)
    pi, pd = ROOT / f'.scratch/qec_d5_set{k}_in.hex', ROOT / f'.scratch/qec_d5_set{k}_dec.hex'
    pi.write_text(''.join(vin[i] + '\n' for i in idx))
    pd.write_text(''.join(vdec[i] + '\n' for i in idx))
    rec['sets'][str(k)] = {'seed': k, 'in': str(pi.relative_to(ROOT)), 'dec': str(pd.relative_to(ROOT)),
                           'sha256_in': sha(pi), 'sha256_dec': sha(pd), 'flips': sum(vdec[i] != '0' for i in idx)}
    print(k, rec['sets'][str(k)])
out = ROOT / 'ref/golden/qec_d5_sets.json'
if out.exists():  # a rerun must reproduce the committed sets
    old = json.loads(out.read_text())
    assert old['sets'] == rec['sets'], 'sets differ from ref/golden/qec_d5_sets.json'
    print('reproduced ref/golden/qec_d5_sets.json')
else:
    out.write_text(json.dumps(rec, indent=1) + '\n')
