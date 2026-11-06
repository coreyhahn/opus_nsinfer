// jsc_argmax: class decision from the da4ml core's packed logits.
//
// Lanes are aligned to the finest LSB and sign-extended (layout generated in
// jsc_out_lanes.svh by ref/export_argmax.py). The winner is the lowest index
// i with v_i >= v_j for every j > i and v_i > v_j for every j < i, which is
// np.argmax's first-maximum rule; all ten comparisons run in parallel.
// ARG_LAT = 1: compare and encode in one cycle. ARG_LAT = 2: the comparison
// bits are registered first. The logits leave aligned with the class.
`timescale 1ns / 1ps
`default_nettype none

module jsc_argmax #(
    parameter int ARG_LAT = 1
) (
    input  wire         clk,
    input  wire  [79:0] logits_in,
    input  wire         vld_in,
    output logic [2:0]  cls_out,
    output logic [79:0] logits_out,
    output logic        vld_out
);
  `include "jsc_out_lanes.svh"

  logic signed [ARG_AW-1:0] v[N_CLASS];
  for (genvar i = 0; i < N_CLASS; i++) begin : g_lane
    wire signed [LANE_W[i]-1:0] raw = logits_in[LANE_OFF[i]+:LANE_W[i]];
    assign v[i] = ARG_AW'(raw) <<< LANE_SH[i];
  end

  // win[i]: lane i is the first maximum
  logic [N_CLASS-1:0] win;
  always_comb begin
    for (int i = 0; i < N_CLASS; i++) begin
      win[i] = 1'b1;
      for (int j = 0; j < N_CLASS; j++) begin
        if (j > i && v[i] < v[j]) win[i] = 1'b0;
        if (j < i && v[i] <= v[j]) win[i] = 1'b0;
      end
    end
  end

  function automatic logic [2:0] enc(input logic [N_CLASS-1:0] w);
    enc = 3'd0;
    for (int i = N_CLASS - 1; i >= 0; i--) if (w[i]) enc = 3'(i);
  endfunction

  if (ARG_LAT == 1) begin : g_lat1
    always_ff @(posedge clk) begin
      cls_out    <= enc(win);
      logits_out <= logits_in;
      vld_out    <= vld_in;
    end
  end else begin : g_lat2
    logic [N_CLASS-1:0] win_q;
    logic [79:0]        logits_q;
    logic               vld_q;
    always_ff @(posedge clk) begin
      win_q      <= win;
      logits_q   <= logits_in;
      vld_q      <= vld_in;
      cls_out    <= enc(win_q);
      logits_out <= logits_q;
      vld_out    <= vld_q;
    end
  end
endmodule

`default_nettype wire
