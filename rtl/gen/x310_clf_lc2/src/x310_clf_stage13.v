`timescale 1 ns / 1 ps

module x310_clf_stage13 (
    input [256:0] model_inp,
    output [222:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [9:0] v0; assign v0[9:0] = model_inp[9:0]; // 26.0
    wire [6:0] v1; assign v1[6:0] = model_inp[16:10]; // 26.0
    wire [11:0] v2; shift_adder #(10, 7, 1, 0, 12, -2, 1) op_2 (v0[9:0], v1[6:0], v2[11:0]); // 27.0
    wire [12:0] v3; assign v3[12:0] = model_inp[29:17]; // 26.0
    wire [11:0] v4; assign v4[11:0] = model_inp[41:30]; // 26.0
    wire [14:0] v5; shift_adder #(13, 12, 1, 1, 15, -2, 1) op_5 (v3[12:0], v4[11:0], v5[14:0]); // 27.0
    wire [12:0] v6; assign v6[12:0] = v5[12:0] & {13{~v5[14]}}; // 27.0
    wire [12:0] v7; shift_adder #(13, 4, 0, 0, 13, 0, 0) op_7 (v6[12:0], 4'b1000, v7[12:0]); // 27.0
    wire [6:0] v8; assign v8[6:0] = v7[10:4]; // 27.0
    wire [12:0] v9; assign v9[12:0] = model_inp[54:42]; // 26.0
    wire [4:0] v10; assign v10[4:0] = model_inp[59:55]; // 26.0
    wire [12:0] v11; shift_adder #(13, 5, 1, 0, 13, 0, 1) op_11 (v9[12:0], v10[4:0], v11[12:0]); // 27.0
    wire [12:0] v12; shift_adder #(13, 6, 1, 0, 13, 0, 0) op_12 (v11[12:0], 6'b111100, v12[12:0]); // 27.0
    wire [9:0] v13; assign v13[9:0] = v12[9:0] & {10{~v12[12]}}; // 27.0
    wire [9:0] v14; shift_adder #(10, 4, 0, 0, 10, 0, 0) op_14 (v13[9:0], 4'b1000, v14[9:0]); // 27.0
    wire [4:0] v15; assign v15[4:0] = v14[8:4]; // 27.0
    wire [12:0] v16; assign v16[12:0] = model_inp[72:60]; // 26.0
    wire [12:0] v17; shift_adder #(13, 5, 1, 0, 13, 0, 1) op_17 (v16[12:0], v10[4:0], v17[12:0]); // 27.0
    wire [12:0] v18; shift_adder #(13, 4, 1, 0, 13, 0, 1) op_18 (v17[12:0], 4'b1000, v18[12:0]); // 27.0
    wire [11:0] v19; assign v19[11:0] = v18[11:0] & {12{~v18[12]}}; // 27.0
    wire [11:0] v20; shift_adder #(12, 4, 0, 0, 12, 0, 0) op_20 (v19[11:0], 4'b1000, v20[11:0]); // 27.0
    wire [5:0] v21; assign v21[5:0] = v20[9:4]; // 27.0
    wire [12:0] v22; assign v22[12:0] = model_inp[85:73]; // 26.0
    wire [12:0] v23; shift_adder #(13, 5, 1, 0, 13, 0, 0) op_23 (v22[12:0], v10[4:0], v23[12:0]); // 27.0
    wire [11:0] v24; assign v24[11:0] = v23[11:0] & {12{~v23[12]}}; // 27.0
    wire [11:0] v25; shift_adder #(12, 3, 0, 0, 12, 0, 0) op_25 (v24[11:0], 3'b100, v25[11:0]); // 27.0
    wire [6:0] v26; assign v26[6:0] = v25[9:3]; // 27.0
    wire [5:0] v27; assign v27[5:0] = model_inp[91:86]; // 26.0
    wire [5:0] v28; assign v28[5:0] = model_inp[97:92]; // 26.0
    wire [8:0] v29; shift_adder #(6, 6, 0, 0, 9, 2, 1) op_29 (v27[5:0], v28[5:0], v29[8:0]); // 27.0
    wire [2:0] v30; assign v30[2:0] = model_inp[100:98]; // 26.0
    wire [11:0] v31; assign v31[11:0] = model_inp[112:101]; // 26.0
    wire [11:0] v32; shift_adder #(3, 12, 0, 1, 12, -4, 0) op_32 (v30[2:0], v31[11:0], v32[11:0]); // 27.0
    wire [12:0] v33; assign v33[12:0] = model_inp[125:113]; // 26.0
    wire [13:0] v34; shift_adder #(13, 12, 1, 1, 14, -1, 0) op_34 (v33[12:0], v4[11:0], v34[13:0]); // 27.0
    wire [11:0] v35; assign v35[11:0] = v34[11:0] & {12{~v34[13]}}; // 27.0
    wire [11:0] v36; shift_adder #(12, 4, 0, 0, 12, 0, 0) op_36 (v35[11:0], 4'b1000, v36[11:0]); // 27.0
    wire [3:0] v37; assign v37[3:0] = v36[7:4]; // 27.0
    wire [4:0] v38; assign v38[4:0] = model_inp[130:126]; // 26.0
    wire [6:0] v39; assign v39[6:0] = model_inp[137:131]; // 26.0
    wire [8:0] v40; shift_adder #(5, 7, 0, 0, 9, -3, 0) op_40 (v38[4:0], v39[6:0], v40[8:0]); // 27.0
    wire [3:0] v41; assign v41[3:0] = model_inp[141:138]; // 26.0
    wire [6:0] v42; shift_adder #(6, 4, 0, 0, 7, 2, 1) op_42 (v28[5:0], v41[3:0], v42[6:0]); // 27.0
    wire [12:0] v43; assign v43[12:0] = model_inp[154:142]; // 26.0
    wire [9:0] v44; assign v44[9:0] = model_inp[164:155]; // 26.0
    wire [14:0] v45; shift_adder #(13, 10, 1, 0, 15, 3, 0) op_45 (v43[12:0], v44[9:0], v45[14:0]); // 27.0
    wire [10:0] v46; assign v46[10:0] = model_inp[175:165]; // 26.0
    wire [10:0] v47; shift_adder #(11, 5, 1, 0, 11, 0, 1) op_47 (v46[10:0], v38[4:0], v47[10:0]); // 27.0
    wire [5:0] v48; assign v48[5:0] = model_inp[181:176]; // 26.0
    wire [10:0] v49; shift_adder #(6, 6, 1, 0, 11, -4, 1) op_49 (v48[5:0], v27[5:0], v49[10:0]); // 27.0
    wire [11:0] v50; shift_adder #(12, 7, 1, 0, 12, 2, 1) op_50 (v2[11:0], v8[6:0], v50[11:0]); // 28.0
    wire [6:0] v51; shift_adder #(5, 6, 0, 0, 7, 0, 1) op_51 (v15[4:0], v27[5:0], v51[6:0]); // 28.0
    wire [5:0] v52; assign v52[5:0] = model_inp[187:182]; // 26.0
    wire [7:0] v53; shift_adder #(6, 6, 0, 0, 8, -1, 1) op_53 (v21[5:0], v52[5:0], v53[7:0]); // 28.0
    wire [5:0] v54; assign v54[5:0] = model_inp[193:188]; // 26.0
    wire [8:0] v55; shift_adder #(6, 7, 0, 0, 9, -2, 0) op_55 (v54[5:0], v26[6:0], v55[8:0]); // 28.0
    wire [9:0] v56; shift_adder #(5, 9, 0, 1, 10, -3, 0) op_56 (v38[4:0], v29[8:0], v56[9:0]); // 28.0
    wire [12:0] v57; assign v57[12:0] = model_inp[206:194]; // 26.0
    wire [13:0] v58; shift_adder #(13, 12, 1, 1, 14, -1, 0) op_58 (v57[12:0], v32[11:0], v58[13:0]); // 28.0
    wire [13:0] v59; shift_adder #(14, 4, 1, 0, 14, 0, 0) op_59 (v58[13:0], 4'b1000, v59[13:0]); // 28.0
    wire [12:0] v60; assign v60[12:0] = v59[12:0] & {13{~v59[13]}}; // 28.0
    wire [12:0] v61; shift_adder #(13, 4, 0, 0, 13, 0, 0) op_61 (v60[12:0], 4'b1000, v61[12:0]); // 28.0
    wire [6:0] v62; assign v62[6:0] = v61[10:4]; // 28.0
    wire [10:0] v63; assign v63[10:0] = model_inp[217:207]; // 26.0
    wire [13:0] v64; shift_adder #(11, 12, 1, 1, 14, -2, 0) op_64 (v63[10:0], v32[11:0], v64[13:0]); // 28.0
    wire [13:0] v65; shift_adder #(14, 5, 1, 0, 14, 0, 0) op_65 (v64[13:0], 5'b10000, v65[13:0]); // 28.0
    wire [11:0] v66; assign v66[11:0] = v65[11:0] & {12{~v65[13]}}; // 28.0
    wire [11:0] v67; shift_adder #(12, 6, 0, 0, 12, 0, 0) op_67 (v66[11:0], 6'b100000, v67[11:0]); // 28.0
    wire [3:0] v68; assign v68[3:0] = v67[9:6]; // 28.0
    wire [6:0] v69; assign v69[6:0] = model_inp[224:218]; // 26.0
    wire [8:0] v70; shift_adder #(7, 7, 0, 0, 9, -1, 1) op_70 (v8[6:0], v69[6:0], v70[8:0]); // 28.0
    wire [9:0] v71; shift_adder #(4, 9, 0, 0, 10, -4, 0) op_71 (v37[3:0], v40[8:0], v71[9:0]); // 28.0
    wire [10:0] v72; shift_adder #(7, 6, 1, 0, 11, -3, 1) op_72 (v42[6:0], v27[5:0], v72[10:0]); // 28.0
    wire [6:0] v73; shift_adder #(6, 6, 0, 0, 7, 0, 1) op_73 (v21[5:0], v52[5:0], v73[6:0]); // 28.0
    wire [10:0] v74; shift_adder #(7, 7, 0, 0, 11, 3, 0) op_74 (v39[6:0], v26[6:0], v74[10:0]); // 28.0
    wire [14:0] v75; shift_adder #(15, 5, 1, 0, 15, 4, 1) op_75 (v45[14:0], v15[4:0], v75[14:0]); // 28.0
    wire [5:0] v76; assign v76[5:0] = model_inp[230:225]; // 26.0
    wire [8:0] v77; shift_adder #(7, 6, 0, 0, 9, 2, 1) op_77 (v8[6:0], v76[5:0], v77[8:0]); // 28.0
    wire [9:0] v78; shift_adder #(6, 9, 0, 1, 10, -2, 1) op_78 (v21[5:0], v29[8:0], v78[9:0]); // 28.0
    wire [11:0] v79; shift_adder #(11, 6, 1, 0, 12, -1, 1) op_79 (v47[10:0], v28[5:0], v79[11:0]); // 28.0
    wire [10:0] v80; shift_adder #(4, 11, 0, 1, 11, -4, 0) op_80 (v37[3:0], v49[10:0], v80[10:0]); // 28.0
    wire [5:0] v81; assign v81[5:0] = model_inp[236:231]; // 26.0
    wire [5:0] v82; assign v82[5:0] = model_inp[242:237]; // 26.0
    wire [4:0] v83; assign v83[4:0] = model_inp[247:243]; // 26.0
    wire [4:0] v84; assign v84[4:0] = model_inp[252:248]; // 26.0
    wire [3:0] v85; assign v85[3:0] = model_inp[256:253]; // 26.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[11:0] = v50[11:0];
    assign model_out[18:12] = v51[6:0];
    assign model_out[24:19] = v81[5:0];
    assign model_out[32:25] = v53[7:0];
    assign model_out[41:33] = v55[8:0];
    assign model_out[51:42] = v56[9:0];
    assign model_out[56:52] = v15[4:0];
    assign model_out[63:57] = v62[6:0];
    assign model_out[69:64] = v54[5:0];
    assign model_out[73:70] = v68[3:0];
    assign model_out[80:74] = v1[6:0];
    assign model_out[89:81] = v70[8:0];
    assign model_out[99:90] = v71[9:0];
    assign model_out[110:100] = v72[10:0];
    assign model_out[117:111] = v69[6:0];
    assign model_out[124:118] = v73[6:0];
    assign model_out[135:125] = v74[10:0];
    assign model_out[150:136] = v75[14:0];
    assign model_out[159:151] = v77[8:0];
    assign model_out[169:160] = v78[9:0];
    assign model_out[181:170] = v79[11:0];
    assign model_out[192:182] = v80[10:0];
    assign model_out[198:193] = v28[5:0];
    assign model_out[202:199] = v37[3:0];
    assign model_out[208:203] = v82[5:0];
    assign model_out[213:209] = v83[4:0];
    assign model_out[218:214] = v84[4:0];
    assign model_out[222:219] = v85[3:0];

endmodule
