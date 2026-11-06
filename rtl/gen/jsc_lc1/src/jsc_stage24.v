`timescale 1 ns / 1 ps

module jsc_stage24 (
    input [104:0] model_inp,
    output [89:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [15:0] v0; assign v0[15:0] = model_inp[15:0]; // 24.0
    wire [10:0] v1; assign v1[10:0] = model_inp[26:16]; // 24.0
    wire [15:0] v2; shift_adder #(16, 11, 1, 1, 16, 1, 0) op_2 (v0[15:0], v1[10:0], v2[15:0]); // 25.0
    wire [14:0] v3; assign v3[14:0] = model_inp[41:27]; // 24.0
    wire [15:0] v4; assign v4[15:0] = model_inp[57:42]; // 24.0
    wire [15:0] v5; shift_adder #(15, 16, 1, 1, 16, 0, 0) op_5 (v3[14:0], v4[15:0], v5[15:0]); // 25.0
    wire [15:0] v6; assign v6[15:0] = model_inp[73:58]; // 24.0
    wire [14:0] v7; assign v7[14:0] = model_inp[88:74]; // 24.0
    wire [15:0] v8; assign v8[15:0] = model_inp[104:89]; // 24.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[15:0] = v2[15:0];
    assign model_out[26:16] = v1[10:0];
    assign model_out[42:27] = v6[15:0];
    assign model_out[57:43] = v7[14:0];
    assign model_out[73:58] = v5[15:0];
    assign model_out[89:74] = v8[15:0];

endmodule
