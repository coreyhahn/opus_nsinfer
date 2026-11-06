#!/usr/bin/env bash
# Run a list of training jobs on grumpy-calf, one container per job, each pinned to its own CPU slice.
# Run ON grumpy-calf, detached:
#   ssh grumpy-calf 'cd /home/cah/r2d2/code/fpga/opus_nsinfer && nohup sw/grumpy/launch_sweep.sh <jobs.txt> <cpus_per_job> > <log> 2>&1 &'
# jobs.txt: one job per line: <run_name> <args for $TRAIN ...>; output $RUNS/<run_name>/
# (an existing directory is an error: runs are never overwritten).
# CPUSETS="0-9 10-19 ..." (environment) gives the slots explicitly, for when other jobs hold some cores.
# TRAIN / RUNS (environment) select another training script and runs directory (default the Stage 2/4 ones);
# Stage 5: TRAIN=ref/x310/train_x310.py RUNS=ref/runs/x310.
set -euo pipefail
PROJ=$(cd "$(dirname "$0")/../.." && pwd)
JOBS=$1; CPJ=${2:-10}
TRAIN=${TRAIN:-ref/qec/train_qec.py}; RUNS=${RUNS:-ref/runs/qec}
NCPU=$(nproc); SLOTS=$((NCPU / CPJ))
read -r -a CS <<< "${CPUSETS:-}"
[[ ${#CS[@]} -gt 0 ]] && SLOTS=${#CS[@]}
mapfile -t L < <(grep -v '^\s*#' "$JOBS" | grep -v '^\s*$')
for l in "${L[@]}"; do n=${l%% *}; [[ -e $PROJ/$RUNS/$n ]] && { echo "ERROR: $RUNS/$n exists" >&2; exit 1; }; done
i=0
for l in "${L[@]}"; do
    n=${l%% *}; args=${l#* }
    slot=$((i % SLOTS)); c0=$((slot * CPJ)); c1=$((c0 + CPJ - 1))
    [[ ${#CS[@]} -gt 0 ]] && { c0=${CS[$slot]%-*}; c1=${CS[$slot]#*-}; }
    while [[ $(jobs -rp | wc -l) -ge $SLOTS ]]; do wait -n || true; done
    mkdir -p "$PROJ/$RUNS/$n"
    ( DOCKER_ARGS="--cpuset-cpus=$c0-$c1 --name nsinfer_$n" "$PROJ/container/run.sh" \
        "python $TRAIN --out $RUNS/$n $args" > "$PROJ/$RUNS/$n.log" 2>&1 \
        && echo "DONE $n" || echo "FAILED $n" ) &
    echo "START $n cpus $c0-$c1 $(date -Is)"
    i=$((i + 1))
done
wait
echo "SWEEP COMPLETE $(date -Is)"
