#!/bin/bash
# opus_nsinfer Stage 5: stand-in for uhd/fpga/usrp3/top/x300/setupenv.sh that selects the lab's
# Vivado 2024.2 (stock UHD 4.9 a5d1b2e asks for 2021.1_AR76780). Source it from a bash script.
VIVADO_VER=2024.2
VIVADO_VER_FULL=2024.2
DISPLAY_NAME="USRP-X3x0"
REPO_BASE_PATH=<repo>/.scratch/uhd/fpga/usrp3
declare -A PRODUCT_ID_MAP
PRODUCT_ID_MAP["X300"]="kintex7/xc7k325t/ffg900/-2"
PRODUCT_ID_MAP["X310"]="kintex7/xc7k410t/ffg900/-2"
export ARCH=kintex7
export PART_ID="xc7k410t/ffg900/-2"
source $REPO_BASE_PATH/tools/scripts/setupenv_base.sh --vivado-path=<xilinx-tools>/Vivado
