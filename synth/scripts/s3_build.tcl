# Stage 3 BCU-1525 loop build (s3_top), through route; no bitstream (s3_bitstream.tcl does that).
#   vivado -mode batch -nojournal -source s3_build.tcl -tclargs <out_dir> <lc> [directive] [d]
# <out_dir> already holds s3_shots.hex (launch_s3.sh writes it and its sha256). DEC_LAT =
# metadata latency + 2 (decoder input register to flip valid, the Verilator loop's DEC_LAT).
# d = 3 (default; Stage 3): N_DET = 24, DW = 64, aurora_a/b, rtl/gen/qec_d3_lc<lc>, s3_bcu1525.xdc.
# d = 5: N_DET = 120, DW = 192, aurora3_a/b (3 bonded lanes), + s3_bcu1525_l3.xdc; <lc> is a cutoff of
#   rtl/gen/qec_d5_lc<lc> (with rtl/qec_d5_in_map.svh, widths from ref/golden/qec_d5_golden.json), or
#   "standin" for the TEST-ONLY synthetic core tb/qec_d5_standin.sv (link / timing checks only).
lassign $argv out_dir lc directive d
if {$directive eq ""} { set directive Default }
if {$d eq ""} { set d 3 }
set out_dir [file normalize $out_dir]
set proj [file normalize [file join [file dirname [info script]] ../..]]
set part xcvu9p-fsgd2104-2L-e
proc meta_lat {f} { set fh [open $f r]; set m [read $fh]; close $fh; regexp {"latency": *([0-9]+)} $m -> l; return $l }
if {$d == 3} {
    set n_det 24; set dw 64; set ips {aurora_a aurora_b s3_jtag_axi}; set inc $proj/rtl
    set gen $proj/rtl/gen/qec_d3_lc$lc
    set core_lat [meta_lat $gen/metadata.json]
    set core_v [concat [glob $gen/src/static/*.v] [glob $gen/src/qec_d3_stage*.v] [list $gen/src/qec_d3.v]]
    set top_sv [list $proj/rtl/qec_d3_top.sv]
    set xdcs [list $proj/synth/constraints/s3_bcu1525.xdc]
    set wgen {}
} elseif {$d == 5} {
    set n_det 120; set dw 192; set ips {aurora3_a aurora3_b s3_jtag_axi}
    set top_sv [list $proj/rtl/d5/qec_d5_top.sv]
    set xdcs [list $proj/synth/constraints/s3_bcu1525.xdc $proj/synth/constraints/s3_bcu1525_l3.xdc]
    if {$lc eq "standin"} {
        set inc $proj/tb/standin; set core_lat 3; set out_w 16; set lsig 1
        set core_v {}; lappend top_sv $proj/tb/qec_d5_standin.sv
    } else {
        set inc $proj/rtl
        set gen $proj/rtl/gen/qec_d5_lc$lc
        set core_lat [meta_lat $gen/metadata.json]
        set core_v [concat [glob $gen/src/static/*.v] [glob $gen/src/qec_d5_stage*.v] [list $gen/src/qec_d5.v]]
        set fh [open $proj/ref/golden/qec_d5_golden.json r]; set gj [read $fh]; close $fh
        regexp {"out_width_bits": *([0-9]+)} $gj -> out_w
        regexp {"out_kif":\s*\[\s*\[\s*([0-9]+)} $gj -> lsig  ;# json.dumps(indent=1) spreads it over lines
    }
    set wgen [list -generic N_DET=$n_det -generic DW=$dw -generic OUT_W=$out_w -generic LOGIT_SIGNED=$lsig]
} else { puts "ERROR: d must be 3 or 5"; exit 1 }
set dec_lat [expr {$core_lat + 2}]
set shots $out_dir/s3_shots.hex
if {![file exists $shots]} { puts "ERROR: $shots missing"; exit 1 }
set nvec 0
set fh [open $shots r]; while {[gets $fh l] >= 0} { if {$l ne ""} { incr nvec } }; close $fh
puts "S3BUILD d=$d lc=$lc core_lat=$core_lat DEC_LAT=$dec_lat NVEC=$nvec N_DET=$n_det DW=$dw directive=$directive"

create_project -in_memory -part $part
set_property target_language Verilog [current_project]
foreach ip $ips {
    read_ip $proj/rtl/ip/$ip/$ip.xci
    # only the .xci is committed: regenerate and synthesise the products on a fresh checkout
    if {![file exists $proj/rtl/ip/$ip/$ip.dcp]} { generate_target all [get_ips $ip]; synth_ip [get_ips $ip] }
}
if {[llength $core_v]} { read_verilog $core_v }
read_verilog -sv [concat [list $proj/rtl/s3/s3_pkg.sv] $top_sv [list $proj/rtl/s3/s3_side_a.sv \
    $proj/rtl/s3/s3_side_b.sv $proj/rtl/s3/s3_regs.sv $proj/rtl/s3/s3_freq.sv $proj/rtl/s3/s3_top.sv]]
foreach x $xdcs { read_xdc $x }

synth_design -top s3_top -part $part -include_dirs $inc \
    -generic NVEC=$nvec -generic DEC_LAT=$dec_lat -generic "INIT_FILE=\"$shots\"" {*}$wgen
write_checkpoint -force $out_dir/post_synth.dcp
report_utilization -file $out_dir/util_synth.rpt
opt_design
place_design -directive $directive
phys_opt_design
route_design
if {[get_property SLACK [get_timing_paths -max_paths 1 -setup]] < 0} { phys_opt_design -directive AggressiveExplore }
write_checkpoint -force $out_dir/post_route.dcp
report_timing_summary -max_paths 20 -file $out_dir/timing_route.rpt
report_utilization -file $out_dir/util_route.rpt
report_clock_interaction -file $out_dir/clock_interaction.rpt
report_cdc -file $out_dir/cdc.rpt
report_methodology -file $out_dir/methodology.rpt

set wns  [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
set whs  [get_property SLACK [get_timing_paths -max_paths 1 -hold]]
# WPWS from the design timing summary (as stage1_build.tcl): column 9 of the summary row
set ts [report_timing_summary -no_detailed_paths -return_string]
set wpws -1
regexp {WPWS\(ns\)[^\n]*\n[ -]+\n\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)} $ts -> - - - - - - - - wpws
set u [report_utilization -return_string]
proc grab {u pat} { if {[regexp "\\|\\s*$pat\\s*\\|\\s*(\\d+)" $u -> v]} { return $v }; return -1 }
set gts {}
foreach c [get_cells -hier -filter {REF_NAME == GTYE4_CHANNEL}] { lappend gts "[get_property NAME $c]=[get_property LOC $c]" }
set fh [open $out_dir/summary.json w]
set lcj [expr {[string is integer -strict $lc] ? $lc : "\"$lc\""}]
puts $fh "\{\"d\": $d, \"lc\": $lcj, \"n_det\": $n_det, \"dw\": $dw, \"dec_lat\": $dec_lat, \"nvec\": $nvec, \"directive\": \"$directive\", \"wns_ns\": $wns, \"whs_ns\": $whs, \"wpws_ns\": $wpws,"
puts $fh " \"lut\": [grab $u {CLB LUTs\*?}], \"ff\": [grab $u {CLB Registers}], \"bram\": [grab $u {Block RAM Tile}], \"dsp\": [grab $u {DSPs}],"
puts $fh " \"gt\": \"[join $gts { }]\", \"vivado\": \"[version -short]\", \"date\": \"[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S]\"\}"
close $fh
puts "SUMMARY d=$d lc=$lc wns=$wns whs=$whs wpws=$wpws gt=$gts"
