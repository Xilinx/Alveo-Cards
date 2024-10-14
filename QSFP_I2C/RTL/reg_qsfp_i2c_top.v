/*
Copyright (C) 2024, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: X11
*/

//------------------------------------------------------------------------------

module reg_qsfp_i2c_top(
    output wire       IO_CONTROL_PULSE,
    output wire [0:0] IO_CONTROL_RW,
    output wire [7:0] IO_CONTROL_ID,
    output wire [7:0] IO_ADDR_ADDR,
    output wire [7:0] IO_WDATA_WDATA,
    output wire [6:0] IO_RESETB_WDATA,
    input  wire [7:0] IO_RDATA_RDATA,
    input  wire       IO_CONTROL_CMPLT,

    input  wire            aclk           ,
    input  wire            aresetn        ,
    input  wire [31:0]     m_axi_awaddr   ,
    input  wire [2:0]      m_axi_awprot   ,
    input  wire            m_axi_awvalid  ,
    output wire            m_axi_awready  ,
    input  wire [31:0]     m_axi_wdata    ,
    input  wire [3:0]      m_axi_wstrb    ,
    input  wire            m_axi_wvalid   ,
    output wire            m_axi_wready   ,
    output wire [1:0]      m_axi_bresp    ,
    output wire            m_axi_bvalid   ,
    input  wire            m_axi_bready   ,
    input  wire [31:0]     m_axi_araddr   ,
    input  wire [2:0]      m_axi_arprot   ,
    input  wire            m_axi_arvalid  ,
    output wire            m_axi_arready  ,
    output wire [31:0]     m_axi_rdata    ,
    output wire [1:0]      m_axi_rresp    ,
    output wire            m_axi_rvalid   ,
    input  wire            m_axi_rready    
);


wire            wen   ;
wire [31:0]     addr  ;
wire [31:0]     wdata ;
wire [31:0]     rdata ;

// ####################################################
// # 
// #   AXI Bridge
// # 
// ####################################################

reg_axi_slave reg_axi_slave(
    .s_axi_aclk     ( aclk            ),
    .s_axi_aresetn  ( aresetn         ),

    .s_axi_awaddr   ( m_axi_awaddr    ),
    .s_axi_awvalid  ( m_axi_awvalid   ),
    .s_axi_awready  ( m_axi_awready   ),
    .s_axi_wdata    ( m_axi_wdata     ),
    .s_axi_wstrb    ( m_axi_wstrb     ),
    .s_axi_wvalid   ( m_axi_wvalid    ),
    .s_axi_wready   ( m_axi_wready    ),
    .s_axi_bresp    ( m_axi_bresp     ),
    .s_axi_bvalid   ( m_axi_bvalid    ),
    .s_axi_bready   ( m_axi_bready    ),

    .s_axi_araddr   ( m_axi_araddr    ),
    .s_axi_arvalid  ( m_axi_arvalid   ),
    .s_axi_arready  ( m_axi_arready   ),
    .s_axi_rdata    ( m_axi_rdata     ),
    .s_axi_rresp    ( m_axi_rresp     ),
    .s_axi_rvalid   ( m_axi_rvalid    ),
    .s_axi_rready   ( m_axi_rready    ),

    .wr_en          ( wen   ),
    .addr           ( addr  ),
    .wdata          ( wdata ),
    .wstrb          (       ),
    .rdata          ( rdata )
);

// ####################################################
// # 
// #   Register Array
// # 
// ####################################################

reg_qsfp_i2c_logic reg_qsfp_i2c_logic (
    .IO_CONTROL_PULSE ( IO_CONTROL_PULSE ),
    .IO_CONTROL_RW ( IO_CONTROL_RW ),
    .IO_CONTROL_ID ( IO_CONTROL_ID ),
    .IO_ADDR_ADDR ( IO_ADDR_ADDR ),
    .IO_WDATA_WDATA ( IO_WDATA_WDATA ),
    .IO_RESETB_WDATA ( IO_RESETB_WDATA ),
    .IO_RDATA_RDATA ( IO_RDATA_RDATA ),
    .IO_CONTROL_CMPLT ( IO_CONTROL_CMPLT ),
    .aclk    ( aclk    ),
    .aresetn ( aresetn ),
    .wen     ( wen     ),
    .addr    ( addr    ),
    .wdata   ( wdata   ),
    .rdata   ( rdata   ) 
);

endmodule

