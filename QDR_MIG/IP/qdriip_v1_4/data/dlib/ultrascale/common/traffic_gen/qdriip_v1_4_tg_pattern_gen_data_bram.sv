/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//******************************************************************************
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
// This is BRAM data pattern.
//
// Reference        :
// Revision History :
//*****************************************************************************

`timescale 1ps / 1ps

// BRAM
module qdriip_v1_4_19_tg_pattern_gen_data_bram
  #(
    parameter TCQ            = 100,    
    //parameter APP_DATA_WIDTH = 288,
    parameter NUM_DQ_PINS    = 36,
    parameter nCK_PER_CLK    = 4,
    parameter NUM_PORT       = 1,
    parameter TG_PATTERN_LOG2_NUM_BRAM_ENTRY = 9
    )
   (  
      input [TG_PATTERN_LOG2_NUM_BRAM_ENTRY-1:0] bram_ptr,
      output reg [NUM_DQ_PINS*2*nCK_PER_CLK*NUM_PORT-1:0] 	 bram_out
      );
   
   always@(*) begin
     casez (bram_ptr)
       'd0: bram_out = 'h123;
       'd1: bram_out = 'h456;
       'd2: bram_out = 'h789;
       'd3: bram_out = 'h0ab;
       default: bram_out = 'h0;
     endcase // casez (bram_ptr)
   end

   // Step
//   always@(*) begin
//     if (bram_ptr < 9'd256)
//       bram_out = {(NUM_DQ_PINS*2*nCK_PER_CLK*NUM_PORT){1'b0}};
//     else
//       bram_out = {(NUM_DQ_PINS*2*nCK_PER_CLK*NUM_PORT){1'b1}};
//   end
   
endmodule

