`timescale 1 ns / 1 ps

module x310_clf_stage14 (
    input [222:0] model_inp,
    output [221:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [11:0] v0; assign v0[11:0] = model_inp[11:0]; // 28.0
    wire [6:0] v1; assign v1[6:0] = model_inp[18:12]; // 28.0
    wire [12:0] v2; shift_adder #(12, 7, 1, 1, 13, 4, 0) op_2 (v0[11:0], v1[6:0], v2[12:0]); // 29.0
    wire [5:0] v3; assign v3[5:0] = model_inp[24:19]; // 28.0
    wire [7:0] v4; assign v4[7:0] = model_inp[32:25]; // 28.0
    wire [9:0] v5; shift_adder #(6, 8, 0, 1, 10, 1, 0) op_5 (v3[5:0], v4[7:0], v5[9:0]); // 29.0
    wire [8:0] v6; assign v6[8:0] = model_inp[41:33]; // 28.0
    wire [9:0] v7; assign v7[9:0] = model_inp[51:42]; // 28.0
    wire [10:0] v8; shift_adder #(9, 10, 0, 1, 11, 1, 0) op_8 (v6[8:0], v7[9:0], v8[10:0]); // 29.0
    wire [4:0] v9; assign v9[4:0] = model_inp[56:52]; // 28.0
    wire [6:0] v10; assign v10[6:0] = model_inp[63:57]; // 28.0
    wire [7:0] v11; shift_adder #(5, 7, 0, 0, 8, -1, 1) op_11 (v9[4:0], v10[6:0], v11[7:0]); // 29.0
    wire [5:0] v12; assign v12[5:0] = model_inp[69:64]; // 28.0
    wire [3:0] v13; assign v13[3:0] = model_inp[73:70]; // 28.0
    wire [6:0] v14; shift_adder #(6, 4, 0, 0, 7, 2, 1) op_14 (v12[5:0], v13[3:0], v14[6:0]); // 29.0
    wire [6:0] v15; assign v15[6:0] = model_inp[80:74]; // 28.0
    wire [8:0] v16; shift_adder #(7, 7, 0, 0, 9, -1, 1) op_16 (v10[6:0], v15[6:0], v16[8:0]); // 29.0
    wire [8:0] v17; assign v17[8:0] = model_inp[89:81]; // 28.0
    wire [10:0] v18; shift_adder #(9, 8, 1, 1, 11, -1, 0) op_18 (v17[8:0], v4[7:0], v18[10:0]); // 29.0
    wire [9:0] v19; assign v19[9:0] = model_inp[99:90]; // 28.0
    wire [9:0] v20; shift_adder #(10, 4, 0, 0, 10, 4, 0) op_20 (v19[9:0], v13[3:0], v20[9:0]); // 29.0
    wire [10:0] v21; assign v21[10:0] = model_inp[110:100]; // 28.0
    wire [12:0] v22; shift_adder #(11, 10, 1, 1, 13, 3, 0) op_22 (v21[10:0], v7[9:0], v22[12:0]); // 29.0
    wire [6:0] v23; assign v23[6:0] = model_inp[117:111]; // 28.0
    wire [6:0] v24; assign v24[6:0] = model_inp[124:118]; // 28.0
    wire [8:0] v25; shift_adder #(7, 7, 0, 1, 9, 0, 0) op_25 (v23[6:0], v24[6:0], v25[8:0]); // 29.0
    wire [10:0] v26; assign v26[10:0] = model_inp[135:125]; // 28.0
    wire [14:0] v27; assign v27[14:0] = model_inp[150:136]; // 28.0
    wire [14:0] v28; shift_adder #(11, 15, 0, 1, 15, -2, 0) op_28 (v26[10:0], v27[14:0], v28[14:0]); // 29.0
    wire [10:0] v29; shift_adder #(9, 9, 0, 1, 11, -1, 1) op_29 (v6[8:0], v17[8:0], v29[10:0]); // 29.0
    wire [8:0] v30; assign v30[8:0] = model_inp[159:151]; // 28.0
    wire [9:0] v31; shift_adder #(9, 7, 1, 0, 10, 1, 0) op_31 (v30[8:0], v10[6:0], v31[9:0]); // 29.0
    wire [10:0] v32; shift_adder #(11, 4, 0, 0, 11, 4, 0) op_32 (v26[10:0], v13[3:0], v32[10:0]); // 29.0
    wire [9:0] v33; assign v33[9:0] = model_inp[169:160]; // 28.0
    wire [11:0] v34; assign v34[11:0] = model_inp[181:170]; // 28.0
    wire [12:0] v35; shift_adder #(10, 12, 1, 1, 13, -2, 0) op_35 (v33[9:0], v34[11:0], v35[12:0]); // 29.0
    wire [10:0] v36; shift_adder #(9, 7, 1, 1, 11, -1, 1) op_36 (v17[8:0], v24[6:0], v36[10:0]); // 29.0
    wire [10:0] v37; assign v37[10:0] = model_inp[192:182]; // 28.0
    wire [12:0] v38; shift_adder #(11, 9, 1, 0, 13, 2, 0) op_38 (v37[10:0], v6[8:0], v38[12:0]); // 29.0
    wire [5:0] v39; assign v39[5:0] = model_inp[198:193]; // 28.0
    wire [8:0] v40; shift_adder #(6, 9, 0, 1, 9, -1, 0) op_40 (v39[5:0], v30[8:0], v40[8:0]); // 29.0
    wire [12:0] v41; shift_adder #(13, 10, 1, 1, 13, 1, 1) op_41 (v2[12:0], v5[9:0], v41[12:0]); // 30.0
    wire [11:0] v42; shift_adder #(8, 11, 1, 1, 12, -3, 0) op_42 (v4[7:0], v8[10:0], v42[11:0]); // 30.0
    wire [9:0] v43; shift_adder #(7, 8, 0, 1, 10, -1, 0) op_43 (v15[6:0], v11[7:0], v43[9:0]); // 30.0
    wire [8:0] v44; shift_adder #(4, 7, 0, 1, 9, 1, 0) op_44 (v13[3:0], v14[6:0], v44[8:0]); // 30.0
    wire [3:0] v45; assign v45[3:0] = model_inp[202:199]; // 28.0
    wire [9:0] v46; shift_adder #(4, 9, 0, 1, 10, -3, 0) op_46 (v45[3:0], v16[8:0], v46[9:0]); // 30.0
    wire [13:0] v47; shift_adder #(7, 10, 1, 0, 14, -6, 0) op_47 (v14[6:0], v20[9:0], v47[13:0]); // 30.0
    wire [13:0] v48; shift_adder #(13, 9, 1, 1, 14, 4, 0) op_48 (v22[12:0], v25[8:0], v48[13:0]); // 30.0
    wire [14:0] v49; shift_adder #(15, 9, 1, 1, 15, 0, 1) op_49 (v28[14:0], v16[8:0], v49[14:0]); // 30.0
    wire [10:0] v50; shift_adder #(5, 11, 0, 1, 11, -1, 0) op_50 (v9[4:0], v29[10:0], v50[10:0]); // 30.0
    wire [11:0] v51; shift_adder #(10, 11, 1, 1, 12, 0, 0) op_51 (v31[9:0], v8[10:0], v51[11:0]); // 30.0
    wire [13:0] v52; shift_adder #(13, 11, 1, 1, 14, 1, 0) op_52 (v35[12:0], v36[10:0], v52[13:0]); // 30.0
    wire [13:0] v53; shift_adder #(10, 13, 0, 1, 14, -2, 0) op_53 (v19[9:0], v38[12:0], v53[13:0]); // 30.0
    wire [12:0] v54; shift_adder #(10, 8, 1, 1, 13, -3, 1) op_54 (v5[9:0], v11[7:0], v54[12:0]); // 30.0
    wire [5:0] v55; assign v55[5:0] = model_inp[208:203]; // 28.0
    wire [9:0] v56; shift_adder #(6, 9, 0, 1, 10, -2, 1) op_56 (v55[5:0], v40[8:0], v56[9:0]); // 30.0
    wire [4:0] v57; assign v57[4:0] = model_inp[213:209]; // 28.0
    wire [4:0] v58; assign v58[4:0] = model_inp[218:214]; // 28.0
    wire [3:0] v59; assign v59[3:0] = model_inp[222:219]; // 28.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[12:0] = v41[12:0];
    assign model_out[24:13] = v42[11:0];
    assign model_out[30:25] = v3[5:0];
    assign model_out[40:31] = v43[9:0];
    assign model_out[50:41] = v46[9:0];
    assign model_out[61:51] = v18[10:0];
    assign model_out[75:62] = v48[13:0];
    assign model_out[90:76] = v49[14:0];
    assign model_out[95:91] = v57[4:0];
    assign model_out[106:96] = v50[10:0];
    assign model_out[118:107] = v51[11:0];
    assign model_out[129:119] = v32[10:0];
    assign model_out[143:130] = v52[13:0];
    assign model_out[157:144] = v53[13:0];
    assign model_out[166:158] = v25[8:0];
    assign model_out[179:167] = v54[12:0];
    assign model_out[188:180] = v44[8:0];
    assign model_out[193:189] = v58[4:0];
    assign model_out[203:194] = v56[9:0];
    assign model_out[217:204] = v47[13:0];
    assign model_out[221:218] = v59[3:0];

endmodule
