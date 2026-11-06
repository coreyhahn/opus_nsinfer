# Targeted timing fix of a routed X310 nsclf checkpoint: unroute and delay-driven reroute the nets of every failing
# setup path (e.g. the DB1 ADC IDDR -> fabric max-delay paths), then phys_opt ExploreWithHoldFix for hold.
# Bitstream only if WNS >= 0 and WHS >= 0 (report_timing, not the phys_opt estimate).
# usage: vivado -mode batch -nojournal -source x310_nsclf_netfix.tcl -tclargs <routed .dcp> <outdir>
lassign $argv dcp out
if {[file exists $out/post_netfix.dcp]} { puts "refusing: $out/post_netfix.dcp exists"; exit 1 }
file mkdir $out
set_param general.maxThreads 8
open_checkpoint $dcp
proc slacks {} { return [list [get_property SLACK [get_timing_paths -setup -max_paths 1]] [get_property SLACK [get_timing_paths -hold -max_paths 1]]] }
puts "RESULT before WNS/WHS [slacks]"
set bad [get_timing_paths -setup -max_paths 50 -slack_lesser_than 0]
set nets [lsort -unique [get_nets -of [get_pins -of $bad]]]
puts "RESULT failing setup paths [llength $bad], nets to reroute: $nets"
route_design -unroute -nets $nets
route_design -nets $nets -delay
puts "RESULT after delay reroute WNS/WHS [slacks]"
lassign [slacks] wns whs
if {$whs < 0} { phys_opt_design -directive ExploreWithHoldFix; route_design -directive Explore; puts "RESULT after hold fix WNS/WHS [slacks]" }
write_checkpoint -force $out/post_netfix.dcp
report_timing_summary -file $out/post_netfix_timing_summary.rpt
lassign [slacks] wns whs
if {$wns >= 0 && $whs >= 0} {
  set_property BITSTREAM.STARTUP.MATCH_CYCLE NoWait [get_designs *]
  set_property BITSTREAM.GENERAL.COMPRESS    False  [get_designs *]
  set_property BITSTREAM.CONFIG.CONFIGRATE   6      [get_designs *]
  write_bitstream -force -bin_file $out/x300.bit
  puts "RESULT netfix bitstream written WNS=$wns WHS=$whs"
} else { puts "RESULT netfix not closed WNS=$wns WHS=$whs" }
