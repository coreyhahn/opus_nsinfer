"""Train the NN decoder (d = 3: 24 detection events, d = 5: 120; -> 1 logical-flip logit) in float64 on JAX.

Training data are the multiset tables from qec_data.py: one row per distinct detection-event
vector with its shot counts n0 / n1. Binary cross-entropy against the soft label n1 / (n0 + n1)
with sample weight n0 + n1 is exactly the per-shot loss summed over the shots, so 10^8 shots
train as a few 10^5 rows. Each p's table is scaled by 1 / (shots * PyMatching LER) so every
noise strength contributes its logical errors on an equal footing.

d = 5 (--d 5): the tables are bit-packed (qec_data_d5.py) and too large to expand in memory, so
training batches are unpacked on the fly from a keras PyDataset (shuffled each epoch);
--steps-per-epoch caps an epoch to that many batches (validation runs at the end of each).

  --mode float : unquantized Keras baseline
  --mode hgq   : HGQ2 with an EBOPs penalty ramp; every Pareto-optimal (val_ler_ratio, ebops)
                 checkpoint is saved. val_ler_ratio = geometric mean over the validation p of
                 (NN logical errors / PyMatching logical errors) on the validation tables.
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

ROOT = Path(__file__).resolve().parents[2]
DDIR = ROOT / 'ref/data/qec'
ND = 24  # set from --d in main()
D = 3


def bits_of(keys, nd=None):
    nd = nd or ND
    if keys.ndim == 2:  # d = 5: packed uint8 rows
        return np.unpackbits(keys, axis=1, bitorder='little', count=nd).astype(np.float64)
    return ((keys[:, None] >> np.arange(nd, dtype=np.int64)) & 1).astype(np.float64)


def load(split, ptags):
    out = {}
    for t in ptags:
        z = np.load(DDIR / f'd{D}_{split}_p{t}.npz')
        out[t] = {k: z[k] for k in z.files}
    return out


class PackedBatches(keras.utils.PyDataset):
    """Shuffled batches of (unpacked bits, soft label, weight) from packed tables (d = 5)."""

    def __init__(self, keys, y, w, batch, steps=None, seed=0, **kw):
        super().__init__(**kw)
        self.keys, self.y, self.w, self.batch = keys, y, w, batch
        self.n_full = int(np.ceil(len(keys) / batch))
        self.steps = min(steps or self.n_full, self.n_full)
        self.rng = np.random.default_rng(seed)
        self.on_epoch_end()

    def __len__(self):
        return self.steps

    def on_epoch_end(self):
        self.perm = self.rng.permutation(len(self.keys))

    def __getitem__(self, i):
        j = self.perm[i * self.batch:(i + 1) * self.batch]
        return bits_of(self.keys[j]), self.y[j], self.w[j]


def build(arch, mode, beta0=0.0, input_f=0, dl_overflow='WRAP', w_b0=8):
    if mode == 'float':
        layers = [keras.layers.InputLayer((ND,))]
        for i, n in enumerate(arch):
            layers.append(keras.layers.Dense(n, activation='relu', name=f'fc{i + 1}'))
        layers.append(keras.layers.Dense(1, name='out'))
        return keras.Sequential(layers, name='qec_float')
    from hgq.config import LayerConfigScope, QuantizerConfigScope
    from hgq.layers import QDense

    with (
        QuantizerConfigScope(place=('weight', 'bias'), overflow_mode='SAT_SYM', round_mode='RND', b0=w_b0),
        QuantizerConfigScope(place='datalane', overflow_mode=dl_overflow, round_mode='RND', f0=input_f),
        LayerConfigScope(enable_ebops=True, beta0=beta0),
    ):
        layers = [keras.layers.InputLayer((ND,))]
        for i, n in enumerate(arch):
            layers.append(QDense(n, activation='relu', name=f'fc{i + 1}'))
        layers.append(QDense(1, name='out'))
        return keras.Sequential(layers, name='qec_hgq')


def errors(model, tab):
    """NN logical errors on one table (decision = logit > 0) and PyMatching's."""
    z = np.asarray(model.predict(bits_of(tab['keys']), batch_size=65536, verbose=0))[:, 0]
    dec = z > 0
    return int(np.where(dec, tab['n0'], tab['n1']).sum()), int(np.where(tab['pm'] == 1, tab['n0'], tab['n1']).sum())


class ValLER(keras.callbacks.Callback):
    def __init__(self, val):
        super().__init__()
        self.val = val

    def on_epoch_end(self, epoch, logs=None):
        r = {}
        for t, tab in self.val.items():
            e_nn, e_pm = errors(self.model, tab)
            r[t] = e_nn / max(e_pm, 1)
        logs['val_ler_ratio'] = float(np.exp(np.mean(np.log(list(r.values())))))
        logs['val_ler_ratio_max'] = float(max(r.values()))
        print(' val NN/PM ' + ' '.join(f'{t}:{v:.3f}' for t, v in r.items()), flush=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--d', type=int, choices=(3, 5), default=3)
    ap.add_argument('--steps-per-epoch', type=int, default=0, help='d = 5: batches per epoch (0 = all rows)')
    ap.add_argument('--mode', choices=('float', 'hgq'), required=True)
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--arch', type=int, nargs='+', default=[64, 32])
    ap.add_argument('--train-p', nargs='+', default=['1e-3', '2e-3', '3e-3', '5e-3', '7e-3', '10e-3'])
    ap.add_argument('--val-p', nargs='+', default=['1e-3', '2e-3', '3e-3', '5e-3', '7e-3', '10e-3'])
    ap.add_argument('--epochs', type=int, default=200)
    ap.add_argument('--batch', type=int, default=4096)
    ap.add_argument('--lr', type=float, default=3e-3)
    ap.add_argument('--beta-start', type=float, default=1e-8)
    ap.add_argument('--beta-end', type=float, default=1e-5)
    ap.add_argument('--input-f', type=int, default=0, help='initial fractional bits f0 of every datalane (activation) quantizer')
    ap.add_argument('--seed', type=int, default=1)
    ap.add_argument('--dl-overflow', default='WRAP', choices=('WRAP', 'SAT', 'SAT_SYM'), help='datalane overflow mode')
    ap.add_argument('--init-from', type=Path, default=None, help='hgq: start from a float .keras of the same arch (kernel / bias copied by layer name)')
    ap.add_argument('--resume', type=Path, default=None, help='hgq: continue from an HGQ .keras (weights and bit widths); --arch etc. are taken from it')
    ap.add_argument('--w-b0', type=int, default=8, help='initial bits b0 of weight / bias quantizers (HGQ2 default 8)')
    a = ap.parse_args()

    global ND, D
    D, ND = a.d, (24 if a.d == 3 else 120)
    keras.utils.set_random_seed(a.seed)
    a.out.mkdir(parents=True, exist_ok=True)
    meta_d = json.loads((ROOT / ('ref/golden/qec_d3_test.json' if D == 3 else 'ref/golden/qec_d5_data.json')).read_text())['p']
    tr = load('train', a.train_p)
    val = load('val', a.val_p)
    xs, ys, ws = [], [], []
    for t, tab in tr.items():
        n = tab['n0'] + tab['n1']
        scale = 1.0 / (meta_d[t]['train']['pm_errors'])
        xs.append(bits_of(tab['keys']) if D == 3 else tab['keys']); ys.append(tab['n1'] / n); ws.append(n * scale)
    x = np.concatenate(xs); y = np.concatenate(ys)[:, None]; w = np.concatenate(ws)
    w = w * (len(w) / w.sum())
    print(f'{len(x)} training rows from {len(tr)} noise strengths', flush=True)
    if D == 5:
        data = PackedBatches(x, y, w, a.batch, a.steps_per_epoch or None, a.seed, workers=8, use_multiprocessing=False)
        steps = a.epochs * len(data)
    else:
        steps = a.epochs * int(np.ceil(len(x) / a.batch))
    opt = keras.optimizers.Adam(keras.optimizers.schedules.CosineDecay(a.lr, steps, alpha=0.02))
    cbs = [ValLER(val)]
    if a.mode == 'float':
        model = build(a.arch, 'float')
        cbs.append(keras.callbacks.ModelCheckpoint(str(a.out / 'best.keras'), monitor='val_ler_ratio', mode='min', save_best_only=True))
    else:
        from hgq.utils.sugar import BetaScheduler, FreeEBOPs, ParetoFront, PieceWiseSchedule

        if a.resume:
            import hgq  # noqa: F401  (registers QDense)

            model = keras.models.load_model(a.resume)
            print(f'resumed from {a.resume}', flush=True)
        else:
            model = build(a.arch, 'hgq', a.beta_start, a.input_f, a.dl_overflow, a.w_b0)
        if a.init_from:
            src = keras.models.load_model(a.init_from)
            for layer in model.layers:
                ref = src.get_layer(layer.name)
                layer.kernel.assign(np.array(ref.kernel))
                layer.bias.assign(np.array(ref.bias))
            print(f'initialised kernels / biases from {a.init_from}', flush=True)
        warm = max(1, a.epochs // 10)
        cbs += [
            BetaScheduler(PieceWiseSchedule([(0, a.beta_start, 'constant'), (warm, a.beta_start, 'log'), (a.epochs, a.beta_end, 'constant')])),
            FreeEBOPs(),
            ParetoFront(a.out / 'pareto', ['val_ler_ratio', 'ebops'], [-1, -1], fname_format='e{epoch:04d}_r{val_ler_ratio:.5f}_ebops{ebops}.keras'),
        ]
    model.compile(opt, keras.losses.BinaryCrossentropy(from_logits=True))
    model.summary()
    t0 = time.time()
    if D == 5:
        hist = model.fit(data, epochs=a.epochs, callbacks=cbs, verbose=2)
    else:
        hist = model.fit(x, y, sample_weight=w, batch_size=a.batch, epochs=a.epochs, callbacks=cbs, verbose=2, shuffle=True)
    hist = {k: [float(v) for v in vs] for k, vs in hist.history.items()}
    (a.out / 'train_log.json').write_text(json.dumps(dict(vars(a), out=str(a.out), wall_s=time.time() - t0, history=hist), indent=1, default=str))
    model.save(a.out / 'last.keras')


if __name__ == '__main__':
    main()
