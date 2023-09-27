/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

// Frequency counter...
//
//   Determine sample duration...
//      Sample window(sec's) = Freq(clk_samp) * samp_count_in 
//
//   Frequency Calculation...
//      Freq(clk) = Freq(clk_samp) * samp_count_in / samp_count_out


module freq_counter (
    // System Interface
    input  wire        sys_if_rstn   ,
    input  wire        en_sample     ,
    input  wire        clk_samp      ,
    output reg  [31:0] clk_count
);


// ======================================================================
//  clk_samp domain

wire aresetn_sync;
syncer_reset syncer_reset_aresetn (
    .clk          ( clk_samp     ),
    .resetn_async ( sys_if_rstn  ),
    .resetn       ( aresetn_sync )
);

wire en_sample_sync;
syncer_level syncer_level_en_sample (
    .resetn       ( aresetn_sync   ),
    .clk          ( clk_samp       ),
    .datain       ( en_sample      ),
    .dataout      ( en_sample_sync )
);

reg en_sample_sync_0;
always@(posedge clk_samp)
begin
    if ( !aresetn_sync )
        en_sample_sync_0 <= 0;
    else
        en_sample_sync_0 <= en_sample_sync;
end

reg en_sample_start;
reg en_sample_end;
always@(posedge clk_samp)
begin
    if ( !aresetn_sync ) begin
        en_sample_start <= 0;
        en_sample_end   <= 0;
    end else begin
        en_sample_start <= ~en_sample_sync_0 &&  en_sample_sync;
        en_sample_end   <=  en_sample_sync_0 && ~en_sample_sync;
    end
end


// Counter in clk domain...
reg [31:0] clk_count_i;
always@(posedge clk_samp)
begin
    if ( !aresetn_sync )
        clk_count_i <= 0;
    else if ( en_sample_start )
        clk_count_i <= 1;
    else
        clk_count_i <= clk_count_i + 1;
end

always@(posedge clk_samp)
begin
    if ( !aresetn_sync )
        clk_count <= 0;
    else if ( en_sample_end )
        clk_count <= clk_count_i;
end


endmodule

