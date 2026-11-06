# Background: sub-microsecond inference, the numbers, the boards

Condensed technical brief. The full report with its sources is
`<lab-share>/fpga/future_fpga_inference_designs/reports/FPGA microsecond latency inference.md`;
its notes are in `research_notes/FPGA microsecond latency inference/`
(`us_inference_techniques_tools.md`, `us_inference_application_domains.md`,
`gapfill_technical.md`, `gapfill_market.md`). Read the report's sections
"Fully unrolled, LUT-only networks now finish in 2 to 6 cycles",
"Bit-exact agreement is engineered into the training graph", "A 3 µs GPU
floor splits the field at the converter", "Qubits, triggers and RF set the
hardest budgets" and "Openings for this reader" before Stage 0. The QEC link
figures come from the sibling report
`FPGA photon timing and quantum readout.md` in the same folder.

## 1. Where the field stands

- **The network is no longer the bottleneck.** With weights baked into the
  fabric, an MLP closes at II = 1 in 2–6 cycles, 5–25 ns, a few hundred to a
  few thousand LUTs, no DSPs, on UltraScale+ [OOC P&R]. HGQ learns each
  weight's and activation's bit-width with a surrogate gradient; most
  weights end at zero bits. hls4ml's Distributed Arithmetic strategy
  (da4ml) emits each constant matrix-vector multiply as a shift-and-add
  adder graph directly as RTL, no HLS compile in the loop, RF = 1 only.
- **Faster clocks lose.** The same JSC models at 694–756 MHz on a VU9P take
  21 cycles = 27.8 ns against 12.1 ns at 200 MHz. Wall-clock is lowest at
  200–400 MHz with 2–6 stages. The clock should follow the data clock.
- **Bit-exactness is engineered, not hoped for.** da4ml RTL matched Keras
  bit for bit in Verilator in >99.5% of models; every mismatch traced to
  float32 accumulators of 23+ bits. Recipe: train in float64 or keep
  accumulators under 23 bits; WRAP with offline range calibration or SAT;
  precision propagation on; run the emitted Verilog against the golden model.
- **The path to the fabric is the cost.** PCIe on a V80: 0.89 µs mean with
  MMIO input, 1.45–1.47 µs with DMA buffers (Myrtle). A GPU loop measured
  by NVIDIA: 2.80/2.92/4.43 µs min/median/max transport-only over RoCE,
  3.65/3.76/4.28 µs with a persistent kernel; Quantum Machines about
  3.5 µs, Diraq 3.3 µs. Budgets of 5 µs and above are GPU-contestable;
  sub-µs budgets are not. The NN belongs in the same clock domain as the
  converter or detector link.
- **Nothing in the ns class has been measured through its I/O.** Every 2026
  LUT-native result is post-P&R. That is Artifact A's gap.

## 2. Artifact A: the measured HGQ/da4ml network

Workload: the hls4ml HLF jet-substructure classifier (JSC): 16 input
features, 5 jet classes, the benchmark every paper above uses, so your
accuracy and LUT counts are directly comparable. Published reference
points on the XCVU9P [OOC P&R]: HGQ+DA 75.9% at 3 cycles / 12.1 ns /
2,891 LUT / 651 FF / 0 DSP at 200 MHz; HGQ with retiming 73.2% at
6 cycles / 9.1 ns / 366 LUT; LogicNets 71.8% at 37,931 LUT, 427 MHz,
under 15 ns; NeuraLUT-class about 1,780 LUT at 940 MHz; TreeLUT about 75%.

What "I/O-inclusive" must mean here: the clock starts when the last input
bit is valid at a package pin (or at the GTH/LVDS receiver's parallel
output, stated) and stops when the decision is valid at a package pin. The
network's 2–6 cycles will be a minority of that number; the deserialiser,
the input register path and the output path are the rest, and reporting
them separately is the contribution. Candidate input paths on the ZCU102,
to be chosen in `docs/MEASUREMENT.md` after reading UG1182: parallel LVDS
on FMC or PMOD from a pattern source; a 10 GbE SFP+ frame carrying one
sample vector (the lab has 10G Ethernet IP for VU9P in
`claude_ip/ethernet/VU9P_10G`; port cost is yours); an on-chip generator
as the fallback, labelled as excluding the pin path. Instrument: an
oscilloscope or logic analyser on the input strobe and output pin if the
user has one; otherwise on-chip timestamp counters at the pin registers,
with the IOB delays taken from the timing report and labelled derived.

## 3. Artifact B: the NN decoder loop

Surface code, distance d, one syndrome round = d² − 1 stabiliser bits
(8 at d = 3, 24 at d = 5); a decoder maps rounds of syndromes to a
correction (or a logical-flip bit). Reference decoder: minimum-weight
perfect matching (PyMatching) on syndromes sampled from a Stim circuit at a
stated physical error rate and noise model. Report the NN's logical error
rate next to PyMatching's on the same held-out syndromes at the same rate.

Published loops to beat, all hardware-measured: the 2026 NN decoder at
d = 3, **124 ns decode inside a 550 ns loop** on a Kintex-7 XC7K410T
(arXiv 2605.04892); RISC-Q's graph decoder, **446 ns** from syndrome
aggregation to error distribution across three ZCU216s with emulated
measurements (arXiv 2603.16203). Throughput references: Helios 11.5 ns per
round to d = 21 on a VCU129 (Yale, IEEE TQE 2024, arXiv 2406.08491); IBM
Relay-BP 24 ns per iteration on a VU19P (synthetic syndromes); Riverlane
Collision Clustering 810 ns per round on an FPGA, 240 ns on its ASIC; Google
Willow decoded d = 5 in software at 63 µs average against a 1.1 µs cycle.
The loop's cost is the link: Aurora 64B/66B is about 450 ns one way against
about 156 ns for a custom link (photon-timing report), so a 124 ns decode
sits inside a link-dominated loop. Measure the link alone first (loopback
with a timestamp), then the decode alone (on-chip counters), then the loop.

On the BCU-1525: the GT prototype of the CMS Global Trigger ran 24 NNs, 8
per SLR, at 240 MHz with 4-bit weights and no DSPs on a VU9P, so a d = 5
decoder at II = 1 is well inside the part. Keep the decoder and its
accumulators in one SLR with the GTY it talks to.

Link options for the loop, in order of preference: (1) the lab's Aurora
100G design looped cage 0 → cage 1 on the same card with a QSFP28 DAC
cable (one card, real serial hop, real Aurora latency); (2) two cards
(needs the second BCU-1525 installed and a host for it); (3) a thin custom
GTY link with minimal framing (stretch, the 156 ns target). Option (1)
needs the cable: ask at Stage 0.

## 4. Artifact C: the Navy budget on the X310

Navy STTR DON26TZ05-NV023, "Detection and Classification of Low
Probability of Intercept radar waveforms using FPGA with Cognitive
Techniques": an AMD RFSoC inside a DRFM, "the latency should be on the
order of hundreds of nanoseconds", Phase II delivers HDL and tests at
NAWCWD Point Mugu. Academic automatic-modulation-classification CNNs on a
ZCU111 reach about 8 µs at 488k classifications/s (UCSD ternary CNN);
DeepSig's OmniSIG is CPU/GPU software with no published latency. Nothing
public meets the budget.

The X310 is the right rehearsal part: its XC7K410T is the decoder paper's
device, its ADCs run at 200 MS/s (14-bit) and DACs at 800 MS/s, and the
lab already has an RFNoC build flow with custom blocks (`<lab-share>/fpga/ettus/`).
Plan: define a small waveform set (LFM chirps, Barker-coded pulses, CW,
noise) generated by the X310's own TX and looped to RX through an
attenuator; a short-window quantized classifier through the same HGQ2/da4ml
flow inside an RFNoC block on the radio clock; latency from RFNoC
timestamps and an on-chip counter from the first ADC sample of the window
to the decision. Blockers: Vivado (upstream pins 2021.1; 2024.2 works with porting edits, PLAN D-S5-TOOL, 2026-10-29),
X310 reachability (10.0.10.2, host unverified), a loop cable. The X310
image loader writes flash; the lab's JTAG script is the volatile path.

## 5. Budgets by domain (from the report; FPGA-mandatory rows in bold)

| Domain | Budget | Achieved / state | FPGA mandatory? |
|---|---|---|---|
| **Qubit readout** | tens of ns inside a ~1 µs QEC cycle | 26.7–50 ns, 42K params, ZCU111; lab demos only | yes, ADC-adjacent |
| **QEC decode + feedback** | ~1 µs rounds | 446 ns graph, 550 ns NN (d = 3); Riverlane ASIC 240 ns | yes |
| **CMS L1 trigger** | 50–81 ns per algorithm; ~1 µs GT; 12.5 µs total | AXOL1TL, CICADA running; GT NNs hardware-tested | yes, 40 MHz fixed latency |
| **Reactive EW / DRFM** | hundreds of ns (Navy STTR) | academic AMC 7.5–8 µs; OmniSIG software | yes, below the GPU floor |
| Finance | p99 under 1.5–2 µs small trees; 7.3 µs large LSTM | VOLLO on V80/VP1802, STAC-audited | below ~3 µs on the NIC path |
| Fusion control | 4.4–17.6 µs | KCU1500, KCU105 | no on latency |
| EW spectrum awareness | ~100 µs | CPU/GPU | no |

## 6. Tools and versions seen in the report

hls4ml 1.3.0 (2026-03-20; DA strategy, HGQ2 frontend, precision
propagation; Vitis HLS ≥ 2022.2 is the complete backend; da4ml emits RTL
directly so HLS is optional for DA models); FINN v1.0.0-alpha (2026-09-06,
AMD Research, two maintainers, features pointing above the µs regime);
QICK (quantum control firmware, commercialised by Qblox); Stim and
PyMatching for QEC sampling and reference decoding; Brevitas for the FINN
readout work. Pin every version in `docs/TOOLS.md`.

## 7. Boards owned, as the report sized them

| Board | Part | Role here |
|---|---|---|
| ZCU102 "zcu102" | XCZU9EG ES2, no URAM, 32.1 Mb BRAM | Artifact A; hls4ml/HGQ bring-up; PS for host control |
| BCU-1525 | XCVU9P, 3 SLRs, 345.9 Mb BRAM+URAM, 2× QSFP28 | Artifact B; GT-class NNs, 8 per SLR |
| USRP X310 | XC7K410T, WBX, 200 MS/s ADC | Artifact C |
| FK33 | XCVU33P, 1 SLR, HBM2 | not used here (in Denver, host unverified) |
| 2× U200, second BCU-1525 | XCVU9P | not installed; two-card loop if the user installs one |

## 8. What "money" looks like for these artifacts

Quantum-control companies post FPGA control roles at $140k–190k and hire
in house rather than buying IP; defense ML-on-FPGA roles run $165k–238k
with clearance; the Navy STTR needs a small business teamed with a
research institution. The report's judgment: an independent's offer is
services, open-tool contributions or SBIR/STTR work, not product sales.
The artifacts are therefore judged by a reader who will open the README,
find the measured loop latency and its method, and then read the RTL and
the Verilator evidence.
