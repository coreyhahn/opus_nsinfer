// tb_jsc: da4ml JSC core vs the Keras float64 golden model, bit for bit.
//
// Phase 1 (latency): flush with zeros, apply vector 0 for one cycle, count
//   clock edges until the output equals its golden value. Must equal LAT.
// Phase 2 (stream, II = 1): every test vector back to back, one per clock,
//   in natural order (SEED = 0) or a seeded Fisher-Yates shuffle; output of
//   vector t is checked LAT edges after it was applied.
// Drive and sample at NEGEDGE only (Verilator --timing race rule).
// Any mismatch -> $fatal(1), so the exit code carries the verdict.
`timescale 1ns / 1ps

module tb_jsc #(
    parameter int IN_W  = 159,
    parameter int OUT_W = 100,
    parameter int LAT   = 8,
    parameter int NVEC  = 166000
);
  logic clk = 1'b0;
  always #2.5 clk = ~clk;

  logic [IN_W-1:0]  in_mem [NVEC];
  logic [OUT_W-1:0] out_mem[NVEC];
  int unsigned      perm   [NVEC];

  logic [IN_W-1:0]  din;
  wire  [OUT_W-1:0] dout;

  jsc dut (.clk(clk), .model_inp(din), .model_out(dout));

  // xorshift32: portable, seed-reproducible permutation independent of the
  // simulator's RNG.
  int unsigned rng;
  function automatic int unsigned xs32();
    rng ^= rng << 13;
    rng ^= rng >> 17;
    rng ^= rng << 5;
    return rng;
  endfunction

  string in_file, out_file;
  int unsigned seed;
  int lat_meas, n_mis, n_chk, k;
  int unsigned j, tmp;
  logic [OUT_W-1:0] zero_out, sig;

  initial begin
    if (!$value$plusargs("IN=%s", in_file))   $fatal(1, "missing +IN=");
    if (!$value$plusargs("OUT=%s", out_file)) $fatal(1, "missing +OUT=");
    if (!$value$plusargs("SEED=%d", seed))    seed = 0;
    $readmemh(in_file, in_mem);
    $readmemh(out_file, out_mem);
    for (int i = 0; i < NVEC; i++) perm[i] = i;
    if (seed != 0) begin
      rng = seed;
      for (int i = NVEC - 1; i > 0; i--) begin
        j = xs32() % (i + 1);
        tmp = perm[i]; perm[i] = perm[j]; perm[j] = tmp;
      end
    end

    // ---- Phase 1: impulse latency ----
    din = '0;
    repeat (LAT + 4) @(negedge clk);
    zero_out = dout;
    if (zero_out == out_mem[perm[0]]) $fatal(1, "impulse vector indistinguishable from zero input");
    din = in_mem[perm[0]];
    lat_meas = -1;
    for (int c = 1; c <= 4 * LAT + 8; c++) begin
      @(negedge clk);
      din = '0;
      if (lat_meas < 0 && dout == out_mem[perm[0]]) lat_meas = c;
    end
    if (lat_meas != LAT) $fatal(1, "latency measured %0d cycles, expected LAT=%0d", lat_meas, LAT);
    $display("LATENCY cycles=%0d (input applied before edge 1, output valid after edge %0d)", lat_meas, lat_meas);

    // ---- Phase 2: back-to-back stream ----
    n_mis = 0; n_chk = 0; sig = '0;
    for (int t = 0; t < NVEC + LAT; t++) begin
      // sample first (value registered on the previous LAT edges), then drive
      k = t - LAT;
      if (k >= 0) begin
        n_chk++;
        sig ^= dout;
        if (dout !== out_mem[perm[k]]) begin
          n_mis++;
          if (n_mis <= 10)
            $display("MISMATCH vec=%0d got=%h exp=%h", perm[k], dout, out_mem[perm[k]]);
        end
      end
      din = (t < NVEC) ? in_mem[perm[t]] : '0;
      @(negedge clk);
    end
    $display("RESULT seed=%0d vectors=%0d checked=%0d mismatches=%0d latency=%0d xor_signature=%h",
             seed, NVEC, n_chk, n_mis, lat_meas, sig);
    if (n_mis != 0 || n_chk != NVEC) $fatal(1, "FAIL: %0d mismatches", n_mis);
    $display("PASS");
    $finish;
  end
endmodule
