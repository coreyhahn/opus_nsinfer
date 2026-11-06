# Stage 5 toolchain proof (pre-hardware), 2026-10-29

Scope: prove UHD 4.9 + Vivado 2024.2 for an X310 RFNoC image before writing any custom block,
check the PLAN D-S5-TAP topology with the image builder, and build the UHD 4.9 host. No X310 was
contacted. Big artefacts (.bit, .dcp, build trees) are in `.scratch/` (git-ignored), not here.

## 1. Source tree

- `git clone --no-hardlinks <lab-share>/fpga/ettus/uhd .scratch/uhd`, `git checkout a5d1b2e`
  (a5d1b2ef28c2, 2026-02-24, "rfnoc: python API: Fix get_tree() call"; host/cmake UHDVersion = 4.9.0.0).
  `.scratch/` is git-ignored (`.gitignore:19`). No submodules, no LFS files in the tree.
- **Finding: stock UHD 4.9 at a5d1b2e targets Vivado 2021.1, not 2024.2.** Every
  `fpga/usrp3/top/*/setupenv.sh` sets `VIVADO_VER=2021.1`, `VIVADO_VER_FULL=2021.1_AR76780`. The
  "2024.2 / 2024.2.1" in `ettus/uhd/fpga/usrp3/top/x300/setupenv.sh` is an **uncommitted local edit** in
  the lab's ettus tree (EME project, March 2026; `git status` there shows 10 modified files: setupenv.sh,
  setupenv_base.sh, viv_preamble.mak, viv_generate_ip.tcl, 4 axi4s_sv files, viv_design_builder.mak,
  timing.xdc). The PLAN D-S5-TOOL / commit aba2245 premise ("UHD 4.9 targets 2024.2") should be
  corrected: UHD 4.9 runs on 2024.2 only with the porting edits listed below.

## 2. Edits and overrides (all in the clone or in .scratch; ettus/ untouched)

| What | Why (evidence) | How |
|---|---|---|
| Vivado selection | setupenv.sh hard-codes 2021.1 (no env override possible); image builder always runs `. ./setupenv.sh` | No edit: `s5_x300_env_2024_2.sh` (copy here) defines VIVADO_VER=2024.2, **VIVADO_VER_FULL=2024.2** (installed reports "vivado v2024.2", build 5239630), then sources `setupenv_base.sh --vivado-path=<xilinx-tools>/Vivado` (that is how VIVADO_BASE_PATH is set; default search is /tools/Xilinx/Vivado, /opt/Xilinx/Vivado). Image builder run with `-G` (generate only), make run by `s5_launch_x310.sh`. |
| `tools/make/viv_preamble.mak:74` `grep Vivado` -> `grep -i vivado` | 2024.2 `vivado -version` prints lower-case "vivado v2024.2"; the check would fail | clone edit |
| `tools/scripts/viv_generate_ip.tcl`: `upgrade_ip` if IS_LOCKED | try 1: every 2021.1 XCI locked, `[filemgmt 20-1365] Unable to generate target(s)... locked`, then `[Synth 8-439] module 'bootram' not found` (`x310_xg_stock_1_make_try1_iplocked.errors.txt`) | clone edit (same as the EME tree's) |
| `lib/axi4s_sv/axi4s_fifo.sv`: `translate_off/on` around the initial-block parameter asserts | try 2: `[Synth 8-6058] Synth Error: TKEEP present mismatch [axi4s_fifo.sv:38]`; the instance is upstream's `in_reg_i` (`xport_sv/eth_ipv4_chdr_adapter.sv:548`), `eth_tx2` TKEEP=1 -> `eth_tx` TKEEP=0 (wrapper :136). Genuine upstream parameter mismatch that 2021.1 synthesis did not flag; asserts stay active in simulation | clone edit; only this file (the EME tree also patched add_bytes/remove_bytes/packet_gate; not needed here) |

Full diff: `uhd_clone_edits.patch` (3 files). Not taken from the EME tree: setupenv_base.sh exports, timing.xdc
EME false path, viv_design_builder.mak.

## 3. RFNoC image builder (generate-only), localhost

- Python-only `uhd` package in `.scratch/pyuhd` (`__init__.py` from `host/python/uhd/__init__.py.in-pymod`,
  `rfnoc_utils` -> clone, block/core YAML dirs copied to `pyuhd/share/uhd/rfnoc`; copies, not
  symlinks: the schema finder does not follow symlinks), venv `.scratch/venv-imgbuilder` (uv, Python 3.12.3:
  mako 1.4.3, ruamel.yaml 0.19.1, numpy 2.5.4, jsonschema, so schemas are validated). `pyuhd_env.sh` here.
- Stock `x310_XG_rfnoc_image_core.yml` -> `rfnoc_image_core.sv/.vh`, `Makefile.inc`, rc 0, no warnings.

## 4. Tap topology (D-S5-TAP): **accepted**

Probe: `.scratch/s5_tap_probe/rfnoc-s5tap` (made with `rfnoc_modtool create` + `add tap`); copies in
`tap_probe/`. Block `tap.yml`: clocks rfnoc_chdr/rfnoc_ctrl/radio; control and data in `radio`;
io_ports `radio_in` (radio, slave), `radio_out` (radio, master), `time` (timekeeper, listener); one
CHDR output `evt`. Image core `x310_XG_tap_rfnoc_image_core.yml` = x310_XG + x3xx_radio_base inlined, with
`_device_.radio0 -> tap0.radio_in`, `tap0.radio_out -> radio0.radio`, `_device_.time -> tap0.time`,
`tap0.evt -> ep6`, `_device_.radio -> tap0.radio` clock.

- Image builder (`-G -l debug`): rc 0, no warning or error (`tap_probe/imgbuilder_tap_generate.log`).
  The connection checker is generic: any module's io_port, `master -> slave` or `broadcaster -> listener`,
  type and wire widths compared (`host/python/uhd/rfnoc_utils/connections.py:171-185, 68-91`).
- Generated `tap_probe/rfnoc_image_core_tap.sv`: tap0 instantiated with `radio_clk` (:1657); IO section
  :1689-1694 device radio0 wires -> tap0 `*_in` (rx_data/rx_stb in, rx_running/tx_data back out),
  :1696-1701 tap0 `*_out` -> radio0 (`radio0_radio_rx_data = tap0_radio_rx_data_out`, ...), :1761
  `tap0_radio_time = radio_time`. Pure wires: no added register or logic in the image core.
- noc_shell (`tap_probe/noc_shell_tap.sv`, framework-generated): `ctrlport_clk = radio_clk` (:166),
  `ctrlport_endpoint` `SYNC_CLKS(0)` (:169-171, rfnoc_ctrl_clk <-> radio_clk), `axis_data_clk = radio_clk`
  (:219), `axis_data_to_chdr` `SYNC_CLKS(0)`, `SIDEBAND_AT_END(0)` (:230-238, radio_clk -> rfnoc_chdr_clk).
  The only clock crossings are these framework ones, as D-S5-TAP assumes.
- Two things to know: (1) each radio io_port needs a `rename` (`\1_in`, `\1_out`), otherwise both ports get
  the same wire names (`radio_rx_data`, ...) and the block is illegal Verilog; (2) `rfnoc_modtool add` writes
  the io-signature width expressions as unrendered Mako (`[${32*int(parameters['spc'])...}-1:0]`) into
  `rfnoc_block_tap.sv` (`tap_probe/rfnoc_block_tap.modtool_generated.sv`); hand-fix to
  `[32*NIPC*NUM_PORTS-1:0]` / `[NUM_PORTS-1:0]`. The image core itself renders them (64 / 2 bits).
- Pass-through tap (`rfnoc_block_tap.passthrough_lint.sv`) + noc_shell_tap + UHD lib, Verilator 5.020
  `--lint-only` on build-host (FIFO IPs / SRLC32E as stubs, `lint_stubs.sv`): 0 errors, 0 warnings (`lint.log`).
- Where the tap sees the samples (**derived** from RTL): ADC capture -> `fe_control` (IQ/DC correction,
  `top/x300/x300_core.v:613-628`, radio_clk) -> `bus_int` radio ports (`x300_core.v:306-307`) -> image core
  `radio_rx_data_radio0` -> tap. Same samples the stock radio streams.
- Not needed, but for reference, the CHDR-side alternative: the radio's output has `sideband_at_end: True`
  (`host/include/uhd/rfnoc/blocks/radio.yml:63`, `noc_shell_radio.v:313` `SIDEBAND_AT_END(1)`), and
  `axis_data_to_chdr.v:22-27` buffers the whole packet before the CHDR output starts, so a classifier
  after the radio on CHDR would wait at least one packet (spp samples / 200 MS/s) plus two clock
  crossings. The tap avoids this.

## 5. Stock X310_XG build, build-host, Vivado 2024.2

Command (build-host, detached): `.scratch/s5_launch_x310.sh <B> -j 6 X310_XG BUILD_DIR=<B>/build-usrp_x310_fpga_XG
IMAGE_CORE_NAME=usrp_x310_fpga_XG BUILD_OUTPUT_DIR=<B>/build BUILD_IP_DIR=.scratch/s5_build/build-ip`
(the make line the image builder printed), image core generated first with `rfnoc_image_builder -G`.

| Run | Dir | Result | Wall |
|---|---|---|---|
| try 1 | `s5_build/x310_xg_stock_1` | IP locked (fixed by upgrade_ip) | 1 min |
| try 2 | same | all 38 IPs built, top synth failed on axi4s assert | 36.5 min (20:30:53-21:07:27) |
| build 2 | `s5_build/x310_xg_stock_2` | synth + impl + bitstream, **hold fail** | 100.3 min (21:08:28-22:48:46) |
| hold fix | `s5_build/holdfix/physopt_hold` | closed, bitstream | ~21 min (22:51-23:12) |

- Log header (`x310_xg_stock_2/build_log_head.txt`): "Vivado v2024.2 (64-bit), SW Build 5239630 on Fri Nov 08
  2024". Licence: `[Common 17-349] Got license for feature 'Synthesis' and/or device 'xc7k410t'` (also
  Implementation): **no licence error**, but `[Common 17-86] ... license expires in 9 day(s)` (build-host System
  Edition eval, 07-Nov-2026).
- Build 2 timing (`x310_xg_stock_2/build_rpt_timing_summary.txt`, report_timing_summary in build.rpt,
  22:48:38, fresh): **WNS +0.016 ns, TNS 0, WHS -0.112 ns, THS -0.667 ns (15 endpoints, all XG_CLK
  156.25 MHz, inside the encrypted 10GBASE-R PCS/PMA, `<hidden>`), WPWS +0.001 ns.** The UHD flow ends with
  `[Builder 0-0] The design did not satisfy timing constraints` (make rc 2); it still wrote x300.bit, but it is
  not a closed image. (The EME build with 2024.2.1 in March had the same kind of failure: WHS -0.034 ns, 4
  endpoints.)
- Hold fix (`holdfix.tcl` here, from build 2's post_route.dcp, 3 variants in parallel):
  `phys_opt_design -directive ExploreWithHoldFix` -> **WNS +0.016, TNS 0, WHS +0.003, THS 0, WPWS +0.001,
  "All user specified timing constraints are met"** (`holdfix/physopt_hold_timing_summary.txt`, 23:08:16),
  16 LUT1/ZHOLD insertions on 15 nets. `+ route_design Explore` gives the same numbers; `route_design
  AggressiveExplore` alone leaves WHS -0.112. Timing per clock (same report): radio_clk (200 MHz) WNS
  +0.366 ns, ce_clk +0.352, bus_clk +0.136.
- Utilisation, post-route (`x310_xg_stock_2/post_route_util.rpt`, 22:42:03; hold fix adds 16 LUTs):

| Resource | Used | Available | Util | Free for the classifier |
|---|---|---|---|---|
| Slice LUTs | 143,664 | 254,200 | 56.5 % | 110,536 |
| Slice registers | 221,057 | 508,400 | 43.5 % | 287,343 |
| Block RAM tiles (36 Kb) | 486 | 795 | 61.1 % | 309 |
| DSP48E1 | 393 | 1,540 | 25.5 % | 1,147 |
| Occupied slices | 59,533 | 63,550 | 93.7 % | packing, not hard: but placement is dense |

- Bitstream (closed): `.scratch/s5_build/holdfix/physopt_hold/x300.bit` (+ `.bin`), 2026-10-29 23:12:47,
  md5 5a055bbcf46008d13a0b49442d4ca64a. The timing-failing one is `.scratch/s5_build/x310_xg_stock_2/
  build-usrp_x310_fpga_XG/x300.bit` (22:47:57). No UHD `build/` export (.lvbitx/.rpt) was made because make
  stopped on the timing error; JTAG loading needs only the .bit.
- **Evaluation-core warning:** `write_bitstream` reports `CRITICAL WARNING: [Vivado 12-1790] Evaluation
  License Warning: This design contains one or more evaluation cores that will cease to function after a
  certain period of time` (build.log:13893 and holdfix log). The EME bitstream has it too. Most likely source:
  `[IP_Flow 19-650] IP license key 'ten_gig_eth_pcs_pma_basekr@2015.04' is enabled with a Design_Linking
  license` (10GBASE-R PCS/PMA, configured BASE-R) under build-host's `Vivado_System_Edition_Eval` licence. Not
  proven which core it is. Do not use this image for long captures until it is resolved.
- Other critical warnings: 64x `[Timing 38-469]` MIG IDELAYCTRL REFCLK 200.080 vs 200.000 MHz (also in the EME
  build), 8x `[Coretcl 2-1280]` IP upgrade review (xfft_*, aurora_64b66b_pcs_pma).

## 6. UHD 4.9 host, localhost (desk-pc)

- build-host cannot build it without root: there are no Boost headers (`/usr/include/boost` missing; only
  libboost_iostreams/locale/thread 1.83 runtime) and no libusb dev. apt for build-host:
  `libboost-dev libboost-chrono-dev libboost-date-time-dev libboost-filesystem-dev
  libboost-program-options-dev libboost-serialization-dev libboost-system-dev libboost-thread-dev
  libboost-test-dev libusb-1.0-0-dev` (or `libboost-all-dev libusb-1.0-0-dev`).
- So it was built on desk-pc (Boost 1.83 dev, libusb 1.0 dev, python3.12 headers present):
  `cmake ../uhd/host -G Ninja -DCMAKE_INSTALL_PREFIX=.scratch/uhd-install -DCMAKE_BUILD_TYPE=Release
  -DENABLE_PYTHON_API=ON -DPYTHON_EXECUTABLE=/usr/bin/python3.12 -DUHD_PYTHON_DIR=lib/python3.12/site-packages
  -DENABLE_TESTS=OFF -DENABLE_MANUAL=OFF -DENABLE_DOXYGEN=OFF -DENABLE_MAN_PAGES=OFF`, with
  `PYTHONPATH=.scratch/venv-uhd/lib/python3.12/site-packages` (uv venv: numpy, mako, ruamel.yaml, requests);
  `ninja -j 24 && ninja install`, 2 min 8 s.
  (A first attempt used the venv's python as PYTHON_EXECUTABLE. UHD then ran a bare `pip3 install .`,
  which installed uhd-4.9.0 into `~/anaconda3/envs/base313`. It had no uhd before; I uninstalled it. That
  attempt also put usrp_mpm in a wrong relative path; deleted and rebuilt clean.)
- Use: `source .scratch/uhd-install/env.sh` (copy: `uhd_install_env.sh`; sets PATH, LD_LIBRARY_PATH,
  PYTHONPATH, UHD_PKG_PATH) and run Python with `/usr/bin/python3.12`.
  `uhd_config_info --version` -> `UHD 4.9.0.HEAD-0-a5d1b2ef`; Python `import uhd` -> 4.9.0.HEAD-0-a5d1b2ef
  (`uhd_config_info.txt`). Enabled: LibUHD, C API, Python API, Examples, Utils, X300, MPMD, ... (no DPDK).
  FPGA compat expected by this tree: 39.3 (`fpga/usrp3/top/x300/bus_int.v:189-190`, 0x0027/0x0003).
  FPGA images are not downloaded (set UHD_IMAGES_DIR when needed).
  The libraries link to desk-pc's Boost 1.83 and will not run on build-host until the packages above exist.
