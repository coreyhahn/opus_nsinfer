#!/usr/bin/env bash
# Stage 2 Verilator gate, run ON snoke: for every cutoff, the golden test vectors (4 seeds x 2 runs,
# logit and flip checked), the exhaustive 2^24 inputs (seeds 0 and 1), and two negative controls
# that must fail (one expected-logit bit flipped; one expected-decision bit flipped).
#   ssh snoke 'cd /home/cah/r2d2/code/fpga/opus_nsinfer && nohup tb/run_qec_stage2.sh 5 3 2 > evidence/stage2/verilator/run.txt 2>&1 &'
set -uo pipefail
PROJ=$(cd "$(dirname "$0")/.." && pwd)
EV=$PROJ/evidence/stage2/verilator
G=$PROJ/ref/golden
NEG=$PROJ/.scratch/qec_neg
mkdir -p "$EV" "$NEG"
# negative-control vector files (derived from the committed golden hex, never written back)
python3 - "$G" "$NEG" <<'PY'
import sys
g, n = sys.argv[1], sys.argv[2]
out = open(f'{g}/qec_d3_golden_out.hex').read().split()
dec = open(f'{g}/qec_d3_golden_dec.hex').read().split()
w = len(out[421])
out[421] = format(int(out[421], 16) ^ (1 << 5), f'0{w}x')
dec[777] = format(int(dec[777], 16) ^ 1, 'x')
open(f'{n}/neg_out.hex', 'w').write('\n'.join(out) + '\n')
open(f'{n}/neg_dec.hex', 'w').write('\n'.join(dec) + '\n')
PY
NV=$(python3 -c "import json;print(json.load(open('$G/qec_d3_golden.json'))['n_vectors'])")
fail=0
for LC in "$@"; do
    echo "=== LC=$LC $(date -Is)"
    make -C "$PROJ/tb" qec LC="$LC" JOBS=16 || fail=1
    make -C "$PROJ/tb" qec_exh LC="$LC" JOBS=16 || fail=1
    B=$PROJ/tb/obj_dir_qec_lc${LC}_n$NV/Vtb_qec
    log=$EV/qec_d3_lc${LC}_negative.log
    { echo "# host=$(hostname) date=$(date -Is) negative controls: neg_out = expected logit of vector 421 bit 5 flipped; neg_dec = expected flip of vector 777 inverted; each must report a mismatch and exit non-zero"
      echo "# neg_out_sha256=$(sha256sum $NEG/neg_out.hex | cut -c1-64) neg_dec_sha256=$(sha256sum $NEG/neg_dec.hex | cut -c1-64)"
      "$B" +IN=$G/qec_d3_golden_in.hex +OUT=$NEG/neg_out.hex +DEC=$G/qec_d3_golden_dec.hex +SEED=0; echo "EXIT $?"
      "$B" +IN=$G/qec_d3_golden_in.hex +OUT=$G/qec_d3_golden_out.hex +DEC=$NEG/neg_dec.hex +SEED=1; echo "EXIT $?"; } > "$log" 2>&1
    grep -c "EXIT [1-9]" "$log" | grep -q '^2$' && echo "NEGATIVE LC=$LC both caught" || { echo "NEGATIVE LC=$LC NOT caught"; fail=1; }
done
echo "STAGE2 VERILATOR $([[ $fail == 0 ]] && echo PASS || echo FAIL) $(date -Is)"
