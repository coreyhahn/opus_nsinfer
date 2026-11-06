# Stage 5: why BPSK was weak on silicon, and the fix (2026-11-03)

Labels: **silicon** (from captures), **sim** (simulated RX), **model** (channel-model data).

## 1. Symptom (silicon, campaign 2, `evidence/stage5/silicon/lead/analysis.md`)

BPSK windows: 65.5 % correct (class-balanced overall 81.8 %), against 78.2 % on the model's test set; 27 % of BPSK
windows were called noise. At 0..2.5 dB pulse SNR BPSK was 22.6 % (CW 74.0 %). The model's own continuous-stream
check (`evidence/stage5/accuracy.md`) already showed BPSK at 59.6 %.

## 2. Diagnosis: the silicon behaviour is a linear channel plus the real noise (`diag_sigL_s0.log`)

`sw/x310/bpsk_diag.py sigL_s0` runs the exported model (Keras = RTL; its decisions on the capture equal the silicon
dump in 100 % of 4,210,625 windows) on the capture and on simulated RX of the same TX schedule, labelled exactly as
`nsclf_analyze.py` does (pulse SNR measured on each RX, so every row bins by its own SNR):

| RX (sigL_s0, TX seed 0) | noise | CW | LFM | BPSK | BPSK at 0..5 dB | BPSK at 5..10 dB |
|---|---|---|---|---|---|---|
| **silicon** | 99.85 | 84.9 | 77.7 | **65.1** | 33.0 | 75.8 |
| sim: Butterworth model channel + model noise | 91.9 | 97.0 | 94.5 | 93.7 | 71.5 | 87.7 |
| sim: Butterworth model channel + real noise (noise_s0) | 99.86 | 98.1 | 95.1 | 91.7 | 54.3 | 82.7 |
| sim: measured response h + model noise | 91.9 | 82.1 | 76.5 | 72.2 | 53.8 | 80.7 |
| **sim: measured response h + real noise** | 99.86 | 84.8 | 77.7 | **65.2** | 33.3 | 76.1 |

The last row matches silicon in every class and bin: nothing non-linear (phase noise, compression, timing) is
needed to explain it. (The Butterworth rows carry ~8 dB more signal, a gain-normalisation slip in the script; the
bins use each row's measured SNR, so the per-bin comparison holds.)

## 3. Root cause: the training channel model (`spectrum_sigL_s0_noise_s0.log`)

`ref/x310/x310_data.py` (channel 'lpf', D-S5-DATA) put signals and noise through a 40 MHz analog low-pass
(5th-order Butterworth, +/-20 MHz) with a white floor 20 dB below. The X310 / UBX-160 path at 200 MS/s is not like
that:

| f (MHz) | 0 | +/-20 | +/-40 | +/-60 | +/-80 | +/-90 |
|---|---|---|---|---|---|---|
| measured loop |H| (dB, silicon) | 0 | -0.2 / -0.6 | -0.6 / -1.5 | -1.7 / -2.7 | -3.3 / -4.6 | -13.5 / -14.7 |
| Butterworth model (dB) | 0 | -3.0 | -34.9 | -62.7 | -97.6 | -129 |
| real noise PSD (dB rel. 0 Hz bin) | 0 | +4.5 / +4.2 | +4.1 / +3.7 | +3.2 / +2.7 | +1.5 / +0.9 | -6.8 / -7.7 |
| model noise PSD (dB rel. 0 Hz) | 0 | +2.0 / +1.9 | -21.2 / -21.5 | -21.9 | -21.9 | -22.0 |

(The 0 Hz Welch bin of the real noise sits ~4.5 dB low: rx_dcoffset.) The receiver is flat to about +/-80 MHz and
its noise is white. Rectangular BPSK keeps its abrupt, wideband phase reversals; the model had only seen them
smoothed by a 20 MHz filter and against noise that has no energy above 20 MHz, so on the real stream BPSK looks
like the (wideband) noise. CW is narrowband and unaffected, LFM partly.

## 4. Fix: a measured channel (PLAN.md D-S5-CH)

* `ref/x310/channel_x310.py` -> `ref/x310/x310_channel.json` (silicon): the loop response h (31 complex taps around
  the peak, mean of the 8 dense captures sigL_s0..7, max deviation between captures 0.0018 of the peak tap) and a
  128-tap noise-shape FIR from the Welch PSD of noise_s0 / noise_s1. Capture hashes are checked against
  `evidence/stage5/silicon/captures.sha256`.
* `ref/x310/x310_data.py` channel 'meas' (default): signals through h with a fractional delay U(0, 1) sample per
  window; noise white through the FIR; total level U(-54, -12) dBFS (the X310 at RX gain 30 sits at -51.5 dBFS of
  noise). Everything else (classes, parameters, SNR definition, DC, IQ imbalance, BFP) as D-S5-DATA. Data in
  `ref/data/x310_meas/`, hashes in `ref/x310/x310_meas_split_meta.json`. Channel 'lpf' stays (`X310_CHANNEL=lpf`,
  `--check` still MATCHes the first set's hashes).
* Check that the new data reproduce the problem: the deployed (v1) model on the 'meas' test split scores noise / CW
  / LFM / BPSK 99.8 / 82.7 / 79.0 / 67.7 % (silicon sigL_s0: 99.85 / 84.9 / 77.7 / 65.1).
* Seeds 0-7 of the silicon signal set calibrated the channel (31 taps + a PSD, no labels); the v2 silicon test uses
  fresh TX seeds 8-15.
