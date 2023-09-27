/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

module renesas_gpio_regs (
    output reg  [0:0] IO_JITT_RSTN_OUT_VALUE,
    output reg  [0:0] IO_JITT_RSTN_CFG_VALUE,
    output reg  [5:0] IO_JITT1_GPIO_OUT_VALUE,
    output reg  [5:0] IO_JITT1_GPIO_CFG_VALUE,
    output reg  [5:0] IO_JITT2_GPIO_OUT_VALUE,
    output reg  [5:0] IO_JITT2_GPIO_CFG_VALUE,
    input  wire [31:0] IO_HEADER0_VALUE,
    input  wire [31:0] IO_HEADER1_VALUE,
    input  wire [31:0] IO_HEADER2_VALUE,
    input  wire [31:0] IO_HEADER3_VALUE,
    input  wire [0:0] IO_JITT_RSTN_IN_VALUE,
    input  wire [5:0] IO_JITT1_GPIO_IN_VALUE,
    input  wire [5:0] IO_JITT2_GPIO_IN_VALUE,
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
localparam ADDR_JITT_RSTN_IN = 'h00000010;
localparam ADDR_JITT_RSTN_OUT = 'h00000014;
localparam ADDR_JITT_RSTN_CFG = 'h00000018;
localparam ADDR_JITT1_GPIO_IN = 'h00000020;
localparam ADDR_JITT1_GPIO_OUT = 'h00000024;
localparam ADDR_JITT1_GPIO_CFG = 'h00000028;
localparam ADDR_JITT2_GPIO_IN = 'h00000030;
localparam ADDR_JITT2_GPIO_OUT = 'h00000034;
localparam ADDR_JITT2_GPIO_CFG = 'h00000038;

localparam ADDR_HEADER0_VALUE = 'h00000000;
localparam ADDR_HEADER1_VALUE = 'h00000004;
localparam ADDR_HEADER2_VALUE = 'h00000008;
localparam ADDR_HEADER3_VALUE = 'h0000000C;
localparam ADDR_JITT_RSTN_IN_VALUE = 'h00000010;
localparam ADDR_JITT_RSTN_OUT_VALUE = 'h00000014;
localparam DFLT_JITT_RSTN_OUT_VALUE = 'h00000000;
localparam ADDR_JITT_RSTN_CFG_VALUE = 'h00000018;
localparam DFLT_JITT_RSTN_CFG_VALUE = 'h00000001;
localparam ADDR_JITT1_GPIO_IN_VALUE = 'h00000020;
localparam ADDR_JITT1_GPIO_OUT_VALUE = 'h00000024;
localparam DFLT_JITT1_GPIO_OUT_VALUE = 'h00000000;
localparam ADDR_JITT1_GPIO_CFG_VALUE = 'h00000028;
localparam DFLT_JITT1_GPIO_CFG_VALUE = 'h0000003F;
localparam ADDR_JITT2_GPIO_IN_VALUE = 'h00000030;
localparam ADDR_JITT2_GPIO_OUT_VALUE = 'h00000034;
localparam DFLT_JITT2_GPIO_OUT_VALUE = 'h00000000;
localparam ADDR_JITT2_GPIO_CFG_VALUE = 'h00000038;
localparam DFLT_JITT2_GPIO_CFG_VALUE = 'h0000003F;

// ####################################################
// # 
// #   Write Registers
// # 
// ####################################################

always@(posedge sys_if_clk)
begin
    if (!sys_if_rstn)
        IO_JITT_RSTN_OUT_VALUE <= DFLT_JITT_RSTN_OUT_VALUE;
    else if ( (sys_if_addr == ADDR_JITT_RSTN_OUT_VALUE) && sys_if_wen)
        IO_JITT_RSTN_OUT_VALUE <= sys_if_wdata[0:0];
end

always@(posedge sys_if_clk)
begin
    if (!sys_if_rstn)
        IO_JITT_RSTN_CFG_VALUE <= DFLT_JITT_RSTN_CFG_VALUE;
    else if ( (sys_if_addr == ADDR_JITT_RSTN_CFG_VALUE) && sys_if_wen)
        IO_JITT_RSTN_CFG_VALUE <= sys_if_wdata[0:0];
end

always@(posedge sys_if_clk)
begin
    if (!sys_if_rstn)
        IO_JITT1_GPIO_OUT_VALUE <= DFLT_JITT1_GPIO_OUT_VALUE;
    else if ( (sys_if_addr == ADDR_JITT1_GPIO_OUT_VALUE) && sys_if_wen)
        IO_JITT1_GPIO_OUT_VALUE <= sys_if_wdata[5:0];
end

always@(posedge sys_if_clk)
begin
    if (!sys_if_rstn)
        IO_JITT1_GPIO_CFG_VALUE <= DFLT_JITT1_GPIO_CFG_VALUE;
    else if ( (sys_if_addr == ADDR_JITT1_GPIO_CFG_VALUE) && sys_if_wen)
        IO_JITT1_GPIO_CFG_VALUE <= sys_if_wdata[5:0];
end

always@(posedge sys_if_clk)
begin
    if (!sys_if_rstn)
        IO_JITT2_GPIO_OUT_VALUE <= DFLT_JITT2_GPIO_OUT_VALUE;
    else if ( (sys_if_addr == ADDR_JITT2_GPIO_OUT_VALUE) && sys_if_wen)
        IO_JITT2_GPIO_OUT_VALUE <= sys_if_wdata[5:0];
end

always@(posedge sys_if_clk)
begin
    if (!sys_if_rstn)
        IO_JITT2_GPIO_CFG_VALUE <= DFLT_JITT2_GPIO_CFG_VALUE;
    else if ( (sys_if_addr == ADDR_JITT2_GPIO_CFG_VALUE) && sys_if_wen)
        IO_JITT2_GPIO_CFG_VALUE <= sys_if_wdata[5:0];
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
reg [31:0] RDATA_JITT_RSTN_IN;
reg [31:0] RDATA_JITT_RSTN_OUT;
reg [31:0] RDATA_JITT_RSTN_CFG;
reg [31:0] RDATA_JITT1_GPIO_IN;
reg [31:0] RDATA_JITT1_GPIO_OUT;
reg [31:0] RDATA_JITT1_GPIO_CFG;
reg [31:0] RDATA_JITT2_GPIO_IN;
reg [31:0] RDATA_JITT2_GPIO_OUT;
reg [31:0] RDATA_JITT2_GPIO_CFG;

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
    RDATA_JITT_RSTN_IN = 'h0;
    RDATA_JITT_RSTN_OUT = 'h0;
    RDATA_JITT_RSTN_CFG = 'h0;
    RDATA_JITT1_GPIO_IN = 'h0;
    RDATA_JITT1_GPIO_OUT = 'h0;
    RDATA_JITT1_GPIO_CFG = 'h0;
    RDATA_JITT2_GPIO_IN = 'h0;
    RDATA_JITT2_GPIO_OUT = 'h0;
    RDATA_JITT2_GPIO_CFG = 'h0;

    RDATA_HEADER0[31:0] = IO_HEADER0_VALUE;
    RDATA_HEADER1[31:0] = IO_HEADER1_VALUE;
    RDATA_HEADER2[31:0] = IO_HEADER2_VALUE;
    RDATA_HEADER3[31:0] = IO_HEADER3_VALUE;
    RDATA_JITT_RSTN_IN[0:0] = IO_JITT_RSTN_IN_VALUE;
    RDATA_JITT_RSTN_OUT[0:0] = IO_JITT_RSTN_OUT_VALUE;
    RDATA_JITT_RSTN_CFG[0:0] = IO_JITT_RSTN_CFG_VALUE;
    RDATA_JITT1_GPIO_IN[5:0] = IO_JITT1_GPIO_IN_VALUE;
    RDATA_JITT1_GPIO_OUT[5:0] = IO_JITT1_GPIO_OUT_VALUE;
    RDATA_JITT1_GPIO_CFG[5:0] = IO_JITT1_GPIO_CFG_VALUE;
    RDATA_JITT2_GPIO_IN[5:0] = IO_JITT2_GPIO_IN_VALUE;
    RDATA_JITT2_GPIO_OUT[5:0] = IO_JITT2_GPIO_OUT_VALUE;
    RDATA_JITT2_GPIO_CFG[5:0] = IO_JITT2_GPIO_CFG_VALUE;
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
            ( {32{sys_if_addr == ADDR_JITT_RSTN_IN}} & RDATA_JITT_RSTN_IN ) | 
            ( {32{sys_if_addr == ADDR_JITT_RSTN_OUT}} & RDATA_JITT_RSTN_OUT ) | 
            ( {32{sys_if_addr == ADDR_JITT_RSTN_CFG}} & RDATA_JITT_RSTN_CFG ) | 
            ( {32{sys_if_addr == ADDR_JITT1_GPIO_IN}} & RDATA_JITT1_GPIO_IN ) | 
            ( {32{sys_if_addr == ADDR_JITT1_GPIO_OUT}} & RDATA_JITT1_GPIO_OUT ) | 
            ( {32{sys_if_addr == ADDR_JITT1_GPIO_CFG}} & RDATA_JITT1_GPIO_CFG ) | 
            ( {32{sys_if_addr == ADDR_JITT2_GPIO_IN}} & RDATA_JITT2_GPIO_IN ) | 
            ( {32{sys_if_addr == ADDR_JITT2_GPIO_OUT}} & RDATA_JITT2_GPIO_OUT ) | 
            ( {32{sys_if_addr == ADDR_JITT2_GPIO_CFG}} & RDATA_JITT2_GPIO_CFG ) | 
            'h0;
end

endmodule

