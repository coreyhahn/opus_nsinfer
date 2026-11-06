`timescale 1 ns / 1 ps

module x310_clf_stage14 (
    input [397:0] model_inp,
    output [337:0] model_out
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
    wire [11:0] v34; assign v34[11:0] = model_inp[188:177]; // 21.0
    wire [3:0] v35; assign v35[3:0] = model_inp[192:189]; // 21.0
    wire [8:0] v36; assign v36[8:0] = model_inp[201:193]; // 21.0
    wire [4:0] v37; assign v37[4:0] = model_inp[206:202]; // 21.0
    wire [4:0] v38; assign v38[4:0] = model_inp[211:207]; // 21.0
    wire [5:0] v39; assign v39[5:0] = model_inp[217:212]; // 21.0
    wire [11:0] v40; assign v40[11:0] = model_inp[229:218]; // 21.0
    wire [4:0] v41; assign v41[4:0] = model_inp[234:230]; // 21.0
    wire [12:0] v42; assign v42[12:0] = model_inp[247:235]; // 21.0
    wire [11:0] v43; assign v43[11:0] = model_inp[259:248]; // 21.0
    wire [6:0] v44; assign v44[6:0] = model_inp[266:260]; // 21.0
    wire [6:0] v45; assign v45[6:0] = model_inp[273:267]; // 21.0
    wire [8:0] v46; assign v46[8:0] = model_inp[282:274]; // 21.0
    wire [10:0] v47; assign v47[10:0] = model_inp[293:283]; // 21.0
    wire [7:0] v48; assign v48[7:0] = model_inp[301:294]; // 21.0
    wire [11:0] v49; assign v49[11:0] = model_inp[313:302]; // 21.0
    wire [10:0] v50; assign v50[10:0] = model_inp[324:314]; // 21.0
    wire [4:0] v51; assign v51[4:0] = model_inp[329:325]; // 21.0
    wire [11:0] v52; assign v52[11:0] = model_inp[341:330]; // 21.0
    wire [10:0] v53; assign v53[10:0] = model_inp[352:342]; // 21.0
    wire [4:0] v54; assign v54[4:0] = model_inp[357:353]; // 21.0
    wire [2:0] v55; assign v55[2:0] = model_inp[360:358]; // 21.0
    wire [12:0] v56; assign v56[12:0] = model_inp[373:361]; // 21.0
    wire [12:0] v57; assign v57[12:0] = model_inp[386:374]; // 21.0
    wire [10:0] v58; assign v58[10:0] = model_inp[397:387]; // 21.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[13:0] = v2[13:0];
    assign model_out[24:14] = v1[10:0];
    assign model_out[36:25] = v34[11:0];
    assign model_out[49:37] = v5[12:0];
    assign model_out[58:50] = v31[8:0];
    assign model_out[64:59] = v18[5:0];
    assign model_out[68:65] = v35[3:0];
    assign model_out[77:69] = v36[8:0];
    assign model_out[82:78] = v37[4:0];
    assign model_out[87:83] = v38[4:0];
    assign model_out[93:88] = v39[5:0];
    assign model_out[105:94] = v40[11:0];
    assign model_out[110:106] = v41[4:0];
    assign model_out[123:111] = v42[12:0];
    assign model_out[133:124] = v33[9:0];
    assign model_out[145:134] = v43[11:0];
    assign model_out[152:146] = v44[6:0];
    assign model_out[159:153] = v45[6:0];
    assign model_out[168:160] = v46[8:0];
    assign model_out[179:169] = v47[10:0];
    assign model_out[187:180] = v48[7:0];
    assign model_out[199:188] = v28[11:0];
    assign model_out[211:200] = v49[11:0];
    assign model_out[222:212] = v50[10:0];
    assign model_out[227:223] = v51[4:0];
    assign model_out[239:228] = v11[11:0];
    assign model_out[251:240] = v52[11:0];
    assign model_out[262:252] = v53[10:0];
    assign model_out[267:263] = v54[4:0];
    assign model_out[280:268] = v8[12:0];
    assign model_out[283:281] = v55[2:0];
    assign model_out[296:284] = v56[12:0];
    assign model_out[302:297] = v25[5:0];
    assign model_out[315:303] = v57[12:0];
    assign model_out[326:316] = v58[10:0];
    assign model_out[332:327] = v29[5:0];
    assign model_out[337:333] = v30[4:0];

endmodule
