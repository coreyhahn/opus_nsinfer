// Stage 6 board top, BCU-1525 desk card (xcvu9p-fsgd2104-2L-e, VCU1525 / U200 pinout; docs/BCU1525.md):
// the Stage 3/4 loop (s3_side_a / s3_side_b, unchanged) over the thin custom GTY link (s6_link) instead of
// Aurora. docs/PLAN.md B.5 "Stage 6 as designed".
//
//   side A + link end A: QSFP0 lanes (quad 231, X1Y48..)  --DAC-->  QSFP1 lanes (quad 230, X1Y44..): end B + side B
//
// Clocking (D-S6-CLK): ONE reference clock, QSFP0's MGTREFCLK1 (K11/K10, Si5335 U9, 161.1328125 MHz), drives the
// QPLL1 of both quads (quad 230 through the GTSOUTHREFCLK routing: the wizard's "clk1+1", UG578 v1.4 p. 24 / 34).
// ONE user clock clk = TXOUTCLK of the master channel through the wizard's BUFG_GT; it is TXUSRCLK/TXUSRCLK2 and
// RXUSRCLK/RXUSRCLK2 of every channel (TX and RX buffers on; UG578 p. 102, p. 106, p. 321, Table 4-38) and clocks
// the whole loop: both link ends, the player / checker, the decoder. init_clk = 300 MHz / 3 clocks the GT reset
// controller (free-running clock), the JTAG-to-AXI master, s3_regs and s6_diag. QSFP1's refclk (P11/P10) is not used.
//
// Bring-up (init_clk): gtwiz_reset_all held for 2^POR_BITS cycles after configuration (1.34 s, as Stage 3's
// pma_init), then the wizard's reset controller runs (QPLL lock, TX, then RX after CDR lock); the link logic leaves
// reset when the wizard reports TX / RX reset done (synchronised to clk). Block lock follows within microseconds
// (s6_link). BOARD[8] re-runs gtwiz_reset_all, BOARD[9] gtwiz_reset_rx_datapath; BOARD[2:0] / [6:4] = LOOPBACK of
// the A / B channels (3'b010 near-end PMA).
//
// TXBYP = 1 (d = 3 only): core s6_gt_bp, TX buffer bypassed (TXBUF_EN FALSE, TX_XCLK_SEL TXUSR, multi-lane auto phase
// alignment by the wizard's buffer-bypass controller, clocked by clk; TXOUTCLK = TXPLLREFCLK_DIV1, the same 161.13 MHz
// refclk). RX unchanged. The link leaves TX reset only after the controller reports done; LINK[20] = done, [21] = error
// (bits that s6_core already passes through from board_stat).
module s6_top #(
    parameter int NVEC         = 464428,
    parameter     INIT_FILE    = "s3_shots.hex",
    parameter int DEC_LAT      = 6,
    parameter int N_DET        = 24,
    parameter int DW           = 64,
    parameter int OUT_W        = 18,
    parameter int LOGIT_SIGNED = 1,
    parameter int TIMEOUT      = 100000,
    parameter int TX_REG       = 0,
    parameter int RX_REG       = 0,
    parameter int TXBYP        = 0,
    parameter int POR_BITS     = 27,
    localparam int NL          = DW / 64
) (
    input  logic       clk_300_p,
    input  logic       clk_300_n,
    /* verilator lint_off ASCRANGE */  // ascending: bit i = cage lane i, as s3_top
    input  logic          qsfp0_refclk_p,
    input  logic          qsfp0_refclk_n,
    input  logic [0:NL-1] qsfp0_rx_p,
    input  logic [0:NL-1] qsfp0_rx_n,
    output logic [0:NL-1] qsfp0_tx_p,
    output logic [0:NL-1] qsfp0_tx_n,
    input  logic [0:NL-1] qsfp1_rx_p,
    input  logic [0:NL-1] qsfp1_rx_n,
    output logic [0:NL-1] qsfp1_tx_p,
    output logic [0:NL-1] qsfp1_tx_n,
    /* verilator lint_on ASCRANGE */
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
  if (!((DW == 64 && N_DET == 24) || (DW == 192 && N_DET == 120))) begin : g_chk
    $error("supported: DW = 64 with N_DET = 24, DW = 192 with N_DET = 120");
  end
  if (TXBYP != 0 && DW != 64) begin : g_chk_byp
    $error("TXBYP = 1 is built for d = 3 (s6_gt_bp) only");
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

  // ---------------- init_clk = 100 MHz, power-on ----------------
  logic clk_300_ib, init_clk;
  IBUFDS u_ibuf_300 (.I(clk_300_p), .IB(clk_300_n), .O(clk_300_ib));
  BUFGCE_DIV #(.BUFGCE_DIVIDE(3)) u_div3 (.I(clk_300_ib), .CE(1'b1), .CLR(1'b0), .O(init_clk));
  logic [POR_BITS:0] por = '0;
  logic axi_rstn = 1'b0, init_done = 1'b0;
  logic [31:0] board_ctrl;
  always_ff @(posedge init_clk) begin
    if (!por[POR_BITS]) por <= por + 1'b1;
    if (por[4]) axi_rstn <= 1'b1;
    init_done <= por[POR_BITS];
  end
  wire rst_all = !init_done | board_ctrl[8];
  wire rst_rxdp = board_ctrl[9];

  // ---------------- GT wizard: both ends, one refclk, one user clock ----------------
  logic refclk, clk, tx_active, tx_done, rx_done, cdr_stable;
  logic bb_done, bb_err;   // TX buffer-bypass controller (TXBYP = 1); 1 / 0 otherwise
  IBUFDS_GTE4 #(.REFCLK_EN_TX_PATH(1'b0), .REFCLK_HROW_CK_SEL(2'b00), .REFCLK_ICNTL_RX(2'b00)) u_refclk (
      .I(qsfp0_refclk_p), .IB(qsfp0_refclk_n), .CEB(1'b0), .O(refclk), .ODIV2());

  // wizard channel order: index 0..NL-1 = X1Y44.. (end B, QSFP1), index NL..2NL-1 = X1Y48.. (end A, QSFP0)
  localparam int NC = 2 * NL;
  logic [64*NC-1:0] g_txd, g_rxd;
  logic [6*NC-1:0]  g_txh, g_rxh;
  logic [7*NC-1:0]  g_txs;
  logic [2*NC-1:0]  g_rxhv, g_rxdv, g_rxsos, g_txbuf;
  logic [3*NC-1:0]  g_rxbuf, g_lpbk;
  logic [NC-1:0]    g_slip, g_bufrst, g_pg, g_txpmadone, g_rxpmadone, g_txrd, g_rxrd, g_rxp, g_rxn, g_txp, g_txn;

  logic [DW-1:0]   a_txd, a_rxd, b_txd, b_rxd;
  logic [2*NL-1:0] a_txh, a_rxh, b_txh, b_rxh, a_txb, b_txb;
  logic [6:0]      a_txs, b_txs;
  logic [NL-1:0]   a_hv, a_dv, b_hv, b_dv, a_slip, b_slip, a_brst, b_brst;
  logic [3*NL-1:0] a_rxb, b_rxb;
  always_comb begin
    for (int l = 0; l < NL; l++) begin
      // B = wizard channel l, A = wizard channel NL + l
      g_txd[64*l +: 64]        = b_txd[64*l +: 64];
      g_txd[64*(NL+l) +: 64]   = a_txd[64*l +: 64];
      g_txh[6*l +: 6]          = {4'b0, b_txh[2*l +: 2]};
      g_txh[6*(NL+l) +: 6]     = {4'b0, a_txh[2*l +: 2]};
      g_txs[7*l +: 7]          = b_txs;
      g_txs[7*(NL+l) +: 7]     = a_txs;
      g_slip[l]                = b_slip[l];
      g_slip[NL+l]             = a_slip[l];
      g_bufrst[l]              = b_brst[l];
      g_bufrst[NL+l]           = a_brst[l];
      g_lpbk[3*l +: 3]         = board_ctrl[6:4];
      g_lpbk[3*(NL+l) +: 3]    = board_ctrl[2:0];
      b_rxd[64*l +: 64]        = g_rxd[64*l +: 64];
      a_rxd[64*l +: 64]        = g_rxd[64*(NL+l) +: 64];
      b_rxh[2*l +: 2]          = g_rxh[6*l +: 2];
      a_rxh[2*l +: 2]          = g_rxh[6*(NL+l) +: 2];
      b_hv[l] = g_rxhv[2*l];  a_hv[l] = g_rxhv[2*(NL+l)];
      b_dv[l] = g_rxdv[2*l];  a_dv[l] = g_rxdv[2*(NL+l)];
      b_rxb[3*l +: 3] = g_rxbuf[3*l +: 3];  a_rxb[3*l +: 3] = g_rxbuf[3*(NL+l) +: 3];
      b_txb[2*l +: 2] = g_txbuf[2*l +: 2];  a_txb[2*l +: 2] = g_txbuf[2*(NL+l) +: 2];
      g_rxp[l] = qsfp1_rx_p[l];  g_rxp[NL+l] = qsfp0_rx_p[l];
      g_rxn[l] = qsfp1_rx_n[l];  g_rxn[NL+l] = qsfp0_rx_n[l];
      qsfp1_tx_p[l] = g_txp[l];  qsfp0_tx_p[l] = g_txp[NL+l];
      qsfp1_tx_n[l] = g_txn[l];  qsfp0_tx_n[l] = g_txn[NL+l];
    end
  end

  if (NL == 1 && TXBYP == 0) begin : g_gt1
    s6_gt u_gt (
        .gtwiz_userclk_tx_reset_in(~&g_txpmadone), .gtwiz_userclk_tx_srcclk_out(), .gtwiz_userclk_tx_usrclk_out(),
        .gtwiz_userclk_tx_usrclk2_out(clk), .gtwiz_userclk_tx_active_out(tx_active),
        .gtwiz_userclk_rx_active_in(tx_active),
        .gtwiz_reset_clk_freerun_in(init_clk), .gtwiz_reset_all_in(rst_all),
        .gtwiz_reset_tx_pll_and_datapath_in(1'b0), .gtwiz_reset_tx_datapath_in(1'b0),
        .gtwiz_reset_rx_pll_and_datapath_in(1'b0), .gtwiz_reset_rx_datapath_in(rst_rxdp),
        .gtwiz_reset_rx_cdr_stable_out(cdr_stable), .gtwiz_reset_tx_done_out(tx_done), .gtwiz_reset_rx_done_out(rx_done),
        .gtwiz_userdata_tx_in(g_txd), .gtwiz_userdata_rx_out(g_rxd),
        .gtrefclk01_in({refclk, refclk}), .qpll1outclk_out(), .qpll1outrefclk_out(),
        .gtyrxn_in(g_rxn), .gtyrxp_in(g_rxp), .loopback_in(g_lpbk), .rxbufreset_in(g_bufrst),
        .rxgearboxslip_in(g_slip), .rxusrclk_in({NC{clk}}), .rxusrclk2_in({NC{clk}}),
        .txheader_in(g_txh), .txsequence_in(g_txs), .gtpowergood_out(g_pg), .gtytxn_out(g_txn), .gtytxp_out(g_txp),
        .rxbufstatus_out(g_rxbuf), .rxdatavalid_out(g_rxdv), .rxheader_out(g_rxh), .rxheadervalid_out(g_rxhv),
        .rxoutclk_out(), .rxpmaresetdone_out(g_rxpmadone), .rxresetdone_out(g_rxrd), .rxstartofseq_out(g_rxsos),
        .txbufstatus_out(g_txbuf), .txpmaresetdone_out(g_txpmadone), .txresetdone_out(g_txrd));
    assign bb_done = 1'b1;
    assign bb_err  = 1'b0;
  end else if (NL == 1) begin : g_gt1bp
    s6_gt_bp u_gt (
        .gtwiz_userclk_tx_reset_in(~&g_txpmadone), .gtwiz_userclk_tx_srcclk_out(), .gtwiz_userclk_tx_usrclk_out(),
        .gtwiz_userclk_tx_usrclk2_out(clk), .gtwiz_userclk_tx_active_out(tx_active),
        .gtwiz_userclk_rx_active_in(tx_active),
        .gtwiz_buffbypass_tx_reset_in(~tx_active), .gtwiz_buffbypass_tx_start_user_in(1'b0),
        .gtwiz_buffbypass_tx_done_out(bb_done), .gtwiz_buffbypass_tx_error_out(bb_err),
        .gtwiz_reset_clk_freerun_in(init_clk), .gtwiz_reset_all_in(rst_all),
        .gtwiz_reset_tx_pll_and_datapath_in(1'b0), .gtwiz_reset_tx_datapath_in(1'b0),
        .gtwiz_reset_rx_pll_and_datapath_in(1'b0), .gtwiz_reset_rx_datapath_in(rst_rxdp),
        .gtwiz_reset_rx_cdr_stable_out(cdr_stable), .gtwiz_reset_tx_done_out(tx_done), .gtwiz_reset_rx_done_out(rx_done),
        .gtwiz_userdata_tx_in(g_txd), .gtwiz_userdata_rx_out(g_rxd),
        .gtrefclk01_in({refclk, refclk}), .qpll1outclk_out(), .qpll1outrefclk_out(),
        .gtyrxn_in(g_rxn), .gtyrxp_in(g_rxp), .loopback_in(g_lpbk), .rxbufreset_in(g_bufrst),
        .rxgearboxslip_in(g_slip), .rxusrclk_in({NC{clk}}), .rxusrclk2_in({NC{clk}}),
        .txheader_in(g_txh), .txsequence_in(g_txs), .gtpowergood_out(g_pg), .gtytxn_out(g_txn), .gtytxp_out(g_txp),
        .rxbufstatus_out(g_rxbuf), .rxdatavalid_out(g_rxdv), .rxheader_out(g_rxh), .rxheadervalid_out(g_rxhv),
        .rxoutclk_out(), .rxpmaresetdone_out(g_rxpmadone), .rxresetdone_out(g_rxrd), .rxstartofseq_out(g_rxsos),
        .txpmaresetdone_out(g_txpmadone), .txresetdone_out(g_txrd));
    assign g_txbuf = '0;   // no TX buffer
  end else begin : g_gt3
    assign bb_done = 1'b1;
    assign bb_err  = 1'b0;
    s6_gt3 u_gt (
        .gtwiz_userclk_tx_reset_in(~&g_txpmadone), .gtwiz_userclk_tx_srcclk_out(), .gtwiz_userclk_tx_usrclk_out(),
        .gtwiz_userclk_tx_usrclk2_out(clk), .gtwiz_userclk_tx_active_out(tx_active),
        .gtwiz_userclk_rx_active_in(tx_active),
        .gtwiz_reset_clk_freerun_in(init_clk), .gtwiz_reset_all_in(rst_all),
        .gtwiz_reset_tx_pll_and_datapath_in(1'b0), .gtwiz_reset_tx_datapath_in(1'b0),
        .gtwiz_reset_rx_pll_and_datapath_in(1'b0), .gtwiz_reset_rx_datapath_in(rst_rxdp),
        .gtwiz_reset_rx_cdr_stable_out(cdr_stable), .gtwiz_reset_tx_done_out(tx_done), .gtwiz_reset_rx_done_out(rx_done),
        .gtwiz_userdata_tx_in(g_txd), .gtwiz_userdata_rx_out(g_rxd),
        .gtrefclk01_in({refclk, refclk}), .qpll1outclk_out(), .qpll1outrefclk_out(),
        .gtyrxn_in(g_rxn), .gtyrxp_in(g_rxp), .loopback_in(g_lpbk), .rxbufreset_in(g_bufrst),
        .rxgearboxslip_in(g_slip), .rxusrclk_in({NC{clk}}), .rxusrclk2_in({NC{clk}}),
        .txheader_in(g_txh), .txsequence_in(g_txs), .gtpowergood_out(g_pg), .gtytxn_out(g_txn), .gtytxp_out(g_txp),
        .rxbufstatus_out(g_rxbuf), .rxdatavalid_out(g_rxdv), .rxheader_out(g_rxh), .rxheadervalid_out(g_rxhv),
        .rxoutclk_out(), .rxpmaresetdone_out(g_rxpmadone), .rxresetdone_out(g_rxrd), .rxstartofseq_out(g_rxsos),
        .txbufstatus_out(g_txbuf), .txpmaresetdone_out(g_txpmadone), .txresetdone_out(g_txrd));
  end

  // ---------------- resets into clk (asynchronous assert, synchronous release) ----------------
  (* ASYNC_REG = "TRUE" *) logic [2:0] rc_s, rt_s, rr_s;
  always_ff @(posedge clk or negedge tx_active)
    if (!tx_active) rc_s <= '1; else rc_s <= {rc_s[1:0], 1'b0};
  wire tx_ok = tx_done & bb_done;   // TXBYP = 1: TX phase alignment finished too
  always_ff @(posedge clk or negedge tx_ok)
    if (!tx_ok) rt_s <= '1; else rt_s <= {rt_s[1:0], 1'b0};
  always_ff @(posedge clk or negedge rx_done)
    if (!rx_done) rr_s <= '1; else rr_s <= {rr_s[1:0], 1'b0};
  wire rst_clk = rc_s[2];
  wire rst_tx  = rt_s[2] | rst_clk;
  wire rst_rx  = rr_s[2] | rst_clk;

  // ---------------- the loop ----------------
  logic [31:0] awaddr, araddr, wdata, rdata, freq_clk;
  logic [3:0]  wstrb;
  logic [1:0]  bresp, rresp, lock_ab;
  logic        awvalid, awready, wvalid, wready, bvalid, bready, arvalid, arready, rvalid, rready;
  wire  [31:0] board_stat = {7'b0, init_done, 2'b0, TXBYP != 0 && bb_err, TXBYP != 0 && bb_done,
                             qsfp1_intl, qsfp0_intl, qsfp1_modprsl, qsfp0_modprsl,
                             1'b0, cdr_stable, rx_done, &g_pg[NL-1:0], 4'b0,
                             1'b0, tx_active, tx_done, &g_pg[NC-1:NL], 4'b0};

  s6_core #(.NVEC(NVEC), .INIT_FILE(INIT_FILE), .DEC_LAT(DEC_LAT), .N_DET(N_DET), .DW(DW), .OUT_W(OUT_W),
            .LOGIT_SIGNED(LOGIT_SIGNED), .TIMEOUT(TIMEOUT), .TX_REG(TX_REG), .RX_REG(RX_REG)) u_core (
      .clk(clk), .rst_clk(rst_clk), .rst_tx(rst_tx), .rst_rx(rst_rx),
      .a_txdata(a_txd), .a_txheader(a_txh), .a_txseq(a_txs), .a_rxdata(a_rxd), .a_rxheader(a_rxh), .a_rxhv(a_hv),
      .a_rxdv(a_dv), .a_rxslip(a_slip), .a_rxbufstatus(a_rxb), .a_txbufstatus(a_txb), .a_rxbufreset(a_brst),
      .b_txdata(b_txd), .b_txheader(b_txh), .b_txseq(b_txs), .b_rxdata(b_rxd), .b_rxheader(b_rxh), .b_rxhv(b_hv),
      .b_rxdv(b_dv), .b_rxslip(b_slip), .b_rxbufstatus(b_rxb), .b_txbufstatus(b_txb), .b_rxbufreset(b_brst),
      .aclk(init_clk), .aresetn(axi_rstn),
      .s_axi_awaddr(awaddr[12:0]), .s_axi_awvalid(awvalid), .s_axi_awready(awready),
      .s_axi_wdata(wdata), .s_axi_wstrb(wstrb), .s_axi_wvalid(wvalid), .s_axi_wready(wready),
      .s_axi_bresp(bresp), .s_axi_bvalid(bvalid), .s_axi_bready(bready),
      .s_axi_araddr(araddr[12:0]), .s_axi_arvalid(arvalid), .s_axi_arready(arready),
      .s_axi_rdata(rdata), .s_axi_rresp(rresp), .s_axi_rvalid(rvalid), .s_axi_rready(rready),
      .board_stat(board_stat), .board_ctrl(board_ctrl), .freq_clk(freq_clk), .lock_ab(lock_ab));

  s3_freq u_fa (.clk_meas(clk), .clk_ref(init_clk), .count(freq_clk));

  s3_jtag_axi u_jtag (
      .aclk(init_clk), .aresetn(axi_rstn),
      .m_axi_awaddr(awaddr), .m_axi_awprot(), .m_axi_awvalid(awvalid), .m_axi_awready(awready),
      .m_axi_wdata(wdata), .m_axi_wstrb(wstrb), .m_axi_wvalid(wvalid), .m_axi_wready(wready),
      .m_axi_bresp(bresp), .m_axi_bvalid(bvalid), .m_axi_bready(bready),
      .m_axi_araddr(araddr), .m_axi_arprot(), .m_axi_arvalid(arvalid), .m_axi_arready(arready),
      .m_axi_rdata(rdata), .m_axi_rresp(rresp), .m_axi_rvalid(rvalid), .m_axi_rready(rready));

  // ---------------- LEDs: lock A, lock B, init_clk heartbeat ----------------
  logic [25:0] hb = '0;
  always_ff @(posedge init_clk) hb <= hb + 1'b1;
  assign led = {hb[25], lock_ab[1], lock_ab[0]};

  wire unused = &{1'b0, awaddr[31:13], araddr[31:13], board_ctrl[31:10], board_ctrl[7], board_ctrl[3],
                  g_rxsos, g_rxpmadone, g_txrd, g_rxrd, g_rxdv[1], g_rxhv[1], g_rxh};
endmodule
