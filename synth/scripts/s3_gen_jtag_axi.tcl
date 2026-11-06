# Generate the JTAG-to-AXI master (AXI4-Lite, 32 bit) that reads and writes s3_regs over the BCU-1525's
# USB JTAG: no PCIe, no MicroBlaze. Output: rtl/ip/s3_jtag_axi/ (xci + products).
#   vivado -mode batch -nojournal -source synth/scripts/s3_gen_jtag_axi.tcl
set proj [file normalize [file join [file dirname [info script]] ../..]]
set part xcvu9p-fsgd2104-2L-e
set ipdir $proj/rtl/ip
file mkdir $ipdir
create_project -in_memory -part $part
set_property target_language Verilog [current_project]
if {[file exists $ipdir/s3_jtag_axi]} { puts "ERROR: $ipdir/s3_jtag_axi exists; refusing to overwrite"; exit 1 }
create_ip -name jtag_axi -vendor xilinx.com -library ip -module_name s3_jtag_axi -dir $ipdir
set_property -dict [list CONFIG.PROTOCOL {2} CONFIG.M_AXI_DATA_WIDTH {32} CONFIG.M_AXI_ADDR_WIDTH {32}] [get_ips s3_jtag_axi]
generate_target all [get_ips s3_jtag_axi]
synth_ip [get_ips s3_jtag_axi]
puts "IPDEF [get_property IPDEF [get_ips s3_jtag_axi]]"
puts "STUB [glob -nocomplain $ipdir/s3_jtag_axi/*_stub.v]"
puts "JTAG_AXI_DONE"
