"""(Stage 5 v2) Raw-decision false alarms and hysteresis events vs K on a capture, from the exported model (bit-exact
with the RTL: the replay MISR proves the same decisions). usage: .venv/bin/python sw/x310/k_scan.py <capture.npz>"""
import os, sys, json
os.environ.setdefault('KERAS_BACKEND', 'jax')
import jax; jax.config.update('jax_enable_x64', True)
import keras; keras.config.set_floatx('float64')
import hgq  # noqa
import numpy as np
ROOT = '/home/cah/r2d2/code/fpga/opus_nsinfer'
sys.path[:0] = [ROOT + '/sw/x310', ROOT + '/ref/x310']
import captures_lib as D, nsclf_model as m
D.model = keras.models.load_model(ROOT + '/ref/golden/x310_hgq.keras')
z = np.load(sys.argv[1]); y = z['i'].astype(float) + 1j * z['q'].astype(float)
cls = D.predict(y)
print('FA per decision %', 100 * np.mean(cls != 0), 'per class', [round(100 * np.mean(cls == c), 3) for c in range(4)])
# run lengths of non-noise raw decisions
nz = (cls != 0).astype(np.int8); d = np.diff(np.concatenate([[0], nz, [0]]))
runs = np.flatnonzero(d == -1) - np.flatnonzero(d == 1)
print('non-noise runs', len(runs), 'median', np.median(runs), 'p90', np.percentile(runs, 90), 'max', runs.max())
for k in (16, 32, 64, 96, 128, 192, 256, 512):
    ev = m.hysteresis(range(len(cls)), [int(c) for c in cls], k)
    print(f'K={k}: events {len(ev)} = {len(ev) / (len(cls) / 200e6):.0f}/s')
