# Stage 6 BCU-1525 loop build (s6_top: s3 sides + the thin GTY link), through route; no bitstream (s6_bitstream.tcl).
#   vivado -mode batch -nojournal -source s6_build.tcl -tclargs <out_dir> <lc> [directive] [d] [tx_reg] [rx_reg]
# <out_dir> holds s3_shots.hex (launch_s6.sh writes it and its sha256). DEC_LAT = metadata latency + 2 as Stage 3.
# d = 3: N_DET = 24, DW = 64, GT core s6_gt (X1Y44 + X1Y48), rtl/gen/qec_d3_lc<lc>, s6_bcu1525.xdc.
# d = 5: N_DET = 120, DW = 192, s6_gt3 (X1Y44..46 + X1Y48..50), rtl/gen/qec_d5_lc<lc>, + s3_bcu1525_l3.xdc.
# Besides timing, it checks the one-clock rule on the routed netlist (docs/PLAN.md D-S6-CLK): every GTYE4_CHANNEL's
# TXUSRCLK, TXUSRCLK2, RXUSRCLK and RXUSRCLK2 on ONE net, that net driven by one BUFG_GT, exactly one IBUFDS_GTE4,
# driving the GTREFCLK01 of both GTYE4_COMMONs; the result goes into summary.json (single_clock) and clock_check.txt.
# Environment S6_TXBYP=1 (d = 3 only): GT core s6_gt_bp (TX buffer bypassed) and s6_top TXBYP = 1.
lassign $argv out_dir lc directive d tx_reg rx_reg
if {$directive eq ""} { set directive Default }
if {$d eq ""} { set d 3 }
if {$tx_reg eq ""} { set tx_reg 0 }
if {$rx_reg eq ""} { set rx_reg 0 }
set txbyp [expr {[info exists ::env(S6_TXBYP)] && $::env(S6_TXBYP) eq "1" ? 1 : 0}]
if {$txbyp && $d != 3} { puts "ERROR: S6_TXBYP=1 is built for d = 3 only"; exit 1 }
set out_dir [file normalize $out_dir]
set proj [file normalize [file join [file dirname [info script]] ../..]]
set part xcvu9p-fsgd2104-2L-e
proc meta_lat {f} { set fh [open $f r]; set m [read $fh]; close $fh; regexp {"latency": *([0-9]+)} $m -> l; return $l }
if {$d == 3} {
    set n_det 24; set dw 64; set ips [expr {$txbyp ? {s6_gt_bp s3_jtag_axi} : {s6_gt s3_jtag_axi}}]; set inc $proj/rtl
    set gen $proj/rtl/gen/qec_d3_lc$lc
    set core_lat [meta_lat $gen/metadata.json]
    set core_v [concat [glob $gen/src/static/*.v] [glob $gen/src/qec_d3_stage*.v] [list $gen/src/qec_d3.v]]
    set top_sv [list $proj/rtl/qec_d3_top.sv]
    set xdcs [list $proj/synth/constraints/s6_bcu1525.xdc]
    set wgen {}
} elseif {$d == 5} {
    set n_det 120; set dw 192; set ips {s6_gt3 s3_jtag_axi}; set inc $proj/rtl
    set top_sv [list $proj/rtl/d5/qec_d5_top.sv]
    set xdcs [list $proj/synth/constraints/s6_bcu1525.xdc $proj/synth/constraints/s3_bcu1525_l3.xdc]
    set gen $proj/rtl/gen/qec_d5_lc$lc
    set core_lat [meta_lat $gen/metadata.json]
    set core_v [concat [glob $gen/src/static/*.v] [glob $gen/src/qec_d5_stage*.v] [list $gen/src/qec_d5.v]]
    set fh [open $proj/ref/golden/qec_d5_golden.json r]; set gj [read $fh]; close $fh
    regexp {"out_width_bits": *([0-9]+)} $gj -> out_w
    regexp {"out_kif":\s*\[\s*\[\s*([0-9]+)} $gj -> lsig
    set wgen [list -generic N_DET=$n_det -generic DW=$dw -generic OUT_W=$out_w -generic LOGIT_SIGNED=$lsig]
} else { puts "ERROR: d must be 3 or 5"; exit 1 }
set dec_lat [expr {$core_lat + 2}]
set shots $out_dir/s3_shots.hex
if {![file exists $shots]} { puts "ERROR: $shots missing"; exit 1 }
set nvec 0
set fh [open $shots r]; while {[gets $fh l] >= 0} { if {$l ne ""} { incr nvec } }; close $fh
puts "S6BUILD d=$d lc=$lc core_lat=$core_lat DEC_LAT=$dec_lat NVEC=$nvec N_DET=$n_det DW=$dw TX_REG=$tx_reg RX_REG=$rx_reg TXBYP=$txbyp directive=$directive"

create_project -in_memory -part $part
set_property target_language Verilog [current_project]
foreach ip $ips {
    read_ip $proj/rtl/ip/$ip/$ip.xci
    if {![file exists $proj/rtl/ip/$ip/$ip.dcp]} { generate_target all [get_ips $ip]; synth_ip [get_ips $ip] }
}
if {[llength $core_v]} { read_verilog $core_v }
read_verilog -sv [concat [list $proj/rtl/s3/s3_pkg.sv $proj/rtl/s6/s6_pkg.sv] $top_sv [list $proj/rtl/s3/s3_side_a.sv \
    $proj/rtl/s3/s3_side_b.sv $proj/rtl/s3/s3_regs.sv $proj/rtl/s3/s3_freq.sv $proj/rtl/s6/s6_link.sv \
    $proj/rtl/s6/s6_probe.sv $proj/rtl/s6/s6_diag.sv $proj/rtl/s6/s6_core.sv $proj/rtl/s6/s6_top.sv]]
foreach x $xdcs { read_xdc $x }

synth_design -top s6_top -part $part -include_dirs $inc \
    -generic NVEC=$nvec -generic DEC_LAT=$dec_lat -generic "INIT_FILE=\"$shots\"" \
    -generic TX_REG=$tx_reg -generic RX_REG=$rx_reg -generic TXBYP=$txbyp {*}$wgen
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
report_clock_networks -file $out_dir/clock_networks.rpt
report_clocks -file $out_dir/clocks.rpt
report_cdc -file $out_dir/cdc.rpt
report_methodology -file $out_dir/methodology.rpt
report_drc -file $out_dir/drc_route.rpt

set wns  [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
set whs  [get_property SLACK [get_timing_paths -max_paths 1 -hold]]
set ts [report_timing_summary -no_detailed_paths -return_string]
set wpws -1
regexp {WPWS\(ns\)[^\n]*\n[ -]+\n\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)} $ts -> - - - - - - - - wpws

# ---------------- one-clock check ----------------
set ck [open $out_dir/clock_check.txt w]
set ok 1
set usr {}
set gts {}
foreach c [get_cells -hier -filter {REF_NAME == GTYE4_CHANNEL}] {
    lappend gts "[get_property NAME $c]=[get_property LOC $c]"
    foreach p {TXUSRCLK TXUSRCLK2 RXUSRCLK RXUSRCLK2} {
        set n [get_nets -of_objects [get_pins $c/$p]]
        set n [get_property PARENT $n]
        puts $ck "CHANNEL [get_property LOC $c] $p net=$n"
        lappend usr $n
    }
}
set usr [lsort -unique $usr]
puts $ck "USRCLK_NETS [llength $usr] $usr"
if {[llength $usr] != 1} { set ok 0 }
set drv [get_cells -of_objects [get_pins -of_objects [get_nets [lindex $usr 0]] -filter {DIRECTION == OUT && IS_LEAF}]]
puts $ck "USRCLK_DRIVER [get_property REF_NAME $drv] $drv LOC=[get_property LOC $drv]"
if {[get_property REF_NAME $drv] ne "BUFG_GT"} { set ok 0 }
set src [get_nets -of_objects [get_pins $drv/I]]
puts $ck "USRCLK_SOURCE [get_pins -of_objects $src -filter {DIRECTION == OUT && IS_LEAF}]"
set ib [get_cells -hier -filter {REF_NAME == IBUFDS_GTE4}]
puts $ck "IBUFDS_GTE4 [llength $ib] $ib"
if {[llength $ib] != 1} { set ok 0 }
set refnet [get_nets -of_objects [get_pins $ib/O]]
foreach cm [get_cells -hier -filter {REF_NAME == GTYE4_COMMON}] {
    set n [get_nets -of_objects [get_pins $cm/GTREFCLK01]]
    set same [expr {[get_property PARENT $n] eq [get_property PARENT $refnet]}]
    puts $ck "COMMON [get_property LOC $cm] GTREFCLK01 net=[get_property PARENT $n] shared_refclk=$same"
    if {!$same} { set ok 0 }
}
set clks {}
foreach c [get_clocks] { lappend clks "[get_property NAME $c]:[get_property PERIOD $c]" }
puts $ck "CLOCKS $clks"
puts $ck "SINGLE_CLOCK [expr {$ok ? "PASS" : "FAIL"}]"
close $ck

set u [report_utilization -return_string]
proc grab {u pat} { if {[regexp "\\|\\s*$pat\\s*\\|\\s*(\\d+)" $u -> v]} { return $v }; return -1 }
set fh [open $out_dir/summary.json w]
set lcj [expr {[string is integer -strict $lc] ? $lc : "\"$lc\""}]
puts $fh "\{\"stage\": 6, \"d\": $d, \"lc\": $lcj, \"n_det\": $n_det, \"dw\": $dw, \"dec_lat\": $dec_lat, \"nvec\": $nvec, \"tx_reg\": $tx_reg, \"rx_reg\": $rx_reg, \"txbyp\": $txbyp, \"directive\": \"$directive\", \"wns_ns\": $wns, \"whs_ns\": $whs, \"wpws_ns\": $wpws,"
puts $fh " \"single_clock\": [expr {$ok ? "true" : "false"}], \"lut\": [grab $u {CLB LUTs\*?}], \"ff\": [grab $u {CLB Registers}], \"bram\": [grab $u {Block RAM Tile}], \"dsp\": [grab $u {DSPs}],"
puts $fh " \"gt\": \"[join $gts { }]\", \"vivado\": \"[version -short]\", \"date\": \"[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S]\"\}"
close $fh
puts "SUMMARY d=$d lc=$lc wns=$wns whs=$whs wpws=$wpws single_clock=$ok gt=$gts"
