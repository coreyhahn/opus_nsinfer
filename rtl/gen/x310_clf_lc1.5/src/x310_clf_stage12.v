`timescale 1 ns / 1 ps

module x310_clf_stage12 (
    input [820:0] model_inp,
    output [691:0] model_out
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
    wire [3:0] v126; assign v126[3:0] = model_inp[647:644]; // 18.0
    wire [9:0] v127; assign v127[9:0] = model_inp[657:648]; // 18.0
    wire [10:0] v128; assign v128[10:0] = model_inp[668:658]; // 18.0
    wire [9:0] v129; assign v129[9:0] = model_inp[678:669]; // 18.0
    wire [7:0] v130; assign v130[7:0] = model_inp[686:679]; // 18.0
    wire [9:0] v131; assign v131[9:0] = model_inp[696:687]; // 18.0
    wire [8:0] v132; assign v132[8:0] = model_inp[705:697]; // 18.0
    wire [8:0] v133; assign v133[8:0] = model_inp[714:706]; // 18.0
    wire [6:0] v134; assign v134[6:0] = model_inp[721:715]; // 18.0
    wire [6:0] v135; assign v135[6:0] = model_inp[728:722]; // 18.0
    wire [3:0] v136; assign v136[3:0] = model_inp[732:729]; // 18.0
    wire [9:0] v137; assign v137[9:0] = model_inp[742:733]; // 18.0
    wire [9:0] v138; assign v138[9:0] = model_inp[752:743]; // 18.0
    wire [3:0] v139; assign v139[3:0] = model_inp[756:753]; // 18.0
    wire [3:0] v140; assign v140[3:0] = model_inp[760:757]; // 18.0
    wire [13:0] v141; assign v141[13:0] = model_inp[774:761]; // 18.0
    wire [4:0] v142; assign v142[4:0] = model_inp[779:775]; // 18.0
    wire [4:0] v143; assign v143[4:0] = model_inp[784:780]; // 18.0
    wire [5:0] v144; assign v144[5:0] = model_inp[790:785]; // 18.0
    wire [4:0] v145; assign v145[4:0] = model_inp[795:791]; // 18.0
    wire [8:0] v146; assign v146[8:0] = model_inp[804:796]; // 18.0
    wire [7:0] v147; assign v147[7:0] = model_inp[812:805]; // 18.0
    wire [4:0] v148; assign v148[4:0] = model_inp[817:813]; // 18.0
    wire [2:0] v149; assign v149[2:0] = model_inp[820:818]; // 18.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[7:0] = v2[7:0];
    assign model_out[17:8] = v5[9:0];
    assign model_out[24:18] = v8[6:0];
    assign model_out[33:25] = v11[8:0];
    assign model_out[37:34] = v126[3:0];
    assign model_out[48:38] = v14[10:0];
    assign model_out[58:49] = v20[9:0];
    assign model_out[69:59] = v23[10:0];
    assign model_out[80:70] = v25[10:0];
    assign model_out[89:81] = v28[8:0];
    assign model_out[98:90] = v30[8:0];
    assign model_out[103:99] = v109[4:0];
    assign model_out[113:104] = v33[9:0];
    assign model_out[116:114] = v43[2:0];
    assign model_out[124:117] = v36[7:0];
    assign model_out[134:125] = v127[9:0];
    assign model_out[143:135] = v39[8:0];
    assign model_out[152:144] = v42[8:0];
    assign model_out[159:153] = v45[6:0];
    assign model_out[170:160] = v48[10:0];
    assign model_out[181:171] = v128[10:0];
    assign model_out[191:182] = v53[9:0];
    assign model_out[201:192] = v129[9:0];
    assign model_out[211:202] = v56[9:0];
    assign model_out[215:212] = v34[3:0];
    assign model_out[222:216] = v59[6:0];
    assign model_out[232:223] = v61[9:0];
    assign model_out[240:233] = v130[7:0];
    assign model_out[252:241] = v64[11:0];
    assign model_out[259:253] = v65[6:0];
    assign model_out[270:260] = v68[10:0];
    assign model_out[279:271] = v74[8:0];
    assign model_out[290:280] = v73[10:0];
    assign model_out[300:291] = v131[9:0];
    assign model_out[313:301] = v76[12:0];
    assign model_out[324:314] = v79[10:0];
    assign model_out[333:325] = v132[8:0];
    assign model_out[343:334] = v82[9:0];
    assign model_out[352:344] = v133[8:0];
    assign model_out[362:353] = v85[9:0];
    assign model_out[369:363] = v134[6:0];
    assign model_out[380:370] = v87[10:0];
    assign model_out[390:381] = v93[9:0];
    assign model_out[397:391] = v135[6:0];
    assign model_out[407:398] = v95[9:0];
    assign model_out[418:408] = v98[10:0];
    assign model_out[428:419] = v102[9:0];
    assign model_out[439:429] = v104[10:0];
    assign model_out[450:440] = v108[10:0];
    assign model_out[456:451] = v18[5:0];
    assign model_out[460:457] = v136[3:0];
    assign model_out[469:461] = v111[8:0];
    assign model_out[480:470] = v117[10:0];
    assign model_out[490:481] = v99[9:0];
    assign model_out[500:491] = v137[9:0];
    assign model_out[511:501] = v119[10:0];
    assign model_out[521:512] = v138[9:0];
    assign model_out[525:522] = v139[3:0];
    assign model_out[537:526] = v50[11:0];
    assign model_out[547:538] = v70[9:0];
    assign model_out[551:548] = v140[3:0];
    assign model_out[560:552] = v90[8:0];
    assign model_out[572:561] = v100[11:0];
    assign model_out[583:573] = v106[10:0];
    assign model_out[594:584] = v114[10:0];
    assign model_out[603:595] = v125[8:0];
    assign model_out[617:604] = v141[13:0];
    assign model_out[627:618] = v122[9:0];
    assign model_out[631:628] = v37[3:0];
    assign model_out[640:632] = v17[8:0];
    assign model_out[645:641] = v142[4:0];
    assign model_out[650:646] = v143[4:0];
    assign model_out[656:651] = v144[5:0];
    assign model_out[661:657] = v145[4:0];
    assign model_out[670:662] = v146[8:0];
    assign model_out[678:671] = v147[7:0];
    assign model_out[683:679] = v148[4:0];
    assign model_out[688:684] = v57[4:0];
    assign model_out[691:689] = v149[2:0];

endmodule
