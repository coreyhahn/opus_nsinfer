`timescale 1 ns / 1 ps

module x310_clf_stage6 (
    input [820:0] model_inp,
    output [397:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [6:0] v0; assign v0[6:0] = model_inp[6:0]; // 18.0
    wire [5:0] v1; assign v1[5:0] = model_inp[12:7]; // 18.0
    wire [7:0] v2; shift_adder #(7, 6, 1, 1, 8, 1, 0) op_2 (v0[6:0], v1[5:0], v2[7:0]); // 19.0
    wire [7:0] v3; assign v3[7:0] = model_inp[20:13]; // 18.0
    wire [9:0] v4; assign v4[9:0] = model_inp[30:21]; // 18.0
    wire [9:0] v5; shift_adder #(8, 10, 1, 1, 10, 0, 0) op_5 (v3[7:0], v4[9:0], v5[9:0]); // 19.0
    wire [5:0] v6; assign v6[5:0] = model_inp[36:31]; // 18.0
    wire [4:0] v7; assign v7[4:0] = model_inp[41:37]; // 18.0
    wire [6:0] v8; shift_adder #(6, 5, 0, 0, 7, 1, 0) op_8 (v6[5:0], v7[4:0], v8[6:0]); // 19.0
    wire [3:0] v9; assign v9[3:0] = model_inp[45:42]; // 18.0
    wire [7:0] v10; assign v10[7:0] = model_inp[53:46]; // 18.0
    wire [8:0] v11; shift_adder #(4, 8, 0, 0, 9, -1, 1) op_11 (v9[3:0], v10[7:0], v11[8:0]); // 19.0
    wire [4:0] v12; assign v12[4:0] = model_inp[58:54]; // 18.0
    wire [10:0] v13; assign v13[10:0] = model_inp[69:59]; // 18.0
    wire [10:0] v14; shift_adder #(5, 11, 0, 1, 11, -1, 0) op_14 (v12[4:0], v13[10:0], v14[10:0]); // 19.0
    wire [7:0] v15; assign v15[7:0] = model_inp[77:70]; // 18.0
    wire [8:0] v16; assign v16[8:0] = model_inp[86:78]; // 18.0
    wire [8:0] v17; shift_adder #(8, 9, 1, 1, 9, 0, 0) op_17 (v15[7:0], v16[8:0], v17[8:0]); // 19.0
    wire [5:0] v18; assign v18[5:0] = model_inp[92:87]; // 18.0
    wire [8:0] v19; assign v19[8:0] = model_inp[101:93]; // 18.0
    wire [9:0] v20; shift_adder #(6, 9, 0, 1, 10, 0, 0) op_20 (v18[5:0], v19[8:0], v20[9:0]); // 19.0
    wire [10:0] v21; assign v21[10:0] = model_inp[112:102]; // 18.0
    wire [7:0] v22; assign v22[7:0] = model_inp[120:113]; // 18.0
    wire [10:0] v23; shift_adder #(11, 8, 1, 1, 11, 1, 1) op_23 (v21[10:0], v22[7:0], v23[10:0]); // 19.0
    wire [10:0] v24; assign v24[10:0] = model_inp[131:121]; // 18.0
    wire [10:0] v25; shift_adder #(11, 10, 1, 1, 11, 0, 0) op_25 (v24[10:0], v4[9:0], v25[10:0]); // 19.0
    wire [7:0] v26; assign v26[7:0] = model_inp[139:132]; // 18.0
    wire [6:0] v27; assign v27[6:0] = model_inp[146:140]; // 18.0
    wire [8:0] v28; shift_adder #(8, 7, 1, 1, 9, 0, 0) op_28 (v26[7:0], v27[6:0], v28[8:0]); // 19.0
    wire [7:0] v29; assign v29[7:0] = model_inp[154:147]; // 18.0
    wire [8:0] v30; shift_adder #(5, 8, 0, 0, 9, 0, 1) op_30 (v7[4:0], v29[7:0], v30[8:0]); // 19.0
    wire [5:0] v31; assign v31[5:0] = model_inp[160:155]; // 18.0
    wire [9:0] v32; assign v32[9:0] = model_inp[170:161]; // 18.0
    wire [9:0] v33; shift_adder #(6, 10, 0, 1, 10, -1, 0) op_33 (v31[5:0], v32[9:0], v33[9:0]); // 19.0
    wire [3:0] v34; assign v34[3:0] = model_inp[174:171]; // 18.0
    wire [6:0] v35; assign v35[6:0] = model_inp[181:175]; // 18.0
    wire [7:0] v36; shift_adder #(4, 7, 0, 1, 8, -1, 1) op_36 (v34[3:0], v35[6:0], v36[7:0]); // 19.0
    wire [3:0] v37; assign v37[3:0] = model_inp[185:182]; // 18.0
    wire [7:0] v38; assign v38[7:0] = model_inp[193:186]; // 18.0
    wire [8:0] v39; shift_adder #(4, 8, 0, 0, 9, -1, 1) op_39 (v37[3:0], v38[7:0], v39[8:0]); // 19.0
    wire [4:0] v40; assign v40[4:0] = model_inp[198:194]; // 18.0
    wire [8:0] v41; assign v41[8:0] = model_inp[207:199]; // 18.0
    wire [8:0] v42; shift_adder #(5, 9, 1, 1, 9, 0, 1) op_42 (v40[4:0], v41[8:0], v42[8:0]); // 19.0
    wire [2:0] v43; assign v43[2:0] = model_inp[210:208]; // 18.0
    wire [6:0] v44; assign v44[6:0] = model_inp[217:211]; // 18.0
    wire [6:0] v45; shift_adder #(3, 7, 0, 1, 7, 0, 1) op_45 (v43[2:0], v44[6:0], v45[6:0]); // 19.0
    wire [6:0] v46; assign v46[6:0] = model_inp[224:218]; // 18.0
    wire [9:0] v47; assign v47[9:0] = model_inp[234:225]; // 18.0
    wire [10:0] v48; shift_adder #(7, 10, 1, 1, 11, -2, 0) op_48 (v46[6:0], v47[9:0], v48[10:0]); // 19.0
    wire [8:0] v49; assign v49[8:0] = model_inp[243:235]; // 18.0
    wire [11:0] v50; shift_adder #(8, 9, 0, 1, 12, -3, 0) op_50 (v10[7:0], v49[8:0], v50[11:0]); // 19.0
    wire [8:0] v51; assign v51[8:0] = model_inp[252:244]; // 18.0
    wire [7:0] v52; assign v52[7:0] = model_inp[260:253]; // 18.0
    wire [9:0] v53; shift_adder #(9, 8, 1, 0, 10, 0, 0) op_53 (v51[8:0], v52[7:0], v53[9:0]); // 19.0
    wire [9:0] v54; assign v54[9:0] = model_inp[270:261]; // 18.0
    wire [5:0] v55; assign v55[5:0] = model_inp[276:271]; // 18.0
    wire [9:0] v56; shift_adder #(10, 6, 1, 1, 10, 0, 1) op_56 (v54[9:0], v55[5:0], v56[9:0]); // 19.0
    wire [4:0] v57; assign v57[4:0] = model_inp[281:277]; // 18.0
    wire [6:0] v58; assign v58[6:0] = model_inp[288:282]; // 18.0
    wire [6:0] v59; shift_adder #(5, 7, 0, 0, 7, 0, 0) op_59 (v57[4:0], v58[6:0], v59[6:0]); // 19.0
    wire [7:0] v60; assign v60[7:0] = model_inp[296:289]; // 18.0
    wire [9:0] v61; shift_adder #(7, 8, 0, 0, 10, 2, 0) op_61 (v58[6:0], v60[7:0], v61[9:0]); // 19.0
    wire [9:0] v62; assign v62[9:0] = model_inp[306:297]; // 18.0
    wire [8:0] v63; assign v63[8:0] = model_inp[315:307]; // 18.0
    wire [11:0] v64; shift_adder #(10, 9, 1, 0, 12, -1, 0) op_64 (v62[9:0], v63[8:0], v64[11:0]); // 19.0
    wire [6:0] v65; shift_adder #(5, 6, 0, 0, 7, 0, 1) op_65 (v7[4:0], v31[5:0], v65[6:0]); // 19.0
    wire [9:0] v66; assign v66[9:0] = model_inp[325:316]; // 18.0
    wire [8:0] v67; assign v67[8:0] = model_inp[334:326]; // 18.0
    wire [10:0] v68; shift_adder #(10, 9, 1, 1, 11, 1, 1) op_68 (v66[9:0], v67[8:0], v68[10:0]); // 19.0
    wire [8:0] v69; assign v69[8:0] = model_inp[343:335]; // 18.0
    wire [9:0] v70; shift_adder #(9, 7, 1, 1, 10, 1, 0) op_70 (v69[8:0], v27[6:0], v70[9:0]); // 19.0
    wire [7:0] v71; assign v71[7:0] = model_inp[351:344]; // 18.0
    wire [7:0] v72; assign v72[7:0] = model_inp[359:352]; // 18.0
    wire [10:0] v73; shift_adder #(8, 8, 1, 0, 11, -3, 1) op_73 (v71[7:0], v72[7:0], v73[10:0]); // 19.0
    wire [8:0] v74; assign v74[8:0] = model_inp[368:360]; // 18.0
    wire [10:0] v75; assign v75[10:0] = model_inp[379:369]; // 18.0
    wire [12:0] v76; shift_adder #(9, 11, 1, 1, 13, 2, 0) op_76 (v74[8:0], v75[10:0], v76[12:0]); // 19.0
    wire [8:0] v77; assign v77[8:0] = model_inp[388:380]; // 18.0
    wire [8:0] v78; assign v78[8:0] = model_inp[397:389]; // 18.0
    wire [10:0] v79; shift_adder #(9, 9, 1, 1, 11, 1, 1) op_79 (v77[8:0], v78[8:0], v79[10:0]); // 19.0
    wire [6:0] v80; assign v80[6:0] = model_inp[404:398]; // 18.0
    wire [9:0] v81; assign v81[9:0] = model_inp[414:405]; // 18.0
    wire [9:0] v82; shift_adder #(7, 10, 1, 1, 10, -1, 0) op_82 (v80[6:0], v81[9:0], v82[9:0]); // 19.0
    wire [8:0] v83; assign v83[8:0] = model_inp[423:415]; // 18.0
    wire [6:0] v84; assign v84[6:0] = model_inp[430:424]; // 18.0
    wire [9:0] v85; shift_adder #(9, 7, 1, 1, 10, 1, 1) op_85 (v83[8:0], v84[6:0], v85[9:0]); // 19.0
    wire [10:0] v86; assign v86[10:0] = model_inp[441:431]; // 18.0
    wire [10:0] v87; shift_adder #(7, 11, 1, 1, 11, -1, 0) op_87 (v27[6:0], v86[10:0], v87[10:0]); // 19.0
    wire [8:0] v88; assign v88[8:0] = model_inp[450:442]; // 18.0
    wire [7:0] v89; assign v89[7:0] = model_inp[458:451]; // 18.0
    wire [8:0] v90; shift_adder #(9, 8, 1, 1, 9, 0, 0) op_90 (v88[8:0], v89[7:0], v90[8:0]); // 19.0
    wire [9:0] v91; assign v91[9:0] = model_inp[468:459]; // 18.0
    wire [9:0] v92; assign v92[9:0] = model_inp[478:469]; // 18.0
    wire [9:0] v93; shift_adder #(10, 10, 1, 1, 10, 0, 0) op_93 (v91[9:0], v92[9:0], v93[9:0]); // 19.0
    wire [5:0] v94; assign v94[5:0] = model_inp[484:479]; // 18.0
    wire [9:0] v95; shift_adder #(8, 6, 1, 0, 10, 2, 0) op_95 (v22[7:0], v94[5:0], v95[9:0]); // 19.0
    wire [10:0] v96; assign v96[10:0] = model_inp[495:485]; // 18.0
    wire [8:0] v97; assign v97[8:0] = model_inp[504:496]; // 18.0
    wire [10:0] v98; shift_adder #(11, 9, 1, 1, 11, 0, 1) op_98 (v96[10:0], v97[8:0], v98[10:0]); // 19.0
    wire [9:0] v99; assign v99[9:0] = model_inp[514:505]; // 18.0
    wire [11:0] v100; shift_adder #(6, 10, 0, 1, 12, -4, 0) op_100 (v94[5:0], v99[9:0], v100[11:0]); // 19.0
    wire [9:0] v101; assign v101[9:0] = model_inp[524:515]; // 18.0
    wire [9:0] v102; shift_adder #(7, 10, 1, 1, 10, 0, 0) op_102 (v0[6:0], v101[9:0], v102[9:0]); // 19.0
    wire [10:0] v103; assign v103[10:0] = model_inp[535:525]; // 18.0
    wire [10:0] v104; shift_adder #(11, 9, 1, 1, 11, 1, 1) op_104 (v103[10:0], v41[8:0], v104[10:0]); // 19.0
    wire [8:0] v105; assign v105[8:0] = model_inp[544:536]; // 18.0
    wire [10:0] v106; shift_adder #(10, 9, 1, 1, 11, 0, 0) op_106 (v54[9:0], v105[8:0], v106[10:0]); // 19.0
    wire [10:0] v107; assign v107[10:0] = model_inp[555:545]; // 18.0
    wire [10:0] v108; shift_adder #(11, 5, 1, 0, 11, 3, 1) op_108 (v107[10:0], v7[4:0], v108[10:0]); // 19.0
    wire [4:0] v109; assign v109[4:0] = model_inp[560:556]; // 18.0
    wire [8:0] v110; assign v110[8:0] = model_inp[569:561]; // 18.0
    wire [8:0] v111; shift_adder #(5, 9, 0, 1, 9, 0, 0) op_111 (v109[4:0], v110[8:0], v111[8:0]); // 19.0
    wire [8:0] v112; assign v112[8:0] = model_inp[578:570]; // 18.0
    wire [6:0] v113; assign v113[6:0] = model_inp[585:579]; // 18.0
    wire [10:0] v114; shift_adder #(9, 7, 0, 0, 11, -1, 1) op_114 (v112[8:0], v113[6:0], v114[10:0]); // 19.0
    wire [8:0] v115; assign v115[8:0] = model_inp[594:586]; // 18.0
    wire [7:0] v116; assign v116[7:0] = model_inp[602:595]; // 18.0
    wire [10:0] v117; shift_adder #(9, 8, 1, 0, 11, 1, 0) op_117 (v115[8:0], v116[7:0], v117[10:0]); // 19.0
    wire [9:0] v118; assign v118[9:0] = model_inp[612:603]; // 18.0
    wire [10:0] v119; shift_adder #(8, 10, 1, 1, 11, -1, 0) op_119 (v71[7:0], v118[9:0], v119[10:0]); // 19.0
    wire [8:0] v120; assign v120[8:0] = model_inp[621:613]; // 18.0
    wire [6:0] v121; assign v121[6:0] = model_inp[628:622]; // 18.0
    wire [9:0] v122; shift_adder #(9, 7, 1, 0, 10, 1, 1) op_122 (v120[8:0], v121[6:0], v122[9:0]); // 19.0
    wire [6:0] v123; assign v123[6:0] = model_inp[635:629]; // 18.0
    wire [7:0] v124; assign v124[7:0] = model_inp[643:636]; // 18.0
    wire [8:0] v125; shift_adder #(7, 8, 1, 1, 9, 1, 1) op_125 (v123[6:0], v124[7:0], v125[8:0]); // 19.0
    wire [10:0] v126; shift_adder #(8, 10, 1, 1, 11, 0, 0) op_126 (v2[7:0], v5[9:0], v126[10:0]); // 20.0
    wire [9:0] v127; shift_adder #(7, 9, 0, 1, 10, -1, 0) op_127 (v8[6:0], v11[8:0], v127[9:0]); // 20.0
    wire [3:0] v128; assign v128[3:0] = model_inp[647:644]; // 18.0
    wire [10:0] v129; shift_adder #(4, 11, 0, 1, 11, -1, 1) op_129 (v128[3:0], v14[10:0], v129[10:0]); // 20.0
    wire [11:0] v130; shift_adder #(10, 11, 1, 1, 12, -1, 0) op_130 (v20[9:0], v23[10:0], v130[11:0]); // 20.0
    wire [10:0] v131; shift_adder #(11, 7, 1, 0, 11, 1, 0) op_131 (v25[10:0], v8[6:0], v131[10:0]); // 20.0
    wire [10:0] v132; shift_adder #(9, 9, 1, 1, 11, 1, 0) op_132 (v28[8:0], v30[8:0], v132[10:0]); // 20.0
    wire [10:0] v133; shift_adder #(5, 10, 0, 1, 11, -2, 0) op_133 (v109[4:0], v33[9:0], v133[10:0]); // 20.0
    wire [7:0] v134; shift_adder #(3, 8, 0, 1, 8, -2, 1) op_134 (v43[2:0], v36[7:0], v134[7:0]); // 20.0
    wire [9:0] v135; assign v135[9:0] = model_inp[657:648]; // 18.0
    wire [10:0] v136; shift_adder #(10, 9, 1, 1, 11, 1, 0) op_136 (v135[9:0], v39[8:0], v136[10:0]); // 20.0
    wire [9:0] v137; shift_adder #(9, 9, 1, 1, 10, -1, 0) op_137 (v39[8:0], v42[8:0], v137[9:0]); // 20.0
    wire [10:0] v138; shift_adder #(7, 11, 1, 1, 11, -2, 0) op_138 (v45[6:0], v48[10:0], v138[10:0]); // 20.0
    wire [10:0] v139; assign v139[10:0] = model_inp[668:658]; // 18.0
    wire [10:0] v140; shift_adder #(11, 10, 1, 1, 11, 0, 0) op_140 (v139[10:0], v53[9:0], v140[10:0]); // 20.0
    wire [9:0] v141; assign v141[9:0] = model_inp[678:669]; // 18.0
    wire [11:0] v142; shift_adder #(10, 10, 1, 1, 12, -1, 0) op_142 (v141[9:0], v56[9:0], v142[11:0]); // 20.0
    wire [7:0] v143; shift_adder #(4, 7, 0, 0, 8, -1, 0) op_143 (v34[3:0], v59[6:0], v143[7:0]); // 20.0
    wire [7:0] v144; assign v144[7:0] = model_inp[686:679]; // 18.0
    wire [10:0] v145; shift_adder #(10, 8, 0, 1, 11, 1, 1) op_145 (v61[9:0], v144[7:0], v145[10:0]); // 20.0
    wire [11:0] v146; shift_adder #(12, 7, 1, 1, 12, 2, 1) op_146 (v64[11:0], v65[6:0], v146[11:0]); // 20.0
    wire [10:0] v147; shift_adder #(11, 9, 1, 1, 11, 0, 1) op_147 (v68[10:0], v74[8:0], v147[10:0]); // 20.0
    wire [9:0] v148; assign v148[9:0] = model_inp[696:687]; // 18.0
    wire [11:0] v149; shift_adder #(11, 10, 1, 1, 12, 1, 1) op_149 (v73[10:0], v148[9:0], v149[11:0]); // 20.0
    wire [12:0] v150; shift_adder #(7, 13, 1, 1, 13, -4, 0) op_150 (v65[6:0], v76[12:0], v150[12:0]); // 20.0
    wire [7:0] v151; shift_adder #(4, 7, 0, 1, 8, 0, 1) op_151 (v34[3:0], v65[6:0], v151[7:0]); // 20.0
    wire [8:0] v152; assign v152[8:0] = model_inp[705:697]; // 18.0
    wire [11:0] v153; shift_adder #(11, 9, 1, 1, 12, -1, 1) op_153 (v79[10:0], v152[8:0], v153[11:0]); // 20.0
    wire [8:0] v154; assign v154[8:0] = model_inp[714:706]; // 18.0
    wire [10:0] v155; shift_adder #(10, 9, 1, 1, 11, 1, 1) op_155 (v82[9:0], v154[8:0], v155[10:0]); // 20.0
    wire [9:0] v156; shift_adder #(9, 10, 1, 1, 10, 0, 0) op_156 (v42[8:0], v85[9:0], v156[9:0]); // 20.0
    wire [6:0] v157; assign v157[6:0] = model_inp[721:715]; // 18.0
    wire [8:0] v158; shift_adder #(7, 7, 0, 0, 9, 1, 1) op_158 (v8[6:0], v157[6:0], v158[8:0]); // 20.0
    wire [11:0] v159; shift_adder #(11, 9, 1, 1, 12, 3, 1) op_159 (v87[10:0], v28[8:0], v159[11:0]); // 20.0
    wire [6:0] v160; assign v160[6:0] = model_inp[728:722]; // 18.0
    wire [10:0] v161; shift_adder #(10, 7, 1, 1, 11, 3, 1) op_161 (v93[9:0], v160[6:0], v161[10:0]); // 20.0
    wire [10:0] v162; shift_adder #(10, 11, 1, 1, 11, 0, 0) op_162 (v95[9:0], v98[10:0], v162[10:0]); // 20.0
    wire [11:0] v163; shift_adder #(10, 11, 1, 1, 12, -1, 0) op_163 (v102[9:0], v104[10:0], v163[11:0]); // 20.0
    wire [11:0] v164; shift_adder #(11, 6, 1, 0, 12, 2, 1) op_164 (v108[10:0], v18[5:0], v164[11:0]); // 20.0
    wire [3:0] v165; assign v165[3:0] = model_inp[732:729]; // 18.0
    wire [8:0] v166; shift_adder #(4, 9, 0, 1, 9, -1, 1) op_166 (v165[3:0], v111[8:0], v166[8:0]); // 20.0
    wire [11:0] v167; shift_adder #(11, 10, 1, 1, 12, -1, 1) op_167 (v117[10:0], v99[9:0], v167[11:0]); // 20.0
    wire [9:0] v168; assign v168[9:0] = model_inp[742:733]; // 18.0
    wire [10:0] v169; shift_adder #(10, 11, 1, 1, 11, 0, 0) op_169 (v168[9:0], v119[10:0], v169[10:0]); // 20.0
    wire [9:0] v170; assign v170[9:0] = model_inp[752:743]; // 18.0
    wire [10:0] v171; shift_adder #(9, 10, 1, 1, 11, -1, 1) op_171 (v11[8:0], v170[9:0], v171[10:0]); // 20.0
    wire [11:0] v172; shift_adder #(11, 10, 1, 1, 12, -1, 1) op_172 (v126[10:0], v127[9:0], v172[11:0]); // 21.0
    wire [3:0] v173; assign v173[3:0] = model_inp[756:753]; // 18.0
    wire [10:0] v174; shift_adder #(4, 11, 0, 1, 11, -1, 1) op_174 (v173[3:0], v129[10:0], v174[10:0]); // 21.0
    wire [12:0] v175; shift_adder #(12, 11, 1, 1, 13, 1, 1) op_175 (v130[11:0], v131[10:0], v175[12:0]); // 21.0
    wire [12:0] v176; shift_adder #(13, 3, 1, 0, 13, 0, 1) op_176 (v175[12:0], 3'b100, v176[12:0]); // 21.0
    wire [11:0] v177; assign v177[11:0] = v176[11:0] & {12{~v176[12]}}; // 21.0
    wire [11:0] v178; shift_adder #(12, 3, 0, 0, 12, 0, 0) op_178 (v177[11:0], 3'b100, v178[11:0]); // 21.0
    wire [6:0] v179; assign v179[6:0] = v178[9:3]; // 21.0
    wire [11:0] v180; shift_adder #(11, 11, 1, 1, 12, 1, 0) op_180 (v132[10:0], v133[10:0], v180[11:0]); // 21.0
    wire [10:0] v181; shift_adder #(8, 11, 1, 1, 11, -1, 0) op_181 (v134[7:0], v136[10:0], v181[10:0]); // 21.0
    wire [12:0] v182; shift_adder #(11, 12, 1, 1, 13, 0, 1) op_182 (v138[10:0], v50[11:0], v182[12:0]); // 21.0
    wire [11:0] v183; shift_adder #(11, 7, 1, 1, 12, 4, 1) op_183 (v145[10:0], v45[6:0], v183[11:0]); // 21.0
    wire [11:0] v184; shift_adder #(11, 10, 1, 1, 12, 0, 1) op_184 (v147[10:0], v70[9:0], v184[11:0]); // 21.0
    wire [13:0] v185; shift_adder #(12, 13, 1, 1, 14, 0, 0) op_185 (v149[11:0], v150[12:0], v185[13:0]); // 21.0
    wire [3:0] v186; assign v186[3:0] = model_inp[760:757]; // 18.0
    wire [7:0] v187; shift_adder #(4, 8, 0, 1, 8, -1, 1) op_187 (v186[3:0], v151[7:0], v187[7:0]); // 21.0
    wire [11:0] v188; shift_adder #(12, 8, 1, 0, 12, 1, 1) op_188 (v153[11:0], v143[7:0], v188[11:0]); // 21.0
    wire [9:0] v189; shift_adder #(8, 9, 1, 1, 10, 1, 0) op_189 (v134[7:0], v158[8:0], v189[9:0]); // 21.0
    wire [12:0] v190; shift_adder #(12, 9, 1, 1, 13, 2, 1) op_190 (v159[11:0], v90[8:0], v190[12:0]); // 21.0
    wire [12:0] v191; shift_adder #(11, 12, 1, 1, 13, 0, 1) op_191 (v162[10:0], v100[11:0], v191[12:0]); // 21.0
    wire [12:0] v192; shift_adder #(12, 11, 1, 1, 13, 1, 1) op_192 (v163[11:0], v106[10:0], v192[12:0]); // 21.0
    wire [11:0] v193; shift_adder #(12, 9, 1, 1, 12, 2, 0) op_193 (v164[11:0], v166[8:0], v193[11:0]); // 21.0
    wire [12:0] v194; shift_adder #(11, 12, 1, 1, 13, -1, 0) op_194 (v114[10:0], v167[11:0], v194[12:0]); // 21.0
    wire [12:0] v195; shift_adder #(13, 5, 1, 0, 13, 0, 1) op_195 (v194[12:0], 5'b10000, v195[12:0]); // 21.0
    wire [11:0] v196; assign v196[11:0] = v195[11:0] & {12{~v195[12]}}; // 21.0
    wire [11:0] v197; shift_adder #(12, 4, 0, 0, 12, 0, 0) op_197 (v196[11:0], 4'b1000, v197[11:0]); // 21.0
    wire [5:0] v198; assign v198[5:0] = v197[9:4]; // 21.0
    wire [11:0] v199; shift_adder #(9, 11, 1, 1, 12, 0, 0) op_199 (v166[8:0], v169[10:0], v199[11:0]); // 21.0
    wire [11:0] v200; shift_adder #(12, 3, 1, 0, 12, 0, 1) op_200 (v199[11:0], 3'b100, v200[11:0]); // 21.0
    wire [8:0] v201; assign v201[8:0] = v200[8:0] & {9{~v200[11]}}; // 21.0
    wire [8:0] v202; shift_adder #(9, 2, 0, 0, 9, 0, 0) op_202 (v201[8:0], 2'b10, v202[8:0]); // 21.0
    wire [4:0] v203; assign v203[4:0] = v202[6:2]; // 21.0
    wire [10:0] v204; shift_adder #(9, 11, 1, 1, 11, -1, 0) op_204 (v125[8:0], v171[10:0], v204[10:0]); // 21.0
    wire [13:0] v205; assign v205[13:0] = model_inp[774:761]; // 18.0
    wire [4:0] v206; assign v206[4:0] = model_inp[779:775]; // 18.0
    wire [4:0] v207; assign v207[4:0] = model_inp[784:780]; // 18.0
    wire [5:0] v208; assign v208[5:0] = model_inp[790:785]; // 18.0
    wire [4:0] v209; assign v209[4:0] = model_inp[795:791]; // 18.0
    wire [8:0] v210; assign v210[8:0] = model_inp[804:796]; // 18.0
    wire [7:0] v211; assign v211[7:0] = model_inp[812:805]; // 18.0
    wire [4:0] v212; assign v212[4:0] = model_inp[817:813]; // 18.0
    wire [2:0] v213; assign v213[2:0] = model_inp[820:818]; // 18.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[13:0] = v205[13:0];
    assign model_out[24:14] = v174[10:0];
    assign model_out[35:25] = v181[10:0];
    assign model_out[45:36] = v137[9:0];
    assign model_out[56:46] = v133[10:0];
    assign model_out[69:57] = v182[12:0];
    assign model_out[77:70] = v143[7:0];
    assign model_out[89:78] = v183[11:0];
    assign model_out[101:90] = v146[11:0];
    assign model_out[113:102] = v184[11:0];
    assign model_out[127:114] = v185[13:0];
    assign model_out[135:128] = v187[7:0];
    assign model_out[145:136] = v156[9:0];
    assign model_out[155:146] = v189[9:0];
    assign model_out[161:156] = v198[5:0];
    assign model_out[166:162] = v203[4:0];
    assign model_out[176:167] = v122[9:0];
    assign model_out[188:177] = v180[11:0];
    assign model_out[192:189] = v37[3:0];
    assign model_out[201:193] = v17[8:0];
    assign model_out[206:202] = v206[4:0];
    assign model_out[211:207] = v207[4:0];
    assign model_out[217:212] = v208[5:0];
    assign model_out[229:218] = v142[11:0];
    assign model_out[234:230] = v209[4:0];
    assign model_out[247:235] = v192[12:0];
    assign model_out[259:248] = v172[11:0];
    assign model_out[266:260] = v179[6:0];
    assign model_out[273:267] = v8[6:0];
    assign model_out[282:274] = v210[8:0];
    assign model_out[293:283] = v140[10:0];
    assign model_out[301:294] = v211[7:0];
    assign model_out[313:302] = v193[11:0];
    assign model_out[324:314] = v204[10:0];
    assign model_out[329:325] = v212[4:0];
    assign model_out[341:330] = v188[11:0];
    assign model_out[352:342] = v155[10:0];
    assign model_out[357:353] = v57[4:0];
    assign model_out[360:358] = v213[2:0];
    assign model_out[373:361] = v191[12:0];
    assign model_out[386:374] = v190[12:0];
    assign model_out[397:387] = v161[10:0];

endmodule
