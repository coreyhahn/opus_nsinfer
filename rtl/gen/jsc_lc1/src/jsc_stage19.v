`timescale 1 ns / 1 ps

module jsc_stage19 (
    input [301:0] model_inp,
    output [301:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [12:0] v0; assign v0[12:0] = model_inp[12:0]; // 19.0
    wire [9:0] v1; assign v1[9:0] = model_inp[22:13]; // 19.0
    wire [12:0] v2; shift_adder #(13, 10, 1, 0, 13, 1, 0) op_2 (v0[12:0], v1[9:0], v2[12:0]); // 20.0
    wire [6:0] v3; assign v3[6:0] = model_inp[29:23]; // 19.0
    wire [7:0] v4; assign v4[7:0] = model_inp[37:30]; // 19.0
    wire [8:0] v5; shift_adder #(7, 8, 0, 1, 9, 0, 1) op_5 (v3[6:0], v4[7:0], v5[8:0]); // 20.0
    wire [8:0] v6; assign v6[8:0] = model_inp[46:38]; // 19.0
    wire [11:0] v7; shift_adder #(10, 9, 0, 0, 12, 2, 1) op_7 (v1[9:0], v6[8:0], v7[11:0]); // 20.0
    wire [5:0] v8; assign v8[5:0] = model_inp[52:47]; // 19.0
    wire [4:0] v9; assign v9[4:0] = model_inp[57:53]; // 19.0
    wire [7:0] v10; shift_adder #(6, 5, 0, 0, 8, 2, 1) op_10 (v8[5:0], v9[4:0], v10[7:0]); // 20.0
    wire [6:0] v11; assign v11[6:0] = model_inp[64:58]; // 19.0
    wire [7:0] v12; shift_adder #(7, 6, 0, 0, 8, 0, 0) op_12 (v11[6:0], v8[5:0], v12[7:0]); // 20.0
    wire [2:0] v13; assign v13[2:0] = model_inp[67:65]; // 19.0
    wire [9:0] v14; assign v14[9:0] = model_inp[77:68]; // 19.0
    wire [9:0] v15; shift_adder #(3, 10, 0, 1, 10, -1, 1) op_15 (v13[2:0], v14[9:0], v15[9:0]); // 20.0
    wire [2:0] v16; assign v16[2:0] = model_inp[80:78]; // 19.0
    wire [6:0] v17; assign v17[6:0] = model_inp[87:81]; // 19.0
    wire [9:0] v18; shift_adder #(3, 7, 0, 0, 10, -6, 1) op_18 (v16[2:0], v17[6:0], v18[9:0]); // 20.0
    wire [7:0] v19; assign v19[7:0] = model_inp[95:88]; // 19.0
    wire [8:0] v20; assign v20[8:0] = model_inp[104:96]; // 19.0
    wire [11:0] v21; shift_adder #(8, 9, 0, 1, 12, 2, 1) op_21 (v19[7:0], v20[8:0], v21[11:0]); // 20.0
    wire [8:0] v22; assign v22[8:0] = model_inp[113:105]; // 19.0
    wire [9:0] v23; assign v23[9:0] = model_inp[123:114]; // 19.0
    wire [13:0] v24; shift_adder #(9, 10, 0, 0, 14, -4, 1) op_24 (v22[8:0], v23[9:0], v24[13:0]); // 20.0
    wire [11:0] v25; shift_adder #(7, 9, 0, 1, 12, -3, 1) op_25 (v11[6:0], v20[8:0], v25[11:0]); // 20.0
    wire [10:0] v26; assign v26[10:0] = model_inp[134:124]; // 19.0
    wire [6:0] v27; assign v27[6:0] = model_inp[141:135]; // 19.0
    wire [10:0] v28; shift_adder #(11, 7, 1, 0, 11, 2, 1) op_28 (v26[10:0], v27[6:0], v28[10:0]); // 20.0
    wire [6:0] v29; assign v29[6:0] = model_inp[148:142]; // 19.0
    wire [9:0] v30; shift_adder #(7, 10, 0, 0, 10, -1, 0) op_30 (v29[6:0], v1[9:0], v30[9:0]); // 20.0
    wire [4:0] v31; assign v31[4:0] = model_inp[153:149]; // 19.0
    wire [10:0] v32; assign v32[10:0] = model_inp[164:154]; // 19.0
    wire [11:0] v33; shift_adder #(5, 11, 0, 1, 12, -2, 1) op_33 (v31[4:0], v32[10:0], v33[11:0]); // 20.0
    wire [11:0] v34; assign v34[11:0] = model_inp[176:165]; // 19.0
    wire [6:0] v35; assign v35[6:0] = model_inp[183:177]; // 19.0
    wire [13:0] v36; shift_adder #(12, 7, 1, 0, 14, -2, 1) op_36 (v34[11:0], v35[6:0], v36[13:0]); // 20.0
    wire [7:0] v37; assign v37[7:0] = model_inp[191:184]; // 19.0
    wire [9:0] v38; shift_adder #(6, 8, 0, 1, 10, -2, 0) op_38 (v8[5:0], v37[7:0], v38[9:0]); // 20.0
    wire [3:0] v39; assign v39[3:0] = model_inp[195:192]; // 19.0
    wire [7:0] v40; assign v40[7:0] = model_inp[203:196]; // 19.0
    wire [8:0] v41; shift_adder #(4, 8, 0, 1, 9, -2, 0) op_41 (v39[3:0], v40[7:0], v41[8:0]); // 20.0
    wire [9:0] v42; assign v42[9:0] = model_inp[213:204]; // 19.0
    wire [9:0] v43; shift_adder #(7, 10, 0, 1, 10, 0, 0) op_43 (v17[6:0], v42[9:0], v43[9:0]); // 20.0
    wire [10:0] v44; assign v44[10:0] = model_inp[224:214]; // 19.0
    wire [7:0] v45; assign v45[7:0] = model_inp[232:225]; // 19.0
    wire [11:0] v46; shift_adder #(11, 8, 1, 1, 12, 0, 1) op_46 (v44[10:0], v45[7:0], v46[11:0]); // 20.0
    wire [9:0] v47; shift_adder #(8, 7, 1, 0, 10, 1, 1) op_47 (v37[7:0], v27[6:0], v47[9:0]); // 20.0
    wire [9:0] v48; assign v48[9:0] = model_inp[242:233]; // 19.0
    wire [12:0] v49; shift_adder #(10, 8, 1, 1, 13, -3, 1) op_49 (v48[9:0], v4[7:0], v49[12:0]); // 20.0
    wire [8:0] v50; assign v50[8:0] = model_inp[251:243]; // 19.0
    wire [12:0] v51; shift_adder #(9, 10, 0, 1, 13, -2, 0) op_51 (v50[8:0], v42[9:0], v51[12:0]); // 20.0
    wire [9:0] v52; assign v52[9:0] = model_inp[261:252]; // 19.0
    wire [5:0] v53; assign v53[5:0] = model_inp[267:262]; // 19.0
    wire [6:0] v54; assign v54[6:0] = model_inp[274:268]; // 19.0
    wire [11:0] v55; assign v55[11:0] = model_inp[286:275]; // 19.0
    wire [4:0] v56; assign v56[4:0] = model_inp[291:287]; // 19.0
    wire [4:0] v57; assign v57[4:0] = model_inp[296:292]; // 19.0
    wire [4:0] v58; assign v58[4:0] = model_inp[301:297]; // 19.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[12:0] = v2[12:0];
    assign model_out[21:13] = v5[8:0];
    assign model_out[33:22] = v7[11:0];
    assign model_out[41:34] = v10[7:0];
    assign model_out[51:42] = v52[9:0];
    assign model_out[54:52] = v13[2:0];
    assign model_out[62:55] = v12[7:0];
    assign model_out[72:63] = v15[9:0];
    assign model_out[82:73] = v18[9:0];
    assign model_out[94:83] = v21[11:0];
    assign model_out[108:95] = v24[13:0];
    assign model_out[114:109] = v53[5:0];
    assign model_out[126:115] = v25[11:0];
    assign model_out[137:127] = v28[10:0];
    assign model_out[143:138] = v8[5:0];
    assign model_out[155:144] = v33[11:0];
    assign model_out[169:156] = v36[13:0];
    assign model_out[179:170] = v38[9:0];
    assign model_out[186:180] = v54[6:0];
    assign model_out[195:187] = v41[8:0];
    assign model_out[207:196] = v55[11:0];
    assign model_out[217:208] = v43[9:0];
    assign model_out[229:218] = v46[11:0];
    assign model_out[239:230] = v30[9:0];
    assign model_out[249:240] = v47[9:0];
    assign model_out[257:250] = v45[7:0];
    assign model_out[270:258] = v49[12:0];
    assign model_out[283:271] = v51[12:0];
    assign model_out[288:284] = v56[4:0];
    assign model_out[293:289] = v57[4:0];
    assign model_out[298:294] = v58[4:0];
    assign model_out[301:299] = v16[2:0];

endmodule
