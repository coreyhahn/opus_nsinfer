`timescale 1 ns / 1 ps

module x310_clf (
    input clk,
    input [2047:0] model_inp,
    output reg [64:0] model_out
);

    reg [2047:0] stage0_inp;
    reg [386:0] stage1_inp;
    reg [3816:0] stage2_inp;
    reg [2405:0] stage3_inp;
    reg [853:0] stage4_inp;
    reg [1696:0] stage5_inp;
    reg [1626:0] stage6_inp;
    reg [826:0] stage7_inp;
    reg [616:0] stage8_inp;
    reg [820:0] stage9_inp;
    reg [541:0] stage10_inp;
    reg [337:0] stage11_inp;
    reg [309:0] stage12_inp;
    reg [256:0] stage13_inp;
    reg [222:0] stage14_inp;
    reg [221:0] stage15_inp;
    reg [119:0] stage16_inp;
    wire [386:0] stage0_out;
    wire [3816:0] stage1_out;
    wire [2405:0] stage2_out;
    wire [853:0] stage3_out;
    wire [1696:0] stage4_out;
    wire [1626:0] stage5_out;
    wire [826:0] stage6_out;
    wire [616:0] stage7_out;
    wire [820:0] stage8_out;
    wire [541:0] stage9_out;
    wire [337:0] stage10_out;
    wire [309:0] stage11_out;
    wire [256:0] stage12_out;
    wire [222:0] stage13_out;
    wire [221:0] stage14_out;
    wire [119:0] stage15_out;
    wire [64:0] stage16_out;

    x310_clf_stage0 stage0 (.model_inp(stage0_inp), .model_out(stage0_out));
    x310_clf_stage1 stage1 (.model_inp(stage1_inp), .model_out(stage1_out));
    x310_clf_stage2 stage2 (.model_inp(stage2_inp), .model_out(stage2_out));
    x310_clf_stage3 stage3 (.model_inp(stage3_inp), .model_out(stage3_out));
    x310_clf_stage4 stage4 (.model_inp(stage4_inp), .model_out(stage4_out));
    x310_clf_stage5 stage5 (.model_inp(stage5_inp), .model_out(stage5_out));
    x310_clf_stage6 stage6 (.model_inp(stage6_inp), .model_out(stage6_out));
    x310_clf_stage7 stage7 (.model_inp(stage7_inp), .model_out(stage7_out));
    x310_clf_stage8 stage8 (.model_inp(stage8_inp), .model_out(stage8_out));
    x310_clf_stage9 stage9 (.model_inp(stage9_inp), .model_out(stage9_out));
    x310_clf_stage10 stage10 (.model_inp(stage10_inp), .model_out(stage10_out));
    x310_clf_stage11 stage11 (.model_inp(stage11_inp), .model_out(stage11_out));
    x310_clf_stage12 stage12 (.model_inp(stage12_inp), .model_out(stage12_out));
    x310_clf_stage13 stage13 (.model_inp(stage13_inp), .model_out(stage13_out));
    x310_clf_stage14 stage14 (.model_inp(stage14_inp), .model_out(stage14_out));
    x310_clf_stage15 stage15 (.model_inp(stage15_inp), .model_out(stage15_out));
    x310_clf_stage16 stage16 (.model_inp(stage16_inp), .model_out(stage16_out));

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
        stage15_inp <= stage14_out;
        stage16_inp <= stage15_out;
        model_out <= stage16_out;
    end
endmodule
