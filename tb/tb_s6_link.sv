// tb_s6_link: Stage 6 gate 2, the fabric link alone. Two s6_link ends (A, B), NL lanes, joined lane by lane by
// tb_s6_gtch models (A TX -> B RX and B TX -> A RX), ONE clock (6.206 ns). Drive and sample at NEGEDGE only.
//
// Checks ($fatal(1) on any failure):
//   ref   an independent bit-serial descrambler (a 58-bit shift register, x^58 + x^39 + 1, written here, not
//         s6_pkg) recovers, from A's TXDATA as the GT takes it, exactly the words A accepted (data blocks) and
//         IDLE_BLK (control blocks). +NEGSCR uses the wrong tap (x^38): this check must then FAIL (negative control).
//   lock  every lane of both ends reaches block lock from a random bit boundary (and from random bits before the
//         far TX starts) within LOCK_MAX cycles; the slips are counted.
//   data  random traffic both ways (random gaps, back to back bursts, random words): the words B delivers equal, in
//         order, the words A's TX accepted, and the reverse; no word lost or added; one-way latency (TX accept edge
//         -> the next register edge after m_tvalid) is reported per lane skew setting; with NL > 1 the lanes have
//         different wire latencies (skew) and the deskew FIFOs must put the words back together.
//   ber   bit errors on A -> B (one flip in ~ber blocks): the end B counters must see them (n_sh_bad + n_idle_bad > 0
//         or a scoreboard mismatch): errors cannot pass silently through idle. Afterwards the link is clean again.
//   glitch one extra bit on the A -> B wire: B must lose lock (n_unlock + 1), slip, and lock again; traffic after
//         re-lock is clean.
//   burst 300 random blocks on B -> A: A loses lock and finds it again.
`timescale 1ns / 1fs

module tb_s6_link
  import s6_pkg::*;
#(
    parameter int NL     = 1,
    parameter int TX_REG = 0,
    parameter int RX_REG = 0,
    parameter int LOCK_MAX = 60000,
    localparam int DW = 64 * NL
);
  real t_ns = 6.206;
  logic clk = 1'b0;
  initial begin #0.001; forever #(t_ns / 2.0) clk = ~clk; end

  logic rst_tx = 1'b1, rst_rx = 1'b1, clr = 1'b0;
  logic [DW-1:0] a_sd = '0, b_sd = '0, a_md, b_md, a_txd, b_txd, a_rxd, b_rxd;
  logic a_sv = 1'b0, b_sv = 1'b0, a_sr, b_sr, a_mv, b_mv, a_lock, b_lock;
  logic [2*NL-1:0] a_txh, b_txh, a_rxh, b_rxh;
  logic [6:0] a_txs, b_txs;
  logic [NL-1:0] a_hv, a_dv, b_hv, b_dv, a_slip, b_slip;
  s6_link_stat_t a_st, b_st;

  s6_link #(.NL(NL), .TX_REG(TX_REG), .RX_REG(RX_REG)) u_a (
      .clk(clk), .rst_tx(rst_tx), .rst_rx(rst_rx), .clr(clr), .s_tdata(a_sd), .s_tvalid(a_sv), .s_tready(a_sr),
      .m_tdata(a_md), .m_tvalid(a_mv), .gt_txdata(a_txd), .gt_txheader(a_txh), .gt_txsequence(a_txs),
      .gt_rxdata(a_rxd), .gt_rxheader(a_rxh), .gt_rxheadervalid(a_hv), .gt_rxdatavalid(a_dv),
      .gt_rxgearboxslip(a_slip), .lock_all(a_lock), .stat(a_st));
  s6_link #(.NL(NL), .TX_REG(TX_REG), .RX_REG(RX_REG)) u_b (
      .clk(clk), .rst_tx(rst_tx), .rst_rx(rst_rx), .clr(clr), .s_tdata(b_sd), .s_tvalid(b_sv), .s_tready(b_sr),
      .m_tdata(b_md), .m_tvalid(b_mv), .gt_txdata(b_txd), .gt_txheader(b_txh), .gt_txsequence(b_txs),
      .gt_rxdata(b_rxd), .gt_rxheader(b_rxh), .gt_rxheadervalid(b_hv), .gt_rxdatavalid(b_dv),
      .gt_rxgearboxslip(b_slip), .lock_all(b_lock), .stat(b_st));

  for (genvar l = 0; l < NL; l++) begin : g_ch
    tb_s6_gtch #(.MITM(0)) u_ab (
        .clk(clk), .tx_en(!rst_tx), .txdata(a_txd[64*l +: 64]), .txheader(a_txh[2*l +: 2]), .txseq(a_txs),
        .rx_en(!rst_rx), .slip(b_slip[l]), .rxdata(b_rxd[64*l +: 64]), .rxheader(b_rxh[2*l +: 2]),
        .rxdv(b_dv[l]), .rxhv(b_hv[l]));
    tb_s6_gtch #(.MITM(0)) u_ba (
        .clk(clk), .tx_en(!rst_tx), .txdata(b_txd[64*l +: 64]), .txheader(b_txh[2*l +: 2]), .txseq(b_txs),
        .rx_en(!rst_rx), .slip(a_slip[l]), .rxdata(a_rxd[64*l +: 64]), .rxheader(a_rxh[2*l +: 2]),
        .rxdv(a_dv[l]), .rxhv(a_hv[l]));
    initial begin
      int sk;
      if (!$value$plusargs("SKEW=%d", sk)) sk = 70;
      u_ab.lat_ui = 640 + l * sk;
      u_ba.lat_ui = 655 + ((l * 2) % 3) * sk;
      u_ab.seed = 32'(11 + 10 * l);
      u_ba.seed = 32'(12 + 10 * l);
    end
  end

  // ---------------- stimulus / scoreboards ----------------
  int unsigned rng = 32'h1357_9BDF;
  function automatic int unsigned xs32();
    rng ^= rng << 13; rng ^= rng >> 17; rng ^= rng << 5;
    return rng;
  endfunction
  function automatic logic [DW-1:0] rword();
    logic [DW-1:0] w;
    for (int i = 0; i < DW; i += 32) w[i +: 32] = xs32();
    if (xs32() % 8 == 0) w = '0;          // syndrome-like all-zero words
    return w;
  endfunction

  logic [DW-1:0] q_ab[$], q_ba[$];       // accepted, not yet delivered
  longint        t_ab[$], t_ba[$];
  longint        cyc = 0;
  int            traffic = 0;            // 0 off, 1 random, 2 back to back
  int            n_mis = 0, n_extra = 0;
  longint        n_ok_ab = 0, n_ok_ba = 0;
  int            lat_ab_min = 1 << 30, lat_ab_max = 0, lat_ba_min = 1 << 30, lat_ba_max = 0;
  int            hab[64], hba[64];

  // reference descrambler (bit-serial) on A's lane-0 TX stream: checks s6_pkg::scramble independently
  logic [57:0] rs = '0;
  int          ref_skip = 64, n_ref_bad = 0;
  longint      n_ref = 0;
  bit          negscr = 0;
  logic [DW-1:0] q_ref[$];

  // stimulus at negedge + 0.75 ns (before the models act at + 1.5 ns), sampling at negedge + 2.25 ns (after)
  bit a_acc = 1'b0, b_acc = 1'b0;      // a handshake seen at the last negedge (it happened at the posedge since)
  always @(negedge clk) begin
    #0.75;
    if (a_acc) a_sv = 1'b0;
    if (b_acc) b_sv = 1'b0;
    if (traffic != 0) begin
      if (!a_sv && (traffic == 2 || xs32() % 4 == 0)) begin a_sv = 1'b1; a_sd = rword(); end
      if (!b_sv && (traffic == 2 || xs32() % 3 == 0)) begin b_sv = 1'b1; b_sd = rword(); end
    end
    // tvalid / tready are now stable until the next posedge, where the transfer happens
    a_acc = a_sv && a_sr;
    b_acc = b_sv && b_sr;
    if (a_acc) begin q_ab.push_back(a_sd); t_ab.push_back(cyc + 1); if (ref_skip == 0) q_ref.push_back(a_sd); end
    if (b_acc) begin q_ba.push_back(b_sd); t_ba.push_back(cyc + 1); end
  end

  always @(negedge clk) begin
    logic [63:0] clr64;
    logic        f;
    #2.25;
    cyc++;
    // the GT takes A's block at the next posedge when TXSEQUENCE != 32; with TX_REG = 1 that block is the one
    // accepted a cycle earlier (q_ref holds the accepted words in order either way)
    if (!rst_tx && a_txs[5:0] != 6'd32) begin
      for (int i = 63; i >= 0; i--) begin
        f = a_txd[i] ^ rs[38] ^ (negscr ? rs[37] : rs[57]);
        rs = {rs[56:0], a_txd[i]};
        clr64[i] = f;
      end
      if (ref_skip > 0) ref_skip--;   // the first words only fill the reference's shift register
      else begin
        n_ref++;
        if (a_txh[1:0] == HDR_DATA) begin
          if (q_ref.size() == 0 || clr64 != q_ref[0][63:0]) n_ref_bad++;
          if (q_ref.size() != 0) void'(q_ref.pop_front());
        end else if (a_txh[1:0] == HDR_CTRL) begin
          if (clr64 != IDLE_BLK) n_ref_bad++;
        end else n_ref_bad++;
      end
    end
    // RX: the next register edge captures m_t*; latency = that edge - the TX accept edge (cycle numbers of edges)
    if (b_mv) begin
      if (q_ab.size() == 0) n_extra++;
      else begin
        int l;
        l = int'(cyc - t_ab[0]);
        if (b_md != q_ab[0]) begin n_mis++; if (n_mis <= 5) $display("MIS a->b cyc=%0d got=%h exp=%h", cyc, b_md, q_ab[0]); end
        else n_ok_ab++;
        if (l < lat_ab_min) lat_ab_min = l;
        if (l > lat_ab_max) lat_ab_max = l;
        if (l < 64) hab[l]++;
        void'(q_ab.pop_front()); void'(t_ab.pop_front());
      end
    end
    if (a_mv) begin
      if (q_ba.size() == 0) n_extra++;
      else begin
        int l;
        l = int'(cyc - t_ba[0]);
        if (a_md != q_ba[0]) begin n_mis++; if (n_mis <= 5) $display("MIS b->a cyc=%0d got=%h exp=%h", cyc, a_md, q_ba[0]); end
        else n_ok_ba++;
        if (l < lat_ba_min) lat_ba_min = l;
        if (l > lat_ba_max) lat_ba_max = l;
        if (l < 64) hba[l]++;
        void'(q_ba.pop_front()); void'(t_ba.pop_front());
      end
    end
  end

  task automatic wait_cyc(input int n);
    repeat (n) @(negedge clk);
  endtask

  task automatic wait_lock(input string what);
    int n;
    n = 0;
    while (!(a_lock && b_lock)) begin
      @(negedge clk); n++;
      if (n > LOCK_MAX) $fatal(1, "%s: no block lock after %0d cycles (A %b B %b, slips A %0d B %0d)", what, n,
                              a_st.lock, b_st.lock, a_st.n_slip, b_st.n_slip);
    end
    wait_cyc(4);   // let the lock counters update
    $display("LOCK %s after %0d cycles: A lock=%b slips=%0d  B lock=%b slips=%0d", what, n, a_st.lock, a_st.n_slip,
             b_st.lock, b_st.n_slip);
  endtask

  task automatic drain(input string what);
    traffic = 0;
    wait_cyc(200);
    if (q_ab.size() != 0 || q_ba.size() != 0) $fatal(1, "%s: %0d / %0d words never delivered", what, q_ab.size(), q_ba.size());
  endtask

  task automatic traffic_phase(input string what, input int mode, input int ncyc);
    longint ab0, ba0;
    int mis0;
    ab0 = n_ok_ab; ba0 = n_ok_ba; mis0 = n_mis;
    traffic = mode;
    wait_cyc(ncyc);
    drain(what);
    $display("TRAFFIC %s mode=%0d cycles=%0d words a->b=%0d b->a=%0d mismatches=%0d extra=%0d", what, mode, ncyc,
             n_ok_ab - ab0, n_ok_ba - ba0, n_mis - mis0, n_extra);
    if (n_mis != mis0 || n_extra != 0) $fatal(1, "%s: %0d mismatched, %0d extra words", what, n_mis - mis0, n_extra);
    if (n_ok_ab == ab0 || n_ok_ba == ba0) $fatal(1, "%s: no traffic", what);
  endtask

  initial begin
    int skew, unl0, lk0, e0;
    negscr = $test$plusargs("NEGSCR");
    if (!$value$plusargs("SKEW=%d", skew)) skew = 70;
    // wire latency per lane (MODEL): set in g_ch (A -> B lane l: 640 + l*SKEW UI, B -> A: 655 + ((l*2) % 3)*SKEW UI)
    $display("CONFIG tb_s6_link NL=%0d TX_REG=%0d RX_REG=%0d T_NS=%.3f skew_ui=%0d negscr=%0d (wire latencies MODEL)", NL, TX_REG,
             RX_REG, t_ns, skew, negscr);
    wait_cyc(20);
    rst_rx = 1'b0;           // RX first: random bits until the far TX starts
    wait_cyc(500);
    rst_tx = 1'b0;
    wait_lock("initial");

    // ---- clean traffic ----
    traffic_phase("random", 1, 20000);
    traffic_phase("b2b", 2, 20000);
    $display("REF descrambled %0d blocks of A lane 0, %0d wrong", n_ref, n_ref_bad);
    if (n_ref < 30000) $fatal(1, "reference descrambler saw too few blocks");
    if (n_ref_bad != 0) $fatal(1, "REF: independent descrambler disagrees on %0d blocks", n_ref_bad);
    if (a_st.n_unlock != 0 || b_st.n_unlock != 0 || a_st.n_sh_bad != 0 || b_st.n_sh_bad != 0 || a_st.n_idle_bad != 0 ||
        b_st.n_idle_bad != 0 || a_st.n_dsk_ovf != 0 || b_st.n_dsk_ovf != 0 || a_st.n_hv_dv != 0 || b_st.n_hv_dv != 0)
      $fatal(1, "clean phases: link error counters not zero");
    $display("LAT a->b one-way %0d..%0d cycles, b->a %0d..%0d cycles (TX accept edge -> next register edge; MODEL wire)",
             lat_ab_min, lat_ab_max, lat_ba_min, lat_ba_max);
    for (int i = 0; i < 64; i++) if (hab[i] != 0 || hba[i] != 0) $display("HISTLAT %0d a->b %0d b->a %0d", i, hab[i], hba[i]);

    // ---- bit errors A -> B (negative control: they must be seen) ----
    e0 = b_st.n_sh_bad + b_st.n_idle_bad;
    for (int l = 0; l < NL; l++) begin
      case (l) 0: g_ch[0].u_ab.ber_blk = 500; default: ; endcase
    end
    traffic = 1; wait_cyc(30000); traffic = 0;
    for (int l = 0; l < NL; l++) begin
      case (l) 0: g_ch[0].u_ab.ber_blk = 0; default: ; endcase
    end
    wait_cyc(300);
    $display("BER injected %0d flips on A->B lane 0: B n_sh_bad=%0d n_idle_bad=%0d unlocks=%0d scoreboard mismatches=%0d",
             g_ch[0].u_ab.n_flip, b_st.n_sh_bad, b_st.n_idle_bad, b_st.n_unlock, n_mis);
    if (g_ch[0].u_ab.n_flip == 0) $fatal(1, "BER: nothing injected");
    if (b_st.n_sh_bad + b_st.n_idle_bad == e0 && n_mis == 0) $fatal(1, "BER: bit errors passed undetected");
    q_ab.delete(); t_ab.delete(); q_ba.delete(); t_ba.delete(); n_mis = 0; n_extra = 0;
    wait_lock("after BER");
    traffic_phase("after_ber", 1, 10000);

    // ---- glitch: one extra bit A -> B ----
    unl0 = b_st.n_unlock; lk0 = b_st.n_lock;
    for (int l = 0; l < NL; l++) begin
      case (l) 0: g_ch[0].u_ab.glitch_at = g_ch[0].u_ab.cyc + 100; default: ; endcase
    end
    wait_cyc(2000);
    wait_lock("after glitch");
    $display("GLITCH B unlock %0d -> %0d, lock %0d -> %0d, slips %0d", unl0, b_st.n_unlock, lk0, b_st.n_lock, b_st.n_slip);
    if (b_st.n_unlock == unl0 || b_st.n_lock == lk0) $fatal(1, "GLITCH: lock was not lost and found again");
    // between the misalignment and the loss of lock, misaligned blocks whose 2 header bits happen to read 01 are
    // delivered as (garbage) words: a property of 64B/66B block sync without a CRC; counted, then cleared
    $display("GLITCH garbage words delivered while losing lock: %0d", n_extra);
    q_ab.delete(); t_ab.delete(); q_ba.delete(); t_ba.delete(); n_mis = 0; n_extra = 0;
    traffic_phase("after_glitch", 1, 10000);

    // ---- burst: 300 random blocks B -> A ----
    unl0 = a_st.n_unlock; lk0 = a_st.n_lock;
    for (int l = 0; l < NL; l++) begin
      case (l) 0: begin g_ch[0].u_ba.burst_len = 300; g_ch[0].u_ba.burst_at = g_ch[0].u_ba.cyc + 50; end default: ; endcase
    end
    wait_cyc(1000);
    wait_lock("after burst");
    $display("BURST A unlock %0d -> %0d, lock %0d -> %0d", unl0, a_st.n_unlock, lk0, a_st.n_lock);
    if (a_st.n_unlock == unl0 || a_st.n_lock == lk0) $fatal(1, "BURST: lock was not lost and found again");
    $display("BURST garbage words delivered while losing lock: %0d", n_extra);
    q_ab.delete(); t_ab.delete(); q_ba.delete(); t_ba.delete(); n_mis = 0; n_extra = 0;
    traffic_phase("after_burst", 2, 10000);

    $display("RESULT tb_s6_link NL=%0d TX_REG=%0d RX_REG=%0d words a->b=%0d b->a=%0d lat_ab=%0d..%0d lat_ba=%0d..%0d ref_blocks=%0d ref_bad=%0d slips_a=%0d slips_b=%0d unlock_a=%0d unlock_b=%0d fails=0",
             NL, TX_REG, RX_REG, n_ok_ab, n_ok_ba, lat_ab_min, lat_ab_max, lat_ba_min, lat_ba_max, n_ref, n_ref_bad,
             a_st.n_slip, b_st.n_slip, a_st.n_unlock, b_st.n_unlock);
    $display("PASS");
    $finish;
  end
endmodule
