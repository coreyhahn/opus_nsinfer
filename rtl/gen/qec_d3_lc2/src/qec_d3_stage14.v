`timescale 1 ns / 1 ps

module qec_d3_stage14 (
    input [34:0] model_inp,
    output [17:0] model_out
);

    // verilator lint_off UNUSEDSIGNAL
    // Explicit quantization operation will drop bits if exists

    wire [17:0] v0; assign v0[17:0] = model_inp[17:0]; // 28.0
    wire [16:0] v1; assign v1[16:0] = model_inp[34:18]; // 28.0
    wire [17:0] v2; shift_adder #(18, 17, 1, 1, 18, 0, 0) op_2 (v0[17:0], v1[16:0], v2[17:0]); // 29.0
    wire [17:0] v3; shift_adder #(18, 10, 1, 0, 18, 0, 1) op_3 (v2[17:0], 10'b1011100000, v3[17:0]); // 29.0

    // verilator lint_on UNUSEDSIGNAL

    assign model_out[17:0] = v3[17:0];

endmodule
