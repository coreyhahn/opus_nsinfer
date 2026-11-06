#!/bin/bash
# usage: s5_launch_x310.sh <base_dir> <make args...>   (run in background; logs to <base_dir>/make.log)
set -o pipefail
S=$(cd "$(dirname "$0")" && pwd)
BASE=$1; shift
source "$S/s5_x300_env_2024_2.sh" || { echo "env setup failed"; exit 2; }
cd "$S/uhd/fpga/usrp3/top/x300" || exit 2
echo "START $(date -Is) host=$(hostname) args: $*"
which vivado; vivado -version | head -3
time make "$@"
rc=$?
echo "END $(date -Is) rc=$rc"
exit $rc
