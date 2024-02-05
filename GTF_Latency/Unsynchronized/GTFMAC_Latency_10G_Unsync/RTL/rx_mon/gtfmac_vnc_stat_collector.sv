/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------
//
//  Description: 
//  This module increments a counter by the amount 'incr' on a clock-by-clock 
//  basis. It's assumed that retiming happens outside the block - for example, 
//  the 'snapshot' pulse should be retimined into the 'clk' domain by a 
//  syncer_pulse, and the counter_hold should be retimed (if necessary) outside 
//  too.
//
//  NOTE: rst was removed from this logic to reduce routing congestion.
//        Consequently the driver/verif env is required to "tick" (assert
//        snapshot input) after reset to bring the values to a known state.
//
//  NOTE: If INCR_WIDTH > 1, then only capture the initial change, and wait
//        for incr to return to 0 before capturing another change.
//
//------------------------------------------------------------------------------

module gtfmac_vnc_stat_collector #(
   parameter INCR_WIDTH = 1,
   parameter CNTR_WIDTH = 32,
   parameter EDGE       = 0,  // Capture rising edge only.
   parameter SATURATE   = 0   // Stop counting, no overflow

) (
   input                        clk,
   input       [INCR_WIDTH-1:0] incr,
   input                        snapshot,
   output wire [CNTR_WIDTH-1:0] stat
);

   reg                    snapshot_R;
   reg   [CNTR_WIDTH-1:0] counter;
   reg   [CNTR_WIDTH-1:0] counter_hold;
   logic [INCR_WIDTH-1:0] incr_int;
   logic                  capture;

   assign stat = counter_hold;

   generate
      if (EDGE == 0) begin : no_edge_detect
         assign incr_int = incr;
      end
      else begin : edge_detect
         logic incr_R;

         always @(posedge clk) begin
             if (|incr == 1'b1) begin
                 incr_R <= 1'b1;
             end
             else if (|incr == 1'b0) begin
                 incr_R <= 1'b0;
             end
         end

         assign incr_int = {INCR_WIDTH{~incr_R}} & incr;
      end
   endgenerate

   always @ (posedge clk) begin
      snapshot_R <= snapshot;
      capture    <= ~snapshot_R & snapshot;

      if (capture == 1'b1) begin
         counter_hold <= counter;
         counter      <= incr_int;
      end
      else begin
         if (SATURATE == 0 || SATURATE == 1 && (&counter) == 1'b0) begin
            counter <=  counter + incr_int;
         end
      end
   end

endmodule
