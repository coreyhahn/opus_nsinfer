# s6_gen_gt.tcl -- generate the Stage 6 thin-link GT Wizard core for the BCU-1525 desk card
# (xcvu9p-fsgd2104-2L-e, VCU1525 / U200 pinout), QSFP0 <-> QSFP1 over the QSFP+ 40G DAC.
#
# One gtwizard_ultrascale instance drives BOTH link ends, on ONE reference clock (docs/PLAN.md D-S6-CLK):
#   s6_gt  (1 lane per cage, d = 3):  channels X1Y44 (QSFP1 lane 0, quad 230 = X1Y11) and X1Y48 (QSFP0 lane 0,
#                                      quad 231 = X1Y12)
#   s6_gt3 (3 lanes per cage, d = 5): X1Y44..X1Y46 and X1Y48..X1Y50
#   refclk: MGTREFCLK1 of quad 231 (K11/K10, Si5335 U9, 161.1328125 MHz) for every channel. The X1Y11 channels
#           take it as "clk1+1" (MGTREFCLK1 of the quad one above, through the GTSOUTHREFCLK routing; UG578 v1.4
#           ch. 2 "Reference Clock Selection and Distribution", p. 24 and p. 34: up to two quads above / below,
#           same SLR; no line-rate restriction below 16.375 Gb/s). Si5335 U12 (P11/P10) is unused.
#   GT settings = the preset the Stage 3/4 Aurora cores used (GTY-Aurora_64B66B: 10.3125 Gb/s, QPLL1,
#   64B/66B synchronous gearbox, TX/RX user width 64 = internal width 64, TX and RX buffers ON, TXOUTCLKPMA).
#   User clocking: TX helper block in the core, sourced by TXOUTCLK of the master channel X1Y48 (X1Y49 for 3
#   lanes, the middle-most channel: UG578 p. 106); one BUFG_GT. The RX helper is left out of the core
#   (LOCATE_RX_USER_CLOCKING = EXAMPLE_DESIGN) so s6_top can drive every RXUSRCLK/RXUSRCLK2 with that same TX
#   user clock (UG578 p. 321: allowed when the same oscillator drives the TX and RX reference clocks; Table 4-38
#   p. 278: such a synchronous system needs no clock correction). Reset controller in the core.
#
# Usage (snoke):
#   vivado -mode batch -nojournal -source synth/scripts/s6_gen_gt.tcl -tclargs [l3] [txbyp] [synth]
#   writes rtl/ip/s6_gt/ (or rtl/ip/s6_gt3/), and a property dump next to the .xci (s6_gt_config.txt)
#   txbyp: TX buffer bypassed (TX_BUFFER_MODE 0, the wizard's TX buffer-bypass controller in the core, PG182);
#          the RX side is unchanged. Core name gets the suffix _bp (s6_gt_bp, s6_gt3_bp). docs/superpowers/plans/
#          2026-11-06-stage6-next.md Task 3.
#   synth: also synth_ip the core (s6_build.tcl does that itself when the .dcp is missing)
set script_dir [file dirname [file normalize [info script]]]
set proj_dir   [file normalize "$script_dir/../.."]
set ip_root    "$proj_dir/rtl/ip"
set part       xcvu9p-fsgd2104-2L-e
set do_l3      [expr {[lsearch $argv l3] >= 0}]
set do_synth   [expr {[lsearch $argv synth] >= 0}]
set do_byp     [expr {[lsearch $argv txbyp] >= 0}]

create_project -in_memory -part $part
set_property target_language Verilog [current_project]
set vlnv [lindex [lsort [get_ipdefs -all xilinx.com:ip:gtwizard_ultrascale:*]] end]
puts "S6GEN: ipdef $vlnv"

if {$do_l3} {
    set name s6_gt3
    set chans {X1Y44 X1Y45 X1Y46 X1Y48 X1Y49 X1Y50}
    set master X1Y49
    set refsrc {X1Y44 clk1+1 X1Y45 clk1+1 X1Y46 clk1+1 X1Y48 clk1 X1Y49 clk1 X1Y50 clk1}
} else {
    set name s6_gt
    set chans {X1Y44 X1Y48}
    set master X1Y48
    set refsrc {X1Y44 clk1+1 X1Y48 clk1}
}
if {$do_byp} { append name _bp }
file delete -force "$ip_root/$name"
file mkdir $ip_root
create_ip -vlnv $vlnv -module_name $name -dir $ip_root
set ip [get_ips $name]
set_property CONFIG.PRESET GTY-Aurora_64B66B $ip
set_property -dict [list \
    CONFIG.CHANNEL_ENABLE          $chans \
    CONFIG.TX_MASTER_CHANNEL       $master \
    CONFIG.RX_MASTER_CHANNEL       $master \
    CONFIG.TX_LINE_RATE            10.3125 \
    CONFIG.RX_LINE_RATE            10.3125 \
    CONFIG.TX_PLL_TYPE             QPLL1 \
    CONFIG.RX_PLL_TYPE             QPLL1 \
    CONFIG.TX_REFCLK_FREQUENCY     161.1328125 \
    CONFIG.RX_REFCLK_FREQUENCY     161.1328125 \
    CONFIG.TX_DATA_ENCODING        64B66B \
    CONFIG.RX_DATA_DECODING        64B66B \
    CONFIG.TX_USER_DATA_WIDTH      64 \
    CONFIG.TX_INT_DATA_WIDTH       64 \
    CONFIG.RX_USER_DATA_WIDTH      64 \
    CONFIG.RX_INT_DATA_WIDTH       64 \
    CONFIG.TX_BUFFER_MODE          1 \
    CONFIG.RX_BUFFER_MODE          1 \
    CONFIG.TX_OUTCLK_SOURCE        TXOUTCLKPMA \
    CONFIG.FREERUN_FREQUENCY       100 \
    CONFIG.LOCATE_COMMON           CORE \
    CONFIG.LOCATE_RESET_CONTROLLER CORE \
    CONFIG.LOCATE_TX_USER_CLOCKING CORE \
    CONFIG.LOCATE_RX_USER_CLOCKING EXAMPLE_DESIGN \
    CONFIG.ENABLE_COMMON_USRCLK    0 \
] $ip
# TX and RX refclk sources must be set together (the IP validates that they match per quad)
set_property -dict [list CONFIG.TX_REFCLK_SOURCE $refsrc CONFIG.RX_REFCLK_SOURCE $refsrc] $ip
if {$do_byp} {
    set_property -dict [list CONFIG.TX_BUFFER_MODE 0 CONFIG.LOCATE_TX_BUFFER_BYPASS_CONTROLLER CORE] $ip
    set_property CONFIG.ENABLE_OPTIONAL_PORTS {loopback_in rxbufstatus_out rxresetdone_out txresetdone_out rxbufreset_in} $ip
} else {
    set_property CONFIG.ENABLE_OPTIONAL_PORTS {loopback_in rxbufstatus_out txbufstatus_out rxresetdone_out txresetdone_out rxbufreset_in} $ip
}

set fh [open "$ip_root/$name/${name}_config.txt" w]
foreach p [lsort [list_property $ip CONFIG.*]] {
    if {[string match *INTERNAL_PORT_ENABLED* $p]} continue
    puts $fh "$p = [get_property $p $ip]"
}
close $fh
foreach p {CHANNEL_ENABLE TX_MASTER_CHANNEL TX_REFCLK_SOURCE RX_REFCLK_SOURCE TX_PLL_TYPE TX_BUFFER_MODE RX_BUFFER_MODE
           TX_INT_DATA_WIDTH TX_OUTCLK_SOURCE LOCATE_TX_USER_CLOCKING LOCATE_RX_USER_CLOCKING
           LOCATE_TX_BUFFER_BYPASS_CONTROLLER ENABLE_OPTIONAL_PORTS} {
    puts "S6GEN: $name $p = [get_property CONFIG.$p $ip]"
}
generate_target all $ip
export_ip_user_files -of_objects $ip -no_script -sync -force -quiet
if {$do_synth} { create_ip_run $ip; synth_ip $ip; puts "S6GEN: dcp [glob -nocomplain $ip_root/$name/$name.dcp]" }
puts "S6GEN: done"
