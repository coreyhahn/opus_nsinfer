# UHD 4.9.0 (a5d1b2e) host install, built on desk-pc (Ubuntu 24.04, Boost 1.83, Python 3.12). Source me.
P=<repo>/.scratch/uhd-install
export PATH=$P/bin:$PATH
export LD_LIBRARY_PATH=$P/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
export PYTHONPATH=$P/lib/python3.12/site-packages:<repo>/.scratch/venv-uhd/lib/python3.12/site-packages${PYTHONPATH:+:$PYTHONPATH}
export UHD_PKG_PATH=$P
# images (uhd_images_downloader -i <dir>) are not fetched; set UHD_IMAGES_DIR when needed
