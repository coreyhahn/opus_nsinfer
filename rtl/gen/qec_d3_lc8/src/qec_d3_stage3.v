`timescale 1 ns / 1 ps

module qec_d3_stage3 (
    input [91:0] model_inp,
    output [17:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [9:0] v0; assign v0[9:0] = model_inp[9:0]; // 24.0
    wire [11:0] v1; assign v1[11:0] = model_inp[21:10]; // 24.0
    wire [12:0] v2; shift_adder #(10, 12, 1, 0, 13, -3, 1) op_2 (v0[9:0], v1[11:0], v2[12:0]); // 25.0
    wire [5:0] v3; assign v3[5:0] = model_inp[27:22]; // 24.0
    wire [8:0] v4; assign v4[8:0] = model_inp[36:28]; // 24.0
    wire [9:0] v5; shift_adder #(6, 9, 0, 0, 10, 0, 0) op_5 (v3[5:0], v4[8:0], v5[9:0]); // 25.0
    wire [14:0] v6; assign v6[14:0] = model_inp[51:37]; // 24.0
    wire [14:0] v7; assign v7[14:0] = model_inp[66:52]; // 24.0
    wire [15:0] v8; shift_adder #(15, 15, 1, 1, 16, 0, 1) op_8 (v6[14:0], v7[14:0], v8[15:0]); // 25.0
    wire [15:0] v9; shift_adder #(16, 5, 1, 0, 16, 0, 1) op_9 (v8[15:0], 5'b11000, v9[15:0]); // 25.0
    wire [14:0] v10; assign v10[14:0] = v9[14:0] & {15{~v9[15]}}; // 25.0
    wire [14:0] v11; shift_adder #(15, 5, 0, 0, 15, 0, 0) op_11 (v10[14:0], 5'b10000, v11[14:0]); // 25.0
    wire [7:0] v12; assign v12[7:0] = v11[12:5]; // 25.0
    wire [8:0] v13; assign v13[8:0] = model_inp[75:67]; // 24.0
    wire [7:0] v14; assign v14[7:0] = model_inp[83:76]; // 24.0
    wire [13:0] v15; shift_adder #(9, 8, 0, 0, 14, 5, 1) op_15 (v13[8:0], v14[7:0], v15[13:0]); // 25.0
    wire [12:0] v16; shift_adder #(9, 12, 0, 0, 13, -3, 0) op_16 (v13[8:0], v1[11:0], v16[12:0]); // 25.0
    wire [17:0] v17; shift_adder #(13, 10, 1, 0, 18, 7, 1) op_17 (v2[12:0], v5[9:0], v17[17:0]); // 26.0
    wire [7:0] v18; assign v18[7:0] = model_inp[91:84]; // 24.0
    wire [9:0] v19; shift_adder #(8, 8, 0, 0, 10, 1, 0) op_19 (v18[7:0], v12[7:0], v19[9:0]); // 26.0
    wire [13:0] v20; shift_adder #(10, 14, 0, 1, 14, -3, 0) op_20 (v5[9:0], v15[13:0], v20[13:0]); // 26.0
    wire [17:0] v21; shift_adder #(18, 10, 1, 0, 18, 6, 0) op_21 (v17[17:0], v19[9:0], v21[17:0]); // 27.0
    wire [16:0] v22; shift_adder #(14, 13, 1, 0, 17, 2, 1) op_22 (v20[13:0], v16[12:0], v22[16:0]); // 27.0
    wire [16:0] v23; shift_adder #(17, 10, 1, 0, 17, 0, 1) op_23 (v22[16:0], v19[9:0], v23[16:0]); // 28.0
    wire [17:0] v24; shift_adder #(18, 17, 1, 1, 18, 0, 0) op_24 (v21[17:0], v23[16:0], v24[17:0]); // 29.0
    wire [17:0] v25; shift_adder #(18, 10, 1, 0, 18, 0, 1) op_25 (v24[17:0], 10'b1011100000, v25[17:0]); // 29.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[17:0] = v25[17:0];

endmodule
