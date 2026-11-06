// s6_diag: Stage 6 link diagnostics and probe control, AXI4-Lite slave (32 bit, aclk), mapped at 0x1000 by
// s6_core (local byte offsets below; register map rtl/s6/s6_regmap.md).
//   0x000 ID       RO  32'h5336_0001
//   0x004 CTRL     RW  [0] probe_en (both ends send probe words; s3 sides see no RX), [1] clr (zero link and
//                      probe counters while 1)
//   0x008 PERIOD   RW  [15:0] probe period - 1 (one probe word every PERIOD+1 cycles)
//   0x00C HBASE    RW  [15:0] latency of probe histogram bin 0
//   0x010 SNAP     W   any value: capture every live word below into the snapshot (clk domain); R [0] busy
//   0x014 PARAMS   RO  [3:0] NL, [4] TX_REG, [5] RX_REG
//   0x400 + 4k     RO  snapshot word k, k = 0 .. NW-1 (s6_core assembles the live words; s6_regmap.md)
// Crossings: control -> clk through 2 flops (quasi-static); the snapshot request is a toggle (2 flops + edge
// in clk), captured in clk, acknowledged by a toggle back (2 flops in aclk); the snapshot registers are static
// once acknowledged and are read directly by the aclk read mux (set_max_delay -datapath_only in the XDC).
module s6_diag #(
    parameter int NW     = 128,
    parameter int NL     = 1,
    parameter int TX_REG = 0,
    parameter int RX_REG = 0
) (
    input  logic        aclk,
    input  logic        aresetn,
    input  logic [11:0] s_axi_awaddr,
    input  logic        s_axi_awvalid,
    output logic        s_axi_awready,
    input  logic [31:0] s_axi_wdata,
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
    // clk domain
    input  logic        clk,
    output logic        probe_en,
    output logic        clr,
    output logic [15:0] period,
    output logic [15:0] hbase,
    input  logic [NW-1:0][31:0] live
);
  // ---------------- aclk registers ----------------
  logic        c_en, c_clr, snap_tgl;
  logic [15:0] c_period, c_hbase;
  (* ASYNC_REG = "TRUE" *) logic [1:0] ack_s;
  wire busy = (snap_tgl != ack_s[1]);

  // ---------------- -> clk ----------------
  (* ASYNC_REG = "TRUE" *) logic [33:0] ctl_s1, ctl_s2;
  (* ASYNC_REG = "TRUE" *) logic [1:0]  req_s;
  logic req_d, ack_tgl = 1'b0;
  logic [NW-1:0][31:0] snap;
  always_ff @(posedge clk) begin
    ctl_s1 <= {c_en, c_clr, c_period, c_hbase};
    ctl_s2 <= ctl_s1;
    req_s  <= {req_s[0], snap_tgl};
    req_d  <= req_s[1];
    if (req_s[1] != req_d) begin
      snap <= live;
      ack_tgl <= ~ack_tgl;
    end
  end
  assign {probe_en, clr, period, hbase} = ctl_s2;
  always_ff @(posedge aclk) ack_s <= {ack_s[0], ack_tgl};

  // ---------------- AXI4-Lite write ----------------
  assign s_axi_bresp = 2'b00;
  assign s_axi_rresp = 2'b00;
  always_ff @(posedge aclk) begin
    if (!aresetn) begin
      s_axi_awready <= 1'b0; s_axi_wready <= 1'b0; s_axi_bvalid <= 1'b0;
      c_en <= 1'b0; c_clr <= 1'b0; c_period <= 16'd63; c_hbase <= '0; snap_tgl <= ack_s[1];
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
          10'h001: {c_clr, c_en} <= s_axi_wdata[1:0];
          10'h002: c_period <= s_axi_wdata[15:0];
          10'h003: c_hbase  <= s_axi_wdata[15:0];
          10'h004: if (!busy) snap_tgl <= ~snap_tgl;
          default: ;
        endcase
      end
      if (s_axi_bvalid && s_axi_bready) s_axi_bvalid <= 1'b0;
    end
  end

  // ---------------- AXI4-Lite read ----------------
  logic [31:0] rmux;
  always_comb begin
    rmux = 32'hDEAD_BEEF;
    if (s_axi_araddr[11:10] == 2'b01) begin
      if (32'(s_axi_araddr[9:2]) < 32'(NW)) rmux = snap[s_axi_araddr[$clog2(NW)+1:2]];
    end else begin
      case (s_axi_araddr[9:2])
        8'h00: rmux = 32'h5336_0001;
        8'h01: rmux = {30'b0, c_clr, c_en};
        8'h02: rmux = {16'b0, c_period};
        8'h03: rmux = {16'b0, c_hbase};
        8'h04: rmux = {31'b0, busy};
        8'h05: rmux = {26'b0, RX_REG[0], TX_REG[0], 4'(NL)};
        default: ;
      endcase
    end
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
  wire unused = &{1'b0, s_axi_awaddr[1:0], s_axi_araddr[1:0], s_axi_wdata[31:16]};
endmodule
