#!/bin/bash
# Stage 5: build the X310_XG image with the nsclf block (rfnoc/icores/x310_XG_nsclf.yml), UHD 4.9 + Vivado 2024.2.
# Run on darthplagueis: the image core is generated here (rfnoc_image_builder -G, Python-only uhd package), then
# make runs detached on snoke through .scratch/s5_launch_x310.sh (the proven stock flow,
# evidence/stage5/toolchain/README.md section 5). The IP dir .scratch/s5_build/build-ip is shared with the stock build.
# usage: synth/scripts/launch_x310_nsclf.sh <name> [LC=2] [extra make args...]   -> .scratch/s5_build/<name>/
set -euo pipefail
P=$(cd "$(dirname "$0")/../.." && pwd)
NAME=${1:?usage: launch_x310_nsclf.sh <name> [LC] [make args]}; LC=${2:-2}; shift $(( $# >= 2 ? 2 : 1 ))
B=$P/.scratch/s5_build/$NAME
[ -e "$B" ] && { echo "refusing: $B exists (build dirs are never reused)"; exit 1; }
META=$P/rtl/gen/x310_clf_lc$LC/metadata.json
[ -f "$META" ] || { echo "no core for LC=$LC ($META)"; exit 1; }
CORE_LAT=$(python3 -c "import json;print(json.load(open('$META'))['latency']+1)")
LCX10=$(python3 -c "print(int(round($LC*10)))")
mkdir -p "$B"
# image core YAML for this cutoff: the committed one (LC 2) with CORE_LAT / LC_X10 set from the core's metadata
sed -E "s/CORE_LAT: [0-9]+/CORE_LAT: $CORE_LAT/; s/LC_X10: [0-9]+/LC_X10: $LCX10/" "$P/rfnoc/icores/x310_XG_nsclf.yml" > "$B/x310_XG_nsclf.yml"
grep -q "CORE_LAT: $CORE_LAT, LC_X10: $LCX10" "$B/x310_XG_nsclf.yml" || { echo "CORE_LAT/LC_X10 substitution failed"; exit 1; }
diff "$P/rfnoc/icores/x310_XG_nsclf.yml" "$B/x310_XG_nsclf.yml" > "$B/icore_vs_committed.diff" || true
source "$P/evidence/stage5/toolchain/pyuhd_env.sh"
BD=$B/build-usrp_x310_fpga_XG_nsclf
$IMGB -y "$B/x310_XG_nsclf.yml" -I "$P/rfnoc" -F "$P/.scratch/uhd/fpga" -B "$BD" -O "$B/build" \
  -E "$P/.scratch/s5_build/build-ip" -G -l debug > "$B/imgbuilder.log" 2>&1
grep -q "rfnoc_block_nsclf" "$BD/rfnoc_image_core.sv" || { echo "image core has no nsclf block"; exit 1; }
{ echo "# $(date -Is) host=$(hostname) name=$NAME LC=$LC CORE_LAT=$CORE_LAT LC_X10=$LCX10";
  echo "# git $(git -C "$P" rev-parse --short HEAD) dirty=$(git -C "$P" status --porcelain | wc -l)";
  echo "# uhd $(git -C "$P/.scratch/uhd" rev-parse --short HEAD) + $(git -C "$P/.scratch/uhd" diff --stat | tail -1)";
  sha256sum "$P"/rtl/x310/*.sv "$P"/rtl/gen/x310_clf_lanes.svh "$P/rfnoc/blocks/nsclf.yml" "$B/x310_XG_nsclf.yml"; } > "$B/provenance.txt"
MK="-j 6 X310_XG BUILD_DIR=$BD IMAGE_CORE_NAME=usrp_x310_fpga_XG_nsclf BUILD_OUTPUT_DIR=$B/build BUILD_IP_DIR=$P/.scratch/s5_build/build-ip NSCLF_LC=$LC $*"
echo "make args: $MK" | tee -a "$B/provenance.txt"
ssh snoke "cd $P && nohup $P/.scratch/s5_launch_x310.sh $B $MK > $B/make.log 2>&1 < /dev/null & echo launched pid \$!"
