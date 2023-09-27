/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

module gtfmac_vnc_latency # (

    parameter  TIMER_WIDTH      = 16,
    parameter  RAM_DEPTH        = 4096,
    parameter  RAM_ADDR_WIDTH   = 12

)
(
    // AXI I/F to JTAG 
    input       wire            axi_clk                      ,
    input       wire            axi_rstn                     ,

//    input       wire    [31:0]  axil_araddr                  ,
//    input       wire            axil_arvalid                 ,
//    output      reg             axil_arready                 ,
//    output      reg     [31:0]  axil_rdata                   ,
//    output      wire    [1:0]   axil_rresp                   ,
//    output      reg             axil_rvalid                  ,
//    input       wire            axil_rready                  ,
//    input       wire    [31:0]  axil_awaddr                  ,
//    input       wire            axil_awvalid                 ,
//    output      reg             axil_awready                 ,
//    input       wire    [31:0]  axil_wdata                   ,
//    input       wire            axil_wvalid                  ,
//    output      reg             axil_wready                  ,
//    output      reg             axil_bvalid                  ,
//    output      wire    [1:0]   axil_bresp                   ,
//    input       wire            axil_bready                  ,

    // Clock and resets from respective blocks...
    input       wire                       tx_clk                     ,
    input       wire                       tx_rstn                    ,
                                           
    input       wire                       rx_clk                     ,
    input       wire                       rx_rstn                    ,
                                           
    input       wire                       lat_clk                    ,
    input       wire                       lat_rstn                   ,
                                           
    // Latency ILA                                          
    output      wire [TIMER_WIDTH-1:0]     lat_mon_sent_time_ila      ,
    output      wire [TIMER_WIDTH-1:0]     lat_mon_rcvd_time_ila      ,
    output      wire [TIMER_WIDTH-1:0]     lat_mon_delta_time_ila     ,
    output      wire                       lat_mon_send_event_ila     ,
    output      wire                       lat_mon_rcv_event_ila      ,
    output      wire [31:0]                lat_mon_delta_time_idx_ila ,
                                           
    input       wire                       pattern_sent               ,
    input       wire                       pattern_rcvd               ,


    input       logic                      go                         , // start collecting samples
    input       logic                      pop                        , // pop next entry
    input       logic                      clear                      , // reset all pointers.  Assumes go=0
    input       logic  [31:0]              lat_pkt_cnt                , // number of packets to collect
                                                                      
    output      logic                      full                       , // status and also auto-clears go
    output      logic  [RAM_ADDR_WIDTH:0]  datav                      , // Number of records
    output      logic                      time_rdy                   , // pulse when a read has occurred
    output      logic  [TIMER_WIDTH-1:0]   tx_time                    , // transmit time
    output      logic  [TIMER_WIDTH-1:0]   rx_time                    , // receive time
                                                                      
    output      logic [31:0]               delta_time_accu            , 
    output      logic [31:0]               delta_time_idx             , 
    output      logic [TIMER_WIDTH-1:0]    delta_time_max             , 
    output      logic [TIMER_WIDTH-1:0]    delta_time_min             , 
    output      logic [TIMER_WIDTH-1:0]    delta_adj_factor           , 
    output      logic                      delta_done_sync            


    //// Signalling from the MAC
    //input       wire            tx_sopin,
    //input       wire            tx_enain,
    //input       wire            tx_rdyout,
    //input       wire            tx_can_start,
    //input       wire            tx_eopin,
    //input       wire            tx_start_measured_run,
    //
    //input       wire            rx_sof,
    //input       wire            rx_start_measured_run
);

// ##################################################################
//
//   Sync to AXI Clock Domains
//
// ##################################################################
    gtfmac_vnc_lat_mon # (
        .TIMER_WIDTH        (TIMER_WIDTH),
        .RAM_DEPTH          (RAM_DEPTH),
        .RAM_ADDR_WIDTH     (RAM_ADDR_WIDTH)
    ) i_lat_mon (
        // Clock and resets from respective blocks...
        .tx_clk                     (tx_clk),
        .tx_rstn                    (tx_rstn),

        .rx_clk                     (rx_clk),
        .rx_rstn                    (rx_rstn),

        .lat_clk                    (lat_clk),
        .lat_rstn                   (lat_rstn),

        // AXI Clock for sync'ing to AXI processor interface
        .axi_clk                    (axi_clk),
        .axi_rstn                   (axi_rstn),


        // Input Control from PIF
        .go                         (go),
        .pop                        (pop),
        .clear                      (clear),
        .lat_pkt_cnt                (lat_pkt_cnt),

        // Output Status to PIF
        .full                       (full),
        .datav                      (datav),
        .time_rdy                   (time_rdy),

        // Event Time Stamps
        .tx_time                    (tx_time),
        .rx_time                    (rx_time),

        // Delta Data
        .delta_time_accu            (delta_time_accu),
        .delta_time_idx             (delta_time_idx),
        .delta_time_max             (delta_time_max),
        .delta_time_min             (delta_time_min),

        // Delta Status
        .delta_done_sync            (delta_done_sync),
        .delta_adj_factor           (delta_adj_factor),

        // Latency monitor ILA signals
        .lat_mon_sent_time_ila      (lat_mon_sent_time_ila),
        .lat_mon_rcvd_time_ila      (lat_mon_rcvd_time_ila),
        .lat_mon_delta_time_ila     (lat_mon_delta_time_ila),
        .lat_mon_send_event_ila     (lat_mon_send_event_ila),
        .lat_mon_rcv_event_ila      (lat_mon_rcv_event_ila),
        .lat_mon_delta_time_idx_ila (lat_mon_delta_time_idx_ila),
        
        .pattern_sent               (pattern_sent),
        .pattern_rcvd               (pattern_rcvd),
        
        //.tx_sopin                   (tx_sopin),
        //.tx_enain                   (tx_enain),
        //.tx_rdyout                  (tx_rdyout),
        //.tx_can_start               (tx_can_start),
        //.tx_start_latency_run       (tx_start_measured_run),
        //.tx_eopin                   (tx_eopin),
        //
        //.rx_sof                     (rx_sof),
        //.rx_start_latency_run       (rx_start_measured_run)
        .tx_start_latency_run       ('h0),
        .rx_start_latency_run       ('h0)
        
    );



endmodule
