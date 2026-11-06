# MEASUREMENT — pin-to-pin latency of the JSC network on the ZCU102 (Artifact A)

Status: method written at Stage 0; §2a revised for Stage 1 on 2026-10-20
(pad loopback, no jumpers; the user has no oscilloscope, pulse generator or
FMC loopback card). Board facts below come from
UG1182 v1.7, DS925 v1.11 (Preliminary; re-check against v1.30 before
publishing) and the Vivado 2024.2 device database; the research notes are in
`evidence/stage0/zcu102_io_report.md`. Items marked UNVERIFIED need the board
or its schematic.

## 1. What is measured

**L_pp: input valid at a package pin → decision valid at a package pin.**

- **Start event:** the rising edge of the input-valid strobe `IN_VALID` at
  the package pad of PMOD pin B (A20; FPGA ball, not the header). The edge
  is driven onto that pad by the pin's own OBUF from the phase-shifted
  launch flop and read back through the same pad's INBUF; an external
  source would arrive at the same pad through its trace (not included).
- **Stop event:** the rising edge of the decision-valid level `DEC_VALID`
  at the package pad of PMOD pin C (D20). (A 3-bit class code on three more PMOD
  pins switches on the same edge; it is checked for correctness, not timed.)
- **Clock:** one domain from the USER_SI570 (AL8/AL7, bank 64, DIFF_SSTL12;
  **300 MHz at power-up**, UG1182 p.47) through one MMCM to F_net = 200, 300,
  400 MHz or the maximum that closes; harness, network, argmax and counters
  all on that clock. One bitstream per clock.
- **What is inside L_pp:** INBUF (HD, LVCMOS33) + wait to the capturing edge
  + pad input flop (a slice next to the pad, PLAN.md D-S1-IOB) + one synchroniser flop + selection of the staged vector
  into the network input register + the da4ml network (LAT_NET cycles, the
  Verilator impulse count) + argmax (ARG_LAT cycles) + pad output flop (slice) + OBUF
  (HD, LVCMOS33): N_core = LAT_NET + ARG_LAT + 2 cycles plus the buffers and
  the wait.
- **What is EXCLUDED, stated with every number:** the 150-bit feature
  vector itself does not cross pins. The ZCU102 has 16 PMOD + 10 J3 user
  pins on HD banks and no user HP pins without an FMC card, so the vector is
  loaded into a staging register over AXI beforehand and is stable for
  microseconds before the strobe; the strobe is the last input event. A real
  deserialiser (GTH or LVDS on FMC) is a separate, later measurement. The PS,
  AXI and Linux are outside the timed path entirely.

### Why this is the honest "I/O-inclusive" number available on this board
The published HGQ/da4ml figures (e.g. 12.1 ns at 200 MHz, XCVU9P) are
register-to-register OOC P&R numbers and exclude all I/O. L_pp adds the real
input buffer, output buffer, pad flops and their routing, the strobe-to-capture wait and the
control logic of a usable harness, on real silicon. The DS925 HD buffer
delays (LVCMOS33_F_12, -2: INBUF 1.154 ns, OBUF 2.415 ns) say the PMOD I/O
alone costs more than one 300 MHz cycle; that is part of the result.

## 2. Instruments

### 2a. On-chip timestamp counter with pad loopback (always available) — labels **silicon** (cycle counts, phase steps) / **model** (two fabric anchors, t_out_C − t_out_B) / **derived** (ns)
Revised 2026-10-20 (Stage 1 design, `docs/ARCHITECTURE.md`): **no jumper
wires**. Pins B and C are IOBUFs with the output always enabled, so each
pin's input buffer reads its own package pad. Nothing may be plugged into
J55/J87. One free-running counter on clk_net (K_*) and one on clk_ps (P_*).

Per armed trial the harness records:
- `K_H`: clk_net count when h_ff (clk_net) first sees l_tw, the fabric twin
  of the launch flop (clk_ps, same D as the pin-B OPFF);
- `K_B`: clk_net count when the pin-B IPFF first sees pad B high;
- `K_C`: clk_net count when DEC_VALID (pin-C OPFF, and its fabric twin c_tw) goes high;
- `P_G`: clk_ps count when g_ff (clk_ps) first sees c_tw;
- `P_D`: clk_ps count when the pin-C IPFF (clk_ps) first sees pad C high.

`N_core = K_C − K_B` is exact and deterministic (= LAT_NET + ARG_LAT + 2,
asserted in simulation and on silicon). With φ the clk_ps delay behind
clk_net (swept by the MMCM fine phase shift over ≥ 1 period, 56·O steps):

```
ΔB(φ) = K_B − K_H = ceil((φ + d_B)/T) − ceil((φ + d_H)/T)
ΔC(φ) = P_D − P_G = ceil((d_C − φ)/T) − ceil((d_G − φ)/T)
```
- d_B = pin-B round trip (clk_ps OPFF clock-to-pad + pad-to-IPFF on clk_net),
  d_C = pin-C round trip (clk_net OPFF → pad → clk_ps IPFF): **silicon**,
  each relative to one fabric anchor;
- d_H (l_tw → h_ff) and d_G (c_tw → g_ff): fabric flop-to-flop crossings,
  **model** (Vivado routed timing, including clock skew). They fix the
  absolute phase; the sweep also measures d_H + d_G on silicon, which
  checks the anchors (`anchor_disagreement`).
- ΔB has one up-step (B) and one down-step (H) per period; ΔC one down (D)
  and one up (G). The solver (`sw/analysis/timed_solve.py`) locates them to
  ± half a phase step (11.9–14.9 ps) and recovers d_B and d_C.

Pin-to-pin latency per trial (pad B rising → pad C rising):
```
L_pp = (K_C − K_H + ceil((φ + d_H)/T))·T − φ + (t_out_C − t_out_B)
     = N_core·T + d_B + u + (t_out_C − t_out_B),   u ∈ [0, T)
```
u is the wait from the pad-B edge to the capturing clk_net edge; the
sweep makes φ, and so u, uniform over one period, which is exactly what an
asynchronous source sees: L_pp is reported as min / median / max. The
remaining model term t_out_C − t_out_B (same bank, same standard) is
tens of ps; each t_out is the routed flop clock delay + clock-to-pad data
path (`summary.json` pad_paths, both corners).

**Anchor bracket.** d_H and d_G differ by ~0.65 ns between Vivado's fast and
slow corners, and L_pp moves one-for-one with d_H. The sweep measures d_H +
d_G on silicon (model-free), so `timed_solve.py --d-h-range --d-g-range`
places the part between the corners at that same fraction and bounds d_H by
max(d_H,min, Σ − d_G,max) … min(d_H,max, Σ − d_G,min); L_pp is quoted at
the estimate with that bracket. Checked in simulation with injected anchors
(d_H 0.7 ns, d_G 1.1 ns): every trial within 2.5 ps of truth. A second, model-free cross-check:
`t_in_B + t_out_C ≈ (d_B + d_C)/2` if both pins' buffers are alike.

Validated in simulation (`evidence/stage1/verilator/`): with injected pad
delays the solver recovers d_B and d_C within half a step and every
trial's L_pp within 3.2 ps of the testbench's true pad-to-pad time.

### 2b. Oscilloscope / logic analyser — not available (user, 2026-10-20) — label **silicon**
Probe pad-adjacent points of pins B and C (or the header pins, with the
trace delay stated). An external pulse generator on pin B replaces the
pin-A launch and gives a truly asynchronous source. If an instrument is
available, its L_pp is the headline and 2a becomes the cross-check.

## 3. Correctness on silicon (bit-exactness)
For every vector the harness writes the 5 logits (80 bits) and the argmax
code to a result BRAM; the host reads them over AXI-Lite (HPM0_FPD,
0xA000_0000) and compares with `ref/golden/jsc_golden_out.hex` and the
argmax of the golden logits. Charter rule (c): 4 vector orders (seeds 0–3,
the same xorshift32 permutation as `tb/tb_jsc.sv`) × 2 runs without
reprogramming, zero mismatches, over the full 166,000-vector test set
(streamed back to back at II = 1 from vector BRAM for the bit-exact pass;
the timed pass uses single strobes).

## 4. What each figure will carry
| Figure | Label | Start | Stop | Instrument | Excludes |
|---|---|---|---|---|---|
| N_net (network cycles) | sim + silicon | network input register D valid | network output register | Verilator impulse test; on-chip counter | I/O, harness |
| OOC latency (N_net × T) | model (OOC P&R) | input register | output register | Vivado 2024.2 timing | pins, IOBs, board |
| N_core | silicon | pin-B readback flop | pin-C output flop | on-chip counter | pad buffers and pad routing |
| d_B, d_C (pad round trips) | silicon (steps, counts) + model (fabric anchor d_H / d_G) | launch clock edge | capture clock edge | counters + MMCM phase sweep | board trace beyond the pad |
| L_pp min/med/max | silicon (counts, steps) + model (anchor, t_out_C − t_out_B) → derived ns | IN_VALID at pad B | DEC_VALID at pad C | counters + MMCM phase sweep | feature-vector pins (on-chip staged), PS/AXI, board traces |
| L_pp (scope) | silicon | IN_VALID at probe point | DEC_VALID at probe point | oscilloscope | as above + probe/trace offset stated |

## 5. Pins (UG1182 Table 3-31; bank 47, HD, LVCMOS33, DRIVE 12, SLEW FAST)
| Role | Net | Ball | Header pin | Buffer |
|---|---|---|---|---|
| B IN_VALID (launch out on clk_ps, readback in on clk_net) | PMOD0_0 | A20 | J55.1 | IOBUF, T = 0 |
| C DEC_VALID (out on clk_net, readback in on clk_ps) | PMOD1_0 | D20 | J87.1 | IOBUF, T = 0 |
| class code [2:0] out | PMOD1_4..6 | F20, G20, J20 | J87.2/.4/.6 | OBUF |

All other PMOD pins are unused (high-Z). **Nothing may be connected to J55
or J87**: the pads are driven. The open PMOD trace stub hangs on each pad;
its reflection is part of what the pad sees and is included in d_B / d_C.

## 6. Faster-I/O variant (not available: the user has no FMC loopback/breakout card, 2026-10-20)
The same method on FMC HPC0/HPC1 LA pins (HP banks 65–67, LVCMOS18 at
VADJ 1.8 V): Vivado model round trip ~1.0 ns slow corner vs ~3.9 ns on the
HD PMODs (`evidence/stage0/zcu102_io_report.md` §4, **model**). Reported as
a second L_pp, never mixed with the PMOD figure.

## 7. ES2 caveat
zcu102 is ES2 silicon timed with the production -2-i speed file. Cycle counts
are unaffected; any ns derived from Vivado's pad/anchor model is labelled
**model**, and the phase-sweep loopback (silicon) is the check.
