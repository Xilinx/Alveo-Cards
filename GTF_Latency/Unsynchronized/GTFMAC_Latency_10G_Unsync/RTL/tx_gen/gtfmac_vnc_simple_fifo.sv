/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------
//
//  Description: Implement a simple FIFO.
//
//------------------------------------------------------------------------------

module gtfmac_vnc_simple_fifo #(
   parameter WIDTH     = 32,
   parameter REG       = 0,
   parameter DEPTH     = 16,
   parameter DEPTHLOG2 = 4,
   parameter RESET     = 0,

   parameter ALMOSTEMPTY = DEPTH/4,
   parameter ALMOSTFULL  = DEPTH-ALMOSTEMPTY,
   parameter CENTERED    = DEPTH/2,
   parameter FULL        = DEPTH
 )
(
  input  wire               clk,
  input  wire               reset,
  input  wire   [WIDTH-1:0] wdat,
  input  wire               we,

  input  wire               re,
  output reg    [WIDTH-1:0] rdat,
  output wire   [WIDTH-1:0] rdat_unreg,

  input       [DEPTHLOG2:0] full_threshold,
  input       [DEPTHLOG2:0] a_empty_threshold,
  input       [DEPTHLOG2:0] a_full_threshold,
  input       [DEPTHLOG2:0] c_threshold,

  output reg                empty,
  output reg                almost_empty,
  output reg                almost_full,
  output reg                centered,
  output wire [DEPTHLOG2:0] fill_level,
  output reg                full
);

   reg  [DEPTHLOG2-1:0] wadd_r;
   reg  [DEPTHLOG2-1:0] wadd_nxt;
   reg  [DEPTHLOG2-1:0] radd_nxt;
   reg  [DEPTHLOG2-1:0] radd_r;
   reg      [WIDTH-1:0] reg_arr_r [DEPTH-1:0];
   reg      [WIDTH-1:0] rdat_r;
   wire     [WIDTH-1:0] rdat_int;

   reg    [DEPTHLOG2:0] fill_level_cnt;
   reg    [DEPTHLOG2:0] fill_level_cnt_nxt;


   assign fill_level = fill_level_cnt;

   always @ (posedge clk) begin
      if (reset == 1'b1) begin
         wadd_r         <= {DEPTHLOG2 {1'b0}};
         radd_r         <= {DEPTHLOG2 {1'b0}};
         fill_level_cnt <= {1'b0, {DEPTHLOG2 {1'b0}}};
         empty          <= 1'b1;
         almost_empty   <= 1'b1;
         almost_full    <= 1'b0;
         centered       <= 1'b0;
         full           <= 1'b0;
      end
      else begin
         wadd_r         <= wadd_nxt;
         radd_r         <= radd_nxt;
         fill_level_cnt <= fill_level_cnt_nxt;
         empty          <= ~|fill_level_cnt_nxt;
         full           <= (fill_level_cnt_nxt == full_threshold) ? 1'b1 : 1'b0;
         almost_empty   <= (fill_level_cnt_nxt > a_empty_threshold)   ? 1'b0 : 1'b1;
         almost_full    <= (fill_level_cnt_nxt <= a_full_threshold)   ? 1'b0 : 1'b1;
         centered       <= (fill_level_cnt_nxt >= c_threshold)    ? 1'b1 : 1'b0;
      end
   end

   // Output all 0s if empty.  A 'vld' signal can then be part of the FIFOed data
   assign rdat_int   = (empty) ? {WIDTH{1'b0}} : reg_arr_r [radd_r];
   assign rdat_unreg = rdat_int;

   always @* begin
      if (REG)
         rdat = rdat_r;
      else begin
         rdat = rdat_int;
      end
   end

   always @(posedge clk) begin
      if (reset == 1'b1) begin
        rdat_r <= {WIDTH{1'b0}};
      end
      else begin
        rdat_r <= re ? rdat_int : rdat_r;
      end
   end

   // Simple fifo write read logic.
   always @* begin
      wadd_nxt =  wadd_r;
      radd_nxt =  radd_r;

      if (we == 1'b1)
         wadd_nxt = (wadd_r == DEPTH-1) ? {1'b0, {DEPTHLOG2 {1'b0}}} :  wadd_r + 1'b1;

      if (re & !empty)
         radd_nxt = (radd_r == DEPTH-1) ? {1'b0, {DEPTHLOG2 {1'b0}}} :  radd_r + 1'b1;

   end

   // Flag  and threshold logic.
   // Operates in "safe" mode, can't underflow.
   always @* begin
      // Fifo full/empty/almost.
      if ( we && ! (re && !empty) )
         fill_level_cnt_nxt = fill_level_cnt + 1;

      else if ( !we && re && !empty )
         fill_level_cnt_nxt = fill_level_cnt - 1;

      else
         fill_level_cnt_nxt = fill_level_cnt;
   end

   generate
      if ( RESET == 1 ) begin : ARRAY_RESET
         always @ (posedge clk) begin
            if (reset == 1'b1) begin
               for (int i = 0; i < DEPTH; i++) begin
                  reg_arr_r[i] <= {WIDTH {1'b0}};
               end
            end
            else begin
               if (we) reg_arr_r[wadd_r] <= wdat;
            end
         end
      end else begin: ARRAY_UNRESET
         always @(posedge clk) begin
             if (we) reg_arr_r[wadd_r] <= wdat;
         end
      end
   endgenerate

endmodule // simple_fifo
