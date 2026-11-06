`timescale 1 ns / 1 ps

module qec_d3 (
    input clk,
    input [47:0] model_inp,
    output reg [17:0] model_out
);

    reg [47:0] stage0_inp;
    reg [2363:0] stage1_inp;
    reg [255:0] stage2_inp;
    wire [2363:0] stage0_out;
    wire [255:0] stage1_out;
    wire [17:0] stage2_out;

    qec_d3_stage0 stage0 (.model_inp(stage0_inp), .model_out(stage0_out));
    qec_d3_stage1 stage1 (.model_inp(stage1_inp), .model_out(stage1_out));
    qec_d3_stage2 stage2 (.model_inp(stage2_inp), .model_out(stage2_out));

    always @(posedge clk) begin
        stage0_inp <= model_inp;
        stage1_inp <= stage0_out;
        stage2_inp <= stage1_out;
        model_out <= stage2_out;
    end
endmodule
