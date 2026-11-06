# Stage 1 gate — Artifact A on silicon (ZCU102 "zcu102", 2026-10-20)

Device: **xczu9eg-ffvb1156-2-i, ES2 silicon**, timed with the production -2-i
speed file (Vivado 2024.2). Network: the Stage 0 HGQ2 JSC 16-64-32-32-5
(76.74 % test accuracy), da4ml RTL unchanged from `rtl/gen/`. Method:
`docs/MEASUREMENT.md` §2a; design: `docs/ARCHITECTURE.md`, `docs/PLAN.md` §A.3.

## Headline (pin-to-pin, asynchronous-source distribution)

| F_net | cutoff | OOC prediction (model, Stage 0, core only) | **L_pp median** (min … max) | N_core (silicon) |
|---|---|---|---|---|
| 200 MHz | 5 | 7 cyc = 35.0 ns | **55.2 ns** (52.7 … 57.7) | 10 |
| **300 MHz** | 3 | 10 cyc = 33.3 ns | **47.6 ns** (45.9 … 49.3) | 13 |
| 500 MHz | 1 | 27 cyc = 54.0 ns | **65.7 ns** (64.7 … 66.7) | 31 |

- **Start event:** rising edge of IN_VALID at the package pad of pin B (A20,
  PMOD0_0). **Stop event:** rising edge of DEC_VALID at the package pad of
  pin C (D20, PMOD1_0).
- **Instrument:** on-chip free-running counters on clk_net and clk_ps plus an
  MMCM fine-phase sweep over one full period (one point every 14.9 / 14.9 /
  11.9 ps at 200 / 300 / 500 MHz), 4 trials per phase step; no oscilloscope
  (none available).
- **Labels:** cycle counts and phase-step positions are **silicon**; the two
  fabric anchor delays d_H / d_G (bracketed by their Vivado corners and fixed
  by their silicon-measured sum) and t_out_C − t_out_B (−0.04 / −0.02 /
  +0.10 ns) are **model**; the ns figures are **derived**. The bracket from the
  anchor corners is ±0.35 ns (table below). The OOC prediction is **model**
  (OOC P&R, register to register, no I/O).
- **Excluded:** the 150-bit feature vector does not cross pins (staged
  on-chip over AXI, stable for microseconds before the strobe); board traces
  beyond the pads; PS, AXI and Linux.
- **Included:** pin B output-to-input pad loop (the strobe's own OBUF and the
  readback INBUF, ~2.6–2.8 ns measured as d_B), the wait to the capturing
  edge (uniform over one period), the readback flop, one synchroniser, the
  network input register, the network, argmax, the DEC_VALID flop and the pin C
  output path. L_pp − (LAT_NET × T) is the harness + pad overhead: about
  14 ns at 300 MHz.
- **Clock:** one network domain per bitstream: USER_SI570 300 MHz → MMCM →
  F_net, measured on silicon at 199.999 / 300.000 / 499.999 MHz.

Wall-clock latency is lowest at 300 MHz, as Stage 0 predicted for the core
(33.3 ns OOC); 500 MHz needs 27 network cycles and loses.

## Every sweep

d_H + d_G is measured on silicon (model-free); "corner frac" is where it
sits between Vivado's fast and slow corners. Brackets are L_pp with d_H at
its lowest / highest value consistent with the corners and the measured sum.

| F_net | build | sweep | N_net (OOC prediction) | N_core | d_H+d_G silicon (corner frac) | d_B est [lo..hi] | L_pp min | L_pp median | L_pp max |
|---|---|---|---|---|---|---|---|---|---|
| 300 MHz | `s1_p300_lc3_f1` | `timed_p300.log` | 10 cyc = 33.3 ns | 13 | 1.560 ns (0.46) | 2.650 [2.326..3.024] | 45.95 [45.63..46.32] | 47.61 [47.28..47.98] | 49.27 [48.94..49.64] |
| 300 MHz | `s1_p300_lc3_f1` | `timed_p300r_a.log` | 10 cyc = 33.3 ns | 13 | 1.560 ns (0.46) | 2.650 [2.326..3.024] | 45.95 [45.63..46.32] | 47.61 [47.28..47.98] | 49.27 [48.94..49.64] |
| 300 MHz | `s1_p300_lc3_f1` | `timed_p300r_b.log` | 10 cyc = 33.3 ns | 13 | 1.558 ns (0.46) | 2.649 [2.326..3.022] | 45.95 [45.63..46.32] | 47.61 [47.28..47.98] | 49.27 [48.94..49.64] |
| 200 MHz | `s1_p200_lc5_f1` | `timed_p200_a.log` | 7 cyc = 35.0 ns | 10 | 1.763 ns (0.47) | 2.761 [2.415..3.155] | 52.75 [52.40..53.14] | 55.24 [54.90..55.64] | 57.73 [57.39..58.13] |
| 200 MHz | `s1_p200_lc5_f1` | `timed_p200_b.log` | 7 cyc = 35.0 ns | 10 | 1.771 ns (0.47) | 2.756 [2.407..3.147] | 52.73 [52.38..53.12] | 55.23 [54.88..55.62] | 57.73 [57.38..58.12] |
| 500 MHz | `s1_p500_lc1_a2_f2` | `timed_p500_a.log` | 27 cyc = 54.0 ns | 31 | 1.393 ns (0.50) | 2.635 [2.326..2.949] | 64.74 [64.43..65.05] | 65.74 [65.43..66.05] | 66.74 [66.43..67.05] |
| 500 MHz | `s1_p500_lc1_a2_f2` | `timed_p500_b.log` | 27 cyc = 54.0 ns | 31 | 1.394 ns (0.50) | 2.633 [2.324..2.947] | 64.74 [64.43..65.05] | 65.73 [65.42..66.05] | 66.73 [66.42..67.04] |

`timed_p300.log` is the first 300 MHz sweep; `timed_p300r_*` follow a
reprogram of the same bitstream (1,118 of 1,120 trials give identical counter
differences; the rest sit on a transition). Every repeat agrees within 20 ps.

## Bit-exactness on silicon (charter rule (c))

For each bitstream, all 166,000 golden test vectors were streamed at II = 1 in 4 orders (seeds 0–3,
the testbench's xorshift32 permutation), each run twice without reprogramming:
logits (80 bits) and class compared with `ref/golden/jsc_golden_{out,argmax}.hex`.

| Bitstream | runs | logit mismatches | class mismatches | log |
|---|---|---|---|---|
| 300 MHz `s1_p300_lc3_f1` | 8 + 8 after reprogram | 0 | 0 | `silicon/stream_p300.log`, `silicon/stream_p300r.log` |
| 200 MHz `s1_p200_lc5_f1` | 8 | 0 | 0 | `silicon/stream_p200.log` |
| 500 MHz `s1_p500_lc1_a2_f2` | 8 | 0 | 0 | `silicon/stream_p500.log` |

Every timed trial (1,120–1,680 per sweep) also checked logits and class: 0
mismatches, 0 missing captures. **Negative controls** on silicon
(`silicon/negative_*.log`): a flipped expected-logit bit (vector 421) and a
flipped input bit (vector 777) each give exactly 1 mismatch and exit 1, at
every clock. STREAM_CYC offsets 16 / 13 / 34 and N_core 13 / 10 / 31 equal
the simulation values.

## Simulation before hardware (charter rule (b))

- `verilator/harness_lc{3_div1_arg1,5_div1_arg1,1_div2_arg2}_seed{0..3}_run{1,2}.log`:
  24 runs on the final RTL (`rtl_sha256` in each header), 166,000 vectors
  each, 0 logit / 0 class mismatches; each with a full phase sweep whose
  solved d_B, d_C and every trial's L_pp match the testbench's injected pad
  delays within half a phase step (`sim_solve/`).
- `verilator/harness_anchor_*`: non-zero anchors (d_H 0.7 ns, d_G 1.1 ns)
  injected; the solver recovers every trial's L_pp within 2.5 ps, both with
  the true anchors and with the corner bracket.
- `verilator/negative_control_{logit,class}.log`: the sim checker catches a
  single corrupted logit bit and a single corrupted class.

## Timing (fresh reports, timestamps checked; `builds/<build>/`)

| Build | F_net / clk_axi | WNS | WHS | WPWS | LUT | FF | BRAM tiles | DSP |
|---|---|---|---|---|---|---|---|---|
| `s1_p200_lc5_f1` | 200 / 200 | +0.069 | +0.014 | +0.500 | 18,465 | 5,086 | 117 | 0 |
| `s1_p300_lc3_f1` | 300 / 300 | +0.011 | +0.011 | +0.166 | 18,255 | 8,418 | 121.5 | 0 |
| `s1_p500_lc1_a2_f2` | 500 / 250 | +0.003 | +0.007 | 0.000 | 18,920 | 22,263 | 117 | 0 |

(Whole design: harness, vector/result BRAM, SmartConnect, PS wrapper.) The
first 500 MHz build (`superseded_f1_summary.json`, WNS −0.111) failed on the
quasi-static T_VEC → vector-BRAM enable path; a 2-cycle multicycle on that
CSR (`stage1_build.tcl`, AXI_DIV = 2 only) closed it. `builds/*/artifacts.sha256`
holds the .bit / .bin / .dcp hashes and timestamps; each .bin's hash is also in
every silicon log header. `iob_check.rpt`: one sampling flop per input pad,
pad flops next to the pads, anchors in fabric. `anchors.rpt`: exactly two
timed clk_ps ↔ clk_net crossings.

**Decision D-S1-IOB** (`builds/decision_D-S1-IOB/`): with the pad flops packed
into the HD IOLOGIC, every IOB flop fails the pulse-width check (Min Period
8.000 ns, slack −4.667 ns at 300 MHz). Pad flops sit in slices beside the pads
instead, with full sign-off.

## Model check of the pads
Vivado's pad paths for pin B (`summary.json` pad_paths: clock-to-pad
1.55–3.16 ns, pad-to-flop 1.15–1.95 ns, fast–slow) bracket the measured
d_B ≈ 2.65 ns near their fast end (the slow corner is worst-case
voltage and temperature; zcu102's actual conditions were not measured). The measured anchor sums sit at 0.46–0.50 of the corner
span, which is consistent across three independent placements.

## Reproduce
```
ssh build-host 'cd <proj> && make -C tb harness LC=3 AXI_DIV=1 ARG_LAT=1 PS_STEPS=224 T_NS=3.333333'
ssh build-host 'cd <proj> && synth/scripts/launch_stage1.sh s1_p300_lc3_f1 300 3 1'   # then stage1_bitstream.tcl
uv run python sw/zcu102/make_vectors.py && sw/zcu102/run_stage1.sh s1_p300_lc3_f1 <tag>
python3 sw/analysis/solve_stage1.py s1_p300_lc3_f1:<tag>
```
