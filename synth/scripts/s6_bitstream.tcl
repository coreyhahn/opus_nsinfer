# Stage 6 bitstream from a finished s6_build.tcl run: post_route.dcp -> s6_top.bit (+ .ltx for the JTAG-AXI
# master). Volatile JTAG loading only: no .mcs/.bin, no cfgmem.
#   vivado -mode batch -nojournal -source s6_bitstream.tcl -tclargs <out_dir>
# Refuses unless: WNS/WHS/WPWS >= 0; the one-clock check passed (summary.json single_clock); and
# evidence/stage6/verilator/ holds at least two passing tb_s6_loop logs (two GT-model settings) of this cutoff,
# vector count and TX_REG/RX_REG on this build's exact shot ROM (shot_mem_sha256), plus the passing link logs
# (CLAUDE.md: no bitstream before bit-exact in Verilator). Never overwrites a .bit.
lassign $argv out_dir
set out_dir [file normalize $out_dir]
set proj [file normalize [file join [file dirname [info script]] ../..]]
set fh [open $out_dir/summary.json r]; set sj [read $fh]; close $fh
foreach k {wns_ns whs_ns wpws_ns} {
    if {![regexp "\"$k\": (-?\[0-9.\]+)" $sj -> v] || $v < 0} { puts "ERROR: summary.json $k not >= 0; timing not signed off"; exit 1 }
}
if {![regexp {"single_clock": true} $sj]} { puts "ERROR: one-clock check did not pass (clock_check.txt)"; exit 1 }
regexp {"d": ([0-9]+)} $sj -> d
regexp {"lc": "?([0-9][0-9A-Za-z]*)"?} $sj -> lc
regexp {"nvec": ([0-9]+)} $sj -> nvec
regexp {"tx_reg": ([0-9]+)} $sj -> txr
regexp {"rx_reg": ([0-9]+)} $sj -> rxr
set vs ""
if {[file exists $out_dir/vector_set.txt]} { set fh [open $out_dir/vector_set.txt r]; set vs _[string trim [read $fh]]; close $fh }
set rom_sha [lindex [exec sha256sum $out_dir/s3_shots.hex] 0]
set pat [expr {$d == 5 ? "$proj/evidence/stage6/verilator/s6d5_loop_lc${lc}${vs}_n${nvec}_t${txr}r${rxr}_*.log"
                       : "$proj/evidence/stage6/verilator/s6_loop_lc${lc}_n${nvec}_t${txr}r${rxr}_*.log"}]
set ok 0
foreach log [glob -nocomplain $pat] {
    set fh [open $log r]; set t [read $fh]; close $fh
    if {![regexp "shot_mem_sha256=$rom_sha" $t]} { puts "SIM_OTHER_ROM $log"; continue }
    if {[regexp {RESULT s6_loop[^\n]*fails=0\n} $t] && [regexp {\nPASS\n} $t]} { incr ok; puts "SIM_PASS $log" }
}
set lk 0
foreach log [glob -nocomplain $proj/evidence/stage6/verilator/s6_link_nl*_t*r*.log] {
    if {[string match *negscr* $log]} continue
    set fh [open $log r]; set t [read $fh]; close $fh
    if {[regexp {RESULT tb_s6_link[^\n]*fails=0\n} $t] && [regexp {\nPASS\n} $t]} { incr lk }
}
if {$ok < 2 || $lk < 4} { puts "ERROR: need 2 passing loop logs (have $ok) and 4 passing link logs (have $lk) for d$d lc$lc n$nvec t${txr}r${rxr}"; exit 1 }
set bit $out_dir/s6_top.bit
if {[file exists $bit]} { puts "ERROR: $bit exists; refusing to overwrite"; exit 1 }
open_checkpoint $out_dir/post_route.dcp
# re-check on the checkpoint itself (fresh numbers, not the build's summary): setup / hold slack and the one-clock rule
set wns2 [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
set whs2 [get_property SLACK [get_timing_paths -max_paths 1 -hold]]
set usr {}
foreach c [get_cells -hier -filter {REF_NAME == GTYE4_CHANNEL}] {
    foreach p {TXUSRCLK TXUSRCLK2 RXUSRCLK RXUSRCLK2} { lappend usr [get_property PARENT [get_nets -of_objects [get_pins $c/$p]]] }
}
set nusr [llength [lsort -unique $usr]]
set nib [llength [get_cells -hier -filter {REF_NAME == IBUFDS_GTE4}]]
puts "RECHECK wns=$wns2 whs=$whs2 usrclk_nets=$nusr ibufds_gte4=$nib channels=[llength [get_cells -hier -filter {REF_NAME == GTYE4_CHANNEL}]]"
report_timing_summary -no_detailed_paths -file $out_dir/timing_recheck_bitstream.rpt
if {$wns2 < 0 || $whs2 < 0 || $nusr != 1 || $nib != 1} { puts "ERROR: re-check on post_route.dcp failed"; exit 1 }
write_bitstream $bit
write_debug_probes -force $out_dir/s6_top.ltx
puts "BITSTREAM [file size $bit] B $bit [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S]"
