`timescale 1 ns / 1 ps

module qec_d3_stage11 (
    input [153:0] model_inp,
    output [91:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [5:0] v0; assign v0[5:0] = model_inp[5:0]; // 22.0
    wire [2:0] v1; assign v1[2:0] = model_inp[8:6]; // 22.0
    wire [6:0] v2; shift_adder #(6, 3, 0, 0, 7, 3, 1) op_2 (v0[5:0], v1[2:0], v2[6:0]); // 23.0
    wire [10:0] v3; assign v3[10:0] = model_inp[19:9]; // 22.0
    wire [16:0] v4; assign v4[16:0] = model_inp[36:20]; // 22.0
    wire [16:0] v5; shift_adder #(11, 17, 1, 1, 17, -4, 0) op_5 (v3[10:0], v4[16:0], v5[16:0]); // 23.0
    wire [16:0] v6; shift_adder #(17, 6, 1, 0, 17, 0, 0) op_6 (v5[16:0], 6'b101000, v6[16:0]); // 23.0
    wire [14:0] v7; assign v7[14:0] = v6[14:0] & {15{~v6[16]}}; // 23.0
    wire [14:0] v8; shift_adder #(15, 4, 0, 0, 15, 0, 0) op_8 (v7[14:0], 4'b1000, v8[14:0]); // 23.0
    wire [7:0] v9; assign v9[7:0] = v8[11:4]; // 23.0
    wire [13:0] v10; assign v10[13:0] = model_inp[50:37]; // 22.0
    wire [12:0] v11; assign v11[12:0] = model_inp[63:51]; // 22.0
    wire [15:0] v12; shift_adder #(14, 13, 1, 1, 16, -2, 1) op_12 (v10[13:0], v11[12:0], v12[15:0]); // 23.0
    wire [15:0] v13; shift_adder #(16, 6, 1, 0, 16, 0, 0) op_13 (v12[15:0], 6'b110000, v13[15:0]); // 23.0
    wire [14:0] v14; assign v14[14:0] = v13[14:0] & {15{~v13[15]}}; // 23.0
    wire [14:0] v15; shift_adder #(15, 3, 0, 0, 15, 0, 0) op_15 (v14[14:0], 3'b100, v15[14:0]); // 23.0
    wire [7:0] v16; assign v16[7:0] = v15[10:3]; // 23.0
    wire [13:0] v17; assign v17[13:0] = model_inp[77:64]; // 22.0
    wire [11:0] v18; assign v18[11:0] = model_inp[89:78]; // 22.0
    wire [13:0] v19; shift_adder #(14, 12, 1, 1, 14, 0, 0) op_19 (v17[13:0], v18[11:0], v19[13:0]); // 23.0
    wire [1:0] v20; assign v20[1:0] = model_inp[91:90]; // 22.0
    wire [14:0] v21; assign v21[14:0] = model_inp[106:92]; // 22.0
    wire [14:0] v22; shift_adder #(2, 15, 0, 1, 15, -6, 1) op_22 (v20[1:0], v21[14:0], v22[14:0]); // 23.0
    wire [1:0] v23; assign v23[1:0] = model_inp[108:107]; // 22.0
    wire [12:0] v24; assign v24[12:0] = model_inp[121:109]; // 22.0
    wire [12:0] v25; shift_adder #(2, 13, 0, 1, 13, -6, 1) op_25 (v23[1:0], v24[12:0], v25[12:0]); // 23.0
    wire [9:0] v26; shift_adder #(7, 8, 1, 0, 10, -2, 0) op_26 (v2[6:0], v9[7:0], v26[9:0]); // 24.0
    wire [3:0] v27; assign v27[3:0] = model_inp[125:122]; // 22.0
    wire [11:0] v28; shift_adder #(8, 4, 0, 0, 12, 7, 0) op_28 (v16[7:0], v27[3:0], v28[11:0]); // 24.0
    wire [15:0] v29; shift_adder #(14, 15, 1, 1, 16, -2, 1) op_29 (v19[13:0], v22[14:0], v29[15:0]); // 24.0
    wire [15:0] v30; shift_adder #(16, 7, 1, 0, 16, 0, 1) op_30 (v29[15:0], 7'b1000000, v30[15:0]); // 24.0
    wire [14:0] v31; assign v31[14:0] = v30[14:0] & {15{~v30[15]}}; // 24.0
    wire [14:0] v32; shift_adder #(15, 4, 0, 0, 15, 0, 0) op_32 (v31[14:0], 4'b1000, v32[14:0]); // 24.0
    wire [8:0] v33; assign v33[8:0] = v32[12:4]; // 24.0
    wire [12:0] v34; assign v34[12:0] = model_inp[138:126]; // 22.0
    wire [14:0] v35; shift_adder #(13, 13, 1, 1, 15, -2, 0) op_35 (v34[12:0], v25[12:0], v35[14:0]); // 24.0
    wire [14:0] v36; assign v36[14:0] = model_inp[153:139]; // 22.0
    wire [15:0] v37; shift_adder #(15, 13, 1, 1, 16, -1, 0) op_37 (v36[14:0], v25[12:0], v37[15:0]); // 24.0
    wire [15:0] v38; shift_adder #(16, 6, 1, 0, 16, 0, 1) op_38 (v37[15:0], 6'b110000, v38[15:0]); // 24.0
    wire [14:0] v39; assign v39[14:0] = v38[14:0] & {15{~v38[15]}}; // 24.0
    wire [14:0] v40; shift_adder #(15, 4, 0, 0, 15, 0, 0) op_40 (v39[14:0], 4'b1000, v40[14:0]); // 24.0
    wire [8:0] v41; assign v41[8:0] = v40[12:4]; // 24.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[9:0] = v26[9:0];
    assign model_out[21:10] = v28[11:0];
    assign model_out[27:22] = v0[5:0];
    assign model_out[36:28] = v33[8:0];
    assign model_out[51:37] = v35[14:0];
    assign model_out[66:52] = v22[14:0];
    assign model_out[75:67] = v41[8:0];
    assign model_out[83:76] = v16[7:0];
    assign model_out[91:84] = v9[7:0];

endmodule
