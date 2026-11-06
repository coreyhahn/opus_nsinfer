#!/usr/bin/env bash
# Run a command in the opus_nsinfer compute container, repo bind-mounted at its real path, as the
# calling user. Python is /opt/venv (uv.lock, frozen); the host's .venv is never used inside.
#   container/run.sh 'python ref/qec/train_qec.py --mode hgq --out ref/runs/qec/x'
# DOCKER_ARGS adds docker run options (e.g. --cpuset-cpus=0-9 for one job of a sweep).
# Build the image once per host: docker build -t opus_nsinfer:1 -f container/Dockerfile .
set -euo pipefail
ROOT=/home/cah/r2d2/code
REPO=$(cd "$(dirname "$0")/.." && pwd)
exec docker run --rm ${DOCKER_ARGS:-} -u "$(id -u):$(id -g)" -e HOME=/tmp \
    --hostname "$(hostname)-ctr" -v /etc/localtime:/etc/localtime:ro \
    -v "$ROOT:$ROOT" -w "$REPO" opus_nsinfer:1 bash -lc "export PATH=/opt/venv/bin:\$PATH; $*"
