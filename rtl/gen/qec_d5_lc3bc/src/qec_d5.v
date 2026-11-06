`timescale 1 ns / 1 ps

module qec_d5 (
    input clk,
    input [530:0] model_inp,
    output reg [21:0] model_out
);

    reg [530:0] stage0_inp;
    reg [530:0] stage0_bc;
    reg [25844:0] stage1_inp;
    reg [7059:0] stage2_inp;
    reg [1033:0] stage3_inp;
    reg [1033:0] stage3_bc;
    reg [21504:0] stage4_inp;
    reg [7487:0] stage5_inp;
    reg [1775:0] stage6_inp;
    reg [1775:0] stage6_bc;
    reg [5831:0] stage7_inp;
    reg [5831:0] stage7_bc;
    reg [8237:0] stage8_inp;
    reg [2677:0] stage9_inp;
    reg [730:0] stage10_inp;
    reg [239:0] stage11_inp;
    reg [57:0] stage12_inp;
    wire [25844:0] stage0_out;
    wire [7059:0] stage1_out;
    wire [1033:0] stage2_out;
    wire [21504:0] stage3_out;
    wire [7487:0] stage4_out;
    wire [1775:0] stage5_out;
    wire [5831:0] stage6_out;
    wire [8237:0] stage7_out;
    wire [2677:0] stage8_out;
    wire [730:0] stage9_out;
    wire [239:0] stage10_out;
    wire [57:0] stage11_out;
    wire [21:0] stage12_out;

    qec_d5_stage0 stage0 (.model_inp(stage0_bc), .model_out(stage0_out));
    qec_d5_stage1 stage1 (.model_inp(stage1_inp), .model_out(stage1_out));
    qec_d5_stage2 stage2 (.model_inp(stage2_inp), .model_out(stage2_out));
    qec_d5_stage3 stage3 (.model_inp(stage3_bc), .model_out(stage3_out));
    qec_d5_stage4 stage4 (.model_inp(stage4_inp), .model_out(stage4_out));
    qec_d5_stage5 stage5 (.model_inp(stage5_inp), .model_out(stage5_out));
    qec_d5_stage6 stage6 (.model_inp(stage6_bc), .model_out(stage6_out));
    qec_d5_stage7 stage7 (.model_inp(stage7_bc), .model_out(stage7_out));
    qec_d5_stage8 stage8 (.model_inp(stage8_inp), .model_out(stage8_out));
    qec_d5_stage9 stage9 (.model_inp(stage9_inp), .model_out(stage9_out));
    qec_d5_stage10 stage10 (.model_inp(stage10_inp), .model_out(stage10_out));
    qec_d5_stage11 stage11 (.model_inp(stage11_inp), .model_out(stage11_out));
    qec_d5_stage12 stage12 (.model_inp(stage12_inp), .model_out(stage12_out));

    always @(posedge clk) begin
        stage7_bc <= stage7_inp;
        stage6_bc <= stage6_inp;
        stage3_bc <= stage3_inp;
        stage0_bc <= stage0_inp;
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
