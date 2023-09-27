/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
// counter.v
//
// N-bit counter with reset, enable, init, and increment value
//
// Andrew Taylor
//
// September 12, 2005
//
//


module counter(clk, count, reset, enable);
   
   parameter WIDTH = 4;
   parameter INIT = 0;
   parameter INC = 1;

   input clk, reset, enable;
   output [WIDTH-1:0] count;
   reg [WIDTH-1:0] 	cnt;

   assign count = cnt[WIDTH-1:0];

   
   initial begin
       cnt <= INIT;
   end
   
   always @ (posedge clk )
   begin
	   if(reset) begin
	       cnt <= INIT;
	   end else begin
           if (enable) begin
	           cnt <=cnt + INC;
           end
       end
   end
endmodule
