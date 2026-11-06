# Stage 3 decoder loop: register map (`s3_regs`, AXI4-Lite, 32 bit, clk_axi)

Byte offsets, full-word accesses (WSTRB ignored). Unmapped reads return `0xDEADBEEF`.

## Control and handshake

| Offset | Name      | Access | Bits |
|--------|-----------|--------|------|
| 0x000  | ID        | RO | `0x5333_0001` |
| 0x004  | CTRL      | RW | [0] run, [1] mode_echo, [4] soft_rst_a, [5] soft_rst_b |
| 0x008  | GAP       | RW | [15:0] idle cycles between shots: one shot every GAP+1 clk_a cycles |
| 0x00C  | HIST_BASE | RW | [15:0] latency (clk_a cycles) of histogram bin 0 |
| 0x010  | STATUS    | RO | [0] done (snapshot valid), [1] timeout, [2] rd_busy |
| 0x014  | RD_CMD    | W  | [31] sel (0 histogram bin, 1 flag RAM entry), [23:0] addr; starts a read (ignored while busy) |
|        |           | R  | [31] sel, [30] rd_busy, [23:0] addr |
| 0x018  | RD_DATA   | RO | last completed read: histogram count, or `{30'b0, seen, flip}` |
| 0x020  | BOARD     | RW | (s3_top) [2:0] GT loopback A, [6:4] GT loopback B (3'b010 = near-end PMA), [8] force pma_init A+B, [9] force reset_pb A+B |
| 0x024  | LINK      | RO | (s3_top, 2-flop synchronised) [0] channel_up A, [1] lane_up A, [2] hard_err A (sticky), [3] soft_err A (sticky), [4] gt_powergood A, [5] gt_pll_lock A, [6] user_clk A active; [8..14] same for B; [16] QSFP0 ModPrsL, [17] QSFP1 ModPrsL, [18] QSFP0 IntL, [19] QSFP1 IntL; [24] init done (pma_init released); DW = 192 only: [25+i] lane_up A lane i, [28+i] lane_up B lane i, i = 0..2 (0 at DW = 64). With 3 lanes, [1]/[9] lane_up and [4]/[12] gt_powergood are the AND over the lanes |
| 0x028  | FREQ_A    | RO | user_clk A cycles per 2^24 init_clk cycles (161.1328125 MHz nominal at 100 MHz init_clk: 27033600) |
| 0x02C  | FREQ_B    | RO | same for B |

## Side A snapshot (clk_a counters, sampled when done rises)

| Offset | Field | Meaning |
|--------|-------|---------|
| 0x040 | n_sent      | TX beats accepted |
| 0x044 | n_rx_words  | RX beats seen while playing / waiting |
| 0x048 | n_good      | good responses (= latency sample count) |
| 0x04C | lat_min     | loop latency, clk_a cycles (TX accept edge -> RX register edge) |
| 0x050 | lat_max     | |
| 0x054 | lat_sum_lo  | [31:0] of the 48-bit sum |
| 0x058 | lat_sum_hi  | [15:0] = sum[47:32] |
| 0x05C | mism        | good responses whose flip differs from the expected decision (0 in echo mode) |
| 0x060 | first_mis   | [31] valid, [23:0] seq of the first mismatch |
| 0x064 | err_tag     | RX tag != 0x5A |
| 0x068 | err_range   | seq >= NVEC or not yet sent |
| 0x06C | err_overrun | timestamp slot seq[9:0] reused (more than 1024 shots in flight) |
| 0x070 | err_dup     | seq already returned this run |
| 0x074 | err_echo    | echo flag != mode_echo |
| 0x078 | hist_under  | latency < HIST_BASE |
| 0x07C | hist_over   | latency >= HIST_BASE + 256 |
| 0x080 | sig         | MISR over good responses in return order (CRC-32 polynomial 0x04C11DB7, init 0xFFFFFFFF): `sig' = {sig[30:0],0} ^ (sig[31] ? 0x04C11DB7 : 0) ^ {7'b0, seq, flip}` |

## Side B snapshot (clk_b counters, same sample instant)

| Offset | Field | Meaning |
|--------|-------|---------|
| 0x0C0 | n_rx      | RX beats with tag 0xA5 |
| 0x0C4 | n_tx      | TX beats accepted |
| 0x0C8 | err_tag   | RX beats with a wrong tag (dropped) |
| 0x0CC | fifo_ovf  | response words dropped at a full TX FIFO |
| 0x0D0 | collide   | echo words dropped (a decode word left the pipe the same cycle) |
| 0x0D4 | fifo_max  | [4:0] TX FIFO peak occupancy |
| 0x0D8 | dec       | [31:16] max, [15:0] min: RX register -> TX FIFO write, clk_b cycles (expected DEC_LAT + 1) |
| 0x0DC | dec_cnt   | |
| 0x0E0 | echo      | [31:16] max, [15:0] min (expected 1) |
| 0x0E4 | echo_cnt  | |

## Build parameters

| Offset | Field |
|--------|-------|
| 0x0F0 | NVEC |
| 0x0F4 | DEC_LAT (det applied -> flip valid, edges = metadata latency + 2) |
| 0x0F8 | TIMEOUT (clk_a cycles after the last send) |
| 0x0FC | N_DET (detection bits per shot: 24 for d = 3, 120 for d = 5) |
| 0x100 | DW (Aurora user data width: 64 for the 1-lane cores, 192 for the 3-lane cores) |

N_DET and DW give the word formats (`s3_pkg.sv`):
- A -> B: `[DW-1:DW-8]` tag 0xA5, `[DW-9:DW-32]` seq, `[N_DET]` mode_echo, `[N_DET-1:0]` det, the rest 0.
- B -> A: `[DW-1:DW-8]` tag 0x5A, `[DW-9:DW-32]` seq, `[1]` echo flag, `[0]` flip, the rest 0.
- At DW = 64, N_DET = 24 this is the Stage 3 layout (`[63:56]`, `[55:32]`, `[24]`, `[23:0]`).

## Use

1. Write GAP, HIST_BASE, CTRL.mode_echo (run = 0). Optionally pulse soft_rst_b to zero side B's counters.
2. Set CTRL.run. Side A clears its flag RAM and histogram (max(NVEC, 256) cycles), plays NVEC shots, waits.
3. Poll STATUS until done = 1. Read the snapshot, the histogram (RD_CMD sel 0, addr 0..255) and the flag
   RAM (RD_CMD sel 1, addr = seq): write RD_CMD, poll until rd_busy = 0, read RD_DATA.
4. Clear CTRL.run (side A back to idle, done = 0); the next run re-arms the snapshot.

## Clock crossings (no async FIFOs)

* Control -> clk_a (run, mode_echo, GAP, HIST_BASE, soft_rst_a) and clk_b (soft_rst_b): 2-flop
  synchronisers (`ASYNC_REG`), quasi-static: change GAP / HIST_BASE / mode only while run = 0.
* Status: side A raises done when its counters are final and ignores the link while done, and side B
  is idle once A holds every response, so both buses are static while done = 1. done crosses through
  2 flops; the buses are sampled into the snapshot one clk_axi cycle later. Bus reads return the
  snapshot, never the live counters.
* Histogram / flag RAM reads: toggle handshake. RD_CMD toggles a request bit with sel/addr held in
  clk_axi registers; clk_a sees it through 2 flops + an edge detector (rd_req pulse), side A answers 3
  edges later (rd_ack pulse, rd_data held), the ack toggle crosses back through 2 flops and RD_DATA is
  sampled. Only valid while side A is not busy (the flag RAM read port is shared with the RX path).
* Implementation: every crossing path needs `set_max_delay -datapath_only` of one destination period.
