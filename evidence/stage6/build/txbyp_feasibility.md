# TX buffer bypass with the 64B/66B synchronous gearbox: wizard feasibility (2026-11-06)

Plan: `docs/superpowers/plans/2026-11-06-stage6-next.md` Task 3. Question: does the GT Wizard (gtwizard_ultrascale 1.7,
Vivado 2024.2) build the Stage 6 link core with the TX buffer bypassed, the 64B/66B synchronous gearbox kept, the RX side
unchanged and every user clock still on the one TXOUTCLK BUFG_GT? Label: **model** (tool output, not a measurement).

Command (build-host): `vivado -mode batch -nojournal -source synth/scripts/s6_gen_gt.tcl -tclargs txbyp synth` -> core
`rtl/ip/s6_gt_bp/` (only the `.xci` is tracked; the rest regenerates). Same channels (X1Y44, X1Y48), refclk (MGTREFCLK1 of
quad 231, "clk1+1" for X1Y44), QPLL1, 10.3125 Gb/s, 64/64 width as `s6_gt`; set: `TX_BUFFER_MODE 0`,
`LOCATE_TX_BUFFER_BYPASS_CONTROLLER CORE`; `txbufstatus_out` dropped.

## What the wizard produced

| Item | s6_gt (today) | s6_gt_bp |
|---|---|---|
| TX_BUFFER_MODE / TXBUF_EN | 1 / TRUE | **0 / FALSE** |
| TX_XCLK_SEL | TXOUT | **TXUSR** |
| TXGEARBOX_EN, GEARBOX_MODE | TRUE, 5'b00001 (sync) | TRUE, 5'b00001 (sync): unchanged |
| TX_OUTCLK_SOURCE | TXOUTCLKPMA | **TXPLLREFCLK_DIV1** (forced by the wizard: the 161.1328125 MHz refclk through the channel; same frequency, same TXOUTCLK pin, same BUFG_GT) |
| TXSYNC_MULTILANE / TXSYNC_OVRD | - | 1 / 0: multi-lane auto phase alignment (UG578 TX buffer bypass) |
| C_TX_BUFFBYPASS_MODE / INSTANCE_CTRL | - | 0 (auto) / 0 (one controller for both channels) |
| buffer-bypass controller clock | - | `txusrclk2_int[master]` = the loop clock `clk` |
| RX_BUFFER_MODE, RX user clocking | 1, EXAMPLE_DESIGN | 1, EXAMPLE_DESIGN: unchanged (RXUSRCLK/RXUSRCLK2 stay on `clk`) |
| ports | ... `txbufstatus_out` | + `gtwiz_buffbypass_tx_{reset_in,start_user_in,done_out,error_out}` (1 bit each), - `txbufstatus_out` |

## Verdict: go

- The gearbox and the bypass are accepted together at 64/64 width; no validation error (`.scratch/s6/gen/gen_bp.log`).
- No second clock: TX user clocking is still the in-core helper on the master channel's TXOUTCLK (now TXPLLREFCLK_DIV1 at the
  same 161.13 MHz), the bypass controller runs on that clock, and the RX side is untouched. The routed-netlist single-clock
  check of `s6_build.tcl` decides it for the build.
- Not known until silicon: the latency saving (second-hand, 32-bit width: TX buffer 7.7-10.9 ns, `docs/stage6_survey.md` §3.0),
  and whether phase alignment across the two quads (X1Y44 in 230, X1Y48 in 231) completes on every bring-up.

Wiring in `s6_top` (TXBYP = 1): `gtwiz_buffbypass_tx_reset_in = ~gtwiz_userclk_tx_active_out`, `start_user_in = 0` (auto
start after TX reset done), the link's TX reset released only on `tx_done & done_out`; LINK[20] = done, LINK[21] = error.
