"""Channel-model dataset for the Stage 5 waveform classifier (Artifact C; every number from it is **model**).

Complex baseband at FS = 200 MS/s, sc16 (int16 I and Q) as the X310 delivers it (PLAN.md D-S5-SIG, D-S5-DATA).
Classes: 0 noise only, 1 CW tone, 2 LFM chirp, 3 BPSK (random bits or Barker-13; rectangular or Gaussian-
filtered chips). One labelled window = W complex samples (2W int16, lane 2k = I_k, lane 2k+1 = Q_k, sample 0
oldest); the pulse fills the window.

Signal parameters (P below; written to ref/x310/x310_split_meta.json):
  CW    f ~ U(-15, 15) MHz.
  LFM   span B ~ U(5, 30) MHz, duration T ~ U(0.5, 5) us, kept only if the sweep rate k = B / T >= 10 MHz/us
        (rejection; slower chirps are a CW tone inside a <= 320 ns window, see ref/x310/separability.py);
        up or down; the swept band lies inside +/-15 MHz; the window sits at a uniform position inside the pulse.
  BPSK  chip rate U(5, 20) Mchip/s, carrier U(-10, 10) MHz; chips random bits or a repeated Barker-13 (1/2 each);
        rectangular or Gaussian-filtered with BT ~ U(0.8, 2) (1/2 each). A BPSK window must contain at least one
        phase reversal at least max(2, W/8) samples from either window edge (rejection; a window with no
        reversal is a CW tone).
Channel (all windows): carrier phase U(0, 2 pi); residual CFO +/-U(2, 100) kHz (TX and RX share the reference);
  analog path (CHANNEL, below); SNR ~ U(-5, 25) dB, defined as the window's filtered signal power over the expected noise
  power (the realised window SNR is stored too; noise-only windows carry a drawn SNR as a tag only, so every
  SNR bin holds all four classes); IQ gain imbalance U(-0.5, 0.5) dB and phase U(-2, 2) deg; DC offset
  U(0, 0.3) x noise rms at a random angle; total rms |x| ~ U(-54, -12) dBFS ('lpf': U(-42, -12)); rounding and
  saturation to int16.

CHANNEL (environment X310_CHANNEL; data in ref/data/<dir>, meta in ref/x310/<meta>, PLAN.md D-S5-CH):
  'meas' (default, from 2026-11-03): the X310's measured analog path (ref/x310/channel_x310.py -> x310_channel.json,
         silicon): signals through the measured TX -> RX loop response h (31 complex taps, flat to about +/-80 MHz)
         with a fractional delay U(0, 1) sample per window (the sampling phase of a signal from outside the loop);
         noise = white complex noise through the measured noise-shape FIR g (Welch PSD of the noise-only captures).
  'lpf'  (the first set, 2026-10-29; kept for --check of ref/data/x310): a 40 MHz analog low-pass (5th-order
         Butterworth, +/-20 MHz) on signals and noise, plus a white noise floor 20 dB below it (ADC). The silicon
         captures showed this was wrong (rectangular BPSK was called noise; evidence/stage5/bpsk/README.md).

Block floating point (bfp(), PLAN.md D-S5-BFP): the window is shifted left by s = min(S_MAX, redundant sign
bits of the window's widest lane); integer only, implemented bit-exactly in rtl/x310/x310_clf_top.sv. The
model input is the shifted window / 2^15.

  python ref/x310/x310_data.py                    # all W, all splits -> ref/data/x310/, meta -> ref/x310/
  python ref/x310/x310_data.py --w 32 --check     # regenerate in memory, compare content hashes with the meta
"""

import argparse
import hashlib
import json
import os
import time
from pathlib import Path

import numpy as np
from scipy.signal import butter, sosfilt

ROOT = Path(__file__).resolve().parents[2]
CHANNEL = os.environ.get('X310_CHANNEL', 'meas')
assert CHANNEL in ('meas', 'lpf'), CHANNEL
DDIR = ROOT / {'meas': 'ref/data/x310_meas', 'lpf': 'ref/data/x310'}[CHANNEL]
META = ROOT / {'meas': 'ref/x310/x310_meas_split_meta.json', 'lpf': 'ref/x310/x310_split_meta.json'}[CHANNEL]
CH_FILE = ROOT / 'ref/x310/x310_channel.json'
TAG = {'meas': '_meas', 'lpf': ''}[CHANNEL]   # suffix of the runs dir, selection files, accuracy.md

FS = 200e6
CLASSES = ('noise', 'cw', 'lfm', 'bpsk')
WS = (16, 32, 64)
GUARD = 32  # samples generated before the window so the analog filter has settled
S_MAX = 8   # largest block-floating-point shift
SPLITS = {'train': 200_000, 'val': 25_000, 'test': 25_000}  # windows per class
SPLIT_ID = {'train': 1, 'val': 2, 'test': 3, 'stream': 4}
BASE_SEED = 20261029
CHUNK = 25_000
BARKER13 = np.array([1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1], np.float64)

P = {
    'fs_hz': FS, 'guard_samples': GUARD, 's_max': S_MAX,
    'cw_f_mhz': [-15.0, 15.0],
    'lfm_span_mhz': [5.0, 30.0], 'lfm_dur_us': [0.5, 5.0], 'lfm_rate_min_mhz_per_us': 10.0, 'lfm_band_mhz': 15.0,
    'bpsk_chip_rate_mchip': [5.0, 20.0], 'bpsk_f_mhz': [-10.0, 10.0], 'bpsk_barker_frac': 0.5,
    'bpsk_filtered_frac': 0.5, 'bpsk_gauss_bt': [0.8, 2.0], 'bpsk_edge_margin': 'max(2, W // 8)',
    'cfo_hz': [2e3, 100e3], 'lpf': 'butter(5, 20 MHz / (FS / 2)), sosfilt on I and Q', 'white_floor_db': -20.0,
    'snr_db': [-5.0, 25.0], 'iq_gain_db': 0.5, 'iq_phase_deg': 2.0, 'dc_rel_noise_rms': [0.0, 0.3],
    'amp_dbfs': [-42.0, -12.0], 'full_scale': 32768,
}
if CHANNEL == 'meas':
    P.update({'channel': 'meas', 'lpf': None, 'white_floor_db': None, 'amp_dbfs': [-54.0, -12.0],
              'analog': 'ref/x310/x310_channel.json: h (signals, + fractional delay U(0, 1) sample), g (noise)',
              'frac_delay_samples': [0.0, 1.0]})
SOS = butter(5, 20e6 / (FS / 2), output='sos')


def _load_channel():
    c = json.loads(CH_FILE.read_text())
    h = np.array(c['h']['re']) + 1j * np.array(c['h']['im'])
    g = np.array(c['g']['re']) + 1j * np.array(c['g']['im'])
    return h, g / np.sqrt(np.sum(np.abs(g) ** 2))


H_MEAS, G_MEAS = _load_channel() if CHANNEL == 'meas' else (None, None)


def _noise_gain() -> float:
    imp = np.zeros(4096)
    imp[0] = 1.0
    return float(np.sum(sosfilt(SOS, imp) ** 2))


NG = _noise_gain()
WF = 10 ** (-20.0 / 20)  # 'lpf' only


def lpf(z: np.ndarray) -> np.ndarray:
    return sosfilt(SOS, z.real, axis=1) + 1j * sosfilt(SOS, z.imag, axis=1)


def analog(z: np.ndarray, rng=None) -> np.ndarray:
    """The analog path on signals z (n, L), causal (the first GUARD samples settle). 'meas': the measured response h
    delayed by a fractional delay U(0, 1) per row (rng None: 0), applied in the frequency domain on a zero-padded
    block (linear, no wrap into the first L samples)."""
    if CHANNEL == 'lpf':
        return lpf(z)
    n, L = z.shape
    nf = 1 << int(np.ceil(np.log2(L + len(H_MEAS) + 2)))
    f = np.fft.fftfreq(nf)
    tau = rng.uniform(*P['frac_delay_samples'], n) if rng is not None else np.zeros(n)
    Z = np.fft.fft(z, nf, axis=1) * np.fft.fft(H_MEAS, nf)[None] * np.exp(-2j * np.pi * f[None] * tau[:, None])
    return np.fft.ifft(Z, axis=1)[:, :L]


def cnoise(rng, shape) -> np.ndarray:
    return (rng.standard_normal(shape) + 1j * rng.standard_normal(shape)) / np.sqrt(2)


def receiver_noise(rng, shape) -> np.ndarray:
    """Unit expected power. 'lpf': filtered thermal noise plus a white floor WF below it; 'meas': white noise through
    the measured noise-shape FIR g (unit energy)."""
    if CHANNEL == 'lpf':
        return (lpf(cnoise(rng, shape)) / np.sqrt(NG) + WF * cnoise(rng, shape)) / np.sqrt(1 + WF ** 2)
    from scipy.signal import fftconvolve
    n, L = shape
    w = cnoise(rng, (n, L + len(G_MEAS) - 1))
    return fftconvolve(w, G_MEAS[None], mode='valid', axes=1)


def gauss_cdf(x):
    from scipy.special import ndtr
    return ndtr(x)


# ---------------------------------------------------------------- per-class clean signals (n, L), unit amplitude
def sig_cw(rng, n, L):
    f = rng.uniform(*P['cw_f_mhz'], n) * 1e6
    return f, np.exp(2j * np.pi * f[:, None] * np.arange(L) / FS)


def sig_lfm(rng, n, L):
    out_k, out_s = [], []
    got = 0
    while got < n:
        m = 4 * (n - got) + 16
        B = rng.uniform(*P['lfm_span_mhz'], m) * 1e6
        T = rng.uniform(*P['lfm_dur_us'], m) * 1e-6
        k = B / T
        ok = (k >= P['lfm_rate_min_mhz_per_us'] * 1e12) & (T >= L / FS)
        B, T, k = B[ok][:n - got], T[ok][:n - got], k[ok][:n - got]
        mm = len(B)
        up = rng.random(mm) < 0.5
        flo = rng.uniform(-P['lfm_band_mhz'] * 1e6, P['lfm_band_mhz'] * 1e6 - B)
        tau0 = rng.uniform(0, T - L / FS)
        t = tau0[:, None] + np.arange(L)[None] / FS
        ph = np.where(up[:, None], flo[:, None] * t + 0.5 * k[:, None] * t ** 2,
                      (flo + B)[:, None] * t - 0.5 * k[:, None] * t ** 2)
        out_s.append(np.exp(2j * np.pi * ph))
        out_k.append(np.where(up, k, -k))
        got += mm
    return np.concatenate(out_k), np.concatenate(out_s)


def sig_bpsk(rng, n, L, W):
    marg = max(2, W // 8)
    out_r, out_s, out_sub = [], [], []
    got = 0
    while got < n:
        m = min(4096, 3 * (n - got) + 64)
        rc = rng.uniform(*P['bpsk_chip_rate_mchip'], m) * 1e6
        fc = rng.uniform(*P['bpsk_f_mhz'], m) * 1e6
        barker = rng.random(m) < P['bpsk_barker_frac']
        filt = rng.random(m) < P['bpsk_filtered_frac']
        bt = rng.uniform(*P['bpsk_gauss_bt'], m)
        t0 = rng.uniform(0, 13, m) / rc  # time of sample 0 after a chip-0 boundary (Barker: anywhere in the code)
        t = t0[:, None] + np.arange(L)[None] / FS
        # chips c = cmin .. cmin + K - 1 cover the segment with 3 chips of margin for the Gaussian tails
        cmin = np.floor(t0 * rc).astype(np.int64) - 3
        K = int(np.ceil(L * P['bpsk_chip_rate_mchip'][1] * 1e6 / FS)) + 8
        c = cmin[:, None] + np.arange(K)[None]
        bits = np.where(barker[:, None], BARKER13[np.mod(c, 13)], rng.choice([-1.0, 1.0], (m, K)))
        tb = c / rc[:, None]  # start time of chip c
        rect = np.take_along_axis(bits, np.floor(t * rc[:, None]).astype(np.int64) - cmin[:, None], axis=1)
        sig = (0.13246 / bt) / rc  # Gaussian sigma: sqrt(ln 2) / (2 pi BT Rc)
        x = (t[:, :, None] - tb[:, None, :]) / sig[:, None, None]
        g = gauss_cdf(x) - gauss_cdf(x - (1 / rc / sig)[:, None, None])
        smooth = np.einsum('nlk,nk->nl', g, bits)
        a = np.where(filt[:, None], smooth, rect)
        # reversal positions (boundary between chips c-1 and c with different bits), in window samples
        rev = bits[:, 1:] != bits[:, :-1]
        p = (tb[:, 1:] - t0[:, None]) * FS - GUARD
        ok = np.any(rev & (p >= marg) & (p <= W - marg), axis=1)
        s = a * np.exp(2j * np.pi * fc[:, None] * np.arange(L)[None] / FS)
        take = np.flatnonzero(ok)[:n - got]
        out_s.append(s[take]); out_r.append(rc[take])
        out_sub.append((barker[take].astype(np.int8) | (filt[take].astype(np.int8) << 1)))
        got += len(take)
    return np.concatenate(out_r), np.concatenate(out_s), np.concatenate(out_sub)


def channel(rng, s, n, W, L):
    """s: clean signal (n, L) or None for noise -> int16 windows (n, 2W) and per-window metadata."""
    nidx = np.arange(L)[None]
    snr_db = rng.uniform(*P['snr_db'], n)
    noise = receiver_noise(rng, (n, L))[:, GUARD:]
    if s is not None:
        theta = rng.uniform(0, 2 * np.pi, n)
        cfo = rng.uniform(*P['cfo_hz'], n) * rng.choice([-1, 1], n)
        s = s * np.exp(1j * (2 * np.pi * cfo[:, None] * nidx / FS + theta[:, None]))
        s = analog(s, rng)[:, GUARD:]
        ps = np.mean(np.abs(s) ** 2, axis=1)
        sigma = np.sqrt(ps / 10 ** (snr_db / 10))
        x = s + sigma[:, None] * noise
        snr_win = 10 * np.log10(ps / np.mean(np.abs(sigma[:, None] * noise) ** 2, axis=1))
    else:
        ps = np.zeros(n)
        sigma = np.ones(n)
        x = noise
        snr_win = np.full(n, np.nan)
    g = 10 ** (rng.uniform(-P['iq_gain_db'], P['iq_gain_db'], n) / 40)
    phi = np.deg2rad(rng.uniform(-P['iq_phase_deg'], P['iq_phase_deg'], n))
    i_, q_ = x.real * g[:, None], (x.imag * np.cos(phi)[:, None] - x.real * np.sin(phi)[:, None]) / g[:, None]
    dc = rng.uniform(*P['dc_rel_noise_rms'], n) * sigma * np.exp(1j * rng.uniform(0, 2 * np.pi, n))
    amp = rng.uniform(*P['amp_dbfs'], n)
    gain = P['full_scale'] * 10 ** (amp / 20) / np.sqrt(ps + sigma ** 2)
    yi = np.clip(np.rint((i_ + dc.real[:, None]) * gain[:, None]), -32768, 32767)
    yq = np.clip(np.rint((q_ + dc.imag[:, None]) * gain[:, None]), -32768, 32767)
    xw = np.empty((n, 2 * W), np.int16)
    xw[:, 0::2], xw[:, 1::2] = yi, yq
    sat = np.mean((np.abs(yi) >= 32767) | (np.abs(yq) >= 32767), axis=1)
    return xw, dict(snr_db=snr_db.astype(np.float32), snr_win_db=snr_win.astype(np.float32),
                    amp_dbfs=amp.astype(np.float32), sat_frac=sat.astype(np.float32))


def gen_split(W: int, split: str, n_per_class: int):
    L = GUARD + W
    xs, meta = [], {k: [] for k in ('y', 'snr_db', 'snr_win_db', 'amp_dbfs', 'sat_frac', 'param', 'sub')}
    for cls in range(4):
        rng = np.random.default_rng([BASE_SEED, W, SPLIT_ID[split], cls])
        for c0 in range(0, n_per_class, CHUNK):
            m = min(CHUNK, n_per_class - c0)
            sub = np.zeros(m, np.int8)
            if cls == 0:
                param, s = np.zeros(m), None
            elif cls == 1:
                param, s = sig_cw(rng, m, L)
            elif cls == 2:
                param, s = sig_lfm(rng, m, L)
            else:
                param, s, sub = sig_bpsk(rng, m, L, W)
            x, md = channel(rng, s, m, W, L)
            xs.append(x)
            meta['y'].append(np.full(m, cls, np.int8)); meta['param'].append(param.astype(np.float64)); meta['sub'].append(sub)
            for k, v in md.items():
                meta[k].append(v)
    out = {'x': np.concatenate(xs)}
    out.update({k: np.concatenate(v) for k, v in meta.items()})
    # one fixed interleaving of the classes (training shuffles anyway; the order is part of the hash)
    perm = np.random.default_rng([BASE_SEED, W, SPLIT_ID[split], 99]).permutation(len(out['x']))
    return {k: v[perm] for k, v in out.items()}


# ---------------------------------------------------------------- continuous stream (sliding-window tests)
def make_stream(n_samples: int, seed: int = 0):
    """A continuous capture: noise floor at -40 dBFS, gaps of noise U(0.2, 2) us between pulses of class
    1..3 (CW 0.5-5 us, LFM as in the window set, BPSK 13-64 chips or 1-4 Barker-13 codes) at SNR U(-5, 25) dB.
    One channel draw (phase per pulse, CFO, IQ imbalance, DC) for the whole stream. Returns int16 (n, 2)
    samples (I, Q) and the per-sample class label (0 in gaps)."""
    rng = np.random.default_rng([BASE_SEED, 0, SPLIT_ID['stream'], seed])
    s = np.zeros(n_samples, np.complex128)
    lab = np.zeros(n_samples, np.int8)
    pos = 0
    while True:
        pos += int(rng.uniform(0.2, 2.0) * 1e-6 * FS)
        cls = int(rng.integers(1, 4))
        snr = rng.uniform(*P['snr_db'])
        if cls == 1:
            T = rng.uniform(0.5, 5.0) * 1e-6
            nn = int(T * FS)
            seg = np.exp(2j * np.pi * rng.uniform(*P['cw_f_mhz']) * 1e6 * np.arange(nn) / FS)
        elif cls == 2:
            while True:
                B = rng.uniform(*P['lfm_span_mhz']) * 1e6
                T = rng.uniform(*P['lfm_dur_us']) * 1e-6
                if B / T >= P['lfm_rate_min_mhz_per_us'] * 1e12:
                    break
            nn = int(T * FS)
            t = np.arange(nn) / FS
            flo = rng.uniform(-P['lfm_band_mhz'] * 1e6, P['lfm_band_mhz'] * 1e6 - B)
            k = B / T
            ph = flo * t + 0.5 * k * t ** 2 if rng.random() < 0.5 else (flo + B) * t - 0.5 * k * t ** 2
            seg = np.exp(2j * np.pi * ph)
        else:
            rc = rng.uniform(*P['bpsk_chip_rate_mchip']) * 1e6
            if rng.random() < P['bpsk_barker_frac']:
                bits = np.tile(BARKER13, int(rng.integers(1, 5)))
            else:
                bits = rng.choice([-1.0, 1.0], int(rng.integers(13, 65)))
            nn = int(len(bits) / rc * FS)
            t = np.arange(nn) / FS
            seg = bits[np.minimum((t * rc).astype(np.int64), len(bits) - 1)] * \
                np.exp(2j * np.pi * rng.uniform(*P['bpsk_f_mhz']) * 1e6 * t)
        if pos + nn > n_samples:
            break
        s[pos:pos + nn] = seg * np.exp(1j * rng.uniform(0, 2 * np.pi)) * 10 ** (snr / 20)
        lab[pos:pos + nn] = cls
        pos += nn
    cfo = rng.uniform(*P['cfo_hz']) * rng.choice([-1, 1])
    s = s * np.exp(2j * np.pi * cfo * np.arange(n_samples) / FS)
    x = analog(s[None], rng)[0] + receiver_noise(rng, (1, n_samples))[0]
    g = 10 ** (rng.uniform(-P['iq_gain_db'], P['iq_gain_db']) / 40)
    phi = np.deg2rad(rng.uniform(-P['iq_phase_deg'], P['iq_phase_deg']))
    dc = rng.uniform(*P['dc_rel_noise_rms']) * np.exp(1j * rng.uniform(0, 2 * np.pi))
    i_ = x.real * g + dc.real
    q_ = (x.imag * np.cos(phi) - x.real * np.sin(phi)) / g + dc.imag
    gain = P['full_scale'] * 10 ** (-40 / 20)
    y = np.clip(np.rint(np.stack([i_, q_], 1) * gain), -32768, 32767).astype(np.int16)
    return y, lab


def stream_windows(y: np.ndarray, W: int) -> np.ndarray:
    """All n - W + 1 windows of a stream (sample 0 oldest), as (n - W + 1, 2W) int16."""
    from numpy.lib.stride_tricks import sliding_window_view
    return sliding_window_view(y, (W, 2)).reshape(-1, 2 * W).copy()


# ---------------------------------------------------------------- block floating point (bit-exact with the RTL)
def bfp(x: np.ndarray, s_max: int = S_MAX):
    """x int16 (n, 2W) -> (x << s, s), s = min(s_max, 15 - bitlength(OR over lanes of (v ^ (v >> 15)) & 0x7fff))."""
    v = x.astype(np.int32)
    m = np.bitwise_or.reduce((v ^ (v >> 15)) & 0x7FFF, axis=1)
    bl = np.zeros(len(m), np.int32)
    for b in range(15):
        bl = np.where(m >> b != 0, b + 1, bl)
    s = np.minimum(s_max, 15 - bl)
    xn = v << s[:, None]
    assert xn.min() >= -32768 and xn.max() <= 32767
    return xn.astype(np.int16), s.astype(np.int8)


def model_input(x: np.ndarray, use_bfp: bool) -> np.ndarray:
    """int16 windows -> the Keras model input (float64 on the 2^-15 grid, [-1, 1))."""
    return (bfp(x)[0] if use_bfp else x).astype(np.float64) / 32768.0


def load(W: int, split: str) -> dict:
    z = np.load(DDIR / f'x310_w{W}_{split}.npz')
    return {k: z[k] for k in z.files}


def sha256(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def content_sha256(d: dict) -> str:
    """Hash of the arrays themselves (key, dtype, shape, bytes; sorted keys): .npz zip headers carry a
    timestamp, so the file hash is not reproducible but this is."""
    h = hashlib.sha256()
    for k in sorted(d):
        v = np.ascontiguousarray(d[k])
        h.update(f'{k}:{v.dtype.str}:{v.shape};'.encode())
        h.update(v.tobytes())
    return h.hexdigest()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--w', type=int, nargs='+', default=list(WS))
    ap.add_argument('--splits', nargs='+', default=list(SPLITS))
    ap.add_argument('--check', action='store_true', help='regenerate into a temp name and compare with the meta hashes')
    a = ap.parse_args()
    DDIR.mkdir(parents=True, exist_ok=True)
    meta = json.loads(META.read_text()) if META.exists() else {}
    meta.update({'generator': 'ref/x310/x310_data.py', 'base_seed': BASE_SEED,
                 'seeding': 'numpy default_rng([base_seed, W, split_id, class]); split_id train 1 val 2 test 3',
                 'classes': list(CLASSES), 'windows_per_class': SPLITS, 'params': P,
                 'numpy': np.__version__, 'files': meta.get('files', {})})
    import scipy
    meta['scipy'] = scipy.__version__
    for W in a.w:
        for split in a.splits:
            t0 = time.time()
            d = gen_split(W, split, SPLITS[split])
            f = DDIR / f'x310_w{W}_{split}.npz'
            h = content_sha256(d)
            if not a.check:
                np.savez_compressed(f, **d)
            key = f'x310_w{W}_{split}.npz'
            if a.check:
                ok = meta['files'].get(key, {}).get('content_sha256') == h
                print(f'CHECK {key}: {"MATCH" if ok else "DIFFERENT"} {h}')
                continue
            y = d['y']
            meta['files'][key] = {'content_sha256': h, 'n': int(len(y)), 'class_counts': np.bincount(y, minlength=4).tolist(),
                                  'mean_sat_frac': float(d['sat_frac'].mean()),
                                  'bfp_shift_hist': np.bincount(bfp(d['x'])[1], minlength=S_MAX + 1).tolist()}
            print(f'W={W} {split}: {len(y)} windows, {time.time() - t0:.0f} s, sha256 {h[:16]}', flush=True)
    if not a.check:
        META.write_text(json.dumps(meta, indent=1) + '\n')


if __name__ == '__main__':
    main()
