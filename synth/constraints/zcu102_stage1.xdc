# ZCU102 (xczu9eg-ffvb1156-2-i) Stage 1 pins, clocks and exceptions for zcu102_top (docs/ARCHITECTURE.md §1, evidence/stage0/zcu102_io_report.md).

# ---- SI570 300 MHz (bank 64 HP, GC pins) ----
set_property PACKAGE_PIN AL8 [get_ports si570_clk_p]
set_property PACKAGE_PIN AL7 [get_ports si570_clk_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports {si570_clk_p si570_clk_n}]
create_clock -period 3.333 -name si570 [get_ports si570_clk_p]

# ---- PMOD pads (bank 47 HD, 3.3 V) ----
set_property PACKAGE_PIN A20 [get_ports pin_b]
set_property PACKAGE_PIN D20 [get_ports pin_c]
set_property PACKAGE_PIN F20 [get_ports {class_o[0]}]
set_property PACKAGE_PIN G20 [get_ports {class_o[1]}]
set_property PACKAGE_PIN J20 [get_ports {class_o[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pin_b pin_c class_o[*]}]
set_property DRIVE 12 [get_ports {pin_b pin_c class_o[*]}]
set_property SLEW FAST [get_ports {pin_b pin_c class_o[*]}]
# Pad flops stay in slices (docs/PLAN.md D-S1-IOB: the HD IOLOGIC FF Min Period is 8.000 ns,
# so IOB packing fails pulse-width checks above 125 MHz). stage1_build.tcl iob=iob overrides
# this for experiments; iob=fabric (default) adds datapath bounds that keep them at the pads.
set_property IOB FALSE [get_ports {pin_b pin_c class_o[*]}]
set_property IOB FALSE [get_cells pad_t_reg]

# ---- LEDs (bank 44 HD, 3.3 V): LED0 = MMCM locked, LED1 = heartbeat ----
set_property PACKAGE_PIN AG14 [get_ports {led[0]}]
set_property PACKAGE_PIN AF13 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

# ---- clocks ----
# clk_net (CLKOUT0) and clk_axi (= clk_net, or CLKOUT2 when AXI_DIV = 2) are synchronous and timed.
# clk_ps (CLKOUT1, fine phase shift) is the measurement fixture; Vivado sees it at phase 0.
# Exactly two clk_ps <-> fabric crossings stay timed as ordinary synchronous paths, because their
# routed delays (with clock skew) are model inputs (anchors.rpt, summary.json d_H / d_G):
#   l_tw (clk_ps) -> h_ff (clk_net)   and   c_tw (clk_net) -> g_ff (clk_ps).
# Every other crossing is a false path: arm synchroniser, pad loops opff_l->pin_b->ipff_b and
# opff_c->pin_c->ipff_d, p_g/p_d/pcnt/pg_valid/pd_valid -> AXI read registers, anything else.
set clk_ps_c  [get_clocks -of_objects [get_pins u_mmcm/CLKOUT1]]
set clk_fab_c [get_clocks -of_objects [get_pins {u_mmcm/CLKOUT0 u_mmcm/CLKOUT2}]]
# (Lists are kept small: clk_ps has few registers. h_ff's only D source is l_tw and g_ff's only
#  D source is c_tw, so the two anchors are the only crossings left timed.)
set_false_path -from [filter [all_registers -clock $clk_ps_c] {NAME !~ "*/l_tw_reg"}] -to $clk_fab_c
set_false_path -from $clk_fab_c -to [filter [all_registers -clock $clk_ps_c] {NAME !~ "*/g_ff_reg"}]

# No set_input_delay / set_output_delay on pin_b / pin_c: they are pad loopbacks (any input delay
# creates artificial hold violations on the dedicated IPFF path). Their buffer delays come from
# report_datasheet (clock-to-out) and stage1_build.tcl pad_paths (pad -> IPFF, unconstrained path).
# The OBUFT T->O arc is disabled and pad_t is a false-path source in stage1_build.tcl (post-synth).

# Decision class code and LEDs are observed quasi-statically (class settles with DEC_VALID).
set_false_path -to [get_ports {class_o[*] led[*]}]

# ---- bitstream (used only by stage1_bitstream.tcl) ----
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLNONE [current_design]
