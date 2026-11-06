`timescale 1 ns / 1 ps

module x310_clf_wrapper (
   input clk,
    // verilator lint_off UNUSEDSIGNAL
    input [2047:0] model_inp,
    // verilator lint_on UNUSEDSIGNAL
    output [67:0] model_out
);
    wire [2047:0] packed_inp;
    wire [64:0] packed_out;

    assign packed_inp[2047:0] = model_inp[2047:0];

    x310_clf op (
        .clk(clk),
        .model_inp(packed_inp),
        .model_out(packed_out)
    );

    assign model_out[0:0] = 1'b0;
    assign model_out[15:1] = packed_out[14:0];
    assign model_out[16:16] = {1{packed_out[14]}};
    assign model_out[66:17] = packed_out[64:15];
    assign model_out[67:67] = {1{packed_out[64]}};

endmodule
