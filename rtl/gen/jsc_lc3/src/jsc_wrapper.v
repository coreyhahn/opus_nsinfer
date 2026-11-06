`timescale 1 ns / 1 ps

module jsc_wrapper (
   input clk,
    // verilator lint_off UNUSEDSIGNAL
    input [223:0] model_inp,
    // verilator lint_on UNUSEDSIGNAL
    output [84:0] model_out
);
    wire [149:0] packed_inp;
    wire [79:0] packed_out;

    assign packed_inp[9:0] = model_inp[12:3];
    assign packed_inp[20:10] = model_inp[26:16];
    assign packed_inp[32:21] = model_inp[40:29];
    assign packed_inp[44:33] = model_inp[54:43];
    assign packed_inp[54:45] = model_inp[68:59];
    assign packed_inp[63:55] = model_inp[83:75];
    assign packed_inp[71:64] = model_inp[96:89];
    assign packed_inp[78:72] = model_inp[110:104];
    assign packed_inp[83:79] = model_inp[124:120];
    assign packed_inp[92:84] = model_inp[137:129];
    assign packed_inp[100:93] = model_inp[151:144];
    assign packed_inp[109:101] = model_inp[165:157];
    assign packed_inp[117:110] = model_inp[179:172];
    assign packed_inp[125:118] = model_inp[193:186];
    assign packed_inp[139:126] = model_inp[209:196];
    assign packed_inp[149:140] = model_inp[222:213];

    jsc op (
        .clk(clk),
        .model_inp(packed_inp),
        .model_out(packed_out)
    );

    assign model_out[15:0] = packed_out[15:0];
    assign model_out[16:16] = {1{packed_out[15]}};
    assign model_out[31:17] = packed_out[30:16];
    assign model_out[33:32] = {2{packed_out[30]}};
    assign model_out[50:34] = packed_out[47:31];
    assign model_out[51:51] = 1'b0;
    assign model_out[67:52] = packed_out[63:48];
    assign model_out[68:68] = 1'b0;
    assign model_out[84:69] = packed_out[79:64];

endmodule
