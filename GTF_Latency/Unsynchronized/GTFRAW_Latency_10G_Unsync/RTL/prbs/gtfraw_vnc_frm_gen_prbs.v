/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

module gtfraw_vnc_frm_gen_prbs (RST, CLK, DATA_IN, EN, DATA_OUT);

  //--------------------------------------------
  // Configuration parameters
  //--------------------------------------------
   parameter CHK_MODE    = 0;
   parameter NBITS       = 16;

  //--------------------------------------------
  // Input/Outputs
  //--------------------------------------------

   input  wire RST;
   input  wire CLK;
   input  wire [NBITS - 1:0] DATA_IN;
   input  wire EN;
   output reg  [NBITS - 1:0] DATA_OUT;


   wire        ena   = 'h1;
   wire        wea   = 'h0;
   wire [15:0] dina  = 'h0;
   reg  [9:0]  addra ;
   wire [15:0] douta ;
   
   initial addra = 'h0;
   always@(posedge CLK)
       if (RST) 
            addra <= 'h0;
       else if (addra == 'h3FF) 
            addra <= 'h0;
       else 
            addra <= addra + 1;
   
   blk_mem_gen_0 blk_mem_gen_0 (
       .clka  ( CLK    ),
       .ena   ( ena    ),
       .wea   ( wea    ),
       .addra ( addra  ),
       .dina  ( dina   ),
       .douta ( douta  )
   );

   // Align the incoming data stream with the BRAM output. A DATA_OUT value of 0 
   // equates to the input data stream matching the expected sequence.
   
   reg [NBITS - 1:0] DATA_IN_0;
   reg [NBITS - 1:0] DATA_IN_1;
   reg [NBITS - 1:0] DATA_IN_2;
   reg [NBITS - 1:0] DATA_IN_3;
   reg [NBITS - 1:0] DATA_IN_4;
   reg [NBITS - 1:0] DATA_IN_5;
   reg [NBITS - 1:0] DATA_IN_6;
   always@(posedge CLK)
   begin
       DATA_IN_0 <= DATA_IN  ;
       DATA_IN_1 <= DATA_IN_0;
       DATA_IN_2 <= DATA_IN_1;
       DATA_IN_3 <= DATA_IN_2;
       DATA_IN_4 <= DATA_IN_3;
       DATA_IN_5 <= DATA_IN_4;
       DATA_IN_6 <= DATA_IN_5;
       DATA_OUT  <= douta ^ DATA_IN_6;
   end

endmodule




