# opus_nsinfer — sub-microsecond NN loops, measured on the lab's boards

A bit-exact HGQ2 → da4ml → Verilator → Vivado → silicon flow, with three artifacts:
A, a jet-substructure MLP on a ZCU102 (pin to pin); B, a neural surface-code decoder in
a loop over a GTY link on a BCU-1525; C, a waveform classifier inside a USRP X310.
Contract: `CHARTER.md`. Decisions: `docs/PLAN.md`. Method: `docs/MEASUREMENT.md`.
One-page summary: https://coreyhahn.github.io/opus_nsinfer/ (`docs/index.html`).

Every figure carries a label: **silicon** (measured on the board), **sim**,
**model** (Vivado timing or OOC P&R), **derived** (computed from silicon counts
with stated model terms).

## Key figures

| Figure | What it is | Label |
|---|---|---|
| **47.6 ns** | JSC MLP on the ZCU102, input pad to decision pad, median at 300 MHz | derived from silicon counts |
| **37.2 ns** | d = 3 surface-code NN decode on the BCU-1525 (6 cycles at 161 MHz) | silicon |
| **117.9 ns** | d = 5 surface-code NN decode at II = 1 (19 cycles at 161 MHz) | silicon |
| **292 ns** | d = 3 decoder loop (syndrome out, link, decode, correction back) over our thin 64B/66B GTY link with the TX buffer bypassed, median (Aurora: 769.6 ns) | silicon |
| **410–422 ns** | d = 5 decoder loop over 3 lanes of the thin GTY link, medians over 4 vector sets (Aurora: 850 ns, worst of 2.36 M shots 943 ns) | silicon |
| **155–330 ns** | X310 waveform classifier: pulse onset at the classifier's input to its first correct decision, median at SNR ≥ 10 dB (BPSK 155 / LFM 175 / CW 330), on the live 200 MS/s ADC stream | silicon decisions + 22-cycle pipeline (sim) |
| **91.5 % / 98.4 %** | X310 classifier accuracy on its own TX→RX loop, class-balanced / SNR ≥ 10 dB, 23.8 M windows, fresh TX seeds; BPSK 88.2 % (model: 91.1 / 98.2; v1 before the channel fix: 81.8 / 97.4, BPSK 65.5) | silicon |
| **0** | decision mismatches against Keras: 166,000 JSC vectors on silicon, 524,288 d = 5 vectors on silicon, 84 M (v1) + 84 M (v2) X310 decisions on silicon against the RTL replay, 17.5 M in Verilator | silicon / sim |

## A. Jet-substructure MLP on the ZCU102 — pin-to-pin latency (Stage 1)

HGQ2 JSC 16-64-32-32-5, 76.74 % test accuracy over the full 166,000-jet test
set (77.08 % for the float64 model), da4ml distributed-arithmetic RTL, 0 DSP.
Device: **xczu9eg-ffvb1156-2-i ES2 silicon** (board "zcu102"), Vivado 2024.2.

| F_net | OOC prediction, network only (model) | **Pin-to-pin L_pp median (derived from silicon)** | min … max | bit-exact on silicon |
|---|---|---|---|---|
| 200 MHz | 35.0 ns (7 cycles) | **55.2 ns** | 52.7 … 57.7 ns | 166,000 × 4 orders × 2 runs, 0 mismatches |
| **300 MHz** | 33.3 ns (10 cycles) | **47.6 ns** | 45.9 … 49.3 ns | same, plus 8 more runs after a reprogram |
| 500 MHz | 54.0 ns (27 cycles) | **65.7 ns** | 64.7 … 66.7 ns | same |

- **Start event:** IN_VALID rising at the package pad of PMOD pin A20. **Stop
  event:** DEC_VALID rising at the package pad of pin D20.
- **Instrument:** on-chip counters plus an MMCM phase sweep over one full
  period (12–15 ps steps). Each pad is driven and read back at its own buffer,
  with no oscilloscope. The min…max spread is one clock period: it is the
  wait of an asynchronous input for the capturing edge.
- **Model terms:** two fabric anchor delays, bracketed by Vivado corners, which
  makes the L_pp uncertainty ±0.35 ns, plus a 0.02–0.10 ns output-buffer
  difference.
- **Excluded:** the 150-bit feature vector does not cross pins (it is
  staged on-chip). The ZCU102 has no free HP pins without an FMC card, so the
  strobe is the last input event. Board traces beyond the pads are also excluded.
- **Comparison:** the published HGQ+DA JSC figure (76.9 %, 23.4 ns, 11,978
  LUT, XCVU9P) is **OOC P&R only** (register to register, no I/O). Our OOC
  figure for the same flow on the ZU9EG is 33.3 ns at 300 MHz. Silicon adds
  about 14 ns at 300 MHz:
  - the HD input and output buffers, about 2.7 ns together (the measured pad
    loop d_B);
  - on average half a period waiting for the capturing edge;
  - three harness cycles: the readback flop, the synchroniser and the
    DEC_VALID flop;
  - the argmax.

Evidence and the per-sweep tables: `evidence/stage1/README.md`. Stage 0 (flow,
golden vectors, OOC sweep on ZU9EG and VU9P): `evidence/stage0/README.md`.

## B. NN surface-code decoder over GTY (BCU-1525) — d = 3 (Stage 3) and d = 5 (Stage 4) on silicon

**Stage 4 (2026-10-29): the d = 5 decoder loop at II = 1 on BCU-1525 silicon.**
- **Network and code:** a 120-192-96-96-1 HGQ2/da4ml MLP (933,465 EBOPs) decodes Stim `rotated_memory_z`, d = 5, 5 rounds. It runs at the 161.13 MHz GTY user clock, one syndrome per cycle. Syndromes (120 bits) and corrections cross three bonded 10.3125 Gb/s Aurora 64B/66B lanes over the QSFP+ DAC.
- **Bit-identical to Keras on silicon:** 4 vector sets of 131,072 held-out vectors (524,288), each run at least twice without reprogramming: 27 runs, 27 PASS, with MISR equal to the sim signature per set. Verilator matches on all 17,517,776 distinct test vectors.
- **Decode alone (silicon, side B on-chip counter, RX register → TX FIFO write, constant on every shot):** **19 cycles = 117.9 ns**.
- **Loop (silicon, side A counter, TX accept → RX register; excludes syndrome generation and qubit-controller pins):** median **844–856 ns** per run (136–138 cycles). The worst shot over all runs is 943.3 ns. The Aurora round trip (echo mode) is 726–732 ns of it.
- **LER (sim on 5×10^6 test shots per p; hardware-equal, derived):** NN / PyMatching = **0.986 at p = 0.1 %** rising to **1.523 at 1 %** (0.1 %: 1.29e-4 vs 1.30e-4).
- **The price of II = 1 at 161 MHz.** The most accurate d = 5 core (3.58M EBOPs, NN/PM 0.833 … 1.269) does not route on the VU9P (model: OOC P&R). None of the larger probes (1.53M, 1.71M, 1.92M EBOPs) met 6.206 ns either.
  - The fix that closed timing: a pure register on each all-to-all layer input (4 cycles, 24.8 ns). Each layer's output broadcast was the critical path, at about 95 % route delay.
  - The selection rule records the bound and the choice (`docs/PLAN.md` D-S4-SEL).

Evidence: `evidence/stage4/README.md`.


**Stage 3 (2026-10-23): the d = 3 decoder loop on BCU-1525 silicon.** Syndromes cross a 10.3125 Gb/s Aurora 64B/66B GTY link over a QSFP+ DAC (QSFP0 → QSFP1), the decoder runs at the 161.13 MHz GTY user clock, and corrections return over the same cable.
- **Bit-identical to Keras on silicon:** all 464,428 held-out vectors, 10 decode runs over 3 builds (0 mismatches; MISR equals the sim signature). The hardware LER is therefore exactly the Stage 2 table (derived).
- **Decode alone (silicon, on-chip counter, lc8):** **6 cycles = 37.2 ns**; 31.0 ns at lc12.
- **Loop (silicon, side A counter, TX accept → RX register, median of 464,428 shots):** **769.6 ns** (124 cycles; min 726 ns, max 807 ns). Of that, the Aurora round trip (echo mode) is about 727 ns. Decode − echo equals the decoder depth at 5, 6 and 8 cycles.
- **Against the published figures:** 124 ns decode and 550 ns loop, hardware-measured on a Kintex-7 (arXiv 2605.04892). Our decode is 3.3× shorter; with Aurora our loop is longer because of the link. **Stage 6 (silicon):** a thin custom 64B/66B GTY link on one clock replaces Aurora: one way 124–155 ns over every probe word of every run (published custom link about 156 ns, second-hand), 112–130 ns with the TX buffer bypassed; loop median **335 ns at d = 3** (**286–292 ns** with the TX buffer bypassed) and **410–422 ns at d = 5** over all four vector sets (Aurora: 769.6 / about 850 ns), bit-exact (`evidence/stage6/README.md`).

Evidence: `evidence/stage3/README.md`.


**Stage 2 (2026-10-20): the d = 3 decoder in simulation.**
- **Circuit and decoders:** Stim rotated surface-code memory, d = 3, 3 rounds, uniform circuit-level noise p = 0.1–1 %. The NN is a 24-128-64-32-1 HGQ2/da4ml MLP (30,258 EBOPs) with flip = logit > 0; it is compared against PyMatching.
- **LER (sim, 10^7 held-out test shots per p):** NN/PM = 0.854 at p = 0.1 %, with the advantage narrowing as p rises: 0.892, 0.911, 0.947, 0.969, 1.000 at p = 1 %.
- **Bit-exact in Verilator:** 0 mismatches over 464,428 distinct test vectors × 8 runs, and over all 2^24 inputs, at 3 pipeline depths.
- **Decode latency (model, OOC P&R on xcvu9p-fsgd2104-2L-e, network only, register to register):** **8 cycles at 270 MHz = 29.6 ns**, or 12 cycles at 390 MHz = 30.8 ns; about 16k LUT, 0 DSP.
  - Start: the edge that captures the detection word. Stop: the flip register.
  - Excludes: link, pins and syndrome extraction.
  - Published reference: 124 ns, hardware-measured, Kintex-7 (arXiv 2605.04892). Not like for like until Stage 3 measures it in the GTY loop.

Evidence: `evidence/stage2/README.md`.

## Against the published figures

Every row is a different device and workload. "Measured" means on hardware; "OOC" means out-of-context place and route (register to register, no I/O).

| What | Published | Their device, status | Ours | Our device, label |
|---|---|---|---|---|
| HGQ + DA JSC MLP | 76.9 %, 23.4 ns, 11,978 LUT; 75.9 %, 12.1 ns at 200 MHz | XCVU9P, **OOC only** | 76.74 %; 33.3 ns OOC, **47.6 ns pin to pin** | ZU9EG ES2: model / derived from silicon |
| NN decoder, decode | 124 ns, d = 3 | Kintex-7 XC7K410T, measured | **37.2 ns** d = 3; **117.9 ns** d = 5 at II = 1 | VU9P, silicon |
| NN decoder, loop | 550 ns, d = 3 | Kintex-7, measured | **292 ns** d = 3 (TX buffer bypassed; 335 ns with it), **410–422 ns** d = 5 (medians, 4 vector sets; thin GTY link, Stage 6); with Aurora 769.6 / 850 ns | VU9P over DAC, silicon |
| Graph decoder loop | 446 ns, d = 3 | 3× ZCU216, measured (emulated measurements) | — | — |
| Link cost | Aurora 64B/66B about 450 ns one way | vendor / derived | about 363 ns one way (726 ns echo round trip / 2) | 1- and 3-lane Aurora, silicon |
| RF waveform classifier, sample to decision | "hundreds of nanoseconds" (Navy STTR DON26TZ05-NV023); AMC CNN about 8 µs | RFSoC, **a requirement, not a measurement**; ZCU111, published | **155–330 ns** onset at the tap → valid decision (median, SNR ≥ 10 dB); ~315–490 ns from the ADC input; ≤ 425 ns for a full window | XC7K410T in an X310: silicon + sim; ADC/front-end part derived |

- **Decode:** at d = 3 our hardware decode is 3.3× shorter than the published one. At d = 5 (120 detectors, five times the d = 3 input) it is still under the published d = 3 figure.
- **Loop:** with Aurora our loop was longer than the published 550 ns, and the difference was the link: the Aurora round trip alone is 726–732 ns; the decoder adds 37 ns at d = 3 and 118 ns at d = 5. The Stage 6 thin GTY link (64B/66B, GT gearbox and buffers, one shared refclk and one clock) cuts the round trip to 291.7 ns, so the loop is 335 ns (d = 3) and 410–422 ns (d = 5), below the published 550 ns. About 100 ns of each one-way trip is the GTY's own PCS; going lower needs a second clock (a 32-bit GT width or RX buffer bypass). d = 5 is bit-exact on all four vector sets over the thin link (12 runs, medians 409.6–422.0 ns). With the GTY's TX buffer bypassed (still one clock, d = 3) one way is 112–130 ns and the d = 3 loop 286–292 ns.
- **Classifier:** a 4-class pulse classifier (noise, CW, LFM, BPSK), not modulation classification; the CNN row is a different task. The X310 latency is from the X310's own timestamps (the radio's time counter carried with every decision).
- **Accuracy:** the d = 5 network at II = 1 is up to 1.5× worse than PyMatching at p = 1 %; at d = 3 it was 0.85–1.00. Published NN decoders are not measured on our syndromes, so there is no accuracy row.

## Reproduce

`sw/reproduce.sh <stage>` (0–5, or `all`) re-derives each stage's numbers from the committed frozen models and golden vectors:
- regenerated RTL is checked byte-identical;
- the Verilator gates are rerun;
- for the silicon stages it prints the build, bitstream and run commands and re-analyses the committed silicon logs.

Each `evidence/<stage>/README.md` lists its commands.

The scripts were written for this lab: a Vivado 2024.2 install on a shared file server, a build host reached by `ssh`,
and the boards' JTAG cables by serial number. To run them elsewhere, set the Vivado `settings64.sh` path in the
`synth/scripts/launch_*.sh` launchers, the host names in the `ssh` lines of `sw/`, and the cable serials in `sw/bcu/` and
`sw/x310/`. `tb/Makefile` finds the repository from its own location. In the public copy, the logs under `evidence/`
and `docs/` show lab paths as `<repo>`, `<lab-share>` and `<xilinx-tools>`, host names by role (`build-host`, `desk-pc`,
`train-host`, `zcu102`), and cable and board serials as placeholders.

## C. X310 waveform classifier on the live ADC stream (Stage 5)

A quantized classifier inside an RFNoC block of the USRP X310's image, between the radio's ADC front end and the stock
radio block, classifying every 200 MS/s sample's 64-sample window into noise / CW / LFM / BPSK at II = 1, on the radio
clock. The X310 generates its own signal set: RF A TX/RX → 30 dB attenuator → RF A RX2 (two UBX-160 boards, 1 GHz).
Details: `evidence/stage5/README.md` (classifier), `evidence/stage5/block/README.md` (block, image),
`evidence/stage5/silicon/README.md` (v1 silicon), `evidence/stage5/v2/README.md` (v2, the current classifier).

- **Network (v2, the current image):** HGQ2 MLP 128-96-48-24-4 on a block-floating-point window, da4ml RTL, 24.8k LUT
  and 0 DSP in the image; the X310_XG image with it closes at 200 MHz (WNS +0.011 / WHS +0.003 ns) with Vivado 2024.2.
  It is trained on the X310's **measured** receive channel. The first model (v1) assumed a ±20 MHz analog low-pass; the
  real path is flat to about ±80 MHz with white noise, which made rectangular BPSK look like noise (65.5 % on silicon).
  A simulation through the measured response and real noise reproduced the silicon numbers class by class; the fix
  measures the channel (`ref/x310/channel_x310.py`) and retrains (`evidence/stage5/bpsk/README.md`, PLAN.md D-S5-CH).
- **Bit-exact on silicon:** the block's on-chip MISR over every decision of every capture equals a Verilator replay of
  the captured samples through the RTL: v2 20 captures, 84 M decisions (v1 the same), 0 mismatches; for v1, flipping
  one sample bit or shifting the replay by one sample fails, as it must (silicon vs sim).
- **Accuracy (silicon, v2, 8 captures on fresh TX seeds, 23.8 M labelled windows, labels from the TX schedule):**
  **91.5 % class-balanced, 98.4 % at SNR ≥ 10 dB**; the model on its measured-channel test set: 91.1 % / 98.2 % (float
  93.9 / 99.2). Per class: noise 98.3, CW 92.6, LFM 86.9, **BPSK 88.2 %** (model 97.1 / 91.3 / 88.3 / 87.7). On the
  same TX schedules as v1: 91.4 / 98.3 (v1 81.8 / 97.4, BPSK 65.5). Noise-only false alarms: 1.70 % of decisions (v1
  0.14 %), in runs of at most 29 decisions, so a K = 16 hysteresis gives about 100–200 events/s on noise.
- **Latency.** All of it is counted in 200 MHz radio-clock cycles from the X310's own sample timestamps.
  - **Pipeline (sim, read back from the block on silicon):** 22 cycles = 110 ns (v1 19), from the clock edge that
    captures the window's newest sample at the block's input to the edge after which its decision is on the outputs.
  - **Detection (silicon):** from a pulse's first sample at the block's input to the first decision of its class, then
    + 22 cycles until that decision is valid. The median at SNR ≥ 10 dB is **155 ns (BPSK), 175 ns (LFM) and 330 ns
    (CW)** (v1 150 / 170 / 225), and 100 % of those pulses were detected. Under a fully filled window, the decision is
    valid at most 425 ns after the onset.
  - **Before the block (derived):** about 160 ns from the ADC input, so about 315–490 ns from the ADC input to the
    decision. The ADC part is from the datasheet and RTL, not measured.
  - **Loop (silicon):** the X310's TX→RX loop delay is 668.5 ns.
- **Labels and limits:**
  - A DC step at every TX burst start is removed by keeping the transmitter on for 31.5 ms before the signal set (silicon README §0).
  - The smoothed class-change events work on silicon (sequence and drop counters clean; v1 975 of 975, v2 2,164 of 2,164 in-window events equal the replay). The first image sent one record per packet, which at dense pulse rates exceeded what the host could take (about 10⁶ packets/s). The current image (event revision) packs up to 16 records per packet and starts with events off; at dense pulse rates every record arrives (40,567 of 40,567 in-window events equal the replay; `evidence/stage5/evt/README.md`).
  - The captures (203 MB) are not committed; their hashes are.
