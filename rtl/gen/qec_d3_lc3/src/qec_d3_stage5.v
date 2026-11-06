`timescale 1 ns / 1 ps

module qec_d3_stage5 (
    input [462:0] model_inp,
    output [337:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [1:0] v0; assign v0[1:0] = model_inp[1:0]; // 15.0
    wire [9:0] v1; assign v1[9:0] = model_inp[11:2]; // 15.0
    wire [9:0] v2; shift_adder #(2, 10, 0, 1, 10, -2, 0) op_2 (v0[1:0], v1[9:0], v2[9:0]); // 16.0
    wire [11:0] v3; assign v3[11:0] = model_inp[23:12]; // 15.0
    wire [11:0] v4; assign v4[11:0] = model_inp[35:24]; // 15.0
    wire [12:0] v5; shift_adder #(12, 12, 1, 1, 13, 0, 0) op_5 (v3[11:0], v4[11:0], v5[12:0]); // 16.0
    wire [12:0] v6; shift_adder #(13, 3, 1, 0, 13, 0, 0) op_6 (v5[12:0], 3'b101, v6[12:0]); // 16.0
    wire [11:0] v7; assign v7[11:0] = v6[11:0] & {12{~v6[12]}}; // 16.0
    wire [11:0] v8; shift_adder #(12, 3, 0, 0, 12, 0, 0) op_8 (v7[11:0], 3'b100, v8[11:0]); // 16.0
    wire [6:0] v9; assign v9[6:0] = v8[9:3]; // 16.0
    wire [8:0] v10; assign v10[8:0] = model_inp[44:36]; // 15.0
    wire [11:0] v11; shift_adder #(9, 12, 1, 1, 12, -1, 0) op_11 (v10[8:0], v3[11:0], v11[11:0]); // 16.0
    wire [4:0] v12; assign v12[4:0] = model_inp[49:45]; // 15.0
    wire [3:0] v13; assign v13[3:0] = model_inp[53:50]; // 15.0
    wire [5:0] v14; shift_adder #(5, 4, 0, 0, 6, 0, 0) op_14 (v12[4:0], v13[3:0], v14[5:0]); // 16.0
    wire [12:0] v15; assign v15[12:0] = model_inp[66:54]; // 15.0
    wire [11:0] v16; assign v16[11:0] = model_inp[78:67]; // 15.0
    wire [13:0] v17; shift_adder #(13, 12, 1, 1, 14, 1, 0) op_17 (v15[12:0], v16[11:0], v17[13:0]); // 16.0
    wire [13:0] v18; shift_adder #(14, 5, 1, 0, 14, 0, 0) op_18 (v17[13:0], 5'b11110, v18[13:0]); // 16.0
    wire [12:0] v19; assign v19[12:0] = v18[12:0] & {13{~v18[13]}}; // 16.0
    wire [12:0] v20; shift_adder #(13, 4, 0, 0, 13, 0, 0) op_20 (v19[12:0], 4'b1000, v20[12:0]); // 16.0
    wire [5:0] v21; assign v21[5:0] = v20[9:4]; // 16.0
    wire [6:0] v22; assign v22[6:0] = model_inp[85:79]; // 15.0
    wire [5:0] v23; assign v23[5:0] = model_inp[91:86]; // 15.0
    wire [7:0] v24; shift_adder #(7, 6, 1, 0, 8, 0, 1) op_24 (v22[6:0], v23[5:0], v24[7:0]); // 16.0
    wire [7:0] v25; assign v25[7:0] = model_inp[99:92]; // 15.0
    wire [4:0] v26; assign v26[4:0] = model_inp[104:100]; // 15.0
    wire [8:0] v27; shift_adder #(8, 5, 1, 0, 9, -1, 0) op_27 (v25[7:0], v26[4:0], v27[8:0]); // 16.0
    wire [12:0] v28; assign v28[12:0] = model_inp[117:105]; // 15.0
    wire [12:0] v29; assign v29[12:0] = model_inp[130:118]; // 15.0
    wire [13:0] v30; shift_adder #(13, 13, 1, 1, 14, -1, 1) op_30 (v28[12:0], v29[12:0], v30[13:0]); // 16.0
    wire [13:0] v31; shift_adder #(14, 6, 1, 0, 14, 0, 1) op_31 (v30[13:0], 6'b100000, v31[13:0]); // 16.0
    wire [12:0] v32; assign v32[12:0] = v31[12:0] & {13{~v31[13]}}; // 16.0
    wire [12:0] v33; shift_adder #(13, 4, 0, 0, 13, 0, 0) op_33 (v32[12:0], 4'b1000, v33[12:0]); // 16.0
    wire [6:0] v34; assign v34[6:0] = v33[10:4]; // 16.0
    wire [7:0] v35; assign v35[7:0] = model_inp[138:131]; // 15.0
    wire [2:0] v36; assign v36[2:0] = model_inp[141:139]; // 15.0
    wire [8:0] v37; shift_adder #(8, 3, 0, 0, 9, 3, 1) op_37 (v35[7:0], v36[2:0], v37[8:0]); // 16.0
    wire [6:0] v38; assign v38[6:0] = model_inp[148:142]; // 15.0
    wire [8:0] v39; shift_adder #(5, 7, 0, 1, 9, -2, 0) op_39 (v26[4:0], v38[6:0], v39[8:0]); // 16.0
    wire [3:0] v40; assign v40[3:0] = model_inp[152:149]; // 15.0
    wire [6:0] v41; assign v41[6:0] = model_inp[159:153]; // 15.0
    wire [7:0] v42; shift_adder #(4, 7, 0, 1, 8, 0, 1) op_42 (v40[3:0], v41[6:0], v42[7:0]); // 16.0
    wire [3:0] v43; assign v43[3:0] = model_inp[163:160]; // 15.0
    wire [5:0] v44; shift_adder #(4, 5, 0, 0, 6, -1, 1) op_44 (v43[3:0], v26[4:0], v44[5:0]); // 16.0
    wire [10:0] v45; assign v45[10:0] = model_inp[174:164]; // 15.0
    wire [11:0] v46; assign v46[11:0] = model_inp[186:175]; // 15.0
    wire [12:0] v47; shift_adder #(11, 12, 1, 1, 13, 1, 0) op_47 (v45[10:0], v46[11:0], v47[12:0]); // 16.0
    wire [12:0] v48; shift_adder #(13, 3, 1, 0, 13, 0, 0) op_48 (v47[12:0], 3'b100, v48[12:0]); // 16.0
    wire [10:0] v49; assign v49[10:0] = v48[10:0] & {11{~v48[12]}}; // 16.0
    wire [10:0] v50; shift_adder #(11, 3, 0, 0, 11, 0, 0) op_50 (v49[10:0], 3'b100, v50[10:0]); // 16.0
    wire [4:0] v51; assign v51[4:0] = v50[7:3]; // 16.0
    wire [4:0] v52; assign v52[4:0] = model_inp[191:187]; // 15.0
    wire [6:0] v53; assign v53[6:0] = model_inp[198:192]; // 15.0
    wire [7:0] v54; shift_adder #(5, 7, 0, 1, 8, -1, 0) op_54 (v52[4:0], v53[6:0], v54[7:0]); // 16.0
    wire [8:0] v55; assign v55[8:0] = model_inp[207:199]; // 15.0
    wire [4:0] v56; assign v56[4:0] = model_inp[212:208]; // 15.0
    wire [8:0] v57; shift_adder #(9, 5, 1, 0, 9, 2, 0) op_57 (v55[8:0], v56[4:0], v57[8:0]); // 16.0
    wire [2:0] v58; assign v58[2:0] = model_inp[215:213]; // 15.0
    wire [4:0] v59; assign v59[4:0] = model_inp[220:216]; // 15.0
    wire [5:0] v60; shift_adder #(3, 5, 0, 0, 6, -2, 1) op_60 (v58[2:0], v59[4:0], v60[5:0]); // 16.0
    wire [11:0] v61; assign v61[11:0] = model_inp[232:221]; // 15.0
    wire [12:0] v62; assign v62[12:0] = model_inp[245:233]; // 15.0
    wire [12:0] v63; shift_adder #(12, 13, 1, 1, 13, 0, 0) op_63 (v61[11:0], v62[12:0], v63[12:0]); // 16.0
    wire [6:0] v64; assign v64[6:0] = model_inp[252:246]; // 15.0
    wire [5:0] v65; assign v65[5:0] = model_inp[258:253]; // 15.0
    wire [8:0] v66; shift_adder #(7, 6, 1, 1, 9, 2, 0) op_66 (v64[6:0], v65[5:0], v66[8:0]); // 16.0
    wire [4:0] v67; assign v67[4:0] = model_inp[263:259]; // 15.0
    wire [5:0] v68; assign v68[5:0] = model_inp[269:264]; // 15.0
    wire [7:0] v69; shift_adder #(5, 6, 0, 1, 8, -2, 0) op_69 (v67[4:0], v68[5:0], v69[7:0]); // 16.0
    wire [5:0] v70; assign v70[5:0] = model_inp[275:270]; // 15.0
    wire [7:0] v71; shift_adder #(6, 5, 0, 0, 8, 2, 1) op_71 (v70[5:0], v26[4:0], v71[7:0]); // 16.0
    wire [4:0] v72; assign v72[4:0] = model_inp[280:276]; // 15.0
    wire [6:0] v73; shift_adder #(5, 5, 0, 0, 7, -1, 0) op_73 (v72[4:0], v26[4:0], v73[6:0]); // 16.0
    wire [5:0] v74; assign v74[5:0] = model_inp[286:281]; // 15.0
    wire [6:0] v75; shift_adder #(6, 5, 0, 0, 7, 1, 1) op_75 (v74[5:0], v56[4:0], v75[6:0]); // 16.0
    wire [6:0] v76; assign v76[6:0] = model_inp[293:287]; // 15.0
    wire [5:0] v77; assign v77[5:0] = model_inp[299:294]; // 15.0
    wire [8:0] v78; shift_adder #(7, 6, 1, 0, 9, 1, 1) op_78 (v76[6:0], v77[5:0], v78[8:0]); // 16.0
    wire [8:0] v79; assign v79[8:0] = model_inp[308:300]; // 15.0
    wire [11:0] v80; shift_adder #(6, 9, 1, 0, 12, -5, 0) op_80 (v68[5:0], v79[8:0], v80[11:0]); // 16.0
    wire [6:0] v81; assign v81[6:0] = model_inp[315:309]; // 15.0
    wire [7:0] v82; assign v82[7:0] = model_inp[323:316]; // 15.0
    wire [9:0] v83; shift_adder #(7, 8, 0, 0, 10, -2, 1) op_83 (v81[6:0], v82[7:0], v83[9:0]); // 16.0
    wire [7:0] v84; assign v84[7:0] = model_inp[331:324]; // 15.0
    wire [8:0] v85; shift_adder #(6, 8, 1, 1, 9, -1, 0) op_85 (v65[5:0], v84[7:0], v85[8:0]); // 16.0
    wire [6:0] v86; shift_adder #(6, 4, 0, 0, 7, 2, 0) op_86 (v70[5:0], v13[3:0], v86[6:0]); // 16.0
    wire [4:0] v87; assign v87[4:0] = model_inp[336:332]; // 15.0
    wire [7:0] v88; shift_adder #(5, 5, 0, 0, 8, 2, 1) op_88 (v52[4:0], v87[4:0], v88[7:0]); // 16.0
    wire [8:0] v89; assign v89[8:0] = model_inp[345:337]; // 15.0
    wire [5:0] v90; assign v90[5:0] = model_inp[351:346]; // 15.0
    wire [8:0] v91; shift_adder #(9, 6, 1, 0, 9, 0, 1) op_91 (v89[8:0], v90[5:0], v91[8:0]); // 16.0
    wire [4:0] v92; assign v92[4:0] = model_inp[356:352]; // 15.0
    wire [7:0] v93; shift_adder #(5, 5, 0, 1, 8, 2, 0) op_93 (v59[4:0], v92[4:0], v93[7:0]); // 16.0
    wire [1:0] v94; assign v94[1:0] = model_inp[358:357]; // 15.0
    wire [9:0] v95; shift_adder #(2, 10, 0, 1, 10, -2, 1) op_95 (v94[1:0], v2[9:0], v95[9:0]); // 17.0
    wire [13:0] v96; assign v96[13:0] = model_inp[372:359]; // 15.0
    wire [13:0] v97; shift_adder #(14, 12, 1, 1, 14, 1, 0) op_97 (v96[13:0], v11[11:0], v97[13:0]); // 17.0
    wire [13:0] v98; shift_adder #(14, 4, 1, 0, 14, 0, 0) op_98 (v97[13:0], 4'b1100, v98[13:0]); // 17.0
    wire [12:0] v99; assign v99[12:0] = v98[12:0] & {13{~v98[13]}}; // 17.0
    wire [12:0] v100; shift_adder #(13, 4, 0, 0, 13, 0, 0) op_100 (v99[12:0], 4'b1000, v100[12:0]); // 17.0
    wire [7:0] v101; assign v101[7:0] = v100[11:4]; // 17.0
    wire [1:0] v102; assign v102[1:0] = model_inp[374:373]; // 15.0
    wire [6:0] v103; shift_adder #(2, 6, 0, 0, 7, -1, 1) op_103 (v102[1:0], v14[5:0], v103[6:0]); // 17.0
    wire [1:0] v104; assign v104[1:0] = model_inp[376:375]; // 15.0
    wire [6:0] v105; shift_adder #(6, 2, 0, 0, 7, 4, 0) op_105 (v21[5:0], v104[1:0], v105[6:0]); // 17.0
    wire [9:0] v106; shift_adder #(8, 9, 1, 1, 10, 0, 0) op_106 (v24[7:0], v27[8:0], v106[9:0]); // 17.0
    wire [11:0] v107; shift_adder #(7, 9, 0, 1, 12, -3, 0) op_107 (v34[6:0], v37[8:0], v107[11:0]); // 17.0
    wire [4:0] v108; assign v108[4:0] = model_inp[381:377]; // 15.0
    wire [7:0] v109; shift_adder #(5, 6, 0, 0, 8, -2, 1) op_109 (v108[4:0], v21[5:0], v109[7:0]); // 17.0
    wire [7:0] v110; shift_adder #(4, 8, 0, 1, 8, 0, 0) op_110 (v43[3:0], v42[7:0], v110[7:0]); // 17.0
    wire [8:0] v111; shift_adder #(4, 6, 0, 1, 9, 2, 1) op_111 (v13[3:0], v44[5:0], v111[8:0]); // 17.0
    wire [6:0] v112; shift_adder #(6, 5, 0, 0, 7, 0, 0) op_112 (v21[5:0], v51[4:0], v112[6:0]); // 17.0
    wire [8:0] v113; shift_adder #(8, 8, 1, 1, 9, 1, 0) op_113 (v54[7:0], v42[7:0], v113[8:0]); // 17.0
    wire [7:0] v114; shift_adder #(6, 7, 1, 1, 8, 0, 1) op_114 (v60[5:0], v76[6:0], v114[7:0]); // 17.0
    wire [12:0] v115; shift_adder #(13, 9, 1, 1, 13, 1, 1) op_115 (v63[12:0], v10[8:0], v115[12:0]); // 17.0
    wire [13:0] v116; shift_adder #(13, 4, 1, 0, 14, -1, 0) op_116 (v115[12:0], 4'b1101, v116[13:0]); // 17.0
    wire [12:0] v117; assign v117[12:0] = v116[12:0] & {13{~v116[13]}}; // 17.0
    wire [12:0] v118; shift_adder #(13, 4, 0, 0, 13, 0, 0) op_118 (v117[12:0], 4'b1000, v118[12:0]); // 17.0
    wire [5:0] v119; assign v119[5:0] = v118[9:4]; // 17.0
    wire [8:0] v120; shift_adder #(8, 7, 0, 0, 9, 0, 0) op_120 (v35[7:0], v34[6:0], v120[8:0]); // 17.0
    wire [9:0] v121; shift_adder #(9, 8, 1, 1, 10, 1, 0) op_121 (v66[8:0], v69[7:0], v121[9:0]); // 17.0
    wire [8:0] v122; shift_adder #(8, 5, 1, 0, 9, 2, 1) op_122 (v71[7:0], v51[4:0], v122[8:0]); // 17.0
    wire [8:0] v123; shift_adder #(7, 7, 0, 0, 9, 1, 0) op_123 (v73[6:0], v34[6:0], v123[8:0]); // 17.0
    wire [7:0] v124; shift_adder #(5, 7, 0, 1, 8, 0, 1) op_124 (v52[4:0], v75[6:0], v124[7:0]); // 17.0
    wire [5:0] v125; assign v125[5:0] = model_inp[387:382]; // 15.0
    wire [10:0] v126; shift_adder #(9, 6, 1, 0, 11, 3, 1) op_126 (v78[8:0], v125[5:0], v126[10:0]); // 17.0
    wire [10:0] v127; shift_adder #(10, 9, 1, 1, 11, 1, 0) op_127 (v83[9:0], v37[8:0], v127[10:0]); // 17.0
    wire [3:0] v128; assign v128[3:0] = model_inp[391:388]; // 15.0
    wire [7:0] v129; shift_adder #(4, 7, 0, 0, 8, -2, 0) op_129 (v128[3:0], v73[6:0], v129[7:0]); // 17.0
    wire [8:0] v130; shift_adder #(6, 9, 1, 1, 9, -1, 0) op_130 (v60[5:0], v85[8:0], v130[8:0]); // 17.0
    wire [9:0] v131; shift_adder #(8, 5, 1, 0, 10, 3, 1) op_131 (v88[7:0], v52[4:0], v131[9:0]); // 17.0
    wire [8:0] v132; shift_adder #(7, 6, 0, 1, 9, 2, 0) op_132 (v9[6:0], v44[5:0], v132[8:0]); // 17.0
    wire [8:0] v133; shift_adder #(5, 8, 0, 1, 9, -2, 0) op_133 (v51[4:0], v93[7:0], v133[8:0]); // 17.0
    wire [14:0] v134; assign v134[14:0] = model_inp[406:392]; // 15.0
    wire [15:0] v135; shift_adder #(15, 10, 1, 1, 16, 2, 0) op_135 (v134[14:0], v95[9:0], v135[15:0]); // 18.0
    wire [13:0] v136; assign v136[13:0] = v135[13:0] & {14{~v135[15]}}; // 18.0
    wire [13:0] v137; shift_adder #(14, 5, 0, 0, 14, 0, 0) op_137 (v136[13:0], 5'b10000, v137[13:0]); // 18.0
    wire [6:0] v138; assign v138[6:0] = v137[11:5]; // 18.0
    wire [13:0] v139; assign v139[13:0] = model_inp[420:407]; // 15.0
    wire [13:0] v140; shift_adder #(14, 10, 1, 1, 14, 1, 0) op_140 (v139[13:0], v95[9:0], v140[13:0]); // 18.0
    wire [13:0] v141; shift_adder #(14, 6, 1, 0, 14, 0, 1) op_141 (v140[13:0], 6'b100000, v141[13:0]); // 18.0
    wire [12:0] v142; assign v142[12:0] = v141[12:0] & {13{~v141[13]}}; // 18.0
    wire [12:0] v143; shift_adder #(13, 4, 0, 0, 13, 0, 0) op_143 (v142[12:0], 4'b1000, v143[12:0]); // 18.0
    wire [6:0] v144; assign v144[6:0] = v143[10:4]; // 18.0
    wire [1:0] v145; assign v145[1:0] = model_inp[422:421]; // 15.0
    wire [6:0] v146; shift_adder #(2, 7, 0, 1, 7, -2, 1) op_146 (v145[1:0], v103[6:0], v146[6:0]); // 18.0
    wire [12:0] v147; shift_adder #(10, 12, 1, 1, 13, -3, 1) op_147 (v106[9:0], v107[11:0], v147[12:0]); // 18.0
    wire [10:0] v148; shift_adder #(7, 9, 0, 1, 11, 2, 0) op_148 (v105[6:0], v39[8:0], v148[10:0]); // 18.0
    wire [7:0] v149; shift_adder #(2, 8, 0, 1, 8, -4, 1) op_149 (v104[1:0], v109[7:0], v149[7:0]); // 18.0
    wire [2:0] v150; assign v150[2:0] = model_inp[425:423]; // 15.0
    wire [8:0] v151; shift_adder #(3, 8, 0, 1, 9, 1, 1) op_151 (v150[2:0], v110[7:0], v151[8:0]); // 18.0
    wire [0:0] v152; assign v152[0:0] = model_inp[426:426]; // 15.0
    wire [8:0] v153; shift_adder #(1, 9, 0, 1, 9, -4, 0) op_153 (v152[0:0], v111[8:0], v153[8:0]); // 18.0
    wire [10:0] v154; shift_adder #(7, 9, 0, 1, 11, 1, 0) op_154 (v112[6:0], v113[8:0], v154[10:0]); // 18.0
    wire [9:0] v155; shift_adder #(9, 8, 1, 1, 10, 0, 0) op_155 (v57[8:0], v114[7:0], v155[9:0]); // 18.0
    wire [4:0] v156; assign v156[4:0] = model_inp[431:427]; // 15.0
    wire [6:0] v157; shift_adder #(5, 6, 0, 0, 7, 0, 0) op_157 (v156[4:0], v119[5:0], v157[6:0]); // 18.0
    wire [14:0] v158; shift_adder #(9, 8, 0, 0, 15, -6, 0) op_158 (v120[8:0], v101[7:0], v158[14:0]); // 18.0
    wire [4:0] v159; assign v159[4:0] = model_inp[436:432]; // 15.0
    wire [7:0] v160; shift_adder #(5, 6, 0, 0, 8, -2, 1) op_160 (v159[4:0], v119[5:0], v160[7:0]); // 18.0
    wire [10:0] v161; shift_adder #(10, 7, 1, 0, 11, 1, 0) op_161 (v121[9:0], v112[6:0], v161[10:0]); // 18.0
    wire [10:0] v162; shift_adder #(9, 9, 1, 0, 11, 0, 1) op_162 (v122[8:0], v123[8:0], v162[10:0]); // 18.0
    wire [7:0] v163; shift_adder #(4, 8, 0, 1, 8, -1, 0) op_163 (v13[3:0], v124[7:0], v163[7:0]); // 18.0
    wire [13:0] v164; shift_adder #(11, 12, 1, 1, 14, -2, 1) op_164 (v126[10:0], v80[11:0], v164[13:0]); // 18.0
    wire [10:0] v165; shift_adder #(11, 8, 1, 0, 11, 0, 1) op_165 (v127[10:0], v129[7:0], v165[10:0]); // 18.0
    wire [10:0] v166; shift_adder #(9, 7, 1, 0, 11, 3, 1) op_166 (v130[8:0], v86[6:0], v166[10:0]); // 18.0
    wire [8:0] v167; shift_adder #(8, 7, 0, 0, 9, 0, 0) op_167 (v101[7:0], v9[6:0], v167[8:0]); // 18.0
    wire [8:0] v168; shift_adder #(6, 7, 0, 0, 9, 1, 1) op_168 (v74[5:0], v112[6:0], v168[8:0]); // 18.0
    wire [9:0] v169; shift_adder #(10, 6, 1, 0, 10, 1, 1) op_169 (v131[9:0], v119[5:0], v169[9:0]); // 18.0
    wire [9:0] v170; shift_adder #(9, 8, 1, 0, 10, 0, 0) op_170 (v132[8:0], v129[7:0], v170[9:0]); // 18.0
    wire [10:0] v171; shift_adder #(9, 9, 1, 1, 11, -2, 0) op_171 (v91[8:0], v133[8:0], v171[10:0]); // 18.0
    wire [4:0] v172; assign v172[4:0] = model_inp[441:437]; // 15.0
    wire [3:0] v173; assign v173[3:0] = model_inp[445:442]; // 15.0
    wire [4:0] v174; assign v174[4:0] = model_inp[450:446]; // 15.0
    wire [3:0] v175; assign v175[3:0] = model_inp[454:451]; // 15.0
    wire [3:0] v176; assign v176[3:0] = model_inp[458:455]; // 15.0
    wire [1:0] v177; assign v177[1:0] = model_inp[460:459]; // 15.0
    wire [1:0] v178; assign v178[1:0] = model_inp[462:461]; // 15.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[6:0] = v138[6:0];
    assign model_out[11:7] = v52[4:0];
    assign model_out[18:12] = v144[6:0];
    assign model_out[25:19] = v9[6:0];
    assign model_out[33:26] = v101[7:0];
    assign model_out[40:34] = v146[6:0];
    assign model_out[47:41] = v105[6:0];
    assign model_out[60:48] = v147[12:0];
    assign model_out[71:61] = v148[10:0];
    assign model_out[79:72] = v149[7:0];
    assign model_out[88:80] = v151[8:0];
    assign model_out[97:89] = v153[8:0];
    assign model_out[108:98] = v154[10:0];
    assign model_out[118:109] = v155[9:0];
    assign model_out[125:119] = v157[6:0];
    assign model_out[130:126] = v92[4:0];
    assign model_out[145:131] = v158[14:0];
    assign model_out[153:146] = v160[7:0];
    assign model_out[164:154] = v161[10:0];
    assign model_out[175:165] = v162[10:0];
    assign model_out[180:176] = v172[4:0];
    assign model_out[184:181] = v173[3:0];
    assign model_out[192:185] = v163[7:0];
    assign model_out[206:193] = v164[13:0];
    assign model_out[217:207] = v165[10:0];
    assign model_out[228:218] = v166[10:0];
    assign model_out[234:229] = v119[5:0];
    assign model_out[243:235] = v167[8:0];
    assign model_out[248:244] = v174[4:0];
    assign model_out[257:249] = v168[8:0];
    assign model_out[267:258] = v169[9:0];
    assign model_out[276:268] = v120[8:0];
    assign model_out[287:277] = v171[10:0];
    assign model_out[292:288] = v72[4:0];
    assign model_out[297:293] = v59[4:0];
    assign model_out[303:298] = v21[5:0];
    assign model_out[305:304] = v102[1:0];
    assign model_out[310:306] = v12[4:0];
    assign model_out[320:311] = v170[9:0];
    assign model_out[323:321] = v150[2:0];
    assign model_out[327:324] = v175[3:0];
    assign model_out[331:328] = v176[3:0];
    assign model_out[333:332] = v177[1:0];
    assign model_out[335:334] = v178[1:0];
    assign model_out[337:336] = v145[1:0];

endmodule
