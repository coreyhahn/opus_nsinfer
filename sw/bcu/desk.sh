#!/usr/bin/env bash
# The only entry point to the DESK BCU-1525 (card #2): runs sw/bcu/desk_jtag.tcl on snoke under the
# desk card's own lock (fable5's board_lock.py pointed at .opus_nsinfer_desk_bcu.lock; the PCIe
# card's .fable5_board.lock is never taken or touched). Volatile JTAG loads only, never flash.
#   sw/bcu/desk.sh list
#   sw/bcu/desk.sh program <bit> [ltx]
#   sw/bcu/desk.sh run <cmdfile>
# The desk card's JTAG serial is read from sw/bcu/desk_serial.txt (recorded on first enumeration).
# Each call is a short batch session, so snoke's hw_server has no lingering client (fable5's
# program_fpga.sh refuses while one is connected).
set -euo pipefail
PROJ=$(cd "$(dirname "$0")/../.." && pwd)
LOCK=/home/cah/r2d2/code/fpga/.opus_nsinfer_desk_bcu.lock
BL=/home/cah/r2d2/code/fpga/fable5_llm/sw/board_lock.py
[[ "$(hostname -s)" == snoke ]] || { echo "ERROR: run on snoke (the desk card's USB JTAG is there)" >&2; exit 1; }
CMD=${1:?usage: desk.sh list|program <bit> [ltx]|run <cmdfile>}
SERIAL=$(cat "$PROJ/sw/bcu/desk_serial.txt" 2>/dev/null || true)
set +u; source /home/cah/r2d2/sc2data/tools/Vivado/2024.2/settings64.sh; set -u
TMP=$(mktemp -d "$PROJ/.scratch/desk_XXXXXX")
V=(vivado -mode batch -nojournal -log "$TMP/vivado.log" -tempDir "$TMP" -source "$PROJ/sw/bcu/desk_jtag.tcl" -tclargs)
case $CMD in
    list)    cd "$TMP" && "${V[@]}" list ;;
    program) B=$(readlink -f "$2"); L=${3:--}; [[ $L == - ]] || L=$(readlink -f "$L")
             echo "# desk program $(date -Is) bit=$B sha256=$(sha256sum "$B" | cut -c1-64) serial=$SERIAL"
             cd "$TMP" && exec python3 "$BL" --lock "$LOCK" --tool "opus_nsinfer desk program $(basename "$B")" --exec -- "${V[@]}" program "$SERIAL" "$B" "$L" ;;
    run)     F=$(readlink -f "$2")
             cd "$TMP" && exec python3 "$BL" --lock "$LOCK" --tool "opus_nsinfer desk run $(basename "$F")" --exec -- "${V[@]}" run "$SERIAL" "$F" ;;
    *) echo "unknown command $CMD" >&2; exit 1 ;;
esac
