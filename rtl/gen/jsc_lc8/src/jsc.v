`timescale 1 ns / 1 ps

module jsc (
    input clk,
    input [149:0] model_inp,
    output reg [79:0] model_out
);

    reg [149:0] stage0_inp;
    reg [1812:0] stage1_inp;
    reg [1144:0] stage2_inp;
    reg [260:0] stage3_inp;
    wire [1812:0] stage0_out;
    wire [1144:0] stage1_out;
    wire [260:0] stage2_out;
    wire [79:0] stage3_out;

    jsc_stage0 stage0 (.model_inp(stage0_inp), .model_out(stage0_out));
    jsc_stage1 stage1 (.model_inp(stage1_inp), .model_out(stage1_out));
    jsc_stage2 stage2 (.model_inp(stage2_inp), .model_out(stage2_out));
    jsc_stage3 stage3 (.model_inp(stage3_inp), .model_out(stage3_out));

    always @(posedge clk) begin
        stage0_inp <= model_inp;
        stage1_inp <= stage0_out;
        stage2_inp <= stage1_out;
        stage3_inp <= stage2_out;
        model_out <= stage3_out;
    end
endmodule
