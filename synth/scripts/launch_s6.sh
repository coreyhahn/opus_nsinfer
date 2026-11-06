#!/usr/bin/env bash
# Launch one Stage 6 BCU-1525 loop build (s6_build.tcl, through route, no bitstream) detached ON snoke:
#   ssh -n snoke 'cd /home/cah/r2d2/code/fpga/opus_nsinfer && synth/scripts/launch_s6.sh <build_name> <LC> [directive] [d] [tx_reg] [rx_reg]' > /dev/null 2>&1
# Writes synth/out_<build_name>/ (an existing directory is an error): s3_shots.hex (tb/s3_make_mem.py, the Stage 3/4
# shot ROM of the golden vectors + expected decisions) with its sha256, then the Vivado run.
#   d = 3 (default): s6_gt (1 lane per cage), rtl/gen/qec_d3_lc<LC>, all d = 3 golden vectors.
#   d = 5: s6_gt3 (3 lanes per cage, DW = 192), rtl/gen/qec_d5_lc<LC>; D5_N / D5_SET as launch_s3.sh.
#   S6_TXBYP=1 (d = 3): the TX-buffer-bypass core s6_gt_bp (s6_build.tcl).
set -euo pipefail
PROJ=$(cd "$(dirname "$0")/../.." && pwd)
[[ $# -ge 2 ]] || { echo "usage: $0 <build_name> <LC> [directive] [3|5] [tx_reg] [rx_reg]" >&2; exit 1; }
NAME=$1; LC=$2; DIR=${3:-Default}; D=${4:-3}; TXR=${5:-0}; RXR=${6:-0}
[[ "$D" == 3 || "$D" == 5 ]] || { echo "ERROR: d must be 3 or 5" >&2; exit 1; }
[[ "$(hostname -s)" == snoke ]] || { echo "ERROR: run on snoke (VU9P licence)" >&2; exit 1; }
OUT=$PROJ/synth/out_$NAME
[[ -e "$OUT" ]] && { echo "ERROR: synth/out_$NAME exists; refusing to overwrite" >&2; exit 1; }
mkdir -p "$OUT"
if [[ "$D" == 3 ]]; then
    python3 "$PROJ/tb/s3_make_mem.py" --out "$OUT/s3_shots.hex" > "$OUT/mem.txt"
    sha256sum "$OUT/s3_shots.hex" "$PROJ/ref/golden/qec_d3_golden_in.hex" "$PROJ/ref/golden/qec_d3_golden_dec.hex" >> "$OUT/mem.txt"
elif [[ -n "${D5_SET:-}" ]]; then
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
echo "launch $(date -Is) host=$(hostname -s) git=$(git -C "$PROJ" rev-parse --short HEAD 2>/dev/null || echo none) d=$D lc=$LC directive=$DIR tx_reg=$TXR rx_reg=$RXR txbyp=${S6_TXBYP:-0}" > "$OUT/launch.txt"
sha256sum "$PROJ"/rtl/s6/*.sv "$PROJ"/rtl/s3/*.sv "$PROJ"/synth/constraints/s6_bcu1525.xdc "$PROJ"/rtl/ip/s6_gt*/s6_gt*.xci >> "$OUT/launch.txt"
nohup vivado -mode batch -nojournal -log "$OUT/vivado.log" -source "$PROJ/synth/scripts/s6_build.tcl" \
    -tclargs "$OUT" "$LC" "$DIR" "$D" "$TXR" "$RXR" > "$OUT/build.log" 2>&1 < /dev/null &
echo $! > "$OUT/vivado.pid"
echo "started $NAME pid $(cat "$OUT/vivado.pid"); log $OUT/build.log"
