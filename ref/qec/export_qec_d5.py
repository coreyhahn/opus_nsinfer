"""Freeze the chosen d = 5 HGQ2 decoder and export it through da4ml (export_qec.py, adapted to 120 detectors).

The d = 5 tables are bit-packed (qec_data_d5.py: detector j = bit j % 8 of byte j // 8, 15 bytes), and
the full test set (~1.9e7 distinct vectors) is too large to commit, so the golden data has two tiers:
  1. trace_minmax over the calibration set (every distinct d = 5 training vector, all p, in chunks)
     fixes the WRAP integer bits; the calibrated model is saved as ref/golden/qec_d5_hgq.keras.
  2. Full set: every distinct vector of the held-out test multisets (all p) plus the all-zero vector,
     with the Keras float64 logit lane and the decision (logit > 0 -> flip), as hex under .scratch/
     (qec_d5_full_{in,out,dec}.hex, not committed; SHA-256 in ref/golden/qec_d5_full.json). The
     logical error rates per p of the quantized NN and of PyMatching on the same test shots are
     computed over this set and recorded in qec_d5_golden.json.
  3. Golden set (committed): N_GOLDEN vectors drawn from the full set with a fixed seed, an equal share
     from each p's test keys, all-zero vector first: ref/golden/qec_d5_golden.{npz,json},
     qec_d5_golden_{in,out,dec}.hex (in = 30 hex digits, detector j at bit j). These are the
     silicon shots (tb/s3_make_mem.py --d 5) and the Verilator 4x2 set; the full set is run once.
  4. RTL: one da4ml Verilog project per latency cutoff, rtl/gen/qec_d5_lc<cutoff>/, and the input
     lane map rtl/qec_d5_in_map.svh (included by rtl/d5/qec_d5_top.sv). With --bcast-ratio R, also
     rtl/gen/qec_d5_lc<cutoff>bc/: the same core with a pure broadcast register before every stage whose
     output is more than R times its input (synth/scripts/add_bcast.py; PLAN.md D-S4-SEL, 2026-10-28).

  python ref/qec/export_qec_d5.py --model ref/runs/qec/chosen_d5.keras --cutoffs 3 --bcast-ratio 1.3
  python ref/qec/export_qec_d5.py --rtl-only --rtl-root .scratch/x/gen --cutoffs 5   # reproduce RTL
"""

import argparse
import json
import os
import shutil
import subprocess
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
from export_jsc import sha256, to_lanes  # noqa: E402

ND = 120
NB = 15
NAME = 'qec_d5'
N_GOLDEN = 131072
SEED = 20261023
CHUNK = 1 << 19


def bits_of(keys):
    return np.unpackbits(keys, axis=1, bitorder='little', count=ND).astype(np.float64)


def void(k):
    return np.ascontiguousarray(k).view(np.dtype((np.void, NB)))[:, 0]


def keys_hex(k):
    """Packed keys -> one 30-digit hex line each (bytes reversed: detector j at integer bit j)."""
    s = np.ascontiguousarray(k[:, ::-1]).tobytes().hex()
    return ''.join(s[i:i + 2 * NB] + '\n' for i in range(0, len(s), 2 * NB))


def lane_hex(lanes, w):
    assert lanes.shape[1] == 1, 'one output lane expected'
    nhex = (int(w.sum()) + 3) // 4
    return ''.join(f'{v:0{nhex}x}\n' for v in lanes[:, 0].tolist())


def predict(model, keys):
    return np.concatenate([np.asarray(model.predict(bits_of(keys[i:i + CHUNK]), batch_size=65536, verbose=0), np.float64)
                           for i in range(0, len(keys), CHUNK)])


def input_wrap(model):
    """da4ml traces the network input only in WRAP. Inputs are 0/1 and the first quantizer's traced
    i covers 1 (checked below as the 0/v_j switch), so SAT and WRAP agree there: set it to WRAP."""
    q = model.layers[0].iq.quantizer
    if q.overflow_mode != 'WRAP':
        print(f'input quantizer {q.overflow_mode} -> WRAP (0/1 inputs)', flush=True)
        q._overflow_mode = 'WRAP'
    return model


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--model', type=Path)
    ap.add_argument('--golden', type=Path, default=ROOT / 'ref/golden')
    ap.add_argument('--rtl-root', type=Path, default=ROOT / 'rtl/gen')
    ap.add_argument('--cutoffs', type=float, nargs='+', default=[])
    ap.add_argument('--bcast-ratio', type=float, default=0, help='also write <name>bc with broadcast registers (0 = off)')
    ap.add_argument('--rtl-only', action='store_true', help='emit RTL from the frozen model; never rewrite golden files')
    a = ap.parse_args()
    g = a.golden
    dmeta = json.loads((g / 'qec_d5_data.json').read_text())
    ptags = list(dmeta['p'])

    if a.rtl_only:
        meta = json.loads((g / f'{NAME}_golden.json').read_text())
        for p, h in meta['sha256'].items():
            assert sha256(g / p) == h, f'{p} does not match {NAME}_golden.json'
        model = input_wrap(keras.models.load_model(g / f'{NAME}_hgq.keras'))
        sol = comb_trace(*trace_model(model))
        k_in, k_out = get_io_kifs(sol)
        z = np.load(g / f'{NAME}_golden.npz')
        assert np.array_equal(k_in, z['in_kif']) and np.array_equal(k_out, z['out_kif']), 'traced I/O format differs from golden'
    else:
        model = input_wrap(keras.models.load_model(a.model))
        # 1. calibration: all distinct training vectors of every p, chunked (reset only before the first chunk)
        n_cal = 0
        for i, t in enumerate(ptags):
            f = ROOT / dmeta['p'][t]['train']['file']
            assert sha256(f) == dmeta['p'][t]['train']['sha256'], f'{f} does not match qec_d5_data.json'
            k = np.load(f)['keys']
            for j in range(0, len(k), CHUNK):
                ebops = int(trace_minmax(model, bits_of(k[j:j + CHUNK]), reset=(i == 0 and j == 0), batch_size=65536))
            n_cal += len(k)
            print(f'calibrated on {t}: {len(k)} rows, EBOPs {ebops}', flush=True)
        model.save(g / f'{NAME}_hgq.keras')

        # 2. full set: union of the test keys (all p) + all-zero, sorted by packed bytes
        test = {}
        for t in ptags:
            f = ROOT / dmeta['p'][t]['test']['file']
            assert sha256(f) == dmeta['p'][t]['test']['sha256'], f'{f} does not match qec_d5_data.json'
            test[t] = dict(np.load(f))
        allk = np.concatenate([np.zeros((1, NB), np.uint8)] + [test[t]['keys'] for t in ptags])
        u, inv = np.unique(void(allk), return_inverse=True)
        keys = u.view(np.uint8).reshape(len(u), NB)
        assert not keys[0].any(), 'all-zero vector must sort first'
        idx_of, o = {}, 1
        for t in ptags:
            n = len(test[t]['keys'])
            idx_of[t] = inv[o:o + n]
            o += n
        logit = predict(model, keys)
        dec = (logit[:, 0] > 0).astype(np.uint8)
        print(f'full set: {len(keys)} distinct vectors', flush=True)

        ler = {}
        for t in ptags:
            n0, n1, pm = test[t]['n0'], test[t]['n1'], test[t]['pm']
            d_t = dec[idx_of[t]]
            shots = int(n0.sum() + n1.sum())
            e_nn = int(np.where(d_t == 1, n0, n1).sum())
            e_pm = int(np.where(pm == 1, n0, n1).sum())
            ler[t] = {'p': dmeta['p'][t]['p'], 'shots': shots, 'nn_errors': e_nn, 'pm_errors': e_pm,
                      'nn_ler': e_nn / shots, 'pm_ler': e_pm / shots, 'nn_over_pm': e_nn / e_pm,
                      'nn_ler_per_round': (1 - (1 - 2 * e_nn / shots) ** (1 / 5)) / 2,
                      'pm_ler_per_round': (1 - (1 - 2 * e_pm / shots) ** (1 / 5)) / 2,
                      'disagree_shots': int(np.where(d_t != pm, n0 + n1, 0).sum())}
            print(t, json.dumps(ler[t]), flush=True)

        # 3. golden subset: equal share per p (seeded), all-zero first, then shuffled
        rng = np.random.default_rng(SEED)
        share = (N_GOLDEN - 1) // len(ptags)
        pick = [np.zeros(1, np.int64)] + [rng.choice(idx_of[t], share, replace=False) for t in ptags]
        gi = np.unique(np.concatenate(pick))
        if len(gi) < N_GOLDEN:
            rest = np.setdiff1d(np.arange(len(keys)), gi)
            gi = np.union1d(gi, rng.choice(rest, N_GOLDEN - len(gi), replace=False))
        gi = np.concatenate([[0], rng.permutation(gi[gi != 0])])
        assert len(gi) == N_GOLDEN == len(np.unique(gi))

        sol = comb_trace(*trace_model(model))
        k_in, k_out = get_io_kifs(sol)
        xg = bits_of(keys[gi])
        xq = np.asarray(ops.convert_to_numpy(model.layers[0].iq(xg, training=False)), np.float64)
        # as at d = 3: each detector is a 0 / v_j switch (pruned: v_j = 0; negative f: v_j = 2^k)
        v = np.asarray(ops.convert_to_numpy(model.layers[0].iq(np.ones((1, ND)), training=False)), np.float64)[0]
        assert np.array_equal(xq, xg * v), 'input quantizer is not a per-detector 0 / v_j switch'
        n_interp_mis = int(np.sum(np.any(sol.predict(xg) != logit[gi], axis=1)))

        in_lanes, in_w = to_lanes(xq, k_in)
        v_lane, _ = to_lanes(v[None], k_in)
        write_in_map(v_lane[0], in_w, a.rtl_root.parent / f'{NAME}_in_map.svh')
        out_lanes, out_w = to_lanes(logit, k_out)

        sc = ROOT / '.scratch'
        sc.mkdir(exist_ok=True)
        (sc / f'{NAME}_full_in.hex').write_text(keys_hex(keys))
        (sc / f'{NAME}_full_out.hex').write_text(lane_hex(out_lanes, out_w))
        (sc / f'{NAME}_full_dec.hex').write_text(''.join(f'{x:x}\n' for x in dec))
        full = {'n_vectors': int(len(keys)), 'vectors': 'distinct detection-event vectors of the d = 5 test multisets (all p) + all-zero, sorted by packed bytes',
                'model_sha256': sha256(g / f'{NAME}_hgq.keras'),
                'sha256': {f'.scratch/{NAME}_full_{s}.hex': sha256(sc / f'{NAME}_full_{s}.hex') for s in ('in', 'out', 'dec')}}
        (g / f'{NAME}_full.json').write_text(json.dumps(full, indent=1) + '\n')

        np.savez_compressed(g / f'{NAME}_golden.npz', keys=keys[gi], full_index=gi, in_lanes=in_lanes.astype(np.uint32),
                            out_lanes=out_lanes[gi].astype(np.uint32), dec=dec[gi], in_kif=k_in, out_kif=k_out)
        (g / f'{NAME}_golden_in.hex').write_text(keys_hex(keys[gi]))
        (g / f'{NAME}_golden_out.hex').write_text(lane_hex(out_lanes[gi], out_w))
        (g / f'{NAME}_golden_dec.hex').write_text(''.join(f'{x:x}\n' for x in dec[gi]))
        meta = {
            'model_source': str(a.model), 'data': 'ref/golden/qec_d5_data.json (test files checked by sha256)',
            'n_vectors': N_GOLDEN, 'vectors': f'{N_GOLDEN} of the full set ({NAME}_full.json): all-zero first, then {share} '
                                              f'per p drawn with numpy default_rng({SEED}) (topped up uniformly), shuffled',
            'n_full': int(len(keys)), 'decision_rule': 'flip = logit > 0 (strict)', 'ebops': ebops, 'calibration_rows': n_cal,
            'det_bits': ND, 'in_width_bits': int(in_w.sum()), 'out_width_bits': int(out_w.sum()),
            'in_lane_widths': in_w.tolist(), 'in_value_of_one': v.tolist(), 'pruned_detectors': [j for j in range(ND) if v[j] == 0],
            'in_kif': k_in.tolist(), 'out_kif': k_out.tolist(),
            'da4ml_comb_cost_lut_est': float(sol.cost), 'da4ml_comb_latency': [float(x) for x in sol.latency],
            'keras_vs_dais_interp_mismatching_vectors_golden': n_interp_mis, 'ler': ler, 'ler_over': 'full test multisets',
            'sha256': {p: sha256(g / p) for p in (f'{NAME}_golden.npz', f'{NAME}_golden_in.hex', f'{NAME}_golden_out.hex',
                                                    f'{NAME}_golden_dec.hex', f'{NAME}_hgq.keras', f'{NAME}_full.json')},
        }
        (g / f'{NAME}_golden.json').write_text(json.dumps(meta, indent=1) + '\n')
        print(json.dumps({k: x for k, x in meta.items() if k not in ('in_kif', 'out_kif', 'in_value_of_one', 'in_lane_widths')}, indent=1))

    for lc in a.cutoffs:
        name = f'{NAME}_lc{lc:g}'
        path = a.rtl_root / name
        if path.exists():
            shutil.rmtree(path)
        rtl = RTLModel(sol, NAME, path, latency_cutoff=lc, part_name='xcvu9p-fsgd2104-2L-e', clock_period=6.206)
        rtl.write(metadata={'model_sha256': meta['sha256'][f'{NAME}_hgq.keras'], 'golden_sha256_in_hex': meta['sha256'][f'{NAME}_golden_in.hex']})
        md = json.loads((path / 'metadata.json').read_text())
        print(f'{name}: {md["latency"]} stages, est {md["cost"]:.0f} LUT, {md["reg_bits"]} FF')
        if a.bcast_ratio:
            subprocess.run([sys.executable, str(ROOT / 'synth/scripts/add_bcast.py'), str(path), str(path.parent / f'{name}bc'),
                            '0', 'auto'], env={**os.environ, 'BC_RATIO': str(a.bcast_ratio)}, check=True)


def write_in_map(v_lane, in_w, path):
    off = np.concatenate([[0], np.cumsum(in_w)[:-1]])
    lines = ['// Generated by ref/qec/export_qec_d5.py from the frozen model. Do not edit.',
             '// Detection bit j drives core input lane j (offset LANE_OFF[j], LANE_W[j] bits) with 0 or LANE_ONE[j].',
             f'localparam int N_DET = {ND};', f'localparam int CORE_IN_W = {int(in_w.sum())};',
             "localparam int LANE_OFF [N_DET] = '{" + ', '.join(str(int(o)) for o in off) + '};',
             "localparam int LANE_W   [N_DET] = '{" + ', '.join(str(int(w)) for w in in_w) + '};',
             "localparam int LANE_ONE [N_DET] = '{" + ', '.join(str(int(o)) for o in v_lane) + '};', '']
    path.write_text('\n'.join(lines))


if __name__ == '__main__':
    main()
