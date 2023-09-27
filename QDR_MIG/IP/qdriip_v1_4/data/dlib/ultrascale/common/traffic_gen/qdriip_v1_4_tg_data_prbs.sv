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
//  /   /         Filename           : qdriip_v1_4_19_tg_data_prbs.sv
// /___/   /\     Date Last Modified : $Date: 2014/09/03 $
// \   \  /  \    Date Created       : Thu May 22 2014
//  \___\/\___\
//
// Device           : UltraScale
// Design Name      : Traffic Generator
// Purpose:
// This is PRBS generator wrapper
// PRBS block is modified from 7Series traffic generator
// PRBS 8,10,23 are supported
// PRBS seed is hard-coded
// PRSB generator generates NUM_DQ_PINS number of independent PRBS bitstreams.
// Each PRBS bitstream returns width of nCK_PER_CLK*2 per cycle
// Reference        :
// Revision History :
//*****************************************************************************

`timescale 1ps / 1ps

module qdriip_v1_4_19_tg_data_prbs 
  #(
    parameter TCQ              = 100,
    //parameter APP_DATA_WIDTH   = 576,        // RLDRAM3 data bus width.
    parameter NUM_DQ_PINS      = 72,
    parameter nCK_PER_CLK      = 4,
    parameter NUM_PORT         = 1,
    parameter PRBS_WIDTH       = 23
  )
   (
    // ********* ALL SIGNALS AT THIS INTERFACE ARE ACTIVE HIGH SIGNALS ********/
    input 				   clk, // memory controller (MC) user interface (UI) clock
    input 				   rst, // MC UI reset signal.
    input 				   prbs_en,
    input 				   prbs_load_seed,
    input [PRBS_WIDTH-1:0] 		   prbs_seed [NUM_DQ_PINS*NUM_PORT-1:0],
    output [NUM_DQ_PINS*2*nCK_PER_CLK*NUM_PORT-1:0] prbs_vec
    );

//*******************************************************************************
// Tmp solution for PRBS generator
//*******************************************************************************   
   wire [NUM_DQ_PINS*NUM_PORT-1:0] 		   prbsdata_rising_0;
   wire [NUM_DQ_PINS*NUM_PORT-1:0] 		   prbsdata_falling_0;
   wire [NUM_DQ_PINS*NUM_PORT-1:0] 		   prbsdata_rising_1;
   wire [NUM_DQ_PINS*NUM_PORT-1:0] 		   prbsdata_falling_1;
   wire [NUM_DQ_PINS*NUM_PORT-1:0] 		   prbsdata_rising_2;
   wire [NUM_DQ_PINS*NUM_PORT-1:0] 		   prbsdata_falling_2;
   wire [NUM_DQ_PINS*NUM_PORT-1:0] 		   prbsdata_rising_3;
   wire [NUM_DQ_PINS*NUM_PORT-1:0] 		   prbsdata_falling_3 ;
   wire [2*nCK_PER_CLK-1:0] 		   prbs_out [NUM_DQ_PINS*NUM_PORT-1:0];
   wire [PRBS_WIDTH*NUM_DQ_PINS*NUM_PORT-1:0]       lfsr_reg_o;
   genvar 				   r, s;
   
/*   
   generate
      for (s = 0; s < NUM_DQ_PINS/4; s = s + 1) begin: gen_prbs_seed
	 assign prbs_seed[4*s+0] = {(PRBS_WIDTH/2){2'b10}} + ((4*s+0)<<0 + (4*s+0)<<4 + (4*s+0)<<8 + (4*s+0)<<12 + (4*s+0)<<16 + (4*s+0)<<20);
	 assign prbs_seed[4*s+1] = 23'h56bf03              + ((4*s+1)<<0 + (4*s+1)<<4 + (4*s+1)<<8 + (4*s+1)<<12 + (4*s+1)<<16 + (4*s+1)<<20);
	 assign prbs_seed[4*s+2] = 23'h671bdc              + ((4*s+2)<<0 + (4*s+2)<<4 + (4*s+2)<<8 + (4*s+2)<<12 + (4*s+2)<<16 + (4*s+2)<<20);
	 assign prbs_seed[4*s+3] = 23'h2dc0af              + ((4*s+3)<<0 + (4*s+3)<<4 + (4*s+3)<<8 + (4*s+3)<<12 + (4*s+3)<<16 + (4*s+3)<<20);
      end
   endgenerate
*/   
   generate
      for (r = 0; r < NUM_DQ_PINS*NUM_PORT; r = r + 1) begin: gen_prbs_pin
	 qdriip_v1_4_19_tg_prbs_gen #
               (.nCK_PER_CLK   (nCK_PER_CLK),
		.TCQ           (TCQ),
		.PRBS_WIDTH    (PRBS_WIDTH)
		)
	 u_qdriip_v1_4_19_data_prbs_gen
	       (
		.clk_i           (clk),
		.rst_i           (rst),
		.clk_en_i        (prbs_en),
		.prbs_load_seed  (prbs_load_seed),
		.prbs_seed       (prbs_seed[r]),
		.prbs_o          (prbs_out[r]),
		.lfsr_reg_o      (lfsr_reg_o[PRBS_WIDTH*r +: PRBS_WIDTH])
		);   
      end 
   endgenerate
   
   generate
      for (r = 0; r < NUM_DQ_PINS*NUM_PORT; r = r + 1) begin: gen_prbs_rise_fall_data
	 if (nCK_PER_CLK == 1) begin: gen_ck_per_clk1
            assign prbsdata_rising_0[r]  = prbs_out[r][1];
            assign prbsdata_falling_0[r] = prbs_out[r][0];
	 end else if (nCK_PER_CLK == 2) begin: gen_ck_per_clk2
	    // Note this is reverse order as suggested in qdriip_v1_4_19_tg_prbs_gen.sv 
            assign prbsdata_rising_0[r]  = prbs_out[r][3];
            assign prbsdata_falling_0[r] = prbs_out[r][2];
            assign prbsdata_rising_1[r]  = prbs_out[r][1];
            assign prbsdata_falling_1[r] = prbs_out[r][0];
            //assign prbsdata_rising_2[r]  = 'h0;
            //assign prbsdata_falling_2[r] = 'h0;
            //assign prbsdata_rising_3[r]  = 'h0;
            //assign prbsdata_falling_3[r] = 'h0;
	 end else if (nCK_PER_CLK == 4) begin: gen_ck_per_clk4
            assign prbsdata_rising_0[r]  = prbs_out[r][7];
            assign prbsdata_falling_0[r] = prbs_out[r][6];
            assign prbsdata_rising_1[r]  = prbs_out[r][5];
            assign prbsdata_falling_1[r] = prbs_out[r][4]; 
            assign prbsdata_rising_2[r]  = prbs_out[r][3];
            assign prbsdata_falling_2[r] = prbs_out[r][2];
            assign prbsdata_rising_3[r]  = prbs_out[r][1];
            assign prbsdata_falling_3[r] = prbs_out[r][0];
	 end
      end

      if (nCK_PER_CLK == 1) begin: gen_ck_per_clk1
	 assign prbs_vec = {prbsdata_falling_0,prbsdata_rising_0};
      end else if (nCK_PER_CLK == 2) begin: gen_ck_per_clk2
	 assign prbs_vec = {prbsdata_falling_1,prbsdata_rising_1,prbsdata_falling_0,prbsdata_rising_0};
      end else if (nCK_PER_CLK == 4) begin: gen_ck_per_clk4
	 assign prbs_vec = {prbsdata_falling_3,prbsdata_rising_3,prbsdata_falling_2,prbsdata_rising_2,prbsdata_falling_1,prbsdata_rising_1,prbsdata_falling_0,prbsdata_rising_0};
      end	    
   endgenerate
   
   //*******************************************************************************
endmodule // qdriip_v1_4_19_tg_data_prbs


