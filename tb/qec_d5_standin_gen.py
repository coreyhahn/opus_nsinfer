#!/usr/bin/env python3
"""TEST-ONLY golden vectors for tb/qec_d5_standin.sv (the synthetic d = 5 stand-in core; not a decoder).

Writes, in the packed golden format that tb/s3_make_mem.py --d 5 reads:
  <out>/qec_d5_standin_in.hex   30 hex digits per line = 120 bits, detector j at bit j
  <out>/qec_d5_standin_dec.hex  1 hex digit per line, expected flip (logit > 0)
  <out>/qec_d5_standin.json     n_vectors, det_bits, out_width_bits, out_signed, dec_lat, seed, flip rate
Vectors: random 120-bit words; each vector's bit density is drawn from {0.01, 0.03, 0.1, 0.3, 0.5}
(sparse syndromes and dense ones), plus the all-zero and all-one words first.
  python3 tb/qec_d5_standin_gen.py --n 65536 --out .scratch/s3d5_standin
"""
import argparse, hashlib, json, os
import random

N_DET, OUT_W, DEC_LAT = 120, 16, 5   # DEC_LAT: 4 core edges + qec_d5_top flip register
W = [((73 * j + 11) % 251) - 125 for j in range(N_DET)]


def logit(x):
    s = sum(W[j] for j in range(N_DET) if (x >> j) & 1)
    par = bin(x).count('1') & 1
    v = s + (301 if par else -301)
    assert -(1 << (OUT_W - 1)) <= v < (1 << (OUT_W - 1))
    return v


ap = argparse.ArgumentParser()
ap.add_argument('--n', type=int, default=65536)
ap.add_argument('--seed', type=int, default=5)
ap.add_argument('--out', required=True)
a = ap.parse_args()
rng = random.Random(a.seed)
vecs = [0, (1 << N_DET) - 1]
while len(vecs) < a.n:
    p = rng.choice([0.01, 0.03, 0.1, 0.3, 0.5])
    x = 0
    for j in range(N_DET):
        if rng.random() < p:
            x |= 1 << j
    vecs.append(x)
vecs = vecs[:a.n]
dec = [1 if logit(x) > 0 else 0 for x in vecs]
os.makedirs(a.out, exist_ok=True)
fin, fdec = os.path.join(a.out, 'qec_d5_standin_in.hex'), os.path.join(a.out, 'qec_d5_standin_dec.hex')
din = ''.join(format(x, '030x') + '\n' for x in vecs).encode()
ddec = ''.join(f'{d}\n' for d in dec).encode()
open(fin, 'wb').write(din)
open(fdec, 'wb').write(ddec)
meta = dict(what='TEST-ONLY stand-in (tb/qec_d5_standin.sv), not a decoder', n_vectors=a.n, det_bits=N_DET,
            out_width_bits=OUT_W, out_signed=1, dec_lat=DEC_LAT, seed=a.seed, flip_rate=sum(dec) / a.n,
            in_hex_sha256=hashlib.sha256(din).hexdigest(), dec_hex_sha256=hashlib.sha256(ddec).hexdigest())
json.dump(meta, open(os.path.join(a.out, 'qec_d5_standin.json'), 'w'), indent=1)
print(json.dumps(meta))
