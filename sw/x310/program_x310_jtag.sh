#!/bin/bash
# Volatile JTAG load of an X310 bitstream with Vivado 2024.2 (sw/x310/program_x310_jtag.tcl). Never flash:
# do NOT use uhd_image_loader (it writes the X310's flash). UNTESTED (no X310 reachable on 2026-10-30).
# After the load, the X310 must be re-enumerated by UHD (e.g. uhd_usrp_probe --args addr=192.168.10.2) and its
# FPGA image must match the host's FPGA compat (UHD 4.9 = 39.3, evidence/stage5/toolchain/README.md section 6).
# usage: sw/x310/program_x310_jtag.sh <x300.bit> <target substring|list> [hw_server url]
set -euo pipefail
D=$(cd "$(dirname "$0")" && pwd)
set +u  # settings64.sh reads unset variables (PYTHONPATH on snoke)
source /home/cah/r2d2/sc2data/tools/Vivado/2024.2/settings64.sh
set -u
cd "$(mktemp -d)"
vivado -mode batch -nojournal -source "$D/program_x310_jtag.tcl" -tclargs "$@"
