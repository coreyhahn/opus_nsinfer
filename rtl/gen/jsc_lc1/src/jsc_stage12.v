`timescale 1 ns / 1 ps

module jsc_stage12 (
    input [629:0] model_inp,
    output [1085:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [4:0] v0; assign v0[4:0] = model_inp[4:0]; // 12.0
    wire [6:0] v1; assign v1[6:0] = model_inp[11:5]; // 12.0
    wire [7:0] v2; shift_adder #(5, 7, 0, 1, 8, -1, 1) op_2 (v0[4:0], v1[6:0], v2[7:0]); // 13.0
    wire [6:0] v3; assign v3[6:0] = model_inp[18:12]; // 12.0
    wire [6:0] v4; assign v4[6:0] = model_inp[25:19]; // 12.0
    wire [9:0] v5; shift_adder #(7, 7, 0, 0, 10, -2, 1) op_5 (v3[6:0], v4[6:0], v5[9:0]); // 13.0
    wire [5:0] v6; assign v6[5:0] = model_inp[31:26]; // 12.0
    wire [6:0] v7; assign v7[6:0] = model_inp[38:32]; // 12.0
    wire [10:0] v8; shift_adder #(6, 7, 1, 0, 11, 2, 1) op_8 (v6[5:0], v7[6:0], v8[10:0]); // 13.0
    wire [2:0] v9; assign v9[2:0] = model_inp[41:39]; // 12.0
    wire [5:0] v10; assign v10[5:0] = model_inp[47:42]; // 12.0
    wire [6:0] v11; shift_adder #(3, 6, 0, 0, 7, -3, 1) op_11 (v9[2:0], v10[5:0], v11[6:0]); // 13.0
    wire [4:0] v12; assign v12[4:0] = model_inp[52:48]; // 12.0
    wire [7:0] v13; shift_adder #(5, 7, 0, 0, 8, -2, 0) op_13 (v12[4:0], v4[6:0], v13[7:0]); // 13.0
    wire [4:0] v14; assign v14[4:0] = model_inp[57:53]; // 12.0
    wire [6:0] v15; shift_adder #(6, 5, 0, 0, 7, 0, 1) op_15 (v10[5:0], v14[4:0], v15[6:0]); // 13.0
    wire [7:0] v16; assign v16[7:0] = model_inp[65:58]; // 12.0
    wire [8:0] v17; assign v17[8:0] = model_inp[74:66]; // 12.0
    wire [9:0] v18; shift_adder #(8, 9, 0, 0, 10, -1, 0) op_18 (v16[7:0], v17[8:0], v18[9:0]); // 13.0
    wire [4:0] v19; assign v19[4:0] = model_inp[79:75]; // 12.0
    wire [4:0] v20; assign v20[4:0] = model_inp[84:80]; // 12.0
    wire [6:0] v21; shift_adder #(5, 5, 0, 0, 7, 1, 0) op_21 (v19[4:0], v20[4:0], v21[6:0]); // 13.0
    wire [6:0] v22; assign v22[6:0] = model_inp[91:85]; // 12.0
    wire [4:0] v23; assign v23[4:0] = model_inp[96:92]; // 12.0
    wire [7:0] v24; shift_adder #(7, 5, 1, 0, 8, 1, 0) op_24 (v22[6:0], v23[4:0], v24[7:0]); // 13.0
    wire [6:0] v25; assign v25[6:0] = model_inp[103:97]; // 12.0
    wire [7:0] v26; assign v26[7:0] = model_inp[111:104]; // 12.0
    wire [8:0] v27; shift_adder #(7, 8, 1, 1, 9, 0, 0) op_27 (v25[6:0], v26[7:0], v27[8:0]); // 13.0
    wire [3:0] v28; assign v28[3:0] = model_inp[115:112]; // 12.0
    wire [8:0] v29; assign v29[8:0] = model_inp[124:116]; // 12.0
    wire [8:0] v30; shift_adder #(4, 9, 0, 1, 9, 0, 1) op_30 (v28[3:0], v29[8:0], v30[8:0]); // 13.0
    wire [7:0] v31; assign v31[7:0] = model_inp[132:125]; // 12.0
    wire [4:0] v32; assign v32[4:0] = model_inp[137:133]; // 12.0
    wire [8:0] v33; shift_adder #(8, 5, 0, 0, 9, 0, 0) op_33 (v31[7:0], v32[4:0], v33[8:0]); // 13.0
    wire [4:0] v34; assign v34[4:0] = model_inp[142:138]; // 12.0
    wire [6:0] v35; assign v35[6:0] = model_inp[149:143]; // 12.0
    wire [7:0] v36; shift_adder #(5, 7, 0, 0, 8, -2, 1) op_36 (v34[4:0], v35[6:0], v36[7:0]); // 13.0
    wire [7:0] v37; assign v37[7:0] = model_inp[157:150]; // 12.0
    wire [8:0] v38; assign v38[8:0] = model_inp[166:158]; // 12.0
    wire [10:0] v39; shift_adder #(8, 9, 0, 1, 11, 2, 0) op_39 (v37[7:0], v38[8:0], v39[10:0]); // 13.0
    wire [6:0] v40; assign v40[6:0] = model_inp[173:167]; // 12.0
    wire [8:0] v41; shift_adder #(7, 7, 0, 0, 9, 1, 1) op_41 (v4[6:0], v40[6:0], v41[8:0]); // 13.0
    wire [7:0] v42; assign v42[7:0] = model_inp[181:174]; // 12.0
    wire [8:0] v43; shift_adder #(7, 8, 0, 0, 9, -1, 1) op_43 (v4[6:0], v42[7:0], v43[8:0]); // 13.0
    wire [7:0] v44; shift_adder #(5, 5, 0, 0, 8, -2, 1) op_44 (v20[4:0], v20[4:0], v44[7:0]); // 13.0
    wire [7:0] v45; assign v45[7:0] = model_inp[189:182]; // 12.0
    wire [4:0] v46; assign v46[4:0] = model_inp[194:190]; // 12.0
    wire [8:0] v47; shift_adder #(8, 5, 1, 0, 9, 2, 0) op_47 (v45[7:0], v46[4:0], v47[8:0]); // 13.0
    wire [8:0] v48; shift_adder #(9, 2, 1, 0, 9, 0, 0) op_48 (v47[8:0], 2'b10, v48[8:0]); // 13.0
    wire [8:0] v48_neg; negative #(9, 9, 1) op_neg_48 (v48, v48_neg);
    wire [5:0] v49; assign v49[5:0] = v48_neg[5:0] & {6{~v48_neg[8]}}; // 13.0
    wire [6:0] v50; shift_adder #(6, 3, 0, 0, 7, 0, 0) op_50 (v49[5:0], 3'b100, v50[6:0]); // 13.0
    wire [2:0] v51; assign v51[2:0] = v50[5:3]; // 13.0
    wire [7:0] v52; assign v52[7:0] = model_inp[202:195]; // 12.0
    wire [6:0] v53; assign v53[6:0] = model_inp[209:203]; // 12.0
    wire [8:0] v54; shift_adder #(8, 7, 1, 0, 9, 1, 1) op_54 (v52[7:0], v53[6:0], v54[8:0]); // 13.0
    wire [7:0] v55; assign v55[7:0] = model_inp[217:210]; // 12.0
    wire [8:0] v56; assign v56[8:0] = model_inp[226:218]; // 12.0
    wire [8:0] v57; shift_adder #(8, 9, 1, 1, 9, 0, 0) op_57 (v55[7:0], v56[8:0], v57[8:0]); // 13.0
    wire [5:0] v58; assign v58[5:0] = model_inp[232:227]; // 12.0
    wire [10:0] v59; shift_adder #(6, 9, 0, 0, 11, -4, 1) op_59 (v58[5:0], v17[8:0], v59[10:0]); // 13.0
    wire [5:0] v60; assign v60[5:0] = model_inp[238:233]; // 12.0
    wire [8:0] v61; shift_adder #(6, 8, 0, 0, 9, -1, 0) op_61 (v60[5:0], v31[7:0], v61[8:0]); // 13.0
    wire [3:0] v62; assign v62[3:0] = model_inp[242:239]; // 12.0
    wire [6:0] v63; shift_adder #(4, 7, 0, 0, 7, 0, 0) op_63 (v62[3:0], v35[6:0], v63[6:0]); // 13.0
    wire [10:0] v64; shift_adder #(8, 8, 0, 0, 11, -2, 1) op_64 (v31[7:0], v31[7:0], v64[10:0]); // 13.0
    wire [5:0] v65; assign v65[5:0] = model_inp[248:243]; // 12.0
    wire [7:0] v66; shift_adder #(6, 6, 0, 0, 8, -1, 0) op_66 (v65[5:0], v10[5:0], v66[7:0]); // 13.0
    wire [4:0] v67; assign v67[4:0] = model_inp[253:249]; // 12.0
    wire [5:0] v68; shift_adder #(5, 5, 0, 0, 6, 0, 0) op_68 (v20[4:0], v67[4:0], v68[5:0]); // 13.0
    wire [9:0] v69; shift_adder #(6, 9, 0, 0, 10, 0, 1) op_69 (v10[5:0], v17[8:0], v69[9:0]); // 13.0
    wire [3:0] v70; assign v70[3:0] = model_inp[257:254]; // 12.0
    wire [8:0] v71; shift_adder #(8, 4, 0, 0, 9, 0, 0) op_71 (v31[7:0], v70[3:0], v71[8:0]); // 13.0
    wire [8:0] v72; shift_adder #(8, 5, 0, 0, 9, 1, 1) op_72 (v16[7:0], v32[4:0], v72[8:0]); // 13.0
    wire [5:0] v73; assign v73[5:0] = model_inp[263:258]; // 12.0
    wire [9:0] v74; shift_adder #(9, 6, 0, 0, 10, 0, 1) op_74 (v17[8:0], v73[5:0], v74[9:0]); // 13.0
    wire [7:0] v75; assign v75[7:0] = model_inp[271:264]; // 12.0
    wire [8:0] v76; shift_adder #(8, 5, 0, 0, 9, 2, 0) op_76 (v75[7:0], v0[4:0], v76[8:0]); // 13.0
    wire [6:0] v77; shift_adder #(6, 5, 0, 0, 7, 0, 1) op_77 (v65[5:0], v32[4:0], v77[6:0]); // 13.0
    wire [6:0] v78; assign v78[6:0] = model_inp[278:272]; // 12.0
    wire [8:0] v79; shift_adder #(7, 5, 1, 0, 9, 2, 1) op_79 (v78[6:0], v12[4:0], v79[8:0]); // 13.0
    wire [8:0] v80; shift_adder #(8, 8, 0, 0, 9, 0, 0) op_80 (v16[7:0], v75[7:0], v80[8:0]); // 13.0
    wire [7:0] v81; assign v81[7:0] = model_inp[286:279]; // 12.0
    wire [9:0] v82; shift_adder #(8, 7, 0, 1, 10, 0, 0) op_82 (v81[7:0], v25[6:0], v82[9:0]); // 13.0
    wire [6:0] v83; assign v83[6:0] = model_inp[293:287]; // 12.0
    wire [8:0] v84; shift_adder #(5, 7, 0, 1, 9, 1, 0) op_84 (v20[4:0], v83[6:0], v84[8:0]); // 13.0
    wire [7:0] v85; shift_adder #(7, 6, 0, 0, 8, 1, 0) op_85 (v3[6:0], v10[5:0], v85[7:0]); // 13.0
    wire [8:0] v86; shift_adder #(7, 8, 0, 0, 9, 0, 0) op_86 (v3[6:0], v75[7:0], v86[8:0]); // 13.0
    wire [9:0] v87; shift_adder #(7, 9, 0, 0, 10, -1, 0) op_87 (v3[6:0], v17[8:0], v87[9:0]); // 13.0
    wire [6:0] v88; shift_adder #(6, 5, 0, 0, 7, 1, 1) op_88 (v10[5:0], v23[4:0], v88[6:0]); // 13.0
    wire [6:0] v89; assign v89[6:0] = model_inp[300:294]; // 12.0
    wire [7:0] v90; shift_adder #(7, 5, 1, 0, 8, 1, 1) op_90 (v89[6:0], v23[4:0], v90[7:0]); // 13.0
    wire [6:0] v91; assign v91[6:0] = model_inp[307:301]; // 12.0
    wire [6:0] v92; shift_adder #(5, 7, 0, 1, 7, 0, 1) op_92 (v67[4:0], v91[6:0], v92[6:0]); // 13.0
    wire [9:0] v93; shift_adder #(7, 9, 0, 0, 10, -2, 0) op_93 (v40[6:0], v17[8:0], v93[9:0]); // 13.0
    wire [10:0] v94; assign v94[10:0] = model_inp[318:308]; // 12.0
    wire [10:0] v95; assign v95[10:0] = model_inp[329:319]; // 12.0
    wire [11:0] v96; shift_adder #(11, 11, 0, 0, 12, 0, 0) op_96 (v94[10:0], v95[10:0], v96[11:0]); // 13.0
    wire [5:0] v97; shift_adder #(4, 5, 0, 0, 6, -1, 1) op_97 (v70[3:0], v23[4:0], v97[5:0]); // 13.0
    wire [6:0] v98; shift_adder #(5, 6, 0, 0, 7, 0, 0) op_98 (v12[4:0], v65[5:0], v98[6:0]); // 13.0
    wire [6:0] v99; shift_adder #(6, 6, 0, 0, 7, 0, 1) op_99 (v65[5:0], v60[5:0], v99[6:0]); // 13.0
    wire [9:0] v100; shift_adder #(7, 8, 0, 0, 10, 1, 0) op_100 (v3[6:0], v75[7:0], v100[9:0]); // 13.0
    wire [9:0] v101; shift_adder #(8, 7, 0, 1, 10, 2, 1) op_101 (v31[7:0], v83[6:0], v101[9:0]); // 13.0
    wire [9:0] v102; assign v102[9:0] = model_inp[339:330]; // 12.0
    wire [8:0] v103; assign v103[8:0] = model_inp[348:340]; // 12.0
    wire [10:0] v104; shift_adder #(10, 9, 1, 1, 11, 0, 0) op_104 (v102[9:0], v103[8:0], v104[10:0]); // 13.0
    wire [12:0] v105; shift_adder #(8, 5, 0, 0, 13, -4, 1) op_105 (v31[7:0], v67[4:0], v105[12:0]); // 13.0
    wire [5:0] v106; assign v106[5:0] = model_inp[354:349]; // 12.0
    wire [6:0] v107; shift_adder #(6, 5, 1, 0, 7, 0, 0) op_107 (v106[5:0], v20[4:0], v107[6:0]); // 13.0
    wire [6:0] v108; shift_adder #(5, 5, 0, 0, 7, 1, 1) op_108 (v67[4:0], v32[4:0], v108[6:0]); // 13.0
    wire [8:0] v109; shift_adder #(8, 8, 1, 1, 9, 0, 0) op_109 (v45[7:0], v55[7:0], v109[8:0]); // 13.0
    wire [7:0] v110; assign v110[7:0] = model_inp[362:355]; // 12.0
    wire [8:0] v111; shift_adder #(8, 8, 0, 0, 9, 0, 0) op_111 (v75[7:0], v110[7:0], v111[8:0]); // 13.0
    wire [7:0] v112; assign v112[7:0] = model_inp[370:363]; // 12.0
    wire [9:0] v113; shift_adder #(8, 7, 1, 0, 10, 1, 1) op_113 (v112[7:0], v40[6:0], v113[9:0]); // 13.0
    wire [7:0] v114; shift_adder #(6, 5, 0, 0, 8, 2, 0) op_114 (v65[5:0], v23[4:0], v114[7:0]); // 13.0
    wire [6:0] v115; assign v115[6:0] = model_inp[377:371]; // 12.0
    wire [9:0] v116; shift_adder #(9, 7, 0, 0, 10, 0, 0) op_116 (v17[8:0], v115[6:0], v116[9:0]); // 13.0
    wire [8:0] v117; shift_adder #(5, 6, 0, 0, 9, 2, 1) op_117 (v19[4:0], v65[5:0], v117[8:0]); // 13.0
    wire [8:0] v118; shift_adder #(8, 6, 0, 0, 9, 0, 1) op_118 (v75[7:0], v65[5:0], v118[8:0]); // 13.0
    wire [7:0] v119; assign v119[7:0] = model_inp[385:378]; // 12.0
    wire [8:0] v120; assign v120[8:0] = model_inp[394:386]; // 12.0
    wire [9:0] v121; shift_adder #(8, 9, 1, 1, 10, 0, 0) op_121 (v119[7:0], v120[8:0], v121[9:0]); // 13.0
    wire [10:0] v122; assign v122[10:0] = model_inp[405:395]; // 12.0
    wire [13:0] v123; shift_adder #(8, 11, 0, 1, 14, -5, 0) op_123 (v75[7:0], v122[10:0], v123[13:0]); // 13.0
    wire [5:0] v124; assign v124[5:0] = model_inp[411:406]; // 12.0
    wire [8:0] v125; shift_adder #(6, 8, 0, 1, 9, -1, 0) op_125 (v124[5:0], v55[7:0], v125[8:0]); // 13.0
    wire [11:0] v126; shift_adder #(7, 11, 1, 1, 12, -2, 0) op_126 (v91[6:0], v122[10:0], v126[11:0]); // 13.0
    wire [7:0] v127; assign v127[7:0] = model_inp[419:412]; // 12.0
    wire [8:0] v128; assign v128[8:0] = model_inp[428:420]; // 12.0
    wire [10:0] v129; shift_adder #(8, 9, 1, 1, 11, -2, 0) op_129 (v127[7:0], v128[8:0], v129[10:0]); // 13.0
    wire [9:0] v130; shift_adder #(3, 9, 0, 1, 10, -1, 0) op_130 (v9[2:0], v103[8:0], v130[9:0]); // 13.0
    wire [6:0] v131; assign v131[6:0] = model_inp[435:429]; // 12.0
    wire [5:0] v132; assign v132[5:0] = model_inp[441:436]; // 12.0
    wire [7:0] v133; shift_adder #(7, 6, 1, 0, 8, 0, 1) op_133 (v131[6:0], v132[5:0], v133[7:0]); // 13.0
    wire [9:0] v134; assign v134[9:0] = model_inp[451:442]; // 12.0
    wire [9:0] v135; shift_adder #(8, 10, 0, 1, 10, 0, 0) op_135 (v42[7:0], v134[9:0], v135[9:0]); // 13.0
    wire [7:0] v136; assign v136[7:0] = model_inp[459:452]; // 12.0
    wire [6:0] v137; assign v137[6:0] = model_inp[466:460]; // 12.0
    wire [9:0] v138; shift_adder #(8, 7, 0, 1, 10, 2, 1) op_138 (v136[7:0], v137[6:0], v138[9:0]); // 13.0
    wire [10:0] v139; shift_adder #(9, 9, 0, 1, 11, 1, 1) op_139 (v17[8:0], v120[8:0], v139[10:0]); // 13.0
    wire [7:0] v140; shift_adder #(6, 5, 0, 0, 8, 2, 0) op_140 (v73[5:0], v23[4:0], v140[7:0]); // 13.0
    wire [8:0] v141; assign v141[8:0] = model_inp[475:467]; // 12.0
    wire [13:0] v142; shift_adder #(9, 7, 1, 0, 14, 5, 1) op_142 (v141[8:0], v3[6:0], v142[13:0]); // 13.0
    wire [5:0] v143; shift_adder #(3, 5, 0, 0, 6, -1, 0) op_143 (v9[2:0], v67[4:0], v143[5:0]); // 13.0
    wire [10:0] v144; shift_adder #(5, 6, 0, 0, 11, -5, 0) op_144 (v23[4:0], v65[5:0], v144[10:0]); // 13.0
    wire [8:0] v145; shift_adder #(5, 8, 0, 1, 9, 0, 0) op_145 (v14[4:0], v26[7:0], v145[8:0]); // 13.0
    wire [9:0] v146; shift_adder #(7, 7, 0, 1, 10, -1, 1) op_146 (v4[6:0], v78[6:0], v146[9:0]); // 13.0
    wire [8:0] v147; shift_adder #(6, 8, 0, 1, 9, -1, 1) op_147 (v60[5:0], v26[7:0], v147[8:0]); // 13.0
    wire [10:0] v148; shift_adder #(7, 6, 1, 0, 11, -3, 1) op_148 (v137[6:0], v58[5:0], v148[10:0]); // 13.0
    wire [9:0] v149; shift_adder #(9, 5, 0, 0, 10, 1, 1) op_149 (v17[8:0], v14[4:0], v149[9:0]); // 13.0
    wire [6:0] v150; assign v150[6:0] = model_inp[482:476]; // 12.0
    wire [9:0] v151; assign v151[9:0] = model_inp[492:483]; // 12.0
    wire [11:0] v152; shift_adder #(7, 10, 0, 1, 12, -4, 0) op_152 (v150[6:0], v151[9:0], v152[11:0]); // 13.0
    wire [7:0] v153; assign v153[7:0] = model_inp[500:493]; // 12.0
    wire [9:0] v154; shift_adder #(8, 5, 1, 0, 10, 3, 0) op_154 (v153[7:0], v0[4:0], v154[9:0]); // 13.0
    wire [7:0] v155; assign v155[7:0] = model_inp[508:501]; // 12.0
    wire [8:0] v156; shift_adder #(5, 8, 0, 1, 9, -1, 0) op_156 (v0[4:0], v155[7:0], v156[8:0]); // 13.0
    wire [11:0] v157; shift_adder #(8, 6, 0, 0, 12, 5, 1) op_157 (v75[7:0], v132[5:0], v157[11:0]); // 13.0
    wire [10:0] v158; shift_adder #(8, 5, 0, 0, 11, -2, 0) op_158 (v16[7:0], v67[4:0], v158[10:0]); // 13.0
    wire [8:0] v159; shift_adder #(7, 5, 0, 0, 9, 3, 1) op_159 (v4[6:0], v20[4:0], v159[8:0]); // 13.0
    wire [13:0] v160; assign v160[13:0] = model_inp[522:509]; // 12.0
    wire [14:0] v161; shift_adder #(7, 14, 0, 1, 15, -4, 0) op_161 (v35[6:0], v160[13:0], v161[14:0]); // 13.0
    wire [9:0] v162; shift_adder #(5, 5, 0, 0, 10, 4, 1) op_162 (v20[4:0], v14[4:0], v162[9:0]); // 13.0
    wire [5:0] v163; assign v163[5:0] = model_inp[528:523]; // 12.0
    wire [7:0] v164; shift_adder #(6, 7, 0, 1, 8, 0, 0) op_164 (v163[5:0], v78[6:0], v164[7:0]); // 13.0
    wire [6:0] v165; assign v165[6:0] = model_inp[535:529]; // 12.0
    wire [8:0] v166; shift_adder #(7, 8, 0, 0, 9, 0, 0) op_166 (v165[6:0], v37[7:0], v166[8:0]); // 13.0
    wire [9:0] v167; assign v167[9:0] = model_inp[545:536]; // 12.0
    wire [10:0] v168; shift_adder #(10, 5, 1, 0, 11, 1, 1) op_168 (v167[9:0], v0[4:0], v168[10:0]); // 13.0
    wire [5:0] v169; assign v169[5:0] = model_inp[551:546]; // 12.0
    wire [8:0] v170; shift_adder #(6, 5, 0, 0, 9, 3, 1) op_170 (v169[5:0], v14[4:0], v170[8:0]); // 13.0
    wire [7:0] v171; shift_adder #(5, 6, 0, 0, 8, 1, 0) op_171 (v20[4:0], v73[5:0], v171[7:0]); // 13.0
    wire [6:0] v172; assign v172[6:0] = model_inp[558:552]; // 12.0
    wire [11:0] v173; shift_adder #(7, 6, 0, 0, 12, 5, 1) op_173 (v172[6:0], v132[5:0], v173[11:0]); // 13.0
    wire [8:0] v174; assign v174[8:0] = model_inp[567:559]; // 12.0
    wire [7:0] v175; assign v175[7:0] = model_inp[575:568]; // 12.0
    wire [10:0] v176; shift_adder #(9, 8, 1, 0, 11, 1, 0) op_176 (v174[8:0], v175[7:0], v176[10:0]); // 13.0
    wire [6:0] v177; assign v177[6:0] = model_inp[582:576]; // 12.0
    wire [7:0] v178; shift_adder #(7, 5, 1, 0, 8, -1, 0) op_178 (v177[6:0], v20[4:0], v178[7:0]); // 13.0
    wire [9:0] v179; shift_adder #(7, 8, 0, 0, 10, -2, 1) op_179 (v3[6:0], v16[7:0], v179[9:0]); // 13.0
    wire [6:0] v180; assign v180[6:0] = model_inp[589:583]; // 12.0
    wire [7:0] v181; shift_adder #(7, 6, 1, 0, 8, 0, 0) op_181 (v180[6:0], v169[5:0], v181[7:0]); // 13.0
    wire [8:0] v182; shift_adder #(8, 5, 1, 0, 9, 1, 1) op_182 (v153[7:0], v20[4:0], v182[8:0]); // 13.0
    wire [8:0] v183; assign v183[8:0] = model_inp[598:590]; // 12.0
    wire [8:0] v184; shift_adder #(9, 6, 0, 0, 9, 0, 0) op_184 (v183[8:0], v10[5:0], v184[8:0]); // 13.0
    wire [6:0] v185; assign v185[6:0] = model_inp[605:599]; // 12.0
    wire [7:0] v186; shift_adder #(7, 6, 0, 0, 8, 1, 1) op_186 (v185[6:0], v124[5:0], v186[7:0]); // 13.0
    wire [7:0] v187; assign v187[7:0] = model_inp[613:606]; // 12.0
    wire [8:0] v188; shift_adder #(8, 8, 0, 0, 9, -1, 0) op_188 (v187[7:0], v136[7:0], v188[8:0]); // 13.0
    wire [5:0] v189; assign v189[5:0] = model_inp[619:614]; // 12.0
    wire [5:0] v190; assign v190[5:0] = model_inp[625:620]; // 12.0
    wire [3:0] v191; assign v191[3:0] = model_inp[629:626]; // 12.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[7:0] = v2[7:0];
    assign model_out[17:8] = v5[9:0];
    assign model_out[28:18] = v8[10:0];
    assign model_out[35:29] = v11[6:0];
    assign model_out[43:36] = v13[7:0];
    assign model_out[50:44] = v15[6:0];
    assign model_out[60:51] = v18[9:0];
    assign model_out[66:61] = v10[5:0];
    assign model_out[74:67] = v24[7:0];
    assign model_out[83:75] = v27[8:0];
    assign model_out[87:84] = v62[3:0];
    assign model_out[96:88] = v33[8:0];
    assign model_out[104:97] = v36[7:0];
    assign model_out[115:105] = v39[10:0];
    assign model_out[124:116] = v43[8:0];
    assign model_out[133:125] = v41[8:0];
    assign model_out[141:134] = v44[7:0];
    assign model_out[150:142] = v54[8:0];
    assign model_out[157:151] = v21[6:0];
    assign model_out[166:158] = v57[8:0];
    assign model_out[177:167] = v59[10:0];
    assign model_out[184:178] = v4[6:0];
    assign model_out[193:185] = v61[8:0];
    assign model_out[200:194] = v63[6:0];
    assign model_out[207:201] = v150[6:0];
    assign model_out[215:208] = v66[7:0];
    assign model_out[221:216] = v68[5:0];
    assign model_out[231:222] = v69[9:0];
    assign model_out[240:232] = v72[8:0];
    assign model_out[250:241] = v74[9:0];
    assign model_out[259:251] = v76[8:0];
    assign model_out[266:260] = v35[6:0];
    assign model_out[272:267] = v189[5:0];
    assign model_out[279:273] = v77[6:0];
    assign model_out[288:280] = v79[8:0];
    assign model_out[297:289] = v80[8:0];
    assign model_out[307:298] = v82[9:0];
    assign model_out[316:308] = v84[8:0];
    assign model_out[321:317] = v23[4:0];
    assign model_out[329:322] = v85[7:0];
    assign model_out[338:330] = v86[8:0];
    assign model_out[348:339] = v87[9:0];
    assign model_out[351:349] = v9[2:0];
    assign model_out[358:352] = v88[6:0];
    assign model_out[366:359] = v90[7:0];
    assign model_out[372:367] = v65[5:0];
    assign model_out[379:373] = v92[6:0];
    assign model_out[389:380] = v93[9:0];
    assign model_out[395:390] = v97[5:0];
    assign model_out[402:396] = v98[6:0];
    assign model_out[410:403] = v16[7:0];
    assign model_out[417:411] = v99[6:0];
    assign model_out[423:418] = v190[5:0];
    assign model_out[433:424] = v100[9:0];
    assign model_out[443:434] = v101[9:0];
    assign model_out[452:444] = v30[8:0];
    assign model_out[463:453] = v104[10:0];
    assign model_out[476:464] = v105[12:0];
    assign model_out[481:477] = v19[4:0];
    assign model_out[488:482] = v107[6:0];
    assign model_out[495:489] = v108[6:0];
    assign model_out[504:496] = v120[8:0];
    assign model_out[513:505] = v29[8:0];
    assign model_out[522:514] = v111[8:0];
    assign model_out[532:523] = v113[9:0];
    assign model_out[540:533] = v114[7:0];
    assign model_out[549:541] = v117[8:0];
    assign model_out[558:550] = v118[8:0];
    assign model_out[568:559] = v121[9:0];
    assign model_out[582:569] = v123[13:0];
    assign model_out[591:583] = v125[8:0];
    assign model_out[603:592] = v126[11:0];
    assign model_out[609:604] = v124[5:0];
    assign model_out[620:610] = v129[10:0];
    assign model_out[630:621] = v130[9:0];
    assign model_out[635:631] = v0[4:0];
    assign model_out[643:636] = v133[7:0];
    assign model_out[653:644] = v135[9:0];
    assign model_out[663:654] = v138[9:0];
    assign model_out[668:664] = v12[4:0];
    assign model_out[679:669] = v139[10:0];
    assign model_out[687:680] = v75[7:0];
    assign model_out[698:688] = v64[10:0];
    assign model_out[706:699] = v140[7:0];
    assign model_out[720:707] = v142[13:0];
    assign model_out[726:721] = v143[5:0];
    assign model_out[737:727] = v144[10:0];
    assign model_out[746:738] = v145[8:0];
    assign model_out[756:747] = v146[9:0];
    assign model_out[765:757] = v147[8:0];
    assign model_out[776:766] = v148[10:0];
    assign model_out[784:777] = v31[7:0];
    assign model_out[796:785] = v152[11:0];
    assign model_out[806:797] = v154[9:0];
    assign model_out[815:807] = v156[8:0];
    assign model_out[826:816] = v94[10:0];
    assign model_out[831:827] = v67[4:0];
    assign model_out[841:832] = v149[9:0];
    assign model_out[853:842] = v157[11:0];
    assign model_out[864:854] = v158[10:0];
    assign model_out[873:865] = v159[8:0];
    assign model_out[888:874] = v161[14:0];
    assign model_out[898:889] = v162[9:0];
    assign model_out[906:899] = v164[7:0];
    assign model_out[915:907] = v166[8:0];
    assign model_out[922:916] = v131[6:0];
    assign model_out[931:923] = v170[8:0];
    assign model_out[939:932] = v171[7:0];
    assign model_out[950:940] = v176[10:0];
    assign model_out[958:951] = v178[7:0];
    assign model_out[966:959] = v181[7:0];
    assign model_out[975:967] = v182[8:0];
    assign model_out[984:976] = v184[8:0];
    assign model_out[992:985] = v186[7:0];
    assign model_out[1001:993] = v188[8:0];
    assign model_out[1011:1002] = v179[9:0];
    assign model_out[1014:1012] = v51[2:0];
    assign model_out[1023:1015] = v71[8:0];
    assign model_out[1035:1024] = v96[11:0];
    assign model_out[1044:1036] = v109[8:0];
    assign model_out[1048:1045] = v191[3:0];
    assign model_out[1058:1049] = v116[9:0];
    assign model_out[1062:1059] = v28[3:0];
    assign model_out[1073:1063] = v168[10:0];
    assign model_out[1085:1074] = v173[11:0];

endmodule
