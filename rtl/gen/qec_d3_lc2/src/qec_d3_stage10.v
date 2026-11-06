`timescale 1 ns / 1 ps

module qec_d3_stage10 (
    input [255:0] model_inp,
    output [153:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [10:0] v0; assign v0[10:0] = model_inp[10:0]; // 20.0
    wire [12:0] v1; assign v1[12:0] = model_inp[23:11]; // 20.0
    wire [13:0] v2; shift_adder #(11, 13, 1, 1, 14, 0, 0) op_2 (v0[10:0], v1[12:0], v2[13:0]); // 21.0
    wire [9:0] v3; assign v3[9:0] = model_inp[33:24]; // 20.0
    wire [9:0] v4; assign v4[9:0] = model_inp[43:34]; // 20.0
    wire [10:0] v5; shift_adder #(10, 10, 1, 1, 11, 0, 0) op_5 (v3[9:0], v4[9:0], v5[10:0]); // 21.0
    wire [11:0] v6; assign v6[11:0] = model_inp[55:44]; // 20.0
    wire [10:0] v7; assign v7[10:0] = model_inp[66:56]; // 20.0
    wire [13:0] v8; shift_adder #(12, 11, 1, 1, 14, 2, 0) op_8 (v6[11:0], v7[10:0], v8[13:0]); // 21.0
    wire [15:0] v9; assign v9[15:0] = model_inp[82:67]; // 20.0
    wire [15:0] v10; shift_adder #(10, 16, 1, 1, 16, -1, 1) op_10 (v4[9:0], v9[15:0], v10[15:0]); // 21.0
    wire [11:0] v11; assign v11[11:0] = model_inp[94:83]; // 20.0
    wire [12:0] v12; assign v12[12:0] = model_inp[107:95]; // 20.0
    wire [12:0] v13; shift_adder #(12, 13, 1, 1, 13, -1, 0) op_13 (v11[11:0], v12[12:0], v13[12:0]); // 21.0
    wire [8:0] v14; assign v14[8:0] = model_inp[116:108]; // 20.0
    wire [12:0] v15; shift_adder #(13, 9, 1, 1, 13, 3, 0) op_15 (v12[12:0], v14[8:0], v15[12:0]); // 21.0
    wire [13:0] v16; assign v16[13:0] = model_inp[130:117]; // 20.0
    wire [9:0] v17; assign v17[9:0] = model_inp[140:131]; // 20.0
    wire [13:0] v18; shift_adder #(14, 10, 1, 1, 14, 1, 1) op_18 (v16[13:0], v17[9:0], v18[13:0]); // 21.0
    wire [2:0] v19; assign v19[2:0] = model_inp[143:141]; // 20.0
    wire [9:0] v20; assign v20[9:0] = model_inp[153:144]; // 20.0
    wire [9:0] v21; shift_adder #(3, 10, 0, 1, 10, -3, 0) op_21 (v19[2:0], v20[9:0], v21[9:0]); // 21.0
    wire [8:0] v22; assign v22[8:0] = model_inp[162:154]; // 20.0
    wire [12:0] v23; assign v23[12:0] = model_inp[175:163]; // 20.0
    wire [14:0] v24; shift_adder #(9, 13, 0, 1, 15, -5, 0) op_24 (v22[8:0], v23[12:0], v24[14:0]); // 21.0
    wire [11:0] v25; assign v25[11:0] = model_inp[187:176]; // 20.0
    wire [12:0] v26; shift_adder #(12, 10, 1, 1, 13, -1, 1) op_26 (v25[11:0], v3[9:0], v26[12:0]); // 21.0
    wire [3:0] v27; assign v27[3:0] = model_inp[191:188]; // 20.0
    wire [12:0] v28; assign v28[12:0] = model_inp[204:192]; // 20.0
    wire [12:0] v29; shift_adder #(4, 13, 0, 1, 13, -4, 1) op_29 (v27[3:0], v28[12:0], v29[12:0]); // 21.0
    wire [12:0] v30; assign v30[12:0] = model_inp[217:205]; // 20.0
    wire [12:0] v31; shift_adder #(13, 10, 1, 1, 13, 0, 1) op_31 (v30[12:0], v17[9:0], v31[12:0]); // 21.0
    wire [7:0] v32; assign v32[7:0] = model_inp[225:218]; // 20.0
    wire [13:0] v33; shift_adder #(13, 8, 1, 0, 14, 4, 0) op_33 (v23[12:0], v32[7:0], v33[13:0]); // 21.0
    wire [13:0] v34; shift_adder #(8, 14, 0, 1, 14, -3, 0) op_34 (v32[7:0], v2[13:0], v34[13:0]); // 22.0
    wire [12:0] v35; assign v35[12:0] = v34[12:0] & {13{~v34[13]}}; // 22.0
    wire [12:0] v36; shift_adder #(13, 4, 0, 0, 13, 0, 0) op_36 (v35[12:0], 4'b1000, v36[12:0]); // 22.0
    wire [5:0] v37; assign v37[5:0] = v36[9:4]; // 22.0
    wire [16:0] v38; shift_adder #(14, 16, 1, 1, 17, -1, 0) op_38 (v8[13:0], v10[15:0], v38[16:0]); // 22.0
    wire [12:0] v39; assign v39[12:0] = model_inp[238:226]; // 20.0
    wire [13:0] v40; shift_adder #(13, 13, 1, 1, 14, 0, 1) op_40 (v13[12:0], v39[12:0], v40[13:0]); // 22.0
    wire [11:0] v41; shift_adder #(10, 9, 1, 1, 12, 2, 1) op_41 (v21[9:0], v14[8:0], v41[11:0]); // 22.0
    wire [3:0] v42; assign v42[3:0] = model_inp[242:239]; // 20.0
    wire [14:0] v43; shift_adder #(4, 15, 0, 1, 15, -4, 0) op_43 (v42[3:0], v24[14:0], v43[14:0]); // 22.0
    wire [12:0] v44; shift_adder #(13, 10, 1, 1, 13, 0, 1) op_44 (v26[12:0], v21[9:0], v44[12:0]); // 22.0
    wire [1:0] v45; assign v45[1:0] = model_inp[244:243]; // 20.0
    wire [12:0] v46; shift_adder #(2, 13, 0, 1, 13, -6, 1) op_46 (v45[1:0], v29[12:0], v46[12:0]); // 22.0
    wire [14:0] v47; shift_adder #(13, 14, 1, 1, 15, -2, 0) op_47 (v31[12:0], v33[13:0], v47[14:0]); // 22.0
    wire [2:0] v48; assign v48[2:0] = model_inp[247:245]; // 20.0
    wire [1:0] v49; assign v49[1:0] = model_inp[249:248]; // 20.0
    wire [1:0] v50; assign v50[1:0] = model_inp[251:250]; // 20.0
    wire [3:0] v51; assign v51[3:0] = model_inp[255:252]; // 20.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[5:0] = v37[5:0];
    assign model_out[8:6] = v48[2:0];
    assign model_out[19:9] = v5[10:0];
    assign model_out[36:20] = v38[16:0];
    assign model_out[50:37] = v40[13:0];
    assign model_out[63:51] = v15[12:0];
    assign model_out[77:64] = v18[13:0];
    assign model_out[89:78] = v41[11:0];
    assign model_out[91:90] = v49[1:0];
    assign model_out[106:92] = v43[14:0];
    assign model_out[108:107] = v50[1:0];
    assign model_out[121:109] = v46[12:0];
    assign model_out[125:122] = v51[3:0];
    assign model_out[138:126] = v44[12:0];
    assign model_out[153:139] = v47[14:0];

endmodule
