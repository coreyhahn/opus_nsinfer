#!/usr/bin/env bash
# Launch one Stage 1 ZCU102 build (stage1_build.tcl, through route, no bitstream) detached ON snoke:
#   ssh snoke 'cd /home/cah/r2d2/code/fpga/opus_nsinfer && synth/scripts/launch_stage1.sh <build_name> <F_NET_MHZ> <LC> [ARG_LAT] [key=value ...]'
# Writes synth/out_<build_name>/ (an existing directory is an error: outputs are never overwritten
# or reused); log in synth/out_<build_name>/build.log, Vivado PID in synth/out_<build_name>/vivado.pid.
# key=value options are passed to stage1_build.tcl (harness=, xbar=, depth=, place=, phys=, route=, iob=; iob=fabric is the default).
set -euo pipefail
PROJ=$(cd "$(dirname "$0")/../.." && pwd)
if [[ $# -lt 3 ]]; then
    echo "usage: $0 <build_name> <F_NET_MHZ> <LC> [ARG_LAT] [key=value ...]" >&2; exit 1
fi
NAME=$1; shift
if [[ "$(hostname -s)" != snoke ]]; then
    echo "ERROR: run on snoke (ZU9EG synthesis licence)" >&2; exit 1
fi
OUT=$PROJ/synth/out_$NAME
if [[ -e "$OUT" ]]; then
    echo "ERROR: synth/out_$NAME exists; refusing to overwrite" >&2; exit 1
fi
mkdir -p "$OUT"
set +u; source /home/cah/r2d2/sc2data/tools/Vivado/2024.2/settings64.sh; set -u  # Xilinx settings use unset vars
cd "$OUT"
echo "launch $(date -Is) host=$(hostname -s) git=$(git -C "$PROJ" rev-parse --short HEAD 2>/dev/null || echo none) args: $*" > "$OUT/launch.txt"
nohup vivado -mode batch -nojournal -log "$OUT/vivado.log" -source "$PROJ/synth/scripts/stage1_build.tcl" \
    -tclargs "$OUT" "$@" > "$OUT/build.log" 2>&1 < /dev/null &
echo $! > "$OUT/vivado.pid"
echo "started $NAME pid $(cat "$OUT/vivado.pid"); log $OUT/build.log"
