`timescale 1 ns / 1 ps

module qec_d3_stage8 (
    input [417:0] model_inp,
    output [337:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [1:0] v0; assign v0[1:0] = model_inp[1:0]; // 16.0
    wire [9:0] v1; assign v1[9:0] = model_inp[11:2]; // 16.0
    wire [9:0] v2; shift_adder #(2, 10, 0, 1, 10, -2, 1) op_2 (v0[1:0], v1[9:0], v2[9:0]); // 17.0
    wire [13:0] v3; assign v3[13:0] = model_inp[25:12]; // 16.0
    wire [11:0] v4; assign v4[11:0] = model_inp[37:26]; // 16.0
    wire [13:0] v5; shift_adder #(14, 12, 1, 1, 14, 1, 0) op_5 (v3[13:0], v4[11:0], v5[13:0]); // 17.0
    wire [13:0] v6; shift_adder #(14, 4, 1, 0, 14, 0, 0) op_6 (v5[13:0], 4'b1100, v6[13:0]); // 17.0
    wire [12:0] v7; assign v7[12:0] = v6[12:0] & {13{~v6[13]}}; // 17.0
    wire [12:0] v8; shift_adder #(13, 4, 0, 0, 13, 0, 0) op_8 (v7[12:0], 4'b1000, v8[12:0]); // 17.0
    wire [7:0] v9; assign v9[7:0] = v8[11:4]; // 17.0
    wire [1:0] v10; assign v10[1:0] = model_inp[39:38]; // 16.0
    wire [5:0] v11; assign v11[5:0] = model_inp[45:40]; // 16.0
    wire [6:0] v12; shift_adder #(2, 6, 0, 0, 7, -1, 1) op_12 (v10[1:0], v11[5:0], v12[6:0]); // 17.0
    wire [5:0] v13; assign v13[5:0] = model_inp[51:46]; // 16.0
    wire [1:0] v14; assign v14[1:0] = model_inp[53:52]; // 16.0
    wire [6:0] v15; shift_adder #(6, 2, 0, 0, 7, 4, 0) op_15 (v13[5:0], v14[1:0], v15[6:0]); // 17.0
    wire [7:0] v16; assign v16[7:0] = model_inp[61:54]; // 16.0
    wire [8:0] v17; assign v17[8:0] = model_inp[70:62]; // 16.0
    wire [9:0] v18; shift_adder #(8, 9, 1, 1, 10, 0, 0) op_18 (v16[7:0], v17[8:0], v18[9:0]); // 17.0
    wire [6:0] v19; assign v19[6:0] = model_inp[77:71]; // 16.0
    wire [8:0] v20; assign v20[8:0] = model_inp[86:78]; // 16.0
    wire [11:0] v21; shift_adder #(7, 9, 0, 1, 12, -3, 0) op_21 (v19[6:0], v20[8:0], v21[11:0]); // 17.0
    wire [4:0] v22; assign v22[4:0] = model_inp[91:87]; // 16.0
    wire [7:0] v23; shift_adder #(5, 6, 0, 0, 8, -2, 1) op_23 (v22[4:0], v13[5:0], v23[7:0]); // 17.0
    wire [3:0] v24; assign v24[3:0] = model_inp[95:92]; // 16.0
    wire [7:0] v25; assign v25[7:0] = model_inp[103:96]; // 16.0
    wire [7:0] v26; shift_adder #(4, 8, 0, 1, 8, 0, 0) op_26 (v24[3:0], v25[7:0], v26[7:0]); // 17.0
    wire [3:0] v27; assign v27[3:0] = model_inp[107:104]; // 16.0
    wire [5:0] v28; assign v28[5:0] = model_inp[113:108]; // 16.0
    wire [8:0] v29; shift_adder #(4, 6, 0, 1, 9, 2, 1) op_29 (v27[3:0], v28[5:0], v29[8:0]); // 17.0
    wire [4:0] v30; assign v30[4:0] = model_inp[118:114]; // 16.0
    wire [6:0] v31; shift_adder #(6, 5, 0, 0, 7, 0, 0) op_31 (v13[5:0], v30[4:0], v31[6:0]); // 17.0
    wire [7:0] v32; assign v32[7:0] = model_inp[126:119]; // 16.0
    wire [8:0] v33; shift_adder #(8, 8, 1, 1, 9, 1, 0) op_33 (v32[7:0], v25[7:0], v33[8:0]); // 17.0
    wire [5:0] v34; assign v34[5:0] = model_inp[132:127]; // 16.0
    wire [6:0] v35; assign v35[6:0] = model_inp[139:133]; // 16.0
    wire [7:0] v36; shift_adder #(6, 7, 1, 1, 8, 0, 1) op_36 (v34[5:0], v35[6:0], v36[7:0]); // 17.0
    wire [12:0] v37; assign v37[12:0] = model_inp[152:140]; // 16.0
    wire [8:0] v38; assign v38[8:0] = model_inp[161:153]; // 16.0
    wire [12:0] v39; shift_adder #(13, 9, 1, 1, 13, 1, 1) op_39 (v37[12:0], v38[8:0], v39[12:0]); // 17.0
    wire [13:0] v40; shift_adder #(13, 4, 1, 0, 14, -1, 0) op_40 (v39[12:0], 4'b1101, v40[13:0]); // 17.0
    wire [12:0] v41; assign v41[12:0] = v40[12:0] & {13{~v40[13]}}; // 17.0
    wire [12:0] v42; shift_adder #(13, 4, 0, 0, 13, 0, 0) op_42 (v41[12:0], 4'b1000, v42[12:0]); // 17.0
    wire [5:0] v43; assign v43[5:0] = v42[9:4]; // 17.0
    wire [7:0] v44; assign v44[7:0] = model_inp[169:162]; // 16.0
    wire [8:0] v45; shift_adder #(8, 7, 0, 0, 9, 0, 0) op_45 (v44[7:0], v19[6:0], v45[8:0]); // 17.0
    wire [8:0] v46; assign v46[8:0] = model_inp[178:170]; // 16.0
    wire [7:0] v47; assign v47[7:0] = model_inp[186:179]; // 16.0
    wire [9:0] v48; shift_adder #(9, 8, 1, 1, 10, 1, 0) op_48 (v46[8:0], v47[7:0], v48[9:0]); // 17.0
    wire [7:0] v49; assign v49[7:0] = model_inp[194:187]; // 16.0
    wire [8:0] v50; shift_adder #(8, 5, 1, 0, 9, 2, 1) op_50 (v49[7:0], v30[4:0], v50[8:0]); // 17.0
    wire [6:0] v51; assign v51[6:0] = model_inp[201:195]; // 16.0
    wire [8:0] v52; shift_adder #(7, 7, 0, 0, 9, 1, 0) op_52 (v51[6:0], v19[6:0], v52[8:0]); // 17.0
    wire [4:0] v53; assign v53[4:0] = model_inp[206:202]; // 16.0
    wire [6:0] v54; assign v54[6:0] = model_inp[213:207]; // 16.0
    wire [7:0] v55; shift_adder #(5, 7, 0, 1, 8, 0, 1) op_55 (v53[4:0], v54[6:0], v55[7:0]); // 17.0
    wire [8:0] v56; assign v56[8:0] = model_inp[222:214]; // 16.0
    wire [5:0] v57; assign v57[5:0] = model_inp[228:223]; // 16.0
    wire [10:0] v58; shift_adder #(9, 6, 1, 0, 11, 3, 1) op_58 (v56[8:0], v57[5:0], v58[10:0]); // 17.0
    wire [9:0] v59; assign v59[9:0] = model_inp[238:229]; // 16.0
    wire [10:0] v60; shift_adder #(10, 9, 1, 1, 11, 1, 0) op_60 (v59[9:0], v20[8:0], v60[10:0]); // 17.0
    wire [3:0] v61; assign v61[3:0] = model_inp[242:239]; // 16.0
    wire [7:0] v62; shift_adder #(4, 7, 0, 0, 8, -2, 0) op_62 (v61[3:0], v51[6:0], v62[7:0]); // 17.0
    wire [8:0] v63; assign v63[8:0] = model_inp[251:243]; // 16.0
    wire [8:0] v64; shift_adder #(6, 9, 1, 1, 9, -1, 0) op_64 (v34[5:0], v63[8:0], v64[8:0]); // 17.0
    wire [7:0] v65; assign v65[7:0] = model_inp[259:252]; // 16.0
    wire [9:0] v66; shift_adder #(8, 5, 1, 0, 10, 3, 1) op_66 (v65[7:0], v53[4:0], v66[9:0]); // 17.0
    wire [6:0] v67; assign v67[6:0] = model_inp[266:260]; // 16.0
    wire [8:0] v68; shift_adder #(7, 6, 0, 1, 9, 2, 0) op_68 (v67[6:0], v28[5:0], v68[8:0]); // 17.0
    wire [7:0] v69; assign v69[7:0] = model_inp[274:267]; // 16.0
    wire [8:0] v70; shift_adder #(5, 8, 0, 1, 9, -2, 0) op_70 (v30[4:0], v69[7:0], v70[8:0]); // 17.0
    wire [14:0] v71; assign v71[14:0] = model_inp[289:275]; // 16.0
    wire [15:0] v72; shift_adder #(15, 10, 1, 1, 16, 2, 0) op_72 (v71[14:0], v2[9:0], v72[15:0]); // 18.0
    wire [13:0] v73; assign v73[13:0] = v72[13:0] & {14{~v72[15]}}; // 18.0
    wire [13:0] v74; shift_adder #(14, 5, 0, 0, 14, 0, 0) op_74 (v73[13:0], 5'b10000, v74[13:0]); // 18.0
    wire [6:0] v75; assign v75[6:0] = v74[11:5]; // 18.0
    wire [13:0] v76; assign v76[13:0] = model_inp[303:290]; // 16.0
    wire [13:0] v77; shift_adder #(14, 10, 1, 1, 14, 1, 0) op_77 (v76[13:0], v2[9:0], v77[13:0]); // 18.0
    wire [13:0] v78; shift_adder #(14, 6, 1, 0, 14, 0, 1) op_78 (v77[13:0], 6'b100000, v78[13:0]); // 18.0
    wire [12:0] v79; assign v79[12:0] = v78[12:0] & {13{~v78[13]}}; // 18.0
    wire [12:0] v80; shift_adder #(13, 4, 0, 0, 13, 0, 0) op_80 (v79[12:0], 4'b1000, v80[12:0]); // 18.0
    wire [6:0] v81; assign v81[6:0] = v80[10:4]; // 18.0
    wire [1:0] v82; assign v82[1:0] = model_inp[305:304]; // 16.0
    wire [6:0] v83; shift_adder #(2, 7, 0, 1, 7, -2, 1) op_83 (v82[1:0], v12[6:0], v83[6:0]); // 18.0
    wire [12:0] v84; shift_adder #(10, 12, 1, 1, 13, -3, 1) op_84 (v18[9:0], v21[11:0], v84[12:0]); // 18.0
    wire [8:0] v85; assign v85[8:0] = model_inp[314:306]; // 16.0
    wire [10:0] v86; shift_adder #(7, 9, 0, 1, 11, 2, 0) op_86 (v15[6:0], v85[8:0], v86[10:0]); // 18.0
    wire [7:0] v87; shift_adder #(2, 8, 0, 1, 8, -4, 1) op_87 (v14[1:0], v23[7:0], v87[7:0]); // 18.0
    wire [2:0] v88; assign v88[2:0] = model_inp[317:315]; // 16.0
    wire [8:0] v89; shift_adder #(3, 8, 0, 1, 9, 1, 1) op_89 (v88[2:0], v26[7:0], v89[8:0]); // 18.0
    wire [0:0] v90; assign v90[0:0] = model_inp[318:318]; // 16.0
    wire [8:0] v91; shift_adder #(1, 9, 0, 1, 9, -4, 0) op_91 (v90[0:0], v29[8:0], v91[8:0]); // 18.0
    wire [10:0] v92; shift_adder #(7, 9, 0, 1, 11, 1, 0) op_92 (v31[6:0], v33[8:0], v92[10:0]); // 18.0
    wire [8:0] v93; assign v93[8:0] = model_inp[327:319]; // 16.0
    wire [9:0] v94; shift_adder #(9, 8, 1, 1, 10, 0, 0) op_94 (v93[8:0], v36[7:0], v94[9:0]); // 18.0
    wire [4:0] v95; assign v95[4:0] = model_inp[332:328]; // 16.0
    wire [6:0] v96; shift_adder #(5, 6, 0, 0, 7, 0, 0) op_96 (v95[4:0], v43[5:0], v96[6:0]); // 18.0
    wire [14:0] v97; shift_adder #(9, 8, 0, 0, 15, -6, 0) op_97 (v45[8:0], v9[7:0], v97[14:0]); // 18.0
    wire [4:0] v98; assign v98[4:0] = model_inp[337:333]; // 16.0
    wire [7:0] v99; shift_adder #(5, 6, 0, 0, 8, -2, 1) op_99 (v98[4:0], v43[5:0], v99[7:0]); // 18.0
    wire [10:0] v100; shift_adder #(10, 7, 1, 0, 11, 1, 0) op_100 (v48[9:0], v31[6:0], v100[10:0]); // 18.0
    wire [10:0] v101; shift_adder #(9, 9, 1, 0, 11, 0, 1) op_101 (v50[8:0], v52[8:0], v101[10:0]); // 18.0
    wire [7:0] v102; shift_adder #(4, 8, 0, 1, 8, -1, 0) op_102 (v27[3:0], v55[7:0], v102[7:0]); // 18.0
    wire [11:0] v103; assign v103[11:0] = model_inp[349:338]; // 16.0
    wire [13:0] v104; shift_adder #(11, 12, 1, 1, 14, -2, 1) op_104 (v58[10:0], v103[11:0], v104[13:0]); // 18.0
    wire [10:0] v105; shift_adder #(11, 8, 1, 0, 11, 0, 1) op_105 (v60[10:0], v62[7:0], v105[10:0]); // 18.0
    wire [6:0] v106; assign v106[6:0] = model_inp[356:350]; // 16.0
    wire [10:0] v107; shift_adder #(9, 7, 1, 0, 11, 3, 1) op_107 (v64[8:0], v106[6:0], v107[10:0]); // 18.0
    wire [8:0] v108; shift_adder #(8, 7, 0, 0, 9, 0, 0) op_108 (v9[7:0], v67[6:0], v108[8:0]); // 18.0
    wire [5:0] v109; assign v109[5:0] = model_inp[362:357]; // 16.0
    wire [8:0] v110; shift_adder #(6, 7, 0, 0, 9, 1, 1) op_110 (v109[5:0], v31[6:0], v110[8:0]); // 18.0
    wire [9:0] v111; shift_adder #(10, 6, 1, 0, 10, 1, 1) op_111 (v66[9:0], v43[5:0], v111[9:0]); // 18.0
    wire [9:0] v112; shift_adder #(9, 8, 1, 0, 10, 0, 0) op_112 (v68[8:0], v62[7:0], v112[9:0]); // 18.0
    wire [8:0] v113; assign v113[8:0] = model_inp[371:363]; // 16.0
    wire [10:0] v114; shift_adder #(9, 9, 1, 1, 11, -2, 0) op_114 (v113[8:0], v70[8:0], v114[10:0]); // 18.0
    wire [4:0] v115; assign v115[4:0] = model_inp[376:372]; // 16.0
    wire [4:0] v116; assign v116[4:0] = model_inp[381:377]; // 16.0
    wire [3:0] v117; assign v117[3:0] = model_inp[385:382]; // 16.0
    wire [4:0] v118; assign v118[4:0] = model_inp[390:386]; // 16.0
    wire [4:0] v119; assign v119[4:0] = model_inp[395:391]; // 16.0
    wire [4:0] v120; assign v120[4:0] = model_inp[400:396]; // 16.0
    wire [4:0] v121; assign v121[4:0] = model_inp[405:401]; // 16.0
    wire [3:0] v122; assign v122[3:0] = model_inp[409:406]; // 16.0
    wire [3:0] v123; assign v123[3:0] = model_inp[413:410]; // 16.0
    wire [1:0] v124; assign v124[1:0] = model_inp[415:414]; // 16.0
    wire [1:0] v125; assign v125[1:0] = model_inp[417:416]; // 16.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[6:0] = v75[6:0];
    assign model_out[11:7] = v53[4:0];
    assign model_out[18:12] = v81[6:0];
    assign model_out[25:19] = v67[6:0];
    assign model_out[33:26] = v9[7:0];
    assign model_out[40:34] = v83[6:0];
    assign model_out[47:41] = v15[6:0];
    assign model_out[60:48] = v84[12:0];
    assign model_out[71:61] = v86[10:0];
    assign model_out[79:72] = v87[7:0];
    assign model_out[88:80] = v89[8:0];
    assign model_out[97:89] = v91[8:0];
    assign model_out[108:98] = v92[10:0];
    assign model_out[118:109] = v94[9:0];
    assign model_out[125:119] = v96[6:0];
    assign model_out[130:126] = v115[4:0];
    assign model_out[145:131] = v97[14:0];
    assign model_out[153:146] = v99[7:0];
    assign model_out[164:154] = v100[10:0];
    assign model_out[175:165] = v101[10:0];
    assign model_out[180:176] = v116[4:0];
    assign model_out[184:181] = v117[3:0];
    assign model_out[192:185] = v102[7:0];
    assign model_out[206:193] = v104[13:0];
    assign model_out[217:207] = v105[10:0];
    assign model_out[228:218] = v107[10:0];
    assign model_out[234:229] = v43[5:0];
    assign model_out[243:235] = v108[8:0];
    assign model_out[248:244] = v118[4:0];
    assign model_out[257:249] = v110[8:0];
    assign model_out[267:258] = v111[9:0];
    assign model_out[276:268] = v45[8:0];
    assign model_out[287:277] = v114[10:0];
    assign model_out[292:288] = v119[4:0];
    assign model_out[297:293] = v120[4:0];
    assign model_out[303:298] = v13[5:0];
    assign model_out[305:304] = v10[1:0];
    assign model_out[310:306] = v121[4:0];
    assign model_out[320:311] = v112[9:0];
    assign model_out[323:321] = v88[2:0];
    assign model_out[327:324] = v122[3:0];
    assign model_out[331:328] = v123[3:0];
    assign model_out[333:332] = v124[1:0];
    assign model_out[335:334] = v125[1:0];
    assign model_out[337:336] = v82[1:0];

endmodule
