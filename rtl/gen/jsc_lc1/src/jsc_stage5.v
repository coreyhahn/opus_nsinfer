`timescale 1 ns / 1 ps

module jsc_stage5 (
    input [914:0] model_inp,
    output [1300:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [17:0] v0; assign v0[17:0] = model_inp[17:0]; // 5.0
    wire [12:0] v1; assign v1[12:0] = model_inp[30:18]; // 5.0
    wire [17:0] v2; shift_adder #(18, 13, 1, 1, 18, 3, 1) op_2 (v0[17:0], v1[12:0], v2[17:0]); // 6.0
    wire [17:0] v3; shift_adder #(18, 7, 1, 0, 18, 0, 0) op_3 (v2[17:0], 7'b1100000, v3[17:0]); // 6.0
    wire [16:0] v4; assign v4[16:0] = v3[16:0] & {17{~v3[17]}}; // 6.0
    wire [16:0] v5; shift_adder #(17, 7, 0, 0, 17, 0, 0) op_5 (v4[16:0], 7'b1000000, v5[16:0]); // 6.0
    wire [4:0] v6; assign v6[4:0] = v5[11:7]; // 6.0
    wire [16:0] v7; assign v7[16:0] = model_inp[47:31]; // 5.0
    wire [17:0] v8; assign v8[17:0] = model_inp[65:48]; // 5.0
    wire [18:0] v9; shift_adder #(17, 18, 1, 1, 19, 0, 0) op_9 (v7[16:0], v8[17:0], v9[18:0]); // 6.0
    wire [18:0] v10; shift_adder #(19, 11, 1, 0, 19, 0, 1) op_10 (v9[18:0], 11'b10100000000, v10[18:0]); // 6.0
    wire [17:0] v11; assign v11[17:0] = v10[17:0] & {18{~v10[18]}}; // 6.0
    wire [17:0] v12; shift_adder #(18, 9, 0, 0, 18, 0, 0) op_12 (v11[17:0], 9'b100000000, v12[17:0]); // 6.0
    wire [6:0] v13; assign v13[6:0] = v12[15:9]; // 6.0
    wire [3:0] v14; assign v14[3:0] = model_inp[69:66]; // 5.0
    wire [4:0] v15; assign v15[4:0] = model_inp[74:70]; // 5.0
    wire [6:0] v16; shift_adder #(4, 5, 0, 0, 7, -2, 0) op_16 (v14[3:0], v15[4:0], v16[6:0]); // 6.0
    wire [5:0] v17; assign v17[5:0] = model_inp[80:75]; // 5.0
    wire [5:0] v18; assign v18[5:0] = model_inp[86:81]; // 5.0
    wire [7:0] v19; shift_adder #(6, 6, 0, 0, 8, 1, 1) op_19 (v17[5:0], v18[5:0], v19[7:0]); // 6.0
    wire [17:0] v20; assign v20[17:0] = model_inp[104:87]; // 5.0
    wire [15:0] v21; assign v21[15:0] = model_inp[120:105]; // 5.0
    wire [17:0] v22; shift_adder #(18, 16, 1, 1, 18, 0, 1) op_22 (v20[17:0], v21[15:0], v22[17:0]); // 6.0
    wire [17:0] v23; shift_adder #(18, 10, 1, 0, 18, 0, 1) op_23 (v22[17:0], 10'b1000000000, v23[17:0]); // 6.0
    wire [16:0] v24; assign v24[16:0] = v23[16:0] & {17{~v23[17]}}; // 6.0
    wire [16:0] v25; shift_adder #(17, 9, 0, 0, 17, 0, 0) op_25 (v24[16:0], 9'b100000000, v25[16:0]); // 6.0
    wire [5:0] v26; assign v26[5:0] = v25[14:9]; // 6.0
    wire [7:0] v27; assign v27[7:0] = model_inp[128:121]; // 5.0
    wire [10:0] v28; shift_adder #(8, 8, 0, 0, 11, -2, 1) op_28 (v27[7:0], v27[7:0], v28[10:0]); // 6.0
    wire [4:0] v29; assign v29[4:0] = model_inp[133:129]; // 5.0
    wire [4:0] v30; assign v30[4:0] = model_inp[138:134]; // 5.0
    wire [6:0] v31; shift_adder #(5, 5, 0, 0, 7, -1, 0) op_31 (v29[4:0], v30[4:0], v31[6:0]); // 6.0
    wire [4:0] v32; assign v32[4:0] = model_inp[143:139]; // 5.0
    wire [6:0] v33; shift_adder #(6, 5, 0, 0, 7, 1, 0) op_33 (v17[5:0], v32[4:0], v33[6:0]); // 6.0
    wire [3:0] v34; assign v34[3:0] = model_inp[147:144]; // 5.0
    wire [5:0] v35; assign v35[5:0] = model_inp[153:148]; // 5.0
    wire [6:0] v36; shift_adder #(4, 6, 0, 0, 7, -2, 1) op_36 (v34[3:0], v35[5:0], v36[6:0]); // 6.0
    wire [17:0] v37; assign v37[17:0] = model_inp[171:154]; // 5.0
    wire [17:0] v38; shift_adder #(18, 16, 1, 1, 18, 0, 1) op_38 (v37[17:0], v21[15:0], v38[17:0]); // 6.0
    wire [17:0] v39; shift_adder #(18, 11, 1, 0, 18, 0, 1) op_39 (v38[17:0], 11'b11100000000, v39[17:0]); // 6.0
    wire [16:0] v40; assign v40[16:0] = v39[16:0] & {17{~v39[17]}}; // 6.0
    wire [16:0] v41; shift_adder #(17, 8, 0, 0, 17, 0, 0) op_41 (v40[16:0], 8'b10000000, v41[16:0]); // 6.0
    wire [5:0] v42; assign v42[5:0] = v41[13:8]; // 6.0
    wire [4:0] v43; assign v43[4:0] = model_inp[176:172]; // 5.0
    wire [3:0] v44; assign v44[3:0] = model_inp[180:177]; // 5.0
    wire [5:0] v45; shift_adder #(5, 4, 0, 0, 6, 1, 0) op_45 (v43[4:0], v44[3:0], v45[5:0]); // 6.0
    wire [15:0] v46; assign v46[15:0] = model_inp[196:181]; // 5.0
    wire [15:0] v47; assign v47[15:0] = model_inp[212:197]; // 5.0
    wire [17:0] v48; shift_adder #(16, 16, 1, 1, 18, 1, 0) op_48 (v46[15:0], v47[15:0], v48[17:0]); // 6.0
    wire [17:0] v49; shift_adder #(18, 9, 1, 0, 18, 0, 1) op_49 (v48[17:0], 9'b111110000, v49[17:0]); // 6.0
    wire [16:0] v50; assign v50[16:0] = v49[16:0] & {17{~v49[17]}}; // 6.0
    wire [16:0] v51; shift_adder #(17, 7, 0, 0, 17, 0, 0) op_51 (v50[16:0], 7'b1000000, v51[16:0]); // 6.0
    wire [4:0] v52; assign v52[4:0] = v51[11:7]; // 6.0
    wire [7:0] v53; assign v53[7:0] = model_inp[220:213]; // 5.0
    wire [7:0] v54; assign v54[7:0] = model_inp[228:221]; // 5.0
    wire [8:0] v55; shift_adder #(8, 8, 0, 0, 9, 0, 0) op_55 (v53[7:0], v54[7:0], v55[8:0]); // 6.0
    wire [17:0] v56; assign v56[17:0] = model_inp[246:229]; // 5.0
    wire [16:0] v57; assign v57[16:0] = model_inp[263:247]; // 5.0
    wire [18:0] v58; shift_adder #(18, 17, 1, 1, 19, 1, 1) op_58 (v56[17:0], v57[16:0], v58[18:0]); // 6.0
    wire [18:0] v59; shift_adder #(19, 9, 1, 0, 19, 0, 1) op_59 (v58[18:0], 9'b101000000, v59[18:0]); // 6.0
    wire [17:0] v60; assign v60[17:0] = v59[17:0] & {18{~v59[18]}}; // 6.0
    wire [17:0] v61; shift_adder #(18, 6, 0, 0, 18, 0, 0) op_61 (v60[17:0], 6'b100000, v61[17:0]); // 6.0
    wire [7:0] v62; assign v62[7:0] = v61[13:6]; // 6.0
    wire [5:0] v63; assign v63[5:0] = model_inp[269:264]; // 5.0
    wire [7:0] v64; shift_adder #(6, 6, 0, 0, 8, -1, 0) op_64 (v35[5:0], v63[5:0], v64[7:0]); // 6.0
    wire [5:0] v65; assign v65[5:0] = model_inp[275:270]; // 5.0
    wire [7:0] v66; shift_adder #(5, 6, 0, 0, 8, 1, 0) op_66 (v43[4:0], v65[5:0], v66[7:0]); // 6.0
    wire [9:0] v67; assign v67[9:0] = model_inp[285:276]; // 5.0
    wire [10:0] v68; shift_adder #(10, 6, 1, 0, 11, -1, 1) op_68 (v67[9:0], v35[5:0], v68[10:0]); // 6.0
    wire [5:0] v69; assign v69[5:0] = model_inp[291:286]; // 5.0
    wire [5:0] v70; assign v70[5:0] = model_inp[297:292]; // 5.0
    wire [6:0] v71; shift_adder #(6, 6, 0, 0, 7, 0, 0) op_71 (v69[5:0], v70[5:0], v71[6:0]); // 6.0
    wire [12:0] v72; assign v72[12:0] = model_inp[310:298]; // 5.0
    wire [16:0] v73; assign v73[16:0] = model_inp[327:311]; // 5.0
    wire [16:0] v74; shift_adder #(13, 17, 1, 1, 17, -2, 0) op_74 (v72[12:0], v73[16:0], v74[16:0]); // 6.0
    wire [16:0] v75; shift_adder #(17, 7, 1, 0, 17, 0, 0) op_75 (v74[16:0], 7'b1100000, v75[16:0]); // 6.0
    wire [15:0] v76; assign v76[15:0] = v75[15:0] & {16{~v75[16]}}; // 6.0
    wire [15:0] v77; shift_adder #(16, 8, 0, 0, 16, 0, 0) op_77 (v76[15:0], 8'b10000000, v77[15:0]); // 6.0
    wire [3:0] v78; assign v78[3:0] = v77[11:8]; // 6.0
    wire [4:0] v79; assign v79[4:0] = model_inp[332:328]; // 5.0
    wire [5:0] v80; shift_adder #(5, 5, 0, 0, 6, 0, 1) op_80 (v15[4:0], v79[4:0], v80[5:0]); // 6.0
    wire [7:0] v81; assign v81[7:0] = model_inp[340:333]; // 5.0
    wire [10:0] v82; shift_adder #(8, 8, 0, 0, 11, -2, 1) op_82 (v81[7:0], v81[7:0], v82[10:0]); // 6.0
    wire [17:0] v83; assign v83[17:0] = model_inp[358:341]; // 5.0
    wire [7:0] v84; assign v84[7:0] = model_inp[366:359]; // 5.0
    wire [17:0] v85; shift_adder #(18, 8, 1, 1, 18, 2, 1) op_85 (v83[17:0], v84[7:0], v85[17:0]); // 6.0
    wire [17:0] v86; shift_adder #(18, 9, 1, 0, 18, 0, 1) op_86 (v85[17:0], 9'b111100000, v86[17:0]); // 6.0
    wire [16:0] v87; assign v87[16:0] = v86[16:0] & {17{~v86[17]}}; // 6.0
    wire [16:0] v88; shift_adder #(17, 8, 0, 0, 17, 0, 0) op_88 (v87[16:0], 8'b10000000, v88[16:0]); // 6.0
    wire [4:0] v89; assign v89[4:0] = v88[12:8]; // 6.0
    wire [17:0] v90; assign v90[17:0] = model_inp[384:367]; // 5.0
    wire [20:0] v91; shift_adder #(18, 17, 1, 1, 21, 3, 1) op_91 (v90[17:0], v57[16:0], v91[20:0]); // 6.0
    wire [20:0] v92; shift_adder #(21, 11, 1, 0, 21, 0, 0) op_92 (v91[20:0], 11'b11111100000, v92[20:0]); // 6.0
    wire [19:0] v93; assign v93[19:0] = v92[19:0] & {20{~v92[20]}}; // 6.0
    wire [19:0] v94; shift_adder #(20, 8, 0, 0, 20, 0, 0) op_94 (v93[19:0], 8'b10000000, v94[19:0]); // 6.0
    wire [8:0] v95; assign v95[8:0] = v94[16:8]; // 6.0
    wire [7:0] v96; shift_adder #(5, 6, 0, 0, 8, 1, 0) op_96 (v15[4:0], v63[5:0], v96[7:0]); // 6.0
    wire [7:0] v97; assign v97[7:0] = model_inp[392:385]; // 5.0
    wire [8:0] v98; assign v98[8:0] = model_inp[401:393]; // 5.0
    wire [12:0] v99; shift_adder #(8, 9, 1, 0, 13, 3, 1) op_99 (v97[7:0], v98[8:0], v99[12:0]); // 6.0
    wire [8:0] v100; assign v100[8:0] = model_inp[410:402]; // 5.0
    wire [10:0] v101; shift_adder #(9, 8, 0, 0, 11, 2, 0) op_101 (v100[8:0], v81[7:0], v101[10:0]); // 6.0
    wire [2:0] v102; assign v102[2:0] = model_inp[413:411]; // 5.0
    wire [5:0] v103; shift_adder #(3, 5, 0, 0, 6, 0, 1) op_103 (v102[2:0], v32[4:0], v103[5:0]); // 6.0
    wire [6:0] v104; shift_adder #(6, 6, 0, 0, 7, 0, 1) op_104 (v65[5:0], v63[5:0], v104[6:0]); // 6.0
    wire [6:0] v105; assign v105[6:0] = model_inp[420:414]; // 5.0
    wire [9:0] v106; shift_adder #(7, 8, 0, 0, 10, -2, 0) op_106 (v105[6:0], v53[7:0], v106[9:0]); // 6.0
    wire [5:0] v107; assign v107[5:0] = model_inp[426:421]; // 5.0
    wire [6:0] v108; assign v108[6:0] = model_inp[433:427]; // 5.0
    wire [8:0] v109; shift_adder #(6, 7, 0, 0, 9, -2, 1) op_109 (v107[5:0], v108[6:0], v109[8:0]); // 6.0
    wire [6:0] v110; shift_adder #(4, 6, 0, 0, 7, -2, 0) op_110 (v34[3:0], v65[5:0], v110[6:0]); // 6.0
    wire [6:0] v111; shift_adder #(6, 5, 0, 0, 7, 0, 1) op_111 (v35[5:0], v30[4:0], v111[6:0]); // 6.0
    wire [5:0] v112; assign v112[5:0] = model_inp[439:434]; // 5.0
    wire [9:0] v113; assign v113[9:0] = model_inp[449:440]; // 5.0
    wire [12:0] v114; shift_adder #(6, 10, 1, 0, 13, -6, 0) op_114 (v112[5:0], v113[9:0], v114[12:0]); // 6.0
    wire [7:0] v115; shift_adder #(5, 5, 0, 0, 8, -2, 1) op_115 (v15[4:0], v15[4:0], v115[7:0]); // 6.0
    wire [15:0] v116; assign v116[15:0] = model_inp[465:450]; // 5.0
    wire [17:0] v117; assign v117[17:0] = model_inp[483:466]; // 5.0
    wire [18:0] v118; shift_adder #(16, 18, 1, 1, 19, -2, 0) op_118 (v116[15:0], v117[17:0], v118[18:0]); // 6.0
    wire [18:0] v119; shift_adder #(19, 11, 1, 0, 19, 0, 1) op_119 (v118[18:0], 11'b11100000000, v119[18:0]); // 6.0
    wire [17:0] v120; assign v120[17:0] = v119[17:0] & {18{~v119[18]}}; // 6.0
    wire [17:0] v121; shift_adder #(18, 8, 0, 0, 18, 0, 0) op_121 (v120[17:0], 8'b10000000, v121[17:0]); // 6.0
    wire [4:0] v122; assign v122[4:0] = v121[12:8]; // 6.0
    wire [15:0] v123; assign v123[15:0] = model_inp[499:484]; // 5.0
    wire [16:0] v124; shift_adder #(16, 13, 1, 1, 17, 1, 1) op_124 (v123[15:0], v1[12:0], v124[16:0]); // 6.0
    wire [16:0] v125; shift_adder #(17, 8, 1, 0, 17, 0, 1) op_125 (v124[16:0], 8'b10100000, v125[16:0]); // 6.0
    wire [15:0] v126; assign v126[15:0] = v125[15:0] & {16{~v125[16]}}; // 6.0
    wire [15:0] v127; shift_adder #(16, 6, 0, 0, 16, 0, 0) op_127 (v126[15:0], 6'b100000, v127[15:0]); // 6.0
    wire [5:0] v128; assign v128[5:0] = v127[11:6]; // 6.0
    wire [5:0] v129; shift_adder #(5, 5, 0, 0, 6, 0, 1) op_129 (v32[4:0], v43[4:0], v129[5:0]); // 6.0
    wire [8:0] v130; assign v130[8:0] = model_inp[508:500]; // 5.0
    wire [9:0] v131; shift_adder #(9, 6, 1, 0, 10, 2, 1) op_131 (v130[8:0], v70[5:0], v131[9:0]); // 6.0
    wire [4:0] v132; assign v132[4:0] = model_inp[513:509]; // 5.0
    wire [7:0] v133; shift_adder #(5, 5, 0, 0, 8, 2, 1) op_133 (v15[4:0], v132[4:0], v133[7:0]); // 6.0
    wire [5:0] v134; shift_adder #(4, 5, 0, 0, 6, -1, 1) op_134 (v44[3:0], v30[4:0], v134[5:0]); // 6.0
    wire [7:0] v135; shift_adder #(6, 5, 0, 0, 8, -1, 0) op_135 (v17[5:0], v29[4:0], v135[7:0]); // 6.0
    wire [6:0] v136; assign v136[6:0] = model_inp[520:514]; // 5.0
    wire [9:0] v137; shift_adder #(6, 7, 0, 0, 10, 2, 1) op_137 (v69[5:0], v136[6:0], v137[9:0]); // 6.0
    wire [7:0] v138; assign v138[7:0] = model_inp[528:521]; // 5.0
    wire [7:0] v139; shift_adder #(8, 4, 0, 0, 8, 0, 0) op_139 (v138[7:0], v34[3:0], v139[7:0]); // 6.0
    wire [7:0] v140; shift_adder #(6, 6, 0, 0, 8, -1, 1) op_140 (v65[5:0], v35[5:0], v140[7:0]); // 6.0
    wire [6:0] v141; assign v141[6:0] = model_inp[535:529]; // 5.0
    wire [7:0] v142; shift_adder #(5, 7, 0, 0, 8, -1, 1) op_142 (v132[4:0], v141[6:0], v142[7:0]); // 6.0
    wire [5:0] v143; assign v143[5:0] = model_inp[541:536]; // 5.0
    wire [7:0] v144; assign v144[7:0] = model_inp[549:542]; // 5.0
    wire [9:0] v145; shift_adder #(6, 8, 0, 1, 10, -2, 0) op_145 (v143[5:0], v144[7:0], v145[9:0]); // 6.0
    wire [4:0] v146; assign v146[4:0] = model_inp[554:550]; // 5.0
    wire [7:0] v147; shift_adder #(6, 5, 0, 0, 8, 2, 1) op_147 (v69[5:0], v146[4:0], v147[7:0]); // 6.0
    wire [6:0] v148; shift_adder #(5, 5, 0, 0, 7, 1, 0) op_148 (v32[4:0], v29[4:0], v148[6:0]); // 6.0
    wire [8:0] v149; shift_adder #(6, 7, 0, 0, 9, -2, 0) op_149 (v107[5:0], v141[6:0], v149[8:0]); // 6.0
    wire [5:0] v150; assign v150[5:0] = model_inp[560:555]; // 5.0
    wire [4:0] v151; assign v151[4:0] = model_inp[565:561]; // 5.0
    wire [7:0] v152; shift_adder #(6, 5, 0, 0, 8, -1, 1) op_152 (v150[5:0], v151[4:0], v152[7:0]); // 6.0
    wire [9:0] v153; shift_adder #(7, 8, 0, 0, 10, -2, 0) op_153 (v105[6:0], v81[7:0], v153[9:0]); // 6.0
    wire [18:0] v154; assign v154[18:0] = model_inp[584:566]; // 5.0
    wire [14:0] v155; assign v155[14:0] = model_inp[599:585]; // 5.0
    wire [18:0] v156; shift_adder #(19, 15, 1, 1, 19, 2, 1) op_156 (v154[18:0], v155[14:0], v156[18:0]); // 6.0
    wire [18:0] v157; shift_adder #(19, 9, 1, 0, 19, 0, 1) op_157 (v156[18:0], 9'b111100000, v157[18:0]); // 6.0
    wire [17:0] v158; assign v158[17:0] = v157[17:0] & {18{~v157[18]}}; // 6.0
    wire [17:0] v159; shift_adder #(18, 8, 0, 0, 18, 0, 0) op_159 (v158[17:0], 8'b10000000, v159[17:0]); // 6.0
    wire [6:0] v160; assign v160[6:0] = v159[14:8]; // 6.0
    wire [3:0] v161; assign v161[3:0] = model_inp[603:600]; // 5.0
    wire [7:0] v162; shift_adder #(5, 4, 0, 0, 8, 3, 1) op_162 (v43[4:0], v161[3:0], v162[7:0]); // 6.0
    wire [3:0] v163; assign v163[3:0] = model_inp[607:604]; // 5.0
    wire [5:0] v164; shift_adder #(5, 4, 0, 0, 6, 0, 0) op_164 (v30[4:0], v163[3:0], v164[5:0]); // 6.0
    wire [4:0] v165; assign v165[4:0] = model_inp[612:608]; // 5.0
    wire [6:0] v166; shift_adder #(5, 5, 1, 0, 7, 0, 1) op_166 (v165[4:0], v32[4:0], v166[6:0]); // 6.0
    wire [4:0] v167; assign v167[4:0] = model_inp[617:613]; // 5.0
    wire [4:0] v168; assign v168[4:0] = model_inp[622:618]; // 5.0
    wire [6:0] v169; shift_adder #(5, 5, 0, 0, 7, -1, 1) op_169 (v167[4:0], v168[4:0], v169[6:0]); // 6.0
    wire [5:0] v170; assign v170[5:0] = model_inp[628:623]; // 5.0
    wire [9:0] v171; shift_adder #(6, 5, 0, 0, 10, 4, 1) op_171 (v170[5:0], v168[4:0], v171[9:0]); // 6.0
    wire [7:0] v172; assign v172[7:0] = model_inp[636:629]; // 5.0
    wire [7:0] v173; shift_adder #(4, 8, 0, 0, 8, -2, 0) op_173 (v44[3:0], v172[7:0], v173[7:0]); // 6.0
    wire [6:0] v174; shift_adder #(6, 6, 0, 0, 7, 0, 1) op_174 (v69[5:0], v70[5:0], v174[6:0]); // 6.0
    wire [4:0] v175; assign v175[4:0] = model_inp[641:637]; // 5.0
    wire [8:0] v176; shift_adder #(5, 7, 0, 0, 9, 1, 0) op_176 (v175[4:0], v141[6:0], v176[8:0]); // 6.0
    wire [5:0] v177; assign v177[5:0] = model_inp[647:642]; // 5.0
    wire [8:0] v178; shift_adder #(8, 6, 0, 0, 9, 0, 0) op_178 (v81[7:0], v177[5:0], v178[8:0]); // 6.0
    wire [5:0] v179; assign v179[5:0] = model_inp[653:648]; // 5.0
    wire [9:0] v180; shift_adder #(6, 5, 0, 0, 10, -3, 0) op_180 (v179[5:0], v30[4:0], v180[9:0]); // 6.0
    wire [8:0] v181; shift_adder #(6, 6, 0, 0, 9, -2, 1) op_181 (v70[5:0], v70[5:0], v181[8:0]); // 6.0
    wire [6:0] v182; assign v182[6:0] = model_inp[660:654]; // 5.0
    wire [7:0] v183; shift_adder #(7, 5, 1, 0, 8, 1, 1) op_183 (v182[6:0], v168[4:0], v183[7:0]); // 6.0
    wire [10:0] v184; shift_adder #(6, 10, 0, 0, 11, -1, 1) op_184 (v35[5:0], v113[9:0], v184[10:0]); // 6.0
    wire [7:0] v185; shift_adder #(7, 4, 0, 0, 8, 3, 0) op_185 (v141[6:0], v34[3:0], v185[7:0]); // 6.0
    wire [7:0] v186; shift_adder #(4, 6, 0, 0, 8, -3, 0) op_186 (v163[3:0], v69[5:0], v186[7:0]); // 6.0
    wire [6:0] v187; shift_adder #(5, 5, 0, 0, 7, -1, 0) op_187 (v30[4:0], v15[4:0], v187[6:0]); // 6.0
    wire [9:0] v188; shift_adder #(9, 6, 0, 0, 10, 2, 0) op_188 (v100[8:0], v65[5:0], v188[9:0]); // 6.0
    wire [7:0] v189; assign v189[7:0] = model_inp[668:661]; // 5.0
    wire [8:0] v190; shift_adder #(8, 6, 1, 1, 9, 1, 1) op_190 (v189[7:0], v112[5:0], v190[8:0]); // 6.0
    wire [7:0] v191; shift_adder #(6, 7, 0, 0, 8, -1, 1) op_191 (v69[5:0], v141[6:0], v191[7:0]); // 6.0
    wire [7:0] v192; shift_adder #(5, 5, 0, 0, 8, 2, 1) op_192 (v32[4:0], v175[4:0], v192[7:0]); // 6.0
    wire [9:0] v193; shift_adder #(5, 8, 0, 1, 10, 1, 0) op_193 (v15[4:0], v144[7:0], v193[9:0]); // 6.0
    wire [6:0] v194; shift_adder #(6, 6, 0, 0, 7, 0, 0) op_194 (v18[5:0], v177[5:0], v194[6:0]); // 6.0
    wire [7:0] v195; shift_adder #(5, 5, 0, 0, 8, -2, 1) op_195 (v29[4:0], v29[4:0], v195[7:0]); // 6.0
    wire [5:0] v196; assign v196[5:0] = model_inp[674:669]; // 5.0
    wire [7:0] v197; shift_adder #(6, 6, 1, 0, 8, -2, 0) op_197 (v196[5:0], v70[5:0], v197[7:0]); // 6.0
    wire [13:0] v198; shift_adder #(6, 9, 0, 0, 14, 4, 1) op_198 (v170[5:0], v100[8:0], v198[13:0]); // 6.0
    wire [9:0] v199; shift_adder #(6, 5, 0, 0, 10, -3, 0) op_199 (v63[5:0], v146[4:0], v199[9:0]); // 6.0
    wire [3:0] v200; assign v200[3:0] = model_inp[678:675]; // 5.0
    wire [7:0] v201; shift_adder #(4, 4, 0, 0, 8, -3, 1) op_201 (v200[3:0], v44[3:0], v201[7:0]); // 6.0
    wire [3:0] v202; assign v202[3:0] = model_inp[682:679]; // 5.0
    wire [7:0] v203; assign v203[7:0] = model_inp[690:683]; // 5.0
    wire [8:0] v204; shift_adder #(4, 8, 0, 1, 9, 1, 1) op_204 (v202[3:0], v203[7:0], v204[8:0]); // 6.0
    wire [6:0] v205; shift_adder #(5, 5, 0, 0, 7, -1, 1) op_205 (v167[4:0], v15[4:0], v205[6:0]); // 6.0
    wire [6:0] v206; shift_adder #(4, 4, 0, 0, 7, -2, 1) op_206 (v163[3:0], v44[3:0], v206[6:0]); // 6.0
    wire [6:0] v207; assign v207[6:0] = model_inp[697:691]; // 5.0
    wire [7:0] v208; shift_adder #(5, 7, 0, 0, 8, -1, 0) op_208 (v146[4:0], v207[6:0], v208[7:0]); // 6.0
    wire [6:0] v209; shift_adder #(6, 4, 0, 0, 7, 1, 0) op_209 (v69[5:0], v163[3:0], v209[6:0]); // 6.0
    wire [12:0] v210; shift_adder #(10, 8, 0, 0, 13, -2, 0) op_210 (v113[9:0], v27[7:0], v210[12:0]); // 6.0
    wire [5:0] v211; shift_adder #(5, 5, 0, 0, 6, 0, 0) op_211 (v29[4:0], v32[4:0], v211[5:0]); // 6.0
    wire [10:0] v212; assign v212[10:0] = model_inp[708:698]; // 5.0
    wire [10:0] v213; shift_adder #(6, 11, 0, 0, 11, -2, 0) op_213 (v65[5:0], v212[10:0], v213[10:0]); // 6.0
    wire [4:0] v214; assign v214[4:0] = model_inp[713:709]; // 5.0
    wire [6:0] v215; shift_adder #(5, 5, 0, 0, 7, -1, 1) op_215 (v43[4:0], v214[4:0], v215[6:0]); // 6.0
    wire [10:0] v216; shift_adder #(4, 10, 0, 0, 11, -3, 0) op_216 (v34[3:0], v113[9:0], v216[10:0]); // 6.0
    wire [5:0] v217; assign v217[5:0] = model_inp[719:714]; // 5.0
    wire [6:0] v218; shift_adder #(6, 6, 0, 0, 7, 0, 0) op_218 (v107[5:0], v217[5:0], v218[6:0]); // 6.0
    wire [5:0] v219; assign v219[5:0] = model_inp[725:720]; // 5.0
    wire [9:0] v220; shift_adder #(6, 9, 0, 0, 10, 0, 1) op_220 (v219[5:0], v100[8:0], v220[9:0]); // 6.0
    wire [6:0] v221; assign v221[6:0] = model_inp[732:726]; // 5.0
    wire [12:0] v222; shift_adder #(8, 7, 0, 0, 13, -4, 0) op_222 (v81[7:0], v221[6:0], v222[12:0]); // 6.0
    wire [10:0] v223; shift_adder #(10, 4, 0, 0, 11, 4, 1) op_223 (v113[9:0], v202[3:0], v223[10:0]); // 6.0
    wire [6:0] v224; assign v224[6:0] = model_inp[739:733]; // 5.0
    wire [7:0] v225; shift_adder #(7, 6, 1, 0, 8, -1, 0) op_225 (v224[6:0], v35[5:0], v225[7:0]); // 6.0
    wire [7:0] v226; shift_adder #(5, 5, 0, 0, 8, -2, 1) op_226 (v146[4:0], v32[4:0], v226[7:0]); // 6.0
    wire [6:0] v227; assign v227[6:0] = model_inp[746:740]; // 5.0
    wire [6:0] v228; shift_adder #(7, 4, 0, 0, 7, 0, 0) op_228 (v227[6:0], v44[3:0], v228[6:0]); // 6.0
    wire [6:0] v229; shift_adder #(6, 4, 0, 0, 7, 0, 1) op_229 (v69[5:0], v163[3:0], v229[6:0]); // 6.0
    wire [6:0] v230; shift_adder #(5, 6, 0, 0, 7, 0, 0) op_230 (v146[4:0], v177[5:0], v230[6:0]); // 6.0
    wire [6:0] v231; shift_adder #(6, 4, 0, 0, 7, 0, 0) op_231 (v69[5:0], v34[3:0], v231[6:0]); // 6.0
    wire [6:0] v232; assign v232[6:0] = model_inp[753:747]; // 5.0
    wire [7:0] v233; shift_adder #(7, 6, 1, 0, 8, 0, 1) op_233 (v232[6:0], v17[5:0], v233[7:0]); // 6.0
    wire [8:0] v234; assign v234[8:0] = model_inp[762:754]; // 5.0
    wire [9:0] v235; shift_adder #(6, 9, 0, 0, 10, -2, 0) op_235 (v177[5:0], v234[8:0], v235[9:0]); // 6.0
    wire [8:0] v236; assign v236[8:0] = model_inp[771:763]; // 5.0
    wire [9:0] v237; shift_adder #(4, 9, 0, 0, 10, 0, 1) op_237 (v163[3:0], v236[8:0], v237[9:0]); // 6.0
    wire [9:0] v238; shift_adder #(6, 7, 0, 0, 10, 2, 1) op_238 (v65[5:0], v141[6:0], v238[9:0]); // 6.0
    wire [5:0] v239; assign v239[5:0] = model_inp[777:772]; // 5.0
    wire [6:0] v240; shift_adder #(6, 5, 1, 0, 7, 0, 0) op_240 (v239[5:0], v146[4:0], v240[6:0]); // 6.0
    wire [5:0] v241; shift_adder #(5, 5, 0, 0, 6, 0, 0) op_241 (v43[4:0], v214[4:0], v241[5:0]); // 6.0
    wire [10:0] v242; shift_adder #(8, 7, 0, 0, 11, 3, 0) op_242 (v27[7:0], v141[6:0], v242[10:0]); // 6.0
    wire [8:0] v243; assign v243[8:0] = model_inp[786:778]; // 5.0
    wire [8:0] v244; shift_adder #(5, 9, 0, 1, 9, -1, 0) op_244 (v29[4:0], v243[8:0], v244[8:0]); // 6.0
    wire [7:0] v245; shift_adder #(5, 7, 0, 0, 8, 0, 1) op_245 (v15[4:0], v108[6:0], v245[7:0]); // 6.0
    wire [6:0] v246; assign v246[6:0] = model_inp[793:787]; // 5.0
    wire [9:0] v247; shift_adder #(7, 7, 0, 0, 10, 2, 1) op_247 (v246[6:0], v108[6:0], v247[9:0]); // 6.0
    wire [4:0] v248; assign v248[4:0] = model_inp[798:794]; // 5.0
    wire [5:0] v249; assign v249[5:0] = model_inp[804:799]; // 5.0
    wire [7:0] v250; shift_adder #(5, 6, 0, 0, 8, -2, 0) op_250 (v248[4:0], v249[5:0], v250[7:0]); // 6.0
    wire [6:0] v251; shift_adder #(6, 5, 0, 0, 7, 0, 0) op_251 (v65[5:0], v15[4:0], v251[6:0]); // 6.0
    wire [3:0] v252; assign v252[3:0] = model_inp[808:805]; // 5.0
    wire [6:0] v253; shift_adder #(5, 4, 0, 0, 7, -1, 0) op_253 (v214[4:0], v252[3:0], v253[6:0]); // 6.0
    wire [5:0] v254; assign v254[5:0] = model_inp[814:809]; // 5.0
    wire [9:0] v255; shift_adder #(5, 6, 0, 1, 10, 3, 0) op_255 (v32[4:0], v254[5:0], v255[9:0]); // 6.0
    wire [9:0] v256; assign v256[9:0] = model_inp[824:815]; // 5.0
    wire [9:0] v257; shift_adder #(5, 10, 0, 0, 10, -3, 0) op_257 (v43[4:0], v256[9:0], v257[9:0]); // 6.0
    wire [7:0] v258; shift_adder #(5, 6, 0, 0, 8, -2, 0) op_258 (v32[4:0], v107[5:0], v258[7:0]); // 6.0
    wire [7:0] v259; assign v259[7:0] = model_inp[832:825]; // 5.0
    wire [8:0] v260; shift_adder #(8, 6, 1, 1, 9, 0, 1) op_260 (v259[7:0], v254[5:0], v260[8:0]); // 6.0
    wire [10:0] v261; shift_adder #(5, 10, 0, 0, 11, 0, 0) op_261 (v146[4:0], v113[9:0], v261[10:0]); // 6.0
    wire [8:0] v262; assign v262[8:0] = model_inp[841:833]; // 5.0
    wire [8:0] v263; shift_adder #(5, 9, 0, 0, 9, -1, 0) op_263 (v167[4:0], v262[8:0], v263[8:0]); // 6.0
    wire [10:0] v264; shift_adder #(8, 6, 0, 0, 11, -2, 0) op_264 (v81[7:0], v107[5:0], v264[10:0]); // 6.0
    wire [7:0] v265; assign v265[7:0] = model_inp[849:842]; // 5.0
    wire [11:0] v266; shift_adder #(8, 9, 1, 0, 12, 1, 1) op_266 (v265[7:0], v100[8:0], v266[11:0]); // 6.0
    wire [8:0] v267; shift_adder #(8, 6, 0, 0, 9, 1, 0) op_267 (v53[7:0], v70[5:0], v267[8:0]); // 6.0
    wire [6:0] v268; shift_adder #(6, 5, 0, 0, 7, 0, 0) op_268 (v63[5:0], v214[4:0], v268[6:0]); // 6.0
    wire [5:0] v269; assign v269[5:0] = model_inp[855:850]; // 5.0
    wire [6:0] v270; shift_adder #(5, 6, 0, 0, 7, 0, 0) op_270 (v146[4:0], v269[5:0], v270[6:0]); // 6.0
    wire [9:0] v271; assign v271[9:0] = model_inp[865:856]; // 5.0
    wire [9:0] v272; shift_adder #(10, 5, 1, 0, 10, 2, 1) op_272 (v271[9:0], v214[4:0], v272[9:0]); // 6.0
    wire [4:0] v273; assign v273[4:0] = model_inp[870:866]; // 5.0
    wire [1:0] v274; assign v274[1:0] = model_inp[872:871]; // 5.0
    wire [9:0] v275; assign v275[9:0] = model_inp[882:873]; // 5.0
    wire [7:0] v276; assign v276[7:0] = model_inp[890:883]; // 5.0
    wire [10:0] v277; assign v277[10:0] = model_inp[901:891]; // 5.0
    wire [9:0] v278; assign v278[9:0] = model_inp[911:902]; // 5.0
    wire [2:0] v279; assign v279[2:0] = model_inp[914:912]; // 5.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[4:0] = v6[4:0];
    assign model_out[11:5] = v136[6:0];
    assign model_out[18:12] = v13[6:0];
    assign model_out[25:19] = v16[6:0];
    assign model_out[33:26] = v19[7:0];
    assign model_out[39:34] = v26[5:0];
    assign model_out[50:40] = v28[10:0];
    assign model_out[54:51] = v34[3:0];
    assign model_out[61:55] = v31[6:0];
    assign model_out[64:62] = v102[2:0];
    assign model_out[71:65] = v33[6:0];
    assign model_out[77:72] = v42[5:0];
    assign model_out[82:78] = v132[4:0];
    assign model_out[88:83] = v107[5:0];
    assign model_out[93:89] = v52[4:0];
    assign model_out[102:94] = v55[8:0];
    assign model_out[110:103] = v27[7:0];
    assign model_out[118:111] = v62[7:0];
    assign model_out[126:119] = v64[7:0];
    assign model_out[134:127] = v66[7:0];
    assign model_out[145:135] = v68[10:0];
    assign model_out[152:146] = v71[6:0];
    assign model_out[156:153] = v78[3:0];
    assign model_out[162:157] = v80[5:0];
    assign model_out[171:163] = v100[8:0];
    assign model_out[182:172] = v82[10:0];
    assign model_out[187:183] = v89[4:0];
    assign model_out[196:188] = v95[8:0];
    assign model_out[202:197] = v69[5:0];
    assign model_out[210:203] = v96[7:0];
    assign model_out[223:211] = v99[12:0];
    assign model_out[234:224] = v101[10:0];
    assign model_out[239:235] = v273[4:0];
    assign model_out[243:240] = v252[3:0];
    assign model_out[249:244] = v179[5:0];
    assign model_out[255:250] = v103[5:0];
    assign model_out[265:256] = v106[9:0];
    assign model_out[274:266] = v109[8:0];
    assign model_out[281:275] = v110[6:0];
    assign model_out[286:282] = v214[4:0];
    assign model_out[293:287] = v111[6:0];
    assign model_out[298:294] = v146[4:0];
    assign model_out[311:299] = v114[12:0];
    assign model_out[319:312] = v115[7:0];
    assign model_out[325:320] = v177[5:0];
    assign model_out[331:326] = v128[5:0];
    assign model_out[337:332] = v129[5:0];
    assign model_out[347:338] = v131[9:0];
    assign model_out[352:348] = v122[4:0];
    assign model_out[358:353] = v63[5:0];
    assign model_out[366:359] = v133[7:0];
    assign model_out[371:367] = v32[4:0];
    assign model_out[377:372] = v134[5:0];
    assign model_out[385:378] = v53[7:0];
    assign model_out[393:386] = v135[7:0];
    assign model_out[403:394] = v137[9:0];
    assign model_out[411:404] = v139[7:0];
    assign model_out[419:412] = v140[7:0];
    assign model_out[427:420] = v142[7:0];
    assign model_out[437:428] = v145[9:0];
    assign model_out[445:438] = v147[7:0];
    assign model_out[452:446] = v148[6:0];
    assign model_out[458:453] = v70[5:0];
    assign model_out[467:459] = v149[8:0];
    assign model_out[475:468] = v152[7:0];
    assign model_out[480:476] = v29[4:0];
    assign model_out[487:481] = v160[6:0];
    assign model_out[492:488] = v79[4:0];
    assign model_out[500:493] = v162[7:0];
    assign model_out[507:501] = v141[6:0];
    assign model_out[513:508] = v164[5:0];
    assign model_out[520:514] = v166[6:0];
    assign model_out[527:521] = v169[6:0];
    assign model_out[537:528] = v171[9:0];
    assign model_out[545:538] = v173[7:0];
    assign model_out[552:546] = v174[6:0];
    assign model_out[561:553] = v176[8:0];
    assign model_out[570:562] = v178[8:0];
    assign model_out[580:571] = v180[9:0];
    assign model_out[589:581] = v181[8:0];
    assign model_out[597:590] = v183[7:0];
    assign model_out[605:598] = v185[7:0];
    assign model_out[613:606] = v186[7:0];
    assign model_out[619:614] = v45[5:0];
    assign model_out[621:620] = v274[1:0];
    assign model_out[628:622] = v187[6:0];
    assign model_out[638:629] = v153[9:0];
    assign model_out[648:639] = v188[9:0];
    assign model_out[657:649] = v190[8:0];
    assign model_out[665:658] = v191[7:0];
    assign model_out[673:666] = v192[7:0];
    assign model_out[683:674] = v275[9:0];
    assign model_out[693:684] = v193[9:0];
    assign model_out[700:694] = v194[6:0];
    assign model_out[708:701] = v195[7:0];
    assign model_out[716:709] = v197[7:0];
    assign model_out[730:717] = v198[13:0];
    assign model_out[736:731] = v143[5:0];
    assign model_out[746:737] = v199[9:0];
    assign model_out[754:747] = v201[7:0];
    assign model_out[763:755] = v204[8:0];
    assign model_out[770:764] = v205[6:0];
    assign model_out[777:771] = v206[6:0];
    assign model_out[785:778] = v208[7:0];
    assign model_out[792:786] = v209[6:0];
    assign model_out[805:793] = v210[12:0];
    assign model_out[811:806] = v211[5:0];
    assign model_out[822:812] = v213[10:0];
    assign model_out[833:823] = v184[10:0];
    assign model_out[837:834] = v202[3:0];
    assign model_out[844:838] = v215[6:0];
    assign model_out[855:845] = v216[10:0];
    assign model_out[860:856] = v167[4:0];
    assign model_out[867:861] = v218[6:0];
    assign model_out[874:868] = v36[6:0];
    assign model_out[882:875] = v276[7:0];
    assign model_out[892:883] = v220[9:0];
    assign model_out[905:893] = v222[12:0];
    assign model_out[916:906] = v223[10:0];
    assign model_out[922:917] = v17[5:0];
    assign model_out[930:923] = v225[7:0];
    assign model_out[938:931] = v226[7:0];
    assign model_out[945:939] = v228[6:0];
    assign model_out[952:946] = v229[6:0];
    assign model_out[959:953] = v231[6:0];
    assign model_out[967:960] = v233[7:0];
    assign model_out[977:968] = v113[9:0];
    assign model_out[984:978] = v230[6:0];
    assign model_out[994:985] = v235[9:0];
    assign model_out[1004:995] = v237[9:0];
    assign model_out[1014:1005] = v238[9:0];
    assign model_out[1025:1015] = v277[10:0];
    assign model_out[1032:1026] = v240[6:0];
    assign model_out[1038:1033] = v241[5:0];
    assign model_out[1046:1039] = v81[7:0];
    assign model_out[1057:1047] = v242[10:0];
    assign model_out[1066:1058] = v244[8:0];
    assign model_out[1074:1067] = v245[7:0];
    assign model_out[1084:1075] = v247[9:0];
    assign model_out[1090:1085] = v65[5:0];
    assign model_out[1098:1091] = v250[7:0];
    assign model_out[1105:1099] = v251[6:0];
    assign model_out[1115:1106] = v255[9:0];
    assign model_out[1120:1116] = v30[4:0];
    assign model_out[1130:1121] = v257[9:0];
    assign model_out[1138:1131] = v258[7:0];
    assign model_out[1147:1139] = v260[8:0];
    assign model_out[1157:1148] = v278[9:0];
    assign model_out[1164:1158] = v253[6:0];
    assign model_out[1175:1165] = v261[10:0];
    assign model_out[1184:1176] = v263[8:0];
    assign model_out[1196:1185] = v266[11:0];
    assign model_out[1205:1197] = v267[8:0];
    assign model_out[1212:1206] = v268[6:0];
    assign model_out[1219:1213] = v270[6:0];
    assign model_out[1229:1220] = v272[9:0];
    assign model_out[1236:1230] = v104[6:0];
    assign model_out[1242:1237] = v35[5:0];
    assign model_out[1246:1243] = v200[3:0];
    assign model_out[1253:1247] = v108[6:0];
    assign model_out[1257:1254] = v44[3:0];
    assign model_out[1262:1258] = v15[4:0];
    assign model_out[1267:1263] = v151[4:0];
    assign model_out[1278:1268] = v264[10:0];
    assign model_out[1283:1279] = v248[4:0];
    assign model_out[1287:1284] = v163[3:0];
    assign model_out[1291:1288] = v161[3:0];
    assign model_out[1294:1292] = v279[2:0];
    assign model_out[1300:1295] = v18[5:0];

endmodule
