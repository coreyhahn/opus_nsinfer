`timescale 1 ns / 1 ps

module jsc_stage15 (
    input [886:0] model_inp,
    output [536:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [12:0] v0; assign v0[12:0] = model_inp[12:0]; // 15.0
    wire [10:0] v1; assign v1[10:0] = model_inp[23:13]; // 15.0
    wire [13:0] v2; shift_adder #(13, 11, 1, 1, 14, 2, 1) op_2 (v0[12:0], v1[10:0], v2[13:0]); // 16.0
    wire [10:0] v3; assign v3[10:0] = v2[10:0] & {11{~v2[13]}}; // 16.0
    wire [10:0] v4; shift_adder #(11, 4, 0, 0, 11, 0, 0) op_4 (v3[10:0], 4'b1000, v4[10:0]); // 16.0
    wire [4:0] v5; assign v5[4:0] = v4[8:4]; // 16.0
    wire [10:0] v6; assign v6[10:0] = model_inp[34:24]; // 15.0
    wire [12:0] v7; assign v7[12:0] = model_inp[47:35]; // 15.0
    wire [12:0] v8; shift_adder #(11, 13, 1, 1, 13, -1, 0) op_8 (v6[10:0], v7[12:0], v8[12:0]); // 16.0
    wire [11:0] v9; assign v9[11:0] = v8[11:0] & {12{~v8[12]}}; // 16.0
    wire [11:0] v10; shift_adder #(12, 3, 0, 0, 12, 0, 0) op_10 (v9[11:0], 3'b100, v10[11:0]); // 16.0
    wire [5:0] v11; assign v11[5:0] = v10[8:3]; // 16.0
    wire [11:0] v12; assign v12[11:0] = model_inp[59:48]; // 15.0
    wire [12:0] v13; assign v13[12:0] = model_inp[72:60]; // 15.0
    wire [13:0] v14; shift_adder #(12, 13, 1, 1, 14, -1, 0) op_14 (v12[11:0], v13[12:0], v14[13:0]); // 16.0
    wire [13:0] v15; shift_adder #(14, 7, 1, 0, 14, 0, 1) op_15 (v14[13:0], 7'b1000000, v15[13:0]); // 16.0
    wire [12:0] v16; assign v16[12:0] = v15[12:0] & {13{~v15[13]}}; // 16.0
    wire [12:0] v17; shift_adder #(13, 4, 0, 0, 13, 0, 0) op_17 (v16[12:0], 4'b1000, v17[12:0]); // 16.0
    wire [6:0] v18; assign v18[6:0] = v17[10:4]; // 16.0
    wire [5:0] v19; assign v19[5:0] = model_inp[78:73]; // 15.0
    wire [4:0] v20; assign v20[4:0] = model_inp[83:79]; // 15.0
    wire [7:0] v21; shift_adder #(6, 5, 0, 0, 8, 2, 0) op_21 (v19[5:0], v20[4:0], v21[7:0]); // 16.0
    wire [11:0] v22; assign v22[11:0] = model_inp[95:84]; // 15.0
    wire [8:0] v23; assign v23[8:0] = model_inp[104:96]; // 15.0
    wire [11:0] v24; shift_adder #(12, 9, 1, 0, 12, 0, 1) op_24 (v22[11:0], v23[8:0], v24[11:0]); // 16.0
    wire [9:0] v25; assign v25[9:0] = v24[9:0] & {10{~v24[11]}}; // 16.0
    wire [9:0] v26; shift_adder #(10, 4, 0, 0, 10, 0, 0) op_26 (v25[9:0], 4'b1000, v26[9:0]); // 16.0
    wire [3:0] v27; assign v27[3:0] = v26[7:4]; // 16.0
    wire [11:0] v28; assign v28[11:0] = model_inp[116:105]; // 15.0
    wire [12:0] v29; assign v29[12:0] = model_inp[129:117]; // 15.0
    wire [13:0] v30; shift_adder #(12, 13, 1, 1, 14, 1, 0) op_30 (v28[11:0], v29[12:0], v30[13:0]); // 16.0
    wire [13:0] v31; shift_adder #(14, 6, 1, 0, 14, 0, 1) op_31 (v30[13:0], 6'b111000, v31[13:0]); // 16.0
    wire [12:0] v32; assign v32[12:0] = v31[12:0] & {13{~v31[13]}}; // 16.0
    wire [12:0] v33; shift_adder #(13, 5, 0, 0, 13, 0, 0) op_33 (v32[12:0], 5'b10000, v33[12:0]); // 16.0
    wire [6:0] v34; assign v34[6:0] = v33[11:5]; // 16.0
    wire [10:0] v35; assign v35[10:0] = model_inp[140:130]; // 15.0
    wire [8:0] v36; assign v36[8:0] = model_inp[149:141]; // 15.0
    wire [11:0] v37; shift_adder #(11, 9, 1, 1, 12, 2, 1) op_37 (v35[10:0], v36[8:0], v37[11:0]); // 16.0
    wire [13:0] v38; assign v38[13:0] = model_inp[163:150]; // 15.0
    wire [11:0] v39; assign v39[11:0] = model_inp[175:164]; // 15.0
    wire [14:0] v40; shift_adder #(14, 12, 1, 1, 15, -1, 1) op_40 (v38[13:0], v39[11:0], v40[14:0]); // 16.0
    wire [11:0] v41; assign v41[11:0] = model_inp[187:176]; // 15.0
    wire [10:0] v42; assign v42[10:0] = model_inp[198:188]; // 15.0
    wire [12:0] v43; shift_adder #(12, 11, 1, 1, 13, -1, 0) op_43 (v41[11:0], v42[10:0], v43[12:0]); // 16.0
    wire [13:0] v44; assign v44[13:0] = model_inp[212:199]; // 15.0
    wire [10:0] v45; assign v45[10:0] = model_inp[223:213]; // 15.0
    wire [13:0] v46; shift_adder #(14, 11, 1, 1, 14, 1, 1) op_46 (v44[13:0], v45[10:0], v46[13:0]); // 16.0
    wire [12:0] v47; assign v47[12:0] = model_inp[236:224]; // 15.0
    wire [10:0] v48; assign v48[10:0] = model_inp[247:237]; // 15.0
    wire [12:0] v49; shift_adder #(13, 11, 1, 1, 13, 2, 1) op_49 (v47[12:0], v48[10:0], v49[12:0]); // 16.0
    wire [11:0] v50; assign v50[11:0] = model_inp[259:248]; // 15.0
    wire [13:0] v51; assign v51[13:0] = model_inp[273:260]; // 15.0
    wire [13:0] v52; shift_adder #(12, 14, 1, 1, 14, -2, 0) op_52 (v50[11:0], v51[13:0], v52[13:0]); // 16.0
    wire [13:0] v53; assign v53[13:0] = model_inp[287:274]; // 15.0
    wire [12:0] v54; assign v54[12:0] = model_inp[300:288]; // 15.0
    wire [15:0] v55; shift_adder #(14, 13, 1, 1, 16, -2, 1) op_55 (v53[13:0], v54[12:0], v55[15:0]); // 16.0
    wire [10:0] v56; assign v56[10:0] = model_inp[311:301]; // 15.0
    wire [10:0] v57; assign v57[10:0] = model_inp[322:312]; // 15.0
    wire [11:0] v58; shift_adder #(11, 11, 1, 1, 12, 1, 0) op_58 (v56[10:0], v57[10:0], v58[11:0]); // 16.0
    wire [10:0] v59; assign v59[10:0] = model_inp[333:323]; // 15.0
    wire [13:0] v60; assign v60[13:0] = model_inp[347:334]; // 15.0
    wire [13:0] v61; shift_adder #(11, 14, 1, 1, 14, -1, 0) op_61 (v59[10:0], v60[13:0], v61[13:0]); // 16.0
    wire [12:0] v62; assign v62[12:0] = model_inp[360:348]; // 15.0
    wire [9:0] v63; assign v63[9:0] = model_inp[370:361]; // 15.0
    wire [12:0] v64; shift_adder #(13, 10, 1, 1, 13, 0, 1) op_64 (v62[12:0], v63[9:0], v64[12:0]); // 16.0
    wire [15:0] v65; assign v65[15:0] = model_inp[386:371]; // 15.0
    wire [13:0] v66; assign v66[13:0] = model_inp[400:387]; // 15.0
    wire [15:0] v67; shift_adder #(16, 14, 1, 1, 16, 0, 0) op_67 (v65[15:0], v66[13:0], v67[15:0]); // 16.0
    wire [11:0] v68; assign v68[11:0] = model_inp[412:401]; // 15.0
    wire [13:0] v69; assign v69[13:0] = model_inp[426:413]; // 15.0
    wire [14:0] v70; shift_adder #(12, 14, 1, 1, 15, 1, 1) op_70 (v68[11:0], v69[13:0], v70[14:0]); // 16.0
    wire [8:0] v71; assign v71[8:0] = model_inp[435:427]; // 15.0
    wire [12:0] v72; assign v72[12:0] = model_inp[448:436]; // 15.0
    wire [12:0] v73; shift_adder #(9, 13, 1, 1, 13, -2, 0) op_73 (v71[8:0], v72[12:0], v73[12:0]); // 16.0
    wire [11:0] v74; assign v74[11:0] = model_inp[460:449]; // 15.0
    wire [11:0] v75; assign v75[11:0] = model_inp[472:461]; // 15.0
    wire [12:0] v76; shift_adder #(12, 12, 1, 1, 13, 1, 1) op_76 (v74[11:0], v75[11:0], v76[12:0]); // 16.0
    wire [11:0] v77; assign v77[11:0] = model_inp[484:473]; // 15.0
    wire [11:0] v78; shift_adder #(11, 12, 1, 1, 12, 0, 0) op_78 (v59[10:0], v77[11:0], v78[11:0]); // 16.0
    wire [10:0] v79; assign v79[10:0] = model_inp[495:485]; // 15.0
    wire [10:0] v80; shift_adder #(9, 11, 1, 1, 11, 0, 1) op_80 (v71[8:0], v79[10:0], v80[10:0]); // 16.0
    wire [12:0] v81; assign v81[12:0] = model_inp[508:496]; // 15.0
    wire [13:0] v82; assign v82[13:0] = model_inp[522:509]; // 15.0
    wire [13:0] v83; shift_adder #(13, 14, 1, 1, 14, 0, 0) op_83 (v81[12:0], v82[13:0], v83[13:0]); // 16.0
    wire [12:0] v84; assign v84[12:0] = model_inp[535:523]; // 15.0
    wire [12:0] v85; assign v85[12:0] = model_inp[548:536]; // 15.0
    wire [13:0] v86; shift_adder #(13, 13, 1, 1, 14, -1, 1) op_86 (v84[12:0], v85[12:0], v86[13:0]); // 16.0
    wire [11:0] v87; assign v87[11:0] = model_inp[560:549]; // 15.0
    wire [12:0] v88; assign v88[12:0] = model_inp[573:561]; // 15.0
    wire [13:0] v89; shift_adder #(12, 13, 1, 1, 14, 0, 0) op_89 (v87[11:0], v88[12:0], v89[13:0]); // 16.0
    wire [12:0] v90; shift_adder #(13, 5, 1, 0, 13, 0, 0) op_90 (v64[12:0], 5'b10000, v90[12:0]); // 16.0
    wire [8:0] v91; assign v91[8:0] = v90[8:0] & {9{~v90[12]}}; // 16.0
    wire [8:0] v92; shift_adder #(9, 4, 0, 0, 9, 0, 0) op_92 (v91[8:0], 4'b1000, v92[8:0]); // 16.0
    wire [2:0] v93; assign v93[2:0] = v92[6:4]; // 16.0
    wire [12:0] v94; assign v94[12:0] = model_inp[586:574]; // 15.0
    wire [11:0] v95; assign v95[11:0] = model_inp[598:587]; // 15.0
    wire [13:0] v96; shift_adder #(13, 12, 1, 1, 14, -1, 1) op_96 (v94[12:0], v95[11:0], v96[13:0]); // 16.0
    wire [13:0] v97; shift_adder #(14, 4, 1, 0, 14, 0, 1) op_97 (v96[13:0], 4'b1100, v97[13:0]); // 16.0
    wire [9:0] v98; assign v98[9:0] = v97[9:0] & {10{~v97[13]}}; // 16.0
    wire [9:0] v99; shift_adder #(10, 3, 0, 0, 10, 0, 0) op_99 (v98[9:0], 3'b100, v99[9:0]); // 16.0
    wire [4:0] v100; assign v100[4:0] = v99[7:3]; // 16.0
    wire [14:0] v101; assign v101[14:0] = model_inp[613:599]; // 15.0
    wire [13:0] v102; assign v102[13:0] = model_inp[627:614]; // 15.0
    wire [14:0] v103; shift_adder #(15, 14, 1, 1, 15, 0, 0) op_103 (v101[14:0], v102[13:0], v103[14:0]); // 16.0
    wire [14:0] v104; shift_adder #(15, 9, 1, 0, 15, 0, 1) op_104 (v103[14:0], 9'b100000000, v104[14:0]); // 16.0
    wire [13:0] v105; assign v105[13:0] = v104[13:0] & {14{~v104[14]}}; // 16.0
    wire [13:0] v106; shift_adder #(14, 5, 0, 0, 14, 0, 0) op_106 (v105[13:0], 5'b10000, v106[13:0]); // 16.0
    wire [7:0] v107; assign v107[7:0] = v106[12:5]; // 16.0
    wire [9:0] v108; assign v108[9:0] = model_inp[637:628]; // 15.0
    wire [7:0] v109; assign v109[7:0] = model_inp[645:638]; // 15.0
    wire [10:0] v110; shift_adder #(10, 8, 1, 1, 11, 0, 1) op_110 (v108[9:0], v109[7:0], v110[10:0]); // 16.0
    wire [10:0] v111; assign v111[10:0] = model_inp[656:646]; // 15.0
    wire [10:0] v112; assign v112[10:0] = model_inp[667:657]; // 15.0
    wire [12:0] v113; shift_adder #(11, 11, 1, 1, 13, -2, 0) op_113 (v111[10:0], v112[10:0], v113[12:0]); // 16.0
    wire [8:0] v114; assign v114[8:0] = v113[8:0] & {9{~v113[12]}}; // 16.0
    wire [8:0] v115; shift_adder #(9, 4, 0, 0, 9, 0, 0) op_115 (v114[8:0], 4'b1000, v115[8:0]); // 16.0
    wire [3:0] v116; assign v116[3:0] = v115[7:4]; // 16.0
    wire [11:0] v117; assign v117[11:0] = model_inp[679:668]; // 15.0
    wire [10:0] v118; assign v118[10:0] = model_inp[690:680]; // 15.0
    wire [12:0] v119; shift_adder #(12, 11, 1, 1, 13, 2, 1) op_119 (v117[11:0], v118[10:0], v119[12:0]); // 16.0
    wire [3:0] v120; assign v120[3:0] = model_inp[694:691]; // 15.0
    wire [6:0] v121; assign v121[6:0] = model_inp[701:695]; // 15.0
    wire [6:0] v122; shift_adder #(4, 7, 0, 1, 7, 0, 0) op_122 (v120[3:0], v121[6:0], v122[6:0]); // 16.0
    wire [11:0] v123; assign v123[11:0] = model_inp[713:702]; // 15.0
    wire [10:0] v124; assign v124[10:0] = model_inp[724:714]; // 15.0
    wire [13:0] v125; shift_adder #(12, 11, 1, 1, 14, 2, 1) op_125 (v123[11:0], v124[10:0], v125[13:0]); // 16.0
    wire [10:0] v126; assign v126[10:0] = model_inp[735:725]; // 15.0
    wire [12:0] v127; assign v127[12:0] = model_inp[748:736]; // 15.0
    wire [12:0] v128; shift_adder #(11, 13, 1, 1, 13, 0, 0) op_128 (v126[10:0], v127[12:0], v128[12:0]); // 16.0
    wire [12:0] v129; shift_adder #(13, 5, 1, 0, 13, 0, 1) op_129 (v43[12:0], 5'b10000, v129[12:0]); // 16.0
    wire [10:0] v130; assign v130[10:0] = v129[10:0] & {11{~v129[12]}}; // 16.0
    wire [10:0] v131; shift_adder #(11, 2, 0, 0, 11, 0, 0) op_131 (v130[10:0], 2'b10, v131[10:0]); // 16.0
    wire [4:0] v132; assign v132[4:0] = v131[6:2]; // 16.0
    wire [4:0] v133; assign v133[4:0] = model_inp[753:749]; // 15.0
    wire [14:0] v134; assign v134[14:0] = model_inp[768:754]; // 15.0
    wire [9:0] v135; assign v135[9:0] = model_inp[778:769]; // 15.0
    wire [13:0] v136; assign v136[13:0] = model_inp[792:779]; // 15.0
    wire [14:0] v137; assign v137[14:0] = model_inp[807:793]; // 15.0
    wire [11:0] v138; assign v138[11:0] = model_inp[819:808]; // 15.0
    wire [13:0] v139; assign v139[13:0] = model_inp[833:820]; // 15.0
    wire [12:0] v140; assign v140[12:0] = model_inp[846:834]; // 15.0
    wire [11:0] v141; assign v141[11:0] = model_inp[858:847]; // 15.0
    wire [13:0] v142; assign v142[13:0] = model_inp[872:859]; // 15.0
    wire [10:0] v143; assign v143[10:0] = model_inp[883:873]; // 15.0
    wire [2:0] v144; assign v144[2:0] = model_inp[886:884]; // 15.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[4:0] = v5[4:0];
    assign model_out[9:5] = v133[4:0];
    assign model_out[16:10] = v18[6:0];
    assign model_out[24:17] = v21[7:0];
    assign model_out[28:25] = v27[3:0];
    assign model_out[35:29] = v34[6:0];
    assign model_out[47:36] = v37[11:0];
    assign model_out[62:48] = v40[14:0];
    assign model_out[76:63] = v46[13:0];
    assign model_out[89:77] = v49[12:0];
    assign model_out[103:90] = v52[13:0];
    assign model_out[119:104] = v55[15:0];
    assign model_out[131:120] = v58[11:0];
    assign model_out[145:132] = v61[13:0];
    assign model_out[161:146] = v67[15:0];
    assign model_out[176:162] = v134[14:0];
    assign model_out[191:177] = v70[14:0];
    assign model_out[201:192] = v135[9:0];
    assign model_out[215:202] = v136[13:0];
    assign model_out[228:216] = v76[12:0];
    assign model_out[243:229] = v137[14:0];
    assign model_out[255:244] = v78[11:0];
    assign model_out[266:256] = v80[10:0];
    assign model_out[280:267] = v83[13:0];
    assign model_out[294:281] = v86[13:0];
    assign model_out[308:295] = v89[13:0];
    assign model_out[320:309] = v138[11:0];
    assign model_out[331:321] = v110[10:0];
    assign model_out[334:332] = v93[2:0];
    assign model_out[338:335] = v116[3:0];
    assign model_out[344:339] = v11[5:0];
    assign model_out[358:345] = v139[13:0];
    assign model_out[371:359] = v119[12:0];
    assign model_out[376:372] = v100[4:0];
    assign model_out[383:377] = v122[6:0];
    assign model_out[396:384] = v140[12:0];
    assign model_out[410:397] = v125[13:0];
    assign model_out[423:411] = v128[12:0];
    assign model_out[435:424] = v141[11:0];
    assign model_out[448:436] = v43[12:0];
    assign model_out[462:449] = v142[13:0];
    assign model_out[474:463] = v24[11:0];
    assign model_out[487:475] = v64[12:0];
    assign model_out[500:488] = v73[12:0];
    assign model_out[508:501] = v107[7:0];
    assign model_out[519:509] = v143[10:0];
    assign model_out[522:520] = v144[2:0];
    assign model_out[527:523] = v132[4:0];
    assign model_out[532:528] = v20[4:0];
    assign model_out[536:533] = v120[3:0];

endmodule
