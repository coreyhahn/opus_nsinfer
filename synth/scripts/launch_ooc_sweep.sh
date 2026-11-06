#!/usr/bin/env bash
# Run a list of OOC JSC builds in parallel. Run ON snoke, detached:
#   ssh snoke 'cd /home/cah/r2d2/code/fpga/opus_nsinfer && nohup synth/scripts/launch_ooc_sweep.sh <jobs.txt> [parallel] > synth/sweep_<tag>.log 2>&1 &'
# jobs.txt: one build per line: <build_name> <gen_dir> <part> <period_ns> [retime|-] [top] [wrap_file wrap_generics]
# Each build writes synth/out_<build_name>/; an existing directory is an error
# (outputs are never overwritten or reused).
set -euo pipefail
PROJ=$(cd "$(dirname "$0")/../.." && pwd)
JOBS=$1
PAR=${2:-8}
set +u; source /home/cah/r2d2/sc2data/tools/Vivado/2024.2/settings64.sh; set -u  # Xilinx settings use unset vars

while read -r name gen part period opts top wf wg; do
    [[ -z "$name" || "$name" == \#* ]] && continue
    if [[ -e "$PROJ/synth/out_$name" ]]; then
        echo "ERROR: synth/out_$name exists; refusing to overwrite" >&2
        exit 1
    fi
done < "$JOBS"

run_one() {
    local name=$1 gen=$2 part=$3 period=$4 opts=${5:-} top=${6:-} wf=${7:-} wg=${8:-}
    local out=$PROJ/synth/out_$name
    mkdir -p "$out"
    cd "$out"
    vivado -mode batch -nojournal -log vivado.log -source "$PROJ/synth/scripts/ooc_jsc.tcl" \
        -tclargs "$gen" "$part" "$period" "$out" "$opts" "$top" "$wf" "$wg" > stdout.txt 2>&1 || true
    if [[ -f "$out/summary.json" ]]; then echo "DONE $name $(cat "$out/summary.json")"; else echo "FAILED $name"; fi
}
export -f run_one
export PROJ
grep -v '^\s*#' "$JOBS" | grep -v '^\s*$' | xargs -P "$PAR" -L 1 bash -c 'run_one "$@"' _
echo "SWEEP COMPLETE $(date -Is)"
