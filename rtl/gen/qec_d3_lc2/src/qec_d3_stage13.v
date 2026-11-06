`timescale 1 ns / 1 ps

module qec_d3_stage13 (
    input [54:0] model_inp,
    output [34:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [17:0] v0; assign v0[17:0] = model_inp[17:0]; // 26.0
    wire [9:0] v1; assign v1[9:0] = model_inp[27:18]; // 26.0
    wire [17:0] v2; shift_adder #(18, 10, 1, 0, 18, 6, 0) op_2 (v0[17:0], v1[9:0], v2[17:0]); // 27.0
    wire [13:0] v3; assign v3[13:0] = model_inp[41:28]; // 26.0
    wire [12:0] v4; assign v4[12:0] = model_inp[54:42]; // 26.0
    wire [16:0] v5; shift_adder #(14, 13, 1, 0, 17, 2, 1) op_5 (v3[13:0], v4[12:0], v5[16:0]); // 27.0
    wire [16:0] v6; shift_adder #(17, 10, 1, 0, 17, 0, 1) op_6 (v5[16:0], v1[9:0], v6[16:0]); // 28.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[17:0] = v2[17:0];
    assign model_out[34:18] = v6[16:0];

endmodule
