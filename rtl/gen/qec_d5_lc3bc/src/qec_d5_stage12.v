`timescale 1 ns / 1 ps

module qec_d5_stage12 (
    input [57:0] model_inp,
    output [21:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [18:0] v0; assign v0[18:0] = model_inp[18:0]; // 36.0
    wire [17:0] v1; assign v1[17:0] = model_inp[36:19]; // 36.0
    wire [19:0] v2; shift_adder #(19, 18, 1, 1, 20, 1, 1) op_2 (v0[18:0], v1[17:0], v2[19:0]); // 37.0
    wire [20:0] v3; assign v3[20:0] = model_inp[57:37]; // 36.0
    wire [21:0] v4; shift_adder #(21, 20, 1, 1, 22, 1, 0) op_4 (v3[20:0], v2[19:0], v4[21:0]); // 38.0
    wire [21:0] v5; shift_adder #(22, 11, 1, 0, 22, 0, 1) op_5 (v4[21:0], 11'b10000000000, v5[21:0]); // 38.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[21:0] = v5[21:0];

endmodule
