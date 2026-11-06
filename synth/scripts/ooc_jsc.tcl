# Out-of-context synthesis + place + route of a da4ml JSC core.
#   vivado -mode batch -nojournal -source ooc_jsc.tcl -tclargs <gen_dir> <part> <period_ns> <out_dir> [retime|-] [top] [wrap_file wrap_generics]
#   retime: synth_design -retiming (global register retiming); top: da4ml module name (default jsc,
#   Stage 2 uses qec_d3); wrap_file + wrap_generics (Stage 2: rtl/qec_d3_top.sv, "IN_W=24,OUT_W=..")
#   synthesise a hand-written wrapper around the core as the top (its module name = file stem)
#
# The da4ml core registers its inputs and its outputs, so every timed path is
# register to register; ports are left unconstrained (no IOBs in OOC). This is
# the same "OOC P&R" class as the published HGQ/da4ml numbers: it EXCLUDES the
# package pins, IOBs and any input/output path.
lassign $argv gen_dir part period out_dir opts top wrap_file wrap_generics
if {$top eq ""} { set top jsc }
set core $top
set gen_args {}
if {$wrap_file ne ""} {
    set top [file rootname [file tail $wrap_file]]
    foreach kv [split $wrap_generics ,] { lappend gen_args -generic $kv }
    set inc [list [file dirname $wrap_file]]
    # OOC_INCLUDE (env, ':'-separated): extra include dirs, e.g. Stage 4 rtl/ for qec_d5_in_map.svh
    if {[info exists ::env(OOC_INCLUDE)]} { lappend inc {*}[split $::env(OOC_INCLUDE) :] }
    lappend gen_args -include_dirs $inc
}
set retime [expr {$opts eq "retime"}]
file mkdir $out_dir
set_part $part
set_param general.maxThreads 4

read_verilog [glob $gen_dir/src/static/*.v]
read_verilog [glob $gen_dir/src/${core}_stage*.v]
read_verilog $gen_dir/src/$core.v
# OOC_EXTRA_SV (env, ':'-separated): more hand-written SV read before the wrapper (Stage 5: x310_clf_top.sv
# under the x310_stream.sv top)
if {[info exists ::env(OOC_EXTRA_SV)]} { foreach f [split $::env(OOC_EXTRA_SV) :] { read_verilog -sv $f } }
if {$wrap_file ne ""} { read_verilog -sv $wrap_file }

set xdc $out_dir/clock.xdc
set fh [open $xdc w]
puts $fh "create_clock -period $period -name clk \[get_ports clk\]"
close $fh
read_xdc -mode out_of_context $xdc

if {$retime} {
    synth_design -top $top -part $part -mode out_of_context -flatten_hierarchy full -retiming {*}$gen_args
} else {
    synth_design -top $top -part $part -mode out_of_context -flatten_hierarchy full {*}$gen_args
}
write_checkpoint -force $out_dir/post_synth.dcp
report_utilization -file $out_dir/util_synth.rpt
opt_design
place_design
phys_opt_design
route_design
write_checkpoint -force $out_dir/post_route.dcp
report_timing_summary -max_paths 10 -file $out_dir/timing_route.rpt
report_utilization -file $out_dir/util_route.rpt

# Machine-readable summary
set wns [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
set whs [get_property SLACK [get_timing_paths -max_paths 1 -hold]]
set u [report_utilization -return_string]
proc grab {u pat} {
    if {[regexp "\\|\\s*$pat\\s*\\|\\s*(\\d+)" $u -> v]} { return $v }
    return -1
}
set lut [grab $u {CLB LUTs\*?}]
set ff  [grab $u {CLB Registers}]
# 7-series reports name them Slice LUTs / Slice Registers (Stage 5, xc7k410t)
if {$lut < 0} { set lut [grab $u {Slice LUTs\*?}] }
if {$ff < 0}  { set ff  [grab $u {Slice Registers}] }
set dsp [grab $u {DSPs}]
set fh [open $out_dir/summary.json w]
puts $fh "{\"part\": \"$part\", \"period_ns\": $period, \"wns_ns\": $wns, \"whs_ns\": $whs, \"lut\": $lut, \"ff\": $ff, \"dsp\": $dsp, \"retime\": $retime, \"gen_dir\": \"$gen_dir\", \"top\": \"$top\", \"vivado\": \"[version -short]\", \"date\": \"[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S]\"}"
close $fh
puts "SUMMARY part=$part period=$period wns=$wns whs=$whs lut=$lut ff=$ff dsp=$dsp"
