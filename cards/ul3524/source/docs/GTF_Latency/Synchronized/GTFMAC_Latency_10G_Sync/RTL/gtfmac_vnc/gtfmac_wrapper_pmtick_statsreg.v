/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

module gtfmac_wrapper_pmtick_statsreg
#(
  parameter OUTWIDTH = 16,
  parameter INWIDTH = 16
 )
(
   input wire                       clk,
   input wire                       resetn,
   input wire                       pm_tick,
   input wire [INWIDTH-1:0]         pulsein,
   input wire                       hold_output,
   output reg [OUTWIDTH-1:0]        statsout
);

  wire pm_tick_pipe;
  wire pm_tick_post_pipe;

  assign pm_tick_pipe = pm_tick;


  assign pm_tick_post_pipe = pm_tick_pipe;

  wire hold_output_pipe;
  reg  pass_statshold_value;


  assign hold_output_pipe = hold_output;

  assign pass_statshold_value = ~hold_output_pipe;

  wire [INWIDTH-1:0] pulsein_r;
  wire [INWIDTH-1:0] pulsein_bus;


  assign pulsein_bus = pulsein;

  assign pulsein_r = pulsein_bus;

   //
   // The following alternative logic breaks up the pm_tick counter into two half-size counters.
   // It is intended to improve timing characteristics of the design mainly for 64-bit counters.
   //

   (* keep = "true" *) reg pm_tick_r;
   (* keep = "true" *) reg pm_tick_d1;

   reg [OUTWIDTH-1:0]      statsout_next;
   reg [OUTWIDTH-1:0]      statshold, statshold_next;
   reg [OUTWIDTH/2-1:0]    counter_lsb, counter_lsb_next;
   reg [OUTWIDTH/2-1:0]    counter_lsb_d1;
   reg                     counter_lsb_ovf, counter_lsb_ovf_next;
   reg [OUTWIDTH/2-1:0]    counter_msb, counter_msb_next;
   reg                     overflow;
   reg                     overflow_next;

   always @* begin

      // LSB counter
      if ( pm_tick_r ) begin
         counter_lsb_next = pulsein_r;
         counter_lsb_ovf_next = 1'b0;
      end
      else begin
         {counter_lsb_ovf_next, counter_lsb_next} = counter_lsb + pulsein_r;
      end

      // MSB counter
      if ( pm_tick_d1 ) begin
         counter_msb_next = 0;
         overflow_next = 1'b0;
         statshold_next = {counter_msb, counter_lsb_d1};
      end
      else begin
         {overflow_next, counter_msb_next} = ( !overflow ) ? counter_msb + counter_lsb_ovf : {1'b1,{(OUTWIDTH/2){1'b1}}};
         statshold_next = statshold;
      end

      statsout_next = pass_statshold_value ? statshold : statsout;
   end


always @( posedge clk or negedge resetn )
    begin
      if ( resetn != 1'b1 )
      begin
        `ifdef HIGH_STATSREG_COUNTER
         // pragma translate_off
         pm_tick_r <= 1'b0;
         pm_tick_d1 <= 1'b0;
         counter_lsb <= {(OUTWIDTH/2){1'b1}}-10;
         counter_lsb_ovf <= 1'b0;
         counter_msb <= {(OUTWIDTH/2){1'b1}};
         overflow <= 1'b0;
         // pragma translate_on
        `elsif LSB_OVF_STATSREG_COUNTER
         // pragma translate_off
         pm_tick_r <= 1'b0;
         pm_tick_d1 <= 1'b0;
         counter_lsb <= {(OUTWIDTH/2){1'b1}}-10;
         counter_lsb_ovf <= 1'b0;
         counter_msb <= {{(OUTWIDTH/3){1'b0}},{(OUTWIDTH/6){1'b1}}};
         overflow <= 1'b0;
         // pragma translate_on
         `else
         pm_tick_r <= 1'b0;
         pm_tick_d1 <= 1'b0;
         counter_lsb <= 0;
         counter_lsb_ovf <= 1'b0;
         counter_msb <= 0;
         overflow <= 1'b0;
         `endif
         statshold <= {OUTWIDTH{1'b0}};
         statsout  <= {OUTWIDTH{1'b0}};
         counter_lsb_d1 <= {(OUTWIDTH/2){1'b0}};
      end
      else begin
         statshold <= statshold_next;
         statsout  <= statsout_next;
         counter_lsb_d1 <= ( !overflow ) ? counter_lsb : {(OUTWIDTH/2){1'b1}};
         pm_tick_r <= pm_tick_post_pipe;
         pm_tick_d1 <= pm_tick_r;
         counter_lsb <= counter_lsb_next;
         counter_lsb_ovf <= counter_lsb_ovf_next;
         counter_msb <= counter_msb_next;
         overflow <= overflow_next;
      end
   end


endmodule // pmtick_statsreg
