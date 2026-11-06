# Stage 5 v2: the measured-channel classifier on the X310 (2026-11-03)

Why v2 exists: `../bpsk/README.md` (BPSK 65.5 % on silicon; root cause the training channel model). Decision:
PLAN.md D-S5-CH. Labels: **silicon**, **sim**, **model**, **derived**. Clock: radio_clk 200 MHz, 1 cycle = 1 sample
= 5 ns.

## 0. Result

| | class-balanced | SNR >= 10 dB, class-balanced | noise | CW | LFM | BPSK |
|---|---|---|---|---|---|---|
| **v2 silicon, fresh TX seeds 8-15** (8 captures, 23.8 M labelled windows) | **91.5** | **98.4** | 98.3 | 92.6 | 86.9 | **88.2** |
| v2 silicon, TX seeds 0-7 (the v1 campaign-2 schedules) | 91.4 | 98.3 | 98.3 | 92.7 | 86.7 | 87.9 |
| v2 model (exported = RTL, measured-channel test set) | 91.1 | 98.2 | 97.1 | 91.3 | 88.3 | 87.7 |
| v1 silicon, seeds 0-7 (`../silicon/lead/analysis.md`) | 81.8 | 97.4 | 99.9 | 84.5 | 77.5 | 65.5 |

* Bit-exact on silicon: all 20 v2 captures (16 dense, 2 noise-only, 2 sparse event runs; 84.2 M decisions) replay in
  Verilator to the block's MISR / counts / first and last tau; the 2 event runs' 618 + 1,546 in-window event records
  equal the replay's (`silicon/replay_*.log`).
* Silicon now agrees with the model bin by bin (`silicon/test/analysis.md`, per-SNR table: within ~1 point from
  -2.5 dB up). BPSK at SNR >= 10 dB: 97.7-98.7 % for every code / chip-rate bin (v1: 88.9-95.1 %).
* Spread over the 8 test captures: class-balanced 91.48 +/- 0.18 %, SNR >= 10 dB 98.36 +/- 0.03 %.
* Cost: noise-only false alarms per decision 1.70 % (v1 0.14 %; `noise_s2`, `noise_s3`, no TX). They are short:
  the longest run of non-noise decisions on noise is 29, so a K = 16 hysteresis gives 95-190 events/s and K >= 32
  none in 4.2 M decisions (derived from the silicon decisions: `silicon/k_scan_noise_s2.log`, `_s3`,
  `sw/x310/k_scan.py`).
* Latency changes (section 3): block L = 22 cycles (110 ns; v1 19 = 95 ns); detection median at SNR >= 10 dB
  BPSK 155 / LFM 175 / CW 330 ns (v1 150 / 170 / 225 ns).

## 1. Model (`../accuracy_meas.md`, every number **model**)

Data: `ref/x310/x310_data.py` channel 'meas' (`X310_CHANNEL`, default), W = 64, 200k / 25k / 25k windows per class,
hashes `ref/x310/x310_meas_split_meta.json`. Training on build-host (`sw/snoke_sweep.sh`, sweeps `ref/x310/sweeps/m1.txt`,
`m2.txt`; train-host unreachable): float `float_w64_128_64_32`, HGQ `hgq_w64_96_48_24_b2e5_e300` with seeds 1, 2, 3
and `..._b3e5_e300`. Selection (D-S5-SEL amended, unchanged rule, `select.log`, `ref/x310/x310_meas_selection.json`):
285 Pareto checkpoints, 112 costed (`ref/x310/x310_meas_cost.json`), 69 inside 22,000 LUT est. with val acc at SNR >=
10 dB >= 0.95; chosen `hgq_w64_96_48_24_b2e5_e300_s3/pareto/e0260` (22,727 EBOPs, 22,121 after calibration, da4ml
21,363 LUT est.; v1 21,424). Test: 91.1 % / 98.2 % at SNR >= 10 dB (float64 93.9 / 99.2); v1 81.5 / 96.0.
Export: `export.log`, cutoffs 1.5 / 2 / 2.5 / 3 (`rtl/gen/x310_clf_lc*`); Keras vs da4ml interpreter 0 mismatching
vectors on the full test set and the stream.

## 2. RTL and image

* Core at cutoff 2: 17 stages (v1 14) -> CORE_LAT 18, block L = IN_REG + 1 + CORE_LAT + 1 + BFP_PIPE = 22 cycles.
  OUT_W 65 (v1 62): the MISR word {logits, cls} is folded to 64 bits (bits 64.. XORed into the top, cls stays in
  [1:0]; `rtl/x310/nsclf_core.sv` dword, `sw/x310/nsclf_model.py` dec_word). `rfnoc/blocks/nsclf.yml`,
  `rfnoc/icores/x310_XG_nsclf.yml` CORE_LAT 18; noc_shell / block wrapper regenerated (`rfnoc/gen_nsclf.sh`).
* Verilator (sim, build-host): `verilator/` full test set 100,000 vectors x 4 seeds x 2 runs and stream 65,473 windows
  x 4 x 2: 0 mismatches, latency 20 = CORE_LAT + 1 + BFP_PIPE; negatives fail. `block/`: nsclf 4 configs x 2, 0
  decision / tau / latency / pass-through / register / event mismatches; 3 negatives fail; lint clean. UHD xsim of the
  whole block (`block/uhdsim_nsclf_rfnoc_block_nsclf_tb.log`): PASSED, 338 / 338 events.
* Image (`build/`): `synth/scripts/launch_x310_nsclf.sh x310_xg_nsclf_v2_lc2_1 2` (UHD 4.9 flow, Vivado 2024.2):
  setup met (WNS +0.011 ns), hold not (WHS -0.057 ns, 12 endpoints); the stock hold fix (`evidence/stage5/toolchain/
  holdfix.tcl physopt_hold`) on its post_route.dcp: **WNS +0.011 / WHS +0.003 / WPWS +0.001 ns, "All user specified
  timing constraints are met"** (fresh reports `build/report_fresh/`, worst setup radio_clk). Bitstream written from
  that checkpoint with UHD's bitstream properties (`build/bit.tcl`): `.scratch/s5_build/
  x310_xg_nsclf_v2_lc2_1_holdfix_physopt_hold_bit/x300.bit`, md5 6ba311719d968c80552ba3ae1830a5b5. The same 33 critical
  warnings as v1 (32 DDR3 IDELAY REFCLK, 1 evaluation core: NEXT_SESSION item e). nsclf0: 24,809 LUT, 22,413 FF, 1
  BRAM (classifier 22,649 LUT). Variants from post_synth.dcp did not beat it (`build/other_variants_results.txt`).
* Loaded by JTAG only (volatile, `silicon/jtag_load_*.log`); read back (`silicon/nsclf_info_1.log`): cutoff 2,
  CORE_LAT 18, LATENCY 22.

## 3. Latency (silicon, `silicon/test/analysis.md`)

Start: pulse onset at the classifier's tap (TX schedule + measured D = 133.70 samples); stop: the tap time tau of the
first decision of the pulse's class + L = 22 cycles (the decision is valid L cycles after its newest sample is at
the tap); instrument: the X310's radio time (the decisions are the silicon ones, proven by the MISR); excluded: the
~160 ns before the tap (ADC, radio front end; derived in `../silicon/README.md`). SNR >= 10 dB medians: BPSK 9 + 22 =
31 cycles = 155 ns, LFM 13 + 22 = 175 ns, CW 44 + 22 = 330 ns; 100 % of those pulses detected. CW is ~100 ns later
than v1 (26 + 19 cycles): the v2 model calls CW only once more of the window holds the tone. K = 16 events (sparse
runs, silicon event records): median 66 cycles after onset at SNR >= 10 dB (v1 66).

## 4. Campaign notes (`silicon/`)

* `sw/x310/s5v2_campaign.sh`: dense `sigL_s0..15` (31.5 ms TX lead-in, K = 60000), `noise_s2/3`, `evt_s102` (no
  lead-in, as v1) and `evt_s103` (lead-in). Hashes: `silicon/captures.sha256`.
* **Session init failures:** on 2026-11-03 afternoon a new UHD session right after a TX/RX capture often failed to
  open the graph (Radio#0 control ACK timeout at init; `silicon/failed_init/`). The capture then never starts (no
  partial data). The v1 image does the same (checked by loading it: first session after a capture failed, later ones
  opened), so it is not the v2 bitstream; a volatile JTAG reload cleared it every time. The campaign script retries
  and reloads. Root cause not established (v1's morning campaign did not see it; build-host was heavily loaded).
* evt_s102's first try with the lead-in overflowed the host: the DC step at TX start (D-S5-LEAD) makes the classifier
  emit ~5e4 events at K = 16 before the capture window (D-S5-EVK); without the lead-in it completed.

## 5. Reproduce

`sw/reproduce.sh 5` (data hash checks of both channels' sets, the Verilator gate, replays of `sigL_s8..15`,
`noise_s2/3`, `evt_s102/103` and the analysis diff against `silicon/test/summary.json`; log `reproduce5.log`). Analysis: `sw/x310/nsclf_analyze.py --cap .scratch/s5_cap_v2 --replay
.scratch/nsclf_replay_v2 --model-json evidence/stage5/v2/model_ref.json --stems sigL_s{8..15} evt_s102 evt_s103
noise_s2 noise_s3 --out evidence/stage5/v2/silicon/test` (and `--stems sigL_s{0..7} --out .../same_tx_as_v1`).
Diagnosis tools: `sw/x310/bpsk_diag.py`, `bpsk_spectrum.py`, `eval_on_captures.py` (`../bpsk/`). v1 is reproduced by
`sw/reproduce.sh 5` at commit 2eba869.
