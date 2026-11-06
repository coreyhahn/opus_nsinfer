#!/usr/bin/env bash
# Reproduce the committed numbers from the frozen models and golden vectors (no retraining by
# default). Each step names its host; run from darthplagueis (or any NFS host) with ssh access to
# snoke (Verilator, Vivado, the desk BCU-1525), grumpy-calf (Python container) and galen (ZCU102).
#
#   sw/reproduce.sh <stage> [...]     stage: 0 1 2 3 4 5 all   (silicon steps need the boards)
#   RETRAIN=1 sw/reproduce.sh 2       also re-sample Stim data and retrain (hours; numbers move by noise)
#
# Logs go to .scratch/<tag>/, never over the committed evidence. What each stage re-checks (evidence/<stage>/README.md has the committed results):
#   0  JSC export from ref/golden/jsc_hgq.keras -> RTL byte-identical (9 depths); Verilator 4x2 runs at lc1/3/5
#   1  ZCU102 silicon: load, bit-exact stream, negative controls, phase sweeps, L_pp solve (galen)
#   2  QEC d = 3 export -> RTL byte-identical; Verilator golden 4x2 + exhaustive 2^24 + negatives
#   3  BCU-1525 desk card: loop sim, build, gated bitstream, silicon run, analysis
#   4  QEC d = 5: RTL regeneration (lc3 + broadcast lc3bc) byte-identical; Verilator golden 4x2 + loop
#      (set 0); vector sets 1..3 reproduced byte for byte; re-analysis of the committed silicon logs;
#      the build / bitstream / silicon commands are printed (as stage 3)
#   5  X310 classifier: Verilator (classifier full set + stream, nsclf block 4x2 + negatives); if the captures are in
#      .scratch/s5_cap (sha256 in evidence/stage5/silicon/captures.sha256), the campaign-2 replays (silicon MISR
#      = RTL) and the analysis, compared with the committed summary; the X310 silicon commands are printed
set -euo pipefail
PROJ=$(cd "$(dirname "$0")/.." && pwd)
SN="ssh snoke cd $PROJ &&"
GC="ssh grumpy-calf cd $PROJ &&"
TAG=repro_$(date +%Y%m%d_%H%M%S)
mkdir -p "$PROJ/.scratch/$TAG"
log() { echo "== $(date -Is) $*"; }

stage0() {
    log "stage 0: JSC RTL regeneration (snoke, uv venv) and Verilator"
    $SN "uv run python ref/export_jsc.py --model ref/golden/jsc_hgq.keras --rtl-only --rtl-root .scratch/$TAG/gen --cutoffs 1 2 3 4 5 6 8 12 32"
    for c in 1 2 3 4 5 6 8 12 32; do diff -r "$PROJ/rtl/gen/jsc_lc$c" "$PROJ/.scratch/$TAG/gen/jsc_lc$c" >/dev/null && echo "jsc_lc$c byte-identical"; done
    for c in 1 3 5; do $SN "make -C tb jsc LC=$c LOGDIR=$PROJ/.scratch/$TAG/v0 JOBS=16"; done   # logs outside evidence/
}

stage1() {
    log "stage 1: ZCU102 silicon at 300 MHz (build s1_p300_lc3_f1; volatile PL load through the PS)"
    "$PROJ/sw/galen/run_stage1.sh" s1_p300_lc3_f1 "p300_$TAG"
    python3 "$PROJ/sw/analysis/solve_stage1.py" "s1_p300_lc3_f1:p300_$TAG"
}

stage2() {
    if [[ ${RETRAIN:-0} == 1 ]]; then
        log "stage 2: RETRAIN (grumpy-calf): Stim data, HGQ sweep g2, selection"
        $GC "container/run.sh 'python ref/qec/qec_data.py'"
        echo "train: sw/grumpy/launch_sweep.sh ref/qec/sweeps/g2.txt 10 (detached), then select_qec.py --margin 0.10 --max-ratio 1.0"
    fi
    log "stage 2: QEC d = 3 RTL regeneration from ref/golden/qec_d3_hgq.keras (grumpy-calf)"
    $GC "container/run.sh 'python ref/qec/export_qec.py --model ref/golden/qec_d3_hgq.keras --rtl-only --rtl-root .scratch/$TAG/gen --exhaustive --cutoffs 2 3 5 8 12'"
    for c in 2 3 5 8 12; do diff -r "$PROJ/rtl/gen/qec_d3_lc$c" "$PROJ/.scratch/$TAG/gen/qec_d3_lc$c" >/dev/null && echo "qec_d3_lc$c byte-identical"; done
    log "stage 2: Verilator gate (snoke): golden 4x2, exhaustive 2^24, negative controls"
    $SN "make -C tb qec LC=5 QLOGDIR=$PROJ/.scratch/$TAG/v2 JOBS=16 && make -C tb qec_exh LC=5 QLOGDIR=$PROJ/.scratch/$TAG/v2 JOBS=16"
}

stage3() {
    log "stage 3: loop sim (snoke)"
    $SN "make -C tb s3 LC=8 JOBS=16"
    log "stage 3: build + gated bitstream (snoke, ~45 min)"
    $SN "synth/scripts/launch_s3.sh s3_lc8_$TAG 8"
    echo "wait for synth/out_s3_lc8_$TAG/summary.json, then:"
    echo "  ssh snoke 'cd $PROJ/synth/out_s3_lc8_$TAG && vivado -mode batch -nojournal -source ../scripts/s3_bitstream.tcl -tclargs .'"
    echo "  ssh snoke 'cd $PROJ && sw/bcu/desk.sh program synth/out_s3_lc8_$TAG/s3_top.bit synth/out_s3_lc8_$TAG/s3_top.ltx'"
    echo "  ssh snoke 'cd $PROJ && sw/bcu/desk.sh run sw/bcu/s3_measure.cmd' > .scratch/$TAG/s3.log"
    echo "  python3 sw/analysis/s3_analyze.py --lc 8 .scratch/$TAG/s3.log"
    log "stage 3: re-analyse the committed silicon logs"
    python3 "$PROJ/sw/analysis/s3_analyze.py" --lc 8 "$PROJ"/evidence/stage3/silicon/s3_lc8_d_cable_run*.log
}

stage4() {
    log "stage 4: QEC d = 5 RTL regeneration from ref/golden/qec_d5_hgq.keras (grumpy-calf)"
    $GC "container/run.sh 'python ref/qec/export_qec_d5.py --rtl-only --golden ref/golden --rtl-root .scratch/$TAG/gen --cutoffs 3 --bcast-ratio 1.3'"
    for c in 3 3bc; do diff -r "$PROJ/rtl/gen/qec_d5_lc$c" "$PROJ/.scratch/$TAG/gen/qec_d5_lc$c" >/dev/null && echo "qec_d5_lc$c byte-identical"; done
    log "stage 4: Verilator (snoke): core golden 4x2, loop on set 0 (both clock orientations)"
    $SN "make -C tb qec5 LC=3bc Q5LOGDIR=$PROJ/.scratch/$TAG/v4 JOBS=16 && make -C tb s3d5 LC=3bc D5_LOGDIR=$PROJ/.scratch/$TAG/v4 JOBS=16"
    log "stage 4: vector sets 1..3 (needs .scratch/qec_d5_full_*.hex from the export)"
    python3 "$PROJ/tb/s4_vector_sets.py"
    echo "build / silicon (snoke, desk card), per set k in '' 1 2 3:"
    echo "  ssh snoke 'cd $PROJ && D5_N=131072 D5_SET=k synth/scripts/launch_s3.sh s4_$TAG 3bc Default 5'  (then s3_bitstream.tcl)"
    echo "  ssh snoke 'cd $PROJ && sw/bcu/desk.sh program ... && sw/bcu/desk.sh run sw/bcu/s4_measure.cmd' > .scratch/$TAG/s4.log"
    log "stage 4: re-analyse the committed silicon logs"
    python3 "$PROJ/sw/analysis/s3_analyze.py" --d 5 --lc 3bc "$PROJ"/evidence/stage4/silicon/s4_lc3bc_d_cable_run*.log
    for k in 1 2 3; do ls "$PROJ"/evidence/stage4/silicon/s4_lc3bc_set${k}_*.log >/dev/null 2>&1 && \
        python3 "$PROJ/sw/analysis/s3_analyze.py" --d 5 --lc 3bc_set$k --dec "$PROJ/.scratch/qec_d5_set${k}_dec.hex" "$PROJ"/evidence/stage4/silicon/s4_lc3bc_set${k}_*.log; done
}

stage5() {
    # v2 (measured-channel model, PLAN.md D-S5-CH, evidence/stage5/v2/). v1 (the 2026-11-03 gate) is reproduced by
    # this script at commit 2eba869 (its RTL and golden vectors were replaced by the v2 export).
    log "stage 5: data hashes (v2 'meas' set; the v1 'lpf' set) and the channel calibration"
    $SN "X310_CHANNEL=meas .venv/bin/python ref/x310/x310_data.py --w 64 --check" 2>&1 | grep CHECK
    $SN "X310_CHANNEL=lpf .venv/bin/python ref/x310/x310_data.py --w 64 --check" 2>&1 | grep CHECK
    log "stage 5: Verilator (snoke): classifier full set + stream 4x2, nsclf block 4x2 + negatives"
    $SN "make -C tb x310 LC=2 JOBS=12 XLOGDIR=$PROJ/evidence/stage5/v2/verilator" > "$PROJ/.scratch/$TAG/s5_x310.log" 2>&1
    $SN "make -C tb nsclf LC=2 JOBS=12 NSC_LOGDIR=$PROJ/evidence/stage5/v2/block" > "$PROJ/.scratch/$TAG/s5_nsclf.log" 2>&1
    log "stage 5: v2 silicon captures (not committed) and their hashes"
    if (cd "$PROJ/.scratch/s5_cap_v2" 2>/dev/null && sha256sum --quiet -c "$PROJ/evidence/stage5/v2/silicon/captures.sha256"); then
        for c in sigL_s{8..15} noise_s2 noise_s3 evt_s102 evt_s103; do
            python3 "$PROJ/sw/x310/nsclf_replay.py" --work "$PROJ/.scratch/nsclf_replay_v2/$c" replay \
                "$PROJ/.scratch/s5_cap_v2/$c" --dump > "$PROJ/.scratch/$TAG/replay_$c.log" 2>&1
            echo "$c $(tail -1 "$PROJ/.scratch/$TAG/replay_$c.log")"
        done
        mkdir -p "$PROJ/.scratch/$TAG/v2"
        python3 "$PROJ/sw/x310/nsclf_analyze.py" --cap "$PROJ/.scratch/s5_cap_v2" --replay "$PROJ/.scratch/nsclf_replay_v2" \
            --model-json "$PROJ/evidence/stage5/v2/model_ref.json" --stems sigL_s{8..15} evt_s102 evt_s103 noise_s2 noise_s3 --out "$PROJ/.scratch/$TAG/v2"
        diff -q "$PROJ/.scratch/$TAG/v2/summary.json" "$PROJ/evidence/stage5/v2/silicon/test/summary.json" \
            && echo "stage 5 v2 analysis identical to the committed summary"
    else
        echo "captures missing or changed: skip replay / analysis (evidence/stage5/v2/silicon/README.md has the results)"
    fi
    cat <<'EOT'
stage 5 silicon (X310 by snoke; volatile JTAG only, never uhd_image_loader):
  sw/x310/program_x310_jtag.sh <v2 x300.bit, evidence/stage5/v2/README.md> 25163513C6B0A
  (root, snoke) nmcli dev set enp132s0f0 managed no; ip addr add 192.168.40.1/24 dev enp132s0f0; ip link set enp132s0f0 mtu 9000
  sw/x310/s5v2_campaign.sh     # dense seeds 8-15 and 0-7, noise, events -> .scratch/s5_cap_v2, evidence/stage5/v2/silicon
EOT
}

[[ $# -ge 1 ]] || { sed -n 2,18p "$0"; exit 1; }
for s in "$@"; do
    case $s in
        0|1|2|3|4|5) "stage$s" ;;
        all) stage0; stage2; stage3; stage4; stage5; stage1 ;;
        *) echo "unknown stage $s" >&2; exit 1 ;;
    esac
done
