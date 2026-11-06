`timescale 1 ns / 1 ps

module jsc_stage17 (
    input [353:0] model_inp,
    output [307:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [9:0] v0; assign v0[9:0] = model_inp[9:0]; // 17.0
    wire [5:0] v1; assign v1[5:0] = model_inp[15:10]; // 17.0
    wire [10:0] v2; shift_adder #(10, 6, 1, 0, 11, 1, 1) op_2 (v0[9:0], v1[5:0], v2[10:0]); // 18.0
    wire [9:0] v3; assign v3[9:0] = model_inp[25:16]; // 17.0
    wire [7:0] v4; assign v4[7:0] = model_inp[33:26]; // 17.0
    wire [11:0] v5; shift_adder #(10, 8, 0, 0, 12, 3, 0) op_5 (v3[9:0], v4[7:0], v5[11:0]); // 18.0
    wire [14:0] v6; assign v6[14:0] = model_inp[48:34]; // 17.0
    wire [12:0] v7; assign v7[12:0] = model_inp[61:49]; // 17.0
    wire [15:0] v8; shift_adder #(15, 13, 1, 1, 16, 1, 1) op_8 (v6[14:0], v7[12:0], v8[15:0]); // 18.0
    wire [15:0] v9; shift_adder #(16, 7, 1, 0, 16, 0, 1) op_9 (v8[15:0], 7'b1100000, v9[15:0]); // 18.0
    wire [14:0] v10; assign v10[14:0] = v9[14:0] & {15{~v9[15]}}; // 18.0
    wire [14:0] v11; shift_adder #(15, 4, 0, 0, 15, 0, 0) op_11 (v10[14:0], 4'b1000, v11[14:0]); // 18.0
    wire [8:0] v12; assign v12[8:0] = v11[12:4]; // 18.0
    wire [13:0] v13; assign v13[13:0] = model_inp[75:62]; // 17.0
    wire [15:0] v14; assign v14[15:0] = model_inp[91:76]; // 17.0
    wire [15:0] v15; shift_adder #(14, 16, 1, 1, 16, 0, 0) op_15 (v13[13:0], v14[15:0], v15[15:0]); // 18.0
    wire [15:0] v16; shift_adder #(16, 8, 1, 0, 16, 0, 0) op_16 (v15[15:0], 8'b10000000, v16[15:0]); // 18.0
    wire [14:0] v17; assign v17[14:0] = v16[14:0] & {15{~v16[15]}}; // 18.0
    wire [14:0] v18; shift_adder #(15, 6, 0, 0, 15, 0, 0) op_18 (v17[14:0], 6'b100000, v18[14:0]); // 18.0
    wire [6:0] v19; assign v19[6:0] = v18[12:6]; // 18.0
    wire [11:0] v20; assign v20[11:0] = model_inp[103:92]; // 17.0
    wire [14:0] v21; assign v21[14:0] = model_inp[118:104]; // 17.0
    wire [14:0] v22; shift_adder #(12, 15, 1, 1, 15, 0, 0) op_22 (v20[11:0], v21[14:0], v22[14:0]); // 18.0
    wire [13:0] v23; assign v23[13:0] = v22[13:0] & {14{~v22[14]}}; // 18.0
    wire [13:0] v24; shift_adder #(14, 4, 0, 0, 14, 0, 0) op_24 (v23[13:0], 4'b1000, v24[13:0]); // 18.0
    wire [6:0] v25; assign v25[6:0] = v24[10:4]; // 18.0
    wire [12:0] v26; assign v26[12:0] = model_inp[131:119]; // 17.0
    wire [15:0] v27; assign v27[15:0] = model_inp[147:132]; // 17.0
    wire [16:0] v28; shift_adder #(13, 16, 1, 1, 17, 0, 0) op_28 (v26[12:0], v27[15:0], v28[16:0]); // 18.0
    wire [16:0] v29; shift_adder #(17, 7, 1, 0, 17, 0, 0) op_29 (v28[16:0], 7'b1110000, v29[16:0]); // 18.0
    wire [13:0] v30; assign v30[13:0] = v29[13:0] & {14{~v29[16]}}; // 18.0
    wire [13:0] v31; shift_adder #(14, 4, 0, 0, 14, 0, 0) op_31 (v30[13:0], 4'b1000, v31[13:0]); // 18.0
    wire [6:0] v32; assign v32[6:0] = v31[10:4]; // 18.0
    wire [4:0] v33; assign v33[4:0] = model_inp[152:148]; // 17.0
    wire [8:0] v34; shift_adder #(5, 8, 0, 0, 9, -2, 0) op_34 (v33[4:0], v4[7:0], v34[8:0]); // 18.0
    wire [12:0] v35; assign v35[12:0] = model_inp[165:153]; // 17.0
    wire [13:0] v36; assign v36[13:0] = model_inp[179:166]; // 17.0
    wire [14:0] v37; shift_adder #(13, 14, 1, 1, 15, -1, 0) op_37 (v35[12:0], v36[13:0], v37[14:0]); // 18.0
    wire [4:0] v38; assign v38[4:0] = model_inp[184:180]; // 17.0
    wire [4:0] v39; assign v39[4:0] = model_inp[189:185]; // 17.0
    wire [8:0] v40; shift_adder #(5, 5, 0, 0, 9, -3, 0) op_40 (v38[4:0], v39[4:0], v40[8:0]); // 18.0
    wire [14:0] v41; assign v41[14:0] = model_inp[204:190]; // 17.0
    wire [15:0] v42; shift_adder #(13, 15, 1, 1, 16, -1, 0) op_42 (v7[12:0], v41[14:0], v42[15:0]); // 18.0
    wire [13:0] v43; assign v43[13:0] = v42[13:0] & {14{~v42[15]}}; // 18.0
    wire [13:0] v44; shift_adder #(14, 5, 0, 0, 14, 0, 0) op_44 (v43[13:0], 5'b10000, v44[13:0]); // 18.0
    wire [6:0] v45; assign v45[6:0] = v44[11:5]; // 18.0
    wire [7:0] v46; assign v46[7:0] = model_inp[212:205]; // 17.0
    wire [5:0] v47; assign v47[5:0] = model_inp[218:213]; // 17.0
    wire [8:0] v48; shift_adder #(8, 6, 0, 0, 9, 1, 1) op_48 (v46[7:0], v47[5:0], v48[8:0]); // 18.0
    wire [6:0] v49; shift_adder #(5, 5, 0, 0, 7, 1, 0) op_49 (v38[4:0], v39[4:0], v49[6:0]); // 18.0
    wire [5:0] v50; assign v50[5:0] = model_inp[224:219]; // 17.0
    wire [7:0] v51; assign v51[7:0] = model_inp[232:225]; // 17.0
    wire [7:0] v52; shift_adder #(6, 8, 0, 0, 8, 0, 0) op_52 (v50[5:0], v51[7:0], v52[7:0]); // 18.0
    wire [4:0] v53; assign v53[4:0] = model_inp[237:233]; // 17.0
    wire [8:0] v54; shift_adder #(5, 5, 0, 0, 9, -3, 0) op_54 (v53[4:0], v38[4:0], v54[8:0]); // 18.0
    wire [7:0] v55; assign v55[7:0] = model_inp[245:238]; // 17.0
    wire [3:0] v56; assign v56[3:0] = model_inp[249:246]; // 17.0
    wire [7:0] v57; shift_adder #(8, 4, 1, 0, 8, 1, 1) op_57 (v55[7:0], v56[3:0], v57[7:0]); // 18.0
    wire [6:0] v58; assign v58[6:0] = model_inp[256:250]; // 17.0
    wire [8:0] v59; shift_adder #(7, 6, 0, 0, 9, -1, 1) op_59 (v58[6:0], v47[5:0], v59[8:0]); // 18.0
    wire [13:0] v60; assign v60[13:0] = model_inp[270:257]; // 17.0
    wire [10:0] v61; assign v61[10:0] = model_inp[281:271]; // 17.0
    wire [14:0] v62; shift_adder #(14, 11, 1, 1, 15, -1, 1) op_62 (v60[13:0], v61[10:0], v62[14:0]); // 18.0
    wire [13:0] v63; assign v63[13:0] = v62[13:0] & {14{~v62[14]}}; // 18.0
    wire [13:0] v64; shift_adder #(14, 3, 0, 0, 14, 0, 0) op_64 (v63[13:0], 3'b100, v64[13:0]); // 18.0
    wire [7:0] v65; assign v65[7:0] = v64[10:3]; // 18.0
    wire [9:0] v66; shift_adder #(7, 5, 0, 0, 10, -2, 1) op_66 (v58[6:0], v53[4:0], v66[9:0]); // 18.0
    wire [6:0] v67; assign v67[6:0] = model_inp[288:282]; // 17.0
    wire [7:0] v68; assign v68[7:0] = model_inp[296:289]; // 17.0
    wire [10:0] v69; shift_adder #(7, 8, 0, 1, 11, 3, 0) op_69 (v67[6:0], v68[7:0], v69[10:0]); // 18.0
    wire [3:0] v70; assign v70[3:0] = model_inp[300:297]; // 17.0
    wire [5:0] v71; shift_adder #(5, 4, 0, 0, 6, 1, 0) op_71 (v53[4:0], v70[3:0], v71[5:0]); // 18.0
    wire [2:0] v72; assign v72[2:0] = model_inp[303:301]; // 17.0
    wire [9:0] v73; shift_adder #(3, 7, 0, 0, 10, -7, 0) op_73 (v72[2:0], v67[6:0], v73[9:0]); // 18.0
    wire [4:0] v74; assign v74[4:0] = model_inp[308:304]; // 17.0
    wire [8:0] v75; assign v75[8:0] = model_inp[317:309]; // 17.0
    wire [8:0] v76; shift_adder #(5, 9, 0, 0, 9, 0, 0) op_76 (v74[4:0], v75[8:0], v76[8:0]); // 18.0
    wire [5:0] v77; shift_adder #(5, 5, 0, 0, 6, 0, 0) op_77 (v38[4:0], v39[4:0], v77[5:0]); // 18.0
    wire [6:0] v78; assign v78[6:0] = model_inp[324:318]; // 17.0
    wire [4:0] v79; assign v79[4:0] = model_inp[329:325]; // 17.0
    wire [4:0] v80; assign v80[4:0] = model_inp[334:330]; // 17.0
    wire [4:0] v81; assign v81[4:0] = model_inp[339:335]; // 17.0
    wire [6:0] v82; assign v82[6:0] = model_inp[346:340]; // 17.0
    wire [2:0] v83; assign v83[2:0] = model_inp[349:347]; // 17.0
    wire [3:0] v84; assign v84[3:0] = model_inp[353:350]; // 17.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[10:0] = v2[10:0];
    assign model_out[22:11] = v5[11:0];
    assign model_out[31:23] = v12[8:0];
    assign model_out[38:32] = v58[6:0];
    assign model_out[45:39] = v25[6:0];
    assign model_out[52:46] = v32[6:0];
    assign model_out[65:53] = v26[12:0];
    assign model_out[80:66] = v37[14:0];
    assign model_out[89:81] = v40[8:0];
    assign model_out[96:90] = v45[6:0];
    assign model_out[101:97] = v74[4:0];
    assign model_out[110:102] = v48[8:0];
    assign model_out[115:111] = v33[4:0];
    assign model_out[122:116] = v49[6:0];
    assign model_out[129:123] = v19[6:0];
    assign model_out[136:130] = v78[6:0];
    assign model_out[144:137] = v52[7:0];
    assign model_out[153:145] = v54[8:0];
    assign model_out[161:154] = v57[7:0];
    assign model_out[170:162] = v59[8:0];
    assign model_out[178:171] = v65[7:0];
    assign model_out[186:179] = v46[7:0];
    assign model_out[196:187] = v66[9:0];
    assign model_out[207:197] = v69[10:0];
    assign model_out[213:208] = v71[5:0];
    assign model_out[218:214] = v79[4:0];
    assign model_out[223:219] = v80[4:0];
    assign model_out[233:224] = v73[9:0];
    assign model_out[238:234] = v53[4:0];
    assign model_out[247:239] = v76[8:0];
    assign model_out[253:248] = v77[5:0];
    assign model_out[262:254] = v34[8:0];
    assign model_out[267:263] = v81[4:0];
    assign model_out[274:268] = v82[6:0];
    assign model_out[277:275] = v83[2:0];
    assign model_out[280:278] = v72[2:0];
    assign model_out[287:281] = v67[6:0];
    assign model_out[292:288] = v38[4:0];
    assign model_out[296:293] = v84[3:0];
    assign model_out[302:297] = v1[5:0];
    assign model_out[307:303] = v39[4:0];

endmodule
