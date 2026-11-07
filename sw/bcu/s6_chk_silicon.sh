#!/bin/bash
# Stage 6 d = 3 build <name> on the desk card (run on snoke): load, status, runs 1-2, re-train, run 3 (logs as s6_<name>_*).
# Same sequence as sw/bcu/s6d5_set_silicon.sh with the d = 3 command file. Stops at the first failing step.
set -euo pipefail
n=$1
cd /home/cah/r2d2/code/fpga/opus_nsinfer
O=synth/out_$n
S=evidence/stage6/silicon
sw/bcu/desk.sh program $O/s6_top.bit $O/s6_top.ltx > $S/program_${n}_1.log 2>&1
sw/bcu/desk.sh run sw/bcu/s6_status.cmd > $S/${n}_status_1.log 2>&1
sw/bcu/desk.sh run sw/bcu/s6_measure.cmd > $S/${n}_cable_run1.log 2>&1
sw/bcu/desk.sh run sw/bcu/s6_measure.cmd > $S/${n}_cable_run2.log 2>&1
sw/bcu/desk.sh run sw/bcu/s6_retrain.cmd > $S/${n}_retrain_1.log 2>&1
sw/bcu/desk.sh run sw/bcu/s6_measure.cmd > $S/${n}_cable_run3.log 2>&1
echo "$n DONE $(date -Is)"
