/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

module renesas_i2c_regs (
    output reg  [0:0] IO_CONTROL_RESETN,
    output reg  [0:0] IO_CONTROL_START,
    input  wire [31:0] IO_HEADER0_VALUE,
    input  wire [31:0] IO_HEADER1_VALUE,
    input  wire [31:0] IO_HEADER2_VALUE,
    input  wire [31:0] IO_HEADER3_VALUE,
    input  wire [31:0] IO_STATUS_VALUE,
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

localparam ADDR_HEADER0_VALUE = 'h00000000;
localparam ADDR_HEADER1_VALUE = 'h00000004;
localparam ADDR_HEADER2_VALUE = 'h00000008;
localparam ADDR_HEADER3_VALUE = 'h0000000C;
localparam ADDR_STATUS_VALUE = 'h00000010;
localparam ADDR_CONTROL_RESETN = 'h00000014;
localparam DFLT_CONTROL_RESETN = 'h00000000;
localparam ADDR_CONTROL_START = 'h00000014;
localparam DFLT_CONTROL_START = 0;

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
        IO_CONTROL_START <= DFLT_CONTROL_START;
    else if ( (sys_if_addr == ADDR_CONTROL_START) && sys_if_wen)
        IO_CONTROL_START <= sys_if_wdata[1:1];
    else
        IO_CONTROL_START <= 'h0;
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

    RDATA_HEADER0[31:0] = IO_HEADER0_VALUE;
    RDATA_HEADER1[31:0] = IO_HEADER1_VALUE;
    RDATA_HEADER2[31:0] = IO_HEADER2_VALUE;
    RDATA_HEADER3[31:0] = IO_HEADER3_VALUE;
    RDATA_STATUS[31:0] = IO_STATUS_VALUE;
    RDATA_CONTROL[0:0] = IO_CONTROL_RESETN;
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
            'h0;
end

endmodule

