`timescale 1 ns / 1 ps

module x310_clf_stage15 (
    input [337:0] model_inp,
    output [309:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [13:0] v0; assign v0[13:0] = model_inp[13:0]; // 22.5
    wire [10:0] v1; assign v1[10:0] = model_inp[24:14]; // 22.5
    wire [14:0] v2; shift_adder #(14, 11, 1, 1, 15, 0, 1) op_2 (v0[13:0], v1[10:0], v2[14:0]); // 23.0
    wire [14:0] v3; shift_adder #(15, 6, 1, 0, 15, 0, 1) op_3 (v2[14:0], 6'b101000, v3[14:0]); // 23.0
    wire [13:0] v4; assign v4[13:0] = v3[13:0] & {14{~v3[14]}}; // 23.0
    wire [13:0] v5; shift_adder #(14, 4, 0, 0, 14, 0, 0) op_5 (v4[13:0], 4'b1000, v5[13:0]); // 23.0
    wire [6:0] v6; assign v6[6:0] = v5[10:4]; // 23.0
    wire [11:0] v7; assign v7[11:0] = model_inp[36:25]; // 22.5
    wire [12:0] v8; assign v8[12:0] = model_inp[49:37]; // 22.5
    wire [13:0] v9; shift_adder #(12, 13, 1, 1, 14, -1, 0) op_9 (v7[11:0], v8[12:0], v9[13:0]); // 23.0
    wire [8:0] v10; assign v10[8:0] = model_inp[58:50]; // 22.5
    wire [5:0] v11; assign v11[5:0] = model_inp[64:59]; // 22.5
    wire [9:0] v12; shift_adder #(9, 6, 1, 0, 10, 1, 0) op_12 (v10[8:0], v11[5:0], v12[9:0]); // 23.0
    wire [3:0] v13; assign v13[3:0] = model_inp[68:65]; // 22.5
    wire [7:0] v14; shift_adder #(4, 7, 0, 0, 8, -2, 0) op_14 (v13[3:0], v6[6:0], v14[7:0]); // 24.0
    wire [8:0] v15; assign v15[8:0] = model_inp[77:69]; // 22.5
    wire [12:0] v16; shift_adder #(9, 7, 1, 0, 13, -3, 1) op_16 (v15[8:0], v6[6:0], v16[12:0]); // 24.0
    wire [12:0] v17; shift_adder #(13, 3, 1, 0, 13, 0, 1) op_17 (v16[12:0], 3'b100, v17[12:0]); // 24.0
    wire [10:0] v18; assign v18[10:0] = v17[10:0] & {11{~v17[12]}}; // 24.0
    wire [10:0] v19; shift_adder #(11, 4, 0, 0, 11, 0, 0) op_19 (v18[10:0], 4'b1000, v19[10:0]); // 24.0
    wire [4:0] v20; assign v20[4:0] = v19[8:4]; // 24.0
    wire [4:0] v21; assign v21[4:0] = model_inp[82:78]; // 22.5
    wire [7:0] v22; shift_adder #(7, 5, 0, 0, 8, 0, 0) op_22 (v6[6:0], v21[4:0], v22[7:0]); // 24.0
    wire [4:0] v23; assign v23[4:0] = model_inp[87:83]; // 22.5
    wire [7:0] v24; shift_adder #(5, 7, 0, 0, 8, -2, 1) op_24 (v23[4:0], v6[6:0], v24[7:0]); // 24.0
    wire [5:0] v25; assign v25[5:0] = model_inp[93:88]; // 22.5
    wire [8:0] v26; shift_adder #(6, 7, 0, 0, 9, -2, 1) op_26 (v25[5:0], v6[6:0], v26[8:0]); // 24.0
    wire [11:0] v27; assign v27[11:0] = model_inp[105:94]; // 22.5
    wire [11:0] v28; shift_adder #(12, 7, 1, 0, 12, 2, 0) op_28 (v27[11:0], v6[6:0], v28[11:0]); // 24.0
    wire [4:0] v29; assign v29[4:0] = model_inp[110:106]; // 22.5
    wire [8:0] v30; shift_adder #(5, 7, 0, 0, 9, -3, 1) op_30 (v29[4:0], v6[6:0], v30[8:0]); // 24.0
    wire [12:0] v31; assign v31[12:0] = model_inp[123:111]; // 22.5
    wire [15:0] v32; shift_adder #(13, 7, 1, 0, 16, -3, 0) op_32 (v31[12:0], v6[6:0], v32[15:0]); // 24.0
    wire [15:0] v33; shift_adder #(16, 4, 1, 0, 16, 0, 0) op_33 (v32[15:0], 4'b1000, v33[15:0]); // 24.0
    wire [13:0] v34; assign v34[13:0] = v33[13:0] & {14{~v33[15]}}; // 24.0
    wire [13:0] v35; shift_adder #(14, 5, 0, 0, 14, 0, 0) op_35 (v34[13:0], 5'b10000, v35[13:0]); // 24.0
    wire [6:0] v36; assign v36[6:0] = v35[11:5]; // 24.0
    wire [9:0] v37; assign v37[9:0] = model_inp[133:124]; // 22.5
    wire [11:0] v38; shift_adder #(10, 7, 1, 0, 12, -2, 1) op_38 (v37[9:0], v6[6:0], v38[11:0]); // 24.0
    wire [10:0] v39; assign v39[10:0] = v38[10:0] & {11{~v38[11]}}; // 24.0
    wire [10:0] v40; shift_adder #(11, 4, 0, 0, 11, 0, 0) op_40 (v39[10:0], 4'b1000, v40[10:0]); // 24.0
    wire [4:0] v41; assign v41[4:0] = v40[8:4]; // 24.0
    wire [11:0] v42; assign v42[11:0] = model_inp[145:134]; // 22.5
    wire [6:0] v43; assign v43[6:0] = model_inp[152:146]; // 22.5
    wire [6:0] v44; assign v44[6:0] = model_inp[159:153]; // 22.5
    wire [8:0] v45; assign v45[8:0] = model_inp[168:160]; // 22.5
    wire [10:0] v46; assign v46[10:0] = model_inp[179:169]; // 22.5
    wire [7:0] v47; assign v47[7:0] = model_inp[187:180]; // 22.5
    wire [11:0] v48; assign v48[11:0] = model_inp[199:188]; // 22.5
    wire [11:0] v49; assign v49[11:0] = model_inp[211:200]; // 22.5
    wire [10:0] v50; assign v50[10:0] = model_inp[222:212]; // 22.5
    wire [4:0] v51; assign v51[4:0] = model_inp[227:223]; // 22.5
    wire [11:0] v52; assign v52[11:0] = model_inp[239:228]; // 22.5
    wire [11:0] v53; assign v53[11:0] = model_inp[251:240]; // 22.5
    wire [10:0] v54; assign v54[10:0] = model_inp[262:252]; // 22.5
    wire [4:0] v55; assign v55[4:0] = model_inp[267:263]; // 22.5
    wire [12:0] v56; assign v56[12:0] = model_inp[280:268]; // 22.5
    wire [2:0] v57; assign v57[2:0] = model_inp[283:281]; // 22.5
    wire [12:0] v58; assign v58[12:0] = model_inp[296:284]; // 22.5
    wire [5:0] v59; assign v59[5:0] = model_inp[302:297]; // 22.5
    wire [12:0] v60; assign v60[12:0] = model_inp[315:303]; // 22.5
    wire [10:0] v61; assign v61[10:0] = model_inp[326:316]; // 22.5
    wire [5:0] v62; assign v62[5:0] = model_inp[332:327]; // 22.5
    wire [4:0] v63; assign v63[4:0] = model_inp[337:333]; // 22.5

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[11:0] = v42[11:0];
    assign model_out[19:12] = v14[7:0];
    assign model_out[24:20] = v20[4:0];
    assign model_out[31:25] = v43[6:0];
    assign model_out[45:32] = v9[13:0];
    assign model_out[53:46] = v24[7:0];
    assign model_out[60:54] = v44[6:0];
    assign model_out[69:61] = v45[8:0];
    assign model_out[78:70] = v26[8:0];
    assign model_out[89:79] = v46[10:0];
    assign model_out[101:90] = v28[11:0];
    assign model_out[109:102] = v47[7:0];
    assign model_out[118:110] = v30[8:0];
    assign model_out[130:119] = v48[11:0];
    assign model_out[142:131] = v49[11:0];
    assign model_out[152:143] = v12[9:0];
    assign model_out[157:153] = v41[4:0];
    assign model_out[168:158] = v50[10:0];
    assign model_out[176:169] = v22[7:0];
    assign model_out[181:177] = v51[4:0];
    assign model_out[186:182] = v23[4:0];
    assign model_out[198:187] = v52[11:0];
    assign model_out[210:199] = v53[11:0];
    assign model_out[221:211] = v54[10:0];
    assign model_out[226:222] = v55[4:0];
    assign model_out[233:227] = v36[6:0];
    assign model_out[246:234] = v56[12:0];
    assign model_out[249:247] = v57[2:0];
    assign model_out[262:250] = v58[12:0];
    assign model_out[268:263] = v11[5:0];
    assign model_out[274:269] = v59[5:0];
    assign model_out[287:275] = v60[12:0];
    assign model_out[298:288] = v61[10:0];
    assign model_out[304:299] = v62[5:0];
    assign model_out[309:305] = v63[4:0];

endmodule
