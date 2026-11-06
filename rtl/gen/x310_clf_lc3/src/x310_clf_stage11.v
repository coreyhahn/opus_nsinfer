`timescale 1 ns / 1 ps

module x310_clf_stage11 (
    input [91:0] model_inp,
    output [64:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [16:0] v0; assign v0[16:0] = model_inp[16:0]; // 33.0
    wire [14:0] v1; assign v1[14:0] = model_inp[31:17]; // 33.0
    wire [16:0] v2; shift_adder #(17, 15, 1, 1, 17, 1, 0) op_2 (v0[16:0], v1[14:0], v2[16:0]); // 34.0
    wire [16:0] v3; shift_adder #(17, 8, 1, 0, 17, 0, 1) op_3 (v2[16:0], 8'b10001000, v3[16:0]); // 34.0
    wire [14:0] v4; assign v4[14:0] = model_inp[46:32]; // 33.0
    wire [12:0] v5; assign v5[12:0] = model_inp[59:47]; // 33.0
    wire [15:0] v6; shift_adder #(15, 13, 1, 1, 16, 3, 0) op_6 (v4[14:0], v5[12:0], v6[15:0]); // 34.0
    wire [15:0] v7; shift_adder #(16, 7, 1, 0, 16, 0, 1) op_7 (v6[15:0], 7'b1100000, v7[15:0]); // 34.0
    wire [14:0] v8; assign v8[14:0] = model_inp[74:60]; // 33.0
    wire [16:0] v9; assign v9[16:0] = model_inp[91:75]; // 33.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[14:0] = v8[14:0];
    assign model_out[31:15] = v9[16:0];
    assign model_out[48:32] = v3[16:0];
    assign model_out[64:49] = v7[15:0];

endmodule
