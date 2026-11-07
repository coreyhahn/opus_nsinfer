# Stage 6 loop: register map (`s6_core`, AXI4-Lite, 32 bit, init_clk)

`0x0000-0x0FFF` is `s3_regs`, unchanged (`rtl/s3/s3_regmap.md`), except the meaning of BOARD and LINK below.
`0x1000-0x1FFF` is `s6_diag`. Unmapped reads return `0xDEADBEEF`. One clock (`clk`, the TX user clock) runs the
loop; side A's and side B's counters are both in it (s3_regs' `clk_a` = `clk_b` = `clk`).

## s3_regs registers whose bits differ from Stage 3

| Offset | Name | Bits |
|---|---|---|
| 0x020 | BOARD | [2:0] LOOPBACK of the end-A channel(s) (QSFP0; 3'b010 = near-end PMA), [6:4] the same for end B (QSFP1), [8] gtwiz_reset_all, [9] gtwiz_reset_rx_datapath (both ends: one wizard) |
| 0x024 | LINK | [0] block lock A (every lane of QSFP0's RX), [1] = [0], [2] lock lost A (sticky), [3] invalid header or bad idle at A (sticky), [4] GTPOWERGOOD A, [5] gtwiz_reset_tx_done, [6] gtwiz_userclk_tx_active; [8] lock B (QSFP1's RX), [9] = [8], [10] lock lost B (sticky), [11] header / idle error B (sticky), [12] GTPOWERGOOD B, [13] gtwiz_reset_rx_done, [14] gtwiz_reset_rx_cdr_stable; [16] QSFP0 ModPrsL, [17] QSFP1 ModPrsL, [18] QSFP0 IntL, [19] QSFP1 IntL; [20] TX buffer-bypass phase alignment done, [21] its error (TXBYP = 1 builds; 0 otherwise); [24] init done (power-on hold released); NL = 3: [25+i] lane i lock A, [28+i] lane i lock B. Stickies clear with CTRL soft_rst_a ([2], [3]) / soft_rst_b ([10], [11]) |
| 0x028 | FREQ_A | loop clock cycles per 2^24 init_clk cycles (161.1328125 MHz nominal: 27033600) |
| 0x02C | FREQ_B | = FREQ_A (one clock) |

## s6_diag (`rtl/s6/s6_diag.sv`)

| Offset | Name | Access | Bits |
|---|---|---|---|
| 0x1000 | D_ID | RO | `0x5336_0001` |
| 0x1004 | D_CTRL | RW | [0] probe_en: both ends send probe words (the s3 sides see no RX until 2047 cycles after it falls), [1] clr: zero the link / probe counters while 1 |
| 0x1008 | D_PERIOD | RW | [15:0] one probe word every PERIOD+1 cycles (counted from the accept edge) |
| 0x100C | D_HBASE | RW | [15:0] latency of probe histogram bin 0 |
| 0x1010 | D_SNAP | W: capture; R: [0] busy | copies every live word into the snapshot (clk domain), read below |
| 0x1014 | D_PARAMS | RO | [3:0] NL, [4] TX_REG, [5] RX_REG |
| 0x1400 + 4k | snapshot word k | RO | k below |

| k | word (end A = QSFP0's RX, end B = QSFP1's RX) |
|---|---|
| 0 / 16 | lock per lane (A / B) |
| 1 / 17 | lock acquisitions |
| 2 / 18 | lock losses |
| 3 / 19 | RXGEARBOXSLIP pulses |
| 4 / 20 | invalid sync headers while locked |
| 5 / 21 | control blocks whose payload is not IDLE, while locked |
| 6 / 22 | words delivered |
| 7 / 23 | deskew FIFO overflows (NL > 1) |
| 8 / 24 | cycles with RXHEADERVALID != RXDATAVALID on a lane |
| 9 / 25 | RX buffer resets issued (RXBUFSTATUS[2]) |
| 10 / 26 | [8:0] RXBUFSTATUS (3 bits per lane, live), [15:10] TXBUFSTATUS (2 per lane, live), [18:16] RX buffer error seen per lane (sticky), [22:20] TX buffer error seen |
| 11 / 27 | check blocks that matched (count and CRC-32 of the data blocks since the last check; summed over lanes; the first after lock is not counted) |
| 12 / 28 | check blocks that did not match |
| 32..38 | probe at end A: [32] words A sent, [33] words received at A (from B, or from A itself in PMA loopback), [34] bad words / sequence gaps, [35] min, [36] max, [37] sum[31:0], [38] sum[47:32] of the one-way latency into A |
| 40..46 | probe at end B: the same, latency A -> B |
| 48 | the shared timestamp counter |
| 64..95 | histogram at A (32 bins from D_HBASE) |
| 96..127 | histogram at B |

Probe latency: start = the clk edge at which the sending end's link TX accepts the probe word (tvalid & tready),
stop = the clk edge at which the receiving end registers it (as s3_side_a's / s3_side_b's RX register), both read
from the one shared counter: one-way, in clk cycles.
