/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

module reg_reference_logic(
    output reg  [31:0] IO_TEST0_VALUE,
    output reg  [31:0] IO_TEST1_VALUE,
    output reg  [31:0] IO_TEST2_VALUE,
    input  wire [31:0] IO_TEST3_VALUE,
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

localparam ADDR_TEST0 = 'h00000004;
localparam ADDR_TEST1 = 'h00000008;
localparam ADDR_TEST2 = 'h0000000c;
localparam ADDR_TEST3 = 'h00000010;

localparam ADDR_TEST0_VALUE = 'h00000004;
localparam DFLT_TEST0_VALUE = 'h00001111;
localparam ADDR_TEST1_VALUE = 'h00000008;
localparam DFLT_TEST1_VALUE = 'h00002222;
localparam ADDR_TEST2_VALUE = 'h0000000c;
localparam DFLT_TEST2_VALUE = 'h00003333;
localparam ADDR_TEST3_VALUE = 'h00000010;

// ####################################################
// # 
// #   Write Registers
// # 
// ####################################################

always@(posedge aclk)
begin
    if (!aresetn)
        IO_TEST0_VALUE <= DFLT_TEST0_VALUE;
    else if ( (addr == ADDR_TEST0_VALUE) && wen)
        IO_TEST0_VALUE <= wdata[31:0];
end

always@(posedge aclk)
begin
    if (!aresetn)
        IO_TEST1_VALUE <= DFLT_TEST1_VALUE;
    else if ( (addr == ADDR_TEST1_VALUE) && wen)
        IO_TEST1_VALUE <= wdata[31:0];
end

always@(posedge aclk)
begin
    if (!aresetn)
        IO_TEST2_VALUE <= DFLT_TEST2_VALUE;
    else if ( (addr == ADDR_TEST2_VALUE) && wen)
        IO_TEST2_VALUE <= wdata[31:0];
end


// ####################################################
// # 
// #   Read Data Register Definition
// # 
// ####################################################

reg [31:0] RDATA_TEST0;
reg [31:0] RDATA_TEST1;
reg [31:0] RDATA_TEST2;
reg [31:0] RDATA_TEST3;

// ####################################################
// # 
// #   Read Data Register Fill
// # 
// ####################################################

always@(*)
begin
    RDATA_TEST0 = 'h0;
    RDATA_TEST1 = 'h0;
    RDATA_TEST2 = 'h0;
    RDATA_TEST3 = 'h0;

    RDATA_TEST0[31:0] = IO_TEST0_VALUE;
    RDATA_TEST1[31:0] = IO_TEST1_VALUE;
    RDATA_TEST2[31:0] = IO_TEST2_VALUE;
    RDATA_TEST3[31:0] = IO_TEST3_VALUE;
end

// ####################################################
// # 
// #   Read Data Mux
// # 
// ####################################################

always@(*)
begin
    rdata <=
            ( {32{addr == ADDR_TEST0}} & RDATA_TEST0 ) | 
            ( {32{addr == ADDR_TEST1}} & RDATA_TEST1 ) | 
            ( {32{addr == ADDR_TEST2}} & RDATA_TEST2 ) | 
            ( {32{addr == ADDR_TEST3}} & RDATA_TEST3 ) | 
            'h0;
end

endmodule

