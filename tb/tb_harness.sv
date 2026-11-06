// tb_harness: the Stage 1 harness (jsc_harness + da4ml core) through its AXI4-Lite port.
//
// Stream pass (bit-exactness): every test vector, in natural order (SEED = 0)
//   or the same xorshift32 Fisher-Yates shuffle as tb_jsc, loaded through AXI
//   in chunks of 2**DEPTH_LOG2, streamed at II = 1, results read back through
//   AXI; logits vs jsc_golden_out.hex and class vs jsc_golden_argmax.hex.
// Timed pass (measurement logic): pads modelled as transport delays D_B
//   (pin B out -> pin B in) and D_C (pin C out -> pin C in); clk_ps is
//   clk_net shifted by PHI0 + pos * T / PS_STEPS (the MMCM fine phase shift,
//   applied on PSEN, PSDONE 12 PSCLK cycles later). One TRIAL line per armed
//   trial for sw/analysis/timed_solve.py, which must recover D_B and D_C.
// Drive and sample at NEGEDGE of clk_axi only. Any check failure -> $fatal(1).
`timescale 1ns / 1fs

module tb_harness #(
    parameter int  NVEC       = 166000,
    parameter int  LAT_NET    = 10,
    parameter int  ARG_LAT    = 1,
    parameter int  DEPTH_LOG2 = 14,
    parameter int  AXI_DIV    = 1,
    parameter int  PS_STEPS   = 224,
    parameter real T_NS       = 3.333333,
    parameter real D_B        = 4.123457,  // pin B pad loop, ns
    parameter real D_C        = 3.876543,  // pin C pad loop, ns
    parameter real PHI0       = 0.004321   // clk_ps phase at PS_POS = 0, ns
);
  localparam int DEPTH  = 1 << DEPTH_LOG2;
  localparam int N_CORE = LAT_NET + ARG_LAT + 2;
  localparam logic [20:0] A_ID = 21'h000, A_PARAMS = 21'h004, A_CFG = 21'h008, A_SCRATCH = 21'h00C,
      A_CTRL = 21'h010, A_STREAM_N = 21'h014, A_STREAM_GO = 21'h018, A_STATUS = 21'h01C,
      A_STREAM_CYC = 21'h020, A_T_VEC = 21'h024, A_STAGE_GO = 21'h028, A_ARM = 21'h02C,
      A_K_H = 21'h030, A_K_B = 21'h034, A_K_C = 21'h038, A_T_CLASS = 21'h03C, A_T_LOGIT = 21'h040,
      A_P_G = 21'h050, A_P_D = 21'h054, A_PS_CMD = 21'h060, A_PS_POS = 21'h064, A_CNT = 21'h070,
      A_VEC = 21'h080000, A_RES = 21'h100000;

  // ---------------- clocks ----------------
  logic clk_net = 1'b0, clk_axi_div = 1'b0, clk_ps = 1'b0;
  wire  clk_axi = (AXI_DIV == 1) ? clk_net : clk_axi_div;
  // absolute edge times (k + 1)·T/2, so rounding to 1 fs never accumulates
  initial begin
    longint k = 0;
    forever begin
      k++;
      #(k * T_NS / 2.0 - $realtime);
      clk_net = ~clk_net;
      if (clk_net) clk_axi_div = ~clk_axi_div;
    end
  end
  realtime ps_pending = 0.0;
  initial begin
    realtime t_next;
    t_next = PHI0 + 1.5 * T_NS;  // clk_net rises at (k + 1/2) T
    forever begin
      #(t_next - $realtime);
      clk_ps = 1'b1;
      #(T_NS / 2.0);
      clk_ps = 1'b0;
      t_next = t_next + T_NS + ps_pending;
      ps_pending = 0.0;
    end
  end

  // measured clk_ps phase behind clk_net (ns, in [0, T)): ground truth for the solver
  realtime t_net_rise = 0.0, phi_meas = 0.0;
  always @(posedge clk_net) t_net_rise = $realtime;
  always @(posedge clk_ps) phi_meas = $realtime - t_net_rise;

  // ---------------- resets ----------------
  logic rst_net = 1'b1, rst_ps = 1'b1, aresetn = 1'b0;
  initial begin
    repeat (20) @(posedge clk_net);
    @(negedge clk_axi);
    rst_net = 1'b0; rst_ps = 1'b0; aresetn = 1'b1;
  end

  // ---------------- MMCM phase-shift model (PSCLK = clk_net) ----------------
  wire psen, psincdec;
  logic psdone = 1'b0;
  int ps_cnt = -1;
  always @(posedge clk_net) begin
    psdone <= 1'b0;
    if (psen) begin
      if (ps_cnt >= 0) $fatal(1, "PSEN while a phase step is in progress");
      ps_pending = ps_pending + (psincdec ? 1.0 : -1.0) * T_NS / PS_STEPS;
      ps_cnt <= 11;
    end else if (ps_cnt > 0) ps_cnt <= ps_cnt - 1;
    else if (ps_cnt == 0) begin psdone <= 1'b1; ps_cnt <= -1; end
  end

  // ---------------- pads ----------------
  wire pin_b_o, pin_c_o, pin_b_i, pin_c_i;
  wire [2:0] class_o;
  wire heartbeat;
  assign #(D_B) pin_b_i = pin_b_o;
  assign #(D_C) pin_c_i = pin_c_o;
  // true flop-to-flop latency, pin B launch to pin C launch (the pads in this model are the flops)
  realtime t_b_rise = 0.0, t_c_rise = 0.0;
  always @(posedge pin_b_o) t_b_rise = $realtime;
  always @(posedge pin_c_o) t_c_rise = $realtime;

  // ---------------- AXI ----------------
  logic [20:0] awaddr = '0, araddr = '0;
  logic        awvalid = 1'b0, wvalid = 1'b0, arvalid = 1'b0;
  logic [31:0] wdata = '0;
  wire         awready, wready, bvalid, arready, rvalid;
  wire  [1:0]  bresp, rresp;
  wire  [31:0] rdata;

  jsc_harness #(
      .LAT_NET(LAT_NET), .ARG_LAT(ARG_LAT), .DEPTH_LOG2(DEPTH_LOG2), .F_NET_MHZ(300),
      .AXI_DIV(AXI_DIV), .PS_STEPS_PER_PERIOD(PS_STEPS), .LC(3)
  ) dut (
      .clk_net(clk_net), .rst_net(rst_net), .clk_axi(clk_axi), .aresetn(aresetn),
      .clk_ps(clk_ps), .rst_ps(rst_ps),
      .s_axi_awaddr(awaddr), .s_axi_awvalid(awvalid), .s_axi_awready(awready),
      .s_axi_wdata(wdata), .s_axi_wstrb(4'hF), .s_axi_wvalid(wvalid), .s_axi_wready(wready),
      .s_axi_bresp(bresp), .s_axi_bvalid(bvalid), .s_axi_bready(1'b1),
      .s_axi_araddr(araddr), .s_axi_arvalid(arvalid), .s_axi_arready(arready),
      .s_axi_rdata(rdata), .s_axi_rresp(rresp), .s_axi_rvalid(rvalid), .s_axi_rready(1'b1),
      .psen(psen), .psincdec(psincdec), .psdone(psdone), .mmcm_locked(1'b1),
      .pin_b_o(pin_b_o), .pin_b_i(pin_b_i), .pin_c_o(pin_c_o), .pin_c_i(pin_c_i),
      .class_o(class_o), .heartbeat(heartbeat));

  task automatic axi_write(input logic [20:0] a, input logic [31:0] d);
    logic aw_hs, w_hs;
    @(negedge clk_axi);
    awaddr = a; wdata = d; awvalid = 1'b1; wvalid = 1'b1;
    do begin
      aw_hs = awvalid && awready;
      w_hs  = wvalid && wready;
      @(negedge clk_axi);
      if (aw_hs) awvalid = 1'b0;
      if (w_hs) wvalid = 1'b0;
    end while (awvalid || wvalid);
    while (!bvalid) @(negedge clk_axi);
    if (bresp != 2'b00) $fatal(1, "BRESP %0d at %h", bresp, a);
    @(negedge clk_axi);
  endtask

  task automatic axi_read(input logic [20:0] a, output logic [31:0] d);
    logic hs;
    @(negedge clk_axi);
    araddr = a; arvalid = 1'b1;
    do begin
      hs = arready;
      @(negedge clk_axi);
    end while (!hs);
    arvalid = 1'b0;
    while (!rvalid) @(negedge clk_axi);
    if (rresp != 2'b00) $fatal(1, "RRESP %0d at %h", rresp, a);
    d = rdata;
    @(negedge clk_axi);
  endtask

  task automatic expect_reg(input logic [20:0] a, input logic [31:0] exp, input string what);
    logic [31:0] d;
    axi_read(a, d);
    if (d !== exp) $fatal(1, "%s: read %h expected %h", what, d, exp);
  endtask

  // ---------------- golden data ----------------
  logic [149:0] in_mem [NVEC];
  logic [79:0]  out_mem[NVEC];
  logic [3:0]   arg_mem[NVEC];
  int unsigned  perm   [NVEC];
  int unsigned  rng;
  function automatic int unsigned xs32();
    rng ^= rng << 13;
    rng ^= rng >> 17;
    rng ^= rng << 5;
    return rng;
  endfunction

  string in_file, out_file, arg_file, mode;
  int unsigned seed, j, tmp;
  int nvec, n_mis, n_cls_mis, n_chk, stream_k, n_trials, trial_stride, n_pos;

  task automatic stream_pass();
    logic [31:0] d, cyc, st;
    int base, n, prev_seq;
    logic [79:0] got;
    logic [2:0] cls;
    n_mis = 0; n_cls_mis = 0; n_chk = 0; stream_k = -1;
    axi_write(A_CTRL, 32'd0);
    axi_read(A_STATUS, st);
    prev_seq = int'(st[23:16]);
    for (base = 0; base < nvec; base += DEPTH) begin
      n = (nvec - base < DEPTH) ? nvec - base : DEPTH;
      for (int i = 0; i < n; i++)
        for (int w = 0; w < 5; w++)
          axi_write(A_VEC + 21'(32 * i + 4 * w), 32'(in_mem[perm[base+i]] >> (32 * w)));
      // read back two vectors through port A
      for (int i = 0; i < n; i += (n > 1 ? n - 1 : 1))
        for (int w = 0; w < 5; w++) begin
          axi_read(A_VEC + 21'(32 * i + 4 * w), d);
          if (d !== 32'(in_mem[perm[base+i]] >> (32 * w))) $fatal(1, "vector readback %0d word %0d: %h", i, w, d);
        end
      axi_write(A_STREAM_N, 32'(n));
      axi_write(A_STREAM_GO, 32'd1);
      do axi_read(A_STATUS, st); while (st[0] || int'(st[23:16]) != ((prev_seq + 1) & 255));
      prev_seq = int'(st[23:16]);
      axi_read(A_STREAM_CYC, cyc);
      if (stream_k < 0) stream_k = int'(cyc) - (n - 1);
      else if (int'(cyc) != n - 1 + stream_k) $fatal(1, "STREAM_CYC %0d for n=%0d, expected %0d", cyc, n, n - 1 + stream_k);
      for (int i = 0; i < n; i++) begin
        axi_read(A_RES + 21'(16 * i), d); got[31:0] = d;
        axi_read(A_RES + 21'(16 * i + 4), d); got[63:32] = d;
        axi_read(A_RES + 21'(16 * i + 8), d); got[79:64] = d[15:0]; cls = d[18:16];
        n_chk++;
        if (got !== out_mem[perm[base+i]]) begin
          n_mis++;
          if (n_mis <= 10) $display("MISMATCH vec=%0d got=%h exp=%h", perm[base+i], got, out_mem[perm[base+i]]);
        end
        if (4'(cls) !== arg_mem[perm[base+i]]) begin
          n_cls_mis++;
          if (n_cls_mis <= 10) $display("CLASS_MISMATCH vec=%0d got=%0d exp=%0d", perm[base+i], cls, arg_mem[perm[base+i]]);
        end
      end
      $display("CHUNK base=%0d n=%0d stream_cyc=%0d mismatches_so_far=%0d", base, n, cyc, n_mis + n_cls_mis);
    end
    $display("RESULT stream seed=%0d vectors=%0d checked=%0d logit_mismatches=%0d class_mismatches=%0d stream_cyc_offset=%0d",
             seed, nvec, n_chk, n_mis, n_cls_mis, stream_k);
    if (n_mis != 0 || n_cls_mis != 0 || n_chk != nvec) $fatal(1, "FAIL stream");
  endtask

  task automatic timed_pass();
    logic [31:0] d, st, kh, kb, kc, pg, pd, cls, l0, l1, l2, pos;
    logic [79:0] got;
    int v, n_bad, t_idx;
    axi_write(A_CTRL, 32'd1);
    // vectors 0..DEPTH-1 of the current permutation must be in vec_mem
    n_bad = 0; t_idx = 0;
    for (int p = 0; p < n_pos; p++) begin
      axi_read(A_PS_POS, pos);
      if (int'(pos) != p * trial_stride) $fatal(1, "PS_POS %0d expected %0d", pos, p * trial_stride);
      for (int t = 0; t < n_trials; t++) begin
        v = (t_idx * 7919) % ((nvec < DEPTH) ? nvec : DEPTH);
        t_idx++;
        axi_write(A_T_VEC, 32'(v));
        axi_write(A_STAGE_GO, 32'd1);
        do axi_read(A_STATUS, st); while (st[1]);
        axi_write(A_ARM, 32'd1);
        do axi_read(A_STATUS, st); while (st[12:8] != 5'b11111);
        axi_read(A_K_H, kh); axi_read(A_K_B, kb); axi_read(A_K_C, kc);
        axi_read(A_P_G, pg); axi_read(A_P_D, pd); axi_read(A_T_CLASS, cls);
        axi_read(A_T_LOGIT, l0); axi_read(A_T_LOGIT + 4, l1); axi_read(A_T_LOGIT + 8, l2);
        got = {l2[15:0], l1, l0};
        if (kc - kb != N_CORE) $fatal(1, "N_core %0d expected %0d (pos %0d)", kc - kb, N_CORE, pos);
        if (got !== out_mem[perm[v]] || 4'(cls[2:0]) !== arg_mem[perm[v]]) begin
          n_bad++;
          $display("TRIAL_MISMATCH vec=%0d cls=%0d exp=%0d", perm[v], cls, arg_mem[perm[v]]);
        end
        if (class_o !== cls[2:0]) $fatal(1, "class pins %0d != T_CLASS %0d", class_o, cls);
        $display("TRIAL pos=%0d vec=%0d kh=%0d kb=%0d kc=%0d pg=%0d pd=%0d cls=%0d ok=%0d phi_ns=%.6f lpp_ns=%.6f",
                 pos, perm[v], kh, kb, kc, pg, pd, cls, got === out_mem[perm[v]], phi_meas, t_c_rise - t_b_rise);
        axi_write(A_ARM, 32'd0);
        repeat (N_CORE + 16) @(negedge clk_net);
        if (pin_c_o !== 1'b0) $fatal(1, "DEC_VALID still high after disarm");
      end
      axi_write(A_PS_CMD, 32'(trial_stride));
      do axi_read(A_STATUS, st); while (st[2]);
    end
    $display("RESULT timed trials=%0d positions=%0d stride=%0d mismatches=%0d n_core=%0d T_NS=%f PS_STEPS=%0d D_B=%f D_C=%f PHI0=%f",
             t_idx, n_pos, trial_stride, n_bad, N_CORE, T_NS, PS_STEPS, D_B, D_C, PHI0);
    if (n_bad != 0) $fatal(1, "FAIL timed");
  endtask

  initial begin
    logic [31:0] d;
    if (!$value$plusargs("IN=%s", in_file))   $fatal(1, "missing +IN=");
    if (!$value$plusargs("OUT=%s", out_file)) $fatal(1, "missing +OUT=");
    if (!$value$plusargs("ARG=%s", arg_file)) $fatal(1, "missing +ARG=");
    if (!$value$plusargs("SEED=%d", seed))    seed = 0;
    if (!$value$plusargs("MODE=%s", mode))    mode = "both";
    if (!$value$plusargs("NVEC=%d", nvec))    nvec = NVEC;
    if (!$value$plusargs("TRIALS=%d", n_trials)) n_trials = 2;
    if (!$value$plusargs("STRIDE=%d", trial_stride)) trial_stride = 1;
    if (!$value$plusargs("NPOS=%d", n_pos))   n_pos = PS_STEPS / trial_stride + 8;
    $readmemh(in_file, in_mem);
    $readmemh(out_file, out_mem);
    $readmemh(arg_file, arg_mem);
    for (int i = 0; i < NVEC; i++) perm[i] = i;
    if (seed != 0) begin
      rng = seed;
      for (int i = NVEC - 1; i > 0; i--) begin
        j = xs32() % (i + 1);
        tmp = perm[i]; perm[i] = perm[j]; perm[j] = tmp;
      end
    end
    wait (aresetn);
    repeat (4) @(negedge clk_axi);

    expect_reg(A_ID, 32'h4A53_4331, "ID");
    expect_reg(A_PARAMS, {8'd3, 8'(N_CORE), 4'(DEPTH_LOG2), 4'(ARG_LAT), 8'(LAT_NET)}, "PARAMS");
    expect_reg(A_CFG, {12'(PS_STEPS), 4'(AXI_DIV), 16'd300}, "CFG");
    axi_write(A_SCRATCH, 32'hA5C3_0F96);
    expect_reg(A_SCRATCH, 32'hA5C3_0F96, "SCRATCH");
    expect_reg(21'h0FFC, 32'hDEAD_C0DE, "unmapped CSR");
    expect_reg(21'h180000, 32'hDEAD_C0DE, "unmapped window");
    axi_write(21'h0FFC, 32'h1234_5678);  // dropped, must still complete
    expect_reg(A_VEC + 21'd20, 32'd0, "VEC word 5");
    $display("REGS ok");

    if (mode == "stream" || mode == "both") stream_pass();
    if (mode == "timed" || mode == "both") begin
      // vec_mem index i must hold perm position i (the stream pass left its last chunk there)
      for (int i = 0; i < ((nvec < DEPTH) ? nvec : DEPTH); i++)
        for (int w = 0; w < 5; w++)
          axi_write(A_VEC + 21'(32 * i + 4 * w), 32'(in_mem[perm[i]] >> (32 * w)));
      timed_pass();
    end
    $display("PASS");
    $finish;
  end
endmodule
