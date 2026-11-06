// s6_core: the Stage 6 loop without the board (GT wizard, clock buffers, JTAG-AXI, power-on): the same
// s3_side_a (shot player, timestamps, checker) and s3_side_b (decoder or echo) as Stage 3/4, joined by two
// s6_link ends (A = QSFP0 channel(s), B = QSFP1 channel(s)) instead of the Aurora cores, plus one-way probes,
// s3_regs (unchanged map at 0x000-0xFFF) and s6_diag (0x1000-0x1FFF). Verilator runs this with a behavioural
// GT model (tb/tb_s6_loop.sv); s6_top wraps it for the board.
//
// ONE clock: clk is the TX user clock of the GT wizard (TXOUTCLK of the master channel through one BUFG_GT) and
// clocks both link ends, both s3 sides, the decoder, the probes and the snapshot logic (docs/PLAN.md D-S6-CLK).
// aclk (100 MHz init clock) clocks only the register files; its crossings are those of s3_regs / s6_diag.
//
// LINK (s3_regs 0x024) for Stage 6: [0] lock A (all lanes of QSFP0's RX), [1] same, [2] lock lost A (sticky),
// [3] invalid header or bad idle at A (sticky), [8..11] the same for B (QSFP1's RX), [25+i] / [28+i] lane i lock
// A / B at NL = 3; the board bits (powergood, reset done, user clock active, ModPrsL, IntL, init done) come in
// board_stat at their positions (s6_top). Stickies clear with CTRL soft_rst_a / soft_rst_b, as in Stage 3.
// AXI split: awaddr[12] / araddr[12] select s6_diag; one outstanding transaction per channel (JTAG-AXI).
module s6_core
  import s3_pkg::*;
  import s6_pkg::*;
#(
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
    localparam int NL          = DW / 64
) (
    input  logic            clk,
    input  logic            rst_clk,     // clk domain: user clock not yet active
    input  logic            rst_tx,      // clk domain: GT TX reset not done
    input  logic            rst_rx,      // clk domain: GT RX reset not done
    // GT A (QSFP0 lanes) / B (QSFP1 lanes)
    output logic [DW-1:0]   a_txdata,
    output logic [2*NL-1:0] a_txheader,
    output logic [6:0]      a_txseq,
    input  logic [DW-1:0]   a_rxdata,
    input  logic [2*NL-1:0] a_rxheader,
    input  logic [NL-1:0]   a_rxhv,
    input  logic [NL-1:0]   a_rxdv,
    output logic [NL-1:0]   a_rxslip,
    input  logic [3*NL-1:0] a_rxbufstatus,
    input  logic [2*NL-1:0] a_txbufstatus,
    output logic [NL-1:0]   a_rxbufreset,
    output logic [DW-1:0]   b_txdata,
    output logic [2*NL-1:0] b_txheader,
    output logic [6:0]      b_txseq,
    input  logic [DW-1:0]   b_rxdata,
    input  logic [2*NL-1:0] b_rxheader,
    input  logic [NL-1:0]   b_rxhv,
    input  logic [NL-1:0]   b_rxdv,
    output logic [NL-1:0]   b_rxslip,
    input  logic [3*NL-1:0] b_rxbufstatus,
    input  logic [2*NL-1:0] b_txbufstatus,
    output logic [NL-1:0]   b_rxbufreset,
    // registers (aclk)
    input  logic            aclk,
    input  logic            aresetn,
    input  logic [12:0]     s_axi_awaddr,
    input  logic            s_axi_awvalid,
    output logic            s_axi_awready,
    input  logic [31:0]     s_axi_wdata,
    input  logic [3:0]      s_axi_wstrb,
    input  logic            s_axi_wvalid,
    output logic            s_axi_wready,
    output logic [1:0]      s_axi_bresp,
    output logic            s_axi_bvalid,
    input  logic            s_axi_bready,
    input  logic [12:0]     s_axi_araddr,
    input  logic            s_axi_arvalid,
    output logic            s_axi_arready,
    output logic [31:0]     s_axi_rdata,
    output logic [1:0]      s_axi_rresp,
    output logic            s_axi_rvalid,
    input  logic            s_axi_rready,
    input  logic [31:0]     board_stat,  // asynchronous board / GT status bits at their LINK positions
    output logic [31:0]     board_ctrl,  // s3_regs BOARD (aclk)
    input  logic [31:0]     freq_clk,    // clk cycles per 2^24 aclk cycles (s3_freq, aclk)
    output logic [1:0]      lock_ab      // {B, A} all-lane lock, for LEDs
);
  // ---------------- AXI split ----------------
  logic        r_awready, r_wready, r_bvalid, r_arready, r_rvalid, d_awready, d_wready, d_bvalid, d_arready, d_rvalid;
  logic [1:0]  r_bresp, r_rresp, d_bresp, d_rresp;
  logic [31:0] r_rdata, d_rdata;
  wire w_d = s_axi_awaddr[12];
  wire r_d = s_axi_araddr[12];
  assign s_axi_awready = w_d ? d_awready : r_awready;
  assign s_axi_wready  = w_d ? d_wready  : r_wready;
  assign s_axi_bvalid  = r_bvalid | d_bvalid;
  assign s_axi_bresp   = d_bvalid ? d_bresp : r_bresp;
  assign s_axi_arready = r_d ? d_arready : r_arready;
  assign s_axi_rvalid  = r_rvalid | d_rvalid;
  assign s_axi_rdata   = d_rvalid ? d_rdata : r_rdata;
  assign s_axi_rresp   = d_rvalid ? d_rresp : r_rresp;

  // ---------------- shared timestamp counter (probes) ----------------
  logic [31:0] tsc;
  always_ff @(posedge clk) tsc <= rst_clk ? 32'd0 : tsc + 32'd1;

  // ---------------- s3 sides ----------------
  logic        a_run, a_mode, a_srst, a_rd_req, a_rd_sel, a_rd_ack, a_done, a_busy, b_srst;
  logic [15:0] a_gap, a_hbase;
  logic [23:0] a_rd_addr;
  logic [31:0] a_rd_data;
  s3_a_stat_t  a_stat;
  s3_b_stat_t  b_stat;
  logic [DW-1:0] sa_tx_d, sa_rx_d, sb_tx_d, sb_rx_d;
  logic          sa_tx_v, sa_tx_r, sa_rx_v, sb_tx_v, sb_tx_r, sb_rx_v;
  logic          probe_en, dclr;
  logic [15:0]   p_period, p_hbase;

  s3_side_a #(.NVEC(NVEC), .INIT_FILE(INIT_FILE), .TIMEOUT(TIMEOUT), .N_DET(N_DET), .DW(DW)) u_a (
      .clk(clk), .rst(rst_clk | a_srst), .run(a_run), .mode_echo(a_mode), .gap(a_gap),
      .hist_base(a_hbase), .tx_tdata(sa_tx_d), .tx_tvalid(sa_tx_v), .tx_tready(sa_tx_r),
      .rx_tdata(sa_rx_d), .rx_tvalid(sa_rx_v), .rd_req(a_rd_req), .rd_sel(a_rd_sel),
      .rd_addr(a_rd_addr), .rd_data(a_rd_data), .rd_ack(a_rd_ack), .done(a_done), .busy(a_busy),
      .stat(a_stat));

  s3_side_b #(.N_DET(N_DET), .DW(DW), .IN_W(N_DET), .OUT_W(OUT_W), .LOGIT_SIGNED(LOGIT_SIGNED),
              .DEC_LAT(DEC_LAT)) u_b (
      .clk(clk), .rst(rst_clk | b_srst), .rx_tdata(sb_rx_d), .rx_tvalid(sb_rx_v),
      .tx_tdata(sb_tx_d), .tx_tvalid(sb_tx_v), .tx_tready(sb_tx_r), .stat(b_stat));

  // ---------------- probes ----------------
  logic [DW-1:0]  pa_tx_d, pb_tx_d;
  logic           pa_tx_v, pb_tx_v;
  s6_probe_stat_t pa_stat, pb_stat;
  logic [31:0]    pa_hist[32], pb_hist[32];

  // ---------------- links ----------------
  logic [DW-1:0]  la_s_d, la_m_d, lb_s_d, lb_m_d;
  logic           la_s_v, la_s_r, la_m_v, lb_s_v, lb_s_r, lb_m_v, a_lock, b_lock;
  s6_link_stat_t  la_stat, lb_stat;
  // probe mode: the probes own the link TX; the s3 sides see no RX and no tready. The RX side stays in probe mode
  // for 2047 cycles after probe_en falls (probe_win), so words in flight reach the checkers, not the s3 sides.
  logic [10:0] p_hold;
  always_ff @(posedge clk) p_hold <= (rst_clk || probe_en) ? 11'h7FF : (p_hold != 0) ? p_hold - 1'b1 : p_hold;
  wire probe_win = probe_en || (p_hold != 0 && !rst_clk);
  assign la_s_d  = probe_en ? pa_tx_d : sa_tx_d;
  assign la_s_v  = probe_en ? pa_tx_v : sa_tx_v;
  assign sa_tx_r = la_s_r && !probe_en;
  assign lb_s_d  = probe_en ? pb_tx_d : sb_tx_d;
  assign lb_s_v  = probe_en ? pb_tx_v : sb_tx_v;
  assign sb_tx_r = lb_s_r && !probe_en;
  assign sa_rx_d = la_m_d;
  assign sa_rx_v = la_m_v && !probe_win;
  assign sb_rx_d = lb_m_d;
  assign sb_rx_v = lb_m_v && !probe_win;

  s6_link #(.NL(NL), .TX_REG(TX_REG), .RX_REG(RX_REG)) u_la (
      .clk(clk), .rst_tx(rst_tx), .rst_rx(rst_rx), .clr(dclr),
      .s_tdata(la_s_d), .s_tvalid(la_s_v), .s_tready(la_s_r), .m_tdata(la_m_d), .m_tvalid(la_m_v),
      .gt_txdata(a_txdata), .gt_txheader(a_txheader), .gt_txsequence(a_txseq),
      .gt_rxdata(a_rxdata), .gt_rxheader(a_rxheader), .gt_rxheadervalid(a_rxhv), .gt_rxdatavalid(a_rxdv),
      .gt_rxgearboxslip(a_rxslip), .lock_all(a_lock), .stat(la_stat));
  s6_link #(.NL(NL), .TX_REG(TX_REG), .RX_REG(RX_REG)) u_lb (
      .clk(clk), .rst_tx(rst_tx), .rst_rx(rst_rx), .clr(dclr),
      .s_tdata(lb_s_d), .s_tvalid(lb_s_v), .s_tready(lb_s_r), .m_tdata(lb_m_d), .m_tvalid(lb_m_v),
      .gt_txdata(b_txdata), .gt_txheader(b_txheader), .gt_txsequence(b_txseq),
      .gt_rxdata(b_rxdata), .gt_rxheader(b_rxheader), .gt_rxheadervalid(b_rxhv), .gt_rxdatavalid(b_rxdv),
      .gt_rxgearboxslip(b_rxslip), .lock_all(b_lock), .stat(lb_stat));
  assign lock_ab = {b_lock, a_lock};

  s6_probe #(.DW(DW)) u_pa (
      .clk(clk), .rst(rst_clk), .en(probe_en), .period(p_period), .hbase(p_hbase), .clr(dclr), .tsc(tsc),
      .tdata(pa_tx_d), .tvalid(pa_tx_v), .tready(la_s_r), .rdata(la_m_d), .rvalid(la_m_v && probe_win),
      .stat(pa_stat), .hist(pa_hist));
  s6_probe #(.DW(DW)) u_pb (
      .clk(clk), .rst(rst_clk), .en(probe_en), .period(p_period), .hbase(p_hbase), .clr(dclr), .tsc(tsc),
      .tdata(pb_tx_d), .tvalid(pb_tx_v), .tready(lb_s_r), .rdata(lb_m_d), .rvalid(lb_m_v && probe_win),
      .stat(pb_stat), .hist(pb_hist));

  // ---------------- RX elastic buffer recovery and buffer status ----------------
  // RXBUFSTATUS[2] = 1 (101 underflow, 110 overflow, UG578 Table 4-36): pulse RXBUFRESET for 8 cycles, then
  // ignore the status for 4096 cycles. Counted per end; sticky error bits per lane.
  logic [31:0] a_bufrst_n, b_bufrst_n;
  logic [NL-1:0] a_rxerr_s, b_rxerr_s, a_txerr_s, b_txerr_s;
  logic [12:0] a_ho, b_ho;
  always_ff @(posedge clk) begin
    if (rst_rx) begin
      a_ho <= '0; b_ho <= '0; a_rxbufreset <= '0; b_rxbufreset <= '0;
    end else begin
      if (a_ho != '0) a_ho <= a_ho - 1'b1;
      if (b_ho != '0) b_ho <= b_ho - 1'b1;
      a_rxbufreset <= {NL{a_ho > 13'd4088}};
      b_rxbufreset <= {NL{b_ho > 13'd4088}};
      for (int l = 0; l < NL; l++) begin
        if (a_rxbufstatus[3*l+2] && a_ho == '0) a_ho <= 13'd4096;
        if (b_rxbufstatus[3*l+2] && b_ho == '0) b_ho <= 13'd4096;
      end
    end
    if (dclr) begin
      a_bufrst_n <= '0; b_bufrst_n <= '0; a_rxerr_s <= '0; b_rxerr_s <= '0; a_txerr_s <= '0; b_txerr_s <= '0;
    end else begin
      if (a_ho == 13'd4096) a_bufrst_n <= a_bufrst_n + 1'b1;
      if (b_ho == 13'd4096) b_bufrst_n <= b_bufrst_n + 1'b1;
      for (int l = 0; l < NL; l++) begin
        if (a_rxbufstatus[3*l+2]) a_rxerr_s[l] <= 1'b1;
        if (b_rxbufstatus[3*l+2]) b_rxerr_s[l] <= 1'b1;
        if (a_txbufstatus[2*l+1]) a_txerr_s[l] <= 1'b1;
        if (b_txbufstatus[2*l+1]) b_txerr_s[l] <= 1'b1;
      end
    end
  end

  // ---------------- diag live words ----------------
  logic [127:0][31:0] live;
  function automatic logic [31:0] bufword(input logic [8:0] rxs, input logic [5:0] txs, input logic [2:0] rxe,
                                          input logic [2:0] txe);
    return {9'b0, txe, 1'b0, rxe, txs, 1'b0, rxs};   // [8:0] RXBUFSTATUS, [15:10] TXBUFSTATUS, [18:16] RX err, [22:20] TX err
  endfunction
  always_comb begin
    for (int k = 0; k < 128; k++) live[k] = 32'h0;
    live[0]  = {29'b0, la_stat.lock};  live[1] = la_stat.n_lock; live[2] = la_stat.n_unlock; live[3] = la_stat.n_slip;
    live[4]  = la_stat.n_sh_bad; live[5] = la_stat.n_idle_bad; live[6] = la_stat.n_data; live[7] = la_stat.n_dsk_ovf;
    live[8]  = la_stat.n_hv_dv;  live[9] = a_bufrst_n;
    live[10] = bufword(9'(a_rxbufstatus), 6'(a_txbufstatus), 3'(a_rxerr_s), 3'(a_txerr_s));
    live[16] = {29'b0, lb_stat.lock};  live[17] = lb_stat.n_lock; live[18] = lb_stat.n_unlock; live[19] = lb_stat.n_slip;
    live[20] = lb_stat.n_sh_bad; live[21] = lb_stat.n_idle_bad; live[22] = lb_stat.n_data; live[23] = lb_stat.n_dsk_ovf;
    live[24] = lb_stat.n_hv_dv;  live[25] = b_bufrst_n;
    live[26] = bufword(9'(b_rxbufstatus), 6'(b_txbufstatus), 3'(b_rxerr_s), 3'(b_txerr_s));
    // probe at end A: n_tx = A -> B words sent, n_rx / latency = B -> A; probe at end B: the reverse
    live[32] = pa_stat.n_tx; live[33] = pa_stat.n_rx; live[34] = pa_stat.n_bad; live[35] = pa_stat.lat_min;
    live[36] = pa_stat.lat_max; live[37] = pa_stat.lat_sum[31:0]; live[38] = {16'b0, pa_stat.lat_sum[47:32]};
    live[40] = pb_stat.n_tx; live[41] = pb_stat.n_rx; live[42] = pb_stat.n_bad; live[43] = pb_stat.lat_min;
    live[44] = pb_stat.lat_max; live[45] = pb_stat.lat_sum[31:0]; live[46] = {16'b0, pb_stat.lat_sum[47:32]};
    live[48] = tsc;
    for (int k = 0; k < 32; k++) begin live[64 + k] = pa_hist[k]; live[96 + k] = pb_hist[k]; end
  end

  s6_diag #(.NW(128), .NL(NL), .TX_REG(TX_REG), .RX_REG(RX_REG)) u_diag (
      .aclk(aclk), .aresetn(aresetn),
      .s_axi_awaddr(s_axi_awaddr[11:0]), .s_axi_awvalid(s_axi_awvalid && w_d), .s_axi_awready(d_awready),
      .s_axi_wdata(s_axi_wdata), .s_axi_wvalid(s_axi_wvalid && w_d), .s_axi_wready(d_wready),
      .s_axi_bresp(d_bresp), .s_axi_bvalid(d_bvalid), .s_axi_bready(s_axi_bready),
      .s_axi_araddr(s_axi_araddr[11:0]), .s_axi_arvalid(s_axi_arvalid && r_d), .s_axi_arready(d_arready),
      .s_axi_rdata(d_rdata), .s_axi_rresp(d_rresp), .s_axi_rvalid(d_rvalid), .s_axi_rready(s_axi_rready),
      .clk(clk), .probe_en(probe_en), .clr(dclr), .period(p_period), .hbase(p_hbase), .live(live));

  // ---------------- LINK word ----------------
  logic a_lost_s, a_err_s, b_lost_s, b_err_s;
  logic a_lock_d, b_lock_d;
  logic [31:0] a_esum_d, b_esum_d;
  wire  [31:0] a_esum = la_stat.n_sh_bad + la_stat.n_idle_bad;
  wire  [31:0] b_esum = lb_stat.n_sh_bad + lb_stat.n_idle_bad;
  always_ff @(posedge clk) begin
    a_lock_d <= a_lock; b_lock_d <= b_lock; a_esum_d <= a_esum; b_esum_d <= b_esum;
    if (a_srst) {a_lost_s, a_err_s} <= 2'b00;
    else begin
      if (a_lock_d && !a_lock) a_lost_s <= 1'b1;
      if (a_esum != a_esum_d) a_err_s <= 1'b1;
    end
    if (b_srst) {b_lost_s, b_err_s} <= 2'b00;
    else begin
      if (b_lock_d && !b_lock) b_lost_s <= 1'b1;
      if (b_esum != b_esum_d) b_err_s <= 1'b1;
    end
  end
  logic [2:0] a_l3, b_l3;
  always_comb begin
    a_l3 = '0; b_l3 = '0;
    if (NL > 1) begin a_l3 = la_stat.lock; b_l3 = lb_stat.lock; end
  end
  wire [31:0] core_stat = {1'b0, b_l3, a_l3, 1'b0, 12'b0, b_err_s, b_lost_s, b_lock, b_lock, 4'b0,
                           a_err_s, a_lost_s, a_lock, a_lock};
  wire [31:0] link_stat = core_stat | (board_stat & 32'h01FF_7070);

  s3_regs #(.NVEC(NVEC), .DEC_LAT(DEC_LAT), .TIMEOUT(TIMEOUT), .N_DET(N_DET), .DW(DW)) u_regs (
      .aclk(aclk), .aresetn(aresetn),
      .s_axi_awaddr(s_axi_awaddr[11:0]), .s_axi_awvalid(s_axi_awvalid && !w_d), .s_axi_awready(r_awready),
      .s_axi_wdata(s_axi_wdata), .s_axi_wstrb(s_axi_wstrb), .s_axi_wvalid(s_axi_wvalid && !w_d), .s_axi_wready(r_wready),
      .s_axi_bresp(r_bresp), .s_axi_bvalid(r_bvalid), .s_axi_bready(s_axi_bready),
      .s_axi_araddr(s_axi_araddr[11:0]), .s_axi_arvalid(s_axi_arvalid && !r_d), .s_axi_arready(r_arready),
      .s_axi_rdata(r_rdata), .s_axi_rresp(r_rresp), .s_axi_rvalid(r_rvalid), .s_axi_rready(s_axi_rready),
      .clk_a(clk), .a_run(a_run), .a_mode_echo(a_mode), .a_soft_rst(a_srst), .a_gap(a_gap),
      .a_hist_base(a_hbase), .a_rd_req(a_rd_req), .a_rd_sel(a_rd_sel), .a_rd_addr(a_rd_addr),
      .a_rd_data(a_rd_data), .a_rd_ack(a_rd_ack), .a_done(a_done), .a_stat(a_stat),
      .clk_b(clk), .b_soft_rst(b_srst), .b_stat(b_stat),
      .board_ctrl(board_ctrl), .link_stat(link_stat), .freq_a(freq_clk), .freq_b(freq_clk));

  wire unused = &{1'b0, a_busy};
endmodule
