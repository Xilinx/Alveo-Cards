/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

module gtfraw_vnc_clock_count (
   input   wire          clk,
   input   wire          one_second_edge,
   output  wire [32-1:0] clocks_per_second
);

   wire          ticks_per_one_second_edge_sync;
   wire          one_second_passed;
   reg  [32-1:0] one_second_count_live;
   reg  [32-1:0] one_second_count_snap;
   reg           ticks_per_one_second_edge_sync_d;

   assign clocks_per_second = one_second_count_snap;

   gtfraw_vnc_syncer_level #(
      .WIDTH (1)
   ) retime_ticks_per_one_second_edge (
      .datain  (one_second_edge),
      .dataout (ticks_per_one_second_edge_sync),
      .clk     (clk) ,
      .reset   (1'b1)
   );

   // Keep a copy from one cycle back.
   always @(posedge clk) begin
      ticks_per_one_second_edge_sync_d <= ticks_per_one_second_edge_sync;
   end

   // Edge detection
   assign one_second_passed = ticks_per_one_second_edge_sync_d ^
                              ticks_per_one_second_edge_sync;

   always @(posedge clk) begin
      if (one_second_passed == 1'b1) begin
         one_second_count_snap <= one_second_count_live;
         one_second_count_live <= 32'd0;
      end else begin
         one_second_count_live <= one_second_count_live + 1'b1;
      end
   end

endmodule
