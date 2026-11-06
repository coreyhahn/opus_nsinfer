`timescale 1 ns / 1 ps

module jsc_stage3 (
    input [1926:0] model_inp,
    output [1231:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [16:0] v0; assign v0[16:0] = model_inp[16:0]; // 3.0
    wire [15:0] v1; assign v1[15:0] = model_inp[32:17]; // 3.0
    wire [18:0] v2; shift_adder #(17, 16, 1, 1, 19, 2, 0) op_2 (v0[16:0], v1[15:0], v2[18:0]); // 4.0
    wire [13:0] v3; assign v3[13:0] = model_inp[46:33]; // 3.0
    wire [15:0] v4; assign v4[15:0] = model_inp[62:47]; // 3.0
    wire [16:0] v5; shift_adder #(14, 16, 1, 1, 17, -1, 0) op_5 (v3[13:0], v4[15:0], v5[16:0]); // 4.0
    wire [15:0] v6; assign v6[15:0] = model_inp[78:63]; // 3.0
    wire [12:0] v7; assign v7[12:0] = model_inp[91:79]; // 3.0
    wire [17:0] v8; shift_adder #(16, 13, 1, 1, 18, 4, 0) op_8 (v6[15:0], v7[12:0], v8[17:0]); // 4.0
    wire [12:0] v9; assign v9[12:0] = model_inp[104:92]; // 3.0
    wire [6:0] v10; assign v10[6:0] = model_inp[111:105]; // 3.0
    wire [12:0] v11; shift_adder #(13, 7, 1, 1, 13, 0, 1) op_11 (v9[12:0], v10[6:0], v11[12:0]); // 4.0
    wire [16:0] v12; assign v12[16:0] = model_inp[128:112]; // 3.0
    wire [12:0] v13; assign v13[12:0] = model_inp[141:129]; // 3.0
    wire [16:0] v14; shift_adder #(17, 13, 1, 1, 17, 0, 0) op_14 (v12[16:0], v13[12:0], v14[16:0]); // 4.0
    wire [16:0] v15; shift_adder #(17, 9, 1, 0, 17, 0, 1) op_15 (v14[16:0], 9'b111100000, v15[16:0]); // 4.0
    wire [15:0] v16; assign v16[15:0] = v15[15:0] & {16{~v15[16]}}; // 4.0
    wire [15:0] v17; shift_adder #(16, 7, 0, 0, 16, 0, 0) op_17 (v16[15:0], 7'b1000000, v17[15:0]); // 4.0
    wire [6:0] v18; assign v18[6:0] = v17[13:7]; // 4.0
    wire [12:0] v19; assign v19[12:0] = model_inp[154:142]; // 3.0
    wire [14:0] v20; assign v20[14:0] = model_inp[169:155]; // 3.0
    wire [16:0] v21; shift_adder #(13, 15, 1, 1, 17, -3, 1) op_21 (v19[12:0], v20[14:0], v21[16:0]); // 4.0
    wire [13:0] v22; assign v22[13:0] = model_inp[183:170]; // 3.0
    wire [11:0] v23; assign v23[11:0] = model_inp[195:184]; // 3.0
    wire [14:0] v24; shift_adder #(14, 12, 1, 1, 15, 2, 1) op_24 (v22[13:0], v23[11:0], v24[14:0]); // 4.0
    wire [14:0] v25; shift_adder #(15, 6, 1, 0, 15, 0, 1) op_25 (v24[14:0], 6'b111000, v25[14:0]); // 4.0
    wire [13:0] v26; assign v26[13:0] = v25[13:0] & {14{~v25[14]}}; // 4.0
    wire [13:0] v27; shift_adder #(14, 6, 0, 0, 14, 0, 0) op_27 (v26[13:0], 6'b100000, v27[13:0]); // 4.0
    wire [3:0] v28; assign v28[3:0] = v27[9:6]; // 4.0
    wire [15:0] v29; assign v29[15:0] = model_inp[211:196]; // 3.0
    wire [14:0] v30; assign v30[14:0] = model_inp[226:212]; // 3.0
    wire [16:0] v31; shift_adder #(16, 15, 1, 1, 17, 0, 1) op_31 (v29[15:0], v30[14:0], v31[16:0]); // 4.0
    wire [13:0] v32; assign v32[13:0] = model_inp[240:227]; // 3.0
    wire [14:0] v33; assign v33[14:0] = model_inp[255:241]; // 3.0
    wire [15:0] v34; shift_adder #(14, 15, 1, 1, 16, 0, 0) op_34 (v32[13:0], v33[14:0], v34[15:0]); // 4.0
    wire [14:0] v35; assign v35[14:0] = v34[14:0] & {15{~v34[15]}}; // 4.0
    wire [14:0] v36; shift_adder #(15, 5, 0, 0, 15, 0, 0) op_36 (v35[14:0], 5'b10000, v36[14:0]); // 4.0
    wire [5:0] v37; assign v37[5:0] = v36[10:5]; // 4.0
    wire [15:0] v38; assign v38[15:0] = model_inp[271:256]; // 3.0
    wire [13:0] v39; assign v39[13:0] = model_inp[285:272]; // 3.0
    wire [16:0] v40; shift_adder #(16, 14, 1, 1, 17, 0, 1) op_40 (v38[15:0], v39[13:0], v40[16:0]); // 4.0
    wire [16:0] v41; shift_adder #(17, 9, 1, 0, 17, 0, 1) op_41 (v40[16:0], 9'b111100000, v41[16:0]); // 4.0
    wire [15:0] v42; assign v42[15:0] = v41[15:0] & {16{~v41[16]}}; // 4.0
    wire [15:0] v43; shift_adder #(16, 8, 0, 0, 16, 0, 0) op_43 (v42[15:0], 8'b10000000, v43[15:0]); // 4.0
    wire [4:0] v44; assign v44[4:0] = v43[12:8]; // 4.0
    wire [14:0] v45; assign v45[14:0] = model_inp[300:286]; // 3.0
    wire [12:0] v46; assign v46[12:0] = model_inp[313:301]; // 3.0
    wire [15:0] v47; shift_adder #(15, 13, 1, 1, 16, 1, 0) op_47 (v45[14:0], v46[12:0], v47[15:0]); // 4.0
    wire [15:0] v48; shift_adder #(16, 10, 1, 0, 16, 0, 1) op_48 (v47[15:0], 10'b1111000000, v48[15:0]); // 4.0
    wire [14:0] v49; assign v49[14:0] = v48[14:0] & {15{~v48[15]}}; // 4.0
    wire [14:0] v50; shift_adder #(15, 9, 0, 0, 15, 0, 0) op_50 (v49[14:0], 9'b100000000, v50[14:0]); // 4.0
    wire [3:0] v51; assign v51[3:0] = v50[12:9]; // 4.0
    wire [14:0] v52; assign v52[14:0] = model_inp[328:314]; // 3.0
    wire [16:0] v53; assign v53[16:0] = model_inp[345:329]; // 3.0
    wire [17:0] v54; shift_adder #(15, 17, 1, 1, 18, -2, 0) op_54 (v52[14:0], v53[16:0], v54[17:0]); // 4.0
    wire [14:0] v55; assign v55[14:0] = model_inp[360:346]; // 3.0
    wire [11:0] v56; assign v56[11:0] = model_inp[372:361]; // 3.0
    wire [15:0] v57; shift_adder #(15, 12, 1, 1, 16, 3, 1) op_57 (v55[14:0], v56[11:0], v57[15:0]); // 4.0
    wire [13:0] v58; assign v58[13:0] = model_inp[386:373]; // 3.0
    wire [11:0] v59; assign v59[11:0] = model_inp[398:387]; // 3.0
    wire [14:0] v60; shift_adder #(14, 12, 1, 1, 15, 1, 1) op_60 (v58[13:0], v59[11:0], v60[14:0]); // 4.0
    wire [13:0] v61; assign v61[13:0] = model_inp[412:399]; // 3.0
    wire [10:0] v62; assign v62[10:0] = model_inp[423:413]; // 3.0
    wire [14:0] v63; shift_adder #(14, 11, 1, 1, 15, 2, 0) op_63 (v61[13:0], v62[10:0], v63[14:0]); // 4.0
    wire [14:0] v64; shift_adder #(15, 9, 1, 0, 15, 0, 1) op_64 (v63[14:0], 9'b110000000, v64[14:0]); // 4.0
    wire [13:0] v65; assign v65[13:0] = v64[13:0] & {14{~v64[14]}}; // 4.0
    wire [13:0] v66; shift_adder #(14, 7, 0, 0, 14, 0, 0) op_66 (v65[13:0], 7'b1000000, v66[13:0]); // 4.0
    wire [3:0] v67; assign v67[3:0] = v66[10:7]; // 4.0
    wire [14:0] v68; assign v68[14:0] = model_inp[438:424]; // 3.0
    wire [16:0] v69; assign v69[16:0] = model_inp[455:439]; // 3.0
    wire [17:0] v70; shift_adder #(15, 17, 1, 1, 18, -2, 0) op_70 (v68[14:0], v69[16:0], v70[17:0]); // 4.0
    wire [15:0] v71; assign v71[15:0] = model_inp[471:456]; // 3.0
    wire [13:0] v72; assign v72[13:0] = model_inp[485:472]; // 3.0
    wire [16:0] v73; shift_adder #(16, 14, 1, 1, 17, 0, 1) op_73 (v71[15:0], v72[13:0], v73[16:0]); // 4.0
    wire [13:0] v74; assign v74[13:0] = model_inp[499:486]; // 3.0
    wire [14:0] v75; assign v75[14:0] = model_inp[514:500]; // 3.0
    wire [15:0] v76; shift_adder #(14, 15, 1, 1, 16, 0, 1) op_76 (v74[13:0], v75[14:0], v76[15:0]); // 4.0
    wire [12:0] v77; shift_adder #(13, 7, 1, 0, 13, 0, 1) op_77 (v11[12:0], 7'b1010000, v77[12:0]); // 4.0
    wire [11:0] v78; assign v78[11:0] = v77[11:0] & {12{~v77[12]}}; // 4.0
    wire [11:0] v79; shift_adder #(12, 5, 0, 0, 12, 0, 0) op_79 (v78[11:0], 5'b10000, v79[11:0]); // 4.0
    wire [2:0] v80; assign v80[2:0] = v79[7:5]; // 4.0
    wire [11:0] v81; assign v81[11:0] = model_inp[526:515]; // 3.0
    wire [11:0] v82; assign v82[11:0] = model_inp[538:527]; // 3.0
    wire [12:0] v83; shift_adder #(12, 12, 1, 1, 13, 0, 1) op_83 (v81[11:0], v82[11:0], v83[12:0]); // 4.0
    wire [13:0] v84; assign v84[13:0] = model_inp[552:539]; // 3.0
    wire [14:0] v85; assign v85[14:0] = model_inp[567:553]; // 3.0
    wire [16:0] v86; shift_adder #(14, 15, 1, 1, 17, 2, 0) op_86 (v84[13:0], v85[14:0], v86[16:0]); // 4.0
    wire [16:0] v87; assign v87[16:0] = model_inp[584:568]; // 3.0
    wire [12:0] v88; assign v88[12:0] = model_inp[597:585]; // 3.0
    wire [17:0] v89; shift_adder #(17, 13, 1, 1, 18, 2, 0) op_89 (v87[16:0], v88[12:0], v89[17:0]); // 4.0
    wire [16:0] v90; assign v90[16:0] = model_inp[614:598]; // 3.0
    wire [13:0] v91; assign v91[13:0] = model_inp[628:615]; // 3.0
    wire [16:0] v92; shift_adder #(17, 14, 1, 1, 17, 1, 1) op_92 (v90[16:0], v91[13:0], v92[16:0]); // 4.0
    wire [14:0] v93; assign v93[14:0] = model_inp[643:629]; // 3.0
    wire [11:0] v94; assign v94[11:0] = model_inp[655:644]; // 3.0
    wire [15:0] v95; shift_adder #(15, 12, 1, 1, 16, 2, 1) op_95 (v93[14:0], v94[11:0], v95[15:0]); // 4.0
    wire [15:0] v96; shift_adder #(16, 8, 1, 0, 16, 0, 0) op_96 (v95[15:0], 8'b11110000, v96[15:0]); // 4.0
    wire [14:0] v97; assign v97[14:0] = v96[14:0] & {15{~v96[15]}}; // 4.0
    wire [14:0] v98; shift_adder #(15, 7, 0, 0, 15, 0, 0) op_98 (v97[14:0], 7'b1000000, v98[14:0]); // 4.0
    wire [4:0] v99; assign v99[4:0] = v98[11:7]; // 4.0
    wire [13:0] v100; assign v100[13:0] = model_inp[669:656]; // 3.0
    wire [15:0] v101; assign v101[15:0] = model_inp[685:670]; // 3.0
    wire [16:0] v102; shift_adder #(14, 16, 1, 1, 17, -1, 0) op_102 (v100[13:0], v101[15:0], v102[16:0]); // 4.0
    wire [14:0] v103; assign v103[14:0] = model_inp[700:686]; // 3.0
    wire [10:0] v104; assign v104[10:0] = model_inp[711:701]; // 3.0
    wire [16:0] v105; shift_adder #(15, 11, 1, 1, 17, 5, 1) op_105 (v103[14:0], v104[10:0], v105[16:0]); // 4.0
    wire [13:0] v106; assign v106[13:0] = model_inp[725:712]; // 3.0
    wire [8:0] v107; assign v107[8:0] = model_inp[734:726]; // 3.0
    wire [14:0] v108; shift_adder #(14, 9, 1, 1, 15, 5, 1) op_108 (v106[13:0], v107[8:0], v108[14:0]); // 4.0
    wire [12:0] v109; assign v109[12:0] = model_inp[747:735]; // 3.0
    wire [12:0] v110; assign v110[12:0] = model_inp[760:748]; // 3.0
    wire [15:0] v111; shift_adder #(13, 13, 1, 1, 16, 3, 1) op_111 (v109[12:0], v110[12:0], v111[15:0]); // 4.0
    wire [16:0] v112; assign v112[16:0] = model_inp[777:761]; // 3.0
    wire [9:0] v113; assign v113[9:0] = model_inp[787:778]; // 3.0
    wire [16:0] v114; shift_adder #(17, 10, 1, 1, 17, 2, 1) op_114 (v112[16:0], v113[9:0], v114[16:0]); // 4.0
    wire [13:0] v115; assign v115[13:0] = model_inp[801:788]; // 3.0
    wire [16:0] v116; assign v116[16:0] = model_inp[818:802]; // 3.0
    wire [16:0] v117; shift_adder #(14, 17, 1, 1, 17, 0, 1) op_117 (v115[13:0], v116[16:0], v117[16:0]); // 4.0
    wire [3:0] v118; assign v118[3:0] = model_inp[822:819]; // 3.0
    wire [16:0] v119; assign v119[16:0] = model_inp[839:823]; // 3.0
    wire [16:0] v120; shift_adder #(4, 17, 1, 1, 17, -4, 1) op_120 (v118[3:0], v119[16:0], v120[16:0]); // 4.0
    wire [13:0] v121; assign v121[13:0] = model_inp[853:840]; // 3.0
    wire [12:0] v122; assign v122[12:0] = model_inp[866:854]; // 3.0
    wire [14:0] v123; shift_adder #(14, 13, 1, 1, 15, 1, 0) op_123 (v121[13:0], v122[12:0], v123[14:0]); // 4.0
    wire [14:0] v124; assign v124[14:0] = model_inp[881:867]; // 3.0
    wire [15:0] v125; assign v125[15:0] = model_inp[897:882]; // 3.0
    wire [16:0] v126; shift_adder #(15, 16, 1, 1, 17, 1, 0) op_126 (v124[14:0], v125[15:0], v126[16:0]); // 4.0
    wire [16:0] v127; shift_adder #(17, 8, 1, 0, 17, 0, 1) op_127 (v126[16:0], 8'b11110000, v127[16:0]); // 4.0
    wire [15:0] v128; assign v128[15:0] = v127[15:0] & {16{~v127[16]}}; // 4.0
    wire [15:0] v129; shift_adder #(16, 6, 0, 0, 16, 0, 0) op_129 (v128[15:0], 6'b100000, v129[15:0]); // 4.0
    wire [8:0] v130; assign v130[8:0] = v129[14:6]; // 4.0
    wire [12:0] v131; assign v131[12:0] = model_inp[910:898]; // 3.0
    wire [16:0] v132; assign v132[16:0] = model_inp[927:911]; // 3.0
    wire [17:0] v133; shift_adder #(13, 17, 1, 1, 18, -4, 1) op_133 (v131[12:0], v132[16:0], v133[17:0]); // 4.0
    wire [13:0] v134; assign v134[13:0] = model_inp[941:928]; // 3.0
    wire [13:0] v135; assign v135[13:0] = model_inp[955:942]; // 3.0
    wire [14:0] v136; shift_adder #(14, 14, 1, 1, 15, -1, 1) op_136 (v134[13:0], v135[13:0], v136[14:0]); // 4.0
    wire [13:0] v137; assign v137[13:0] = model_inp[969:956]; // 3.0
    wire [13:0] v138; assign v138[13:0] = model_inp[983:970]; // 3.0
    wire [14:0] v139; shift_adder #(14, 14, 1, 1, 15, 0, 1) op_139 (v137[13:0], v138[13:0], v139[14:0]); // 4.0
    wire [15:0] v140; assign v140[15:0] = model_inp[999:984]; // 3.0
    wire [13:0] v141; assign v141[13:0] = model_inp[1013:1000]; // 3.0
    wire [15:0] v142; shift_adder #(16, 14, 1, 1, 16, 0, 1) op_142 (v140[15:0], v141[13:0], v142[15:0]); // 4.0
    wire [15:0] v143; shift_adder #(16, 8, 1, 0, 16, 0, 1) op_143 (v142[15:0], 8'b11111100, v143[15:0]); // 4.0
    wire [14:0] v144; assign v144[14:0] = v143[14:0] & {15{~v143[15]}}; // 4.0
    wire [14:0] v145; shift_adder #(15, 6, 0, 0, 15, 0, 0) op_145 (v144[14:0], 6'b100000, v145[14:0]); // 4.0
    wire [4:0] v146; assign v146[4:0] = v145[10:6]; // 4.0
    wire [11:0] v147; assign v147[11:0] = model_inp[1025:1014]; // 3.0
    wire [11:0] v148; assign v148[11:0] = model_inp[1037:1026]; // 3.0
    wire [12:0] v149; shift_adder #(12, 12, 1, 1, 13, 0, 1) op_149 (v147[11:0], v148[11:0], v149[12:0]); // 4.0
    wire [16:0] v150; assign v150[16:0] = model_inp[1054:1038]; // 3.0
    wire [16:0] v151; shift_adder #(11, 17, 1, 1, 17, -2, 0) op_151 (v62[10:0], v150[16:0], v151[16:0]); // 4.0
    wire [10:0] v152; assign v152[10:0] = model_inp[1065:1055]; // 3.0
    wire [10:0] v153; assign v153[10:0] = model_inp[1076:1066]; // 3.0
    wire [11:0] v154; shift_adder #(11, 11, 1, 1, 12, 0, 1) op_154 (v152[10:0], v153[10:0], v154[11:0]); // 4.0
    wire [14:0] v155; assign v155[14:0] = model_inp[1091:1077]; // 3.0
    wire [11:0] v156; assign v156[11:0] = model_inp[1103:1092]; // 3.0
    wire [16:0] v157; shift_adder #(15, 12, 1, 1, 17, 4, 1) op_157 (v155[14:0], v156[11:0], v157[16:0]); // 4.0
    wire [14:0] v158; assign v158[14:0] = model_inp[1118:1104]; // 3.0
    wire [12:0] v159; assign v159[12:0] = model_inp[1131:1119]; // 3.0
    wire [15:0] v160; shift_adder #(15, 13, 1, 1, 16, 2, 0) op_160 (v158[14:0], v159[12:0], v160[15:0]); // 4.0
    wire [15:0] v161; shift_adder #(16, 9, 1, 0, 16, 0, 1) op_161 (v160[15:0], 9'b110000000, v161[15:0]); // 4.0
    wire [14:0] v162; assign v162[14:0] = v161[14:0] & {15{~v161[15]}}; // 4.0
    wire [14:0] v163; shift_adder #(15, 7, 0, 0, 15, 0, 0) op_163 (v162[14:0], 7'b1000000, v163[14:0]); // 4.0
    wire [4:0] v164; assign v164[4:0] = v163[11:7]; // 4.0
    wire [13:0] v165; assign v165[13:0] = model_inp[1145:1132]; // 3.0
    wire [12:0] v166; assign v166[12:0] = model_inp[1158:1146]; // 3.0
    wire [14:0] v167; shift_adder #(14, 13, 1, 1, 15, 1, 0) op_167 (v165[13:0], v166[12:0], v167[14:0]); // 4.0
    wire [14:0] v168; shift_adder #(15, 9, 1, 0, 15, 0, 1) op_168 (v167[14:0], 9'b100000000, v168[14:0]); // 4.0
    wire [13:0] v169; assign v169[13:0] = v168[13:0] & {14{~v168[14]}}; // 4.0
    wire [13:0] v170; shift_adder #(14, 6, 0, 0, 14, 0, 0) op_170 (v169[13:0], 6'b100000, v170[13:0]); // 4.0
    wire [3:0] v171; assign v171[3:0] = v170[9:6]; // 4.0
    wire [16:0] v172; assign v172[16:0] = model_inp[1175:1159]; // 3.0
    wire [13:0] v173; assign v173[13:0] = model_inp[1189:1176]; // 3.0
    wire [17:0] v174; shift_adder #(17, 14, 1, 1, 18, 2, 1) op_174 (v172[16:0], v173[13:0], v174[17:0]); // 4.0
    wire [16:0] v175; assign v175[16:0] = model_inp[1206:1190]; // 3.0
    wire [13:0] v176; assign v176[13:0] = model_inp[1220:1207]; // 3.0
    wire [16:0] v177; shift_adder #(17, 14, 1, 1, 17, 0, 0) op_177 (v175[16:0], v176[13:0], v177[16:0]); // 4.0
    wire [16:0] v178; shift_adder #(17, 8, 1, 0, 17, 0, 1) op_178 (v177[16:0], 8'b10110000, v178[16:0]); // 4.0
    wire [15:0] v179; assign v179[15:0] = v178[15:0] & {16{~v178[16]}}; // 4.0
    wire [15:0] v180; shift_adder #(16, 7, 0, 0, 16, 0, 0) op_180 (v179[15:0], 7'b1000000, v180[15:0]); // 4.0
    wire [6:0] v181; assign v181[6:0] = v180[13:7]; // 4.0
    wire [13:0] v182; assign v182[13:0] = model_inp[1234:1221]; // 3.0
    wire [13:0] v183; assign v183[13:0] = model_inp[1248:1235]; // 3.0
    wire [15:0] v184; shift_adder #(14, 14, 1, 1, 16, -2, 1) op_184 (v182[13:0], v183[13:0], v184[15:0]); // 4.0
    wire [15:0] v185; shift_adder #(16, 7, 1, 0, 16, 0, 1) op_185 (v184[15:0], 7'b1100000, v185[15:0]); // 4.0
    wire [14:0] v186; assign v186[14:0] = v185[14:0] & {15{~v185[15]}}; // 4.0
    wire [14:0] v187; shift_adder #(15, 6, 0, 0, 15, 0, 0) op_187 (v186[14:0], 6'b100000, v187[14:0]); // 4.0
    wire [6:0] v188; assign v188[6:0] = v187[12:6]; // 4.0
    wire [15:0] v189; assign v189[15:0] = model_inp[1264:1249]; // 3.0
    wire [15:0] v190; assign v190[15:0] = model_inp[1280:1265]; // 3.0
    wire [16:0] v191; shift_adder #(16, 16, 1, 1, 17, 0, 1) op_191 (v189[15:0], v190[15:0], v191[16:0]); // 4.0
    wire [13:0] v192; assign v192[13:0] = model_inp[1294:1281]; // 3.0
    wire [14:0] v193; shift_adder #(10, 14, 1, 1, 15, -2, 0) op_193 (v113[9:0], v192[13:0], v193[14:0]); // 4.0
    wire [16:0] v194; assign v194[16:0] = model_inp[1311:1295]; // 3.0
    wire [14:0] v195; assign v195[14:0] = model_inp[1326:1312]; // 3.0
    wire [16:0] v196; shift_adder #(17, 15, 1, 1, 17, 1, 1) op_196 (v194[16:0], v195[14:0], v196[16:0]); // 4.0
    wire [12:0] v197; assign v197[12:0] = model_inp[1339:1327]; // 3.0
    wire [12:0] v198; assign v198[12:0] = model_inp[1352:1340]; // 3.0
    wire [14:0] v199; shift_adder #(13, 13, 1, 1, 15, 1, 1) op_199 (v197[12:0], v198[12:0], v199[14:0]); // 4.0
    wire [18:0] v200; assign v200[18:0] = model_inp[1371:1353]; // 3.0
    wire [15:0] v201; assign v201[15:0] = model_inp[1387:1372]; // 3.0
    wire [19:0] v202; shift_adder #(19, 16, 1, 1, 20, 3, 0) op_202 (v200[18:0], v201[15:0], v202[19:0]); // 4.0
    wire [15:0] v203; assign v203[15:0] = model_inp[1403:1388]; // 3.0
    wire [7:0] v204; assign v204[7:0] = model_inp[1411:1404]; // 3.0
    wire [15:0] v205; shift_adder #(16, 8, 1, 1, 16, 0, 1) op_205 (v203[15:0], v204[7:0], v205[15:0]); // 4.0
    wire [13:0] v206; assign v206[13:0] = model_inp[1425:1412]; // 3.0
    wire [14:0] v207; assign v207[14:0] = model_inp[1440:1426]; // 3.0
    wire [17:0] v208; shift_adder #(14, 15, 1, 1, 18, -3, 0) op_208 (v206[13:0], v207[14:0], v208[17:0]); // 4.0
    wire [13:0] v209; assign v209[13:0] = model_inp[1454:1441]; // 3.0
    wire [12:0] v210; assign v210[12:0] = model_inp[1467:1455]; // 3.0
    wire [14:0] v211; shift_adder #(14, 13, 1, 1, 15, 1, 0) op_211 (v209[13:0], v210[12:0], v211[14:0]); // 4.0
    wire [13:0] v212; assign v212[13:0] = model_inp[1481:1468]; // 3.0
    wire [15:0] v213; shift_adder #(14, 14, 1, 1, 16, 1, 0) op_213 (v84[13:0], v212[13:0], v213[15:0]); // 4.0
    wire [13:0] v214; assign v214[13:0] = model_inp[1495:1482]; // 3.0
    wire [13:0] v215; assign v215[13:0] = model_inp[1509:1496]; // 3.0
    wire [14:0] v216; shift_adder #(14, 14, 1, 1, 15, 1, 0) op_216 (v214[13:0], v215[13:0], v216[14:0]); // 4.0
    wire [14:0] v217; shift_adder #(15, 7, 1, 0, 15, 0, 0) op_217 (v216[14:0], 7'b1000000, v217[14:0]); // 4.0
    wire [13:0] v218; assign v218[13:0] = v217[13:0] & {14{~v217[14]}}; // 4.0
    wire [13:0] v219; shift_adder #(14, 6, 0, 0, 14, 0, 0) op_219 (v218[13:0], 6'b100000, v219[13:0]); // 4.0
    wire [4:0] v220; assign v220[4:0] = v219[10:6]; // 4.0
    wire [14:0] v221; assign v221[14:0] = model_inp[1524:1510]; // 3.0
    wire [16:0] v222; assign v222[16:0] = model_inp[1541:1525]; // 3.0
    wire [16:0] v223; shift_adder #(15, 17, 1, 1, 17, 0, 0) op_223 (v221[14:0], v222[16:0], v223[16:0]); // 4.0
    wire [14:0] v224; assign v224[14:0] = model_inp[1556:1542]; // 3.0
    wire [14:0] v225; assign v225[14:0] = model_inp[1571:1557]; // 3.0
    wire [17:0] v226; shift_adder #(15, 15, 1, 1, 18, -2, 0) op_226 (v224[14:0], v225[14:0], v226[17:0]); // 4.0
    wire [14:0] v227; assign v227[14:0] = model_inp[1586:1572]; // 3.0
    wire [13:0] v228; assign v228[13:0] = model_inp[1600:1587]; // 3.0
    wire [15:0] v229; shift_adder #(15, 14, 1, 1, 16, 1, 0) op_229 (v227[14:0], v228[13:0], v229[15:0]); // 4.0
    wire [15:0] v230; shift_adder #(16, 6, 1, 0, 16, 0, 0) op_230 (v205[15:0], 6'b111000, v230[15:0]); // 4.0
    wire [14:0] v231; assign v231[14:0] = v230[14:0] & {15{~v230[15]}}; // 4.0
    wire [14:0] v232; shift_adder #(15, 6, 0, 0, 15, 0, 0) op_232 (v231[14:0], 6'b100000, v232[14:0]); // 4.0
    wire [4:0] v233; assign v233[4:0] = v232[10:6]; // 4.0
    wire [4:0] v234; assign v234[4:0] = model_inp[1605:1601]; // 3.0
    wire [2:0] v235; assign v235[2:0] = model_inp[1608:1606]; // 3.0
    wire [5:0] v236; shift_adder #(5, 3, 0, 0, 6, 2, 0) op_236 (v234[4:0], v235[2:0], v236[5:0]); // 4.0
    wire [5:0] v237; assign v237[5:0] = model_inp[1614:1609]; // 3.0
    wire [8:0] v238; shift_adder #(5, 6, 0, 0, 9, -3, 0) op_238 (v234[4:0], v237[5:0], v238[8:0]); // 4.0
    wire [3:0] v239; assign v239[3:0] = model_inp[1618:1615]; // 3.0
    wire [5:0] v240; shift_adder #(4, 5, 0, 0, 6, -1, 1) op_240 (v239[3:0], v234[4:0], v240[5:0]); // 4.0
    wire [13:0] v241; assign v241[13:0] = model_inp[1632:1619]; // 3.0
    wire [15:0] v242; assign v242[15:0] = model_inp[1648:1633]; // 3.0
    wire [13:0] v243; assign v243[13:0] = model_inp[1662:1649]; // 3.0
    wire [19:0] v244; assign v244[19:0] = model_inp[1682:1663]; // 3.0
    wire [14:0] v245; assign v245[14:0] = model_inp[1697:1683]; // 3.0
    wire [15:0] v246; assign v246[15:0] = model_inp[1713:1698]; // 3.0
    wire [13:0] v247; assign v247[13:0] = model_inp[1727:1714]; // 3.0
    wire [12:0] v248; assign v248[12:0] = model_inp[1740:1728]; // 3.0
    wire [15:0] v249; assign v249[15:0] = model_inp[1756:1741]; // 3.0
    wire [14:0] v250; assign v250[14:0] = model_inp[1771:1757]; // 3.0
    wire [15:0] v251; assign v251[15:0] = model_inp[1787:1772]; // 3.0
    wire [15:0] v252; assign v252[15:0] = model_inp[1803:1788]; // 3.0
    wire [15:0] v253; assign v253[15:0] = model_inp[1819:1804]; // 3.0
    wire [1:0] v254; assign v254[1:0] = model_inp[1821:1820]; // 3.0
    wire [13:0] v255; assign v255[13:0] = model_inp[1835:1822]; // 3.0
    wire [13:0] v256; assign v256[13:0] = model_inp[1849:1836]; // 3.0
    wire [13:0] v257; assign v257[13:0] = model_inp[1863:1850]; // 3.0
    wire [16:0] v258; assign v258[16:0] = model_inp[1880:1864]; // 3.0
    wire [12:0] v259; assign v259[12:0] = model_inp[1893:1881]; // 3.0
    wire [16:0] v260; assign v260[16:0] = model_inp[1910:1894]; // 3.0
    wire [15:0] v261; assign v261[15:0] = model_inp[1926:1911]; // 3.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[18:0] = v2[18:0];
    assign model_out[26:19] = v204[7:0];
    assign model_out[43:27] = v5[16:0];
    assign model_out[57:44] = v241[13:0];
    assign model_out[75:58] = v8[17:0];
    assign model_out[88:76] = v46[12:0];
    assign model_out[104:89] = v242[15:0];
    assign model_out[121:105] = v21[16:0];
    assign model_out[138:122] = v31[16:0];
    assign model_out[152:139] = v243[13:0];
    assign model_out[157:153] = v44[4:0];
    assign model_out[161:158] = v51[3:0];
    assign model_out[177:162] = v57[15:0];
    assign model_out[197:178] = v244[19:0];
    assign model_out[212:198] = v60[14:0];
    assign model_out[230:213] = v70[17:0];
    assign model_out[247:231] = v73[16:0];
    assign model_out[262:248] = v245[14:0];
    assign model_out[278:263] = v76[15:0];
    assign model_out[291:279] = v83[12:0];
    assign model_out[307:292] = v246[15:0];
    assign model_out[324:308] = v86[16:0];
    assign model_out[342:325] = v89[17:0];
    assign model_out[359:343] = v92[16:0];
    assign model_out[371:360] = v147[11:0];
    assign model_out[388:372] = v102[16:0];
    assign model_out[401:389] = v11[12:0];
    assign model_out[418:402] = v105[16:0];
    assign model_out[432:419] = v247[13:0];
    assign model_out[447:433] = v108[14:0];
    assign model_out[460:448] = v248[12:0];
    assign model_out[476:461] = v111[15:0];
    assign model_out[493:477] = v114[16:0];
    assign model_out[500:494] = v18[6:0];
    assign model_out[516:501] = v249[15:0];
    assign model_out[533:517] = v117[16:0];
    assign model_out[548:534] = v250[14:0];
    assign model_out[563:549] = v123[14:0];
    assign model_out[572:564] = v130[8:0];
    assign model_out[577:573] = v99[4:0];
    assign model_out[593:578] = v251[15:0];
    assign model_out[611:594] = v133[17:0];
    assign model_out[626:612] = v136[14:0];
    assign model_out[641:627] = v139[14:0];
    assign model_out[656:642] = v55[14:0];
    assign model_out[669:657] = v149[12:0];
    assign model_out[686:670] = v151[16:0];
    assign model_out[702:687] = v252[15:0];
    assign model_out[714:703] = v154[11:0];
    assign model_out[730:715] = v253[15:0];
    assign model_out[747:731] = v157[16:0];
    assign model_out[752:748] = v146[4:0];
    assign model_out[754:753] = v254[1:0];
    assign model_out[772:755] = v174[17:0];
    assign model_out[786:773] = v255[13:0];
    assign model_out[803:787] = v191[16:0];
    assign model_out[818:804] = v193[14:0];
    assign model_out[835:819] = v196[16:0];
    assign model_out[839:836] = v239[3:0];
    assign model_out[854:840] = v199[14:0];
    assign model_out[874:855] = v202[19:0];
    assign model_out[888:875] = v256[13:0];
    assign model_out[906:889] = v208[17:0];
    assign model_out[921:907] = v211[14:0];
    assign model_out[935:922] = v257[13:0];
    assign model_out[951:936] = v213[15:0];
    assign model_out[956:952] = v220[4:0];
    assign model_out[963:957] = v181[6:0];
    assign model_out[966:964] = v80[2:0];
    assign model_out[983:967] = v223[16:0];
    assign model_out[998:984] = v195[14:0];
    assign model_out[1005:999] = v188[6:0];
    assign model_out[1010:1006] = v164[4:0];
    assign model_out[1014:1011] = v67[3:0];
    assign model_out[1031:1015] = v258[16:0];
    assign model_out[1049:1032] = v226[17:0];
    assign model_out[1052:1050] = v235[2:0];
    assign model_out[1056:1053] = v171[3:0];
    assign model_out[1072:1057] = v229[15:0];
    assign model_out[1085:1073] = v259[12:0];
    assign model_out[1091:1086] = v37[5:0];
    assign model_out[1096:1092] = v233[4:0];
    assign model_out[1102:1097] = v236[5:0];
    assign model_out[1106:1103] = v28[3:0];
    assign model_out[1112:1107] = v240[5:0];
    assign model_out[1117:1113] = v234[4:0];
    assign model_out[1123:1118] = v237[5:0];
    assign model_out[1140:1124] = v260[16:0];
    assign model_out[1158:1141] = v54[17:0];
    assign model_out[1174:1159] = v261[15:0];
    assign model_out[1191:1175] = v120[16:0];
    assign model_out[1207:1192] = v205[15:0];
    assign model_out[1222:1208] = v63[14:0];
    assign model_out[1231:1223] = v238[8:0];

endmodule
