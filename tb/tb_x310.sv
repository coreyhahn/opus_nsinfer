// tb_x310: Stage 5 classifier (x310_clf_top = BFP + da4ml core + argmax) vs the Keras float64 model, bit
// for bit, on independent windows (the golden or the full test set from ref/x310/export_x310.py).
//
// Phase 1 (latency): idle, then one valid window; count edges until out_vld (must be LAT) and check its
//   logits and class.
// Phase 2 (stream, II = 1): every window once, natural order and no gaps (SEED = 0), or a seeded
//   Fisher-Yates shuffle (xorshift32) with idle cycles (in_vld = 0, random data on the port) inserted with
//   probability 1/8 per cycle. Outputs are matched in order through a queue of applied indices: logits and
//   class of every out_vld, and the number of outputs must equal NVEC.
// CORRUPT = k (plusarg) flips bit 0 of the expected logits of window k: the negative control, must FAIL.
// Drive and sample at NEGEDGE only (Verilator --timing race rule). Any mismatch -> $fatal(1).
`timescale 1ns / 1ps

module tb_x310 #(
    parameter int W = 64,
    parameter int OUT_W = 40,
    parameter int CORE_LAT = 4,
    parameter int BFP_PIPE = 1,
    parameter int NVEC = 1000
);
  localparam int LAT = CORE_LAT + 1 + BFP_PIPE;
  logic clk = 1'b0;
  always #2.5 clk = ~clk;  // 5.0 ns, the radio clock

  logic [32*W-1:0]  in_mem [NVEC];
  logic [OUT_W-1:0] out_mem[NVEC];
  logic [3:0]       dec_mem[NVEC];
  int unsigned      perm   [NVEC];
  int unsigned      q      [NVEC];

  logic             rst = 1'b1;
  logic [32*W-1:0]  din;
  logic             dvld;
  wire  [OUT_W-1:0] logits;
  wire  [1:0]       cls;
  wire              ovld;

  x310_clf_top #(.W(W), .OUT_W(OUT_W), .CORE_LAT(CORE_LAT), .BFP_PIPE(BFP_PIPE)) dut (
      .clk(clk), .rst(rst), .win(din), .in_vld(dvld), .logits(logits), .cls(cls), .out_vld(ovld));

  int unsigned rng;
  function automatic int unsigned xs32();
    rng ^= rng << 13;
    rng ^= rng >> 17;
    rng ^= rng << 5;
    return rng;
  endfunction
  function automatic logic [32*W-1:0] rnd_win();
    logic [32*W-1:0] r;
    for (int i = 0; i < W; i++) r[32*i +: 32] = xs32();
    return r;
  endfunction

  string in_file, out_file, dec_file;
  int unsigned seed, j, tmp;
  int lat_meas, n_mis, n_cmis, n_chk, n_gap, qh, qt, t, corrupt, k0;
  int hist[4];
  logic [OUT_W-1:0] sig;

  task automatic check_out();
    int k;
    if (!ovld) return;
    if (qh == qt) $fatal(1, "out_vld with no window in flight");
    k = q[qh];
    qh++;
    n_chk++;
    sig ^= logits;
    hist[cls]++;
    if (logits !== out_mem[k]) begin
      n_mis++;
      if (n_mis <= 10) $display("MISMATCH vec=%0d got=%h exp=%h", k, logits, out_mem[k]);
    end
    if (4'(cls) !== dec_mem[k]) begin
      n_cmis++;
      if (n_cmis <= 10) $display("CLASS_MISMATCH vec=%0d got=%0d exp=%0d", k, cls, dec_mem[k]);
    end
  endtask

  initial begin
    if (!$value$plusargs("IN=%s", in_file))   $fatal(1, "missing +IN=");
    if (!$value$plusargs("OUT=%s", out_file)) $fatal(1, "missing +OUT=");
    if (!$value$plusargs("DEC=%s", dec_file)) $fatal(1, "missing +DEC=");
    if (!$value$plusargs("SEED=%d", seed))    seed = 0;
    if (!$value$plusargs("CORRUPT=%d", corrupt)) corrupt = -1;
    $readmemh(in_file, in_mem);
    $readmemh(out_file, out_mem);
    $readmemh(dec_file, dec_mem);
    if (corrupt >= 0) begin
      out_mem[corrupt][0] = ~out_mem[corrupt][0];
      $display("NEGATIVE CONTROL: expected logits of window %0d corrupted (bit 0 flipped)", corrupt);
    end
    for (int i = 0; i < NVEC; i++) perm[i] = i;
    rng = (seed == 0) ? 32'h1234_5678 : seed;
    if (seed != 0)
      for (int i = NVEC - 1; i > 0; i--) begin
        j = xs32() % (i + 1);
        tmp = perm[i]; perm[i] = perm[j]; perm[j] = tmp;
      end

    // ---- Phase 1: latency of one window
    din = '0; dvld = 1'b0;
    repeat (4) @(negedge clk);
    rst = 1'b0;
    repeat (LAT + 4) @(negedge clk);
    k0 = perm[0];
    din = in_mem[k0]; dvld = 1'b1;
    lat_meas = -1;
    for (int c = 1; c <= 4 * LAT + 8; c++) begin
      @(negedge clk);
      din = rnd_win(); dvld = 1'b0;
      if (ovld) begin
        if (lat_meas >= 0) $fatal(1, "second out_vld after one window");
        lat_meas = c;
        if (logits !== out_mem[k0] || 4'(cls) !== dec_mem[k0]) $fatal(1, "latency window %0d wrong: %h / %0d", k0, logits, cls);
      end
    end
    if (lat_meas != LAT) $fatal(1, "latency measured %0d cycles, expected LAT=%0d", lat_meas, LAT);
    $display("LATENCY cycles=%0d (window applied before edge 1 -> logits and class valid; core %0d, BFP_PIPE %0d, argmax 1)",
             lat_meas, CORE_LAT, BFP_PIPE);

    // ---- Phase 2: every window, back to back (with gaps for seed != 0)
    n_mis = 0; n_cmis = 0; n_chk = 0; n_gap = 0; qh = 0; qt = 0; sig = '0;
    for (int i = 0; i < 4; i++) hist[i] = 0;
    t = 0;
    while (t < NVEC) begin
      if (seed != 0 && (xs32() % 8) == 0) begin
        din = rnd_win(); dvld = 1'b0; n_gap++;
      end else begin
        din = in_mem[perm[t]]; dvld = 1'b1;
        q[qt] = perm[t]; qt++; t++;
      end
      @(negedge clk);
      check_out();
    end
    din = '0; dvld = 1'b0;
    repeat (LAT + 4) begin
      @(negedge clk);
      check_out();
    end
    $display("RESULT seed=%0d vectors=%0d checked=%0d mismatches=%0d class_mismatches=%0d gaps=%0d latency=%0d class_hist=%0d,%0d,%0d,%0d xor_signature=%h",
             seed, NVEC, n_chk, n_mis, n_cmis, n_gap, lat_meas, hist[0], hist[1], hist[2], hist[3], sig);
    if (n_mis != 0 || n_cmis != 0 || n_chk != NVEC) $fatal(1, "FAIL: %0d logit, %0d class mismatches, %0d of %0d checked", n_mis, n_cmis, n_chk, NVEC);
    $display("PASS");
    $finish;
  end
endmodule
