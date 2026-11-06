`timescale 1 ns / 1 ps

module x310_clf_stage13 (
    input [691:0] model_inp,
    output [397:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [7:0] v0; assign v0[7:0] = model_inp[7:0]; // 19.5
    wire [9:0] v1; assign v1[9:0] = model_inp[17:8]; // 19.5
    wire [10:0] v2; shift_adder #(8, 10, 1, 1, 11, 0, 0) op_2 (v0[7:0], v1[9:0], v2[10:0]); // 20.0
    wire [6:0] v3; assign v3[6:0] = model_inp[24:18]; // 19.5
    wire [8:0] v4; assign v4[8:0] = model_inp[33:25]; // 19.5
    wire [9:0] v5; shift_adder #(7, 9, 0, 1, 10, -1, 0) op_5 (v3[6:0], v4[8:0], v5[9:0]); // 20.0
    wire [3:0] v6; assign v6[3:0] = model_inp[37:34]; // 19.5
    wire [10:0] v7; assign v7[10:0] = model_inp[48:38]; // 19.5
    wire [10:0] v8; shift_adder #(4, 11, 0, 1, 11, -1, 1) op_8 (v6[3:0], v7[10:0], v8[10:0]); // 20.0
    wire [9:0] v9; assign v9[9:0] = model_inp[58:49]; // 19.5
    wire [10:0] v10; assign v10[10:0] = model_inp[69:59]; // 19.5
    wire [11:0] v11; shift_adder #(10, 11, 1, 1, 12, -1, 0) op_11 (v9[9:0], v10[10:0], v11[11:0]); // 20.0
    wire [10:0] v12; assign v12[10:0] = model_inp[80:70]; // 19.5
    wire [10:0] v13; shift_adder #(11, 7, 1, 0, 11, 1, 0) op_13 (v12[10:0], v3[6:0], v13[10:0]); // 20.0
    wire [8:0] v14; assign v14[8:0] = model_inp[89:81]; // 19.5
    wire [8:0] v15; assign v15[8:0] = model_inp[98:90]; // 19.5
    wire [10:0] v16; shift_adder #(9, 9, 1, 1, 11, 1, 0) op_16 (v14[8:0], v15[8:0], v16[10:0]); // 20.0
    wire [4:0] v17; assign v17[4:0] = model_inp[103:99]; // 19.5
    wire [9:0] v18; assign v18[9:0] = model_inp[113:104]; // 19.5
    wire [10:0] v19; shift_adder #(5, 10, 0, 1, 11, -2, 0) op_19 (v17[4:0], v18[9:0], v19[10:0]); // 20.0
    wire [2:0] v20; assign v20[2:0] = model_inp[116:114]; // 19.5
    wire [7:0] v21; assign v21[7:0] = model_inp[124:117]; // 19.5
    wire [7:0] v22; shift_adder #(3, 8, 0, 1, 8, -2, 1) op_22 (v20[2:0], v21[7:0], v22[7:0]); // 20.0
    wire [9:0] v23; assign v23[9:0] = model_inp[134:125]; // 19.5
    wire [8:0] v24; assign v24[8:0] = model_inp[143:135]; // 19.5
    wire [10:0] v25; shift_adder #(10, 9, 1, 1, 11, 1, 0) op_25 (v23[9:0], v24[8:0], v25[10:0]); // 20.0
    wire [8:0] v26; assign v26[8:0] = model_inp[152:144]; // 19.5
    wire [9:0] v27; shift_adder #(9, 9, 1, 1, 10, -1, 0) op_27 (v24[8:0], v26[8:0], v27[9:0]); // 20.0
    wire [6:0] v28; assign v28[6:0] = model_inp[159:153]; // 19.5
    wire [10:0] v29; assign v29[10:0] = model_inp[170:160]; // 19.5
    wire [10:0] v30; shift_adder #(7, 11, 1, 1, 11, -2, 0) op_30 (v28[6:0], v29[10:0], v30[10:0]); // 20.0
    wire [10:0] v31; assign v31[10:0] = model_inp[181:171]; // 19.5
    wire [9:0] v32; assign v32[9:0] = model_inp[191:182]; // 19.5
    wire [10:0] v33; shift_adder #(11, 10, 1, 1, 11, 0, 0) op_33 (v31[10:0], v32[9:0], v33[10:0]); // 20.0
    wire [9:0] v34; assign v34[9:0] = model_inp[201:192]; // 19.5
    wire [9:0] v35; assign v35[9:0] = model_inp[211:202]; // 19.5
    wire [11:0] v36; shift_adder #(10, 10, 1, 1, 12, -1, 0) op_36 (v34[9:0], v35[9:0], v36[11:0]); // 20.0
    wire [3:0] v37; assign v37[3:0] = model_inp[215:212]; // 19.5
    wire [6:0] v38; assign v38[6:0] = model_inp[222:216]; // 19.5
    wire [7:0] v39; shift_adder #(4, 7, 0, 0, 8, -1, 0) op_39 (v37[3:0], v38[6:0], v39[7:0]); // 20.0
    wire [9:0] v40; assign v40[9:0] = model_inp[232:223]; // 19.5
    wire [7:0] v41; assign v41[7:0] = model_inp[240:233]; // 19.5
    wire [10:0] v42; shift_adder #(10, 8, 0, 1, 11, 1, 1) op_42 (v40[9:0], v41[7:0], v42[10:0]); // 20.0
    wire [11:0] v43; assign v43[11:0] = model_inp[252:241]; // 19.5
    wire [6:0] v44; assign v44[6:0] = model_inp[259:253]; // 19.5
    wire [11:0] v45; shift_adder #(12, 7, 1, 1, 12, 2, 1) op_45 (v43[11:0], v44[6:0], v45[11:0]); // 20.0
    wire [10:0] v46; assign v46[10:0] = model_inp[270:260]; // 19.5
    wire [8:0] v47; assign v47[8:0] = model_inp[279:271]; // 19.5
    wire [10:0] v48; shift_adder #(11, 9, 1, 1, 11, 0, 1) op_48 (v46[10:0], v47[8:0], v48[10:0]); // 20.0
    wire [10:0] v49; assign v49[10:0] = model_inp[290:280]; // 19.5
    wire [9:0] v50; assign v50[9:0] = model_inp[300:291]; // 19.5
    wire [11:0] v51; shift_adder #(11, 10, 1, 1, 12, 1, 1) op_51 (v49[10:0], v50[9:0], v51[11:0]); // 20.0
    wire [12:0] v52; assign v52[12:0] = model_inp[313:301]; // 19.5
    wire [12:0] v53; shift_adder #(7, 13, 1, 1, 13, -4, 0) op_53 (v44[6:0], v52[12:0], v53[12:0]); // 20.0
    wire [7:0] v54; shift_adder #(4, 7, 0, 1, 8, 0, 1) op_54 (v37[3:0], v44[6:0], v54[7:0]); // 20.0
    wire [10:0] v55; assign v55[10:0] = model_inp[324:314]; // 19.5
    wire [8:0] v56; assign v56[8:0] = model_inp[333:325]; // 19.5
    wire [11:0] v57; shift_adder #(11, 9, 1, 1, 12, -1, 1) op_57 (v55[10:0], v56[8:0], v57[11:0]); // 20.0
    wire [9:0] v58; assign v58[9:0] = model_inp[343:334]; // 19.5
    wire [8:0] v59; assign v59[8:0] = model_inp[352:344]; // 19.5
    wire [10:0] v60; shift_adder #(10, 9, 1, 1, 11, 1, 1) op_60 (v58[9:0], v59[8:0], v60[10:0]); // 20.0
    wire [9:0] v61; assign v61[9:0] = model_inp[362:353]; // 19.5
    wire [9:0] v62; shift_adder #(9, 10, 1, 1, 10, 0, 0) op_62 (v26[8:0], v61[9:0], v62[9:0]); // 20.0
    wire [6:0] v63; assign v63[6:0] = model_inp[369:363]; // 19.5
    wire [8:0] v64; shift_adder #(7, 7, 0, 0, 9, 1, 1) op_64 (v3[6:0], v63[6:0], v64[8:0]); // 20.0
    wire [10:0] v65; assign v65[10:0] = model_inp[380:370]; // 19.5
    wire [11:0] v66; shift_adder #(11, 9, 1, 1, 12, 3, 1) op_66 (v65[10:0], v14[8:0], v66[11:0]); // 20.0
    wire [9:0] v67; assign v67[9:0] = model_inp[390:381]; // 19.5
    wire [6:0] v68; assign v68[6:0] = model_inp[397:391]; // 19.5
    wire [10:0] v69; shift_adder #(10, 7, 1, 1, 11, 3, 1) op_69 (v67[9:0], v68[6:0], v69[10:0]); // 20.0
    wire [9:0] v70; assign v70[9:0] = model_inp[407:398]; // 19.5
    wire [10:0] v71; assign v71[10:0] = model_inp[418:408]; // 19.5
    wire [10:0] v72; shift_adder #(10, 11, 1, 1, 11, 0, 0) op_72 (v70[9:0], v71[10:0], v72[10:0]); // 20.0
    wire [9:0] v73; assign v73[9:0] = model_inp[428:419]; // 19.5
    wire [10:0] v74; assign v74[10:0] = model_inp[439:429]; // 19.5
    wire [11:0] v75; shift_adder #(10, 11, 1, 1, 12, -1, 0) op_75 (v73[9:0], v74[10:0], v75[11:0]); // 20.0
    wire [10:0] v76; assign v76[10:0] = model_inp[450:440]; // 19.5
    wire [5:0] v77; assign v77[5:0] = model_inp[456:451]; // 19.5
    wire [11:0] v78; shift_adder #(11, 6, 1, 0, 12, 2, 1) op_78 (v76[10:0], v77[5:0], v78[11:0]); // 20.0
    wire [3:0] v79; assign v79[3:0] = model_inp[460:457]; // 19.5
    wire [8:0] v80; assign v80[8:0] = model_inp[469:461]; // 19.5
    wire [8:0] v81; shift_adder #(4, 9, 0, 1, 9, -1, 1) op_81 (v79[3:0], v80[8:0], v81[8:0]); // 20.0
    wire [10:0] v82; assign v82[10:0] = model_inp[480:470]; // 19.5
    wire [9:0] v83; assign v83[9:0] = model_inp[490:481]; // 19.5
    wire [11:0] v84; shift_adder #(11, 10, 1, 1, 12, -1, 1) op_84 (v82[10:0], v83[9:0], v84[11:0]); // 20.0
    wire [9:0] v85; assign v85[9:0] = model_inp[500:491]; // 19.5
    wire [10:0] v86; assign v86[10:0] = model_inp[511:501]; // 19.5
    wire [10:0] v87; shift_adder #(10, 11, 1, 1, 11, 0, 0) op_87 (v85[9:0], v86[10:0], v87[10:0]); // 20.0
    wire [9:0] v88; assign v88[9:0] = model_inp[521:512]; // 19.5
    wire [10:0] v89; shift_adder #(9, 10, 1, 1, 11, -1, 1) op_89 (v4[8:0], v88[9:0], v89[10:0]); // 20.0
    wire [11:0] v90; shift_adder #(11, 10, 1, 1, 12, -1, 1) op_90 (v2[10:0], v5[9:0], v90[11:0]); // 21.0
    wire [3:0] v91; assign v91[3:0] = model_inp[525:522]; // 19.5
    wire [10:0] v92; shift_adder #(4, 11, 0, 1, 11, -1, 1) op_92 (v91[3:0], v8[10:0], v92[10:0]); // 21.0
    wire [12:0] v93; shift_adder #(12, 11, 1, 1, 13, 1, 1) op_93 (v11[11:0], v13[10:0], v93[12:0]); // 21.0
    wire [12:0] v94; shift_adder #(13, 3, 1, 0, 13, 0, 1) op_94 (v93[12:0], 3'b100, v94[12:0]); // 21.0
    wire [11:0] v95; assign v95[11:0] = v94[11:0] & {12{~v94[12]}}; // 21.0
    wire [11:0] v96; shift_adder #(12, 3, 0, 0, 12, 0, 0) op_96 (v95[11:0], 3'b100, v96[11:0]); // 21.0
    wire [6:0] v97; assign v97[6:0] = v96[9:3]; // 21.0
    wire [11:0] v98; shift_adder #(11, 11, 1, 1, 12, 1, 0) op_98 (v16[10:0], v19[10:0], v98[11:0]); // 21.0
    wire [10:0] v99; shift_adder #(8, 11, 1, 1, 11, -1, 0) op_99 (v22[7:0], v25[10:0], v99[10:0]); // 21.0
    wire [11:0] v100; assign v100[11:0] = model_inp[537:526]; // 19.5
    wire [12:0] v101; shift_adder #(11, 12, 1, 1, 13, 0, 1) op_101 (v30[10:0], v100[11:0], v101[12:0]); // 21.0
    wire [11:0] v102; shift_adder #(11, 7, 1, 1, 12, 4, 1) op_102 (v42[10:0], v28[6:0], v102[11:0]); // 21.0
    wire [9:0] v103; assign v103[9:0] = model_inp[547:538]; // 19.5
    wire [11:0] v104; shift_adder #(11, 10, 1, 1, 12, 0, 1) op_104 (v48[10:0], v103[9:0], v104[11:0]); // 21.0
    wire [13:0] v105; shift_adder #(12, 13, 1, 1, 14, 0, 0) op_105 (v51[11:0], v53[12:0], v105[13:0]); // 21.0
    wire [3:0] v106; assign v106[3:0] = model_inp[551:548]; // 19.5
    wire [7:0] v107; shift_adder #(4, 8, 0, 1, 8, -1, 1) op_107 (v106[3:0], v54[7:0], v107[7:0]); // 21.0
    wire [11:0] v108; shift_adder #(12, 8, 1, 0, 12, 1, 1) op_108 (v57[11:0], v39[7:0], v108[11:0]); // 21.0
    wire [9:0] v109; shift_adder #(8, 9, 1, 1, 10, 1, 0) op_109 (v22[7:0], v64[8:0], v109[9:0]); // 21.0
    wire [8:0] v110; assign v110[8:0] = model_inp[560:552]; // 19.5
    wire [12:0] v111; shift_adder #(12, 9, 1, 1, 13, 2, 1) op_111 (v66[11:0], v110[8:0], v111[12:0]); // 21.0
    wire [11:0] v112; assign v112[11:0] = model_inp[572:561]; // 19.5
    wire [12:0] v113; shift_adder #(11, 12, 1, 1, 13, 0, 1) op_113 (v72[10:0], v112[11:0], v113[12:0]); // 21.0
    wire [10:0] v114; assign v114[10:0] = model_inp[583:573]; // 19.5
    wire [12:0] v115; shift_adder #(12, 11, 1, 1, 13, 1, 1) op_115 (v75[11:0], v114[10:0], v115[12:0]); // 21.0
    wire [11:0] v116; shift_adder #(12, 9, 1, 1, 12, 2, 0) op_116 (v78[11:0], v81[8:0], v116[11:0]); // 21.0
    wire [10:0] v117; assign v117[10:0] = model_inp[594:584]; // 19.5
    wire [12:0] v118; shift_adder #(11, 12, 1, 1, 13, -1, 0) op_118 (v117[10:0], v84[11:0], v118[12:0]); // 21.0
    wire [12:0] v119; shift_adder #(13, 5, 1, 0, 13, 0, 1) op_119 (v118[12:0], 5'b10000, v119[12:0]); // 21.0
    wire [11:0] v120; assign v120[11:0] = v119[11:0] & {12{~v119[12]}}; // 21.0
    wire [11:0] v121; shift_adder #(12, 4, 0, 0, 12, 0, 0) op_121 (v120[11:0], 4'b1000, v121[11:0]); // 21.0
    wire [5:0] v122; assign v122[5:0] = v121[9:4]; // 21.0
    wire [11:0] v123; shift_adder #(9, 11, 1, 1, 12, 0, 0) op_123 (v81[8:0], v87[10:0], v123[11:0]); // 21.0
    wire [11:0] v124; shift_adder #(12, 3, 1, 0, 12, 0, 1) op_124 (v123[11:0], 3'b100, v124[11:0]); // 21.0
    wire [8:0] v125; assign v125[8:0] = v124[8:0] & {9{~v124[11]}}; // 21.0
    wire [8:0] v126; shift_adder #(9, 2, 0, 0, 9, 0, 0) op_126 (v125[8:0], 2'b10, v126[8:0]); // 21.0
    wire [4:0] v127; assign v127[4:0] = v126[6:2]; // 21.0
    wire [8:0] v128; assign v128[8:0] = model_inp[603:595]; // 19.5
    wire [10:0] v129; shift_adder #(9, 11, 1, 1, 11, -1, 0) op_129 (v128[8:0], v89[10:0], v129[10:0]); // 21.0
    wire [13:0] v130; assign v130[13:0] = model_inp[617:604]; // 19.5
    wire [9:0] v131; assign v131[9:0] = model_inp[627:618]; // 19.5
    wire [3:0] v132; assign v132[3:0] = model_inp[631:628]; // 19.5
    wire [8:0] v133; assign v133[8:0] = model_inp[640:632]; // 19.5
    wire [4:0] v134; assign v134[4:0] = model_inp[645:641]; // 19.5
    wire [4:0] v135; assign v135[4:0] = model_inp[650:646]; // 19.5
    wire [5:0] v136; assign v136[5:0] = model_inp[656:651]; // 19.5
    wire [4:0] v137; assign v137[4:0] = model_inp[661:657]; // 19.5
    wire [8:0] v138; assign v138[8:0] = model_inp[670:662]; // 19.5
    wire [7:0] v139; assign v139[7:0] = model_inp[678:671]; // 19.5
    wire [4:0] v140; assign v140[4:0] = model_inp[683:679]; // 19.5
    wire [4:0] v141; assign v141[4:0] = model_inp[688:684]; // 19.5
    wire [2:0] v142; assign v142[2:0] = model_inp[691:689]; // 19.5

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[13:0] = v130[13:0];
    assign model_out[24:14] = v92[10:0];
    assign model_out[35:25] = v99[10:0];
    assign model_out[45:36] = v27[9:0];
    assign model_out[56:46] = v19[10:0];
    assign model_out[69:57] = v101[12:0];
    assign model_out[77:70] = v39[7:0];
    assign model_out[89:78] = v102[11:0];
    assign model_out[101:90] = v45[11:0];
    assign model_out[113:102] = v104[11:0];
    assign model_out[127:114] = v105[13:0];
    assign model_out[135:128] = v107[7:0];
    assign model_out[145:136] = v62[9:0];
    assign model_out[155:146] = v109[9:0];
    assign model_out[161:156] = v122[5:0];
    assign model_out[166:162] = v127[4:0];
    assign model_out[176:167] = v131[9:0];
    assign model_out[188:177] = v98[11:0];
    assign model_out[192:189] = v132[3:0];
    assign model_out[201:193] = v133[8:0];
    assign model_out[206:202] = v134[4:0];
    assign model_out[211:207] = v135[4:0];
    assign model_out[217:212] = v136[5:0];
    assign model_out[229:218] = v36[11:0];
    assign model_out[234:230] = v137[4:0];
    assign model_out[247:235] = v115[12:0];
    assign model_out[259:248] = v90[11:0];
    assign model_out[266:260] = v97[6:0];
    assign model_out[273:267] = v3[6:0];
    assign model_out[282:274] = v138[8:0];
    assign model_out[293:283] = v33[10:0];
    assign model_out[301:294] = v139[7:0];
    assign model_out[313:302] = v116[11:0];
    assign model_out[324:314] = v129[10:0];
    assign model_out[329:325] = v140[4:0];
    assign model_out[341:330] = v108[11:0];
    assign model_out[352:342] = v60[10:0];
    assign model_out[357:353] = v141[4:0];
    assign model_out[360:358] = v142[2:0];
    assign model_out[373:361] = v113[12:0];
    assign model_out[386:374] = v111[12:0];
    assign model_out[397:387] = v69[10:0];

endmodule
