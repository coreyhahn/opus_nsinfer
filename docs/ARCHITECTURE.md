# ARCHITECTURE — Stage 1 ZCU102 harness (Artifact A)

Method and labels: `docs/MEASUREMENT.md`. Decisions: `docs/PLAN.md` §A.3.
This file is the interface contract between the RTL (`rtl/`), the testbench
(`tb/`), the Vivado flow (`synth/`) and the host tools (`sw/zcu102/`).

## 1. Blocks

```
                 SI570 300 MHz (AL8/AL7, DIFF_SSTL12)
                         |
                    IBUFDS -> MMCME4_ADV --CLKOUT0--> BUFG clk_net  (F_net)
                                         --CLKOUT1--> BUFG clk_ps   (F_net, fine phase shift; fixture only)
                                         --CLKOUT2--> BUFG clk_axi  (F_net / AXI_DIV; = clk_net when AXI_DIV = 1)
                    PSCLK = clk_net, PSEN/PSINCDEC/PSDONE <-> jsc_harness
 PS (zynq_ultra_ps_e) HPM0_FPD 128b --AXI interconnect--> AXI4-Lite 32b, 21-bit addr --> jsc_harness (clk_axi)

 zcu102_top
  ├─ ps_bd (block design: PS + interconnect; ports M_AXI, clk_axi in, aresetn in)
  ├─ clocking (IBUFDS, MMCME4_ADV, BUFGs, reset synchronisers)
  ├─ IOBUF pin_b (A20, PMOD0_0, J55.1)   I = pin_b_o, O -> pin_b_i, T = 0
  ├─ IOBUF pin_c (D20, PMOD1_0, J87.1)   I = pin_c_o, O -> pin_c_i, T = 0
  ├─ OBUF class[2:0] (F20, G20, J20 = PMOD1_4..6)
  └─ jsc_harness (rtl/jsc_harness.sv)
       ├─ axil_regs: AXI4-Lite slave, CSR + vector/result memory windows
       ├─ vec_mem: DEPTH x 150 b (5 x 32-b BRAM lanes), write clk_axi, read clk_net
       ├─ res_mem: DEPTH x 83 b (logits 80 b + argmax 3 b), write clk_net, read clk_axi
       ├─ stream engine (clk_net): vec_mem[0..N-1] at II = 1 -> core -> argmax -> res_mem
       ├─ timed path (clk_net): ipff_b -> sync_b -> input mux(staged) -> core -> argmax -> opff_c
       ├─ launch fixture (clk_ps): arm 2FF sync -> opff_l (pin B) + twin l_tw
       ├─ timestamp captures: k_H, k_B, k_C (clk_net counter), p_G, p_D (clk_ps counter)
       └─ phase-shift sequencer (clk_net = PSCLK)
```

Pad loopback: pins B and C are bidirectional with the output always enabled,
so each pin's input buffer reads its own pad. No external wire is needed and
nothing may be plugged into J55/J87 (an external driver would fight the
OBUF). Unused PMOD pins stay unconstrained (high-Z).

## 2. jsc_harness ports

```
module jsc_harness #(
  int LAT_NET    = 10,   // da4ml core: model_inp -> model_out cycles (metadata latency + 1)
  int ARG_LAT    = 1,    // argmax register stages (1 or 2)
  int DEPTH_LOG2 = 14,   // vector / result memory depth = 2**DEPTH_LOG2
  int F_NET_MHZ  = 300,  // reported in CFG only
  int AXI_DIV    = 1,    // reported in CFG only (1: clk_axi is clk_net)
  int PS_STEPS_PER_PERIOD = 224, // 56 * CLKOUT1 divide; reported in CFG
  int LC         = 3     // da4ml latency cutoff, reported in CFG
)(
  input  clk_net, input rst_net,          // rst_net: synchronous, active high
  input  clk_axi, input aresetn,          // AXI domain reset, synchronous, active low
  input  clk_ps,  input rst_ps,           // synchronous, active high
  // AXI4-Lite slave on clk_axi, 21-bit byte address (2 MiB window)
  input [20:0] s_axi_awaddr, input s_axi_awvalid, output s_axi_awready,
  input [31:0] s_axi_wdata, input [3:0] s_axi_wstrb, input s_axi_wvalid, output s_axi_wready,
  output [1:0] s_axi_bresp, output s_axi_bvalid, input s_axi_bready,
  input [20:0] s_axi_araddr, input s_axi_arvalid, output s_axi_arready,
  output [31:0] s_axi_rdata, output [1:0] s_axi_rresp, output s_axi_rvalid, input s_axi_rready,
  // MMCM dynamic phase shift; PSCLK = clk_net
  output psen, output psincdec, input psdone, input mmcm_locked,
  // pads (pad flops inside the harness, in slices next to the pads, drive / sample these)
  output pin_b_o, input pin_b_i,   // B: launch OPFF on clk_ps; IN_VALID IPFF on clk_net
  output pin_c_o, input pin_c_i,   // C: DEC_VALID OPFF on clk_net; readback IPFF on clk_ps
  output [2:0] class_o,            // decision class code, OPFFs on clk_net
  output heartbeat
);
```
AXPROT is ignored. Every AXI transaction completes in bounded time (no wait
on anything outside the slave); unmapped addresses read 0xDEADC0DE and
writes are dropped with OKAY.

## 3. Address map (offsets from 0xA000_0000; 32-bit registers)

| Offset | Name | Access | Meaning |
|---|---|---|---|
| 0x000 | ID | RO | 0x4A534331 ("JSC1") |
| 0x004 | PARAMS | RO | [7:0] LAT_NET, [11:8] ARG_LAT, [15:12] DEPTH_LOG2, [23:16] N_CORE expected (= LAT_NET + ARG_LAT + 2), [31:24] LC |
| 0x008 | CFG | RO | [15:0] F_NET_MHZ, [19:16] AXI_DIV, [31:20] PS_STEPS_PER_PERIOD |
| 0x00C | SCRATCH | RW | |
| 0x010 | CTRL | RW | [0] mode: 0 = stream, 1 = timed |
| 0x014 | STREAM_N | RW | vectors to stream, 1..DEPTH |
| 0x018 | STREAM_GO | W | any write starts a stream (toggle) |
| 0x01C | STATUS | RO | [0] stream_busy, [1] stage_busy, [2] ps_busy, [3] mmcm_locked, [8] trial_dec (DEC_VALID seen this arm), [9] kh_valid, [10] kb_valid, [11] pg_valid (clk_ps), [12] pd_valid (clk_ps), [23:16] stream_seq (count of completed streams, mod 256) |
| 0x020 | STREAM_CYC | RO | clk_net cycles from first vector issued to last result written |
| 0x024 | T_VEC | RW | vector index to stage |
| 0x028 | STAGE_GO | W | any write: staged <= vec_mem[T_VEC] (toggle) |
| 0x02C | ARM | RW | [0] arm level. 0 -> 1 clears all captures and starts a trial; 1 -> 0 ends it |
| 0x030 | K_H | RO | clk_net counter at the first edge where the H flop (twin of the launch, fabric) is 1 |
| 0x034 | K_B | RO | clk_net counter at the first edge where ipff_b (pin B readback, pad flop) is 1 |
| 0x038 | K_C | RO | clk_net counter at the edge opff_c (DEC_VALID, pin C, pad flop) went 1 |
| 0x03C | T_CLASS | RO | [2:0] class code driven with DEC_VALID |
| 0x040–0x048 | T_LOGIT0..2 | RO | 80-b logits captured with DEC_VALID (word 2 = bits [79:64]) |
| 0x050 | P_G | RO | clk_ps counter at the first edge where G (clk_ps flop of the DEC_VALID fabric twin) is 1 (quasi-static) |
| 0x054 | P_D | RO | clk_ps counter at the first edge where ipff_d (pin C readback, pad flop, clk_ps) is 1 (quasi-static) |
| 0x060 | PS_CMD | W | [15:0] number of phase steps, [31] direction (0 = increment) |
| 0x064 | PS_POS | RO | signed accumulated phase steps since reset |
| 0x070 | CNT | RO | free-running clk_net counter (host checks F_net against wall time) |
| 0x080000 + 32·v + 4·w | VEC[v][w] | RW | vector v, word w = 0..4 (bits 32w+31:32w of the 150-b input; word 4 holds [149:128]); w = 5..7 read 0 |
| 0x100000 + 16·v + 4·w | RES[v][w] | RO | w = 0..1: logits [63:0]; w = 2: [15:0] logits [79:64], [18:16] argmax; w = 3 reads 0 |

Clocks for registers: all CSR state lives on clk_axi. Commands cross to
clk_net as toggles (level change detected in clk_net), configuration as
quasi-static levels written before the toggle. With AXI_DIV = 1 the two are
one clock; with AXI_DIV = 2 they are synchronous (same MMCM) and Vivado times
every crossing. P_G, P_D, pg_valid, pd_valid come from clk_ps and are
quasi-static (false path); the host reads them only after DEC_VALID has been
seen and ≥ 1 µs has passed.

## 4. Timed path, cycle by cycle (clk_net edges; counter cnt == e in the cycle after edge e)
- e_B: ipff_b (pad flop) first captures 1 → K_B = e_B.
- e_B+1: sync_b = 1 (one synchroniser stage; part of N_core).
- e_B+2: core input register holds `staged` (input mux = sync_b ? staged : 0).
- e_B+1+LAT_NET: core output holds the logits.
- e_B+1+LAT_NET+ARG_LAT: argmax register.
- e_C = e_B+2+LAT_NET+ARG_LAT: opff_c (DEC_VALID) and the class OPFFs switch → K_C = e_C.
- N_core = K_C − K_B = LAT_NET + ARG_LAT + 2 (deterministic; asserted in sim and on silicon).

DEC_VALID is a level: it follows sync_b through the same delay, so it falls
N_core cycles after pin B falls (arm 1 → 0).

## 5. Launch fixture and captures
- clk_ps: arm (clk_axi) → 2-FF synchroniser → opff_l (pad flop, pin B) and l_tw
  (fabric twin, same D). Which clk_ps edge launches is irrelevant: K_H
  timestamps it.
- clk_net: h_ff <= l_tw (anchor crossing, timed: d_H) → K_H.
- clk_net: c_tw (fabric twin of opff_c, same D).
- clk_ps: g_ff <= c_tw (anchor crossing, timed: d_G) → P_G; ipff_d (pad flop) <= pin_c_i → P_D.
- All captures arm on ARM 0 → 1 and record only the first rising edge.

## 6. Phase shift
MMCM CLKOUT1 uses fine phase shift; one PSEN pulse moves clk_ps by
T_VCO/56. The sequencer issues PS_CMD[15:0] pulses, each after the previous
PSDONE, and accumulates PS_POS. Steps per output period =
PS_STEPS_PER_PERIOD = 56 × CLKOUT1_DIVIDE.

| F_net | VCO | CLKOUT0/1 divide | step | steps per period | AXI clock |
|---|---|---|---|---|---|
| 300 MHz | 1200 MHz (M=4, D=1) | 4 | 14.88 ps | 224 | 300 MHz (AXI_DIV 1) |
| 200 MHz | 1200 MHz (M=4, D=1) | 6 | 14.88 ps | 336 | 200 MHz (AXI_DIV 1) |
| 500 MHz | 1500 MHz (M=5, D=1) | 3 | 11.90 ps | 168 | 250 MHz (AXI_DIV 2, CLKOUT2 = 6) |

## 7. Stream engine
STREAM_GO: issue vec_mem addresses 0..N−1 on consecutive clk_net cycles; the
read data (BRAM with output register) drives the core input mux; a valid
shift register aligned to the core and argmax writes {argmax, logits} to
res_mem[0..N−1]. STREAM_CYC counts from the first issue to the last write;
it must equal N − 1 + (fixed pipeline depth) exactly.

## 8. argmax
Logit lanes (LSB at bit 0): lane i width `out_lane_widths[i]`, LSB exponent
`out_lsb_exponent[i]` from `ref/golden/jsc_golden.json` (16/15/17/16/16 bits;
2^-9, 2^-9, 2^-9, 2^-8, 2^-8). Lanes are aligned to the finest LSB (lanes 3
and 4 shifted left by one) and sign-extended to 18 bits. Winner = the lowest
index i with v_i ≥ v_j for all j > i and v_i > v_j for all j < i
(`np.argmax` first-max rule), from all ten pairwise comparisons in parallel.
Expected values come from Python (`ref/golden/jsc_golden_argmax.hex`), not
from the RTL algorithm.
