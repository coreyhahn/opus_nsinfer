# Stage 6 survey — a thin custom GTY link for the BCU-1525 decoder loop

Date 2026-11-03. Read-only survey (no builds, no board access). Labels as CLAUDE.md: **silicon**
(read from counters on the board), **sim**, **model** (estimate from vendor/third-party numbers),
**derived** (arithmetic on the others), **vendor** (AMD document I read), **unverified**.
One cycle of clk_a = 6.20606 ns (silicon: `evidence/stage3/README.md:17`).

Target: CHARTER.md:138 (stretch item 6) and `docs/PLAN.md:175` — beat the ~156 ns **one-way** custom
link. Where 156 ns comes from: RISC-Q's custom Eos-based link, "about 156 ns one-way ... with CDC-driven
spread", against "about 450 ns with AMD Aurora, all measured in the RISC-Q work"
(`future_fpga_inference_designs/reports/FPGA photon timing and quantum readout.md` lines 14, 162, 242;
RISC-Q = arXiv 2603.16203 per `docs/BACKGROUND.md:80-86`; I did not open the paper).

## 1. Where the 727 ns goes today

### 1.1 The loop as built (all from the repo)
- Two independent Aurora 64B/66B v13.0 cores, one per cage, 1 lane each, 10.3125 Gb/s, Streaming,
  Duplex, no flow control, no CRC, SupportLevel 1, 64-bit AXI4-Stream, INIT_CLK 100 MHz
  (`synth/scripts/s3_gen_aurora.tcl:9-10, 62-82`; `docs/PLAN.md:183-187`).
  - Core A: QSFP0, quad 231 = Quad_X1Y12, lane GTYE4_CHANNEL_X1Y48, refclk MGTREFCLK1 pins K11/K10
    (Si5335 U9). Core B: QSFP1, quad 230 = X1Y11, channel X1Y44, MGTREFCLK1 P11/P10 (Si5335 U12). Both
    161.1328125 MHz (FS = 10) (`s3_gen_aurora.tcl:4-7`; `docs/BCU1525.md` table; `synth/constraints/s3_bcu1525.xdc:10-15`).
  - 3-lane variant for d = 5 (`aurora3_a/b`, 192-bit, lanes X1Y48..50 / X1Y44..46, channel bonding)
    (`s3_gen_aurora.tcl:41-47`; `docs/PLAN.md:265`). Echo median 118 -> 118-119 cycles, so bonding costs <= 1 cycle
    (`evidence/stage4/README.md:91`).
- GT settings inside the core (`rtl/ip/aurora_a/ip_0/aurora_a_gt.xci`, `.../synth/aurora_a_gt_gtye4_channel_wrapper.v`):
  - preset `GTY-Aurora_64B66B`; PLL type QPLL1 (xci:241), TX and RX data width 64, internal width 64 (xci:36-37, 46-47).
  - **TX buffer and RX buffer both used** (`TX_BUFFER_MODE` = 1, `RX_BUFFER_MODE` = 1, xci:38, 48;
    wrapper: `TXBUF_EN` "TRUE" :1109, `RXBUF_EN` "TRUE" :680, `TX_XCLK_SEL` "TXOUT" :1322, `RX_XCLK_SEL` "RXDES" :1080).
    The `RX_BUFFER_BYPASS_MODE` option is present but disabled (xci:59).
  - GT-internal gearbox on both sides (`TXGEARBOX_EN` :1160, `RXGEARBOX_EN` :904, `GEARBOX_MODE` 5'b00001 :567);
    `TXSEQUENCE` port present (:283). The Aurora fabric does scrambling/descrambling and block sync
    (`aurora_a_64b66b_scrambler.v`, `_descrambler.v`, `aurora_a_block_sync_sm.v` in `rtl/ip/aurora_a/aurora_a/src/`);
    `RXSLIDE_MODE` "OFF" (:994), the slip is `RXGEARBOXSLIP`.
  - Clocks: `TX_OUTCLK_SOURCE` = TXOUTCLKPMA, `RX_OUTCLK_SOURCE` = RXOUTCLKPMA (xci:40, 53). user_clk is derived from
    TXOUTCLK in `aurora_a_clock_module.v` (`s3_top.sv:132`, `PLAN.md:186`); measured 161.1328125 MHz.
  - Clock compensation: the core's fabric CBCC (`aurora_a_cbcc_gtx_6466.v`: write side "wrt RXRECCLK", read side user_clk) with an
    independent-clock built-in FIFO, depth 512 (`ip_1/aurora_a_fifo_gen_master.xci:11,18`). `PLAN.md:187`: "RX goes through
    the core's fabric CBCC FIFO (no bypass option)".
- Clock domains (`rtl/s3/s3_top.sv:14-22`, `PLAN.md:188-193`): clk_a and clk_b are the two Aurora user clocks (separate Si5335
  outputs, **plesiochronous**: B is +0.19 ... +0.63 ppm from A, `evidence/stage3/silicon/BRINGUP.md`, `evidence/stage4/README.md:87`).
  init_clk = 300 MHz / 3 = 100 MHz runs the JTAG-AXI registers and reset sequence. **No CDC FIFOs for data**: data crosses only
  over the cable. The only crossings are 2-flop quasi-static control and Gray frequency counters (`s3_regs`, `s3_freq`).
- Cable: QSFP+ 40G DAC QSFP0 <-> QSFP1 on the same desk card (#2), one lane per direction (`evidence/stage3/README.md:14`).

### 1.2 Measurement method (silicon)
- Loop: start = clk_a edge at which side A's TX beat is accepted (tvalid and tready); stop = clk_a edge at which the response is
  registered from Aurora A's RX; instrument = side A's 32-bit cycle counter, per-shot histogram at 1-cycle resolution
  (`evidence/stage3/README.md:46-51`; `rtl/s3/s3_side_a.sv:20-22`).
- Echo mode: side B returns the word through a 1-cycle register instead of the decoder (`s3_side_b.sv:11-13`), so
  echo median - 1 = link round trip. Decode alone = side B counter, constant over every shot (`README.md:52-54`).
- Numbers: decode 6 cycles + 1 = 37.2 ns; echo loop **118 cycles = 732.3 ns** (111 ... 124); decode loop 124 cycles = 769.6 ns
  (silicon, `README.md:60`). d = 5: decode 19 cycles = 117.9 ns, echo 118-119, loop 844-856 ns (silicon, `evidence/stage4/README.md:6, 76-92`).

### 1.3 Breakdown of the round trip (117 cycles = 727 ns) as far as the sources allow
| Part | Cycles one way | ns one way | Label / source |
|---|---|---|---|
| Whole Aurora hop (echo - 1) / 2 | 58.5 | 363 | derived from silicon (`README.md:60, 67`) |
| Aurora protocol-engine logic (TX+RX pipelines) | 46 | 285 | vendor: PG074 "Latency" table (below) |
| Clock compensation (CBCC) | 7 | 43 | vendor: PG074 |
| Gearbox | 1 or 2 | 6-12 | vendor: PG074 |
| PG074 total, default config | 54 or 55 | 335-341 | vendor |
| Remainder = GT TX/RX buffers, PMA/serialiser, cable | ~3.5-4.5 | ~22-28 | derived (363 - 335..341) |
| of which cable | — | ~2.5 | silicon-stated "about 5 ns" round trip (`README.md:67`) |

- PG074 (v13.0, "Latency" page, fetched 2026-11-03: https://docs.amd.com/r/en-US/pg074-aurora-64b66b/Latency): the default
  single-lane latency is "Logic 46 + Gearbox 1 or 2 + Clock Compensation 7 = 54 or 55" user_clk cycles, measured from the
  transmitter user_clk edge of the first TX valid-and-ready to the receiver user_clk edge of the first `m_axi_rx_tvalid`;
  it excludes the serial-link length; "The PE pipeline delay increases as the AXI4-Stream interface width increases."
  The page names the 7-series GTX/GTH and UltraScale/UltraScale+ GTH; GTY is not broken out (**unverified for GTY 64-bit**).
- So **~330 of the 363 ns one way is the Aurora protocol engine plus CBCC, which a thin link removes entirely.** What stays is
  the GT (buffers, gearbox, serialiser: ~22-28 ns derived) and the cable (~2.5 ns).
- Jitter of the loop (13 cycles, even/odd structure): two plesiochronous clocks, the 1-in-33 gearbox pause, clock compensation
  (`README.md:68`). The 1-in-33 pause is PG074's "s_axi_tx_tready ... deasserted for one cycle, once after every 32 cycles" (vendor).
- Not separable from the repo: the per-stage split of the 46 logic cycles, and GT-internal cycles (no link-alone PMA-loopback
  latency was recorded; PMA loopback only showed that the A-to-A path carries all words, `BRINGUP.md`).

## 2. The lab's existing GTY / Aurora material

| Item | What it has | Reusable for Stage 6? |
|---|---|---|
| This repo, `rtl/ip/aurora_a|b/ip_0/aurora_{a,b}_gt.xci` and `.../synth/*gtye4_channel_wrapper.v` | A generated `gtwizard_ultrascale` v1.7 GTYE4 channel config for exactly this card, lane and refclk: 10.3125 G, QPLL1, 161.1328125 MHz, 64B66B gearbox, buffers on. Known-good on silicon (Stage 3/4). | **Yes, best starting point.** Re-create it as a standalone GT Wizard IP (preset GTY-Aurora_64B66B or custom), same locations. |
| `rtl/ip/aurora_a/aurora_a/src/` | Fabric scrambler/descrambler, block-sync SM, reset logic, userclk module (Xilinx-generated, check file headers for licence terms). | Scrambler, descrambler and block-sync SM as references/reuse; CBCC, bonding, init SMs not needed. |
| `synth/constraints/s3_bcu1525.xdc`, `s3_bcu1525_l3.xdc`, `docs/BCU1525.md` | Pin LOCs, refclk periods, QSFP sideband (FS = 10, ResetL, LPMode ...), tested on the desk card. Quad names corrected (cage 0 = quad 231 = X1Y12; the older lab notes have them swapped). | **Yes**, unchanged. |
| `synth/scripts/s3_gen_aurora.tcl` | Scripted IP generation, template for a `s6_gen_gt.tcl`. | Yes. |
| `rtl/s3/*` (`s3_side_a/b`, `s3_regs`, `s3_freq`, `s3_pkg`, `s3_top`) | Shot player, histogram, timestamps, echo/decoder side, JTAG-AXI registers. They talk AXI4-Stream with `tvalid/tready` (TX) and `tvalid` (RX, no tready) at DW = 64 or 192. | **Yes**; the thin link only replaces the Aurora instances with a shim of the same port shape. |
| `sw/bcu/desk.sh`, `s3_measure.cmd`, `s4_measure.cmd`, `sw/analysis/s3_analyze.py`, `tb/tb_s3_loop.sv` | Lock, programming, measurement, analysis, loop sim with behavioural link. | Yes (the sim's link latency parameters need a new value). |
| `claude_ip/ethernet/aurora_64b66b_100g/` (`CLAUDE.md`) | Board-agnostic wrapper, reset sequencer, PRBS traffic gen/checker for **4-lane 25.78 G Aurora**; its status checkboxes are all unticked. | Only the PRBS-31 gen/chk and reset-sequence ideas; not GT configs. |
| `claude_ip/ethernet/VU9P_100G/` | 100G Aurora project (`aurora_100g_link.gen/.../aurora_64b66b_1/ip_0/hdl/gtwizard_ultrascale_v1_7_*` incl. `gtwiz_buffbypass_{tx,rx}.v`, `gtwiz_userclk_*`, `gtwiz_reset.v`); XDC from Corundum (GPL-2) with QSFP0/1 pins and clock pins. Its CLAUDE.md says GT LOCs "TBD" and boxes unticked. | The wizard helper-block sources (buffer-bypass controllers) are generated files of the Aurora IP: a reference for what a bypass wizard instance looks like. Not a raw-GTY design. Do not take its XDC (pin notes are stale; the repo's XDC is the verified one). |
| `claude_project/aurora_uart_test/CLAUDE.md` | 4-lane 25.78125 G Aurora between two BCU-1525 via QSFP28 DAC, MicroBlaze UART control, PRBS-31; reset-sequencer FSM; I2C topology (QSFP module I2C is not connected there; SI570 programming); notes "cage labels swapped" gotcha and "if the link does not come up but loopback works, try the other cage". Calls K11/K10 MGTREFCLK0 and M11/M10 MGTREFCLK1, which disagrees with `docs/BCU1525.md` and with what this project's silicon runs (K11/K10 = MGTREFCLK1). | Lessons only. Trust `docs/BCU1525.md` and the Stage 3 XDC. |
| `claude_ip/ethernet/VU9P_10G` | Empty directory. | No. |
| `fable5_llm` (PCIe card, shared lock) | Not opened beyond the lock rule. | No. |

Result of the search: **there is no raw-GTY (non-Aurora) wizard configuration anywhere in the lab, no buffer-bypass or
fixed-latency GTY example, and no 10.3125 G custom framing.** Every GT instance in the lab is inside an Aurora IP. (My bounded searches of
`claude_ip` and the named `claude_project` subdirectories found only `gtwizard_ultrascale_v1_7_*` files inside the Aurora IP outputs;
a recursive `find` over both trees timed out on NFS and was abandoned. `claude_project/llm_inference/` was not opened.)

## 3. Design options for a thin link on GTYE4 (xcvu9p-fsgd2104-2L-e, Vivado 2024.2)

### 3.0 Sources for GT latency, and what I could not verify
- AMD UG578 (UltraScale Architecture GTY Transceivers User Guide, rev 1.4, 2025-12-19): the page at
  https://docs.amd.com/v/u/en-US/ug578-ultrascale-gty-transceivers loads as a JavaScript shell; the body, and therefore its
  TX/RX buffer-bypass and gearbox sections and any PCS latency table, **could not be read** (WebFetch returned only the title, curl
  returned HTML stubs, section URLs 404). **No UG578 table or section number is cited here because I did not see one.**
- AMD Answer Record 69011 "UltraScale+ GTY Transceiver: TX and RX Latency Values": not reachable (support site returned an error page).
  Its numbers below are quoted **second-hand** from a third-party write-up that cites it
  (https://ttchisholm.github.io/ethernet/2023/05/06/designing-10g-eth-3.html, fetched): values for a **32-bit internal / 32-bit interface width**
  (322.27 MHz at 10.3125 G, 3.1 ns per word), none for 64-bit:
  - synchronous gearbox: TX 6.2-12.4 ns (2-4 cycles), RX 3.1-9.4 ns (1-3 cycles);
  - asynchronous gearbox: about 30 ns TX and about 30 ns RX;
  - PMA buffer, default (not bypassed): TX 7.7-10.9 ns, RX 13.2-17.1 ns;
  - the author's own results: buffer bypass saves about 18-25 ns; a custom fabric synchronous gearbox saves 8.5 ns on average
    against the GTY synchronous gearbox and about 60 ns against the asynchronous one (a loopback histogram, values only for the average).
  All **model** (second-hand), and for 32-bit width; at 64-bit internal width the same stages cost more nanoseconds, because each
  fabric-width stage is one 161 MHz cycle, not one 322 MHz cycle (**unverified**).
- AM002 (Versal GTY) pages seen through search snippets only: buffer bypass gives "low and deterministic" latency when the recovered clock
  sources RXUSRCLK; the TX async gearbox "allows data to be continuously applied every TXUSRCLK cycle" while the sync gearbox needs the logic
  to pause at certain sequence-counter values. That is the Versal part, not UltraScale+ (**vendor, different device**).
- PG182 (UltraScale GT Wizard) "Transmitter Buffer Bypass Controller Helper Block Ports" (fetched): the helper block runs the TX buffer-bypass
  procedure, its clock `gtwiz_buffbypass_tx_clk_in` must come from the same source as TXUSRCLK2 of the master channel, it needs a
  reset pulse after TXUSRCLK2 is stable, ports `..._start_user_in`, `..._done_out`, `..._error_out` (**vendor**). No latency numbers there.

### 3.1 Common elements of any thin design
- Keep the GT Wizard's reset controller and user-clocking helper blocks (they are what brought the Aurora cores up on this card);
  do not hand-roll the GT reset sequence.
- Every serial stream still needs transitions and DC balance: either 64B/66B (header guarantees a transition each 66 bits) **plus a fabric
  scrambler** (x^58 + x^39 + 1, as in the Aurora sources), or raw data scrambled in fabric. A syndrome stream is mostly zeros, so unscrambled raw payload
  is not acceptable for the CDR.
- Frequency: both ends must run at one frequency. The two cages' refclks are different Si5335 outputs (`docs/BCU1525.md`, last bullet of the QSFP table notes), 0.2-0.6 ppm apart
  (**silicon**). Over one 0.18 s Stage 3 run (464,428 shots x 64 cycles) that is ~90 ns, i.e. ~15 words, more than a GT RX buffer holds. A thin link without
  clock compensation therefore needs **both quads on one refclk** (see 3.5), or fabric idle insertion/deletion (a mini CBCC, costs cycles).

### 3.2 Option A — 64B/66B with the GT's internal synchronous gearbox, buffers on (closest to today)
- Same GT settings as the Aurora core (known to bring up on this card). Fabric: 64-bit payload word -> scrambler -> `txdata`, header from `txheader`
  (01 = data, 10 = control), the sequence counter (`TXSEQUENCE`) drives the 1-in-33 pause, as Aurora does. RX: `RXGEARBOXSLIP` block-sync SM
  (reuse `aurora_a_block_sync_sm.v` rule), descrambler, header check. No idle/clock-compensation/channel-bonding/init SMs; idle = header 01 with an
  idle-tag payload; word valid = payload tag, as `s3_pkg` already does (tag A5 / BA).
- Latency (one way, A TX register -> B RX register): fabric TX (scrambler + register, 2 cycles = 12.4 ns) + GT TX (buffer 7.7-10.9 + sync gearbox 6.2-12.4)
  + serialiser/cable (~5) + GT RX (buffer 13.2-17.1 + gearbox 3.1-9.4) + fabric RX (descrambler + register, 2 cycles = 12.4) = **~60-80 ns, plus up to 6.2 ns when a word meets the
  1-in-33 pause** -> ~60-86 ns one way (**model**: second-hand 32-bit numbers, +-15 ns). Round trip ~120-170 ns, loop with the 37.2 ns decoder ~160-210 ns, against 770 ns today.
  This already beats 156 ns one way by a factor of about 2.
- Pros: reuses the proven GT settings, same user clock (161.13 MHz), same side A/B RTL, deterministic framing, d = 5 fits (see 3.6). Cons: the 1-in-33 pause jitter;
  gearbox latency ~10-20 ns.

### 3.3 Option B — raw 64-bit, no gearbox, buffers on
- Wizard: `TX_DATA_ENCODING` RAW, `RX_DATA_DECODING` RAW, user width = internal width = 64. User clock = 10.3125 G / 64 = 161.13 MHz; no header overhead, all 64 bits per cycle, **no periodic pause**
  (removes the 1/33 jitter; the one-in-33 tready logic disappears).
- Needs fabric word alignment: a marker word (e.g. a 64-bit fixed pattern sent as idle) found by a bit-slip search driven by the GT's slide input (`RXSLIDE_MODE` PCS/PMA
  or the fabric-controlled variants), or comma alignment (`ALIGN_COMMA_*`, 10-bit comma patterns are legal in raw mode at some widths). Whether comma alignment
  and slide are both available at 64-bit raw is **not verified** (needs UG578). DC balance by the fabric scrambler (still 1 cycle each side).
- Latency: A minus the gearbox: ~**45-65 ns** one way (**model**). Risk: new alignment scheme and new bring-up behaviour; lock detection is yours.

### 3.4 Option C — Option A or B with TX and RX buffer bypass (phase alignment)
- Requires TXUSRCLK sourced from TXOUTCLK (already the case) and the wizard's TX/RX buffer-bypass helper blocks (PG182, fetched); the RX side then runs on the **recovered
  clock** (RXOUTCLK -> RXUSRCLK, vendor statement in AM002, Versal). Saving, second-hand: ~18-25 ns total (blog), consistent with the buffer rows in 3.0 (TX 7.7-10.9 + RX 13.2-17.1 = 21-28 ns).
- Cost: the received data is in a different clock domain from the transmit user clock (same frequency, fixed arbitrary phase with a shared refclk). A single clock domain per
  side needs either (i) the AM002-style "TXUSRCLK and RXUSRCLK sharing with both buffers bypassed" mode (the Versal manual has it; the UltraScale+ equivalent is **unverified**), or
  (ii) one more crossing inside each side (an async FIFO of 2 words, ~1-2 cycles = 6-12 ns, which eats half the saving and conflicts with the project's single-domain rule).
  Also the side A latency counter spans two clocks, so the stop timestamp would carry a +-1-cycle phase uncertainty.
- Latency: A or B minus ~20 ns: **~25-45 ns** one way (**model**). Worth doing only after the simpler link works; 156 ns does not need it.

### 3.5 Clocking: one clock per side and a shared refclk
- Today: two cores, two refclks (K11/K10 for X1Y48, P11/P10 for X1Y44), plesiochronous; the sides stay in separate domains and Aurora's CBCC absorbs the ppm.
- Proposed (Option A/B): drive **both quads from one refclk** (e.g. K11/K10 = MGTREFCLK1 of quad 231; quad 230's channel X1Y44 takes it as `TX_REFCLK_SOURCE` / `RX_REFCLK_SOURCE` of the form `"X1Y48 clk1"`,
  the format already used in the xci, line 159-160). Adjacent quads can share a reference clock through the north/south refclk routing; this is standard UltraScale+ practice but I **could not check
  the UG578 refclk-distribution rules (unverified)**, and the Si5335 U12 then idles. Result: same frequency in both TX PLLs; the RX elastic buffer sees 0 ppm and needs no clock compensation;
  each side stays in a single clock domain (its own TXOUTCLK) with the GT RX buffer absorbing the fixed phase offset. Each side keeps its own user clock (`clk_a`, `clk_b`), so **no new CDC in fabric**, same
  structure as Stage 3 (separate domains, data only crosses over the cable).
- Fallbacks: (a) keep two refclks and add a fabric idle-insertion CC (a few cycles, ~25-40 ns, still well under 156 ns); (b) frequency-lock the Si5335s (no source in the repo that says this is possible).
- A second card (desk + PCIe card) would be plesiochronous by construction and needs (a).

### 3.6 Word formats: d = 3 (24-bit) and d = 5 (120-bit)
- d = 3: `s3_pkg` word {tag A5 (8), seq (24), ..., echo flag, det[23:0]} fits one 64-bit payload unchanged (`s3_side_b.sv:46-49` needs N_DET + 1 < DW - 32). The correction is one flip bit in the same word.
- d = 5: 120 detectors + echo + 8-bit tag + 24-bit seq = 153 bits. Options:
  1. 3 lanes (192 bit) as Stage 4, but with no bonding: each lane has a fixed bring-up-dependent word skew (<= 1 cycle in Stage 4, `evidence/stage4/README.md:88`), so add a per-lane tag/marker deskew (+0-1 cycle).
  2. **Two words on one lane**: word 0 and word 1 of one shot; with Option A the 2-bit header distinguishes first/second (01 / 10 are both legal data headers), so no payload bits are spent on framing. Cost +1 cycle (6.2 ns, derived), simplest bring-up (1 lane). Seq/tag in word 0, det[119:...] in both.
  3. 2 lanes x 64 = 128 bits is one bit short once tag and seq are kept, so it needs a shorter seq.
- Correction word returns as one 64-bit payload (flip + seq + tag) in all cases.

### 3.7 Line rate and cable
- The QSFP+ 40G DAC is rated for 4 x 10.3125 Gb/s (`PLAN.md:171-172`, user-confirmed in `NEXT_SESSION.md`); a passive DAC at 25.78 G was never tried here and is not a vendor-rated use of a QSFP+ cable.
  A **higher rate would not be needed**: serialisation time of a 64-bit word is 6.2 ns at 10.3125 G, and the dominant terms are fabric and GT stage counts, not line rate.
- 32-bit internal width (322.27 MHz user clock) would halve each word-wide stage (3.1 ns instead of 6.2 ns), saving roughly 4 x 3.1 ns ~ 12 ns, but the decoders close at 161 MHz (`PLAN.md` D-S3-CUT; d = 5 needs broadcast registers), so a 2:1 clock ratio would add a domain or a rate-change, against the single-domain rule. Not recommended.

### 3.8 Summary of options (one way; **model**, not measured)
| Option | GT config | Fabric | Expected one-way | Notes |
|---|---|---|---|---|
| Aurora today | 64B66B sync gearbox, buffers on | PE + CBCC (53 cycles) | 363 ns (**silicon**) | baseline |
| A | 64B66B sync gearbox, buffers on | scrambler, block sync | ~60-86 ns | lowest risk |
| B | RAW 64, buffers on | scrambler, marker/slide align | ~45-65 ns | alignment scheme new |
| C | A or B with both buffers bypassed | + helper blocks, RX on recovered clock | ~25-45 ns | clock-domain crossing issue |

## 4. Recommendation

**Stage 6a = Option A on a shared refclk, one lane, d = 3 first.** It removes ~330 of the 363 ns/hop that PG074 attributes to the Aurora engine, lands near 60-90 ns/hop (model),
and keeps every proven piece: GT settings, pins, user clock, `s3_side_a/b`, measurement harness. 156 ns is beaten by ~2x without bypass, bit-alignment search or new clocking tricks.
Options B and C are Stage 6b (only if a lower floor is wanted).

Steps
1. `synth/scripts/s6_gen_gt.tcl` (clone of `s3_gen_aurora.tcl`): GT Wizard IP, one channel per core (X1Y48, X1Y44), preset GTY-Aurora_64B66B, 10.3125 G, 161.1328125 MHz, QPLL1, reset controller and user-clocking in core,
   `TX/RX_REFCLK_SOURCE` both = MGTREFCLK1 of quad 231; compare the generated wrapper with `aurora_a_gt_gtye4_channel_wrapper.v` line by line (buffers, gearbox, widths) so the only differences are the intended ones.
2. `rtl/s6/thin_link.sv`: scrambler, `TXSEQUENCE` counter and tready pause, header, RX block-sync SM, descrambler, idle/valid by tag; AXI4-Stream shim with the same ports as the Aurora cores (`s_axi_tx_*`, `m_axi_rx_*`), so `s3_top.sv` selects Aurora or thin by a parameter.
3. Verilator: behavioural gearbox model is already in `tb/tb_s3_loop.sv`; replace the Aurora latency model by the thin-link cycle counts; both clock orientations; bit-exact on the full 464,428 vectors before any bitstream (project rule).
4. Build via `launch_s3.sh` pattern; the same gated `s3_bitstream.tcl`.
5. Silicon, **measured exactly as Stage 3/4**: same `s3_measure.cmd`/`s4_measure.cmd`, same side A counter (TX accept edge -> RX register edge, clk_a), echo mode first (link round trip = echo median - 1), then decode mode, GAP 63 and 7, 15 runs per build, histograms analysed by `s3_analyze.py`.
   First also a PMA-loopback echo (`BRINGUP.md` flow) to separate link-only latency; report cycles **and** ns with clk_a measured against init_clk.
   Pass line: one-way = (echo median - 1) / 2 cycles x 6.206 ns **< 156 ns**, i.e. an echo median below ~51 cycles (today 118); expected 20-28 cycles.
   Also report max/jitter (the 1-in-33 pause adds up to 1 cycle) and the loop median with the d = 3 decoder (expect ~160-210 ns, was 769.6 ns).
6. d = 5 on the same link with the two-word scheme (3.6 option 2), Stage 4's decoder unchanged; expected loop ~ +118 ns decode.

Risks
- **Latency numbers are second-hand.** UG578 and AR 69011 could not be read; confirm from silicon (PMA-loopback echo) before quoting any GT-stage figure. If UG578 is made available,
  fill in Sections 3.0/3.3/3.4 (comma alignment and slide in raw 64-bit, shared-clock bypass mode, refclk distribution).
- **Shared refclk across quads** may need a different refclk-source choice than assumed (unverified); fallback is a fabric idle-insertion CC (3.5a).
- **Bring-up and cable**: Stage 3's first load had lane_up = 0 until the DAC was reseated (QSFP0 ModPrsL = 1, `BRINGUP.md`). Expect the same sensitivity; keep the near-end PMA loopback path in the build
  (`board_ctrl[2:0]`, `[6:4]`). The reset order (pma_init held 1.34 s, then reset_pb) is the Aurora example's; the wizard's own controller replaces it, so retest. Block-lock time is sub-microsecond once the GT is up (model).
  Desk card only, through `sw/bcu/desk.sh`, with its own lock; never the PCIe card; JTAG volatile loads only.
- **Scrambler/CDR**: the zero-heavy syndrome stream must be scrambled; test with an all-zero shot stream and a PRBS stream, plus the negative controls used in Stage 3 (corrupted flip caught).
- **Jitter spec**: the 1/33 pause means the latency spread is not zero; the report must say so.
- **Reuse of Xilinx-generated Aurora sources** (scrambler, block sync): check headers; keep the repo's NOTICE honest (Apache-2.0 project; Xilinx IP files stay as generated IP, not relicensed).
- **Licence (build-host Vivado, this is relevant: every xcvu9p build runs there).**
  - Evidence the VU9P build used the System Edition eval: the Stage 4 bitstream log of 2026-10-29 says "Got license for feature 'Implementation' and/or device 'xcvu9p'" and "expires in 9 day(s)"
    (`evidence/stage4/build/s4b_lc3bc_Default_bitstream.txt:79-81`), i.e. 2026-11-07, matching `CLAUDE.md:80-82` (System Edition eval 07-Nov, ML Enterprise 26-Nov). Today is 2026-11-03: **4 days left on that entry.**
  - I listed feature names and dates (not keys) of `~/.Xilinx/*.lic` on build-host, read-only: `Xilinx_RE_2026.1.lic` carries `Vivado_ML_Enterprise_Edition` (and Enterprise_Package) to 26-nov-2026;
    a file `Xilinx_eval_20261102.lic`, dated yesterday, carries `Vivado_System_Edition_Eval` to **18-dec-2026**. I did not check which file Vivado actually checks out (run `report_license`/a short `write_bitstream` on build-host to see the new "expires in N days" line).
  - Which covers xcvu9p: both are all-device editions by their names (an eval System Edition and the ML Enterprise edition), and the eval entry demonstrably did for xcvu9p on 2026-10-29. I did not test ML Enterprise on xcvu9p (**unverified**).
    The GT Wizard IP and Aurora 64B/66B need no separate IP licence to my knowledge (**unverified**); the evaluation-core warning in NEXT_SESSION item e belongs to the X310 10G PCS/PMA, not to GT wizard.
  - Plan the builds (a handful of 15-30 min implementations) inside the 18-Dec window; if the 07-Nov entry is the one in use, build before it ends.

## 5. What I read
- Repo: `CHARTER.md`, `docs/BACKGROUND.md`, `docs/PLAN.md` (B.2-B.4), `docs/BCU1525.md`, `rtl/s3/s3_top.sv`, `s3_side_a.sv`, `s3_side_b.sv`, `synth/scripts/s3_gen_aurora.tcl`, `evidence/stage3/README.md`, `evidence/stage3/silicon/BRINGUP.md`, `evidence/stage4/README.md`,
  the Aurora IP xci and generated wrappers under `rtl/ip/aurora_a/`, `NEXT_SESSION.md`, `CLAUDE.md`.
- Lab: `claude_ip/ethernet/aurora_64b66b_100g/CLAUDE.md`, `claude_ip/ethernet/VU9P_100G/CLAUDE.md` and XDC head, `claude_project/aurora_uart_test/CLAUDE.md`, the photon-timing report lines cited.
- Web (fetched 2026-11-03): PG074 Latency page; PG182 TX buffer bypass helper block page; ttchisholm.github.io 10G-Ethernet-on-GTY write-up (cites AR 69011); AM002 Versal GTY pages as search snippets only; UG578 landing page (no body).
- The Vivado doc-search MCP tools failed on every call ("additional properties 'top_k' not allowed"), so no UG578/PG-number lookup came from there.
