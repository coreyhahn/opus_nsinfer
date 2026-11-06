# Stage 4 gate: d = 5 NN decoder loop on BCU-1525 silicon over GTY, II = 1

**Verdict: PASS (2026-10-29).**
- **Hardware:** a d = 5 surface-code NN decoder (120 detectors, 120-192-96-96-1 HGQ2/da4ml MLP, 933,465 EBOPs) runs on a BCU-1525 at the 161.13 MHz GTY user clock with initiation interval 1. Syndromes arrive over three bonded 10.3125 Gb/s Aurora 64B/66B lanes through a QSFP+ DAC cable, and corrections leave over the same link.
- **Decisions:** bit-identical to the Keras model on silicon for 4 vector sets of 131,072 held-out detection vectors (524,288 in all). Each set was run at least twice without reprogramming, in every mode: 27 runs, 27 PASS.
- **Latency (silicon):** decode **19 cycles = 117.9 ns**; loop median **844–856 ns**; every shot of every run returns in under 1 µs (worst 943.3 ns). The Aurora round trip, measured separately in echo mode, is 726–732 ns of that.

Labels as CLAUDE.md requires: **silicon** = read from on-chip counters on the board, **derived** = computed from silicon numbers, **sim** = Verilator, **model** = Vivado timing / OOC P&R.

## 1. What was built, and why this network

The CHARTER asks for d = 5 at II = 1. The rule that picks the network is D-S4-SEL in `docs/PLAN.md` (amended twice):

1. **First pick: does not fit.** The best-accuracy rule chose a 256x3 core at 3.58M EBOPs (test NN/PM geomean 1.033). It is bit-exact in Verilator, but at about 500k LUT it does not route on the VU9P at 6.206 ns (`ooc/q5_*`). Its record is `ref/qec/qec_d5_selection_q5_unroutable.json`.
2. **Why the large cores fail.** Smaller cores (1.53M–1.92M EBOPs; 256x3, 128x4, 192-96-96) route but miss 6.206 ns by 3.5–11.7 ns at every pipeline depth, or do not route. The failing paths are 2–4 LUTs with about 95 % route delay. Each layer's output register broadcasts, with fanout 80–190, into the all-to-all next layer (`ooc/q5p_vu9p_lc3_f161_timing.txt`).
   - None of the following helped; each made timing worse or the design unroutable (`ooc/q5p_unrouted.txt`): synthesis `max_fanout`, forced placement-aware replication, an SLR1 pblock, aggressive directives.
3. **What works: broadcast registers on a smaller net.** A pure pipeline register goes before every stage whose output is more than 1.3× its input (`synth/scripts/add_bcast.py`, `export_qec_d5.py --bcast-ratio 1.3`).
   - This adds 4 cycles, carries no logic, keeps II = 1 and leaves the arithmetic untouched.
   - It is bit-exact in Verilator against the golden set.
   - The placer can then put the broadcast next to its consumers.
4. **The bound and the pick.** The probe at 1,018,201 EBOPs closes OOC at WNS +0.035 ns, so B = 1,018,201. The rule then picks the best validation geomean with EBOPs ≤ B over 175 Pareto checkpoints, 30 of them inside B. The pick is `hgq_d5nr_192_96_96_to1e8` e0023 (val 1.265, test 1.257; `ref/qec/qec_d5_selection.json`).
   - Disclosure: each probe export prints that core's test LER. Those numbers were not used for B or for the choice.

## 2. Logical error rate (sim; on hardware, derived)

Stim `rotated_memory_z`, d = 5, 5 rounds, uniform circuit-level noise. Each p has 5×10^6 held-out test shots, and PyMatching decodes the same shots. The NN is the exported, calibrated model (`ref/golden/qec_d5_golden.json`). Silicon reproduces its decision on every vector tried (§3) and Verilator reproduces it on every distinct test vector (§5). The hardware LER on these shots is therefore this table.

| p | NN LER | PyMatching LER | **NN / PM, built core (933k EBOPs)** | NN / PM, unroutable 3.58M core (not built) |
|---|---|---|---|---|
| 0.1 % | 1.286e-4 | 1.304e-4 | **0.986** | 0.833 |
| 0.2 % | 1.198e-3 | 1.047e-3 | **1.144** | 0.896 |
| 0.3 % | 4.247e-3 | 3.317e-3 | **1.280** | 0.976 |
| 0.5 % | 2.036e-2 | 1.402e-2 | **1.452** | 1.128 |
| 0.7 % | 5.290e-2 | 3.482e-2 | **1.519** | 1.209 |
| 1.0 % | 1.277e-1 | 8.386e-2 | **1.523** | 1.269 |

The right column is the accuracy given up to fit 161 MHz at II = 1 on this part. The 3.58M figures come from the same export run over the same shots, at commit 412dd0a. At d = 5 the NN at II = 1 matches PyMatching at p = 0.1 % and is up to 1.5× worse at 1 %. At d = 3 it was 0.85–1.00 (Stage 2).

## 3. Bit-exactness on silicon

- **Setup:** the desk BCU-1525 (#2, `xcvu9p-fsgd2104-2L-e`, JTAG `DESK-BCU-JTAG`), under its own lock (`sw/bcu/desk.sh`). Loads are volatile JTAG only; nothing was written to flash.
- **Cable:** QSFP+ 40G DAC from QSFP0 to QSFP1, 3 of its 4 lanes per direction. LINK reads `0x7F0C3333`: all six lane_up bits, both channel_up bits, init done.
- **Design:** `rtl/s3/s3_top.sv` at DW = 192. Side A is the shot player, timestamp counter and checker; side B is the decoder or echo. Registers are read over JTAG-to-AXI.
- **Run order:** `sw/bcu/s4_measure.cmd` runs echo GAP 63, decode GAP 63 and decode GAP 7.
- **Checks:** `sw/analysis/s3_analyze.py --d 5` applies all of these per run:
  - n_sent = n_good = 131,072;
  - mismatch counter 0, and every protocol and FIFO error counter 0;
  - histogram total = n_good;
  - the return-order MISR equals the Verilator loop's for that shot ROM;
  - 8,192 stored decisions read back (shots 0–4095 and 126976–131071) equal that set's expected (Keras) decisions (`--dec`);
  - side B's decode-path count is constant at DEC_LAT + 1.

- **Vector sets** (CHARTER rule (c)): set 0 is the committed golden set (131,072 vectors drawn per p, zero vector first). Sets 1–3 are seeded draws of 131,072 vectors each from the full distinct test set (`tb/s4_vector_sets.py`, sha256 in `ref/golden/qec_d5_sets.json`). Each set is its own build, differing only in the shot ROM, and its own volatile load.
  - Set 0 was run three times on one load; sets 1–3 twice each on their load. No set was reprogrammed between its runs.
  - Each run has 3 modes: **27 runs, 27 PASS** over 524,288 vectors (`silicon/*_cable_run*.json`, `silicon/summary.json` from `sw/analysis/s4_summary.py`).
- **Signatures:** each set's decode MISR is distinct and equals that set's Verilator loop signature. The echo MISR is `ebffc69c` for every set (sim and silicon). The MISR steps on (seq, flip), and echo returns flip = 0, so it sees only the sequence numbers.
- **Error rate on hardware (derived):** every silicon decision tried equals the Keras decision, and Verilator matches on all 17.5M distinct test vectors, so the §2 table is the hardware LER.

## 4. Latency

Definitions (as Stage 3, `evidence/stage3/README.md` §3):
- **Loop (silicon):**
  - start: the clk_a edge at which side A's TX beat is accepted by Aurora A (tvalid & tready);
  - stop: the clk_a edge at which the matching response word is registered from Aurora A's RX;
  - instrument: side A's cycle counter, histogrammed per shot at 1-cycle resolution, with clk_a's period measured against the 100 MHz init clock (FREQ_A = 27,033,600 per 2^24, **6.20606 ns**);
  - covers both directions of Aurora, GTY and the cable, side B and the decoder;
  - excludes syndrome generation and the pins of a real qubit controller.
- **Echo:** the same path with the decoder replaced by side B's 1-cycle echo register.
- **Decode alone (silicon):** side B's own counter from the RX register to the TX FIFO write. It is constant on every shot and equals the decoder latency + 1.
  - The decoder latency (DEC_LAT) is 19 cycles: the core input register, 17 pipeline edges ending at the logit register (13 da4ml stages and 4 broadcast registers), and the flip register.

Per run, median cycles = ns (min … max) over 131,072 shots. All figures are **silicon**:

| Set | Run | Echo loop, GAP 63 | Decode loop, GAP 63 | Decode loop, GAP 7 | Decode − echo (means) | Decode signature = sim |
|---|---|---|---|---|---|---|
| 0 | 1 | 118 cyc = 732.3 ns (113 … 125) | 137 cyc = 850.2 ns (132 … 152) | 136 cyc = 844.0 ns (132 … 148) | 19.08 | `61783930` |
| 0 | 2 | 118 cyc = 732.3 ns (113 … 124) | 137 cyc = 850.2 ns (132 … 147) | 136 cyc = 844.0 ns (132 … 148) | 19.04 | `61783930` |
| 0 | 3 | 118 cyc = 732.3 ns (113 … 124) | 137 cyc = 850.2 ns (132 … 150) | 137 cyc = 850.2 ns (132 … 147) | 19.05 | `61783930` |
| 1 | 1 | 118 cyc = 732.3 ns (111 … 124) | 137 cyc = 850.2 ns (132 … 143) | 137 cyc = 850.2 ns (134 … 146) | 18.98 | `149e1a8e` |
| 1 | 2 | 118 cyc = 732.3 ns (113 … 124) | 137 cyc = 850.2 ns (130 … 143) | 136 cyc = 844.0 ns (131 … 145) | 19.04 | `149e1a8e` |
| 2 | 1 | 119 cyc = 738.5 ns (114 … 125) | 138 cyc = 856.4 ns (131 … 144) | 137 cyc = 850.2 ns (131 … 150) | 18.98 | `bbf1d963` |
| 2 | 2 | 119 cyc = 738.5 ns (112 … 125) | 138 cyc = 856.4 ns (131 … 148) | 138 cyc = 856.4 ns (131 … 149) | 19.18 | `bbf1d963` |
| 3 | 1 | 119 cyc = 738.5 ns (114 … 125) | 138 cyc = 856.4 ns (133 … 144) | 138 cyc = 856.4 ns (133 … 150) | 19.01 | `56434086` |
| 3 | 2 | 119 cyc = 738.5 ns (114 … 126) | 138 cyc = 856.4 ns (133 … 147) | 138 cyc = 856.4 ns (133 … 151) | 19.03 | `56434086` |

- **Decode alone (silicon):** side B's decode-path count is **20 on every shot of every run**, which is DEC_LAT + 1. The decoder is therefore **19 cycles = 117.9 ns**.
- **Spread:** the worst shot of all 27 runs is 152 cycles = **943.3 ns**, so every shot returns in under 1 µs. clk_a is 6.20606 ns, and clk_b is +0.37 … +0.63 ppm from it.
- **Load-to-load shift:** loads differ by one cycle (118 vs 119 echo median). That comes from the per-bring-up lane alignment; decode − echo does not move.

How to read it:
- **The decoder is isolated.** Decode − echo means are 18.9–19.2 cycles, against a decoder depth of 19. The echo loop median is 118–119 cycles, against 118 for Stage 3's 1-lane link. Bonding three lanes costs at most one cycle.
- **The link dominates.** The Aurora round trip is 117–118 cycles = 726–732 ns of the loop (the echo median minus the 1-cycle echo register). The decoder adds 117.9 ns.
- **No queueing at II = 1.** GAP 7 (one shot every 8 cycles) gives the same median as GAP 63.
- **The cost of fit.** Without the broadcast registers the decoder would be 4 cycles (24.8 ns) shorter, but it does not close at 161 MHz.

## 5. Simulation evidence and builds

- **Core, golden set** (`verilator/qec_d5_lc3bc_seed*_run*.log`): 131,072 vectors × 4 seeds × 2 runs; 0 decision and 0 flip mismatches; latency 18 = 17 core stages + flip register.
- **Core, full test set** (`verilator/qec_d5_lc3bc_full_seed{0,1}.log`): all 17,517,776 distinct test vectors, plus zero, × 2 seeds; 0 mismatches.
- **Loop** (`verilator/s3d5_loop_lc3bc{,_set1,_set2,_set3}_n131072_{spec,aslow}.log`): the real side A, side B and decoder RTL with a behavioural link and plesiochronous clocks in both orientations, on each set's shot ROM.
  - fails = 0; decode − echo = DEC_LAT = 19 exactly.
  - Negative control: one corrupted flip is caught as exactly 1 mismatch.
- **OOC probes** (`ooc/`, model: OOC P&R on xcvu9p-2L at 6.206 ns, register to register, ports excluded). The chosen core closes at WNS +0.035 ns with 148k LUT. The stage-0,3 broadcast variant closes under four directive sets (+0.008 … +0.280 ns).
- **Builds** (`build/`, Vivado 2024.2, full implementation with the 3-lane Aurora cores):
  - all five directives close: WNS +0.002 … +0.043 ns, WHS +0.010 ns, WPWS +0.448 ns;
  - Default uses 154,880 LUT (13.1 %), 89,810 FF, 502 BRAM tiles (the 131,072-shot ROM) and 0 DSP;
  - every bitstream went through `s3_bitstream.tcl`. It refuses without signed-off timing and two passing loop sims on the build's exact shot ROM (sha256).

| Build | Vector set | WNS | WHS | WPWS | Shot ROM sha256 | Bitstream sha256 |
|---|---|---|---|---|---|---|
| s4b_lc3bc_Default | 0 | +0.043 | +0.010 | +0.448 | `d11d736d…` | `31a760c4…` |
| s4b_lc3bc_set1 | 1 | +0.043 | +0.010 | +0.448 | `3e114182…` | `984e185a…` |
| s4b_lc3bc_set2 | 2 | +0.043 | +0.010 | +0.448 | `02ad625d…` | `1b36403b…` |
| s4b_lc3bc_set3 | 3 | +0.043 | +0.010 | +0.448 | `b66b9698…` | `5a4e1cfc…` |

The full hashes are in `build/bitstream_sha256.txt` and `build/*_mem.txt`.

## 6. Reproduce

```
ssh train-host 'cd <proj> && container/run.sh "python ref/qec/export_qec_d5.py --model ref/runs/qec/chosen_d5.keras --cutoffs 3 --bcast-ratio 1.3"'
ssh build-host 'cd <proj> && make -C tb qec5 LC=3bc && make -C tb qec5_full LC=3bc && make -C tb s3d5 LC=3bc'
python3 tb/s4_vector_sets.py && ssh build-host 'cd <proj> && make -C tb s3d5 LC=3bc D5_SET=1'          # sets 1..3
ssh build-host 'cd <proj> && D5_N=131072 [D5_SET=k] synth/scripts/launch_s3.sh <name> 3bc Default 5'    # then s3_bitstream.tcl in synth/out_<name>
ssh build-host 'cd <proj> && sw/bcu/desk.sh program synth/out_<name>/s3_top.bit synth/out_<name>/s3_top.ltx'
ssh build-host 'cd <proj> && sw/bcu/desk.sh run sw/bcu/s4_measure.cmd' > evidence/stage4/silicon/<run>.log
python3 sw/analysis/s3_analyze.py --d 5 --lc 3bc evidence/stage4/silicon/<run>.log --json <run>.json
```
`sw/reproduce.sh 4` runs the non-silicon steps and re-analyses the committed silicon logs.

**Reproduction run (2026-10-29, `evidence/stage4/reproduce4.log`, exit 0, 2 h 35 min).** `sw/reproduce.sh 4`
regenerated `qec_d5_lc3` and `qec_d5_lc3bc` from `ref/golden/qec_d5_hgq.keras` on train-host, byte-identical
to `rtl/gen/` (metadata.json included); the core gate (4 seeds x 2 runs, 0 mismatches) and the set-0 loop sim
(both clock orientations) gave RESULT lines identical to the committed `evidence/stage4/verilator/` logs,
including the 8-beat shortfall at gap 0 in the `spec` orientation (clk_a faster than clk_b: the GAP 0 FIFO
overflow noted in CLAUDE.md; never used on silicon, which runs gap 7 and 63); `tb/s4_vector_sets.py`
reproduced `ref/golden/qec_d5_sets.json`; all 27 committed silicon runs re-analysed PASS.
