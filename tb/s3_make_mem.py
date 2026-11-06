#!/usr/bin/env python3
"""Stage 3/4 shot memory: one line per shot, {exp_flip, det[N_DET-1:0]} = (dec << N_DET) | det, in
ceil((N_DET + 1) / 4) hex digits: 7 for d = 3 (N_DET = 24), 31 for d = 5 (N_DET = 120).

Input: the packed golden format (never written back):
  <in>.hex   one detection vector per line, ceil(N_DET / 4) hex digits, detector j at bit j
             (6 digits for d = 3, 30 digits = 120 bits for d = 5)
  <dec>.hex  one expected flip per line (1 hex digit, 0 or 1), same order
Defaults: ref/golden/qec_d<d>_golden_in.hex and qec_d<d>_golden_dec.hex, with the vector count checked
against n_vectors in ref/golden/qec_d<d>_golden.json. Explicit --in / --dec (e.g. the TEST-ONLY
stand-in vectors of tb/qec_d5_standin_gen.py) skip the json; the count is the line count.
  python3 tb/s3_make_mem.py                          -> .scratch/s3_shots_n<N>.hex (d = 3, all shots)
  python3 tb/s3_make_mem.py --nvec 4096              -> first 4096 shots
  python3 tb/s3_make_mem.py --out <path>             -> any path (e.g. a build directory)
  python3 tb/s3_make_mem.py --d 5                    -> ref/golden/qec_d5_golden_*.hex, .scratch/s3d5_shots_n<N>.hex
  python3 tb/s3_make_mem.py --d 5 --in X.hex --dec Y.hex --nvec 65536 --out Z.hex
Prints the output path and its sha256.
"""
import argparse, hashlib, json, os, sys

proj = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ap = argparse.ArgumentParser()
ap.add_argument('--d', type=int, default=3, choices=(3, 5), help='code distance: 3 (24 bits) or 5 (120 bits)')
ap.add_argument('--golden', default=os.path.join(proj, 'ref', 'golden'))
ap.add_argument('--in', dest='inp', default='', help='detection hex file (default: golden)')
ap.add_argument('--dec', default='', help='decision hex file (default: golden)')
ap.add_argument('--nvec', type=int, default=0, help='first N shots (0 = all)')
ap.add_argument('--out', default='')
a = ap.parse_args()

n_det = {3: 24, 5: 120}[a.d]
in_digits = (n_det + 3) // 4
out_digits = (n_det + 1 + 3) // 4
if bool(a.inp) != bool(a.dec):
    sys.exit('--in and --dec go together')
if a.inp:
    fin, fdec, n_all = a.inp, a.dec, None
else:
    fin = os.path.join(a.golden, f'qec_d{a.d}_golden_in.hex')
    fdec = os.path.join(a.golden, f'qec_d{a.d}_golden_dec.hex')
    n_all = json.load(open(os.path.join(a.golden, f'qec_d{a.d}_golden.json')))['n_vectors']
det = open(fin).read().split()
dec = open(fdec).read().split()
if n_all is None:
    n_all = len(det)
if len(det) != n_all or len(dec) != n_all:
    sys.exit(f'golden length mismatch: expected {n_all}, in {len(det)}, dec {len(dec)}')
n = a.nvec or n_all
if not 0 < n <= n_all:
    sys.exit(f'--nvec must be in 1..{n_all}')
pfx = 's3' if a.d == 3 else 's3d5'
out = a.out or os.path.join(proj, '.scratch', f'{pfx}_shots_n{n}.hex')
os.makedirs(os.path.dirname(os.path.abspath(out)), exist_ok=True)
lines = []
for i in range(n):
    if len(det[i]) != in_digits:
        sys.exit(f'golden entry {i}: {len(det[i])} hex digits, want {in_digits} for d = {a.d}')
    d, f = int(det[i], 16), int(dec[i], 16)
    if d >> n_det or f > 1:
        sys.exit(f'bad golden entry {i}: {det[i]} {dec[i]}')
    lines.append(format((f << n_det) | d, f'0{out_digits}x'))
data = ('\n'.join(lines) + '\n').encode()
open(out, 'wb').write(data)
print(out, hashlib.sha256(data).hexdigest())
