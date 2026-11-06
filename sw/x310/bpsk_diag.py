"""(Stage 5 BPSK fix, evidence/stage5/bpsk/) Silicon vs simulated RX of the same TX schedule: decisions of the exported model on the capture, and on the TX waveform through the Butterworth model or the measured loop response h, plus model or real (noise_s0) noise. usage: bpsk_diag.py <stem>; writes .scratch/bpsk_diag/h_<stem>.npz."""
import os, sys, json
os.environ.setdefault('KERAS_BACKEND', 'jax')
os.environ['X310_CHANNEL'] = 'lpf'  # the first channel model (the one under test)
import jax; jax.config.update('jax_enable_x64', True)
import keras; keras.config.set_floatx('float64')
import hgq  # noqa: registers QDense
import numpy as np
from pathlib import Path
ROOT = Path('/home/cah/r2d2/code/fpga/opus_nsinfer')
sys.path.insert(0, str(ROOT / 'sw/x310')); sys.path.insert(0, str(ROOT / 'ref/x310'))
import nsclf_analyze as A, nsclf_txrx as tr, x310_data as xd
from numpy.lib.stride_tricks import sliding_window_view
W = 64
model = keras.models.load_model(ROOT / 'ref/golden/x310_hgq.keras')

def predict(y):
    yi = np.clip(np.rint(np.stack([y.real, y.imag], 1)), -32768, 32767).astype(np.int16)
    out = np.empty(len(y) - W + 1, np.int8)
    v = sliding_window_view(yi, (W, 2)).reshape(-1, 2 * W)
    for i in range(0, len(v), 400000):
        z = model.predict(xd.model_input(v[i:i+400000].copy(), True), batch_size=65536, verbose=0)
        out[i:i+400000] = np.argmax(z, 1)
    return out

def evaluate(name, y, x, pulses, pre, cls, lr=None):
    n_rx = len(y); n_dec = len(cls)
    lr = lr or A.loop_response(x, y, pre)
    D_int, D, lo, hi = lr['D_int'], lr['D'], lr['lo'], lr['hi']
    nm = A.rx_noise_mask(n_rx, pulses, len(x), pre, lo, hi)
    dc = y[nm].mean(); yac = y - dc
    N = float(np.mean(np.abs(yac[nm]) ** 2))
    snr = np.full(len(pulses), np.nan)
    for i, p in enumerate(pulses):
        r0, r1 = pre + p['start'] + hi, pre + p['start'] + p['len'] - 1 + lo
        if r1 <= r0:
            r0, r1 = pre + p['start'] + D_int, pre + p['start'] + p['len'] + D_int - 1
        P = float(np.mean(np.abs(yac[r0:r1 + 1]) ** 2))
        snr[i] = 10 * np.log10(max(P - N, 1e-3 * N) / N)
    lab, kind, pid, region = A.labels(None, pulses, len(x), n_dec, pre, lo, hi, D)
    pure = kind == 0
    wsnr = np.where(pid >= 0, snr[np.clip(pid, 0, None)], np.nan)
    res = {'name': name, 'D': D, 'lo': lo, 'hi': hi, 'N_dbfs': 10*np.log10(N) - 90.3}
    pc = []
    for c in range(4):
        s = pure & (lab == c); pc.append(100 * np.mean(cls[s] == c))
    res['per_class'] = pc
    bins = []
    for b0 in range(-5, 25, 5):
        s = pure & (lab == 3) & (wsnr >= b0) & (wsnr < b0 + 5)
        sc = pure & (lab == 1) & (wsnr >= b0) & (wsnr < b0 + 5)
        bins.append((b0, round(100*np.mean(cls[s] == 3), 1), round(100*np.mean(cls[sc] == 1), 1),
                     np.bincount(cls[s], minlength=4).tolist()))
    res['bpsk_cw_by_snr'] = bins
    # per-class peak SNR estimate (snr - a_db) for loud pulses
    a_db = np.array([p['a_db'] for p in pulses]); pcl = np.array([p['cls'] for p in pulses])
    res['peak_snr_by_class'] = [float(np.median((snr - a_db)[(a_db > -15) & (pcl == c)])) for c in (1, 2, 3)]
    print(json.dumps(res), flush=True)
    return res, lr

stem = sys.argv[1] if len(sys.argv) > 1 else 'sigL_s0'
meta, y = A.load_capture(stem)
T = int(meta['T_host_first_sample']); pre = int(meta['tx_start_host_ticks']) - T
tx = meta['tx']
x, _, pulses = tr.make_tx(tx['seed'], tx['n_tx'], tx['amp'], tx['att_db'], tuple(tx['gap_us']))
sil, words, tau0, misr = A.load_decisions(stem, meta, len(y))
kcls = predict(y)
print('keras vs silicon decisions agree:', float(np.mean(kcls == sil)), flush=True)
r_sil, lr = evaluate('silicon', y, x, pulses, pre, sil)

# measured linear response h and a model channel with the same delay and complex gain
from scipy.signal import sosfilt
h = None
L = A.loop_response.__code__  # noqa
# recompute h (loop_response does not return it): least squares as there
from scipy.linalg import solve_toeplitz
nfft = 1 << int(np.ceil(np.log2(len(y) + len(x))))
X = np.fft.fft(x.astype(np.complex128), nfft); Y = np.fft.fft(y, nfft)
c = np.fft.ifft(Y * np.conj(X)); r = np.fft.ifft(X * np.conj(X))
lg = np.arange(pre - 200, pre + 3000); d0 = int(lg[np.argmax(np.abs(c[lg]))])
ls = np.arange(d0 - 48, d0 + 96)
h = solve_toeplitz((r[:len(ls)], np.conj(r[:len(ls)])), c[ls])
np.savez(ROOT / f'.scratch/bpsk_diag/h_{stem}.npz', h=h, lags=ls - pre)
def through_h(hh, lags):
    out = np.zeros(len(y), np.complex128)
    full = np.convolve(x.astype(np.complex128), hh)
    l0 = lags[0] + pre
    seg = full[:len(y) - l0]
    out[l0:l0 + len(seg)] = seg
    return out
s_meas = through_h(h, ls - pre)
# model channel: Butterworth LPF of the training set, delay & gain matched to the measured peak
imp = np.zeros(200); imp[0] = 1; hb = sosfilt(xd.SOS, imp)
gd = int(np.argmax(np.abs(hb)))
kpk = int(np.argmax(np.abs(h)))
s_mod = through_h(h[kpk] / hb[gd] * hb, np.arange(len(hb)) + (ls[kpk] - pre) - gd)
rng = np.random.default_rng(1)
Nsil = 10 ** ((r_sil['N_dbfs'] + 90.3) / 10)
n_mod = np.sqrt(Nsil) * xd.receiver_noise(rng, (1, len(y)))[0]
_, yn = A.load_capture('noise_s0')
n_real = (yn - yn.mean())[:len(y)]
if len(n_real) < len(y): n_real = np.concatenate([n_real, n_real[:len(y) - len(n_real)]])
print('real noise power dBFS', 10*np.log10(np.mean(np.abs(n_real)**2)) - 90.3)
for nm_, yy in [('modelLPF+modelnoise', s_mod + n_mod), ('measH+modelnoise', s_meas + n_mod),
                ('modelLPF+realnoise', s_mod + n_real), ('measH+realnoise', s_meas + n_real),
                ('silicon-residual-check: measH+(y - measH)', None)]:
    if yy is None:
        continue
    evaluate(nm_, yy, x, pulses, pre, predict(yy))
