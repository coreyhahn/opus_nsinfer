`timescale 1 ns / 1 ps

module x310_clf_stage12 (
    input [309:0] model_inp,
    output [256:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [11:0] v0; assign v0[11:0] = model_inp[11:0]; // 24.0
    wire [7:0] v1; assign v1[7:0] = model_inp[19:12]; // 24.0
    wire [11:0] v2; shift_adder #(12, 8, 1, 0, 12, 0, 0) op_2 (v0[11:0], v1[7:0], v2[11:0]); // 25.0
    wire [11:0] v3; shift_adder #(12, 3, 1, 0, 12, 0, 1) op_3 (v2[11:0], 3'b100, v3[11:0]); // 25.0
    wire [9:0] v4; assign v4[9:0] = v3[9:0] & {10{~v3[11]}}; // 25.0
    wire [9:0] v5; shift_adder #(10, 2, 0, 0, 10, 0, 0) op_5 (v4[9:0], 2'b10, v5[9:0]); // 25.0
    wire [5:0] v6; assign v6[5:0] = v5[7:2]; // 25.0
    wire [4:0] v7; assign v7[4:0] = model_inp[24:20]; // 24.0
    wire [6:0] v8; assign v8[6:0] = model_inp[31:25]; // 24.0
    wire [7:0] v9; shift_adder #(5, 7, 0, 0, 8, -2, 0) op_9 (v7[4:0], v8[6:0], v9[7:0]); // 25.0
    wire [13:0] v10; assign v10[13:0] = model_inp[45:32]; // 24.0
    wire [7:0] v11; assign v11[7:0] = model_inp[53:46]; // 24.0
    wire [15:0] v12; shift_adder #(14, 8, 1, 1, 16, -2, 0) op_12 (v10[13:0], v11[7:0], v12[15:0]); // 25.0
    wire [6:0] v13; assign v13[6:0] = model_inp[60:54]; // 24.0
    wire [11:0] v14; shift_adder #(7, 8, 0, 1, 12, -3, 1) op_14 (v13[6:0], v11[7:0], v14[11:0]); // 25.0
    wire [8:0] v15; assign v15[8:0] = model_inp[69:61]; // 24.0
    wire [8:0] v16; assign v16[8:0] = model_inp[78:70]; // 24.0
    wire [11:0] v17; shift_adder #(9, 9, 1, 1, 12, -3, 1) op_17 (v15[8:0], v16[8:0], v17[11:0]); // 25.0
    wire [10:0] v18; assign v18[10:0] = model_inp[89:79]; // 24.0
    wire [11:0] v19; shift_adder #(11, 9, 1, 1, 12, 0, 1) op_19 (v18[10:0], v16[8:0], v19[11:0]); // 25.0
    wire [11:0] v20; assign v20[11:0] = model_inp[101:90]; // 24.0
    wire [11:0] v21; shift_adder #(8, 12, 0, 1, 12, 0, 0) op_21 (v1[7:0], v20[11:0], v21[11:0]); // 25.0
    wire [11:0] v22; shift_adder #(12, 4, 1, 0, 12, 0, 1) op_22 (v21[11:0], 4'b1010, v22[11:0]); // 25.0
    wire [10:0] v23; assign v23[10:0] = v22[10:0] & {11{~v22[11]}}; // 25.0
    wire [10:0] v24; shift_adder #(11, 3, 0, 0, 11, 0, 0) op_24 (v23[10:0], 3'b100, v24[10:0]); // 25.0
    wire [5:0] v25; assign v25[5:0] = v24[8:3]; // 25.0
    wire [7:0] v26; assign v26[7:0] = model_inp[109:102]; // 24.0
    wire [8:0] v27; assign v27[8:0] = model_inp[118:110]; // 24.0
    wire [9:0] v28; shift_adder #(8, 9, 0, 1, 10, -1, 1) op_28 (v26[7:0], v27[8:0], v28[9:0]); // 25.0
    wire [11:0] v29; shift_adder #(9, 9, 1, 1, 12, -2, 1) op_29 (v16[8:0], v16[8:0], v29[11:0]); // 25.0
    wire [11:0] v30; assign v30[11:0] = model_inp[130:119]; // 24.0
    wire [12:0] v31; shift_adder #(12, 8, 1, 0, 13, -1, 1) op_31 (v30[11:0], v1[7:0], v31[12:0]); // 25.0
    wire [11:0] v32; assign v32[11:0] = model_inp[142:131]; // 24.0
    wire [12:0] v33; shift_adder #(12, 9, 1, 1, 13, 1, 1) op_33 (v32[11:0], v27[8:0], v33[12:0]); // 25.0
    wire [12:0] v34; shift_adder #(13, 4, 1, 0, 13, 0, 1) op_34 (v33[12:0], 4'b1000, v34[12:0]); // 25.0
    wire [9:0] v35; assign v35[9:0] = v34[9:0] & {10{~v34[12]}}; // 25.0
    wire [9:0] v36; shift_adder #(10, 4, 0, 0, 10, 0, 0) op_36 (v35[9:0], 4'b1000, v36[9:0]); // 25.0
    wire [3:0] v37; assign v37[3:0] = v36[7:4]; // 25.0
    wire [9:0] v38; assign v38[9:0] = model_inp[152:143]; // 24.0
    wire [4:0] v39; assign v39[4:0] = model_inp[157:153]; // 24.0
    wire [9:0] v40; shift_adder #(10, 5, 1, 0, 10, 0, 1) op_40 (v38[9:0], v39[4:0], v40[9:0]); // 25.0
    wire [10:0] v41; assign v41[10:0] = model_inp[168:158]; // 24.0
    wire [12:0] v42; shift_adder #(11, 8, 1, 1, 13, -1, 1) op_42 (v41[10:0], v11[7:0], v42[12:0]); // 25.0
    wire [12:0] v43; shift_adder #(13, 5, 1, 0, 13, 0, 1) op_43 (v42[12:0], 5'b10000, v43[12:0]); // 25.0
    wire [10:0] v44; assign v44[10:0] = v43[10:0] & {11{~v43[12]}}; // 25.0
    wire [10:0] v45; shift_adder #(11, 4, 0, 0, 11, 0, 0) op_45 (v44[10:0], 4'b1000, v45[10:0]); // 25.0
    wire [3:0] v46; assign v46[3:0] = v45[7:4]; // 25.0
    wire [5:0] v47; shift_adder #(5, 5, 0, 0, 6, 0, 1) op_47 (v39[4:0], v7[4:0], v47[5:0]); // 25.0
    wire [9:0] v48; shift_adder #(6, 8, 0, 0, 10, -3, 1) op_48 (v6[5:0], v9[7:0], v48[9:0]); // 26.0
    wire [7:0] v49; assign v49[7:0] = model_inp[176:169]; // 24.0
    wire [15:0] v50; shift_adder #(8, 16, 0, 1, 16, -4, 0) op_50 (v49[7:0], v12[15:0], v50[15:0]); // 26.0
    wire [15:0] v51; shift_adder #(16, 4, 1, 0, 16, 0, 0) op_51 (v50[15:0], 4'b1000, v51[15:0]); // 26.0
    wire [14:0] v52; assign v52[14:0] = v51[14:0] & {15{~v51[15]}}; // 26.0
    wire [14:0] v53; shift_adder #(15, 5, 0, 0, 15, 0, 0) op_53 (v52[14:0], 5'b10000, v53[14:0]); // 26.0
    wire [6:0] v54; assign v54[6:0] = v53[11:5]; // 26.0
    wire [4:0] v55; assign v55[4:0] = model_inp[181:177]; // 24.0
    wire [11:0] v56; shift_adder #(5, 12, 0, 1, 12, -3, 1) op_56 (v55[4:0], v14[11:0], v56[11:0]); // 26.0
    wire [12:0] v57; shift_adder #(12, 8, 1, 0, 13, 3, 1) op_57 (v17[11:0], v49[7:0], v57[12:0]); // 26.0
    wire [4:0] v58; assign v58[4:0] = model_inp[186:182]; // 24.0
    wire [12:0] v59; shift_adder #(12, 5, 1, 0, 13, -1, 1) op_59 (v19[11:0], v58[4:0], v59[12:0]); // 26.0
    wire [12:0] v60; shift_adder #(13, 3, 1, 0, 13, 0, 1) op_60 (v59[12:0], 3'b100, v60[12:0]); // 26.0
    wire [11:0] v61; assign v61[11:0] = v60[11:0] & {12{~v60[12]}}; // 26.0
    wire [11:0] v62; shift_adder #(12, 3, 0, 0, 12, 0, 0) op_62 (v61[11:0], 3'b100, v62[11:0]); // 26.0
    wire [5:0] v63; assign v63[5:0] = v62[8:3]; // 26.0
    wire [11:0] v64; assign v64[11:0] = model_inp[198:187]; // 24.0
    wire [12:0] v65; shift_adder #(12, 10, 1, 1, 13, 0, 1) op_65 (v64[11:0], v28[9:0], v65[12:0]); // 26.0
    wire [11:0] v66; assign v66[11:0] = model_inp[210:199]; // 24.0
    wire [12:0] v67; shift_adder #(12, 12, 1, 1, 13, -1, 0) op_67 (v66[11:0], v29[11:0], v67[12:0]); // 26.0
    wire [10:0] v68; assign v68[10:0] = model_inp[221:211]; // 24.0
    wire [11:0] v69; shift_adder #(11, 10, 1, 1, 12, -1, 1) op_69 (v68[10:0], v28[9:0], v69[11:0]); // 26.0
    wire [10:0] v70; assign v70[10:0] = v69[10:0] & {11{~v69[11]}}; // 26.0
    wire [10:0] v71; shift_adder #(11, 4, 0, 0, 11, 0, 0) op_71 (v70[10:0], 4'b1000, v71[10:0]); // 26.0
    wire [4:0] v72; assign v72[4:0] = v71[8:4]; // 26.0
    wire [12:0] v73; shift_adder #(13, 5, 1, 0, 13, 0, 0) op_73 (v31[12:0], v58[4:0], v73[12:0]); // 26.0
    wire [11:0] v74; assign v74[11:0] = v73[11:0] & {12{~v73[12]}}; // 26.0
    wire [11:0] v75; shift_adder #(12, 3, 0, 0, 12, 0, 0) op_75 (v74[11:0], 3'b100, v75[11:0]); // 26.0
    wire [5:0] v76; assign v76[5:0] = v75[8:3]; // 26.0
    wire [4:0] v77; assign v77[4:0] = model_inp[226:222]; // 24.0
    wire [11:0] v78; shift_adder #(5, 12, 0, 1, 12, -3, 0) op_78 (v77[4:0], v29[11:0], v78[11:0]); // 26.0
    wire [12:0] v79; shift_adder #(6, 6, 0, 0, 13, -6, 1) op_79 (v25[5:0], v25[5:0], v79[12:0]); // 26.0
    wire [6:0] v80; assign v80[6:0] = model_inp[233:227]; // 24.0
    wire [9:0] v81; shift_adder #(7, 4, 0, 0, 10, -2, 0) op_81 (v80[6:0], v37[3:0], v81[9:0]); // 26.0
    wire [10:0] v82; shift_adder #(10, 4, 1, 0, 11, -1, 1) op_82 (v40[9:0], v46[3:0], v82[10:0]); // 26.0
    wire [12:0] v83; assign v83[12:0] = model_inp[246:234]; // 24.0
    wire [2:0] v84; assign v84[2:0] = model_inp[249:247]; // 24.0
    wire [12:0] v85; assign v85[12:0] = model_inp[262:250]; // 24.0
    wire [5:0] v86; assign v86[5:0] = model_inp[268:263]; // 24.0
    wire [5:0] v87; assign v87[5:0] = model_inp[274:269]; // 24.0
    wire [12:0] v88; assign v88[12:0] = model_inp[287:275]; // 24.0
    wire [10:0] v89; assign v89[10:0] = model_inp[298:288]; // 24.0
    wire [5:0] v90; assign v90[5:0] = model_inp[304:299]; // 24.0
    wire [4:0] v91; assign v91[4:0] = model_inp[309:305]; // 24.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[9:0] = v48[9:0];
    assign model_out[16:10] = v54[6:0];
    assign model_out[29:17] = v83[12:0];
    assign model_out[41:30] = v56[11:0];
    assign model_out[54:42] = v57[12:0];
    assign model_out[59:55] = v58[4:0];
    assign model_out[72:60] = v65[12:0];
    assign model_out[85:73] = v67[12:0];
    assign model_out[91:86] = v63[5:0];
    assign model_out[97:92] = v76[5:0];
    assign model_out[100:98] = v84[2:0];
    assign model_out[112:101] = v78[11:0];
    assign model_out[125:113] = v85[12:0];
    assign model_out[130:126] = v72[4:0];
    assign model_out[137:131] = v80[6:0];
    assign model_out[141:138] = v37[3:0];
    assign model_out[154:142] = v79[12:0];
    assign model_out[164:155] = v81[9:0];
    assign model_out[175:165] = v82[10:0];
    assign model_out[181:176] = v47[5:0];
    assign model_out[187:182] = v86[5:0];
    assign model_out[193:188] = v87[5:0];
    assign model_out[206:194] = v88[12:0];
    assign model_out[217:207] = v89[10:0];
    assign model_out[224:218] = v8[6:0];
    assign model_out[230:225] = v90[5:0];
    assign model_out[236:231] = v25[5:0];
    assign model_out[242:237] = v6[5:0];
    assign model_out[247:243] = v7[4:0];
    assign model_out[252:248] = v91[4:0];
    assign model_out[256:253] = v46[3:0];

endmodule
