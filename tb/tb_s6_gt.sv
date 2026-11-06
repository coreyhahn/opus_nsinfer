// tb_s6_gt: behavioural model of one direction of the Stage 6 link: the TX half of a GTY channel in 64B/66B
// synchronous-gearbox mode (8-byte interface, 8-byte internal datapath, external TXSEQUENCE), the serial wire,
// and the RX half of the far channel (RX buffer + RX synchronous gearbox with RXGEARBOXSLIP). All on ONE clock
// (the Stage 6 design rule: both ends share the reference clock and the user clock). MODEL, not the GTY.
//
// Negedge discipline: the model acts dly_ns after each negedge (default 1.5 ns, before the next posedge): the
// values on txdata / txheader / txsequence then are the block the GT takes at the next posedge; the rx outputs it
// sets then are captured by the DUT at the next posedge. TB stimulus goes before dly_ns, TB sampling after.
//   TX: a block is taken whenever tx_en and TXSEQUENCE[5:0] != 32 (UG578 Table 3-10: the 8-byte / 8-byte mode
//       pauses two cycles in 66). Block j occupies wire bits 66j .. 66j+65, header first (TXHEADER[1], [0]), then
//       TXDATA[63] .. [0] (UG578 p. 115, MSB first).
//   wire: bit p has fully arrived at the far RX in cycle k when 64 k - B0 > p, B0 = 64 c_first + lat_ui (c_first =
//       the cycle of the first block): 64 bits per cycle, a fixed latency of lat_ui unit intervals (TX PCS + PMA,
//       cable, RX PMA + buffer, as one number). Before the first block and for negative positions: random bits.
//   RX: (rx_en) outputs the 66-bit block starting at bit s as soon as all its bits have arrived, at most one block
//       per cycle (so RXDATAVALID / RXHEADERVALID drop about 2 cycles in 66, together); s advances by 66; a slip
//       (RXGEARBOXSLIP seen at a negedge) moves s by one bit. The first RX block starts at a random bit (block sync
//       has to find the boundary). Before the TX starts, RX outputs random blocks.
//   impairments (set by the TB): ber_blk = N > 0 flips one random bit in about one of N RX blocks; glitch_at = a
//       cycle at which one extra bit appears on the wire (the boundary moves: block lock must be lost and found
//       again); burst_at / burst_len = RX blocks replaced by random bits.
//   MITM = 1 (lane 0 of the B -> A direction in the loop TB): the model descrambles each TX block with its own
//       descrambler, can invert payload bit 0 (the s3 flip bit) of the data block taken in cycle flip_at (the TB
//       picks the cycle of one returned word: the s3 negative control), and re-scrambles with its own scrambler.
`timescale 1ns / 1fs

module tb_s6_gtch
  import s6_pkg::*;
#(
    parameter int MITM = 0
) (
    input  logic        clk,
    input  logic        tx_en,
    input  logic [63:0] txdata,
    input  logic [1:0]  txheader,
    input  logic [6:0]  txseq,
    input  logic        rx_en,
    input  logic        slip,
    output logic [63:0] rxdata,
    output logic [1:0]  rxheader,
    output logic        rxdv,
    output logic        rxhv
);
  int          lat_ui = 640;
  real         dly_ns = 1.5;       // the model acts this long after each negedge (TB drives before, samples after)
  int unsigned ber_blk = 0;
  longint      glitch_at = -1;
  longint      burst_at = -1;
  int          burst_len = 0;
  longint      flip_at = -1;      // MITM: invert payload bit 0 of the data block taken in this model cycle
  int unsigned seed = 1;
  longint      n_tx = 0, n_rx = 0, n_flip = 0, n_slip = 0, n_corrupt = 0;

  localparam int NB = 8192;
  logic [65:0] blk[NB];
  longint      cyc = 0, c_first = -1, b0 = 0, s = 0, gb_acc = 0;
  bit          rx_on = 1'b0;
  logic [57:0] m_dst = '0, m_sst = 58'h2AA_AAAA_AAAA_AAAA;

  initial begin rxdata = '0; rxheader = '0; rxdv = 1'b0; rxhv = 1'b0; end

  // xorshift32 (deterministic per seed, independent of the simulator's RNG)
  function automatic int unsigned xs();
    seed ^= seed << 13;
    seed ^= seed >> 17;
    seed ^= seed << 5;
    return seed;
  endfunction
  function automatic logic [65:0] rnd66();
    return {2'(xs()), xs(), xs()};
  endfunction

  function automatic logic [65:0] blk_at(input longint j);
    if (j < 0 || c_first < 0) return rnd66();
    if (j >= n_tx) $fatal(1, "tb_s6_gtch: causality: block %0d needed at cycle %0d, only %0d sent", j, cyc, n_tx);
    if (j < n_tx - NB) $fatal(1, "tb_s6_gtch: block %0d overwritten (history %0d)", j, NB);
    return blk[int'(j % NB)];
  endfunction

  function automatic logic [65:0] extract(input longint p);
    longint j, o;
    logic [131:0] w;
    j = (p >= 0) ? p / 66 : -((-p + 65) / 66);
    o = p - 66 * j;
    w = {blk_at(j), (o == 0) ? 66'd0 : blk_at(j + 1)};
    return w[131 - int'(o) -: 66];
  endfunction

  always @(negedge clk) begin
    logic [63:0] pay, clr;
    logic [65:0] b;
    #(dly_ns);
    cyc++;
    // ---------------- TX ----------------
    if (tx_en && txseq[5:0] != 6'd32) begin
      pay = txdata;
      if (MITM) begin
        {m_dst, clr} = descramble(pay, m_dst);
        if (txheader == HDR_DATA && cyc == flip_at) begin clr[0] = ~clr[0]; n_corrupt++; end
        {m_sst, pay} = scramble(clr, m_sst);
      end
      if (c_first < 0) begin c_first = cyc; b0 = 64 * c_first + lat_ui; end
      blk[int'(n_tx % NB)] = {txheader, pay};
      n_tx++;
    end
    // ---------------- RX ----------------
    rxdv = 1'b0; rxhv = 1'b0;
    if (!rx_en) begin
      rx_on = 1'b0;
    end else if (c_first < 0) begin
      // TX not started: random blocks at the line rate (64 of 66 cycles)
      gb_acc += 64;
      if (gb_acc >= 66) begin
        gb_acc -= 66; b = rnd66();
        {rxheader, rxdata} = b; rxdv = 1'b1; rxhv = 1'b1;
      end
    end else begin
      if (!rx_on) begin
        rx_on = 1'b1;
        s = 64 * cyc - b0 - 66 - longint'(xs() % 66);   // random boundary, about one block back
      end
      if (cyc == glitch_at) s = s - 1;   // one extra bit on the wire
      if (s + 66 <= 64 * cyc - b0) begin
        b = extract(s);
        s += 66;
        if (ber_blk != 0 && (xs() % ber_blk) == 0) begin b[xs() % 66] ^= 1'b1; n_flip++; end
        if (burst_at >= 0 && cyc >= burst_at && cyc < burst_at + burst_len) b = rnd66();
        {rxheader, rxdata} = b; rxdv = 1'b1; rxhv = 1'b1;
        n_rx++;
      end
      if (slip) begin s = s + 1; n_slip++; end
    end
  end
endmodule
