// tb_qec: da4ml d = 3 decoder (qec_d3_top) vs the Keras float64 golden model, bit for bit.
// Built with +define+QEC_D5 it checks the d = 5 decoder (qec_d5_top, IN_W = 120) the same way.
//
// Phase 1 (latency): flush with zeros, apply vector 0 of the order for one cycle, count edges
//   until the logit equals its golden value (must be LAT) and check the decision at LAT + 1.
// Phase 2 (stream, II = 1): every vector back to back, natural order (SEED = 0) or a seeded
//   Fisher-Yates shuffle (xorshift32); logit checked LAT edges and the flip bit LAT + 1 edges
//   after the vector was applied. DEC = 0 skips the flip check (exhaustive set has no dec file).
// Drive and sample at NEGEDGE only (Verilator --timing race rule). Any mismatch -> $fatal(1).
`timescale 1ns / 1ps

module tb_qec #(
    parameter int IN_W  = 24,
    parameter int OUT_W = 8,
    parameter int LAT   = 4,
    parameter int NVEC  = 1000,
    parameter int LOGIT_SIGNED = 1
);
  logic clk = 1'b0;
  always #1.5 clk = ~clk;

  logic [IN_W-1:0]  in_mem [NVEC];
  logic [OUT_W-1:0] out_mem[NVEC];
  logic [3:0]       dec_mem[NVEC];
  int unsigned      perm   [NVEC];

  logic [IN_W-1:0]  din;
  wire  [OUT_W-1:0] dout;
  wire              flip;

`ifdef QEC_D5
  qec_d5_top #(.IN_W(IN_W), .OUT_W(OUT_W), .LOGIT_SIGNED(LOGIT_SIGNED)) dut (.clk(clk), .det(din), .logit(dout), .flip(flip));
`else
  qec_d3_top #(.IN_W(IN_W), .OUT_W(OUT_W), .LOGIT_SIGNED(LOGIT_SIGNED)) dut (.clk(clk), .det(din), .logit(dout), .flip(flip));
`endif

  int unsigned rng;
  function automatic int unsigned xs32();
    rng ^= rng << 13;
    rng ^= rng >> 17;
    rng ^= rng << 5;
    return rng;
  endfunction

  string in_file, out_file, dec_file;
  int unsigned seed;
  int lat_meas, n_mis, n_dmis, n_chk, n_dchk, n_flip, k, use_dec;
  int unsigned j, tmp;
  logic [OUT_W-1:0] zero_out, sig;
  logic zero_flip;

  initial begin
    if (!$value$plusargs("IN=%s", in_file))   $fatal(1, "missing +IN=");
    if (!$value$plusargs("OUT=%s", out_file)) $fatal(1, "missing +OUT=");
    use_dec = $value$plusargs("DEC=%s", dec_file);
    if (!$value$plusargs("SEED=%d", seed))    seed = 0;
    $readmemh(in_file, in_mem);
    $readmemh(out_file, out_mem);
    if (use_dec) $readmemh(dec_file, dec_mem);
    for (int i = 0; i < NVEC; i++) perm[i] = i;
    if (seed != 0) begin
      rng = seed;
      for (int i = NVEC - 1; i > 0; i--) begin
        j = xs32() % (i + 1);
        tmp = perm[i]; perm[i] = perm[j]; perm[j] = tmp;
      end
    end

    // ---- Phase 1: impulse latency (first vector of the order whose logit differs from zero input's) ----
    din = '0;
    repeat (LAT + 4) @(negedge clk);
    zero_out = dout;
    zero_flip = flip;
    k = 0;
    while (out_mem[perm[k]] == zero_out) k++;
    din = in_mem[perm[k]];
    lat_meas = -1;
    for (int c = 1; c <= 4 * LAT + 8; c++) begin
      @(negedge clk);
      din = '0;
      if (lat_meas < 0 && dout == out_mem[perm[k]]) lat_meas = c;
    end
    if (lat_meas != LAT) $fatal(1, "latency measured %0d cycles, expected LAT=%0d", lat_meas, LAT);
    $display("LATENCY cycles=%0d logit, %0d flip (vector %0d; input applied before edge 1)", lat_meas, lat_meas + 1, perm[k]);

    // ---- Phase 2: back-to-back stream ----
    n_mis = 0; n_dmis = 0; n_chk = 0; n_dchk = 0; n_flip = 0; sig = '0;
    for (int t = 0; t < NVEC + LAT + 1; t++) begin
      k = t - LAT;
      if (k >= 0 && k < NVEC) begin
        n_chk++;
        sig ^= dout;
        if (dout !== out_mem[perm[k]]) begin
          n_mis++;
          if (n_mis <= 10) $display("MISMATCH vec=%0d got=%h exp=%h", perm[k], dout, out_mem[perm[k]]);
        end
      end
      k = t - LAT - 1;
      if (use_dec && k >= 0) begin
        n_dchk++;
        n_flip += flip;
        if (flip !== dec_mem[perm[k]][0]) begin
          n_dmis++;
          if (n_dmis <= 10) $display("FLIP_MISMATCH vec=%0d got=%0d exp=%0d", perm[k], flip, dec_mem[perm[k]][0]);
        end
      end
      din = (t < NVEC) ? in_mem[perm[t]] : '0;
      @(negedge clk);
    end
    $display("RESULT seed=%0d vectors=%0d checked=%0d mismatches=%0d flip_checked=%0d flip_mismatches=%0d flips=%0d latency=%0d xor_signature=%h",
             seed, NVEC, n_chk, n_mis, n_dchk, n_dmis, n_flip, lat_meas, sig);
    if (n_mis != 0 || n_chk != NVEC || n_dmis != 0 || (use_dec && n_dchk != NVEC)) $fatal(1, "FAIL: %0d logit, %0d flip mismatches", n_mis, n_dmis);
    $display("PASS");
    $finish;
  end
endmodule
