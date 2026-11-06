# UHD 4.9 RFNoC block testbench flow (xsim, Vivado 2024.2) for the whole nsclf block: tb/rfnoc_block_nsclf_tb.sv.
# Derived from the rfnoc_modtool-generated Makefile (.scratch/s5_nsclf/rfnoc-nsclfgen/rfnoc/fpga/nsclfgen/
# rfnoc_block_nsclf/Makefile). Needs the stimulus of tb_nsclf seed 0 (make -C tb nsclf LC=2 writes it).
# usage (snoke): sw/x310/uhdsim/run_uhdsim.sh nsclf rfnoc_block_nsclf_tb
PROJ ?= $(abspath ../../../..)
BASE_DIR = $(PROJ)/.scratch/uhd/fpga/usrp3/top
include $(BASE_DIR)/../tools/make/viv_sim_preamble.mak
include $(BASE_DIR)/../lib/rfnoc/core/Makefile.srcs
include $(BASE_DIR)/../lib/rfnoc/utils/Makefile.srcs
include $(PROJ)/rfnoc/fpga/nsclf/Makefile.srcs
DESIGN_SRCS += $(abspath $(RFNOC_SRCS) $(RFNOC_CORE_SRCS) $(RFNOC_UTIL_SRCS) $(RFNOC_BLOCK_NSCLF_SRCS))
INC_SRCS += $(PROJ)/rtl/gen/x310_clf_lanes.svh
SIM_TOP ?= rfnoc_block_nsclf_tb
SIM_SRCS = $(PROJ)/tb/rfnoc_block_nsclf_tb.sv
include $(BASE_DIR)/../tools/make/viv_simulator.mak
