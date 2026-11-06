// ZCU102 Stage 1 board top: SI570 -> MMCME4_ADV (clk_net, clk_ps fine-PS, clk_axi), PS block design, pads, jsc_harness (docs/ARCHITECTURE.md §1, §6).
`timescale 1 ns / 1 ps

module zcu102_top #(
  int F_NET_MHZ  = 300,  // 300, 200 or 500 (§6 table); selects the MMCM settings and AXI_DIV
  int LAT_NET    = 10,   // da4ml core latency + 1 (set by the build script from metadata.json)
  int ARG_LAT    = 1,
  int DEPTH_LOG2 = 14,
  int LC         = 3
)(
  input  logic       si570_clk_p,  // AL8, 300 MHz at power-up, DIFF_SSTL12
  input  logic       si570_clk_n,  // AL7
  inout  wire        pin_b,        // A20, PMOD0_0 (J55.1): launch out (clk_ps OPFF), IN_VALID in (clk_net IPFF)
  inout  wire        pin_c,        // D20, PMOD1_0 (J87.1): DEC_VALID out (clk_net OPFF), readback in (clk_ps IPFF)
  output logic [2:0] class_o,      // F20, G20, J20 (PMOD1_4..6)
  output logic [1:0] led           // LED0 AG14 = MMCM locked, LED1 AF13 = heartbeat
);
  // ---------------- §6 per-F_net MMCM settings (VCO = 300 MHz * M / D) ----------------
  localparam real MMCM_M    = (F_NET_MHZ == 500) ? 5.0 : 4.0;   // VCO 1500 / 1200 / 1200 MHz
  localparam int  NET_DIV   = (F_NET_MHZ == 500) ? 3 : (F_NET_MHZ == 200) ? 6 : 4;
  localparam int  AXI_DIV   = (F_NET_MHZ == 500) ? 2 : 1;
  localparam int  PS_STEPS_PER_PERIOD = 56 * NET_DIV;
  if (F_NET_MHZ != 300 && F_NET_MHZ != 200 && F_NET_MHZ != 500) begin : g_bad_fnet
    $error("zcu102_top: F_NET_MHZ must be 300, 200 or 500");
  end

  // ---------------- clocking ----------------
  logic clk_in, clk_fb_o, clk_fb, clk0_o, clk1_o, clk2_o;
  logic clk_net, clk_ps, clk_axi, mmcm_locked;
  logic psen, psincdec, psdone;

  IBUFDS u_ibufds (.I(si570_clk_p), .IB(si570_clk_n), .O(clk_in));

  MMCME4_ADV #(
    .BANDWIDTH           ("OPTIMIZED"),
    .COMPENSATION        ("AUTO"),
    .CLKIN1_PERIOD       (3.333),
    .DIVCLK_DIVIDE       (1),
    .CLKFBOUT_MULT_F     (MMCM_M),
    .CLKFBOUT_PHASE      (0.0),
    .CLKOUT0_DIVIDE_F    (real'(NET_DIV)),
    .CLKOUT1_DIVIDE      (NET_DIV),
    .CLKOUT1_USE_FINE_PS ("TRUE"),
    .CLKOUT2_DIVIDE      (NET_DIV * AXI_DIV),
    .STARTUP_WAIT        ("FALSE")
  ) u_mmcm (
    .CLKIN1(clk_in), .CLKIN2(1'b0), .CLKINSEL(1'b1),
    .CLKFBIN(clk_fb), .CLKFBOUT(clk_fb_o), .CLKFBOUTB(),
    .CLKOUT0(clk0_o), .CLKOUT0B(), .CLKOUT1(clk1_o), .CLKOUT1B(),
    .CLKOUT2(clk2_o), .CLKOUT2B(), .CLKOUT3(), .CLKOUT3B(),
    .CLKOUT4(), .CLKOUT5(), .CLKOUT6(),
    .LOCKED(mmcm_locked), .CLKINSTOPPED(), .CLKFBSTOPPED(),
    .RST(1'b0), .PWRDWN(1'b0),
    .PSCLK(clk_net), .PSEN(psen), .PSINCDEC(psincdec), .PSDONE(psdone),
    .DCLK(1'b0), .DEN(1'b0), .DWE(1'b0), .DADDR(7'd0), .DI(16'd0), .DO(), .DRDY(),
    .CDDCREQ(1'b0), .CDDCDONE()
  );

  BUFG u_bufg_fb  (.I(clk_fb_o), .O(clk_fb));
  BUFG u_bufg_net (.I(clk0_o),   .O(clk_net));
  BUFG u_bufg_ps  (.I(clk1_o),   .O(clk_ps));
  if (AXI_DIV == 1) begin : g_axi_eq_net
    assign clk_axi = clk_net;        // one BUFG net: clk_axi IS clk_net
  end else begin : g_axi_div
    BUFG u_bufg_axi (.I(clk2_o), .O(clk_axi));
  end

  // ---------------- reset synchronisers (assert on !locked, release synchronously) ----------------
  (* ASYNC_REG = "TRUE" *) logic [2:0] rs_net = '1, rs_ps = '1, rs_axi = '1;
  always_ff @(posedge clk_net or negedge mmcm_locked)
    if (!mmcm_locked) rs_net <= '1; else rs_net <= {rs_net[1:0], 1'b0};
  always_ff @(posedge clk_ps or negedge mmcm_locked)
    if (!mmcm_locked) rs_ps <= '1; else rs_ps <= {rs_ps[1:0], 1'b0};
  always_ff @(posedge clk_axi or negedge mmcm_locked)
    if (!mmcm_locked) rs_axi <= '1; else rs_axi <= {rs_axi[1:0], 1'b0};
  logic rst_net, rst_ps, aresetn;
  assign rst_net = rs_net[2];
  assign rst_ps  = rs_ps[2];
  assign aresetn = ~rs_axi[2];

  // ---------------- PS block design (HPM0_FPD -> AXI4-Lite 32 b, 21-bit address) ----------------
  logic [20:0] awaddr, araddr;
  logic [2:0]  awprot, arprot;
  logic        awvalid, awready, wvalid, wready, bvalid, bready;
  logic        arvalid, arready, rvalid, rready;
  logic [31:0] wdata, rdata;
  logic [3:0]  wstrb;
  logic [1:0]  bresp, rresp;

  ps_bd_wrapper u_ps (
    .clk_axi        (clk_axi),
    .aresetn        (aresetn),
    .M_AXI_awaddr   (awaddr),  .M_AXI_awprot (awprot), .M_AXI_awvalid (awvalid), .M_AXI_awready (awready),
    .M_AXI_wdata    (wdata),   .M_AXI_wstrb  (wstrb),  .M_AXI_wvalid  (wvalid),  .M_AXI_wready  (wready),
    .M_AXI_bresp    (bresp),   .M_AXI_bvalid (bvalid), .M_AXI_bready  (bready),
    .M_AXI_araddr   (araddr),  .M_AXI_arprot (arprot), .M_AXI_arvalid (arvalid), .M_AXI_arready (arready),
    .M_AXI_rdata    (rdata),   .M_AXI_rresp  (rresp),  .M_AXI_rvalid  (rvalid),  .M_AXI_rready  (rready)
  );

  // ---------------- pads ----------------
  logic pin_b_o, pin_b_i, pin_c_o, pin_c_i, heartbeat;
  logic [2:0] class_d;
  // Output always enabled. T comes from a constant-0 DONT_TOUCH flop rather than 1'b0: with a
  // literal 0 Vivado's case analysis disables the IBUFCTRL I->O arc and never times pad -> IPFF.
  (* DONT_TOUCH = "TRUE" *) logic pad_t = 1'b0;
  always_ff @(posedge clk_net) pad_t <= 1'b0;
  IOBUF u_iob_b (.I(pin_b_o), .T(pad_t), .O(pin_b_i), .IO(pin_b));
  IOBUF u_iob_c (.I(pin_c_o), .T(pad_t), .O(pin_c_i), .IO(pin_c));
  for (genvar i = 0; i < 3; i++) begin : g_class
    OBUF u_obuf (.I(class_d[i]), .O(class_o[i]));
  end
  OBUF u_led0 (.I(mmcm_locked), .O(led[0]));
  OBUF u_led1 (.I(heartbeat),   .O(led[1]));

  // ---------------- harness ----------------
  jsc_harness #(
    .LAT_NET (LAT_NET), .ARG_LAT (ARG_LAT), .DEPTH_LOG2 (DEPTH_LOG2),
    .F_NET_MHZ (F_NET_MHZ), .AXI_DIV (AXI_DIV),
    .PS_STEPS_PER_PERIOD (PS_STEPS_PER_PERIOD), .LC (LC)
  ) u_harness (
    .clk_net (clk_net), .rst_net (rst_net),
    .clk_axi (clk_axi), .aresetn (aresetn),
    .clk_ps  (clk_ps),  .rst_ps  (rst_ps),
    .s_axi_awaddr (awaddr), .s_axi_awvalid (awvalid), .s_axi_awready (awready),
    .s_axi_wdata  (wdata),  .s_axi_wstrb   (wstrb),   .s_axi_wvalid  (wvalid), .s_axi_wready (wready),
    .s_axi_bresp  (bresp),  .s_axi_bvalid  (bvalid),  .s_axi_bready  (bready),
    .s_axi_araddr (araddr), .s_axi_arvalid (arvalid), .s_axi_arready (arready),
    .s_axi_rdata  (rdata),  .s_axi_rresp   (rresp),   .s_axi_rvalid  (rvalid), .s_axi_rready (rready),
    .psen (psen), .psincdec (psincdec), .psdone (psdone), .mmcm_locked (mmcm_locked),
    .pin_b_o (pin_b_o), .pin_b_i (pin_b_i),
    .pin_c_o (pin_c_o), .pin_c_i (pin_c_i),
    .class_o (class_d),
    .heartbeat (heartbeat)
  );
endmodule
