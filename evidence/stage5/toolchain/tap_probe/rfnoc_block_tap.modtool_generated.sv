//
// Copyright 2026 <author>
//
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Module: rfnoc_block_tap
//
// Description:
//
//   <Add block description here>
//
// Parameters:
//
//   THIS_PORTID : Control crossbar port to which this block is connected
//   CHDR_W      : AXIS-CHDR data bus width
//   MTU         : Maximum transmission unit (i.e., maximum packet size in
//                 CHDR words is 2**MTU).
//

`default_nettype none

module rfnoc_block_tap #(
  parameter [9:0] THIS_PORTID     = 10'd0,
  parameter       CHDR_W          = 64,
  parameter [5:0] MTU             = 10,
  parameter       NUM_PORTS       = 2,
  parameter       NIPC            = 1
)(
  // RFNoC Framework Clocks and Resets
  input  wire                   rfnoc_chdr_clk,
  input  wire                   rfnoc_ctrl_clk,
  input  wire                   radio_clk,
  // AXIS-CHDR Input Ports (from framework)
  input  wire [(0)*CHDR_W-1:0] s_rfnoc_chdr_tdata,
  input  wire [(0)-1:0]        s_rfnoc_chdr_tlast,
  input  wire [(0)-1:0]        s_rfnoc_chdr_tvalid,
  output wire [(0)-1:0]        s_rfnoc_chdr_tready,
  // AXIS-CHDR Output Ports (to framework)
  output wire [(1)*CHDR_W-1:0] m_rfnoc_chdr_tdata,
  output wire [(1)-1:0]        m_rfnoc_chdr_tlast,
  output wire [(1)-1:0]        m_rfnoc_chdr_tvalid,
  input  wire [(1)-1:0]        m_rfnoc_chdr_tready,
  // AXIS-Ctrl Input Port (from framework)
  input  wire [31:0]            s_rfnoc_ctrl_tdata,
  input  wire                   s_rfnoc_ctrl_tlast,
  input  wire                   s_rfnoc_ctrl_tvalid,
  output wire                   s_rfnoc_ctrl_tready,
  // AXIS-Ctrl Output Port (to framework)
  output wire [31:0]            m_rfnoc_ctrl_tdata,
  output wire                   m_rfnoc_ctrl_tlast,
  output wire                   m_rfnoc_ctrl_tvalid,
  input  wire                   m_rfnoc_ctrl_tready,
  // IO Ports
  //   radio_in
  input  wire [${32*int(parameters['spc'])*int(parameters['num_ports']) if isinstance(parameters['spc'], int) and isinstance(parameters['num_ports'], int) else f"32*{parameters['spc']}*{parameters['num_ports']}"}-1:0] radio_rx_data_in,
  input  wire [${parameters['num_ports']}-1:0] radio_rx_stb_in,
  output wire [${parameters['num_ports']}-1:0] radio_rx_running_in,
  output wire [${32*int(parameters['spc'])*int(parameters['num_ports']) if isinstance(parameters['spc'], int) and isinstance(parameters['num_ports'], int) else f"32*{parameters['spc']}*{parameters['num_ports']}"}-1:0] radio_tx_data_in,
  input  wire [${parameters['num_ports']}-1:0] radio_tx_stb_in,
  output wire [${parameters['num_ports']}-1:0] radio_tx_running_in,
  //   radio_out
  output wire [${32*int(parameters['spc'])*int(parameters['num_ports']) if isinstance(parameters['spc'], int) and isinstance(parameters['num_ports'], int) else f"32*{parameters['spc']}*{parameters['num_ports']}"}-1:0] radio_rx_data_out,
  output wire [${parameters['num_ports']}-1:0] radio_rx_stb_out,
  input  wire [${parameters['num_ports']}-1:0] radio_rx_running_out,
  input  wire [${32*int(parameters['spc'])*int(parameters['num_ports']) if isinstance(parameters['spc'], int) and isinstance(parameters['num_ports'], int) else f"32*{parameters['spc']}*{parameters['num_ports']}"}-1:0] radio_tx_data_out,
  output wire [${parameters['num_ports']}-1:0] radio_tx_stb_out,
  input  wire [${parameters['num_ports']}-1:0] radio_tx_running_out,
  //   time
  input  wire [           63:0] radio_time,
  // RFNoC Backend Interface
  input  wire [511:0]           rfnoc_core_config,
  output wire [511:0]           rfnoc_core_status
);

  //---------------------------------------------------------------------------
  // Signal Declarations
  //---------------------------------------------------------------------------

  // Clocks and Resets
  wire               ctrlport_clk;
  wire               ctrlport_rst;
  wire               axis_data_clk;
  wire               axis_data_rst;
  // CtrlPort Master
  wire               m_ctrlport_req_wr;
  wire               m_ctrlport_req_rd;
  wire [19:0]        m_ctrlport_req_addr;
  wire [31:0]        m_ctrlport_req_data;
  wire               m_ctrlport_resp_ack;
  wire [31:0]        m_ctrlport_resp_data;
  // Data Stream from User Logic: evt
  wire [64*1-1:0]    s_evt_axis_tdata;
  wire [0:0]         s_evt_axis_tkeep;
  wire               s_evt_axis_tlast;
  wire               s_evt_axis_tvalid;
  wire               s_evt_axis_tready;
  wire [63:0]        s_evt_axis_ttimestamp;
  wire               s_evt_axis_thas_time;
  wire [15:0]        s_evt_axis_tlength;
  wire               s_evt_axis_teov;
  wire               s_evt_axis_teob;

  //---------------------------------------------------------------------------
  // NoC Shell
  //---------------------------------------------------------------------------

  noc_shell_tap #(
    .CHDR_W              (CHDR_W),
    .THIS_PORTID         (THIS_PORTID),
    .MTU                 (MTU),
    .NUM_PORTS           (NUM_PORTS),
    .NIPC                (NIPC)
  ) noc_shell_tap_i (
    //---------------------
    // Framework Interface
    //---------------------

    // Clock Inputs
    .rfnoc_chdr_clk      (rfnoc_chdr_clk),
    .rfnoc_ctrl_clk      (rfnoc_ctrl_clk),
    .radio_clk           (radio_clk),
    // Reset Outputs
    .rfnoc_chdr_rst      (),
    .rfnoc_ctrl_rst      (),
    .radio_rst           (),
    // CHDR Input Ports  (from framework)
    .s_rfnoc_chdr_tdata  (s_rfnoc_chdr_tdata),
    .s_rfnoc_chdr_tlast  (s_rfnoc_chdr_tlast),
    .s_rfnoc_chdr_tvalid (s_rfnoc_chdr_tvalid),
    .s_rfnoc_chdr_tready (s_rfnoc_chdr_tready),
    // CHDR Output Ports (to framework)
    .m_rfnoc_chdr_tdata  (m_rfnoc_chdr_tdata),
    .m_rfnoc_chdr_tlast  (m_rfnoc_chdr_tlast),
    .m_rfnoc_chdr_tvalid (m_rfnoc_chdr_tvalid),
    .m_rfnoc_chdr_tready (m_rfnoc_chdr_tready),
    // AXIS-Ctrl Input Port (from framework)
    .s_rfnoc_ctrl_tdata  (s_rfnoc_ctrl_tdata),
    .s_rfnoc_ctrl_tlast  (s_rfnoc_ctrl_tlast),
    .s_rfnoc_ctrl_tvalid (s_rfnoc_ctrl_tvalid),
    .s_rfnoc_ctrl_tready (s_rfnoc_ctrl_tready),
    // AXIS-Ctrl Output Port (to framework)
    .m_rfnoc_ctrl_tdata  (m_rfnoc_ctrl_tdata),
    .m_rfnoc_ctrl_tlast  (m_rfnoc_ctrl_tlast),
    .m_rfnoc_ctrl_tvalid (m_rfnoc_ctrl_tvalid),
    .m_rfnoc_ctrl_tready (m_rfnoc_ctrl_tready),

    //---------------------
    // Client Interface
    //---------------------

    // CtrlPort Clock and Reset
    .ctrlport_clk              (ctrlport_clk),
    .ctrlport_rst              (ctrlport_rst),
    // CtrlPort Master
    .m_ctrlport_req_wr         (m_ctrlport_req_wr),
    .m_ctrlport_req_rd         (m_ctrlport_req_rd),
    .m_ctrlport_req_addr       (m_ctrlport_req_addr),
    .m_ctrlport_req_data       (m_ctrlport_req_data),
    .m_ctrlport_resp_ack       (m_ctrlport_resp_ack),
    .m_ctrlport_resp_data      (m_ctrlport_resp_data),

    // AXI-Stream Clock and Reset
    .axis_data_clk (axis_data_clk),
    .axis_data_rst (axis_data_rst),
    // Data Stream from User Logic: evt
    .s_evt_axis_tdata      (s_evt_axis_tdata),
    .s_evt_axis_tkeep      (s_evt_axis_tkeep),
    .s_evt_axis_tlast      (s_evt_axis_tlast),
    .s_evt_axis_tvalid     (s_evt_axis_tvalid),
    .s_evt_axis_tready     (s_evt_axis_tready),
    .s_evt_axis_ttimestamp (s_evt_axis_ttimestamp),
    .s_evt_axis_thas_time  (s_evt_axis_thas_time),
    .s_evt_axis_tlength    (s_evt_axis_tlength),
    .s_evt_axis_teov       (s_evt_axis_teov),
    .s_evt_axis_teob       (s_evt_axis_teob),

    //---------------------------
    // RFNoC Backend Interface
    //---------------------------
    .rfnoc_core_config   (rfnoc_core_config),
    .rfnoc_core_status   (rfnoc_core_status)
  );

  //---------------------------------------------------------------------------
  // User Logic
  //---------------------------------------------------------------------------

  // < Replace this section with your logic >

  // Nothing to do yet, so just drive control signals to default values
  assign m_ctrlport_resp_ack = 1'b0;
  assign s_evt_axis_tvalid = 1'b0;

endmodule // rfnoc_block_tap

`default_nettype wire
