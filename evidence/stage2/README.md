# Stage 2 gate — NN surface-code decoder, d = 3 (sim + OOC, no hardware)

**Verdict: PASS (2026-10-20).** The CHARTER's Stage 2 items:

| CHARTER item | Result | Where |
|---|---|---|
| Stim syndromes, PyMatching reference | d = 3 and d = 5, p = 0.1 … 1 % | §1, `pymatching_d5.json`, `ref/golden/qec_d3_test.json` |
| Small NN decoder through the HGQ2/da4ml flow | 24-128-64-32-1 MLP, 30,258 EBOPs | §2, `training/` |
| LER vs PyMatching on held-out syndromes | NN/PM 0.854 at p = 0.1 %, rising to 1.000 at p = 1 % (test) | §3 |
| Bit-exact in Verilator | 0 mismatches: 464,428 vectors × 8 runs × 3 depths, plus all 2^24 inputs × 2 × 3 depths | §4, `verilator/` |
| Cycles and ns on the VU9P (OOC) | **8 cycles at 270 MHz = 29.6 ns** (closest point to the minimum) | §5, `ooc/`, `ooc_table.md` |

Labels: every figure here is **sim** or **model**. No hardware ran in Stage 2.

## 1. Data (ref/qec/qec_data.py, ref/qec/pm_reference.py)

**Circuit and noise:** Stim 1.16.0 `surface_code:rotated_memory_z`, distance d with d rounds. The noise is uniform circuit-level: the after-Clifford depolarisation, the before-round data depolarisation, the before-measure flip and the after-reset flip probabilities all equal p.

**Detectors:** 24 at d = 3. The reference decoder is PyMatching 2.4.0 on `detector_error_model(decompose_errors=True)`.

**Shots per p:**
- train 10^8, val 10^7, test 10^7;
- disjoint seeds: train 100000 + i, val 200000 + i, test 300000 + i;
- p ∈ {0.1, 0.2, 0.3, 0.5, 0.7, 1.0} %.

Each split is stored as a multiset: the distinct detection-event vectors with their counts of observable 0 and 1. That representation is exact, because the decoder is a function of the vector.

**Files:**
- The test multisets are `ref/golden/qec_d3_test.npz`, sha256 `cef4839b…74d0fd`, recorded in `qec_d3_test.json`.
- Train and val are regenerated from their seeds into `ref/data/qec/`, which is not committed.

**LER per round:** (1 − (1 − 2 P_L)^(1/d)) / 2.

**The d = 5 PyMatching reference** (`pymatching_d5.json`, 10^7 shots per p, 120 detectors) is context for Stage 4:

| p | per-shot LER | per-round LER |
|---|---|---|
| 0.1 % | 1.32e-4 | 2.6e-5 |
| 1 % | 8.39e-2 | 1.8e-2 |

## 2. Training and selection (training/)

**Network:** one network serves all p. Its input is the 24 detection bits and its output is one logit; flip = logit > 0, strictly.

**Loss:** BCE against the soft label n1 / (n0 + n1), with each key weighted by n0 + n1 and each p scaled by 1 / (PyMatching train errors).

**HGQ2 quantizers:**
- weights: KBI SAT_SYM;
- datalanes: KIF WRAP, initial f0 = 6;
- rounding: RND;
- EBOPs β ramped from 1e-8 to 1e-6 over 300 epochs.

**Float64 baselines** were trained for 32-16, 64-32, 128-64 and 128-64-32. The best is 128-64-32, with a val geomean NN/PM of 0.8436.

**Compute:**
- The HGQ sweeps ran on train-host in the `opus_nsinfer:1` container (`sw/grumpy/launch_sweep.sh`, `ref/qec/sweeps/g1.txt` and `g2.txt`; logs in `training/g1.log` and `g2.log`).
- A few early runs ran on desk-pc.
- In total: 21 HGQ runs and 546 Pareto checkpoints.

**Datalane f0 matters:**
- Sweep g1 used f0 = 0, meaning the hidden activations start integer-only. It plateaued at a val geomean of about 0.92–0.95.
- Sweep g2 used f0 = 6 or 8 and reached 0.905.

**Selection (validation only, `ref/qec/select_qec.py`):** every Pareto checkpoint was re-scored on val (`candidates.json`).
- **The planned rule failed:** within 0.02 of the float baseline (`select1.log`), 0 of the 546 checkpoints pass. The best HGQ checkpoint is 0.062 above float.
- **The rule used (`select2.log`, `selection.json`):** the lowest-EBOPs checkpoint that matches or beats PyMatching at **every** p on validation (`--max-ratio 1.0`; with `--margin 0.10` the geomean cap does not bind). 21 checkpoints pass.
- **The chosen checkpoint:** `hgq_g2_128_64_32_f6_b6` epoch 118, 31,516 EBOPs at training time, val geomean 0.927 and worst val p 0.998.
- **After export:** trace_minmax calibration on every distinct training vector gives 30,258 EBOPs (`ref/golden/qec_d3_hgq.keras`, sha256 `79eb378d…`).
- **Lower-EBOPs checkpoints** each lose to PyMatching at one p or more. The cheapest of them that still comes within 5 % of PyMatching at every p has 6,674 EBOPs, with a worst val p of 1.037 (`candidates.json`).

## 3. Logical error rate on the held-out test shots (ref/golden/qec_d3_golden.json)

The quantized, calibrated NN (Keras float64, which equals the RTL; see §4) against PyMatching. Both run on the same 10^7 test shots per p, d = 3, 3 rounds:

| p | NN errors | PM errors | NN / PM | NN LER per round | PM LER per round |
|---|---|---|---|---|---|
| 0.1 % | 6,625 | 7,757 | **0.854** | 2.21e-4 | 2.59e-4 |
| 0.2 % | 26,759 | 30,008 | **0.892** | 8.94e-4 | 1.00e-3 |
| 0.3 % | 59,818 | 65,693 | **0.911** | 2.00e-3 | 2.20e-3 |
| 0.5 % | 162,146 | 171,148 | **0.947** | 5.46e-3 | 5.77e-3 |
| 0.7 % | 307,377 | 317,077 | **0.969** | 1.05e-2 | 1.08e-2 |
| 1.0 % | 590,842 | 590,640 | **1.000** | 2.053e-2 | 2.052e-2 |

**Reading the table:**
- The NN is better than matching below 1 %, consistent with matching ignoring the X/Z correlations of depolarising noise.
- At 1 % the two are tied: +202 errors, 0.03 %, well inside the √N shot noise of about 770.
- The float64 baseline of the same shape does better: test NN/PM 0.789 at 0.1 % and 0.905 at 1 % (`selection.json`). The gap is the price of the 30k-EBOP quantization.

## 4. Bit-exactness in Verilator (verilator/, tb/run_qec_stage2.sh)

**DUT:** `rtl/qec_d3_top.sv` = the generated input map (`rtl/qec_d3_in_map.svh`: detection bit j becomes lane j with value 0 or LANE_ONE[j]) + the da4ml core + a flip register (logit > 0). The port is the 24 raw detection bits. Run with Verilator 5.020 on build-host.

**Depths:** cutoffs 5, 3 and 2 (da4ml 6, 10 and 15 stages).

**Golden vectors:** all 464,428 distinct test detection-event vectors (every p) plus the zero vector, with the Keras logits and decisions.
- 4 orders (seed 0 natural; seeds 1–3 xorshift32 shuffles) × 2 runs each, II = 1.
- Logit and flip are checked every cycle.
- 0 mismatches and 0 flip mismatches in all 24 runs; 120,246 flips in every run.
- The logs carry the sha256 of the golden in/out/dec hex and of the top + input map.

**Exhaustive:** all 2^24 inputs against Keras logits (`ref/golden/qec_d3_exhaustive.json`; in `c814528d…`, out `35f09cb6…`, matching each log header).
- Seeds 0 and 1 at each depth: 0 mismatches, XOR signature 07a75 everywhere.
- These runs check the logit; the flip is a fixed comparator, already checked on the golden runs.

**Negative controls** (`qec_d3_lc<c>_negative.log`):
- one bit of the expected logit of vector 421 flipped;
- the expected decision of vector 777 inverted.

Each control gives exactly one MISMATCH (or FLIP_MISMATCH) at that vector and exit 134, at every depth.

**Impulse latency (sim):** measured and asserted.

| cutoff | logit (cycles) | flip (cycles) |
|---|---|---|
| 5 | 7 | 8 |
| 3 | 11 | 12 |
| 2 | 16 | 17 |

**Latency definition:**
- **Start event:** the rising edge that captures the detection-event word into the core's input register.
- **Stop event:** the rising edge after which the flip register holds the decision.
- **Instrument:** the Verilator cycle count.
- **Excludes:** the link and serialisation (Stage 3), syndrome extraction, and the pins.

## 5. OOC on the VU9P (ooc/, ooc_table.md, synth/sweeps/q2.txt, q3.txt)

**model, OOC P&R:**
- **Tool and part:** Vivado 2024.2 on build-host, `xcvu9p-fsgd2104-2L-e`.
- **Flow:** `synth_design -mode out_of_context -flatten_hierarchy full` with top = `qec_d3_top`, then opt, place, phys_opt and route. The only constraint is `create_clock`.
- **What is timed:** every path is register to register.
- **Excludes:** pins, IOBs and the GTY.
- **Report freshness:** reports were copied only if not older than their `post_route.dcp`.
- **Latency:** flip cycles (sim) × constrained period.
- **Hold:** every build has WHS ≥ +0.037 ns.
- **Note:** sweep q1 failed on a script error (`read_verilog` has no `-include_dirs`; the option was moved to `synth_design`) and produced no results.

Shallowest pipeline that closes at each clock, and each depth's highest closing clock:

| Clock | Cutoff | Cycles (sim) | Latency | WNS (ns) | LUT | FF | DSP |
|---|---|---|---|---|---|---|---|
| 240 MHz | 5 | 8 | **33.3 ns** | +0.164 | 16,389 | 4,498 | 0 |
| **270 MHz (lc5 max)** | 5 | 8 | **29.6 ns** | +0.074 | 16,874 | 4,490 | 0 |
| 300 MHz | 3 | 12 | **40.0 ns** | +0.238 | 15,302 | 7,926 | 0 |
| **390 MHz (lc3 max)** | 3 | 12 | **30.8 ns** | +0.011 | 16,236 | 7,918 | 0 |
| 400 MHz | 2 | 17 | **42.5 ns** | +0.051 | 15,680 | 11,494 | 0 |
| **450 MHz (lc2, highest tried)** | 2 | 17 | **37.8 ns** | +0.044 | 15,828 | 11,491 | 0 |

**Fails:**
- lc5 at 280 MHz (−0.073), at 300 MHz (−0.300; also −0.278 with `-retiming`) and at 400 MHz (−1.064);
- lc3 at 400 MHz (−0.027).

**The minimum:** the lowest wall-clock latency is about 29–31 ns, either at 8 cycles near 270 MHz or at 12 cycles near 390 MHz. As in Stage 0, it is flat across 2–6 stages. The clock for Stage 3 follows the GTY user clock; this table says which cutoff to use at that clock.

**Against the target:** CHARTER success criterion B is a decode under 124 ns at d = 3 on the VU9P.
- The published figure is an NN decode of **124 ns**, **hardware-measured** on a Kintex-7 XC7K410T (arXiv 2605.04892, preprint).
- Ours is **29.6 ns OOC** on the VU9P: network only, register to register.
- This is not yet like for like. Stage 3 measures the decode inside the GTY loop on the BCU-1525 silicon.

**Area:** about 15–17k LUT, 0 DSP, 0 BRAM. That is 1.3–1.5 % of the VU9P's 1,182k LUTs.

## 6. Reproduce

```
# train-host (container): data, training, selection, export
container/run.sh "python ref/qec/qec_data.py"
sw/grumpy/launch_sweep.sh ref/qec/sweeps/g2.txt 10
container/run.sh "python ref/qec/select_qec.py --margin 0.10 --max-ratio 1.0"
container/run.sh "python ref/qec/export_qec.py --model ref/runs/qec/chosen.keras --exhaustive --cutoffs 2 3 5"
# build-host: Verilator gate and OOC
tb/run_qec_stage2.sh 5 3 2
synth/scripts/launch_ooc_sweep.sh synth/sweeps/q2.txt 5; synth/scripts/launch_ooc_sweep.sh synth/sweeps/q3.txt 4
STAGE=stage2 python3 synth/scripts/collect_ooc.py q2_ q3_
```
