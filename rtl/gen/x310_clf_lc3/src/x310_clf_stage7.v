`timescale 1 ns / 1 ps

module x310_clf_stage7 (
    input [397:0] model_inp,
    output [309:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [13:0] v0; assign v0[13:0] = model_inp[13:0]; // 21.0
    wire [10:0] v1; assign v1[10:0] = model_inp[24:14]; // 21.0
    wire [13:0] v2; shift_adder #(14, 11, 1, 1, 14, 2, 0) op_2 (v0[13:0], v1[10:0], v2[13:0]); // 22.0
    wire [10:0] v3; assign v3[10:0] = model_inp[35:25]; // 21.0
    wire [9:0] v4; assign v4[9:0] = model_inp[45:36]; // 21.0
    wire [12:0] v5; shift_adder #(11, 10, 1, 1, 13, 2, 1) op_5 (v3[10:0], v4[9:0], v5[12:0]); // 22.0
    wire [10:0] v6; assign v6[10:0] = model_inp[56:46]; // 21.0
    wire [12:0] v7; assign v7[12:0] = model_inp[69:57]; // 21.0
    wire [12:0] v8; shift_adder #(11, 13, 1, 1, 13, 0, 0) op_8 (v6[10:0], v7[12:0], v8[12:0]); // 22.0
    wire [7:0] v9; assign v9[7:0] = model_inp[77:70]; // 21.0
    wire [11:0] v10; assign v10[11:0] = model_inp[89:78]; // 21.0
    wire [11:0] v11; shift_adder #(8, 12, 0, 1, 12, -2, 0) op_11 (v9[7:0], v10[11:0], v11[11:0]); // 22.0
    wire [11:0] v12; assign v12[11:0] = model_inp[101:90]; // 21.0
    wire [11:0] v13; assign v13[11:0] = model_inp[113:102]; // 21.0
    wire [12:0] v14; shift_adder #(12, 12, 1, 1, 13, 0, 0) op_14 (v12[11:0], v13[11:0], v14[12:0]); // 22.0
    wire [12:0] v15; shift_adder #(13, 3, 1, 0, 13, 0, 0) op_15 (v14[12:0], 3'b100, v15[12:0]); // 22.0
    wire [11:0] v16; assign v16[11:0] = v15[11:0] & {12{~v15[12]}}; // 22.0
    wire [11:0] v17; shift_adder #(12, 3, 0, 0, 12, 0, 0) op_17 (v16[11:0], 3'b100, v17[11:0]); // 22.0
    wire [5:0] v18; assign v18[5:0] = v17[8:3]; // 22.0
    wire [13:0] v19; assign v19[13:0] = model_inp[127:114]; // 21.0
    wire [7:0] v20; assign v20[7:0] = model_inp[135:128]; // 21.0
    wire [13:0] v21; shift_adder #(14, 8, 1, 1, 14, 2, 1) op_21 (v19[13:0], v20[7:0], v21[13:0]); // 22.0
    wire [13:0] v22; shift_adder #(14, 2, 1, 0, 14, 0, 0) op_22 (v21[13:0], 2'b10, v22[13:0]); // 22.0
    wire [10:0] v23; assign v23[10:0] = v22[10:0] & {11{~v22[13]}}; // 22.0
    wire [10:0] v24; shift_adder #(11, 3, 0, 0, 11, 0, 0) op_24 (v23[10:0], 3'b100, v24[10:0]); // 22.0
    wire [5:0] v25; assign v25[5:0] = v24[8:3]; // 22.0
    wire [9:0] v26; assign v26[9:0] = model_inp[145:136]; // 21.0
    wire [9:0] v27; assign v27[9:0] = model_inp[155:146]; // 21.0
    wire [11:0] v28; shift_adder #(10, 10, 1, 1, 12, -1, 0) op_28 (v26[9:0], v27[9:0], v28[11:0]); // 22.0
    wire [5:0] v29; assign v29[5:0] = model_inp[161:156]; // 21.0
    wire [4:0] v30; assign v30[4:0] = model_inp[166:162]; // 21.0
    wire [8:0] v31; shift_adder #(6, 5, 0, 0, 9, -2, 1) op_31 (v29[5:0], v30[4:0], v31[8:0]); // 22.0
    wire [9:0] v32; assign v32[9:0] = model_inp[176:167]; // 21.0
    wire [9:0] v33; shift_adder #(10, 8, 1, 1, 10, 0, 1) op_33 (v32[9:0], v20[7:0], v33[9:0]); // 22.0
    wire [14:0] v34; shift_adder #(14, 11, 1, 1, 15, 0, 1) op_34 (v2[13:0], v1[10:0], v34[14:0]); // 23.0
    wire [14:0] v35; shift_adder #(15, 6, 1, 0, 15, 0, 1) op_35 (v34[14:0], 6'b101000, v35[14:0]); // 23.0
    wire [13:0] v36; assign v36[13:0] = v35[13:0] & {14{~v35[14]}}; // 23.0
    wire [13:0] v37; shift_adder #(14, 4, 0, 0, 14, 0, 0) op_37 (v36[13:0], 4'b1000, v37[13:0]); // 23.0
    wire [6:0] v38; assign v38[6:0] = v37[10:4]; // 23.0
    wire [11:0] v39; assign v39[11:0] = model_inp[188:177]; // 21.0
    wire [13:0] v40; shift_adder #(12, 13, 1, 1, 14, -1, 0) op_40 (v39[11:0], v5[12:0], v40[13:0]); // 23.0
    wire [9:0] v41; shift_adder #(9, 6, 1, 0, 10, 1, 0) op_41 (v31[8:0], v18[5:0], v41[9:0]); // 23.0
    wire [3:0] v42; assign v42[3:0] = model_inp[192:189]; // 21.0
    wire [7:0] v43; shift_adder #(4, 7, 0, 0, 8, -2, 0) op_43 (v42[3:0], v38[6:0], v43[7:0]); // 24.0
    wire [8:0] v44; assign v44[8:0] = model_inp[201:193]; // 21.0
    wire [12:0] v45; shift_adder #(9, 7, 1, 0, 13, -3, 1) op_45 (v44[8:0], v38[6:0], v45[12:0]); // 24.0
    wire [12:0] v46; shift_adder #(13, 3, 1, 0, 13, 0, 1) op_46 (v45[12:0], 3'b100, v46[12:0]); // 24.0
    wire [10:0] v47; assign v47[10:0] = v46[10:0] & {11{~v46[12]}}; // 24.0
    wire [10:0] v48; shift_adder #(11, 4, 0, 0, 11, 0, 0) op_48 (v47[10:0], 4'b1000, v48[10:0]); // 24.0
    wire [4:0] v49; assign v49[4:0] = v48[8:4]; // 24.0
    wire [4:0] v50; assign v50[4:0] = model_inp[206:202]; // 21.0
    wire [7:0] v51; shift_adder #(7, 5, 0, 0, 8, 0, 0) op_51 (v38[6:0], v50[4:0], v51[7:0]); // 24.0
    wire [4:0] v52; assign v52[4:0] = model_inp[211:207]; // 21.0
    wire [7:0] v53; shift_adder #(5, 7, 0, 0, 8, -2, 1) op_53 (v52[4:0], v38[6:0], v53[7:0]); // 24.0
    wire [5:0] v54; assign v54[5:0] = model_inp[217:212]; // 21.0
    wire [8:0] v55; shift_adder #(6, 7, 0, 0, 9, -2, 1) op_55 (v54[5:0], v38[6:0], v55[8:0]); // 24.0
    wire [11:0] v56; assign v56[11:0] = model_inp[229:218]; // 21.0
    wire [11:0] v57; shift_adder #(12, 7, 1, 0, 12, 2, 0) op_57 (v56[11:0], v38[6:0], v57[11:0]); // 24.0
    wire [4:0] v58; assign v58[4:0] = model_inp[234:230]; // 21.0
    wire [8:0] v59; shift_adder #(5, 7, 0, 0, 9, -3, 1) op_59 (v58[4:0], v38[6:0], v59[8:0]); // 24.0
    wire [12:0] v60; assign v60[12:0] = model_inp[247:235]; // 21.0
    wire [15:0] v61; shift_adder #(13, 7, 1, 0, 16, -3, 0) op_61 (v60[12:0], v38[6:0], v61[15:0]); // 24.0
    wire [15:0] v62; shift_adder #(16, 4, 1, 0, 16, 0, 0) op_62 (v61[15:0], 4'b1000, v62[15:0]); // 24.0
    wire [13:0] v63; assign v63[13:0] = v62[13:0] & {14{~v62[15]}}; // 24.0
    wire [13:0] v64; shift_adder #(14, 5, 0, 0, 14, 0, 0) op_64 (v63[13:0], 5'b10000, v64[13:0]); // 24.0
    wire [6:0] v65; assign v65[6:0] = v64[11:5]; // 24.0
    wire [11:0] v66; shift_adder #(10, 7, 1, 0, 12, -2, 1) op_66 (v33[9:0], v38[6:0], v66[11:0]); // 24.0
    wire [10:0] v67; assign v67[10:0] = v66[10:0] & {11{~v66[11]}}; // 24.0
    wire [10:0] v68; shift_adder #(11, 4, 0, 0, 11, 0, 0) op_68 (v67[10:0], 4'b1000, v68[10:0]); // 24.0
    wire [4:0] v69; assign v69[4:0] = v68[8:4]; // 24.0
    wire [11:0] v70; assign v70[11:0] = model_inp[259:248]; // 21.0
    wire [6:0] v71; assign v71[6:0] = model_inp[266:260]; // 21.0
    wire [6:0] v72; assign v72[6:0] = model_inp[273:267]; // 21.0
    wire [8:0] v73; assign v73[8:0] = model_inp[282:274]; // 21.0
    wire [10:0] v74; assign v74[10:0] = model_inp[293:283]; // 21.0
    wire [7:0] v75; assign v75[7:0] = model_inp[301:294]; // 21.0
    wire [11:0] v76; assign v76[11:0] = model_inp[313:302]; // 21.0
    wire [10:0] v77; assign v77[10:0] = model_inp[324:314]; // 21.0
    wire [4:0] v78; assign v78[4:0] = model_inp[329:325]; // 21.0
    wire [11:0] v79; assign v79[11:0] = model_inp[341:330]; // 21.0
    wire [10:0] v80; assign v80[10:0] = model_inp[352:342]; // 21.0
    wire [4:0] v81; assign v81[4:0] = model_inp[357:353]; // 21.0
    wire [2:0] v82; assign v82[2:0] = model_inp[360:358]; // 21.0
    wire [12:0] v83; assign v83[12:0] = model_inp[373:361]; // 21.0
    wire [12:0] v84; assign v84[12:0] = model_inp[386:374]; // 21.0
    wire [10:0] v85; assign v85[10:0] = model_inp[397:387]; // 21.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[11:0] = v70[11:0];
    assign model_out[19:12] = v43[7:0];
    assign model_out[24:20] = v49[4:0];
    assign model_out[31:25] = v71[6:0];
    assign model_out[45:32] = v40[13:0];
    assign model_out[53:46] = v53[7:0];
    assign model_out[60:54] = v72[6:0];
    assign model_out[69:61] = v73[8:0];
    assign model_out[78:70] = v55[8:0];
    assign model_out[89:79] = v74[10:0];
    assign model_out[101:90] = v57[11:0];
    assign model_out[109:102] = v75[7:0];
    assign model_out[118:110] = v59[8:0];
    assign model_out[130:119] = v28[11:0];
    assign model_out[142:131] = v76[11:0];
    assign model_out[152:143] = v41[9:0];
    assign model_out[157:153] = v69[4:0];
    assign model_out[168:158] = v77[10:0];
    assign model_out[176:169] = v51[7:0];
    assign model_out[181:177] = v78[4:0];
    assign model_out[186:182] = v52[4:0];
    assign model_out[198:187] = v11[11:0];
    assign model_out[210:199] = v79[11:0];
    assign model_out[221:211] = v80[10:0];
    assign model_out[226:222] = v81[4:0];
    assign model_out[233:227] = v65[6:0];
    assign model_out[246:234] = v8[12:0];
    assign model_out[249:247] = v82[2:0];
    assign model_out[262:250] = v83[12:0];
    assign model_out[268:263] = v18[5:0];
    assign model_out[274:269] = v25[5:0];
    assign model_out[287:275] = v84[12:0];
    assign model_out[298:288] = v85[10:0];
    assign model_out[304:299] = v29[5:0];
    assign model_out[309:305] = v30[4:0];

endmodule
