// x310_stream: the Stage 5 classifier on the radio's sample stream (PLAN.md D-S5-WIN, D-S5-RTL).
//
// One sc16 sample (in_i, in_q) per clock when in_vld (the radio clock, 200 MS/s, spc = 1). The newest
// sample enters the top of a W-sample shift register, so the register is always the window
// {sample n-W+1 (oldest, lane 0/1) ... sample n (newest)} in x310_clf_top's lane order. Once W samples
// have arrived, every valid sample yields one decision (II = 1): out_vld, cls and the logits of the window
// ending at that sample. Latency, last window sample at the ports -> decision: 1 (shift register) +
// CORE_LAT + 1 + BFP_PIPE edges (Verilator measures it, tb/tb_x310_stream.sv).
// Integration (D-S5-TAP) maps the RFNoC sc16 item {I[31:16], Q[15:0]} onto in_i / in_q.
`timescale 1ns / 1ps
`default_nettype none

module x310_stream #(
    parameter int W = 64,
    parameter int OUT_W = 40,
    parameter int CORE_LAT = 4,
    parameter int BFP_PIPE = 1
) (
    input  wire              clk,
    input  wire              rst,
    input  wire  [15:0]      in_i,
    input  wire  [15:0]      in_q,
    input  wire              in_vld,
    output logic [OUT_W-1:0] logits,
    output logic [1:0]       cls,
    output logic             out_vld
);
  logic [32*W-1:0]        win;
  logic [$clog2(W+1)-1:0] cnt;
  logic                   win_vld;

  always_ff @(posedge clk) begin
    if (in_vld) win <= {in_q, in_i, win[32*W-1:32]};
  end
  always_ff @(posedge clk) begin
    if (rst) begin
      cnt     <= '0;
      win_vld <= 1'b0;
    end else begin
      win_vld <= in_vld && (cnt >= ($clog2(W+1))'(W - 1));
      if (in_vld && cnt != ($clog2(W+1))'(W)) cnt <= cnt + 1'b1;
    end
  end

  x310_clf_top #(.W(W), .OUT_W(OUT_W), .CORE_LAT(CORE_LAT), .BFP_PIPE(BFP_PIPE)) u_clf (
      .clk(clk), .rst(rst), .win(win), .in_vld(win_vld), .logits(logits), .cls(cls), .out_vld(out_vld));
endmodule

`default_nettype wire
