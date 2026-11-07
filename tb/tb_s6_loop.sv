// tb_s6_loop: Stage 6 gate 2, the whole loop: s6_core (the real s3_side_a player / checker, s3_side_b with the
// real decoder or echo, both s6_link ends, the one-way probes, s3_regs, s6_diag) with tb_s6_gtch models for the
// GTY channels and the cable (A TX -> B RX, B TX -> A RX, one model per lane and direction), all on ONE clock
// (T_NS, default 6.206 ns) as on the board; aclk 10 ns. Everything is driven through the AXI4-Lite port.
// Negedge discipline: AXI and model stimulus before negedge + 1.5 ns (where the models act), sampling after.
//
// Sequence (any unexpected result -> $fatal(1)):
//   1. bring-up: RX out of reset first (random bits), then TX; wait for LINK lock A and B (0x024 bits 0, 8).
//   2. probe: both ends send probe words (s6_diag); one-way latency A->B and B->A from the shared counter
//      (min / max / mean / histogram); every word must arrive, n_bad = 0.
//   3. the s3 cases of tb_s3_loop: decode GAP 0, decode GAP 7, echo GAP 7, echo GAP 0, decode GAP 1 with the flip of
//      one returned word (+CORRUPT=<seq>, default NVEC/2+17) inverted on the B -> A wire (MITM model, lane 0):
//      exactly 1 mismatch at that seq. Per case: counts, errors 0, the histogram over AXI = the RAM, the
//      signature = the golden-order MISR and = a MISR of the words side A received (taken here), the flag RAM
//      (hierarchical, all NVEC, and random AXI reads), side B decode path constant DEC_LAT + 1.
//      Loop latency bounds from the probe's one-way numbers (same counter convention, TX accept edge -> RX register
//      edge): [OW_AB_min + OW_BA_min + D + 2, OW_AB_max + OW_BA_max + D + 4] (+4 at GAP 0: queueing), where D =
//      DEC_LAT (decode) or 0 (echo) and D + 2 = side B's RX register -> FIFO write (D + 1) + FIFO write -> B TX accept
//      (1, up to 2 more while TXSEQUENCE = 32). decode - echo (GAP 7): DEC_LAT +- 1 (min, max), +- 0.5 (mean).
//   4. link counters: no lock loss, no bad header, no bad idle, no buffer error during the runs.
`timescale 1ns / 1fs

module tb_s6_loop
  import s3_pkg::*;
  import s6_pkg::*;
#(
    parameter int NVEC         = 4096,
    parameter int N_DET        = 24,
    parameter int DW           = 64,
    parameter int DEC_LAT      = 8,
    parameter int OUT_W        = 18,
    parameter int LOGIT_SIGNED = 1,
    parameter int TIMEOUT      = 100000,
    parameter int TX_REG       = 0,
    parameter int RX_REG       = 0,
    parameter     INIT_FILE    = "s3_shots.hex",
    localparam int NL          = DW / 64
);
  real t_ns = 6.206;
  logic clk = 1'b0, aclk = 1'b0;
  initial void'($value$plusargs("T_NS=%f", t_ns));
  initial begin #0.001; forever #(t_ns / 2.0) clk = ~clk; end
  always #5.0 aclk = ~aclk;

  // ---------------- DUT ----------------
  logic rst_clk = 1'b1, rst_tx = 1'b1, rst_rx = 1'b1, aresetn = 1'b0;
  logic [DW-1:0]   a_txd, a_rxd, b_txd, b_rxd;
  logic [2*NL-1:0] a_txh, a_rxh, b_txh, b_rxh;
  logic [6:0]      a_txs, b_txs;
  logic [NL-1:0]   a_hv, a_dv, b_hv, b_dv, a_slip, b_slip, a_brst, b_brst;
  logic [1:0]      lock_ab;
  logic [31:0]     board_ctrl;

  logic [12:0] awaddr = '0, araddr = '0;
  logic [31:0] wdata = '0, rdata;
  logic        awvalid = 1'b0, wvalid = 1'b0, arvalid = 1'b0;
  logic        awready, wready, bvalid, arready, rvalid;
  logic [1:0]  bresp, rresp;

  s6_core #(.NVEC(NVEC), .INIT_FILE(INIT_FILE), .DEC_LAT(DEC_LAT), .N_DET(N_DET), .DW(DW), .OUT_W(OUT_W),
            .LOGIT_SIGNED(LOGIT_SIGNED), .TIMEOUT(TIMEOUT), .TX_REG(TX_REG), .RX_REG(RX_REG)) u_dut (
      .clk(clk), .rst_clk(rst_clk), .rst_tx(rst_tx), .rst_rx(rst_rx),
      .a_txdata(a_txd), .a_txheader(a_txh), .a_txseq(a_txs), .a_rxdata(a_rxd), .a_rxheader(a_rxh), .a_rxhv(a_hv),
      .a_rxdv(a_dv), .a_rxslip(a_slip), .a_rxbufstatus('0), .a_txbufstatus('0), .a_rxbufreset(a_brst),
      .b_txdata(b_txd), .b_txheader(b_txh), .b_txseq(b_txs), .b_rxdata(b_rxd), .b_rxheader(b_rxh), .b_rxhv(b_hv),
      .b_rxdv(b_dv), .b_rxslip(b_slip), .b_rxbufstatus('0), .b_txbufstatus('0), .b_rxbufreset(b_brst),
      .aclk(aclk), .aresetn(aresetn),
      .s_axi_awaddr(awaddr), .s_axi_awvalid(awvalid), .s_axi_awready(awready),
      .s_axi_wdata(wdata), .s_axi_wstrb(4'hF), .s_axi_wvalid(wvalid), .s_axi_wready(wready),
      .s_axi_bresp(bresp), .s_axi_bvalid(bvalid), .s_axi_bready(1'b1),
      .s_axi_araddr(araddr), .s_axi_arvalid(arvalid), .s_axi_arready(arready),
      .s_axi_rdata(rdata), .s_axi_rresp(rresp), .s_axi_rvalid(rvalid), .s_axi_rready(1'b1),
      .board_stat(32'h0100_7070), .board_ctrl(board_ctrl), .freq_clk(32'd27033600), .lock_ab(lock_ab));

  for (genvar l = 0; l < NL; l++) begin : g_ch
    tb_s6_gtch #(.MITM(l == 0)) u_ab (
        .clk(clk), .tx_en(!rst_tx), .txdata(a_txd[64*l +: 64]), .txheader(a_txh[2*l +: 2]), .txseq(a_txs),
        .rx_en(!rst_rx), .slip(b_slip[l]), .rxdata(b_rxd[64*l +: 64]), .rxheader(b_rxh[2*l +: 2]),
        .rxdv(b_dv[l]), .rxhv(b_hv[l]));
    tb_s6_gtch #(.MITM(l == 0)) u_ba (
        .clk(clk), .tx_en(!rst_tx), .txdata(b_txd[64*l +: 64]), .txheader(b_txh[2*l +: 2]), .txseq(b_txs),
        .rx_en(!rst_rx), .slip(a_slip[l]), .rxdata(a_rxd[64*l +: 64]), .rxheader(a_rxh[2*l +: 2]),
        .rxdv(a_dv[l]), .rxhv(a_hv[l]));
    initial begin
      int lu, sd;
      if (!$value$plusargs("LAT_UI=%d", lu)) lu = 640;
      if (!$value$plusargs("SEED=%d", sd)) sd = 0;
      u_ab.lat_ui = lu + 23 * l;   // a little lane skew at NL = 3 (MODEL)
      u_ba.lat_ui = lu + 9 + 31 * ((2 * l) % 3);
      u_ab.seed = 32'(101 + 10 * l + 1000 * sd);
      u_ba.seed = 32'(102 + 10 * l + 1000 * sd);
    end
  end

  // ---------------- link-side observers (negedge + 2.25 ns) ----------------
  // MISR over the 5A words side A receives (in return order), as tb_s3_link's; and the corruption trigger: when
  // side B's word for seq = corrupt is accepted by link end B at the next posedge, the lane-0 B -> A model inverts
  // the flip bit of the data block it takes TX_REG cycles after that edge.
  logic [31:0] sig_link = 32'hFFFF_FFFF;
  int          corrupt_seq = -1;
  localparam int SQ = DW - 32;
  always @(negedge clk) begin
    #0.75;
    if (corrupt_seq >= 0 && u_dut.lb_s_v && u_dut.lb_s_r && u_dut.lb_s_d[DW-1:DW-8] == TAG_BA &&
        u_dut.lb_s_d[SQ+23:SQ] == 24'(corrupt_seq)) g_ch[0].u_ba.flip_at = g_ch[0].u_ba.cyc + 1 + TX_REG;
  end
  always @(negedge clk) begin
    #2.25;
    if (u_dut.la_m_v && !u_dut.probe_win && u_dut.la_m_d[DW-1:DW-8] == TAG_BA)
      sig_link = {sig_link[30:0], 1'b0} ^ (sig_link[31] ? 32'h04C11DB7 : 32'h0) ^ {7'b0, u_dut.la_m_d[SQ+23:SQ], u_dut.la_m_d[0]};
  end

  // ---------------- AXI4-Lite master (aclk negedge drive / sample) ----------------
  task automatic axi_wr(input logic [12:0] a, input logic [31:0] d);
    awaddr = a; wdata = d; awvalid = 1'b1; wvalid = 1'b1;
    do @(negedge aclk); while (!awready);
    @(negedge aclk);
    awvalid = 1'b0; wvalid = 1'b0;
    while (!bvalid) @(negedge aclk);
    @(negedge aclk);
  endtask

  task automatic axi_rd(input logic [12:0] a, output logic [31:0] d);
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
    axi_wr(13'h014, {sel, 7'b0, 24'(addr)});
    do axi_rd(13'h014, s); while (s[30]);
    axi_rd(13'h018, d);
  endtask

  task automatic diag_snap();
    logic [31:0] s;
    axi_wr(13'h1010, 32'h1);
    do axi_rd(13'h1010, s); while (s[0]);
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
  int ow_ab_min, ow_ab_max, ow_ba_min, ow_ba_max;
  real ow_ab_mean, ow_ba_mean;

  task automatic chk(input bit ok, input string what);
    if (!ok) begin
      n_fail++;
      $display("CHECK FAILED: %s", what);
    end
  endtask

  // ---------------- probe ----------------
  task automatic probe_case(input int period, input int ncyc);
    logic [31:0] w[128];
    int h_ab, h_ba;
    axi_wr(13'h1004, 32'h2);       // clr
    repeat (8) @(negedge aclk);
    axi_wr(13'h1004, 32'h0);
    axi_wr(13'h1008, 32'(period));
    axi_wr(13'h100C, 32'h0);
    axi_wr(13'h1004, 32'h1);       // probe_en
    repeat (int'(ncyc * t_ns / 10.0)) @(negedge aclk);
    axi_wr(13'h1004, 32'h0);
    repeat (400) @(negedge aclk);  // in flight words arrive (probe_win)
    diag_snap();
    for (int k = 0; k < 128; k++) axi_rd(13'(13'h1400 + 4 * k), w[k]);
    // probe at A: n_tx = A->B sent (w32), n_rx = B->A received (w33), latency B->A; probe at B: the reverse
    ow_ba_min = int'(w[35]); ow_ba_max = int'(w[36]); ow_ab_min = int'(w[43]); ow_ab_max = int'(w[44]);
    ow_ba_mean = (w[33] != 0) ? real'({w[38][15:0], w[37]}) / real'(w[33]) : 0.0;
    ow_ab_mean = (w[41] != 0) ? real'({w[46][15:0], w[45]}) / real'(w[41]) : 0.0;
    h_ab = 0; h_ba = 0;
    for (int k = 0; k < 32; k++) begin
      h_ba += int'(w[64 + k]); h_ab += int'(w[96 + k]);
      if (w[64 + k] != 0 || w[96 + k] != 0) $display("PHIST lat=%0d b->a=%0d a->b=%0d", k, w[64 + k], w[96 + k]);
    end
    $display("RESULT case=probe period=%0d a2b_sent=%0d a2b_rx=%0d a2b_bad=%0d a2b_lat=%0d..%0d mean=%.4f b2a_sent=%0d b2a_rx=%0d b2a_bad=%0d b2a_lat=%0d..%0d mean=%.4f",
             period, w[32], w[41], w[42], ow_ab_min, ow_ab_max, ow_ab_mean, w[40], w[33], w[34], ow_ba_min, ow_ba_max, ow_ba_mean);
    chk(w[32] > 100 && w[41] == w[32] && w[40] > 100 && w[33] == w[40], "probe: words lost or added");
    chk(w[34] == 0 && w[42] == 0, "probe: bad words");
    chk(h_ab == int'(w[41]) && h_ba == int'(w[33]), "probe: histogram total != received");
    if (n_fail != 0) $fatal(1, "FAIL in probe (%0d checks)", n_fail);
  endtask

  task automatic run_case(input string name, input bit echo, input int gap, input int cor);
    logic [31:0] v[48], h, s, sig_exp;
    int lo, hi, d, n_hist, n_axi, bad, seen_bad, f_exp, tmo;
    real mean;
    longint lsum;
    d  = echo ? 0 : DEC_LAT;
    lo = ow_ab_min + ow_ba_min + d + 2;
    hi = ow_ab_max + ow_ba_max + d + 4 + ((gap == 0) ? 4 : 0);
    corrupt_seq = cor;
    sig_link = 32'hFFFF_FFFF;
    axi_wr(13'h004, 32'h20);
    repeat (8) @(negedge aclk);
    axi_wr(13'h004, 32'h00);
    repeat (8) @(negedge aclk);
    axi_wr(13'h008, 32'(gap));
    axi_wr(13'h00C, 32'(lo - 8));
    axi_wr(13'h004, {30'b0, echo, 1'b0});
    axi_wr(13'h004, {30'b0, echo, 1'b1});
    tmo = 0;
    do begin
      repeat (1000) @(negedge aclk);
      axi_rd(13'h010, s);
      tmo++;
      if (tmo > (NVEC * (gap + 2) * 2 + TIMEOUT) / 1000 + 1000) $fatal(1, "%s: done never came", name);
    end while (!s[0]);
    for (int i = 0; i < 48; i++) axi_rd(13'(13'h040 + 4 * i), v[i]);
    lsum = {v[6][15:0], v[5]};
    mean = (v[2] != 0) ? real'(lsum) / real'(v[2]) : 0.0;

    n_hist = 0; bad = 0;
    for (int i = 0; i < 256; i++) begin
      ram_rd(1'b0, i, h);
      if (h != u_dut.u_a.hist[i]) bad++;
      n_hist += int'(h);
      if (h != 0) $display("HIST %s lat=%0d n=%0d", name, lo - 8 + i, h);
    end
    chk(bad == 0, $sformatf("%s: %0d histogram bins differ AXI vs RAM", name, bad));
    chk(n_hist + int'(v[14]) + int'(v[15]) == int'(v[2]), $sformatf("%s: histogram sum %0d + %0d + %0d != good %0d", name, n_hist, v[14], v[15], v[2]));

    sig_exp = 32'hFFFF_FFFF;
    for (int i = 0; i < NVEC; i++) begin
      f_exp = echo ? 0 : int'(gold[i][N_DET]);
      if (i == cor) f_exp ^= 1;
      sig_exp = s3_misr(sig_exp, 24'(i), f_exp[0]);
    end

    $display("RESULT case=%s mode=%s gap=%0d nvec=%0d sent=%0d rx=%0d good=%0d mism=%0d first_mis=%0d/%0d err_tag=%0d err_range=%0d err_ovr=%0d err_dup=%0d err_echo=%0d hist_under=%0d hist_over=%0d lat_min=%0d lat_max=%0d lat_mean=%.4f expect=[%0d,%0d] b_rx=%0d b_tx=%0d b_dec=%0d..%0d/%0d b_echo=%0d..%0d/%0d b_fifo_max=%0d b_ovf=%0d b_collide=%0d timeout=%0d sig=%h sig_link=%h sig_exp=%h",
             name, echo ? "echo" : "decode", gap, NVEC, v[0], v[1], v[2], v[7], v[8][31], v[8][23:0], v[9], v[10], v[11], v[12], v[13], v[14], v[15],
             v[3], v[4], mean, lo, hi, v[32], v[33], v[38][15:0], v[38][31:16], v[39], v[40][15:0], v[40][31:16], v[41], v[37], v[35], v[36],
             s[1], v[16], sig_link, sig_exp);

    chk(v[0] == NVEC, "sent != NVEC");
    chk(v[9] == 0 && v[10] == 0 && v[11] == 0 && v[12] == 0 && v[13] == 0, "protocol errors");
    chk(v[34] == 0 && v[36] == 0, "side B tag errors / collisions");
    chk(v[16] == sig_link, "signature differs from the link-side MISR");
    chk(v[32] == NVEC, "side B rx != NVEC");
    if (echo) begin
      chk(v[41] == NVEC && v[39] == 0 && v[40][15:0] == 1 && v[40][31:16] == 1, "B echo path count / constant 1 cycle");
    end else begin
      chk(v[39] == NVEC && v[41] == 0 && v[38][15:0] == 16'(DEC_LAT + 1) && v[38][31:16] == 16'(DEC_LAT + 1),
          $sformatf("B decode path count / constant %0d cycles", DEC_LAT + 1));
    end
    chk(s[1] == 1'b0 && v[35] == 0 && v[2] == NVEC && v[1] == NVEC && v[33] == NVEC, "loop incomplete");
    chk(v[16] == sig_exp, "signature differs from the golden-order MISR");
    chk(v[14] == 0 && v[15] == 0, "latency outside the histogram window");
    chk(int'(v[3]) >= lo && int'(v[4]) <= hi, $sformatf("latency %0d..%0d outside expected [%0d,%0d]", v[3], v[4], lo, hi));
    if (cor >= 0) begin
      chk(v[7] == 1 && v[8][31] && int'(v[8][23:0]) == cor, $sformatf("corruption of seq %0d: want exactly 1 mismatch at it", cor));
      chk(g_ch[0].u_ba.n_corrupt == 1, "corruption: the model did not invert exactly one block");
    end else begin
      chk(v[7] == 0 && !v[8][31], "decision mismatches");
    end
    bad = 0; seen_bad = 0;
    for (int i = 0; i < NVEC; i++) begin
      f_exp = echo ? 0 : int'(gold[i][N_DET]);
      if (i == cor) f_exp ^= 1;
      if (u_dut.u_a.flag_mem[i][0] != f_exp[0]) bad++;
      if (!u_dut.u_a.flag_mem[i][1]) seen_bad++;
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
    if (gap == 7 && cor < 0) begin
      if (echo) begin echo7_min = int'(v[3]); echo7_max = int'(v[4]); echo7_mean = mean; end
      else begin dec7_min = int'(v[3]); dec7_max = int'(v[4]); dec7_mean = mean; end
    end
    corrupt_seq = -1;
    g_ch[0].u_ba.n_corrupt = 0;
    if (n_fail != 0) $fatal(1, "FAIL in case %s (%0d checks)", name, n_fail);
    axi_wr(13'h004, {30'b0, echo, 1'b0});
    do axi_rd(13'h010, s); while (s[0]);
  endtask

  logic [31:0] id, p0, p1, p2, p3, lk, did, dpar;
  logic [31:0] ls[32];
  int lat_ui, seed;
  initial begin
    int n;
    n_fail = 0;
    if (!$value$plusargs("LAT_UI=%d", lat_ui)) lat_ui = 640;
    if (!$value$plusargs("SEED=%d", seed)) seed = 0;
    if (!$value$plusargs("CORRUPT=%d", corrupt)) corrupt = NVEC / 2 + 17;
    if (corrupt < 0 || corrupt >= NVEC) $fatal(1, "+CORRUPT out of range");
    $readmemh(INIT_FILE, gold);
    repeat (20) @(negedge aclk);
    aresetn = 1'b1;
    @(negedge clk); #0.5; rst_clk = 1'b0;
    repeat (50) @(negedge clk);
    #0.5; rst_rx = 1'b0;          // RX first: random bits until the far TX starts
    repeat (300) @(negedge clk);
    #0.5; rst_tx = 1'b0;
    axi_rd(13'h000, id);
    axi_rd(13'h0F0, p0);
    axi_rd(13'h0F4, p1);
    axi_rd(13'h1000, did);
    axi_rd(13'h1014, dpar);
    $display("CONFIG id=%h diag=%h params=%h NVEC=%0d DEC_LAT=%0d N_DET=%0d DW=%0d NL=%0d TX_REG=%0d RX_REG=%0d LAT_UI=%0d SEED=%0d (MODEL wire) TIMEOUT=%0d T_NS=%.4f corrupt_seq=%0d",
             id, did, dpar, p0, p1, N_DET, DW, NL, TX_REG, RX_REG, lat_ui, seed, TIMEOUT, t_ns, corrupt);
    if (id != 32'h5333_0001 || p0 != NVEC || p1 != DEC_LAT || did != 32'h5336_0001 || dpar[3:0] != 4'(NL))
      $fatal(1, "ID / parameter registers wrong");
    n = 0;
    do begin repeat (100) @(negedge aclk); axi_rd(13'h024, lk); n++; if (n > 200) $fatal(1, "no lock: LINK %h", lk); end
    while ((lk & 32'h101) != 32'h101);
    $display("LINK %h after %0d polls (lock A, B)", lk, n);
    axi_wr(13'h004, 32'h30);      // soft resets: clear side counters and the LINK stickies
    axi_wr(13'h004, 32'h00);
    axi_rd(13'h024, lk);
    $display("LINK %h after soft reset", lk);
    chk(lk[2] == 1'b0 && lk[10] == 1'b0, "LINK lock-lost sticky set after bring-up");

    probe_case(63, 20000);
    probe_case(0, 6000);
    // stop the probe at varied phases (AXI writes on aclk): the sent / received counts must agree every time
    for (int k = 0; k < 6; k++) probe_case(0, 1000 + 7 * k);

    run_case("dec_gap0", 1'b0, 0, -1);
    run_case("dec_gap7", 1'b0, 7, -1);
    run_case("echo_gap7", 1'b1, 7, -1);
    run_case("echo_gap0", 1'b1, 0, -1);
    run_case("corrupt_gap1", 1'b0, 1, corrupt);
    axi_rd(13'h0FC, p2);
    axi_rd(13'h100, p3);
    $display("CONFIG N_DET=%0d DW=%0d", p2, p3);
    if (p2 != N_DET || p3 != DW) $fatal(1, "N_DET / DW registers wrong");

    // ---- link counters over the whole run ----
    diag_snap();
    for (int k = 0; k < 32; k++) axi_rd(13'(13'h1400 + 4 * k), ls[k]);
    axi_rd(13'h024, lk);
    $display("LINKSTAT A lock=%h locks=%0d unlocks=%0d slips=%0d sh_bad=%0d idle_bad=%0d data=%0d dsk_ovf=%0d hv_dv=%0d | B lock=%h locks=%0d unlocks=%0d slips=%0d sh_bad=%0d idle_bad=%0d data=%0d dsk_ovf=%0d hv_dv=%0d | LINK=%h",
             ls[0], ls[1], ls[2], ls[3], ls[4], ls[5], ls[6], ls[7], ls[8], ls[16], ls[17], ls[18], ls[19], ls[20], ls[21], ls[22], ls[23], ls[24], lk);
    chk(ls[2] == 0 && ls[18] == 0 && ls[4] == 0 && ls[20] == 0 && ls[5] == 0 && ls[21] == 0 && ls[7] == 0 && ls[23] == 0,
        "link errors during the run");
    chk(lk[2] == 1'b0 && lk[3] == 1'b0 && lk[10] == 1'b0 && lk[11] == 1'b0, "LINK stickies set");
    // check blocks (s6_pkg CHK_TYPE): the corrupt case's model inverts one returned data word on B -> A lane 0 after
    // descrambling and re-scrambles it, so the link itself is clean but A's CRC must catch exactly that word
    $display("CHK A ok=%0d bad=%0d | B ok=%0d bad=%0d", ls[11], ls[12], ls[27], ls[28]);
    chk(ls[11] != 0 && ls[27] != 0, "no good check block at an end");
    chk(ls[28] == 0, "bad check blocks at B");
    chk(ls[12] == 1, $sformatf("A: %0d bad check blocks, want exactly 1 (the corrupted word)", ls[12]));

    chk(dec7_min - echo7_min >= DEC_LAT - 1 && dec7_min - echo7_min <= DEC_LAT + 1, "decode - echo (min) != DEC_LAT +- 1");
    chk(dec7_max - echo7_max >= DEC_LAT - 1 && dec7_max - echo7_max <= DEC_LAT + 1, "decode - echo (max) != DEC_LAT +- 1");
    chk(dec7_mean - echo7_mean >= DEC_LAT - 0.5 && dec7_mean - echo7_mean <= DEC_LAT + 0.5, "decode - echo (mean) != DEC_LAT +- 0.5");
    $display("RESULT s6_loop nvec=%0d dec_lat=%0d nl=%0d tx_reg=%0d rx_reg=%0d lat_ui=%0d seed=%0d t_ns=%.4f oneway_ab=%0d..%0d mean %.4f oneway_ba=%0d..%0d mean %.4f gap7 decode=%0d..%0d mean %.4f echo=%0d..%0d mean %.4f decode_minus_echo min=%0d max=%0d mean=%.4f fails=%0d",
             NVEC, DEC_LAT, NL, TX_REG, RX_REG, lat_ui, seed, t_ns, ow_ab_min, ow_ab_max, ow_ab_mean, ow_ba_min, ow_ba_max, ow_ba_mean,
             dec7_min, dec7_max, dec7_mean, echo7_min, echo7_max, echo7_mean,
             dec7_min - echo7_min, dec7_max - echo7_max, dec7_mean - echo7_mean, n_fail);
    if (n_fail != 0) $fatal(1, "FAIL (%0d checks)", n_fail);
    $display("PASS");
    $finish;
  end
endmodule
