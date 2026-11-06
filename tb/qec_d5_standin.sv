// qec_d5_standin: TEST-ONLY stand-in for the da4ml d = 5 core `qec_d5` (not a decoder; never in rtl/).
// Same port style as a da4ml core (clk, model_inp, model_out) so rtl/qec_d5_top.sv and the Stage 3/4
// loop can be exercised at N_DET = 120 / DW = 192 before the real d = 5 network exists.
// With tb/standin/qec_d5_in_map.svh (identity lanes: CORE_IN_W = 120, detector j -> model_inp[j]):
//   W[j]  = ((73 j + 11) mod 251) - 125                       (signed weights, -125..125)
//   par   = XOR of the 120 bits
//   logit = sum_j W[j] x[j] + (par ? +301 : -301)            (16-bit two's complement, no overflow)
// Pipeline like a da4ml core: input register, 3 more registers -> model_out 4 edges after model_inp
// (metadata-equivalent latency 3; with qec_d5_top's flip register, DEC_LAT = 5).
// Golden model: tb/qec_d5_standin_gen.py (same formula; flip = logit > 0).
module qec_d5 (
    input  logic         clk,
    input  logic [119:0] model_inp,
    output logic [15:0]  model_out
);
  function automatic logic signed [15:0] w(input int j);
    return 16'(((73 * j + 11) % 251) - 125);
  endfunction

  logic [119:0]        s0;
  logic signed [15:0]  s1_sum[4];
  logic [3:0]          s1_par;
  logic signed [15:0]  s2_sum;
  logic                s2_par;
  always_ff @(posedge clk) begin
    s0 <= model_inp;
    for (int g = 0; g < 4; g++) begin
      logic signed [15:0] acc;
      acc = '0;
      for (int k = 0; k < 30; k++) if (s0[30 * g + k]) acc = acc + w(30 * g + k);
      s1_sum[g] <= acc;
      s1_par[g] <= ^s0[30 * g +: 30];
    end
    s2_sum    <= s1_sum[0] + s1_sum[1] + s1_sum[2] + s1_sum[3];
    s2_par    <= ^s1_par;
    model_out <= s2_sum + (s2_par ? 16'sd301 : -16'sd301);
  end
endmodule
