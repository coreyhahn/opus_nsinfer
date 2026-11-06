#!/usr/bin/env bash
# Training sweep on snoke without the container (grumpy-calf unreachable 2026-11-03): one job per CPU slice
# (taskset), the project .venv. Run ON snoke, detached:
#   nohup sw/snoke_sweep.sh <jobs.txt> <first_cpu> <cpus_per_job> <slots> > <log> 2>&1 &
# TRAIN / RUNS as in sw/grumpy/launch_sweep.sh (Stage 5 measured channel: ref/x310/train_x310.py, ref/runs/x310_meas).
set -euo pipefail
PROJ=$(cd "$(dirname "$0")/.." && pwd); cd "$PROJ"
JOBS=$1; C0=$2; CPJ=$3; SLOTS=$4
TRAIN=${TRAIN:-ref/x310/train_x310.py}; RUNS=${RUNS:-ref/runs/x310_meas}
mapfile -t L < <(grep -v '^\s*#' "$JOBS" | grep -v '^\s*$')
for l in "${L[@]}"; do n=${l%% *}; [[ -e $RUNS/$n ]] && { echo "ERROR: $RUNS/$n exists" >&2; exit 1; }; done
i=0
for l in "${L[@]}"; do
    n=${l%% *}; args=${l#* }
    slot=$((i % SLOTS)); a=$((C0 + slot * CPJ)); b=$((a + CPJ - 1))
    while [[ $(jobs -rp | wc -l) -ge $SLOTS ]]; do wait -n || true; done
    mkdir -p "$RUNS/$n"
    ( taskset -c $a-$b .venv/bin/python $TRAIN --out $RUNS/$n $args > "$RUNS/$n.log" 2>&1 && echo "DONE $n $(date -Is)" || echo "FAILED $n $(date -Is)" ) &
    echo "START $n cpus $a-$b $(date -Is)"
    i=$((i + 1))
done
wait
echo "SWEEP COMPLETE $(date -Is)"
