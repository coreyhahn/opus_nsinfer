# JTAG access to the DESK BCU-1525 (card #2) on snoke's hw_server: volatile programming and the
# s3_regs map over JTAG-to-AXI. Never writes flash (no cfgmem commands exist in this file), never
# opens the PCIe card's cable.
#   vivado -mode batch -nojournal -source sw/bcu/desk_jtag.tcl -tclargs list
#   vivado ... -tclargs program <serial> <bit> <ltx|->        program, then print ID/LINK
#   vivado ... -tclargs run <serial> <cmdfile>                 execute register commands (below)
# Run only through sw/bcu/desk.sh, which holds the desk-card lock.
#
# cmdfile lines:  w <addr> <data> | r <addr> [label] | wait <addr> <mask> <value> <timeout_s> | @stats
#                 | sleep <s> | hist <n> | flips <first> <count> | echo <text>
# Output lines:   R <addr> <data> <label>, HIST <bin> <count>, FLIP <seq> <seen> <flip>, ...
set PCIE_SERIAL 21440289J04F
lassign $argv cmd serial arg1 arg2

proc targets {} {
    set out {}
    foreach t [get_hw_targets -quiet] { lappend out $t }
    return $out
}
proc open_desk {serial} {
    global PCIE_SERIAL
    if {$serial eq "" || [string match "*$PCIE_SERIAL*" $serial]} {
        puts "ERROR: refusing target serial '$serial' (empty or the PCIe card)"; exit 2
    }
    set hits {}
    foreach t [targets] { if {[string match "*$serial*" $t]} { lappend hits $t } }
    if {[llength $hits] != 1} { puts "ERROR: serial $serial matches [llength $hits] targets: [targets]"; exit 2 }
    set t [lindex $hits 0]
    if {[string match "*$PCIE_SERIAL*" $t]} { puts "ERROR: $t is the PCIe card"; exit 2 }
    puts "TARGET $t"
    open_hw_target $t
    set dev [lindex [get_hw_devices -quiet xcvu9p*] 0]
    if {$dev eq ""} { puts "ERROR: no xcvu9p on $t"; close_hw_target; exit 3 }
    current_hw_device $dev
    refresh_hw_device -quiet $dev
    puts "DEVICE $dev"
    return $dev
}
proc axi {} {
    set a [lindex [get_hw_axis -quiet] 0]
    if {$a eq ""} { puts "ERROR: no JTAG-AXI master (bitstream loaded? probes refreshed?)"; exit 4 }
    return $a
}
set ::txn 0
proc rd {addr} {
    set n t[incr ::txn]
    create_hw_axi_txn $n [axi] -type read -address [format %08x $addr] -len 1 -force
    run_hw_axi -quiet [get_hw_axi_txns $n]
    set v [get_property DATA [get_hw_axi_txns $n]]
    delete_hw_axi_txn [get_hw_axi_txns $n]
    return [expr {"0x$v"}]
}
proc wr {addr data} {
    set n t[incr ::txn]
    create_hw_axi_txn $n [axi] -type write -address [format %08x $addr] -len 1 -data [format %08x $data] -force
    run_hw_axi -quiet [get_hw_axi_txns $n]
    delete_hw_axi_txn [get_hw_axi_txns $n]
}
proc rd_cmd {sel addr} {
    wr 0x014 [expr {($sel << 31) | $addr}]
    for {set i 0} {$i < 1000} {incr i} { if {!([rd 0x010] & 4)} { return [rd 0x018] } }
    puts "ERROR: RD_CMD $sel $addr never completed"; exit 5
}

open_hw_manager
connect_hw_server -url localhost:3121
switch -- $cmd {
    list {
        foreach t [targets] { puts "TARGETLIST $t" }
    }
    program {
        set dev [open_desk $serial]
        set bit [file normalize $arg1]
        if {![file exists $bit]} { puts "ERROR: $bit missing"; exit 1 }
        set_property PROGRAM.FILE $bit $dev
        if {$arg2 ne "" && $arg2 ne "-"} { set_property PROBES.FILE [file normalize $arg2] $dev }
        program_hw_devices $dev
        refresh_hw_device $dev
        puts "PROGRAM_OK $bit"
        puts [format "R 000 %08x ID" [rd 0x000]]
        puts [format "R 024 %08x LINK" [rd 0x024]]
    }
    run {
        set dev [open_desk $serial]
        set fh [open $arg1 r]
        while {[gets $fh line] >= 0} {
            set f [regexp -all -inline {\S+} $line]
            if {[llength $f] == 0 || [string index [lindex $f 0] 0] eq "#"} continue
            switch -- [lindex $f 0] {
                w     { wr [lindex $f 1] [lindex $f 2] }
                r     { puts [format "R %03x %08x %s" [lindex $f 1] [rd [lindex $f 1]] [lindex $f 2]] }
                sleep { after [expr {int([lindex $f 1] * 1000)}] }
                echo  { puts "ECHO [lrange $f 1 end]" }
                wait  {
                    lassign [lrange $f 1 end] a m v to
                    set t0 [clock milliseconds]; set ok 0
                    while {[clock milliseconds] - $t0 < $to * 1000} {
                        set x [rd $a]
                        if {($x & $m) == $v} { set ok 1; break }
                        after 50
                    }
                    puts [format "WAIT %03x mask %08x want %08x got %08x %s" $a $m $v $x [expr {$ok ? "OK" : "TIMEOUT"}]]
                    if {!$ok} { puts "ERROR: wait timed out"; exit 6 }
                }
                @stats {
                    foreach {a l} {0x010 STATUS 0x040 n_sent 0x044 n_rx_words 0x048 n_good 0x04C lat_min 0x050 lat_max
                                   0x054 lat_sum_lo 0x058 lat_sum_hi 0x05C mism 0x060 first_mis 0x064 err_tag
                                   0x068 err_range 0x06C err_overrun 0x070 err_dup 0x074 err_echo 0x078 hist_under
                                   0x07C hist_over 0x080 sig 0x0C0 b_n_rx 0x0C4 b_n_tx 0x0C8 b_err_tag 0x0CC b_fifo_ovf
                                   0x0D0 b_collide 0x0D4 b_fifo_max 0x0D8 b_dec 0x0DC b_dec_cnt 0x0E0 b_echo 0x0E4 b_echo_cnt
                                   0x008 GAP 0x00C HIST_BASE 0x024 LINK} {
                        puts [format "R %03x %08x %s" $a [rd $a] $l]
                    }
                }
                hist  { for {set b 0} {$b < [lindex $f 1]} {incr b} { puts "HIST $b [rd_cmd 0 $b]" } }
                flips {
                    for {set s [lindex $f 1]} {$s < [lindex $f 1] + [lindex $f 2]} {incr s} {
                        set v [rd_cmd 1 $s]; puts "FLIP $s [expr {($v >> 1) & 1}] [expr {$v & 1}]"
                    }
                }
                default { puts "ERROR: bad command '$line'"; exit 1 }
            }
        }
        close $fh
    }
    default { puts "ERROR: unknown command $cmd"; exit 1 }
}
catch {close_hw_target}
disconnect_hw_server
puts "DESK_JTAG_DONE"
