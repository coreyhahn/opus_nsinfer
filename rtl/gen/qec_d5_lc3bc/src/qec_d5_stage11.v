`timescale 1 ns / 1 ps

module qec_d5_stage11 (
    input [239:0] model_inp,
    output [57:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [17:0] v0; assign v0[17:0] = model_inp[17:0]; // 33.0
    wire [15:0] v1; assign v1[15:0] = model_inp[33:18]; // 33.0
    wire [18:0] v2; shift_adder #(18, 16, 1, 1, 19, 2, 0) op_2 (v0[17:0], v1[15:0], v2[18:0]); // 34.0
    wire [14:0] v3; assign v3[14:0] = model_inp[48:34]; // 33.0
    wire [12:0] v4; assign v4[12:0] = model_inp[61:49]; // 33.0
    wire [16:0] v5; shift_adder #(15, 13, 1, 1, 17, 3, 0) op_5 (v3[14:0], v4[12:0], v5[16:0]); // 34.0
    wire [14:0] v6; assign v6[14:0] = model_inp[76:62]; // 33.0
    wire [15:0] v7; assign v7[15:0] = model_inp[92:77]; // 33.0
    wire [17:0] v8; shift_adder #(15, 16, 1, 0, 18, -3, 1) op_8 (v6[14:0], v7[15:0], v8[17:0]); // 34.0
    wire [14:0] v9; assign v9[14:0] = model_inp[107:93]; // 33.0
    wire [14:0] v10; assign v10[14:0] = model_inp[122:108]; // 33.0
    wire [16:0] v11; shift_adder #(15, 15, 1, 1, 17, -2, 0) op_11 (v9[14:0], v10[14:0], v11[16:0]); // 34.0
    wire [15:0] v12; assign v12[15:0] = model_inp[138:123]; // 33.0
    wire [15:0] v13; assign v13[15:0] = model_inp[154:139]; // 33.0
    wire [16:0] v14; shift_adder #(16, 16, 1, 1, 17, 1, 0) op_14 (v12[15:0], v13[15:0], v14[16:0]); // 34.0
    wire [14:0] v15; assign v15[14:0] = model_inp[169:155]; // 33.0
    wire [13:0] v16; assign v16[13:0] = model_inp[183:170]; // 33.0
    wire [16:0] v17; shift_adder #(15, 14, 1, 1, 17, 3, 0) op_17 (v15[14:0], v16[13:0], v17[16:0]); // 34.0
    wire [14:0] v18; assign v18[14:0] = model_inp[198:184]; // 33.0
    wire [11:0] v19; assign v19[11:0] = model_inp[210:199]; // 33.0
    wire [16:0] v20; shift_adder #(15, 12, 1, 1, 17, 5, 1) op_20 (v18[14:0], v19[11:0], v20[16:0]); // 34.0
    wire [14:0] v21; assign v21[14:0] = model_inp[225:211]; // 33.0
    wire [15:0] v22; shift_adder #(15, 15, 1, 1, 16, -1, 0) op_22 (v10[14:0], v21[14:0], v22[15:0]); // 34.0
    wire [19:0] v23; shift_adder #(19, 17, 1, 1, 20, 2, 0) op_23 (v2[18:0], v5[16:0], v23[19:0]); // 35.0
    wire [18:0] v24; shift_adder #(18, 17, 1, 1, 19, -1, 1) op_24 (v8[17:0], v11[16:0], v24[18:0]); // 35.0
    wire [13:0] v25; assign v25[13:0] = model_inp[239:226]; // 33.0
    wire [18:0] v26; shift_adder #(17, 14, 1, 1, 19, 4, 1) op_26 (v14[16:0], v25[13:0], v26[18:0]); // 35.0
    wire [17:0] v27; shift_adder #(17, 17, 1, 1, 18, 0, 0) op_27 (v17[16:0], v20[16:0], v27[17:0]); // 35.0
    wire [17:0] v28; shift_adder #(17, 16, 1, 1, 18, -1, 0) op_28 (v17[16:0], v22[15:0], v28[17:0]); // 35.0
    wire [20:0] v29; shift_adder #(20, 19, 1, 1, 21, -1, 0) op_29 (v23[19:0], v24[18:0], v29[20:0]); // 36.0
    wire [18:0] v30; shift_adder #(19, 18, 1, 1, 19, 0, 0) op_30 (v26[18:0], v27[17:0], v30[18:0]); // 36.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[18:0] = v30[18:0];
    assign model_out[36:19] = v28[17:0];
    assign model_out[57:37] = v29[20:0];

endmodule
