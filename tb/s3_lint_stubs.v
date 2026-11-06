// Lint-only stand-ins for primitives missing from verilator_lib (s3_top lint; never synthesised).
module BUFGCE_DIV #(parameter integer BUFGCE_DIVIDE = 1) (input I, input CE, input CLR, output O);
  assign O = I & CE & ~CLR;
endmodule
