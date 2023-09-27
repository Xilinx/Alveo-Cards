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
//  /   /         Filename           : qdriip_v1_4_19_tg_pattern_gen_addr.sv
// /___/   /\     Date Last Modified : $Date: 2014/09/03 $
// \   \  /  \    Date Created       : Thu May 22 2014
//  \___\/\___\
//
// Device           : UltraScale
// Design Name      : Traffic Generator
// Purpose:
// This is address pattern generation block.
// Address patterns supported are:
// - PRBS (PRBS width covers 8 to 34 bit address)
// - Linear
// - Walking0/1
//
// Reference        :
// Revision History :
//*****************************************************************************

`timescale 1ps / 1ps

// Address Pattern Generation
module qdriip_v1_4_19_tg_pattern_gen_addr
  #(
    parameter TCQ            = 100,    
    parameter APP_ADDR_WIDTH = 32,
    parameter CMD_PER_CLK    = 1,
    parameter NUM_PORT       = 1,
    parameter PRBS_WIDTH     = 23,
    parameter NUM_OF_POLY_TAP = 2,
    parameter POLY_TAP0 = 18,
    parameter POLY_TAP1 = 23,
    parameter POLY_TAP2 = 18,
    parameter POLY_TAP3 = 23,
    parameter MEM_TYPE = "DDR3",
    parameter RLD_BANK_WIDTH = 4
    )
   (
    input 			    clk,
    input 			    rst,
    //input 			    calib_complete,
    input 			    pattern_load,
    input 			    pattern_done, 
    input [APP_ADDR_WIDTH-1:0] 	    pattern_prbs_seed,
    input [APP_ADDR_WIDTH-1:0] 	    pattern_linear_seed,
    input [3:0] 		    pattern_mode,
    input 	    pattern_en,
    input 			    pattern_hold,
    output reg 			    pattern_valid,
    output reg 			    pattern_repeat,
    output reg [APP_ADDR_WIDTH-1:0] pattern_out [CMD_PER_CLK*NUM_PORT]
    );

   integer 			    i, j;
   genvar 			    gen_i;
   localparam LOG2_APP_ADDR_WIDTH = 8; // Need a function
   localparam LOG2_CMD_PER_CLK = 2; // Need a function
   localparam TG_LOWER_ADDR_WIDTH = ((MEM_TYPE == "RLD3") || (MEM_TYPE == "RLD2")) ? RLD_BANK_WIDTH : (MEM_TYPE == "QDRIIP" ||  MEM_TYPE == "QDRIV") ? 0 : 3;
   localparam TG_LOWER_ADDR_WIDTH_1 = ((MEM_TYPE == "RLD3") || (MEM_TYPE == "RLD2")) ? RLD_BANK_WIDTH : (MEM_TYPE == "QDRIIP" ||  MEM_TYPE == "QDRIV") ? 1 : 3;
   localparam UPPER_ADDR_PER_CLK  = ((MEM_TYPE == "RLD3") || (MEM_TYPE == "RLD2")) ? 1 : CMD_PER_CLK;
   localparam LOG2_UPPER_ADDR_PER_CLK = ((MEM_TYPE == "RLD3") || (MEM_TYPE == "RLD2")) ? 1 : LOG2_CMD_PER_CLK;

   localparam TG_PATTERN_MODE_LINEAR   = 4'b0000;   
   localparam TG_PATTERN_MODE_PRBS     = 4'b0001;
   localparam TG_PATTERN_MODE_WALKING1 = 4'b0010;
   localparam TG_PATTERN_MODE_WALKING0 = 4'b0011;
   localparam TG_PATTERN_MODE_HAMMER1  = 4'b0100;
   localparam TG_PATTERN_MODE_HAMMER0  = 4'b0101;
   localparam TG_PATTERN_MODE_BRAM     = 4'b0110;

   reg [TG_LOWER_ADDR_WIDTH_1-1:0]    rld_bank_addr [CMD_PER_CLK*NUM_PORT];
   reg [CMD_PER_CLK*NUM_PORT-1:0]   rld_upper_addr_en_i;
   wire 			    rld_upper_addr_en;
   wire 			    local_pattern_en;

   generate
      if ((MEM_TYPE == "RLD3") || (MEM_TYPE == "RLD2")) begin
	 assign local_pattern_en = rld_upper_addr_en;
      end
      else begin
	 assign local_pattern_en = pattern_en;
      end
   endgenerate
   
   
   reg 			       pattern_int0_valid;
   reg 			       pattern_int0_repeat;
   reg [APP_ADDR_WIDTH-1:0]    pattern_int0 [CMD_PER_CLK*NUM_PORT];

   reg 			       pattern_int1_valid;
   reg 			       pattern_int1_repeat;
   reg [APP_ADDR_WIDTH-1:0]    pattern_int1 [CMD_PER_CLK*NUM_PORT];

   reg 			       pattern_int2_valid;
   reg 			       pattern_int2_repeat;
   reg [APP_ADDR_WIDTH-1:0]    pattern_int2 [CMD_PER_CLK*NUM_PORT];   

   reg 			       pattern_int3_valid;
   reg 			       pattern_int3_repeat;
   reg [APP_ADDR_WIDTH-1:0]    pattern_int3 [CMD_PER_CLK*NUM_PORT];      

   reg 			       pattern_int4_valid;
   reg 			       pattern_int4_repeat;
   reg [APP_ADDR_WIDTH-1:0]    pattern_int4 [CMD_PER_CLK*NUM_PORT];
   //***********************************************   
   // PRBS engine
   wire [APP_ADDR_WIDTH-TG_LOWER_ADDR_WIDTH-1:0] prbs_out[UPPER_ADDR_PER_CLK];
   wire 					 prbs_repeat;
   qdriip_v1_4_19_tg_addr_prbs 
     #(
       .TCQ(TCQ),
       .PRBS_WIDTH(APP_ADDR_WIDTH-TG_LOWER_ADDR_WIDTH),
       .NUM_OF_POLY_TAP(NUM_OF_POLY_TAP),
       .POLY_TAP0(POLY_TAP0),
       .POLY_TAP1(POLY_TAP1),
       .POLY_TAP2(POLY_TAP2),
       .POLY_TAP3(POLY_TAP3),
       .N_ENTRY(UPPER_ADDR_PER_CLK*NUM_PORT)
       ) u_qdriip_v1_4_19_addr_prbs
       (
	.clk(clk),
	.rst(rst),
	.prbs_load_seed(pattern_load),
	.prbs_seed(pattern_prbs_seed[APP_ADDR_WIDTH-1:TG_LOWER_ADDR_WIDTH]),
	.prbs_en(local_pattern_en && ~pattern_hold),
	.prbs_repeat(prbs_repeat),
	.prbs_out(prbs_out)
	);

   //***********************************************
   // Linear engine
   reg [APP_ADDR_WIDTH-TG_LOWER_ADDR_WIDTH-1:0]   linear_out[UPPER_ADDR_PER_CLK*NUM_PORT];
   reg [UPPER_ADDR_PER_CLK*NUM_PORT-1:0] 	  linear_repeat_int;
   reg 						  linear_repeat;

   always@(posedge clk) begin
      for (i=0; i<UPPER_ADDR_PER_CLK*NUM_PORT; i=i+1) begin : gen_lbl_linear
	 
	 if (pattern_load) begin
	    linear_out[i] <= #TCQ pattern_linear_seed[APP_ADDR_WIDTH-1:TG_LOWER_ADDR_WIDTH] + i;
	    linear_repeat <= #TCQ 1'b0;
	 end
	 else if (local_pattern_en && ~pattern_hold) begin
	    linear_out[i] <= #TCQ linear_out[i] + UPPER_ADDR_PER_CLK;
	    linear_repeat <= #TCQ linear_repeat | (|linear_repeat_int);
	 end
      end
   end

   always@(*) begin
      for (i=0; i<UPPER_ADDR_PER_CLK*NUM_PORT; i=i+1) begin : gen_lbl_linear_2
	 linear_repeat_int[i] = ((linear_out[i] + UPPER_ADDR_PER_CLK*NUM_PORT) == pattern_linear_seed[APP_ADDR_WIDTH-1:TG_LOWER_ADDR_WIDTH]);
      end
   end
   
   //***********************************************
   // Walking 1/0 engine
   reg [APP_ADDR_WIDTH-TG_LOWER_ADDR_WIDTH-1:0] 		 walking_out[UPPER_ADDR_PER_CLK];
   reg [APP_ADDR_WIDTH-TG_LOWER_ADDR_WIDTH-1:0] 		 walking_int[UPPER_ADDR_PER_CLK];
   //reg [LOG2_APP_ADDR_WIDTH:0] 					 walking_cnt[UPPER_ADDR_PER_CLK];
   wire [LOG2_APP_ADDR_WIDTH:0] 				 walking_cnt_nxt[UPPER_ADDR_PER_CLK];
   wire [UPPER_ADDR_PER_CLK-1:0] 				 walking_repeat_nxt;
   wire 							 walking_repeat;
   reg [UPPER_ADDR_PER_CLK-1:0] 				 walking_repeat_vec;
   reg 								 walking_select;
   reg 								 walking_start;
   
   always@(posedge clk) begin
      walking_select <= #TCQ (pattern_mode == TG_PATTERN_MODE_WALKING1);
   end
      
   always@(posedge clk) begin
      for (i=0; i<UPPER_ADDR_PER_CLK; i=i+1) begin : gen_lbl_walking_i
	 for (j=0; j<APP_ADDR_WIDTH-TG_LOWER_ADDR_WIDTH; j=j+1) begin : gen_lbl_walking_j
	    if (pattern_load) begin
	       walking_int[i][j] <= #TCQ (i==j);
	    end
	    else if (local_pattern_en && ~pattern_hold) begin
	       if (j==0) begin
		  walking_int[i][j]   <= #TCQ walking_int[i][APP_ADDR_WIDTH-TG_LOWER_ADDR_WIDTH-1];
	       end
	       else begin
		  walking_int[i][j]   <= #TCQ walking_int[i][j-1];
	       end
	    end
	 end
      end // block: gen_lbl_walking_j
   end // block: gen_lbl_walking_i

   always@(*) begin
      for (i=0; i<UPPER_ADDR_PER_CLK; i=i+1) begin : gen_lbl_walking_i_comb
	 walking_repeat_vec[i] = (walking_int[i][0] == 1'b1);
	 walking_out[i]        = walking_select ? walking_int[i] : ~walking_int[i];
      end
   end

   assign  walking_repeat = ~walking_start && (| walking_repeat_vec);
   
   always@(posedge clk) begin
      if (pattern_load) begin
	 walking_start  <= #TCQ 'h1;
      end
      else if (local_pattern_en && ~pattern_hold) begin
	 walking_start  <= #TCQ 'h0;
      end
   end
   
   //***********************************************
   // BRAM engine
   // TBD
   reg [APP_ADDR_WIDTH-TG_LOWER_ADDR_WIDTH-1:0]  bram_out[UPPER_ADDR_PER_CLK*NUM_PORT];
   wire 		      bram_repeat;

   always@(*) begin
      for (i=0; i<UPPER_ADDR_PER_CLK*NUM_PORT; i=i+1) begin : gen_lbl_bram_i
	 bram_out[i] = 'h0;
      end
   end
   assign bram_repeat = 1'b1;

   //***********************************************
   // Linear address - RLD Bank address
   generate 
      if ((MEM_TYPE == "RLD3") || (MEM_TYPE == "RLD2")) begin
	 for (gen_i=0; gen_i<CMD_PER_CLK*NUM_PORT; gen_i=gen_i+1) begin
	    always@(posedge clk) begin
	       if (pattern_load) begin
		  rld_bank_addr[gen_i] <= #TCQ gen_i;
	       end
	       else if (pattern_en && ~pattern_hold) begin
		  rld_bank_addr[gen_i] <= #TCQ rld_bank_addr[gen_i] + CMD_PER_CLK*NUM_PORT;
	       end
	    end
	 end
      end
   endgenerate

   //***********************************************
   // Lower Address
   reg [TG_LOWER_ADDR_WIDTH_1-1:0] lower_addr [CMD_PER_CLK*NUM_PORT];

   always@(*) begin
      for (i=0; i<CMD_PER_CLK*NUM_PORT; i=i+1) begin
	 if ((MEM_TYPE == "RLD3") || (MEM_TYPE == "RLD2")) begin
	    lower_addr[i]          = rld_bank_addr[i];
	    rld_upper_addr_en_i[i] = pattern_en && ~pattern_hold &&   // Lower Address
				     (rld_bank_addr[i] == {TG_LOWER_ADDR_WIDTH_1{1'b1}});
	 end
	 else begin
	    lower_addr[i]          = {TG_LOWER_ADDR_WIDTH_1{1'b0}};
            rld_upper_addr_en_i[i] = {CMD_PER_CLK*NUM_PORT{1'b0}};
         end
      end
   end

   assign rld_upper_addr_en = |rld_upper_addr_en_i;
   
   //***********************************************
   // output select

   generate
      for (gen_i=0; gen_i<CMD_PER_CLK*NUM_PORT; gen_i=gen_i+1) begin
	 if ((MEM_TYPE == "RLD3") || (MEM_TYPE == "RLD2")) begin
	    always@(*) begin
	       casez (pattern_mode)
		 TG_PATTERN_MODE_LINEAR:     begin
		    pattern_int0[gen_i]    = {linear_out[0], lower_addr[gen_i]};
		 end
		 TG_PATTERN_MODE_PRBS:       begin
		    pattern_int0[gen_i]    = {prbs_out[0], lower_addr[gen_i]};
		 end
		 TG_PATTERN_MODE_WALKING1,
		   TG_PATTERN_MODE_WALKING0: begin
		      pattern_int0[gen_i]  = {walking_out[0], lower_addr[gen_i]};
		   end	     
		 TG_PATTERN_MODE_BRAM:       begin
		    pattern_int0[gen_i]    = {bram_out[0], lower_addr[gen_i]};
		 end
		 default:                    begin
		    pattern_int0[gen_i]    = {linear_out[0], lower_addr[gen_i]};
		 end
	       endcase
	    end
	 end
	 else if (MEM_TYPE == "QDRIIP" || MEM_TYPE == "QDRIV") begin
	    always@(*) begin
	       casez (pattern_mode)
		 TG_PATTERN_MODE_LINEAR:     begin
		    pattern_int0[gen_i]    = linear_out[gen_i];
		 end
		 TG_PATTERN_MODE_PRBS:       begin
		    pattern_int0[gen_i]    = prbs_out[gen_i];
		 end
		 TG_PATTERN_MODE_WALKING1,
		   TG_PATTERN_MODE_WALKING0: begin
		      pattern_int0[gen_i]  = walking_out[gen_i];
		   end	     
		 TG_PATTERN_MODE_BRAM:       begin
		    pattern_int0[gen_i]    = bram_out[gen_i];
		 end
		 default:                    begin
		    pattern_int0[gen_i]    = linear_out[gen_i];
		 end
	       endcase
	    end
	 end
	 else /*if (MEM_TYPE == "DDR3" || MEM_TYPE == "DDR4")*/ begin
	    always@(*) begin
	       casez (pattern_mode)
		 TG_PATTERN_MODE_LINEAR:     begin
		    pattern_int0[gen_i]    = {linear_out[gen_i], lower_addr[gen_i]};
		 end
		 TG_PATTERN_MODE_PRBS:       begin
		    pattern_int0[gen_i]    = {prbs_out[gen_i], lower_addr[gen_i]};
		 end
		 TG_PATTERN_MODE_WALKING1,
		   TG_PATTERN_MODE_WALKING0: begin
		      pattern_int0[gen_i]  = {walking_out[gen_i], lower_addr[gen_i]};
		   end	     
		 TG_PATTERN_MODE_BRAM:       begin
		    pattern_int0[gen_i]    = {bram_out[gen_i], lower_addr[gen_i]};
		 end
		 default:                    begin
		    pattern_int0[gen_i]    = {linear_out[gen_i], lower_addr[gen_i]};
		 end
	       endcase
	    end
	 end
      end
   endgenerate
   
   always@(*) begin
      casez (pattern_mode)
	TG_PATTERN_MODE_LINEAR:     begin
	   pattern_int0_repeat = linear_repeat;
	end
	TG_PATTERN_MODE_PRBS:       begin
	   pattern_int0_repeat = prbs_repeat;
	end
	TG_PATTERN_MODE_WALKING1,
	  TG_PATTERN_MODE_WALKING0: begin
	     pattern_int0_repeat = walking_repeat;
	  end	     
	TG_PATTERN_MODE_BRAM:       begin
	   pattern_int0_repeat = bram_repeat;
	   //synthesis translate_off
	   //assert (rst!=1'b0 || pattern_en!=1'b1 /*|| calib_complete!=1'b1*/) else begin $display ($time, "Warning: BRAM not supported for address mode\n"); end
	   //synthesis translate_on
	end
	default:                    begin
	   pattern_int0_repeat = 'h1;
	   //synthesis translate_off
	   //if (pattern_en) begin
	   //   assert (rst!=1'b0 || pattern_en!=1'b1 /*|| calib_complete!=1'b1*/) else begin $display ($time, "Warning: User programmed unsupported address mode %x\n", pattern_mode); end
	   //end
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
		 pattern_mode == TG_PATTERN_MODE_BRAM) 
	   else begin
	      $display ($time, "Warning: User programmed unsupported address mode %x\n", pattern_mode); 
	   end	      
      end
   end
   //synthesis translate_on
   
   always@(posedge clk) begin
      if(rst | pattern_load) begin
	 pattern_int1_valid  <= #TCQ 1'b0;
	 pattern_int2_valid  <= #TCQ 1'b0;
	 pattern_int3_valid  <= #TCQ 1'b0;
	 pattern_int4_valid  <= #TCQ 1'b0;
	 pattern_valid       <= #TCQ 1'b0;
	 pattern_int1_repeat <= #TCQ 1'b0;
	 pattern_int2_repeat <= #TCQ 1'b0;
	 pattern_int3_repeat <= #TCQ 1'b0;
	 pattern_int4_repeat <= #TCQ 1'b0;
	 pattern_repeat      <= #TCQ 1'b0;
      end
      else if (pattern_en && ~pattern_hold) begin
	 pattern_int1_valid  <= #TCQ 1'b1 /*pattern_int0_valid*/;
	 pattern_int2_valid  <= #TCQ pattern_int1_valid;
	 pattern_int3_valid  <= #TCQ pattern_int2_valid;
	 pattern_int4_valid  <= #TCQ pattern_int3_valid;
	 pattern_valid       <= #TCQ pattern_int4_valid;
	 pattern_int1_repeat <= #TCQ pattern_int0_repeat;
	 pattern_int2_repeat <= #TCQ pattern_int1_repeat;
	 pattern_int3_repeat <= #TCQ pattern_int2_repeat;
	 pattern_int4_repeat <= #TCQ pattern_int3_repeat;
	 pattern_repeat      <= #TCQ pattern_int4_repeat;
	 pattern_int1        <= #TCQ pattern_int0;
	 pattern_int2        <= #TCQ pattern_int1;
	 pattern_int3        <= #TCQ pattern_int2;
	 pattern_int4        <= #TCQ pattern_int3;
	 pattern_out         <= #TCQ pattern_int4;
      end
   end
   
endmodule // qdriip_v1_4_19_tg_pattern_gen_addr
