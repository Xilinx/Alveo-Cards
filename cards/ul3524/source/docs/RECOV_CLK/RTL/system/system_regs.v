/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

module system_regs #(
    parameter integer NUM_CHANNEL = 4
) (
    output reg  [31:0] IO_SCRATCH_VALUE,
    input  wire [31:0] IO_HEADER0_VALUE,
    input  wire [31:0] IO_HEADER1_VALUE,
    input  wire [31:0] IO_HEADER2_VALUE,
    input  wire [31:0] IO_HEADER3_VALUE,
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
localparam ADDR_SCRATCH = 'h00000010;
localparam ADDR_CHANNEL = 'h00000014;

localparam ADDR_HEADER0_VALUE = 'h00000000;
localparam ADDR_HEADER1_VALUE = 'h00000004;
localparam ADDR_HEADER2_VALUE = 'h00000008;
localparam ADDR_HEADER3_VALUE = 'h0000000C;
localparam ADDR_SCRATCH_VALUE = 'h00000010;
localparam DFLT_SCRATCH_VALUE = 'h00000000;
localparam ADDR_CHANNEL_VALUE = 'h00000014;
localparam DFLT_CHANNEL_VALUE = NUM_CHANNEL;

// ####################################################
// # 
// #   Write Registers
// # 
// ####################################################

always@(posedge sys_if_clk)
begin
    if (!sys_if_rstn)
        IO_SCRATCH_VALUE <= DFLT_SCRATCH_VALUE;
    else if ( (sys_if_addr == ADDR_SCRATCH_VALUE) && sys_if_wen)
        IO_SCRATCH_VALUE <= sys_if_wdata[31:0];
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
reg [31:0] RDATA_SCRATCH;
reg [31:0] RDATA_CHANNEL;

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
    RDATA_SCRATCH = 'h0;
    RDATA_CHANNEL = 'h0;

    RDATA_HEADER0[31:0] = IO_HEADER0_VALUE;
    RDATA_HEADER1[31:0] = IO_HEADER1_VALUE;
    RDATA_HEADER2[31:0] = IO_HEADER2_VALUE;
    RDATA_HEADER3[31:0] = IO_HEADER3_VALUE;
    RDATA_SCRATCH[31:0] = IO_SCRATCH_VALUE;
    RDATA_CHANNEL[31:0] = DFLT_CHANNEL_VALUE;
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
            ( {32{sys_if_addr == ADDR_SCRATCH}} & RDATA_SCRATCH ) | 
            ( {32{sys_if_addr == ADDR_CHANNEL}} & RDATA_CHANNEL ) | 
            'h0;
end

endmodule

