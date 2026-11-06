`timescale 1 ns / 1 ps

module jsc_stage1 (
    input [1442:0] model_inp,
    output [2376:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [8:0] v0; assign v0[8:0] = model_inp[8:0]; // 1.0
    wire [13:0] v1; assign v1[13:0] = model_inp[22:9]; // 1.0
    wire [13:0] v2; shift_adder #(9, 14, 1, 1, 14, -3, 0) op_2 (v0[8:0], v1[13:0], v2[13:0]); // 2.0
    wire [11:0] v3; assign v3[11:0] = model_inp[34:23]; // 1.0
    wire [11:0] v4; assign v4[11:0] = model_inp[46:35]; // 1.0
    wire [12:0] v5; shift_adder #(12, 12, 1, 1, 13, 0, 0) op_5 (v3[11:0], v4[11:0], v5[12:0]); // 2.0
    wire [10:0] v6; assign v6[10:0] = model_inp[57:47]; // 1.0
    wire [12:0] v7; shift_adder #(11, 12, 1, 1, 13, -1, 0) op_7 (v6[10:0], v4[11:0], v7[12:0]); // 2.0
    wire [3:0] v8; assign v8[3:0] = model_inp[61:58]; // 1.0
    wire [9:0] v9; assign v9[9:0] = model_inp[71:62]; // 1.0
    wire [9:0] v10; shift_adder #(4, 10, 1, 1, 10, -3, 1) op_10 (v8[3:0], v9[9:0], v10[9:0]); // 2.0
    wire [9:0] v11; assign v11[9:0] = model_inp[81:72]; // 1.0
    wire [12:0] v12; shift_adder #(10, 12, 1, 1, 13, -2, 1) op_12 (v11[9:0], v4[11:0], v12[12:0]); // 2.0
    wire [12:0] v13; assign v13[12:0] = model_inp[94:82]; // 1.0
    wire [11:0] v14; assign v14[11:0] = model_inp[106:95]; // 1.0
    wire [15:0] v15; shift_adder #(13, 12, 1, 1, 16, -2, 0) op_15 (v13[12:0], v14[11:0], v15[15:0]); // 2.0
    wire [9:0] v16; assign v16[9:0] = model_inp[116:107]; // 1.0
    wire [8:0] v17; assign v17[8:0] = model_inp[125:117]; // 1.0
    wire [11:0] v18; shift_adder #(10, 9, 1, 1, 12, 2, 0) op_18 (v16[9:0], v17[8:0], v18[11:0]); // 2.0
    wire [7:0] v19; assign v19[7:0] = model_inp[133:126]; // 1.0
    wire [13:0] v20; assign v20[13:0] = model_inp[147:134]; // 1.0
    wire [13:0] v21; shift_adder #(8, 14, 1, 1, 14, -2, 1) op_21 (v19[7:0], v20[13:0], v21[13:0]); // 2.0
    wire [8:0] v22; assign v22[8:0] = model_inp[156:148]; // 1.0
    wire [10:0] v23; assign v23[10:0] = model_inp[167:157]; // 1.0
    wire [11:0] v24; shift_adder #(9, 11, 1, 1, 12, 0, 1) op_24 (v22[8:0], v23[10:0], v24[11:0]); // 2.0
    wire [5:0] v25; assign v25[5:0] = model_inp[173:168]; // 1.0
    wire [10:0] v26; assign v26[10:0] = model_inp[184:174]; // 1.0
    wire [10:0] v27; shift_adder #(6, 11, 1, 1, 11, -1, 1) op_27 (v25[5:0], v26[10:0], v27[10:0]); // 2.0
    wire [10:0] v28; assign v28[10:0] = model_inp[195:185]; // 1.0
    wire [11:0] v29; assign v29[11:0] = model_inp[207:196]; // 1.0
    wire [12:0] v30; shift_adder #(11, 12, 1, 1, 13, -1, 0) op_30 (v28[10:0], v29[11:0], v30[12:0]); // 2.0
    wire [8:0] v31; assign v31[8:0] = model_inp[216:208]; // 1.0
    wire [11:0] v32; assign v32[11:0] = model_inp[228:217]; // 1.0
    wire [11:0] v33; shift_adder #(9, 12, 1, 1, 12, 0, 1) op_33 (v31[8:0], v32[11:0], v33[11:0]); // 2.0
    wire [7:0] v34; assign v34[7:0] = model_inp[236:229]; // 1.0
    wire [9:0] v35; shift_adder #(8, 9, 1, 1, 10, -1, 0) op_35 (v34[7:0], v31[8:0], v35[9:0]); // 2.0
    wire [11:0] v36; assign v36[11:0] = model_inp[248:237]; // 1.0
    wire [16:0] v37; assign v37[16:0] = model_inp[265:249]; // 1.0
    wire [16:0] v38; shift_adder #(12, 17, 1, 1, 17, -1, 0) op_38 (v36[11:0], v37[16:0], v38[16:0]); // 2.0
    wire [8:0] v39; assign v39[8:0] = model_inp[274:266]; // 1.0
    wire [6:0] v40; assign v40[6:0] = model_inp[281:275]; // 1.0
    wire [8:0] v41; shift_adder #(9, 7, 1, 1, 9, 0, 1) op_41 (v39[8:0], v40[6:0], v41[8:0]); // 2.0
    wire [7:0] v42; assign v42[7:0] = model_inp[289:282]; // 1.0
    wire [8:0] v43; assign v43[8:0] = model_inp[298:290]; // 1.0
    wire [10:0] v44; shift_adder #(8, 9, 1, 1, 11, 2, 0) op_44 (v42[7:0], v43[8:0], v44[10:0]); // 2.0
    wire [11:0] v45; assign v45[11:0] = model_inp[310:299]; // 1.0
    wire [15:0] v46; assign v46[15:0] = model_inp[326:311]; // 1.0
    wire [15:0] v47; shift_adder #(12, 16, 1, 1, 16, -3, 1) op_47 (v45[11:0], v46[15:0], v47[15:0]); // 2.0
    wire [9:0] v48; assign v48[9:0] = model_inp[336:327]; // 1.0
    wire [10:0] v49; shift_adder #(10, 6, 1, 1, 11, 4, 1) op_49 (v48[9:0], v25[5:0], v49[10:0]); // 2.0
    wire [11:0] v50; assign v50[11:0] = model_inp[348:337]; // 1.0
    wire [15:0] v51; shift_adder #(14, 12, 1, 1, 16, 3, 0) op_51 (v1[13:0], v50[11:0], v51[15:0]); // 2.0
    wire [11:0] v52; assign v52[11:0] = model_inp[360:349]; // 1.0
    wire [13:0] v53; assign v53[13:0] = model_inp[374:361]; // 1.0
    wire [14:0] v54; shift_adder #(12, 14, 1, 1, 15, -3, 0) op_54 (v52[11:0], v53[13:0], v54[14:0]); // 2.0
    wire [11:0] v55; assign v55[11:0] = model_inp[386:375]; // 1.0
    wire [6:0] v56; assign v56[6:0] = model_inp[393:387]; // 1.0
    wire [11:0] v57; shift_adder #(12, 7, 1, 1, 12, 2, 1) op_57 (v55[11:0], v56[6:0], v57[11:0]); // 2.0
    wire [10:0] v58; assign v58[10:0] = model_inp[404:394]; // 1.0
    wire [9:0] v59; assign v59[9:0] = model_inp[414:405]; // 1.0
    wire [11:0] v60; shift_adder #(11, 10, 1, 1, 12, 1, 1) op_60 (v58[10:0], v59[9:0], v60[11:0]); // 2.0
    wire [11:0] v61; assign v61[11:0] = model_inp[426:415]; // 1.0
    wire [11:0] v62; shift_adder #(7, 12, 1, 1, 12, 0, 0) op_62 (v40[6:0], v61[11:0], v62[11:0]); // 2.0
    wire [9:0] v63; assign v63[9:0] = model_inp[436:427]; // 1.0
    wire [15:0] v64; shift_adder #(12, 10, 1, 1, 16, 5, 0) op_64 (v45[11:0], v63[9:0], v64[15:0]); // 2.0
    wire [13:0] v65; shift_adder #(13, 11, 1, 1, 14, 2, 0) op_65 (v13[12:0], v58[10:0], v65[13:0]); // 2.0
    wire [8:0] v66; assign v66[8:0] = model_inp[445:437]; // 1.0
    wire [9:0] v67; shift_adder #(6, 9, 1, 1, 10, -2, 0) op_67 (v25[5:0], v66[8:0], v67[9:0]); // 2.0
    wire [11:0] v68; shift_adder #(10, 10, 1, 1, 12, -2, 1) op_68 (v59[9:0], v48[9:0], v68[11:0]); // 2.0
    wire [8:0] v69; assign v69[8:0] = model_inp[454:446]; // 1.0
    wire [7:0] v70; assign v70[7:0] = model_inp[462:455]; // 1.0
    wire [9:0] v71; shift_adder #(9, 8, 1, 1, 10, 1, 0) op_71 (v69[8:0], v70[7:0], v71[9:0]); // 2.0
    wire [7:0] v72; assign v72[7:0] = model_inp[470:463]; // 1.0
    wire [10:0] v73; assign v73[10:0] = model_inp[481:471]; // 1.0
    wire [11:0] v74; shift_adder #(8, 11, 1, 1, 12, -1, 1) op_74 (v72[7:0], v73[10:0], v74[11:0]); // 2.0
    wire [11:0] v75; assign v75[11:0] = model_inp[493:482]; // 1.0
    wire [13:0] v76; shift_adder #(12, 12, 1, 1, 14, -1, 0) op_76 (v4[11:0], v75[11:0], v76[13:0]); // 2.0
    wire [11:0] v77; assign v77[11:0] = model_inp[505:494]; // 1.0
    wire [13:0] v78; shift_adder #(12, 14, 1, 1, 14, -1, 0) op_78 (v77[11:0], v20[13:0], v78[13:0]); // 2.0
    wire [13:0] v79; assign v79[13:0] = model_inp[519:506]; // 1.0
    wire [14:0] v80; shift_adder #(12, 14, 1, 1, 15, -2, 1) op_80 (v36[11:0], v79[13:0], v80[14:0]); // 2.0
    wire [8:0] v81; assign v81[8:0] = model_inp[528:520]; // 1.0
    wire [14:0] v82; shift_adder #(9, 12, 1, 1, 15, 2, 0) op_82 (v81[8:0], v29[11:0], v82[14:0]); // 2.0
    wire [9:0] v83; assign v83[9:0] = model_inp[538:529]; // 1.0
    wire [12:0] v84; shift_adder #(10, 12, 1, 1, 13, -2, 0) op_84 (v83[9:0], v36[11:0], v84[12:0]); // 2.0
    wire [13:0] v85; assign v85[13:0] = model_inp[552:539]; // 1.0
    wire [14:0] v86; shift_adder #(12, 14, 1, 1, 15, -2, 0) op_86 (v32[11:0], v85[13:0], v86[14:0]); // 2.0
    wire [8:0] v87; assign v87[8:0] = model_inp[561:553]; // 1.0
    wire [11:0] v88; shift_adder #(9, 8, 1, 1, 12, -3, 0) op_88 (v87[8:0], v19[7:0], v88[11:0]); // 2.0
    wire [15:0] v89; assign v89[15:0] = model_inp[577:562]; // 1.0
    wire [15:0] v90; shift_adder #(11, 16, 1, 1, 16, -4, 0) op_90 (v6[10:0], v89[15:0], v90[15:0]); // 2.0
    wire [17:0] v91; shift_adder #(10, 13, 1, 1, 18, 4, 1) op_91 (v48[9:0], v13[12:0], v91[17:0]); // 2.0
    wire [8:0] v92; shift_adder #(7, 9, 1, 1, 9, 0, 0) op_92 (v40[6:0], v87[8:0], v92[8:0]); // 2.0
    wire [11:0] v93; shift_adder #(9, 11, 1, 1, 12, -2, 0) op_93 (v81[8:0], v26[10:0], v93[11:0]); // 2.0
    wire [13:0] v94; assign v94[13:0] = model_inp[591:578]; // 1.0
    wire [12:0] v95; assign v95[12:0] = model_inp[604:592]; // 1.0
    wire [13:0] v96; shift_adder #(14, 13, 1, 1, 14, 0, 1) op_96 (v94[13:0], v95[12:0], v96[13:0]); // 2.0
    wire [9:0] v97; shift_adder #(7, 9, 1, 1, 10, -2, 1) op_97 (v56[6:0], v66[8:0], v97[9:0]); // 2.0
    wire [11:0] v98; assign v98[11:0] = model_inp[616:605]; // 1.0
    wire [7:0] v99; assign v99[7:0] = model_inp[624:617]; // 1.0
    wire [12:0] v100; shift_adder #(12, 8, 1, 1, 13, 5, 0) op_100 (v98[11:0], v99[7:0], v100[12:0]); // 2.0
    wire [7:0] v101; assign v101[7:0] = model_inp[632:625]; // 1.0
    wire [11:0] v102; shift_adder #(10, 8, 1, 1, 12, 3, 1) op_102 (v16[9:0], v101[7:0], v102[11:0]); // 2.0
    wire [15:0] v103; assign v103[15:0] = model_inp[648:633]; // 1.0
    wire [15:0] v104; shift_adder #(16, 12, 1, 1, 16, 3, 0) op_104 (v103[15:0], v36[11:0], v104[15:0]); // 2.0
    wire [13:0] v105; assign v105[13:0] = model_inp[662:649]; // 1.0
    wire [14:0] v106; shift_adder #(14, 8, 1, 1, 15, -1, 1) op_106 (v105[13:0], v72[7:0], v106[14:0]); // 2.0
    wire [10:0] v107; assign v107[10:0] = model_inp[673:663]; // 1.0
    wire [12:0] v108; shift_adder #(11, 9, 1, 1, 13, 3, 1) op_108 (v107[10:0], v87[8:0], v108[12:0]); // 2.0
    wire [12:0] v109; assign v109[12:0] = model_inp[686:674]; // 1.0
    wire [12:0] v110; shift_adder #(9, 13, 1, 1, 13, 0, 1) op_110 (v66[8:0], v109[12:0], v110[12:0]); // 2.0
    wire [9:0] v111; assign v111[9:0] = model_inp[696:687]; // 1.0
    wire [14:0] v112; shift_adder #(10, 11, 1, 1, 15, 3, 0) op_112 (v111[9:0], v73[10:0], v112[14:0]); // 2.0
    wire [9:0] v113; shift_adder #(7, 10, 1, 1, 10, -1, 1) op_113 (v40[6:0], v59[9:0], v113[9:0]); // 2.0
    wire [9:0] v114; assign v114[9:0] = model_inp[706:697]; // 1.0
    wire [8:0] v115; assign v115[8:0] = model_inp[715:707]; // 1.0
    wire [10:0] v116; shift_adder #(10, 9, 1, 1, 11, 1, 1) op_116 (v114[9:0], v115[8:0], v116[10:0]); // 2.0
    wire [13:0] v117; assign v117[13:0] = model_inp[729:716]; // 1.0
    wire [14:0] v118; shift_adder #(10, 14, 1, 1, 15, -4, 0) op_118 (v114[9:0], v117[13:0], v118[14:0]); // 2.0
    wire [10:0] v119; assign v119[10:0] = model_inp[740:730]; // 1.0
    wire [10:0] v120; shift_adder #(4, 11, 1, 1, 11, -3, 0) op_120 (v8[3:0], v119[10:0], v120[10:0]); // 2.0
    wire [10:0] v121; shift_adder #(8, 11, 1, 1, 11, 0, 0) op_121 (v101[7:0], v28[10:0], v121[10:0]); // 2.0
    wire [9:0] v122; assign v122[9:0] = model_inp[750:741]; // 1.0
    wire [11:0] v123; shift_adder #(10, 9, 1, 1, 12, -2, 0) op_123 (v122[9:0], v31[8:0], v123[11:0]); // 2.0
    wire [15:0] v124; shift_adder #(11, 16, 1, 1, 16, -1, 1) op_124 (v107[10:0], v103[15:0], v124[15:0]); // 2.0
    wire [9:0] v125; assign v125[9:0] = model_inp[760:751]; // 1.0
    wire [13:0] v126; shift_adder #(10, 12, 1, 1, 14, 2, 1) op_126 (v125[9:0], v4[11:0], v126[13:0]); // 2.0
    wire [9:0] v127; shift_adder #(8, 8, 1, 1, 10, -1, 0) op_127 (v19[7:0], v42[7:0], v127[9:0]); // 2.0
    wire [13:0] v128; assign v128[13:0] = model_inp[774:761]; // 1.0
    wire [15:0] v129; shift_adder #(12, 14, 1, 1, 16, -4, 0) op_129 (v61[11:0], v128[13:0], v129[15:0]); // 2.0
    wire [14:0] v130; shift_adder #(12, 14, 1, 1, 15, -2, 0) op_130 (v29[11:0], v85[13:0], v130[14:0]); // 2.0
    wire [12:0] v131; shift_adder #(11, 8, 1, 1, 13, 4, 0) op_131 (v28[10:0], v42[7:0], v131[12:0]); // 2.0
    wire [16:0] v132; shift_adder #(9, 17, 1, 1, 17, -3, 0) op_132 (v0[8:0], v37[16:0], v132[16:0]); // 2.0
    wire [13:0] v133; shift_adder #(9, 14, 1, 1, 14, -4, 0) op_133 (v87[8:0], v1[13:0], v133[13:0]); // 2.0
    wire [11:0] v134; assign v134[11:0] = model_inp[786:775]; // 1.0
    wire [11:0] v135; shift_adder #(8, 12, 1, 1, 12, 0, 0) op_135 (v19[7:0], v134[11:0], v135[11:0]); // 2.0
    wire [11:0] v136; shift_adder #(8, 10, 1, 1, 12, 2, 0) op_136 (v72[7:0], v9[9:0], v136[11:0]); // 2.0
    wire [12:0] v137; assign v137[12:0] = model_inp[799:787]; // 1.0
    wire [12:0] v138; shift_adder #(7, 13, 1, 1, 13, -2, 0) op_138 (v56[6:0], v137[12:0], v138[12:0]); // 2.0
    wire [8:0] v139; assign v139[8:0] = model_inp[808:800]; // 1.0
    wire [11:0] v140; shift_adder #(12, 9, 1, 1, 12, 1, 0) op_140 (v61[11:0], v139[8:0], v140[11:0]); // 2.0
    wire [13:0] v141; shift_adder #(10, 10, 1, 1, 14, -3, 1) op_141 (v63[9:0], v125[9:0], v141[13:0]); // 2.0
    wire [12:0] v142; shift_adder #(9, 10, 1, 1, 13, -4, 1) op_142 (v39[8:0], v114[9:0], v142[12:0]); // 2.0
    wire [14:0] v143; shift_adder #(9, 14, 1, 1, 15, -5, 0) op_143 (v87[8:0], v20[13:0], v143[14:0]); // 2.0
    wire [10:0] v144; assign v144[10:0] = model_inp[819:809]; // 1.0
    wire [11:0] v145; shift_adder #(10, 11, 1, 1, 12, 1, 0) op_145 (v114[9:0], v144[10:0], v145[11:0]); // 2.0
    wire [13:0] v146; assign v146[13:0] = model_inp[833:820]; // 1.0
    wire [13:0] v147; shift_adder #(14, 9, 1, 1, 14, 3, 1) op_147 (v146[13:0], v81[8:0], v147[13:0]); // 2.0
    wire [9:0] v148; assign v148[9:0] = model_inp[843:834]; // 1.0
    wire [11:0] v149; shift_adder #(10, 8, 1, 1, 12, 3, 1) op_149 (v148[9:0], v19[7:0], v149[11:0]); // 2.0
    wire [10:0] v150; assign v150[10:0] = model_inp[854:844]; // 1.0
    wire [13:0] v151; assign v151[13:0] = model_inp[868:855]; // 1.0
    wire [13:0] v152; shift_adder #(11, 14, 1, 1, 14, -1, 0) op_152 (v150[10:0], v151[13:0], v152[13:0]); // 2.0
    wire [11:0] v153; shift_adder #(10, 11, 1, 1, 12, -1, 1) op_153 (v125[9:0], v6[10:0], v153[11:0]); // 2.0
    wire [10:0] v154; shift_adder #(9, 10, 1, 1, 11, 1, 0) op_154 (v0[8:0], v48[9:0], v154[10:0]); // 2.0
    wire [10:0] v155; assign v155[10:0] = model_inp[879:869]; // 1.0
    wire [11:0] v156; shift_adder #(11, 9, 1, 1, 12, 2, 1) op_156 (v155[10:0], v31[8:0], v156[11:0]); // 2.0
    wire [12:0] v157; shift_adder #(7, 13, 1, 1, 13, -2, 0) op_157 (v40[6:0], v109[12:0], v157[12:0]); // 2.0
    wire [13:0] v158; assign v158[13:0] = model_inp[893:880]; // 1.0
    wire [14:0] v159; shift_adder #(14, 14, 1, 1, 15, 1, 0) op_159 (v105[13:0], v158[13:0], v159[14:0]); // 2.0
    wire [13:0] v160; shift_adder #(14, 10, 1, 1, 14, 1, 1) op_160 (v20[13:0], v111[9:0], v160[13:0]); // 2.0
    wire [11:0] v161; assign v161[11:0] = model_inp[905:894]; // 1.0
    wire [12:0] v162; shift_adder #(12, 12, 1, 1, 13, 0, 0) op_162 (v161[11:0], v52[11:0], v162[12:0]); // 2.0
    wire [13:0] v163; assign v163[13:0] = model_inp[919:906]; // 1.0
    wire [13:0] v164; shift_adder #(11, 14, 1, 1, 14, -2, 0) op_164 (v6[10:0], v163[13:0], v164[13:0]); // 2.0
    wire [13:0] v165; shift_adder #(14, 10, 1, 1, 14, 1, 1) op_165 (v128[13:0], v111[9:0], v165[13:0]); // 2.0
    wire [11:0] v166; assign v166[11:0] = model_inp[931:920]; // 1.0
    wire [11:0] v167; assign v167[11:0] = model_inp[943:932]; // 1.0
    wire [16:0] v168; shift_adder #(12, 12, 1, 1, 17, -5, 0) op_168 (v166[11:0], v167[11:0], v168[16:0]); // 2.0
    wire [14:0] v169; shift_adder #(13, 14, 1, 1, 15, -1, 1) op_169 (v13[12:0], v1[13:0], v169[14:0]); // 2.0
    wire [6:0] v170; assign v170[6:0] = model_inp[950:944]; // 1.0
    wire [11:0] v171; shift_adder #(11, 7, 1, 1, 12, 2, 1) op_171 (v73[10:0], v170[6:0], v171[11:0]); // 2.0
    wire [11:0] v172; shift_adder #(10, 10, 1, 1, 12, -1, 1) op_172 (v63[9:0], v122[9:0], v172[11:0]); // 2.0
    wire [9:0] v173; assign v173[9:0] = model_inp[960:951]; // 1.0
    wire [10:0] v174; assign v174[10:0] = model_inp[971:961]; // 1.0
    wire [11:0] v175; shift_adder #(10, 11, 1, 1, 12, -1, 0) op_175 (v173[9:0], v174[10:0], v175[11:0]); // 2.0
    wire [9:0] v176; shift_adder #(6, 10, 1, 1, 10, -2, 1) op_176 (v25[5:0], v83[9:0], v176[9:0]); // 2.0
    wire [14:0] v177; assign v177[14:0] = model_inp[986:972]; // 1.0
    wire [14:0] v178; shift_adder #(15, 6, 1, 1, 15, 5, 1) op_178 (v177[14:0], v25[5:0], v178[14:0]); // 2.0
    wire [13:0] v179; assign v179[13:0] = model_inp[1000:987]; // 1.0
    wire [14:0] v180; shift_adder #(14, 14, 1, 1, 15, 0, 0) op_180 (v179[13:0], v146[13:0], v180[14:0]); // 2.0
    wire [10:0] v181; shift_adder #(10, 10, 1, 1, 11, -1, 0) op_181 (v59[9:0], v173[9:0], v181[10:0]); // 2.0
    wire [12:0] v182; assign v182[12:0] = model_inp[1013:1001]; // 1.0
    wire [9:0] v183; assign v183[9:0] = model_inp[1023:1014]; // 1.0
    wire [15:0] v184; shift_adder #(13, 10, 1, 1, 16, -3, 1) op_184 (v182[12:0], v183[9:0], v184[15:0]); // 2.0
    wire [13:0] v185; shift_adder #(14, 10, 1, 1, 14, 2, 0) op_185 (v1[13:0], v63[9:0], v185[13:0]); // 2.0
    wire [11:0] v186; shift_adder #(9, 11, 1, 1, 12, 1, 0) op_186 (v81[8:0], v28[10:0], v186[11:0]); // 2.0
    wire [10:0] v187; assign v187[10:0] = model_inp[1034:1024]; // 1.0
    wire [16:0] v188; shift_adder #(17, 11, 1, 1, 17, 5, 0) op_188 (v37[16:0], v187[10:0], v188[16:0]); // 2.0
    wire [8:0] v189; assign v189[8:0] = model_inp[1043:1035]; // 1.0
    wire [11:0] v190; shift_adder #(11, 9, 1, 1, 12, -1, 1) op_190 (v28[10:0], v189[8:0], v190[11:0]); // 2.0
    wire [8:0] v191; assign v191[8:0] = model_inp[1052:1044]; // 1.0
    wire [11:0] v192; shift_adder #(9, 10, 1, 1, 12, 2, 0) op_192 (v191[8:0], v111[9:0], v192[11:0]); // 2.0
    wire [11:0] v193; shift_adder #(8, 10, 1, 1, 12, -3, 1) op_193 (v101[7:0], v48[9:0], v193[11:0]); // 2.0
    wire [12:0] v194; assign v194[12:0] = model_inp[1065:1053]; // 1.0
    wire [13:0] v195; shift_adder #(10, 13, 1, 1, 14, -3, 0) op_195 (v122[9:0], v194[12:0], v195[13:0]); // 2.0
    wire [9:0] v196; assign v196[9:0] = model_inp[1075:1066]; // 1.0
    wire [11:0] v197; shift_adder #(10, 12, 1, 1, 12, -1, 0) op_197 (v196[9:0], v32[11:0], v197[11:0]); // 2.0
    wire [15:0] v198; shift_adder #(11, 10, 1, 1, 16, -5, 1) op_198 (v150[10:0], v59[9:0], v198[15:0]); // 2.0
    wire [12:0] v199; assign v199[12:0] = model_inp[1088:1076]; // 1.0
    wire [13:0] v200; shift_adder #(12, 13, 1, 1, 14, -1, 0) op_200 (v167[11:0], v199[12:0], v200[13:0]); // 2.0
    wire [6:0] v201; assign v201[6:0] = model_inp[1095:1089]; // 1.0
    wire [11:0] v202; shift_adder #(7, 12, 1, 1, 12, 0, 1) op_202 (v201[6:0], v36[11:0], v202[11:0]); // 2.0
    wire [9:0] v203; assign v203[9:0] = model_inp[1105:1096]; // 1.0
    wire [12:0] v204; shift_adder #(10, 8, 1, 1, 13, 4, 1) op_204 (v203[9:0], v34[7:0], v204[12:0]); // 2.0
    wire [16:0] v205; shift_adder #(17, 10, 1, 1, 17, 1, 1) op_205 (v37[16:0], v59[9:0], v205[16:0]); // 2.0
    wire [9:0] v206; assign v206[9:0] = model_inp[1115:1106]; // 1.0
    wire [9:0] v207; shift_adder #(10, 7, 1, 1, 10, 0, 1) op_207 (v206[9:0], v56[6:0], v207[9:0]); // 2.0
    wire [15:0] v208; shift_adder #(8, 16, 1, 1, 16, -5, 1) op_208 (v34[7:0], v103[15:0], v208[15:0]); // 2.0
    wire [12:0] v209; shift_adder #(12, 12, 1, 1, 13, 0, 0) op_209 (v36[11:0], v167[11:0], v209[12:0]); // 2.0
    wire [14:0] v210; shift_adder #(14, 9, 1, 1, 15, 2, 0) op_210 (v79[13:0], v66[8:0], v210[14:0]); // 2.0
    wire [9:0] v211; assign v211[9:0] = model_inp[1125:1116]; // 1.0
    wire [12:0] v212; shift_adder #(10, 12, 1, 1, 13, -1, 0) op_212 (v211[9:0], v134[11:0], v212[12:0]); // 2.0
    wire [10:0] v213; assign v213[10:0] = model_inp[1136:1126]; // 1.0
    wire [11:0] v214; assign v214[11:0] = model_inp[1148:1137]; // 1.0
    wire [13:0] v215; shift_adder #(11, 12, 1, 1, 14, 1, 0) op_215 (v213[10:0], v214[11:0], v215[13:0]); // 2.0
    wire [11:0] v216; shift_adder #(12, 11, 1, 1, 12, 0, 0) op_216 (v32[11:0], v6[10:0], v216[11:0]); // 2.0
    wire [9:0] v217; assign v217[9:0] = model_inp[1158:1149]; // 1.0
    wire [13:0] v218; shift_adder #(10, 14, 1, 1, 14, -3, 0) op_218 (v217[9:0], v20[13:0], v218[13:0]); // 2.0
    wire [7:0] v219; assign v219[7:0] = model_inp[1166:1159]; // 1.0
    wire [9:0] v220; shift_adder #(9, 8, 1, 1, 10, 1, 0) op_220 (v0[8:0], v219[7:0], v220[9:0]); // 2.0
    wire [8:0] v221; assign v221[8:0] = model_inp[1175:1167]; // 1.0
    wire [11:0] v222; shift_adder #(9, 11, 1, 1, 12, -2, 1) op_222 (v221[8:0], v28[10:0], v222[11:0]); // 2.0
    wire [11:0] v223; assign v223[11:0] = model_inp[1187:1176]; // 1.0
    wire [12:0] v224; shift_adder #(12, 9, 1, 1, 13, -1, 1) op_224 (v223[11:0], v115[8:0], v224[12:0]); // 2.0
    wire [16:0] v225; shift_adder #(14, 16, 1, 1, 17, -2, 0) op_225 (v1[13:0], v103[15:0], v225[16:0]); // 2.0
    wire [13:0] v226; shift_adder #(14, 10, 1, 1, 14, 0, 0) op_226 (v128[13:0], v173[9:0], v226[13:0]); // 2.0
    wire [16:0] v227; shift_adder #(17, 9, 1, 1, 17, 1, 1) op_227 (v37[16:0], v39[8:0], v227[16:0]); // 2.0
    wire [12:0] v228; shift_adder #(9, 11, 1, 1, 13, -3, 1) op_228 (v81[8:0], v23[10:0], v228[12:0]); // 2.0
    wire [9:0] v229; assign v229[9:0] = model_inp[1197:1188]; // 1.0
    wire [12:0] v230; shift_adder #(10, 12, 1, 1, 13, 1, 0) op_230 (v229[9:0], v36[11:0], v230[12:0]); // 2.0
    wire [10:0] v231; shift_adder #(10, 9, 1, 1, 11, -1, 0) op_231 (v48[9:0], v31[8:0], v231[10:0]); // 2.0
    wire [12:0] v232; shift_adder #(12, 10, 1, 1, 13, 1, 0) op_232 (v4[11:0], v173[9:0], v232[12:0]); // 2.0
    wire [13:0] v233; shift_adder #(12, 8, 1, 1, 14, 5, 1) op_233 (v36[11:0], v101[7:0], v233[13:0]); // 2.0
    wire [10:0] v234; assign v234[10:0] = model_inp[1208:1198]; // 1.0
    wire [14:0] v235; shift_adder #(14, 11, 1, 1, 15, 4, 0) op_235 (v20[13:0], v234[10:0], v235[14:0]); // 2.0
    wire [10:0] v236; assign v236[10:0] = model_inp[1219:1209]; // 1.0
    wire [12:0] v237; shift_adder #(11, 8, 1, 1, 13, 4, 1) op_237 (v236[10:0], v34[7:0], v237[12:0]); // 2.0
    wire [12:0] v238; assign v238[12:0] = model_inp[1232:1220]; // 1.0
    wire [14:0] v239; shift_adder #(13, 12, 1, 1, 15, -2, 1) op_239 (v238[12:0], v50[11:0], v239[14:0]); // 2.0
    wire [13:0] v240; shift_adder #(14, 11, 1, 1, 14, 0, 1) op_240 (v1[13:0], v28[10:0], v240[13:0]); // 2.0
    wire [12:0] v241; shift_adder #(10, 12, 1, 1, 13, -1, 0) op_241 (v48[9:0], v29[11:0], v241[12:0]); // 2.0
    wire [10:0] v242; assign v242[10:0] = model_inp[1243:1233]; // 1.0
    wire [16:0] v243; shift_adder #(11, 13, 1, 1, 17, 3, 1) op_243 (v242[10:0], v13[12:0], v243[16:0]); // 2.0
    wire [14:0] v244; shift_adder #(14, 10, 1, 1, 15, 4, 0) op_244 (v128[13:0], v63[9:0], v244[14:0]); // 2.0
    wire [15:0] v245; shift_adder #(14, 10, 1, 1, 16, -2, 1) op_245 (v117[13:0], v206[9:0], v245[15:0]); // 2.0
    wire [7:0] v246; assign v246[7:0] = model_inp[1251:1244]; // 1.0
    wire [10:0] v247; shift_adder #(11, 8, 1, 1, 11, 1, 0) op_247 (v26[10:0], v246[7:0], v247[10:0]); // 2.0
    wire [10:0] v248; shift_adder #(8, 8, 1, 1, 11, -2, 0) op_248 (v34[7:0], v72[7:0], v248[10:0]); // 2.0
    wire [8:0] v249; assign v249[8:0] = model_inp[1260:1252]; // 1.0
    wire [13:0] v250; shift_adder #(9, 14, 1, 1, 14, -3, 1) op_250 (v249[8:0], v53[13:0], v250[13:0]); // 2.0
    wire [13:0] v251; assign v251[13:0] = model_inp[1274:1261]; // 1.0
    wire [13:0] v252; shift_adder #(14, 7, 1, 1, 14, 3, 1) op_252 (v251[13:0], v56[6:0], v252[13:0]); // 2.0
    wire [9:0] v253; shift_adder #(8, 10, 1, 1, 10, 0, 0) op_253 (v101[7:0], v206[9:0], v253[9:0]); // 2.0
    wire [11:0] v254; shift_adder #(10, 12, 1, 1, 12, -1, 0) op_254 (v48[9:0], v36[11:0], v254[11:0]); // 2.0
    wire [10:0] v255; assign v255[10:0] = model_inp[1285:1275]; // 1.0
    wire [11:0] v256; shift_adder #(11, 8, 1, 1, 12, 3, 1) op_256 (v255[10:0], v101[7:0], v256[11:0]); // 2.0
    wire [9:0] v257; assign v257[9:0] = model_inp[1295:1286]; // 1.0
    wire [9:0] v258; assign v258[9:0] = model_inp[1305:1296]; // 1.0
    wire [10:0] v259; shift_adder #(10, 10, 1, 1, 11, 0, 0) op_259 (v257[9:0], v258[9:0], v259[10:0]); // 2.0
    wire [11:0] v260; shift_adder #(12, 8, 1, 1, 12, 1, 1) op_260 (v167[11:0], v42[7:0], v260[11:0]); // 2.0
    wire [12:0] v261; shift_adder #(10, 8, 1, 1, 13, 4, 1) op_261 (v9[9:0], v34[7:0], v261[12:0]); // 2.0
    wire [13:0] v262; shift_adder #(11, 9, 1, 1, 14, 4, 0) op_262 (v58[10:0], v31[8:0], v262[13:0]); // 2.0
    wire [11:0] v263; assign v263[11:0] = model_inp[1317:1306]; // 1.0
    wire [11:0] v264; shift_adder #(12, 10, 1, 1, 12, 1, 0) op_264 (v263[11:0], v59[9:0], v264[11:0]); // 2.0
    wire [11:0] v265; assign v265[11:0] = model_inp[1329:1318]; // 1.0
    wire [15:0] v266; shift_adder #(12, 14, 1, 1, 16, -4, 1) op_266 (v265[11:0], v163[13:0], v266[15:0]); // 2.0
    wire [13:0] v267; shift_adder #(13, 11, 1, 1, 14, 2, 0) op_267 (v194[12:0], v150[10:0], v267[13:0]); // 2.0
    wire [9:0] v268; assign v268[9:0] = model_inp[1339:1330]; // 1.0
    wire [12:0] v269; shift_adder #(10, 11, 1, 1, 13, -2, 1) op_269 (v268[9:0], v23[10:0], v269[12:0]); // 2.0
    wire [11:0] v270; shift_adder #(11, 10, 1, 1, 12, 1, 0) op_270 (v150[10:0], v206[9:0], v270[11:0]); // 2.0
    wire [12:0] v271; shift_adder #(11, 11, 1, 1, 13, -2, 0) op_271 (v58[10:0], v6[10:0], v271[12:0]); // 2.0
    wire [10:0] v272; assign v272[10:0] = model_inp[1350:1340]; // 1.0
    wire [11:0] v273; assign v273[11:0] = model_inp[1362:1351]; // 1.0
    wire [10:0] v274; assign v274[10:0] = model_inp[1373:1363]; // 1.0
    wire [11:0] v275; assign v275[11:0] = model_inp[1385:1374]; // 1.0
    wire [9:0] v276; assign v276[9:0] = model_inp[1395:1386]; // 1.0
    wire [10:0] v277; assign v277[10:0] = model_inp[1406:1396]; // 1.0
    wire [8:0] v278; assign v278[8:0] = model_inp[1415:1407]; // 1.0
    wire [11:0] v279; assign v279[11:0] = model_inp[1427:1416]; // 1.0
    wire [12:0] v280; assign v280[12:0] = model_inp[1440:1428]; // 1.0
    wire [1:0] v281; assign v281[1:0] = model_inp[1442:1441]; // 1.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[13:0] = v2[13:0];
    assign model_out[29:14] = v103[15:0];
    assign model_out[42:30] = v5[12:0];
    assign model_out[55:43] = v7[12:0];
    assign model_out[65:56] = v10[9:0];
    assign model_out[79:66] = v20[13:0];
    assign model_out[92:80] = v12[12:0];
    assign model_out[108:93] = v15[15:0];
    assign model_out[119:109] = v272[10:0];
    assign model_out[131:120] = v18[11:0];
    assign model_out[143:132] = v273[11:0];
    assign model_out[157:144] = v21[13:0];
    assign model_out[169:158] = v24[11:0];
    assign model_out[180:170] = v27[10:0];
    assign model_out[187:181] = v170[6:0];
    assign model_out[200:188] = v30[12:0];
    assign model_out[212:201] = v33[11:0];
    assign model_out[222:213] = v35[9:0];
    assign model_out[231:223] = v41[8:0];
    assign model_out[241:232] = v258[9:0];
    assign model_out[252:242] = v44[10:0];
    assign model_out[268:253] = v47[15:0];
    assign model_out[279:269] = v49[10:0];
    assign model_out[295:280] = v51[15:0];
    assign model_out[305:296] = v217[9:0];
    assign model_out[317:306] = v57[11:0];
    assign model_out[329:318] = v60[11:0];
    assign model_out[345:330] = v64[15:0];
    assign model_out[358:346] = v137[12:0];
    assign model_out[372:359] = v65[13:0];
    assign model_out[382:373] = v67[9:0];
    assign model_out[394:383] = v62[11:0];
    assign model_out[406:395] = v68[11:0];
    assign model_out[416:407] = v71[9:0];
    assign model_out[428:417] = v36[11:0];
    assign model_out[440:429] = v74[11:0];
    assign model_out[454:441] = v76[13:0];
    assign model_out[468:455] = v78[13:0];
    assign model_out[483:469] = v82[14:0];
    assign model_out[494:484] = v274[10:0];
    assign model_out[507:495] = v84[12:0];
    assign model_out[522:508] = v86[14:0];
    assign model_out[532:523] = v59[9:0];
    assign model_out[548:533] = v90[15:0];
    assign model_out[566:549] = v91[17:0];
    assign model_out[575:567] = v92[8:0];
    assign model_out[589:576] = v53[13:0];
    assign model_out[597:590] = v34[7:0];
    assign model_out[607:598] = v97[9:0];
    assign model_out[620:608] = v100[12:0];
    assign model_out[630:621] = v173[9:0];
    assign model_out[642:631] = v102[11:0];
    assign model_out[658:643] = v104[15:0];
    assign model_out[673:659] = v106[14:0];
    assign model_out[686:674] = v108[12:0];
    assign model_out[699:687] = v110[12:0];
    assign model_out[714:700] = v112[14:0];
    assign model_out[724:715] = v113[9:0];
    assign model_out[735:725] = v116[10:0];
    assign model_out[746:736] = v120[10:0];
    assign model_out[757:747] = v121[10:0];
    assign model_out[769:758] = v45[11:0];
    assign model_out[785:770] = v124[15:0];
    assign model_out[789:786] = v8[3:0];
    assign model_out[803:790] = v126[13:0];
    assign model_out[813:804] = v127[9:0];
    assign model_out[827:814] = v117[13:0];
    assign model_out[843:828] = v129[15:0];
    assign model_out[858:844] = v130[14:0];
    assign model_out[871:859] = v131[12:0];
    assign model_out[888:872] = v132[16:0];
    assign model_out[897:889] = v66[8:0];
    assign model_out[906:898] = v189[8:0];
    assign model_out[918:907] = v135[11:0];
    assign model_out[930:919] = v136[11:0];
    assign model_out[943:931] = v138[12:0];
    assign model_out[957:944] = v141[13:0];
    assign model_out[970:958] = v142[12:0];
    assign model_out[985:971] = v143[14:0];
    assign model_out[997:986] = v145[11:0];
    assign model_out[1011:998] = v147[13:0];
    assign model_out[1023:1012] = v149[11:0];
    assign model_out[1037:1024] = v128[13:0];
    assign model_out[1051:1038] = v152[13:0];
    assign model_out[1063:1052] = v275[11:0];
    assign model_out[1075:1064] = v153[11:0];
    assign model_out[1086:1076] = v154[10:0];
    assign model_out[1098:1087] = v156[11:0];
    assign model_out[1108:1099] = v276[9:0];
    assign model_out[1123:1109] = v159[14:0];
    assign model_out[1137:1124] = v160[13:0];
    assign model_out[1150:1138] = v162[12:0];
    assign model_out[1164:1151] = v164[13:0];
    assign model_out[1178:1165] = v165[13:0];
    assign model_out[1185:1179] = v201[6:0];
    assign model_out[1200:1186] = v169[14:0];
    assign model_out[1209:1201] = v115[8:0];
    assign model_out[1221:1210] = v171[11:0];
    assign model_out[1233:1222] = v172[11:0];
    assign model_out[1245:1234] = v175[11:0];
    assign model_out[1255:1246] = v176[9:0];
    assign model_out[1270:1256] = v178[14:0];
    assign model_out[1281:1271] = v26[10:0];
    assign model_out[1296:1282] = v180[14:0];
    assign model_out[1307:1297] = v181[10:0];
    assign model_out[1323:1308] = v184[15:0];
    assign model_out[1337:1324] = v185[13:0];
    assign model_out[1349:1338] = v186[11:0];
    assign model_out[1358:1350] = v81[8:0];
    assign model_out[1370:1359] = v190[11:0];
    assign model_out[1381:1371] = v58[10:0];
    assign model_out[1392:1382] = v277[10:0];
    assign model_out[1404:1393] = v192[11:0];
    assign model_out[1416:1405] = v193[11:0];
    assign model_out[1429:1417] = v157[12:0];
    assign model_out[1441:1430] = v197[11:0];
    assign model_out[1457:1442] = v198[15:0];
    assign model_out[1470:1458] = v204[12:0];
    assign model_out[1487:1471] = v205[16:0];
    assign model_out[1497:1488] = v207[9:0];
    assign model_out[1513:1498] = v208[15:0];
    assign model_out[1526:1514] = v209[12:0];
    assign model_out[1541:1527] = v210[14:0];
    assign model_out[1554:1542] = v212[12:0];
    assign model_out[1568:1555] = v215[13:0];
    assign model_out[1582:1569] = v218[13:0];
    assign model_out[1595:1583] = v199[12:0];
    assign model_out[1605:1596] = v220[9:0];
    assign model_out[1617:1606] = v222[11:0];
    assign model_out[1626:1618] = v278[8:0];
    assign model_out[1639:1627] = v224[12:0];
    assign model_out[1656:1640] = v225[16:0];
    assign model_out[1669:1657] = v228[12:0];
    assign model_out[1682:1670] = v230[12:0];
    assign model_out[1693:1683] = v231[10:0];
    assign model_out[1706:1694] = v232[12:0];
    assign model_out[1720:1707] = v233[13:0];
    assign model_out[1735:1721] = v235[14:0];
    assign model_out[1748:1736] = v237[12:0];
    assign model_out[1756:1749] = v42[7:0];
    assign model_out[1771:1757] = v239[14:0];
    assign model_out[1785:1772] = v240[13:0];
    assign model_out[1798:1786] = v241[12:0];
    assign model_out[1815:1799] = v243[16:0];
    assign model_out[1830:1816] = v244[14:0];
    assign model_out[1846:1831] = v245[15:0];
    assign model_out[1857:1847] = v247[10:0];
    assign model_out[1868:1858] = v248[10:0];
    assign model_out[1882:1869] = v252[13:0];
    assign model_out[1892:1883] = v253[9:0];
    assign model_out[1904:1893] = v279[11:0];
    assign model_out[1916:1905] = v254[11:0];
    assign model_out[1928:1917] = v256[11:0];
    assign model_out[1940:1929] = v202[11:0];
    assign model_out[1952:1941] = v29[11:0];
    assign model_out[1963:1953] = v259[10:0];
    assign model_out[1975:1964] = v260[11:0];
    assign model_out[1988:1976] = v261[12:0];
    assign model_out[2002:1989] = v262[13:0];
    assign model_out[2014:2003] = v264[11:0];
    assign model_out[2030:2015] = v266[15:0];
    assign model_out[2044:2031] = v267[13:0];
    assign model_out[2057:2045] = v280[12:0];
    assign model_out[2070:2058] = v269[12:0];
    assign model_out[2084:2071] = v105[13:0];
    assign model_out[2096:2085] = v270[11:0];
    assign model_out[2109:2097] = v271[12:0];
    assign model_out[2126:2110] = v38[16:0];
    assign model_out[2141:2127] = v54[14:0];
    assign model_out[2156:2142] = v80[14:0];
    assign model_out[2168:2157] = v88[11:0];
    assign model_out[2180:2169] = v93[11:0];
    assign model_out[2194:2181] = v96[13:0];
    assign model_out[2209:2195] = v118[14:0];
    assign model_out[2221:2210] = v123[11:0];
    assign model_out[2235:2222] = v133[13:0];
    assign model_out[2247:2236] = v140[11:0];
    assign model_out[2264:2248] = v168[16:0];
    assign model_out[2281:2265] = v188[16:0];
    assign model_out[2295:2282] = v195[13:0];
    assign model_out[2309:2296] = v200[13:0];
    assign model_out[2321:2310] = v216[11:0];
    assign model_out[2335:2322] = v226[13:0];
    assign model_out[2352:2336] = v227[16:0];
    assign model_out[2360:2353] = v19[7:0];
    assign model_out[2374:2361] = v250[13:0];
    assign model_out[2376:2375] = v281[1:0];

endmodule
