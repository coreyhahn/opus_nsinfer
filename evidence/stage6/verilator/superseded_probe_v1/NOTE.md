# Superseded loop logs (probe v1)

These four tb_s6_loop logs (d = 3, lc8, all 464,428 golden shots; TX_REG/RX_REG 0/0 and 1/1; two GT-model settings
each) all PASS. They were the gate for build `s6_lc8_a` (the first Stage 6 bitstream, silicon runs
`../../silicon/s6_lc8_a_*`). Silicon run 3 then showed that `s6_probe` counted one word as sent when probe_en fell in
the cycle of an accept (the link had already switched back to side A): sent = received + 1 in both directions.
`rtl/s6/s6_probe.sv` now counts only while en; the loop logic is unchanged. The current logs in `..` are from the
fixed RTL (build `s6_lc8_b`); these are kept as the record of build a's gate.
