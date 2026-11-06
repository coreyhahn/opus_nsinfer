`timescale 1 ns / 1 ps

module jsc_stage2 (
    input [2376:0] model_inp,
    output [1926:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [13:0] v0; assign v0[13:0] = model_inp[13:0]; // 2.0
    wire [15:0] v1; assign v1[15:0] = model_inp[29:14]; // 2.0
    wire [16:0] v2; shift_adder #(14, 16, 1, 1, 17, -2, 1) op_2 (v0[13:0], v1[15:0], v2[16:0]); // 3.0
    wire [12:0] v3; assign v3[12:0] = model_inp[42:30]; // 2.0
    wire [12:0] v4; assign v4[12:0] = model_inp[55:43]; // 2.0
    wire [15:0] v5; shift_adder #(13, 13, 1, 1, 16, -3, 1) op_5 (v3[12:0], v4[12:0], v5[15:0]); // 3.0
    wire [9:0] v6; assign v6[9:0] = model_inp[65:56]; // 2.0
    wire [13:0] v7; assign v7[13:0] = model_inp[79:66]; // 2.0
    wire [13:0] v8; shift_adder #(10, 14, 1, 1, 14, -2, 1) op_8 (v6[9:0], v7[13:0], v8[13:0]); // 3.0
    wire [12:0] v9; assign v9[12:0] = model_inp[92:80]; // 2.0
    wire [15:0] v10; assign v10[15:0] = model_inp[108:93]; // 2.0
    wire [15:0] v11; shift_adder #(13, 16, 1, 1, 16, 0, 0) op_11 (v9[12:0], v10[15:0], v11[15:0]); // 3.0
    wire [10:0] v12; assign v12[10:0] = model_inp[119:109]; // 2.0
    wire [11:0] v13; assign v13[11:0] = model_inp[131:120]; // 2.0
    wire [13:0] v14; shift_adder #(11, 12, 1, 1, 14, -2, 0) op_14 (v12[10:0], v13[11:0], v14[13:0]); // 3.0
    wire [11:0] v15; assign v15[11:0] = model_inp[143:132]; // 2.0
    wire [13:0] v16; assign v16[13:0] = model_inp[157:144]; // 2.0
    wire [15:0] v17; shift_adder #(12, 14, 1, 1, 16, -4, 0) op_17 (v15[11:0], v16[13:0], v17[15:0]); // 3.0
    wire [11:0] v18; assign v18[11:0] = model_inp[169:158]; // 2.0
    wire [10:0] v19; assign v19[10:0] = model_inp[180:170]; // 2.0
    wire [12:0] v20; shift_adder #(12, 11, 1, 1, 13, 1, 1) op_20 (v18[11:0], v19[10:0], v20[12:0]); // 3.0
    wire [6:0] v21; assign v21[6:0] = model_inp[187:181]; // 2.0
    wire [12:0] v22; assign v22[12:0] = model_inp[200:188]; // 2.0
    wire [12:0] v23; shift_adder #(7, 13, 1, 1, 13, -3, 0) op_23 (v21[6:0], v22[12:0], v23[12:0]); // 3.0
    wire [11:0] v24; assign v24[11:0] = model_inp[212:201]; // 2.0
    wire [9:0] v25; assign v25[9:0] = model_inp[222:213]; // 2.0
    wire [12:0] v26; shift_adder #(12, 10, 1, 1, 13, 2, 1) op_26 (v24[11:0], v25[9:0], v26[12:0]); // 3.0
    wire [8:0] v27; assign v27[8:0] = model_inp[231:223]; // 2.0
    wire [9:0] v28; assign v28[9:0] = model_inp[241:232]; // 2.0
    wire [12:0] v29; shift_adder #(9, 10, 1, 1, 13, -3, 1) op_29 (v27[8:0], v28[9:0], v29[12:0]); // 3.0
    wire [10:0] v30; assign v30[10:0] = model_inp[252:242]; // 2.0
    wire [15:0] v31; assign v31[15:0] = model_inp[268:253]; // 2.0
    wire [16:0] v32; shift_adder #(11, 16, 1, 1, 17, -4, 0) op_32 (v30[10:0], v31[15:0], v32[16:0]); // 3.0
    wire [10:0] v33; assign v33[10:0] = model_inp[279:269]; // 2.0
    wire [15:0] v34; assign v34[15:0] = model_inp[295:280]; // 2.0
    wire [15:0] v35; shift_adder #(11, 16, 1, 1, 16, -2, 0) op_35 (v33[10:0], v34[15:0], v35[15:0]); // 3.0
    wire [9:0] v36; assign v36[9:0] = model_inp[305:296]; // 2.0
    wire [12:0] v37; shift_adder #(10, 10, 1, 1, 13, 3, 1) op_37 (v25[9:0], v36[9:0], v37[12:0]); // 3.0
    wire [11:0] v38; assign v38[11:0] = model_inp[317:306]; // 2.0
    wire [11:0] v39; assign v39[11:0] = model_inp[329:318]; // 2.0
    wire [13:0] v40; shift_adder #(12, 12, 1, 1, 14, 2, 0) op_40 (v38[11:0], v39[11:0], v40[13:0]); // 3.0
    wire [15:0] v41; assign v41[15:0] = model_inp[345:330]; // 2.0
    wire [12:0] v42; assign v42[12:0] = model_inp[358:346]; // 2.0
    wire [15:0] v43; shift_adder #(16, 13, 1, 1, 16, 2, 1) op_43 (v41[15:0], v42[12:0], v43[15:0]); // 3.0
    wire [13:0] v44; assign v44[13:0] = model_inp[372:359]; // 2.0
    wire [9:0] v45; assign v45[9:0] = model_inp[382:373]; // 2.0
    wire [14:0] v46; shift_adder #(14, 10, 1, 1, 15, 3, 0) op_46 (v44[13:0], v45[9:0], v46[14:0]); // 3.0
    wire [11:0] v47; assign v47[11:0] = model_inp[394:383]; // 2.0
    wire [11:0] v48; assign v48[11:0] = model_inp[406:395]; // 2.0
    wire [13:0] v49; shift_adder #(12, 12, 1, 1, 14, -1, 0) op_49 (v47[11:0], v48[11:0], v49[13:0]); // 3.0
    wire [9:0] v50; assign v50[9:0] = model_inp[416:407]; // 2.0
    wire [11:0] v51; assign v51[11:0] = model_inp[428:417]; // 2.0
    wire [13:0] v52; shift_adder #(10, 12, 1, 1, 14, 2, 1) op_52 (v50[9:0], v51[11:0], v52[13:0]); // 3.0
    wire [11:0] v53; assign v53[11:0] = model_inp[440:429]; // 2.0
    wire [13:0] v54; assign v54[13:0] = model_inp[454:441]; // 2.0
    wire [14:0] v55; shift_adder #(12, 14, 1, 1, 15, 1, 1) op_55 (v53[11:0], v54[13:0], v55[14:0]); // 3.0
    wire [13:0] v56; assign v56[13:0] = model_inp[468:455]; // 2.0
    wire [15:0] v57; shift_adder #(16, 14, 1, 1, 16, 0, 0) op_57 (v1[15:0], v56[13:0], v57[15:0]); // 3.0
    wire [14:0] v58; assign v58[14:0] = model_inp[483:469]; // 2.0
    wire [10:0] v59; assign v59[10:0] = model_inp[494:484]; // 2.0
    wire [14:0] v60; shift_adder #(15, 11, 1, 1, 15, 3, 1) op_60 (v58[14:0], v59[10:0], v60[14:0]); // 3.0
    wire [12:0] v61; assign v61[12:0] = model_inp[507:495]; // 2.0
    wire [14:0] v62; assign v62[14:0] = model_inp[522:508]; // 2.0
    wire [16:0] v63; shift_adder #(13, 15, 1, 1, 17, -4, 1) op_63 (v61[12:0], v62[14:0], v63[16:0]); // 3.0
    wire [9:0] v64; assign v64[9:0] = model_inp[532:523]; // 2.0
    wire [14:0] v65; shift_adder #(10, 14, 1, 1, 15, -3, 0) op_65 (v64[9:0], v44[13:0], v65[14:0]); // 3.0
    wire [15:0] v66; assign v66[15:0] = model_inp[548:533]; // 2.0
    wire [17:0] v67; assign v67[17:0] = model_inp[566:549]; // 2.0
    wire [19:0] v68; shift_adder #(16, 18, 1, 1, 20, 2, 0) op_68 (v66[15:0], v67[17:0], v68[19:0]); // 3.0
    wire [8:0] v69; assign v69[8:0] = model_inp[575:567]; // 2.0
    wire [13:0] v70; assign v70[13:0] = model_inp[589:576]; // 2.0
    wire [13:0] v71; shift_adder #(9, 14, 1, 1, 14, -2, 1) op_71 (v69[8:0], v70[13:0], v71[13:0]); // 3.0
    wire [7:0] v72; assign v72[7:0] = model_inp[597:590]; // 2.0
    wire [9:0] v73; assign v73[9:0] = model_inp[607:598]; // 2.0
    wire [10:0] v74; shift_adder #(8, 10, 1, 1, 11, -1, 1) op_74 (v72[7:0], v73[9:0], v74[10:0]); // 3.0
    wire [12:0] v75; assign v75[12:0] = model_inp[620:608]; // 2.0
    wire [9:0] v76; assign v76[9:0] = model_inp[630:621]; // 2.0
    wire [14:0] v77; shift_adder #(13, 10, 1, 1, 15, 4, 1) op_77 (v75[12:0], v76[9:0], v77[14:0]); // 3.0
    wire [11:0] v78; assign v78[11:0] = model_inp[642:631]; // 2.0
    wire [15:0] v79; assign v79[15:0] = model_inp[658:643]; // 2.0
    wire [16:0] v80; shift_adder #(12, 16, 1, 1, 17, -3, 0) op_80 (v78[11:0], v79[15:0], v80[16:0]); // 3.0
    wire [14:0] v81; assign v81[14:0] = model_inp[673:659]; // 2.0
    wire [12:0] v82; assign v82[12:0] = model_inp[686:674]; // 2.0
    wire [15:0] v83; shift_adder #(15, 13, 1, 1, 16, -1, 1) op_83 (v81[14:0], v82[12:0], v83[15:0]); // 3.0
    wire [12:0] v84; assign v84[12:0] = model_inp[699:687]; // 2.0
    wire [13:0] v85; shift_adder #(12, 13, 1, 1, 14, -2, 0) op_85 (v47[11:0], v84[12:0], v85[13:0]); // 3.0
    wire [14:0] v86; assign v86[14:0] = model_inp[714:700]; // 2.0
    wire [9:0] v87; assign v87[9:0] = model_inp[724:715]; // 2.0
    wire [14:0] v88; shift_adder #(15, 10, 1, 1, 15, 1, 1) op_88 (v86[14:0], v87[9:0], v88[14:0]); // 3.0
    wire [10:0] v89; assign v89[10:0] = model_inp[735:725]; // 2.0
    wire [13:0] v90; shift_adder #(11, 14, 1, 1, 14, -1, 0) op_90 (v89[10:0], v16[13:0], v90[13:0]); // 3.0
    wire [10:0] v91; assign v91[10:0] = model_inp[746:736]; // 2.0
    wire [10:0] v92; assign v92[10:0] = model_inp[757:747]; // 2.0
    wire [11:0] v93; shift_adder #(11, 11, 1, 1, 12, 0, 0) op_93 (v91[10:0], v92[10:0], v93[11:0]); // 3.0
    wire [11:0] v94; assign v94[11:0] = model_inp[769:758]; // 2.0
    wire [15:0] v95; assign v95[15:0] = model_inp[785:770]; // 2.0
    wire [15:0] v96; shift_adder #(12, 16, 1, 1, 16, -1, 1) op_96 (v94[11:0], v95[15:0], v96[15:0]); // 3.0
    wire [3:0] v97; assign v97[3:0] = model_inp[789:786]; // 2.0
    wire [13:0] v98; assign v98[13:0] = model_inp[803:790]; // 2.0
    wire [13:0] v99; shift_adder #(4, 14, 1, 1, 14, -5, 0) op_99 (v97[3:0], v98[13:0], v99[13:0]); // 3.0
    wire [9:0] v100; assign v100[9:0] = model_inp[813:804]; // 2.0
    wire [13:0] v101; assign v101[13:0] = model_inp[827:814]; // 2.0
    wire [14:0] v102; shift_adder #(10, 14, 1, 1, 15, 1, 1) op_102 (v100[9:0], v101[13:0], v102[14:0]); // 3.0
    wire [15:0] v103; assign v103[15:0] = model_inp[843:828]; // 2.0
    wire [14:0] v104; assign v104[14:0] = model_inp[858:844]; // 2.0
    wire [16:0] v105; shift_adder #(16, 15, 1, 1, 17, -1, 0) op_105 (v103[15:0], v104[14:0], v105[16:0]); // 3.0
    wire [12:0] v106; assign v106[12:0] = model_inp[871:859]; // 2.0
    wire [12:0] v107; shift_adder #(13, 9, 1, 1, 13, 2, 0) op_107 (v106[12:0], v69[8:0], v107[12:0]); // 3.0
    wire [16:0] v108; assign v108[16:0] = model_inp[888:872]; // 2.0
    wire [8:0] v109; assign v109[8:0] = model_inp[897:889]; // 2.0
    wire [16:0] v110; shift_adder #(17, 9, 1, 1, 17, 5, 1) op_110 (v108[16:0], v109[8:0], v110[16:0]); // 3.0
    wire [8:0] v111; assign v111[8:0] = model_inp[906:898]; // 2.0
    wire [11:0] v112; assign v112[11:0] = model_inp[918:907]; // 2.0
    wire [11:0] v113; shift_adder #(9, 12, 1, 1, 12, -1, 1) op_113 (v111[8:0], v112[11:0], v113[11:0]); // 3.0
    wire [11:0] v114; assign v114[11:0] = model_inp[930:919]; // 2.0
    wire [12:0] v115; assign v115[12:0] = model_inp[943:931]; // 2.0
    wire [14:0] v116; shift_adder #(12, 13, 1, 1, 15, -3, 1) op_116 (v114[11:0], v115[12:0], v116[14:0]); // 3.0
    wire [13:0] v117; assign v117[13:0] = model_inp[957:944]; // 2.0
    wire [13:0] v118; shift_adder #(10, 14, 1, 1, 14, -3, 0) op_118 (v6[9:0], v117[13:0], v118[13:0]); // 3.0
    wire [12:0] v119; assign v119[12:0] = model_inp[970:958]; // 2.0
    wire [14:0] v120; assign v120[14:0] = model_inp[985:971]; // 2.0
    wire [15:0] v121; shift_adder #(13, 15, 1, 1, 16, -2, 1) op_121 (v119[12:0], v120[14:0], v121[15:0]); // 3.0
    wire [11:0] v122; assign v122[11:0] = model_inp[997:986]; // 2.0
    wire [13:0] v123; assign v123[13:0] = model_inp[1011:998]; // 2.0
    wire [14:0] v124; shift_adder #(12, 14, 1, 1, 15, -1, 0) op_124 (v122[11:0], v123[13:0], v124[14:0]); // 3.0
    wire [11:0] v125; assign v125[11:0] = model_inp[1023:1012]; // 2.0
    wire [13:0] v126; shift_adder #(13, 12, 1, 1, 14, 1, 0) op_126 (v106[12:0], v125[11:0], v126[13:0]); // 3.0
    wire [13:0] v127; assign v127[13:0] = model_inp[1037:1024]; // 2.0
    wire [13:0] v128; shift_adder #(14, 10, 1, 1, 14, 2, 0) op_128 (v127[13:0], v87[9:0], v128[13:0]); // 3.0
    wire [13:0] v129; assign v129[13:0] = model_inp[1051:1038]; // 2.0
    wire [11:0] v130; assign v130[11:0] = model_inp[1063:1052]; // 2.0
    wire [15:0] v131; shift_adder #(14, 12, 1, 1, 16, -2, 1) op_131 (v129[13:0], v130[11:0], v131[15:0]); // 3.0
    wire [11:0] v132; assign v132[11:0] = model_inp[1075:1064]; // 2.0
    wire [10:0] v133; assign v133[10:0] = model_inp[1086:1076]; // 2.0
    wire [12:0] v134; shift_adder #(12, 11, 1, 1, 13, 0, 1) op_134 (v132[11:0], v133[10:0], v134[12:0]); // 3.0
    wire [11:0] v135; assign v135[11:0] = model_inp[1098:1087]; // 2.0
    wire [9:0] v136; assign v136[9:0] = model_inp[1108:1099]; // 2.0
    wire [12:0] v137; shift_adder #(12, 10, 1, 1, 13, 3, 1) op_137 (v135[11:0], v136[9:0], v137[12:0]); // 3.0
    wire [14:0] v138; assign v138[14:0] = model_inp[1123:1109]; // 2.0
    wire [13:0] v139; assign v139[13:0] = model_inp[1137:1124]; // 2.0
    wire [16:0] v140; shift_adder #(15, 14, 1, 1, 17, 2, 0) op_140 (v138[14:0], v139[13:0], v140[16:0]); // 3.0
    wire [9:0] v141; shift_adder #(7, 10, 1, 1, 10, 0, 0) op_141 (v21[6:0], v45[9:0], v141[9:0]); // 3.0
    wire [12:0] v142; assign v142[12:0] = model_inp[1150:1138]; // 2.0
    wire [13:0] v143; assign v143[13:0] = model_inp[1164:1151]; // 2.0
    wire [15:0] v144; shift_adder #(13, 14, 1, 1, 16, 1, 0) op_144 (v142[12:0], v143[13:0], v144[15:0]); // 3.0
    wire [13:0] v145; assign v145[13:0] = model_inp[1178:1165]; // 2.0
    wire [13:0] v146; shift_adder #(14, 10, 1, 1, 14, 1, 1) op_146 (v145[13:0], v73[9:0], v146[13:0]); // 3.0
    wire [6:0] v147; assign v147[6:0] = model_inp[1185:1179]; // 2.0
    wire [14:0] v148; assign v148[14:0] = model_inp[1200:1186]; // 2.0
    wire [16:0] v149; shift_adder #(7, 15, 1, 1, 17, 2, 0) op_149 (v147[6:0], v148[14:0], v149[16:0]); // 3.0
    wire [8:0] v150; assign v150[8:0] = model_inp[1209:1201]; // 2.0
    wire [14:0] v151; shift_adder #(9, 15, 1, 1, 15, -2, 1) op_151 (v150[8:0], v148[14:0], v151[14:0]); // 3.0
    wire [11:0] v152; assign v152[11:0] = model_inp[1221:1210]; // 2.0
    wire [11:0] v153; assign v153[11:0] = model_inp[1233:1222]; // 2.0
    wire [13:0] v154; shift_adder #(12, 12, 1, 1, 14, 2, 0) op_154 (v152[11:0], v153[11:0], v154[13:0]); // 3.0
    wire [11:0] v155; assign v155[11:0] = model_inp[1245:1234]; // 2.0
    wire [9:0] v156; assign v156[9:0] = model_inp[1255:1246]; // 2.0
    wire [12:0] v157; shift_adder #(12, 10, 1, 1, 13, -1, 1) op_157 (v155[11:0], v156[9:0], v157[12:0]); // 3.0
    wire [14:0] v158; assign v158[14:0] = model_inp[1270:1256]; // 2.0
    wire [10:0] v159; assign v159[10:0] = model_inp[1281:1271]; // 2.0
    wire [14:0] v160; shift_adder #(15, 11, 1, 1, 15, 2, 1) op_160 (v158[14:0], v159[10:0], v160[14:0]); // 3.0
    wire [14:0] v161; assign v161[14:0] = model_inp[1296:1282]; // 2.0
    wire [10:0] v162; assign v162[10:0] = model_inp[1307:1297]; // 2.0
    wire [15:0] v163; shift_adder #(15, 11, 1, 1, 16, -1, 1) op_163 (v161[14:0], v162[10:0], v163[15:0]); // 3.0
    wire [15:0] v164; assign v164[15:0] = model_inp[1323:1308]; // 2.0
    wire [13:0] v165; assign v165[13:0] = model_inp[1337:1324]; // 2.0
    wire [15:0] v166; shift_adder #(16, 14, 1, 1, 16, 0, 1) op_166 (v164[15:0], v165[13:0], v166[15:0]); // 3.0
    wire [11:0] v167; assign v167[11:0] = model_inp[1349:1338]; // 2.0
    wire [8:0] v168; assign v168[8:0] = model_inp[1358:1350]; // 2.0
    wire [12:0] v169; shift_adder #(12, 9, 1, 1, 13, 3, 1) op_169 (v167[11:0], v168[8:0], v169[12:0]); // 3.0
    wire [11:0] v170; assign v170[11:0] = model_inp[1370:1359]; // 2.0
    wire [10:0] v171; assign v171[10:0] = model_inp[1381:1371]; // 2.0
    wire [13:0] v172; shift_adder #(12, 11, 1, 1, 14, -1, 1) op_172 (v170[11:0], v171[10:0], v172[13:0]); // 3.0
    wire [13:0] v173; shift_adder #(13, 11, 1, 1, 14, 1, 0) op_173 (v115[12:0], v133[10:0], v173[13:0]); // 3.0
    wire [10:0] v174; assign v174[10:0] = model_inp[1392:1382]; // 2.0
    wire [11:0] v175; assign v175[11:0] = model_inp[1404:1393]; // 2.0
    wire [12:0] v176; shift_adder #(11, 12, 1, 1, 13, -1, 0) op_176 (v174[10:0], v175[11:0], v176[12:0]); // 3.0
    wire [11:0] v177; assign v177[11:0] = model_inp[1416:1405]; // 2.0
    wire [12:0] v178; assign v178[12:0] = model_inp[1429:1417]; // 2.0
    wire [13:0] v179; shift_adder #(12, 13, 1, 1, 14, -2, 1) op_179 (v177[11:0], v178[12:0], v179[13:0]); // 3.0
    wire [11:0] v180; assign v180[11:0] = model_inp[1441:1430]; // 2.0
    wire [15:0] v181; assign v181[15:0] = model_inp[1457:1442]; // 2.0
    wire [15:0] v182; shift_adder #(12, 16, 1, 1, 16, 0, 0) op_182 (v180[11:0], v181[15:0], v182[15:0]); // 3.0
    wire [12:0] v183; assign v183[12:0] = model_inp[1470:1458]; // 2.0
    wire [16:0] v184; assign v184[16:0] = model_inp[1487:1471]; // 2.0
    wire [16:0] v185; shift_adder #(13, 17, 1, 1, 17, -1, 0) op_185 (v183[12:0], v184[16:0], v185[16:0]); // 3.0
    wire [9:0] v186; assign v186[9:0] = model_inp[1497:1488]; // 2.0
    wire [15:0] v187; assign v187[15:0] = model_inp[1513:1498]; // 2.0
    wire [15:0] v188; shift_adder #(10, 16, 1, 1, 16, -4, 1) op_188 (v186[9:0], v187[15:0], v188[15:0]); // 3.0
    wire [10:0] v189; shift_adder #(9, 11, 1, 1, 11, 0, 1) op_189 (v69[8:0], v159[10:0], v189[10:0]); // 3.0
    wire [12:0] v190; assign v190[12:0] = model_inp[1526:1514]; // 2.0
    wire [14:0] v191; assign v191[14:0] = model_inp[1541:1527]; // 2.0
    wire [15:0] v192; shift_adder #(13, 15, 1, 1, 16, -3, 1) op_192 (v190[12:0], v191[14:0], v192[15:0]); // 3.0
    wire [12:0] v193; assign v193[12:0] = model_inp[1554:1542]; // 2.0
    wire [13:0] v194; assign v194[13:0] = model_inp[1568:1555]; // 2.0
    wire [14:0] v195; shift_adder #(13, 14, 1, 1, 15, 1, 0) op_195 (v193[12:0], v194[13:0], v195[14:0]); // 3.0
    wire [13:0] v196; assign v196[13:0] = model_inp[1582:1569]; // 2.0
    wire [14:0] v197; shift_adder #(12, 14, 1, 1, 15, -1, 0) op_197 (v132[11:0], v196[13:0], v197[14:0]); // 3.0
    wire [12:0] v198; assign v198[12:0] = model_inp[1595:1583]; // 2.0
    wire [9:0] v199; assign v199[9:0] = model_inp[1605:1596]; // 2.0
    wire [12:0] v200; shift_adder #(13, 10, 1, 1, 13, 0, 0) op_200 (v198[12:0], v199[9:0], v200[12:0]); // 3.0
    wire [11:0] v201; assign v201[11:0] = model_inp[1617:1606]; // 2.0
    wire [8:0] v202; assign v202[8:0] = model_inp[1626:1618]; // 2.0
    wire [12:0] v203; shift_adder #(12, 9, 1, 1, 13, 4, 1) op_203 (v201[11:0], v202[8:0], v203[12:0]); // 3.0
    wire [12:0] v204; assign v204[12:0] = model_inp[1639:1627]; // 2.0
    wire [16:0] v205; assign v205[16:0] = model_inp[1656:1640]; // 2.0
    wire [16:0] v206; shift_adder #(13, 17, 1, 1, 17, -1, 0) op_206 (v204[12:0], v205[16:0], v206[16:0]); // 3.0
    wire [12:0] v207; assign v207[12:0] = model_inp[1669:1657]; // 2.0
    wire [13:0] v208; shift_adder #(13, 13, 1, 1, 14, 0, 1) op_208 (v207[12:0], v42[12:0], v208[13:0]); // 3.0
    wire [12:0] v209; assign v209[12:0] = model_inp[1682:1670]; // 2.0
    wire [13:0] v210; shift_adder #(13, 11, 1, 1, 14, 1, 1) op_210 (v209[12:0], v171[10:0], v210[13:0]); // 3.0
    wire [10:0] v211; assign v211[10:0] = model_inp[1693:1683]; // 2.0
    wire [13:0] v212; shift_adder #(11, 13, 1, 1, 14, -2, 0) op_212 (v211[10:0], v82[12:0], v212[13:0]); // 3.0
    wire [12:0] v213; assign v213[12:0] = model_inp[1706:1694]; // 2.0
    wire [13:0] v214; shift_adder #(12, 13, 1, 1, 14, -1, 1) op_214 (v48[11:0], v213[12:0], v214[13:0]); // 3.0
    wire [13:0] v215; assign v215[13:0] = model_inp[1720:1707]; // 2.0
    wire [14:0] v216; assign v216[14:0] = model_inp[1735:1721]; // 2.0
    wire [15:0] v217; shift_adder #(14, 15, 1, 1, 16, -1, 0) op_217 (v215[13:0], v216[14:0], v217[15:0]); // 3.0
    wire [12:0] v218; assign v218[12:0] = model_inp[1748:1736]; // 2.0
    wire [7:0] v219; assign v219[7:0] = model_inp[1756:1749]; // 2.0
    wire [13:0] v220; shift_adder #(13, 8, 1, 1, 14, 5, 1) op_220 (v218[12:0], v219[7:0], v220[13:0]); // 3.0
    wire [14:0] v221; assign v221[14:0] = model_inp[1771:1757]; // 2.0
    wire [16:0] v222; shift_adder #(15, 16, 1, 1, 17, 0, 0) op_222 (v221[14:0], v187[15:0], v222[16:0]); // 3.0
    wire [13:0] v223; assign v223[13:0] = model_inp[1785:1772]; // 2.0
    wire [14:0] v224; shift_adder #(9, 14, 1, 1, 15, -4, 0) op_224 (v111[8:0], v223[13:0], v224[14:0]); // 3.0
    wire [12:0] v225; shift_adder #(13, 7, 1, 0, 13, 0, 1) op_225 (v176[12:0], 7'b1000000, v225[12:0]); // 3.0
    wire [11:0] v226; assign v226[11:0] = v225[11:0] & {12{~v225[12]}}; // 3.0
    wire [11:0] v227; shift_adder #(12, 6, 0, 0, 12, 0, 0) op_227 (v226[11:0], 6'b100000, v227[11:0]); // 3.0
    wire [3:0] v228; assign v228[3:0] = v227[9:6]; // 3.0
    wire [12:0] v229; assign v229[12:0] = model_inp[1798:1786]; // 2.0
    wire [12:0] v230; shift_adder #(10, 13, 1, 1, 13, -1, 0) op_230 (v45[9:0], v229[12:0], v230[12:0]); // 3.0
    wire [16:0] v231; assign v231[16:0] = model_inp[1815:1799]; // 2.0
    wire [14:0] v232; assign v232[14:0] = model_inp[1830:1816]; // 2.0
    wire [18:0] v233; shift_adder #(17, 15, 1, 1, 19, 3, 0) op_233 (v231[16:0], v232[14:0], v233[18:0]); // 3.0
    wire [15:0] v234; assign v234[15:0] = model_inp[1846:1831]; // 2.0
    wire [10:0] v235; assign v235[10:0] = model_inp[1857:1847]; // 2.0
    wire [15:0] v236; shift_adder #(16, 11, 1, 1, 16, 1, 1) op_236 (v234[15:0], v235[10:0], v236[15:0]); // 3.0
    wire [10:0] v237; assign v237[10:0] = model_inp[1868:1858]; // 2.0
    wire [15:0] v238; shift_adder #(11, 16, 1, 1, 16, -1, 1) op_238 (v237[10:0], v1[15:0], v238[15:0]); // 3.0
    wire [13:0] v239; shift_adder #(10, 11, 1, 1, 14, 3, 1) op_239 (v156[9:0], v171[10:0], v239[13:0]); // 3.0
    wire [13:0] v240; assign v240[13:0] = model_inp[1882:1869]; // 2.0
    wire [9:0] v241; assign v241[9:0] = model_inp[1892:1883]; // 2.0
    wire [14:0] v242; shift_adder #(14, 10, 1, 1, 15, 4, 0) op_242 (v240[13:0], v241[9:0], v242[14:0]); // 3.0
    wire [11:0] v243; assign v243[11:0] = model_inp[1904:1893]; // 2.0
    wire [13:0] v244; shift_adder #(13, 12, 1, 1, 14, 1, 1) op_244 (v84[12:0], v243[11:0], v244[13:0]); // 3.0
    wire [11:0] v245; assign v245[11:0] = model_inp[1916:1905]; // 2.0
    wire [12:0] v246; shift_adder #(12, 10, 1, 1, 13, 1, 1) op_246 (v245[11:0], v241[9:0], v246[12:0]); // 3.0
    wire [11:0] v247; assign v247[11:0] = model_inp[1928:1917]; // 2.0
    wire [13:0] v248; shift_adder #(12, 12, 1, 1, 14, -1, 1) op_248 (v247[11:0], v112[11:0], v248[13:0]); // 3.0
    wire [11:0] v249; assign v249[11:0] = model_inp[1940:1929]; // 2.0
    wire [11:0] v250; assign v250[11:0] = model_inp[1952:1941]; // 2.0
    wire [13:0] v251; shift_adder #(12, 12, 1, 1, 14, 1, 1) op_251 (v249[11:0], v250[11:0], v251[13:0]); // 3.0
    wire [10:0] v252; assign v252[10:0] = model_inp[1963:1953]; // 2.0
    wire [13:0] v253; shift_adder #(11, 13, 1, 1, 14, -1, 0) op_253 (v252[10:0], v229[12:0], v253[13:0]); // 3.0
    wire [11:0] v254; assign v254[11:0] = model_inp[1975:1964]; // 2.0
    wire [13:0] v255; shift_adder #(12, 10, 1, 1, 14, 3, 1) op_255 (v254[11:0], v25[9:0], v255[13:0]); // 3.0
    wire [12:0] v256; assign v256[12:0] = model_inp[1988:1976]; // 2.0
    wire [13:0] v257; assign v257[13:0] = model_inp[2002:1989]; // 2.0
    wire [14:0] v258; shift_adder #(13, 14, 1, 1, 15, -1, 0) op_258 (v256[12:0], v257[13:0], v258[14:0]); // 3.0
    wire [11:0] v259; assign v259[11:0] = model_inp[2014:2003]; // 2.0
    wire [16:0] v260; shift_adder #(16, 12, 1, 1, 17, 1, 1) op_260 (v79[15:0], v259[11:0], v260[16:0]); // 3.0
    wire [13:0] v261; shift_adder #(14, 5, 1, 0, 14, 0, 1) op_261 (v14[13:0], 5'b10000, v261[13:0]); // 3.0
    wire [12:0] v262; assign v262[12:0] = v261[12:0] & {13{~v261[13]}}; // 3.0
    wire [12:0] v263; shift_adder #(13, 5, 0, 0, 13, 0, 0) op_263 (v262[12:0], 5'b10000, v263[12:0]); // 3.0
    wire [5:0] v264; assign v264[5:0] = v263[10:5]; // 3.0
    wire [15:0] v265; assign v265[15:0] = model_inp[2030:2015]; // 2.0
    wire [16:0] v266; shift_adder #(9, 16, 1, 1, 17, -6, 0) op_266 (v69[8:0], v265[15:0], v266[16:0]); // 3.0
    wire [13:0] v267; assign v267[13:0] = model_inp[2044:2031]; // 2.0
    wire [12:0] v268; assign v268[12:0] = model_inp[2057:2045]; // 2.0
    wire [14:0] v269; shift_adder #(14, 13, 1, 1, 15, 2, 1) op_269 (v267[13:0], v268[12:0], v269[14:0]); // 3.0
    wire [15:0] v270; shift_adder #(16, 11, 1, 0, 16, 0, 1) op_270 (v131[15:0], 11'b10100000000, v270[15:0]); // 3.0
    wire [14:0] v271; assign v271[14:0] = v270[14:0] & {15{~v270[15]}}; // 3.0
    wire [14:0] v272; shift_adder #(15, 7, 0, 0, 15, 0, 0) op_272 (v271[14:0], 7'b1000000, v272[14:0]); // 3.0
    wire [2:0] v273; assign v273[2:0] = v272[9:7]; // 3.0
    wire [12:0] v274; assign v274[12:0] = model_inp[2070:2058]; // 2.0
    wire [13:0] v275; assign v275[13:0] = model_inp[2084:2071]; // 2.0
    wire [14:0] v276; shift_adder #(13, 14, 1, 1, 15, 1, 1) op_276 (v274[12:0], v275[13:0], v276[14:0]); // 3.0
    wire [11:0] v277; assign v277[11:0] = model_inp[2096:2085]; // 2.0
    wire [12:0] v278; assign v278[12:0] = model_inp[2109:2097]; // 2.0
    wire [13:0] v279; shift_adder #(12, 13, 1, 1, 14, -1, 1) op_279 (v277[11:0], v278[12:0], v279[13:0]); // 3.0
    wire [16:0] v280; shift_adder #(17, 10, 1, 0, 17, 0, 1) op_280 (v32[16:0], 10'b1000000000, v280[16:0]); // 3.0
    wire [15:0] v281; assign v281[15:0] = v280[15:0] & {16{~v280[16]}}; // 3.0
    wire [15:0] v282; shift_adder #(16, 9, 0, 0, 16, 0, 0) op_282 (v281[15:0], 9'b100000000, v282[15:0]); // 3.0
    wire [4:0] v283; assign v283[4:0] = v282[13:9]; // 3.0
    wire [16:0] v284; assign v284[16:0] = model_inp[2126:2110]; // 2.0
    wire [14:0] v285; assign v285[14:0] = model_inp[2141:2127]; // 2.0
    wire [14:0] v286; assign v286[14:0] = model_inp[2156:2142]; // 2.0
    wire [11:0] v287; assign v287[11:0] = model_inp[2168:2157]; // 2.0
    wire [11:0] v288; assign v288[11:0] = model_inp[2180:2169]; // 2.0
    wire [13:0] v289; assign v289[13:0] = model_inp[2194:2181]; // 2.0
    wire [14:0] v290; assign v290[14:0] = model_inp[2209:2195]; // 2.0
    wire [11:0] v291; assign v291[11:0] = model_inp[2221:2210]; // 2.0
    wire [13:0] v292; assign v292[13:0] = model_inp[2235:2222]; // 2.0
    wire [11:0] v293; assign v293[11:0] = model_inp[2247:2236]; // 2.0
    wire [16:0] v294; assign v294[16:0] = model_inp[2264:2248]; // 2.0
    wire [16:0] v295; assign v295[16:0] = model_inp[2281:2265]; // 2.0
    wire [13:0] v296; assign v296[13:0] = model_inp[2295:2282]; // 2.0
    wire [13:0] v297; assign v297[13:0] = model_inp[2309:2296]; // 2.0
    wire [11:0] v298; assign v298[11:0] = model_inp[2321:2310]; // 2.0
    wire [13:0] v299; assign v299[13:0] = model_inp[2335:2322]; // 2.0
    wire [16:0] v300; assign v300[16:0] = model_inp[2352:2336]; // 2.0
    wire [7:0] v301; assign v301[7:0] = model_inp[2360:2353]; // 2.0
    wire [13:0] v302; assign v302[13:0] = model_inp[2374:2361]; // 2.0
    wire [1:0] v303; assign v303[1:0] = model_inp[2376:2375]; // 2.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[16:0] = v2[16:0];
    assign model_out[32:17] = v5[15:0];
    assign model_out[46:33] = v8[13:0];
    assign model_out[62:47] = v11[15:0];
    assign model_out[78:63] = v17[15:0];
    assign model_out[91:79] = v20[12:0];
    assign model_out[104:92] = v26[12:0];
    assign model_out[111:105] = v147[6:0];
    assign model_out[128:112] = v284[16:0];
    assign model_out[141:129] = v29[12:0];
    assign model_out[154:142] = v37[12:0];
    assign model_out[169:155] = v285[14:0];
    assign model_out[183:170] = v40[13:0];
    assign model_out[195:184] = v47[11:0];
    assign model_out[211:196] = v43[15:0];
    assign model_out[226:212] = v46[14:0];
    assign model_out[240:227] = v52[13:0];
    assign model_out[255:241] = v55[14:0];
    assign model_out[271:256] = v57[15:0];
    assign model_out[285:272] = v0[13:0];
    assign model_out[300:286] = v286[14:0];
    assign model_out[313:301] = v23[12:0];
    assign model_out[328:314] = v60[14:0];
    assign model_out[345:329] = v63[16:0];
    assign model_out[360:346] = v65[14:0];
    assign model_out[372:361] = v287[11:0];
    assign model_out[386:373] = v71[13:0];
    assign model_out[398:387] = v288[11:0];
    assign model_out[412:399] = v289[13:0];
    assign model_out[423:413] = v74[10:0];
    assign model_out[438:424] = v77[14:0];
    assign model_out[455:439] = v80[16:0];
    assign model_out[471:456] = v83[15:0];
    assign model_out[485:472] = v85[13:0];
    assign model_out[499:486] = v90[13:0];
    assign model_out[514:500] = v290[14:0];
    assign model_out[526:515] = v93[11:0];
    assign model_out[538:527] = v291[11:0];
    assign model_out[552:539] = v99[13:0];
    assign model_out[567:553] = v102[14:0];
    assign model_out[584:568] = v105[16:0];
    assign model_out[597:585] = v107[12:0];
    assign model_out[614:598] = v110[16:0];
    assign model_out[628:615] = v292[13:0];
    assign model_out[643:629] = v116[14:0];
    assign model_out[655:644] = v293[11:0];
    assign model_out[669:656] = v118[13:0];
    assign model_out[685:670] = v121[15:0];
    assign model_out[700:686] = v124[14:0];
    assign model_out[711:701] = v19[10:0];
    assign model_out[725:712] = v128[13:0];
    assign model_out[734:726] = v69[8:0];
    assign model_out[747:735] = v137[12:0];
    assign model_out[760:748] = v178[12:0];
    assign model_out[777:761] = v140[16:0];
    assign model_out[787:778] = v141[9:0];
    assign model_out[801:788] = v146[13:0];
    assign model_out[818:802] = v294[16:0];
    assign model_out[822:819] = v97[3:0];
    assign model_out[839:823] = v149[16:0];
    assign model_out[853:840] = v154[13:0];
    assign model_out[866:854] = v157[12:0];
    assign model_out[881:867] = v160[14:0];
    assign model_out[897:882] = v163[15:0];
    assign model_out[910:898] = v169[12:0];
    assign model_out[927:911] = v295[16:0];
    assign model_out[941:928] = v172[13:0];
    assign model_out[955:942] = v173[13:0];
    assign model_out[969:956] = v179[13:0];
    assign model_out[983:970] = v296[13:0];
    assign model_out[999:984] = v182[15:0];
    assign model_out[1013:1000] = v297[13:0];
    assign model_out[1025:1014] = v113[11:0];
    assign model_out[1037:1026] = v249[11:0];
    assign model_out[1054:1038] = v185[16:0];
    assign model_out[1065:1055] = v189[10:0];
    assign model_out[1076:1066] = v91[10:0];
    assign model_out[1091:1077] = v195[14:0];
    assign model_out[1103:1092] = v298[11:0];
    assign model_out[1118:1104] = v197[14:0];
    assign model_out[1131:1119] = v200[12:0];
    assign model_out[1145:1132] = v16[13:0];
    assign model_out[1158:1146] = v203[12:0];
    assign model_out[1175:1159] = v206[16:0];
    assign model_out[1189:1176] = v299[13:0];
    assign model_out[1206:1190] = v300[16:0];
    assign model_out[1220:1207] = v208[13:0];
    assign model_out[1234:1221] = v210[13:0];
    assign model_out[1248:1235] = v212[13:0];
    assign model_out[1264:1249] = v217[15:0];
    assign model_out[1280:1265] = v95[15:0];
    assign model_out[1294:1281] = v220[13:0];
    assign model_out[1311:1295] = v222[16:0];
    assign model_out[1326:1312] = v224[14:0];
    assign model_out[1339:1327] = v230[12:0];
    assign model_out[1352:1340] = v190[12:0];
    assign model_out[1371:1353] = v233[18:0];
    assign model_out[1387:1372] = v236[15:0];
    assign model_out[1403:1388] = v238[15:0];
    assign model_out[1411:1404] = v301[7:0];
    assign model_out[1425:1412] = v302[13:0];
    assign model_out[1440:1426] = v242[14:0];
    assign model_out[1454:1441] = v244[13:0];
    assign model_out[1467:1455] = v246[12:0];
    assign model_out[1481:1468] = v251[13:0];
    assign model_out[1495:1482] = v253[13:0];
    assign model_out[1509:1496] = v255[13:0];
    assign model_out[1524:1510] = v258[14:0];
    assign model_out[1541:1525] = v260[16:0];
    assign model_out[1556:1542] = v148[14:0];
    assign model_out[1571:1557] = v269[14:0];
    assign model_out[1586:1572] = v276[14:0];
    assign model_out[1600:1587] = v279[13:0];
    assign model_out[1605:1601] = v283[4:0];
    assign model_out[1608:1606] = v273[2:0];
    assign model_out[1614:1609] = v264[5:0];
    assign model_out[1618:1615] = v228[3:0];
    assign model_out[1632:1619] = v14[13:0];
    assign model_out[1648:1633] = v35[15:0];
    assign model_out[1662:1649] = v49[13:0];
    assign model_out[1682:1663] = v68[19:0];
    assign model_out[1697:1683] = v88[14:0];
    assign model_out[1713:1698] = v96[15:0];
    assign model_out[1727:1714] = v126[13:0];
    assign model_out[1740:1728] = v134[12:0];
    assign model_out[1756:1741] = v144[15:0];
    assign model_out[1771:1757] = v151[14:0];
    assign model_out[1787:1772] = v166[15:0];
    assign model_out[1803:1788] = v188[15:0];
    assign model_out[1819:1804] = v192[15:0];
    assign model_out[1821:1820] = v303[1:0];
    assign model_out[1835:1822] = v214[13:0];
    assign model_out[1849:1836] = v239[13:0];
    assign model_out[1863:1850] = v248[13:0];
    assign model_out[1880:1864] = v266[16:0];
    assign model_out[1893:1881] = v176[12:0];
    assign model_out[1910:1894] = v32[16:0];
    assign model_out[1926:1911] = v131[15:0];

endmodule
