/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

module freq_counter_regs (
    output reg  [0:0] IO_CONTROL_RESETN,
    output reg  [0:0] IO_CONTROL_SAMP_START,
    output reg  [31:0] IO_SAMP_WIDTH_VALUE,
    input  wire [31:0] IO_HEADER0_VALUE,
    input  wire [31:0] IO_HEADER1_VALUE,
    input  wire [31:0] IO_HEADER2_VALUE,
    input  wire [31:0] IO_HEADER3_VALUE,
    input  wire [0:0] IO_STATUS_SAMP_VALID,
    input  wire [31:0] IO_SAMP_COUNT_0_VALUE,
    input  wire [31:0] IO_SAMP_COUNT_1_VALUE,
    input  wire [31:0] IO_SAMP_COUNT_2_VALUE,
    input  wire [31:0] IO_SAMP_COUNT_3_VALUE,
    input  wire [31:0] IO_SAMP_COUNT_4_VALUE,
    input  wire [31:0] IO_SAMP_COUNT_5_VALUE,
    input  wire [31:0] IO_SAMP_COUNT_6_VALUE,
    input  wire [31:0] IO_SAMP_COUNT_7_VALUE,
    input  wire        sys_if_clk,   
    input  wire        sys_if_rstn,
    input  wire        sys_if_wen,    
    input  wire [31:0] sys_if_addr,   
    input  wire [31:0] sys_if_wdata,  
    output reg  [31:0] sys_if_rdata   
);


// ####################################################
// # 
// #   Local Parameters
// # 
// ####################################################

localparam ADDR_HEADER0 = 'h00000000;
localparam ADDR_HEADER1 = 'h00000004;
localparam ADDR_HEADER2 = 'h00000008;
localparam ADDR_HEADER3 = 'h0000000C;
localparam ADDR_STATUS = 'h00000010;
localparam ADDR_CONTROL = 'h00000014;
localparam ADDR_SAMP_WIDTH = 'h00000018;
localparam ADDR_SAMP_COUNT_0 = 'h00000020;
localparam ADDR_SAMP_COUNT_1 = 'h00000024;
localparam ADDR_SAMP_COUNT_2 = 'h00000028;
localparam ADDR_SAMP_COUNT_3 = 'h0000002c;
localparam ADDR_SAMP_COUNT_4 = 'h00000030;
localparam ADDR_SAMP_COUNT_5 = 'h00000034;
localparam ADDR_SAMP_COUNT_6 = 'h00000038;
localparam ADDR_SAMP_COUNT_7 = 'h0000003c;

localparam ADDR_HEADER0_VALUE = 'h00000000;
localparam ADDR_HEADER1_VALUE = 'h00000004;
localparam ADDR_HEADER2_VALUE = 'h00000008;
localparam ADDR_HEADER3_VALUE = 'h0000000C;
localparam ADDR_STATUS_SAMP_VALID = 'h00000010;
localparam ADDR_CONTROL_RESETN = 'h00000014;
localparam DFLT_CONTROL_RESETN = 'h00000000;
localparam ADDR_CONTROL_SAMP_START = 'h00000014;
localparam DFLT_CONTROL_SAMP_START = 0;
localparam ADDR_SAMP_WIDTH_VALUE = 'h00000018;
localparam DFLT_SAMP_WIDTH_VALUE = 'h000186a0;
localparam ADDR_SAMP_COUNT_0_VALUE = 'h00000020;
localparam ADDR_SAMP_COUNT_1_VALUE = 'h00000024;
localparam ADDR_SAMP_COUNT_2_VALUE = 'h00000028;
localparam ADDR_SAMP_COUNT_3_VALUE = 'h0000002c;
localparam ADDR_SAMP_COUNT_4_VALUE = 'h00000030;
localparam ADDR_SAMP_COUNT_5_VALUE = 'h00000034;
localparam ADDR_SAMP_COUNT_6_VALUE = 'h00000038;
localparam ADDR_SAMP_COUNT_7_VALUE = 'h0000003c;

// ####################################################
// # 
// #   Write Registers
// # 
// ####################################################

always@(posedge sys_if_clk)
begin
    if (!sys_if_rstn)
        IO_CONTROL_RESETN <= DFLT_CONTROL_RESETN;
    else if ( (sys_if_addr == ADDR_CONTROL_RESETN) && sys_if_wen)
        IO_CONTROL_RESETN <= sys_if_wdata[0:0];
end

always@(posedge sys_if_clk)
begin
    if (!sys_if_rstn)
        IO_CONTROL_SAMP_START <= DFLT_CONTROL_SAMP_START;
    else if ( (sys_if_addr == ADDR_CONTROL_SAMP_START) && sys_if_wen)
        IO_CONTROL_SAMP_START <= sys_if_wdata[1:1];
    else
        IO_CONTROL_SAMP_START <= 'h0;
end

always@(posedge sys_if_clk)
begin
    if (!sys_if_rstn)
        IO_SAMP_WIDTH_VALUE <= DFLT_SAMP_WIDTH_VALUE;
    else if ( (sys_if_addr == ADDR_SAMP_WIDTH_VALUE) && sys_if_wen)
        IO_SAMP_WIDTH_VALUE <= sys_if_wdata[31:0];
end


// ####################################################
// # 
// #   Read Data Register Definition
// # 
// ####################################################

reg [31:0] RDATA_HEADER0;
reg [31:0] RDATA_HEADER1;
reg [31:0] RDATA_HEADER2;
reg [31:0] RDATA_HEADER3;
reg [31:0] RDATA_STATUS;
reg [31:0] RDATA_CONTROL;
reg [31:0] RDATA_SAMP_WIDTH;
reg [31:0] RDATA_SAMP_COUNT_0;
reg [31:0] RDATA_SAMP_COUNT_1;
reg [31:0] RDATA_SAMP_COUNT_2;
reg [31:0] RDATA_SAMP_COUNT_3;
reg [31:0] RDATA_SAMP_COUNT_4;
reg [31:0] RDATA_SAMP_COUNT_5;
reg [31:0] RDATA_SAMP_COUNT_6;
reg [31:0] RDATA_SAMP_COUNT_7;

// ####################################################
// # 
// #   Read Data Register Fill
// # 
// ####################################################

always@(*)
begin
    RDATA_HEADER0 = 'h0;
    RDATA_HEADER1 = 'h0;
    RDATA_HEADER2 = 'h0;
    RDATA_HEADER3 = 'h0;
    RDATA_STATUS = 'h0;
    RDATA_CONTROL = 'h0;
    RDATA_SAMP_WIDTH = 'h0;
    RDATA_SAMP_COUNT_0 = 'h0;
    RDATA_SAMP_COUNT_1 = 'h0;
    RDATA_SAMP_COUNT_2 = 'h0;
    RDATA_SAMP_COUNT_3 = 'h0;
    RDATA_SAMP_COUNT_4 = 'h0;
    RDATA_SAMP_COUNT_5 = 'h0;
    RDATA_SAMP_COUNT_6 = 'h0;
    RDATA_SAMP_COUNT_7 = 'h0;

    RDATA_HEADER0[31:0] = IO_HEADER0_VALUE;
    RDATA_HEADER1[31:0] = IO_HEADER1_VALUE;
    RDATA_HEADER2[31:0] = IO_HEADER2_VALUE;
    RDATA_HEADER3[31:0] = IO_HEADER3_VALUE;
    RDATA_STATUS[0:0] = IO_STATUS_SAMP_VALID;
    RDATA_CONTROL[0:0] = IO_CONTROL_RESETN;
    RDATA_SAMP_WIDTH[31:0] = IO_SAMP_WIDTH_VALUE;
    RDATA_SAMP_COUNT_0[31:0] = IO_SAMP_COUNT_0_VALUE;
    RDATA_SAMP_COUNT_1[31:0] = IO_SAMP_COUNT_1_VALUE;
    RDATA_SAMP_COUNT_2[31:0] = IO_SAMP_COUNT_2_VALUE;
    RDATA_SAMP_COUNT_3[31:0] = IO_SAMP_COUNT_3_VALUE;
    RDATA_SAMP_COUNT_4[31:0] = IO_SAMP_COUNT_4_VALUE;
    RDATA_SAMP_COUNT_5[31:0] = IO_SAMP_COUNT_5_VALUE;
    RDATA_SAMP_COUNT_6[31:0] = IO_SAMP_COUNT_6_VALUE;
    RDATA_SAMP_COUNT_7[31:0] = IO_SAMP_COUNT_7_VALUE;
end

// ####################################################
// # 
// #   Read Data Mux
// # 
// ####################################################

always@(*)
begin
    sys_if_rdata <=
            ( {32{sys_if_addr == ADDR_HEADER0}} & RDATA_HEADER0 ) | 
            ( {32{sys_if_addr == ADDR_HEADER1}} & RDATA_HEADER1 ) | 
            ( {32{sys_if_addr == ADDR_HEADER2}} & RDATA_HEADER2 ) | 
            ( {32{sys_if_addr == ADDR_HEADER3}} & RDATA_HEADER3 ) | 
            ( {32{sys_if_addr == ADDR_STATUS}} & RDATA_STATUS ) | 
            ( {32{sys_if_addr == ADDR_CONTROL}} & RDATA_CONTROL ) | 
            ( {32{sys_if_addr == ADDR_SAMP_WIDTH}} & RDATA_SAMP_WIDTH ) | 
            ( {32{sys_if_addr == ADDR_SAMP_COUNT_0}} & RDATA_SAMP_COUNT_0 ) | 
            ( {32{sys_if_addr == ADDR_SAMP_COUNT_1}} & RDATA_SAMP_COUNT_1 ) | 
            ( {32{sys_if_addr == ADDR_SAMP_COUNT_2}} & RDATA_SAMP_COUNT_2 ) | 
            ( {32{sys_if_addr == ADDR_SAMP_COUNT_3}} & RDATA_SAMP_COUNT_3 ) | 
            ( {32{sys_if_addr == ADDR_SAMP_COUNT_4}} & RDATA_SAMP_COUNT_4 ) | 
            ( {32{sys_if_addr == ADDR_SAMP_COUNT_5}} & RDATA_SAMP_COUNT_5 ) | 
            ( {32{sys_if_addr == ADDR_SAMP_COUNT_6}} & RDATA_SAMP_COUNT_6 ) | 
            ( {32{sys_if_addr == ADDR_SAMP_COUNT_7}} & RDATA_SAMP_COUNT_7 ) | 
            'h0;
end

endmodule

