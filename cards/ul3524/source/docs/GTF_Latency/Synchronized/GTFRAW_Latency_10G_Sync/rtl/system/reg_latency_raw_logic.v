/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

module reg_latency_raw_logic(
    output reg  [0:0] IO_CONTROL_GTWIZ_RESET_ALL,
    output reg  [0:0] IO_CONTROL_GTF_CH_TXDP_RESET,
    output reg  [0:0] IO_CONTROL_GTF_CH_RXDP_RESET,
    output reg  [0:0] IO_CONTROL_LAT_ENABLE,
    output reg  [0:0] IO_CONTROL_LAT_POP,
    output reg  [0:0] IO_CONTROL_LAT_CLEAR,
    output reg  [0:0] IO_CONTROL_ERR_INJ_START,
    output reg  [15:0] IO_ERR_INJ_COUNT_VALUE,
    output reg  [15:0] IO_ERR_INJ_DELAY_VALUE,
    output reg  [15:0] IO_LAT_PKT_CNT_VALUE,
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
    input  wire        aclk,   
    input  wire        aresetn,
    input  wire        wen,    
    input  wire [31:0] addr,   
    input  wire [31:0] wdata,  
    output reg  [31:0] rdata   
);


// ####################################################
// # 
// #   Local Parameters
// # 
// ####################################################

localparam ADDR_STATUS = 'h00000000;
localparam ADDR_CONTROL = 'h00000004;
localparam ADDR_ERR_INJ_COUNT = 'h00000010;
localparam ADDR_ERR_INJ_DELAY = 'h00000014;
localparam ADDR_ERR_INJ_REMAIN = 'h00000018;
localparam ADDR_LAT_PKT_CNT = 'h00000020;
localparam ADDR_LAT_PENDING = 'h00000024;
localparam ADDR_LAT_TX_TIME = 'h00000028;
localparam ADDR_LAT_RX_TIME = 'h0000002C;
localparam ADDR_LAT_DELTA_ACC = 'h00000030;
localparam ADDR_LAT_DELTA_IDX = 'h00000034;
localparam ADDR_LAT_DELTA_MAX = 'h00000038;
localparam ADDR_LAT_DELTA_MIN = 'h0000003C;
localparam ADDR_LAT_DELTA_ADJ = 'h00000040;

localparam ADDR_STATUS_LINK_STATUS = 'h00000000;
localparam ADDR_STATUS_LINK_STABLE = 'h00000000;
localparam ADDR_STATUS_LINK_DOWN_LATCHED = 'h00000000;
localparam ADDR_CONTROL_GTWIZ_RESET_ALL = 'h00000004;
localparam DFLT_CONTROL_GTWIZ_RESET_ALL = 'h00000000;
localparam ADDR_CONTROL_GTF_CH_TXDP_RESET = 'h00000004;
localparam DFLT_CONTROL_GTF_CH_TXDP_RESET = 'h00000000;
localparam ADDR_CONTROL_GTF_CH_RXDP_RESET = 'h00000004;
localparam DFLT_CONTROL_GTF_CH_RXDP_RESET = 'h00000000;
localparam ADDR_CONTROL_LAT_ENABLE = 'h00000004;
localparam DFLT_CONTROL_LAT_ENABLE = 'h00000000;
localparam ADDR_CONTROL_LAT_POP = 'h00000004;
localparam DFLT_CONTROL_LAT_POP = 'h00000000;
localparam ADDR_CONTROL_LAT_CLEAR = 'h00000004;
localparam DFLT_CONTROL_LAT_CLEAR = 'h00000000;
localparam ADDR_CONTROL_ERR_INJ_START = 'h00000004;
localparam DFLT_CONTROL_ERR_INJ_START = 'h00000000;
localparam ADDR_ERR_INJ_COUNT_VALUE = 'h00000010;
localparam DFLT_ERR_INJ_COUNT_VALUE = 'h00000000;
localparam ADDR_ERR_INJ_DELAY_VALUE = 'h00000014;
localparam DFLT_ERR_INJ_DELAY_VALUE = 'h00000000;
localparam ADDR_ERR_INJ_REMAIN_VALUE = 'h00000018;
localparam ADDR_LAT_PKT_CNT_VALUE = 'h00000020;
localparam DFLT_LAT_PKT_CNT_VALUE = 'h00000000;
localparam ADDR_LAT_PENDING_VALUE = 'h00000024;
localparam ADDR_LAT_TX_TIME_VALUE = 'h00000028;
localparam ADDR_LAT_RX_TIME_VALUE = 'h0000002C;
localparam ADDR_LAT_DELTA_ACC_VALUE = 'h00000030;
localparam ADDR_LAT_DELTA_IDX_VALUE = 'h00000034;
localparam ADDR_LAT_DELTA_MAX_VALUE = 'h00000038;
localparam ADDR_LAT_DELTA_MIN_VALUE = 'h0000003C;
localparam ADDR_LAT_DELTA_ADJ_VALUE = 'h00000040;

// ####################################################
// # 
// #   Write Registers
// # 
// ####################################################

always@(posedge aclk)
begin
    if (!aresetn)
        IO_CONTROL_GTWIZ_RESET_ALL <= DFLT_CONTROL_GTWIZ_RESET_ALL;
    else if ( (addr == ADDR_CONTROL_GTWIZ_RESET_ALL) && wen)
        IO_CONTROL_GTWIZ_RESET_ALL <= wdata[0:0];
end

always@(posedge aclk)
begin
    if (!aresetn)
        IO_CONTROL_GTF_CH_TXDP_RESET <= DFLT_CONTROL_GTF_CH_TXDP_RESET;
    else if ( (addr == ADDR_CONTROL_GTF_CH_TXDP_RESET) && wen)
        IO_CONTROL_GTF_CH_TXDP_RESET <= wdata[1:1];
end

always@(posedge aclk)
begin
    if (!aresetn)
        IO_CONTROL_GTF_CH_RXDP_RESET <= DFLT_CONTROL_GTF_CH_RXDP_RESET;
    else if ( (addr == ADDR_CONTROL_GTF_CH_RXDP_RESET) && wen)
        IO_CONTROL_GTF_CH_RXDP_RESET <= wdata[2:2];
end

always@(posedge aclk)
begin
    if (!aresetn)
        IO_CONTROL_LAT_ENABLE <= DFLT_CONTROL_LAT_ENABLE;
    else if ( (addr == ADDR_CONTROL_LAT_ENABLE) && wen)
        IO_CONTROL_LAT_ENABLE <= wdata[4:4];
end

always@(posedge aclk)
begin
    if (!aresetn)
        IO_CONTROL_LAT_POP <= DFLT_CONTROL_LAT_POP;
    else if ( (addr == ADDR_CONTROL_LAT_POP) && wen)
        IO_CONTROL_LAT_POP <= wdata[5:5];
    else
        IO_CONTROL_LAT_POP <= 'h0;
end

always@(posedge aclk)
begin
    if (!aresetn)
        IO_CONTROL_LAT_CLEAR <= DFLT_CONTROL_LAT_CLEAR;
    else if ( (addr == ADDR_CONTROL_LAT_CLEAR) && wen)
        IO_CONTROL_LAT_CLEAR <= wdata[6:6];
    else
        IO_CONTROL_LAT_CLEAR <= 'h0;
end

always@(posedge aclk)
begin
    if (!aresetn)
        IO_CONTROL_ERR_INJ_START <= DFLT_CONTROL_ERR_INJ_START;
    else if ( (addr == ADDR_CONTROL_ERR_INJ_START) && wen)
        IO_CONTROL_ERR_INJ_START <= wdata[8:8];
    else
        IO_CONTROL_ERR_INJ_START <= 'h0;
end

always@(posedge aclk)
begin
    if (!aresetn)
        IO_ERR_INJ_COUNT_VALUE <= DFLT_ERR_INJ_COUNT_VALUE;
    else if ( (addr == ADDR_ERR_INJ_COUNT_VALUE) && wen)
        IO_ERR_INJ_COUNT_VALUE <= wdata[15:0];
end

always@(posedge aclk)
begin
    if (!aresetn)
        IO_ERR_INJ_DELAY_VALUE <= DFLT_ERR_INJ_DELAY_VALUE;
    else if ( (addr == ADDR_ERR_INJ_DELAY_VALUE) && wen)
        IO_ERR_INJ_DELAY_VALUE <= wdata[15:0];
end

always@(posedge aclk)
begin
    if (!aresetn)
        IO_LAT_PKT_CNT_VALUE <= DFLT_LAT_PKT_CNT_VALUE;
    else if ( (addr == ADDR_LAT_PKT_CNT_VALUE) && wen)
        IO_LAT_PKT_CNT_VALUE <= wdata[15:0];
end


// ####################################################
// # 
// #   Read Data Register Definition
// # 
// ####################################################

reg [31:0] RDATA_STATUS;
reg [31:0] RDATA_CONTROL;
reg [31:0] RDATA_ERR_INJ_COUNT;
reg [31:0] RDATA_ERR_INJ_DELAY;
reg [31:0] RDATA_ERR_INJ_REMAIN;
reg [31:0] RDATA_LAT_PKT_CNT;
reg [31:0] RDATA_LAT_PENDING;
reg [31:0] RDATA_LAT_TX_TIME;
reg [31:0] RDATA_LAT_RX_TIME;
reg [31:0] RDATA_LAT_DELTA_ACC;
reg [31:0] RDATA_LAT_DELTA_IDX;
reg [31:0] RDATA_LAT_DELTA_MAX;
reg [31:0] RDATA_LAT_DELTA_MIN;
reg [31:0] RDATA_LAT_DELTA_ADJ;

// ####################################################
// # 
// #   Read Data Register Fill
// # 
// ####################################################

always@(*)
begin
    RDATA_STATUS = 'h0;
    RDATA_CONTROL = 'h0;
    RDATA_ERR_INJ_COUNT = 'h0;
    RDATA_ERR_INJ_DELAY = 'h0;
    RDATA_ERR_INJ_REMAIN = 'h0;
    RDATA_LAT_PKT_CNT = 'h0;
    RDATA_LAT_PENDING = 'h0;
    RDATA_LAT_TX_TIME = 'h0;
    RDATA_LAT_RX_TIME = 'h0;
    RDATA_LAT_DELTA_ACC = 'h0;
    RDATA_LAT_DELTA_IDX = 'h0;
    RDATA_LAT_DELTA_MAX = 'h0;
    RDATA_LAT_DELTA_MIN = 'h0;
    RDATA_LAT_DELTA_ADJ = 'h0;

    RDATA_STATUS[0:0] = IO_STATUS_LINK_STATUS;
    RDATA_STATUS[1:1] = IO_STATUS_LINK_STABLE;
    RDATA_STATUS[2:2] = IO_STATUS_LINK_DOWN_LATCHED;
    RDATA_CONTROL[0:0] = IO_CONTROL_GTWIZ_RESET_ALL;
    RDATA_CONTROL[1:1] = IO_CONTROL_GTF_CH_TXDP_RESET;
    RDATA_CONTROL[2:2] = IO_CONTROL_GTF_CH_RXDP_RESET;
    RDATA_CONTROL[4:4] = IO_CONTROL_LAT_ENABLE;
    RDATA_CONTROL[5:5] = IO_CONTROL_LAT_POP;
    RDATA_CONTROL[6:6] = IO_CONTROL_LAT_CLEAR;
    RDATA_CONTROL[8:8] = IO_CONTROL_ERR_INJ_START;
    RDATA_ERR_INJ_COUNT[15:0] = IO_ERR_INJ_COUNT_VALUE;
    RDATA_ERR_INJ_DELAY[15:0] = IO_ERR_INJ_DELAY_VALUE;
    RDATA_ERR_INJ_REMAIN[15:0] = IO_ERR_INJ_REMAIN_VALUE;
    RDATA_LAT_PKT_CNT[15:0] = IO_LAT_PKT_CNT_VALUE;
    RDATA_LAT_PENDING[15:0] = IO_LAT_PENDING_VALUE;
    RDATA_LAT_TX_TIME[15:0] = IO_LAT_TX_TIME_VALUE;
    RDATA_LAT_RX_TIME[15:0] = IO_LAT_RX_TIME_VALUE;
    RDATA_LAT_DELTA_ACC[31:0] = IO_LAT_DELTA_ACC_VALUE;
    RDATA_LAT_DELTA_IDX[31:0] = IO_LAT_DELTA_IDX_VALUE;
    RDATA_LAT_DELTA_MAX[15:0] = IO_LAT_DELTA_MAX_VALUE;
    RDATA_LAT_DELTA_MIN[15:0] = IO_LAT_DELTA_MIN_VALUE;
    RDATA_LAT_DELTA_ADJ[15:0] = IO_LAT_DELTA_ADJ_VALUE;
end

// ####################################################
// # 
// #   Read Data Mux
// # 
// ####################################################

always@(*)
begin
    rdata <=
            ( {32{addr == ADDR_STATUS}} & RDATA_STATUS ) | 
            ( {32{addr == ADDR_CONTROL}} & RDATA_CONTROL ) | 
            ( {32{addr == ADDR_ERR_INJ_COUNT}} & RDATA_ERR_INJ_COUNT ) | 
            ( {32{addr == ADDR_ERR_INJ_DELAY}} & RDATA_ERR_INJ_DELAY ) | 
            ( {32{addr == ADDR_ERR_INJ_REMAIN}} & RDATA_ERR_INJ_REMAIN ) | 
            ( {32{addr == ADDR_LAT_PKT_CNT}} & RDATA_LAT_PKT_CNT ) | 
            ( {32{addr == ADDR_LAT_PENDING}} & RDATA_LAT_PENDING ) | 
            ( {32{addr == ADDR_LAT_TX_TIME}} & RDATA_LAT_TX_TIME ) | 
            ( {32{addr == ADDR_LAT_RX_TIME}} & RDATA_LAT_RX_TIME ) | 
            ( {32{addr == ADDR_LAT_DELTA_ACC}} & RDATA_LAT_DELTA_ACC ) | 
            ( {32{addr == ADDR_LAT_DELTA_IDX}} & RDATA_LAT_DELTA_IDX ) | 
            ( {32{addr == ADDR_LAT_DELTA_MAX}} & RDATA_LAT_DELTA_MAX ) | 
            ( {32{addr == ADDR_LAT_DELTA_MIN}} & RDATA_LAT_DELTA_MIN ) | 
            ( {32{addr == ADDR_LAT_DELTA_ADJ}} & RDATA_LAT_DELTA_ADJ ) | 
            'h0;
end

endmodule

