/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

module reg_latency_raw_top(
    output wire [0:0] IO_CONTROL_GTWIZ_RESET_ALL,
    output wire [0:0] IO_CONTROL_GTF_CH_TXDP_RESET,
    output wire [0:0] IO_CONTROL_GTF_CH_RXDP_RESET,
    output wire [0:0] IO_CONTROL_LAT_ENABLE,
    output wire [0:0] IO_CONTROL_LAT_POP,
    output wire [0:0] IO_CONTROL_LAT_CLEAR,
    output wire [0:0] IO_CONTROL_ERR_INJ_START,
    output wire [15:0] IO_ERR_INJ_COUNT_VALUE,
    output wire [15:0] IO_ERR_INJ_DELAY_VALUE,
    output wire [15:0] IO_LAT_PKT_CNT_VALUE,
    input  wire [0:0] IO_STATUS_LINK_STATUS,
    input  wire [0:0] IO_STATUS_LINK_STABLE,
    input  wire [0:0] IO_STATUS_LINK_DOWN_LATCHED,
    input  wire [15:0] IO_ERR_INJ_REMAIN_VALUE,
    input  wire [15:0] IO_LAT_PENDING_VALUE,
    input  wire [15:0] IO_LAT_TX_TIME_VALUE,
    input  wire [15:0] IO_LAT_RX_TIME_VALUE,
    input  wire [31:0] IO_LAT_DELTA_ACC_VALUE,
    input  wire [31:0] IO_LAT_DELTA_IDX_VALUE,
    input  wire [15:0] IO_LAT_DELTA_MAX_VALUE,
    input  wire [15:0] IO_LAT_DELTA_MIN_VALUE,
    input  wire [15:0] IO_LAT_DELTA_ADJ_VALUE,

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

reg_latency_raw_logic reg_latency_raw_logic (
    .IO_STATUS_LINK_STATUS ( IO_STATUS_LINK_STATUS ),
    .IO_STATUS_LINK_STABLE ( IO_STATUS_LINK_STABLE ),
    .IO_STATUS_LINK_DOWN_LATCHED ( IO_STATUS_LINK_DOWN_LATCHED ),
    .IO_CONTROL_GTWIZ_RESET_ALL ( IO_CONTROL_GTWIZ_RESET_ALL ),
    .IO_CONTROL_GTF_CH_TXDP_RESET ( IO_CONTROL_GTF_CH_TXDP_RESET ),
    .IO_CONTROL_GTF_CH_RXDP_RESET ( IO_CONTROL_GTF_CH_RXDP_RESET ),
    .IO_CONTROL_LAT_ENABLE ( IO_CONTROL_LAT_ENABLE ),
    .IO_CONTROL_LAT_POP ( IO_CONTROL_LAT_POP ),
    .IO_CONTROL_LAT_CLEAR ( IO_CONTROL_LAT_CLEAR ),
    .IO_CONTROL_ERR_INJ_START ( IO_CONTROL_ERR_INJ_START ),
    .IO_ERR_INJ_COUNT_VALUE ( IO_ERR_INJ_COUNT_VALUE ),
    .IO_ERR_INJ_DELAY_VALUE ( IO_ERR_INJ_DELAY_VALUE ),
    .IO_ERR_INJ_REMAIN_VALUE ( IO_ERR_INJ_REMAIN_VALUE ),
    .IO_LAT_PKT_CNT_VALUE ( IO_LAT_PKT_CNT_VALUE ),
    .IO_LAT_PENDING_VALUE ( IO_LAT_PENDING_VALUE ),
    .IO_LAT_TX_TIME_VALUE ( IO_LAT_TX_TIME_VALUE ),
    .IO_LAT_RX_TIME_VALUE ( IO_LAT_RX_TIME_VALUE ),
    .IO_LAT_DELTA_ACC_VALUE ( IO_LAT_DELTA_ACC_VALUE ),
    .IO_LAT_DELTA_IDX_VALUE ( IO_LAT_DELTA_IDX_VALUE ),
    .IO_LAT_DELTA_MAX_VALUE ( IO_LAT_DELTA_MAX_VALUE ),
    .IO_LAT_DELTA_MIN_VALUE ( IO_LAT_DELTA_MIN_VALUE ),
    .IO_LAT_DELTA_ADJ_VALUE ( IO_LAT_DELTA_ADJ_VALUE ),
    .aclk    ( aclk    ),
    .aresetn ( aresetn ),
    .wen     ( wen     ),
    .addr    ( addr    ),
    .wdata   ( wdata   ),
    .rdata   ( rdata   ) 
);

endmodule

