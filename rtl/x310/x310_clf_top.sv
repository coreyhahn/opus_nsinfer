// x310_clf_top: Stage 5 waveform classifier on one window (PLAN.md D-S5-BFP, D-S5-RTL).
//
//   win (2W int16 lanes: lane 2k = I_k, 2k + 1 = Q_k, sample 0 oldest, lane 0 at the LSB)
//     -> block floating point: s = min(X_S_MAX, 15 - bitlength(OR_j (v_j ^ {15{v_j[15]}}))), v_j <<< s
//        (ref/x310/x310_data.py:bfp(); integer only, no overflow by construction)
//     -> da4ml core x310_clf (its input register, then its stages: CORE_LAT edges; the SAT / TRN input
//        quantizer is inside the core, traced from 16-bit lanes)
//     -> first-max argmax over the N_CLASS logits (np.argmax's rule), registered with the logits (+1 edge).
// BFP_PIPE = 0: the shift is combinational into the core's input register (no extra cycle); 1: the OR
// mask and the window are registered first (+1 edge); 2: the shift amount too (+2 edges). On the K7 at
// 5.0 ns (OOC dry runs, 128 lanes): 0 fails (-0.29 ns, 9 levels), 1 closes the BFP path (+0.35 ns), 2 is no
// better (+0.005 ns, the replicated shift amount's fanout). Latency in_vld -> out_vld = CORE_LAT + 1 + BFP_PIPE
// edges, II = 1, one clock (the radio clock), no reset needed on the data path (valid has one).
// Layout constants come from rtl/gen/x310_clf_lanes.svh, generated with the model.
`timescale 1ns / 1ps
`default_nettype none

module x310_clf_top #(
    parameter int W = 64,         // must equal X_W of x310_clf_lanes.svh
    parameter int OUT_W = 40,     // must equal X_OUT_W
    parameter int CORE_LAT = 4,   // da4ml metadata latency + 1 (input register)
    parameter int BFP_PIPE = 1
) (
    input  wire                 clk,
    input  wire                 rst,
    input  wire  [32*W-1:0]     win,
    input  wire                 in_vld,
    output logic [OUT_W-1:0]    logits,
    output logic [1:0]          cls,
    output logic                out_vld
);
  `include "x310_clf_lanes.svh"
  localparam int NL = 2 * W;
  localparam int LAT = CORE_LAT + 1 + BFP_PIPE;

  if (W != X_W || OUT_W != X_OUT_W || N_CLASS > 4) begin : g_bad
    $error("x310_clf_top parameters do not match x310_clf_lanes.svh");
  end

  // ---------------- block floating point
  // BFP_PIPE = 0: OR tree, shift encode and the shift itself in one cycle into the core's input register.
  // BFP_PIPE = 1: the OR mask is registered (the window is delayed with it).
  // BFP_PIPE = 2: the shift amount is registered as well (replicated by synthesis, max_fanout).
  logic [14:0]       mask_c, mask;
  logic [32*W-1:0]   win_b, win_c;
  always_comb begin
    mask_c = '0;
    for (int j = 0; j < NL; j++) mask_c |= win[16*j +: 15] ^ {15{win[16*j+15]}};
  end
  if (BFP_PIPE >= 1) begin : g_p1
    always_ff @(posedge clk) begin
      mask  <= mask_c;
      win_b <= win;
    end
  end else begin : g_p1c
    assign mask  = mask_c;
    assign win_b = win;
  end

  function automatic logic [3:0] shift_of(input logic [14:0] m);
    int bl;
    bl = 0;
    for (int b = 0; b < 15; b++) if (m[b]) bl = b + 1;
    return (X_BFP == 0) ? 4'd0 : ((15 - bl > X_S_MAX) ? 4'(X_S_MAX) : 4'(15 - bl));
  endfunction

  logic [3:0] sh;
  if (BFP_PIPE >= 2) begin : g_p2
    (* max_fanout = 64 *) logic [3:0] sh_q;
    always_ff @(posedge clk) begin
      sh_q  <= shift_of(mask);
      win_c <= win_b;
    end
    assign sh = sh_q;
  end else begin : g_p2c
    assign sh    = shift_of(mask);
    assign win_c = win_b;
  end

  // shifted lanes packed into the core's port (lanes HGQ pruned are not on it: IN_COFF[j] = -1)
  logic [X_CORE_IN_W-1:0] core_in;
  always_comb begin
    core_in = '0;
    for (int j = 0; j < NL; j++)
      if (IN_COFF[j] >= 0) core_in[IN_COFF[j] +: 16] = win_c[16*j +: 16] << sh;
  end

  // ---------------- da4ml core
  wire [OUT_W-1:0] z;
  x310_clf u_core (.clk(clk), .model_inp(core_in), .model_out(z));

  // ---------------- first-max argmax (all comparisons in parallel), registered with the logits
  logic signed [ARG_AW-1:0] v[N_CLASS];
  for (genvar i = 0; i < N_CLASS; i++) begin : g_lane
    wire signed [LANE_W[i]-1:0] raw = z[LANE_OFF[i] +: LANE_W[i]];
    assign v[i] = ARG_AW'(raw) <<< LANE_SH[i];
  end
  logic [N_CLASS-1:0] win_cls;
  always_comb begin
    for (int i = 0; i < N_CLASS; i++) begin
      win_cls[i] = 1'b1;
      for (int j = 0; j < N_CLASS; j++) begin
        if (j > i && v[i] < v[j]) win_cls[i] = 1'b0;
        if (j < i && v[i] <= v[j]) win_cls[i] = 1'b0;
      end
    end
  end
  function automatic logic [1:0] enc(input logic [N_CLASS-1:0] w);
    enc = 2'd0;
    for (int i = N_CLASS - 1; i >= 0; i--) if (w[i]) enc = 2'(i);
  endfunction
  always_ff @(posedge clk) begin
    cls    <= enc(win_cls);
    logits <= z;
  end

  // ---------------- valid
  logic [LAT-1:0] vsr;
  always_ff @(posedge clk) begin
    if (rst) vsr <= '0;
    else     vsr <= {vsr[LAT-2:0], in_vld};
  end
  assign out_vld = vsr[LAT-1];
endmodule

`default_nettype wire
