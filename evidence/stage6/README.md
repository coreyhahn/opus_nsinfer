# Stage 6: a thin custom GTY link in place of Aurora (BCU-1525 decoder loop)

**d = 3 verdict: PASS (2026-11-03), silicon.** The Stage 3 loop (same shot player, checker, decoder and counters) runs
over a thin 64B/66B link on the GTYs instead of Aurora 64B/66B:
- **One-way link latency 22-24 cycles = 136.5-148.9 ns** (silicon, direct one-way probe, 4 runs over 3 bring-ups of the
  final build), **under the published ~156 ns custom-link figure** on every one of ~6.3e8 probe words (both directions), but not by much (the
  worst word of the first build, after a re-train, was 25 cycles = 155.2 ns).
- **Link round trip 47 cycles = 291.7 ns**, against Aurora's 117 cycles = 726 ns (Stage 3, same method): 2.5x lower.
- **Decode loop median 54 cycles = 335.1 ns** (52 ... 56 = 322.7 ... 347.5 ns), against 769.6 ns with Aurora; it is now
  below the published 550 ns d = 3 loop (arXiv 2605.04892, Kintex-7, hardware-measured).
- Bit-identical to the Keras model on all 464,428 golden vectors in every one of 21 decode / echo runs on two builds;
  return-order signatures equal Stage 3's (decode `5e8e5270`, echo `5f09efeb`).
- **One clock domain** for the whole loop (both link ends, player, checker, decoder), from **one reference clock**.

**d = 5 verdict: PASS (2026-11-05 set 0, 2026-11-06 sets 1-3), silicon, all four vector sets** (§7). The Stage 4 loop (120 detectors, the 192-96-96 lc3bc
decoder, 19 cycles, II = 1) over 3 lanes per direction of the same link: **decode loop median 67 cycles = 415.8 ns**
(65 ... 69 = 403.4 ... 428.2 ns) against Aurora's 137-138 cycles = 850-856 ns (Stage 4): 2.0x lower; echo median 48 cycles
= 297.9 ns, the same as d = 3 (3-lane deskew costs no measurable cycle); one-way probe 21-24 cycles = 130.3-148.9 ns.
Bit-exact on the 131,072 golden-set vectors in 9 of 9 runs (3 runs x 3 modes, 2 bring-ups); signatures equal Stage 4's
(decode `61783930`, echo `ebffc69c`). **Sets 1-3** (one build each, the same netlist and timing): 27 of 27 modes bit-exact
(9 runs, a load and a re-train per set), decode loop median 66-68 cycles = 409.6-422.0 ns, decode - echo = 19 in every run.

**TX buffer bypass, d = 3: PASS (2026-11-06), silicon** (§6). Same loop and single clock with the GTY's TX buffer bypassed (build
s6bp_lc8_a): **one way 18-21 cycles = 111.7-130.3 ns** (was 136.5-148.9 ns), **decode loop median 46-47 cycles = 285.5-291.7 ns**
(was 335.1 ns), bit-exact on all 464,428 vectors in 9 of 9 runs (3 runs x 3 modes, a load and 3 re-trains).

**Link check blocks (CRC-32), d = 3 with TX bypass: PASS (2026-11-06), silicon** (§6b). Build s6chk_lc8_a: a check block in idle
slots only, so no data word waits: decode loop median 46 cycles = 285.5 ns in 3 of 3 runs (= s6bp_lc8_a), 9 of 9 modes
bit-exact, about 9.8e8 checks verified per end with 0 bad.

Labels as CLAUDE.md: **silicon** (on-chip counters on the board), **sim** (Verilator), **model** (the Verilator GT model or
second-hand numbers), **derived** (arithmetic on the others). One cycle = 6.20606 ns (FREQ_A = 27,033,600 per 2^24 cycles of
the 100 MHz init clock, silicon, every run).

## 1. What was built (docs/PLAN.md §B.5)
- **Link (`rtl/s6/s6_link.sv`):** 64B/66B on the GTY's synchronous gearbox (the GT settings of the Stage 3 Aurora cores:
  `synth/scripts/s6_gen_gt.tcl`, GT Wizard 1.7, preset GTY-Aurora_64B66B; the generated channel attributes equal Aurora's
  except RX/TXSYNC_MULTILANE), TX and RX buffers on, 10.3125 Gb/s, one lane per direction on the same QSFP+ DAC. One 66-bit
  block per s3 word: header 01 = data, 10 = idle; x^58 + x^39 + 1 self-synchronous scrambler; UG578 Fig. 4-54 block sync with
  RXGEARBOXSLIP; TXSEQUENCE counter with tready low in the 2 cycles of 66 the gearbox pauses. No fabric register between the
  s3 sides and the GT in either direction (TX_REG = RX_REG = 0). No CRC in the builds of §2-5 and §7 (Aurora had none either); errors reach the s3 checks. Check blocks (CRC-32) since §6b.
- **Clocking (D-S6-CLK):** QSFP0's MGTREFCLK1 (K11/K10) drives the QPLL1 of both quads (quad 230 through the south-bound refclk
  routing, UG578 v1.4 p. 24 / 34). TXOUTCLK of channel X1Y48 through one BUFG_GT is TXUSRCLK/TXUSRCLK2 and RXUSRCLK/RXUSRCLK2
  of both channels (UG578 p. 102, 106, 321; Table 4-38) and the fabric clock of the whole loop. The build checks it on the routed
  netlist (`build/s6_lc8_b/clock_check.txt`): all eight USRCLK pins on one net, one BUFG_GT, one IBUFDS_GTE4 driving both
  commons: `SINGLE_CLOCK PASS`. The plesiochronous A/B drift of Stage 3/4 is gone, which also makes a direct one-way
  measurement possible.
- **Probe (`rtl/s6/s6_probe.sv`):** each end stamps a word with the shared counter at its TX accept edge; the other end reads
  the same counter at its RX register edge. Same start / stop convention as the loop counter.
- Register map: `rtl/s6/s6_regmap.md`. Top: `rtl/s6/s6_top.sv` (around `s6_core.sv`, which is what Verilator runs).

## 2. Simulation (gate 2; `verilator/`)
- **Link alone** (`make -C tb s6_link`, `s6_link_nl{1,3}_t{0,1}r{0,1}.log`): two link ends and a behavioural GT/wire model
  (`tb/tb_s6_gt.sv`: TXSEQUENCE pause, a 66-bit serial stream, random bit boundary, gearbox slip, bit errors, a one-bit glitch,
  a garbage burst). Each: an independent bit-serial descrambler on the TX stream agrees on every one of ~1.0e5 blocks; block
  lock from random boundaries; ~1e5 random and back-to-back words both ways delivered in order without loss; injected bit
  errors are seen (header / idle counters, scoreboard); the glitch and the burst lose lock, slip and re-lock, then clean traffic.
  NL = 3 with lane skew exercises the deskew FIFOs (for d = 5). Negative control: the reference descrambler with a wrong tap
  must fail, and does (`s6_link_nl1_t0r0_negscr.log`).
- **Whole loop** (`make -C tb s6 LC=8`, `s6_loop_lc8_n464428_t0r0_lat{640,701}_s{0,1}.log`, two GT-model latencies / seeds):
  `s6_core` (real s3_side_a, s3_side_b + the lc8 decoder, links, probes, registers) on all 464,428 golden shots: decode GAP 0,
  GAP 7, echo GAP 7, echo GAP 0, a corrupted returned flip caught as exactly 1 mismatch at its seq, histograms, flag RAM,
  golden-order signature = link-side signature; loop latency inside the bounds computed from the probe's one-way numbers;
  decode - echo = DEC_LAT = 6; no link error. `fails=0`, PASS, both. Regression / negative control for the probe-counter bug
  found on silicon (§5): `s6_loop_negctl_probe_counter.log` (old counter must FAIL, does). The four logs that gated the first
  build are in `verilator/superseded_probe_v1/` (same loop logic, old probe counter); the TX_REG = RX_REG = 1 variant passed
  there too.

## 3. Builds (gate 3; `build/`)
Vivado 2024.2 on build-host; licence used: "Implementation ... expires in 23 day(s)" = the ML Enterprise licence to 26-Nov-2026
(`build/*/licence_excerpt.txt`). Every bitstream went through `synth/scripts/s6_bitstream.tcl` (refuses without WNS/WHS/WPWS
>= 0, the one-clock check, and two passing loop logs on the build's exact shot ROM plus the four link logs).

| Build | RTL | WNS | WHS | WPWS | LUT / FF / BRAM tiles | Single clock | Bitstream sha256 |
|---|---|---|---|---|---|---|---|
| s6_lc8_a | probe v1 | +0.180 | +0.013 | +0.442 | 21,353 / 14,817 / 408 | PASS | `fd7dbea9…` |
| **s6_lc8_b** | final | **+0.252** | **+0.006** | **+0.442** | 21,548 / 14,817 / 408 | PASS | `6d27728e…` |
| **s6d5_lc3bc_a** (d = 5, 3 lanes) | final | **+0.037** | **+0.013** | **+0.442** | 156,275 / 89,169 / 496 | PASS (24 USRCLK pins, one net) | `7affdf92…` |
| s6d5_lc3bc_set1 (d = 5, set 1 ROM) | final | +0.037 | +0.013 | +0.442 | 156,275 / 89,169 / 496 | PASS | `0f9d3e2c…` |
| s6d5_lc3bc_set2 (d = 5, set 2 ROM) | final | +0.037 | +0.013 | +0.442 | 156,275 / 89,169 / 496 | PASS | `72d997d0…` |
| s6d5_lc3bc_set3 (d = 5, set 3 ROM) | final | +0.037 | +0.013 | +0.442 | 156,275 / 89,169 / 496 | PASS | `f1290662…` |

The d = 5 bitstream (written 2026-11-05, licence "expires in 21 day(s)", the same ML Enterprise licence) was also gated by a
re-check on the routed checkpoint itself, added to `s6_bitstream.tcl` then: WNS +0.037 / WHS +0.013 recomputed, one USRCLK net,
one IBUFDS_GTE4, 6 channels (`build/s6d5_lc3bc_a/bitstream_log_excerpt.txt`, `timing_recheck_bitstream.rpt`).

## 4. Silicon (gate 4; `silicon/`)
Desk BCU-1525 (#2) only, through `sw/bcu/desk.sh` (its own lock; volatile JTAG; PCIe card not touched). The link locked on
the first load of each build (`BRINGUP.md`). Command file `sw/bcu/s6_measure.cmd` (generated by `sw/bcu/gen_s6_cmd.py`;
build a used `silicon/cmd/s6_measure_v1.cmd`, without the PCS-loopback and back-to-back loopback probes): probe, the Stage 3
runs (echo GAP 63, decode GAP 63, decode GAP 7 + 8,192 decisions read back), link counters, then near-end loopbacks of end A.
Analysis: `sw/analysis/s6_analyze.py` (the s3_analyze checks + probes), `sw/analysis/s6_summary.py`.

**Definitions.**
- *Loop* (as Stage 3/4): start = the clk edge at which side A's word is accepted by link end A (tvalid & tready); stop = the
  clk edge at which side A registers the response from link end A; instrument = side A's cycle counter, 1-cycle histogram;
  covers link A TX, GTY X1Y48, the DAC, GTY X1Y44, side B (decoder or 1-cycle echo register), the way back; excludes syndrome
  generation and a real controller's pins. *Echo* = the same with side B's echo register: link round trip + 1.
- *One-way probe*: start = the clk edge at which the sending end's link TX accepts the probe word; stop = the clk edge at which
  the receiving end registers it; instrument = the one shared counter (one clock); covers the sender's GTY TX, the DAC (or the
  near-end loopback path), the receiver's GTY RX, its RX register; excludes the s3 sides. `p63` = one word per 64 cycles (the
  generator then always meets the TX gearbox right after its pause), `p0` = back to back (every gearbox position).
- clk = the one loop clock, 161.1328125 MHz (TX user clock).

**Results, final build s6_lc8_b** (silicon; median (min ... max), cycles; ns = cycles x 6.20606):

| Run | Bring-up | Echo loop GAP 63 | Decode loop GAP 63 | Decode loop GAP 7 | Probe A->B p0 (mean) | Probe B->A p0 (mean) | Probe p63 A->B / B->A | PMA loopback A->A p0 | PCS loopback A->A p0 |
|---|---|---|---|---|---|---|---|---|---|
| 1 | load 1 | 48 (46 ... 50) | 54 (52 ... 56) | 54 (52 ... 56) | 24 (22 ... 24) 23.25 | 24 (22 ... 24) 23.00 | 22 / 22 | 21 (19 ... 21) | 17 (17 ... 19) |
| 2 | load 1 | 48 (46 ... 50) | 54 (52 ... 56) | 54 (52 ... 56) | 24 (22 ... 24) 23.00 | 22 (22 ... 24) 22.81 | 22 / 22 | 20 (20 ... 22) | 19 (17 ... 19) |
| 3 | re-train (gtwiz_reset_all) | 48 (46 ... 50) | 54 (52 ... 54) | 54 (52 ... 54) | 22 (22 ... 24) 22.88 | 22 (22 ... 24) 22.50 | 22 / 22 | 21 (19 ... 21) | 17 (17 ... 19) |
| 4 | load 2 | 48 (46 ... 50) | 54 (52 ... 56) | 54 (52 ... 56) | 24 (22 ... 24) 23.25 | 22 (22 ... 24) 22.56 | 22 / 22 | 20 (18 ... 20) | 19 (17 ... 19) |

In ns: echo 297.9 (285.5 ... 310.3); decode loop **335.1 (322.7 ... 347.5)**; one-way probe **136.5 ... 148.9**, means
139.7-144.3; PMA loopback 111.7-136.5; PCS loopback 105.5-117.9. Every run: n_good = 464,428, every error counter 0, signature =
sim, 8,192 decisions = golden, side B decode path constant 7 = DEC_LAT + 1, every probe word received (78.6-79.5 M per direction
per run back to back), no lock loss / bad header / bad idle / buffer error. Build s6_lc8_a (3 runs, 2 bring-ups) measured 1-3
cycles lower on its first bring-up (echo 45-47, decode 51-53, probe 20-23) and 49 / 55 / 22-25 after its re-train
(`summary_lc8_a.json`); its run 3 is marked FAIL only for the probe counter bug (§5).

**How to read it.**
- **Link round trip (derived, Stage 3 convention):** echo median - 1 = 47 cycles = **291.7 ns**; one way 23.5 cycles = 145.8 ns.
  Aurora (Stage 3 silicon): 117 cycles = 726 ns, 363 ns one way. The direct probe agrees: 22-24 cycles one way.
- **The decoder is isolated:** decode - echo = 6 cycles at every run and both GAPs (DEC_LAT of lc8), as in Stage 3.
- **Where the time goes (silicon, derived):** near-end PCS loopback (TX PCS -> RX PCS inside the GTY, no PMA, no cable) is
  already 17-19 cycles = 106-118 ns, of which 1 cycle is our RX register; near-end PMA loopback adds 1-3 cycles; the DAC and the
  far channel 1-3 more. **The GTY's PCS at the 64-bit internal width (gearbox, TX and RX buffers) is ~100 ns of the ~140 ns.**
  The second-hand AR 69011 numbers of the survey (32-bit path, ~40 ns of PCS) do not describe this configuration.
- **Jitter:** latency moves in steps of 2 cycles (the TX sequence counter steps every 2 cycles at this width): a word that meets
  the TX gearbox right after its pause takes 22, the others 24 (probe p63 vs p0). Loop spread 4 cycles (46 ... 50), against 13
  for Aurora. Re-trains and reloads moved the one-way latency by up to 3 cycles (build a: 20/21 -> 22/23); within a bring-up it
  is fixed.
- **GAP 7** gives the same median as GAP 63 (no queueing).

## 5. Against the targets
| | One way | Loop (d = 3, decode) | Source |
|---|---|---|---|
| Aurora 64B/66B, this card (Stage 3) | 363 ns (derived from echo) | 769.6 ns | silicon |
| Aurora, RISC-Q work | ~450 ns | — | secondary report |
| Custom (Eos-based) link, RISC-Q work | ~156 ns, "with CDC-driven spread" | — | secondary report |
| **This link (s6_lc8_b)** | **136.5-148.9 ns** (probe; 145.8 ns Stage 3 convention) | **335.1 ns** median | silicon |
| NN decoder loop, arXiv 2605.04892 | — | 550 ns | hardware-measured (paper) |
| d = 5 over Aurora, 3 bonded lanes (Stage 4) | 363-366 ns (derived) | 850-856 ns | silicon |
| **d = 5 over this link, 3 lanes (s6d5_lc3bc_a)** | **130.3-148.9 ns** (probe) | **415.8 ns** median | silicon |
| **d = 3, TX buffer bypassed (s6bp_lc8_a, §6)** | **111.7-130.3 ns** (probe) | **285.5-291.7 ns** median | silicon |

The 156 ns and 450 ns figures come from `future_fpga_inference_designs/reports/FPGA photon timing and quantum readout.md`,
which says they were "all measured in the RISC-Q work" (arXiv 2603.16203, a preprint) and that the custom link's spread comes from
clock-domain crossings. I did not open the paper, so their method (start / stop events) is not known here; treat the comparison as
against a reported measurement, not a like-for-like one. This link beats 156 ns on every probe word, with a margin of 7-20 ns.

**Bug found on silicon and fixed:** the probe's sent counter counted an accept in the cycle in which probe_en fell (build a run 3:
sent = received + 1). Fixed in RTL, regression test added, build b. Latency data were never affected.

## 6. TX buffer bypass at d = 3 (2026-11-06)

Plan: `docs/superpowers/plans/2026-11-06-stage6-next.md` Tasks 3-4; decision D-S6-TXBYP in `docs/PLAN.md`. Labels: **silicon**
unless stated. Same loop, link, decoder (lc8), measurement and clock as build s6_lc8_b; only the GT core differs.
- **Core (`build/txbyp_feasibility.md`, model):** `s6_gt_bp` = `s6_gt` with TX_BUFFER_MODE 0: TXBUF_EN FALSE, TX_XCLK_SEL TXUSR,
  the synchronous gearbox kept, multi-lane auto phase alignment by the wizard's buffer-bypass controller (clocked by the loop
  clock), TXOUTCLK = TXPLLREFCLK_DIV1 (the same 161.1328125 MHz refclk; the wizard requires it). RX unchanged. `s6_top`
  TXBYP = 1 releases the link's TX reset only after the controller reports done; LINK[20] = done, LINK[21] = error.
- **Sim:** `s6_core` / `s6_link` are byte-identical to the d = 3 gate (RTL sha256 26894cb4..., the committed loop logs PASS on
  all 464,428 golden shots); both `s6_top_lint` configurations clean. The bypass itself is not in the Verilator GT model.
- **Build `build/s6bp_lc8_a/`:** WNS +0.231 / WHS +0.010 / WPWS +0.442 ns (s6_lc8_b +0.252 / +0.006 / +0.442), 21,648 LUT,
  `SINGLE_CLOCK PASS` (all USRCLK pins on one net, one BUFG_GT, one IBUFDS_GTE4). Bitstream sha256 `d3cfd8a2...`.
- **Bring-up:** LINK `0x011c7373` on the first load (both ends locked, bypass done, no error); 3 re-trains in a row
  (`silicon/s6bp_lc8_a_retrain_{1,2,3}.log`): each loses lock, re-locks with done = 1 and error = 0, stickies clear.

| Run (s6bp_lc8_a) | Bring-up | Echo GAP 63 | Decode GAP 63 / GAP 7 | Probe A->B p63 | Probe B->A p63 | Probe p0 A->B / B->A | PMA loop | PCS loop |
|---|---|---|---|---|---|---|---|---|
| 1 | load | 39 (39 ... 43) | 47 (45 ... 47) / 47 | 18 (18 ... 18) | 19 (19 ... 19) | 18-20 / 19-21 | 16 (16 ... 18) | 15 (15 ... 15) |
| 2 | load | 41 (39 ... 41) | 47 (45 ... 47) / 47 | 19 (19 ... 21) | 18 (18 ... 20) | 19-21 / 18-20 | 16 (16 ... 18) | 15 (15 ... 15) |
| 3 | 3 re-trains | 40 (38 ... 42) | 46 (46 ... 46) / 46 | 18 (18 ... 20) | 18 (18 ... 20) | 18-20 / 18-20 | 16 (16 ... 18) | 15 (15 ... 15) |
| s6_lc8_b (§4), for comparison | | 48 (46 ... 50) | 54 (52 ... 56) | 22 | 22 | 22-24 | 19-21 | 17-19 |

(median (min ... max) cycles of 6.20606 ns.) Every run: n_good = 464,428 in all three modes, every error counter 0, signatures
`5e8e5270` / `5f09efeb` = sim and = s6_lc8_b's, 8,192 sampled decisions = Keras, every probe word received, no lock loss or
buffer error during the runs (`silicon/s6bp_lc8_a_cable_run{1,2,3}.{log,json}`, `silicon/summary_bp_lc8_a.json`).
- **One way: 18-21 cycles = 111.7-130.3 ns** over every probe word of the three runs (s6_lc8_b 22-24 = 136.5-148.9 ns): the
  TX buffer was 4 cycles = 24.8 ns of each hop. 156 ns (second-hand) is now beaten by 26-44 ns on every word.
- **Decode loop median 46-47 cycles = 285.5-291.7 ns** (s6_lc8_b 335.1 ns, Aurora 769.6 ns); echo (link round trip + 1) 39-41.
- **Near-end loopbacks:** PCS 15 (was 17-19), PMA 16 (was 19-21): the saving is inside end A's GT TX, as expected.
- The latency now varies by about one cycle between bring-ups (echo median 39 / 41 / 40), as before (the GT RX buffer and gearbox
  phase); TX phase alignment adds no spread that the runs can see.
- **Not done:** bypass at d = 5 (3 lanes over two quads, multi-lane alignment across 6 channels): one more core and build.
  RX buffer bypass would put RXUSRCLK on the recovered clock (a second clock): needs the user's approval.

## 6b. Link check blocks (CRC-32), 2026-11-06
Plan: `docs/superpowers/plans/2026-11-06-stage6-next.md` Tasks 5-6; decision D-S6-CHK in `docs/PLAN.md`.
- **Design (`rtl/s6/s6_link.sv`, `s6_pkg.sv`):** each lane keeps a CRC-32 (reflected 0xEDB88320, init all ones, over each
  64-bit data word as 8 little-endian bytes: = zlib.crc32) and a 24-bit word count. When the lane has no data word to send
  (`!s_tvalid`) and words were sent since the last check, it sends a control block (header 10) `{0xD2, n[23:0], ~crc[31:0]}`
  instead of IDLE, then restarts both. A data word never waits for a check, so the latency cannot change. The receiver keeps
  the same CRC and count per lane, compares at each check block (`n_chk_ok` / `n_chk_bad`, regs 11/12 at end A, 27/28 at
  end B, `rtl/s6/s6_regmap.md`), and ignores the first check after lock (its window started before lock). Errors are counted,
  not acted on: the s3 checks still own the data.
- **Sim (`verilator/s6_link_*.log`, branch s6-crc 34f08f9, merged bb4d32f):** the link tests check the CRC against zlib's
  known answer (0x1a972b44 over [0, 0x0123456789ABCDEF, all ones]) and against a reference CRC in the testbench on every
  check block; clean phases end with 0 bad checks; a data word stalls only in the gearbox pause cycles; random bit errors
  give bad checks; after a glitch or burst and re-lock the next checks are good again. 4 of 4 link logs PASS, the scrambler
  negative control FAILS as it must. Loop sims (`verilator/s6_loop_lc8_*`, `s6d5_loop_lc3bc_n131072_*`): every RESULT line
  identical to the logs without checks, and the injected corrupted word gives exactly 1 bad check at end A (d = 3: A ok =
  1,351,570, B ok = 1,365,641; d = 5: A ok = 1,133,504 / 1,133,510, B ok = 1,157,334, B bad = 0).
- **Build s6chk_lc8_a** (TX bypass + checks, `S6_TXBYP=1 launch_s6.sh s6chk_lc8_a 8 Default 3 0 0`, built in the s6-crc worktree
  at 34f08f9 and moved to `synth/out_s6chk_lc8_a`, `build/s6chk_lc8_a/MOVED.txt`; its RTL = master's after the merge): WNS +0.080 /
  WHS +0.011 / WPWS +0.441 ns, single clock PASS, 22,727 LUT / 15,314 FF / 408 BRAM tiles (s6bp_lc8_a: 21,648 LUT), bitstream
  `e756b38f…` gated by `s6_bitstream.tcl` on the two d = 3 loop logs with checks.
- **Silicon (`silicon/*s6chk_lc8_a*`, `summary_chk_lc8_a.json`, run by `sw/bcu/s6_chk_silicon.sh`):** LINK `0x011c7373` (TX
  bypass done, no error) on the load and after the re-train; runs 1-2 on the load, a re-train, run 3; analysis
  `s6_analyze.py --lc 8 --chk`.

| Run | Bring-up | Echo GAP 63 | Decode GAP 63 | Decode GAP 7 | Probe A->B p0 (mean) | Probe B->A p0 (mean) | p63 A->B / B->A | PMA loop A->A p0 | PCS loop A->A p0 | Checks per end (all windows) |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | load | 40 (40 ... 42) | 46 (46 ... 48) | 46 (46 ... 48) | 19 (19 ... 19) 19.00 | 19 (19 ... 21) 19.25 | 19 / 19 | 16 (16 ... 18) | 15 (15 ... 15) | 328,553,722 ok, 0 bad |
| 2 | load | 40 (38 ... 42) | 46 (44 ... 48) | 46 (44 ... 48) | 20 (18 ... 20) 19.06 | 20 (18 ... 20) 19.00 | 18 / 18 | 16 (16 ... 18) | 15 (15 ... 15) | 325,666,036 ok, 0 bad |
| 3 | re-train | 40 (38 ... 40) | 46 (44 ... 46) | 46 (44 ... 46) | 19 (17 ... 19) 18.75 | 19 (17 ... 19) 18.88 | 17 / 17 | 16 (16 ... 18) | 15 (15 ... 15) | 325,638,779 ok, 0 bad |

(silicon; median (min ... max) cycles of 6.20606 ns; definitions as §4.) Every run: n_good = 464,428, every error counter 0,
signatures `5e8e5270` / `5f09efeb` (= sim, = every d = 3 build), 8,192 decisions = Keras, every probe word received.
- **Latency unchanged by the checks:** decode loop median 46 cycles = 285.5 ns in all three runs (s6bp_lc8_a: 46-47); one way
  17-21 cycles = 105.5-130.3 ns over every probe word (s6bp_lc8_a 18-21); PCS / PMA near-end loopback 15 / 16, as s6bp_lc8_a.
- **Checks:** 979,858,537 good checks at each end over the three runs (8 counter windows per run), 0 bad. A and B count the same
  in every window because the traffic is symmetric (both ends send the same probe stream; `n_data` is equal at A and B too,
  e.g. 0x04c5c624 in run 1's p0 window) and an isolated data word is followed by one check.
- **Not shown on silicon:** a bad check. The board has no error injection; detection is shown in sim only (bit errors, the
  corrupted word). Not built at d = 5 (same RTL, NL = 3 in sim).

## 7. d = 5 (3 lanes, DW = 192)
- **Design:** `s6_link` with NL = 3 (D-S6-D5): every lane carries 64 bits of the Stage 4 192-bit word, all lanes on one
  TXSEQUENCE, RX lanes re-aligned by per-lane FIFOs (no marker, no bonding). GT core `s6_gt3` (X1Y44..46, X1Y48..50, master
  X1Y49), the same one refclk and one user clock. Decoder: Stage 4's `qec_d5_lc3bc` (DEC_LAT 19), unchanged.
- **Sim (`verilator/s6d5_loop_lc3bc_n131072_t0r0_lat{640_s0,701_s1}.log`):** the Stage 4 golden set (131,072 vectors), both GT-model
  settings, lane skew in the model: PASS, decode - echo = 19, the corrupted flip caught once; the link alone at NL = 3 in
  `s6_link_nl3_*.log` (deskew with 70 / 140 UI of skew).
- **Build:** table in §3. **Silicon:** desk card, `program_s6d5_lc3bc_a_1.log` (LINK `0x7f0c7373`: all six lanes locked on the
  first load), `sw/bcu/s6d5_measure.cmd` (= s6_measure.cmd with the d = 5 flag sample), runs 1 and 2 on the load, a re-train
  (`s6d5_lc3bc_a_retrain_1.log`), run 3. Analysis `sw/analysis/s6_analyze.py --d 5 --lc 3bc`, summary `silicon/summary_d5_lc3bc_a.json`.
  Same definitions as §4 (loop: side A's counter, TX accept edge -> RX register edge, one loop clock; probe: shared counter;
  excluded: syndrome generation, a controller's pins).

| Run | Bring-up | Echo GAP 63 | Decode GAP 63 | Decode GAP 7 | Probe A->B p0 (mean) | Probe B->A p0 (mean) | p63 A->B / B->A | PMA loop A->A p0 | PCS loop A->A p0 |
|---|---|---|---|---|---|---|---|---|---|
| 1 | load | 48 (46 ... 50) | 67 (65 ... 69) | 67 (65 ... 69) | 24 (22 ... 24) 23.13 | 22 (22 ... 24) 23.00 | 22 / 22 | 20 (20 ... 22) | 19 (17 ... 19) |
| 2 | load | 48 (46 ... 49) | 67 (65 ... 68) | 67 (65 ... 68) | 23 (21 ... 23) 22.78 | 23 (22 ... 24) 23.03 | 21 / 22 | 20 (20 ... 22) | 17 (17 ... 19) |
| 3 | re-train | 48 (47 ... 50) | 67 (65 ... 69) | 67 (65 ... 69) | 22 (22 ... 24) 22.69 | 24 (22 ... 24) 23.25 | 22 / 22 | 20 (20 ... 22) | 17 (17 ... 19) |

(silicon; median (min ... max) cycles of 6.20606 ns.) Every run: n_good = 131,072, every error counter 0, signature = sim,
8,192 decisions (shots 0-4095, 126976-131071) = the Keras decisions, side B's decode path constant 20 = DEC_LAT + 1, every probe word
received, no lock loss / bad header / bad idle / deskew overflow / buffer error on any lane.
- **Decoder isolated:** decode - echo = 19 cycles = 117.9 ns (DEC_LAT), as Stage 4. The link part of the d = 5 loop is now 291.7 ns
  (echo - 1) instead of 726-732 ns.
- **3 lanes cost nothing measurable:** the d = 5 echo median (48) equals d = 3's on build b; the one-way probe is in the same
  21-24-cycle band.
- **Vector sets 1-3 (CHARTER rule (c), Stage 4's practice; PLAN D-S4-SETS), 2026-11-06.** The shot ROM is fixed at build time,
  so each set is its own build: `D5_N=131072 D5_SET=k synth/scripts/launch_s6.sh s6d5_lc3bc_set<k> 3bc Default 5 0 0` from the
  same RTL (launch git f85ba3a, the same file hashes as s6d5_lc3bc_a in `build/*/launch.txt`). All three placed and routed the same
  way as set 0 (WNS +0.037 / WHS +0.013 / WPWS +0.442 ns, same utilisation, single clock PASS; only the BRAM contents differ).
  Sims: `verilator/s6d5_loop_lc3bc_set<k>_n131072_t0r0_lat{640_s0,701_s1}.log`, both GT-model settings, PASS; each build's
  `mem.txt` ROM sha256 = its sims' `shot_mem_sha256` (set 1 `3e114182…`, set 2 `02ad625d…`, set 3 `b66b9698…`), which
  `s6_bitstream.tcl` checks. Silicon: `silicon/program_s6d5_lc3bc_set<k>_1.log` (LINK `0x7f0c7373` on every load:
  six lanes locked), `s6d5_lc3bc_set<k>_status_1.log`, runs 1-2, a re-train (`_retrain_1.log`, LINK `0x7f0c7373` after),
  run 3; analysis `s6_analyze.py --d 5 --lc 3bc_set<k> --dec .scratch/qec_d5_set<k>_dec.hex` (the set's Keras decisions),
  summaries `silicon/summary_d5_lc3bc_set<k>.json`. Run script: `sw/bcu/s6d5_set_silicon.sh` (desk.sh calls in this order).

| Set | Run | Bring-up | Echo GAP 63 | Decode GAP 63 | Decode GAP 7 | Probe A->B p0 (mean) | Probe B->A p0 (mean) | p63 A->B / B->A | PMA loop A->A p0 | PCS loop A->A p0 |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | load | 47 (46 ... 48) | 66 (65 ... 67) | 66 (64 ... 67) | 23 (22 ... 24) 22.81 | 22 (20 ... 22) 21.94 | 22 / 20 | 21 (19 ... 21) | 18 (18 ... 18) |
| 1 | 2 | load | 47 (46 ... 49) | 66 (66 ... 68) | 66 (66 ... 68) | 24 (22 ... 24) 23.31 | 22 (21 ... 23) 22.19 | 22 / 21 | 20 (20 ... 22) | 17 (17 ... 19) |
| 1 | 3 | re-train | 48 (46 ... 50) | 67 (67 ... 69) | 67 (67 ... 69) | 24 (22 ... 24) 23.25 | 24 (22 ... 24) 23.06 | 22 / 22 | 21 (19 ... 21) | 18 (18 ... 18) |
| 2 | 1 | load | 48 (46 ... 50) | 67 (65 ... 69) | 67 (65 ... 69) | 22 (22 ... 24) 22.87 | 24 (22 ... 24) 23.13 | 22 / 22 | 21 (19 ... 21) | 18 (18 ... 18) |
| 2 | 2 | load | 48 (46 ... 49) | 67 (66 ... 68) | 67 (66 ... 68) | 23 (21 ... 23) 22.62 | 23 (22 ... 24) 23.25 | 21 / 22 | 21 (19 ... 21) | 18 (18 ... 18) |
| 2 | 3 | re-train | 48 (46 ... 48) | 67 (65 ... 69) | 67 (65 ... 69) | 22 (22 ... 24) 22.63 | 22 (22 ... 24) 22.81 | 22 / 22 | 20 (20 ... 22) | 18 (18 ... 18) |
| 3 | 1 | load | 49 (47 ... 49) | 68 (66 ... 70) | 68 (66 ... 70) | 23 (23 ... 25) 23.56 | 22 (22 ... 24) 22.88 | 23 / 22 | 20 (20 ... 22) | 19 (17 ... 19) |
| 3 | 2 | load | 48 (47 ... 49) | 67 (65 ... 68) | 67 (65 ... 68) | 24 (22 ... 24) 23.44 | 23 (21 ... 23) 22.62 | 22 / 21 | 20 (19 ... 21) | 17 (17 ... 19) |
| 3 | 3 | re-train | 48 (46 ... 50) | 67 (65 ... 69) | 67 (65 ... 69) | 24 (22 ... 24) 23.06 | 22 (22 ... 24) 23.00 | 22 / 22 | 20 (20 ... 22) | 18 (18 ... 18) |

(silicon; median (min ... max) cycles of 6.20606 ns; same definitions as the set 0 table.) Every run: n_good = 131,072, every
error counter 0, decode signature = that set's sim (set 1 `149e1a8e`, set 2 `bbf1d963`, set 3 `56434086`; echo `ebffc69c`, which
does not depend on the shots), 8,192 decisions = the set's Keras decisions, side B's decode path constant 20, every probe word
received, no lock loss / bad header / bad idle / buffer error.
- **Over all four sets (12 runs, 36 modes, 5 bring-ups):** decode loop median 66-68 cycles = 409.6-422.0 ns (min 64, max 70 =
  397.2-434.4 ns), echo median 47-49 = 291.7-304.1 ns, decode - echo = 19 = DEC_LAT in every run; one-way probe 20-25 cycles =
  124.1-155.2 ns over every word. Set 3's first load sat one cycle high A->B (23 ... 25: 14.7 M of 78.6 M p0 words at 25 cycles
  = 155.2 ns, still under 156 ns); set 1's first load reached 20 cycles = 124.1 ns B->A (all but 52 of the p63 words, 2.5 M of 81 M p0 words). These are
  bring-up phases (RX buffer and gearbox, as at d = 3): the re-trained runs and the other loads sit at 22-24, and the data
  sets do not change the link.

## 8. Reproduce
```
vivado -mode batch -nojournal -source synth/scripts/s6_gen_gt.tcl -tclargs synth            # on build-host: rtl/ip/s6_gt
ssh build-host 'cd <proj> && make -C tb s6_link JOBS=8 && make -C tb s6 LC=8 JOBS=8'               # gate 2
ssh -n build-host 'cd <proj> && synth/scripts/launch_s6.sh <name> 8 Default 3 0 0' > /dev/null 2>&1   # gate 3, then in synth/out_<name>:
vivado -mode batch -nojournal -source ../scripts/s6_bitstream.tcl -tclargs .
ssh build-host 'cd <proj> && sw/bcu/desk.sh program synth/out_<name>/s6_top.bit synth/out_<name>/s6_top.ltx'
ssh build-host 'cd <proj> && sw/bcu/desk.sh run sw/bcu/s6_measure.cmd' > evidence/stage6/silicon/<run>.log
python3 sw/analysis/s6_analyze.py --lc 8 evidence/stage6/silicon/<run>.log --json <run>.json
# d = 5: vivado ... s6_gen_gt.tcl -tclargs l3 synth; make -C tb s6d5 LC=3bc; D5_N=131072 synth/scripts/launch_s6.sh <name> 3bc Default 5 0 0;
#        sw/bcu/desk.sh run sw/bcu/s6d5_measure.cmd; python3 sw/analysis/s6_analyze.py --d 5 --lc 3bc <log> --json <json>
```
