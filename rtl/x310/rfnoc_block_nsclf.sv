//
// rfnoc_block_nsclf: the Stage 5 classifier block for the X310 image (PLAN.md D-S5-TAP, D-S5-OUT).
//
// Made from the rfnoc_modtool (UHD 4.9 a5d1b2e) template for rfnoc/blocks/nsclf.yml by
// rfnoc/gen_nsclf.sh: the template's unrendered Mako io-port widths are replaced by
// [32*NIPC*NUM_PORTS-1:0] / [NUM_PORTS-1:0] (evidence/stage5/toolchain/README.md section 4) and the
// "User Logic" section by nsclf_user (pass-through wires + nsclf_core). The noc_shell is the
// framework-generated noc_shell_nsclf.sv (its ctrlport_endpoint and axis_data_to_chdr are the only
// clock crossings of the block); everything in nsclf_user runs on radio_clk.
// Register map and timing: evidence/stage5/block/README.md.
//
// Parameters:
//
//   THIS_PORTID : Control crossbar port to which this block is connected
//   CHDR_W      : AXIS-CHDR data bus width
//   MTU         : Maximum transmission unit (i.e., maximum packet size in
//                 CHDR words is 2**MTU).
//

`default_nettype none

module rfnoc_block_nsclf #(
  parameter [9:0] THIS_PORTID     = 10'd0,
  parameter       CHDR_W          = 64,
  parameter [5:0] MTU             = 10,
  parameter       NUM_PORTS       = 2,
  parameter       NIPC            = 1,
  parameter       CORE_LAT        = 18,
  parameter       LC_X10          = 20,
  parameter       IN_REG          = 1,
  parameter       K_DEFAULT       = 16
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
  input  wire [32*NIPC*NUM_PORTS-1:0] radio_rx_data_in,
  input  wire [NUM_PORTS-1:0] radio_rx_stb_in,
  output wire [NUM_PORTS-1:0] radio_rx_running_in,
  output wire [32*NIPC*NUM_PORTS-1:0] radio_tx_data_in,
  input  wire [NUM_PORTS-1:0] radio_tx_stb_in,
  output wire [NUM_PORTS-1:0] radio_tx_running_in,
  //   radio_out
  output wire [32*NIPC*NUM_PORTS-1:0] radio_rx_data_out,
  output wire [NUM_PORTS-1:0] radio_rx_stb_out,
  input  wire [NUM_PORTS-1:0] radio_rx_running_out,
  input  wire [32*NIPC*NUM_PORTS-1:0] radio_tx_data_out,
  output wire [NUM_PORTS-1:0] radio_tx_stb_out,
  input  wire [NUM_PORTS-1:0] radio_tx_running_out,
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

  noc_shell_nsclf #(
    .CHDR_W              (CHDR_W),
    .THIS_PORTID         (THIS_PORTID),
    .MTU                 (MTU),
    .NUM_PORTS           (NUM_PORTS),
    .NIPC                (NIPC),
    .CORE_LAT            (CORE_LAT),
    .LC_X10              (LC_X10),
    .IN_REG              (IN_REG),
    .K_DEFAULT           (K_DEFAULT)
  ) noc_shell_nsclf_i (
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
  // User Logic: pass-through + classifier tap (radio_clk only)
  //---------------------------------------------------------------------------

  nsclf_user #(
    .NUM_PORTS (NUM_PORTS),
    .NIPC      (NIPC),
    .CORE_LAT  (CORE_LAT),
    .IN_REG    (IN_REG),
    .LC_X10    (LC_X10),
    .K_DEFAULT (K_DEFAULT)
  ) nsclf_user_i (
    .radio_clk             (radio_clk),
    .radio_rst             (ctrlport_rst),
    .radio_rx_data_in      (radio_rx_data_in),
    .radio_rx_stb_in       (radio_rx_stb_in),
    .radio_rx_running_in   (radio_rx_running_in),
    .radio_tx_data_in      (radio_tx_data_in),
    .radio_tx_stb_in       (radio_tx_stb_in),
    .radio_tx_running_in   (radio_tx_running_in),
    .radio_rx_data_out     (radio_rx_data_out),
    .radio_rx_stb_out      (radio_rx_stb_out),
    .radio_rx_running_out  (radio_rx_running_out),
    .radio_tx_data_out     (radio_tx_data_out),
    .radio_tx_stb_out      (radio_tx_stb_out),
    .radio_tx_running_out  (radio_tx_running_out),
    .radio_time            (radio_time),
    .m_ctrlport_req_wr     (m_ctrlport_req_wr),
    .m_ctrlport_req_rd     (m_ctrlport_req_rd),
    .m_ctrlport_req_addr   (m_ctrlport_req_addr),
    .m_ctrlport_req_data   (m_ctrlport_req_data),
    .m_ctrlport_resp_ack   (m_ctrlport_resp_ack),
    .m_ctrlport_resp_data  (m_ctrlport_resp_data),
    .s_evt_axis_tdata      (s_evt_axis_tdata),
    .s_evt_axis_tkeep      (s_evt_axis_tkeep),
    .s_evt_axis_tlast      (s_evt_axis_tlast),
    .s_evt_axis_tvalid     (s_evt_axis_tvalid),
    .s_evt_axis_tready     (s_evt_axis_tready),
    .s_evt_axis_ttimestamp (s_evt_axis_ttimestamp),
    .s_evt_axis_thas_time  (s_evt_axis_thas_time),
    .s_evt_axis_tlength    (s_evt_axis_tlength),
    .s_evt_axis_teov       (s_evt_axis_teov),
    .s_evt_axis_teob       (s_evt_axis_teob)
  );

endmodule // rfnoc_block_nsclf

`default_nettype wire
