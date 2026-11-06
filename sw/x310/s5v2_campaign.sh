#!/bin/bash
# Stage 5 v2 silicon campaign (snoke, measured-channel model; PLAN.md D-S5-CH): dense signal set with the 31.5 ms TX
# lead-in, fresh seeds 8-15 (the test; seeds 0-7 calibrated the channel) and seeds 0-7 again (v1 comparison on the
# same TX), two noise-only captures, two sparse event runs (K = 16). Captures -> .scratch/s5_cap_v2, logs ->
# evidence/stage5/v2/silicon. Needs the v2 image loaded (sw/x310/program_x310_jtag.sh).
# Session init sometimes fails right after a previous session (Radio#0 ctrl ACK timeout, "Failure to create
# rfnoc_graph"; the v1 image does the same, evidence/stage5/v2/README.md): the capture then never starts, so the
# item is retried (RETRIES, PAUSE s apart), and after that once more after a volatile JTAG reload of BIT (if set).
set -u
cd "$(dirname "$0")/../.."
source .scratch/uhd-install/env.sh
E=evidence/stage5/v2/silicon; C=.scratch/s5_cap_v2; mkdir -p $E $C $E/failed_init
SEEDS=${SEEDS-"8 9 10 11 12 13 14 15 0 1 2 3 4 5 6 7"}; NOISE=${NOISE-"2 3"}; EVT=${EVT-"102 103"}
RETRIES=${RETRIES:-6}; PAUSE=${PAUSE:-20}; BIT=${BIT:-}
# event runs without the TX lead-in by default (as v1): with it, the DC step at TX start makes ~5e4 events before the
# capture window (the host then overflows, evt_s102 first try)
EVT_LEAD=${EVT_LEAD:-0}
item() {  # name, command...
  local n=$1; shift
  for t in $(seq 1 $((RETRIES + 1))); do
    "$@" > $E/$n.log 2>&1; local rc=$?
    if [ $rc -eq 0 ] || ! grep -q "Failure to create rfnoc_graph" $E/$n.log; then echo "$n rc=$rc try=$t"; return; fi
    cp $E/$n.log $E/failed_init/$n.try$t.log
    if [ $t -eq $RETRIES ] && [ -n "$BIT" ]; then
      sw/x310/program_x310_jtag.sh "$BIT" 25163513C6B0A > $E/failed_init/$n.jtag_reload.log 2>&1; echo "$n: JTAG reload"
    fi
    sleep $PAUSE
  done
  echo "$n FAILED after $t tries"
}
for s in $SEEDS; do
  item sigL_s$s timeout 300 python3 sw/x310/nsclf_txrx.py run --seed $s --amp 0.05 --tx-gain 0 --rx-gain 30 --no-events \
    --k 60000 --lead 6291456 --out $C/sigL_s$s
done
for s in $NOISE; do
  item noise_s$s timeout 120 python3 sw/x310/nsclf_host.py capture --n 4210688 --freq 1e9 --gain 30 --antenna RX2 \
    --dc-offset auto --no-events --k 60000 --out $C/noise_s$s
done
for s in $EVT; do
  item evt_s$s timeout 300 python3 sw/x310/nsclf_txrx.py run --seed $s --amp 0.05 --tx-gain 0 --rx-gain 30 --k 16 \
    --gap-us 50 200 --lead $EVT_LEAD --out $C/evt_s$s
done
