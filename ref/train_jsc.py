"""Train the JSC MLP (16 -> 64 -> 32 -> 32 -> 5, ReLU), the hls4ml HLF JSC
benchmark architecture, in float64 on the JAX backend.

  --mode float : unquantized Keras baseline (the accuracy reference)
  --mode hgq   : HGQ2 heterogeneous quantization with an EBOPs penalty whose
                 beta ramps up over training; every Pareto-optimal
                 (val_accuracy, ebops) checkpoint is saved.

float64 everywhere: the da4ml mismatch study traced every Keras-vs-RTL
mismatch to float32 emulation of accumulators of 23+ bits; in float64 the
fixed-point arithmetic is exact up to 52 bits.
"""

import argparse
import json
import os
import time
from pathlib import Path

os.environ.setdefault('KERAS_BACKEND', 'jax')
import jax  # noqa: E402

jax.config.update('jax_enable_x64', True)
import keras  # noqa: E402
import numpy as np  # noqa: E402

keras.config.set_floatx('float64')

HERE = Path(__file__).parent
ARCH = (64, 32, 32)
N_CLASS = 5


def load_split():
    d = np.load(HERE / 'data/jsc_split.npz')
    return {k: d[k] for k in d.files}


def build_float():
    layers = [keras.layers.InputLayer((16,))]
    for i, n in enumerate(ARCH):
        layers.append(keras.layers.Dense(n, activation='relu', name=f'fc{i + 1}'))
    layers.append(keras.layers.Dense(N_CLASS, name='out'))
    return keras.Sequential(layers, name='jsc_float')


def build_hgq(beta0: float, input_f: int):
    from hgq.config import LayerConfigScope, QuantizerConfigScope
    from hgq.layers import QDense

    # Weights and biases: KBI, symmetric saturation (bit-widths learned).
    # Activations ('datalane'): KIF, WRAP; the integer bits are fixed after
    # training by trace_minmax over the calibration set, only fractional bits
    # are trained. Rounding RND = floor(x + 0.5) throughout.
    with (
        QuantizerConfigScope(place=('weight', 'bias'), overflow_mode='SAT_SYM', round_mode='RND'),
        QuantizerConfigScope(place='datalane', overflow_mode='WRAP', round_mode='RND', f0=input_f),
        LayerConfigScope(enable_ebops=True, beta0=beta0),
    ):
        layers = [keras.layers.InputLayer((16,))]
        for i, n in enumerate(ARCH):
            layers.append(QDense(n, activation='relu', name=f'fc{i + 1}'))
        layers.append(QDense(N_CLASS, name='out'))
        return keras.Sequential(layers, name='jsc_hgq')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--mode', choices=('float', 'hgq'), required=True)
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--epochs', type=int, default=300)
    ap.add_argument('--batch', type=int, default=2048)
    ap.add_argument('--lr', type=float, default=3e-3)
    ap.add_argument('--beta-start', type=float, default=1e-7)
    ap.add_argument('--beta-end', type=float, default=3e-5)
    ap.add_argument('--input-f', type=int, default=6)
    ap.add_argument('--seed', type=int, default=1)
    a = ap.parse_args()

    keras.utils.set_random_seed(a.seed)
    a.out.mkdir(parents=True, exist_ok=True)
    d = load_split()
    xtr, ytr, xva, yva = d['x_train'], d['y_train'], d['x_val'], d['y_val']

    steps = a.epochs * int(np.ceil(len(xtr) / a.batch))
    sched = keras.optimizers.schedules.CosineDecay(a.lr, steps, alpha=0.02)
    opt = keras.optimizers.Adam(sched)
    cbs = []
    if a.mode == 'float':
        model = build_float()
        cbs.append(keras.callbacks.ModelCheckpoint(str(a.out / 'best.keras'), monitor='val_accuracy', save_best_only=True))
    else:
        from hgq.utils.sugar import BetaScheduler, FreeEBOPs, ParetoFront, PieceWiseSchedule

        model = build_hgq(a.beta_start, a.input_f)
        warm = max(1, a.epochs // 20)
        cbs += [
            BetaScheduler(PieceWiseSchedule([(0, a.beta_start, 'constant'), (warm, a.beta_start, 'log'), (a.epochs, a.beta_end, 'constant')])),
            FreeEBOPs(),
            ParetoFront(a.out / 'pareto', ['val_accuracy', 'ebops'], [1, -1], fname_format='e{epoch:04d}_acc{val_accuracy:.5f}_ebops{ebops}.keras'),
        ]
    model.compile(opt, keras.losses.SparseCategoricalCrossentropy(from_logits=True), metrics=['accuracy'])
    model.summary()
    t0 = time.time()
    hist = model.fit(xtr, ytr, batch_size=a.batch, epochs=a.epochs, validation_data=(xva, yva), callbacks=cbs, verbose=2)
    hist = {k: [float(v) for v in vs] for k, vs in hist.history.items()}
    meta = dict(vars(a), out=str(a.out), wall_s=time.time() - t0, history=hist)
    (a.out / 'train_log.json').write_text(json.dumps(meta, indent=1))
    model.save(a.out / 'last.keras')


if __name__ == '__main__':
    main()
