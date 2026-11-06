# Stage 5, pre-hardware: X310 waveform classifier through the bit-exact flow (no X310)

**Status: pre-hardware flow complete (2026-10-30); silicon done 2026-11-03: `silicon/README.md` (the classifier on the
X310's own TX->RX loop, bit-exact on silicon, 81.8 % / 97.4 % at SNR >= 10 dB against this page's model 81.5 / 96.0 %)
and `block/README.md` (the RFNoC block and image). This page is the pre-hardware (model) record of v1. v2 (2026-11-03,
the current classifier, BPSK fixed by a measured channel model): `v2/README.md`, `bpsk/README.md`, `accuracy_meas.md`.**

- **Chosen classifier:** W = 64 complex samples, HGQ2 MLP 128-96-48-24-4 on the block-floating-point window, 21,439 EBOPs.
- **Accuracy (model, test, 100,000 windows):** 81.5 % overall (float64 85.7 %) and **96.0 % at SNR ≥ 10 dB** (float 98.3 %).
- **Bit-exactness (sim):** Verilator matches the Keras model bit for bit at four pipeline depths. Each depth ran 8 times on all 100,000 test windows and 8 times on every one of 65,473 sliding windows of a continuous stream, with 0 mismatches.
- **OOC (model), xc7k410tffg900-2 at 5.0 ns (200 MHz, the radio clock):** closes at every depth with **~22.4k LUT**, 0 DSP and II = 1. One decision per sample comes **18 cycles = 90 ns** after the window's last sample (cutoff 2, WNS +0.281 ns); the shallowest depth that closes gives 14 cycles = 70 ns (cutoff 3, WNS +0.025 ns).
- **The selection rule had to be amended for the LUT budget.** The rule as first stated picked a 61k-EBOP net at 52.4k LUT, which also fails 5.0 ns at cutoff 3 (§3). That cost 2.9 points overall and 1.5 points at SNR ≥ 10 dB on validation.

**Labels.** No X310 was reachable, so the data is a **channel model** (`ref/x310/x310_data.py`). Every
accuracy here is **model** (the Keras float64 model on channel-model data). Every latency and timing
figure is **sim** (Verilator) or **model** (Vivado OOC P&R). Nothing ran on the radio. The decisions in
`docs/PLAN.md` §C.1 cover this work: D-S5-SIG, D-S5-WIN, D-S5-DATA, D-S5-BFP, D-S5-SEL and D-S5-RTL.

## 1. Signal set and channel model (D-S5-SIG, D-S5-DATA; ref/x310/x310_data.py)

**Format:** complex baseband at 200 MS/s, sc16 (int16 I and Q), as the X310 delivers it.

**Window:** one labelled window is W complex samples, i.e. 2W int16 lanes.
- Lane 2k is I_k and lane 2k+1 is Q_k; sample 0 is the oldest.
- The pulse fills the window.
- Evaluated at W = 16, 32 and 64 (80, 160 and 320 ns).

| class | parameters (each window draws its own) |
|---|---|
| 0 noise | receiver noise only |
| 1 CW | f ~ U(-15, 15) MHz |
| 2 LFM | span B ~ U(5, 30) MHz, duration T ~ U(0.5, 5) µs, **kept only if k = B/T ≥ 10 MHz/µs**; up or down; swept band inside ±15 MHz; the window sits at a uniform position inside the pulse |
| 3 BPSK | chip rate U(5, 20) Mchip/s, carrier U(-10, 10) MHz; random bits or a repeated Barker-13 (½ each); rectangular or Gaussian-filtered chips, BT ~ U(0.8, 2) (½ each); **the window must hold a phase reversal at least max(2, W/8) samples from either edge** |

**Channel, applied to every window in this order:**
1. random carrier phase;
2. residual CFO ±U(2, 100) kHz (TX and RX share the reference);
3. complex AWGN through the analog low-pass (5th-order Butterworth, ±20 MHz, i.e. the 40 MHz WBX bandwidth), plus a white floor 20 dB below it (ADC);
4. SNR ~ U(-5, 25) dB;
5. IQ gain imbalance U(±0.5) dB and phase imbalance U(±2)°;
6. DC offset of U(0, 0.3) × the noise rms at a random angle;
7. total rms |x| ~ U(-42, -12) dBFS (30 dB of unknown loop gain);
8. rounding and saturation to int16.

**How SNR is defined:**
- SNR is the window's filtered signal power over the expected noise power.
- The realised window SNR is stored too: it averages 0.15 dB above the drawn value at W = 64 and 0.6 dB at W = 16, the small-sample bias.
- Noise-only windows carry a drawn SNR as a tag only, so that every SNR bin holds all four classes.
- At -12 dBFS, int16 saturation never triggers in these sets (mean saturated fraction 0.0 in `ref/x310/x310_split_meta.json`).

**Why the LFM and BPSK cuts.** They keep the classes separable in principle (`separability.json`, `ref/x310/separability.py`).

A chirp of rate k inside a W-sample window differs from the best-fitting tone only by a residual energy fraction r(k, W). d² = 2·W·SNR·r is the deflection of the best tone-versus-chirp test. At 10 dB:

| W | k = 1 | 5 | 10 | 20 | 30 | 60 MHz/µs |
|---|---|---|---|---|---|---|
| 16 | 0.0 | 0.0 | 0.1 | 0.3 | 0.6 | 2.5 |
| 32 | 0.0 | 0.6 | 2.3 | 9.1 | 20.3 | 78.0 |
| 64 | 0.7 | 18.3 | 71.7 | 266 | 531 | 947 |

- **LFM.** With the brief's ranges (k = 1 to 60 MHz/µs) a slow chirp *is* a tone in ≤ 320 ns. With k ≥ 10 MHz/µs, every admitted chirp is separable from CW at W = 64 (d² ≥ 72). At W = 32 only k ≳ 20 MHz/µs is separable, and at W = 16 none is.
  - The signal set is the same for every W, so that the W comparison runs on the same physical signals.
  - Small W therefore loses CW-versus-LFM by physics, not by training.
- **BPSK.** A BPSK window without a reversal is a CW tone. With a reversal at least 2 samples in, d² ≥ 140 at 10 dB for every W.

**Sizes and seeds:**
- Each W has 800,000 train, 100,000 val and 100,000 test windows, 25 % per class.
- Seeds: `default_rng([20261029, W, split, class])`.
- Content hashes are in `ref/x310/x310_split_meta.json`. Regenerating gives identical arrays: `--check` reported MATCH for `x310_w16_test` and `x310_w64_val`.
- Data is regenerated by the script into `ref/data/x310/`, which is not committed.

**Continuous stream** (`make_stream`, for the sliding-window test):
- 65,536 samples with the noise floor at -40 dBFS;
- gaps of 0.2–2 µs between CW, LFM and BPSK pulses at SNR U(-5, 25) dB;
- one channel draw for the whole stream.

## 2. Input normalisation: block floating point (D-S5-BFP)

**The shift:**
- s = min(8, 15 − bitlength(OR_j (v_j XOR (v_j >> 15)) & 0x7fff)) over the window's 2W lanes.
- Every lane is shifted left by s. Overflow is impossible by construction.
- The model input is the shifted window / 2^15.

**Where it is implemented:** integer only, in `x310_data.bfp()` and in `rtl/x310/x310_clf_top.sv`, bit-exact (§5).

**Why:** it removes the 30 dB unknown gain before the network.

**Ablation (validation, float64, W = 32, 64-32):**

| input | val accuracy | val accuracy at SNR ≥ 10 dB |
|---|---|---|
| raw int16 / 2^15 | 69.6 % | 84.4 % |
| BFP | 73.5 % | 89.9 % |

BFP was kept.

**Input quantizer:**
- HGQ2 KIF, SAT overflow and TRN rounding, heterogeneous per lane (it learns which bits of each lane matter).
- da4ml traces the model from a 16-bit input (`inputs_kif = (1, 0, 15)`), so this quantizer is part of the generated core.
- The core's port is the shifted int16 window.

## 3. Training and selection (D-S5-SEL and its amendment; evidence/stage5/training/)

**Compute:** train-host, container `opus_nsinfer:1`, via `sw/grumpy/launch_sweep.sh` (it now takes `TRAIN` / `RUNS`, with the Stage 2/4 defaults unchanged). Training is float64 on JAX.

**Float64 baselines** (`ref/x310/sweeps/f1.txt`, plus the floats in `h1`): MLPs 64-32, 128-64 and 128-64-32 at each W, 100 epochs, converged (val flat over the last 25 epochs). One raw-input ablation (§2).

**HGQ2 runs** (`h1`–`h4`, 33 runs, 2,115 Pareto checkpoints):
- quantizers: weights and biases KBI SAT_SYM RND; activations KIF WRAP RND, integer bits fixed by `trace_minmax` over the training split at export; input KIF SAT TRN, per lane;
- EBOPs β ramps from 1e-7 to 3e-6 … 6e-5 over 200–300 epochs;
- warm starts from the float in some runs.

**Rule 1** (D-S5-SEL, stated before training; `training/select.log`, `ref/x310/x310_selection_rule1_overbudget.json`), validation only:
- **Candidates per W:** the lowest-EBOPs checkpoint within 1 point of that W's best float, with ≥ 95 % at SNR ≥ 10 dB.
- **Choosing W:** the smallest W whose pick meets both criteria.
- **W = 16 and W = 32 cannot meet the 95 % criterion,** even in float (79.0 % and 92.1 % at SNR ≥ 10 dB): CW and LFM are not separable in 16 or 32 samples (§1). So **W = 64**.
- **Pick:** `hgq_w64_128_64_32_b5e6_e300` e0219, 61,468 EBOPs, val 84.80 % / 97.73 %. Test, looked at once: 84.57 % / 97.70 %.
- **It does not fit:** OOC gives **52,440 LUT** and WNS −0.715 ns at cutoff 3 (`ooc/x5r1_*`). It is nonetheless bit-exact in Verilator (`verilator_rule1/`: 8 × 100,000 + 8 × 65,473 vectors, 0 mismatches, both negative controls fail).
- **Why EBOPs mislead here:** EBOPs under-count LUTs for these nets. The weights are mostly 1–2-bit at 22–41 % density, and each nonzero term costs an adder: 0.7–0.85 LUT per EBOP, against 0.2 for an 8-bit 128-16 net (`ref/x310/x310_cost.json`).

**Amended rule** (PLAN D-S5-SEL amended, Stage 4's precedent, stated before sweep h4; `training/select_amended.log`, `ref/x310/x310_selection.json`):
- **Bound:** da4ml's LUT estimate of the calibrated core ≤ **22,000**, i.e. the ~25k budget less the hand-written BFP, shift register and argmax. The estimate was computed for all 432 W = 64 checkpoints at ≥ 95 % on SNR ≥ 10 dB (`ref/x310/cost_x310.py`).
- **Pick:** the best overall val accuracy among the checkpoints inside the bound. 34 are inside.
- **The 1-point margin is reported, not required:** nothing inside the bound meets it.

**Chosen:**
- **Checkpoint:** `hgq_w64_96_48_24_b2e5_e300` epoch 271 (128-96-48-24-4).
- **EBOPs:** 21,747 at training, 21,439 calibrated.
- **da4ml estimate:** 21,424 LUT.
- **Accuracy:** val 81.86 % / 96.21 %; test 81.53 % / 96.04 %.
- **Structure:**
  - The input quantizer keeps 1–5 bits per lane after BFP: k + i + f, mean 2.4.
  - HGQ pruned input lane 4 (I_2; its kernel row is zero), and da4ml drops it from the core's port. The RTL packs the other 127 lanes (`IN_COFF` in `rtl/gen/x310_clf_lanes.svh`); lane 4 still counts in the BFP mask.
  - Weight density is 22 % (fc1) to 88 % (out).

**Disclosure:** rule 1's pick was test-scored before the amendment. The amended pick was chosen on validation and cost only, and its test numbers were read once, after the choice.

## 4. Accuracy vs SNR (model; full tables in `accuracy.md`, generated by `ref/x310/report_x310.py`)

**Validation, per W.** Accuracy in %; the SNR bins are 5 dB wide here and 2.5 dB wide in `accuracy.md`.

| W | model | EBOPs | overall | SNR ≥ 10 | -5..0 | 0..5 | 5..10 | 10..15 | 15..20 | 20..25 |
|---|---|---|---|---|---|---|---|---|---|---|
| 16 | float 128-64-32 | – | 66.3 | 79.0 | 33.6 | 53.4 | 73.2 | 76.1 | 78.8 | 82.2 |
| 16 | HGQ rule-1 pick (95 % not met) | 290,444 | 65.4 | 77.5 | 33.6 | 53.1 | 72.3 | 76.0 | 77.9 | 78.8 |
| 32 | float 128-64-32 | – | 75.9 | 92.1 | 37.2 | 61.6 | 79.8 | 86.4 | 93.1 | 96.8 |
| 32 | HGQ rule-1 pick (95 % not met) | 476,864 | 74.9 | 91.0 | 36.2 | 60.8 | 78.7 | 85.8 | 91.8 | 95.6 |
| 64 | float 128-64-32 | – | 85.8 | 98.2 | 45.5 | 79.3 | 95.1 | 98.1 | 98.1 | 98.5 |
| 64 | HGQ rule-1 pick (over budget) | 61,468 | 84.8 | 97.7 | 44.3 | 77.3 | 93.8 | 97.4 | 97.8 | 98.0 |
| 64 | **HGQ chosen (in budget)** | 21,747 | 81.9 | 96.2 | 41.0 | 71.3 | 90.1 | 95.4 | 96.3 | 96.9 |

The 5 dB columns are the means of the two 2.5 dB bins in `accuracy.md`.

**Test, chosen W = 64,** reported once:

| model | overall | SNR ≥ 10 | -5..0 | 0..5 | 5..10 | 10..15 | 15..20 | 20..25 |
|---|---|---|---|---|---|---|---|---|
| float64 128-64-32 | 85.7 | 98.3 | 45.1 | 79.5 | 95.0 | 98.2 | 98.2 | 98.3 |
| **HGQ, exported and calibrated (= RTL)** | **81.5** | **96.0** | 39.8 | 71.1 | 90.1 | 95.4 | 96.3 | 96.5 |

**Per class, test, exported model:**

| | noise | CW | LFM | BPSK |
|---|---|---|---|---|
| overall | 90.0 % | 79.9 % | 78.1 % | 78.2 % |
| SNR ≥ 10 dB | 89.9 % | 98.5 % | 98.3 % | 97.4 % |

**Confusion:**
- Most errors are low-SNR signals called noise.
- 10 % of noise windows are called a signal, mostly BPSK (1,652 of 25,000).

**Continuous stream** (information only; a different draw from the test set):
- The decisions on the 54,182 windows wholly inside one pulse or gap agree with the label 77.4 % of the time.
- Per class (noise / CW / LFM / BPSK): 91.9 / 88.1 / 66.3 / 59.6 %.
- The stream's BPSK windows need not contain a phase reversal, unlike the test set's.

## 5. RTL (D-S5-RTL)

**`rtl/x310/x310_stream.sv`:**
- one sc16 sample (`in_i`, `in_q`) per clock while `in_vld`;
- a 64-sample shift register: the newest sample enters at the top, so the register always holds the window in lane order;
- once 64 samples have arrived, one decision per valid sample (II = 1).

**`rtl/x310/x310_clf_top.sv`:**
- BFP: the OR mask over the 128 lanes is registered (`BFP_PIPE = 1`), then encode and shift go into the da4ml core's input register.
  - `BFP_PIPE = 0` fails 5.0 ns on the K7: −0.29 ns, 9 levels, as the shift amount fans out to 2,048 muxes.
  - `BFP_PIPE = 2` is no better: +0.005 ns on the BFP path.
  - These came from the OOC dry runs on a throwaway model, `.scratch/x310/dry`.
- The da4ml core `x310_clf`.
- A first-max argmax over the four logits (np.argmax's rule), registered with the logits.
- One clock domain and no DSPs.

**Generated, per model:**
- `rtl/gen/x310_clf_lanes.svh`: W, BFP, the logit lane layout and the core input offsets;
- `rtl/gen/x310_clf_lc<c>/`: the da4ml projects, part xc7k410tffg900-2.

## 6. Bit-exactness in Verilator (sim; verilator/, Verilator 5.020 on build-host)

**Window test** (`tb/tb_x310.sv`, `make -C tb x310_win`):
- All 100,000 test windows (`.scratch/x310_full_*.hex`; sha256 `62f72295…` in, `53e57d2a…` out and `3f26bbc7…` dec, in `ref/golden/x310_full.json` and every log header).
- 4 seeds × 2 runs. Seed 0 uses natural order back to back; seeds 1–3 use xorshift32 shuffles with ~14,100 idle cycles (in_vld = 0, random data) inserted at random.
- Logits and class are checked on every out_vld, and the number of outputs is checked too.

**Stream test** (`tb/tb_x310_stream.sv`, `make -C tb x310_stream`):
- The 65,536-sample stream (`ref/golden/x310_stream_*.hex`) goes through `x310_stream`.
- Every one of the 65,473 sliding-window decisions is compared with the Keras model, 4 seeds × 2 runs. Seeds 1–3 insert ~9,400 idle cycles.

**Negative controls** (`make -C tb x310_neg`): one bit of the expected logits of vector 777 is flipped. Both testbenches FAIL, naming that vector (`x310_neg_*.log`).

**Committed golden subset:** the 8,192 windows of `ref/golden/x310_golden_*` at cutoff 2, 4 seeds × 2 runs: 0 mismatches.

**Results:**

| cutoff | da4ml stages | window test: 8 runs × 100,000 | stream test: 8 runs × 65,473 | negatives | latency window → class (cycles) | latency last sample → decision (cycles) |
|---|---|---|---|---|---|---|
| 1.5 | 19 | 0 mismatches | 0 mismatches | both fail as required | 22 | 23 |
| 2 | 14 | 0 | 0 | both fail | 17 | 18 |
| 2.5 | 12 | 0 | 0 | both fail | 15 | 16 |
| 3 | 10 | 0 | 0 | both fail | 13 | 14 |

**Pre-RTL check:** Keras against da4ml's DAIS interpreter on the full test set and the stream gives 0 mismatching vectors (`ref/golden/x310_golden.json`).

## 7. OOC on the X310's part (model; ooc/, ooc_table.md, synth/sweeps/x5.txt)

**Setup:**
- Vivado 2024.2 on build-host, `xc7k410tffg900-2`, `create_clock` 5.0 ns only;
- top `x310_stream`: shift register, BFP, core and argmax;
- `synth_design -mode out_of_context -flatten_hierarchy full`, then opt, place, phys_opt and route;
- all paths register to register;
- excludes pins, IOBs, the RFNoC shell and the rest of the X310 image;
- reports copied only if not older than their `post_route.dcp`.

| build | cutoff | cycles, last sample → decision (sim) | ns | WNS (ns) | WHS (ns) | LUT | FF | DSP | worst path |
|---|---|---|---|---|---|---|---|---|---|
| x5_k7_lc1.5 | 1.5 | 23 | 115 | +0.303 | +0.081 | 22,463 | 23,507 | 0 | core, 1 LUT, route |
| **x5_k7_lc2** | 2 | **18** | **90** | +0.281 | +0.081 | 22,378 | 18,410 | 0 | core, 2 levels, route |
| x5_k7_lc2.5 | 2.5 | 16 | 80 | +0.113 | +0.082 | 22,347 | 15,083 | 0 | core, 8 levels |
| x5_k7_lc3 | 3 | 14 | 70 | +0.025 | +0.092 | 22,535 | 14,009 | 0 | core, 11 levels (8 CARRY4) |
| x5r1_k7_lc3 (rule-1 pick, over budget) | 3 | 15 | – | **−0.715** | +0.089 | 52,440 | 26,244 | 0 | core |

**Reading the table:**
- Every in-budget build closes. **Cutoff 2 is the recommended build:** 0.28 ns of margin to absorb a congested X310 image. The stock X310_XG leaves 110k LUT free with slices 93.7 % occupied and WNS +0.016 ns (D-S5-TOOL).
- Cutoff 3 is the shallowest that closes, with almost no margin.
- **BFP path slack** was not queried in these four builds (the worst path is in the core). The dry run measured +0.35 ns for it with BFP_PIPE = 1.

**Latency, the two ways D-S5-WIN asks for** (sim cycles × 5.0 ns; clock 200 MHz):
- **Last window sample → decision:** start event, the edge that captures sample n into the shift register; stop event, the edge after which `cls` / `out_vld` hold window n's decision.
  - cutoff 2: 18 cycles = 90 ns;
  - cutoff 3: 14 cycles = 70 ns.
- **First window sample → decision:** add the 63 sample periods of the window.
  - cutoff 2: 81 cycles = 405 ns;
  - cutoff 3: 77 cycles = 385 ns.
- **Excluded:** the ADC's own pipeline and the radio's front-end path before `radio0`, the RFNoC shell, and the host.

## 8. Reproduce (commands)

```
# data (train-host container): 9 splits, content hashes -> ref/x310/x310_split_meta.json; --check regenerates and compares
ssh train-host 'cd <proj> && container/run.sh "python ref/x310/x310_data.py"'
ssh train-host 'cd <proj> && container/run.sh "python ref/x310/separability.py"'           # -> separability.json
# training sweeps (detached), one per job file
ssh train-host 'cd <proj> && TRAIN=ref/x310/train_x310.py RUNS=ref/runs/x310 nohup sw/grumpy/launch_sweep.sh ref/x310/sweeps/<f1|h1|h2|h3|h4>.txt 5 > ref/x310/sweeps/<..>.log 2>&1 &'
# selection: rule 1 (as stated), then the da4ml cost of the W = 64 candidates, then the amended rule
container/run.sh "python ref/x310/select_x310.py --no-test"                                  # scores every checkpoint on val (cache)
container/run.sh "python ref/x310/cost_x310.py --w 64 --max-ebops 80000 --shard <i> --nshard <n>"   # then --merge
container/run.sh "python ref/x310/select_x310.py --max-cost 22000"                           # -> x310_selection.json, chosen.keras
container/run.sh "python ref/x310/export_x310.py --cutoffs 1.5 2 2.5 3"                      # golden + full set + stream + RTL
python3 ref/x310/report_x310.py                                                              # -> evidence/stage5/accuracy.md
# Verilator (build-host)
ssh build-host 'cd <proj> && make -C tb x310 LC=2 JOBS=12'           # full set 4x2, stream 4x2, negatives; XSET=golden for the subset
# OOC (build-host, detached), then collect (ALL stage-5 prefixes in one call)
ssh build-host 'cd <proj> && OOC_INCLUDE=<proj>/rtl/gen OOC_EXTRA_SV=<proj>/rtl/x310/x310_clf_top.sv nohup synth/scripts/launch_ooc_sweep.sh synth/sweeps/x5.txt 4 > synth/sweeps/x5.log 2>&1 &'
STAGE=stage5 python3 synth/scripts/collect_ooc.py x5r1_ x5_
```

**Not committed** (regenerated by the scripts):
- `ref/data/x310/`;
- `ref/runs/x310/` (checkpoints);
- `.scratch/x310_full_*.hex` (the full set, 51 MB in hex; hashes committed);
- `.scratch/x310/rule1/` (the rule-1 RTL and golden set).

**Committed:**
- the golden subset;
- the stream set;
- the calibrated model `ref/golden/x310_hgq.keras` (sha256 `6a039e43…`);
- the candidate, cost and selection records.

## 9. Doubts and open items

1. **Transfer to real captures is the main unknown.** The channel model leaves out several things a TX→RX loop through the WBX will have:
   - TX LO leakage and carrier feed-through. A DC or tone spur in "noise" windows will read as CW.
   - TX and RX phase noise, and DAC images and sin(x)/x.
   - Front-end spurs, AGC-free gain steps, and ADC nonlinearity.
   - The real 40 MHz filter shape: a Butterworth was assumed, and the WBX bandwidth is still to be checked with `uhd_usrp_probe`.
   - UHD's own DC-offset and IQ-balance correction, which may or may not be on.

   The plan (D-S5-SIG) is to replace the test set with captures and to fine-tune on them. Until then every accuracy here is **model** only.
2. **False alarms.**
   - 10 % of noise windows are called a signal.
   - At one decision per sample this needs temporal smoothing or hysteresis before the D-S5-OUT event records, or the event stream floods.
   - Pure-window agreement on the stream is 77 %. Windows at a pulse onset are not in the training set.
3. **The budget cost accuracy.** Inside 22k LUT the classifier is 2.9 points below the over-budget rule-1 pick overall and 1.5 points at SNR ≥ 10 dB (validation), and 4.2 points below float (test). The stock image's 110k free LUT could hold the 52k-LUT net, but it fails 5.0 ns at cutoff 3 by 0.7 ns: a deeper cutoff might close, and that was not tried. The ~25k budget is the brief's.
4. **The SNR ≥ 10 dB criterion is met with little margin:** 96.2 % val and 96.0 % test against 95 %. Noise windows are about 90 % correct at every SNR tag, which pulls that figure down.
5. **The float baselines are three MLP sizes per W.** Larger floats were not tried, so "85.8 % float" is a reference, not a ceiling.
6. **The LFM floor of k ≥ 10 MHz/µs is a design choice** (§1). Slower chirps, which the brief's ranges allow, are indistinguishable from CW in ≤ 320 ns and will be called CW.
7. **The rule-1 Verilator and OOC runs** used `x310_clf_top.sv` before the pruned-lane packing (`IN_COFF`). They are functionally identical for that core, which has no pruned lane; the svh in `.scratch/x310/rule1/gen` now carries the trivial `IN_COFF`.

