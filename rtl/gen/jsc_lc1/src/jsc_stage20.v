`timescale 1 ns / 1 ps

module jsc_stage20 (
    input [301:0] model_inp,
    output [260:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [12:0] v0; assign v0[12:0] = model_inp[12:0]; // 20.0
    wire [8:0] v1; assign v1[8:0] = model_inp[21:13]; // 20.0
    wire [14:0] v2; shift_adder #(13, 9, 1, 1, 15, -2, 1) op_2 (v0[12:0], v1[8:0], v2[14:0]); // 21.0
    wire [11:0] v3; assign v3[11:0] = model_inp[33:22]; // 20.0
    wire [12:0] v4; shift_adder #(9, 12, 1, 1, 13, -3, 0) op_4 (v1[8:0], v3[11:0], v4[12:0]); // 21.0
    wire [7:0] v5; assign v5[7:0] = model_inp[41:34]; // 20.0
    wire [9:0] v6; assign v6[9:0] = model_inp[51:42]; // 20.0
    wire [10:0] v7; shift_adder #(8, 10, 1, 0, 11, -1, 1) op_7 (v5[7:0], v6[9:0], v7[10:0]); // 21.0
    wire [2:0] v8; assign v8[2:0] = model_inp[54:52]; // 20.0
    wire [7:0] v9; assign v9[7:0] = model_inp[62:55]; // 20.0
    wire [8:0] v10; shift_adder #(3, 8, 0, 0, 9, -1, 1) op_10 (v8[2:0], v9[7:0], v10[8:0]); // 21.0
    wire [9:0] v11; assign v11[9:0] = model_inp[72:63]; // 20.0
    wire [9:0] v12; assign v12[9:0] = model_inp[82:73]; // 20.0
    wire [10:0] v13; shift_adder #(10, 10, 1, 1, 11, 0, 0) op_13 (v11[9:0], v12[9:0], v13[10:0]); // 21.0
    wire [11:0] v14; assign v14[11:0] = model_inp[94:83]; // 20.0
    wire [13:0] v15; assign v15[13:0] = model_inp[108:95]; // 20.0
    wire [14:0] v16; shift_adder #(12, 14, 1, 1, 15, -2, 0) op_16 (v14[11:0], v15[13:0], v16[14:0]); // 21.0
    wire [5:0] v17; assign v17[5:0] = model_inp[114:109]; // 20.0
    wire [11:0] v18; assign v18[11:0] = model_inp[126:115]; // 20.0
    wire [11:0] v19; shift_adder #(6, 12, 0, 1, 12, 0, 1) op_19 (v17[5:0], v18[11:0], v19[11:0]); // 21.0
    wire [10:0] v20; assign v20[10:0] = model_inp[137:127]; // 20.0
    wire [5:0] v21; assign v21[5:0] = model_inp[143:138]; // 20.0
    wire [11:0] v22; shift_adder #(11, 6, 1, 0, 12, 2, 1) op_22 (v20[10:0], v21[5:0], v22[11:0]); // 21.0
    wire [11:0] v23; assign v23[11:0] = model_inp[155:144]; // 20.0
    wire [13:0] v24; assign v24[13:0] = model_inp[169:156]; // 20.0
    wire [13:0] v25; shift_adder #(12, 14, 1, 1, 14, 0, 0) op_25 (v23[11:0], v24[13:0], v25[13:0]); // 21.0
    wire [9:0] v26; assign v26[9:0] = model_inp[179:170]; // 20.0
    wire [11:0] v27; shift_adder #(12, 10, 1, 1, 12, 0, 0) op_27 (v23[11:0], v26[9:0], v27[11:0]); // 21.0
    wire [6:0] v28; assign v28[6:0] = model_inp[186:180]; // 20.0
    wire [8:0] v29; shift_adder #(7, 8, 0, 1, 9, 1, 0) op_29 (v28[6:0], v5[7:0], v29[8:0]); // 21.0
    wire [8:0] v30; assign v30[8:0] = model_inp[195:187]; // 20.0
    wire [11:0] v31; assign v31[11:0] = model_inp[207:196]; // 20.0
    wire [12:0] v32; shift_adder #(9, 12, 1, 0, 13, -1, 1) op_32 (v30[8:0], v31[11:0], v32[12:0]); // 21.0
    wire [8:0] v33; shift_adder #(8, 9, 1, 1, 9, 0, 0) op_33 (v5[7:0], v30[8:0], v33[8:0]); // 21.0
    wire [9:0] v34; assign v34[9:0] = model_inp[217:208]; // 20.0
    wire [11:0] v35; assign v35[11:0] = model_inp[229:218]; // 20.0
    wire [11:0] v36; shift_adder #(10, 12, 1, 1, 12, 0, 0) op_36 (v34[9:0], v35[11:0], v36[11:0]); // 21.0
    wire [9:0] v37; assign v37[9:0] = model_inp[239:230]; // 20.0
    wire [11:0] v38; shift_adder #(10, 10, 1, 0, 12, 1, 0) op_38 (v11[9:0], v37[9:0], v38[11:0]); // 21.0
    wire [9:0] v39; assign v39[9:0] = model_inp[249:240]; // 20.0
    wire [7:0] v40; assign v40[7:0] = model_inp[257:250]; // 20.0
    wire [10:0] v41; shift_adder #(10, 8, 1, 1, 11, 2, 1) op_41 (v39[9:0], v40[7:0], v41[10:0]); // 21.0
    wire [12:0] v42; assign v42[12:0] = model_inp[270:258]; // 20.0
    wire [13:0] v43; shift_adder #(13, 12, 1, 1, 14, 2, 0) op_43 (v42[12:0], v14[11:0], v43[13:0]); // 21.0
    wire [12:0] v44; assign v44[12:0] = model_inp[283:271]; // 20.0
    wire [12:0] v45; shift_adder #(7, 13, 0, 1, 13, -2, 1) op_45 (v28[6:0], v44[12:0], v45[12:0]); // 21.0
    wire [4:0] v46; assign v46[4:0] = model_inp[288:284]; // 20.0
    wire [4:0] v47; assign v47[4:0] = model_inp[293:289]; // 20.0
    wire [4:0] v48; assign v48[4:0] = model_inp[298:294]; // 20.0
    wire [2:0] v49; assign v49[2:0] = model_inp[301:299]; // 20.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[14:0] = v2[14:0];
    assign model_out[27:15] = v4[12:0];
    assign model_out[38:28] = v7[10:0];
    assign model_out[47:39] = v10[8:0];
    assign model_out[62:48] = v16[14:0];
    assign model_out[67:63] = v46[4:0];
    assign model_out[79:68] = v19[11:0];
    assign model_out[91:80] = v22[11:0];
    assign model_out[101:92] = v37[9:0];
    assign model_out[115:102] = v25[13:0];
    assign model_out[127:116] = v27[11:0];
    assign model_out[132:128] = v47[4:0];
    assign model_out[141:133] = v29[8:0];
    assign model_out[154:142] = v32[12:0];
    assign model_out[163:155] = v33[8:0];
    assign model_out[175:164] = v36[11:0];
    assign model_out[187:176] = v38[11:0];
    assign model_out[198:188] = v41[10:0];
    assign model_out[208:199] = v12[9:0];
    assign model_out[222:209] = v43[13:0];
    assign model_out[228:223] = v17[5:0];
    assign model_out[241:229] = v45[12:0];
    assign model_out[252:242] = v13[10:0];
    assign model_out[257:253] = v48[4:0];
    assign model_out[260:258] = v49[2:0];

endmodule
