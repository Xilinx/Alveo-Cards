/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------


`timescale 1fs/1fs
`default_nettype none
module gtfwizard_mac_gtfmac_ex # (
    parameter   ONE_SECOND_COUNT   = 28'd200_000_000,
    parameter  integer     NUM_CHANNEL = 1
)
(

    // exdes IOs
    output  wire  [NUM_CHANNEL-1:0]              gtf_ch_gtftxn,
    output  wire  [NUM_CHANNEL-1:0]              gtf_ch_gtftxp,
    input   wire  [NUM_CHANNEL-1:0]              gtf_ch_gtfrxn,
    input   wire  [NUM_CHANNEL-1:0]              gtf_ch_gtfrxp,

    input   wire                refclk_p,
    input   wire                refclk_n,

    input  wire                 hb_gtwiz_reset_clk_freerun_p_in,
    input  wire                 hb_gtwiz_reset_clk_freerun_n_in,
    input   wire                hb_gtwiz_reset_all_in,

    input   wire  [NUM_CHANNEL-1:0]              link_down_latched_reset_in,
    output  wire  [NUM_CHANNEL-1:0]              link_status_out,
    output  wire  [NUM_CHANNEL-1:0]              link_down_latched_out,
    output  wire  [NUM_CHANNEL-1:0]              link_maintained,
    output  wire                clk_wiz_locked_out,

    output wire   [NUM_CHANNEL-1:0]              gtwiz_reset_tx_done_out,
    output wire   [NUM_CHANNEL-1:0]              gtwiz_reset_rx_done_out,
    output wire                                  gtf_cm_qpll0_lock,
 
    output  wire  [NUM_CHANNEL-1:0]              gtf_ch_rxsyncdone,
    output  wire  [NUM_CHANNEL-1:0]              gtf_ch_txsyncdone,
    output  wire  [NUM_CHANNEL-1:0]              rxbuffbypass_complete_flg,

    //
    //  Recov: Clock I/O Mods...
    //
	// Moved JTAG/AXi Bus up hierarchy...
    output wire                      s_axil_aclk                      ,
    output wire                      s_axil_aresetn                   ,
    input  wire [31:0]               s_axil_awaddr                    ,
    input  wire [2:0]                s_axil_awprot                    ,
    input  wire                      s_axil_awvalid                   ,
    output wire                      s_axil_awready                   ,
    input  wire [31:0]               s_axil_wdata                     ,
    input  wire [3:0]                s_axil_wstrb                     ,
    input  wire                      s_axil_wvalid                    ,
    output wire                      s_axil_wready                    ,
    output wire [1:0]                s_axil_bresp                     ,
    output wire                      s_axil_bvalid                    ,
    input  wire                      s_axil_bready                    ,
    input  wire [31:0]               s_axil_araddr                    ,
    input  wire [2:0]                s_axil_arprot                    ,
    input  wire                      s_axil_arvalid                   ,
    output wire                      s_axil_arready                   ,
    output wire [31:0]               s_axil_rdata                     ,
    output wire [1:0]                s_axil_rresp                     ,
    output wire                      s_axil_rvalid                    ,
    input  wire                      s_axil_rready                    ,

	// Single ended SYNCE clock for frequency measurement
    output wire                      SYNCE_CLK_OUT                    ,

	// Port Recov Clock to I/O             
    output wire                      RECOV_CLK10_INT                  ,
    output wire                      RECOV_CLK10_LVDS_P               ,
    output wire                      RECOV_CLK10_LVDS_N               ,
               
	// User signal to reset loopback FIFO...
    input  wire                      fifo_rst                         ,

    // 425 Mhz system clock
    input  wire                      sys_clk_out                      ,

    // 200 Mhz system clock
    input  wire                      freerun_clk                      ,

    input  wire                      ctl_hwchk_frm_gen_en_in          , 
    input  wire                      ctl_hwchk_mon_en_in              

); 

    wire [80*NUM_CHANNEL-1:0]        tx_ptp_tstamp_out;
    wire [80*NUM_CHANNEL-1:0]        rx_ptp_tstamp_out;
    wire [NUM_CHANNEL-1:0]           rx_ptp_tstamp_valid_out;
    wire [NUM_CHANNEL-1:0]           tx_ptp_tstamp_valid_out;

    wire [NUM_CHANNEL-1:0]           tx_axis_clk;
    wire [NUM_CHANNEL-1:0]           tx_axis_rst;

    wire [NUM_CHANNEL-1:0]           rx_axis_clk;
    wire [NUM_CHANNEL-1:0]           rx_axis_rst;

    //Recov: wire                   sys_clk_out;
    wire [NUM_CHANNEL-1:0]           sys_rst;

    wire            lat_clk;
    wire            lat_rstn;

    wire            f_clk;
    wire            f_rst;

    wire [NUM_CHANNEL-1:0]           stat_gtf_rx_internal_local_fault;
    wire [NUM_CHANNEL-1:0]           stat_gtf_rx_local_fault;
    wire [NUM_CHANNEL-1:0]           stat_gtf_rx_received_local_fault;
    wire [NUM_CHANNEL-1:0]           stat_gtf_rx_remote_fault;

    wire [NUM_CHANNEL-1:0]           hwchk_gtf_ch_gttxreset;
    wire [NUM_CHANNEL-1:0]           hwchk_gtf_ch_txpmareset;
    wire [NUM_CHANNEL-1:0]           hwchk_gtf_ch_txpcsreset;
    wire [NUM_CHANNEL-1:0]           hwchk_gtf_ch_gtrxreset;
    wire [NUM_CHANNEL-1:0]           hwchk_gtf_ch_rxpmareset;
    wire [NUM_CHANNEL-1:0]           hwchk_gtf_ch_rxdfelpmreset;
    wire [NUM_CHANNEL-1:0]           hwchk_gtf_ch_eyescanreset;
    wire [NUM_CHANNEL-1:0]           hwchk_gtf_ch_rxpcsreset;
    wire [NUM_CHANNEL-1:0]           hwchk_gtf_cm_qpll0reset;
    wire [NUM_CHANNEL-1:0]           stat_gtf_rx_block_lock;

    wire [NUM_CHANNEL-1:0]           tx_axis_tready;
    wire [NUM_CHANNEL-1:0]           tx_axis_tvalid;
    wire [64*NUM_CHANNEL-1:0]        tx_axis_tdata;
    wire [8*NUM_CHANNEL-1:0]         tx_axis_tlast;
    wire [8*NUM_CHANNEL-1:0]         tx_axis_tpre;
    wire [NUM_CHANNEL-1:0]           tx_axis_terr;
    wire [5*NUM_CHANNEL-1:0]         tx_axis_tterm;
    wire [2*NUM_CHANNEL-1:0]         tx_axis_tsof;
    wire [NUM_CHANNEL-1:0]           tx_axis_tpoison;
    wire [NUM_CHANNEL-1:0]           tx_axis_tcan_start;
    wire [NUM_CHANNEL-1:0]           tx_ptp_sop;
    wire [NUM_CHANNEL-1:0]           tx_ptp_sop_pos;
    wire [NUM_CHANNEL-1:0]           tx_gb_seq_start;
    wire [NUM_CHANNEL-1:0]           tx_unfout;

    wire                             int_tx_axis_tready     [0:NUM_CHANNEL-1];
    wire                             int_tx_axis_tvalid     [0:NUM_CHANNEL-1];
    wire [63:0]                      int_tx_axis_tdata      [0:NUM_CHANNEL-1];
    wire [ 7:0]                      int_tx_axis_tlast      [0:NUM_CHANNEL-1];
    wire [ 7:0]                      int_tx_axis_tpre       [0:NUM_CHANNEL-1];
    wire                             int_tx_axis_terr       [0:NUM_CHANNEL-1];
    wire [ 4:0]                      int_tx_axis_tterm      [0:NUM_CHANNEL-1];
    wire [ 1:0]                      int_tx_axis_tsof       [0:NUM_CHANNEL-1];
    wire                             int_tx_axis_tpoison    [0:NUM_CHANNEL-1];
    wire                             int_tx_axis_tcan_start [0:NUM_CHANNEL-1];
    wire                             int_tx_ptp_sop         [0:NUM_CHANNEL-1];
    wire                             int_tx_ptp_sop_pos     [0:NUM_CHANNEL-1];
    wire                             int_tx_gb_seq_start    [0:NUM_CHANNEL-1];
    wire                             int_tx_unfout          [0:NUM_CHANNEL-1];

    wire [NUM_CHANNEL-1:0]           rx_ptp_sop;
    wire [NUM_CHANNEL-1:0]           rx_ptp_sop_pos;
    wire [NUM_CHANNEL-1:0]           rx_gb_seq_start;
    wire [NUM_CHANNEL-1:0]           rx_axis_tvalid;
    wire [64*NUM_CHANNEL-1:0]        rx_axis_tdata;
    wire [8*NUM_CHANNEL-1:0]         rx_axis_tlast;
    wire [8*NUM_CHANNEL-1:0]         rx_axis_tpre;
    wire [NUM_CHANNEL-1:0]           rx_axis_terr;
    wire [5*NUM_CHANNEL-1:0]         rx_axis_tterm;
    wire [2*NUM_CHANNEL-1:0]         rx_axis_tsof;


    wire                             int_rx_ptp_sop             [0:NUM_CHANNEL-1];
    wire                             int_rx_ptp_sop_pos         [0:NUM_CHANNEL-1];
    wire                             int_rx_gb_seq_start        [0:NUM_CHANNEL-1];
    wire                             int_rx_axis_tvalid         [0:NUM_CHANNEL-1];
    wire [63:0]                      int_rx_axis_tdata          [0:NUM_CHANNEL-1];
    wire [ 7:0]                      int_rx_axis_tlast          [0:NUM_CHANNEL-1];
    wire [ 7:0]                      int_rx_axis_tpre           [0:NUM_CHANNEL-1];
    wire                             int_rx_axis_terr           [0:NUM_CHANNEL-1];
    wire [ 4:0]                      int_rx_axis_tterm          [0:NUM_CHANNEL-1];
    wire [ 1:0]                      int_rx_axis_tsof           [0:NUM_CHANNEL-1];
 
    wire    [31:0]      lat_axil_araddr;
    wire                lat_axil_arvalid;
    wire                lat_axil_arready;
    wire    [31:0]      lat_axil_rdata;
    wire    [1:0]       lat_axil_rresp;
    wire                lat_axil_rvalid;
    wire                lat_axil_rready;
    wire    [31:0]      lat_axil_awaddr;
    wire                lat_axil_awvalid;
    wire                lat_axil_awready;
    wire    [31:0]      lat_axil_wdata;
    wire                lat_axil_wvalid;
    wire                lat_axil_wready;
    wire                lat_axil_bvalid;
    wire    [1:0]       lat_axil_bresp;
    wire                lat_axil_bready;

    wire                                 axi_aclk;
    wire    [NUM_CHANNEL-1:0]            axi_aresetn;

    wire    [31:0]       gtf_axil_araddr [0:3] ;
    wire                 gtf_axil_arvalid[0:3] ;
    wire                 gtf_axil_rready [0:3] ;
    wire    [31:0]       gtf_axil_awaddr [0:3] ;
    wire    [ 2:0]       gtf_axil_awprot [0:3] ;
    wire    [ 2:0]       gtf_axil_arprot [0:3] ;
    wire    [ 3:0]       gtf_axil_wstrb  [0:3] ;
    wire                 gtf_axil_awvalid[0:3] ;
    wire    [31:0]       gtf_axil_wdata  [0:3] ;
    wire                 gtf_axil_wvalid [0:3] ;
    wire                 gtf_axil_bready [0:3] ;
    wire                 gtf_axil_arready[0:3] ; 
    wire    [31:0]       gtf_axil_rdata  [0:3] ;
    wire    [1:0]        gtf_axil_rresp  [0:3] ; 
    wire                 gtf_axil_rvalid [0:3] ;
    wire                 gtf_axil_awready[0:3] ;
    wire                 gtf_axil_wready [0:3] ;
    wire                 gtf_axil_bvalid [0:3] ;
    wire    [1:0]        gtf_axil_bresp  [0:3] ;

    wire    [31:0]       hwchk_axil_araddr  [0:3];
    wire                 hwchk_axil_arvalid [0:3];
    wire                 hwchk_axil_rready  [0:3];
    wire    [31:0]       hwchk_axil_awaddr  [0:3];
    wire    [ 2:0]       hwchk_axil_awprot  [0:3];
    wire    [ 2:0]       hwchk_axil_arprot  [0:3];
    wire    [ 3:0]       hwchk_axil_wstrb   [0:3];
    wire                 hwchk_axil_awvalid [0:3];
    wire    [31:0]       hwchk_axil_wdata   [0:3];
    wire                 hwchk_axil_wvalid  [0:3];
    wire                 hwchk_axil_bready  [0:3];
    wire                 hwchk_axil_arready [0:3]; 
    wire    [31:0]       hwchk_axil_rdata   [0:3];
    wire    [1:0]        hwchk_axil_rresp   [0:3]; 
    wire                 hwchk_axil_rvalid  [0:3];
    wire                 hwchk_axil_awready [0:3];
    wire                 hwchk_axil_wready  [0:3];
    wire                 hwchk_axil_bvalid  [0:3];
    wire    [1:0]        hwchk_axil_bresp   [0:3];


    wire    [31:0]      s_axil_araddr;
    wire                s_axil_arvalid;
    wire                s_axil_rready;
    wire    [31:0]      s_axil_awaddr;
    wire    [2:0]       s_axil_awprot;
    wire    [2:0]       s_axil_arprot;
    wire    [3:0]       s_axil_wstrb;
    wire                s_axil_awvalid;
    wire    [31:0]      s_axil_wdata;
    wire                s_axil_wvalid;
    wire                s_axil_bready;

    wire                s_axil_arready;
    wire    [31:0]      s_axil_rdata;
    wire    [1:0]       s_axil_rresp;
    wire                s_axil_rvalid;
    wire                s_axil_awready;
    wire                s_axil_wready;
    wire                s_axil_bvalid;
    wire    [1:0]       s_axil_bresp;
    
    wire    [NUM_CHANNEL-1:0]            hwchk_rx_custom_preamble_en; 
    wire    [NUM_CHANNEL-1:0]            hwchk_gtf_ch_txuserrdy;
    wire    [NUM_CHANNEL-1:0]            hwchk_gtf_ch_rxuserrdy;
    wire    [NUM_CHANNEL-1:0]            gtwiz_reset_tx_pll_and_datapath_in;
    wire    [NUM_CHANNEL-1:0]            gtwiz_reset_tx_datapath_in;
    wire    [NUM_CHANNEL-1:0]            gtwiz_reset_rx_pll_and_datapath_in;
    wire    [NUM_CHANNEL-1:0]            gtwiz_reset_rx_datapath_in;

    wire    [32*NUM_CHANNEL-1:0]      intc_gtf_axil_araddr  ;
    wire    [NUM_CHANNEL-1:0]         intc_gtf_axil_arvalid ;
    wire    [NUM_CHANNEL-1:0]         intc_gtf_axil_rready  ;
    wire    [32*NUM_CHANNEL-1:0]      intc_gtf_axil_awaddr  ;
    wire    [3*NUM_CHANNEL-1:0]       intc_gtf_axil_awprot  ;
    wire    [3*NUM_CHANNEL-1:0]       intc_gtf_axil_arprot  ;
    wire    [4*NUM_CHANNEL-1:0]       intc_gtf_axil_wstrb   ;
    wire    [NUM_CHANNEL-1:0]         intc_gtf_axil_awvalid ;
    wire    [32*NUM_CHANNEL-1:0]      intc_gtf_axil_wdata   ;
    wire    [NUM_CHANNEL-1:0]         intc_gtf_axil_wvalid  ;
    wire    [NUM_CHANNEL-1:0]         intc_gtf_axil_bready  ;
    wire    [NUM_CHANNEL-1:0]         intc_gtf_axil_arready ; 
    wire    [32*NUM_CHANNEL-1:0]      intc_gtf_axil_rdata   ;
    wire    [2*NUM_CHANNEL-1:0]       intc_gtf_axil_rresp   ; 
    wire    [NUM_CHANNEL-1:0]         intc_gtf_axil_rvalid  ;
    wire    [NUM_CHANNEL-1:0]         intc_gtf_axil_awready ;
    wire    [NUM_CHANNEL-1:0]         intc_gtf_axil_wready  ;
    wire    [NUM_CHANNEL-1:0]         intc_gtf_axil_bvalid  ;
    wire    [2*NUM_CHANNEL-1:0]       intc_gtf_axil_bresp   ;

    wire  [NUM_CHANNEL-1:0]          ctl_gb_seq_sync_fab        ; 
    wire  [NUM_CHANNEL-1:0]          ctl_disable_bitslip_fab    ; 
    wire  [NUM_CHANNEL-1:0]          ctl_correct_bitslip_fab    ; 
    wire  [7*NUM_CHANNEL-1:0]        stat_bitslip_cnt_fab       ; 
    wire  [7*NUM_CHANNEL-1:0]        stat_bitslip_issued_fab    ; 
    wire  [NUM_CHANNEL-1:0]          stat_excessive_bitslip_fab ; 
    wire  [NUM_CHANNEL-1:0]          stat_bitslip_locked_fab    ; 
    wire  [NUM_CHANNEL-1:0]          stat_bitslip_busy_fab      ; 
    wire  [NUM_CHANNEL-1:0]          stat_bitslip_done_fab      ; 

    wire            ctl_gb_seq_sync       [0:NUM_CHANNEL-1] ; 
    wire            ctl_disable_bitslip   [0:NUM_CHANNEL-1] ; 
    wire            ctl_correct_bitslip   [0:NUM_CHANNEL-1] ; 
    wire  [6:0]     stat_bitslip_cnt      [0:NUM_CHANNEL-1] ; 
    wire  [6:0]     stat_bitslip_issued   [0:NUM_CHANNEL-1] ; 
    wire            stat_excessive_bitslip[0:NUM_CHANNEL-1] ; 
    wire            stat_bitslip_locked   [0:NUM_CHANNEL-1] ; 
    wire            stat_bitslip_busy     [0:NUM_CHANNEL-1] ; 
    wire            stat_bitslip_done     [0:NUM_CHANNEL-1] ; 
    wire                   hb_gtwiz_reset_clk_freerun_in;
    //Recov: wire                   freerun_clk;

// adding clocking wiz instancwiz instancee

wire             cw_sys_clk;
wire             hb_gtwiz_reset_clk_freerun_in_itm;
wire             clk_wiz_reset;
assign  clk_wiz_reset =  1'b0;

//
// Recov: Moved the clock generation outside this module...
//
// IBUFDS ibufds_clk_freerun_inst (
//   .I  (hb_gtwiz_reset_clk_freerun_p_in),
//   .IB (hb_gtwiz_reset_clk_freerun_n_in),
//   .O  (hb_gtwiz_reset_clk_freerun_in_itm)
// );
// 
// gtfwizard_0_example_clk_wiz clk_wiz_300_to_161_inst
//    (
//     // Clock out ports
//     .clk_out1       (hb_gtwiz_reset_clk_freerun_in),    // output clk_out_200MHz
//     .clk_out2       (cw_sys_clk),                       // output clk_out_425Mhz
//     // Status and control signals
//     .reset          (clk_wiz_reset), // input reset
//     .locked         (clk_wiz_locked_out),       // output locked
//     // Clock in ports
//     .clk_in1(hb_gtwiz_reset_clk_freerun_in_itm)
//    );    
// 
// 
// BUFG bufg_clk_freerun_inst (
//   .I (hb_gtwiz_reset_clk_freerun_in),
//   .O (freerun_clk)
// );
// 
// BUFG bufg_clk_sys_inst (
//   .I (cw_sys_clk),
//   .O (sys_clk_out)
// );
//
//
////This module converts JTAG interface to AXI-Lite interface
//gtfwizard_0_example_jtag_axi u_jtag_axi_0 (
//  .aclk             (axi_aclk),         // input wire aclk
//  .aresetn          (axi_aresetn[0]),      // input wire aresetn   -- MULTI-BIT need update
//  .m_axi_awaddr     (s_axil_awaddr),    // output wire [31 : 0] m_axi_awaddr
//  .m_axi_awprot     (s_axil_awprot),    // output wire [2 : 0] m_axi_awprot
//  .m_axi_awvalid    (s_axil_awvalid),   // output wire m_axi_awvalid
//  .m_axi_awready    (s_axil_awready),   // input wire m_axi_awready
//  .m_axi_wdata      (s_axil_wdata),     // output wire [31 : 0] m_axi_wdata
//  .m_axi_wstrb      (s_axil_wstrb),     // output wire [3 : 0] m_axi_wstrb
//  .m_axi_wvalid     (s_axil_wvalid),    // output wire m_axi_wvalid
//  .m_axi_wready     (s_axil_wready),    // input wire m_axi_wready
//  .m_axi_bresp      (s_axil_bresp),     // input wire [1 : 0] m_axi_bresp
//  .m_axi_bvalid     (s_axil_bvalid),    // input wire m_axi_bvalid
//  .m_axi_bready     (s_axil_bready),    // output wire m_axi_bready
//  .m_axi_araddr     (s_axil_araddr),    // output wire [31 : 0] m_axi_araddr
//  .m_axi_arprot     (s_axil_arprot),    // output wire [2 : 0] m_axi_arprot
//  .m_axi_arvalid    (s_axil_arvalid),   // output wire m_axi_arvalid
//  .m_axi_arready    (s_axil_arready),   // input wire m_axi_arready
//  .m_axi_rdata      (s_axil_rdata),     // input wire [31 : 0] m_axi_rdata
//  .m_axi_rresp      (s_axil_rresp),     // input wire [1 : 0] m_axi_rresp
//  .m_axi_rvalid     (s_axil_rvalid),    // input wire m_axi_rvalid
//  .m_axi_rready     (s_axil_rready)     // output wire m_axi_rready
//);

// Recov: Pass AXI Clock and reset out of module to JTAG/AXI interconnect
assign s_axil_aclk    = axi_aclk      ;
assign s_axil_aresetn = axi_aresetn[0];


genvar i;
generate for (i=NUM_CHANNEL; i<4; i=i+1) begin : interconnect_tieoffs
    
assign hwchk_axil_arready[i]    =   1'b1;
assign hwchk_axil_rdata[i]      =   32'd0;
assign hwchk_axil_rresp[i]      =   2'd0;
assign hwchk_axil_rvalid[i]     =   1'd1;
assign hwchk_axil_awready[i]    =   1'd1;
assign hwchk_axil_wready[i]     =   1'd1;
assign hwchk_axil_bvalid[i]     =   1'd1;
assign hwchk_axil_bresp[i]      =   2'd0;

assign gtf_axil_arready[i]    =   1'b1;
assign gtf_axil_rdata[i]      =   32'd0;
assign gtf_axil_rresp[i]      =   2'd0;
assign gtf_axil_rvalid[i]     =   1'd0;
assign gtf_axil_awready[i]    =   1'd1;
assign gtf_axil_wready[i]     =   1'd1;
assign gtf_axil_bvalid[i]     =   1'd0;
assign gtf_axil_bresp[i]      =   2'd0;

end
endgenerate

genvar k;
generate for (k=0; k<NUM_CHANNEL; k=k+1) begin : interconnect_signal_assign_gen
    
assign  intc_gtf_axil_araddr[32*(k+1)-1:32*k]        =    gtf_axil_araddr[k]  ;
assign  intc_gtf_axil_arvalid[k]                     =    gtf_axil_arvalid[k] ;
assign  intc_gtf_axil_rready[k]                      =    gtf_axil_rready[k]  ;
assign  intc_gtf_axil_awaddr[32*(k+1)-1:32*k]        =    gtf_axil_awaddr[k]  ;
assign  intc_gtf_axil_awprot[ 3*(k+1)-1: 3*k]        =    gtf_axil_awprot[k]  ;
assign  intc_gtf_axil_arprot[ 3*(k+1)-1: 3*k]        =    gtf_axil_arprot[k]  ;
assign  intc_gtf_axil_wstrb[  4*(k+1)-1: 4*k]        =    gtf_axil_wstrb[k];
assign  intc_gtf_axil_awvalid[k]                     =    gtf_axil_awvalid[k];
assign  intc_gtf_axil_wdata[32*(k+1)-1:32*k]         =    gtf_axil_wdata[k];
assign  intc_gtf_axil_wvalid[k]                      =    gtf_axil_wvalid[k]        ;
assign  intc_gtf_axil_bready[k]                      =    gtf_axil_bready[k]        ; 
assign  gtf_axil_arready[k]                          =    intc_gtf_axil_arready[k]     ; 
assign  gtf_axil_rdata[k]                            =    intc_gtf_axil_rdata[32*(k+1)-1:32*k] ;
assign  gtf_axil_rresp[k]                            =    intc_gtf_axil_rresp[2*(k+1)-1:2*k];
assign  gtf_axil_rvalid[k]                           =    intc_gtf_axil_rvalid[k];
assign  gtf_axil_awready[k]                          =    intc_gtf_axil_awready[k];
assign  gtf_axil_wready[k]                           =    intc_gtf_axil_wready[k];
assign  gtf_axil_bvalid[k]                           =    intc_gtf_axil_bvalid[k];
assign  gtf_axil_bresp[k]                            =    intc_gtf_axil_bresp[2*(k+1)-1:2*k];

//Recov:  Moved to register delay to removed two words from stream...

reg          r_rx_ptp_sop       [0:NUM_CHANNEL-1];
reg          r_rx_ptp_sop_pos   [0:NUM_CHANNEL-1];
reg          r_rx_gb_seq_start  [0:NUM_CHANNEL-1];
reg          r_rx_axis_tvalid   [0:NUM_CHANNEL-1];
reg  [63:0]  r_rx_axis_tdata    [0:NUM_CHANNEL-1];
reg  [ 7:0]  r_rx_axis_tlast    [0:NUM_CHANNEL-1];
reg  [ 7:0]  r_rx_axis_tpre     [0:NUM_CHANNEL-1];
reg          r_rx_axis_terr     [0:NUM_CHANNEL-1];
reg  [ 4:0]  r_rx_axis_tterm    [0:NUM_CHANNEL-1];
reg  [ 1:0]  r_rx_axis_tsof     [0:NUM_CHANNEL-1];

always@(posedge rx_axis_clk[k])
begin
    r_rx_axis_tvalid[k]  <= rx_axis_tvalid[k];
    r_rx_axis_tdata[k]   <= rx_axis_tdata[64*(k+1)-1:64*k];
    r_rx_axis_tlast[k]   <= rx_axis_tlast[8*(k+1)-1:8*k];
    r_rx_axis_tpre[k]    <= rx_axis_tpre[8*(k+1)-1:8*k];    
    r_rx_axis_terr[k]    <= rx_axis_terr[k]; 
    r_rx_axis_tterm[k]   <= rx_axis_tterm[5*(k+1)-1:5*k]; 
    r_rx_axis_tsof[k]    <= rx_axis_tsof[2*(k+1)-1:2*k]; 
    r_rx_ptp_sop[k]      <= rx_ptp_sop[k];
    r_rx_ptp_sop_pos[k]  <= rx_ptp_sop_pos[k];
    r_rx_gb_seq_start[k] <= rx_gb_seq_start[k];
end

//assign int_rx_axis_tvalid[k]  = r_rx_axis_tvalid[k]  ;
assign int_rx_axis_tdata[k]   = r_rx_axis_tdata[k]   ;
assign int_rx_axis_tlast[k]   = r_rx_axis_tlast[k]   ;
assign int_rx_axis_tpre[k]    = r_rx_axis_tpre[k]    ;
assign int_rx_axis_terr[k]    = r_rx_axis_terr[k]    ;
assign int_rx_axis_tterm[k]   = r_rx_axis_tterm[k]   ;
assign int_rx_axis_tsof[k]    = r_rx_axis_tsof[k]    ;
assign int_rx_ptp_sop[k]      = r_rx_ptp_sop[k]      ;
assign int_rx_ptp_sop_pos[k]  = r_rx_ptp_sop_pos[k]  ;
assign int_rx_gb_seq_start[k] = r_rx_gb_seq_start[k] ;

assign int_rx_axis_tvalid[k]  =  ((r_rx_axis_tdata[k][15:0] == 'hdf1c) || 
                                  (r_rx_axis_tdata[k][15:0] == 'h2144) )
                                  ? 'h0 : r_rx_axis_tvalid[k];
                                   

//always@(posedge rx_axis_clk[k])
//begin
//    if ( rx_axis_tvalid[k] && ((rx_axis_tdata[64*(k+1)-1:64*k] == 'hdf1c) || 
//                               (rx_axis_tdata[64*(k+1)-1:64*k] == 'h2144)) )
//        int_rx_axis_tvalid[k]  <= 'h0;
//    else
//        int_rx_axis_tvalid[k]  <= rx_axis_tvalid[k];
//        
//    int_rx_axis_tdata[k]   <= rx_axis_tdata[64*(k+1)-1:64*k];
//    int_rx_axis_tlast[k]   <= rx_axis_tlast[8*(k+1)-1:8*k];
//    int_rx_axis_tpre[k]    <= rx_axis_tpre[8*(k+1)-1:8*k];    
//    int_rx_axis_terr[k]    <= rx_axis_terr[k]; 
//    int_rx_axis_tterm[k]   <= rx_axis_tterm[5*(k+1)-1:5*k]; 
//    int_rx_axis_tsof[k]    <= rx_axis_tsof[2*(k+1)-1:2*k]; 
//    int_rx_ptp_sop[k]      <= rx_ptp_sop[k];
//    int_rx_ptp_sop_pos[k]  <= rx_ptp_sop_pos[k];
//    int_rx_gb_seq_start[k] <= rx_gb_seq_start[k];
//end

assign  int_tx_axis_tready[k]                          =  tx_axis_tready[k]         ;                        
assign  tx_axis_tvalid[k]                              =  int_tx_axis_tvalid[k]     ;   
assign  tx_axis_tdata[64*(k+1)-1:64*k]                 =  int_tx_axis_tdata[k]      ;       
assign  tx_axis_tlast[8*(k+1)-1:8*k]                   =  int_tx_axis_tlast[k]      ;       
assign  tx_axis_tpre[8*(k+1)-1:8*k]                    =  int_tx_axis_tpre[k]       ;   
assign  tx_axis_terr[k]                                =  int_tx_axis_terr[k]       ;   
assign  tx_axis_tterm[5*(k+1)-1:5*k]                   =  int_tx_axis_tterm[k]      ;   
assign  tx_axis_tsof[2*(k+1)-1:2*k]                    =  int_tx_axis_tsof[k]       ;   
assign  tx_axis_tpoison[k]                             =  int_tx_axis_tpoison[k]    ;  
assign  int_tx_axis_tcan_start[k]                      =  tx_axis_tcan_start[k]     ;       
assign  int_tx_ptp_sop[k]                              =  tx_ptp_sop[k]             ;   
assign  int_tx_ptp_sop_pos[k]                          =  tx_ptp_sop_pos[k]         ;   
assign  int_tx_gb_seq_start[k]                         =  tx_gb_seq_start[k]        ;   
assign  int_tx_unfout[k]                               =  tx_unfout[k]              ;


end
endgenerate

  wire       axi_aresetn_ch1;      
  wire       axi_aresetn_ch2;      
  wire       axi_aresetn_ch3;      
  generate if(NUM_CHANNEL > 1) begin: gen_blk_axi_aresetn_channel1
    assign   axi_aresetn_ch1   =  axi_aresetn[1];
  end else begin
    assign   axi_aresetn_ch1   =  1'b0;
  end
  endgenerate

  generate if(NUM_CHANNEL > 2) begin: gen_blk_axi_aresetn_channel2
    assign   axi_aresetn_ch2   =  axi_aresetn[2];
  end else begin
    assign   axi_aresetn_ch2   =  1'b0;
  end
  endgenerate

  generate if(NUM_CHANNEL > 3) begin: gen_blk_axi_aresetn_channel3
    assign   axi_aresetn_ch3   =  axi_aresetn[3];
  end else begin
    assign   axi_aresetn_ch3   =  1'b0;
  end
  endgenerate

    //Interconnect Module:
    //This module receives a single input AXI-Lite s/w programming interface and divides it
    //into 2 separate masters M00 and M01. M00 is used to program internal register space of 
    //this exdes (gtfmac_hwchk_hwchk_pif). M01 is used to program register space of GTF. 

    gtfwizard_mac_example_axil_ctrl i_axil_ctrl (

        .ACLK_0                             (axi_aclk),
        .ARESETN_0                          (axi_aresetn[0]),
        .ARESETN_1                          (axi_aresetn_ch1),
        .ARESETN_2                          (axi_aresetn_ch2),
        .ARESETN_3                          (axi_aresetn_ch3),

        .M00_AXI_0_araddr                   (hwchk_axil_araddr[0]),
        .M00_AXI_0_arprot                   (),
        .M00_AXI_0_arready                  (hwchk_axil_arready[0]),
        .M00_AXI_0_arvalid                  (hwchk_axil_arvalid[0]),
        .M00_AXI_0_awaddr                   (hwchk_axil_awaddr[0]),
        .M00_AXI_0_awprot                   (),
        .M00_AXI_0_awready                  (hwchk_axil_awready[0]),
        .M00_AXI_0_awvalid                  (hwchk_axil_awvalid[0]),
        .M00_AXI_0_bready                   (hwchk_axil_bready[0]),
        .M00_AXI_0_bresp                    (hwchk_axil_bresp[0]),
        .M00_AXI_0_bvalid                   (hwchk_axil_bvalid[0]),
        .M00_AXI_0_rdata                    (hwchk_axil_rdata[0]),
        .M00_AXI_0_rready                   (hwchk_axil_rready[0]),
        .M00_AXI_0_rresp                    (hwchk_axil_rresp[0]),
        .M00_AXI_0_rvalid                   (hwchk_axil_rvalid[0]),
        .M00_AXI_0_wdata                    (hwchk_axil_wdata[0]),
        .M00_AXI_0_wready                   (hwchk_axil_wready[0]),
        .M00_AXI_0_wstrb                    (),
        .M00_AXI_0_wvalid                   (hwchk_axil_wvalid[0]),

        .M01_AXI_0_araddr                   (gtf_axil_araddr[0]),
        .M01_AXI_0_arprot                   (gtf_axil_arprot[0]),
        .M01_AXI_0_arready                  (gtf_axil_arready[0]),
        .M01_AXI_0_arvalid                  (gtf_axil_arvalid[0]),
        .M01_AXI_0_awaddr                   (gtf_axil_awaddr[0]),
        .M01_AXI_0_awprot                   (gtf_axil_awprot[0]),
        .M01_AXI_0_awready                  (gtf_axil_awready[0]),
        .M01_AXI_0_awvalid                  (gtf_axil_awvalid[0]),
        .M01_AXI_0_bready                   (gtf_axil_bready[0]),
        .M01_AXI_0_bresp                    (gtf_axil_bresp[0]),
        .M01_AXI_0_bvalid                   (gtf_axil_bvalid[0]),
        .M01_AXI_0_rdata                    (gtf_axil_rdata[0]),
        .M01_AXI_0_rready                   (gtf_axil_rready[0]),
        .M01_AXI_0_rresp                    (gtf_axil_rresp[0]),
        .M01_AXI_0_rvalid                   (gtf_axil_rvalid[0]),
        .M01_AXI_0_wdata                    (gtf_axil_wdata[0]),
        .M01_AXI_0_wready                   (gtf_axil_wready[0]),
        .M01_AXI_0_wstrb                    (gtf_axil_wstrb[0]),
        .M01_AXI_0_wvalid                   (gtf_axil_wvalid[0]),

        .M02_AXI_0_araddr                   (hwchk_axil_araddr[1]),
        .M02_AXI_0_arprot                   (),
        .M02_AXI_0_arready                  (hwchk_axil_arready[1]),
        .M02_AXI_0_arvalid                  (hwchk_axil_arvalid[1]),
        .M02_AXI_0_awaddr                   (hwchk_axil_awaddr[1]),
        .M02_AXI_0_awprot                   (),
        .M02_AXI_0_awready                  (hwchk_axil_awready[1]),
        .M02_AXI_0_awvalid                  (hwchk_axil_awvalid[1]),
        .M02_AXI_0_bready                   (hwchk_axil_bready[1]),
        .M02_AXI_0_bresp                    (hwchk_axil_bresp[1]),
        .M02_AXI_0_bvalid                   (hwchk_axil_bvalid[1]),
        .M02_AXI_0_rdata                    (hwchk_axil_rdata[1]),
        .M02_AXI_0_rready                   (hwchk_axil_rready[1]),
        .M02_AXI_0_rresp                    (hwchk_axil_rresp[1]),
        .M02_AXI_0_rvalid                   (hwchk_axil_rvalid[1]),
        .M02_AXI_0_wdata                    (hwchk_axil_wdata[1]),
        .M02_AXI_0_wready                   (hwchk_axil_wready[1]),
        .M02_AXI_0_wstrb                    (),
        .M02_AXI_0_wvalid                   (hwchk_axil_wvalid[1]),

        .M03_AXI_0_araddr                   (gtf_axil_araddr[1]),
        .M03_AXI_0_arprot                   (gtf_axil_arprot[1]),
        .M03_AXI_0_arready                  (gtf_axil_arready[1]),
        .M03_AXI_0_arvalid                  (gtf_axil_arvalid[1]),
        .M03_AXI_0_awaddr                   (gtf_axil_awaddr[1]),
        .M03_AXI_0_awprot                   (gtf_axil_awprot[1]),
        .M03_AXI_0_awready                  (gtf_axil_awready[1]),
        .M03_AXI_0_awvalid                  (gtf_axil_awvalid[1]),
        .M03_AXI_0_bready                   (gtf_axil_bready[1]),
        .M03_AXI_0_bresp                    (gtf_axil_bresp[1]),
        .M03_AXI_0_bvalid                   (gtf_axil_bvalid[1]),
        .M03_AXI_0_rdata                    (gtf_axil_rdata[1]),
        .M03_AXI_0_rready                   (gtf_axil_rready[1]),
        .M03_AXI_0_rresp                    (gtf_axil_rresp[1]),
        .M03_AXI_0_rvalid                   (gtf_axil_rvalid[1]),
        .M03_AXI_0_wdata                    (gtf_axil_wdata[1]),
        .M03_AXI_0_wready                   (gtf_axil_wready[1]),
        .M03_AXI_0_wstrb                    (gtf_axil_wstrb[1]),
        .M03_AXI_0_wvalid                   (gtf_axil_wvalid[1]),

        .M04_AXI_0_araddr                   (hwchk_axil_araddr[2]),
        .M04_AXI_0_arprot                   (),
        .M04_AXI_0_arready                  (hwchk_axil_arready[2]),
        .M04_AXI_0_arvalid                  (hwchk_axil_arvalid[2]),
        .M04_AXI_0_awaddr                   (hwchk_axil_awaddr[2]),
        .M04_AXI_0_awprot                   (),
        .M04_AXI_0_awready                  (hwchk_axil_awready[2]),
        .M04_AXI_0_awvalid                  (hwchk_axil_awvalid[2]),
        .M04_AXI_0_bready                   (hwchk_axil_bready[2]),
        .M04_AXI_0_bresp                    (hwchk_axil_bresp[2]),
        .M04_AXI_0_bvalid                   (hwchk_axil_bvalid[2]),
        .M04_AXI_0_rdata                    (hwchk_axil_rdata[2]),
        .M04_AXI_0_rready                   (hwchk_axil_rready[2]),
        .M04_AXI_0_rresp                    (hwchk_axil_rresp[2]),
        .M04_AXI_0_rvalid                   (hwchk_axil_rvalid[2]),
        .M04_AXI_0_wdata                    (hwchk_axil_wdata[2]),
        .M04_AXI_0_wready                   (hwchk_axil_wready[2]),
        .M04_AXI_0_wstrb                    (),
        .M04_AXI_0_wvalid                   (hwchk_axil_wvalid[2]),

        .M05_AXI_0_araddr                   (gtf_axil_araddr[2]),
        .M05_AXI_0_arprot                   (gtf_axil_arprot[2]),
        .M05_AXI_0_arready                  (gtf_axil_arready[2]),
        .M05_AXI_0_arvalid                  (gtf_axil_arvalid[2]),
        .M05_AXI_0_awaddr                   (gtf_axil_awaddr[2]),
        .M05_AXI_0_awprot                   (gtf_axil_awprot[2]),
        .M05_AXI_0_awready                  (gtf_axil_awready[2]),
        .M05_AXI_0_awvalid                  (gtf_axil_awvalid[2]),
        .M05_AXI_0_bready                   (gtf_axil_bready[2]),
        .M05_AXI_0_bresp                    (gtf_axil_bresp[2]),
        .M05_AXI_0_bvalid                   (gtf_axil_bvalid[2]),
        .M05_AXI_0_rdata                    (gtf_axil_rdata[2]),
        .M05_AXI_0_rready                   (gtf_axil_rready[2]),
        .M05_AXI_0_rresp                    (gtf_axil_rresp[2]),
        .M05_AXI_0_rvalid                   (gtf_axil_rvalid[2]),
        .M05_AXI_0_wdata                    (gtf_axil_wdata[2]),
        .M05_AXI_0_wready                   (gtf_axil_wready[2]),
        .M05_AXI_0_wstrb                    (gtf_axil_wstrb[2]),
        .M05_AXI_0_wvalid                   (gtf_axil_wvalid[2]),

        .M06_AXI_0_araddr                   (hwchk_axil_araddr[3]),
        .M06_AXI_0_arprot                   (),
        .M06_AXI_0_arready                  (hwchk_axil_arready[3]),
        .M06_AXI_0_arvalid                  (hwchk_axil_arvalid[3]),
        .M06_AXI_0_awaddr                   (hwchk_axil_awaddr[3]),
        .M06_AXI_0_awprot                   (),
        .M06_AXI_0_awready                  (hwchk_axil_awready[3]),
        .M06_AXI_0_awvalid                  (hwchk_axil_awvalid[3]),
        .M06_AXI_0_bready                   (hwchk_axil_bready[3]),
        .M06_AXI_0_bresp                    (hwchk_axil_bresp[3]),
        .M06_AXI_0_bvalid                   (hwchk_axil_bvalid[3]),
        .M06_AXI_0_rdata                    (hwchk_axil_rdata[3]),
        .M06_AXI_0_rready                   (hwchk_axil_rready[3]),
        .M06_AXI_0_rresp                    (hwchk_axil_rresp[3]),
        .M06_AXI_0_rvalid                   (hwchk_axil_rvalid[3]),
        .M06_AXI_0_wdata                    (hwchk_axil_wdata[3]),
        .M06_AXI_0_wready                   (hwchk_axil_wready[3]),
        .M06_AXI_0_wstrb                    (),
        .M06_AXI_0_wvalid                   (hwchk_axil_wvalid[3]),

        .M07_AXI_0_araddr                   (gtf_axil_araddr[3]),
        .M07_AXI_0_arprot                   (gtf_axil_arprot[3]),
        .M07_AXI_0_arready                  (gtf_axil_arready[3]),
        .M07_AXI_0_arvalid                  (gtf_axil_arvalid[3]),
        .M07_AXI_0_awaddr                   (gtf_axil_awaddr[3]),
        .M07_AXI_0_awprot                   (gtf_axil_awprot[3]),
        .M07_AXI_0_awready                  (gtf_axil_awready[3]),
        .M07_AXI_0_awvalid                  (gtf_axil_awvalid[3]),
        .M07_AXI_0_bready                   (gtf_axil_bready[3]),
        .M07_AXI_0_bresp                    (gtf_axil_bresp[3]),
        .M07_AXI_0_bvalid                   (gtf_axil_bvalid[3]),
        .M07_AXI_0_rdata                    (gtf_axil_rdata[3]),
        .M07_AXI_0_rready                   (gtf_axil_rready[3]),
        .M07_AXI_0_rresp                    (gtf_axil_rresp[3]),
        .M07_AXI_0_rvalid                   (gtf_axil_rvalid[3]),
        .M07_AXI_0_wdata                    (gtf_axil_wdata[3]),
        .M07_AXI_0_wready                   (gtf_axil_wready[3]),
        .M07_AXI_0_wstrb                    (gtf_axil_wstrb[3]),
        .M07_AXI_0_wvalid                   (gtf_axil_wvalid[3]),

        .S00_AXI_0_araddr                   (s_axil_araddr),
        .S00_AXI_0_arprot                   (s_axil_arprot),
        .S00_AXI_0_arready                  (s_axil_arready),
        .S00_AXI_0_arvalid                  (s_axil_arvalid),
        .S00_AXI_0_awaddr                   (s_axil_awaddr),
        .S00_AXI_0_awprot                   (s_axil_awprot),
        .S00_AXI_0_awready                  (s_axil_awready),
        .S00_AXI_0_awvalid                  (s_axil_awvalid),
        .S00_AXI_0_bready                   (s_axil_bready),
        .S00_AXI_0_bresp                    (s_axil_bresp),
        .S00_AXI_0_bvalid                   (s_axil_bvalid),
        .S00_AXI_0_rdata                    (s_axil_rdata),
        .S00_AXI_0_rready                   (s_axil_rready),
        .S00_AXI_0_rresp                    (s_axil_rresp),
        .S00_AXI_0_rvalid                   (s_axil_rvalid),
        .S00_AXI_0_wdata                    (s_axil_wdata),
        .S00_AXI_0_wready                   (s_axil_wready),
        .S00_AXI_0_wstrb                    (s_axil_wstrb),
        .S00_AXI_0_wvalid                   (s_axil_wvalid)

    );


    assign lat_clk  = rx_axis_clk;
    assign lat_rstn = ~rx_axis_rst;

    // GTF (MAC mode) fabric wrapper design
    gtfwizard_mac_fab_wrap # (
        .NUM_CHANNEL        (NUM_CHANNEL)
    ) 
    i_gtfmac (
		//Recov: Port Clocks to I/O        
        .SYNCE_CLK_OUT                      ( SYNCE_CLK_OUT      ),
        .RECOV_CLK10_INT                    ( RECOV_CLK10_INT    ),
        .RECOV_CLK10_LVDS_P                 ( RECOV_CLK10_LVDS_P ),
        .RECOV_CLK10_LVDS_N                 ( RECOV_CLK10_LVDS_N ),

        // Control plane
        .aclk                               (axi_aclk),
        .aresetn                            (axi_aresetn),

        .s_axi_awaddr                       (intc_gtf_axil_awaddr),   // input     wire [31 : 0]
        .s_axi_awprot                       (intc_gtf_axil_awprot),                  // output    wire [2 : 0]
        .s_axi_awvalid                      (intc_gtf_axil_awvalid),                 // input     wire
        .s_axi_awready                      (intc_gtf_axil_awready),                 // output    wire
        .s_axi_wdata                        (intc_gtf_axil_wdata),                   // input     wire [31 : 0]
        .s_axi_wstrb                        (intc_gtf_axil_wstrb),                   // output    wire [3 : 0]
        .s_axi_wvalid                       (intc_gtf_axil_wvalid),                  // input     wire
        .s_axi_wready                       (intc_gtf_axil_wready),                  // output    wire
        .s_axi_bresp                        (intc_gtf_axil_bresp),                   // output    wire [1 : 0]
        .s_axi_bvalid                       (intc_gtf_axil_bvalid),                  // output    wire
        .s_axi_bready                       (intc_gtf_axil_bready),                  // input     wire
        .s_axi_araddr                       (intc_gtf_axil_araddr),   // input     wire [31 : 0]
        .s_axi_arprot                       (intc_gtf_axil_arprot),                  // output    wire [2 : 0]
        .s_axi_arvalid                      (intc_gtf_axil_arvalid),                 // input     wire
        .s_axi_arready                      (intc_gtf_axil_arready),                 // output    wire
        .s_axi_rdata                        (intc_gtf_axil_rdata),                   // output    wire [31 : 0]
        .s_axi_rresp                        (intc_gtf_axil_rresp),                   // output    wire [1 : 0]
        .s_axi_rvalid                       (intc_gtf_axil_rvalid),                  // output    wire
        .s_axi_rready                       (intc_gtf_axil_rready),                  // input     wire

        // original exdes IOs
        .gtf_ch_gtftxn                      (gtf_ch_gtftxn),                    // output
        .gtf_ch_gtftxp                      (gtf_ch_gtftxp),                    // output
        .gtf_ch_gtfrxn                      (gtf_ch_gtfrxn),                    // input
        .gtf_ch_gtfrxp                      (gtf_ch_gtfrxp),                    // input

        .refclk_p                           (refclk_p),                         // input
        .refclk_n                           (refclk_n),                         // input
        .freerun_clk                        (freerun_clk),
        .hb_gtwiz_reset_all_in              (hb_gtwiz_reset_all_in),            // input

        .gtwiz_reset_tx_done_out            (gtwiz_reset_tx_done_out),          //output
        .gtwiz_reset_rx_done_out            (gtwiz_reset_rx_done_out),          //output
        .gtf_cm_qpll0_lock                  (gtf_cm_qpll0_lock),                //output

        .link_down_latched_reset_in         (link_down_latched_reset_in),       // input
        .link_status_out                    (link_status_out),                  // output reg
        .link_down_latched_out              (link_down_latched_out),            // output reg
        .link_maintained                    (link_maintained),                  // output wire

        .gtf_ch_rxsyncdone                  (gtf_ch_rxsyncdone),                // output  wire
        .gtf_ch_txsyncdone                  (gtf_ch_txsyncdone),                // output  wire
        .wa_complete_flg                    (rxbuffbypass_complete_flg),        // output  wire

        // generated clocks and resets from exdes
        .tx_axis_clk                        (tx_axis_clk),
        .tx_axis_rst                        (tx_axis_rst),

        .rx_axis_clk                        (rx_axis_clk),
        .rx_axis_rst                        (rx_axis_rst),

        .sys_clk_out                        (sys_clk_out),
        .sys_rst_out                        (sys_rst),

        .hb_gtf_ch_txdp_reset_in            ({NUM_CHANNEL{1'b0}}),
        .hb_gtf_ch_rxdp_reset_in            ({NUM_CHANNEL{1'b0}}),

        .gtf_ch_rxptpsop                    (rx_ptp_sop),                       // output  wire
        .gtf_ch_rxptpsoppos                 (rx_ptp_sop_pos),                   // output  wire
        .gtf_ch_rxgbseqstart                (rx_gb_seq_start),

        // hwchk IOs

        .hwchk_gtf_ch_gttxreset               (hwchk_gtf_ch_gttxreset),             // input 
        .hwchk_gtf_ch_txpmareset              (hwchk_gtf_ch_txpmareset),           // input 
        .hwchk_gtf_ch_txpcsreset              (hwchk_gtf_ch_txpcsreset),            // input
        .hwchk_gtf_ch_gtrxreset               (hwchk_gtf_ch_gtrxreset),             // input 
        .hwchk_gtf_ch_rxpmareset              (hwchk_gtf_ch_rxpmareset),            // input 
        .hwchk_gtf_ch_rxdfelpmreset           (hwchk_gtf_ch_rxdfelpmreset),         // input
        .hwchk_gtf_ch_eyescanreset            (hwchk_gtf_ch_eyescanreset),          // input
        .hwchk_gtf_ch_rxpcsreset              (hwchk_gtf_ch_rxpcsreset),            // input
        .hwchk_gtf_cm_qpll0reset              (hwchk_gtf_cm_qpll0reset),            // input

        .hwchk_gtf_ch_txuserrdy               (hwchk_gtf_ch_txuserrdy),
        .hwchk_gtf_ch_rxuserrdy               (hwchk_gtf_ch_rxuserrdy),

        .gtwiz_reset_tx_pll_and_datapath_in (gtwiz_reset_tx_pll_and_datapath_in),
        .gtwiz_reset_tx_datapath_in         (gtwiz_reset_tx_datapath_in),
        .gtwiz_reset_rx_pll_and_datapath_in (gtwiz_reset_rx_pll_and_datapath_in),
        .gtwiz_reset_rx_datapath_in         (gtwiz_reset_rx_datapath_in),

        .gtf_ch_statrxinternallocalfault    (stat_gtf_rx_internal_local_fault),
        .gtf_ch_statrxlocalfault            (stat_gtf_rx_local_fault),
        .gtf_ch_statrxreceivedlocalfault    (stat_gtf_rx_received_local_fault),
        .gtf_ch_statrxremotefault           (stat_gtf_rx_remote_fault),
        .gtf_ch_statrxblocklock             (stat_gtf_rx_block_lock),           // output  wire

        .gtf_ch_txaxistready                (tx_axis_tready),                   // output  wire   NUM_CHANNEL
        .gtf_ch_txaxistvalid                (tx_axis_tvalid),                   // input   wire
        .gtf_ch_txaxistdata                 (tx_axis_tdata),                    // input   wire [63:0]
        .gtf_ch_txaxistlast                 (tx_axis_tlast),                    // input   wire [7:0]
        .gtf_ch_txaxistpre                  (tx_axis_tpre),                     // input   wire [7:0]
        .gtf_ch_txaxisterr                  (tx_axis_terr),                     // input   wire
        .gtf_ch_txaxistterm                 (tx_axis_tterm),                    // input   wire [4:0]
        .gtf_ch_txaxistsof                  (tx_axis_tsof),                     // input   wire [1:0]
        .gtf_ch_txaxistpoison               (tx_axis_tpoison),                  // input   wire
        .gtf_ch_txaxistcanstart             (tx_axis_tcan_start),               // output  wire
        .gtf_ch_txptpsop                    (tx_ptp_sop),                       // output  wire
        .gtf_ch_txptpsoppos                 (tx_ptp_sop_pos),                   // output  wire
        .gtf_ch_txgbseqstart                (tx_gb_seq_start),                  // output  wire
        .gtf_ch_txunfout                    (tx_unfout),                        // output  wire
        .tx_ptp_tstamp_out                  (tx_ptp_tstamp_out      ), 
        .rx_ptp_tstamp_out                  (rx_ptp_tstamp_out      ),
        .rx_ptp_tstamp_valid_out            (rx_ptp_tstamp_valid_out),
        .tx_ptp_tstamp_valid_out            (tx_ptp_tstamp_valid_out),

        .ctl_gb_seq_sync                    (ctl_gb_seq_sync_fab       ),     
        .ctl_disable_bitslip                (ctl_disable_bitslip_fab   ),
        .ctl_correct_bitslip                (ctl_correct_bitslip_fab   ),
        .stat_bitslip_cnt                   (stat_bitslip_cnt_fab      ),
        .stat_bitslip_issued                (stat_bitslip_issued_fab   ),
        .stat_excessive_bitslip             (stat_excessive_bitslip_fab),
        .stat_bitslip_locked                (stat_bitslip_locked_fab   ),
        .stat_bitslip_busy                  (stat_bitslip_busy_fab     ),
        .stat_bitslip_done                  (stat_bitslip_done_fab     ),

        .gtf_ch_rxaxistvalid                (rx_axis_tvalid),                   // output  wire
        .gtf_ch_rxaxistdata                 (rx_axis_tdata),                    // output  wire [63:0]
        .gtf_ch_rxaxistlast                 (rx_axis_tlast),                    // output  wire [7:0]
        .gtf_ch_rxaxistpre                  (rx_axis_tpre),                     // output  wire [7:0]
        .gtf_ch_rxaxisterr                  (rx_axis_terr),                     // output  wire
        .gtf_ch_rxaxistterm                 (rx_axis_tterm),                    // output  wire [4:0]
        .gtf_ch_rxaxistsof                  (rx_axis_tsof)                      // output  wire [1:0]
        //.hwchk_rx_custom_preamble_en_in       (hwchk_rx_custom_preamble_en)
    );

    //Key sub-modules of "gtfmac_hwchk_core" are TX_GEN and RX_MON modules which help in 
    //driving test data to GTF and monitor the data from GTF respectively
    //This module helps in checking/debugging the GTF hardware (hw).
genvar I;
generate for (I=0; I<NUM_CHANNEL; I=I+1) begin : gtfmac_hwchk_core_gen

    assign            ctl_gb_seq_sync_fab[I]       =   ctl_gb_seq_sync[I]; 
    assign            ctl_disable_bitslip_fab[I]   =   ctl_disable_bitslip[I]; 
    assign            ctl_correct_bitslip_fab[I]   =   ctl_correct_bitslip[I]; 
    assign            stat_bitslip_cnt[I]          =   stat_bitslip_cnt_fab[7*(I+1)-1:7*I]; 
    assign            stat_bitslip_issued[I]       =   stat_bitslip_issued_fab[7*(I+1)-1:7*I]; 
    assign            stat_excessive_bitslip[I]    =   stat_excessive_bitslip_fab; 
    assign            stat_bitslip_locked[I]       =   stat_bitslip_locked_fab   ; 
    assign            stat_bitslip_busy[I]         =   stat_bitslip_busy_fab     ; 
    assign            stat_bitslip_done[I]         =   stat_bitslip_done_fab     ; 

    gtfwizard_mac_gtfmac_hwchk_core # (
        .ONE_SECOND_COUNT   (ONE_SECOND_COUNT)
    )
    i_gtfmac_hwchk_core (
		//Recov: System controls to reset loopback FIFO
        .fifo_rst                           ( fifo_rst ),
        .freerun_clk                        ( freerun_clk ),
        .ctl_hwchk_frm_gen_en_in            ( ctl_hwchk_frm_gen_en_in ),
        .ctl_hwchk_mon_en_in                ( ctl_hwchk_mon_en_in ),

        .axi_aclk                           (axi_aclk),                         // input
        .axi_aresetn                        (axi_aresetn[I]),                      // input

        .hwchk_axil_araddr                    (hwchk_axil_araddr[I]),                  // input   wire    [31:0]
        .hwchk_axil_arvalid                   (hwchk_axil_arvalid[I]),                 // input   wire
        .hwchk_axil_arready                   (hwchk_axil_arready[I]),                 // output  reg
        .hwchk_axil_rdata                     (hwchk_axil_rdata[I]),                   // output  reg     [31:0]
        .hwchk_axil_rresp                     (hwchk_axil_rresp[I]),                   // output  wire    [1:0]
        .hwchk_axil_rvalid                    (hwchk_axil_rvalid[I]),                  // output  reg
        .hwchk_axil_rready                    (hwchk_axil_rready[I]),                  // input
        .hwchk_axil_awaddr                    (hwchk_axil_awaddr[I]),                  // input   wire    [31:0]
        .hwchk_axil_awvalid                   (hwchk_axil_awvalid[I]),                 // input   wire
        .hwchk_axil_awready                   (hwchk_axil_awready[I]),                 // output  reg
        .hwchk_axil_wdata                     (hwchk_axil_wdata[I]),                   // input   wire    [31:0]
        .hwchk_axil_wvalid                    (hwchk_axil_wvalid[I]),                  // input   wire
        .hwchk_axil_wready                    (hwchk_axil_wready[I]),                  // output  reg
        .hwchk_axil_bvalid                    (hwchk_axil_bvalid[I]),                  // output  reg
        .hwchk_axil_bresp                     (hwchk_axil_bresp[I]),                   // output  wire    [1:0]
        .hwchk_axil_bready                    (hwchk_axil_bready[I]),                  // input

        .gen_clk                            (sys_clk_out),                          // input       wire
        .gen_rst                            (sys_rst[I]),                       // input       wire

        .mon_clk                            (sys_clk_out),                          // input       wire
        .mon_rst                            (sys_rst[I]),                       // input       wire

        .lat_clk                            (lat_clk),                          // input       wire
        .lat_rstn                           (lat_rstn),                         // input       wire

        .tx_clk                             (tx_axis_clk[I]),                      // input       wire
        .tx_rst                             (tx_axis_rst[I]),                      // input       wire

        .tx_axis_tready                     (int_tx_axis_tready[I]),                   // input       wire
        .tx_axis_tvalid                     (int_tx_axis_tvalid[I]),                   // output      wire
        .tx_axis_tdata                      (int_tx_axis_tdata[I]),                    // output      wire [63:0]
        .tx_axis_tlast                      (int_tx_axis_tlast[I]),                    // output      wire [7:0]
        .tx_axis_tpre                       (int_tx_axis_tpre[I]),                     // output      wire [7:0]
        .tx_axis_terr                       (int_tx_axis_terr[I]),                     // output      wire
        .tx_axis_tterm                      (int_tx_axis_tterm[I]),                    // output      wire [4:0]
        .tx_axis_tsof                       (int_tx_axis_tsof[I]),                     // output      wire [1:0]
        .tx_axis_tpoison                    (int_tx_axis_tpoison[I]),                  // output      wire
        .tx_axis_tcan_start                 (int_tx_axis_tcan_start[I]),               // input       wire
        .tx_ptp_sop                         (int_tx_ptp_sop[I]),                       // input       wire
        .tx_ptp_sop_pos                     (int_tx_ptp_sop_pos[I]),                   // input       wire
        .tx_gb_seq_start                    (int_tx_gb_seq_start[I]),                  // input       wire
        .tx_unfout                          (int_tx_unfout[I]),                        // input       wire

        .rx_clk                             (rx_axis_clk[I]),                      // input       wire
        .rx_rst                             (rx_axis_rst[I]),                      // input       wire

        .rx_ptp_sop                         (int_rx_ptp_sop[I]),                       // input       wire
        .rx_ptp_sop_pos                     (int_rx_ptp_sop_pos[I]),                   // input       wire
        .rx_gb_seq_start                    (int_rx_gb_seq_start[I]), 
        .rx_axis_tvalid                     (int_rx_axis_tvalid[I]),                   // input       wire
        .rx_axis_tdata                      (int_rx_axis_tdata[I]),                    // input       wire [63:0]
        .rx_axis_tlast                      (int_rx_axis_tlast[I]),                    // input       wire [7:0]
        .rx_axis_tpre                       (int_rx_axis_tpre[I]),                     // input       wire [7:0]
        .rx_axis_terr                       (int_rx_axis_terr[I]),                     // input       wire
        .rx_axis_tterm                      (int_rx_axis_tterm[I]),                    // input       wire [4:0]
        .rx_axis_tsof                       (int_rx_axis_tsof[I]),                     // input       wire [1:0]
        .ctl_gb_seq_sync                    (ctl_gb_seq_sync[I]       ),     
        .ctl_disable_bitslip                (ctl_disable_bitslip[I]   ),
        .ctl_correct_bitslip                (ctl_correct_bitslip[I]   ),
        .stat_bitslip_cnt                   (stat_bitslip_cnt[I]      ),
        .stat_bitslip_issued                (stat_bitslip_issued[I]   ),
        .stat_excessive_bitslip             (stat_excessive_bitslip[I]),
        .stat_bitslip_locked                (stat_bitslip_locked[I]   ),
        .stat_bitslip_busy                  (stat_bitslip_busy[I]     ),
        .stat_bitslip_done                  (stat_bitslip_done[I]     ),

        .hwchk_gtf_ch_gttxreset               (hwchk_gtf_ch_gttxreset[I]),             // output
        .hwchk_gtf_ch_txpmareset              (hwchk_gtf_ch_txpmareset[I]),            // output
        .hwchk_gtf_ch_txpcsreset              (hwchk_gtf_ch_txpcsreset[I]),            // output
        .hwchk_gtf_ch_gtrxreset               (hwchk_gtf_ch_gtrxreset[I]),             // output
        .hwchk_gtf_ch_rxpmareset              (hwchk_gtf_ch_rxpmareset[I]),            // output
        .hwchk_gtf_ch_rxdfelpmreset           (hwchk_gtf_ch_rxdfelpmreset[I]),         // output
        .hwchk_gtf_ch_eyescanreset            (hwchk_gtf_ch_eyescanreset[I]),          // output
        .hwchk_gtf_ch_rxpcsreset              (hwchk_gtf_ch_rxpcsreset[I]),            // output
        .hwchk_gtf_cm_qpll0reset              (hwchk_gtf_cm_qpll0reset[I]),            // output

        .hwchk_gtf_ch_txuserrdy               (hwchk_gtf_ch_txuserrdy[I]),
        .hwchk_gtf_ch_rxuserrdy               (hwchk_gtf_ch_rxuserrdy[I]),

        .gtwiz_reset_tx_pll_and_datapath_in (gtwiz_reset_tx_pll_and_datapath_in[I]),
        .gtwiz_reset_tx_datapath_in         (gtwiz_reset_tx_datapath_in[I]),
        .gtwiz_reset_rx_pll_and_datapath_in (gtwiz_reset_rx_pll_and_datapath_in[I]),
        .gtwiz_reset_rx_datapath_in         (gtwiz_reset_rx_datapath_in[I]),
        .block_lock                         (stat_gtf_rx_block_lock[I]),           // input   logic
        .hwchk_rx_custom_preamble_en        (hwchk_rx_custom_preamble_en[I])         //output wire

    );
end
endgenerate

endmodule
`default_nettype wire

