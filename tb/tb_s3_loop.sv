// tb_s3_loop: Stage 3 decoder loop, board-independent part: s3_side_a (player/checker) <-> two
// behavioural Aurora 64B/66B streaming links <-> s3_side_b (qec_d3_top decoder), all driven through
// s3_regs over AXI4-Lite. Three clocks: clk_a, clk_b plesiochronous (+TA_NS / +TB_NS, defaults
// 6.206 / 6.207 ns), aclk 10 ns.
//
// Link model (tb_s3_link, one per direction): a beat accepted at a source edge (tvalid & tready, both
// seen at the preceding negedge) arrives LINK_CYC source periods later and is presented at the first
// destination negedge at or after arrival, i.e. captured at the following destination posedge; one
// beat per destination cycle (queue). TX clock compensation: source tready low one cycle in CC_PERIOD.
//
// Expected loop latency (clk_a cycles, side A: TX accept edge -> RX register edge), D = DEC_LAT for
// decode and 0 for echo; r = TB/TA ~ 1:
//   L (A->B)  + j1 (B capture: first B negedge at or after arrival, then the posedge, [0.5, 1.5) TB)
//   + (D + 1) (B: RX register -> FIFO write) + 1 (FIFO write -> B TX accept edge)
//   + L*r (B->A) + j2 (A capture, [0.5, 1.5) TA).
//   With TA = TB the two capture phases are complementary (j1 + j2 = 2 exactly), so the loop is
//   C = 2L + D + 4; the ppm drift moves the capture phases (+1) and a tready drop on the B TX can
//   hit the word (+1); both together give C + 2 (seen: 4 of 464,428 at GAP = 7). Bounds: [C - 1, C + 2];
//   GAP = 0 adds queueing in the links and the B FIFO: [C - 1, C + 4]. decode - echo = DEC_LAT (min, max within +-1; mean within 0.5).
// GAP = 0 is sustainable only if clk_a is not faster than clk_b: both TX sides lose 1/CC_PERIOD to
// clock compensation, so with TA < TB the B TX FIFO backlog grows by ~NVEC*(TB/TA - 1) words. When
// that exceeds 2x the FIFO depth the TB requires B fifo_ovf > 0, A timeout, and consistent counts
// (negative check of the overflow path); in between it accepts either outcome, and without overflow
// widens the upper latency bound by the backlog (+2): those words queue in the B FIFO (seen at
// NVEC = 65536, d = 5: backlog 10.6 words, max latency C + 9).
//
// Width: N_DET detection bits per shot, DW-bit link words (s3_pkg): 24 / 64 (Stage 3, d = 3, qec_d3_top)
// or 120 / 192 (d = 5, qec_d5_top: the real core, or the tb/qec_d5_standin.sv test core).
// Cases: decode GAP 0, decode GAP 7, echo GAP 7, echo GAP 0, decode GAP 1 with the returned flip of
// one seq (+CORRUPT=<seq>, default NVEC/2+17) inverted in the B->A link: exactly 1 mismatch at that seq.
// Drive and sample at NEGEDGE only. Any unexpected result -> $fatal(1).
`timescale 1ns / 1fs

module tb_s3_link #(
    parameter int DW        = 64,
    parameter int LINK_CYC  = 40,
    parameter int CC_PERIOD = 1000,
    parameter int CC_PHASE  = 0
) (
    input  logic        s_clk,
    input  logic [DW-1:0] s_tdata,
    input  logic        s_tvalid,
    output logic        s_tready,
    input  logic        d_clk,
    output logic [DW-1:0] d_tdata,
    output logic        d_tvalid
);
  real         s_period = 1.0;  // set by the TB at time 0
  int          corrupt_seq = -1;
  logic [31:0] sig;              // MISR over delivered 5A words (same rule as side A)
  int unsigned n_in, n_out, q_max;
  logic [DW-1:0] qd[$];
  realtime     qt[$];
  int unsigned cyc = 0;
  logic [DW-1:0] w;

  initial begin s_tready = 1'b1; d_tvalid = 1'b0; d_tdata = '0; end

  always @(negedge s_clk) begin
    cyc++;
    s_tready = !(CC_PERIOD > 0 && (cyc % CC_PERIOD) == CC_PHASE);
    if (s_tvalid && s_tready) begin  // transfers at the next s_clk posedge
      qd.push_back(s_tdata);
      qt.push_back($realtime + s_period / 2.0 + LINK_CYC * s_period);
      n_in++;
      if (qd.size() > q_max) q_max = qd.size();
    end
  end

  always @(negedge d_clk) begin
    d_tvalid = 1'b0;
    if (qd.size() > 0 && qt[0] <= $realtime) begin
      w = qd.pop_front();
      void'(qt.pop_front());
      if (corrupt_seq >= 0 && w[DW-1:DW-8] == 8'h5A && w[DW-9:DW-32] == 24'(corrupt_seq)) w[0] = ~w[0];
      if (w[DW-1:DW-8] == 8'h5A) sig = {sig[30:0], 1'b0} ^ (sig[31] ? 32'h04C11DB7 : 32'h0) ^ {7'b0, w[DW-9:DW-32], w[0]};
      d_tdata  = w;
      d_tvalid = 1'b1;
      n_out++;
    end
  end
endmodule

module tb_s3_loop
  import s3_pkg::*;
#(
    parameter int NVEC         = 4096,
    parameter int N_DET        = 24,
    parameter int DW           = 64,
    parameter int DEC_LAT      = 8,
    parameter int OUT_W        = 18,
    parameter int LOGIT_SIGNED = 1,
    parameter int LINK_CYC     = 40,
    parameter int CC_PERIOD    = 1000,
    parameter int TIMEOUT      = 100000,
    parameter     INIT_FILE    = "s3_shots.hex"
);
  real ta_ns = 6.206, tb_ns = 6.207;
  logic clk_a = 1'b0, clk_b = 1'b0, aclk = 1'b0;
  initial begin
    void'($value$plusargs("TA_NS=%f", ta_ns));
    void'($value$plusargs("TB_NS=%f", tb_ns));
    u_ab.s_period = ta_ns;
    u_ba.s_period = tb_ns;
  end
  initial begin #0.001; forever #(ta_ns / 2.0) clk_a = ~clk_a; end
  initial begin #0.002; forever #(tb_ns / 2.0) clk_b = ~clk_b; end
  always #5.0 aclk = ~aclk;

  // ---------------- DUT ----------------
  logic        rst_a = 1'b1, rst_b = 1'b1, aresetn = 1'b0;
  logic        a_run, a_mode, a_srst, b_srst, a_rd_req, a_rd_sel, a_rd_ack, a_done, a_busy;
  logic [15:0] a_gap, a_hbase;
  logic [23:0] a_rd_addr;
  logic [31:0] a_rd_data;
  s3_a_stat_t  a_stat;
  s3_b_stat_t  b_stat;
  logic [DW-1:0] ab_s_d, ab_d_d, ba_s_d, ba_d_d;
  logic        ab_s_v, ab_s_r, ab_d_v, ba_s_v, ba_s_r, ba_d_v;

  logic [11:0] awaddr = '0, araddr = '0;
  logic [31:0] wdata = '0, rdata;
  logic        awvalid = 1'b0, wvalid = 1'b0, arvalid = 1'b0;
  logic        awready, wready, bvalid, arready, rvalid;
  logic [1:0]  bresp, rresp;

  s3_side_a #(.NVEC(NVEC), .INIT_FILE(INIT_FILE), .TIMEOUT(TIMEOUT), .N_DET(N_DET), .DW(DW)) u_a (
      .clk(clk_a), .rst(rst_a | a_srst), .run(a_run), .mode_echo(a_mode), .gap(a_gap), .hist_base(a_hbase),
      .tx_tdata(ab_s_d), .tx_tvalid(ab_s_v), .tx_tready(ab_s_r), .rx_tdata(ba_d_d), .rx_tvalid(ba_d_v),
      .rd_req(a_rd_req), .rd_sel(a_rd_sel), .rd_addr(a_rd_addr), .rd_data(a_rd_data), .rd_ack(a_rd_ack),
      .done(a_done), .busy(a_busy), .stat(a_stat));

  s3_side_b #(.N_DET(N_DET), .DW(DW), .IN_W(N_DET), .OUT_W(OUT_W), .LOGIT_SIGNED(LOGIT_SIGNED), .DEC_LAT(DEC_LAT)) u_b (
      .clk(clk_b), .rst(rst_b | b_srst), .rx_tdata(ab_d_d), .rx_tvalid(ab_d_v),
      .tx_tdata(ba_s_d), .tx_tvalid(ba_s_v), .tx_tready(ba_s_r), .stat(b_stat));

  tb_s3_link #(.DW(DW), .LINK_CYC(LINK_CYC), .CC_PERIOD(CC_PERIOD), .CC_PHASE(0)) u_ab (
      .s_clk(clk_a), .s_tdata(ab_s_d), .s_tvalid(ab_s_v), .s_tready(ab_s_r),
      .d_clk(clk_b), .d_tdata(ab_d_d), .d_tvalid(ab_d_v));
  tb_s3_link #(.DW(DW), .LINK_CYC(LINK_CYC), .CC_PERIOD(CC_PERIOD), .CC_PHASE(CC_PERIOD / 2 + 17)) u_ba (
      .s_clk(clk_b), .s_tdata(ba_s_d), .s_tvalid(ba_s_v), .s_tready(ba_s_r),
      .d_clk(clk_a), .d_tdata(ba_d_d), .d_tvalid(ba_d_v));

  s3_regs #(.NVEC(NVEC), .DEC_LAT(DEC_LAT), .TIMEOUT(TIMEOUT), .N_DET(N_DET), .DW(DW)) u_regs (
      .aclk(aclk), .aresetn(aresetn),
      .s_axi_awaddr(awaddr), .s_axi_awvalid(awvalid), .s_axi_awready(awready),
      .s_axi_wdata(wdata), .s_axi_wstrb(4'hF), .s_axi_wvalid(wvalid), .s_axi_wready(wready),
      .s_axi_bresp(bresp), .s_axi_bvalid(bvalid), .s_axi_bready(1'b1),
      .s_axi_araddr(araddr), .s_axi_arvalid(arvalid), .s_axi_arready(arready),
      .s_axi_rdata(rdata), .s_axi_rresp(rresp), .s_axi_rvalid(rvalid), .s_axi_rready(1'b1),
      .clk_a(clk_a), .a_run(a_run), .a_mode_echo(a_mode), .a_soft_rst(a_srst), .a_gap(a_gap),
      .a_hist_base(a_hbase), .a_rd_req(a_rd_req), .a_rd_sel(a_rd_sel), .a_rd_addr(a_rd_addr),
      .a_rd_data(a_rd_data), .a_rd_ack(a_rd_ack), .a_done(a_done), .a_stat(a_stat),
      .clk_b(clk_b), .b_soft_rst(b_srst), .b_stat(b_stat),
      .board_ctrl(), .link_stat(32'h0100_0000), .freq_a(32'd27033600), .freq_b(32'd27033600));

  // ---------------- AXI4-Lite master (negedge drive / sample) ----------------
  task automatic axi_wr(input logic [11:0] a, input logic [31:0] d);
    awaddr = a; wdata = d; awvalid = 1'b1; wvalid = 1'b1;
    do @(negedge aclk); while (!awready);  // handshake at the next posedge
    @(negedge aclk);
    awvalid = 1'b0; wvalid = 1'b0;
    while (!bvalid) @(negedge aclk);       // bready = 1: response taken at the next posedge
    @(negedge aclk);
  endtask

  task automatic axi_rd(input logic [11:0] a, output logic [31:0] d);
    araddr = a; arvalid = 1'b1;
    do @(negedge aclk); while (!arready);
    @(negedge aclk);
    arvalid = 1'b0;
    while (!rvalid) @(negedge aclk);
    d = rdata;
    @(negedge aclk);
  endtask

  task automatic ram_rd(input bit sel, input int addr, output logic [31:0] d);
    logic [31:0] s;
    axi_wr(12'h014, {sel, 7'b0, 24'(addr)});
    do axi_rd(12'h014, s); while (s[30]);
    axi_rd(12'h018, d);
  endtask

  // ---------------- golden ----------------
  logic [N_DET:0] gold[NVEC];
  int unsigned rng = 32'h1234_5678;
  function automatic int unsigned xs32();
    rng ^= rng << 13;
    rng ^= rng >> 17;
    rng ^= rng << 5;
    return rng;
  endfunction

  int dec7_min, dec7_max, echo7_min, echo7_max, n_fail;
  real dec7_mean, echo7_mean;
  int corrupt;

  task automatic chk(input bit ok, input string what);
    if (!ok) begin
      n_fail++;
      $display("CHECK FAILED: %s", what);
    end
  endtask

  task automatic run_case(input string name, input bit echo, input int gap, input int cor);
    logic [31:0] v[48], h, s, sig_exp;
    int lo, hi, d, n_hist, n_axi, bad, seen_bad, f_exp, tmo, ovf_mode;  // ovf_mode 0 clean, 1 overflow, 2 either
    real backlog, mean;
    longint lsum;
    d  = echo ? 0 : DEC_LAT;
    lo = 2 * LINK_CYC + d + 3;
    hi = 2 * LINK_CYC + d + 6 + ((gap == 0) ? 2 : 0);  // lo = C - 1, hi = C + 2 (+2 at GAP = 0)
    backlog = (gap == 0 && ta_ns < tb_ns) ? NVEC * (tb_ns / ta_ns - 1.0) : 0.0;
    ovf_mode = (backlog > 32.0) ? 1 : (backlog > 4.0) ? 2 : 0;
    // in between (no overflow), the backlog queues in the B FIFO: up to ceil(backlog) + 2 more cycles
    if (ovf_mode == 2) hi += int'($ceil(backlog)) + 2;
    u_ba.corrupt_seq = cor;
    u_ba.sig = 32'hFFFF_FFFF;
    // soft reset of side B (clears its stats and FIFO), then configure and run
    axi_wr(12'h004, 32'h20);
    repeat (8) @(negedge aclk);
    axi_wr(12'h004, 32'h00);
    repeat (8) @(negedge aclk);
    axi_wr(12'h008, 32'(gap));
    axi_wr(12'h00C, 32'(lo - 8));
    axi_wr(12'h004, {30'b0, echo, 1'b0});
    axi_wr(12'h004, {30'b0, echo, 1'b1});
    tmo = 0;
    do begin
      repeat (1000) @(negedge aclk);
      axi_rd(12'h010, s);
      tmo++;
      if (tmo > (NVEC * (gap + 2) * 2 + TIMEOUT) / 1000 + 1000) $fatal(1, "%s: done never came", name);
    end while (!s[0]);
    for (int i = 0; i < 48; i++) axi_rd(12'(12'h040 + 4 * i), v[i]);
    // v[i] = register at byte offset 0x040 + 4i (side A from v[0], side B from v[32] = 0x0C0)
    lsum = {v[6][15:0], v[5]};
    mean = (v[2] != 0) ? real'(lsum) / real'(v[2]) : 0.0;

    // ---- histogram via AXI (all 256 bins) vs the RAM ----
    n_hist = 0; bad = 0;
    for (int i = 0; i < 256; i++) begin
      ram_rd(1'b0, i, h);
      if (h != u_a.hist[i]) bad++;
      n_hist += int'(h);
      if (h != 0) $display("HIST %s lat=%0d n=%0d", name, lo - 8 + i, h);
    end
    chk(bad == 0, $sformatf("%s: %0d histogram bins differ AXI vs RAM", name, bad));
    chk(n_hist + int'(v[14]) + int'(v[15]) == int'(v[2]), $sformatf("%s: histogram sum %0d + %0d + %0d != good %0d", name, n_hist, v[14], v[15], v[2]));

    // ---- expected signature over seq order ----
    sig_exp = 32'hFFFF_FFFF;
    for (int i = 0; i < NVEC; i++) begin
      f_exp = echo ? 0 : int'(gold[i][N_DET]);
      if (i == cor) f_exp ^= 1;
      sig_exp = s3_misr(sig_exp, 24'(i), f_exp[0]);
    end

    $display("RESULT case=%s mode=%s gap=%0d nvec=%0d sent=%0d rx=%0d good=%0d mism=%0d first_mis=%0d/%0d err_tag=%0d err_range=%0d err_ovr=%0d err_dup=%0d err_echo=%0d hist_under=%0d hist_over=%0d lat_min=%0d lat_max=%0d lat_mean=%.4f expect=[%0d,%0d] b_rx=%0d b_tx=%0d b_dec=%0d..%0d/%0d b_echo=%0d..%0d/%0d b_fifo_max=%0d b_ovf=%0d b_collide=%0d timeout=%0d sig=%h sig_link=%h sig_exp=%h",
             name, echo ? "echo" : "decode", gap, NVEC, v[0], v[1], v[2], v[7], v[8][31], v[8][23:0], v[9], v[10], v[11], v[12], v[13], v[14], v[15],
             v[3], v[4], mean, lo, hi, v[32], v[33], v[38][15:0], v[38][31:16], v[39], v[40][15:0], v[40][31:16], v[41], v[37], v[35], v[36],
             s[1], v[16], u_ba.sig, sig_exp);

    // ---- checks common to every case ----
    chk(v[0] == NVEC, "sent != NVEC");
    chk(v[9] == 0 && v[10] == 0 && v[11] == 0 && v[12] == 0 && v[13] == 0, "protocol errors");
    chk(v[34] == 0 && v[36] == 0, "side B tag errors / collisions");
    chk(v[16] == u_ba.sig, "signature differs from the link-side MISR");
    chk(v[32] == NVEC, "side B rx != NVEC");
    if (echo) begin
      chk(v[41] == NVEC && v[39] == 0 && v[40][15:0] == 1 && v[40][31:16] == 1, "B echo path count / constant 1 cycle");
    end else begin
      chk(v[39] == NVEC && v[41] == 0 && v[38][15:0] == 16'(DEC_LAT + 1) && v[38][31:16] == 16'(DEC_LAT + 1),
          $sformatf("B decode path count / constant %0d cycles", DEC_LAT + 1));
    end
    if (ovf_mode == 1 || (ovf_mode == 2 && v[35] != 0)) begin
      $display("NOTE %s: GAP=0 with clk_a faster than clk_b, expected B FIFO backlog %.1f words: overflow path checked", name, backlog);
      chk(v[35] > 0 && s[1] == 1'b1, "expected B FIFO overflow and side A timeout");
      chk(v[33] == NVEC - v[35] && v[2] == v[33] && v[7] == 0, "overflow counts inconsistent (tx = NVEC - ovf = good, no mismatches)");
    end else begin
      chk(s[1] == 1'b0 && v[35] == 0 && v[2] == NVEC && v[1] == NVEC && v[33] == NVEC, "loop incomplete");
      chk(v[16] == sig_exp, "signature differs from the golden-order MISR");
      chk(v[14] == 0 && v[15] == 0, "latency outside the histogram window");
      chk(int'(v[3]) >= lo && int'(v[4]) <= hi, $sformatf("latency %0d..%0d outside expected [%0d,%0d]", v[3], v[4], lo, hi));
      if (cor >= 0) begin
        chk(v[7] == 1 && v[8][31] && int'(v[8][23:0]) == cor, $sformatf("corruption of seq %0d: want exactly 1 mismatch at it", cor));
      end else begin
        chk(v[7] == 0 && !v[8][31], "decision mismatches");
      end
      // ---- flag RAM: full hierarchical compare + random AXI reads ----
      bad = 0; seen_bad = 0;
      for (int i = 0; i < NVEC; i++) begin
        f_exp = echo ? 0 : int'(gold[i][N_DET]);
        if (i == cor) f_exp ^= 1;
        if (u_a.flag_mem[i][0] != f_exp[0]) bad++;
        if (!u_a.flag_mem[i][1]) seen_bad++;
      end
      chk(bad == 0 && seen_bad == 0, $sformatf("flag RAM: %0d flips differ, %0d not seen", bad, seen_bad));
      n_axi = (NVEC < 3000) ? NVEC : 3000;
      bad = 0;
      for (int k = 0; k < n_axi; k++) begin
        int i;
        i = (k < 4) ? ((k == 0) ? 0 : (k == 1) ? NVEC - 1 : (k == 2 && cor >= 0) ? cor : NVEC / 2) : int'(xs32() % NVEC);
        ram_rd(1'b1, i, h);
        f_exp = echo ? 0 : int'(gold[i][N_DET]);
        if (i == cor) f_exp ^= 1;
        if (h != {30'b0, 1'b1, f_exp[0]}) bad++;
      end
      chk(bad == 0, $sformatf("flag RAM via AXI: %0d of %0d reads wrong", bad, n_axi));
      $display("FLAGS %s hierarchical=%0d/%0d axi_reads=%0d ok", name, NVEC, NVEC, n_axi);
    end
    if (gap == 7 && cor < 0) begin
      if (echo) begin echo7_min = int'(v[3]); echo7_max = int'(v[4]); echo7_mean = mean; end
      else begin dec7_min = int'(v[3]); dec7_max = int'(v[4]); dec7_mean = mean; end
    end
    $display("LINKQ %s a->b q_max=%0d b->a q_max=%0d", name, u_ab.q_max, u_ba.q_max);
    u_ab.q_max = 0; u_ba.q_max = 0;
    if (n_fail != 0) $fatal(1, "FAIL in case %s (%0d checks)", name, n_fail);
    // drop run, wait for side A idle (done falls)
    axi_wr(12'h004, {30'b0, echo, 1'b0});
    do axi_rd(12'h010, s); while (s[0]);
  endtask

  logic [31:0] id, p0, p1, p2, p3;
  initial begin
    n_fail = 0;
    if (!$value$plusargs("CORRUPT=%d", corrupt)) corrupt = NVEC / 2 + 17;
    if (corrupt < 0 || corrupt >= NVEC) $fatal(1, "+CORRUPT out of range");
    $readmemh(INIT_FILE, gold);
    repeat (20) @(negedge aclk);
    rst_a = 1'b0; rst_b = 1'b0; aresetn = 1'b1;
    repeat (10) @(negedge aclk);
    axi_rd(12'h000, id);
    axi_rd(12'h0F0, p0);
    axi_rd(12'h0F4, p1);
    $display("CONFIG id=%h NVEC=%0d DEC_LAT=%0d LINK_CYC=%0d CC_PERIOD=%0d TIMEOUT=%0d TA_NS=%.4f TB_NS=%.4f (B/A-1 = %.1f ppm) corrupt_seq=%0d",
             id, p0, p1, LINK_CYC, CC_PERIOD, TIMEOUT, ta_ns, tb_ns, (tb_ns / ta_ns - 1.0) * 1e6, corrupt);
    if (id != 32'h5333_0001 || p0 != NVEC || p1 != DEC_LAT) $fatal(1, "ID / parameter registers wrong");
    $display("PATHS side B: RX register -> FIFO write = %0d edges (decode), 1 edge (echo); framing = 2 edges (RX register + FIFO entry)", DEC_LAT + 1);

    run_case("dec_gap0", 1'b0, 0, -1);
    run_case("dec_gap7", 1'b0, 7, -1);
    run_case("echo_gap7", 1'b1, 7, -1);
    run_case("echo_gap0", 1'b1, 0, -1);
    run_case("corrupt_gap1", 1'b0, 1, corrupt);
    // N_DET / DW registers read after the cases: reading them first would shift every case's start
    // against the plesiochronous clock phases and so the Stage 3 histograms (kept bit-identical)
    axi_rd(12'h0FC, p2);
    axi_rd(12'h100, p3);
    $display("CONFIG N_DET=%0d DW=%0d", p2, p3);
    if (p2 != N_DET || p3 != DW) $fatal(1, "N_DET / DW registers wrong");

    chk(dec7_min - echo7_min >= DEC_LAT - 1 && dec7_min - echo7_min <= DEC_LAT + 1, "decode - echo (min) != DEC_LAT +- 1");
    chk(dec7_max - echo7_max >= DEC_LAT - 1 && dec7_max - echo7_max <= DEC_LAT + 1, "decode - echo (max) != DEC_LAT +- 1");
    chk(dec7_mean - echo7_mean >= DEC_LAT - 0.5 && dec7_mean - echo7_mean <= DEC_LAT + 0.5, "decode - echo (mean) != DEC_LAT +- 0.5");
    $display("RESULT s3_loop nvec=%0d dec_lat=%0d link_cyc=%0d ta_ns=%.4f tb_ns=%.4f gap7 decode=%0d..%0d mean %.4f echo=%0d..%0d mean %.4f decode_minus_echo min=%0d max=%0d mean=%.4f fails=%0d",
             NVEC, DEC_LAT, LINK_CYC, ta_ns, tb_ns, dec7_min, dec7_max, dec7_mean, echo7_min, echo7_max, echo7_mean,
             dec7_min - echo7_min, dec7_max - echo7_max, dec7_mean - echo7_mean, n_fail);
    if (n_fail != 0) $fatal(1, "FAIL (%0d checks)", n_fail);
    $display("PASS");
    $finish;
  end
endmodule
