`timescale 1 ns / 1 ps

module qec_d3_stage7 (
    input [219:0] model_inp,
    output [91:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [7:0] v0; assign v0[7:0] = model_inp[7:0]; // 21.0
    wire [13:0] v1; assign v1[13:0] = model_inp[21:8]; // 21.0
    wire [13:0] v2; shift_adder #(8, 14, 0, 1, 14, -3, 0) op_2 (v0[7:0], v1[13:0], v2[13:0]); // 22.0
    wire [12:0] v3; assign v3[12:0] = v2[12:0] & {13{~v2[13]}}; // 22.0
    wire [12:0] v4; shift_adder #(13, 4, 0, 0, 13, 0, 0) op_4 (v3[12:0], 4'b1000, v4[12:0]); // 22.0
    wire [5:0] v5; assign v5[5:0] = v4[9:4]; // 22.0
    wire [13:0] v6; assign v6[13:0] = model_inp[35:22]; // 21.0
    wire [15:0] v7; assign v7[15:0] = model_inp[51:36]; // 21.0
    wire [16:0] v8; shift_adder #(14, 16, 1, 1, 17, -1, 0) op_8 (v6[13:0], v7[15:0], v8[16:0]); // 22.0
    wire [12:0] v9; assign v9[12:0] = model_inp[64:52]; // 21.0
    wire [12:0] v10; assign v10[12:0] = model_inp[77:65]; // 21.0
    wire [13:0] v11; shift_adder #(13, 13, 1, 1, 14, 0, 1) op_11 (v9[12:0], v10[12:0], v11[13:0]); // 22.0
    wire [9:0] v12; assign v12[9:0] = model_inp[87:78]; // 21.0
    wire [8:0] v13; assign v13[8:0] = model_inp[96:88]; // 21.0
    wire [11:0] v14; shift_adder #(10, 9, 1, 1, 12, 2, 1) op_14 (v12[9:0], v13[8:0], v14[11:0]); // 22.0
    wire [3:0] v15; assign v15[3:0] = model_inp[100:97]; // 21.0
    wire [14:0] v16; assign v16[14:0] = model_inp[115:101]; // 21.0
    wire [14:0] v17; shift_adder #(4, 15, 0, 1, 15, -4, 0) op_17 (v15[3:0], v16[14:0], v17[14:0]); // 22.0
    wire [12:0] v18; assign v18[12:0] = model_inp[128:116]; // 21.0
    wire [12:0] v19; shift_adder #(13, 10, 1, 1, 13, 0, 1) op_19 (v18[12:0], v12[9:0], v19[12:0]); // 22.0
    wire [1:0] v20; assign v20[1:0] = model_inp[130:129]; // 21.0
    wire [12:0] v21; assign v21[12:0] = model_inp[143:131]; // 21.0
    wire [12:0] v22; shift_adder #(2, 13, 0, 1, 13, -6, 1) op_22 (v20[1:0], v21[12:0], v22[12:0]); // 22.0
    wire [12:0] v23; assign v23[12:0] = model_inp[156:144]; // 21.0
    wire [13:0] v24; assign v24[13:0] = model_inp[170:157]; // 21.0
    wire [14:0] v25; shift_adder #(13, 14, 1, 1, 15, -2, 0) op_25 (v23[12:0], v24[13:0], v25[14:0]); // 22.0
    wire [2:0] v26; assign v26[2:0] = model_inp[173:171]; // 21.0
    wire [6:0] v27; shift_adder #(6, 3, 0, 0, 7, 3, 1) op_27 (v5[5:0], v26[2:0], v27[6:0]); // 23.0
    wire [10:0] v28; assign v28[10:0] = model_inp[184:174]; // 21.0
    wire [16:0] v29; shift_adder #(11, 17, 1, 1, 17, -4, 0) op_29 (v28[10:0], v8[16:0], v29[16:0]); // 23.0
    wire [16:0] v30; shift_adder #(17, 6, 1, 0, 17, 0, 0) op_30 (v29[16:0], 6'b101000, v30[16:0]); // 23.0
    wire [14:0] v31; assign v31[14:0] = v30[14:0] & {15{~v30[16]}}; // 23.0
    wire [14:0] v32; shift_adder #(15, 4, 0, 0, 15, 0, 0) op_32 (v31[14:0], 4'b1000, v32[14:0]); // 23.0
    wire [7:0] v33; assign v33[7:0] = v32[11:4]; // 23.0
    wire [12:0] v34; assign v34[12:0] = model_inp[197:185]; // 21.0
    wire [15:0] v35; shift_adder #(14, 13, 1, 1, 16, -2, 1) op_35 (v11[13:0], v34[12:0], v35[15:0]); // 23.0
    wire [15:0] v36; shift_adder #(16, 6, 1, 0, 16, 0, 0) op_36 (v35[15:0], 6'b110000, v36[15:0]); // 23.0
    wire [14:0] v37; assign v37[14:0] = v36[14:0] & {15{~v36[15]}}; // 23.0
    wire [14:0] v38; shift_adder #(15, 3, 0, 0, 15, 0, 0) op_38 (v37[14:0], 3'b100, v38[14:0]); // 23.0
    wire [7:0] v39; assign v39[7:0] = v38[10:3]; // 23.0
    wire [13:0] v40; assign v40[13:0] = model_inp[211:198]; // 21.0
    wire [13:0] v41; shift_adder #(14, 12, 1, 1, 14, 0, 0) op_41 (v40[13:0], v14[11:0], v41[13:0]); // 23.0
    wire [1:0] v42; assign v42[1:0] = model_inp[213:212]; // 21.0
    wire [14:0] v43; shift_adder #(2, 15, 0, 1, 15, -6, 1) op_43 (v42[1:0], v17[14:0], v43[14:0]); // 23.0
    wire [1:0] v44; assign v44[1:0] = model_inp[215:214]; // 21.0
    wire [12:0] v45; shift_adder #(2, 13, 0, 1, 13, -6, 1) op_45 (v44[1:0], v22[12:0], v45[12:0]); // 23.0
    wire [9:0] v46; shift_adder #(7, 8, 1, 0, 10, -2, 0) op_46 (v27[6:0], v33[7:0], v46[9:0]); // 24.0
    wire [3:0] v47; assign v47[3:0] = model_inp[219:216]; // 21.0
    wire [11:0] v48; shift_adder #(8, 4, 0, 0, 12, 7, 0) op_48 (v39[7:0], v47[3:0], v48[11:0]); // 24.0
    wire [15:0] v49; shift_adder #(14, 15, 1, 1, 16, -2, 1) op_49 (v41[13:0], v43[14:0], v49[15:0]); // 24.0
    wire [15:0] v50; shift_adder #(16, 7, 1, 0, 16, 0, 1) op_50 (v49[15:0], 7'b1000000, v50[15:0]); // 24.0
    wire [14:0] v51; assign v51[14:0] = v50[14:0] & {15{~v50[15]}}; // 24.0
    wire [14:0] v52; shift_adder #(15, 4, 0, 0, 15, 0, 0) op_52 (v51[14:0], 4'b1000, v52[14:0]); // 24.0
    wire [8:0] v53; assign v53[8:0] = v52[12:4]; // 24.0
    wire [14:0] v54; shift_adder #(13, 13, 1, 1, 15, -2, 0) op_54 (v19[12:0], v45[12:0], v54[14:0]); // 24.0
    wire [15:0] v55; shift_adder #(15, 13, 1, 1, 16, -1, 0) op_55 (v25[14:0], v45[12:0], v55[15:0]); // 24.0
    wire [15:0] v56; shift_adder #(16, 6, 1, 0, 16, 0, 1) op_56 (v55[15:0], 6'b110000, v56[15:0]); // 24.0
    wire [14:0] v57; assign v57[14:0] = v56[14:0] & {15{~v56[15]}}; // 24.0
    wire [14:0] v58; shift_adder #(15, 4, 0, 0, 15, 0, 0) op_58 (v57[14:0], 4'b1000, v58[14:0]); // 24.0
    wire [8:0] v59; assign v59[8:0] = v58[12:4]; // 24.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[9:0] = v46[9:0];
    assign model_out[21:10] = v48[11:0];
    assign model_out[27:22] = v5[5:0];
    assign model_out[36:28] = v53[8:0];
    assign model_out[51:37] = v54[14:0];
    assign model_out[66:52] = v43[14:0];
    assign model_out[75:67] = v59[8:0];
    assign model_out[83:76] = v39[7:0];
    assign model_out[91:84] = v33[7:0];

endmodule
