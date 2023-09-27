/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

module qsfp_i2c_regs (
    output reg  [0:0] IO_CONTROL_RESETN_TOP,
    output reg  [0:0] IO_CONTROL_RESETN_I2C,
    output reg  [0:0] IO_CONTROL_RESETN_MUX0,
    output reg  [0:0] IO_CONTROL_RESETN_MUX1,
    output reg  [0:0] IO_CONTROL_RESETN_QSFP_0,
    output reg  [0:0] IO_CONTROL_RESETN_QSFP_1,
    output reg  [0:0] IO_CONTROL_RESETN_QSFP_2,
    output reg  [0:0] IO_CONTROL_RESETN_QSFP_3,
    input  wire [31:0] IO_HEADER0_VALUE,
    input  wire [31:0] IO_HEADER1_VALUE,
    input  wire [31:0] IO_HEADER2_VALUE,
    input  wire [31:0] IO_HEADER3_VALUE,
    input  wire [31:0] IO_STATUS_VALUE,
    input  wire [7:0] IO_STATUS_TOP_CSTATE,
    input  wire [7:0] IO_STATUS_PWR_CSTATE,
    input  wire [7:0] IO_STATUS_P0_CSTATE,
    input  wire [0:0] IO_STATUS_P0_INSERTED,
    input  wire [7:0] IO_STATUS_P1_CSTATE,
    input  wire [0:0] IO_STATUS_P1_INSERTED,
    input  wire [7:0] IO_STATUS_P2_CSTATE,
    input  wire [0:0] IO_STATUS_P2_INSERTED,
    input  wire [7:0] IO_STATUS_P3_CSTATE,
    input  wire [0:0] IO_STATUS_P3_INSERTED,
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
localparam ADDR_STATUS_TOP = 'h00000020;
localparam ADDR_STATUS_PWR = 'h00000024;
localparam ADDR_STATUS_P0 = 'h00000028;
localparam ADDR_STATUS_P1 = 'h0000002c;
localparam ADDR_STATUS_P2 = 'h00000030;
localparam ADDR_STATUS_P3 = 'h00000034;

localparam ADDR_HEADER0_VALUE = 'h00000000;
localparam ADDR_HEADER1_VALUE = 'h00000004;
localparam ADDR_HEADER2_VALUE = 'h00000008;
localparam ADDR_HEADER3_VALUE = 'h0000000C;
localparam ADDR_STATUS_VALUE = 'h00000010;
localparam ADDR_CONTROL_RESETN_TOP = 'h00000014;
localparam DFLT_CONTROL_RESETN_TOP = 'h00000000;
localparam ADDR_CONTROL_RESETN_I2C = 'h00000014;
localparam DFLT_CONTROL_RESETN_I2C = 'h00000000;
localparam ADDR_CONTROL_RESETN_MUX0 = 'h00000014;
localparam DFLT_CONTROL_RESETN_MUX0 = 'h00000000;
localparam ADDR_CONTROL_RESETN_MUX1 = 'h00000014;
localparam DFLT_CONTROL_RESETN_MUX1 = 'h00000000;
localparam ADDR_CONTROL_RESETN_QSFP_0 = 'h00000014;
localparam DFLT_CONTROL_RESETN_QSFP_0 = 'h00000000;
localparam ADDR_CONTROL_RESETN_QSFP_1 = 'h00000014;
localparam DFLT_CONTROL_RESETN_QSFP_1 = 'h00000000;
localparam ADDR_CONTROL_RESETN_QSFP_2 = 'h00000014;
localparam DFLT_CONTROL_RESETN_QSFP_2 = 'h00000000;
localparam ADDR_CONTROL_RESETN_QSFP_3 = 'h00000014;
localparam DFLT_CONTROL_RESETN_QSFP_3 = 'h00000000;
localparam ADDR_STATUS_TOP_CSTATE = 'h00000020;
localparam ADDR_STATUS_PWR_CSTATE = 'h00000024;
localparam ADDR_STATUS_P0_CSTATE = 'h00000028;
localparam ADDR_STATUS_P0_INSERTED = 'h00000028;
localparam ADDR_STATUS_P1_CSTATE = 'h0000002c;
localparam ADDR_STATUS_P1_INSERTED = 'h0000002c;
localparam ADDR_STATUS_P2_CSTATE = 'h00000030;
localparam ADDR_STATUS_P2_INSERTED = 'h00000030;
localparam ADDR_STATUS_P3_CSTATE = 'h00000034;
localparam ADDR_STATUS_P3_INSERTED = 'h00000034;

// ####################################################
// # 
// #   Write Registers
// # 
// ####################################################

always@(posedge sys_if_clk)
begin
    if (!sys_if_rstn)
        IO_CONTROL_RESETN_TOP <= DFLT_CONTROL_RESETN_TOP;
    else if ( (sys_if_addr == ADDR_CONTROL_RESETN_TOP) && sys_if_wen)
        IO_CONTROL_RESETN_TOP <= sys_if_wdata[0:0];
end

always@(posedge sys_if_clk)
begin
    if (!sys_if_rstn)
        IO_CONTROL_RESETN_I2C <= DFLT_CONTROL_RESETN_I2C;
    else if ( (sys_if_addr == ADDR_CONTROL_RESETN_I2C) && sys_if_wen)
        IO_CONTROL_RESETN_I2C <= sys_if_wdata[1:1];
end

always@(posedge sys_if_clk)
begin
    if (!sys_if_rstn)
        IO_CONTROL_RESETN_MUX0 <= DFLT_CONTROL_RESETN_MUX0;
    else if ( (sys_if_addr == ADDR_CONTROL_RESETN_MUX0) && sys_if_wen)
        IO_CONTROL_RESETN_MUX0 <= sys_if_wdata[2:2];
end

always@(posedge sys_if_clk)
begin
    if (!sys_if_rstn)
        IO_CONTROL_RESETN_MUX1 <= DFLT_CONTROL_RESETN_MUX1;
    else if ( (sys_if_addr == ADDR_CONTROL_RESETN_MUX1) && sys_if_wen)
        IO_CONTROL_RESETN_MUX1 <= sys_if_wdata[3:3];
end

always@(posedge sys_if_clk)
begin
    if (!sys_if_rstn)
        IO_CONTROL_RESETN_QSFP_0 <= DFLT_CONTROL_RESETN_QSFP_0;
    else if ( (sys_if_addr == ADDR_CONTROL_RESETN_QSFP_0) && sys_if_wen)
        IO_CONTROL_RESETN_QSFP_0 <= sys_if_wdata[4:4];
end

always@(posedge sys_if_clk)
begin
    if (!sys_if_rstn)
        IO_CONTROL_RESETN_QSFP_1 <= DFLT_CONTROL_RESETN_QSFP_1;
    else if ( (sys_if_addr == ADDR_CONTROL_RESETN_QSFP_1) && sys_if_wen)
        IO_CONTROL_RESETN_QSFP_1 <= sys_if_wdata[5:5];
end

always@(posedge sys_if_clk)
begin
    if (!sys_if_rstn)
        IO_CONTROL_RESETN_QSFP_2 <= DFLT_CONTROL_RESETN_QSFP_2;
    else if ( (sys_if_addr == ADDR_CONTROL_RESETN_QSFP_2) && sys_if_wen)
        IO_CONTROL_RESETN_QSFP_2 <= sys_if_wdata[6:6];
end

always@(posedge sys_if_clk)
begin
    if (!sys_if_rstn)
        IO_CONTROL_RESETN_QSFP_3 <= DFLT_CONTROL_RESETN_QSFP_3;
    else if ( (sys_if_addr == ADDR_CONTROL_RESETN_QSFP_3) && sys_if_wen)
        IO_CONTROL_RESETN_QSFP_3 <= sys_if_wdata[7:7];
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
reg [31:0] RDATA_STATUS_TOP;
reg [31:0] RDATA_STATUS_PWR;
reg [31:0] RDATA_STATUS_P0;
reg [31:0] RDATA_STATUS_P1;
reg [31:0] RDATA_STATUS_P2;
reg [31:0] RDATA_STATUS_P3;

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
    RDATA_STATUS_TOP = 'h0;
    RDATA_STATUS_PWR = 'h0;
    RDATA_STATUS_P0 = 'h0;
    RDATA_STATUS_P1 = 'h0;
    RDATA_STATUS_P2 = 'h0;
    RDATA_STATUS_P3 = 'h0;

    RDATA_HEADER0[31:0] = IO_HEADER0_VALUE;
    RDATA_HEADER1[31:0] = IO_HEADER1_VALUE;
    RDATA_HEADER2[31:0] = IO_HEADER2_VALUE;
    RDATA_HEADER3[31:0] = IO_HEADER3_VALUE;
    RDATA_STATUS[31:0] = IO_STATUS_VALUE;
    RDATA_CONTROL[0:0] = IO_CONTROL_RESETN_TOP;
    RDATA_CONTROL[1:1] = IO_CONTROL_RESETN_I2C;
    RDATA_CONTROL[2:2] = IO_CONTROL_RESETN_MUX0;
    RDATA_CONTROL[3:3] = IO_CONTROL_RESETN_MUX1;
    RDATA_CONTROL[4:4] = IO_CONTROL_RESETN_QSFP_0;
    RDATA_CONTROL[5:5] = IO_CONTROL_RESETN_QSFP_1;
    RDATA_CONTROL[6:6] = IO_CONTROL_RESETN_QSFP_2;
    RDATA_CONTROL[7:7] = IO_CONTROL_RESETN_QSFP_3;
    RDATA_STATUS_TOP[7:0] = IO_STATUS_TOP_CSTATE;
    RDATA_STATUS_PWR[7:0] = IO_STATUS_PWR_CSTATE;
    RDATA_STATUS_P0[7:0] = IO_STATUS_P0_CSTATE;
    RDATA_STATUS_P0[8:8] = IO_STATUS_P0_INSERTED;
    RDATA_STATUS_P1[7:0] = IO_STATUS_P1_CSTATE;
    RDATA_STATUS_P1[8:8] = IO_STATUS_P1_INSERTED;
    RDATA_STATUS_P2[7:0] = IO_STATUS_P2_CSTATE;
    RDATA_STATUS_P2[8:8] = IO_STATUS_P2_INSERTED;
    RDATA_STATUS_P3[7:0] = IO_STATUS_P3_CSTATE;
    RDATA_STATUS_P3[8:8] = IO_STATUS_P3_INSERTED;
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
            ( {32{sys_if_addr == ADDR_STATUS_TOP}} & RDATA_STATUS_TOP ) | 
            ( {32{sys_if_addr == ADDR_STATUS_PWR}} & RDATA_STATUS_PWR ) | 
            ( {32{sys_if_addr == ADDR_STATUS_P0}} & RDATA_STATUS_P0 ) | 
            ( {32{sys_if_addr == ADDR_STATUS_P1}} & RDATA_STATUS_P1 ) | 
            ( {32{sys_if_addr == ADDR_STATUS_P2}} & RDATA_STATUS_P2 ) | 
            ( {32{sys_if_addr == ADDR_STATUS_P3}} & RDATA_STATUS_P3 ) | 
            'h0;
end

endmodule

