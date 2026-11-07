// s6_pkg: Stage 6 thin GTY link (docs/PLAN.md B.5): constants and status bundles.
//
// Framing (one 66-bit block per 64-bit lane word, the GTY's 64B/66B synchronous gearbox, UG578 v1.4 ch. 3
// "TX Synchronous Gearbox" / ch. 4 "RX Synchronous Gearbox"):
//   header 2'b01 = data block: payload = one 64-bit lane word of the user stream (s3_pkg words), scrambled;
//   header 2'b10 = control block: payload = IDLE (64'h1E00_0000_0000_0000, the 10GBASE-R idle block type),
//                  scrambled; sent whenever the user has no word ready and no check block is due;
//   header 2'b10 = check block: payload = {CHK_TYPE, n[23:0], crc[31:0]}: n data blocks were sent on this lane since the
//                  last check block (or TX reset), crc = CRC-32 of their payloads (crc32_d64 below), scrambled; sent
//                  instead of an IDLE block when n != 0, so it never takes a cycle from a data word. The RX recomputes
//                  both over the data blocks it delivers and counts good / bad checks (the first after lock is skipped).
//   2'b00 / 2'b11 = invalid (counted, drive block sync).
//   Scrambler: self-synchronous x^58 + x^39 + 1 over every block payload the GT accepts, data and idle alike,
//   payload bit 63 first (the order the gearbox serialises, UG578 p. 115).
package s6_pkg;
  localparam logic [1:0]  HDR_DATA = 2'b01;
  localparam logic [1:0]  HDR_CTRL = 2'b10;
  localparam logic [63:0] IDLE_BLK = 64'h1E00_0000_0000_0000;
  localparam logic [7:0]  TAG_PROBE = 8'hC3;
  localparam logic [7:0]  CHK_TYPE = 8'hD2;

  // CRC-32 (IEEE 802.3, reflected, polynomial 0xEDB88320) over one 64-bit word taken as 8 bytes, byte 0 = d[7:0]
  // first (so bit d[0] first). Start from 32'hFFFF_FFFF; the value sent is ~crc. Over words w0, w1, ... it equals
  // Python zlib.crc32(b''.join(w.to_bytes(8, 'little') for w in words)).
  function automatic logic [31:0] crc32_d64(input logic [31:0] c, input logic [63:0] d);
    logic [31:0] r;
    r = c;
    for (int i = 0; i < 64; i++) r = (r >> 1) ^ ((r[0] ^ d[i]) ? 32'hEDB8_8320 : 32'h0);
    return r;
  endfunction

  // x^58 + x^39 + 1, payload bit 63 first: st holds the last 58 scrambled bits, st[0] the newest
  function automatic logic [121:0] scramble(input logic [63:0] d, input logic [57:0] st);
    logic [57:0] p;
    logic [63:0] o;
    logic        x;
    p = st;
    for (int i = 63; i >= 0; i--) begin
      x    = d[i] ^ p[38] ^ p[57];
      p    = {p[56:0], x};
      o[i] = x;
    end
    return {p, o};   // {next state, scrambled payload}
  endfunction

  function automatic logic [121:0] descramble(input logic [63:0] s, input logic [57:0] st);
    logic [57:0] p;
    logic [63:0] o;
    p = st;
    for (int i = 63; i >= 0; i--) begin
      o[i] = s[i] ^ p[38] ^ p[57];
      p    = {p[56:0], s[i]};
    end
    return {p, o};   // {next state, descrambled payload}
  endfunction

  // link status (clk), counters zeroed by clr; aggregated over the lanes of one link end
  typedef struct packed {
    logic [2:0]  lock;        // per-lane block lock (bit i = lane i), live
    logic [31:0] n_lock;      // lock acquisitions (0 -> 1 on any lane)
    logic [31:0] n_unlock;    // lock losses (1 -> 0 on any lane)
    logic [31:0] n_slip;      // RXGEARBOXSLIP pulses
    logic [31:0] n_sh_bad;    // invalid sync headers seen while locked
    logic [31:0] n_idle_bad;  // control blocks whose descrambled payload is not IDLE_BLK, while locked
    logic [31:0] n_data;      // data blocks delivered (all lanes of a word = 1)
    logic [31:0] n_dsk_ovf;   // deskew FIFO overflows (NL > 1)
    logic [31:0] n_hv_dv;     // cycles where RXHEADERVALID != RXDATAVALID on some lane (diagnostic)
    logic [31:0] n_chk_ok;    // check blocks whose count and CRC match the data blocks received (summed over lanes)
    logic [31:0] n_chk_bad;   // check blocks that do not match (summed over lanes)
  } s6_link_stat_t;

  typedef struct packed {
    logic [31:0] n_tx;        // probe words accepted by the link TX
    logic [31:0] n_rx;        // probe words received (tag C3)
    logic [31:0] n_bad;       // received words with another tag, or a sequence gap
    logic [31:0] lat_min;     // clk cycles, TX accept edge -> RX register edge (one way)
    logic [31:0] lat_max;
    logic [47:0] lat_sum;
  } s6_probe_stat_t;
endpackage
