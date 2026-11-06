`timescale 1 ns / 1 ps

module x310_clf_stage10 (
    input [283:0] model_inp,
    output [220:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [5:0] v0; assign v0[5:0] = model_inp[5:0]; // 25.0
    wire [7:0] v1; assign v1[7:0] = model_inp[13:6]; // 25.0
    wire [9:0] v2; shift_adder #(6, 8, 0, 0, 10, -3, 1) op_2 (v0[5:0], v1[7:0], v2[9:0]); // 26.0
    wire [7:0] v3; assign v3[7:0] = model_inp[21:14]; // 25.0
    wire [15:0] v4; assign v4[15:0] = model_inp[37:22]; // 25.0
    wire [15:0] v5; shift_adder #(8, 16, 0, 1, 16, -4, 0) op_5 (v3[7:0], v4[15:0], v5[15:0]); // 26.0
    wire [15:0] v6; shift_adder #(16, 4, 1, 0, 16, 0, 0) op_6 (v5[15:0], 4'b1000, v6[15:0]); // 26.0
    wire [14:0] v7; assign v7[14:0] = v6[14:0] & {15{~v6[15]}}; // 26.0
    wire [14:0] v8; shift_adder #(15, 5, 0, 0, 15, 0, 0) op_8 (v7[14:0], 5'b10000, v8[14:0]); // 26.0
    wire [6:0] v9; assign v9[6:0] = v8[11:5]; // 26.0
    wire [4:0] v10; assign v10[4:0] = model_inp[42:38]; // 25.0
    wire [11:0] v11; assign v11[11:0] = model_inp[54:43]; // 25.0
    wire [11:0] v12; shift_adder #(5, 12, 0, 1, 12, -3, 1) op_12 (v10[4:0], v11[11:0], v12[11:0]); // 26.0
    wire [11:0] v13; assign v13[11:0] = model_inp[66:55]; // 25.0
    wire [12:0] v14; shift_adder #(12, 8, 1, 0, 13, 3, 1) op_14 (v13[11:0], v3[7:0], v14[12:0]); // 26.0
    wire [11:0] v15; assign v15[11:0] = model_inp[78:67]; // 25.0
    wire [4:0] v16; assign v16[4:0] = model_inp[83:79]; // 25.0
    wire [12:0] v17; shift_adder #(12, 5, 1, 0, 13, -1, 1) op_17 (v15[11:0], v16[4:0], v17[12:0]); // 26.0
    wire [12:0] v18; shift_adder #(13, 3, 1, 0, 13, 0, 1) op_18 (v17[12:0], 3'b100, v18[12:0]); // 26.0
    wire [11:0] v19; assign v19[11:0] = v18[11:0] & {12{~v18[12]}}; // 26.0
    wire [11:0] v20; shift_adder #(12, 3, 0, 0, 12, 0, 0) op_20 (v19[11:0], 3'b100, v20[11:0]); // 26.0
    wire [5:0] v21; assign v21[5:0] = v20[8:3]; // 26.0
    wire [11:0] v22; assign v22[11:0] = model_inp[95:84]; // 25.0
    wire [9:0] v23; assign v23[9:0] = model_inp[105:96]; // 25.0
    wire [12:0] v24; shift_adder #(12, 10, 1, 1, 13, 0, 1) op_24 (v22[11:0], v23[9:0], v24[12:0]); // 26.0
    wire [11:0] v25; assign v25[11:0] = model_inp[117:106]; // 25.0
    wire [11:0] v26; assign v26[11:0] = model_inp[129:118]; // 25.0
    wire [12:0] v27; shift_adder #(12, 12, 1, 1, 13, -1, 0) op_27 (v25[11:0], v26[11:0], v27[12:0]); // 26.0
    wire [10:0] v28; assign v28[10:0] = model_inp[140:130]; // 25.0
    wire [11:0] v29; shift_adder #(11, 10, 1, 1, 12, -1, 1) op_29 (v28[10:0], v23[9:0], v29[11:0]); // 26.0
    wire [10:0] v30; assign v30[10:0] = v29[10:0] & {11{~v29[11]}}; // 26.0
    wire [10:0] v31; shift_adder #(11, 4, 0, 0, 11, 0, 0) op_31 (v30[10:0], 4'b1000, v31[10:0]); // 26.0
    wire [4:0] v32; assign v32[4:0] = v31[8:4]; // 26.0
    wire [12:0] v33; assign v33[12:0] = model_inp[153:141]; // 25.0
    wire [12:0] v34; shift_adder #(13, 5, 1, 0, 13, 0, 0) op_34 (v33[12:0], v16[4:0], v34[12:0]); // 26.0
    wire [11:0] v35; assign v35[11:0] = v34[11:0] & {12{~v34[12]}}; // 26.0
    wire [11:0] v36; shift_adder #(12, 3, 0, 0, 12, 0, 0) op_36 (v35[11:0], 3'b100, v36[11:0]); // 26.0
    wire [5:0] v37; assign v37[5:0] = v36[8:3]; // 26.0
    wire [4:0] v38; assign v38[4:0] = model_inp[158:154]; // 25.0
    wire [11:0] v39; shift_adder #(5, 12, 0, 1, 12, -3, 0) op_39 (v38[4:0], v26[11:0], v39[11:0]); // 26.0
    wire [5:0] v40; assign v40[5:0] = model_inp[164:159]; // 25.0
    wire [12:0] v41; shift_adder #(6, 6, 0, 0, 13, -6, 1) op_41 (v40[5:0], v40[5:0], v41[12:0]); // 26.0
    wire [6:0] v42; assign v42[6:0] = model_inp[171:165]; // 25.0
    wire [3:0] v43; assign v43[3:0] = model_inp[175:172]; // 25.0
    wire [9:0] v44; shift_adder #(7, 4, 0, 0, 10, -2, 0) op_44 (v42[6:0], v43[3:0], v44[9:0]); // 26.0
    wire [9:0] v45; assign v45[9:0] = model_inp[185:176]; // 25.0
    wire [3:0] v46; assign v46[3:0] = model_inp[189:186]; // 25.0
    wire [10:0] v47; shift_adder #(10, 4, 1, 0, 11, -1, 1) op_47 (v45[9:0], v46[3:0], v47[10:0]); // 26.0
    wire [11:0] v48; shift_adder #(10, 7, 1, 0, 12, -2, 1) op_48 (v2[9:0], v9[6:0], v48[11:0]); // 27.0
    wire [12:0] v49; assign v49[12:0] = model_inp[202:190]; // 25.0
    wire [14:0] v50; shift_adder #(13, 12, 1, 1, 15, -2, 1) op_50 (v49[12:0], v12[11:0], v50[14:0]); // 27.0
    wire [12:0] v51; assign v51[12:0] = v50[12:0] & {13{~v50[14]}}; // 27.0
    wire [12:0] v52; shift_adder #(13, 4, 0, 0, 13, 0, 0) op_52 (v51[12:0], 4'b1000, v52[12:0]); // 27.0
    wire [6:0] v53; assign v53[6:0] = v52[10:4]; // 27.0
    wire [12:0] v54; shift_adder #(13, 5, 1, 0, 13, 0, 1) op_54 (v14[12:0], v16[4:0], v54[12:0]); // 27.0
    wire [12:0] v55; shift_adder #(13, 6, 1, 0, 13, 0, 0) op_55 (v54[12:0], 6'b111100, v55[12:0]); // 27.0
    wire [9:0] v56; assign v56[9:0] = v55[9:0] & {10{~v55[12]}}; // 27.0
    wire [9:0] v57; shift_adder #(10, 4, 0, 0, 10, 0, 0) op_57 (v56[9:0], 4'b1000, v57[9:0]); // 27.0
    wire [4:0] v58; assign v58[4:0] = v57[8:4]; // 27.0
    wire [12:0] v59; shift_adder #(13, 5, 1, 0, 13, 0, 1) op_59 (v24[12:0], v16[4:0], v59[12:0]); // 27.0
    wire [12:0] v60; shift_adder #(13, 4, 1, 0, 13, 0, 1) op_60 (v59[12:0], 4'b1000, v60[12:0]); // 27.0
    wire [11:0] v61; assign v61[11:0] = v60[11:0] & {12{~v60[12]}}; // 27.0
    wire [11:0] v62; shift_adder #(12, 4, 0, 0, 12, 0, 0) op_62 (v61[11:0], 4'b1000, v62[11:0]); // 27.0
    wire [5:0] v63; assign v63[5:0] = v62[9:4]; // 27.0
    wire [12:0] v64; shift_adder #(13, 5, 1, 0, 13, 0, 0) op_64 (v27[12:0], v16[4:0], v64[12:0]); // 27.0
    wire [11:0] v65; assign v65[11:0] = v64[11:0] & {12{~v64[12]}}; // 27.0
    wire [11:0] v66; shift_adder #(12, 3, 0, 0, 12, 0, 0) op_66 (v65[11:0], 3'b100, v66[11:0]); // 27.0
    wire [6:0] v67; assign v67[6:0] = v66[9:3]; // 27.0
    wire [8:0] v68; shift_adder #(6, 6, 0, 0, 9, 2, 1) op_68 (v21[5:0], v37[5:0], v68[8:0]); // 27.0
    wire [2:0] v69; assign v69[2:0] = model_inp[205:203]; // 25.0
    wire [11:0] v70; shift_adder #(3, 12, 0, 1, 12, -4, 0) op_70 (v69[2:0], v39[11:0], v70[11:0]); // 27.0
    wire [12:0] v71; assign v71[12:0] = model_inp[218:206]; // 25.0
    wire [13:0] v72; shift_adder #(13, 12, 1, 1, 14, -1, 0) op_72 (v71[12:0], v12[11:0], v72[13:0]); // 27.0
    wire [11:0] v73; assign v73[11:0] = v72[11:0] & {12{~v72[13]}}; // 27.0
    wire [11:0] v74; shift_adder #(12, 4, 0, 0, 12, 0, 0) op_74 (v73[11:0], 4'b1000, v74[11:0]); // 27.0
    wire [3:0] v75; assign v75[3:0] = v74[7:4]; // 27.0
    wire [8:0] v76; shift_adder #(5, 7, 0, 0, 9, -3, 0) op_76 (v32[4:0], v42[6:0], v76[8:0]); // 27.0
    wire [6:0] v77; shift_adder #(6, 4, 0, 0, 7, 2, 1) op_77 (v37[5:0], v43[3:0], v77[6:0]); // 27.0
    wire [14:0] v78; shift_adder #(13, 10, 1, 0, 15, 3, 0) op_78 (v41[12:0], v44[9:0], v78[14:0]); // 27.0
    wire [10:0] v79; shift_adder #(11, 5, 1, 0, 11, 0, 1) op_79 (v47[10:0], v32[4:0], v79[10:0]); // 27.0
    wire [5:0] v80; assign v80[5:0] = model_inp[224:219]; // 25.0
    wire [10:0] v81; shift_adder #(6, 6, 1, 0, 11, -4, 1) op_81 (v80[5:0], v21[5:0], v81[10:0]); // 27.0
    wire [5:0] v82; assign v82[5:0] = model_inp[230:225]; // 25.0
    wire [5:0] v83; assign v83[5:0] = model_inp[236:231]; // 25.0
    wire [12:0] v84; assign v84[12:0] = model_inp[249:237]; // 25.0
    wire [10:0] v85; assign v85[10:0] = model_inp[260:250]; // 25.0
    wire [6:0] v86; assign v86[6:0] = model_inp[267:261]; // 25.0
    wire [5:0] v87; assign v87[5:0] = model_inp[273:268]; // 25.0
    wire [4:0] v88; assign v88[4:0] = model_inp[278:274]; // 25.0
    wire [4:0] v89; assign v89[4:0] = model_inp[283:279]; // 25.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[11:0] = v48[11:0];
    assign model_out[18:12] = v53[6:0];
    assign model_out[23:19] = v58[4:0];
    assign model_out[29:24] = v21[5:0];
    assign model_out[35:30] = v63[5:0];
    assign model_out[41:36] = v82[5:0];
    assign model_out[47:42] = v83[5:0];
    assign model_out[54:48] = v67[6:0];
    assign model_out[59:55] = v32[4:0];
    assign model_out[68:60] = v68[8:0];
    assign model_out[81:69] = v84[12:0];
    assign model_out[93:82] = v70[11:0];
    assign model_out[104:94] = v85[10:0];
    assign model_out[111:105] = v86[6:0];
    assign model_out[115:112] = v75[3:0];
    assign model_out[124:116] = v76[8:0];
    assign model_out[131:125] = v77[6:0];
    assign model_out[138:132] = v42[6:0];
    assign model_out[153:139] = v78[14:0];
    assign model_out[159:154] = v87[5:0];
    assign model_out[170:160] = v79[10:0];
    assign model_out[176:171] = v37[5:0];
    assign model_out[187:177] = v81[10:0];
    assign model_out[193:188] = v40[5:0];
    assign model_out[200:194] = v9[6:0];
    assign model_out[206:201] = v0[5:0];
    assign model_out[211:207] = v88[4:0];
    assign model_out[216:212] = v89[4:0];
    assign model_out[220:217] = v46[3:0];

endmodule
