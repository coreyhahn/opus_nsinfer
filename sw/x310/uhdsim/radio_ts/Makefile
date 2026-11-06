# UHD 4.9 xsim flow (Vivado 2024.2) for tb/tb_radio_ts.sv on UHD's own radio_core.
# Derived from .scratch/uhd/fpga/usrp3/lib/rfnoc/blocks/rfnoc_block_radio/Makefile (same sources, own top).
# usage (snoke): sw/x310/uhdsim/run_uhdsim.sh radio_ts <tb_radio_ts_cg1|tb_radio_ts_cg0>
PROJ ?= $(abspath ../../../..)
BASE_DIR = $(PROJ)/.scratch/uhd/fpga/usrp3/top
include $(BASE_DIR)/../tools/make/viv_sim_preamble.mak
include $(BASE_DIR)/../lib/rfnoc/core/Makefile.srcs
include $(BASE_DIR)/../lib/rfnoc/utils/Makefile.srcs
include $(BASE_DIR)/../lib/rfnoc/blocks/rfnoc_block_radio/Makefile.srcs
include $(BASE_DIR)/../lib/axi4s_sv/Makefile.srcs
DESIGN_SRCS += $(abspath $(RFNOC_CORE_SRCS) $(RFNOC_UTIL_SRCS) $(RFNOC_BLOCK_RADIO_SRCS) $(AXI4S_SV_SRCS))
SIM_TOP ?= tb_radio_ts_cg1
SIM_SRCS = $(PROJ)/tb/tb_radio_ts.sv $(PROJ)/tb/tb_radio_ts_tops.sv
include $(BASE_DIR)/../tools/make/viv_simulator.mak
