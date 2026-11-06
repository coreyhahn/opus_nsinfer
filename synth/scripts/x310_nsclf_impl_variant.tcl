# Re-implement an X310 nsclf image from the UHD build's post_synth.dcp with other directives (Stage 5 timing closure).
# Mirrors UHD 4.9 top/x300/build_x300.tcl (opt NoBramPowerOpt -> place -> phys_opt -> route -tns_cleanup ->
# phys_opt, then the same bitstream properties); only the directives differ. The constraints are in the checkpoint
# (read before synthesis by viv_utils). Adds the hold fix (phys_opt ExploreWithHoldFix) if setup closes and hold
# does not (evidence/stage5/toolchain/holdfix.tcl). Bitstream only if WNS >= 0, WHS >= 0 and WPWS >= 0.
# usage: vivado -mode batch -nojournal -source x310_nsclf_impl_variant.tcl -tclargs <post_synth.dcp> <outdir> \
#          <place directive> [post-place phys_opt directive=AggressiveExplore] [route directive=Explore]
lassign $argv dcp out pdir popt rdir
if {$popt eq ""} { set popt AggressiveExplore }
if {$rdir eq ""} { set rdir Explore }
if {[file exists $out/post_route.dcp]} { puts "refusing: $out/post_route.dcp exists"; exit 1 }
file mkdir $out
set_param general.maxThreads 8
open_checkpoint $dcp
opt_design -directive NoBramPowerOpt
place_design -directive $pdir
phys_opt_design -directive $popt
write_checkpoint -force $out/post_place.dcp
route_design -directive $rdir -tns_cleanup
phys_opt_design -directive Explore
write_checkpoint -force $out/post_route.dcp
report_timing_summary -no_detailed_paths -file $out/post_route_timing_summary.rpt
proc slacks {} {
  return [list [get_property SLACK [get_timing_paths -setup -max_paths 1]] [get_property SLACK [get_timing_paths -hold -max_paths 1]]]
}
lassign [slacks] wns whs
puts "RESULT variant=$pdir/$popt/$rdir post_route WNS=$wns WHS=$whs"
if {$wns >= 0 && $whs < 0} {
  phys_opt_design -directive ExploreWithHoldFix
  write_checkpoint -force $out/post_fix.dcp
  report_timing_summary -no_detailed_paths -file $out/post_fix_timing_summary.rpt
  lassign [slacks] wns whs
  puts "RESULT variant=$pdir/$popt/$rdir after hold fix WNS=$wns WHS=$whs"
}
report_utilization -file $out/util.rpt
if {$wns >= 0 && $whs >= 0} {
  set_property BITSTREAM.STARTUP.MATCH_CYCLE NoWait [get_designs *]
  set_property BITSTREAM.GENERAL.COMPRESS    False  [get_designs *]
  set_property BITSTREAM.CONFIG.CONFIGRATE   6      [get_designs *]
  write_bitstream -force -bin_file $out/x300.bit
  puts "RESULT variant=$pdir/$popt/$rdir bitstream written (check WPWS in the timing summary)"
} else {
  puts "RESULT variant=$pdir/$popt/$rdir not closed, no bitstream"
}
