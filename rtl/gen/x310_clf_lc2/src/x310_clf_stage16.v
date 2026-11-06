`timescale 1 ns / 1 ps

module x310_clf_stage16 (
    input [119:0] model_inp,
    output [64:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [13:0] v0; assign v0[13:0] = model_inp[13:0]; // 32.0
    wire [11:0] v1; assign v1[11:0] = model_inp[25:14]; // 32.0
    wire [14:0] v2; shift_adder #(14, 12, 1, 1, 15, 1, 0) op_2 (v0[13:0], v1[11:0], v2[14:0]); // 33.0
    wire [14:0] v3; shift_adder #(15, 8, 1, 0, 15, 0, 0) op_3 (v2[14:0], 8'b11000000, v3[14:0]); // 33.0
    wire [14:0] v4; assign v4[14:0] = model_inp[40:26]; // 32.0
    wire [15:0] v5; assign v5[15:0] = model_inp[56:41]; // 32.0
    wire [16:0] v6; shift_adder #(15, 16, 1, 1, 17, 0, 0) op_6 (v4[14:0], v5[15:0], v6[16:0]); // 33.0
    wire [16:0] v7; shift_adder #(17, 7, 1, 0, 17, 0, 1) op_7 (v6[16:0], 7'b1010000, v7[16:0]); // 33.0
    wire [14:0] v8; assign v8[14:0] = model_inp[71:57]; // 32.0
    wire [10:0] v9; assign v9[10:0] = model_inp[82:72]; // 32.0
    wire [14:0] v10; shift_adder #(15, 11, 1, 1, 15, 1, 1) op_10 (v8[14:0], v9[10:0], v10[14:0]); // 33.0
    wire [14:0] v11; assign v11[14:0] = model_inp[97:83]; // 32.0
    wire [10:0] v12; assign v12[10:0] = model_inp[108:98]; // 32.0
    wire [14:0] v13; shift_adder #(15, 11, 1, 1, 15, 2, 1) op_13 (v11[14:0], v12[10:0], v13[14:0]); // 33.0
    wire [10:0] v14; assign v14[10:0] = model_inp[119:109]; // 32.0
    wire [12:0] v15; shift_adder #(11, 11, 1, 1, 13, 1, 0) op_15 (v14[10:0], v12[10:0], v15[12:0]); // 33.0
    wire [16:0] v16; shift_adder #(17, 15, 1, 1, 17, 1, 0) op_16 (v6[16:0], v10[14:0], v16[16:0]); // 34.0
    wire [16:0] v17; shift_adder #(17, 8, 1, 0, 17, 0, 1) op_17 (v16[16:0], 8'b10001000, v17[16:0]); // 34.0
    wire [15:0] v18; shift_adder #(15, 13, 1, 1, 16, 3, 0) op_18 (v13[14:0], v15[12:0], v18[15:0]); // 34.0
    wire [15:0] v19; shift_adder #(16, 7, 1, 0, 16, 0, 1) op_19 (v18[15:0], 7'b1100000, v19[15:0]); // 34.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[14:0] = v3[14:0];
    assign model_out[31:15] = v7[16:0];
    assign model_out[48:32] = v17[16:0];
    assign model_out[64:49] = v19[15:0];

endmodule
