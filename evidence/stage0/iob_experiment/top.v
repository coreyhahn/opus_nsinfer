module top(input clk_p, input clk_n,
  input  hd_in,  output hd_out,   // PMOD (bank 47, HD)
  input  hp_in,  output hp_out);  // FMC HPC1 LA (bank 65 HP) for comparison
  wire clk_ibuf, clk;
  IBUFDS ib(.I(clk_p), .IB(clk_n), .O(clk_ibuf));
  BUFG bg(.I(clk_ibuf), .O(clk));
  (* IOB="TRUE" *) reg hd_r1, hd_r2, hp_r1, hp_r2;
  always @(posedge clk) begin hd_r1 <= hd_in; hd_r2 <= hd_r1; hp_r1 <= hp_in; hp_r2 <= hp_r1; end
  assign hd_out = hd_r2; assign hp_out = hp_r2;
endmodule
