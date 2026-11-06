"""Pack the committed golden vectors into the word layout jsc_host.py writes over AXI.

Reads ref/golden/jsc_golden_{in,out,argmax}.hex (checking their SHA-256
against ref/golden/jsc_golden.json and jsc_golden_argmax.json) and writes
`jsc_vectors.npz` with
  vin  [N, 5] uint32  VEC words (docs/ARCHITECTURE.md §3)
  vout [N, 3] uint32  expected RES words (logits; word 2 = logits[79:64] | argmax << 16)
plus the source hashes, for copying to galen.

  uv run python sw/galen/make_vectors.py [out.npz]
"""

import hashlib
import json
import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
GOLD = ROOT / 'ref/golden'


def check(name, exp):
    h = hashlib.sha256((GOLD / name).read_bytes()).hexdigest()
    assert h == exp, f'{name}: sha256 {h} != {exp}'
    return h


def main():
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / '.scratch/jsc_vectors.npz'
    meta = json.loads((GOLD / 'jsc_golden.json').read_text())
    amet = json.loads((GOLD / 'jsc_golden_argmax.json').read_text())
    hashes = {n: check(n, meta['sha256'][n]) for n in ('jsc_golden_in.hex', 'jsc_golden_out.hex')}
    hashes['jsc_golden_argmax.hex'] = check('jsc_golden_argmax.hex', amet['jsc_golden_argmax.hex_sha256'])
    vin_i = [int(l, 16) for l in (GOLD / 'jsc_golden_in.hex').read_text().split()]
    vout_i = [int(l, 16) for l in (GOLD / 'jsc_golden_out.hex').read_text().split()]
    arg = [int(l, 16) for l in (GOLD / 'jsc_golden_argmax.hex').read_text().split()]
    n = len(vin_i)
    assert n == len(vout_i) == len(arg) == meta['n_test']
    m = (1 << 32) - 1
    vin = np.array([[(x >> (32 * w)) & m for w in range(5)] for x in vin_i], dtype=np.uint32)
    vout = np.array([[x & m, (x >> 32) & m, ((x >> 64) & 0xFFFF) | (a << 16)] for x, a in zip(vout_i, arg)], dtype=np.uint32)
    out.parent.mkdir(parents=True, exist_ok=True)
    np.savez(out, vin=vin, vout=vout, hashes=json.dumps(hashes))
    print(f'{out}: {n} vectors, sha256 {hashlib.sha256(out.read_bytes()).hexdigest()}')


if __name__ == '__main__':
    main()
