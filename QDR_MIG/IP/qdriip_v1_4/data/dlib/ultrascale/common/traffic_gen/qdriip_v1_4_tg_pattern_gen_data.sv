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
//  /   /         Filename           : qdriip_v1_4_19_tg_pattern_gen_data.sv
// /___/   /\     Date Last Modified : $Date: 2014/09/03 $
// \   \  /  \    Date Created       : Thu May 22 2014
//  \___\/\___\
//
// Device           : UltraScale
// Design Name      : Traffic Generator
// Purpose:
// This is data pattern generation block.
// Data patterns supported are:
// - PRBS (PRBS block is modified from 7Series traffic generator), PRBS 8,10,23 are supprted
// - Linear
// - Walking0/1
// - Hammer0/1
//
// Reference        :
// Revision History :
//*****************************************************************************

`timescale 1ps / 1ps

// Data Pattern Generation
module qdriip_v1_4_19_tg_pattern_gen_data
  #(
    parameter TCQ            = 100,    
    parameter APP_DATA_WIDTH = 288,
    parameter NUM_DQ_PINS    = 36,
    parameter nCK_PER_CLK    = 4,
    parameter NUM_PORT       = 1,
    parameter PRBS_WIDTH     = 23
    )
   (
    input 				     clk,
    input 				     rst,
    //input 			    calib_complete,
    input 				     pattern_load,
    input 				     pattern_done, 
    input [PRBS_WIDTH-1:0] 		     pattern_prbs_seed[NUM_DQ_PINS*NUM_PORT-1:0],
    input [APP_DATA_WIDTH*NUM_PORT-1:0]      pattern_linear_seed,
    input [3:0] 			     pattern_mode,
    input 		     pattern_en,
    input 				     pattern_hold,
    output reg 				     pattern_valid,
    output reg [APP_DATA_WIDTH*NUM_PORT-1:0] pattern_out
    );

   integer 				     i, j;
   reg 					     pattern_int_valid;
   reg [APP_DATA_WIDTH*NUM_PORT-1:0] 	     pattern_int;

   localparam TG_PATTERN_MODE_LINEAR   = 4'b0000;   
   localparam TG_PATTERN_MODE_PRBS     = 4'b0001;
   localparam TG_PATTERN_MODE_WALKING1 = 4'b0010;
   localparam TG_PATTERN_MODE_WALKING0 = 4'b0011;
   localparam TG_PATTERN_MODE_HAMMER1  = 4'b0100;
   localparam TG_PATTERN_MODE_HAMMER0  = 4'b0101;
   localparam TG_PATTERN_MODE_BRAM     = 4'b0110;
   localparam TG_PATTERN_LOG2_NUM_BRAM_ENTRY = 9;
   
   //***********************************************   
   // PRBS engine
   wire [NUM_DQ_PINS*2*nCK_PER_CLK*NUM_PORT-1:0]  prbs_vec;
   qdriip_v1_4_19_tg_data_prbs 
     #(
       .TCQ(TCQ),
       //.APP_DATA_WIDTH(APP_DATA_WIDTH),
       .NUM_DQ_PINS(NUM_DQ_PINS),
       .nCK_PER_CLK(nCK_PER_CLK),
       .NUM_PORT(NUM_PORT),
       .PRBS_WIDTH(PRBS_WIDTH)
       ) qdriip_v1_4_19_u_data_prbs
       (
	.clk(clk),
	.rst(rst),
	.prbs_seed(pattern_prbs_seed),
	.prbs_load_seed(pattern_load),
	.prbs_en(pattern_en && ~pattern_hold),
	.prbs_vec(prbs_vec)
	);

   //***********************************************
   // Linear engine
   reg [NUM_DQ_PINS-1:0] 		 linear[2*nCK_PER_CLK*NUM_PORT];
   reg [NUM_DQ_PINS*2*nCK_PER_CLK*NUM_PORT-1:0]  linear_vec;
   always@(posedge clk) begin
      for (i=0; i<(2*nCK_PER_CLK*NUM_PORT); i=i+1) begin : gen_lbl_linear
	 if (pattern_load) begin
	    //linear[i] <= #TCQ pattern_linear_seed[NUM_DQ_PINS*i +: NUM_DQ_PINS];
	    linear_vec[NUM_DQ_PINS*i +: NUM_DQ_PINS] <= #TCQ pattern_linear_seed[NUM_DQ_PINS*i +: NUM_DQ_PINS];
	 end
	    else if (pattern_en && ~pattern_hold) begin
	       //linear[i] <= #TCQ linear[i] + 2*nCK_PER_CLK;
	       linear_vec[NUM_DQ_PINS*i +: NUM_DQ_PINS] <= #TCQ linear_vec[NUM_DQ_PINS*i +: NUM_DQ_PINS] + 2*nCK_PER_CLK*NUM_PORT;
	    end
      end
   end

   //***********************************************
   // Walking 1/0 engine
   reg [NUM_DQ_PINS-1:0] 		 walking[2*nCK_PER_CLK*NUM_PORT];
   reg [NUM_DQ_PINS*2*nCK_PER_CLK*NUM_PORT-1:0]  walking_vec;   
   reg 					 walking_select;

   always@(posedge clk) begin
      walking_select <= #TCQ (pattern_mode == TG_PATTERN_MODE_WALKING1);
   end
      
   always@(posedge clk) begin
      for (i=0; i<(2*nCK_PER_CLK*NUM_PORT); i=i+1) begin : gen_lbl_walking_i
	 for (j=0; j<NUM_DQ_PINS; j=j+1) begin : gen_lbl_walking_j

	       if (pattern_load) begin
		  walking[i][j] <= #TCQ (i == j);
	       end
	       else if (pattern_en && ~pattern_hold) begin
		  if (j==0) begin
		     if (i==0) begin
			walking[i][0] <= #TCQ walking[2*nCK_PER_CLK-1][NUM_DQ_PINS-1];
		     end
		     else begin
			walking[i][0] <= #TCQ walking[i-1][NUM_DQ_PINS-1];
		     end
		  end
		  else begin
		     walking[i][j] <= #TCQ walking[i][j-1];
		  end
	       end
	    end
	 end
   end
   always@(*) begin
      for (i=0; i<(2*nCK_PER_CLK*NUM_PORT); i=i+1) begin : gen_lbl_walking_i_2
	 walking_vec[NUM_DQ_PINS*i +: NUM_DQ_PINS] = walking_select ? walking[i] : ~walking[i];
      end
   end

   //***********************************************
   // Hammer engine
   reg [NUM_DQ_PINS-1:0] 		 hammer[2*nCK_PER_CLK*NUM_PORT];
   reg [NUM_DQ_PINS*2*nCK_PER_CLK*NUM_PORT-1:0] 	 hammer_vec;
   reg 					 hammer_select;

   always@(posedge clk) begin
      hammer_select <= #TCQ (pattern_mode == TG_PATTERN_MODE_HAMMER1);
   end
      
   always@(*) begin
      for (i=0; i<(2*nCK_PER_CLK*NUM_PORT); i=i+1) begin : gen_lbl_hammer
	 hammer[i] = (i%2)?{NUM_DQ_PINS{1'b0}}:{NUM_DQ_PINS{1'b1}};
	 hammer_vec[NUM_DQ_PINS*i +: NUM_DQ_PINS] = hammer_select ? hammer[i] : ~hammer[i];
      end
   end
   
   //***********************************************
   // BRAM engine
   // TBD
   wire [NUM_DQ_PINS*2*nCK_PER_CLK*NUM_PORT-1:0]  bram_vec;
   wire [NUM_DQ_PINS*2*nCK_PER_CLK*NUM_PORT-1:0]  bram_out;
   reg [TG_PATTERN_LOG2_NUM_BRAM_ENTRY-1:0] bram_ptr;

   qdriip_v1_4_19_tg_pattern_gen_data_bram
     #(
       .TCQ(TCQ),
       //.APP_DATA_WIDTH(APP_DATA_WIDTH),
       .NUM_DQ_PINS(NUM_DQ_PINS),
       .nCK_PER_CLK(nCK_PER_CLK),
       .TG_PATTERN_LOG2_NUM_BRAM_ENTRY(TG_PATTERN_LOG2_NUM_BRAM_ENTRY)
       )
   u_qdriip_v1_4_19_tg_pattern_gen_data_bram
     (
      .bram_ptr(bram_ptr),
      .bram_out(bram_out)
      );
   
   always@(posedge clk) begin
      if (pattern_load) begin
	 bram_ptr = {TG_PATTERN_LOG2_NUM_BRAM_ENTRY{1'b0}};
      end
      else if (pattern_en && ~pattern_hold) begin
	 bram_ptr = bram_ptr + 'b1;
      end
   end

   assign bram_vec = bram_out;
   
   //***********************************************
   // output select
//   reg 	pattern_load_status;
//   always@(posedge clk) begin
//      if (rst) begin
//	 pattern_int_valid <= #TCQ 1'b0;
//      end
//      else begin
//	 pattern_int_valid <= #TCQ pattern_load ? 1'b1 : pattern_done ? 1'b0 : pattern_int_valid;
//      end
//   end
   
   always@(*) begin
      casez (pattern_mode)
	TG_PATTERN_MODE_LINEAR:     pattern_int = linear_vec;
	TG_PATTERN_MODE_PRBS:       pattern_int = prbs_vec;
	TG_PATTERN_MODE_WALKING1,
	  TG_PATTERN_MODE_WALKING0: pattern_int = walking_vec;
	TG_PATTERN_MODE_HAMMER1,
	  TG_PATTERN_MODE_HAMMER0:  pattern_int = hammer_vec;
	TG_PATTERN_MODE_BRAM:       
	  begin
	     pattern_int = bram_vec;
	     //synthesis translate_off
	     //assert (rst!=1'b0 || pattern_en!=1'b1 /*|| calib_complete!=1'b1*/) else begin $display ($time, "Warning: BRAM mode not supported for data mode\n"); end
	     //synthesis translate_on
	  end
	default: begin
           pattern_int = 'h0;
	     //synthesis translate_off
	     //assert (rst!=1'b0 || pattern_en!=1'b1 /*|| calib_complete!=1'b1*/) else begin $display ($time, "Warning: User programmed unsupported data mode %x\n", pattern_mode); end
	     //synthesis translate_on
	end
      endcase
   end

   //synthesis translate_off
   always@(posedge clk) begin
      if (!rst && pattern_en) begin
	 assert (pattern_mode == TG_PATTERN_MODE_LINEAR    ||
		 pattern_mode == TG_PATTERN_MODE_PRBS      ||
		 pattern_mode == TG_PATTERN_MODE_WALKING0  ||
		 pattern_mode == TG_PATTERN_MODE_WALKING1  ||
		 pattern_mode == TG_PATTERN_MODE_HAMMER0  ||
		 pattern_mode == TG_PATTERN_MODE_HAMMER1  ||
		 pattern_mode == TG_PATTERN_MODE_BRAM) 
	   else begin
	      $display ($time, "Warning: User programmed unsupported data mode %x\n", pattern_mode); 
	   end	      
      end
   end
   //synthesis translate_on
   
   always@(posedge clk) begin
      if (rst | pattern_load) begin
	 pattern_valid <= #TCQ 1'b0;
      end
      else if (pattern_en && ~pattern_hold /*&& pattern_int_valid*/) begin
	 pattern_valid <= #TCQ 1'b1 /*pattern_int_valid*/;
	 pattern_out   <= #TCQ pattern_int;
      end
   end
   
endmodule // qdriip_v1_4_19_tg_pattern_gen_data

