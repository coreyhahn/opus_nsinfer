`timescale 1 ns / 1 ps

module qec_d3_stage9 (
    input [44:0] model_inp,
    output [17:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [16:0] v0; assign v0[16:0] = model_inp[16:0]; // 27.0
    wire [9:0] v1; assign v1[9:0] = model_inp[26:17]; // 27.0
    wire [16:0] v2; shift_adder #(17, 10, 1, 0, 17, 0, 1) op_2 (v0[16:0], v1[9:0], v2[16:0]); // 28.0
    wire [17:0] v3; assign v3[17:0] = model_inp[44:27]; // 27.0
    wire [17:0] v4; shift_adder #(18, 17, 1, 1, 18, 0, 0) op_4 (v3[17:0], v2[16:0], v4[17:0]); // 29.0
    wire [17:0] v5; shift_adder #(18, 10, 1, 0, 18, 0, 1) op_5 (v4[17:0], 10'b1011100000, v5[17:0]); // 29.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[17:0] = v5[17:0];

endmodule
