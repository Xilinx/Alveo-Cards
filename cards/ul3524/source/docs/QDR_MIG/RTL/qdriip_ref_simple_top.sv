/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/


//------------------------------------------------------------------------------
//
//  Description: Top-level module for the Simple QDRII+ Reference Design. This 
//  design serves as a refernce on how to interface to the QDRII+ SRAM using the 
//  QDRII+ Memory Controller (MC) generated through the Memory Interface 
//  Generator (MIG) and the AXI-QDRII+ Bridge.
// 
//  Instantiates: Simple AXI Master 
//                AXI-QDRII+ Bridge
//                QDRII+ MC
//
//  Simple AXI Master is connected the AXI ports AXI-QDRII+ Bridge
//  UI ports of the QDRII+ MC are connected to the AXI-QDRII+ Bridge
//  MI ports of the QDRII+ MC are connected to the top-level
//
//------------------------------------------------------------------------------

module qdriip_ref_simple_top #(
  parameter AXI_ADDR_WIDTH = 32,
  parameter AXI_DATA_WIDTH = 64,

  parameter QDRIIP_ADDR_WIDTH = 22,
  parameter QDRIIP_DATA_WIDTH = 72,
  
  parameter NUM_WRITES = 10
)(
  // QDRII+ 300 MHz Ref Clock
  input logic         CLK10_LVDS_300_P,
  input logic         CLK10_LVDS_300_N,

  // QDRII+ Memory Interface
  input  logic        QDR0_CQP,
  input  logic        QDR0_CQN,
  output logic        QDR0_KP,
  output logic        QDR0_KN,
  output logic        QDR0_WN,
  output logic        QDR0_RN,
  output logic        QDR0_DOFFN,
  output logic [1:0]  QDR0_BWN,
  output logic [21:0] QDR0_A,
  output logic [17:0] QDR0_D,
  input  logic [17:0] QDR0_Q
);
  //============//
  // Parameters //
  //============//
  
  localparam ERROR_CNT_SIZE = $clog2(NUM_WRITES);

  //=====================//
  // Signal Declarations //
  //=====================//

  // AXI Address Write Channel
  wire [AXI_ADDR_WIDTH-1:0] axi_awaddr;
  wire [7:0]                axi_awlen;
  wire                      axi_awvalid;
  wire                      axi_awready;

  // AXI Write Data Channel
  wire                      axi_wlast;
  wire [AXI_DATA_WIDTH-1:0] axi_wdata;
  wire [7:0]                axi_wstrb;
  wire                      axi_wvalid;
  wire                      axi_wready;

  // AXI Write Response Chann
  wire [1:0]                axi_bresp;
  wire                      axi_bvalid;
  wire                      axi_bready;

  // AXI Address Read Chann
  wire [AXI_ADDR_WIDTH-1:0] axi_araddr;
  wire [7:0]                axi_arlen;
  wire                      axi_arvalid;
  wire                      axi_arready;

  // AXI Read Data Chann
  wire [AXI_DATA_WIDTH-1:0] axi_rdata;
  wire [1:0]                axi_rresp;   
  wire                      axi_rvalid;
  wire                      axi_rlast;
  wire                      axi_rready;

  // QDRII+ User Interface
  wire                         qdriip_clk;
  wire                         qdriip_rst_clk;
  wire                         init_calib_complete;
  wire                         qdriip_app_wr_cmd;
  wire [QDRIIP_ADDR_WIDTH-1:0] qdriip_app_wr_addr;
  wire [QDRIIP_DATA_WIDTH-1:0] qdriip_app_wr_data;
  wire [7:0]                   qdriip_app_wr_bw_n;
  wire                         qdriip_app_rd_cmd;
  wire [QDRIIP_ADDR_WIDTH-1:0] qdriip_app_rd_addr;
  wire [QDRIIP_DATA_WIDTH-1:0] qdriip_app_rd_data;
  wire                         qdriip_app_rd_valid;

  wire                         rst_n = !qdriip_rst_clk;

  wire start = init_calib_complete; // Start FSM when calibration is done
  wire done;
  wire [ERROR_CNT_SIZE-1:0] error_counter;

  // AXI-QDRII+ Bridge Ports
  wire bridge_wr_error;
  wire bridge_rd_error;

  (* DONT_TOUCH = "TRUE" *) logic sys_rst; // System reset driven by VIO

  //======================//
  // Module Instantiation //
  //======================//

  vio_0 vio_0_inst0 (
    .clk(qdriip_clk),      
    .probe_in0(done), 
    .probe_in1(bridge_wr_error), 
    .probe_in2(bridge_rd_error), 
    .probe_in3(error_counter),
    .probe_in4(init_calib_complete),
    .probe_out0(sys_rst)
  );

  ila_0 ila_0_inst0 (
	  .clk(qdriip_clk), // input wire clk
	  .probe0(axi_awaddr), // input wire [31:0]  probe0  
	  .probe1(axi_awlen), // input wire [7:0]  probe1 
	  .probe2(axi_awvalid), // input wire [0:0]  probe2 
	  .probe3(axi_awready), // input wire [0:0]  probe3 
	  .probe4(axi_wlast), // input wire [0:0]  probe4 
	  .probe5(axi_wdata), // input wire [63:0]  probe5 
	  .probe6(axi_wstrb), // input wire [7:0]  probe6 
	  .probe7(axi_wvalid), // input wire [0:0]  probe7 
	  .probe8(axi_wready), // input wire [0:0]  probe8 
	  .probe9(axi_bresp), // input wire [1:0]  probe9 
	  .probe10(axi_bvalid), // input wire [0:0]  probe10 
	  .probe11(axi_bready), // input wire [0:0]  probe11 
	  .probe12(axi_araddr), // input wire [31:0]  probe12 
	  .probe13(axi_arlen), // input wire [7:0]  probe13 
	  .probe14(axi_arvalid), // input wire [0:0]  probe14 
	  .probe15(axi_arready), // input wire [0:0]  probe15 
	  .probe16(axi_rdata), // input wire [63:0]  probe16 
	  .probe17(axi_rresp), // input wire [1:0]  probe17 
	  .probe18(axi_rvalid), // input wire [0:0]  probe18 
	  .probe19(axi_rlast), // input wire [0:0]  probe19 
	  .probe20(axi_rready) // input wire [0:0]  probe20
  );

  simple_axi_master #(
    .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .NUM_WRITES(NUM_WRITES)
  ) simple_axi_master_inst_0 (
    .clk(qdriip_clk),
    .rst_n(rst_n),

    // Control/Status
    .start(start),
    .done(done),
    .error_counter(error_counter),

    // AXI Interface
    .m_axi_awaddr(axi_awaddr),
    .m_axi_awlen(axi_awlen),
    .m_axi_awvalid(axi_awvalid),
    .m_axi_awready(axi_awready),

    .m_axi_wlast(axi_wlast),
    .m_axi_wdata(axi_wdata),
    .m_axi_wstrb(axi_wstrb),
    .m_axi_wvalid(axi_wvalid),
    .m_axi_wready(axi_wready),

    .m_axi_bresp(axi_bresp),
    .m_axi_bvalid(axi_bvalid),
    .m_axi_bready(axi_bready),

    .m_axi_araddr(axi_araddr),
    .m_axi_arlen(axi_arlen),
    .m_axi_arvalid(axi_arvalid),
    .m_axi_arready(axi_arready),

    .m_axi_rdata(axi_rdata),
    .m_axi_rresp(axi_rresp),
    .m_axi_rvalid(axi_rvalid),
    .m_axi_rlast(axi_rlast),
    .m_axi_rready(axi_rready)
  );

  axi_qdriip_bridge_0 axi_qdriip_bridge_inst_0 (
    // AXI Interface
    .s_axi_aclk(qdriip_clk),
    .s_axi_aresetn(rst_n),
    .s_axi_awaddr(axi_awaddr),
    .s_axi_awlen(axi_awlen),
    .s_axi_awvalid(axi_awvalid),
    .s_axi_awready(axi_awready),
    .s_axi_wlast(axi_wlast),
    .s_axi_wdata(axi_wdata),
    .s_axi_wstrb(axi_wstrb),
    .s_axi_wvalid(axi_wvalid),
    .s_axi_wready(axi_wready),
    .s_axi_bresp(axi_bresp),
    .s_axi_bvalid(axi_bvalid),
    .s_axi_bready(axi_bready),
    .s_axi_araddr(axi_araddr),
    .s_axi_arlen(axi_arlen),
    .s_axi_arvalid(axi_arvalid),
    .s_axi_arready(axi_arready),
    .s_axi_rdata(axi_rdata),
    .s_axi_rresp(axi_rresp),
    .s_axi_rvalid(axi_rvalid),
    .s_axi_rlast(axi_rlast),
    .s_axi_rready(axi_rready),

    // QDRII+ User Interface
    .qdriip_app_wr_cmd(qdriip_app_wr_cmd),
    .qdriip_app_wr_addr(qdriip_app_wr_addr),
    .qdriip_app_wr_data(qdriip_app_wr_data),
    .qdriip_app_wr_bw_n(qdriip_app_wr_bw_n),

    .qdriip_app_rd_cmd(qdriip_app_rd_cmd),
    .qdriip_app_rd_addr(qdriip_app_rd_addr),
    .qdriip_app_rd_data(qdriip_app_rd_data),
    .qdriip_app_rd_valid(qdriip_app_rd_valid),

    .wr_error(bridge_wr_error),
    .rd_error(bridge_rd_error)
  );

  qdriip_0 qdriip_inst_0 (
    // QDRII+ User Interface
    .c0_qdriip_app_rd_addr0(qdriip_app_rd_addr),
    .c0_qdriip_app_rd_cmd0(qdriip_app_rd_cmd),
    .c0_qdriip_app_rd_data0(qdriip_app_rd_data),
    .c0_qdriip_app_rd_valid0(qdriip_app_rd_valid),
    .c0_qdriip_app_wr_addr0(qdriip_app_wr_addr),
    .c0_qdriip_app_wr_cmd0(qdriip_app_wr_cmd),
    .c0_qdriip_app_wr_data0(qdriip_app_wr_data),
    .c0_qdriip_app_wr_bw_n0(qdriip_app_wr_bw_n),
    .c0_qdriip_clk(qdriip_clk),                    // User Interface clock
    .c0_qdriip_rst_clk(qdriip_rst_clk),            // Reset signal synchrnoized by the User Interface clock
    .c0_init_calib_complete(init_calib_complete), 
    .sys_rst(sys_rst),                             // Asynchronous system reset input, active high,
                                                   // must assert for a minimum pulse width of 5 ns
    .c0_sys_clk_p(CLK10_LVDS_300_P),                      // System clock to the Memory Controller
    .c0_sys_clk_n(CLK10_LVDS_300_N),                 
    .dbg_clk(),                                    // Reserved, do not connect
    .dbg_bus(),                                    // Reserved, do not connect
    
    // QDRII+ Memory Interface
    .c0_qdriip_cq_n(QDR0_CQN),
    .c0_qdriip_cq_p(QDR0_CQP),                 
    .c0_qdriip_d(QDR0_D),
    .c0_qdriip_doff_n(QDR0_DOFFN),
    .c0_qdriip_bw_n(QDR0_BWN),
    .c0_qdriip_k_n(QDR0_KN),
    .c0_qdriip_k_p(QDR0_KP),
    .c0_qdriip_q(QDR0_Q),
    .c0_qdriip_sa(QDR0_A),
    .c0_qdriip_w_n(QDR0_WN),
    .c0_qdriip_r_n(QDR0_RN)
  );

endmodule