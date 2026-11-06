# Verilator testbenches. Run on snoke:
#   ssh snoke 'cd /home/cah/r2d2/code/fpga/opus_nsinfer && make -C tb jsc LC=<cutoff> JOBS=16'
# One obj_dir per design: obj_dir_jsc_lc<LC>.

PROJ    := $(abspath ..)
JOBS    ?= 16
LC      ?= 5
GEN     ?= $(PROJ)/rtl/gen/jsc_lc$(LC)
GOLDEN  ?= $(PROJ)/ref/golden
SEEDS   ?= 0 1 2 3
LOGDIR  ?= $(PROJ)/evidence/stage0/verilator
VLIB    := /home/cah/r2d2/code/verilator_lib

# Widths and depth come from the exported metadata, never typed by hand.
IN_W  = $(shell python3 -c "import json;print(json.load(open('$(GOLDEN)/jsc_golden.json'))['in_width_bits'])")
OUT_W = $(shell python3 -c "import json;print(json.load(open('$(GOLDEN)/jsc_golden.json'))['out_width_bits'])")
NVEC  = $(shell python3 -c "import json;print(json.load(open('$(GOLDEN)/jsc_golden.json'))['n_test'])")
# da4ml core: an input register plus one register per stage.
LAT   = $(shell python3 -c "import json;print(json.load(open('$(GEN)/metadata.json'))['latency']+1)")

OBJ  := obj_dir_jsc_lc$(LC)
SRCS  = $(wildcard $(GEN)/src/static/*.v) $(wildcard $(GEN)/src/jsc_stage*.v) $(GEN)/src/jsc.v tb_jsc.sv

.PHONY: jsc jsc_build jsc_lint clean

jsc_lint:
	verilator --lint-only -Wall -Wno-DECLFILENAME -Wno-UNUSEDPARAM --top-module jsc \
	  $(wildcard $(GEN)/src/static/*.v) $(wildcard $(GEN)/src/jsc_stage*.v) $(GEN)/src/jsc.v

jsc_build:
	verilator --binary --timing -j $(JOBS) --top-module tb_jsc --Mdir $(OBJ) \
	  -Wno-fatal -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC --unroll-count 1024 -O3 \
	  -GIN_W=$(IN_W) -GOUT_W=$(OUT_W) -GLAT=$(LAT) -GNVEC=$(NVEC) \
	  -o Vtb_jsc $(SRCS)

jsc: jsc_lint jsc_build
	mkdir -p $(LOGDIR)
	set -e; for s in $(SEEDS); do for r in 1 2; do \
	  log=$(LOGDIR)/jsc_lc$(LC)_seed$${s}_run$${r}.log; \
	  { echo "# host=$$(hostname) date=$$(date -Is) verilator=$$(verilator --version)"; \
	    echo "# design=$(GEN) in_hex_sha256=$$(sha256sum $(GOLDEN)/jsc_golden_in.hex | cut -c1-64) out_hex_sha256=$$(sha256sum $(GOLDEN)/jsc_golden_out.hex | cut -c1-64)"; \
	    echo "# IN_W=$(IN_W) OUT_W=$(OUT_W) LAT=$(LAT) NVEC=$(NVEC) seed=$$s run=$$r"; \
	    ./$(OBJ)/Vtb_jsc +IN=$(GOLDEN)/jsc_golden_in.hex +OUT=$(GOLDEN)/jsc_golden_out.hex +SEED=$$s; } > $$log 2>&1 \
	    || { tail -20 $$log; exit 1; }; \
	  grep -h "RESULT" $$log; done; done

clean:
	rm -rf obj_dir_*

# ---------------- Stage 1 harness (jsc_harness + core, AXI4-Lite) ----------------
#   make -C tb harness LC=3 AXI_DIV=1      (4 seeds x 2 runs, stream + timed)
#   make -C tb harness_quick LC=3          (1,000 vectors, short sweep)
AXI_DIV  ?= 1
ARG_LAT  ?= 1
HDEPTH   ?= 14
PS_STEPS ?= 224
T_NS     ?= 3.333333
HLOGDIR  ?= $(PROJ)/evidence/stage1/verilator
HOBJ     := obj_dir_harness_lc$(LC)_div$(AXI_DIV)_arg$(ARG_LAT)
HSRCS     = $(wildcard $(GEN)/src/static/*.v) $(wildcard $(GEN)/src/jsc_stage*.v) $(GEN)/src/jsc.v \
            $(PROJ)/rtl/jsc_argmax.sv $(PROJ)/rtl/jsc_harness.sv
HARGS     = +IN=$(GOLDEN)/jsc_golden_in.hex +OUT=$(GOLDEN)/jsc_golden_out.hex +ARG=$(GOLDEN)/jsc_golden_argmax.hex

.PHONY: harness harness_build harness_lint harness_quick

harness_lint:
	verilator --lint-only -Wall -Wno-DECLFILENAME -Wno-UNUSEDPARAM -I$(PROJ)/rtl --top-module jsc_harness $(HSRCS)

harness_build:
	verilator --binary --timing -j $(JOBS) --top-module tb_harness --Mdir $(HOBJ) -I$(PROJ)/rtl \
	  -Wno-fatal -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC --unroll-count 1024 -O3 \
	  -GLAT_NET=$(LAT) -GARG_LAT=$(ARG_LAT) -GDEPTH_LOG2=$(HDEPTH) -GAXI_DIV=$(AXI_DIV) \
	  -GPS_STEPS=$(PS_STEPS) -GT_NS=$(T_NS) -GNVEC=$(NVEC) \
	  -o Vtb_harness $(HSRCS) tb_harness.sv

harness_quick: harness_lint harness_build
	./$(HOBJ)/Vtb_harness $(HARGS) +SEED=1 +NVEC=1000 +STRIDE=8

harness: harness_lint harness_build
	mkdir -p $(HLOGDIR)
	set -e; for s in $(SEEDS); do for r in 1 2; do \
	  log=$(HLOGDIR)/harness_lc$(LC)_div$(AXI_DIV)_arg$(ARG_LAT)_seed$${s}_run$${r}.log; \
	  { echo "# host=$$(hostname) date=$$(date -Is) verilator=$$(verilator --version)"; \
	    echo "# design=$(GEN) rtl_sha256=$$(cat $(PROJ)/rtl/jsc_harness.sv $(PROJ)/rtl/jsc_argmax.sv | sha256sum | cut -c1-64) in_hex_sha256=$$(sha256sum $(GOLDEN)/jsc_golden_in.hex | cut -c1-64) out_hex_sha256=$$(sha256sum $(GOLDEN)/jsc_golden_out.hex | cut -c1-64) argmax_hex_sha256=$$(sha256sum $(GOLDEN)/jsc_golden_argmax.hex | cut -c1-64)"; \
	    echo "# LAT_NET=$(LAT) ARG_LAT=$(ARG_LAT) DEPTH_LOG2=$(HDEPTH) AXI_DIV=$(AXI_DIV) PS_STEPS=$(PS_STEPS) T_NS=$(T_NS) NVEC=$(NVEC) seed=$$s run=$$r"; \
	    ./$(HOBJ)/Vtb_harness $(HARGS) +SEED=$$s; } > $$log 2>&1 \
	    || { tail -20 $$log; exit 1; }; \
	  grep -h "RESULT" $$log; done; done

# Anchor sign check: non-zero d_H / d_G as transport delays (TB_ANCHOR_DLY, sim only); the solver
# must recover D_B, D_C and every trial's L_pp with the true anchors, and bracket them from corners.
#   make -C tb harness_anchor LC=3 TB_DH=0.7 TB_DG=1.1
TB_DH ?= 0.7
TB_DG ?= 1.1
HAOBJ := obj_dir_harness_anchor_lc$(LC)_div$(AXI_DIV)_arg$(ARG_LAT)
.PHONY: harness_anchor
harness_anchor:
	verilator --binary --timing -j $(JOBS) --top-module tb_harness --Mdir $(HAOBJ) -I$(PROJ)/rtl \
	  -Wno-fatal -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC --unroll-count 1024 -O3 \
	  +define+TB_ANCHOR_DLY +define+TB_DH=$(TB_DH) +define+TB_DG=$(TB_DG) \
	  -GLAT_NET=$(LAT) -GARG_LAT=$(ARG_LAT) -GDEPTH_LOG2=$(HDEPTH) -GAXI_DIV=$(AXI_DIV) \
	  -GPS_STEPS=$(PS_STEPS) -GT_NS=$(T_NS) -GNVEC=$(NVEC) \
	  -o Vtb_harness $(HSRCS) tb_harness.sv
	mkdir -p $(HLOGDIR)
	log=$(HLOGDIR)/harness_anchor_lc$(LC)_div$(AXI_DIV)_arg$(ARG_LAT)_dh$(TB_DH)_dg$(TB_DG).log; \
	  { echo "# host=$$(hostname) date=$$(date -Is) TB_DH=$(TB_DH) TB_DG=$(TB_DG)"; \
	    ./$(HAOBJ)/Vtb_harness $(HARGS) +SEED=2 +MODE=timed; } > $$log 2>&1 || { tail -20 $$log; exit 1; }; \
	  grep -h "RESULT" $$log; \
	  python3 $(PROJ)/sw/analysis/timed_solve.py $$log --check-sim --d-h $(TB_DH) --d-g $(TB_DG) \
	    --json $(PROJ)/evidence/stage1/sim_solve/$$(basename $$log .log).json | grep -A6 sim_check; \
	  python3 $(PROJ)/sw/analysis/timed_solve.py $$log --check-sim \
	    --d-h-range $$(python3 -c "print($(TB_DH)-0.2, $(TB_DH)+0.3)") --d-g-range $$(python3 -c "print($(TB_DG)-0.2, $(TB_DG)+0.3)") \
	    --json $(PROJ)/evidence/stage1/sim_solve/$$(basename $$log .log)_bracket.json | grep -A6 sim_check

# ---------------- Stage 2: d = 3 NN decoder (qec_d3_top = da4ml core + flip register) ----------------
#   make -C tb qec LC=<cutoff>            golden test vectors, 4 seeds x 2 runs (flip checked)
#   make -C tb qec_exh LC=<cutoff>        all 2^24 inputs, seeds 0 and 1 (logit only)
QGEN    ?= $(PROJ)/rtl/gen/qec_d3_lc$(LC)
QLOGDIR ?= $(PROJ)/evidence/stage2/verilator
QJ       = $(GOLDEN)/qec_d3_golden.json
Q_IN_W   = $(shell python3 -c "import json;print(json.load(open('$(QJ)'))['det_bits'])")
QINC    ?= $(PROJ)/rtl
Q_OUT_W  = $(shell python3 -c "import json;print(json.load(open('$(QJ)'))['out_width_bits'])")
Q_NVEC   = $(shell python3 -c "import json;print(json.load(open('$(QJ)'))['n_vectors'])")
Q_SIGNED = $(shell python3 -c "import json;print(json.load(open('$(QJ)'))['out_kif'][0][0])")
Q_LAT    = $(shell python3 -c "import json;print(json.load(open('$(QGEN)/metadata.json'))['latency']+1)")
QSRCS    = $(wildcard $(QGEN)/src/static/*.v) $(wildcard $(QGEN)/src/qec_d3_stage*.v) $(QGEN)/src/qec_d3.v $(PROJ)/rtl/qec_d3_top.sv
QARGS    = +IN=$(GOLDEN)/qec_d3_golden_in.hex +OUT=$(GOLDEN)/qec_d3_golden_out.hex +DEC=$(GOLDEN)/qec_d3_golden_dec.hex
EXH_IN  ?= $(PROJ)/.scratch/qec_d3_exh_in.hex
EXH_OUT ?= $(PROJ)/.scratch/qec_d3_exh_out.hex

.PHONY: qec qec_lint qec_build qec_exh
qec_lint:
	verilator --lint-only -Wall -Wno-DECLFILENAME -Wno-UNUSEDPARAM -I$(QINC) --top-module qec_d3_top \
	  -GIN_W=$(Q_IN_W) -GOUT_W=$(Q_OUT_W) -GLOGIT_SIGNED=$(Q_SIGNED) $(QSRCS)

# one binary per (cutoff, vector count): the memories are sized by NVEC
qec_build:
	verilator --binary --timing -j $(JOBS) -I$(QINC) --top-module tb_qec --Mdir obj_dir_qec_lc$(LC)_n$(QN) \
	  -Wno-fatal -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC --unroll-count 1024 -O3 \
	  -GIN_W=$(Q_IN_W) -GOUT_W=$(Q_OUT_W) -GLAT=$(Q_LAT) -GNVEC=$(QN) -GLOGIT_SIGNED=$(Q_SIGNED) \
	  -o Vtb_qec $(QSRCS) tb_qec.sv

qec: qec_lint
	$(MAKE) qec_build QN=$(Q_NVEC)
	mkdir -p $(QLOGDIR)
	set -e; for s in $(SEEDS); do for r in 1 2; do \
	  log=$(QLOGDIR)/qec_d3_lc$(LC)_seed$${s}_run$${r}.log; \
	  { echo "# host=$$(hostname) date=$$(date -Is) verilator=$$(verilator --version)"; \
	    echo "# design=$(QGEN) top_sha256=$$(cat $(PROJ)/rtl/qec_d3_top.sv $(QINC)/qec_d3_in_map.svh | sha256sum | cut -c1-64) in_hex_sha256=$$(sha256sum $(GOLDEN)/qec_d3_golden_in.hex | cut -c1-64) out_hex_sha256=$$(sha256sum $(GOLDEN)/qec_d3_golden_out.hex | cut -c1-64) dec_hex_sha256=$$(sha256sum $(GOLDEN)/qec_d3_golden_dec.hex | cut -c1-64)"; \
	    echo "# IN_W=$(Q_IN_W) OUT_W=$(Q_OUT_W) LAT=$(Q_LAT) NVEC=$(Q_NVEC) seed=$$s run=$$r"; \
	    ./obj_dir_qec_lc$(LC)_n$(Q_NVEC)/Vtb_qec $(QARGS) +SEED=$$s; } > $$log 2>&1 \
	    || { tail -20 $$log; exit 1; }; \
	  grep -h "RESULT" $$log; done; done

qec_exh: qec_lint
	$(MAKE) qec_build QN=16777216
	mkdir -p $(QLOGDIR)
	set -e; for s in 0 1; do \
	  log=$(QLOGDIR)/qec_d3_lc$(LC)_exhaustive_seed$${s}.log; \
	  { echo "# host=$$(hostname) date=$$(date -Is) verilator=$$(verilator --version)"; \
	    echo "# design=$(QGEN) exh_in_sha256=$$(sha256sum $(EXH_IN) | cut -c1-64) exh_out_sha256=$$(sha256sum $(EXH_OUT) | cut -c1-64) (must equal ref/golden/qec_d3_exhaustive.json)"; \
	    echo "# IN_W=$(Q_IN_W) OUT_W=$(Q_OUT_W) LAT=$(Q_LAT) NVEC=16777216 seed=$$s"; \
	    ./obj_dir_qec_lc$(LC)_n16777216/Vtb_qec +IN=$(EXH_IN) +OUT=$(EXH_OUT) +SEED=$$s; } > $$log 2>&1 \
	    || { tail -20 $$log; exit 1; }; \
	  grep -h "RESULT" $$log; done

# ---------------- Stage 4: d = 5 NN decoder core (qec_d5_top = da4ml core + flip register) ----------------
#   make -C tb qec5 LC=<cutoff>           committed golden set (ref/golden/qec_d5_golden_*), 4 seeds x 2 runs
#   make -C tb qec5_full LC=<cutoff>      the full distinct test set (.scratch/qec_d5_full_*.hex, hashes in
#                                         ref/golden/qec_d5_full.json), seeds 0 and 1
# The d = 5 models need a large stack (ulimit -s unlimited; the default 8 MB segfaults at start).
Q5GEN    ?= $(PROJ)/rtl/gen/qec_d5_lc$(LC)
Q5LOGDIR ?= $(PROJ)/evidence/stage4/verilator
Q5INC    ?= $(PROJ)/rtl
Q5J       = $(GOLDEN)/qec_d5_golden.json
Q5_OUT_W  = $(shell python3 -c "import json;print(json.load(open('$(Q5J)'))['out_width_bits'])")
Q5_NVEC   = $(shell python3 -c "import json;print(json.load(open('$(Q5J)'))['n_vectors'])")
Q5_NFULL  = $(shell python3 -c "import json;print(json.load(open('$(Q5J)'))['n_full'])")
Q5_SIGNED = $(shell python3 -c "import json;print(json.load(open('$(Q5J)'))['out_kif'][0][0])")
Q5_LAT    = $(shell python3 -c "import json;print(json.load(open('$(Q5GEN)/metadata.json'))['latency']+1)")
Q5SRCS    = $(wildcard $(Q5GEN)/src/static/*.v) $(wildcard $(Q5GEN)/src/qec_d5_stage*.v) $(Q5GEN)/src/qec_d5.v $(PROJ)/rtl/d5/qec_d5_top.sv
Q5ARGS    = +IN=$(GOLDEN)/qec_d5_golden_in.hex +OUT=$(GOLDEN)/qec_d5_golden_out.hex +DEC=$(GOLDEN)/qec_d5_golden_dec.hex
F5        = $(PROJ)/.scratch/qec_d5_full
Q5_SHA    = top_sha256=$$(cat $(PROJ)/rtl/d5/qec_d5_top.sv $(Q5INC)/qec_d5_in_map.svh | sha256sum | cut -c1-64)

.PHONY: qec5 qec5_lint qec5_build qec5_full
qec5_lint:
	verilator --lint-only -Wall -Wno-DECLFILENAME -Wno-UNUSEDPARAM -I$(Q5INC) --top-module qec_d5_top \
	  -GIN_W=120 -GOUT_W=$(Q5_OUT_W) -GLOGIT_SIGNED=$(Q5_SIGNED) $(Q5SRCS)

qec5_build:
	verilator --binary --timing -j $(JOBS) -I$(Q5INC) +define+QEC_D5 --top-module tb_qec --Mdir obj_dir_qec5_lc$(LC)_n$(QN) \
	  -Wno-fatal -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC --unroll-count 1024 -O3 \
	  -GIN_W=120 -GOUT_W=$(Q5_OUT_W) -GLAT=$(Q5_LAT) -GNVEC=$(QN) -GLOGIT_SIGNED=$(Q5_SIGNED) \
	  -o Vtb_qec $(Q5SRCS) tb_qec.sv

qec5: qec5_lint
	$(MAKE) qec5_build QN=$(Q5_NVEC) LC=$(LC)
	mkdir -p $(Q5LOGDIR)
	set -e; ulimit -s unlimited; for s in $(SEEDS); do for r in 1 2; do \
	  log=$(Q5LOGDIR)/qec_d5_lc$(LC)_seed$${s}_run$${r}.log; \
	  { echo "# host=$$(hostname) date=$$(date -Is) verilator=$$(verilator --version)"; \
	    echo "# design=$(Q5GEN) $(Q5_SHA) in_hex_sha256=$$(sha256sum $(GOLDEN)/qec_d5_golden_in.hex | cut -c1-64) out_hex_sha256=$$(sha256sum $(GOLDEN)/qec_d5_golden_out.hex | cut -c1-64) dec_hex_sha256=$$(sha256sum $(GOLDEN)/qec_d5_golden_dec.hex | cut -c1-64)"; \
	    echo "# IN_W=120 OUT_W=$(Q5_OUT_W) LAT=$(Q5_LAT) NVEC=$(Q5_NVEC) seed=$$s run=$$r"; \
	    ./obj_dir_qec5_lc$(LC)_n$(Q5_NVEC)/Vtb_qec $(Q5ARGS) +SEED=$$s; } > $$log 2>&1 \
	    || { tail -20 $$log; exit 1; }; \
	  grep -h "RESULT" $$log; done; done

qec5_full: qec5_lint
	$(MAKE) qec5_build QN=$(Q5_NFULL) LC=$(LC)
	mkdir -p $(Q5LOGDIR)
	set -e; ulimit -s unlimited; for s in 0 1; do \
	  log=$(Q5LOGDIR)/qec_d5_lc$(LC)_full_seed$${s}.log; \
	  { echo "# host=$$(hostname) date=$$(date -Is) verilator=$$(verilator --version)"; \
	    echo "# design=$(Q5GEN) $(Q5_SHA) full_in_sha256=$$(sha256sum $(F5)_in.hex | cut -c1-64) full_out_sha256=$$(sha256sum $(F5)_out.hex | cut -c1-64) full_dec_sha256=$$(sha256sum $(F5)_dec.hex | cut -c1-64) (must equal ref/golden/qec_d5_full.json)"; \
	    echo "# IN_W=120 OUT_W=$(Q5_OUT_W) LAT=$(Q5_LAT) NVEC=$(Q5_NFULL) seed=$$s"; \
	    ./obj_dir_qec5_lc$(LC)_n$(Q5_NFULL)/Vtb_qec +IN=$(F5)_in.hex +OUT=$(F5)_out.hex +DEC=$(F5)_dec.hex +SEED=$$s; } > $$log 2>&1 \
	    || { tail -20 $$log; exit 1; }; \
	  grep -h "RESULT" $$log; done

# ---------------- Stage 3: decoder loop (s3_side_a <-> 2 link models <-> s3_side_b, s3_regs) ----------------
#   make -C tb s3_lint LC=5
#   make -C tb s3 LC=5                 all golden shots, two clock orientations (logs in evidence/stage3)
#   make -C tb s3 LC=5 S3_N=4096       quick run on the first 4096 shots (truncated shot memory)
#   make -C tb s3 LC=8 S3_LOGDIR=$(PROJ)/.scratch/s3_rerun   logs elsewhere (never overwrite committed logs)
# DEC_LAT (det -> flip) = metadata latency + 2 (core input register + stages + logit, + flip register).
S3_N      ?= $(Q_NVEC)
S3_LINK   ?= 40
S3_CC     ?= 1000
S3_TMO    ?= 100000
S3_LOGDIR ?=
S3LOGDIR  ?= $(if $(S3_LOGDIR),$(S3_LOGDIR),$(PROJ)/evidence/stage3/verilator)
S3_DEC    = $(shell python3 -c "import json;print(json.load(open('$(QGEN)/metadata.json'))['latency']+2)")
S3_MEM    = $(PROJ)/.scratch/s3_shots_n$(S3_N).hex
S3_OBJ    = obj_dir_s3_lc$(LC)_n$(S3_N)
S3_RTL    = $(PROJ)/rtl/s3/s3_pkg.sv $(PROJ)/rtl/s3/s3_side_a.sv $(PROJ)/rtl/s3/s3_side_b.sv $(PROJ)/rtl/s3/s3_regs.sv
S3_CORE   = $(wildcard $(QGEN)/src/static/*.v) $(wildcard $(QGEN)/src/qec_d3_stage*.v) $(QGEN)/src/qec_d3.v $(PROJ)/rtl/qec_d3_top.sv
S3_LINT   = verilator --lint-only -Wall -Wno-DECLFILENAME -Wno-UNUSEDPARAM --timescale 1ns/1ps -I$(QINC)
# clock orientations: "spec" = clk_a 6.206 / clk_b 6.207 ns (A faster); "aslow" = swapped
S3_CLOCKS ?= spec:6.206:6.207 aslow:6.207:6.206

.PHONY: s3 s3_lint s3_build s3_mem
s3_lint:
	$(S3_LINT) --top-module s3_side_a $(PROJ)/rtl/s3/s3_pkg.sv $(PROJ)/rtl/s3/s3_side_a.sv
	$(S3_LINT) --top-module s3_side_b -GOUT_W=$(Q_OUT_W) -GLOGIT_SIGNED=$(Q_SIGNED) -GDEC_LAT=$(S3_DEC) \
	  $(PROJ)/rtl/s3/s3_pkg.sv $(S3_CORE) $(PROJ)/rtl/s3/s3_side_b.sv
	$(S3_LINT) --top-module s3_regs $(PROJ)/rtl/s3/s3_pkg.sv $(PROJ)/rtl/s3/s3_regs.sv

# regenerated only when missing (parallel LC runs share it); delete it after a golden change
s3_mem:
	test -f $(S3_MEM) || python3 $(PROJ)/tb/s3_make_mem.py --nvec $(S3_N) --out $(S3_MEM)

s3_build: s3_mem
	verilator --binary --timing --timescale 1ns/1ps -j $(JOBS) -I$(QINC) --top-module tb_s3_loop --Mdir $(S3_OBJ) \
	  -Wno-fatal -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC --unroll-count 1024 -O3 \
	  -GNVEC=$(S3_N) -GDEC_LAT=$(S3_DEC) -GOUT_W=$(Q_OUT_W) -GLOGIT_SIGNED=$(Q_SIGNED) \
	  -GLINK_CYC=$(S3_LINK) -GCC_PERIOD=$(S3_CC) -GTIMEOUT=$(S3_TMO) -GINIT_FILE='"$(S3_MEM)"' \
	  -o Vtb_s3_loop $(PROJ)/rtl/s3/s3_pkg.sv $(S3_CORE) $(filter-out %s3_pkg.sv,$(S3_RTL)) tb_s3_loop.sv

s3: s3_lint s3_build
	mkdir -p $(S3LOGDIR)
	set -e; for c in $(S3_CLOCKS); do \
	  tag=$${c%%:*}; ta=$$(echo $$c | cut -d: -f2); tb=$$(echo $$c | cut -d: -f3); \
	  log=$(S3LOGDIR)/s3_loop_lc$(LC)_n$(S3_N)_$${tag}.log; \
	  { echo "# host=$$(hostname) date=$$(date -Is) verilator=$$(verilator --version)"; \
	    echo "# design=$(QGEN) rtl_sha256=$$(cat $(S3_RTL) $(PROJ)/rtl/qec_d3_top.sv $(QINC)/qec_d3_in_map.svh | sha256sum | cut -c1-64) tb_sha256=$$(sha256sum tb_s3_loop.sv | cut -c1-64)"; \
	    echo "# in_hex_sha256=$$(sha256sum $(GOLDEN)/qec_d3_golden_in.hex | cut -c1-64) dec_hex_sha256=$$(sha256sum $(GOLDEN)/qec_d3_golden_dec.hex | cut -c1-64) shot_mem_sha256=$$(sha256sum $(S3_MEM) | cut -c1-64) ($(S3_MEM), tb/s3_make_mem.py)"; \
	    echo "# NVEC=$(S3_N) DEC_LAT=$(S3_DEC) LINK_CYC=$(S3_LINK) CC_PERIOD=$(S3_CC) TIMEOUT=$(S3_TMO) TA_NS=$$ta TB_NS=$$tb clocks=$$tag"; \
	    ./$(S3_OBJ)/Vtb_s3_loop +TA_NS=$$ta +TB_NS=$$tb; } > $$log 2>&1 \
	    || { tail -30 $$log; exit 1; }; \
	  grep -h "RESULT" $$log; done

# ---------------- Stage 4 prep: the same loop at d = 5 (N_DET = 120, DW = 192: 3-lane Aurora words) ----------------
#   make -C tb s3d5 STANDIN=1 [D5_N=65536]  TEST-ONLY synthetic core tb/qec_d5_standin.sv (not a decoder) on
#                                            random vectors from tb/qec_d5_standin_gen.py; logs in .scratch/s3d5
#   make -C tb s3d5 LC=<cutoff>             the real da4ml core rtl/gen/qec_d5_lc<LC> + rtl/qec_d5_in_map.svh on
#                                            ref/golden/qec_d5_golden_{in,dec}.hex; logs in evidence/stage4/verilator
#   make -C tb s3d5_lint STANDIN=1|LC=..    lint side A / side B / regs at N_DET = 120, DW = 192
# The loop TB, side A, side B and s3_regs are the Stage 3 files with -GN_DET=120 -GDW=192.
STANDIN ?= 0
ifeq ($(STANDIN),1)
D5_N      ?= 65536
D5_TAG     = standin
D5_SDIR    = $(PROJ)/.scratch/s3d5_standin_n$(D5_N)
D5_IN      = $(D5_SDIR)/qec_d5_standin_in.hex
D5_DECF    = $(D5_SDIR)/qec_d5_standin_dec.hex
D5_INC     = $(PROJ)/tb/standin
D5_CORE    = $(PROJ)/tb/qec_d5_standin.sv $(PROJ)/rtl/d5/qec_d5_top.sv
D5_DEC     = 5
D5_OUT_W   = 16
D5_SIGNED  = 1
D5_LOGDIR ?= $(PROJ)/.scratch/s3d5/verilator
D5_MEMARGS = --in $(D5_IN) --dec $(D5_DECF)
else
D5_GEN    ?= $(PROJ)/rtl/gen/qec_d5_lc$(LC)
D5J        = $(GOLDEN)/qec_d5_golden.json
D5_N      ?= $(shell python3 -c "import json;print(json.load(open('$(D5J)'))['n_vectors'])")
# Stage 4 silicon vector sets 1..3 (tb/s4_vector_sets.py): D5_SET=<k> -> .scratch/qec_d5_set<k>_*, tag lc<LC>_set<k>
ifneq ($(D5_SET),)
D5_TAG     = lc$(LC)_set$(D5_SET)
D5_IN      = $(PROJ)/.scratch/qec_d5_set$(D5_SET)_in.hex
D5_DECF    = $(PROJ)/.scratch/qec_d5_set$(D5_SET)_dec.hex
D5_MEMARGS = --in $(D5_IN) --dec $(D5_DECF)
else
D5_TAG     = lc$(LC)
D5_IN      = $(GOLDEN)/qec_d5_golden_in.hex
D5_DECF    = $(GOLDEN)/qec_d5_golden_dec.hex
D5_MEMARGS =
endif
D5_INC     = $(PROJ)/rtl
D5_CORE    = $(wildcard $(D5_GEN)/src/static/*.v) $(wildcard $(D5_GEN)/src/qec_d5_stage*.v) $(D5_GEN)/src/qec_d5.v $(PROJ)/rtl/d5/qec_d5_top.sv
D5_DEC     = $(shell python3 -c "import json;print(json.load(open('$(D5_GEN)/metadata.json'))['latency']+2)")
D5_OUT_W   = $(shell python3 -c "import json;print(json.load(open('$(D5J)'))['out_width_bits'])")
D5_SIGNED  = $(shell python3 -c "import json;print(json.load(open('$(D5J)'))['out_kif'][0][0])")
D5_LOGDIR ?= $(PROJ)/evidence/stage4/verilator
endif
D5_MEM     = $(PROJ)/.scratch/s3d5_shots_$(D5_TAG)_n$(D5_N).hex
D5_OBJ     = obj_dir_s3d5_$(D5_TAG)_n$(D5_N)
D5_G       = -GN_DET=120 -GDW=192
D5_LINT    = verilator --lint-only -Wall -Wno-DECLFILENAME -Wno-UNUSEDPARAM --timescale 1ns/1ps -I$(D5_INC)

.PHONY: s3d5 s3d5_lint s3d5_build s3d5_mem
s3d5_lint:
	$(D5_LINT) --top-module s3_side_a $(D5_G) $(PROJ)/rtl/s3/s3_pkg.sv $(PROJ)/rtl/s3/s3_side_a.sv
	$(D5_LINT) --top-module s3_side_b $(D5_G) -GOUT_W=$(D5_OUT_W) -GLOGIT_SIGNED=$(D5_SIGNED) -GDEC_LAT=$(D5_DEC) \
	  $(PROJ)/rtl/s3/s3_pkg.sv $(D5_CORE) $(PROJ)/rtl/s3/s3_side_b.sv
	$(D5_LINT) --top-module s3_regs $(D5_G) $(PROJ)/rtl/s3/s3_pkg.sv $(PROJ)/rtl/s3/s3_regs.sv

s3d5_mem:
ifeq ($(STANDIN),1)
	test -f $(D5_IN) || python3 $(PROJ)/tb/qec_d5_standin_gen.py --n $(D5_N) --out $(D5_SDIR)
endif
	test -f $(D5_MEM) || python3 $(PROJ)/tb/s3_make_mem.py --d 5 $(D5_MEMARGS) --nvec $(D5_N) --out $(D5_MEM)

s3d5_build: s3d5_mem
	verilator --binary --timing --timescale 1ns/1ps -j $(JOBS) -I$(D5_INC) --top-module tb_s3_loop --Mdir $(D5_OBJ) \
	  -Wno-fatal -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC --unroll-count 1024 -O3 $(D5_G) \
	  -GNVEC=$(D5_N) -GDEC_LAT=$(D5_DEC) -GOUT_W=$(D5_OUT_W) -GLOGIT_SIGNED=$(D5_SIGNED) \
	  -GLINK_CYC=$(S3_LINK) -GCC_PERIOD=$(S3_CC) -GTIMEOUT=$(S3_TMO) -GINIT_FILE='"$(D5_MEM)"' \
	  -o Vtb_s3_loop $(PROJ)/rtl/s3/s3_pkg.sv $(D5_CORE) $(filter-out %s3_pkg.sv,$(S3_RTL)) tb_s3_loop.sv

s3d5: s3d5_lint s3d5_build
	mkdir -p $(D5_LOGDIR)
	set -e; ulimit -s unlimited; for c in $(S3_CLOCKS); do \
	  tag=$${c%%:*}; ta=$$(echo $$c | cut -d: -f2); tb=$$(echo $$c | cut -d: -f3); \
	  log=$(D5_LOGDIR)/s3d5_loop_$(D5_TAG)_n$(D5_N)_$${tag}.log; \
	  { echo "# host=$$(hostname) date=$$(date -Is) verilator=$$(verilator --version)"; \
	    echo "# core=$(D5_TAG) ($(D5_CORE)) rtl_sha256=$$(cat $(S3_RTL) $(D5_CORE) $(D5_INC)/qec_d5_in_map.svh | sha256sum | cut -c1-64) tb_sha256=$$(sha256sum tb_s3_loop.sv | cut -c1-64)"; \
	    echo "# in_hex_sha256=$$(sha256sum $(D5_IN) | cut -c1-64) dec_hex_sha256=$$(sha256sum $(D5_DECF) | cut -c1-64) shot_mem_sha256=$$(sha256sum $(D5_MEM) | cut -c1-64) ($(D5_MEM), tb/s3_make_mem.py --d 5)"; \
	    echo "# N_DET=120 DW=192 NVEC=$(D5_N) DEC_LAT=$(D5_DEC) OUT_W=$(D5_OUT_W) LINK_CYC=$(S3_LINK) CC_PERIOD=$(S3_CC) TIMEOUT=$(S3_TMO) TA_NS=$$ta TB_NS=$$tb clocks=$$tag"; \
	    ./$(D5_OBJ)/Vtb_s3_loop +TA_NS=$$ta +TB_NS=$$tb; } > $$log 2>&1 \
	    || { tail -30 $$log; exit 1; }; \
	  grep -h "RESULT" $$log; done

# ---------------- board top lint (s3_top with the IP stubs), both link widths ----------------
#   make -C tb s3_top_lint LC=8               DW = 64:  aurora_a/b, qec_d3_lc<LC>
#   make -C tb s3_top_lint_d5 STANDIN=1       DW = 192: aurora3_a/b, the d = 5 core (stand-in or LC=..)
S3T_STUBS = $(PROJ)/tb/s3_top_lint.vlt $(PROJ)/tb/s3_lint_stubs.v $(PROJ)/rtl/ip/s3_jtag_axi/s3_jtag_axi_stub.v \
            $(VLIB)/primitives/xilinx_clk_primitives.sv
S3T_RTL   = $(PROJ)/rtl/s3/s3_pkg.sv $(filter-out %s3_pkg.sv,$(S3_RTL)) $(PROJ)/rtl/s3/s3_freq.sv $(PROJ)/rtl/s3/s3_top.sv
.PHONY: s3_top_lint s3_top_lint_d5
# PINCONNECTEMPTY waived: the unused IP outputs are left open on purpose (as in the Stage 3 lint)
s3_top_lint:
	$(S3_LINT) -Wno-PINCONNECTEMPTY --top-module s3_top -GDEC_LAT=$(S3_DEC) -GOUT_W=$(Q_OUT_W) -GLOGIT_SIGNED=$(Q_SIGNED) \
	  $(S3T_STUBS) $(PROJ)/rtl/ip/aurora_a/aurora_a_stub.v $(PROJ)/rtl/ip/aurora_b/aurora_b_stub.v $(S3_CORE) $(S3T_RTL)
s3_top_lint_d5:
	$(D5_LINT) -Wno-PINCONNECTEMPTY --top-module s3_top $(D5_G) -GDEC_LAT=$(D5_DEC) -GOUT_W=$(D5_OUT_W) -GLOGIT_SIGNED=$(D5_SIGNED) \
	  $(S3T_STUBS) $(PROJ)/rtl/ip/aurora3_a/aurora3_a_stub.v $(PROJ)/rtl/ip/aurora3_b/aurora3_b_stub.v $(D5_CORE) $(S3T_RTL)

# ---------------- Stage 5: X310 waveform classifier (x310_clf_top = BFP + da4ml core + argmax; x310_stream) ----------------
#   make -C tb x310 LC=<cutoff>                full test set (.scratch/x310_full_*.hex, sha256 in ref/golden/x310_full.json):
#                                              4 seeds x 2 runs (seed 0 natural order; others shuffled + idle gaps); then the
#                                              stream set (ref/golden/x310_stream_*, every sliding window), 4 seeds x 2 runs;
#                                              then the negative controls (a corrupted expected vector must FAIL)
#   make -C tb x310 LC=<cutoff> XSET=golden    the committed golden subset (ref/golden/x310_golden_*) instead of the full set
#   BFP_PIPE=0 / 2                             BFP variants (default 1 = OR mask registered, +1 cycle; 0 = none; 2 = + shift amount)
XGEN     ?= $(PROJ)/rtl/gen/x310_clf_lc$(LC)
XINC     ?= $(PROJ)/rtl/gen
XLOGDIR  ?= $(PROJ)/evidence/stage5/verilator
XSET     ?= full
BFP_PIPE ?= 1
XJ        = $(GOLDEN)/x310_golden.json
X_W       = $(shell python3 -c "import json;print(json.load(open('$(XJ)'))['w'])")
X_OUT_W   = $(shell python3 -c "import json;print(json.load(open('$(XJ)'))['out_width_bits'])")
X_NV      = $(shell python3 -c "import json;print(json.load(open('$(XJ)'))['$(if $(filter full,$(XSET)),n_full,n_vectors)'])")
X_NS      = $(shell python3 -c "import json;print(json.load(open('$(GOLDEN)/x310_stream.json'))['n_samples'])")
X_CLAT    = $(shell python3 -c "import json;print(json.load(open('$(XGEN)/metadata.json'))['latency']+1)")
XFULL    ?= $(PROJ)/.scratch/x310_full
X_PFX     = $(if $(filter full,$(XSET)),$(XFULL),$(GOLDEN)/x310_golden)
X_SPFX    = $(GOLDEN)/x310_stream
X_TAG     = lc$(LC)$(if $(filter-out 1,$(BFP_PIPE)),_p$(BFP_PIPE),)
XOBJ      = obj_dir_x310_$(X_TAG)_n$(X_NV)
XSOBJ     = obj_dir_x310s_$(X_TAG)_n$(X_NS)
XG        = -GW=$(X_W) -GOUT_W=$(X_OUT_W) -GCORE_LAT=$(X_CLAT) -GBFP_PIPE=$(BFP_PIPE)
XCORE     = $(wildcard $(XGEN)/src/static/*.v) $(wildcard $(XGEN)/src/x310_clf_stage*.v) $(XGEN)/src/x310_clf.v
XRTL      = $(PROJ)/rtl/x310/x310_clf_top.sv $(PROJ)/rtl/x310/x310_stream.sv
XVFLAGS   = --binary --timing -j $(JOBS) -I$(XINC) -Wno-fatal -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC --unroll-count 1024 -O3
X_SHA     = rtl_sha256=$$(cat $(XRTL) $(XINC)/x310_clf_lanes.svh | sha256sum | cut -c1-64)
X_ARGS    = +IN=$(X_PFX)_in.hex +OUT=$(X_PFX)_out.hex +DEC=$(X_PFX)_dec.hex
X_SARGS   = +IN=$(X_SPFX)_in.hex +OUT=$(X_SPFX)_out.hex +DEC=$(X_SPFX)_dec.hex
X_NEG     = 777

.PHONY: x310 x310_lint x310_build x310s_build x310_win x310_stream x310_neg
x310_lint:
	verilator --lint-only -Wall -Wno-DECLFILENAME -Wno-UNUSEDPARAM -I$(XINC) --top-module x310_stream $(XG) $(XCORE) $(XRTL)

x310_build:
	verilator $(XVFLAGS) --top-module tb_x310 --Mdir $(XOBJ) $(XG) -GNVEC=$(X_NV) -o Vtb_x310 $(XCORE) $(XRTL) tb_x310.sv

x310s_build:
	verilator $(XVFLAGS) --top-module tb_x310_stream --Mdir $(XSOBJ) $(XG) -GNS=$(X_NS) -o Vtb_x310_stream $(XCORE) $(XRTL) tb_x310_stream.sv

x310_win: x310_lint x310_build
	X310_GOLDEN=$(GOLDEN) python3 x310_check.py $(XSET)
	mkdir -p $(XLOGDIR)
	set -e; for s in $(SEEDS); do for r in 1 2; do \
	  log=$(XLOGDIR)/x310_clf_$(X_TAG)_$(XSET)_seed$${s}_run$${r}.log; \
	  { echo "# host=$$(hostname) date=$$(date -Is) verilator=$$(verilator --version)"; \
	    echo "# design=$(XGEN) $(X_SHA) $$(X310_GOLDEN=$(GOLDEN) python3 x310_check.py $(XSET))"; \
	    echo "# W=$(X_W) OUT_W=$(X_OUT_W) CORE_LAT=$(X_CLAT) BFP_PIPE=$(BFP_PIPE) NVEC=$(X_NV) set=$(XSET) seed=$$s run=$$r"; \
	    ./$(XOBJ)/Vtb_x310 $(X_ARGS) +SEED=$$s; } > $$log 2>&1 \
	    || { tail -20 $$log; exit 1; }; \
	  grep -h "RESULT" $$log; done; done

x310_stream: x310_lint x310s_build
	X310_GOLDEN=$(GOLDEN) python3 x310_check.py stream
	mkdir -p $(XLOGDIR)
	set -e; for s in $(SEEDS); do for r in 1 2; do \
	  log=$(XLOGDIR)/x310_stream_$(X_TAG)_seed$${s}_run$${r}.log; \
	  { echo "# host=$$(hostname) date=$$(date -Is) verilator=$$(verilator --version)"; \
	    echo "# design=$(XGEN) $(X_SHA) $$(X310_GOLDEN=$(GOLDEN) python3 x310_check.py stream)"; \
	    echo "# W=$(X_W) OUT_W=$(X_OUT_W) CORE_LAT=$(X_CLAT) BFP_PIPE=$(BFP_PIPE) NS=$(X_NS) seed=$$s run=$$r"; \
	    ./$(XSOBJ)/Vtb_x310_stream $(X_SARGS) +SEED=$$s; } > $$log 2>&1 \
	    || { tail -20 $$log; exit 1; }; \
	  grep -h "RESULT" $$log; done; done

# negative controls: the expected logits of one vector corrupted; the run must FAIL and name that vector
x310_neg: x310_build x310s_build
	mkdir -p $(XLOGDIR)
	log=$(XLOGDIR)/x310_neg_$(X_TAG)_$(XSET).log; \
	  if ./$(XOBJ)/Vtb_x310 $(X_ARGS) +SEED=1 +CORRUPT=$(X_NEG) > $$log 2>&1; then echo "NEGATIVE CONTROL DID NOT FAIL ($$log)"; exit 1; fi; \
	  grep -q "^MISMATCH vec=$(X_NEG) " $$log || { echo "negative control failed for another reason ($$log)"; exit 1; }; \
	  echo "NEGATIVE CONTROL (windows) failed as required: $$(grep -m1 '^MISMATCH' $$log)"
	log=$(XLOGDIR)/x310_neg_stream_$(X_TAG).log; \
	  if ./$(XSOBJ)/Vtb_x310_stream $(X_SARGS) +SEED=1 +CORRUPT=$(X_NEG) > $$log 2>&1; then echo "NEGATIVE CONTROL DID NOT FAIL ($$log)"; exit 1; fi; \
	  grep -q "^MISMATCH window=$(X_NEG) " $$log || { echo "negative control failed for another reason ($$log)"; exit 1; }; \
	  echo "NEGATIVE CONTROL (stream) failed as required: $$(grep -m1 '^MISMATCH' $$log)"

x310: x310_win x310_stream x310_neg

# ---------------- Stage 5: the nsclf RFNoC block (rtl/x310/nsclf_core.sv + nsclf_user.sv: everything below the noc_shell) ----------------
#   make -C tb nsclf LC=<cutoff>        lint, build, 4 configurations x 2 runs on the golden stream (tb/run_nsclf.sh:
#                                       decisions, tau, latency, pass-through, MISR windows, events), then the negatives
#   make -C tb nsclf_block_lint LC=<c>  Verilator lint of the whole block: rfnoc_block_nsclf + the framework-generated
#                                       noc_shell_nsclf + the UHD 4.9 library it pulls in (.scratch/uhd), FIFO IPs stubbed
NSC_RTL    = $(PROJ)/rtl/x310/nsclf_core.sv $(PROJ)/rtl/x310/nsclf_user.sv
NSC_TAG    = lc$(LC)
NSC_OBJ    = obj_dir_nsclf_$(NSC_TAG)
NSC_LOGDIR ?= $(PROJ)/evidence/stage5/block
NSC_STIM   ?= $(PROJ)/.scratch/nsclf_stim
NSC_LCX10  = $(shell python3 -c "print(int(round($(LC)*10)))")
NSC_G      = $(XG) -GIN_REG=1
UHD_LIB   ?= $(PROJ)/.scratch/uhd/fpga/usrp3/lib
NSC_BLK    = $(PROJ)/rtl/x310/noc_shell_nsclf.sv $(PROJ)/rtl/x310/rfnoc_block_nsclf.sv
NSC_UHDY   = -y $(UHD_LIB)/rfnoc/core -y $(UHD_LIB)/rfnoc/utils -y $(UHD_LIB)/rfnoc/xport_sv -y $(UHD_LIB)/fifo \
             -y $(UHD_LIB)/control -y $(UHD_LIB)/axi -y $(UHD_LIB)/axi4s_sv -y $(UHD_LIB)/packet_proc -y $(UHD_LIB)/dsp \
             +incdir+$(UHD_LIB)/rfnoc/core +incdir+$(UHD_LIB)/rfnoc/utils +incdir+$(UHD_LIB)/axi4s_sv

.PHONY: nsclf nsclf_lint nsclf_build nsclf_block_lint
nsclf_lint:
	verilator --lint-only -Wall -Wno-DECLFILENAME -Wno-UNUSEDPARAM -I$(XINC) --top-module nsclf_user $(XG) -GLC_X10=$(NSC_LCX10) \
	  $(XCORE) $(XRTL) $(NSC_RTL)

nsclf_build:
	verilator $(XVFLAGS) --top-module tb_nsclf --Mdir $(NSC_OBJ) $(NSC_G) -GNS=$(X_NS) -o Vtb_nsclf $(XCORE) $(XRTL) $(NSC_RTL) tb_nsclf.sv

nsclf_block_lint:
	mkdir -p $(NSC_LOGDIR)
	{ echo "# host=$$(hostname) date=$$(date -Is) verilator=$$(verilator --version) uhd=$$(git -C $(PROJ)/.scratch/uhd rev-parse --short HEAD)"; \
	  verilator --lint-only -Wall -Wno-DECLFILENAME -Wno-UNUSEDPARAM -Wno-fatal -I$(XINC) --top-module rfnoc_block_nsclf \
	  -GCORE_LAT=$(X_CLAT) -GLC_X10=$(NSC_LCX10) nsclf_uhd_lint.vlt $(NSC_UHDY) nsclf_lint_stubs.sv \
	  $(XCORE) $(XRTL) $(NSC_RTL) $(NSC_BLK) 2>&1; echo "verilator rc=$$?"; } > $(NSC_LOGDIR)/nsclf_block_lint_$(NSC_TAG).log; \
	  tail -3 $(NSC_LOGDIR)/nsclf_block_lint_$(NSC_TAG).log

nsclf: nsclf_lint nsclf_build
	./run_nsclf.sh $(abspath $(NSC_OBJ))/Vtb_nsclf $(NSC_LOGDIR) $(NSC_TAG) $(NSC_STIM)/$(NSC_TAG)
	./run_nsclf.sh $(abspath $(NSC_OBJ))/Vtb_nsclf $(NSC_LOGDIR) $(NSC_TAG) $(NSC_STIM)/$(NSC_TAG) neg

# ---------------- Stage 5: stock UHD radio timestamp relation (tb_radio_ts.sv on UHD's own radio_core) ----------------
#   make -C tb radio_ts   (snoke) UHD 4.9 xsim flow, Vivado 2024.2: EN_COMP_GAIN_RX = 1 (the X310 image's radio0: host
#                         timestamp = tap time + 6) and the control EN_COMP_GAIN_RX = 0 (+0); logs in evidence/stage5/block/.
#                         xsim, not Verilator: Verilator 5.020 rejects radio_core's zero-width selects at NSPC = 1.
#   make -C tb nsclf_uhdsim  the whole nsclf block (noc_shell, CHDR, ctrlport) in the UHD block-testbench flow (xsim)
.PHONY: radio_ts nsclf_uhdsim
radio_ts:
	$(PROJ)/sw/x310/uhdsim/run_uhdsim.sh radio_ts tb_radio_ts_cg1
	$(PROJ)/sw/x310/uhdsim/run_uhdsim.sh radio_ts tb_radio_ts_cg0
nsclf_uhdsim:
	UHDSIM_LOGDIR=$(NSC_LOGDIR) $(PROJ)/sw/x310/uhdsim/run_uhdsim.sh nsclf rfnoc_block_nsclf_tb
	python3 $(PROJ)/sw/x310/nsclf_model.py check-events --model $(NSC_STIM)/lc2/seed0/events_model.json \
	  --log $(NSC_LOGDIR)/uhdsim_nsclf_rfnoc_block_nsclf_tb.log | tee $(NSC_LOGDIR)/uhdsim_nsclf_check_events.log

# ---------------- Stage 5: replay of a host capture through the nsclf RTL (driven by sw/x310/nsclf_replay.py) ----------------
#   make -C tb nsclf_replay LC=<c> RNS=<samples> RSTIM=<dir> RT0=<tap time of sample 0, hex> RK=<K> RLOG=<log>
#     [RDUMP=<file>: every decision's tau and {logits, cls} as text, for sw/x310/nsclf_replay.py --dump]
.PHONY: nsclf_replay
nsclf_replay:
	verilator $(XVFLAGS) --top-module tb_nsclf --Mdir obj_dir_nsclf_replay_$(NSC_TAG)_n$(RNS) $(NSC_G) -GNS=$(RNS) \
	  -o Vtb_nsclf $(XCORE) $(XRTL) $(NSC_RTL) tb_nsclf.sv > obj_dir_nsclf_replay_$(NSC_TAG)_n$(RNS).build.log 2>&1 \
	  || { tail -20 obj_dir_nsclf_replay_$(NSC_TAG)_n$(RNS).build.log; exit 1; }
	{ echo "# host=$$(hostname) date=$$(date -Is) verilator=$$(verilator --version) replay stim=$(RSTIM) T0=$(RT0) K=$(RK)"; \
	  ./obj_dir_nsclf_replay_$(NSC_TAG)_n$(RNS)/Vtb_nsclf +STIM=$(RSTIM) +REPLAY=1 +SEED=0 +CHAN=0 +K=$(RK) +READY=0 +NWIN=1 \
	  +T0=$(RT0) $(if $(RDUMP),+DUMP=$(RDUMP)); } > $(RLOG) 2>&1 || { tail -20 $(RLOG); exit 1; }

# ---------------- Stage 6: thin custom GTY link (rtl/s6), ONE clock (docs/PLAN.md B.5) ----------------
#   make -C tb s6_link                     the link alone (tb_s6_link): NL = 1 and 3, TX_REG/RX_REG = 0/0 and 1/1, then
#                                          the negative control (+NEGSCR: a wrong reference polynomial must FAIL)
#   make -C tb s6 LC=8 [S6_N=4096]         the d = 3 loop (tb_s6_loop: s6_core + GT models): probes + the s3 cases on the
#                                          golden shots, for each model setting in S6_RUNS (LAT_UI:SEED)
#   make -C tb s6d5 LC=3bc [D5_SET=k]      the d = 5 loop (3 lanes, DW = 192), same cases
#   make -C tb s6_lint LC=8 / s6_top_lint  lint s6_core / the board top (with IP stubs)
#   S6_LOGDIR=<dir> puts the logs elsewhere (default evidence/stage6/verilator; never the Stage 3/4 dirs)
S6_LOGDIR ?= $(PROJ)/evidence/stage6/verilator
S6_TXR    ?= 0
S6_RXR    ?= 0
S6_RUNS   ?= 640:0 701:1
S6_N      ?= $(Q_NVEC)
S6_PKG     = $(PROJ)/rtl/s6/s6_pkg.sv
S6_RTL     = $(PROJ)/rtl/s6/s6_link.sv $(PROJ)/rtl/s6/s6_probe.sv $(PROJ)/rtl/s6/s6_diag.sv $(PROJ)/rtl/s6/s6_core.sv
S6_VFL     = --binary --timing --timescale 1ns/1ps -j $(JOBS) -Wno-fatal -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC
S6_LINT    = verilator --lint-only -Wall -Wno-DECLFILENAME -Wno-UNUSEDPARAM --timescale 1ns/1ps
S6_MEM     = $(PROJ)/.scratch/s3_shots_n$(S6_N).hex
S6_OBJ     = obj_dir_s6_lc$(LC)_n$(S6_N)_t$(S6_TXR)r$(S6_RXR)
S6_G       = -GTX_REG=$(S6_TXR) -GRX_REG=$(S6_RXR)
S6_SHA     = rtl_sha256=$$(cat $(S6_PKG) $(S6_RTL) $(S3_RTL) | sha256sum | cut -c1-64) tb_sha256=$$(cat tb_s6_gt.sv tb_s6_loop.sv | sha256sum | cut -c1-64)

.PHONY: s6_link s6 s6_lint s6_build s6d5 s6d5_build s6_top_lint
s6_link:
	mkdir -p $(S6_LOGDIR)
	set -e; for c in 1:0:0 3:0:0 1:1:1 3:1:1; do \
	  nl=$$(echo $$c | cut -d: -f1); tx=$$(echo $$c | cut -d: -f2); rx=$$(echo $$c | cut -d: -f3); \
	  o=obj_dir_s6_link_nl$${nl}_t$${tx}r$${rx}; log=$(S6_LOGDIR)/s6_link_nl$${nl}_t$${tx}r$${rx}.log; \
	  verilator $(S6_VFL) --top-module tb_s6_link --Mdir $$o -GNL=$$nl -GTX_REG=$$tx -GRX_REG=$$rx -o Vtb_s6_link \
	    $(S6_PKG) $(PROJ)/rtl/s6/s6_link.sv tb_s6_gt.sv tb_s6_link.sv > $$o.build.log 2>&1 || { tail -20 $$o.build.log; exit 1; }; \
	  { echo "# host=$$(hostname) date=$$(date -Is) verilator=$$(verilator --version)"; \
	    echo "# rtl_sha256=$$(cat $(S6_PKG) $(PROJ)/rtl/s6/s6_link.sv | sha256sum | cut -c1-64) tb_sha256=$$(cat tb_s6_gt.sv tb_s6_link.sv | sha256sum | cut -c1-64) NL=$$nl TX_REG=$$tx RX_REG=$$rx"; \
	    ./$$o/Vtb_s6_link; } > $$log 2>&1 || { tail -20 $$log; exit 1; }; \
	  grep -h "RESULT" $$log; done
	log=$(S6_LOGDIR)/s6_link_nl1_t0r0_negscr.log; \
	  { echo "# host=$$(hostname) date=$$(date -Is) NEGATIVE CONTROL: +NEGSCR (reference descrambler with the x^38 tap) must FAIL"; \
	    ./obj_dir_s6_link_nl1_t0r0/Vtb_s6_link +NEGSCR; echo "exit=$$?"; } > $$log 2>&1; \
	  if grep -q "^PASS" $$log || ! grep -q "REF: independent descrambler disagrees" $$log; then echo "NEGATIVE CONTROL DID NOT FAIL: $$log"; exit 1; fi; \
	  echo "NEGATIVE_CONTROL_FAILED_AS_REQUIRED" >> $$log; grep -h "REF\|NEGATIVE" $$log

s6_lint:
	$(S6_LINT) -I$(QINC) --top-module s6_core -GDEC_LAT=$(S3_DEC) -GOUT_W=$(Q_OUT_W) -GLOGIT_SIGNED=$(Q_SIGNED) $(S6_G) \
	  $(PROJ)/rtl/s3/s3_pkg.sv $(S6_PKG) $(S3_CORE) $(filter-out %s3_pkg.sv,$(S3_RTL)) $(S6_RTL)

s6_build:
	$(MAKE) s3_mem S3_N=$(S6_N) LC=$(LC)
	verilator $(S6_VFL) -I$(QINC) --top-module tb_s6_loop --Mdir $(S6_OBJ) $(S6_G) \
	  -GNVEC=$(S6_N) -GDEC_LAT=$(S3_DEC) -GOUT_W=$(Q_OUT_W) -GLOGIT_SIGNED=$(Q_SIGNED) -GTIMEOUT=$(S3_TMO) -GINIT_FILE='"$(S6_MEM)"' \
	  -o Vtb_s6_loop $(PROJ)/rtl/s3/s3_pkg.sv $(S6_PKG) $(S3_CORE) $(filter-out %s3_pkg.sv,$(S3_RTL)) $(S6_RTL) tb_s6_gt.sv tb_s6_loop.sv

s6: s6_lint s6_build
	mkdir -p $(S6_LOGDIR)
	set -e; for c in $(S6_RUNS); do \
	  lu=$${c%%:*}; sd=$${c##*:}; log=$(S6_LOGDIR)/s6_loop_lc$(LC)_n$(S6_N)_t$(S6_TXR)r$(S6_RXR)_lat$${lu}_s$${sd}.log; \
	  { echo "# host=$$(hostname) date=$$(date -Is) verilator=$$(verilator --version)"; \
	    echo "# design=$(QGEN) $(S6_SHA)"; \
	    echo "# in_hex_sha256=$$(sha256sum $(GOLDEN)/qec_d3_golden_in.hex | cut -c1-64) dec_hex_sha256=$$(sha256sum $(GOLDEN)/qec_d3_golden_dec.hex | cut -c1-64) shot_mem_sha256=$$(sha256sum $(S6_MEM) | cut -c1-64) ($(S6_MEM), tb/s3_make_mem.py)"; \
	    echo "# NVEC=$(S6_N) DEC_LAT=$(S3_DEC) TX_REG=$(S6_TXR) RX_REG=$(S6_RXR) TIMEOUT=$(S3_TMO) LAT_UI=$$lu SEED=$$sd"; \
	    ./$(S6_OBJ)/Vtb_s6_loop +LAT_UI=$$lu +SEED=$$sd; } > $$log 2>&1 || { tail -30 $$log; exit 1; }; \
	  grep -h "RESULT" $$log; done

S6D5_OBJ = obj_dir_s6d5_$(D5_TAG)_n$(D5_N)_t$(S6_TXR)r$(S6_RXR)
s6d5_build: s3d5_mem
	verilator $(S6_VFL) -I$(D5_INC) --top-module tb_s6_loop --Mdir $(S6D5_OBJ) --unroll-count 1024 -O3 $(D5_G) $(S6_G) \
	  -GNVEC=$(D5_N) -GDEC_LAT=$(D5_DEC) -GOUT_W=$(D5_OUT_W) -GLOGIT_SIGNED=$(D5_SIGNED) -GTIMEOUT=$(S3_TMO) -GINIT_FILE='"$(D5_MEM)"' \
	  -o Vtb_s6_loop $(PROJ)/rtl/s3/s3_pkg.sv $(S6_PKG) $(D5_CORE) $(filter-out %s3_pkg.sv,$(S3_RTL)) $(S6_RTL) tb_s6_gt.sv tb_s6_loop.sv

s6d5: s6d5_build
	mkdir -p $(S6_LOGDIR)
	set -e; ulimit -s unlimited; for c in $(S6_RUNS); do \
	  lu=$${c%%:*}; sd=$${c##*:}; log=$(S6_LOGDIR)/s6d5_loop_$(D5_TAG)_n$(D5_N)_t$(S6_TXR)r$(S6_RXR)_lat$${lu}_s$${sd}.log; \
	  { echo "# host=$$(hostname) date=$$(date -Is) verilator=$$(verilator --version)"; \
	    echo "# core=$(D5_TAG) ($(D5_CORE)) $(S6_SHA)"; \
	    echo "# in_hex_sha256=$$(sha256sum $(D5_IN) | cut -c1-64) dec_hex_sha256=$$(sha256sum $(D5_DECF) | cut -c1-64) shot_mem_sha256=$$(sha256sum $(D5_MEM) | cut -c1-64) ($(D5_MEM), tb/s3_make_mem.py --d 5)"; \
	    echo "# N_DET=120 DW=192 NVEC=$(D5_N) DEC_LAT=$(D5_DEC) OUT_W=$(D5_OUT_W) TX_REG=$(S6_TXR) RX_REG=$(S6_RXR) TIMEOUT=$(S3_TMO) LAT_UI=$$lu SEED=$$sd"; \
	    ./$(S6D5_OBJ)/Vtb_s6_loop +LAT_UI=$$lu +SEED=$$sd; } > $$log 2>&1 || { tail -30 $$log; exit 1; }; \
	  grep -h "RESULT" $$log; done

# s6_top lint (d = 3): the GT wizard / JTAG-AXI IP stubs and the lint-only primitives, as s3_top_lint;
# S6_TXBYP=1: the TX-buffer-bypass core's stub (rtl/ip/s6_gt_bp, synth/scripts/s6_gen_gt.tcl txbyp synth) and TXBYP = 1
S6_TXBYP  ?= 0
S6_GTCORE  = $(if $(filter 1,$(S6_TXBYP)),s6_gt_bp,s6_gt)
s6_top_lint:
	$(S6_LINT) -Wno-PINCONNECTEMPTY -I$(QINC) --top-module s6_top -GDEC_LAT=$(S3_DEC) -GOUT_W=$(Q_OUT_W) -GLOGIT_SIGNED=$(Q_SIGNED) $(S6_G) \
	  -GTXBYP=$(S6_TXBYP) $(S3T_STUBS) $(PROJ)/rtl/ip/$(S6_GTCORE)/$(S6_GTCORE)_stub.v $(S3_CORE) $(PROJ)/rtl/s3/s3_pkg.sv $(S6_PKG) \
	  $(filter-out %s3_pkg.sv,$(S3_RTL)) $(PROJ)/rtl/s3/s3_freq.sv $(S6_RTL) $(PROJ)/rtl/s6/s6_top.sv
