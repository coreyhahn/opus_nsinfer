// s3_pkg: Stage 3 decoder-loop word formats and status bundles (shared by side A, side B, regs, TB).
//
// Words are DW bits (the Aurora user data width: 64 for 1 lane / d = 3, 192 for 3 lanes / d = 5), one
// AXI4-Stream beat; N_DET detection bits (24 or 120), N_DET + 1 < DW - 32.
// A -> B word (one beat on the Aurora A TX):
//   [DW-1:DW-8] TAG_AB = 8'hA5   [DW-9:DW-32] seq   [DW-33:N_DET+1] 0   [N_DET] mode_echo
//   [N_DET-1:0] det (detector j at bit j)
//   DW = 64, N_DET = 24 (Stage 3):  [63:56] tag  [55:32] seq  [31:25] 0  [24] mode_echo  [23:0] det
//   DW = 192, N_DET = 120:          [191:184] tag  [183:160] seq  [159:121] 0  [120] mode_echo  [119:0] det
// B -> A word:
//   [DW-1:DW-8] TAG_BA = 8'h5A   [DW-9:DW-32] seq   [DW-33:2] 0   [1] echo flag   [0] flip
//
// Signature (side A, s3_misr): a 32-bit MISR with the CRC-32 polynomial 0x04C11DB7, init 0xFFFFFFFF,
// one step per GOOD response (right tag, in range, not overrun, not a duplicate) in return order:
//   sig' = {sig[30:0], 1'b0} ^ (sig[31] ? 32'h04C11DB7 : 32'h0) ^ {7'b0, seq[23:0], flip}
package s3_pkg;
  localparam logic [7:0] TAG_AB = 8'hA5;
  localparam logic [7:0] TAG_BA = 8'h5A;

  function automatic logic [31:0] s3_misr(input logic [31:0] s, input logic [23:0] seq, input logic f);
    return {s[30:0], 1'b0} ^ (s[31] ? 32'h04C11DB7 : 32'h0) ^ {7'b0, seq, f};
  endfunction

  // Side A status (clk_a). Static while side A is in S_DONE (it ignores the link there).
  typedef struct packed {
    logic        timeout;        // done was reached by the TIMEOUT counter, not by NVEC responses
    logic [31:0] n_sent;         // beats accepted by the TX (tvalid & tready)
    logic [31:0] n_rx_words;     // every RX beat seen while playing or waiting
    logic [31:0] n_good;         // good responses (= latency sample count)
    logic [31:0] lat_min;        // loop latency, clk_a cycles: tsc at RX register - tsc at TX accept
    logic [31:0] lat_max;
    logic [47:0] lat_sum;
    logic [31:0] mism;           // good responses whose flip differs from the expected decision
    logic        first_mis_v;
    logic [23:0] first_mis_seq;
    logic [31:0] err_tag;        // [DW-1:DW-8] != 8'h5A
    logic [31:0] err_range;      // seq >= NVEC or seq not sent yet
    logic [31:0] err_overrun;    // timestamp slot seq[9:0] holds another seq (more than 1024 in flight)
    logic [31:0] err_dup;        // seq already returned in this run
    logic [31:0] err_echo;       // echo flag != mode_echo (counted, response still good)
    logic [31:0] hist_under;     // latency < HIST_BASE
    logic [31:0] hist_over;      // latency >= HIST_BASE + 256
    logic [31:0] sig;
  } s3_a_stat_t;

  // Side B status (clk_b). Static once the loop has drained (no traffic).
  typedef struct packed {
    logic [31:0] n_rx;           // RX beats with the right tag
    logic [31:0] n_tx;           // TX beats accepted (tvalid & tready)
    logic [31:0] err_tag;        // RX beats with [DW-1:DW-8] != 8'hA5 (dropped)
    logic [31:0] fifo_ovf;       // response words dropped: TX FIFO full
    logic [31:0] collide;        // echo word dropped: a decode word left the pipe the same cycle
    logic [4:0]  fifo_max;       // TX FIFO peak occupancy
    logic [15:0] dec_min;        // decode-alone, clk_b cycles: RX word register -> TX FIFO write
    logic [15:0] dec_max;
    logic [31:0] dec_cnt;
    logic [15:0] echo_min;       // echo path, same two events
    logic [15:0] echo_max;
    logic [31:0] echo_cnt;
  } s3_b_stat_t;
endpackage
