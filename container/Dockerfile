# opus_nsinfer compute image (grumpy-calf): the Python environment of uv.lock, nothing else
# (no Vivado, no Verilator: those stay on snoke / darthplagueis per CLAUDE.md).
# Pinned: Ubuntu 24.04 (CPython 3.12.3, as on darthplagueis), uv 0.9.5, packages from uv.lock (--frozen).
#   docker build -t opus_nsinfer:1 -f container/Dockerfile .     (context = repo root)
FROM ubuntu:24.04
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl python3 python3-venv time \
    && rm -rf /var/lib/apt/lists/*
RUN curl -LsSf https://astral.sh/uv/0.9.5/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh
ENV UV_PROJECT_ENVIRONMENT=/opt/venv UV_PYTHON=/usr/bin/python3.12 UV_PYTHON_DOWNLOADS=never \
    PATH=/opt/venv/bin:$PATH KERAS_BACKEND=jax
COPY pyproject.toml uv.lock /opt/src/
RUN cd /opt/src && uv sync --frozen --no-install-project && chmod -R a+rX /opt/venv
RUN python -c "import keras, jax, hgq, da4ml, stim, pymatching; print(keras.__version__, jax.__version__, stim.__version__, pymatching.__version__)"
