#!/bin/bash
# Stage 5 nsclf block regression (Verilator, snoke): tb/tb_nsclf.sv on the committed golden stream.
# usage (from tb/, via make): run_nsclf.sh <binary> <logdir> <tag> <stimdir> [neg]
# Five configurations x 2 runs each; stimulus and expected values from sw/x310/nsclf_model.py stim;
# events (records and packets) checked by nsclf_model.py check-events. 'neg': the four negative controls instead.
# 2026-11 event revision: each configuration also sets EVT_FLUSH and the EVT_EN schedule ('on' = enabled during the
# configuration; 'toggle:f,..' = off from reset, switched on / off / on mid-stream at quiet points); EVT_BATCH = 16.
set -euo pipefail
BIN=$1; LOGDIR=$2; TAG=$3; STIMROOT=$4; MODE=${5:-pos}
P=$(cd "$(dirname "$0")/.." && pwd)
M="python3 $P/sw/x310/nsclf_model.py"
BATCH=16
mkdir -p "$LOGDIR" "$STIMROOT"
# seed chan K ready gap_p t0 flush evt_en  (ready: 0 always, 1 random 50 %, 2 long stalls -> drops)
#   seed 0: K = 16, flush 4096 (the reset value, not written): full and timed-out packets; the UHD xsim model
#   seed 1: flush 0: one record per packet (the v1 format), random back pressure
#   seed 2: K = 1, stalls of 20,000 cycles -> FIFO full, drops; full 16-record packets; events off -> on -> off -> on
#   seed 3: K = 64, flush 64: mostly lone records closed by the timeout; off -> on -> off -> on; time crosses 2^63
#   seed 4: K = 2, flush 1000, random back pressure; off from reset, on at 40 % of the stream
CONFIGS=(
  "0 0 16 0 0     0xFFFFF000          4096 on"
  "1 1 4  1 0.125 0x1FFFF0000         0    on"
  "2 0 1  2 0.125 0x1000              4096 toggle:0.25,0.6,0.7"
  "3 1 64 0 0.25  0x7FFFFFFFFFFF8000  64   toggle:0.2,0.45,0.7"
  "4 0 2  1 0     0xFFFFFFFFFFFE0000  1000 toggle:0.4"
)
hdr() { echo "# host=$(hostname) date=$(date -Is) verilator=$(verilator --version)"; \
        echo "# rtl_sha256=$(cat $P/rtl/x310/nsclf_core.sv $P/rtl/x310/nsclf_user.sv $P/rtl/x310/x310_stream.sv $P/rtl/x310/x310_clf_top.sv $P/rtl/gen/x310_clf_lanes.svh | sha256sum | cut -c1-64) golden=$(sha256sum $P/ref/golden/x310_stream_in.hex $P/ref/golden/x310_stream_out.hex $P/ref/golden/x310_stream_dec.hex | cut -c1-16 | tr '\n' ' ')"; }
stim() {  # seed chan K ready gap t0 flush evt_en -> stim dir
  local d=$STIMROOT/seed$1
  $M stim --out "$d" --seed "$1" --gap-p "$5" --k "$3" --t0 "$6" --flush "$7" --evt-en "$8" --batch $BATCH \
    > "$d.stim.log" 2>&1 || { cat "$d.stim.log"; exit 1; }
  echo "$d"
}
args() {  # stimdir seed chan K ready gap t0 flush evt_en
  local d=$1
  local nsw; nsw=$(python3 -c "import json;print(len(json.load(open('$d/meta.json'))['evt_switches']))")
  local fl=""; [ "$2" != 0 ] && fl="+FLUSH=$8"   # seed 0 keeps the reset value of REG_EVT_FLUSH (4096)
  echo "+STIM=$d +SEED=$2 +CHAN=$3 +K=$4 +READY=$5 +T0=$(python3 -c "print(format($7,'x'))") +NWIN=$(python3 -c "import json;print(json.load(open('$d/meta.json'))['n_windows'])") +NEVSW=$nsw $fl"
}
if [ "$MODE" = pos ]; then
  for c in "${CONFIGS[@]}"; do
    set -- $c
    d=$(stim "$@")
    for r in 1 2; do
      log=$LOGDIR/nsclf_${TAG}_seed$1_run$r.log
      { hdr; echo "# config seed=$1 chan=$2 K=$3 ready=$4 gap_p=$5 t0=$6 flush=$7 evt_en=$8 batch=$BATCH"; cat "$d.stim.log"; \
        "$BIN" $(args "$d" "$@"); } > "$log" 2>&1 || { tail -20 "$log"; echo "FAIL $log"; exit 1; }
      $M check-events --model "$d/events_model.json" --log "$log" >> "$log" 2>&1 || { tail -15 "$log"; echo "FAIL (events) $log"; exit 1; }
      echo "$(grep -h '^RESULT' "$log") | $(grep -h '^PACKETS' "$log") | $(grep -h '^EVENTS' "$log")"
    done
  done
else
  set -- ${CONFIGS[1]}
  d=$(stim "$@")
  log=$LOGDIR/nsclf_${TAG}_neg_decision.log
  if { hdr; "$BIN" $(args "$d" "$@") +CORRUPT=777; } > "$log" 2>&1; then echo "NEGATIVE CONTROL DID NOT FAIL ($log)"; exit 1; fi
  grep -q "^MISMATCH decision=777 " "$log" || { echo "decision negative control failed for another reason ($log)"; exit 1; }
  echo "NEGATIVE CONTROL (decision) failed as required: $(grep -m1 '^MISMATCH' "$log")"
  log=$LOGDIR/nsclf_${TAG}_neg_misr.log
  if { hdr; "$BIN" $(args "$d" "$@") +CORRUPT_WIN=1; } > "$log" 2>&1; then echo "NEGATIVE CONTROL DID NOT FAIL ($log)"; exit 1; fi
  grep -q "^REG_MISMATCH win0 MISR" "$log" || { echo "MISR negative control failed for another reason ($log)"; exit 1; }
  echo "NEGATIVE CONTROL (MISR) failed as required: $(grep -m1 '^REG_MISMATCH' "$log")"
  log=$LOGDIR/nsclf_${TAG}_neg_events.log
  { hdr; "$BIN" $(args "$d" "$@"); } > "$log" 2>&1 || { echo "neg_events base run failed ($log)"; exit 1; }
  if $M check-events --model "$d/events_model.json" --log "$log" --corrupt 5 >> "$log" 2>&1; then echo "NEGATIVE CONTROL DID NOT FAIL ($log)"; exit 1; fi
  echo "NEGATIVE CONTROL (events) failed as required: $(grep -m1 '^MISMATCH' "$log")"
  # batching: one bit of the second record of the first multi-record packet (seed 2: full 16-record packets)
  set -- ${CONFIGS[2]}
  d=$(stim "$@")
  log=$LOGDIR/nsclf_${TAG}_neg_packet.log
  { hdr; "$BIN" $(args "$d" "$@"); } > "$log" 2>&1 || { echo "neg_packet base run failed ($log)"; exit 1; }
  $M check-events --model "$d/events_model.json" --log "$log" > "$log.base" 2>&1 || { cat "$log.base"; echo "neg_packet base check failed"; exit 1; }
  rm -f "$log.base"
  if $M check-events --model "$d/events_model.json" --log "$log" --corrupt-pkt >> "$log" 2>&1; then echo "NEGATIVE CONTROL DID NOT FAIL ($log)"; exit 1; fi
  grep -q "^MISMATCH event seq .* field run" "$log" || { echo "packet negative control failed for another reason ($log)"; exit 1; }
  echo "NEGATIVE CONTROL (record inside a multi-record packet) failed as required: $(grep -m1 '^MISMATCH' "$log")"
fi
