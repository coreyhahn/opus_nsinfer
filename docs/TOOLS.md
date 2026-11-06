# TOOLS — every version this program's numbers depend on

Recorded 2026-10-19. Update in the same commit that changes any tool.

## Python environment (`uv`, `pyproject.toml` + `uv.lock`)

Create: `uv sync --python 3.12` in the project root (desk-pc: `uv`
0.12.21 at `/snap/bin/uv`). Interpreter: CPython 3.12.3 (`/usr/bin/python3.12`).
Always run with `KERAS_BACKEND=jax` (the scripts set it); JAX runs on CPU
with `jax_enable_x64` (no CUDA jaxlib installed; not needed at this size).

| Package | Version | Licence | Role |
|---|---|---|---|
| hgq2 | 0.2.0 | LGPL-3.0 | HGQ2 quantization-aware training (Keras 3) |
| da4ml | 0.6.0 | LGPL-3.0 | distributed-arithmetic tracing + Verilog emission |
| hls4ml | 1.3.0 | Apache-2.0 | pinned for cross-checks and the upstream PR (not in the RTL path) |
| keras | 3.15.1 | Apache-2.0 | model definition, float64 |
| jax / jaxlib | 0.12.0 | Apache-2.0 | Keras backend |
| quantizers | 1.2.2 | (HGQ2 dependency) | fixed-point quantizer kernels |
| stim | 1.16.0 | Apache-2.0 | surface-code circuit sampling (Stage 2) |
| pymatching | 2.4.0 | Apache-2.0 | reference MWPM decoder (Stage 2) |
| numpy | 2.5.4 | BSD-3 | |
| scikit-learn | 1.9.1 | BSD-3 | split + scaler |
| pandas / pyarrow | 3.0.6 / 26.0.0 | BSD-3 / Apache-2.0 | parquet dataset read |

The full resolved set is `uv.lock` (committed).

## Dataset

OpenML 42468 `hls4ml_lhc_jets_hlf` v1, CC-BY, DOI 10.5281/zenodo.3602260,
parquet from `https://data.openml.org/datasets/0004/42468/dataset_42468.pq`
(79,579,784 bytes, SHA-256 `e8bd0961…b463`, full hash in
`ref/jsc_split_meta.json`). 830,000 jets: 597,600 train / 66,400 val /
166,000 test (`train_test_split(test_size=0.2, random_state=42)` then 10% of
train to val, `random_state=42`; StandardScaler fitted on train).

## Compute container (train-host, Stage 2 on)

`container/Dockerfile` (Ubuntu 24.04, CPython 3.12.3, uv 0.9.5, `uv sync --frozen` from
`uv.lock` into `/opt/venv`), image `opus_nsinfer:1`, built on train-host (80 cores, 156 GB,
Docker 29.8.1) with `docker build -t opus_nsinfer:1 -f container/Dockerfile .`
(image sha256 `11d540e4…7c9c`, 2026-10-20). Its 43 installed packages are identical, name and
version, to the project `.venv` on desk-pc (`uv pip list` diff, 2026-10-20).
`container/run.sh '<cmd>'` runs a command with the NFS tree bind-mounted at its real path as the
calling user; `sw/grumpy/launch_sweep.sh <jobs> <cpus_per_job>` runs one training job per
container on its own `--cpuset-cpus` slice. No Vivado and no Verilator in the image.

## HDL tools

| Tool | Version | Host | Use |
|---|---|---|---|
| Verilator | 5.020 (Debian 5.020-1) | build-host | all simulation (`make -C tb`) |
| g++ | 13.3.0 | build-host | Verilator C++ |
| Vivado | 2024.2 (64-bit), NFS `<xilinx-tools>/Vivado/2024.2` | build-host (batch) | OOC synthesis + P&R |
| Vitis HLS | not used | — | da4ml emits RTL directly; no HLS in the chain |

## Device parts

- ZCU102 "zcu102": `xczu9eg-ffvb1156-2-i` (ES2 silicon on the board; OOC uses
  the production speed file for the -2-i grade).
- BCU-1525: `xcvu9p-fsgd2104-2L-e`.
