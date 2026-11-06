"""Freeze the chosen d = 3 HGQ2 decoder and export it through da4ml (the Stage 0 flow, unchanged).

  1. trace_minmax over the calibration set (every distinct training detection-event vector, all p)
     fixes the WRAP integer bits; the calibrated model is saved as ref/golden/qec_d3_hgq.keras.
  2. Golden vectors: every distinct detection-event vector in the held-out test multisets (all p,
     deduplicated) plus the all-zero vector, with the Keras float64 logit as a two's-complement lane
     and the decision bit (logit > 0 -> flip). ref/golden/qec_d3_golden.{npz,json},
     qec_d3_golden_{in,out,dec}.hex. Logical error rates per p for the quantized NN and for
     PyMatching on the same test shots go in the json.
  3. Exhaustive set (--exhaustive): all 2^24 inputs and their Keras logits as hex under .scratch/
     (170 MB, not committed; SHA-256 recorded) for the exhaustive Verilator run.
  4. RTL: one da4ml Verilog project per latency cutoff, rtl/gen/qec_d3_lc<cutoff>/.
"""

import argparse
import json
import os
import shutil
import sys
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

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'ref'))
from export_jsc import lanes_hex, sha256, to_lanes  # noqa: E402

ND = 24
NAME = 'qec_d3'


def bits_of(keys):
    return ((keys[:, None] >> np.arange(ND, dtype=np.int64)) & 1).astype(np.float64)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--model', type=Path)
    ap.add_argument('--golden', type=Path, default=ROOT / 'ref/golden')
    ap.add_argument('--rtl-root', type=Path, default=ROOT / 'rtl/gen')
    ap.add_argument('--cutoffs', type=float, nargs='+', default=[])
    ap.add_argument('--exhaustive', action='store_true')
    ap.add_argument('--rtl-only', action='store_true', help='emit RTL / exhaustive set from the frozen model; never rewrite golden files')
    a = ap.parse_args()
    g = a.golden
    tmeta = json.loads((g / 'qec_d3_test.json').read_text())
    assert sha256(g / 'qec_d3_test.npz') == tmeta['test_sha256'], 'qec_d3_test.npz does not match its json'

    if a.rtl_only:
        meta = json.loads((g / f'{NAME}_golden.json').read_text())
        for p, h in meta['sha256'].items():
            assert sha256(g / p) == h, f'{p} does not match {NAME}_golden.json'
        model = keras.models.load_model(g / f'{NAME}_hgq.keras')
        sol = comb_trace(*trace_model(model))
        k_in, k_out = get_io_kifs(sol)
        z = np.load(g / f'{NAME}_golden.npz')
        assert np.array_equal(k_in, z['in_kif']) and np.array_equal(k_out, z['out_kif']), 'traced I/O format differs from golden'
    else:
        model = keras.models.load_model(a.model)
        cal = np.unique(np.concatenate([np.load(ROOT / f'ref/data/qec/d3_train_p{t}.npz')['keys'] for t in tmeta['p']]))
        ebops = int(trace_minmax(model, bits_of(cal), batch_size=65536))
        model.save(g / f'{NAME}_hgq.keras')

        test = np.load(g / 'qec_d3_test.npz')
        keys = np.unique(np.concatenate([[0]] + [test[f'{t}_keys'] for t in tmeta['p']]))
        x = bits_of(keys)
        logit = np.asarray(model.predict(x, batch_size=65536, verbose=0), np.float64)
        xq = np.asarray(ops.convert_to_numpy(model.layers[0].iq(x, training=False)), np.float64)
        # HGQ2 learns the input quantizer too: a detector may be pruned (its 1 maps to 0) or carry a
        # negative fractional bit (its 1 maps to 2). Each detector is still a 0 / v_j switch, so the
        # RTL maps detection bit j to lane value v_j (rtl/qec_d3_in_map.svh) and its port stays the
        # 24 raw detection bits.
        v = np.asarray(ops.convert_to_numpy(model.layers[0].iq(np.ones((1, ND)), training=False)), np.float64)[0]
        assert np.array_equal(xq, x * v), 'input quantizer is not a per-detector 0 / v_j switch'
        sol = comb_trace(*trace_model(model))
        k_in, k_out = get_io_kifs(sol)
        n_interp_mis = int(np.sum(np.any(sol.predict(x) != logit, axis=1)))
        dec = (logit[:, 0] > 0).astype(np.uint8)

        ler = {}
        for t in tmeta['p']:
            tk, n0, n1, pm = (test[f'{t}_{f}'] for f in ('keys', 'n0', 'n1', 'pm'))
            d_t = dec[np.searchsorted(keys, tk)]
            shots = int(n0.sum() + n1.sum())
            e_nn = int(np.where(d_t == 1, n0, n1).sum())
            e_pm = int(np.where(pm == 1, n0, n1).sum())
            ler[t] = {'p': tmeta['p'][t]['p'], 'shots': shots, 'nn_errors': e_nn, 'pm_errors': e_pm,
                      'nn_ler': e_nn / shots, 'pm_ler': e_pm / shots, 'nn_over_pm': e_nn / e_pm,
                      'nn_ler_per_round': (1 - (1 - 2 * e_nn / shots) ** (1 / 3)) / 2,
                      'pm_ler_per_round': (1 - (1 - 2 * e_pm / shots) ** (1 / 3)) / 2,
                      'disagree_shots': int(np.where(d_t != pm, n0 + n1, 0).sum())}

        in_lanes, in_w = to_lanes(xq, k_in)
        v_lane, _ = to_lanes(v[None], k_in)
        write_in_map(v_lane[0], in_w, a.rtl_root.parent / f'{NAME}_in_map.svh')
        out_lanes, out_w = to_lanes(logit, k_out)
        np.savez_compressed(g / f'{NAME}_golden.npz', keys=keys, in_lanes=in_lanes.astype(np.uint32),
                            out_lanes=out_lanes.astype(np.uint32), dec=dec, in_kif=k_in, out_kif=k_out)
        (g / f'{NAME}_golden_in.hex').write_text(''.join(f'{k:06x}\n' for k in keys.tolist()))  # raw detection bits, detector j at bit j
        (g / f'{NAME}_golden_out.hex').write_text('\n'.join(lanes_hex(out_lanes, out_w)) + '\n')
        (g / f'{NAME}_golden_dec.hex').write_text(''.join(f'{v:x}\n' for v in dec))
        meta = {
            'model_source': str(a.model), 'test_source': 'ref/golden/qec_d3_test.npz', 'test_sha256': tmeta['test_sha256'],
            'n_vectors': int(len(keys)), 'vectors': 'distinct detection-event vectors of the test multisets (all p) + all-zero',
            'decision_rule': 'flip = logit > 0 (strict)', 'ebops': ebops,
            'det_bits': ND, 'in_width_bits': int(in_w.sum()), 'out_width_bits': int(out_w.sum()),
            'in_lane_widths': in_w.tolist(), 'in_value_of_one': v.tolist(), 'pruned_detectors': [j for j in range(ND) if v[j] == 0],
            'in_kif': k_in.tolist(), 'out_kif': k_out.tolist(),
            'da4ml_comb_cost_lut_est': float(sol.cost), 'da4ml_comb_latency': [float(v) for v in sol.latency],
            'keras_vs_dais_interp_mismatching_vectors': n_interp_mis, 'ler': ler,
            'sha256': {p: sha256(g / p) for p in (f'{NAME}_golden.npz', f'{NAME}_golden_in.hex', f'{NAME}_golden_out.hex',
                                                    f'{NAME}_golden_dec.hex', f'{NAME}_hgq.keras')},
        }
        (g / f'{NAME}_golden.json').write_text(json.dumps(meta, indent=1) + '\n')
        print(json.dumps({k: v for k, v in meta.items() if k not in ('in_kif', 'out_kif')}, indent=1))

    if a.exhaustive:
        exhaustive(model, k_out, g)
    for lc in a.cutoffs:
        name = f'{NAME}_lc{lc:g}'
        path = a.rtl_root / name
        if path.exists():
            shutil.rmtree(path)
        rtl = RTLModel(sol, NAME, path, latency_cutoff=lc, part_name='xcvu9p-fsgd2104-2L-e', clock_period=3.333)
        rtl.write(metadata={'model_sha256': meta['sha256'][f'{NAME}_hgq.keras'], 'golden_sha256_in_hex': meta['sha256'][f'{NAME}_golden_in.hex']})
        md = json.loads((path / 'metadata.json').read_text())
        print(f'{name}: {md["latency"]} stages, est {md["cost"]:.0f} LUT, {md["reg_bits"]} FF')


def write_in_map(v_lane, in_w, path):
    off = np.concatenate([[0], np.cumsum(in_w)[:-1]])
    lines = [f'// Generated by ref/qec/export_qec.py from the frozen model. Do not edit.',
             f'// Detection bit j drives core input lane j (offset LANE_OFF[j], LANE_W[j] bits) with 0 or LANE_ONE[j].',
             f'localparam int N_DET = {ND};', f'localparam int CORE_IN_W = {int(in_w.sum())};',
             "localparam int LANE_OFF [N_DET] = '{" + ', '.join(str(int(o)) for o in off) + '};',
             "localparam int LANE_W   [N_DET] = '{" + ', '.join(str(int(w)) for w in in_w) + '};',
             "localparam int LANE_ONE [N_DET] = '{" + ', '.join(str(int(o)) for o in v_lane) + '};', '']
    path.write_text('\n'.join(lines))


def exhaustive(model, k_out, g):
    """All 2^24 inputs (input i = detection-event vector with key i) -> Keras logit lanes, as hex."""
    sc = ROOT / '.scratch'
    w = (k_out.sum(0)).astype(np.int64)
    nhex = (int(w.sum()) + 3) // 4
    with open(sc / f'{NAME}_exh_in.hex', 'w') as fi, open(sc / f'{NAME}_exh_out.hex', 'w') as fo:
        for c0 in range(0, 1 << ND, 1 << 20):
            keys = np.arange(c0, c0 + (1 << 20), dtype=np.int64)
            logit = np.asarray(model.predict(bits_of(keys), batch_size=1 << 18, verbose=0), np.float64)
            lanes, lw = to_lanes(logit, k_out)
            fi.write(''.join(f'{k:06x}\n' for k in keys.tolist()))
            fo.write('\n'.join(lanes_hex(lanes, lw)) + '\n')
    rep = {'n': 1 << ND, 'model_sha256': sha256(g / f'{NAME}_hgq.keras'),
           'in_sha256': sha256(sc / f'{NAME}_exh_in.hex'), 'out_sha256': sha256(sc / f'{NAME}_exh_out.hex'),
           'out_hex_digits': nhex}
    (g / f'{NAME}_exhaustive.json').write_text(json.dumps(rep, indent=1) + '\n')
    print(json.dumps(rep, indent=1))


if __name__ == '__main__':
    main()
