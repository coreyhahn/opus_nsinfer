// tb_radio_ts: which radio_time does the stock UHD 4.9 radio put on the packet that carries a given sample?
//
// DUT: UHD's own radio_core (lib/rfnoc/blocks/rfnoc_block_radio/radio_core.v, .scratch/uhd at a5d1b2e) with the
// X310 image's settings: SAMP_W = 32, NSPC = 1, EN_COMP_GAIN_TX/RX = EN_CG (radio0 in x310_XG: 1). As on the X310,
// radio_rx_stb is 1 on every clock and radio_time counts up by 1 per clock (bus_int.v timekeeper, TIME_INCREMENT 1,
// sample_rx_stb 1). Every sample is tagged with its own tap time: radio_rx_data = radio_time[31:0] of the cycle it
// is on the port (the same port and radio_time the nsclf block sees). A timed finite RX command (REG_RX_CMD) at
// CMD_TIME for NW words, MAX_WORDS_PER_PKT = SPP; m_axis_tready = 1 (no back pressure).
// Checks, every word of every packet: data == ttimestamp_of_packet + k - OFFSET_EXP, i.e. the sample stamped with
// time T (host timestamp) was on the radio port at radio_time T - OFFSET_EXP. Also the first packet's timestamp
// must equal CMD_TIME. Drive and sample at negedge; any failure -> $fatal(1).
`timescale 1ns / 1ps

module tb_radio_ts #(
    parameter int EN_CG = 1,
    parameter int OFFSET_EXP = 6,
    parameter int SPP = 100,
    parameter int NW = 1000
);
  localparam logic [19:0] RX = 20'h100;
  localparam logic [19:0] REG_RX_CMD = RX + 20'h04, REG_RX_CMD_NUM_WORDS_LO = RX + 20'h08, REG_RX_CMD_NUM_WORDS_HI = RX + 20'h0C,
      REG_RX_CMD_TIME_LO = RX + 20'h10, REG_RX_CMD_TIME_HI = RX + 20'h14, REG_RX_MAX_WORDS_PER_PKT = RX + 20'h18;
  localparam logic [63:0] T0 = 64'h0000_0000_0000_1000;
  localparam logic [63:0] CMD_TIME = 64'h0000_0000_0000_3000;

  logic clk = 0;
  always #2.5 clk = ~clk;
  logic rst = 1;
  logic        req_wr = 0, req_rd = 0;
  logic [19:0] req_addr = 0;
  logic [31:0] req_data = 0;
  wire         resp_ack;
  wire  [1:0]  resp_status;
  wire  [31:0] resp_data;
  wire  [31:0] m_tdata;
  wire         m_tlast, m_tvalid, m_has_time, m_teob;
  wire  [63:0] m_ts;
  logic [63:0] radio_time = T0;
  wire  [31:0] tx_data;
  wire         rx_running, tx_running;
  wire         e_wr, e_has_time;
  wire  [19:0] e_addr;
  wire  [9:0]  e_portid, e_rem_portid;
  wire  [15:0] e_rem_epid;
  wire  [31:0] e_data;
  wire  [63:0] e_time;
  wire         s_tready;

  radio_core #(.SAMP_W(32), .NSPC(1), .EN_COMP_GAIN_TX(EN_CG), .EN_COMP_GAIN_RX(EN_CG), .EN_FIFO_OUT_REG(0)) dut (
      .radio_clk(clk), .radio_rst(rst),
      .s_ctrlport_req_wr(req_wr), .s_ctrlport_req_rd(req_rd), .s_ctrlport_req_addr(req_addr),
      .s_ctrlport_req_data(req_data), .s_ctrlport_req_has_time(1'b0), .s_ctrlport_req_time(64'd0),
      .s_ctrlport_resp_ack(resp_ack), .s_ctrlport_resp_status(resp_status), .s_ctrlport_resp_data(resp_data),
      .m_ctrlport_req_wr(e_wr), .m_ctrlport_req_addr(e_addr), .m_ctrlport_req_portid(e_portid),
      .m_ctrlport_req_rem_epid(e_rem_epid), .m_ctrlport_req_rem_portid(e_rem_portid), .m_ctrlport_req_data(e_data),
      .m_ctrlport_req_has_time(e_has_time), .m_ctrlport_req_time(e_time), .m_ctrlport_resp_ack(1'b1),
      .s_axis_tdata(32'd0), .s_axis_tlast(1'b0), .s_axis_tvalid(1'b0), .s_axis_tready(s_tready),
      .s_axis_ttimestamp(64'd0), .s_axis_thas_time(1'b0), .s_axis_teob(1'b0),
      .m_axis_tdata(m_tdata), .m_axis_tlast(m_tlast), .m_axis_tvalid(m_tvalid), .m_axis_tready(1'b1),
      .m_axis_ttimestamp(m_ts), .m_axis_thas_time(m_has_time), .m_axis_teob(m_teob),
      .radio_time(radio_time), .radio_rx_data(radio_time[31:0]), .radio_rx_stb(1'b1), .radio_rx_running(rx_running),
      .radio_tx_data(tx_data), .radio_tx_stb(1'b1), .radio_tx_running(tx_running));

  // radio_time: +1 per clock, changed at negedge (the sample on radio_rx_data is radio_time itself)
  always @(negedge clk) radio_time <= radio_time + 64'd1;

  task automatic cp_write(input logic [19:0] a, input logic [31:0] d);
    int to;
    @(negedge clk);
    req_wr = 1; req_addr = a; req_data = d;
    @(negedge clk);
    req_wr = 0;
    to = 0;
    while (!resp_ack) begin
      @(negedge clk);
      to++;
      if (to > 100) $fatal(1, "ctrlport write %h: no ack", a);
    end
  endtask

  int n_words = 0, n_pkts = 0, n_bad = 0, k = 0, offs = 0;
  logic [63:0] pkt_ts;
  bit first = 1;
  always @(negedge clk) begin
    if (!rst && m_tvalid) begin
      if (k == 0) begin
        pkt_ts = m_ts;
        if (first) begin
          offs = int'(m_ts[31:0] - m_tdata);
          $display("FIRST packet ttimestamp=%h has_time=%0d first sample (its tap time)=%h -> host timestamp - tap time = %0d",
                   m_ts, m_has_time, m_tdata, offs);
          if (m_ts !== CMD_TIME) begin
            n_bad++;
            $display("MISMATCH first packet timestamp %h != CMD_TIME %h", m_ts, CMD_TIME);
          end
          first = 0;
        end
      end
      if (m_tdata !== 32'(pkt_ts) + 32'(k) - 32'(OFFSET_EXP)) begin
        n_bad++;
        if (n_bad <= 10) $display("MISMATCH pkt %0d word %0d data=%h ts=%h", n_pkts, k, m_tdata, pkt_ts);
      end
      n_words++;
      k++;
      if (m_tlast) begin
        k = 0;
        n_pkts++;
      end
    end
  end

  initial begin
    repeat (20) @(negedge clk);
    rst = 0;
    repeat (20) @(negedge clk);
    cp_write(REG_RX_MAX_WORDS_PER_PKT, SPP);
    cp_write(REG_RX_CMD_NUM_WORDS_LO, NW);
    cp_write(REG_RX_CMD_NUM_WORDS_HI, 0);
    cp_write(REG_RX_CMD_TIME_LO, CMD_TIME[31:0]);
    cp_write(REG_RX_CMD_TIME_HI, CMD_TIME[63:32]);
    cp_write(REG_RX_CMD, 32'h8000_0001);   // timed, finite
    wait (n_words == NW || radio_time > CMD_TIME + 64'(NW) + 64'd500);
    repeat (50) @(negedge clk);
    $display("RESULT EN_COMP_GAIN_RX=%0d words=%0d/%0d packets=%0d offset(host ts - tap time)=%0d expected=%0d mismatches=%0d",
             EN_CG, n_words, NW, n_pkts, offs, OFFSET_EXP, n_bad);
    if (n_words != NW || n_bad != 0 || offs != OFFSET_EXP) $fatal(1, "FAIL");
    $display("PASS");
    $finish;
  end
endmodule
