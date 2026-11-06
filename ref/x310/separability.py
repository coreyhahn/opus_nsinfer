"""How far an LFM chirp is from a CW tone inside a W-sample window (PLAN.md D-S5-DATA; **model**, analytic).

r(k, W) = 1 - max_f |<s_k, e_f>|^2 / (|s_k|^2 W): the fraction of a noiseless chirp's energy (rate k, centred
in the window) that no tone (frequency grid +/-40 MHz, 10 kHz steps; phase and amplitude free) explains.
d^2 = 2 W SNR r is the deflection of the best tone-vs-chirp test at per-sample SNR (10 dB here); d^2 of a
few means not separable, tens means separable. The same for a BPSK reversal m samples from the window edge.

  python ref/x310/separability.py      # -> evidence/stage5/separability.json
"""

import json
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
FS = 200e6
SNR = 10.0


def best_tone_residual(s):
    W = len(s)
    t = (np.arange(W) - (W - 1) / 2) / FS
    fs = np.linspace(-40e6, 40e6, 8001)
    return float(1 - np.max(np.abs(np.exp(-2j * np.pi * fs[:, None] * t[None]) @ s) ** 2) / (np.sum(np.abs(s) ** 2) * W))


def main():
    out = {'snr_db': 10 * np.log10(SNR), 'lfm': {}, 'bpsk_reversal': {}}
    for W in (16, 32, 64):
        t = (np.arange(W) - (W - 1) / 2) / FS
        out['lfm'][W] = {}
        for k in (1, 5, 10, 15, 20, 30, 45, 60):
            r = best_tone_residual(np.exp(1j * np.pi * k * 1e12 * t ** 2))
            out['lfm'][W][k] = {'r': r, 'd2': 2 * W * SNR * r}
        out['bpsk_reversal'][W] = {}
        for m in sorted({2, max(2, W // 8), W // 4, W // 2}):
            s = np.where(np.arange(W) < m, -1.0, 1.0).astype(complex)
            r = best_tone_residual(s)
            out['bpsk_reversal'][W][m] = {'r': r, 'd2': 2 * W * SNR * r}
    print('LFM vs best tone, d^2 at 10 dB (rows W, columns k MHz/us)')
    for W, row in out['lfm'].items():
        print(W, '  '.join(f'k{k}:{v["d2"]:.1f}' for k, v in row.items()))
    print('BPSK reversal m samples from the edge vs best tone, d^2 at 10 dB')
    for W, row in out['bpsk_reversal'].items():
        print(W, '  '.join(f'm{m}:{v["d2"]:.1f}' for m, v in row.items()))
    dst = ROOT / 'evidence/stage5/separability.json'
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(json.dumps(out, indent=1) + '\n')


if __name__ == '__main__':
    main()
