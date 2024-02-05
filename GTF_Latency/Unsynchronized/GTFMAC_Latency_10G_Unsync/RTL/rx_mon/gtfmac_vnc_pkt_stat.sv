/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

module gtfmac_vnc_pkt_stat (

    input   wire            clk,
    input   wire            rst,

    input   wire            din_ena,
    input   wire            din_pre,
    input   wire            din_sop,
    input   wire    [63:0]  din_data,
    input   wire            din_eop,
    input   wire    [2:0]   din_mty,
    input   wire            din_err,
    input   wire            din_empty,

    input   wire            din_bad_fcs,
    input   wire            din_vlan,
    input   wire            din_broadcast,
    input   wire            din_multicast,
    input   wire            din_unicast,

    input   wire            add_4,

    input   wire            stat_clk,
    input   wire            stat_rst,
    input   wire            stat_tick

);


    logic           frame_active;
    //NA logic   [13:0]  byte_count;
    //NA logic           is_vlan;
    //NA logic           is_broadcast;
    //NA logic           is_multicast;
    //NA logic           is_unicast;
    //NA logic           is_err;
    //NA logic           is_bad_fcs;
    logic           stat_incr;

    logic           stat_total_packets_incr;


    always @(posedge clk) begin

        stat_incr       <= 1'b0;

        if (frame_active && din_ena && din_eop) begin
            frame_active    <= 1'b0;
            stat_incr       <= 1'b1;
        end else if (!frame_active && din_empty) begin
            stat_incr       <= 1'b1;
        end else if (!frame_active && din_ena && din_sop) begin
            frame_active    <= 1'b1;
        end

        if (rst) begin
            frame_active    <= 1'b0;
            stat_incr       <= 1'b0;
        end

    end

    // We won't reset these incr signals, because the stat_collector
    // requires a 'tick' before the stats start being collected.
    always @(posedge clk) begin
    
        stat_total_packets_incr          <= 1'b0;
    
        if (stat_incr) begin
    
            stat_total_packets_incr          <= 1'b1;
    
        end
    
    end

    // --------------------------------------------------------------------------
    // COUNTERS
    // --------------------------------------------------------------------------

    wire    lcl_tick;

    gtfmac_vnc_syncer_pulse i_stat_tick (
       .clkin        (stat_clk),
       .clkin_reset  (~stat_rst),
       .clkout       (clk),
       .clkout_reset (~rst),

       .pulsein      (stat_tick),
       .pulseout     (lcl_tick)
    );

    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_total_packets (
    
        .clk        (clk),
        .incr       (stat_total_packets_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_total_packets)
    );
    
endmodule
