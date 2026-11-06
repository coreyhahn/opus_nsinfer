// s3_side_b: Stage 3 decoder side (clk = Aurora B user_clk, synchronous reset).
//
// Every A -> B beat (tag A5) is registered (R, the RX word register) and then takes one of two paths
// into the TX FIFO; the FIFO entry is the TX word register (show-ahead: the word is on tx_tdata the
// cycle after it is written when the FIFO was empty).
//   decode (bit N_DET = 0): R drives the decoder's det (qec_d3_top for N_DET = 24, qec_d5_top for
//                        N_DET = 120; IN_W = N_DET, OUT_W, LOGIT_SIGNED passed through); the flip is valid DEC_LAT edges after R (core input
//                        register + stages + logit register + flip register), a DEC_LAT-deep valid/seq
//                        shift register runs alongside; the word is written to the FIFO at the next edge.
//                        RX register edge -> FIFO write edge = DEC_LAT + 1 edges.
//   echo   (bit N_DET = 1): R goes straight to the FIFO write: RX register edge -> FIFO write edge = 1 edge.
//   Both paths: link beat -> R (1 edge) ... FIFO write ... -> tx_tdata (0 edges, combinational read).
//   So decode - echo = DEC_LAT exactly; the framing alone costs 2 edges (R and the FIFO entry).
// If a decode word and an echo word reach the FIFO in the same cycle (only when the mode changes with
// words in flight) the decode word wins and `collide` counts the dropped echo word.
//
// Word formats (DW bits): s3_pkg.
// TX: 16-deep show-ahead FIFO (LUTRAM) absorbs tx_tready drops (Aurora clock compensation). A word
// arriving at a full FIFO is dropped and counted (fifo_ovf).
// Decode-alone measurement: 16-bit free counter, stamped at R, differenced at the FIFO write; min/max/
// count per path (expected constant: DEC_LAT + 1 for decode, 1 for echo).
module s3_side_b
  import s3_pkg::*;
#(
    parameter int N_DET        = 24,  // detection bits per shot (24: d = 3, 120: d = 5)
    parameter int DW           = 64,  // Aurora user data width (64: 1 lane, 192: 3 lanes)
    parameter int IN_W         = N_DET,
    parameter int OUT_W        = 18,
    parameter int LOGIT_SIGNED = 1,
    parameter int DEC_LAT      = 8   // det applied -> flip valid, edges (= metadata latency + 2)
) (
    input  logic        clk,
    input  logic        rst,
    // Aurora B RX (no tready)
    input  logic [DW-1:0] rx_tdata,
    input  logic        rx_tvalid,
    // Aurora B TX
    output logic [DW-1:0] tx_tdata,
    output logic        tx_tvalid,
    input  logic        tx_tready,
    output s3_b_stat_t  stat
);
  if (DEC_LAT < 2) begin : g_chk
    $error("DEC_LAT must be >= 2");
  end
  if (IN_W != N_DET || N_DET + 1 >= DW - 32) begin : g_chk_w
    $error("need IN_W == N_DET and N_DET + 1 < DW - 32");
  end
  localparam int SQ = DW - 32;  // seq field [DW-9:DW-32] = [SQ+23:SQ]

  logic [15:0] tsc;
  always_ff @(posedge clk) tsc <= rst ? 16'd0 : tsc + 16'd1;

  // ---------------- R: RX word register ----------------
  logic        r_v;
  logic [DW-1:0] r_d;
  logic [15:0] r_t;
  always_ff @(posedge clk) begin
    r_v <= rx_tvalid && !rst;
    r_d <= rx_tdata;
    r_t <= tsc;
  end
  wire r_ok   = r_v && (r_d[DW-1:DW-8] == TAG_AB);
  wire r_echo = r_d[N_DET];

  // ---------------- decode path ----------------
  wire [OUT_W-1:0] logit;
  wire             flip;
  if (N_DET == 24) begin : g_d3
    qec_d3_top #(.IN_W(IN_W), .OUT_W(OUT_W), .LOGIT_SIGNED(LOGIT_SIGNED)) u_dec (
        .clk(clk), .det(r_d[IN_W-1:0]), .logit(logit), .flip(flip));
  end else if (N_DET == 120) begin : g_d5
    qec_d5_top #(.IN_W(IN_W), .OUT_W(OUT_W), .LOGIT_SIGNED(LOGIT_SIGNED)) u_dec (
        .clk(clk), .det(r_d[IN_W-1:0]), .logit(logit), .flip(flip));
  end else begin : g_bad
    $error("N_DET must be 24 (qec_d3_top) or 120 (qec_d5_top)");
  end

  logic [DEC_LAT-1:0] d_v;
  logic [23:0]        d_seq[DEC_LAT];
  logic [15:0]        d_t  [DEC_LAT];
  always_ff @(posedge clk) begin
    d_v      <= rst ? '0 : {d_v[DEC_LAT-2:0], r_ok && !r_echo};
    d_seq[0] <= r_d[SQ+23:SQ];
    d_t[0]   <= r_t;
    for (int i = 1; i < DEC_LAT; i++) begin
      d_seq[i] <= d_seq[i-1];
      d_t[i]   <= d_t[i-1];
    end
  end

  // ---------------- path merge -> FIFO write ----------------
  wire        dv  = d_v[DEC_LAT-1];
  wire        ev  = r_ok && r_echo;
  wire        o_v = dv || ev;
  wire [DW-1:0] o_d = dv ? {TAG_BA, d_seq[DEC_LAT-1], (DW-34)'(0), 1'b0, flip}
                         : {TAG_BA, r_d[SQ+23:SQ], (DW-34)'(0), 1'b1, 1'b0};
  wire [15:0] o_dt = tsc - (dv ? d_t[DEC_LAT-1] : r_t);

  // ---------------- TX FIFO, 16 x DW, show-ahead ----------------
  (* ram_style = "distributed" *) logic [DW-1:0] fifo[16];
  logic [4:0] wp, rp;
  wire  [4:0] occ  = wp - rp;
  wire        full = (occ == 5'd16);
  wire        wr   = o_v && !full;
  wire        rd   = tx_tvalid && tx_tready;
  assign tx_tdata  = fifo[rp[3:0]];
  assign tx_tvalid = (wp != rp);
  always_ff @(posedge clk) begin
    if (wr) fifo[wp[3:0]] <= o_d;
    if (rst) begin
      wp <= '0; rp <= '0;
    end else begin
      if (wr) wp <= wp + 5'd1;
      if (rd) rp <= rp + 5'd1;
    end
  end

  // ---------------- status ----------------
  logic [31:0] s_n_rx, s_n_tx, s_err_tag, s_fifo_ovf, s_collide, s_dec_cnt, s_echo_cnt;
  logic [15:0] s_dec_min, s_dec_max, s_echo_min, s_echo_max;
  logic [4:0]  s_fifo_max;
  always_ff @(posedge clk) begin
    if (rst) begin
      s_n_rx <= '0; s_n_tx <= '0; s_err_tag <= '0; s_fifo_ovf <= '0; s_collide <= '0; s_fifo_max <= '0;
      s_dec_min <= '1; s_dec_max <= '0; s_dec_cnt <= '0; s_echo_min <= '1; s_echo_max <= '0; s_echo_cnt <= '0;
    end else begin
      if (r_ok) s_n_rx <= s_n_rx + 32'd1;
      if (r_v && !r_ok) s_err_tag <= s_err_tag + 32'd1;
      if (rd) s_n_tx <= s_n_tx + 32'd1;
      if (o_v && full) s_fifo_ovf <= s_fifo_ovf + 32'd1;
      if (dv && ev) s_collide <= s_collide + 32'd1;
      if (occ > s_fifo_max) s_fifo_max <= occ;
      if (dv) begin
        s_dec_cnt <= s_dec_cnt + 32'd1;
        if (o_dt < s_dec_min) s_dec_min <= o_dt;
        if (o_dt > s_dec_max) s_dec_max <= o_dt;
      end else if (ev) begin
        s_echo_cnt <= s_echo_cnt + 32'd1;
        if (o_dt < s_echo_min) s_echo_min <= o_dt;
        if (o_dt > s_echo_max) s_echo_max <= o_dt;
      end
    end
  end
  assign stat = '{n_rx: s_n_rx, n_tx: s_n_tx, err_tag: s_err_tag, fifo_ovf: s_fifo_ovf, collide: s_collide,
                  fifo_max: s_fifo_max, dec_min: s_dec_min, dec_max: s_dec_max, dec_cnt: s_dec_cnt,
                  echo_min: s_echo_min, echo_max: s_echo_max, echo_cnt: s_echo_cnt};

  // logit is the decoder's raw output (checked in Stage 2); RX bits [DW-33:N_DET+1] are reserved
  wire unused = &{1'b0, logit, r_d[DW-33:N_DET+1]};
endmodule
