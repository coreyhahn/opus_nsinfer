`timescale 1 ns / 1 ps

module x310_clf_stage11 (
    input [220:0] model_inp,
    output [221:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [11:0] v0; assign v0[11:0] = model_inp[11:0]; // 27.5
    wire [6:0] v1; assign v1[6:0] = model_inp[18:12]; // 27.5
    wire [11:0] v2; shift_adder #(12, 7, 1, 0, 12, 2, 1) op_2 (v0[11:0], v1[6:0], v2[11:0]); // 28.0
    wire [4:0] v3; assign v3[4:0] = model_inp[23:19]; // 27.5
    wire [5:0] v4; assign v4[5:0] = model_inp[29:24]; // 27.5
    wire [6:0] v5; shift_adder #(5, 6, 0, 0, 7, 0, 1) op_5 (v3[4:0], v4[5:0], v5[6:0]); // 28.0
    wire [5:0] v6; assign v6[5:0] = model_inp[35:30]; // 27.5
    wire [5:0] v7; assign v7[5:0] = model_inp[41:36]; // 27.5
    wire [7:0] v8; shift_adder #(6, 6, 0, 0, 8, -1, 1) op_8 (v6[5:0], v7[5:0], v8[7:0]); // 28.0
    wire [5:0] v9; assign v9[5:0] = model_inp[47:42]; // 27.5
    wire [6:0] v10; assign v10[6:0] = model_inp[54:48]; // 27.5
    wire [8:0] v11; shift_adder #(6, 7, 0, 0, 9, -2, 0) op_11 (v9[5:0], v10[6:0], v11[8:0]); // 28.0
    wire [4:0] v12; assign v12[4:0] = model_inp[59:55]; // 27.5
    wire [8:0] v13; assign v13[8:0] = model_inp[68:60]; // 27.5
    wire [9:0] v14; shift_adder #(5, 9, 0, 1, 10, -3, 0) op_14 (v12[4:0], v13[8:0], v14[9:0]); // 28.0
    wire [12:0] v15; assign v15[12:0] = model_inp[81:69]; // 27.5
    wire [11:0] v16; assign v16[11:0] = model_inp[93:82]; // 27.5
    wire [13:0] v17; shift_adder #(13, 12, 1, 1, 14, -1, 0) op_17 (v15[12:0], v16[11:0], v17[13:0]); // 28.0
    wire [13:0] v18; shift_adder #(14, 4, 1, 0, 14, 0, 0) op_18 (v17[13:0], 4'b1000, v18[13:0]); // 28.0
    wire [12:0] v19; assign v19[12:0] = v18[12:0] & {13{~v18[13]}}; // 28.0
    wire [12:0] v20; shift_adder #(13, 4, 0, 0, 13, 0, 0) op_20 (v19[12:0], 4'b1000, v20[12:0]); // 28.0
    wire [6:0] v21; assign v21[6:0] = v20[10:4]; // 28.0
    wire [10:0] v22; assign v22[10:0] = model_inp[104:94]; // 27.5
    wire [13:0] v23; shift_adder #(11, 12, 1, 1, 14, -2, 0) op_23 (v22[10:0], v16[11:0], v23[13:0]); // 28.0
    wire [13:0] v24; shift_adder #(14, 5, 1, 0, 14, 0, 0) op_24 (v23[13:0], 5'b10000, v24[13:0]); // 28.0
    wire [11:0] v25; assign v25[11:0] = v24[11:0] & {12{~v24[13]}}; // 28.0
    wire [11:0] v26; shift_adder #(12, 6, 0, 0, 12, 0, 0) op_26 (v25[11:0], 6'b100000, v26[11:0]); // 28.0
    wire [3:0] v27; assign v27[3:0] = v26[9:6]; // 28.0
    wire [6:0] v28; assign v28[6:0] = model_inp[111:105]; // 27.5
    wire [8:0] v29; shift_adder #(7, 7, 0, 0, 9, -1, 1) op_29 (v1[6:0], v28[6:0], v29[8:0]); // 28.0
    wire [3:0] v30; assign v30[3:0] = model_inp[115:112]; // 27.5
    wire [8:0] v31; assign v31[8:0] = model_inp[124:116]; // 27.5
    wire [9:0] v32; shift_adder #(4, 9, 0, 0, 10, -4, 0) op_32 (v30[3:0], v31[8:0], v32[9:0]); // 28.0
    wire [6:0] v33; assign v33[6:0] = model_inp[131:125]; // 27.5
    wire [10:0] v34; shift_adder #(7, 6, 1, 0, 11, -3, 1) op_34 (v33[6:0], v4[5:0], v34[10:0]); // 28.0
    wire [6:0] v35; shift_adder #(6, 6, 0, 0, 7, 0, 1) op_35 (v6[5:0], v7[5:0], v35[6:0]); // 28.0
    wire [6:0] v36; assign v36[6:0] = model_inp[138:132]; // 27.5
    wire [10:0] v37; shift_adder #(7, 7, 0, 0, 11, 3, 0) op_37 (v36[6:0], v10[6:0], v37[10:0]); // 28.0
    wire [14:0] v38; assign v38[14:0] = model_inp[153:139]; // 27.5
    wire [14:0] v39; shift_adder #(15, 5, 1, 0, 15, 4, 1) op_39 (v38[14:0], v3[4:0], v39[14:0]); // 28.0
    wire [5:0] v40; assign v40[5:0] = model_inp[159:154]; // 27.5
    wire [8:0] v41; shift_adder #(7, 6, 0, 0, 9, 2, 1) op_41 (v1[6:0], v40[5:0], v41[8:0]); // 28.0
    wire [9:0] v42; shift_adder #(6, 9, 0, 1, 10, -2, 1) op_42 (v6[5:0], v13[8:0], v42[9:0]); // 28.0
    wire [10:0] v43; assign v43[10:0] = model_inp[170:160]; // 27.5
    wire [5:0] v44; assign v44[5:0] = model_inp[176:171]; // 27.5
    wire [11:0] v45; shift_adder #(11, 6, 1, 0, 12, -1, 1) op_45 (v43[10:0], v44[5:0], v45[11:0]); // 28.0
    wire [10:0] v46; assign v46[10:0] = model_inp[187:177]; // 27.5
    wire [10:0] v47; shift_adder #(4, 11, 0, 1, 11, -4, 0) op_47 (v30[3:0], v46[10:0], v47[10:0]); // 28.0
    wire [12:0] v48; shift_adder #(12, 7, 1, 1, 13, 4, 0) op_48 (v2[11:0], v5[6:0], v48[12:0]); // 29.0
    wire [5:0] v49; assign v49[5:0] = model_inp[193:188]; // 27.5
    wire [9:0] v50; shift_adder #(6, 8, 0, 1, 10, 1, 0) op_50 (v49[5:0], v8[7:0], v50[9:0]); // 29.0
    wire [10:0] v51; shift_adder #(9, 10, 0, 1, 11, 1, 0) op_51 (v11[8:0], v14[9:0], v51[10:0]); // 29.0
    wire [7:0] v52; shift_adder #(5, 7, 0, 0, 8, -1, 1) op_52 (v3[4:0], v21[6:0], v52[7:0]); // 29.0
    wire [6:0] v53; shift_adder #(6, 4, 0, 0, 7, 2, 1) op_53 (v9[5:0], v27[3:0], v53[6:0]); // 29.0
    wire [6:0] v54; assign v54[6:0] = model_inp[200:194]; // 27.5
    wire [8:0] v55; shift_adder #(7, 7, 0, 0, 9, -1, 1) op_55 (v21[6:0], v54[6:0], v55[8:0]); // 29.0
    wire [10:0] v56; shift_adder #(9, 8, 1, 1, 11, -1, 0) op_56 (v29[8:0], v8[7:0], v56[10:0]); // 29.0
    wire [9:0] v57; shift_adder #(10, 4, 0, 0, 10, 4, 0) op_57 (v32[9:0], v27[3:0], v57[9:0]); // 29.0
    wire [12:0] v58; shift_adder #(11, 10, 1, 1, 13, 3, 0) op_58 (v34[10:0], v14[9:0], v58[12:0]); // 29.0
    wire [8:0] v59; shift_adder #(7, 7, 0, 1, 9, 0, 0) op_59 (v28[6:0], v35[6:0], v59[8:0]); // 29.0
    wire [14:0] v60; shift_adder #(11, 15, 0, 1, 15, -2, 0) op_60 (v37[10:0], v39[14:0], v60[14:0]); // 29.0
    wire [10:0] v61; shift_adder #(9, 9, 0, 1, 11, -1, 1) op_61 (v11[8:0], v29[8:0], v61[10:0]); // 29.0
    wire [9:0] v62; shift_adder #(9, 7, 1, 0, 10, 1, 0) op_62 (v41[8:0], v21[6:0], v62[9:0]); // 29.0
    wire [10:0] v63; shift_adder #(11, 4, 0, 0, 11, 4, 0) op_63 (v37[10:0], v27[3:0], v63[10:0]); // 29.0
    wire [12:0] v64; shift_adder #(10, 12, 1, 1, 13, -2, 0) op_64 (v42[9:0], v45[11:0], v64[12:0]); // 29.0
    wire [10:0] v65; shift_adder #(9, 7, 1, 1, 11, -1, 1) op_65 (v29[8:0], v35[6:0], v65[10:0]); // 29.0
    wire [12:0] v66; shift_adder #(11, 9, 1, 0, 13, 2, 0) op_66 (v47[10:0], v11[8:0], v66[12:0]); // 29.0
    wire [8:0] v67; shift_adder #(6, 9, 0, 1, 9, -1, 0) op_67 (v44[5:0], v41[8:0], v67[8:0]); // 29.0
    wire [12:0] v68; shift_adder #(13, 10, 1, 1, 13, 1, 1) op_68 (v48[12:0], v50[9:0], v68[12:0]); // 30.0
    wire [11:0] v69; shift_adder #(8, 11, 1, 1, 12, -3, 0) op_69 (v8[7:0], v51[10:0], v69[11:0]); // 30.0
    wire [9:0] v70; shift_adder #(7, 8, 0, 1, 10, -1, 0) op_70 (v54[6:0], v52[7:0], v70[9:0]); // 30.0
    wire [8:0] v71; shift_adder #(4, 7, 0, 1, 9, 1, 0) op_71 (v27[3:0], v53[6:0], v71[8:0]); // 30.0
    wire [9:0] v72; shift_adder #(4, 9, 0, 1, 10, -3, 0) op_72 (v30[3:0], v55[8:0], v72[9:0]); // 30.0
    wire [13:0] v73; shift_adder #(7, 10, 1, 0, 14, -6, 0) op_73 (v53[6:0], v57[9:0], v73[13:0]); // 30.0
    wire [13:0] v74; shift_adder #(13, 9, 1, 1, 14, 4, 0) op_74 (v58[12:0], v59[8:0], v74[13:0]); // 30.0
    wire [14:0] v75; shift_adder #(15, 9, 1, 1, 15, 0, 1) op_75 (v60[14:0], v55[8:0], v75[14:0]); // 30.0
    wire [10:0] v76; shift_adder #(5, 11, 0, 1, 11, -1, 0) op_76 (v3[4:0], v61[10:0], v76[10:0]); // 30.0
    wire [11:0] v77; shift_adder #(10, 11, 1, 1, 12, 0, 0) op_77 (v62[9:0], v51[10:0], v77[11:0]); // 30.0
    wire [13:0] v78; shift_adder #(13, 11, 1, 1, 14, 1, 0) op_78 (v64[12:0], v65[10:0], v78[13:0]); // 30.0
    wire [13:0] v79; shift_adder #(10, 13, 0, 1, 14, -2, 0) op_79 (v32[9:0], v66[12:0], v79[13:0]); // 30.0
    wire [12:0] v80; shift_adder #(10, 8, 1, 1, 13, -3, 1) op_80 (v50[9:0], v52[7:0], v80[12:0]); // 30.0
    wire [5:0] v81; assign v81[5:0] = model_inp[206:201]; // 27.5
    wire [9:0] v82; shift_adder #(6, 9, 0, 1, 10, -2, 1) op_82 (v81[5:0], v67[8:0], v82[9:0]); // 30.0
    wire [4:0] v83; assign v83[4:0] = model_inp[211:207]; // 27.5
    wire [4:0] v84; assign v84[4:0] = model_inp[216:212]; // 27.5
    wire [3:0] v85; assign v85[3:0] = model_inp[220:217]; // 27.5

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[12:0] = v68[12:0];
    assign model_out[24:13] = v69[11:0];
    assign model_out[30:25] = v49[5:0];
    assign model_out[40:31] = v70[9:0];
    assign model_out[50:41] = v72[9:0];
    assign model_out[61:51] = v56[10:0];
    assign model_out[75:62] = v74[13:0];
    assign model_out[90:76] = v75[14:0];
    assign model_out[95:91] = v83[4:0];
    assign model_out[106:96] = v76[10:0];
    assign model_out[118:107] = v77[11:0];
    assign model_out[129:119] = v63[10:0];
    assign model_out[143:130] = v78[13:0];
    assign model_out[157:144] = v79[13:0];
    assign model_out[166:158] = v59[8:0];
    assign model_out[179:167] = v80[12:0];
    assign model_out[188:180] = v71[8:0];
    assign model_out[193:189] = v84[4:0];
    assign model_out[203:194] = v82[9:0];
    assign model_out[217:204] = v73[13:0];
    assign model_out[221:218] = v85[3:0];

endmodule
