`timescale 1 ns / 1 ps

module x310_clf_stage9 (
    input [1177:0] model_inp,
    output [528:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [9:0] v0; assign v0[9:0] = model_inp[9:0]; // 13.5
    wire [10:0] v1; assign v1[10:0] = model_inp[20:10]; // 13.5
    wire [10:0] v2; shift_adder #(10, 11, 1, 1, 11, 0, 0) op_2 (v0[9:0], v1[10:0], v2[10:0]); // 14.0
    wire [7:0] v3; assign v3[7:0] = model_inp[28:21]; // 13.5
    wire [8:0] v4; assign v4[8:0] = model_inp[37:29]; // 13.5
    wire [9:0] v5; shift_adder #(8, 9, 1, 1, 10, 1, 0) op_5 (v3[7:0], v4[8:0], v5[9:0]); // 14.0
    wire [10:0] v6; assign v6[10:0] = model_inp[48:38]; // 13.5
    wire [9:0] v7; assign v7[9:0] = model_inp[58:49]; // 13.5
    wire [11:0] v8; shift_adder #(11, 10, 1, 1, 12, 1, 0) op_8 (v6[10:0], v7[9:0], v8[11:0]); // 14.0
    wire [11:0] v9; shift_adder #(12, 4, 1, 0, 12, 0, 1) op_9 (v8[11:0], 4'b1000, v9[11:0]); // 14.0
    wire [10:0] v10; assign v10[10:0] = v9[10:0] & {11{~v9[11]}}; // 14.0
    wire [10:0] v11; shift_adder #(11, 4, 0, 0, 11, 0, 0) op_11 (v10[10:0], 4'b1000, v11[10:0]); // 14.0
    wire [4:0] v12; assign v12[4:0] = v11[8:4]; // 14.0
    wire [9:0] v13; assign v13[9:0] = model_inp[68:59]; // 13.5
    wire [9:0] v14; assign v14[9:0] = model_inp[78:69]; // 13.5
    wire [10:0] v15; shift_adder #(10, 10, 1, 1, 11, 0, 0) op_15 (v13[9:0], v14[9:0], v15[10:0]); // 14.0
    wire [9:0] v16; assign v16[9:0] = model_inp[88:79]; // 13.5
    wire [7:0] v17; assign v17[7:0] = model_inp[96:89]; // 13.5
    wire [10:0] v18; shift_adder #(10, 8, 1, 1, 11, 2, 1) op_18 (v16[9:0], v17[7:0], v18[10:0]); // 14.0
    wire [10:0] v19; assign v19[10:0] = model_inp[107:97]; // 13.5
    wire [9:0] v20; assign v20[9:0] = model_inp[117:108]; // 13.5
    wire [11:0] v21; shift_adder #(11, 10, 1, 1, 12, 1, 1) op_21 (v19[10:0], v20[9:0], v21[11:0]); // 14.0
    wire [9:0] v22; assign v22[9:0] = model_inp[127:118]; // 13.5
    wire [10:0] v23; shift_adder #(10, 8, 1, 1, 11, 1, 1) op_23 (v22[9:0], v3[7:0], v23[10:0]); // 14.0
    wire [7:0] v24; assign v24[7:0] = model_inp[135:128]; // 13.5
    wire [10:0] v25; assign v25[10:0] = model_inp[146:136]; // 13.5
    wire [10:0] v26; shift_adder #(8, 11, 1, 1, 11, 0, 1) op_26 (v24[7:0], v25[10:0], v26[10:0]); // 14.0
    wire [10:0] v27; assign v27[10:0] = model_inp[157:147]; // 13.5
    wire [9:0] v28; assign v28[9:0] = model_inp[167:158]; // 13.5
    wire [11:0] v29; shift_adder #(11, 10, 1, 1, 12, 1, 1) op_29 (v27[10:0], v28[9:0], v29[11:0]); // 14.0
    wire [9:0] v30; assign v30[9:0] = model_inp[177:168]; // 13.5
    wire [8:0] v31; assign v31[8:0] = model_inp[186:178]; // 13.5
    wire [10:0] v32; shift_adder #(10, 9, 1, 1, 11, 0, 1) op_32 (v30[9:0], v31[8:0], v32[10:0]); // 14.0
    wire [10:0] v33; assign v33[10:0] = model_inp[197:187]; // 13.5
    wire [10:0] v34; shift_adder #(8, 11, 1, 1, 11, -1, 0) op_34 (v24[7:0], v33[10:0], v34[10:0]); // 14.0
    wire [10:0] v35; assign v35[10:0] = model_inp[208:198]; // 13.5
    wire [10:0] v36; assign v36[10:0] = model_inp[219:209]; // 13.5
    wire [11:0] v37; shift_adder #(11, 11, 1, 1, 12, 0, 0) op_37 (v35[10:0], v36[10:0], v37[11:0]); // 14.0
    wire [9:0] v38; assign v38[9:0] = model_inp[229:220]; // 13.5
    wire [10:0] v39; assign v39[10:0] = model_inp[240:230]; // 13.5
    wire [10:0] v40; shift_adder #(10, 11, 1, 1, 11, 0, 1) op_40 (v38[9:0], v39[10:0], v40[10:0]); // 14.0
    wire [7:0] v41; assign v41[7:0] = model_inp[248:241]; // 13.5
    wire [5:0] v42; assign v42[5:0] = model_inp[254:249]; // 13.5
    wire [8:0] v43; shift_adder #(8, 6, 0, 0, 9, -1, 0) op_43 (v41[7:0], v42[5:0], v43[8:0]); // 14.0
    wire [10:0] v44; assign v44[10:0] = model_inp[265:255]; // 13.5
    wire [6:0] v45; assign v45[6:0] = model_inp[272:266]; // 13.5
    wire [10:0] v46; shift_adder #(11, 7, 1, 0, 11, 1, 1) op_46 (v44[10:0], v45[6:0], v46[10:0]); // 14.0
    wire [10:0] v47; assign v47[10:0] = model_inp[283:273]; // 13.5
    wire [10:0] v48; assign v48[10:0] = model_inp[294:284]; // 13.5
    wire [11:0] v49; shift_adder #(11, 11, 1, 1, 12, 0, 1) op_49 (v47[10:0], v48[10:0], v49[11:0]); // 14.0
    wire [8:0] v50; assign v50[8:0] = model_inp[303:295]; // 13.5
    wire [8:0] v51; assign v51[8:0] = model_inp[312:304]; // 13.5
    wire [9:0] v52; shift_adder #(9, 9, 0, 1, 10, 0, 0) op_52 (v50[8:0], v51[8:0], v52[9:0]); // 14.0
    wire [9:0] v53; shift_adder #(10, 3, 1, 0, 10, 0, 1) op_53 (v52[9:0], 3'b100, v53[9:0]); // 14.0
    wire [8:0] v54; assign v54[8:0] = v53[8:0] & {9{~v53[9]}}; // 14.0
    wire [8:0] v55; shift_adder #(9, 3, 0, 0, 9, 0, 0) op_55 (v54[8:0], 3'b100, v55[8:0]); // 14.0
    wire [3:0] v56; assign v56[3:0] = v55[6:3]; // 14.0
    wire [10:0] v57; assign v57[10:0] = model_inp[323:313]; // 13.5
    wire [8:0] v58; assign v58[8:0] = model_inp[332:324]; // 13.5
    wire [10:0] v59; shift_adder #(11, 9, 1, 1, 11, 2, 0) op_59 (v57[10:0], v58[8:0], v59[10:0]); // 14.0
    wire [8:0] v60; assign v60[8:0] = model_inp[341:333]; // 13.5
    wire [8:0] v61; assign v61[8:0] = model_inp[350:342]; // 13.5
    wire [10:0] v62; shift_adder #(9, 9, 1, 1, 11, 1, 1) op_62 (v60[8:0], v61[8:0], v62[10:0]); // 14.0
    wire [10:0] v63; assign v63[10:0] = model_inp[361:351]; // 13.5
    wire [8:0] v64; assign v64[8:0] = model_inp[370:362]; // 13.5
    wire [11:0] v65; shift_adder #(11, 9, 1, 0, 12, 1, 1) op_65 (v63[10:0], v64[8:0], v65[11:0]); // 14.0
    wire [8:0] v66; assign v66[8:0] = model_inp[379:371]; // 13.5
    wire [8:0] v67; assign v67[8:0] = model_inp[388:380]; // 13.5
    wire [11:0] v68; shift_adder #(9, 9, 1, 1, 12, 2, 1) op_68 (v66[8:0], v67[8:0], v68[11:0]); // 14.0
    wire [10:0] v69; assign v69[10:0] = model_inp[399:389]; // 13.5
    wire [9:0] v70; assign v70[9:0] = model_inp[409:400]; // 13.5
    wire [11:0] v71; shift_adder #(11, 10, 1, 1, 12, 1, 0) op_71 (v69[10:0], v70[9:0], v71[11:0]); // 14.0
    wire [11:0] v72; assign v72[11:0] = model_inp[421:410]; // 13.5
    wire [9:0] v73; assign v73[9:0] = model_inp[431:422]; // 13.5
    wire [11:0] v74; shift_adder #(12, 10, 1, 1, 12, 1, 0) op_74 (v72[11:0], v73[9:0], v74[11:0]); // 14.0
    wire [3:0] v75; assign v75[3:0] = model_inp[435:432]; // 13.5
    wire [7:0] v76; assign v76[7:0] = model_inp[443:436]; // 13.5
    wire [7:0] v77; shift_adder #(4, 8, 0, 1, 8, -1, 0) op_77 (v75[3:0], v76[7:0], v77[7:0]); // 14.0
    wire [10:0] v78; assign v78[10:0] = model_inp[454:444]; // 13.5
    wire [5:0] v79; assign v79[5:0] = model_inp[460:455]; // 13.5
    wire [10:0] v80; shift_adder #(11, 6, 1, 0, 11, 1, 0) op_80 (v78[10:0], v79[5:0], v80[10:0]); // 14.0
    wire [9:0] v81; assign v81[9:0] = model_inp[470:461]; // 13.5
    wire [9:0] v82; assign v82[9:0] = model_inp[480:471]; // 13.5
    wire [11:0] v83; shift_adder #(10, 10, 1, 1, 12, 1, 0) op_83 (v81[9:0], v82[9:0], v83[11:0]); // 14.0
    wire [8:0] v84; assign v84[8:0] = model_inp[489:481]; // 13.5
    wire [9:0] v85; shift_adder #(9, 9, 0, 1, 10, 1, 0) op_85 (v84[8:0], v4[8:0], v85[9:0]); // 14.0
    wire [8:0] v86; assign v86[8:0] = v85[8:0] & {9{~v85[9]}}; // 14.0
    wire [8:0] v87; shift_adder #(9, 3, 0, 0, 9, 0, 0) op_87 (v86[8:0], 3'b100, v87[8:0]); // 14.0
    wire [3:0] v88; assign v88[3:0] = v87[6:3]; // 14.0
    wire [10:0] v89; assign v89[10:0] = model_inp[500:490]; // 13.5
    wire [8:0] v90; assign v90[8:0] = model_inp[509:501]; // 13.5
    wire [11:0] v91; shift_adder #(11, 9, 1, 1, 12, 1, 1) op_91 (v89[10:0], v90[8:0], v91[11:0]); // 14.0
    wire [9:0] v92; assign v92[9:0] = model_inp[519:510]; // 13.5
    wire [9:0] v93; assign v93[9:0] = model_inp[529:520]; // 13.5
    wire [10:0] v94; shift_adder #(10, 10, 1, 1, 11, 0, 0) op_94 (v92[9:0], v93[9:0], v94[10:0]); // 14.0
    wire [9:0] v95; assign v95[9:0] = model_inp[539:530]; // 13.5
    wire [8:0] v96; assign v96[8:0] = model_inp[548:540]; // 13.5
    wire [10:0] v97; shift_adder #(10, 9, 1, 1, 11, 0, 1) op_97 (v95[9:0], v96[8:0], v97[10:0]); // 14.0
    wire [4:0] v98; assign v98[4:0] = model_inp[553:549]; // 13.5
    wire [8:0] v99; assign v99[8:0] = model_inp[562:554]; // 13.5
    wire [8:0] v100; shift_adder #(5, 9, 0, 1, 9, 0, 0) op_100 (v98[4:0], v99[8:0], v100[8:0]); // 14.0
    wire [8:0] v101; assign v101[8:0] = model_inp[571:563]; // 13.5
    wire [9:0] v102; assign v102[9:0] = model_inp[581:572]; // 13.5
    wire [10:0] v103; shift_adder #(9, 10, 1, 1, 11, 0, 0) op_103 (v101[8:0], v102[9:0], v103[10:0]); // 14.0
    wire [8:0] v104; assign v104[8:0] = v103[8:0] & {9{~v103[10]}}; // 14.0
    wire [8:0] v105; shift_adder #(9, 3, 0, 0, 9, 0, 0) op_105 (v104[8:0], 3'b100, v105[8:0]); // 14.0
    wire [3:0] v106; assign v106[3:0] = v105[6:3]; // 14.0
    wire [11:0] v107; assign v107[11:0] = model_inp[593:582]; // 13.5
    wire [9:0] v108; assign v108[9:0] = model_inp[603:594]; // 13.5
    wire [12:0] v109; shift_adder #(12, 10, 1, 1, 13, 2, 0) op_109 (v107[11:0], v108[9:0], v109[12:0]); // 14.0
    wire [8:0] v110; assign v110[8:0] = model_inp[612:604]; // 13.5
    wire [9:0] v111; shift_adder #(9, 9, 1, 1, 10, 0, 0) op_111 (v110[8:0], v90[8:0], v111[9:0]); // 14.0
    wire [10:0] v112; assign v112[10:0] = model_inp[623:613]; // 13.5
    wire [9:0] v113; assign v113[9:0] = model_inp[633:624]; // 13.5
    wire [11:0] v114; shift_adder #(11, 10, 1, 1, 12, 0, 0) op_114 (v112[10:0], v113[9:0], v114[11:0]); // 14.0
    wire [9:0] v115; assign v115[9:0] = model_inp[643:634]; // 13.5
    wire [10:0] v116; assign v116[10:0] = model_inp[654:644]; // 13.5
    wire [12:0] v117; shift_adder #(10, 11, 1, 1, 13, 1, 0) op_117 (v115[9:0], v116[10:0], v117[12:0]); // 14.0
    wire [10:0] v118; assign v118[10:0] = model_inp[665:655]; // 13.5
    wire [10:0] v119; assign v119[10:0] = model_inp[676:666]; // 13.5
    wire [11:0] v120; shift_adder #(11, 11, 1, 1, 12, 1, 0) op_120 (v118[10:0], v119[10:0], v120[11:0]); // 14.0
    wire [10:0] v121; assign v121[10:0] = model_inp[687:677]; // 13.5
    wire [10:0] v122; assign v122[10:0] = model_inp[698:688]; // 13.5
    wire [11:0] v123; shift_adder #(11, 11, 1, 1, 12, 0, 0) op_123 (v121[10:0], v122[10:0], v123[11:0]); // 14.0
    wire [9:0] v124; assign v124[9:0] = model_inp[708:699]; // 13.5
    wire [8:0] v125; assign v125[8:0] = model_inp[717:709]; // 13.5
    wire [10:0] v126; shift_adder #(10, 9, 1, 1, 11, 1, 0) op_126 (v124[9:0], v125[8:0], v126[10:0]); // 14.0
    wire [10:0] v127; assign v127[10:0] = model_inp[728:718]; // 13.5
    wire [7:0] v128; assign v128[7:0] = model_inp[736:729]; // 13.5
    wire [10:0] v129; shift_adder #(11, 8, 1, 1, 11, 2, 1) op_129 (v127[10:0], v128[7:0], v129[10:0]); // 14.0
    wire [9:0] v130; assign v130[9:0] = model_inp[746:737]; // 13.5
    wire [8:0] v131; assign v131[8:0] = model_inp[755:747]; // 13.5
    wire [10:0] v132; shift_adder #(10, 9, 1, 1, 11, 1, 1) op_132 (v130[9:0], v131[8:0], v132[10:0]); // 14.0
    wire [10:0] v133; assign v133[10:0] = model_inp[766:756]; // 13.5
    wire [9:0] v134; assign v134[9:0] = model_inp[776:767]; // 13.5
    wire [10:0] v135; shift_adder #(11, 10, 1, 1, 11, 0, 1) op_135 (v133[10:0], v134[9:0], v135[10:0]); // 14.0
    wire [2:0] v136; assign v136[2:0] = model_inp[779:777]; // 13.5
    wire [2:0] v137; assign v137[2:0] = model_inp[782:780]; // 13.5
    wire [4:0] v138; shift_adder #(3, 3, 0, 0, 5, 1, 0) op_138 (v136[2:0], v137[2:0], v138[4:0]); // 14.0
    wire [9:0] v139; assign v139[9:0] = model_inp[792:783]; // 13.5
    wire [9:0] v140; assign v140[9:0] = model_inp[802:793]; // 13.5
    wire [10:0] v141; shift_adder #(10, 10, 1, 0, 11, 0, 1) op_141 (v139[9:0], v140[9:0], v141[10:0]); // 14.0
    wire [9:0] v142; assign v142[9:0] = model_inp[812:803]; // 13.5
    wire [8:0] v143; assign v143[8:0] = model_inp[821:813]; // 13.5
    wire [10:0] v144; shift_adder #(10, 9, 1, 0, 11, 0, 1) op_144 (v142[9:0], v143[8:0], v144[10:0]); // 14.0
    wire [9:0] v145; assign v145[9:0] = model_inp[831:822]; // 13.5
    wire [11:0] v146; assign v146[11:0] = model_inp[843:832]; // 13.5
    wire [11:0] v147; shift_adder #(10, 12, 1, 1, 12, -1, 0) op_147 (v145[9:0], v146[11:0], v147[11:0]); // 14.0
    wire [4:0] v148; assign v148[4:0] = model_inp[848:844]; // 13.5
    wire [10:0] v149; assign v149[10:0] = model_inp[859:849]; // 13.5
    wire [10:0] v150; shift_adder #(5, 11, 1, 1, 11, -1, 0) op_150 (v148[4:0], v149[10:0], v150[10:0]); // 14.0
    wire [10:0] v151; assign v151[10:0] = model_inp[870:860]; // 13.5
    wire [10:0] v152; assign v152[10:0] = model_inp[881:871]; // 13.5
    wire [11:0] v153; shift_adder #(11, 11, 1, 1, 12, -1, 0) op_153 (v151[10:0], v152[10:0], v153[11:0]); // 14.0
    wire [9:0] v154; assign v154[9:0] = model_inp[891:882]; // 13.5
    wire [10:0] v155; shift_adder #(10, 8, 1, 1, 11, 2, 1) op_155 (v154[9:0], v128[7:0], v155[10:0]); // 14.0
    wire [3:0] v156; assign v156[3:0] = model_inp[895:892]; // 13.5
    wire [5:0] v157; assign v157[5:0] = model_inp[901:896]; // 13.5
    wire [6:0] v158; shift_adder #(4, 6, 0, 1, 7, -1, 0) op_158 (v156[3:0], v157[5:0], v158[6:0]); // 14.0
    wire [3:0] v159; assign v159[3:0] = model_inp[905:902]; // 13.5
    wire [3:0] v160; assign v160[3:0] = model_inp[909:906]; // 13.5
    wire [4:0] v161; shift_adder #(4, 4, 0, 0, 5, 0, 1) op_161 (v159[3:0], v160[3:0], v161[4:0]); // 14.0
    wire [2:0] v162; assign v162[2:0] = model_inp[912:910]; // 13.5
    wire [3:0] v163; shift_adder #(3, 3, 0, 0, 4, 0, 1) op_163 (v162[2:0], v136[2:0], v163[3:0]); // 14.0
    wire [8:0] v164; assign v164[8:0] = model_inp[921:913]; // 13.5
    wire [11:0] v165; shift_adder #(9, 10, 1, 1, 12, -2, 0) op_165 (v164[8:0], v5[9:0], v165[11:0]); // 15.0
    wire [10:0] v166; assign v166[10:0] = model_inp[932:922]; // 13.5
    wire [11:0] v167; shift_adder #(11, 11, 1, 1, 12, 0, 0) op_167 (v166[10:0], v15[10:0], v167[11:0]); // 15.0
    wire [11:0] v168; shift_adder #(11, 12, 1, 1, 12, 0, 0) op_168 (v18[10:0], v21[11:0], v168[11:0]); // 15.0
    wire [10:0] v169; assign v169[10:0] = v168[10:0] & {11{~v168[11]}}; // 15.0
    wire [10:0] v170; shift_adder #(11, 4, 0, 0, 11, 0, 0) op_170 (v169[10:0], 4'b1000, v170[10:0]); // 15.0
    wire [3:0] v171; assign v171[3:0] = v170[7:4]; // 15.0
    wire [11:0] v172; shift_adder #(11, 11, 1, 1, 12, 0, 0) op_172 (v23[10:0], v26[10:0], v172[11:0]); // 15.0
    wire [9:0] v173; assign v173[9:0] = v172[9:0] & {10{~v172[11]}}; // 15.0
    wire [9:0] v174; shift_adder #(10, 4, 0, 0, 10, 0, 0) op_174 (v173[9:0], 4'b1000, v174[9:0]); // 15.0
    wire [3:0] v175; assign v175[3:0] = v174[7:4]; // 15.0
    wire [12:0] v176; shift_adder #(12, 11, 1, 1, 13, 1, 0) op_176 (v29[11:0], v32[10:0], v176[12:0]); // 15.0
    wire [11:0] v177; shift_adder #(11, 12, 1, 1, 12, 0, 0) op_177 (v34[10:0], v37[11:0], v177[11:0]); // 15.0
    wire [10:0] v178; assign v178[10:0] = v177[10:0] & {11{~v177[11]}}; // 15.0
    wire [10:0] v179; shift_adder #(11, 4, 0, 0, 11, 0, 0) op_179 (v178[10:0], 4'b1000, v179[10:0]); // 15.0
    wire [3:0] v180; assign v180[3:0] = v179[7:4]; // 15.0
    wire [8:0] v181; assign v181[8:0] = model_inp[941:933]; // 13.5
    wire [11:0] v182; shift_adder #(9, 11, 1, 1, 12, 0, 0) op_182 (v181[8:0], v40[10:0], v182[11:0]); // 15.0
    wire [11:0] v183; shift_adder #(12, 3, 1, 0, 12, 0, 0) op_183 (v182[11:0], 3'b100, v183[11:0]); // 15.0
    wire [9:0] v184; assign v184[9:0] = v183[9:0] & {10{~v183[11]}}; // 15.0
    wire [9:0] v185; shift_adder #(10, 3, 0, 0, 10, 0, 0) op_185 (v184[9:0], 3'b100, v185[9:0]); // 15.0
    wire [3:0] v186; assign v186[3:0] = v185[6:3]; // 15.0
    wire [4:0] v187; assign v187[4:0] = model_inp[946:942]; // 13.5
    wire [8:0] v188; shift_adder #(5, 9, 0, 0, 9, 0, 0) op_188 (v187[4:0], v43[8:0], v188[8:0]); // 15.0
    wire [9:0] v189; assign v189[9:0] = model_inp[956:947]; // 13.5
    wire [11:0] v190; shift_adder #(10, 11, 1, 1, 12, -1, 0) op_190 (v189[9:0], v46[10:0], v190[11:0]); // 15.0
    wire [3:0] v191; assign v191[3:0] = model_inp[960:957]; // 13.5
    wire [11:0] v192; shift_adder #(4, 12, 0, 1, 12, -1, 0) op_192 (v191[3:0], v49[11:0], v192[11:0]); // 15.0
    wire [11:0] v193; shift_adder #(12, 2, 1, 0, 12, 0, 1) op_193 (v192[11:0], 2'b10, v193[11:0]); // 15.0
    wire [10:0] v194; assign v194[10:0] = v193[10:0] & {11{~v193[11]}}; // 15.0
    wire [10:0] v195; shift_adder #(11, 3, 0, 0, 11, 0, 0) op_195 (v194[10:0], 3'b100, v195[10:0]); // 15.0
    wire [4:0] v196; assign v196[4:0] = v195[7:3]; // 15.0
    wire [10:0] v197; assign v197[10:0] = model_inp[971:961]; // 13.5
    wire [11:0] v198; shift_adder #(11, 11, 1, 1, 12, 0, 1) op_198 (v59[10:0], v197[10:0], v198[11:0]); // 15.0
    wire [10:0] v199; assign v199[10:0] = v198[10:0] & {11{~v198[11]}}; // 15.0
    wire [10:0] v200; shift_adder #(11, 3, 0, 0, 11, 0, 0) op_200 (v199[10:0], 3'b100, v200[10:0]); // 15.0
    wire [4:0] v201; assign v201[4:0] = v200[7:3]; // 15.0
    wire [11:0] v202; shift_adder #(11, 12, 1, 1, 12, 0, 0) op_202 (v62[10:0], v65[11:0], v202[11:0]); // 15.0
    wire [11:0] v203; shift_adder #(12, 3, 1, 0, 12, 0, 1) op_203 (v202[11:0], 3'b100, v203[11:0]); // 15.0
    wire [10:0] v204; assign v204[10:0] = v203[10:0] & {11{~v203[11]}}; // 15.0
    wire [10:0] v205; shift_adder #(11, 3, 0, 0, 11, 0, 0) op_205 (v204[10:0], 3'b100, v205[10:0]); // 15.0
    wire [5:0] v206; assign v206[5:0] = v205[8:3]; // 15.0
    wire [12:0] v207; shift_adder #(12, 12, 1, 1, 13, 0, 0) op_207 (v68[11:0], v71[11:0], v207[12:0]); // 15.0
    wire [12:0] v208; shift_adder #(13, 4, 1, 0, 13, 0, 1) op_208 (v207[12:0], 4'b1000, v208[12:0]); // 15.0
    wire [10:0] v209; assign v209[10:0] = v208[10:0] & {11{~v208[12]}}; // 15.0
    wire [10:0] v210; shift_adder #(11, 3, 0, 0, 11, 0, 0) op_210 (v209[10:0], 3'b100, v210[10:0]); // 15.0
    wire [5:0] v211; assign v211[5:0] = v210[8:3]; // 15.0
    wire [10:0] v212; assign v212[10:0] = model_inp[982:972]; // 13.5
    wire [12:0] v213; shift_adder #(11, 12, 1, 1, 13, 0, 0) op_213 (v212[10:0], v74[11:0], v213[12:0]); // 15.0
    wire [3:0] v214; assign v214[3:0] = model_inp[986:983]; // 13.5
    wire [10:0] v215; shift_adder #(4, 11, 0, 1, 11, -1, 0) op_215 (v214[3:0], v80[10:0], v215[10:0]); // 15.0
    wire [11:0] v216; shift_adder #(4, 12, 0, 1, 12, -1, 0) op_216 (v191[3:0], v83[11:0], v216[11:0]); // 15.0
    wire [8:0] v217; assign v217[8:0] = model_inp[995:987]; // 13.5
    wire [11:0] v218; shift_adder #(11, 9, 1, 1, 12, 2, 1) op_218 (v94[10:0], v217[8:0], v218[11:0]); // 15.0
    wire [10:0] v219; assign v219[10:0] = model_inp[1006:996]; // 13.5
    wire [12:0] v220; shift_adder #(11, 11, 1, 1, 13, 1, 0) op_220 (v219[10:0], v97[10:0], v220[12:0]); // 15.0
    wire [3:0] v221; assign v221[3:0] = model_inp[1010:1007]; // 13.5
    wire [8:0] v222; shift_adder #(4, 9, 0, 1, 9, -1, 1) op_222 (v221[3:0], v100[8:0], v222[8:0]); // 15.0
    wire [8:0] v223; assign v223[8:0] = model_inp[1019:1011]; // 13.5
    wire [11:0] v224; shift_adder #(9, 10, 0, 1, 12, -1, 0) op_224 (v223[8:0], v111[9:0], v224[11:0]); // 15.0
    wire [10:0] v225; assign v225[10:0] = model_inp[1030:1020]; // 13.5
    wire [10:0] v226; shift_adder #(11, 8, 1, 1, 11, 1, 0) op_226 (v225[10:0], v77[7:0], v226[10:0]); // 15.0
    wire [9:0] v227; assign v227[9:0] = model_inp[1040:1031]; // 13.5
    wire [12:0] v228; shift_adder #(13, 10, 1, 0, 13, 0, 1) op_228 (v117[12:0], v227[9:0], v228[12:0]); // 15.0
    wire [12:0] v229; shift_adder #(13, 5, 1, 0, 13, 0, 1) op_229 (v228[12:0], 5'b10000, v229[12:0]); // 15.0
    wire [11:0] v230; assign v230[11:0] = v229[11:0] & {12{~v229[12]}}; // 15.0
    wire [11:0] v231; shift_adder #(12, 4, 0, 0, 12, 0, 0) op_231 (v230[11:0], 4'b1000, v231[11:0]); // 15.0
    wire [4:0] v232; assign v232[4:0] = v231[8:4]; // 15.0
    wire [10:0] v233; assign v233[10:0] = model_inp[1051:1041]; // 13.5
    wire [12:0] v234; shift_adder #(12, 11, 1, 1, 13, 1, 1) op_234 (v120[11:0], v233[10:0], v234[12:0]); // 15.0
    wire [11:0] v235; shift_adder #(12, 11, 1, 1, 12, 0, 1) op_235 (v123[11:0], v126[10:0], v235[11:0]); // 15.0
    wire [11:0] v236; shift_adder #(12, 3, 1, 0, 12, 0, 1) op_236 (v235[11:0], 3'b100, v236[11:0]); // 15.0
    wire [10:0] v237; assign v237[10:0] = v236[10:0] & {11{~v236[11]}}; // 15.0
    wire [10:0] v238; shift_adder #(11, 4, 0, 0, 11, 0, 0) op_238 (v237[10:0], 4'b1000, v238[10:0]); // 15.0
    wire [4:0] v239; assign v239[4:0] = v238[8:4]; // 15.0
    wire [10:0] v240; assign v240[10:0] = model_inp[1062:1052]; // 13.5
    wire [11:0] v241; shift_adder #(11, 11, 1, 1, 12, 0, 0) op_241 (v240[10:0], v129[10:0], v241[11:0]); // 15.0
    wire [11:0] v242; shift_adder #(12, 4, 1, 0, 12, 0, 1) op_242 (v241[11:0], 4'b1000, v242[11:0]); // 15.0
    wire [9:0] v243; assign v243[9:0] = v242[9:0] & {10{~v242[11]}}; // 15.0
    wire [9:0] v244; shift_adder #(10, 3, 0, 0, 10, 0, 0) op_244 (v243[9:0], 3'b100, v244[9:0]); // 15.0
    wire [4:0] v245; assign v245[4:0] = v244[7:3]; // 15.0
    wire [9:0] v246; assign v246[9:0] = model_inp[1072:1063]; // 13.5
    wire [10:0] v247; shift_adder #(10, 11, 1, 1, 11, 0, 0) op_247 (v246[9:0], v132[10:0], v247[10:0]); // 15.0
    wire [10:0] v248; assign v248[10:0] = model_inp[1083:1073]; // 13.5
    wire [10:0] v249; shift_adder #(11, 11, 1, 1, 11, 0, 0) op_249 (v248[10:0], v135[10:0], v249[10:0]); // 15.0
    wire [10:0] v250; shift_adder #(11, 4, 1, 0, 11, 0, 1) op_250 (v249[10:0], 4'b1000, v250[10:0]); // 15.0
    wire [9:0] v251; assign v251[9:0] = v250[9:0] & {10{~v250[10]}}; // 15.0
    wire [9:0] v252; shift_adder #(10, 3, 0, 0, 10, 0, 0) op_252 (v251[9:0], 3'b100, v252[9:0]); // 15.0
    wire [4:0] v253; assign v253[4:0] = v252[7:3]; // 15.0
    wire [10:0] v254; assign v254[10:0] = v216[10:0] & {11{~v216[11]}}; // 15.0
    wire [10:0] v255; shift_adder #(11, 4, 0, 0, 11, 0, 0) op_255 (v254[10:0], 4'b1000, v255[10:0]); // 15.0
    wire [4:0] v256; assign v256[4:0] = v255[8:4]; // 15.0
    wire [7:0] v257; shift_adder #(5, 5, 0, 0, 8, -2, 1) op_257 (v12[4:0], v12[4:0], v257[7:0]); // 15.0
    wire [5:0] v258; shift_adder #(5, 4, 0, 0, 6, 1, 0) op_258 (v138[4:0], v56[3:0], v258[5:0]); // 15.0
    wire [10:0] v259; assign v259[10:0] = model_inp[1094:1084]; // 13.5
    wire [11:0] v260; shift_adder #(11, 11, 1, 1, 12, 1, 0) op_260 (v259[10:0], v141[10:0], v260[11:0]); // 15.0
    wire [11:0] v261; shift_adder #(12, 4, 1, 0, 12, 0, 1) op_261 (v260[11:0], 4'b1100, v261[11:0]); // 15.0
    wire [10:0] v262; assign v262[10:0] = v261[10:0] & {11{~v261[11]}}; // 15.0
    wire [10:0] v263; shift_adder #(11, 3, 0, 0, 11, 0, 0) op_263 (v262[10:0], 3'b100, v263[10:0]); // 15.0
    wire [5:0] v264; assign v264[5:0] = v263[8:3]; // 15.0
    wire [11:0] v265; assign v265[11:0] = model_inp[1106:1095]; // 13.5
    wire [11:0] v266; shift_adder #(12, 11, 1, 1, 12, 0, 0) op_266 (v265[11:0], v144[10:0], v266[11:0]); // 15.0
    wire [11:0] v267; shift_adder #(12, 9, 1, 0, 12, 0, 1) op_267 (v147[11:0], v64[8:0], v267[11:0]); // 15.0
    wire [3:0] v268; assign v268[3:0] = model_inp[1110:1107]; // 13.5
    wire [10:0] v269; shift_adder #(4, 11, 0, 1, 11, -1, 0) op_269 (v268[3:0], v150[10:0], v269[10:0]); // 15.0
    wire [9:0] v270; assign v270[9:0] = model_inp[1120:1111]; // 13.5
    wire [11:0] v271; shift_adder #(11, 10, 1, 1, 12, -1, 1) op_271 (v155[10:0], v270[9:0], v271[11:0]); // 15.0
    wire [6:0] v272; shift_adder #(4, 4, 0, 0, 7, 2, 1) op_272 (v88[3:0], v159[3:0], v272[6:0]); // 15.0
    wire [7:0] v273; shift_adder #(5, 4, 1, 0, 8, -2, 1) op_273 (v161[4:0], v106[3:0], v273[7:0]); // 15.0
    wire [2:0] v274; assign v274[2:0] = model_inp[1123:1121]; // 13.5
    wire [4:0] v275; shift_adder #(3, 4, 0, 0, 5, -1, 1) op_275 (v274[2:0], v56[3:0], v275[4:0]); // 15.0
    wire [6:0] v276; shift_adder #(4, 5, 0, 0, 7, 1, 0) op_276 (v156[3:0], v12[4:0], v276[6:0]); // 15.0
    wire [5:0] v277; shift_adder #(5, 4, 0, 0, 6, 1, 0) op_277 (v12[4:0], v88[3:0], v277[5:0]); // 15.0
    wire [2:0] v278; assign v278[2:0] = model_inp[1126:1124]; // 13.5
    wire [7:0] v279; assign v279[7:0] = model_inp[1134:1127]; // 13.5
    wire [8:0] v280; assign v280[8:0] = model_inp[1143:1135]; // 13.5
    wire [3:0] v281; assign v281[3:0] = model_inp[1147:1144]; // 13.5
    wire [8:0] v282; assign v282[8:0] = model_inp[1156:1148]; // 13.5
    wire [5:0] v283; assign v283[5:0] = model_inp[1162:1157]; // 13.5
    wire [0:0] v284; assign v284[0:0] = model_inp[1163:1163]; // 13.5
    wire [4:0] v285; assign v285[4:0] = model_inp[1168:1164]; // 13.5
    wire [4:0] v286; assign v286[4:0] = model_inp[1173:1169]; // 13.5
    wire [3:0] v287; assign v287[3:0] = model_inp[1177:1174]; // 13.5

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[10:0] = v2[10:0];
    assign model_out[22:11] = v165[11:0];
    assign model_out[34:23] = v167[11:0];
    assign model_out[43:35] = v181[8:0];
    assign model_out[56:44] = v176[12:0];
    assign model_out[60:57] = v180[3:0];
    assign model_out[64:61] = v186[3:0];
    assign model_out[73:65] = v188[8:0];
    assign model_out[85:74] = v190[11:0];
    assign model_out[90:86] = v196[4:0];
    assign model_out[95:91] = v201[4:0];
    assign model_out[101:96] = v206[5:0];
    assign model_out[114:102] = v213[12:0];
    assign model_out[122:115] = v77[7:0];
    assign model_out[125:123] = v278[2:0];
    assign model_out[136:126] = v215[10:0];
    assign model_out[148:137] = v91[11:0];
    assign model_out[160:149] = v218[11:0];
    assign model_out[173:161] = v220[12:0];
    assign model_out[182:174] = v222[8:0];
    assign model_out[195:183] = v109[12:0];
    assign model_out[207:196] = v224[11:0];
    assign model_out[215:208] = v279[7:0];
    assign model_out[227:216] = v114[11:0];
    assign model_out[238:228] = v226[10:0];
    assign model_out[251:239] = v234[12:0];
    assign model_out[255:252] = v56[3:0];
    assign model_out[259:256] = v175[3:0];
    assign model_out[263:260] = v156[3:0];
    assign model_out[268:264] = v239[4:0];
    assign model_out[277:269] = v280[8:0];
    assign model_out[288:278] = v247[10:0];
    assign model_out[293:289] = v253[4:0];
    assign model_out[298:294] = v256[4:0];
    assign model_out[306:299] = v257[7:0];
    assign model_out[312:307] = v258[5:0];
    assign model_out[318:313] = v264[5:0];
    assign model_out[322:319] = v191[3:0];
    assign model_out[334:323] = v266[11:0];
    assign model_out[346:335] = v267[11:0];
    assign model_out[357:347] = v269[10:0];
    assign model_out[362:358] = v232[4:0];
    assign model_out[374:363] = v153[11:0];
    assign model_out[386:375] = v271[11:0];
    assign model_out[390:387] = v281[3:0];
    assign model_out[393:391] = v274[2:0];
    assign model_out[397:394] = v106[3:0];
    assign model_out[404:398] = v272[6:0];
    assign model_out[407:405] = v162[2:0];
    assign model_out[414:408] = v158[6:0];
    assign model_out[418:415] = v159[3:0];
    assign model_out[423:419] = v245[4:0];
    assign model_out[431:424] = v273[7:0];
    assign model_out[435:432] = v171[3:0];
    assign model_out[442:436] = v276[6:0];
    assign model_out[448:443] = v277[5:0];
    assign model_out[454:449] = v211[5:0];
    assign model_out[458:455] = v88[3:0];
    assign model_out[462:459] = v163[3:0];
    assign model_out[467:463] = v12[4:0];
    assign model_out[476:468] = v282[8:0];
    assign model_out[482:477] = v283[5:0];
    assign model_out[483:483] = v284[0:0];
    assign model_out[486:484] = v136[2:0];
    assign model_out[489:487] = v137[2:0];
    assign model_out[494:490] = v275[4:0];
    assign model_out[506:495] = v216[11:0];
    assign model_out[511:507] = v285[4:0];
    assign model_out[516:512] = v286[4:0];
    assign model_out[520:517] = v160[3:0];
    assign model_out[524:521] = v287[3:0];
    assign model_out[528:525] = v221[3:0];

endmodule
