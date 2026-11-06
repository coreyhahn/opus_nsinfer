`timescale 1 ns / 1 ps

module qec_d3 (
    input clk,
    input [47:0] model_inp,
    output reg [17:0] model_out
);

    reg [47:0] stage0_inp;
    reg [2455:0] stage1_inp;
    reg [2268:0] stage2_inp;
    reg [1158:0] stage3_inp;
    reg [2341:0] stage4_inp;
    reg [2363:0] stage5_inp;
    reg [1206:0] stage6_inp;
    reg [563:0] stage7_inp;
    reg [417:0] stage8_inp;
    reg [337:0] stage9_inp;
    reg [255:0] stage10_inp;
    reg [153:0] stage11_inp;
    reg [91:0] stage12_inp;
    reg [54:0] stage13_inp;
    reg [34:0] stage14_inp;
    wire [2455:0] stage0_out;
    wire [2268:0] stage1_out;
    wire [1158:0] stage2_out;
    wire [2341:0] stage3_out;
    wire [2363:0] stage4_out;
    wire [1206:0] stage5_out;
    wire [563:0] stage6_out;
    wire [417:0] stage7_out;
    wire [337:0] stage8_out;
    wire [255:0] stage9_out;
    wire [153:0] stage10_out;
    wire [91:0] stage11_out;
    wire [54:0] stage12_out;
    wire [34:0] stage13_out;
    wire [17:0] stage14_out;

    qec_d3_stage0 stage0 (.model_inp(stage0_inp), .model_out(stage0_out));
    qec_d3_stage1 stage1 (.model_inp(stage1_inp), .model_out(stage1_out));
    qec_d3_stage2 stage2 (.model_inp(stage2_inp), .model_out(stage2_out));
    qec_d3_stage3 stage3 (.model_inp(stage3_inp), .model_out(stage3_out));
    qec_d3_stage4 stage4 (.model_inp(stage4_inp), .model_out(stage4_out));
    qec_d3_stage5 stage5 (.model_inp(stage5_inp), .model_out(stage5_out));
    qec_d3_stage6 stage6 (.model_inp(stage6_inp), .model_out(stage6_out));
    qec_d3_stage7 stage7 (.model_inp(stage7_inp), .model_out(stage7_out));
    qec_d3_stage8 stage8 (.model_inp(stage8_inp), .model_out(stage8_out));
    qec_d3_stage9 stage9 (.model_inp(stage9_inp), .model_out(stage9_out));
    qec_d3_stage10 stage10 (.model_inp(stage10_inp), .model_out(stage10_out));
    qec_d3_stage11 stage11 (.model_inp(stage11_inp), .model_out(stage11_out));
    qec_d3_stage12 stage12 (.model_inp(stage12_inp), .model_out(stage12_out));
    qec_d3_stage13 stage13 (.model_inp(stage13_inp), .model_out(stage13_out));
    qec_d3_stage14 stage14 (.model_inp(stage14_inp), .model_out(stage14_out));

    always @(posedge clk) begin
        stage0_inp <= model_inp;
        stage1_inp <= stage0_out;
        stage2_inp <= stage1_out;
        stage3_inp <= stage2_out;
        stage4_inp <= stage3_out;
        stage5_inp <= stage4_out;
        stage6_inp <= stage5_out;
        stage7_inp <= stage6_out;
        stage8_inp <= stage7_out;
        stage9_inp <= stage8_out;
        stage10_inp <= stage9_out;
        stage11_inp <= stage10_out;
        stage12_inp <= stage11_out;
        stage13_inp <= stage12_out;
        stage14_inp <= stage13_out;
        model_out <= stage14_out;
    end
endmodule
