//
// rfnoc_block_nsclf_tb: the whole nsclf block (rfnoc_block_nsclf = framework-generated noc_shell_nsclf +
// nsclf_user) in the UHD 4.9 RFNoC testbench flow (xsim, Vivado 2024.2), with UHD's RfnocBlockCtrlBfm on the
// AXIS-Ctrl and CHDR ports and three asynchronous clocks. Derived from the rfnoc_modtool template
// (.scratch/s5_nsclf/rfnoc-nsclfgen/.../rfnoc_block_nsclf_tb.sv); run by sw/x310/uhdsim/run_uhdsim.sh nsclf.
//
// What this adds to tb/tb_nsclf.sv (Verilator, below the noc_shell): the ctrlport path through
// ctrlport_endpoint (AXIS-Ctrl packets, rfnoc_ctrl_clk <-> radio_clk) and the event records as real CHDR
// packets out of axis_data_to_chdr (radio_clk -> rfnoc_chdr_clk), with the BFM's random back pressure.
// Stimulus: the golden stream as in tb_nsclf seed 0 (STIM_DIR: nsclf_model.py stim --seed 0 --t0 0xFFFFF000,
// one sample per radio_clk on channel 0, radio_time + 1 per clock, as on the X310).
// Checks: NOC ID, ports, MTU; ID / VERSION (2.0) / LATENCY / CTRL / EVT_FLUSH / EVT_CFG registers; the MISR window
// over the whole stream equals the model's; the host side enables events (REG_CTRL bit 2 EVT_EN, 0 at reset) before
// the stream; every CHDR event packet (2026-11 event revision: up to EVT_BATCH records of 3 words) has has_time,
// 24 x n payload bytes with 1 <= n <= EVT_BATCH and timestamp = word 0 of its first record; REG_EVT_PKTS = packets
// received; the decision count; then "EVTPKT <ts> <n>" + n "EVT ..." lines and "EVTREG ...", compared with the
// model's hysteresis (and the packet structure rules) by nsclf_model.py check-events.
//

`default_nettype none

module rfnoc_block_nsclf_tb #(
  parameter string STIM_DIR = "/home/cah/r2d2/code/fpga/opus_nsinfer/.scratch/nsclf_stim/lc2/seed0"
);

  `include "test_exec.svh"

  import PkgTestExec::*;
  import rfnoc_chdr_utils_pkg::*;
  import PkgChdrData::*;
  import PkgRfnocBlockCtrlBfm::*;
  import PkgRfnocItemUtils::*;

  localparam [31:0] NOC_ID          = 32'h4E53C1F0;
  localparam [ 9:0] THIS_PORTID     = 10'h123;
  localparam int    CHDR_W          = 64;
  localparam int    MTU             = 10;
  localparam int    NUM_PORTS       = 2;
  localparam int    NIPC            = 1;
  localparam int    CORE_LAT        = 18;   // rtl/gen/x310_clf_lc2/metadata.json latency + 1 (v2 model)
  localparam int    LC_X10          = 20;
  localparam int    IN_REG          = 1;
  localparam int    K_DEFAULT       = 16;
  localparam int    EVT_BATCH       = 16;   // nsclf_user defaults (not block parameters): batch, FIFO 2^6, flush 4096
  localparam int    EVT_AW          = 6;
  localparam int    EVT_FLUSH       = 4096;
  localparam int    NUM_PORTS_I     = 0;
  localparam int    NUM_PORTS_O     = 1;
  localparam int    ITEM_W          = 64;
  localparam int    STALL_PROB      = 25;
  localparam int    W               = 64;
  localparam int    NS              = 65536;
  localparam int    NDEC            = NS - W + 1;
  localparam int    L               = IN_REG + 1 + CORE_LAT + 1 + 1;
  localparam logic [63:0] T0        = 64'h0000_0000_FFFF_F000;

  // X310-like clocks: radio 200 MHz, CHDR (bus_clk) 187.5 MHz, ctrl 125 MHz (asynchronous to each other)
  localparam real   CHDR_CLK_PER    = 5.333;
  localparam real   CTRL_CLK_PER    = 8.0;
  localparam real   RADIO_CLK_PER   = 5.0;

  bit rfnoc_chdr_clk;
  bit rfnoc_ctrl_clk;
  bit radio_clk;

  sim_clock_gen #(CHDR_CLK_PER) rfnoc_chdr_clk_gen (.clk(rfnoc_chdr_clk), .rst());
  sim_clock_gen #(CTRL_CLK_PER) rfnoc_ctrl_clk_gen (.clk(rfnoc_ctrl_clk), .rst());
  sim_clock_gen #(RADIO_CLK_PER) radio_clk_gen (.clk(radio_clk), .rst());

  RfnocBackendIf        backend (rfnoc_chdr_clk, rfnoc_ctrl_clk);
  AxiStreamIf #(32)     m_ctrl  (rfnoc_ctrl_clk, 1'b0);
  AxiStreamIf #(32)     s_ctrl  (rfnoc_ctrl_clk, 1'b0);
  AxiStreamIf #(CHDR_W) s_chdr [NUM_PORTS_O] (rfnoc_chdr_clk, 1'b0);

  RfnocBlockCtrlBfm #(CHDR_W, ITEM_W) blk_ctrl = new(backend, m_ctrl, s_ctrl);

  typedef ChdrData #(CHDR_W, ITEM_W)::chdr_word_t chdr_word_t;

  for (genvar i = 0; i < NUM_PORTS_O; i++) begin : gen_bfm_output_connections
    initial begin
      blk_ctrl.connect_slave_data_port(i, s_chdr[i]);
      blk_ctrl.set_slave_stall_prob(i, STALL_PROB);
    end
  end

  logic [CHDR_W*NUM_PORTS_O-1:0] m_rfnoc_chdr_tdata;
  logic [       NUM_PORTS_O-1:0] m_rfnoc_chdr_tlast;
  logic [       NUM_PORTS_O-1:0] m_rfnoc_chdr_tvalid;
  logic [       NUM_PORTS_O-1:0] m_rfnoc_chdr_tready;
  assign s_chdr[0].tdata        = m_rfnoc_chdr_tdata;
  assign s_chdr[0].tlast        = m_rfnoc_chdr_tlast;
  assign s_chdr[0].tvalid       = m_rfnoc_chdr_tvalid;
  assign m_rfnoc_chdr_tready    = s_chdr[0].tready;

  // radio io ports
  logic [63:0] rx_data_in = '0, tx_data_out = '0, radio_time = T0 - 64'd100000;
  logic [1:0]  rx_stb_in = '0, tx_stb_in = '0, rx_running_out = '0, tx_running_out = '0;
  wire  [63:0] rx_data_out, tx_data_in;
  wire  [1:0]  rx_stb_out, tx_stb_out, rx_running_in, tx_running_in;

  rfnoc_block_nsclf #(
    .THIS_PORTID         (THIS_PORTID),
    .CHDR_W              (CHDR_W),
    .MTU                 (MTU),
    .NUM_PORTS           (NUM_PORTS),
    .NIPC                (NIPC),
    .CORE_LAT            (CORE_LAT),
    .LC_X10              (LC_X10),
    .IN_REG              (IN_REG),
    .K_DEFAULT           (K_DEFAULT)
  ) dut (
    .rfnoc_chdr_clk      (rfnoc_chdr_clk),
    .rfnoc_ctrl_clk      (rfnoc_ctrl_clk),
    .radio_clk           (radio_clk),
    .rfnoc_core_config   (backend.cfg),
    .rfnoc_core_status   (backend.sts),
    .s_rfnoc_chdr_tdata  (),
    .s_rfnoc_chdr_tlast  (),
    .s_rfnoc_chdr_tvalid (),
    .s_rfnoc_chdr_tready (),
    .m_rfnoc_chdr_tdata  (m_rfnoc_chdr_tdata),
    .m_rfnoc_chdr_tlast  (m_rfnoc_chdr_tlast),
    .m_rfnoc_chdr_tvalid (m_rfnoc_chdr_tvalid),
    .m_rfnoc_chdr_tready (m_rfnoc_chdr_tready),
    .s_rfnoc_ctrl_tdata  (m_ctrl.tdata),
    .s_rfnoc_ctrl_tlast  (m_ctrl.tlast),
    .s_rfnoc_ctrl_tvalid (m_ctrl.tvalid),
    .s_rfnoc_ctrl_tready (m_ctrl.tready),
    .m_rfnoc_ctrl_tdata  (s_ctrl.tdata),
    .m_rfnoc_ctrl_tlast  (s_ctrl.tlast),
    .m_rfnoc_ctrl_tvalid (s_ctrl.tvalid),
    .m_rfnoc_ctrl_tready (s_ctrl.tready),
    .radio_rx_data_in    (rx_data_in),
    .radio_rx_stb_in     (rx_stb_in),
    .radio_rx_running_in (rx_running_in),
    .radio_tx_data_in    (tx_data_in),
    .radio_tx_stb_in     (tx_stb_in),
    .radio_tx_running_in (tx_running_in),
    .radio_rx_data_out   (rx_data_out),
    .radio_rx_stb_out    (rx_stb_out),
    .radio_rx_running_out(rx_running_out),
    .radio_tx_data_out   (tx_data_out),
    .radio_tx_stb_out    (tx_stb_out),
    .radio_tx_running_out(tx_running_out),
    .radio_time          (radio_time)
  );

  //---------------------------------------------------------------------------
  // Radio side: golden stream on channel 0, one sample per clock, radio_time + 1 per clock
  //---------------------------------------------------------------------------

  logic [31:0] smem [NS];
  logic [63:0] wmem [10];
  bit          go_req = 0, go = 0, stream_done = 0;
  int          ks = 0, n_pt = 0;
  initial begin
    $readmemh({STIM_DIR, "/samples.hex"}, smem);
    $readmemh({STIM_DIR, "/windows.hex"}, wmem);
  end
  always @(negedge radio_clk) begin
    // pass-through check (outputs vs the inputs applied one negedge ago)
    if (rx_data_out !== rx_data_in || rx_stb_out !== rx_stb_in || tx_data_in !== tx_data_out ||
        tx_stb_out !== tx_stb_in || rx_running_in !== rx_running_out || tx_running_in !== tx_running_out) n_pt++;
    // radio_time + 1 per clock (as on the X310); it jumps to T0 when the stream starts (sample 0 at T0)
    radio_time <= (go_req && !go) ? T0 : radio_time + 64'd1;
    if (go_req) go <= 1;
    rx_data_in[63:32] <= $urandom;
    tx_data_out <= {$urandom, $urandom};
    tx_stb_in <= 2'($urandom);
    rx_running_out <= 2'($urandom);
    tx_running_out <= 2'($urandom);
    rx_stb_in[1] <= 1'b1;
    if (go_req && ks < NS) begin
      rx_data_in[31:0] <= smem[ks];
      rx_stb_in[0] <= 1'b1;
      ks <= ks + 1;
      if (ks == NS - 1) stream_done <= 1;
    end else begin
      rx_data_in[31:0] <= $urandom;
      rx_stb_in[0] <= 1'b0;            // no samples before / after the golden stream (so the counts are exact)
    end
  end

  //---------------------------------------------------------------------------
  // Main Test Process
  //---------------------------------------------------------------------------

  initial begin : tb_main
    logic [31:0] r, lo, hi, nevt, ndrop;
    chdr_word_t  data[$], md[$];
    int          nbytes, n_evt, n_pkt, nrec;
    packet_info_t pi;

    test.start_tb("rfnoc_block_nsclf_tb");
    blk_ctrl.run();

    test.start_test("Flush block then reset it", 10us);
    blk_ctrl.flush_and_reset();
    test.end_test();

    test.start_test("Verify Block Info", 2us);
    `ASSERT_ERROR(blk_ctrl.get_noc_id() == NOC_ID, "Incorrect NOC_ID Value");
    `ASSERT_ERROR(blk_ctrl.get_num_data_i() == NUM_PORTS_I, "Incorrect NUM_DATA_I Value");
    `ASSERT_ERROR(blk_ctrl.get_num_data_o() == NUM_PORTS_O, "Incorrect NUM_DATA_O Value");
    `ASSERT_ERROR(blk_ctrl.get_mtu() == MTU, "Incorrect MTU Value");
    test.end_test();

    test.start_test("Registers over AXIS-Ctrl / ctrlport_endpoint", 50us);
    blk_ctrl.reg_read(20'h00, r);
    `ASSERT_ERROR(r == 32'h6E73636C, $sformatf("REG_ID %h", r));
    blk_ctrl.reg_read(20'h04, r);
    `ASSERT_ERROR(r == 32'h00020000, $sformatf("REG_VERSION %h", r));
    blk_ctrl.reg_read(20'h18, r);
    `ASSERT_ERROR(r == 32'h0, $sformatf("REG_CTRL at reset %h (EVT_EN must be 0)", r));
    blk_ctrl.reg_read(20'h78, r);
    `ASSERT_ERROR(r == EVT_FLUSH, $sformatf("REG_EVT_FLUSH at reset %0d", r));
    blk_ctrl.reg_read(20'h7C, r);
    `ASSERT_ERROR(r == {8'd24, 4'd1, 4'd3, 8'(EVT_AW), 8'(EVT_BATCH)}, $sformatf("REG_EVT_CFG %h", r));
    blk_ctrl.reg_read(20'h0C, r);
    `ASSERT_ERROR(r == L, $sformatf("REG_LATENCY %0d", r));
    $display("REGS ID/VERSION/CTRL/EVT_FLUSH/EVT_CFG ok");
    blk_ctrl.reg_read(20'h0C, r);
    $display("REGS LATENCY=%0d", r);
    blk_ctrl.reg_read(20'h14, r);
    `ASSERT_ERROR(r == K_DEFAULT, $sformatf("REG_K %0d", r));
    blk_ctrl.reg_write(20'h10, 0);                      // CHAN 0 (restarts the window)
    blk_ctrl.reg_write(20'h18, 32'h4);                  // EVT_EN = 1 (as the host tools do after setting K)
    blk_ctrl.reg_read(20'h18, r);
    `ASSERT_ERROR(r == 32'h4, $sformatf("REG_CTRL after EVT_EN %h", r));
    // MISR window = the model's seed-0 window (the whole stream)
    blk_ctrl.reg_write(20'h20, wmem[0][31:0]);
    blk_ctrl.reg_write(20'h24, wmem[0][63:32]);
    blk_ctrl.reg_write(20'h28, wmem[1][31:0]);
    blk_ctrl.reg_write(20'h2C, 1);
    blk_ctrl.reg_read(20'h30, r);
    `ASSERT_ERROR(r[0] == 1'b1, $sformatf("STATUS after arm %h", r));
    test.end_test();

    test.start_test("Golden stream: events over CHDR, MISR", 2ms);
    @(negedge radio_clk);
    go_req = 1;                // the driver puts sample 0 on the port with radio_time = T0 at its next negedge
    n_evt = 0;
    n_pkt = 0;
    fork
      begin : rx_events
        forever begin
          blk_ctrl.recv_adv(0, data, nbytes, md, pi);
          nrec = nbytes / 24;
          `ASSERT_ERROR(nbytes % 24 == 0 && nrec >= 1 && nrec <= EVT_BATCH,
                        $sformatf("event packet %0d: %0d payload bytes", n_pkt, nbytes));
          `ASSERT_ERROR(data.size() == 3 * nrec, $sformatf("event packet %0d: %0d words for %0d bytes", n_pkt, data.size(), nbytes));
          `ASSERT_ERROR(pi.has_time == 1, "event packet without timestamp");
          `ASSERT_ERROR(pi.timestamp == data[0], $sformatf("CHDR timestamp %h != word 0 %h", pi.timestamp, data[0]));
          $display("EVTPKT %h %0d", pi.timestamp, nrec);
          for (int k = 0; k < nrec; k++) begin
            $display("EVT %h %h %h %h", pi.timestamp, data[3*k], data[3*k + 1], data[3*k + 2]);
            n_evt++;
          end
          n_pkt++;
        end
      end
      begin : wait_stream
        wait (stream_done);
        repeat (L + 2000 + EVT_FLUSH) @(negedge radio_clk);   // the last packet closes after EVT_FLUSH cycles
      end
    join_any
    disable rx_events;
    blk_ctrl.reg_read(20'h38, lo);
    blk_ctrl.reg_read(20'h3C, hi);
    $display("MISR got=%h exp=%h", {hi, lo}, wmem[2]);
    `ASSERT_ERROR({hi, lo} == wmem[2], "MISR mismatch");
    blk_ctrl.reg_read(20'h34, r);
    `ASSERT_ERROR(r == wmem[3][31:0], $sformatf("window count %0d", r));
    blk_ctrl.reg_read(20'h68, lo);
    blk_ctrl.reg_read(20'h6C, hi);
    `ASSERT_ERROR({hi, lo} == NDEC, $sformatf("decision count %0d", {hi, lo}));
    blk_ctrl.reg_read(20'h60, ndrop);
    blk_ctrl.reg_read(20'h64, nevt);
    `ASSERT_ERROR(n_evt + ndrop == nevt, $sformatf("events received %0d + dropped %0d != generated %0d", n_evt, ndrop, nevt));
    blk_ctrl.reg_read(20'h80, r);
    `ASSERT_ERROR(r == n_pkt, $sformatf("REG_EVT_PKTS %0d != packets received %0d", r, n_pkt));
    `ASSERT_ERROR(n_pt == 0, $sformatf("%0d pass-through mismatches", n_pt));
    $display("EVTREG drop=%0d seq=%0d pkts=%0d", ndrop, nevt, r);
    $display("RESULT uhd_flow decisions=%0d misr=%h events_received=%0d packets=%0d passthrough_mismatches=%0d", {hi, lo}, wmem[2], n_evt, n_pkt, n_pt);
    test.end_test();

    test.end_tb();
  end : tb_main

endmodule : rfnoc_block_nsclf_tb

`default_nettype wire
