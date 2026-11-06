`timescale 1 ns / 1 ps

module jsc_stage9 (
    input [1251:0] model_inp,
    output [798:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [3:0] v0; assign v0[3:0] = model_inp[3:0]; // 9.0
    wire [11:0] v1; assign v1[11:0] = model_inp[15:4]; // 9.0
    wire [11:0] v2; shift_adder #(4, 12, 0, 1, 12, -3, 1) op_2 (v0[3:0], v1[11:0], v2[11:0]); // 10.0
    wire [10:0] v3; assign v3[10:0] = model_inp[26:16]; // 9.0
    wire [10:0] v4; assign v4[10:0] = model_inp[37:27]; // 9.0
    wire [11:0] v5; shift_adder #(11, 11, 1, 1, 12, 1, 0) op_5 (v3[10:0], v4[10:0], v5[11:0]); // 10.0
    wire [13:0] v6; assign v6[13:0] = model_inp[51:38]; // 9.0
    wire [13:0] v7; assign v7[13:0] = model_inp[65:52]; // 9.0
    wire [15:0] v8; shift_adder #(14, 14, 1, 1, 16, 1, 0) op_8 (v6[13:0], v7[13:0], v8[15:0]); // 10.0
    wire [15:0] v9; shift_adder #(16, 8, 1, 0, 16, 0, 0) op_9 (v8[15:0], 8'b10100000, v9[15:0]); // 10.0
    wire [12:0] v10; assign v10[12:0] = v9[12:0] & {13{~v9[15]}}; // 10.0
    wire [12:0] v11; shift_adder #(13, 5, 0, 0, 13, 0, 0) op_11 (v10[12:0], 5'b10000, v11[12:0]); // 10.0
    wire [3:0] v12; assign v12[3:0] = v11[8:5]; // 10.0
    wire [12:0] v13; assign v13[12:0] = model_inp[78:66]; // 9.0
    wire [14:0] v14; assign v14[14:0] = model_inp[93:79]; // 9.0
    wire [14:0] v15; shift_adder #(13, 15, 0, 1, 15, 0, 0) op_15 (v13[12:0], v14[14:0], v15[14:0]); // 10.0
    wire [11:0] v16; assign v16[11:0] = model_inp[105:94]; // 9.0
    wire [9:0] v17; assign v17[9:0] = model_inp[115:106]; // 9.0
    wire [11:0] v18; shift_adder #(12, 10, 1, 1, 12, 1, 0) op_18 (v16[11:0], v17[9:0], v18[11:0]); // 10.0
    wire [13:0] v19; assign v19[13:0] = model_inp[129:116]; // 9.0
    wire [12:0] v20; assign v20[12:0] = model_inp[142:130]; // 9.0
    wire [14:0] v21; shift_adder #(14, 13, 1, 1, 15, 2, 0) op_21 (v19[13:0], v20[12:0], v21[14:0]); // 10.0
    wire [14:0] v22; assign v22[14:0] = model_inp[157:143]; // 9.0
    wire [9:0] v23; assign v23[9:0] = model_inp[167:158]; // 9.0
    wire [14:0] v24; shift_adder #(15, 10, 1, 0, 15, 4, 1) op_24 (v22[14:0], v23[9:0], v24[14:0]); // 10.0
    wire [3:0] v25; assign v25[3:0] = model_inp[171:168]; // 9.0
    wire [7:0] v26; assign v26[7:0] = model_inp[179:172]; // 9.0
    wire [7:0] v27; shift_adder #(4, 8, 0, 1, 8, 0, 1) op_27 (v25[3:0], v26[7:0], v27[7:0]); // 10.0
    wire [9:0] v28; assign v28[9:0] = model_inp[189:180]; // 9.0
    wire [8:0] v29; assign v29[8:0] = model_inp[198:190]; // 9.0
    wire [9:0] v30; shift_adder #(10, 9, 1, 1, 10, 0, 1) op_30 (v28[9:0], v29[8:0], v30[9:0]); // 10.0
    wire [12:0] v31; assign v31[12:0] = model_inp[211:199]; // 9.0
    wire [10:0] v32; assign v32[10:0] = model_inp[222:212]; // 9.0
    wire [13:0] v33; shift_adder #(13, 11, 1, 1, 14, 0, 0) op_33 (v31[12:0], v32[10:0], v33[13:0]); // 10.0
    wire [10:0] v34; assign v34[10:0] = model_inp[233:223]; // 9.0
    wire [10:0] v35; assign v35[10:0] = model_inp[244:234]; // 9.0
    wire [12:0] v36; shift_adder #(11, 11, 1, 1, 13, -2, 0) op_36 (v34[10:0], v35[10:0], v36[12:0]); // 10.0
    wire [11:0] v37; assign v37[11:0] = model_inp[256:245]; // 9.0
    wire [9:0] v38; assign v38[9:0] = model_inp[266:257]; // 9.0
    wire [11:0] v39; shift_adder #(12, 10, 1, 1, 12, 1, 0) op_39 (v37[11:0], v38[9:0], v39[11:0]); // 10.0
    wire [11:0] v40; assign v40[11:0] = model_inp[278:267]; // 9.0
    wire [12:0] v41; assign v41[12:0] = model_inp[291:279]; // 9.0
    wire [13:0] v42; shift_adder #(12, 13, 1, 1, 14, -2, 0) op_42 (v40[11:0], v41[12:0], v42[13:0]); // 10.0
    wire [10:0] v43; assign v43[10:0] = model_inp[302:292]; // 9.0
    wire [12:0] v44; assign v44[12:0] = model_inp[315:303]; // 9.0
    wire [12:0] v45; shift_adder #(11, 13, 1, 1, 13, -1, 1) op_45 (v43[10:0], v44[12:0], v45[12:0]); // 10.0
    wire [12:0] v46; assign v46[12:0] = model_inp[328:316]; // 9.0
    wire [16:0] v47; assign v47[16:0] = model_inp[345:329]; // 9.0
    wire [16:0] v48; shift_adder #(13, 17, 1, 1, 17, -2, 0) op_48 (v46[12:0], v47[16:0], v48[16:0]); // 10.0
    wire [12:0] v49; assign v49[12:0] = model_inp[358:346]; // 9.0
    wire [9:0] v50; assign v50[9:0] = model_inp[368:359]; // 9.0
    wire [12:0] v51; shift_adder #(13, 10, 1, 1, 13, 1, 1) op_51 (v49[12:0], v50[9:0], v51[12:0]); // 10.0
    wire [13:0] v52; assign v52[13:0] = model_inp[382:369]; // 9.0
    wire [10:0] v53; assign v53[10:0] = model_inp[393:383]; // 9.0
    wire [13:0] v54; shift_adder #(14, 11, 1, 1, 14, 0, 1) op_54 (v52[13:0], v53[10:0], v54[13:0]); // 10.0
    wire [14:0] v55; assign v55[14:0] = model_inp[408:394]; // 9.0
    wire [14:0] v56; shift_adder #(15, 11, 1, 1, 15, 2, 1) op_56 (v55[14:0], v35[10:0], v56[14:0]); // 10.0
    wire [13:0] v57; assign v57[13:0] = model_inp[422:409]; // 9.0
    wire [11:0] v58; assign v58[11:0] = model_inp[434:423]; // 9.0
    wire [14:0] v59; shift_adder #(14, 12, 1, 1, 15, 2, 1) op_59 (v57[13:0], v58[11:0], v59[14:0]); // 10.0
    wire [12:0] v60; assign v60[12:0] = model_inp[447:435]; // 9.0
    wire [9:0] v61; assign v61[9:0] = model_inp[457:448]; // 9.0
    wire [13:0] v62; shift_adder #(13, 10, 1, 0, 14, 1, 1) op_62 (v60[12:0], v61[9:0], v62[13:0]); // 10.0
    wire [16:0] v63; assign v63[16:0] = model_inp[474:458]; // 9.0
    wire [13:0] v64; assign v64[13:0] = model_inp[488:475]; // 9.0
    wire [17:0] v65; shift_adder #(17, 14, 1, 1, 18, 3, 0) op_65 (v63[16:0], v64[13:0], v65[17:0]); // 10.0
    wire [4:0] v66; assign v66[4:0] = model_inp[493:489]; // 9.0
    wire [13:0] v67; assign v67[13:0] = model_inp[507:494]; // 9.0
    wire [13:0] v68; shift_adder #(5, 14, 0, 1, 14, -2, 0) op_68 (v66[4:0], v67[13:0], v68[13:0]); // 10.0
    wire [2:0] v69; assign v69[2:0] = model_inp[510:508]; // 9.0
    wire [10:0] v70; assign v70[10:0] = model_inp[521:511]; // 9.0
    wire [10:0] v71; shift_adder #(3, 11, 0, 1, 11, -1, 0) op_71 (v69[2:0], v70[10:0], v71[10:0]); // 10.0
    wire [14:0] v72; assign v72[14:0] = model_inp[536:522]; // 9.0
    wire [12:0] v73; assign v73[12:0] = model_inp[549:537]; // 9.0
    wire [14:0] v74; shift_adder #(15, 13, 1, 0, 15, 0, 1) op_74 (v72[14:0], v73[12:0], v74[14:0]); // 10.0
    wire [11:0] v75; assign v75[11:0] = model_inp[561:550]; // 9.0
    wire [5:0] v76; assign v76[5:0] = model_inp[567:562]; // 9.0
    wire [11:0] v77; shift_adder #(12, 6, 1, 0, 12, 3, 0) op_77 (v75[11:0], v76[5:0], v77[11:0]); // 10.0
    wire [12:0] v78; assign v78[12:0] = model_inp[580:568]; // 9.0
    wire [13:0] v79; assign v79[13:0] = model_inp[594:581]; // 9.0
    wire [13:0] v80; shift_adder #(13, 14, 1, 1, 14, 0, 0) op_80 (v78[12:0], v79[13:0], v80[13:0]); // 10.0
    wire [10:0] v81; assign v81[10:0] = model_inp[605:595]; // 9.0
    wire [12:0] v82; shift_adder #(11, 11, 1, 1, 13, 1, 0) op_82 (v81[10:0], v4[10:0], v82[12:0]); // 10.0
    wire [11:0] v83; assign v83[11:0] = model_inp[617:606]; // 9.0
    wire [8:0] v84; assign v84[8:0] = model_inp[626:618]; // 9.0
    wire [12:0] v85; shift_adder #(12, 9, 1, 1, 13, 2, 1) op_85 (v83[11:0], v84[8:0], v85[12:0]); // 10.0
    wire [10:0] v86; assign v86[10:0] = model_inp[637:627]; // 9.0
    wire [12:0] v87; assign v87[12:0] = model_inp[650:638]; // 9.0
    wire [13:0] v88; shift_adder #(11, 13, 1, 1, 14, -1, 0) op_88 (v86[10:0], v87[12:0], v88[13:0]); // 10.0
    wire [11:0] v89; assign v89[11:0] = model_inp[662:651]; // 9.0
    wire [12:0] v90; assign v90[12:0] = model_inp[675:663]; // 9.0
    wire [13:0] v91; shift_adder #(12, 13, 1, 1, 14, 0, 0) op_91 (v89[11:0], v90[12:0], v91[13:0]); // 10.0
    wire [9:0] v92; assign v92[9:0] = v91[9:0] & {10{~v91[13]}}; // 10.0
    wire [9:0] v93; shift_adder #(10, 4, 0, 0, 10, 0, 0) op_93 (v92[9:0], 4'b1000, v93[9:0]); // 10.0
    wire [3:0] v94; assign v94[3:0] = v93[7:4]; // 10.0
    wire [11:0] v95; assign v95[11:0] = model_inp[687:676]; // 9.0
    wire [9:0] v96; assign v96[9:0] = model_inp[697:688]; // 9.0
    wire [11:0] v97; shift_adder #(12, 10, 1, 1, 12, 0, 1) op_97 (v95[11:0], v96[9:0], v97[11:0]); // 10.0
    wire [12:0] v98; assign v98[12:0] = model_inp[710:698]; // 9.0
    wire [13:0] v99; assign v99[13:0] = model_inp[724:711]; // 9.0
    wire [14:0] v100; shift_adder #(13, 14, 1, 1, 15, -1, 0) op_100 (v98[12:0], v99[13:0], v100[14:0]); // 10.0
    wire [13:0] v101; assign v101[13:0] = model_inp[738:725]; // 9.0
    wire [15:0] v102; assign v102[15:0] = model_inp[754:739]; // 9.0
    wire [16:0] v103; shift_adder #(14, 16, 1, 1, 17, -3, 1) op_103 (v101[13:0], v102[15:0], v103[16:0]); // 10.0
    wire [16:0] v104; shift_adder #(17, 9, 1, 0, 17, 0, 1) op_104 (v103[16:0], 9'b100000000, v104[16:0]); // 10.0
    wire [14:0] v105; assign v105[14:0] = v104[14:0] & {15{~v104[16]}}; // 10.0
    wire [14:0] v106; shift_adder #(15, 8, 0, 0, 15, 0, 0) op_106 (v105[14:0], 8'b10000000, v106[14:0]); // 10.0
    wire [4:0] v107; assign v107[4:0] = v106[12:8]; // 10.0
    wire [13:0] v108; assign v108[13:0] = model_inp[768:755]; // 9.0
    wire [13:0] v109; shift_adder #(14, 11, 1, 1, 14, 1, 0) op_109 (v108[13:0], v53[10:0], v109[13:0]); // 10.0
    wire [10:0] v110; assign v110[10:0] = model_inp[779:769]; // 9.0
    wire [8:0] v111; assign v111[8:0] = model_inp[788:780]; // 9.0
    wire [11:0] v112; shift_adder #(11, 9, 1, 1, 12, 1, 1) op_112 (v110[10:0], v111[8:0], v112[11:0]); // 10.0
    wire [10:0] v113; assign v113[10:0] = v112[10:0] & {11{~v112[11]}}; // 10.0
    wire [10:0] v114; shift_adder #(11, 3, 0, 0, 11, 0, 0) op_114 (v113[10:0], 3'b100, v114[10:0]); // 10.0
    wire [5:0] v115; assign v115[5:0] = v114[8:3]; // 10.0
    wire [10:0] v116; assign v116[10:0] = model_inp[799:789]; // 9.0
    wire [12:0] v117; assign v117[12:0] = model_inp[812:800]; // 9.0
    wire [12:0] v118; shift_adder #(11, 13, 1, 1, 13, 0, 0) op_118 (v116[10:0], v117[12:0], v118[12:0]); // 10.0
    wire [10:0] v119; assign v119[10:0] = model_inp[823:813]; // 9.0
    wire [13:0] v120; assign v120[13:0] = model_inp[837:824]; // 9.0
    wire [14:0] v121; shift_adder #(11, 14, 1, 1, 15, -3, 0) op_121 (v119[10:0], v120[13:0], v121[14:0]); // 10.0
    wire [13:0] v122; assign v122[13:0] = v121[13:0] & {14{~v121[14]}}; // 10.0
    wire [13:0] v123; shift_adder #(14, 7, 0, 0, 14, 0, 0) op_123 (v122[13:0], 7'b1000000, v123[13:0]); // 10.0
    wire [3:0] v124; assign v124[3:0] = v123[10:7]; // 10.0
    wire [8:0] v125; assign v125[8:0] = model_inp[846:838]; // 9.0
    wire [13:0] v126; assign v126[13:0] = model_inp[860:847]; // 9.0
    wire [14:0] v127; shift_adder #(9, 14, 0, 1, 15, -4, 0) op_127 (v125[8:0], v126[13:0], v127[14:0]); // 10.0
    wire [10:0] v128; assign v128[10:0] = model_inp[871:861]; // 9.0
    wire [7:0] v129; assign v129[7:0] = model_inp[879:872]; // 9.0
    wire [11:0] v130; shift_adder #(11, 8, 1, 1, 12, 3, 1) op_130 (v128[10:0], v129[7:0], v130[11:0]); // 10.0
    wire [14:0] v131; assign v131[14:0] = model_inp[894:880]; // 9.0
    wire [9:0] v132; assign v132[9:0] = model_inp[904:895]; // 9.0
    wire [14:0] v133; shift_adder #(15, 10, 1, 1, 15, 3, 1) op_133 (v131[14:0], v132[9:0], v133[14:0]); // 10.0
    wire [11:0] v134; assign v134[11:0] = model_inp[916:905]; // 9.0
    wire [15:0] v135; assign v135[15:0] = model_inp[932:917]; // 9.0
    wire [16:0] v136; shift_adder #(12, 16, 1, 1, 17, -5, 0) op_136 (v134[11:0], v135[15:0], v136[16:0]); // 10.0
    wire [16:0] v137; shift_adder #(17, 10, 1, 0, 17, 0, 1) op_137 (v136[16:0], 10'b1000000000, v137[16:0]); // 10.0
    wire [15:0] v138; assign v138[15:0] = v137[15:0] & {16{~v137[16]}}; // 10.0
    wire [15:0] v139; shift_adder #(16, 7, 0, 0, 16, 0, 0) op_139 (v138[15:0], 7'b1000000, v139[15:0]); // 10.0
    wire [5:0] v140; assign v140[5:0] = v139[12:7]; // 10.0
    wire [13:0] v141; assign v141[13:0] = model_inp[946:933]; // 9.0
    wire [14:0] v142; assign v142[14:0] = model_inp[961:947]; // 9.0
    wire [14:0] v143; shift_adder #(14, 15, 1, 1, 15, 0, 0) op_143 (v141[13:0], v142[14:0], v143[14:0]); // 10.0
    wire [9:0] v144; assign v144[9:0] = model_inp[971:962]; // 9.0
    wire [8:0] v145; assign v145[8:0] = model_inp[980:972]; // 9.0
    wire [9:0] v146; shift_adder #(10, 9, 1, 1, 10, 0, 1) op_146 (v144[9:0], v145[8:0], v146[9:0]); // 10.0
    wire [13:0] v147; assign v147[13:0] = model_inp[994:981]; // 9.0
    wire [14:0] v148; shift_adder #(11, 14, 1, 1, 15, 1, 0) op_148 (v81[10:0], v147[13:0], v148[14:0]); // 10.0
    wire [13:0] v149; assign v149[13:0] = model_inp[1008:995]; // 9.0
    wire [14:0] v150; assign v150[14:0] = model_inp[1023:1009]; // 9.0
    wire [15:0] v151; shift_adder #(14, 15, 1, 1, 16, -1, 0) op_151 (v149[13:0], v150[14:0], v151[15:0]); // 10.0
    wire [11:0] v152; assign v152[11:0] = model_inp[1035:1024]; // 9.0
    wire [9:0] v153; assign v153[9:0] = model_inp[1045:1036]; // 9.0
    wire [12:0] v154; shift_adder #(12, 10, 1, 1, 13, -1, 0) op_154 (v152[11:0], v153[9:0], v154[12:0]); // 10.0
    wire [1:0] v155; assign v155[1:0] = model_inp[1047:1046]; // 9.0
    wire [13:0] v156; assign v156[13:0] = model_inp[1061:1048]; // 9.0
    wire [11:0] v157; assign v157[11:0] = model_inp[1073:1062]; // 9.0
    wire [15:0] v158; assign v158[15:0] = model_inp[1089:1074]; // 9.0
    wire [11:0] v159; assign v159[11:0] = model_inp[1101:1090]; // 9.0
    wire [14:0] v160; assign v160[14:0] = model_inp[1116:1102]; // 9.0
    wire [14:0] v161; assign v161[14:0] = model_inp[1131:1117]; // 9.0
    wire [11:0] v162; assign v162[11:0] = model_inp[1143:1132]; // 9.0
    wire [14:0] v163; assign v163[14:0] = model_inp[1158:1144]; // 9.0
    wire [18:0] v164; assign v164[18:0] = model_inp[1177:1159]; // 9.0
    wire [10:0] v165; assign v165[10:0] = model_inp[1188:1178]; // 9.0
    wire [12:0] v166; assign v166[12:0] = model_inp[1201:1189]; // 9.0
    wire [5:0] v167; assign v167[5:0] = model_inp[1207:1202]; // 9.0
    wire [12:0] v168; assign v168[12:0] = model_inp[1220:1208]; // 9.0
    wire [15:0] v169; assign v169[15:0] = model_inp[1236:1221]; // 9.0
    wire [12:0] v170; assign v170[12:0] = model_inp[1249:1237]; // 9.0
    wire [1:0] v171; assign v171[1:0] = model_inp[1251:1250]; // 9.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[1:0] = v155[1:0];
    assign model_out[13:2] = v2[11:0];
    assign model_out[27:14] = v156[13:0];
    assign model_out[39:28] = v5[11:0];
    assign model_out[43:40] = v12[3:0];
    assign model_out[58:44] = v15[14:0];
    assign model_out[70:59] = v18[11:0];
    assign model_out[85:71] = v21[14:0];
    assign model_out[100:86] = v24[14:0];
    assign model_out[112:101] = v157[11:0];
    assign model_out[122:113] = v30[9:0];
    assign model_out[138:123] = v158[15:0];
    assign model_out[152:139] = v33[13:0];
    assign model_out[164:153] = v159[11:0];
    assign model_out[177:165] = v36[12:0];
    assign model_out[192:178] = v160[14:0];
    assign model_out[204:193] = v39[11:0];
    assign model_out[218:205] = v42[13:0];
    assign model_out[233:219] = v161[14:0];
    assign model_out[246:234] = v45[12:0];
    assign model_out[263:247] = v48[16:0];
    assign model_out[276:264] = v51[12:0];
    assign model_out[290:277] = v54[13:0];
    assign model_out[305:291] = v59[14:0];
    assign model_out[317:306] = v95[11:0];
    assign model_out[331:318] = v62[13:0];
    assign model_out[349:332] = v65[17:0];
    assign model_out[360:350] = v71[10:0];
    assign model_out[372:361] = v162[11:0];
    assign model_out[387:373] = v74[14:0];
    assign model_out[399:388] = v77[11:0];
    assign model_out[414:400] = v163[14:0];
    assign model_out[427:415] = v82[12:0];
    assign model_out[446:428] = v164[18:0];
    assign model_out[459:447] = v85[12:0];
    assign model_out[469:460] = v23[9:0];
    assign model_out[483:470] = v88[13:0];
    assign model_out[495:484] = v97[11:0];
    assign model_out[510:496] = v100[14:0];
    assign model_out[521:511] = v165[10:0];
    assign model_out[535:522] = v109[13:0];
    assign model_out[548:536] = v166[12:0];
    assign model_out[561:549] = v118[12:0];
    assign model_out[567:562] = v167[5:0];
    assign model_out[571:568] = v124[3:0];
    assign model_out[584:572] = v168[12:0];
    assign model_out[599:585] = v127[14:0];
    assign model_out[611:600] = v130[11:0];
    assign model_out[626:612] = v133[14:0];
    assign model_out[632:627] = v140[5:0];
    assign model_out[637:633] = v107[4:0];
    assign model_out[641:638] = v94[3:0];
    assign model_out[651:642] = v146[9:0];
    assign model_out[665:652] = v68[13:0];
    assign model_out[681:666] = v169[15:0];
    assign model_out[697:682] = v151[15:0];
    assign model_out[710:698] = v170[12:0];
    assign model_out[723:711] = v154[12:0];
    assign model_out[725:724] = v171[1:0];
    assign model_out[731:726] = v115[5:0];
    assign model_out[739:732] = v27[7:0];
    assign model_out[754:740] = v56[14:0];
    assign model_out[768:755] = v80[13:0];
    assign model_out[783:769] = v143[14:0];
    assign model_out[798:784] = v148[14:0];

endmodule
