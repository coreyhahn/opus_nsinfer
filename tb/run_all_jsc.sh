#!/usr/bin/env bash
# Verilator regression over every exported depth (run on snoke, detached).
set -uo pipefail
cd "$(dirname "$0")"
PAR=${PAR:-4}
ls -d ../rtl/gen/jsc_lc* | sed 's/.*jsc_lc//' | xargs -P "$PAR" -I{} sh -c 'make jsc LC={} JOBS=8 > ../evidence/stage0/verilator/make_lc{}.log 2>&1 && echo "LC={} PASS" || echo "LC={} FAIL"'
echo "ALL DONE $(date -Is)"
