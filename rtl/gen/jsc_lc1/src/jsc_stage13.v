`timescale 1 ns / 1 ps

module jsc_stage13 (
    input [1085:0] model_inp,
    output [1144:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [7:0] v0; assign v0[7:0] = model_inp[7:0]; // 13.0
    wire [9:0] v1; assign v1[9:0] = model_inp[17:8]; // 13.0
    wire [10:0] v2; shift_adder #(8, 10, 1, 1, 11, -2, 0) op_2 (v0[7:0], v1[9:0], v2[10:0]); // 14.0
    wire [10:0] v3; assign v3[10:0] = model_inp[28:18]; // 13.0
    wire [6:0] v4; assign v4[6:0] = model_inp[35:29]; // 13.0
    wire [12:0] v5; shift_adder #(11, 7, 1, 1, 13, -2, 1) op_5 (v3[10:0], v4[6:0], v5[12:0]); // 14.0
    wire [7:0] v6; assign v6[7:0] = model_inp[43:36]; // 13.0
    wire [6:0] v7; assign v7[6:0] = model_inp[50:44]; // 13.0
    wire [10:0] v8; shift_adder #(8, 7, 0, 1, 11, -1, 0) op_8 (v6[7:0], v7[6:0], v8[10:0]); // 14.0
    wire [9:0] v9; assign v9[9:0] = model_inp[60:51]; // 13.0
    wire [5:0] v10; assign v10[5:0] = model_inp[66:61]; // 13.0
    wire [10:0] v11; shift_adder #(10, 6, 0, 0, 11, 1, 1) op_11 (v9[9:0], v10[5:0], v11[10:0]); // 14.0
    wire [7:0] v12; assign v12[7:0] = model_inp[74:67]; // 13.0
    wire [8:0] v13; assign v13[8:0] = model_inp[83:75]; // 13.0
    wire [9:0] v14; shift_adder #(8, 9, 1, 1, 10, 0, 0) op_14 (v12[7:0], v13[8:0], v14[9:0]); // 14.0
    wire [10:0] v15; shift_adder #(8, 8, 0, 1, 11, -1, 1) op_15 (v6[7:0], v0[7:0], v15[10:0]); // 14.0
    wire [3:0] v16; assign v16[3:0] = model_inp[87:84]; // 13.0
    wire [8:0] v17; assign v17[8:0] = model_inp[96:88]; // 13.0
    wire [10:0] v18; shift_adder #(4, 9, 0, 0, 11, 1, 1) op_18 (v16[3:0], v17[8:0], v18[10:0]); // 14.0
    wire [7:0] v19; assign v19[7:0] = model_inp[104:97]; // 13.0
    wire [10:0] v20; assign v20[10:0] = model_inp[115:105]; // 13.0
    wire [10:0] v21; shift_adder #(8, 11, 1, 1, 11, -1, 0) op_21 (v19[7:0], v20[10:0], v21[10:0]); // 14.0
    wire [8:0] v22; assign v22[8:0] = model_inp[124:116]; // 13.0
    wire [8:0] v23; assign v23[8:0] = model_inp[133:125]; // 13.0
    wire [12:0] v24; shift_adder #(9, 9, 1, 1, 13, -3, 1) op_24 (v22[8:0], v23[8:0], v24[12:0]); // 14.0
    wire [7:0] v25; assign v25[7:0] = model_inp[141:134]; // 13.0
    wire [8:0] v26; shift_adder #(6, 8, 0, 1, 9, -1, 0) op_26 (v10[5:0], v25[7:0], v26[8:0]); // 14.0
    wire [8:0] v27; assign v27[8:0] = model_inp[150:142]; // 13.0
    wire [6:0] v28; assign v28[6:0] = model_inp[157:151]; // 13.0
    wire [9:0] v29; shift_adder #(9, 7, 1, 0, 10, 0, 1) op_29 (v27[8:0], v28[6:0], v29[9:0]); // 14.0
    wire [9:0] v30; shift_adder #(10, 3, 1, 0, 10, 0, 0) op_30 (v29[9:0], 3'b100, v30[9:0]); // 14.0
    wire [6:0] v31; assign v31[6:0] = v30[6:0] & {7{~v30[9]}}; // 14.0
    wire [7:0] v32; shift_adder #(7, 2, 0, 0, 8, 0, 0) op_32 (v31[6:0], 2'b10, v32[7:0]); // 14.0
    wire [4:0] v33; assign v33[4:0] = v32[6:2]; // 14.0
    wire [8:0] v34; assign v34[8:0] = model_inp[166:158]; // 13.0
    wire [10:0] v35; assign v35[10:0] = model_inp[177:167]; // 13.0
    wire [12:0] v36; shift_adder #(9, 11, 1, 1, 13, -3, 1) op_36 (v34[8:0], v35[10:0], v36[12:0]); // 14.0
    wire [6:0] v37; assign v37[6:0] = model_inp[184:178]; // 13.0
    wire [8:0] v38; assign v38[8:0] = model_inp[193:185]; // 13.0
    wire [9:0] v39; shift_adder #(7, 9, 0, 0, 10, -2, 0) op_39 (v37[6:0], v38[8:0], v39[9:0]); // 14.0
    wire [6:0] v40; assign v40[6:0] = model_inp[200:194]; // 13.0
    wire [6:0] v41; assign v41[6:0] = model_inp[207:201]; // 13.0
    wire [7:0] v42; shift_adder #(7, 7, 0, 0, 8, 0, 1) op_42 (v40[6:0], v41[6:0], v42[7:0]); // 14.0
    wire [7:0] v43; assign v43[7:0] = model_inp[215:208]; // 13.0
    wire [5:0] v44; assign v44[5:0] = model_inp[221:216]; // 13.0
    wire [8:0] v45; shift_adder #(8, 6, 0, 0, 9, 1, 0) op_45 (v43[7:0], v44[5:0], v45[8:0]); // 14.0
    wire [9:0] v46; assign v46[9:0] = model_inp[231:222]; // 13.0
    wire [10:0] v47; shift_adder #(10, 10, 1, 1, 11, 0, 0) op_47 (v46[9:0], v1[9:0], v47[10:0]); // 14.0
    wire [8:0] v48; assign v48[8:0] = model_inp[240:232]; // 13.0
    wire [9:0] v49; assign v49[9:0] = model_inp[250:241]; // 13.0
    wire [10:0] v50; shift_adder #(9, 10, 1, 1, 11, 0, 0) op_50 (v48[8:0], v49[9:0], v50[10:0]); // 14.0
    wire [8:0] v51; assign v51[8:0] = model_inp[259:251]; // 13.0
    wire [6:0] v52; assign v52[6:0] = model_inp[266:260]; // 13.0
    wire [9:0] v53; shift_adder #(9, 7, 0, 0, 10, 1, 1) op_53 (v51[8:0], v52[6:0], v53[9:0]); // 14.0
    wire [5:0] v54; assign v54[5:0] = model_inp[272:267]; // 13.0
    wire [6:0] v55; assign v55[6:0] = model_inp[279:273]; // 13.0
    wire [8:0] v56; shift_adder #(6, 7, 0, 1, 9, 1, 0) op_56 (v54[5:0], v55[6:0], v56[8:0]); // 14.0
    wire [8:0] v57; assign v57[8:0] = model_inp[288:280]; // 13.0
    wire [8:0] v58; assign v58[8:0] = model_inp[297:289]; // 13.0
    wire [11:0] v59; shift_adder #(9, 9, 1, 0, 12, 1, 0) op_59 (v57[8:0], v58[8:0], v59[11:0]); // 14.0
    wire [9:0] v60; assign v60[9:0] = model_inp[307:298]; // 13.0
    wire [8:0] v61; assign v61[8:0] = model_inp[316:308]; // 13.0
    wire [10:0] v62; shift_adder #(10, 9, 1, 1, 11, -1, 0) op_62 (v60[9:0], v61[8:0], v62[10:0]); // 14.0
    wire [4:0] v63; assign v63[4:0] = model_inp[321:317]; // 13.0
    wire [7:0] v64; assign v64[7:0] = model_inp[329:322]; // 13.0
    wire [8:0] v65; shift_adder #(5, 8, 0, 0, 9, -2, 0) op_65 (v63[4:0], v64[7:0], v65[8:0]); // 14.0
    wire [8:0] v66; assign v66[8:0] = model_inp[338:330]; // 13.0
    wire [9:0] v67; assign v67[9:0] = model_inp[348:339]; // 13.0
    wire [11:0] v68; shift_adder #(9, 10, 0, 0, 12, 1, 1) op_68 (v66[8:0], v67[9:0], v68[11:0]); // 14.0
    wire [2:0] v69; assign v69[2:0] = model_inp[351:349]; // 13.0
    wire [6:0] v70; assign v70[6:0] = model_inp[358:352]; // 13.0
    wire [7:0] v71; shift_adder #(3, 7, 0, 1, 8, 0, 1) op_71 (v69[2:0], v70[6:0], v71[7:0]); // 14.0
    wire [7:0] v72; assign v72[7:0] = model_inp[366:359]; // 13.0
    wire [5:0] v73; assign v73[5:0] = model_inp[372:367]; // 13.0
    wire [9:0] v74; shift_adder #(8, 6, 1, 0, 10, 2, 1) op_74 (v72[7:0], v73[5:0], v74[9:0]); // 14.0
    wire [6:0] v75; assign v75[6:0] = model_inp[379:373]; // 13.0
    wire [9:0] v76; assign v76[9:0] = model_inp[389:380]; // 13.0
    wire [11:0] v77; shift_adder #(7, 10, 1, 0, 12, -3, 0) op_77 (v75[6:0], v76[9:0], v77[11:0]); // 14.0
    wire [5:0] v78; assign v78[5:0] = model_inp[395:390]; // 13.0
    wire [10:0] v79; shift_adder #(10, 6, 1, 1, 11, 2, 0) op_79 (v1[9:0], v78[5:0], v79[10:0]); // 14.0
    wire [8:0] v80; shift_adder #(7, 9, 0, 0, 9, 0, 0) op_80 (v37[6:0], v51[8:0], v80[8:0]); // 14.0
    wire [6:0] v81; assign v81[6:0] = model_inp[402:396]; // 13.0
    wire [10:0] v82; shift_adder #(7, 10, 0, 1, 11, -2, 0) op_82 (v81[6:0], v49[9:0], v82[10:0]); // 14.0
    wire [7:0] v83; assign v83[7:0] = model_inp[410:403]; // 13.0
    wire [6:0] v84; assign v84[6:0] = model_inp[417:411]; // 13.0
    wire [10:0] v85; shift_adder #(8, 7, 0, 1, 11, -1, 0) op_85 (v83[7:0], v84[6:0], v85[10:0]); // 14.0
    wire [5:0] v86; assign v86[5:0] = model_inp[423:418]; // 13.0
    wire [9:0] v87; assign v87[9:0] = model_inp[433:424]; // 13.0
    wire [10:0] v88; shift_adder #(6, 10, 0, 0, 11, -4, 1) op_88 (v86[5:0], v87[9:0], v88[10:0]); // 14.0
    wire [9:0] v89; assign v89[9:0] = model_inp[443:434]; // 13.0
    wire [11:0] v90; shift_adder #(11, 10, 1, 1, 12, 1, 0) op_90 (v35[10:0], v89[9:0], v90[11:0]); // 14.0
    wire [8:0] v91; assign v91[8:0] = model_inp[452:444]; // 13.0
    wire [10:0] v92; assign v92[10:0] = model_inp[463:453]; // 13.0
    wire [11:0] v93; shift_adder #(9, 11, 1, 1, 12, -1, 0) op_93 (v91[8:0], v92[10:0], v93[11:0]); // 14.0
    wire [12:0] v94; assign v94[12:0] = model_inp[476:464]; // 13.0
    wire [13:0] v95; shift_adder #(13, 7, 1, 1, 14, 0, 1) op_95 (v94[12:0], v4[6:0], v95[13:0]); // 14.0
    wire [10:0] v96; shift_adder #(8, 8, 1, 0, 11, -2, 0) op_96 (v19[7:0], v6[7:0], v96[10:0]); // 14.0
    wire [4:0] v97; assign v97[4:0] = model_inp[481:477]; // 13.0
    wire [8:0] v98; shift_adder #(5, 8, 0, 0, 9, 0, 1) op_98 (v97[4:0], v64[7:0], v98[8:0]); // 14.0
    wire [6:0] v99; assign v99[6:0] = model_inp[488:482]; // 13.0
    wire [10:0] v100; shift_adder #(7, 7, 1, 1, 11, 3, 0) op_100 (v4[6:0], v99[6:0], v100[10:0]); // 14.0
    wire [6:0] v101; assign v101[6:0] = model_inp[495:489]; // 13.0
    wire [6:0] v102; shift_adder #(4, 7, 0, 1, 7, -1, 0) op_102 (v16[3:0], v101[6:0], v102[6:0]); // 14.0
    wire [8:0] v103; assign v103[8:0] = model_inp[504:496]; // 13.0
    wire [10:0] v104; shift_adder #(9, 7, 1, 0, 11, 3, 1) op_104 (v103[8:0], v81[6:0], v104[10:0]); // 14.0
    wire [8:0] v105; assign v105[8:0] = model_inp[513:505]; // 13.0
    wire [12:0] v106; shift_adder #(10, 9, 0, 1, 13, 3, 0) op_106 (v9[9:0], v105[8:0], v106[12:0]); // 14.0
    wire [8:0] v107; assign v107[8:0] = model_inp[522:514]; // 13.0
    wire [10:0] v108; shift_adder #(7, 9, 1, 0, 11, -2, 0) op_108 (v7[6:0], v107[8:0], v108[10:0]); // 14.0
    wire [9:0] v109; assign v109[9:0] = model_inp[532:523]; // 13.0
    wire [7:0] v110; assign v110[7:0] = model_inp[540:533]; // 13.0
    wire [10:0] v111; shift_adder #(10, 8, 1, 0, 11, -1, 1) op_111 (v109[9:0], v110[7:0], v111[10:0]); // 14.0
    wire [8:0] v112; assign v112[8:0] = model_inp[549:541]; // 13.0
    wire [9:0] v113; shift_adder #(9, 9, 0, 1, 10, 0, 0) op_113 (v66[8:0], v112[8:0], v113[9:0]); // 14.0
    wire [8:0] v114; assign v114[8:0] = model_inp[558:550]; // 13.0
    wire [9:0] v115; assign v115[9:0] = model_inp[568:559]; // 13.0
    wire [10:0] v116; shift_adder #(9, 10, 1, 1, 11, 1, 0) op_116 (v114[8:0], v115[9:0], v116[10:0]); // 14.0
    wire [10:0] v117; shift_adder #(9, 7, 0, 1, 11, 2, 0) op_117 (v66[8:0], v55[6:0], v117[10:0]); // 14.0
    wire [12:0] v118; shift_adder #(9, 10, 0, 1, 13, -3, 1) op_118 (v38[8:0], v89[9:0], v118[12:0]); // 14.0
    wire [13:0] v119; assign v119[13:0] = model_inp[582:569]; // 13.0
    wire [14:0] v120; shift_adder #(14, 10, 1, 0, 15, 2, 0) op_120 (v119[13:0], v9[9:0], v120[14:0]); // 14.0
    wire [8:0] v121; assign v121[8:0] = model_inp[591:583]; // 13.0
    wire [9:0] v122; shift_adder #(7, 9, 0, 1, 10, -1, 0) op_122 (v81[6:0], v121[8:0], v122[9:0]); // 14.0
    wire [11:0] v123; assign v123[11:0] = model_inp[603:592]; // 13.0
    wire [5:0] v124; assign v124[5:0] = model_inp[609:604]; // 13.0
    wire [11:0] v125; shift_adder #(12, 6, 1, 0, 12, 2, 1) op_125 (v123[11:0], v124[5:0], v125[11:0]); // 14.0
    wire [10:0] v126; assign v126[10:0] = model_inp[620:610]; // 13.0
    wire [10:0] v127; shift_adder #(11, 9, 1, 1, 11, 1, 0) op_127 (v126[10:0], v61[8:0], v127[10:0]); // 14.0
    wire [9:0] v128; assign v128[9:0] = model_inp[630:621]; // 13.0
    wire [10:0] v129; shift_adder #(10, 9, 1, 0, 11, -1, 0) op_129 (v128[9:0], v38[8:0], v129[10:0]); // 14.0
    wire [4:0] v130; assign v130[4:0] = model_inp[635:631]; // 13.0
    wire [7:0] v131; shift_adder #(5, 7, 0, 1, 8, -1, 0) op_131 (v130[4:0], v55[6:0], v131[7:0]); // 14.0
    wire [7:0] v132; assign v132[7:0] = model_inp[643:636]; // 13.0
    wire [9:0] v133; assign v133[9:0] = model_inp[653:644]; // 13.0
    wire [10:0] v134; shift_adder #(8, 10, 1, 1, 11, -1, 0) op_134 (v132[7:0], v133[9:0], v134[10:0]); // 14.0
    wire [9:0] v135; assign v135[9:0] = model_inp[663:654]; // 13.0
    wire [12:0] v136; shift_adder #(10, 9, 1, 1, 13, -3, 1) op_136 (v135[9:0], v114[8:0], v136[12:0]); // 14.0
    wire [4:0] v137; assign v137[4:0] = model_inp[668:664]; // 13.0
    wire [10:0] v138; assign v138[10:0] = model_inp[679:669]; // 13.0
    wire [10:0] v139; shift_adder #(5, 11, 0, 1, 11, -1, 0) op_139 (v137[4:0], v138[10:0], v139[10:0]); // 14.0
    wire [7:0] v140; assign v140[7:0] = model_inp[687:680]; // 13.0
    wire [11:0] v141; shift_adder #(8, 8, 1, 0, 12, 2, 1) op_141 (v25[7:0], v140[7:0], v141[11:0]); // 14.0
    wire [10:0] v142; assign v142[10:0] = model_inp[698:688]; // 13.0
    wire [7:0] v143; assign v143[7:0] = model_inp[706:699]; // 13.0
    wire [11:0] v144; shift_adder #(11, 8, 1, 0, 12, 1, 0) op_144 (v142[10:0], v143[7:0], v144[11:0]); // 14.0
    wire [13:0] v145; assign v145[13:0] = model_inp[720:707]; // 13.0
    wire [5:0] v146; assign v146[5:0] = model_inp[726:721]; // 13.0
    wire [13:0] v147; shift_adder #(14, 6, 1, 0, 14, 2, 1) op_147 (v145[13:0], v146[5:0], v147[13:0]); // 14.0
    wire [10:0] v148; assign v148[10:0] = model_inp[737:727]; // 13.0
    wire [11:0] v149; shift_adder #(11, 10, 0, 1, 12, 1, 0) op_149 (v148[10:0], v128[9:0], v149[11:0]); // 14.0
    wire [8:0] v150; assign v150[8:0] = model_inp[746:738]; // 13.0
    wire [9:0] v151; assign v151[9:0] = model_inp[756:747]; // 13.0
    wire [10:0] v152; shift_adder #(9, 10, 1, 1, 11, 1, 0) op_152 (v150[8:0], v151[9:0], v152[10:0]); // 14.0
    wire [10:0] v153; shift_adder #(8, 6, 1, 0, 11, 3, 1) op_153 (v19[7:0], v10[5:0], v153[10:0]); // 14.0
    wire [8:0] v154; assign v154[8:0] = model_inp[765:757]; // 13.0
    wire [10:0] v155; shift_adder #(8, 9, 0, 1, 11, -1, 0) op_155 (v143[7:0], v154[8:0], v155[10:0]); // 14.0
    wire [10:0] v156; assign v156[10:0] = model_inp[776:766]; // 13.0
    wire [7:0] v157; assign v157[7:0] = model_inp[784:777]; // 13.0
    wire [11:0] v158; shift_adder #(11, 8, 1, 0, 12, -1, 1) op_158 (v156[10:0], v157[7:0], v158[11:0]); // 14.0
    wire [10:0] v159; shift_adder #(10, 6, 1, 1, 11, 0, 1) op_159 (v46[9:0], v78[5:0], v159[10:0]); // 14.0
    wire [7:0] v160; shift_adder #(5, 8, 0, 1, 8, -1, 1) op_160 (v63[4:0], v25[7:0], v160[7:0]); // 14.0
    wire [11:0] v161; assign v161[11:0] = model_inp[796:785]; // 13.0
    wire [12:0] v162; shift_adder #(9, 12, 0, 1, 13, -2, 0) op_162 (v51[8:0], v161[11:0], v162[12:0]); // 14.0
    wire [9:0] v163; assign v163[9:0] = model_inp[806:797]; // 13.0
    wire [10:0] v164; shift_adder #(10, 7, 1, 1, 11, -1, 1) op_164 (v163[9:0], v84[6:0], v164[10:0]); // 14.0
    wire [8:0] v165; assign v165[8:0] = model_inp[815:807]; // 13.0
    wire [10:0] v166; assign v166[10:0] = model_inp[826:816]; // 13.0
    wire [11:0] v167; shift_adder #(9, 11, 1, 0, 12, 0, 1) op_167 (v165[8:0], v166[10:0], v167[11:0]); // 14.0
    wire [4:0] v168; assign v168[4:0] = model_inp[831:827]; // 13.0
    wire [9:0] v169; assign v169[9:0] = model_inp[841:832]; // 13.0
    wire [9:0] v170; shift_adder #(5, 10, 0, 1, 10, -3, 1) op_170 (v168[4:0], v169[9:0], v170[9:0]); // 14.0
    wire [11:0] v171; assign v171[11:0] = model_inp[853:842]; // 13.0
    wire [12:0] v172; shift_adder #(6, 12, 1, 1, 13, -1, 0) op_172 (v78[5:0], v171[11:0], v172[12:0]); // 14.0
    wire [10:0] v173; assign v173[10:0] = model_inp[864:854]; // 13.0
    wire [11:0] v174; shift_adder #(11, 9, 0, 1, 12, 0, 0) op_174 (v173[10:0], v112[8:0], v174[11:0]); // 14.0
    wire [8:0] v175; assign v175[8:0] = model_inp[873:865]; // 13.0
    wire [14:0] v176; assign v176[14:0] = model_inp[888:874]; // 13.0
    wire [14:0] v177; shift_adder #(9, 15, 1, 1, 15, -4, 0) op_177 (v175[8:0], v176[14:0], v177[14:0]); // 14.0
    wire [9:0] v178; assign v178[9:0] = model_inp[898:889]; // 13.0
    wire [12:0] v179; shift_adder #(10, 10, 1, 1, 13, 3, 0) op_179 (v1[9:0], v178[9:0], v179[12:0]); // 14.0
    wire [7:0] v180; assign v180[7:0] = model_inp[906:899]; // 13.0
    wire [10:0] v181; shift_adder #(9, 8, 1, 1, 11, 2, 0) op_181 (v150[8:0], v180[7:0], v181[10:0]); // 14.0
    wire [8:0] v182; assign v182[8:0] = model_inp[915:907]; // 13.0
    wire [10:0] v183; shift_adder #(9, 10, 0, 1, 11, -1, 1) op_183 (v182[8:0], v1[9:0], v183[10:0]); // 14.0
    wire [6:0] v184; assign v184[6:0] = model_inp[922:916]; // 13.0
    wire [7:0] v185; shift_adder #(7, 7, 1, 1, 8, 0, 1) op_185 (v101[6:0], v184[6:0], v185[7:0]); // 14.0
    wire [8:0] v186; assign v186[8:0] = model_inp[931:923]; // 13.0
    wire [7:0] v187; assign v187[7:0] = model_inp[939:932]; // 13.0
    wire [9:0] v188; shift_adder #(9, 8, 1, 0, 10, 1, 0) op_188 (v186[8:0], v187[7:0], v188[9:0]); // 14.0
    wire [10:0] v189; assign v189[10:0] = model_inp[950:940]; // 13.0
    wire [10:0] v190; shift_adder #(9, 11, 1, 1, 11, -1, 0) op_190 (v112[8:0], v189[10:0], v190[10:0]); // 14.0
    wire [11:0] v191; shift_adder #(8, 8, 1, 0, 12, 2, 1) op_191 (v25[7:0], v157[7:0], v191[11:0]); // 14.0
    wire [11:0] v192; shift_adder #(9, 5, 1, 0, 12, 5, 1) op_192 (v112[8:0], v130[4:0], v192[11:0]); // 14.0
    wire [7:0] v193; assign v193[7:0] = model_inp[958:951]; // 13.0
    wire [11:0] v194; shift_adder #(8, 10, 1, 0, 12, 1, 1) op_194 (v193[7:0], v67[9:0], v194[11:0]); // 14.0
    wire [7:0] v195; assign v195[7:0] = model_inp[966:959]; // 13.0
    wire [9:0] v196; shift_adder #(8, 9, 1, 1, 10, -1, 1) op_196 (v195[7:0], v154[8:0], v196[9:0]); // 14.0
    wire [8:0] v197; assign v197[8:0] = model_inp[975:967]; // 13.0
    wire [10:0] v198; shift_adder #(9, 9, 1, 1, 11, 1, 1) op_198 (v197[8:0], v103[8:0], v198[10:0]); // 14.0
    wire [8:0] v199; assign v199[8:0] = model_inp[984:976]; // 13.0
    wire [10:0] v200; shift_adder #(7, 9, 1, 0, 11, -2, 0) op_200 (v70[6:0], v199[8:0], v200[10:0]); // 14.0
    wire [7:0] v201; assign v201[7:0] = model_inp[992:985]; // 13.0
    wire [9:0] v202; shift_adder #(8, 8, 1, 0, 10, 0, 0) op_202 (v201[7:0], v187[7:0], v202[9:0]); // 14.0
    wire [10:0] v203; shift_adder #(10, 6, 0, 0, 11, 0, 1) op_203 (v76[9:0], v146[5:0], v203[10:0]); // 14.0
    wire [8:0] v204; assign v204[8:0] = model_inp[1001:993]; // 13.0
    wire [9:0] v205; assign v205[9:0] = model_inp[1011:1002]; // 13.0
    wire [11:0] v206; shift_adder #(9, 10, 0, 1, 12, -1, 0) op_206 (v204[8:0], v205[9:0], v206[11:0]); // 14.0
    wire [2:0] v207; assign v207[2:0] = model_inp[1014:1012]; // 13.0
    wire [8:0] v208; assign v208[8:0] = model_inp[1023:1015]; // 13.0
    wire [11:0] v209; assign v209[11:0] = model_inp[1035:1024]; // 13.0
    wire [8:0] v210; assign v210[8:0] = model_inp[1044:1036]; // 13.0
    wire [3:0] v211; assign v211[3:0] = model_inp[1048:1045]; // 13.0
    wire [9:0] v212; assign v212[9:0] = model_inp[1058:1049]; // 13.0
    wire [3:0] v213; assign v213[3:0] = model_inp[1062:1059]; // 13.0
    wire [10:0] v214; assign v214[10:0] = model_inp[1073:1063]; // 13.0
    wire [11:0] v215; assign v215[11:0] = model_inp[1085:1074]; // 13.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[10:0] = v2[10:0];
    assign model_out[23:11] = v5[12:0];
    assign model_out[34:24] = v11[10:0];
    assign model_out[41:35] = v28[6:0];
    assign model_out[51:42] = v14[9:0];
    assign model_out[60:52] = v91[8:0];
    assign model_out[71:61] = v15[10:0];
    assign model_out[82:72] = v18[10:0];
    assign model_out[93:83] = v21[10:0];
    assign model_out[102:94] = v23[8:0];
    assign model_out[115:103] = v24[12:0];
    assign model_out[124:116] = v26[8:0];
    assign model_out[127:125] = v207[2:0];
    assign model_out[132:128] = v33[4:0];
    assign model_out[145:133] = v36[12:0];
    assign model_out[155:146] = v39[9:0];
    assign model_out[163:156] = v42[7:0];
    assign model_out[174:164] = v142[10:0];
    assign model_out[185:175] = v47[10:0];
    assign model_out[194:186] = v208[8:0];
    assign model_out[205:195] = v50[10:0];
    assign model_out[215:206] = v53[9:0];
    assign model_out[225:216] = v1[9:0];
    assign model_out[234:226] = v56[8:0];
    assign model_out[246:235] = v59[11:0];
    assign model_out[257:247] = v62[10:0];
    assign model_out[266:258] = v65[8:0];
    assign model_out[274:267] = v71[7:0];
    assign model_out[284:275] = v74[9:0];
    assign model_out[296:285] = v77[11:0];
    assign model_out[308:297] = v209[11:0];
    assign model_out[319:309] = v79[10:0];
    assign model_out[328:320] = v80[8:0];
    assign model_out[339:329] = v85[10:0];
    assign model_out[349:340] = v76[9:0];
    assign model_out[360:350] = v88[10:0];
    assign model_out[372:361] = v90[11:0];
    assign model_out[384:373] = v93[11:0];
    assign model_out[398:385] = v95[13:0];
    assign model_out[409:399] = v96[10:0];
    assign model_out[418:410] = v98[8:0];
    assign model_out[429:419] = v100[10:0];
    assign model_out[436:430] = v102[6:0];
    assign model_out[445:437] = v210[8:0];
    assign model_out[449:446] = v211[3:0];
    assign model_out[460:450] = v104[10:0];
    assign model_out[473:461] = v106[12:0];
    assign model_out[484:474] = v108[10:0];
    assign model_out[495:485] = v111[10:0];
    assign model_out[505:496] = v212[9:0];
    assign model_out[516:506] = v116[10:0];
    assign model_out[526:517] = v9[9:0];
    assign model_out[537:527] = v117[10:0];
    assign model_out[550:538] = v118[12:0];
    assign model_out[565:551] = v120[14:0];
    assign model_out[575:566] = v122[9:0];
    assign model_out[587:576] = v125[11:0];
    assign model_out[598:588] = v127[10:0];
    assign model_out[609:599] = v129[10:0];
    assign model_out[613:610] = v213[3:0];
    assign model_out[621:614] = v131[7:0];
    assign model_out[632:622] = v134[10:0];
    assign model_out[641:633] = v48[8:0];
    assign model_out[654:642] = v136[12:0];
    assign model_out[665:655] = v139[10:0];
    assign model_out[677:666] = v141[11:0];
    assign model_out[691:678] = v147[13:0];
    assign model_out[703:692] = v149[11:0];
    assign model_out[714:704] = v152[10:0];
    assign model_out[725:715] = v153[10:0];
    assign model_out[737:726] = v158[11:0];
    assign model_out[748:738] = v159[10:0];
    assign model_out[756:749] = v160[7:0];
    assign model_out[766:757] = v169[9:0];
    assign model_out[777:767] = v164[10:0];
    assign model_out[789:778] = v167[11:0];
    assign model_out[799:790] = v170[9:0];
    assign model_out[812:800] = v172[12:0];
    assign model_out[820:813] = v43[7:0];
    assign model_out[833:821] = v179[12:0];
    assign model_out[844:834] = v181[10:0];
    assign model_out[855:845] = v183[10:0];
    assign model_out[863:856] = v185[7:0];
    assign model_out[874:864] = v214[10:0];
    assign model_out[884:875] = v188[9:0];
    assign model_out[896:885] = v215[11:0];
    assign model_out[907:897] = v190[10:0];
    assign model_out[919:908] = v191[11:0];
    assign model_out[931:920] = v192[11:0];
    assign model_out[943:932] = v194[11:0];
    assign model_out[953:944] = v205[9:0];
    assign model_out[963:954] = v196[9:0];
    assign model_out[974:964] = v198[10:0];
    assign model_out[984:975] = v202[9:0];
    assign model_out[995:985] = v203[10:0];
    assign model_out[1007:996] = v206[11:0];
    assign model_out[1018:1008] = v8[10:0];
    assign model_out[1027:1019] = v45[8:0];
    assign model_out[1039:1028] = v68[11:0];
    assign model_out[1050:1040] = v82[10:0];
    assign model_out[1060:1051] = v113[9:0];
    assign model_out[1072:1061] = v144[11:0];
    assign model_out[1083:1073] = v155[10:0];
    assign model_out[1096:1084] = v162[12:0];
    assign model_out[1108:1097] = v174[11:0];
    assign model_out[1123:1109] = v177[14:0];
    assign model_out[1134:1124] = v200[10:0];
    assign model_out[1144:1135] = v29[9:0];

endmodule
