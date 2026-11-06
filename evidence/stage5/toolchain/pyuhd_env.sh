# Python-only uhd package for rfnoc_image_builder (no UHD C++ build); source me.
export PYTHONPATH=<repo>/.scratch/pyuhd${PYTHONPATH:+:$PYTHONPATH}
export UHD_PKG_DATA_PATH=<repo>/.scratch/pyuhd/share/uhd
IMGB="<repo>/.scratch/venv-imgbuilder/bin/python <repo>/.scratch/uhd/host/utils/rfnoc_image_builder.py"
