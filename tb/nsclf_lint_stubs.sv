// Lint-only black boxes for nsclf_block_lint, copied from evidence/stage5/toolchain/tap_probe/lint_stubs.sv
// (opus_nsinfer Stage 5 tap probe, 2026-10-29): the Vivado FIFO Generator IPs (top/x300/ip) and SRLC32E that
// the UHD noc_shell pulls in. Not used by any simulation.
module fifo_short_2clk (input wire rst, input wire wr_clk, input wire [71:0] din, input wire wr_en,
  output wire full, output wire [9:0] wr_data_count, input wire rd_clk, output wire [71:0] dout,
  input wire rd_en, output wire empty, output wire [9:0] rd_data_count);
  assign full = 1'b0; assign empty = 1'b1; assign dout = '0; assign wr_data_count = '0; assign rd_data_count = '0;
endmodule
module fifo_4k_2clk (input wire rst, input wire wr_clk, input wire [71:0] din, input wire wr_en,
  output wire full, output wire [11:0] wr_data_count, input wire rd_clk, output wire [71:0] dout,
  input wire rd_en, output wire empty, output wire [11:0] rd_data_count);
  assign full = 1'b0; assign empty = 1'b1; assign dout = '0; assign wr_data_count = '0; assign rd_data_count = '0;
endmodule
module SRLC32E #(parameter [31:0] INIT = 32'h0) (output wire Q, output wire Q31, input wire [4:0] A,
  input wire CE, input wire CLK, input wire D);
  reg [31:0] r = INIT;
  always @(posedge CLK) if (CE) r <= {r[30:0], D};
  assign Q = r[A]; assign Q31 = r[31];
endmodule
