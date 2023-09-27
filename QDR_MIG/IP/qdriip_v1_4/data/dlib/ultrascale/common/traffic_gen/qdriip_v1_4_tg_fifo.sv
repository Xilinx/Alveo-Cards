/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

******************************************************************************/
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor             : Xilinx
// \   \   \/     Version            : 1.1
//  \   \         Application        : QDRIIP
//  /   /         Filename           : qdriip_v1_4_19_tg_top.sv
// /___/   /\     Date Last Modified : $Date: 2014/09/03 $
// \   \  /  \    Date Created       : Thu May 22 2014
//  \___\/\___\
//
// Device           : UltraScale
// Design Name      : Traffic Generator
// Purpose:
// Simple FIFO for TG timing fix
//
// Reference        :
// Revision History :
//*****************************************************************************

`timescale 1ps / 1ps

module qdriip_v1_4_19_tg_fifo
  #(
    parameter TCQ = 100,
    parameter WIDTH  = 576,
    parameter DEPTH = 4,
    parameter LOG2DEPTH  = 2
    )
(
 input 		    clk,
 input 		    rst,
 input 		    wren,
 input 		    rden,
 input [WIDTH-1:0]  din,
 output [WIDTH-1:0] dout,
 output reg 	    full,
 output reg 	    empty
 );

   reg [WIDTH-1:0]  data[DEPTH-1:0];
   reg [LOG2DEPTH-1:0] rdptr;
   reg [LOG2DEPTH-1:0] wrptr;   
   reg [LOG2DEPTH:0] cnt;

   wire 	     write;
   wire 	     read;
   reg [LOG2DEPTH:0] cnt_nxt;
   
   assign write = wren && ~full;
   assign read  = rden && ~empty;
   
   always@(posedge clk) begin
      if (rst) begin
	 rdptr <= #TCQ 'h0;
	 wrptr <= #TCQ 'h0;
      end
      else begin
	 if (write) begin
	    wrptr       <= #TCQ wrptr + 'h1;
	    data[wrptr[LOG2DEPTH-1:0]] <= #TCQ din;
	 end
	 if (read) begin
	    rdptr <= #TCQ rdptr + 'h1;
	 end
      end

      if (rst) begin
	 cnt   <= #TCQ 'h0;
	 full  <= #TCQ 'h0;
	 empty <= #TCQ 'h1;
      end
      else begin
	 cnt   <= #TCQ cnt_nxt;
	 full  <= #TCQ (cnt_nxt == DEPTH);
	 empty <= #TCQ (cnt_nxt == 'h0);
      end
   end

   always@(*) begin
      casez ({write, read})
	2'b00: cnt_nxt = cnt;
	2'b01: cnt_nxt = cnt-'h1;
	2'b10: cnt_nxt = cnt+'h1;
	2'b11: cnt_nxt = cnt;	
      endcase
   end
   
   assign dout  = data[rdptr[LOG2DEPTH-1:0]];
//   assign full  = (rdptr[LOG2DEPTH] != wrptr[LOG2DEPTH]) && 
//		    (rdptr[LOG2DEPTH-1:0] == wrptr[LOG2DEPTH-1:0]);
//   assign empty = (rdptr == wrptr);

endmodule
