// Two parameterisations of tb_radio_ts as separate simulation tops (the UHD xsim flow takes no generics):
// tb_radio_ts_cg1 = the X310 image's radio0 (EN_COMP_GAIN_RX = 1, expected offset 6), tb_radio_ts_cg0 = control (0).
`timescale 1ns / 1ps
module tb_radio_ts_cg1;
  tb_radio_ts #(.EN_CG(1), .OFFSET_EXP(6)) t ();
endmodule
module tb_radio_ts_cg0;
  tb_radio_ts #(.EN_CG(0), .OFFSET_EXP(0)) t ();
endmodule
