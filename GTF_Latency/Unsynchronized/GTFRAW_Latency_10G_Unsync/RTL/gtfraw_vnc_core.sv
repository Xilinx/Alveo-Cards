/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

module gtfraw_vnc_core # (
    parameter ONE_SECOND_COUNT = 28'd200_000_000,
    parameter TIMER_WIDTH      = 16,
    parameter RAM_ADDR_WIDTH   = 12
)
(

    ////////////////////////////////////////////////////////////////
    // AXI-Lite Interface
    ////////////////////////////////////////////////////////////////

    // Common AXI I/F Clock and Reset
    input       wire            axi_aclk,
    input       wire            axi_aresetn,

    // AXI I/F to VNC Control 
    input       wire    [31:0]  vnc_axil_araddr,
    input       wire            vnc_axil_arvalid,
    output      wire            vnc_axil_arready,
    output      wire    [31:0]  vnc_axil_rdata,
    output      wire    [1:0]   vnc_axil_rresp,
    output      wire            vnc_axil_rvalid,
    input       wire            vnc_axil_rready,
    input       wire    [31:0]  vnc_axil_awaddr,
    input       wire            vnc_axil_awvalid,
    output      wire            vnc_axil_awready,
    input       wire    [31:0]  vnc_axil_wdata,
    input       wire            vnc_axil_wvalid,
    output      wire            vnc_axil_wready,
    output      wire            vnc_axil_bvalid,
    output      wire    [1:0]   vnc_axil_bresp,
    input       wire            vnc_axil_bready,

    // AXI I/F to Latency Monitor
    input       wire    [31:0]  lat_axil_araddr,
    input       wire            lat_axil_arvalid,
    output      reg             lat_axil_arready,
    output      reg     [31:0]  lat_axil_rdata,
    output      wire    [1:0]   lat_axil_rresp,
    output      reg             lat_axil_rvalid,
    input       wire            lat_axil_rready,
    input       wire    [31:0]  lat_axil_awaddr,
    input       wire            lat_axil_awvalid,
    output      reg             lat_axil_awready,
    input       wire    [31:0]  lat_axil_wdata,
    input       wire            lat_axil_wvalid,
    output      reg             lat_axil_wready,
    output      reg             lat_axil_bvalid,
    output      wire    [1:0]   lat_axil_bresp,
    input       wire            lat_axil_bready,

    ////////////////////////////////////////////////////////////////
    // Generator and Monitor
    ////////////////////////////////////////////////////////////////

    input       wire            gen_clk,
    input       wire            gen_rst,

    input       wire            mon_clk,
    input       wire            mon_rst,

    input       wire            lat_clk,
    input       wire            lat_rstn,

    ////////////////////////////////////////////////////////////////
    // TX Interface
    ////////////////////////////////////////////////////////////////

    output      wire            pattern_sent,
    output      wire            pattern_rcvd,

    input       wire            tx_clk,
    input       wire            tx_rst,

    output      wire [39:0]     gtf_ch_txrawdata,

    input       wire            tx_axis_tready,
    output      wire            tx_axis_tvalid,
    output      wire [63:0]     tx_axis_tdata,
    output      wire [7:0]      tx_axis_tlast,
    output      wire [7:0]      tx_axis_tpre,
    output      wire            tx_axis_terr,
    output      wire [4:0]      tx_axis_tterm,
    output      wire [1:0]      tx_axis_tsof,
    output      wire            tx_axis_tpoison,
    input       wire            tx_axis_tcan_start,

    input       wire            tx_ptp_sop,
    input       wire            tx_ptp_sop_pos,
    input       wire            tx_gb_seq_start,
    input       wire            tx_unfout,

    ////////////////////////////////////////////////////////////////
    // RX Interface
    ////////////////////////////////////////////////////////////////

    input       wire            rx_clk,
    input       wire            rx_rst,

    input       wire [39:0]     gtf_ch_rxrawdata,
    input       wire [15:0]     gtf_ch_rxrawdata_align,
    input       wire            sync_error,

    input       wire            rx_axis_tvalid,
    input       wire [63:0]     rx_axis_tdata,
    input       wire [7:0]      rx_axis_tlast,
    input       wire [7:0]      rx_axis_tpre,
    input       wire            rx_axis_terr,
    input       wire [4:0]      rx_axis_tterm,
    input       wire [1:0]      rx_axis_tsof,

    ////////////////////////////////////////////////////////////////
    // Control and Status
    ////////////////////////////////////////////////////////////////

    // TX/RX Reset Controls
    output      logic           vnc_gtf_ch_gttxreset,
    output      logic           vnc_gtf_ch_txpmareset,
    output      logic           vnc_gtf_ch_txpcsreset,
    output      logic           vnc_gtf_ch_gtrxreset,
    output      logic           vnc_gtf_ch_rxpmareset,
    output      logic           vnc_gtf_ch_rxdfelpmreset,
    output      logic           vnc_gtf_ch_eyescanreset,
    output      logic           vnc_gtf_ch_rxpcsreset,
    output      logic           vnc_gtf_cm_qpll0reset,
    output      logic           gtwiz_reset_tx_pll_and_datapath_in,
    output      logic           gtwiz_reset_tx_datapath_in,
    output      logic           gtwiz_reset_rx_pll_and_datapath_in,
    output      logic           gtwiz_reset_rx_datapath_in,


    output      logic           vnc_gtf_ch_txuserrdy,
    output      logic           vnc_gtf_ch_rxuserrdy,


    input       wire            stat_gtf_rx_internal_local_fault,
    input       wire            stat_gtf_rx_local_fault,
    input       wire            stat_gtf_rx_received_local_fault,
    input       wire            stat_gtf_rx_remote_fault,
                
    input       logic           block_lock,
    
    // Bitslip correction
    output      logic           ctl_gb_seq_sync,
    output      logic           ctl_disable_bitslip,
    output      logic           ctl_correct_bitslip,
    input       logic [6:0]     stat_bitslip_cnt,
    input       logic [6:0]     stat_bitslip_issued,
    input       logic           stat_excessive_bitslip,
    input       logic           stat_bitslip_locked,
    input       logic           stat_bitslip_busy,
    input       logic           stat_bitslip_done,

    ////////////////////////////////////////////////////////////////
    // ILA Status
    ////////////////////////////////////////////////////////////////
    output wire                      ila_gtf_ch_rxrawdata_sof , // = gtf_ch_rxrawdata_sof
    output wire [15:0]               ila_gtf_ch_rxrawdata     , // = gtf_ch_rxrawdata[15:0] 
    output wire                      ila_gtf_ch_txrawdata_sof , // = gtf_ch_txrawdata_sof
    output wire [15:0]               ila_gtf_ch_txrawdata     , // = gtf_ch_txrawdata[15:0]

    output wire [TIMER_WIDTH-1:0]    lat_mon_sent_time_ila,
    output wire [TIMER_WIDTH-1:0]    lat_mon_rcvd_time_ila,
    output wire [TIMER_WIDTH-1:0]    lat_mon_delta_time_ila,
    output wire                      lat_mon_send_event_ila,
    output wire                      lat_mon_rcv_event_ila,
    output wire [31:0]               lat_mon_delta_time_idx_ila,
    output wire                      ctl_vnc_frm_gen_en_0
);

    logic                       lm_go;
    logic                       lm_full;
    logic   [9:0]               lm_datav;
    logic                       lm_pop;
    logic                       lm_clear;
    logic   [TIMER_WIDTH-1:0]   lm_tx_time;
    logic   [TIMER_WIDTH-1:0]   lm_rx_time;
    logic                       lm_time_rdy;

    logic           tx_sop;

    wire            ctl_vnc_frm_gen_en;
    assign          ctl_vnc_frm_gen_en_0 = ctl_vnc_frm_gen_en;
    wire            ctl_vnc_frm_gen_mode;
    wire    [13:0]  ctl_vnc_max_len;
    wire    [13:0]  ctl_vnc_min_len;

    wire            ctl_tx_custom_preamble_en;
    wire    [63:0]  ctl_vnc_tx_custom_preamble;
    wire            ctl_tx_variable_ipg;

    wire            ctl_tx_fcs_ins_enable;
    wire            ctl_tx_data_rate;

    wire            ctl_vnc_mon_en;
    wire            ctl_rx_data_rate;
    wire            ctl_rx_packet_framing_enable;
    wire            ctl_rx_custom_preamble_en;
    wire    [63:0]  ctl_vnc_rx_custom_preamble;
    wire    [31:0]  ctl_num_frames;

    wire            stat_tick_from_pif;
    wire            stat_tick_from_vio;
    wire            stat_tick;

    wire   [15:0]   stat_vnc_tx_overflow;
    wire   [15:0]   stat_tx_unfout;

    wire            tx_axis_tcan_start_0;
    wire [1:0]      rx_axis_tsof_0;

    `include "gtfraw_vnc_top.vh"

    localparam  CFG_FRAME_COUNT = `CONFIG_FRAMES_TO_SEND;

    assign  stat_tick   = stat_tick_from_pif;

    wire        rx_f_rst;

    wire        stat_gtf_tx_rst_sync;
    wire        stat_gtf_rx_rst_sync;
    wire        stat_gtf_block_lock_sync;
    wire        stat_gtf_rx_internal_local_fault_sync;
    wire        stat_gtf_rx_local_fault_sync;
    wire        stat_gtf_rx_received_local_fault_sync;
    wire        stat_gtf_rx_remote_fault_sync;

    reg         [27:0]  one_second_ctr;

    wire        [31:0]  tx_clk_cps;
    wire        [31:0]  rx_clk_cps;
    wire        [31:0]  axi_aclk_cps;
    wire        [31:0]  gen_clk_cps;
    wire        [31:0]  mon_clk_cps;
    wire        [31:0]  lat_clk_cps;
    
    // Scratch registers are used for user 
    wire [31:0] scratch_0;

    reg [31:0] tx_scratch_0;
    always@(posedge tx_clk)
        tx_scratch_0 <= scratch_0;

    reg [31:0] rx_scratch_0;
    always@(posedge rx_clk)
        rx_scratch_0 <= scratch_0;

    wire gtf_ch_txrawdata_sof;
    wire gtf_ch_rxrawdata_sof;
    assign pattern_sent = gtf_ch_txrawdata_sof;
    assign pattern_rcvd = gtf_ch_rxrawdata_sof;


// ##################################################################
//
//   Sync to AXI Clock Domains
//
// ##################################################################
gtfraw_vnc_vnc_pif i_vnc_pif (

    // AXI Interface from JTAG Control
    .axi_aclk                           (axi_aclk),                 // input
    .axi_aresetn                        (axi_aresetn),              // input

    .axil_araddr                        (vnc_axil_araddr),          // input   wire    [31:0]
    .axil_arvalid                       (vnc_axil_arvalid),         // input   wire
    .axil_arready                       (vnc_axil_arready),         // output  reg
    .axil_rdata                         (vnc_axil_rdata),           // output  reg     [31:0]
    .axil_rresp                         (vnc_axil_rresp),           // output  wire    [1:0]
    .axil_rvalid                        (vnc_axil_rvalid),          // output  reg
    .axil_rready                        (vnc_axil_rready),          // input
    .axil_awaddr                        (vnc_axil_awaddr),          // input   wire    [31:0]
    .axil_awvalid                       (vnc_axil_awvalid),         // input   wire
    .axil_awready                       (vnc_axil_awready),         // output  reg
    .axil_wdata                         (vnc_axil_wdata),           // input   wire    [31:0]
    .axil_wvalid                        (vnc_axil_wvalid),          // input   wire
    .axil_wready                        (vnc_axil_wready),          // output  reg
    .axil_bvalid                        (vnc_axil_bvalid),          // output  reg
    .axil_bresp                         (vnc_axil_bresp),           // output  wire    [1:0]
    .axil_bready                        (vnc_axil_bready),          // input

    // Clock counters
    .tx_clk_cps                         (tx_clk_cps),
    .rx_clk_cps                         (rx_clk_cps),
    .axi_aclk_cps                       (axi_aclk_cps),
    .gen_clk_cps                        (gen_clk_cps),
    .mon_clk_cps                        (mon_clk_cps),
    .lat_clk_cps                        (lat_clk_cps),

    // GTF TX/RX Resets
    .vnc_gtf_ch_gttxreset               (vnc_gtf_ch_gttxreset),
    .vnc_gtf_ch_txpmareset              (vnc_gtf_ch_txpmareset),
    .vnc_gtf_ch_txpcsreset              (vnc_gtf_ch_txpcsreset),
    .vnc_gtf_ch_gtrxreset               (vnc_gtf_ch_gtrxreset),
    .vnc_gtf_ch_rxpmareset              (vnc_gtf_ch_rxpmareset),
    .vnc_gtf_ch_rxdfelpmreset           (vnc_gtf_ch_rxdfelpmreset),
    .vnc_gtf_ch_eyescanreset            (vnc_gtf_ch_eyescanreset),
    .vnc_gtf_ch_rxpcsreset              (vnc_gtf_ch_rxpcsreset),
    .vnc_gtf_cm_qpll0reset              (vnc_gtf_cm_qpll0reset),
    .gtwiz_reset_tx_pll_and_datapath_in (gtwiz_reset_tx_pll_and_datapath_in),
    .gtwiz_reset_tx_datapath_in         (gtwiz_reset_tx_datapath_in),
    .gtwiz_reset_rx_pll_and_datapath_in (gtwiz_reset_rx_pll_and_datapath_in),
    .gtwiz_reset_rx_datapath_in         (gtwiz_reset_rx_datapath_in),

    .vnc_gtf_ch_txuserrdy               (vnc_gtf_ch_txuserrdy),
    .vnc_gtf_ch_rxuserrdy               (vnc_gtf_ch_rxuserrdy),

    // GTFMAC Status
    .stat_gtf_rx_rst                    (stat_gtf_rx_rst_sync),
    .stat_gtf_tx_rst                    (stat_gtf_tx_rst_sync),
    .stat_gtf_block_lock                (stat_gtf_block_lock_sync),

    .stat_gtf_rx_internal_local_fault   (stat_gtf_rx_internal_local_fault_sync),
    .stat_gtf_rx_local_fault            (stat_gtf_rx_local_fault_sync),
    .stat_gtf_rx_received_local_fault   (stat_gtf_rx_received_local_fault_sync),
    .stat_gtf_rx_remote_fault           (stat_gtf_rx_remote_fault_sync),

    // Bitslip correction
    .ctl_gb_seq_sync                    (ctl_gb_seq_sync),                      // output  logic
    .ctl_disable_bitslip                (ctl_disable_bitslip),                  // output  logic
    .ctl_correct_bitslip                (ctl_correct_bitslip),                  // output  logic
    .stat_bitslip_cnt                   (stat_bitslip_cnt),                     // input   logic  [6:0]
    .stat_bitslip_issued                (stat_bitslip_issued),                  // input   logic  [6:0]
    .stat_bitslip_locked                (stat_bitslip_locked),                  // input   logic
    .stat_bitslip_busy                  (stat_bitslip_busy),                    // input   logic
    .stat_bitslip_done                  (stat_bitslip_done),                    // input   logic
    .stat_excessive_bitslip             (stat_excessive_bitslip),               // input   logic

    // Generator
    .ctl_vnc_frm_gen_en                 (ctl_vnc_frm_gen_en),                   // output      logic
    .ctl_vnc_frm_gen_mode               (ctl_vnc_frm_gen_mode),                 // output      logic
    .ctl_vnc_max_len                    (ctl_vnc_max_len),                      // output      logic   [13:0]
    .ctl_vnc_min_len                    (ctl_vnc_min_len),                      // output      logic   [13:0]
    .ctl_num_frames                     (ctl_num_frames),                       // output      wire    [31:0]
    .ack_frm_gen_done                   (ack_frm_gen_done),                     // input       wire

    .ctl_tx_start_framing_enable        (ctl_tx_start_framing_enable),          // output      logic
    .ctl_tx_custom_preamble_en          (ctl_tx_custom_preamble_en),            // output      logic
    .ctl_vnc_tx_custom_preamble         (ctl_vnc_tx_custom_preamble),           // output      logic   [63:0]
    .ctl_tx_variable_ipg                (ctl_tx_variable_ipg),                  // output      logic

    .ctl_tx_fcs_ins_enable              (ctl_tx_fcs_ins_enable),                // output      logic
    .ctl_tx_data_rate                   (ctl_tx_data_rate),                     // output      logic

    .ctl_vnc_tx_start_lat_run           (ctl_vnc_tx_start_lat_run),             // output
    .ack_vnc_tx_start_lat_run           (1'b0),                                 // input

    // Monitor
    .ctl_vnc_mon_en                     (ctl_vnc_mon_en),                       // output      logic
    .ctl_rx_data_rate                   (ctl_rx_data_rate),                     // output      logic
    .ctl_rx_packet_framing_enable       (ctl_rx_packet_framing_enable),         // output      logic
    .ctl_rx_custom_preamble_en          (ctl_rx_custom_preamble_en),            // output      logic
    .ctl_vnc_rx_custom_preamble         (ctl_vnc_rx_custom_preamble),           // output      logic   [63:0]

    // VNC Statistics
    .scratch_0 (scratch_0),
    .stat_tick                          (stat_tick_from_pif)                    // output      logic
);


// ##################################################################
//
//   TX Data Generator
//
// ##################################################################

gtfraw_vnc_tx_gen_raw gtfraw_vnc_tx_gen_raw (
    .axi_aclk             ( axi_aclk               ),
    .axi_aresetn          ( axi_aresetn            ),
                                                   
    .gen_clk              ( gen_clk                ),
    .gen_rst              ( gen_rst                ),
                                                   
    .ctl_vnc_frm_gen_en   ( ctl_vnc_frm_gen_en     ),
    .ctl_num_frames       ( ctl_num_frames         ),
    .ack_frm_gen_done     ( ack_frm_gen_done       ),
                                                   
    .tx_clk               ( tx_clk                 ),
    .tx_rst               ( tx_rst                 ),

    .gtf_ch_txrawdata     ( gtf_ch_txrawdata[15:0] ),
    .gtf_ch_txrawdata_sof ( gtf_ch_txrawdata_sof   )
);

assign gtf_ch_txrawdata[39:16] = 'h0;

// ##################################################################
//
//   RX Data Monitor
//
// ##################################################################
gtfraw_vnc_rx_mon i_rx_mon (

    // RX Monitor Clock (RX User Clock)
    .mon_clk                            (mon_clk),                              // input       wire
    .mon_rst                            (mon_rst),                              // input       wire

    // RX User clock and reset
    .rx_clk                             (rx_clk),                               // input       wire
    .rx_rst                             (rx_rst),                               // input       wire

    // Raw data from GTF sampled by 1 RX clock.... 
    .gtf_ch_rxrawdata_align             (gtf_ch_rxrawdata_align),
    .sync_error                         (sync_error),

    // Aligned RX Raw Data from GTF...
	.gtf_ch_rxrawdata                   (gtf_ch_rxrawdata),                       
	.gtf_ch_rxrawdata_sof               (gtf_ch_rxrawdata_sof),                   

    // RX AXIS I/F from GTF and SOF marker to Latency Monitor
	.rx_axis_tvalid                     (rx_axis_tvalid),                       // input       wire
	.rx_axis_tdata                      (rx_axis_tdata),                        // input       wire [63:0]
	.rx_axis_tlast                      (rx_axis_tlast),                        // input       wire [7:0]
	.rx_axis_tpre                       (rx_axis_tpre),                         // input       wire [7:0]
	.rx_axis_terr                       (rx_axis_terr),                         // input       wire
	.rx_axis_tterm                      (rx_axis_tterm),                        // input       wire [4:0]
	.rx_axis_tsof                       (rx_axis_tsof),                         // input       wire [1:0]
	.rx_start_measured_run              (rx_start_measured_run),                // output      wire

    .ctl_vnc_mon_en                     (ctl_vnc_mon_en),                       // input       wire
    .ctl_rx_data_rate                   (ctl_rx_data_rate),                     // input       wire
    .ctl_rx_packet_framing_enable       (ctl_rx_packet_framing_enable),         // input       wire
    .ctl_rx_custom_preamble_en          (ctl_rx_custom_preamble_en),            // input       wire
    .ctl_vnc_rx_custom_preamble         (ctl_vnc_rx_custom_preamble),           // input       wire    [63:0]
    .ctl_vnc_max_len                    (ctl_vnc_max_len),                      // input       wire    [13:0]
    .ctl_vnc_min_len                    (ctl_vnc_min_len)                       // input       wire    [13:0]
);

    
// ##################################################################
//
//   Latency Monitor
//
// ##################################################################
gtfraw_vnc_latency i_latency (

    // Clock and resets
    .tx_clk                             (tx_clk),                               // input       wire
    .tx_rstn                            (~tx_rst),                              // input       wire

    .rx_clk                             (rx_clk),                               // input       wire
    .rx_rstn                            (~rx_rst),                              // input       wire

    .lat_clk                            (lat_clk),                              // input       wire
    .lat_rstn                           (lat_rstn),                             // input       wire

    // AXI Interface from JTAG I/F 
    .axi_clk                            (axi_aclk),                             // input       wire
    .axi_rstn                           (axi_aresetn),                          // input       wire
                                                                                           
    .axil_araddr                        (lat_axil_araddr),                      // input   wire    [31:0]
    .axil_arvalid                       (lat_axil_arvalid),                     // input   wire
    .axil_arready                       (lat_axil_arready),                     // output  reg
    .axil_rdata                         (lat_axil_rdata),                       // output  reg     [31:0]
    .axil_rresp                         (lat_axil_rresp),                       // output  wire    [1:0]
    .axil_rvalid                        (lat_axil_rvalid),                      // output  reg
    .axil_rready                        (lat_axil_rready),                      // input
    .axil_awaddr                        (lat_axil_awaddr),                      // input   wire    [31:0]
    .axil_awvalid                       (lat_axil_awvalid),                     // input   wire
    .axil_awready                       (lat_axil_awready),                     // output  reg
    .axil_wdata                         (lat_axil_wdata),                       // input   wire    [31:0]
    .axil_wvalid                        (lat_axil_wvalid),                      // input   wire
    .axil_wready                        (lat_axil_wready),                      // output  reg
    .axil_bvalid                        (lat_axil_bvalid),                      // output  reg
    .axil_bresp                         (lat_axil_bresp),                       // output  wire    [1:0]
    .axil_bready                        (lat_axil_bready),                      // input

    // Latency monitor ILA signals
    .lat_mon_sent_time_ila              (lat_mon_sent_time_ila),
    .lat_mon_rcvd_time_ila              (lat_mon_rcvd_time_ila),
    .lat_mon_delta_time_ila             (lat_mon_delta_time_ila),
    .lat_mon_send_event_ila             (lat_mon_send_event_ila),
    .lat_mon_rcv_event_ila              (lat_mon_rcv_event_ila),
    .lat_mon_delta_time_idx_ila         (lat_mon_delta_time_idx_ila),

    .lat_sel                            (scratch_0[16]),
    .gtf_ch_txrawdata_sof               (gtf_ch_txrawdata_sof),
    .gtf_ch_rxrawdata_sof               (gtf_ch_rxrawdata_sof),
    //.gtf_ch_rxrawdata_sof               (pattern_rcvd), // gtf_ch_rxrawdata_sof),

    // TX/RX Data Marker Signals...
    .tx_sopin                           (tx_sop),                               // input       wire
    .tx_enain                           (tx_axis_tvalid),                       // input       wire
    .tx_rdyout                          (tx_axis_tready),                       // input       wire
    .tx_can_start                       (tx_axis_tcan_start),                   // input       wire
    .tx_start_measured_run              (tx_start_measured_run),                // output      wire
    .tx_eopin                           (|tx_axis_tlast),                       // input       wire
    .rx_sof                             (|rx_axis_tsof),                        // input       wire
    .rx_start_measured_run              (rx_start_measured_run)                 // input       wire
);

// ##################################################################
//
//   Sync to AXI Clock Domains
//
// ##################################################################

    gtfraw_vnc_syncer_level i_sync_gtfraw_rx_rst (
    
      .clk        (axi_aclk),
      .reset      (axi_aresetn),
    
      .datain     (rx_rst),
      .dataout    (stat_gtf_rx_rst_sync)
    
    );
    
    gtfraw_vnc_syncer_level i_sync_gtfraw_tx_rst (
    
      .clk        (axi_aclk),
      .reset      (axi_aresetn),
    
      .datain     (tx_rst),
      .dataout    (stat_gtf_tx_rst_sync)
    
    );
    
    gtfraw_vnc_syncer_level i_sync_gtfraw_block_lock (
    
      .clk        (axi_aclk),
      .reset      (~axi_aresetn),
    
      .datain     (block_lock),
      .dataout    (stat_gtf_block_lock_sync)
    
    );
    
    gtfraw_vnc_syncer_level i_sync_gtfraw_internal_local_fault (
    
      .clk        (axi_aclk),
      .reset      (axi_aresetn),
    
      .datain     (stat_gtf_rx_internal_local_fault),
      .dataout    (stat_gtf_rx_internal_local_fault_sync)
    
    );
    
    gtfraw_vnc_syncer_level i_sync_gtfraw_local_fault (
    
      .clk        (axi_aclk),
      .reset      (axi_aresetn),
    
      .datain     (stat_gtf_rx_local_fault),
      .dataout    (stat_gtf_rx_local_fault_sync)
    
    );
    
    gtfraw_vnc_syncer_level i_sync_gtfraw_received_local_fault (
    
      .clk        (axi_aclk),
      .reset      (axi_aresetn),
    
      .datain     (stat_gtf_rx_received_local_fault),
      .dataout    (stat_gtf_rx_received_local_fault_sync)
    
    );
    
    gtfraw_vnc_syncer_level i_sync_gtfraw_remote_fault (
    
      .clk        (axi_aclk),
      .reset      (axi_aresetn),
    
      .datain     (stat_gtf_rx_remote_fault),
      .dataout    (stat_gtf_rx_remote_fault_sync)
    
    );




    logic one_second_edge;

    always @ (posedge axi_aclk) begin

        if (one_second_ctr == (ONE_SECOND_COUNT-1)) begin
            one_second_edge <= ~one_second_edge;
            one_second_ctr  <= 28'd0;
        end
        else begin
            one_second_ctr  <= one_second_ctr + 1'b1;
        end

        if (axi_aresetn == 1'b0) begin
            one_second_edge <= 1'b0;
            one_second_ctr  <= 28'd0;
        end

    end


    gtfraw_vnc_clock_count i_clock_count_tx_clk (
        .clk                (tx_clk),
        .one_second_edge    (one_second_edge),
        .clocks_per_second  (tx_clk_cps)
    );

    gtfraw_vnc_clock_count i_clock_count_rx_clk (
        .clk                (rx_clk),
        .one_second_edge    (one_second_edge),
        .clocks_per_second  (rx_clk_cps)
    );

    gtfraw_vnc_clock_count i_clock_count_aclk (
        .clk                (axi_aclk),
        .one_second_edge    (one_second_edge),
        .clocks_per_second  (axi_aclk_cps)
    );

    gtfraw_vnc_clock_count i_clock_count_gen_clk (
        .clk                (gen_clk),
        .one_second_edge    (one_second_edge),
        .clocks_per_second  (gen_clk_cps)
    );

    gtfraw_vnc_clock_count i_clock_count_mon_clk (
        .clk                (mon_clk),
        .one_second_edge    (one_second_edge),
        .clocks_per_second  (mon_clk_cps)
    );

    gtfraw_vnc_clock_count i_clock_count_lat_clk (
        .clk                (lat_clk),
        .one_second_edge    (one_second_edge),
        .clocks_per_second  (lat_clk_cps)
    );

    assign ila_gtf_ch_rxrawdata_sof   = gtf_ch_rxrawdata_sof   ;
    assign ila_gtf_ch_rxrawdata       = gtf_ch_rxrawdata[15:0] ;
    assign ila_gtf_ch_txrawdata_sof   = gtf_ch_txrawdata_sof   ;
    assign ila_gtf_ch_txrawdata       = gtf_ch_txrawdata[15:0] ;

endmodule
