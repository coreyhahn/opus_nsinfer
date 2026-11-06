// jsc_harness: Stage 1 measurement harness around the da4ml JSC core (ZCU102).
//
// Contract: docs/ARCHITECTURE.md (ports, address map, cycle-by-cycle timed
// path); method: docs/MEASUREMENT.md. Three clocks from one MMCM:
//   clk_net  network, timed path, stream engine, timestamp counter, PSCLK
//   clk_axi  AXI4-Lite CSR (clk_net itself when AXI_DIV = 1, else synchronous)
//   clk_ps   phase-shifted copy of clk_net: the launch fixture and the
//            pin C readback only; every crossing to or from it is either a
//            2-FF synchroniser, a measured event, or a quasi-static value.
// Pads: pin B and pin C are IOBUFs with T = 0, so each pin's input buffer
// reads its own pad (pad loopback, no external wire).
`timescale 1ns / 1ps
`default_nettype none

module jsc_harness #(
    parameter int LAT_NET             = 10,
    parameter int ARG_LAT             = 1,
    parameter int DEPTH_LOG2          = 14,
    parameter int F_NET_MHZ           = 300,
    parameter int AXI_DIV             = 1,
    parameter int PS_STEPS_PER_PERIOD = 224,
    parameter int LC                  = 3
) (
    input  wire         clk_net,
    input  wire         rst_net,
    input  wire         clk_axi,
    input  wire         aresetn,
    input  wire         clk_ps,
    input  wire         rst_ps,

    input  wire  [20:0] s_axi_awaddr,
    input  wire         s_axi_awvalid,
    output logic        s_axi_awready,
    input  wire  [31:0] s_axi_wdata,
    input  wire  [3:0]  s_axi_wstrb,
    input  wire         s_axi_wvalid,
    output logic        s_axi_wready,
    output logic [1:0]  s_axi_bresp,
    output logic        s_axi_bvalid,
    input  wire         s_axi_bready,
    input  wire  [20:0] s_axi_araddr,
    input  wire         s_axi_arvalid,
    output logic        s_axi_arready,
    output logic [31:0] s_axi_rdata,
    output logic [1:0]  s_axi_rresp,
    output logic        s_axi_rvalid,
    input  wire         s_axi_rready,

    output logic        psen,
    output logic        psincdec,
    input  wire         psdone,
    input  wire         mmcm_locked,

    output wire         pin_b_o,
    input  wire         pin_b_i,
    output wire         pin_c_o,
    input  wire         pin_c_i,
    output wire  [2:0]  class_o,
    output wire         heartbeat
);
  localparam int DEPTH  = 1 << DEPTH_LOG2;
  localparam int IN_W   = 150;
  localparam int OUT_W  = 80;
  localparam int N_CORE = LAT_NET + ARG_LAT + 2;
  localparam int NVW    = 5;  // 32-bit words per input vector
  localparam int NRW    = 3;  // 32-bit words per result
  localparam logic [31:0] ID = 32'h4A53_4331;  // "JSC1"

  typedef logic [DEPTH_LOG2-1:0] addr_t;

  // ------------------------------------------------------------------
  // Memories
  // ------------------------------------------------------------------
  // vec_mem: port A on clk_axi (read/write, byte enables), port B on clk_net (read)
  logic [NVW-1:0] vec_we_a;
  logic [3:0]     vec_be_a;
  addr_t          vec_addr_a, vec_addr_b;
  logic [31:0]    vec_din_a;
  logic [31:0]    vec_dout_a[NVW];
  logic [31:0]    vec_dout_b[NVW], vec_dout_b_q[NVW];

  for (genvar w = 0; w < NVW; w++) begin : g_vec
    (* ram_style = "block" *) logic [31:0] mem[DEPTH];
    always_ff @(posedge clk_axi) begin
      for (int b = 0; b < 4; b++) if (vec_we_a[w] && vec_be_a[b]) mem[vec_addr_a][8*b+:8] <= vec_din_a[8*b+:8];
      vec_dout_a[w] <= mem[vec_addr_a];
    end
    always_ff @(posedge clk_net) begin
      vec_dout_b[w]   <= mem[vec_addr_b];
      vec_dout_b_q[w] <= vec_dout_b[w];
    end
  end
  wire [IN_W-1:0] vec_rd = {vec_dout_b_q[4][IN_W-129:0], vec_dout_b_q[3], vec_dout_b_q[2], vec_dout_b_q[1], vec_dout_b_q[0]};

  // res_mem: write on clk_net, read on clk_axi
  logic                res_we;
  addr_t               res_waddr, res_raddr;
  logic [OUT_W+2:0]    res_din;
  logic [OUT_W+2:0]    res_dout, res_dout_q;
  (* ram_style = "block" *) logic [OUT_W+2:0] res_mem[DEPTH];
  always_ff @(posedge clk_net) if (res_we) res_mem[res_waddr] <= res_din;
  always_ff @(posedge clk_axi) begin
    res_dout   <= res_mem[res_raddr];
    res_dout_q <= res_dout;
  end

  // ------------------------------------------------------------------
  // CSR state (clk_axi)
  // ------------------------------------------------------------------
  logic [31:0] scratch, stream_n, t_vec;
  /* verilator lint_off UNUSEDSIGNAL */
  logic [31:0] ps_cmd;  // [15:0] steps, [31] direction; [30:16] unused
  /* verilator lint_on UNUSEDSIGNAL */
  logic        mode, arm;
  logic        stream_tgl, stage_tgl, ps_tgl;

  // net-domain results read by the CSR (synchronous when AXI_DIV > 1)
  logic        stream_busy, stage_busy, ps_busy;
  logic [7:0]  stream_seq;
  logic [31:0] stream_cyc, k_h, k_b, k_c, cnt;
  logic        kh_valid, kb_valid, kc_valid;
  logic [2:0]  t_class;
  logic [OUT_W-1:0] t_logit;
  logic signed [31:0] ps_pos;
  // clk_ps-domain results (quasi-static, false path by clock groups)
  logic [31:0] p_g, p_d;
  logic        pg_valid, pd_valid;

  logic [1:0]  locked_s;
  always_ff @(posedge clk_axi) locked_s <= {locked_s[0], mmcm_locked};

  // ---- write channel ----
  logic        aw_hold, w_hold;
  logic [20:0] aw_addr;
  logic [31:0] w_data;
  logic [3:0]  w_strb;
  logic [2:0]  r_st;  // read pipeline stage (0 = idle)
  logic [20:0] r_addr;
  logic [31:0] csr_q;
  logic [31:0] vec_dout_a_q[NVW];
  wire         do_write = aw_hold && w_hold && !s_axi_bvalid && r_st != 3'd1;

  assign s_axi_awready = !aw_hold;
  assign s_axi_wready  = !w_hold;
  assign s_axi_bresp   = 2'b00;
  assign s_axi_rresp   = 2'b00;

  wire        wr_csr = aw_addr[20:19] == 2'b00;
  wire        wr_vec = aw_addr[20:19] == 2'b01;
  wire [11:0] wr_reg = aw_addr[11:0];

  always_ff @(posedge clk_axi) begin
    if (!aresetn) begin
      aw_hold <= 1'b0; w_hold <= 1'b0; s_axi_bvalid <= 1'b0;
      scratch <= '0; stream_n <= '0; t_vec <= '0; ps_cmd <= '0;
      mode <= 1'b0; arm <= 1'b0;
      stream_tgl <= 1'b0; stage_tgl <= 1'b0; ps_tgl <= 1'b0;
    end else begin
      if (s_axi_awvalid && s_axi_awready) begin aw_hold <= 1'b1; aw_addr <= s_axi_awaddr; end
      if (s_axi_wvalid && s_axi_wready) begin w_hold <= 1'b1; w_data <= s_axi_wdata; w_strb <= s_axi_wstrb; end
      if (s_axi_bvalid && s_axi_bready) s_axi_bvalid <= 1'b0;
      if (do_write) begin
        aw_hold <= 1'b0; w_hold <= 1'b0; s_axi_bvalid <= 1'b1;
        if (wr_csr) begin
          case (wr_reg)
            12'h00C: scratch <= w_data;
            12'h010: mode <= w_data[0];
            12'h014: stream_n <= w_data;
            12'h018: stream_tgl <= ~stream_tgl;
            12'h024: t_vec <= w_data;
            12'h028: stage_tgl <= ~stage_tgl;
            12'h02C: arm <= w_data[0];
            12'h060: begin ps_cmd <= w_data; ps_tgl <= ~ps_tgl; end
            default: ;
          endcase
        end
      end
    end
  end

  always_comb begin
    vec_we_a   = '0;
    vec_be_a   = w_strb;
    vec_din_a  = w_data;
    vec_addr_a = do_write ? aw_addr[5+:DEPTH_LOG2] : r_addr[5+:DEPTH_LOG2];
    if (do_write && wr_vec && aw_addr[4:2] < 3'(NVW)) vec_we_a[aw_addr[4:2]] = 1'b1;
  end

  // ---- read channel: fixed 3-cycle pipeline ----
  assign s_axi_arready = (r_st == 3'd0) && !s_axi_rvalid;
  assign res_raddr     = r_addr[4+:DEPTH_LOG2];

  logic [31:0] csr_mux;
  always_comb begin
    case (r_addr[11:0])
      12'h000: csr_mux = ID;
      12'h004: csr_mux = {8'(LC), 8'(N_CORE), 4'(DEPTH_LOG2), 4'(ARG_LAT), 8'(LAT_NET)};
      12'h008: csr_mux = {12'(PS_STEPS_PER_PERIOD), 4'(AXI_DIV), 16'(F_NET_MHZ)};
      12'h00C: csr_mux = scratch;
      12'h010: csr_mux = {31'd0, mode};
      12'h014: csr_mux = stream_n;
      12'h01C: csr_mux = {8'd0, stream_seq, 3'd0, pd_valid, pg_valid, kb_valid, kh_valid, kc_valid,
                          4'd0, locked_s[1], ps_busy, stage_busy, stream_busy};
      12'h020: csr_mux = stream_cyc;
      12'h024: csr_mux = t_vec;
      12'h02C: csr_mux = {31'd0, arm};
      12'h030: csr_mux = k_h;
      12'h034: csr_mux = k_b;
      12'h038: csr_mux = k_c;
      12'h03C: csr_mux = {29'd0, t_class};
      12'h040: csr_mux = t_logit[31:0];
      12'h044: csr_mux = t_logit[63:32];
      12'h048: csr_mux = {16'd0, t_logit[79:64]};
      12'h050: csr_mux = p_g;
      12'h054: csr_mux = p_d;
      12'h064: csr_mux = ps_pos;
      12'h070: csr_mux = cnt;
      default: csr_mux = 32'hDEAD_C0DE;
    endcase
  end

  always_ff @(posedge clk_axi) begin
    if (!aresetn) begin
      r_st <= 3'd0; s_axi_rvalid <= 1'b0;
    end else begin
      case (r_st)
        3'd0: if (s_axi_arvalid && s_axi_arready) begin r_addr <= s_axi_araddr; r_st <= 3'd1; end
        3'd1: begin csr_q <= csr_mux; r_st <= 3'd2; end  // memories read this cycle
        3'd2: r_st <= 3'd3;                               // memory output registers
        3'd3: begin
          s_axi_rvalid <= 1'b1;
          r_st <= 3'd0;
          case (r_addr[20:19])
            2'b00: s_axi_rdata <= csr_q;
            2'b01: s_axi_rdata <= (r_addr[4:2] < 3'(NVW)) ? vec_rd_a(r_addr[4:2]) : 32'd0;
            2'b10: case (r_addr[3:2])
                     2'd0: s_axi_rdata <= res_dout_q[31:0];
                     2'd1: s_axi_rdata <= res_dout_q[63:32];
                     2'd2: s_axi_rdata <= {13'd0, res_dout_q[OUT_W+2:OUT_W], res_dout_q[79:64]};
                     default: s_axi_rdata <= 32'd0;
                   endcase
            default: s_axi_rdata <= 32'hDEAD_C0DE;
          endcase
        end
        default: r_st <= 3'd0;
      endcase
      if (s_axi_rvalid && s_axi_rready) s_axi_rvalid <= 1'b0;
    end
  end

  // vec port A output register (memory output register stage for AXI reads)
  always_ff @(posedge clk_axi) for (int w = 0; w < NVW; w++) vec_dout_a_q[w] <= vec_dout_a[w];
  function automatic logic [31:0] vec_rd_a(input logic [2:0] w);
    vec_rd_a = vec_dout_a_q[w];
  endfunction

  // ------------------------------------------------------------------
  // clk_net: commands, counter, stream engine, timed path
  // ------------------------------------------------------------------
  logic stream_tgl_d, stage_tgl_d, ps_tgl_d, arm_n;
  wire  stream_go = stream_tgl != stream_tgl_d;
  wire  stage_go  = stage_tgl != stage_tgl_d;
  wire  ps_go     = ps_tgl != ps_tgl_d;

  always_ff @(posedge clk_net) begin
    if (rst_net) begin
      stream_tgl_d <= 1'b0; stage_tgl_d <= 1'b0; ps_tgl_d <= 1'b0; arm_n <= 1'b0; cnt <= '0;
    end else begin
      stream_tgl_d <= stream_tgl; stage_tgl_d <= stage_tgl; ps_tgl_d <= ps_tgl; arm_n <= arm;
      cnt <= cnt + 1'b1;
    end
  end
  assign heartbeat = cnt[27];

  // ---- vector read port B: stream issue or staging ----
  logic [DEPTH_LOG2:0] s_left;
  addr_t               s_addr, s_last;
  logic                last_wr;
  logic                s_issue, s_v1, s_v2, st_v1, st_v2;
  logic [IN_W-1:0]     staged;

  always_ff @(posedge clk_net) begin
    if (rst_net) begin
      stream_busy <= 1'b0; stage_busy <= 1'b0; s_left <= '0; s_issue <= 1'b0;
      s_v1 <= 1'b0; s_v2 <= 1'b0; st_v1 <= 1'b0; st_v2 <= 1'b0;
    end else begin
      s_issue <= 1'b0;
      if (stream_go) begin
        stream_busy <= 1'b1;
        s_addr      <= '0;
        s_left      <= (stream_n == 0 || stream_n > DEPTH) ? (DEPTH_LOG2 + 1)'(DEPTH) : (DEPTH_LOG2 + 1)'(stream_n);
        s_last      <= (stream_n == 0 || stream_n > DEPTH) ? addr_t'(DEPTH - 1) : addr_t'(stream_n - 1);
      end else if (s_left != 0) begin
        s_issue <= 1'b1;
        s_addr  <= s_addr + 1'b1;
        s_left  <= s_left - 1'b1;
      end
      // BRAM read latency 2 (array + output register)
      s_v1 <= s_issue; s_v2 <= s_v1;
      st_v1 <= stage_go; st_v2 <= st_v1;
      if (stage_go) stage_busy <= 1'b1;
      if (st_v2) begin staged <= vec_rd; stage_busy <= 1'b0; end
      if (last_wr) stream_busy <= 1'b0;
    end
  end
  // issue address: registered with s_issue so the read lines up with s_v1
  always_comb vec_addr_b = s_issue ? s_addr - 1'b1 : addr_t'(t_vec);

  // ---- timed path input: pad flop on the pin B readback (in a slice next to the pad; see
  //      docs/PLAN.md D-S1-IOB: the HD IOLOGIC FF is rated to an 8 ns period) ----
  logic ipff_b;
  logic sync_b;
  always_ff @(posedge clk_net) begin
    ipff_b <= pin_b_i;
    sync_b <= ipff_b;
  end

  // ---- the network ----
  wire [IN_W-1:0]  net_in = mode ? (sync_b ? staged : '0) : (s_v2 ? vec_rd : '0);
  wire             net_v  = mode ? sync_b : s_v2;
  wire [OUT_W-1:0] logits;
  jsc u_core (.clk(clk_net), .model_inp(net_in), .model_out(logits));

  logic [LAT_NET-1:0] vpipe;
  always_ff @(posedge clk_net) vpipe <= rst_net ? '0 : {vpipe[LAT_NET-2:0], net_v};

  wire [2:0]       a_cls;
  wire [OUT_W-1:0] a_logits;
  wire             a_vld;
  jsc_argmax #(.ARG_LAT(ARG_LAT)) u_arg (
      .clk(clk_net), .logits_in(logits), .vld_in(vpipe[LAT_NET-1]),
      .cls_out(a_cls), .logits_out(a_logits), .vld_out(a_vld));

  // ---- stream results ----
  addr_t s_out;
  assign last_wr = res_we && stream_busy && res_waddr == s_last;
  always_ff @(posedge clk_net) begin
    res_we <= 1'b0;
    if (rst_net || stream_go) s_out <= '0;
    else if (a_vld && !mode) begin
      res_we    <= 1'b1;
      res_waddr <= s_out;
      res_din   <= {a_cls, a_logits};
      s_out     <= s_out + 1'b1;
    end
  end

  always_ff @(posedge clk_net) begin
    if (rst_net) begin
      stream_cyc <= '0; stream_seq <= '0;
    end else begin
      if (stream_go) stream_cyc <= '0;
      else if (stream_busy) stream_cyc <= stream_cyc + 1'b1;
      if (last_wr) stream_seq <= stream_seq + 1'b1;
    end
  end

  // ---- timed path output: DEC_VALID and class code pad flops + fabric twin ----
                                          logic       opff_c;
                                          logic [2:0] class_q;
  (* DONT_TOUCH = "TRUE" *)               logic       c_tw;
  wire dec_d = mode && a_vld;
  always_ff @(posedge clk_net) begin
    opff_c <= dec_d;
    c_tw   <= dec_d;
    if (dec_d && !c_tw) class_q <= a_cls;
  end
  assign pin_c_o = opff_c;
  assign class_o = class_q;

  // ---- timestamp captures (clk_net), armed while ARM = 1 ----
  // The two anchor crossings (l_tw -> h_ff, c_tw -> g_ff) are timed on purpose; their routed
  // delays d_H / d_G anchor the phase sweep (docs/MEASUREMENT.md §2a). TB_ANCHOR_DLY (simulation
  // only, never defined for synthesis) gives them transport delays TB_DH / TB_DG in ns, so the
  // testbench checks the solver's sign conventions for non-zero anchors.
  wire l_tw_a, c_tw_a;
`ifdef TB_ANCHOR_DLY
  assign #(`TB_DH) l_tw_a = l_tw;
  assign #(`TB_DG) c_tw_a = c_tw;
`else
  assign l_tw_a = l_tw;
  assign c_tw_a = c_tw;
`endif
  (* ASYNC_REG = "TRUE" *) logic h_ff;
  logic [OUT_W-1:0] dec_logits;
  always_ff @(posedge clk_net) begin
    h_ff  <= l_tw_a; // anchor crossing clk_ps -> clk_net (timed: d_H)
    if (dec_d && !c_tw) begin t_class <= a_cls; dec_logits <= a_logits; end
    if (rst_net || !arm_n) begin
      kh_valid <= 1'b0; kb_valid <= 1'b0; kc_valid <= 1'b0;
    end else begin
      if (h_ff   && !kh_valid) begin k_h <= cnt; kh_valid <= 1'b1; end
      if (ipff_b && !kb_valid) begin k_b <= cnt; kb_valid <= 1'b1; end
      if (c_tw   && !kc_valid) begin k_c <= cnt; kc_valid <= 1'b1; end
    end
  end
  assign t_logit = dec_logits;

  // ---- phase-shift sequencer (PSCLK = clk_net) ----
  logic [15:0] ps_left;
  logic        ps_wait, ps_dir;
  always_ff @(posedge clk_net) begin
    if (rst_net) begin
      psen <= 1'b0; psincdec <= 1'b0; ps_left <= '0; ps_wait <= 1'b0; ps_busy <= 1'b0; ps_pos <= '0; ps_dir <= 1'b0;
    end else begin
      psen <= 1'b0;
      if (ps_go && !ps_busy) begin
        ps_left <= ps_cmd[15:0]; ps_dir <= ps_cmd[31]; ps_busy <= ps_cmd[15:0] != 0;
      end else if (ps_busy && !ps_wait) begin
        psen <= 1'b1; psincdec <= !ps_dir; ps_wait <= 1'b1;
      end else if (ps_wait && psdone) begin
        ps_wait <= 1'b0;
        ps_pos  <= ps_dir ? ps_pos - 1 : ps_pos + 1;
        ps_left <= ps_left - 1'b1;
        if (ps_left == 16'd1) ps_busy <= 1'b0;
      end
    end
  end

  // ------------------------------------------------------------------
  // clk_ps: launch fixture and pin C readback
  // ------------------------------------------------------------------
  (* ASYNC_REG = "TRUE" *)  logic arm_p1, arm_p2;
                            logic opff_l;
  (* DONT_TOUCH = "TRUE" *) logic l_tw;
                            logic ipff_d;
  (* ASYNC_REG = "TRUE" *)  logic g_ff;
  logic [31:0] pcnt;
  always_ff @(posedge clk_ps) begin
    arm_p1 <= arm;   // clk_axi -> clk_ps synchroniser
    arm_p2 <= arm_p1;
    opff_l <= arm_p2;
    l_tw   <= arm_p2;
    ipff_d <= pin_c_i;
    g_ff   <= c_tw_a; // anchor crossing clk_net -> clk_ps (timed: d_G)
    if (rst_ps) begin
      pcnt <= '0; pg_valid <= 1'b0; pd_valid <= 1'b0;
    end else begin
      pcnt <= pcnt + 1'b1;
      if (!arm_p2) begin
        pg_valid <= 1'b0; pd_valid <= 1'b0;
      end else begin
        if (g_ff   && !pg_valid) begin p_g <= pcnt; pg_valid <= 1'b1; end
        if (ipff_d && !pd_valid) begin p_d <= pcnt; pd_valid <= 1'b1; end
      end
    end
  end
  assign pin_b_o = opff_l;

  // AXI_DIV and F_NET_MHZ are informational (CFG register)
endmodule

`default_nettype wire
