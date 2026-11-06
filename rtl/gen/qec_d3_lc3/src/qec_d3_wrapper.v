`timescale 1 ns / 1 ps

module qec_d3_wrapper (
   input clk,
    // verilator lint_off UNUSEDSIGNAL
    input [71:0] model_inp,
    // verilator lint_on UNUSEDSIGNAL
    output [17:0] model_out
);
    wire [47:0] packed_inp;
    wire [17:0] packed_out;

    assign packed_inp[3:0] = model_inp[4:1];
    assign packed_inp[5:4] = model_inp[7:6];
    assign packed_inp[7:6] = model_inp[10:9];
    assign packed_inp[11:8] = model_inp[16:13];
    assign packed_inp[15:12] = model_inp[22:19];
    assign packed_inp[17:16] = model_inp[25:24];
    assign packed_inp[21:18] = model_inp[31:28];
    assign packed_inp[23:22] = model_inp[35:34];
    assign packed_inp[27:24] = model_inp[40:37];
    assign packed_inp[31:28] = model_inp[46:43];
    assign packed_inp[33:32] = model_inp[49:48];
    assign packed_inp[37:34] = model_inp[55:52];
    assign packed_inp[41:38] = model_inp[61:58];
    assign packed_inp[43:42] = model_inp[64:63];
    assign packed_inp[47:44] = model_inp[70:67];

    qec_d3 op (
        .clk(clk),
        .model_inp(packed_inp),
        .model_out(packed_out)
    );

    assign model_out[17:0] = packed_out[17:0];

endmodule
