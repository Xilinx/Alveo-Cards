/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

module gtfmac_vnc_rx_mon (

    // RX Monitor Clock (RX User Clock)
    input       wire            mon_clk,
    input       wire            mon_rst,

    // RX User clock and reset
    input       wire            rx_clk,
    input       wire            rx_rst,

    // RX AXIS I/F from GTF and SOF marker to Latency Monitor
    input       wire            rx_axis_tvalid,
    input       wire [63:0]     rx_axis_tdata,
    input       wire [7:0]      rx_axis_tlast,
    input       wire [7:0]      rx_axis_tpre,
    input       wire            rx_axis_terr,
    input       wire [4:0]      rx_axis_tterm,
    input       wire [1:0]      rx_axis_tsof,
    output      wire            rx_start_measured_run,

    input       wire            ctl_vnc_mon_en,
    input       wire            ctl_rx_data_rate,
    input       wire            ctl_rx_packet_framing_enable,
    input       wire            ctl_rx_custom_preamble_en,
    input       wire    [63:0]  ctl_vnc_rx_custom_preamble,
    input       wire    [13:0]  ctl_vnc_max_len,
    input       wire    [13:0]  ctl_vnc_min_len,

    input       wire            stat_clk,
    input       wire            stat_rst,
    input       wire            stat_tick
    
);


    wire                gtf_ena;
    wire                gtf_sop;
    wire                gtf_eop;
    wire    [2:0]       gtf_mty;
    wire    [63:0]      gtf_data;
    wire                gtf_err;
    wire                gtf_empty;

    gtfmac_vnc_rx_gtfmac_if  i_rx_gtfmac_if  (

        .rx_axis_clk                    (rx_clk),
        .rx_axis_rst                    (rx_rst),

        .ctl_rx_data_rate               (ctl_rx_data_rate),
        .ctl_rx_custom_preamble_en      (ctl_rx_custom_preamble_en),

        .rx_axis_tvalid                 (rx_axis_tvalid),           // input      wire
        .rx_axis_tdata                  (rx_axis_tdata),            // input      wire [63:0]
        .rx_axis_tlast                  (rx_axis_tlast),            // input      wire [7:0]
        .rx_axis_tpre                   (rx_axis_tpre),             // input      wire [7:0]
        .rx_axis_terr                   (rx_axis_terr),             // input      wire
        .rx_axis_tterm                  (rx_axis_tterm),            // input      wire [4:0]
        .rx_axis_tsof                   (rx_axis_tsof),             // input      wire [1:0]

        .dout_ena                       (gtf_ena),
        .dout_sop                       (gtf_sop),
        .dout_data                      (gtf_data),
        .dout_eop                       (gtf_eop),
        .dout_mty                       (gtf_mty), // [3-1:0]
        .dout_err                       (gtf_err),
        .dout_empty                     (gtf_empty),
        .rx_start_measured_run          (rx_start_measured_run),    // output wire

        .stat_bad_tpre                  (),
        .stat_unexpected_tpre           (),
        .stat_missing_preamble          (),
        .stat_missed_tterm              (),
        .stat_terminate_during_preamble (),
        .stat_missed_tsof               (),
        .stat_incomplete_preamble       (),
        .stat_invalid_tterm             ()

    );


gtfmac_vnc_pkt_stat i_rx_mon_stat (
    .clk            ( rx_clk    ),
    .rst            ( rx_rst    ),

    .din_ena        ( gtf_ena   ),
    .din_pre        ( 1'b0      ),
    .din_sop        ( gtf_sop   ),
    .din_data       ( gtf_data  ),
    .din_eop        ( gtf_eop   ),
    .din_mty        ( gtf_mty   ),
    .din_err        ( gtf_err   ),
    .din_empty      ( gtf_empty ),

    .din_bad_fcs    ( 1'b0      ),
    .din_vlan       ( 1'b0      ),
    .din_broadcast  ( 1'b0      ),
    .din_multicast  ( 1'b0      ),
    .din_unicast    ( 1'b0      ),

    .add_4          ( 1'b0      ),

    .stat_clk       ( stat_clk  ),
    .stat_rst       ( stat_rst  ),
    .stat_tick      ( stat_tick )
);



endmodule
