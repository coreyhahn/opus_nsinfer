`timescale 1 ns / 1 ps

module x310_clf_stage9 (
    input [337:0] model_inp,
    output [283:0] model_out
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
    wire [11:0] v43; shift_adder #(12, 8, 1, 0, 12, 0, 0) op_43 (v42[11:0], v14[7:0], v43[11:0]); // 25.0
    wire [11:0] v44; shift_adder #(12, 3, 1, 0, 12, 0, 1) op_44 (v43[11:0], 3'b100, v44[11:0]); // 25.0
    wire [9:0] v45; assign v45[9:0] = v44[9:0] & {10{~v44[11]}}; // 25.0
    wire [9:0] v46; shift_adder #(10, 2, 0, 0, 10, 0, 0) op_46 (v45[9:0], 2'b10, v46[9:0]); // 25.0
    wire [5:0] v47; assign v47[5:0] = v46[7:2]; // 25.0
    wire [6:0] v48; assign v48[6:0] = model_inp[152:146]; // 22.5
    wire [7:0] v49; shift_adder #(5, 7, 0, 0, 8, -2, 0) op_49 (v20[4:0], v48[6:0], v49[7:0]); // 25.0
    wire [15:0] v50; shift_adder #(14, 8, 1, 1, 16, -2, 0) op_50 (v9[13:0], v24[7:0], v50[15:0]); // 25.0
    wire [6:0] v51; assign v51[6:0] = model_inp[159:153]; // 22.5
    wire [11:0] v52; shift_adder #(7, 8, 0, 1, 12, -3, 1) op_52 (v51[6:0], v24[7:0], v52[11:0]); // 25.0
    wire [8:0] v53; assign v53[8:0] = model_inp[168:160]; // 22.5
    wire [11:0] v54; shift_adder #(9, 9, 1, 1, 12, -3, 1) op_54 (v53[8:0], v26[8:0], v54[11:0]); // 25.0
    wire [10:0] v55; assign v55[10:0] = model_inp[179:169]; // 22.5
    wire [11:0] v56; shift_adder #(11, 9, 1, 1, 12, 0, 1) op_56 (v55[10:0], v26[8:0], v56[11:0]); // 25.0
    wire [11:0] v57; shift_adder #(8, 12, 0, 1, 12, 0, 0) op_57 (v14[7:0], v28[11:0], v57[11:0]); // 25.0
    wire [11:0] v58; shift_adder #(12, 4, 1, 0, 12, 0, 1) op_58 (v57[11:0], 4'b1010, v58[11:0]); // 25.0
    wire [10:0] v59; assign v59[10:0] = v58[10:0] & {11{~v58[11]}}; // 25.0
    wire [10:0] v60; shift_adder #(11, 3, 0, 0, 11, 0, 0) op_60 (v59[10:0], 3'b100, v60[10:0]); // 25.0
    wire [5:0] v61; assign v61[5:0] = v60[8:3]; // 25.0
    wire [7:0] v62; assign v62[7:0] = model_inp[187:180]; // 22.5
    wire [9:0] v63; shift_adder #(8, 9, 0, 1, 10, -1, 1) op_63 (v62[7:0], v30[8:0], v63[9:0]); // 25.0
    wire [11:0] v64; shift_adder #(9, 9, 1, 1, 12, -2, 1) op_64 (v26[8:0], v26[8:0], v64[11:0]); // 25.0
    wire [11:0] v65; assign v65[11:0] = model_inp[199:188]; // 22.5
    wire [12:0] v66; shift_adder #(12, 8, 1, 0, 13, -1, 1) op_66 (v65[11:0], v14[7:0], v66[12:0]); // 25.0
    wire [11:0] v67; assign v67[11:0] = model_inp[211:200]; // 22.5
    wire [12:0] v68; shift_adder #(12, 9, 1, 1, 13, 1, 1) op_68 (v67[11:0], v30[8:0], v68[12:0]); // 25.0
    wire [12:0] v69; shift_adder #(13, 4, 1, 0, 13, 0, 1) op_69 (v68[12:0], 4'b1000, v69[12:0]); // 25.0
    wire [9:0] v70; assign v70[9:0] = v69[9:0] & {10{~v69[12]}}; // 25.0
    wire [9:0] v71; shift_adder #(10, 4, 0, 0, 10, 0, 0) op_71 (v70[9:0], 4'b1000, v71[9:0]); // 25.0
    wire [3:0] v72; assign v72[3:0] = v71[7:4]; // 25.0
    wire [9:0] v73; shift_adder #(10, 5, 1, 0, 10, 0, 1) op_73 (v12[9:0], v41[4:0], v73[9:0]); // 25.0
    wire [10:0] v74; assign v74[10:0] = model_inp[222:212]; // 22.5
    wire [12:0] v75; shift_adder #(11, 8, 1, 1, 13, -1, 1) op_75 (v74[10:0], v24[7:0], v75[12:0]); // 25.0
    wire [12:0] v76; shift_adder #(13, 5, 1, 0, 13, 0, 1) op_76 (v75[12:0], 5'b10000, v76[12:0]); // 25.0
    wire [10:0] v77; assign v77[10:0] = v76[10:0] & {11{~v76[12]}}; // 25.0
    wire [10:0] v78; shift_adder #(11, 4, 0, 0, 11, 0, 0) op_78 (v77[10:0], 4'b1000, v78[10:0]); // 25.0
    wire [3:0] v79; assign v79[3:0] = v78[7:4]; // 25.0
    wire [5:0] v80; shift_adder #(5, 5, 0, 0, 6, 0, 1) op_80 (v41[4:0], v20[4:0], v80[5:0]); // 25.0
    wire [4:0] v81; assign v81[4:0] = model_inp[227:223]; // 22.5
    wire [11:0] v82; assign v82[11:0] = model_inp[239:228]; // 22.5
    wire [11:0] v83; assign v83[11:0] = model_inp[251:240]; // 22.5
    wire [10:0] v84; assign v84[10:0] = model_inp[262:252]; // 22.5
    wire [4:0] v85; assign v85[4:0] = model_inp[267:263]; // 22.5
    wire [12:0] v86; assign v86[12:0] = model_inp[280:268]; // 22.5
    wire [2:0] v87; assign v87[2:0] = model_inp[283:281]; // 22.5
    wire [12:0] v88; assign v88[12:0] = model_inp[296:284]; // 22.5
    wire [5:0] v89; assign v89[5:0] = model_inp[302:297]; // 22.5
    wire [12:0] v90; assign v90[12:0] = model_inp[315:303]; // 22.5
    wire [10:0] v91; assign v91[10:0] = model_inp[326:316]; // 22.5
    wire [5:0] v92; assign v92[5:0] = model_inp[332:327]; // 22.5
    wire [4:0] v93; assign v93[4:0] = model_inp[337:333]; // 22.5

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[5:0] = v47[5:0];
    assign model_out[13:6] = v49[7:0];
    assign model_out[21:14] = v22[7:0];
    assign model_out[37:22] = v50[15:0];
    assign model_out[42:38] = v81[4:0];
    assign model_out[54:43] = v52[11:0];
    assign model_out[66:55] = v54[11:0];
    assign model_out[78:67] = v56[11:0];
    assign model_out[83:79] = v23[4:0];
    assign model_out[95:84] = v82[11:0];
    assign model_out[105:96] = v63[9:0];
    assign model_out[117:106] = v83[11:0];
    assign model_out[129:118] = v64[11:0];
    assign model_out[140:130] = v84[10:0];
    assign model_out[153:141] = v66[12:0];
    assign model_out[158:154] = v85[4:0];
    assign model_out[164:159] = v61[5:0];
    assign model_out[171:165] = v36[6:0];
    assign model_out[175:172] = v72[3:0];
    assign model_out[185:176] = v73[9:0];
    assign model_out[189:186] = v79[3:0];
    assign model_out[202:190] = v86[12:0];
    assign model_out[205:203] = v87[2:0];
    assign model_out[218:206] = v88[12:0];
    assign model_out[224:219] = v80[5:0];
    assign model_out[230:225] = v11[5:0];
    assign model_out[236:231] = v89[5:0];
    assign model_out[249:237] = v90[12:0];
    assign model_out[260:250] = v91[10:0];
    assign model_out[267:261] = v48[6:0];
    assign model_out[273:268] = v92[5:0];
    assign model_out[278:274] = v20[4:0];
    assign model_out[283:279] = v93[4:0];

endmodule
