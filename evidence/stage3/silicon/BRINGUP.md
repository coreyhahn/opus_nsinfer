# Stage 3 silicon bring-up log (desk BCU-1525, JTAG serial DESK-BCU-JTAG)

## 2026-10-23: first load, lc8 build s3_lc8_d
- **JTAG:** build-host's hw_server lists the desk card FIRST (`DESK-BCU-JTAGA`), before the PCIe card (`PCIE-BCU-JTAG`). A bare `open_hw_target` (fable5_llm `program.tcl`) would therefore open the desk card.
- **Load:** probe and volatile load under `.opus_nsinfer_desk_bcu.lock` (`program_lc8_d_2.log`). bit sha256 `0ef35a6e…`; ID `0x53330001`, NVEC 464428, DEC_LAT 6.
- **After the power-on sequence:** LINK = `0x010d3030`. Both cores have GT power-good and PLL lock, but lane_up = 0 and channel_up = 0.
  - QSFP0 ModPrsL = 1 (no module detected); QSFP1 ModPrsL = 0 (module present).
- **Clocks (silicon, s3_freq, 2^24-cycle window of init_clk = 300 MHz / 3):**
  - FREQ_A = 27,033,600, which is 161.1328125 MHz exactly against the init clock;
  - FREQ_B = 27,033,605 … 27,033,606: B is +0.19 … +0.22 ppm relative to A.
- **Near-end PMA loopback on both GTYs (`bringup_pma_loopback_1.log`):** LINK = `0x010d3333`, both lanes and channels up. With loopback cleared they drop again.
  - So the cores, refclks, PLLs and resets work, and the missing link is on the cable / module side.
- **Measurement in PMA loopback (`s3_lc8_d_pmaloop_run1.log`):**
  - In near-end loopback each core hears its own TX, so side A received all 464,428 of its own A->B words (n_rx_words = NVEC, err_tag = NVEC) and side B received nothing.
  - This mode cannot close the A->B->A loop. It does show A's TX -> GTY -> A's RX path carrying every word.

## 2026-10-23: cable reseated (both DAC ends in the desk card's QSFP0 and QSFP1)
- **Link (`bringup_cable_relink_1.log`):** LINK = `0x010c3333`. Both modules are present, and lane and channel are up on both cores. The link came up by itself (hot-plug) before the pma_init pulse.
- **Runs:** `s3_lc8_d_cable_run{1,2,3}` (run 3 after a reprogram, `program_lc8_d_3.log`), `s3_lc12_d_cable_run1` and `s3_lc5_d_cable_run1`. All PASS; see ../README.md.
- **Board state left:** the lc5 build is loaded on the desk card (volatile).
