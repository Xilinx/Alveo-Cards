/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: %version
//  \   \         Application: QDRIIP
//  /   /         Filename: qdriip_v1_4_19_tg_prbs_gen
// /___/   /\     Date Last Modified: $Date: 2014/09/03 $
// \   \  /  \    Date Created: Thu May 22 2014
//  \___\/\___\
//
//Device: UltraScale
//Design Name: PRBS_Generator
//Purpose:       
// Overview:
//  Simplified version of 7 Series PRBS Generator
//
//  Implements a "pseudo-PRBS" generator. Basically this is a standard
//  PRBS generator (using an linear feedback shift register) along with
//  logic to force the repetition of the sequence after 2^PRBS_WIDTH
//  samples (instead of 2^PRBS_WIDTH - 1). The LFSR is based on the design
//  from Table 1 of XAPP 210. Note that only 8- and 10-tap long LFSR chains
//  are supported in this code
// Parameter Requirements:
//  1. PRBS_WIDTH = 8 or 10
//  2. PRBS_WIDTH >= 2*nCK_PER_CLK
// Output notes:
//  The output of this module consists of 2*nCK_PER_CLK bits, these contain
//  the value of the LFSR output for the next 2*CK_PER_CLK bit times. Note
//  that prbs_o[0] contains the bit value for the "earliest" bit time. 
//Reference:
//Revision History:
//*****************************************************************************

`timescale 1ps/1ps

module qdriip_v1_4_19_tg_prbs_gen #
  (
   parameter TCQ         = 100,        // clk->out delay (sim only)
   parameter PRBS_WIDTH  = 10,         // LFSR shift register length
   parameter nCK_PER_CLK = 4           // output:internal clock freq ratio
   )
  (
   input 		      clk_i, // input clock
   input 		      clk_en_i, // clock enable 
   input 		      rst_i, // synchronous reset
   input                      prbs_load_seed,
   input [PRBS_WIDTH-1:0]     prbs_seed, // initial LFSR seed
   output reg [2*nCK_PER_CLK-1:0] prbs_o, // generated address
   output [PRBS_WIDTH-1:0]    lfsr_reg_o
   // ReSeedcounter used to indicate when pseudo-PRBS sequence has reached
   // the end of it's cycle. May not be needed, but for now included to
   // maintain compatibility with current TG code
   //output [31:0] 	      ReSeedcounter_o ,
   //output [7:0] 	      dbg_prbs_signals
  );

  //***************************************************************************

  function integer clogb2 (input integer size);
    begin
      size = size - 1;
      for (clogb2=1; size>1; clogb2=clogb2+1)
        size = size >> 1;
    end
  endfunction
  
  // Number of internal clock cycles before the PRBS sequence will repeat
  localparam PRBS_SEQ_LEN_CYCLES = (2**PRBS_WIDTH);// / (2*nCK_PER_CLK);
  localparam PRBS_SEQ_LEN_CYCLES_BITS = clogb2(PRBS_SEQ_LEN_CYCLES);
  
  reg [PRBS_WIDTH-1:0]                lfsr_reg_r;
  wire [PRBS_WIDTH-1:0]               next_lfsr_reg;
  //reg [PRBS_WIDTH-1:0]                reseed_cnt_r;
  reg                                 reseed_prbs_r;
  reg [PRBS_SEQ_LEN_CYCLES_BITS-1:0]  sample_cnt_r;

  integer 			      i;
  
  //***************************************************************************
   /*
  assign dbg_prbs_signals = {7'b0000000,reseed_prbs_r};
  assign ReSeedcounter_o = {{(32-PRBS_WIDTH){1'b0}}, reseed_cnt_r};
  always @ (posedge clk_i)
    if (rst_i)
      reseed_cnt_r <= 'b0;
    else if (clk_en_i)
      if (reseed_cnt_r == {PRBS_WIDTH {1'b1}})
        reseed_cnt_r <= 'b0;
      else
        reseed_cnt_r <= reseed_cnt_r + 1;
    */
  //***************************************************************************
  // Generate PRBS reset signal to ensure that PRBS sequence repeats after
  // every 2**PRBS_WIDTH samples. Basically what happens is that we let the
  // LFSR run for an extra cycle after "truly PRBS" 2**PRBS_WIDTH - 1
  // samples have past. Once that extra cycle is finished, we reseed the LFSR

  //`define RESEED_ENABLE
`ifndef RESEED_ENABLE
   always @(posedge clk_i) begin
      reseed_prbs_r   <= #TCQ 1'b0;
   end
`else
  always @(posedge clk_i)
    if (rst_i) begin
      sample_cnt_r <= #TCQ 'b0;
      reseed_prbs_r   <= #TCQ 1'b0;
    end else if (clk_en_i) begin
      // The rollver count should always be [(power of 2) - 1]
      sample_cnt_r <= #TCQ sample_cnt_r + 1;
      // Assert PRBS reset signal so that it is simultaneously with the
      // last sample of the sequence
      if (sample_cnt_r == PRBS_SEQ_LEN_CYCLES - 2)
        reseed_prbs_r <= #TCQ 1'b1;
      else
        reseed_prbs_r <= #TCQ 1'b0;
    end
`endif
  // Load initial seed or update LFSR contents
  always @(posedge clk_i)
    if (prbs_load_seed)
      lfsr_reg_r <= #TCQ prbs_seed;
    else if (clk_en_i)
      if (reseed_prbs_r)
        lfsr_reg_r <= #TCQ prbs_seed;
      else begin
 //       lfsr_reg_r <= #TCQ {lfsr_reg_r[21:0], lfsr_reg_r[22]^lfsr_reg_r[17] };//prbs23_B pattern in par_prbs_debug;
         lfsr_reg_r <= #TCQ next_lfsr_reg;//next_lfsr_reg;
        
      end
  assign lfsr_reg_o = lfsr_reg_r;
  // Calculate next set of nCK_PER_CLK samplse for LFSR
  // Basically we calculate all PRBS_WIDTH samples in parallel, rather
  // than serially shifting the LFSR to determine future sample values.
  // Shifting is possible, but requires multiple shift registers to be
  // instantiated because the fabric clock frequency is running at a
  // fraction of the output clock frequency
  generate
    if (PRBS_WIDTH == 8) begin: gen_next_lfsr_prbs8
      if (nCK_PER_CLK == 1) begin: gen_ck_per_clk1
        assign next_lfsr_reg[7] = lfsr_reg_r[5];
        assign next_lfsr_reg[6] = lfsr_reg_r[4];
        assign next_lfsr_reg[5] = lfsr_reg_r[3];
        assign next_lfsr_reg[4] = lfsr_reg_r[2];
        assign next_lfsr_reg[3] = lfsr_reg_r[1];
        assign next_lfsr_reg[2] = lfsr_reg_r[0];
        assign next_lfsr_reg[1] = ~(lfsr_reg_r[7] ^ lfsr_reg_r[5] ^
				    lfsr_reg_r[4] ^ lfsr_reg_r[3]);
        assign next_lfsr_reg[0] = ~(lfsr_reg_r[6] ^ lfsr_reg_r[4] ^
                                    lfsr_reg_r[3] ^ lfsr_reg_r[2]);
      end else if (nCK_PER_CLK == 2) begin: gen_ck_per_clk2
        assign next_lfsr_reg[7] = lfsr_reg_r[3];
        assign next_lfsr_reg[6] = lfsr_reg_r[2];
        assign next_lfsr_reg[5] = lfsr_reg_r[1];
        assign next_lfsr_reg[4] = lfsr_reg_r[0];
        assign next_lfsr_reg[3] = ~(lfsr_reg_r[7] ^ lfsr_reg_r[5] ^
                                    lfsr_reg_r[4] ^ lfsr_reg_r[3]);
        assign next_lfsr_reg[2] = ~(lfsr_reg_r[6] ^ lfsr_reg_r[4] ^
                                    lfsr_reg_r[3] ^ lfsr_reg_r[2]);
        assign next_lfsr_reg[1] = ~(lfsr_reg_r[5] ^ lfsr_reg_r[3] ^
                                    lfsr_reg_r[2] ^ lfsr_reg_r[1]);
        assign next_lfsr_reg[0] = ~(lfsr_reg_r[4] ^ lfsr_reg_r[2] ^
                                    lfsr_reg_r[1] ^ lfsr_reg_r[0]);
      end else if (nCK_PER_CLK == 4) begin: gen_ck_per_clk4
        assign next_lfsr_reg[7] = ~(lfsr_reg_r[7] ^ lfsr_reg_r[5] ^
                                    lfsr_reg_r[4] ^ lfsr_reg_r[3]);
        assign next_lfsr_reg[6] = ~(lfsr_reg_r[6] ^ lfsr_reg_r[4] ^
                                    lfsr_reg_r[3] ^ lfsr_reg_r[2]) ;
        assign next_lfsr_reg[5] = ~(lfsr_reg_r[5] ^ lfsr_reg_r[3] ^
                                    lfsr_reg_r[2] ^ lfsr_reg_r[1]);
        assign next_lfsr_reg[4] = ~(lfsr_reg_r[4] ^ lfsr_reg_r[2] ^
                                    lfsr_reg_r[1] ^ lfsr_reg_r[0]);
        assign next_lfsr_reg[3] = ~(lfsr_reg_r[3] ^ lfsr_reg_r[1] ^
                                    lfsr_reg_r[0] ^ next_lfsr_reg[7]);
        assign next_lfsr_reg[2] = ~(lfsr_reg_r[2]    ^ lfsr_reg_r[0] ^
                                    next_lfsr_reg[7] ^ next_lfsr_reg[6]);
        assign next_lfsr_reg[1] = ~(lfsr_reg_r[1]    ^ next_lfsr_reg[7] ^
                                    next_lfsr_reg[6] ^ next_lfsr_reg[5]);
        assign next_lfsr_reg[0] = ~(lfsr_reg_r[0]    ^ next_lfsr_reg[6] ^
                                    next_lfsr_reg[5] ^ next_lfsr_reg[4]);
      end
    end else if (PRBS_WIDTH == 10) begin: gen_next_lfsr_prbs10
    //  XNOR tap at 10,7
      if (nCK_PER_CLK == 1) begin: gen_ck_per_clk1
        assign next_lfsr_reg[9] = lfsr_reg_r[7];		   
        assign next_lfsr_reg[8] = lfsr_reg_r[6];		   
        assign next_lfsr_reg[7] = lfsr_reg_r[5];		   
        assign next_lfsr_reg[6] = lfsr_reg_r[4];		   
        assign next_lfsr_reg[5] = lfsr_reg_r[3];		   
        assign next_lfsr_reg[4] = lfsr_reg_r[2];		   
        assign next_lfsr_reg[3] = lfsr_reg_r[1];		   
        assign next_lfsr_reg[2] = lfsr_reg_r[0];		   
        assign next_lfsr_reg[1] = ~(lfsr_reg_r[9] ^ lfsr_reg_r[6]);
        assign next_lfsr_reg[0] = ~(lfsr_reg_r[8] ^ lfsr_reg_r[5]);
      end else if (nCK_PER_CLK == 2) begin: gen_ck_per_clk2
        assign next_lfsr_reg[9] = lfsr_reg_r[5];
        assign next_lfsr_reg[8] = lfsr_reg_r[4];
        assign next_lfsr_reg[7] = lfsr_reg_r[3];
        assign next_lfsr_reg[6] = lfsr_reg_r[2];
        assign next_lfsr_reg[5] = lfsr_reg_r[1];
        assign next_lfsr_reg[4] = lfsr_reg_r[0];
        assign next_lfsr_reg[3] = ~(lfsr_reg_r[9] ^ lfsr_reg_r[6]);
        assign next_lfsr_reg[2] = ~(lfsr_reg_r[8] ^ lfsr_reg_r[5]);
        assign next_lfsr_reg[1] = ~(lfsr_reg_r[7] ^ lfsr_reg_r[4]);
        assign next_lfsr_reg[0] = ~(lfsr_reg_r[6] ^ lfsr_reg_r[3]);
      end else if (nCK_PER_CLK == 4) begin: gen_ck_per_clk4
        assign next_lfsr_reg[9] = lfsr_reg_r[1];
        assign next_lfsr_reg[8] = lfsr_reg_r[0];
        assign next_lfsr_reg[7] = ~(lfsr_reg_r[9] ^ lfsr_reg_r[6]);
        assign next_lfsr_reg[6] = ~(lfsr_reg_r[8] ^ lfsr_reg_r[5]);
        assign next_lfsr_reg[5] = ~(lfsr_reg_r[7] ^ lfsr_reg_r[4]);
        assign next_lfsr_reg[4] = ~(lfsr_reg_r[6] ^ lfsr_reg_r[3]);
        assign next_lfsr_reg[3] = ~(lfsr_reg_r[5] ^ lfsr_reg_r[2]);
        assign next_lfsr_reg[2] = ~(lfsr_reg_r[4] ^ lfsr_reg_r[1]);
        assign next_lfsr_reg[1] = ~(lfsr_reg_r[3] ^ lfsr_reg_r[0]);
        assign next_lfsr_reg[0] = ~(lfsr_reg_r[2] ^ next_lfsr_reg[7]);
      end
    end else if (PRBS_WIDTH == 23) begin: gen_next_lfsr_prbs23
    //  XNOR tap at 10,7
      if (nCK_PER_CLK == 1) begin: gen_ck_per_clk1
        assign next_lfsr_reg[22] = lfsr_reg_r[20];		     
        assign next_lfsr_reg[21] = lfsr_reg_r[19];		     
        assign next_lfsr_reg[20] = lfsr_reg_r[18];		     
        assign next_lfsr_reg[19] = lfsr_reg_r[17];		     
        assign next_lfsr_reg[18] = lfsr_reg_r[16];		     
        assign next_lfsr_reg[17] = lfsr_reg_r[15];		     
        assign next_lfsr_reg[16] = lfsr_reg_r[14];		     
        assign next_lfsr_reg[15] = lfsr_reg_r[13];		     
        assign next_lfsr_reg[14] = lfsr_reg_r[12];		     
        assign next_lfsr_reg[13] = lfsr_reg_r[11];		     
        assign next_lfsr_reg[12] = lfsr_reg_r[10];		     
        assign next_lfsr_reg[11] = lfsr_reg_r[9];		     
        assign next_lfsr_reg[10] = lfsr_reg_r[8];		     
        assign next_lfsr_reg[9] = lfsr_reg_r[7];		     
        assign next_lfsr_reg[8] = lfsr_reg_r[6];		     
        assign next_lfsr_reg[7] = lfsr_reg_r[5];		     
        assign next_lfsr_reg[6] = lfsr_reg_r[4];		     
        assign next_lfsr_reg[5] = lfsr_reg_r[3];		     
        assign next_lfsr_reg[4] = lfsr_reg_r[2];		     
        assign next_lfsr_reg[3] = lfsr_reg_r[1];		     
        assign next_lfsr_reg[2] = lfsr_reg_r[0];		     
        assign next_lfsr_reg[1] = ~(lfsr_reg_r[22] ^ lfsr_reg_r[17]);
        assign next_lfsr_reg[0] = ~(lfsr_reg_r[21] ^ lfsr_reg_r[16]);
      end else if (nCK_PER_CLK == 2) begin: gen_ck_per_clk2
        assign next_lfsr_reg[22] = lfsr_reg_r[18];
        assign next_lfsr_reg[21] = lfsr_reg_r[17];
        assign next_lfsr_reg[20] = lfsr_reg_r[16];
        assign next_lfsr_reg[19] = lfsr_reg_r[15];
        assign next_lfsr_reg[18] = lfsr_reg_r[14];
        assign next_lfsr_reg[17] = lfsr_reg_r[13];
        assign next_lfsr_reg[16] = lfsr_reg_r[12];
        assign next_lfsr_reg[15] = lfsr_reg_r[11];
        assign next_lfsr_reg[14] = lfsr_reg_r[10];
        assign next_lfsr_reg[13] = lfsr_reg_r[9];
        assign next_lfsr_reg[12] = lfsr_reg_r[8];
        assign next_lfsr_reg[11] = lfsr_reg_r[7];
        assign next_lfsr_reg[10] = lfsr_reg_r[6];
        assign next_lfsr_reg[9] = lfsr_reg_r[5];
        assign next_lfsr_reg[8] = lfsr_reg_r[4];
        assign next_lfsr_reg[7] = lfsr_reg_r[3];
        assign next_lfsr_reg[6] = lfsr_reg_r[2];
        assign next_lfsr_reg[5] = lfsr_reg_r[1];
        assign next_lfsr_reg[4] = lfsr_reg_r[0];
        assign next_lfsr_reg[3] = ~(lfsr_reg_r[22] ^ lfsr_reg_r[17]);
        assign next_lfsr_reg[2] = ~(lfsr_reg_r[21] ^ lfsr_reg_r[16]);
        assign next_lfsr_reg[1] = ~(lfsr_reg_r[20] ^ lfsr_reg_r[15]);
        assign next_lfsr_reg[0] = ~(lfsr_reg_r[19] ^ lfsr_reg_r[14]);
      end else if (nCK_PER_CLK == 4) begin: gen_ck_per_clk4
        assign next_lfsr_reg[22] = lfsr_reg_r[14];
        assign next_lfsr_reg[21] = lfsr_reg_r[13];
        assign next_lfsr_reg[20] = lfsr_reg_r[12];
        assign next_lfsr_reg[19] = lfsr_reg_r[11];
        assign next_lfsr_reg[18] = lfsr_reg_r[10];
        assign next_lfsr_reg[17] = lfsr_reg_r[9];
        assign next_lfsr_reg[16] = lfsr_reg_r[8];
        assign next_lfsr_reg[15] = lfsr_reg_r[7];
        assign next_lfsr_reg[14] = lfsr_reg_r[6];
        assign next_lfsr_reg[13] = lfsr_reg_r[5];
        assign next_lfsr_reg[12] = lfsr_reg_r[4];
        assign next_lfsr_reg[11] = lfsr_reg_r[3];
        assign next_lfsr_reg[10] = lfsr_reg_r[2];
        assign next_lfsr_reg[9] = lfsr_reg_r[1];
        assign next_lfsr_reg[8] = lfsr_reg_r[0];
        assign next_lfsr_reg[7] = ~(lfsr_reg_r[22] ^ lfsr_reg_r[17]);
        assign next_lfsr_reg[6] = ~(lfsr_reg_r[21] ^ lfsr_reg_r[16]);
        assign next_lfsr_reg[5] = ~(lfsr_reg_r[20] ^ lfsr_reg_r[15]);
        assign next_lfsr_reg[4] = ~(lfsr_reg_r[19] ^ lfsr_reg_r[14]);
        assign next_lfsr_reg[3] = ~(lfsr_reg_r[18] ^ lfsr_reg_r[13]);
        assign next_lfsr_reg[2] = ~(lfsr_reg_r[17] ^ lfsr_reg_r[12]);
        assign next_lfsr_reg[1] = ~(lfsr_reg_r[16] ^ lfsr_reg_r[11]);
        assign next_lfsr_reg[0] = ~(lfsr_reg_r[15] ^ /*next_lfsr_reg[7]*/lfsr_reg_r[10]);
        
    //  uncomment here for real PRBS 23
	 /*
        assign next_lfsr_reg[22] = lfsr_reg_r[21];
        assign next_lfsr_reg[21] = lfsr_reg_r[20];
        assign next_lfsr_reg[20] = lfsr_reg_r[19];
        assign next_lfsr_reg[19] = lfsr_reg_r[18];
        assign next_lfsr_reg[18] = lfsr_reg_r[17];
        assign next_lfsr_reg[17] = lfsr_reg_r[16];
        assign next_lfsr_reg[16] = lfsr_reg_r[15];
        assign next_lfsr_reg[15] = lfsr_reg_r[14];
        assign next_lfsr_reg[14] = lfsr_reg_r[13];
        assign next_lfsr_reg[13] = lfsr_reg_r[12];
        assign next_lfsr_reg[12] = lfsr_reg_r[11];
        assign next_lfsr_reg[11] = lfsr_reg_r[10];
        assign next_lfsr_reg[10] = lfsr_reg_r[9];
        assign next_lfsr_reg[9]  = lfsr_reg_r[8];
        assign next_lfsr_reg[8]  = lfsr_reg_r[7];
        assign next_lfsr_reg[7] =  lfsr_reg_r[6];
        assign next_lfsr_reg[6] =  lfsr_reg_r[5];
        assign next_lfsr_reg[5] =  lfsr_reg_r[4];
        assign next_lfsr_reg[4] =  lfsr_reg_r[3];
        assign next_lfsr_reg[3] =  lfsr_reg_r[2];
        assign next_lfsr_reg[2] =  lfsr_reg_r[1];
        assign next_lfsr_reg[1] =  lfsr_reg_r[0];
        assign next_lfsr_reg[0] = (lfsr_reg_r[22] ^ lfsr_reg_r[17]);
        */
      end
    end
  endgenerate

  // Output highest (2*nCK_PER_CLK) taps of LFSR - note that the "earliest"
  // tap is highest tap (e.g. for an 8-bit LFSR, tap[7] contains the first
  // data sent out the shift register), therefore tap[PRBS_WIDTH-1] must be 
  // routed to bit[0] of the output, tap[PRBS_WIDTH-2] to bit[1] of the
  // output, etc. 
  always@(*) begin
     for (i = 0; i < 2*nCK_PER_CLK; i = i + 1) begin: gen_prbs_transpose
  	prbs_o[i] = lfsr_reg_r[PRBS_WIDTH-1-i];
     end
  end

endmodule
