# Stage 3 bitstream from a finished s3_build.tcl run: post_route.dcp -> s3_top.bit (+ .ltx for the
# JTAG-AXI master). Volatile JTAG loading only: no .mcs/.bin, no cfgmem.
#   vivado -mode batch -nojournal -source s3_bitstream.tcl -tclargs <out_dir>
# Refuses unless WNS/WHS/WPWS >= 0 and evidence/stage3/verilator/ (d = 3) or evidence/stage4/verilator/
# (d = 5, s3d5_loop_* logs) holds a PASS log of the loop at this cutoff on the build's vector set
# (CLAUDE.md: no bitstream before bit-exact in Verilator); refuses the TEST-ONLY d = 5 stand-in core;
# never overwrites a .bit.
lassign $argv out_dir
set out_dir [file normalize $out_dir]
set proj [file normalize [file join [file dirname [info script]] ../..]]
set fh [open $out_dir/summary.json r]; set sj [read $fh]; close $fh
foreach k {wns_ns whs_ns wpws_ns} {
    if {![regexp "\"$k\": (-?\[0-9.\]+)" $sj -> v] || $v < 0} { puts "ERROR: summary.json $k not >= 0; timing not signed off"; exit 1 }
}
set d 3
regexp {"d": ([0-9]+)} $sj -> d
# lc is a cutoff (3) or a cutoff tag (3bc: broadcast-register core, add_bcast.py); never the stand-in
if {![regexp {"lc": "?([0-9][0-9A-Za-z]*)"?} $sj -> lc] || $lc eq "standin"} { puts "ERROR: not a cutoff (the d = 5 stand-in is TEST-ONLY)"; exit 1 }
regexp {"nvec": ([0-9]+)} $sj -> nvec
set ok 0
# d = 5: the passing loop log must be on this build's exact shot ROM (shot_mem_sha256 = sha256 of s3_shots.hex)
set vs ""
if {[file exists $out_dir/vector_set.txt]} { set fh [open $out_dir/vector_set.txt r]; set vs _[string trim [read $fh]]; close $fh }
set rom_sha [lindex [exec sha256sum $out_dir/s3_shots.hex] 0]
set pat [expr {$d == 5 ? "$proj/evidence/stage4/verilator/s3d5_loop_lc${lc}${vs}_n${nvec}_*.log"
                       : "$proj/evidence/stage3/verilator/s3_loop_lc${lc}_n${nvec}_*.log"}]
foreach log [glob -nocomplain $pat] {
    set fh [open $log r]; set t [read $fh]; close $fh
    if {$d == 5 && ![regexp "shot_mem_sha256=$rom_sha" $t]} { puts "SIM_OTHER_ROM $log"; continue }
    if {[regexp {RESULT s3_loop[^\n]*fails=0\n} $t] && [regexp {\nPASS\n} $t]} { incr ok; puts "SIM_PASS $log" }
}
if {$ok < 2} { puts "ERROR: need the passing Verilator loop logs (both clock orientations) for d$d lc$lc n$nvec"; exit 1 }
set bit $out_dir/s3_top.bit
if {[file exists $bit]} { puts "ERROR: $bit exists; refusing to overwrite"; exit 1 }
open_checkpoint $out_dir/post_route.dcp
write_bitstream $bit
write_debug_probes -force $out_dir/s3_top.ltx
puts "BITSTREAM [file size $bit] B $bit [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S]"
