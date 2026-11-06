`timescale 1 ns / 1 ps

module jsc_stage22 (
    input [183:0] model_inp,
    output [134:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [12:0] v0; assign v0[12:0] = model_inp[12:0]; // 22.0
    wire [10:0] v1; assign v1[10:0] = model_inp[23:13]; // 22.0
    wire [13:0] v2; shift_adder #(13, 11, 1, 1, 14, 1, 1) op_2 (v0[12:0], v1[10:0], v2[13:0]); // 23.0
    wire [11:0] v3; assign v3[11:0] = model_inp[35:24]; // 22.0
    wire [13:0] v4; assign v4[13:0] = model_inp[49:36]; // 22.0
    wire [14:0] v5; shift_adder #(12, 14, 1, 1, 15, -2, 0) op_5 (v3[11:0], v4[13:0], v5[14:0]); // 23.0
    wire [15:0] v6; assign v6[15:0] = model_inp[65:50]; // 22.0
    wire [15:0] v7; shift_adder #(16, 12, 1, 1, 16, 2, 1) op_7 (v6[15:0], v3[11:0], v7[15:0]); // 23.0
    wire [4:0] v8; assign v8[4:0] = model_inp[70:66]; // 22.0
    wire [9:0] v9; assign v9[9:0] = model_inp[80:71]; // 22.0
    wire [9:0] v10; shift_adder #(5, 10, 0, 1, 10, -2, 1) op_10 (v8[4:0], v9[9:0], v10[9:0]); // 23.0
    wire [13:0] v11; assign v11[13:0] = model_inp[94:81]; // 22.0
    wire [14:0] v12; assign v12[14:0] = model_inp[109:95]; // 22.0
    wire [14:0] v13; shift_adder #(14, 15, 1, 1, 15, 0, 0) op_13 (v11[13:0], v12[14:0], v13[14:0]); // 23.0
    wire [12:0] v14; assign v14[12:0] = model_inp[122:110]; // 22.0
    wire [13:0] v15; assign v15[13:0] = model_inp[136:123]; // 22.0
    wire [14:0] v16; shift_adder #(13, 14, 1, 1, 15, 0, 0) op_16 (v14[12:0], v15[13:0], v16[14:0]); // 23.0
    wire [12:0] v17; assign v17[12:0] = model_inp[149:137]; // 22.0
    wire [15:0] v18; shift_adder #(13, 13, 1, 1, 16, -3, 1) op_18 (v17[12:0], v17[12:0], v18[15:0]); // 23.0
    wire [15:0] v19; assign v19[15:0] = model_inp[165:150]; // 22.0
    wire [14:0] v20; assign v20[14:0] = model_inp[180:166]; // 22.0
    wire [2:0] v21; assign v21[2:0] = model_inp[183:181]; // 22.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[15:0] = v19[15:0];
    assign model_out[29:16] = v2[13:0];
    assign model_out[44:30] = v20[14:0];
    assign model_out[59:45] = v5[14:0];
    assign model_out[62:60] = v21[2:0];
    assign model_out[72:63] = v10[9:0];
    assign model_out[87:73] = v16[14:0];
    assign model_out[103:88] = v18[15:0];
    assign model_out[119:104] = v7[15:0];
    assign model_out[134:120] = v13[14:0];

endmodule
