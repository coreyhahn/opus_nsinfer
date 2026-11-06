#!/bin/bash
# Run one UHD-flow xsim simulation (Vivado 2024.2 env of the Stage 5 X310 build) in a fresh copy of
# sw/x310/uhdsim/<dir> under .scratch/s5_uhdsim/<dir>_<top>/; log to evidence/stage5/block/uhdsim_<dir>_<top>.log.
# usage (snoke): sw/x310/uhdsim/run_uhdsim.sh <dir> <sim top> [make vars...]
set -o pipefail
P=$(cd "$(dirname "$0")/../../.." && pwd)
D=$1; TOP=$2; shift 2
W=$P/.scratch/s5_uhdsim/${D}_${TOP}
rm -rf "$W"; mkdir -p "$W"; cp "$P/sw/x310/uhdsim/$D/Makefile" "$W/"
source "$P/.scratch/s5_x300_env_2024_2.sh" > /dev/null || { echo "env setup failed"; exit 2; }
LOG=${UHDSIM_LOGDIR:-$P/evidence/stage5/block}/uhdsim_${D}_${TOP}.log
{ echo "# host=$(hostname) date=$(date -Is) $(vivado -version | head -1) uhd=$(git -C "$P/.scratch/uhd" rev-parse --short HEAD) top=$TOP";
  cd "$W" && make xsim PROJ="$P" SIM_TOP="$TOP" "$@" 2>&1; echo "make rc=$?"; } > "$LOG"
grep -h "^FIRST\|^RESULT\|PASS\|FAIL\|Fatal\|ERROR\|make rc" "$LOG" | head -20
