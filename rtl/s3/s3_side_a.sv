// s3_side_a: Stage 3 syndrome player and checker (clk = Aurora A user_clk, synchronous reset).
//
// Shot memory: NVEC x (N_DET + 1) bits {exp_flip, det[N_DET-1:0]} from INIT_FILE ($readmemh, tb/s3_make_mem.py), a
// block-RAM ROM with two registered read ports (player; checker looks up exp_flip by returned seq).
//
// Run: `run` (level, synchronised outside) high in S_IDLE starts a run:
//   S_CLEAR  max(NVEC, 256) cycles: clears the per-seq flag RAM and the histogram, zeroes the stats.
//   S_PLAY   shots are read ahead in order (registered address, two output registers) into a
//            4-entry FIFO; shot p goes out as {A5, p[23:0], 0, mode_echo, det} (s3_pkg); a new beat is
//            loaded every GAP+1 cycles (GAP counted from the load) and held while tx_tready is low. The send timestamp
//            (tsc in the cycle of the accepting edge, tvalid & tready) goes to ts RAM[seq[9:0]] together
//            with seq[23:10], so a response for a slot that was reused is caught (err_overrun).
//   S_WAIT   all NVEC accepted; ends when NVEC good responses are in, or after TIMEOUT cycles (timeout).
//   S_DONE   `done` = 1; RX is ignored so every status field is static. run low -> S_IDLE.
//
// RX pipeline (one beat per cycle, no back-pressure):
//   R0  rx beat registered, stamped with tsc; reads issued (ts RAM, shot ROM port B, flag RAM)
//   R1  RAM data back: classify tag -> range -> overrun -> duplicate -> good; good writes the flag RAM
//       {seen, flip}, steps the MISR, counts mismatches (expected = mode_echo ? 0 : exp_flip)
//   R2  latency stats (min/max/sum) and the histogram (LUTRAM read-modify-write, async read, so the
//       same bin on consecutive cycles needs no forwarding)
//   Loop latency = tsc(R0 register) - tsc(TX accept): edges from the TX accept edge to the RX
//   register edge, clk_a cycles.
//
// Register read port (for s3_regs; use only when not busy): rd_req pulse with rd_sel/rd_addr ->
//   rd_data valid with the rd_ack pulse three edges later. rd_sel = 0: histogram bin rd_addr[7:0];
//   rd_sel = 1: flag RAM entry rd_addr = {30'b0, seen, flip}.
module s3_side_a
  import s3_pkg::*;
#(
    parameter int NVEC      = 464428,
    parameter     INIT_FILE = "s3_shots.hex",
    parameter int TIMEOUT   = 100000,
    parameter int N_DET     = 24,   // detection bits per shot (24: d = 3, 120: d = 5)
    parameter int DW        = 64,   // Aurora user data width (64: 1 lane, 192: 3 lanes)
    parameter int AW        = (NVEC > 1) ? $clog2(NVEC) : 1
) (
    input  logic        clk,
    input  logic        rst,
    input  logic        run,
    input  logic        mode_echo,
    input  logic [15:0] gap,
    input  logic [15:0] hist_base,
    // Aurora A TX (AXI4-Stream, DW bit)
    output logic [DW-1:0] tx_tdata,
    output logic        tx_tvalid,
    input  logic        tx_tready,
    // Aurora A RX (AXI4-Stream, no tready)
    input  logic [DW-1:0] rx_tdata,
    input  logic        rx_tvalid,
    // register read port
    input  logic        rd_req,
    input  logic        rd_sel,
    input  logic [23:0] rd_addr,
    output logic [31:0] rd_data,
    output logic        rd_ack,
    output logic        done,
    output logic        busy,
    output s3_a_stat_t  stat
);
  localparam logic [24:0] NV    = 25'(NVEC);
  localparam logic [24:0] CLR_N = 25'((NVEC > 256) ? NVEC : 256);
  localparam logic [31:0] TO    = 32'(TIMEOUT);
  localparam int SW = N_DET + 1;   // shot word {exp_flip, det}
  localparam int SQ = DW - 32;     // seq field [DW-9:DW-32] = [SQ+23:SQ]
  if (N_DET < 1 || N_DET + 1 >= DW - 32) begin : g_chk
    $error("need 1 <= N_DET and N_DET + 1 < DW - 32 (at least one reserved bit)");
  end

  // status registers (bundled into `stat` at the end)
  logic        s_timeout, s_first_mis_v;
  logic [23:0] s_first_mis_seq;
  logic [47:0] s_lat_sum;
  logic [31:0] s_n_rx_words, s_lat_min, s_lat_max, s_mism, s_err_tag, s_err_range, s_err_overrun;
  logic [31:0] s_err_dup, s_err_echo, s_hist_under, s_hist_over, s_sig;

  typedef enum logic [2:0] {S_IDLE, S_CLEAR, S_PLAY, S_WAIT, S_DONE} st_t;
  st_t st;
  wire start = (st == S_IDLE) && run;
  wire rx_en = (st == S_PLAY) || (st == S_WAIT);

  logic [31:0] tsc;  // free-running timestamp counter
  always_ff @(posedge clk) tsc <= rst ? 32'd0 : tsc + 32'd1;

  // ---------------- shot ROM (block RAM, two registered read ports) ----------------
  (* ram_style = "block" *) logic [SW-1:0] shot_mem[NVEC];
  initial $readmemh(INIT_FILE, shot_mem);
  logic [AW-1:0] sa_addr, sb_addr;
  logic [SW-1:0] sa_q, sa_q2, sb_q;
  always_ff @(posedge clk) begin
    sa_q  <= shot_mem[sa_addr];
    sa_q2 <= sa_q;               // second register: the deep BRAM cascade's output mux gets a cycle
    sb_q  <= shot_mem[sb_addr];
  end

  // ---------------- read-ahead: ROM -> 4-entry FIFO (no tx_tready in the address path) ----------
  // The reader issues addresses 0..NVEC-1 in order from a register while the FIFO plus the two
  // read stages have room; sa_q2 lands 2 edges after the address. The player sends from the FIFO.
  logic [24:0] ra;               // next address to read
  logic [1:0]  rv;               // valid of the sa_q / sa_q2 stages
  logic [23:0] rs1, rs2;         // seq of those stages
  logic [24+N_DET-1:0] ff_mem[4];  // {seq, det}
  logic [1:0]  ff_wp, ff_rp;
  logic [2:0]  ff_cnt;
  wire rd_issue = (st == S_PLAY) && (ra < NV) && ({1'b0, ff_cnt} + {3'b0, rv[0]} + {3'b0, rv[1]} < 4'd4);
  assign sa_addr = ra[AW-1:0];

  // ---------------- player ----------------
  logic [24:0] n_sent;
  logic [24:0] clr;
  logic [15:0] gap_cnt;
  logic [31:0] to_cnt;
  logic [24:0] n_good;
  wire tx_acc   = tx_tvalid & tx_tready;
  wire can_load = (st == S_PLAY) && (ff_cnt != 3'd0) && (gap_cnt == 16'd0) && (!tx_tvalid || tx_tready);

  always_ff @(posedge clk) begin
    if (rst) begin
      st <= S_IDLE; n_sent <= '0; clr <= '0; gap_cnt <= '0; to_cnt <= '0;
      tx_tvalid <= 1'b0; tx_tdata <= '0; s_timeout <= 1'b0;
      ra <= '0; rv <= '0; ff_wp <= '0; ff_rp <= '0; ff_cnt <= '0;
    end else begin
      // reader
      rv  <= {rv[0], rd_issue};
      rs1 <= ra[23:0];
      rs2 <= rs1;
      if (rd_issue) ra <= ra + 25'd1;
      if (rv[1]) begin ff_mem[ff_wp] <= {rs2, sa_q2[N_DET-1:0]}; ff_wp <= ff_wp + 2'd1; end
      ff_cnt <= ff_cnt + {2'b0, rv[1]} - {2'b0, can_load};
      // player
      if (gap_cnt != 16'd0) gap_cnt <= gap_cnt - 16'd1;
      if (tx_acc) begin
        tx_tvalid <= 1'b0;
        n_sent <= n_sent + 25'd1;
      end
      if (can_load) begin
        tx_tvalid <= 1'b1;
        tx_tdata  <= {TAG_AB, ff_mem[ff_rp][24+N_DET-1:N_DET], (DW-33-N_DET)'(0), mode_echo,
                      ff_mem[ff_rp][N_DET-1:0]};
        ff_rp     <= ff_rp + 2'd1;
        gap_cnt   <= gap;
      end
      case (st)
        S_IDLE:  if (run) begin
          st <= S_CLEAR; n_sent <= '0; clr <= '0; gap_cnt <= '0; s_timeout <= 1'b0;
          ra <= '0; rv <= '0; ff_wp <= '0; ff_rp <= '0; ff_cnt <= '0;
        end
        S_CLEAR: begin
          clr <= clr + 25'd1;
          if (clr == CLR_N - 25'd1) st <= S_PLAY;
        end
        S_PLAY:  if (n_sent == NV) begin st <= S_WAIT; to_cnt <= '0; end
        S_WAIT:  begin
          to_cnt <= to_cnt + 32'd1;
          if (n_good == NV) st <= S_DONE;
          else if (to_cnt == TO) begin st <= S_DONE; s_timeout <= 1'b1; end
        end
        S_DONE:  if (!run) st <= S_IDLE;
        default: st <= S_IDLE;
      endcase
    end
  end
  assign done = (st == S_DONE);
  assign busy = (st == S_CLEAR) || (st == S_PLAY) || (st == S_WAIT);

  // ---------------- send-timestamp RAM: 1024 x {seq[23:10], tsc} ----------------
  (* ram_style = "block" *) logic [45:0] ts_mem[1024];
  logic [45:0] ts_q;
  always_ff @(posedge clk) if (tx_acc) ts_mem[tx_tdata[SQ+9:SQ]] <= {tx_tdata[SQ+23:SQ+10], tsc};

  // ---------------- R0: RX beat register ----------------
  logic        r0_v;
  logic [DW-1:0] r0_d;
  logic [31:0] r0_t;
  always_ff @(posedge clk) begin
    r0_v <= rx_tvalid && !rst;
    r0_d <= rx_tdata;
    r0_t <= tsc;
  end
  wire [23:0] r0_seq = r0_d[SQ+23:SQ];
  always_ff @(posedge clk) ts_q <= ts_mem[r0_seq[9:0]];
  assign sb_addr = (25'(r0_seq) < NV) ? r0_seq[AW-1:0] : '0;

  // ---------------- per-seq flag RAM {seen, flip} (block RAM, 1 write + 1 read port) ----------------
  logic        rd_s1, rd_s2, rd_sel_r;
  logic [23:0] rd_addr_r;
  (* ram_style = "block" *) logic [1:0] flag_mem[NVEC];
  logic [1:0]  flag_q;
  logic          fw_en;
  logic [AW-1:0] fw_addr;
  logic [1:0]    fw_data;
  wire  [23:0] fr_seq  = rd_s1 ? rd_addr_r : r0_seq;  // register reads only happen when idle
  wire  [AW-1:0] fr_addr = (25'(fr_seq) < NV) ? fr_seq[AW-1:0] : '0;
  always_ff @(posedge clk) begin
    flag_q <= flag_mem[fr_addr];
    if (fw_en) flag_mem[fw_addr] <= fw_data;
  end

  // ---------------- R1: classify ----------------
  logic        r1_v, r1_tag_ok, r1_rng_ok, r1_flip, r1_echo;
  logic [23:0] r1_seq;
  logic [31:0] r1_t;
  logic        pw_v;     // previous R1 wrote the flag RAM for pw_seq (read-during-write forwarding)
  logic [23:0] pw_seq;
  always_ff @(posedge clk) begin
    r1_v      <= r0_v && rx_en;
    r1_tag_ok <= (r0_d[DW-1:DW-8] == TAG_BA);
    r1_rng_ok <= (25'(r0_seq) < NV) && (25'(r0_seq) < n_sent);
    r1_seq    <= r0_seq;
    r1_flip   <= r0_d[0];
    r1_echo   <= r0_d[1];
    r1_t      <= r0_t;
  end
  wire        r1_overrun = (ts_q[45:32] != r1_seq[23:10]);
  wire        r1_seen    = flag_q[1] || (pw_v && pw_seq == r1_seq);
  wire        e_tag  = r1_v && !r1_tag_ok;
  wire        e_rng  = r1_v && r1_tag_ok && !r1_rng_ok;
  wire        e_ovr  = r1_v && r1_tag_ok && r1_rng_ok && r1_overrun;
  wire        e_dup  = r1_v && r1_tag_ok && r1_rng_ok && !r1_overrun && r1_seen;
  wire        good   = r1_v && r1_tag_ok && r1_rng_ok && !r1_overrun && !r1_seen;
  wire        exp_f  = mode_echo ? 1'b0 : sb_q[N_DET];
  wire [31:0] delta  = r1_t - ts_q[31:0];
  wire [31:0] d_off  = delta - 32'(hist_base);

  always_comb begin
    fw_en = 1'b0; fw_addr = r1_seq[AW-1:0]; fw_data = {1'b1, r1_flip};
    if (st == S_CLEAR) begin
      fw_en = (clr < NV); fw_addr = clr[AW-1:0]; fw_data = 2'b00;
    end else if (good) fw_en = 1'b1;
  end

  // ---------------- R2: latency stats + histogram ----------------
  logic        r2_v, r2_under, r2_over;
  logic [31:0] r2_delta;
  logic [7:0]  r2_bin;
  (* ram_style = "distributed" *) logic [31:0] hist[256];
  logic [31:0] hist_rq;
  always_ff @(posedge clk) begin
    r2_v     <= good;
    r2_delta <= delta;
    r2_under <= (delta < 32'(hist_base));
    r2_over  <= (delta >= 32'(hist_base)) && (d_off > 32'd255);
    r2_bin   <= d_off[7:0];
    if (st == S_CLEAR) begin
      if (clr < 25'd256) hist[clr[7:0]] <= 32'd0;
    end else if (r2_v && !r2_under && !r2_over) hist[r2_bin] <= hist[r2_bin] + 32'd1;
    hist_rq <= hist[rd_addr_r[7:0]];
  end

  // ---------------- counters (zeroed at run start) ----------------
  always_ff @(posedge clk) begin
    if (rst || start) begin
      n_good <= '0; pw_v <= 1'b0; pw_seq <= '0;
      s_n_rx_words <= '0; s_lat_min <= '1; s_lat_max <= '0; s_lat_sum <= '0;
      s_mism <= '0; s_first_mis_v <= 1'b0; s_first_mis_seq <= '0;
      s_err_tag <= '0; s_err_range <= '0; s_err_overrun <= '0; s_err_dup <= '0;
      s_err_echo <= '0; s_hist_under <= '0; s_hist_over <= '0; s_sig <= 32'hFFFF_FFFF;
    end else begin
      pw_v   <= good;
      pw_seq <= r1_seq;
      if (r1_v) s_n_rx_words <= s_n_rx_words + 32'd1;
      if (e_tag) s_err_tag     <= s_err_tag + 32'd1;
      if (e_rng) s_err_range   <= s_err_range + 32'd1;
      if (e_ovr) s_err_overrun <= s_err_overrun + 32'd1;
      if (e_dup) s_err_dup     <= s_err_dup + 32'd1;
      if (good) begin
        n_good   <= n_good + 25'd1;
        s_sig <= s3_misr(s_sig, r1_seq, r1_flip);
        if (r1_echo != mode_echo) s_err_echo <= s_err_echo + 32'd1;
        if (r1_flip != exp_f) begin
          s_mism <= s_mism + 32'd1;
          if (!s_first_mis_v) begin s_first_mis_v <= 1'b1; s_first_mis_seq <= r1_seq; end
        end
      end
      if (r2_v) begin
        if (r2_delta < s_lat_min) s_lat_min <= r2_delta;
        if (r2_delta > s_lat_max) s_lat_max <= r2_delta;
        s_lat_sum <= s_lat_sum + 48'(r2_delta);
        if (r2_under) s_hist_under <= s_hist_under + 32'd1;
        if (r2_over)  s_hist_over  <= s_hist_over + 32'd1;
      end
    end
  end
  assign stat = '{timeout: s_timeout, n_sent: 32'(n_sent), n_rx_words: s_n_rx_words, n_good: 32'(n_good),
                  lat_min: s_lat_min, lat_max: s_lat_max, lat_sum: s_lat_sum, mism: s_mism,
                  first_mis_v: s_first_mis_v, first_mis_seq: s_first_mis_seq, err_tag: s_err_tag,
                  err_range: s_err_range, err_overrun: s_err_overrun, err_dup: s_err_dup, err_echo: s_err_echo,
                  hist_under: s_hist_under, hist_over: s_hist_over, sig: s_sig};

  // ---------------- register read port ----------------
  always_ff @(posedge clk) begin
    rd_s1 <= rd_req && !rst;
    rd_s2 <= rd_s1;
    rd_ack <= rd_s2;
    if (rd_req) begin rd_sel_r <= rd_sel; rd_addr_r <= rd_addr; end
    if (rd_s2) rd_data <= rd_sel_r ? {30'b0, flag_q} : hist_rq;
  end

  // port A needs only det, port B only exp_flip (one ROM, two views); RX bits [DW-33:2] are reserved
  wire unused = &{1'b0, sa_q2[N_DET], sb_q[N_DET-1:0], r0_d[DW-33:2]};
endmodule
