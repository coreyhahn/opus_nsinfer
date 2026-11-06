// Stage 3 board top, BCU-1525 (xcvu9p-fsgd2104-2L-e, VCU1525 / U200 pinout; docs/BCU1525.md).
//
//   side A (core A user_clk)  QSFP0 lanes --DAC--> QSFP1 lanes  side B (core B user_clk)
//   shot player + timestamps  <------------DAC-----------------  decoder (or echo)
//
// Link width (DW, docs/PLAN.md):
//   DW = 64  (Stage 3, d = 3, N_DET = 24):  aurora_a / aurora_b,   1 lane per cage (lane 0: X1Y48 / X1Y44),
//            decoder qec_d3_top; constraints s3_bcu1525.xdc.
//   DW = 192 (d = 5, N_DET = 120):          aurora3_a / aurora3_b, 3 bonded lanes per cage (lanes 0..2:
//            X1Y48..X1Y50 / X1Y44..X1Y46, same refclks), decoder qec_d5_top; constraints s3_bcu1525.xdc
//            + s3_bcu1525_l3.xdc (lanes 1, 2). GT ports are [0:NL-1], NL = DW / 64 lanes; at NL = 1 they are
//            one-bit buses (qsfp0_rx_p[0] ...), which s3_bcu1525.xdc names.
//
// Clocks (docs/PLAN.md D-S3-CLK): init_clk = 300 MHz board clock (AW20/AW19) / 3 by BUFGCE_DIV
// clocks the Aurora init/DRP logic, the JTAG-to-AXI master and s3_regs. clk_a / clk_b are the
// Aurora user clocks (161.1328125 MHz each, from two Si5335 outputs: plesiochronous). Every
// crossing is in s3_regs (2-flop, quasi-static) or s3_freq (Gray); data crosses only over the
// cable.
//
// Reset: pma_init held for 2^27 init_clk cycles (1.34 s) after configuration, then reset_pb for
// 2^20 more (10.5 ms), the order the Aurora example design uses (pma_init first, reset_pb after);
// BOARD[8] / BOARD[9] force them again from JTAG. Side A / B are held in reset by their core's
// sys_reset_out and by the soft resets in CTRL.
module s3_top #(
    parameter int NVEC         = 464428,
    parameter     INIT_FILE    = "s3_shots.hex",
    parameter int DEC_LAT      = 6,
    parameter int N_DET        = 24,   // 24: d = 3 (qec_d3_top), 120: d = 5 (qec_d5_top)
    parameter int DW           = 64,   // 64: 1-lane aurora_a/b, 192: 3-lane aurora3_a/b
    parameter int OUT_W        = 18,   // decoder logit width (qec_d3 lc*: 18)
    parameter int LOGIT_SIGNED = 1,
    parameter int TIMEOUT      = 100000,
    parameter int POR_PMA_BITS = 27,
    parameter int POR_RST_BITS = 20,
    localparam int NL          = DW / 64
) (
    input  logic       clk_300_p,
    input  logic       clk_300_n,
    // QSFP0 (core A) and QSFP1 (core B), lanes 0 .. NL-1: bit i = cage lane i = the IP's rxp[i] etc.
    // (the IP's [0:NL-1] order; rxp[0] is GT channel X1Y48 / X1Y44)
    /* verilator lint_off ASCRANGE */  // ascending on purpose: the Aurora IP's own port order
    input  logic          qsfp0_refclk_p,
    input  logic          qsfp0_refclk_n,
    input  logic [0:NL-1] qsfp0_rx_p,
    input  logic [0:NL-1] qsfp0_rx_n,
    output logic [0:NL-1] qsfp0_tx_p,
    output logic [0:NL-1] qsfp0_tx_n,
    input  logic          qsfp1_refclk_p,
    input  logic          qsfp1_refclk_n,
    input  logic [0:NL-1] qsfp1_rx_p,
    input  logic [0:NL-1] qsfp1_rx_n,
    output logic [0:NL-1] qsfp1_tx_p,
    output logic [0:NL-1] qsfp1_tx_n,
    /* verilator lint_on ASCRANGE */
    // QSFP sideband and the Si5335 frequency select (FS = 10: 161.1328125 MHz)
    output logic [1:0] qsfp0_fs,
    output logic [1:0] qsfp1_fs,
    output logic       qsfp0_refclk_reset,
    output logic       qsfp1_refclk_reset,
    output logic       qsfp0_modsell,
    output logic       qsfp1_modsell,
    output logic       qsfp0_resetl,
    output logic       qsfp1_resetl,
    output logic       qsfp0_lpmode,
    output logic       qsfp1_lpmode,
    input  logic       qsfp0_modprsl,
    input  logic       qsfp1_modprsl,
    input  logic       qsfp0_intl,
    input  logic       qsfp1_intl,
    output logic [2:0] led
);
  import s3_pkg::*;

  if (!((DW == 64 && N_DET == 24) || (DW == 192 && N_DET == 120))) begin : g_chk
    $error("supported: DW = 64 with N_DET = 24, DW = 192 with N_DET = 120");
  end

  assign qsfp0_fs = 2'b10;
  assign qsfp1_fs = 2'b10;
  assign qsfp0_refclk_reset = 1'b0;
  assign qsfp1_refclk_reset = 1'b0;
  assign qsfp0_modsell = 1'b0;
  assign qsfp1_modsell = 1'b0;
  assign qsfp0_resetl = 1'b1;
  assign qsfp1_resetl = 1'b1;
  assign qsfp0_lpmode = 1'b0;
  assign qsfp1_lpmode = 1'b0;

  // ---------------- init_clk = 100 MHz ----------------
  logic clk_300_ib, init_clk;
  IBUFDS u_ibuf_300 (.I(clk_300_p), .IB(clk_300_n), .O(clk_300_ib));
  BUFGCE_DIV #(.BUFGCE_DIVIDE(3)) u_div3 (.I(clk_300_ib), .CE(1'b1), .CLR(1'b0), .O(init_clk));

  // ---------------- power-on sequence (init_clk) ----------------
  logic [POR_PMA_BITS:0] por = '0;
  logic pma_por = 1'b1, axi_rstn = 1'b0;
  logic [31:0] board_ctrl;
  always_ff @(posedge init_clk) begin
    if (!por[POR_PMA_BITS]) por <= por + 1'b1;
    if (por[4]) axi_rstn <= 1'b1;
    if (por[POR_PMA_BITS]) pma_por <= 1'b0;
  end
  // after pma_por falls the counter is frozen at 2^27; count the reset_pb delay separately
  logic [POR_RST_BITS:0] rst_cnt = '0;
  logic init_done = 1'b0;
  always_ff @(posedge init_clk) begin
    if (!pma_por && !rst_cnt[POR_RST_BITS]) rst_cnt <= rst_cnt + 1'b1;
    init_done <= rst_cnt[POR_RST_BITS];
  end
  wire pma_init = pma_por | board_ctrl[8];
  wire reset_pb = !init_done | board_ctrl[9];

  // ---------------- Aurora cores ----------------
  // tdata: the IP's [0:DW-1] is connected to our [DW-1:0] (IP bit 0 = our MSB = the tag), as in Stage 3.
  logic          clk_a, clk_b;
  logic [DW-1:0] a_tx_tdata, a_rx_tdata, b_tx_tdata, b_rx_tdata;
  logic          a_tx_tvalid, a_tx_tready, a_rx_tvalid, b_tx_tvalid, b_tx_tready, b_rx_tvalid;
  logic          a_chup, a_hard, a_soft, a_pll, a_uclk_on, a_sysrst;
  logic          b_chup, b_hard, b_soft, b_pll, b_uclk_on, b_sysrst;
  /* verilator lint_off ASCRANGE */
  logic [0:NL-1] a_lane, b_lane;  // the IP's lane_up[0:NL-1]: index i = lane i
  /* verilator lint_on ASCRANGE */
  logic [NL-1:0] a_pgv, b_pgv;    // the IP's gt_powergood[NL-1:0]

  if (DW == 64) begin : g_l1
    aurora_a u_aur_a (
        .s_axi_tx_tdata(a_tx_tdata), .s_axi_tx_tvalid(a_tx_tvalid), .s_axi_tx_tready(a_tx_tready),
        .m_axi_rx_tdata(a_rx_tdata), .m_axi_rx_tvalid(a_rx_tvalid),
        .rxp(qsfp0_rx_p), .rxn(qsfp0_rx_n), .txp(qsfp0_tx_p), .txn(qsfp0_tx_n),
        .gt_refclk1_p(qsfp0_refclk_p), .gt_refclk1_n(qsfp0_refclk_n), .gt_refclk1_out(),
        .hard_err(a_hard), .soft_err(a_soft), .channel_up(a_chup), .lane_up(a_lane),
        .user_clk_out(clk_a), .mmcm_not_locked_out(a_uclk_on), .sync_clk_out(),
        .reset_pb(reset_pb), .gt_rxcdrovrden_in(1'b0), .power_down(1'b0),
        .loopback(board_ctrl[2:0]), .pma_init(pma_init), .gt_pll_lock(a_pll),
        .gt0_drpaddr(10'd0), .gt0_drpdi(16'd0), .gt0_drpdo(), .gt0_drprdy(), .gt0_drpen(1'b0),
        .gt0_drpwe(1'b0), .init_clk(init_clk), .link_reset_out(), .gt_powergood(a_pgv),
        .gt_qpllclk_quad1_out(), .gt_qpllrefclk_quad1_out(), .gt_qplllock_quad1_out(),
        .gt_qpllrefclklost_quad1_out(), .sys_reset_out(a_sysrst), .gt_reset_out(), .tx_out_clk());

    aurora_b u_aur_b (
        .s_axi_tx_tdata(b_tx_tdata), .s_axi_tx_tvalid(b_tx_tvalid), .s_axi_tx_tready(b_tx_tready),
        .m_axi_rx_tdata(b_rx_tdata), .m_axi_rx_tvalid(b_rx_tvalid),
        .rxp(qsfp1_rx_p), .rxn(qsfp1_rx_n), .txp(qsfp1_tx_p), .txn(qsfp1_tx_n),
        .gt_refclk1_p(qsfp1_refclk_p), .gt_refclk1_n(qsfp1_refclk_n), .gt_refclk1_out(),
        .hard_err(b_hard), .soft_err(b_soft), .channel_up(b_chup), .lane_up(b_lane),
        .user_clk_out(clk_b), .mmcm_not_locked_out(b_uclk_on), .sync_clk_out(),
        .reset_pb(reset_pb), .gt_rxcdrovrden_in(1'b0), .power_down(1'b0),
        .loopback(board_ctrl[6:4]), .pma_init(pma_init), .gt_pll_lock(b_pll),
        .gt0_drpaddr(10'd0), .gt0_drpdi(16'd0), .gt0_drpdo(), .gt0_drprdy(), .gt0_drpen(1'b0),
        .gt0_drpwe(1'b0), .init_clk(init_clk), .link_reset_out(), .gt_powergood(b_pgv),
        .gt_qpllclk_quad1_out(), .gt_qpllrefclk_quad1_out(), .gt_qplllock_quad1_out(),
        .gt_qpllrefclklost_quad1_out(), .sys_reset_out(b_sysrst), .gt_reset_out(), .tx_out_clk());
  end else begin : g_l3
    // 3 bonded lanes (lane 1 is the channel-bonding master in the generated core); DRP of every lane
    // tied off; loopback applies to all three lanes of a core.
    aurora3_a u_aur_a (
        .s_axi_tx_tdata(a_tx_tdata), .s_axi_tx_tvalid(a_tx_tvalid), .s_axi_tx_tready(a_tx_tready),
        .m_axi_rx_tdata(a_rx_tdata), .m_axi_rx_tvalid(a_rx_tvalid),
        .rxp(qsfp0_rx_p), .rxn(qsfp0_rx_n), .txp(qsfp0_tx_p), .txn(qsfp0_tx_n),
        .gt_refclk1_p(qsfp0_refclk_p), .gt_refclk1_n(qsfp0_refclk_n), .gt_refclk1_out(),
        .hard_err(a_hard), .soft_err(a_soft), .channel_up(a_chup), .lane_up(a_lane),
        .user_clk_out(clk_a), .mmcm_not_locked_out(a_uclk_on), .sync_clk_out(),
        .reset_pb(reset_pb), .gt_rxcdrovrden_in(1'b0), .power_down(1'b0),
        .loopback(board_ctrl[2:0]), .pma_init(pma_init), .gt_pll_lock(a_pll),
        .gt0_drpaddr(10'd0), .gt0_drpdi(16'd0), .gt0_drpdo(), .gt0_drprdy(), .gt0_drpen(1'b0), .gt0_drpwe(1'b0),
        .gt1_drpaddr(10'd0), .gt1_drpdi(16'd0), .gt1_drpdo(), .gt1_drprdy(), .gt1_drpen(1'b0), .gt1_drpwe(1'b0),
        .gt2_drpaddr(10'd0), .gt2_drpdi(16'd0), .gt2_drpdo(), .gt2_drprdy(), .gt2_drpen(1'b0), .gt2_drpwe(1'b0),
        .init_clk(init_clk), .link_reset_out(), .gt_powergood(a_pgv),
        .gt_qpllclk_quad1_out(), .gt_qpllrefclk_quad1_out(), .gt_qplllock_quad1_out(),
        .gt_qpllrefclklost_quad1_out(), .sys_reset_out(a_sysrst), .gt_reset_out(), .tx_out_clk());

    aurora3_b u_aur_b (
        .s_axi_tx_tdata(b_tx_tdata), .s_axi_tx_tvalid(b_tx_tvalid), .s_axi_tx_tready(b_tx_tready),
        .m_axi_rx_tdata(b_rx_tdata), .m_axi_rx_tvalid(b_rx_tvalid),
        .rxp(qsfp1_rx_p), .rxn(qsfp1_rx_n), .txp(qsfp1_tx_p), .txn(qsfp1_tx_n),
        .gt_refclk1_p(qsfp1_refclk_p), .gt_refclk1_n(qsfp1_refclk_n), .gt_refclk1_out(),
        .hard_err(b_hard), .soft_err(b_soft), .channel_up(b_chup), .lane_up(b_lane),
        .user_clk_out(clk_b), .mmcm_not_locked_out(b_uclk_on), .sync_clk_out(),
        .reset_pb(reset_pb), .gt_rxcdrovrden_in(1'b0), .power_down(1'b0),
        .loopback(board_ctrl[6:4]), .pma_init(pma_init), .gt_pll_lock(b_pll),
        .gt0_drpaddr(10'd0), .gt0_drpdi(16'd0), .gt0_drpdo(), .gt0_drprdy(), .gt0_drpen(1'b0), .gt0_drpwe(1'b0),
        .gt1_drpaddr(10'd0), .gt1_drpdi(16'd0), .gt1_drpdo(), .gt1_drprdy(), .gt1_drpen(1'b0), .gt1_drpwe(1'b0),
        .gt2_drpaddr(10'd0), .gt2_drpdi(16'd0), .gt2_drpdo(), .gt2_drprdy(), .gt2_drpen(1'b0), .gt2_drpwe(1'b0),
        .init_clk(init_clk), .link_reset_out(), .gt_powergood(b_pgv),
        .gt_qpllclk_quad1_out(), .gt_qpllrefclk_quad1_out(), .gt_qplllock_quad1_out(),
        .gt_qpllrefclklost_quad1_out(), .sys_reset_out(b_sysrst), .gt_reset_out(), .tx_out_clk());
  end
  // LINK bits: lane_up and gt_powergood are the AND over the lanes (= lane 0 at NL = 1)
  wire a_lane_all = &a_lane, b_lane_all = &b_lane, a_pg = &a_pgv, b_pg = &b_pgv;

  // ---------------- loop sides ----------------
  logic        a_run, a_mode, a_srst, a_rd_req, a_rd_sel, a_rd_ack, a_done, a_busy, b_srst;
  logic [15:0] a_gap, a_hbase;
  logic [23:0] a_rd_addr;
  logic [31:0] a_rd_data;
  s3_a_stat_t  a_stat;
  s3_b_stat_t  b_stat;

  s3_side_a #(.NVEC(NVEC), .INIT_FILE(INIT_FILE), .TIMEOUT(TIMEOUT), .N_DET(N_DET), .DW(DW)) u_a (
      .clk(clk_a), .rst(a_sysrst | a_srst), .run(a_run), .mode_echo(a_mode), .gap(a_gap),
      .hist_base(a_hbase), .tx_tdata(a_tx_tdata), .tx_tvalid(a_tx_tvalid), .tx_tready(a_tx_tready),
      .rx_tdata(a_rx_tdata), .rx_tvalid(a_rx_tvalid), .rd_req(a_rd_req), .rd_sel(a_rd_sel),
      .rd_addr(a_rd_addr), .rd_data(a_rd_data), .rd_ack(a_rd_ack), .done(a_done), .busy(a_busy),
      .stat(a_stat));

  s3_side_b #(.N_DET(N_DET), .DW(DW), .IN_W(N_DET), .OUT_W(OUT_W), .LOGIT_SIGNED(LOGIT_SIGNED),
              .DEC_LAT(DEC_LAT)) u_b (
      .clk(clk_b), .rst(b_sysrst | b_srst), .rx_tdata(b_rx_tdata), .rx_tvalid(b_rx_tvalid),
      .tx_tdata(b_tx_tdata), .tx_tvalid(b_tx_tvalid), .tx_tready(b_tx_tready), .stat(b_stat));

  // sticky link errors in each user clock, cleared by that side's soft reset
  logic a_hard_s = 1'b0, a_soft_s = 1'b0, b_hard_s = 1'b0, b_soft_s = 1'b0;
  always_ff @(posedge clk_a)
    if (a_srst) {a_hard_s, a_soft_s} <= 2'b00;
    else begin a_hard_s <= a_hard_s | a_hard; a_soft_s <= a_soft_s | a_soft; end
  always_ff @(posedge clk_b)
    if (b_srst) {b_hard_s, b_soft_s} <= 2'b00;
    else begin b_hard_s <= b_hard_s | b_hard; b_soft_s <= b_soft_s | b_soft; end

  // per-lane lane_up in [27:25] (A) / [30:28] (B) for the 3-lane cores only (0 at NL = 1: Stage 3 value)
  logic [2:0] a_l3, b_l3;  // bit i = lane i
  always_comb begin
    a_l3 = '0; b_l3 = '0;
    if (NL > 1) for (int i = 0; i < NL; i++) begin a_l3[i] = a_lane[i]; b_l3[i] = b_lane[i]; end
  end
  wire [31:0] link_stat = {1'b0, b_l3, a_l3, init_done,
                           4'b0, qsfp1_intl, qsfp0_intl, qsfp1_modprsl, qsfp0_modprsl,
                           1'b0, b_uclk_on, b_pll, b_pg, b_soft_s, b_hard_s, b_lane_all, b_chup,
                           1'b0, a_uclk_on, a_pll, a_pg, a_soft_s, a_hard_s, a_lane_all, a_chup};

  logic [31:0] freq_a, freq_b;
  s3_freq u_fa (.clk_meas(clk_a), .clk_ref(init_clk), .count(freq_a));
  s3_freq u_fb (.clk_meas(clk_b), .clk_ref(init_clk), .count(freq_b));

  // ---------------- JTAG-to-AXI -> registers (init_clk) ----------------
  logic [31:0] awaddr, araddr, wdata, rdata;
  logic [3:0]  wstrb;
  logic [1:0]  bresp, rresp;
  logic        awvalid, awready, wvalid, wready, bvalid, bready, arvalid, arready, rvalid, rready;

  s3_jtag_axi u_jtag (
      .aclk(init_clk), .aresetn(axi_rstn),
      .m_axi_awaddr(awaddr), .m_axi_awprot(), .m_axi_awvalid(awvalid), .m_axi_awready(awready),
      .m_axi_wdata(wdata), .m_axi_wstrb(wstrb), .m_axi_wvalid(wvalid), .m_axi_wready(wready),
      .m_axi_bresp(bresp), .m_axi_bvalid(bvalid), .m_axi_bready(bready),
      .m_axi_araddr(araddr), .m_axi_arprot(), .m_axi_arvalid(arvalid), .m_axi_arready(arready),
      .m_axi_rdata(rdata), .m_axi_rresp(rresp), .m_axi_rvalid(rvalid), .m_axi_rready(rready));

  s3_regs #(.NVEC(NVEC), .DEC_LAT(DEC_LAT), .TIMEOUT(TIMEOUT), .N_DET(N_DET), .DW(DW)) u_regs (
      .aclk(init_clk), .aresetn(axi_rstn),
      .s_axi_awaddr(awaddr[11:0]), .s_axi_awvalid(awvalid), .s_axi_awready(awready),
      .s_axi_wdata(wdata), .s_axi_wstrb(wstrb), .s_axi_wvalid(wvalid), .s_axi_wready(wready),
      .s_axi_bresp(bresp), .s_axi_bvalid(bvalid), .s_axi_bready(bready),
      .s_axi_araddr(araddr[11:0]), .s_axi_arvalid(arvalid), .s_axi_arready(arready),
      .s_axi_rdata(rdata), .s_axi_rresp(rresp), .s_axi_rvalid(rvalid), .s_axi_rready(rready),
      .clk_a(clk_a), .a_run(a_run), .a_mode_echo(a_mode), .a_soft_rst(a_srst), .a_gap(a_gap),
      .a_hist_base(a_hbase), .a_rd_req(a_rd_req), .a_rd_sel(a_rd_sel), .a_rd_addr(a_rd_addr),
      .a_rd_data(a_rd_data), .a_rd_ack(a_rd_ack), .a_done(a_done), .a_stat(a_stat),
      .clk_b(clk_b), .b_soft_rst(b_srst), .b_stat(b_stat),
      .board_ctrl(board_ctrl), .link_stat(link_stat), .freq_a(freq_a), .freq_b(freq_b));

  // ---------------- LEDs: channel up A, channel up B, init_clk heartbeat ----------------
  logic [25:0] hb = '0;
  always_ff @(posedge init_clk) hb <= hb + 1'b1;
  assign led = {hb[25], b_chup, a_chup};

  // BOARD [31:10], [7], [3] are reserved
  wire unused = &{1'b0, a_busy, awaddr[31:12], araddr[31:12], board_ctrl[31:10], board_ctrl[7], board_ctrl[3]};
endmodule
