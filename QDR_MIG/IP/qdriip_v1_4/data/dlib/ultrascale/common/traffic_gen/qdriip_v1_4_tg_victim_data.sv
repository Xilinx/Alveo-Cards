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
//  /   /         Filename           : qdriip_v1_4_19_tg_victim_data.sv
// /___/   /\     Date Last Modified : $Date: 2014/09/03 $
// \   \  /  \    Date Created       : Thu May 22 2014
//  \___\/\___\
//
// Device           : UltraScale
// Design Name      : Traffic Generator
// Purpose:
// This is victim pattern generation block.
// User select one bit out of input data bus as victim bit.
// Differnt aggressor pattern could be programmed.
// Victim patterns supported are:
// - No operation (Input data pattern same as output data pattern)
// - All data signals held at 1 except victim signal (follows input data pattern)
// - All data signals held at 0 except victim signal (follows input data pattern)
// - All data signals is inversion of victim siganl
// - All data signals is delayed version of victim signal
// Reference        :
// Revision History :
//*****************************************************************************

`timescale 1ps / 1ps

// Data Pattern Generation
module qdriip_v1_4_19_tg_victim_data
  #(
    parameter TCQ            = 100,    
    parameter APP_DATA_WIDTH = 576,
    parameter NUM_DQ_PINS    = 72,
    parameter nCK_PER_CLK    = 4,
    parameter MEM_TYPE       = "DDR3",
    parameter MEM_ARCH       = "ULTRASCALE"
    )
   (
    input 			    clk,
    input 			    rst,
    //input 			    calib_complete,
    input [2:0] 		    victim_mode,
    input [7:0] 		    victim_bit,
    input [4:0] 		    victim_aggr_delay,
    input                	    victim_en,
    input 			    victim_hold,
    input [APP_DATA_WIDTH-1:0] 	    victim_in, 
    output reg 			    victim_valid,
    output reg [APP_DATA_WIDTH-1:0] victim_out
    );

   localparam TG_LOG2_MAX_AGGR_DELAY = 2; // Total delay stage is TG_MAX_AGGR_DELAY*2*nCK_PER_CLK = (2**2)*8
   localparam TG_MAX_AGGR_DELAY = 2**TG_LOG2_MAX_AGGR_DELAY;

   localparam TG_VICTIM_MODE_NO_VICTIM     = 3'b000;
   localparam TG_VICTIM_MODE_HELD1         = 3'b001;
   localparam TG_VICTIM_MODE_HELD0         = 3'b010;   
   localparam TG_VICTIM_MODE_NONINV_AGGR   = 3'b011;
   localparam TG_VICTIM_MODE_INV_AGGR      = 3'b100;
   localparam TG_VICTIM_MODE_DELAYED_AGGR  = 3'b101;
   
   reg 				       victim_int0_valid;
   reg [APP_DATA_WIDTH-1:0] 	       victim_int0;
   reg 				       victim_int1_valid;
   reg [APP_DATA_WIDTH-1:0] 	       victim_int1;
   reg 				       victim_int2_valid;
   reg [APP_DATA_WIDTH-1:0] 	       victim_int2;
   //reg 				       victim_int3_valid;   
   reg [NUM_DQ_PINS-1:0] 	       victim_nxt0[2*nCK_PER_CLK];
   reg [NUM_DQ_PINS-1:0] 	       victim_nxt0_r[2*nCK_PER_CLK];
   reg [NUM_DQ_PINS-1:0] 	       victim_nxt1[2*nCK_PER_CLK];
   reg [NUM_DQ_PINS-1:0] 	       victim_nxt1_r[2*nCK_PER_CLK];
   reg [NUM_DQ_PINS-1:0] 	       victim_nxt2[2*nCK_PER_CLK];
   reg [NUM_DQ_PINS-1:0] 	       victim_nxt2_r[2*nCK_PER_CLK];
   reg [NUM_DQ_PINS-1:0] 	       victim_mask[2*nCK_PER_CLK];
   wire [2*nCK_PER_CLK-1:0] 	       victim_vec;
   reg [NUM_DQ_PINS-1:0] 	       victim_int0_mask[2*nCK_PER_CLK];
   reg [NUM_DQ_PINS-1:0] 	       victim_int1_mask[2*nCK_PER_CLK];
   reg [NUM_DQ_PINS-1:0] 	       victim_int2_mask[2*nCK_PER_CLK];
   reg [11:0] 			       victim_num[2*nCK_PER_CLK];
   reg [11:0] 			       victim_int0_num[2*nCK_PER_CLK];
   reg [2*nCK_PER_CLK-1:0] 	       victim_int1_vec;
   reg [TG_MAX_AGGR_DELAY*2*nCK_PER_CLK-1:0] 	       delayed_aggr_bit_int1;
   wire [TG_MAX_AGGR_DELAY*2*nCK_PER_CLK-1:0] delayed_aggr_vec_int1;
   reg [2*nCK_PER_CLK-1:0] 		      delayed_aggr_vec_int2;
   //reg [7:0] 				      victim_aggr_delay_num[2*nCK_PER_CLK];
   reg [5:0] 				      victim_aggr_delay_int0;
   reg [7:0] 				      victim_aggr_delay_num_int1;
   integer 				      i,j;

   //***********************************************
   always@(*) begin
      for (i=0; i<(2*nCK_PER_CLK); i=i+1) begin : gen_lbl_victim	 
	 victim_mask[i] = ('h1 << victim_bit);
	 victim_num[i]  = NUM_DQ_PINS*i+victim_bit;
	 
	 case (victim_mode)
	   TG_VICTIM_MODE_NO_VICTIM: begin
	      victim_nxt0[i] = victim_int0[NUM_DQ_PINS*i +: NUM_DQ_PINS];
	      victim_nxt1[i] = victim_nxt0_r[i];
	      victim_nxt2[i] = victim_nxt1_r[i];
	   end
	   TG_VICTIM_MODE_HELD1: begin
	      victim_nxt0[i] = victim_int0[NUM_DQ_PINS*i +: NUM_DQ_PINS] | ~victim_int0_mask[i];
	      victim_nxt1[i] = victim_nxt0_r[i];
	      victim_nxt2[i] = victim_nxt1_r[i];
	   end
	   TG_VICTIM_MODE_HELD0: begin
	      victim_nxt0[i] = victim_int0[NUM_DQ_PINS*i +: NUM_DQ_PINS] & victim_int0_mask[i];
	      victim_nxt1[i] = victim_nxt0_r[i];
	      victim_nxt2[i] = victim_nxt1_r[i];
	   end
	   TG_VICTIM_MODE_NONINV_AGGR: begin
	      victim_nxt0[i] = victim_int0[NUM_DQ_PINS*i +: NUM_DQ_PINS]; // Dummy
	      //victim_nxt0[i] = 'b0; // Dummy
	      victim_nxt1[i] = (victim_int1[NUM_DQ_PINS*i +: NUM_DQ_PINS] & victim_int1_mask[i]) |
			       ({NUM_DQ_PINS{victim_int1_vec[i]}} & ~victim_int1_mask[i]);
	      victim_nxt2[i] = victim_nxt1_r[i];
	   end
	   TG_VICTIM_MODE_INV_AGGR: begin
	      //		 victim_nxt0[i] = (victim_int0[NUM_DQ_PINS*i +: NUM_DQ_PINS] & victim_int0_mask[i]) |
	      //				 ({NUM_DQ_PINS{~victim_int0[(NUM_DQ_PINS*i)+victim_bit]}} & ~victim_int0_mask[i]);
	      victim_nxt0[i] = victim_int0[NUM_DQ_PINS*i +: NUM_DQ_PINS]; // Dummy
	      //victim_nxt0[i] = 'b0; // Dummy
	      victim_nxt1[i] = (victim_int1[NUM_DQ_PINS*i +: NUM_DQ_PINS] & victim_int1_mask[i]) |
			       ({NUM_DQ_PINS{~victim_int1_vec[i]}} & ~victim_int1_mask[i]);
	      victim_nxt2[i] = victim_nxt1_r[i];
	   end
	   TG_VICTIM_MODE_DELAYED_AGGR: begin	 
	      //		 victim_nxt1[i] = (victim_int1[NUM_DQ_PINS*i +: NUM_DQ_PINS] & victim_int1_mask[i]) |
	      //				 ({NUM_DQ_PINS{delayed_aggr_vec[victim_aggr_delay_num[i]]}} & ~victim_int1_mask[i]);
	      victim_nxt0[i] = victim_int0[NUM_DQ_PINS*i +: NUM_DQ_PINS]; // Dummy
	      victim_nxt1[i] = victim_nxt0_r[i]; // Dummy
	      //victim_nxt0[i] = 'b0; // Dummy
	      //victim_nxt1[i] = 'b01; // Dummy
	      victim_nxt2[i] = (victim_int2[NUM_DQ_PINS*i +: NUM_DQ_PINS] & victim_int2_mask[i]) |
			       ({NUM_DQ_PINS{delayed_aggr_vec_int2[i]}} & ~victim_int2_mask[i]);
	      //				 ({NUM_DQ_PINS{victim_int1_vec[i]}} & ~victim_int2_mask[i]);
	   end
  	   default: begin
	      victim_nxt0[i] = victim_int0[NUM_DQ_PINS*i +: NUM_DQ_PINS];
	      victim_nxt1[i] = victim_nxt0_r[i];
	      victim_nxt2[i] = victim_nxt1_r[i];
	      //synthesis translate_off
	      //assert (rst!=1'b0 || victim_en!=1'b1 /*|| calib_complete!=1'b1*/) else begin $display ($time, "Warning: User programmed unsupported victim mode %x\n", victim_mode); end
	      //synthesis translate_on
	   end
	 endcase
      end
   end

   //synthesis translate_off
   always@(posedge clk) begin
      if (!rst && victim_en) begin
	 assert (victim_mode == TG_VICTIM_MODE_NO_VICTIM ||
		 victim_mode == TG_VICTIM_MODE_HELD1 ||
		 victim_mode == TG_VICTIM_MODE_HELD0 ||
		 victim_mode == TG_VICTIM_MODE_NONINV_AGGR ||
		 victim_mode == TG_VICTIM_MODE_INV_AGGR ||
		 victim_mode == TG_VICTIM_MODE_DELAYED_AGGR) 
	   else begin
	      $display ($time, "Warning: User programmed unsupported victim mode %x\n", victim_mode); 
	   end	      
      end
   end
   //synthesis translate_on
   
   always@(posedge clk) begin   
      for (i=1; i<TG_MAX_AGGR_DELAY; i=i+1) begin : gen_lbl_aggr_delay
	 if (rst) begin
	    delayed_aggr_bit_int1 <= #TCQ 'h0;	       
	 end
	 else if (victim_en && ~victim_hold) begin
	    if (i==(TG_MAX_AGGR_DELAY-1)) begin
	       delayed_aggr_bit_int1[i*2*nCK_PER_CLK +: 2*nCK_PER_CLK]     <= #TCQ victim_int1_vec;
	    end
	    delayed_aggr_bit_int1[(i-1)*2*nCK_PER_CLK +: 2*nCK_PER_CLK] <= #TCQ delayed_aggr_bit_int1[i*2*nCK_PER_CLK +: 2*nCK_PER_CLK];
	 end
      end
   end

   assign delayed_aggr_vec_int1 = {victim_int1_vec, delayed_aggr_bit_int1[2*nCK_PER_CLK +: ((TG_MAX_AGGR_DELAY-1)*2*nCK_PER_CLK)]};

   always@(posedge clk) begin
      if (rst) begin
	 victim_aggr_delay_int0 <= #TCQ 'h0;
	 delayed_aggr_vec_int2  <= #TCQ 'h0;
      end
      else if (victim_en && ~victim_hold) begin
	 victim_aggr_delay_int0     <= #TCQ victim_aggr_delay;
	 victim_aggr_delay_num_int1 <= #TCQ (TG_MAX_AGGR_DELAY-1)*2*nCK_PER_CLK-victim_aggr_delay_int0;
	 delayed_aggr_vec_int2      <= #TCQ delayed_aggr_vec_int1[victim_aggr_delay_num_int1 +: 2*nCK_PER_CLK];
      end
   end
     
   always@(posedge clk) begin
      if (rst) begin
	 victim_int0_valid <= #TCQ 1'b0;
	 victim_int1_valid <= #TCQ 1'b0;
	 victim_int2_valid <= #TCQ 1'b0;
	 //victim_int3_valid <= #TCQ 1'b0;
	 victim_valid      <= #TCQ 1'b0;
	 victim_int0        <= #TCQ 'h0;
	 victim_int1        <= #TCQ 'h0;	 
	 victim_int2        <= #TCQ 'h0;	 
      end
      else if (victim_en && ~victim_hold) begin
	 victim_int0_valid <= #TCQ victim_en;
	 victim_int1_valid <= #TCQ victim_int0_valid;
	 victim_int2_valid <= #TCQ victim_int1_valid;
	 //victim_int3_valid <= #TCQ victim_int2_valid;
	 victim_valid      <= #TCQ victim_int2_valid;
	 victim_int0        <= #TCQ victim_in;
	 victim_int1        <= #TCQ victim_int0;
	 victim_int2        <= #TCQ victim_int1;
      end
   end

   always@(posedge clk) begin   
      for (i=0; i<(2*nCK_PER_CLK); i=i+1) begin : gen_lbl_victim_out
	 if (rst) begin
	    victim_int1_vec[i]  <= #TCQ 'h0;
	    victim_int0_num[i]  <= #TCQ victim_num[i];
	 end
	 else if (victim_en && ~victim_hold) begin
	    victim_int0_mask[i] <= #TCQ victim_mask[i];
	    victim_int1_mask[i] <= #TCQ victim_int0_mask[i];
	    victim_int2_mask[i] <= #TCQ victim_int1_mask[i];
	    victim_int0_num[i]  <= #TCQ victim_num[i];
	    victim_int1_vec[i]  <= #TCQ victim_int0[victim_int0_num[i]];
	    victim_nxt0_r[i]    <= #TCQ victim_nxt0[i];
	    victim_nxt1_r[i]    <= #TCQ victim_nxt1[i];
	 end
      end
   end
   
   always@(posedge clk) begin
      for (i=0; i<(2*nCK_PER_CLK); i=i+1) begin : gen_lbl_victim_out3_i
	 for (j=0; j<NUM_DQ_PINS/2/nCK_PER_CLK; j=j+1) begin : gen_lbl_victim_out3_j
	    if (victim_en && ~victim_hold) begin
	       if ((MEM_ARCH == "7SERIES") || 
		   ((MEM_ARCH == "ULTRASCALE") && (MEM_TYPE == "RLD3" || MEM_TYPE == "QDRIIP" || MEM_TYPE == "QDRIV"))) begin
		  victim_out[NUM_DQ_PINS*i +: NUM_DQ_PINS]  <= #TCQ victim_nxt2[i];		     
	       end
	       else begin // DDR3/DDR4
		  victim_out[(8*2*nCK_PER_CLK)*j+8*i +: 8] <= #TCQ victim_nxt2[i][(2*nCK_PER_CLK)*j +: 2*nCK_PER_CLK];
	       end
	    end
	 end
      end
   end

endmodule // tg_victim_data
