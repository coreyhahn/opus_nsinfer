# Stage 3 loop on the BCU-1525 (xcvu9p-fsgd2104-2L-e). Pins from Corundum fpga_au200.xdc
# (VCU1525 / U200 pinout), docs/BCU1525.md.

# ---- 300 MHz system clock (SI53340) -> init_clk (BUFGCE_DIV /3, derived automatically) ----
set_property -dict {PACKAGE_PIN AW20 IOSTANDARD LVDS} [get_ports clk_300_p]
set_property -dict {PACKAGE_PIN AW19 IOSTANDARD LVDS} [get_ports clk_300_n]
create_clock -period 3.333 -name clk_300 [get_ports clk_300_p]

# ---- GTY reference clocks, 161.1328125 MHz from the Si5335 (FS = 10) ----
set_property PACKAGE_PIN K11 [get_ports qsfp0_refclk_p]
set_property PACKAGE_PIN K10 [get_ports qsfp0_refclk_n]
set_property PACKAGE_PIN P11 [get_ports qsfp1_refclk_p]
set_property PACKAGE_PIN P10 [get_ports qsfp1_refclk_n]
create_clock -period 6.206 -name qsfp0_refclk [get_ports qsfp0_refclk_p]
create_clock -period 6.206 -name qsfp1_refclk [get_ports qsfp1_refclk_p]

# ---- GTY lane 0 of each cage (the Aurora IP places the channel; the pins pin it too) ----
# The GT ports are buses [0:NL-1] in s3_top (one bit for the 1-lane cores); lanes 1 and 2 of the
# 3-lane build are in s3_bcu1525_l3.xdc.
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

# static board pins: no timing
set_false_path -to [get_ports {qsfp*_fs[*] qsfp*_refclk_reset qsfp*_modsell qsfp*_resetl qsfp*_lpmode led[*]}]
set_false_path -from [get_ports {qsfp*_modprsl qsfp*_intl}]

# ---- clock-domain crossings (docs/PLAN.md D-S3-CLK) ----
# init_clk, user_clk A and user_clk B are unrelated. Every crossing between them is a 2-flop
# ASYNC_REG synchroniser on quasi-static data (s3_regs) or a Gray count (s3_freq): bound the
# datapath to one destination period instead of cutting it, so a mis-routed bus still shows.
# (XDC has no foreach: one line per pair.) Hold is not checked across these unrelated clocks.
# The cores sit in a generate block of s3_top (g_l1.u_aur_a for 1 lane, g_l3.u_aur_a for 3): *u_aur_a.
set_max_delay -datapath_only 6.206 -from [get_clocks -of_objects [get_pins u_div3/O]] -to [get_clocks -of_objects [get_pins *u_aur_a/user_clk_out]]
set_max_delay -datapath_only 6.206 -from [get_clocks -of_objects [get_pins u_div3/O]] -to [get_clocks -of_objects [get_pins *u_aur_b/user_clk_out]]
set_max_delay -datapath_only 10.000 -from [get_clocks -of_objects [get_pins *u_aur_a/user_clk_out]] -to [get_clocks -of_objects [get_pins u_div3/O]]
set_max_delay -datapath_only 10.000 -from [get_clocks -of_objects [get_pins *u_aur_b/user_clk_out]] -to [get_clocks -of_objects [get_pins u_div3/O]]
set_false_path -hold -from [get_clocks -of_objects [get_pins u_div3/O]] -to [get_clocks -of_objects [get_pins *u_aur_a/user_clk_out]]
set_false_path -hold -from [get_clocks -of_objects [get_pins u_div3/O]] -to [get_clocks -of_objects [get_pins *u_aur_b/user_clk_out]]
set_false_path -hold -from [get_clocks -of_objects [get_pins *u_aur_a/user_clk_out]] -to [get_clocks -of_objects [get_pins u_div3/O]]
set_false_path -hold -from [get_clocks -of_objects [get_pins *u_aur_b/user_clk_out]] -to [get_clocks -of_objects [get_pins u_div3/O]]
