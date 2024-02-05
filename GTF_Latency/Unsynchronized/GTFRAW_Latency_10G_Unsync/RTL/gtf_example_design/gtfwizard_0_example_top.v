/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------


`timescale 1fs/1fs
`default_nettype none
module gtfwizard_0_example_top # (
  parameter  integer     NUM_CHANNEL = 1
)
(
  output wire [NUM_CHANNEL-1:0] gtf_ch_gtftxn,
  output wire [NUM_CHANNEL-1:0] gtf_ch_gtftxp,
  input  wire [NUM_CHANNEL-1:0] gtf_ch_gtfrxn,
  input  wire [NUM_CHANNEL-1:0] gtf_ch_gtfrxp,
  input  wire                   refclk_p,
  input  wire                   refclk_n,
  input  wire                   freerun_clk,
  output wire                   aclk,
  output wire [NUM_CHANNEL-1:0] aresetn,
  input  wire                   hb_gtwiz_reset_all_in,
  output wire [NUM_CHANNEL-1:0] gtwiz_reset_tx_done_out,
  output wire [NUM_CHANNEL-1:0] gtwiz_reset_rx_done_out,
  output wire                   gtf_cm_qpll0_lock,

  input  wire [NUM_CHANNEL-1:0] hb_gtf_ch_txdp_reset_in,
  input  wire [NUM_CHANNEL-1:0] hb_gtf_ch_rxdp_reset_in,

  // PRBS-based link status ports
  input  wire [NUM_CHANNEL-1:0] link_down_latched_reset_in,
  output reg  [NUM_CHANNEL-1:0] link_status_out,
  output reg  [NUM_CHANNEL-1:0] link_down_latched_out, // = {NUM_CHANNEL{1'b1}}

// ====================================================
// Add VNC

  output wire                   sync_error,
  output wire                   sync_det_0,
  output wire [NUM_CHANNEL-1:0] link_maintained,
  output wire [NUM_CHANNEL-1:0] gtf_ch_rxsyncdone,
  output wire [NUM_CHANNEL-1:0] gtf_ch_txsyncdone,
  output wire [NUM_CHANNEL-1:0] wa_complete_flg,

  output wire [NUM_CHANNEL-1:0] tx_axis_clk,
  output wire [NUM_CHANNEL-1:0] tx_axis_rst,
                        
  output wire [NUM_CHANNEL-1:0] rx_axis_clk,
  output wire [NUM_CHANNEL-1:0] rx_axis_rst,

  input wire                    sys_clk_out, // clk wiz new 
  output wire [NUM_CHANNEL-1:0] sys_rst_out,


  input  wire [NUM_CHANNEL-1:0] hwchk_gtf_ch_gttxreset,
  input  wire [NUM_CHANNEL-1:0] hwchk_gtf_ch_txpmareset,
  input  wire [NUM_CHANNEL-1:0] hwchk_gtf_ch_txpcsreset,
  input  wire [NUM_CHANNEL-1:0] hwchk_gtf_ch_gtrxreset,
  input  wire [NUM_CHANNEL-1:0] hwchk_gtf_ch_rxpmareset,
  input  wire [NUM_CHANNEL-1:0] hwchk_gtf_ch_rxdfelpmreset,
  input  wire [NUM_CHANNEL-1:0] hwchk_gtf_ch_eyescanreset,
  input  wire [NUM_CHANNEL-1:0] hwchk_gtf_ch_rxpcsreset,
  input  wire [NUM_CHANNEL-1:0] hwchk_gtf_cm_qpll0reset,
  
  input  wire [NUM_CHANNEL-1:0] hwchk_gtf_ch_txuserrdy,
  input  wire [NUM_CHANNEL-1:0] hwchk_gtf_ch_rxuserrdy,
  
  input  wire [NUM_CHANNEL-1:0] gtwiz_reset_tx_pll_and_datapath_in,
  input  wire [NUM_CHANNEL-1:0] gtwiz_reset_tx_datapath_in,
  input  wire [NUM_CHANNEL-1:0] gtwiz_reset_rx_pll_and_datapath_in,
  input  wire [NUM_CHANNEL-1:0] gtwiz_reset_rx_datapath_in,
  
  output wire [NUM_CHANNEL-1:0] gtf_ch_statrxinternallocalfault,
  output wire [NUM_CHANNEL-1:0] gtf_ch_statrxlocalfault,
  output wire [NUM_CHANNEL-1:0] gtf_ch_statrxreceivedlocalfault,
  output wire [NUM_CHANNEL-1:0] gtf_ch_statrxremotefault,
  output wire [NUM_CHANNEL-1:0] gtf_ch_statrxblocklock,
  
  
  input  wire [40*NUM_CHANNEL-1:0] gtf_ch_txrawdata,
  output wire [40*NUM_CHANNEL-1:0] gtf_ch_rxrawdata,
  output wire [15:0]               gtf_ch_rxrawdata_align,
  output wire [15:0]               gtf_ch_rxrawdata_samp,
  output wire [7:0]                bitslip_value,
  
  input  wire [31 : 0]          s_axi_awaddr,
  output wire [2 : 0]           s_axi_awprot,
  input  wire                   s_axi_awvalid,
  output wire                   s_axi_awready,
  input  wire [31 : 0]          s_axi_wdata,
  output wire [3 : 0]           s_axi_wstrb,
  input  wire                   s_axi_wvalid,
  output wire                   s_axi_wready,
  output wire [1 : 0]           s_axi_bresp,
  output wire                   s_axi_bvalid,
  input  wire                   s_axi_bready,
  input  wire [31 : 0]          s_axi_araddr,
  output wire [2 : 0]           s_axi_arprot,
  input  wire                   s_axi_arvalid,
  output wire                   s_axi_arready,
  output wire [31 : 0]          s_axi_rdata,
  output wire [1 : 0]           s_axi_rresp,
  output wire                   s_axi_rvalid,
  input  wire                   s_axi_rready
  );

  `include "gtfwizard_0_rules_output.vh" 
wire                   refclk_in;
wire [NUM_CHANNEL-1:0] gtf_wiz_reset_tx_datapath_init_i;
wire [NUM_CHANNEL-1:0] gtf_wiz_reset_rx_datapath_init_i;
wire [NUM_CHANNEL-1:0] gtf_wiz_reset_tx_datapath_init_sync;
wire [NUM_CHANNEL-1:0] gtf_wiz_reset_rx_datapath_init_sync;
wire [NUM_CHANNEL-1:0] gtwiz_reset_tx_done_out_init_sync;
wire [NUM_CHANNEL-1:0] gtwiz_reset_rx_done_out_init_sync;
wire [NUM_CHANNEL-1:0] gtwiz_buffbypass_tx_done_out_i;
wire [NUM_CHANNEL-1:0] gtwiz_buffbypass_rx_done_out_i;
reg  [NUM_CHANNEL-1:0] tx_init_done_in_r;
reg  [NUM_CHANNEL-1:0] rx_init_done_in_r;
reg  [NUM_CHANNEL-1:0] gtwiz_reset_tx_datapath_r;
reg  [NUM_CHANNEL-1:0] gtwiz_reset_rx_datapath_r;
wire [NUM_CHANNEL-1:0] gtwiz_reset_all_in;
wire [NUM_CHANNEL-1:0] gtwiz_reset_tx_sync;
wire [NUM_CHANNEL-1:0] gtwiz_reset_rx_sync;
wire [NUM_CHANNEL-1:0] gtf_txusrclk2_out;
wire [NUM_CHANNEL-1:0] gtf_rxusrclk2_out;

wire  [2:0]             ctl_local_loopback;
wire  [NUM_CHANNEL-1:0] ctl_tx_send_idle_axi;
wire  [NUM_CHANNEL-1:0] ctl_tx_send_lfi_axi;
wire  [NUM_CHANNEL-1:0] ctl_tx_send_rfi_axi;
wire  [NUM_CHANNEL-1:0] ctl_gt_reset_all;

wire    [6:0]   bs_stat_bitslip_cnt     [0:NUM_CHANNEL-1];
wire    [6:0]   bs_stat_bitslip_issued  [0:NUM_CHANNEL-1];


IBUFDS_GTE4 #(
  .REFCLK_EN_TX_PATH  (1'b0),
  .REFCLK_HROW_CK_SEL (2'b00),
  .REFCLK_ICNTL_RX    (2'b00)
) IBUFDS_GTE4_INST (
  .I     (refclk_p),
  .IB    (refclk_n),
  .CEB   (1'b0),
  .O     (refclk_in),
  .ODIV2 ()
);


wire gtwiz_reset_tx, gtwiz_reset_rx;
wire hb_gtwiz_reset_all_in_or = ctl_gt_reset_all[0] || hb_gtwiz_reset_all_in; //  || hb_gtwiz_reset_all_vio;																			  

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
  
  assign  aclk                      = freerun_clk;
  wire   gtwiz_reset_clk_freerun_in = freerun_clk;
  wire   gtf_cm_qpll0lockdetclk     = freerun_clk;
  wire   gtf_cm_qpll1lockdetclk     = freerun_clk;
  wire   gtf_ch_cplllockdetclk      = freerun_clk;
  wire   gtf_ch_drpclk              = freerun_clk;
  wire   gtf_cm_drpclk              = freerun_clk;
  wire   gtf_ch_dmonitorclk         = freerun_clk;

  //---Reset controller ports ---{
  wire  [NUM_CHANNEL-1:0] gtwiz_reset_rx_cdr_stable_out;
  wire  [NUM_CHANNEL-1:0] gtwiz_pllreset_rx_out;
  wire  [NUM_CHANNEL-1:0] gtwiz_pllreset_tx_out;
  wire  [NUM_CHANNEL-1:0] gtf_ch_txdp_reset_in;
  wire  [NUM_CHANNEL-1:0] gtf_ch_rxdp_reset_in;
  //---Reset controller ports ---}

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
  wire              gtf_cm_qpll0reset        = gtwiz_pllreset_tx_out[0] || hwchk_gtf_cm_qpll0reset;// QPLL0RESET    ;
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
  wire  [NUM_CHANNEL-1:0]       gtf_ch_drpen;
  wire  [NUM_CHANNEL-1:0]       gtf_ch_drprst; 
  wire  [NUM_CHANNEL-1:0]       gtf_ch_drpwe;
  wire  [16*NUM_CHANNEL-1:0]    gtf_ch_drpdi;
  wire  [10*NUM_CHANNEL-1:0]    gtf_ch_drpaddr;
  wire  [NUM_CHANNEL-1:0]       gtf_ch_drprdy;
  wire  [16*NUM_CHANNEL-1:0]    gtf_ch_drpdo;
  wire         gtf_cm_drpen = 0;
  wire         gtf_cm_drpwe =0;
  wire  [15:0] gtf_cm_drpaddr =0;
  wire  [15:0] gtf_cm_drpdi =0;
  wire         gtf_cm_drprdy;
  wire  [15:0] gtf_cm_drpdo;
  //--- DRP ports ---}

  wire  [NUM_CHANNEL-1:0] gtwiz_buffbypass_rx_reset;
  wire  [NUM_CHANNEL-1:0] gtf_ch_am_switch;
  wire  [NUM_CHANNEL-1:0] gtf_ch_drp_reconfig_rdy;
  wire  [NUM_CHANNEL-1:0] gtf_ch_drp_reconfig_done;

  

  //---Port tie offs--{ 
  wire  [8:0]       gtf_ch_ctlrxpauseack = CTLRXPAUSEACK;
  wire  [8:0]       gtf_ch_ctltxpausereq = CTLTXPAUSEREQ;
  wire              gtf_ch_ctltxresendpause = CTLTXRESENDPAUSE;
  wire              gtf_ch_ctltxsendidle = ctl_tx_send_idle_axi; // VNC = CTLTXSENDIDLE;
  wire              gtf_ch_ctltxsendlfi = ctl_tx_send_lfi_axi; // VNC = CTLTXSENDLFI;
  wire              gtf_ch_ctltxsendrfi = ctl_tx_send_rfi_axi; // VNC = CTLTXSENDRFI;
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
  wire              gtf_ch_gtrxreset = GTRXRESET;
  wire              gtf_ch_gtrxresetsel = GTRXRESETSEL;
  wire              gtf_ch_gttxreset = GTTXRESET;
  wire              gtf_ch_gttxresetsel = GTTXRESETSEL;
  wire              gtf_ch_incpctrl = INCPCTRL;
  wire              gtf_ch_resetovrd = RESETOVRD;
  wire              gtf_ch_rxafecfoken = RXAFECFOKEN;
  wire              gtf_ch_rxcdrfreqreset = RXCDRFREQRESET;
  wire              gtf_ch_rxcdrhold = RXCDRHOLD;
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
  wire [NUM_CHANNEL-1:0]             gtf_ch_rxdlybypass;//     = RXDLYBYPASS        ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_rxdlyen;//         = RXDLYEN            ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_rxdlyovrden;//     = RXDLYOVRDEN        ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_rxdlysreset;//     = RXDLYSRESET        ;
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
  wire [NUM_CHANNEL-1:0]             gtf_ch_rxphalign;//       = RXPHALIGN       ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_rxphalignen;//     = RXPHALIGNEN     ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_rxphdlypd;//       = RXPHDLYPD       ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_rxphdlyreset;//    = RXPHDLYRESET    ;
  wire              gtf_ch_rxpmareset         = RXPMARESET      ;
  wire              gtf_ch_rxpolarity         = RXPOLARITY      ;
  wire              gtf_ch_rxprbscntreset     = RXPRBSCNTRESET  ;
  wire              gtf_ch_rxprogdivreset     = RXPROGDIVRESET  ;
  wire              gtf_ch_rxslipoutclk       = RXSLIPOUTCLK    ;
  wire              gtf_ch_rxslippma          = RXSLIPPMA       ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_rxsyncallin;//     = RXSYNCALLIN     ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_rxsyncin;//        = RXSYNCIN        ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_rxsyncmode;//      = RXSYNCMODE      ;
  wire              gtf_ch_rxtermination      = RXTERMINATION   ;
  wire              gtf_ch_rxuserrdy         = RXUSERRDY;
  wire              gtf_ch_txdccforcestart   =  TXDCCFORCESTART;
  wire              gtf_ch_txdccreset        =  TXDCCRESET     ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_txdlybypass;//    =  TXDLYBYPASS    ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_txdlyen;//        =  TXDLYEN        ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_txdlyhold;//      =  TXDLYHOLD      ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_txdlyovrden;//    =  TXDLYOVRDEN    ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_txdlysreset;//    =  TXDLYSRESET    ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_txdlyupdown;//    =  TXDLYUPDOWN    ;
  wire              gtf_ch_txelecidle        =  1'b0;
  wire              gtf_ch_txgbseqsync       =  TXGBSEQSYNC    ;
  wire              gtf_ch_txmuxdcdexhold    =  TXMUXDCDEXHOLD ;
  wire              gtf_ch_txmuxdcdorwren    =  TXMUXDCDORWREN ;
  wire              gtf_ch_txpcsreset        =  TXPCSRESET     ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_txphalign;//      =  TXPHALIGN      ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_txphalignen;//    =  TXPHALIGNEN    ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_txphdlypd;//      =  TXPHDLYPD      ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_txphdlyreset;//   =  TXPHDLYRESET   ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_txphdlytstclk;//  =  TXPHDLYTSTCLK  ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_txphinit;//       =  TXPHINIT       ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_txphovrden;//     =  TXPHOVRDEN     ;
  wire              gtf_ch_txpippmen         =  TXPIPPMEN      ;
  wire              gtf_ch_txpippmovrden     =  TXPIPPMOVRDEN  ;
  wire              gtf_ch_txpippmpd         =  TXPIPPMPD      ;
  wire              gtf_ch_txpippmsel        =  TXPIPPMSEL     ;
  wire              gtf_ch_txpisopd          =  TXPISOPD       ;
  wire              gtf_ch_txpmareset        =  TXPMARESET     ;
  wire              gtf_ch_txpolarity        =  TXPOLARITY     ;
  wire              gtf_ch_txprbsforceerr    =  TXPRBSFORCEERR ;
  wire              gtf_ch_txprogdivreset    =  TXPROGDIVRESET ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_txsyncallin;//    =  TXSYNCALLIN    ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_txsyncin;//       =  TXSYNCIN       ;
  wire [NUM_CHANNEL-1:0]             gtf_ch_txsyncmode;//     =  TXSYNCMODE     ;
  wire              gtf_ch_txuserrdy         =  TXUSERRDY      ;
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
  wire [NUM_CHANNEL-1:0]             gtf_ch_gtpowergood;
  wire              gtf_ch_gtrefclkmonitor;
  wire              gtf_ch_resetexception;
  wire              gtf_ch_rxbitslip;
  wire              gtf_ch_rxslippmardy;
  //wire              gtf_ch_statrxblocklock;
  //wire              gtf_ch_statrxinternallocalfault;
  //wire              gtf_ch_statrxlocalfault;
  //wire              gtf_ch_statrxreceivedlocalfault;
  //wire              gtf_ch_statrxremotefault;  
  wire  [15:0]      gtf_ch_gtrsvd = GTRSVD;
  wire  [15:0]      gtf_ch_pcsrsvdin = PCSRSVDIN;
  wire [NUM_CHANNEL-1:0]             gtf_ch_rxcdrlock;
  wire              gtf_ch_rxcdrphdone;
  wire              gtf_ch_rxckcaldone;
  wire [NUM_CHANNEL-1:0]             gtf_ch_rxdlysresetdone;
  wire              gtf_ch_rxelecidle;
  wire              gtf_ch_rxosintdone;
  wire              gtf_ch_rxosintstarted;
  wire              gtf_ch_rxosintstrobedone;
  wire              gtf_ch_rxosintstrobestarted;
  wire              gtf_ch_rxoutclk;
  wire              gtf_ch_rxoutclkfabric;
  wire              gtf_ch_rxoutclkpcs;
  wire [NUM_CHANNEL-1:0]             gtf_ch_rxphovrden;
  wire [NUM_CHANNEL-1:0]             gtf_ch_rxphaligndone;
  wire              gtf_ch_rxphalignerr;
  wire [NUM_CHANNEL-1:0]             gtf_ch_rxpmaresetdone;
  wire              gtf_ch_rxprbserr;
  wire              gtf_ch_rxprbslocked;
  wire              gtf_ch_rxprgdivresetdone;
  wire              gtf_ch_rxrecclkout;
  wire [NUM_CHANNEL-1:0]             gtf_ch_rxresetdone;
  wire              gtf_ch_rxslipdone;
  wire              gtf_ch_rxslipoutclkrdy;
  //wire [NUM_CHANNEL-1:0]             gtf_ch_rxsyncdone;
  wire [NUM_CHANNEL-1:0]             gtf_ch_rxsyncout;
  wire [NUM_CHANNEL-1:0]             gtf_ch_statrxbadcode;
  wire [NUM_CHANNEL-1:0]             gtf_ch_statrxbadfcs;
  wire [NUM_CHANNEL-1:0]             gtf_ch_statrxbadpreamble;
  wire [NUM_CHANNEL-1:0]             gtf_ch_statrxbadsfd;
  wire [NUM_CHANNEL-1:0]             gtf_ch_statrxbroadcast;
  wire [NUM_CHANNEL-1:0]             gtf_ch_statrxfcserr;
  wire [NUM_CHANNEL-1:0]             gtf_ch_statrxframingerr;
  wire [NUM_CHANNEL-1:0]             gtf_ch_statrxgotsignalos;
  wire [NUM_CHANNEL-1:0]             gtf_ch_statrxhiber;
  wire [NUM_CHANNEL-1:0]             gtf_ch_statrxinrangeerr;
  wire [NUM_CHANNEL-1:0]             gtf_ch_statrxmulticast;
  wire [NUM_CHANNEL-1:0]             gtf_ch_statrxpkt;
  wire [NUM_CHANNEL-1:0]             gtf_ch_statrxpkterr;
  wire [NUM_CHANNEL-1:0]             gtf_ch_statrxstatus;
  wire [NUM_CHANNEL-1:0]             gtf_ch_statrxstompedfcs;
  wire [NUM_CHANNEL-1:0]             gtf_ch_statrxtestpatternmismatch;
  wire [NUM_CHANNEL-1:0]             gtf_ch_statrxtruncated;
  wire [NUM_CHANNEL-1:0]             gtf_ch_statrxunicast;
  wire [NUM_CHANNEL-1:0]             gtf_ch_statrxvalidctrlcode;
  wire [NUM_CHANNEL-1:0]             gtf_ch_statrxvlan;
  wire [NUM_CHANNEL-1:0]             gtf_ch_stattxbadfcs;
  wire [NUM_CHANNEL-1:0]             gtf_ch_stattxbroadcast;
  wire [NUM_CHANNEL-1:0]             gtf_ch_stattxfcserr;
  wire [NUM_CHANNEL-1:0]             gtf_ch_stattxmulticast;
  wire [NUM_CHANNEL-1:0]             gtf_ch_stattxpkt;
  wire [NUM_CHANNEL-1:0]             gtf_ch_stattxpkterr;
  wire [NUM_CHANNEL-1:0]             gtf_ch_stattxunicast;
  wire [NUM_CHANNEL-1:0]             gtf_ch_stattxvlan;
  wire              gtf_ch_txdccdone;
  wire [NUM_CHANNEL-1:0]             gtf_ch_txdlysresetdone;
  wire              gtf_ch_txoutclk;
  wire              gtf_ch_txoutclkfabric;
  wire              gtf_ch_txoutclkpcs;
  wire [NUM_CHANNEL-1:0]             gtf_ch_txphaligndone;
  wire [NUM_CHANNEL-1:0]             gtf_ch_txphinitdone;
  wire [NUM_CHANNEL-1:0]             gtf_ch_txpmaresetdone;
  wire              gtf_ch_txprgdivresetdone;
  wire [NUM_CHANNEL-1:0]             gtf_ch_txresetdone;
  //wire [NUM_CHANNEL-1:0]             gtf_ch_txsyncdone;
  wire [NUM_CHANNEL-1:0]             gtf_ch_txsyncout;
  wire [16*NUM_CHANNEL-1:0]          gtf_ch_dmonitorout;
  wire   [15:0]     gtf_ch_pinrsrvdas;
  wire   [7:0]      gtf_ch_rxmonitorout;
  wire [9*NUM_CHANNEL-1:0]           gtf_ch_statrxpausequanta;
  wire [9*NUM_CHANNEL-1:0]           gtf_ch_statrxpausereq;
  wire [9*NUM_CHANNEL-1:0]           gtf_ch_statrxpausevalid;
  wire [9*NUM_CHANNEL-1:0]           gtf_ch_stattxpausevalid;
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

  //wire  [40*NUM_CHANNEL-1:0]         gtf_ch_txrawdata;

  wire  [NUM_CHANNEL-1:0]            gtf_ch_txaxisterr = {NUM_CHANNEL{1'b0}};
  wire  [NUM_CHANNEL-1:0]            gtf_ch_txaxistpoison = {NUM_CHANNEL{1'b0}};
  wire  [NUM_CHANNEL-1:0]            gtf_ch_txaxistready;
  wire  [NUM_CHANNEL-1:0]            gtf_ch_txaxistvalid = {NUM_CHANNEL{1'b1}};
  wire  [2*NUM_CHANNEL-1:0]          gtf_ch_txaxistsof = {NUM_CHANNEL{2'd0}};
  wire  [5*NUM_CHANNEL-1:0]          gtf_ch_txaxistterm = {NUM_CHANNEL{5'd0}};
  wire  [64*NUM_CHANNEL-1:0]         gtf_ch_txaxistdata = {NUM_CHANNEL{64'd0}};
  wire  [8*NUM_CHANNEL-1:0]          gtf_ch_txaxistlast = {NUM_CHANNEL{8'd1}};
  wire  [8*NUM_CHANNEL-1:0]          gtf_ch_txaxistpre  = {NUM_CHANNEL{8'd0}};

  //wire   [40*NUM_CHANNEL-1:0]     gtf_ch_rxrawdata;

  wire              gtf_ch_rxaxisterr;
  wire   [NUM_CHANNEL-1:0]        gtf_ch_rxaxistvalid;
  wire   [1:0]      gtf_ch_rxaxistsof;
  wire   [4:0]      gtf_ch_rxaxistterm;
  wire   [64*NUM_CHANNEL-1:0]     gtf_ch_rxaxistdata;
  wire   [8*NUM_CHANNEL-1:0]      gtf_ch_rxaxistlast;
  wire   [7:0]      gtf_ch_rxaxistpre;
  wire  [4*NUM_CHANNEL-1:0]          gtf_ch_statrxbytes;
  wire   [NUM_CHANNEL-1:0]        gtf_ch_gttxreset_out;

  wire [NUM_CHANNEL-1:0]    status_int_freerun_sync;
  wire [16*NUM_CHANNEL-1:0] tx_prbs_data;
  wire [16*NUM_CHANNEL-1:0] rx_prbs_data;
  //wire [16*NUM_CHANNEL-1:0] prbs_any_chk_error_int;
  wire [NUM_CHANNEL-1:0]    status_int_prbs;

  wire [NUM_CHANNEL-1:0]     rx_clk;
  wire [NUM_CHANNEL-1:0]     tx_clk;
  wire [NUM_CHANNEL-1:0]     tx_resetn;
  wire [NUM_CHANNEL-1:0]     rx_resetn;

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

genvar i;
generate
for (i=0; i<NUM_CHANNEL; i=i+1) begin : gen_blk_multi_ch

  xpm_cdc_async_rst # (
    .DEST_SYNC_FF (5),
    .RST_ACTIVE_HIGH(1)
  ) reset_all_in_sync (
    .dest_clk  (freerun_clk),
    .src_arst  (hb_gtwiz_reset_all_in || ctl_gt_reset_all[i]),
    .dest_arst (gtwiz_reset_all_in[i])
  );

  xpm_cdc_async_rst # (
    .DEST_SYNC_FF (5),
    .RST_ACTIVE_HIGH(1)
  ) reset_tx_dp_in_sync (
    .dest_clk  (freerun_clk),
    .src_arst  (hb_gtf_ch_txdp_reset_in[i] || ctl_gt_reset_all[i]),
    .dest_arst (gtf_ch_txdp_reset_in[i])
  );

  xpm_cdc_async_rst # (
    .DEST_SYNC_FF (5),
    .RST_ACTIVE_HIGH(1)
  ) reset_rx_dp_in_sync (
    .dest_clk  (freerun_clk),
    .src_arst  (hb_gtf_ch_rxdp_reset_in[i] || ctl_gt_reset_all[i]),
    .dest_arst (gtf_ch_rxdp_reset_in[i])
  );

  xpm_cdc_sync_rst # (
   .DEST_SYNC_FF (4),
   .INIT         (1)
  ) u_reset_txdp_sync (
    .src_rst  (gtf_ch_txdp_reset_in[i]),
    .dest_rst (gtwiz_reset_tx_sync[i]),
    .dest_clk (gtf_txusrclk2_out[i])
  );

  xpm_cdc_sync_rst # (
   .DEST_SYNC_FF (4),
   .INIT         (1)
  ) u_gtf_wiz_reset_tx_datapath_init (
    .src_rst  (gtf_wiz_reset_tx_datapath_init_i[i]),
    .dest_rst (gtf_wiz_reset_tx_datapath_init_sync[i]),
    .dest_clk (gtf_txusrclk2_out[i])
  );

  xpm_cdc_sync_rst # (
   .DEST_SYNC_FF (4),
   .INIT         (1)
  ) u_reset_rxdp_sync (
    .src_rst  (gtf_ch_rxdp_reset_in[i]),
    .dest_rst (gtwiz_reset_rx_sync[i]),
    .dest_clk (gtf_rxusrclk2_out[i])
  );

  xpm_cdc_sync_rst # (
   .DEST_SYNC_FF (4),
   .INIT         (1)
  ) u_gtf_wiz_reset_rx_datapath_init (
    .src_rst  (gtf_wiz_reset_rx_datapath_init_i[i]),
    .dest_rst (gtf_wiz_reset_rx_datapath_init_sync[i]),
    .dest_clk (gtf_rxusrclk2_out[i])
  );

reg  [NUM_CHANNEL-1:0]     sys_rst_comb_r;
  
  always @ (posedge freerun_clk)  begin
    sys_rst_comb_r[i]  <=  hb_gtf_ch_txdp_reset_in[i] || ctl_gt_reset_all[i] || hb_gtwiz_reset_all_in;   
  end

  xpm_cdc_async_rst # (
    .DEST_SYNC_FF (5),
    .RST_ACTIVE_HIGH(1)
  ) reset_sys_sync (
    .dest_clk  (sys_clk_out),
    .src_arst  (sys_rst_comb_r[i]),
    .dest_arst (sys_rst_out[i])
  );

  assign gtf_ch_drprst[i]                 =  gtwiz_reset_all_in[i] || ctl_gt_reset_all[i];
    
  assign gtwiz_buffbypass_rx_reset[i] = ~gtf_ch_rxresetdone[i];
 
   assign tx_axis_clk[i]           = gtf_txusrclk2_out[i];
   assign tx_axis_rst[i]           = ~gtf_ch_txresetdone[i];
   /*xpm_cdc_async_rst # (
    .DEST_SYNC_FF (5),
    .RST_ACTIVE_HIGH(1)
   ) reset_all_in_tx_sync (
    .dest_clk  (gtf_txusrclk2_out),
    .src_arst  (hb_gtwiz_reset_all_in || ctl_gt_reset_all[i]),
    .dest_arst (tx_axis_rst[i])
  );*/   
   assign rx_axis_clk[i]           = gtf_rxusrclk2_out[i];
   assign rx_axis_rst[i]           = ~gtf_ch_rxresetdone[i];
   /*xpm_cdc_async_rst # (
    .DEST_SYNC_FF (5),
    .RST_ACTIVE_HIGH(1)
   ) reset_all_in_rx_sync (
    .dest_clk  (gtf_rxusrclk2_out),
    .src_arst  (hb_gtwiz_reset_all_in || ctl_gt_reset_all[i]),
    .dest_arst (rx_axis_rst[i])
   );*/   
   //assign gtf_ch_pcsrsvdout_2[i]   = gtf_ch_pcsrsvdout[(16*i)+2];
    

//  gtfwizard_0_prbs_any # (
//    .CHK_MODE    (0),
//    .INV_PATTERN (1),
//    .POLY_LENGHT (31),
//    .POLY_TAP    (28),
//    .NBITS       (16)
//  ) tx_raw_data_prbs (
//    .RST      (gtwiz_reset_tx_sync[i] || gtf_wiz_reset_tx_datapath_init_sync[i]),
//    .CLK      (gtf_txusrclk2_out[i]),
//    .DATA_IN  (16'b0),
//    .EN       (1'b1),
//    .DATA_OUT (tx_prbs_data[16*(i+1)-1:16*i])
//  );
//
//  assign gtf_ch_txrawdata[40*(i+1)-1:40*i] = {24'd0,tx_prbs_data[16*(i+1)-1:16*i]};
//  
//  assign        status_int_prbs[i] = ~(|prbs_any_chk_error_int[16*(i+1)-1:16*i]);
//  gtfwizard_0_prbs_any # (
//    .CHK_MODE    (1),
//    .INV_PATTERN (1),
//    .POLY_LENGHT (31),
//    .POLY_TAP    (28),
//    .NBITS       (16)
//  ) rx_raw_data_prbs (
//    .RST      (gtwiz_reset_rx_sync[i] || gtf_wiz_reset_rx_datapath_init_sync[i]),
//    .CLK      (gtf_rxusrclk2_out[i]),
//    .DATA_IN  (gtf_ch_rxrawdata[40*(i+1)-25:40*i]),
//    .EN       (1'b1),
//    .DATA_OUT (prbs_any_chk_error_int[16*(i+1)-1:16*i])
//  );
assign        status_int_prbs[i] = 'h0;
    

  // AXI-Lite integration start


  assign rx_clk[i]                        =  gtf_rxusrclk2_out[i];
  assign tx_clk[i]                        =  gtf_txusrclk2_out[i];
  assign tx_resetn[i]                     =  gtf_ch_txresetdone[i];
  assign rx_resetn[i]                     =  gtf_ch_rxresetdone[i];
  assign aresetn[i]                       =  ~gtwiz_reset_all_in[i];

    
    
  //xpm_cdc_single #(
  // .DEST_SYNC_FF(3),   // DECIMAL; range: 2-10
  // .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
  // .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
  // .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
  // ) u_status_int_sync (
  //   .dest_out (status_int_freerun_sync[i]),
  //   .dest_clk (freerun_clk),
  //   .src_clk  (gtf_rxusrclk2_out[i]),
  //   .src_in   (status_int_prbs[i])
  // );
  //
  //always @(posedge freerun_clk) begin
  //  if (gtf_ch_rxdp_reset_in[i] || gtf_wiz_reset_rx_datapath_init_i[i])
  //    link_status_out[i] <= 1'b0;
  //  else
  //    link_status_out[i] <= status_int_freerun_sync[i];
  //end
  //always @(posedge freerun_clk) begin
  //  if (link_down_latched_reset_in[i])
  //    link_down_latched_out[i] <= 1'b0;
  //  else if (!link_status_out[i])
  //    link_down_latched_out[i] <= 1'b1;
  //end  
  //
  //assign link_maintained[i] = ((~link_down_latched_out[i]) && (link_status_out[i]));
  
  assign  wa_complete_flg[i]   =   gtwiz_buffbypass_rx_done_out_i[i];


 
  xpm_cdc_single #(
   .DEST_SYNC_FF(3),   // DECIMAL; range: 2-10
   .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
   .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   .SRC_INPUT_REG(0)   // DECIMAL; 0=do not register input, 1=register input
   ) u_reset_tx_done_out_init_done_inst (
     .dest_out (gtwiz_reset_tx_done_out_init_sync[i]),
     .dest_clk (gtf_ch_drpclk),
     .src_clk  (1'b0),
     .src_in   (gtwiz_reset_tx_done_out[i])
   );

  always @ (posedge gtf_ch_drpclk)
  begin
    tx_init_done_in_r[i]  <=  gtwiz_reset_tx_done_out_init_sync[i] && gtwiz_buffbypass_tx_done_out_i[i];
  end

  xpm_cdc_single #(
   .DEST_SYNC_FF(3),   // DECIMAL; range: 2-10
   .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
   .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   .SRC_INPUT_REG(0)   // DECIMAL; 0=do not register input, 1=register input
   ) u_reset_rx_done_out_init_done_inst (
     .dest_out (gtwiz_reset_rx_done_out_init_sync[i]),
     .dest_clk (gtf_ch_drpclk),
     .src_clk  (1'b0),
     .src_in   (gtwiz_reset_rx_done_out[i])
   );

  always @ (posedge gtf_ch_drpclk)
  begin
    rx_init_done_in_r[i]  <=  gtwiz_reset_rx_done_out_init_sync[i] && gtwiz_buffbypass_rx_done_out_i[i]; 
  end

  // The example initialization module interacts with the reset controller helper block and other example design logic
  // to retry failed reset attempts in order to mitigate bring-up issues such as initially-unavilable reference clocks
  // or data connections. It also resets the receiver in the event of link loss in an attempt to regain link, so please
  // note the possibility that this behavior can have the effect of overriding or disturbing user-provided inputs that
  // destabilize the data stream. It is a demonstration only and can be modified to suit your system needs.
  gtfwizard_0_example_init example_init_inst (
    .clk_freerun_in  (freerun_clk),
    .reset_all_in    (gtwiz_reset_all_in[i]),
    .tx_init_done_in (tx_init_done_in_r[i]),
    .rx_init_done_in (rx_init_done_in_r[i]),
    .rx_data_good_in (1'b1), // status_int_freerun_sync[i]),
    .reset_all_out   (gtf_wiz_reset_tx_datapath_init_i[i]),
    .reset_rx_out    (gtf_wiz_reset_rx_datapath_init_i[i]),
    .init_done_out   (),
    .retry_ctr_out   ()
  );

  always @ (posedge gtwiz_reset_clk_freerun_in)  begin
    gtwiz_reset_tx_datapath_r[i]  <=  gtf_ch_txdp_reset_in[i] || gtf_wiz_reset_tx_datapath_init_i[i] || hwchk_gtf_ch_gttxreset[i]  || gtwiz_reset_tx_datapath_in[i];  
    gtwiz_reset_rx_datapath_r[i]  <=  gtf_ch_rxdp_reset_in[i] || gtf_wiz_reset_rx_datapath_init_i[i] || hwchk_gtf_ch_gtrxreset[i]  || gtwiz_reset_rx_datapath_in[i];  
  end


gtfwizard_0 u_gtf_wiz_ip_top (
.gtwiz_reset_clk_freerun_in                (gtwiz_reset_clk_freerun_in                ),
.gtwiz_reset_all_in                        (gtwiz_reset_all_in[i]                     ),
.gtwiz_reset_tx_pll_and_datapath_in        (gtwiz_reset_tx_pll_and_datapath_in[i]     ),
.gtwiz_reset_rx_pll_and_datapath_in        (gtwiz_reset_rx_pll_and_datapath_in[i]     ),
.gtwiz_reset_tx_datapath_in                (gtwiz_reset_tx_datapath_r[i]              ),
.gtwiz_reset_rx_datapath_in                (gtwiz_reset_rx_datapath_r[i]              ),
.gtwiz_reset_rx_cdr_stable_out             (gtwiz_reset_rx_cdr_stable_out[i]          ),
.gtwiz_reset_tx_done_out                   (gtwiz_reset_tx_done_out[i]                ),
.gtwiz_reset_rx_done_out                   (gtwiz_reset_rx_done_out[i]                ),
.gtwiz_pllreset_rx_out                     (gtwiz_pllreset_rx_out[i]                  ),
.gtwiz_pllreset_tx_out                     (gtwiz_pllreset_tx_out[i]                  ),
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
.gtf_ch_ctltxsendlfi                       (gtf_ch_ctltxsendlfi                       ),
.gtf_ch_ctltxsendrfi                       (gtf_ch_ctltxsendrfi                       ),
.gtf_ch_ctltxsendidle                      (gtf_ch_ctltxsendidle                      ),
.gtf_ch_dmonfiforeset                      (gtf_ch_dmonfiforeset                      ),
.gtf_ch_dmonitorclk                        (gtf_ch_dmonitorclk                        ),
.gtf_ch_drpclk                             (gtf_ch_drpclk                             ),
.gtf_ch_drprst                             (gtf_ch_drprst[i]                          ),

.gtf_ch_eyescanreset                       (gtf_ch_eyescanreset || hwchk_gtf_ch_eyescanreset[i]),
.gtf_ch_eyescantrigger                     (gtf_ch_eyescantrigger                     ),
.gtf_ch_freqos                             (gtf_ch_freqos                             ),
.gtf_ch_gtfrxn                             (gtf_ch_gtfrxn[i]                          ),
.gtf_ch_gtfrxp                             (gtf_ch_gtfrxp[i]                          ),
.gtf_ch_gtgrefclk                          (gtf_ch_gtgrefclk                          ),
.gtf_ch_gtnorthrefclk0                     (gtf_ch_gtnorthrefclk0                     ),
.gtf_ch_gtnorthrefclk1                     (gtf_ch_gtnorthrefclk1                     ),
.gtf_ch_gtrefclk0                          (gtf_ch_gtrefclk0                          ),
.gtf_ch_gtrefclk1                          (gtf_ch_gtrefclk1                          ),
.gtf_ch_gtrxresetsel                       (gtf_ch_gtrxresetsel                       ),
.gtf_ch_gtsouthrefclk0                     (gtf_ch_gtsouthrefclk0                     ),
.gtf_ch_gtsouthrefclk1                     (gtf_ch_gtsouthrefclk1                     ),
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
.gtf_ch_rxdfelpmreset                      (gtf_ch_rxdfelpmreset || hwchk_gtf_ch_rxdfelpmreset[i]),
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
.gtf_ch_rxpcsreset                         (gtf_ch_rxpcsreset || hwchk_gtf_ch_rxpcsreset[i]),
.gtf_ch_rxpmareset                         (gtf_ch_rxpmareset || hwchk_gtf_ch_rxpmareset[i]),
.gtf_ch_rxpolarity                         (gtf_ch_rxpolarity                         ),
.gtf_ch_rxprbscntreset                     (gtf_ch_rxprbscntreset                     ),
.gtf_ch_rxslipoutclk                       (gtf_ch_rxslipoutclk                       ),
.gtf_ch_rxslippma                          (gtf_ch_rxslippma                          ),
.gtf_ch_rxtermination                      (gtf_ch_rxtermination                      ),
.gtf_ch_rxuserrdy                          (hwchk_gtf_ch_rxuserrdy[i]                 ),
.gtf_ch_txaxisterr                         (gtf_ch_txaxisterr[i]                      ),
.gtf_ch_txaxistpoison                      (gtf_ch_txaxistpoison[i]                   ),
.gtf_ch_txaxistvalid                       (gtf_ch_txaxistvalid[i]                    ),
.gtf_ch_txdccforcestart                    (gtf_ch_txdccforcestart                    ),
.gtf_ch_txdccreset                         (gtf_ch_txdccreset                         ),
.gtf_ch_txelecidle                         (gtf_ch_txelecidle                         ),
.gtf_ch_txgbseqsync                        (gtf_ch_txgbseqsync                        ),
.gtf_ch_txmuxdcdexhold                     (gtf_ch_txmuxdcdexhold                     ),
.gtf_ch_txmuxdcdorwren                     (gtf_ch_txmuxdcdorwren                     ),
.gtf_ch_txpcsreset                         (gtf_ch_txpcsreset || hwchk_gtf_ch_txpcsreset[i]),
.gtf_ch_txpippmen                          (gtf_ch_txpippmen                          ),
.gtf_ch_txpippmovrden                      (gtf_ch_txpippmovrden                      ),
.gtf_ch_txpippmpd                          (gtf_ch_txpippmpd                          ),
.gtf_ch_txpippmsel                         (gtf_ch_txpippmsel                         ),
.gtf_ch_txpisopd                           (gtf_ch_txpisopd                           ),
.gtf_ch_txpmareset                         (gtf_ch_txpmareset || hwchk_gtf_ch_txpmareset[i]),
.gtf_ch_txpolarity                         (gtf_ch_txpolarity                         ),
.gtf_ch_txprbsforceerr                     (gtf_ch_txprbsforceerr                     ),
.gtf_ch_txuserrdy                          (hwchk_gtf_ch_txuserrdy[i]                 ),//(gtf_ch_txuserrdy                          ),
.gtf_ch_gtrsvd                             (gtf_ch_gtrsvd                             ),
.gtf_ch_pcsrsvdin                          (gtf_ch_pcsrsvdin                          ),
.gtf_ch_tstin                              (gtf_ch_tstin                              ),
.gtf_ch_rxelecidlemode                     (gtf_ch_rxelecidlemode                     ),
.gtf_ch_rxmonitorsel                       (gtf_ch_rxmonitorsel                       ),
.gtf_ch_rxpd                               (gtf_ch_rxpd                               ),
.gtf_ch_rxpllclksel                        (gtf_ch_rxpllclksel                        ),
.gtf_ch_rxsysclksel                        (gtf_ch_rxsysclksel                        ),
.gtf_ch_txaxistsof                         (gtf_ch_txaxistsof[2*(i+1)-1:2*i]          ),
.gtf_ch_txpd                               (gtf_ch_txpd                               ),
.gtf_ch_txpllclksel                        (gtf_ch_txpllclksel                        ),
.gtf_ch_txsysclksel                        (gtf_ch_txsysclksel                        ),
.gtf_ch_cpllrefclksel                      (gtf_ch_cpllrefclksel                      ),
.gtf_ch_loopback                           (gtf_ch_loopback                           ),
.gtf_ch_rxoutclksel                        (gtf_ch_rxoutclksel                        ),
.gtf_ch_txoutclksel                        (gtf_ch_txoutclksel                        ),
.gtf_ch_txrawdata                          (gtf_ch_txrawdata[40*(i+1)-1:40*i]         ),
.gtf_ch_rxdfecfokfcnum                     (gtf_ch_rxdfecfokfcnum                     ),
.gtf_ch_rxprbssel                          (gtf_ch_rxprbssel                          ),
.gtf_ch_txprbssel                          (gtf_ch_txprbssel                          ),
.gtf_ch_txaxistterm                        (gtf_ch_txaxistterm[5*(i+1)-1:5*i]         ),
.gtf_ch_txdiffctrl                         (gtf_ch_txdiffctrl                         ),
.gtf_ch_txpippmstepsize                    (gtf_ch_txpippmstepsize                    ),
.gtf_ch_txpostcursor                       (gtf_ch_txpostcursor                       ),
.gtf_ch_txprecursor                        (gtf_ch_txprecursor                        ),
.gtf_ch_txaxistdata                        (gtf_ch_txaxistdata[64*(i+1)-1:64*i]       ),
.gtf_ch_rxckcalstart                       (gtf_ch_rxckcalstart                       ),
.gtf_ch_txmaincursor                       (gtf_ch_txmaincursor                       ),
.gtf_ch_txaxistlast                        (gtf_ch_txaxistlast[8*(i+1)-1:8*i]         ),
.gtf_ch_txaxistpre                         (gtf_ch_txaxistpre[8*(i+1)-1:8*i]          ),
.gtf_ch_ctlrxpauseack                      (gtf_ch_ctlrxpauseack                      ),
.gtf_ch_ctltxpausereq                      (gtf_ch_ctltxpausereq                      ),
.gtf_ch_cpllfbclklost                      (                                          ),
.gtf_ch_cplllock                           (                                          ),
.gtf_ch_cpllrefclklost                     (                                          ),
.gtf_ch_dmonitoroutclk                     (                                          ),
.gtf_ch_eyescandataerror                   (                                          ),
.gtf_ch_gtftxn                             (gtf_ch_gtftxn[i]                          ),
.gtf_ch_gtftxp                             (gtf_ch_gtftxp[i]                          ),
.gtf_ch_gtpowergood                        (gtf_ch_gtpowergood[i]                     ),
.gtf_ch_gtrefclkmonitor                    (                                          ),
.gtf_ch_resetexception                     (                                          ),
.gtf_ch_rxaxisterr                         (                                          ),
.gtf_ch_rxaxistvalid                       (gtf_ch_rxaxistvalid[i]                    ),
.gtf_ch_rxbitslip                          (                                          ),
.gtf_ch_rxcdrlock                          (gtf_ch_rxcdrlock[i]                       ),
.gtf_ch_rxcdrphdone                        (                                          ),
.gtf_ch_rxckcaldone                        (                                          ),
.gtf_ch_rxelecidle                         (                                          ),
.gtf_ch_rxgbseqstart                       (                                          ),
.gtf_ch_rxosintdone                        (                                          ),
.gtf_ch_rxosintstarted                     (                                          ),
.gtf_ch_rxosintstrobedone                  (                                          ),
.gtf_ch_rxosintstrobestarted               (                                          ),
.gtf_ch_rxoutclk                           (                                          ),
.gtf_ch_rxoutclkfabric                     (                                          ),
.gtf_ch_rxoutclkpcs                        (                                          ),
.gtf_ch_rxphalignerr                       (                                          ),
.gtf_ch_rxpmaresetdone                     (gtf_ch_rxpmaresetdone[i]                  ),
.gtf_ch_rxprbserr                          (                                          ),
.gtf_ch_rxprbslocked                       (                                          ),
.gtf_ch_rxprgdivresetdone                  (                                          ),
.gtf_ch_rxptpsop                           (                                          ),
.gtf_ch_rxptpsoppos                        (                                          ),
.gtf_ch_rxrecclkout                        (                                          ),
.gtf_ch_rxresetdone                        (gtf_ch_rxresetdone[i]                     ),
.gtf_ch_rxslipdone                         (                                          ),
.gtf_ch_rxslipoutclkrdy                    (                                          ),
.gtf_ch_rxslippmardy                       (                                          ),
.gtf_ch_rxsyncdone                         (gtf_ch_rxsyncdone[i]                      ),
.gtf_ch_statrxbadcode                      (                                          ),
.gtf_ch_statrxbadfcs                       (                                          ),
.gtf_ch_statrxbadpreamble                  (                                          ),
.gtf_ch_statrxbadsfd                       (                                          ),
.gtf_ch_statrxblocklock                    (gtf_ch_statrxblocklock[i]                 ),
.gtf_ch_statrxbroadcast                    (                                          ),
.gtf_ch_statrxfcserr                       (                                          ),
.gtf_ch_statrxframingerr                   (                                          ),
.gtf_ch_statrxgotsignalos                  (                                          ),
.gtf_ch_statrxhiber                        (                                          ),
.gtf_ch_statrxinrangeerr                   (                                          ),
.gtf_ch_statrxinternallocalfault           (gtf_ch_statrxinternallocalfault[i]        ),
.gtf_ch_statrxlocalfault                   (gtf_ch_statrxlocalfault[i]                ),
.gtf_ch_statrxmulticast                    (                                          ),
.gtf_ch_statrxpkt                          (                                          ),
.gtf_ch_statrxpkterr                       (                                          ),
.gtf_ch_statrxreceivedlocalfault           (gtf_ch_statrxreceivedlocalfault[i]        ),
.gtf_ch_statrxremotefault                  (gtf_ch_statrxremotefault[i]               ),
.gtf_ch_statrxstatus                       (                                          ),
.gtf_ch_statrxstompedfcs                   (                                          ),
.gtf_ch_statrxtestpatternmismatch          (                                          ),
.gtf_ch_statrxtruncated                    (                                          ),
.gtf_ch_statrxunicast                      (                                          ),
.gtf_ch_statrxvalidctrlcode                (                                          ),
.gtf_ch_statrxvlan                         (                                          ),
.gtf_ch_stattxbadfcs                       (                                          ),
.gtf_ch_stattxbroadcast                    (                                          ),
.gtf_ch_stattxfcserr                       (                                          ),
.gtf_ch_stattxmulticast                    (                                          ),
.gtf_ch_stattxpkt                          (                                          ),
.gtf_ch_stattxpkterr                       (                                          ),
.gtf_ch_stattxunicast                      (                                          ),
.gtf_ch_stattxvlan                         (                                          ),
.gtf_ch_txaxistready                       (gtf_ch_txaxistready[i]                    ),
.gtf_ch_txdccdone                          (                          ),
.gtf_ch_txgbseqstart                       (                       ),
.gtf_ch_txoutclk                           (                           ),
.gtf_ch_txoutclkfabric                     (                     ),
.gtf_ch_txoutclkpcs                        (                        ),
.gtf_ch_txpmaresetdone                     (gtf_ch_txpmaresetdone[i]                  ),
.gtf_ch_txprgdivresetdone                  (                  ),
.gtf_ch_txptpsop                           (                        ),
.gtf_ch_txptpsoppos                        (                     ),
.gtf_ch_txresetdone                        (gtf_ch_txresetdone[i]                     ),
.gtf_ch_txsyncdone                         (gtf_ch_txsyncdone[i]                      ),
.gtf_ch_txunfout                           (                                          ),
.gtf_ch_txaxistcanstart                    (                                          ),
.gtf_ch_rxinvalidstart                     (                           ),
.gtf_ch_pcsrsvdout                         (        ),
.gtf_ch_pinrsrvdas                         (                         ),
.gtf_ch_rxaxistsof                         (                         ),
.gtf_ch_rxrawdata                          (gtf_ch_rxrawdata[40*(i+1)-1:40*i]         ),
.gtf_ch_statrxbytes                        (gtf_ch_statrxbytes[4*(i+1)-1:4*i]         ),
.gtf_ch_stattxbytes                        (         ),
.gtf_ch_rxaxistterm                        (                        ),
.gtf_ch_rxaxistdata                        (gtf_ch_rxaxistdata[64*(i+1)-1:64*i]       ),
.gtf_ch_rxaxistlast                        (gtf_ch_rxaxistlast[8*(i+1)-1:8*i]         ),
.gtf_ch_rxaxistpre                         (                                          ),
.gtf_ch_rxmonitorout                       (                                          ),
.gtf_ch_statrxpausequanta                  (                                          ),
.gtf_ch_statrxpausereq                     (                                          ),
.gtf_ch_statrxpausevalid                   (                                          ),
.gtf_ch_stattxpausevalid                   (                                          ),
.gtf_ch_gttxreset_out                      (gtf_ch_gttxreset_out[i]                   ),
 .gtwiz_buffbypass_tx_done_out             (gtwiz_buffbypass_tx_done_out_i[i]         ),
 .gtwiz_buffbypass_rx_done_out         (gtwiz_buffbypass_rx_done_out_i[i]        ),
.gtf_txusrclk2_out                         (gtf_txusrclk2_out[i]                      ),
.gtf_rxusrclk2_out                         (gtf_rxusrclk2_out[i]                      )
);

end
endgenerate

gtfwizard_0_example_gtf_common # (
.AEN_QPLL0_FBDIV             (AEN_QPLL0_FBDIV             ),
.AEN_QPLL1_FBDIV             (AEN_QPLL1_FBDIV             ),
.AEN_SDM0TOGGLE              (AEN_SDM0TOGGLE              ),
.AEN_SDM1TOGGLE              (AEN_SDM1TOGGLE              ),
.A_SDM0TOGGLE                (A_SDM0TOGGLE                ),
.A_SDM1DATA_HIGH             (A_SDM1DATA_HIGH             ),
.A_SDM1DATA_LOW              (A_SDM1DATA_LOW              ),
.A_SDM1TOGGLE                (A_SDM1TOGGLE                ),
.BIAS_CFG0                   (BIAS_CFG0                   ),
.BIAS_CFG1                   (BIAS_CFG1                   ),
.BIAS_CFG2                   (BIAS_CFG2                   ),
.BIAS_CFG3                   (BIAS_CFG3                   ),
.BIAS_CFG4                   (BIAS_CFG4                   ),
.BIAS_CFG_RSVD               (BIAS_CFG_RSVD               ),
.COMMON_CFG0                 (COMMON_CFG0                 ),
.COMMON_CFG1                 (COMMON_CFG1                 ),
.POR_CFG                     (POR_CFG                     ),
.PPF0_CFG                    (PPF0_CFG                    ),
.PPF1_CFG                    (PPF1_CFG                    ),
.QPLL0CLKOUT_RATE            (QPLL0CLKOUT_RATE            ),
.QPLL0_CFG0                  (QPLL0_CFG0                  ),
.QPLL0_CFG1                  (QPLL0_CFG1                  ),
.QPLL0_CFG1_G3               (QPLL0_CFG1_G3               ),
.QPLL0_CFG2                  (QPLL0_CFG2                  ),
.QPLL0_CFG2_G3               (QPLL0_CFG2_G3               ),
.QPLL0_CFG3                  (QPLL0_CFG3                  ),
.QPLL0_CFG4                  (QPLL0_CFG4                  ),
.QPLL0_CP                    (QPLL0_CP                    ),
.QPLL0_CP_G3                 (QPLL0_CP_G3                 ),
.QPLL0_FBDIV                 (QPLL0_FBDIV                 ),
.QPLL0_FBDIV_G3              (QPLL0_FBDIV_G3              ),
.QPLL0_INIT_CFG0             (QPLL0_INIT_CFG0             ),
.QPLL0_INIT_CFG1             (QPLL0_INIT_CFG1             ),
.QPLL0_LOCK_CFG              (QPLL0_LOCK_CFG              ),
.QPLL0_LOCK_CFG_G3           (QPLL0_LOCK_CFG_G3           ),
.QPLL0_LPF                   (QPLL0_LPF                   ),
.QPLL0_LPF_G3                (QPLL0_LPF_G3                ),
.QPLL0_PCI_EN                (QPLL0_PCI_EN                ),
.QPLL0_RATE_SW_USE_DRP       (QPLL0_RATE_SW_USE_DRP       ),
.QPLL0_REFCLK_DIV            (QPLL0_REFCLK_DIV            ),
.QPLL0_SDM_CFG0              (QPLL0_SDM_CFG0              ),
.QPLL0_SDM_CFG1              (QPLL0_SDM_CFG1              ),
.QPLL0_SDM_CFG2              (QPLL0_SDM_CFG2              ),
.QPLL1CLKOUT_RATE            (QPLL1CLKOUT_RATE            ),
.QPLL1_CFG0                  (QPLL1_CFG0                  ),
.QPLL1_CFG1                  (QPLL1_CFG1                  ),
.QPLL1_CFG1_G3               (QPLL1_CFG1_G3               ),
.QPLL1_CFG2                  (QPLL1_CFG2                  ),
.QPLL1_CFG2_G3               (QPLL1_CFG2_G3               ),
.QPLL1_CFG3                  (QPLL1_CFG3                  ),
.QPLL1_CFG4                  (QPLL1_CFG4                  ),
.QPLL1_CP                    (QPLL1_CP                    ),
.QPLL1_CP_G3                 (QPLL1_CP_G3                 ),
.QPLL1_FBDIV                 (QPLL1_FBDIV                 ),
.QPLL1_FBDIV_G3              (QPLL1_FBDIV_G3              ),
.QPLL1_INIT_CFG0             (QPLL1_INIT_CFG0             ),
.QPLL1_INIT_CFG1             (QPLL1_INIT_CFG1             ),
.QPLL1_LOCK_CFG              (QPLL1_LOCK_CFG              ),
.QPLL1_LOCK_CFG_G3           (QPLL1_LOCK_CFG_G3           ),
.QPLL1_LPF                   (QPLL1_LPF                   ),
.QPLL1_LPF_G3                (QPLL1_LPF_G3                ),
.QPLL1_PCI_EN                (QPLL1_PCI_EN                ),
.QPLL1_RATE_SW_USE_DRP       (QPLL1_RATE_SW_USE_DRP       ),
.QPLL1_REFCLK_DIV            (QPLL1_REFCLK_DIV            ),
.QPLL1_SDM_CFG0              (QPLL1_SDM_CFG0              ),
.QPLL1_SDM_CFG1              (QPLL1_SDM_CFG1              ),
.QPLL1_SDM_CFG2              (QPLL1_SDM_CFG2              ),
.RSVD_ATTR0                  (RSVD_ATTR0                  ),
.RSVD_ATTR1                  (RSVD_ATTR1                  ),
.RSVD_ATTR2                  (RSVD_ATTR2                  ),
.RSVD_ATTR3                  (RSVD_ATTR3                  ),
.RXRECCLKOUT0_SEL            (RXRECCLKOUT0_SEL            ),
.RXRECCLKOUT1_SEL            (RXRECCLKOUT1_SEL            ),
.SARC_ENB                    (SARC_ENB                    ),
.SARC_SEL                    (SARC_SEL                    ),
.SDM0INITSEED0_0             (SDM0INITSEED0_0             ),
.SDM0INITSEED0_1             (SDM0INITSEED0_1             ),
.SDM1INITSEED0_0             (SDM1INITSEED0_0             ),
.SDM1INITSEED0_1             (SDM1INITSEED0_1             ),
.SIM_MODE                    (SIM_MODE                    ),
.SIM_RESET_SPEEDUP           (SIM_RESET_SPEEDUP           )
) example_gtf_common_inst(
  .gtf_cm_bgbypassb                 (gtf_cm_bgbypassb                 ),
  .gtf_cm_bgmonitorenb              (gtf_cm_bgmonitorenb              ),
  .gtf_cm_bgpdb                     (gtf_cm_bgpdb                     ),
  .gtf_cm_bgrcalovrdenb             (gtf_cm_bgrcalovrdenb             ),
  .gtf_cm_drpclk                    (gtf_cm_drpclk                    ),
  .gtf_cm_drpen                     (gtf_cm_drpen                     ),
  .gtf_cm_drpwe                     (gtf_cm_drpwe                     ),
  .gtf_cm_gtgrefclk0                (gtf_cm_gtgrefclk0                ),
  .gtf_cm_gtgrefclk1                (gtf_cm_gtgrefclk1                ),
  .gtf_cm_gtnorthrefclk00           (gtf_cm_gtnorthrefclk00           ),
  .gtf_cm_gtnorthrefclk01           (gtf_cm_gtnorthrefclk01           ),
  .gtf_cm_gtnorthrefclk10           (gtf_cm_gtnorthrefclk10           ),
  .gtf_cm_gtnorthrefclk11           (gtf_cm_gtnorthrefclk11           ),
  .gtf_cm_gtrefclk00                (gtf_cm_gtrefclk00                ),
  .gtf_cm_gtrefclk01                (gtf_cm_gtrefclk01                ),
  .gtf_cm_gtrefclk10                (gtf_cm_gtrefclk10                ),
  .gtf_cm_gtrefclk11                (gtf_cm_gtrefclk11                ),
  .gtf_cm_gtsouthrefclk00           (gtf_cm_gtsouthrefclk00           ),
  .gtf_cm_gtsouthrefclk01           (gtf_cm_gtsouthrefclk01           ),
  .gtf_cm_gtsouthrefclk10           (gtf_cm_gtsouthrefclk10           ),
  .gtf_cm_gtsouthrefclk11           (gtf_cm_gtsouthrefclk11           ),
  .gtf_cm_qpll0clkrsvd0             (gtf_cm_qpll0clkrsvd0             ),
  .gtf_cm_qpll0clkrsvd1             (gtf_cm_qpll0clkrsvd1             ),
  .gtf_cm_qpll0lockdetclk           (gtf_cm_qpll0lockdetclk           ),
  .gtf_cm_qpll0locken               (gtf_cm_qpll0locken               ),
  .gtf_cm_qpll0pd                   (gtf_cm_qpll0pd                   ),
  .gtf_cm_qpll0reset                (gtf_cm_qpll0reset                ),
  .gtf_cm_qpll1clkrsvd0             (gtf_cm_qpll1clkrsvd0             ),
  .gtf_cm_qpll1clkrsvd1             (gtf_cm_qpll1clkrsvd1             ),
  .gtf_cm_qpll1lockdetclk           (gtf_cm_qpll1lockdetclk           ),
  .gtf_cm_qpll1locken               (gtf_cm_qpll1locken               ),
  .gtf_cm_qpll1pd                   (gtf_cm_qpll1pd                   ),
  .gtf_cm_qpll1reset                (gtf_cm_qpll1reset                ),
  .gtf_cm_rcalenb                   (gtf_cm_rcalenb                   ),
  .gtf_cm_sdm0reset                 (gtf_cm_sdm0reset                 ),
  .gtf_cm_sdm0toggle                (gtf_cm_sdm0toggle                ),
  .gtf_cm_sdm1reset                 (gtf_cm_sdm1reset                 ),
  .gtf_cm_sdm1toggle                (gtf_cm_sdm1toggle                ),
  .gtf_cm_drpaddr                   (gtf_cm_drpaddr                   ),
  .gtf_cm_drpdi                     (gtf_cm_drpdi                     ),
  .gtf_cm_sdm0width                 (gtf_cm_sdm0width                 ),
  .gtf_cm_sdm1width                 (gtf_cm_sdm1width                 ),
  .gtf_cm_sdm0data                  (gtf_cm_sdm0data                  ),
  .gtf_cm_sdm1data                  (gtf_cm_sdm1data                  ),
  .gtf_cm_qpll0refclksel            (gtf_cm_qpll0refclksel            ),
  .gtf_cm_qpll1refclksel            (gtf_cm_qpll1refclksel            ),
  .gtf_cm_bgrcalovrd                (gtf_cm_bgrcalovrd                ),
  .gtf_cm_qpllrsvd2                 (gtf_cm_qpllrsvd2                 ),
  .gtf_cm_qpllrsvd3                 (gtf_cm_qpllrsvd3                 ),
  .gtf_cm_pmarsvd0                  (gtf_cm_pmarsvd0                  ),
  .gtf_cm_pmarsvd1                  (gtf_cm_pmarsvd1                  ),
  .gtf_cm_qpll0fbdiv                (gtf_cm_qpll0fbdiv                ),
  .gtf_cm_qpll1fbdiv                (gtf_cm_qpll1fbdiv                ),
  .gtf_cm_qpllrsvd1                 (gtf_cm_qpllrsvd1                 ),
  .gtf_cm_qpllrsvd4                 (gtf_cm_qpllrsvd4                 ),
  .gtf_cm_drprdy                    (gtf_cm_drprdy                    ),
  .gtf_cm_qpll0fbclklost            (gtf_cm_qpll0fbclklost            ),
  .gtf_cm_qpll0lock                 (gtf_cm_qpll0lock                 ),
  .gtf_cm_qpll0outclk               (gtf_cm_qpll0outclk               ),
  .gtf_cm_qpll0outrefclk            (gtf_cm_qpll0outrefclk            ),
  .gtf_cm_qpll0refclklost           (gtf_cm_qpll0refclklost           ),
  .gtf_cm_qpll1fbclklost            (gtf_cm_qpll1fbclklost            ),
  .gtf_cm_qpll1lock                 (gtf_cm_qpll1lock                 ),
  .gtf_cm_qpll1outclk               (gtf_cm_qpll1outclk               ),
  .gtf_cm_qpll1outrefclk            (gtf_cm_qpll1outrefclk            ),
  .gtf_cm_qpll1refclklost           (gtf_cm_qpll1refclklost           ),
  .gtf_cm_refclkoutmonitor0         (gtf_cm_refclkoutmonitor0         ),
  .gtf_cm_refclkoutmonitor1         (gtf_cm_refclkoutmonitor1         ),
  .gtf_cm_sdm0testdata              (gtf_cm_sdm0testdata              ),
  .gtf_cm_sdm1testdata              (gtf_cm_sdm1testdata              ),
  .gtf_cm_drpdo                     (gtf_cm_drpdo                     ),
  .gtf_cm_rxrecclk0sel              (gtf_cm_rxrecclk0sel              ),
  .gtf_cm_rxrecclk1sel              (gtf_cm_rxrecclk1sel              ),
  .gtf_cm_sdm0finalout              (gtf_cm_sdm0finalout              ),
  .gtf_cm_sdm1finalout              (gtf_cm_sdm1finalout              ),
  .gtf_cm_pmarsvdout0               (gtf_cm_pmarsvdout0               ),
  .gtf_cm_pmarsvdout1               (gtf_cm_pmarsvdout1               ),
  .gtf_cm_qplldmonitor0             (gtf_cm_qplldmonitor0             ),
  .gtf_cm_qplldmonitor1             (gtf_cm_qplldmonitor1             )
);


  /////////////////DRP Switching Start//////////////////
  
  //wire gtwiz_buffbypass_rx_reset;
  wire gtwiz_buffbypass_tx_reset; //EG new
  assign gtwiz_buffbypass_rx_reset = ~gtf_ch_rxresetdone[0]; //new this one is in rxusrclk domain already, was ~gtf_ch_rxpmaresetdone
  assign gtwiz_buffbypass_tx_reset = ~gtf_ch_txresetdone[0]; //EG new
  wire AM_switch = 0;
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
    .gtwiz_buffbypass_rx_reset_in (gtwiz_buffbypass_rx_reset[0]),
    
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

 assign gtf_cm_qpll0_lock = plllock_tx_in;

  wire          drp_bridge_drpen;
  wire          drp_bridge_drpwe;
  wire [9:0]    drp_bridge_drpaddr;
  wire [15:0]   drp_bridge_drpdo;
  wire          drp_bridge_drprdy;
  wire [15:0]   drp_bridge_drpdi;

gtfraw_wrapper_drp_bridge #(
    .DRP_COUNT(2),
    .DRP_ADDR_WIDTH(10),
    .DRP_DATA_WIDTH(16)
    ) u_gtfraw_wrapper_drp_bridge (
  .s_axi_aclk       (aclk),
  .s_axi_aresetn    (aresetn),
  .s_axi_awaddr     (m0_axi_awaddr),
  .s_axi_awvalid    (m0_axi_awvalid),
  .s_axi_awready    (m0_axi_awready),
  .s_axi_wdata      (m0_axi_wdata),
  .s_axi_wstrb      (m0_axi_wstrb),
  .s_axi_wvalid     (m0_axi_wvalid),
  .s_axi_wready     (m0_axi_wready),
  .s_axi_bresp      (m0_axi_bresp),
  .s_axi_bvalid     (m0_axi_bvalid),
  .s_axi_bready     (m0_axi_bready),
  .s_axi_araddr     (m0_axi_araddr),
  .s_axi_arvalid    (m0_axi_arvalid),
  .s_axi_arready    (m0_axi_arready),
  .s_axi_rdata      (m0_axi_rdata),
  .s_axi_rresp      (m0_axi_rresp),
  .s_axi_rvalid     (m0_axi_rvalid),
  .s_axi_rready     (m0_axi_rready),
  
  .drp_en   (   ), //{gtf_cm_drpen,drp_bridge_drpen}),
  .drp_we   (   ), //{gtf_cm_drpwe,drp_bridge_drpwe}),
  .drp_addr (   ), //{gtf_cm_drpaddr[9:0],drp_bridge_drpaddr[9:0]}),
  .drp_di   (   ), //{gtf_cm_drpdi,drp_bridge_drpdi}),
  .drp_do   ('h0), //{gtf_cm_drpdo,drp_bridge_drpdo}),
  .drp_rdy  ('h3)  //{gtf_cm_drprdy,drp_bridge_drprdy})

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


gtfraw_wrapper_axi_custom_crossbar_gtfraw i_custom_crossbar_gtfraw (
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

  wire rx_reset_axi_not_sync ;
  wire tx_reset_axi_not_sync ;
  gtfraw_wrapper_axi_if_soft_top i_axi_if_soft_top (

    .rx_clk                          ( rx_clk[0]                         ),
    .tx_clk                          ( tx_clk[0]                         ),
    .rx_resetn                       ( rx_resetn[0]                      ),
    .tx_resetn                       ( tx_resetn[0]                      ),

    .rx_resetn_out                   ( rx_reset_axi_not_sync             ),
    .tx_resetn_out                   ( tx_reset_axi_not_sync             ),

    .s_axi_aclk                      ( aclk                              ),
    .s_axi_aresetn                   ( aresetn                           ),
    .s_axi_awaddr                    ( m1_axi_awaddr                     ),
    .s_axi_awvalid                   ( m1_axi_awvalid                    ),
    .s_axi_awready                   ( m1_axi_awready                    ),
    .s_axi_wdata                     ( m1_axi_wdata                      ),
    .s_axi_wstrb                     ( m1_axi_wstrb                      ),
    .s_axi_wvalid                    ( m1_axi_wvalid                     ),
    .s_axi_wready                    ( m1_axi_wready                     ),
    .s_axi_bresp                     ( m1_axi_bresp                      ),
    .s_axi_bvalid                    ( m1_axi_bvalid                     ),
    .s_axi_bready                    ( m1_axi_bready                     ),
    .s_axi_araddr                    ( m1_axi_araddr                     ),
    .s_axi_arvalid                   ( m1_axi_arvalid                    ),
    .s_axi_arready                   ( m1_axi_arready                    ),
    .s_axi_rdata                     ( m1_axi_rdata                      ),
    .s_axi_rresp                     ( m1_axi_rresp                      ),
    .s_axi_rvalid                    ( m1_axi_rvalid                     ),
    .s_axi_rready                    ( m1_axi_rready                     ),
    .pm_tick                         ( 1'b0                              ),
    
    .ctl_local_loopback              ( ctl_local_loopback                ),
    .ctl_gt_reset_all                ( ctl_gt_reset_all                  ),
    .ctl_gt_tx_reset                 ( gtf_ch_gttxreset                  ),
    .ctl_gt_rx_reset                 ( gtf_ch_gtrxreset                  ),
    .ctl_tx_send_lfi                 ( ctl_tx_send_lfi_axi               ),
    .ctl_tx_send_rfi                 ( ctl_tx_send_rfi_axi               ),
    .ctl_tx_send_idle                ( ctl_tx_send_idle_axi              ),

    .stat_rx_hi_ber                  ( 'h0 ), //gtf_ch_statrxhiber                ),
    .stat_rx_status                  ( 'h0 ), //gtf_ch_statrxstatus               ),
    .stat_rx_clk_align               ( 'h0 ), //1'b0                              ),
    .stat_rx_bit_slip                ( 'h0 ), //1'b0                              ),
    .stat_rx_pkt_err                 ( 'h0 ), //gtf_ch_statrxpkterr               ),
    .stat_rx_bad_preamble            ( 'h0 ), //gtf_ch_statrxbadpreamble          ),
    .stat_rx_bad_sfd                 ( 'h0 ), //gtf_ch_statrxbadsfd               ),
    .stat_rx_got_signal_os           ( 'h0 ), //gtf_ch_statrxgotsignalos          ),
    .stat_rx_local_fault             ( 'h0 ), //gtf_ch_statrxlocalfault           ),
    .stat_rx_remote_fault            ( 'h0 ), //gtf_ch_statrxremotefault          ),
    .stat_rx_internal_local_fault    ( 'h0 ), //gtf_ch_statrxinternallocalfault   ),
    .stat_rx_received_local_fault    ( 'h0 ), //gtf_ch_statrxreceivedlocalfault   ),

    .stat_rx_framing_err             ( 'h0 ), //stat_rx_framing_err_R             ),
    .stat_rx_bad_code                ( 'h0 ), //gtf_ch_statrxbadcode_R            ),
    .stat_rx_total_packets           ( 'h0 ), //stat_rx_total_packets_R           ),
    .stat_rx_total_good_packets      ( 'h0 ), //stat_rx_total_good_packets_R      ),
    .stat_rx_total_bytes             ( 'h0 ), //stat_rx_total_bytes_R             ),
    .stat_rx_total_good_bytes        ( 'h0 ), //stat_rx_total_good_bytes_R        ),
    .stat_rx_packet_small            ( 'h0 ), //stat_rx_packet_small_R            ),
    .stat_rx_jabber                  ( 'h0 ), //stat_rx_jabber_R                  ),
    .stat_rx_packet_large            ( 'h0 ), //stat_rx_packet_large_R            ),
    .stat_rx_oversize                ( 'h0 ), //stat_rx_oversize_R                ),
    .stat_rx_undersize               ( 'h0 ), //stat_rx_undersize_R               ),
    .stat_rx_toolong                 ( 'h0 ), //stat_rx_toolong_R                 ),
    .stat_rx_fragment                ( 'h0 ), //stat_rx_fragment_R                ),
    .stat_rx_packet_64_bytes         ( 'h0 ), //stat_rx_packet_64_bytes_R         ),
    .stat_rx_packet_65_127_bytes     ( 'h0 ), //stat_rx_packet_65_127_bytes_R     ),
    .stat_rx_packet_128_255_bytes    ( 'h0 ), //stat_rx_packet_128_255_bytes_R    ),
    .stat_rx_packet_256_511_bytes    ( 'h0 ), //stat_rx_packet_256_511_bytes_R    ),
    .stat_rx_packet_512_1023_bytes   ( 'h0 ), //stat_rx_packet_512_1023_bytes_R   ),
    .stat_rx_packet_1024_1518_bytes  ( 'h0 ), //stat_rx_packet_1024_1518_bytes_R  ),
    .stat_rx_packet_1519_1522_bytes  ( 'h0 ), //stat_rx_packet_1519_1522_bytes_R  ),
    .stat_rx_packet_1523_1548_bytes  ( 'h0 ), //stat_rx_packet_1523_1548_bytes_R  ),
    .stat_rx_total_err_bytes         ( 'h0 ), //stat_rx_total_err_bytes_R         ),
    .stat_rx_bad_fcs                 ( 'h0 ), //stat_rx_bad_fcs_R                 ),
    .stat_rx_packet_bad_fcs          ( 'h0 ), //stat_rx_packet_bad_fcs_R          ),
    .stat_rx_stomped_fcs             ( 'h0 ), //gtf_ch_statrxstompedfcs_R         ),
    .stat_rx_packet_1549_2047_bytes  ( 'h0 ), //stat_rx_packet_1549_2047_bytes_R  ),
    .stat_rx_packet_2048_4095_bytes  ( 'h0 ), //stat_rx_packet_2048_4095_bytes_R  ),
    .stat_rx_packet_4096_8191_bytes  ( 'h0 ), //stat_rx_packet_4096_8191_bytes_R  ),
    .stat_rx_packet_8192_9215_bytes  ( 'h0 ), //stat_rx_packet_8192_9215_bytes_R  ),
    .stat_rx_unicast                 ( 'h0 ), //stat_rx_unicast_R                 ),
    .stat_rx_multicast               ( 'h0 ), //stat_rx_multicast_R               ),
    .stat_rx_broadcast               ( 'h0 ), //stat_rx_broadcast_R               ),
    .stat_rx_vlan                    ( 'h0 ), //stat_rx_vlan_R                    ),
    .stat_rx_pause                   ( 'h0 ), //stat_rx_pause_R                   ),
    .stat_rx_user_pause              ( 'h0 ), //stat_rx_user_pause_R              ),
    .stat_rx_inrangeerr              ( 'h0 ), //stat_rx_inrangeerr_R              ),
    .stat_rx_truncated               ( 'h0 ), //gtf_ch_statrxtruncated_R          ),
    .stat_tx_total_packets           ( 'h0 ), //stat_tx_total_packets_R           ),
    .stat_tx_total_bytes             ( 'h0 ), //stat_tx_total_bytes_R             ),
    .stat_tx_total_good_packets      ( 'h0 ), //stat_tx_total_good_packets_R      ),
    .stat_tx_total_good_bytes        ( 'h0 ), //stat_tx_total_good_bytes_R        ),
    .stat_tx_packet_64_bytes         ( 'h0 ), //stat_tx_packet_64_bytes_R         ),
    .stat_tx_packet_65_127_bytes     ( 'h0 ), //stat_tx_packet_65_127_bytes_R     ),
    .stat_tx_packet_128_255_bytes    ( 'h0 ), //stat_tx_packet_128_255_bytes_R    ),
    .stat_tx_packet_256_511_bytes    ( 'h0 ), //stat_tx_packet_256_511_bytes_R    ),
    .stat_tx_packet_512_1023_bytes   ( 'h0 ), //stat_tx_packet_512_1023_bytes_R   ),
    .stat_tx_packet_1024_1518_bytes  ( 'h0 ), //stat_tx_packet_1024_1518_bytes_R  ),
    .stat_tx_packet_1519_1522_bytes  ( 'h0 ), //stat_tx_packet_1519_1522_bytes_R  ),
    .stat_tx_packet_1523_1548_bytes  ( 'h0 ), //stat_tx_packet_1523_1548_bytes_R  ),
    .stat_tx_packet_large            ( 'h0 ), //stat_tx_packet_large_R            ),
    .stat_tx_packet_small            ( 'h0 ), //stat_tx_packet_small_R            ),
    .stat_tx_total_err_bytes         ( 'h0 ), //stat_tx_total_err_bytes_R         ),
    .stat_tx_packet_1549_2047_bytes  ( 'h0 ), //stat_tx_packet_1549_2047_bytes_R  ),
    .stat_tx_packet_2048_4095_bytes  ( 'h0 ), //stat_tx_packet_2048_4095_bytes_R  ),
    .stat_tx_packet_4096_8191_bytes  ( 'h0 ), //stat_tx_packet_4096_8191_bytes_R  ),
    .stat_tx_packet_8192_9215_bytes  ( 'h0 ), //stat_tx_packet_8192_9215_bytes_R  ),
    .stat_tx_unicast                 ( 'h0 ), //stat_tx_unicast_R                 ),
    .stat_tx_multicast               ( 'h0 ), //stat_tx_multicast_R               ),
    .stat_tx_broadcast               ( 'h0 ), //stat_tx_broadcast_R               ),
    .stat_tx_vlan                    ( 'h0 ), //stat_tx_vlan_R                    ),
    .stat_tx_bad_fcs                 ( 'h0 ), //stat_tx_bad_fcs_R                 ),
    .stat_tx_frame_error             ( 'h0 )  //stat_tx_frame_error_R             )
  );

    // Search Rx raw data for bit alignment....
    wire sync_det ;
    
/*
    gtf_ch_rxrawdata_syncdet gtf_ch_rxrawdata_syncdet (
        .gtwiz_reset_rx_sync   ( gtwiz_reset_rx           ),
        .gtf_rxusrclk2_out     ( gtf_rxusrclk2_out        ),
        .gtf_ch_rxrawdata_in   ( gtf_ch_rxrawdata         ),
        .gtf_ch_rxrawdata_out  ( gtf_ch_rxrawdata_align   ),
        .gtf_ch_rxrawdata_samp ( gtf_ch_rxrawdata_samp    ),
        .sync_det              ( sync_det                 )
    ); 
*/

    bitslip_raw bitslip_raw (
        .clk                    ( gtf_rxusrclk2_out      ),
        .rstn                   ( ~gtwiz_reset_rx        ),
        .gtf_ch_rxrawdata       ( gtf_ch_rxrawdata[15:0] ),
        .gtf_ch_rxrawdata_samp  ( gtf_ch_rxrawdata_samp  ),
        .gtf_ch_rxrawdata_align ( gtf_ch_rxrawdata_align ),
        .bitslip_value          ( bitslip_value          ),
        .locked                 ( sync_det               ),
        .error                  ( sync_error             ),
        .en                     ( 1'b1                   )
    );
    assign sync_det_0 = sync_det;
    
    // Check for data sync...
    // If sync'd data stream is expected, then prbs_any_chk_error_int will be 0
    //wire [15:0] prbs_any_chk_error_int;
    //
    //gtfraw_vnc_frm_gen_prbs # ( .CHK_MODE(1) ) 
    //rx_raw_data_prbs (
    //    .RST      (gtwiz_reset_rx | sync_det),
    //    .CLK      (gtf_rxusrclk2_out),
    //    .DATA_IN  (gtf_ch_rxrawdata_align),
    //    .EN       (1'b1),
    //    .DATA_OUT (prbs_any_chk_error_int)
    //);
    
    // Will be asserted when expected data stream matches actual data stream...
    wire int_raw_locked = sync_det; // ~(|prbs_any_chk_error_int);

    reg  int_raw_locked_r;    
    always @(posedge freerun_clk)
    begin
      if (gtwiz_reset_all_in)
        int_raw_locked_r        <= 1'b0;
      else
        int_raw_locked_r        <= int_raw_locked;
    end
    
    // Assert link up status when valid, updates each clock cycle
    always @(posedge freerun_clk) begin
      if (gtwiz_reset_all_in)
        link_status_out <= 1'b0;
      else
        link_status_out <= int_raw_locked_r;
    end
    
    // If link up goes away, link down status is latched until reset by user logic
    always @(posedge freerun_clk) begin
      if (link_down_latched_reset_in)
        link_down_latched_out <= 1'b0;
      else if (!link_status_out)
        link_down_latched_out <= 1'b1;
    end
     
    assign link_maintained = ((~link_down_latched_out) && (link_status_out));

endmodule
`default_nettype wire

//`default_nettype none
//(* DowngradeIPIdentifiedWarnings="yes" *)
//module gtfwizard_0_prbs_any(RST, CLK, DATA_IN, EN, DATA_OUT);
//
//  //--------------------------------------------
//  // Configuration parameters
//  //--------------------------------------------
//   parameter CHK_MODE = 0;
//   parameter INV_PATTERN = 0;
//   parameter POLY_LENGHT = 31;
//   parameter POLY_TAP = 3;
//   parameter NBITS = 16;
//
//  //--------------------------------------------
//  // Input/Outputs
//  //--------------------------------------------
//
//   input  wire RST;
//   input  wire CLK;
//   input  wire [NBITS - 1:0] DATA_IN;
//   input  wire EN;
//   output reg  [NBITS - 1:0] DATA_OUT = {NBITS{1'b1}};
//
//  //--------------------------------------------
//  // Internal variables
//  //--------------------------------------------
//
//   wire [1:POLY_LENGHT] prbs[NBITS:0];
//   wire [NBITS - 1:0] data_in_i;
//   wire [NBITS - 1:0] prbs_xor_a;
//   wire [NBITS - 1:0] prbs_xor_b;
//   wire [NBITS:1] prbs_msb;
//   reg  [1:POLY_LENGHT]prbs_reg = {(POLY_LENGHT){1'b1}};
//
//  //--------------------------------------------
//  // Implementation
//  //--------------------------------------------
//
//   assign data_in_i = INV_PATTERN == 0 ? DATA_IN : ( ~DATA_IN);
//   assign prbs[0] = prbs_reg;
//
//   genvar I;
//   generate for (I=0; I<NBITS; I=I+1) begin : g1
//      assign prbs_xor_a[I] = prbs[I][POLY_TAP] ^ prbs[I][POLY_LENGHT];
//      assign prbs_xor_b[I] = prbs_xor_a[I] ^ data_in_i[I];
//      assign prbs_msb[I+1] = CHK_MODE == 0 ? prbs_xor_a[I]  :  data_in_i[I];
//      assign prbs[I+1] = {prbs_msb[I+1] , prbs[I][1:POLY_LENGHT-1]};
//   end
//   endgenerate
//
//   always @(posedge CLK) begin
//      if(RST == 1'b 1) begin
//         prbs_reg <= {POLY_LENGHT{1'b1}};
//         DATA_OUT <= {NBITS{1'b1}};
//      end
//      else if(EN == 1'b 1) begin
//         DATA_OUT <= prbs_xor_b;
//         prbs_reg <= prbs[NBITS];
//      end
//  end
//
//endmodule
//`default_nettype wire
