/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`timescale 1ns/1ns

module tb();

reg clk;
initial
begin
    clk = 'h0;
    forever
    begin
        clk = #10 ~clk;
    end
end

reg rst;
initial
begin
    rst = 1'b1;
    repeat (10) @(posedge clk);
    rst = 1'b0;
end

// ---------------------------------------------------------------

reg [31:0] timer;
always@(posedge clk)
begin
    if (rst)
        timer <= 'h0;
    else
        timer <= timer + 1;
end

// ---------------------------------------------------------------


wire        IO_CONTROL_PULSE ;
wire  [0:0] IO_CONTROL_RW    ;
wire  [7:0] IO_CONTROL_ID    ;
wire  [7:0] IO_ADDR_ADDR     ;
wire  [7:0] IO_WDATA_WDATA   ;
reg   [7:0] IO_RDATA_RDATA   ;
wire        IO_CONTROL_CMPLT ;

reg   [7:0] array [0:1024];

reg [15:0] delay;

always@(posedge clk)
begin
    if (IO_CONTROL_PULSE && ~IO_CONTROL_RW && (IO_CONTROL_ID == 'h42))
        array[IO_ADDR_ADDR] <= IO_WDATA_WDATA;
end

// ---------------------------------------------------------------
// SB Control/Status bits
//   0 - LPMODE    (output, 0 = hw control, high power)
//   1 - INTL      (input,  0 = interrupt)
//   2 - MODPRSTL  (input,  0 = present)
//   3 - MODSELL   (output, 0 = I2C enable)
//   4 - RESETL    (output, 1 = enabled)


reg  LPMODE   ; // (output, 0 = hw control, high power)
wire INTL     = 1'b1; // (input,  0 = interrupt)
reg  MODPRSTL ; // (input,  0 = present)
reg  MODSELL  ; // (output, 0 = I2C enable)
reg  RESETL   ; // (output, 1 = enabled)

initial
begin
    MODPRSTL <= 1'b1;
    #80000
    MODPRSTL <= 1'b0;
    #40000
    MODPRSTL <= 1'b1;
    #40000
    MODPRSTL <= 1'b0;
end    

always@(posedge clk)
begin
    if (IO_CONTROL_PULSE && IO_CONTROL_RW && (IO_CONTROL_ID == 'h40))
        IO_RDATA_RDATA <= { 3'h0,
                            RESETL, 
                            MODSELL,
                            MODPRSTL ,
                            INTL,
                            LPMODE};
end

always@(posedge clk)
begin
    if (IO_CONTROL_PULSE && ~IO_CONTROL_RW && (IO_CONTROL_ID == 'h40))
    begin
        LPMODE   <= IO_WDATA_WDATA[0];
        //INTL     <= IO_WDATA_WDATA[1];
        //MODPRSTL <= IO_WDATA_WDATA[2];
        MODSELL  <= IO_WDATA_WDATA[3];
        RESETL   <= IO_WDATA_WDATA[4];
    end
end

always@(posedge clk)
begin
    if (rst)
        delay <= 'h0;
    else
        delay <= {delay[14:0], IO_CONTROL_PULSE};
end

assign IO_CONTROL_CMPLT = delay[15];
//assign IO_RDATA_RDATA   = array[IO_ADDR_ADDR];        

// ---------------------------------------------------------------

//state_machine_top state_machine_top (
//    .clk              ( clk               ),
//    .rst              ( rst               ),
//
//    .IO_CONTROL_PULSE ( IO_CONTROL_PULSE  ),
//    .IO_CONTROL_RW    ( IO_CONTROL_RW     ),
//    .IO_CONTROL_ID    ( IO_CONTROL_ID     ),
//    .IO_ADDR_ADDR     ( IO_ADDR_ADDR      ),
//    .IO_WDATA_WDATA   ( IO_WDATA_WDATA    ),
//    .IO_RDATA_RDATA   ( IO_RDATA_RDATA    ),
//    .IO_CONTROL_CMPLT ( IO_CONTROL_CMPLT  )
//);

endmodule
