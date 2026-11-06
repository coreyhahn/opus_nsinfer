`timescale 1 ns / 1 ps

module x310_clf_stage11 (
    input [616:0] model_inp,
    output [820:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [3:0] v0; assign v0[3:0] = model_inp[3:0]; // 16.5
    wire [4:0] v1; assign v1[4:0] = model_inp[8:4]; // 16.5
    wire [6:0] v2; shift_adder #(4, 5, 0, 0, 7, 1, 1) op_2 (v0[3:0], v1[4:0], v2[6:0]); // 17.0
    wire [3:0] v3; assign v3[3:0] = model_inp[12:9]; // 16.5
    wire [3:0] v4; assign v4[3:0] = model_inp[16:13]; // 16.5
    wire [4:0] v5; shift_adder #(4, 4, 0, 0, 5, 0, 1) op_5 (v3[3:0], v4[3:0], v5[4:0]); // 17.0
    wire [3:0] v6; assign v6[3:0] = model_inp[20:17]; // 16.5
    wire [3:0] v7; assign v7[3:0] = model_inp[24:21]; // 16.5
    wire [4:0] v8; shift_adder #(4, 4, 0, 0, 5, 0, 1) op_8 (v6[3:0], v7[3:0], v8[4:0]); // 17.0
    wire [4:0] v9; assign v9[4:0] = model_inp[29:25]; // 16.5
    wire [4:0] v10; assign v10[4:0] = model_inp[34:30]; // 16.5
    wire [5:0] v11; shift_adder #(5, 5, 0, 0, 6, 0, 1) op_11 (v9[4:0], v10[4:0], v11[5:0]); // 17.0
    wire [6:0] v12; assign v12[6:0] = model_inp[41:35]; // 16.5
    wire [9:0] v13; shift_adder #(7, 7, 0, 0, 10, -2, 1) op_13 (v12[6:0], v12[6:0], v13[9:0]); // 17.0
    wire [12:0] v14; assign v14[12:0] = model_inp[54:42]; // 16.5
    wire [10:0] v15; assign v15[10:0] = model_inp[65:55]; // 16.5
    wire [12:0] v16; shift_adder #(13, 11, 1, 1, 13, 1, 1) op_16 (v14[12:0], v15[10:0], v16[12:0]); // 17.0
    wire [12:0] v17; assign v17[12:0] = model_inp[78:66]; // 16.5
    wire [8:0] v18; assign v18[8:0] = model_inp[87:79]; // 16.5
    wire [12:0] v19; shift_adder #(13, 9, 1, 1, 13, 1, 1) op_19 (v17[12:0], v18[8:0], v19[12:0]); // 17.0
    wire [10:0] v20; assign v20[10:0] = v19[10:0] & {11{~v19[12]}}; // 17.0
    wire [10:0] v21; shift_adder #(11, 3, 0, 0, 11, 0, 0) op_21 (v20[10:0], 3'b100, v21[10:0]); // 17.0
    wire [4:0] v22; assign v22[4:0] = v21[7:3]; // 17.0
    wire [13:0] v23; assign v23[13:0] = model_inp[101:88]; // 16.5
    wire [13:0] v24; shift_adder #(11, 14, 1, 1, 14, -1, 0) op_24 (v15[10:0], v23[13:0], v24[13:0]); // 17.0
    wire [5:0] v25; assign v25[5:0] = model_inp[107:102]; // 16.5
    wire [9:0] v26; assign v26[9:0] = model_inp[117:108]; // 16.5
    wire [10:0] v27; shift_adder #(6, 10, 0, 0, 11, -1, 1) op_27 (v25[5:0], v26[9:0], v27[10:0]); // 17.0
    wire [4:0] v28; assign v28[4:0] = model_inp[122:118]; // 16.5
    wire [4:0] v29; assign v29[4:0] = model_inp[127:123]; // 16.5
    wire [6:0] v30; shift_adder #(5, 5, 0, 0, 7, -1, 0) op_30 (v28[4:0], v29[4:0], v30[6:0]); // 17.0
    wire [4:0] v31; assign v31[4:0] = model_inp[132:128]; // 16.5
    wire [6:0] v32; assign v32[6:0] = model_inp[139:133]; // 16.5
    wire [7:0] v33; shift_adder #(5, 7, 0, 1, 8, 1, 0) op_33 (v31[4:0], v32[6:0], v33[7:0]); // 17.0
    wire [4:0] v34; assign v34[4:0] = model_inp[144:140]; // 16.5
    wire [3:0] v35; assign v35[3:0] = model_inp[148:145]; // 16.5
    wire [5:0] v36; shift_adder #(5, 4, 0, 0, 6, 0, 0) op_36 (v34[4:0], v35[3:0], v36[5:0]); // 17.0
    wire [3:0] v37; assign v37[3:0] = model_inp[152:149]; // 16.5
    wire [4:0] v38; shift_adder #(4, 4, 0, 0, 5, 0, 0) op_38 (v37[3:0], v7[3:0], v38[4:0]); // 17.0
    wire [5:0] v39; assign v39[5:0] = model_inp[158:153]; // 16.5
    wire [5:0] v40; assign v40[5:0] = model_inp[164:159]; // 16.5
    wire [7:0] v41; shift_adder #(6, 6, 0, 1, 8, 1, 1) op_41 (v39[5:0], v40[5:0], v41[7:0]); // 17.0
    wire [0:0] v42; assign v42[0:0] = model_inp[165:165]; // 16.5
    wire [4:0] v43; shift_adder #(1, 4, 0, 0, 5, -2, 0) op_43 (v42[0:0], v3[3:0], v43[4:0]); // 17.0
    wire [8:0] v44; assign v44[8:0] = model_inp[174:166]; // 16.5
    wire [8:0] v45; shift_adder #(9, 5, 1, 0, 9, 2, 1) op_45 (v44[8:0], v28[4:0], v45[8:0]); // 17.0
    wire [8:0] v46; assign v46[8:0] = model_inp[183:175]; // 16.5
    wire [7:0] v47; assign v47[7:0] = model_inp[191:184]; // 16.5
    wire [9:0] v48; shift_adder #(9, 8, 1, 0, 10, 1, 0) op_48 (v46[8:0], v47[7:0], v48[9:0]); // 17.0
    wire [5:0] v49; assign v49[5:0] = model_inp[197:192]; // 16.5
    wire [6:0] v50; assign v50[6:0] = model_inp[204:198]; // 16.5
    wire [7:0] v51; shift_adder #(6, 7, 0, 0, 8, 0, 0) op_51 (v49[5:0], v50[6:0], v51[7:0]); // 17.0
    wire [3:0] v52; assign v52[3:0] = model_inp[208:205]; // 16.5
    wire [5:0] v53; shift_adder #(5, 4, 0, 0, 6, 1, 1) op_53 (v10[4:0], v52[3:0], v53[5:0]); // 17.0
    wire [4:0] v54; assign v54[4:0] = model_inp[213:209]; // 16.5
    wire [5:0] v55; assign v55[5:0] = model_inp[219:214]; // 16.5
    wire [7:0] v56; shift_adder #(5, 6, 0, 1, 8, 1, 0) op_56 (v54[4:0], v55[5:0], v56[7:0]); // 17.0
    wire [12:0] v57; assign v57[12:0] = model_inp[232:220]; // 16.5
    wire [10:0] v58; assign v58[10:0] = model_inp[243:233]; // 16.5
    wire [12:0] v59; shift_adder #(13, 11, 1, 1, 13, 0, 1) op_59 (v57[12:0], v58[10:0], v59[12:0]); // 17.0
    wire [12:0] v60; shift_adder #(13, 5, 1, 0, 13, 0, 1) op_60 (v59[12:0], 5'b10000, v60[12:0]); // 17.0
    wire [11:0] v61; assign v61[11:0] = v60[11:0] & {12{~v60[12]}}; // 17.0
    wire [11:0] v62; shift_adder #(12, 4, 0, 0, 12, 0, 0) op_62 (v61[11:0], 4'b1000, v62[11:0]); // 17.0
    wire [4:0] v63; assign v63[4:0] = v62[8:4]; // 17.0
    wire [6:0] v64; assign v64[6:0] = model_inp[250:244]; // 16.5
    wire [7:0] v65; shift_adder #(7, 5, 0, 0, 8, -1, 0) op_65 (v64[6:0], v10[4:0], v65[7:0]); // 17.0
    wire [4:0] v66; assign v66[4:0] = model_inp[255:251]; // 16.5
    wire [7:0] v67; shift_adder #(5, 5, 0, 0, 8, -2, 1) op_67 (v66[4:0], v66[4:0], v67[7:0]); // 17.0
    wire [5:0] v68; assign v68[5:0] = model_inp[261:256]; // 16.5
    wire [7:0] v69; shift_adder #(6, 6, 0, 0, 8, -1, 0) op_69 (v49[5:0], v68[5:0], v69[7:0]); // 17.0
    wire [9:0] v70; assign v70[9:0] = model_inp[271:262]; // 16.5
    wire [5:0] v71; assign v71[5:0] = model_inp[277:272]; // 16.5
    wire [9:0] v72; shift_adder #(10, 6, 1, 0, 10, 2, 1) op_72 (v70[9:0], v71[5:0], v72[9:0]); // 17.0
    wire [3:0] v73; assign v73[3:0] = model_inp[281:278]; // 16.5
    wire [4:0] v74; assign v74[4:0] = model_inp[286:282]; // 16.5
    wire [5:0] v75; shift_adder #(4, 5, 0, 0, 6, -1, 1) op_75 (v73[3:0], v74[4:0], v75[5:0]); // 17.0
    wire [5:0] v76; shift_adder #(4, 4, 0, 0, 6, 1, 1) op_76 (v6[3:0], v7[3:0], v76[5:0]); // 17.0
    wire [4:0] v77; assign v77[4:0] = model_inp[291:287]; // 16.5
    wire [8:0] v78; assign v78[8:0] = model_inp[300:292]; // 16.5
    wire [8:0] v79; shift_adder #(5, 9, 1, 1, 9, 0, 0) op_79 (v77[4:0], v78[8:0], v79[8:0]); // 17.0
    wire [5:0] v80; assign v80[5:0] = model_inp[306:301]; // 16.5
    wire [9:0] v81; shift_adder #(4, 6, 0, 1, 10, -4, 1) op_81 (v3[3:0], v80[5:0], v81[9:0]); // 17.0
    wire [7:0] v82; assign v82[7:0] = model_inp[314:307]; // 16.5
    wire [8:0] v83; shift_adder #(4, 8, 0, 1, 9, -2, 0) op_83 (v0[3:0], v82[7:0], v83[8:0]); // 17.0
    wire [2:0] v84; assign v84[2:0] = model_inp[317:315]; // 16.5
    wire [4:0] v85; shift_adder #(3, 4, 0, 0, 5, 0, 1) op_85 (v84[2:0], v35[3:0], v85[4:0]); // 17.0
    wire [2:0] v86; assign v86[2:0] = model_inp[320:318]; // 16.5
    wire [6:0] v87; shift_adder #(3, 5, 0, 0, 7, 1, 0) op_87 (v86[2:0], v10[4:0], v87[6:0]); // 17.0
    wire [7:0] v88; shift_adder #(7, 6, 0, 0, 8, 0, 0) op_88 (v12[6:0], v71[5:0], v88[7:0]); // 17.0
    wire [8:0] v89; shift_adder #(6, 8, 0, 1, 9, -1, 1) op_89 (v68[5:0], v82[7:0], v89[8:0]); // 17.0
    wire [4:0] v90; assign v90[4:0] = model_inp[325:321]; // 16.5
    wire [8:0] v91; shift_adder #(5, 7, 0, 1, 9, 1, 1) op_91 (v90[4:0], v32[6:0], v91[8:0]); // 17.0
    wire [4:0] v92; shift_adder #(4, 4, 0, 0, 5, 0, 0) op_92 (v6[3:0], v3[3:0], v92[4:0]); // 17.0
    wire [5:0] v93; shift_adder #(4, 4, 0, 0, 6, -1, 0) op_93 (v37[3:0], v7[3:0], v93[5:0]); // 17.0
    wire [3:0] v94; assign v94[3:0] = model_inp[329:326]; // 16.5
    wire [6:0] v95; shift_adder #(6, 4, 0, 0, 7, 1, 0) op_95 (v49[5:0], v94[3:0], v95[6:0]); // 17.0
    wire [7:0] v96; assign v96[7:0] = model_inp[337:330]; // 16.5
    wire [5:0] v97; assign v97[5:0] = model_inp[343:338]; // 16.5
    wire [8:0] v98; shift_adder #(8, 6, 1, 0, 9, 1, 0) op_98 (v96[7:0], v97[5:0], v98[8:0]); // 17.0
    wire [4:0] v99; assign v99[4:0] = model_inp[348:344]; // 16.5
    wire [6:0] v100; shift_adder #(5, 4, 0, 0, 7, 2, 0) op_100 (v99[4:0], v35[3:0], v100[6:0]); // 17.0
    wire [7:0] v101; shift_adder #(4, 5, 0, 0, 8, -3, 0) op_101 (v0[3:0], v10[4:0], v101[7:0]); // 17.0
    wire [5:0] v102; assign v102[5:0] = model_inp[354:349]; // 16.5
    wire [7:0] v103; shift_adder #(6, 6, 0, 0, 8, 1, 0) op_103 (v102[5:0], v39[5:0], v103[7:0]); // 17.0
    wire [4:0] v104; assign v104[4:0] = model_inp[359:355]; // 16.5
    wire [7:0] v105; shift_adder #(5, 5, 0, 0, 8, -2, 0) op_105 (v104[4:0], v28[4:0], v105[7:0]); // 17.0
    wire [8:0] v106; assign v106[8:0] = model_inp[368:360]; // 16.5
    wire [8:0] v107; shift_adder #(9, 6, 1, 1, 9, 1, 1) op_107 (v106[8:0], v40[5:0], v107[8:0]); // 17.0
    wire [8:0] v108; shift_adder #(6, 6, 0, 0, 9, -2, 1) op_108 (v49[5:0], v49[5:0], v108[8:0]); // 17.0
    wire [7:0] v109; shift_adder #(4, 7, 0, 0, 8, -2, 1) op_109 (v6[3:0], v12[6:0], v109[7:0]); // 17.0
    wire [4:0] v110; assign v110[4:0] = model_inp[373:369]; // 16.5
    wire [6:0] v111; assign v111[6:0] = model_inp[380:374]; // 16.5
    wire [7:0] v112; shift_adder #(5, 7, 0, 1, 8, 0, 0) op_112 (v110[4:0], v111[6:0], v112[7:0]); // 17.0
    wire [6:0] v113; assign v113[6:0] = model_inp[387:381]; // 16.5
    wire [7:0] v114; shift_adder #(7, 4, 0, 0, 8, 1, 0) op_114 (v113[6:0], v0[3:0], v114[7:0]); // 17.0
    wire [5:0] v115; assign v115[5:0] = model_inp[393:388]; // 16.5
    wire [8:0] v116; shift_adder #(6, 6, 0, 0, 9, -2, 0) op_116 (v39[5:0], v115[5:0], v116[8:0]); // 17.0
    wire [6:0] v117; shift_adder #(4, 5, 0, 0, 7, 1, 1) op_117 (v7[3:0], v74[4:0], v117[6:0]); // 17.0
    wire [5:0] v118; assign v118[5:0] = model_inp[399:394]; // 16.5
    wire [10:0] v119; shift_adder #(6, 6, 1, 0, 11, 3, 1) op_119 (v118[5:0], v102[5:0], v119[10:0]); // 17.0
    wire [5:0] v120; assign v120[5:0] = model_inp[405:400]; // 16.5
    wire [5:0] v121; assign v121[5:0] = model_inp[411:406]; // 16.5
    wire [7:0] v122; shift_adder #(6, 6, 1, 1, 8, -1, 0) op_122 (v120[5:0], v121[5:0], v122[7:0]); // 17.0
    wire [7:0] v123; shift_adder #(5, 6, 0, 0, 8, 1, 1) op_123 (v66[4:0], v68[5:0], v123[7:0]); // 17.0
    wire [5:0] v124; shift_adder #(5, 4, 0, 0, 6, 0, 1) op_124 (v28[4:0], v0[3:0], v124[5:0]); // 17.0
    wire [4:0] v125; assign v125[4:0] = model_inp[416:412]; // 16.5
    wire [9:0] v126; shift_adder #(5, 5, 1, 0, 10, 3, 1) op_126 (v125[4:0], v66[4:0], v126[9:0]); // 17.0
    wire [6:0] v127; assign v127[6:0] = model_inp[423:417]; // 16.5
    wire [7:0] v128; shift_adder #(7, 4, 1, 0, 8, 0, 1) op_128 (v127[6:0], v0[3:0], v128[7:0]); // 17.0
    wire [4:0] v129; assign v129[4:0] = model_inp[428:424]; // 16.5
    wire [5:0] v130; shift_adder #(4, 5, 0, 0, 6, -1, 0) op_130 (v0[3:0], v129[4:0], v130[5:0]); // 17.0
    wire [5:0] v131; shift_adder #(5, 4, 0, 0, 6, 1, 0) op_131 (v10[4:0], v35[3:0], v131[5:0]); // 17.0
    wire [8:0] v132; shift_adder #(5, 6, 0, 1, 9, 2, 0) op_132 (v10[4:0], v55[5:0], v132[8:0]); // 17.0
    wire [7:0] v133; assign v133[7:0] = model_inp[436:429]; // 16.5
    wire [6:0] v134; assign v134[6:0] = model_inp[443:437]; // 16.5
    wire [9:0] v135; shift_adder #(8, 7, 0, 0, 10, -1, 1) op_135 (v133[7:0], v134[6:0], v135[9:0]); // 17.0
    wire [6:0] v136; shift_adder #(4, 4, 0, 0, 7, 2, 1) op_136 (v3[3:0], v4[3:0], v136[6:0]); // 17.0
    wire [6:0] v137; assign v137[6:0] = model_inp[450:444]; // 16.5
    wire [8:0] v138; shift_adder #(7, 6, 0, 0, 9, 2, 0) op_138 (v137[6:0], v39[5:0], v138[8:0]); // 17.0
    wire [5:0] v139; assign v139[5:0] = model_inp[456:451]; // 16.5
    wire [6:0] v140; assign v140[6:0] = model_inp[463:457]; // 16.5
    wire [7:0] v141; shift_adder #(6, 7, 0, 1, 8, 1, 0) op_141 (v139[5:0], v140[6:0], v141[7:0]); // 17.0
    wire [9:0] v142; shift_adder #(7, 5, 0, 0, 10, 4, 1) op_142 (v12[6:0], v74[4:0], v142[9:0]); // 17.0
    wire [7:0] v143; assign v143[7:0] = model_inp[471:464]; // 16.5
    wire [8:0] v144; shift_adder #(8, 4, 0, 0, 9, 0, 1) op_144 (v143[7:0], v35[3:0], v144[8:0]); // 17.0
    wire [7:0] v145; assign v145[7:0] = model_inp[479:472]; // 16.5
    wire [8:0] v146; shift_adder #(6, 8, 1, 0, 9, 0, 0) op_146 (v118[5:0], v145[7:0], v146[8:0]); // 17.0
    wire [7:0] v147; shift_adder #(5, 7, 1, 1, 8, 0, 0) op_147 (v77[4:0], v111[6:0], v147[7:0]); // 17.0
    wire [6:0] v148; assign v148[6:0] = model_inp[486:480]; // 16.5
    wire [8:0] v149; shift_adder #(7, 5, 1, 0, 9, 2, 0) op_149 (v148[6:0], v66[4:0], v149[8:0]); // 17.0
    wire [7:0] v150; assign v150[7:0] = model_inp[494:487]; // 16.5
    wire [9:0] v151; shift_adder #(8, 8, 0, 0, 10, -2, 0) op_151 (v145[7:0], v150[7:0], v151[9:0]); // 17.0
    wire [5:0] v152; shift_adder #(4, 4, 0, 0, 6, -1, 0) op_152 (v3[3:0], v4[3:0], v152[5:0]); // 17.0
    wire [6:0] v153; assign v153[6:0] = model_inp[501:495]; // 16.5
    wire [6:0] v154; shift_adder #(4, 7, 0, 0, 7, 0, 0) op_154 (v3[3:0], v153[6:0], v154[6:0]); // 17.0
    wire [6:0] v155; assign v155[6:0] = model_inp[508:502]; // 16.5
    wire [7:0] v156; shift_adder #(7, 4, 1, 0, 8, 0, 1) op_156 (v155[6:0], v37[3:0], v156[7:0]); // 17.0
    wire [6:0] v157; assign v157[6:0] = model_inp[515:509]; // 16.5
    wire [9:0] v158; shift_adder #(7, 6, 0, 0, 10, 3, 1) op_158 (v157[6:0], v71[5:0], v158[9:0]); // 17.0
    wire [7:0] v159; assign v159[7:0] = model_inp[523:516]; // 16.5
    wire [8:0] v160; shift_adder #(5, 8, 0, 0, 9, -1, 1) op_160 (v66[4:0], v159[7:0], v160[8:0]); // 17.0
    wire [6:0] v161; shift_adder #(7, 4, 0, 0, 7, 1, 0) op_161 (v64[6:0], v0[3:0], v161[6:0]); // 17.0
    wire [5:0] v162; shift_adder #(5, 4, 0, 0, 6, 1, 1) op_162 (v104[4:0], v3[3:0], v162[5:0]); // 17.0
    wire [8:0] v163; shift_adder #(5, 7, 0, 1, 9, -2, 0) op_163 (v74[4:0], v155[6:0], v163[8:0]); // 17.0
    wire [6:0] v164; shift_adder #(3, 7, 0, 1, 7, -1, 0) op_164 (v86[2:0], v2[6:0], v164[6:0]); // 18.0
    wire [5:0] v165; shift_adder #(5, 5, 1, 1, 6, 0, 1) op_165 (v5[4:0], v8[4:0], v165[5:0]); // 18.0
    wire [6:0] v166; assign v166[6:0] = model_inp[530:524]; // 16.5
    wire [7:0] v167; shift_adder #(6, 7, 1, 0, 8, 0, 1) op_167 (v11[5:0], v166[6:0], v167[7:0]); // 18.0
    wire [9:0] v168; shift_adder #(4, 10, 0, 1, 10, 0, 1) op_168 (v94[3:0], v13[9:0], v168[9:0]); // 18.0
    wire [11:0] v169; assign v169[11:0] = model_inp[542:531]; // 16.5
    wire [13:0] v170; shift_adder #(13, 12, 1, 1, 14, 0, 1) op_170 (v16[12:0], v169[11:0], v170[13:0]); // 18.0
    wire [13:0] v171; shift_adder #(14, 4, 1, 0, 14, 0, 1) op_171 (v170[13:0], 4'b1000, v171[13:0]); // 18.0
    wire [11:0] v172; assign v172[11:0] = v171[11:0] & {12{~v171[13]}}; // 18.0
    wire [11:0] v173; shift_adder #(12, 4, 0, 0, 12, 0, 0) op_173 (v172[11:0], 4'b1000, v173[11:0]); // 18.0
    wire [4:0] v174; assign v174[4:0] = v173[8:4]; // 18.0
    wire [7:0] v175; shift_adder #(6, 5, 0, 0, 8, -1, 0) op_175 (v39[5:0], v22[4:0], v175[7:0]); // 18.0
    wire [4:0] v176; assign v176[4:0] = model_inp[547:543]; // 16.5
    wire [10:0] v177; shift_adder #(5, 11, 0, 1, 11, -2, 0) op_177 (v176[4:0], v27[10:0], v177[10:0]); // 18.0
    wire [7:0] v178; shift_adder #(7, 5, 0, 0, 8, 0, 1) op_178 (v30[6:0], v74[4:0], v178[7:0]); // 18.0
    wire [8:0] v179; shift_adder #(8, 6, 1, 0, 9, 1, 1) op_179 (v33[7:0], v36[5:0], v179[8:0]); // 18.0
    wire [3:0] v180; assign v180[3:0] = model_inp[551:548]; // 16.5
    wire [5:0] v181; shift_adder #(4, 5, 0, 0, 6, -1, 0) op_181 (v180[3:0], v38[4:0], v181[5:0]); // 18.0
    wire [8:0] v182; shift_adder #(8, 5, 1, 0, 9, 2, 0) op_182 (v41[7:0], v43[4:0], v182[8:0]); // 18.0
    wire [10:0] v183; shift_adder #(9, 10, 1, 1, 11, -1, 0) op_183 (v45[8:0], v48[9:0], v183[10:0]); // 18.0
    wire [7:0] v184; shift_adder #(5, 5, 0, 0, 8, -2, 1) op_184 (v66[4:0], v22[4:0], v184[7:0]); // 18.0
    wire [10:0] v185; shift_adder #(8, 6, 0, 1, 11, -2, 0) op_185 (v51[7:0], v53[5:0], v185[10:0]); // 18.0
    wire [6:0] v186; shift_adder #(5, 5, 0, 0, 7, -1, 1) op_186 (v63[4:0], v22[4:0], v186[6:0]); // 18.0
    wire [9:0] v187; shift_adder #(8, 8, 1, 0, 10, 0, 0) op_187 (v67[7:0], v69[7:0], v187[9:0]); // 18.0
    wire [6:0] v188; shift_adder #(6, 5, 0, 0, 7, 1, 1) op_188 (v39[5:0], v38[4:0], v188[6:0]); // 18.0
    wire [9:0] v189; shift_adder #(10, 5, 1, 1, 10, 4, 1) op_189 (v72[9:0], v8[4:0], v189[9:0]); // 18.0
    wire [7:0] v190; shift_adder #(6, 6, 0, 0, 8, 1, 0) op_190 (v102[5:0], v36[5:0], v190[7:0]); // 18.0
    wire [8:0] v191; shift_adder #(5, 6, 0, 1, 9, -2, 0) op_191 (v29[4:0], v75[5:0], v191[8:0]); // 18.0
    wire [6:0] v192; shift_adder #(5, 6, 1, 1, 7, 0, 0) op_192 (v5[4:0], v76[5:0], v192[6:0]); // 18.0
    wire [6:0] v193; shift_adder #(5, 5, 0, 0, 7, 1, 1) op_193 (v63[4:0], v28[4:0], v193[6:0]); // 18.0
    wire [9:0] v194; shift_adder #(9, 10, 1, 1, 10, -1, 0) op_194 (v79[8:0], v81[9:0], v194[9:0]); // 18.0
    wire [8:0] v195; shift_adder #(9, 5, 1, 1, 9, 2, 0) op_195 (v83[8:0], v85[4:0], v195[8:0]); // 18.0
    wire [8:0] v196; shift_adder #(7, 8, 0, 0, 9, 0, 1) op_196 (v87[6:0], v88[7:0], v196[8:0]); // 18.0
    wire [10:0] v197; shift_adder #(9, 9, 1, 1, 11, 1, 0) op_197 (v89[8:0], v91[8:0], v197[10:0]); // 18.0
    wire [8:0] v198; shift_adder #(8, 5, 1, 0, 9, 2, 0) op_198 (v56[7:0], v92[4:0], v198[8:0]); // 18.0
    wire [7:0] v199; shift_adder #(6, 7, 0, 0, 8, -1, 0) op_199 (v93[5:0], v95[6:0], v199[7:0]); // 18.0
    wire [9:0] v200; shift_adder #(9, 9, 1, 1, 10, 0, 0) op_200 (v44[8:0], v98[8:0], v200[9:0]); // 18.0
    wire [9:0] v201; shift_adder #(8, 6, 0, 1, 10, -1, 1) op_201 (v69[7:0], v80[5:0], v201[9:0]); // 18.0
    wire [6:0] v202; shift_adder #(5, 5, 0, 0, 7, -1, 0) op_202 (v22[4:0], v54[4:0], v202[6:0]); // 18.0
    wire [4:0] v203; assign v203[4:0] = model_inp[556:552]; // 16.5
    wire [7:0] v204; shift_adder #(5, 7, 0, 0, 8, -1, 0) op_204 (v203[4:0], v100[6:0], v204[7:0]); // 18.0
    wire [7:0] v205; shift_adder #(7, 6, 0, 1, 8, 1, 0) op_205 (v95[6:0], v76[5:0], v205[7:0]); // 18.0
    wire [9:0] v206; shift_adder #(8, 5, 0, 0, 10, -1, 1) op_206 (v103[7:0], v38[4:0], v206[9:0]); // 18.0
    wire [8:0] v207; shift_adder #(8, 8, 0, 0, 9, -1, 0) op_207 (v105[7:0], v101[7:0], v207[8:0]); // 18.0
    wire [9:0] v208; shift_adder #(5, 9, 0, 1, 10, -1, 0) op_208 (v43[4:0], v107[8:0], v208[9:0]); // 18.0
    wire [8:0] v209; shift_adder #(3, 8, 0, 1, 9, -3, 0) op_209 (v86[2:0], v67[7:0], v209[8:0]); // 18.0
    wire [8:0] v210; shift_adder #(8, 8, 0, 1, 9, 0, 0) op_210 (v103[7:0], v109[7:0], v210[8:0]); // 18.0
    wire [2:0] v211; assign v211[2:0] = model_inp[559:557]; // 16.5
    wire [7:0] v212; shift_adder #(3, 8, 0, 1, 8, 0, 1) op_212 (v211[2:0], v112[7:0], v212[7:0]); // 18.0
    wire [9:0] v213; shift_adder #(9, 7, 0, 1, 10, 1, 0) op_213 (v116[8:0], v117[6:0], v213[9:0]); // 18.0
    wire [7:0] v214; assign v214[7:0] = model_inp[567:560]; // 16.5
    wire [10:0] v215; shift_adder #(11, 8, 1, 0, 11, 0, 1) op_215 (v119[10:0], v214[7:0], v215[10:0]); // 18.0
    wire [8:0] v216; shift_adder #(5, 8, 0, 1, 9, -2, 0) op_216 (v66[4:0], v122[7:0], v216[8:0]); // 18.0
    wire [8:0] v217; shift_adder #(8, 6, 1, 1, 9, 1, 0) op_217 (v123[7:0], v124[5:0], v217[8:0]); // 18.0
    wire [6:0] v218; shift_adder #(5, 7, 0, 1, 7, 0, 0) op_218 (v63[4:0], v117[6:0], v218[6:0]); // 18.0
    wire [9:0] v219; shift_adder #(9, 10, 1, 1, 10, 0, 0) op_219 (v108[8:0], v126[9:0], v219[9:0]); // 18.0
    wire [8:0] v220; shift_adder #(5, 8, 0, 1, 9, -1, 0) op_220 (v22[4:0], v56[7:0], v220[8:0]); // 18.0
    wire [8:0] v221; shift_adder #(8, 6, 1, 0, 9, 1, 0) op_221 (v128[7:0], v130[5:0], v221[8:0]); // 18.0
    wire [6:0] v222; shift_adder #(5, 6, 1, 1, 7, -1, 0) op_222 (v5[4:0], v76[5:0], v222[6:0]); // 18.0
    wire [6:0] v223; shift_adder #(5, 6, 0, 0, 7, 0, 0) op_223 (v22[4:0], v131[5:0], v223[6:0]); // 18.0
    wire [10:0] v224; shift_adder #(9, 10, 1, 1, 11, 1, 0) op_224 (v132[8:0], v135[9:0], v224[10:0]); // 18.0
    wire [8:0] v225; shift_adder #(6, 8, 0, 1, 9, -1, 0) op_225 (v130[5:0], v123[7:0], v225[8:0]); // 18.0
    wire [7:0] v226; shift_adder #(5, 6, 1, 1, 8, -2, 0) op_226 (v8[4:0], v75[5:0], v226[7:0]); // 18.0
    wire [6:0] v227; assign v227[6:0] = model_inp[574:568]; // 16.5
    wire [9:0] v228; shift_adder #(7, 7, 1, 0, 10, -2, 1) op_228 (v136[6:0], v227[6:0], v228[9:0]); // 18.0
    wire [9:0] v229; shift_adder #(9, 8, 0, 1, 10, 0, 1) op_229 (v138[8:0], v41[7:0], v229[9:0]); // 18.0
    wire [6:0] v230; shift_adder #(5, 6, 0, 1, 7, 0, 0) op_230 (v63[4:0], v124[5:0], v230[6:0]); // 18.0
    wire [5:0] v231; shift_adder #(5, 5, 0, 0, 6, 0, 0) op_231 (v104[4:0], v63[4:0], v231[5:0]); // 18.0
    wire [10:0] v232; shift_adder #(8, 10, 1, 1, 11, -1, 0) op_232 (v141[7:0], v142[9:0], v232[10:0]); // 18.0
    wire [8:0] v233; shift_adder #(6, 7, 1, 1, 9, -2, 0) op_233 (v124[5:0], v2[6:0], v233[8:0]); // 18.0
    wire [9:0] v234; shift_adder #(5, 9, 0, 1, 10, -3, 1) op_234 (v10[4:0], v108[8:0], v234[9:0]); // 18.0
    wire [9:0] v235; shift_adder #(9, 8, 1, 1, 10, 1, 0) op_235 (v144[8:0], v67[7:0], v235[9:0]); // 18.0
    wire [9:0] v236; assign v236[9:0] = model_inp[584:575]; // 16.5
    wire [10:0] v237; shift_adder #(9, 10, 1, 0, 11, -1, 1) op_237 (v146[8:0], v236[9:0], v237[10:0]); // 18.0
    wire [8:0] v238; shift_adder #(5, 8, 0, 1, 9, -2, 0) op_238 (v22[4:0], v147[7:0], v238[8:0]); // 18.0
    wire [10:0] v239; shift_adder #(9, 10, 1, 0, 11, -1, 1) op_239 (v149[8:0], v151[9:0], v239[10:0]); // 18.0
    wire [8:0] v240; shift_adder #(8, 6, 0, 0, 9, 0, 1) op_240 (v101[7:0], v152[5:0], v240[8:0]); // 18.0
    wire [8:0] v241; shift_adder #(7, 8, 0, 0, 9, -1, 0) op_241 (v154[6:0], v103[7:0], v241[8:0]); // 18.0
    wire [6:0] v242; shift_adder #(6, 5, 0, 0, 7, 1, 0) op_242 (v130[5:0], v38[4:0], v242[6:0]); // 18.0
    wire [5:0] v243; assign v243[5:0] = model_inp[590:585]; // 16.5
    wire [8:0] v244; shift_adder #(6, 6, 0, 0, 9, -2, 1) op_244 (v36[5:0], v243[5:0], v244[8:0]); // 18.0
    wire [7:0] v245; shift_adder #(7, 5, 0, 0, 8, 2, 0) op_245 (v30[6:0], v63[4:0], v245[7:0]); // 18.0
    wire [9:0] v246; shift_adder #(8, 6, 1, 0, 10, 2, 1) op_246 (v156[7:0], v49[5:0], v246[9:0]); // 18.0
    wire [9:0] v247; shift_adder #(10, 7, 1, 0, 10, 1, 1) op_247 (v158[9:0], v100[6:0], v247[9:0]); // 18.0
    wire [8:0] v248; shift_adder #(6, 9, 0, 1, 9, -2, 0) op_248 (v152[5:0], v160[8:0], v248[8:0]); // 18.0
    wire [6:0] v249; shift_adder #(6, 5, 1, 1, 7, 1, 1) op_249 (v162[5:0], v85[4:0], v249[6:0]); // 18.0
    wire [9:0] v250; shift_adder #(6, 9, 0, 1, 10, -2, 0) op_250 (v93[5:0], v163[8:0], v250[9:0]); // 18.0
    wire [4:0] v251; assign v251[4:0] = model_inp[595:591]; // 16.5
    wire [5:0] v252; assign v252[5:0] = model_inp[601:596]; // 16.5
    wire [3:0] v253; assign v253[3:0] = model_inp[605:602]; // 16.5
    wire [3:0] v254; assign v254[3:0] = model_inp[609:606]; // 16.5
    wire [3:0] v255; assign v255[3:0] = model_inp[613:610]; // 16.5
    wire [2:0] v256; assign v256[2:0] = model_inp[616:614]; // 16.5

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[6:0] = v164[6:0];
    assign model_out[12:7] = v165[5:0];
    assign model_out[20:13] = v167[7:0];
    assign model_out[30:21] = v168[9:0];
    assign model_out[36:31] = v102[5:0];
    assign model_out[41:37] = v174[4:0];
    assign model_out[45:42] = v52[3:0];
    assign model_out[53:46] = v175[7:0];
    assign model_out[58:54] = v251[4:0];
    assign model_out[69:59] = v177[10:0];
    assign model_out[77:70] = v178[7:0];
    assign model_out[86:78] = v179[8:0];
    assign model_out[92:87] = v181[5:0];
    assign model_out[101:93] = v182[8:0];
    assign model_out[112:102] = v183[10:0];
    assign model_out[120:113] = v184[7:0];
    assign model_out[131:121] = v185[10:0];
    assign model_out[139:132] = v56[7:0];
    assign model_out[146:140] = v186[6:0];
    assign model_out[154:147] = v65[7:0];
    assign model_out[160:155] = v252[5:0];
    assign model_out[170:161] = v187[9:0];
    assign model_out[174:171] = v253[3:0];
    assign model_out[181:175] = v188[6:0];
    assign model_out[185:182] = v180[3:0];
    assign model_out[193:186] = v190[7:0];
    assign model_out[198:194] = v5[4:0];
    assign model_out[207:199] = v191[8:0];
    assign model_out[210:208] = v211[2:0];
    assign model_out[217:211] = v192[6:0];
    assign model_out[224:218] = v193[6:0];
    assign model_out[234:225] = v194[9:0];
    assign model_out[243:235] = v195[8:0];
    assign model_out[252:244] = v198[8:0];
    assign model_out[260:253] = v199[7:0];
    assign model_out[270:261] = v201[9:0];
    assign model_out[276:271] = v53[5:0];
    assign model_out[281:277] = v29[4:0];
    assign model_out[288:282] = v202[6:0];
    assign model_out[296:289] = v204[7:0];
    assign model_out[306:297] = v206[9:0];
    assign model_out[315:307] = v207[8:0];
    assign model_out[325:316] = v208[9:0];
    assign model_out[334:326] = v108[8:0];
    assign model_out[343:335] = v210[8:0];
    assign model_out[351:344] = v212[7:0];
    assign model_out[359:352] = v114[7:0];
    assign model_out[368:360] = v209[8:0];
    assign model_out[379:369] = v215[10:0];
    assign model_out[388:380] = v216[8:0];
    assign model_out[397:389] = v89[8:0];
    assign model_out[404:398] = v218[6:0];
    assign model_out[414:405] = v219[9:0];
    assign model_out[423:415] = v221[8:0];
    assign model_out[430:424] = v222[6:0];
    assign model_out[441:431] = v224[10:0];
    assign model_out[450:442] = v225[8:0];
    assign model_out[458:451] = v226[7:0];
    assign model_out[468:459] = v228[9:0];
    assign model_out[478:469] = v229[9:0];
    assign model_out[484:479] = v231[5:0];
    assign model_out[495:485] = v232[10:0];
    assign model_out[504:496] = v233[8:0];
    assign model_out[514:505] = v234[9:0];
    assign model_out[524:515] = v235[9:0];
    assign model_out[535:525] = v237[10:0];
    assign model_out[544:536] = v238[8:0];
    assign model_out[555:545] = v239[10:0];
    assign model_out[560:556] = v74[4:0];
    assign model_out[569:561] = v240[8:0];
    assign model_out[578:570] = v241[8:0];
    assign model_out[585:579] = v242[6:0];
    assign model_out[594:586] = v244[8:0];
    assign model_out[602:595] = v245[7:0];
    assign model_out[612:603] = v247[9:0];
    assign model_out[621:613] = v248[8:0];
    assign model_out[628:622] = v161[6:0];
    assign model_out[635:629] = v249[6:0];
    assign model_out[643:636] = v109[7:0];
    assign model_out[647:644] = v254[3:0];
    assign model_out[657:648] = v189[9:0];
    assign model_out[668:658] = v197[10:0];
    assign model_out[678:669] = v200[9:0];
    assign model_out[686:679] = v205[7:0];
    assign model_out[696:687] = v213[9:0];
    assign model_out[705:697] = v217[8:0];
    assign model_out[714:706] = v220[8:0];
    assign model_out[721:715] = v223[6:0];
    assign model_out[728:722] = v230[6:0];
    assign model_out[732:729] = v0[3:0];
    assign model_out[742:733] = v246[9:0];
    assign model_out[752:743] = v250[9:0];
    assign model_out[756:753] = v255[3:0];
    assign model_out[760:757] = v3[3:0];
    assign model_out[774:761] = v24[13:0];
    assign model_out[779:775] = v1[4:0];
    assign model_out[784:780] = v10[4:0];
    assign model_out[790:785] = v49[5:0];
    assign model_out[795:791] = v28[4:0];
    assign model_out[804:796] = v196[8:0];
    assign model_out[812:805] = v101[7:0];
    assign model_out[817:813] = v99[4:0];
    assign model_out[820:818] = v256[2:0];

endmodule
