"""(Stage 5 BPSK fix) Labelled accuracy of a keras model on silicon captures (labels and pulse SNR as sw/x310/nsclf_analyze.py)."""
import sys, json
import numpy as np
from pathlib import Path
ROOT = Path('/home/cah/r2d2/code/fpga/opus_nsinfer')
sys.path.insert(0, str(ROOT / 'sw/x310')); sys.path.insert(0, str(ROOT / 'ref/x310'))
import nsclf_analyze as A, nsclf_txrx as tr, x310_data as xd
from numpy.lib.stride_tricks import sliding_window_view
W = 64
model = None

def predict(y):
    yi = np.clip(np.rint(np.stack([y.real, y.imag], 1)), -32768, 32767).astype(np.int16)
    v = sliding_window_view(yi, (W, 2)).reshape(-1, 2 * W)
    out = np.empty(len(v), np.int8)
    for i in range(0, len(v), 400000):
        out[i:i+400000] = np.argmax(model.predict(xd.model_input(v[i:i+400000].copy(), True), batch_size=65536, verbose=0), 1)
    return out

def run_capture(stem):
    meta, y = A.load_capture(stem)
    pre = int(meta['tx_start_host_ticks']) - int(meta['T_host_first_sample'])
    t = meta['tx']
    x, _, pulses = tr.make_tx(t['seed'], t['n_tx'], t['amp'], t['att_db'], tuple(t['gap_us']))
    cls = predict(y)
    lr = A.loop_response(x, y, pre)
    D_int, D, lo, hi = lr['D_int'], lr['D'], lr['lo'], lr['hi']
    nm = A.rx_noise_mask(len(y), pulses, len(x), pre, lo, hi)
    yac = y - y[nm].mean(); N = float(np.mean(np.abs(yac[nm]) ** 2))
    snr = np.full(len(pulses), np.nan)
    for i, p in enumerate(pulses):
        r0, r1 = pre + p['start'] + hi, pre + p['start'] + p['len'] - 1 + lo
        if r1 <= r0:
            r0, r1 = pre + p['start'] + D_int, pre + p['start'] + p['len'] + D_int - 1
        snr[i] = 10 * np.log10(max(float(np.mean(np.abs(yac[r0:r1 + 1]) ** 2)) - N, 1e-3 * N) / N)
    lab, kind, pid, region = A.labels(None, pulses, len(x), len(cls), pre, lo, hi, D)
    pure = kind == 0
    wsnr = np.where(pid >= 0, snr[np.clip(pid, 0, None)], np.nan)
    pc = [100 * np.mean(cls[pure & (lab == c)] == c) for c in range(4)]
    hi_ = [100 * np.mean(cls[pure & (lab == c) & ((wsnr >= 10) if c else True)] == c) for c in range(4)]
    print(json.dumps({'capture': stem, 'balanced': float(np.mean(pc)), 'per_class': pc,
                      'snr_ge10_balanced': float(np.mean(hi_)), 'per_class_ge10': hi_}), flush=True)
