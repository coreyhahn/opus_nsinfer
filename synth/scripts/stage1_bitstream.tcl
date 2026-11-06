# Stage 1 bitstream from a finished stage1_build.tcl run: post_route.dcp -> zcu102_top.bit + zcu102_top.bin (Linux FPGA manager). Run only after the harness is bit-exact in Verilator.
#   vivado -mode batch -nojournal -source stage1_bitstream.tcl -tclargs <out_dir>
# Refuses to run unless <out_dir>/iob_check.rpt says IOB_CHECK PASS; never overwrites an existing .bit.
lassign $argv out_dir
set out_dir [file normalize $out_dir]
set fh [open $out_dir/iob_check.rpt r]; set iob [read $fh]; close $fh
if {![string match "*IOB_CHECK PASS*" $iob]} { puts "ERROR: $out_dir/iob_check.rpt is not PASS"; exit 1 }
set fh [open $out_dir/summary.json r]; set sj [read $fh]; close $fh
foreach k {wns_ns whs_ns wpws_ns} {
    if {![regexp "\"$k\": (-?\[0-9.\]+)" $sj -> v] || $v < 0} { puts "ERROR: summary.json $k is [expr {[info exists v] ? $v : {missing}}]; timing not signed off"; exit 1 }
}
set bit $out_dir/zcu102_top.bit
set bin $out_dir/zcu102_top.bin
if {[file exists $bit] || [file exists $bin]} { puts "ERROR: $bit or $bin exists; refusing to overwrite"; exit 1 }
open_checkpoint $out_dir/post_route.dcp
write_bitstream $bit
# Linux FPGA manager image: bootgen -process_bitstream bin (AMD's documented ZynqMP PL-programming
# flow; writes <bit>.bin, the byte-swapped raw bitstream without a boot header).
set bif $out_dir/zcu102_top.bif
set fh [open $bif w]
puts $fh "all:\n\{\n    \[destination_device = pl\] $bit\n\}"
close $fh
exec bootgen -image $bif -arch zynqmp -process_bitstream bin -w >@ stdout 2>@ stderr
file rename $bit.bin $bin
puts "BITSTREAM [file size $bit] B $bit; BIN [file size $bin] B $bin; [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S]"
