# ZCU102 (zcu102) user I/O and IOB timing for pin-to-pin latency (research notes)

Date: 2026-10-19. Sources:
- **UG1182 v1.7** (ZCU102 Evaluation Board User Guide, 21 Feb 2023), from a mirror
  (https://www.ic-xilinx.com/files/11/ek-u1-zcu102-g-ed.pdf). AMD's own URLs redirected,
  and the xilinx-fpga MCP has no UG1182 or DS925 entry (search returned nothing).
- **Vivado 2024.2 board file** `data/xhub/boards/XilinxBoardStore/boards/Xilinx/zcu102/3.4/part0_pins.xml`
  (the board file targets `-2-e`).
- **Vivado 2024.2 device database**: `link_design -part xczu9eg-ffvb1156-2-i`, then `get_iobanks`
  and `PIN_FUNC` for every LOC below (localhost; no license needed).
- **DS925 v1.11** (Apr 2018, *Preliminary*), from a mirror (https://www.farnell.com/datasheets/2621630.pdf).
  The current revision is v1.29/v1.30 on docs.amd.com. I did not compare the numbers against it
  (UNVERIFIED).
- **A small Vivado P&R experiment** (build-host, 2024.2, `-2-i`) in `evidence/stage0/iob_experiment/`.

No ZCU102 master XDC was found on the NFS install. The board file has no PMOD or prototype-header
pins, so those come from UG1182 only.

## 1. User-accessible I/O

### Bank map (UG1182 Table 3-2, p.24; bank types from Vivado `BANK_TYPE`)
| Bank | Type | VCCO | Connected to |
|---|---|---|---|
| 44 | HD | 3.3 V | DIP switches, push buttons, LEDs, 74.25 MHz clock |
| 47 | HD | 3.3 V | **PMOD0 J55, PMOD1 J87**, PL I2C1, TRACEDATA, **125 MHz clock** |
| 48 | HD | 3.3 V | TRACEDATA |
| 49 | HD | 3.3 V | HDMI codec, SYSMON I2C, SFP control, UART2, MSP430 |
| 50 | HD | 3.3 V | HDMI, MSP430 GPIO, PL I2C0, **prototype header J3** |
| 64 | HP | 1.2 V | DDR4 (PL), **USER_SI570** |
| 65 | HP | VADJ_FMC (1.8 V) | FMC_HPC1 LA bus, HDMI TX |
| 66 | HP | VADJ_FMC (1.8 V) | FMC_HPC0 LA bus, HDMI recovered clock |
| 67 | HP | VADJ_FMC (1.8 V) | FMC_HPC0 LA bus, SFP recovered clock |

VADJ_FMC ships at 1.8 V, set by the MSP430. The valid settings are 1.2/1.5/1.8 V
(UG1182 p.96 and p.114).

### PMOD headers: UG1182 "User PMOD GPIO Headers", Table 3-31, pp.74-75
J55 is a right-angle female header and J87 is a vertical male header. All 16 nets go to **bank 47 (HD, 3.3 V)**
with LVCMOS33. Vivado confirms every pin is in bank 47 (BT_HIGH_DENSITY).

| Net | LOC | Header pin | Vivado PIN_FUNC |
|---|---|---|---|
| PMOD0_0 | A20 | J55.1 | IO_L12N_AD0N_47 |
| PMOD0_1 | B20 | J55.3 | IO_L12P_AD0P_47 |
| PMOD0_2 | A22 | J55.5 | IO_L11N_AD1N_47 |
| PMOD0_3 | A21 | J55.7 | IO_L11P_AD1P_47 |
| PMOD0_4 | B21 | J55.2 | IO_L10N_AD2N_47 |
| PMOD0_5 | C21 | J55.4 | IO_L10P_AD2P_47 |
| PMOD0_6 | C22 | J55.6 | IO_L9N_AD3N_47 |
| PMOD0_7 | D21 | J55.8 | IO_L9P_AD3P_47 |
| PMOD1_0 | D20 | J87.1 | IO_L8N_HDGC_AD4N_47 |
| PMOD1_1 | E20 | J87.3 | IO_L8P_HDGC_AD4P_47 |
| PMOD1_2 | D22 | J87.5 | IO_L7N_HDGC_AD5N_47 |
| PMOD1_3 | E22 | J87.7 | IO_L7P_HDGC_AD5P_47 |
| PMOD1_4 | F20 | J87.2 | IO_L6N_HDGC_AD6N_47 |
| PMOD1_5 | G20 | J87.4 | IO_L6P_HDGC_AD6P_47 |
| PMOD1_6 | J20 | J87.6 | IO_L4N_AD8N_47 |
| PMOD1_7 | J19 | J87.8 (the table prints "J77.8", an obvious typo) | IO_L4P_AD8P_47 |

- The header pin numbers are UG1182's schematic numbers (1,3,5,7 / 2,4,6,8), not Digilent's
  1-4/7-10 numbering. Before fitting a jumper, find the physical pin positions and the
  VCC3V3/GND pins from the silkscreen or schematic (UNVERIFIED). A jumper to VCC or GND on a driven
  output would short it.
- **Level shifters and series resistors on the PMOD nets**: the UG1182 text mentions neither.
  Other nets do get them, and UG1182 says so: UART via TXS0104E U52/U53 (p.~55), PMU GPO/MSP430 via
  TXS0108E U141, CAN via TXS0104E U33, SD via IP4856 U133. Bank 47 is already at 3.3 V, so no
  translator is needed. That the PMOD nets connect directly is **UNVERIFIED**: check the ZCU102
  schematic (not available here). If any translator or resistor sits in the path, it adds delay
  that a loopback calibration will include.

### Prototype header J3 (UG1182 Table 3-32, p.76): bank 50, HD, LVCMOS33
J3 is a 2x12 male header with 10 GPIOs.

| LOC | J3 pin |
|---|---|
| J15 | 14 |
| J16 | 16 |
| G16 | 18 |
| H16 | 20 |
| H14 | 6 |
| J14 | 8 |
| G14 | 10 |
| G15 | 12 |
| G13 | 22 |
| H13 | 24 |

Vivado reports, for example, G13 = IO_L8N_HDGC_50 and H13 = IO_L8P_HDGC_50. UG1182's net-name
suffixes for these pins are swapped/odd.

### User I/O (UG1182 "User I/O", Table 3-33, pp.77-79): bank 44, HD, LVCMOS33
The board file agrees with these LOCs.
- **LEDs**, active high: LED0..7 = AG14, AF13, AE13, AJ14, AJ15, AH13, AH14, AL12.
  The board file calls them `GPIO_LED_n_LS`. Whether the LEDs have a buffer or driver is shown only
  in UG1182 Figure 3-32 (an image), so it is UNVERIFIED. The LEDs are not useful for timing.
- **Push buttons**, active high: N=AG15, E=AE14, W=AF15, S=AE15, C=AG13. CPU_RESET (SW20) = AM13.
- **DIP switch SW13**: SW0..7 = AN14, AP14, AM14, AN13, AN12, AP12, AL13, AK13.

### SMA connectors: none are GPIO
UG1182 Table 3-13 (pp.44-45) and the GTH tables (pp.85-86) list only transceiver SMAs:
- **SMA_MGT_TX** P/N on J71/J72 = M29/M30 (MGTHTXP3/N3_128).
- **SMA_MGT_RX** P/N on J69/J70 = M33/M34 (MGTHRXP3/N3_128).
- **USER_SMA_MGT_CLOCK** P/N on J79/J80. It is an AC-coupled MGT reference clock input, bank 129
  MGTREFCLK1.
  - **The LOC is inconsistent inside UG1182.** Table 3-13 gives N27/N28. The text on p.49 and the
    GTH table on p.86 give **J27/J28** (MGTREFCLK1P_129). N27/N28 is the HDMI_RX_CLK refclk on
    bank 128. Use J27/J28 and confirm in Vivado.

There is no user "USER_SMA_CLOCK"/GPIO SMA on the ZCU102.

### Clocks into the PL (UG1182 Table 3-12, p.44; Table 3-13, pp.44-45; "Programmable User Clock", p.47)
| Clock | LOC P/N | Bank | IOSTANDARD | Notes |
|---|---|---|---|---|
| USER_SI570 (U42) | **AL8 / AL7** | 64 HP 1.2 V, GC pins | DIFF_SSTL12 | Si570BAB001614DG, **300.000 MHz at power-up**. Programmable 10-810 MHz over I2C (I2C mux channel 2, address 0x5D) or from the MSP430. Returns to 300 MHz on power cycle. 61.5 ppm. |
| CLK_125 (U69 SI5341B) | G21 / F21 | 47 HD | LVDS_25 | Same bank as the PMODs. The board file calls it `sysclk_p/n`. |
| CLK_74_25 | AK15 / AK14 | 44 HD | LVDS_25 | |
| USER_MGT_SI570 (156.25 MHz) | via buffer U51 to L27/L28 and C8/C7 | GTH refclk | n/a | |

- **Correction to `CLAUDE.md`**: the board does not have a "200 MHz SI570". The SI570 runs at
  **300 MHz** by default. The lab's 200 MHz came from an MMCM (300 to 200 MHz) in zu9_axi_test.
  Either reprogram the Si570 over I2C or derive the clock with an MMCM.
- The board file description says "SI570 based ... 300 MHz" but lists part_name SI5341B, which is
  wrong.
- DS925 (DC section) restricts LVDS_25 in HD banks to inputs with VCCO 2.375-2.625 V. Banks 44 and 47
  are 3.3 V, yet UG1182 and the board file both use LVDS_25 there. Whether Vivado DRCs allow this at
  3.3 V (input, no DIFF_TERM) is UNVERIFIED: I did not test it. The latency design does not need these
  clocks.

### FMC HPC0 (J5) and HPC1 (J4)
- Both connect to HP banks 65-67 at VADJ = 1.8 V, using LVCMOS18 in the board file. For example,
  HPC1 LA02_P/N = AD2/AD1 (bank 65), HPC0 LA00_CC_P = Y4 (bank 66), HPC1 LA00_CC_P = AE5 (bank 65).
- Full tables: UG1182 Tables 3-44 to 3-48 (p.96 onward) and `part0_pins.xml`.
- They are only usable with an FMC loopback or breakout card. Whether the lab has one is UNKNOWN
  (ask the user).

## 2. Loopback options for an on-chip timestamp counter

- **Best option: PMOD on bank 47.** The design drives an output PMOD pin and a jumper carries it to an
  input PMOD pin. All 16 PMOD pins share bank 47 and the bank's HDGC clock pins, and the 125 MHz
  clock is in the same bank. The jumper can stay inside J55, stay inside J87, or go J55 to J87
  (J55 is a female socket, J87 has male pins).
- **Same idea on J3 (bank 50, 10 pins, male header).** A female-female jumper loops two pins.
- **HP path (much faster IOBs, see section 4).** This needs an FMC loopback card on HPC0/HPC1.
- **GT path.** An SMA cable from J71/J72 TX to J69/J70 RX loops a GTH lane. This measures SerDes
  latency, not GPIO latency.
- **What the measurement contains.** The counter registers a launch time at the output FF and a
  capture time at the input FF. Round trip =
  T_clk-to-out(OPFF + OBUF) + board trace + jumper + T_pad-to-IPFF(INBUF), quantised to one clock
  period. Two ways to remove the quantisation:
  - sweep the phase of the capture clock with MMCM dynamic phase shift;
  - capture with ISERDES or oversampling. HD banks have no ISERDES; HD RX DDR is limited to
    250 Mb/s (DS925 v1.11, ~p.50 LVDS table).
- **How to use the loopback.** The measured loopback (output IOB + board + input IOB) is the
  calibration term for a "pin-in to pin-out" claim. The network's own latency is an exact cycle count
  from the input FF to the output FF.
- **Jumper delay is small.** Roughly 5 ns/m, so a 10 cm Dupont wire adds about 0.5 ns (derived).
  The FPGA-to-header trace length is not in UG1182 (UNVERIFIED).

## 3. Lab notes: claude_project/zu9_axi_test and zu9_petalinux

### Clocking
From `zu9_axi_test/docs/plans/2026-03-02-zu9-walker-x1-design.md` and `constraints/zu9_walker.xdc`:
- The core clock is the SI570 at 300 MHz on AL8/AL7 (DIFF_SSTL12) through clk_wiz_0 (MMCM), giving
  **200 MHz**.
- The AXI clock is PS **pl_clk0 at 100 MHz** (`PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ {100}` in
  `scripts/create_project.tcl`).
- CDC between the two clocks uses async FIFOs. This is two clock domains. The opus_nsinfer rule is a
  single domain unless PLAN.md justifies otherwise, so the AXI-Lite CSR side needs a decision.
- The `create_clock` on the SI570 is left to the clk_wiz XDC. Adding it again raised
  CRITICAL WARNING 18-1055.
- In `zu9_petalinux/constraints/zcu102_blink.xdc`, the bare blink design declares
  `create_clock -period 3.333` itself.

### Pins and XDC used
Only the SI570 pair, LED0 (AG14, LVCMOS33) used as the MMCM-locked indicator, and LED0-3 in blink.
The XDCs also set:
- `BITSTREAM.GENERAL.COMPRESS TRUE`;
- `BITSTREAM.CONFIG.UNUSEDPIN PULLUP`;
- `BITSTREAM.GENERAL.PERDEVICEOVERRIDE TRUE` (blink only).

No PMOD or J3 pins have ever been used in the lab.

### PS block design
From `create_project.tcl`:
- HPM0_FPD is enabled and HPM1 is disabled.
- The slave is at **0xA000_0000, 4 KB range** (`set_property offset 0xA0000000 ... range 4K`).
- A SmartConnect/interconnect runs at pl_clk0.
- `create_gpio_test.tcl` puts an AXI GPIO at the same address.

### Loading the PL through the PS
From `scripts/deploy_and_load.sh`, `scripts/bit2bin.sh` and `driver/load_fpga.sh`:
1. `bootgen -image x.bif -arch zynqmp -o x.bin -w`, with the BIF set to
   `all: { [destination_device = pl] x.bit }`.
2. `scp x.bin root@zcu102:/lib/firmware/`.
3. On zcu102:
   - `echo 0 > /sys/class/fpga_manager/fpga0/flags` (0 = full bitstream);
   - `echo x.bin > /sys/class/fpga_manager/fpga0/firmware`;
   - check that `cat .../state` reads `operating`.
4. The script falls back to `fpgautil -b x.bin` if the sysfs node is missing.
5. Bitstreams loaded this way: `bitstreams/axi_test_20260304_*.bin` and `gpio_test.bin`
   (`deploy_test.sh` scratch-register test, "ALL TESTS PASSED").

### /dev/mem access pattern
- `zu9_petalinux/scripts/devmem.c` (static aarch64 build with `aarch64-linux-gnu-gcc -static`):
  - `open("/dev/mem", O_RDWR|O_SYNC)`;
  - `mmap(NULL, 0x1000, PROT_READ|PROT_WRITE, MAP_SHARED, fd, addr & ~0xFFF)`;
  - volatile 8/16/32-bit read and write.
- `walker_driver.py` uses Python `mmap` on /dev/mem at 0xA0000000 with `struct '<I'`.
- **python3 on zcu102 is uncertain.** `deploy_and_load.sh` prints "zcu102 has no python3", while
  `deploy_test.sh` and `CLAUDE.md` run `python3` on zcu102. This is UNVERIFIED and may depend on the
  current image. The static C devmem works either way.

### ES2 caveats
From `zu9_petalinux/CLAUDE.md`, `zu9_axi_test/scripts/program_fpga.tcl` and
`zu9_petalinux/scripts/patch_bitstream_idcode.py`:
- The silicon is ES2. The JTAG IDCODE is 0x14738093 (version field 1); production is 0x04738093.
- Vivado has no ES2 part, so builds target the production `xczu9eg-ffvb1156-2-i`.
- JTAG programming must use `xsdb`: `fpga -f x.bit -no-revision-check`. Vivado hw_manager has no
  bypass.
- A tool exists to patch the configuration IDCODE inside a .bit from 0x0484A093 to 0x1484A093.
  None of the scripts I saw call it, and the FPGA-manager path worked without it.
- The earlier "SDHCI POWER_ON bug" turned out to be false.
- **Timing caveat (UNVERIFIED).** The timing model is the production -2-i speed file; ES2 silicon may
  differ. A latency in ns that rests on Vivado's IOB numbers should therefore be checked by loopback
  on the board.

### Boot chain
- SD BOOT.BIN (FSBL, PMUFW, ATF, U-Boot 2025.01), then a TFTP `image.ub` from lab-host-3
  (/srv/tftp), then Linux 6.12. NFS is mounted at `/file-server`.
- `CLAUDE.md` records Vivado 2025.2 at `<xilinx-tools>/2025.2/Vivado`.

## 4. IOB timing facts (HD vs HP)

### DS925 v1.11 tables
TINBUF_DELAY_PAD_I is pad to IBUF I-pin. TOUTBUF_DELAY_O_PAD is OBUF O-pin to pad. Values are for
**-2 at VCCINT 0.85 V**:

| Standard | Bank type | In (ns) | Out (ns) | Source |
|---|---|---|---|---|
| LVCMOS33_F_12 | HD | 1.154 | 2.415 | Table 75, pp.51-53 |
| LVCMOS33_F_16 | HD | 1.154 | 2.383 | Table 75 |
| LVCMOS33_S_12 | HD | 1.154 | 2.705 | Table 75 |
| LVCMOS18_F_12 | HD | 0.915 | 1.805 | Table 75 |
| LVCMOS18_F_12 | HP | 0.418 | 0.573 | Table 76, pp.53-59 |
| LVCMOS18_F_8 | HP | 0.418 | 0.573 | Table 76 |
| DIFF_SSTL12_F | HP | 0.394 | 0.412 | Table 76 |

- **HD output buffers are about 4x slower than HP** (about 2.4 ns vs 0.57 ns).
- **HD input buffers are about 2.5x slower** (1.15 ns vs 0.42 ns).
- The datasheet values are per-standard adders. Vivado's timing engine uses them, and they are the
  only datasheet source for buffer delays.
- Caveat: v1.11 is marked *Preliminary*. Check against v1.30 before citing in final docs.

### Vivado experiment
Files are in `evidence/stage0/iob_experiment/`: `top.v`, `top.xdc`, `impl.tcl`, `t_*.rpt`, `datasheet.rpt`, all
dated 2026-10-19 22:35.

**Setup** (labels: **model**/**sim**, not silicon):
- Part `xczu9eg-ffvb1156-2-i`, Vivado 2024.2 on build-host.
- 300 MHz clock: SI570 pins through IBUFDS and BUFG.
- Each path is in → FF(IOB=TRUE) → FF → out.
- HD path: PMOD B20 in, A20 out, LVCMOS33, DRIVE 12, SLEW FAST.
- HP path: FMC AD1 in, AD2 out, LVCMOS18, DRIVE 12, SLEW FAST.

**Packing:**
- HD registers packed into **HDIOLOGIC IPFF/OPFF**.
- HP registers packed into **BITSLICE_RX_TX IN_FF/OUT_FF**.
- Synth 8-4163 replicated the first FF to honour IOB=TRUE.
- Packing should be confirmed in every build. Check `report_datasheet` "IO Reg Type = FDRE (IO)",
  or the cell LOC.

**Results:**

| Quantity | HD PMOD, LVCMOS33 | HP FMC, LVCMOS18 |
|---|---|---|
| INBUF pad to I, slow / fast corner | 1.316 / 0.892 ns | 0.349 / 0.279 ns |
| OBUF I to pad, slow / fast corner | 2.582 / 1.305 ns | 0.684 / 0.349 ns |
| IOB FF clk-to-Q (slow) | 0.359 ns (OPFF) | 0.494 ns (OUT_FF) |
| `report_datasheet` clock-to-out, max / min | 5.935 / 3.108 ns | 4.489 / 2.305 ns |
| `report_datasheet` input setup / hold | 1.966 / -0.623 ns | -0.988 / 2.640 ns |

- The clock-to-out figures are measured from the clock pin and include about 3 ns of clock insertion
  (IBUFDS, BUFG and route).
- **HD output path, max:** clk-to-out from the FF = 0.359 + 2.582 = **about 2.9 ns**
  ("Data Path Delay 2.944 ns").
- **HP output path, max:** about **1.43 ns**.
- **HD round trip** (OBUF + INBUF, excluding FFs, jumper and clock skew): about **3.9 ns slow /
  2.2 ns fast** (**derived**). At 300 MHz that is 1-2 cycles.
- **HP round trip:** about 1.0 / 0.63 ns.

### Useful commands
- `report_datasheet`: per-port setup/hold and clock-to-out with process corner.
- `report_timing -from [get_ports X]` and `report_timing -to [get_ports Y]`: these break out the
  INBUF/OBUF cells.
- `report_io`.
- `set_property IOB TRUE [get_cells ...]`, or the RTL attribute `(* IOB="TRUE" *)`.
- In the timing reports, `Prop_OUTBUF_HDIOB_*` and `Prop_INBUF_HDIOB_*` name the HD buffers.

### Recommendation implied by the numbers
- An HP bank would cut about 2.9 ns from each pin-to-pin crossing. The only user-reachable HP pins
  are on the FMC, and the PMODs are HD.
- With PMODs, report the HD IOB cost separately, calibrated by the PMOD loopback.

## Not verified
- PMOD path components (series resistors, ESD parts, translators) and the physical pin positions on
  J55/J87: needs the schematic or a look at the board.
- DS925 numbers in the current revision (v1.30).
- The LVDS_25 DRC in the 3.3 V HD banks.
- Whether python3 exists on zcu102.
- Whether the lab has an FMC loopback card.
- **License note:** a localhost Vivado 2024.2 synth for xczu9eg **failed with no license**. build-host
  holds a Synthesis license for xczu9eg that **expires in 19 days**, so ZCU102 builds must run on
  build-host.
