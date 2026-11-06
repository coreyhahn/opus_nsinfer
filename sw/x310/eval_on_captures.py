"""(Stage 5 BPSK fix, evidence/stage5/bpsk/) Evaluate a keras model on the meas test split (per class, SNR >= 10) and on silicon captures (labelled as
nsclf_analyze). usage: sw/x310/eval_on_captures.py <model.keras> [captures...]"""
import os, sys, json
os.environ.setdefault('KERAS_BACKEND', 'jax')
import jax; jax.config.update('jax_enable_x64', True)
import keras; keras.config.set_floatx('float64')
import hgq  # noqa
import numpy as np
from pathlib import Path
ROOT = Path('/home/cah/r2d2/code/fpga/opus_nsinfer')
sys.path.insert(0, str(ROOT / 'sw/x310')); sys.path.insert(0, str(ROOT / 'ref/x310'))
import x310_data as xd
mp = sys.argv[1]; caps = sys.argv[2:]
model = keras.models.load_model(mp)
te = xd.load(64, 'test')
z = model.predict(xd.model_input(te['x'], True), batch_size=65536, verbose=0); pr = np.argmax(z, 1)
y = te['y']; hi = te['snr_db'] >= 10
pc = [100 * np.mean(pr[y == c] == c) for c in range(4)]
pch = [100 * np.mean(pr[(y == c) & hi] == c) for c in range(4)]
print(json.dumps({'model': mp, 'meas_test_balanced': np.mean(pc), 'per_class': pc, 'snr_ge10_balanced': np.mean(pch), 'per_class_ge10': pch}), flush=True)
if caps:
    import captures_lib as D
    D.model = model
    for c in caps:
        D.run_capture(c)
