`timescale 1 ns / 1 ps

module jsc_stage25 (
    input [89:0] model_inp,
    output [79:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [15:0] v0; assign v0[15:0] = model_inp[15:0]; // 25.0
    wire [10:0] v1; assign v1[10:0] = model_inp[26:16]; // 25.0
    wire [16:0] v2; shift_adder #(16, 11, 1, 1, 17, 3, 1) op_2 (v0[15:0], v1[10:0], v2[16:0]); // 26.0
    wire [16:0] v3; shift_adder #(17, 8, 1, 0, 17, 0, 0) op_3 (v2[16:0], 8'b10010000, v3[16:0]); // 26.0
    wire [15:0] v4; assign v4[15:0] = model_inp[42:27]; // 25.0
    wire [14:0] v5; assign v5[14:0] = model_inp[57:43]; // 25.0
    wire [15:0] v6; assign v6[15:0] = model_inp[73:58]; // 25.0
    wire [15:0] v7; assign v7[15:0] = model_inp[89:74]; // 25.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[15:0] = v4[15:0];
    assign model_out[30:16] = v5[14:0];
    assign model_out[47:31] = v3[16:0];
    assign model_out[63:48] = v6[15:0];
    assign model_out[79:64] = v7[15:0];

endmodule
