/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`timescale 1ns / 1ns

module RC38612A002GN2 #(
    parameter [7:0] DEVICE_ID = 'hB0
)(
    input  wire  enable  ,
    input  wire  scl_io  ,
    inout  wire  sda_io   
);

// ---------------------------------------------------

reg  [7:0] reg_array [0:255];

integer ii;
initial
begin
    for(ii=0;ii<256;ii=ii+1) begin
        reg_array[ii] <= 'h00;
    end
end 

// ---------------------------------------------------

reg RST;

initial 
begin
    RST <= 1'b0;
    #10;
    RST <= 1'b1;
    #10;
    RST <= 1'b0;
end

// ---------------------------------------------------

wire       addr_strobe  ;
wire       write_strobe ;
wire       read_strobe  ;
wire [7:0] wdata        ;
reg  [7:0] rdata        ;

i2c_slave_if #( 
    .device_address (DEVICE_ID) 
) i2c_slave_if (
    .enable       ( enable       ) ,
    .scl_io       ( scl_io       ) ,
    .sda_io       ( sda_io       ) ,
    .addr_strobe  ( addr_strobe  ) ,
    .write_strobe ( write_strobe ) ,
    .read_strobe  ( read_strobe  ) ,
    .wdata        ( wdata        ) ,
    .rdata        ( rdata        ) 
);

// ---------------------------------------------------

reg [7:0] addr ;
reg [7:0] wdata_tmp ; 

always@(posedge addr_strobe)
    addr <= wdata;

always@(posedge write_strobe)
    wdata_tmp <= wdata;

always @(negedge write_strobe)
    reg_array[addr] <= wdata_tmp;

always @(posedge addr_strobe)
    rdata <= reg_array[addr] ;

endmodule

