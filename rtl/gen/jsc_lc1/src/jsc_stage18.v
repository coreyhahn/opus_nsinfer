`timescale 1 ns / 1 ps

module jsc_stage18 (
    input [307:0] model_inp,
    output [301:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [10:0] v0; assign v0[10:0] = model_inp[10:0]; // 18.0
    wire [11:0] v1; assign v1[11:0] = model_inp[22:11]; // 18.0
    wire [12:0] v2; shift_adder #(11, 12, 1, 0, 13, 0, 0) op_2 (v0[10:0], v1[11:0], v2[12:0]); // 19.0
    wire [8:0] v3; assign v3[8:0] = model_inp[31:23]; // 18.0
    wire [6:0] v4; assign v4[6:0] = model_inp[38:32]; // 18.0
    wire [9:0] v5; shift_adder #(9, 7, 0, 0, 10, 0, 0) op_5 (v3[8:0], v4[6:0], v5[9:0]); // 19.0
    wire [6:0] v6; assign v6[6:0] = model_inp[45:39]; // 18.0
    wire [6:0] v7; assign v7[6:0] = model_inp[52:46]; // 18.0
    wire [7:0] v8; shift_adder #(7, 7, 0, 0, 8, 0, 1) op_8 (v6[6:0], v7[6:0], v8[7:0]); // 19.0
    wire [12:0] v9; assign v9[12:0] = model_inp[65:53]; // 18.0
    wire [14:0] v10; assign v10[14:0] = model_inp[80:66]; // 18.0
    wire [14:0] v11; shift_adder #(13, 15, 1, 1, 15, 0, 0) op_11 (v9[12:0], v10[14:0], v11[14:0]); // 19.0
    wire [14:0] v12; shift_adder #(15, 8, 1, 0, 15, 0, 0) op_12 (v11[14:0], 8'b10010000, v12[14:0]); // 19.0
    wire [13:0] v13; assign v13[13:0] = v12[13:0] & {14{~v12[14]}}; // 19.0
    wire [13:0] v14; shift_adder #(14, 5, 0, 0, 14, 0, 0) op_14 (v13[13:0], 5'b10000, v14[13:0]); // 19.0
    wire [5:0] v15; assign v15[5:0] = v14[10:5]; // 19.0
    wire [8:0] v16; assign v16[8:0] = model_inp[89:81]; // 18.0
    wire [6:0] v17; assign v17[6:0] = model_inp[96:90]; // 18.0
    wire [9:0] v18; shift_adder #(9, 7, 0, 0, 10, 1, 0) op_18 (v16[8:0], v17[6:0], v18[9:0]); // 19.0
    wire [4:0] v19; assign v19[4:0] = model_inp[101:97]; // 18.0
    wire [8:0] v20; assign v20[8:0] = model_inp[110:102]; // 18.0
    wire [9:0] v21; shift_adder #(5, 9, 0, 1, 10, -3, 0) op_21 (v19[4:0], v20[8:0], v21[9:0]); // 19.0
    wire [4:0] v22; assign v22[4:0] = model_inp[115:111]; // 18.0
    wire [6:0] v23; assign v23[6:0] = model_inp[122:116]; // 18.0
    wire [6:0] v24; shift_adder #(5, 7, 0, 0, 7, 0, 0) op_24 (v22[4:0], v23[6:0], v24[6:0]); // 19.0
    wire [6:0] v25; assign v25[6:0] = model_inp[129:123]; // 18.0
    wire [6:0] v26; assign v26[6:0] = model_inp[136:130]; // 18.0
    wire [8:0] v27; shift_adder #(7, 7, 0, 0, 9, 1, 1) op_27 (v25[6:0], v26[6:0], v27[8:0]); // 19.0
    wire [7:0] v28; assign v28[7:0] = model_inp[144:137]; // 18.0
    wire [8:0] v29; shift_adder #(7, 8, 0, 0, 9, 0, 0) op_29 (v23[6:0], v28[7:0], v29[8:0]); // 19.0
    wire [8:0] v30; assign v30[8:0] = model_inp[153:145]; // 18.0
    wire [9:0] v31; shift_adder #(7, 9, 0, 0, 10, -1, 0) op_31 (v6[6:0], v30[8:0], v31[9:0]); // 19.0
    wire [7:0] v32; assign v32[7:0] = model_inp[161:154]; // 18.0
    wire [8:0] v33; assign v33[8:0] = model_inp[170:162]; // 18.0
    wire [10:0] v34; shift_adder #(8, 9, 1, 1, 11, -2, 0) op_34 (v32[7:0], v33[8:0], v34[10:0]); // 19.0
    wire [7:0] v35; assign v35[7:0] = model_inp[178:171]; // 18.0
    wire [7:0] v36; assign v36[7:0] = model_inp[186:179]; // 18.0
    wire [10:0] v37; shift_adder #(8, 8, 0, 0, 11, 2, 1) op_37 (v35[7:0], v36[7:0], v37[10:0]); // 19.0
    wire [9:0] v38; assign v38[9:0] = model_inp[196:187]; // 18.0
    wire [10:0] v39; assign v39[10:0] = model_inp[207:197]; // 18.0
    wire [11:0] v40; shift_adder #(10, 11, 1, 1, 12, -1, 0) op_40 (v38[9:0], v39[10:0], v40[11:0]); // 19.0
    wire [5:0] v41; assign v41[5:0] = model_inp[213:208]; // 18.0
    wire [7:0] v42; shift_adder #(7, 6, 0, 0, 8, 1, 1) op_42 (v25[6:0], v41[5:0], v42[7:0]); // 19.0
    wire [4:0] v43; assign v43[4:0] = model_inp[218:214]; // 18.0
    wire [7:0] v44; shift_adder #(5, 7, 0, 0, 8, -2, 1) op_44 (v43[4:0], v25[6:0], v44[7:0]); // 19.0
    wire [11:0] v45; shift_adder #(7, 7, 0, 0, 12, -4, 0) op_45 (v17[6:0], v17[6:0], v45[11:0]); // 19.0
    wire [4:0] v46; assign v46[4:0] = model_inp[223:219]; // 18.0
    wire [9:0] v47; shift_adder #(5, 9, 0, 1, 10, -2, 0) op_47 (v46[4:0], v33[8:0], v47[9:0]); // 19.0
    wire [9:0] v48; assign v48[9:0] = model_inp[233:224]; // 18.0
    wire [4:0] v49; assign v49[4:0] = model_inp[238:234]; // 18.0
    wire [10:0] v50; shift_adder #(10, 5, 0, 0, 11, 3, 1) op_50 (v48[9:0], v49[4:0], v50[10:0]); // 19.0
    wire [7:0] v51; shift_adder #(7, 6, 0, 0, 8, 1, 1) op_51 (v6[6:0], v41[5:0], v51[7:0]); // 19.0
    wire [8:0] v52; assign v52[8:0] = model_inp[247:239]; // 18.0
    wire [5:0] v53; assign v53[5:0] = model_inp[253:248]; // 18.0
    wire [9:0] v54; shift_adder #(9, 6, 0, 0, 10, 0, 1) op_54 (v52[8:0], v53[5:0], v54[9:0]); // 19.0
    wire [8:0] v55; assign v55[8:0] = model_inp[262:254]; // 18.0
    wire [4:0] v56; assign v56[4:0] = model_inp[267:263]; // 18.0
    wire [6:0] v57; assign v57[6:0] = model_inp[274:268]; // 18.0
    wire [2:0] v58; assign v58[2:0] = model_inp[277:275]; // 18.0
    wire [2:0] v59; assign v59[2:0] = model_inp[280:278]; // 18.0
    wire [6:0] v60; assign v60[6:0] = model_inp[287:281]; // 18.0
    wire [4:0] v61; assign v61[4:0] = model_inp[292:288]; // 18.0
    wire [3:0] v62; assign v62[3:0] = model_inp[296:293]; // 18.0
    wire [5:0] v63; assign v63[5:0] = model_inp[302:297]; // 18.0
    wire [4:0] v64; assign v64[4:0] = model_inp[307:303]; // 18.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[12:0] = v2[12:0];
    assign model_out[22:13] = v5[9:0];
    assign model_out[29:23] = v25[6:0];
    assign model_out[37:30] = v8[7:0];
    assign model_out[46:38] = v55[8:0];
    assign model_out[52:47] = v15[5:0];
    assign model_out[57:53] = v56[4:0];
    assign model_out[64:58] = v57[6:0];
    assign model_out[67:65] = v58[2:0];
    assign model_out[77:68] = v21[9:0];
    assign model_out[80:78] = v59[2:0];
    assign model_out[87:81] = v24[6:0];
    assign model_out[95:88] = v36[7:0];
    assign model_out[104:96] = v27[8:0];
    assign model_out[113:105] = v29[8:0];
    assign model_out[123:114] = v31[9:0];
    assign model_out[134:124] = v34[10:0];
    assign model_out[141:135] = v7[6:0];
    assign model_out[148:142] = v60[6:0];
    assign model_out[153:149] = v61[4:0];
    assign model_out[164:154] = v37[10:0];
    assign model_out[176:165] = v40[11:0];
    assign model_out[183:177] = v6[6:0];
    assign model_out[191:184] = v42[7:0];
    assign model_out[195:192] = v62[3:0];
    assign model_out[203:196] = v44[7:0];
    assign model_out[213:204] = v47[9:0];
    assign model_out[224:214] = v50[10:0];
    assign model_out[232:225] = v51[7:0];
    assign model_out[242:233] = v54[9:0];
    assign model_out[251:243] = v3[8:0];
    assign model_out[261:252] = v18[9:0];
    assign model_out[267:262] = v63[5:0];
    assign model_out[274:268] = v17[6:0];
    assign model_out[286:275] = v45[11:0];
    assign model_out[291:287] = v46[4:0];
    assign model_out[296:292] = v64[4:0];
    assign model_out[301:297] = v22[4:0];

endmodule
