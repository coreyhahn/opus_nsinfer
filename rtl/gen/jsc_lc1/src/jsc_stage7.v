`timescale 1 ns / 1 ps

module jsc_stage7 (
    input [1812:0] model_inp,
    output [1689:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [7:0] v0; assign v0[7:0] = model_inp[7:0]; // 7.0
    wire [8:0] v1; assign v1[8:0] = model_inp[16:8]; // 7.0
    wire [11:0] v2; shift_adder #(8, 9, 1, 0, 12, 2, 1) op_2 (v0[7:0], v1[8:0], v2[11:0]); // 8.0
    wire [10:0] v3; assign v3[10:0] = model_inp[27:17]; // 7.0
    wire [11:0] v4; assign v4[11:0] = model_inp[39:28]; // 7.0
    wire [13:0] v5; shift_adder #(11, 12, 1, 1, 14, 2, 1) op_5 (v3[10:0], v4[11:0], v5[13:0]); // 8.0
    wire [3:0] v6; assign v6[3:0] = model_inp[43:40]; // 7.0
    wire [7:0] v7; assign v7[7:0] = model_inp[51:44]; // 7.0
    wire [8:0] v8; shift_adder #(4, 8, 0, 1, 9, -2, 1) op_8 (v6[3:0], v7[7:0], v8[8:0]); // 8.0
    wire [7:0] v9; assign v9[7:0] = model_inp[59:52]; // 7.0
    wire [6:0] v10; assign v10[6:0] = model_inp[66:60]; // 7.0
    wire [9:0] v11; shift_adder #(8, 7, 1, 1, 10, -1, 1) op_11 (v9[7:0], v10[6:0], v11[9:0]); // 8.0
    wire [6:0] v12; assign v12[6:0] = model_inp[73:67]; // 7.0
    wire [8:0] v13; assign v13[8:0] = model_inp[82:74]; // 7.0
    wire [9:0] v14; shift_adder #(7, 9, 1, 0, 10, -1, 0) op_14 (v12[6:0], v13[8:0], v14[9:0]); // 8.0
    wire [5:0] v15; assign v15[5:0] = model_inp[88:83]; // 7.0
    wire [6:0] v16; assign v16[6:0] = model_inp[95:89]; // 7.0
    wire [9:0] v17; shift_adder #(6, 7, 0, 0, 10, 2, 1) op_17 (v15[5:0], v16[6:0], v17[9:0]); // 8.0
    wire [9:0] v18; assign v18[9:0] = model_inp[105:96]; // 7.0
    wire [9:0] v19; assign v19[9:0] = model_inp[115:106]; // 7.0
    wire [12:0] v20; shift_adder #(10, 10, 1, 1, 13, -3, 1) op_20 (v18[9:0], v19[9:0], v20[12:0]); // 8.0
    wire [8:0] v21; assign v21[8:0] = model_inp[124:116]; // 7.0
    wire [11:0] v22; assign v22[11:0] = model_inp[136:125]; // 7.0
    wire [12:0] v23; shift_adder #(9, 12, 0, 1, 13, -1, 0) op_23 (v21[8:0], v22[11:0], v23[12:0]); // 8.0
    wire [6:0] v24; assign v24[6:0] = model_inp[143:137]; // 7.0
    wire [6:0] v25; assign v25[6:0] = model_inp[150:144]; // 7.0
    wire [12:0] v26; shift_adder #(7, 7, 1, 0, 13, 4, 1) op_26 (v24[6:0], v25[6:0], v26[12:0]); // 8.0
    wire [7:0] v27; assign v27[7:0] = model_inp[158:151]; // 7.0
    wire [11:0] v28; assign v28[11:0] = model_inp[170:159]; // 7.0
    wire [12:0] v29; shift_adder #(8, 12, 0, 1, 13, -1, 0) op_29 (v27[7:0], v28[11:0], v29[12:0]); // 8.0
    wire [6:0] v30; assign v30[6:0] = model_inp[177:171]; // 7.0
    wire [11:0] v31; assign v31[11:0] = model_inp[189:178]; // 7.0
    wire [11:0] v32; shift_adder #(7, 12, 0, 0, 12, -1, 0) op_32 (v30[6:0], v31[11:0], v32[11:0]); // 8.0
    wire [4:0] v33; assign v33[4:0] = model_inp[194:190]; // 7.0
    wire [8:0] v34; assign v34[8:0] = model_inp[203:195]; // 7.0
    wire [8:0] v35; shift_adder #(5, 9, 0, 0, 9, 0, 0) op_35 (v33[4:0], v34[8:0], v35[8:0]); // 8.0
    wire [5:0] v36; assign v36[5:0] = model_inp[209:204]; // 7.0
    wire [12:0] v37; assign v37[12:0] = model_inp[222:210]; // 7.0
    wire [12:0] v38; shift_adder #(6, 13, 0, 1, 13, -2, 0) op_38 (v36[5:0], v37[12:0], v38[12:0]); // 8.0
    wire [12:0] v39; assign v39[12:0] = model_inp[235:223]; // 7.0
    wire [11:0] v40; assign v40[11:0] = model_inp[247:236]; // 7.0
    wire [13:0] v41; shift_adder #(13, 12, 1, 1, 14, 1, 0) op_41 (v39[12:0], v40[11:0], v41[13:0]); // 8.0
    wire [6:0] v42; assign v42[6:0] = model_inp[254:248]; // 7.0
    wire [8:0] v43; assign v43[8:0] = model_inp[263:255]; // 7.0
    wire [9:0] v44; shift_adder #(7, 9, 0, 0, 10, -2, 0) op_44 (v42[6:0], v43[8:0], v44[9:0]); // 8.0
    wire [3:0] v45; assign v45[3:0] = model_inp[267:264]; // 7.0
    wire [6:0] v46; shift_adder #(4, 7, 0, 1, 7, -1, 1) op_46 (v45[3:0], v12[6:0], v46[6:0]); // 8.0
    wire [3:0] v47; assign v47[3:0] = model_inp[271:268]; // 7.0
    wire [7:0] v48; assign v48[7:0] = model_inp[279:272]; // 7.0
    wire [7:0] v49; shift_adder #(4, 8, 0, 1, 8, 0, 1) op_49 (v47[3:0], v48[7:0], v49[7:0]); // 8.0
    wire [8:0] v50; assign v50[8:0] = model_inp[288:280]; // 7.0
    wire [6:0] v51; assign v51[6:0] = model_inp[295:289]; // 7.0
    wire [11:0] v52; shift_adder #(9, 7, 1, 1, 12, 4, 1) op_52 (v50[8:0], v51[6:0], v52[11:0]); // 8.0
    wire [11:0] v53; assign v53[11:0] = model_inp[307:296]; // 7.0
    wire [7:0] v54; assign v54[7:0] = model_inp[315:308]; // 7.0
    wire [12:0] v55; shift_adder #(12, 8, 1, 0, 13, 3, 0) op_55 (v53[11:0], v54[7:0], v55[12:0]); // 8.0
    wire [2:0] v56; assign v56[2:0] = model_inp[318:316]; // 7.0
    wire [8:0] v57; assign v57[8:0] = model_inp[327:319]; // 7.0
    wire [9:0] v58; shift_adder #(3, 9, 0, 1, 10, -2, 1) op_58 (v56[2:0], v57[8:0], v58[9:0]); // 8.0
    wire [10:0] v59; assign v59[10:0] = model_inp[338:328]; // 7.0
    wire [6:0] v60; assign v60[6:0] = model_inp[345:339]; // 7.0
    wire [12:0] v61; shift_adder #(11, 7, 1, 1, 13, -1, 1) op_61 (v59[10:0], v60[6:0], v61[12:0]); // 8.0
    wire [12:0] v62; assign v62[12:0] = model_inp[358:346]; // 7.0
    wire [6:0] v63; assign v63[6:0] = model_inp[365:359]; // 7.0
    wire [13:0] v64; shift_adder #(13, 7, 1, 0, 14, 4, 0) op_64 (v62[12:0], v63[6:0], v64[13:0]); // 8.0
    wire [6:0] v65; assign v65[6:0] = model_inp[372:366]; // 7.0
    wire [7:0] v66; assign v66[7:0] = model_inp[380:373]; // 7.0
    wire [8:0] v67; shift_adder #(7, 8, 0, 0, 9, 1, 0) op_67 (v65[6:0], v66[7:0], v67[8:0]); // 8.0
    wire [6:0] v68; assign v68[6:0] = model_inp[387:381]; // 7.0
    wire [9:0] v69; assign v69[9:0] = model_inp[397:388]; // 7.0
    wire [10:0] v70; shift_adder #(7, 10, 1, 1, 11, -2, 0) op_70 (v68[6:0], v69[9:0], v70[10:0]); // 8.0
    wire [10:0] v71; assign v71[10:0] = model_inp[408:398]; // 7.0
    wire [10:0] v72; shift_adder #(7, 11, 1, 1, 11, -2, 0) op_72 (v60[6:0], v71[10:0], v72[10:0]); // 8.0
    wire [3:0] v73; assign v73[3:0] = model_inp[412:409]; // 7.0
    wire [6:0] v74; assign v74[6:0] = model_inp[419:413]; // 7.0
    wire [7:0] v75; shift_adder #(4, 7, 0, 1, 8, 0, 0) op_75 (v73[3:0], v74[6:0], v75[7:0]); // 8.0
    wire [4:0] v76; assign v76[4:0] = model_inp[424:420]; // 7.0
    wire [6:0] v77; assign v77[6:0] = model_inp[431:425]; // 7.0
    wire [8:0] v78; shift_adder #(5, 7, 0, 1, 9, -2, 1) op_78 (v76[4:0], v77[6:0], v78[8:0]); // 8.0
    wire [8:0] v79; assign v79[8:0] = model_inp[440:432]; // 7.0
    wire [4:0] v80; assign v80[4:0] = model_inp[445:441]; // 7.0
    wire [9:0] v81; shift_adder #(9, 5, 1, 0, 10, 3, 1) op_81 (v79[8:0], v80[4:0], v81[9:0]); // 8.0
    wire [8:0] v82; assign v82[8:0] = model_inp[454:446]; // 7.0
    wire [10:0] v83; shift_adder #(9, 7, 0, 1, 11, 0, 0) op_83 (v82[8:0], v74[6:0], v83[10:0]); // 8.0
    wire [9:0] v84; assign v84[9:0] = model_inp[464:455]; // 7.0
    wire [8:0] v85; assign v85[8:0] = model_inp[473:465]; // 7.0
    wire [9:0] v86; shift_adder #(10, 9, 1, 0, 10, 0, 0) op_86 (v84[9:0], v85[8:0], v86[9:0]); // 8.0
    wire [10:0] v87; assign v87[10:0] = model_inp[484:474]; // 7.0
    wire [10:0] v88; assign v88[10:0] = model_inp[495:485]; // 7.0
    wire [14:0] v89; shift_adder #(11, 11, 1, 1, 15, -4, 1) op_89 (v87[10:0], v88[10:0], v89[14:0]); // 8.0
    wire [10:0] v90; assign v90[10:0] = model_inp[506:496]; // 7.0
    wire [10:0] v91; assign v91[10:0] = model_inp[517:507]; // 7.0
    wire [12:0] v92; shift_adder #(11, 11, 1, 0, 13, 1, 1) op_92 (v90[10:0], v91[10:0], v92[12:0]); // 8.0
    wire [4:0] v93; assign v93[4:0] = model_inp[522:518]; // 7.0
    wire [9:0] v94; assign v94[9:0] = model_inp[532:523]; // 7.0
    wire [10:0] v95; shift_adder #(5, 10, 0, 1, 11, -1, 0) op_95 (v93[4:0], v94[9:0], v95[10:0]); // 8.0
    wire [6:0] v96; assign v96[6:0] = model_inp[539:533]; // 7.0
    wire [10:0] v97; assign v97[10:0] = model_inp[550:540]; // 7.0
    wire [10:0] v98; shift_adder #(7, 11, 1, 1, 11, -1, 0) op_98 (v96[6:0], v97[10:0], v98[10:0]); // 8.0
    wire [5:0] v99; assign v99[5:0] = model_inp[556:551]; // 7.0
    wire [9:0] v100; shift_adder #(6, 10, 0, 1, 10, -1, 0) op_100 (v99[5:0], v19[9:0], v100[9:0]); // 8.0
    wire [7:0] v101; assign v101[7:0] = model_inp[564:557]; // 7.0
    wire [9:0] v102; assign v102[9:0] = model_inp[574:565]; // 7.0
    wire [10:0] v103; shift_adder #(8, 10, 1, 0, 11, 0, 1) op_103 (v101[7:0], v102[9:0], v103[10:0]); // 8.0
    wire [7:0] v104; assign v104[7:0] = model_inp[582:575]; // 7.0
    wire [7:0] v105; assign v105[7:0] = model_inp[590:583]; // 7.0
    wire [12:0] v106; shift_adder #(8, 8, 0, 0, 13, 5, 0) op_106 (v104[7:0], v105[7:0], v106[12:0]); // 8.0
    wire [5:0] v107; assign v107[5:0] = model_inp[596:591]; // 7.0
    wire [6:0] v108; assign v108[6:0] = model_inp[603:597]; // 7.0
    wire [7:0] v109; shift_adder #(6, 7, 1, 0, 8, 0, 0) op_109 (v107[5:0], v108[6:0], v109[7:0]); // 8.0
    wire [10:0] v110; assign v110[10:0] = model_inp[614:604]; // 7.0
    wire [8:0] v111; assign v111[8:0] = model_inp[623:615]; // 7.0
    wire [11:0] v112; shift_adder #(11, 9, 1, 1, 12, 1, 0) op_112 (v110[10:0], v111[8:0], v112[11:0]); // 8.0
    wire [7:0] v113; assign v113[7:0] = model_inp[631:624]; // 7.0
    wire [8:0] v114; assign v114[8:0] = model_inp[640:632]; // 7.0
    wire [9:0] v115; shift_adder #(8, 9, 1, 1, 10, -1, 0) op_115 (v113[7:0], v114[8:0], v115[9:0]); // 8.0
    wire [6:0] v116; assign v116[6:0] = model_inp[647:641]; // 7.0
    wire [8:0] v117; shift_adder #(7, 7, 0, 1, 9, 1, 0) op_117 (v116[6:0], v12[6:0], v117[8:0]); // 8.0
    wire [4:0] v118; assign v118[4:0] = model_inp[652:648]; // 7.0
    wire [9:0] v119; shift_adder #(5, 10, 0, 1, 10, 0, 1) op_119 (v118[4:0], v94[9:0], v119[9:0]); // 8.0
    wire [11:0] v120; assign v120[11:0] = model_inp[664:653]; // 7.0
    wire [9:0] v121; assign v121[9:0] = model_inp[674:665]; // 7.0
    wire [12:0] v122; shift_adder #(12, 10, 1, 1, 13, 2, 0) op_122 (v120[11:0], v121[9:0], v122[12:0]); // 8.0
    wire [3:0] v123; assign v123[3:0] = model_inp[678:675]; // 7.0
    wire [6:0] v124; assign v124[6:0] = model_inp[685:679]; // 7.0
    wire [7:0] v125; shift_adder #(4, 7, 0, 0, 8, -2, 1) op_125 (v123[3:0], v124[6:0], v125[7:0]); // 8.0
    wire [10:0] v126; assign v126[10:0] = model_inp[696:686]; // 7.0
    wire [12:0] v127; shift_adder #(12, 11, 1, 1, 13, 1, 0) op_127 (v4[11:0], v126[10:0], v127[12:0]); // 8.0
    wire [9:0] v128; assign v128[9:0] = model_inp[706:697]; // 7.0
    wire [10:0] v129; assign v129[10:0] = model_inp[717:707]; // 7.0
    wire [11:0] v130; shift_adder #(10, 11, 0, 0, 12, -1, 0) op_130 (v128[9:0], v129[10:0], v130[11:0]); // 8.0
    wire [4:0] v131; assign v131[4:0] = model_inp[722:718]; // 7.0
    wire [8:0] v132; shift_adder #(5, 7, 0, 0, 9, 1, 1) op_132 (v131[4:0], v42[6:0], v132[8:0]); // 8.0
    wire [9:0] v133; assign v133[9:0] = model_inp[732:723]; // 7.0
    wire [7:0] v134; assign v134[7:0] = model_inp[740:733]; // 7.0
    wire [9:0] v135; shift_adder #(10, 8, 1, 1, 10, 1, 0) op_135 (v133[9:0], v134[7:0], v135[9:0]); // 8.0
    wire [10:0] v136; assign v136[10:0] = model_inp[751:741]; // 7.0
    wire [12:0] v137; shift_adder #(11, 7, 1, 0, 13, 4, 1) op_137 (v136[10:0], v16[6:0], v137[12:0]); // 8.0
    wire [10:0] v138; assign v138[10:0] = model_inp[762:752]; // 7.0
    wire [10:0] v139; shift_adder #(11, 7, 1, 0, 11, 1, 1) op_139 (v138[10:0], v108[6:0], v139[10:0]); // 8.0
    wire [6:0] v140; assign v140[6:0] = model_inp[769:763]; // 7.0
    wire [9:0] v141; shift_adder #(9, 7, 1, 0, 10, 1, 0) op_141 (v111[8:0], v140[6:0], v141[9:0]); // 8.0
    wire [7:0] v142; assign v142[7:0] = model_inp[777:770]; // 7.0
    wire [11:0] v143; shift_adder #(10, 8, 1, 1, 12, 3, 0) op_143 (v19[9:0], v142[7:0], v143[11:0]); // 8.0
    wire [9:0] v144; assign v144[9:0] = model_inp[787:778]; // 7.0
    wire [9:0] v145; assign v145[9:0] = model_inp[797:788]; // 7.0
    wire [11:0] v146; shift_adder #(10, 10, 0, 1, 12, 1, 0) op_146 (v144[9:0], v145[9:0], v146[11:0]); // 8.0
    wire [11:0] v147; shift_adder #(9, 11, 1, 0, 12, 0, 1) op_147 (v50[8:0], v91[10:0], v147[11:0]); // 8.0
    wire [9:0] v148; assign v148[9:0] = model_inp[807:798]; // 7.0
    wire [10:0] v149; assign v149[10:0] = model_inp[818:808]; // 7.0
    wire [10:0] v150; shift_adder #(10, 11, 1, 1, 11, 0, 0) op_150 (v148[9:0], v149[10:0], v150[10:0]); // 8.0
    wire [11:0] v151; assign v151[11:0] = model_inp[830:819]; // 7.0
    wire [8:0] v152; assign v152[8:0] = model_inp[839:831]; // 7.0
    wire [12:0] v153; shift_adder #(12, 9, 1, 1, 13, 3, 1) op_153 (v151[11:0], v152[8:0], v153[12:0]); // 8.0
    wire [10:0] v154; shift_adder #(6, 11, 0, 1, 11, -2, 1) op_154 (v99[5:0], v126[10:0], v154[10:0]); // 8.0
    wire [8:0] v155; assign v155[8:0] = model_inp[848:840]; // 7.0
    wire [13:0] v156; assign v156[13:0] = model_inp[862:849]; // 7.0
    wire [14:0] v157; shift_adder #(9, 14, 1, 1, 15, -1, 0) op_157 (v155[8:0], v156[13:0], v157[14:0]); // 8.0
    wire [7:0] v158; assign v158[7:0] = model_inp[870:863]; // 7.0
    wire [6:0] v159; assign v159[6:0] = model_inp[877:871]; // 7.0
    wire [9:0] v160; shift_adder #(8, 7, 0, 1, 10, -1, 0) op_160 (v158[7:0], v159[6:0], v160[9:0]); // 8.0
    wire [12:0] v161; shift_adder #(8, 7, 1, 0, 13, 4, 1) op_161 (v9[7:0], v25[6:0], v161[12:0]); // 8.0
    wire [10:0] v162; assign v162[10:0] = model_inp[888:878]; // 7.0
    wire [9:0] v163; assign v163[9:0] = model_inp[898:889]; // 7.0
    wire [11:0] v164; shift_adder #(11, 10, 1, 1, 12, 0, 0) op_164 (v162[10:0], v163[9:0], v164[11:0]); // 8.0
    wire [11:0] v165; shift_adder #(11, 8, 1, 1, 12, 0, 0) op_165 (v136[10:0], v0[7:0], v165[11:0]); // 8.0
    wire [9:0] v166; assign v166[9:0] = model_inp[908:899]; // 7.0
    wire [7:0] v167; assign v167[7:0] = model_inp[916:909]; // 7.0
    wire [10:0] v168; shift_adder #(10, 8, 1, 1, 11, 2, 0) op_168 (v166[9:0], v167[7:0], v168[10:0]); // 8.0
    wire [9:0] v169; assign v169[9:0] = model_inp[926:917]; // 7.0
    wire [9:0] v170; shift_adder #(7, 10, 0, 0, 10, -1, 0) op_170 (v42[6:0], v169[9:0], v170[9:0]); // 8.0
    wire [13:0] v171; assign v171[13:0] = model_inp[940:927]; // 7.0
    wire [14:0] v172; shift_adder #(14, 10, 1, 1, 15, 4, 0) op_172 (v171[13:0], v19[9:0], v172[14:0]); // 8.0
    wire [10:0] v173; assign v173[10:0] = model_inp[951:941]; // 7.0
    wire [12:0] v174; assign v174[12:0] = model_inp[964:952]; // 7.0
    wire [12:0] v175; shift_adder #(11, 13, 0, 1, 13, 0, 0) op_175 (v173[10:0], v174[12:0], v175[12:0]); // 8.0
    wire [4:0] v176; assign v176[4:0] = model_inp[969:965]; // 7.0
    wire [11:0] v177; assign v177[11:0] = model_inp[981:970]; // 7.0
    wire [11:0] v178; shift_adder #(5, 12, 0, 1, 12, -2, 1) op_178 (v176[4:0], v177[11:0], v178[11:0]); // 8.0
    wire [13:0] v179; assign v179[13:0] = model_inp[995:982]; // 7.0
    wire [5:0] v180; assign v180[5:0] = model_inp[1001:996]; // 7.0
    wire [13:0] v181; shift_adder #(14, 6, 1, 0, 14, 2, 1) op_181 (v179[13:0], v180[5:0], v181[13:0]); // 8.0
    wire [10:0] v182; shift_adder #(7, 8, 0, 0, 11, -3, 1) op_182 (v25[6:0], v105[7:0], v182[10:0]); // 8.0
    wire [9:0] v183; shift_adder #(6, 8, 0, 0, 10, -3, 0) op_183 (v180[5:0], v66[7:0], v183[9:0]); // 8.0
    wire [8:0] v184; shift_adder #(8, 7, 1, 1, 9, 0, 0) op_184 (v167[7:0], v77[6:0], v184[8:0]); // 8.0
    wire [11:0] v185; assign v185[11:0] = model_inp[1013:1002]; // 7.0
    wire [9:0] v186; assign v186[9:0] = model_inp[1023:1014]; // 7.0
    wire [13:0] v187; shift_adder #(12, 10, 1, 1, 14, 4, 0) op_187 (v185[11:0], v186[9:0], v187[13:0]); // 8.0
    wire [8:0] v188; assign v188[8:0] = model_inp[1032:1024]; // 7.0
    wire [8:0] v189; assign v189[8:0] = model_inp[1041:1033]; // 7.0
    wire [10:0] v190; shift_adder #(9, 9, 1, 0, 11, -1, 0) op_190 (v188[8:0], v189[8:0], v190[10:0]); // 8.0
    wire [9:0] v191; shift_adder #(6, 10, 0, 1, 10, -2, 0) op_191 (v99[5:0], v19[9:0], v191[9:0]); // 8.0
    wire [7:0] v192; assign v192[7:0] = model_inp[1049:1042]; // 7.0
    wire [7:0] v193; assign v193[7:0] = model_inp[1057:1050]; // 7.0
    wire [10:0] v194; shift_adder #(8, 8, 0, 1, 11, 2, 0) op_194 (v192[7:0], v193[7:0], v194[10:0]); // 8.0
    wire [11:0] v195; assign v195[11:0] = model_inp[1069:1058]; // 7.0
    wire [11:0] v196; assign v196[11:0] = model_inp[1081:1070]; // 7.0
    wire [13:0] v197; shift_adder #(12, 12, 1, 1, 14, 2, 0) op_197 (v195[11:0], v196[11:0], v197[13:0]); // 8.0
    wire [10:0] v198; assign v198[10:0] = model_inp[1092:1082]; // 7.0
    wire [11:0] v199; shift_adder #(8, 11, 1, 1, 12, 0, 1) op_199 (v101[7:0], v198[10:0], v199[11:0]); // 8.0
    wire [5:0] v200; assign v200[5:0] = model_inp[1098:1093]; // 7.0
    wire [10:0] v201; shift_adder #(6, 10, 0, 0, 11, -2, 1) op_201 (v200[5:0], v144[9:0], v201[10:0]); // 8.0
    wire [6:0] v202; assign v202[6:0] = model_inp[1105:1099]; // 7.0
    wire [11:0] v203; shift_adder #(11, 7, 1, 1, 12, 4, 0) op_203 (v88[10:0], v202[6:0], v203[11:0]); // 8.0
    wire [7:0] v204; assign v204[7:0] = model_inp[1113:1106]; // 7.0
    wire [9:0] v205; shift_adder #(9, 8, 0, 0, 10, 0, 0) op_205 (v43[8:0], v204[7:0], v205[9:0]); // 8.0
    wire [11:0] v206; assign v206[11:0] = model_inp[1125:1114]; // 7.0
    wire [11:0] v207; shift_adder #(12, 7, 1, 1, 12, 2, 1) op_207 (v206[11:0], v159[6:0], v207[11:0]); // 8.0
    wire [7:0] v208; assign v208[7:0] = model_inp[1133:1126]; // 7.0
    wire [8:0] v209; shift_adder #(5, 8, 0, 1, 9, 1, 1) op_209 (v131[4:0], v208[7:0], v209[8:0]); // 8.0
    wire [8:0] v210; assign v210[8:0] = model_inp[1142:1134]; // 7.0
    wire [9:0] v211; assign v211[9:0] = model_inp[1152:1143]; // 7.0
    wire [10:0] v212; shift_adder #(9, 10, 0, 1, 11, 0, 0) op_212 (v210[8:0], v211[9:0], v212[10:0]); // 8.0
    wire [9:0] v213; assign v213[9:0] = model_inp[1162:1153]; // 7.0
    wire [7:0] v214; assign v214[7:0] = model_inp[1170:1163]; // 7.0
    wire [10:0] v215; shift_adder #(10, 8, 1, 1, 11, 1, 0) op_215 (v213[9:0], v214[7:0], v215[10:0]); // 8.0
    wire [8:0] v216; assign v216[8:0] = model_inp[1179:1171]; // 7.0
    wire [6:0] v217; assign v217[6:0] = model_inp[1186:1180]; // 7.0
    wire [10:0] v218; shift_adder #(9, 7, 1, 0, 11, 3, 1) op_218 (v216[8:0], v217[6:0], v218[10:0]); // 8.0
    wire [7:0] v219; assign v219[7:0] = model_inp[1194:1187]; // 7.0
    wire [10:0] v220; shift_adder #(9, 8, 0, 1, 11, 2, 0) op_220 (v43[8:0], v219[7:0], v220[10:0]); // 8.0
    wire [12:0] v221; assign v221[12:0] = model_inp[1207:1195]; // 7.0
    wire [12:0] v222; shift_adder #(13, 7, 1, 0, 13, 3, 1) op_222 (v221[12:0], v16[6:0], v222[12:0]); // 8.0
    wire [7:0] v223; shift_adder #(7, 7, 0, 0, 8, 0, 1) op_223 (v65[6:0], v124[6:0], v223[7:0]); // 8.0
    wire [8:0] v224; assign v224[8:0] = model_inp[1216:1208]; // 7.0
    wire [9:0] v225; shift_adder #(9, 9, 1, 1, 10, 0, 0) op_225 (v114[8:0], v224[8:0], v225[9:0]); // 8.0
    wire [8:0] v226; assign v226[8:0] = model_inp[1225:1217]; // 7.0
    wire [9:0] v227; shift_adder #(7, 9, 0, 0, 10, -2, 1) op_227 (v63[6:0], v226[8:0], v227[9:0]); // 8.0
    wire [10:0] v228; assign v228[10:0] = model_inp[1236:1226]; // 7.0
    wire [10:0] v229; assign v229[10:0] = model_inp[1247:1237]; // 7.0
    wire [12:0] v230; shift_adder #(11, 11, 0, 1, 13, 2, 0) op_230 (v228[10:0], v229[10:0], v230[12:0]); // 8.0
    wire [11:0] v231; assign v231[11:0] = model_inp[1259:1248]; // 7.0
    wire [12:0] v232; shift_adder #(12, 10, 1, 1, 13, -1, 1) op_232 (v231[11:0], v133[9:0], v232[12:0]); // 8.0
    wire [10:0] v233; assign v233[10:0] = model_inp[1270:1260]; // 7.0
    wire [15:0] v234; shift_adder #(11, 13, 1, 1, 16, -4, 0) op_234 (v233[10:0], v37[12:0], v234[15:0]); // 8.0
    wire [9:0] v235; assign v235[9:0] = model_inp[1280:1271]; // 7.0
    wire [11:0] v236; assign v236[11:0] = model_inp[1292:1281]; // 7.0
    wire [13:0] v237; shift_adder #(10, 12, 1, 0, 14, -3, 0) op_237 (v235[9:0], v236[11:0], v237[13:0]); // 8.0
    wire [9:0] v238; assign v238[9:0] = model_inp[1302:1293]; // 7.0
    wire [9:0] v239; assign v239[9:0] = model_inp[1312:1303]; // 7.0
    wire [10:0] v240; shift_adder #(10, 10, 1, 1, 11, 1, 0) op_240 (v238[9:0], v239[9:0], v240[10:0]); // 8.0
    wire [8:0] v241; shift_adder #(8, 7, 1, 1, 9, 0, 0) op_241 (v193[7:0], v77[6:0], v241[8:0]); // 8.0
    wire [10:0] v242; assign v242[10:0] = model_inp[1323:1313]; // 7.0
    wire [8:0] v243; assign v243[8:0] = model_inp[1332:1324]; // 7.0
    wire [11:0] v244; shift_adder #(11, 9, 1, 1, 12, 2, 0) op_244 (v242[10:0], v243[8:0], v244[11:0]); // 8.0
    wire [6:0] v245; assign v245[6:0] = model_inp[1339:1333]; // 7.0
    wire [9:0] v246; shift_adder #(9, 7, 1, 0, 10, 1, 0) op_246 (v50[8:0], v245[6:0], v246[9:0]); // 8.0
    wire [11:0] v247; assign v247[11:0] = model_inp[1351:1340]; // 7.0
    wire [8:0] v248; assign v248[8:0] = model_inp[1360:1352]; // 7.0
    wire [11:0] v249; shift_adder #(12, 9, 1, 1, 12, 1, 1) op_249 (v247[11:0], v248[8:0], v249[11:0]); // 8.0
    wire [7:0] v250; assign v250[7:0] = model_inp[1368:1361]; // 7.0
    wire [8:0] v251; shift_adder #(8, 6, 1, 1, 9, 1, 0) op_251 (v250[7:0], v107[5:0], v251[8:0]); // 8.0
    wire [10:0] v252; assign v252[10:0] = model_inp[1379:1369]; // 7.0
    wire [11:0] v253; shift_adder #(7, 11, 1, 1, 12, -2, 1) op_253 (v12[6:0], v252[10:0], v253[11:0]); // 8.0
    wire [8:0] v254; assign v254[8:0] = model_inp[1388:1380]; // 7.0
    wire [9:0] v255; assign v255[9:0] = model_inp[1398:1389]; // 7.0
    wire [10:0] v256; shift_adder #(9, 10, 1, 1, 11, 1, 0) op_256 (v254[8:0], v255[9:0], v256[10:0]); // 8.0
    wire [3:0] v257; assign v257[3:0] = model_inp[1402:1399]; // 7.0
    wire [7:0] v258; assign v258[7:0] = model_inp[1410:1403]; // 7.0
    wire [8:0] v259; shift_adder #(4, 8, 0, 1, 9, -3, 1) op_259 (v257[3:0], v258[7:0], v259[8:0]); // 8.0
    wire [11:0] v260; assign v260[11:0] = model_inp[1422:1411]; // 7.0
    wire [6:0] v261; assign v261[6:0] = model_inp[1429:1423]; // 7.0
    wire [13:0] v262; shift_adder #(12, 7, 1, 0, 14, 6, 1) op_262 (v260[11:0], v261[6:0], v262[13:0]); // 8.0
    wire [10:0] v263; assign v263[10:0] = model_inp[1440:1430]; // 7.0
    wire [10:0] v264; shift_adder #(11, 7, 1, 1, 11, 2, 0) op_264 (v263[10:0], v24[6:0], v264[10:0]); // 8.0
    wire [6:0] v265; assign v265[6:0] = model_inp[1447:1441]; // 7.0
    wire [8:0] v266; shift_adder #(7, 8, 0, 0, 9, 1, 0) op_266 (v265[6:0], v158[7:0], v266[8:0]); // 8.0
    wire [10:0] v267; shift_adder #(7, 9, 1, 0, 11, -2, 1) op_267 (v60[6:0], v13[8:0], v267[10:0]); // 8.0
    wire [11:0] v268; assign v268[11:0] = model_inp[1459:1448]; // 7.0
    wire [12:0] v269; shift_adder #(8, 12, 1, 1, 13, -3, 0) op_269 (v0[7:0], v268[11:0], v269[12:0]); // 8.0
    wire [9:0] v270; shift_adder #(9, 8, 1, 1, 10, 0, 0) op_270 (v188[8:0], v0[7:0], v270[9:0]); // 8.0
    wire [6:0] v271; assign v271[6:0] = model_inp[1466:1460]; // 7.0
    wire [13:0] v272; shift_adder #(11, 7, 1, 1, 14, 6, 0) op_272 (v252[10:0], v271[6:0], v272[13:0]); // 8.0
    wire [10:0] v273; assign v273[10:0] = model_inp[1477:1467]; // 7.0
    wire [9:0] v274; assign v274[9:0] = model_inp[1487:1478]; // 7.0
    wire [13:0] v275; shift_adder #(11, 10, 0, 1, 14, 3, 0) op_275 (v273[10:0], v274[9:0], v275[13:0]); // 8.0
    wire [6:0] v276; assign v276[6:0] = model_inp[1494:1488]; // 7.0
    wire [8:0] v277; shift_adder #(7, 7, 0, 1, 9, 0, 0) op_277 (v124[6:0], v276[6:0], v277[8:0]); // 8.0
    wire [10:0] v278; assign v278[10:0] = model_inp[1505:1495]; // 7.0
    wire [9:0] v279; assign v279[9:0] = model_inp[1515:1506]; // 7.0
    wire [11:0] v280; shift_adder #(11, 10, 1, 1, 12, 0, 1) op_280 (v278[10:0], v279[9:0], v280[11:0]); // 8.0
    wire [4:0] v281; assign v281[4:0] = model_inp[1520:1516]; // 7.0
    wire [11:0] v282; shift_adder #(10, 5, 1, 0, 12, 5, 1) op_282 (v19[9:0], v281[4:0], v282[11:0]); // 8.0
    wire [10:0] v283; assign v283[10:0] = model_inp[1531:1521]; // 7.0
    wire [15:0] v284; shift_adder #(14, 11, 1, 0, 16, 4, 0) op_284 (v171[13:0], v283[10:0], v284[15:0]); // 8.0
    wire [9:0] v285; assign v285[9:0] = model_inp[1541:1532]; // 7.0
    wire [6:0] v286; assign v286[6:0] = model_inp[1548:1542]; // 7.0
    wire [10:0] v287; shift_adder #(10, 7, 1, 1, 11, -1, 1) op_287 (v285[9:0], v286[6:0], v287[10:0]); // 8.0
    wire [9:0] v288; assign v288[9:0] = model_inp[1558:1549]; // 7.0
    wire [12:0] v289; shift_adder #(11, 10, 1, 1, 13, -1, 0) op_289 (v233[10:0], v288[9:0], v289[12:0]); // 8.0
    wire [10:0] v290; assign v290[10:0] = model_inp[1569:1559]; // 7.0
    wire [12:0] v291; shift_adder #(6, 11, 0, 0, 13, 1, 1) op_291 (v180[5:0], v290[10:0], v291[12:0]); // 8.0
    wire [8:0] v292; shift_adder #(7, 7, 1, 1, 9, -1, 0) op_292 (v24[6:0], v202[6:0], v292[8:0]); // 8.0
    wire [8:0] v293; assign v293[8:0] = model_inp[1578:1570]; // 7.0
    wire [7:0] v294; assign v294[7:0] = model_inp[1586:1579]; // 7.0
    wire [10:0] v295; shift_adder #(9, 8, 1, 0, 11, 2, 0) op_295 (v293[8:0], v294[7:0], v295[10:0]); // 8.0
    wire [12:0] v296; assign v296[12:0] = model_inp[1599:1587]; // 7.0
    wire [5:0] v297; assign v297[5:0] = model_inp[1605:1600]; // 7.0
    wire [13:0] v298; shift_adder #(13, 6, 1, 0, 14, -1, 1) op_298 (v296[12:0], v297[5:0], v298[13:0]); // 8.0
    wire [10:0] v299; assign v299[10:0] = model_inp[1616:1606]; // 7.0
    wire [12:0] v300; shift_adder #(11, 11, 0, 0, 13, -2, 0) op_300 (v273[10:0], v299[10:0], v300[12:0]); // 8.0
    wire [11:0] v301; shift_adder #(12, 8, 1, 1, 12, 2, 0) op_301 (v260[11:0], v142[7:0], v301[11:0]); // 8.0
    wire [11:0] v302; assign v302[11:0] = model_inp[1628:1617]; // 7.0
    wire [9:0] v303; assign v303[9:0] = model_inp[1638:1629]; // 7.0
    wire [12:0] v304; shift_adder #(12, 10, 1, 1, 13, 2, 0) op_304 (v302[11:0], v303[9:0], v304[12:0]); // 8.0
    wire [7:0] v305; assign v305[7:0] = model_inp[1646:1639]; // 7.0
    wire [8:0] v306; shift_adder #(8, 8, 1, 1, 9, 0, 1) op_306 (v305[7:0], v193[7:0], v306[8:0]); // 8.0
    wire [11:0] v307; assign v307[11:0] = model_inp[1658:1647]; // 7.0
    wire [11:0] v308; shift_adder #(12, 7, 1, 0, 12, 1, 0) op_308 (v307[11:0], v116[6:0], v308[11:0]); // 8.0
    wire [5:0] v309; assign v309[5:0] = model_inp[1664:1659]; // 7.0
    wire [4:0] v310; assign v310[4:0] = model_inp[1669:1665]; // 7.0
    wire [4:0] v311; assign v311[4:0] = model_inp[1674:1670]; // 7.0
    wire [9:0] v312; assign v312[9:0] = model_inp[1684:1675]; // 7.0
    wire [8:0] v313; assign v313[8:0] = model_inp[1693:1685]; // 7.0
    wire [13:0] v314; assign v314[13:0] = model_inp[1707:1694]; // 7.0
    wire [3:0] v315; assign v315[3:0] = model_inp[1711:1708]; // 7.0
    wire [5:0] v316; assign v316[5:0] = model_inp[1717:1712]; // 7.0
    wire [5:0] v317; assign v317[5:0] = model_inp[1723:1718]; // 7.0
    wire [13:0] v318; assign v318[13:0] = model_inp[1737:1724]; // 7.0
    wire [9:0] v319; assign v319[9:0] = model_inp[1747:1738]; // 7.0
    wire [10:0] v320; assign v320[10:0] = model_inp[1758:1748]; // 7.0
    wire [7:0] v321; assign v321[7:0] = model_inp[1766:1759]; // 7.0
    wire [8:0] v322; assign v322[8:0] = model_inp[1775:1767]; // 7.0
    wire [11:0] v323; assign v323[11:0] = model_inp[1787:1776]; // 7.0
    wire [9:0] v324; assign v324[9:0] = model_inp[1797:1788]; // 7.0
    wire [3:0] v325; assign v325[3:0] = model_inp[1801:1798]; // 7.0
    wire [2:0] v326; assign v326[2:0] = model_inp[1804:1802]; // 7.0
    wire [5:0] v327; assign v327[5:0] = model_inp[1810:1805]; // 7.0
    wire [1:0] v328; assign v328[1:0] = model_inp[1812:1811]; // 7.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[5:0] = v309[5:0];
    assign model_out[17:6] = v2[11:0];
    assign model_out[31:18] = v5[13:0];
    assign model_out[40:32] = v8[8:0];
    assign model_out[50:41] = v11[9:0];
    assign model_out[60:51] = v14[9:0];
    assign model_out[66:61] = v15[5:0];
    assign model_out[76:67] = v17[9:0];
    assign model_out[89:77] = v20[12:0];
    assign model_out[102:90] = v23[12:0];
    assign model_out[115:103] = v26[12:0];
    assign model_out[128:116] = v29[12:0];
    assign model_out[140:129] = v32[11:0];
    assign model_out[149:141] = v35[8:0];
    assign model_out[162:150] = v38[12:0];
    assign model_out[176:163] = v41[13:0];
    assign model_out[186:177] = v44[9:0];
    assign model_out[193:187] = v46[6:0];
    assign model_out[201:194] = v49[7:0];
    assign model_out[213:202] = v52[11:0];
    assign model_out[226:214] = v55[12:0];
    assign model_out[236:227] = v58[9:0];
    assign model_out[249:237] = v61[12:0];
    assign model_out[263:250] = v64[13:0];
    assign model_out[268:264] = v310[4:0];
    assign model_out[277:269] = v67[8:0];
    assign model_out[282:278] = v311[4:0];
    assign model_out[293:283] = v70[10:0];
    assign model_out[304:294] = v72[10:0];
    assign model_out[312:305] = v75[7:0];
    assign model_out[320:313] = v294[7:0];
    assign model_out[330:321] = v81[9:0];
    assign model_out[341:331] = v83[10:0];
    assign model_out[351:342] = v86[9:0];
    assign model_out[366:352] = v89[14:0];
    assign model_out[377:367] = v95[10:0];
    assign model_out[384:378] = v286[6:0];
    assign model_out[394:385] = v312[9:0];
    assign model_out[399:395] = v76[4:0];
    assign model_out[409:400] = v100[9:0];
    assign model_out[420:410] = v103[10:0];
    assign model_out[433:421] = v106[12:0];
    assign model_out[441:434] = v109[7:0];
    assign model_out[453:442] = v112[11:0];
    assign model_out[463:454] = v115[9:0];
    assign model_out[472:464] = v313[8:0];
    assign model_out[481:473] = v117[8:0];
    assign model_out[491:482] = v119[9:0];
    assign model_out[504:492] = v122[12:0];
    assign model_out[512:505] = v125[7:0];
    assign model_out[525:513] = v127[12:0];
    assign model_out[537:526] = v130[11:0];
    assign model_out[546:538] = v132[8:0];
    assign model_out[556:547] = v135[9:0];
    assign model_out[567:557] = v139[10:0];
    assign model_out[577:568] = v141[9:0];
    assign model_out[589:578] = v143[11:0];
    assign model_out[603:590] = v314[13:0];
    assign model_out[615:604] = v146[11:0];
    assign model_out[627:616] = v147[11:0];
    assign model_out[638:628] = v150[10:0];
    assign model_out[651:639] = v153[12:0];
    assign model_out[655:652] = v315[3:0];
    assign model_out[666:656] = v154[10:0];
    assign model_out[681:667] = v157[14:0];
    assign model_out[691:682] = v160[9:0];
    assign model_out[704:692] = v137[12:0];
    assign model_out[717:705] = v161[12:0];
    assign model_out[726:718] = v82[8:0];
    assign model_out[738:727] = v165[11:0];
    assign model_out[749:739] = v168[10:0];
    assign model_out[757:750] = v105[7:0];
    assign model_out[772:758] = v172[14:0];
    assign model_out[785:773] = v175[12:0];
    assign model_out[797:786] = v178[11:0];
    assign model_out[803:798] = v316[5:0];
    assign model_out[817:804] = v181[13:0];
    assign model_out[823:818] = v317[5:0];
    assign model_out[834:824] = v182[10:0];
    assign model_out[844:835] = v183[9:0];
    assign model_out[853:845] = v184[8:0];
    assign model_out[867:854] = v187[13:0];
    assign model_out[878:868] = v190[10:0];
    assign model_out[888:879] = v94[9:0];
    assign model_out[898:889] = v191[9:0];
    assign model_out[907:899] = v78[8:0];
    assign model_out[917:908] = v166[9:0];
    assign model_out[928:918] = v194[10:0];
    assign model_out[942:929] = v197[13:0];
    assign model_out[954:943] = v199[11:0];
    assign model_out[959:955] = v176[4:0];
    assign model_out[970:960] = v201[10:0];
    assign model_out[982:971] = v203[11:0];
    assign model_out[996:983] = v318[13:0];
    assign model_out[1006:997] = v205[9:0];
    assign model_out[1018:1007] = v207[11:0];
    assign model_out[1029:1019] = v212[10:0];
    assign model_out[1040:1030] = v215[10:0];
    assign model_out[1050:1041] = v319[9:0];
    assign model_out[1061:1051] = v218[10:0];
    assign model_out[1072:1062] = v220[10:0];
    assign model_out[1085:1073] = v222[12:0];
    assign model_out[1093:1086] = v223[7:0];
    assign model_out[1103:1094] = v227[9:0];
    assign model_out[1114:1104] = v90[10:0];
    assign model_out[1127:1115] = v230[12:0];
    assign model_out[1140:1128] = v232[12:0];
    assign model_out[1151:1141] = v320[10:0];
    assign model_out[1159:1152] = v321[7:0];
    assign model_out[1170:1160] = v240[10:0];
    assign model_out[1177:1171] = v12[6:0];
    assign model_out[1189:1178] = v244[11:0];
    assign model_out[1199:1190] = v246[9:0];
    assign model_out[1211:1200] = v249[11:0];
    assign model_out[1220:1212] = v251[8:0];
    assign model_out[1232:1221] = v253[11:0];
    assign model_out[1243:1233] = v256[10:0];
    assign model_out[1252:1244] = v259[8:0];
    assign model_out[1261:1253] = v322[8:0];
    assign model_out[1275:1262] = v262[13:0];
    assign model_out[1286:1276] = v264[10:0];
    assign model_out[1298:1287] = v323[11:0];
    assign model_out[1309:1299] = v267[10:0];
    assign model_out[1322:1310] = v269[12:0];
    assign model_out[1332:1323] = v270[9:0];
    assign model_out[1342:1333] = v324[9:0];
    assign model_out[1356:1343] = v272[13:0];
    assign model_out[1370:1357] = v275[13:0];
    assign model_out[1379:1371] = v277[8:0];
    assign model_out[1391:1380] = v282[11:0];
    assign model_out[1407:1392] = v284[15:0];
    assign model_out[1418:1408] = v287[10:0];
    assign model_out[1431:1419] = v289[12:0];
    assign model_out[1444:1432] = v291[12:0];
    assign model_out[1453:1445] = v209[8:0];
    assign model_out[1460:1454] = v60[6:0];
    assign model_out[1471:1461] = v295[10:0];
    assign model_out[1485:1472] = v298[13:0];
    assign model_out[1498:1486] = v300[12:0];
    assign model_out[1510:1499] = v301[11:0];
    assign model_out[1523:1511] = v304[12:0];
    assign model_out[1532:1524] = v306[8:0];
    assign model_out[1541:1533] = v266[8:0];
    assign model_out[1553:1542] = v308[11:0];
    assign model_out[1557:1554] = v325[3:0];
    assign model_out[1570:1558] = v92[12:0];
    assign model_out[1581:1571] = v98[10:0];
    assign model_out[1593:1582] = v164[11:0];
    assign model_out[1603:1594] = v170[9:0];
    assign model_out[1608:1604] = v281[4:0];
    assign model_out[1611:1609] = v326[2:0];
    assign model_out[1617:1612] = v327[5:0];
    assign model_out[1627:1618] = v225[9:0];
    assign model_out[1643:1628] = v234[15:0];
    assign model_out[1657:1644] = v237[13:0];
    assign model_out[1666:1658] = v241[8:0];
    assign model_out[1678:1667] = v280[11:0];
    assign model_out[1687:1679] = v292[8:0];
    assign model_out[1689:1688] = v328[1:0];

endmodule
