`timescale 1 ns / 1 ps

module jsc_stage16 (
    input [536:0] model_inp,
    output [353:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [4:0] v0; assign v0[4:0] = model_inp[4:0]; // 16.0
    wire [4:0] v1; assign v1[4:0] = model_inp[9:5]; // 16.0
    wire [9:0] v2; shift_adder #(5, 5, 0, 0, 10, 4, 1) op_2 (v0[4:0], v1[4:0], v2[9:0]); // 17.0
    wire [6:0] v3; assign v3[6:0] = model_inp[16:10]; // 16.0
    wire [7:0] v4; assign v4[7:0] = model_inp[24:17]; // 16.0
    wire [9:0] v5; shift_adder #(7, 8, 0, 0, 10, 2, 0) op_5 (v3[6:0], v4[7:0], v5[9:0]); // 17.0
    wire [3:0] v6; assign v6[3:0] = model_inp[28:25]; // 16.0
    wire [6:0] v7; assign v7[6:0] = model_inp[35:29]; // 16.0
    wire [7:0] v8; shift_adder #(4, 7, 0, 0, 8, -1, 0) op_8 (v6[3:0], v7[6:0], v8[7:0]); // 17.0
    wire [11:0] v9; assign v9[11:0] = model_inp[47:36]; // 16.0
    wire [14:0] v10; assign v10[14:0] = model_inp[62:48]; // 16.0
    wire [14:0] v11; shift_adder #(12, 15, 1, 1, 15, -1, 0) op_11 (v9[11:0], v10[14:0], v11[14:0]); // 17.0
    wire [13:0] v12; assign v12[13:0] = model_inp[76:63]; // 16.0
    wire [12:0] v13; assign v13[12:0] = model_inp[89:77]; // 16.0
    wire [14:0] v14; shift_adder #(14, 13, 1, 1, 15, 1, 0) op_14 (v12[13:0], v13[12:0], v14[14:0]); // 17.0
    wire [14:0] v15; shift_adder #(15, 6, 1, 0, 15, 0, 1) op_15 (v14[14:0], 6'b100000, v15[14:0]); // 17.0
    wire [13:0] v16; assign v16[13:0] = v15[13:0] & {14{~v15[14]}}; // 17.0
    wire [13:0] v17; shift_adder #(14, 4, 0, 0, 14, 0, 0) op_17 (v16[13:0], 4'b1000, v17[13:0]); // 17.0
    wire [6:0] v18; assign v18[6:0] = v17[10:4]; // 17.0
    wire [13:0] v19; assign v19[13:0] = model_inp[103:90]; // 16.0
    wire [15:0] v20; assign v20[15:0] = model_inp[119:104]; // 16.0
    wire [15:0] v21; shift_adder #(14, 16, 1, 1, 16, 0, 0) op_21 (v19[13:0], v20[15:0], v21[15:0]); // 17.0
    wire [11:0] v22; assign v22[11:0] = model_inp[131:120]; // 16.0
    wire [13:0] v23; assign v23[13:0] = model_inp[145:132]; // 16.0
    wire [14:0] v24; shift_adder #(12, 14, 1, 1, 15, 0, 0) op_24 (v22[11:0], v23[13:0], v24[14:0]); // 17.0
    wire [15:0] v25; assign v25[15:0] = model_inp[161:146]; // 16.0
    wire [14:0] v26; assign v26[14:0] = model_inp[176:162]; // 16.0
    wire [15:0] v27; shift_adder #(16, 15, 1, 1, 16, 0, 1) op_27 (v25[15:0], v26[14:0], v27[15:0]); // 17.0
    wire [14:0] v28; assign v28[14:0] = model_inp[191:177]; // 16.0
    wire [9:0] v29; assign v29[9:0] = model_inp[201:192]; // 16.0
    wire [14:0] v30; shift_adder #(15, 10, 1, 1, 15, 1, 1) op_30 (v28[14:0], v29[9:0], v30[14:0]); // 17.0
    wire [14:0] v31; shift_adder #(15, 6, 1, 0, 15, 0, 0) op_31 (v30[14:0], 6'b100000, v31[14:0]); // 17.0
    wire [12:0] v32; assign v32[12:0] = v31[12:0] & {13{~v31[14]}}; // 17.0
    wire [12:0] v33; shift_adder #(13, 4, 0, 0, 13, 0, 0) op_33 (v32[12:0], 4'b1000, v33[12:0]); // 17.0
    wire [4:0] v34; assign v34[4:0] = v33[8:4]; // 17.0
    wire [13:0] v35; assign v35[13:0] = model_inp[215:202]; // 16.0
    wire [12:0] v36; assign v36[12:0] = model_inp[228:216]; // 16.0
    wire [13:0] v37; shift_adder #(14, 13, 1, 1, 14, 0, 0) op_37 (v35[13:0], v36[12:0], v37[13:0]); // 17.0
    wire [14:0] v38; assign v38[14:0] = model_inp[243:229]; // 16.0
    wire [11:0] v39; assign v39[11:0] = model_inp[255:244]; // 16.0
    wire [14:0] v40; shift_adder #(15, 12, 1, 1, 15, 0, 0) op_40 (v38[14:0], v39[11:0], v40[14:0]); // 17.0
    wire [14:0] v41; shift_adder #(15, 6, 1, 0, 15, 0, 0) op_41 (v40[14:0], 6'b100000, v41[14:0]); // 17.0
    wire [11:0] v42; assign v42[11:0] = v41[11:0] & {12{~v41[14]}}; // 17.0
    wire [11:0] v43; shift_adder #(12, 4, 0, 0, 12, 0, 0) op_43 (v42[11:0], 4'b1000, v43[11:0]); // 17.0
    wire [4:0] v44; assign v44[4:0] = v43[8:4]; // 17.0
    wire [10:0] v45; assign v45[10:0] = model_inp[266:256]; // 16.0
    wire [13:0] v46; assign v46[13:0] = model_inp[280:267]; // 16.0
    wire [14:0] v47; shift_adder #(11, 14, 1, 1, 15, -2, 0) op_47 (v45[10:0], v46[13:0], v47[14:0]); // 17.0
    wire [11:0] v48; assign v48[11:0] = v47[11:0] & {12{~v47[14]}}; // 17.0
    wire [11:0] v49; shift_adder #(12, 4, 0, 0, 12, 0, 0) op_49 (v48[11:0], 4'b1000, v49[11:0]); // 17.0
    wire [4:0] v50; assign v50[4:0] = v49[8:4]; // 17.0
    wire [13:0] v51; assign v51[13:0] = model_inp[294:281]; // 16.0
    wire [13:0] v52; assign v52[13:0] = model_inp[308:295]; // 16.0
    wire [14:0] v53; shift_adder #(14, 14, 1, 1, 15, 1, 0) op_53 (v51[13:0], v52[13:0], v53[14:0]); // 17.0
    wire [11:0] v54; assign v54[11:0] = model_inp[320:309]; // 16.0
    wire [10:0] v55; assign v55[10:0] = model_inp[331:321]; // 16.0
    wire [12:0] v56; shift_adder #(12, 11, 1, 1, 13, 1, 0) op_56 (v54[11:0], v55[10:0], v56[12:0]); // 17.0
    wire [12:0] v57; shift_adder #(13, 4, 1, 0, 13, 0, 0) op_57 (v56[12:0], 4'b1000, v57[12:0]); // 17.0
    wire [11:0] v58; assign v58[11:0] = v57[11:0] & {12{~v57[12]}}; // 17.0
    wire [11:0] v59; shift_adder #(12, 3, 0, 0, 12, 0, 0) op_59 (v58[11:0], 3'b100, v59[11:0]); // 17.0
    wire [5:0] v60; assign v60[5:0] = v59[8:3]; // 17.0
    wire [2:0] v61; assign v61[2:0] = model_inp[334:332]; // 16.0
    wire [3:0] v62; assign v62[3:0] = model_inp[338:335]; // 16.0
    wire [5:0] v63; shift_adder #(3, 4, 0, 0, 6, -2, 0) op_63 (v61[2:0], v62[3:0], v63[5:0]); // 17.0
    wire [5:0] v64; assign v64[5:0] = model_inp[344:339]; // 16.0
    wire [7:0] v65; shift_adder #(4, 6, 0, 0, 8, -3, 0) op_65 (v6[3:0], v64[5:0], v65[7:0]); // 17.0
    wire [13:0] v66; assign v66[13:0] = model_inp[358:345]; // 16.0
    wire [12:0] v67; assign v67[12:0] = model_inp[371:359]; // 16.0
    wire [14:0] v68; shift_adder #(14, 13, 1, 1, 15, -1, 0) op_68 (v66[13:0], v67[12:0], v68[14:0]); // 17.0
    wire [14:0] v69; shift_adder #(15, 6, 1, 0, 15, 0, 0) op_69 (v68[14:0], 6'b100000, v69[14:0]); // 17.0
    wire [11:0] v70; assign v70[11:0] = v69[11:0] & {12{~v69[14]}}; // 17.0
    wire [11:0] v71; shift_adder #(12, 4, 0, 0, 12, 0, 0) op_71 (v70[11:0], 4'b1000, v71[11:0]); // 17.0
    wire [4:0] v72; assign v72[4:0] = v71[8:4]; // 17.0
    wire [4:0] v73; assign v73[4:0] = model_inp[376:372]; // 16.0
    wire [6:0] v74; assign v74[6:0] = model_inp[383:377]; // 16.0
    wire [7:0] v75; shift_adder #(5, 7, 0, 1, 8, 0, 0) op_75 (v73[4:0], v74[6:0], v75[7:0]); // 17.0
    wire [12:0] v76; assign v76[12:0] = model_inp[396:384]; // 16.0
    wire [13:0] v77; assign v77[13:0] = model_inp[410:397]; // 16.0
    wire [13:0] v78; shift_adder #(13, 14, 1, 1, 14, 0, 0) op_78 (v76[12:0], v77[13:0], v78[13:0]); // 17.0
    wire [11:0] v79; assign v79[11:0] = v78[11:0] & {12{~v78[13]}}; // 17.0
    wire [11:0] v80; shift_adder #(12, 3, 0, 0, 12, 0, 0) op_80 (v79[11:0], 3'b100, v80[11:0]); // 17.0
    wire [6:0] v81; assign v81[6:0] = v80[9:3]; // 17.0
    wire [12:0] v82; assign v82[12:0] = model_inp[423:411]; // 16.0
    wire [11:0] v83; assign v83[11:0] = model_inp[435:424]; // 16.0
    wire [13:0] v84; shift_adder #(13, 12, 1, 1, 14, 0, 1) op_84 (v82[12:0], v83[11:0], v84[13:0]); // 17.0
    wire [7:0] v85; shift_adder #(6, 7, 0, 0, 8, 0, 1) op_85 (v64[5:0], v7[6:0], v85[7:0]); // 17.0
    wire [8:0] v86; shift_adder #(5, 4, 0, 0, 9, -3, 0) op_86 (v1[4:0], v6[3:0], v86[8:0]); // 17.0
    wire [12:0] v87; assign v87[12:0] = model_inp[448:436]; // 16.0
    wire [13:0] v88; assign v88[13:0] = model_inp[462:449]; // 16.0
    wire [11:0] v89; assign v89[11:0] = model_inp[474:463]; // 16.0
    wire [12:0] v90; assign v90[12:0] = model_inp[487:475]; // 16.0
    wire [12:0] v91; assign v91[12:0] = model_inp[500:488]; // 16.0
    wire [7:0] v92; assign v92[7:0] = model_inp[508:501]; // 16.0
    wire [10:0] v93; assign v93[10:0] = model_inp[519:509]; // 16.0
    wire [2:0] v94; assign v94[2:0] = model_inp[522:520]; // 16.0
    wire [4:0] v95; assign v95[4:0] = model_inp[527:523]; // 16.0
    wire [4:0] v96; assign v96[4:0] = model_inp[532:528]; // 16.0
    wire [3:0] v97; assign v97[3:0] = model_inp[536:533]; // 16.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[9:0] = v2[9:0];
    assign model_out[15:10] = v64[5:0];
    assign model_out[25:16] = v5[9:0];
    assign model_out[33:26] = v8[7:0];
    assign model_out[48:34] = v11[14:0];
    assign model_out[61:49] = v87[12:0];
    assign model_out[75:62] = v88[13:0];
    assign model_out[91:76] = v21[15:0];
    assign model_out[103:92] = v89[11:0];
    assign model_out[118:104] = v24[14:0];
    assign model_out[131:119] = v90[12:0];
    assign model_out[147:132] = v27[15:0];
    assign model_out[152:148] = v34[4:0];
    assign model_out[165:153] = v91[12:0];
    assign model_out[179:166] = v37[13:0];
    assign model_out[184:180] = v44[4:0];
    assign model_out[189:185] = v50[4:0];
    assign model_out[204:190] = v53[14:0];
    assign model_out[212:205] = v92[7:0];
    assign model_out[218:213] = v60[5:0];
    assign model_out[224:219] = v63[5:0];
    assign model_out[232:225] = v65[7:0];
    assign model_out[237:233] = v72[4:0];
    assign model_out[245:238] = v75[7:0];
    assign model_out[249:246] = v6[3:0];
    assign model_out[256:250] = v18[6:0];
    assign model_out[270:257] = v84[13:0];
    assign model_out[281:271] = v93[10:0];
    assign model_out[288:282] = v81[6:0];
    assign model_out[296:289] = v85[7:0];
    assign model_out[300:297] = v62[3:0];
    assign model_out[303:301] = v94[2:0];
    assign model_out[308:304] = v73[4:0];
    assign model_out[317:309] = v86[8:0];
    assign model_out[324:318] = v7[6:0];
    assign model_out[329:325] = v95[4:0];
    assign model_out[334:330] = v0[4:0];
    assign model_out[339:335] = v96[4:0];
    assign model_out[346:340] = v3[6:0];
    assign model_out[349:347] = v61[2:0];
    assign model_out[353:350] = v97[3:0];

endmodule
