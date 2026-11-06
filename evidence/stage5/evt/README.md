# Stage 5: nsclf event revision (VERSION 2.0) on the X310 (2026-11-03)

Purpose: D-S5-EVK (dense pulses at K = 16 swamped the host with ~1e6 one-record event packets/s) and the session-init
failures seen in the v2 campaign (`../v2/README.md` §4: a new UHD session right after a capture often failed with a
Radio#0 control-ACK timeout). Classifier unchanged (the v2 model, cutoff 2, L = 22 cycles). Labels: **silicon**, **sim**.

## 1. What changed (register map: `../block/README.md` §5a)

* Events are **off at reset**: REG_CTRL bit 2 EVT_EN (reset 0). UHD resets the block at every session init; before,
  K = 16 at reset sent ~2-5e4 event packets per session to an endpoint nobody had connected. The host tools write
  EVT_EN = 1 only after K is set and the receiver runs, and 0 after the capture.
* **Batching**: up to EVT_BATCH = 16 records (unchanged 3-word format) per CHDR packet, timestamp = the first record's
  tau, tlength 24 x n; a packet leaves when full or when its oldest record has waited EVT_FLUSH cycles (reset 4096 =
  20.5 us; 0 = one record per packet). EVT_AW 6 (64 records). New registers EVT_FLUSH, EVT_CFG, EVT_PKTS; VERSION
  0x00020000.
* Host: `sw/x310/nsclf_host.py` / `nsclf_txrx.py` / `nsclf_replay.py` parse packed packets; `drain_events()` waits
  after EVT_EN = 0 until every generated record (EVT_SEQ - EVT_DROP) has been read (section 3).

## 2. Simulation (`block/`, `verilator/`, `replay/`; sim)

nsclf 5 configs x 2 runs (events on from start / FLUSH 0 with random ready / K 1 with 20,000-cycle stalls and EVT_EN
off-on-off-on / K 64 FLUSH 64 with radio time crossing 2^63 / K 2 FLUSH 1000 with EVT_EN switched on at 40 %): 0
decision, tau, latency, pass-through, register, AXIS, framer and event mismatches; the packet start rule is checked
cycle by cycle. 4 negative controls fail (decision, MISR, event field, a corrupted record inside a 16-record packet).
UHD 4.9 xsim of the whole block: PASSED (338 records in 22 packets = model). Classifier gate unchanged (full set and
stream, 0 mismatches). Replay self-test PASS, its negatives fail.

## 3. Image and silicon (`build/`, `silicon/`)

* Image `x310_xg_nsclf_evt_lc2_1` (UHD 4.9 flow, Vivado 2024.2, ML Enterprise licence): closes in the UHD flow itself,
  **WNS +0.003 / WHS +0.003 / WPWS +0.001 ns** ("All user specified timing constraints are met"; worst setup
  radio_clk), no hold fix needed. Bitstream `.scratch/s5_build/x310_xg_nsclf_evt_lc2_1/build-usrp_x310_fpga_XG_nsclf/
  x300.bit`, md5 c23a55d99699a90cca2b4ae40921d331. nsclf0 25,094 LUT (v2 24,809). Same critical warnings as the v2
  build. JTAG-loaded only (volatile); read back VERSION 0x00020000, EVT_EN 0, events 0 at session start (v2 image:
  2-3e4 per session start).
* **Session init (A)**: 8 dense captures, each followed at once by an `info` session, no retry, no pause: **0 of 16
  sessions failed** (`silicon/sigL_s8..15.log`, `info_after_s*.log`). With the v2 image the same sequence failed
  most of the time (`../v2/silicon/failed_init/`). This supports the event-flood explanation; not proven.
* **Sparse events (B)**, K = 16, gaps 50-200 us: evt_s102 (no lead-in) 1,475 in-window records in 297 packets, evt_s103
  (lead-in) 637 in 172: every one equals the replay, 0 drops, no sequence gaps.
* **Dense pulses with events on (C)**, K = 16 (the D-S5-EVK case, impossible with v1): sigLev_s8 / s9 complete with no
  RX overflow or errors; 22,062 / 21,916 records (~1e6 records/s during the burst, ~6e4 packets/s), all received, 0
  drops; the in-window 20,079 / 20,488 equal the replay with 0 errors; decisions bit-exact (MISR). The first try
  (`*_nodrain.log`) lost the tail: the Python receiver lags at this rate and was stopped as the capture ended; fixed in
  the host by draining (0.6-0.7 s) before stopping.
* The host's "ts != word0" count (recv calls whose UHD metadata time differs from their first record's tau) is a
  host-side check of UHD's timestamp conversion, as in v1 (`nsclf_host.ts_matches`); the records themselves carry tau
  and all equal the replay.

Script: `sw/x310/s5evt_check.sh` (SEEDS / EVT / EVDENSE select the parts). Captures `.scratch/s5_cap_evt/`, hashes
`silicon/captures.sha256`; replays `sw/x310/nsclf_replay.py --work .scratch/nsclf_replay_evt/<stem> replay
.scratch/s5_cap_evt/<stem> --dump`.
