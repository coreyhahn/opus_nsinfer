`timescale 1 ns / 1 ps

module jsc_stage21 (
    input [260:0] model_inp,
    output [183:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [14:0] v0; assign v0[14:0] = model_inp[14:0]; // 21.0
    wire [12:0] v1; assign v1[12:0] = model_inp[27:15]; // 21.0
    wire [15:0] v2; shift_adder #(15, 13, 1, 1, 16, 1, 0) op_2 (v0[14:0], v1[12:0], v2[15:0]); // 22.0
    wire [10:0] v3; assign v3[10:0] = model_inp[38:28]; // 21.0
    wire [8:0] v4; assign v4[8:0] = model_inp[47:39]; // 21.0
    wire [12:0] v5; shift_adder #(11, 9, 1, 1, 13, 4, 0) op_5 (v3[10:0], v4[8:0], v5[12:0]); // 22.0
    wire [14:0] v6; assign v6[14:0] = model_inp[62:48]; // 21.0
    wire [14:0] v7; shift_adder #(15, 9, 1, 1, 15, 2, 1) op_7 (v6[14:0], v4[8:0], v7[14:0]); // 22.0
    wire [4:0] v8; assign v8[4:0] = model_inp[67:63]; // 21.0
    wire [11:0] v9; assign v9[11:0] = model_inp[79:68]; // 21.0
    wire [11:0] v10; shift_adder #(5, 12, 0, 1, 12, 0, 0) op_10 (v8[4:0], v9[11:0], v10[11:0]); // 22.0
    wire [11:0] v11; assign v11[11:0] = model_inp[91:80]; // 21.0
    wire [9:0] v12; assign v12[9:0] = model_inp[101:92]; // 21.0
    wire [13:0] v13; shift_adder #(12, 10, 1, 0, 14, -2, 1) op_13 (v11[11:0], v12[9:0], v13[13:0]); // 22.0
    wire [13:0] v14; assign v14[13:0] = model_inp[115:102]; // 21.0
    wire [11:0] v15; assign v15[11:0] = model_inp[127:116]; // 21.0
    wire [15:0] v16; shift_adder #(14, 12, 1, 1, 16, 4, 1) op_16 (v14[13:0], v15[11:0], v16[15:0]); // 22.0
    wire [4:0] v17; assign v17[4:0] = model_inp[132:128]; // 21.0
    wire [8:0] v18; assign v18[8:0] = model_inp[141:133]; // 21.0
    wire [9:0] v19; shift_adder #(5, 9, 0, 1, 10, -1, 1) op_19 (v17[4:0], v18[8:0], v19[9:0]); // 22.0
    wire [12:0] v20; assign v20[12:0] = model_inp[154:142]; // 21.0
    wire [8:0] v21; assign v21[8:0] = model_inp[163:155]; // 21.0
    wire [13:0] v22; shift_adder #(13, 9, 1, 1, 14, -1, 1) op_22 (v20[12:0], v21[8:0], v22[13:0]); // 22.0
    wire [11:0] v23; assign v23[11:0] = model_inp[175:164]; // 21.0
    wire [11:0] v24; assign v24[11:0] = model_inp[187:176]; // 21.0
    wire [14:0] v25; shift_adder #(12, 12, 1, 1, 15, 2, 0) op_25 (v23[11:0], v24[11:0], v25[14:0]); // 22.0
    wire [10:0] v26; assign v26[10:0] = model_inp[198:188]; // 21.0
    wire [9:0] v27; assign v27[9:0] = model_inp[208:199]; // 21.0
    wire [12:0] v28; shift_adder #(11, 10, 1, 1, 13, -1, 1) op_28 (v26[10:0], v27[9:0], v28[12:0]); // 22.0
    wire [13:0] v29; assign v29[13:0] = model_inp[222:209]; // 21.0
    wire [13:0] v30; shift_adder #(14, 9, 1, 1, 14, 0, 1) op_30 (v29[13:0], v18[8:0], v30[13:0]); // 22.0
    wire [5:0] v31; assign v31[5:0] = model_inp[228:223]; // 21.0
    wire [12:0] v32; assign v32[12:0] = model_inp[241:229]; // 21.0
    wire [12:0] v33; shift_adder #(6, 13, 0, 1, 13, 0, 0) op_33 (v31[5:0], v32[12:0], v33[12:0]); // 22.0
    wire [10:0] v34; assign v34[10:0] = model_inp[252:242]; // 21.0
    wire [4:0] v35; assign v35[4:0] = model_inp[257:253]; // 21.0
    wire [2:0] v36; assign v36[2:0] = model_inp[260:258]; // 21.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[12:0] = v5[12:0];
    assign model_out[23:13] = v34[10:0];
    assign model_out[35:24] = v10[11:0];
    assign model_out[49:36] = v13[13:0];
    assign model_out[65:50] = v16[15:0];
    assign model_out[70:66] = v35[4:0];
    assign model_out[80:71] = v19[9:0];
    assign model_out[94:81] = v22[13:0];
    assign model_out[109:95] = v25[14:0];
    assign model_out[122:110] = v28[12:0];
    assign model_out[136:123] = v30[13:0];
    assign model_out[149:137] = v33[12:0];
    assign model_out[165:150] = v2[15:0];
    assign model_out[180:166] = v7[14:0];
    assign model_out[183:181] = v36[2:0];

endmodule
