#!/bin/bash
# Stage 6 d = 5 vector set <k> on the desk card (run on snoke): load, status, runs 1-2, re-train, run 3.
# Same sequence as set 0 (evidence/stage6/README.md §7). Stops at the first failing step.
set -euo pipefail
k=$1
P=/home/cah/r2d2/code/fpga/opus_nsinfer
cd $P
O=synth/out_s6d5_lc3bc_set$k
S=evidence/stage6/silicon
t=s6d5_lc3bc_set$k
sw/bcu/desk.sh program $O/s6_top.bit $O/s6_top.ltx > $S/program_${t}_1.log 2>&1
sw/bcu/desk.sh run sw/bcu/s6_status.cmd > $S/${t}_status_1.log 2>&1
sw/bcu/desk.sh run sw/bcu/s6d5_measure.cmd > $S/${t}_cable_run1.log 2>&1
sw/bcu/desk.sh run sw/bcu/s6d5_measure.cmd > $S/${t}_cable_run2.log 2>&1
sw/bcu/desk.sh run sw/bcu/s6_retrain.cmd > $S/${t}_retrain_1.log 2>&1
sw/bcu/desk.sh run sw/bcu/s6d5_measure.cmd > $S/${t}_cable_run3.log 2>&1
echo "SET $k DONE $(date -Is)"
