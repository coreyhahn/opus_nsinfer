# Stage 0 gate — flow and budget (no board)

Date: 2026-10-19/20. All numbers below are **sim** (Verilator) or **model**
(Vivado 2024.2 OOC synthesis + place + route). Nothing here is silicon.

## 1. Model (ref/, training/)
- Workload: hls4ml HLF jet-substructure classifier, 16 inputs, 5 classes,
  MLP 16-64-32-32-5 ReLU; OpenML 42468 (CC-BY), frozen split
  597,600 / 66,400 / 166,000 (`ref/jsc_split_meta.json`).
- Float64 baseline (Keras, JAX x64): **77.08 %** test accuracy (best val 77.12 %).
- HGQ2 (float64 training, KBI SAT_SYM weights, KIF WRAP activations
  calibrated with `trace_minmax` on the training split): three β schedules ×
  1,000 epochs, 129 Pareto checkpoints (`training/*.train_log.json`).
- Selection on validation only (`docs/PLAN.md` §A.1).
  - **Attempt 1 (margin 0.4 pt)** picked 15.3k EBOPs. Its test accuracy was
    76.57 %, 0.51 pt below float, which misses the charter's 0.5 pt rule
    (`selection_attempt1_margin0.4*.json`).
  - **Attempt 2 (margin 0.3 pt)** picked `hgq_b3e-5` epoch 445: **76.74 % test
    accuracy (0.34 pt below float)**, 21,874 EBOPs after calibration
    (`selection_final_margin0.3.json`, `golden_final.json`).
  - The second margin was chosen after seeing a test-set number. That is
    disclosed here and is the only time test data influenced a choice.

## 2. Golden vectors (ref/golden/, hashes in golden_final.json)
The full 166,000-vector test set, exported once from the calibrated model
`jsc_hgq.keras` (sha256 `4f2181eb…bfd8`):
- 150-bit input lanes (the input quantizer's output);
- 80-bit output lanes (5 logits, LSB 2^-k per lane);
- `jsc_golden_in.hex` sha256 `8905d5c0…3986`;
- `jsc_golden_out.hex` sha256 `383bdcdd…8a34`.

Pre-RTL check: Keras float64 vs da4ml's DAIS interpreter on the traced graph,
**0 mismatching vectors**.

## 3. Bit-exact RTL in Verilator (verilator/)
Flow: da4ml 0.6.0 `RTLModel` → Verilog per latency cutoff → `tb/tb_jsc.sv` on
build-host (Verilator 5.020, `--binary --timing`, drive and sample at negedge,
`$fatal` on any mismatch). Lint: `--lint-only -Wall` is clean on the core,
waiving only DECLFILENAME and UNUSEDPARAM.

For each of 9 pipeline depths (cutoff 1, 2, 3, 4, 5, 6, 8, 12, 32):
1. **Impulse latency**, measured and asserted equal to stages + 1.
2. **All 166,000 vectors back to back at II = 1**, in 4 orders (natural, plus
   xorshift32 shuffles with seeds 1–3), each run twice.

Result: **72 runs, 72 × 166,000 vectors, 0 mismatches.** Every log header
carries the golden hashes. Measured latencies: 27, 14, 10, 8, 7, 6, 5, 4, 2
cycles.

Negative control (`verilator/negative_control_lc4.log`): one bit flipped in
one golden output gives exactly 1 MISMATCH at that vector and exit code 134.

Reproducibility: `ref/export_jsc.py --rtl-only` regenerated lc4 from the
frozen model byte-identical to the committed RTL.

## 4. OOC synthesis + P&R sweep (ooc/, ooc_table_all.md, ooc_results.json)
**model, OOC P&R.**
- **Setup:** Vivado 2024.2, `synth_design -mode out_of_context -flatten_hierarchy
  full`, then opt, place, phys_opt and route. The only constraint is
  `create_clock`.
- **What is timed:** every path is register to register. The da4ml core
  registers both its inputs and its outputs.
- **Excludes:** pins, IOBs and board.
- **Builds:** 69, each in its own `synth/out_<name>/`. Reports were copied only
  if not older than that build's `post_route.dcp`.
- **Latency:** cycles (Verilator impulse) × constrained period. Every build
  below has WHS ≥ +0.037 ns.

Shallowest pipeline that closes at each clock:

| Part | Clock | Cutoff | Cycles (sim) | Latency | WNS (ns) | LUT | FF | DSP |
|---|---|---|---|---|---|---|---|---|
| xczu9eg-ffvb1156-2-i | 200 MHz | 5 | 7 | **35.0 ns** | +0.118 | 16,566 | 3,068 | 0 |
| xczu9eg-ffvb1156-2-i | 300 MHz | 3 | 10 | **33.3 ns** | +0.058 | 16,709 | 6,493 | 0 |
| xczu9eg-ffvb1156-2-i | 400 MHz | 2 | 14 | **35.0 ns** | +0.014 | 16,824 | 10,204 | 0 |
| xczu9eg-ffvb1156-2-i | **500 MHz (max)** | 1 | 27 | **54.0 ns** | +0.103 | 17,289 | 20,118 | 0 |
| xcvu9p-fsgd2104-2L-e | 200 MHz | 5 | 7 | **35.0 ns** | +0.245 | 16,470 | 3,068 | 0 |
| xcvu9p-fsgd2104-2L-e | 300 MHz | 3 | 10 | **33.3 ns** | +0.092 | 16,652 | 6,493 | 0 |
| xcvu9p-fsgd2104-2L-e | 400 MHz | 2 | 14 | **35.0 ns** | +0.013 | 16,805 | 10,204 | 0 |
| xcvu9p-fsgd2104-2L-e | **526 MHz (max)** | 1 | 27 | **51.3 ns** | +0.024 | 17,294 | 20,139 | 0 |

Maximum-clock search:
- **ZU9EG:** 1.9 ns fails by 6 ps and 1.8 ns by 100 ps (−0.051 ns with
  retiming).
- **VU9P:** 1.8 ns fails by 41 ps.
- **Next-shallower depth at each clock, all failing:**
  - lc6 at 200 MHz: −0.197 (ZU9EG) / −0.137 (VU9P) ns;
  - lc4 at 300 MHz: −0.402 / −0.365 ns;
  - lc3 at 400 MHz: −0.519 / −0.574 ns.
- **Retiming** (`synth_design -retiming`, 9 builds) changed WNS by at most
  0.15 ns and closed no new point. The da4ml stages are already balanced, and
  the critical paths are about 80 % routing: for example, lc1 at 400 MHz has
  0.45 ns logic + 1.81 ns route from one high-fanout register.

Findings:
1. **Wall-clock latency is flat at 33–35 ns from 200 to 400 MHz and worse at
   the maximum clock (51–54 ns).** This reproduces, on this model, the
   published finding that faster clocks lose (hls4ml overview Table 4:
   12.1 ns at 200 MHz vs 27.8 ns at about 750 MHz, XCVU9P, OOC P&R). The
   fastest point here is **300 MHz, the ZCU102 SI570's power-up frequency**.
2. **Comparison with the published figure:** HGQ+DA JSC at 76.9 % accuracy,
   23.4 ns, 11,978 LUT, 0 DSP (XCVU9P, OOC P&R only, never measured on a
   board).
   - This model: 76.74 % test, 33.3 ns (300 MHz) / 35.0 ns (200 MHz),
     16.5–16.7k LUT, 0 DSP, on the same XCVU9P part and the same OOC class.
   - That is about 45 % more latency and 38 % more LUTs at about 0.2 pt lower
     accuracy.
   - Cycle-counting conventions may differ. Ours includes the input and the
     output register. Closing that gap (smaller-EBOP models, Vivado 2025.x
     retiming as used in the HGQ paper) is optional work, not Stage 0.
3. **The da4ml LUT estimate is close:** 16,288 estimated vs 16.1–17.9k placed,
   across all builds.
4. **Same RTL, two parts:** ZU9EG -2-i and VU9P -2L close the same depths at
   the same clocks.

## 5. Artifact A measurement method
`docs/MEASUREMENT.md`. Research behind it: `zcu102_io_report.md`, plus a
model-only IOB P&R experiment in `iob_experiment/`. That experiment puts an
HD PMOD round trip at about 3.9 ns (slow corner) vs about 1.0 ns on HP FMC
pins (**model**).
