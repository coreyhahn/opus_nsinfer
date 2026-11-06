`timescale 1 ns / 1 ps

module x310_clf_stage21 (
    input [156:0] model_inp,
    output [91:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [10:0] v0; assign v0[10:0] = model_inp[10:0]; // 31.5
    wire [8:0] v1; assign v1[8:0] = model_inp[19:11]; // 31.5
    wire [11:0] v2; shift_adder #(11, 9, 1, 1, 12, 3, 1) op_2 (v0[10:0], v1[8:0], v2[11:0]); // 32.0
    wire [11:0] v3; assign v3[11:0] = model_inp[31:20]; // 31.5
    wire [13:0] v4; assign v4[13:0] = model_inp[45:32]; // 31.5
    wire [14:0] v5; shift_adder #(12, 14, 1, 1, 15, -2, 1) op_5 (v3[11:0], v4[13:0], v5[14:0]); // 32.0
    wire [15:0] v6; assign v6[15:0] = model_inp[61:46]; // 31.5
    wire [10:0] v7; assign v7[10:0] = model_inp[72:62]; // 31.5
    wire [15:0] v8; shift_adder #(16, 11, 1, 1, 16, 1, 1) op_8 (v6[15:0], v7[10:0], v8[15:0]); // 32.0
    wire [12:0] v9; assign v9[12:0] = model_inp[85:73]; // 31.5
    wire [13:0] v10; assign v10[13:0] = model_inp[99:86]; // 31.5
    wire [14:0] v11; shift_adder #(13, 14, 1, 1, 15, 1, 0) op_11 (v9[12:0], v10[13:0], v11[14:0]); // 32.0
    wire [13:0] v12; assign v12[13:0] = model_inp[113:100]; // 31.5
    wire [13:0] v13; assign v13[13:0] = model_inp[127:114]; // 31.5
    wire [14:0] v14; shift_adder #(14, 14, 1, 1, 15, 1, 0) op_14 (v12[13:0], v13[13:0], v14[14:0]); // 32.0
    wire [3:0] v15; assign v15[3:0] = model_inp[131:128]; // 31.5
    wire [10:0] v16; assign v16[10:0] = model_inp[142:132]; // 31.5
    wire [10:0] v17; shift_adder #(4, 11, 0, 1, 11, -1, 0) op_17 (v15[3:0], v16[10:0], v17[10:0]); // 32.0
    wire [13:0] v18; assign v18[13:0] = model_inp[156:143]; // 31.5
    wire [14:0] v19; shift_adder #(14, 12, 1, 1, 15, 1, 0) op_19 (v18[13:0], v2[11:0], v19[14:0]); // 33.0
    wire [14:0] v20; shift_adder #(15, 8, 1, 0, 15, 0, 0) op_20 (v19[14:0], 8'b11000000, v20[14:0]); // 33.0
    wire [16:0] v21; shift_adder #(15, 16, 1, 1, 17, 0, 0) op_21 (v5[14:0], v8[15:0], v21[16:0]); // 33.0
    wire [16:0] v22; shift_adder #(17, 7, 1, 0, 17, 0, 1) op_22 (v21[16:0], 7'b1010000, v22[16:0]); // 33.0
    wire [14:0] v23; shift_adder #(15, 11, 1, 1, 15, 1, 1) op_23 (v11[14:0], v7[10:0], v23[14:0]); // 33.0
    wire [14:0] v24; shift_adder #(15, 11, 1, 1, 15, 2, 1) op_24 (v14[14:0], v17[10:0], v24[14:0]); // 33.0
    wire [12:0] v25; shift_adder #(11, 11, 1, 1, 13, 1, 0) op_25 (v0[10:0], v17[10:0], v25[12:0]); // 33.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[16:0] = v21[16:0];
    assign model_out[31:17] = v23[14:0];
    assign model_out[46:32] = v24[14:0];
    assign model_out[59:47] = v25[12:0];
    assign model_out[74:60] = v20[14:0];
    assign model_out[91:75] = v22[16:0];

endmodule
