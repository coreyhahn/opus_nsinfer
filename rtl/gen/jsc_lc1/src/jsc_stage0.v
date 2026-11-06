`timescale 1 ns / 1 ps

module jsc_stage0 (
    input [149:0] model_inp,
    output [1442:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [9:0] v0; assign v0[9:0] = model_inp[9:0]; // 0.0
    wire [10:0] v1; assign v1[10:0] = model_inp[20:10]; // 0.0
    wire [11:0] v2; assign v2[11:0] = model_inp[32:21]; // 0.0
    wire [11:0] v3; assign v3[11:0] = model_inp[44:33]; // 0.0
    wire [9:0] v4; assign v4[9:0] = model_inp[54:45]; // 0.0
    wire [8:0] v5; assign v5[8:0] = model_inp[63:55]; // 0.0
    wire [7:0] v6; assign v6[7:0] = model_inp[71:64]; // 0.0
    wire [6:0] v7; assign v7[6:0] = model_inp[78:72]; // 0.0
    wire [4:0] v8; assign v8[4:0] = model_inp[83:79]; // 0.0
    wire [8:0] v9; assign v9[8:0] = model_inp[92:84]; // 0.0
    wire [7:0] v10; assign v10[7:0] = model_inp[100:93]; // 0.0
    wire [8:0] v11; assign v11[8:0] = model_inp[109:101]; // 0.0
    wire [7:0] v12; assign v12[7:0] = model_inp[117:110]; // 0.0
    wire [7:0] v13; assign v13[7:0] = model_inp[125:118]; // 0.0
    wire [13:0] v14; assign v14[13:0] = model_inp[139:126]; // 0.0
    wire [9:0] v15; assign v15[9:0] = model_inp[149:140]; // 0.0
    wire [8:0] v16; assign v16[8:0] = v9[8:0]; // 0.0
    wire [9:0] v17; shift_adder #(9, 1, 1, 0, 10, 0, 0) op_17 (v16[8:0], 1'b1, v17[9:0]); // 0.0
    wire [7:0] v18; assign v18[7:0] = v17[8:1]; // 0.0
    wire [8:0] v19; shift_adder #(8, 6, 1, 0, 9, 0, 0) op_19 (v18[7:0], 6'b100000, v19[8:0]); // 0.0
    wire [8:0] v19_neg; negative #(9, 9, 1) op_neg_19 (v19, v19_neg);
    wire [6:0] v20; assign v20[6:0] = v19_neg[6:0] & {7{~v19_neg[8]}}; // 0.0
    wire [6:0] v21; shift_adder #(7, 5, 0, 0, 7, 0, 0) op_21 (v20[6:0], 5'b10000, v21[6:0]); // 0.0
    wire [1:0] v22; assign v22[1:0] = v21[6:5]; // 0.0
    wire [9:0] v23; assign v23[9:0] = v15[9:0]; // 0.0
    wire [10:0] v24; shift_adder #(10, 1, 1, 0, 11, 0, 0) op_24 (v23[9:0], 1'b1, v24[10:0]); // 0.0
    wire [8:0] v25; assign v25[8:0] = v24[9:1]; // 0.0
    wire [11:0] v26; assign v26[11:0] = v2[11:0]; // 0.0
    wire [12:0] v27; shift_adder #(12, 1, 1, 0, 13, 0, 0) op_27 (v26[11:0], 1'b1, v27[12:0]); // 0.0
    wire [10:0] v28; assign v28[10:0] = v27[11:1]; // 0.0
    wire [13:0] v29; assign v29[13:0] = v14[13:0]; // 0.0
    wire [14:0] v30; shift_adder #(14, 1, 1, 0, 15, 0, 0) op_30 (v29[13:0], 1'b1, v30[14:0]); // 0.0
    wire [12:0] v31; assign v31[12:0] = v30[13:1]; // 0.0
    wire [8:0] v32; assign v32[8:0] = v5[8:0]; // 0.0
    wire [9:0] v33; shift_adder #(9, 1, 1, 0, 10, 0, 0) op_33 (v32[8:0], 1'b1, v33[9:0]); // 0.0
    wire [7:0] v34; assign v34[7:0] = v33[8:1]; // 0.0
    wire [9:0] v35; assign v35[9:0] = v0[9:0]; // 0.0
    wire [10:0] v36; shift_adder #(10, 1, 1, 0, 11, 0, 0) op_36 (v35[9:0], 1'b1, v36[10:0]); // 0.0
    wire [8:0] v37; assign v37[8:0] = v36[9:1]; // 0.0
    wire [10:0] v38; assign v38[10:0] = v1[10:0]; // 0.0
    wire [11:0] v39; shift_adder #(11, 1, 1, 0, 12, 0, 0) op_39 (v38[10:0], 1'b1, v39[11:0]); // 0.0
    wire [9:0] v40; assign v40[9:0] = v39[10:1]; // 0.0
    wire [9:0] v41; assign v41[9:0] = v4[9:0]; // 0.0
    wire [10:0] v42; shift_adder #(10, 1, 1, 0, 11, 0, 0) op_42 (v41[9:0], 1'b1, v42[10:0]); // 0.0
    wire [8:0] v43; assign v43[8:0] = v42[9:1]; // 0.0
    wire [8:0] v44; assign v44[8:0] = v11[8:0]; // 0.0
    wire [9:0] v45; shift_adder #(9, 1, 1, 0, 10, 0, 0) op_45 (v44[8:0], 1'b1, v45[9:0]); // 0.0
    wire [7:0] v46; assign v46[7:0] = v45[8:1]; // 0.0
    wire [4:0] v47; assign v47[4:0] = v8[4:0]; // 0.0
    wire [5:0] v48; shift_adder #(5, 1, 1, 0, 6, 0, 0) op_48 (v47[4:0], 1'b1, v48[5:0]); // 0.0
    wire [3:0] v49; assign v49[3:0] = v48[4:1]; // 0.0
    wire [7:0] v50; assign v50[7:0] = v12[7:0]; // 0.0
    wire [8:0] v51; shift_adder #(8, 1, 1, 0, 9, 0, 0) op_51 (v50[7:0], 1'b1, v51[8:0]); // 0.0
    wire [6:0] v52; assign v52[6:0] = v51[7:1]; // 0.0
    wire [11:0] v53; assign v53[11:0] = v3[11:0]; // 0.0
    wire [12:0] v54; shift_adder #(12, 1, 1, 0, 13, 0, 0) op_54 (v53[11:0], 1'b1, v54[12:0]); // 0.0
    wire [10:0] v55; assign v55[10:0] = v54[11:1]; // 0.0
    wire [6:0] v56; assign v56[6:0] = v7[6:0]; // 0.0
    wire [7:0] v57; shift_adder #(7, 1, 1, 0, 8, 0, 0) op_57 (v56[6:0], 1'b1, v57[7:0]); // 0.0
    wire [5:0] v58; assign v58[5:0] = v57[6:1]; // 0.0
    wire [7:0] v59; assign v59[7:0] = v10[7:0]; // 0.0
    wire [8:0] v60; shift_adder #(8, 1, 1, 0, 9, 0, 0) op_60 (v59[7:0], 1'b1, v60[8:0]); // 0.0
    wire [6:0] v61; assign v61[6:0] = v60[7:1]; // 0.0
    wire [7:0] v62; assign v62[7:0] = v13[7:0]; // 0.0
    wire [8:0] v63; shift_adder #(8, 1, 1, 0, 9, 0, 0) op_63 (v62[7:0], 1'b1, v63[8:0]); // 0.0
    wire [6:0] v64; assign v64[6:0] = v63[7:1]; // 0.0
    wire [7:0] v65; assign v65[7:0] = v6[7:0]; // 0.0
    wire [8:0] v66; shift_adder #(8, 1, 1, 0, 9, 0, 0) op_66 (v65[7:0], 1'b1, v66[8:0]); // 0.0
    wire [6:0] v67; assign v67[6:0] = v66[7:1]; // 0.0
    wire [13:0] v68; shift_adder #(11, 11, 1, 1, 14, -2, 1) op_68 (v28[10:0], v28[10:0], v68[13:0]); // 1.0
    wire [15:0] v69; shift_adder #(13, 13, 1, 1, 16, -2, 1) op_69 (v31[12:0], v31[12:0], v69[15:0]); // 1.0
    wire [11:0] v70; shift_adder #(8, 8, 1, 1, 12, 3, 1) op_70 (v18[7:0], v34[7:0], v70[11:0]); // 1.0
    wire [11:0] v71; shift_adder #(9, 10, 1, 1, 12, -2, 0) op_71 (v37[8:0], v40[9:0], v71[11:0]); // 1.0
    wire [10:0] v72; shift_adder #(9, 8, 1, 1, 11, -1, 1) op_72 (v43[8:0], v46[7:0], v72[10:0]); // 1.0
    wire [9:0] v73; shift_adder #(7, 9, 1, 1, 10, 0, 1) op_73 (v52[6:0], v25[8:0], v73[9:0]); // 1.0
    wire [13:0] v74; shift_adder #(11, 11, 1, 1, 14, -2, 1) op_74 (v55[10:0], v55[10:0], v74[13:0]); // 1.0
    wire [9:0] v75; shift_adder #(9, 8, 1, 1, 10, 1, 0) op_75 (v43[8:0], v46[7:0], v75[9:0]); // 1.0
    wire [11:0] v76; shift_adder #(6, 11, 1, 1, 12, -4, 0) op_76 (v58[5:0], v28[10:0], v76[11:0]); // 1.0
    wire [10:0] v77; shift_adder #(9, 9, 1, 1, 11, -1, 1) op_77 (v25[8:0], v43[8:0], v77[10:0]); // 1.0
    wire [9:0] v78; shift_adder #(9, 8, 1, 1, 10, 0, 0) op_78 (v37[8:0], v46[7:0], v78[9:0]); // 1.0
    wire [8:0] v79; shift_adder #(4, 8, 1, 1, 9, -3, 0) op_79 (v49[3:0], v34[7:0], v79[8:0]); // 1.0
    wire [11:0] v80; shift_adder #(11, 7, 1, 1, 12, 2, 1) op_80 (v28[10:0], v61[6:0], v80[11:0]); // 1.0
    wire [8:0] v81; shift_adder #(7, 8, 1, 1, 9, -1, 0) op_81 (v52[6:0], v46[7:0], v81[8:0]); // 1.0
    wire [10:0] v82; shift_adder #(9, 8, 1, 1, 11, 2, 1) op_82 (v43[8:0], v34[7:0], v82[10:0]); // 1.0
    wire [10:0] v83; shift_adder #(9, 9, 1, 1, 11, 1, 0) op_83 (v37[8:0], v43[8:0], v83[10:0]); // 1.0
    wire [11:0] v84; shift_adder #(11, 8, 1, 1, 12, 3, 0) op_84 (v28[10:0], v34[7:0], v84[11:0]); // 1.0
    wire [8:0] v85; shift_adder #(8, 7, 1, 1, 9, 1, 1) op_85 (v18[7:0], v52[6:0], v85[8:0]); // 1.0
    wire [11:0] v86; shift_adder #(11, 7, 1, 1, 12, 1, 0) op_86 (v55[10:0], v64[6:0], v86[11:0]); // 1.0
    wire [11:0] v87; shift_adder #(9, 9, 1, 1, 12, -2, 1) op_87 (v25[8:0], v25[8:0], v87[11:0]); // 1.0
    wire [16:0] v88; shift_adder #(13, 13, 1, 1, 17, -3, 1) op_88 (v31[12:0], v31[12:0], v88[16:0]); // 1.0
    wire [8:0] v89; shift_adder #(8, 7, 1, 1, 9, 0, 1) op_89 (v18[7:0], v61[6:0], v89[8:0]); // 1.0
    wire [9:0] v90; shift_adder #(9, 8, 1, 1, 10, 1, 0) op_90 (v43[8:0], v18[7:0], v90[9:0]); // 1.0
    wire [7:0] v91; shift_adder #(7, 7, 1, 1, 8, 0, 0) op_91 (v61[6:0], v52[6:0], v91[7:0]); // 1.0
    wire [8:0] v92; shift_adder #(4, 8, 1, 1, 9, -1, 0) op_92 (v49[3:0], v34[7:0], v92[8:0]); // 1.0
    wire [11:0] v93; shift_adder #(11, 9, 1, 1, 12, 1, 1) op_93 (v55[10:0], v25[8:0], v93[11:0]); // 1.0
    wire [15:0] v94; shift_adder #(9, 13, 1, 1, 16, -6, 0) op_94 (v25[8:0], v31[12:0], v94[15:0]); // 1.0
    wire [9:0] v95; shift_adder #(7, 7, 1, 1, 10, -2, 1) op_95 (v64[6:0], v64[6:0], v95[9:0]); // 1.0
    wire [11:0] v96; shift_adder #(11, 9, 1, 1, 12, 1, 0) op_96 (v55[10:0], v25[8:0], v96[11:0]); // 1.0
    wire [9:0] v97; shift_adder #(8, 7, 1, 1, 10, -1, 1) op_97 (v34[7:0], v67[6:0], v97[9:0]); // 1.0
    wire [11:0] v98; shift_adder #(7, 7, 1, 1, 12, -4, 1) op_98 (v61[6:0], v61[6:0], v98[11:0]); // 1.0
    wire [13:0] v99; shift_adder #(7, 13, 1, 1, 14, -4, 1) op_99 (v67[6:0], v31[12:0], v99[13:0]); // 1.0
    wire [11:0] v100; shift_adder #(7, 11, 1, 1, 12, -2, 0) op_100 (v64[6:0], v28[10:0], v100[11:0]); // 1.0
    wire [10:0] v101; shift_adder #(8, 8, 1, 1, 11, -2, 1) op_101 (v46[7:0], v46[7:0], v101[10:0]); // 1.0
    wire [9:0] v102; shift_adder #(7, 7, 1, 1, 10, -2, 1) op_102 (v61[6:0], v61[6:0], v102[9:0]); // 1.0
    wire [11:0] v103; shift_adder #(11, 9, 1, 1, 12, 0, 1) op_103 (v55[10:0], v43[8:0], v103[11:0]); // 1.0
    wire [9:0] v104; shift_adder #(9, 8, 1, 1, 10, 1, 1) op_104 (v43[8:0], v34[7:0], v104[9:0]); // 1.0
    wire [12:0] v105; shift_adder #(9, 11, 1, 1, 13, 1, 1) op_105 (v37[8:0], v28[10:0], v105[12:0]); // 1.0
    wire [8:0] v106; shift_adder #(8, 7, 1, 1, 9, 0, 0) op_106 (v18[7:0], v52[6:0], v106[8:0]); // 1.0
    wire [8:0] v107; shift_adder #(7, 4, 1, 1, 9, 4, 0) op_107 (v52[6:0], v49[3:0], v107[8:0]); // 1.0
    wire [7:0] v108; shift_adder #(6, 7, 1, 1, 8, -1, 0) op_108 (v58[5:0], v67[6:0], v108[7:0]); // 1.0
    wire [7:0] v109; shift_adder #(7, 7, 1, 1, 8, 0, 1) op_109 (v61[6:0], v64[6:0], v109[7:0]); // 1.0
    wire [10:0] v110; shift_adder #(9, 10, 1, 1, 11, -1, 0) op_110 (v37[8:0], v40[9:0], v110[10:0]); // 1.0
    wire [11:0] v111; shift_adder #(11, 8, 1, 1, 12, 3, 0) op_111 (v55[10:0], v34[7:0], v111[11:0]); // 1.0
    wire [11:0] v112; shift_adder #(8, 8, 1, 1, 12, 3, 0) op_112 (v46[7:0], v18[7:0], v112[11:0]); // 1.0
    wire [13:0] v113; shift_adder #(7, 13, 1, 1, 14, -6, 1) op_113 (v67[6:0], v31[12:0], v113[13:0]); // 1.0
    wire [8:0] v114; shift_adder #(8, 7, 1, 1, 9, 1, 1) op_114 (v18[7:0], v61[6:0], v114[8:0]); // 1.0
    wire [10:0] v115; shift_adder #(8, 7, 1, 1, 11, -2, 0) op_115 (v18[7:0], v52[6:0], v115[10:0]); // 1.0
    wire [9:0] v116; shift_adder #(9, 7, 1, 1, 10, 0, 0) op_116 (v43[8:0], v64[6:0], v116[9:0]); // 1.0
    wire [13:0] v117; shift_adder #(8, 13, 1, 1, 14, -2, 0) op_117 (v46[7:0], v31[12:0], v117[13:0]); // 1.0
    wire [8:0] v118; shift_adder #(6, 6, 1, 1, 9, -2, 1) op_118 (v58[5:0], v58[5:0], v118[8:0]); // 1.0
    wire [15:0] v119; shift_adder #(8, 8, 1, 1, 16, 7, 1) op_119 (v46[7:0], v34[7:0], v119[15:0]); // 1.0
    wire [13:0] v120; shift_adder #(10, 9, 1, 1, 14, 4, 0) op_120 (v40[9:0], v37[8:0], v120[13:0]); // 1.0
    wire [12:0] v121; shift_adder #(11, 11, 1, 1, 13, 1, 0) op_121 (v55[10:0], v28[10:0], v121[12:0]); // 1.0
    wire [11:0] v122; shift_adder #(4, 11, 1, 1, 12, -4, 0) op_122 (v49[3:0], v55[10:0], v122[11:0]); // 1.0
    wire [7:0] v123; shift_adder #(7, 4, 1, 1, 8, 1, 1) op_123 (v64[6:0], v49[3:0], v123[7:0]); // 1.0
    wire [9:0] v124; shift_adder #(7, 7, 1, 1, 10, -2, 1) op_124 (v52[6:0], v52[6:0], v124[9:0]); // 1.0
    wire [13:0] v125; shift_adder #(11, 13, 1, 1, 14, -1, 1) op_125 (v28[10:0], v31[12:0], v125[13:0]); // 1.0
    wire [12:0] v126; shift_adder #(10, 10, 1, 1, 13, -2, 1) op_126 (v40[9:0], v40[9:0], v126[12:0]); // 1.0
    wire [9:0] v127; shift_adder #(9, 7, 1, 1, 10, 0, 0) op_127 (v43[8:0], v67[6:0], v127[9:0]); // 1.0
    wire [9:0] v128; shift_adder #(8, 9, 1, 1, 10, 0, 1) op_128 (v46[7:0], v25[8:0], v128[9:0]); // 1.0
    wire [13:0] v129; shift_adder #(11, 13, 1, 1, 14, 0, 1) op_129 (v28[10:0], v31[12:0], v129[13:0]); // 1.0
    wire [10:0] v130; shift_adder #(7, 7, 1, 1, 11, -3, 0) op_130 (v67[6:0], v64[6:0], v130[10:0]); // 1.0
    wire [9:0] v131; shift_adder #(8, 9, 1, 1, 10, 0, 1) op_131 (v18[7:0], v25[8:0], v131[9:0]); // 1.0
    wire [13:0] v132; shift_adder #(11, 11, 1, 1, 14, -2, 0) op_132 (v55[10:0], v55[10:0], v132[13:0]); // 1.0
    wire [11:0] v133; shift_adder #(11, 8, 1, 1, 12, 1, 1) op_133 (v55[10:0], v46[7:0], v133[11:0]); // 1.0
    wire [8:0] v134; shift_adder #(8, 6, 1, 1, 9, 0, 0) op_134 (v18[7:0], v58[5:0], v134[8:0]); // 1.0
    wire [10:0] v135; shift_adder #(7, 9, 1, 1, 11, 1, 1) op_135 (v52[6:0], v43[8:0], v135[10:0]); // 1.0
    wire [13:0] v136; shift_adder #(11, 11, 1, 1, 14, 2, 0) op_136 (v28[10:0], v55[10:0], v136[13:0]); // 1.0
    wire [9:0] v137; shift_adder #(8, 7, 1, 1, 10, 2, 1) op_137 (v46[7:0], v64[6:0], v137[9:0]); // 1.0
    wire [10:0] v138; shift_adder #(9, 10, 1, 1, 11, 0, 0) op_138 (v37[8:0], v40[9:0], v138[10:0]); // 1.0
    wire [13:0] v139; shift_adder #(10, 7, 1, 1, 14, -3, 1) op_139 (v40[9:0], v61[6:0], v139[13:0]); // 1.0
    wire [11:0] v140; shift_adder #(9, 11, 1, 1, 12, -2, 0) op_140 (v25[8:0], v28[10:0], v140[11:0]); // 1.0
    wire [10:0] v141; shift_adder #(9, 7, 1, 1, 11, 3, 0) op_141 (v37[8:0], v61[6:0], v141[10:0]); // 1.0
    wire [9:0] v142; shift_adder #(9, 4, 1, 1, 10, 2, 0) op_142 (v37[8:0], v49[3:0], v142[9:0]); // 1.0
    wire [13:0] v143; shift_adder #(8, 9, 1, 1, 14, 4, 0) op_143 (v46[7:0], v43[8:0], v143[13:0]); // 1.0
    wire [11:0] v144; shift_adder #(7, 8, 1, 1, 12, -4, 1) op_144 (v64[6:0], v46[7:0], v144[11:0]); // 1.0
    wire [13:0] v145; shift_adder #(8, 13, 1, 1, 14, -3, 0) op_145 (v18[7:0], v31[12:0], v145[13:0]); // 1.0
    wire [11:0] v146; shift_adder #(11, 9, 1, 1, 12, 0, 0) op_146 (v55[10:0], v43[8:0], v146[11:0]); // 1.0
    wire [11:0] v147; shift_adder #(9, 9, 1, 1, 12, -2, 1) op_147 (v37[8:0], v37[8:0], v147[11:0]); // 1.0
    wire [10:0] v148; shift_adder #(8, 7, 1, 1, 11, -2, 1) op_148 (v18[7:0], v67[6:0], v148[10:0]); // 1.0
    wire [14:0] v149; shift_adder #(13, 9, 1, 1, 15, 5, 0) op_149 (v31[12:0], v43[8:0], v149[14:0]); // 1.0
    wire [13:0] v150; shift_adder #(11, 8, 1, 1, 14, -2, 1) op_150 (v28[10:0], v46[7:0], v150[13:0]); // 1.0
    wire [12:0] v151; shift_adder #(7, 11, 1, 1, 13, 1, 0) op_151 (v52[6:0], v28[10:0], v151[12:0]); // 1.0
    wire [9:0] v152; shift_adder #(8, 9, 1, 1, 10, -1, 0) op_152 (v46[7:0], v25[8:0], v152[9:0]); // 1.0
    wire [10:0] v153; shift_adder #(8, 7, 1, 1, 11, -2, 0) op_153 (v34[7:0], v67[6:0], v153[10:0]); // 1.0
    wire [10:0] v154; shift_adder #(10, 9, 1, 1, 11, 1, 1) op_154 (v40[9:0], v25[8:0], v154[10:0]); // 1.0
    wire [8:0] v155; shift_adder #(4, 8, 1, 1, 9, -4, 0) op_155 (v49[3:0], v18[7:0], v155[8:0]); // 1.0
    wire [12:0] v156; shift_adder #(11, 7, 1, 1, 13, 5, 0) op_156 (v55[10:0], v52[6:0], v156[12:0]); // 1.0
    wire [9:0] v157; shift_adder #(7, 9, 1, 1, 10, 0, 0) op_157 (v52[6:0], v25[8:0], v157[9:0]); // 1.0
    wire [12:0] v158; shift_adder #(10, 11, 1, 1, 13, -2, 1) op_158 (v40[9:0], v28[10:0], v158[12:0]); // 1.0
    wire [9:0] v159; shift_adder #(6, 7, 1, 1, 10, 2, 0) op_159 (v58[5:0], v64[6:0], v159[9:0]); // 1.0
    wire [9:0] v160; shift_adder #(8, 7, 1, 1, 10, -1, 0) op_160 (v18[7:0], v61[6:0], v160[9:0]); // 1.0
    wire [9:0] v161; shift_adder #(6, 9, 1, 1, 10, -3, 0) op_161 (v58[5:0], v43[8:0], v161[9:0]); // 1.0
    wire [10:0] v162; shift_adder #(10, 8, 1, 1, 11, 2, 0) op_162 (v40[9:0], v18[7:0], v162[10:0]); // 1.0
    wire [11:0] v163; shift_adder #(11, 7, 1, 1, 12, 4, 0) op_163 (v28[10:0], v52[6:0], v163[11:0]); // 1.0
    wire [7:0] v164; shift_adder #(6, 7, 1, 1, 8, 0, 0) op_164 (v58[5:0], v52[6:0], v164[7:0]); // 1.0
    wire [8:0] v165; shift_adder #(7, 6, 1, 1, 9, 2, 0) op_165 (v67[6:0], v58[5:0], v165[8:0]); // 1.0
    wire [8:0] v166; shift_adder #(7, 4, 1, 1, 9, -1, 0) op_166 (v67[6:0], v49[3:0], v166[8:0]); // 1.0
    wire [11:0] v167; shift_adder #(9, 8, 1, 1, 12, 3, 0) op_167 (v43[8:0], v34[7:0], v167[11:0]); // 1.0
    wire [9:0] v168; shift_adder #(7, 7, 1, 1, 10, 2, 0) op_168 (v61[6:0], v61[6:0], v168[9:0]); // 1.0
    wire [10:0] v169; shift_adder #(7, 6, 1, 1, 11, -3, 1) op_169 (v52[6:0], v58[5:0], v169[10:0]); // 1.0
    wire [10:0] v170; shift_adder #(8, 10, 1, 1, 11, 0, 0) op_170 (v46[7:0], v40[9:0], v170[10:0]); // 1.0
    wire [12:0] v171; shift_adder #(8, 11, 1, 1, 13, 1, 0) op_171 (v46[7:0], v55[10:0], v171[12:0]); // 1.0
    wire [10:0] v172; shift_adder #(8, 7, 1, 1, 11, 3, 0) op_172 (v18[7:0], v67[6:0], v172[10:0]); // 1.0
    wire [7:0] v173; shift_adder #(7, 4, 1, 1, 8, 1, 0) op_173 (v52[6:0], v49[3:0], v173[7:0]); // 1.0
    wire [8:0] v174; shift_adder #(8, 7, 1, 1, 9, 1, 0) op_174 (v34[7:0], v64[6:0], v174[8:0]); // 1.0
    wire [13:0] v175; shift_adder #(7, 13, 1, 1, 14, -5, 0) op_175 (v67[6:0], v31[12:0], v175[13:0]); // 1.0
    wire [11:0] v176; shift_adder #(9, 9, 1, 1, 12, -2, 0) op_176 (v37[8:0], v43[8:0], v176[11:0]); // 1.0
    wire [10:0] v177; shift_adder #(7, 9, 1, 1, 11, -3, 1) op_177 (v64[6:0], v37[8:0], v177[10:0]); // 1.0
    wire [9:0] v178; shift_adder #(9, 4, 1, 1, 10, 3, 1) op_178 (v25[8:0], v49[3:0], v178[9:0]); // 1.0
    wire [11:0] v179; shift_adder #(11, 6, 1, 1, 12, 2, 0) op_179 (v55[10:0], v58[5:0], v179[11:0]); // 1.0
    wire [11:0] v180; shift_adder #(9, 7, 1, 1, 12, -2, 1) op_180 (v37[8:0], v64[6:0], v180[11:0]); // 1.0
    wire [12:0] v181; shift_adder #(8, 9, 1, 1, 13, -4, 0) op_181 (v34[7:0], v43[8:0], v181[12:0]); // 1.0
    wire [9:0] v182; shift_adder #(7, 9, 1, 1, 10, 0, 1) op_182 (v64[6:0], v25[8:0], v182[9:0]); // 1.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[8:0] = v25[8:0];
    assign model_out[22:9] = v68[13:0];
    assign model_out[34:23] = v70[11:0];
    assign model_out[46:35] = v71[11:0];
    assign model_out[57:47] = v72[10:0];
    assign model_out[61:58] = v49[3:0];
    assign model_out[71:62] = v73[9:0];
    assign model_out[81:72] = v75[9:0];
    assign model_out[94:82] = v31[12:0];
    assign model_out[106:95] = v76[11:0];
    assign model_out[116:107] = v78[9:0];
    assign model_out[125:117] = v79[8:0];
    assign model_out[133:126] = v18[7:0];
    assign model_out[147:134] = v74[13:0];
    assign model_out[156:148] = v81[8:0];
    assign model_out[167:157] = v55[10:0];
    assign model_out[173:168] = v58[5:0];
    assign model_out[184:174] = v82[10:0];
    assign model_out[195:185] = v83[10:0];
    assign model_out[207:196] = v84[11:0];
    assign model_out[216:208] = v85[8:0];
    assign model_out[228:217] = v86[11:0];
    assign model_out[236:229] = v34[7:0];
    assign model_out[248:237] = v87[11:0];
    assign model_out[265:249] = v88[16:0];
    assign model_out[274:266] = v89[8:0];
    assign model_out[281:275] = v67[6:0];
    assign model_out[289:282] = v91[7:0];
    assign model_out[298:290] = v92[8:0];
    assign model_out[310:299] = v93[11:0];
    assign model_out[326:311] = v94[15:0];
    assign model_out[336:327] = v95[9:0];
    assign model_out[348:337] = v96[11:0];
    assign model_out[360:349] = v98[11:0];
    assign model_out[374:361] = v99[13:0];
    assign model_out[386:375] = v100[11:0];
    assign model_out[393:387] = v52[6:0];
    assign model_out[404:394] = v101[10:0];
    assign model_out[414:405] = v102[9:0];
    assign model_out[426:415] = v103[11:0];
    assign model_out[436:427] = v104[9:0];
    assign model_out[445:437] = v106[8:0];
    assign model_out[454:446] = v107[8:0];
    assign model_out[462:455] = v108[7:0];
    assign model_out[470:463] = v109[7:0];
    assign model_out[481:471] = v110[10:0];
    assign model_out[493:482] = v111[11:0];
    assign model_out[505:494] = v112[11:0];
    assign model_out[519:506] = v113[13:0];
    assign model_out[528:520] = v114[8:0];
    assign model_out[538:529] = v116[9:0];
    assign model_out[552:539] = v117[13:0];
    assign model_out[561:553] = v118[8:0];
    assign model_out[577:562] = v119[15:0];
    assign model_out[591:578] = v120[13:0];
    assign model_out[604:592] = v121[12:0];
    assign model_out[616:605] = v122[11:0];
    assign model_out[624:617] = v123[7:0];
    assign model_out[632:625] = v46[7:0];
    assign model_out[648:633] = v69[15:0];
    assign model_out[662:649] = v125[13:0];
    assign model_out[673:663] = v28[10:0];
    assign model_out[686:674] = v126[12:0];
    assign model_out[696:687] = v127[9:0];
    assign model_out[706:697] = v128[9:0];
    assign model_out[715:707] = v37[8:0];
    assign model_out[729:716] = v129[13:0];
    assign model_out[740:730] = v130[10:0];
    assign model_out[750:741] = v131[9:0];
    assign model_out[760:751] = v40[9:0];
    assign model_out[774:761] = v132[13:0];
    assign model_out[786:775] = v133[11:0];
    assign model_out[799:787] = v105[12:0];
    assign model_out[808:800] = v134[8:0];
    assign model_out[819:809] = v135[10:0];
    assign model_out[833:820] = v136[13:0];
    assign model_out[843:834] = v137[9:0];
    assign model_out[854:844] = v138[10:0];
    assign model_out[868:855] = v139[13:0];
    assign model_out[879:869] = v141[10:0];
    assign model_out[893:880] = v143[13:0];
    assign model_out[905:894] = v144[11:0];
    assign model_out[919:906] = v145[13:0];
    assign model_out[931:920] = v146[11:0];
    assign model_out[943:932] = v147[11:0];
    assign model_out[950:944] = v61[6:0];
    assign model_out[960:951] = v124[9:0];
    assign model_out[971:961] = v148[10:0];
    assign model_out[986:972] = v149[14:0];
    assign model_out[1000:987] = v150[13:0];
    assign model_out[1013:1001] = v151[12:0];
    assign model_out[1023:1014] = v152[9:0];
    assign model_out[1034:1024] = v153[10:0];
    assign model_out[1043:1035] = v43[8:0];
    assign model_out[1052:1044] = v155[8:0];
    assign model_out[1065:1053] = v156[12:0];
    assign model_out[1075:1066] = v157[9:0];
    assign model_out[1088:1076] = v158[12:0];
    assign model_out[1095:1089] = v64[6:0];
    assign model_out[1105:1096] = v159[9:0];
    assign model_out[1115:1106] = v160[9:0];
    assign model_out[1125:1116] = v161[9:0];
    assign model_out[1136:1126] = v162[10:0];
    assign model_out[1148:1137] = v163[11:0];
    assign model_out[1158:1149] = v97[9:0];
    assign model_out[1166:1159] = v164[7:0];
    assign model_out[1175:1167] = v165[8:0];
    assign model_out[1187:1176] = v167[11:0];
    assign model_out[1197:1188] = v168[9:0];
    assign model_out[1208:1198] = v169[10:0];
    assign model_out[1219:1209] = v170[10:0];
    assign model_out[1232:1220] = v171[12:0];
    assign model_out[1243:1233] = v172[10:0];
    assign model_out[1251:1244] = v173[7:0];
    assign model_out[1260:1252] = v174[8:0];
    assign model_out[1274:1261] = v175[13:0];
    assign model_out[1285:1275] = v177[10:0];
    assign model_out[1295:1286] = v178[9:0];
    assign model_out[1305:1296] = v90[9:0];
    assign model_out[1317:1306] = v179[11:0];
    assign model_out[1329:1318] = v180[11:0];
    assign model_out[1339:1330] = v182[9:0];
    assign model_out[1350:1340] = v77[10:0];
    assign model_out[1362:1351] = v80[11:0];
    assign model_out[1373:1363] = v115[10:0];
    assign model_out[1385:1374] = v140[11:0];
    assign model_out[1395:1386] = v142[9:0];
    assign model_out[1406:1396] = v154[10:0];
    assign model_out[1415:1407] = v166[8:0];
    assign model_out[1427:1416] = v176[11:0];
    assign model_out[1440:1428] = v181[12:0];
    assign model_out[1442:1441] = v22[1:0];

endmodule
