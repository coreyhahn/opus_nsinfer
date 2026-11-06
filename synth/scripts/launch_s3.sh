#!/usr/bin/env bash
# Launch one Stage 3 BCU-1525 loop build (s3_build.tcl, through route, no bitstream) detached ON snoke:
#   ssh snoke 'cd /home/cah/r2d2/code/fpga/opus_nsinfer && synth/scripts/launch_s3.sh <build_name> <LC> [directive] [d]'
# Writes synth/out_<build_name>/ (an existing directory is an error): s3_shots.hex (golden vectors +
# expected decisions, tb/s3_make_mem.py) with its sha256, then the Vivado run.
#   d = 3 (default, Stage 3): 1-lane cores, rtl/gen/qec_d3_lc<LC>, all d = 3 golden vectors.
#   d = 5: 3-lane cores (DW = 192); LC = a cutoff of rtl/gen/qec_d5_lc<LC> (ref/golden/qec_d5_golden_*),
#          or LC = standin: the TEST-ONLY synthetic core tb/qec_d5_standin.sv on D5_N random vectors
#          (tb/qec_d5_standin_gen.py; link / timing checks only, s3_bitstream.tcl refuses it).
#          D5_N (environment) = number of shots in the ROM: default all golden vectors, 65536 for standin.
#          D5_SET=<k> (environment): shots from Stage 4 vector set k (tb/s4_vector_sets.py) instead of the golden set.
set -euo pipefail
PROJ=$(cd "$(dirname "$0")/../.." && pwd)
[[ $# -ge 2 ]] || { echo "usage: $0 <build_name> <LC|standin> [directive] [3|5]" >&2; exit 1; }
NAME=$1; LC=$2; DIR=${3:-Default}; D=${4:-3}
[[ "$D" == 3 || "$D" == 5 ]] || { echo "ERROR: d must be 3 or 5" >&2; exit 1; }
[[ "$LC" != standin || "$D" == 5 ]] || { echo "ERROR: standin is d = 5 only" >&2; exit 1; }
[[ "$(hostname -s)" == snoke ]] || { echo "ERROR: run on snoke (VU9P licence)" >&2; exit 1; }
OUT=$PROJ/synth/out_$NAME
[[ -e "$OUT" ]] && { echo "ERROR: synth/out_$NAME exists; refusing to overwrite" >&2; exit 1; }
mkdir -p "$OUT"
if [[ "$D" == 3 ]]; then
    python3 "$PROJ/tb/s3_make_mem.py" --out "$OUT/s3_shots.hex" > "$OUT/mem.txt"
    sha256sum "$OUT/s3_shots.hex" "$PROJ/ref/golden/qec_d3_golden_in.hex" "$PROJ/ref/golden/qec_d3_golden_dec.hex" >> "$OUT/mem.txt"
elif [[ "$LC" == standin ]]; then
    N=${D5_N:-65536}
    python3 "$PROJ/tb/qec_d5_standin_gen.py" --n "$N" --out "$OUT/standin" > "$OUT/mem.txt"
    python3 "$PROJ/tb/s3_make_mem.py" --d 5 --in "$OUT/standin/qec_d5_standin_in.hex" \
        --dec "$OUT/standin/qec_d5_standin_dec.hex" --out "$OUT/s3_shots.hex" >> "$OUT/mem.txt"
    sha256sum "$OUT/s3_shots.hex" "$OUT/standin/qec_d5_standin_in.hex" "$OUT/standin/qec_d5_standin_dec.hex" >> "$OUT/mem.txt"
elif [[ -n "${D5_SET:-}" ]]; then   # Stage 4 vector set 1..3 (tb/s4_vector_sets.py, ref/golden/qec_d5_sets.json)
    SI=$PROJ/.scratch/qec_d5_set${D5_SET}_in.hex; SD=$PROJ/.scratch/qec_d5_set${D5_SET}_dec.hex
    python3 "$PROJ/tb/s3_make_mem.py" --d 5 --in "$SI" --dec "$SD" ${D5_N:+--nvec "$D5_N"} --out "$OUT/s3_shots.hex" > "$OUT/mem.txt"
    sha256sum "$OUT/s3_shots.hex" "$SI" "$SD" >> "$OUT/mem.txt"
    echo "set$D5_SET" > "$OUT/vector_set.txt"
else
    python3 "$PROJ/tb/s3_make_mem.py" --d 5 ${D5_N:+--nvec "$D5_N"} --out "$OUT/s3_shots.hex" > "$OUT/mem.txt"
    sha256sum "$OUT/s3_shots.hex" "$PROJ/ref/golden/qec_d5_golden_in.hex" "$PROJ/ref/golden/qec_d5_golden_dec.hex" >> "$OUT/mem.txt"
fi
set +u; source /home/cah/r2d2/sc2data/tools/Vivado/2024.2/settings64.sh; set -u
cd "$OUT"
echo "launch $(date -Is) host=$(hostname -s) git=$(git -C "$PROJ" rev-parse --short HEAD 2>/dev/null || echo none) d=$D lc=$LC directive=$DIR" > "$OUT/launch.txt"
nohup vivado -mode batch -nojournal -log "$OUT/vivado.log" -source "$PROJ/synth/scripts/s3_build.tcl" \
    -tclargs "$OUT" "$LC" "$DIR" "$D" > "$OUT/build.log" 2>&1 < /dev/null &
echo $! > "$OUT/vivado.pid"
echo "started $NAME pid $(cat "$OUT/vivado.pid"); log $OUT/build.log"
