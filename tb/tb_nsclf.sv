// tb_nsclf: nsclf_user (everything of the nsclf RFNoC block below its noc_shell) on the committed golden
// stream, with a ctrlport master model and an AXI-Stream sink in place of the framework.
//
// Stimulus and expected values come from sw/x310/nsclf_model.py stim (STIM=<dir>):
//   samples.hex  radio word {I[31:16], Q[15:0]} of sample k (ref/golden/x310_stream_in.hex re-packed)
//   toff.hex     cycle offset of sample k: it is driven on rx_data[CHAN] with rx_stb[CHAN] = 1 in the cycle in
//                which radio_time = T0 + toff[k] (no gaps for seed 0, as on the X310; random idle cycles else)
//   dec.hex      expected decision word {logits, cls} of window j (Keras model, ref/golden/x310_stream_out/dec)
//   windows.hex  per MISR window: T_start N MISR count h0 h1 h2 h3 tfirst tlast
//   evten.hex    (2026-11 event revision) EVT_EN switches "t_sw value" (+NEVSW=n of them; n = 0: EVT_EN is written 1
//                during the configuration, before the stream): a separate process writes REG_CTRL bit 2 when
//                radio_time reaches the switch (the model picked quiet points, so the write's jitter does not matter)
// Checks, all at NEGEDGE, any failure -> $fatal(1):
//   * pass-through: every *_out equals its *_in (and back) on every cycle, with random values on all of them;
//   * every decision (cls and logits) equals the expected word, in order, and there are NS - W + 1 of them;
//   * every decision's tau equals the tap time of its window's newest sample, and it is valid exactly
//     REG_LATENCY cycles after that sample was on rx_data (the alignment definition, README section 3);
//   * MISR, count, per-class counts, first/last tau and status of every window equal the model's;
//   * a window armed after its start has passed reports LATE; REG_DEC (decision count) = NS - W + 1;
//   * AXIS rules on the event stream (sideband on the first beat of a packet, tlength = 24 x records, tlast on the
//     last record's third beat, data and sideband stable while stalled);
//   * the packet framer, cycle by cycle, from the outside (record pushes into the FIFO + AXIS handshakes): a packet
//     starts exactly at the edges the start rule of rtl/x310/nsclf_core.sv gives, with n = min(queued, nbmax)
//     records; every record queued leaves; REG_EVT_PKTS = packets seen.
// Event packets are printed as "EVTPKT <ts> <n>" followed by n "EVT <ts> <w0> <w1> <w2>" lines, then
// "EVTREG drop=.. seq=.. pkts=..", and compared with the model's hysteresis (with the EVT_EN schedule) by
// nsclf_model.py check-events (tb/run_nsclf.sh). +FLUSH=<cycles> writes REG_EVT_FLUSH (else the reset value is kept
// and checked). CORRUPT=j flips bit 2 (a logit bit) of the
// expected word of decision j; CORRUPT_WIN=1 flips bit 0 of window 0's expected MISR (negative controls).
// REPLAY=1 (sw/x310/nsclf_replay.py, a host capture re-run): no expected decisions or window values exist; the
// tau / latency / pass-through / AXIS checks still run, the window registers and events are printed and the
// Python side compares them with the silicon read-back. +DUMP=<file> (replay only) writes every decision as one
// line "<tau 16 hex> <{logits, cls} 16 hex>", in order, for the per-decision analysis (nsclf_replay.py --dump).
`timescale 1ns / 1ps

module tb_nsclf #(
    parameter int W = 64,
    parameter int OUT_W = 62,
    parameter int CORE_LAT = 15,
    parameter int BFP_PIPE = 1,
    parameter int IN_REG = 1,
    parameter int NS = 65536,
    parameter int K_DEFAULT = 16,
    parameter int EVT_AW = 6,
    parameter int EVT_BATCH = 16,
    parameter int EVT_FLUSH_DEFAULT = 4096
);
  localparam int NDEC = NS - W + 1;
  localparam int L = IN_REG + 1 + CORE_LAT + 1 + BFP_PIPE;
  localparam int NWMAX = 16;
  localparam int NSWMAX = 16;
  localparam int GO_CYC = 400;

  logic clk = 1'b0;
  always #2.5 clk = ~clk;

  // ---------------------------------------------------------------- DUT
  logic        rst = 1'b1;
  logic [63:0] rx_data_in, tx_data_out;
  logic [1:0]  rx_stb_in, tx_stb_in, rx_running_out, tx_running_out;
  wire  [63:0] rx_data_out, tx_data_in;
  wire  [1:0]  rx_stb_out, tx_stb_out, rx_running_in, tx_running_in;
  logic [63:0] radio_time;
  logic        req_wr = 0, req_rd = 0;
  logic [19:0] req_addr = 0;
  logic [31:0] req_data = 0;
  wire         resp_ack;
  wire  [31:0] resp_data;
  wire  [63:0] e_tdata, e_ts;
  wire  [0:0]  e_tkeep;
  wire         e_tlast, e_tvalid, e_has_time, e_teov, e_teob;
  wire  [15:0] e_tlength;
  logic        e_tready = 1'b0;

  nsclf_user #(.NUM_PORTS(2), .NIPC(1), .W(W), .OUT_W(OUT_W), .CORE_LAT(CORE_LAT), .BFP_PIPE(BFP_PIPE),
               .IN_REG(IN_REG), .K_DEFAULT(K_DEFAULT), .EVT_AW(EVT_AW), .EVT_BATCH(EVT_BATCH),
               .EVT_FLUSH_DEFAULT(EVT_FLUSH_DEFAULT)) dut (
      .radio_clk(clk), .radio_rst(rst),
      .radio_rx_data_in(rx_data_in), .radio_rx_stb_in(rx_stb_in), .radio_rx_running_in(rx_running_in),
      .radio_tx_data_in(tx_data_in), .radio_tx_stb_in(tx_stb_in), .radio_tx_running_in(tx_running_in),
      .radio_rx_data_out(rx_data_out), .radio_rx_stb_out(rx_stb_out), .radio_rx_running_out(rx_running_out),
      .radio_tx_data_out(tx_data_out), .radio_tx_stb_out(tx_stb_out), .radio_tx_running_out(tx_running_out),
      .radio_time(radio_time),
      .m_ctrlport_req_wr(req_wr), .m_ctrlport_req_rd(req_rd), .m_ctrlport_req_addr(req_addr),
      .m_ctrlport_req_data(req_data), .m_ctrlport_resp_ack(resp_ack), .m_ctrlport_resp_data(resp_data),
      .s_evt_axis_tdata(e_tdata), .s_evt_axis_tkeep(e_tkeep), .s_evt_axis_tlast(e_tlast),
      .s_evt_axis_tvalid(e_tvalid), .s_evt_axis_tready(e_tready), .s_evt_axis_ttimestamp(e_ts),
      .s_evt_axis_thas_time(e_has_time), .s_evt_axis_tlength(e_tlength), .s_evt_axis_teov(e_teov),
      .s_evt_axis_teob(e_teob));

  // ---------------------------------------------------------------- stimulus files
  logic [31:0] smem[NS];
  logic [31:0] toff[NS];
  logic [63:0] dmem[NDEC];
  logic [63:0] wmem[NWMAX*10];
  logic [63:0] swmem[NSWMAX*2];
  string       stim;
  int unsigned seed, chan, kreg, ready_mode, nwin, corrupt, corrupt_win, replay, nevsw, flush;
  bit          flush_set;
  string       dump;
  int          dump_fd = 0;
  logic [63:0] t0;

  int unsigned rng;
  function automatic int unsigned xs32();
    rng ^= rng << 13;
    rng ^= rng >> 17;
    rng ^= rng << 5;
    return rng;
  endfunction
  int unsigned rng2;                 // the AXIS sink's own generator
  function automatic int unsigned xs32b();
    rng2 ^= rng2 << 13;
    rng2 ^= rng2 >> 17;
    rng2 ^= rng2 << 5;
    return rng2;
  endfunction

  // ---------------------------------------------------------------- clock-cycle bookkeeping
  int          cyc = 0;            // incremented at every negedge
  int          ks = 0;             // next sample to drive
  bit          go = 0, stream_done = 0, drain = 0;
  int          cyc_drive[NS];
  int          n_dec = 0, n_dmis = 0, n_tmis = 0, n_lmis = 0, n_pt = 0;
  int          errors = 0;

  // previous-cycle pass-through inputs, checked against the outputs at the next negedge
  logic [63:0] p_rx_data, p_tx_data;
  logic [1:0]  p_rx_stb, p_tx_stb, p_rx_run, p_tx_run;
  bit          p_valid = 0;

  always @(negedge clk) begin
    // 1. pass-through check: outputs must equal the inputs driven at the previous negedge
    if (p_valid) begin
      if (rx_data_out !== p_rx_data || rx_stb_out !== p_rx_stb || tx_stb_out !== p_tx_stb ||
          rx_running_in !== p_rx_run || tx_data_in !== p_tx_data || tx_running_in !== p_tx_run) begin
        n_pt++;
        if (n_pt <= 5) $display("PASSTHROUGH_MISMATCH cyc=%0d", cyc);
      end
    end
    // 2. decision checks (internal probes of the tap path)
    if (!rst && dut.u_core.dvld) begin
      logic [63:0] word, expw, exp_tau;
      int j;
      j = n_dec;
      if (j >= NDEC) $fatal(1, "more than NDEC = %0d decisions", NDEC);
      word = dut.u_core.dword;   // {logits, cls}, folded to 64 bits if wider
      expw = replay ? word : dmem[j];
      if (dump_fd != 0) $fwrite(dump_fd, "%h %h\n", dut.u_core.tau, word);
      if (j == int'(corrupt)) expw[2] = ~expw[2];
      if (word !== expw) begin
        n_dmis++;
        if (n_dmis <= 10) $display("MISMATCH decision=%0d got=%h exp=%h", j, word, expw);
      end
      exp_tau = t0 + 64'(toff[j + W - 1]);
      if (dut.u_core.tau !== exp_tau) begin
        n_tmis++;
        if (n_tmis <= 10) $display("TAU_MISMATCH decision=%0d got=%h exp=%h", j, dut.u_core.tau, exp_tau);
      end
      // edges from the one that captures the window's newest sample from rx_data (edge 1) to the one after
      // which the decision is on the outputs; this negedge follows edge cyc - cyc_drive + 1
      if (cyc - cyc_drive[j + W - 1] + 1 != L) begin
        n_lmis++;
        if (n_lmis <= 10) $display("LATENCY_MISMATCH decision=%0d edges=%0d L=%0d", j, cyc - cyc_drive[j + W - 1] + 1, L);
      end
      n_dec++;
    end
    // 3. drive the next cycle: time, samples, pass-through randoms
    cyc++;
    radio_time = t0 + 64'(longint'(cyc) - longint'(GO_CYC));
    begin
      rx_data_in = {xs32(), xs32()};
      rx_stb_in = 2'(xs32());
      if (go && ks < NS && cyc == GO_CYC + int'(toff[ks])) begin
        rx_data_in[32*chan +: 32] = smem[ks];
        rx_stb_in[chan] = 1'b1;
        cyc_drive[ks] = cyc;
        ks++;
        if (ks == NS) stream_done = 1;
      end else begin
        rx_stb_in[chan] = 1'b0;
      end
      tx_data_out = {xs32(), xs32()};
      tx_stb_in = 2'(xs32());
      rx_running_out = 2'(xs32() >> 3);
      tx_running_out = 2'(xs32() >> 7);
    end
    p_rx_data = rx_data_in; p_tx_data = tx_data_out; p_rx_stb = rx_stb_in; p_tx_stb = tx_stb_in;
    p_rx_run = rx_running_out; p_tx_run = tx_running_out; p_valid = 1;
  end

  // ---------------------------------------------------------------- AXIS event sink + framer check
  int          beat = 0, rec_left = 0, n_evt = 0, n_pkt = 0, n_axis_err = 0, n_frm_err = 0, stall_left = 0, run_left = 0;
  logic [63:0] ew[3];
  logic [63:0] ets;
  logic        last_valid = 0, last_ready = 0, last_tlast = 0;
  logic [63:0] last_data, last_ts;
  logic [15:0] last_len;
  // framer reference: queued records (negedge index of their push), packet state
  int          ncyc = 0;          // incremented at the end of every negedge of this block
  int          pq[$];             // push negedge index of each queued record not yet in a packet
  bit          exp_start = 0, tb_in_pkt = 0, lastpop_prev = 0, sop = 0;
  int          exp_n = 0, n_full = 0, n_part = 0;
  task automatic frm_err(input string m);
    n_frm_err++;
    if (n_frm_err <= 10) $display("FRAMER_ERROR cyc=%0d: %s", ncyc, m);
  endtask
  always @(negedge clk) begin
    int nbmax;
    bit lastpop_now;
    nbmax = (flush == 0) ? 1 : EVT_BATCH;
    lastpop_now = 0;
    // AXIS stability: a beat offered but not taken must stay offered with the same data / sideband
    if (last_valid && !last_ready && (!e_tvalid || e_tdata !== last_data || e_tlast !== last_tlast ||
                                      (sop && (e_ts !== last_ts || e_tlength !== last_len)))) begin
      n_axis_err++;
      if (n_axis_err <= 5) $display("AXIS_ERROR cyc=%0d: tvalid/tdata/sideband changed while stalled", cyc);
    end
    // 1. framer: did a packet start exactly where the rule says?
    if (!rst) begin
      if (exp_start) begin
        exp_start = 0;
        if (!e_tvalid) frm_err($sformatf("packet of %0d records expected to start, tvalid low", exp_n));
        else if (tb_in_pkt) frm_err("packet start expected inside a packet");
        else begin
          if (e_tlength !== 16'(24 * exp_n)) frm_err($sformatf("tlength %0d, expected 24 x %0d", e_tlength, exp_n));
          tb_in_pkt = 1;
          sop = 1;
          rec_left = exp_n;
          beat = 0;
          if (exp_n == nbmax) n_full++; else n_part++;
        end
      end else if (e_tvalid && !tb_in_pkt) begin
        frm_err($sformatf("unexpected packet start (tlength %0d, queued %0d)", e_tlength, pq.size()));
        tb_in_pkt = 1;   // follow the DUT so the records are still printed
        sop = 1;
        rec_left = int'(e_tlength) / 24;
        beat = 0;
      end
    end
    // choose tready for the coming edge
    if (drain || ready_mode == 0) e_tready = 1'b1;
    else if (ready_mode == 1) e_tready = (xs32b() % 2) == 0;
    else begin
      if (stall_left > 0) begin e_tready = 1'b0; stall_left--; end
      else if (run_left > 0) begin e_tready = 1'b1; run_left--; end
      else begin stall_left = 20000; run_left = 1500; e_tready = 1'b0; end
    end
    // 2. handshake at the coming edge
    if (e_tvalid && e_tready) begin
      if (sop) begin
        ets = e_ts;
        if (e_has_time !== 1'b1 || e_tkeep !== 1'b1 || e_teov !== 1'b0 || e_teob !== 1'b0 || e_tlength === 16'd0 ||
            e_tlength % 24 != 0) begin
          n_axis_err++;
          $display("AXIS_ERROR cyc=%0d: sideband has_time=%0d tlength=%0d tkeep=%0d", cyc, e_has_time, e_tlength, e_tkeep);
        end
        $display("EVTPKT %h %0d", ets, int'(e_tlength) / 24);
        n_pkt++;
      end
      if (e_tlast !== (beat == 2 && rec_left == 1)) begin
        n_axis_err++;
        $display("AXIS_ERROR cyc=%0d: tlast=%0d on beat %0d with %0d records left", cyc, e_tlast, beat, rec_left);
      end
      ew[beat] = e_tdata;
      if (beat == 2) begin
        $display("EVT %h %h %h %h", ets, ew[0], ew[1], ew[2]);
        n_evt++;
        beat = 0;
        rec_left--;
        if (rec_left <= 0) begin
          tb_in_pkt = 0;
          lastpop_now = 1;
        end
      end else beat++;
      sop = 0;
    end
    // 3. framer rule for the coming edge (the DUT is idle now): the queue's head must have been there an edge ago
    //    and no record may have left at the previous edge; then start if n >= nbmax or the head waited >= FLUSH
    if (!rst && !e_tvalid && !lastpop_prev && pq.size() > 0 && pq[0] < ncyc - 1) begin
      if (pq.size() >= nbmax || ncyc - pq[0] >= int'(flush)) begin
        exp_start = 1;
        exp_n = (pq.size() >= nbmax) ? nbmax : pq.size();
        repeat (exp_n) void'(pq.pop_front());
      end
    end
    // 4. a record pushed into the FIFO at the coming edge
    if (!rst && dut.u_core.push) pq.push_back(ncyc);
    lastpop_prev = lastpop_now;
    last_valid = e_tvalid; last_ready = e_tready; last_data = e_tdata; last_tlast = e_tlast;
    last_ts = e_ts; last_len = e_tlength;
    ncyc++;
  end

  // ---------------------------------------------------------------- ctrlport master
  // two processes use the bus (main, and the EVT_EN switcher with priority): a lock, taken without a wait in between
  bit cp_busy = 0, cp_hp_req = 0;
  task automatic cp_acquire(input bit hp);
    if (hp) begin
      cp_hp_req = 1;
      while (cp_busy) @(negedge clk);
      cp_hp_req = 0;
    end else begin
      while (cp_busy || cp_hp_req) @(negedge clk);
    end
    cp_busy = 1;
  endtask
  task automatic cp_xfer(input bit wr, input logic [19:0] a, input logic [31:0] d, output logic [31:0] q);
    int to;
    @(negedge clk);
    if (wr) begin req_wr = 1; req_data = d; end
    else req_rd = 1;
    req_addr = a;
    @(negedge clk);
    req_wr = 0;
    req_rd = 0;
    to = 0;
    while (!resp_ack) begin
      @(negedge clk);
      to++;
      if (to > 50) $fatal(1, "ctrlport %s %h: no ack", wr ? "write" : "read", a);
    end
    q = resp_data;
  endtask
  task automatic cp_write(input logic [19:0] a, input logic [31:0] d, input bit hp = 0);
    logic [31:0] q;
    cp_acquire(hp);
    cp_xfer(1, a, d, q);
    cp_busy = 0;
  endtask
  task automatic cp_read(input logic [19:0] a, output logic [31:0] d);
    cp_acquire(0);
    cp_xfer(0, a, 32'd0, d);
    cp_busy = 0;
  endtask
  task automatic cp_read64(input logic [19:0] a, output logic [63:0] d);
    logic [31:0] lo, hi;
    cp_read(a, lo);
    cp_read(a + 20'h4, hi);
    d = {hi, lo};
  endtask

  // register map (rtl/x310/nsclf_core.sv)
  localparam logic [19:0] REG_ID = 20'h00, REG_VERSION = 20'h04, REG_BUILD = 20'h08, REG_LATENCY = 20'h0C,
      REG_CHAN = 20'h10, REG_K = 20'h14, REG_CTRL = 20'h18, REG_CUR = 20'h1C, REG_T_START_LO = 20'h20,
      REG_T_START_HI = 20'h24, REG_N = 20'h28, REG_ARM = 20'h2C, REG_STATUS = 20'h30, REG_WIN_COUNT = 20'h34,
      REG_MISR_LO = 20'h38, REG_CNT0 = 20'h40, REG_TFIRST_LO = 20'h50, REG_TLAST_LO = 20'h58,
      REG_EVT_DROP = 20'h60, REG_EVT_SEQ = 20'h64, REG_DEC_LO = 20'h68, REG_TIME_LO = 20'h70,
      REG_EVT_FLUSH = 20'h78, REG_EVT_CFG = 20'h7C, REG_EVT_PKTS = 20'h80;

  task automatic check(input string what, input logic [63:0] got, input logic [63:0] exp);
    if (got !== exp) begin
      errors++;
      $display("REG_MISMATCH %s got=%h exp=%h", what, got, exp);
    end
  endtask

  // ---------------------------------------------------------------- main
  int n_win_ok;
  initial begin
    logic [31:0] r;
    logic [63:0] r64, misr, tf, tl;
    logic [31:0] cnt, h[4], st;
    if (!$value$plusargs("STIM=%s", stim)) $fatal(1, "missing +STIM=");
    if (!$value$plusargs("SEED=%d", seed)) seed = 0;
    if (!$value$plusargs("CHAN=%d", chan)) chan = 0;
    if (!$value$plusargs("K=%d", kreg)) kreg = K_DEFAULT;
    if (!$value$plusargs("READY=%d", ready_mode)) ready_mode = 0;
    if (!$value$plusargs("NWIN=%d", nwin)) $fatal(1, "missing +NWIN=");
    if (!$value$plusargs("T0=%h", t0)) $fatal(1, "missing +T0=");
    if (!$value$plusargs("CORRUPT=%d", corrupt)) corrupt = 32'hFFFF_FFFF;
    if (!$value$plusargs("CORRUPT_WIN=%d", corrupt_win)) corrupt_win = 0;
    if (!$value$plusargs("REPLAY=%d", replay)) replay = 0;
    if (!$value$plusargs("NEVSW=%d", nevsw)) nevsw = 0;
    if (nevsw > NSWMAX) $fatal(1, "NEVSW %0d > %0d", nevsw, NSWMAX);
    flush_set = $value$plusargs("FLUSH=%d", flush);
    if (!flush_set) flush = EVT_FLUSH_DEFAULT;
    if ($value$plusargs("DUMP=%s", dump)) begin
      if (!replay) $fatal(1, "+DUMP= needs +REPLAY=1");
      dump_fd = $fopen(dump, "w");
      if (dump_fd == 0) $fatal(1, "cannot open dump file %s", dump);
    end
    $readmemh({stim, "/samples.hex"}, smem);
    $readmemh({stim, "/toff.hex"}, toff);
    if (!replay) $readmemh({stim, "/dec.hex"}, dmem);
    $readmemh({stim, "/windows.hex"}, wmem);
    if (nevsw != 0) $readmemh({stim, "/evten.hex"}, swmem);
    if (corrupt != 32'hFFFF_FFFF) $display("NEGATIVE CONTROL: expected word of decision %0d corrupted (bit 2)", corrupt);
    if (corrupt_win != 0) begin
      wmem[2][0] = ~wmem[2][0];
      $display("NEGATIVE CONTROL: expected MISR of window 0 corrupted (bit 0)");
    end
    rng = 32'h9E37_79B9 ^ (seed * 32'h0101_0101 + 1);
    rng2 = 32'h7F4A_7C15 ^ (seed * 32'h0001_0003 + 7);
    radio_time = t0 - 64'(GO_CYC);
    repeat (10) @(negedge clk);
    rst = 0;
    repeat (5) @(negedge clk);
    // identification and configuration
    cp_read(REG_ID, r);       check("ID", 64'(r), 64'h6E73_636C);
    cp_read(REG_VERSION, r);  check("VERSION", 64'(r), 64'h0002_0000);
    cp_read(REG_CTRL, r);     check("CTRL reset value (EVT_EN 0)", 64'(r), 64'd0);
    cp_read(REG_EVT_FLUSH, r); check("EVT_FLUSH reset value", 64'(r), 64'(EVT_FLUSH_DEFAULT));
    cp_read(REG_EVT_CFG, r);  check("EVT_CFG", 64'(r), 64'({8'd24, 4'd1, 4'd3, 8'(EVT_AW), 8'(EVT_BATCH)}));
    cp_read(REG_BUILD, r);    $display("BUILD %h", r);
    check("BUILD.CORE_LAT", 64'(r[15:8]), 64'(CORE_LAT));
    cp_read(REG_LATENCY, r);  check("LATENCY", 64'(r), 64'(L));
    $display("LATENCY register=%0d cycles (rx_data port -> decision valid)", r);
    cp_read(REG_K, r);        check("K reset value", 64'(r), 64'(K_DEFAULT));
    cp_write(REG_CTRL, 32'h3);
    cp_write(REG_CHAN, chan);
    cp_write(REG_K, kreg);
    cp_read(REG_CHAN, r);     check("CHAN", 64'(r), 64'(chan));
    cp_read(REG_K, r);        check("K", 64'(r), 64'(kreg));
    if (flush_set) begin
      cp_write(REG_EVT_FLUSH, flush);
      cp_read(REG_EVT_FLUSH, r); check("EVT_FLUSH", 64'(r), 64'(flush));
    end
    if (nevsw == 0) begin
      cp_write(REG_CTRL, 32'h4);
      cp_read(REG_CTRL, r);   check("CTRL EVT_EN", 64'(r), 64'h4);
    end
    $display("EVTCFG batch=%0d aw=%0d flush=%0d evt_en=%s", EVT_BATCH, EVT_AW, flush,
             nevsw == 0 ? "on" : $sformatf("%0d switches from 0", nevsw));
    if (cyc >= GO_CYC - 50) $fatal(1, "configuration too slow");
    go = 1;
    n_win_ok = 0;
    for (int wi = 0; wi < int'(nwin); wi++) begin
      logic [63:0] ts;
      logic [31:0] nn;
      bit last_win;
      ts = wmem[wi*10 + 0];
      nn = 32'(wmem[wi*10 + 1]);
      last_win = (wi == int'(nwin) - 1);
      if (seed != 0 && last_win) begin
        // late-arm check before the last window: a window whose start is already in the past
        logic [63:0] now;
        cp_read64(REG_TIME_LO, now);
        cp_write(REG_T_START_LO, 32'(now - 64'd500)); cp_write(REG_T_START_HI, 32'((now - 64'd500) >> 32));
        cp_write(REG_N, 32'd100);
        cp_write(REG_ARM, 32'h1);
        repeat (L + 40) @(negedge clk);
        cp_read(REG_STATUS, st);
        check("late-arm STATUS.late", 64'(st[3]), 64'd1);
        cp_write(REG_ARM, 32'h2);
        cp_read(REG_STATUS, st);
        check("disarm STATUS.armed", 64'(st[0]), 64'd0);
        $display("LATE_ARM status after arm=late, after disarm=%h", st);
      end
      if (radio_time >= ts) $fatal(1, "window %0d: T_start %h already passed (time %h): schedule too tight", wi, ts, radio_time);
      cp_write(REG_T_START_LO, ts[31:0]);
      cp_write(REG_T_START_HI, ts[63:32]);
      cp_write(REG_N, nn);
      cp_write(REG_ARM, 32'h1);
      // wait for done, or for the end of the stream (window reaching past the last decision)
      forever begin
        cp_read(REG_STATUS, st);
        if (st[2]) break;
        if (stream_done && n_dec == NDEC) begin
          repeat (20) @(negedge clk);
          cp_read(REG_STATUS, st);
          break;
        end
      end
      cp_read64(REG_MISR_LO, misr);
      cp_read(REG_WIN_COUNT, cnt);
      for (int c = 0; c < 4; c++) cp_read(REG_CNT0 + 20'(4*c), h[c]);
      cp_read64(REG_TFIRST_LO, tf);
      cp_read64(REG_TLAST_LO, tl);
      if (replay) begin
        n_win_ok++;
        $display("WINDOW %0d T_start=%h N=%0d status=%h misr=%h count=%0d hist=%0d,%0d,%0d,%0d tfirst=%h tlast=%h REPLAY",
                 wi, ts, nn, st, misr, cnt, h[0], h[1], h[2], h[3], tf, tl);
      end else begin
        int e0;
        e0 = errors;
        check($sformatf("win%0d MISR", wi), misr, wmem[wi*10 + 2]);
        check($sformatf("win%0d count", wi), 64'(cnt), wmem[wi*10 + 3]);
        for (int c = 0; c < 4; c++) check($sformatf("win%0d cnt%0d", wi, c), 64'(h[c]), wmem[wi*10 + 4 + c]);
        if (cnt != 0) begin
          check($sformatf("win%0d tfirst", wi), tf, wmem[wi*10 + 8]);
          check($sformatf("win%0d tlast", wi), tl, wmem[wi*10 + 9]);
        end
        check($sformatf("win%0d late", wi), 64'(st[3]), 64'd0);
        if (errors == e0) n_win_ok++;
        $display("WINDOW %0d T_start=%h N=%0d status=%h misr=%h count=%0d hist=%0d,%0d,%0d,%0d tfirst=%h tlast=%h %s",
                 wi, ts, nn, st, misr, cnt, h[0], h[1], h[2], h[3], tf, tl, errors == e0 ? "MATCH" : "MISMATCH");
      end
    end
    // end of stream: drain the events, read the counters
    wait (stream_done);
    repeat (L + 50) @(negedge clk);
    wait (sw_done);
    drain = 1;
    begin
      int idle;
      idle = 0;
      while (idle < int'(flush) + 300) begin
        @(negedge clk);
        idle = e_tvalid ? 0 : idle + 1;
      end
    end
    if (pq.size() != 0 || tb_in_pkt || exp_start) frm_err($sformatf("%0d records never left", pq.size()));
    begin
      logic [31:0] drop, sq, np;
      logic [63:0] nd, tnow;
      cp_read(REG_EVT_DROP, drop);
      cp_read(REG_EVT_SEQ, sq);
      cp_read(REG_EVT_PKTS, np);
      check("EVT_PKTS", 64'(np), 64'(n_pkt));
      cp_read64(REG_DEC_LO, nd);
      cp_read64(REG_TIME_LO, tnow);
      cp_read(REG_CUR, r);
      check("DEC count", nd, 64'(NDEC));
      if (tnow > radio_time || radio_time - tnow > 64'd20) begin
        errors++;
        $display("REG_MISMATCH TIME %h vs radio_time %h", tnow, radio_time);
      end
      $display("EVTREG drop=%0d seq=%0d pkts=%0d", drop, sq, np);
      $display("FRAMER packets=%0d full=%0d partial=%0d records=%0d framer_errors=%0d", n_pkt, n_full, n_part, n_evt, n_frm_err);
      $display("CUR %h", r);
    end
    $display("RESULT seed=%0d chan=%0d K=%0d ready=%0d flush=%0d samples=%0d decisions=%0d/%0d mismatches=%0d tau_mismatches=%0d latency_mismatches=%0d passthrough_mismatches=%0d windows=%0d/%0d events_received=%0d packets=%0d axis_errors=%0d framer_errors=%0d reg_errors=%0d cycles=%0d",
             seed, chan, kreg, ready_mode, flush, NS, n_dec, NDEC, n_dmis, n_tmis, n_lmis, n_pt, n_win_ok, nwin, n_evt, n_pkt, n_axis_err, n_frm_err, errors, cyc);
    if (n_dec != NDEC || n_dmis || n_tmis || n_lmis || n_pt || n_axis_err || n_frm_err || errors || n_win_ok != int'(nwin))
      $fatal(1, "FAIL");
    if (dump_fd != 0) $fclose(dump_fd);
    $display("PASS (in-tb checks; events checked by nsclf_model.py check-events)");
    $finish;
  end

  // ---------------------------------------------------------------- EVT_EN switches (evten.hex)
  // switch i: REG_CTRL = {EVT_EN = v, 2'b0} written when radio_time reaches t_sw + L + 1 - 4 (the change of a decision
  // with tau t is evaluated in the cycle with radio_time t + L + 1); the model picked t_sw with no change within
  // +/- 48 ticks, so the lock wait and the write's own latency (< 10 cycles) cannot matter
  bit sw_done = 0;
  initial begin
    wait (go);
    for (int i = 0; i < int'(nevsw); i++) begin
      logic [63:0] tsw;
      tsw = swmem[2*i];
      while (radio_time < tsw + 64'(L) + 64'd1 - 64'd4) @(negedge clk);
      cp_write(REG_CTRL, swmem[2*i + 1][0] ? 32'h4 : 32'h0, 1);
      $display("EVTEN_SWITCH %0d EVT_EN=%0d written at radio_time %h (t_sw %h)", i, swmem[2*i + 1][0], radio_time, tsw);
    end
    sw_done = 1;
  end

  initial begin
    #50ms $fatal(1, "timeout");
  end
endmodule
