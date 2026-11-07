# PLAN — architecture and stage plan (decisions live here)

Contract: `CHARTER.md`. Measurement method for Artifact A: `docs/MEASUREMENT.md`.
Each decision below carries its reason; change it here before changing code.

## 0. The flow (shared by all three artifacts)

```
ref/fetch_jsc.py      frozen split (hash in ref/jsc_split_meta.json)
ref/train_jsc.py      HGQ2 training, float64, JAX backend, Pareto checkpoints
ref/select_jsc.py     choose the checkpoint (rule in §A.1), copy to ref/runs/chosen.keras
ref/export_jsc.py     trace_minmax calibration -> golden vectors (full test set,
                      hashed, committed in ref/golden/) -> da4ml CombLogic ->
                      Keras-vs-DAIS-interpreter check -> RTL per latency cutoff
                      in rtl/gen/jsc_lc<cutoff>/
tb/  (make -C tb jsc LC=<cutoff>, on build-host)  Verilator: impulse latency + full
                      test set back to back at II = 1, 4 seeded orders x 2 runs
synth/scripts/ooc_jsc.tcl + launch_ooc_sweep.sh   OOC synth+P&R sweep on build-host
```

Decisions:
- **RTL comes straight from da4ml** (`da4ml.codegen.RTLModel`), not through an
  HLS compile. hls4ml's DA strategy on the Vivado/Vitis backend emits HLS C++
  around the same da4ml solution; going direct removes the HLS compiler from
  the bit-exactness chain (the charter's "hls4ml/da4ml" flow, minimum tools).
  hls4ml 1.3.0 is pinned for a later cross-check and for the hls4ml PR.
- **float64 + JAX x64 everywhere.** Every published da4ml mismatch was float32
  emulation of ≥23-bit accumulators; float64 represents every value exactly.
- **Quantizers**: weights/biases KBI with SAT_SYM; activations KIF with WRAP,
  integer bits fixed by `trace_minmax` over the training split (the
  calibration set is that split, reproducible from its hash); RND rounding.
  WRAP is free in hardware; the Keras model wraps identically, so test
  vectors outside the calibrated range are still bit-exact (only accuracy can
  suffer, and it is measured on the full test set).
- **Golden vectors**: the full 166,000-jet test set, exported once from the
  chosen model; `jsc_golden_{in,out}.hex` (lane 0 at the LSB, two's
  complement per lane, widths in `jsc_golden.json`) are what Verilator reads,
  and the same files feed the silicon harness's vector memory at Stage 1.
- **da4ml static primitives** (`binop.v`, `mux.v`, `multiplier.v`,
  `lookup_table.v`) are LGPL-3.0 files copied by the generator; they are
  committed unmodified under `rtl/gen/*/src/static/` with the licence noted in
  `NOTICE`. Hand-written RTL in `rtl/` is Apache-2.0.

## A. Artifact A — ZCU102, measured pin-to-pin latency

### A.1 Model choice
Architecture 16-64-32-32-5 ReLU (the hls4ml HLF JSC benchmark, identical to
the published HGQ+DA JSC). Selection rule, applied on the VALIDATION split
only: the lowest-EBOPs Pareto checkpoint whose validation accuracy is within
0.4 points of the float64 baseline's; then report test accuracy once. The
charter target is ≤0.5 points from float on the full test set.

### A.2 Clocks and pipeline depth
Depth is set by da4ml's `latency_cutoff` (adder-delay units). For each part
(ZU9EG -2-i ES2 silicon, VU9P -2L) and each target clock (200 MHz, 400 MHz,
maximum that closes) we pick the shallowest cutoff that closes in OOC P&R.
Report: cycles (measured in Verilator by the impulse test), ns = cycles x
period, LUT, FF, DSP, WNS, from fresh reports. The OOC number excludes pins,
IOBs and board; it is the prediction placed beside each silicon number.

Stage 0 result (model, OOC P&R): shallowest closing depth per clock gives
35.0 ns at 200 MHz (cutoff 5, 7 cycles), **33.3 ns at 300 MHz (cutoff 3,
10 cycles)**, 35.0 ns at 400 MHz (cutoff 2, 14 cycles), 54.0 ns at the
500 MHz maximum (cutoff 1, 27 cycles) on the ZU9EG; identical depths on the
VU9P. **Stage 1 clocks: 300 MHz (the SI570's power-up frequency, through
an MMCM for the phase-shift fixture), 200 MHz, and 500 MHz.** Each
silicon build re-closes timing with the harness around the core; the
OOC row is the prediction beside each silicon number.

### A.3 Board design (Stage 1) — as built (details: `docs/ARCHITECTURE.md`)
- **One network clock domain**: SI570 (300 MHz at power-up, measured on zcu102
  2026-10-20) -> one MMCME4 -> clk_net. Harness, network, argmax and the
  timestamp counter K_* are all on clk_net. One bitstream per clock.
- **clk_axi** = clk_net at 300 and 200 MHz (single domain); at 500 MHz it is
  clk_net/2 from the same MMCM (synchronous, timed; HPM0 and the AXI path do
  not close at 500 MHz). Control crosses as quasi-static registered words;
  never on the measured path. This is the documented exception.
- **clk_ps** (MMCM CLKOUT1, fine phase shift) is the measurement fixture
  only: the launch flop of pin B and the readback flop of pin C. Its two
  anchor crossings (l_tw -> h_ff, c_tw -> g_ff) are timed on purpose (their
  routed delays are model inputs); every other clk_ps crossing is a false
  path. Reason: without a scope or pulse generator, the phase sweep is the
  only way to resolve sub-cycle pad delays (`docs/MEASUREMENT.md` §2a).
- **Pad loopback, no jumpers** (user: no scope/AWG/FMC card): pins B (A20)
  and C (D20) are IOBUFs with the output always enabled; each input buffer
  reads its own pad. The IOBUF T input is a constant-0 DONT_TOUCH flop, not a
  literal 0: with a literal, Vivado's case analysis disables the IBUFCTRL
  I->O arc and the pad -> IPFF path is never timed.
- **D-S1-IOB: pad flops in fabric slices, not the HD IOLOGIC** (2026-10-20).
  The HD IOLOGIC flip-flop has a Min Period of 8.000 ns in the 2024.2 speed
  file (125 MHz); IOB-packed builds fail pulse width by -4.667 ns at 300 MHz
  (`synth/out_s1_p300_lc3_e`). Slices next to the pads close with full
  sign-off (`synth/out_s1_p300_lc3_fab_c`: WNS +0.010, WHS +0.014, WPWS
  +0.166) for about +0.5 ns on the input and +0.17 ns on the output pad path,
  all of which is inside the silicon-measured d_B / d_C. Datapath bounds
  (2.0 ns in, 3.4 ns out) keep the placer at the pads; the IOB check in
  `stage1_build.tcl` enforces one sampling flop per input pad.
- **SmartConnect**, not AXI Interconnect, between HPM0_FPD (128 bit) and the
  21-bit AXI4-Lite slave: the Interconnect's downsizer fails at 300 MHz
  (-0.325 ns into PS8 RVALID); SmartConnect closes.
- Path under test: vector BRAM (loaded over AXI from the golden hex) ->
  staging register held stable -> launch strobe out of pin B (clk_ps) ->
  pad -> pin B readback flop (clk_net) -> synchroniser -> network input
  register -> network (LAT_NET) -> argmax (ARG_LAT 1, or 2 at 500 MHz; first
  maximum, verified against `np.argmax`) -> DEC_VALID flop -> pin C. N_core =
  LAT_NET + ARG_LAT + 2 cycles, asserted in simulation and read on silicon.
- Bit-exactness on silicon: every vector streamed at II = 1 from vector BRAM,
  logits + class into result BRAM, compared by `sw/zcu102/jsc_host.py stream`
  with the committed golden vectors; 4 orders x 2 runs without reprogramming.
- Loaded through the PS fpga_manager sysfs (zcu102 has no `fpgautil`; the
  rootfs is RAM, `/lib/firmware` is created per boot); never QSPI/SD writes.

## B. Artifact B — NN surface-code decoder over GTY (BCU-1525)

### B.1 Reference (Stage 2, simulation) — as built
- **Circuit and noise (D-S2-NOISE):** Stim `surface_code:rotated_memory_z`, d rounds, uniform
  circuit-level noise p on all four knobs (`after_clifford_depolarization`,
  `before_round_data_depolarization`, `before_measure_flip_probability`,
  `after_reset_flip_probability`), p in {0.1, 0.2, 0.3, 0.5, 0.7, 1.0} %. Circuits committed in
  `ref/qec/circuits/`. Detectors: 24 at d = 3, 120 at d = 5; one observable.
- **Reference decoder:** PyMatching 2.4.0 on `detector_error_model(decompose_errors=True)`.
  Logical error rate (LER) per shot and per round, `(1 - (1 - 2 P_L)^(1/d)) / 2`.
- **Data as multisets (D-S2-TABLE):** at d = 3 each split is stored as the distinct
  detection-event vectors with shot counts n0 / n1 (observable not flipped / flipped). Lossless
  for a decoder (a function of the detection events): errors = sum of n_(1-decision). Train 10^8,
  val 10^7, test 10^7 shots per p, disjoint Stim seeds (`ref/qec/qec_data.py`, SEED_BASE). Training
  uses BCE on the soft label n1/(n0+n1) weighted by n0+n1 (exactly the per-shot loss), each p
  scaled by 1 / (PyMatching training errors) so every p counts its logical errors equally.
  One network for all p (a hardware decoder cannot know p).
- **NN:** 24 detection bits -> MLP (ReLU) -> one logit; **flip = logit > 0**. HGQ2 as Stage 0
  (KBI SAT_SYM weights, KIF WRAP activations, RND), float64 on JAX. Datalane f0 = 6 (g1 sweep
  used 0: hidden activations started integer-only and plateaued about 10 % above float).
- **Input quantizer is learned (D-S2-INMAP):** HGQ2 may prune a detector or give it a negative
  fractional bit (a 1 arrives as 2). Each detector stays a 0 / v_j switch; `qec_d3_top` maps the 24
  raw detection bits to the core's lanes with the generated `rtl/qec_d3_in_map.svh`, so the
  decoder port is always the 24 detection bits. Export asserts the switch property.
- **Selection (validation only, D-S2-SEL):** `ref/qec/select_qec.py`; rule recorded in
  `ref/qec/qec_selection.json`. Test numbers reported once, after the choice. The planned rule
  (val geomean NN/PM within 0.02 of the best float64) passed 0 of 546 checkpoints (best HGQ
  0.905 vs float 0.844). Used instead: **lowest EBOPs whose val NN/PM is <= 1.0 at every p**
  (`--margin 0.10 --max-ratio 1.0`): a decoder that is never worse than matching. Chosen
  128-64-32, 30,258 EBOPs after calibration; test NN/PM 0.854 (0.1 %) … 1.000 (1 %).
- **Bit-exactness:** (1) every distinct test detection-event vector (all p) + zero, 4 seeds x 2
  runs, logit and flip; (2) **exhaustive**: all 2^24 inputs against Keras logits (generated from
  the frozen model, hashes in `ref/golden/qec_d3_exhaustive.json`, 200 MB not committed);
  (3) negative controls (one corrupted logit word, one corrupted flip bit) must fail.
- **OOC:** `qec_d3_top` (core + input map + flip register) on `xcvu9p-fsgd2104-2L-e` at 240,
  300, 400 MHz and the maximum closing clock; cycles from Verilator, ns = cycles x period.
  Target < 124 ns decode (2605.04892, Kintex-7, hardware-measured; ours OOC, labelled).
  Result: lc5 8 cycles at 270 MHz = 29.6 ns; lc3 12 cycles at 390 MHz = 30.8 ns; 15–17k LUT.
- **Gate passed 2026-10-20:** `evidence/stage2/README.md`.
- **Compute:** training on train-host in `container/` (docs/TOOLS.md), Verilator on build-host,
  Vivado on build-host.
- **d = 5:** PyMatching reference here (`evidence/stage2/pymatching_d5.json`); the d = 5 NN is
  Stage 4 work (CHARTER: "grow the decoder to distance 5 at II = 1").

### B.2 Loop (Stage 3/4, silicon)
- Preferred link: the lab Aurora 64B/66B 100G design
  (`claude_ip/ethernet/aurora_64b66b_100g`), QSFP28 cage 0 -> DAC -> cage 1 on
  the same card. Syndrome player (BRAM of Stim shots) -> Aurora TX (cage 0)
  -> cable -> Aurora RX (cage 1) -> decoder (same SLR as the GTY quad, in the
  GTY user-clock domain) -> Aurora TX (cage 1) -> cable -> RX (cage 0) ->
  checker. Free-running counter in one domain stamps send, arrival,
  decision and return.
- Measured in order: link alone (loopback with timestamps), decode alone
  (on-chip counters around the decoder), then the loop; link cost reported
  separately. Logical error rate on hardware vs PyMatching on the same shots.
- Board discipline: shared lock `<lab-share>/fpga/.fable5_board.lock`,
  reprogram only via `fable5_llm/sw/program_fpga.sh` (copied with provenance),
  no host-visible BAR/AXI change without a stalled-completion analysis.
- Cable: the user's QSFP+ 40G DAC (4 x 10.3125 Gb/s) plugs straight into the
  QSFP28 cages; the loop runs at 10G lane rate. A second BCU-1525 (desk, bench
  PSU, USB JTAG to build-host, no PCIe, its own lock file) allows a card-to-card
  link. Fallback: GTY near-end PMA loopback (labelled: no cable, no board trace).
- Stretch (Stage 6): thin custom GTY framing to beat ~156 ns one way.

### B.3 Stage 3 as designed (2026-10-21)
- **D-S3-CARD:** the desk card (#2) only, by JTAG, under its own lock
  `<lab-share>/fpga/.opus_nsinfer_desk_bcu.lock` (`board_lock.py` with `FABLE5_BOARD_LOCK`
  pointed there). The shared PCIe card is not touched. Our programming script names the desk
  card's JTAG target explicitly and refuses the PCIe card's cable (`PCIE-BCU-JTAG`). Volatile
  loads only; nothing writes flash.
- **D-S3-LINK:** Aurora 64B/66B v13.0, 1 lane per core at 10.3125 Gb/s, streaming, CRC off, no
  flow control (`synth/scripts/s3_gen_aurora.tcl`). Core A on QSFP0 lane 0 (X1Y48, refclk
  K11/K10 from Si5335 U9), core B on QSFP1 lane 0 (X1Y44, refclk P11/P10 from U12), both
  161.1328125 MHz (FS = 10). user_clk = TXOUTCLK = 161.13 MHz; RX goes through the core's fabric
  CBCC FIFO (no bypass option). Board pins: `docs/BCU1525.md` (Corundum's AU200/VCU1525 XDC).
- **D-S3-CLK:** three kinds of clock, and why. A's user_clk runs the player, the send and return
  timestamps and the checker: the loop latency is one counter in one domain. B's user_clk runs
  the decoder, so the network is in the GTY user-clock domain, as §A/CLAUDE.md allow. The two are
  plesiochronous (separate Si5335 outputs); the data crosses only over the cable, through
  Aurora's own CBCC. init_clk = 100 MHz from a 300 MHz board clock, which also clocks the JTAG-AXI
  register file. Its crossings are 2-flop synchronisers on quasi-static control (set before a
  run) and on results read after `done`. No async FIFOs.
- **D-S3-CUT:** the decoder at 161.13 MHz uses the shallowest cutoff that closes there with
  margin. lc8 is 6 cycles to flip (37.2 ns) against lc5's 8 cycles (49.6 ns); the choice is
  recorded with its OOC run (synth/sweeps/q4.txt).
- **D-S3-SHOTS:** the shots are the 464,428 golden detection vectors (every distinct held-out
  test vector) in BRAM, initialised from hex, with the expected decision. Every returned
  decision is stored per vector and read back by JTAG. The silicon LER is **derived**: silicon
  decisions weighted by the test multiset counts, compared with PyMatching on the same 10^7
  shots per p.
- **D-S3-MEAS:** the three measurements, in order. (1) **Echo mode** (B returns each word without
  decoding through a fixed, documented register path) gives the link round trip. (2) **Decode
  alone**: B's own counters around the decoder. (3) **Decode mode**: the loop. The silicon
  histograms are in A's user-clock cycles (6.206 ns), with min / median / max and the
  echo-mode subtraction.
- **Sim first:** `tb/tb_s3_loop.sv` models the two links behaviourally (latency, clock
  compensation, plesiochronous clocks) around the real side-A / side-B RTL and the real decoder.
  It must be bit-exact on all 464,428 vectors before any bitstream. Aurora itself is
  characterised on silicon in echo mode.
- **Gate passed 2026-10-23:** `evidence/stage3/README.md`. lc8 decode is 37.2 ns (silicon);
  the loop median is 769.6 ns; the Aurora round trip is about 727 ns.

### B.4 Stage 4 as designed (2026-10-23): d = 5 at II = 1
- **D-S4-DATA:** Stim `rotated_memory_z`, d = 5, 5 rounds, the d = 3 noise model and seeds
  (`ref/qec/qec_data_d5.py`); 120 detectors, bit-packed tables (3e7 train / 2e6 val / 5e6 test shots
  per p). PyMatching per-shot LER 1.30e-4 (0.1 %) to 8.39e-2 (1 %) (`ref/golden/qec_d5_data.json`).
- **D-S4-NET:** float64 baselines `ref/qec/sweeps/d5_f1.txt`. Val geomean NN/PM: 512-256-128 0.95
  (epoch 149), 256-256-256 0.969 (stopped at 164); 128-64 / 256-128 plateaued at 1.42 / 1.38 (stopped).
  The deep nets beat PyMatching at low p (0.71–0.79 at 0.1 %) and lose at high p (1.19–1.21 at 1 %).
  HGQ2 from scratch failed twice: `d5_h1` (beta to 1e-6/1e-7): the d = 5 BCE is ~0.0016, so beta x
  EBOPs outweighed it and val stalled at 2.9; `d5_h2` (beta 1e-11 -> 1e-9/1e-10): 2.10 at epoch 28 vs
  float 1.34 at 30, i.e. slow convergence. `d5_x1` (6000-step probes: float, WRAP, SAT datalanes,
  12-bit weights) showed no early gap, so no single quantizer setting is at fault. **Used: warm start**
  (`--init-from` the float 256x3 best.keras, lr 5e-4, 60 epochs; `d5_h3.txt`, beta end 1e-9 / 3e-9 /
  1e-8): val 0.987 after one epoch. (Loss values printed by HGQ include the bit regularisers and are
  not comparable with float losses.) All three `d5_h3` runs then collapsed at ~5.0M EBOPs (epoch
  22–24, geomean 0.97 -> 5+, whatever the beta). In the last checkpoint before the collapse,
  `e0023_r0.97226_ebops5060991`, the validation |x| of 7, 8 and 12 lanes into fc2, fc3 and out already
  reached the trained 2^i. Under WRAP these lanes fold; once a heavily weighted lane folds, the
  decoder breaks. Re-tracing that checkpoint's ranges keeps NN/PM 0.728 / 1.206 at 0.1 % / 1 %
  (5.11M EBOPs). **Used: SAT datalanes** (`d5_h4.txt`: d5_h3 plus `--dl-overflow SAT`, which trained
  normally in the d5_x1 probe). The export re-traces the ranges over the whole training set.
- **D-S4-SEL:** `select_qec.py --d 5 --margin 0.10 --max-ratio 100`: the lowest-EBOPs HGQ checkpoint
  whose val geomean NN/PM is within 0.10 of the best float64 d = 5 baseline. The d = 3 per-p cap
  (NN <= PM everywhere) is dropped because no d = 5 network meets it; the README states that the
  d = 5 decoder is worse than matching and by how much, per p, on the test set.
  **Amended 2026-10-26 (routability):** that rule's pick (`hgq_d5s_256x3_b3e9` e0044, 3.58M EBOPs,
  val 1.024, test 1.033) is bit-exact in Verilator but does not route on the VU9P at 6.206 ns. The OOC
  result is in `evidence/stage4/ooc/q5_*`: ~500k LUT, congestion level 7, 3.4e5 unrouted nets at lc8.
  The rule is now: the best-val-geomean Pareto checkpoint with EBOPs <= B. B is the largest EBOPs at
  which an OOC probe (`synth/sweeps/q5p*.txt`, lc8, 6.206 ns) routes with WNS >= 0. The probe is an
  input to the choice; test numbers are still read once, after the choice. The README reports the
  unroutable 3.58M core's test ratios beside the built one's, so the accuracy given up for fit is
  stated per p.
  **Amended 2026-10-28 (probe flow, B):** no lc8 probe closes, and neither does any lc of the 1.92M
  256x3 core (best lc3 -3.48 ns). The failing paths are 2-4 LUTs with ~95% route delay: each layer's
  output register broadcasts (fanout 80-190) to an all-to-all next layer. Synthesis `max_fanout`, forced
  phys_opt replication, SLR1 pblocks and aggressive directives all made it worse or unroutable
  (`evidence/stage4/ooc/q5p_*`, `q5p_unrouted.txt`). What works: a smaller narrow net plus a pure
  broadcast register before every stage whose output is > 1.3x its input
  (`BC_RATIO=1.3 synth/scripts/add_bcast.py <gen> <out> 0 auto`; latency +N cycles, II = 1, one clock,
  arithmetic unchanged, Verilator bit-exact on the golden set). The probe flow is therefore lc3 +
  broadcast registers. B = 1,018,201 EBOPs (training count; 933,465 calibrated): the 192-96-96 checkpoint
  `hgq_d5nr_192_96_96_to1e8` e0023 closes at WNS +0.035 ns / WHS +0.042 ns, 148k LUT
  (`evidence/stage4/ooc/q5m10_vu9p_lc3bc4_f161_*`); the 1.53M-1.92M probes do not. Disclosure: each
  probe export prints that core's test LER (export_qec_d5.py always does); those numbers were not
  used for B or the choice, which remain validation-only.
- **D-S4-GOLDEN:** the full test set (~1.9e7 distinct vectors, 0.6 GB of hex) is not committed:
  `ref/qec/export_qec_d5.py` writes it to `.scratch/qec_d5_full_*.hex` with SHA-256 in
  `ref/golden/qec_d5_full.json`, and Verilator runs it once (seeds 0 and 1, `make -C tb qec5_full`).
  The committed golden set is 131,072 vectors drawn per p with a fixed seed (zero vector first):
  the Verilator 4x2 set and the silicon shots (BRAM holds about 640k at 31 digits/shot).
- **D-S4-LINK:** 3-lane Aurora (192-bit words, `aurora3_a/b`), same cages, same refclks; loop RTL
  parametric in N_DET / DW (`-GN_DET=120 -GDW=192`). Measurement as D-S3-MEAS. All six lane_up bits
  came up on the first silicon load (LINK `0x7F0C3333`).
- **D-S4-SETS (2026-10-29):** CHARTER rule (c) (>= 4 vector sets, each run twice without reprogramming)
  on silicon. The shot ROM is fixed at build time, so each set is its own build (the ROM is the only
  difference) and its own load. Set 0 is the golden set; sets 1-3 are seeded draws from the full test set
  (`tb/s4_vector_sets.py`). `s3_bitstream.tcl` now requires the passing loop sims to be on the build's exact
  shot ROM (sha256 in the sim log). Stage 3 did not apply rule (c) this way (one vector set, three runs
  of lc8); that stays as recorded.
- **Gate passed 2026-10-29:** `evidence/stage4/README.md`. The decode is 19 cycles = 117.9 ns
  (silicon); the loop median is 844-856 ns, worst shot 943.3 ns; 27/27 silicon runs PASS over 4 sets.
  The LER is NN/PM 0.986 at p = 0.1 % to 1.523 at 1 %.

### B.5 Stage 6 as designed (2026-11-03): a thin custom GTY link instead of Aurora
Goal (CHARTER stretch 6): one-way link latency under the published ~156 ns custom link, measured as Stage 3/4
measured Aurora (Aurora: echo median 118 cycles, link round trip 117 cycles = 727 ns). Sources read for this
note: AMD UG578 v1.4 (2025-12-19, GTY user guide; fetched as PDF through the docs.amd.com document API, kept in
the session scratchpad, not committed), the generated GT Wizard 1.7 products (`rtl/ip/s6_gt/`), the Aurora GT
wrapper of Stage 3 (`rtl/ip/aurora_a/`). AR 69011 (GTY latency values) is still not reachable (support portal
returns a loading shell): **no AMD latency table backs any GT-stage number below**; UG578 itself has none for
the synchronous gearbox / buffer path (its only latency figures are the async gearbox's measurement registers,
p. 126-130, 311-316, and the qualitative Table 3-17 p. 132 / Table 4-35 p. 274: "if low latency is critical,
the TX buffer must be bypassed").

- **D-S6-OPT (option A of `docs/stage6_survey.md`):** 64B/66B on the GTY's synchronous gearbox, TX and RX
  buffers on, one lane per direction at 10.3125 Gb/s over the same QSFP+ DAC (QSFP0 lane 0 <-> QSFP1 lane 0), the
  GT settings of the Stage 3 Aurora cores. `synth/scripts/s6_gen_gt.tcl` generates one GT Wizard core with the
  Aurora preset; its channel attributes equal the Aurora core's except `RXSYNC_MULTILANE` / `TXSYNC_MULTILANE`
  (1 instead of 0; used only by buffer bypass). Options B (raw 64-bit) and C (buffer bypass) stay for later.
- **D-S6-CLK (one clock domain):** both quads run QPLL1 from ONE reference clock, QSFP0's MGTREFCLK1 (K11/K10,
  Si5335 U9); quad 230 takes it as `clk1+1` through the south-bound refclk routing. UG578 ch. 2 "Reference Clock
  Selection and Distribution": a quad can source its reference clock from up to two quads above or below via
  GTSOUTHREFCLK / GTNORTHREFCLK, within one SLR (p. 24); the UltraScale+ limits to one quad apply only from
  16.375 Gb/s (p. 24); at most two quads above / below and five quads per pin pair (p. 34). The wizard validates
  the setting (it rejects mismatched TX/RX sources but accepts `X1Y44 clk1+1 X1Y48 clk1`) and wires the shared
  IBUFDS_GTE4 to both commons' GTREFCLK01 with QPLL1REFCLKSEL = 001. ONE user clock: TXOUTCLK (TXOUTCLKPMA) of the
  master channel X1Y48 through the wizard's single BUFG_GT drives TXUSRCLK = TXUSRCLK2 of every channel (UG578 p. 102:
  TXUSRCLK must come from the TX refclk's oscillator; p. 106 Fig. 3-3: one TXOUTCLK for all lanes) and also
  RXUSRCLK = RXUSRCLK2 of every channel (`LOCATE_RX_USER_CLOCKING = EXAMPLE_DESIGN`, driven by `s6_top`): UG578 p. 321,
  "if the same oscillator drives the reference clock for the transmitter and the receiver, TXOUTCLK can be used to
  drive RXUSRCLK", and Table 4-38 p. 278: a synchronous system on one oscillator needs no clock correction (the
  sentence on p. 321 that phase alignment "must be used" when clock correction is off reads as the bypass case;
  Table 4-38 and the RX buffer, which absorbs a fixed phase, are what this design relies on: a silicon risk, see
  below). That one clock runs both link ends, both s3 sides, the decoder and the probes: **one clock domain for the
  loop**, as the project rule asks. init_clk (100 MHz) clocks only the GT reset controller and the register files
  (D-S3-CLK crossings). Si5335 U12 is unused. No CDC FIFO anywhere. Consequence: the A <-> B ppm drift of Stage 3/4
  (0.2-0.6 ppm) is gone, and a one-way latency can be read directly (D-S6-MEAS).
- **D-S6-FRAME (`rtl/s6/s6_link.sv`, `s6_pkg.sv`):** one 66-bit block per 64-bit lane word. Header 01 = data block
  (payload = the s3 word: tag, seq, det / flip, unchanged formats of `s3_pkg`), 10 = control block (payload
  IDLE = 0x1E00..00, sent whenever no word is ready), 00 / 11 invalid. Scrambler x^58 + x^39 + 1, self-synchronous,
  over every payload the GT takes (data and idle), payload bit 63 first (the gearbox sends MSB first, UG578 p. 115).
  TX sequence counter 0..32 stepping every second cycle, the GT ignoring the block while TXSEQUENCE = 32 (UG578
  p. 117-122 and Table 3-10, 8-byte interface on the 8-byte internal path; the same counter as the Aurora wrapper):
  `s_tready` is low in those 2 cycles of 66. Block sync = UG578 Fig. 4-54 (p. 305-306): lock after 64 valid
  headers in a row, lose it at 16 invalid within 64, a slip (RXGEARBOXSLIP pulse) on every invalid header while
  unlocked, 32 cycles of wait after a slip. Link-up = block lock on both ends (LINK bits 0 and 8, the bits Stage 3's
  `wait 0x024 0x101` already polls), after the wizard's TX / RX reset done. No CRC (Aurora's Stage 3/4 cores had none
  either): bit errors in a data block reach the s3 checks (tag, seq range / overrun / duplicate, flip vs golden);
  errors in idle blocks are counted (`n_idle_bad`, a BER monitor), invalid headers too (`n_sh_bad`). Between a
  misalignment and the loss of lock, misaligned blocks that happen to read 01 are delivered (Verilator: 13 and 2
  garbage words in the glitch / burst tests); the s3 checks see them as tag errors. Accepted, stated.
  Fabric latency: TX `TX_REG = 0`: the user's TX register feeds TXDATA through the scrambler XOR and the idle mux
  only, so the accept edge is the edge at which the GT captures the block; RX `RX_REG = 0`: RXDATA -> descrambler
  -> the user's RX register. Both are parameters (1 adds one register each way) in case timing needs it.
- **D-S6-D5 (later, if d = 3 measures well):** 3 lanes per direction (DW = 192, the Stage 4 word), all lanes on the
  same TXSEQUENCE so every lane's k-th data block belongs to word k; RX deskew by per-lane FIFOs (depth 4, bypass when
  every lane has a block), no marker, no channel bonding; costs the lane skew. `s6_gt3` (X1Y44..46, X1Y48..50,
  master X1Y49). The survey's 2-word single-lane scheme does not fit (120 det + echo + 24-bit seq + tag = 153 bits
  > 128).
- **D-S6-RESET (`rtl/s6/s6_top.sv`):** gtwiz_reset_all held 2^27 init_clk cycles (1.34 s, Stage 3's pma_init hold)
  after configuration, then the wizard's reset controller (QPLL lock, TX, RX after CDR lock; the wizard also delays
  GTPOWERGOOD for the 250 us refclk rule, UG578 p. 34). TX user clock helper reset = not all TXPMARESETDONE (the
  wizard example's rule); the clk-domain logic leaves reset on userclk_tx_active, the link TX on reset_tx_done, the
  link RX on reset_rx_done (asynchronous assert, 3-flop release). RXBUFSTATUS[2] (under/overflow, UG578 RX buffer
  ports) pulses RXBUFRESET (8 cycles, then 4096 cycles hold-off), counted. BOARD[8] re-runs reset_all, BOARD[9]
  reset_rx_datapath, BOARD[2:0] / [6:4] = LOOPBACK of the A / B channel.
- **D-S6-MEAS:** exactly Stage 3/4's loop measurement (`s3_side_a` counter, TX accept edge -> RX register edge, 1-cycle
  histogram, echo then decode, GAP 63 and 7, `sw/analysis/s3_analyze.py`), plus a **one-way probe** (`s6_probe`):
  with both ends on one clock, end A stamps a word with the shared counter at its TX accept edge and end B reads the
  same counter at its RX register edge (and B -> A at the same time): start = TX accept edge, stop = the far end's RX
  register edge, the loop's own convention, so echo = OW(A->B) + OW(B->A) + 2 (+0..2 waiting for B's TX slot) exactly
  (checked in Verilator). Near-end PMA loopback (LOOPBACK = 010 on A) with the probe gives A TX -> A RX without the cable.
  The Stage-3-comparable one-way number is (echo median - 1) / 2; the probe's is direct.
- **D-S6-LAT (expected, model):** fabric adds no register on either side (TX_REG = RX_REG = 0). GT TX (interface,
  sync gearbox, TX buffer with TXFIFO_ADDR_CFG = LOW, PISO) and GT RX (SIPO / CDR, RX elastic buffer at CLK_COR_MIN_LAT
  = 16 / MAX_LAT = 24 bytes, i.e. ~2-3 words, sync gearbox): no AMD number available (above); the survey's second-hand
  AR 69011 figures for a 32-bit path (TX gearbox 6.2-12.4 ns + buffer 7.7-10.9 ns; RX buffer 13.2-17.1 ns + gearbox
  3.1-9.4 ns) give ~30-50 ns of GT, plus 6.4 ns to serialise a 66-bit block and ~5 ns of 1 m twinax: **~45-65 ns one
  way = 7-11 cycles (model)**, round trip ~16-24 cycles, echo median ~18-26 cycles (Aurora: 118). The Verilator model
  uses 640 UI (10 cycles) of wire + GT and gives one-way 12-14 cycles, echo 26-29 (sim, model wire). Silicon decides.
  Pass line: one-way < 156 ns = 25.1 cycles.
- **Risks:** (1) RXUSRCLK from the TX clock with the RX buffer and no clock correction (above): if the RX buffer
  drifts or slips on silicon, RXBUFSTATUS shows it (counted); fallback is RXUSRCLK from RXOUTCLK, i.e. a second
  clock (needs the user's approval: stop and report). (2) Cross-quad refclk: route_design / DRC must accept the
  IBUFDS_GTE4 in quad 231 driving quad 230's common. (3) The DAC: Stage 3 needed a reseat once.
- **Verilator gate (gate 2):** `make -C tb s6_link` (the link alone, NL = 1 and 3, both register settings: an
  independent bit-serial descrambler on the TX stream, lock from random boundaries, random and back-to-back traffic,
  bit errors detected, a one-bit glitch and a 300-block burst lose and regain lock; negative control +NEGSCR must
  FAIL); `make -C tb s6 LC=8` (s6_core + GT models, the Stage 3 cases on all 464,428 golden shots, bounds from the
  probe, corrupted flip caught as exactly 1 mismatch, link counters clean). Logs: `evidence/stage6/verilator/`.
- **d = 3 gate passed 2026-11-03 (silicon):** `evidence/stage6/README.md`. Build s6_lc8_b (WNS +0.252 / WHS +0.006 /
  WPWS +0.442, one-clock check PASS), 4 runs over 3 bring-ups, all bit-exact: one-way probe 22-24 cycles = 136.5-148.9 ns
  (under 156 ns on every word), link round trip 47 cycles = 291.7 ns (Aurora 726 ns), decode loop median 54 cycles = 335.1 ns
  (Aurora 769.6 ns). D-S6-LAT's model was low: near-end PCS loopback alone is 17-19 cycles, i.e. the GTY PCS at the 64-bit
  internal width is ~100 ns of the ~140 ns one way. Next levers (not done, they change the clocking and need the user's
  approval): the 32-bit internal width (TXUSRCLK = 322 MHz from the same TXOUTCLK, fabric still on TXUSRCLK2 = 161 MHz) and
  TX / RX buffer bypass (RX bypass needs RXUSRCLK from the recovered clock: a second clock).
- **d = 5 passed 2026-11-05 (silicon, set 0):** build s6d5_lc3bc_a (3 lanes, WNS +0.037 / WHS +0.013 / WPWS +0.442, one clock),
  3 runs over 2 bring-ups, bit-exact on the 131,072 golden-set vectors: decode loop median 67 cycles = 415.8 ns (Stage 4 Aurora
  850-856 ns), echo 48 (= d = 3: deskew costs nothing measurable). **Sets 1-3 passed 2026-11-06** (one build each, D-S4-SETS;
  identical timing): 9 runs, 27/27 modes bit-exact, decode loop median 66-68 cycles = 409.6-422.0 ns, decode - echo = 19 every run.
- **D-S6-TXBYP (2026-11-06, silicon, d = 3):** TX buffer bypassed on the same single clock (wizard: sync gearbox kept,
  TXOUTCLK = TXPLLREFCLK_DIV1 = the shared refclk, multi-lane auto phase alignment, controller on the loop clock; RX buffer
  stays on, RXUSRCLK stays the loop clock). Build s6bp_lc8_a (WNS +0.231, one-clock check PASS), 3 runs over a load and 3
  re-trains, all bit-exact: one-way probe 18-21 cycles = 111.7-130.3 ns (was 22-24), decode loop median 46-47 cycles =
  285.5-291.7 ns (was 54 = 335.1 ns), PCS near-end loopback 15 (was 17-19). Adopted for d = 3 (`s6_top` TXBYP = 1,
  `S6_TXBYP=1 launch_s6.sh`). Not yet built for d = 5. `evidence/stage6/README.md` §6.
- **D-S6-CHK (2026-11-06, silicon, d = 3):** link check blocks: per lane a CRC-32 (= zlib.crc32 over the data words) and a
  word count, sent as a control block `{0xD2, n, ~crc}` only in a slot with no data word (so no data word waits), checked
  and counted at the receiver (regs 11/12, 27/28), first check after lock ignored. Report only: the s3 checks still own
  the data. Sim: link tests + both loops, RESULT lines unchanged, bit errors and the corrupted word caught. Silicon (build
  s6chk_lc8_a = TX bypass + checks): 9/9 modes bit-exact, loop median 46 = 285.5 ns (= s6bp_lc8_a), 979,858,537 good
  checks per end, 0 bad. Kept in the RTL for every build from now on. `evidence/stage6/README.md` §6b.

## C. Artifact C — X310 waveform classifier (Stage 5, gate passed 2026-11-03)
The X310 was reached on 2026-11-03 (two UBX-160, 10G to build-host, JTAG on build-host; CLAUDE.md lab facts). The
classifier ran live in the X310 image on its own TX->RX loop: bit-exact on silicon (MISR = RTL replay on every
capture), accuracy and detection latency from the X310's timestamps (`evidence/stage5/silicon/README.md`). The
"on-chip counter" of the original plan is the radio time carried with every decision (tau, D-S5-OUT).
Vivado 2021.1 is not used (D-S5-TOOL). Volatile JTAG loads only; never `uhd_image_loader`.

### C.1 Stage 5 as designed (2026-10-29), the parts that need no X310
- **D-S5-TOOL (corrected 2026-10-29 after the proof):** upstream UHD 4.9 (a5d1b2e) pins X310 to
  Vivado 2021.1_AR76780 (committed `top/x300/setupenv.sh`); the "2024.2.1" first seen was an uncommitted
  port in the lab's `ettus/uhd` (10 files, March EME work). User rule: 2024.2 or newer only. So: a clean
  clone at a5d1b2e in `.scratch/uhd` (ettus tree untouched), image builder `-G`, make through
  `.scratch/s5_x300_env_2024_2.sh` (VIVADO_VER/VIVADO_VER_FULL=2024.2, build 5239630), and 3 clone
  edits each forced by a failure (`evidence/stage5/toolchain/uhd_clone_edits.patch`): `grep -i vivado`
  (lower-case banner), `upgrade_ip` for the locked 2021.1 XCIs, translate_off around axi4s_fifo's
  parameter asserts (a real upstream TKEEP mismatch that 2021.1 did not flag; asserts still run in sim).
  Stock X310_XG on build-host: WNS +0.016 / WHS -0.112 ns from the UHD flow (15 hold endpoints, XG_CLK in the
  encrypted 10G PCS/PMA); `phys_opt_design -directive ExploreWithHoldFix` on post_route -> WNS +0.016 /
  WHS +0.003 / WPWS +0.001, all constraints met. Free for the classifier: 110k LUT, 287k FF, 309 BRAM36,
  1,147 DSP (slices 93.7 % occupied by packing). **Open:** `write_bitstream` warns of evaluation cores
  (Vivado 12-1790; likely the 10G PCS/PMA via the System Edition eval licence): the image may stop after
  a time limit (volatile JTAG loads restart it). Host: UHD 4.9 built on desk-pc into
  `.scratch/uhd-install` (`source .scratch/uhd-install/env.sh`; build-host lacks Boost/libusb headers),
  FPGA compat 39.3.
- **D-S5-TAP:** the classifier block sits *between* the device's `radio0` io_port and the stock radio
  block (a `radio` slave port in, a `radio` master port out, all signals passed through as wires),
  plus a `timekeeper` listener. It sees every ADC sample at `radio_clk` (200 MHz, spc = 1), one per
  clock, with `radio_time`; the stock radio still streams the very same samples to the host
  (timestamped), so captures become the silicon golden vectors (replayed in Verilator, decisions
  compared bit for bit). The classifier and its window run in `radio_clk` only (one domain); the only
  crossing is the RFNoC framework's own noc_shell between `radio_clk` and the CHDR bus for the
  decision/event stream and ctrlport, the same structure the stock radio uses (to confirm with the user:
  framework-generated, no hand-written CDC).
- **D-S5-SIG:** signal set (all generated by the X310's own TX at 200 MS/s, looped TX->RX through
  >= 30 dB): noise only, CW, LFM chirp, BPSK (random and Barker-13), within the daughterboard's
  instantaneous bandwidth (WBX, 50 MHz-2.2 GHz, so assumed the 40 MHz WBX: +/- 15 MHz offsets; check with
  `uhd_usrp_probe`). Pre-hardware data is a channel model (**model**): random phase, small CFO, IQ
  imbalance, DC offset, 40 MHz analog filter, SNR range, sc16 quantisation. The captured X310 data then
  replaces it as the test set (and for fine-tuning) once the loop exists.
- **D-S5-WIN:** a sliding window of W complex samples, one decision per sample (II = 1). W from
  {16, 32, 64} (80/160/320 ns) by the accuracy-vs-SNR curve; latency is reported two ways: last window
  sample -> decision (pipeline only) and first window sample -> decision (W + pipeline). On silicon,
  ADC-sample-to-decision = radio_time of the decision minus radio_time of the first captured sample
  carrying the pulse (found offline from the capture), plus the ADC's own pipeline delay from its
  datasheet (**derived**, stated separately).
- **D-S5-OUT:** 200 M decisions/s cannot go to the host; the block emits event records (class change:
  radio_time, class, window start) and a MISR over every decision per capture window, read by ctrlport.
- **D-S5-DATA (2026-10-29):** the pre-hardware data is a channel model (`ref/x310/x310_data.py`, every figure
  from it is **model**), parameters and content hashes in `ref/x310/x310_split_meta.json`. Separability: a
  chirp of rate k inside a W-sample window differs from the best-fitting tone by the residual energy fraction
  r(k, W) (`ref/x310/separability.py`). With the brief's ranges (5-30 MHz over 0.5-5 us, k = 1-60 MHz/us)
  a slow chirp IS a tone in <= 320 ns, so LFM pulses are drawn from those ranges and kept only if
  k >= 10 MHz/us: then every admitted chirp is separable from CW at 10 dB at W = 64 (d^2 = 2 W SNR r >= 72),
  while at W = 32 only k >~ 20 MHz/us is and at W = 16 none is (d^2 <= 2.5). One signal set for all W, so the
  W comparison is on the same physical signals. A BPSK window must contain a phase reversal at least
  max(2, W/8) samples from either edge (a window with no reversal is a CW tone; rejection depends on W by
  nature). Noise-only windows carry a drawn SNR as a tag so every SNR bin holds all four classes. Windows
  straddling a pulse onset are not in the train/val/test sets (the pulse fills the window); the continuous
  stream used by the sliding-window Verilator test has them and its decisions are reported for information.
- **D-S5-BFP:** cheap exact input normalisation: block floating point. s = min(8, 15 - bitlength(OR over the
  2W lanes of (v ^ (v >> 15)) & 0x7fff)), every lane shifted left by s (no overflow by construction); integer
  only, implemented in `rtl/x310/x310_clf_top.sv` and in `ref/x310/x310_data.py:bfp()`: the OR mask is
  registered (BFP_PIPE = 1, +1 cycle), then encode + shift into the da4ml core's input register (all in one
  cycle fails at 5.0 ns on the K7: -0.29 ns, 9 levels, the shift amount fans out to 2,048 muxes). It removes the ~30 dB unknown loop gain before the network, so the
  network's bits are spent on shape. The input quantizer (SAT, TRN, per lane, learned bits) is traced by
  da4ml from a 16-bit input (inputs_kif = (1, 0, 15)), so it is inside the generated core; the core's port is
  the shifted int16 window. Kept only if it helps on validation (ablation `bfp0` runs at one W).
- **D-S5-SEL (stated 2026-10-29, before any training):** validation split only. Per W: the float64
  baseline is the best val accuracy over the float runs of that W. Among that W's HGQ Pareto checkpoints
  (re-scored on val), those with overall val accuracy >= float - 1.0 point are eligible; if any eligible one
  has val accuracy >= 95 % on the windows with SNR >= 10 dB, the pick is the lowest-EBOPs such checkpoint,
  otherwise the lowest-EBOPs eligible one, flagged "SNR >= 10 dB criterion not met". W: the smallest W whose
  pick meets both criteria (if none does, the W whose pick has the best SNR >= 10 dB val accuracy, said so).
  Test accuracy is reported only for the chosen model and its W's float baseline, once, after the choice.
  EBOPs are the training counts in the checkpoint names (as Stages 0, 2, 4). Budget: < ~25k LUT and closes
  at 5.0 ns on xc7k410tffg900-2 with II = 1 (the radio clock), checked by OOC after the choice.
  **Rule 1 result (validation; test once):** W = 64 (W = 16 / 32 reach 79.0 / 92.1 % at SNR >= 10 dB even in
  float), pick `hgq_w64_128_64_32_b5e6_e300` e0219, 61,468 EBOPs, val 84.80 % / 97.73 % (float 85.79 /
  98.23), test 84.57 / 97.70 % (float 85.73 / 98.26). **It does not fit:** da4ml estimates 50.8k LUT for the
  core (EBOPs under-count LUTs here: mostly 1-2-bit weights at 37 % density, one adder per nonzero term,
  0.7-0.85 LUT per EBOP against 0.2 for the dry run's 8-bit 128-16 net). Kept on record:
  `ref/x310/x310_selection_rule1_overbudget.json`, bit-exact in Verilator (`evidence/stage5/verilator_rule1/`),
  OOC `x5r1_*`.
- **D-S5-SEL amended (2026-10-29, Stage 4's D-S4-SEL precedent; stated before sweep h4 and before any test
  look at a budget candidate):** resource bound on da4ml's LUT estimate of the calibrated core,
  `sol.cost <= B = 22,000` (the ~25k budget less ~3k for the hand-written BFP, shift register and argmax:
  the dry OOC measured 15.4k LUT for a 13.1k estimate), computed for every W = 64 checkpoint with val
  accuracy >= 95 % at SNR >= 10 dB by `ref/x310/cost_x310.py` (`ref/x310/x310_cost.json`, validation-derived
  only). Pick: the highest overall val accuracy among those with cost <= B (ties: lower cost). W stays 64 (no
  smaller W can meet the 95 % criterion). The 1-point margin is reported, not required: no checkpoint inside
  B meets it (best before h4: 80.5 % at 22.0k). The OOC of the pick must show <= ~25k LUT total, else B is
  lowered and the rule re-applied.
  **Result (2026-10-30, `evidence/stage5/README.md`):** 34 checkpoints inside B; pick
  `hgq_w64_96_48_24_b2e5_e300` e0271 (128-96-48-24-4), 21,747 EBOPs (21,439 calibrated), da4ml 21,424 LUT;
  val 81.86 % / 96.21 %, test 81.53 % / 96.04 % (**model**). Verilator bit-exact at cutoffs 1.5 / 2 / 2.5 / 3
  (8 x 100,000 test windows + 8 x 65,473 stream windows each, 0 mismatches). OOC on xc7k410tffg900-2 at
  5.0 ns closes at all four: ~22.4k LUT, 0 DSP; last sample -> decision 23 / 18 / 16 / 14 cycles, WNS
  +0.303 / +0.281 / +0.113 / +0.025 ns. Recommended build: cutoff 2 (90 ns, margin for the full image).
- **D-S5-RTL:** `rtl/x310/x310_clf_top.sv` (window in: BFP -> da4ml core -> registered first-max argmax over
  the four logits, layout generated in `rtl/gen/x310_clf_lanes.svh`; logits and class both out, valid
  pipelined) and `rtl/x310/x310_stream.sv` (one sc16 sample per valid clock -> W-sample shift register ->
  x310_clf_top: one decision per sample, II = 1). Window lane order: lane 2k = I_k, 2k + 1 = Q_k, sample 0
  oldest, lane 0 at the LSB.
- **D-S5-BLOCK (2026-10-30, `evidence/stage5/block/README.md`):** RFNoC block `nsclf` (framework-generated
  noc_shell, `nsclf_user` = radio pass-through as wires + `nsclf_core`: channel select, IN_REG, `x310_stream`,
  tau delay line, armed 64-bit MISR over {logits, cls}, K-decision hysteresis events on CHDR ep6 with
  radio_time, ctrlport registers). I = bits [31:16], Q = [15:0] at the radio0 port (from the UHD RTL, confirmed
  by the golden stream matching). L = 19 cycles (95 ns, cutoff 2 + IN_REG) newest-sample capture -> decision (sim);
  host timestamp = tap time + 6 (radio complex-gain pipeline, xsim on UHD's radio_core). **D-S5-CAP:** radio0.out_0
  goes straight to ep0 (the DDC is not bit-transparent), ddc0 serves ch1 only; this changes the stock RF A ch0
  DSP chain (asked of the user). K default 16 (chosen after the sweep; a register).
  Image X310_XG + nsclf closes with an AltSpreadLogic_high placement from the UHD post_synth.dcp
  (WNS +0.016 / WHS +0.003 / WPWS +0.001; the UHD-flow run missed by 12 ps in the stock DB-B ADC capture).

### C.2 Stage 5 on silicon (2026-11-03), decisions forced by the hardware
- **D-S5-DC:** rx_dcoffset **auto** (UHD default), not off as first planned: with it off the ADC's DC
  (about (-128, 136) counts against 22 rms of noise) is a 0 Hz tone and noise reads as CW (99.99 %); with auto,
  99.86 % of noise decisions are noise.
- **D-S5-LEAD:** the UBX TX path adds DC / LO leakage at RX only while it transmits, which rx_dcoffset (tau 5.2 ms)
  removes over ~10 ms. Campaign 1 (no lead-in) shows it; campaign 2 keeps the TX on with 31.5 ms of zeros before the
  signal set, and is the reported result (every window counts; campaign 1's post-hoc "settled" subset is
  superseded and kept for the record).
- **D-S5-EVK:** at K = 16 dense pulses give ~1e6 event packets/s (one CHDR packet per event), which swamps the host
  (sequence errors, overflow, control timeouts). Dense captures set K = 60000 (no events; raw decisions, MISR and
  accuracy unaffected); events are verified on sparse captures (gaps 50-200 us, K = 16: 975 / 975 equal the replay).
  Batching several records per packet would lift the limit (not done). The tools always connect ep6: an unconnected
  SEP keeps an earlier session's stream state. **Resolved 2026-11-03 by the event revision** (VERSION 2.0,
  `evidence/stage5/evt/README.md`): events off at reset (CTRL bit 2), up to 16 records per packet; dense pulses at
  K = 16 now deliver every record (~1e6 records/s), and back-to-back sessions no longer fail at init (0 of 16).
- **D-S5-LAB:** labels from the regenerated TX schedule shifted by the measured loop delay (D = 134 samples, the
  maximum of the fitted response), a 17 / 2 sample guard from the response's 99.95 % energy span, and the D-S5-DATA
  rules (pure windows, BPSK reversal margin W/8). Accuracy is class-balanced (the model's test set is 25 % per class)
  and per class; the silicon population is not identical to the model's (rectangular BPSK only, SNR per pulse).
- **D-S5-CH (2026-11-03, after the gate): measured channel, model v2.** BPSK was 65.5 % on silicon (78.2 % model).
  Root cause (`evidence/stage5/bpsk/README.md`): D-S5-DATA's 40 MHz Butterworth analog model; the X310 / UBX-160 path
  is flat to about +/-80 MHz with white noise, and a simulation through the measured loop response plus real noise
  reproduces the silicon numbers class by class (BPSK 65.2 vs 65.1 %). Fix: `ref/x310/channel_x310.py` measures h
  (31 taps) and the noise PSD from the committed captures; `x310_data.py` channel 'meas' (default) uses them (signals
  through h with a fractional delay U(0, 1) per window, noise through the PSD's FIR, level U(-54, -12) dBFS). W = 64
  only (the block is built for it); same recipe and rule (D-S5-SEL amended, cost <= 22000 LUT est.); runs in
  `ref/runs/x310_meas/` (trained on build-host without the container: train-host unreachable, `sw/snoke_sweep.sh`);
  files suffixed `_meas`. The export replaces the core in `rtl/gen/` and the golden vectors in `ref/golden/`: v1
  (the gate) stays reproducible at commit 2eba869. Seeds 0-7 calibrated the channel; v2 is tested on TX seeds 8-15.

## Stage status

| Stage | Content | Status |
|---|---|---|
| 0 | flow, golden vectors, Verilator bit-exact, OOC sweep, MEASUREMENT.md, PLAN.md | **gate passed 2026-10-20** (`evidence/stage0/README.md`) |
| 1 | ZCU102 silicon, pin-to-pin | **gate passed 2026-10-20** (`evidence/stage1/README.md`): L_pp median 47.6 ns at 300 MHz, bit-exact on silicon at 200/300/500 MHz |
| 2 | decoder in simulation | **gate passed 2026-10-20** (`evidence/stage2/README.md`) |
| 3 | d = 3 loop on BCU-1525 | **gate passed 2026-10-23** (`evidence/stage3/README.md`): decode 37.2 ns, loop median 769.6 ns (silicon, desk card) |
| 4 | d = 5, README, reproduce.sh | **gate passed 2026-10-29** (`evidence/stage4/README.md`, `reproduce4.log`) |
| 5 | X310 | pre-hardware flow done 2026-10-30 (§C.1, `evidence/stage5/README.md`: W = 64, 96.0 % at SNR >= 10 dB (model), bit-exact in Verilator, 22.4k LUT, closes 5.0 ns on the K7); RFNoC block + X310_XG image done 2026-10-30 (D-S5-BLOCK, `evidence/stage5/block/`); **gate passed 2026-11-03** (§C.2, `evidence/stage5/silicon/README.md`: bit-exact on silicon over 84 M decisions; 81.8 % / 97.4 % at SNR >= 10 dB on the X310's TX->RX loop; onset -> valid decision median 150-225 ns at SNR >= 10 dB); **v2 2026-11-03** (D-S5-CH, `evidence/stage5/v2/README.md`: measured-channel model, BPSK 65.5 -> 88.2 %, 91.5 % / 98.4 % at SNR >= 10 dB on fresh TX seeds, bit-exact on silicon; L 22 cycles) |
| 6 | thin GTY link (stretch) | **d = 3 gate passed 2026-11-03** (§B.5, `evidence/stage6/README.md`): one-way 136.5-148.9 ns (silicon probe; < 156 ns), loop 335.1 ns median (was 769.6 ns); **d = 5 passed 2026-11-05** (vector set 0, 9/9 runs bit-exact): decode loop 415.8 ns median (Aurora 850-856 ns); **sets 1-3 passed 2026-11-06** (27/27 modes bit-exact, medians 409.6-422.0 ns); **TX buffer bypass at d = 3 2026-11-06**: loop 285.5-291.7 ns; **link check blocks (CRC-32) 2026-11-06**: 0 bad in 9.8e8, loop unchanged |
