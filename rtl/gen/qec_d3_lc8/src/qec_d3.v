`timescale 1 ns / 1 ps

module qec_d3 (
    input clk,
    input [47:0] model_inp,
    output reg [17:0] model_out
);

    reg [47:0] stage0_inp;
    reg [2341:0] stage1_inp;
    reg [417:0] stage2_inp;
    reg [91:0] stage3_inp;
    wire [2341:0] stage0_out;
    wire [417:0] stage1_out;
    wire [91:0] stage2_out;
    wire [17:0] stage3_out;

    qec_d3_stage0 stage0 (.model_inp(stage0_inp), .model_out(stage0_out));
    qec_d3_stage1 stage1 (.model_inp(stage1_inp), .model_out(stage1_out));
    qec_d3_stage2 stage2 (.model_inp(stage2_inp), .model_out(stage2_out));
    qec_d3_stage3 stage3 (.model_inp(stage3_inp), .model_out(stage3_out));

    always @(posedge clk) begin
        stage0_inp <= model_inp;
        stage1_inp <= stage0_out;
        stage2_inp <= stage1_out;
        stage3_inp <= stage2_out;
        model_out <= stage3_out;
    end
endmodule
