// tb_x310_stream: x310_stream (W-sample shift register + x310_clf_top) on a continuous capture vs the Keras
// float64 model on every one of its NS - W + 1 sliding windows (ref/golden/x310_stream_*.hex), bit for bit.
//
// After reset, the NS samples are driven in order, one per clock with in_vld = 1 (SEED = 0), or with idle
// cycles (in_vld = 0, random data on the ports) inserted with probability 1/8 per cycle (SEED != 0). The
// k-th out_vld must carry the logits and class of window k (samples k .. k + W - 1), and there must be
// exactly NS - W + 1 of them. Latency: edges from the W-th sample at the ports (applied before edge 1) to
// the first out_vld (SEED = 0 only, must be 1 + LAT). CORRUPT = k flips bit 0 of window k's expected
// logits (negative control). Drive and sample at NEGEDGE only. Any mismatch -> $fatal(1).
`timescale 1ns / 1ps

module tb_x310_stream #(
    parameter int W = 64,
    parameter int OUT_W = 40,
    parameter int CORE_LAT = 4,
    parameter int BFP_PIPE = 1,
    parameter int NS = 65536
);
  localparam int LAT = CORE_LAT + 1 + BFP_PIPE;
  localparam int NWIN = NS - W + 1;
  logic clk = 1'b0;
  always #2.5 clk = ~clk;

  logic [31:0]      in_mem [NS];
  logic [OUT_W-1:0] out_mem[NWIN];
  logic [3:0]       dec_mem[NWIN];

  logic        rst = 1'b1;
  logic [15:0] di, dq;
  logic        dvld;
  wire  [OUT_W-1:0] logits;
  wire  [1:0]  cls;
  wire         ovld;

  x310_stream #(.W(W), .OUT_W(OUT_W), .CORE_LAT(CORE_LAT), .BFP_PIPE(BFP_PIPE)) dut (
      .clk(clk), .rst(rst), .in_i(di), .in_q(dq), .in_vld(dvld), .logits(logits), .cls(cls), .out_vld(ovld));

  int unsigned rng;
  function automatic int unsigned xs32();
    rng ^= rng << 13;
    rng ^= rng >> 17;
    rng ^= rng << 5;
    return rng;
  endfunction

  string in_file, out_file, dec_file;
  int unsigned seed, r32;
  int n_mis, n_cmis, n_chk, n_gap, t, cyc, cyc_w, lat_meas, corrupt;
  int hist[4];
  logic [OUT_W-1:0] sig;

  task automatic check_out();
    if (!ovld) return;
    if (n_chk >= NWIN) $fatal(1, "more than NWIN = %0d decisions", NWIN);
    if (lat_meas < 0) lat_meas = cyc - cyc_w;
    sig ^= logits;
    hist[cls]++;
    if (logits !== out_mem[n_chk]) begin
      n_mis++;
      if (n_mis <= 10) $display("MISMATCH window=%0d got=%h exp=%h", n_chk, logits, out_mem[n_chk]);
    end
    if (4'(cls) !== dec_mem[n_chk]) begin
      n_cmis++;
      if (n_cmis <= 10) $display("CLASS_MISMATCH window=%0d got=%0d exp=%0d", n_chk, cls, dec_mem[n_chk]);
    end
    n_chk++;
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
    rng = (seed == 0) ? 32'h1234_5678 : seed;
    n_mis = 0; n_cmis = 0; n_chk = 0; n_gap = 0; sig = '0; lat_meas = -1; cyc = 0; cyc_w = 0;
    for (int i = 0; i < 4; i++) hist[i] = 0;
    di = '0; dq = '0; dvld = 1'b0;
    repeat (4) @(negedge clk);
    rst = 1'b0;
    repeat (2) @(negedge clk);
    t = 0;
    while (t < NS) begin
      if (seed != 0 && (xs32() % 8) == 0) begin
        r32 = xs32();
        {dq, di} = r32; dvld = 1'b0; n_gap++;
      end else begin
        {dq, di} = in_mem[t]; dvld = 1'b1;
        if (t == W - 1) cyc_w = cyc;
        t++;
      end
      @(negedge clk);
      cyc++;
      check_out();
    end
    dvld = 1'b0;
    repeat (LAT + 8) begin
      @(negedge clk);
      cyc++;
      check_out();
    end
    if (seed == 0 && lat_meas != 1 + LAT) $fatal(1, "stream latency %0d edges, expected 1 + LAT = %0d", lat_meas, 1 + LAT);
    $display("LATENCY cycles=%0d (last window sample at the ports before edge 1 -> decision valid; shift register 1, core %0d, BFP_PIPE %0d, argmax 1)%s",
             lat_meas, CORE_LAT, BFP_PIPE, seed == 0 ? "" : " (gapped run: includes idle cycles)");
    $display("RESULT seed=%0d samples=%0d windows=%0d checked=%0d mismatches=%0d class_mismatches=%0d gaps=%0d class_hist=%0d,%0d,%0d,%0d xor_signature=%h",
             seed, NS, NWIN, n_chk, n_mis, n_cmis, n_gap, hist[0], hist[1], hist[2], hist[3], sig);
    if (n_mis != 0 || n_cmis != 0 || n_chk != NWIN) $fatal(1, "FAIL: %0d logit, %0d class mismatches, %0d of %0d checked", n_mis, n_cmis, n_chk, NWIN);
    $display("PASS");
    $finish;
  end
endmodule
