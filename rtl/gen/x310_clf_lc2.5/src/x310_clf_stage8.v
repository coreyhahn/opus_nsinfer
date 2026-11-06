`timescale 1 ns / 1 ps

module x310_clf_stage8 (
    input [541:0] model_inp,
    output [337:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [10:0] v0; assign v0[10:0] = model_inp[10:0]; // 20.0
    wire [9:0] v1; assign v1[9:0] = model_inp[20:11]; // 20.0
    wire [11:0] v2; shift_adder #(11, 10, 1, 1, 12, -1, 1) op_2 (v0[10:0], v1[9:0], v2[11:0]); // 21.0
    wire [3:0] v3; assign v3[3:0] = model_inp[24:21]; // 20.0
    wire [10:0] v4; assign v4[10:0] = model_inp[35:25]; // 20.0
    wire [10:0] v5; shift_adder #(4, 11, 0, 1, 11, -1, 1) op_5 (v3[3:0], v4[10:0], v5[10:0]); // 21.0
    wire [11:0] v6; assign v6[11:0] = model_inp[47:36]; // 20.0
    wire [10:0] v7; assign v7[10:0] = model_inp[58:48]; // 20.0
    wire [12:0] v8; shift_adder #(12, 11, 1, 1, 13, 1, 1) op_8 (v6[11:0], v7[10:0], v8[12:0]); // 21.0
    wire [12:0] v9; shift_adder #(13, 3, 1, 0, 13, 0, 1) op_9 (v8[12:0], 3'b100, v9[12:0]); // 21.0
    wire [11:0] v10; assign v10[11:0] = v9[11:0] & {12{~v9[12]}}; // 21.0
    wire [11:0] v11; shift_adder #(12, 3, 0, 0, 12, 0, 0) op_11 (v10[11:0], 3'b100, v11[11:0]); // 21.0
    wire [6:0] v12; assign v12[6:0] = v11[9:3]; // 21.0
    wire [10:0] v13; assign v13[10:0] = model_inp[69:59]; // 20.0
    wire [10:0] v14; assign v14[10:0] = model_inp[80:70]; // 20.0
    wire [11:0] v15; shift_adder #(11, 11, 1, 1, 12, 1, 0) op_15 (v13[10:0], v14[10:0], v15[11:0]); // 21.0
    wire [7:0] v16; assign v16[7:0] = model_inp[88:81]; // 20.0
    wire [10:0] v17; assign v17[10:0] = model_inp[99:89]; // 20.0
    wire [10:0] v18; shift_adder #(8, 11, 1, 1, 11, -1, 0) op_18 (v16[7:0], v17[10:0], v18[10:0]); // 21.0
    wire [10:0] v19; assign v19[10:0] = model_inp[110:100]; // 20.0
    wire [11:0] v20; assign v20[11:0] = model_inp[122:111]; // 20.0
    wire [12:0] v21; shift_adder #(11, 12, 1, 1, 13, 0, 1) op_21 (v19[10:0], v20[11:0], v21[12:0]); // 21.0
    wire [10:0] v22; assign v22[10:0] = model_inp[133:123]; // 20.0
    wire [6:0] v23; assign v23[6:0] = model_inp[140:134]; // 20.0
    wire [11:0] v24; shift_adder #(11, 7, 1, 1, 12, 4, 1) op_24 (v22[10:0], v23[6:0], v24[11:0]); // 21.0
    wire [10:0] v25; assign v25[10:0] = model_inp[151:141]; // 20.0
    wire [9:0] v26; assign v26[9:0] = model_inp[161:152]; // 20.0
    wire [11:0] v27; shift_adder #(11, 10, 1, 1, 12, 0, 1) op_27 (v25[10:0], v26[9:0], v27[11:0]); // 21.0
    wire [11:0] v28; assign v28[11:0] = model_inp[173:162]; // 20.0
    wire [12:0] v29; assign v29[12:0] = model_inp[186:174]; // 20.0
    wire [13:0] v30; shift_adder #(12, 13, 1, 1, 14, 0, 0) op_30 (v28[11:0], v29[12:0], v30[13:0]); // 21.0
    wire [3:0] v31; assign v31[3:0] = model_inp[190:187]; // 20.0
    wire [7:0] v32; assign v32[7:0] = model_inp[198:191]; // 20.0
    wire [7:0] v33; shift_adder #(4, 8, 0, 1, 8, -1, 1) op_33 (v31[3:0], v32[7:0], v33[7:0]); // 21.0
    wire [11:0] v34; assign v34[11:0] = model_inp[210:199]; // 20.0
    wire [7:0] v35; assign v35[7:0] = model_inp[218:211]; // 20.0
    wire [11:0] v36; shift_adder #(12, 8, 1, 0, 12, 1, 1) op_36 (v34[11:0], v35[7:0], v36[11:0]); // 21.0
    wire [8:0] v37; assign v37[8:0] = model_inp[227:219]; // 20.0
    wire [9:0] v38; shift_adder #(8, 9, 1, 1, 10, 1, 0) op_38 (v16[7:0], v37[8:0], v38[9:0]); // 21.0
    wire [11:0] v39; assign v39[11:0] = model_inp[239:228]; // 20.0
    wire [8:0] v40; assign v40[8:0] = model_inp[248:240]; // 20.0
    wire [12:0] v41; shift_adder #(12, 9, 1, 1, 13, 2, 1) op_41 (v39[11:0], v40[8:0], v41[12:0]); // 21.0
    wire [10:0] v42; assign v42[10:0] = model_inp[259:249]; // 20.0
    wire [11:0] v43; assign v43[11:0] = model_inp[271:260]; // 20.0
    wire [12:0] v44; shift_adder #(11, 12, 1, 1, 13, 0, 1) op_44 (v42[10:0], v43[11:0], v44[12:0]); // 21.0
    wire [11:0] v45; assign v45[11:0] = model_inp[283:272]; // 20.0
    wire [10:0] v46; assign v46[10:0] = model_inp[294:284]; // 20.0
    wire [12:0] v47; shift_adder #(12, 11, 1, 1, 13, 1, 1) op_47 (v45[11:0], v46[10:0], v47[12:0]); // 21.0
    wire [11:0] v48; assign v48[11:0] = model_inp[306:295]; // 20.0
    wire [8:0] v49; assign v49[8:0] = model_inp[315:307]; // 20.0
    wire [11:0] v50; shift_adder #(12, 9, 1, 1, 12, 2, 0) op_50 (v48[11:0], v49[8:0], v50[11:0]); // 21.0
    wire [10:0] v51; assign v51[10:0] = model_inp[326:316]; // 20.0
    wire [11:0] v52; assign v52[11:0] = model_inp[338:327]; // 20.0
    wire [12:0] v53; shift_adder #(11, 12, 1, 1, 13, -1, 0) op_53 (v51[10:0], v52[11:0], v53[12:0]); // 21.0
    wire [12:0] v54; shift_adder #(13, 5, 1, 0, 13, 0, 1) op_54 (v53[12:0], 5'b10000, v54[12:0]); // 21.0
    wire [11:0] v55; assign v55[11:0] = v54[11:0] & {12{~v54[12]}}; // 21.0
    wire [11:0] v56; shift_adder #(12, 4, 0, 0, 12, 0, 0) op_56 (v55[11:0], 4'b1000, v56[11:0]); // 21.0
    wire [5:0] v57; assign v57[5:0] = v56[9:4]; // 21.0
    wire [10:0] v58; assign v58[10:0] = model_inp[349:339]; // 20.0
    wire [11:0] v59; shift_adder #(9, 11, 1, 1, 12, 0, 0) op_59 (v49[8:0], v58[10:0], v59[11:0]); // 21.0
    wire [11:0] v60; shift_adder #(12, 3, 1, 0, 12, 0, 1) op_60 (v59[11:0], 3'b100, v60[11:0]); // 21.0
    wire [8:0] v61; assign v61[8:0] = v60[8:0] & {9{~v60[11]}}; // 21.0
    wire [8:0] v62; shift_adder #(9, 2, 0, 0, 9, 0, 0) op_62 (v61[8:0], 2'b10, v62[8:0]); // 21.0
    wire [4:0] v63; assign v63[4:0] = v62[6:2]; // 21.0
    wire [8:0] v64; assign v64[8:0] = model_inp[358:350]; // 20.0
    wire [10:0] v65; assign v65[10:0] = model_inp[369:359]; // 20.0
    wire [10:0] v66; shift_adder #(9, 11, 1, 1, 11, -1, 0) op_66 (v64[8:0], v65[10:0], v66[10:0]); // 21.0
    wire [13:0] v67; assign v67[13:0] = model_inp[383:370]; // 20.0
    wire [13:0] v68; shift_adder #(14, 11, 1, 1, 14, 2, 0) op_68 (v67[13:0], v5[10:0], v68[13:0]); // 22.0
    wire [9:0] v69; assign v69[9:0] = model_inp[393:384]; // 20.0
    wire [12:0] v70; shift_adder #(11, 10, 1, 1, 13, 2, 1) op_70 (v18[10:0], v69[9:0], v70[12:0]); // 22.0
    wire [12:0] v71; shift_adder #(11, 13, 1, 1, 13, 0, 0) op_71 (v14[10:0], v21[12:0], v71[12:0]); // 22.0
    wire [11:0] v72; shift_adder #(8, 12, 0, 1, 12, -2, 0) op_72 (v35[7:0], v24[11:0], v72[11:0]); // 22.0
    wire [11:0] v73; assign v73[11:0] = model_inp[405:394]; // 20.0
    wire [12:0] v74; shift_adder #(12, 12, 1, 1, 13, 0, 0) op_74 (v73[11:0], v27[11:0], v74[12:0]); // 22.0
    wire [12:0] v75; shift_adder #(13, 3, 1, 0, 13, 0, 0) op_75 (v74[12:0], 3'b100, v75[12:0]); // 22.0
    wire [11:0] v76; assign v76[11:0] = v75[11:0] & {12{~v75[12]}}; // 22.0
    wire [11:0] v77; shift_adder #(12, 3, 0, 0, 12, 0, 0) op_77 (v76[11:0], 3'b100, v77[11:0]); // 22.0
    wire [5:0] v78; assign v78[5:0] = v77[8:3]; // 22.0
    wire [13:0] v79; shift_adder #(14, 8, 1, 1, 14, 2, 1) op_79 (v30[13:0], v33[7:0], v79[13:0]); // 22.0
    wire [13:0] v80; shift_adder #(14, 2, 1, 0, 14, 0, 0) op_80 (v79[13:0], 2'b10, v80[13:0]); // 22.0
    wire [10:0] v81; assign v81[10:0] = v80[10:0] & {11{~v80[13]}}; // 22.0
    wire [10:0] v82; shift_adder #(11, 3, 0, 0, 11, 0, 0) op_82 (v81[10:0], 3'b100, v82[10:0]); // 22.0
    wire [5:0] v83; assign v83[5:0] = v82[8:3]; // 22.0
    wire [9:0] v84; assign v84[9:0] = model_inp[415:406]; // 20.0
    wire [11:0] v85; shift_adder #(10, 10, 1, 1, 12, -1, 0) op_85 (v84[9:0], v38[9:0], v85[11:0]); // 22.0
    wire [8:0] v86; shift_adder #(6, 5, 0, 0, 9, -2, 1) op_86 (v57[5:0], v63[4:0], v86[8:0]); // 22.0
    wire [9:0] v87; assign v87[9:0] = model_inp[425:416]; // 20.0
    wire [9:0] v88; shift_adder #(10, 8, 1, 1, 10, 0, 1) op_88 (v87[9:0], v33[7:0], v88[9:0]); // 22.0
    wire [3:0] v89; assign v89[3:0] = model_inp[429:426]; // 20.0
    wire [8:0] v90; assign v90[8:0] = model_inp[438:430]; // 20.0
    wire [4:0] v91; assign v91[4:0] = model_inp[443:439]; // 20.0
    wire [4:0] v92; assign v92[4:0] = model_inp[448:444]; // 20.0
    wire [5:0] v93; assign v93[5:0] = model_inp[454:449]; // 20.0
    wire [11:0] v94; assign v94[11:0] = model_inp[466:455]; // 20.0
    wire [4:0] v95; assign v95[4:0] = model_inp[471:467]; // 20.0
    wire [6:0] v96; assign v96[6:0] = model_inp[478:472]; // 20.0
    wire [8:0] v97; assign v97[8:0] = model_inp[487:479]; // 20.0
    wire [10:0] v98; assign v98[10:0] = model_inp[498:488]; // 20.0
    wire [7:0] v99; assign v99[7:0] = model_inp[506:499]; // 20.0
    wire [4:0] v100; assign v100[4:0] = model_inp[511:507]; // 20.0
    wire [10:0] v101; assign v101[10:0] = model_inp[522:512]; // 20.0
    wire [4:0] v102; assign v102[4:0] = model_inp[527:523]; // 20.0
    wire [2:0] v103; assign v103[2:0] = model_inp[530:528]; // 20.0
    wire [10:0] v104; assign v104[10:0] = model_inp[541:531]; // 20.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[13:0] = v68[13:0];
    assign model_out[24:14] = v5[10:0];
    assign model_out[36:25] = v15[11:0];
    assign model_out[49:37] = v70[12:0];
    assign model_out[58:50] = v86[8:0];
    assign model_out[64:59] = v78[5:0];
    assign model_out[68:65] = v89[3:0];
    assign model_out[77:69] = v90[8:0];
    assign model_out[82:78] = v91[4:0];
    assign model_out[87:83] = v92[4:0];
    assign model_out[93:88] = v93[5:0];
    assign model_out[105:94] = v94[11:0];
    assign model_out[110:106] = v95[4:0];
    assign model_out[123:111] = v47[12:0];
    assign model_out[133:124] = v88[9:0];
    assign model_out[145:134] = v2[11:0];
    assign model_out[152:146] = v12[6:0];
    assign model_out[159:153] = v96[6:0];
    assign model_out[168:160] = v97[8:0];
    assign model_out[179:169] = v98[10:0];
    assign model_out[187:180] = v99[7:0];
    assign model_out[199:188] = v85[11:0];
    assign model_out[211:200] = v50[11:0];
    assign model_out[222:212] = v66[10:0];
    assign model_out[227:223] = v100[4:0];
    assign model_out[239:228] = v72[11:0];
    assign model_out[251:240] = v36[11:0];
    assign model_out[262:252] = v101[10:0];
    assign model_out[267:263] = v102[4:0];
    assign model_out[280:268] = v71[12:0];
    assign model_out[283:281] = v103[2:0];
    assign model_out[296:284] = v44[12:0];
    assign model_out[302:297] = v83[5:0];
    assign model_out[315:303] = v41[12:0];
    assign model_out[326:316] = v104[10:0];
    assign model_out[332:327] = v57[5:0];
    assign model_out[337:333] = v63[4:0];

endmodule
