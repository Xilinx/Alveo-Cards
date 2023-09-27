/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------


`timescale 1fs/1fs
module gtfwizard_0_example_top (
  output        gtf_ch_gtftxn,
  output        gtf_ch_gtftxp,
  input         gtf_ch_gtfrxn,
  input         gtf_ch_gtfrxp,
  input  refclk_p,
  input  refclk_n,
//  input  hb_gtwiz_reset_clk_freerun_p_in,
//  input  hb_gtwiz_reset_clk_freerun_n_in,
  input  hb_gtwiz_reset_all_in,
  // PRBS-based link status ports
  input  link_down_latched_reset_in,
  output reg link_status_out,
  output reg link_down_latched_out = 1'b1,
  output link_maintained,
  output wire gtf_ch_rxsyncdone,
  output wire gtf_ch_txsyncdone,
  output wire wa_complete_flg,
  output wire pass,
  output wire state_check,

  // VNC
  
  output    wire        tx_axis_clk,
  output    wire        tx_axis_rst,
                        
  output    wire        rx_axis_clk,
  output    wire        rx_axis_rst,

  output    wire        lat_clk_out,
  output    wire        lat_rstn_out,

  output    wire        sys_clk_out,
  output    wire        sys_rst_out,

  output    wire        aclk,
  output    wire        aresetn,

  input     wire [31 : 0]   s_axi_awaddr,
  output    wire [2 : 0]    s_axi_awprot,
  input     wire            s_axi_awvalid,
  output    wire            s_axi_awready,
  input     wire [31 : 0]   s_axi_wdata,
  output    wire [3 : 0]    s_axi_wstrb,
  input     wire            s_axi_wvalid,
  output    wire            s_axi_wready,
  output    wire [1 : 0]    s_axi_bresp,
  output    wire            s_axi_bvalid,
  input     wire            s_axi_bready,
  input     wire [31 : 0]   s_axi_araddr,
  output    wire [2 : 0]    s_axi_arprot,
  input     wire            s_axi_arvalid,
  output    wire            s_axi_arready,
  output    wire [31 : 0]   s_axi_rdata,
  output    wire [1 : 0]    s_axi_rresp,
  output    wire            s_axi_rvalid,
  input     wire            s_axi_rready,

  input     wire        vnc_gtf_ch_gttxreset,
  input     wire        vnc_gtf_ch_txpmareset,
  input     wire        vnc_gtf_ch_txpcsreset,
  input     wire        vnc_gtf_ch_gtrxreset,
  input     wire        vnc_gtf_ch_rxpmareset,
  input     wire        vnc_gtf_ch_rxdfelpmreset,
  input     wire        vnc_gtf_ch_eyescanreset,
  input     wire        vnc_gtf_ch_rxpcsreset,
  input     wire        vnc_gtf_cm_qpll0reset,

  input     wire        vnc_gtf_ch_txuserrdy,
  input     wire        vnc_gtf_ch_rxuserrdy,

  input     wire        gtwiz_reset_tx_pll_and_datapath_in,
  input     wire        gtwiz_reset_tx_datapath_in,
  input     wire        gtwiz_reset_rx_pll_and_datapath_in,
  input     wire        gtwiz_reset_rx_datapath_in,

  output    wire        gtf_ch_statrxinternallocalfault,
  output    wire        gtf_ch_statrxlocalfault,
  output    wire        gtf_ch_statrxreceivedlocalfault,
  output    wire        gtf_ch_statrxremotefault,
                        
  output  wire          gtf_ch_statrxblocklock,
  output  wire          gtf_ch_rxbitslip,
  input   wire          gtf_ch_pcsrsvdin_0, // rx_gb_seq_sync
  input   wire          gtf_ch_pcsrsvdin_1, // rx_disable_bitslip
  input   wire          gtf_ch_rxslippma,
  output  wire          gtf_ch_rxslippmardy,
  input   wire          gtf_ch_gtrsvd_8,    // rx_slip_one_ui
                              
  output  wire          gtf_ch_txaxistready,
  input   wire          gtf_ch_txaxistvalid,
  input   wire [63:0]   gtf_ch_txaxistdata,
  input   wire [7:0]    gtf_ch_txaxistlast,
  input   wire [7:0]    gtf_ch_txaxistpre,
  input   wire          gtf_ch_txaxisterr,
  input   wire [4:0]    gtf_ch_txaxistterm,
  input   wire [1:0]    gtf_ch_txaxistsof,
  input   wire          gtf_ch_txaxistpoison,
  output  wire          gtf_ch_pcsrsvdout_2, // tx_axis_tcan_start
  output  wire          gtf_ch_txunfout,
  output  wire          gtf_ch_txptpsop,
  output  wire          gtf_ch_txptpsoppos,
  output  wire          gtf_ch_txgbseqstart,
                              
  output  wire          gtf_ch_rxaxistvalid,
  output  wire [63:0]   gtf_ch_rxaxistdata,
  output  wire [7:0]    gtf_ch_rxaxistlast,
  output  wire [7:0]    gtf_ch_rxaxistpre,
  output  wire          gtf_ch_rxaxisterr,
  output  wire [4:0]    gtf_ch_rxaxistterm,
  output  wire [1:0]    gtf_ch_rxaxistsof,
  input   wire          vnc_rx_custom_preamble_en_in //EG
  
  // END VNC

);

  `include "gtfwizard_0_rules_output.vh" 


wire hb_gtwiz_reset_all_vio;
wire freerun_clk;
wire hb_gtwiz_reset_clk_freerun_in;
wire hb_gtwiz_reset_clk_freerun_in_itm;
wire refclk_in;
wire gtwiz_reset_all_in;
wire gtf_txusrclk2_out;
wire gtf_rxusrclk2_out;
wire gtwiz_reset_tx, gtwiz_reset_rx;
wire gtwiz_reset_tx_t, gtwiz_reset_rx_t;  
wire              gtf_ch_txresetdone;
wire              gtf_ch_rxresetdone;

wire    vio_gtf_ch_gttxreset;
wire    vio_gtf_ch_txpmareset;
wire    vio_gtf_ch_txpcsreset;
wire    vio_gtf_ch_gtrxreset;
wire    vio_gtf_ch_txuserrdy;
wire    vio_gtf_ch_rxpmareset;
wire    vio_gtf_ch_rxdfelpmreset;
wire    vio_gtf_ch_eyescanreset;
wire    vio_gtf_ch_rxpcsreset;
wire    vio_gtf_ch_rxuserrdy;
wire    vio_gtf_cm_qpll0reset;
wire    vio_gtf_cm_qpll1reset;

//IBUFDS ibufds_clk_freerun_inst (
//  .I  (hb_gtwiz_reset_clk_freerun_p_in),
//  .IB (hb_gtwiz_reset_clk_freerun_n_in),
//  .O  (hb_gtwiz_reset_clk_freerun_in_itm)
//);

wire clk_wiz_reset = 1'b0;
wire cw_lat_clk;
wire cw_sys_clk;
wire ctl_gt_reset_all;
wire [2:0] ctl_local_loopback;
wire  ctl_tx_send_idle_axi;
wire  ctl_tx_send_lfi_axi;
wire  ctl_tx_send_rfi_axi;

assign  aclk    = freerun_clk;
assign  aresetn = ~gtwiz_reset_all_in;

///////////////    cfgmclk    //////////////////
wire cfgmclk; 
STARTUPE3 #(
  .PROG_USR("FALSE"),  // Activate program event security feature. Requires encrypted bitstreams.
  .SIM_CCLK_FREQ(0.0)  // Set the Configuration Clock Frequency (ns) for simulation.
) STARTUPE3_inst (
  .CFGCLK(),       // 1-bit output: Configuration main clock output.
  .CFGMCLK(cfgmclk)     // 1-bit output: Configuration internal oscillator clock output.
);

///////////////  cfgmclk end   //////////////////

clk_wiz_0 clk_wiz_freerun_inst (
  // Clock out ports
  .clk_out1       (freerun_clk),    // output clk_out_200MHz
  .clk_out2       (sys_clk_out),                       // output clk_out_425Mhz
  // Status and control signals
  .reset          (clk_wiz_reset), // input reset
  .locked         (),       // output locked
  // Clock in ports
  .clk_in1(cfgmclk)
);    

/*
BUFG bufg_clk_freerun_inst (
  .I (hb_gtwiz_reset_clk_freerun_in),
  .O (freerun_clk)
);
*/

/*
 * We are deprecating the latency clock - instead we are using the RXUSRCLK to measure latency.
BUFG bufg_clk_lat_inst (
  .I (cw_lat_clk),
  .O (lat_clk_out)
);
*/
assign lat_clk_out = 1'b0;

/*
BUFG bufg_clk_sys_inst (
  .I (cw_sys_clk),
  .O (sys_clk_out)
);
*/
  wire hb_gtwiz_reset_all_in_or = ctl_gt_reset_all || hb_gtwiz_reset_all_in || hb_gtwiz_reset_all_vio;																			  

  xpm_cdc_async_rst # (
    .DEST_SYNC_FF (5),
    .RST_ACTIVE_HIGH(0)
  ) reset_lat_sync (
    .dest_clk  (lat_clk_out),
    .src_arst  (~hb_gtwiz_reset_all_in_or),
    .dest_arst (lat_rstn_out)
  );

  xpm_cdc_async_rst # (
    .DEST_SYNC_FF (5),
    .RST_ACTIVE_HIGH(1)
  ) reset_sys_sync (
    .dest_clk  (sys_clk_out), //EG 8/31 switched from freerun to sys
    .src_arst  (hb_gtwiz_reset_all_in_or),
    .dest_arst (sys_rst_out)
  );



IBUFDS_GTE4 #(
  .REFCLK_EN_TX_PATH  (1'b0),
  .REFCLK_HROW_CK_SEL (2'b00), //odiv2 = O frequency = 161 M
  .REFCLK_ICNTL_RX    (2'b00)
) IBUFDS_GTE4_INST (
  .I     (refclk_p),
  .IB    (refclk_n),
  .CEB   (1'b0),
  .O     (refclk_in),       // goes direct to the GT
  .ODIV2 () 
);

  xpm_cdc_async_rst # (
    .DEST_SYNC_FF (5),
    .RST_ACTIVE_HIGH(1)
  ) reset_all_in_sync (
    .dest_clk  (freerun_clk),
    .src_arst  (hb_gtwiz_reset_all_in_or),
    .dest_arst (gtwiz_reset_all_in)
  );

/*
    xpm_cdc_async_rst # (
    .DEST_SYNC_FF (5),
    .RST_ACTIVE_HIGH(0)
  ) reset_tx_clk_sync_t (
    .dest_clk  (gtf_txusrclk2_out),
    .src_arst  ((!gtf_ch_txresetdone)| hb_gtwiz_reset_all_in_or ),
    .dest_arst (gtwiz_reset_tx_t)
  );
  
  xpm_cdc_async_rst # (
    .DEST_SYNC_FF (5),
    .RST_ACTIVE_HIGH(0)
  ) reset_rx_clk_sync_t(
    .dest_clk  (gtf_rxusrclk2_out),
    .src_arst  ((!gtf_ch_rxresetdone) | hb_gtwiz_reset_all_in_or),
    .dest_arst (gtwiz_reset_rx_t)
  );
*/
  
  xpm_cdc_async_rst # (
    .DEST_SYNC_FF (5),
    .RST_ACTIVE_HIGH(1)
  ) reset_tx_clk_sync (
    .dest_clk  (gtf_txusrclk2_out),
    .src_arst  (hb_gtwiz_reset_all_in_or ),
    .dest_arst (gtwiz_reset_tx)
  );
  
  xpm_cdc_async_rst # (
    .DEST_SYNC_FF (5),
    .RST_ACTIVE_HIGH(1)
  ) reset_rx_clk_sync (
    .dest_clk  (gtf_rxusrclk2_out),
    .src_arst  (hb_gtwiz_reset_all_in_or),
    .dest_arst (gtwiz_reset_rx)
  );

  wire   gtwiz_reset_clk_freerun_in = freerun_clk;
  wire   gtf_cm_qpll0lockdetclk     = freerun_clk;
  wire   gtf_cm_qpll1lockdetclk     = freerun_clk;
  wire   gtf_ch_cplllockdetclk      = freerun_clk;
  wire   gtf_ch_drpclk              = freerun_clk;
  wire   gtf_cm_drpclk              = freerun_clk;
  wire   gtf_ch_dmonitorclk         = freerun_clk;

  //---Reset controller inputs ---{
// VNC  wire              gtwiz_reset_tx_pll_and_datapath_in = 1'b0;
// VNC  wire              gtwiz_reset_tx_datapath_in = 1'b0;
// VNC  wire              gtwiz_reset_rx_pll_and_datapath_in = 1'b0;
// VNC  wire              gtwiz_reset_rx_datapath_in = 1'b0;
  //---Reset controller inputs ---}

  //---GT Reference clock inputs ---{
  wire              gtf_ch_gtgrefclk = 1'b0;
  wire  [2:0]       gtf_ch_cpllrefclksel = CPLLREFCLKSEL;
  wire      [2:0]   gtf_cm_qpll0refclksel = QPLL0REFCLKSEL;
  wire      [2:0]   gtf_cm_qpll1refclksel = QPLL1REFCLKSEL;
  wire              gtf_ch_gtnorthrefclk0 = 0;
  wire              gtf_ch_gtnorthrefclk1 = 0;
  wire              gtf_ch_gtrefclk0 = refclk_in;
  wire              gtf_ch_gtrefclk1 = 0;
  wire              gtf_ch_gtsouthrefclk0 = 0;
  wire              gtf_ch_gtsouthrefclk1 = 0;
  wire              gtf_cm_gtgrefclk0 = 0;
  wire              gtf_cm_gtgrefclk1 = 0;
  wire              gtf_cm_gtnorthrefclk00 = 0;
  wire              gtf_cm_gtnorthrefclk01 = 0;
  wire              gtf_cm_gtnorthrefclk10 = 0;
  wire              gtf_cm_gtnorthrefclk11 = 0;
  wire              gtf_cm_gtrefclk00 = refclk_in;
  wire              gtf_cm_gtrefclk01 = 0;
  wire              gtf_cm_gtrefclk10 = 0;
  wire              gtf_cm_gtrefclk11 = 0;
  wire              gtf_cm_gtsouthrefclk00 = 0;
  wire              gtf_cm_gtsouthrefclk01 = 0;
  wire              gtf_cm_gtsouthrefclk10 = 0;
  wire              gtf_cm_gtsouthrefclk11 = 0;
  //---GT Reference clock inputs ---}

  //--- CPLL/QPLL0/QPLL1 dynamic sel ---{
  wire              gtf_cm_qpll0clkrsvd0     =  QPLL0CLKRSVD0 ;
  wire              gtf_cm_qpll0clkrsvd1     =  QPLL0CLKRSVD1 ;
  wire              gtf_cm_qpll0fbclklost;
  wire              gtf_cm_qpll0lock;
  wire              gtf_cm_qpll0locken = 1'b1;
  wire              gtf_cm_qpll0outclk;
  wire              gtf_cm_qpll0outrefclk;
  wire              gtf_cm_qpll0pd           =  QPLL0PD       ;
  wire              gtf_cm_qpll0refclklost;
  wire              gtf_cm_qpll0reset        =  QPLL0RESET    ;
  wire              gtf_cm_qpll1clkrsvd0     =  QPLL1CLKRSVD0 ;
  wire              gtf_cm_qpll1clkrsvd1     =  QPLL1CLKRSVD1 ;
  wire              gtf_cm_qpll1fbclklost;
  wire              gtf_cm_qpll1lock;
  wire              gtf_cm_qpll1locken = 1'b1;
  wire              gtf_cm_qpll1outclk;
  wire              gtf_cm_qpll1outrefclk;
  wire              gtf_cm_qpll1pd           =  QPLL1PD       ;
  wire              gtf_cm_qpll1refclklost;
  wire              gtf_cm_qpll1reset        =  QPLL1RESET    ;
  wire      [4:0]   gtf_cm_qpllrsvd2         =  QPLLRSVD2     ;
  wire      [4:0]   gtf_cm_qpllrsvd3         =  QPLLRSVD3     ;
  wire      [7:0]   gtf_cm_qpll0fbdiv        =  QPLL0FBDIV    ;
  wire      [7:0]   gtf_cm_qpll1fbdiv        =  QPLL1FBDIV    ;
  wire      [7:0]   gtf_cm_qplldmonitor0;
  wire      [7:0]   gtf_cm_qplldmonitor1;
  wire      [7:0]   gtf_cm_qpllrsvd1         =  QPLLRSVD1     ;
  wire      [7:0]   gtf_cm_qpllrsvd4         =  QPLLRSVD4     ;
  wire              gtf_ch_cpllfbclklost;
  wire              gtf_ch_cpllfreqlock = CPLLFREQLOCK;
  wire              gtf_ch_cplllock;
  wire              gtf_ch_cplllocken =1'b1;
  wire              gtf_ch_cpllpd = 1'b0;
  wire              gtf_ch_cpllrefclklost;
  wire              gtf_ch_cpllreset = 1'b0;
  wire              gtf_ch_qpll0clk = gtf_cm_qpll0outclk;
  wire              gtf_ch_qpll0freqlock = QPLL0FREQLOCK;
  wire              gtf_ch_qpll0refclk = gtf_cm_qpll0outrefclk;
  wire              gtf_ch_qpll1clk = gtf_cm_qpll1outclk;
  wire              gtf_ch_qpll1freqlock = QPLL1FREQLOCK;
  wire              gtf_ch_qpll1refclk = gtf_cm_qpll1outrefclk;
  wire              plllock_tx_in = gtf_cm_qpll0lock;
  wire              plllock_rx_in = gtf_cm_qpll0lock;

  wire              gtf_cm_sdm0reset     =  SDM0RESET  ;
  wire              gtf_cm_sdm0toggle    =  SDM0TOGGLE ;
  wire      [1:0]   gtf_cm_sdm0width     =  SDM0WIDTH  ;
  wire      [3:0]   gtf_cm_sdm0finalout;
  wire     [14:0]   gtf_cm_sdm0testdata;
  wire     [24:0]   gtf_cm_sdm0data      =  SDM0DATA   ;
  wire              gtf_cm_sdm1reset     =  SDM1RESET  ;
  wire              gtf_cm_sdm1toggle    =  SDM1TOGGLE ;
  wire      [1:0]   gtf_cm_sdm1width     =  SDM1WIDTH  ;
  wire      [3:0]   gtf_cm_sdm1finalout;
  wire     [14:0]   gtf_cm_sdm1testdata;
  wire     [24:0]   gtf_cm_sdm1data      =  SDM1DATA   ;
  //--- CPLL/QPLL0/QPLL1 dynamic sel ---}

  //--- DRP ports ---{
  wire         gtf_ch_drpen;// = 0;
  wire         gtf_ch_drprst = gtwiz_reset_all_in; //new 
  wire         gtf_ch_drpwe;// =0;
  wire  [15:0] gtf_ch_drpdi;// =0;
  wire  [9:0]  gtf_ch_drpaddr;// =0;
  wire         gtf_ch_drprdy;
  wire  [15:0] gtf_ch_drpdo;
  wire         gtf_cm_drpen;   // VNC  = 0;
  wire         gtf_cm_drpwe;   // VNC  =0;
  wire  [15:0]  gtf_cm_drpaddr; // VNC  =0;
  wire  [15:0] gtf_cm_drpdi;   // VNC  =0;
  wire         gtf_cm_drprdy;
  wire  [15:0] gtf_cm_drpdo;
  //--- DRP ports ---{

  //---Port tie offs--{ 
  assign gtf_cm_drpaddr[15:10] = 6'd0;  // VNC
  wire  [8:0]       gtf_ch_ctlrxpauseack = CTLRXPAUSEACK;
  wire  [8:0]       gtf_ch_ctltxpausereq = CTLTXPAUSEREQ;
  wire              gtf_ch_ctltxresendpause = CTLTXRESENDPAUSE;
  wire              gtf_ch_ctltxsendidle = ctl_tx_send_idle_axi; // VNC = CTLTXSENDIDLE;
  wire              gtf_ch_ctltxsendlfi = ctl_tx_send_lfi_axi; // VNC = CTLTXSENDLFI;
  wire              gtf_ch_ctltxsendrfi = ctl_tx_send_rfi_axi; // VNC = CTLTXSENDRFI;
  wire              gtwiz_reset_rx_cdr_stable_out;
  wire              gtwiz_reset_rx_done_out;
  wire              gtwiz_reset_tx_done_out;
  wire              gtf_ch_cdrstepdir = CDRSTEPDIR;
  wire              gtf_ch_cdrstepsq = CDRSTEPSQ;
  wire              gtf_ch_cdrstepsx = CDRSTEPSX;
  wire              gtf_ch_cfgreset = CFGRESET;
  wire              gtf_ch_clkrsvd0 = CLKRSVD0;
  wire              gtf_ch_clkrsvd1 = CLKRSVD1;
  wire              gtf_ch_dmonfiforeset = DMONFIFORESET;
  wire              gtf_ch_eyescanreset = EYESCANRESET;
  wire              gtf_ch_eyescantrigger = EYESCANTRIGGER;
  wire              gtf_ch_freqos = FREQOS;
  wire              gtf_ch_gtrxreset; // VNC  = GTRXRESET;
  wire              gtf_ch_gtrxresetsel = GTRXRESETSEL;
  wire              gtf_ch_gttxreset; // VNC  = GTTXRESET;
  wire              gtf_ch_gttxresetsel = GTTXRESETSEL;
  wire              gtf_ch_incpctrl = INCPCTRL;
  wire              gtf_ch_resetovrd = RESETOVRD;
  wire              gtf_ch_rxafecfoken = RXAFECFOKEN;
  wire              gtf_ch_rxcdrfreqreset = RXCDRFREQRESET;
  wire              gtf_ch_rxcdrhold = 0; //common clk, was = RXCDRHOLD;
  wire              gtf_ch_rxcdrovrden = RXCDROVRDEN;
  wire              gtf_ch_rxcdrreset = RXCDRRESET;
  wire              gtf_ch_rxckcalreset = RXCKCALRESET;
  wire              gtf_ch_rxdfeagchold = RXDFEAGCHOLD;
  wire              gtf_ch_rxdfeagcovrden = RXDFEAGCOVRDEN;
  wire              gtf_ch_rxdfecfokfen = RXDFECFOKFEN;
  wire              gtf_ch_rxdfecfokfpulse = RXDFECFOKFPULSE;
  wire              gtf_ch_rxdfecfokhold = RXDFECFOKHOLD;
  wire              gtf_ch_rxdfecfokovren = RXDFECFOKOVREN;
  wire              gtf_ch_rxdfekhhold = RXDFEKHHOLD;
  wire              gtf_ch_rxdfekhovrden = RXDFEKHOVRDEN;
  wire              gtf_ch_rxdfelfhold = RXDFELFHOLD;
  wire              gtf_ch_rxdfelfovrden = RXDFELFOVRDEN;
  wire              gtf_ch_rxdfelpmreset      = RXDFELPMRESET      ;
  wire              gtf_ch_rxdfetap10hold     = RXDFETAP10HOLD     ;
  wire              gtf_ch_rxdfetap10ovrden   = RXDFETAP10OVRDEN   ;
  wire              gtf_ch_rxdfetap11hold     = RXDFETAP11HOLD     ;
  wire              gtf_ch_rxdfetap11ovrden   = RXDFETAP11OVRDEN   ;
  wire              gtf_ch_rxdfetap12hold     = RXDFETAP12HOLD     ;
  wire              gtf_ch_rxdfetap12ovrden   = RXDFETAP12OVRDEN   ;
  wire              gtf_ch_rxdfetap13hold     = RXDFETAP13HOLD     ;
  wire              gtf_ch_rxdfetap13ovrden   = RXDFETAP13OVRDEN   ;
  wire              gtf_ch_rxdfetap14hold     = RXDFETAP14HOLD     ;
  wire              gtf_ch_rxdfetap14ovrden   = RXDFETAP14OVRDEN   ;
  wire              gtf_ch_rxdfetap15hold     = RXDFETAP15HOLD     ;
  wire              gtf_ch_rxdfetap15ovrden   = RXDFETAP15OVRDEN   ;
  wire              gtf_ch_rxdfetap2hold      = RXDFETAP2HOLD      ;
  wire              gtf_ch_rxdfetap2ovrden    = RXDFETAP2OVRDEN    ;
  wire              gtf_ch_rxdfetap3hold      = RXDFETAP3HOLD      ;
  wire              gtf_ch_rxdfetap3ovrden    = RXDFETAP3OVRDEN    ;
  wire              gtf_ch_rxdfetap4hold      = RXDFETAP4HOLD      ;
  wire              gtf_ch_rxdfetap4ovrden    = RXDFETAP4OVRDEN    ;
  wire              gtf_ch_rxdfetap5hold      = RXDFETAP5HOLD      ;
  wire              gtf_ch_rxdfetap5ovrden    = RXDFETAP5OVRDEN    ;
  wire              gtf_ch_rxdfetap6hold      = RXDFETAP6HOLD      ;
  wire              gtf_ch_rxdfetap6ovrden    = RXDFETAP6OVRDEN    ;
  wire              gtf_ch_rxdfetap7hold      = RXDFETAP7HOLD      ;
  wire              gtf_ch_rxdfetap7ovrden    = RXDFETAP7OVRDEN    ;
  wire              gtf_ch_rxdfetap8hold      = RXDFETAP8HOLD      ;
  wire              gtf_ch_rxdfetap8ovrden    = RXDFETAP8OVRDEN    ;
  wire              gtf_ch_rxdfetap9hold      = RXDFETAP9HOLD      ;
  wire              gtf_ch_rxdfetap9ovrden    = RXDFETAP9OVRDEN    ;
  wire              gtf_ch_rxdfeuthold        = RXDFEUTHOLD        ;
  wire              gtf_ch_rxdfeutovrden      = RXDFEUTOVRDEN      ;
  wire              gtf_ch_rxdfevphold        = RXDFEVPHOLD        ;
  wire              gtf_ch_rxdfevpovrden      = RXDFEVPOVRDEN      ;
  wire              gtf_ch_rxdfexyden         = RXDFEXYDEN         ;
  wire              gtf_ch_rxdlybypass;//     = RXDLYBYPASS        ;
  wire              gtf_ch_rxdlyen;//         = RXDLYEN            ;
  wire              gtf_ch_rxdlyovrden;//     = RXDLYOVRDEN        ;
  wire              gtf_ch_rxdlysreset;//     = RXDLYSRESET        ;
  wire              gtf_ch_rxlpmen            = RXLPMEN            ;
  wire              gtf_ch_rxlpmgchold        = RXLPMGCHOLD        ;
  wire              gtf_ch_rxlpmgcovrden      = RXLPMGCOVRDEN      ;
  wire              gtf_ch_rxlpmhfhold        = RXLPMHFHOLD        ;
  wire              gtf_ch_rxlpmhfovrden      = RXLPMHFOVRDEN      ;
  wire              gtf_ch_rxlpmlfhold        = RXLPMLFHOLD        ;
  wire              gtf_ch_rxlpmlfklovrden    = RXLPMLFKLOVRDEN    ;
  wire              gtf_ch_rxlpmoshold        = RXLPMOSHOLD        ;
  wire              gtf_ch_rxlpmosovrden      = RXLPMOSOVRDEN      ;
  wire              gtf_ch_rxoscalreset       = RXOSCALRESET    ;
  wire              gtf_ch_rxoshold           = RXOSHOLD        ;
  wire              gtf_ch_rxosovrden         = RXOSOVRDEN      ;
  wire              gtf_ch_rxpcsreset         = RXPCSRESET      ;
  wire              gtf_ch_rxphalign;//       = RXPHALIGN       ;
  wire              gtf_ch_rxphalignen;//     = RXPHALIGNEN     ;
  wire              gtf_ch_rxphdlypd;//       = RXPHDLYPD       ;
  wire              gtf_ch_rxphdlyreset;//    = RXPHDLYRESET    ;
  wire              gtf_ch_rxpmareset         = RXPMARESET      ;
  wire              gtf_ch_rxpolarity         = RXPOLARITY      ;
  wire              gtf_ch_rxprbscntreset     = RXPRBSCNTRESET  ;
  wire              gtf_ch_rxprogdivreset     = RXPROGDIVRESET  ;
  wire              gtf_ch_rxslipoutclk       = RXSLIPOUTCLK    ;
// VNC  wire              gtf_ch_rxslippma          = RXSLIPPMA       ;
  wire              gtf_ch_rxsyncallin;//     = RXSYNCALLIN     ;
  wire              gtf_ch_rxsyncin;//        = RXSYNCIN        ;
  wire              gtf_ch_rxsyncmode;//      = RXSYNCMODE      ;
  wire              gtf_ch_rxtermination      = RXTERMINATION   ;
  wire              gtf_ch_rxuserrdy         = RXUSERRDY;
  wire              gtf_ch_txdccforcestart   =  TXDCCFORCESTART;
  wire              gtf_ch_txdccreset        =  TXDCCRESET     ;
  wire              gtf_ch_txdlybypass;//    =  TXDLYBYPASS    ;
  wire              gtf_ch_txdlyen;//        =  TXDLYEN        ;
  wire              gtf_ch_txdlyhold;//      =  TXDLYHOLD      ;
  wire              gtf_ch_txdlyovrden;//    =  TXDLYOVRDEN    ;
  wire              gtf_ch_txdlysreset;//    =  TXDLYSRESET    ;
  wire              gtf_ch_txdlyupdown;//    =  TXDLYUPDOWN    ;
  wire              gtf_ch_txelecidle        =  1'b0;
  wire              gtf_ch_txgbseqsync       =  TXGBSEQSYNC    ;
  wire              gtf_ch_txmuxdcdexhold    =  TXMUXDCDEXHOLD ;
  wire              gtf_ch_txmuxdcdorwren    =  TXMUXDCDORWREN ;
  wire              gtf_ch_txpcsreset        =  TXPCSRESET     ;
  wire              gtf_ch_txphalign;//      =  TXPHALIGN      ;
  wire              gtf_ch_txphalignen;//    =  TXPHALIGNEN    ;
  wire              gtf_ch_txphdlypd;//      =  TXPHDLYPD      ;
  wire              gtf_ch_txphdlyreset;//   =  TXPHDLYRESET   ;
  wire              gtf_ch_txphdlytstclk;//  =  TXPHDLYTSTCLK  ;
  wire              gtf_ch_txphinit;//       =  TXPHINIT       ;
  wire              gtf_ch_txphovrden;//     =  TXPHOVRDEN     ;
  wire              gtf_ch_txpippmen         =  TXPIPPMEN      ;
  wire              gtf_ch_txpippmovrden     =  TXPIPPMOVRDEN  ;
  wire              gtf_ch_txpippmpd         =  TXPIPPMPD      ;
  wire              gtf_ch_txpippmsel        =  TXPIPPMSEL     ;
  wire              gtf_ch_txpisopd          =  TXPISOPD       ;
  wire              gtf_ch_txpmareset        =  TXPMARESET     ;
  wire              gtf_ch_txpolarity        =  TXPOLARITY     ;
  wire              gtf_ch_txprbsforceerr    =  TXPRBSFORCEERR ;
  wire              gtf_ch_txprogdivreset    =  TXPROGDIVRESET ;
  wire              gtf_ch_txsyncallin;//    =  TXSYNCALLIN    ;
  wire              gtf_ch_txsyncin;//       =  TXSYNCIN       ;
  wire              gtf_ch_txsyncmode;//     =  TXSYNCMODE     ;
  wire              gtf_ch_txuserrdy         =  TXUSERRDY      ;
// VNC  
// wire  [15:0]      gtf_ch_gtrsvd = GTRSVD;
// wire  [15:0]      gtf_ch_pcsrsvdin = PCSRSVDIN;
  wire  [15:0]      gtf_ch_gtrsvd    = {GTRSVD[15:9], gtf_ch_gtrsvd_8, GTRSVD[7:0]};
  wire  [15:0]      gtf_ch_pcsrsvdin = {PCSRSVDIN[15:2], gtf_ch_pcsrsvdin_1, gtf_ch_pcsrsvdin_0};
// END VNC
  wire  [19:0]      gtf_ch_tstin = TSTIN;
  wire  [1:0]       gtf_ch_rxelecidlemode     = RXELECIDLEMODE ;
  wire  [1:0]       gtf_ch_rxmonitorsel = RXMONITORSEL;
  wire  [1:0]       gtf_ch_rxpd = RXPD;
  wire  [1:0]       gtf_ch_rxpllclksel = RXPLLCLKSEL;
  wire  [1:0]       gtf_ch_rxsysclksel       =  RXSYSCLKSEL;
  wire  [1:0]       gtf_ch_txpd = TXPD;
  wire  [1:0]       gtf_ch_txpllclksel = TXPLLCLKSEL;
  wire  [1:0]       gtf_ch_txsysclksel       =  TXSYSCLKSEL    ;
  wire  [2:0]       gtf_ch_loopback = ctl_local_loopback; // VNC = LOOPBACK;
  wire  [2:0]       gtf_ch_rxoutclksel = RXOUTCLKSEL;
  wire  [2:0]       gtf_ch_txoutclksel = TXOUTCLKSEL;
  wire  [3:0]       gtf_ch_rxdfecfokfcnum = RXDFECFOKFCNUM;
  wire  [3:0]       gtf_ch_rxprbssel = RXPRBSSEL;
  wire  [3:0]       gtf_ch_txprbssel = TXPRBSSEL;
  wire  [4:0]       gtf_ch_txdiffctrl        =  A_TXDIFFCTRL     ;
  wire  [4:0]       gtf_ch_txpippmstepsize   =  TXPIPPMSTEPSIZE;
  wire  [4:0]       gtf_ch_txpostcursor      =  TXPOSTCURSOR   ;
  wire  [4:0]       gtf_ch_txprecursor       =  TXPRECURSOR    ;
  wire  [6:0]       gtf_ch_rxckcalstart = RXCKCALSTART;
  wire  [6:0]       gtf_ch_txmaincursor      =  TXMAINCURSOR   ;
  wire              gtf_ch_dmonitoroutclk;
  wire              gtf_ch_eyescandataerror;
  wire              gtf_ch_gtpowergood;
  wire              gtf_ch_gtrefclkmonitor;
  wire              gtf_ch_resetexception;
// VNC  wire              gtf_ch_rxbitslip;
  wire              gtf_ch_rxcdrlock;
  wire              gtf_ch_rxcdrphdone;
  wire              gtf_ch_rxckcaldone;
  wire              gtf_ch_rxdlysresetdone;
  wire              gtf_ch_rxelecidle;
  wire              gtf_ch_rxgbseqstart;
  wire              gtf_ch_rxosintdone;
  wire              gtf_ch_rxosintstarted;
  wire              gtf_ch_rxosintstrobedone;
  wire              gtf_ch_rxosintstrobestarted;
  wire              gtf_ch_rxoutclk;
  wire              gtf_ch_rxoutclkfabric;
  wire              gtf_ch_rxoutclkpcs;
  wire              gtf_ch_rxphovrden;
  wire              gtf_ch_rxphaligndone;
  wire              gtf_ch_rxphalignerr;
  wire              gtf_ch_rxpmaresetdone;
  wire              gtf_ch_rxprbserr;
  wire              gtf_ch_rxprbslocked;
  wire              gtf_ch_rxptpsop;
  wire              gtf_ch_rxptpsoppos;
  wire              gtf_ch_rxrecclkout;
  wire              gtf_ch_rxslipdone;
  wire              gtf_ch_rxslipoutclkrdy;
// VNC  wire              gtf_ch_rxslippmardy;
  //wire              gtf_ch_rxsyncdone;
  wire              gtf_ch_rxsyncout;
  wire              gtf_ch_statrxbadcode;
  wire              gtf_ch_statrxbadfcs;
  wire              gtf_ch_statrxbadpreamble;
  wire              gtf_ch_statrxbadsfd;
// VNC   wire              gtf_ch_statrxblocklock;
  wire              gtf_ch_statrxbroadcast;
  wire              gtf_ch_statrxfcserr;
  wire              gtf_ch_statrxframingerr;
  wire              gtf_ch_statrxgotsignalos;
  wire              gtf_ch_statrxhiber;
  wire              gtf_ch_statrxinrangeerr;
// VNC  wire              gtf_ch_statrxinternallocalfault;
// VNC  wire              gtf_ch_statrxlocalfault;
  wire              gtf_ch_statrxmulticast;
  wire              gtf_ch_statrxpkt;
  wire              gtf_ch_statrxpkterr;
// VNC  wire              gtf_ch_statrxreceivedlocalfault;
// VNC  wire              gtf_ch_statrxremotefault;
  wire              gtf_ch_statrxstatus;
  wire              gtf_ch_statrxstompedfcs;
  wire              gtf_ch_statrxtestpatternmismatch;
  wire              gtf_ch_statrxtruncated;
  wire              gtf_ch_statrxunicast;
  wire              gtf_ch_statrxvalidctrlcode;
  wire              gtf_ch_statrxvlan;
  wire              gtf_ch_stattxbadfcs;
  wire              gtf_ch_stattxbroadcast;
  wire              gtf_ch_stattxfcserr;
  wire              gtf_ch_stattxmulticast;
  wire              gtf_ch_stattxpkt;
  wire              gtf_ch_stattxpkterr;
  wire              gtf_ch_stattxunicast;
  wire              gtf_ch_stattxvlan;
  wire              gtf_ch_txdccdone;
  wire              gtf_ch_txdlysresetdone;
// VNC  wire              gtf_ch_txgbseqstart;
  wire              gtf_ch_txoutclk;
  wire              gtf_ch_txoutclkfabric;
  wire              gtf_ch_txoutclkpcs;
  wire              gtf_ch_txphaligndone;
  wire              gtf_ch_txphinitdone;
  wire              gtf_ch_txpmaresetdone;
  wire              gtf_ch_txprgdivresetdone;
// VNC  wire              gtf_ch_txptpsop;
// VNC  wire              gtf_ch_txptpsoppos;
//  wire              gtf_ch_txresetdone;
//  wire              gtf_ch_rxresetdone;
  //wire              gtf_ch_txsyncdone;
  wire              gtf_ch_txsyncout;
// VNC  wire              gtf_ch_txunfout;
  wire   [15:0]     gtf_ch_dmonitorout;
  wire   [15:0]     gtf_ch_pcsrsvdout;
  wire   [15:0]     gtf_ch_pinrsrvdas;
  wire   [7:0]      gtf_ch_rxmonitorout;
  wire   [8:0]      gtf_ch_statrxpausequanta;
  wire   [8:0]      gtf_ch_statrxpausereq;
  wire   [8:0]      gtf_ch_statrxpausevalid;
  wire   [8:0]      gtf_ch_stattxpausevalid;
  wire              gtf_cm_bgbypassb         =  BGBYPASSB    ;
  wire              gtf_cm_bgmonitorenb      =  BGMONITORENB ;
  wire              gtf_cm_bgpdb             =  BGPDB        ;
  wire              gtf_cm_bgrcalovrdenb     =  BGRCALOVRDENB;
  wire              gtf_cm_rcalenb           =  RCALENB      ;
  wire      [4:0]   gtf_cm_bgrcalovrd        =  BGRCALOVRD;
  wire      [7:0]   gtf_cm_pmarsvd0          =  PMARSVD0  ;
  wire      [7:0]   gtf_cm_pmarsvd1          =  PMARSVD1  ;
  wire              gtf_cm_refclkoutmonitor0;
  wire              gtf_cm_refclkoutmonitor1;
  wire      [1:0]   gtf_cm_rxrecclk0sel;
  wire      [1:0]   gtf_cm_rxrecclk1sel;
  wire      [7:0]   gtf_cm_pmarsvdout0;
  wire      [7:0]   gtf_cm_pmarsvdout1;
  //---Port tie offs--}

  wire  [39:0]      gtf_ch_txrawdata;

// VNC  wire              gtf_ch_txaxisterr = 1'b0;
// VNC  wire              gtf_ch_txaxistpoison = 1'b0;
// VNC  wire              gtf_ch_txaxistready;
// VNC  wire              gtf_ch_txaxistvalid = 1'b1;
// VNC  wire  [1:0]       gtf_ch_txaxistsof = 2'd0;
// VNC  wire  [4:0]       gtf_ch_txaxistterm = 5'd0;
// VNC  wire  [63:0]      gtf_ch_txaxistdata = 64'd0;
// VNC  wire  [7:0]       gtf_ch_txaxistlast = 8'd1;
// VNC  wire  [7:0]       gtf_ch_txaxistpre = 8'd0;
  wire   [3:0]      gtf_ch_stattxbytes;

  wire   [39:0]     gtf_ch_rxrawdata;

// VNC  wire              gtf_ch_rxaxisterr;
// VNC  wire              gtf_ch_rxaxistvalid;
// VNC  wire   [1:0]      gtf_ch_rxaxistsof;
// VNC  wire   [4:0]      gtf_ch_rxaxistterm;
// VNC  wire   [63:0]     gtf_ch_rxaxistdata;
// VNC  wire   [7:0]      gtf_ch_rxaxistlast;
// VNC  wire   [7:0]      gtf_ch_rxaxistpre;
  wire   [3:0]      gtf_ch_statrxbytes;
  
  
  /////////////////DRP Switching Start//////////////////
  
//  wire gtwiz_buffbypass_rx_reset;
//  wire gtwiz_buffbypass_tx_reset; //EG new
//  assign gtwiz_buffbypass_rx_reset = ~gtf_ch_rxresetdone; //new this one is in rxusrclk domain already, was ~gtf_ch_rxpmaresetdone
//  assign gtwiz_buffbypass_tx_reset = ~gtf_ch_txresetdone; //EG new
  wire AM_switch;
  wire drp_reconfig_rdy;
  wire drp_reconfig_done;

  wire          drp_align_drprdy;
  wire          drp_align_drpen;
  wire          drp_align_drpwe;
  wire [9:0]    drp_align_drpaddr;
  wire [15:0]   drp_align_drpdi;
  wire [15:0]   drp_align_drpdo;
  
  gtfwizard_0_example_gtwiz_drp_align_switch drp_align_switch_inst (
    .freerun_clk_in               (freerun_clk),
    .gtwiz_buffbypass_rx_reset_in (gtwiz_buffbypass_rx_reset),
    
    .AM_switch_in                 (AM_switch), //need signal
    .drp_reconfig_rdy_in          (drp_reconfig_rdy), //need signal
    .drprdy_in                    (drp_align_drprdy), 
    .drp_reconfig_done_out        (drp_reconfig_done), //need signal
    .drpen_out                    (drp_align_drpen),
    .drpwe_out                    (drp_align_drpwe), 
    .drpaddr_out                  (drp_align_drpaddr),
    .drpdo_in                     (drp_align_drpdo),
    .drpdi_out                    (drp_align_drpdi)
  );
  /////////////////DRP Switching End//////////////////
  
  
  /////////////////DAPI Beginning ////////////////////
  wire gttxreset;
  assign gtf_ch_rxphdlypd = gttxreset;
  assign gtf_ch_txphdlypd = gttxreset;
  /////////////////   DAPI END    ////////////////////

// VNC
   assign tx_axis_clk           = gtf_txusrclk2_out; 
   assign tx_axis_rst           = gtwiz_reset_tx; //EG 8/31 ~resetdone causes buffer flush in tx/rx buffers in vnc due to reset lag
   assign rx_axis_clk           = gtf_rxusrclk2_out; 
   assign rx_axis_rst           = gtwiz_reset_rx; //EG 8/31 ~resetdone causes buffer flush in tx/rx buffers in vnc due to reset lag
   assign gtf_ch_pcsrsvdout_2   = gtf_ch_pcsrsvdout[2];
// END VNC

  wire [15:0] tx_prbs_data;
  wire [15:0] rx_prbs_data;
  gtfwizard_0_prbs_any # (
    .CHK_MODE    (0),
    .INV_PATTERN (1),
    .POLY_LENGHT (31),
    .POLY_TAP    (28),
    .NBITS       (16)
  ) tx_raw_data_prbs (
    .RST      (gtwiz_reset_all_in),
    .CLK      (gtf_txusrclk2_out),
    .DATA_IN  (16'b0),
    .EN       (1'b1),
    .DATA_OUT (tx_prbs_data)
  );

  assign gtf_ch_txrawdata = {24'd0,tx_prbs_data};
  

  wire [15:0] prbs_any_chk_error_int;
  gtfwizard_0_prbs_any # (
    .CHK_MODE    (1),
    .INV_PATTERN (1),
    .POLY_LENGHT (31),
    .POLY_TAP    (28),
    .NBITS       (16)
  ) rx_raw_data_prbs (
    .RST      (gtwiz_reset_all_in),
    .CLK      (gtf_rxusrclk2_out),
    .DATA_IN  (gtf_ch_rxrawdata[15:0]),
    .EN       (1'b1),
    .DATA_OUT (prbs_any_chk_error_int)
  );

/* VNC
  wire restart_tx_rx = ~gtf_ch_txresetdone;
  wire send_continuous_pkts =  1'b1;
  wire completion_status;
  wire rx_gt_locked_led;
  wire rx_block_lock_led;
END VNC */

/* VNC - not needed 
  reg state_check_r;
  
  assign state_check = state_check_r;
  
  reg  fail;
  wire START;
  reg [3:0] count_post_reset;
  
  always @ (posedge gtf_txusrclk2_out)
    if (gtwiz_reset_tx)
        count_post_reset <= 4'b0;
    else if (count_post_reset <= 4'd10)
        count_post_reset <= count_post_reset +1;
        
  assign START = (count_post_reset <= 4'd9) && (count_post_reset >= 4'd1) ? 1'b1: 1'b0;
       
  
  localparam WIDTH = 16	;
  localparam PREABLE_BYTE = 3	;
  localparam COUNT_SIZE = 11	;
  localparam NUM_OF_PACKETS = 10;

wire [(WIDTH-1):0] rxaxistdata	;
wire [(WIDTH-1):0] txaxistdata	;
wire [(WIDTH-1):0] bert_txdata		;
wire [7:0] bert_txaxistpre		;
wire [7:0] txaxistpre	;
wire [7:0] rxaxistpre	;
wire txaxistvalid ;
wire txaxistready ;
wire txgbseqstart ;
wire [7:0] txaxistlast ;
wire rxaxistvalid ;
wire [COUNT_SIZE:0] bist_count	;
wire bist_cnt_en		;
wire bist_cnt_rst		;
wire BIST_RESET; 
wire [7:0] packet_count;

wire txdlysreset;
wire txdlysresetdone, txdlysresetdone_reg0, sm_txdlysresetdone; 
wire txphinitdone, txphinitdone_reg0, sm_txphinitdone;
wire txphaligndone, txphaligndone_reg0, sm_txphaligndone;
wire txsyncdone, txsyncdone_reg0, sm_txsyncdone;
wire rxphaligndone, rxphaligndone_reg0, sm_rxphaligndone;
wire rxdlysresetdone, rxdlysresetdone_reg0, sm_rxdlysresetdone;
wire rxsyncdone, rxsyncdone_reg0, sm_rxsyncdone;
wire rxphalignerr, rxphalignerr_reg0, sm_rxphalignerr;
wire statrxpkt, statrxpkt_1, sm_statrxpkt;
wire statrxpkterr, sm_statrxpkterr, statrxpkterr_1;
wire statrxstatus, sm_statrxstatus, statrxstatus_1;
wire statrxbadfcs, sm_statrxbadfcs, statrxbadfcs_1;
wire statrxfcserr, sm_statrxfcserr, statrxfcserr_1;
wire stattxpkt, sm_stattxpkt, stattxpkt_1;
wire stattxpkterr, sm_stattxpkterr, stattxpkterr_1;
wire stattxbadfcs, sm_stattxbadfcs, stattxbadfcs_1;
wire stattxfcserr, sm_stattxfcserr, stattxfcserr_1;
wire txphinit_sync, txphinit_reg, txphinit;
wire txphalign_sync, txphalign_reg, txphalign;
wire rxphalign_sync, rxphalign_reg, rxphalign;

wire preable_en, sm_preable_en_1, sm_preable_en;
wire bert_en, sm_bert_en_1, sm_bert_en;
wire bert_sync, sm_bert_sync_1, sm_bert_sync;
wire error_counter_ce, sm_error_counter_ce_1, sm_error_counter_ce;
wire bert_det_out, sm_bert_det_out, bert_det_out_1;
wire bert_pass, sm_bert_pass, bert_pass_1;
wire tlast_en, sm_tlast_en_1, sm_tlast_en;

// Re-time start to this domain
wire start_reg0		;
wire start_retimed	;
//wire START ;
wire DONE;
wire DATA_PASSED;
wire CLEAR_FLAGS = 1'b0;
wire sm_done;
wire sm_data_error;

wire [4:0] int_state	;
assign STATE0 = int_state[0];
assign STATE1 = int_state[1];
assign STATE2 = int_state[2];
assign STATE3 = int_state[3];
assign STATE4 = int_state[4];

assign txaxistready = gtf_ch_txaxistready;
assign txgbseqstart = gtf_ch_txgbseqstart;
assign rxaxistdata = gtf_ch_rxaxistdata;
assign rxaxistvalid = gtf_ch_rxaxistvalid;
assign gtf_ch_txaxistvalid = txaxistvalid;
assign gtf_ch_txaxistlast = txaxistlast; 
assign gtf_ch_txaxistpre = bert_txaxistpre;
assign gtf_ch_txaxistdata = bert_txdata;
assign BIST_RESET  = gtwiz_reset_all_in;
  
assign gtf_ch_txaxisterr = 1'b0;
assign gtf_ch_txaxistpoison = 1'b0;
assign gtf_ch_txaxistsof = 2'b0;
assign gtf_ch_txaxistterm = 5'b0;


//wire  sm_rxphinitdone, rxphinitdone_reg0, rxphinitdone;
//wire txphaligen, txdlyen, rxdlyreset, rxphinit, rxphalignen, rxdlyen;

//assign gtf_ch_txdlysreset = txdlysreset;
//assign gtf_ch_txphinit = txphinit_sync;
//assign gtf_ch_txphalign = txphalign_sync;
//assign gtf_ch_rxphalign = rxphalign_sync;
//assign gtf_ch_txphalignen = txphaligen;
//assign gtf_ch_txdlyen = txdlyen;
//assign gtf_ch_rxdlysreset = rxdlyreset;
//assign gtf_ch_rxphalignen = rxphalignen;
//assign gtf_ch_rxdlyen = rxdlyen;

//assign rxphinit =             //dont exist in GT wrapper
//assign sm_rxphinitdone =      //dont exist in GT wrapper 

  
  mac_standard_prbs  #(
	.WIDTH			(WIDTH),
	.PREABLE_BYTE	(PREABLE_BYTE)
) mac_standard_prbs_i (
	.txclk			(gtf_txusrclk2_out),
	.rxclk			(gtf_rxusrclk2_out),
	.txrst			(gtwiz_reset_tx),
	.rxrst			(gtwiz_reset_rx),
	.preable_en		(preable_en),
	.txen			(bert_en),
	.tlast_en		(tlast_en),
	.sync			(bert_sync),
	.error_counter_ce	(error_counter_ce),
	.det 			(bert_det_out),
	.test1 			(),
	.test2 			(),
	.pass			(bert_pass),
	.data_out		(bert_txdata),
	.pre_data_out	(bert_txaxistpre),
	.txaxistvalid	(txaxistvalid),
	.txaxistready	(txaxistready),
	.txgbseqstart	(txgbseqstart),
	.txaxistlast	(txaxistlast),
	.txaxissof      (),
	.data_in		(rxaxistdata),
	.rxaxistvalid	(rxaxistvalid)
	
	);
	
// use either CLEAR_FLAGS or RST for sticky flop CLR
assign flag_rst = CLEAR_FLAGS||BIST_RESET;

//defparam start_ff0.INIT = 0;
FDR start_ff0 (.Q(start_reg0), .D(START), .C(gtf_txusrclk2_out), .R(gtwiz_reset_tx));
//defparam start_ff1.INIT = 0;
FDR start_ff1 (.Q(start_retimed), .D(start_reg0), .C(gtf_txusrclk2_out), .R(gtwiz_reset_tx));

// bist counter 
defparam bist_counter.WIDTH = (COUNT_SIZE+1);
counter bist_counter (.clk(gtf_txusrclk2_out), .count(bist_count[COUNT_SIZE:0]), .reset(bist_cnt_rst), .enable(bist_cnt_en));


assign txdlysresetdone = gtf_ch_txdlysresetdone; 
assign txphinitdone = gtf_ch_txphinitdone;
assign txphaligndone = gtf_ch_txphaligndone;
assign txsyncdone = gtf_ch_txsyncdone;
assign rxphaligndone = gtf_ch_rxphaligndone;
assign rxdlysresetdone = gtf_ch_rxdlysresetdone;
assign rxsyncdone = gtf_ch_rxsyncdone;
assign rxphalignerr = gtf_ch_rxphalignerr;
assign statrxpkt = gtf_ch_statrxpkt;
assign statrxpkterr = gtf_ch_statrxpkterr;
assign statrxstatus = gtf_ch_statrxstatus;
assign statrxbadfcs = gtf_ch_statrxbadfcs;
assign statrxfcserr = gtf_ch_statrxfcserr;
assign stattxpkt = gtf_ch_stattxpkt;
assign stattxpkterr = gtf_ch_stattxpkterr;
assign stattxbadfcs = gtf_ch_stattxbadfcs;
assign stattxfcserr = gtf_ch_stattxfcserr;




//defparam txdlysresetdone_ff0.INIT = 0;
FDR txdlysresetdone_ff0 (.Q(txdlysresetdone_reg0), .D(txdlysresetdone), .C(gtf_txusrclk2_out), .R(gtwiz_reset_tx));
//defparam txdlysresetdone_ff1.INIT = 0;
FDR txdlysresetdone_ff1 (.Q(sm_txdlysresetdone), .D(txdlysresetdone_reg0), .C(gtf_txusrclk2_out), .R(gtwiz_reset_tx));
///defparam txphinitdone_ff0.INIT = 0;
FDR txphinitdone_ff0 (.Q(txphinitdone_reg0), .D(txphinitdone), .C(gtf_txusrclk2_out), .R(gtwiz_reset_tx));
//defparam txphinitdone_ff1.INIT = 0;
FDR txphinitdone_ff1 (.Q(sm_txphinitdone), .D(txphinitdone_reg0), .C(gtf_txusrclk2_out), .R(gtwiz_reset_tx));
//defparam txphaligndone_ff0.INIT = 0;
FDR txphaligndone_ff0 (.Q(txphaligndone_reg0), .D(txphaligndone), .C(gtf_txusrclk2_out), .R(gtwiz_reset_tx));
//defparam txphaligndone_ff1.INIT = 0;
FDR txphaligndone_ff1 (.Q(sm_txphaligndone), .D(txphaligndone_reg0), .C(gtf_txusrclk2_out), .R(gtwiz_reset_tx));
//defparam txsyncdone_ff0.INIT = 0;
FDR txsyncdone_ff0 (.Q(txsyncdone_reg0), .D(txsyncdone), .C(gtf_txusrclk2_out), .R(gtwiz_reset_tx));
//defparam txsyncdone_ff1.INIT = 0;
FDR txsyncdone_ff1 (.Q(sm_txsyncdone), .D(txsyncdone_reg0), .C(gtf_txusrclk2_out), .R(gtwiz_reset_tx));
//defparam rxdlysresetdone_ff0.INIT = 0;
FDR rxdlysresetdone_ff0 (.Q(rxdlysresetdone_reg0), .D(rxdlysresetdone), .C(gtf_rxusrclk2_out), .R(gtwiz_reset_rx));
//defparam rxdlysresetdone_ff1.INIT = 0;
FDR rxdlysresetdone_ff1 (.Q(sm_rxdlysresetdone), .D(rxdlysresetdone_reg0), .C(gtf_rxusrclk2_out), .R(gtwiz_reset_rx));
//defparam rxphaligndone_ff0.INIT = 0;
FDR rxphaligndone_ff0 (.Q(rxphaligndone_reg0), .D(rxphaligndone), .C(gtf_rxusrclk2_out), .R(gtwiz_reset_rx));
//defparam rxphaligndone_ff1.INIT = 0;
FDR rxphaligndone_ff1 (.Q(sm_rxphaligndone), .D(rxphaligndone_reg0), .C(gtf_rxusrclk2_out), .R(gtwiz_reset_rx));
//defparam rxsyncdone_ff0.INIT = 0;
FDR rxsyncdone_ff0 (.Q(rxsyncdone_reg0), .D(rxsyncdone), .C(gtf_rxusrclk2_out), .R(gtwiz_reset_rx));
//defparam rxsyncdone_ff1.INIT = 0;
FDR rxsyncdone_ff1 (.Q(sm_rxsyncdone), .D(rxsyncdone_reg0), .C(gtf_rxusrclk2_out), .R(gtwiz_reset_rx));
//defparam rxphalignerr_ff0.INIT = 0;
FDR rxphalignerr_ff0 (.Q(rxphalignerr_reg0), .D(rxphalignerr), .C(gtf_rxusrclk2_out), .R(gtwiz_reset_rx));
//defparam rxphalignerr_ff1.INIT = 0;
FDR rxphalignerr_ff1 (.Q(sm_rxphalignerr), .D(rxphalignerr_reg0), .C(gtf_rxusrclk2_out), .R(gtwiz_reset_rx));
///defparam rxphinitdone_ff0.INIT = 0;
FDR rxphinitdone_ff0 (.Q(rxphinitdone_reg0), .D(rxphinitdone), .C(rxusrclk), .R(gtwiz_reset_rx));
//defparam rxphinitdone_ff1.INIT = 0;
FDR rxphinitdone_ff1 (.Q(sm_rxphinitdone), .D(rxphinitdone_reg0), .C(rxusrclk), .R(gtwiz_reset_rx));


FDRE txphinit_sync0_ff (.Q(txphinit_reg), .D(txphinit), .CE(1'b1), .C(gtf_txusrclk2_out), .R(gtwiz_reset_tx));
FDRE txphinit_sync1_ff (.Q(txphinit_sync), .D(txphinit_reg), .CE(1'b1), .C(gtf_txusrclk2_out), .R(gtwiz_reset_tx));

FDRE txphalign_sync0_ff (.Q(txphalign_reg), .D(txphalign), .CE(1'b1), .C(gtf_txusrclk2_out), .R(gtwiz_reset_tx));
FDRE txphalign_sync1_ff (.Q(txphalign_sync), .D(txphalign_reg), .CE(1'b1), .C(gtf_txusrclk2_out), .R(gtwiz_reset_tx));

FDRE rxphalign_sync0_ff (.Q(rxphalign_reg), .D(rxphalign), .CE(1'b1), .C(gtf_rxusrclk2_out), .R(gtwiz_reset_rx));
FDRE rxphalign_sync1_ff (.Q(rxphalign_sync), .D(rxphalign_reg), .CE(1'b1), .C(gtf_rxusrclk2_out), .R(gtwiz_reset_rx));

  //re-time all input bert checker signal to rxusrclk domain and output to txusrclk domain into state machine
FDCE preable_en_ff0 (.Q(sm_preable_en_1), .D(sm_preable_en), .CE(1'b1), .C(gtf_rxusrclk2_out), .CLR(gtwiz_reset_rx));
FDCE preable_en_ff1 (.Q(preable_en), .D(sm_preable_en_1), .CE(1'b1), .C(gtf_rxusrclk2_out), .CLR(gtwiz_reset_rx));

FDCE bert_en_ff0 (.Q(sm_bert_en_1), .D(sm_bert_en), .CE(1'b1), .C(gtf_rxusrclk2_out), .CLR(gtwiz_reset_rx));
FDCE bert_en_ff1 (.Q(bert_en), .D(sm_bert_en_1), .CE(1'b1), .C(gtf_rxusrclk2_out), .CLR(gtwiz_reset_rx));

FDCE tlast_en_ff0 (.Q(sm_tlast_en_1), .D(sm_tlast_en), .CE(1'b1), .C(gtf_rxusrclk2_out), .CLR(gtwiz_reset_rx));
FDCE tlast_en_ff1 (.Q(tlast_en), .D(sm_tlast_en_1), .CE(1'b1), .C(gtf_rxusrclk2_out), .CLR(gtwiz_reset_rx));

FDCE bert_sync_ff0 (.Q(sm_bert_sync_1), .D(sm_bert_sync), .CE(1'b1), .C(gtf_rxusrclk2_out), .CLR(gtwiz_reset_rx));
FDCE bert_sync_ff1 (.Q(bert_sync), .D(sm_bert_sync_1), .CE(1'b1), .C(gtf_rxusrclk2_out), .CLR(gtwiz_reset_rx));

FDCE bert_error_ce_ff0 (.Q(sm_error_counter_ce_1), .D(sm_error_counter_ce), .CE(1'b1), .C(gtf_rxusrclk2_out), .CLR(gtwiz_reset_rx));
FDCE bert_error_ce_ff1 (.Q(error_counter_ce), .D(sm_error_counter_ce_1), .CE(1'b1), .C(gtf_rxusrclk2_out), .CLR(gtwiz_reset_rx));

FDCE bert_det_out_ff0 (.Q(bert_det_out_1), .D(bert_det_out), .CE(1'b1), .C(gtf_txusrclk2_out), .CLR(gtwiz_reset_tx));
FDCE bert_det_out_ff1 (.Q(sm_bert_det_out), .D(bert_det_out_1), .CE(1'b1), .C(gtf_txusrclk2_out), .CLR(gtwiz_reset_tx));

FDCE bert_pass_ff0 (.Q(bert_pass_1), .D(bert_pass), .CE(1'b1), .C(gtf_txusrclk2_out), .CLR(gtwiz_reset_tx));
FDCE bert_pass_ff1 (.Q(sm_bert_pass), .D(bert_pass_1), .CE(1'b1), .C(gtf_txusrclk2_out), .CLR(gtwiz_reset_tx));


FDCE statrxpkt_ff0 (.Q(statrxpkt_1), .D(statrxpkt), .CE(1'b1), .C(gtf_rxusrclk2_out), .CLR(gtwiz_reset_rx));
FDCE statrxpkt_ff1 (.Q(sm_statrxpkt), .D(statrxpkt_1), .CE(1'b1), .C(gtf_rxusrclk2_out), .CLR(gtwiz_reset_rx));

FDCE statrxpkterr_ff0 (.Q(statrxpkterr_1), .D(statrxpkterr), .CE(1'b1), .C(gtf_rxusrclk2_out), .CLR(gtwiz_reset_rx));
FDCE statrxpkterr_ff1 (.Q(sm_statrxpkterr), .D(statrxpkterr_1), .CE(1'b1), .C(gtf_rxusrclk2_out), .CLR(gtwiz_reset_rx));

FDCE statrxstatus_ff0 (.Q(statrxstatus_1), .D(statrxstatus), .CE(1'b1), .C(gtf_rxusrclk2_out), .CLR(gtwiz_reset_rx));
FDCE statrxstatus_ff1 (.Q(sm_statrxstatus), .D(statrxstatus_1), .CE(1'b1), .C(gtf_rxusrclk2_out), .CLR(gtwiz_reset_rx));

FDCE statrxbadfcs_ff0 (.Q(statrxbadfcs_1), .D(statrxbadfcs), .CE(1'b1), .C(gtf_rxusrclk2_out), .CLR(gtwiz_reset_rx));
FDCE statrxbadfcs_ff1 (.Q(sm_statrxbadfcs), .D(statrxbadfcs_1), .CE(1'b1), .C(gtf_rxusrclk2_out), .CLR(gtwiz_reset_rx));

FDCE statrxfcserr_ff0 (.Q(statrxfcserr_1), .D(statrxfcserr), .CE(1'b1), .C(gtf_rxusrclk2_out), .CLR(gtwiz_reset_rx));
FDCE statrxfcserr_ff1 (.Q(sm_statrxfcserr), .D(statrxfcserr_1), .CE(1'b1), .C(gtf_rxusrclk2_out), .CLR(gtwiz_reset_rx));

FDCE stattxpkt_ff0 (.Q(stattxpkt_1), .D(stattxpkt), .CE(1'b1), .C(gtf_txusrclk2_out), .CLR(gtwiz_reset_tx));
FDCE stattxpkt_ff1 (.Q(sm_stattxpkt), .D(stattxpkt_1), .CE(1'b1), .C(gtf_txusrclk2_out), .CLR(gtwiz_reset_tx));

FDCE stattxpkterr_ff0 (.Q(stattxpkterr_1), .D(stattxpkterr), .CE(1'b1), .C(gtf_txusrclk2_out), .CLR(gtwiz_reset_tx));
FDCE stattxpkterr_ff1 (.Q(sm_stattxpkterr), .D(stattxpkterr_1), .CE(1'b1), .C(gtf_txusrclk2_out), .CLR(gtwiz_reset_tx));

FDCE stattxbadfcs_ff0 (.Q(stattxbadfcs_1), .D(stattxbadfcs), .CE(1'b1), .C(gtf_txusrclk2_out), .CLR(gtwiz_reset_tx));
FDCE stattxbadfcs_ff1 (.Q(sm_stattxbadfcs), .D(stattxbadfcs_1), .CE(1'b1), .C(gtf_txusrclk2_out), .CLR(gtwiz_reset_tx));

FDCE stattxfcserr_ff0 (.Q(stattxfcserr_1), .D(stattxfcserr), .CE(1'b1), .C(gtf_txusrclk2_out), .CLR(gtwiz_reset_tx));
FDCE stattxfcserr_ff1 (.Q(sm_stattxfcserr), .D(stattxfcserr_1), .CE(1'b1), .C(gtf_txusrclk2_out), .CLR(gtwiz_reset_tx));
// synthesis attribute keep done_ff true
// done pin - sticky flag
//defparam done_ff.INIT = 0;
FDCE done_ff (.Q(DONE), .D(1'b1), .CE(sm_done), .C(gtf_txusrclk2_out), .CLR(gtwiz_reset_tx));

// data error pin - sticky error
// synthesis attribute keep data_passed_ff true
defparam data_passed_ff.INIT = 1'b0;
FDCE data_passed_ff (.Q(DATA_PASSED), .D(1'b1), .CE(~sm_data_error), .C(gtf_rxusrclk2_out), .CLR(gtwiz_reset_rx));



 
pma_mac_gtf_sm #(
	.NUM_OF_PACKETS (NUM_OF_PACKETS),
	.PREABLE_BYTE	(PREABLE_BYTE)
) state_machine (
  .CLK                 (gtf_txusrclk2_out), 
  .RST                 (gtwiz_reset_tx), 
  .START_MM            (), 
  .START               (start_retimed), 
  .BIST_COUNT          (bist_count), 
  .TXDLYSRESET	       (txdlysreset), 
  .TXDLYSRESETDONE     (sm_txdlysresetdone), 
  .TXPHINIT	      	   (txphinit), 
  .TXPHINITDONE	       (sm_txphinitdone),
  .TXPHALIGN	       (txphalign),
  .TXPHALIGNEN	       (txphaligen),
  .TXDLYEN 	      	   (txdlyen),
  .TXPHALIGNDONE       (sm_txphaligndone),
  .TXSYNCDONE     	   (sm_txsyncdone),
  //.RXDLYSRESET	      (rxdlyreset), 
  .RXDLYSRESETDONE     (sm_rxdlysresetdone), 
  .RXPHINIT	      	   (rxphinit), 
  .RXPHINITDONE	       (sm_rxphinitdone),
  .RXPHALIGN	       (rxphalign),
  .RXPHALIGNEN	       (rxphalignen),
  .RXDLYEN 	      	   (rxdlyen),
  .RXPHALIGNDONE       (sm_rxphaligndone),
  .RXSYNCDONE     	   (sm_rxsyncdone),
  .RXPHALIGNERR        (sm_rxphalignerr),   
  .GT_RESET            (),
  .BIST_CNT_EN         (bist_cnt_en), 
  .BIST_CNT_RST        (bist_cnt_rst),  
  .PREAMBLE_EN         (sm_preable_en),
  .TLAST_EN            (sm_tlast_en),
  .BERT_EN             (sm_bert_en),
  .BERT_SYNC           (sm_bert_sync),
  .BERT_PASS           (sm_bert_pass),
  .BERT_DET_OUT        (sm_bert_det_out), 
  .STATRXPKT       	   (sm_statrxpkt),
  .STATRXPKTERR        (sm_statrxpkterr),  
  .STATRXSTATUS        (sm_statrxstatus),
  .STATRXBADFCS        (sm_statrxbadfcs),
  .STATRXFCSERR        (sm_statrxfcserr),
  .STATTXPKT       	   (sm_stattxpkt),
  .STATTXPKTERR        (sm_stattxpkterr),  
  .STATTXBADFCS        (sm_stattxbadfcs),
  .STATTXFCSERR        (sm_stattxfcserr),
  
  .ERROR_COUNT_EN      (sm_error_counter_ce),
  .DONE                (sm_done), 
  .STATE               (int_state[4:0]),
  .DATA_ERROR          (sm_data_error),
  .packet_count        (packet_count),
  .STATRXPKTERR_STICKY (STATRXPKTERR_vio),
  .STATRXSTATUS_STICKY (STATRXSTATUS_vio),
  .STATTXPKTERR_STICKY (STATTXPKTERR_vio),
  .STATTXBADFCS_STICKY (STATTXBADFCS_vio),
  .STATTXFCSERR_STICKY (STATTXFCSERR_vio),
  .STATRXBADFCS_STICKY (STATRXBADFCS_vio),
  .STATRXFCSERR_STICKY (STATRXFCSERR_vio),
  .wa_complete_flg     (wa_complete_flg)
);
 

 assign pass = (packet_count==NUM_OF_PACKETS & bert_pass) ? 1'b1 : 1'b0;

 always @(posedge gtf_txusrclk2_out) begin
    if (gtwiz_reset_tx) 
        state_check_r <= 1'b0;
    else if ((packet_count== NUM_OF_PACKETS)&&(int_state == 5'h1c))
        state_check_r <= 1'b1;
    end
*/
  reg  [4:0][15:0] gtf_ch_rxaxistdata_d;
  reg  [7:0]       gtf_ch_rxaxistpre_d;
  reg              gtf_ch_rxaxistvalid_d;
  reg  [7:0][1:0]  gtf_ch_rxaxistsof_d;
  
  reg  [4:0][15:0] gtf_ch_txaxistdata_d;
  reg  [7:0]       gtf_ch_txaxistpre_d;
  reg              gtf_ch_txaxistvalid_d;
  reg              gtf_ch_txaxistready_d;
  reg              bad_start_cw = 1'b0; 
  reg              vnc_rx_custom_preamble_en;      
  
  integer i;
  always @(posedge gtf_rxusrclk2_out) 
  begin
    if (gtwiz_reset_all_in)
    begin
      for (i = 0; i < 5; i = i + 1) 
        gtf_ch_rxaxistdata_d[i] <= 16'h0;
        
      bad_start_cw          <= 1'b0; 
      gtf_ch_rxaxistpre_d   <= 8'h0;
      gtf_ch_rxaxistvalid_d <= 1'b0;
      gtf_ch_rxaxistsof_d   <= 16'h0;
      vnc_rx_custom_preamble_en <= 1'b0;
    end
    
    else
    begin
      gtf_ch_rxaxistsof_d[0] <= gtf_ch_rxaxistsof;
      for (i = 1; i < 8; i = i + 1)
      begin
        gtf_ch_rxaxistsof_d[i] <= gtf_ch_rxaxistsof_d[i-1];
      end
      
      gtf_ch_rxaxistvalid_d <= gtf_ch_rxaxistvalid;
      gtf_ch_rxaxistpre_d   <= gtf_ch_rxaxistpre;
      vnc_rx_custom_preamble_en <= vnc_rx_custom_preamble_en_in; //EG
      //preamble capture
      gtf_ch_rxaxistdata_d[$size(gtf_ch_rxaxistdata_d)-1] <= gtf_ch_rxaxistdata[15:0];
      if ((gtf_ch_rxaxistpre_d != 8'h00) && gtf_ch_rxaxistvalid_d)
      begin
        for (i = 1; i < 5; i = i + 1)
        begin
          gtf_ch_rxaxistdata_d[$size(gtf_ch_rxaxistdata_d)-1-i] <= gtf_ch_rxaxistdata_d[$size(gtf_ch_rxaxistdata_d)-i];
        end
      end
      
      //sof codeword checker. different lag times for different custom preamble settings
      if ( (gtf_ch_rxaxistsof_d[0] == 2'h3) && gtf_ch_rxaxistvalid_d)
      begin
        bad_start_cw <= 1'b1;
      end
      
      if(vnc_rx_custom_preamble_en)
      begin
        if ( ((gtf_ch_rxaxistsof_d[1] == 2'h2) && ~gtf_ch_rxaxistvalid_d) || ((gtf_ch_rxaxistsof_d[3] == 2'h3) && ~gtf_ch_rxaxistvalid_d) )     
          bad_start_cw <= 1'b1;
      end  
      else
      begin  
      if ( ((gtf_ch_rxaxistsof_d[5] == 2'h2) && ~gtf_ch_rxaxistvalid_d) || ((gtf_ch_rxaxistsof_d[7] == 2'h3) && ~gtf_ch_rxaxistvalid_d) )         
          bad_start_cw <= 1'b1;
      end
    end 
  end 

  always @(posedge gtf_txusrclk2_out) 
  begin
    if (gtwiz_reset_all_in)
    begin
      for (i = 0; i < 5; i = i + 1) 
        gtf_ch_txaxistdata_d[i] <= 16'h0;
		
      gtf_ch_txaxistpre_d   <= 8'h0;
      gtf_ch_txaxistvalid_d <= 1'b0;
      gtf_ch_txaxistready_d <= 1'b0;
    end
    
    else
    begin
      gtf_ch_txaxistdata_d[$size(gtf_ch_txaxistdata_d)-1] <= gtf_ch_txaxistdata[15:0];
      gtf_ch_txaxistvalid_d <= gtf_ch_txaxistvalid;
      gtf_ch_txaxistpre_d   <= gtf_ch_txaxistpre;
      gtf_ch_txaxistready_d   <= gtf_ch_txaxistready;
      if ( (gtf_ch_txaxistpre_d != 8'h00) && gtf_ch_txaxistvalid_d && gtf_ch_txaxistready_d)
      begin
        for (i = 1; i < 5; i = i + 1)
        begin
          gtf_ch_txaxistdata_d[$size(gtf_ch_txaxistdata_d)-1-i] <= gtf_ch_txaxistdata_d[$size(gtf_ch_txaxistdata_d)-i];
        end
      end
    end 
  end 
/////////////////VIO Beginning ////////////////////
  wire [1:0]  sm_buffbypass_tx_ila;
  wire [2:0]  sm_buffbypass_rx_mm;
  wire [15:0] manual_cnt_vio;
  wire        workaround_bypass_vio;
  wire [63:0] gtf_ch_tx_preamble_vio;
  wire [63:0] gtf_ch_rx_preamble_vio;
  assign gtf_ch_rx_preamble_vio = gtf_ch_rxaxistdata_d[3:0];
  assign gtf_ch_tx_preamble_vio = gtf_ch_txaxistdata_d[3:0];
   
  vio_0 vio_inst (
  .clk  (freerun_clk),

  .probe_in0    (gtf_ch_gttxreset           ), 
  .probe_in1    (gtf_ch_txpmareset          ), 
  .probe_in2    (gtf_ch_txpcsreset          ), 
  .probe_in3    (gtf_ch_gtrxreset           ), 
  .probe_in4    (gtf_ch_txresetdone         ), 
  .probe_in5    (gtf_ch_rxpmareset          ), 
  .probe_in6    (gtf_ch_rxdfelpmreset       ),
  .probe_in7    (gtf_ch_eyescanreset        ),
  .probe_in8    (gtf_ch_rxpcsreset          ), 
  .probe_in9    (gtf_ch_rxresetdone         ), 
  .probe_in10   (hb_gtwiz_reset_all_in      ), 
  .probe_in11   (gtwiz_reset_all_in         ), 
  .probe_in12   (gtf_cm_qpll0lock           ), 
  .probe_in13   (gtf_cm_qpll1lock           ), 
  .probe_in14   (gtf_ch_gtpowergood         ), 
  .probe_in15   (wa_complete_flg            ),
  .probe_in16   (sm_buffbypass_rx_mm        ),  // [2:0]
  .probe_in17   (gttxreset                  ),
  .probe_in18   (gtf_ch_rxsyncdone          ),
  .probe_in19   (gtf_ch_txsyncdone          ),
  .probe_in20   (gtf_ch_dmonitorout         ),  // [15:0]
  .probe_in21   (sm_buffbypass_tx_ila       ),  // [1:0]
  .probe_in22   (gtf_ch_rxphalign           ),
  .probe_in23   (manual_cnt_vio             ),  // [15:0]
  .probe_in24   (gtf_cm_qpll0lock           ),
  
  .probe_out0   (hb_gtwiz_reset_all_vio),
  .probe_out1   (workaround_bypass_vio), //defaults to 0 for workaround mode
  .probe_out2   (vio_gtf_ch_gttxreset),
  .probe_out3   (vio_gtf_ch_txpmareset),
  .probe_out4   (vio_gtf_ch_txpcsreset),
  .probe_out5   (vio_gtf_ch_gtrxreset),
  .probe_out6   (vio_gtf_ch_txuserrdy),
  .probe_out7   (vio_gtf_ch_rxpmareset),
  .probe_out8   (vio_gtf_ch_rxdfelpmreset),
  .probe_out9   (vio_gtf_ch_eyescanreset),
  .probe_out10  (vio_gtf_ch_rxpcsreset),
  .probe_out11  (vio_gtf_ch_rxuserrdy),
  .probe_out12  (vio_gtf_cm_qpll0reset),
  .probe_out13  (vio_gtf_cm_qpll1reset),
  .probe_out14  (force_bad_align_vio)

  );
  
  /////////////////    VIO End    ////////////////////
  /////////////////// ila beginning /////////////////////////

  ila_0 ila_inst (
    .clk(freerun_clk), // input wire clk
    .probe0(gtf_ch_dmonitorout),      // input wire [15:0] probe0  
    .probe1(wa_complete_flg),         // input wire [0:0]  probe1 
    .probe2(gtf_ch_txsyncdone),       // input wire [0:0]  probe2 
    .probe3(gtf_ch_rxsyncdone),       // input wire [0:0]  probe3 
    .probe4(gtf_ch_rxresetdone),      // input wire [0:0]  probe4 
    .probe5(gtf_ch_rxpmaresetdone),   // input wire [0:0]  probe5 
    .probe6(sm_buffbypass_rx_mm),     // input wire [2:0]  probe6 
    .probe7(gtf_ch_txaxistdata),      // input wire [63:0] probe7 
    .probe8(gtf_ch_rxaxistdata),      // input wire [63:0] probe8 
    .probe9(sm_buffbypass_tx_ila),    // input wire [1:0]  probe9 
    .probe10(gtf_ch_txresetdone),     // input wire [0:0]  probe10 
    .probe11(gtf_ch_txpmaresetdone),  // input wire [0:0]  probe11
    .probe12(gtf_ch_txphalign),       // input wire [0:0]  probe12 
    .probe13(gtf_ch_txphaligndone),   // input wire [0:0]  probe13
    .probe14(gtf_ch_rxphalign),       // input wire [0:0]  probe14 
    .probe15(manual_cnt_vio),         // input wire [15:0] probe15 
    .probe16(gtf_ch_txaxistpre),      // input wire [7:0]  probe16 
    .probe17(gtf_ch_rxaxistpre),      // input wire [7:0]  probe17
    .probe18(gtf_ch_txaxistlast),     // input wire [7:0]  probe18 
    .probe19(gtf_ch_rxaxistlast),     // input wire [7:0]  probe19 
    .probe20(gtf_ch_txaxistvalid),    // input wire [0:0]  probe20 
    .probe21(gtf_ch_rxaxistvalid),    // input wire [0:0]  probe21 
    .probe22(gtf_ch_txaxistsof),      // input wire [1:0]  probe22 
    .probe23(gtf_ch_rxaxistsof),      // input wire [1:0]  probe23 
    .probe24(gtf_ch_tx_preamble_vio), // input wire [63:0] probe24
    .probe25(gtf_ch_rx_preamble_vio), // input wire [63:0] probe25
    .probe26(bad_start_cw),           // input wire [0:0]  probe26
    .probe27(gtf_ch_rxaxistsof_d)     // input wire [13:0] probe27
    );
  //////////////////// ila end /////////////////////////
  
  
  reg        int_block_lock;
  reg        int_gt_locked;
  reg [15:0] int_rx_received;
  reg [15:0] int_tx_ack;


  assign rx_gt_locked_led              =int_gt_locked;
  assign rx_block_lock_led             =int_block_lock;
  
  
  always @(posedge freerun_clk)
  begin
    if (gtwiz_reset_all_in)
    begin
      int_rx_received      <= 16'h0;
      int_tx_ack           <= 16'h0;
      int_gt_locked        <= 1'b0;
      int_block_lock       <= 1'b0;
    end
    else
    begin
      int_rx_received      <= (gtf_ch_rxaxistvalid==1'b1) ? 16'h0 : int_rx_received+1'b1;
      int_tx_ack           <= (gtf_ch_txaxistready==1'b1) ? 16'h0 : int_tx_ack+1'b1;
      int_gt_locked        <= (int_tx_ack>= 16'h8fff)? 1'b0 : (int_gt_locked || (gtf_ch_rxaxistvalid==1'b1));
      int_block_lock       <= (int_rx_received>= 16'h8fff)? 1'b0 : (int_block_lock || (gtf_ch_txaxistready==1'b1));
    end
  end


// VNC - AXI-Lite integration

  // Pipeline the stats signals from GTFMAC
  reg   [3:0]   gtf_ch_statrxbytes_R;
  reg           gtf_ch_statrxpkt_R;
  reg           gtf_ch_statrxpkterr_R;
  reg           gtf_ch_statrxtruncated_R;
  reg           gtf_ch_statrxbadfcs_R;
  reg           gtf_ch_statrxstompedfcs_R;
  reg           gtf_ch_statrxunicast_R;
  reg           gtf_ch_statrxmulticast_R;
  reg           gtf_ch_statrxbroadcast_R;
  reg           gtf_ch_statrxvlan_R;
  reg           gtf_ch_statrxinrangeerr_R;
  reg           gtf_ch_statrxbadcode_R;
  reg           gtf_ch_statrxbadpreamble_R;
  reg           stat_rx_framing_err_R;

  reg        stat_rx_unicast_R;
  reg        stat_rx_multicast_R;
  reg        stat_rx_broadcast_R;
  reg        stat_rx_vlan_R;
  reg        stat_rx_inrangeerr_R;
  reg        stat_rx_bad_fcs_R;

  reg [ 3:0] stat_rx_total_bytes_R;
  reg [13:0] stat_rx_total_err_bytes_R;
  reg [13:0] stat_rx_total_good_bytes_R;
  reg        stat_rx_total_packets_R;
  reg        stat_rx_total_good_packets_R;
  reg        stat_rx_packet_64_bytes_R;
  reg        stat_rx_packet_65_127_bytes_R;
  reg        stat_rx_packet_128_255_bytes_R;
  reg        stat_rx_packet_256_511_bytes_R;
  reg        stat_rx_packet_512_1023_bytes_R;
  reg        stat_rx_packet_1024_1518_bytes_R;
  reg        stat_rx_packet_1519_1522_bytes_R;
  reg        stat_rx_packet_1523_1548_bytes_R;
  reg        stat_rx_packet_1549_2047_bytes_R;
  reg        stat_rx_packet_2048_4095_bytes_R;
  reg        stat_rx_packet_4096_8191_bytes_R;
  reg        stat_rx_packet_8192_9215_bytes_R;
  reg        stat_rx_oversize_R;
  reg        stat_rx_undersize_R;
  reg        stat_rx_toolong_R;
  reg        stat_rx_packet_small_R;
  reg        stat_rx_packet_large_R;
  reg        stat_rx_user_pause_R;
  reg        stat_rx_pause_R;
  reg        stat_rx_jabber_R;
  reg        stat_rx_fragment_R;
  reg        stat_rx_packet_bad_fcs_R;

  reg        stat_tx_bad_fcs_R;
  reg        stat_tx_broadcast_R;
  reg        stat_tx_multicast_R;
  reg        stat_tx_unicast_R;
  reg        stat_tx_vlan_R;

  reg  [ 3:0] stat_tx_total_bytes_R;
  reg  [13:0] stat_tx_total_err_bytes_R;
  reg  [13:0] stat_tx_total_good_bytes_R;
  reg         stat_tx_total_packets_R;
  reg         stat_tx_total_good_packets_R;
  reg         stat_tx_packet_64_bytes_R;
  reg         stat_tx_packet_65_127_bytes_R;
  reg         stat_tx_packet_128_255_bytes_R;
  reg         stat_tx_packet_256_511_bytes_R;
  reg         stat_tx_packet_512_1023_bytes_R;
  reg         stat_tx_packet_1024_1518_bytes_R;
  reg         stat_tx_packet_1519_1522_bytes_R;
  reg         stat_tx_packet_1523_1548_bytes_R;
  reg         stat_tx_packet_1549_2047_bytes_R;
  reg         stat_tx_packet_2048_4095_bytes_R;
  reg         stat_tx_packet_4096_8191_bytes_R;
  reg         stat_tx_packet_8192_9215_bytes_R;
  reg         stat_tx_packet_small_R;
  reg         stat_tx_packet_large_R;
  reg         stat_tx_frame_error_R;

  wire [31 : 0] m0_axi_awaddr;
  wire [2 : 0] m0_axi_awprot;
  wire m0_axi_awvalid;
  wire m0_axi_awready;
  wire [31 : 0] m0_axi_wdata;
  wire [3 : 0] m0_axi_wstrb;
  wire m0_axi_wvalid;
  wire m0_axi_wready;
  wire [1 : 0] m0_axi_bresp;
  wire m0_axi_bvalid;
  wire m0_axi_bready;
  wire [31 : 0] m0_axi_araddr;
  wire [2 : 0] m0_axi_arprot;
  wire m0_axi_arvalid;
  wire m0_axi_arready;
  wire [31 : 0] m0_axi_rdata;
  wire [1 : 0] m0_axi_rresp;
  wire m0_axi_rvalid;
  wire m0_axi_rready;

  wire [31 : 0] m1_axi_awaddr;
  wire [2 : 0] m1_axi_awprot;
  wire m1_axi_awvalid;
  wire m1_axi_awready;
  wire [31 : 0] m1_axi_wdata;
  wire [3 : 0] m1_axi_wstrb;
  wire m1_axi_wvalid;
  wire m1_axi_wready;
  wire [1 : 0] m1_axi_bresp;
  wire m1_axi_bvalid;
  wire m1_axi_bready;
  wire [31 : 0] m1_axi_araddr;
  wire [2 : 0] m1_axi_arprot;
  wire m1_axi_arvalid;
  wire m1_axi_arready;
  wire [31 : 0] m1_axi_rdata;
  wire [1 : 0] m1_axi_rresp;
  wire m1_axi_rvalid;
  wire m1_axi_rready;

  wire  ctl_tx_data_rate;
  wire  ctl_tx_ignore_fcs;
  wire  ctl_tx_fcs_ins_enable;
  wire  ctl_rx_data_rate;
  wire  ctl_rx_ignore_fcs;
  wire  [7:0] ctl_rx_min_packet_len;
  wire  [15:0] ctl_rx_max_packet_len;

  wire stat_rx_block_lock;
  wire stat_rx_framing_err = gtf_ch_statrxframingerr;
  wire stat_rx_hi_ber;
  wire stat_rx_status;
  wire stat_rx_valid_ctrl_code;
  wire stat_rx_bad_code;

  wire stat_rx_total_packets;
  wire stat_rx_total_good_packets;
  wire [3:0] stat_rx_total_bytes;
  wire [13:0] stat_rx_total_good_bytes;
  wire stat_rx_packet_small;
  wire stat_rx_jabber;
  wire stat_rx_packet_large;
  wire stat_rx_oversize;
  wire stat_rx_undersize;
  wire stat_rx_toolong;
  wire stat_rx_fragment;
  wire stat_rx_packet_64_bytes;
  wire stat_rx_packet_65_127_bytes;
  wire stat_rx_packet_128_255_bytes;
  wire stat_rx_packet_256_511_bytes;
  wire stat_rx_packet_512_1023_bytes;
  wire stat_rx_packet_1024_1518_bytes;
  wire stat_rx_packet_1519_1522_bytes;
  wire stat_rx_packet_1523_1548_bytes;
  wire [13:0] stat_rx_total_err_bytes;
  wire stat_rx_bad_fcs;
  wire stat_rx_packet_bad_fcs;
  wire stat_rx_stomped_fcs;
  wire stat_rx_packet_1549_2047_bytes;
  wire stat_rx_packet_2048_4095_bytes;
  wire stat_rx_packet_4096_8191_bytes;
  wire stat_rx_packet_8192_9215_bytes;
  wire stat_rx_unicast;
  wire stat_rx_multicast;
  wire stat_rx_broadcast;
  wire stat_rx_vlan;
  wire stat_rx_pause;
  wire stat_rx_user_pause;
  wire stat_rx_inrangeerr;
  wire stat_rx_bad_preamble;
  wire stat_rx_bad_sfd;
  wire stat_rx_got_signal_os;
  wire stat_rx_truncated;
  wire [8:0] stat_rx_pause_valid;
  wire [15:0] stat_rx_pause_quanta0;
  wire [15:0] stat_rx_pause_quanta1;
  wire [15:0] stat_rx_pause_quanta2;
  wire [15:0] stat_rx_pause_quanta3;
  wire [15:0] stat_rx_pause_quanta4;
  wire [15:0] stat_rx_pause_quanta5;
  wire [15:0] stat_rx_pause_quanta6;
  wire [15:0] stat_rx_pause_quanta7;
  wire [15:0] stat_rx_pause_quanta8;
  wire [8:0] stat_rx_pause_req;

  wire stat_rx_local_fault;
  wire stat_rx_remote_fault;
  wire stat_rx_internal_local_fault;
  wire stat_rx_received_local_fault;

  wire stat_tx_total_packets;
  wire [3:0] stat_tx_total_bytes;
  wire stat_tx_total_good_packets;
  wire [13:0] stat_tx_total_good_bytes;
  wire stat_tx_packet_64_bytes;
  wire stat_tx_packet_65_127_bytes;
  wire stat_tx_packet_128_255_bytes;
  wire stat_tx_packet_256_511_bytes;
  wire stat_tx_packet_512_1023_bytes;
  wire stat_tx_packet_1024_1518_bytes;
  wire stat_tx_packet_1519_1522_bytes;
  wire stat_tx_packet_1523_1548_bytes;
  wire stat_tx_packet_large;
  wire stat_tx_packet_small;
  wire [13:0] stat_tx_total_err_bytes;
  wire stat_tx_packet_1549_2047_bytes;
  wire stat_tx_packet_2048_4095_bytes;
  wire stat_tx_packet_4096_8191_bytes;
  wire stat_tx_packet_8192_9215_bytes;
  wire stat_tx_unicast;
  wire stat_tx_multicast;
  wire stat_tx_broadcast;
  wire stat_tx_vlan;
  wire stat_tx_bad_fcs;
  wire stat_tx_frame_error;

  wire rx_clk = gtf_rxusrclk2_out;
  wire tx_clk = gtf_txusrclk2_out;
  wire tx_resetn = gtf_ch_txresetdone; // VNC
  wire rx_resetn = gtf_ch_rxresetdone; // VNC


  gtfmac_wrapper_axi_if_soft_top i_axi_if_soft_top (

    .ctl_local_loopback (ctl_local_loopback),
    .ctl_gt_reset_all (ctl_gt_reset_all),
    .ctl_gt_tx_reset (gtf_ch_gttxreset),
    .ctl_gt_rx_reset (gtf_ch_gtrxreset),
    .ctl_tx_send_lfi (ctl_tx_send_lfi_axi),
    .ctl_tx_send_rfi (ctl_tx_send_rfi_axi),
    .ctl_tx_send_idle (ctl_tx_send_idle_axi),

    .stat_rx_hi_ber (gtf_ch_statrxhiber),
    .stat_rx_status (gtf_ch_statrxstatus),
    .stat_rx_clk_align (1'b0),  // TODO
    .stat_rx_bit_slip (1'b0),   // TODO
    .stat_rx_pkt_err (gtf_ch_statrxpkterr),
    .stat_rx_bad_preamble (gtf_ch_statrxbadpreamble_R),
    .stat_rx_bad_sfd (gtf_ch_statrxbadsfd),
    .stat_rx_got_signal_os (gtf_ch_statrxgotsignalos),
    .stat_rx_local_fault (gtf_ch_statrxlocalfault),
    .stat_rx_remote_fault (gtf_ch_statrxremotefault),
    .stat_rx_internal_local_fault (gtf_ch_statrxinternallocalfault),
    .stat_rx_received_local_fault (gtf_ch_statrxreceivedlocalfault),

    .stat_rx_framing_err (stat_rx_framing_err_R),
    .stat_rx_bad_code (gtf_ch_statrxbadcode_R),
    .stat_rx_total_packets (stat_rx_total_packets_R),
    .stat_rx_total_good_packets (stat_rx_total_good_packets_R),
    .stat_rx_total_bytes (stat_rx_total_bytes_R),
    .stat_rx_total_good_bytes (stat_rx_total_good_bytes_R),
    .stat_rx_packet_small (stat_rx_packet_small_R),
    .stat_rx_jabber (stat_rx_jabber_R),
    .stat_rx_packet_large (stat_rx_packet_large_R),
    .stat_rx_oversize (stat_rx_oversize_R),
    .stat_rx_undersize (stat_rx_undersize_R),
    .stat_rx_toolong (stat_rx_toolong_R),
    .stat_rx_fragment (stat_rx_fragment_R),
    .stat_rx_packet_64_bytes (stat_rx_packet_64_bytes_R),
    .stat_rx_packet_65_127_bytes (stat_rx_packet_65_127_bytes_R),
    .stat_rx_packet_128_255_bytes (stat_rx_packet_128_255_bytes_R),
    .stat_rx_packet_256_511_bytes (stat_rx_packet_256_511_bytes_R),
    .stat_rx_packet_512_1023_bytes (stat_rx_packet_512_1023_bytes_R),
    .stat_rx_packet_1024_1518_bytes (stat_rx_packet_1024_1518_bytes_R),
    .stat_rx_packet_1519_1522_bytes (stat_rx_packet_1519_1522_bytes_R),
    .stat_rx_packet_1523_1548_bytes (stat_rx_packet_1523_1548_bytes_R),
    .stat_rx_total_err_bytes (stat_rx_total_err_bytes_R),
    .stat_rx_bad_fcs (stat_rx_bad_fcs_R),
    .stat_rx_packet_bad_fcs (stat_rx_packet_bad_fcs_R),
    .stat_rx_stomped_fcs (gtf_ch_statrxstompedfcs_R),
    .stat_rx_packet_1549_2047_bytes (stat_rx_packet_1549_2047_bytes_R),
    .stat_rx_packet_2048_4095_bytes (stat_rx_packet_2048_4095_bytes_R),
    .stat_rx_packet_4096_8191_bytes (stat_rx_packet_4096_8191_bytes_R),
    .stat_rx_packet_8192_9215_bytes (stat_rx_packet_8192_9215_bytes_R),
    .stat_rx_unicast (stat_rx_unicast_R),
    .stat_rx_multicast (stat_rx_multicast_R),
    .stat_rx_broadcast (stat_rx_broadcast_R),
    .stat_rx_vlan (stat_rx_vlan_R),
    .stat_rx_pause (stat_rx_pause_R),
    .stat_rx_user_pause (stat_rx_user_pause_R),
    .stat_rx_inrangeerr (stat_rx_inrangeerr_R),
    .stat_rx_truncated (gtf_ch_statrxtruncated_R),
    .stat_tx_total_packets (stat_tx_total_packets_R),
    .stat_tx_total_bytes (stat_tx_total_bytes_R),
    .stat_tx_total_good_packets (stat_tx_total_good_packets_R),
    .stat_tx_total_good_bytes (stat_tx_total_good_bytes_R),
    .stat_tx_packet_64_bytes (stat_tx_packet_64_bytes_R),
    .stat_tx_packet_65_127_bytes (stat_tx_packet_65_127_bytes_R),
    .stat_tx_packet_128_255_bytes (stat_tx_packet_128_255_bytes_R),
    .stat_tx_packet_256_511_bytes (stat_tx_packet_256_511_bytes_R),
    .stat_tx_packet_512_1023_bytes (stat_tx_packet_512_1023_bytes_R),
    .stat_tx_packet_1024_1518_bytes (stat_tx_packet_1024_1518_bytes_R),
    .stat_tx_packet_1519_1522_bytes (stat_tx_packet_1519_1522_bytes_R),
    .stat_tx_packet_1523_1548_bytes (stat_tx_packet_1523_1548_bytes_R),
    .stat_tx_packet_large (stat_tx_packet_large_R),
    .stat_tx_packet_small (stat_tx_packet_small_R),
    .stat_tx_total_err_bytes (stat_tx_total_err_bytes_R),
    .stat_tx_packet_1549_2047_bytes (stat_tx_packet_1549_2047_bytes_R),
    .stat_tx_packet_2048_4095_bytes (stat_tx_packet_2048_4095_bytes_R),
    .stat_tx_packet_4096_8191_bytes (stat_tx_packet_4096_8191_bytes_R),
    .stat_tx_packet_8192_9215_bytes (stat_tx_packet_8192_9215_bytes_R),
    .stat_tx_unicast (stat_tx_unicast_R),
    .stat_tx_multicast (stat_tx_multicast_R),
    .stat_tx_broadcast (stat_tx_broadcast_R),
    .stat_tx_vlan (stat_tx_vlan_R),
    .stat_tx_bad_fcs (stat_tx_bad_fcs_R),
    .stat_tx_frame_error (stat_tx_frame_error_R),

    .rx_clk ( rx_clk ),
    .tx_clk ( tx_clk ),
    .rx_resetn ( rx_resetn ),
    .tx_resetn ( tx_resetn ),

    .rx_resetn_out( rx_reset_axi_not_sync ),
    .tx_resetn_out( tx_reset_axi_not_sync),

    .s_axi_aclk (aclk),
    .s_axi_aresetn (aresetn),
    .s_axi_awaddr (m1_axi_awaddr),
    .s_axi_awvalid (m1_axi_awvalid),
    .s_axi_awready (m1_axi_awready),
    .s_axi_wdata (m1_axi_wdata),
    .s_axi_wstrb (m1_axi_wstrb),
    .s_axi_wvalid (m1_axi_wvalid),
    .s_axi_wready (m1_axi_wready),
    .s_axi_bresp (m1_axi_bresp),
    .s_axi_bvalid (m1_axi_bvalid),
    .s_axi_bready (m1_axi_bready),
    .s_axi_araddr (m1_axi_araddr),
    .s_axi_arvalid (m1_axi_arvalid),
    .s_axi_arready (m1_axi_arready),
    .s_axi_rdata (m1_axi_rdata),
    .s_axi_rresp (m1_axi_rresp),
    .s_axi_rvalid (m1_axi_rvalid),
    .s_axi_rready (m1_axi_rready),
    .pm_tick (1'b0)     // TODO
  );

  always @ (posedge rx_clk or negedge rx_resetn) begin
   
    if (!rx_resetn) begin

        gtf_ch_statrxbytes_R       <= 'd0;
        gtf_ch_statrxpkt_R         <= 'd0;
        gtf_ch_statrxpkterr_R      <= 'd0;
        gtf_ch_statrxtruncated_R   <= 'd0;
        gtf_ch_statrxbadfcs_R      <= 'd0;
        gtf_ch_statrxstompedfcs_R  <= 'd0;
        gtf_ch_statrxunicast_R     <= 'd0;
        gtf_ch_statrxmulticast_R   <= 'd0;
        gtf_ch_statrxbroadcast_R   <= 'd0;
        gtf_ch_statrxvlan_R        <= 'd0;
        gtf_ch_statrxinrangeerr_R  <= 'd0;
        gtf_ch_statrxbadcode_R     <= 'd0;
        gtf_ch_statrxbadpreamble_R <= 'd0;
        stat_rx_framing_err_R      <= 'd0;

        stat_rx_unicast_R                   <= 'd0;
        stat_rx_multicast_R                 <= 'd0;
        stat_rx_broadcast_R                 <= 'd0;
        stat_rx_vlan_R                      <= 'd0;
        stat_rx_inrangeerr_R                <= 'd0;
        stat_rx_bad_fcs_R                   <= 'd0;

        stat_rx_total_bytes_R               <= 'd0;
        stat_rx_total_err_bytes_R           <= 'd0;
        stat_rx_total_good_bytes_R          <= 'd0;
        stat_rx_total_packets_R             <= 'd0;
        stat_rx_total_good_packets_R        <= 'd0;
        stat_rx_packet_64_bytes_R           <= 'd0;
        stat_rx_packet_65_127_bytes_R       <= 'd0;
        stat_rx_packet_128_255_bytes_R      <= 'd0;
        stat_rx_packet_256_511_bytes_R      <= 'd0;
        stat_rx_packet_512_1023_bytes_R     <= 'd0;
        stat_rx_packet_1024_1518_bytes_R    <= 'd0;
        stat_rx_packet_1519_1522_bytes_R    <= 'd0;
        stat_rx_packet_1523_1548_bytes_R    <= 'd0;
        stat_rx_packet_1549_2047_bytes_R    <= 'd0;
        stat_rx_packet_2048_4095_bytes_R    <= 'd0;
        stat_rx_packet_4096_8191_bytes_R    <= 'd0;
        stat_rx_packet_8192_9215_bytes_R    <= 'd0;
        stat_rx_oversize_R                  <= 'd0;
        stat_rx_undersize_R                 <= 'd0;
        stat_rx_toolong_R                   <= 'd0;
        stat_rx_packet_small_R              <= 'd0;
        stat_rx_packet_large_R              <= 'd0;
        stat_rx_user_pause_R                <= 'd0;
        stat_rx_pause_R                     <= 'd0;
        stat_rx_jabber_R                    <= 'd0;
        stat_rx_fragment_R                  <= 'd0;
        stat_rx_packet_bad_fcs_R            <= 'd0;

    end
    else begin

        gtf_ch_statrxbytes_R       <= gtf_ch_statrxbytes;
        gtf_ch_statrxpkt_R         <= gtf_ch_statrxpkt;
        gtf_ch_statrxpkterr_R      <= gtf_ch_statrxpkterr;
        gtf_ch_statrxtruncated_R   <= gtf_ch_statrxtruncated;
        gtf_ch_statrxbadfcs_R      <= gtf_ch_statrxbadfcs;
        gtf_ch_statrxstompedfcs_R  <= gtf_ch_statrxstompedfcs;
        gtf_ch_statrxunicast_R     <= gtf_ch_statrxunicast;
        gtf_ch_statrxmulticast_R   <= gtf_ch_statrxmulticast;
        gtf_ch_statrxbroadcast_R   <= gtf_ch_statrxbroadcast;
        gtf_ch_statrxvlan_R        <= gtf_ch_statrxvlan;
        gtf_ch_statrxinrangeerr_R  <= gtf_ch_statrxinrangeerr;
        gtf_ch_statrxbadcode_R     <= gtf_ch_statrxbadcode;
        gtf_ch_statrxbadpreamble_R <= gtf_ch_statrxbadpreamble;

        stat_rx_unicast_R                   <= stat_rx_unicast;
        stat_rx_multicast_R                 <= stat_rx_multicast;
        stat_rx_broadcast_R                 <= stat_rx_broadcast;
        stat_rx_vlan_R                      <= stat_rx_vlan;
        stat_rx_inrangeerr_R                <= stat_rx_inrangeerr;
        stat_rx_bad_fcs_R                   <= stat_rx_bad_fcs;
        stat_rx_framing_err_R               <= stat_rx_framing_err;

        stat_rx_total_bytes_R               <= stat_rx_total_bytes;
        stat_rx_total_err_bytes_R           <= stat_rx_total_err_bytes;
        stat_rx_total_good_bytes_R          <= stat_rx_total_good_bytes;
        stat_rx_total_packets_R             <= stat_rx_total_packets;
        stat_rx_total_good_packets_R        <= stat_rx_total_good_packets;
        stat_rx_packet_64_bytes_R           <= stat_rx_packet_64_bytes;
        stat_rx_packet_65_127_bytes_R       <= stat_rx_packet_65_127_bytes;
        stat_rx_packet_128_255_bytes_R      <= stat_rx_packet_128_255_bytes;
        stat_rx_packet_256_511_bytes_R      <= stat_rx_packet_256_511_bytes;
        stat_rx_packet_512_1023_bytes_R     <= stat_rx_packet_512_1023_bytes;
        stat_rx_packet_1024_1518_bytes_R    <= stat_rx_packet_1024_1518_bytes;
        stat_rx_packet_1519_1522_bytes_R    <= stat_rx_packet_1519_1522_bytes;
        stat_rx_packet_1523_1548_bytes_R    <= stat_rx_packet_1523_1548_bytes;
        stat_rx_packet_1549_2047_bytes_R    <= stat_rx_packet_1549_2047_bytes;
        stat_rx_packet_2048_4095_bytes_R    <= stat_rx_packet_2048_4095_bytes;
        stat_rx_packet_4096_8191_bytes_R    <= stat_rx_packet_4096_8191_bytes;
        stat_rx_packet_8192_9215_bytes_R    <= stat_rx_packet_8192_9215_bytes;
        stat_rx_oversize_R                  <= stat_rx_oversize;
        stat_rx_undersize_R                 <= stat_rx_undersize;
        stat_rx_toolong_R                   <= stat_rx_toolong;
        stat_rx_packet_small_R              <= stat_rx_packet_small;
        stat_rx_packet_large_R              <= stat_rx_packet_large;
        stat_rx_user_pause_R                <= stat_rx_user_pause;
        stat_rx_pause_R                     <= stat_rx_pause;
        stat_rx_jabber_R                    <= stat_rx_jabber;
        stat_rx_fragment_R                  <= stat_rx_fragment;
        stat_rx_packet_bad_fcs_R            <= stat_rx_packet_bad_fcs;

    end

  end

  always @ (posedge tx_clk or negedge tx_resetn) begin

    if (!tx_resetn) begin

        stat_tx_bad_fcs_R                   <= 'd0;
        stat_tx_broadcast_R                 <= 'd0;
        stat_tx_multicast_R                 <= 'd0;
        stat_tx_unicast_R                   <= 'd0;
        stat_tx_vlan_R                      <= 'd0;

        stat_tx_total_bytes_R               <= 'd0;
        stat_tx_total_err_bytes_R           <= 'd0;
        stat_tx_total_good_bytes_R          <= 'd0;
        stat_tx_total_packets_R             <= 'd0;
        stat_tx_total_good_packets_R        <= 'd0;
        stat_tx_packet_64_bytes_R           <= 'd0;
        stat_tx_packet_65_127_bytes_R       <= 'd0;
        stat_tx_packet_128_255_bytes_R      <= 'd0;
        stat_tx_packet_256_511_bytes_R      <= 'd0;
        stat_tx_packet_512_1023_bytes_R     <= 'd0;
        stat_tx_packet_1024_1518_bytes_R    <= 'd0;
        stat_tx_packet_1519_1522_bytes_R    <= 'd0;
        stat_tx_packet_1523_1548_bytes_R    <= 'd0;
        stat_tx_packet_1549_2047_bytes_R    <= 'd0;
        stat_tx_packet_2048_4095_bytes_R    <= 'd0;
        stat_tx_packet_4096_8191_bytes_R    <= 'd0;
        stat_tx_packet_8192_9215_bytes_R    <= 'd0;
        stat_tx_packet_small_R              <= 'd0;
        stat_tx_packet_large_R              <= 'd0;
        stat_tx_frame_error_R               <= 'd0;

    end
    else begin

        stat_tx_bad_fcs_R                   <= stat_tx_bad_fcs;
        stat_tx_broadcast_R                 <= stat_tx_broadcast;
        stat_tx_multicast_R                 <= stat_tx_multicast;
        stat_tx_unicast_R                   <= stat_tx_unicast;
        stat_tx_vlan_R                      <= stat_tx_vlan;

        stat_tx_total_bytes_R               <= stat_tx_total_bytes;
        stat_tx_total_err_bytes_R           <= stat_tx_total_err_bytes;
        stat_tx_total_good_bytes_R          <= stat_tx_total_good_bytes;
        stat_tx_total_packets_R             <= stat_tx_total_packets;
        stat_tx_total_good_packets_R        <= stat_tx_total_good_packets;
        stat_tx_packet_64_bytes_R           <= stat_tx_packet_64_bytes;
        stat_tx_packet_65_127_bytes_R       <= stat_tx_packet_65_127_bytes;
        stat_tx_packet_128_255_bytes_R      <= stat_tx_packet_128_255_bytes;
        stat_tx_packet_256_511_bytes_R      <= stat_tx_packet_256_511_bytes;
        stat_tx_packet_512_1023_bytes_R     <= stat_tx_packet_512_1023_bytes;
        stat_tx_packet_1024_1518_bytes_R    <= stat_tx_packet_1024_1518_bytes;
        stat_tx_packet_1519_1522_bytes_R    <= stat_tx_packet_1519_1522_bytes;
        stat_tx_packet_1523_1548_bytes_R    <= stat_tx_packet_1523_1548_bytes;
        stat_tx_packet_1549_2047_bytes_R    <= stat_tx_packet_1549_2047_bytes;
        stat_tx_packet_2048_4095_bytes_R    <= stat_tx_packet_2048_4095_bytes;
        stat_tx_packet_4096_8191_bytes_R    <= stat_tx_packet_4096_8191_bytes;
        stat_tx_packet_8192_9215_bytes_R    <= stat_tx_packet_8192_9215_bytes;
        stat_tx_packet_small_R              <= stat_tx_packet_small;
        stat_tx_packet_large_R              <= stat_tx_packet_large;
        stat_tx_frame_error_R               <= stat_tx_frame_error;

    end

  end
   

  gtfmac_wrapper_wrapper_stats_gasket i_wrapper_stats_gasket (
    .tx_axis_tpoison  (gtf_ch_txaxistpoison),
    .tx_axis_tready   (gtf_ch_txaxistready ),
    .tx_axis_tlast    (gtf_ch_txaxistlast  ),
    .tx_axis_tterm    (gtf_ch_txaxistterm  ),

  // connect these ctrl to output from axi_custom_crossbar_gtfmac for GTF
  // since the mac_cfg ports will be gone
    .ctl_rx_data_rate (ctl_rx_data_rate),
    .ctl_rx_ignore_fcs (ctl_rx_ignore_fcs),
    .ctl_rx_min_packet_len (ctl_rx_min_packet_len),
    .ctl_rx_max_packet_len (ctl_rx_max_packet_len),
    .ctl_tx_data_rate (ctl_tx_data_rate),
    .ctl_tx_fcs_ins_enable (ctl_tx_fcs_ins_enable),
    .ctl_tx_ignore_fcs (ctl_tx_ignore_fcs),
    .ctl_tx_packet_framing_enable (1'b0),   // deprecated, always 0

    .stat_rx_total_packets (stat_rx_total_packets),
    .stat_rx_total_good_packets (stat_rx_total_good_packets),
    .stat_rx_total_bytes (stat_rx_total_bytes),
    .stat_rx_total_good_bytes (stat_rx_total_good_bytes),
    .stat_rx_packet_small (stat_rx_packet_small),
    .stat_rx_jabber (stat_rx_jabber),
    .stat_rx_packet_large (stat_rx_packet_large),
    .stat_rx_oversize (stat_rx_oversize),
    .stat_rx_undersize (stat_rx_undersize),
    .stat_rx_toolong (stat_rx_toolong),
    .stat_rx_fragment (stat_rx_fragment),
    .stat_rx_packet_64_bytes (stat_rx_packet_64_bytes),
    .stat_rx_packet_65_127_bytes (stat_rx_packet_65_127_bytes),
    .stat_rx_packet_128_255_bytes (stat_rx_packet_128_255_bytes),
    .stat_rx_packet_256_511_bytes (stat_rx_packet_256_511_bytes),
    .stat_rx_packet_512_1023_bytes (stat_rx_packet_512_1023_bytes),
    .stat_rx_packet_1024_1518_bytes (stat_rx_packet_1024_1518_bytes),
    .stat_rx_packet_1519_1522_bytes (stat_rx_packet_1519_1522_bytes),
    .stat_rx_packet_1523_1548_bytes (stat_rx_packet_1523_1548_bytes),
    .stat_rx_total_err_bytes (stat_rx_total_err_bytes),
    .stat_rx_bad_fcs (stat_rx_bad_fcs),
    .stat_rx_packet_bad_fcs (stat_rx_packet_bad_fcs),
    .stat_rx_packet_1549_2047_bytes (stat_rx_packet_1549_2047_bytes),
    .stat_rx_packet_2048_4095_bytes (stat_rx_packet_2048_4095_bytes),
    .stat_rx_packet_4096_8191_bytes (stat_rx_packet_4096_8191_bytes),
    .stat_rx_packet_8192_9215_bytes (stat_rx_packet_8192_9215_bytes),
    .stat_rx_unicast (stat_rx_unicast),
    .stat_rx_multicast (stat_rx_multicast),
    .stat_rx_broadcast (stat_rx_broadcast),
    .stat_rx_vlan (stat_rx_vlan),
    .stat_rx_pause (stat_rx_pause),
    .stat_rx_user_pause (stat_rx_user_pause),
    .stat_rx_inrangeerr (stat_rx_inrangeerr),
    .stat_rx_pause_valid (stat_rx_pause_valid),
    .stat_rx_pause_quanta0 (stat_rx_pause_quanta0),
    .stat_rx_pause_quanta1 (stat_rx_pause_quanta1),
    .stat_rx_pause_quanta2 (stat_rx_pause_quanta2),
    .stat_rx_pause_quanta3 (stat_rx_pause_quanta3),
    .stat_rx_pause_quanta4 (stat_rx_pause_quanta4),
    .stat_rx_pause_quanta5 (stat_rx_pause_quanta5),
    .stat_rx_pause_quanta6 (stat_rx_pause_quanta6),
    .stat_rx_pause_quanta7 (stat_rx_pause_quanta7),
    .stat_rx_pause_quanta8 (stat_rx_pause_quanta8),
    .stat_rx_pause_req (stat_rx_pause_req),
    .stat_tx_total_packets (stat_tx_total_packets),
    .stat_tx_total_bytes (stat_tx_total_bytes),
    .stat_tx_total_good_packets (stat_tx_total_good_packets),
    .stat_tx_total_good_bytes (stat_tx_total_good_bytes),
    .stat_tx_packet_64_bytes (stat_tx_packet_64_bytes),
    .stat_tx_packet_65_127_bytes (stat_tx_packet_65_127_bytes),
    .stat_tx_packet_128_255_bytes (stat_tx_packet_128_255_bytes),
    .stat_tx_packet_256_511_bytes (stat_tx_packet_256_511_bytes),
    .stat_tx_packet_512_1023_bytes (stat_tx_packet_512_1023_bytes),
    .stat_tx_packet_1024_1518_bytes (stat_tx_packet_1024_1518_bytes),
    .stat_tx_packet_1519_1522_bytes (stat_tx_packet_1519_1522_bytes),
    .stat_tx_packet_1523_1548_bytes (stat_tx_packet_1523_1548_bytes),
    .stat_tx_packet_large (stat_tx_packet_large),
    .stat_tx_packet_small (stat_tx_packet_small),
    .stat_tx_total_err_bytes (stat_tx_total_err_bytes),
    .stat_tx_packet_1549_2047_bytes (stat_tx_packet_1549_2047_bytes),
    .stat_tx_packet_2048_4095_bytes (stat_tx_packet_2048_4095_bytes),
    .stat_tx_packet_4096_8191_bytes (stat_tx_packet_4096_8191_bytes),
    .stat_tx_packet_8192_9215_bytes (stat_tx_packet_8192_9215_bytes),
    .stat_tx_unicast (stat_tx_unicast),
    .stat_tx_multicast (stat_tx_multicast),
    .stat_tx_broadcast (stat_tx_broadcast),
    .stat_tx_vlan (stat_tx_vlan),
    .stat_tx_bad_fcs (stat_tx_bad_fcs),
    .stat_tx_frame_error (stat_tx_frame_error),

    .gtfmac_stat_rx_bytes       (gtf_ch_statrxbytes_R),
    .gtfmac_stat_rx_pkt         (gtf_ch_statrxpkt_R),
    .gtfmac_stat_rx_pkt_err     (gtf_ch_statrxpkterr_R),
    .gtfmac_stat_rx_truncated   (gtf_ch_statrxtruncated_R),
    .gtfmac_stat_rx_bad_fcs     (gtf_ch_statrxbadfcs_R),
    .gtfmac_stat_rx_stomped_fcs (gtf_ch_statrxstompedfcs_R),
    .gtfmac_stat_rx_unicast     (gtf_ch_statrxunicast_R),
    .gtfmac_stat_rx_broadcast   (gtf_ch_statrxbroadcast_R),
    .gtfmac_stat_rx_multicast   (gtf_ch_statrxmulticast_R),
    .gtfmac_stat_rx_vlan        (gtf_ch_statrxvlan_R),
    .gtfmac_stat_rx_inrangeerr  (gtf_ch_statrxinrangeerr_R),

    .gtfmac_rx_pause_quanta     (gtf_ch_statrxpausequanta),
    .gtfmac_rx_pause_req        (gtf_ch_statrxpausereq)   ,
    .gtfmac_rx_pause_valid      (gtf_ch_statrxpausevalid[0]) ,

    .gtfmac_stat_tx_bytes       (gtf_ch_stattxbytes),
    .gtfmac_stat_tx_pkt         (gtf_ch_stattxpkt),
    .gtfmac_stat_tx_pkt_err     (gtf_ch_stattxpkterr),
    .gtfmac_stat_tx_bad_fcs     (gtf_ch_stattxbadfcs),
    .gtfmac_stat_tx_unicast     (gtf_ch_stattxunicast),
    .gtfmac_stat_tx_broadcast   (gtf_ch_stattxbroadcast),
    .gtfmac_stat_tx_multicast   (gtf_ch_stattxmulticast),
    .gtfmac_stat_tx_vlan        (gtf_ch_stattxvlan),
                                
    .rx_clk                     (rx_clk),
    .tx_clk                     (tx_clk),
    .rx_reset                   (rx_resetn),
    .tx_reset                   (tx_resetn)
  );


// END VNC


// END VNC
  always @(posedge freerun_clk) begin
    if (gtwiz_reset_all_in)
      link_status_out <= 1'b0;
    else
      link_status_out <= (rx_gt_locked_led && rx_block_lock_led);
  end


  always @(posedge freerun_clk) begin
    if (link_down_latched_reset_in)
      link_down_latched_out <= 1'b0;
    else if (!link_status_out)
      link_down_latched_out <= 1'b1;
  end
  
  assign link_maintained = ((~link_down_latched_out) && (link_status_out));

  localparam COMMON_CLOCK = 1;
  wire tx_rdy_int; //common clock
  
  gtfwizard_0_example_gtwiz_buffbypass_tx #(
    .P_TOTAL_NUMBER_OF_CHANNELS (1),
    .P_MASTER_CHANNEL_POINTER   (0)
  ) gtwiz_buffbypass_tx_inst (
    .gtwiz_buffbypass_tx_clk_in        (freerun_clk),
    .gtwiz_buffbypass_tx_reset_in      (~gtf_ch_txpmaresetdone), 
    .gtwiz_buffbypass_tx_start_user_in (COMMON_CLOCK ? tx_rdy_int : 1'b0), //common clock was 1'b0
    .gtwiz_buffbypass_tx_resetdone_in  (gtf_ch_txresetdone),

    .gtwiz_buffbypass_tx_done_out      (),
    .gtwiz_buffbypass_tx_error_out     (),
    .sm_buffbypass_tx_out              (sm_buffbypass_tx_ila),
    .txphaligndone_in                  (gtf_ch_txphaligndone),
    .txphinitdone_in                   (gtf_ch_txphinitdone),
    .txdlysresetdone_in                (gtf_ch_txdlysresetdone),
    .txsyncout_in                      (gtf_ch_txsyncout),
    .txsyncdone_in                     (gtf_ch_txsyncdone),
    .txphdlyreset_out                  (gtf_ch_txphdlyreset),
    .txphalign_out                     (gtf_ch_txphalign),
    .txphalignen_out                   (gtf_ch_txphalignen),
    .txphdlypd_out                     (), //EG 6/26 gtf_ch_txphdlypd
    .txphinit_out                      (gtf_ch_txphinit),
    .txphovrden_out                    (gtf_ch_txphovrden),
    .txdlysreset_out                   (gtf_ch_txdlysreset),
    .txdlybypass_out                   (gtf_ch_txdlybypass),
    .txdlyen_out                       (gtf_ch_txdlyen),
    .txdlyovrden_out                   (gtf_ch_txdlyovrden),
    .txphdlytstclk_out                 (gtf_ch_txphdlytstclk),
    .txdlyhold_out                     (gtf_ch_txdlyhold),
    .txdlyupdown_out                   (gtf_ch_txdlyupdown),
    .txsyncmode_out                    (gtf_ch_txsyncmode),
    .txsyncallin_out                   (gtf_ch_txsyncallin),
    .txsyncin_out                      (gtf_ch_txsyncin)
  );
  
  
  gtfwizard_0_example_gtwiz_buffbypass_rx gtwiz_buffbypass_rx_inst (
    .gtwiz_rx_clk_in                   (gtf_ch_drpclk), //EG originally gtf_rxusrclk2_out 6/29 gtf_ch_drpclk
    .gtwiz_rx_reset_in                 (~gtf_ch_rxpmaresetdone), //EG deleted ~gtf_ch_rxpmaresetdone or gtwiz_buffbypass_rx_reset 6/29
    .gtwiz_rx_start_user_in            (1'b0),
    .gtwiz_rx_resetdone_in             (gtf_ch_rxresetdone),
    .dmon_bad_align_in                 (gtf_ch_dmonitorout[3]), //1 indicates bad MM align which is desirable for WA
    .drp_reconfig_done_in              (drp_reconfig_done), 
    .workaround_bypass_in              (workaround_bypass_vio),
    .force_bad_align_in                (force_bad_align_vio),
    .drp_reconfig_rdy_out              (drp_reconfig_rdy), 
    .drp_switch_am_out                 (AM_switch), 
	.sm_buffbypass_rx_mm_out           (sm_buffbypass_rx_mm),	
	.manual_cnt_out                    (manual_cnt_vio), //EG 7/28													 
    
    .gtwiz_rx_done_out                 (wa_complete_flg),
    .gtwiz_rx_error_out                (),
    
    .rxphaligndone_in                  (gtf_ch_rxphaligndone),
    .rxphalignerr_in                   (gtf_ch_rxphalignerr), //7/28
    .rxdlysresetdone_in                (gtf_ch_rxdlysresetdone),
    .rxsyncout_in                      (gtf_ch_rxsyncout),
    .rxsyncdone_in                     (gtf_ch_rxsyncdone),
    .rxphdlyreset_out                  (gtf_ch_rxphdlyreset),
    .rxphalign_out                     (gtf_ch_rxphalign),
    .rxphovrden_out                    (gtf_ch_rxphovrden),
    .rxphalignen_out                   (gtf_ch_rxphalignen),
    .rxphdlypd_out                     (), //EG 6/26 gtf_ch_rxphdlypd
    .rxdlysreset_out                   (gtf_ch_rxdlysreset),
    .rxdlybypass_out                   (gtf_ch_rxdlybypass),
    .rxdlyen_out                       (gtf_ch_rxdlyen),
    .rxdlyovrden_out                   (gtf_ch_rxdlyovrden),
    .rxsyncmode_out                    (gtf_ch_rxsyncmode),
    .rxsyncallin_out                   (gtf_ch_rxsyncallin),
    .rxsyncin_out                      (gtf_ch_rxsyncin),
    .tx_rdy_out                        (tx_rdy_int) //common clock
  );


gtfwizard_0 u_gtf_wiz_ip_top (
.gtwiz_reset_clk_freerun_in                (gtwiz_reset_clk_freerun_in                ),
.gtwiz_reset_all_in                        (gtwiz_reset_all_in                        ),
.gtwiz_reset_tx_pll_and_datapath_in        (gtwiz_reset_tx_pll_and_datapath_in        ),
.gtwiz_reset_tx_datapath_in                (gtwiz_reset_tx_datapath_in                ),
.gtwiz_reset_rx_pll_and_datapath_in        (gtwiz_reset_rx_pll_and_datapath_in        ),
.gtwiz_reset_rx_datapath_in                (gtwiz_reset_rx_datapath_in                ),
.gtwiz_reset_rx_cdr_stable_out             (gtwiz_reset_rx_cdr_stable_out             ),
.gtwiz_reset_tx_done_out                   (gtwiz_reset_tx_done_out                   ),
.gtwiz_reset_rx_done_out                   (gtwiz_reset_rx_done_out                   ),
.plllock_tx_in                             (plllock_tx_in                             ),
.plllock_rx_in                             (plllock_rx_in                             ),
.gtf_ch_cdrstepdir                         (gtf_ch_cdrstepdir                         ),
.gtf_ch_cdrstepsq                          (gtf_ch_cdrstepsq                          ),
.gtf_ch_cdrstepsx                          (gtf_ch_cdrstepsx                          ),
.gtf_ch_cfgreset                           (gtf_ch_cfgreset                           ),
.gtf_ch_clkrsvd0                           (gtf_ch_clkrsvd0                           ),
.gtf_ch_clkrsvd1                           (gtf_ch_clkrsvd1                           ),
.gtf_ch_cpllfreqlock                       (gtf_ch_cpllfreqlock                       ),
.gtf_ch_cplllockdetclk                     (gtf_ch_cplllockdetclk                     ),
.gtf_ch_cplllocken                         (gtf_ch_cplllocken                         ),
.gtf_ch_cpllpd                             (gtf_ch_cpllpd                             ),
.gtf_ch_cpllreset                          (gtf_ch_cpllreset                          ),
.gtf_ch_ctltxresendpause                   (gtf_ch_ctltxresendpause                   ),
.gtf_ch_ctltxsendidle                      (gtf_ch_ctltxsendidle                      ),
.gtf_ch_ctltxsendlfi                       (gtf_ch_ctltxsendlfi                       ),
.gtf_ch_ctltxsendrfi                       (gtf_ch_ctltxsendrfi                       ),
.gtf_ch_dmonfiforeset                      (gtf_ch_dmonfiforeset                      ),
.gtf_ch_dmonitorclk                        (gtf_ch_dmonitorclk                        ),
.gtf_ch_drpclk                             (gtf_ch_drpclk                             ),
.gtf_ch_drpen                              (gtf_ch_drpen                              ),
.gtf_ch_drprst                             (gtf_ch_drprst                             ),
.gtf_ch_drpwe                              (gtf_ch_drpwe                              ),
.gtf_ch_eyescanreset                       (gtf_ch_eyescanreset | vio_gtf_ch_eyescanreset | vnc_gtf_ch_eyescanreset ),
.gtf_ch_eyescantrigger                     (gtf_ch_eyescantrigger                     ),
.gtf_ch_freqos                             (gtf_ch_freqos                             ),
.gtf_ch_gtfrxn                             (gtf_ch_gtfrxn                             ),
.gtf_ch_gtfrxp                             (gtf_ch_gtfrxp                             ),
.gtf_ch_gtgrefclk                          (gtf_ch_gtgrefclk                          ),
.gtf_ch_gtnorthrefclk0                     (gtf_ch_gtnorthrefclk0                     ),
.gtf_ch_gtnorthrefclk1                     (gtf_ch_gtnorthrefclk1                     ),
.gtf_ch_gtrefclk0                          (gtf_ch_gtrefclk0                          ),
.gtf_ch_gtrefclk1                          (gtf_ch_gtrefclk1                          ),
.gtf_ch_gtrxreset                          (gtf_ch_gtrxreset | vio_gtf_ch_gtrxreset | vnc_gtf_ch_gtrxreset ),
.gtf_ch_gtrxresetsel                       (gtf_ch_gtrxresetsel                       ),
.gtf_ch_gtsouthrefclk0                     (gtf_ch_gtsouthrefclk0                     ),
.gtf_ch_gtsouthrefclk1                     (gtf_ch_gtsouthrefclk1                     ),
.gtf_ch_gttxreset                          (gtf_ch_gttxreset | vio_gtf_ch_gttxreset | vnc_gtf_ch_gttxreset ),
.gtf_ch_gttxresetsel                       (gtf_ch_gttxresetsel                       ),
.gtf_ch_incpctrl                           (gtf_ch_incpctrl                           ),
.gtf_ch_qpll0clk                           (gtf_ch_qpll0clk                           ),
.gtf_ch_qpll0freqlock                      (gtf_ch_qpll0freqlock                      ),
.gtf_ch_qpll0refclk                        (gtf_ch_qpll0refclk                        ),
.gtf_ch_qpll1clk                           (gtf_ch_qpll1clk                           ),
.gtf_ch_qpll1freqlock                      (gtf_ch_qpll1freqlock                      ),
.gtf_ch_qpll1refclk                        (gtf_ch_qpll1refclk                        ),
.gtf_ch_resetovrd                          (gtf_ch_resetovrd                          ),
.gtf_ch_rxafecfoken                        (gtf_ch_rxafecfoken                        ),
.gtf_ch_rxcdrfreqreset                     (gtf_ch_rxcdrfreqreset                     ),
.gtf_ch_rxcdrhold                          (gtf_ch_rxcdrhold                          ),
.gtf_ch_rxcdrovrden                        (gtf_ch_rxcdrovrden                        ),
.gtf_ch_rxcdrreset                         (gtf_ch_rxcdrreset                         ),
.gtf_ch_rxckcalreset                       (gtf_ch_rxckcalreset                       ),
.gtf_ch_rxdfeagchold                       (gtf_ch_rxdfeagchold                       ),
.gtf_ch_rxdfeagcovrden                     (gtf_ch_rxdfeagcovrden                     ),
.gtf_ch_rxdfecfokfen                       (gtf_ch_rxdfecfokfen                       ),
.gtf_ch_rxdfecfokfpulse                    (gtf_ch_rxdfecfokfpulse                    ),
.gtf_ch_rxdfecfokhold                      (gtf_ch_rxdfecfokhold                      ),
.gtf_ch_rxdfecfokovren                     (gtf_ch_rxdfecfokovren                     ),
.gtf_ch_rxdfekhhold                        (gtf_ch_rxdfekhhold                        ),
.gtf_ch_rxdfekhovrden                      (gtf_ch_rxdfekhovrden                      ),
.gtf_ch_rxdfelfhold                        (gtf_ch_rxdfelfhold                        ),
.gtf_ch_rxdfelfovrden                      (gtf_ch_rxdfelfovrden                      ),
.gtf_ch_rxdfelpmreset                      (gtf_ch_rxdfelpmreset | vio_gtf_ch_rxdfelpmreset | vnc_gtf_ch_rxdfelpmreset ),
.gtf_ch_rxdfetap10hold                     (gtf_ch_rxdfetap10hold                     ),
.gtf_ch_rxdfetap10ovrden                   (gtf_ch_rxdfetap10ovrden                   ),
.gtf_ch_rxdfetap11hold                     (gtf_ch_rxdfetap11hold                     ),
.gtf_ch_rxdfetap11ovrden                   (gtf_ch_rxdfetap11ovrden                   ),
.gtf_ch_rxdfetap12hold                     (gtf_ch_rxdfetap12hold                     ),
.gtf_ch_rxdfetap12ovrden                   (gtf_ch_rxdfetap12ovrden                   ),
.gtf_ch_rxdfetap13hold                     (gtf_ch_rxdfetap13hold                     ),
.gtf_ch_rxdfetap13ovrden                   (gtf_ch_rxdfetap13ovrden                   ),
.gtf_ch_rxdfetap14hold                     (gtf_ch_rxdfetap14hold                     ),
.gtf_ch_rxdfetap14ovrden                   (gtf_ch_rxdfetap14ovrden                   ),
.gtf_ch_rxdfetap15hold                     (gtf_ch_rxdfetap15hold                     ),
.gtf_ch_rxdfetap15ovrden                   (gtf_ch_rxdfetap15ovrden                   ),
.gtf_ch_rxdfetap2hold                      (gtf_ch_rxdfetap2hold                      ),
.gtf_ch_rxdfetap2ovrden                    (gtf_ch_rxdfetap2ovrden                    ),
.gtf_ch_rxdfetap3hold                      (gtf_ch_rxdfetap3hold                      ),
.gtf_ch_rxdfetap3ovrden                    (gtf_ch_rxdfetap3ovrden                    ),
.gtf_ch_rxdfetap4hold                      (gtf_ch_rxdfetap4hold                      ),
.gtf_ch_rxdfetap4ovrden                    (gtf_ch_rxdfetap4ovrden                    ),
.gtf_ch_rxdfetap5hold                      (gtf_ch_rxdfetap5hold                      ),
.gtf_ch_rxdfetap5ovrden                    (gtf_ch_rxdfetap5ovrden                    ),
.gtf_ch_rxdfetap6hold                      (gtf_ch_rxdfetap6hold                      ),
.gtf_ch_rxdfetap6ovrden                    (gtf_ch_rxdfetap6ovrden                    ),
.gtf_ch_rxdfetap7hold                      (gtf_ch_rxdfetap7hold                      ),
.gtf_ch_rxdfetap7ovrden                    (gtf_ch_rxdfetap7ovrden                    ),
.gtf_ch_rxdfetap8hold                      (gtf_ch_rxdfetap8hold                      ),
.gtf_ch_rxdfetap8ovrden                    (gtf_ch_rxdfetap8ovrden                    ),
.gtf_ch_rxdfetap9hold                      (gtf_ch_rxdfetap9hold                      ),
.gtf_ch_rxdfetap9ovrden                    (gtf_ch_rxdfetap9ovrden                    ),
.gtf_ch_rxdfeuthold                        (gtf_ch_rxdfeuthold                        ),
.gtf_ch_rxdfeutovrden                      (gtf_ch_rxdfeutovrden                      ),
.gtf_ch_rxdfevphold                        (gtf_ch_rxdfevphold                        ),
.gtf_ch_rxdfevpovrden                      (gtf_ch_rxdfevpovrden                      ),
.gtf_ch_rxdfexyden                         (gtf_ch_rxdfexyden                         ),
.gtf_ch_rxdlybypass                        (gtf_ch_rxdlybypass                        ),
.gtf_ch_rxdlyen                            (gtf_ch_rxdlyen                            ),
.gtf_ch_rxdlyovrden                        (gtf_ch_rxdlyovrden                        ),
.gtf_ch_rxdlysreset                        (gtf_ch_rxdlysreset                        ),
.gtf_ch_rxlpmen                            (gtf_ch_rxlpmen                            ),
.gtf_ch_rxlpmgchold                        (gtf_ch_rxlpmgchold                        ),
.gtf_ch_rxlpmgcovrden                      (gtf_ch_rxlpmgcovrden                      ),
.gtf_ch_rxlpmhfhold                        (gtf_ch_rxlpmhfhold                        ),
.gtf_ch_rxlpmhfovrden                      (gtf_ch_rxlpmhfovrden                      ),
.gtf_ch_rxlpmlfhold                        (gtf_ch_rxlpmlfhold                        ),
.gtf_ch_rxlpmlfklovrden                    (gtf_ch_rxlpmlfklovrden                    ),
.gtf_ch_rxlpmoshold                        (gtf_ch_rxlpmoshold                        ),
.gtf_ch_rxlpmosovrden                      (gtf_ch_rxlpmosovrden                      ),
.gtf_ch_rxoscalreset                       (gtf_ch_rxoscalreset                       ),
.gtf_ch_rxoshold                           (gtf_ch_rxoshold                           ),
.gtf_ch_rxosovrden                         (gtf_ch_rxosovrden                         ),
.gtf_ch_rxpcsreset                         (gtf_ch_rxpcsreset | vio_gtf_ch_rxpcsreset | vnc_gtf_ch_rxpcsreset ),
.gtf_ch_rxphalign                          (gtf_ch_rxphalign                          ),
.gtf_ch_rxphalignen                        (gtf_ch_rxphalignen                        ),
.gtf_ch_rxphdlypd                          (gtf_ch_rxphdlypd                          ),
.gtf_ch_rxphdlyreset                       (gtf_ch_rxphdlyreset                       ),
.gtf_ch_rxpmareset                         (gtf_ch_rxpmareset | vio_gtf_ch_rxpmareset | vnc_gtf_ch_rxpmareset ),
.gtf_ch_rxpolarity                         (gtf_ch_rxpolarity                         ),
.gtf_ch_rxprbscntreset                     (gtf_ch_rxprbscntreset                     ),
.gtf_ch_rxprogdivreset                     (gtf_ch_rxprogdivreset                     ),
.gtf_ch_rxslipoutclk                       (gtf_ch_rxslipoutclk                       ),
.gtf_ch_rxslippma                          (gtf_ch_rxslippma                          ),
.gtf_ch_rxsyncallin                        (gtf_ch_rxsyncallin                        ),
.gtf_ch_rxsyncin                           (gtf_ch_rxsyncin                           ),
.gtf_ch_rxsyncmode                         (gtf_ch_rxsyncmode                         ),
.gtf_ch_rxtermination                      (gtf_ch_rxtermination                      ),
.gtf_ch_rxuserrdy                          (vio_gtf_ch_rxuserrdy | vnc_gtf_ch_rxuserrdy),
.gtf_ch_txaxisterr                         (gtf_ch_txaxisterr                         ),
.gtf_ch_txaxistpoison                      (gtf_ch_txaxistpoison                      ),
.gtf_ch_txaxistvalid                       (gtf_ch_txaxistvalid                       ),
.gtf_ch_txdccforcestart                    (gtf_ch_txdccforcestart                    ),
.gtf_ch_txdccreset                         (gtf_ch_txdccreset                         ),
.gtf_ch_txdlybypass                        (gtf_ch_txdlybypass                        ),
.gtf_ch_txdlyen                            (gtf_ch_txdlyen                            ),
.gtf_ch_txdlyhold                          (gtf_ch_txdlyhold                          ),
.gtf_ch_txdlyovrden                        (gtf_ch_txdlyovrden                        ),
.gtf_ch_txdlysreset                        (gtf_ch_txdlysreset                        ),
.gtf_ch_txdlyupdown                        (gtf_ch_txdlyupdown                        ),
.gtf_ch_txelecidle                         (gtf_ch_txelecidle                         ),
.gtf_ch_txgbseqsync                        (gtf_ch_txgbseqsync                        ),
.gtf_ch_txmuxdcdexhold                     (gtf_ch_txmuxdcdexhold                     ),
.gtf_ch_txmuxdcdorwren                     (gtf_ch_txmuxdcdorwren                     ),
.gtf_ch_txpcsreset                         (gtf_ch_txpcsreset | vio_gtf_ch_txpcsreset | vnc_gtf_ch_txpcsreset ),
.gtf_ch_txphalign                          (gtf_ch_txphalign                          ),
.gtf_ch_txphalignen                        (gtf_ch_txphalignen                        ),
.gtf_ch_txphdlypd                          (gtf_ch_txphdlypd                          ),
.gtf_ch_txphdlyreset                       (gtf_ch_txphdlyreset                       ),
.gtf_ch_txphdlytstclk                      (gtf_ch_txphdlytstclk                      ),
.gtf_ch_txphinit                           (gtf_ch_txphinit                           ),
.gtf_ch_txphovrden                         (gtf_ch_txphovrden                         ),
.gtf_ch_txpippmen                          (gtf_ch_txpippmen                          ),
.gtf_ch_txpippmovrden                      (gtf_ch_txpippmovrden                      ),
.gtf_ch_txpippmpd                          (gtf_ch_txpippmpd                          ),
.gtf_ch_txpippmsel                         (gtf_ch_txpippmsel                         ),
.gtf_ch_txpisopd                           (gtf_ch_txpisopd                           ),
.gtf_ch_txpmareset                         (gtf_ch_txpmareset | vio_gtf_ch_txpmareset | vnc_gtf_ch_txpmareset ),
.gtf_ch_txpolarity                         (gtf_ch_txpolarity                         ),
.gtf_ch_txprbsforceerr                     (gtf_ch_txprbsforceerr                     ),
.gtf_ch_txprogdivreset                     (gtf_ch_txprogdivreset                     ),
.gtf_ch_txsyncallin                        (gtf_ch_txsyncallin                        ),
.gtf_ch_txsyncin                           (gtf_ch_txsyncin                           ),
.gtf_ch_txsyncmode                         (gtf_ch_txsyncmode                         ),
.gtf_ch_txuserrdy                          (vio_gtf_ch_txuserrdy | vnc_gtf_ch_txuserrdy ),
.gtf_ch_drpdi                              (gtf_ch_drpdi                              ),
.gtf_ch_gtrsvd                             (gtf_ch_gtrsvd                             ),
.gtf_ch_pcsrsvdin                          (gtf_ch_pcsrsvdin                          ),
.gtf_ch_tstin                              (gtf_ch_tstin                              ),
.gtf_ch_rxelecidlemode                     (gtf_ch_rxelecidlemode                     ),
.gtf_ch_rxmonitorsel                       (gtf_ch_rxmonitorsel                       ),
.gtf_ch_rxpd                               (gtf_ch_rxpd                               ),
.gtf_ch_rxpllclksel                        (gtf_ch_rxpllclksel                        ),
.gtf_ch_rxsysclksel                        (gtf_ch_rxsysclksel                        ),
.gtf_ch_txaxistsof                         (gtf_ch_txaxistsof                         ),
.gtf_ch_txpd                               (gtf_ch_txpd                               ),
.gtf_ch_txpllclksel                        (gtf_ch_txpllclksel                        ),
.gtf_ch_txsysclksel                        (gtf_ch_txsysclksel                        ),
.gtf_ch_cpllrefclksel                      (gtf_ch_cpllrefclksel                      ),
.gtf_ch_loopback                           (gtf_ch_loopback                           ),
.gtf_ch_rxoutclksel                        (gtf_ch_rxoutclksel                        ),
.gtf_ch_txoutclksel                        (gtf_ch_txoutclksel                        ),
.gtf_ch_txrawdata                          (gtf_ch_txrawdata                          ),
.gtf_ch_rxdfecfokfcnum                     (gtf_ch_rxdfecfokfcnum                     ),
.gtf_ch_rxprbssel                          (gtf_ch_rxprbssel                          ),
.gtf_ch_txprbssel                          (gtf_ch_txprbssel                          ),
.gtf_ch_txaxistterm                        (gtf_ch_txaxistterm                        ),
.gtf_ch_txdiffctrl                         (gtf_ch_txdiffctrl                         ),
.gtf_ch_txpippmstepsize                    (gtf_ch_txpippmstepsize                    ),
.gtf_ch_txpostcursor                       (gtf_ch_txpostcursor                       ),
.gtf_ch_txprecursor                        (gtf_ch_txprecursor                        ),
.gtf_ch_txaxistdata                        (gtf_ch_txaxistdata                        ),
.gtf_ch_rxckcalstart                       (gtf_ch_rxckcalstart                       ),
.gtf_ch_txmaincursor                       (gtf_ch_txmaincursor                       ),
.gtf_ch_txaxistlast                        (gtf_ch_txaxistlast                        ),
.gtf_ch_txaxistpre                         (gtf_ch_txaxistpre                         ),
.gtf_ch_ctlrxpauseack                      (gtf_ch_ctlrxpauseack                      ),
.gtf_ch_ctltxpausereq                      (gtf_ch_ctltxpausereq                      ),
.gtf_ch_drpaddr                            (gtf_ch_drpaddr                            ),
.gtf_ch_cpllfbclklost                      (gtf_ch_cpllfbclklost                      ),
.gtf_ch_cplllock                           (gtf_ch_cplllock                           ),
.gtf_ch_cpllrefclklost                     (gtf_ch_cpllrefclklost                     ),
.gtf_ch_dmonitoroutclk                     (gtf_ch_dmonitoroutclk                     ),
.gtf_ch_drprdy                             (gtf_ch_drprdy                             ),
.gtf_ch_eyescandataerror                   (gtf_ch_eyescandataerror                   ),
.gtf_ch_gtftxn                             (gtf_ch_gtftxn                             ),
.gtf_ch_gtftxp                             (gtf_ch_gtftxp                             ),
.gtf_ch_gtpowergood                        (gtf_ch_gtpowergood                        ),
.gtf_ch_gtrefclkmonitor                    (gtf_ch_gtrefclkmonitor                    ),
.gtf_ch_resetexception                     (gtf_ch_resetexception                     ),
.gtf_ch_rxaxisterr                         (gtf_ch_rxaxisterr                         ),
.gtf_ch_rxaxistvalid                       (gtf_ch_rxaxistvalid                       ),
.gtf_ch_rxbitslip                          (gtf_ch_rxbitslip                          ),
.gtf_ch_rxcdrlock                          (gtf_ch_rxcdrlock                          ),
.gtf_ch_rxcdrphdone                        (gtf_ch_rxcdrphdone                        ),
.gtf_ch_rxckcaldone                        (gtf_ch_rxckcaldone                        ),
.gtf_ch_rxdlysresetdone                    (gtf_ch_rxdlysresetdone                    ),
.gtf_ch_rxelecidle                         (gtf_ch_rxelecidle                         ),
.gtf_ch_rxgbseqstart                       (gtf_ch_rxgbseqstart                       ),
.gtf_ch_rxosintdone                        (gtf_ch_rxosintdone                        ),
.gtf_ch_rxosintstarted                     (gtf_ch_rxosintstarted                     ),
.gtf_ch_rxosintstrobedone                  (gtf_ch_rxosintstrobedone                  ),
.gtf_ch_rxosintstrobestarted               (gtf_ch_rxosintstrobestarted               ),
.gtf_ch_rxoutclk                           (gtf_ch_rxoutclk                           ),
.gtf_ch_rxoutclkfabric                     (gtf_ch_rxoutclkfabric                     ),
.gtf_ch_rxoutclkpcs                        (gtf_ch_rxoutclkpcs                        ),
.gtf_ch_rxphaligndone                      (gtf_ch_rxphaligndone                      ),
.gtf_ch_rxphalignerr                       (gtf_ch_rxphalignerr                       ),
.gtf_ch_rxpmaresetdone                     (gtf_ch_rxpmaresetdone                     ),
.gtf_ch_rxprbserr                          (gtf_ch_rxprbserr                          ),
.gtf_ch_rxprbslocked                       (gtf_ch_rxprbslocked                       ),
.gtf_ch_rxprgdivresetdone                  (gtf_ch_rxprgdivresetdone                  ),
.gtf_ch_rxptpsop                           (gtf_ch_rxptpsop                           ),
.gtf_ch_rxptpsoppos                        (gtf_ch_rxptpsoppos                        ),
.gtf_ch_rxrecclkout                        (gtf_ch_rxrecclkout                        ),
.gtf_ch_rxresetdone                        (gtf_ch_rxresetdone                        ),
.gtf_ch_rxslipdone                         (gtf_ch_rxslipdone                         ),
.gtf_ch_rxslipoutclkrdy                    (gtf_ch_rxslipoutclkrdy                    ),
.gtf_ch_rxslippmardy                       (gtf_ch_rxslippmardy                       ),
.gtf_ch_rxsyncdone                         (gtf_ch_rxsyncdone                         ),
.gtf_ch_rxsyncout                          (gtf_ch_rxsyncout                          ),
.gtf_ch_statrxbadcode                      (gtf_ch_statrxbadcode                      ),
.gtf_ch_statrxbadfcs                       (gtf_ch_statrxbadfcs                       ),
.gtf_ch_statrxbadpreamble                  (gtf_ch_statrxbadpreamble                  ),
.gtf_ch_statrxbadsfd                       (gtf_ch_statrxbadsfd                       ),
.gtf_ch_statrxblocklock                    (gtf_ch_statrxblocklock                    ),
.gtf_ch_statrxbroadcast                    (gtf_ch_statrxbroadcast                    ),
.gtf_ch_statrxfcserr                       (gtf_ch_statrxfcserr                       ),
.gtf_ch_statrxframingerr                   (gtf_ch_statrxframingerr                   ),
.gtf_ch_statrxgotsignalos                  (gtf_ch_statrxgotsignalos                  ),
.gtf_ch_statrxhiber                        (gtf_ch_statrxhiber                        ),
.gtf_ch_statrxinrangeerr                   (gtf_ch_statrxinrangeerr                   ),
.gtf_ch_statrxinternallocalfault           (gtf_ch_statrxinternallocalfault           ),
.gtf_ch_statrxlocalfault                   (gtf_ch_statrxlocalfault                   ),
.gtf_ch_statrxmulticast                    (gtf_ch_statrxmulticast                    ),
.gtf_ch_statrxpkt                          (gtf_ch_statrxpkt                          ),
.gtf_ch_statrxpkterr                       (gtf_ch_statrxpkterr                       ),
.gtf_ch_statrxreceivedlocalfault           (gtf_ch_statrxreceivedlocalfault           ),
.gtf_ch_statrxremotefault                  (gtf_ch_statrxremotefault                  ),
.gtf_ch_statrxstatus                       (gtf_ch_statrxstatus                       ),
.gtf_ch_statrxstompedfcs                   (gtf_ch_statrxstompedfcs                   ),
.gtf_ch_statrxtestpatternmismatch          (gtf_ch_statrxtestpatternmismatch          ),
.gtf_ch_statrxtruncated                    (gtf_ch_statrxtruncated                    ),
.gtf_ch_statrxunicast                      (gtf_ch_statrxunicast                      ),
.gtf_ch_statrxvalidctrlcode                (gtf_ch_statrxvalidctrlcode                ),
.gtf_ch_statrxvlan                         (gtf_ch_statrxvlan                         ),
.gtf_ch_stattxbadfcs                       (gtf_ch_stattxbadfcs                       ),
.gtf_ch_stattxbroadcast                    (gtf_ch_stattxbroadcast                    ),
.gtf_ch_stattxfcserr                       (gtf_ch_stattxfcserr                       ),
.gtf_ch_stattxmulticast                    (gtf_ch_stattxmulticast                    ),
.gtf_ch_stattxpkt                          (gtf_ch_stattxpkt                          ),
.gtf_ch_stattxpkterr                       (gtf_ch_stattxpkterr                       ),
.gtf_ch_stattxunicast                      (gtf_ch_stattxunicast                      ),
.gtf_ch_stattxvlan                         (gtf_ch_stattxvlan                         ),
.gtf_ch_txaxistready                       (gtf_ch_txaxistready                       ),
.gtf_ch_txdccdone                          (gtf_ch_txdccdone                          ),
.gtf_ch_txdlysresetdone                    (gtf_ch_txdlysresetdone                    ),
.gtf_ch_txgbseqstart                       (gtf_ch_txgbseqstart                       ),
.gtf_ch_txoutclk                           (gtf_ch_txoutclk                           ),
.gtf_ch_txoutclkfabric                     (gtf_ch_txoutclkfabric                     ),
.gtf_ch_txoutclkpcs                        (gtf_ch_txoutclkpcs                        ),
.gtf_ch_txphaligndone                      (gtf_ch_txphaligndone                      ),
.gtf_ch_txphinitdone                       (gtf_ch_txphinitdone                       ),
.gtf_ch_txpmaresetdone                     (gtf_ch_txpmaresetdone                     ),
.gtf_ch_txprgdivresetdone                  (gtf_ch_txprgdivresetdone                  ),
.gtf_ch_txptpsop                           (gtf_ch_txptpsop                           ),
.gtf_ch_txptpsoppos                        (gtf_ch_txptpsoppos                        ),
.gtf_ch_txresetdone                        (gtf_ch_txresetdone                        ),
.gtf_ch_txsyncdone                         (gtf_ch_txsyncdone                         ),
.gtf_ch_txsyncout                          (gtf_ch_txsyncout                          ),
.gtf_ch_txunfout                           (gtf_ch_txunfout                           ),
.gtf_ch_dmonitorout                        (gtf_ch_dmonitorout                        ),
.gtf_ch_drpdo                              (gtf_ch_drpdo                              ),
.gtf_ch_pcsrsvdout                         (gtf_ch_pcsrsvdout                         ),
.gtf_ch_pinrsrvdas                         (gtf_ch_pinrsrvdas                         ),
.gtf_ch_rxaxistsof                         (gtf_ch_rxaxistsof                         ),
.gtf_ch_rxrawdata                          (gtf_ch_rxrawdata                          ),
.gtf_ch_statrxbytes                        (gtf_ch_statrxbytes                        ),
.gtf_ch_stattxbytes                        (gtf_ch_stattxbytes                        ),
.gtf_ch_rxaxistterm                        (gtf_ch_rxaxistterm                        ),
.gtf_ch_rxaxistdata                        (gtf_ch_rxaxistdata                        ),
.gtf_ch_rxaxistlast                        (gtf_ch_rxaxistlast                        ),
.gtf_ch_rxaxistpre                         (gtf_ch_rxaxistpre                         ),
.gtf_ch_rxmonitorout                       (gtf_ch_rxmonitorout                       ),
.gtf_ch_statrxpausequanta                  (gtf_ch_statrxpausequanta                  ),
.gtf_ch_statrxpausereq                     (gtf_ch_statrxpausereq                     ),
.gtf_ch_statrxpausevalid                   (gtf_ch_statrxpausevalid                   ),
.gtf_ch_stattxpausevalid                   (gtf_ch_stattxpausevalid                   ),
.gtf_cm_bgbypassb                          (gtf_cm_bgbypassb                          ),
.gtf_cm_bgmonitorenb                       (gtf_cm_bgmonitorenb                       ),
.gtf_cm_bgpdb                              (gtf_cm_bgpdb                              ),
.gtf_cm_bgrcalovrdenb                      (gtf_cm_bgrcalovrdenb                      ),
.gtf_cm_drpclk                             (gtf_cm_drpclk                             ),
.gtf_cm_drpen                              (gtf_cm_drpen                              ),
.gtf_cm_drpwe                              (gtf_cm_drpwe                              ),
.gtf_cm_gtgrefclk0                         (gtf_cm_gtgrefclk0                         ),
.gtf_cm_gtgrefclk1                         (gtf_cm_gtgrefclk1                         ),
.gtf_cm_gtnorthrefclk00                    (gtf_cm_gtnorthrefclk00                    ),
.gtf_cm_gtnorthrefclk01                    (gtf_cm_gtnorthrefclk01                    ),
.gtf_cm_gtnorthrefclk10                    (gtf_cm_gtnorthrefclk10                    ),
.gtf_cm_gtnorthrefclk11                    (gtf_cm_gtnorthrefclk11                    ),
.gtf_cm_gtrefclk00                         (gtf_cm_gtrefclk00                         ),
.gtf_cm_gtrefclk01                         (gtf_cm_gtrefclk01                         ),
.gtf_cm_gtrefclk10                         (gtf_cm_gtrefclk10                         ),
.gtf_cm_gtrefclk11                         (gtf_cm_gtrefclk11                         ),
.gtf_cm_gtsouthrefclk00                    (gtf_cm_gtsouthrefclk00                    ),
.gtf_cm_gtsouthrefclk01                    (gtf_cm_gtsouthrefclk01                    ),
.gtf_cm_gtsouthrefclk10                    (gtf_cm_gtsouthrefclk10                    ),
.gtf_cm_gtsouthrefclk11                    (gtf_cm_gtsouthrefclk11                    ),
.gtf_cm_qpll0clkrsvd0                      (gtf_cm_qpll0clkrsvd0                      ),
.gtf_cm_qpll0clkrsvd1                      (gtf_cm_qpll0clkrsvd1                      ),
.gtf_cm_qpll0lockdetclk                    (gtf_cm_qpll0lockdetclk                    ),
.gtf_cm_qpll0locken                        (gtf_cm_qpll0locken                        ),
.gtf_cm_qpll0pd                            (gtf_cm_qpll0pd                            ),
.gtf_cm_qpll0reset                         (gtf_cm_qpll0reset | vio_gtf_cm_qpll0reset | vnc_gtf_cm_qpll0reset ),
.gtf_cm_qpll1clkrsvd0                      (gtf_cm_qpll1clkrsvd0                      ),
.gtf_cm_qpll1clkrsvd1                      (gtf_cm_qpll1clkrsvd1                      ),
.gtf_cm_qpll1lockdetclk                    (gtf_cm_qpll1lockdetclk                    ),
.gtf_cm_qpll1locken                        (gtf_cm_qpll1locken                        ),
.gtf_cm_qpll1pd                            (gtf_cm_qpll1pd                            ),
.gtf_cm_qpll1reset                         (gtf_cm_qpll1reset ^ vio_gtf_cm_qpll1reset ),
.gtf_cm_rcalenb                            (gtf_cm_rcalenb                            ),
.gtf_cm_sdm0reset                          (gtf_cm_sdm0reset                          ),
.gtf_cm_sdm0toggle                         (gtf_cm_sdm0toggle                         ),
.gtf_cm_sdm1reset                          (gtf_cm_sdm1reset                          ),
.gtf_cm_sdm1toggle                         (gtf_cm_sdm1toggle                         ),
.gtf_cm_drpaddr                            (gtf_cm_drpaddr                            ),
.gtf_cm_drpdi                              (gtf_cm_drpdi                              ),
.gtf_cm_sdm0width                          (gtf_cm_sdm0width                          ),
.gtf_cm_sdm1width                          (gtf_cm_sdm1width                          ),
.gtf_cm_sdm0data                           (gtf_cm_sdm0data                           ),
.gtf_cm_sdm1data                           (gtf_cm_sdm1data                           ),
.gtf_cm_qpll0refclksel                     (gtf_cm_qpll0refclksel                     ),
.gtf_cm_qpll1refclksel                     (gtf_cm_qpll1refclksel                     ),
.gtf_cm_bgrcalovrd                         (gtf_cm_bgrcalovrd                         ),
.gtf_cm_qpllrsvd2                          (gtf_cm_qpllrsvd2                          ),
.gtf_cm_qpllrsvd3                          (gtf_cm_qpllrsvd3                          ),
.gtf_cm_pmarsvd0                           (gtf_cm_pmarsvd0                           ),
.gtf_cm_pmarsvd1                           (gtf_cm_pmarsvd1                           ),
.gtf_cm_qpll0fbdiv                         (gtf_cm_qpll0fbdiv                         ),
.gtf_cm_qpll1fbdiv                         (gtf_cm_qpll1fbdiv                         ),
.gtf_cm_qpllrsvd1                          (gtf_cm_qpllrsvd1                          ),
.gtf_cm_qpllrsvd4                          (gtf_cm_qpllrsvd4                          ),
.gtf_cm_drprdy                             (gtf_cm_drprdy                             ),
.gtf_cm_qpll0fbclklost                     (gtf_cm_qpll0fbclklost                     ),
.gtf_cm_qpll0lock                          (gtf_cm_qpll0lock                          ),
.gtf_cm_qpll0outclk                        (gtf_cm_qpll0outclk                        ),
.gtf_cm_qpll0outrefclk                     (gtf_cm_qpll0outrefclk                     ),
.gtf_cm_qpll0refclklost                    (gtf_cm_qpll0refclklost                    ),
.gtf_cm_qpll1fbclklost                     (gtf_cm_qpll1fbclklost                     ),
.gtf_cm_qpll1lock                          (gtf_cm_qpll1lock                          ),
.gtf_cm_qpll1outclk                        (gtf_cm_qpll1outclk                        ),
.gtf_cm_qpll1outrefclk                     (gtf_cm_qpll1outrefclk                     ),
.gtf_cm_qpll1refclklost                    (gtf_cm_qpll1refclklost                    ),
.gtf_cm_refclkoutmonitor0                  (gtf_cm_refclkoutmonitor0                  ),
.gtf_cm_refclkoutmonitor1                  (gtf_cm_refclkoutmonitor1                  ),
.gtf_cm_sdm0testdata                       (gtf_cm_sdm0testdata                       ),
.gtf_cm_sdm1testdata                       (gtf_cm_sdm1testdata                       ),
.gtf_cm_drpdo                              (gtf_cm_drpdo                              ),
.gtf_cm_rxrecclk0sel                       (gtf_cm_rxrecclk0sel                       ),
.gtf_cm_rxrecclk1sel                       (gtf_cm_rxrecclk1sel                       ),
.gtf_cm_sdm0finalout                       (gtf_cm_sdm0finalout                       ),
.gtf_cm_sdm1finalout                       (gtf_cm_sdm1finalout                       ),
.gtf_cm_pmarsvdout0                        (gtf_cm_pmarsvdout0                        ),
.gtf_cm_pmarsvdout1                        (gtf_cm_pmarsvdout1                        ),
.gtf_cm_qplldmonitor0                      (gtf_cm_qplldmonitor0                      ),
.gtf_cm_qplldmonitor1                      (gtf_cm_qplldmonitor1                      ),
.gtf_txusrclk2_out                         (gtf_txusrclk2_out                         ),
.gtf_rxusrclk2_out                         (gtf_rxusrclk2_out                         ),
.gtf_ch_gttxreset_out                      (gttxreset                                 )
);

// VNC 

  wire          drp_bridge_drpen;
  wire          drp_bridge_drpwe;
  wire [9:0]    drp_bridge_drpaddr;
  wire [15:0]   drp_bridge_drpdo;
  wire          drp_bridge_drprdy;
  wire [15:0]   drp_bridge_drpdi;

gtfmac_wrapper_drp_bridge #(
    .DRP_COUNT(2),
    .DRP_ADDR_WIDTH(10),
    .DRP_DATA_WIDTH(16)
    ) u_gtfmac_wrapper_drp_bridge (
  .s_axi_aclk (aclk),
  .s_axi_aresetn (aresetn),
  .s_axi_awaddr (m0_axi_awaddr),
  .s_axi_awvalid (m0_axi_awvalid),
  .s_axi_awready (m0_axi_awready),
  .s_axi_wdata (m0_axi_wdata),
  .s_axi_wstrb (m0_axi_wstrb),
  .s_axi_wvalid (m0_axi_wvalid),
  .s_axi_wready (m0_axi_wready),
  .s_axi_bresp (m0_axi_bresp),
  .s_axi_bvalid (m0_axi_bvalid),
  .s_axi_bready (m0_axi_bready),
  .s_axi_araddr (m0_axi_araddr),
  .s_axi_arvalid (m0_axi_arvalid),
  .s_axi_arready (m0_axi_arready),
  .s_axi_rdata (m0_axi_rdata),
  .s_axi_rresp (m0_axi_rresp),
  .s_axi_rvalid (m0_axi_rvalid),
  .s_axi_rready (m0_axi_rready),
  
  .drp_en({gtf_cm_drpen,drp_bridge_drpen}),
  .drp_we({gtf_cm_drpwe,drp_bridge_drpwe}),
  .drp_addr({gtf_cm_drpaddr[9:0],drp_bridge_drpaddr[9:0]}),
  .drp_di({gtf_cm_drpdi,drp_bridge_drpdi}),
  .drp_do({gtf_cm_drpdo,drp_bridge_drpdo}),
  .drp_rdy({gtf_cm_drprdy,drp_bridge_drprdy})

);

// This mux selects whether we are driving the DRP with the alignment logic or the bridge
assign  gtf_ch_drpen        = drp_reconfig_rdy ? drp_align_drpen   : drp_bridge_drpen;
assign  gtf_ch_drpwe        = drp_reconfig_rdy ? drp_align_drpwe   : drp_bridge_drpwe;
assign  gtf_ch_drpaddr      = drp_reconfig_rdy ? drp_align_drpaddr : drp_bridge_drpaddr;
assign  gtf_ch_drpdi        = drp_reconfig_rdy ? drp_align_drpdi   : drp_bridge_drpdi;

assign  drp_bridge_drpdo    = drp_reconfig_rdy ? 16'd0 : gtf_ch_drpdo;
assign  drp_bridge_drprdy   = drp_reconfig_rdy ? 1'b0  : gtf_ch_drprdy;
assign  drp_align_drprdy    = drp_reconfig_rdy ? gtf_ch_drprdy : 1'b0;
assign  drp_align_drpdo     = drp_reconfig_rdy ? gtf_ch_drpdo : 16'd0;


gtfmac_wrapper_axi_custom_crossbar_gtfmac i_custom_crossbar_gtfmac (
    .S0_s_axi_aclk (aclk),
    .S0_s_axi_aresetn (aresetn),

    .S0_s_axi_awvalid (s_axi_awvalid),
    .S0_s_axi_awready (s_axi_awready),
    .S0_s_axi_wdata (s_axi_wdata),
    .S0_s_axi_wstrb (s_axi_wstrb),
    .S0_s_axi_wvalid (s_axi_wvalid),
    .S0_s_axi_wready (s_axi_wready),
    .S0_s_axi_bresp (s_axi_bresp),
    .S0_s_axi_bvalid (s_axi_bvalid),
    .S0_s_axi_bready (s_axi_bready),
    .S0_s_axi_arvalid (s_axi_arvalid),
    .S0_s_axi_arready (s_axi_arready),
    .S0_s_axi_rdata (s_axi_rdata),
    .S0_s_axi_rresp (s_axi_rresp),
    .S0_s_axi_rvalid (s_axi_rvalid),
    .S0_s_axi_rready (s_axi_rready),
    .S0_s_axi_awaddr (s_axi_awaddr & 32'h0000FFFF),
    .S0_s_axi_araddr (s_axi_araddr & 32'h0000FFFF),

    .M0_m_axi_awaddr (m0_axi_awaddr),
    .M0_m_axi_awvalid (m0_axi_awvalid),
    .M0_m_axi_awready (m0_axi_awready),
    .M0_m_axi_wdata (m0_axi_wdata),
    .M0_m_axi_wstrb (m0_axi_wstrb),
    .M0_m_axi_wvalid (m0_axi_wvalid),
    .M0_m_axi_wready (m0_axi_wready),
    .M0_m_axi_bresp (m0_axi_bresp),
    .M0_m_axi_bvalid (m0_axi_bvalid),
    .M0_m_axi_bready (m0_axi_bready),
    .M0_m_axi_araddr (m0_axi_araddr),
    .M0_m_axi_arvalid (m0_axi_arvalid),
    .M0_m_axi_arready (m0_axi_arready),
    .M0_m_axi_rdata (m0_axi_rdata),
    .M0_m_axi_rresp (m0_axi_rresp),
    .M0_m_axi_rvalid (m0_axi_rvalid),
    .M0_m_axi_rready (m0_axi_rready),

    .M1_m_axi_awaddr (m1_axi_awaddr),
    .M1_m_axi_awvalid (m1_axi_awvalid),
    .M1_m_axi_awready (m1_axi_awready),
    .M1_m_axi_wdata (m1_axi_wdata),
    .M1_m_axi_wstrb (m1_axi_wstrb),
    .M1_m_axi_wvalid (m1_axi_wvalid),
    .M1_m_axi_wready (m1_axi_wready),
    .M1_m_axi_bresp (m1_axi_bresp),
    .M1_m_axi_bvalid (m1_axi_bvalid),
    .M1_m_axi_bready (m1_axi_bready),
    .M1_m_axi_araddr (m1_axi_araddr),
    .M1_m_axi_arvalid (m1_axi_arvalid),
    .M1_m_axi_arready (m1_axi_arready),
    .M1_m_axi_rdata (m1_axi_rdata),
    .M1_m_axi_rresp (m1_axi_rresp),
    .M1_m_axi_rvalid (m1_axi_rvalid),
    .M1_m_axi_rready (m1_axi_rready),

    .ctl_tx_data_rate (ctl_tx_data_rate),
    .ctl_tx_ignore_fcs (ctl_tx_ignore_fcs),
    .ctl_tx_fcs_ins_enable (ctl_tx_fcs_ins_enable),
    .ctl_rx_data_rate (ctl_rx_data_rate),
    .ctl_rx_ignore_fcs (ctl_rx_ignore_fcs),
    .ctl_rx_min_packet_len (ctl_rx_min_packet_len),
    .ctl_rx_max_packet_len (ctl_rx_max_packet_len)
  );

// END VNC

endmodule


module gtfwizard_0_prbs_any(RST, CLK, DATA_IN, EN, DATA_OUT);

  //--------------------------------------------
  // Configuration parameters
  //--------------------------------------------
   parameter CHK_MODE = 0;
   parameter INV_PATTERN = 0;
   parameter POLY_LENGHT = 31;
   parameter POLY_TAP = 3;
   parameter NBITS = 16;

  //--------------------------------------------
  // Input/Outputs
  //--------------------------------------------

   input  wire RST;
   input  wire CLK;
   input  wire [NBITS - 1:0] DATA_IN;
   input  wire EN;
   output reg  [NBITS - 1:0] DATA_OUT = {NBITS{1'b1}};

  //--------------------------------------------
  // Internal variables
  //--------------------------------------------

   wire [1:POLY_LENGHT] prbs[NBITS:0];
   wire [NBITS - 1:0] data_in_i;
   wire [NBITS - 1:0] prbs_xor_a;
   wire [NBITS - 1:0] prbs_xor_b;
   wire [NBITS:1] prbs_msb;
   reg  [1:POLY_LENGHT]prbs_reg = {(POLY_LENGHT){1'b1}};

  //--------------------------------------------
  // Implementation
  //--------------------------------------------

   assign data_in_i = INV_PATTERN == 0 ? DATA_IN : ( ~DATA_IN);
   assign prbs[0] = prbs_reg;

   genvar I;
   generate for (I=0; I<NBITS; I=I+1) begin : g1
      assign prbs_xor_a[I] = prbs[I][POLY_TAP] ^ prbs[I][POLY_LENGHT];
      assign prbs_xor_b[I] = prbs_xor_a[I] ^ data_in_i[I];
      assign prbs_msb[I+1] = CHK_MODE == 0 ? prbs_xor_a[I]  :  data_in_i[I];
      assign prbs[I+1] = {prbs_msb[I+1] , prbs[I][1:POLY_LENGHT-1]};
   end
   endgenerate

   always @(posedge CLK) begin
      if(RST == 1'b 1) begin
         prbs_reg <= {POLY_LENGHT{1'b1}};
         DATA_OUT <= {NBITS{1'b1}};
      end
      else if(EN == 1'b 1) begin
         DATA_OUT <= prbs_xor_b;
         prbs_reg <= prbs[NBITS];
      end
  end

endmodule







module gtfwizard_0_example_gtwiz_buffbypass_tx #(

  parameter integer P_BUFFER_BYPASS_MODE       = 0,
  parameter integer P_TOTAL_NUMBER_OF_CHANNELS = 1,
  parameter integer P_MASTER_CHANNEL_POINTER   = 0

)(

  // User interface ports
  input  wire gtwiz_buffbypass_tx_clk_in,
  input  wire gtwiz_buffbypass_tx_reset_in,
  input  wire gtwiz_buffbypass_tx_start_user_in,
  input  wire gtwiz_buffbypass_tx_resetdone_in,
  output reg  gtwiz_buffbypass_tx_done_out  = 1'b0,
  output reg  gtwiz_buffbypass_tx_error_out = 1'b0,
  
  //syncdone debug
  output wire [1:0] sm_buffbypass_tx_out, //EG 8/3
  
  // Transceiver interface ports
  input  wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txphaligndone_in,
  input  wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txphinitdone_in,
  input  wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txdlysresetdone_in,
  input  wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txsyncout_in,
  input  wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txsyncdone_in,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txphdlyreset_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txphalign_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txphalignen_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txphdlypd_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txphinit_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txphovrden_out,
  output reg  [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txdlysreset_out = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}},
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txdlybypass_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txdlyen_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txdlyovrden_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txphdlytstclk_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txdlyhold_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txdlyupdown_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txsyncmode_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txsyncallin_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txsyncin_out

);

  
  // -------------------------------------------------------------------------------------------------------------------
  // Transmitter buffer bypass conditional generation, based on parameter values in module instantiation
  // -------------------------------------------------------------------------------------------------------------------
  localparam [1:0] ST_BUFFBYPASS_TX_IDLE                 = 2'd0;
  localparam [1:0] ST_BUFFBYPASS_TX_DEASSERT_TXDLYSRESET = 2'd1;
  localparam [1:0] ST_BUFFBYPASS_TX_WAIT_TXSYNCDONE      = 2'd2;
  localparam [1:0] ST_BUFFBYPASS_TX_DONE                 = 2'd3;

  generate if (1) begin: gen_gtwiz_buffbypass_tx_main

    // Use auto mode buffer bypass
    if (P_BUFFER_BYPASS_MODE == 0) begin : gen_auto_mode

      // For single-lane auto mode buffer bypass, perform specified input port tie-offs
      if (P_TOTAL_NUMBER_OF_CHANNELS == 1) begin : gen_assign_one_chan
        assign txphdlyreset_out  = 1'b0;
        assign txphalign_out     = 1'b0;
        assign txphalignen_out   = 1'b0;
        assign txphdlypd_out     = 1'b0;
        assign txphinit_out      = 1'b0;
        assign txphovrden_out    = 1'b0;
        assign txdlybypass_out   = 1'b0;
        assign txdlyen_out       = 1'b0;
        assign txdlyovrden_out   = 1'b0;
        assign txphdlytstclk_out = 1'b0;
        assign txdlyhold_out     = 1'b0;
        assign txdlyupdown_out   = 1'b0;
        assign txsyncmode_out    = 1'b1;
        assign txsyncallin_out   = txphaligndone_in;
        assign txsyncin_out      = 1'b0;
      end

      // For multi-lane auto mode buffer bypass, perform specified master and slave lane input port tie-offs
      else begin : gen_assign_multi_chan
        assign txphdlyreset_out  = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
        assign txphalign_out     = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
        assign txphalignen_out   = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
        assign txphdlypd_out     = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
        assign txphinit_out      = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
        assign txphovrden_out    = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
        assign txdlybypass_out   = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
        assign txdlyen_out       = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
        assign txdlyovrden_out   = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
        assign txphdlytstclk_out = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
        assign txdlyhold_out     = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
        assign txdlyupdown_out   = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};

        genvar gi;
        for (gi = 0; gi < P_TOTAL_NUMBER_OF_CHANNELS; gi = gi + 1) begin : gen_assign_txsyncmode
          if (gi == P_MASTER_CHANNEL_POINTER)
            assign txsyncmode_out[gi] = 1'b1;
          else
            assign txsyncmode_out[gi] = 1'b0;
        end

        assign txsyncallin_out = {P_TOTAL_NUMBER_OF_CHANNELS{&txphaligndone_in}};
        assign txsyncin_out    = {P_TOTAL_NUMBER_OF_CHANNELS{txsyncout_in[P_MASTER_CHANNEL_POINTER]}};
      end

      // Detect the rising edge of the transmitter reset done re-synchronized input. Assign an internal buffer bypass
      // start signal to the OR of this reset done indicator, and the synchronous buffer bypass procedure user request.
      wire gtwiz_buffbypass_tx_resetdone_sync_int;

//     xpm_cdc_async_rst # (
//      .DEST_SYNC_FF (5),
//      .RST_ACTIVE_HIGH (1)
//     ) reset_synchronizer_resetdone_inst (
//       .src_arst  (gtwiz_buffbypass_tx_resetdone_in),
//       .dest_arst (gtwiz_buffbypass_tx_resetdone_sync_int),
//       .dest_clk  (gtwiz_buffbypass_tx_clk_in)
//     );
      xpm_cdc_sync_rst # ( //EG 8/3
        .DEST_SYNC_FF (4),
        .INIT         (0)
      ) reset_synchronizer_resetdone_inst (
        .src_rst  (gtwiz_buffbypass_tx_resetdone_in),
        .dest_rst (gtwiz_buffbypass_tx_resetdone_sync_int),
        .dest_clk  (gtwiz_buffbypass_tx_clk_in)
      );


      reg  gtwiz_buffbypass_tx_resetdone_reg = 1'b0;
      wire gtwiz_buffbypass_tx_start_int;

      always @(posedge gtwiz_buffbypass_tx_clk_in) begin
        if (gtwiz_buffbypass_tx_reset_in)
          gtwiz_buffbypass_tx_resetdone_reg <= 1'b0;
        else
          gtwiz_buffbypass_tx_resetdone_reg <= gtwiz_buffbypass_tx_resetdone_sync_int;
      end

      assign gtwiz_buffbypass_tx_start_int = (gtwiz_buffbypass_tx_resetdone_sync_int &&
                                             ~gtwiz_buffbypass_tx_resetdone_reg) || gtwiz_buffbypass_tx_start_user_in;

      // Synchronize the master channel's buffer bypass completion output (TXSYNCDONE) into the local clock domain
      // and detect its rising edge for purposes of safe state machine transitions
      reg  gtwiz_buffbypass_tx_master_syncdone_sync_reg = 1'b0;
      wire gtwiz_buffbypass_tx_master_syncdone_sync_int;
      wire gtwiz_buffbypass_tx_master_syncdone_sync_re;

      xpm_cdc_sync_rst # (
       .DEST_SYNC_FF (4),
       .INIT          (0)
      ) bit_synchronizer_mastersyncdone_inst (
        .src_rst  (txsyncdone_in[P_MASTER_CHANNEL_POINTER]),
        .dest_rst (gtwiz_buffbypass_tx_master_syncdone_sync_int),
        .dest_clk (gtwiz_buffbypass_tx_clk_in)
      );


      always @(posedge gtwiz_buffbypass_tx_clk_in)
        gtwiz_buffbypass_tx_master_syncdone_sync_reg <= gtwiz_buffbypass_tx_master_syncdone_sync_int;

      assign gtwiz_buffbypass_tx_master_syncdone_sync_re = gtwiz_buffbypass_tx_master_syncdone_sync_int &&
                                                          ~gtwiz_buffbypass_tx_master_syncdone_sync_reg;

      // Synchronize the master channel's phase alignment completion output (TXPHALIGNDONE) into the local clock domain
      wire gtwiz_buffbypass_tx_master_phaligndone_sync_int;

      xpm_cdc_sync_rst # (
       .DEST_SYNC_FF (4),
       .INIT          (0)
      )  bit_synchronizer_masterphaligndone_inst (
        .src_rst  (txphaligndone_in[P_MASTER_CHANNEL_POINTER]),
        .dest_rst (gtwiz_buffbypass_tx_master_phaligndone_sync_int),
        .dest_clk (gtwiz_buffbypass_tx_clk_in)
      );

      // Implement a simple state machine to perform the transmitter auto mode buffer bypass procedure
      reg [1:0] sm_buffbypass_tx = ST_BUFFBYPASS_TX_IDLE;
      assign sm_buffbypass_tx_out = sm_buffbypass_tx; //EG 8/3
      always @(posedge gtwiz_buffbypass_tx_clk_in) begin
        if (gtwiz_buffbypass_tx_reset_in) begin
          gtwiz_buffbypass_tx_done_out  <= 1'b0;
          gtwiz_buffbypass_tx_error_out <= 1'b0;
          txdlysreset_out               <= {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
          sm_buffbypass_tx              <= ST_BUFFBYPASS_TX_IDLE;
        end
        else begin
          case (sm_buffbypass_tx)

            // Upon assertion of the internal buffer bypass start signal, assert TXDLYSRESET output(s)
            default: begin
              if (gtwiz_buffbypass_tx_start_int) begin
                gtwiz_buffbypass_tx_done_out  <= 1'b0;
                gtwiz_buffbypass_tx_error_out <= 1'b0;
                txdlysreset_out               <= {P_TOTAL_NUMBER_OF_CHANNELS{1'b1}};
                sm_buffbypass_tx              <= ST_BUFFBYPASS_TX_DEASSERT_TXDLYSRESET;
              end
            end

            // De-assert the TXDLYSRESET output(s)
            ST_BUFFBYPASS_TX_DEASSERT_TXDLYSRESET: begin
              txdlysreset_out  <= {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
              sm_buffbypass_tx <= ST_BUFFBYPASS_TX_WAIT_TXSYNCDONE;
            end

            // Upon assertion of the synchronized TXSYNCDONE indicator, transition to the final state
            ST_BUFFBYPASS_TX_WAIT_TXSYNCDONE: begin
              if (gtwiz_buffbypass_tx_master_syncdone_sync_re)
                sm_buffbypass_tx <= ST_BUFFBYPASS_TX_DONE;
            end

            // Assert the buffer bypass procedure done user indicator, and set the procedure error flag if the
            // synchronized TXPHALIGNDONE indicator is not high
            ST_BUFFBYPASS_TX_DONE: begin
              gtwiz_buffbypass_tx_done_out  <= 1'b1;
              gtwiz_buffbypass_tx_error_out <= ~gtwiz_buffbypass_tx_master_phaligndone_sync_int;
              sm_buffbypass_tx              <= ST_BUFFBYPASS_TX_IDLE;
            end

          endcase
        end
      end

    end
  end
  endgenerate


endmodule
