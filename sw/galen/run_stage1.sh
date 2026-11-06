#!/usr/bin/env bash
# Stage 1 silicon run for one build, from darthplagueis: copy -> volatile PL load (fpga_manager) ->
# info -> bit-exact stream (4 seeds x 2 runs) -> negative controls -> two phase sweeps -> logs back.
#   sw/galen/run_stage1.sh <build_name> <tag>     e.g. sw/galen/run_stage1.sh s1_p300_lc3_f1 p300
# Needs synth/out_<build>/zcu102_top.bin and .scratch/jsc_vectors.npz (sw/galen/make_vectors.py).
# Touches only galen's RAM (/tmp, /lib/firmware on the RAM rootfs) and the PL; never flash or SD.
set -euo pipefail
PROJ=$(cd "$(dirname "$0")/../.." && pwd)
B=$1; TAG=$2
BIN=$PROJ/synth/out_$B/zcu102_top.bin
EV=$PROJ/evidence/stage1/silicon
mkdir -p "$EV"
for f in stream_$TAG timed_${TAG}_a timed_${TAG}_b; do
    [[ -e $EV/$f.log ]] && { echo "ERROR: $EV/$f.log exists; refusing to overwrite" >&2; exit 1; }
done
cp "$BIN" "$PROJ/.scratch/$B.bin"
scp -q "$PROJ/.scratch/$B.bin" "$PROJ/sw/galen/jsc_host.py" "$PROJ/.scratch/jsc_vectors.npz" root@galen:/tmp/
ssh root@galen "cd /tmp && B=$B TAG=$TAG bash -s" <<'EOF'
set -u
hdr() { echo "# host=$(hostname) date=$(date -Is) kernel=$(uname -r) bin=$B.bin bin_sha256=$(sha256sum $B.bin | cut -c1-64) vectors_sha256=$(sha256sum jsc_vectors.npz | cut -c1-64) host_sha256=$(sha256sum jsc_host.py | cut -c1-64)"; }
python3 jsc_host.py load $B.bin || exit 1
{ hdr; python3 jsc_host.py info; python3 jsc_host.py stream jsc_vectors.npz; echo "EXIT $?"; } > stream_$TAG.log 2>&1
python3 - <<'PY'
import numpy as np
d = np.load("jsc_vectors.npz"); vout = d["vout"].copy(); vin = d["vin"].copy()
vout[421, 1] ^= 1 << 5; vin[777, 0] ^= 1 << 3
np.savez("neg_out.npz", vin=d["vin"], vout=vout, hashes=str(d["hashes"]))
np.savez("neg_in.npz", vin=vin, vout=d["vout"], hashes=str(d["hashes"]))
PY
{ hdr; echo "# negative controls: neg_out = expected logit word1 bit5 of vector 421 flipped; neg_in = input word0 bit3 of vector 777 flipped (each must give exactly 1 mismatch, EXIT 1)"
  python3 jsc_host.py stream neg_out.npz --seeds 0 --runs 1; echo "EXIT $?"
  python3 jsc_host.py stream neg_in.npz --seeds 1 --runs 1; echo "EXIT $?"; } > negative_$TAG.log 2>&1
{ hdr; python3 jsc_host.py timed jsc_vectors.npz --vec-seed 1; echo "EXIT $?"; } > timed_${TAG}_a.log 2>&1
{ hdr; python3 jsc_host.py timed jsc_vectors.npz --vec-seed 2; echo "EXIT $?"; } > timed_${TAG}_b.log 2>&1
grep -h "RESULT\|EXIT\|mmcm_locked" stream_$TAG.log negative_$TAG.log timed_${TAG}_a.log timed_${TAG}_b.log | cut -c1-200
EOF
for f in stream_$TAG negative_$TAG timed_${TAG}_a timed_${TAG}_b; do scp -q "root@galen:/tmp/$f.log" "$EV/"; done
echo "logs in $EV"
