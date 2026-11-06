"""Check the Stage 5 Verilator inputs against their committed hashes before a run (make -C tb x310).

  python3 tb/x310_check.py full     # .scratch/x310_full_{in,out,dec}.hex vs ref/golden/x310_full.json
  python3 tb/x310_check.py golden   # ref/golden/x310_golden_*.hex vs ref/golden/x310_golden.json
  python3 tb/x310_check.py stream   # ref/golden/x310_stream_*.hex vs ref/golden/x310_stream.json
"""
import hashlib
import json
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
G = Path(os.environ.get('X310_GOLDEN', ROOT / 'ref/golden'))
which = sys.argv[1]
if which == 'full':
    j = json.loads((G / 'x310_full.json').read_text())
    pairs = [(ROOT / j['files'][s], j['sha256'][s]) for s in ('in', 'out', 'dec')]
else:
    j = json.loads((G / f'x310_{which}.json').read_text())
    pairs = [(G / f'x310_{which}_{s}.hex', j['sha256'][f'x310_{which}_{s}.hex']) for s in ('in', 'out', 'dec')]
bad = [str(p) for p, h in pairs if hashlib.sha256(p.read_bytes()).hexdigest() != h]
if bad:
    sys.exit('HASH MISMATCH: ' + ' '.join(bad))
print(f'x310 {which} vectors: sha256 match ' + ' '.join(f'{p.name}={h[:12]}' for p, h in pairs))
