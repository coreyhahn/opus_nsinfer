// Frequency of a fast clock in units of a reference clock: cycles of clk_meas per 2^WIN cycles
// of clk_ref. A binary counter in clk_meas is Gray-coded, passed through 2 ASYNC_REG flops into
// clk_ref (one bit changes per clk_meas edge, so a sample is off by at most one count), converted
// back to binary and differenced every 2^WIN clk_ref cycles. Reads 0 until the second window ends.
module s3_freq #(
    parameter int WIN = 24
) (
    input  logic        clk_meas,
    input  logic        clk_ref,
    output logic [31:0] count     // clk_ref domain
);
  logic [31:0] bin = '0, gray = '0;
  always_ff @(posedge clk_meas) begin
    bin  <= bin + 32'd1;
    gray <= bin ^ (bin >> 1);
  end

  (* ASYNC_REG = "TRUE" *) logic [31:0] g_s1 = '0, g_s2 = '0;
  logic [31:0] b_ref, b_prev = '0;
  logic [WIN-1:0] tick = '0;
  logic valid = 1'b0;
  logic [31:0] count_q = '0;
  assign count = count_q;
  always_comb begin
    for (int i = 0; i < 32; i++) b_ref[i] = ^(g_s2 >> i);   // Gray -> binary
  end
  always_ff @(posedge clk_ref) begin
    g_s1 <= gray;
    g_s2 <= g_s1;
    tick <= tick + 1'b1;
    if (tick == '1) begin
      b_prev <= b_ref;
      valid  <= 1'b1;
      count_q <= valid ? b_ref - b_prev : '0;
    end
  end
endmodule
