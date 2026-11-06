# Stage 1 ZCU102 implementation (project + block design, synth -> route, reports, IOB check); NO write_bitstream (see stage1_bitstream.tcl).
#   vivado -mode batch -nojournal -source stage1_build.tcl -tclargs <out_dir> <F_NET_MHZ> <LC> [ARG_LAT] [key=value ...]
#   keys: harness=<file.sv>  use this harness instead of rtl/jsc_harness.sv (feasibility stubs)
#         xbar=smartconnect|interconnect   HPM0 -> AXI4-Lite converter in the BD (default smartconnect)
#         depth=<DEPTH_LOG2> (default 14)
#         place=<dir> phys=<dir> route=<dir>  implementation directives (default Explore)
#         iob=fabric|iob  fabric (default): pad flops in slices; tight pad I/O datapath bounds
#                         (below) make the placer keep them next to the pads;
#                         iob: IOB TRUE after synthesis, pad flops packed in the HD IOLOGIC
#                         (experiment only: the HD IOLOGIC FF Min Period is 8.000 ns, so
#                         pulse-width checks fail above 125 MHz)
# Exit 2 (and an "IOB_CHECK FAIL" line) unless every pad flop is where iob= asks (IOB or fabric).
set t0 [clock seconds]
set argv [lassign $argv out_dir f_net lc]
set arg_lat 1
if {[llength $argv] > 0 && [string is integer -strict [lindex $argv 0]]} { set argv [lassign $argv arg_lat] }
array set opt {harness "" xbar smartconnect depth 14 place Explore phys Explore route Explore iob fabric}
foreach kv $argv {
    if {![regexp {^([a-z_]+)=(.*)$} $kv -> k v] || ![info exists opt($k)]} { puts "ERROR: bad option '$kv'"; exit 1 }
    set opt($k) $v
}
switch -- $f_net { 300 - 200 { set axi_div 1 } 500 { set axi_div 2 } default { puts "ERROR: F_NET_MHZ must be 300, 200 or 500"; exit 1 } }

set proj [file normalize [file dirname [info script]]/../..]
set out_dir [file normalize $out_dir]
set part xczu9eg-ffvb1156-2-i
set gen_dir $proj/rtl/gen/jsc_lc$lc
file mkdir $out_dir
set_param general.maxThreads 8

# LAT_NET = da4ml metadata latency + 1 (docs/ARCHITECTURE.md §2)
set fh [open $gen_dir/metadata.json r]; set meta [read $fh]; close $fh
if {![regexp {"latency":\s*(\d+)} $meta -> core_lat]} { puts "ERROR: no latency in $gen_dir/metadata.json"; exit 1 }
set lat_net [expr {$core_lat + 1}]
puts "STAGE1 out=$out_dir F_net=$f_net AXI_DIV=$axi_div LC=$lc LAT_NET=$lat_net ARG_LAT=$arg_lat opts=[array get opt]"

# ---------------- project and sources ----------------
create_project s1 $out_dir/proj -part $part
set_property BOARD_PART xilinx.com:zcu102:part0:3.4 [current_project]
set_property target_language Verilog [current_project]

set rtl {}
foreach f [lsort [glob $proj/rtl/*.sv]] {
    set b [file tail $f]
    if {[string match tb_* $b] || [string match *_tb.sv $b]} continue
    if {$opt(harness) ne "" && $b eq "jsc_harness.sv"} continue
    lappend rtl $f
}
if {$opt(iob) ni {iob fabric}} { puts "ERROR: iob must be iob or fabric"; exit 1 }
if {$opt(harness) ne ""} { lappend rtl [file normalize [file join $proj $opt(harness)]] }  ;# relative to the project root
set core [concat [glob $gen_dir/src/static/*.v] [glob $gen_dir/src/jsc_stage*.v] [list $gen_dir/src/jsc.v]]
add_files -norecurse $rtl
add_files -norecurse $core
set_property include_dirs [list $proj/rtl] [current_fileset]
add_files -fileset constrs_1 -norecurse $proj/synth/constraints/zcu102_stage1.xdc
puts "SOURCES rtl: $rtl"

# ---------------- block design ----------------
set bd_freq_hz [expr {$f_net * 1000000 / $axi_div}]
set bd_xbar $opt(xbar)
source $proj/synth/scripts/stage1_bd.tcl
set bd_file [get_files ps_bd.bd]
set_property synth_checkpoint_mode None $bd_file
generate_target all $bd_file
add_files -norecurse [make_wrapper -files $bd_file -top]
set_property top zcu102_top [current_fileset]
update_compile_order -fileset sources_1
# BOARD_PART switched the project to the board file's -2-e part; synth_design -part below
# implements the in-memory design on $part (-2-i), which every report header confirms.

# ---------------- synth -> route ----------------
synth_design -top zcu102_top -part $part -flatten_hierarchy rebuilt \
    -generic [list F_NET_MHZ=$f_net LAT_NET=$lat_net ARG_LAT=$arg_lat DEPTH_LOG2=$opt(depth) LC=$lc]
write_checkpoint -force $out_dir/post_synth.dcp
if {$opt(iob) eq "iob"} {
    set iobc [get_cells -hierarchical -filter {NAME =~ u_harness/ipff_b_reg || NAME =~ u_harness/ipff_d_reg || NAME =~ u_harness/opff_l_reg || NAME =~ u_harness/opff_c_reg || NAME =~ u_harness/class_q_reg*}]
    puts "IOB TRUE on [llength $iobc] cells: $iobc"
    set_property IOB TRUE $iobc
    set_property IOB TRUE [get_ports {pin_b pin_c class_o[*]}]
} else {
    # Placement pull: datapath bounds a little above the IOB-packed values (INBUF ~1.42 ns,
    # OPFF clk-to-Q + OBUF ~2.94 ns, slow corner). They hide the datasheet min clock-to-out;
    # pad_paths below reports both corners.
    set_max_delay -datapath_only 2.000 -from [get_ports {pin_b pin_c}]
    set_max_delay -datapath_only 3.400 -from [get_cells {u_harness/opff_l_reg u_harness/opff_c_reg}] -to [get_ports {pin_b pin_c}]
}
# Pad output enable: T is a constant-0 flop (zcu102_top.sv) so the IBUFCTRL arc stays timed;
# the enable itself is never exercised, so its T->O arc and any path from pad_t are not timed.
set_disable_timing -from T -to O [get_cells {u_iob_b/OBUFT u_iob_c/OBUFT}]
set_false_path -from [get_cells pad_t_reg]
if {$axi_div == 2} {
    # T_VEC (clk_axi CSR) -> vector BRAM port B address/enable (clk_net = 2 x clk_axi): quasi-static.
    # The host writes T_VEC in one AXI transaction and STAGE_GO in a later one, and the stage read
    # uses the address two clk_net cycles after stage_go, so 2 clk_net cycles of setup are always
    # available; a mid-change value only addresses a read nobody consumes.
    set_multicycle_path -setup 2 -end -from [get_cells u_harness/t_vec_reg*] -to [get_clocks -of_objects [get_pins u_mmcm/CLKOUT0]]
    set_multicycle_path -hold 1 -end -from [get_cells u_harness/t_vec_reg*] -to [get_clocks -of_objects [get_pins u_mmcm/CLKOUT0]]
}
report_utilization -file $out_dir/util_synth.rpt
opt_design
place_design -directive $opt(place)
phys_opt_design -directive $opt(phys)
route_design -directive $opt(route)
if {[get_property SLACK [get_timing_paths -max_paths 1 -setup]] < 0} { phys_opt_design -directive AggressiveExplore }
write_checkpoint -force $out_dir/post_route.dcp

# ---------------- reports (all written now, into this build's own directory) ----------------
report_timing_summary -max_paths 10 -report_unconstrained -file $out_dir/timing_summary.rpt
report_utilization -file $out_dir/utilization.rpt
report_utilization -hierarchical -file $out_dir/utilization_hier.rpt
report_datasheet -file $out_dir/datasheet.rpt
report_io -file $out_dir/io.rpt
report_clock_interaction -delay_type min_max -file $out_dir/clock_interaction.rpt
report_clocks -file $out_dir/clocks.rpt
report_clock_utilization -file $out_dir/clock_utilization.rpt
report_drc -file $out_dir/drc.rpt
if {[catch {report_drc -ruledecks {bitstream_checks} -file $out_dir/drc_bitstream.rpt} e]} { puts "WARNING: bitstream_checks DRC: $e" }
report_methodology -file $out_dir/methodology.rpt
report_timing -max_paths 20 -nworst 1 -file $out_dir/timing_worst20.rpt
report_timing -to [get_ports {pin_b pin_c class_o[*]}] -max_paths 6 -file $out_dir/timing_to_pads_max.rpt
report_timing -to [get_ports {pin_b pin_c class_o[*]}] -max_paths 6 -delay_type min -file $out_dir/timing_to_pads_min.rpt
report_timing -from [get_ports {pin_b pin_c}] -max_paths 4 -file $out_dir/timing_from_pads_max.rpt
report_timing -from [get_ports {pin_b pin_c}] -max_paths 4 -delay_type min -file $out_dir/timing_from_pads_min.rpt

# ---------------- IOB packing check ----------------
# Output pads: the single flop driving the pad (found by topology) must be an OPFF in an IOLOGIC
# site (fabric replicas from Synth 8-4163 that do not drive the pad are fine).
# Input pads: EVERY sequential load of the pad net must be the IPFF in an IOLOGIC site (a fabric
# replica sampling the pad would break the timestamp semantics).
# Expected: opff_l / ipff_b (pin B), opff_c / ipff_d (pin C), one class flop per class_o bit.
# The fabric twins l_tw / c_tw must exist and must NOT be in an IOB.
proc iob_site_ok {c} {
    set s [get_sites -quiet -of_objects $c]
    return [expr {$s ne "" && [regexp {^(HDIOLOGIC|BITSLICE_RX_TX)} [get_property SITE_TYPE $s]]}]
}
set iob_ok 1
set iob_rows {}
set checks [list pin_b out opff_l u_iob_b/O in ipff_b pin_c out opff_c u_iob_c/O in ipff_d \
                 {class_o[0]} out class {class_o[1]} out class {class_o[2]} out class]
foreach {obj dir want} $checks {
    if {$dir eq "out"} {
        set ffs [filter -quiet [all_fanin -flat -startpoints_only -only_cells [get_ports $obj]] {IS_SEQUENTIAL && NAME != pad_t_reg}]
    } else {
        set ffs [filter -quiet [get_cells -quiet -of_objects [get_pins -quiet -leaf -filter {DIRECTION == IN} \
                    -of_objects [get_nets -of_objects [get_pins $obj]]]] {IS_SEQUENTIAL}]
    }
    if {[llength $ffs] != 1} {
        set iob_ok 0
        lappend iob_rows "$obj $dir want=$want FAIL: [llength $ffs] sequential cells at the pad ($ffs)"
        continue
    }
    set c [lindex $ffs 0]
    set ok [expr {[iob_site_ok $c] == ($opt(iob) eq "iob")}]
    set named [string match "*$want*" $c]
    if {!$ok} { set iob_ok 0 }
    lappend iob_rows "$obj $dir want=$want [expr {$ok ? "PASS" : "FAIL"}] cell=$c bel=[get_property BEL $c] site=[get_property LOC $c] clk=[get_nets -of_objects [get_pins $c/C]][expr {$named ? "" : " (name does not contain $want)"}]"
}
foreach tw {l_tw c_tw h_ff g_ff} {
    set c [get_cells -quiet -hierarchical -filter "NAME =~ */${tw}_reg && IS_PRIMITIVE"]
    if {[llength $c] != 1} {
        set iob_ok 0; lappend iob_rows "$tw fabric FAIL: [llength $c] cells named */${tw}_reg"; continue
    }
    set ok [expr {![iob_site_ok $c]}]
    if {!$ok} { set iob_ok 0 }
    lappend iob_rows "$tw fabric [expr {$ok ? "PASS" : "FAIL (in an IOB)"}] cell=$c bel=[get_property BEL $c] site=[get_property LOC $c] clk=[get_nets -of_objects [get_pins $c/C]]"
}
set fh [open $out_dir/iob_check.rpt w]
puts $fh "IOB packing check (iob=$opt(iob): pad flops must be [expr {$opt(iob) eq "iob" ? "in IOLOGIC" : "in fabric"}]) [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S] ([version -short], $part)"
foreach r $iob_rows { puts $fh $r; puts "IOB_CHECK $r" }
puts $fh [expr {$iob_ok ? "IOB_CHECK PASS" : "IOB_CHECK FAIL"}]
close $fh

# ---------------- anchor crossings (timed on purpose, see zcu102_stage1.xdc) ----------------
# d_eff_max = src clock arrival + data path + setup - dst clock arrival      (slow corner, setup path)
# d_eff_min = src clock arrival + data path - hold  - dst clock arrival      (fast corner, hold path)
# Clock arrivals are the clock-network delays from each clock's own edge (both clocks phase 0 in
# Vivado's view). Library setup/hold are recovered from REQUIRED_TIME:
#   setup: REQUIRED = edge + dst_clk + pessimism - uncertainty - setup
#   hold:  REQUIRED = edge + dst_clk + pessimism + uncertainty + hold
# t_minus_slack = REQUIREMENT - SLACK (setup) / SLACK - REQUIREMENT (hold), which also carries
# uncertainty and pessimism removal. Full clock paths are in anchors.rpt.
set fh [open $out_dir/anchors.rpt w]; close $fh
proc anchor {out_dir from to} {
    set fc [get_cells -quiet -hierarchical -filter "NAME =~ */${from}_reg && IS_PRIMITIVE"]
    set tc [get_cells -quiet -hierarchical -filter "NAME =~ */${to}_reg && IS_PRIMITIVE"]
    set res {}
    foreach kind {max min} {
        set p [get_timing_paths -quiet -from $fc -to $tc -delay_type $kind -max_paths 1]
        if {$fc eq "" || $tc eq "" || $p eq "" || [get_property SLACK $p] eq ""} {
            lappend res "\"$kind\": null"; puts "ANCHOR $from->$to $kind NOT TIMED"; continue
        }
        report_timing -of_objects $p -path_type full_clock_expanded -input_pins -append -file $out_dir/anchors.rpt
        set sedge [get_property STARTPOINT_CLOCK_EDGE $p]; set eedge [get_property ENDPOINT_CLOCK_EDGE $p]
        set scd [get_property STARTPOINT_CLOCK_DELAY $p]; set ecd [get_property ENDPOINT_CLOCK_DELAY $p]
        set dp  [get_property DATAPATH_DELAY $p];        set req [get_property REQUIRED_TIME $p]
        set cpr [get_property CLOCK_PESSIMISM $p];       set unc [get_property UNCERTAINTY $p]
        set slack [get_property SLACK $p];               set rq [get_property REQUIREMENT $p]
        if {$kind eq "max"} {
            set lib [expr {$eedge + $ecd + $cpr - $unc - $req}]
            set deff [expr {$scd + $dp + $lib - $ecd}]
            set tms [expr {$rq - $slack}]
        } else {
            set lib [expr {$req - $eedge - $ecd - $cpr - $unc}]
            set deff [expr {$scd + $dp - $lib - $ecd}]
            set tms [expr {$slack - $rq}]
        }
        set name [expr {$kind eq "max" ? "setup" : "hold"}]
        lappend res [format {"%s": {"corner": "%s", "src_clk_ns": %.3f, "datapath_ns": %.3f, "dst_clk_ns": %.3f, "%s_ns": %.3f, "pessimism_ns": %.3f, "uncertainty_ns": %.3f, "requirement_ns": %.3f, "slack_ns": %.3f, "d_eff_ns": %.3f, "t_minus_slack_ns": %.3f}} \
            $kind [get_property CORNER $p] $scd $dp $ecd $name $lib $cpr $unc $rq $slack $deff $tms]
        puts [format "ANCHOR %s->%s %s d_eff=%.3f slack=%.3f (src_clk %.3f dp %.3f dst_clk %.3f %s %.3f)" $from $to $kind $deff $slack $scd $dp $ecd $name $lib]
    }
    return "{\"from\": \"$fc\", \"to\": \"$tc\", [join $res {, }]}"
}
set d_h [anchor $out_dir l_tw h_ff]
set d_g [anchor $out_dir c_tw g_ff]
# Every timed clk_ps <-> fabric crossing (expected: only the two anchors).
set c_ps [get_clocks -of_objects [get_pins u_mmcm/CLKOUT1]]
set c_fab [get_clocks -of_objects [get_pins {u_mmcm/CLKOUT0 u_mmcm/CLKOUT2}]]
set xing {}
foreach {a b} [list $c_ps $c_fab $c_fab $c_ps] {
    foreach p [get_timing_paths -quiet -from $a -to $b -max_paths 1000 -nworst 1 -setup] {
        if {[get_property SLACK $p] eq ""} continue
        lappend xing "[get_property STARTPOINT_PIN $p] -> [get_property ENDPOINT_PIN $p] slack=[get_property SLACK $p]"
    }
}
set fh [open $out_dir/anchors.rpt a]
puts $fh "\nTIMED clk_ps <-> clk_net/clk_axi crossings ([llength $xing]; expected 2: l_tw->h_ff, c_tw->g_ff):"
foreach x $xing { puts $fh "  $x"; puts "XING $x" }
close $fh

# ---------------- report_datasheet numbers for the timed pads ----------------
# Clock-to-out is from the SI570 reference port through the MMCM (internal clock in the last column).
set ds [report_datasheet -return_string]
proc ds_section {ds title} {
    set a [string first $title $ds]
    if {$a < 0} { return "" }
    set b [string first "\n\n\n" $ds [expr {$a + [string length $title] + 200}]]
    return [string range $ds $a [expr {$b < 0 ? "end" : $b}]]
}
set ds_out [ds_section $ds "Output Ports Clock-to-out"]
set ds_in  [ds_section $ds "Input Ports Setup/Hold"]
proc ds_row {sec port} {
    set re "\\|\\s*${port}\\s*\\|\\s*(\[^|\]*?)\\s*\\|\[^|\]*\\|\\s*(\[-0-9.\]+) \\(r\\)\\s*\\|\\s*(\\S+)\\s*\\|\\s*(\[-0-9.\]+) \\(r\\)\\s*\\|\\s*(\\S+)\\s*\\|\\s*(\\S+)\\s*\\|"
    if {[regexp $re $sec -> type a ca b cb iclk]} {
        return [list $type $a $ca $b $cb $iclk]
    }
    return {}
}
set ds_json {}
foreach {port sec what} [list pin_b $ds_out clk_to_out pin_c $ds_out clk_to_out pin_b $ds_in setup_hold pin_c $ds_in setup_hold] {
    set r [ds_row $sec $port]
    if {$r eq ""} { lappend ds_json "\"${port}_$what\": null"; continue }
    lassign $r type a ca b cb iclk
    set k [expr {$what eq "clk_to_out" ? [list max_ns min_ns] : [list setup_ns hold_ns]}]
    lappend ds_json "\"${port}_$what\": {\"io_reg\": \"$type\", \"[lindex $k 0]\": $a, \"corner_[lindex $k 0]\": \"$ca\", \"[lindex $k 1]\": $b, \"corner_[lindex $k 1]\": \"$cb\", \"internal_clock\": \"$iclk\"}"
    set ds_v(${port}_${what}_a) $a; set ds_v(${port}_${what}_b) $b
    puts "DATASHEET $port $what $type $a ($ca) / $b ($cb) internal=$iclk"
}
if {[info exists ds_v(pin_b_clk_to_out_a)] && [info exists ds_v(pin_c_clk_to_out_a)]} {
    lappend ds_json [format {"tout_c_minus_tout_b_max_ns": %.3f, "tout_c_minus_tout_b_min_ns": %.3f} \
        [expr {$ds_v(pin_c_clk_to_out_a) - $ds_v(pin_b_clk_to_out_a)}] [expr {$ds_v(pin_c_clk_to_out_b) - $ds_v(pin_b_clk_to_out_b)}]]
}

# ---------------- per-clock timing and summary.json ----------------
proc clk_of {pin} { return [get_clocks -quiet -of_objects [get_pins -quiet $pin]] }
set roles [list clk_net [clk_of u_mmcm/CLKOUT0] clk_ps [clk_of u_mmcm/CLKOUT1] \
                clk_axi [expr {$axi_div == 1 ? [clk_of u_mmcm/CLKOUT0] : [clk_of u_mmcm/CLKOUT2]}]]
proc slack_or_null {paths} {
    if {[llength $paths] == 0} { return null }
    set s [get_property SLACK [lindex $paths 0]]
    return [expr {$s eq "" ? "null" : $s}]
}
proc tns_of {grp kind} {
    set t 0.0
    foreach p [get_timing_paths -quiet -group $grp -$kind -max_paths 100000 -nworst 1 -slack_lesser_than 0] {
        set t [expr {$t + [get_property SLACK $p]}]
    }
    return [format %.3f $t]
}
set clk_json {}
foreach {role c} $roles {
    if {$c eq ""} { lappend clk_json "\"$role\": null"; continue }
    set wns [slack_or_null [get_timing_paths -quiet -group $c -setup -max_paths 1]]
    set whs [slack_or_null [get_timing_paths -quiet -group $c -hold -max_paths 1]]
    lappend clk_json "\"$role\": {\"clock\": \"$c\", \"period_ns\": [get_property PERIOD $c], \"wns_ns\": $wns, \"tns_ns\": [tns_of $c setup], \"whs_ns\": $whs, \"ths_ns\": [tns_of $c hold]}"
    puts "CLOCK $role=$c period=[get_property PERIOD $c] WNS=$wns WHS=$whs"
}
set wns [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
set whs [get_property SLACK [get_timing_paths -max_paths 1 -hold]]
# Pulse width (WPWS) from the design timing summary: the HD IOLOGIC FF Min Period (8 ns) shows here.
set wpws null; set tpws null; set pw_fail null
set ts [report_timing_summary -no_detailed_paths -return_string]
if {[regexp {WPWS\(ns\)[^\n]*\n[ -]+\n\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)} $ts -> - - - - - - - - wpws tpws pw_fail]} {}
set pw_cells {}
foreach l [split [report_pulse_width -all_violators -return_string] "\n"] {
    if {[regexp {^(Min Period|Low Pulse Width|High Pulse Width)\s.*\s(-[0-9.]+)\s+(\S+)\s+(\S+)\s*$} $l -> kind sl site pin]} { lappend pw_cells "$pin ($site, $kind $sl)" }
}
puts "PULSE_WIDTH WPWS=$wpws TPWS=$tpws failing_endpoints=$pw_fail"
foreach x [lsort -unique $pw_cells] { puts "PULSE_WIDTH_FAIL $x" }
# Pad data paths (port -> IPFF, OPFF -> port; unconstrained in iob mode, datapath-bounded in
# fabric mode): INBUF/OBUF + any fabric routing, slow (max) and fast (min) corners.
set pad_json {}
foreach {tag from to} [list pin_b_in [get_ports pin_b] {} pin_c_in [get_ports pin_c] {} \
                           pin_b_out {} [get_ports pin_b] pin_c_out {} [get_ports pin_c]] {
    foreach kind {max min} {
        if {$from ne ""} { set p [get_timing_paths -quiet -from $from -delay_type $kind -max_paths 1]
        } else { set p [get_timing_paths -quiet -to $to -delay_type $kind -max_paths 1] }
        if {$p eq "" || [get_property DATAPATH_DELAY $p] eq ""} { lappend pad_json "\"${tag}_$kind\": null"; continue }
        set sl [get_property SLACK $p]; if {$sl eq "" || $sl eq "inf"} { set sl null }
        # clock network delay at the pad flop (from its clock's MMCM-referenced edge; both clocks
        # phase 0 in Vivado's view), so clk_to_pad = clock insertion + clk-to-Q + route + OBUF
        set ck [expr {$from ne "" ? [get_property ENDPOINT_CLOCK_DELAY $p] : [get_property STARTPOINT_CLOCK_DELAY $p]}]
        if {$ck eq ""} { set ck 0.0 }
        set pad_v(${tag}_$kind) [expr {$ck + [get_property DATAPATH_DELAY $p]}]
        lappend pad_json [format {"%s_%s": {"from": "%s", "to": "%s", "datapath_ns": %.3f, "flop_clock_delay_ns": %.3f, "slack_ns": %s, "corner": "%s"}} \
            $tag $kind [get_property STARTPOINT_PIN $p] [get_property ENDPOINT_PIN $p] [get_property DATAPATH_DELAY $p] $ck $sl [get_property CORNER $p]]
        puts "PAD $tag $kind [get_property STARTPOINT_PIN $p] -> [get_property ENDPOINT_PIN $p] datapath=[get_property DATAPATH_DELAY $p] slack=[get_property SLACK $p]"
    }
}
# t_out_C - t_out_B for timed_solve.py --dtout (docs/MEASUREMENT.md §2a): each = flop clock delay + data path
foreach kind {max min} {
    if {[info exists pad_v(pin_c_out_$kind)] && [info exists pad_v(pin_b_out_$kind)]} {
        set dt [expr {$pad_v(pin_c_out_$kind) - $pad_v(pin_b_out_$kind)}]
        lappend pad_json [format {"clk_to_pad_b_%s_ns": %.3f, "clk_to_pad_c_%s_ns": %.3f, "tout_c_minus_tout_b_%s_ns": %.3f} \
            $kind $pad_v(pin_b_out_$kind) $kind $pad_v(pin_c_out_$kind) $kind $dt]
        puts [format "DTOUT %s t_out_B=%.3f t_out_C=%.3f diff=%.3f" $kind $pad_v(pin_b_out_$kind) $pad_v(pin_c_out_$kind) $dt]
    }
}
set u [report_utilization -return_string]
proc grab {u pat} {
    if {[regexp "\\|\\s*$pat\\s*\\|\\s*(\[0-9.\]+)" $u -> v]} { return $v }
    return -1
}
set lut [grab $u {CLB LUTs\*?}]
set ff  [grab $u {CLB Registers}]
set bram [grab $u {Block RAM Tile}]
set dsp [grab $u {DSPs}]
set fh [open $out_dir/summary.json w]
puts $fh "{\"part\": \"$part\", \"f_net_mhz\": $f_net, \"axi_div\": $axi_div, \"lc\": $lc, \"lat_net\": $lat_net, \"arg_lat\": $arg_lat, \"depth_log2\": $opt(depth),"
puts $fh " \"xbar\": \"$opt(xbar)\", \"harness\": \"[expr {$opt(harness) eq "" ? "rtl/jsc_harness.sv" : $opt(harness)}]\","
puts $fh " \"directives\": {\"place\": \"$opt(place)\", \"phys\": \"$opt(phys)\", \"route\": \"$opt(route)\"},"
puts $fh " \"wns_ns\": $wns, \"whs_ns\": $whs, \"clocks\": {[join $clk_json {, }]},"
puts $fh " \"iob_mode\": \"$opt(iob)\", \"wpws_ns\": $wpws, \"tpws_ns\": $tpws, \"pulse_width_failing_endpoints\": $pw_fail, \"pad_paths\": {[join $pad_json {, }]},"
puts $fh " \"d_H\": $d_h, \"d_G\": $d_g, \"datasheet\": {[join $ds_json {, }]},"
puts $fh " \"lut\": $lut, \"ff\": $ff, \"bram_tiles\": $bram, \"dsp\": $dsp,"
puts $fh " \"iob_check\": \"[expr {$iob_ok ? "PASS" : "FAIL"}]\", \"vivado\": \"[version -short]\", \"date\": \"[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S]\", \"elapsed_s\": [expr {[clock seconds] - $t0}]}"
close $fh
puts "SUMMARY F_net=$f_net LC=$lc LAT_NET=$lat_net iob=$opt(iob) wns=$wns whs=$whs wpws=$wpws lut=$lut ff=$ff bram=$bram dsp=$dsp iob=[expr {$iob_ok ? "PASS" : "FAIL"}]"
if {!$iob_ok} { puts "IOB_CHECK FAIL"; exit 2 }
puts "IOB_CHECK PASS"
