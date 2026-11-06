# Stage 3 gate: d = 3 NN decoder loop on BCU-1525 silicon over GTY

**Verdict: PASS (2026-10-23).**
- **Hardware:** the Stage 2 decoder (24-128-64-32-1 MLP, 30,258 EBOPs) runs on a BCU-1525. Syndromes arrive over a 10.3125 Gb/s Aurora 64B/66B GTY link through a QSFP+ DAC cable, and corrections leave over it.
- **Decisions:** bit-identical to the Keras model on all 464,428 held-out detection vectors, in 10 decode runs over 3 builds.
- **Latency:** decode latency and loop latency are measured separately, with the link's share isolated by an echo mode.

Labels as CLAUDE.md requires: **silicon** = read from on-chip counters on the board, **derived** = computed from silicon numbers, **sim** = Verilator.

## 1. Setup

- **Card:** the desk BCU-1525 (#2), `xcvu9p-fsgd2104-2L-e`, bench PSU, USB JTAG on build-host (serial `DESK-BCU-JTAG`). The shared PCIe card was not touched.
- **Access:** under its own lock, `.opus_nsinfer_desk_bcu.lock` (`sw/bcu/desk.sh`). Volatile JTAG loads only; nothing was written to flash.
- **Cable:** a QSFP+ 40G DAC from QSFP0 to QSFP1 on the same card. One lane is used per direction.
- **Design:** `rtl/s3/s3_top.sv`. Side A (QSFP0, Aurora core A, user clock A) is a shot player, timestamp counter and checker. Side B (QSFP1, core B, user clock B) runs the decoder at its user clock, or echoes. Registers are read over JTAG-to-AXI.
- **Clocks:** both user clocks are 161.1328125 MHz from separate Si5335 outputs. The silicon frequency counters (`s3_freq`, 2^24 cycles of the 100 MHz init clock) read:
  - A: 27,033,600, which gives a period of **6.20606 ns**;
  - B: A + 0.22 … 0.30 ppm.
- **Shots:** the 464,428 golden vectors (`ref/golden/qec_d3_golden_in.hex`) with their expected decisions, in BRAM, played in order. Each run sends every vector once.

## 2. Bit-exactness on silicon

For each run, all of the following hold:
- n_sent = n_good = 464,428;
- the decision mismatch counter is 0 (every returned flip is compared on chip with the golden decision);
- all protocol and FIFO error counters are 0;
- the return-order MISR equals the Verilator loop's golden-order signature: decode `5e8e5270`, echo `5f09efeb`;
- 8,192 stored decisions read back by JTAG (shots 0–4095 and 460332–464427) equal `qec_d3_golden_dec.hex`.

The runs:
- lc8 build: 3 runs, two on one load and one after a fresh reprogram;
- lc12 and lc5 builds: 1 run each.

Each run has echo GAP 63, decode GAP 63 and decode GAP 7: **15 runs, 15 PASS** (`silicon/*_cable_run*.json`, `silicon/summary.json`, `sw/analysis/s3_analyze.py`).

**Error rate on hardware (derived).** Every silicon decision equals the Keras decision, so the hardware logical error rate on the 10^7 held-out shots per p is exactly the Stage 2 table (`ref/golden/qec_d3_golden.json`):

| p | NN / PyMatching |
|---|---|
| 0.1 % | 0.854 |
| 1 % | 1.000 |

## 3. Latency

Definitions:
- **Loop (silicon):**
  - start: the clk_a edge at which side A's TX beat is accepted by Aurora A (tvalid & tready);
  - stop: the clk_a edge at which the matching response word is registered from Aurora A's RX;
  - instrument: side A's 32-bit cycle counter, histogrammed per shot at 1-cycle resolution;
  - covers: Aurora A TX, GTY A, the DAC cable, GTY B, Aurora B RX (including its CBCC FIFO), side B, Aurora B TX, the cable back, and Aurora A RX;
  - excludes: syndrome generation and the pins of a real qubit controller.
- **Echo:** the same path with the decoder replaced by side B's 1-cycle echo register. That is the link round trip plus 1 cycle.
- **Decode alone (silicon):** side B's counter from the RX register to the TX FIFO write. It is constant over every shot and equals the decoder latency + 1 (the RX register).

lc8 is the main build (the shallowest that closes at 161 MHz with margin). The table gives the median (min … max) over 464,428 shots, GAP 63:

| Build | Decoder cycles (silicon B count − 1) | Decode alone | Echo loop | Decode loop | Decode − echo (means) |
|---|---|---|---|---|---|
| **lc8** run 1 | 6 | **37.2 ns** | 118 cyc = **732.3 ns** (111 … 124) | 124 cyc = **769.6 ns** (117 … 130) | 6.01 cyc |
| lc8 run 2 | 6 | 37.2 ns | 118 (111 … 129) | 124 (117 … 130) | 5.98 |
| lc8 run 3 (reprogrammed) | 6 | 37.2 ns | 118 (111 … 124) | 124 (117 … 136) | 5.99 |
| lc12 | 5 | 31.0 ns | 118 (111 … 124) | 123 = 763.3 ns (116 … 129) | 5.07 |
| lc5 | 8 | 49.6 ns | 118 (112 … 125) | 126 = 782.0 ns (120 … 133) | 8.03 |

How to read it:
- **The decoder is isolated.** Decode − echo equals the decoder's pipeline depth at all three builds (5, 6, 8 cycles) to within 0.07 cycle. The echo loop is the same with every decoder.
- **The link dominates.** The Aurora round trip is about 117 cycles = 727 ns. That is the 118-cycle echo median minus 1 echo register, roughly 360 ns each way. Most of it is the 64B/66B gearbox, the GT buffers and the RX CBCC FIFO; the cable itself is about 5 ns.
- **Jitter:** the loop spreads over about 13 cycles, with an even/odd structure in the histogram. That comes from the two plesiochronous clocks, the 1-in-33 gearbox pause and clock compensation (`hist` in the json).
- **GAP 7** gives the same median, so there is no queueing.

## 4. Against the published figures

The published figures are a 124 ns NN decode inside a 550 ns d = 3 loop, **hardware-measured** on a Kintex-7 XC7K410T (arXiv 2605.04892, preprint).

| | Theirs (hardware) | Ours |
|---|---|---|
| Decode | 124 ns | **37.2 ns** (lc8, silicon on-chip counter; 31.0 ns at lc12) |
| Loop | 550 ns | **769.6 ns** median (silicon) |

- **Decode:** ours is 3.3× shorter. Both are hardware decode latencies on different devices.
- **Loop:** ours is longer. Of our loop, 727 ns is the Aurora 64B/66B round trip; the decoder adds 37 ns. Their link is not ours, so the loops differ mostly in the link.
- **Next:** the CHARTER's Stage 6 stretch (a thin custom GTY framing replacing Aurora) targets that link cost.

## 5. Simulation evidence and builds

- **Verilator loop** (`verilator/s3_loop_lc{5,8,12}_n464428_{spec,aslow}.log`): the real side A, side B and decoder RTL with a behavioural link and plesiochronous clocks in both orientations, on the full vector set.
  - fails = 0; decode − echo equals DEC_LAT exactly.
  - Negative control: one corrupted returned flip is caught as exactly 1 mismatch.
  - The GAP 0 case with clk_a faster than clk_b overflows side B's FIFO as predicted, a real property: on silicon use GAP ≥ 1.
- **Builds** (`build/s3_lc{8,12,5}_d/`), Vivado 2024.2, routed:

  | Build | WNS | WHS | WPWS | Bitstream sha256 |
  |---|---|---|---|---|
  | lc8 | +0.178 | +0.013 | +0.455 | `0ef35a6e…` |
  | lc12 | +0.051 | +0.011 | +0.455 | `build/s3_lc12_d/bitstream_sha256.txt` |
  | lc5 | +0.157 | +0.002 | +0.455 | `build/s3_lc5_d/bitstream_sha256.txt` |

  - Each build uses about 19.5–21.3k LUT, 410 BRAM tiles (the shot ROM), 0 DSP.
  - Every bitstream went through `s3_bitstream.tcl`, which refuses without signed-off timing and both passing Verilator loop logs.

## 6. Reproduce

```
ssh build-host 'cd <proj> && make -C tb s3 LC=8 JOBS=16'                 # loop sim (both orientations)
ssh build-host 'cd <proj> && synth/scripts/launch_s3.sh s3_lc8_x 8'      # build; then s3_bitstream.tcl in synth/out_s3_lc8_x
ssh build-host 'cd <proj> && sw/bcu/desk.sh program synth/out_s3_lc8_x/s3_top.bit synth/out_s3_lc8_x/s3_top.ltx'
ssh build-host 'cd <proj> && sw/bcu/desk.sh run sw/bcu/s3_measure.cmd' > evidence/stage3/silicon/<run>.log
python3 sw/analysis/s3_analyze.py evidence/stage3/silicon/<run>.log --json <run>.json
```
Bring-up notes, including the missing-module diagnosis and the PMA loopback check: `silicon/BRINGUP.md`.
