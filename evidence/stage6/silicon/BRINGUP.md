# Stage 6 silicon bring-up log (desk BCU-1525 #2, JTAG serial DESK-BCU-JTAG)

All access through `sw/bcu/desk.sh` on build-host under `.opus_nsinfer_desk_bcu.lock`; volatile JTAG loads only, nothing
written to flash; the PCIe card (PCIE-BCU-JTAG) was not opened. The QSFP+ 40G DAC stayed as Stage 3/4 left it
(QSFP0 <-> QSFP1 on the desk card); nothing was reseated.

## 2026-11-03: build s6_lc8_a (d = 3, lc8, TX_REG = RX_REG = 0), first load
- **Targets (`desk.sh list`):** `Digilent/X310-JTAG` (the X310), `Xilinx/DESK-BCU-JTAGA` (desk card), `Xilinx/PCIE-BCU-JTAG`
  (PCIe card). Only the desk card was opened.
- **Load (`program_s6_lc8_a_1.log`):** bit sha256 `fd7dbea9…` (`../build/s6_lc8_a/bitstream_sha256.txt`). Right after the
  load, during the 1.34 s power-on hold: ID `0x53330001`, LINK `0x000c1010` (GTPOWERGOOD A and B, both modules present).
- **Status after the hold (`bringup_status_1.log`):** LINK `0x010c7373`: block lock on both ends (bits 0, 1, 8, 9), TX reset
  done, TX user clock active, RX reset done, CDR stable, init done. FREQ_A = FREQ_B = 27,033,600 = 161.1328125 MHz against the
  100 MHz init clock (the one loop clock). Diag: 32 slips at end A, 57 at end B before lock, 1 lock acquisition each, no lock loss,
  no invalid header, no bad idle, RXBUFSTATUS / TXBUFSTATUS 0, no RX buffer reset. **The link came up on the first load, with
  one reference clock and one user clock**, i.e. the shared-refclk and RXUSRCLK-from-TXOUTCLK risks of docs/PLAN.md D-S6-CLK
  did not materialise.
- **Runs:** `s6_lc8_a_cable_run1` and `_run2` on this load, `s6_lc8_a_retrain_1` (BOARD[8] = gtwiz_reset_all pulse: new QPLL
  lock, TX / RX resets, new block lock; LINK `0x010c7373` again), then `s6_lc8_a_cable_run3`. Near-end PMA loopback of end A
  (BOARD = 0x002) locked within the `wait` every time and the link came back after it.
- **Finding:** in run 3 the back-to-back probe reported sent = received + 1 in both directions. Cause: `s6_probe` counted an
  accept in the cycle in which probe_en fell, when the link input had already switched back to side A (the word was never
  sent). Fixed in RTL (count only while en), regression case added to tb_s6_loop (six stops at varied phases), the old counter
  fails it (`../verilator/s6_loop_negctl_probe_counter.log`). Latency statistics were not affected (they are taken at the
  receiver). Build s6_lc8_b carries the fix.

## 2026-11-05: build s6d5_lc3bc_a (d = 5, 3 lanes per cage)
- `desk.sh list` first: the desk card enumerated as before (`Xilinx/DESK-BCU-JTAGA`); nothing needed hands.
- **Load (`program_s6d5_lc3bc_a_1.log`):** bit sha256 `7affdf92…`; after the 1.34 s hold (`s6d5_lc3bc_a_status_1.log`) LINK
  `0x7f0c7373`: all six lanes locked (bits 25-30), both ends locked, NVEC 131072, DEC_LAT 19, N_DET 120, DW 192, D_PARAMS NL = 3.
  76 / 27 slips at end A / B before lock, no lock loss, no error, buffers nominal.
- Runs `s6d5_lc3bc_a_cable_run{1,2}`, re-train (`s6d5_lc3bc_a_retrain_1.log`, LINK `0x7f0c7373` again), `run3`: all PASS.
- **Board state left:** build s6d5_lc3bc_a loaded on the desk card (volatile); the desk lock is released.
