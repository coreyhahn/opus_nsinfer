// s3_regs: Stage 3 AXI4-Lite slave (32 bit, clk_axi) and every clock crossing of the loop.
// Address map (byte offsets; also rtl/s3/s3_regmap.md):
//   0x000 ID        RO  32'h5333_0001
//   0x004 CTRL      RW  [0] run  [1] mode_echo  [4] soft_rst_a  [5] soft_rst_b
//   0x008 GAP       RW  [15:0] idle cycles between shots (one shot every GAP+1 clk_a cycles)
//   0x00C HIST_BASE RW  [15:0] latency of histogram bin 0 (clk_a cycles)
//   0x010 STATUS    RO  [0] done (snapshot valid)  [1] timeout  [2] rd_busy
//   0x014 RD_CMD    W: [31] sel (0 histogram bin, 1 flag RAM)  [23:0] addr; starts a read
//                   R: same fields, [30] = rd_busy
//   0x018 RD_DATA   RO  data of the last completed read (histogram count, or {30'b0, seen, flip})
//   0x040.. side A snapshot, 0x0C0.. side B snapshot, 0x0F0 NVEC, 0x0F4 DEC_LAT, 0x0F8 TIMEOUT,
//   0x0FC N_DET, 0x100 DW (build parameters, read only)
//   (field list: s3_regmap.md)
//
// Crossings (no async FIFOs):
//   * control -> clk_a / clk_b: 2-flop synchronisers, quasi-static (software writes GAP, HIST_BASE and
//     mode_echo before raising run, and changes nothing while a run is busy).
//   * status: side A raises `done` once its counters are final and ignores the link while done, and
//     side B is idle once A has every response, so both status buses are static while done = 1.
//     done crosses through 2 flops; one clk_axi cycle after it is seen the buses are sampled into the
//     snapshot registers that the bus reads return. Re-run (run 0 -> 1) re-arms the snapshot.
//   * histogram / flag RAM reads: request toggle (address and sel held in clk_axi registers, stable
//     before the toggle crosses) -> 2-flop + edge -> rd_req pulse in clk_a; side A answers with
//     rd_ack (rd_data held until the next request) -> ack toggle in clk_a -> 2 flops -> RD_DATA.
//   Timing: every crossing path takes set_max_delay -datapath_only (one destination period).
module s3_regs
  import s3_pkg::*;
#(
    parameter int NVEC    = 464428,
    parameter int DEC_LAT = 8,
    parameter int TIMEOUT = 100000,
    parameter int N_DET   = 24,
    parameter int DW      = 64
) (
    input  logic        aclk,
    input  logic        aresetn,
    input  logic [11:0] s_axi_awaddr,
    input  logic        s_axi_awvalid,
    output logic        s_axi_awready,
    input  logic [31:0] s_axi_wdata,
    input  logic [3:0]  s_axi_wstrb,
    input  logic        s_axi_wvalid,
    output logic        s_axi_wready,
    output logic [1:0]  s_axi_bresp,
    output logic        s_axi_bvalid,
    input  logic        s_axi_bready,
    input  logic [11:0] s_axi_araddr,
    input  logic        s_axi_arvalid,
    output logic        s_axi_arready,
    output logic [31:0] s_axi_rdata,
    output logic [1:0]  s_axi_rresp,
    output logic        s_axi_rvalid,
    input  logic        s_axi_rready,
    // side A (clk_a)
    input  logic        clk_a,
    output logic        a_run,
    output logic        a_mode_echo,
    output logic        a_soft_rst,
    output logic [15:0] a_gap,
    output logic [15:0] a_hist_base,
    output logic        a_rd_req,
    output logic        a_rd_sel,
    output logic [23:0] a_rd_addr,
    input  logic [31:0] a_rd_data,
    input  logic        a_rd_ack,
    input  logic        a_done,
    input  s3_a_stat_t  a_stat,
    // side B (clk_b)
    input  logic        clk_b,
    output logic        b_soft_rst,
    input  s3_b_stat_t  b_stat,
    // board (s3_top): GT loopback / reset overrides out (aclk), link status in (asynchronous,
    // synchronised here), user-clock frequency counts (already in aclk, s3_freq)
    output logic [31:0] board_ctrl,
    input  logic [31:0] link_stat,
    input  logic [31:0] freq_a,
    input  logic [31:0] freq_b
);
  // ---------------- clk_axi registers ----------------
  logic        c_run, c_mode, c_rst_a, c_rst_b;
  logic [15:0] c_gap, c_hbase;
  logic        rd_tgl, rd_sel_q;
  logic [23:0] rd_addr_q;
  logic [31:0] rd_data_q;
  s3_a_stat_t  a_snap;
  s3_b_stat_t  b_snap;
  logic [31:0] c_board;
  (* ASYNC_REG = "TRUE" *) logic [31:0] link_s1, link_s2;
  always_ff @(posedge aclk) begin
    link_s1 <= link_stat;
    link_s2 <= link_s1;
  end
  assign board_ctrl = c_board;

  // ---------------- control -> clk_a, clk_b ----------------
  (* ASYNC_REG = "TRUE" *) logic [34:0] a_ctl_s1, a_ctl_s2;
  always_ff @(posedge clk_a) begin
    a_ctl_s1 <= {c_rst_a, c_run, c_mode, c_gap, c_hbase};
    a_ctl_s2 <= a_ctl_s1;
  end
  assign {a_soft_rst, a_run, a_mode_echo, a_gap, a_hist_base} = a_ctl_s2;

  (* ASYNC_REG = "TRUE" *) logic b_rst_s1, b_rst_s2;
  always_ff @(posedge clk_b) begin
    b_rst_s1 <= c_rst_b;
    b_rst_s2 <= b_rst_s1;
  end
  assign b_soft_rst = b_rst_s2;

  // ---------------- read request / ack (toggle handshake) ----------------
  (* ASYNC_REG = "TRUE" *) logic [1:0] a_req_s;
  logic a_req_d;
  logic a_ack_tgl = 1'b0;
  always_ff @(posedge clk_a) begin
    a_req_s <= {a_req_s[0], rd_tgl};
    a_req_d <= a_req_s[1];
    if (a_rd_ack) a_ack_tgl <= ~a_ack_tgl;
  end
  assign a_rd_req  = a_req_s[1] ^ a_req_d;
  assign a_rd_sel  = rd_sel_q;   // held since before the toggle
  assign a_rd_addr = rd_addr_q;

  (* ASYNC_REG = "TRUE" *) logic [1:0] ack_s;
  logic ack_d;
  always_ff @(posedge aclk) begin
    ack_s <= {ack_s[0], a_ack_tgl};
    ack_d <= ack_s[1];
  end
  wire rd_busy = (rd_tgl != ack_s[1]);

  // ---------------- done -> snapshot ----------------
  (* ASYNC_REG = "TRUE" *) logic [1:0] done_s;
  logic done_d;
  always_ff @(posedge aclk) begin
    done_s <= {done_s[0], a_done};
    done_d <= done_s[1];
    if (done_s[1] && !done_d) begin
      a_snap <= a_stat;
      b_snap <= b_stat;
    end
    if (ack_s[1] != ack_d) rd_data_q <= a_rd_data;
  end
  wire snap_ok = done_s[1] && done_d;

  // ---------------- AXI4-Lite write ----------------
  assign s_axi_bresp = 2'b00;
  assign s_axi_rresp = 2'b00;
  always_ff @(posedge aclk) begin
    if (!aresetn) begin
      s_axi_awready <= 1'b0; s_axi_wready <= 1'b0; s_axi_bvalid <= 1'b0;
      c_run <= 1'b0; c_mode <= 1'b0; c_rst_a <= 1'b0; c_rst_b <= 1'b0; c_gap <= '0; c_hbase <= '0; c_board <= '0;
      rd_tgl <= ack_s[1]; rd_sel_q <= 1'b0; rd_addr_q <= '0;
    end else begin
      s_axi_awready <= 1'b0;
      s_axi_wready  <= 1'b0;
      if (!s_axi_awready && s_axi_awvalid && s_axi_wvalid && !s_axi_bvalid) begin
        s_axi_awready <= 1'b1;
        s_axi_wready  <= 1'b1;
      end
      if (s_axi_awready && s_axi_awvalid && s_axi_wvalid) begin
        s_axi_bvalid <= 1'b1;
        case (s_axi_awaddr[11:2])
          10'h001: {c_rst_b, c_rst_a, c_mode, c_run} <= {s_axi_wdata[5:4], s_axi_wdata[1:0]};
          10'h002: c_gap   <= s_axi_wdata[15:0];
          10'h003: c_hbase <= s_axi_wdata[15:0];
          10'h005: if (!rd_busy) begin
            rd_sel_q <= s_axi_wdata[31]; rd_addr_q <= s_axi_wdata[23:0]; rd_tgl <= ~rd_tgl;
          end
          10'h008: c_board <= s_axi_wdata;
          default: ;
        endcase
      end
      if (s_axi_bvalid && s_axi_bready) s_axi_bvalid <= 1'b0;
    end
  end

  // ---------------- AXI4-Lite read ----------------
  logic [31:0] rmux;
  always_comb begin
    case (s_axi_araddr[11:2])
      10'h000: rmux = 32'h5333_0001;
      10'h001: rmux = {26'b0, c_rst_b, c_rst_a, 2'b0, c_mode, c_run};
      10'h002: rmux = {16'b0, c_gap};
      10'h003: rmux = {16'b0, c_hbase};
      10'h004: rmux = {29'b0, rd_busy, a_snap.timeout & snap_ok, snap_ok};
      10'h005: rmux = {rd_sel_q, rd_busy, 6'b0, rd_addr_q};
      10'h006: rmux = rd_data_q;
      10'h008: rmux = c_board;
      10'h009: rmux = link_s2;
      10'h00A: rmux = freq_a;
      10'h00B: rmux = freq_b;
      // side A snapshot
      10'h010: rmux = a_snap.n_sent;
      10'h011: rmux = a_snap.n_rx_words;
      10'h012: rmux = a_snap.n_good;
      10'h013: rmux = a_snap.lat_min;
      10'h014: rmux = a_snap.lat_max;
      10'h015: rmux = a_snap.lat_sum[31:0];
      10'h016: rmux = {16'b0, a_snap.lat_sum[47:32]};
      10'h017: rmux = a_snap.mism;
      10'h018: rmux = {a_snap.first_mis_v, 7'b0, a_snap.first_mis_seq};
      10'h019: rmux = a_snap.err_tag;
      10'h01A: rmux = a_snap.err_range;
      10'h01B: rmux = a_snap.err_overrun;
      10'h01C: rmux = a_snap.err_dup;
      10'h01D: rmux = a_snap.err_echo;
      10'h01E: rmux = a_snap.hist_under;
      10'h01F: rmux = a_snap.hist_over;
      10'h020: rmux = a_snap.sig;
      // side B snapshot
      10'h030: rmux = b_snap.n_rx;
      10'h031: rmux = b_snap.n_tx;
      10'h032: rmux = b_snap.err_tag;
      10'h033: rmux = b_snap.fifo_ovf;
      10'h034: rmux = b_snap.collide;
      10'h035: rmux = {27'b0, b_snap.fifo_max};
      10'h036: rmux = {b_snap.dec_max, b_snap.dec_min};
      10'h037: rmux = b_snap.dec_cnt;
      10'h038: rmux = {b_snap.echo_max, b_snap.echo_min};
      10'h039: rmux = b_snap.echo_cnt;
      // build parameters
      10'h03C: rmux = 32'(NVEC);
      10'h03D: rmux = 32'(DEC_LAT);
      10'h03E: rmux = 32'(TIMEOUT);
      10'h03F: rmux = 32'(N_DET);
      10'h040: rmux = 32'(DW);
      default: rmux = 32'hDEAD_BEEF;
    endcase
  end
  always_ff @(posedge aclk) begin
    if (!aresetn) begin
      s_axi_arready <= 1'b0; s_axi_rvalid <= 1'b0; s_axi_rdata <= '0;
    end else begin
      s_axi_arready <= 1'b0;
      if (!s_axi_arready && s_axi_arvalid && !s_axi_rvalid) s_axi_arready <= 1'b1;
      if (s_axi_arready && s_axi_arvalid) begin
        s_axi_rvalid <= 1'b1;
        s_axi_rdata  <= rmux;
      end
      if (s_axi_rvalid && s_axi_rready) s_axi_rvalid <= 1'b0;
    end
  end

  // full-word writes only; RD_CMD [30:24] reserved
  wire unused = &{1'b0, s_axi_wstrb, s_axi_awaddr[1:0], s_axi_araddr[1:0], s_axi_wdata[30:24]};
endmodule
