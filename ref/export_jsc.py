"""Freeze a trained HGQ2 JSC model and export it through da4ml.

Steps (each writes into --golden / --rtl-root):
  1. trace_minmax over the calibration set (the frozen training split) to fix
     the WRAP integer bits; save the calibrated model (`jsc_hgq.keras`).
  2. Golden vectors over the FULL test set: the input quantizer's output (what
     the RTL sees on its pins) and the Keras float64 logits, both converted to
     the RTL's per-lane two's-complement integers. Saved as `jsc_golden.npz`
     with SHA-256 in `jsc_golden.json`; `jsc_golden_{in,out}.hex` (one vector
     per line, lane 0 at the LSB) are what the Verilator testbench reads.
  3. Pre-RTL checks: Keras vs da4ml's DAIS interpreter on the traced
     CombLogic, bit for bit; accuracy of the quantized model.
  4. RTL: one da4ml Verilog project per latency cutoff under
     rtl/gen/jsc_lc<cutoff>/ (pipeline depth follows from the cutoff).
"""

import argparse
import hashlib
import json
import os
import shutil
from pathlib import Path

os.environ.setdefault('KERAS_BACKEND', 'jax')
import jax  # noqa: E402

jax.config.update('jax_enable_x64', True)
import keras  # noqa: E402
import numpy as np  # noqa: E402
from keras import ops  # noqa: E402

keras.config.set_floatx('float64')

from da4ml.codegen import RTLModel  # noqa: E402
from da4ml.codegen.rtl.rtl_model import get_io_kifs  # noqa: E402
from da4ml.converter import trace_model  # noqa: E402
from da4ml.trace import comb_trace  # noqa: E402
from hgq.utils import trace_minmax  # noqa: E402

HERE = Path(__file__).parent
ROOT = HERE.parent


def sha256(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def to_lanes(x: np.ndarray, kifs: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    """Float fixed-point values -> unsigned lane integers (two's complement)."""
    k, i, f = (kifs[j].astype(np.int64) for j in range(3))
    w = k + i + f
    assert w.max() <= 32, 'lane wider than the uint32 golden store'
    q = x * 2.0**f
    assert np.all(q == np.round(q)), 'value not on the lane grid'
    q = q.astype(np.int64)
    return np.mod(q, 1 << w), w


def lanes_hex(lanes: np.ndarray, widths: np.ndarray) -> list[str]:
    total = int(widths.sum())
    nhex = (total + 3) // 4
    offs = np.concatenate([[0], np.cumsum(widths)[:-1]])
    out = []
    for row in lanes:
        v = 0
        for val, off in zip(row.tolist(), offs.tolist()):
            v |= int(val) << int(off)
        out.append(f'{v:0{nhex}x}')
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--model', type=Path, required=True)
    ap.add_argument('--golden', type=Path, default=ROOT / 'ref/golden')
    ap.add_argument('--rtl-root', type=Path, default=ROOT / 'rtl/gen')
    ap.add_argument('--cutoffs', type=float, nargs='+', default=[])
    ap.add_argument('--rtl-only', action='store_true',
                    help='emit RTL from the frozen calibrated model in --golden; never rewrite golden files')
    a = ap.parse_args()
    if a.rtl_only:
        return rtl_only(a)

    d = np.load(HERE / 'data/jsc_split.npz')
    a.golden.mkdir(parents=True, exist_ok=True)

    model = keras.models.load_model(a.model)
    ebops = int(trace_minmax(model, d['x_train'], batch_size=16384))
    model.save(a.golden / 'jsc_hgq.keras')

    x = d['x_test']
    y = d['y_test']
    logits = np.asarray(model.predict(x, batch_size=16384, verbose=0), np.float64)
    xq = np.asarray(ops.convert_to_numpy(model.layers[0].iq(x, training=False)), np.float64)

    inp, out = trace_model(model)
    sol = comb_trace(inp, out)
    k_in, k_out = get_io_kifs(sol)

    # Pre-RTL equivalence: DAIS interpreter on the traced graph vs Keras.
    interp = sol.predict(xq)
    n_interp_mis = int(np.sum(np.any(interp != logits, axis=1)))

    in_lanes, in_w = to_lanes(xq, k_in)
    out_lanes, out_w = to_lanes(logits, k_out)
    # Integer lanes only; float values are lane * 2**-f (sign from k). x_test
    # itself is reproducible from the frozen split (hash in jsc_split_meta.json).
    np.savez_compressed(a.golden / 'jsc_golden.npz', y=y.astype(np.int8),
                        in_lanes=in_lanes.astype(np.uint32), out_lanes=out_lanes.astype(np.uint32), in_kif=k_in, out_kif=k_out)
    (a.golden / 'jsc_golden_in.hex').write_text('\n'.join(lanes_hex(in_lanes, in_w)) + '\n')
    (a.golden / 'jsc_golden_out.hex').write_text('\n'.join(lanes_hex(out_lanes, out_w)) + '\n')

    acc = float(np.mean(np.argmax(logits, 1) == y))
    meta = {
        'model_source': str(a.model),
        'n_test': int(len(x)),
        'test_accuracy_quantized': acc,
        'ebops': ebops,
        'in_width_bits': int(in_w.sum()),
        'out_width_bits': int(out_w.sum()),
        'in_lane_widths': in_w.tolist(),
        'out_lane_widths': out_w.tolist(),
        'in_kif': k_in.tolist(),
        'out_kif': k_out.tolist(),
        'out_lsb_exponent': (-k_out[2]).tolist(),
        'da4ml_comb_cost_lut_est': float(sol.cost),
        'da4ml_comb_latency': [float(v) for v in sol.latency],
        'keras_vs_dais_interp_mismatching_vectors': n_interp_mis,
        'sha256': {p: sha256(a.golden / p) for p in ('jsc_golden.npz', 'jsc_golden_in.hex', 'jsc_golden_out.hex', 'jsc_hgq.keras')},
    }
    (a.golden / 'jsc_golden.json').write_text(json.dumps(meta, indent=1))
    print(json.dumps({k: v for k, v in meta.items() if k not in ('in_kif', 'out_kif')}, indent=1))

    write_rtl(sol, a.cutoffs, a.rtl_root, meta['sha256'])


def rtl_only(a):
    meta = json.loads((a.golden / 'jsc_golden.json').read_text())
    for p, h in meta['sha256'].items():
        assert sha256(a.golden / p) == h, f'{p} does not match jsc_golden.json'
    model = keras.models.load_model(a.golden / 'jsc_hgq.keras')
    inp, out = trace_model(model)
    sol = comb_trace(inp, out)
    g = np.load(a.golden / 'jsc_golden.npz')
    k_in, k_out = get_io_kifs(sol)
    assert np.array_equal(k_in, g['in_kif']) and np.array_equal(k_out, g['out_kif']), 'traced I/O format differs from golden'
    write_rtl(sol, a.cutoffs, a.rtl_root, meta['sha256'])


def write_rtl(sol, cutoffs, rtl_root, hashes):
    for lc in cutoffs:
        name = f'jsc_lc{lc:g}'
        path = rtl_root / name
        if path.exists():
            shutil.rmtree(path)
        rtl = RTLModel(sol, 'jsc', path, latency_cutoff=lc, part_name='xczu9eg-ffvb1156-2-i', clock_period=5)
        rtl.write(metadata={'model_sha256': hashes['jsc_hgq.keras'], 'golden_sha256_in_hex': hashes['jsc_golden_in.hex']})
        md = json.loads((path / 'metadata.json').read_text())
        print(f'{name}: {md["latency"]} stages, est {md["cost"]:.0f} LUT, {md["reg_bits"]} FF')


if __name__ == '__main__':
    main()
