`timescale 1 ns / 1 ps

module jsc_stage10 (
    input [798:0] model_inp,
    output [508:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [1:0] v0; assign v0[1:0] = model_inp[1:0]; // 10.0
    wire [11:0] v1; assign v1[11:0] = model_inp[13:2]; // 10.0
    wire [11:0] v2; shift_adder #(2, 12, 0, 1, 12, -3, 1) op_2 (v0[1:0], v1[11:0], v2[11:0]); // 11.0
    wire [13:0] v3; assign v3[13:0] = model_inp[27:14]; // 10.0
    wire [11:0] v4; assign v4[11:0] = model_inp[39:28]; // 10.0
    wire [13:0] v5; shift_adder #(14, 12, 1, 1, 14, 0, 0) op_5 (v3[13:0], v4[11:0], v5[13:0]); // 11.0
    wire [3:0] v6; assign v6[3:0] = model_inp[43:40]; // 10.0
    wire [6:0] v7; shift_adder #(4, 4, 0, 0, 7, -2, 1) op_7 (v6[3:0], v6[3:0], v7[6:0]); // 11.0
    wire [14:0] v8; assign v8[14:0] = model_inp[58:44]; // 10.0
    wire [11:0] v9; assign v9[11:0] = model_inp[70:59]; // 10.0
    wire [14:0] v10; shift_adder #(15, 12, 1, 1, 15, 0, 1) op_10 (v8[14:0], v9[11:0], v10[14:0]); // 11.0
    wire [14:0] v11; shift_adder #(15, 6, 1, 0, 15, 0, 0) op_11 (v10[14:0], 6'b100000, v11[14:0]); // 11.0
    wire [13:0] v12; assign v12[13:0] = v11[13:0] & {14{~v11[14]}}; // 11.0
    wire [13:0] v13; shift_adder #(14, 5, 0, 0, 14, 0, 0) op_13 (v12[13:0], 5'b10000, v13[13:0]); // 11.0
    wire [6:0] v14; assign v14[6:0] = v13[11:5]; // 11.0
    wire [14:0] v15; assign v15[14:0] = model_inp[85:71]; // 10.0
    wire [14:0] v16; assign v16[14:0] = model_inp[100:86]; // 10.0
    wire [15:0] v17; shift_adder #(15, 15, 1, 1, 16, 0, 0) op_17 (v15[14:0], v16[14:0], v17[15:0]); // 11.0
    wire [11:0] v18; assign v18[11:0] = model_inp[112:101]; // 10.0
    wire [9:0] v19; assign v19[9:0] = model_inp[122:113]; // 10.0
    wire [12:0] v20; shift_adder #(12, 10, 1, 1, 13, 1, 0) op_20 (v18[11:0], v19[9:0], v20[12:0]); // 11.0
    wire [12:0] v21; shift_adder #(13, 5, 1, 0, 13, 0, 0) op_21 (v20[12:0], 5'b10000, v21[12:0]); // 11.0
    wire [10:0] v22; assign v22[10:0] = v21[10:0] & {11{~v21[12]}}; // 11.0
    wire [10:0] v23; shift_adder #(11, 4, 0, 0, 11, 0, 0) op_23 (v22[10:0], 4'b1000, v23[10:0]); // 11.0
    wire [3:0] v24; assign v24[3:0] = v23[7:4]; // 11.0
    wire [15:0] v25; assign v25[15:0] = model_inp[138:123]; // 10.0
    wire [13:0] v26; assign v26[13:0] = model_inp[152:139]; // 10.0
    wire [16:0] v27; shift_adder #(16, 14, 1, 1, 17, 3, 0) op_27 (v25[15:0], v26[13:0], v27[16:0]); // 11.0
    wire [16:0] v28; shift_adder #(17, 9, 1, 0, 17, 0, 0) op_28 (v27[16:0], 9'b110000000, v28[16:0]); // 11.0
    wire [13:0] v29; assign v29[13:0] = v28[13:0] & {14{~v28[16]}}; // 11.0
    wire [13:0] v30; shift_adder #(14, 7, 0, 0, 14, 0, 0) op_30 (v29[13:0], 7'b1000000, v30[13:0]); // 11.0
    wire [4:0] v31; assign v31[4:0] = v30[11:7]; // 11.0
    wire [11:0] v32; assign v32[11:0] = model_inp[164:153]; // 10.0
    wire [12:0] v33; assign v33[12:0] = model_inp[177:165]; // 10.0
    wire [14:0] v34; shift_adder #(12, 13, 1, 1, 15, -2, 0) op_34 (v32[11:0], v33[12:0], v34[14:0]); // 11.0
    wire [14:0] v35; shift_adder #(15, 7, 1, 0, 15, 0, 1) op_35 (v34[14:0], 7'b1111000, v35[14:0]); // 11.0
    wire [13:0] v36; assign v36[13:0] = v35[13:0] & {14{~v35[14]}}; // 11.0
    wire [13:0] v37; shift_adder #(14, 6, 0, 0, 14, 0, 0) op_37 (v36[13:0], 6'b100000, v37[13:0]); // 11.0
    wire [5:0] v38; assign v38[5:0] = v37[11:6]; // 11.0
    wire [14:0] v39; assign v39[14:0] = model_inp[192:178]; // 10.0
    wire [11:0] v40; assign v40[11:0] = model_inp[204:193]; // 10.0
    wire [15:0] v41; shift_adder #(15, 12, 1, 1, 16, 2, 0) op_41 (v39[14:0], v40[11:0], v41[15:0]); // 11.0
    wire [15:0] v42; shift_adder #(16, 8, 1, 0, 16, 0, 0) op_42 (v41[15:0], 8'b10000000, v42[15:0]); // 11.0
    wire [12:0] v43; assign v43[12:0] = v42[12:0] & {13{~v42[15]}}; // 11.0
    wire [12:0] v44; shift_adder #(13, 7, 0, 0, 13, 0, 0) op_44 (v43[12:0], 7'b1000000, v44[12:0]); // 11.0
    wire [2:0] v45; assign v45[2:0] = v44[9:7]; // 11.0
    wire [13:0] v46; assign v46[13:0] = model_inp[218:205]; // 10.0
    wire [14:0] v47; assign v47[14:0] = model_inp[233:219]; // 10.0
    wire [15:0] v48; shift_adder #(14, 15, 1, 1, 16, 1, 1) op_48 (v46[13:0], v47[14:0], v48[15:0]); // 11.0
    wire [12:0] v49; assign v49[12:0] = model_inp[246:234]; // 10.0
    wire [16:0] v50; assign v50[16:0] = model_inp[263:247]; // 10.0
    wire [17:0] v51; shift_adder #(13, 17, 1, 1, 18, -2, 0) op_51 (v49[12:0], v50[16:0], v51[17:0]); // 11.0
    wire [17:0] v52; shift_adder #(18, 8, 1, 0, 18, 0, 0) op_52 (v51[17:0], 8'b11000000, v52[17:0]); // 11.0
    wire [14:0] v53; assign v53[14:0] = v52[14:0] & {15{~v52[17]}}; // 11.0
    wire [14:0] v54; shift_adder #(15, 7, 0, 0, 15, 0, 0) op_54 (v53[14:0], 7'b1000000, v54[14:0]); // 11.0
    wire [4:0] v55; assign v55[4:0] = v54[11:7]; // 11.0
    wire [12:0] v56; assign v56[12:0] = model_inp[276:264]; // 10.0
    wire [13:0] v57; assign v57[13:0] = model_inp[290:277]; // 10.0
    wire [13:0] v58; shift_adder #(13, 14, 1, 1, 14, 0, 0) op_58 (v56[12:0], v57[13:0], v58[13:0]); // 11.0
    wire [13:0] v59; shift_adder #(14, 8, 1, 0, 14, 0, 0) op_59 (v58[13:0], 8'b10100000, v59[13:0]); // 11.0
    wire [12:0] v60; assign v60[12:0] = v59[12:0] & {13{~v59[13]}}; // 11.0
    wire [12:0] v61; shift_adder #(13, 5, 0, 0, 13, 0, 0) op_61 (v60[12:0], 5'b10000, v61[12:0]); // 11.0
    wire [4:0] v62; assign v62[4:0] = v61[9:5]; // 11.0
    wire [14:0] v63; assign v63[14:0] = model_inp[305:291]; // 10.0
    wire [11:0] v64; assign v64[11:0] = model_inp[317:306]; // 10.0
    wire [15:0] v65; shift_adder #(15, 12, 1, 1, 16, 3, 1) op_65 (v63[14:0], v64[11:0], v65[15:0]); // 11.0
    wire [13:0] v66; assign v66[13:0] = model_inp[331:318]; // 10.0
    wire [17:0] v67; assign v67[17:0] = model_inp[349:332]; // 10.0
    wire [17:0] v68; shift_adder #(14, 18, 1, 1, 18, -2, 0) op_68 (v66[13:0], v67[17:0], v68[17:0]); // 11.0
    wire [10:0] v69; assign v69[10:0] = model_inp[360:350]; // 10.0
    wire [11:0] v70; assign v70[11:0] = model_inp[372:361]; // 10.0
    wire [12:0] v71; shift_adder #(11, 12, 1, 1, 13, 0, 1) op_71 (v69[10:0], v70[11:0], v71[12:0]); // 11.0
    wire [14:0] v72; assign v72[14:0] = model_inp[387:373]; // 10.0
    wire [11:0] v73; assign v73[11:0] = model_inp[399:388]; // 10.0
    wire [15:0] v74; shift_adder #(15, 12, 1, 1, 16, 2, 1) op_74 (v72[14:0], v73[11:0], v74[15:0]); // 11.0
    wire [14:0] v75; assign v75[14:0] = model_inp[414:400]; // 10.0
    wire [12:0] v76; assign v76[12:0] = model_inp[427:415]; // 10.0
    wire [14:0] v77; shift_adder #(15, 13, 1, 1, 15, 0, 0) op_77 (v75[14:0], v76[12:0], v77[14:0]); // 11.0
    wire [18:0] v78; assign v78[18:0] = model_inp[446:428]; // 10.0
    wire [12:0] v79; assign v79[12:0] = model_inp[459:447]; // 10.0
    wire [18:0] v80; shift_adder #(19, 13, 1, 1, 19, 3, 0) op_80 (v78[18:0], v79[12:0], v80[18:0]); // 11.0
    wire [18:0] v81; shift_adder #(19, 9, 1, 0, 19, 0, 0) op_81 (v80[18:0], 9'b100000000, v81[18:0]); // 11.0
    wire [14:0] v82; assign v82[14:0] = v81[14:0] & {15{~v81[18]}}; // 11.0
    wire [14:0] v83; shift_adder #(15, 7, 0, 0, 15, 0, 0) op_83 (v82[14:0], 7'b1000000, v83[14:0]); // 11.0
    wire [5:0] v84; assign v84[5:0] = v83[12:7]; // 11.0
    wire [9:0] v85; assign v85[9:0] = model_inp[469:460]; // 10.0
    wire [13:0] v86; assign v86[13:0] = model_inp[483:470]; // 10.0
    wire [13:0] v87; shift_adder #(10, 14, 0, 1, 14, -2, 0) op_87 (v85[9:0], v86[13:0], v87[13:0]); // 11.0
    wire [13:0] v88; shift_adder #(14, 5, 1, 0, 14, 0, 1) op_88 (v87[13:0], 5'b10000, v88[13:0]); // 11.0
    wire [11:0] v89; assign v89[11:0] = v88[11:0] & {12{~v88[13]}}; // 11.0
    wire [11:0] v90; shift_adder #(12, 4, 0, 0, 12, 0, 0) op_90 (v89[11:0], 4'b1000, v90[11:0]); // 11.0
    wire [5:0] v91; assign v91[5:0] = v90[9:4]; // 11.0
    wire [11:0] v92; assign v92[11:0] = model_inp[495:484]; // 10.0
    wire [14:0] v93; assign v93[14:0] = model_inp[510:496]; // 10.0
    wire [14:0] v94; shift_adder #(12, 15, 1, 1, 15, -1, 0) op_94 (v92[11:0], v93[14:0], v94[14:0]); // 11.0
    wire [10:0] v95; assign v95[10:0] = model_inp[521:511]; // 10.0
    wire [13:0] v96; assign v96[13:0] = model_inp[535:522]; // 10.0
    wire [14:0] v97; shift_adder #(11, 14, 1, 1, 15, -4, 0) op_97 (v95[10:0], v96[13:0], v97[14:0]); // 11.0
    wire [14:0] v98; shift_adder #(15, 9, 1, 0, 15, 0, 1) op_98 (v97[14:0], 9'b100000000, v98[14:0]); // 11.0
    wire [13:0] v99; assign v99[13:0] = v98[13:0] & {14{~v98[14]}}; // 11.0
    wire [13:0] v100; shift_adder #(14, 7, 0, 0, 14, 0, 0) op_100 (v99[13:0], 7'b1000000, v100[13:0]); // 11.0
    wire [4:0] v101; assign v101[4:0] = v100[11:7]; // 11.0
    wire [12:0] v102; assign v102[12:0] = model_inp[548:536]; // 10.0
    wire [12:0] v103; assign v103[12:0] = model_inp[561:549]; // 10.0
    wire [13:0] v104; shift_adder #(13, 13, 1, 1, 14, 0, 0) op_104 (v102[12:0], v103[12:0], v104[13:0]); // 11.0
    wire [13:0] v105; shift_adder #(14, 6, 1, 0, 14, 0, 0) op_105 (v104[13:0], 6'b100000, v105[13:0]); // 11.0
    wire [11:0] v106; assign v106[11:0] = v105[11:0] & {12{~v105[13]}}; // 11.0
    wire [11:0] v107; shift_adder #(12, 4, 0, 0, 12, 0, 0) op_107 (v106[11:0], 4'b1000, v107[11:0]); // 11.0
    wire [5:0] v108; assign v108[5:0] = v107[9:4]; // 11.0
    wire [5:0] v109; assign v109[5:0] = model_inp[567:562]; // 10.0
    wire [3:0] v110; assign v110[3:0] = model_inp[571:568]; // 10.0
    wire [6:0] v111; shift_adder #(6, 4, 0, 0, 7, 0, 1) op_111 (v109[5:0], v110[3:0], v111[6:0]); // 11.0
    wire [12:0] v112; assign v112[12:0] = model_inp[584:572]; // 10.0
    wire [14:0] v113; assign v113[14:0] = model_inp[599:585]; // 10.0
    wire [15:0] v114; shift_adder #(13, 15, 1, 1, 16, -2, 0) op_114 (v112[12:0], v113[14:0], v114[15:0]); // 11.0
    wire [13:0] v115; assign v115[13:0] = v114[13:0] & {14{~v114[15]}}; // 11.0
    wire [13:0] v116; shift_adder #(14, 6, 0, 0, 14, 0, 0) op_116 (v115[13:0], 6'b100000, v116[13:0]); // 11.0
    wire [5:0] v117; assign v117[5:0] = v116[11:6]; // 11.0
    wire [11:0] v118; assign v118[11:0] = model_inp[611:600]; // 10.0
    wire [14:0] v119; assign v119[14:0] = model_inp[626:612]; // 10.0
    wire [15:0] v120; shift_adder #(12, 15, 1, 1, 16, -2, 0) op_120 (v118[11:0], v119[14:0], v120[15:0]); // 11.0
    wire [15:0] v121; shift_adder #(16, 9, 1, 0, 16, 0, 1) op_121 (v120[15:0], 9'b101000000, v121[15:0]); // 11.0
    wire [14:0] v122; assign v122[14:0] = v121[14:0] & {15{~v121[15]}}; // 11.0
    wire [14:0] v123; shift_adder #(15, 6, 0, 0, 15, 0, 0) op_123 (v122[14:0], 6'b100000, v123[14:0]); // 11.0
    wire [6:0] v124; assign v124[6:0] = v123[12:6]; // 11.0
    wire [4:0] v125; shift_adder #(4, 4, 0, 0, 5, 0, 0) op_125 (v110[3:0], v6[3:0], v125[4:0]); // 11.0
    wire [6:0] v126; shift_adder #(4, 4, 0, 0, 7, -2, 1) op_126 (v110[3:0], v110[3:0], v126[6:0]); // 11.0
    wire [5:0] v127; assign v127[5:0] = model_inp[632:627]; // 10.0
    wire [4:0] v128; assign v128[4:0] = model_inp[637:633]; // 10.0
    wire [6:0] v129; shift_adder #(6, 5, 0, 0, 7, 0, 0) op_129 (v127[5:0], v128[4:0], v129[6:0]); // 11.0
    wire [3:0] v130; assign v130[3:0] = model_inp[641:638]; // 10.0
    wire [6:0] v131; shift_adder #(4, 5, 0, 0, 7, -2, 1) op_131 (v130[3:0], v128[4:0], v131[6:0]); // 11.0
    wire [9:0] v132; assign v132[9:0] = model_inp[651:642]; // 10.0
    wire [12:0] v133; shift_adder #(10, 11, 1, 1, 13, 1, 0) op_133 (v132[9:0], v69[10:0], v133[12:0]); // 11.0
    wire [13:0] v134; assign v134[13:0] = model_inp[665:652]; // 10.0
    wire [15:0] v135; assign v135[15:0] = model_inp[681:666]; // 10.0
    wire [15:0] v136; shift_adder #(14, 16, 1, 1, 16, 0, 1) op_136 (v134[13:0], v135[15:0], v136[15:0]); // 11.0
    wire [15:0] v137; assign v137[15:0] = model_inp[697:682]; // 10.0
    wire [12:0] v138; assign v138[12:0] = model_inp[710:698]; // 10.0
    wire [16:0] v139; shift_adder #(16, 13, 1, 1, 17, 2, 1) op_139 (v137[15:0], v138[12:0], v139[16:0]); // 11.0
    wire [12:0] v140; assign v140[12:0] = model_inp[723:711]; // 10.0
    wire [13:0] v141; shift_adder #(13, 12, 1, 1, 14, 1, 0) op_141 (v140[12:0], v73[11:0], v141[13:0]); // 11.0
    wire [6:0] v142; shift_adder #(4, 6, 0, 0, 7, -1, 0) op_142 (v130[3:0], v109[5:0], v142[6:0]); // 11.0
    wire [5:0] v143; shift_adder #(5, 4, 0, 0, 6, 0, 0) op_143 (v128[4:0], v6[3:0], v143[5:0]); // 11.0
    wire [7:0] v144; shift_adder #(4, 5, 0, 0, 8, 2, 0) op_144 (v6[3:0], v128[4:0], v144[7:0]); // 11.0
    wire [1:0] v145; assign v145[1:0] = model_inp[725:724]; // 10.0
    wire [5:0] v146; shift_adder #(2, 4, 0, 0, 6, -3, 1) op_146 (v145[1:0], v110[3:0], v146[5:0]); // 11.0
    wire [5:0] v147; assign v147[5:0] = model_inp[731:726]; // 10.0
    wire [6:0] v148; shift_adder #(6, 6, 0, 0, 7, 0, 1) op_148 (v127[5:0], v147[5:0], v148[6:0]); // 11.0
    wire [7:0] v149; shift_adder #(6, 2, 0, 0, 8, 5, 1) op_149 (v147[5:0], v145[1:0], v149[7:0]); // 11.0
    wire [4:0] v150; shift_adder #(2, 4, 0, 0, 5, -1, 0) op_150 (v145[1:0], v110[3:0], v150[4:0]); // 11.0
    wire [6:0] v151; shift_adder #(6, 4, 0, 0, 7, 2, 0) op_151 (v127[5:0], v6[3:0], v151[6:0]); // 11.0
    wire [6:0] v152; shift_adder #(4, 4, 0, 0, 7, -2, 1) op_152 (v6[3:0], v110[3:0], v152[6:0]); // 11.0
    wire [7:0] v153; shift_adder #(5, 6, 0, 0, 8, -2, 0) op_153 (v128[4:0], v127[5:0], v153[7:0]); // 11.0
    wire [7:0] v154; assign v154[7:0] = model_inp[739:732]; // 10.0
    wire [14:0] v155; assign v155[14:0] = model_inp[754:740]; // 10.0
    wire [13:0] v156; assign v156[13:0] = model_inp[768:755]; // 10.0
    wire [14:0] v157; assign v157[14:0] = model_inp[783:769]; // 10.0
    wire [14:0] v158; assign v158[14:0] = model_inp[798:784]; // 10.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[11:0] = v2[11:0];
    assign model_out[25:12] = v5[13:0];
    assign model_out[41:26] = v17[15:0];
    assign model_out[49:42] = v154[7:0];
    assign model_out[53:50] = v24[3:0];
    assign model_out[55:54] = v145[1:0];
    assign model_out[60:56] = v31[4:0];
    assign model_out[66:61] = v38[5:0];
    assign model_out[82:67] = v48[15:0];
    assign model_out[97:83] = v155[14:0];
    assign model_out[113:98] = v65[15:0];
    assign model_out[131:114] = v68[17:0];
    assign model_out[145:132] = v134[13:0];
    assign model_out[158:146] = v71[12:0];
    assign model_out[174:159] = v74[15:0];
    assign model_out[179:175] = v55[4:0];
    assign model_out[182:180] = v45[2:0];
    assign model_out[196:183] = v156[13:0];
    assign model_out[211:197] = v77[14:0];
    assign model_out[217:212] = v84[5:0];
    assign model_out[223:218] = v91[5:0];
    assign model_out[238:224] = v94[14:0];
    assign model_out[243:239] = v101[4:0];
    assign model_out[248:244] = v62[4:0];
    assign model_out[254:249] = v147[5:0];
    assign model_out[260:255] = v108[5:0];
    assign model_out[267:261] = v111[6:0];
    assign model_out[273:268] = v117[5:0];
    assign model_out[280:274] = v126[6:0];
    assign model_out[287:281] = v131[6:0];
    assign model_out[291:288] = v110[3:0];
    assign model_out[306:292] = v157[14:0];
    assign model_out[319:307] = v133[12:0];
    assign model_out[334:320] = v158[14:0];
    assign model_out[350:335] = v136[15:0];
    assign model_out[367:351] = v139[16:0];
    assign model_out[381:368] = v141[13:0];
    assign model_out[388:382] = v142[6:0];
    assign model_out[394:389] = v143[5:0];
    assign model_out[398:395] = v130[3:0];
    assign model_out[406:399] = v144[7:0];
    assign model_out[412:407] = v127[5:0];
    assign model_out[419:413] = v124[6:0];
    assign model_out[426:420] = v129[6:0];
    assign model_out[432:427] = v146[5:0];
    assign model_out[439:433] = v148[6:0];
    assign model_out[445:440] = v109[5:0];
    assign model_out[452:446] = v14[6:0];
    assign model_out[459:453] = v7[6:0];
    assign model_out[467:460] = v149[7:0];
    assign model_out[471:468] = v6[3:0];
    assign model_out[476:472] = v150[4:0];
    assign model_out[483:477] = v151[6:0];
    assign model_out[490:484] = v152[6:0];
    assign model_out[498:491] = v153[7:0];
    assign model_out[503:499] = v128[4:0];
    assign model_out[508:504] = v125[4:0];

endmodule
