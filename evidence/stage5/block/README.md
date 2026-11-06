# Stage 5: the nsclf RFNoC block in the X310 image (pre-hardware), 2026-10-30

**Status:** the block is bit-exact in Verilator (classifier path against the committed golden stream, pass-through
unchanged); the whole block (framework noc_shell + CHDR + ctrlport) passes the UHD 4.9 testbench flow in xsim;
the X310_XG image with it is built on build-host and **closes timing** (WNS +0.016 / WHS +0.003 / WPWS +0.001 ns, with a
spread-logic placement; the default UHD flow missed by 12 ps in the stock ADC capture, section 8). **No X310 was reachable: nothing here ran on the radio.**
Every figure is **sim** (Verilator / xsim), **model** (Vivado P&R, Keras channel-model labels) or **derived**
(read from RTL), labelled where it appears. Everything in `sw/x310/` that talks to a device is **untested**.

## 1. What was built

| file | what |
|---|---|
| `rfnoc/blocks/nsclf.yml` | block descriptor (from the tap probe's `tap.yml`): clocks rfnoc_chdr / rfnoc_ctrl / radio; ctrlport and data in `radio`; io_ports `radio_in` (radio, slave, renamed `*_in`), `radio_out` (radio, master, `*_out`), `time` (timekeeper listener); one CHDR output `evt` (u64, sideband at start); NOC ID 0x4E53C1F0; parameters NUM_PORTS 2, NIPC 1, CORE_LAT 15, LC_X10 20, IN_REG 1, K_DEFAULT 16 |
| `rtl/x310/noc_shell_nsclf.sv` | **framework-generated** (rfnoc_modtool, UHD 4.9 a5d1b2e), copied verbatim by `rfnoc/gen_nsclf.sh`; `--check` regenerates and compares (identical, 2026-10-30) |
| `rtl/x310/rfnoc_block_nsclf.sv` | the modtool block template, mechanically edited by `rfnoc/nsclf_block_from_template.py` (Mako widths, header, User Logic = `nsclf_user`) |
| `rtl/x310/nsclf_user.sv` | everything below the noc_shell: radio pass-through (wires) + `nsclf_core` |
| `rtl/x310/nsclf_core.sv` | tap: channel select, input register, `x310_stream` (unchanged), tau delay line, MISR window, hysteresis, event FIFO + framer, ctrlport registers |
| `rfnoc/fpga/nsclf/Makefile.srcs` | sources for the UHD build; `NSCLF_LC` (default 2) picks `rtl/gen/x310_clf_lc<c>`; exports `VIV_INCLUDE_DIRS` for `x310_clf_lanes.svh` |
| `rfnoc/icores/x310_XG_nsclf.yml` | image core (stock x310_XG + `x3xx_radio_base.yml` inlined) with nsclf0, ep6, and the raw RX path (D-S5-CAP below) |
| `synth/scripts/launch_x310_nsclf.sh` | image builder `-G` on desk-pc, then make detached on build-host via `.scratch/s5_launch_x310.sh` (the stock flow); per-cutoff CORE_LAT/LC_X10 set from `metadata.json`; refuses an existing build dir |

Clock domains: everything in `nsclf_user` runs on `radio_clk`. The only crossings of the block are the
noc_shell's own `ctrlport_endpoint` (SYNC_CLKS 0, rfnoc_ctrl_clk <-> radio_clk) and `axis_data_to_chdr`
(radio_clk -> rfnoc_chdr_clk), plus its reset pulse synchroniser. No hand-written CDC.

## 2. Decisions (refinements of the brief, each forced or checked by the source)

- **D-S5-CAP (raw RX path).** The stock x310_XG routes radio0.out_0 -> ddc0 -> ep0. The DDC is not bit-transparent
  at decimation 1 and 0 Hz (`lib/rfnoc/ddc.v`: `dds_freq_tune` complex multiply, `axi_clip_complex`, then the CIC
  and the host-set `scale_factor` multiply; **derived**, not simulated), so a host capture through it is not the tap's
  samples. In `x310_XG_nsclf.yml`: **radio0.out_0 -> ep0 directly** (channel 0 raw = the tap's default channel),
  ddc0 has one port, on radio0.out_1 -> ep1. RF A TX, RF B and replay are stock. Channel 1 captures go through ddc0
  and cannot be replayed bit-exactly (nsclf_host.py warns). Side effect: 37 fewer DSPs (393 -> 356 post-synth).
- **Pass-through** exactly as the probe: rx_data, rx_stb device -> radio; rx_running, tx_data back; tx_stb device ->
  radio; tx_running back. Wires only (`nsclf_user.sv`); the generated image core connects them with plain assigns
  (`build/rfnoc_image_core.sv` here: nsclf0 `*_in` from `radio_*_radio0`, `*_out` to `radio0_radio_*`).
- **IN_REG = 1:** the selected channel's sample is registered once before the window shift register (+1 cycle,
  5 ns) so that the route from the fe_control outputs (near the ADC pins) to a 25k-LUT block placed elsewhere is
  one register-to-register hop. Reported in REG_BUILD and REG_LATENCY.
- **Cutoff as a build parameter:** `NSCLF_LC` selects the core directory; the block's `CORE_LAT` must match it
  (the core module has the same name at every cutoff). `launch_x310_nsclf.sh <name> <LC>` writes both from
  `metadata.json`. A mismatch would misalign tau; the silicon MISR check would expose it.
- **Channel change restarts the window:** writing REG_CHAN pulses the stream's reset (the shift register's counter
  and the classifier's valid pipe), so the first decision after a change is the first window made only of the new
  channel's samples; decisions in flight are dropped.
- **Hysteresis state is not reset by a channel change** (REG_CTRL bit 0 does that).
- **MISR word = {logits[61:0], cls[1:0]}**: all 62 logit bits are in the signature, not only the class, so a
  silicon/sim difference in any logit bit is caught.

## 3. Sample format, what precedes the tap, and time

**I/Q at the radio io_port (derived from RTL, .scratch/uhd a5d1b2e):** `top/x300/x300.v:587`
`rx0 = {rx0_i, 2'b00, ~rx0_q_inv, 2'b00}` (14-bit ADS62P48, left-justified, Q pair inverted on the board);
`x300_core.v:738` feeds rx0 to both channels of dboard 0; `lib/control/fe_control.v` passes
`rx_data_in[31:16]` as adc_i and `[15:0]` as adc_q to `rx_frontend_gen3` and writes `rx_data_out = {rx_i, rx_q}`;
that is `radio_rx_data_radio0` (bus_int.v:818). So **I = bits [31:16], Q = [15:0]**, the RFNoC sc16 item order
(`timed_complex_gain.sv` header; host `convert_common.hpp:174` `sc16_t(item >> 16, item)`, real = I).
The classifier's lanes: `x310_stream` lane 2k = I_k (`win <= {in_q, in_i, ...}`), `x310_data.py` column 0 = I =
real part, `export_x310.py:216` writes the stream hex as `(q << 16) | i`. `nsclf_core` maps
`in_i = s_data[31:16]`, `in_q = s_data[15:0]`; `nsclf_model.py radio_word()` re-packs the golden hex as {I, Q}, and
the Verilator decisions match Keras on all 65,473 windows (section 7), which an I/Q swap would not.

**Processing before the tap (derived; UHD host defaults read from `x300_radio_control.cpp`, `rx_frontend_core_3000.cpp`,
`db_wbx_common.cpp`):** ADC capture (`capture_ddrlvds`) -> `rx_frontend_gen3` per channel:
1. IQ mapping: WBX connection "IQ" -> no swap, no inversion (register 0);
2. **DC-offset correction: automatic by default** (`DEFAULT_DC_OFFSET_ENABLE = true`): `rx_dcoffset`, an IIR notch
   y = x - 2^-20 y[-1] in 24 bits (time constant 2^20 samples = 5.2 ms); `nsclf_host.py capture --dc-offset off`
   switches it to fixed (0);
3. IQ-balance correction: mag/phase 0 by default (identity), unless a UHD calibration file
   (`uhd_cal_rx_iq_balance`) exists on the host;
4. heterodyne / quarter-rate downconverter: present (BYPASS_HETERODYNE 0) but off ("IQ" mode);
5. `round_sd` 24 -> 16 bits (error-feedback rounding: the 14-bit ADC values become full 16-bit values after DC
   correction). rx_stb is constant 1 after reset (`adc_stb = 1'b1`).
The classifier was trained on a channel model with a DC offset and no notch; with the notch on, the real input has
its DC removed slowly. Both channels of radio0 see the same ADC through two independent front-end instances.

**Time.** `bus_int.v:541`: `timekeeper` on radio_clk with TIME_INCREMENT 1 and sample_rx_stb 1, so radio_time
counts +1 per radio_clk = one tick per sample (spc = 1, tick rate = master clock rate, 200 MHz). The image core
gives the same `radio_time` wire to radio0 and nsclf0 (`rfnoc_image_core.sv:1755, 1759`).
- **Tap time** of a sample = the radio_time value in the clock cycle in which it is on `radio_rx_data` with
  `radio_rx_stb` high.
- **tau** of a decision = the tap time of its window's newest sample (the window is the 64 samples ending there).
  `nsclf_core` carries radio_time through an L-cycle delay line, so tau is right even across time jumps and stb gaps.
- **Host timestamp = tap time + 6 (sim).** In UHD's radio_core the RX complex gain (`timed_complex_gain`,
  EN_COMP_GAIN_RX = 1 in x310_XG radio0, default 1.0 + 0j, bit-exact) is a 6-strobe pipeline between the radio port
  and `radio_rx_core`, which stamps each packet with radio_time of the cycle its first word enters
  (`radio_rx_core.v:561-563`). `tb/tb_radio_ts.sv` on UHD's own `radio_core` (xsim, UHD flow, radio_time + 1 per
  clock, every sample tagged with its own tap time, timed finite RX command): **every one of 1,000 words in 10
  packets has data = packet timestamp + k - 6**, and the first packet's timestamp equals the command time
  (`uhdsim_radio_ts_tb_radio_ts_cg1.log`); control with EN_COMP_GAIN_RX = 0: offset 0 (`..._cg0.log`). Ettus's own
  rfnoc_block_radio_tb uses the same constant (FEATURE_COMP_GAIN_LATENCY = 6) for non-default gains.
- So a host capture with first-sample timestamp T has tap times T - 6 + k; its decisions fully inside the capture
  have tau in [T - 6 + 63, T - 6 + N - 1]; `nsclf_host.py capture` arms exactly that window.

## 4. Outputs (D-S5-OUT)

**Hysteresis (smoothed class).** State: current class `cur` (0 = noise after reset), candidate, count, run length.
For each raw decision c: c = cur -> count := 0; else count := (c = candidate and count > 0) ? count + 1 : 1,
candidate := c; when count reaches K (K = 0 is treated as 1) the smoothed class becomes c **at that decision**
and one event record is emitted. Run length = number of decisions with the old smoothed class, from the previous
change (inclusive) to this one (exclusive), saturating at 2^32 - 1. The first event after reset counts from the
first decision.

**K default = 16** (`k_choice.txt`, `sw/x310/nsclf_kchoice.py`, **model** labels of the golden stream: 182 label
changes, 54,182 pure windows, raw accuracy 77.4 %): K = 16 gives 264 events (1.45 per true change), smoothed
accuracy 79.6 %, and adds 15 decisions = 75 ns; K = 24 gives 192 events but 73.2 %. Rule: the largest K whose
smoothed pure-window accuracy is not below the raw one. **Stated after the sweep, not before**; K is a register.

**Event record** (CHDR packet on port `evt` -> ep6, 3 payload words = 24 bytes, has_time = 1, timestamp = tau):

| word | bits |
|---|---|
| 0 | tau (64) |
| 1 | [63:32] previous run length, [31:16] K used, [11:8] record version (1), [5:4] old class, [1:0] new class |
| 2 | [63:32] event sequence number (counts every event generated, dropped or not), [31:0] drop count when it was queued |

Events queue in a 32-entry FIFO; when it is full a record is dropped and REG_EVT_DROP counts it; gaps in the sequence
numbers show where. At K = 1 with a stalled sink, 8,100 of 8,611 were dropped in sim and the 511 received matched
the model by sequence number (seed 2 below).

**MISR window.** REG_T_START, REG_N, then REG_ARM bit 0: the window registers are latched (T_last = T_start + N - 1),
the MISR is set to all ones, the counters cleared. The window is the decisions with **T_start <= tau <= T_last**,
i.e. by the tap time of each window's newest sample. MISR: 64-bit Galois, polynomial x^64 + x^63 + x^61 + x^60 + 1
(XAPP052 taps 64, 63, 61, 60), one step per decision, s := (s << 1) ^ (s[63] ? 0xB000000000000001 : 0) ^ {logits, cls}.
Also per-class counts, count, tau of the first and last counted decision. DONE once a decision with tau >= T_last
has been processed. **LATE** = some decision with tau >= T_start went by before the window was active (the window
missed decisions; the host must re-arm earlier). N >= 1. The decision in the stage-2 register during the arming
cycle is not counted (its compare used the old window); with the host arming milliseconds ahead this never matters.

## 5. Register map (ctrlport byte addresses; 32-bit; RO = read only)

| addr | name | access | meaning |
|---|---|---|---|
| 0x00 | ID | RO | 0x6E73636C ("nscl") |
| 0x04 | VERSION | RO | 0x00010000 (1.0) |
| 0x08 | BUILD | RO | [31:24] cutoff x 10, [23:16] W, [15:8] CORE_LAT, [7:4] IN_REG, [3:0] BFP_PIPE (lc2: 0x14400F11) |
| 0x0C | LATENCY | RO | L = IN_REG + 1 + CORE_LAT + 1 + BFP_PIPE = **19** (section 6) |
| 0x10 | CHAN | RW | radio0 channel feeding the classifier (reset 0); a write restarts the window |
| 0x14 | K | RW | hysteresis K, 16 bits (reset K_DEFAULT = 16; 0 acts as 1) |
| 0x18 | CTRL | W | bit 0: reset hysteresis (class 0, count 0, run 0); bit 1: clear event seq and drop counters |
| 0x1C | CUR | RO | [31:16] count, [9:8] candidate, [5:4] last raw class, [1:0] smoothed class |
| 0x20 / 0x24 | T_START_LO / HI | RW | window start (tap time) |
| 0x28 | N | RW | window length in tap-time ticks (>= 1) |
| 0x2C | ARM | W | bit 0 arm (latch window, clear MISR / counters); bit 1 disarm |
| 0x30 | STATUS | RO | bit 0 armed, 1 active (>= 1 decision counted), 2 done, 3 late |
| 0x34 | WIN_COUNT | RO | decisions counted |
| 0x38 / 0x3C | MISR_LO / HI | RO | MISR |
| 0x40..0x4C | CNT0..CNT3 | RO | per-class raw decision counts in the window |
| 0x50 / 0x54 | TFIRST_LO / HI | RO | tau of the first counted decision |
| 0x58 / 0x5C | TLAST_LO / HI | RO | tau of the last counted decision |
| 0x60 | EVT_DROP | RO | event records dropped (FIFO full) |
| 0x64 | EVT_SEQ | RO | event records generated |
| 0x68 / 0x6C | DEC_LO / HI | RO | free-running decision count since reset (reading LO latches HI) |
| 0x70 / 0x74 | TIME_LO / HI | RO | radio_time now (reading LO latches HI) |

Unlisted addresses read 0 and are acknowledged. Read/write latency 1 radio_clk cycle (plus the ctrlport_endpoint).

## 5a. (2026-11, event revision) EVT_EN and batched event packets, block VERSION 2.0

Everything in sections 1-5 above describes VERSION 1.0 (the images of 2026-10-30 and 2026-11-03) and stays as it was.
This section lists what the 2026-11 event revision changes (`rtl/x310/nsclf_core.sv`, `nsclf_user.sv`; YAML
`version: "2.0"`; noc_shell / block wrapper unchanged by the regeneration). Why: UHD resets the block at every
session init, VERSION 1.0 then emits events at K = 16 from reset to an endpoint nobody reads yet, one CHDR packet per
record (~1e6 packets/s on dense pulses, D-S5-EVK), and new sessions right after a capture often failed with a Radio#0
control-ACK timeout (`../v2/README.md` section 4). **Status: sim only** (Verilator, UHD xsim); no image built yet.

**Register map delta (2026-11, event revision)** (all other registers as in section 5):

| addr | name | access | meaning |
|---|---|---|---|
| 0x04 | VERSION | RO | **0x00020000 (2.0)** (2026-11, event revision); 0x00010000 = the images before it |
| 0x18 | CTRL | **RW** | bit 0 / bit 1 as before (write-1 pulses, read 0); **bit 2: EVT_EN, reset 0** (2026-11, event revision): a level, set by every CTRL write (to pulse bit 0 or 1 with events on, write them with bit 2 = 1); reads {29'b0, EVT_EN, 2'b0} |
| 0x78 | EVT_FLUSH | RW | (2026-11, event revision) packet close timeout in radio_clk cycles, bits [23:0]; reset **4096** (20.5 us at 200 MHz); **0 = one record per packet** (the VERSION 1.0 format) |
| 0x7C | EVT_CFG | RO | (2026-11, event revision) [7:0] EVT_BATCH (16), [15:8] EVT_AW (6: FIFO 64 records), [19:16] words per record (3), [23:20] record version (1), [31:24] wait-counter width (24): 0x18130610 |
| 0x80 | EVT_PKTS | RO | (2026-11, event revision) event packets sent (last beat accepted); cleared by CTRL bit 1 with EVT_SEQ / EVT_DROP |

**EVT_EN.** While 0, a smoothed-class change makes no record, no FIFO push, no drop count and no EVT_SEQ step; the
hysteresis (REG_CUR, run length) runs as before, so a record emitted after EVT_EN goes to 1 has the true run length.
Records already queued when EVT_EN goes to 0 still leave (the last open packet after at most EVT_FLUSH cycles).
A hysteresis reset (CTRL bit 0) in the cycle of a change wins: the change does not happen and no event is generated
(VERSION 1.0 advanced EVT_SEQ in that corner without a record).

**Packet format (port `evt`, CHDR, has_time = 1).** Payload = n records of the unchanged 3-word format of section 4
(record version field still 1), back to back, 1 <= n <= EVT_BATCH = 16; CHDR timestamp = word 0 (tau) of the
**first** record; tlength = **24 x n** bytes (sideband sampled on the first beat, SIDEBAND_AT_END 0, as before);
tlast on the third beat of the last record; the largest packet is 2 + 48 = 50 CHDR words = 400 bytes (block MTU 2^10
words, noc_shell payload FIFO 64 words: the sideband-at-start framer does not need a whole packet in its FIFO).

**When a packet starts** (one rule, checked cycle by cycle by `tb/tb_nsclf.sv` from the outside): at a clock edge with
no packet open, the FIFO not empty at the previous edge and no record sent at it, a packet of n = min(queued,
nbmax) records starts if queued >= nbmax or the oldest queued record has waited >= EVT_FLUSH cycles since its push
(nbmax = 16, or 1 when EVT_FLUSH = 0). So a full batch leaves at once, a lone record after max(EVT_FLUSH, 2) cycles,
and two idle cycles follow each packet (3n + 2 cycles per packet of n records with tready high). The
wait counter is 24 bits: a record that waits more than 2^24 cycles (84 ms) behind a flow-control stall may leave up
to EVT_FLUSH cycles later than the rule says (never earlier, never stuck). Derived from RTL, not measured: a record is
pushed 3 cycles after its decision (as before); with EVT_FLUSH = 0 its first beat is offered 2 cycles after the push
(VERSION 1.0: in the cycle after it).

**FIFO and drops.** EVT_AW 5 -> **6** (64 records = 4 full batches): a full batch can be sent while 48 more queue.
Each entry carries the record (180 bits) + a 24-bit push stamp (LUTRAM, asynchronous read). A record that finds the
FIFO full is dropped and counted (REG_EVT_DROP), its seq number skipped, exactly as before; the drop field of each
record is the drop count when it was queued.

**Defaults and why.** EVT_BATCH 16: 16 x 24 B = 384 B payload, well inside a 1500-byte Ethernet frame and the
block MTU; a 16x cut of the packet rate (dense pulses ~1e6 records/s -> ~6e4 packets/s) for 204 x 64 bits of LUTRAM.
EVT_FLUSH 4096 cycles = 20.5 us: a lone event still reaches the host within ~20 us plus transport, small against the
millisecond-scale host processing, while a burst fills whole packets. EVT_AW 6: the sink can stall for a whole packet
(48 beats) while the next three batches queue. Host tools may set EVT_FLUSH per run (`--evt-flush`).

**Host side.** `sw/x310/nsclf_host.py` / `nsclf_txrx.py`: EVT_EN stays 0 during setup, is set to 1 only after K is
written and the event receiver thread runs, and back to 0 after the capture; `--no-events` leaves it 0 (no event
traffic at all). Records are parsed in 6-item groups (packet boundaries do not matter); `info` prints EVT_EN,
EVT_FLUSH, EVT_CFG and EVT_PKTS. A VERSION 1.0 image is recognised by REG_VERSION (the CTRL bit 2 write is ignored
there, the new registers are not read). `nsclf_replay.py` compares record lists (packing-independent) and checks the
replay's own packets.

**Verification (sim, build-host, Verilator 5.020; logs `../evt/block/`):** `make -C tb nsclf LC=2` 5 configurations x 2:
events on from the configuration (seed 0, flush 4096: 21 full + 1 timed-out packet; seed 1, flush 0: 786 one-record
packets, random back pressure), off from reset and switched on / off / on mid-stream (seed 2, K = 1, 20,000-cycle
stalls: 3,207 generated, 2,743 dropped, 29 full packets; seed 3, flush 64: 76 timed-out packets), off then on at 40 %
(seed 4, flush 1000, random back pressure: 56 full + 9 partial); 0 decision / tau / latency / pass-through / register /
AXIS / framer / event mismatches; negatives (decision, MISR, event run length, and a record inside a 16-record packet)
all fail. UHD 4.9 xsim of the whole block (`../evt/block/uhdsim_nsclf_rfnoc_block_nsclf_tb.log`, Vivado 2024.2,
BFM stall probability 25 %): **PASSED**; VERSION 2.0, CTRL 0 at reset, EVT_FLUSH 4096, EVT_CFG read back; the host side
writes EVT_EN = 1 before the stream; MISR 0xc086b19f7a5f449b over 65,473 decisions; 338 records in 22 CHDR packets
(21 x 16 + 1 x 2, each has_time, 24 n bytes, timestamp = first record's tau), EVT_PKTS = 22, 0 dropped, all equal the
model (`../evt/block/uhdsim_nsclf_check_events.log`). Lint: `nsclf_lint` 0 warnings; `nsclf_block_lint` the same 89
framework warnings as before, 0 in nsclf_core / nsclf_user. `rfnoc/gen_nsclf.sh --check`: generated files unchanged
by the YAML version bump. Classifier unchanged: `make -C tb x310 LC=2` passes (`../evt/verilator/`); replay
self-test PASS, --flip / --shift FAIL (`../evt/replay/`).

## 6. Latency (sim)

- **Pipeline latency L = 19 cycles = 95 ns at 200 MHz** (cutoff 2). Start event: the radio_clk edge that captures
  the window's newest sample from `radio_rx_data` at the block's radio_in port (into the IN_REG register). Stop
  event: the edge after which that window's decision (class, logits, valid) is on the classifier's registered
  outputs. L counts the edges from the first to the second inclusive: 1 input register + 1 shift register + BFP 1
  + core 15 (14 da4ml stages + input register) + argmax 1. Counter: Verilator cycle count in `tb_nsclf.sv`, checked
  on **every** decision of every run (65,473 x 8), with and without stb gaps; REG_LATENCY reports it.
- **First window sample -> decision** = L + 63 = 82 cycles = 410 ns.
- **To the event record** (derived from RTL, not measured): an event leaves `nsclf_core` on the AXIS 3 cycles after
  its decision (stage-1 register, event register, FIFO), i.e. L + 3 = 22 cycles after the decision's newest sample,
  if the FIFO is empty; then axis_data_to_chdr (a whole 3-word packet, CDC to the CHDR clock), the crossbar, the
  SEP and 10 GbE to the host: not measured. Events carry tau, so host-side latency is never needed for the tau.
- **Excluded:** the ADC's own pipeline, `capture_ddrlvds`, `rx_frontend_gen3` (DC/IQ correction, rounding: a fixed
  number of cycles before the tap, not counted), and everything after the decision.
- Hysteresis adds K - 1 decisions (75 ns at K = 16) before a change is declared.

## 7. Simulation results

**Verilator 5.020, build-host, `make -C tb nsclf LC=2`** (`tb/tb_nsclf.sv` on `nsclf_user`, stimulus and expected values
from `sw/x310/nsclf_model.py stim`, events checked by `nsclf_model.py check-events`; logs `nsclf_lc2_*.log`):

| config | channel | K | AXIS ready | stb gaps | windows | decisions | events model / received / dropped |
|---|---|---|---|---|---|---|---|
| seed 0 | 0 | 16 | always | none (X310) | 1 (whole stream, 65,473) | 65,473, 0 mismatches | 264 / 264 / 0 |
| seed 1 | 1 | 4 | random 50 % | p = 1/8 | 7 (N = 1, 64, 1000, 7, 12000, 333, end-of-stream) + late-arm | 65,473, 0 | 1,121 / 1,121 / 0 |
| seed 2 | 0 | 1 | stalls of 20,000 cycles | p = 1/8 | 7 + late-arm | 65,473, 0 | 8,611 / 511 / 8,100 |
| seed 3 | 1 | 64 | always | p = 1/4 | 7 + late-arm | 65,473, 0 | 97 / 97 / 0 |

Each config ran twice with identical results (8 runs). In every run: every decision's logits and class equal the
Keras golden stream (`ref/golden/x310_stream_*`, sha256 in each log header), every tau equals the tap time of
its newest sample, every decision comes exactly L = 19 edges after that sample, the pass-through outputs equal the
inputs on every cycle (random values on all radio signals), every window's MISR / count / per-class counts /
first and last tau equal the Python model, LATE is set for the late-armed window and clear for the others,
REG_DEC = 65,473, AXIS rules hold. Time bases cross 2^32 (seeds 0, 1) and 2^63 (seed 3).
**Negative controls** (`nsclf_lc2_neg_*.log`), all FAIL as required: one expected logit bit of decision 777
flipped; window 0's expected MISR bit 0 flipped; event 5's model run length changed.

**Lint.** `make -C tb nsclf_lint`: nsclf_user + core, `-Wall`: 0 warnings. `make -C tb nsclf_block_lint`
(`nsclf_block_lint_lc2.log`): rfnoc_block_nsclf + generated noc_shell_nsclf + the UHD library it pulls in (FIFO IPs
stubbed, `tb/nsclf_lint_stubs.sv` from the probe): **0 errors; 0 warnings in the hand-written RTL**; 89 warnings,
all in framework files: noc_shell / template (zero-width CHDR input port `[(0)-1:0]` ASCRANGE, unused
data_i_flush_* of a block without inputs, unconnected reset outputs, unused ctrlport_clk / axis_data_clk which equal
radio_clk), UHD library (TIMESCALEMOD, GENUNNAMED, WIDTHEXPAND) and the stubs.

**UHD 4.9 RFNoC testbench flow (xsim, Vivado 2024.2, build-host).** `sw/x310/uhdsim/run_uhdsim.sh` runs UHD's own sim
makefiles (`viv_simulator.mak`, `axi_fifo_2clk_sim.v` for the crossings) in `.scratch/s5_uhdsim/`:
- `nsclf rfnoc_block_nsclf_tb` (`tb/rfnoc_block_nsclf_tb.sv`, the whole block with UHD's RfnocBlockCtrlBfm,
  radio 200 MHz / CHDR 187.5 MHz / ctrl 125 MHz, BFM stall probability 25 %): **PASSED**
  (`uhdsim_nsclf_rfnoc_block_nsclf_tb.log`): NOC ID, ports, MTU; ID / VERSION / LATENCY = 19 / K = 16 read
  through AXIS-Ctrl; golden stream on channel 0 (one sample per clock): MISR 0xb7761c4cde1360f3 over all 65,473
  decisions = the model, REG_DEC = 65,473, 264 CHDR event packets each with has_time, 24 bytes and timestamp =
  word 0, 0 dropped, and all 264 equal the model's hysteresis (`uhdsim_nsclf_check_events.log`); pass-through 0
  mismatches. 343 us of simulated time, ~8 min.
- `radio_ts` (section 3): offset 6 with EN_COMP_GAIN_RX = 1, 0 without; 1,000 / 1,000 words each.
  (Verilator cannot elaborate UHD's radio_core at NSPC = 1: zero-width part selects are an Unsupported error.)

**Replay chain self-test** (`sw/x310/nsclf_replay.py selftest`, `replay_selftest*.log`): the golden stream posing as
a capture with host time T = 2^32 + 12345, the Python model posing as silicon; the replay drives sample k at tap time
T - 6 + k and arms the window nsclf_host.py would arm: MISR 0xb7761c4cde1360f3, 65,473 decisions, 264 events, all
equal: **PASS**. Negatives: one sample's I bit 13 flipped -> MISR and counts differ, FAIL; replay misaligned by one
sample -> FAIL. (An I bit-0 flip does not change any logit: the input quantizer keeps 1-5 bits per lane after BFP,
so the MISR is a check on the classifier's arithmetic, not on sample LSBs.)

## 8. Image build (model: Vivado 2024.2 P&R on build-host)

All builds: Vivado 2024.2 (SW Build 5239630) on build-host, xc7k410tffg900-2, cutoff 2, the RTL of section 7 (sha256 in
`build/provenance.txt`), image core `build/x310_XG_nsclf.yml` = the committed one (`icore_vs_committed.diff` empty),
generated image core in `build/rfnoc_image_core.sv`. Every number below is from a report written after its checkpoint
(timestamps checked). Big artefacts stay in `.scratch/s5_build/` (git-ignored).

| run | dir (.scratch/s5_build/) | flow | WNS | WHS | WPWS | result |
|---|---|---|---|---|---|---|
| UHD flow | `x310_xg_nsclf_lc2_1` | synth 30 min + UHD impl (place ExtraNetDelay_high), 125 min | -0.012 | -0.140 | +0.001 | `[Builder 0-0] did not satisfy timing` (make rc 2); x300.bit written but not closed |
| hold fix | `x310_xg_nsclf_lc2_1_holdfix/physopt_hold` | holdfix.tcl ExploreWithHoldFix on its post_route | -0.012 | -0.076 | | not closed |
| hold fix | `.../physopt_then_reroute` | + route_design Explore | -0.012 | -0.076 | | not closed |
| net reroute | `x310_xg_nsclf_lc2_1_netfix` | delay-driven reroute of the 3 failing nets | -0.012 | | | no effect; stopped |
| **variant** | **`x310_xg_nsclf_lc2_1_impl_AltSpreadLogic_high`** | `x310_nsclf_impl_variant.tcl` from the UHD build's post_synth.dcp: UHD's steps, place AltSpreadLogic_high | **+0.016** | **+0.003** | **+0.001** | **"All user specified timing constraints are met"**, bitstream |
| variant | `..._impl_Explore` | place Explore | +0.016 | -0.180 (before hold fix) | | stopped once the above closed |
| variant | `..._impl_ExtraTimingOpt` | place ExtraTimingOpt | -0.063 (routing) | | | stopped |

**What failed in the UHD-flow build, and what it was not:** setup -0.012 ns on 3 endpoints, all the stock ADC capture
crossing of daughterboard B: `cap_db1/gen_lvds_pins[*].iddr_i` (ILOGIC_X0Y274) -> `cap_db1/adc_data_rclk_reg[*]`, a
`set_max_delay 0.950 -datapath_only` from UHD's timing.xdc (0.392 ns IDDR + 0.520 ns route to the adjacent slice);
hold -0.140 ns on 57 endpoints in XG_CLK (the encrypted 10GBASE-R PCS/PMA, as in the stock build). Slices were 98.0 %
occupied. radio_clk itself was +0.225 / +0.050; no path in nsclf0 failed. The spread-logic placement fixed both.

**Closed image (`build/closed_AltSpreadLogic_high/`, fresh `report_timing_summary` of post_route.dcp 04:15:47, report
04:24; `summary.txt` from `synth/scripts/x310_nsclf_report.tcl`):**
- overall WNS +0.016 ns (DB1_DAC_DCI, stock DAC interface), TNS 0, WHS +0.003 ns, THS 0, WPWS +0.001 ns;
- radio_clk (200 MHz, this group includes the ADC capture crossings) WNS +0.058, WHS +0.045; bus_clk +0.111 / +0.017;
  ce_clk +0.291 / +0.050; XG_CLK +0.904 / +0.035 (all clocks in `summary.txt`);
- **paths inside nsclf0 (endpoints or startpoints in the block, 22,557 sequential cells): worst setup +0.373 ns**
  (da4ml core stage 1 -> stage 2, 2 logic levels), then +0.403 (timekeeper -> TIME_HI shadow), worst hold +0.045 ns.
  So the radio_clk paths through the classifier close with 0.37 ns to spare (OOC alone: +0.281).
- Utilisation (post-route, `util.rpt`): Slice LUTs 168,715 / 254,200 (66.4 %; stock 143,664), registers 242,808
  (47.8 %), BRAM tiles 483 (60.8 %), DSP 356 (23.1 %; stock 393, ddc0 lost a channel), occupied slices 59,218 /
  63,550 (93.2 %). nsclf0: 24,748 LUT, 21,914 FF, 1 BRAM, 0 DSP (noc_shell 1,362 LUT; classifier 22,582).
- **Bitstream: `.scratch/s5_build/x310_xg_nsclf_lc2_1_impl_AltSpreadLogic_high/x300.bit`** (2026-10-30 04:19:13, md5
  378a1fef249c297aff7189f184f97eb3; `.bin` 1396ef9f2970bedccac8147721882160), written 3.5 min after its post_route.dcp.
  Bitstream properties as UHD's build_x300.tcl (STARTUP.MATCH_CYCLE NoWait, COMPRESS False, CONFIGRATE 6).
  No UHD `build/` export (.lvbitx) was made; a JTAG load needs only the .bit.
- `write_bitstream` again reports **CRITICAL WARNING [Vivado 12-1790] evaluation cores** (as the stock build):
  the image may stop working after a time limit; volatile JTAG loads restart it.
- The UHD-flow x300.bit in `x310_xg_nsclf_lc2_1/build-usrp_x310_fpga_XG_nsclf/` is NOT closed: do not load it.

## 9. Host side (`sw/x310/`, all **untested** against hardware)

- `nsclf_host.py` (UHD 4.9 Python, `/usr/bin/python3.12` after `source .scratch/uhd-install/env.sh`; every API name
  it uses was checked to exist in the built `uhd` module): `info`, `peek`, `poke`, `capture` (timed finite capture
  of radio0 ch 0, sc16 at 200 MS/s, window armed for the same decisions, event receiver thread on nsclf0 -> ep6,
  saves `.npz` + `.json`; checks first packet ticks = T, contiguity, STATUS done / not late, count = N - 63).
  Event decoding assumes item 0 of a 64-bit word is bits [31:0]; it checks word 0 against the packet timestamp
  and `--swap-words` flips the order if the first silicon run shows otherwise.
- `nsclf_replay.py replay <stem>`: capture -> Verilator replay (`make -C tb nsclf_replay`) -> compare MISR, counts,
  first/last tau and the events after the first common one; `--extra-offset` shifts the assumed tap time
  (diagnostic if the offset of 6 were wrong on silicon).
- `program_x310_jtag.sh` / `.tcl`: volatile JTAG load, adapted from `<lab-share>/fpga/ettus/program_x310.tcl`
  (provenance header); requires a named JTAG target and an xc7k410t on it; never flash, never `uhd_image_loader`.

## 10. Commands

```
rfnoc/gen_nsclf.sh [--check]                                   # regenerate / check noc_shell + block wrapper
ssh build-host 'cd <proj> && make -C tb nsclf LC=2 JOBS=16'         # Verilator regression + negatives
ssh build-host 'cd <proj> && make -C tb nsclf_block_lint LC=2'      # lint incl. noc_shell + UHD lib
ssh build-host 'cd <proj> && make -C tb nsclf_uhdsim'               # UHD flow, whole block (+ event check)
ssh build-host 'cd <proj> && make -C tb radio_ts'                   # host ts = tap + 6 (and the + 0 control)
python3 sw/x310/nsclf_replay.py selftest [--flip 30000 | --shift 1]                   # replay chain (sim)
.venv/bin/python sw/x310/nsclf_kchoice.py                      # K default
synth/scripts/launch_x310_nsclf.sh x310_xg_nsclf_lc2_1 2       # image (desk-pc -> make on build-host, detached)
# directive variant from the UHD build's post_synth.dcp (build-host, detached), and the fresh reports:
ssh build-host 'cd <O> && source <xilinx-tools>/Vivado/2024.2/settings64.sh && setsid nohup vivado -mode batch \
  -nojournal -log <O>/impl.log -source <proj>/synth/scripts/x310_nsclf_impl_variant.tcl -tclargs \
  <proj>/.scratch/s5_build/x310_xg_nsclf_lc2_1/build-usrp_x310_fpga_XG_nsclf/post_synth.dcp <O> AltSpreadLogic_high &'
vivado -mode batch -nojournal -source synth/scripts/x310_nsclf_report.tcl -tclargs <O>/post_route.dcp <O>/report_fresh
# hold fix (stock recipe) on a UHD-flow post_route.dcp:
vivado -mode batch -source evidence/stage5/toolchain/holdfix.tcl -tclargs <post_route.dcp> <outdir> physopt_hold
# hardware (untested): sw/x310/program_x310_jtag.sh <bit> list | <bit> <target>; then
source .scratch/uhd-install/env.sh; /usr/bin/python3.12 sw/x310/nsclf_host.py --args addr=10.0.10.2 info
/usr/bin/python3.12 sw/x310/nsclf_host.py capture --freq <Hz> --gain <dB> --n 1048576 --out cap1
python3 sw/x310/nsclf_replay.py replay cap1
```

## 11. Doubts and open items

1. **Nothing ran on an X310.** The host tools are untested; the first silicon session should run `info`, then
   a short `capture` with `--no-events`, then with events, checking word 0 = timestamp (else `--swap-words`).
2. **200 MS/s to the host in Python.** One sc16 channel at 200 MS/s is 6.4 Gb/s on one 10 GbE link; UHD supports
   it on the X310, but a Python recv loop may overflow. Captures are finite (num_done) and the tool reports
   overflows / discontinuities; if Python cannot keep up, use UHD's C++ `rx_samples_to_file` with the same timed
   start and the window armed by `nsclf_host.py`, or shorter captures.
3. **The raw ch 0 path changes the stock DSP chain** (D-S5-CAP): host applications that expect ddc0 on RF A ch 0
   (multi_usrp at rates below 200 MS/s on that channel) get no decimation there. RF A ch 1 and RF B are unchanged.
   The DDC's non-transparency is derived from its RTL, not simulated.
4. **The +6 tick offset** is proven on UHD's radio_core in xsim with the X310's settings, not on silicon; the
   replay's `--extra-offset` and the MISR would show a different value at once (a 1-sample shift fails the
   self-test).
5. **DC-offset correction** is on by default and changes what the classifier sees relative to its channel model
   (the model had a DC offset and no notch). Whether to turn it off for the classifier is a choice for the silicon
   session (`--dc-offset off`); it applies to the stock radio's samples too (same front end).
6. **Evaluation-core warning** of the stock build (toolchain README section 5, Vivado 12-1790, most likely the
   10GBASE-R PCS/PMA under build-host's System Edition eval licence) applies to this image as well; check the build log.
   build-host's licence expires 07-Nov-2026.
7. **K = 16 was chosen after looking at the sweep** (on model labels of the stream, which has no real-world false
   alarm statistics); it is a register, so silicon tuning needs no rebuild.
8. **MISR sensitivity:** the MISR covers all logit bits, but sample bits the classifier ignores (LSBs below the input
   quantizer's kept bits) cannot be checked by it; the capture's own integrity rests on UHD's sequence checks.
9. Framework-file lint warnings (section 7) are left as generated.
