`timescale 1 ns / 1 ps

module jsc_stage4 (
    input [1231:0] model_inp,
    output [914:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [18:0] v0; assign v0[18:0] = model_inp[18:0]; // 4.0
    wire [7:0] v1; assign v1[7:0] = model_inp[26:19]; // 4.0
    wire [18:0] v2; shift_adder #(19, 8, 1, 1, 19, 2, 1) op_2 (v0[18:0], v1[7:0], v2[18:0]); // 5.0
    wire [18:0] v3; shift_adder #(19, 9, 1, 0, 19, 0, 1) op_3 (v2[18:0], 9'b111000000, v3[18:0]); // 5.0
    wire [17:0] v4; assign v4[17:0] = v3[17:0] & {18{~v3[18]}}; // 5.0
    wire [17:0] v5; shift_adder #(18, 9, 0, 0, 18, 0, 0) op_5 (v4[17:0], 9'b100000000, v5[17:0]); // 5.0
    wire [3:0] v6; assign v6[3:0] = v5[12:9]; // 5.0
    wire [16:0] v7; assign v7[16:0] = model_inp[43:27]; // 4.0
    wire [13:0] v8; assign v8[13:0] = model_inp[57:44]; // 4.0
    wire [16:0] v9; shift_adder #(17, 14, 1, 1, 17, 1, 1) op_9 (v7[16:0], v8[13:0], v9[16:0]); // 5.0
    wire [16:0] v10; shift_adder #(17, 8, 1, 0, 17, 0, 0) op_10 (v9[16:0], 8'b10100000, v10[16:0]); // 5.0
    wire [15:0] v11; assign v11[15:0] = v10[15:0] & {16{~v10[16]}}; // 5.0
    wire [15:0] v12; shift_adder #(16, 7, 0, 0, 16, 0, 0) op_12 (v11[15:0], 7'b1000000, v12[15:0]); // 5.0
    wire [5:0] v13; assign v13[5:0] = v12[12:7]; // 5.0
    wire [17:0] v14; assign v14[17:0] = model_inp[75:58]; // 4.0
    wire [12:0] v15; assign v15[12:0] = model_inp[88:76]; // 4.0
    wire [17:0] v16; shift_adder #(18, 13, 1, 1, 18, 1, 1) op_16 (v14[17:0], v15[12:0], v16[17:0]); // 5.0
    wire [15:0] v17; assign v17[15:0] = model_inp[104:89]; // 4.0
    wire [16:0] v18; assign v18[16:0] = model_inp[121:105]; // 4.0
    wire [17:0] v19; shift_adder #(16, 17, 1, 1, 18, -2, 0) op_19 (v17[15:0], v18[16:0], v19[17:0]); // 5.0
    wire [16:0] v20; assign v20[16:0] = model_inp[138:122]; // 4.0
    wire [13:0] v21; assign v21[13:0] = model_inp[152:139]; // 4.0
    wire [16:0] v22; shift_adder #(17, 14, 1, 1, 17, 2, 1) op_22 (v20[16:0], v21[13:0], v22[16:0]); // 5.0
    wire [16:0] v23; shift_adder #(17, 9, 1, 0, 17, 0, 0) op_23 (v22[16:0], 9'b111100000, v23[16:0]); // 5.0
    wire [15:0] v24; assign v24[15:0] = v23[15:0] & {16{~v23[16]}}; // 5.0
    wire [15:0] v25; shift_adder #(16, 7, 0, 0, 16, 0, 0) op_25 (v24[15:0], 7'b1000000, v25[15:0]); // 5.0
    wire [4:0] v26; assign v26[4:0] = v25[11:7]; // 5.0
    wire [4:0] v27; assign v27[4:0] = model_inp[157:153]; // 4.0
    wire [3:0] v28; assign v28[3:0] = model_inp[161:158]; // 4.0
    wire [5:0] v29; shift_adder #(5, 4, 0, 0, 6, 1, 0) op_29 (v27[4:0], v28[3:0], v29[5:0]); // 5.0
    wire [15:0] v30; assign v30[15:0] = model_inp[177:162]; // 4.0
    wire [15:0] v31; shift_adder #(16, 8, 1, 1, 16, 2, 1) op_31 (v30[15:0], v1[7:0], v31[15:0]); // 5.0
    wire [19:0] v32; assign v32[19:0] = model_inp[197:178]; // 4.0
    wire [14:0] v33; assign v33[14:0] = model_inp[212:198]; // 4.0
    wire [19:0] v34; shift_adder #(20, 15, 1, 1, 20, 1, 0) op_34 (v32[19:0], v33[14:0], v34[19:0]); // 5.0
    wire [19:0] v35; shift_adder #(20, 12, 1, 0, 20, 0, 0) op_35 (v34[19:0], 12'b111100010000, v35[19:0]); // 5.0
    wire [18:0] v36; assign v36[18:0] = v35[18:0] & {19{~v35[19]}}; // 5.0
    wire [18:0] v37; shift_adder #(19, 7, 0, 0, 19, 0, 0) op_37 (v36[18:0], 7'b1000000, v37[18:0]); // 5.0
    wire [7:0] v38; assign v38[7:0] = v37[14:7]; // 5.0
    wire [15:0] v39; shift_adder #(16, 9, 1, 0, 16, 0, 1) op_39 (v31[15:0], 9'b110000000, v39[15:0]); // 5.0
    wire [14:0] v40; assign v40[14:0] = v39[14:0] & {15{~v39[15]}}; // 5.0
    wire [14:0] v41; shift_adder #(15, 8, 0, 0, 15, 0, 0) op_41 (v40[14:0], 8'b10000000, v41[14:0]); // 5.0
    wire [3:0] v42; assign v42[3:0] = v41[11:8]; // 5.0
    wire [17:0] v43; assign v43[17:0] = model_inp[230:213]; // 4.0
    wire [16:0] v44; assign v44[16:0] = model_inp[247:231]; // 4.0
    wire [19:0] v45; shift_adder #(18, 17, 1, 1, 20, 3, 0) op_45 (v43[17:0], v44[16:0], v45[19:0]); // 5.0
    wire [19:0] v46; shift_adder #(20, 12, 1, 0, 20, 0, 0) op_46 (v45[19:0], 12'b100010000000, v46[19:0]); // 5.0
    wire [18:0] v47; assign v47[18:0] = v46[18:0] & {19{~v46[19]}}; // 5.0
    wire [18:0] v48; shift_adder #(19, 9, 0, 0, 19, 0, 0) op_48 (v47[18:0], 9'b100000000, v48[18:0]); // 5.0
    wire [4:0] v49; assign v49[4:0] = v48[13:9]; // 5.0
    wire [14:0] v50; assign v50[14:0] = model_inp[262:248]; // 4.0
    wire [15:0] v51; assign v51[15:0] = model_inp[278:263]; // 4.0
    wire [16:0] v52; shift_adder #(15, 16, 1, 1, 17, -2, 0) op_52 (v50[14:0], v51[15:0], v52[16:0]); // 5.0
    wire [16:0] v53; shift_adder #(17, 7, 1, 0, 17, 0, 0) op_53 (v52[16:0], 7'b1110000, v53[16:0]); // 5.0
    wire [15:0] v54; assign v54[15:0] = v53[15:0] & {16{~v53[16]}}; // 5.0
    wire [15:0] v55; shift_adder #(16, 7, 0, 0, 16, 0, 0) op_55 (v54[15:0], 7'b1000000, v55[15:0]); // 5.0
    wire [4:0] v56; assign v56[4:0] = v55[11:7]; // 5.0
    wire [12:0] v57; assign v57[12:0] = model_inp[291:279]; // 4.0
    wire [15:0] v58; assign v58[15:0] = model_inp[307:292]; // 4.0
    wire [16:0] v59; shift_adder #(13, 16, 1, 1, 17, -3, 1) op_59 (v57[12:0], v58[15:0], v59[16:0]); // 5.0
    wire [16:0] v60; shift_adder #(17, 10, 1, 0, 17, 0, 0) op_60 (v59[16:0], 10'b1101000000, v60[16:0]); // 5.0
    wire [15:0] v61; assign v61[15:0] = v60[15:0] & {16{~v60[16]}}; // 5.0
    wire [15:0] v62; shift_adder #(16, 8, 0, 0, 16, 0, 0) op_62 (v61[15:0], 8'b10000000, v62[15:0]); // 5.0
    wire [4:0] v63; assign v63[4:0] = v62[12:8]; // 5.0
    wire [16:0] v64; assign v64[16:0] = model_inp[324:308]; // 4.0
    wire [17:0] v65; assign v65[17:0] = model_inp[342:325]; // 4.0
    wire [18:0] v66; shift_adder #(17, 18, 1, 1, 19, -1, 1) op_66 (v64[16:0], v65[17:0], v66[18:0]); // 5.0
    wire [18:0] v67; shift_adder #(19, 10, 1, 0, 19, 0, 0) op_67 (v66[18:0], 10'b1111110000, v67[18:0]); // 5.0
    wire [17:0] v68; assign v68[17:0] = v67[17:0] & {18{~v67[18]}}; // 5.0
    wire [17:0] v69; shift_adder #(18, 8, 0, 0, 18, 0, 0) op_69 (v68[17:0], 8'b10000000, v69[17:0]); // 5.0
    wire [5:0] v70; assign v70[5:0] = v69[13:8]; // 5.0
    wire [16:0] v71; assign v71[16:0] = model_inp[359:343]; // 4.0
    wire [11:0] v72; assign v72[11:0] = model_inp[371:360]; // 4.0
    wire [17:0] v73; shift_adder #(17, 12, 1, 1, 18, 3, 1) op_73 (v71[16:0], v72[11:0], v73[17:0]); // 5.0
    wire [16:0] v74; assign v74[16:0] = model_inp[388:372]; // 4.0
    wire [16:0] v75; shift_adder #(17, 14, 1, 1, 17, 2, 1) op_75 (v74[16:0], v8[13:0], v75[16:0]); // 5.0
    wire [15:0] v76; assign v76[15:0] = v75[15:0] & {16{~v75[16]}}; // 5.0
    wire [15:0] v77; shift_adder #(16, 7, 0, 0, 16, 0, 0) op_77 (v76[15:0], 7'b1000000, v77[15:0]); // 5.0
    wire [4:0] v78; assign v78[4:0] = v77[11:7]; // 5.0
    wire [12:0] v79; assign v79[12:0] = model_inp[401:389]; // 4.0
    wire [16:0] v80; assign v80[16:0] = model_inp[418:402]; // 4.0
    wire [16:0] v81; shift_adder #(13, 17, 1, 1, 17, -2, 0) op_81 (v79[12:0], v80[16:0], v81[16:0]); // 5.0
    wire [16:0] v82; shift_adder #(17, 8, 1, 0, 17, 0, 1) op_82 (v81[16:0], 8'b10000000, v82[16:0]); // 5.0
    wire [15:0] v83; assign v83[15:0] = v82[15:0] & {16{~v82[16]}}; // 5.0
    wire [15:0] v84; shift_adder #(16, 7, 0, 0, 16, 0, 0) op_84 (v83[15:0], 7'b1000000, v84[15:0]); // 5.0
    wire [3:0] v85; assign v85[3:0] = v84[10:7]; // 5.0
    wire [13:0] v86; assign v86[13:0] = model_inp[432:419]; // 4.0
    wire [14:0] v87; assign v87[14:0] = model_inp[447:433]; // 4.0
    wire [16:0] v88; shift_adder #(14, 15, 1, 1, 17, -2, 0) op_88 (v86[13:0], v87[14:0], v88[16:0]); // 5.0
    wire [16:0] v89; shift_adder #(17, 9, 1, 0, 17, 0, 1) op_89 (v88[16:0], 9'b110000000, v89[16:0]); // 5.0
    wire [15:0] v90; assign v90[15:0] = v89[15:0] & {16{~v89[16]}}; // 5.0
    wire [15:0] v91; shift_adder #(16, 7, 0, 0, 16, 0, 0) op_91 (v90[15:0], 7'b1000000, v91[15:0]); // 5.0
    wire [5:0] v92; assign v92[5:0] = v91[12:7]; // 5.0
    wire [12:0] v93; assign v93[12:0] = model_inp[460:448]; // 4.0
    wire [15:0] v94; assign v94[15:0] = model_inp[476:461]; // 4.0
    wire [15:0] v95; shift_adder #(13, 16, 1, 1, 16, 0, 0) op_95 (v93[12:0], v94[15:0], v95[15:0]); // 5.0
    wire [16:0] v96; assign v96[16:0] = model_inp[493:477]; // 4.0
    wire [16:0] v97; shift_adder #(17, 8, 1, 1, 17, 1, 1) op_97 (v96[16:0], v1[7:0], v97[16:0]); // 5.0
    wire [16:0] v98; shift_adder #(17, 7, 1, 0, 17, 0, 0) op_98 (v97[16:0], 7'b1110000, v98[16:0]); // 5.0
    wire [15:0] v99; assign v99[15:0] = v98[15:0] & {16{~v98[16]}}; // 5.0
    wire [15:0] v100; shift_adder #(16, 6, 0, 0, 16, 0, 0) op_100 (v99[15:0], 6'b100000, v100[15:0]); // 5.0
    wire [7:0] v101; assign v101[7:0] = v100[13:6]; // 5.0
    wire [6:0] v102; assign v102[6:0] = model_inp[500:494]; // 4.0
    wire [7:0] v103; shift_adder #(7, 4, 0, 0, 8, 2, 0) op_103 (v102[6:0], v28[3:0], v103[7:0]); // 5.0
    wire [15:0] v104; assign v104[15:0] = model_inp[516:501]; // 4.0
    wire [16:0] v105; assign v105[16:0] = model_inp[533:517]; // 4.0
    wire [17:0] v106; shift_adder #(16, 17, 1, 1, 18, 1, 0) op_106 (v104[15:0], v105[16:0], v106[17:0]); // 5.0
    wire [14:0] v107; assign v107[14:0] = model_inp[548:534]; // 4.0
    wire [14:0] v108; assign v108[14:0] = model_inp[563:549]; // 4.0
    wire [16:0] v109; shift_adder #(15, 15, 1, 1, 17, -1, 0) op_109 (v107[14:0], v108[14:0], v109[16:0]); // 5.0
    wire [16:0] v110; shift_adder #(17, 9, 1, 0, 17, 0, 1) op_110 (v109[16:0], 9'b101000000, v110[16:0]); // 5.0
    wire [15:0] v111; assign v111[15:0] = v110[15:0] & {16{~v110[16]}}; // 5.0
    wire [15:0] v112; shift_adder #(16, 6, 0, 0, 16, 0, 0) op_112 (v111[15:0], 6'b100000, v112[15:0]); // 5.0
    wire [5:0] v113; assign v113[5:0] = v112[11:6]; // 5.0
    wire [8:0] v114; assign v114[8:0] = model_inp[572:564]; // 4.0
    wire [4:0] v115; assign v115[4:0] = model_inp[577:573]; // 4.0
    wire [9:0] v116; shift_adder #(9, 5, 0, 0, 10, 0, 1) op_116 (v114[8:0], v115[4:0], v116[9:0]); // 5.0
    wire [15:0] v117; assign v117[15:0] = model_inp[593:578]; // 4.0
    wire [17:0] v118; assign v118[17:0] = model_inp[611:594]; // 4.0
    wire [18:0] v119; shift_adder #(16, 18, 1, 1, 19, -2, 0) op_119 (v117[15:0], v118[17:0], v119[18:0]); // 5.0
    wire [18:0] v120; shift_adder #(19, 13, 1, 0, 19, 0, 0) op_120 (v119[18:0], 13'b1100101000000, v120[18:0]); // 5.0
    wire [17:0] v121; assign v121[17:0] = v120[17:0] & {18{~v120[18]}}; // 5.0
    wire [17:0] v122; shift_adder #(18, 9, 0, 0, 18, 0, 0) op_122 (v121[17:0], 9'b100000000, v122[17:0]); // 5.0
    wire [5:0] v123; assign v123[5:0] = v122[14:9]; // 5.0
    wire [14:0] v124; assign v124[14:0] = model_inp[626:612]; // 4.0
    wire [17:0] v125; shift_adder #(15, 16, 1, 1, 18, 2, 1) op_125 (v124[14:0], v58[15:0], v125[17:0]); // 5.0
    wire [17:0] v126; shift_adder #(18, 6, 1, 0, 18, 0, 0) op_126 (v125[17:0], 6'b100000, v126[17:0]); // 5.0
    wire [16:0] v127; assign v127[16:0] = v126[16:0] & {17{~v126[17]}}; // 5.0
    wire [16:0] v128; shift_adder #(17, 7, 0, 0, 17, 0, 0) op_128 (v127[16:0], 7'b1000000, v128[16:0]); // 5.0
    wire [5:0] v129; assign v129[5:0] = v128[12:7]; // 5.0
    wire [14:0] v130; assign v130[14:0] = model_inp[641:627]; // 4.0
    wire [14:0] v131; assign v131[14:0] = model_inp[656:642]; // 4.0
    wire [16:0] v132; shift_adder #(15, 15, 1, 1, 17, -1, 1) op_132 (v130[14:0], v131[14:0], v132[16:0]); // 5.0
    wire [12:0] v133; assign v133[12:0] = model_inp[669:657]; // 4.0
    wire [16:0] v134; assign v134[16:0] = model_inp[686:670]; // 4.0
    wire [16:0] v135; shift_adder #(13, 17, 1, 1, 17, 0, 0) op_135 (v133[12:0], v134[16:0], v135[16:0]); // 5.0
    wire [16:0] v136; shift_adder #(17, 8, 1, 0, 17, 0, 1) op_136 (v135[16:0], 8'b11000000, v136[16:0]); // 5.0
    wire [15:0] v137; assign v137[15:0] = v136[15:0] & {16{~v136[16]}}; // 5.0
    wire [15:0] v138; shift_adder #(16, 6, 0, 0, 16, 0, 0) op_138 (v137[15:0], 6'b100000, v138[15:0]); // 5.0
    wire [7:0] v139; assign v139[7:0] = v138[13:6]; // 5.0
    wire [15:0] v140; assign v140[15:0] = model_inp[702:687]; // 4.0
    wire [11:0] v141; assign v141[11:0] = model_inp[714:703]; // 4.0
    wire [17:0] v142; shift_adder #(16, 12, 1, 1, 18, 5, 0) op_142 (v140[15:0], v141[11:0], v142[17:0]); // 5.0
    wire [15:0] v143; assign v143[15:0] = model_inp[730:715]; // 4.0
    wire [16:0] v144; assign v144[16:0] = model_inp[747:731]; // 4.0
    wire [17:0] v145; shift_adder #(16, 17, 1, 1, 18, 1, 0) op_145 (v143[15:0], v144[16:0], v145[17:0]); // 5.0
    wire [4:0] v146; assign v146[4:0] = model_inp[752:748]; // 4.0
    wire [1:0] v147; assign v147[1:0] = model_inp[754:753]; // 4.0
    wire [7:0] v148; shift_adder #(5, 2, 0, 0, 8, 5, 1) op_148 (v146[4:0], v147[1:0], v148[7:0]); // 5.0
    wire [8:0] v149; shift_adder #(7, 5, 0, 0, 9, 3, 0) op_149 (v102[6:0], v27[4:0], v149[8:0]); // 5.0
    wire [17:0] v150; assign v150[17:0] = model_inp[772:755]; // 4.0
    wire [17:0] v151; shift_adder #(18, 8, 1, 1, 18, 1, 0) op_151 (v150[17:0], v1[7:0], v151[17:0]); // 5.0
    wire [17:0] v152; shift_adder #(18, 9, 1, 0, 18, 0, 1) op_152 (v151[17:0], 9'b101110000, v152[17:0]); // 5.0
    wire [16:0] v153; assign v153[16:0] = v152[16:0] & {17{~v152[17]}}; // 5.0
    wire [16:0] v154; shift_adder #(17, 6, 0, 0, 17, 0, 0) op_154 (v153[16:0], 6'b100000, v154[16:0]); // 5.0
    wire [5:0] v155; assign v155[5:0] = v154[11:6]; // 5.0
    wire [13:0] v156; assign v156[13:0] = model_inp[786:773]; // 4.0
    wire [16:0] v157; assign v157[16:0] = model_inp[803:787]; // 4.0
    wire [17:0] v158; shift_adder #(14, 17, 1, 1, 18, -2, 0) op_158 (v156[13:0], v157[16:0], v158[17:0]); // 5.0
    wire [17:0] v159; shift_adder #(18, 9, 1, 0, 18, 0, 1) op_159 (v158[17:0], 9'b110100000, v159[17:0]); // 5.0
    wire [16:0] v160; assign v160[16:0] = v159[16:0] & {17{~v159[17]}}; // 5.0
    wire [16:0] v161; shift_adder #(17, 8, 0, 0, 17, 0, 0) op_161 (v160[16:0], 8'b10000000, v161[16:0]); // 5.0
    wire [4:0] v162; assign v162[4:0] = v161[12:8]; // 5.0
    wire [14:0] v163; assign v163[14:0] = model_inp[818:804]; // 4.0
    wire [16:0] v164; assign v164[16:0] = model_inp[835:819]; // 4.0
    wire [17:0] v165; shift_adder #(15, 17, 1, 1, 18, 1, 0) op_165 (v163[14:0], v164[16:0], v165[17:0]); // 5.0
    wire [17:0] v166; shift_adder #(18, 11, 1, 0, 18, 0, 1) op_166 (v165[17:0], 11'b11110100000, v166[17:0]); // 5.0
    wire [16:0] v167; assign v167[16:0] = v166[16:0] & {17{~v166[17]}}; // 5.0
    wire [16:0] v168; shift_adder #(17, 8, 0, 0, 17, 0, 0) op_168 (v167[16:0], 8'b10000000, v168[16:0]); // 5.0
    wire [4:0] v169; assign v169[4:0] = v168[12:8]; // 5.0
    wire [3:0] v170; assign v170[3:0] = model_inp[839:836]; // 4.0
    wire [5:0] v171; shift_adder #(5, 4, 0, 0, 6, 0, 1) op_171 (v115[4:0], v170[3:0], v171[5:0]); // 5.0
    wire [14:0] v172; assign v172[14:0] = model_inp[854:840]; // 4.0
    wire [19:0] v173; assign v173[19:0] = model_inp[874:855]; // 4.0
    wire [19:0] v174; shift_adder #(15, 20, 1, 1, 20, -1, 0) op_174 (v172[14:0], v173[19:0], v174[19:0]); // 5.0
    wire [19:0] v175; shift_adder #(20, 11, 1, 0, 20, 0, 0) op_175 (v174[19:0], 11'b10011100000, v175[19:0]); // 5.0
    wire [18:0] v176; assign v176[18:0] = v175[18:0] & {19{~v175[19]}}; // 5.0
    wire [18:0] v177; shift_adder #(19, 6, 0, 0, 19, 0, 0) op_177 (v176[18:0], 6'b100000, v177[18:0]); // 5.0
    wire [9:0] v178; assign v178[9:0] = v177[15:6]; // 5.0
    wire [13:0] v179; assign v179[13:0] = model_inp[888:875]; // 4.0
    wire [17:0] v180; assign v180[17:0] = model_inp[906:889]; // 4.0
    wire [17:0] v181; shift_adder #(14, 18, 1, 1, 18, -3, 0) op_181 (v179[13:0], v180[17:0], v181[17:0]); // 5.0
    wire [14:0] v182; assign v182[14:0] = model_inp[921:907]; // 4.0
    wire [16:0] v183; shift_adder #(15, 15, 1, 1, 17, -1, 1) op_183 (v182[14:0], v107[14:0], v183[16:0]); // 5.0
    wire [16:0] v184; shift_adder #(17, 8, 1, 0, 17, 0, 1) op_184 (v183[16:0], 8'b11110000, v184[16:0]); // 5.0
    wire [15:0] v185; assign v185[15:0] = v184[15:0] & {16{~v184[16]}}; // 5.0
    wire [15:0] v186; shift_adder #(16, 7, 0, 0, 16, 0, 0) op_186 (v185[15:0], 7'b1000000, v186[15:0]); // 5.0
    wire [5:0] v187; assign v187[5:0] = v186[12:7]; // 5.0
    wire [13:0] v188; assign v188[13:0] = model_inp[935:922]; // 4.0
    wire [15:0] v189; assign v189[15:0] = model_inp[951:936]; // 4.0
    wire [15:0] v190; shift_adder #(14, 16, 1, 1, 16, -1, 0) op_190 (v188[13:0], v189[15:0], v190[15:0]); // 5.0
    wire [4:0] v191; assign v191[4:0] = model_inp[956:952]; // 4.0
    wire [6:0] v192; assign v192[6:0] = model_inp[963:957]; // 4.0
    wire [8:0] v193; shift_adder #(5, 7, 0, 0, 9, -3, 1) op_193 (v191[4:0], v192[6:0], v193[8:0]); // 5.0
    wire [2:0] v194; assign v194[2:0] = model_inp[966:964]; // 4.0
    wire [7:0] v195; shift_adder #(7, 3, 0, 0, 8, 0, 0) op_195 (v192[6:0], v194[2:0], v195[7:0]); // 5.0
    wire [16:0] v196; assign v196[16:0] = model_inp[983:967]; // 4.0
    wire [14:0] v197; assign v197[14:0] = model_inp[998:984]; // 4.0
    wire [16:0] v198; shift_adder #(17, 15, 1, 1, 17, 1, 1) op_198 (v196[16:0], v197[14:0], v198[16:0]); // 5.0
    wire [16:0] v199; shift_adder #(17, 9, 1, 0, 17, 0, 1) op_199 (v198[16:0], 9'b110000000, v199[16:0]); // 5.0
    wire [15:0] v200; assign v200[15:0] = v199[15:0] & {16{~v199[16]}}; // 5.0
    wire [15:0] v201; shift_adder #(16, 6, 0, 0, 16, 0, 0) op_201 (v200[15:0], 6'b100000, v201[15:0]); // 5.0
    wire [6:0] v202; assign v202[6:0] = v201[12:6]; // 5.0
    wire [6:0] v203; assign v203[6:0] = model_inp[1005:999]; // 4.0
    wire [4:0] v204; assign v204[4:0] = model_inp[1010:1006]; // 4.0
    wire [7:0] v205; shift_adder #(7, 5, 0, 0, 8, 1, 1) op_205 (v203[6:0], v204[4:0], v205[7:0]); // 5.0
    wire [3:0] v206; assign v206[3:0] = model_inp[1014:1011]; // 4.0
    wire [5:0] v207; shift_adder #(4, 4, 0, 0, 6, 1, 0) op_207 (v206[3:0], v28[3:0], v207[5:0]); // 5.0
    wire [16:0] v208; assign v208[16:0] = model_inp[1031:1015]; // 4.0
    wire [17:0] v209; assign v209[17:0] = model_inp[1049:1032]; // 4.0
    wire [18:0] v210; shift_adder #(17, 18, 1, 1, 19, 1, 0) op_210 (v208[16:0], v209[17:0], v210[18:0]); // 5.0
    wire [2:0] v211; assign v211[2:0] = model_inp[1052:1050]; // 4.0
    wire [3:0] v212; assign v212[3:0] = model_inp[1056:1053]; // 4.0
    wire [4:0] v213; shift_adder #(3, 4, 0, 0, 5, 0, 1) op_213 (v211[2:0], v212[3:0], v213[4:0]); // 5.0
    wire [15:0] v214; assign v214[15:0] = model_inp[1072:1057]; // 4.0
    wire [12:0] v215; assign v215[12:0] = model_inp[1085:1073]; // 4.0
    wire [16:0] v216; shift_adder #(16, 13, 1, 1, 17, 1, 1) op_216 (v214[15:0], v215[12:0], v216[16:0]); // 5.0
    wire [16:0] v217; shift_adder #(17, 8, 1, 0, 17, 0, 1) op_217 (v216[16:0], 8'b10000000, v217[16:0]); // 5.0
    wire [15:0] v218; assign v218[15:0] = v217[15:0] & {16{~v217[16]}}; // 5.0
    wire [15:0] v219; shift_adder #(16, 7, 0, 0, 16, 0, 0) op_219 (v218[15:0], 7'b1000000, v219[15:0]); // 5.0
    wire [4:0] v220; assign v220[4:0] = v219[11:7]; // 5.0
    wire [5:0] v221; shift_adder #(5, 4, 0, 0, 6, 1, 0) op_221 (v115[4:0], v212[3:0], v221[5:0]); // 5.0
    wire [7:0] v222; shift_adder #(5, 4, 0, 0, 8, 3, 0) op_222 (v191[4:0], v28[3:0], v222[7:0]); // 5.0
    wire [5:0] v223; assign v223[5:0] = model_inp[1091:1086]; // 4.0
    wire [6:0] v224; shift_adder #(6, 4, 0, 0, 7, 1, 1) op_224 (v223[5:0], v206[3:0], v224[6:0]); // 5.0
    wire [7:0] v225; shift_adder #(5, 7, 0, 0, 8, 0, 1) op_225 (v191[4:0], v102[6:0], v225[7:0]); // 5.0
    wire [9:0] v226; shift_adder #(7, 7, 0, 0, 10, -2, 1) op_226 (v192[6:0], v192[6:0], v226[9:0]); // 5.0
    wire [5:0] v227; shift_adder #(3, 4, 0, 0, 6, 1, 1) op_227 (v211[2:0], v206[3:0], v227[5:0]); // 5.0
    wire [7:0] v228; shift_adder #(5, 5, 0, 0, 8, -2, 1) op_228 (v146[4:0], v146[4:0], v228[7:0]); // 5.0
    wire [6:0] v229; shift_adder #(5, 3, 0, 0, 7, -1, 0) op_229 (v27[4:0], v194[2:0], v229[6:0]); // 5.0
    wire [4:0] v230; assign v230[4:0] = model_inp[1096:1092]; // 4.0
    wire [10:0] v231; shift_adder #(5, 7, 0, 0, 11, 3, 0) op_231 (v230[4:0], v102[6:0], v231[10:0]); // 5.0
    wire [5:0] v232; shift_adder #(4, 2, 0, 0, 6, 3, 0) op_232 (v28[3:0], v147[1:0], v232[5:0]); // 5.0
    wire [7:0] v233; shift_adder #(7, 5, 0, 0, 8, 2, 0) op_233 (v192[6:0], v230[4:0], v233[7:0]); // 5.0
    wire [5:0] v234; shift_adder #(2, 5, 0, 0, 6, -1, 0) op_234 (v147[1:0], v191[4:0], v234[5:0]); // 5.0
    wire [5:0] v235; assign v235[5:0] = model_inp[1102:1097]; // 4.0
    wire [6:0] v236; shift_adder #(6, 5, 0, 0, 7, 0, 0) op_236 (v235[5:0], v204[4:0], v236[6:0]); // 5.0
    wire [3:0] v237; assign v237[3:0] = model_inp[1106:1103]; // 4.0
    wire [6:0] v238; shift_adder #(5, 4, 0, 0, 7, 2, 1) op_238 (v204[4:0], v237[3:0], v238[6:0]); // 5.0
    wire [6:0] v239; shift_adder #(5, 5, 0, 0, 7, -1, 0) op_239 (v27[4:0], v191[4:0], v239[6:0]); // 5.0
    wire [6:0] v240; shift_adder #(4, 5, 0, 0, 7, -2, 1) op_240 (v206[3:0], v115[4:0], v240[6:0]); // 5.0
    wire [8:0] v241; shift_adder #(5, 5, 0, 0, 9, 3, 0) op_241 (v146[4:0], v204[4:0], v241[8:0]); // 5.0
    wire [10:0] v242; shift_adder #(9, 5, 0, 0, 11, -1, 0) op_242 (v114[8:0], v115[4:0], v242[10:0]); // 5.0
    wire [5:0] v243; shift_adder #(4, 3, 0, 0, 6, -1, 1) op_243 (v206[3:0], v194[2:0], v243[5:0]); // 5.0
    wire [5:0] v244; assign v244[5:0] = model_inp[1112:1107]; // 4.0
    wire [8:0] v245; shift_adder #(5, 6, 0, 1, 9, 2, 0) op_245 (v146[4:0], v244[5:0], v245[8:0]); // 5.0
    wire [6:0] v246; shift_adder #(4, 5, 0, 0, 7, -2, 0) op_246 (v237[3:0], v146[4:0], v246[6:0]); // 5.0
    wire [4:0] v247; assign v247[4:0] = model_inp[1117:1113]; // 4.0
    wire [5:0] v248; shift_adder #(5, 3, 0, 0, 6, 2, 0) op_248 (v247[4:0], v194[2:0], v248[5:0]); // 5.0
    wire [5:0] v249; shift_adder #(4, 3, 0, 0, 6, -1, 1) op_249 (v237[3:0], v211[2:0], v249[5:0]); // 5.0
    wire [9:0] v250; shift_adder #(2, 9, 0, 0, 10, -6, 0) op_250 (v147[1:0], v114[8:0], v250[9:0]); // 5.0
    wire [5:0] v251; assign v251[5:0] = model_inp[1123:1118]; // 4.0
    wire [7:0] v252; shift_adder #(7, 6, 0, 0, 8, 0, 1) op_252 (v102[6:0], v251[5:0], v252[7:0]); // 5.0
    wire [9:0] v253; shift_adder #(6, 7, 0, 0, 10, 2, 1) op_253 (v223[5:0], v102[6:0], v253[9:0]); // 5.0
    wire [8:0] v254; shift_adder #(6, 5, 0, 0, 9, 3, 0) op_254 (v223[5:0], v115[4:0], v254[8:0]); // 5.0
    wire [7:0] v255; shift_adder #(5, 5, 0, 0, 8, 2, 1) op_255 (v115[4:0], v230[4:0], v255[7:0]); // 5.0
    wire [5:0] v256; shift_adder #(3, 5, 0, 0, 6, -1, 0) op_256 (v211[2:0], v191[4:0], v256[5:0]); // 5.0
    wire [9:0] v257; shift_adder #(9, 4, 0, 0, 10, 3, 1) op_257 (v114[8:0], v237[3:0], v257[9:0]); // 5.0
    wire [16:0] v258; assign v258[16:0] = model_inp[1140:1124]; // 4.0
    wire [17:0] v259; assign v259[17:0] = model_inp[1158:1141]; // 4.0
    wire [15:0] v260; assign v260[15:0] = model_inp[1174:1159]; // 4.0
    wire [16:0] v261; assign v261[16:0] = model_inp[1191:1175]; // 4.0
    wire [15:0] v262; assign v262[15:0] = model_inp[1207:1192]; // 4.0
    wire [14:0] v263; assign v263[14:0] = model_inp[1222:1208]; // 4.0
    wire [8:0] v264; assign v264[8:0] = model_inp[1231:1223]; // 4.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[17:0] = v16[17:0];
    assign model_out[30:18] = v79[12:0];
    assign model_out[47:31] = v258[16:0];
    assign model_out[65:48] = v19[17:0];
    assign model_out[69:66] = v237[3:0];
    assign model_out[74:70] = v26[4:0];
    assign model_out[80:75] = v223[5:0];
    assign model_out[86:81] = v29[5:0];
    assign model_out[104:87] = v259[17:0];
    assign model_out[120:105] = v31[15:0];
    assign model_out[128:121] = v38[7:0];
    assign model_out[133:129] = v49[4:0];
    assign model_out[138:134] = v56[4:0];
    assign model_out[143:139] = v63[4:0];
    assign model_out[147:144] = v42[3:0];
    assign model_out[153:148] = v70[5:0];
    assign model_out[171:154] = v73[17:0];
    assign model_out[176:172] = v78[4:0];
    assign model_out[180:177] = v85[3:0];
    assign model_out[196:181] = v260[15:0];
    assign model_out[212:197] = v95[15:0];
    assign model_out[220:213] = v101[7:0];
    assign model_out[228:221] = v103[7:0];
    assign model_out[246:229] = v106[17:0];
    assign model_out[263:247] = v261[16:0];
    assign model_out[269:264] = v13[5:0];
    assign model_out[275:270] = v113[5:0];
    assign model_out[285:276] = v116[9:0];
    assign model_out[291:286] = v123[5:0];
    assign model_out[297:292] = v129[5:0];
    assign model_out[310:298] = v215[12:0];
    assign model_out[327:311] = v132[16:0];
    assign model_out[332:328] = v146[4:0];
    assign model_out[340:333] = v139[7:0];
    assign model_out[358:341] = v142[17:0];
    assign model_out[366:359] = v1[7:0];
    assign model_out[384:367] = v145[17:0];
    assign model_out[392:385] = v148[7:0];
    assign model_out[401:393] = v149[8:0];
    assign model_out[410:402] = v114[8:0];
    assign model_out[413:411] = v194[2:0];
    assign model_out[420:414] = v192[6:0];
    assign model_out[426:421] = v92[5:0];
    assign model_out[433:427] = v203[6:0];
    assign model_out[439:434] = v171[5:0];
    assign model_out[449:440] = v178[9:0];
    assign model_out[465:450] = v262[15:0];
    assign model_out[483:466] = v181[17:0];
    assign model_out[499:484] = v190[15:0];
    assign model_out[508:500] = v193[8:0];
    assign model_out[513:509] = v115[4:0];
    assign model_out[520:514] = v102[6:0];
    assign model_out[528:521] = v195[7:0];
    assign model_out[535:529] = v202[6:0];
    assign model_out[541:536] = v251[5:0];
    assign model_out[549:542] = v205[7:0];
    assign model_out[554:550] = v169[4:0];
    assign model_out[560:555] = v207[5:0];
    assign model_out[565:561] = v191[4:0];
    assign model_out[584:566] = v210[18:0];
    assign model_out[599:585] = v263[14:0];
    assign model_out[603:600] = v170[3:0];
    assign model_out[607:604] = v6[3:0];
    assign model_out[612:608] = v213[4:0];
    assign model_out[617:613] = v220[4:0];
    assign model_out[622:618] = v230[4:0];
    assign model_out[628:623] = v221[5:0];
    assign model_out[636:629] = v222[7:0];
    assign model_out[641:637] = v247[4:0];
    assign model_out[647:642] = v187[5:0];
    assign model_out[653:648] = v155[5:0];
    assign model_out[660:654] = v224[6:0];
    assign model_out[668:661] = v225[7:0];
    assign model_out[674:669] = v227[5:0];
    assign model_out[678:675] = v28[3:0];
    assign model_out[682:679] = v206[3:0];
    assign model_out[690:683] = v228[7:0];
    assign model_out[697:691] = v229[6:0];
    assign model_out[708:698] = v231[10:0];
    assign model_out[713:709] = v162[4:0];
    assign model_out[719:714] = v232[5:0];
    assign model_out[725:720] = v234[5:0];
    assign model_out[732:726] = v236[6:0];
    assign model_out[739:733] = v238[6:0];
    assign model_out[746:740] = v239[6:0];
    assign model_out[753:747] = v240[6:0];
    assign model_out[762:754] = v241[8:0];
    assign model_out[771:763] = v264[8:0];
    assign model_out[777:772] = v243[5:0];
    assign model_out[786:778] = v245[8:0];
    assign model_out[793:787] = v246[6:0];
    assign model_out[798:794] = v27[4:0];
    assign model_out[804:799] = v248[5:0];
    assign model_out[808:805] = v212[3:0];
    assign model_out[814:809] = v249[5:0];
    assign model_out[824:815] = v250[9:0];
    assign model_out[832:825] = v252[7:0];
    assign model_out[841:833] = v254[8:0];
    assign model_out[849:842] = v255[7:0];
    assign model_out[855:850] = v256[5:0];
    assign model_out[865:856] = v257[9:0];
    assign model_out[870:866] = v204[4:0];
    assign model_out[872:871] = v147[1:0];
    assign model_out[882:873] = v226[9:0];
    assign model_out[890:883] = v233[7:0];
    assign model_out[901:891] = v242[10:0];
    assign model_out[911:902] = v253[9:0];
    assign model_out[914:912] = v211[2:0];

endmodule
