"""Measured X310 receive channel for the Stage 5 data generator (PLAN.md D-S5-CH; every number from it is **silicon**,
the model built on it is **model**).

The first training set (x310_data.py channel 'lpf') assumed a 40 MHz analog low-pass (5th-order Butterworth,
+/-20 MHz) and noise shaped by it. The silicon captures of 2026-11-03 show the X310 / UBX-160 path at 200 MS/s is
flat to about +/-80 MHz and its noise is white: rectangular BPSK keeps its wideband phase reversals and was
called noise (evidence/stage5/bpsk/README.md). This script measures the channel from the committed captures:

  * signal response h: least-squares loop response (nsclf_analyze.loop_response) of each dense capture sigL_s0..7
    (TX -> 30 dB -> RX, the UBX TX and RX chains), complex taps around the peak, normalised to h[peak] = 1, mean
    over the 8 captures;
  * noise shape g: Welch PSD of noise_s0 and noise_s1 (no TX, rx_dcoffset auto), mean, -> zero-phase FIR whose
    |G(f)|^2 is the PSD (unit power).

  python ref/x310/channel_x310.py      # -> ref/x310/x310_channel.json (needs .scratch/s5_cap, hashes checked)
"""
import hashlib
import json
import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'sw/x310'))
OUT = ROOT / 'ref/x310/x310_channel.json'
SIG = [f'sigL_s{k}' for k in range(8)]
NOISE = ['noise_s0', 'noise_s1']
H_SPAN = (-6, 24)        # taps kept around the peak (the 99.95 % span is peak -2 .. +17)
G_TAPS = 128             # noise FIR length (Welch segment)


def sha(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def loop_h(stem):
    import nsclf_analyze as A
    import nsclf_txrx as tr
    from scipy.linalg import solve_toeplitz
    meta, y = A.load_capture(stem)
    pre = int(meta['tx_start_host_ticks']) - int(meta['T_host_first_sample'])
    t = meta['tx']
    x, _, _ = tr.make_tx(t['seed'], t['n_tx'], t['amp'], t['att_db'], tuple(t['gap_us']))
    nfft = 1 << int(np.ceil(np.log2(len(y) + len(x))))
    X = np.fft.fft(x.astype(np.complex128), nfft)
    c = np.fft.ifft(np.fft.fft(y, nfft) * np.conj(X))
    r = np.fft.ifft(X * np.conj(X))
    lg = np.arange(pre - 200, pre + 3000)
    d0 = int(lg[np.argmax(np.abs(c[lg]))])
    ls = np.arange(d0 - 48, d0 + 96)
    h = solve_toeplitz((r[:len(ls)], np.conj(r[:len(ls)])), c[ls])
    k = int(np.argmax(np.abs(h)))
    hs = h[k + H_SPAN[0]:k + H_SPAN[1] + 1] / h[k]
    tot = float(np.sum(np.abs(h) ** 2))
    return hs, int(ls[k] - pre), float(np.sum(np.abs(hs) ** 2) * abs(h[k]) ** 2 / tot)


def noise_g(stems):
    import nsclf_analyze as A
    from scipy.signal import welch
    ps = []
    for s in stems:
        _, y = A.load_capture(s)
        f, p = welch(y - y.mean(), fs=200e6, nperseg=G_TAPS, return_onesided=False, detrend=False)
        ps.append(p)
    p = np.mean(ps, 0)                    # FFT bin order (0 .. +, - .. -1)
    p /= p.mean()
    g = np.fft.fftshift(np.fft.ifft(np.sqrt(p)))     # zero-phase, centred
    g *= np.hanning(G_TAPS + 2)[1:-1]
    g /= np.sqrt(np.sum(np.abs(g) ** 2))
    return g, f, p


def main():
    cap = ROOT / '.scratch/s5_cap'
    hashes = {f'{s}.npz': sha(cap / f'{s}.npz') for s in SIG + NOISE}
    ref = {l.split()[1].split('/')[-1]: l.split()[0] for l in
           (ROOT / 'evidence/stage5/silicon/captures.sha256').read_text().splitlines() if l.strip()}
    for k, v in hashes.items():
        assert ref.get(k) == v, f'{k}: hash differs from evidence/stage5/silicon/captures.sha256'
    hs, lags, kept = [], [], []
    for s in SIG:
        h, l, e = loop_h(s)
        hs.append(h); lags.append(l); kept.append(e)
        print(f'{s}: peak lag {l}, energy kept {100 * e:.3f} %', flush=True)
    H = np.mean(hs, 0)
    spread = float(np.max(np.abs(np.array(hs) - H)))
    g, f, p = noise_g(NOISE)
    fo = np.fft.fftshift(f)
    po = np.fft.fftshift(p)
    out = {'generator': 'ref/x310/channel_x310.py', 'captures_sha256': hashes,
           'h': {'re': H.real.tolist(), 'im': H.imag.tolist(), 'first_tap_rel_peak': H_SPAN[0],
                 'peak_lag_samples': lags, 'energy_kept_frac': kept, 'max_abs_dev_over_captures': spread},
           'g': {'re': g.real.tolist(), 'im': g.imag.tolist(), 'taps': G_TAPS},
           'noise_psd_db': {'f_mhz': (fo / 1e6).round(4).tolist(), 'db': (10 * np.log10(po)).round(3).tolist()}}
    OUT.write_text(json.dumps(out, indent=1) + '\n')
    Hf = np.fft.fftshift(np.fft.fft(H, 256)); ff = np.fft.fftshift(np.fft.fftfreq(256, 1 / 200)) 
    for fm in (-90, -80, -60, -40, -20, 0, 20, 40, 60, 80, 90):
        k = np.argmin(np.abs(ff - fm)); kk = np.argmin(np.abs(fo / 1e6 - fm))
        print(f'{fm:4d} MHz: |H| {20 * np.log10(abs(Hf[k]) / abs(Hf[128])):6.1f} dB, noise PSD {10 * np.log10(po[kk]):6.1f} dB')
    print(f'wrote {OUT.relative_to(ROOT)}; h spread over captures {spread:.4f}')


if __name__ == '__main__':
    main()
