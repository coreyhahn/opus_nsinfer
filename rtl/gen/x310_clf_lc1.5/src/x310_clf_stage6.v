`timescale 1 ns / 1 ps

module x310_clf_stage6 (
    input [1006:0] model_inp,
    output [1696:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [4:0] v0; assign v0[4:0] = model_inp[4:0]; // 9.0
    wire [3:0] v1; assign v1[3:0] = model_inp[8:5]; // 9.0
    wire [6:0] v2; shift_adder #(5, 4, 1, 0, 7, -1, 0) op_2 (v0[4:0], v1[3:0], v2[6:0]); // 10.0
    wire [3:0] v3; assign v3[3:0] = model_inp[12:9]; // 9.0
    wire [6:0] v4; shift_adder #(4, 4, 0, 0, 7, -2, 1) op_4 (v3[3:0], v3[3:0], v4[6:0]); // 10.0
    wire [4:0] v5; assign v5[4:0] = model_inp[17:13]; // 9.0
    wire [3:0] v6; assign v6[3:0] = model_inp[21:18]; // 9.0
    wire [6:0] v7; shift_adder #(5, 4, 1, 0, 7, -1, 0) op_7 (v5[4:0], v6[3:0], v7[6:0]); // 10.0
    wire [4:0] v8; assign v8[4:0] = model_inp[26:22]; // 9.0
    wire [3:0] v9; assign v9[3:0] = model_inp[30:27]; // 9.0
    wire [5:0] v10; shift_adder #(5, 4, 0, 0, 6, 1, 0) op_10 (v8[4:0], v9[3:0], v10[5:0]); // 10.0
    wire [3:0] v11; assign v11[3:0] = model_inp[34:31]; // 9.0
    wire [4:0] v12; assign v12[4:0] = model_inp[39:35]; // 9.0
    wire [5:0] v13; shift_adder #(4, 5, 0, 0, 6, 0, 1) op_13 (v11[3:0], v12[4:0], v13[5:0]); // 10.0
    wire [4:0] v14; assign v14[4:0] = model_inp[44:40]; // 9.0
    wire [5:0] v15; shift_adder #(5, 5, 0, 0, 6, 0, 0) op_15 (v8[4:0], v14[4:0], v15[5:0]); // 10.0
    wire [4:0] v16; assign v16[4:0] = model_inp[49:45]; // 9.0
    wire [4:0] v17; assign v17[4:0] = model_inp[54:50]; // 9.0
    wire [6:0] v18; shift_adder #(5, 5, 0, 0, 7, 1, 1) op_18 (v16[4:0], v17[4:0], v18[6:0]); // 10.0
    wire [3:0] v19; assign v19[3:0] = model_inp[58:55]; // 9.0
    wire [4:0] v20; shift_adder #(4, 4, 0, 0, 5, 0, 0) op_20 (v19[3:0], v11[3:0], v20[4:0]); // 10.0
    wire [4:0] v21; assign v21[4:0] = model_inp[63:59]; // 9.0
    wire [4:0] v22; assign v22[4:0] = model_inp[68:64]; // 9.0
    wire [5:0] v23; shift_adder #(5, 5, 0, 0, 6, 0, 0) op_23 (v21[4:0], v22[4:0], v23[5:0]); // 10.0
    wire [3:0] v24; assign v24[3:0] = model_inp[72:69]; // 9.0
    wire [6:0] v25; shift_adder #(4, 4, 0, 0, 7, -2, 1) op_25 (v24[3:0], v9[3:0], v25[6:0]); // 10.0
    wire [4:0] v26; assign v26[4:0] = model_inp[77:73]; // 9.0
    wire [5:0] v27; assign v27[5:0] = model_inp[83:78]; // 9.0
    wire [6:0] v28; shift_adder #(5, 6, 0, 0, 7, 0, 0) op_28 (v26[4:0], v27[5:0], v28[6:0]); // 10.0
    wire [3:0] v29; assign v29[3:0] = model_inp[87:84]; // 9.0
    wire [3:0] v30; assign v30[3:0] = model_inp[91:88]; // 9.0
    wire [4:0] v31; shift_adder #(4, 4, 0, 0, 5, 0, 0) op_31 (v29[3:0], v30[3:0], v31[4:0]); // 10.0
    wire [4:0] v32; assign v32[4:0] = model_inp[96:92]; // 9.0
    wire [5:0] v33; assign v33[5:0] = model_inp[102:97]; // 9.0
    wire [7:0] v34; shift_adder #(5, 6, 1, 0, 8, 0, 0) op_34 (v32[4:0], v33[5:0], v34[7:0]); // 10.0
    wire [5:0] v35; assign v35[5:0] = model_inp[108:103]; // 9.0
    wire [4:0] v36; assign v36[4:0] = model_inp[113:109]; // 9.0
    wire [7:0] v37; shift_adder #(6, 5, 0, 0, 8, 2, 1) op_37 (v35[5:0], v36[4:0], v37[7:0]); // 10.0
    wire [3:0] v38; assign v38[3:0] = model_inp[117:114]; // 9.0
    wire [6:0] v39; shift_adder #(4, 4, 0, 0, 7, -2, 1) op_39 (v38[3:0], v38[3:0], v39[6:0]); // 10.0
    wire [9:0] v40; assign v40[9:0] = model_inp[127:118]; // 9.0
    wire [7:0] v41; assign v41[7:0] = model_inp[135:128]; // 9.0
    wire [9:0] v42; shift_adder #(10, 8, 1, 1, 10, 0, 1) op_42 (v40[9:0], v41[7:0], v42[9:0]); // 10.0
    wire [9:0] v43; shift_adder #(10, 6, 1, 0, 10, 0, 1) op_43 (v42[9:0], 6'b110000, v43[9:0]); // 10.0
    wire [8:0] v44; assign v44[8:0] = v43[8:0] & {9{~v43[9]}}; // 10.0
    wire [8:0] v45; shift_adder #(9, 4, 0, 0, 9, 0, 0) op_45 (v44[8:0], 4'b1000, v45[8:0]); // 10.0
    wire [4:0] v46; assign v46[4:0] = v45[8:4]; // 10.0
    wire [9:0] v47; assign v47[9:0] = model_inp[145:136]; // 9.0
    wire [9:0] v48; shift_adder #(8, 10, 1, 1, 10, 0, 0) op_48 (v41[7:0], v47[9:0], v48[9:0]); // 10.0
    wire [9:0] v49; shift_adder #(10, 6, 1, 0, 10, 0, 0) op_49 (v48[9:0], 6'b111100, v49[9:0]); // 10.0
    wire [8:0] v50; assign v50[8:0] = v49[8:0] & {9{~v49[9]}}; // 10.0
    wire [8:0] v51; shift_adder #(9, 4, 0, 0, 9, 0, 0) op_51 (v50[8:0], 4'b1000, v51[8:0]); // 10.0
    wire [4:0] v52; assign v52[4:0] = v51[8:4]; // 10.0
    wire [3:0] v53; assign v53[3:0] = model_inp[149:146]; // 9.0
    wire [4:0] v54; assign v54[4:0] = model_inp[154:150]; // 9.0
    wire [5:0] v55; shift_adder #(4, 5, 0, 0, 6, -1, 0) op_55 (v53[3:0], v54[4:0], v55[5:0]); // 10.0
    wire [4:0] v56; assign v56[4:0] = model_inp[159:155]; // 9.0
    wire [6:0] v57; shift_adder #(5, 5, 0, 0, 7, 1, 0) op_57 (v56[4:0], v12[4:0], v57[6:0]); // 10.0
    wire [9:0] v58; assign v58[9:0] = model_inp[169:160]; // 9.0
    wire [8:0] v59; assign v59[8:0] = model_inp[178:170]; // 9.0
    wire [9:0] v60; shift_adder #(10, 9, 1, 1, 10, 0, 0) op_60 (v58[9:0], v59[8:0], v60[9:0]); // 10.0
    wire [9:0] v61; shift_adder #(10, 4, 1, 0, 10, 0, 1) op_61 (v60[9:0], 4'b1100, v61[9:0]); // 10.0
    wire [8:0] v62; assign v62[8:0] = v61[8:0] & {9{~v61[9]}}; // 10.0
    wire [8:0] v63; shift_adder #(9, 4, 0, 0, 9, 0, 0) op_63 (v62[8:0], 4'b1000, v63[8:0]); // 10.0
    wire [4:0] v64; assign v64[4:0] = v63[8:4]; // 10.0
    wire [3:0] v65; assign v65[3:0] = model_inp[182:179]; // 9.0
    wire [3:0] v66; assign v66[3:0] = model_inp[186:183]; // 9.0
    wire [4:0] v67; shift_adder #(4, 4, 0, 0, 5, 0, 0) op_67 (v65[3:0], v66[3:0], v67[4:0]); // 10.0
    wire [6:0] v68; assign v68[6:0] = model_inp[193:187]; // 9.0
    wire [5:0] v69; assign v69[5:0] = model_inp[199:194]; // 9.0
    wire [7:0] v70; shift_adder #(7, 6, 1, 1, 8, 0, 1) op_70 (v68[6:0], v69[5:0], v70[7:0]); // 10.0
    wire [3:0] v71; assign v71[3:0] = model_inp[203:200]; // 9.0
    wire [5:0] v72; shift_adder #(5, 4, 0, 0, 6, 0, 0) op_72 (v54[4:0], v71[3:0], v72[5:0]); // 10.0
    wire [3:0] v73; assign v73[3:0] = model_inp[207:204]; // 9.0
    wire [3:0] v74; assign v74[3:0] = model_inp[211:208]; // 9.0
    wire [4:0] v75; shift_adder #(4, 4, 0, 0, 5, 0, 0) op_75 (v73[3:0], v74[3:0], v75[4:0]); // 10.0
    wire [4:0] v76; assign v76[4:0] = model_inp[216:212]; // 9.0
    wire [7:0] v77; shift_adder #(5, 5, 0, 1, 8, 2, 0) op_77 (v54[4:0], v76[4:0], v77[7:0]); // 10.0
    wire [4:0] v78; assign v78[4:0] = model_inp[221:217]; // 9.0
    wire [5:0] v79; shift_adder #(4, 5, 0, 0, 6, -1, 1) op_79 (v6[3:0], v78[4:0], v79[5:0]); // 10.0
    wire [3:0] v80; assign v80[3:0] = model_inp[225:222]; // 9.0
    wire [4:0] v81; shift_adder #(4, 4, 0, 0, 5, 0, 0) op_81 (v6[3:0], v80[3:0], v81[4:0]); // 10.0
    wire [4:0] v82; assign v82[4:0] = model_inp[230:226]; // 9.0
    wire [5:0] v83; shift_adder #(4, 5, 0, 0, 6, -1, 1) op_83 (v29[3:0], v82[4:0], v83[5:0]); // 10.0
    wire [5:0] v84; assign v84[5:0] = model_inp[236:231]; // 9.0
    wire [4:0] v85; assign v85[4:0] = model_inp[241:237]; // 9.0
    wire [6:0] v86; shift_adder #(6, 5, 1, 0, 7, 0, 0) op_86 (v84[5:0], v85[4:0], v86[6:0]); // 10.0
    wire [5:0] v87; assign v87[5:0] = model_inp[247:242]; // 9.0
    wire [7:0] v88; shift_adder #(6, 5, 1, 0, 8, 2, 1) op_88 (v87[5:0], v82[4:0], v88[7:0]); // 10.0
    wire [4:0] v89; assign v89[4:0] = model_inp[252:248]; // 9.0
    wire [5:0] v90; shift_adder #(5, 5, 0, 0, 6, 0, 0) op_90 (v89[4:0], v16[4:0], v90[5:0]); // 10.0
    wire [5:0] v91; shift_adder #(4, 4, 0, 0, 6, -1, 0) op_91 (v3[3:0], v9[3:0], v91[5:0]); // 10.0
    wire [5:0] v92; assign v92[5:0] = model_inp[258:253]; // 9.0
    wire [6:0] v93; shift_adder #(4, 6, 0, 0, 7, -2, 0) op_93 (v6[3:0], v92[5:0], v93[6:0]); // 10.0
    wire [5:0] v94; assign v94[5:0] = model_inp[264:259]; // 9.0
    wire [5:0] v95; assign v95[5:0] = model_inp[270:265]; // 9.0
    wire [8:0] v96; shift_adder #(6, 6, 0, 1, 9, 3, 0) op_96 (v94[5:0], v95[5:0], v96[8:0]); // 10.0
    wire [4:0] v97; assign v97[4:0] = model_inp[275:271]; // 9.0
    wire [6:0] v98; shift_adder #(5, 5, 0, 0, 7, -1, 0) op_98 (v78[4:0], v97[4:0], v98[6:0]); // 10.0
    wire [5:0] v99; assign v99[5:0] = model_inp[281:276]; // 9.0
    wire [6:0] v100; shift_adder #(5, 6, 0, 0, 7, 1, 0) op_100 (v54[4:0], v99[5:0], v100[6:0]); // 10.0
    wire [4:0] v101; shift_adder #(4, 4, 0, 0, 5, 0, 0) op_101 (v65[3:0], v73[3:0], v101[4:0]); // 10.0
    wire [5:0] v102; shift_adder #(5, 5, 0, 0, 6, 0, 0) op_102 (v78[4:0], v97[4:0], v102[5:0]); // 10.0
    wire [5:0] v103; assign v103[5:0] = model_inp[287:282]; // 9.0
    wire [5:0] v104; shift_adder #(4, 6, 0, 0, 6, 0, 0) op_104 (v65[3:0], v103[5:0], v104[5:0]); // 10.0
    wire [6:0] v105; shift_adder #(6, 4, 0, 0, 7, 1, 0) op_105 (v27[5:0], v3[3:0], v105[6:0]); // 10.0
    wire [6:0] v106; shift_adder #(4, 5, 0, 0, 7, -2, 0) op_106 (v53[3:0], v78[4:0], v106[6:0]); // 10.0
    wire [9:0] v107; assign v107[9:0] = model_inp[297:288]; // 9.0
    wire [5:0] v108; assign v108[5:0] = model_inp[303:298]; // 9.0
    wire [9:0] v109; shift_adder #(10, 6, 1, 1, 10, 1, 1) op_109 (v107[9:0], v108[5:0], v109[9:0]); // 10.0
    wire [9:0] v110; shift_adder #(10, 3, 1, 0, 10, 0, 1) op_110 (v109[9:0], 3'b110, v110[9:0]); // 10.0
    wire [8:0] v111; assign v111[8:0] = v110[8:0] & {9{~v110[9]}}; // 10.0
    wire [8:0] v112; shift_adder #(9, 4, 0, 0, 9, 0, 0) op_112 (v111[8:0], 4'b1000, v112[8:0]); // 10.0
    wire [4:0] v113; assign v113[4:0] = v112[8:4]; // 10.0
    wire [5:0] v114; assign v114[5:0] = model_inp[309:304]; // 9.0
    wire [4:0] v115; assign v115[4:0] = model_inp[314:310]; // 9.0
    wire [6:0] v116; shift_adder #(6, 5, 1, 0, 7, 1, 0) op_116 (v114[5:0], v115[4:0], v116[6:0]); // 10.0
    wire [5:0] v117; shift_adder #(4, 4, 0, 0, 6, 1, 1) op_117 (v11[3:0], v74[3:0], v117[5:0]); // 10.0
    wire [3:0] v118; assign v118[3:0] = model_inp[318:315]; // 9.0
    wire [4:0] v119; shift_adder #(4, 4, 0, 0, 5, 0, 0) op_119 (v118[3:0], v3[3:0], v119[4:0]); // 10.0
    wire [3:0] v120; assign v120[3:0] = model_inp[322:319]; // 9.0
    wire [5:0] v121; shift_adder #(5, 4, 0, 0, 6, 1, 0) op_121 (v8[4:0], v120[3:0], v121[5:0]); // 10.0
    wire [5:0] v122; shift_adder #(5, 4, 0, 0, 6, 1, 1) op_122 (v54[4:0], v73[3:0], v122[5:0]); // 10.0
    wire [3:0] v123; assign v123[3:0] = model_inp[326:323]; // 9.0
    wire [4:0] v124; shift_adder #(4, 4, 0, 0, 5, 0, 1) op_124 (v74[3:0], v123[3:0], v124[4:0]); // 10.0
    wire [6:0] v125; shift_adder #(5, 5, 0, 0, 7, 1, 0) op_125 (v89[4:0], v78[4:0], v125[6:0]); // 10.0
    wire [3:0] v126; assign v126[3:0] = model_inp[330:327]; // 9.0
    wire [4:0] v127; shift_adder #(4, 4, 0, 0, 5, 0, 0) op_127 (v29[3:0], v126[3:0], v127[4:0]); // 10.0
    wire [5:0] v128; assign v128[5:0] = model_inp[336:331]; // 9.0
    wire [6:0] v129; shift_adder #(4, 6, 0, 0, 7, -2, 0) op_129 (v65[3:0], v128[5:0], v129[6:0]); // 10.0
    wire [5:0] v130; shift_adder #(5, 5, 0, 0, 6, 0, 1) op_130 (v97[4:0], v14[4:0], v130[5:0]); // 10.0
    wire [2:0] v131; assign v131[2:0] = model_inp[339:337]; // 9.0
    wire [3:0] v132; assign v132[3:0] = model_inp[343:340]; // 9.0
    wire [4:0] v133; shift_adder #(3, 4, 0, 0, 5, 0, 1) op_133 (v131[2:0], v132[3:0], v133[4:0]); // 10.0
    wire [4:0] v134; assign v134[4:0] = model_inp[348:344]; // 9.0
    wire [5:0] v135; assign v135[5:0] = model_inp[354:349]; // 9.0
    wire [6:0] v136; shift_adder #(5, 6, 0, 0, 7, -1, 0) op_136 (v134[4:0], v135[5:0], v136[6:0]); // 10.0
    wire [7:0] v137; assign v137[7:0] = model_inp[362:355]; // 9.0
    wire [7:0] v138; shift_adder #(8, 5, 0, 0, 8, 2, 0) op_138 (v137[7:0], v16[4:0], v138[7:0]); // 10.0
    wire [3:0] v139; assign v139[3:0] = model_inp[366:363]; // 9.0
    wire [6:0] v140; shift_adder #(4, 6, 0, 0, 7, -2, 1) op_140 (v139[3:0], v33[5:0], v140[6:0]); // 10.0
    wire [4:0] v141; assign v141[4:0] = model_inp[371:367]; // 9.0
    wire [3:0] v142; assign v142[3:0] = model_inp[375:372]; // 9.0
    wire [5:0] v143; shift_adder #(5, 4, 0, 0, 6, 1, 0) op_143 (v141[4:0], v142[3:0], v143[5:0]); // 10.0
    wire [7:0] v144; assign v144[7:0] = model_inp[383:376]; // 9.0
    wire [7:0] v145; shift_adder #(8, 4, 1, 0, 8, 2, 1) op_145 (v144[7:0], v142[3:0], v145[7:0]); // 10.0
    wire [4:0] v146; assign v146[4:0] = model_inp[388:384]; // 9.0
    wire [6:0] v147; shift_adder #(6, 5, 0, 0, 7, 0, 0) op_147 (v92[5:0], v146[4:0], v147[6:0]); // 10.0
    wire [5:0] v148; shift_adder #(4, 5, 0, 0, 6, -1, 1) op_148 (v1[3:0], v14[4:0], v148[5:0]); // 10.0
    wire [3:0] v149; assign v149[3:0] = model_inp[392:389]; // 9.0
    wire [6:0] v150; shift_adder #(4, 5, 0, 0, 7, -2, 0) op_150 (v149[3:0], v97[4:0], v150[6:0]); // 10.0
    wire [5:0] v151; assign v151[5:0] = model_inp[398:393]; // 9.0
    wire [5:0] v152; shift_adder #(6, 4, 0, 0, 6, 0, 0) op_152 (v151[5:0], v149[3:0], v152[5:0]); // 10.0
    wire [4:0] v153; shift_adder #(4, 4, 0, 0, 5, 0, 1) op_153 (v19[3:0], v149[3:0], v153[4:0]); // 10.0
    wire [4:0] v154; shift_adder #(4, 4, 0, 0, 5, 0, 1) op_154 (v11[3:0], v74[3:0], v154[4:0]); // 10.0
    wire [4:0] v155; assign v155[4:0] = model_inp[403:399]; // 9.0
    wire [7:0] v156; shift_adder #(5, 4, 0, 0, 8, -2, 1) op_156 (v155[4:0], v9[3:0], v156[7:0]); // 10.0
    wire [5:0] v157; shift_adder #(4, 5, 0, 0, 6, -1, 0) op_157 (v53[3:0], v78[4:0], v157[5:0]); // 10.0
    wire [5:0] v158; shift_adder #(4, 5, 0, 0, 6, -1, 0) op_158 (v3[3:0], v141[4:0], v158[5:0]); // 10.0
    wire [3:0] v159; assign v159[3:0] = model_inp[407:404]; // 9.0
    wire [4:0] v160; shift_adder #(4, 4, 0, 0, 5, 0, 1) op_160 (v159[3:0], v9[3:0], v160[4:0]); // 10.0
    wire [3:0] v161; assign v161[3:0] = model_inp[411:408]; // 9.0
    wire [4:0] v162; shift_adder #(4, 4, 0, 0, 5, 0, 1) op_162 (v161[3:0], v132[3:0], v162[4:0]); // 10.0
    wire [4:0] v163; assign v163[4:0] = model_inp[416:412]; // 9.0
    wire [7:0] v164; shift_adder #(4, 5, 0, 0, 8, 2, 1) op_164 (v74[3:0], v163[4:0], v164[7:0]); // 10.0
    wire [4:0] v165; assign v165[4:0] = model_inp[421:417]; // 9.0
    wire [6:0] v166; shift_adder #(4, 5, 0, 1, 7, -1, 0) op_166 (v159[3:0], v165[4:0], v166[6:0]); // 10.0
    wire [6:0] v167; assign v167[6:0] = model_inp[428:422]; // 9.0
    wire [4:0] v168; assign v168[4:0] = model_inp[433:429]; // 9.0
    wire [7:0] v169; shift_adder #(7, 5, 1, 0, 8, 1, 0) op_169 (v167[6:0], v168[4:0], v169[7:0]); // 10.0
    wire [6:0] v170; shift_adder #(5, 6, 0, 0, 7, -1, 0) op_170 (v17[4:0], v35[5:0], v170[6:0]); // 10.0
    wire [6:0] v171; assign v171[6:0] = model_inp[440:434]; // 9.0
    wire [7:0] v172; shift_adder #(7, 4, 0, 0, 8, 1, 0) op_172 (v171[6:0], v29[3:0], v172[7:0]); // 10.0
    wire [5:0] v173; shift_adder #(5, 4, 0, 0, 6, -1, 0) op_173 (v21[4:0], v65[3:0], v173[5:0]); // 10.0
    wire [7:0] v174; shift_adder #(6, 6, 0, 1, 8, -1, 0) op_174 (v27[5:0], v95[5:0], v174[7:0]); // 10.0
    wire [5:0] v175; assign v175[5:0] = model_inp[446:441]; // 9.0
    wire [4:0] v176; assign v176[4:0] = model_inp[451:447]; // 9.0
    wire [6:0] v177; shift_adder #(6, 5, 0, 0, 7, 0, 0) op_177 (v175[5:0], v176[4:0], v177[6:0]); // 10.0
    wire [5:0] v178; assign v178[5:0] = model_inp[457:452]; // 9.0
    wire [6:0] v179; shift_adder #(5, 6, 0, 0, 7, 0, 1) op_179 (v146[4:0], v178[5:0], v179[6:0]); // 10.0
    wire [5:0] v180; assign v180[5:0] = model_inp[463:458]; // 9.0
    wire [5:0] v181; assign v181[5:0] = model_inp[469:464]; // 9.0
    wire [7:0] v182; shift_adder #(6, 6, 0, 0, 8, -1, 1) op_182 (v180[5:0], v181[5:0], v182[7:0]); // 10.0
    wire [5:0] v183; assign v183[5:0] = model_inp[475:470]; // 9.0
    wire [5:0] v184; assign v184[5:0] = model_inp[481:476]; // 9.0
    wire [7:0] v185; shift_adder #(6, 6, 0, 0, 8, -1, 0) op_185 (v183[5:0], v184[5:0], v185[7:0]); // 10.0
    wire [3:0] v186; assign v186[3:0] = model_inp[485:482]; // 9.0
    wire [5:0] v187; shift_adder #(4, 4, 0, 0, 6, -1, 0) op_187 (v126[3:0], v186[3:0], v187[5:0]); // 10.0
    wire [5:0] v188; shift_adder #(4, 4, 0, 0, 6, -1, 0) op_188 (v118[3:0], v3[3:0], v188[5:0]); // 10.0
    wire [5:0] v189; shift_adder #(5, 4, 0, 0, 6, 0, 0) op_189 (v8[4:0], v132[3:0], v189[5:0]); // 10.0
    wire [4:0] v190; assign v190[4:0] = model_inp[490:486]; // 9.0
    wire [6:0] v191; assign v191[6:0] = model_inp[497:491]; // 9.0
    wire [7:0] v192; shift_adder #(5, 7, 0, 0, 8, 1, 0) op_192 (v190[4:0], v191[6:0], v192[7:0]); // 10.0
    wire [4:0] v193; assign v193[4:0] = model_inp[502:498]; // 9.0
    wire [5:0] v194; shift_adder #(4, 5, 0, 0, 6, 0, 1) op_194 (v65[3:0], v193[4:0], v194[5:0]); // 10.0
    wire [4:0] v195; assign v195[4:0] = model_inp[507:503]; // 9.0
    wire [6:0] v196; shift_adder #(4, 5, 0, 0, 7, 1, 0) op_196 (v73[3:0], v195[4:0], v196[6:0]); // 10.0
    wire [4:0] v197; assign v197[4:0] = model_inp[512:508]; // 9.0
    wire [6:0] v198; shift_adder #(5, 5, 0, 0, 7, 1, 1) op_198 (v97[4:0], v197[4:0], v198[6:0]); // 10.0
    wire [4:0] v199; assign v199[4:0] = model_inp[517:513]; // 9.0
    wire [5:0] v200; shift_adder #(5, 5, 0, 0, 6, 0, 0) op_200 (v16[4:0], v199[4:0], v200[5:0]); // 10.0
    wire [6:0] v201; shift_adder #(4, 4, 0, 0, 7, 2, 1) op_201 (v132[3:0], v126[3:0], v201[6:0]); // 10.0
    wire [5:0] v202; assign v202[5:0] = model_inp[523:518]; // 9.0
    wire [6:0] v203; shift_adder #(6, 4, 0, 0, 7, 1, 0) op_203 (v202[5:0], v11[3:0], v203[6:0]); // 10.0
    wire [5:0] v204; shift_adder #(4, 4, 0, 0, 6, 1, 0) op_204 (v73[3:0], v132[3:0], v204[5:0]); // 10.0
    wire [5:0] v205; assign v205[5:0] = model_inp[529:524]; // 9.0
    wire [7:0] v206; shift_adder #(6, 6, 0, 0, 8, 1, 0) op_206 (v27[5:0], v205[5:0], v206[7:0]); // 10.0
    wire [3:0] v207; assign v207[3:0] = model_inp[533:530]; // 9.0
    wire [5:0] v208; shift_adder #(4, 4, 0, 0, 6, 1, 1) op_208 (v30[3:0], v207[3:0], v208[5:0]); // 10.0
    wire [5:0] v209; assign v209[5:0] = model_inp[539:534]; // 9.0
    wire [5:0] v210; shift_adder #(6, 4, 0, 0, 6, 0, 0) op_210 (v209[5:0], v29[3:0], v210[5:0]); // 10.0
    wire [5:0] v211; assign v211[5:0] = model_inp[545:540]; // 9.0
    wire [6:0] v212; shift_adder #(4, 6, 0, 0, 7, -1, 0) op_212 (v1[3:0], v211[5:0], v212[6:0]); // 10.0
    wire [3:0] v213; assign v213[3:0] = model_inp[549:546]; // 9.0
    wire [6:0] v214; shift_adder #(4, 5, 0, 0, 7, 1, 0) op_214 (v213[3:0], v195[4:0], v214[6:0]); // 10.0
    wire [3:0] v215; assign v215[3:0] = model_inp[553:550]; // 9.0
    wire [4:0] v216; shift_adder #(4, 4, 0, 0, 5, 0, 1) op_216 (v65[3:0], v215[3:0], v216[4:0]); // 10.0
    wire [4:0] v217; shift_adder #(4, 4, 0, 0, 5, 0, 0) op_217 (v29[3:0], v207[3:0], v217[4:0]); // 10.0
    wire [5:0] v218; assign v218[5:0] = model_inp[559:554]; // 9.0
    wire [6:0] v219; shift_adder #(5, 6, 0, 0, 7, -1, 0) op_219 (v16[4:0], v218[5:0], v219[6:0]); // 10.0
    wire [7:0] v220; shift_adder #(5, 5, 0, 0, 8, -2, 1) op_220 (v56[4:0], v56[4:0], v220[7:0]); // 10.0
    wire [6:0] v221; shift_adder #(5, 6, 0, 1, 7, 0, 0) op_221 (v89[4:0], v69[5:0], v221[6:0]); // 10.0
    wire [6:0] v222; shift_adder #(5, 4, 0, 0, 7, -1, 1) op_222 (v193[4:0], v30[3:0], v222[6:0]); // 10.0
    wire [4:0] v223; assign v223[4:0] = model_inp[564:560]; // 9.0
    wire [7:0] v224; shift_adder #(5, 5, 0, 0, 8, -2, 1) op_224 (v195[4:0], v223[4:0], v224[7:0]); // 10.0
    wire [4:0] v225; shift_adder #(4, 4, 0, 0, 5, 0, 0) op_225 (v118[3:0], v1[3:0], v225[4:0]); // 10.0
    wire [5:0] v226; assign v226[5:0] = model_inp[570:565]; // 9.0
    wire [6:0] v227; shift_adder #(6, 4, 1, 0, 7, 1, 0) op_227 (v226[5:0], v3[3:0], v227[6:0]); // 10.0
    wire [4:0] v228; assign v228[4:0] = model_inp[575:571]; // 9.0
    wire [5:0] v229; assign v229[5:0] = model_inp[581:576]; // 9.0
    wire [6:0] v230; shift_adder #(5, 6, 1, 1, 7, -1, 0) op_230 (v228[4:0], v229[5:0], v230[6:0]); // 10.0
    wire [6:0] v231; shift_adder #(4, 6, 0, 0, 7, -1, 0) op_231 (v9[3:0], v27[5:0], v231[6:0]); // 10.0
    wire [5:0] v232; shift_adder #(5, 4, 0, 0, 6, 1, 0) op_232 (v78[4:0], v207[3:0], v232[5:0]); // 10.0
    wire [4:0] v233; shift_adder #(4, 4, 0, 0, 5, 0, 0) op_233 (v38[3:0], v29[3:0], v233[4:0]); // 10.0
    wire [6:0] v234; shift_adder #(5, 4, 0, 0, 7, 2, 0) op_234 (v82[4:0], v9[3:0], v234[6:0]); // 10.0
    wire [5:0] v235; assign v235[5:0] = model_inp[587:582]; // 9.0
    wire [7:0] v236; shift_adder #(5, 6, 0, 0, 8, -2, 0) op_236 (v54[4:0], v235[5:0], v236[7:0]); // 10.0
    wire [6:0] v237; assign v237[6:0] = model_inp[594:588]; // 9.0
    wire [7:0] v238; shift_adder #(7, 5, 0, 0, 8, 1, 1) op_238 (v237[6:0], v14[4:0], v238[7:0]); // 10.0
    wire [4:0] v239; shift_adder #(4, 4, 0, 0, 5, 0, 0) op_239 (v53[3:0], v19[3:0], v239[4:0]); // 10.0
    wire [4:0] v240; assign v240[4:0] = model_inp[599:595]; // 9.0
    wire [6:0] v241; shift_adder #(4, 5, 0, 0, 7, -2, 0) op_241 (v73[3:0], v240[4:0], v241[6:0]); // 10.0
    wire [5:0] v242; shift_adder #(5, 4, 0, 0, 6, 0, 1) op_242 (v89[4:0], v213[3:0], v242[5:0]); // 10.0
    wire [6:0] v243; shift_adder #(4, 5, 0, 0, 7, 1, 0) op_243 (v74[3:0], v16[4:0], v243[6:0]); // 10.0
    wire [4:0] v244; shift_adder #(4, 4, 0, 0, 5, 1, 0) op_244 (v149[3:0], v215[3:0], v244[4:0]); // 10.0
    wire [4:0] v245; assign v245[4:0] = model_inp[604:600]; // 9.0
    wire [6:0] v246; shift_adder #(5, 5, 1, 0, 7, -1, 1) op_246 (v245[4:0], v197[4:0], v246[6:0]); // 10.0
    wire [4:0] v247; assign v247[4:0] = model_inp[609:605]; // 9.0
    wire [5:0] v248; shift_adder #(5, 4, 0, 0, 6, 1, 0) op_248 (v247[4:0], v132[3:0], v248[5:0]); // 10.0
    wire [4:0] v249; assign v249[4:0] = model_inp[614:610]; // 9.0
    wire [6:0] v250; shift_adder #(5, 5, 1, 0, 7, 0, 1) op_250 (v249[4:0], v56[4:0], v250[6:0]); // 10.0
    wire [5:0] v251; shift_adder #(4, 5, 0, 0, 6, -1, 0) op_251 (v161[3:0], v14[4:0], v251[5:0]); // 10.0
    wire [5:0] v252; shift_adder #(5, 4, 0, 0, 6, 0, 0) op_252 (v8[4:0], v9[3:0], v252[5:0]); // 10.0
    wire [6:0] v253; shift_adder #(4, 5, 0, 0, 7, 1, 0) op_253 (v29[3:0], v85[4:0], v253[6:0]); // 10.0
    wire [5:0] v254; assign v254[5:0] = model_inp[620:615]; // 9.0
    wire [6:0] v255; shift_adder #(6, 4, 1, 0, 7, 1, 0) op_255 (v254[5:0], v6[3:0], v255[6:0]); // 10.0
    wire [4:0] v256; shift_adder #(4, 4, 0, 0, 5, 0, 0) op_256 (v29[3:0], v9[3:0], v256[4:0]); // 10.0
    wire [4:0] v257; assign v257[4:0] = model_inp[625:621]; // 9.0
    wire [5:0] v258; shift_adder #(5, 5, 0, 0, 6, 0, 0) op_258 (v89[4:0], v257[4:0], v258[5:0]); // 10.0
    wire [5:0] v259; assign v259[5:0] = model_inp[631:626]; // 9.0
    wire [5:0] v260; shift_adder #(4, 6, 0, 1, 6, 0, 0) op_260 (v19[3:0], v259[5:0], v260[5:0]); // 10.0
    wire [5:0] v261; assign v261[5:0] = model_inp[637:632]; // 9.0
    wire [7:0] v262; shift_adder #(6, 5, 0, 0, 8, -2, 0) op_262 (v261[5:0], v14[4:0], v262[7:0]); // 10.0
    wire [5:0] v263; assign v263[5:0] = model_inp[643:638]; // 9.0
    wire [4:0] v264; assign v264[4:0] = model_inp[648:644]; // 9.0
    wire [6:0] v265; shift_adder #(6, 5, 0, 0, 7, 2, 0) op_265 (v263[5:0], v264[4:0], v265[6:0]); // 10.0
    wire [3:0] v266; assign v266[3:0] = model_inp[652:649]; // 9.0
    wire [5:0] v267; assign v267[5:0] = model_inp[658:653]; // 9.0
    wire [5:0] v268; shift_adder #(4, 6, 0, 0, 6, 0, 0) op_268 (v266[3:0], v267[5:0], v268[5:0]); // 10.0
    wire [5:0] v269; assign v269[5:0] = model_inp[664:659]; // 9.0
    wire [6:0] v270; shift_adder #(5, 6, 0, 0, 7, 0, 1) op_270 (v17[4:0], v269[5:0], v270[6:0]); // 10.0
    wire [4:0] v271; assign v271[4:0] = model_inp[669:665]; // 9.0
    wire [6:0] v272; shift_adder #(5, 5, 0, 0, 7, 1, 1) op_272 (v271[4:0], v197[4:0], v272[6:0]); // 10.0
    wire [2:0] v273; assign v273[2:0] = model_inp[672:670]; // 9.0
    wire [6:0] v274; assign v274[6:0] = model_inp[679:673]; // 9.0
    wire [6:0] v275; shift_adder #(3, 7, 0, 1, 7, 0, 0) op_275 (v273[2:0], v274[6:0], v275[6:0]); // 10.0
    wire [7:0] v276; shift_adder #(5, 6, 0, 0, 8, 1, 1) op_276 (v56[4:0], v235[5:0], v276[7:0]); // 10.0
    wire [4:0] v277; shift_adder #(4, 3, 0, 0, 5, 1, 1) op_277 (v126[3:0], v131[2:0], v277[4:0]); // 10.0
    wire [7:0] v278; shift_adder #(6, 5, 0, 1, 8, 2, 1) op_278 (v94[5:0], v5[4:0], v278[7:0]); // 10.0
    wire [5:0] v279; shift_adder #(4, 4, 0, 0, 6, 2, 0) op_279 (v3[3:0], v207[3:0], v279[5:0]); // 10.0
    wire [5:0] v280; shift_adder #(6, 5, 0, 0, 6, 0, 0) op_280 (v269[5:0], v193[4:0], v280[5:0]); // 10.0
    wire [6:0] v281; assign v281[6:0] = model_inp[686:680]; // 9.0
    wire [5:0] v282; assign v282[5:0] = model_inp[692:687]; // 9.0
    wire [7:0] v283; shift_adder #(7, 6, 1, 0, 8, -1, 0) op_283 (v281[6:0], v282[5:0], v283[7:0]); // 10.0
    wire [7:0] v284; shift_adder #(7, 4, 1, 0, 8, 1, 0) op_284 (v274[6:0], v1[3:0], v284[7:0]); // 10.0
    wire [5:0] v285; shift_adder #(4, 5, 0, 0, 6, 0, 0) op_285 (v74[3:0], v115[4:0], v285[5:0]); // 10.0
    wire [3:0] v286; assign v286[3:0] = model_inp[696:693]; // 9.0
    wire [5:0] v287; shift_adder #(4, 5, 0, 0, 6, 0, 0) op_287 (v286[3:0], v193[4:0], v287[5:0]); // 10.0
    wire [4:0] v288; shift_adder #(4, 4, 0, 0, 5, 0, 0) op_288 (v6[3:0], v126[3:0], v288[4:0]); // 10.0
    wire [6:0] v289; shift_adder #(6, 5, 0, 0, 7, 1, 0) op_289 (v92[5:0], v21[4:0], v289[6:0]); // 10.0
    wire [5:0] v290; assign v290[5:0] = model_inp[702:697]; // 9.0
    wire [6:0] v291; shift_adder #(6, 5, 1, 0, 7, 0, 0) op_291 (v290[5:0], v146[4:0], v291[6:0]); // 10.0
    wire [5:0] v292; shift_adder #(5, 5, 0, 0, 6, 0, 1) op_292 (v257[4:0], v97[4:0], v292[5:0]); // 10.0
    wire [5:0] v293; assign v293[5:0] = model_inp[708:703]; // 9.0
    wire [4:0] v294; assign v294[4:0] = model_inp[713:709]; // 9.0
    wire [6:0] v295; shift_adder #(6, 5, 0, 0, 7, 0, 0) op_295 (v293[5:0], v294[4:0], v295[6:0]); // 10.0
    wire [6:0] v296; shift_adder #(6, 4, 0, 0, 7, 1, 0) op_296 (v92[5:0], v38[3:0], v296[6:0]); // 10.0
    wire [5:0] v297; assign v297[5:0] = model_inp[719:714]; // 9.0
    wire [8:0] v298; shift_adder #(6, 6, 0, 0, 9, 3, 0) op_298 (v297[5:0], v99[5:0], v298[8:0]); // 10.0
    wire [5:0] v299; shift_adder #(4, 4, 0, 0, 6, -1, 0) op_299 (v65[3:0], v29[3:0], v299[5:0]); // 10.0
    wire [5:0] v300; shift_adder #(4, 5, 0, 0, 6, -1, 0) op_300 (v207[3:0], v89[4:0], v300[5:0]); // 10.0
    wire [6:0] v301; assign v301[6:0] = model_inp[726:720]; // 9.0
    wire [7:0] v302; shift_adder #(7, 6, 0, 0, 8, 1, 0) op_302 (v301[6:0], v183[5:0], v302[7:0]); // 10.0
    wire [4:0] v303; shift_adder #(4, 4, 0, 0, 5, 0, 0) op_303 (v74[3:0], v286[3:0], v303[4:0]); // 10.0
    wire [6:0] v304; assign v304[6:0] = model_inp[733:727]; // 9.0
    wire [7:0] v305; shift_adder #(5, 7, 0, 0, 8, -2, 0) op_305 (v195[4:0], v304[6:0], v305[7:0]); // 10.0
    wire [6:0] v306; assign v306[6:0] = model_inp[740:734]; // 9.0
    wire [7:0] v307; shift_adder #(7, 5, 1, 0, 8, 1, 0) op_307 (v306[6:0], v89[4:0], v307[7:0]); // 10.0
    wire [6:0] v308; shift_adder #(4, 6, 0, 0, 7, -1, 0) op_308 (v1[3:0], v202[5:0], v308[6:0]); // 10.0
    wire [6:0] v309; shift_adder #(4, 4, 0, 0, 7, -2, 0) op_309 (v29[3:0], v6[3:0], v309[6:0]); // 10.0
    wire [4:0] v310; shift_adder #(4, 4, 0, 0, 5, 0, 1) op_310 (v6[3:0], v38[3:0], v310[4:0]); // 10.0
    wire [5:0] v311; assign v311[5:0] = model_inp[746:741]; // 9.0
    wire [6:0] v312; shift_adder #(6, 6, 0, 0, 7, 1, 0) op_312 (v92[5:0], v311[5:0], v312[6:0]); // 10.0
    wire [5:0] v313; assign v313[5:0] = model_inp[752:747]; // 9.0
    wire [6:0] v314; shift_adder #(6, 6, 0, 0, 7, -1, 0) op_314 (v261[5:0], v313[5:0], v314[6:0]); // 10.0
    wire [6:0] v315; shift_adder #(6, 5, 0, 0, 7, 1, 0) op_315 (v128[5:0], v264[4:0], v315[6:0]); // 10.0
    wire [6:0] v316; assign v316[6:0] = model_inp[759:753]; // 9.0
    wire [7:0] v317; shift_adder #(5, 7, 0, 0, 8, 1, 0) op_317 (v21[4:0], v316[6:0], v317[7:0]); // 10.0
    wire [4:0] v318; assign v318[4:0] = model_inp[764:760]; // 9.0
    wire [5:0] v319; assign v319[5:0] = model_inp[770:765]; // 9.0
    wire [5:0] v320; shift_adder #(5, 6, 0, 0, 6, 0, 0) op_320 (v318[4:0], v319[5:0], v320[5:0]); // 10.0
    wire [6:0] v321; assign v321[6:0] = model_inp[777:771]; // 9.0
    wire [9:0] v322; shift_adder #(7, 5, 0, 0, 10, -2, 1) op_322 (v321[6:0], v146[4:0], v322[9:0]); // 10.0
    wire [6:0] v323; shift_adder #(4, 5, 0, 0, 7, -2, 0) op_323 (v3[3:0], v8[4:0], v323[6:0]); // 10.0
    wire [5:0] v324; shift_adder #(4, 4, 0, 0, 6, 1, 0) op_324 (v1[3:0], v126[3:0], v324[5:0]); // 10.0
    wire [4:0] v325; assign v325[4:0] = model_inp[782:778]; // 9.0
    wire [7:0] v326; shift_adder #(5, 7, 0, 0, 8, -1, 0) op_326 (v325[4:0], v237[6:0], v326[7:0]); // 10.0
    wire [6:0] v327; shift_adder #(4, 5, 0, 0, 7, 1, 1) op_327 (v73[3:0], v197[4:0], v327[6:0]); // 10.0
    wire [6:0] v328; shift_adder #(4, 5, 0, 0, 7, 1, 0) op_328 (v139[3:0], v56[4:0], v328[6:0]); // 10.0
    wire [5:0] v329; assign v329[5:0] = model_inp[788:783]; // 9.0
    wire [6:0] v330; assign v330[6:0] = model_inp[795:789]; // 9.0
    wire [8:0] v331; shift_adder #(6, 7, 1, 0, 9, -2, 0) op_331 (v329[5:0], v330[6:0], v331[8:0]); // 10.0
    wire [6:0] v332; shift_adder #(5, 5, 0, 1, 7, 1, 1) op_332 (v89[4:0], v228[4:0], v332[6:0]); // 10.0
    wire [4:0] v333; assign v333[4:0] = model_inp[800:796]; // 9.0
    wire [8:0] v334; shift_adder #(7, 5, 0, 0, 9, 3, 1) op_334 (v237[6:0], v333[4:0], v334[8:0]); // 10.0
    wire [4:0] v335; assign v335[4:0] = model_inp[805:801]; // 9.0
    wire [6:0] v336; shift_adder #(5, 5, 1, 0, 7, 0, 0) op_336 (v335[4:0], v264[4:0], v336[6:0]); // 10.0
    wire [4:0] v337; assign v337[4:0] = model_inp[810:806]; // 9.0
    wire [2:0] v338; assign v338[2:0] = model_inp[813:811]; // 9.0
    wire [5:0] v339; shift_adder #(5, 3, 1, 0, 6, 0, 1) op_339 (v337[4:0], v338[2:0], v339[5:0]); // 10.0
    wire [7:0] v340; shift_adder #(6, 5, 1, 0, 8, 1, 0) op_340 (v329[5:0], v14[4:0], v340[7:0]); // 10.0
    wire [6:0] v341; shift_adder #(6, 5, 0, 0, 7, -1, 0) op_341 (v151[5:0], v141[4:0], v341[6:0]); // 10.0
    wire [6:0] v342; shift_adder #(6, 5, 0, 0, 7, 0, 0) op_342 (v27[5:0], v168[4:0], v342[6:0]); // 10.0
    wire [5:0] v343; assign v343[5:0] = model_inp[819:814]; // 9.0
    wire [6:0] v344; shift_adder #(6, 4, 0, 0, 7, 0, 1) op_344 (v343[5:0], v73[3:0], v344[6:0]); // 10.0
    wire [5:0] v345; shift_adder #(5, 4, 0, 0, 6, 0, 1) op_345 (v197[4:0], v38[3:0], v345[5:0]); // 10.0
    wire [5:0] v346; shift_adder #(5, 5, 0, 0, 6, 0, 1) op_346 (v134[4:0], v22[4:0], v346[5:0]); // 10.0
    wire [4:0] v347; assign v347[4:0] = model_inp[824:820]; // 9.0
    wire [5:0] v348; shift_adder #(5, 4, 0, 0, 6, 1, 1) op_348 (v347[4:0], v19[3:0], v348[5:0]); // 10.0
    wire [4:0] v349; assign v349[4:0] = model_inp[829:825]; // 9.0
    wire [6:0] v350; shift_adder #(5, 5, 1, 0, 7, 1, 1) op_350 (v165[4:0], v349[4:0], v350[6:0]); // 10.0
    wire [5:0] v351; assign v351[5:0] = model_inp[835:830]; // 9.0
    wire [6:0] v352; shift_adder #(6, 5, 0, 0, 7, -1, 0) op_352 (v351[5:0], v78[4:0], v352[6:0]); // 10.0
    wire [3:0] v353; assign v353[3:0] = model_inp[839:836]; // 9.0
    wire [5:0] v354; shift_adder #(5, 4, 0, 0, 6, 0, 1) op_354 (v14[4:0], v353[3:0], v354[5:0]); // 10.0
    wire [6:0] v355; shift_adder #(4, 6, 0, 0, 7, 1, 0) op_355 (v1[3:0], v235[5:0], v355[6:0]); // 10.0
    wire [4:0] v356; assign v356[4:0] = model_inp[844:840]; // 9.0
    wire [5:0] v357; assign v357[5:0] = model_inp[850:845]; // 9.0
    wire [6:0] v358; shift_adder #(5, 6, 0, 0, 7, -1, 0) op_358 (v356[4:0], v357[5:0], v358[6:0]); // 10.0
    wire [6:0] v359; shift_adder #(6, 4, 0, 0, 7, 1, 0) op_359 (v205[5:0], v29[3:0], v359[6:0]); // 10.0
    wire [5:0] v360; assign v360[5:0] = model_inp[856:851]; // 9.0
    wire [6:0] v361; shift_adder #(6, 5, 0, 0, 7, -1, 0) op_361 (v360[5:0], v21[4:0], v361[6:0]); // 10.0
    wire [6:0] v362; assign v362[6:0] = model_inp[863:857]; // 9.0
    wire [5:0] v363; assign v363[5:0] = model_inp[869:864]; // 9.0
    wire [7:0] v364; shift_adder #(7, 6, 1, 0, 8, 0, 0) op_364 (v362[6:0], v363[5:0], v364[7:0]); // 10.0
    wire [9:0] v365; shift_adder #(6, 5, 0, 0, 10, -3, 1) op_365 (v267[5:0], v176[4:0], v365[9:0]); // 10.0
    wire [6:0] v366; assign v366[6:0] = model_inp[876:870]; // 9.0
    wire [6:0] v367; shift_adder #(7, 6, 0, 0, 7, 0, 0) op_367 (v366[6:0], v178[5:0], v367[6:0]); // 10.0
    wire [4:0] v368; assign v368[4:0] = model_inp[881:877]; // 9.0
    wire [6:0] v369; shift_adder #(6, 5, 0, 0, 7, 1, 0) op_369 (v184[5:0], v368[4:0], v369[6:0]); // 10.0
    wire [5:0] v370; assign v370[5:0] = model_inp[887:882]; // 9.0
    wire [6:0] v371; shift_adder #(5, 6, 0, 0, 7, -1, 0) op_371 (v54[4:0], v370[5:0], v371[6:0]); // 10.0
    wire [4:0] v372; shift_adder #(4, 4, 0, 0, 5, 0, 0) op_372 (v132[3:0], v65[3:0], v372[4:0]); // 10.0
    wire [5:0] v373; shift_adder #(5, 5, 0, 0, 6, 0, 0) op_373 (v333[4:0], v134[4:0], v373[5:0]); // 10.0
    wire [6:0] v374; shift_adder #(6, 5, 1, 0, 7, -1, 0) op_374 (v95[5:0], v16[4:0], v374[6:0]); // 10.0
    wire [6:0] v375; assign v375[6:0] = model_inp[894:888]; // 9.0
    wire [6:0] v376; shift_adder #(7, 5, 0, 0, 7, 1, 0) op_376 (v375[6:0], v21[4:0], v376[6:0]); // 10.0
    wire [0:0] v377; assign v377[0:0] = model_inp[895:895]; // 9.0
    wire [2:0] v378; assign v378[2:0] = model_inp[898:896]; // 9.0
    wire [3:0] v379; shift_adder #(1, 3, 0, 0, 4, -1, 0) op_379 (v377[0:0], v378[2:0], v379[3:0]); // 10.0
    wire [6:0] v380; assign v380[6:0] = model_inp[905:899]; // 9.0
    wire [7:0] v381; shift_adder #(4, 7, 0, 0, 8, -1, 1) op_381 (v38[3:0], v380[6:0], v381[7:0]); // 10.0
    wire [3:0] v382; assign v382[3:0] = model_inp[909:906]; // 9.0
    wire [4:0] v383; assign v383[4:0] = model_inp[914:910]; // 9.0
    wire [5:0] v384; assign v384[5:0] = model_inp[920:915]; // 9.0
    wire [6:0] v385; assign v385[6:0] = model_inp[927:921]; // 9.0
    wire [3:0] v386; assign v386[3:0] = model_inp[931:928]; // 9.0
    wire [3:0] v387; assign v387[3:0] = model_inp[935:932]; // 9.0
    wire [4:0] v388; assign v388[4:0] = model_inp[940:936]; // 9.0
    wire [6:0] v389; assign v389[6:0] = model_inp[947:941]; // 9.0
    wire [5:0] v390; assign v390[5:0] = model_inp[953:948]; // 9.0
    wire [6:0] v391; assign v391[6:0] = model_inp[960:954]; // 9.0
    wire [6:0] v392; assign v392[6:0] = model_inp[967:961]; // 9.0
    wire [6:0] v393; assign v393[6:0] = model_inp[974:968]; // 9.0
    wire [4:0] v394; assign v394[4:0] = model_inp[979:975]; // 9.0
    wire [3:0] v395; assign v395[3:0] = model_inp[983:980]; // 9.0
    wire [4:0] v396; assign v396[4:0] = model_inp[988:984]; // 9.0
    wire [5:0] v397; assign v397[5:0] = model_inp[994:989]; // 9.0
    wire [4:0] v398; assign v398[4:0] = model_inp[999:995]; // 9.0
    wire [2:0] v399; assign v399[2:0] = model_inp[1002:1000]; // 9.0
    wire [3:0] v400; assign v400[3:0] = model_inp[1006:1003]; // 9.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[6:0] = v2[6:0];
    assign model_out[12:7] = v33[5:0];
    assign model_out[19:13] = v4[6:0];
    assign model_out[26:20] = v7[6:0];
    assign model_out[32:27] = v10[5:0];
    assign model_out[38:33] = v13[5:0];
    assign model_out[42:39] = v207[3:0];
    assign model_out[48:43] = v15[5:0];
    assign model_out[55:49] = v18[6:0];
    assign model_out[60:56] = v20[4:0];
    assign model_out[66:61] = v23[5:0];
    assign model_out[73:67] = v25[6:0];
    assign model_out[77:74] = v3[3:0];
    assign model_out[84:78] = v28[6:0];
    assign model_out[88:85] = v186[3:0];
    assign model_out[93:89] = v31[4:0];
    assign model_out[101:94] = v34[7:0];
    assign model_out[109:102] = v37[7:0];
    assign model_out[114:110] = v89[4:0];
    assign model_out[118:115] = v149[3:0];
    assign model_out[124:119] = v35[5:0];
    assign model_out[131:125] = v39[6:0];
    assign model_out[136:132] = v46[4:0];
    assign model_out[141:137] = v52[4:0];
    assign model_out[146:142] = v64[4:0];
    assign model_out[150:147] = v132[3:0];
    assign model_out[155:151] = v67[4:0];
    assign model_out[163:156] = v70[7:0];
    assign model_out[169:164] = v72[5:0];
    assign model_out[174:170] = v75[4:0];
    assign model_out[182:175] = v77[7:0];
    assign model_out[188:183] = v229[5:0];
    assign model_out[194:189] = v79[5:0];
    assign model_out[199:195] = v14[4:0];
    assign model_out[204:200] = v81[4:0];
    assign model_out[208:205] = v19[3:0];
    assign model_out[214:209] = v83[5:0];
    assign model_out[221:215] = v86[6:0];
    assign model_out[229:222] = v88[7:0];
    assign model_out[233:230] = v126[3:0];
    assign model_out[239:234] = v90[5:0];
    assign model_out[245:240] = v91[5:0];
    assign model_out[252:246] = v93[6:0];
    assign model_out[256:253] = v1[3:0];
    assign model_out[265:257] = v96[8:0];
    assign model_out[270:266] = v271[4:0];
    assign model_out[276:271] = v27[5:0];
    assign model_out[283:277] = v98[6:0];
    assign model_out[288:284] = v16[4:0];
    assign model_out[293:289] = v101[4:0];
    assign model_out[299:294] = v102[5:0];
    assign model_out[305:300] = v104[5:0];
    assign model_out[312:306] = v105[6:0];
    assign model_out[319:313] = v106[6:0];
    assign model_out[324:320] = v113[4:0];
    assign model_out[328:325] = v382[3:0];
    assign model_out[332:329] = v38[3:0];
    assign model_out[339:333] = v116[6:0];
    assign model_out[345:340] = v117[5:0];
    assign model_out[350:346] = v119[4:0];
    assign model_out[356:351] = v121[5:0];
    assign model_out[362:357] = v122[5:0];
    assign model_out[367:363] = v124[4:0];
    assign model_out[374:368] = v125[6:0];
    assign model_out[379:375] = v127[4:0];
    assign model_out[386:380] = v129[6:0];
    assign model_out[392:387] = v130[5:0];
    assign model_out[397:393] = v133[4:0];
    assign model_out[401:398] = v9[3:0];
    assign model_out[408:402] = v136[6:0];
    assign model_out[416:409] = v138[7:0];
    assign model_out[423:417] = v140[6:0];
    assign model_out[429:424] = v143[5:0];
    assign model_out[437:430] = v145[7:0];
    assign model_out[444:438] = v57[6:0];
    assign model_out[451:445] = v147[6:0];
    assign model_out[456:452] = v383[4:0];
    assign model_out[460:457] = v120[3:0];
    assign model_out[466:461] = v148[5:0];
    assign model_out[470:467] = v65[3:0];
    assign model_out[476:471] = v384[5:0];
    assign model_out[483:477] = v150[6:0];
    assign model_out[489:484] = v152[5:0];
    assign model_out[495:490] = v69[5:0];
    assign model_out[500:496] = v153[4:0];
    assign model_out[507:501] = v385[6:0];
    assign model_out[512:508] = v154[4:0];
    assign model_out[520:513] = v156[7:0];
    assign model_out[526:521] = v157[5:0];
    assign model_out[532:527] = v158[5:0];
    assign model_out[537:533] = v160[4:0];
    assign model_out[542:538] = v162[4:0];
    assign model_out[550:543] = v164[7:0];
    assign model_out[557:551] = v166[6:0];
    assign model_out[565:558] = v169[7:0];
    assign model_out[572:566] = v170[6:0];
    assign model_out[580:573] = v172[7:0];
    assign model_out[586:581] = v173[5:0];
    assign model_out[594:587] = v174[7:0];
    assign model_out[598:595] = v386[3:0];
    assign model_out[605:599] = v177[6:0];
    assign model_out[612:606] = v179[6:0];
    assign model_out[620:613] = v182[7:0];
    assign model_out[628:621] = v185[7:0];
    assign model_out[634:629] = v187[5:0];
    assign model_out[640:635] = v188[5:0];
    assign model_out[646:641] = v189[5:0];
    assign model_out[650:647] = v387[3:0];
    assign model_out[658:651] = v192[7:0];
    assign model_out[664:659] = v194[5:0];
    assign model_out[671:665] = v198[6:0];
    assign model_out[677:672] = v200[5:0];
    assign model_out[684:678] = v201[6:0];
    assign model_out[691:685] = v203[6:0];
    assign model_out[696:692] = v97[4:0];
    assign model_out[702:697] = v55[5:0];
    assign model_out[708:703] = v204[5:0];
    assign model_out[716:709] = v206[7:0];
    assign model_out[722:717] = v208[5:0];
    assign model_out[729:723] = v212[6:0];
    assign model_out[736:730] = v214[6:0];
    assign model_out[741:737] = v216[4:0];
    assign model_out[746:742] = v12[4:0];
    assign model_out[751:747] = v217[4:0];
    assign model_out[758:752] = v219[6:0];
    assign model_out[763:759] = v388[4:0];
    assign model_out[771:764] = v220[7:0];
    assign model_out[775:772] = v66[3:0];
    assign model_out[782:776] = v221[6:0];
    assign model_out[786:783] = v29[3:0];
    assign model_out[790:787] = v286[3:0];
    assign model_out[797:791] = v222[6:0];
    assign model_out[805:798] = v224[7:0];
    assign model_out[812:806] = v196[6:0];
    assign model_out[817:813] = v247[4:0];
    assign model_out[822:818] = v225[4:0];
    assign model_out[829:823] = v227[6:0];
    assign model_out[836:830] = v230[6:0];
    assign model_out[843:837] = v231[6:0];
    assign model_out[849:844] = v232[5:0];
    assign model_out[854:850] = v233[4:0];
    assign model_out[861:855] = v234[6:0];
    assign model_out[869:862] = v236[7:0];
    assign model_out[877:870] = v238[7:0];
    assign model_out[882:878] = v239[4:0];
    assign model_out[889:883] = v241[6:0];
    assign model_out[896:890] = v389[6:0];
    assign model_out[902:897] = v242[5:0];
    assign model_out[909:903] = v243[6:0];
    assign model_out[916:910] = v246[6:0];
    assign model_out[921:917] = v8[4:0];
    assign model_out[927:922] = v248[5:0];
    assign model_out[934:928] = v237[6:0];
    assign model_out[941:935] = v250[6:0];
    assign model_out[947:942] = v251[5:0];
    assign model_out[953:948] = v252[5:0];
    assign model_out[960:954] = v253[6:0];
    assign model_out[967:961] = v255[6:0];
    assign model_out[972:968] = v256[4:0];
    assign model_out[977:973] = v82[4:0];
    assign model_out[983:978] = v258[5:0];
    assign model_out[989:984] = v260[5:0];
    assign model_out[994:990] = v240[4:0];
    assign model_out[1001:995] = v265[6:0];
    assign model_out[1006:1002] = v115[4:0];
    assign model_out[1012:1007] = v268[5:0];
    assign model_out[1019:1013] = v270[6:0];
    assign model_out[1026:1020] = v272[6:0];
    assign model_out[1032:1027] = v390[5:0];
    assign model_out[1039:1033] = v275[6:0];
    assign model_out[1047:1040] = v276[7:0];
    assign model_out[1052:1048] = v277[4:0];
    assign model_out[1057:1053] = v333[4:0];
    assign model_out[1065:1058] = v278[7:0];
    assign model_out[1071:1066] = v279[5:0];
    assign model_out[1077:1072] = v280[5:0];
    assign model_out[1085:1078] = v283[7:0];
    assign model_out[1093:1086] = v284[7:0];
    assign model_out[1099:1094] = v285[5:0];
    assign model_out[1105:1100] = v287[5:0];
    assign model_out[1110:1106] = v288[4:0];
    assign model_out[1116:1111] = v128[5:0];
    assign model_out[1123:1117] = v289[6:0];
    assign model_out[1130:1124] = v291[6:0];
    assign model_out[1136:1131] = v292[5:0];
    assign model_out[1143:1137] = v391[6:0];
    assign model_out[1148:1144] = v163[4:0];
    assign model_out[1155:1149] = v392[6:0];
    assign model_out[1162:1156] = v296[6:0];
    assign model_out[1168:1163] = v99[5:0];
    assign model_out[1177:1169] = v298[8:0];
    assign model_out[1183:1178] = v299[5:0];
    assign model_out[1189:1184] = v300[5:0];
    assign model_out[1197:1190] = v302[7:0];
    assign model_out[1202:1198] = v303[4:0];
    assign model_out[1208:1203] = v235[5:0];
    assign model_out[1216:1209] = v305[7:0];
    assign model_out[1224:1217] = v307[7:0];
    assign model_out[1231:1225] = v308[6:0];
    assign model_out[1238:1232] = v309[6:0];
    assign model_out[1243:1239] = v310[4:0];
    assign model_out[1250:1244] = v312[6:0];
    assign model_out[1257:1251] = v314[6:0];
    assign model_out[1264:1258] = v393[6:0];
    assign model_out[1272:1265] = v317[7:0];
    assign model_out[1277:1273] = v197[4:0];
    assign model_out[1283:1278] = v320[5:0];
    assign model_out[1293:1284] = v322[9:0];
    assign model_out[1300:1294] = v323[6:0];
    assign model_out[1306:1301] = v324[5:0];
    assign model_out[1314:1307] = v326[7:0];
    assign model_out[1321:1315] = v327[6:0];
    assign model_out[1326:1322] = v141[4:0];
    assign model_out[1335:1327] = v331[8:0];
    assign model_out[1342:1336] = v332[6:0];
    assign model_out[1351:1343] = v334[8:0];
    assign model_out[1358:1352] = v336[6:0];
    assign model_out[1364:1359] = v339[5:0];
    assign model_out[1372:1365] = v340[7:0];
    assign model_out[1379:1373] = v341[6:0];
    assign model_out[1386:1380] = v342[6:0];
    assign model_out[1393:1387] = v328[6:0];
    assign model_out[1400:1394] = v344[6:0];
    assign model_out[1406:1401] = v345[5:0];
    assign model_out[1412:1407] = v346[5:0];
    assign model_out[1418:1413] = v348[5:0];
    assign model_out[1422:1419] = v11[3:0];
    assign model_out[1429:1423] = v350[6:0];
    assign model_out[1436:1430] = v352[6:0];
    assign model_out[1442:1437] = v354[5:0];
    assign model_out[1449:1443] = v355[6:0];
    assign model_out[1454:1450] = v54[4:0];
    assign model_out[1461:1455] = v358[6:0];
    assign model_out[1468:1462] = v361[6:0];
    assign model_out[1476:1469] = v364[7:0];
    assign model_out[1486:1477] = v365[9:0];
    assign model_out[1493:1487] = v367[6:0];
    assign model_out[1500:1494] = v369[6:0];
    assign model_out[1505:1501] = v244[4:0];
    assign model_out[1512:1506] = v371[6:0];
    assign model_out[1517:1513] = v372[4:0];
    assign model_out[1523:1518] = v373[5:0];
    assign model_out[1530:1524] = v374[6:0];
    assign model_out[1537:1531] = v100[6:0];
    assign model_out[1544:1538] = v376[6:0];
    assign model_out[1552:1545] = v381[7:0];
    assign model_out[1557:1553] = v368[4:0];
    assign model_out[1563:1558] = v210[5:0];
    assign model_out[1567:1564] = v123[3:0];
    assign model_out[1570:1568] = v338[2:0];
    assign model_out[1575:1571] = v349[4:0];
    assign model_out[1583:1576] = v262[7:0];
    assign model_out[1588:1584] = v394[4:0];
    assign model_out[1595:1589] = v295[6:0];
    assign model_out[1602:1596] = v315[6:0];
    assign model_out[1606:1603] = v6[3:0];
    assign model_out[1610:1607] = v395[3:0];
    assign model_out[1617:1611] = v359[6:0];
    assign model_out[1623:1618] = v267[5:0];
    assign model_out[1626:1624] = v378[2:0];
    assign model_out[1629:1627] = v273[2:0];
    assign model_out[1635:1630] = v178[5:0];
    assign model_out[1640:1636] = v22[4:0];
    assign model_out[1646:1641] = v269[5:0];
    assign model_out[1651:1647] = v396[4:0];
    assign model_out[1657:1652] = v397[5:0];
    assign model_out[1663:1658] = v319[5:0];
    assign model_out[1668:1664] = v398[4:0];
    assign model_out[1672:1669] = v74[3:0];
    assign model_out[1676:1673] = v139[3:0];
    assign model_out[1680:1677] = v142[3:0];
    assign model_out[1684:1681] = v213[3:0];
    assign model_out[1687:1685] = v399[2:0];
    assign model_out[1691:1688] = v379[3:0];
    assign model_out[1692:1692] = v377[0:0];
    assign model_out[1696:1693] = v400[3:0];

endmodule
