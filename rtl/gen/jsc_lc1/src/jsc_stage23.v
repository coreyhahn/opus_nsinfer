`timescale 1 ns / 1 ps

module jsc_stage23 (
    input [134:0] model_inp,
    output [104:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [15:0] v0; assign v0[15:0] = model_inp[15:0]; // 23.0
    wire [13:0] v1; assign v1[13:0] = model_inp[29:16]; // 23.0
    wire [15:0] v2; shift_adder #(16, 14, 1, 1, 16, 1, 0) op_2 (v0[15:0], v1[13:0], v2[15:0]); // 24.0
    wire [15:0] v3; shift_adder #(16, 6, 1, 0, 16, 0, 1) op_3 (v2[15:0], 6'b111000, v3[15:0]); // 24.0
    wire [14:0] v4; assign v4[14:0] = model_inp[44:30]; // 23.0
    wire [14:0] v5; assign v5[14:0] = model_inp[59:45]; // 23.0
    wire [14:0] v6; shift_adder #(15, 15, 1, 1, 15, 0, 0) op_6 (v4[14:0], v5[14:0], v6[14:0]); // 24.0
    wire [2:0] v7; assign v7[2:0] = model_inp[62:60]; // 23.0
    wire [9:0] v8; assign v8[9:0] = model_inp[72:63]; // 23.0
    wire [10:0] v9; shift_adder #(3, 10, 0, 1, 11, -5, 0) op_9 (v7[2:0], v8[9:0], v9[10:0]); // 24.0
    wire [14:0] v10; assign v10[14:0] = model_inp[87:73]; // 23.0
    wire [15:0] v11; assign v11[15:0] = model_inp[103:88]; // 23.0
    wire [15:0] v12; shift_adder #(15, 16, 1, 1, 16, 0, 0) op_12 (v10[14:0], v11[15:0], v12[15:0]); // 24.0
    wire [15:0] v13; shift_adder #(16, 7, 1, 0, 16, 0, 1) op_13 (v12[15:0], 7'b1000000, v13[15:0]); // 24.0
    wire [15:0] v14; assign v14[15:0] = model_inp[119:104]; // 23.0
    wire [14:0] v15; assign v15[14:0] = model_inp[134:120]; // 23.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[15:0] = v14[15:0];
    assign model_out[26:16] = v9[10:0];
    assign model_out[41:27] = v15[14:0];
    assign model_out[57:42] = v12[15:0];
    assign model_out[73:58] = v3[15:0];
    assign model_out[88:74] = v6[14:0];
    assign model_out[104:89] = v13[15:0];

endmodule
