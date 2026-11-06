// nsclf_user: everything of the nsclf RFNoC block below its noc_shell (PLAN.md D-S5-TAP).
//
// 1. Pass-through: every radio0 io_port signal goes straight from the device side (*_in) to the stock radio
//    block (*_out) and back, as plain wires (no register, no logic), so the stock radio behaves exactly as
//    without the block. tb/tb_nsclf.sv checks out == in on every cycle.
// 2. nsclf_core on the device-side rx_data / rx_stb with radio_time, ctrlport and the event stream.
//    Event records are off at reset (REG_CTRL bit 2 EVT_EN) and leave batched, up to EVT_BATCH per packet.
// Only radio_clk is used here.
`timescale 1ns / 1ps
`default_nettype none

module nsclf_user #(
    parameter int NUM_PORTS = 2,
    parameter int NIPC      = 1,
    parameter int W         = 64,
    parameter int OUT_W     = 65,   // must equal X_OUT_W of rtl/gen/x310_clf_lanes.svh (x310_clf_top checks; v2 core 65, v1 62)
    parameter int CORE_LAT  = 18,
    parameter int BFP_PIPE  = 1,
    parameter int IN_REG    = 1,
    parameter int LC_X10    = 20,
    parameter int K_DEFAULT = 16,
    // 2026-11 event revision (not block YAML parameters: the image uses these defaults; REG_EVT_CFG reports them)
    parameter int EVT_AW    = 6,       // event FIFO depth 2^EVT_AW records
    parameter int EVT_BATCH = 16,      // event records per CHDR packet at most
    parameter int EVT_FLUSH_DEFAULT = 4096   // REG_EVT_FLUSH reset value (cycles)
) (
    input  wire                          radio_clk,
    input  wire                          radio_rst,
    //   radio_in (device side)
    input  wire [32*NIPC*NUM_PORTS-1:0]  radio_rx_data_in,
    input  wire [NUM_PORTS-1:0]          radio_rx_stb_in,
    output wire [NUM_PORTS-1:0]          radio_rx_running_in,
    output wire [32*NIPC*NUM_PORTS-1:0]  radio_tx_data_in,
    input  wire [NUM_PORTS-1:0]          radio_tx_stb_in,
    output wire [NUM_PORTS-1:0]          radio_tx_running_in,
    //   radio_out (stock radio side)
    output wire [32*NIPC*NUM_PORTS-1:0]  radio_rx_data_out,
    output wire [NUM_PORTS-1:0]          radio_rx_stb_out,
    input  wire [NUM_PORTS-1:0]          radio_rx_running_out,
    input  wire [32*NIPC*NUM_PORTS-1:0]  radio_tx_data_out,
    output wire [NUM_PORTS-1:0]          radio_tx_stb_out,
    input  wire [NUM_PORTS-1:0]          radio_tx_running_out,
    //   time
    input  wire [63:0]                   radio_time,
    // ctrlport
    input  wire                          m_ctrlport_req_wr,
    input  wire                          m_ctrlport_req_rd,
    input  wire [19:0]                   m_ctrlport_req_addr,
    input  wire [31:0]                   m_ctrlport_req_data,
    output wire                          m_ctrlport_resp_ack,
    output wire [31:0]                   m_ctrlport_resp_data,
    // event stream
    output wire [63:0]                   s_evt_axis_tdata,
    output wire [0:0]                    s_evt_axis_tkeep,
    output wire                          s_evt_axis_tlast,
    output wire                          s_evt_axis_tvalid,
    input  wire                          s_evt_axis_tready,
    output wire [63:0]                   s_evt_axis_ttimestamp,
    output wire                          s_evt_axis_thas_time,
    output wire [15:0]                   s_evt_axis_tlength,
    output wire                          s_evt_axis_teov,
    output wire                          s_evt_axis_teob
);
  if (NIPC != 1) begin : g_bad
    $error("nsclf_user: the classifier takes one sample per clock (NIPC = 1, the X310 radio)");
  end

  // ---- pass-through (D-S5-TAP): wires only
  assign radio_rx_data_out   = radio_rx_data_in;
  assign radio_rx_stb_out    = radio_rx_stb_in;
  assign radio_rx_running_in = radio_rx_running_out;
  assign radio_tx_data_in    = radio_tx_data_out;
  assign radio_tx_stb_out    = radio_tx_stb_in;
  assign radio_tx_running_in = radio_tx_running_out;

  // ---- classifier tap
  nsclf_core #(
      .NUM_PORTS(NUM_PORTS), .W(W), .OUT_W(OUT_W), .CORE_LAT(CORE_LAT), .BFP_PIPE(BFP_PIPE),
      .IN_REG(IN_REG), .LC_X10(LC_X10), .K_DEFAULT(K_DEFAULT), .EVT_AW(EVT_AW), .EVT_BATCH(EVT_BATCH),
      .EVT_FLUSH_DEFAULT(EVT_FLUSH_DEFAULT)
  ) u_core (
      .clk(radio_clk), .rst(radio_rst),
      .rx_data(radio_rx_data_in), .rx_stb(radio_rx_stb_in), .radio_time(radio_time),
      .req_wr(m_ctrlport_req_wr), .req_rd(m_ctrlport_req_rd), .req_addr(m_ctrlport_req_addr),
      .req_data(m_ctrlport_req_data), .resp_ack(m_ctrlport_resp_ack), .resp_data(m_ctrlport_resp_data),
      .evt_tdata(s_evt_axis_tdata), .evt_tkeep(s_evt_axis_tkeep[0]), .evt_tlast(s_evt_axis_tlast),
      .evt_tvalid(s_evt_axis_tvalid), .evt_tready(s_evt_axis_tready), .evt_ttimestamp(s_evt_axis_ttimestamp),
      .evt_thas_time(s_evt_axis_thas_time), .evt_tlength(s_evt_axis_tlength), .evt_teov(s_evt_axis_teov),
      .evt_teob(s_evt_axis_teob));
endmodule

`default_nettype wire
