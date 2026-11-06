"""Train the Stage 5 waveform classifier (2W int16 -> MLP -> 4 logits) in float64 on JAX (PLAN.md D-S5-SEL).

Input: one window of W complex samples from ref/x310/x310_data.py, block-floating-point shifted (--bfp 1,
the default; bit-exact in RTL) and scaled to [-1, 1) on the 2^-15 grid.

  --mode float : unquantized Keras baseline (the accuracy reference per W)
  --mode hgq   : HGQ2 with an EBOPs penalty whose beta ramps up; every Pareto-optimal
                 (val_accuracy, val_acc_hi, ebops) checkpoint is saved. val_acc_hi = validation accuracy
                 over the windows with SNR >= 10 dB (the selection rule's second criterion).

Quantizers (hgq): weights / biases KBI SAT_SYM RND; activations KIF WRAP RND (integer bits fixed later by
trace_minmax over the training split, the Stage 0 flow); the INPUT quantizer is KIF SAT with TRN rounding
(i0 = 0: the model input is in [-1, 1)), heterogeneous per lane, so HGQ learns which int16 bits of each lane
matter. da4ml traces the model from a 16-bit input (inputs_kif = (1, 0, 15)), so the SAT / TRN input
quantizer is inside the generated RTL and the core's port is the shifted int16 window.
float64 everywhere (every published da4ml mismatch was float32 emulation of >= 23-bit accumulators).

  python ref/x310/train_x310.py --w 32 --mode float --arch 64 32 --out ref/runs/x310/float_w32_64_32
"""

import argparse
import json
import os
import sys
import time
from pathlib import Path

os.environ.setdefault('KERAS_BACKEND', 'jax')
import jax  # noqa: E402

jax.config.update('jax_enable_x64', True)
import keras  # noqa: E402
import numpy as np  # noqa: E402

keras.config.set_floatx('float64')

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'ref/x310'))
import x310_data as xd  # noqa: E402

N_CLASS = 4
SNR_HI = 10.0


def build(W, arch, mode, beta0=0.0, input_f=6, act_f=4, w_b0=8):
    if mode == 'float':
        layers = [keras.layers.InputLayer((2 * W,))]
        for i, n in enumerate(arch):
            layers.append(keras.layers.Dense(n, activation='relu', name=f'fc{i + 1}'))
        layers.append(keras.layers.Dense(N_CLASS, name='out'))
        return keras.Sequential(layers, name='x310_float')
    from hgq.config import LayerConfigScope, QuantizerConfig, QuantizerConfigScope
    from hgq.layers import QDense

    with (
        QuantizerConfigScope(place=('weight', 'bias'), overflow_mode='SAT_SYM', round_mode='RND', b0=w_b0),
        QuantizerConfigScope(place='datalane', overflow_mode='WRAP', round_mode='RND', f0=act_f),
        LayerConfigScope(enable_ebops=True, beta0=beta0),
    ):
        iq = QuantizerConfig('kif', 'datalane', overflow_mode='SAT', round_mode='TRN', i0=0, f0=input_f)
        layers = [keras.layers.InputLayer((2 * W,))]
        for i, n in enumerate(arch):
            layers.append(QDense(n, activation='relu', name=f'fc{i + 1}', **({'iq_conf': iq} if i == 0 else {})))
        layers.append(QDense(N_CLASS, name='out', **({'iq_conf': iq} if not arch else {})))
        return keras.Sequential(layers, name='x310_hgq')


def accuracy(model, x, y):
    return float(np.mean(np.argmax(np.asarray(model.predict(x, batch_size=16384, verbose=0)), 1) == y))


class ValHi(keras.callbacks.Callback):
    def __init__(self, x, y):
        super().__init__()
        self.x, self.y = x, y

    def on_epoch_end(self, epoch, logs=None):
        logs['val_acc_hi'] = accuracy(self.model, self.x, self.y)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--w', type=int, required=True, choices=xd.WS)
    ap.add_argument('--bfp', type=int, default=1, choices=(0, 1))
    ap.add_argument('--mode', choices=('float', 'hgq'), required=True)
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--arch', type=int, nargs='+', default=[64, 32])
    ap.add_argument('--epochs', type=int, default=200)
    ap.add_argument('--batch', type=int, default=2048)
    ap.add_argument('--lr', type=float, default=3e-3)
    ap.add_argument('--beta-start', type=float, default=1e-7)
    ap.add_argument('--beta-end', type=float, default=1e-5)
    ap.add_argument('--input-f', type=int, default=6, help='initial fractional bits of the input quantizer (of 15)')
    ap.add_argument('--act-f', type=int, default=4, help='initial fractional bits of the activation quantizers')
    ap.add_argument('--w-b0', type=int, default=8)
    ap.add_argument('--init-from', type=Path, default=None, help='hgq: copy kernels / biases from a float .keras of the same arch')
    ap.add_argument('--seed', type=int, default=1)
    a = ap.parse_args()

    keras.utils.set_random_seed(a.seed)
    a.out.mkdir(parents=True, exist_ok=True)
    tr, va = xd.load(a.w, 'train'), xd.load(a.w, 'val')
    xtr, ytr = xd.model_input(tr['x'], bool(a.bfp)), tr['y'].astype(np.int64)
    xva, yva = xd.model_input(va['x'], bool(a.bfp)), va['y'].astype(np.int64)
    hi = va['snr_db'] >= SNR_HI
    print(f'W={a.w} bfp={a.bfp}: {len(xtr)} train, {len(xva)} val ({hi.sum()} at SNR >= {SNR_HI} dB)', flush=True)

    steps = a.epochs * int(np.ceil(len(xtr) / a.batch))
    opt = keras.optimizers.Adam(keras.optimizers.schedules.CosineDecay(a.lr, steps, alpha=0.02))
    cbs = [ValHi(xva[hi], yva[hi])]
    if a.mode == 'float':
        model = build(a.w, a.arch, 'float')
        cbs.append(keras.callbacks.ModelCheckpoint(str(a.out / 'best.keras'), monitor='val_accuracy', save_best_only=True))
    else:
        from hgq.utils.sugar import BetaScheduler, FreeEBOPs, ParetoFront, PieceWiseSchedule

        model = build(a.w, a.arch, 'hgq', a.beta_start, a.input_f, a.act_f, a.w_b0)
        if a.init_from:
            src = keras.models.load_model(a.init_from)
            for layer in model.layers:
                ref = src.get_layer(layer.name)
                layer.kernel.assign(np.array(ref.kernel))
                layer.bias.assign(np.array(ref.bias))
            print(f'initialised kernels / biases from {a.init_from}', flush=True)
        warm = max(1, a.epochs // 20)
        cbs += [
            BetaScheduler(PieceWiseSchedule([(0, a.beta_start, 'constant'), (warm, a.beta_start, 'log'), (a.epochs, a.beta_end, 'constant')])),
            FreeEBOPs(),
            ParetoFront(a.out / 'pareto', ['val_accuracy', 'val_acc_hi', 'ebops'], [1, 1, -1],
                        fname_format='e{epoch:04d}_acc{val_accuracy:.5f}_hi{val_acc_hi:.5f}_ebops{ebops}.keras'),
        ]
    model.compile(opt, keras.losses.SparseCategoricalCrossentropy(from_logits=True), metrics=['accuracy'])
    model.summary()
    t0 = time.time()
    hist = model.fit(xtr, ytr, batch_size=a.batch, epochs=a.epochs, validation_data=(xva, yva), callbacks=cbs, verbose=2)
    hist = {k: [float(v) for v in vs] for k, vs in hist.history.items()}
    (a.out / 'train_log.json').write_text(json.dumps(dict(vars(a), out=str(a.out), wall_s=time.time() - t0, history=hist), indent=1, default=str))
    model.save(a.out / 'last.keras')


if __name__ == '__main__':
    main()
