# usage: vivado -mode batch -source holdfix.tcl -tclargs <post_route.dcp> <outdir> <variant>
lassign $argv dcp out variant
file mkdir $out
open_checkpoint $dcp
set_param general.maxThreads 8
report_timing_summary -no_detailed_paths -file $out/before_timing_summary.rpt
report_timing -hold -max_paths 20 -nworst 1 -file $out/before_hold_paths.rpt
switch $variant {
  physopt_hold { phys_opt_design -directive ExploreWithHoldFix }
  reroute_aggr { route_design -directive AggressiveExplore -tns_cleanup }
  physopt_then_reroute { phys_opt_design -directive ExploreWithHoldFix; route_design -directive Explore -tns_cleanup }
}
report_timing_summary -file $out/post_fix_timing_summary.rpt
report_utilization -file $out/post_fix_util.rpt
write_checkpoint -force $out/post_fix.dcp
set wns [get_property SLACK [get_timing_paths -setup]]
set whs [get_property SLACK [get_timing_paths -hold]]
set wpws [get_property SLACK [get_timing_paths -setup -max_paths 1 -nworst 1]]
puts "RESULT variant=$variant WNS=$wns WHS=$whs"
if {$wns >= 0 && $whs >= 0} {
  write_bitstream -force -bin_file $out/x300.bit
  puts "RESULT bitstream written"
} else { puts "RESULT not closed, no bitstream" }
