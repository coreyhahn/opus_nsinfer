# Stage 1 block design ps_bd: ZU+ PS (zcu102 preset, HPM0_FPD 128 b) -> converter -> external AXI4-Lite 32 b master M_AXI (21-bit, 0xA000_0000).
#   source stage1_bd.tcl inside an open project; needs: bd_freq_hz (clk_axi in Hz), bd_xbar (smartconnect | interconnect)
# Ports of the generated ps_bd_wrapper: clk_axi (in), aresetn (in), M_AXI_* (AXI4-Lite master).
# pl_clk0 stays enabled (preset) but drives nothing; HPM0 and the converter run on clk_axi from the PL MMCM.

create_bd_design ps_bd

create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.5 zynq_ps
apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e \
    -config {apply_board_preset "1"} [get_bd_cells zynq_ps]
# galen's FSBL programs AFI_FS = 0x00000A00 (HPM0/HPM1 128 b); the PL bitstream does not
# reconfigure the PS, so the width here must stay 128.
set_property -dict [list \
    CONFIG.PSU__USE__M_AXI_GP0 {1} \
    CONFIG.PSU__MAXIGP0__DATA_WIDTH {128} \
    CONFIG.PSU__USE__M_AXI_GP1 {0} \
    CONFIG.PSU__USE__M_AXI_GP2 {0} \
] [get_bd_cells zynq_ps]

create_bd_port -dir I -type clk -freq_hz $bd_freq_hz clk_axi
create_bd_port -dir I -type rst aresetn
set_property CONFIG.POLARITY ACTIVE_LOW [get_bd_ports aresetn]

create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI
set_property -dict [list \
    CONFIG.PROTOCOL {AXI4LITE} \
    CONFIG.ADDR_WIDTH {21} \
    CONFIG.DATA_WIDTH {32} \
    CONFIG.FREQ_HZ $bd_freq_hz \
    CONFIG.HAS_PROT {1} \
] [get_bd_intf_ports M_AXI]
set_property -dict [list CONFIG.ASSOCIATED_BUSIF {M_AXI} CONFIG.ASSOCIATED_RESET {aresetn}] \
    [get_bd_ports clk_axi]

if {$bd_xbar eq "smartconnect"} {
    create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 xbar
    set_property -dict [list CONFIG.NUM_SI {1} CONFIG.NUM_MI {1} CONFIG.NUM_CLKS {1}] [get_bd_cells xbar]
    connect_bd_net [get_bd_ports clk_axi] [get_bd_pins xbar/aclk]
    connect_bd_net [get_bd_ports aresetn] [get_bd_pins xbar/aresetn]
} else {
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 xbar
    set_property -dict [list CONFIG.NUM_SI {1} CONFIG.NUM_MI {1}] [get_bd_cells xbar]
    foreach p {ACLK S00_ACLK M00_ACLK} { connect_bd_net [get_bd_ports clk_axi] [get_bd_pins xbar/$p] }
    foreach p {ARESETN S00_ARESETN M00_ARESETN} { connect_bd_net [get_bd_ports aresetn] [get_bd_pins xbar/$p] }
}
connect_bd_net [get_bd_ports clk_axi] [get_bd_pins zynq_ps/maxihpm0_fpd_aclk]
connect_bd_intf_net [get_bd_intf_pins zynq_ps/M_AXI_HPM0_FPD] [get_bd_intf_pins xbar/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins xbar/M00_AXI] [get_bd_intf_ports M_AXI]

assign_bd_address -target_address_space /zynq_ps/Data [get_bd_addr_segs M_AXI/Reg]
set seg [get_bd_addr_segs zynq_ps/Data/SEG_M_AXI_Reg]
set_property offset 0xA0000000 $seg
set_property range 2M $seg

validate_bd_design
save_bd_design
