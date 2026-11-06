// nsclf_core: the Stage 5 classifier tap inside the X310 image (PLAN.md D-S5-TAP, D-S5-OUT).
//
// One clock (radio_clk, 200 MHz on the X310) for everything here; the only clock crossings of the block
// are the framework's noc_shell ones (ctrlport_endpoint, axis_data_to_chdr). Definitions, register map
// and the measured latencies are in evidence/stage5/block/README.md. Summary:
//
//   rx_data/rx_stb (radio0 io_port, after fe_control) -> channel select (REG_CHAN) -> IN_REG register
//     -> x310_stream (W-sample shift register, BFP, da4ml core, argmax; one decision per sample, II = 1)
//   tap time of a sample  = the radio_time value in the clock cycle in which the sample is on rx_data with
//                           rx_stb high (the same cycle relation the stock radio uses to timestamp it, before
//                           its own complex-gain pipeline: README section 3)
//   tau(decision)         = tap time of the NEWEST sample of the decision's window
//   L (REG_LATENCY)       = IN_REG + 1 + CORE_LAT + 1 + BFP_PIPE cycles: a sample on rx_data in cycle c gives
//                           its window's decision (cls, logits valid) in cycle c + L; tau comes from an
//                           L-cycle delay line of radio_time, so time jumps and stb gaps cannot misalign it.
//   MISR window           = decisions with T_start <= tau <= T_start + N - 1 (REG_T_START, REG_N, REG_ARM):
//                           64-bit MISR over {logits, cls}, per-class counts, count, first and last tau
//   hysteresis            = the smoothed class changes to c at the K-th consecutive raw decision c != current;
//                           with EVT_EN (REG_CTRL bit 2, 0 at reset) each change is one event record (3 x 64-bit
//                           words) pushed to a 2^EVT_AW-entry FIFO; a full FIFO drops the record and counts it
//                           (REG_EVT_DROP). With EVT_EN = 0 the hysteresis runs, but no record and no EVT_SEQ step.
//   event packets         = (2026-11, event revision) up to EVT_BATCH records per CHDR packet, CHDR timestamp = the
//                           first record's tau, tlength = 24 x n bytes. A packet starts when the FIFO holds
//                           EVT_BATCH records, or when its oldest record has waited REG_EVT_FLUSH cycles
//                           (EVT_FLUSH = 0: one record per packet, the v1 format). README section 5a.
`timescale 1ns / 1ps
`default_nettype none

module nsclf_core #(
    parameter int NUM_PORTS = 2,
    parameter int W         = 64,
    parameter int OUT_W     = 62,
    parameter int CORE_LAT  = 15,
    parameter int BFP_PIPE  = 1,
    parameter int IN_REG    = 1,
    parameter int LC_X10    = 20,
    parameter int K_DEFAULT = 16,
    parameter int EVT_AW    = 6,       // event FIFO 2^EVT_AW records (64 = 4 full batches)
    parameter int EVT_BATCH = 16,      // records per CHDR packet at most (16 x 24 B = 384 B payload)
    parameter int EVT_FLUSH_DEFAULT = 4096   // REG_EVT_FLUSH at reset: 4096 cycles = 20.5 us at 200 MHz
) (
    input  wire                     clk,
    input  wire                     rst,
    // tap (radio0 io_port, device side)
    input  wire  [32*NUM_PORTS-1:0] rx_data,
    input  wire  [NUM_PORTS-1:0]    rx_stb,
    input  wire  [63:0]             radio_time,
    // ctrlport slave (noc_shell's m_ctrlport_*)
    input  wire                     req_wr,
    input  wire                     req_rd,
    input  wire  [19:0]             req_addr,
    input  wire  [31:0]             req_data,
    output logic                    resp_ack,
    output logic [31:0]             resp_data,
    // event records (noc_shell's s_evt_axis_*)
    output logic [63:0]             evt_tdata,
    output logic                    evt_tkeep,
    output logic                    evt_tlast,
    output logic                    evt_tvalid,
    input  wire                     evt_tready,
    output logic [63:0]             evt_ttimestamp,
    output logic                    evt_thas_time,
    output logic [15:0]             evt_tlength,
    output logic                    evt_teov,
    output logic                    evt_teob
);
  localparam int LAT  = CORE_LAT + 1 + BFP_PIPE;   // x310_clf_top: in_vld -> out_vld
  localparam int L    = IN_REG + 1 + LAT;          // rx_data port -> decision valid
  localparam int CH_W = (NUM_PORTS > 1) ? $clog2(NUM_PORTS) : 1;
  localparam logic [31:0] ID      = 32'h6E73_636C;  // "nscl"
  localparam logic [31:0] VERSION = 32'h0002_0000;  // 2.0 (2026-11 event revision: EVT_EN, batched packets)
  localparam logic [63:0] MISR_POLY = 64'hB000_0000_0000_0001;  // x^64 + x^63 + x^61 + x^60 + 1
  localparam logic [63:0] MISR_SEED = '1;

  // register addresses (bytes)
  localparam logic [19:0] REG_ID = 20'h00, REG_VERSION = 20'h04, REG_BUILD = 20'h08, REG_LATENCY = 20'h0C,
      REG_CHAN = 20'h10, REG_K = 20'h14, REG_CTRL = 20'h18, REG_CUR = 20'h1C,
      REG_T_START_LO = 20'h20, REG_T_START_HI = 20'h24, REG_N = 20'h28, REG_ARM = 20'h2C,
      REG_STATUS = 20'h30, REG_WIN_COUNT = 20'h34, REG_MISR_LO = 20'h38, REG_MISR_HI = 20'h3C,
      REG_CNT0 = 20'h40, REG_CNT1 = 20'h44, REG_CNT2 = 20'h48, REG_CNT3 = 20'h4C,
      REG_TFIRST_LO = 20'h50, REG_TFIRST_HI = 20'h54, REG_TLAST_LO = 20'h58, REG_TLAST_HI = 20'h5C,
      REG_EVT_DROP = 20'h60, REG_EVT_SEQ = 20'h64, REG_DEC_LO = 20'h68, REG_DEC_HI = 20'h6C,
      REG_TIME_LO = 20'h70, REG_TIME_HI = 20'h74,
      REG_EVT_FLUSH = 20'h78, REG_EVT_CFG = 20'h7C, REG_EVT_PKTS = 20'h80;   // 2026-11 event revision
  localparam int FW = 24;                         // REG_EVT_FLUSH / record wait-time width (cycles)
  localparam int BW = $clog2(EVT_BATCH + 1);      // records-per-packet counter width

  if (OUT_W + 2 > 126) begin : g_bad
    $error("nsclf_core: the MISR word {logits, cls} must fit 126 bits");
  end
  if (EVT_BATCH < 1 || EVT_BATCH > 255 || EVT_BATCH > (1 << EVT_AW) || EVT_BATCH * 24 > 65535) begin : g_bad_batch
    $error("nsclf_core: EVT_BATCH must be 1..255, <= the FIFO depth 2^EVT_AW, and 24 x EVT_BATCH must fit tlength");
  end

  // ------------------------------------------------------------------------------------- control registers
  logic [CH_W-1:0] reg_chan;
  logic [15:0]     reg_k;
  logic [63:0]     reg_t_start;
  logic [31:0]     reg_n;
  logic            restart;        // channel changed: restart the window (pulse)
  logic            arm_p, disarm_p, hyst_clr_p, cnt_clr_p;
  logic            reg_evt_en;     // REG_CTRL bit 2: event records on (reset 0)
  logic [FW-1:0]   reg_evt_flush;  // REG_EVT_FLUSH: packet close timeout in cycles (0: one record per packet)

  // ------------------------------------------------------------------------------------- tap
  wire [31:0] sel_data = rx_data[32*reg_chan +: 32];
  wire        sel_stb  = rx_stb[reg_chan];
  logic [31:0] s_data;
  logic        s_vld;
  if (IN_REG != 0) begin : g_inreg
    always_ff @(posedge clk) begin
      s_data <= sel_data;
      s_vld  <= rst ? 1'b0 : sel_stb;
    end
  end else begin : g_noreg
    assign s_data = sel_data;
    assign s_vld  = sel_stb;
  end

  // sc16 item at the radio port: I in [31:16], Q in [15:0] (fe_control.v); x310_stream lane 2k = I_k
  wire [OUT_W-1:0] logits;
  wire [1:0]       cls;
  wire             dvld;
  x310_stream #(.W(W), .OUT_W(OUT_W), .CORE_LAT(CORE_LAT), .BFP_PIPE(BFP_PIPE)) u_stream (
      .clk(clk), .rst(rst | restart), .in_i(s_data[31:16]), .in_q(s_data[15:0]), .in_vld(s_vld),
      .logits(logits), .cls(cls), .out_vld(dvld));

  // MISR data word: {logits, cls}, folded to 64 bits when wider (OUT_W > 62, the v2 core: 65): bits 64.. are
  // XORed into the top bits, so cls stays in [1:0] (sw/x310/nsclf_model.py dec_word)
  localparam int DW = OUT_W + 2;
  wire [127:0] dfull = 128'({logits, cls});
  wire [63:0]  dword;
  if (DW > 64) begin : g_fold
    assign dword = dfull[63:0] ^ (dfull[127:64] << (128 - DW));
  end else begin : g_nofold
    assign dword = dfull[63:0];
  end

  // tau: radio_time delayed by L cycles (the cycle in which the window's newest sample was on rx_data)
  logic [63:0] tdl[L];
  always_ff @(posedge clk) begin
    tdl[0] <= radio_time;
    for (int i = 1; i < L; i++) tdl[i] <= tdl[i-1];
  end
  wire [63:0] tau = tdl[L-1];

  // ------------------------------------------------------------------------------------- stage 1: register + compares
  typedef enum logic [1:0] {W_IDLE, W_ARMING, W_ARMED, W_DONE} wstate_t;
  wstate_t     wst;
  logic [63:0] t_start_l, t_last_l;   // latched at arm
  logic        d1_v, d1_ge, d1_le, d1_gelast;
  logic [63:0] d1_tau, d1_word;
  logic [1:0]  d1_cls;
  always_ff @(posedge clk) begin
    d1_v      <= rst ? 1'b0 : dvld;
    d1_tau    <= tau;
    d1_cls    <= cls;
    d1_word   <= dword;
    d1_ge     <= (tau >= t_start_l);
    d1_le     <= (tau <= t_last_l);
    d1_gelast <= (tau >= t_last_l);
  end

  // ------------------------------------------------------------------------------------- stage 2: window (MISR)
  logic [63:0] misr, tfirst, tlast;
  logic [31:0] wcount, hist[4];
  logic        late;
  // tau of the last decision processed (window active or not): a window is LATE if a decision with
  // tau >= T_start went by before it became active (those decisions are missing from its MISR)
  logic [63:0] last_tau;
  logic        any_dec;
  always_ff @(posedge clk) begin
    if (rst) any_dec <= 1'b0;
    else if (d1_v) any_dec <= 1'b1;
    if (d1_v) last_tau <= d1_tau;
  end
  always_ff @(posedge clk) begin
    if (rst) begin
      wst <= W_IDLE;
      late <= 1'b0;
      misr <= MISR_SEED;
      wcount <= '0;
      for (int c = 0; c < 4; c++) hist[c] <= '0;
      tfirst <= '0;
      tlast <= '0;
      t_start_l <= '1;
      t_last_l <= '0;
    end else if (arm_p) begin
      // the window registers are latched now; stage-1 compares use them from the next cycle on, so the
      // decision in stage 2 during W_ARMING (compared against the old values) is not counted
      wst <= W_ARMING;
      t_start_l <= reg_t_start;
      t_last_l <= reg_t_start + 64'(reg_n) - 64'd1;
      late <= 1'b0;
      misr <= MISR_SEED;
      wcount <= '0;
      for (int c = 0; c < 4; c++) hist[c] <= '0;
      tfirst <= '0;
      tlast <= '0;
    end else if (disarm_p) begin
      wst <= W_IDLE;
    end else begin
      if (wst == W_ARMING) begin
        // last_tau: decisions processed before this cycle; d1: the one not counted in this cycle
        wst <= W_ARMED;
        late <= (any_dec && last_tau >= t_start_l) || (d1_v && d1_tau >= t_start_l);
      end
      if (wst == W_ARMED && d1_v) begin
        if (d1_ge && d1_le) begin
          misr <= {misr[62:0], 1'b0} ^ (misr[63] ? MISR_POLY : 64'd0) ^ d1_word;
          wcount <= wcount + 1'b1;
          hist[d1_cls] <= hist[d1_cls] + 1'b1;
          if (wcount == 0) tfirst <= d1_tau;
          tlast <= d1_tau;
        end
        if (d1_gelast) wst <= W_DONE;
      end
    end
  end

  // ------------------------------------------------------------------------------------- stage 2: hysteresis
  logic [1:0]  cur, cand, raw_last;
  logic [15:0] hcnt;
  logic [31:0] run;
  logic [63:0] dec_cnt;
  logic [31:0] ev_seq, ev_drop;
  logic        ev_v;
  logic [63:0] ev_tau;
  logic [1:0]  ev_new, ev_old;
  logic [15:0] ev_k;
  logic [31:0] ev_run, ev_sq;
  wire  [15:0] keff = (reg_k == 16'd0) ? 16'd1 : reg_k;
  wire  [15:0] ncnt = (d1_cls == cand && hcnt != 16'd0) ? hcnt + 16'd1 : 16'd1;
  wire         chg  = d1_v && (d1_cls != cur) && (ncnt >= keff);
  wire  [31:0] run_inc = (run == 32'hFFFF_FFFF) ? run : run + 32'd1;
  // an event is generated (EVT_SEQ step, record queued or dropped) only while EVT_EN = 1; a hysteresis reset in the
  // same cycle wins (the state goes to class 0, the change does not happen)
  wire         ev_gen = chg && reg_evt_en && !hyst_clr_p;
  always_ff @(posedge clk) begin
    ev_v <= 1'b0;
    if (rst || hyst_clr_p) begin
      cur <= 2'd0;
      cand <= 2'd0;
      hcnt <= '0;
      run <= '0;
    end else if (d1_v) begin
      if (d1_cls == cur) begin
        hcnt <= '0;
        run <= run_inc;
      end else if (chg) begin
        cur <= d1_cls;
        hcnt <= '0;
        run <= 32'd1;
      end else begin
        cand <= d1_cls;
        hcnt <= ncnt;
        run <= run_inc;
      end
    end
    if (!rst && ev_gen) begin
      ev_v   <= 1'b1;
      ev_tau <= d1_tau;
      ev_new <= d1_cls;
      ev_old <= cur;
      ev_k   <= keff;
      ev_run <= run;
      ev_sq  <= ev_seq;
    end
    if (rst) raw_last <= 2'd0;
    else if (d1_v) raw_last <= d1_cls;
  end
  always_ff @(posedge clk) begin
    if (rst) dec_cnt <= '0;
    else if (d1_v) dec_cnt <= dec_cnt + 64'd1;
  end

  // ------------------------------------------------------------------------------------- event FIFO + framer
  // FIFO entry: the record fields + the low FW bits of (cycle counter at push) - 1, so that age_ge (registered) tells
  // whether the head has waited >= REG_EVT_FLUSH cycles at the next clock edge.
  localparam int EW = 64 + 32 + 16 + 2 + 2 + 32 + 32;   // tau, run, k, old, new, seq, drops
  localparam int DEPTH = 1 << EVT_AW;
  logic [EW+FW-1:0] fifo[DEPTH];
  logic [EVT_AW:0]  wp, rp;
  logic [FW-1:0]    cyc_ctr;
  wire  [EVT_AW:0]  occ   = wp - rp;
  wire              full  = occ == (EVT_AW + 1)'(DEPTH);
  wire              push  = ev_v && !full;
  logic [31:0]      ev_pkts;
  always_ff @(posedge clk) begin
    if (rst || cnt_clr_p) begin
      ev_seq  <= '0;
      ev_drop <= '0;
    end else begin
      if (ev_gen) ev_seq <= ev_seq + 32'd1;
      if (ev_v && full) ev_drop <= ev_drop + 32'd1;
    end
    if (push) fifo[wp[EVT_AW-1:0]] <= {ev_tau, ev_run, ev_k, ev_old, ev_new, ev_sq, ev_drop, cyc_ctr - FW'(1)};
  end
  wire [EW+FW-1:0] head = fifo[rp[EVT_AW-1:0]];
  wire [63:0]   h_tau   = head[EW+FW-1 -: 64];
  wire [31:0]   h_run   = head[EW+FW-65 -: 32];
  wire [15:0]   h_k     = head[EW+FW-97 -: 16];
  wire [1:0]    h_old   = head[EW+FW-113 -: 2];
  wire [1:0]    h_new   = head[EW+FW-115 -: 2];
  wire [31:0]   h_seq   = head[FW+63 -: 32];
  wire [31:0]   h_drop  = head[FW+31 -: 32];
  wire [FW-1:0] h_stamp = head[FW-1:0];

  // Framer. A packet of n records goes out as 3n beats, tlast on the last; tlength (24 n) and the timestamp (first
  // record's tau) are valid from the first beat on (noc_shell samples the sideband at the start of a packet,
  // SIDEBAND_AT_END 0). Start rule, evaluated at a clock edge while no packet is open:
  //   hv     the FIFO was not empty at the previous edge and no record left at it (so the head is the same one
  //          age_ge was computed for),
  //   start  = hv && (occ >= nbmax || age_ge),  n = min(occ, nbmax),  nbmax = EVT_FLUSH == 0 ? 1 : EVT_BATCH,
  //   age_ge = the head has waited >= EVT_FLUSH cycles since its push edge (FW-bit arithmetic: a head that waits
  //            more than 2^FW cycles behind a stalled packet can be delayed by up to EVT_FLUSH more cycles).
  // tb/tb_nsclf.sv checks this rule cycle by cycle from the outside (pushes and AXIS handshakes only).
  logic          inpkt, hv, age_ge, nb1;
  logic [1:0]    beat;
  logic [BW-1:0] nrem, pkt_n;
  wire  [7:0]    nbmax  = nb1 ? 8'd1 : 8'(EVT_BATCH);
  wire  [7:0]    occ8   = 8'(occ);
  wire           start  = !inpkt && hv && (occ8 >= nbmax || age_ge);
  wire  [BW-1:0] nstart = (occ8 >= nbmax) ? BW'(nbmax) : BW'(occ8);
  wire           pop    = inpkt && evt_tready && beat == 2'd2;   // a record's last beat accepted
  wire           pkt_end = pop && nrem == BW'(1);
  always_ff @(posedge clk) begin
    nb1    <= (reg_evt_flush == '0);
    age_ge <= (cyc_ctr - h_stamp) >= reg_evt_flush;
    if (rst) begin
      wp <= '0;
      rp <= '0;
      beat <= '0;
      inpkt <= 1'b0;
      hv <= 1'b0;
      nrem <= '0;
      pkt_n <= '0;
      cyc_ctr <= '0;
    end else begin
      cyc_ctr <= cyc_ctr + FW'(1);
      hv <= (occ != '0) && !pop;
      if (push) wp <= wp + 1'b1;
      if (start) begin
        inpkt <= 1'b1;
        beat <= '0;
        nrem <= nstart;
        pkt_n <= nstart;
      end else if (inpkt && evt_tready) begin
        if (beat == 2'd2) begin
          beat <= '0;
          rp <= rp + 1'b1;
          if (nrem == BW'(1)) inpkt <= 1'b0;
          nrem <= nrem - BW'(1);
        end else beat <= beat + 1'b1;
      end
    end
  end
  always_ff @(posedge clk) begin
    if (rst || cnt_clr_p) ev_pkts <= '0;
    else if (pkt_end) ev_pkts <= ev_pkts + 32'd1;
  end
  always_comb begin
    evt_tvalid     = inpkt;
    evt_tlast      = (beat == 2'd2) && (nrem == BW'(1));
    evt_tkeep      = 1'b1;
    evt_ttimestamp = h_tau;
    evt_thas_time  = 1'b1;
    evt_tlength    = 16'(24 * int'(pkt_n));
    evt_teov       = 1'b0;
    evt_teob       = 1'b0;
    case (beat)
      2'd0:    evt_tdata = h_tau;
      2'd1:    evt_tdata = {h_run, h_k, 4'd0, 4'd1, 2'd0, h_old, 2'd0, h_new};
      default: evt_tdata = {h_seq, h_drop};
    endcase
  end

  // ------------------------------------------------------------------------------------- ctrlport
  logic [31:0] dec_hi_sh, time_hi_sh;
  wire  [31:0] status = {28'd0, late, wst == W_DONE, wcount != 0, wst == W_ARMING || wst == W_ARMED};
  always_ff @(posedge clk) begin
    restart <= 1'b0;
    arm_p <= 1'b0;
    disarm_p <= 1'b0;
    hyst_clr_p <= 1'b0;
    cnt_clr_p <= 1'b0;
    resp_ack <= 1'b0;
    if (rst) begin
      reg_chan <= '0;
      reg_k <= 16'(K_DEFAULT);
      reg_t_start <= '0;
      reg_n <= '0;
      reg_evt_en <= 1'b0;
      reg_evt_flush <= FW'(EVT_FLUSH_DEFAULT);
      resp_data <= '0;
      dec_hi_sh <= '0;
      time_hi_sh <= '0;
    end else begin
      if (req_wr) begin
        resp_ack <= 1'b1;
        case (req_addr)
          REG_CHAN: begin
            reg_chan <= CH_W'(req_data);
            restart <= 1'b1;
          end
          REG_K: reg_k <= req_data[15:0];
          REG_CTRL: begin
            hyst_clr_p <= req_data[0];
            cnt_clr_p <= req_data[1];
            reg_evt_en <= req_data[2];
          end
          REG_EVT_FLUSH: reg_evt_flush <= req_data[FW-1:0];
          REG_T_START_LO: reg_t_start[31:0] <= req_data;
          REG_T_START_HI: reg_t_start[63:32] <= req_data;
          REG_N: reg_n <= req_data;
          REG_ARM: begin
            arm_p <= req_data[0];
            disarm_p <= req_data[1] & ~req_data[0];
          end
          default: ;
        endcase
      end
      if (req_rd) begin
        resp_ack <= 1'b1;
        case (req_addr)
          REG_ID:         resp_data <= ID;
          REG_VERSION:    resp_data <= VERSION;
          REG_BUILD:      resp_data <= {8'(LC_X10), 8'(W), 8'(CORE_LAT), 4'(IN_REG), 4'(BFP_PIPE)};
          REG_LATENCY:    resp_data <= 32'(L);
          REG_CHAN:       resp_data <= 32'(reg_chan);
          REG_K:          resp_data <= {16'd0, reg_k};
          REG_CTRL:       resp_data <= {29'd0, reg_evt_en, 2'd0};
          REG_CUR:        resp_data <= {hcnt, 6'd0, cand, 2'd0, raw_last, 2'd0, cur};
          REG_T_START_LO: resp_data <= reg_t_start[31:0];
          REG_T_START_HI: resp_data <= reg_t_start[63:32];
          REG_N:          resp_data <= reg_n;
          REG_STATUS:     resp_data <= status;
          REG_WIN_COUNT:  resp_data <= wcount;
          REG_MISR_LO:    resp_data <= misr[31:0];
          REG_MISR_HI:    resp_data <= misr[63:32];
          REG_CNT0:       resp_data <= hist[0];
          REG_CNT1:       resp_data <= hist[1];
          REG_CNT2:       resp_data <= hist[2];
          REG_CNT3:       resp_data <= hist[3];
          REG_TFIRST_LO:  resp_data <= tfirst[31:0];
          REG_TFIRST_HI:  resp_data <= tfirst[63:32];
          REG_TLAST_LO:   resp_data <= tlast[31:0];
          REG_TLAST_HI:   resp_data <= tlast[63:32];
          REG_EVT_DROP:   resp_data <= ev_drop;
          REG_EVT_SEQ:    resp_data <= ev_seq;
          REG_DEC_LO: begin
            resp_data <= dec_cnt[31:0];
            dec_hi_sh <= dec_cnt[63:32];
          end
          REG_DEC_HI:     resp_data <= dec_hi_sh;
          REG_TIME_LO: begin
            resp_data <= radio_time[31:0];
            time_hi_sh <= radio_time[63:32];
          end
          REG_TIME_HI:    resp_data <= time_hi_sh;
          REG_EVT_FLUSH:  resp_data <= 32'(reg_evt_flush);
          REG_EVT_CFG:    resp_data <= {8'(FW), 4'd1, 4'd3, 8'(EVT_AW), 8'(EVT_BATCH)};
          REG_EVT_PKTS:   resp_data <= ev_pkts;
          default:        resp_data <= 32'h0;
        endcase
      end
    end
  end
endmodule

`default_nettype wire
