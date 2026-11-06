#!/usr/bin/env python3
"""Choice of the hysteresis K default (REG_K reset value) on the committed golden stream (model labels).

Rule (stated with the result, evidence/stage5/block/README.md section 4): the largest K whose smoothed-class
accuracy on the stream's pure windows (all 64 samples one label) is not below the raw decisions' accuracy; the
event count and the added delay (K - 1 decisions) are reported with it. Labels: x310_data.make_stream(65536, 0)
regenerated (the stream's samples are checked equal to ref/golden/x310_stream_in.hex first). Every figure is
**model** (Keras decisions on the channel-model stream). Run with the project venv: .venv/bin/python sw/x310/nsclf_kchoice.py
"""
import sys
from pathlib import Path

import numpy as np
from numpy.lib.stride_tricks import sliding_window_view

ROOT = Path(__file__).resolve().parents[2]
sys.path[:0] = [str(ROOT / 'ref' / 'x310'), str(ROOT / 'sw' / 'x310')]
import x310_data as xd  # noqa: E402
import nsclf_model as m  # noqa: E402

samp, _, cls, W, _ = m.load_stream()
ys, lab = xd.make_stream(len(samp), 0)
assert np.array_equal(ys[:, 0], [s[0] for s in samp]) and np.array_equal(ys[:, 1], [s[1] for s in samp])
cls = np.array(cls)
lw = sliding_window_view(lab, W)
pure = np.all(lw == lw[:, :1], axis=1)
wl = lw[:, 0]
true_changes = int(np.sum(np.diff(lab) != 0))
raw_acc = float(np.mean(cls[pure] == wl[pure]))
print(f'stream: {len(samp)} samples, {len(cls)} decisions, {int(pure.sum())} pure windows, '
      f'{true_changes} label changes, raw pure-window accuracy {raw_acc:.4f} (model)')
print(f'{"K":>3} {"events":>7} {"events/true":>11} {"smoothed acc":>12} {"added delay":>12}')
best = None
for k in [1, 2, 4, 8, 12, 16, 24, 32, 48, 64]:
    ev = m.hysteresis(list(range(len(cls))), list(cls), k)
    sm = np.zeros(len(cls), dtype=int)
    cur, it = 0, iter(ev)
    nxt = next(it, None)
    for d in range(len(cls)):
        if nxt is not None and nxt['tau'] == d:
            cur = nxt['new']
            nxt = next(it, None)
        sm[d] = cur
    acc = float(np.mean(sm[pure] == wl[pure]))
    if acc >= raw_acc:
        best = k
    print(f'{k:3d} {len(ev):7d} {len(ev) / true_changes:11.2f} {acc:12.4f} {5 * (k - 1):9d} ns')
print(f'K_DEFAULT = {best} (largest K with smoothed accuracy >= raw)')
