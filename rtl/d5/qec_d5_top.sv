// qec_d5_top: da4ml d = 5 decoder core + the registered logical-flip decision.
// The core registers its input and every stage (LAT edges, input to logit); the decision
// flip = (logit > 0), the rule the export records in ref/golden/qec_d5_golden.json, adds one register (LAT + 1).
// The port is the 120 raw detection bits (detector j at bit j); qec_d5_in_map.svh (generated with
// the model) maps bit j to the core's input lane j: 0 or LANE_ONE[j] (pruned detectors have no lane).
// LOGIT_SIGNED = 1 for a two's-complement logit lane, 0 for an unsigned one.
// Location: rtl/d5/, not rtl/, on purpose. The d = 3 Verilator flows pass -I rtl (for qec_d3_in_map.svh),
// and Verilator's library search would then find and parse rtl/qec_d5_top.sv for s3_side_b's (dead)
// N_DET = 120 branch and fail on the include until the export has written rtl/qec_d5_in_map.svh.
// The include is found through -I rtl (real core) or -I tb/standin (TEST-ONLY stand-in map).
module qec_d5_top #(
    parameter int IN_W = 120,  // = N_DET
    parameter int OUT_W = 8,
    parameter int LOGIT_SIGNED = 1
) (
    input  logic             clk,
    input  logic [IN_W-1:0]  det,
    output logic [OUT_W-1:0] logit,
    output logic             flip
);
`include "qec_d5_in_map.svh"
  logic [CORE_IN_W-1:0] lanes;
  always_comb begin
    lanes = '0;
    for (int j = 0; j < N_DET; j++)
      for (int b = 0; b < LANE_W[j]; b++)
        lanes[LANE_OFF[j] + b] = det[j] & LANE_ONE[j][b];
  end

  qec_d5 u_core (.clk(clk), .model_inp(lanes), .model_out(logit));

  wire positive = ((LOGIT_SIGNED != 0) ? !logit[OUT_W-1] : 1'b1) && (logit != '0);
  always_ff @(posedge clk) flip <= positive;
endmodule
