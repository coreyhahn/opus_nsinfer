# Fresh timing / utilisation reports of an X310 nsclf image checkpoint (Stage 5).
# usage: vivado -mode batch -nojournal -source x310_nsclf_report.tcl -tclargs <post_route or post_fix .dcp> <outdir>
lassign $argv dcp out
file mkdir $out
open_checkpoint $dcp
set f [open $out/summary.txt w]
puts $f "# checkpoint $dcp ([clock format [file mtime $dcp] -format %Y-%m-%dT%H:%M:%S]), report [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S]"
report_timing_summary -no_detailed_paths -file $out/timing_summary.rpt
report_utilization -file $out/util.rpt
report_utilization -hierarchical -hierarchical_depth 8 -file $out/util_hier.rpt
set wns  [get_property SLACK [get_timing_paths -setup -max_paths 1]]
set whs  [get_property SLACK [get_timing_paths -hold -max_paths 1]]
puts $f "overall WNS $wns WHS $whs"
# per clock: worst setup / hold path ending in that clock's domain
foreach c [lsort [get_clocks]] {
  set ps [get_timing_paths -setup -max_paths 1 -group $c -quiet]
  set ph [get_timing_paths -hold  -max_paths 1 -group $c -quiet]
  if {[llength $ps] == 0} continue
  puts $f [format "clock %-28s period %7.3f  WNS %8.3f  WHS %8.3f" $c [get_property PERIOD $c] [get_property SLACK $ps] [expr {[llength $ph] ? [get_property SLACK $ph] : "na"}]]
}
# the classifier block: worst setup / hold paths with any cell inside nsclf0
set blk [get_cells -hier -filter {NAME =~ *b_nsclf0_6 && IS_PRIMITIVE == 0}]
puts $f "nsclf0 cell: $blk"
# endpoints inside nsclf0 (paths internal to the block and paths entering it) and startpoints inside it
set regs [get_cells -hier -filter "NAME =~ $blk/* && IS_SEQUENTIAL"]
puts $f "nsclf0 sequential cells: [llength $regs]"
set ps [concat [get_timing_paths -setup -max_paths 10 -nworst 1 -to $regs -quiet] [get_timing_paths -setup -max_paths 3 -nworst 1 -from $regs -quiet]]
set ph [concat [get_timing_paths -hold  -max_paths 10 -nworst 1 -to $regs -quiet] [get_timing_paths -hold  -max_paths 3 -nworst 1 -from $regs -quiet]]
foreach p $ps { puts $f [format "nsclf setup %8.3f  %s -> %s  levels %s  group %s" [get_property SLACK $p] [get_property STARTPOINT_PIN $p] [get_property ENDPOINT_PIN $p] [get_property LOGIC_LEVELS $p] [get_property GROUP $p]] }
foreach p $ph { puts $f [format "nsclf hold  %8.3f  %s -> %s  group %s" [get_property SLACK $p] [get_property STARTPOINT_PIN $p] [get_property ENDPOINT_PIN $p] [get_property GROUP $p]] }
report_timing -max_paths 20 -nworst 1 -to $regs -file $out/nsclf_setup_paths.rpt
# the pulse width check (WPWS)
report_pulse_width -file $out/pulse_width.rpt
close $f
puts "REPORT done: $out/summary.txt"
