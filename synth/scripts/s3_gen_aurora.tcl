# s3_gen_aurora.tcl -- generate the two Aurora 64B/66B cores for the BCU-1525
# (VCU1525 / Alveo U200 pinout) QSFP0 <-> QSFP1 loop over a QSFP+ 40G DAC.
#
#   core A = aurora_a : QSFP0, GTY quad 231 = Quad_X1Y12, lane 0 = GTYE4_CHANNEL_X1Y48,
#                       refclk MGTREFCLK1 of quad 231 (K11/K10, 161.1328125 MHz, Si5335 U9)
#   core B = aurora_b : QSFP1, GTY quad 230 = Quad_X1Y11, lane 0 = GTYE4_CHANNEL_X1Y44,
#                       refclk MGTREFCLK1 of quad 230 (P11/P10, 161.1328125 MHz, Si5335 U12)
#
# 1 lane, 10.3125 Gb/s, Streaming, Duplex, no flow control, no CRC, shared logic in
# core (SupportLevel 1), DRP Native (Disabled not offered for GTY; tie off), INIT_CLK 100 MHz (IP range 50..200 MHz).
#
# Stage 4 (d = 5, 192-bit user data): option l3 generates the 3-lane bonded cores instead,
#   core A = aurora3_a : QSFP0 lanes 0..2 = GTYE4_CHANNEL_X1Y48..X1Y50, same refclk (MGTREFCLK1, quad 231)
#   core B = aurora3_b : QSFP1 lanes 0..2 = GTYE4_CHANNEL_X1Y44..X1Y46, same refclk (MGTREFCLK1, quad 230)
#   everything else as the 1-lane cores (10.3125 Gb/s per lane, streaming, no CRC, no flow control).
#
# Usage (snoke, VU9P licence):
#   vivado -mode batch -nojournal -source synth/scripts/s3_gen_aurora.tcl \
#          -tclargs [l3] [exdes] [synth]
#   l3    : the 3-lane cores aurora3_a / aurora3_b (default: the 1-lane aurora_a / aurora_b)
#   exdes : also open_example_project for core A into .scratch/aurora_ex_a/ (.scratch/aurora3_ex_a/ with l3)
#   synth : also synth_ip both cores OOC; reports into .scratch/aurora_ooc/ (.scratch/aurora3_ooc/ with l3)
# Outputs: rtl/ip/aurora_a/, rtl/ip/aurora_b/ (or rtl/ip/aurora3_a/, rtl/ip/aurora3_b/): xci + products.

set script_dir [file dirname [file normalize [info script]]]
set proj_dir   [file normalize "$script_dir/../.."]
set ip_root    "$proj_dir/rtl/ip"
set part       xcvu9p-fsgd2104-2L-e
set do_exdes   [expr {[lsearch $argv exdes] >= 0}]
set do_synth   [expr {[lsearch $argv synth] >= 0}]
set do_l3      [expr {[lsearch $argv l3] >= 0}]

create_project -in_memory -part $part
set_property target_language Verilog [current_project]

set vlnv [lindex [lsort [get_ipdefs -all xilinx.com:ip:aurora_64b66b:*]] end]
puts "S3GEN: ipdef $vlnv"


# name quad start_lane enabled_channels
if {$do_l3} {
    set nlanes 3
    set pfx    aurora3
    set cores {
        aurora3_a Quad_X1Y12 X1Y48 {X1Y48 X1Y49 X1Y50}
        aurora3_b Quad_X1Y11 X1Y44 {X1Y44 X1Y45 X1Y46}
    }
} else {
    set nlanes 1
    set pfx    aurora
    set cores {
        aurora_a Quad_X1Y12 X1Y48 X1Y48
        aurora_b Quad_X1Y11 X1Y44 X1Y44
    }
}

foreach {name quad lane chans} $cores {
    file delete -force "$ip_root/$name"
    file mkdir $ip_root
    create_ip -vlnv $vlnv -module_name $name -dir $ip_root
    set ip [get_ips $name]
    set_property -dict [list \
        CONFIG.C_AURORA_LANES     $nlanes \
        CONFIG.C_LINE_RATE        {10.3125} \
        CONFIG.C_REFCLK_FREQUENCY {161.1328125} \
        CONFIG.C_INIT_CLK         {100} \
        CONFIG.C_START_QUAD       $quad \
        CONFIG.C_START_LANE       $lane \
        CONFIG.CHANNEL_ENABLE     $chans \
        CONFIG.C_REFCLK_SOURCE    "MGTREFCLK1_of_$quad" \
        CONFIG.interface_mode     {Streaming} \
        CONFIG.dataflow_config    {Duplex} \
        CONFIG.flow_mode          {None} \
        CONFIG.crc_mode           {false} \
        CONFIG.C_USER_K           {false} \
        CONFIG.SupportLevel       {1} \
        CONFIG.drp_mode           {Native} \
        CONFIG.C_USE_BYTESWAP     {false} \
        CONFIG.SINGLEEND_INITCLK  {true} \
        CONFIG.SINGLEEND_GTREFCLK {false} \
        CONFIG.C_USE_CHIPSCOPE    {false} \
    ] $ip
    foreach p {C_AURORA_LANES C_LINE_RATE C_REFCLK_FREQUENCY C_REFCLK_FREQUENCY_ACTUAL
               C_INIT_CLK C_START_QUAD C_START_LANE CHANNEL_ENABLE C_REFCLK_SOURCE
               C_GT_CLOCK_1 C_GT_LOC_1 C_PLL_TYPE interface_mode dataflow_config
               flow_mode crc_mode SupportLevel drp_mode DRP_FREQ C_USE_BYTESWAP
               SINGLEEND_INITCLK TransceiverControl C_GTWIZ_OUT C_GT_LOC_2 C_GT_LOC_3
               C_GT_LOC_4 C_LANE_WIDTH} {
        puts "S3GEN: $name $p = [get_property -quiet CONFIG.$p $ip]"
    }
    generate_target all $ip
    export_ip_user_files -of_objects $ip -no_script -sync -force -quiet
}

if {$do_exdes} {
    set ex_dir "$proj_dir/.scratch/${pfx}_ex_a"
    file delete -force $ex_dir
    open_example_project -force -dir $ex_dir [get_ips ${pfx}_a]
    puts "S3GEN: example project for ${pfx}_a in $ex_dir"
}

if {$do_synth} {
    set rpt "$proj_dir/.scratch/${pfx}_ooc"
    file mkdir $rpt
    foreach {name quad lane chans} $cores {
        set ip [get_ips $name]
        create_ip_run $ip
        synth_ip $ip
        set dcp [glob -nocomplain "$ip_root/$name/$name.dcp"]
        puts "S3GEN: $name dcp = $dcp"
    }
    close_project
    foreach {name quad lane chans} $cores {
        open_checkpoint "$ip_root/$name/$name.dcp"
        report_utilization -file "$rpt/${name}_util.rpt"
        set f [open "$rpt/${name}_gt.txt" w]
        foreach c [get_cells -hier -filter {REF_NAME =~ GTYE4_*}] {
            set l "[get_property REF_NAME $c] $c LOC=[get_property LOC $c]"
            puts $f $l; puts "S3GEN: $name $l"
        }
        set pw [dict create]
        foreach p [get_ports] {
            set k "[get_property DIRECTION $p] [regsub {\[[0-9]+\]$} [get_property NAME $p] {}]"
            dict incr pw $k
        }
        dict for {k n} $pw { puts $f "PORT $k width=$n" }
        close $f
        foreach c [get_cells -hier -filter {REF_NAME =~ BUFG*}] {
            puts "S3GEN: $name BUF [get_property REF_NAME $c] $c"
        }
        close_design
    }
}
puts "S3GEN: done"
