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
    input       wire            axi_clk,
    input       wire            axi_rstn,

    input       wire    [31:0]  axil_araddr,
    input       wire            axil_arvalid,
    output      reg             axil_arready,
    output      reg     [31:0]  axil_rdata,
    output      wire    [1:0]   axil_rresp,
    output      reg             axil_rvalid,
    input       wire            axil_rready,
    input       wire    [31:0]  axil_awaddr,
    input       wire            axil_awvalid,
    output      reg             axil_awready,
    input       wire    [31:0]  axil_wdata,
    input       wire            axil_wvalid,
    output      reg             axil_wready,
    output      reg             axil_bvalid,
    output      wire    [1:0]   axil_bresp,
    input       wire            axil_bready,


    // Clock and resets from respective blocks...
    input       wire            tx_clk,
    input       wire            tx_rstn,

    input       wire            rx_clk,
    input       wire            rx_rstn,

    input       wire            lat_clk,
    input       wire            lat_rstn,

    // Latency ILA
    output wire [TIMER_WIDTH-1:0] lat_mon_sent_time_ila,
    output wire [TIMER_WIDTH-1:0] lat_mon_rcvd_time_ila,
    output wire [TIMER_WIDTH-1:0] lat_mon_delta_time_ila,
    output wire                   lat_mon_send_event_ila,
    output wire                   lat_mon_rcv_event_ila,
    output wire [31:0]            lat_mon_delta_time_idx_ila,

    input       wire            data_rate,

    input       wire            lat_sel,
    input       wire            pattern_sent,
    input       wire            pattern_rcvd,

    // Signalling from the MAC
    input       wire            tx_sopin,
    input       wire            tx_enain,
    input       wire            tx_rdyout,
    input       wire            tx_can_start,
    input       wire            tx_eopin,
    input       wire            tx_start_measured_run,

    input       wire            rx_sof,
    input       wire            rx_start_measured_run
);

    logic                           go;             // start collecting samples
    logic                           pop;            // pop next entry
    logic                           clear;          // reset all pointers.  Assumes go=0
    logic   [31:0]                  lat_pkt_cnt;    // number of packets to collect

    logic                           full;           // status and also auto-clears go
    logic   [RAM_ADDR_WIDTH:0]      datav;          // Number of records
    logic                           time_rdy;       // pulse when a read has occurred
    logic   [TIMER_WIDTH-1:0]       tx_time;        // transmit time
    logic   [TIMER_WIDTH-1:0]       rx_time;        // receive time

    logic [31:0]                    delta_time_accu;
    logic [31:0]                    delta_time_idx;
    logic [TIMER_WIDTH-1:0]         delta_time_max;
    logic [TIMER_WIDTH-1:0]         delta_time_min;
    logic [TIMER_WIDTH-1:0]         delta_adj_factor;
    logic                           delta_done_sync;

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
        
        .tx_sopin                   (tx_sopin),
        .tx_enain                   (tx_enain),
        .tx_rdyout                  (tx_rdyout),
        .tx_can_start               (tx_can_start),
        .tx_start_latency_run       (tx_start_measured_run),
        .tx_eopin                   (tx_eopin),

        .rx_sof                     (rx_sof),
        .rx_start_latency_run       (rx_start_measured_run),


        .data_rate                  (data_rate)
        
    );




// ##################################################################
//
//   Sync to AXI Clock Domains
//
// ##################################################################
    gtfmac_vnc_lat_mon_pif  # (
        .TIMER_WIDTH        (TIMER_WIDTH),
        .RAM_ADDR_WIDTH     (RAM_ADDR_WIDTH)
    ) i_lat_mon_pif (
        // AXI I/F to JTAG 
        .axi_aclk                   (axi_clk),
        .axi_aresetn                (axi_rstn),

        .axil_araddr                (axil_araddr),
        .axil_arvalid               (axil_arvalid),
        .axil_arready               (axil_arready),
        .axil_rdata                 (axil_rdata),
        .axil_rresp                 (axil_rresp),
        .axil_rvalid                (axil_rvalid),
        .axil_rready                (axil_rready),
        .axil_awaddr                (axil_awaddr),
        .axil_awvalid               (axil_awvalid),
        .axil_awready               (axil_awready),
        .axil_wdata                 (axil_wdata),
        .axil_wvalid                (axil_wvalid),
        .axil_wready                (axil_wready),
        .axil_bvalid                (axil_bvalid),
        .axil_bresp                 (axil_bresp),
        .axil_bready                (axil_bready),

        // Output Control Signals
        .lm_go                      (go),
        .lm_pop                     (pop),
        .lm_clear                   (clear),
        .lm_lat_pkt_cnt             (lat_pkt_cnt),

        // Status
        .lm_full                    (full),
        .lm_datav                   (datav),
        .lm_time_rdy                (time_rdy),

        // Event Time Stamps
        .lm_snd_time                (tx_time),
        .lm_rcv_time                (rx_time),

        // Delta Data
        .lm_delta_time_accu         (delta_time_accu),
        .lm_delta_time_idx          (delta_time_idx),
        .lm_delta_time_max          (delta_time_max),
        .lm_delta_time_min          (delta_time_min),
        .lm_delta_adj_factor        (delta_adj_factor),

        // Delta Status
        .lm_delta_done_sync         (delta_done_sync) 
    );

endmodule
