# Stage 5 on silicon: nsclf in the X310, TX -> RX loop, 2026-11-03

Labels: **silicon** = measured on the X310 (the block's own registers, the host captures); **sim** = Verilator replay
of the captured samples; **derived** = read from RTL or a datasheet, not measured; **model** = the committed
channel-model figures (`evidence/stage5/accuracy.md`). Nothing here touched the X310 again: every number is
recomputed from the captures in `.scratch/s5_cap/` (not committed, 9-11 MB each) and the replay decisions in
`.scratch/nsclf_replay/<stem>/decisions.npz` (not committed, 25 MB each).

Setup (silicon): image `x310_xg_nsclf_lc2_1_impl_AltSpreadLogic_high` (cutoff 2, L = 19 read back from REG_LATENCY in
every capture), two UBX-160 daughterboards, RF A TX/RX -> 30 dB attenuator -> RF A RX2, 1 GHz, RX gain 30, TX gain 0,
rx_dcoffset auto (UHD default), radio0 channel 0 raw (D-S5-CAP), 200 MS/s, 4,210,688 samples per capture (21.05 ms),
MISR window = all 4,210,625 decisions inside the capture. TX plays the seed's waveform (`sw/x310/nsclf_txrx.py`,
`make_tx`) at host tick T + 4000 (PRE).

## 0. Headline: campaign 2 with a TX lead-in (primary result; sections 1-8 below are campaign 1)

Campaign 1 (sig_s0..s7) showed a DC step at every TX burst start (section 4): the UBX TX path adds DC / LO leakage
at RX only while the transmitter plays, and UHD's rx_dcoffset IIR (tau 2^20 samples = 5.2 ms) takes ~10 ms to remove
it, so noise windows early in a burst read as CW. Its "settled" subset was chosen after seeing that. **Campaign 2
(sigL_s0..s7, same seeds, same settings) removes the cause instead:** the TX plays 6,291,456 zeros (31.5 ms, 6 time
constants) before the signal set (`nsclf_txrx.py run --lead 6291456`), so the transmitter is on and the IIR has
settled before the capture starts. Result: gap DC 0 +/- 1 counts in every 2.6 ms block, noise windows 99.9 % noise
throughout (`lead/analysis.md`, "Time structure"), and the settled and all-window figures are identical; **every
labelled window counts, no post-hoc subset.**

| | overall (window-weighted) | class-balanced | SNR >= 10 dB, class-balanced | noise | CW | LFM | BPSK |
|---|---|---|---|---|---|---|---|
| **silicon, campaign 2, all windows** (23.8 M windows, 8 captures) | 82.4 | **81.8** | **97.4** | 99.9 | 84.5 | 77.5 | 65.5 |
| silicon, campaign 2, SNR >= 10 dB | | | 96.6 (signal windows) | 99.9 | 98.9 | 97.5 | 93.5 |
| model (exported = RTL, channel-model test set) | 81.5 | 81.5 | 96.0 | 90.0 | 79.9 | 78.1 | 78.2 |
| float64 (channel-model test set) | 85.7 | 85.7 | 98.3 | | | | |

- Bit-exact on silicon: all 8 campaign-2 captures PASS the replay (`replay_sigL_s*.log`; MISR, count, per-class
  hist, tfirst / tlast; the `--dump` MISR recomputed from the dumped decisions equals the silicon read-back).
- Seed spread (8 captures): class-balanced 81.82 % mean, std 0.29 (81.27 .. 82.14); SNR >= 10 dB 97.4-97.5 %.
- Loop delay D = 133.702 samples (std 0.0006) = 668.5 ns, identical to campaign 1 (**silicon**).
- Detection (silicon decisions; onset from D; cycles after the pulse's first sample at the tap; +19 cycles to a
  valid decision), SNR >= 10 dB, median (p90, max): CW 26 (43, 56), LFM 15 (31, 102), BPSK 11 (25, 196); 100 % of
  the 23,911 pulses detected; median + L = **225 / 170 / 150 ns**. 16 consecutive decisions of the class start at a
  median 50 / 59 / 62 cycles. Noise-only false alarms (no TX): 0.143 / 0.145 % of decisions.
- BPSK remains the weak class (65.5 %, 93.5 % at >= 10 dB against the model's 78.2 / 97.4 %): 27 % of BPSK windows
  are called noise (section 4 and doubt 2 apply unchanged). Noise is easier on silicon (99.9 % vs 90.0 %: the model's
  noise windows carry IQ imbalance, DC and random amplitude tags), which lifts the class-balanced figures; compare
  per class.
- Reproduce: `python3 sw/x310/nsclf_replay.py replay .scratch/s5_cap/sigL_s<k> --dump`, then
  `python3 sw/x310/nsclf_analyze.py --stems sigL_s0 .. sigL_s7 noise_s0 noise_s1 --out evidence/stage5/silicon/lead`.
  Captures are not committed (203 MB); their sha256 are in `captures.sha256`.

## 1. Bit-exactness: silicon MISR = Verilator replay (sim vs silicon), all 12 campaign captures PASS

Command per capture: `python3 sw/x310/nsclf_replay.py replay .scratch/s5_cap/<stem> --dump` (runs
`make -C tb nsclf_replay` on build-host: Verilator 5.020, the RTL of the image, one sample per clock at tap time T - 6 + k).
Log: `replay_<stem>.log`. Compared with the silicon read-back: MISR, count, per-class histogram, tau of the first and
last counted decision; for the evt runs also the event records. The tb's own checks ran too (every decision's tau,
the 19-edge latency, pass-through, AXIS: 0 mismatches in every run).

| capture | K | silicon MISR (= replay) | decisions | per-class histogram (silicon = replay) | tfirst .. tlast | events compared | dump MISR | result |
|---|---|---|---|---|---|---|---|---|
| sig_s0 | 60000 | 0xa597d04a0f7d5a82 | 4210625 | [1529396, 1287772, 588326, 805131] | 114973776 .. 119184400 | - | EQUALS | PASS |
| sig_s1 | 60000 | 0xe05f0acc8ecf4090 | 4210625 | [1521460, 1307669, 583305, 798191] | 117969151 .. 122179775 | - | EQUALS | PASS |
| sig_s2 | 60000 | 0x35fa8a3f37bb3b54 | 4210625 | [1531755, 1300087, 574892, 803891] | 116592555 .. 120803179 | - | EQUALS | PASS |
| sig_s3 | 60000 | 0x5c9bcca41ac07eb2 | 4210625 | [1510272, 1307059, 564658, 828636] | 116684870 .. 120895494 | - | EQUALS | PASS |
| sig_s4 | 60000 | 0x5385b64bb33610cf | 4210625 | [1524913, 1278069, 579852, 827791] | 118322844 .. 122533468 | - | EQUALS | PASS |
| sig_s5 | 60000 | 0x173bc1722a824f08 | 4210625 | [1516949, 1314207, 567135, 812334] | 116302995 .. 120513619 | - | EQUALS | PASS |
| sig_s6 | 60000 | 0x45b2c5d753fa8947 | 4210625 | [1557660, 1291604, 580785, 780576] | 116033823 .. 120244447 | - | EQUALS | PASS |
| sig_s7 | 60000 | 0xad82174c8eb6a794 | 4210625 | [1556873, 1279473, 561508, 812771] | 117706111 .. 121916735 | - | EQUALS | PASS |
| noise_s0 | 60000 | 0x669fda3a63934b23 | 4210625 | [4204615, 3100, 1390, 1520] | 108466608 .. 112677232 | - | EQUALS | PASS |
| noise_s1 | 60000 | 0x9c8b7ceff935b1b8 | 4210625 | [4204525, 3159, 1402, 1539] | 108253705 .. 112464329 | - | EQUALS | PASS |
| evt_s100 | 16 | 0xd0764309ffd8d8f0 | 4210625 | [3549456, 447256, 167547, 46366] | 118616446 .. 122827070 | 473 | EQUALS | PASS |
| evt_s101 | 16 | 0x1a82a71523d79b7d | 4210625 | [3563051, 439531, 166190, 41853] | 116773904 .. 120984528 | 502 | EQUALS | PASS |

Earlier `noise_1` (DC correction off, RX gain 10) still passes (`replay_noise_1.log`, from the first session).
That the MISR includes all 62 logit bits makes this a check of every decision's class and logits on silicon: 12 x
4.21 M decisions, 50.5 M in total, bit-exact against the replayed RTL, on a real analog input at full 200 MS/s.

**Negative controls (all FAIL as required):**

| control | log | result |
|---|---|---|
| sig_s0, one capture sample (14309, inside a CW pulse) with I bit 13 flipped (-394 -> -8586) | `replay_sig_s0_neg_flip14309.log` | MISR 0x4e10a09f18e71110 != silicon, hist differs by 9/15/6 decisions: FAIL |
| sig_s0, `--extra-offset 1` (replay one tap tick late) | `replay_sig_s0_neg_offset1.log` | MISR, count, hist, tfirst differ: FAIL |
| evt_s100, `--extra-offset 1` | `replay_evt_s100_neg_offset1.log` | window fields and "no common event": FAIL |
| noise_1, `--extra-offset 1` (first session) | `replay_noise_1_neg_offset1.log` | FAIL |

The +6 tick offset between host timestamp and tap time (block README section 3, shown in xsim) is therefore also
confirmed on silicon: the offset-0 replay is bit-exact on 4.21 M decisions, offset +1 is not.

## 2. Per-decision classes (the silicon decisions, proven)

`tb/tb_nsclf.sv` got a `+DUMP=<file>` plusarg (replay mode only; testbench change, no RTL change; `tb/Makefile`
variable `RDUMP`) that writes `tau` and the decision word `{logits[61:0], cls[1:0]}` of every decision. `nsclf_replay.py
--dump` parses it, recomputes MISR / count / histogram / first / last tau with `nsclf_model.window` and requires them
to equal the silicon read-back (the `DUMP ... EQUALS` line in each log), checks tau = tap0 + 63 + j for every j, and
only then stores `decisions.npz`. So every class and logit used in sections 4-5 is the silicon decision.
(The tb change was exercised by the 15 runs above and by `nsclf_replay.py selftest`, still PASS with its 264 events;
`make -C tb nsclf` was not re-run.)

## 3. Loop delay D, labels, SNR

All by `sw/x310/nsclf_analyze.py` (docstring has the exact definitions).

**Loop delay D (silicon).** Start event: TX sample 0 scheduled at host tick T + PRE (the radio's timed TX command,
`nsclf_txrx.py`); stop event: that waveform's first sample arriving in the RX capture, in the RX stream's host
timestamps (sample k = T + k). Instrument: the X310's own radio timekeeper (200 MHz), cross-correlation of the RX
samples with the regenerated TX waveform (peak/median 629, next-highest correlation more than 64 lags away 2.7 % of
the peak), refined by a least-squares fit of the loop's impulse response over 144 lags. Includes the DUC, radio TX,
DAC, UBX TX, cable, 30 dB attenuator, UBX RX, ADC, capture, rx_frontend (every stage of the loop); excludes nothing.
Clock 200 MHz.

| | value |
|---|---|
| integer lag of the maximum of \|h\| | **134 samples** in all 8 dense captures (the plain correlation peak is at 133: the response has a long tail, below) |
| sub-sample estimate (parabola through \|h\| at 133, 134, 135) | **133.7017 samples** mean, std 0.0005 over the 8 captures (min 133.7007, max 133.7023) = 668.5 ns |
| sparse captures evt_s100/101 | 133.700 / 133.701 |
| response h (power relative to its peak) | lag 132 -16.6 dB, 133 -2.0 dB, **134 0 dB**, 135..139 -11..-19 dB, 140..146 -22..-35 dB, 147..154 -34..-42 dB, below -45 dB beyond 155 |
| span holding 99.95 % of sum \|h\|^2 | lags [132, 151] (all 8 captures) |

The sub-sample figure rests on a parabola through three integer-lag LS estimates of a response that is not
symmetric, so the fraction is indicative (+-0.3 sample), not a calibrated sub-sample delay. D is for this power-up of
this image; the spread across captures (which share one session) says nothing about a re-load.

To tap time: the host timestamp of RX sample k is the tap time + 6, so TX start to the sample at the tap is D - 6
= 127.7 samples (derived from the xsim offset, confirmed bit-exact on silicon, section 1).

**Labelling (D-S5-DATA rules, `ref/x310/x310_data.py`).** Decision j's 64-sample window depends on TX samples
j - PRE - 151 .. j + 63 - PRE - 132 (guard from the measured response: a window must start at least 151 - 134 = 17
samples after a pulse's first TX sample has reached the peak lag, and end at most 2 samples after the last).
- class c (CW, LFM, BPSK): all those TX samples lie inside one pulse of class c;
- BPSK: additionally one chip boundary with a bit change at a window position p with max(2, W/8) = 8 <= p <= 56
  (position from D = 133.70), else "BPSK without a reversal", excluded and reported;
- noise: all those TX samples lie in a gap or between pulses **and** inside the TX burst; the windows that depend on
  the time before the burst or after it are excluded (131,224 windows; a DC step follows the burst's end);
- all other windows (straddling a pulse edge or within the guard) are excluded and reported (7.6 M of 33.7 M decisions).

Pooled over sig_s0..s7: 23,777,106 labelled windows (noise 6,645,515, CW 7,395,737, LFM 2,884,026, BPSK
6,851,828), straddling 7,621,579, BPSK without reversal 2,155,091.

**Pulse SNR (silicon).** Model definition: signal power over total noise power at 200 MS/s. Noise power N =
mean |y - dc|^2 over RX samples whose TX dependence lies in a gap during playback (dc = slowly varying gap mean in
blocks of 2^16 samples, so the DC step below does not count as noise): **7,624 (-51.5 dBFS)**, the same as the idle
noise before the TX starts (7,638, variance): the TX adds no measurable noise in the gaps. Pulse SNR =
10 log10((P - N) / N), P = mean |y - dc|^2 over the pulse's span [start + 151, end - 1 + 132] + PRE.
The measured SNR follows the intended per-pulse amplitude with slope 1.000, **peak SNR 25.1 dB** (p10..p90 of
SNR - a_db over the pulses within 15 dB of the maximum amplitude: 24.9 .. 25.2 dB; CW/LFM/BPSK 25.16/25.15/25.09), so the 30 dB
amplitude range maps to measured pulse SNR of about -4.9 .. 25.1 dB; 98.1 % of the pulses of sig_s0 are inside
[-5, 25) dB, the rest between -5 and -13 dB (short pulses at the lowest amplitudes, noisy estimates). This equals
the intended -5 .. 25 dB. Pulse SNR is measured per pulse over its span; the model's SNR is per window (realised
window SNR averages 0.15 dB above the drawn one at W = 64), so bins differ slightly at the edges.

## 4. Accuracy (silicon decisions vs the TX-schedule labels)

Full tables in `analysis.md` (generated), numbers in `summary.json`. Pooled over the 8 dense captures sig_s0..s7.

**The 10 ms DC transient (important for reading every figure).** When the TX burst begins, the RX baseband gets a DC
step of about (+121, -12) counts (1.4 sigma of the noise; sign reverses at the burst's end: (-125, +16)); the front
end's `rx_dcoffset` IIR (time constant 2^20 samples = 5.2 ms, README block section 3) removes it slowly, so the
first ~8 ms of every dense capture is a CW-like 0 Hz tone in the noise windows (classified noise: 16.9 % at 0-2.6 ms,
75.5 % at 2.6-5.2 ms, 97.3 % at 5.2-7.9 ms, 99.8 % from 10.5 ms; the false calls are CW). The pre-TX idle part
(DC about 0) and the noise-only captures do not have it. The cause of the step is not known (TX LO / DAC offset
that exists only while the replay block plays; see doubts). I therefore report two subsets:
- **all playback windows**: every labelled window;
- **settled**: windows whose newest sample is at least 2 x 2^20 samples (10.5 ms) after the burst arrives
  (the DC step is then below e^-2 of its size, 16 counts = 0.2 sigma). The threshold (2 time constants of the
  IIR) was fixed after looking at the transient above, so "settled" is post hoc; both subsets are shown.

| | overall (window-weighted) | class-balanced | SNR >= 10 dB class-balanced | noise | CW | LFM | BPSK |
|---|---|---|---|---|---|---|---|
| **silicon, all playback windows** | 77.3 | 77.0 | 93.6 | 86.1 | 81.0 | 75.0 | 65.8 |
| silicon, all, SNR >= 10 dB | | | | 86.1 | 98.3 | 96.8 | 93.2 |
| **silicon, settled** | 82.3 | **81.6** | **97.4** | 99.8 | 84.1 | 77.3 | 65.2 |
| silicon, settled, SNR >= 10 dB | | | | 99.8 | 98.9 | 97.4 | 93.6 |
| model, exported = RTL (test, 25 % per class) | 81.5 | 81.5 | **96.0** | 90.0 | 79.9 | 78.1 | 78.2 |
| model, SNR >= 10 dB | | | | 89.9 | 98.5 | 98.3 | 97.4 |
| float64 model (test) | 85.7 | 85.7 | 98.3 | | | | |

Class-balanced = mean of the four per-class accuracies (the model's test set has 25 % per class, noise windows
tagged with a random SNR, so its "81.5 %" and "96.0 %" are class-balanced figures); window-weighted = every
labelled window counts once (silicon: noise windows dominate in the sparse runs, pulse length weights the pulse
classes). The "SNR >= 10 dB class-balanced" figure = mean(noise accuracy of the subset, CW, LFM, BPSK at pulse SNR
>= 10 dB). Signal windows only at SNR >= 10 dB (the figure that does not depend on how noise is weighted): 96.0 %
(all playback), 96.6 % (settled). **Headline: silicon 81.6 % overall and 97.4 % at SNR >= 10 dB (settled) against the
model's 81.5 % and 96.0 %; with the DC transient included 77.0 % and 93.6 %.**

Per class, the comparison is not uniform: noise is better on silicon (99.8 % settled, 86.1 % with the transient,
against 90.0 %: the model's noise windows carry DC, IQ imbalance and the random-amplitude tags that this
capture lacks), CW is similar to the model (84.1 vs 79.9 settled), LFM slightly lower (77.3 vs 78.1), **BPSK clearly
lower (65.2 % vs 78.2 %; at SNR >= 10 dB 93.6 % vs 97.4 %)**. The BPSK deficit grows with chip rate (pooled settled,
SNR >= 10 dB: 94.7-95.0 % at 5-15 Mchip/s, 88.8-89.3 % at 15-20 Mchip/s; Barker and random codes alike, so it is not
the code), and 28 % of settled BPSK windows are called noise. The cause is not established (candidates: the real
TX chain's filtering of the rectangular chips, the model's 50 % Gaussian-filtered BPSK that this TX does not
transmit, a reversal timing smeared by the 20-sample response tail so that the label's reversal position is
uncertain by a few samples).

Confusion matrices, settled (rows true, columns predicted; all-windows matrix in `analysis.md`):

| true \ pred | noise | CW | LFM | BPSK |
|---|---|---|---|---|
| noise | 3,333,408 | 2,640 | 1,445 | 1,387 |
| CW | 420,119 | 3,088,447 | 143,480 | 18,827 |
| LFM | 178,780 | 135,495 | 1,120,555 | 14,303 |
| BPSK | 948,227 | 96,567 | 147,705 | 2,233,502 |

**Per SNR bin** (settled, class-balanced = mean of noise and the three signal accuracies; model column = the test
split's HGQ-exported row of `accuracy.md`; counts of every cell are in `analysis.md`):

| SNR bin (dB) | -5..-2.5 | -2.5..0 | 0..2.5 | 2.5..5 | 5..7.5 | 7.5..10 | 10..12.5 | 12.5..15 | 15..17.5 | 17.5..20 | 20..22.5 | 22.5..25 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| silicon settled, class-balanced % | 32.1 | 44.2 | 62.5 | 75.8 | 85.9 | 93.1 | 95.9 | 96.4 | 97.8 | 97.9 | 98.1 | 98.4 |
| silicon all playback, class-balanced % | 30.2 | 39.1 | 54.6 | 67.9 | 79.8 | 87.7 | 91.2 | 92.4 | 94.1 | 94.2 | 94.5 | 94.8 |
| model, test % | 34.3 | 45.3 | 63.2 | 79.0 | 87.6 | 92.6 | 94.8 | 96.0 | 96.1 | 96.5 | 96.4 | 96.5 |

The settled silicon curve is 0.7-3.2 points below the model from -5 to 7.5 dB (largest gap 3.2 points at
2.5-5 dB), 0.5 points above it at 7.5-10 dB, and 1-2 points above it from 10 dB up (partly because its noise class
is easier, 99.8 vs 90 %).

**Noise-only false alarms (silicon, noise_s0 / noise_s1, no TX, DC about 0, K = 60000 so no events)**: 0.143 % and
0.145 % of the 4,210,625 decisions are not noise (0.074 / 0.075 % CW, 0.033 % LFM, 0.036 / 0.037 % BPSK). The
K = 16 hysteresis applied to these silicon decisions (derived with `nsclf_model.hysteresis`) would have produced
0 events in 21 ms in each; in the evt runs, 1 silicon event per capture lies outside every pulse span in the
settled part (last 10.5 ms); 174 per capture lie outside every pulse span in all, of which 77-79 come after the
capture's last sample (the host kept listening; post-burst, not analysed) and the other ~95 in the DC transient.

**Stream-level view** (information; every decision incl. the 7.6 M straddling windows, per-sample label = class of
the TX sample at the window's newest sample, minus D): agreement 65.6 % (noise / CW / LFM / BPSK 74.3 / 75.2 / 61.3
/ 50.2 %); the straddling windows alone agree 43.8-44.6 % per dense capture. For reference the model's stream was 77.4 % on pure
windows.

**Seed-to-seed spread (8 dense captures, silicon):** class-balanced overall 76.99 % mean, std 0.30 (min 76.61, max
77.47); SNR >= 10 dB class-balanced 93.59, std 0.13; settled: 81.62 (std 0.66, min 80.56, max 82.56) and 97.43 (std
0.10, min 97.25, max 97.56). Per-class std (all playback; noise / CW / LFM / BPSK): 0.38 / 0.59 / 0.50 / 1.12.
Per-capture rows are in `analysis.md`. The sparse captures evt_s100/101 give 79.97/80.80 % and 97.47/97.43 %
(settled, class-balanced, with only ~165 pulses each, ~55 per class, so BPSK 63.4 / 51.3 % there is noisy).

## 5. Latency

| item | value | label |
|---|---|---|
| (a) pipeline L | **19 cycles = 95 ns** at 200 MHz: start = the radio_clk edge that captures the window's newest sample from `radio_rx_data` at the block's `radio_in` port; stop = the edge after which that window's decision (class, logits, valid) is on the classifier's registered outputs, counted inclusive; excludes everything before the tap and after the decision. Checked on every decision of the 12 replays (`latency_mismatches=0`) and read back from REG_LATENCY on silicon in every capture | **sim** (Verilator cycle count; the register value is silicon) |
| first window sample -> decision | L + 63 = 82 cycles = 410 ns | **derived** |
| (b) pulse onset at the tap -> first raw decision of the pulse's class (tau minus onset; below) | see table | **silicon** decisions, onset **derived** from the measured D |
| (c) pulse onset -> K = 16 smoothed event tau | see table | **silicon** event records |
| (d) before the tap | ADC 23 clock cycles + FPGA ~9 radio_clk stages = ~32 cycles = ~160 ns | **derived** (RTL, datasheet), not measured |
| (e) TX start -> RX arrival D | 134 samples (133.70) = 668.5 ns | **silicon** |

**(b) Detection delay, silicon.** Start event: the tap time of the pulse's first TX sample = host-time arrival
estimate PRE + start + 134 (the lag of the response's maximum; the response begins ~2 samples earlier and rises over
~3 samples, so the "first sample at the tap" is defined at the peak lag). Stop event: tau of the first decision at or
after the onset whose class is the pulse's class and whose window no longer contains the previous pulse (tau =
tap time of the window's newest sample, from the MISR-proven silicon decisions). Instrument: the silicon decision
stream (replay-proven) and the TX schedule. Clock 200 MHz, 1 cycle = 5 ns. The decision is *valid* L = 19 cycles
after tau. Excluded: everything before the tap, hysteresis, the event path. Pooled over the 8 dense captures
(15,790 CW, 15,707 LFM, 15,687 BPSK pulses); cycles after onset:

| class / SNR | detected | min | median | p90 | max | median + L (ns) |
|---|---|---|---|---|---|---|
| CW, all | 100.0 % | 0 | 28 | 49 | 567 | 235 |
| LFM, all | 99.8 % | 0 | 20 | 71 | 362 | 195 |
| BPSK, all | 99.8 % | 0 | 16 | 67 | 693 | 175 |
| CW, SNR >= 10 dB | 100.0 % | 0 | 25 | 43 | 62 | 220 |
| LFM, SNR >= 10 dB | 100.0 % | 0 | 15 | 31 | 97 | 170 |
| BPSK, SNR >= 10 dB | 100.0 % | 0 | 10 | 24 | 200 | 145 |
| all classes, -5..0 dB | 99.4 % | 0 | 53 | 119 | 693 | 360 |
| all classes, 0..5 dB | 100 % | 0 | 32 | 66 | 310 | 255 |
| all classes, 5..10 dB | 100 % | 0 | 22 | 41 | 192 | 205 |
| all classes, 10..15 dB | 100 % | 0 | 17 | 38 | 195 | 180 |
| all classes, 15..25 dB | 100 % | 0 | 14 | 39 | 200 | 165 |

How to read it: a decision at the onset whose window holds one pulse sample can be of the pulse's class by chance
(min 0), so the minimum is not a detection time; the median is the time for a typical first decision of the class,
and is a *first-hit* figure, which is optimistic: the stricter "first run of 16 consecutive decisions of the class"
(what K = 16 needs) has, at SNR >= 10 dB, medians of 50 (CW), 59 (LFM), 62 (BPSK) cycles after the onset to the
*start* of the run (p90 62 / 92 / 138; 99.9 % reached); K = 16 declares the class 15 decisions later, i.e. at about
65 / 74 / 77 cycles, consistent with the silicon event delays of (c); L = 19 more for validity (tables in
`analysis.md`). The settled subset gives the same medians (CW 26, LFM 15, BPSK 11 cycles).
The BPSK first-hit time is short because a BPSK window containing a reversal is recognised long before it is full
and because a CW decision at the onset of a BPSK pulse is not a BPSK decision, so only genuine BPSK calls count.

**(c) K = 16 event delay (evt_s100/101, silicon event records).** Event tau (the tap time of the newest sample of
the 16th consecutive decision) minus the pulse onset; the event leaves the core 3 cycles after the decision, i.e.
tau + 22 cycles (derived, README block section 6). At SNR >= 10 dB: 98.2 % of 166 pulses have an event of their
class, median 66, p90 107, min 25, max 531 cycles (330 ns median, 1.4 us worst) -- by class CW 63 (94.4 %), LFM 72
(100 %), BPSK 60 (100 %). All SNR: 71.9 % of 327 pulses, median 71 cycles (the rest are missed: pulses below ~5 dB
rarely give 16 equal decisions). The 3 missing CW pulses at >= 10 dB are not investigated.

**(d) What precedes the tap (derived, not measured).** From the UHD 4.9 RTL (a5d1b2e, `fpga/usrp3/`, read by a
sub-agent, file:line in its notes below):
- ADC pins to `radio_rx_data` at radio0's io_port: 1 IDDR stage (capture_ddrlvds.v:116-122, ADC clock) + 2 flops
  in radio_clk (capture_ddrlvds.v:135-139, a two-flop synchroniser, no FIFO; ADC clock and radio_clk share a
  source with an unknown constant phase, so the count is a fixed integer per placed image and boot but could
  differ by one cycle between builds/boots) + rx_frontend_gen3: IQ mapping 1, rx_dcoffset 1, IQ-balance
  `mult_add_clip` 2 (instantiated even at identity gain), heterodyne bypassed by a mux 0, round_sd 2 = 8 radio_clk
  stages (rx_frontend_gen3.v:148-159, 189-227, 327-330; lib/dsp/rx_dcoffset.v, mult_add_clip.v, round_sd.v);
  everything else is wires. About 9 cycles (45 ns).
- ADS62P48 data latency: 22 clock cycles (TI SLAS635B, "ADC latency (4)", LVDS and CMOS modes; Fig. 5 N-22) and
  its footnote 4: at higher clock frequencies tPDI exceeds one clock period and the latency is ADC latency + 1.
  At 200 MSPS tPDI = 0.69 Ts + tdelay = 7.65 .. 10.65 ns > 5 ns, so 23 cycles = 115 ns (that application of
  the footnote to 200 MSPS is ours, not stated in the datasheet; the PDF was revision B of January 2011).
- So from the ADC input to the tap about 32 cycles = 160 ns; the daughterboard analog path (UBX-160 filters) is not
  included. Adding it to (b): a pulse's first sample at the SMA to a valid first CW/LFM/BPSK decision at SNR >= 10 dB
  is about 32 + (25 / 15 / 10) + 19 = 76 / 66 / 61 cycles = 380 / 330 / 305 ns (derived sum of derived and silicon
  parts; uses medians of first hits). This is not a measured pin-to-pin latency.

**(e)** D as above is the only end-to-end silicon time; it includes the TX half (DUC, DAC, UBX TX) that the
classifier does not see.

## 6. Events on silicon and the "timestamp != word 0" records

The replay runs the RTL's own hysteresis and event framer (K = 16, events received by the testbench's AXIS sink);
the comparison starts at the first event both sides have (the hysteresis state at the capture start depends on earlier
samples) and then requires every event (tau, new/old class, K, and run length except for the first) to match.
- evt_s100: 550 records received, sequence 30533..31082 with **0 gaps**, every drop field 0, EVT_SEQ = 31083 and
  EVT_DROP = 0 (so every event the block generated in the session after its reset, from sequence 30533 on, was
  received); 473 have tau inside the capture window, 77 come after its end (the host kept listening 0.2 s after the
  last sample; their decisions were not computed in the replay); **473 / 473 equal the replay events: PASS**.
  Sequence numbers start at 30533 because the counter runs since the session's block reset.
- evt_s101: 581 records, sequence 20678..21258, 0 gaps, drops 0, EVT_DROP = 0; 502 in the window; **502 / 502
  equal: PASS**.
So the host decoder reads the words right (word order, field positions, `tau` = word 0): any other word order would
fail the field comparison for every event.

**The `events_timestamp_mismatch` counts (9 and 10) were a defect of the host's check, not of the data.**
- 9 = ceil(550 / 64) and 10 = ceil(581 / 64): `EventReceiver` receives into a 64-record buffer and compared the
  recv metadata time spec of the first packet of **every recv call** with word 0 using
  `time_spec.to_ticks(200e6)`; it flagged exactly one record per call, i.e. every call, never a sporadic record. So
  all comparisons failed for a systematic reason and the counts equal the number of calls.
- The nsclf block has no UHD block controller (UHD logs "Could not find block with Noc-ID 0x4e53c1f0, using the
  default"), its timebase is a graph clock that nothing sets, and `info` shows `block tick rate 0.0`
  (`nsclf_info_1.log`). The default streamer tick rate is 1.0 (`rx_streamer_zero_copy.hpp: _tick_rate = 1.0`), which
  makes the recv time spec `from_ticks(tsf, 1.0)` = tsf *seconds*; `to_ticks(200e6)` of that is 200 million times
  tau. This reading is the most likely explanation; it is not proven because the time specs were not saved.
- Fix (`sw/x310/nsclf_host.py`, also saved per recv call in the json from now on; `nsclf_txrx.py` stores the
  same): `ts_matches()` accepts the time spec as `tick` (converted at 200 MHz) or `raw1` (tau seconds, the default
  rate-1.0 case) and flags anything else; the receiver also keeps a per-call record (items, has_time, full/frac secs,
  match kind), receive errors, and checks whole records. **Verification (offline only; no re-capture possible):**
  `event_ts_check_offline.log` runs the real UHD 4.9 `TimeSpec.from_ticks(tau, rate)` on every captured tau
  (550 + 581): at rate 1.0 the old check fails for all, `ts_matches` returns `raw1` for all; at rate 200e6 it
  returns `tick` for all; for tau + 1 it flags all. Not run against a device.

## 7. Files

- `sw/x310/nsclf_replay.py`: `--dump`, `--keep-txt`, `--flip-sample/--flip-bit`, capture summary lines, absolute work dir
  (the earlier relative `--work` broke `make -C tb`); `tb/tb_nsclf.sv`, `tb/Makefile`: `+DUMP` / `RDUMP`.
- `sw/x310/nsclf_analyze.py`: all of sections 3-5 (`python3 sw/x310/nsclf_analyze.py`, about 2 min on desk-pc with
  python3.13 + numpy + scipy, needs `.scratch/s5_cap` and the replay `decisions.npz`) -> `summary.json`,
  `analysis.md`.
- `sw/x310/nsclf_host.py`, `nsclf_txrx.py`: event-timestamp fix and logging (section 6).
- `evidence/stage5/silicon/`: `replay_*.log` (12 PASS + 3 negatives + the session-one noise_1 pair), `summary.json`,
  `analysis.md`, `event_ts_check_offline.log`; the session's own capture logs were there already.
- Not committed: `.scratch/s5_cap/*.npz`, `.scratch/nsclf_replay/*/decisions.npz`.

Reproduce: `python3 sw/x310/nsclf_replay.py replay .scratch/s5_cap/<stem> --dump > replay_<stem>.log` (first run
builds on build-host; one run at a time per `obj_dir`, they are keyed by sample count), negatives with `--flip-sample
14309` / `--extra-offset 1` and `--work .scratch/nsclf_replay/<name>`, then `python3 sw/x310/nsclf_analyze.py`.

## 8. Doubts

1. **The DC step at the TX burst start is not understood.** It is +121 counts in I (1.4 sigma) for the first ~ms,
   reverses at the burst's end, and it is not in the noise-only captures. The likely cause is TX DC / LO leakage
   present only while the DAC plays (the replay block outputs nothing but zeros before), seen through UHD's slow
   DC IIR. Any deployment with an on/off transmitter gets a 10 ms transient in which noise reads as CW; the model
   has DC (U(0, 0.3) x noise rms) but no step. The settled subset is a post-hoc selection, so the two headline
   pairs (77.0 / 93.6 and 81.6 / 97.4) must be read together; the claim "silicon meets the model figure" holds for
   settled data only, and for the all-window figures silicon is 4.5 / 2.4 points below.
2. **BPSK is the weak class** (65.2 % vs 78.2 % overall, 93.6 vs 97.4 at >= 10 dB), worse at high chip rates;
   the cause is not established (section 4).
3. **Window mixes differ** between silicon and the model's test set: silicon BPSK is rectangular chips only (the
   model has 50 % Gaussian-filtered), windows are weighted by pulse length (long CW pulses weigh more), LFM windows
   sit at all positions of the pulse, and the SNR is the pulse's, not the window's. The class-balanced figures are
   the comparison the model's balanced test set allows, not an identical population.
4. **Label guard from a linear response fit.** The 99.95 % span [132, 151] is a 20-sample window around the peak
   and trims 24 % of the windows as straddling; a different threshold moves a few tenths of a percent at pulse edges.
   The SNR bins assume the pulse's SNR is flat over its span (the response gain, `gain_db` -2.2 dB, is in the
   measurement).
5. **D's fraction (133.70) is indicative** (section 3). The integer 134 is the maximum of |h|; the plain correlation
   peak is at 133 because the response is skewed.
6. **Pre-tap latency (d) is derived**: the clock-domain-crossing phase can change the count by one cycle between
   builds and boots; the ADS62P48 revision read was B (2011) and applying footnote 4 at 200 MSPS is our reading.
7. **Event denominators:** the K = 16 event delay counts a pulse only if an event of its class (new class) occurs
   in its span (onset .. end + 63 + 16 + 19); events are only generated on a class change, so a pulse preceded
   by an unreturned smoothed class would be missed. The 3 CW pulses at >= 10 dB without an event were not
   investigated. Nothing in this section is re-checked on silicon after the host fix.
8. The Verilator replay is the only independent reference: it proves the silicon equals the *RTL*, not that the
   classifier equals the Keras model on these captures (that was done on the golden stream, stage 5 block README).
   Samples below the input quantizer's kept bits cannot be checked by the MISR (block README doubt 8): the capture
   integrity rests on UHD's sequence checks (no overflows, `errors` empty, packet ticks contiguous in every json).
9. The block regression `make -C tb nsclf LC=2` was re-run after the `+DUMP` change (2026-11-03,
   `nsclf_regress_after_dump.log`): 8/8 runs 0 mismatches on 65,473 decisions, the 3 negative controls fail, rc 0.