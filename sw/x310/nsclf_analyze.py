#!/usr/bin/env python3
"""Stage 5 silicon analysis: accuracy, loop delay and detection latency of the nsclf block on the X310, from the
2026-11-03 captures (.scratch/s5_cap/<stem>.npz/.json) and the per-decision dumps of the bit-exact replay
(.scratch/nsclf_replay/<stem>/decisions.npz, written by `nsclf_replay.py replay <stem> --dump`).

Every decision used here is a silicon decision: the dump's MISR / count / per-class counts / first and last tau are
recomputed (nsclf_model.window) and must equal the block's read-back from the capture's json, else the script stops.

  python3 sw/x310/nsclf_analyze.py [--stems ...] [--out evidence/stage5/silicon]
    -> <out>/summary.json, <out>/analysis.md (tables), progress on stdout

Definitions (evidence/stage5/silicon/README.md has the reasoning):
  * RX sample k of a capture has host time T + k and tap time T - 6 + k; decision j's window is RX samples j..j+63,
    tau_j = T - 6 + j + 63 (checked against the dump).
  * TX sample 0 is played at host time T + PRE (PRE = 4000); the TX waveform and its pulse schedule are regenerated
    by nsclf_txrx.make_tx from the json 'tx' parameters.
  * Loop response h[l] (RX = sum_l h[l] TX[r - PRE - l]): least squares over lags D0 - 48 .. D0 + 95 around the
    cross-correlation peak D0 (normal equations with the TX autocorrelation, scipy solve_toeplitz). D = lag of max
    |h| refined by a parabola through |h| at the 3 lags around it (host ticks = samples at 200 MS/s). The analog span
    [lo, hi] = the smallest lag range holding 99.95 % of sum |h|^2 (residual < -33 dB of the response).
  * Labels (D-S5-DATA rules, ref/x310/x310_data.py): window j depends on TX samples j - PRE - hi .. j + 63 - PRE - lo.
    class c if they all lie inside one pulse of class c; BPSK only if a phase reversal (chip boundary with a bit change,
    at RX position PRE + D + start + c * FS / rc) lies at window position p with max(2, W // 8) <= p <= W - max(2, W // 8),
    else 'bpsk_norev' (excluded); noise if none of them is inside a pulse and all lie inside the TX burst [0, n_tx)
    (windows that depend on the time before the burst or after it are 'tx_idle', excluded: a DC step follows the
    burst's end); otherwise 'straddle' (excluded).
  * Noise power N: mean |y - dc(t)|^2 over RX samples whose TX dependence lies in a gap during playback (dc(t): the
    gap mean in blocks of 2^16 samples, interpolated); pulse SNR = 10 log10((P - N) / N), P = mean |y - dc(t)|^2 over
    the pulse's steady RX span [PRE + s + hi, PRE + e - 1 + lo] (the model's definition: signal power over the total
    noise power at 200 MS/s, DC not counted as noise).
  * Onset of a pulse (tap time) = T - 6 + PRE + start + D_int (D_int = lag of max |h|); detection delay = tau of the
    first decision of the pulse's class with tau >= onset, whose window no longer depends on the previous pulse, and
    before the pulse's last window has left, minus onset.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(ROOT / 'ref/x310'))
import nsclf_model as m  # noqa: E402
import nsclf_txrx as tr  # noqa: E402

W = 64
L_PIPE = 19                 # REG_LATENCY (sim): v1 19; set per capture from the silicon read-back (v2: 22)
RADIO_RX_OFFSET = 6
FS = 200e6
CAP = ROOT / '.scratch/s5_cap'
REPLAY = ROOT / '.scratch/nsclf_replay'
CLS = ('noise', 'cw', 'lfm', 'bpsk')
MARG = max(2, W // 8)
SNR_EDGES = [-5.0 + 2.5 * k for k in range(13)]          # accuracy.md bins: -5 .. 25 dB in 2.5 dB steps
LAT_EDGES = [-5.0, 0.0, 5.0, 10.0, 15.0, 20.0, 25.0]
DENSE_SPAN = {}              # filled from the dense captures: the sparse captures (166 pulses) cannot fit h as well
SIG = [f'sig_s{k}' for k in range(8)]


def is_dense(stem: str) -> bool:
    """Dense signal-set captures: sig_s* (no TX lead-in) and sigL_s* (31.5 ms TX lead-in, 2026-11-03)."""
    return stem.startswith('sig')
EVT = ['evt_s100', 'evt_s101']


def is_evt(stem: str) -> bool:
    """Sparse event captures (evt_s*)."""
    return stem.startswith('evt')


NOISE = ['noise_s0', 'noise_s1']
MODEL = {'test_overall': 81.5, 'test_snr_ge10': 96.0, 'float_overall': 85.7, 'float_snr_ge10': 98.3,
         'per_class_overall': [90.0, 79.9, 78.1, 78.2], 'per_class_snr_ge10': [89.9, 98.5, 98.3, 97.4],
         'bins_2p5db': [34.3, 45.3, 63.2, 79.0, 87.6, 92.6, 94.8, 96.0, 96.1, 96.5, 96.4, 96.5],
         'source': 'evidence/stage5/accuracy.md (exported model = RTL, channel-model test set, 100,000 windows)'}


# ----------------------------------------------------------------------------------------------- loading
def load_capture(stem: str):
    meta = json.loads((CAP / f'{stem}.json').read_text())
    z = np.load(CAP / f'{stem}.npz')
    y = z['i'].astype(np.float64) + 1j * z['q'].astype(np.float64)
    return meta, y


def load_decisions(stem: str, meta: dict, n_rx: int):
    """Silicon decisions (proven): the dump's recomputed window must equal the silicon read-back."""
    z = np.load(REPLAY / stem / 'decisions.npz')
    words = z['words']
    tau0 = int(z['tau0'])
    t_tap0 = int(meta['T_host_first_sample']) - RADIO_RX_OFFSET
    assert tau0 == t_tap0 + W - 1, (tau0, t_tap0)
    assert len(words) == n_rx - (W - 1)
    wn = meta['window']
    wl = [int(x) for x in words]
    taus = range(tau0, tau0 + len(wl))
    r = m.window(taus, wl, [x & 3 for x in wl], wn['t_start'], wn['n'])
    for f in ('misr', 'count', 'hist', 'tfirst', 'tlast'):
        if r[f] != wn[f]:
            raise SystemExit(f'{stem}: decisions.npz {f} {r[f]} != silicon {wn[f]}: not the silicon decisions')
    return (words & np.uint64(3)).astype(np.int8), words, tau0, r['misr']


# ----------------------------------------------------------------------------------------------- loop response
def loop_response(x: np.ndarray, y: np.ndarray, pre: int):
    from scipy.linalg import solve_toeplitz
    nfft = 1 << int(np.ceil(np.log2(len(y) + len(x))))
    X = np.fft.fft(x.astype(np.complex128), nfft)
    Y = np.fft.fft(y, nfft)
    c = np.fft.ifft(Y * np.conj(X))                     # c[l] = sum_k y[k + l] conj(x[k])
    r = np.fft.ifft(X * np.conj(X))                     # TX autocorrelation
    lg = np.arange(pre - 200, pre + 3000)
    d0 = int(lg[np.argmax(np.abs(c[lg]))])
    ls = np.arange(d0 - 48, d0 + 96)
    n = len(ls)
    h = solve_toeplitz((r[:n], np.conj(r[:n])), c[ls])
    p = np.abs(h) ** 2
    k = int(np.argmax(p))
    a = np.abs(h)
    if 0 < k < n - 1:
        den = a[k - 1] - 2 * a[k] + a[k + 1]
        frac = 0.5 * (a[k - 1] - a[k + 1]) / den if den != 0 else 0.0
    else:
        frac = 0.0
    lags = ls - pre
    # smallest contiguous lag span holding 99.95 % of the energy
    tot, best = p.sum(), (0, n - 1)
    for i0 in range(n):
        acc = 0.0
        for i1 in range(i0, n):
            acc += p[i1]
            if acc >= 0.9995 * tot:
                if i1 - i0 < best[1] - best[0]:
                    best = (i0, i1)
                break
    # residual of the linear model during playback (what the linear loop does not explain)
    yhat = np.zeros(len(y), np.complex128)
    for j, l in enumerate(ls):
        seg = x[:max(0, min(len(x), len(y) - l))]
        yhat[l:l + len(seg)] += h[j] * seg
    span = slice(pre, pre + len(x))
    resid = float(np.mean(np.abs(y[span] - yhat[span]) ** 2))
    far = np.abs(lg - d0) > 64
    side = float(np.max(np.abs(c[lg][far])) / np.abs(c[d0]))     # highest correlation more than 64 lags away
    return {'d0_xcorr': d0 - pre, 'D_int': int(lags[k]), 'D': float(lags[k] + frac), 'lo': int(lags[best[0]]),
            'hi': int(lags[best[1]]), 'h_db': {int(l): float(10 * np.log10(p[j] / p[k])) for j, l in enumerate(lags)
                                               if p[j] > 1e-5 * p[k]},
            'gain_db': float(10 * np.log10(tot) - 20 * np.log10(32768.0)), 'phase_deg': float(np.degrees(np.angle(h[k]))),
            'resid_power': resid, 'xcorr_peak_to_median': float(np.abs(c[d0]) / np.median(np.abs(c[lg]))),
            'xcorr_highest_beyond_64_lags_rel': side}


# ----------------------------------------------------------------------------------------------- labels
def labels(meta, pulses, n_tx, n_dec, pre, lo, hi, d_frac):
    """Per decision: label class (0..3), kind (0 pure, 1 straddle, 2 bpsk_norev), pulse id (-1 for noise / straddle),
    region for noise windows (0 pre-TX idle, 1 during playback, 2 after playback)."""
    lab = np.full(n_dec, -1, np.int8)
    kind = np.ones(n_dec, np.int8)
    pid = np.full(n_dec, -1, np.int32)
    region = np.full(n_dec, -1, np.int8)
    j = np.arange(n_dec)
    a_tx = j - pre - hi              # first TX sample window j depends on
    b_tx = j + W - 1 - pre - lo      # last
    st = np.array([p['start'] for p in pulses])
    en = np.array([p['start'] + p['len'] for p in pulses])
    for i, p in enumerate(pulses):
        j0 = p['start'] + pre + hi
        j1 = p['start'] + p['len'] - 1 + pre + lo - (W - 1)
        j0, j1 = max(j0, 0), min(j1, n_dec - 1)
        if j1 < j0:
            continue
        lab[j0:j1 + 1] = p['cls']
        kind[j0:j1 + 1] = 0
        pid[j0:j1 + 1] = i
        if p['cls'] == 3:
            bits = np.array(p['bits'])
            cb = np.flatnonzero(bits[1:] != bits[:-1]) + 1                  # chip c starts a new bit value
            pos = pre + d_frac + p['start'] + cb * FS / p['chip_rate']       # RX position of each reversal
            jj = np.arange(j0, j1 + 1)
            # window position of reversal = pos - j; need MARG <= pos - j <= W - MARG for some reversal
            ok = np.zeros(len(jj), bool)
            for q in pos:
                ok |= (q - jj >= MARG) & (q - jj <= W - MARG)
            kind[jj[~ok]] = 2
    # noise: the TX dependence [a_tx, b_tx] holds no pulse sample
    idx = np.searchsorted(st, a_tx, side='right') - 1     # last pulse starting at or before a_tx
    prev_end = np.where(idx >= 0, en[np.clip(idx, 0, None)], -10 ** 12)
    nxt = np.clip(idx + 1, 0, len(st) - 1)
    next_start = np.where(idx + 1 < len(st), st[nxt], 10 ** 12)
    noise = (a_tx >= prev_end) & (b_tx < next_start)
    lab[noise] = 0
    region[noise] = np.where(a_tx[noise] < 0, 0, np.where(b_tx[noise] >= n_tx, 2, 1))
    # labelled noise = during playback only (the TX chain is in the same state as around the pulses); windows
    # touching the time before TX starts or after the burst ends (a DC step appears there) are kind 3, excluded
    kind[noise] = np.where(region[noise] == 1, 0, 3)
    return lab, kind, pid, region


def rx_noise_mask(n_rx, pulses, n_tx, pre, lo, hi):
    """RX samples whose whole TX dependence lies in a gap during playback (for the noise power)."""
    r = np.arange(n_rx)
    a, b = r - pre - hi, r - pre - lo
    busy = np.zeros(n_tx + 1, np.int32)
    for p in pulses:
        busy[p['start']] += 1
        busy[p['start'] + p['len']] -= 1
    occ = np.concatenate([[0], np.cumsum(np.cumsum(busy)[:n_tx] != 0)])   # occ[t] = busy samples in TX [0, t)
    ok = (a >= 0) & (b < n_tx)
    aa, bb = np.clip(a, 0, n_tx), np.clip(b + 1, 0, n_tx)
    ok &= (occ[bb] - occ[aa]) == 0
    return ok


# ----------------------------------------------------------------------------------------------- per capture
def pct(x):
    x = np.asarray(x, float)
    if len(x) == 0:
        return None
    return {'n': int(len(x)), 'min': float(x.min()), 'median': float(np.median(x)), 'p90': float(np.percentile(x, 90)),
            'max': float(x.max()), 'mean': float(x.mean())}


def acc(pred, true):
    return float(100.0 * np.mean(pred == true)) if len(true) else None


def acc_counts(cls, lab, wsnr, sel) -> dict:
    """Counts over the selected labelled windows: confusion, and per SNR bin per signal class (n, n_correct)."""
    cm = np.zeros((4, 4), np.int64)
    np.add.at(cm, (lab[sel].astype(int), cls[sel].astype(int)), 1)
    edges = [-np.inf] + SNR_EDGES + [np.inf]
    bn, bok = [], []
    for b0, b1 in zip(edges[:-1], edges[1:]):
        s2 = sel & (lab > 0) & (wsnr >= b0) & (wsnr < b1)
        bn.append([int(np.sum(s2 & (lab == c))) for c in (1, 2, 3)])
        bok.append([int(np.sum(s2 & (lab == c) & (cls == c))) for c in (1, 2, 3)])
    return {'confusion': cm.tolist(), 'bin_n': bn, 'bin_ok': bok}


def acc_metrics(cnt: dict) -> dict:
    """Accuracy figures from (pooled) counts. Class-balanced = mean of the per-class accuracies (the model's test set
    is 25 % per class, noise windows tagged with a random SNR, so its SNR >= 10 figure = mean(noise, CW>=10,
    LFM>=10, BPSK>=10))."""
    cm = np.array(cnt['confusion'])
    bn, bok = np.array(cnt['bin_n']), np.array(cnt['bin_ok'])
    pc = [float(100.0 * cm[c, c] / cm[c].sum()) if cm[c].sum() else None for c in range(4)]
    edges = [-np.inf] + SNR_EDGES + [np.inf]
    ge = np.array([e >= 10 for e in edges[:-1]])
    n10, ok10 = bn[ge].sum(0), bok[ge].sum(0)
    pc10 = [pc[0]] + [float(100.0 * o / n) if n else None for o, n in zip(ok10, n10)]
    bins = []
    for i, (b0, b1) in enumerate(zip(edges[:-1], edges[1:])):
        per = [float(100.0 * o / n) if n else None for o, n in zip(bok[i], bn[i])]
        bins.append({'lo': b0 if np.isfinite(b0) else None, 'hi': b1 if np.isfinite(b1) else None,
                     'n_per_class': bn[i].tolist(), 'acc_per_class': per,
                     'class_balanced': float(np.mean([pc[0]] + per)) if all(v is not None for v in per + [pc[0]]) else None,
                     'signal_window_weighted': float(100.0 * bok[i].sum() / bn[i].sum()) if bn[i].sum() else None})
    ok = all(v is not None for v in pc)
    inr = np.array([(e >= -5) and (e < 25) for e in edges[:-1]])      # the model's SNR range [-5, 25) dB
    nin, okin = bn[inr].sum(0), bok[inr].sum(0)
    pcin = [pc[0]] + [float(100.0 * o / n) if n else None for o, n in zip(okin, nin)]
    ok_in = all(v is not None for v in pcin)
    return {'n_windows': int(cm.sum()),
            'in_model_snr_range_per_class': pcin,
            'in_model_snr_range_class_balanced': float(np.mean(pcin)) if ok_in else None, 'n_per_class': cm.sum(1).tolist(), 'confusion': cm.tolist(),
            'overall_window_weighted': float(100.0 * np.trace(cm) / cm.sum()) if cm.sum() else None,
            'per_class': pc, 'class_balanced': float(np.mean(pc)) if ok else None,
            'snr_ge10_per_class': pc10,
            'snr_ge10_class_balanced': float(np.mean(pc10)) if all(v is not None for v in pc10) else None,
            'snr_ge10_signal_window_weighted': float(100.0 * ok10.sum() / n10.sum()) if n10.sum() else None,
            'bins': bins}


def pool_counts(cnts: list[dict]) -> dict:
    return {k: np.sum([c[k] for c in cnts], axis=0).tolist() for k in ('confusion', 'bin_n', 'bin_ok')}


def analyze(stem: str) -> dict:
    meta, y = load_capture(stem)
    n_rx = len(y)
    cls, words, tau0, misr = load_decisions(stem, meta, n_rx)
    global L_PIPE
    L_PIPE = int(meta['registers']['LATENCY'])
    n_dec = len(cls)
    T = int(meta['T_host_first_sample'])
    t_tap0 = T - RADIO_RX_OFFSET
    out = {'stem': stem, 'T_host_first_sample': T, 'n_rx': n_rx, 'n_decisions': n_dec, 'k_reg': meta['k'],
           'silicon_misr': f"{meta['window']['misr']:#018x}", 'dump_misr_equal': True,
           'silicon_hist': meta['window']['hist'], 'registers': meta['registers'], 'rx_gain': meta.get('gain'),
           'dc_offset': meta.get('dc_offset', 'auto (UHD default)')}
    tx = meta.get('tx')
    if not tx or 'seed' not in tx:                      # noise-only capture
        out['type'] = 'noise'
        out['fa_per_decision_pct'] = float(100.0 * np.mean(cls != 0))
        out['fa_per_class_pct'] = [float(100.0 * np.mean(cls == c)) for c in range(4)]
        ev = m.hysteresis(range(n_dec), [int(c) for c in cls], 16)
        out['k16_events_derived'] = len(ev)
        out['k16_events_per_s_derived'] = len(ev) / (n_dec / FS)
        out['noise_power'] = float(np.mean(np.abs(y) ** 2))
        out['dc'] = [float(y.real.mean()), float(y.imag.mean())]
        print(f"{stem}: noise-only, FA/decision {out['fa_per_decision_pct']:.3f} %, per class "
              f"{[round(v, 4) for v in out['fa_per_class_pct']]}, K=16 events (derived) {len(ev)} "
              f"= {out['k16_events_per_s_derived']:.0f}/s", flush=True)
        return out
    out['type'] = 'signal'
    x, lab_tx, pulses = tr.make_tx(tx['seed'], tx['n_tx'], tx['amp'], tx['att_db'], tuple(tx['gap_us']))
    assert len(pulses) == tx['n_pulses'], (len(pulses), tx['n_pulses'])
    pre = int(meta['tx_start_host_ticks']) - T
    assert pre == tr.PRE
    lr = loop_response(x, y, pre)
    out['loop'] = lr
    D_int, D, lo, hi = lr['D_int'], lr['D'], lr['lo'], lr['hi']
    if is_evt(stem) and DENSE_SPAN:
        # the analog response is the same hardware: use the dense captures' guard span (README section 3)
        lr['lo_own'], lr['hi_own'] = lo, hi
        lo, hi = DENSE_SPAN['lo'], DENSE_SPAN['hi']
        lr['lo'], lr['hi'] = lo, hi
    out['guard'] = {'lead': hi - D_int, 'trail': D_int - lo,
                    'meaning': 'window must start >= hi samples after the pulse TX start (+PRE) and end <= lo after its '
                               'last TX sample; [lo, hi] = 99.95 % energy span of h'}
    # noise power and pulse SNR
    nm = rx_noise_mask(n_rx, pulses, len(x), pre, lo, hi)
    # the slowly varying DC (TX burst step minus the rx_dcoffset IIR, README) is not noise in the model's sense
    # (the model adds DC separately): estimate it from the gap samples in blocks of 2^16 and remove it before the
    # powers are measured
    blk = 1 << 16
    gi = np.flatnonzero(nm)
    cen, dcv = [], []
    for b0 in range(0, n_rx, blk):
        g = gi[(gi >= b0) & (gi < b0 + blk)]
        if len(g) > 1000:
            cen.append(g.mean())
            dcv.append(y[g].mean())
    dcv = np.array(dcv)
    dc_t = np.interp(np.arange(n_rx), cen, dcv.real) + 1j * np.interp(np.arange(n_rx), cen, dcv.imag)
    yac = y - dc_t
    N = float(np.mean(np.abs(yac[nm]) ** 2))
    pre_idle = y[:pre + lo - 1]
    out['noise'] = {'N_gaps_during_tx': N, 'N_gaps_incl_dc': float(np.mean(np.abs(y[nm]) ** 2)), 'n_samples': int(nm.sum()),
                    'N_pre_tx_idle': float(np.var(pre_idle)), 'dc_gaps': [float(y[nm].real.mean()), float(y[nm].imag.mean())],
                    'N_dbfs': float(10 * np.log10(N) - 20 * np.log10(32768.0)),
                    'dc_block_estimate_first_last': [[float(dcv[0].real), float(dcv[0].imag)],
                                                     [float(dcv[-1].real), float(dcv[-1].imag)]]}
    snr = np.full(len(pulses), np.nan)
    for i, p in enumerate(pulses):
        r0, r1 = pre + p['start'] + hi, pre + p['start'] + p['len'] - 1 + lo
        if r1 <= r0:
            r0, r1 = pre + p['start'] + D_int, pre + p['start'] + p['len'] + D_int - 1
        P = float(np.mean(np.abs(yac[r0:r1 + 1]) ** 2))
        snr[i] = 10 * np.log10(max(P - N, 1e-3 * N) / N)
    a_db = np.array([p['a_db'] for p in pulses])
    pc = np.array([p['cls'] for p in pulses])
    hi_amp = a_db > -15
    off = snr[hi_amp] - a_db[hi_amp]
    out['snr'] = {'pulse_snr_db': pct(snr), 'peak_snr_est_db': float(np.median(off)),
                  'peak_snr_est_spread_db_p10_p90': [float(np.percentile(off, 10)), float(np.percentile(off, 90))],
                  'fit_slope': float(np.polyfit(a_db[hi_amp], snr[hi_amp], 1)[0]),
                  'frac_in_m5_25': float(np.mean((snr >= -5) & (snr < 25))),
                  'per_class_peak_snr_est_db': [float(np.median((snr - a_db)[hi_amp & (pc == c)])) for c in (1, 2, 3)]}
    # labels
    lab, kind, pid, region = labels(meta, pulses, len(x), n_dec, pre, lo, hi, D)
    pure = kind == 0
    idle = (kind == 3)
    wsnr = np.where(pid >= 0, snr[np.clip(pid, 0, None)], np.nan)
    out['windows'] = {'pure': int(pure.sum()), 'straddle': int((kind == 1).sum()), 'bpsk_norev': int((kind == 2).sum()),
                      'tx_idle_noise': int(idle.sum()),
                      'pure_per_class': [int(np.sum(pure & (lab == c))) for c in range(4)],
                      'noise_by_region_pre_during_post': [int(np.sum((lab == 0) & (region == g))) for g in range(3)]}
    # settled: the window starts >= 2 x 2^20 samples (2 time constants of rx_dcoffset, 10.5 ms) after the burst's
    # arrival; the DC step at the burst start has then decayed to e^-2 of its size (README: DC transient)
    # with a TX lead-in (nsclf_txrx.py --lead, TX on with zeros before the signal set) the burst arrived lead
    # samples earlier, so a lead >= 2 x 2^20 makes every window settled
    settle_rx = max(0, pre + D_int + 2 * (1 << 20) - int(meta.get('tx_lead', 0)))
    settled = np.arange(n_dec) >= settle_rx
    out['settle_rx_index'] = int(settle_rx)
    out['counts'] = acc_counts(cls, lab, wsnr, pure)
    out['counts_settled'] = acc_counts(cls, lab, wsnr, pure & settled)
    out['acc'] = acc_metrics(out['counts'])
    out['acc_settled'] = acc_metrics(out['counts_settled'])
    pcacc = out['acc']['per_class']
    out['acc']['noise_by_region_pre_during_post'] = [acc(cls[(lab == 0) & (region == g)], lab[(lab == 0) & (region == g)])
                                                     for g in range(3)]
    # DC of the gaps around the burst start / end (TX-chain state change, removed by the rx_dcoffset IIR)
    gi = np.flatnonzero(nm)
    first = gi[gi < pre + D_int + (1 << 17)]
    last = gi[gi >= settle_rx]
    post = y[pre + len(x) + hi + 200:]
    out['dc'] = {'gaps_first_0p66ms': [float(y[first].real.mean()), float(y[first].imag.mean())] if len(first) else None,
                 'gaps_settled': [float(y[last].real.mean()), float(y[last].imag.mean())] if len(last) else None,
                 'after_burst_end': [float(post.real.mean()), float(post.imag.mean())] if len(post) else None,
                 'pre_tx': [float(y[:pre + lo - 1].real.mean()), float(y[:pre + lo - 1].imag.mean())],
                 'noise_rms': float(np.sqrt(N)),
                 'N_gaps_settled': float(np.mean(np.abs(y[last]) ** 2)) if len(last) else None}
    # time structure of the capture: gap DC and noise-window accuracy per 2^19-sample block (the rx_dcoffset transient)
    jj = np.arange(n_dec)
    tr_ = []
    for b0 in range(0, n_rx, 1 << 19):
        gsel = gi[(gi >= b0) & (gi < b0 + (1 << 19))]
        nsel = pure & (lab == 0) & (jj >= b0) & (jj < b0 + (1 << 19))
        tr_.append({'rx_start': b0, 'ms': b0 / FS * 1e3, 'gap_dc': [float(y[gsel].real.mean()), float(y[gsel].imag.mean())] if len(gsel) else None,
                    'n_noise': int(nsel.sum()), 'noise_ok': int(np.sum(cls[nsel] == 0)), 'noise_as_cw': int(np.sum(cls[nsel] == 1))})
    out['transient'] = tr_
    # BPSK breakdown (settled windows of pulses at SNR >= 10 dB): code type and chip rate
    bsel = pure & settled & (lab == 3) & (wsnr >= 10)
    bk = {}
    for i_, p_ in enumerate(pulses):
        if p_['cls'] != 3:
            continue
        rb = int(min(2, max(0, (p_['chip_rate'] - 5e6) // 5e6)))
        m_ = bsel & (pid == i_)
        key = f"{'barker' if p_['barker'] else 'random'}_rate{5 + 5 * rb}-{10 + 5 * rb}"
        n_, k_ = int(m_.sum()), int(np.sum(m_ & (cls == 3)))
        a_ = bk.setdefault(key, [0, 0, [0, 0, 0, 0]])
        a_[0] += n_
        a_[1] += k_
        for c_ in range(4):
            a_[2][c_] += int(np.sum(m_ & (cls == c_)))
    out['bpsk_breakdown_snr_ge10_settled'] = bk
    # BPSK windows without a reversal (excluded) and straddling windows (excluded), for information
    nr = kind == 2
    out['bpsk_norev_pred_hist'] = np.bincount(cls[nr], minlength=4).tolist()
    # chance of a spurious decision of each class per decision in labelled noise (for the latency reading)
    out['noise_pred_frac'] = [float(np.mean(cls[pure & (lab == 0)] == c)) for c in range(4)]
    out['noise_pred_frac_settled'] = [float(np.mean(cls[pure & settled & (lab == 0)] == c)) for c in range(4)]
    # stream-level: label = class at the newest sample (TX label at RX index - PRE - D_int)
    k_new = np.arange(n_dec) + W - 1 - pre - D_int
    slab = np.where((k_new >= 0) & (k_new < len(x)), lab_tx[np.clip(k_new, 0, len(x) - 1)], 0)
    scm = np.zeros((4, 4), np.int64)
    np.add.at(scm, (slab.astype(int), cls.astype(int)), 1)
    out['stream'] = {'agreement': acc(cls, slab), 'confusion': scm.tolist(),
                     'per_class': [float(100.0 * scm[c, c] / scm[c].sum()) for c in range(4)],
                     'straddle_agreement': acc(cls[kind == 1], slab[kind == 1])}
    # detection latency per pulse
    lat = []
    for i, p in enumerate(pulses):
        on = pre + p['start'] + D_int                 # RX index of the onset (first TX sample at the response peak)
        prev_end = pulses[i - 1]['start'] + pulses[i - 1]['len'] if i else -10 ** 9
        # decisions whose newest sample is >= onset and whose window no longer depends on the previous pulse
        j_lo = max(on - (W - 1), prev_end + pre + hi)
        j_hi = pre + p['start'] + p['len'] + D_int - 1   # last decision whose window still holds pulse samples
        j_lo, j_hi = max(j_lo, 0), min(j_hi, n_dec - 1)
        seg = cls[j_lo:j_hi + 1] == p['cls']
        hit = np.flatnonzero(seg)
        d = int(hit[0] + j_lo + W - 1 - on) if len(hit) else None
        # stricter: start of the first run of 16 consecutive decisions of the class (K = 16 would declare it at
        # the run's 16th decision, i.e. 15 samples later)
        run = np.flatnonzero(np.convolve(seg.astype(np.int32), np.ones(16, np.int32), 'valid') == 16) if len(seg) >= 16 else []
        d16 = int(run[0] + j_lo + W - 1 - on) if len(run) else None
        lat.append({'cls': p['cls'], 'snr': float(snr[i]), 'len': p['len'], 'onset_tap': t_tap0 + on,
                    'first_allowed': int(j_lo + W - 1 - on), 'settled': bool(on - (W - 1) >= settle_rx),
                    'delay': d, 'run16': d16, 'end_tap': t_tap0 + pre + p['start'] + p['len'] + D_int - 1})
    out['latency_pulses'] = lat
    # events (sparse runs): silicon event records vs pulse onsets
    if meta.get('events'):
        ev = sorted(meta['events'], key=lambda e: e['tau'])
        et = np.array([e['tau'] for e in ev], np.int64)
        en_ = np.array([e['new'] for e in ev])
        ed = []
        for q in lat:
            sel = np.flatnonzero((et >= q['onset_tap']) & (et <= q['end_tap'] + W - 1 + 16 + L_PIPE) & (en_ == q['cls']))
            ed.append(int(et[sel[0]] - q['onset_tap']) if len(sel) else None)
        for q, e in zip(lat, ed):
            q['event_delay'] = e
        # events not explained by a pulse's class change within its span (false events)
        in_any = np.zeros(len(et), bool)
        for q in lat:
            in_any |= (et >= q['onset_tap']) & (et <= q['end_tap'] + W - 1 + 16 + L_PIPE)
        t_set = t_tap0 + settle_rx
        t_end = t_tap0 + n_rx - 1
        wsel = (et >= meta['window']['t_start']) & (et <= meta['window']['t_start'] + meta['window']['n'] - 1)
        out['events'] = {'n': len(ev), 'n_in_capture_window': int(wsel.sum()), 'n_after_window_end': int((et > t_end).sum()),
                         'n_outside_settled_in_window': int(((~in_any) & (et >= t_set) & wsel).sum()),
                         'n_pulse_spans_settled': int(sum(1 for q in lat if q['settled'])),
                         'settled_window_seconds': float((t_end - t_set) / FS),
                         'n_in_pulse_spans': int(in_any.sum()), 'n_outside': int((~in_any).sum()),
                         'new_class_hist': np.bincount(en_, minlength=4).tolist(),
                         'pulses_with_event_of_class': int(sum(e is not None for e in ed)), 'pulses': len(lat)}
    print(f"{stem}: D={D:.3f} (int {D_int}, xcorr {lr['d0_xcorr']}) span [{lo},{hi}] N={out['noise']['N_dbfs']:.1f} dBFS "
          f"peakSNR~{out['snr']['peak_snr_est_db']:.1f} dB pure={out['windows']['pure']} straddle={out['windows']['straddle']} "
          f"acc {out['acc']['overall_window_weighted']:.2f} / bal {out['acc']['class_balanced']:.2f} / >=10 bal "
          f"{out['acc']['snr_ge10_class_balanced']:.2f} per class {[round(v, 1) for v in pcacc]}; settled bal "
          f"{out['acc_settled']['class_balanced']:.2f} / >=10 bal {out['acc_settled']['snr_ge10_class_balanced']:.2f} "
          f"per class {[round(v, 1) for v in out['acc_settled']['per_class']]}", flush=True)
    return out


# ----------------------------------------------------------------------------------------------- aggregation
def aggregate(res: list[dict]) -> dict:
    sig = [r for r in res if r['type'] == 'signal']
    agg = {'captures': [r['stem'] for r in sig]}
    agg['acc'] = acc_metrics(pool_counts([r['counts'] for r in sig]))
    agg['acc_settled'] = acc_metrics(pool_counts([r['counts_settled'] for r in sig]))
    for sub in ('acc', 'acc_settled'):
        for k in ('overall_window_weighted', 'class_balanced', 'snr_ge10_class_balanced'):
            v = [r[sub][k] for r in sig]
            agg[sub][f'spread_{k}'] = {'mean': float(np.mean(v)), 'std': float(np.std(v, ddof=1)) if len(v) > 1 else 0.0,
                                       'min': float(np.min(v)), 'max': float(np.max(v))}
        v = np.array([r[sub]['per_class'] for r in sig])
        agg[sub]['spread_per_class'] = {'mean': v.mean(0).tolist(),
                                        'std': (v.std(0, ddof=1) if len(v) > 1 else 0 * v[0]).tolist(),
                                        'min': v.min(0).tolist(), 'max': v.max(0).tolist()}
    scm = np.sum([r['stream']['confusion'] for r in sig], axis=0)
    agg['stream'] = {'agreement': float(100 * np.trace(scm) / scm.sum()),
                     'per_class': [float(100 * scm[c, c] / scm[c].sum()) for c in range(4)], 'confusion': scm.tolist()}
    agg['windows'] = {k: int(np.sum([r['windows'][k] for r in sig])) for k in ('pure', 'straddle', 'bpsk_norev',
                                                                                 'tx_idle_noise')}
    agg['windows']['pure_per_class'] = np.sum([r['windows']['pure_per_class'] for r in sig], axis=0).tolist()
    bk = {}
    for r in sig:
        for k, (n_, ok_, h_) in r['bpsk_breakdown_snr_ge10_settled'].items():
            a_ = bk.setdefault(k, [0, 0, [0, 0, 0, 0]])
            a_[0] += n_
            a_[1] += ok_
            a_[2] = [x + y for x, y in zip(a_[2], h_)]
    agg['bpsk_breakdown_snr_ge10_settled'] = {k: {'n': v[0], 'acc': 100.0 * v[1] / v[0] if v[0] else None, 'pred_hist': v[2]}
                                              for k, v in sorted(bk.items())}
    tb = []
    for bi in range(len(sig[0]['transient'])):
        n_ = sum(r['transient'][bi]['n_noise'] for r in sig)
        gdc = [r['transient'][bi]['gap_dc'] for r in sig if r['transient'][bi]['gap_dc']]
        tb.append({'ms': sig[0]['transient'][bi]['ms'], 'gap_dc': np.mean(gdc, axis=0).tolist() if gdc else None,
                   'n_noise': n_, 'noise_acc': 100.0 * sum(r['transient'][bi]['noise_ok'] for r in sig) / n_ if n_ else None,
                   'noise_as_cw': 100.0 * sum(r['transient'][bi]['noise_as_cw'] for r in sig) / n_ if n_ else None})
    agg['transient'] = tb
    agg['bpsk_norev_pred_hist'] = np.sum([r['bpsk_norev_pred_hist'] for r in sig], axis=0).tolist()
    # latency
    lat = [q for r in sig for q in r['latency_pulses']]
    def lat_tab(sel_fn, key='delay'):
        d = [q[key] for q in lat if sel_fn(q) and q.get(key) is not None]
        n = sum(1 for q in lat if sel_fn(q))
        t = pct(d)
        if t:
            t['detected_frac'] = len(d) / n
            t['pulses'] = n
        return t
    agg['latency'] = {'per_class': {CLS[c]: lat_tab(lambda q, c=c: q['cls'] == c) for c in (1, 2, 3)},
                      'per_snr': [{'lo': b0, 'hi': b1, 'all': lat_tab(lambda q, b0=b0, b1=b1: b0 <= q['snr'] < b1),
                                   **{CLS[c]: lat_tab(lambda q, b0=b0, b1=b1, c=c: b0 <= q['snr'] < b1 and q['cls'] == c)
                                      for c in (1, 2, 3)}}
                                  for b0, b1 in zip(LAT_EDGES[:-1], LAT_EDGES[1:])],
                      'snr_ge10': {CLS[c]: lat_tab(lambda q, c=c: q['snr'] >= 10 and q['cls'] == c) for c in (1, 2, 3)},
                      'run16_per_class': {CLS[c]: lat_tab(lambda q, c=c: q['cls'] == c, 'run16') for c in (1, 2, 3)},
                      'run16_snr_ge10': {CLS[c]: lat_tab(lambda q, c=c: q['snr'] >= 10 and q['cls'] == c, 'run16')
                                         for c in (1, 2, 3)},
                      'settled_per_class': {CLS[c]: lat_tab(lambda q, c=c: q['cls'] == c and q['settled']) for c in (1, 2, 3)},
                      'settled_snr_ge10': {CLS[c]: lat_tab(lambda q, c=c: q['snr'] >= 10 and q['cls'] == c and q['settled'])
                                           for c in (1, 2, 3)},
                      'settled_run16_snr_ge10': {CLS[c]: lat_tab(lambda q, c=c: q['snr'] >= 10 and q['cls'] == c
                                                                 and q['settled'], 'run16') for c in (1, 2, 3)}}
    D = [r['loop']['D'] for r in sig]
    agg['loop_delay'] = {'D_per_capture': {r['stem']: r['loop']['D'] for r in sig},
                         'D_int_per_capture': {r['stem']: r['loop']['D_int'] for r in sig},
                         'mean': float(np.mean(D)), 'std': float(np.std(D, ddof=1)) if len(D) > 1 else 0.0,
                         'min': float(np.min(D)), 'max': float(np.max(D)),
                         'span_lo_hi': {r['stem']: [r['loop']['lo'], r['loop']['hi']] for r in sig}}
    return agg


def event_latency(res):
    lat = [q for r in res if r['type'] == 'signal' and is_evt(r['stem']) for q in r['latency_pulses']]

    def tab(sel):
        qs = [q for q in lat if sel(q)]
        d = [q['event_delay'] for q in qs if q.get('event_delay') is not None]
        t = pct(d)
        if t:
            t['detected_frac'] = len(d) / len(qs)
            t['pulses'] = len(qs)
        return t
    out = {}
    for c in (1, 2, 3):
        out[CLS[c]] = tab(lambda q, c=c: q['cls'] == c)
        out[CLS[c] + '_snr_ge10'] = tab(lambda q, c=c: q['cls'] == c and q['snr'] >= 10)
    out['all'] = tab(lambda q: True)
    out['all_snr_ge10'] = tab(lambda q: q['snr'] >= 10)
    out['all_snr_ge10_settled'] = tab(lambda q: q['snr'] >= 10 and q['settled'])
    return out


# ----------------------------------------------------------------------------------------------- report
def f1(v, nd=1):
    return '-' if v is None else f'{v:.{nd}f}'


def acc_table(L, A, label):
    L.append(f"| **silicon, {label}** | {f1(A['overall_window_weighted'])} | {f1(A['class_balanced'])} | "
             f"{f1(A['snr_ge10_class_balanced'])} | " + ' | '.join(f1(v) for v in A['per_class']) + ' |')
    L.append(f"| silicon, {label}, pulse SNR in [-5, 25) dB only | | {f1(A['in_model_snr_range_class_balanced'])} | | "
             + ' | '.join(f1(v) for v in A['in_model_snr_range_per_class']) + ' |')
    L.append(f"| silicon, {label}, SNR >= 10 dB | | | {f1(A['snr_ge10_signal_window_weighted'])} (signal windows) | "
             + ' | '.join(f1(v) for v in A['snr_ge10_per_class']) + ' |')


def write_md(path: Path, summ: dict):
    S, E, Nz = summ['sig_agg'], summ.get('evt_agg'), summ['noise']
    A, B = S['acc'], S['acc_settled']
    L = ['# Stage 5 silicon tables (generated by sw/x310/nsclf_analyze.py; do not edit)\n',
         'Labels: **silicon** = decisions of the X310 (proven by MISR equality with the block read-back) against labels '
         'from the TX schedule; D, SNR and noise figures are silicon measurements of the captures; **model** figures are '
         f"from {MODEL['source']}. " '"settled" = windows starting '
         '>= 2 x 2^20 samples (10.5 ms) after the burst arrives, when the DC step at the TX burst start has decayed to '
         'e^-2 by the rx_dcoffset IIR (README section 4); with a TX lead-in >= 10.5 ms every window is settled.\n',
         f"## Accuracy, dense captures {', '.join(summ['sig_agg']['stems'])} pooled\n",
         '| | overall (window-weighted) | class-balanced | SNR >= 10 dB, class-balanced | noise | CW | LFM | BPSK |',
         '|---|---|---|---|---|---|---|---|']
    acc_table(L, A, 'all playback windows')
    acc_table(L, B, 'settled')
    M_, pc_, ph_ = MODEL, MODEL['per_class_overall'], MODEL['per_class_snr_ge10']
    L += [f"| model (exported = RTL, test; 25 % per class) | {M_['test_overall']} | {M_['test_overall']} | {M_['test_snr_ge10']} | "
          + ' | '.join(f'{v}' for v in pc_) + ' |',
          '| model, SNR >= 10 dB | | | | ' + ' | '.join(f'{v}' for v in ph_) + ' |',
          f"| float64 (test) | {M_['float_overall']} | {M_['float_overall']} | {M_['float_snr_ge10']} | | | | |\n"]
    W_ = S['windows']
    L.append(f"Labelled windows (all playback): {A['n_windows']:,} (noise / CW / LFM / BPSK "
             f"{', '.join(f'{v:,}' for v in A['n_per_class'])}); settled: {B['n_windows']:,} "
             f"({', '.join(f'{v:,}' for v in B['n_per_class'])}). Excluded: straddling {W_['straddle']:,}; BPSK without a "
             f"qualifying reversal {W_['bpsk_norev']:,} (predicted noise/CW/LFM/BPSK {S['bpsk_norev_pred_hist']}); noise "
             f"windows before the burst or after its end {W_['tx_idle_noise']:,}.\n")
    for nm_, X in (('all playback windows', A), ('settled', B)):
        L += [f'Confusion, {nm_} (rows true, columns predicted):\n', '| true \\ pred | noise | CW | LFM | BPSK |',
              '|---|---|---|---|---|']
        for c in range(4):
            L.append(f'| {CLS[c]} | ' + ' | '.join(f'{v:,}' for v in X['confusion'][c]) + ' |')
        L.append('')
    for nm_, X in (('all playback windows', A), ('settled', B)):
        L += [f'## Per SNR bin, {nm_} (measured pulse SNR, the 2.5 dB bins of accuracy.md)\n',
              '| bin (dB) | CW n | CW % | LFM n | LFM % | BPSK n | BPSK % | signal windows % | class-balanced % | model % |',
              '|---|---|---|---|---|---|---|---|---|---|']
        for bi, b in enumerate(X['bins']):
            lo = '-inf' if b['lo'] is None else f"{b['lo']:g}"
            hi = 'inf' if b['hi'] is None else f"{b['hi']:g}"
            mod = MODEL['bins_2p5db'][bi - 1] if 1 <= bi <= 12 else None
            L.append(f"| {lo}..{hi} | " + ' | '.join(f"{b['n_per_class'][c]:,} | {f1(b['acc_per_class'][c])}" for c in range(3))
                     + f" | {f1(b['signal_window_weighted'])} | {f1(b['class_balanced'])} | {f1(mod)} |")
        L.append('\nClass-balanced = mean of the noise accuracy (all labelled noise windows of the subset) and the three '
                 'signal accuracies in the bin (the model bins hold 25 % noise windows with random SNR tags).\n')
    L += ['## Per capture (silicon)\n',
          '| capture | D | span [lo, hi] | noise dBFS | peak SNR dB | DC at burst start (I, Q) | overall | class-bal. | SNR>=10 bal. | settled: class-bal. | settled: SNR>=10 bal. | settled noise / CW / LFM / BPSK | stream agreement |',
          '|---|---|---|---|---|---|---|---|---|---|---|---|---|']
    for r in summ['captures']:
        if r['type'] != 'signal':
            continue
        a, b = r['acc'], r['acc_settled']
        dc = r['dc']['gaps_first_0p66ms']
        L.append(f"| {r['stem']} | {r['loop']['D']:.3f} | [{r['loop']['lo']}, {r['loop']['hi']}] | {r['noise']['N_dbfs']:.1f} | "
                 f"{r['snr']['peak_snr_est_db']:.1f} | {dc[0]:.0f}, {dc[1]:.0f} | {f1(a['overall_window_weighted'])} | "
                 f"{f1(a['class_balanced'])} | {f1(a['snr_ge10_class_balanced'])} | {f1(b['class_balanced'])} | "
                 f"{f1(b['snr_ge10_class_balanced'])} | " + ' / '.join(f1(v) for v in b['per_class'])
                 + f" | {f1(r['stream']['agreement'])} |")
    for sub, X in (('all', A), ('settled', B)):
        for k in ('overall_window_weighted', 'class_balanced', 'snr_ge10_class_balanced'):
            s = X[f'spread_{k}']
            L.append(f"\n{sub}, {k}, over the 8 captures: mean {s['mean']:.2f}, std {s['std']:.2f}, min {s['min']:.2f}, "
                     f"max {s['max']:.2f}")
        s = X['spread_per_class']
        L.append(f'\n{sub}, per class (noise / CW / LFM / BPSK) std over captures: ' + ' / '.join(f'{v:.2f}' for v in s['std']))
    L += ['\n## Time structure (8 dense captures pooled): the DC step at the TX burst start\n',
          'Gap DC = mean of the RX samples whose TX dependence lies in a gap (after the front end\'s rx_dcoffset IIR, '
          'time constant 2^20 samples = 5.2 ms); noise windows = labelled noise windows of that block.\n',
          '| RX time (ms) | gap DC (I, Q) | noise windows | classified noise % | classified CW % |', '|---|---|---|---|---|']
    for b in S['transient']:
        dc = b['gap_dc']
        L.append(f"| {b['ms']:.1f} | " + (f"{dc[0]:.0f}, {dc[1]:.0f}" if dc else '-') + f" | {b['n_noise']:,} | "
                 f"{f1(b['noise_acc'])} | {f1(b['noise_as_cw'])} |")
    L += ['\n## BPSK breakdown (settled, pulse SNR >= 10 dB, pooled dense captures)\n',
          '| code, chip rate (Mchip/s) | windows | BPSK % | predicted noise / CW / LFM / BPSK (windows) |', '|---|---|---|---|']
    for k, v in S['bpsk_breakdown_snr_ge10_settled'].items():
        L.append(f"| {k} | {v['n']:,} | {f1(v['acc'])} | " + ' / '.join(f'{h:,}' for h in v['pred_hist']) + ' |')
    L += ['\n## Stream-level view (all decisions incl. straddling, label = class at the newest sample; information)\n',
          f"agreement {S['stream']['agreement']:.2f} %; per class " + ' / '.join(f'{v:.1f}' for v in S['stream']['per_class']) + '\n']
    L += ['## Noise-only captures (silicon; no TX burst)\n',
          '| capture | decisions | false alarm per decision % | as CW % | as LFM % | as BPSK % | K=16 events (derived) | per s | DC (I, Q) | noise dBFS |',
          '|---|---|---|---|---|---|---|---|---|---|']
    for r in Nz:
        L.append(f"| {r['stem']} | {r['n_decisions']:,} | {r['fa_per_decision_pct']:.3f} | "
                 + ' | '.join(f"{v:.3f}" for v in r['fa_per_class_pct'][1:])
                 + f" | {r['k16_events_derived']} | {r['k16_events_per_s_derived']:.0f} | {r['dc'][0]:.1f}, {r['dc'][1]:.1f} | "
                 f"{10 * np.log10(r['noise_power']) - 20 * np.log10(32768):.1f} |")
    L += ['\n## Detection latency (silicon decisions; onset from the measured D; 1 cycle = 1 sample = 5 ns)\n',
          'Delay = tau of the first raw decision of the pulse class - onset tap time (decisions whose window still holds '
          f'the previous pulse are skipped). The decision is valid on the classifier outputs L = {L_PIPE} cycles later (sim).\n',
          '| class / SNR | pulses | detected | min | median | p90 | max | median + L (ns) |', '|---|---|---|---|---|---|---|---|']

    def latrow(name, t):
        if not t:
            return f'| {name} | 0 | | | | | | |'
        return (f"| {name} | {t['pulses']:,} | {100 * t['detected_frac']:.1f} % | {t['min']:.0f} | {t['median']:.0f} | "
                f"{t['p90']:.0f} | {t['max']:.0f} | {5 * (t['median'] + L_PIPE):.0f} |")
    T_ = S['latency']
    for c in ('cw', 'lfm', 'bpsk'):
        L.append(latrow(c + ', all SNR', T_['per_class'][c]))
    for c in ('cw', 'lfm', 'bpsk'):
        L.append(latrow(c + ', SNR >= 10 dB', T_['snr_ge10'][c]))
    for c in ('cw', 'lfm', 'bpsk'):
        L.append(latrow(c + ', SNR >= 10 dB, settled', T_['settled_snr_ge10'][c]))
    for b in T_['per_snr']:
        L.append(latrow(f"all classes, {b['lo']:g}..{b['hi']:g} dB", b['all']))
    L += ['\nStricter: start of the first run of 16 consecutive decisions of the pulse class (a K = 16 hysteresis '
          'declares it 15 decisions later):\n',
          '| class / SNR | pulses | reached | min | median | p90 | max | median + L (ns) |', '|---|---|---|---|---|---|---|---|']
    for c in ('cw', 'lfm', 'bpsk'):
        L.append(latrow(c + ', all SNR', T_['run16_per_class'][c]))
    for c in ('cw', 'lfm', 'bpsk'):
        L.append(latrow(c + ', SNR >= 10 dB', T_['run16_snr_ge10'][c]))
    for c in ('cw', 'lfm', 'bpsk'):
        L.append(latrow(c + ', SNR >= 10 dB, settled', T_['settled_run16_snr_ge10'][c]))
    evs = ', '.join(c['stem'] for c in summ['captures'] if is_evt(c['stem']))
    if summ.get('event_latency'):
        L += [f'\n## K = 16 event delay (sparse captures {evs}, silicon event records as received by the host)\n',
              'Delay = event tau (the tap time of the newest sample of the K-th consecutive decision) - pulse onset.\n',
              '| class / SNR | pulses | with an event of the class | min | median | p90 | max |', '|---|---|---|---|---|---|---|']
        for c, t in summ['event_latency'].items():
            if t:
                L.append(f"| {c} | {t['pulses']} | {100 * t['detected_frac']:.1f} % | {t['min']:.0f} | {t['median']:.0f} | "
                         f"{t['p90']:.0f} | {t['max']:.0f} |")
    if E:
        L += [f'\n## Sparse captures {evs} (silicon, same labelling)\n']
        for sub in ('acc', 'acc_settled'):
            X = E[sub]
            L.append(f"{sub}: windows {X['n_windows']:,} ({', '.join(f'{v:,}' for v in X['n_per_class'])}); overall "
                     f"{f1(X['overall_window_weighted'], 2)}, class-balanced {f1(X['class_balanced'], 2)}, SNR >= 10 class-balanced "
                     f"{f1(X['snr_ge10_class_balanced'], 2)}; per class " + ' / '.join(f1(v) for v in X['per_class'])
                     + '; SNR >= 10 per class ' + ' / '.join(f1(v) for v in X['snr_ge10_per_class']) + '\n')
        for r in summ['captures']:
            if is_evt(r['stem']) and r.get('events'):
                e = r['events']
                L.append(f"{r['stem']}: {e['n']} silicon events ({e['n_in_capture_window']} with tau inside the capture window, "
                         f"{e['n_after_window_end']} after its end), {e['n_in_pulse_spans']} inside a pulse span (onset .. last "
                         f"window + K + L), {e['n_outside']} outside; outside a pulse span after the DC settled (last "
                         f"{e['settled_window_seconds'] * 1e3:.1f} ms): {e['n_outside_settled_in_window']} false events; "
                         f"new-class histogram {e['new_class_hist']}; "
                         f"{e['pulses_with_event_of_class']} of {e['pulses']} pulses have an event of their class.\n")
    D = S['loop_delay']
    L.append(f"## Loop delay D (silicon)\n\nD = {D['mean']:.3f} samples, mean over the 8 dense captures (std {D['std']:.4f}, "
             f"min {D['min']:.3f}, max {D['max']:.3f}) = {5 * D['mean']:.2f} ns; integer peak "
             f"{sorted(set(D['D_int_per_capture'].values()))}; 99.95 % energy span per capture {sorted(set(map(tuple, D['span_lo_hi'].values())))}.\n")
    path.write_text('\n'.join(L) + '\n')


def main():
    global CAP, REPLAY
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--stems', nargs='+', default=SIG + EVT + NOISE)
    ap.add_argument('--out', default=str(ROOT / 'evidence/stage5/silicon'))
    ap.add_argument('--cap', default=str(CAP), help='captures dir (v2 campaign: .scratch/s5_cap_v2)')
    ap.add_argument('--replay', default=str(REPLAY), help='decision dumps dir (v2: .scratch/nsclf_replay_v2)')
    ap.add_argument('--model-json', default=None, help='model reference numbers (keys of MODEL) for the tables; default v1')
    a = ap.parse_args()
    CAP, REPLAY = Path(a.cap), Path(a.replay)
    if a.model_json:
        MODEL.clear()
        MODEL.update(json.loads(Path(a.model_json).read_text()))
    res = []
    for s_ in a.stems:
        if is_evt(s_) and not DENSE_SPAN:
            sp = {(r['loop']['lo'], r['loop']['hi']) for r in res if r.get('type') == 'signal' and is_dense(r['stem'])}
            if len(sp) == 1:
                DENSE_SPAN.update(lo=list(sp)[0][0], hi=list(sp)[0][1])
            elif sp:
                DENSE_SPAN.update(lo=min(x[0] for x in sp), hi=max(x[1] for x in sp))
        res.append(analyze(s_))
    summ = {'generator': 'sw/x310/nsclf_analyze.py', 'model': MODEL, 'captures': [], 'noise': []}
    for r in res:
        r2 = {k: v for k, v in r.items() if k != 'latency_pulses'}
        if r['type'] == 'signal':
            r2['loop'] = {k: v for k, v in r['loop'].items()}
        summ['captures'].append(r2)
        if r['type'] == 'noise':
            summ['noise'].append(r2)
    sig = [r for r in res if r['type'] == 'signal' and is_dense(r['stem'])]
    if sig:
        summ['sig_agg'] = aggregate(sig)
        summ['sig_agg']['stems'] = [r['stem'] for r in sig]
    ev = [r for r in res if r['type'] == 'signal' and is_evt(r['stem'])]
    if ev:
        summ['evt_agg'] = aggregate(ev)
        summ['event_latency'] = event_latency(ev)
        summ['evt_agg'].pop('latency', None)
        summ['evt_agg'].pop('loop_delay', None)
    out = Path(a.out)
    (out / 'summary.json').write_text(json.dumps(summ, indent=1) + '\n')
    np.savez_compressed(ROOT / f'.scratch/s5_ana_latency_{out.name}.npz',
                        **{r['stem']: np.array([[q['cls'], q['snr'], -1 if q['delay'] is None else q['delay'], q['len'],
                                                 -1 if q['run16'] is None else q['run16']]
                                                for q in r['latency_pulses']]) for r in res if r['type'] == 'signal'})
    if sig:
        write_md(out / 'analysis.md', summ)
    print(f"wrote {out / 'summary.json'}" + (f" and {out / 'analysis.md'}" if sig else ''))


if __name__ == '__main__':
    main()
