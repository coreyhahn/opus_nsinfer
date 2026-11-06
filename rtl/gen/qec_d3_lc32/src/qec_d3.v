`timescale 1 ns / 1 ps

module qec_d3 (
    input clk,
    input [47:0] model_inp,
    output reg [17:0] model_out
);

    reg [47:0] stage0_inp;
    wire [17:0] stage0_out;

    qec_d3_stage0 stage0 (.model_inp(stage0_inp), .model_out(stage0_out));

    always @(posedge clk) begin
        stage0_inp <= model_inp;
        model_out <= stage0_out;
    end
endmodule
