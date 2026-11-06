# v2 bitstream from the hold-fixed checkpoint with UHD's bitstream properties (as x310_nsclf_impl_variant.tcl)
open_checkpoint <repo>/.scratch/s5_build/x310_xg_nsclf_v2_lc2_1_holdfix_physopt_hold/post_fix.dcp
report_timing_summary -no_detailed_paths -file <repo>/.scratch/s5_build/x310_xg_nsclf_v2_lc2_1_holdfix_physopt_hold_bit/timing_summary.rpt
set_property BITSTREAM.STARTUP.MATCH_CYCLE NoWait [get_designs *]
set_property BITSTREAM.GENERAL.COMPRESS    False  [get_designs *]
set_property BITSTREAM.CONFIG.CONFIGRATE   6      [get_designs *]
write_bitstream -force -bin_file <repo>/.scratch/s5_build/x310_xg_nsclf_v2_lc2_1_holdfix_physopt_hold_bit/x300.bit
puts "RESULT bitstream written"
