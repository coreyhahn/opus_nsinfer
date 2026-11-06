`timescale 1 ns / 1 ps

module qec_d3_stage9 (
    input [337:0] model_inp,
    output [255:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [6:0] v0; assign v0[6:0] = model_inp[6:0]; // 18.0
    wire [4:0] v1; assign v1[4:0] = model_inp[11:7]; // 18.0
    wire [7:0] v2; shift_adder #(7, 5, 0, 0, 8, 1, 0) op_2 (v0[6:0], v1[4:0], v2[7:0]); // 19.0
    wire [6:0] v3; assign v3[6:0] = model_inp[18:12]; // 18.0
    wire [6:0] v4; assign v4[6:0] = model_inp[25:19]; // 18.0
    wire [9:0] v5; shift_adder #(7, 7, 0, 0, 10, -2, 1) op_5 (v3[6:0], v4[6:0], v5[9:0]); // 19.0
    wire [7:0] v6; assign v6[7:0] = model_inp[33:26]; // 18.0
    wire [8:0] v7; shift_adder #(8, 7, 0, 0, 9, 0, 0) op_7 (v6[7:0], v3[6:0], v7[8:0]); // 19.0
    wire [6:0] v8; assign v8[6:0] = model_inp[40:34]; // 18.0
    wire [6:0] v9; assign v9[6:0] = model_inp[47:41]; // 18.0
    wire [7:0] v10; shift_adder #(7, 7, 1, 0, 8, -1, 1) op_10 (v8[6:0], v9[6:0], v10[7:0]); // 19.0
    wire [12:0] v11; assign v11[12:0] = model_inp[60:48]; // 18.0
    wire [12:0] v12; shift_adder #(13, 7, 1, 0, 13, 0, 1) op_12 (v11[12:0], v0[6:0], v12[12:0]); // 19.0
    wire [10:0] v13; assign v13[10:0] = model_inp[71:61]; // 18.0
    wire [11:0] v14; shift_adder #(11, 8, 1, 0, 12, 2, 0) op_14 (v13[10:0], v6[7:0], v14[11:0]); // 19.0
    wire [11:0] v14_neg; negative #(12, 12, 1) op_neg_14 (v14, v14_neg);
    wire [5:0] v15; assign v15[5:0] = v14_neg[5:0] & {6{~v14_neg[11]}}; // 19.0
    wire [5:0] v16; shift_adder #(6, 3, 0, 0, 6, 0, 0) op_16 (v15[5:0], 3'b100, v16[5:0]); // 19.0
    wire [2:0] v17; assign v17[2:0] = v16[5:3]; // 19.0
    wire [9:0] v18; shift_adder #(7, 8, 0, 0, 10, -2, 1) op_18 (v0[6:0], v6[7:0], v18[9:0]); // 19.0
    wire [7:0] v19; assign v19[7:0] = model_inp[79:72]; // 18.0
    wire [8:0] v20; assign v20[8:0] = model_inp[88:80]; // 18.0
    wire [9:0] v21; shift_adder #(8, 9, 1, 1, 10, 1, 0) op_21 (v19[7:0], v20[8:0], v21[9:0]); // 19.0
    wire [8:0] v22; assign v22[8:0] = model_inp[97:89]; // 18.0
    wire [9:0] v23; shift_adder #(7, 9, 1, 1, 10, -2, 0) op_23 (v8[6:0], v22[8:0], v23[9:0]); // 19.0
    wire [10:0] v24; assign v24[10:0] = model_inp[108:98]; // 18.0
    wire [9:0] v25; assign v25[9:0] = model_inp[118:109]; // 18.0
    wire [10:0] v26; shift_adder #(11, 10, 1, 1, 11, 0, 0) op_26 (v24[10:0], v25[9:0], v26[10:0]); // 19.0
    wire [6:0] v27; assign v27[6:0] = model_inp[125:119]; // 18.0
    wire [4:0] v28; assign v28[4:0] = model_inp[130:126]; // 18.0
    wire [7:0] v29; shift_adder #(7, 5, 0, 1, 8, 0, 0) op_29 (v27[6:0], v28[4:0], v29[7:0]); // 19.0
    wire [14:0] v30; assign v30[14:0] = model_inp[145:131]; // 18.0
    wire [7:0] v31; assign v31[7:0] = model_inp[153:146]; // 18.0
    wire [15:0] v32; shift_adder #(15, 8, 0, 1, 16, 2, 0) op_32 (v30[14:0], v31[7:0], v32[15:0]); // 19.0
    wire [10:0] v33; assign v33[10:0] = model_inp[164:154]; // 18.0
    wire [10:0] v34; assign v34[10:0] = model_inp[175:165]; // 18.0
    wire [11:0] v35; shift_adder #(11, 11, 1, 1, 12, 1, 0) op_35 (v33[10:0], v34[10:0], v35[11:0]); // 19.0
    wire [4:0] v36; assign v36[4:0] = model_inp[180:176]; // 18.0
    wire [7:0] v37; shift_adder #(7, 5, 0, 0, 8, 0, 1) op_37 (v0[6:0], v36[4:0], v37[7:0]); // 19.0
    wire [3:0] v38; assign v38[3:0] = model_inp[184:181]; // 18.0
    wire [7:0] v39; assign v39[7:0] = model_inp[192:185]; // 18.0
    wire [8:0] v40; shift_adder #(4, 8, 0, 1, 9, 1, 1) op_40 (v38[3:0], v39[7:0], v40[8:0]); // 19.0
    wire [13:0] v41; assign v41[13:0] = model_inp[206:193]; // 18.0
    wire [13:0] v42; shift_adder #(14, 8, 1, 1, 14, 1, 1) op_42 (v41[13:0], v19[7:0], v42[13:0]); // 19.0
    wire [10:0] v43; shift_adder #(8, 8, 1, 0, 11, 1, 1) op_43 (v31[7:0], v6[7:0], v43[10:0]); // 19.0
    wire [10:0] v44; assign v44[10:0] = model_inp[217:207]; // 18.0
    wire [10:0] v45; assign v45[10:0] = model_inp[228:218]; // 18.0
    wire [12:0] v46; shift_adder #(11, 11, 1, 1, 13, 1, 0) op_46 (v44[10:0], v45[10:0], v46[12:0]); // 19.0
    wire [5:0] v47; assign v47[5:0] = model_inp[234:229]; // 18.0
    wire [8:0] v48; assign v48[8:0] = model_inp[243:235]; // 18.0
    wire [9:0] v49; shift_adder #(6, 9, 0, 0, 10, 0, 1) op_49 (v47[5:0], v48[8:0], v49[9:0]); // 19.0
    wire [4:0] v50; assign v50[4:0] = model_inp[248:244]; // 18.0
    wire [8:0] v51; assign v51[8:0] = model_inp[257:249]; // 18.0
    wire [9:0] v52; shift_adder #(5, 9, 0, 1, 10, -3, 0) op_52 (v50[4:0], v51[8:0], v52[9:0]); // 19.0
    wire [9:0] v53; assign v53[9:0] = model_inp[267:258]; // 18.0
    wire [8:0] v54; assign v54[8:0] = model_inp[276:268]; // 18.0
    wire [10:0] v55; shift_adder #(10, 9, 1, 0, 11, 0, 1) op_55 (v53[9:0], v54[8:0], v55[10:0]); // 19.0
    wire [10:0] v56; assign v56[10:0] = model_inp[287:277]; // 18.0
    wire [11:0] v57; shift_adder #(11, 9, 1, 1, 12, 1, 1) op_57 (v56[10:0], v20[8:0], v57[11:0]); // 19.0
    wire [10:0] v58; shift_adder #(9, 9, 1, 0, 11, 1, 1) op_58 (v22[8:0], v54[8:0], v58[10:0]); // 19.0
    wire [4:0] v59; assign v59[4:0] = model_inp[292:288]; // 18.0
    wire [7:0] v60; shift_adder #(5, 8, 0, 0, 8, 0, 0) op_60 (v59[4:0], v2[7:0], v60[7:0]); // 20.0
    wire [10:0] v61; shift_adder #(10, 9, 1, 0, 11, -1, 1) op_61 (v5[9:0], v7[8:0], v61[10:0]); // 20.0
    wire [12:0] v62; shift_adder #(8, 13, 1, 1, 13, -2, 0) op_62 (v10[7:0], v12[12:0], v62[12:0]); // 20.0
    wire [4:0] v63; assign v63[4:0] = model_inp[297:293]; // 18.0
    wire [9:0] v64; shift_adder #(5, 10, 0, 1, 10, -1, 1) op_64 (v63[4:0], v18[9:0], v64[9:0]); // 20.0
    wire [9:0] v65; shift_adder #(4, 10, 0, 1, 10, -1, 1) op_65 (v38[3:0], v5[9:0], v65[9:0]); // 20.0
    wire [11:0] v66; shift_adder #(10, 10, 1, 1, 12, 1, 0) op_66 (v21[9:0], v23[9:0], v66[11:0]); // 20.0
    wire [10:0] v67; shift_adder #(11, 8, 1, 1, 11, 2, 1) op_67 (v26[10:0], v29[7:0], v67[10:0]); // 20.0
    wire [11:0] v68; shift_adder #(8, 12, 1, 1, 12, -1, 0) op_68 (v29[7:0], v35[11:0], v68[11:0]); // 20.0
    wire [5:0] v69; assign v69[5:0] = model_inp[303:298]; // 18.0
    wire [12:0] v70; shift_adder #(6, 8, 0, 1, 13, 4, 0) op_70 (v69[5:0], v37[7:0], v70[12:0]); // 20.0
    wire [12:0] v71; shift_adder #(9, 8, 0, 1, 13, -3, 0) op_71 (v7[8:0], v37[7:0], v71[12:0]); // 20.0
    wire [1:0] v72; assign v72[1:0] = model_inp[305:304]; // 18.0
    wire [8:0] v73; shift_adder #(2, 9, 0, 1, 9, -1, 0) op_73 (v72[1:0], v40[8:0], v73[8:0]); // 20.0
    wire [14:0] v74; shift_adder #(14, 11, 1, 1, 15, 3, 0) op_74 (v42[13:0], v43[10:0], v74[14:0]); // 20.0
    wire [14:0] v75; shift_adder #(15, 5, 1, 0, 15, 0, 1) op_75 (v74[14:0], 5'b10000, v75[14:0]); // 20.0
    wire [10:0] v76; assign v76[10:0] = v75[10:0] & {11{~v75[14]}}; // 20.0
    wire [10:0] v77; shift_adder #(11, 5, 0, 0, 11, 0, 0) op_77 (v76[10:0], 5'b10000, v77[10:0]); // 20.0
    wire [3:0] v78; assign v78[3:0] = v77[8:5]; // 20.0
    wire [13:0] v79; shift_adder #(13, 9, 1, 0, 14, 3, 1) op_79 (v46[12:0], v48[8:0], v79[13:0]); // 20.0
    wire [4:0] v80; assign v80[4:0] = model_inp[310:306]; // 18.0
    wire [9:0] v81; shift_adder #(5, 10, 0, 1, 10, -2, 0) op_81 (v80[4:0], v52[9:0], v81[9:0]); // 20.0
    wire [12:0] v82; shift_adder #(7, 10, 0, 1, 13, -4, 1) op_82 (v3[6:0], v5[9:0], v82[12:0]); // 20.0
    wire [9:0] v83; assign v83[9:0] = model_inp[320:311]; // 18.0
    wire [11:0] v84; shift_adder #(11, 10, 1, 1, 12, 0, 1) op_84 (v55[10:0], v83[9:0], v84[11:0]); // 20.0
    wire [12:0] v85; shift_adder #(6, 10, 0, 1, 13, -5, 1) op_85 (v69[5:0], v18[9:0], v85[12:0]); // 20.0
    wire [12:0] v86; shift_adder #(12, 11, 1, 1, 13, 1, 0) op_86 (v57[11:0], v58[10:0], v86[12:0]); // 20.0
    wire [2:0] v87; assign v87[2:0] = model_inp[323:321]; // 18.0
    wire [3:0] v88; assign v88[3:0] = model_inp[327:324]; // 18.0
    wire [3:0] v89; assign v89[3:0] = model_inp[331:328]; // 18.0
    wire [1:0] v90; assign v90[1:0] = model_inp[333:332]; // 18.0
    wire [1:0] v91; assign v91[1:0] = model_inp[335:334]; // 18.0
    wire [1:0] v92; assign v92[1:0] = model_inp[337:336]; // 18.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[10:0] = v61[10:0];
    assign model_out[23:11] = v62[12:0];
    assign model_out[33:24] = v64[9:0];
    assign model_out[43:34] = v65[9:0];
    assign model_out[55:44] = v66[11:0];
    assign model_out[66:56] = v67[10:0];
    assign model_out[82:67] = v32[15:0];
    assign model_out[94:83] = v68[11:0];
    assign model_out[107:95] = v70[12:0];
    assign model_out[116:108] = v73[8:0];
    assign model_out[130:117] = v79[13:0];
    assign model_out[140:131] = v49[9:0];
    assign model_out[143:141] = v87[2:0];
    assign model_out[153:144] = v81[9:0];
    assign model_out[162:154] = v54[8:0];
    assign model_out[175:163] = v82[12:0];
    assign model_out[187:176] = v84[11:0];
    assign model_out[191:188] = v88[3:0];
    assign model_out[204:192] = v85[12:0];
    assign model_out[217:205] = v86[12:0];
    assign model_out[225:218] = v60[7:0];
    assign model_out[238:226] = v71[12:0];
    assign model_out[242:239] = v89[3:0];
    assign model_out[244:243] = v90[1:0];
    assign model_out[247:245] = v17[2:0];
    assign model_out[249:248] = v91[1:0];
    assign model_out[251:250] = v92[1:0];
    assign model_out[255:252] = v78[3:0];

endmodule
