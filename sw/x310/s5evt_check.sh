#!/bin/bash
# Stage 5 event-revision image (VERSION 2.0) on silicon (snoke): (A) back-to-back sessions, no retry, no pause: 8 dense
# captures (events off), each followed at once by an `info` session, failures counted; (B) sparse event runs evt_s102
# (no lead-in) and evt_s103 (lead-in) at K = 16; (C) dense captures with events ON at K = 16 (D-S5-EVK: v1 could not).
# Captures -> .scratch/s5_cap_evt, logs -> evidence/stage5/evt/silicon.
set -u
cd "$(dirname "$0")/../.."
source .scratch/uhd-install/env.sh
E=evidence/stage5/evt/silicon; C=.scratch/s5_cap_evt; mkdir -p $E $C
fail=0
for s in ${SEEDS-8 9 10 11 12 13 14 15}; do
  timeout 300 python3 sw/x310/nsclf_txrx.py run --seed $s --amp 0.05 --tx-gain 0 --rx-gain 30 --no-events --k 60000 \
    --lead 6291456 --out $C/sigL_s$s > $E/sigL_s$s.log 2>&1; r1=$?
  timeout 60 python3 sw/x310/nsclf_host.py info > $E/info_after_s$s.log 2>&1; r2=$?
  grep -q "Failure to create rfnoc_graph" $E/sigL_s$s.log $E/info_after_s$s.log && fail=$((fail + 1))
  echo "sigL_s$s rc=$r1 info rc=$r2"
done
echo "A: init failures $fail of 16 sessions"
for s in ${EVT-102 103}; do
  lead=0; [ $s = 103 ] && lead=6291456
  timeout 300 python3 sw/x310/nsclf_txrx.py run --seed $s --amp 0.05 --tx-gain 0 --rx-gain 30 --k 16 --gap-us 50 200 \
    --lead $lead --out $C/evt_s$s > $E/evt_s$s.log 2>&1; echo "evt_s$s rc=$? $(grep -h 'events received\|CAPTURE' $E/evt_s$s.log | tr '\n' ' ')"
done
for s in ${EVDENSE-8 9}; do
  timeout 300 python3 sw/x310/nsclf_txrx.py run --seed $s --amp 0.05 --tx-gain 0 --rx-gain 30 --k 16 --lead 6291456 \
    --out $C/sigLev_s$s > $E/sigLev_s$s.log 2>&1; echo "sigLev_s$s rc=$? $(grep -h 'events received\|CAPTURE\|errors' $E/sigLev_s$s.log | tr '\n' ' ' | cut -c1-300)"
done
