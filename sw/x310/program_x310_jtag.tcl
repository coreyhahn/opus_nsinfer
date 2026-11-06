# program_x310_jtag.tcl: volatile JTAG load of an X310 bitstream (the FPGA's SRAM only; flash is never touched).
#
# Provenance: adapted from /home/cah/r2d2/code/fpga/ettus/program_x310.tcl (lab EME project, 2026-03-08; read only,
# not modified). Changes: bitstream path and JTAG target come from -tclargs instead of being hard-coded; the target
# must be named (the lab's script took the first target, and our hosts' hw_servers also see the ZCU102 and the
# BCU-1525 cards); the device must be an xc7k410t (X310) or nothing is programmed; no cfgmem / flash commands.
# UNTESTED: no X310 was reachable when this was written (2026-10-30).
#
# usage: vivado -mode batch -nojournal -source program_x310_jtag.tcl -tclargs <x300.bit> <target substring> [hw_server url]
#   target substring: part of the hw_target name, e.g. the X310's Digilent serial; "list" only lists targets.
if {[llength $argv] < 2} { puts "usage: -tclargs <bitfile> <target substring|list> \[hw_server url\]"; exit 2 }
lassign $argv bit want url
if {$url eq ""} { set url localhost:3121 }
if {$want ne "list" && ![file exists $bit]} { puts "ERROR: no bitfile $bit"; exit 2 }
open_hw_manager
connect_hw_server -url $url -allow_non_jtag
set targets [get_hw_targets]
puts "=== HW targets on $url ==="
foreach t $targets { puts "  $t" }
if {$want eq "list"} { close_hw_server; close_hw_manager; exit 0 }
set sel [lsearch -all -inline $targets *$want*]
if {[llength $sel] != 1} {
  puts "ERROR: '$want' matches [llength $sel] targets (need exactly 1): $sel"
  close_hw_server; close_hw_manager; exit 1
}
open_hw_target [lindex $sel 0]
set devs [get_hw_devices]
set dev ""
foreach d $devs {
  set part [get_property PART $d]
  puts "  device $d part $part"
  if {[string match xc7k410t* $part]} { set dev $d }
}
if {$dev eq ""} {
  puts "ERROR: no xc7k410t (X310) on [lindex $sel 0]; nothing programmed"
  close_hw_target; close_hw_server; close_hw_manager; exit 1
}
current_hw_device $dev
set_property PROGRAM.FILE $bit $dev
puts "=== Programming $dev with $bit (volatile, JTAG) ==="
program_hw_device $dev
refresh_hw_device $dev
puts "=== DONE: [get_property REGISTER.IR.BIT5_DONE $dev] (1 = DONE high) ==="
close_hw_target
close_hw_server
close_hw_manager
