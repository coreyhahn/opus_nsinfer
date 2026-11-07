// s6_link: one end of the Stage 6 thin GTY link (docs/PLAN.md B.5): NL lanes, each one GTY channel with the
// 64B/66B synchronous gearbox (TX_DATA_WIDTH = TX_INT_DATAWIDTH = 64), TX and RX buffers on. Everything runs
// on the one link clock clk (= TXUSRCLK = TXUSRCLK2 = RXUSRCLK = RXUSRCLK2 of every channel).
//
// TX (per lane i, word bits [64i+63:64i]):
//   * external sequence counter (UG578 v1.4 p. 117-122, Table 3-10: 8-byte interface on the 8-byte internal
//     datapath): 0..32, incremented every second cycle; the GT ignores TXDATA/TXHEADER while TXSEQUENCE = 32
//     (two cycles in 66), so s_tready is low in exactly those cycles.
//   * block = s_tvalid ? {HDR_DATA, word} : {HDR_CTRL, CHK or IDLE_BLK}; payload scrambled (s6_pkg::scramble), the
//     scrambler advancing on every block the GT takes. Check block (s6_pkg): in a slot where the user has no word
//     and at least one data block went out since the last check, every lane sends {CHK_TYPE, n, ~crc} instead of
//     IDLE (n, crc over that lane's data payloads, registered state); data blocks and s_tready are unchanged.
//   * TX_REG = 0: TXDATA / TXHEADER / TXSEQUENCE are combinational from the user's registers and the counter: the
//     user's accept edge (s_tvalid & s_tready) is the edge at which the GT captures the block. TX_REG = 1 adds one
//     register stage (+1 cycle) for timing.
// RX (per lane):
//   * RX_REG = 1 registers the GT outputs first (+1 cycle); RX_REG = 0 uses them directly.
//   * block sync: the state machine of UG578 Fig. 4-54 (p. 305-306): lock after SH_CNT_MAX valid headers in a row,
//     lose lock at SH_INV_MAX invalid headers within SH_CNT_MAX; every invalid header while unlocked slips the
//     gearbox (RXGEARBOXSLIP, one-cycle pulse) and the next SLIP_WAIT cycles are not tested (p. 306: 32).
//   * descrambler advances on every RXDATAVALID cycle; the header type comes from the same cycle's RXHEADER (or
//     the last valid one when RXHEADERVALID and RXDATAVALID differ: counted in n_hv_dv, not expected).
//   * a data block on a locked lane is a lane word; control blocks are dropped (checked against IDLE_BLK: a
//     bit-error monitor). Check blocks: the lane's running count and CRC-32 of the data blocks it delivered since
//     the last check are compared with the block's (n_chk_ok / n_chk_bad) and restarted; the first check after
//     lock (or after rst_rx) only restarts them, since its window began before the lane was locked.
//   * NL = 1: m_tdata / m_tvalid are combinational from the (registered) GT outputs: the next register is the
//     user's RX register. NL > 1: per-lane deskew FIFO (DSK_DEPTH, show-ahead with bypass): every lane's k-th data
//     block belongs to word k (all lanes transmit their data blocks in the same cycle), so a word is out when every
//     lane has one; costs the lane skew, no marker. FIFOs are flushed while any lane is unlocked.
module s6_link
  import s6_pkg::*;
#(
    parameter int NL         = 1,
    parameter int TX_REG     = 0,
    parameter int RX_REG     = 0,
    parameter int SH_CNT_MAX = 64,
    parameter int SH_INV_MAX = 16,
    parameter int SLIP_WAIT  = 32,
    parameter int DSK_DEPTH  = 4,
    localparam int DW        = 64 * NL
) (
    input  logic            clk,
    input  logic            rst_tx,     // GT TX not ready (TX reset not done): idle, no tready
    input  logic            rst_rx,     // GT RX not ready: block sync held unlocked
    input  logic            clr,        // zero the counters
    // user TX
    input  logic [DW-1:0]   s_tdata,
    input  logic            s_tvalid,
    output logic            s_tready,
    // user RX (no back-pressure)
    output logic [DW-1:0]   m_tdata,
    output logic            m_tvalid,
    // GT TX (one channel per lane)
    output logic [DW-1:0]   gt_txdata,
    output logic [2*NL-1:0] gt_txheader,
    output logic [6:0]      gt_txsequence,   // shared by the lanes
    // GT RX
    input  logic [DW-1:0]   gt_rxdata,
    input  logic [2*NL-1:0] gt_rxheader,
    input  logic [NL-1:0]   gt_rxheadervalid,
    input  logic [NL-1:0]   gt_rxdatavalid,
    output logic [NL-1:0]   gt_rxgearboxslip,
    output logic            lock_all,
    output s6_link_stat_t   stat
);
  if (NL < 1 || NL > 3) begin : g_chk
    $error("NL must be 1..3");
  end

  // ---------------- TX ----------------
  logic [5:0] seq;
  logic       ph;
  always_ff @(posedge clk) begin
    if (rst_tx) begin
      seq <= '0; ph <= 1'b0;
    end else begin
      ph <= ~ph;
      if (ph) seq <= (seq == 6'd32) ? 6'd0 : seq + 6'd1;
    end
  end
  // seq is the value the GT sees in the cycle after the edge for TX_REG = 1, in the same cycle for TX_REG = 0
  wire slot = (seq != 6'd32);
  assign s_tready = slot && !rst_tx;

  logic [57:0]   tx_st [NL];
  logic [57:0]   tx_stn[NL];
  logic [63:0]   tx_o  [NL];
  logic [31:0]   tx_crc[NL];
  logic [23:0]   tx_n;               // data blocks since the last check block (all lanes send together)
  logic [DW-1:0] txd_c;
  logic [2*NL-1:0] txh_c;
  wire           tx_chk = !s_tvalid && (tx_n != '0);
  always_comb begin
    for (int l = 0; l < NL; l++) begin
      {tx_stn[l], tx_o[l]} = scramble(s_tvalid ? s_tdata[64*l +: 64] : tx_chk ? {CHK_TYPE, tx_n, ~tx_crc[l]} : IDLE_BLK,
                                      tx_st[l]);
      txd_c[64*l +: 64]  = tx_o[l];
      txh_c[2*l +: 2]    = s_tvalid ? HDR_DATA : HDR_CTRL;
    end
  end
  always_ff @(posedge clk) begin
    for (int l = 0; l < NL; l++) begin
      if (rst_tx) begin
        tx_st[l] <= 58'h155_5555_5555_5555; tx_crc[l] <= '1;
      end else if (slot) begin
        tx_st[l] <= tx_stn[l];
        if (s_tvalid)    tx_crc[l] <= crc32_d64(tx_crc[l], s_tdata[64*l +: 64]);
        else if (tx_chk) tx_crc[l] <= '1;
      end
    end
    if (rst_tx) tx_n <= '0;
    else if (slot) begin
      if (s_tvalid)    tx_n <= tx_n + 1'b1;
      else if (tx_chk) tx_n <= '0;
    end
  end
  if (TX_REG != 0) begin : g_txr
    always_ff @(posedge clk) begin
      gt_txdata     <= txd_c;
      gt_txheader   <= txh_c;
      gt_txsequence <= {1'b0, seq};
    end
  end else begin : g_txc
    assign gt_txdata     = txd_c;
    assign gt_txheader   = txh_c;
    assign gt_txsequence = {1'b0, seq};
  end

  // ---------------- RX: optional input register ----------------
  logic [DW-1:0]   rd;
  logic [2*NL-1:0] rh;
  logic [NL-1:0]   rhv, rdv;
  if (RX_REG != 0) begin : g_rxr
    always_ff @(posedge clk) begin
      rd <= gt_rxdata; rh <= gt_rxheader; rhv <= gt_rxheadervalid; rdv <= gt_rxdatavalid;
    end
  end else begin : g_rxc
    assign rd = gt_rxdata; assign rh = gt_rxheader; assign rhv = gt_rxheadervalid; assign rdv = gt_rxdatavalid;
  end

  // ---------------- RX per lane: block sync, descrambler, block type ----------------
  localparam int CW = $clog2(SH_CNT_MAX + 1);
  localparam int IW = $clog2(SH_INV_MAX + 1);
  localparam int WW = $clog2(SLIP_WAIT + 1);
  logic [NL-1:0]   lock, slip, lane_v, ctl_v, idle_bad, sh_bad, chk_v, chk_ok, chk_bad, chk_arm;
  logic [31:0]     rx_crc[NL];
  logic [23:0]     rx_n  [NL];
  logic [63:0]     lane_d[NL];
  logic [57:0]     rx_st [NL];
  logic [57:0]     rx_stn[NL];
  logic [1:0]      hdr_q [NL];
  logic [1:0]      hdr_e [NL];
  logic [CW-1:0]   sh_cnt[NL];
  logic [IW-1:0]   inv_cnt[NL];
  logic [WW-1:0]   wait_cnt[NL];
  always_comb begin
    for (int l = 0; l < NL; l++) begin
      {rx_stn[l], lane_d[l]} = descramble(rd[64*l +: 64], rx_st[l]);
      hdr_e[l]    = rhv[l] ? rh[2*l +: 2] : hdr_q[l];
      lane_v[l]   = rdv[l] && lock[l] && (hdr_e[l] == HDR_DATA) && !rst_rx;
      ctl_v[l]    = rdv[l] && lock[l] && (hdr_e[l] == HDR_CTRL) && !rst_rx;
      chk_v[l]    = ctl_v[l] && (lane_d[l][63:56] == CHK_TYPE);
      chk_ok[l]   = chk_v[l] && chk_arm[l] && (lane_d[l][55:32] == rx_n[l]) && (lane_d[l][31:0] == ~rx_crc[l]);
      chk_bad[l]  = chk_v[l] && chk_arm[l] && !chk_ok[l];
      idle_bad[l] = ctl_v[l] && !chk_v[l] && (lane_d[l] != IDLE_BLK);
      sh_bad[l]   = rhv[l] && lock[l] && !(rh[2*l +: 2] == HDR_DATA || rh[2*l +: 2] == HDR_CTRL);
    end
  end
  always_ff @(posedge clk) begin
    for (int l = 0; l < NL; l++) begin
      if (rhv[l]) hdr_q[l] <= rh[2*l +: 2];
      if (rdv[l]) rx_st[l] <= rx_stn[l];
      slip[l] <= 1'b0;
      if (rst_rx) begin
        lock[l] <= 1'b0; sh_cnt[l] <= '0; inv_cnt[l] <= '0; wait_cnt[l] <= WW'(SLIP_WAIT);
      end else if (wait_cnt[l] != '0) begin
        wait_cnt[l] <= wait_cnt[l] - 1'b1;
      end else if (rhv[l]) begin
        if (!(rh[2*l +: 2] == HDR_DATA || rh[2*l +: 2] == HDR_CTRL) &&
            (!lock[l] || inv_cnt[l] == IW'(SH_INV_MAX - 1))) begin
          lock[l] <= 1'b0; slip[l] <= 1'b1; wait_cnt[l] <= WW'(SLIP_WAIT); sh_cnt[l] <= '0; inv_cnt[l] <= '0;
        end else if (sh_cnt[l] == CW'(SH_CNT_MAX - 1)) begin
          if (inv_cnt[l] == '0 && (rh[2*l +: 2] == HDR_DATA || rh[2*l +: 2] == HDR_CTRL)) lock[l] <= 1'b1;
          sh_cnt[l] <= '0; inv_cnt[l] <= '0;
        end else begin
          sh_cnt[l] <= sh_cnt[l] + 1'b1;
          if (!(rh[2*l +: 2] == HDR_DATA || rh[2*l +: 2] == HDR_CTRL)) inv_cnt[l] <= inv_cnt[l] + 1'b1;
        end
      end
    end
  end
  always_ff @(posedge clk) begin
    for (int l = 0; l < NL; l++) begin
      if (rst_rx || !lock[l]) begin
        rx_crc[l] <= '1; rx_n[l] <= '0; chk_arm[l] <= 1'b0;
      end else if (lane_v[l]) begin
        rx_crc[l] <= crc32_d64(rx_crc[l], lane_d[l]); rx_n[l] <= rx_n[l] + 1'b1;
      end else if (chk_v[l]) begin
        rx_crc[l] <= '1; rx_n[l] <= '0; chk_arm[l] <= 1'b1;
      end
    end
  end
  assign gt_rxgearboxslip = slip;
  assign lock_all = &lock;

  // ---------------- word assembly ----------------
  logic dsk_ovf;
  if (NL == 1) begin : g_l1
    assign m_tdata  = lane_d[0];
    assign m_tvalid = lane_v[0];
    assign dsk_ovf  = 1'b0;
  end else begin : g_dsk
    localparam int PW = $clog2(DSK_DEPTH);
    logic [63:0]   mem[NL][DSK_DEPTH];
    logic [PW-1:0] wp[NL], rp[NL];
    logic [PW:0]   cnt[NL];
    logic [NL-1:0] has, ovf;
    logic [63:0]   head[NL];
    wire  pop = (&has) && lock_all;
    always_comb begin
      for (int l = 0; l < NL; l++) begin
        has[l]  = (cnt[l] != '0) || lane_v[l];
        head[l] = (cnt[l] != '0) ? mem[l][rp[l]] : lane_d[l];
        ovf[l]  = lane_v[l] && (cnt[l] == (PW+1)'(DSK_DEPTH)) && !pop;
      end
      for (int l = 0; l < NL; l++) m_tdata[64*l +: 64] = head[l];
    end
    assign m_tvalid = pop;
    assign dsk_ovf  = |ovf;
    always_ff @(posedge clk) begin
      for (int l = 0; l < NL; l++) begin
        logic push;
        push = lane_v[l] && !(pop && cnt[l] == '0) && !ovf[l];
        if (rst_rx || !lock_all) begin
          wp[l] <= '0; rp[l] <= '0; cnt[l] <= '0;
        end else begin
          if (push) begin mem[l][wp[l]] <= lane_d[l]; wp[l] <= wp[l] + 1'b1; end
          if (pop && cnt[l] != '0) rp[l] <= rp[l] + 1'b1;
          cnt[l] <= cnt[l] + (PW+1)'(push) - (PW+1)'(pop && cnt[l] != '0);
        end
      end
    end
  end

  // ---------------- status ----------------
  logic [NL-1:0] lock_d;
  logic [31:0] c_lock, c_unlock, c_slip, c_shbad, c_idlebad, c_data, c_ovf, c_hvdv, c_chkok, c_chkbad;
  always_ff @(posedge clk) begin
    lock_d <= lock;
    if (clr) begin
      c_lock <= '0; c_unlock <= '0; c_slip <= '0; c_shbad <= '0; c_idlebad <= '0; c_data <= '0; c_ovf <= '0; c_hvdv <= '0;
      c_chkok <= '0; c_chkbad <= '0;
    end else begin
      if (|(lock & ~lock_d)) c_lock    <= c_lock + 1'b1;
      if (|(~lock & lock_d)) c_unlock  <= c_unlock + 1'b1;
      if (|slip)             c_slip    <= c_slip + 1'b1;
      if (|sh_bad)           c_shbad   <= c_shbad + 1'b1;
      if (|idle_bad)         c_idlebad <= c_idlebad + 1'b1;
      if (m_tvalid)          c_data    <= c_data + 1'b1;
      if (dsk_ovf)           c_ovf     <= c_ovf + 1'b1;
      if (|(rhv ^ rdv))      c_hvdv    <= c_hvdv + 1'b1;
      c_chkok  <= c_chkok + 32'($countones(chk_ok));
      c_chkbad <= c_chkbad + 32'($countones(chk_bad));
    end
  end
  always_comb begin
    stat = '0;
    stat.lock[NL-1:0] = lock;
    stat.n_lock = c_lock; stat.n_unlock = c_unlock; stat.n_slip = c_slip; stat.n_sh_bad = c_shbad;
    stat.n_idle_bad = c_idlebad; stat.n_data = c_data; stat.n_dsk_ovf = c_ovf; stat.n_hv_dv = c_hvdv;
    stat.n_chk_ok = c_chkok; stat.n_chk_bad = c_chkbad;
  end
endmodule
