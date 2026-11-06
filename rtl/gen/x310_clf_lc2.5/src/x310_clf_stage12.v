`timescale 1 ns / 1 ps

module x310_clf_stage12 (
    input [221:0] model_inp,
    output [119:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [12:0] v0; assign v0[12:0] = model_inp[12:0]; // 30.0
    wire [11:0] v1; assign v1[11:0] = model_inp[24:13]; // 30.0
    wire [13:0] v2; shift_adder #(13, 12, 1, 1, 14, 1, 0) op_2 (v0[12:0], v1[11:0], v2[13:0]); // 31.0
    wire [5:0] v3; assign v3[5:0] = model_inp[30:25]; // 30.0
    wire [9:0] v4; assign v4[9:0] = model_inp[40:31]; // 30.0
    wire [10:0] v5; shift_adder #(6, 10, 0, 1, 11, -3, 0) op_5 (v3[5:0], v4[9:0], v5[10:0]); // 31.0
    wire [9:0] v6; assign v6[9:0] = model_inp[50:41]; // 30.0
    wire [10:0] v7; assign v7[10:0] = model_inp[61:51]; // 30.0
    wire [11:0] v8; shift_adder #(10, 11, 1, 1, 12, -2, 1) op_8 (v6[9:0], v7[10:0], v8[11:0]); // 31.0
    wire [13:0] v9; assign v9[13:0] = model_inp[75:62]; // 30.0
    wire [14:0] v10; assign v10[14:0] = model_inp[90:76]; // 30.0
    wire [15:0] v11; shift_adder #(14, 15, 1, 1, 16, -1, 0) op_11 (v9[13:0], v10[14:0], v11[15:0]); // 31.0
    wire [4:0] v12; assign v12[4:0] = model_inp[95:91]; // 30.0
    wire [10:0] v13; assign v13[10:0] = model_inp[106:96]; // 30.0
    wire [10:0] v14; shift_adder #(5, 11, 0, 1, 11, -3, 1) op_14 (v12[4:0], v13[10:0], v14[10:0]); // 31.0
    wire [11:0] v15; assign v15[11:0] = model_inp[118:107]; // 30.0
    wire [10:0] v16; assign v16[10:0] = model_inp[129:119]; // 30.0
    wire [12:0] v17; shift_adder #(12, 11, 1, 0, 13, 1, 1) op_17 (v15[11:0], v16[10:0], v17[12:0]); // 31.0
    wire [13:0] v18; assign v18[13:0] = model_inp[143:130]; // 30.0
    wire [13:0] v19; shift_adder #(14, 10, 1, 1, 14, 1, 1) op_19 (v18[13:0], v6[9:0], v19[13:0]); // 31.0
    wire [13:0] v20; assign v20[13:0] = model_inp[157:144]; // 30.0
    wire [8:0] v21; assign v21[8:0] = model_inp[166:158]; // 30.0
    wire [13:0] v22; shift_adder #(14, 9, 1, 1, 14, 3, 1) op_22 (v20[13:0], v21[8:0], v22[13:0]); // 31.0
    wire [12:0] v23; assign v23[12:0] = model_inp[179:167]; // 30.0
    wire [8:0] v24; assign v24[8:0] = model_inp[188:180]; // 30.0
    wire [13:0] v25; shift_adder #(13, 9, 1, 1, 14, 4, 1) op_25 (v23[12:0], v24[8:0], v25[13:0]); // 31.0
    wire [4:0] v26; assign v26[4:0] = model_inp[193:189]; // 30.0
    wire [9:0] v27; assign v27[9:0] = model_inp[203:194]; // 30.0
    wire [10:0] v28; shift_adder #(5, 10, 0, 1, 11, -2, 0) op_28 (v26[4:0], v27[9:0], v28[10:0]); // 31.0
    wire [11:0] v29; shift_adder #(11, 9, 1, 1, 12, 3, 1) op_29 (v5[10:0], v24[8:0], v29[11:0]); // 32.0
    wire [13:0] v30; assign v30[13:0] = model_inp[217:204]; // 30.0
    wire [14:0] v31; shift_adder #(12, 14, 1, 1, 15, -2, 1) op_31 (v8[11:0], v30[13:0], v31[14:0]); // 32.0
    wire [15:0] v32; shift_adder #(16, 11, 1, 1, 16, 1, 1) op_32 (v11[15:0], v14[10:0], v32[15:0]); // 32.0
    wire [14:0] v33; shift_adder #(13, 14, 1, 1, 15, 1, 0) op_33 (v17[12:0], v19[13:0], v33[14:0]); // 32.0
    wire [14:0] v34; shift_adder #(14, 14, 1, 1, 15, 1, 0) op_34 (v22[13:0], v25[13:0], v34[14:0]); // 32.0
    wire [3:0] v35; assign v35[3:0] = model_inp[221:218]; // 30.0
    wire [10:0] v36; shift_adder #(4, 11, 0, 1, 11, -1, 0) op_36 (v35[3:0], v28[10:0], v36[10:0]); // 32.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[13:0] = v2[13:0];
    assign model_out[25:14] = v29[11:0];
    assign model_out[40:26] = v31[14:0];
    assign model_out[56:41] = v32[15:0];
    assign model_out[71:57] = v33[14:0];
    assign model_out[82:72] = v14[10:0];
    assign model_out[97:83] = v34[14:0];
    assign model_out[108:98] = v36[10:0];
    assign model_out[119:109] = v5[10:0];

endmodule
