`timescale 1 ns / 1 ps

module qec_d3_stage5 (
    input [65:0] model_inp,
    output [17:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [12:0] v0; assign v0[12:0] = model_inp[12:0]; // 25.0
    wire [9:0] v1; assign v1[9:0] = model_inp[22:13]; // 25.0
    wire [17:0] v2; shift_adder #(13, 10, 1, 0, 18, 7, 1) op_2 (v0[12:0], v1[9:0], v2[17:0]); // 26.0
    wire [7:0] v3; assign v3[7:0] = model_inp[30:23]; // 25.0
    wire [7:0] v4; assign v4[7:0] = model_inp[38:31]; // 25.0
    wire [9:0] v5; shift_adder #(8, 8, 0, 0, 10, 1, 0) op_5 (v3[7:0], v4[7:0], v5[9:0]); // 26.0
    wire [13:0] v6; assign v6[13:0] = model_inp[52:39]; // 25.0
    wire [13:0] v7; shift_adder #(10, 14, 0, 1, 14, -3, 0) op_7 (v1[9:0], v6[13:0], v7[13:0]); // 26.0
    wire [17:0] v8; shift_adder #(18, 10, 1, 0, 18, 6, 0) op_8 (v2[17:0], v5[9:0], v8[17:0]); // 27.0
    wire [12:0] v9; assign v9[12:0] = model_inp[65:53]; // 25.0
    wire [16:0] v10; shift_adder #(14, 13, 1, 0, 17, 2, 1) op_10 (v7[13:0], v9[12:0], v10[16:0]); // 27.0
    wire [16:0] v11; shift_adder #(17, 10, 1, 0, 17, 0, 1) op_11 (v10[16:0], v5[9:0], v11[16:0]); // 28.0
    wire [17:0] v12; shift_adder #(18, 17, 1, 1, 18, 0, 0) op_12 (v8[17:0], v11[16:0], v12[17:0]); // 29.0
    wire [17:0] v13; shift_adder #(18, 10, 1, 0, 18, 0, 1) op_13 (v12[17:0], 10'b1011100000, v13[17:0]); // 29.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[17:0] = v13[17:0];

endmodule
