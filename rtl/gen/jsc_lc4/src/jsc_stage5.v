`timescale 1 ns / 1 ps

module jsc_stage5 (
    input [301:0] model_inp,
    output [104:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [12:0] v0; assign v0[12:0] = model_inp[12:0]; // 20.0
    wire [8:0] v1; assign v1[8:0] = model_inp[21:13]; // 20.0
    wire [14:0] v2; shift_adder #(13, 9, 1, 1, 15, -2, 1) op_2 (v0[12:0], v1[8:0], v2[14:0]); // 21.0
    wire [11:0] v3; assign v3[11:0] = model_inp[33:22]; // 20.0
    wire [12:0] v4; shift_adder #(9, 12, 1, 1, 13, -3, 0) op_4 (v1[8:0], v3[11:0], v4[12:0]); // 21.0
    wire [7:0] v5; assign v5[7:0] = model_inp[41:34]; // 20.0
    wire [9:0] v6; assign v6[9:0] = model_inp[51:42]; // 20.0
    wire [10:0] v7; shift_adder #(8, 10, 1, 0, 11, -1, 1) op_7 (v5[7:0], v6[9:0], v7[10:0]); // 21.0
    wire [2:0] v8; assign v8[2:0] = model_inp[54:52]; // 20.0
    wire [7:0] v9; assign v9[7:0] = model_inp[62:55]; // 20.0
    wire [8:0] v10; shift_adder #(3, 8, 0, 0, 9, -1, 1) op_10 (v8[2:0], v9[7:0], v10[8:0]); // 21.0
    wire [9:0] v11; assign v11[9:0] = model_inp[72:63]; // 20.0
    wire [9:0] v12; assign v12[9:0] = model_inp[82:73]; // 20.0
    wire [10:0] v13; shift_adder #(10, 10, 1, 1, 11, 0, 0) op_13 (v11[9:0], v12[9:0], v13[10:0]); // 21.0
    wire [11:0] v14; assign v14[11:0] = model_inp[94:83]; // 20.0
    wire [13:0] v15; assign v15[13:0] = model_inp[108:95]; // 20.0
    wire [14:0] v16; shift_adder #(12, 14, 1, 1, 15, -2, 0) op_16 (v14[11:0], v15[13:0], v16[14:0]); // 21.0
    wire [5:0] v17; assign v17[5:0] = model_inp[114:109]; // 20.0
    wire [11:0] v18; assign v18[11:0] = model_inp[126:115]; // 20.0
    wire [11:0] v19; shift_adder #(6, 12, 0, 1, 12, 0, 1) op_19 (v17[5:0], v18[11:0], v19[11:0]); // 21.0
    wire [10:0] v20; assign v20[10:0] = model_inp[137:127]; // 20.0
    wire [5:0] v21; assign v21[5:0] = model_inp[143:138]; // 20.0
    wire [11:0] v22; shift_adder #(11, 6, 1, 0, 12, 2, 1) op_22 (v20[10:0], v21[5:0], v22[11:0]); // 21.0
    wire [11:0] v23; assign v23[11:0] = model_inp[155:144]; // 20.0
    wire [13:0] v24; assign v24[13:0] = model_inp[169:156]; // 20.0
    wire [13:0] v25; shift_adder #(12, 14, 1, 1, 14, 0, 0) op_25 (v23[11:0], v24[13:0], v25[13:0]); // 21.0
    wire [9:0] v26; assign v26[9:0] = model_inp[179:170]; // 20.0
    wire [11:0] v27; shift_adder #(12, 10, 1, 1, 12, 0, 0) op_27 (v23[11:0], v26[9:0], v27[11:0]); // 21.0
    wire [6:0] v28; assign v28[6:0] = model_inp[186:180]; // 20.0
    wire [8:0] v29; shift_adder #(7, 8, 0, 1, 9, 1, 0) op_29 (v28[6:0], v5[7:0], v29[8:0]); // 21.0
    wire [8:0] v30; assign v30[8:0] = model_inp[195:187]; // 20.0
    wire [11:0] v31; assign v31[11:0] = model_inp[207:196]; // 20.0
    wire [12:0] v32; shift_adder #(9, 12, 1, 0, 13, -1, 1) op_32 (v30[8:0], v31[11:0], v32[12:0]); // 21.0
    wire [8:0] v33; shift_adder #(8, 9, 1, 1, 9, 0, 0) op_33 (v5[7:0], v30[8:0], v33[8:0]); // 21.0
    wire [9:0] v34; assign v34[9:0] = model_inp[217:208]; // 20.0
    wire [11:0] v35; assign v35[11:0] = model_inp[229:218]; // 20.0
    wire [11:0] v36; shift_adder #(10, 12, 1, 1, 12, 0, 0) op_36 (v34[9:0], v35[11:0], v36[11:0]); // 21.0
    wire [9:0] v37; assign v37[9:0] = model_inp[239:230]; // 20.0
    wire [11:0] v38; shift_adder #(10, 10, 1, 0, 12, 1, 0) op_38 (v11[9:0], v37[9:0], v38[11:0]); // 21.0
    wire [9:0] v39; assign v39[9:0] = model_inp[249:240]; // 20.0
    wire [7:0] v40; assign v40[7:0] = model_inp[257:250]; // 20.0
    wire [10:0] v41; shift_adder #(10, 8, 1, 1, 11, 2, 1) op_41 (v39[9:0], v40[7:0], v41[10:0]); // 21.0
    wire [12:0] v42; assign v42[12:0] = model_inp[270:258]; // 20.0
    wire [13:0] v43; shift_adder #(13, 12, 1, 1, 14, 2, 0) op_43 (v42[12:0], v14[11:0], v43[13:0]); // 21.0
    wire [12:0] v44; assign v44[12:0] = model_inp[283:271]; // 20.0
    wire [12:0] v45; shift_adder #(7, 13, 0, 1, 13, -2, 1) op_45 (v28[6:0], v44[12:0], v45[12:0]); // 21.0
    wire [15:0] v46; shift_adder #(15, 13, 1, 1, 16, 1, 0) op_46 (v2[14:0], v4[12:0], v46[15:0]); // 22.0
    wire [12:0] v47; shift_adder #(11, 9, 1, 1, 13, 4, 0) op_47 (v7[10:0], v10[8:0], v47[12:0]); // 22.0
    wire [14:0] v48; shift_adder #(15, 9, 1, 1, 15, 2, 1) op_48 (v16[14:0], v10[8:0], v48[14:0]); // 22.0
    wire [4:0] v49; assign v49[4:0] = model_inp[288:284]; // 20.0
    wire [11:0] v50; shift_adder #(5, 12, 0, 1, 12, 0, 0) op_50 (v49[4:0], v19[11:0], v50[11:0]); // 22.0
    wire [13:0] v51; shift_adder #(12, 10, 1, 0, 14, -2, 1) op_51 (v22[11:0], v37[9:0], v51[13:0]); // 22.0
    wire [15:0] v52; shift_adder #(14, 12, 1, 1, 16, 4, 1) op_52 (v25[13:0], v27[11:0], v52[15:0]); // 22.0
    wire [4:0] v53; assign v53[4:0] = model_inp[293:289]; // 20.0
    wire [9:0] v54; shift_adder #(5, 9, 0, 1, 10, -1, 1) op_54 (v53[4:0], v29[8:0], v54[9:0]); // 22.0
    wire [13:0] v55; shift_adder #(13, 9, 1, 1, 14, -1, 1) op_55 (v32[12:0], v33[8:0], v55[13:0]); // 22.0
    wire [14:0] v56; shift_adder #(12, 12, 1, 1, 15, 2, 0) op_56 (v36[11:0], v38[11:0], v56[14:0]); // 22.0
    wire [12:0] v57; shift_adder #(11, 10, 1, 1, 13, -1, 1) op_57 (v41[10:0], v12[9:0], v57[12:0]); // 22.0
    wire [13:0] v58; shift_adder #(14, 9, 1, 1, 14, 0, 1) op_58 (v43[13:0], v29[8:0], v58[13:0]); // 22.0
    wire [12:0] v59; shift_adder #(6, 13, 0, 1, 13, 0, 0) op_59 (v17[5:0], v45[12:0], v59[12:0]); // 22.0
    wire [13:0] v60; shift_adder #(13, 11, 1, 1, 14, 1, 1) op_60 (v47[12:0], v13[10:0], v60[13:0]); // 23.0
    wire [14:0] v61; shift_adder #(12, 14, 1, 1, 15, -2, 0) op_61 (v50[11:0], v51[13:0], v61[14:0]); // 23.0
    wire [15:0] v62; shift_adder #(16, 12, 1, 1, 16, 2, 1) op_62 (v52[15:0], v50[11:0], v62[15:0]); // 23.0
    wire [4:0] v63; assign v63[4:0] = model_inp[298:294]; // 20.0
    wire [9:0] v64; shift_adder #(5, 10, 0, 1, 10, -2, 1) op_64 (v63[4:0], v54[9:0], v64[9:0]); // 23.0
    wire [14:0] v65; shift_adder #(14, 15, 1, 1, 15, 0, 0) op_65 (v55[13:0], v56[14:0], v65[14:0]); // 23.0
    wire [14:0] v66; shift_adder #(13, 14, 1, 1, 15, 0, 0) op_66 (v57[12:0], v58[13:0], v66[14:0]); // 23.0
    wire [15:0] v67; shift_adder #(13, 13, 1, 1, 16, -3, 1) op_67 (v59[12:0], v59[12:0], v67[15:0]); // 23.0
    wire [15:0] v68; shift_adder #(16, 14, 1, 1, 16, 1, 0) op_68 (v46[15:0], v60[13:0], v68[15:0]); // 24.0
    wire [15:0] v69; shift_adder #(16, 6, 1, 0, 16, 0, 1) op_69 (v68[15:0], 6'b111000, v69[15:0]); // 24.0
    wire [14:0] v70; shift_adder #(15, 15, 1, 1, 15, 0, 0) op_70 (v48[14:0], v61[14:0], v70[14:0]); // 24.0
    wire [2:0] v71; assign v71[2:0] = model_inp[301:299]; // 20.0
    wire [10:0] v72; shift_adder #(3, 10, 0, 1, 11, -5, 0) op_72 (v71[2:0], v64[9:0], v72[10:0]); // 24.0
    wire [15:0] v73; shift_adder #(15, 16, 1, 1, 16, 0, 0) op_73 (v66[14:0], v67[15:0], v73[15:0]); // 24.0
    wire [15:0] v74; shift_adder #(16, 7, 1, 0, 16, 0, 1) op_74 (v73[15:0], 7'b1000000, v74[15:0]); // 24.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[15:0] = v62[15:0];
    assign model_out[26:16] = v72[10:0];
    assign model_out[41:27] = v65[14:0];
    assign model_out[57:42] = v73[15:0];
    assign model_out[73:58] = v69[15:0];
    assign model_out[88:74] = v70[14:0];
    assign model_out[104:89] = v74[15:0];

endmodule
