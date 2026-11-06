# 3-lane build only (s3_top DW = 192, aurora3_a / aurora3_b): lanes 1 and 2 of each cage, read after
# s3_bcu1525.xdc (which pins lane 0). Pins from docs/BCU1525.md (Corundum fpga_au200.xdc).
#   QSFP0 = quad 231: lane 1 = GTYE4_CHANNEL_X1Y49, lane 2 = X1Y50
#   QSFP1 = quad 230: lane 1 = GTYE4_CHANNEL_X1Y45, lane 2 = X1Y46
# Port bit i = cage lane i = the Aurora IP's rxp[i] (lane 0 at X1Y48 / X1Y44).
set_property PACKAGE_PIN M2 [get_ports {qsfp0_rx_p[1]}]
set_property PACKAGE_PIN M1 [get_ports {qsfp0_rx_n[1]}]
set_property PACKAGE_PIN M7 [get_ports {qsfp0_tx_p[1]}]
set_property PACKAGE_PIN M6 [get_ports {qsfp0_tx_n[1]}]
set_property PACKAGE_PIN L4 [get_ports {qsfp0_rx_p[2]}]
set_property PACKAGE_PIN L3 [get_ports {qsfp0_rx_n[2]}]
set_property PACKAGE_PIN L9 [get_ports {qsfp0_tx_p[2]}]
set_property PACKAGE_PIN L8 [get_ports {qsfp0_tx_n[2]}]
set_property PACKAGE_PIN T2 [get_ports {qsfp1_rx_p[1]}]
set_property PACKAGE_PIN T1 [get_ports {qsfp1_rx_n[1]}]
set_property PACKAGE_PIN T7 [get_ports {qsfp1_tx_p[1]}]
set_property PACKAGE_PIN T6 [get_ports {qsfp1_tx_n[1]}]
set_property PACKAGE_PIN R4 [get_ports {qsfp1_rx_p[2]}]
set_property PACKAGE_PIN R3 [get_ports {qsfp1_rx_n[2]}]
set_property PACKAGE_PIN R9 [get_ports {qsfp1_tx_p[2]}]
set_property PACKAGE_PIN R8 [get_ports {qsfp1_tx_n[2]}]
