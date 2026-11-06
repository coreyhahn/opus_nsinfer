# Stage 4 silicon run (sw/bcu/desk.sh run sw/bcu/s4_measure.cmd): s3_measure.cmd for the d = 5 build
# (3 bonded GTY lanes, DW = 192, 131,072 golden shots). Register map rtl/s3/s3_regmap.md.
# Order (docs/PLAN.md D-S3-MEAS): link status (all three lane_up bits per side) and clock counts ->
# echo mode (link alone) -> decode mode (loop) at GAP 63 and 7 -> flag RAM sample (first and last 4096).
echo board
r 0x000 ID
r 0x0F0 NVEC
r 0x0F4 DEC_LAT
r 0x100 DW
r 0x024 LINK
r 0x028 FREQ_A
r 0x02C FREQ_B
wait 0x024 0x7E000101 0x7E000101 30
r 0x024 LINK
w 0x004 0x30
w 0x004 0x00
w 0x00C 0
# ---- echo, GAP 63 ----
echo run echo_gap63
w 0x008 63
w 0x004 0x02
w 0x004 0x03
wait 0x010 0x1 0x1 120
@stats
hist 256
w 0x004 0x00
wait 0x010 0x1 0x0 10
# ---- decode, GAP 63 ----
echo run decode_gap63
w 0x008 63
w 0x004 0x01
wait 0x010 0x1 0x1 120
@stats
hist 256
w 0x004 0x00
wait 0x010 0x1 0x0 10
# ---- decode, GAP 7 ----
echo run decode_gap7
w 0x008 7
w 0x004 0x01
wait 0x010 0x1 0x1 120
@stats
hist 256
flips 0 4096
flips 126976 4096
w 0x004 0x00
wait 0x010 0x1 0x0 10
r 0x024 LINK
r 0x028 FREQ_A
r 0x02C FREQ_B
