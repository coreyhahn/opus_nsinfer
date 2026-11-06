# Stage 6 loop on the BCU-1525 (xcvu9p-fsgd2104-2L-e): s6_top, the thin GTY link. Pins as Stage 3
# (s3_bcu1525.xdc, Corundum fpga_au200.xdc; docs/BCU1525.md). One GT reference clock (QSFP0's MGTREFCLK1); QSFP1's
# refclk pins are not used (docs/PLAN.md D-S6-CLK). Lanes 1 and 2 (d = 5) come from s3_bcu1525_l3.xdc.

# ---- 300 MHz system clock (SI53340) -> init_clk (BUFGCE_DIV /3, derived automatically) ----
set_property -dict {PACKAGE_PIN AW20 IOSTANDARD LVDS} [get_ports clk_300_p]
set_property -dict {PACKAGE_PIN AW19 IOSTANDARD LVDS} [get_ports clk_300_n]
create_clock -period 3.333 -name clk_300 [get_ports clk_300_p]

# ---- the one GTY reference clock, 161.1328125 MHz from Si5335 U9 (FS = 10) ----
set_property PACKAGE_PIN K11 [get_ports qsfp0_refclk_p]
set_property PACKAGE_PIN K10 [get_ports qsfp0_refclk_n]
create_clock -period 6.206 -name qsfp0_refclk [get_ports qsfp0_refclk_p]

# ---- GTY lane 0 of each cage (the wizard's LOC constraints place the channels; the pins pin them too) ----
set_property PACKAGE_PIN N4 [get_ports {qsfp0_rx_p[0]}]
set_property PACKAGE_PIN N3 [get_ports {qsfp0_rx_n[0]}]
set_property PACKAGE_PIN N9 [get_ports {qsfp0_tx_p[0]}]
set_property PACKAGE_PIN N8 [get_ports {qsfp0_tx_n[0]}]
set_property PACKAGE_PIN U4 [get_ports {qsfp1_rx_p[0]}]
set_property PACKAGE_PIN U3 [get_ports {qsfp1_rx_n[0]}]
set_property PACKAGE_PIN U9 [get_ports {qsfp1_tx_p[0]}]
set_property PACKAGE_PIN U8 [get_ports {qsfp1_tx_n[0]}]

# ---- QSFP sideband, Si5335 select (LVCMOS12) ----
set_property -dict {PACKAGE_PIN AT20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {qsfp0_fs[0]}]
set_property -dict {PACKAGE_PIN AU22 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {qsfp0_fs[1]}]
set_property -dict {PACKAGE_PIN AR22 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {qsfp1_fs[0]}]
set_property -dict {PACKAGE_PIN AU20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {qsfp1_fs[1]}]
set_property -dict {PACKAGE_PIN AT22 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp0_refclk_reset]
set_property -dict {PACKAGE_PIN AR21 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp1_refclk_reset]
set_property -dict {PACKAGE_PIN BE16 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp0_modsell]
set_property -dict {PACKAGE_PIN BE17 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp0_resetl]
set_property -dict {PACKAGE_PIN BD18 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp0_lpmode]
set_property -dict {PACKAGE_PIN BE20 IOSTANDARD LVCMOS12 PULLUP true} [get_ports qsfp0_modprsl]
set_property -dict {PACKAGE_PIN BE21 IOSTANDARD LVCMOS12 PULLUP true} [get_ports qsfp0_intl]
set_property -dict {PACKAGE_PIN AY20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp1_modsell]
set_property -dict {PACKAGE_PIN BC18 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp1_resetl]
set_property -dict {PACKAGE_PIN AV22 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp1_lpmode]
set_property -dict {PACKAGE_PIN BC19 IOSTANDARD LVCMOS12 PULLUP true} [get_ports qsfp1_modprsl]
set_property -dict {PACKAGE_PIN AV21 IOSTANDARD LVCMOS12 PULLUP true} [get_ports qsfp1_intl]

# ---- LEDs ----
set_property -dict {PACKAGE_PIN BC21 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN BB21 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN BA20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[2]}]

set_false_path -to [get_ports {qsfp*_fs[*] qsfp*_refclk_reset qsfp*_modsell qsfp*_resetl qsfp*_lpmode led[*]}]
set_false_path -from [get_ports {qsfp*_modprsl qsfp*_intl}]

# ---- crossings between init_clk and the one loop clock (docs/PLAN.md D-S6-CLK, D-S3-CLK) ----
# The loop clock is the GT wizard's TX user clock (TXOUTCLK of the master channel, auto-derived from qsfp0_refclk);
# its net is s6_top's clk. Every crossing is a 2-flop ASYNC_REG synchroniser on quasi-static data (s3_regs, s6_diag),
# a Gray count (s3_freq) or a snapshot that is static when read: bound the datapath to one destination period.
set_max_delay -datapath_only 6.206  -from [get_clocks -of_objects [get_pins u_div3/O]] -to [get_clocks -of_objects [get_nets clk]]
set_max_delay -datapath_only 10.000 -from [get_clocks -of_objects [get_nets clk]] -to [get_clocks -of_objects [get_pins u_div3/O]]
set_false_path -hold -from [get_clocks -of_objects [get_pins u_div3/O]] -to [get_clocks -of_objects [get_nets clk]]
set_false_path -hold -from [get_clocks -of_objects [get_nets clk]] -to [get_clocks -of_objects [get_pins u_div3/O]]
# the wizard's reset-done / user-clock-active outputs enter clk through s6_top's 3-flop asynchronous-assert syncs
set_false_path -to [get_pins -of_objects [get_cells {rc_s_reg[*] rt_s_reg[*] rr_s_reg[*]}] -filter {REF_PIN_NAME == PRE}]
