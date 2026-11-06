# Stage 6 status (2026-11-06, after d = 5 vector sets 1-3 on silicon)

## Where it stands
- **d = 3: all four gates passed** (2026-11-03; committed 695cded).
- **d = 5: all four gates passed for vector set 0** (2026-11-05): sims `verilator/s6d5_loop_lc3bc_n131072_t0r0_*.log` PASS,
  build `build/s6d5_lc3bc_a/` (WNS +0.037 / WHS +0.013 / WPWS +0.442, single clock PASS, re-checked on the checkpoint before
  `write_bitstream`), silicon `silicon/s6d5_lc3bc_a_*` (3 runs, 2 bring-ups, 9/9 modes bit-exact): decode loop median 67 cycles
  = 415.8 ns (Aurora, Stage 4: 850-856 ns), echo 48 = 297.9 ns, one-way probe 21-24 cycles = 130.3-148.9 ns.
  Write-up: `README.md` §7; `docs/PLAN.md` §B.5 result bullet and stage-table row 6.
- **d = 5 vector sets 1-3: passed on silicon (2026-11-06)** (README §7): builds `build/s6d5_lc3bc_set{1,2,3}/` (each WNS +0.037 /
  WHS +0.013 / WPWS +0.442, single clock PASS), sims `verilator/s6d5_loop_lc3bc_set*_*.log` PASS, silicon
  `silicon/*s6d5_lc3bc_set*` (3 runs per set, a load and a re-train, 27/27 modes bit-exact, decode signature = each set's sim):
  decode loop median 66-68 cycles = 409.6-422.0 ns. CHARTER rule (c) now holds at d = 5 on the Stage 6 link (4 sets).

- **TX buffer bypass at d = 3: passed on silicon (2026-11-06)** (README §6, PLAN D-S6-TXBYP): build s6bp_lc8_a, one way 18-21
  cycles = 111.7-130.3 ns, decode loop median 46-47 cycles = 285.5-291.7 ns, 9/9 modes bit-exact over a load and 3 re-trains.
- **In progress 2026-11-06:** link check blocks (CRC-32) on branch
  `s6-crc` (worktree `.scratch/wt_crc`, link tests PASS, loop sim running). Plan: `docs/superpowers/plans/2026-11-06-stage6-next.md`.

## State left
- Desk card: build **s6d5_lc3bc_set3** loaded (volatile, `synth/out_s6d5_lc3bc_set3/s6_top.bit`, sha256 `f1290662…`), link up;
  desk lock not held. Nothing of mine is running on build-host (no Vivado, no Verilator).
- Uncommitted since 9521ca1: `synth/scripts/s6_bitstream.tcl` (checkpoint re-check), the d = 5 build / silicon evidence, README,
  PLAN.md, BRINGUP.md, this file.

## Open problems / doubts (unchanged from 11-03 unless noted)
- Margin to 156 ns is thin (worst probe word 148.9 ns on the final builds, 155.2 ns once on the first d = 3 build after a re-train).
- The GTY PCS at the 64-bit internal width is ~100 ns of the ~140 ns one way (near-end PCS loopback 17-19 cycles, d = 3 and d = 5
  alike). Lower needs a clocking change (32-bit internal width = a 322 MHz TXUSRCLK net; RX buffer bypass = recovered clock), i.e.
  the user's approval under the single-clock rule. TX-only buffer bypass might stay one clock; not tried.
- The 156 ns figure is from a secondary report ("measured in the RISC-Q work", arXiv 2603.16203); the paper was not read.
- No CRC: misaligned blocks can be delivered before lock is lost (sim); the s3 checks catch them.

## Commands used for sets 1-3 (2026-11-06)
```
for k in 1 2 3; do ssh -n build-host "cd <repo> && (nohup make -C tb s6d5 LC=3bc D5_SET=$k JOBS=8 > .scratch/s6/runs/s6d5_set$k.out 2>&1 < /dev/null &)"; done
for k in 1 2 3; do ssh -n build-host "cd <repo> && D5_N=131072 D5_SET=$k synth/scripts/launch_s6.sh s6d5_lc3bc_set$k 3bc Default 5 0 0" > /dev/null 2>&1; done
# in each synth/out_s6d5_lc3bc_set<k>: vivado -mode batch -nojournal -source ../scripts/s6_bitstream.tcl -tclargs .
ssh build-host 'cd <repo> && for k in 1 2 3; do sw/bcu/s6d5_set_silicon.sh $k; done'
python3 sw/analysis/s6_analyze.py --d 5 --lc 3bc_set<k> --dec .scratch/qec_d5_set<k>_dec.hex <log> --json <json>
python3 sw/analysis/s6_summary.py silicon/s6d5_lc3bc_set<k>_cable_run{1,2,3}.json --out silicon/summary_d5_lc3bc_set<k>.json
```
