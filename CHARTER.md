# opus_nsinfer — Nanosecond inference loops, measured on silicon

You are building and **measuring** sub-microsecond neural-network loops on the
boards in this lab, in three steps that each produce a number nobody has
published: an I/O-inclusive hardware latency for an HGQ/da4ml network, a
closed NN surface-code decoder loop over a real serial link, and an
ADC-to-decision waveform classifier against a Navy budget. The product is
the measurements, the bit-exact flow that produced them, and a README anyone
can check in ten minutes.

## Mission

Deliver, in this directory:

1. **A bit-exact flow**: HGQ2 model → hls4ml distributed-arithmetic (da4ml)
   RTL → Verilator against the Keras golden model with zero mismatches →
   OOC synthesis → silicon, with the same test vectors at every stage.
2. **Artifact A, the measurement**: a jet-substructure MLP (the hls4ml HLF
   JSC benchmark, 16 inputs, 5 classes) on the ZCU102, latency measured
   from input valid at a pin to decision at a pin, with the method stated
   and an external instrument where one exists.
3. **Artifact B, the loop**: an NN surface-code decoder at distance 3,
   then 5, on the BCU-1525, with syndromes arriving over a real GTY serial
   link and corrections leaving over it, latency measured syndrome-in to
   correction-out, against the published 124 ns decode and 550 ns loop.
4. **Artifact C, the budget**: a quantized waveform classifier in the USRP
   X310's Kintex-7 on the live 200 MS/s ADC stream, ADC sample to decision
   measured, against "hundreds of nanoseconds". This step has blockers
   outside your control (see GROUND TRUTH); it is Stage 5.
5. **A README** in the style of `<lab-share>/fpga/fable5_llm/README.md`
   with a provenance label on every figure: **silicon**, **sim**,
   **model** or **derived**, and a script that reproduces every number.

Done means Stage 4 with evidence committed. Stage 5 is done if its
blockers clear.

## The numbers to beat

From the report. Every row is a different device and workload; say so
whenever you quote one next to yours.

| What | Published figure | Device | Status | Tag |
|---|---|---|---|---|
| HGQ + DA jet tagger (JSC) | 75.9% accuracy, 3 cycles, **12.1 ns**, 2,891 LUT, 0 DSP at 200 MHz; the same models at ~750 MHz take 21 cycles = **27.8 ns** | XCVU9P | **OOC P&R only, never measured on a board** | peer-reviewed / preprint |
| LUT-native nets (LogicNets, NeuraLUT, TreeLUT, AmigoLUT) | 71.8–75% JSC, 1.2k–38k LUT, 427–1,008 MHz, under 15 ns | XCVU9P | OOC P&R only; **no hardware-measured I/O-inclusive latency exists for any of them** | peer-reviewed |
| da4ml bit-exactness | >99.5% of RTL models zero mismatches vs Keras in Verilator; every mismatch traced to float32 accumulators ≥ 23 bits | — | the method you will reuse | peer-reviewed |
| Qubit readout NN | 5 qubits in **26.7 ns**, 42K parameters (FINN); KLiNQ 32 ns; under 50 ns | ZCU111 RFSoC | lab demos; measurement method unstated | peer-reviewed / preprint |
| NN decoder loop | d = 3 closed in **550 ns** with a **124 ns** NN decode | Kintex-7 XC7K410T | hardware-measured (arXiv 2605.04892) | preprint |
| Graph decoder loop | **446 ns** syndrome aggregation to error distribution, d = 3 | 3× ZCU216 | hardware-measured, emulated measurements (RISC-Q, arXiv 2603.16203) | preprint |
| Decoder throughput | Helios 11.5 ns per round to d = 21 (VCU129); IBM Relay-BP 24 ns per iteration (VU19P); Riverlane FPGA 810 ns per round, ASIC 240 ns | various | research and vendor | mixed |
| Link costs | Aurora 64B/66B about **450 ns** one way; a custom link about **156 ns**; PCIe 0.89–1.47 µs; GPU loop 2.92 µs transport, 3.76 µs with a persistent kernel | — | the loop budget is the link, not the network | vendor / derived |
| CMS Global Trigger | 24 NNs, 8 per SLR, 240 MHz, 4-bit weights, no DSPs; CICADA 81.25 ns; AXOL1TL 50 ns | VU9P prototype, VU13P | hardware-tested in a 40 MHz fixed-latency pipeline | collaboration |
| RF waveform classification | Navy STTR DON26TZ05-NV023: "hundreds of nanoseconds" on an RFSoC in a DRFM; academic AMC CNNs at 7.5–8 µs on a ZCU111; OmniSIG runs as CPU/GPU software | RFSoC | the budget exists, nothing meets it | solicitation / peer-reviewed |

Targets for this program:

- **A**: a hardware-measured, pin-to-pin latency for an HGQ+DA JSC network
  on the ZCU102 at two or three clocks (200 MHz and the fastest that
  closes), each with the OOC prediction beside it. Accuracy within 0.5
  points of the float model on the full test set, bit-exact to the RTL
  model.
- **B**: decode latency under 124 ns at d = 3 on the VU9P; loop latency
  measured with the real link cost separated out; logical error rate
  reported against PyMatching on the same syndromes; then d = 5 at II = 1.
- **C**: ADC sample to decision under 1 µs first, then toward hundreds of
  nanoseconds, on a stated signal set, with the X310's own timestamps.

## Acceptance ladder (each stage gated before the next)

Every stage requires: (a) a bit-exact reference you built or pinned, with
the test vectors committed, (b) simulation evidence before hardware, (c)
hardware evidence with **at least 4 different random seeds or vector sets,
each run twice without reprogramming**, bit-exact against the model, (d)
timing numbers (WNS, Fmax) from fresh reports whose timestamps you checked.

0. **Flow and budget. No board.** Pin hls4ml, da4ml, HGQ2 and their
   Python in a `uv` environment (`docs/TOOLS.md` records every version and
   the Vitis HLS used, if any). Train the HGQ2 JSC MLP in float64 (or with
   accumulators under 23 bits), export DA RTL, run it in Verilator on build-host
   against the Keras golden model over the whole test set: **zero
   mismatches**. OOC-synthesise for `xczu9eg-ffvb1156-2-i` and
   `xcvu9p-fsgd2104-2L-e` at 200, 400 and the maximum closing clock;
   tabulate cycles, ns, LUT, FF, DSP. Write `docs/MEASUREMENT.md`: how
   pin-to-pin latency will be measured on the ZCU102 (input path, output
   path, instrument or on-chip counters, what is labelled silicon versus
   derived). Write `docs/PLAN.md`. Gate: `evidence/stage0/`.
1. **Artifact A on silicon.** ZCU102 bitstream with the network between a
   real input path and an output pin, measured per `docs/MEASUREMENT.md`.
   Report input-valid-to-decision in ns at each clock, next to the OOC
   prediction. Gate: `evidence/stage1/`, README section A.
2. **Decoder in simulation.** Simulated surface-code syndromes (Stim) with
   PyMatching as the reference decoder; a small NN decoder trained through
   the same HGQ2/da4ml flow; logical error rate versus PyMatching on held-out
   syndromes; bit-exact in Verilator; cycles and ns at the target clock on
   the VU9P from OOC synthesis. Gate: `evidence/stage2/`.
3. **Artifact B on silicon, d = 3.** The decoder on the BCU-1525 with
   syndromes arriving over a GTY link and corrections leaving over it.
   Preferred link: the lab's Aurora 64B/66B 100G design looped from one
   QSFP28 cage to the other on the same card with a DAC cable (this needs
   the cable; see GROUND TRUTH), or a second card if the user installs one.
   Measure decode latency and loop latency separately, with the link's
   contribution isolated. Gate: `evidence/stage3/`.
4. **d = 5 and the README.** Grow the decoder to distance 5 at II = 1 and
   repeat Stage 3. Write the README with every figure labelled, the
   comparison table, and `sw/reproduce.sh`. `LICENSE` and `NOTICE`. Gate:
   README committed, numbers reproducible.
5. **Artifact C, blocked on user items.** An RFNoC block in the X310 image
   (flow in `<lab-share>/fpga/ettus/`) carrying a quantized classifier on
   the ADC stream; signal set defined and generated by the X310's own TX
   looped to RX; ADC-sample-to-decision from RFNoC timestamps. Needs
   Vivado 2021.1, a reachable X310 and the loop cable. Gate:
   `evidence/stage5/`.
6. **Stretch.** A thin custom GTY link under the 156 ns published custom
   figure, replacing Aurora in the loop; a readout discriminator if an
   RFSoC board appears; an hls4ml pull request or FPGA'27 submission from
   Artifact A.

## GROUND TRUTH (the lab; you cannot discover this by experiment safely)

- **Workstation**: this machine (desk-pc, 4 cores, RTX 3090, Python
  3.13 under anaconda, `uv` at `/snap/bin/uv`, Verilator). **Big
  compute: build-host** (48 cores, 256 GB, Tesla P40, Python 3.12, `uv` at
  `~/.local/bin/uv`, Verilator 5.020). Use `uv` with a pinned Python
  (≤ 3.12 if hls4ml, Keras or JAX need it) and record it. lab-host-3 (4
  cores) has Vivado_Lab 2024.2 only. lab-host-4 was unreachable on
  2026-10-19.
- **Filesystem**: `<lab-share>` is one NFS export at the same path
  on every host. Never build or run one `obj_dir` from two hosts.
- **Xilinx tools** (NFS, usable from build-host and here): Vivado 2024.2 and
  2026.1, Vitis HLS 2024.2, Vitis 2024.2 and a 2025.2 unified install under
  `<xilinx-tools>/` (`source .../Vivado/2024.2/settings64.sh`;
  2024.2 is the proven one). build-host also has a local Vivado/Vitis 2020.1 in
  `/tools/Xilinx/` (its mb-gcc built the Aurora test firmware). **Vivado
  2021.1, which the X310 image requires, was not found anywhere.** Run
  every real build on build-host, detached. Use the Vivado MCP tools for short
  queries and report reading.
- **ZCU102 "zcu102"**: XCZU9EG **ES2** silicon, part `xczu9eg-ffvb1156-2-i`,
  JTAG IDCODE 0x14738093, via an FT232H on this machine
  (`localhost:3121/xilinx_tcf/Digilent/ZCU102-JTAG`). PetaLinux boots over
  TFTP from lab-host-3 and NFS; `ssh root@zcu102` when up. 200 MHz SI570 for
  the PL; AXI-Lite from the PS on HPM0_FPD at 0xA000_0000 with a `/dev/mem`
  driver pattern in `<lab-share>/fpga/claude_project/zu9_axi_test/`; boot
  and ES2 notes in `claude_project/zu9_petalinux/CLAUDE.md`. **zcu102 did
  not answer ping on 2026-10-19**: ask the user to power it. Board I/O
  (FMC HPC0/HPC1, PMOD, four SFP+ on GTH, LEDs, switches) comes from
  UG1182; read it through the xilinx-fpga MCP before choosing the input
  path.
- **BCU-1525**: one card, `xcvu9p-fsgd2104-2L-e` (3 SLRs), in build-host at
  PCIe `0000:82:00.0` (Xilinx 0x9038, Gen3 x8), JTAG via build-host hw_server,
  XDMA driver loaded, four DDR4 UDIMMs, **two QSFP28 cages on GTY**.
  **Shared with `fable5_llm`**: the lock is
  `<lab-share>/fpga/.fable5_board.lock` via
  `<lab-share>/fpga/fable5_llm/sw/board_lock.py`; every tool of yours that
  programs or DMAs it takes that lock; never kill a holder. Reprogram only
  through `fable5_llm/sw/program_fpga.sh` or its exact sequence.
- **Aurora**: the lab's 100G Aurora 64B/66B design is at
  `<lab-share>/fpga/claude_ip/ethernet/aurora_64b66b_100g` and was tested
  card-to-card between two BCU-1525s (build-host and lab-host-3, 4 × 25.78 Gbps
  over a QSFP28 DAC) in `claude_project/aurora_uart_test/`. **The second
  card is no longer in lab-host-3** (no Xilinx device on 2026-10-19). Whether
  the DAC cable and the second card are available is a question for the
  user; put it in `NEXT_SESSION.md` at Stage 0.
- **USRP X310**: Kintex-7 XC7K410T, WBX daughterboard (50 MHz–2.2 GHz),
  dual 10 GbE, default address 10.0.10.2, RFNoC image flow and a JTAG
  programming script in `<lab-share>/fpga/ettus/` (read its CLAUDE.md).
  UHD 4.6 host tools exist here but discovery failed on 2026-10-19 (no
  route). Which host carries its 10 GbE link is unverified. Stage 5 only.
- **Not installed**: a second BCU-1525, two Alveo U200, the FK33 (in the
  Denver per the user, host unverified; not needed here). No RFSoC board is owned. No oscilloscope or
  pulse generator is recorded: ask.
- **Reusable lab infrastructure** (copy with a provenance header naming the
  source path; never symlink into another repo): fable5_llm's
  `sw/board_lock.py`, `sw/program_fpga.sh`, `sw/pcie_helper.sh` (NOPASSWD
  sudo only at its own absolute path), `synth/scripts/{create_project,build}.tcl`,
  `launch_build.sh`, `synth/constraints/*`, `rtl/csr_block.sv`;
  `<lab-share>/verilator_lib/` (Xilinx primitives for Verilator);
  `<lab-share>/fpga/python_models/` (`rtlmod`); the Ettus project's
  Makefile and RFNoC block templates; `claude_ip/ethernet/VU9P_10G` and
  `VU9P_100G` if an Ethernet input path is chosen.
- **Chrome and web** are available for papers, datasets and documentation.

## Safety rails (non-negotiable)

- A wedged PCIe endpoint can **kernel-panic build-host**. Before enabling any
  host-visible BAR or AXI path on the BCU-1525, reason about a stalled
  read completion. The only reprogram flow is remove → JTAG → rescan under
  the board lock.
- **Never write any board's flash or non-volatile configuration**: not the
  BCU-1525, not the ZCU102's QSPI or SD, not the X310's flash
  (`uhd_image_loader` writes flash; the Ettus JTAG script is the volatile
  path, and a flash write is the user's call).
- ZCU102: do not JTAG-program the PL while Linux on the PS has live AXI
  masters into it; load through the PS (`fpgautil` or the fpga manager)
  when zcu102 is up, or JTAG with the PS held in reset. Never DMA into PS
  memory before the PL side is verified in simulation.
- Long builds: detached on build-host with `nohup`; one Vivado job per project
  directory; every build writes to its own `synth/out_<build>/`.
- Never read, grep, copy or reference `<lab-share>/fpga/claude_project/llm_inference/`.

## Licence and data rules

- This repository is **Apache-2.0** (full text in `LICENSE`). hls4ml,
  Stim, PyMatching are Apache-2.0; record every dependency's licence in
  `NOTICE`. Check da4ml's and HGQ2's licences before vendoring anything.
- RF datasets: DeepSig RadioML sets are non-commercial licences; prefer a
  signal set you generate yourself with the X310 and document, so the
  artifact carries no dataset restriction.
- No vendor or paper RTL is copied in. Published architectures may be
  reimplemented from their papers.
- The repository stays local. The user creates the GitHub remote and pushes.

## Rules of engagement

- Work in THIS directory only. The git repository is initialised; commit at
  every green gate with the evidence named in the message.
- Maintain `CLAUDE.md`, `docs/PLAN.md` and `NEXT_SESSION.md`. Sessions end
  without warning; resume cold from those three files.
- You are autonomous. The user is not watching. Decide, build, verify,
  iterate. Ask the user only for physical actions (power on zcu102, cables,
  the second card, an instrument), root commands and the X310 items, and
  put every request at the top of `NEXT_SESSION.md` and in the session-end
  report. Do not run a brainstorming interview; this CHARTER is the brief.
- Use subagents for independent work: dataset and training, da4ml export
  and Verilator, OOC synthesis sweeps, Stim/PyMatching harness, link bring-up.
- **A measured number beats a predicted one, and the method is part of the
  number.** Every latency figure states where the clock starts and stops,
  what instrument or counter measured it, and what it excludes.
- **No claimed result without evidence captured in the repo.** If hardware
  disagrees with simulation, THE BUG IS REAL: find it. Never re-run until
  it passes by luck and call that done.
- Every number quoted beside a published number names the device, the
  workload and whether the published one was measured or OOC, in the same
  sentence.
- Report at every session end: stage, evidence, next action, requests.

## Scoring (what the human will judge)

1. Highest acceptance stage reached with full evidence.
2. The measured latencies and their honesty: method stated, link cost
   isolated, OOC prediction beside each silicon figure.
3. Bit-exactness maintained from Keras to silicon at every stage.
4. Wall-clock and number of hardware iterations consumed per stage.
5. Quality of root-cause analyses when things failed.
