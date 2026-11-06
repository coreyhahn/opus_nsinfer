`timescale 1 ns / 1 ps

module jsc (
    input clk,
    input [149:0] model_inp,
    output reg [79:0] model_out
);

    reg [149:0] stage0_inp;
    reg [2376:0] stage1_inp;
    reg [1231:0] stage2_inp;
    reg [1300:0] stage3_inp;
    reg [1689:0] stage4_inp;
    reg [798:0] stage5_inp;
    reg [629:0] stage6_inp;
    reg [1144:0] stage7_inp;
    reg [536:0] stage8_inp;
    reg [307:0] stage9_inp;
    reg [301:0] stage10_inp;
    reg [183:0] stage11_inp;
    reg [104:0] stage12_inp;
    wire [2376:0] stage0_out;
    wire [1231:0] stage1_out;
    wire [1300:0] stage2_out;
    wire [1689:0] stage3_out;
    wire [798:0] stage4_out;
    wire [629:0] stage5_out;
    wire [1144:0] stage6_out;
    wire [536:0] stage7_out;
    wire [307:0] stage8_out;
    wire [301:0] stage9_out;
    wire [183:0] stage10_out;
    wire [104:0] stage11_out;
    wire [79:0] stage12_out;

    jsc_stage0 stage0 (.model_inp(stage0_inp), .model_out(stage0_out));
    jsc_stage1 stage1 (.model_inp(stage1_inp), .model_out(stage1_out));
    jsc_stage2 stage2 (.model_inp(stage2_inp), .model_out(stage2_out));
    jsc_stage3 stage3 (.model_inp(stage3_inp), .model_out(stage3_out));
    jsc_stage4 stage4 (.model_inp(stage4_inp), .model_out(stage4_out));
    jsc_stage5 stage5 (.model_inp(stage5_inp), .model_out(stage5_out));
    jsc_stage6 stage6 (.model_inp(stage6_inp), .model_out(stage6_out));
    jsc_stage7 stage7 (.model_inp(stage7_inp), .model_out(stage7_out));
    jsc_stage8 stage8 (.model_inp(stage8_inp), .model_out(stage8_out));
    jsc_stage9 stage9 (.model_inp(stage9_inp), .model_out(stage9_out));
    jsc_stage10 stage10 (.model_inp(stage10_inp), .model_out(stage10_out));
    jsc_stage11 stage11 (.model_inp(stage11_inp), .model_out(stage11_out));
    jsc_stage12 stage12 (.model_inp(stage12_inp), .model_out(stage12_out));

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
        model_out <= stage12_out;
    end
endmodule
