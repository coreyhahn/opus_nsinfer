`timescale 1 ns / 1 ps

module jsc (
    input clk,
    input [149:0] model_inp,
    output reg [79:0] model_out
);

    reg [149:0] stage0_inp;
    reg [1442:0] stage1_inp;
    reg [2376:0] stage2_inp;
    reg [1926:0] stage3_inp;
    reg [1231:0] stage4_inp;
    reg [914:0] stage5_inp;
    reg [1300:0] stage6_inp;
    reg [1812:0] stage7_inp;
    reg [1689:0] stage8_inp;
    reg [1251:0] stage9_inp;
    reg [798:0] stage10_inp;
    reg [508:0] stage11_inp;
    reg [629:0] stage12_inp;
    reg [1085:0] stage13_inp;
    reg [1144:0] stage14_inp;
    reg [886:0] stage15_inp;
    reg [536:0] stage16_inp;
    reg [353:0] stage17_inp;
    reg [307:0] stage18_inp;
    reg [301:0] stage19_inp;
    reg [301:0] stage20_inp;
    reg [260:0] stage21_inp;
    reg [183:0] stage22_inp;
    reg [134:0] stage23_inp;
    reg [104:0] stage24_inp;
    reg [89:0] stage25_inp;
    wire [1442:0] stage0_out;
    wire [2376:0] stage1_out;
    wire [1926:0] stage2_out;
    wire [1231:0] stage3_out;
    wire [914:0] stage4_out;
    wire [1300:0] stage5_out;
    wire [1812:0] stage6_out;
    wire [1689:0] stage7_out;
    wire [1251:0] stage8_out;
    wire [798:0] stage9_out;
    wire [508:0] stage10_out;
    wire [629:0] stage11_out;
    wire [1085:0] stage12_out;
    wire [1144:0] stage13_out;
    wire [886:0] stage14_out;
    wire [536:0] stage15_out;
    wire [353:0] stage16_out;
    wire [307:0] stage17_out;
    wire [301:0] stage18_out;
    wire [301:0] stage19_out;
    wire [260:0] stage20_out;
    wire [183:0] stage21_out;
    wire [134:0] stage22_out;
    wire [104:0] stage23_out;
    wire [89:0] stage24_out;
    wire [79:0] stage25_out;

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
    jsc_stage13 stage13 (.model_inp(stage13_inp), .model_out(stage13_out));
    jsc_stage14 stage14 (.model_inp(stage14_inp), .model_out(stage14_out));
    jsc_stage15 stage15 (.model_inp(stage15_inp), .model_out(stage15_out));
    jsc_stage16 stage16 (.model_inp(stage16_inp), .model_out(stage16_out));
    jsc_stage17 stage17 (.model_inp(stage17_inp), .model_out(stage17_out));
    jsc_stage18 stage18 (.model_inp(stage18_inp), .model_out(stage18_out));
    jsc_stage19 stage19 (.model_inp(stage19_inp), .model_out(stage19_out));
    jsc_stage20 stage20 (.model_inp(stage20_inp), .model_out(stage20_out));
    jsc_stage21 stage21 (.model_inp(stage21_inp), .model_out(stage21_out));
    jsc_stage22 stage22 (.model_inp(stage22_inp), .model_out(stage22_out));
    jsc_stage23 stage23 (.model_inp(stage23_inp), .model_out(stage23_out));
    jsc_stage24 stage24 (.model_inp(stage24_inp), .model_out(stage24_out));
    jsc_stage25 stage25 (.model_inp(stage25_inp), .model_out(stage25_out));

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
        stage17_inp <= stage16_out;
        stage18_inp <= stage17_out;
        stage19_inp <= stage18_out;
        stage20_inp <= stage19_out;
        stage21_inp <= stage20_out;
        stage22_inp <= stage21_out;
        stage23_inp <= stage22_out;
        stage24_inp <= stage23_out;
        stage25_inp <= stage24_out;
        model_out <= stage25_out;
    end
endmodule
