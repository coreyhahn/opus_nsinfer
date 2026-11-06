`timescale 1 ns / 1 ps

module jsc (
    input clk,
    input [149:0] model_inp,
    output reg [79:0] model_out
);

    reg [149:0] stage0_inp;
    wire [79:0] stage0_out;

    jsc_stage0 stage0 (.model_inp(stage0_inp), .model_out(stage0_out));

    always @(posedge clk) begin
        stage0_inp <= model_inp;
        model_out <= stage0_out;
    end
endmodule
