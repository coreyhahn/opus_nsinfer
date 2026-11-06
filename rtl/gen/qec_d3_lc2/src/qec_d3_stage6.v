`timescale 1 ns / 1 ps

module qec_d3_stage6 (
    input [1206:0] model_inp,
    output [563:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [9:0] v0; assign v0[9:0] = model_inp[9:0]; // 12.0
    wire [11:0] v1; assign v1[11:0] = model_inp[21:10]; // 12.0
    wire [11:0] v2; shift_adder #(10, 12, 1, 1, 12, 0, 0) op_2 (v0[9:0], v1[11:0], v2[11:0]); // 13.0
    wire [11:0] v3; shift_adder #(12, 2, 1, 0, 12, 0, 1) op_3 (v2[11:0], 2'b10, v3[11:0]); // 13.0
    wire [9:0] v4; assign v4[9:0] = v3[9:0] & {10{~v3[11]}}; // 13.0
    wire [9:0] v5; shift_adder #(10, 3, 0, 0, 10, 0, 0) op_5 (v4[9:0], 3'b100, v5[9:0]); // 13.0
    wire [4:0] v6; assign v6[4:0] = v5[7:3]; // 13.0
    wire [10:0] v7; assign v7[10:0] = model_inp[32:22]; // 12.0
    wire [8:0] v8; assign v8[8:0] = model_inp[41:33]; // 12.0
    wire [10:0] v9; shift_adder #(11, 9, 1, 1, 11, 0, 1) op_9 (v7[10:0], v8[8:0], v9[10:0]); // 13.0
    wire [10:0] v10; assign v10[10:0] = model_inp[52:42]; // 12.0
    wire [8:0] v11; assign v11[8:0] = model_inp[61:53]; // 12.0
    wire [11:0] v12; shift_adder #(11, 9, 1, 1, 12, 1, 1) op_12 (v10[10:0], v11[8:0], v12[11:0]); // 13.0
    wire [8:0] v13; assign v13[8:0] = model_inp[70:62]; // 12.0
    wire [12:0] v14; assign v14[12:0] = model_inp[83:71]; // 12.0
    wire [13:0] v15; shift_adder #(9, 13, 1, 1, 14, -3, 0) op_15 (v13[8:0], v14[12:0], v15[13:0]); // 13.0
    wire [2:0] v16; assign v16[2:0] = model_inp[86:84]; // 12.0
    wire [9:0] v17; assign v17[9:0] = model_inp[96:87]; // 12.0
    wire [9:0] v18; shift_adder #(3, 10, 0, 1, 10, -1, 1) op_18 (v16[2:0], v17[9:0], v18[9:0]); // 13.0
    wire [8:0] v19; assign v19[8:0] = model_inp[105:97]; // 12.0
    wire [11:0] v20; assign v20[11:0] = model_inp[117:106]; // 12.0
    wire [11:0] v21; shift_adder #(9, 12, 1, 1, 12, -1, 0) op_21 (v19[8:0], v20[11:0], v21[11:0]); // 13.0
    wire [11:0] v22; assign v22[11:0] = model_inp[129:118]; // 12.0
    wire [11:0] v23; assign v23[11:0] = model_inp[141:130]; // 12.0
    wire [13:0] v24; shift_adder #(12, 12, 1, 1, 14, -2, 0) op_24 (v22[11:0], v23[11:0], v24[13:0]); // 13.0
    wire [0:0] v25; assign v25[0:0] = model_inp[142:142]; // 12.0
    wire [8:0] v26; assign v26[8:0] = model_inp[151:143]; // 12.0
    wire [8:0] v27; shift_adder #(1, 9, 0, 1, 9, -3, 1) op_27 (v25[0:0], v26[8:0], v27[8:0]); // 13.0
    wire [10:0] v28; assign v28[10:0] = model_inp[162:152]; // 12.0
    wire [10:0] v29; assign v29[10:0] = model_inp[173:163]; // 12.0
    wire [11:0] v30; shift_adder #(11, 11, 1, 1, 12, 1, 1) op_30 (v28[10:0], v29[10:0], v30[11:0]); // 13.0
    wire [10:0] v31; assign v31[10:0] = model_inp[184:174]; // 12.0
    wire [7:0] v32; assign v32[7:0] = model_inp[192:185]; // 12.0
    wire [11:0] v33; shift_adder #(11, 8, 1, 1, 12, 0, 1) op_33 (v31[10:0], v32[7:0], v33[11:0]); // 13.0
    wire [10:0] v34; assign v34[10:0] = model_inp[203:193]; // 12.0
    wire [11:0] v35; shift_adder #(9, 11, 1, 1, 12, -2, 0) op_35 (v8[8:0], v34[10:0], v35[11:0]); // 13.0
    wire [1:0] v36; assign v36[1:0] = model_inp[205:204]; // 12.0
    wire [10:0] v37; assign v37[10:0] = model_inp[216:206]; // 12.0
    wire [10:0] v38; shift_adder #(2, 11, 0, 1, 11, -4, 1) op_38 (v36[1:0], v37[10:0], v38[10:0]); // 13.0
    wire [5:0] v39; assign v39[5:0] = model_inp[222:217]; // 12.0
    wire [10:0] v40; assign v40[10:0] = model_inp[233:223]; // 12.0
    wire [10:0] v41; shift_adder #(6, 11, 1, 1, 11, -3, 1) op_41 (v39[5:0], v40[10:0], v41[10:0]); // 13.0
    wire [0:0] v42; assign v42[0:0] = model_inp[234:234]; // 12.0
    wire [9:0] v43; assign v43[9:0] = model_inp[244:235]; // 12.0
    wire [9:0] v44; shift_adder #(1, 10, 0, 1, 10, -4, 1) op_44 (v42[0:0], v43[9:0], v44[9:0]); // 13.0
    wire [8:0] v45; assign v45[8:0] = model_inp[253:245]; // 12.0
    wire [9:0] v46; assign v46[9:0] = model_inp[263:254]; // 12.0
    wire [10:0] v47; shift_adder #(9, 10, 1, 1, 11, 0, 0) op_47 (v45[8:0], v46[9:0], v47[10:0]); // 13.0
    wire [1:0] v48; assign v48[1:0] = model_inp[265:264]; // 12.0
    wire [8:0] v49; assign v49[8:0] = model_inp[274:266]; // 12.0
    wire [8:0] v50; shift_adder #(2, 9, 0, 1, 9, -2, 0) op_50 (v48[1:0], v49[8:0], v50[8:0]); // 13.0
    wire [9:0] v51; assign v51[9:0] = model_inp[284:275]; // 12.0
    wire [9:0] v52; assign v52[9:0] = model_inp[294:285]; // 12.0
    wire [11:0] v53; shift_adder #(10, 10, 1, 1, 12, 1, 1) op_53 (v51[9:0], v52[9:0], v53[11:0]); // 13.0
    wire [11:0] v54; assign v54[11:0] = model_inp[306:295]; // 12.0
    wire [10:0] v55; assign v55[10:0] = model_inp[317:307]; // 12.0
    wire [11:0] v56; shift_adder #(12, 11, 1, 1, 12, 1, 1) op_56 (v54[11:0], v55[10:0], v56[11:0]); // 13.0
    wire [1:0] v57; assign v57[1:0] = model_inp[319:318]; // 12.0
    wire [7:0] v58; assign v58[7:0] = model_inp[327:320]; // 12.0
    wire [7:0] v59; shift_adder #(2, 8, 0, 1, 8, -1, 0) op_59 (v57[1:0], v58[7:0], v59[7:0]); // 13.0
    wire [8:0] v60; assign v60[8:0] = model_inp[336:328]; // 12.0
    wire [2:0] v61; assign v61[2:0] = model_inp[339:337]; // 12.0
    wire [8:0] v62; shift_adder #(9, 3, 1, 0, 9, 2, 0) op_62 (v60[8:0], v61[2:0], v62[8:0]); // 13.0
    wire [9:0] v63; assign v63[9:0] = model_inp[349:340]; // 12.0
    wire [9:0] v64; assign v64[9:0] = model_inp[359:350]; // 12.0
    wire [10:0] v65; shift_adder #(10, 10, 1, 1, 11, -1, 0) op_65 (v63[9:0], v64[9:0], v65[10:0]); // 13.0
    wire [11:0] v66; assign v66[11:0] = model_inp[371:360]; // 12.0
    wire [9:0] v67; assign v67[9:0] = model_inp[381:372]; // 12.0
    wire [11:0] v68; shift_adder #(12, 10, 1, 1, 12, 1, 0) op_68 (v66[11:0], v67[9:0], v68[11:0]); // 13.0
    wire [9:0] v69; assign v69[9:0] = model_inp[391:382]; // 12.0
    wire [9:0] v70; assign v70[9:0] = model_inp[401:392]; // 12.0
    wire [11:0] v71; shift_adder #(10, 10, 1, 1, 12, -1, 0) op_71 (v69[9:0], v70[9:0], v71[11:0]); // 13.0
    wire [7:0] v72; assign v72[7:0] = model_inp[409:402]; // 12.0
    wire [11:0] v73; assign v73[11:0] = model_inp[421:410]; // 12.0
    wire [12:0] v74; shift_adder #(8, 12, 1, 1, 13, -3, 0) op_74 (v72[7:0], v73[11:0], v74[12:0]); // 13.0
    wire [1:0] v75; assign v75[1:0] = model_inp[423:422]; // 12.0
    wire [7:0] v76; assign v76[7:0] = model_inp[431:424]; // 12.0
    wire [8:0] v77; shift_adder #(2, 8, 0, 1, 9, -1, 1) op_77 (v75[1:0], v76[7:0], v77[8:0]); // 13.0
    wire [9:0] v78; assign v78[9:0] = model_inp[441:432]; // 12.0
    wire [10:0] v79; assign v79[10:0] = model_inp[452:442]; // 12.0
    wire [11:0] v80; shift_adder #(10, 11, 1, 1, 12, -1, 0) op_80 (v78[9:0], v79[10:0], v80[11:0]); // 13.0
    wire [11:0] v81; assign v81[11:0] = model_inp[464:453]; // 12.0
    wire [4:0] v82; assign v82[4:0] = model_inp[469:465]; // 12.0
    wire [11:0] v83; shift_adder #(12, 5, 1, 0, 12, 0, 0) op_83 (v81[11:0], v82[4:0], v83[11:0]); // 13.0
    wire [11:0] v84; shift_adder #(12, 3, 1, 0, 12, 0, 1) op_84 (v83[11:0], 3'b111, v84[11:0]); // 13.0
    wire [9:0] v85; assign v85[9:0] = v84[9:0] & {10{~v84[11]}}; // 13.0
    wire [9:0] v86; shift_adder #(10, 3, 0, 0, 10, 0, 0) op_86 (v85[9:0], 3'b100, v86[9:0]); // 13.0
    wire [3:0] v87; assign v87[3:0] = v86[6:3]; // 13.0
    wire [10:0] v88; assign v88[10:0] = model_inp[480:470]; // 12.0
    wire [8:0] v89; assign v89[8:0] = model_inp[489:481]; // 12.0
    wire [11:0] v90; shift_adder #(11, 9, 1, 1, 12, 2, 1) op_90 (v88[10:0], v89[8:0], v90[11:0]); // 13.0
    wire [9:0] v91; assign v91[9:0] = v90[9:0] & {10{~v90[11]}}; // 13.0
    wire [9:0] v92; shift_adder #(10, 4, 0, 0, 10, 0, 0) op_92 (v91[9:0], 4'b1000, v92[9:0]); // 13.0
    wire [3:0] v93; assign v93[3:0] = v92[7:4]; // 13.0
    wire [9:0] v94; assign v94[9:0] = model_inp[499:490]; // 12.0
    wire [9:0] v95; assign v95[9:0] = model_inp[509:500]; // 12.0
    wire [11:0] v96; shift_adder #(10, 10, 1, 1, 12, -2, 1) op_96 (v94[9:0], v95[9:0], v96[11:0]); // 13.0
    wire [11:0] v97; assign v97[11:0] = model_inp[521:510]; // 12.0
    wire [10:0] v98; assign v98[10:0] = model_inp[532:522]; // 12.0
    wire [11:0] v99; shift_adder #(12, 11, 1, 1, 12, 1, 0) op_99 (v97[11:0], v98[10:0], v99[11:0]); // 13.0
    wire [3:0] v100; assign v100[3:0] = model_inp[536:533]; // 12.0
    wire [1:0] v101; assign v101[1:0] = model_inp[538:537]; // 12.0
    wire [4:0] v102; shift_adder #(4, 2, 0, 0, 5, 1, 0) op_102 (v100[3:0], v101[1:0], v102[4:0]); // 13.0
    wire [10:0] v103; assign v103[10:0] = model_inp[549:539]; // 12.0
    wire [11:0] v104; shift_adder #(9, 11, 1, 1, 12, -1, 0) op_104 (v19[8:0], v103[10:0], v104[11:0]); // 13.0
    wire [9:0] v105; assign v105[9:0] = v104[9:0] & {10{~v104[11]}}; // 13.0
    wire [9:0] v106; shift_adder #(10, 4, 0, 0, 10, 0, 0) op_106 (v105[9:0], 4'b1000, v106[9:0]); // 13.0
    wire [3:0] v107; assign v107[3:0] = v106[7:4]; // 13.0
    wire [2:0] v108; assign v108[2:0] = model_inp[552:550]; // 12.0
    wire [0:0] v109; assign v109[0:0] = model_inp[553:553]; // 12.0
    wire [3:0] v110; shift_adder #(3, 1, 0, 0, 4, 0, 1) op_110 (v108[2:0], v109[0:0], v110[3:0]); // 13.0
    wire [7:0] v111; assign v111[7:0] = model_inp[561:554]; // 12.0
    wire [11:0] v112; assign v112[11:0] = model_inp[573:562]; // 12.0
    wire [11:0] v113; shift_adder #(8, 12, 1, 1, 12, -2, 0) op_113 (v111[7:0], v112[11:0], v113[11:0]); // 13.0
    wire [11:0] v114; shift_adder #(12, 3, 1, 0, 12, 0, 1) op_114 (v113[11:0], 3'b100, v114[11:0]); // 13.0
    wire [9:0] v115; assign v115[9:0] = v114[9:0] & {10{~v114[11]}}; // 13.0
    wire [9:0] v116; shift_adder #(10, 3, 0, 0, 10, 0, 0) op_116 (v115[9:0], 3'b100, v116[9:0]); // 13.0
    wire [4:0] v117; assign v117[4:0] = v116[7:3]; // 13.0
    wire [9:0] v118; assign v118[9:0] = model_inp[583:574]; // 12.0
    wire [10:0] v119; assign v119[10:0] = model_inp[594:584]; // 12.0
    wire [10:0] v120; shift_adder #(10, 11, 1, 1, 11, 0, 0) op_120 (v118[9:0], v119[10:0], v120[10:0]); // 13.0
    wire [9:0] v121; assign v121[9:0] = model_inp[604:595]; // 12.0
    wire [10:0] v122; assign v122[10:0] = model_inp[615:605]; // 12.0
    wire [10:0] v123; shift_adder #(10, 11, 1, 1, 11, 0, 0) op_123 (v121[9:0], v122[10:0], v123[10:0]); // 13.0
    wire [10:0] v124; assign v124[10:0] = model_inp[626:616]; // 12.0
    wire [8:0] v125; assign v125[8:0] = model_inp[635:627]; // 12.0
    wire [11:0] v126; shift_adder #(11, 9, 1, 1, 12, 1, 1) op_126 (v124[10:0], v125[8:0], v126[11:0]); // 13.0
    wire [7:0] v127; assign v127[7:0] = model_inp[643:636]; // 12.0
    wire [3:0] v128; assign v128[3:0] = model_inp[647:644]; // 12.0
    wire [7:0] v129; shift_adder #(8, 4, 1, 0, 8, 0, 0) op_129 (v127[7:0], v128[3:0], v129[7:0]); // 13.0
    wire [8:0] v130; assign v130[8:0] = model_inp[656:648]; // 12.0
    wire [9:0] v131; assign v131[9:0] = model_inp[666:657]; // 12.0
    wire [10:0] v132; shift_adder #(9, 10, 1, 1, 11, -1, 0) op_132 (v130[8:0], v131[9:0], v132[10:0]); // 13.0
    wire [8:0] v133; assign v133[8:0] = model_inp[675:667]; // 12.0
    wire [11:0] v134; assign v134[11:0] = model_inp[687:676]; // 12.0
    wire [11:0] v135; shift_adder #(9, 12, 1, 1, 12, 0, 0) op_135 (v133[8:0], v134[11:0], v135[11:0]); // 13.0
    wire [10:0] v136; assign v136[10:0] = model_inp[698:688]; // 12.0
    wire [10:0] v137; assign v137[10:0] = model_inp[709:699]; // 12.0
    wire [11:0] v138; shift_adder #(11, 11, 1, 1, 12, -1, 1) op_138 (v136[10:0], v137[10:0], v138[11:0]); // 13.0
    wire [12:0] v139; assign v139[12:0] = model_inp[722:710]; // 12.0
    wire [7:0] v140; assign v140[7:0] = model_inp[730:723]; // 12.0
    wire [13:0] v141; shift_adder #(13, 8, 1, 1, 14, 3, 0) op_141 (v139[12:0], v140[7:0], v141[13:0]); // 13.0
    wire [11:0] v142; assign v142[11:0] = model_inp[742:731]; // 12.0
    wire [10:0] v143; assign v143[10:0] = model_inp[753:743]; // 12.0
    wire [12:0] v144; shift_adder #(12, 11, 1, 1, 13, 1, 0) op_144 (v142[11:0], v143[10:0], v144[12:0]); // 13.0
    wire [12:0] v145; shift_adder #(13, 3, 1, 0, 13, 0, 0) op_145 (v144[12:0], 3'b100, v145[12:0]); // 13.0
    wire [9:0] v146; assign v146[9:0] = v145[9:0] & {10{~v145[12]}}; // 13.0
    wire [9:0] v147; shift_adder #(10, 4, 0, 0, 10, 0, 0) op_147 (v146[9:0], 4'b1000, v147[9:0]); // 13.0
    wire [2:0] v148; assign v148[2:0] = v147[6:4]; // 13.0
    wire [2:0] v149; assign v149[2:0] = model_inp[756:754]; // 12.0
    wire [2:0] v150; assign v150[2:0] = model_inp[759:757]; // 12.0
    wire [4:0] v151; shift_adder #(3, 3, 0, 0, 5, -1, 1) op_151 (v149[2:0], v150[2:0], v151[4:0]); // 13.0
    wire [9:0] v152; assign v152[9:0] = model_inp[769:760]; // 12.0
    wire [11:0] v153; assign v153[11:0] = model_inp[781:770]; // 12.0
    wire [12:0] v154; shift_adder #(10, 12, 1, 1, 13, -2, 0) op_154 (v152[9:0], v153[11:0], v154[12:0]); // 13.0
    wire [8:0] v155; assign v155[8:0] = model_inp[790:782]; // 12.0
    wire [10:0] v156; assign v156[10:0] = model_inp[801:791]; // 12.0
    wire [10:0] v157; shift_adder #(9, 11, 1, 1, 11, 0, 1) op_157 (v155[8:0], v156[10:0], v157[10:0]); // 13.0
    wire [10:0] v158; assign v158[10:0] = model_inp[812:802]; // 12.0
    wire [10:0] v159; assign v159[10:0] = model_inp[823:813]; // 12.0
    wire [11:0] v160; shift_adder #(11, 11, 1, 1, 12, -1, 0) op_160 (v158[10:0], v159[10:0], v160[11:0]); // 13.0
    wire [9:0] v161; assign v161[9:0] = model_inp[833:824]; // 12.0
    wire [8:0] v162; assign v162[8:0] = model_inp[842:834]; // 12.0
    wire [9:0] v163; shift_adder #(10, 9, 1, 1, 10, 0, 1) op_163 (v161[9:0], v162[8:0], v163[9:0]); // 13.0
    wire [10:0] v164; shift_adder #(10, 2, 1, 0, 11, -1, 0) op_164 (v163[9:0], 2'b11, v164[10:0]); // 13.0
    wire [9:0] v165; assign v165[9:0] = v164[9:0] & {10{~v164[10]}}; // 13.0
    wire [9:0] v166; shift_adder #(10, 4, 0, 0, 10, 0, 0) op_166 (v165[9:0], 4'b1000, v166[9:0]); // 13.0
    wire [3:0] v167; assign v167[3:0] = v166[7:4]; // 13.0
    wire [9:0] v168; assign v168[9:0] = model_inp[852:843]; // 12.0
    wire [9:0] v169; assign v169[9:0] = model_inp[862:853]; // 12.0
    wire [10:0] v170; shift_adder #(10, 10, 1, 1, 11, 0, 0) op_170 (v168[9:0], v169[9:0], v170[10:0]); // 13.0
    wire [7:0] v171; assign v171[7:0] = model_inp[870:863]; // 12.0
    wire [8:0] v172; shift_adder #(8, 8, 1, 1, 9, 1, 1) op_172 (v32[7:0], v171[7:0], v172[8:0]); // 13.0
    wire [9:0] v173; assign v173[9:0] = model_inp[880:871]; // 12.0
    wire [10:0] v174; assign v174[10:0] = model_inp[891:881]; // 12.0
    wire [11:0] v175; shift_adder #(10, 11, 1, 1, 12, 0, 0) op_175 (v173[9:0], v174[10:0], v175[11:0]); // 13.0
    wire [9:0] v176; assign v176[9:0] = model_inp[901:892]; // 12.0
    wire [8:0] v177; assign v177[8:0] = model_inp[910:902]; // 12.0
    wire [10:0] v178; shift_adder #(10, 9, 1, 1, 11, 1, 1) op_178 (v176[9:0], v177[8:0], v178[10:0]); // 13.0
    wire [1:0] v179; assign v179[1:0] = model_inp[912:911]; // 12.0
    wire [8:0] v180; assign v180[8:0] = model_inp[921:913]; // 12.0
    wire [8:0] v181; shift_adder #(2, 9, 0, 1, 9, -2, 1) op_181 (v179[1:0], v180[8:0], v181[8:0]); // 13.0
    wire [4:0] v182; assign v182[4:0] = model_inp[926:922]; // 12.0
    wire [2:0] v183; assign v183[2:0] = model_inp[929:927]; // 12.0
    wire [4:0] v184; shift_adder #(5, 3, 1, 0, 5, 0, 0) op_184 (v182[4:0], v183[2:0], v184[4:0]); // 13.0
    wire [3:0] v185; assign v185[3:0] = model_inp[933:930]; // 12.0
    wire [6:0] v186; shift_adder #(4, 4, 0, 0, 7, -2, 1) op_186 (v185[3:0], v185[3:0], v186[6:0]); // 13.0
    wire [9:0] v187; assign v187[9:0] = model_inp[943:934]; // 12.0
    wire [10:0] v188; assign v188[10:0] = model_inp[954:944]; // 12.0
    wire [11:0] v189; shift_adder #(10, 11, 1, 1, 12, 0, 0) op_189 (v187[9:0], v188[10:0], v189[11:0]); // 13.0
    wire [7:0] v190; assign v190[7:0] = v189[7:0] & {8{~v189[11]}}; // 13.0
    wire [8:0] v191; shift_adder #(8, 3, 0, 0, 9, 0, 0) op_191 (v190[7:0], 3'b100, v191[8:0]); // 13.0
    wire [3:0] v192; assign v192[3:0] = v191[6:3]; // 13.0
    wire [9:0] v193; assign v193[9:0] = model_inp[964:955]; // 12.0
    wire [8:0] v194; assign v194[8:0] = model_inp[973:965]; // 12.0
    wire [10:0] v195; shift_adder #(10, 9, 1, 1, 11, 0, 1) op_195 (v193[9:0], v194[8:0], v195[10:0]); // 13.0
    wire [9:0] v196; assign v196[9:0] = model_inp[983:974]; // 12.0
    wire [10:0] v197; shift_adder #(8, 10, 1, 1, 11, -2, 0) op_197 (v140[7:0], v196[9:0], v197[10:0]); // 13.0
    wire [9:0] v198; assign v198[9:0] = model_inp[993:984]; // 12.0
    wire [9:0] v199; shift_adder #(10, 9, 1, 1, 10, 0, 0) op_199 (v198[9:0], v130[8:0], v199[9:0]); // 13.0
    wire [10:0] v200; assign v200[10:0] = model_inp[1004:994]; // 12.0
    wire [11:0] v201; assign v201[11:0] = model_inp[1016:1005]; // 12.0
    wire [11:0] v202; shift_adder #(11, 12, 1, 1, 12, 0, 0) op_202 (v200[10:0], v201[11:0], v202[11:0]); // 13.0
    wire [9:0] v203; assign v203[9:0] = model_inp[1026:1017]; // 12.0
    wire [11:0] v204; assign v204[11:0] = model_inp[1038:1027]; // 12.0
    wire [12:0] v205; shift_adder #(10, 12, 1, 1, 13, -1, 0) op_205 (v203[9:0], v204[11:0], v205[12:0]); // 13.0
    wire [8:0] v206; assign v206[8:0] = model_inp[1047:1039]; // 12.0
    wire [9:0] v207; shift_adder #(9, 9, 1, 1, 10, 0, 0) op_207 (v206[8:0], v194[8:0], v207[9:0]); // 13.0
    wire [3:0] v208; shift_adder #(2, 3, 0, 0, 4, -1, 0) op_208 (v101[1:0], v149[2:0], v208[3:0]); // 13.0
    wire [10:0] v209; assign v209[10:0] = model_inp[1058:1048]; // 12.0
    wire [9:0] v210; assign v210[9:0] = model_inp[1068:1059]; // 12.0
    wire [10:0] v211; shift_adder #(11, 10, 1, 1, 11, 0, 1) op_211 (v209[10:0], v210[9:0], v211[10:0]); // 13.0
    wire [10:0] v212; shift_adder #(11, 1, 1, 0, 11, 0, 0) op_212 (v211[10:0], 1'b1, v212[10:0]); // 13.0
    wire [8:0] v213; assign v213[8:0] = v212[8:0] & {9{~v212[10]}}; // 13.0
    wire [8:0] v214; shift_adder #(9, 3, 0, 0, 9, 0, 0) op_214 (v213[8:0], 3'b100, v214[8:0]); // 13.0
    wire [2:0] v215; assign v215[2:0] = v214[5:3]; // 13.0
    wire [0:0] v216; assign v216[0:0] = model_inp[1069:1069]; // 12.0
    wire [1:0] v217; assign v217[1:0] = model_inp[1071:1070]; // 12.0
    wire [2:0] v218; shift_adder #(1, 2, 0, 0, 3, 0, 0) op_218 (v216[0:0], v217[1:0], v218[2:0]); // 13.0
    wire [3:0] v219; assign v219[3:0] = model_inp[1075:1072]; // 12.0
    wire [1:0] v220; assign v220[1:0] = model_inp[1077:1076]; // 12.0
    wire [4:0] v221; shift_adder #(4, 2, 0, 0, 5, 1, 0) op_221 (v219[3:0], v220[1:0], v221[4:0]); // 13.0
    wire [2:0] v222; assign v222[2:0] = model_inp[1080:1078]; // 12.0
    wire [3:0] v223; shift_adder #(3, 3, 0, 0, 4, 0, 0) op_223 (v149[2:0], v222[2:0], v223[3:0]); // 13.0
    wire [3:0] v224; assign v224[3:0] = model_inp[1084:1081]; // 12.0
    wire [4:0] v225; shift_adder #(4, 3, 1, 0, 5, 0, 1) op_225 (v224[3:0], v149[2:0], v225[4:0]); // 13.0
    wire [12:0] v226; shift_adder #(11, 12, 1, 1, 13, -1, 0) op_226 (v9[10:0], v12[11:0], v226[12:0]); // 14.0
    wire [2:0] v227; assign v227[2:0] = model_inp[1087:1085]; // 12.0
    wire [9:0] v228; shift_adder #(3, 10, 0, 1, 10, -2, 1) op_228 (v227[2:0], v18[9:0], v228[9:0]); // 14.0
    wire [13:0] v229; shift_adder #(12, 14, 1, 1, 14, 0, 0) op_229 (v21[11:0], v24[13:0], v229[13:0]); // 14.0
    wire [12:0] v230; shift_adder #(12, 12, 1, 1, 13, 0, 0) op_230 (v30[11:0], v33[11:0], v230[12:0]); // 14.0
    wire [12:0] v231; shift_adder #(12, 11, 1, 1, 13, -1, 0) op_231 (v35[11:0], v38[10:0], v231[12:0]); // 14.0
    wire [5:0] v232; assign v232[5:0] = model_inp[1093:1088]; // 12.0
    wire [10:0] v233; shift_adder #(6, 11, 1, 1, 11, -2, 0) op_233 (v232[5:0], v41[10:0], v233[10:0]); // 14.0
    wire [10:0] v234; shift_adder #(10, 11, 1, 1, 11, 0, 0) op_234 (v44[9:0], v47[10:0], v234[10:0]); // 14.0
    wire [9:0] v235; assign v235[9:0] = model_inp[1103:1094]; // 12.0
    wire [10:0] v236; shift_adder #(10, 9, 1, 1, 11, 0, 0) op_236 (v235[9:0], v50[8:0], v236[10:0]); // 14.0
    wire [12:0] v237; shift_adder #(12, 12, 1, 1, 13, -1, 0) op_237 (v53[11:0], v56[11:0], v237[12:0]); // 14.0
    wire [1:0] v238; assign v238[1:0] = model_inp[1105:1104]; // 12.0
    wire [8:0] v239; shift_adder #(2, 9, 0, 1, 9, -3, 1) op_239 (v238[1:0], v62[8:0], v239[8:0]); // 14.0
    wire [12:0] v240; shift_adder #(11, 12, 1, 1, 13, 0, 0) op_240 (v65[10:0], v68[11:0], v240[12:0]); // 14.0
    wire [12:0] v241; shift_adder #(13, 4, 1, 0, 13, 0, 1) op_241 (v240[12:0], 4'b1100, v241[12:0]); // 14.0
    wire [10:0] v242; assign v242[10:0] = v241[10:0] & {11{~v241[12]}}; // 14.0
    wire [10:0] v243; shift_adder #(11, 4, 0, 0, 11, 0, 0) op_243 (v242[10:0], 4'b1000, v243[10:0]); // 14.0
    wire [4:0] v244; assign v244[4:0] = v243[8:4]; // 14.0
    wire [12:0] v245; shift_adder #(12, 13, 1, 1, 13, 0, 0) op_245 (v71[11:0], v74[12:0], v245[12:0]); // 14.0
    wire [9:0] v246; assign v246[9:0] = model_inp[1115:1106]; // 12.0
    wire [12:0] v247; shift_adder #(10, 12, 1, 1, 13, -1, 0) op_247 (v246[9:0], v80[11:0], v247[12:0]); // 14.0
    wire [11:0] v248; assign v248[11:0] = model_inp[1127:1116]; // 12.0
    wire [11:0] v249; shift_adder #(12, 9, 1, 1, 12, 0, 0) op_249 (v248[11:0], v27[8:0], v249[11:0]); // 14.0
    wire [5:0] v250; shift_adder #(4, 4, 0, 0, 6, -1, 0) op_250 (v87[3:0], v93[3:0], v250[5:0]); // 14.0
    wire [12:0] v251; shift_adder #(12, 12, 1, 1, 13, 0, 0) op_251 (v96[11:0], v99[11:0], v251[12:0]); // 14.0
    wire [12:0] v252; shift_adder #(13, 3, 1, 0, 13, 0, 0) op_252 (v251[12:0], 3'b100, v252[12:0]); // 14.0
    wire [11:0] v253; assign v253[11:0] = v252[11:0] & {12{~v252[12]}}; // 14.0
    wire [11:0] v254; shift_adder #(12, 4, 0, 0, 12, 0, 0) op_254 (v253[11:0], 4'b1000, v254[11:0]); // 14.0
    wire [4:0] v255; assign v255[4:0] = v254[8:4]; // 14.0
    wire [5:0] v256; shift_adder #(5, 4, 0, 0, 6, -1, 0) op_256 (v102[4:0], v107[3:0], v256[5:0]); // 14.0
    wire [6:0] v257; shift_adder #(4, 5, 1, 0, 7, -1, 1) op_257 (v110[3:0], v117[4:0], v257[6:0]); // 14.0
    wire [9:0] v258; assign v258[9:0] = model_inp[1137:1128]; // 12.0
    wire [11:0] v259; shift_adder #(11, 10, 1, 1, 12, 0, 1) op_259 (v120[10:0], v258[9:0], v259[11:0]); // 14.0
    wire [11:0] v260; shift_adder #(11, 12, 1, 1, 12, 0, 0) op_260 (v123[10:0], v126[11:0], v260[11:0]); // 14.0
    wire [8:0] v261; shift_adder #(8, 8, 1, 1, 9, 0, 0) op_261 (v129[7:0], v59[7:0], v261[8:0]); // 14.0
    wire [12:0] v262; shift_adder #(11, 11, 1, 1, 13, -1, 0) op_262 (v132[10:0], v38[10:0], v262[12:0]); // 14.0
    wire [13:0] v263; shift_adder #(12, 12, 1, 1, 14, 1, 0) op_263 (v135[11:0], v138[11:0], v263[13:0]); // 14.0
    wire [6:0] v264; shift_adder #(4, 5, 0, 1, 7, 1, 0) op_264 (v107[3:0], v151[4:0], v264[6:0]); // 14.0
    wire [12:0] v265; shift_adder #(10, 13, 1, 1, 13, -1, 0) op_265 (v44[9:0], v154[12:0], v265[12:0]); // 14.0
    wire [12:0] v266; shift_adder #(11, 12, 1, 1, 13, -1, 0) op_266 (v157[10:0], v160[11:0], v266[12:0]); // 14.0
    wire [12:0] v267; shift_adder #(13, 3, 1, 0, 13, 0, 0) op_267 (v266[12:0], 3'b110, v267[12:0]); // 14.0
    wire [11:0] v268; assign v268[11:0] = v267[11:0] & {12{~v267[12]}}; // 14.0
    wire [11:0] v269; shift_adder #(12, 3, 0, 0, 12, 0, 0) op_269 (v268[11:0], 3'b100, v269[11:0]); // 14.0
    wire [4:0] v270; assign v270[4:0] = v269[7:3]; // 14.0
    wire [4:0] v271; assign v271[4:0] = model_inp[1142:1138]; // 12.0
    wire [11:0] v272; shift_adder #(5, 11, 1, 1, 12, -2, 0) op_272 (v271[4:0], v170[10:0], v272[11:0]); // 14.0
    wire [11:0] v273; shift_adder #(12, 2, 1, 0, 12, 0, 1) op_273 (v272[11:0], 2'b10, v273[11:0]); // 14.0
    wire [9:0] v274; assign v274[9:0] = v273[9:0] & {10{~v273[11]}}; // 14.0
    wire [9:0] v275; shift_adder #(10, 2, 0, 0, 10, 0, 0) op_275 (v274[9:0], 2'b10, v275[9:0]); // 14.0
    wire [4:0] v276; assign v276[4:0] = v275[6:2]; // 14.0
    wire [11:0] v277; shift_adder #(9, 12, 1, 1, 12, 0, 0) op_277 (v172[8:0], v175[11:0], v277[11:0]); // 14.0
    wire [11:0] v278; shift_adder #(12, 2, 1, 0, 12, 0, 0) op_278 (v277[11:0], 2'b10, v278[11:0]); // 14.0
    wire [10:0] v279; assign v279[10:0] = v278[10:0] & {11{~v278[11]}}; // 14.0
    wire [10:0] v280; shift_adder #(11, 3, 0, 0, 11, 0, 0) op_280 (v279[10:0], 3'b100, v280[10:0]); // 14.0
    wire [5:0] v281; assign v281[5:0] = v280[8:3]; // 14.0
    wire [9:0] v282; assign v282[9:0] = model_inp[1152:1143]; // 12.0
    wire [10:0] v283; shift_adder #(10, 9, 1, 1, 11, 2, 0) op_283 (v282[9:0], v50[8:0], v283[10:0]); // 14.0
    wire [0:0] v284; assign v284[0:0] = model_inp[1153:1153]; // 12.0
    wire [8:0] v285; shift_adder #(1, 9, 0, 1, 9, -2, 0) op_285 (v284[0:0], v181[8:0], v285[8:0]); // 14.0
    wire [5:0] v286; shift_adder #(5, 3, 1, 0, 6, 1, 1) op_286 (v184[4:0], v222[2:0], v286[5:0]); // 14.0
    wire [7:0] v287; shift_adder #(7, 3, 1, 0, 8, 3, 0) op_287 (v186[6:0], v148[2:0], v287[7:0]); // 14.0
    wire [6:0] v288; shift_adder #(5, 4, 1, 0, 7, 1, 0) op_288 (v151[4:0], v192[3:0], v288[6:0]); // 14.0
    wire [11:0] v289; shift_adder #(11, 11, 1, 1, 12, -1, 1) op_289 (v195[10:0], v197[10:0], v289[11:0]); // 14.0
    wire [11:0] v290; shift_adder #(12, 3, 1, 0, 12, 0, 0) op_290 (v289[11:0], 3'b100, v290[11:0]); // 14.0
    wire [10:0] v291; assign v291[10:0] = v290[10:0] & {11{~v290[11]}}; // 14.0
    wire [10:0] v292; shift_adder #(11, 4, 0, 0, 11, 0, 0) op_292 (v291[10:0], 4'b1000, v292[10:0]); // 14.0
    wire [3:0] v293; assign v293[3:0] = v292[7:4]; // 14.0
    wire [9:0] v294; assign v294[9:0] = model_inp[1163:1154]; // 12.0
    wire [11:0] v295; shift_adder #(10, 10, 1, 1, 12, -1, 1) op_295 (v199[9:0], v294[9:0], v295[11:0]); // 14.0
    wire [10:0] v296; assign v296[10:0] = model_inp[1174:1164]; // 12.0
    wire [11:0] v297; shift_adder #(11, 8, 1, 1, 12, 2, 0) op_297 (v296[10:0], v129[7:0], v297[11:0]); // 14.0
    wire [11:0] v298; shift_adder #(12, 3, 1, 0, 12, 0, 0) op_298 (v297[11:0], 3'b100, v298[11:0]); // 14.0
    wire [9:0] v299; assign v299[9:0] = v298[9:0] & {10{~v298[11]}}; // 14.0
    wire [9:0] v300; shift_adder #(10, 5, 0, 0, 10, 0, 0) op_300 (v299[9:0], 5'b10000, v300[9:0]); // 14.0
    wire [2:0] v301; assign v301[2:0] = v300[7:5]; // 14.0
    wire [12:0] v302; shift_adder #(13, 10, 1, 1, 13, 1, 1) op_302 (v205[12:0], v207[9:0], v302[12:0]); // 14.0
    wire [12:0] v303; shift_adder #(13, 2, 1, 0, 13, 0, 0) op_303 (v302[12:0], 2'b10, v303[12:0]); // 14.0
    wire [9:0] v304; assign v304[9:0] = v303[9:0] & {10{~v303[12]}}; // 14.0
    wire [9:0] v305; shift_adder #(10, 3, 0, 0, 10, 0, 0) op_305 (v304[9:0], 3'b100, v305[9:0]); // 14.0
    wire [4:0] v306; assign v306[4:0] = v305[7:3]; // 14.0
    wire [3:0] v307; shift_adder #(3, 3, 0, 0, 4, 0, 1) op_307 (v215[2:0], v222[2:0], v307[3:0]); // 14.0
    wire [4:0] v308; shift_adder #(3, 4, 0, 0, 5, 0, 0) op_308 (v218[2:0], v192[3:0], v308[4:0]); // 14.0
    wire [4:0] v309; shift_adder #(4, 3, 0, 0, 5, 0, 1) op_309 (v167[3:0], v148[2:0], v309[4:0]); // 14.0
    wire [4:0] v310; assign v310[4:0] = model_inp[1179:1175]; // 12.0
    wire [5:0] v311; shift_adder #(4, 5, 0, 0, 6, -1, 0) op_311 (v93[3:0], v310[4:0], v311[5:0]); // 14.0
    wire [5:0] v312; shift_adder #(4, 5, 0, 0, 6, 1, 0) op_312 (v167[3:0], v221[4:0], v312[5:0]); // 14.0
    wire [7:0] v313; shift_adder #(4, 4, 0, 0, 8, -3, 1) op_313 (v87[3:0], v87[3:0], v313[7:0]); // 14.0
    wire [1:0] v314; assign v314[1:0] = model_inp[1181:1180]; // 12.0
    wire [3:0] v315; shift_adder #(3, 2, 0, 0, 4, 0, 0) op_315 (v148[2:0], v314[1:0], v315[3:0]); // 14.0
    wire [6:0] v316; shift_adder #(5, 5, 1, 0, 7, -1, 0) op_316 (v225[4:0], v117[4:0], v316[6:0]); // 14.0
    wire [2:0] v317; assign v317[2:0] = model_inp[1184:1182]; // 12.0
    wire [2:0] v318; assign v318[2:0] = model_inp[1187:1185]; // 12.0
    wire [1:0] v319; assign v319[1:0] = model_inp[1189:1188]; // 12.0
    wire [6:0] v320; assign v320[6:0] = model_inp[1196:1190]; // 12.0
    wire [2:0] v321; assign v321[2:0] = model_inp[1199:1197]; // 12.0
    wire [1:0] v322; assign v322[1:0] = model_inp[1201:1200]; // 12.0
    wire [1:0] v323; assign v323[1:0] = model_inp[1203:1202]; // 12.0
    wire [0:0] v324; assign v324[0:0] = model_inp[1204:1204]; // 12.0
    wire [1:0] v325; assign v325[1:0] = model_inp[1206:1205]; // 12.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[12:0] = v226[12:0];
    assign model_out[26:13] = v15[13:0];
    assign model_out[29:27] = v317[2:0];
    assign model_out[39:30] = v228[9:0];
    assign model_out[53:40] = v229[13:0];
    assign model_out[62:54] = v27[8:0];
    assign model_out[75:63] = v230[12:0];
    assign model_out[88:76] = v231[12:0];
    assign model_out[91:89] = v318[2:0];
    assign model_out[102:92] = v233[10:0];
    assign model_out[113:103] = v234[10:0];
    assign model_out[124:114] = v236[10:0];
    assign model_out[137:125] = v237[12:0];
    assign model_out[145:138] = v59[7:0];
    assign model_out[147:146] = v319[1:0];
    assign model_out[156:148] = v239[8:0];
    assign model_out[169:157] = v245[12:0];
    assign model_out[178:170] = v77[8:0];
    assign model_out[191:179] = v247[12:0];
    assign model_out[197:192] = v250[5:0];
    assign model_out[202:198] = v255[4:0];
    assign model_out[209:203] = v257[6:0];
    assign model_out[213:210] = v87[3:0];
    assign model_out[225:214] = v259[11:0];
    assign model_out[230:226] = v271[4:0];
    assign model_out[242:231] = v260[11:0];
    assign model_out[251:243] = v261[8:0];
    assign model_out[265:252] = v263[13:0];
    assign model_out[279:266] = v141[13:0];
    assign model_out[286:280] = v320[6:0];
    assign model_out[299:287] = v265[12:0];
    assign model_out[304:300] = v276[4:0];
    assign model_out[310:305] = v281[5:0];
    assign model_out[321:311] = v178[10:0];
    assign model_out[330:322] = v285[8:0];
    assign model_out[336:331] = v286[5:0];
    assign model_out[344:337] = v287[7:0];
    assign model_out[351:345] = v288[6:0];
    assign model_out[355:352] = v293[3:0];
    assign model_out[358:356] = v183[2:0];
    assign model_out[362:359] = v219[3:0];
    assign model_out[374:363] = v202[11:0];
    assign model_out[378:375] = v93[3:0];
    assign model_out[381:379] = v301[2:0];
    assign model_out[385:382] = v208[3:0];
    assign model_out[389:386] = v307[3:0];
    assign model_out[394:390] = v306[4:0];
    assign model_out[397:395] = v108[2:0];
    assign model_out[400:398] = v215[2:0];
    assign model_out[405:401] = v309[4:0];
    assign model_out[410:406] = v270[4:0];
    assign model_out[413:411] = v321[2:0];
    assign model_out[419:414] = v311[5:0];
    assign model_out[423:420] = v107[3:0];
    assign model_out[429:424] = v312[5:0];
    assign model_out[437:430] = v313[7:0];
    assign model_out[441:438] = v223[3:0];
    assign model_out[445:442] = v315[3:0];
    assign model_out[452:446] = v316[6:0];
    assign model_out[457:453] = v244[4:0];
    assign model_out[459:458] = v322[1:0];
    assign model_out[471:460] = v249[11:0];
    assign model_out[477:472] = v256[5:0];
    assign model_out[490:478] = v262[12:0];
    assign model_out[493:491] = v148[2:0];
    assign model_out[500:494] = v264[6:0];
    assign model_out[504:501] = v167[3:0];
    assign model_out[515:505] = v283[10:0];
    assign model_out[527:516] = v295[11:0];
    assign model_out[532:528] = v308[4:0];
    assign model_out[537:533] = v6[4:0];
    assign model_out[539:538] = v323[1:0];
    assign model_out[541:540] = v314[1:0];
    assign model_out[543:542] = v220[1:0];
    assign model_out[545:544] = v217[1:0];
    assign model_out[546:546] = v324[0:0];
    assign model_out[550:547] = v100[3:0];
    assign model_out[555:551] = v117[4:0];
    assign model_out[559:556] = v185[3:0];
    assign model_out[561:560] = v101[1:0];
    assign model_out[563:562] = v325[1:0];

endmodule
