#!/bin/bash
# Regenerate the framework files of the nsclf block from rfnoc/blocks/nsclf.yml with UHD 4.9's rfnoc_modtool
# (clone .scratch/uhd at a5d1b2e, Python package .scratch/pyuhd, venv .scratch/venv-imgbuilder; see
# evidence/stage5/toolchain/README.md). Writes, in this repo:
#   rtl/x310/noc_shell_nsclf.sv    framework-generated noc_shell, copied verbatim
#   rtl/x310/rfnoc_block_nsclf.sv  the modtool block template, Mako widths fixed, User Logic = nsclf_user
# and keeps the whole generated OOT tree (incl. the UHD testbench template rfnoc_block_nsclf_tb.sv) in
# .scratch/s5_nsclf/rfnoc-nsclfgen. Usage: rfnoc/gen_nsclf.sh [--check]  (--check: compare only, no write)
set -euo pipefail
P=$(cd "$(dirname "$0")/.." && pwd)
S=$P/.scratch/s5_nsclf
source "$P/evidence/stage5/toolchain/pyuhd_env.sh"
PY=$P/.scratch/venv-imgbuilder/bin/python
MT=$P/.scratch/uhd/host/utils/rfnoc_modtool.py
mkdir -p "$S"
rm -rf "$S/rfnoc-nsclfgen"
(cd "$S" && "$PY" "$MT" create nsclfgen > create.log 2>&1)
cp "$P/rfnoc/blocks/nsclf.yml" "$S/rfnoc-nsclfgen/rfnoc/blocks/nsclf.yml"
"$PY" "$MT" -C "$S/rfnoc-nsclfgen" add nsclf > "$S/add.log" 2>&1
G=$S/rfnoc-nsclfgen/rfnoc/fpga/nsclfgen/rfnoc_block_nsclf
OUT=$S/out; mkdir -p "$OUT"
cp "$G/noc_shell_nsclf.sv" "$OUT/noc_shell_nsclf.sv"
python3 "$P/rfnoc/nsclf_block_from_template.py" "$G/rfnoc_block_nsclf.sv" "$OUT/rfnoc_block_nsclf.sv"
if [ "${1:-}" = "--check" ]; then
  diff -q "$OUT/noc_shell_nsclf.sv" "$P/rtl/x310/noc_shell_nsclf.sv" && diff -q "$OUT/rfnoc_block_nsclf.sv" "$P/rtl/x310/rfnoc_block_nsclf.sv" \
    && echo "CHECK: rtl/x310 noc_shell_nsclf.sv and rfnoc_block_nsclf.sv match a fresh generation"
else
  cp "$OUT/noc_shell_nsclf.sv" "$OUT/rfnoc_block_nsclf.sv" "$P/rtl/x310/"
  echo "wrote rtl/x310/noc_shell_nsclf.sv rtl/x310/rfnoc_block_nsclf.sv"
fi
