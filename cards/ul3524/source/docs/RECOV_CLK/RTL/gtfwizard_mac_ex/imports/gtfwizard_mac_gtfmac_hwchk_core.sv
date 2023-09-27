/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------


`timescale 1fs/1fs
`default_nettype none
module gtfwizard_mac_gtfmac_hwchk_core # (
    parameter   ONE_SECOND_COUNT   = 28'd200_000_000
)
(
	//Recov: System clock and manual reset for data collection fifos...
    input       wire            fifo_rst,
    input       wire            freerun_clk, 
    input       wire            ctl_hwchk_frm_gen_en_in , 
    input       wire            ctl_hwchk_mon_en_in     ,

    ////////////////////////////////////////////////////////////////
    // AXI-Lite Interface
    ////////////////////////////////////////////////////////////////

    input       wire            axi_aclk,
    input       wire            axi_aresetn,

    input       wire    [31:0]  hwchk_axil_araddr,
    input       wire            hwchk_axil_arvalid,
    output      wire            hwchk_axil_arready,
    output      wire    [31:0]  hwchk_axil_rdata,
    output      wire    [1:0]   hwchk_axil_rresp,
    output      wire            hwchk_axil_rvalid,
    input       wire            hwchk_axil_rready,
    input       wire    [31:0]  hwchk_axil_awaddr,
    input       wire            hwchk_axil_awvalid,
    output      wire            hwchk_axil_awready,
    input       wire    [31:0]  hwchk_axil_wdata,
    input       wire            hwchk_axil_wvalid,
    output      wire            hwchk_axil_wready,
    output      wire            hwchk_axil_bvalid,
    output      wire    [1:0]   hwchk_axil_bresp,
    input       wire            hwchk_axil_bready,



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

    input       wire            tx_clk,
    input       wire            tx_rst,

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

    input       wire            rx_axis_tvalid,
    input       wire [63:0]     rx_axis_tdata,
    input       wire [7:0]      rx_axis_tlast,
    input       wire [7:0]      rx_axis_tpre,
    input       wire            rx_axis_terr,
    input       wire [4:0]      rx_axis_tterm,
    input       wire [1:0]      rx_axis_tsof,

    input       wire            rx_ptp_sop,
    input       wire            rx_ptp_sop_pos,
    input       wire            rx_gb_seq_start,

    ////////////////////////////////////////////////////////////////
    // Control and Status
    ////////////////////////////////////////////////////////////////
    output      wire            ctl_gb_seq_sync         ,
    output      wire            ctl_disable_bitslip     ,
    output      wire            ctl_correct_bitslip     ,
    input       wire  [6:0]     stat_bitslip_cnt        ,
    input       wire  [6:0]     stat_bitslip_issued     ,
    input       wire            stat_excessive_bitslip  ,
    input       wire            stat_bitslip_locked     ,
    input       wire            stat_bitslip_busy       ,
    input       wire            stat_bitslip_done       ,

    // Debug resets
    output      logic           hwchk_gtf_ch_gttxreset,
    output      logic           hwchk_gtf_ch_txpmareset,
    output      logic           hwchk_gtf_ch_txpcsreset,
    output      logic           hwchk_gtf_ch_gtrxreset,
    output      logic           hwchk_gtf_ch_rxpmareset,
    output      logic           hwchk_gtf_ch_rxdfelpmreset,
    output      logic           hwchk_gtf_ch_eyescanreset,
    output      logic           hwchk_gtf_ch_rxpcsreset,
    output      logic           hwchk_gtf_cm_qpll0reset,

    output      logic           hwchk_gtf_ch_txuserrdy,
    output      logic           hwchk_gtf_ch_rxuserrdy,

    output      logic           gtwiz_reset_tx_pll_and_datapath_in,
    output      logic           gtwiz_reset_tx_datapath_in,
    output      logic           gtwiz_reset_rx_pll_and_datapath_in,
    output      logic           gtwiz_reset_rx_datapath_in,
    
    input       wire            block_lock, 

    output      wire            hwchk_rx_custom_preamble_en                  

);

    localparam  TIMER_WIDTH = 16;

    logic                       lm_go;
    logic                       lm_full;
    logic   [9:0]               lm_datav;
    logic                       lm_pop;
    logic                       lm_clear;
    logic   [TIMER_WIDTH-1:0]   lm_tx_time;
    logic   [TIMER_WIDTH-1:0]   lm_rx_time;
    logic                       lm_time_rdy;

    logic           tx_sop;

    wire            ctl_hwchk_frm_gen_en;
    wire            ctl_hwchk_frm_gen_mode;
    wire    [13:0]  ctl_hwchk_max_len;
    wire    [13:0]  ctl_hwchk_min_len;

    wire            ctl_tx_custom_preamble_en;
    wire    [63:0]  ctl_hwchk_tx_custom_preamble;
    wire            ctl_tx_variable_ipg;

    wire            ctl_tx_fcs_ins_enable;
    wire            ctl_tx_data_rate;

    wire            ctl_hwchk_tx_inj_err;
    wire            ack_hwchk_tx_inj_err;
    
    wire            ctl_hwchk_tx_inj_poison; 
    wire            ack_hwchk_tx_inj_poison;

    wire            ctl_hwchk_tx_inj_pause;
    wire    [47:0]  ctl_hwchk_tx_inj_pause_sa;
    wire    [47:0]  ctl_hwchk_tx_inj_pause_da;
    wire    [15:0]  ctl_hwchk_tx_inj_pause_ethtype;
    wire    [15:0]  ctl_hwchk_tx_inj_pause_opcode;
    wire    [15:0]  ctl_hwchk_tx_inj_pause_timer_ce;
    wire    [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc0;
    wire    [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc1;
    wire    [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc2;
    wire    [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc3;
    wire    [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc4;
    wire    [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc5;
    wire    [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc6;
    wire    [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc7;
    wire            ack_hwchk_tx_inj_pause;

    wire            ctl_hwchk_mon_en;
    wire            ctl_rx_data_rate;
    wire            ctl_rx_packet_framing_enable;
    wire            ctl_rx_custom_preamble_en;
    wire    [63:0]  ctl_hwchk_rx_custom_preamble;
    wire    [31:0]  ctl_num_frames;

    wire            stat_tick;





    wire            ack_frm_gen_done;
    wire            ctl_tx_start_framing_enable;
    wire            ctl_hwchk_tx_start_lat_run;
    wire            ack_hwchk_tx_start_lat_run;
    wire            tx_start_measured_run;
    wire            rx_start_measured_run;

    assign hwchk_rx_custom_preamble_en = ctl_rx_custom_preamble_en;
    
    //
    //Recov: Data integrity checking and ILA
    //

    // Mon signal for debug
    wire            fcs_crc_bad           ;
    
    // Signals from pif....
    wire            fifo_rst_status       ;
    wire            rx_packet_count_rst   ;
    wire            rx_packet_count_rst_sync;
    wire  [31:0]    rx_packet_count       ;

    // Signals to pif....
    wire [31:0]     fifo_rx_wr_count      ;
    wire            fifo_rx_err_overflow  ;
    wire            fifo_rx_err_underflow ;
    wire [31:0]     fifo_tx_wr_count      ;
    wire            fifo_tx_err_overflow  ;
    wire            fifo_tx_err_underflow ;
    wire            fifo_rd_fcs_error_pif ;
    wire [31:0]     fifo_rd_err_count     ;

    // Sync 
    gtfmac_hwchk_syncer_pulse i_rx_packet_count_rst_sync (
       .clkin        (axi_aclk),
       .clkin_reset  (1'b1),
       .clkout       (mon_clk),
       .clkout_reset (1'b1),
       .pulsein      (rx_packet_count_rst),
       .pulseout     (rx_packet_count_rst_sync)
    );


    ila_mac_fifo_top ila_mac_fifo_top (
        // Resetf from User PIF
        .axi_aclk                 ( axi_aclk                  ),
        .fifo_rst                 ( fifo_rst                  ),
        .fifo_rst_status          ( fifo_rst_status           ),
    
        // Status signals to User PIF
        .fifo_rd_fcs_error_pif    ( fifo_rd_fcs_error_pif     ),
        .fifo_rd_err_count        ( fifo_rd_err_count         ),
        
        .fifo_rx_err_overflow     ( fifo_rx_err_overflow      ),
        .fifo_rx_err_underflow    ( fifo_rx_err_underflow     ),
        .fifo_rx_wr_count         ( fifo_rx_wr_count          ),
    
        .fifo_tx_err_overflow     ( fifo_tx_err_overflow      ),
        .fifo_tx_err_underflow    ( fifo_tx_err_underflow     ),
        .fifo_tx_wr_count         ( fifo_tx_wr_count          ),
    
        // TX AXIS Signals to GTF.... 
        .tx_clk                   ( tx_clk                    ),
        .tx_rst                   ( tx_rst                    ),
    
        .tx_axis_tready           ( tx_axis_tready            ),
        .tx_axis_tvalid           ( tx_axis_tvalid            ),
        .tx_axis_tdata            ( tx_axis_tdata             ),
        .tx_axis_tlast            ( tx_axis_tlast             ),
        .tx_axis_tsof             ( tx_axis_tsof              ),
        .tx_axis_tcan_start       ( tx_axis_tcan_start        ),
    
        // RX AXIS Signals from GTF.... 
        .rx_clk                   ( rx_clk                    ),
        .rx_rst                   ( rx_rst                    ),
    
        .rx_axis_tvalid           ( rx_axis_tvalid            ),
        .rx_axis_tdata            ( rx_axis_tdata             ),
        .rx_axis_tlast            ( rx_axis_tlast             ),
        .rx_axis_tsof             ( rx_axis_tsof              ),
    
        // ILA and FIFO read clock 
        .fifo_rd_fifo_clk         ( gen_clk                   ),
        
        // CRC Status
        .mon_clk                  ( mon_clk                   ),
        .fcs_crc_bad              ( fcs_crc_bad               )
    );    
    
    // -------------------------------------------------------------------------
    
    //"gtfmac_hwchk_tx_gen" outputs test data to GTF and can be configured to enable/disable 
    // various configurations of test data through the s/w control (ctl) register interface 
    // hosted by module "gtfmac_hwchk_hwchk_pif". This test data ultimately gets driven by GTF's TX

    gtfmac_hwchk_tx_gen  i_tx_gen    (
        .axi_aclk                           (axi_aclk),
        .axi_aresetn                        (axi_aresetn),

        .gen_clk                            (gen_clk),                          // input       wire
        .gen_rst                            (gen_rst),                          // input       wire

        .ctl_hwchk_frm_gen_en                 (ctl_hwchk_frm_gen_en),               // input       wire
        .ctl_hwchk_frm_gen_mode               (ctl_hwchk_frm_gen_mode),             // input       wire
        .ctl_hwchk_max_len                    (ctl_hwchk_max_len),                  // input       wire    [13:0]
        .ctl_hwchk_min_len                    (ctl_hwchk_min_len),                  // input       wire    [13:0]
        .ctl_num_frames                     (ctl_num_frames),                   // input       wire    [31:0]
        .ack_frm_gen_done                   (ack_frm_gen_done),                 // output      wire

        .ctl_tx_start_framing_enable        (ctl_tx_start_framing_enable),      // input       wire
        .ctl_tx_custom_preamble_en          (ctl_tx_custom_preamble_en),        // input       wire
        .ctl_hwchk_tx_custom_preamble         (ctl_hwchk_tx_custom_preamble),       // input       wire    [63:0]
        .ctl_tx_variable_ipg                (ctl_tx_variable_ipg),              // input       wire

        .ctl_tx_fcs_ins_enable              (ctl_tx_fcs_ins_enable),            // input       wire
        .ctl_tx_data_rate                   (ctl_tx_data_rate),

        .ctl_hwchk_tx_inj_err                 (ctl_hwchk_tx_inj_err),               // input       wire
        .ack_hwchk_tx_inj_err                 (ack_hwchk_tx_inj_err),               // output      reg
        
        .ctl_hwchk_tx_inj_poison              (ctl_hwchk_tx_inj_poison),            // input       wire 
        .ack_hwchk_tx_inj_poison              (ack_hwchk_tx_inj_poison),            // output      reg

        .ctl_hwchk_tx_start_lat_run           (ctl_hwchk_tx_start_lat_run),         // input
        .ack_hwchk_tx_start_lat_run           (ack_hwchk_tx_start_lat_run),         // output

        .ctl_hwchk_tx_inj_pause               (ctl_hwchk_tx_inj_pause),             // input       wire
        .ctl_hwchk_tx_inj_pause_sa            (ctl_hwchk_tx_inj_pause_sa),          // input       wire    [47:0]
        .ctl_hwchk_tx_inj_pause_da            (ctl_hwchk_tx_inj_pause_da),          // input       wire    [47:0]
        .ctl_hwchk_tx_inj_pause_ethtype       (ctl_hwchk_tx_inj_pause_ethtype),     // input       wire    [15:0]
        .ctl_hwchk_tx_inj_pause_opcode        (ctl_hwchk_tx_inj_pause_opcode),      // input       wire    [15:0]
        .ctl_hwchk_tx_inj_pause_timer_ce      (ctl_hwchk_tx_inj_pause_timer_ce),    // input       wire    [15:0]
        .ctl_hwchk_tx_inj_pause_timer_pfc0    (ctl_hwchk_tx_inj_pause_timer_pfc0),  // input       wire    [15:0]
        .ctl_hwchk_tx_inj_pause_timer_pfc1    (ctl_hwchk_tx_inj_pause_timer_pfc1),  // input       wire    [15:0]
        .ctl_hwchk_tx_inj_pause_timer_pfc2    (ctl_hwchk_tx_inj_pause_timer_pfc2),  // input       wire    [15:0]
        .ctl_hwchk_tx_inj_pause_timer_pfc3    (ctl_hwchk_tx_inj_pause_timer_pfc3),  // input       wire    [15:0]
        .ctl_hwchk_tx_inj_pause_timer_pfc4    (ctl_hwchk_tx_inj_pause_timer_pfc4),  // input       wire    [15:0]
        .ctl_hwchk_tx_inj_pause_timer_pfc5    (ctl_hwchk_tx_inj_pause_timer_pfc5),  // input       wire    [15:0]
        .ctl_hwchk_tx_inj_pause_timer_pfc6    (ctl_hwchk_tx_inj_pause_timer_pfc6),  // input       wire    [15:0]
        .ctl_hwchk_tx_inj_pause_timer_pfc7    (ctl_hwchk_tx_inj_pause_timer_pfc7),  // input       wire    [15:0]
        .ack_hwchk_tx_inj_pause               (ack_hwchk_tx_inj_pause),             // output      wire

        .tx_clk                             (tx_clk),                           // input       wire
        .tx_rst                             (tx_rst),                           // input       wire

        .tx_axis_tready                     (tx_axis_tready),                   // input       wire
        .tx_axis_tvalid                     (tx_axis_tvalid),                   // output      wire
        .tx_sop                             (tx_sop),
        .tx_axis_tdata                      (tx_axis_tdata),                    // output      wire [63:0]
        .tx_axis_tlast                      (tx_axis_tlast),                    // output      wire [7:0]
        .tx_axis_tpre                       (tx_axis_tpre),                     // output      wire [7:0]
        .tx_axis_terr                       (tx_axis_terr),                     // output      wire
        .tx_axis_tterm                      (tx_axis_tterm),                    // output      wire [4:0]
        .tx_axis_tsof                       (tx_axis_tsof),                     // output      wire [1:0]
        .tx_axis_tpoison                    (tx_axis_tpoison),                  // output      wire
        .tx_axis_tcan_start                 (tx_axis_tcan_start),               // input       wire
        .tx_start_measured_run              (tx_start_measured_run),            // output      wire

        .tx_ptp_sop                         (tx_ptp_sop),                       // input       wire
        .tx_ptp_sop_pos                     (tx_ptp_sop_pos),                   // input       wire
        .tx_gb_seq_start                    (tx_gb_seq_start),                  // input       wire

        .tx_unfout                          (tx_unfout),                        // input       wire

        .stat_clk                           (axi_aclk),                         // input       wire
        .stat_rst                           (~axi_aresetn),                     // input       wire

        .stat_tick                          (stat_tick)                        // input       wire


    );


    //"gtfmac_hwchk_rx_mon" receives test data from GTF's RX and can be configured to enable/disable 
    // various configurations of test data through the s/w control (ctl) register interface 
    // hosted by module "gtfmac_hwchk_hwchk_pif". 
    
    // To complete the data loop for internal debug (hwchk),
    // TX GEN generates the test data which is driven by GTF's TX, GTF's TX is looped-back to GTF's RX, 
    // and GTF's RX is connected to RX MON to monitor the received data.

    gtfmac_hwchk_rx_mon i_rx_mon (
		//Recov: Receive packet counter for user status
        .rx_packet_count_rst                (rx_packet_count_rst_sync),             // input       wire 
        .rx_packet_count                    (rx_packet_count),                      // output      reg [31:0]

        .fcs_crc_bad                        ( fcs_crc_bad ),                        // output      wire

        .mon_clk                            (mon_clk),                              // input       wire
        .mon_rst                            (mon_rst),                              // input       wire

        .ctl_hwchk_mon_en                     (ctl_hwchk_mon_en),                       // input       wire
        .ctl_rx_data_rate                   (ctl_rx_data_rate),                     // input       wire
        .ctl_rx_packet_framing_enable       (ctl_rx_packet_framing_enable),         // input       wire
        .ctl_rx_custom_preamble_en          (ctl_rx_custom_preamble_en),            // input       wire
        .ctl_hwchk_rx_custom_preamble         (ctl_hwchk_rx_custom_preamble),           // input       wire    [63:0]
        .ctl_hwchk_max_len                    (ctl_hwchk_max_len),                      // input       wire    [13:0]
        .ctl_hwchk_min_len                    (ctl_hwchk_min_len),                      // input       wire    [13:0]

        .rx_clk                             (rx_clk),                               // input       wire
        .rx_rst                             (rx_rst),                               // input       wire

        .rx_axis_tvalid                     (rx_axis_tvalid),                       // input       wire
        .rx_axis_tdata                      (rx_axis_tdata),                        // input       wire [63:0]
        .rx_axis_tlast                      (rx_axis_tlast),                        // input       wire [7:0]
        .rx_axis_tpre                       (rx_axis_tpre),                         // input       wire [7:0]
        .rx_axis_terr                       (rx_axis_terr),                         // input       wire
        .rx_axis_tterm                      (rx_axis_tterm),                        // input       wire [4:0]
        .rx_axis_tsof                       (rx_axis_tsof),                         // input       wire [1:0]
        .rx_start_measured_run              (rx_start_measured_run),                // output      wire

        .stat_clk                           (axi_aclk),                             // input       wire
        .stat_rst                           (~axi_aresetn),                         // input       wire

        .stat_tick                          (stat_tick)                             // input       wire


    );


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

    gtfmac_hwchk_syncer_level i_sync_gtfmac_rx_rst (

      .clk        (axi_aclk),
      .reset      (axi_aresetn),

      .datain     (rx_rst),
      .dataout    (stat_gtf_rx_rst_sync)

    );

    gtfmac_hwchk_syncer_level i_sync_gtfmac_tx_rst (

      .clk        (axi_aclk),
      .reset      (axi_aresetn),

      .datain     (tx_rst),
      .dataout    (stat_gtf_tx_rst_sync)

    );

    gtfmac_hwchk_syncer_level i_sync_gtfmac_block_lock (

      .clk        (axi_aclk),
      .reset      (axi_aresetn),

      .datain     (block_lock),
      .dataout    (stat_gtf_block_lock_sync)

    );
    
    assign stat_gtf_rx_internal_local_fault_sync = 1'b0;
    assign stat_gtf_rx_local_fault_sync = 1'b0;
    assign stat_gtf_rx_received_local_fault_sync = 1'b0;
    assign stat_gtf_rx_remote_fault_sync = 1'b0;
    assign tx_clk_cps    = 32'd0   ;
    assign rx_clk_cps    = 32'd0   ;
    assign axi_aclk_cps  = 32'd0   ;
    assign gen_clk_cps   = 32'd0   ;
    assign mon_clk_cps   = 32'd0   ;
    assign lat_clk_cps   = 32'd0   ;


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


    //"gtfmac_hwchk_hwchk_pif" hosts the s/w programmable control (ctl) registers
    //which control the various configurations needed by TX GEN and RX MON

    gtfmac_hwchk_hwchk_pif i_hwchk_pif (
		//Recov: Receive packet counter and data integrity status...
        .rx_packet_count_rst                ( rx_packet_count_rst     ),
        .rx_packet_count                    ( rx_packet_count         ),
        .fifo_tx_fcs_error                  ( fifo_rd_fcs_error_pif   ),
        .ctl_hwchk_frm_gen_en_in            ( ctl_hwchk_frm_gen_en_in ),
        .ctl_hwchk_mon_en_in                ( ctl_hwchk_mon_en_in     ),
                                                        
        .fifo_rst_status                    ( fifo_rst_status         ),
        .fifo_rd_err_count                  ( fifo_rd_err_count       ),
        .fifo_rx_wr_count                   ( fifo_rx_wr_count        ),
        .fifo_rx_err_overflow               ( fifo_rx_err_overflow    ),
        .fifo_rx_err_underflow              ( fifo_rx_err_underflow   ),
        .fifo_tx_wr_count                   ( fifo_tx_wr_count        ),
        .fifo_tx_err_overflow               ( fifo_tx_err_overflow    ),
        .fifo_tx_err_underflow              ( fifo_tx_err_underflow   ),

        .axi_aclk                           (axi_aclk),                 // input
        .axi_aresetn                        (axi_aresetn),              // input

        .axil_araddr                        (hwchk_axil_araddr),          // input   wire    [31:0]
        .axil_arvalid                       (hwchk_axil_arvalid),         // input   wire
        .axil_arready                       (hwchk_axil_arready),         // output  reg

        .axil_rdata                         (hwchk_axil_rdata),           // output  reg     [31:0]
        .axil_rresp                         (hwchk_axil_rresp),           // output  wire    [1:0]
        .axil_rvalid                        (hwchk_axil_rvalid),          // output  reg
        .axil_rready                        (hwchk_axil_rready),          // input

        .axil_awaddr                        (hwchk_axil_awaddr),          // input   wire    [31:0]
        .axil_awvalid                       (hwchk_axil_awvalid),         // input   wire
        .axil_awready                       (hwchk_axil_awready),         // output  reg

        .axil_wdata                         (hwchk_axil_wdata),           // input   wire    [31:0]
        .axil_wvalid                        (hwchk_axil_wvalid),          // input   wire
        .axil_wready                        (hwchk_axil_wready),          // output  reg

        .axil_bvalid                        (hwchk_axil_bvalid),          // output  reg
        .axil_bresp                         (hwchk_axil_bresp),           // output  wire    [1:0]
        .axil_bready                        (hwchk_axil_bready),          // input

        .tx_clk_cps                         (tx_clk_cps),
        .rx_clk_cps                         (rx_clk_cps),
        .axi_aclk_cps                       (axi_aclk_cps),
        .gen_clk_cps                        (gen_clk_cps),
        .mon_clk_cps                        (mon_clk_cps),
        .lat_clk_cps                        (lat_clk_cps),

        // Debug resets
        .hwchk_gtf_ch_gttxreset               (hwchk_gtf_ch_gttxreset),
        .hwchk_gtf_ch_txpmareset              (hwchk_gtf_ch_txpmareset),
        .hwchk_gtf_ch_txpcsreset              (hwchk_gtf_ch_txpcsreset),
        .hwchk_gtf_ch_gtrxreset               (hwchk_gtf_ch_gtrxreset),
        .hwchk_gtf_ch_rxpmareset              (hwchk_gtf_ch_rxpmareset),
        .hwchk_gtf_ch_rxdfelpmreset           (hwchk_gtf_ch_rxdfelpmreset),
        .hwchk_gtf_ch_eyescanreset            (hwchk_gtf_ch_eyescanreset),
        .hwchk_gtf_ch_rxpcsreset              (hwchk_gtf_ch_rxpcsreset),
        .hwchk_gtf_cm_qpll0reset              (hwchk_gtf_cm_qpll0reset),

        .hwchk_gtf_ch_txuserrdy               (hwchk_gtf_ch_txuserrdy),
        .hwchk_gtf_ch_rxuserrdy               (hwchk_gtf_ch_rxuserrdy),

        .gtwiz_reset_tx_pll_and_datapath_in (gtwiz_reset_tx_pll_and_datapath_in),
        .gtwiz_reset_tx_datapath_in         (gtwiz_reset_tx_datapath_in),
        .gtwiz_reset_rx_pll_and_datapath_in (gtwiz_reset_rx_pll_and_datapath_in),
        .gtwiz_reset_rx_datapath_in         (gtwiz_reset_rx_datapath_in),
        
        // GTFMAC Status
        .stat_gtf_rx_rst                    (stat_gtf_rx_rst_sync),
        .stat_gtf_tx_rst                    (stat_gtf_tx_rst_sync),
        .stat_gtf_block_lock                (stat_gtf_block_lock_sync),

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
        .ctl_hwchk_frm_gen_en                 (ctl_hwchk_frm_gen_en),                   // output      logic
        .ctl_hwchk_frm_gen_mode               (ctl_hwchk_frm_gen_mode),                 // output      logic
        .ctl_hwchk_max_len                    (ctl_hwchk_max_len),                      // output      logic   [13:0]
        .ctl_hwchk_min_len                    (ctl_hwchk_min_len),                      // output      logic   [13:0]
        .ctl_num_frames                     (ctl_num_frames),                       // output      wire    [31:0]
        .ack_frm_gen_done                   (ack_frm_gen_done),                     // input       wire

        .ctl_tx_start_framing_enable        (ctl_tx_start_framing_enable),          // output      logic
        .ctl_tx_custom_preamble_en          (ctl_tx_custom_preamble_en),            // output      logic
        .ctl_hwchk_tx_custom_preamble         (ctl_hwchk_tx_custom_preamble),           // output      logic   [63:0]
        .ctl_tx_variable_ipg                (ctl_tx_variable_ipg),                  // output      logic

        .ctl_tx_fcs_ins_enable              (ctl_tx_fcs_ins_enable),                // output      logic
        .ctl_tx_data_rate                   (ctl_tx_data_rate),                     // output      logic

        .ctl_hwchk_tx_inj_err                 (ctl_hwchk_tx_inj_err),                   // output      logic
        .ack_hwchk_tx_inj_err                 (ack_hwchk_tx_inj_err),                   // input       wire
        
        .ctl_hwchk_tx_inj_poison              (ctl_hwchk_tx_inj_poison),                // output      logic 
        .ack_hwchk_tx_inj_poison              (ack_hwchk_tx_inj_poison),                // input       wire

        .ctl_hwchk_tx_start_lat_run           (ctl_hwchk_tx_start_lat_run),             // output
        .ack_hwchk_tx_start_lat_run           (ack_hwchk_tx_start_lat_run),             // input

        .ctl_hwchk_tx_inj_pause               (ctl_hwchk_tx_inj_pause),                 // output      logic
        .ctl_hwchk_tx_inj_pause_sa            (ctl_hwchk_tx_inj_pause_sa),              // output      logic   [47:0]
        .ctl_hwchk_tx_inj_pause_da            (ctl_hwchk_tx_inj_pause_da),              // output      logic   [47:0]
        .ctl_hwchk_tx_inj_pause_ethtype       (ctl_hwchk_tx_inj_pause_ethtype),         // output      logic   [15:0]
        .ctl_hwchk_tx_inj_pause_opcode        (ctl_hwchk_tx_inj_pause_opcode),          // output      logic   [15:0]
        .ctl_hwchk_tx_inj_pause_timer_ce      (ctl_hwchk_tx_inj_pause_timer_ce),        // output      logic   [15:0]
        .ctl_hwchk_tx_inj_pause_timer_pfc0    (ctl_hwchk_tx_inj_pause_timer_pfc0),      // output      logic   [15:0]
        .ctl_hwchk_tx_inj_pause_timer_pfc1    (ctl_hwchk_tx_inj_pause_timer_pfc1),      // output      logic   [15:0]
        .ctl_hwchk_tx_inj_pause_timer_pfc2    (ctl_hwchk_tx_inj_pause_timer_pfc2),      // output      logic   [15:0]
        .ctl_hwchk_tx_inj_pause_timer_pfc3    (ctl_hwchk_tx_inj_pause_timer_pfc3),      // output      logic   [15:0]
        .ctl_hwchk_tx_inj_pause_timer_pfc4    (ctl_hwchk_tx_inj_pause_timer_pfc4),      // output      logic   [15:0]
        .ctl_hwchk_tx_inj_pause_timer_pfc5    (ctl_hwchk_tx_inj_pause_timer_pfc5),      // output      logic   [15:0]
        .ctl_hwchk_tx_inj_pause_timer_pfc6    (ctl_hwchk_tx_inj_pause_timer_pfc6),      // output      logic   [15:0]
        .ctl_hwchk_tx_inj_pause_timer_pfc7    (ctl_hwchk_tx_inj_pause_timer_pfc7),      // output      logic   [15:0]
        .ack_hwchk_tx_inj_pause               (ack_hwchk_tx_inj_pause),                 // input       logic

        // Monitor
        .ctl_hwchk_mon_en                     (ctl_hwchk_mon_en),                       // output      logic
        .ctl_rx_data_rate                   (ctl_rx_data_rate),                     // output      logic
        .ctl_rx_packet_framing_enable       (ctl_rx_packet_framing_enable),         // output      logic
        .ctl_rx_custom_preamble_en          (ctl_rx_custom_preamble_en),            // output      logic
        .ctl_hwchk_rx_custom_preamble         (ctl_hwchk_rx_custom_preamble)            // output      logic   [63:0]


    );

endmodule
`default_nettype wire


`default_nettype none
module gtfmac_hwchk_tx_gen (
    input       wire            axi_aclk,
    input       wire            axi_aresetn,

    input       wire            gen_clk,
    input       wire            gen_rst,

    input       wire            ctl_hwchk_frm_gen_en,
    input       wire            ctl_hwchk_frm_gen_mode,
    input       wire    [13:0]  ctl_hwchk_max_len,
    input       wire    [13:0]  ctl_hwchk_min_len,
    input       wire    [31:0]  ctl_num_frames,
    output      wire            ack_frm_gen_done,

    input       wire            ctl_tx_custom_preamble_en,
    input       wire    [63:0]  ctl_hwchk_tx_custom_preamble,
    input       wire            ctl_tx_start_framing_enable,
    input       wire            ctl_tx_variable_ipg,

    input       wire            ctl_tx_fcs_ins_enable,
    input       wire            ctl_tx_data_rate,

    input       wire            ctl_hwchk_tx_inj_err,
    output      wire            ack_hwchk_tx_inj_err,
    
    input       wire            ctl_hwchk_tx_inj_poison, 
    output      wire            ack_hwchk_tx_inj_poison,

    input       wire            ctl_hwchk_tx_start_lat_run,
    output      wire            ack_hwchk_tx_start_lat_run,

    input       wire            ctl_hwchk_tx_inj_pause,
    input       wire    [47:0]  ctl_hwchk_tx_inj_pause_sa,
    input       wire    [47:0]  ctl_hwchk_tx_inj_pause_da,
    input       wire    [15:0]  ctl_hwchk_tx_inj_pause_ethtype,
    input       wire    [15:0]  ctl_hwchk_tx_inj_pause_opcode,
    input       wire    [15:0]  ctl_hwchk_tx_inj_pause_timer_ce,
    input       wire    [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc0,
    input       wire    [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc1,
    input       wire    [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc2,
    input       wire    [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc3,
    input       wire    [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc4,
    input       wire    [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc5,
    input       wire    [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc6,
    input       wire    [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc7,
    output      wire            ack_hwchk_tx_inj_pause,

    input       wire            tx_clk,
    input       wire            tx_rst,

    input       wire            tx_axis_tready,
    output      wire            tx_axis_tvalid,
    output      wire            tx_sop,
    output      wire [63:0]     tx_axis_tdata,
    output      wire [7:0]      tx_axis_tlast,
    output      wire [7:0]      tx_axis_tpre,
    output      wire            tx_axis_terr,
    output      wire [4:0]      tx_axis_tterm,
    output      wire [1:0]      tx_axis_tsof,
    output      wire            tx_axis_tpoison,
    input       wire            tx_axis_tcan_start,
    output      wire            tx_start_measured_run,

    input       wire            tx_ptp_sop,
    input       wire            tx_ptp_sop_pos,
    input       wire            tx_gb_seq_start,

    input       wire            tx_unfout,

    input       wire            stat_clk,
    input       wire            stat_rst,
    input       wire            stat_tick


);


    wire    [63:0]      prbs_data;

    wire                bp;

    wire                frm_gen_ena;
    wire                frm_gen_pre;
    wire                frm_gen_sop;
    wire                frm_gen_eop;
    wire    [2:0]       frm_gen_mty;
    wire    [7:0]       frm_gen_last;
    wire    [63:0]      frm_gen_data;
    wire                frm_gen_err;
    wire                frm_gen_poison;

    wire                frm_gen_bad_fcs;
    wire                frm_gen_vlan;
    wire                frm_gen_broadcast;
    wire                frm_gen_multicast;
    wire                frm_gen_unicast;

    wire                fcs_ena;
    wire                fcs_pre;
    wire                fcs_sop;
    wire                fcs_eop;
    wire    [2:0]       fcs_mty;
    wire    [63:0]      fcs_data;
    wire                fcs_err;
    wire                fcs_poison;

    wire                tx_credit;

    wire                buf_ena;
    wire                buf_pre;
    wire                buf_sop;
    wire    [63:0]      buf_data;
    wire    [7:0]       buf_last;
    wire                buf_err;
    wire                buf_poison;

    wire                tx_buffer_overflow;
    wire                frm_gen_done;


    gtfmac_hwchk_prbs_gen_64 i_prbs_gen_64 (

        .clk        (gen_clk),
        .rst        (gen_rst),

        .en         (1'b1),
        .prbs_out   (prbs_data)

    );

    wire    ctl_tx_inj_err_sync;
    wire    ctl_tx_inj_poison_sync;
    wire    ack_tx_inj_pause;
    wire    frm_gen_en;
    wire    ctl_hwchk_tx_start_lat_run_sync;
    wire    ack_tx_start_lat_run;
    wire    ctl_hwchk_tx_inj_err_sync;
    wire    ctl_hwchk_tx_inj_poison_sync;

    gtfmac_hwchk_syncer_level i_sync_ctl_tx_inj_err (

      .reset      (~gen_rst),
      .clk        (gen_clk),

      .datain     (ctl_hwchk_tx_inj_err),
      .dataout    (ctl_hwchk_tx_inj_err_sync)

    );
    
    gtfmac_hwchk_syncer_level i_sync_ctl_tx_inj_poison (

      .reset      (~gen_rst),
      .clk        (gen_clk),

      .datain     (ctl_hwchk_tx_inj_poison),
      .dataout    (ctl_hwchk_tx_inj_poison_sync)

    );

    gtfmac_hwchk_syncer_level i_sync_ctl_frm_gen_en (

      .reset      (~gen_rst),
      .clk        (gen_clk),

      .datain     (ctl_hwchk_frm_gen_en),
      .dataout    (frm_gen_en)

    );

    gtfmac_hwchk_syncer_pulse i_ack_ctl_frm_gen_done (
       .clkin        (gen_clk),
       .clkin_reset  (~gen_rst),
       .clkout       (axi_aclk),
       .clkout_reset (axi_aresetn),

       .pulsein      (frm_gen_done),
       .pulseout     (ack_frm_gen_done)
    );

    gtfmac_hwchk_syncer_pulse i_ack_hwchk_tx_inj_err (
       .clkin        (gen_clk),
       .clkin_reset  (~gen_rst),
       .clkout       (axi_aclk),
       .clkout_reset (axi_aresetn),

       .pulsein      (frm_gen_err),
       .pulseout     (ack_hwchk_tx_inj_err)
    );
    
    gtfmac_hwchk_syncer_pulse i_ack_hwchk_tx_inj_poison (
       .clkin        (gen_clk),
       .clkin_reset  (~gen_rst),
       .clkout       (axi_aclk),
       .clkout_reset (axi_aresetn),

       .pulsein      (frm_gen_poison),
       .pulseout     (ack_hwchk_tx_inj_poison) 
    );

    gtfmac_hwchk_syncer_pulse i_ack_hwchk_tx_inj_pause (
       .clkin        (gen_clk),
       .clkin_reset  (~gen_rst),
       .clkout       (axi_aclk),
       .clkout_reset (axi_aresetn),

       .pulsein      (ack_tx_inj_pause),
       .pulseout     (ack_hwchk_tx_inj_pause)
    );

    gtfmac_hwchk_syncer_level i_sync_ctl_hwchk_tx_start_lat_run (

      .reset      (~gen_rst),
      .clk        (gen_clk),

      .datain     (ctl_hwchk_tx_start_lat_run),
      .dataout    (ctl_hwchk_tx_start_lat_run_sync)

    );

    gtfmac_hwchk_syncer_pulse i_ack_hwchk_tx_start_lat_run (
       .clkin        (gen_clk),
       .clkin_reset  (~gen_rst),
       .clkout       (axi_aclk),
       .clkout_reset (axi_aresetn),

       .pulsein      (ack_tx_start_lat_run),
       .pulseout     (ack_hwchk_tx_start_lat_run)
    );

	//Recov: Need to adjust a couple words before checksum...
    gtfmac_hwchk_tx_frm_gen i_tx_frm_gen  (

        .clk                            (gen_clk),
        .rst                            (gen_rst),
        .bp                             (bp),

        .ctl_frm_gen_en                 (frm_gen_en),
        .ctl_frm_gen_mode               (ctl_hwchk_frm_gen_mode),
        .ctl_max_len                    (ctl_hwchk_max_len),
        .ctl_min_len                    (ctl_hwchk_min_len),
        .ctl_num_frames                 (ctl_num_frames),
        .frm_gen_done                   (frm_gen_done),

        .ctl_tx_start_framing_enable    (ctl_tx_start_framing_enable),
        .ctl_tx_custom_preamble_en      (ctl_tx_custom_preamble_en),
        .ctl_tx_custom_preamble         (ctl_hwchk_tx_custom_preamble),
        .ctl_tx_fcs_ins_enable          (ctl_tx_fcs_ins_enable),

        .ctl_tx_inj_err                 (ctl_hwchk_tx_inj_err_sync),
        
        .ctl_tx_inj_poison              (ctl_hwchk_tx_inj_poison_sync),

        .ctl_tx_start_lat_run           (ctl_hwchk_tx_start_lat_run_sync),
        .ack_tx_start_lat_run           (ack_tx_start_lat_run),

        .ctl_tx_inj_pause               (ctl_hwchk_tx_inj_pause),
        .ctl_tx_inj_pause_sa            (ctl_hwchk_tx_inj_pause_sa),
        .ctl_tx_inj_pause_da            (ctl_hwchk_tx_inj_pause_da),
        .ctl_tx_inj_pause_ethtype       (ctl_hwchk_tx_inj_pause_ethtype),
        .ctl_tx_inj_pause_opcode        (ctl_hwchk_tx_inj_pause_opcode),
        .ctl_tx_inj_pause_timer_ce      (ctl_hwchk_tx_inj_pause_timer_ce),
        .ctl_tx_inj_pause_timer_pfc0    (ctl_hwchk_tx_inj_pause_timer_pfc0),
        .ctl_tx_inj_pause_timer_pfc1    (ctl_hwchk_tx_inj_pause_timer_pfc1),
        .ctl_tx_inj_pause_timer_pfc2    (ctl_hwchk_tx_inj_pause_timer_pfc2),
        .ctl_tx_inj_pause_timer_pfc3    (ctl_hwchk_tx_inj_pause_timer_pfc3),
        .ctl_tx_inj_pause_timer_pfc4    (ctl_hwchk_tx_inj_pause_timer_pfc4),
        .ctl_tx_inj_pause_timer_pfc5    (ctl_hwchk_tx_inj_pause_timer_pfc5),
        .ctl_tx_inj_pause_timer_pfc6    (ctl_hwchk_tx_inj_pause_timer_pfc6),
        .ctl_tx_inj_pause_timer_pfc7    (ctl_hwchk_tx_inj_pause_timer_pfc7),
        .ack_tx_inj_pause               (ack_tx_inj_pause),

        .prbs_data                      (prbs_data),

        .ena                            (frm_gen_ena),
        .pre                            (frm_gen_pre),
        .sop                            (frm_gen_sop),
        .eop                            (frm_gen_eop),
        .mty                            (frm_gen_mty),
        .last                           (frm_gen_last),
        .data                           (frm_gen_data),
        .err                            (frm_gen_err),
        .poison                         (frm_gen_poison),

        .bad_fcs_incr                   (frm_gen_bad_fcs),
        .vlan_incr                      (frm_gen_vlan),
        .broadcast_incr                 (frm_gen_broadcast),
        .multicast_incr                 (frm_gen_multicast),
        .unicast_incr                   (frm_gen_unicast)

    );

    // This logic has a latency of three cycles (d3)
    gtfmac_hwchk_tx_fcs  i_tx_fcs  (

        .clk                    (gen_clk),
        .reset                  (~gen_rst),

        // We always add FCS, so we can integrity check our data.
        .ctl_tx_add_fcs         (1'b1),
        .ctl_tx_ignore_fcs      (1'b1),

        .i_ena_passthrough      (1'b1), // tie off - forces the pipeline to keep moving
        .i_ena                  (frm_gen_ena),
        .i_is_ctrl              (frm_gen_pre),
        .i_sop                  (frm_gen_sop),
        .i_dat                  ({  frm_gen_data[7:0],
                                    frm_gen_data[15:8],
                                    frm_gen_data[23:16],
                                    frm_gen_data[31:24],
                                    frm_gen_data[39:32],
                                    frm_gen_data[47:40],
                                    frm_gen_data[55:48],
                                    frm_gen_data[63:56]
                                }), // [64-1:0]
        .i_eop                  (frm_gen_eop),
        .i_mty                  (frm_gen_mty), // [3-1:0]
        .i_err                  (frm_gen_err),
        .i_poison               (frm_gen_poison),

        .o_ena_passthrough      (),
        .o_ena                  (fcs_ena),
        .o_is_ctrl              (fcs_pre),
        .o_sop                  (fcs_sop),
        .o_dat                  ({  fcs_data[7:0],
                                    fcs_data[15:8],
                                    fcs_data[23:16],
                                    fcs_data[31:24],
                                    fcs_data[39:32],
                                    fcs_data[47:40],
                                    fcs_data[55:48],
                                    fcs_data[63:56]
                                }), // [64-1:0]
        .o_eop                  (fcs_eop),
        .o_mty                  (fcs_mty), // [3-1:0]
        .o_err                  (fcs_err),
        .o_poison               (fcs_poison),

        .o_crc_val              (),
        .o_crc                  (), // [31:0]
        .o_crc_bad              (),
        .o_crc_err              (),
        .o_crc_stomped          ()
    );

    // Delay, and adjust, TLAST to reflect the fact that we are lengthening the frame
    // by four bytes above.
    logic   [7:0]   frm_gen_last_d0, frm_gen_last_d1, frm_gen_last_d2, frm_gen_last_d3;
    logic   [7:0]   fcs_last;
    logic           fcs_bad_fcs;
    logic           fcs_vlan;
    logic           fcs_broadcast;
    logic           fcs_multicast;
    logic           fcs_unicast;

    always @(posedge gen_clk) begin

        frm_gen_last_d0 <= 8'd0;
        frm_gen_last_d1 <= frm_gen_last_d0;
        frm_gen_last_d2 <= frm_gen_last_d1;
        frm_gen_last_d3 <= frm_gen_last_d2;

        case (frm_gen_last)
            8'b00000001: begin frm_gen_last_d1 <= 8'b00010000; end
            8'b00000010: begin frm_gen_last_d1 <= 8'b00100000; end
            8'b00000100: begin frm_gen_last_d1 <= 8'b01000000; end
            8'b00001000: begin frm_gen_last_d1 <= 8'b10000000; end
            8'b00010000: begin frm_gen_last_d0 <= 8'b00000001; end
            8'b00100000: begin frm_gen_last_d0 <= 8'b00000010; end
            8'b01000000: begin frm_gen_last_d0 <= 8'b00000100; end
            8'b10000000: begin frm_gen_last_d0 <= 8'b00001000; end
        endcase

    end

    // Delay the stats flags by the delay through the FCS calculator
    logic   [2:0]   frm_gen_bad_fcs_dly;
    logic   [2:0]   frm_gen_vlan_dly;
    logic   [2:0]   frm_gen_broadcast_dly;
    logic   [2:0]   frm_gen_multicast_dly;
    logic   [2:0]   frm_gen_unicast_dly;

    always @(posedge gen_clk) begin

        frm_gen_bad_fcs_dly     <= {frm_gen_bad_fcs_dly[1:0],   frm_gen_bad_fcs};
        frm_gen_vlan_dly        <= {frm_gen_vlan_dly[1:0],      frm_gen_vlan};
        frm_gen_broadcast_dly   <= {frm_gen_broadcast_dly[1:0], frm_gen_broadcast};
        frm_gen_multicast_dly   <= {frm_gen_multicast_dly[1:0], frm_gen_multicast};
        frm_gen_unicast_dly     <= {frm_gen_unicast_dly[1:0],   frm_gen_unicast};

    end

    assign fcs_last         = frm_gen_last_d3;
    assign fcs_bad_fcs      = frm_gen_bad_fcs_dly[2];
    assign fcs_vlan         = frm_gen_vlan_dly[2];
    assign fcs_broadcast    = frm_gen_broadcast_dly[2];
    assign fcs_multicast    = frm_gen_multicast_dly[2];
    assign fcs_unicast      = frm_gen_unicast_dly[2];



    gtfmac_hwchk_ra_buf   # (
        .MAX_CREDITS    (8)
    )
    i_tx_gen_buf   (

        .in_clk                         (gen_clk),
        .in_rst                         (gen_rst),

        .in_bp                          (bp),

        .din_ena                        (fcs_ena),
        .din_pre                        (fcs_pre),
        .din_sop                        (fcs_sop),
        .din_eop                        (fcs_eop),
        .din_data                       (fcs_data),
        .din_last                       (fcs_last),
        .din_err                        (fcs_err),
        .din_poison                     (fcs_poison),

        .in_overflow                    (),

        .out_clk                        (tx_clk),
        .out_rst                        (tx_rst),

        .out_credit                     (tx_credit),

        .dout_ena                       (buf_ena),
        .dout_pre                       (buf_pre),
        .dout_sop                       (buf_sop),
        .dout_data                      (buf_data),
        .dout_last                      (buf_last),
        .dout_err                       (buf_err),
        .dout_poison                    (buf_poison)


    );


    gtfmac_hwchk_tx_gtfmac_if  # (
        .AXI_IF_DEPTH   (8)
    )
    i_tx_gtfmac_if  (

        .tx_axis_clk                    (tx_clk),
        .tx_axis_rst                    (tx_rst),

        .din_ena                        (buf_ena),
        .din_pre                        (buf_pre),
        .din_sop                        (buf_sop),
        .din_data                       (buf_data),
        .din_err                        (buf_err),
        .din_poison                     (buf_poison),
        .din_last                       (buf_last),
        .tx_credit                      (tx_credit),

        .tx_sop                         (tx_sop),                   // for latency measurement

        .tx_axis_tready                 (tx_axis_tready),           // input wire
        .tx_axis_tvalid                 (tx_axis_tvalid),           // output  wire
        .tx_axis_tdata                  (tx_axis_tdata),            // output  wire [63:0]
        .tx_axis_tlast                  (tx_axis_tlast),            // output  wire [7:0]
        .tx_axis_tpre                   (tx_axis_tpre),             // output  wire [7:0]
        .tx_axis_terr                   (tx_axis_terr),             // output  wire
        .tx_axis_tterm                  (tx_axis_tterm),            // output  wire [4:0]
        .tx_axis_tsof                   (tx_axis_tsof),             // output  wire [1:0]
        .tx_axis_tpoison                (tx_axis_tpoison),          // output  wire
        .tx_axis_tcan_start             (tx_axis_tcan_start),       // input wire
        .tx_start_measured_run          (tx_start_measured_run),    // output wire

        .tx_unfout                      (tx_unfout),                // input wire

        .tx_ptp_sop                     (tx_ptp_sop),               // input wire
        .tx_ptp_sop_pos                 (tx_ptp_sop_pos),           // input wire

        .tx_gb_seq_start                (tx_gb_seq_start),          // input wire
        .tx_gb_seq_sync                 (),                         // output  wire

        .ctl_tx_fcs_ins_enable          (ctl_tx_fcs_ins_enable),
        .ctl_tx_data_rate               (ctl_tx_data_rate),
        .ctl_tx_custom_preamble_en      (ctl_tx_custom_preamble_en),
        .ctl_tx_start_framing_enable    (ctl_tx_start_framing_enable),
        .ctl_tx_variable_ipg            (ctl_tx_variable_ipg),

        .tx_buffer_overflow             (tx_buffer_overflow)

    );

endmodule
`default_nettype wire

`default_nettype none
module gtfmac_hwchk_tx_frm_gen (

    input       wire            clk,
    input       wire            rst,
    input       wire            bp,

    input       wire            ctl_frm_gen_en,
    input       wire            ctl_frm_gen_mode,
    input       wire    [13:0]  ctl_max_len,
    input       wire    [13:0]  ctl_min_len,
    input       wire    [31:0]  ctl_num_frames,
    output      reg             frm_gen_done,

    input       wire            ctl_tx_start_framing_enable,
    input       wire            ctl_tx_custom_preamble_en,
    input       wire    [63:0]  ctl_tx_custom_preamble,

    input       wire            ctl_tx_fcs_ins_enable,  // 1 = DUT handling Ethernet FCS; 0 = we handle Ethernet FCS

    input       wire            ctl_tx_inj_err,
    
    input       wire            ctl_tx_inj_poison,

    input       wire            ctl_tx_start_lat_run,
    output      logic           ack_tx_start_lat_run,

    input       wire            ctl_tx_inj_pause,
    input       wire    [47:0]  ctl_tx_inj_pause_sa,
    input       wire    [47:0]  ctl_tx_inj_pause_da,
    input       wire    [15:0]  ctl_tx_inj_pause_ethtype,
    input       wire    [15:0]  ctl_tx_inj_pause_opcode,
    input       wire    [15:0]  ctl_tx_inj_pause_timer_ce,
    input       wire    [15:0]  ctl_tx_inj_pause_timer_pfc0,
    input       wire    [15:0]  ctl_tx_inj_pause_timer_pfc1,
    input       wire    [15:0]  ctl_tx_inj_pause_timer_pfc2,
    input       wire    [15:0]  ctl_tx_inj_pause_timer_pfc3,
    input       wire    [15:0]  ctl_tx_inj_pause_timer_pfc4,
    input       wire    [15:0]  ctl_tx_inj_pause_timer_pfc5,
    input       wire    [15:0]  ctl_tx_inj_pause_timer_pfc6,
    input       wire    [15:0]  ctl_tx_inj_pause_timer_pfc7,
    output      reg             ack_tx_inj_pause,

    input       wire    [63:0]  prbs_data,

    output      logic           ena,
    output      logic           pre,
    output      logic           sop,
    output      logic           eop,
    output      logic   [2:0]   mty,
    output      logic   [7:0]   last,
    output      logic   [63:0]  data,
    output      logic           err,
    output      logic           poison,

    output      wire            bad_fcs_incr,
    output      wire            vlan_incr,
    output      wire            broadcast_incr,
    output      wire            multicast_incr,
    output      wire            unicast_incr

);

    logic   frm_gen_mode, frm_gen_mode_R;

    gtfmac_hwchk_syncer_level i_sync_frm_gen_mode (

      .reset      (~rst),
      .clk        (clk),

      .datain     (ctl_frm_gen_mode),
      .dataout    (frm_gen_mode)

    );

    logic   frm_gen_en, frm_gen_en_R;

    gtfmac_hwchk_syncer_level i_sync_frm_gen_en (

      .reset      (~rst),
      .clk        (clk),

      .datain     (ctl_frm_gen_en),
      .dataout    (frm_gen_en)

    );

    logic   done, done_R;

    assign  frm_gen_done = done & ~done_R;


    wire    [13:0]  ctl_min_len_lcl = ctl_min_len - 14'd4 - {ctl_tx_fcs_ins_enable, 2'd0};
    wire    [13:0]  ctl_max_len_lcl = ctl_max_len - 14'd4 - {ctl_tx_fcs_ins_enable, 2'd0};


    localparam int POLY = 17'b1_0110_1000_0000_0001; // the polynomial used to generate the random packet length

    logic fb;
    logic [1-1:0][15:0] len_r_nxt;
    reg   [1-1:0][15:0] len_r;
    logic [1-1:0][13:0] pkt_len_r;

    wire    [13:0]  i_max_len = ctl_max_len_lcl;
    wire    [13:0]  i_min_len = ctl_min_len_lcl;


    always @* begin
      for (int i=0; i<1; i++) begin
        fb = 1'b0;
        for (int j=16; j>=0; j--) begin
          fb = fb ^ (len_r[i][j] & POLY[j+1]);
        end
        len_r_nxt[i][15:1] = len_r[i][14:0];
        len_r_nxt[i][0] = fb;
      end
    end

    always @(posedge clk) begin
      //
      // generate random packet lengths
      //
      for (int i=0; i<1; i++) begin
        if (i_max_len <= i_min_len) begin
          pkt_len_r[i] <= i_min_len;
        end
        else if (len_r[i][13:0] <= i_max_len) begin
          pkt_len_r[i] <= (len_r[i][13:0] >= i_min_len)? len_r[i][13:0] : i_min_len;
        end
        else begin // len_r[i][13:0] > i_max_len
          pkt_len_r[i] <= '0;

          if (|len_r[i][9:0] & len_r[i][9:0] <= i_max_len & len_r[i][9:0] >= i_min_len) pkt_len_r[i] <= len_r[i][9:0];
          else if (|len_r[i][7:0] & len_r[i][7:0] <= i_max_len & len_r[i][7:0] >= i_min_len) pkt_len_r[i] <= len_r[i][7:0];
          else if  (|len_r[i][5:0] & len_r[i][5:0] <= i_max_len & len_r[i][5:0] >= i_min_len) pkt_len_r[i] <= len_r[i][5:0];
          else pkt_len_r[i] <= i_max_len;
        end
      end

      if (rst) begin
        for (int i=0; i<3; i++) begin
          len_r[i][3:0] <= i;
          len_r[i][15:4] <= '1;
        end
      end
      else begin
        len_r <= len_r_nxt;
      end

    end


    reg     [1:0]       state;
    reg     [13:0]      frm_len;

    reg     [10:0]      cycle_cnt;
    wire    [7:0][63:0] pause_frame;
    reg     [13:0]      last_len;


    assign  pause_frame[0]  = { ctl_tx_inj_pause_sa[15:8], ctl_tx_inj_pause_sa[7:0], ctl_tx_inj_pause_da[47:40], ctl_tx_inj_pause_da[39:32], ctl_tx_inj_pause_da[31:24], ctl_tx_inj_pause_da[23:16], ctl_tx_inj_pause_da[15:8], ctl_tx_inj_pause_da[7:0]};
    assign  pause_frame[1]  = { ctl_tx_inj_pause_opcode[15:8], ctl_tx_inj_pause_opcode[7:0], ctl_tx_inj_pause_ethtype[15:8], ctl_tx_inj_pause_ethtype[7:0], ctl_tx_inj_pause_sa[47:40], ctl_tx_inj_pause_sa[39:32], ctl_tx_inj_pause_sa[31:24], ctl_tx_inj_pause_sa[23:16]};
    assign  pause_frame[2]  = { ctl_tx_inj_pause_timer_pfc2[15:8], ctl_tx_inj_pause_timer_pfc2[7:0], ctl_tx_inj_pause_timer_pfc1[15:8], ctl_tx_inj_pause_timer_pfc1[7:0], ctl_tx_inj_pause_timer_pfc0[15:8], ctl_tx_inj_pause_timer_pfc0[7:0], ctl_tx_inj_pause_timer_ce[15:8], ctl_tx_inj_pause_timer_ce[7:0] };
    assign  pause_frame[3]  = { ctl_tx_inj_pause_timer_pfc6[15:8], ctl_tx_inj_pause_timer_pfc6[7:0], ctl_tx_inj_pause_timer_pfc5[15:8], ctl_tx_inj_pause_timer_pfc5[7:0], ctl_tx_inj_pause_timer_pfc4[15:8], ctl_tx_inj_pause_timer_pfc4[7:0], ctl_tx_inj_pause_timer_pfc3[15:8], ctl_tx_inj_pause_timer_pfc3[7:0] };
    assign  pause_frame[4]  = { 48'h0, ctl_tx_inj_pause_timer_pfc7[15:8], ctl_tx_inj_pause_timer_pfc7[7:0] };
    assign  pause_frame[5]  = 64'd0;
    assign  pause_frame[6]  = 64'd0;
    assign  pause_frame[7]  = {32'd0, 32'd0};

    reg     rand_multicast;
    reg     rand_broadcast;
    reg     rand_unicast;
    reg     rand_vlan;

    reg     bad_fcs;
    reg     vlan;
    reg     broadcast;
    reg     multicast;
    reg     unicast;

    reg     [31:0]  frames_to_send;
    reg     [31:0]  frames_sent;

    always @ (*) begin

        rand_multicast    = 1'b0;
        rand_broadcast    = 1'b0;
        rand_unicast      = 1'b0;
        rand_vlan         = 1'b0;

        case (len_r[0][3:0])

            4'd15, 4'd14, 4'd13, 4'd12: begin
                rand_broadcast    = 1'b1;
            end

            4'd11, 4'd10, 4'd9, 4'd8: begin
                rand_multicast    = 1'b1;
            end

            default: begin
                rand_unicast      = 1'b1;
            end

        endcase

        rand_vlan = len_r[0][0];

    end

    assign  bad_fcs_incr    = sop & bad_fcs;
    assign  vlan_incr       = sop & vlan;
    assign  broadcast_incr  = sop & broadcast;
    assign  multicast_incr  = sop & multicast;
    assign  unicast_incr    = sop & unicast;


    localparam      IDLE_STATE  = 2'h0,
                    FRM_STATE   = 2'h1,
                    PAUSE_STATE = 2'h2;

    logic   [13:0]  len_rem;
    assign          len_rem = frm_len - {cycle_cnt, 3'd0};

    logic           gen_preamble;
    assign          gen_preamble = ctl_tx_custom_preamble_en | ctl_tx_start_framing_enable;

    always @(posedge clk) begin

        ena                     <= 1'b0;
        pre                     <= 1'b0;
        sop                     <= 1'b0;
        data                    <= prbs_data;
        eop                     <= 1'b0;
        mty                     <= 3'd0;
        last                    <= 8'd0;
        err                     <= 1'b0;
        poison                  <= 1'b0; 
        ack_tx_inj_pause        <= 1'b0;
        ack_tx_start_lat_run    <= 1'b0;
        frm_gen_mode_R          <= frm_gen_mode;

        bad_fcs                 <= 1'b0;
        done                    <= 1'b0;
        done_R                  <= done;
        frm_gen_en_R            <= frm_gen_en;

        case (state)

            IDLE_STATE: begin

                cycle_cnt   <= 11'd0;
                last        <= 8'd0;

                if (frm_gen_mode && !frm_gen_mode_R) begin
                    frm_len <= ctl_min_len_lcl;
                end

                if (frm_gen_en == 1'b0) begin
                    frames_to_send  <= ctl_num_frames;
                    frames_sent     <= 32'd0;
                end

                done    <= (|ctl_num_frames == 1'b1) && (frames_sent == frames_to_send);


                // ---- START A NEW FRAME ----
                // don't start a new frame, if
                //  -- there's backpressure
                //  -- ctl_tx_fcs_ins_enable=0, and our FCS generator needs space to insert 4B
                if ( frm_gen_en && !bp && !(eop && (mty < 3'd4)) && ( (|ctl_num_frames == 1'b0) || (|ctl_num_frames == 1'b1) && frames_sent < frames_to_send) ) begin

                    sop         <= ~gen_preamble;
                    pre         <=  gen_preamble;
                    ena         <= 1'b1;
                    frames_sent <= frames_sent + (|ctl_num_frames);

                    if (ctl_tx_inj_pause) begin

                        if (gen_preamble) begin
                            data        <= ctl_tx_start_framing_enable ? 64'd0 : ctl_tx_custom_preamble;
                            cycle_cnt   <= 11'd0;
                        end
                        else begin
                            data        <= pause_frame[0];
                            cycle_cnt   <= 11'd1;
                        end

                        state       <= PAUSE_STATE;

                    end
                    else begin

                        if (!frm_gen_mode) begin
                            frm_len     <= pkt_len_r[0];
                        end

                        vlan        <= rand_vlan;

                        if (ctl_tx_start_lat_run) begin
                            broadcast   <= 1'b0;
                            multicast   <= 1'b0;
                            unicast     <= 1'b1;
                        end
                        else begin
                            broadcast   <= rand_broadcast;
                            multicast   <= rand_multicast;
                            unicast     <= rand_unicast;
                        end

                        if (gen_preamble) begin
                            data        <= ctl_tx_start_framing_enable ? 64'd0 : ctl_tx_custom_preamble;
                            cycle_cnt   <= 11'd0;
                        end
                        else begin

                            // Don't allow the data to pick up our magic word FACE
                            data        <= (prbs_data[15:0] == 16'hFACE) ? 16'h0ACE : prbs_data;

                            if (ctl_tx_start_lat_run) begin
                                ack_tx_start_lat_run    <= 1'b1;
                                data[15:0]              <= 16'hFACE;
                            end
                            else if (rand_broadcast) begin
                                data[47:0]  <= {48{1'b1}};
                            end
                            else if (rand_multicast) begin
                                data[0]     <= 1'b1;
                            end
                            else begin
                                data[0]     <= 1'b0;
                            end

                            cycle_cnt   <= 11'd1;
                        end

                        state       <= FRM_STATE;

                    end
                end

            end

            PAUSE_STATE: begin

                // Ignore bp during pause frame generation (there is enough room downstream)

                ena         <= 1'b1;
                sop         <= pre;
                cycle_cnt   <= cycle_cnt + 1'b1;
                data        <= pause_frame[cycle_cnt[2:0]];

                // We always append an FCS downstream; so our pause frames are 56B if ctl_tx_fcs_ins_enable; 60B otherwise

                if (ctl_tx_fcs_ins_enable && cycle_cnt == 10'd7) begin
                    // tlast indicates the third-last byte of the packet
                    last      <= 8'b0010_0000;
                end
                else if (!ctl_tx_fcs_ins_enable && cycle_cnt == 10'd6) begin
                    // tlast indicates the seventh-last byte of the packet
                    last      <= 8'b0010_0000;
                end

                if (cycle_cnt == 10'd7 && ctl_tx_fcs_ins_enable) begin  // 56B
                    eop                 <= 1'b1;
                    mty                 <= 4'd0;
                    ack_tx_inj_pause    <= 1'b1;
                    err                 <= ctl_tx_inj_err;
                    poison              <= ctl_tx_inj_poison;
                    cycle_cnt           <= 11'd0;
                    state               <= IDLE_STATE;
                end
                else if (cycle_cnt == 10'd8 && !ctl_tx_fcs_ins_enable) begin // 60B
                    eop                 <= 1'b1;
                    mty                 <= 4'd4;
                    ack_tx_inj_pause    <= 1'b1;
                    err                 <= ctl_tx_inj_err;
                    poison              <= ctl_tx_inj_poison;
                    cycle_cnt           <= 11'd0;
                    state               <= IDLE_STATE;
                end

            end

            default: begin // FRM_STATE

                ena         <= 1'b0;
                pre         <= pre & bp;

                if (!bp || len_rem <= 14'd14) begin

                    ena         <= 1'b1;
                    sop         <= pre;

                    // Apply the modifiers for the MAC address
                    if (cycle_cnt == 14'd0) begin

                        // Don't allow the data to pick up our magic word FACE
                        data        <= (prbs_data[15:0] == 16'hFACE) ? 16'h0ACE : prbs_data;

                        ack_tx_start_lat_run    <= ctl_tx_start_lat_run;

                        if (ctl_tx_start_lat_run) begin
                            ack_tx_start_lat_run    <= 1'b1;
                            data[15:0]              <= 16'hFACE;
                        end
                        else if (broadcast) begin
                            data[47:0]  <= {48{1'b1}};
                        end
                        else if (multicast) begin
                            data[0]     <= 1'b1;
                        end
                        else begin
                            data[0]     <= 1'b0;
                        end

                    end
                    else if (cycle_cnt == 14'd1) begin
                        if (vlan) begin
                            data[47:32] <= 16'h0081;
                        end
                        else if (frm_len <= 14'd1500) begin
                            {data[39:32], data[47:40]} <= {2'd0, frm_len} - 16'd12 - 16'd2 + {13'd0, ctl_tx_fcs_ins_enable, 2'd0};
                        end
                        else begin
                            {data[39:32], data[47:40]} <= {data[39:32], data[47:40]} | 16'h2048;
                        end

                    end
                    else if (cycle_cnt == 14'd2) begin
                        if (vlan) begin
                            if (frm_len <= 14'd1500) begin
                                {data[7:0], data[15:8]} <= {2'd0, frm_len} - 16'd12 - 16'd4 - 16'd2 + {13'd0, ctl_tx_fcs_ins_enable, 2'd0};
                            end
                            else begin
                                {data[7:0], data[15:8]} <= {data[7:0], data[15:8]} | 16'd2048;
                            end
                        end
                    end

                    cycle_cnt   <= cycle_cnt + 1'b1;

                    // Need to mark the third-last byte
                    if (ctl_tx_fcs_ins_enable) begin

                        case (len_rem)

                            14'd10:  last    <= 8'b10000000;
                            14'd9:   last    <= 8'b01000000;
                            14'd8:   last    <= 8'b00100000;
                            14'd7:   last    <= 8'b00010000;
                            14'd6:   last    <= 8'b00001000;
                            14'd5:   last    <= 8'b00000100;
                            14'd4:   last    <= 8'b00000010;
                            14'd3:   last    <= 8'b00000001;
                            default: last    <= 8'b00000000;

                        endcase

                    end

                    // Need to mark the seventh-last byte
                    else begin

                        case (len_rem)

                            14'd14:  last    <= 8'b10000000;
                            14'd13:  last    <= 8'b01000000;
                            14'd12:  last    <= 8'b00100000;
                            14'd11:  last    <= 8'b00010000;
                            14'd10:  last    <= 8'b00001000;
                            14'd9:   last    <= 8'b00000100;
                            14'd8:   last    <= 8'b00000010;
                            14'd7:   last    <= 8'b00000001;
                            default: last    <= 8'b00000000;

                        endcase

                    end

                    if (len_rem <= 14'd8) begin

                        eop             <= 1'b1;
                        mty             <= 4'd8 - frm_len[2:0];
                        err             <= ctl_tx_inj_err;
                        poison          <= ctl_tx_inj_poison;
                        cycle_cnt       <= 11'd0;
                        state           <= IDLE_STATE;

                        if (frm_gen_mode) begin
                            frm_len <= (frm_len == ctl_max_len_lcl) ? ctl_min_len_lcl : frm_len + 1'b1;
                        end

                    end

                end

            end

        endcase


        if (rst) begin
            state                   <= 2'h0;
            ena                     <= 1'b0;
            sop                     <= 1'b0;
            pre                     <= 1'b0;
            eop                     <= 1'b0;
            mty                     <= 3'd0;
            last                    <= 8'd0;
            err                     <= 1'b0;
            poison                  <= 1'b0;
            ack_tx_inj_pause        <= 1'b0;
            bad_fcs                 <= 1'b0;
            vlan                    <= 1'b0;
            broadcast               <= 1'b0;
            multicast               <= 1'b0;
            unicast                 <= 1'b0;
            frm_gen_mode_R          <= 1'b0;
            frm_gen_en_R            <= 1'b0;
            done                    <= 1'b0;
            done_R                  <= 1'b0;
            ack_tx_start_lat_run    <= 1'b0;
        end


    end

endmodule
`default_nettype wire

`default_nettype none
module gtfmac_hwchk_prbs_gen_64 (
  input  wire en,
  output wire [63:0] prbs_out,
  input  wire rst,
  input  wire clk);

  reg [63:0] lfsr_q,lfsr_c;

  assign prbs_out = lfsr_q;

  always @(*) begin
    lfsr_c[0] = lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[3] ^ lfsr_q[5] ^ lfsr_q[8] ^ lfsr_q[12] ^ lfsr_q[14] ^ lfsr_q[15] ^ lfsr_q[16] ^ lfsr_q[17] ^ lfsr_q[18] ^ lfsr_q[20] ^ lfsr_q[21] ^ lfsr_q[24] ^ lfsr_q[25] ^ lfsr_q[26] ^ lfsr_q[31] ^ lfsr_q[32] ^ lfsr_q[34] ^ lfsr_q[36] ^ lfsr_q[39] ^ lfsr_q[43] ^ lfsr_q[45] ^ lfsr_q[46] ^ lfsr_q[47] ^ lfsr_q[48] ^ lfsr_q[49] ^ lfsr_q[51] ^ lfsr_q[52] ^ lfsr_q[55] ^ lfsr_q[56] ^ lfsr_q[57] ^ lfsr_q[62] ^ lfsr_q[63];
    lfsr_c[1] = lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[4] ^ lfsr_q[6] ^ lfsr_q[9] ^ lfsr_q[13] ^ lfsr_q[15] ^ lfsr_q[16] ^ lfsr_q[17] ^ lfsr_q[18] ^ lfsr_q[19] ^ lfsr_q[21] ^ lfsr_q[22] ^ lfsr_q[25] ^ lfsr_q[26] ^ lfsr_q[27] ^ lfsr_q[32] ^ lfsr_q[33] ^ lfsr_q[35] ^ lfsr_q[37] ^ lfsr_q[40] ^ lfsr_q[44] ^ lfsr_q[46] ^ lfsr_q[47] ^ lfsr_q[48] ^ lfsr_q[49] ^ lfsr_q[50] ^ lfsr_q[52] ^ lfsr_q[53] ^ lfsr_q[56] ^ lfsr_q[57] ^ lfsr_q[58] ^ lfsr_q[63];
    lfsr_c[2] = lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[5] ^ lfsr_q[7] ^ lfsr_q[10] ^ lfsr_q[14] ^ lfsr_q[16] ^ lfsr_q[17] ^ lfsr_q[18] ^ lfsr_q[19] ^ lfsr_q[20] ^ lfsr_q[22] ^ lfsr_q[23] ^ lfsr_q[26] ^ lfsr_q[27] ^ lfsr_q[28] ^ lfsr_q[33] ^ lfsr_q[34] ^ lfsr_q[36] ^ lfsr_q[38] ^ lfsr_q[41] ^ lfsr_q[45] ^ lfsr_q[47] ^ lfsr_q[48] ^ lfsr_q[49] ^ lfsr_q[50] ^ lfsr_q[51] ^ lfsr_q[53] ^ lfsr_q[54] ^ lfsr_q[57] ^ lfsr_q[58] ^ lfsr_q[59];
    lfsr_c[3] = lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[6] ^ lfsr_q[8] ^ lfsr_q[11] ^ lfsr_q[15] ^ lfsr_q[17] ^ lfsr_q[18] ^ lfsr_q[19] ^ lfsr_q[20] ^ lfsr_q[21] ^ lfsr_q[23] ^ lfsr_q[24] ^ lfsr_q[27] ^ lfsr_q[28] ^ lfsr_q[29] ^ lfsr_q[34] ^ lfsr_q[35] ^ lfsr_q[37] ^ lfsr_q[39] ^ lfsr_q[42] ^ lfsr_q[46] ^ lfsr_q[48] ^ lfsr_q[49] ^ lfsr_q[50] ^ lfsr_q[51] ^ lfsr_q[52] ^ lfsr_q[54] ^ lfsr_q[55] ^ lfsr_q[58] ^ lfsr_q[59] ^ lfsr_q[60];
    lfsr_c[4] = lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[7] ^ lfsr_q[9] ^ lfsr_q[12] ^ lfsr_q[16] ^ lfsr_q[18] ^ lfsr_q[19] ^ lfsr_q[20] ^ lfsr_q[21] ^ lfsr_q[22] ^ lfsr_q[24] ^ lfsr_q[25] ^ lfsr_q[28] ^ lfsr_q[29] ^ lfsr_q[30] ^ lfsr_q[35] ^ lfsr_q[36] ^ lfsr_q[38] ^ lfsr_q[40] ^ lfsr_q[43] ^ lfsr_q[47] ^ lfsr_q[49] ^ lfsr_q[50] ^ lfsr_q[51] ^ lfsr_q[52] ^ lfsr_q[53] ^ lfsr_q[55] ^ lfsr_q[56] ^ lfsr_q[59] ^ lfsr_q[60] ^ lfsr_q[61];
    lfsr_c[5] = lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[8] ^ lfsr_q[10] ^ lfsr_q[13] ^ lfsr_q[17] ^ lfsr_q[19] ^ lfsr_q[20] ^ lfsr_q[21] ^ lfsr_q[22] ^ lfsr_q[23] ^ lfsr_q[25] ^ lfsr_q[26] ^ lfsr_q[29] ^ lfsr_q[30] ^ lfsr_q[31] ^ lfsr_q[36] ^ lfsr_q[37] ^ lfsr_q[39] ^ lfsr_q[41] ^ lfsr_q[44] ^ lfsr_q[48] ^ lfsr_q[50] ^ lfsr_q[51] ^ lfsr_q[52] ^ lfsr_q[53] ^ lfsr_q[54] ^ lfsr_q[56] ^ lfsr_q[57] ^ lfsr_q[60] ^ lfsr_q[61] ^ lfsr_q[62];
    lfsr_c[6] = lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[9] ^ lfsr_q[11] ^ lfsr_q[14] ^ lfsr_q[18] ^ lfsr_q[20] ^ lfsr_q[21] ^ lfsr_q[22] ^ lfsr_q[23] ^ lfsr_q[24] ^ lfsr_q[26] ^ lfsr_q[27] ^ lfsr_q[30] ^ lfsr_q[31] ^ lfsr_q[32] ^ lfsr_q[37] ^ lfsr_q[38] ^ lfsr_q[40] ^ lfsr_q[42] ^ lfsr_q[45] ^ lfsr_q[49] ^ lfsr_q[51] ^ lfsr_q[52] ^ lfsr_q[53] ^ lfsr_q[54] ^ lfsr_q[55] ^ lfsr_q[57] ^ lfsr_q[58] ^ lfsr_q[61] ^ lfsr_q[62] ^ lfsr_q[63];
    lfsr_c[7] = lfsr_q[7] ^ lfsr_q[8] ^ lfsr_q[10] ^ lfsr_q[12] ^ lfsr_q[15] ^ lfsr_q[19] ^ lfsr_q[21] ^ lfsr_q[22] ^ lfsr_q[23] ^ lfsr_q[24] ^ lfsr_q[25] ^ lfsr_q[27] ^ lfsr_q[28] ^ lfsr_q[31] ^ lfsr_q[32] ^ lfsr_q[33] ^ lfsr_q[38] ^ lfsr_q[39] ^ lfsr_q[41] ^ lfsr_q[43] ^ lfsr_q[46] ^ lfsr_q[50] ^ lfsr_q[52] ^ lfsr_q[53] ^ lfsr_q[54] ^ lfsr_q[55] ^ lfsr_q[56] ^ lfsr_q[58] ^ lfsr_q[59] ^ lfsr_q[62] ^ lfsr_q[63];
    lfsr_c[8] = lfsr_q[8] ^ lfsr_q[9] ^ lfsr_q[11] ^ lfsr_q[13] ^ lfsr_q[16] ^ lfsr_q[20] ^ lfsr_q[22] ^ lfsr_q[23] ^ lfsr_q[24] ^ lfsr_q[25] ^ lfsr_q[26] ^ lfsr_q[28] ^ lfsr_q[29] ^ lfsr_q[32] ^ lfsr_q[33] ^ lfsr_q[34] ^ lfsr_q[39] ^ lfsr_q[40] ^ lfsr_q[42] ^ lfsr_q[44] ^ lfsr_q[47] ^ lfsr_q[51] ^ lfsr_q[53] ^ lfsr_q[54] ^ lfsr_q[55] ^ lfsr_q[56] ^ lfsr_q[57] ^ lfsr_q[59] ^ lfsr_q[60] ^ lfsr_q[63];
    lfsr_c[9] = lfsr_q[9] ^ lfsr_q[10] ^ lfsr_q[12] ^ lfsr_q[14] ^ lfsr_q[17] ^ lfsr_q[21] ^ lfsr_q[23] ^ lfsr_q[24] ^ lfsr_q[25] ^ lfsr_q[26] ^ lfsr_q[27] ^ lfsr_q[29] ^ lfsr_q[30] ^ lfsr_q[33] ^ lfsr_q[34] ^ lfsr_q[35] ^ lfsr_q[40] ^ lfsr_q[41] ^ lfsr_q[43] ^ lfsr_q[45] ^ lfsr_q[48] ^ lfsr_q[52] ^ lfsr_q[54] ^ lfsr_q[55] ^ lfsr_q[56] ^ lfsr_q[57] ^ lfsr_q[58] ^ lfsr_q[60] ^ lfsr_q[61];
    lfsr_c[10] = lfsr_q[10] ^ lfsr_q[11] ^ lfsr_q[13] ^ lfsr_q[15] ^ lfsr_q[18] ^ lfsr_q[22] ^ lfsr_q[24] ^ lfsr_q[25] ^ lfsr_q[26] ^ lfsr_q[27] ^ lfsr_q[28] ^ lfsr_q[30] ^ lfsr_q[31] ^ lfsr_q[34] ^ lfsr_q[35] ^ lfsr_q[36] ^ lfsr_q[41] ^ lfsr_q[42] ^ lfsr_q[44] ^ lfsr_q[46] ^ lfsr_q[49] ^ lfsr_q[53] ^ lfsr_q[55] ^ lfsr_q[56] ^ lfsr_q[57] ^ lfsr_q[58] ^ lfsr_q[59] ^ lfsr_q[61] ^ lfsr_q[62];
    lfsr_c[11] = lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[14] ^ lfsr_q[16] ^ lfsr_q[19] ^ lfsr_q[23] ^ lfsr_q[25] ^ lfsr_q[26] ^ lfsr_q[27] ^ lfsr_q[28] ^ lfsr_q[29] ^ lfsr_q[31] ^ lfsr_q[32] ^ lfsr_q[35] ^ lfsr_q[36] ^ lfsr_q[37] ^ lfsr_q[42] ^ lfsr_q[43] ^ lfsr_q[45] ^ lfsr_q[47] ^ lfsr_q[50] ^ lfsr_q[54] ^ lfsr_q[56] ^ lfsr_q[57] ^ lfsr_q[58] ^ lfsr_q[59] ^ lfsr_q[60] ^ lfsr_q[62] ^ lfsr_q[63];
    lfsr_c[12] = lfsr_q[12] ^ lfsr_q[13] ^ lfsr_q[15] ^ lfsr_q[17] ^ lfsr_q[20] ^ lfsr_q[24] ^ lfsr_q[26] ^ lfsr_q[27] ^ lfsr_q[28] ^ lfsr_q[29] ^ lfsr_q[30] ^ lfsr_q[32] ^ lfsr_q[33] ^ lfsr_q[36] ^ lfsr_q[37] ^ lfsr_q[38] ^ lfsr_q[43] ^ lfsr_q[44] ^ lfsr_q[46] ^ lfsr_q[48] ^ lfsr_q[51] ^ lfsr_q[55] ^ lfsr_q[57] ^ lfsr_q[58] ^ lfsr_q[59] ^ lfsr_q[60] ^ lfsr_q[61] ^ lfsr_q[63];
    lfsr_c[13] = lfsr_q[13] ^ lfsr_q[14] ^ lfsr_q[16] ^ lfsr_q[18] ^ lfsr_q[21] ^ lfsr_q[25] ^ lfsr_q[27] ^ lfsr_q[28] ^ lfsr_q[29] ^ lfsr_q[30] ^ lfsr_q[31] ^ lfsr_q[33] ^ lfsr_q[34] ^ lfsr_q[37] ^ lfsr_q[38] ^ lfsr_q[39] ^ lfsr_q[44] ^ lfsr_q[45] ^ lfsr_q[47] ^ lfsr_q[49] ^ lfsr_q[52] ^ lfsr_q[56] ^ lfsr_q[58] ^ lfsr_q[59] ^ lfsr_q[60] ^ lfsr_q[61] ^ lfsr_q[62];
    lfsr_c[14] = lfsr_q[14] ^ lfsr_q[15] ^ lfsr_q[17] ^ lfsr_q[19] ^ lfsr_q[22] ^ lfsr_q[26] ^ lfsr_q[28] ^ lfsr_q[29] ^ lfsr_q[30] ^ lfsr_q[31] ^ lfsr_q[32] ^ lfsr_q[34] ^ lfsr_q[35] ^ lfsr_q[38] ^ lfsr_q[39] ^ lfsr_q[40] ^ lfsr_q[45] ^ lfsr_q[46] ^ lfsr_q[48] ^ lfsr_q[50] ^ lfsr_q[53] ^ lfsr_q[57] ^ lfsr_q[59] ^ lfsr_q[60] ^ lfsr_q[61] ^ lfsr_q[62] ^ lfsr_q[63];
    lfsr_c[15] = lfsr_q[15] ^ lfsr_q[16] ^ lfsr_q[18] ^ lfsr_q[20] ^ lfsr_q[23] ^ lfsr_q[27] ^ lfsr_q[29] ^ lfsr_q[30] ^ lfsr_q[31] ^ lfsr_q[32] ^ lfsr_q[33] ^ lfsr_q[35] ^ lfsr_q[36] ^ lfsr_q[39] ^ lfsr_q[40] ^ lfsr_q[41] ^ lfsr_q[46] ^ lfsr_q[47] ^ lfsr_q[49] ^ lfsr_q[51] ^ lfsr_q[54] ^ lfsr_q[58] ^ lfsr_q[60] ^ lfsr_q[61] ^ lfsr_q[62] ^ lfsr_q[63];
    lfsr_c[16] = lfsr_q[16] ^ lfsr_q[17] ^ lfsr_q[19] ^ lfsr_q[21] ^ lfsr_q[24] ^ lfsr_q[28] ^ lfsr_q[30] ^ lfsr_q[31] ^ lfsr_q[32] ^ lfsr_q[33] ^ lfsr_q[34] ^ lfsr_q[36] ^ lfsr_q[37] ^ lfsr_q[40] ^ lfsr_q[41] ^ lfsr_q[42] ^ lfsr_q[47] ^ lfsr_q[48] ^ lfsr_q[50] ^ lfsr_q[52] ^ lfsr_q[55] ^ lfsr_q[59] ^ lfsr_q[61] ^ lfsr_q[62] ^ lfsr_q[63];
    lfsr_c[17] = lfsr_q[17] ^ lfsr_q[18] ^ lfsr_q[20] ^ lfsr_q[22] ^ lfsr_q[25] ^ lfsr_q[29] ^ lfsr_q[31] ^ lfsr_q[32] ^ lfsr_q[33] ^ lfsr_q[34] ^ lfsr_q[35] ^ lfsr_q[37] ^ lfsr_q[38] ^ lfsr_q[41] ^ lfsr_q[42] ^ lfsr_q[43] ^ lfsr_q[48] ^ lfsr_q[49] ^ lfsr_q[51] ^ lfsr_q[53] ^ lfsr_q[56] ^ lfsr_q[60] ^ lfsr_q[62] ^ lfsr_q[63];
    lfsr_c[18] = lfsr_q[18] ^ lfsr_q[19] ^ lfsr_q[21] ^ lfsr_q[23] ^ lfsr_q[26] ^ lfsr_q[30] ^ lfsr_q[32] ^ lfsr_q[33] ^ lfsr_q[34] ^ lfsr_q[35] ^ lfsr_q[36] ^ lfsr_q[38] ^ lfsr_q[39] ^ lfsr_q[42] ^ lfsr_q[43] ^ lfsr_q[44] ^ lfsr_q[49] ^ lfsr_q[50] ^ lfsr_q[52] ^ lfsr_q[54] ^ lfsr_q[57] ^ lfsr_q[61] ^ lfsr_q[63];
    lfsr_c[19] = lfsr_q[19] ^ lfsr_q[20] ^ lfsr_q[22] ^ lfsr_q[24] ^ lfsr_q[27] ^ lfsr_q[31] ^ lfsr_q[33] ^ lfsr_q[34] ^ lfsr_q[35] ^ lfsr_q[36] ^ lfsr_q[37] ^ lfsr_q[39] ^ lfsr_q[40] ^ lfsr_q[43] ^ lfsr_q[44] ^ lfsr_q[45] ^ lfsr_q[50] ^ lfsr_q[51] ^ lfsr_q[53] ^ lfsr_q[55] ^ lfsr_q[58] ^ lfsr_q[62];
    lfsr_c[20] = lfsr_q[20] ^ lfsr_q[21] ^ lfsr_q[23] ^ lfsr_q[25] ^ lfsr_q[28] ^ lfsr_q[32] ^ lfsr_q[34] ^ lfsr_q[35] ^ lfsr_q[36] ^ lfsr_q[37] ^ lfsr_q[38] ^ lfsr_q[40] ^ lfsr_q[41] ^ lfsr_q[44] ^ lfsr_q[45] ^ lfsr_q[46] ^ lfsr_q[51] ^ lfsr_q[52] ^ lfsr_q[54] ^ lfsr_q[56] ^ lfsr_q[59] ^ lfsr_q[63];
    lfsr_c[21] = lfsr_q[21] ^ lfsr_q[22] ^ lfsr_q[24] ^ lfsr_q[26] ^ lfsr_q[29] ^ lfsr_q[33] ^ lfsr_q[35] ^ lfsr_q[36] ^ lfsr_q[37] ^ lfsr_q[38] ^ lfsr_q[39] ^ lfsr_q[41] ^ lfsr_q[42] ^ lfsr_q[45] ^ lfsr_q[46] ^ lfsr_q[47] ^ lfsr_q[52] ^ lfsr_q[53] ^ lfsr_q[55] ^ lfsr_q[57] ^ lfsr_q[60];
    lfsr_c[22] = lfsr_q[22] ^ lfsr_q[23] ^ lfsr_q[25] ^ lfsr_q[27] ^ lfsr_q[30] ^ lfsr_q[34] ^ lfsr_q[36] ^ lfsr_q[37] ^ lfsr_q[38] ^ lfsr_q[39] ^ lfsr_q[40] ^ lfsr_q[42] ^ lfsr_q[43] ^ lfsr_q[46] ^ lfsr_q[47] ^ lfsr_q[48] ^ lfsr_q[53] ^ lfsr_q[54] ^ lfsr_q[56] ^ lfsr_q[58] ^ lfsr_q[61];
    lfsr_c[23] = lfsr_q[23] ^ lfsr_q[24] ^ lfsr_q[26] ^ lfsr_q[28] ^ lfsr_q[31] ^ lfsr_q[35] ^ lfsr_q[37] ^ lfsr_q[38] ^ lfsr_q[39] ^ lfsr_q[40] ^ lfsr_q[41] ^ lfsr_q[43] ^ lfsr_q[44] ^ lfsr_q[47] ^ lfsr_q[48] ^ lfsr_q[49] ^ lfsr_q[54] ^ lfsr_q[55] ^ lfsr_q[57] ^ lfsr_q[59] ^ lfsr_q[62];
    lfsr_c[24] = lfsr_q[24] ^ lfsr_q[25] ^ lfsr_q[27] ^ lfsr_q[29] ^ lfsr_q[32] ^ lfsr_q[36] ^ lfsr_q[38] ^ lfsr_q[39] ^ lfsr_q[40] ^ lfsr_q[41] ^ lfsr_q[42] ^ lfsr_q[44] ^ lfsr_q[45] ^ lfsr_q[48] ^ lfsr_q[49] ^ lfsr_q[50] ^ lfsr_q[55] ^ lfsr_q[56] ^ lfsr_q[58] ^ lfsr_q[60] ^ lfsr_q[63];
    lfsr_c[25] = lfsr_q[25] ^ lfsr_q[26] ^ lfsr_q[28] ^ lfsr_q[30] ^ lfsr_q[33] ^ lfsr_q[37] ^ lfsr_q[39] ^ lfsr_q[40] ^ lfsr_q[41] ^ lfsr_q[42] ^ lfsr_q[43] ^ lfsr_q[45] ^ lfsr_q[46] ^ lfsr_q[49] ^ lfsr_q[50] ^ lfsr_q[51] ^ lfsr_q[56] ^ lfsr_q[57] ^ lfsr_q[59] ^ lfsr_q[61];
    lfsr_c[26] = lfsr_q[26] ^ lfsr_q[27] ^ lfsr_q[29] ^ lfsr_q[31] ^ lfsr_q[34] ^ lfsr_q[38] ^ lfsr_q[40] ^ lfsr_q[41] ^ lfsr_q[42] ^ lfsr_q[43] ^ lfsr_q[44] ^ lfsr_q[46] ^ lfsr_q[47] ^ lfsr_q[50] ^ lfsr_q[51] ^ lfsr_q[52] ^ lfsr_q[57] ^ lfsr_q[58] ^ lfsr_q[60] ^ lfsr_q[62];
    lfsr_c[27] = lfsr_q[27] ^ lfsr_q[28] ^ lfsr_q[30] ^ lfsr_q[32] ^ lfsr_q[35] ^ lfsr_q[39] ^ lfsr_q[41] ^ lfsr_q[42] ^ lfsr_q[43] ^ lfsr_q[44] ^ lfsr_q[45] ^ lfsr_q[47] ^ lfsr_q[48] ^ lfsr_q[51] ^ lfsr_q[52] ^ lfsr_q[53] ^ lfsr_q[58] ^ lfsr_q[59] ^ lfsr_q[61] ^ lfsr_q[63];
    lfsr_c[28] = lfsr_q[28] ^ lfsr_q[29] ^ lfsr_q[31] ^ lfsr_q[33] ^ lfsr_q[36] ^ lfsr_q[40] ^ lfsr_q[42] ^ lfsr_q[43] ^ lfsr_q[44] ^ lfsr_q[45] ^ lfsr_q[46] ^ lfsr_q[48] ^ lfsr_q[49] ^ lfsr_q[52] ^ lfsr_q[53] ^ lfsr_q[54] ^ lfsr_q[59] ^ lfsr_q[60] ^ lfsr_q[62];
    lfsr_c[29] = lfsr_q[29] ^ lfsr_q[30] ^ lfsr_q[32] ^ lfsr_q[34] ^ lfsr_q[37] ^ lfsr_q[41] ^ lfsr_q[43] ^ lfsr_q[44] ^ lfsr_q[45] ^ lfsr_q[46] ^ lfsr_q[47] ^ lfsr_q[49] ^ lfsr_q[50] ^ lfsr_q[53] ^ lfsr_q[54] ^ lfsr_q[55] ^ lfsr_q[60] ^ lfsr_q[61] ^ lfsr_q[63];
    lfsr_c[30] = lfsr_q[30] ^ lfsr_q[31] ^ lfsr_q[33] ^ lfsr_q[35] ^ lfsr_q[38] ^ lfsr_q[42] ^ lfsr_q[44] ^ lfsr_q[45] ^ lfsr_q[46] ^ lfsr_q[47] ^ lfsr_q[48] ^ lfsr_q[50] ^ lfsr_q[51] ^ lfsr_q[54] ^ lfsr_q[55] ^ lfsr_q[56] ^ lfsr_q[61] ^ lfsr_q[62];
    lfsr_c[31] = lfsr_q[31] ^ lfsr_q[32] ^ lfsr_q[34] ^ lfsr_q[36] ^ lfsr_q[39] ^ lfsr_q[43] ^ lfsr_q[45] ^ lfsr_q[46] ^ lfsr_q[47] ^ lfsr_q[48] ^ lfsr_q[49] ^ lfsr_q[51] ^ lfsr_q[52] ^ lfsr_q[55] ^ lfsr_q[56] ^ lfsr_q[57] ^ lfsr_q[62] ^ lfsr_q[63];
    lfsr_c[32] = lfsr_q[32] ^ lfsr_q[33] ^ lfsr_q[35] ^ lfsr_q[37] ^ lfsr_q[40] ^ lfsr_q[44] ^ lfsr_q[46] ^ lfsr_q[47] ^ lfsr_q[48] ^ lfsr_q[49] ^ lfsr_q[50] ^ lfsr_q[52] ^ lfsr_q[53] ^ lfsr_q[56] ^ lfsr_q[57] ^ lfsr_q[58] ^ lfsr_q[63];
    lfsr_c[33] = lfsr_q[33] ^ lfsr_q[34] ^ lfsr_q[36] ^ lfsr_q[38] ^ lfsr_q[41] ^ lfsr_q[45] ^ lfsr_q[47] ^ lfsr_q[48] ^ lfsr_q[49] ^ lfsr_q[50] ^ lfsr_q[51] ^ lfsr_q[53] ^ lfsr_q[54] ^ lfsr_q[57] ^ lfsr_q[58] ^ lfsr_q[59];
    lfsr_c[34] = lfsr_q[34] ^ lfsr_q[35] ^ lfsr_q[37] ^ lfsr_q[39] ^ lfsr_q[42] ^ lfsr_q[46] ^ lfsr_q[48] ^ lfsr_q[49] ^ lfsr_q[50] ^ lfsr_q[51] ^ lfsr_q[52] ^ lfsr_q[54] ^ lfsr_q[55] ^ lfsr_q[58] ^ lfsr_q[59] ^ lfsr_q[60];
    lfsr_c[35] = lfsr_q[35] ^ lfsr_q[36] ^ lfsr_q[38] ^ lfsr_q[40] ^ lfsr_q[43] ^ lfsr_q[47] ^ lfsr_q[49] ^ lfsr_q[50] ^ lfsr_q[51] ^ lfsr_q[52] ^ lfsr_q[53] ^ lfsr_q[55] ^ lfsr_q[56] ^ lfsr_q[59] ^ lfsr_q[60] ^ lfsr_q[61];
    lfsr_c[36] = lfsr_q[36] ^ lfsr_q[37] ^ lfsr_q[39] ^ lfsr_q[41] ^ lfsr_q[44] ^ lfsr_q[48] ^ lfsr_q[50] ^ lfsr_q[51] ^ lfsr_q[52] ^ lfsr_q[53] ^ lfsr_q[54] ^ lfsr_q[56] ^ lfsr_q[57] ^ lfsr_q[60] ^ lfsr_q[61] ^ lfsr_q[62];
    lfsr_c[37] = lfsr_q[37] ^ lfsr_q[38] ^ lfsr_q[40] ^ lfsr_q[42] ^ lfsr_q[45] ^ lfsr_q[49] ^ lfsr_q[51] ^ lfsr_q[52] ^ lfsr_q[53] ^ lfsr_q[54] ^ lfsr_q[55] ^ lfsr_q[57] ^ lfsr_q[58] ^ lfsr_q[61] ^ lfsr_q[62] ^ lfsr_q[63];
    lfsr_c[38] = lfsr_q[38] ^ lfsr_q[39] ^ lfsr_q[41] ^ lfsr_q[43] ^ lfsr_q[46] ^ lfsr_q[50] ^ lfsr_q[52] ^ lfsr_q[53] ^ lfsr_q[54] ^ lfsr_q[55] ^ lfsr_q[56] ^ lfsr_q[58] ^ lfsr_q[59] ^ lfsr_q[62] ^ lfsr_q[63];
    lfsr_c[39] = lfsr_q[39] ^ lfsr_q[40] ^ lfsr_q[42] ^ lfsr_q[44] ^ lfsr_q[47] ^ lfsr_q[51] ^ lfsr_q[53] ^ lfsr_q[54] ^ lfsr_q[55] ^ lfsr_q[56] ^ lfsr_q[57] ^ lfsr_q[59] ^ lfsr_q[60] ^ lfsr_q[63];
    lfsr_c[40] = lfsr_q[40] ^ lfsr_q[41] ^ lfsr_q[43] ^ lfsr_q[45] ^ lfsr_q[48] ^ lfsr_q[52] ^ lfsr_q[54] ^ lfsr_q[55] ^ lfsr_q[56] ^ lfsr_q[57] ^ lfsr_q[58] ^ lfsr_q[60] ^ lfsr_q[61];
    lfsr_c[41] = lfsr_q[41] ^ lfsr_q[42] ^ lfsr_q[44] ^ lfsr_q[46] ^ lfsr_q[49] ^ lfsr_q[53] ^ lfsr_q[55] ^ lfsr_q[56] ^ lfsr_q[57] ^ lfsr_q[58] ^ lfsr_q[59] ^ lfsr_q[61] ^ lfsr_q[62];
    lfsr_c[42] = lfsr_q[42] ^ lfsr_q[43] ^ lfsr_q[45] ^ lfsr_q[47] ^ lfsr_q[50] ^ lfsr_q[54] ^ lfsr_q[56] ^ lfsr_q[57] ^ lfsr_q[58] ^ lfsr_q[59] ^ lfsr_q[60] ^ lfsr_q[62] ^ lfsr_q[63];
    lfsr_c[43] = lfsr_q[43] ^ lfsr_q[44] ^ lfsr_q[46] ^ lfsr_q[48] ^ lfsr_q[51] ^ lfsr_q[55] ^ lfsr_q[57] ^ lfsr_q[58] ^ lfsr_q[59] ^ lfsr_q[60] ^ lfsr_q[61] ^ lfsr_q[63];
    lfsr_c[44] = lfsr_q[44] ^ lfsr_q[45] ^ lfsr_q[47] ^ lfsr_q[49] ^ lfsr_q[52] ^ lfsr_q[56] ^ lfsr_q[58] ^ lfsr_q[59] ^ lfsr_q[60] ^ lfsr_q[61] ^ lfsr_q[62];
    lfsr_c[45] = lfsr_q[45] ^ lfsr_q[46] ^ lfsr_q[48] ^ lfsr_q[50] ^ lfsr_q[53] ^ lfsr_q[57] ^ lfsr_q[59] ^ lfsr_q[60] ^ lfsr_q[61] ^ lfsr_q[62] ^ lfsr_q[63];
    lfsr_c[46] = lfsr_q[46] ^ lfsr_q[47] ^ lfsr_q[49] ^ lfsr_q[51] ^ lfsr_q[54] ^ lfsr_q[58] ^ lfsr_q[60] ^ lfsr_q[61] ^ lfsr_q[62] ^ lfsr_q[63];
    lfsr_c[47] = lfsr_q[47] ^ lfsr_q[48] ^ lfsr_q[50] ^ lfsr_q[52] ^ lfsr_q[55] ^ lfsr_q[59] ^ lfsr_q[61] ^ lfsr_q[62] ^ lfsr_q[63];
    lfsr_c[48] = lfsr_q[48] ^ lfsr_q[49] ^ lfsr_q[51] ^ lfsr_q[53] ^ lfsr_q[56] ^ lfsr_q[60] ^ lfsr_q[62] ^ lfsr_q[63];
    lfsr_c[49] = lfsr_q[49] ^ lfsr_q[50] ^ lfsr_q[52] ^ lfsr_q[54] ^ lfsr_q[57] ^ lfsr_q[61] ^ lfsr_q[63];
    lfsr_c[50] = lfsr_q[50] ^ lfsr_q[51] ^ lfsr_q[53] ^ lfsr_q[55] ^ lfsr_q[58] ^ lfsr_q[62];
    lfsr_c[51] = lfsr_q[51] ^ lfsr_q[52] ^ lfsr_q[54] ^ lfsr_q[56] ^ lfsr_q[59] ^ lfsr_q[63];
    lfsr_c[52] = lfsr_q[52] ^ lfsr_q[53] ^ lfsr_q[55] ^ lfsr_q[57] ^ lfsr_q[60];
    lfsr_c[53] = lfsr_q[53] ^ lfsr_q[54] ^ lfsr_q[56] ^ lfsr_q[58] ^ lfsr_q[61];
    lfsr_c[54] = lfsr_q[54] ^ lfsr_q[55] ^ lfsr_q[57] ^ lfsr_q[59] ^ lfsr_q[62];
    lfsr_c[55] = lfsr_q[55] ^ lfsr_q[56] ^ lfsr_q[58] ^ lfsr_q[60] ^ lfsr_q[63];
    lfsr_c[56] = lfsr_q[56] ^ lfsr_q[57] ^ lfsr_q[59] ^ lfsr_q[61];
    lfsr_c[57] = lfsr_q[57] ^ lfsr_q[58] ^ lfsr_q[60] ^ lfsr_q[62];
    lfsr_c[58] = lfsr_q[58] ^ lfsr_q[59] ^ lfsr_q[61] ^ lfsr_q[63];
    lfsr_c[59] = lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[3] ^ lfsr_q[5] ^ lfsr_q[8] ^ lfsr_q[12] ^ lfsr_q[14] ^ lfsr_q[15] ^ lfsr_q[16] ^ lfsr_q[17] ^ lfsr_q[18] ^ lfsr_q[20] ^ lfsr_q[21] ^ lfsr_q[24] ^ lfsr_q[25] ^ lfsr_q[26] ^ lfsr_q[31] ^ lfsr_q[32] ^ lfsr_q[34] ^ lfsr_q[36] ^ lfsr_q[39] ^ lfsr_q[43] ^ lfsr_q[45] ^ lfsr_q[46] ^ lfsr_q[47] ^ lfsr_q[48] ^ lfsr_q[49] ^ lfsr_q[51] ^ lfsr_q[52] ^ lfsr_q[55] ^ lfsr_q[56] ^ lfsr_q[57] ^ lfsr_q[59] ^ lfsr_q[60] ^ lfsr_q[63];
    lfsr_c[60] = lfsr_q[0] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[8] ^ lfsr_q[9] ^ lfsr_q[12] ^ lfsr_q[13] ^ lfsr_q[14] ^ lfsr_q[19] ^ lfsr_q[20] ^ lfsr_q[22] ^ lfsr_q[24] ^ lfsr_q[27] ^ lfsr_q[31] ^ lfsr_q[33] ^ lfsr_q[34] ^ lfsr_q[35] ^ lfsr_q[36] ^ lfsr_q[37] ^ lfsr_q[39] ^ lfsr_q[40] ^ lfsr_q[43] ^ lfsr_q[44] ^ lfsr_q[45] ^ lfsr_q[50] ^ lfsr_q[51] ^ lfsr_q[53] ^ lfsr_q[55] ^ lfsr_q[58] ^ lfsr_q[60] ^ lfsr_q[61] ^ lfsr_q[62] ^ lfsr_q[63];
    lfsr_c[61] = lfsr_q[1] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[9] ^ lfsr_q[10] ^ lfsr_q[13] ^ lfsr_q[14] ^ lfsr_q[15] ^ lfsr_q[20] ^ lfsr_q[21] ^ lfsr_q[23] ^ lfsr_q[25] ^ lfsr_q[28] ^ lfsr_q[32] ^ lfsr_q[34] ^ lfsr_q[35] ^ lfsr_q[36] ^ lfsr_q[37] ^ lfsr_q[38] ^ lfsr_q[40] ^ lfsr_q[41] ^ lfsr_q[44] ^ lfsr_q[45] ^ lfsr_q[46] ^ lfsr_q[51] ^ lfsr_q[52] ^ lfsr_q[54] ^ lfsr_q[56] ^ lfsr_q[59] ^ lfsr_q[61] ^ lfsr_q[62] ^ lfsr_q[63];
    lfsr_c[62] = lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[10] ^ lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[17] ^ lfsr_q[18] ^ lfsr_q[20] ^ lfsr_q[22] ^ lfsr_q[25] ^ lfsr_q[29] ^ lfsr_q[31] ^ lfsr_q[32] ^ lfsr_q[33] ^ lfsr_q[34] ^ lfsr_q[35] ^ lfsr_q[37] ^ lfsr_q[38] ^ lfsr_q[41] ^ lfsr_q[42] ^ lfsr_q[43] ^ lfsr_q[48] ^ lfsr_q[49] ^ lfsr_q[51] ^ lfsr_q[53] ^ lfsr_q[56] ^ lfsr_q[60];
    lfsr_c[63] = lfsr_q[0] ^ lfsr_q[2] ^ lfsr_q[4] ^ lfsr_q[7] ^ lfsr_q[11] ^ lfsr_q[13] ^ lfsr_q[14] ^ lfsr_q[15] ^ lfsr_q[16] ^ lfsr_q[17] ^ lfsr_q[19] ^ lfsr_q[20] ^ lfsr_q[23] ^ lfsr_q[24] ^ lfsr_q[25] ^ lfsr_q[30] ^ lfsr_q[31] ^ lfsr_q[33] ^ lfsr_q[35] ^ lfsr_q[38] ^ lfsr_q[42] ^ lfsr_q[44] ^ lfsr_q[45] ^ lfsr_q[46] ^ lfsr_q[47] ^ lfsr_q[48] ^ lfsr_q[50] ^ lfsr_q[51] ^ lfsr_q[54] ^ lfsr_q[55] ^ lfsr_q[56] ^ lfsr_q[61] ^ lfsr_q[62] ^ lfsr_q[63];

  end // always

  always @(posedge clk, posedge rst) begin
    if(rst) begin
      lfsr_q    <= {64{1'b1}};
    end
    else begin
      lfsr_q <= en ? lfsr_c : lfsr_q;
    end
  end // always
endmodule // crc
`default_nettype wire

`default_nettype none
module gtfmac_hwchk_tx_gtfmac_if # (
   parameter AXI_IF_DEPTH = 4'd8    // Needs to match credit depth of tx_gen_buf
)
(

    input   wire            tx_axis_clk,
    input   wire            tx_axis_rst,

    input   wire            din_ena,
    input   wire            din_pre,
    input   wire            din_sop,
    input   wire [63:0]     din_data,
    input   wire [7:0]      din_last,
    input   wire            din_err,
    input   wire            din_poison,
    output  wire            tx_credit,

    input   wire            tx_axis_tready,
    output  logic           tx_axis_tvalid,

    output  logic           tx_sop,
    output  logic [63:0]    tx_axis_tdata,
    output  logic [7:0]     tx_axis_tlast,
    output  logic [7:0]     tx_axis_tpre,
    output  logic           tx_axis_terr,
    output  logic [4:0]     tx_axis_tterm,
    output  logic [1:0]     tx_axis_tsof,
    output  logic           tx_axis_tpoison,
    input   wire            tx_axis_tcan_start,
    input   wire            tx_unfout,

    output  logic           tx_start_measured_run,

    input   wire            tx_ptp_sop,
    input   wire            tx_ptp_sop_pos,

    input   wire            tx_gb_seq_start,
    output  logic           tx_gb_seq_sync,

    input   wire            ctl_tx_fcs_ins_enable,
    input   wire            ctl_tx_data_rate,
    input   wire            ctl_tx_custom_preamble_en,
    input   wire            ctl_tx_start_framing_enable,
    input   wire            ctl_tx_variable_ipg,

    output  logic           tx_buffer_overflow

);

    wire [63:0]     gen_tdata;
    wire [7:0]      gen_tlast;
    wire [7:0]      gen_tpre;
    wire            gen_terr;
    wire [4:0]      gen_tterm;
    wire [1:0]      gen_tsof;
    wire            gen_tpoison;
    wire            gen_sop;
    wire            gen_lat;

    wire            out_sop, out_lat;
    wire [63:0]     out_tdata;
    wire [7:0]      out_tlast;
    wire [7:0]      out_tpre;
    wire            out_terr;
    wire [4:0]      out_tterm;
    wire [1:0]      out_tsof;
    wire            out_tpoison;

    reg [1:0]       dm_cnt;
    reg [2:0]       eop_count;
    logic           data_valid;

    logic [2:0]     ipg, cnt;


    // Insert gaps between frames, if we are "ctl_tx_variable_ipg"
    always @(posedge tx_axis_clk) begin

        cnt    <= cnt + 1'b1;

        if (ctl_tx_variable_ipg) begin

            if (eop_count == 2'd1 && |cnt == 1'b1) begin
                ipg <= cnt;
            end
            else if (|ipg) begin
                ipg <= ipg - 1'b1;
            end

        end

        if (tx_axis_rst == 1'b1) begin
            ipg     <= 3'd0;
            cnt    <= 3'd0;
        end

    end


    // Stage outbound frames in this FIFO.  A credit is generated when the read side pops a cycle.
    wire    pop_axi_fifo;
    wire    data_fifo_empty;
    wire    axi_full;

    wire    no_rd   = data_fifo_empty || (|ipg) || ctl_tx_variable_ipg && (eop_count == 2'd1 && |cnt == 1'b1);


    assign pop_axi_fifo     = (dm_cnt == 0 || eop_count == 2'd1) && ((tx_axis_tready && data_valid && !no_rd) || !(data_valid || no_rd));
    assign tx_credit        = pop_axi_fifo;

    // Create the GTFMAC-facing signalling based on the din input.

    assign  gen_sop     = din_sop & ~ctl_tx_custom_preamble_en | din_pre & ctl_tx_custom_preamble_en;
    assign  gen_lat     = din_sop && din_data[15:0] == 16'hFACE;
    assign  gen_tdata   = din_data;
    assign  gen_tlast   = din_last;
    assign  gen_tpre    = {8{ctl_tx_custom_preamble_en & din_pre}};
    assign  gen_terr    = din_err;
    assign  gen_tterm   = 5'd0;
    assign  gen_tsof    = {1'b0, ctl_tx_start_framing_enable & din_pre};
    assign  gen_tpoison = din_poison;

    localparam  FIFO_WIDTH  =
                   1  +  // sop
                   1  +  // lat
                   64 +  // data
                   8  +  // tlast
                   8  +  // tpre
                   1  +  // terr
                   5  +  // tterm
                   1  +  // tpoison
                   2     // tsof
                   ;

    logic   [FIFO_WIDTH-1:0]    adv_spare;
    logic   [1:0]               adv_tsof;

    gtfmac_hwchk_simple_fifo #(
       .WIDTH     (FIFO_WIDTH),
       .REG       (1),
       .DEPTH     (AXI_IF_DEPTH),
       .DEPTHLOG2 (4)  // Max 15
    ) i_axi_fifo  (
       .clk               (tx_axis_clk),
       .reset             (tx_axis_rst),

       .we                (din_ena),
       .wdat              ({gen_sop, gen_lat, gen_tdata, gen_tlast, gen_tpre, gen_terr, gen_tterm, gen_tpoison, gen_tsof}),

       .re                (pop_axi_fifo),
       .rdat_unreg        ({adv_spare[FIFO_WIDTH-1:2], adv_tsof}),
       .rdat              ({out_sop, out_lat, out_tdata, out_tlast, out_tpre, out_terr, out_tterm, out_tpoison, out_tsof}),

       .full_threshold    (AXI_IF_DEPTH[4:0]),
       .a_empty_threshold (5'd0),
       .a_full_threshold  (5'd0),
       .c_threshold       (5'd0),

       .empty             (data_fifo_empty),
       .almost_empty      (),
       .almost_full       (),
       .centered          (),
       .fill_level        (),
       .full              (axi_full)
    );

    assign  tx_buffer_overflow    = axi_full & din_ena & ~pop_axi_fifo;

    logic   tready;
    assign  tready = tx_axis_tready | out_tsof[0];

    always @(posedge tx_axis_clk) begin

        if (pop_axi_fifo == 1'b1) begin
            data_valid      <= 1'b1;
            tx_axis_tvalid  <= ~adv_tsof[0];
            dm_cnt          <= (ctl_tx_data_rate) ? 2'd0 : 2'd3;
        end
        else begin

            if (|dm_cnt && tready) begin
                dm_cnt <= dm_cnt - 1'b1;
            end

            if (tready & data_valid == 1'b1 && (|dm_cnt == 1'b0 || eop_count == 2'd1) ) begin
                data_valid      <= 1'b0;
                tx_axis_tvalid  <= 1'b0;
            end

        end

        if (tx_axis_rst == 1'b1) begin
           data_valid       <= 1'b0;
           tx_axis_tvalid   <= 1'b0;
           dm_cnt           <= 2'd0;
        end
    end

    always @(posedge tx_axis_clk) begin

        if (|eop_count & tready) begin
            eop_count <= eop_count - 1'b1;
        end
        else if (ctl_tx_data_rate == 1'b0) begin

            if (tready & data_valid & |tx_axis_tlast[1:0]) begin
                eop_count   <= (ctl_tx_fcs_ins_enable) ? 2'd1 : 2'd3;
            end

        end

        if (tx_axis_rst == 1'b1) begin
            eop_count   <= 3'd0;
        end

    end

    always @ (*) begin

        tx_sop                  = (ctl_tx_data_rate || !ctl_tx_data_rate && dm_cnt == 2'd3) ? out_sop : 1'b0;
        tx_axis_tdata           = out_tdata;

        if (!ctl_tx_data_rate) begin

            tx_axis_tlast   = 8'h0;
            tx_axis_tpre    = 8'h0;

            case (dm_cnt)

                2'd3: begin
                    tx_axis_tdata[15:0]     = out_tdata[15:0];
                    tx_axis_tlast[1:0]      = out_tlast[1:0];
                    tx_axis_tpre[1:0]       = out_tpre[1:0];
                    tx_start_measured_run   = out_lat;
                end

                2'd2: begin
                    tx_axis_tdata[15:0]     = out_tdata[31:16];
                    tx_axis_tlast[1:0]      = out_tlast[3:2];
                    tx_axis_tpre[1:0]       = out_tpre[3:2];
                    tx_start_measured_run   = 1'b0;
                end

                2'd1: begin
                    tx_axis_tdata[15:0]     = out_tdata[47:32];
                    tx_axis_tlast[1:0]      = out_tlast[5:4];
                    tx_axis_tpre[1:0]       = out_tpre[5:4];
                    tx_start_measured_run   = 1'b0;
                end

                default: begin
                    tx_axis_tdata[15:0]     = out_tdata[63:48];
                    tx_axis_tlast[1:0]      = out_tlast[7:6];
                    tx_axis_tpre[1:0]       = out_tpre[7:6];
                    tx_start_measured_run   = 1'b0;
                end

            endcase

        end
        else begin

            tx_axis_tlast           = out_tlast;
            tx_axis_tpre            = out_tpre;
            tx_start_measured_run   = out_lat;

        end

    end

    always @ (*) begin

        if (ctl_tx_data_rate || dm_cnt == 2'd3) begin
            tx_axis_terr            = out_terr;
            tx_axis_tterm           = out_tterm;
            tx_axis_tsof            = out_tsof;
            tx_axis_tpoison         = out_tpoison;
        end
        else begin
            tx_axis_terr            = 1'b0;
            tx_axis_tterm           = 5'd0;
            tx_axis_tsof            = 2'd0;
            tx_axis_tpoison         = 1'b0;
        end

    end


endmodule
`default_nettype wire

`default_nettype none
module gtfmac_hwchk_rx_mon (
    //Recov: Receive packet counter for user status
    input       wire            rx_packet_count_rst,
    output      reg  [31:0]     rx_packet_count,

    // Output for debug
    output      wire            fcs_crc_bad,

    input       wire            mon_clk,
    input       wire            mon_rst,

    input       wire            ctl_hwchk_mon_en,
    input       wire            ctl_rx_data_rate,
    input       wire            ctl_rx_packet_framing_enable,
    input       wire            ctl_rx_custom_preamble_en,
    input       wire    [63:0]  ctl_hwchk_rx_custom_preamble,
    input       wire    [13:0]  ctl_hwchk_max_len,
    input       wire    [13:0]  ctl_hwchk_min_len,

    input       wire            rx_clk,
    input       wire            rx_rst,

    input       wire            rx_axis_tvalid,
    input       wire [63:0]     rx_axis_tdata,
    input       wire [7:0]      rx_axis_tlast,
    input       wire [7:0]      rx_axis_tpre,
    input       wire            rx_axis_terr,
    input       wire [4:0]      rx_axis_tterm,
    input       wire [1:0]      rx_axis_tsof,
    output      wire            rx_start_measured_run,

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

    wire                buf_ena;
    wire                buf_sop;
    wire                buf_eop;
    wire    [2:0]       buf_mty;
    wire    [63:0]      buf_data;
    wire                buf_err;
    wire                buf_empty;

    wire                parser_ena;
    wire                parser_sop;
    wire                parser_eop;
    wire    [2:0]       parser_mty;
    wire    [63:0]      parser_data;
    wire                parser_err;
    wire                parser_empty;

    wire                fcs_ena;
    wire                fcs_sop;
    wire                fcs_eop;
    wire    [2:0]       fcs_mty;
    wire    [63:0]      fcs_data;
    wire                fcs_err;
    wire                fcs_empty;
    wire                fcs_crc_val;
    //Most to module port: wire                fcs_crc_bad;
    
    wire                tsof_codeword_matched;
    wire                fcs_codeword_matched;
    wire                fcs_preamble_bad;
    wire                fcs_vlan;
    wire                fcs_broadcast;
    wire                fcs_multicast;
    wire                fcs_unicast;
    wire [63:0]     stat_hwchk_rx_unicast;
    wire [63:0]     stat_hwchk_rx_multicast;
    wire [63:0]     stat_hwchk_rx_broadcast;
    wire [63:0]     stat_hwchk_rx_bad_preamble;
    wire [63:0]     stat_hwchk_rx_good_tsof_codeword;
    wire [63:0]     stat_hwchk_rx_vlan;
    wire [63:0]     stat_hwchk_rx_total_bytes;
    wire [63:0]     stat_hwchk_rx_total_good_bytes;
    wire [63:0]     stat_hwchk_rx_total_packets;
    wire [63:0]     stat_hwchk_rx_total_good_packets;

    wire [63:0]     stat_hwchk_rx_inrangeerr;
    wire [63:0]     stat_hwchk_rx_bad_fcs;

    wire [63:0]     stat_hwchk_rx_packet_64_bytes;
    wire [63:0]     stat_hwchk_rx_packet_65_127_bytes;
    wire [63:0]     stat_hwchk_rx_packet_128_255_bytes;
    wire [63:0]     stat_hwchk_rx_packet_256_511_bytes;
    wire [63:0]     stat_hwchk_rx_packet_512_1023_bytes;
    wire [63:0]     stat_hwchk_rx_packet_1024_1518_bytes;
    wire [63:0]     stat_hwchk_rx_packet_1519_1522_bytes;
    wire [63:0]     stat_hwchk_rx_packet_1523_1548_bytes;
    wire [63:0]     stat_hwchk_rx_packet_1549_2047_bytes;
    wire [63:0]     stat_hwchk_rx_packet_2048_4095_bytes;
    wire [63:0]     stat_hwchk_rx_packet_4096_8191_bytes;
    wire [63:0]     stat_hwchk_rx_packet_8192_9215_bytes;

    wire [63:0]     stat_hwchk_rx_oversize;
    wire [63:0]     stat_hwchk_rx_undersize;
    wire [63:0]     stat_hwchk_rx_toolong;
    wire [63:0]     stat_hwchk_rx_packet_small;
    wire [63:0]     stat_hwchk_rx_packet_large;
    wire [63:0]     stat_hwchk_rx_jabber;
    wire [63:0]     stat_hwchk_rx_fragment;
    wire [63:0]     stat_hwchk_rx_packet_bad_fcs;

    wire [63:0]     stat_hwchk_rx_user_pause;
    wire [63:0]     stat_hwchk_rx_pause;


    gtfmac_hwchk_rx_gtfmac_if  i_rx_gtfmac_if  (

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
        
        .tsof_codeword_matched          (tsof_codeword_matched),    //output wire

        .stat_bad_tpre                  (),
        .stat_unexpected_tpre           (),
        .stat_missing_preamble          (),
        .stat_missed_tterm              (),
        .stat_terminate_during_preamble (),
        .stat_missed_tsof               (),
        .stat_incomplete_preamble       (),
        .stat_invalid_tterm             ()

    );

    logic   [2:0]   buf_spare;

    gtfmac_hwchk_ra_buf   # (
        .MAX_CREDITS    (0)
    )
    i_rx_mon_buf   (

        .in_clk                         (rx_clk),
        .in_rst                         (rx_rst),

        .in_bp                          (),
        .in_overflow                    (),

        .din_ena                        (gtf_ena),
        .din_pre                        (1'b0),
        .din_sop                        (gtf_sop),
        .din_eop                        (gtf_eop),
        .din_data                       (gtf_data),
        .din_last                       ({3'd0, gtf_eop, gtf_empty, gtf_mty}),
        .din_err                        (gtf_err),

        .out_clk                        (mon_clk),
        .out_rst                        (mon_rst),

        .out_credit                     (1'b0),

        .dout_ena                       (buf_ena),
        .dout_pre                       (),
        .dout_sop                       (buf_sop),
        .dout_data                      (buf_data),
        .dout_last                      ({buf_spare, buf_eop, buf_empty, buf_mty}),
        .dout_err                       (buf_err)

    );

    gtfmac_hwchk_mon_parser  i_mon_parser (

        .clk                            (mon_clk),                      // input   wire
        .rst                            (mon_rst),                      // input   wire

        .ctl_rx_custom_preamble_en      (ctl_rx_custom_preamble_en),    // input   wire
        .ctl_rx_custom_preamble         (ctl_hwchk_rx_custom_preamble),   // input   wire
        
        .tsof_codeword_matched          (tsof_codeword_matched),        // input   wire

        .din_ena                        (buf_ena),                      // input   logic
        .din_sop                        (buf_sop),                      // input   logic
        .din_data                       (buf_data),                     // input   logic  [63:0]
        .din_eop                        (buf_eop),                      // input   logic
        .din_mty                        (buf_mty),                      // input   logic  [2:0]
        .din_err                        (buf_err),                      // input   logic
        .din_empty                      (buf_empty),                    // input   logic

        .dout_ena                       (parser_ena),                   // output  logic
        .dout_sop                       (parser_sop),                   // output  logic
        .dout_data                      (parser_data),                  // output  logic  [63:0]
        .dout_eop                       (parser_eop),                   // output  logic
        .dout_mty                       (parser_mty),                   // output  logic  [2:0]
        .dout_err                       (parser_err),                   // output  logic
        .dout_empty                     (parser_empty),                 // output  logic
    
        .dout_dly_codeword_matched      (fcs_codeword_matched),         // output  logic
        .dout_dly_preamble_bad          (fcs_preamble_bad),             // output  logic
        .dout_dly_vlan                  (fcs_vlan),                     // output  logic
        .dout_dly_broadcast             (fcs_broadcast),                // output  logic
        .dout_dly_multicast             (fcs_multicast),                // output  logic
        .dout_dly_unicast               (fcs_unicast)                   // output  logic

    );


    // This logic has a latency of three cycles (d3)
    gtfmac_hwchk_tx_fcs  i_rx_fcs  (

        .clk                    (mon_clk),
        .reset                  (~mon_rst),

        .ctl_tx_add_fcs         (1'b0),
        .ctl_tx_ignore_fcs      (1'b0),

        .i_ena_passthrough      (1'b1),
        .i_ena                  (parser_ena),
        .i_sop                  (parser_sop),
        .i_dat                  ({  parser_data[7:0],
                                    parser_data[15:8],
                                    parser_data[23:16],
                                    parser_data[31:24],
                                    parser_data[39:32],
                                    parser_data[47:40],
                                    parser_data[55:48],
                                    parser_data[63:56]
                                }), // [64-1:0]
        .i_eop                  (parser_eop),
        .i_mty                  (parser_mty), // [3-1:0]
        .i_err                  (parser_err),
        .i_is_ctrl              (parser_empty),

        .o_ena_passthrough      (),
        .o_ena                  (fcs_ena),
        .o_sop                  (fcs_sop),
        .o_dat                  ({  fcs_data[7:0],
                                    fcs_data[15:8],
                                    fcs_data[23:16],
                                    fcs_data[31:24],
                                    fcs_data[39:32],
                                    fcs_data[47:40],
                                    fcs_data[55:48],
                                    fcs_data[63:56]
                                }), // [64-1:0]
        .o_eop                  (fcs_eop),
        .o_mty                  (fcs_mty), // [3-1:0]
        .o_err                  (fcs_err),
        .o_is_ctrl              (fcs_empty),

        .o_crc_val              (fcs_crc_val),
        .o_crc                  (), // [31:0]
        .o_crc_bad              (fcs_crc_bad),
        .o_crc_err              (),
        .o_crc_stomped          ()
    );

    logic stat_incr;
    logic frame_active;
    logic stat_total_packets_incr;

    always @(posedge mon_clk) begin

        stat_incr       <= 1'b0;

        if (frame_active) begin

            if (fcs_ena) begin
                if (fcs_eop) begin
                    frame_active    <= 1'b0;
                    stat_incr       <= 1'b1;
                end
            end

        end
        else begin

            if (fcs_ena && fcs_empty) begin
                stat_incr       <= 1'b1;
            end
            else if (fcs_ena && fcs_sop) begin
                frame_active        <= 1'b1;
            end

        end

        if (mon_rst) begin
            frame_active        <= 1'b0;
            stat_incr           <= 1'b0;
        end

    end

    // We won't reset these incr signals, because the stat_collector
    // requires a 'tick' before the stats start being collected.
    always @(posedge mon_clk) begin

        stat_total_packets_incr          <= 1'b0;

        if (stat_incr) begin

            stat_total_packets_incr          <= 1'b1;
                            
        end

    end

    //Recov: Receive packet counter for user status
    always@(posedge mon_clk)
    begin
        if (mon_rst)
            rx_packet_count <= 'h0;
        else if (rx_packet_count_rst)
            rx_packet_count <= 'h0;
        else if (stat_total_packets_incr)
            rx_packet_count <= rx_packet_count + 1;
    end

endmodule
`default_nettype wire

`default_nettype none
module gtfmac_hwchk_mon_parser (

    input   wire            clk,
    input   wire            rst,

    input   wire            ctl_rx_custom_preamble_en,
    input   wire   [63:0]   ctl_rx_custom_preamble,
    input   wire            tsof_codeword_matched,

    input   wire           din_ena,
    input   wire           din_sop,
    input   wire  [63:0]   din_data,
    input   wire           din_eop,
    input   wire  [2:0]    din_mty,
    input   wire           din_err,
    input   wire           din_empty,

    output  logic           dout_ena,
    output  logic           dout_sop,
    output  logic  [63:0]   dout_data,
    output  logic           dout_eop,
    output  logic  [2:0]    dout_mty,
    output  logic           dout_err,
    output  logic           dout_empty,
    
    output  logic           dout_dly_codeword_matched,
    output  logic           dout_dly_preamble_bad,
    output  logic           dout_dly_vlan,
    output  logic           dout_dly_broadcast,
    output  logic           dout_dly_multicast,
    output  logic           dout_dly_unicast

);

    logic           strip_preamble;
    logic           preamble_bad;
    logic           check_vlan;

    logic           broadcast;
    logic           multicast;
    logic           unicast;
    logic           vlan;
    
    logic   [3:0]   dly_codeword_matched;
    logic   [3:0]   dly_preamble_bad;
    logic   [3:0]   dly_vlan;
    logic   [3:0]   dly_broadcast;
    logic   [3:0]   dly_multicast;
    logic   [3:0]   dly_unicast;


    assign  dout_dly_codeword_matched   = dly_codeword_matched[3];
    assign  dout_dly_preamble_bad       = dly_preamble_bad[3];
    assign  dout_dly_vlan               = dly_vlan[1];
    assign  dout_dly_broadcast          = dly_broadcast[2];
    assign  dout_dly_multicast          = dly_multicast[2];
    assign  dout_dly_unicast            = dly_unicast[2];


    always @(posedge clk) begin

        dout_ena        <= din_ena;
        dout_sop        <= din_sop;
        dout_data       <= din_data;
        dout_eop        <= din_eop;
        dout_mty        <= din_mty;
        dout_err        <= din_err;
        dout_empty      <= din_empty;

        if (din_ena && din_sop) begin

            broadcast   <= 1'b0;
            multicast   <= 1'b0;
            unicast     <= 1'b0;
            vlan        <= 1'b0;

            if (ctl_rx_custom_preamble_en) begin
                dout_ena        <= 1'b0;
                dout_sop        <= 1'b0;
                strip_preamble  <= 1'b1;
                preamble_bad    <= (din_data[63:8] != ctl_rx_custom_preamble[63:8]) ? 1'b1 : 1'b0;
            end
            else begin
                preamble_bad    <= 1'b0;
                check_vlan      <= 1'b1;

                if (&din_data[47:0]) begin
                    broadcast       <= 1'b1;
                end
                else if (din_data[0]) begin
                    multicast       <= 1'b1;
                end
                else begin
                    unicast         <= 1'b1;
                end
            end
        end
        else if (din_ena && strip_preamble) begin
            dout_sop        <= 1'b1;
            strip_preamble  <= 1'b0;
            check_vlan      <= 1'b1;
            if (&din_data[47:0]) begin
                broadcast       <= 1'b1;
            end
            else if (din_data[0]) begin
                multicast       <= 1'b1;
            end
            else begin
                unicast         <= 1'b1;
            end
        end
        else if (din_ena && check_vlan) begin
            vlan    <= (din_data[47:32] == 16'h0081) ? 1'b1 : 1'b0;
        end

        if (rst) begin

            strip_preamble  <= 1'b0;
            dout_ena        <= 1'b0;
            dout_sop        <= 1'b0;
            dout_eop        <= 1'b0;
            dout_mty        <= 3'd0;
            dout_err        <= 1'b0;
            dout_empty      <= 1'b0;

            preamble_bad    <= 1'b0;
            vlan            <= 1'b0;
            broadcast       <= 1'b0;
            multicast       <= 1'b0;
            unicast         <= 1'b0;

        end

    end


    always @(posedge clk) begin

        dly_codeword_matched <= {dly_codeword_matched[2:0], tsof_codeword_matched};
        dly_preamble_bad     <= {dly_preamble_bad[2:0], preamble_bad};
        dly_vlan             <= {dly_vlan[2:0], vlan};
        dly_broadcast        <= {dly_broadcast[2:0], broadcast};
        dly_multicast        <= {dly_multicast[2:0], multicast};
        dly_unicast          <= {dly_unicast[2:0], unicast};

        if (rst) begin
            dly_codeword_matched <= 'd0;
            dly_preamble_bad     <= 'd0;
            dly_vlan             <= 'd0;
            dly_broadcast        <= 'd0;
            dly_multicast        <= 'd0;
            dly_unicast          <= 'd0;
        end

    end


endmodule
`default_nettype wire

`default_nettype none
module gtfmac_hwchk_rx_gtfmac_if (

    input   wire            rx_axis_clk,
    input   wire            rx_axis_rst,

    input   wire            ctl_rx_data_rate,
    input   wire            ctl_rx_custom_preamble_en,

    input   wire            rx_axis_tvalid,
    input   wire   [63:0]   rx_axis_tdata,
    input   wire   [7:0]    rx_axis_tlast,
    input   wire   [7:0]    rx_axis_tpre,
    input   wire            rx_axis_terr,
    input   wire   [4:0]    rx_axis_tterm,
    input   wire   [1:0]    rx_axis_tsof,


    output  logic           dout_ena,
    output  logic           dout_sop,
    output  logic  [63:0]   dout_data,
    output  logic           dout_eop,
    output  logic  [2:0]    dout_mty,
    output  logic           dout_err,
    output  logic           dout_empty,
    output  logic           rx_start_measured_run,
    
    output  logic           tsof_codeword_matched,

    output  logic           stat_bad_tpre,
    output  logic           stat_unexpected_tpre,
    output  logic           stat_missing_preamble,
    output  logic           stat_missed_tterm,
    output  logic           stat_terminate_during_preamble,
    output  logic           stat_missed_tsof,
    output  logic           stat_incomplete_preamble,
    output  logic           stat_invalid_tterm


);


    logic   [1:0]   cycle_cnt;
    logic           frame_active;
    logic           collect_preamble;
    logic           late_eop;
    logic           new_frame;
    logic           flush;
    

    logic           ena, hold_ena;
    logic           sop, hold_sop;
    logic           get_da;
    logic  [63:0]   data, hold_data;
    logic           eop, hold_eop;
    logic           err, hold_err;
    logic  [2:0]    mty, hold_mty;
    logic           delayed_empty, empty, hold_empty;
    logic  [4:0]    tterm;
    logic  [4:0]    err_cnt;

    logic           q_rx_axis_tvalid;
    logic  [63:0]   q_rx_axis_tdata;
    logic  [7:0]    q_rx_axis_tlast;
    logic  [7:0]    q_rx_axis_tpre;
    logic           q_rx_axis_terr;
    logic  [4:0]    q_rx_axis_tterm;
    logic  [1:0]    q_rx_axis_tsof;
    
    logic  [7:0]    expected_cw;// capture expected cw based on prev sof value
    logic  [7:0]    q_rx_axis_tpre_d;
    
    
    always @(posedge rx_axis_clk) begin 
        if (rx_axis_rst == 1'b1) begin
            tsof_codeword_matched <= 1'b0;
        end
        else begin
            q_rx_axis_tpre_d <= q_rx_axis_tvalid ? q_rx_axis_tpre : q_rx_axis_tpre_d;
            if (ctl_rx_custom_preamble_en) begin
                if (q_rx_axis_tsof == 2'd2) begin
                    tsof_codeword_matched <= (q_rx_axis_tdata [7:0] == 8'h78);
                    expected_cw           <= 8'h78;
                end  
                else if (q_rx_axis_tsof == 2'd3) begin
                    tsof_codeword_matched <= (q_rx_axis_tdata [7:0] == 8'h33);
                    expected_cw           <= 8'h33;
                end
                else if (|q_rx_axis_tpre && !(|q_rx_axis_tpre_d)) begin
                    tsof_codeword_matched <= (q_rx_axis_tdata [7:0] == expected_cw);
                end
            end
            else
                tsof_codeword_matched <= 1'b1;

        end
    end

    always @(posedge rx_axis_clk) begin

        ena                 <= 1'b0;
        sop                 <= 1'b0;
        eop                 <= 1'b0;
        err                 <= 1'b0;
        mty                 <= 3'd0;
        late_eop            <= 1'b0;
        delayed_empty       <= 1'b0;
        empty               <= 1'b0;
        flush               <= 1'b0;

        q_rx_axis_tvalid    <= rx_axis_tvalid;
        q_rx_axis_tdata     <= rx_axis_tdata;
        q_rx_axis_tlast     <= rx_axis_tlast;
        q_rx_axis_tpre      <= rx_axis_tpre;
        q_rx_axis_terr      <= rx_axis_terr;
        q_rx_axis_tterm     <= rx_axis_tterm;
        q_rx_axis_tsof      <= rx_axis_tsof;

        stat_bad_tpre                   <= 1'b0;
        stat_unexpected_tpre            <= 1'b0;
        stat_missing_preamble           <= 1'b0;
        stat_missed_tterm               <= 1'b0;
        stat_terminate_during_preamble  <= 1'b0;
        stat_missed_tsof                <= 1'b0;
        stat_incomplete_preamble        <= 1'b0;
        stat_invalid_tterm              <= 1'b0;

        if (frame_active == 1'b0) begin

            cycle_cnt           <= 2'd0;
            collect_preamble    <= 1'b0;
            new_frame           <= 1'b0;

            if (q_rx_axis_tsof[1]) begin

                frame_active    <= 1'b1;
                flush           <= |err_cnt;
                err_cnt         <= 5'd0;

                if (ctl_rx_data_rate && q_rx_axis_tterm == 5'h18) begin
                    tterm           <= 5'h18;
                    delayed_empty   <= 1'b1;
                end

                if (|q_rx_axis_tpre) begin
                    data    <= q_rx_axis_tdata;
                    if (!ctl_rx_data_rate) begin
                        collect_preamble    <= 1'b1;
                        cycle_cnt           <= 2'd1;
                        new_frame           <= 1'b1;
                    end
                    else begin
                        ena                 <= 1'b1;
                        sop                 <= 1'b1;
                    end
                end
                else begin
                    new_frame   <= 1'b1;
                end

            end // q_rx_axis_tsof[1]
            else if (err_cnt == 5'd1 || q_rx_axis_terr) begin
                flush       <= 1'b1;
                err         <= q_rx_axis_terr;
                err_cnt     <= 5'd0;
            end
            else begin
                err_cnt     <= (|err_cnt) ? err_cnt - 1'b1 : 5'd0;
            end


        end
        else begin  // frame_active == 1

            if (ctl_rx_data_rate) begin // 25G

                err         <= q_rx_axis_terr;
                data        <= q_rx_axis_tdata;

                // Capture tterm for future integrity check
                if (!tterm[4]) begin
                    tterm       <= q_rx_axis_tterm;
                end

                if (q_rx_axis_tlast[0] || new_frame && q_rx_axis_tterm == 5'h10 || delayed_empty) begin

                    new_frame       <= 1'b0;
                    frame_active    <= 1'b0;
                    err_cnt         <= 5'd2;
                    
                    if (new_frame) begin
                        ena             <= 1'b1;
                        sop             <= 1'b1;
                        eop             <= 1'b1;
                        empty           <= 1'b1;
                    end
                    else begin
                        late_eop        <= 1'b1;
                    end

                end
                else if (q_rx_axis_tvalid) begin

                    new_frame       <= 1'b0;
                    ena             <= 1'b1;
                    sop             <= new_frame;

                    if (|q_rx_axis_tlast) begin

                        eop             <= 1'b1;
                        frame_active    <= 1'b0;
                        err_cnt         <= 5'd2;

                        case (q_rx_axis_tlast)

                            8'b0000_0010: begin mty         <= 3'd7; end
                            8'b0000_0100: begin mty         <= 3'd6; end
                            8'b0000_1000: begin mty         <= 3'd5; end
                            8'b0001_0000: begin mty         <= 3'd4; end
                            8'b0010_0000: begin mty         <= 3'd3; end
                            8'b0100_0000: begin mty         <= 3'd2; end
                            8'b1000_0000: begin mty         <= 3'd1; end
                            default:      begin mty         <= 3'd0; end

                        endcase

                    end

                end // if (q_rx_axis_tvalid)

            end
            else begin  // 10G

                err <= err | q_rx_axis_terr;

                // Capture tterm for future integrity check
                if (!tterm[4]) begin
                    tterm       <= q_rx_axis_tterm;
                end

                case (cycle_cnt)

                    2'd0: begin
                        data <= {48'd0, q_rx_axis_tdata[15:0]};
                    end
                    2'd1: begin
                        data[31:16] <= q_rx_axis_tdata[15:0];
                    end
                    2'd2: begin
                        data[47:32] <= q_rx_axis_tdata[15:0];
                    end
                    default: begin
                        data[63:48] <= q_rx_axis_tdata[15:0];
                    end

                endcase

                if (|q_rx_axis_tpre || q_rx_axis_tvalid) begin
                    cycle_cnt   <= cycle_cnt + 1'b1;
                end

                if (new_frame && q_rx_axis_tterm[4] == 1'b1) begin

                    new_frame       <= 1'b0;
                    frame_active    <= 1'b0;
                    err_cnt         <= 5'd9;

                    ena             <= 1'b1;
                    sop             <= 1'b1;
                    eop             <= 1'b1;
                    empty           <= 1'b1;

                end
                else if (|q_rx_axis_tlast[1:0] || (|q_rx_axis_tpre || q_rx_axis_tvalid) && cycle_cnt == 2'd3) begin

                    ena                 <= 1'b1;
                    sop                 <= new_frame;
                    new_frame           <= 1'b0;
                    collect_preamble    <= 1'b0;

                    if (|q_rx_axis_tlast[1:0]) begin

                        frame_active    <= 1'b0;
                        err_cnt         <= 5'd9;
                        
                        ///////////////// Start of simultaneous eop/sop 
                        if (q_rx_axis_tsof[1]) begin
                            cycle_cnt           <= 2'd0;
                            collect_preamble    <= 1'b0;
                            new_frame           <= 1'b0;
    
                            frame_active    <= 1'b1;
                            flush           <= |err_cnt;
                            err_cnt         <= 5'd0;
    
                            if (ctl_rx_data_rate && q_rx_axis_tterm == 5'h18) begin
                                tterm           <= 5'h18;
                                delayed_empty   <= 1'b1;
                            end
            
                            if (|q_rx_axis_tpre) begin
                                data    <= q_rx_axis_tdata;
                                if (!ctl_rx_data_rate) begin
                                    collect_preamble    <= 1'b1;
                                    cycle_cnt           <= 2'd1;
                                    new_frame           <= 1'b1;
                                end
                                else begin
                                    ena                 <= 1'b1;
                                    sop                 <= 1'b1;
                                end
                            end
                            else begin
                                new_frame   <= 1'b1;
                            end
            
                        end 
                        ///////////////// End of simultaneous eop/sop 

                        if (q_rx_axis_tlast[0] && cycle_cnt == 2'd0) begin
                            late_eop    <= 1'b1;
                            ena         <= 1'b0;
                        end
                        else begin
                            eop         <= 1'b1;
                        end

                        case (cycle_cnt)

                            2'd0: begin
                                mty <= (q_rx_axis_tlast[0]) ? 3'd0 : 3'd7;    // late eop
                            end
                            2'd1: begin
                                mty <= (q_rx_axis_tlast[0]) ? 3'd6 : 3'd5;
                            end
                            2'd2: begin
                                mty <= (q_rx_axis_tlast[0]) ? 3'd4 : 3'd3;
                            end
                            default: begin
                                mty <= (q_rx_axis_tlast[0]) ? 3'd2 : 3'd1;
                            end

                        endcase

                    end

                end

            end

        end


        if (rx_axis_rst == 1'b1) begin

            q_rx_axis_tvalid    <= 1'b0;

            ena                 <= 1'b0;
            sop                 <= 1'b0;
            eop                 <= 1'b0;
            err                 <= 1'b0;
            mty                 <= 3'd0;
            late_eop            <= 1'b0;
            empty               <= 1'b0;
            delayed_empty       <= 1'b0;

            cycle_cnt           <= 2'd0;
            collect_preamble    <= 1'b0;
            new_frame           <= 1'b0;
            frame_active        <= 1'b0;
            flush               <= 1'b0;
            err_cnt             <= 5'd0;
            

            stat_bad_tpre                   <= 1'b0;
            stat_unexpected_tpre            <= 1'b0;
            stat_missing_preamble           <= 1'b0;
            stat_missed_tterm               <= 1'b0;
            stat_terminate_during_preamble  <= 1'b0;
            stat_missed_tsof                <= 1'b0;
            stat_incomplete_preamble        <= 1'b0;
            stat_invalid_tterm              <= 1'b0;

        end

    end


    always @(posedge rx_axis_clk) begin

        dout_ena                <= 1'b0;
        dout_sop                <= 1'b0;
        dout_data               <= 1'b0;
        dout_eop                <= 1'b0;
        dout_mty                <= 1'b0;
        dout_err                <= 1'b0;
        dout_empty              <= 1'b0;
        rx_start_measured_run   <= 1'b0;

        begin

            if (ena || flush) begin

                hold_ena    <= ena;
                hold_sop    <= sop;
                get_da      <= hold_sop;
                hold_data   <= data;
                hold_eop    <= eop;
                hold_mty    <= mty;
                hold_err    <= err;
                hold_empty  <= empty;

            end
            else if (late_eop) begin
                hold_eop    <= 1'b1;
                hold_err    <= hold_err | err;
            end

            // If we are holding and new data comes in, or a flush, push out to to the datapath
            if (hold_ena && ena || flush) begin

                dout_ena                <= hold_ena;
                dout_sop                <= hold_sop;
                dout_data               <= hold_data;
                dout_eop                <= hold_eop | late_eop;
                dout_mty                <= hold_mty;
                dout_err                <= hold_err | err;
                dout_empty              <= hold_empty;

                // Signal to the latency measurement logic whether to begin a 'run'.  If we have
                // custom_preamble enabled, then SOP will be the preamble and we want to wait for the DA.
                // If not, then SOP will be the DA and we start the run.
                rx_start_measured_run   <= (hold_data[15:0] == 16'hFACE) ? (hold_sop & ~ctl_rx_custom_preamble_en | get_da & ctl_rx_custom_preamble_en) : 1'b0;

            end

        end

        if (rx_axis_rst == 1'b1) begin
            dout_ena                <= 1'b0;
            dout_sop                <= 1'b0;
            dout_eop                <= 1'b0;
            dout_mty                <= 1'b0;
            dout_err                <= 1'b0;
            dout_empty              <= 1'b0;

            rx_start_measured_run   <= 1'b0;
            get_da                  <= 1'b0;

            hold_ena                <= 1'b0;
            hold_sop                <= 1'b0;
            hold_eop                <= 1'b0;
            hold_mty                <= 1'b0;
            hold_err                <= 1'b0;
            hold_empty              <= 1'b0;
        end


    end


endmodule
`default_nettype wire

// ***************************************************************************
// Misc control and status registers
// ***************************************************************************

`default_nettype none
module gtfmac_hwchk_hwchk_pif (
    //Recov: Receive packet counter for user status
    output  reg             rx_packet_count_rst     ,
    input   wire [31:0]     rx_packet_count         ,
    input   wire            fifo_tx_fcs_error        ,
    input   wire            ctl_hwchk_frm_gen_en_in , 
    input   wire            ctl_hwchk_mon_en_in     ,

    output  reg             fifo_rst_status         ,
    input   wire [31:0]     fifo_rd_err_count       ,
    input   wire [31:0]     fifo_rx_wr_count        ,
    input   wire            fifo_rx_err_overflow    ,
    input   wire            fifo_rx_err_underflow   ,
    input   wire [31:0]     fifo_tx_wr_count        ,
    input   wire            fifo_tx_err_overflow    ,
    input   wire            fifo_tx_err_underflow   ,


    // ============================================================
    // AXI Ports : BEGIN
    // ============================================================

    // AXI Globals
    input   wire             axi_aclk,
    input   wire             axi_aresetn,

    // AXI: Read Address Channel
    input   wire    [31:0]  axil_araddr,
    input   wire            axil_arvalid,
    output  reg             axil_arready,

    // Read Data Channel
    output  reg     [31:0]  axil_rdata,
    output  wire    [1:0]   axil_rresp,
    output  reg             axil_rvalid,
    input   wire            axil_rready,

    // Write Address Channel
    input   wire    [31:0]  axil_awaddr,
    input   wire            axil_awvalid,
    output  reg             axil_awready,

    // Write Data Channel
    input   wire    [31:0]  axil_wdata,
    input   wire            axil_wvalid,
    output  reg             axil_wready,

    // Write Response Channel
    output  reg             axil_bvalid,
    output  wire    [1:0]   axil_bresp,
    input   wire            axil_bready,

    // ============================================================
    // AXI Ports : END
    // ============================================================

    // Clock counters

    input       wire [31:0]    tx_clk_cps,
    input       wire [31:0]    rx_clk_cps,
    input       wire [31:0]    axi_aclk_cps,
    input       wire [31:0]    gen_clk_cps,
    input       wire [31:0]    mon_clk_cps,
    input       wire [31:0]    lat_clk_cps,

    // Debug resets
    output      logic           hwchk_gtf_ch_gttxreset,
    output      logic           hwchk_gtf_ch_txpmareset,
    output      logic           hwchk_gtf_ch_txpcsreset,
    output      logic           hwchk_gtf_ch_gtrxreset,
    output      logic           hwchk_gtf_ch_rxpmareset,
    output      logic           hwchk_gtf_ch_rxdfelpmreset,
    output      logic           hwchk_gtf_ch_eyescanreset,
    output      logic           hwchk_gtf_ch_rxpcsreset,
    output      logic           hwchk_gtf_cm_qpll0reset,

    output      logic           hwchk_gtf_ch_txuserrdy,
    output      logic           hwchk_gtf_ch_rxuserrdy,

    output      logic           gtwiz_reset_tx_pll_and_datapath_in,
    output      logic           gtwiz_reset_tx_datapath_in,
    output      logic           gtwiz_reset_rx_pll_and_datapath_in,
    output      logic           gtwiz_reset_rx_datapath_in,

    // GTFMAC Status
    input       wire           stat_gtf_tx_rst,
    input       wire           stat_gtf_rx_rst,
    input       wire           stat_gtf_block_lock,
    // Bitslip correction
    output      logic           ctl_gb_seq_sync,
    output      logic           ctl_disable_bitslip,
    output      logic           ctl_correct_bitslip,
    input       wire   [6:0]   stat_bitslip_cnt,
    input       wire   [6:0]   stat_bitslip_issued,
    input       wire           stat_excessive_bitslip,
    input       wire           stat_bitslip_locked,
    input       wire           stat_bitslip_busy,
    input       wire           stat_bitslip_done,

    // Generator
    output      logic           ctl_hwchk_frm_gen_en,
    output      logic           ctl_hwchk_frm_gen_mode,
    output      logic   [13:0]  ctl_hwchk_max_len,
    output      logic   [13:0]  ctl_hwchk_min_len,
    output      logic   [31:0]  ctl_num_frames,
    input       wire           ack_frm_gen_done,

    output      logic           ctl_tx_start_framing_enable,
    output      logic           ctl_tx_custom_preamble_en,
    output      logic   [63:0]  ctl_hwchk_tx_custom_preamble,
    output      logic           ctl_tx_variable_ipg,

    output      logic           ctl_tx_fcs_ins_enable,
    output      logic           ctl_tx_data_rate,

    output      logic           ctl_hwchk_tx_inj_err,
    input       wire            ack_hwchk_tx_inj_err,
    
    output      logic           ctl_hwchk_tx_inj_poison, 
    input       wire            ack_hwchk_tx_inj_poison, 

    output      logic           ctl_hwchk_tx_inj_pause,
    output      logic   [47:0]  ctl_hwchk_tx_inj_pause_sa,
    output      logic   [47:0]  ctl_hwchk_tx_inj_pause_da,
    output      logic   [15:0]  ctl_hwchk_tx_inj_pause_ethtype,
    output      logic   [15:0]  ctl_hwchk_tx_inj_pause_opcode,
    output      logic   [15:0]  ctl_hwchk_tx_inj_pause_timer_ce,
    output      logic   [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc0,
    output      logic   [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc1,
    output      logic   [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc2,
    output      logic   [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc3,
    output      logic   [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc4,
    output      logic   [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc5,
    output      logic   [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc6,
    output      logic   [15:0]  ctl_hwchk_tx_inj_pause_timer_pfc7,
    input       wire            ack_hwchk_tx_inj_pause,

    // Monitor
    output      logic           ctl_hwchk_mon_en,
    output      logic           ctl_rx_data_rate,
    output      logic           ctl_rx_packet_framing_enable,
    output      logic           ctl_rx_custom_preamble_en,
    output      logic   [63:0]  ctl_hwchk_rx_custom_preamble,

    // hwchk Statistics
    output      logic           stat_tick,

    // Latency run controls
    output      logic           ctl_hwchk_tx_start_lat_run,
    input       wire            ack_hwchk_tx_start_lat_run


);

//
//Recov: Assert frm_gen_en and ctl_hwchk_mon_en from a common source, to start all channels simultaneously...
//
    // NOTE gtfmac_hwchk_syncer_level's reset is ACTIVE LOW
    
    wire ctl_hwchk_frm_gen_en_sync;
    gtfmac_hwchk_syncer_level i_ctl_hwchk_frm_gen_en_sync (
        .clk     ( axi_aclk                    ),
        .reset   ( axi_aresetn                 ),
                    
        .datain  ( ctl_hwchk_frm_gen_en_in     ),
        .dataout ( ctl_hwchk_frm_gen_en_sync   )
    );
    
    reg ctl_hwchk_frm_gen_en_0;
    reg ctl_hwchk_frm_gen_en_1;
    always@(posedge axi_aclk)
    begin
        if (!axi_aresetn) begin
            ctl_hwchk_frm_gen_en_0 <= 'h0;
            ctl_hwchk_frm_gen_en_1 <= 'h0;
        end else begin
            ctl_hwchk_frm_gen_en_0 <= ctl_hwchk_frm_gen_en_sync ;
            ctl_hwchk_frm_gen_en_1 <= ctl_hwchk_frm_gen_en_0 ;
        end
    end  
    
    always@(posedge axi_aclk)
    begin
        if (!axi_aresetn)
            ctl_hwchk_frm_gen_en <= 'h0;
        else if (!ctl_hwchk_frm_gen_en_1 &&  ctl_hwchk_frm_gen_en_0)
            ctl_hwchk_frm_gen_en <= 'h1;
        else if ( ctl_hwchk_frm_gen_en_1 && !ctl_hwchk_frm_gen_en_0)
            ctl_hwchk_frm_gen_en <= 'h0;
        else if (ack_frm_gen_done)
            ctl_hwchk_frm_gen_en <= 'h0;
    end  
    
    wire ctl_hwchk_mon_en_sync;
    gtfmac_hwchk_syncer_level i_ctl_hwchk_mon_en_sync (
        .clk     ( axi_aclk                    ),
        .reset   ( ~axi_aresetn                ),
                    
        .datain  ( ctl_hwchk_mon_en_in         ),
        .dataout ( ctl_hwchk_mon_en_sync       )
    );
    
    always@(posedge axi_aclk)
    begin
        if (!axi_aresetn)
            ctl_hwchk_mon_en <= 'h0;
        else
            ctl_hwchk_mon_en <= ctl_hwchk_mon_en_sync;
    end
  
//
//
//

    reg             axil_bvalid_next;
    reg     [2:0]   wr_state, wr_state_next;
    reg             do_write, do_write_next;
    reg     [11:0]  wr_addr, wr_addr_next;
    reg     [31:0]  wr_data, wr_data_next;
    reg             axil_awready_next;
    reg             axil_wready_next;
    reg             axil_arready_next, axil_arvalid_next, axil_rvalid_next;
    reg     [31:0]  rdata;
    reg     [31:0]  axil_rdata_next;
    reg     [11:0]  rd_addr, rd_addr_next;
    reg     [2:0]   rd_state, rd_state_next;
    reg             do_rd, do_rd_next;

    // Write Data - State Machine
    localparam      WR_IDLE_STATE               = 3'd0,
                    WR_GET_ADDR_STATE           = 3'd1,
                    WR_GET_DATA_STATE           = 3'd2,
                    WR_SET_DATA_STATE           = 3'd3,
                    WR_WAIT_FOR_BVALID_STATE    = 3'd4;

    localparam      RD_IDLE_STATE               = 3'd0,
                    RD_STATE                    = 3'd1,
                    RD_ACK_STATE                = 3'd2,
                    RD_FIFO_STATE               = 3'd3;


    assign axil_bresp = 2'd0; // Tie to 'OKAY'.
    assign axil_rresp = 2'd0; // Tie to 'Okay;.

    assign ctl_tx_data_rate = 1'b0;
    assign ctl_rx_data_rate = 1'b0;
    // -----------------------------------------------------------------
    // Determine next state of write FSM - combinatorial logic
    // -----------------------------------------------------------------
    always_comb begin: COMB_LOGIC_WRITE_FSM_NEXT_STATE

        // Defaults.
        wr_state_next           = wr_state;
        wr_addr_next            = wr_addr;
        wr_data_next            = wr_data;
        do_write_next           = 1'b0;
        axil_awready_next       = 1'b0;
        axil_wready_next        = 1'b0;
        axil_bvalid_next        = 1'b0;

        case (wr_state)
            WR_IDLE_STATE: begin

                axil_awready_next = 1'b1;
                axil_wready_next = 1'b1;

                case ({axil_awvalid & axil_awready, axil_wvalid & axil_wready})

                    2'b10: begin // Have address, so get data
                        wr_state_next       = WR_GET_DATA_STATE;
                        wr_addr_next        = axil_awaddr[11:0];
                        axil_awready_next   = 1'b0;
                    end

                    2'b01: begin // Have data, get address
                        wr_state_next       = WR_GET_ADDR_STATE;
                        wr_data_next        = axil_wdata;
                        axil_wready_next    = 1'b0;
                    end

                    2'b11: begin // Have both..
                        wr_state_next       = WR_SET_DATA_STATE;
                        wr_addr_next        = axil_awaddr[11:0];
                        wr_data_next        = axil_wdata;
                        axil_wready_next    = 1'b0;
                    end

                    2'b00: begin // Have nothing!
                        // Do nothing. Just wait.
                        wr_state_next = WR_IDLE_STATE;
                    end
                endcase
            end // WR_IDLE_STATE

            WR_GET_ADDR_STATE: begin

                // If we're here, it's implied that (axil_wvalid
                // & axil_wready) == 1'b1 on the previous aclk rising edge.

                axil_awready_next         = 1'b1;
                wr_addr_next              = axil_awaddr[11:0];

                if (axil_awvalid & axil_awready) begin
                    axil_awready_next   = 1'b0;
                    wr_state_next       = WR_SET_DATA_STATE;
                end
            end // WR_GET_ADDR_STATE

            WR_GET_DATA_STATE: begin

                axil_wready_next        = 1'b1;

                if (axil_wvalid & axil_wready) begin
                    axil_wready_next    = 1'b0; // De-assert 'ready' on the next cycle
                    wr_data_next        = axil_wdata;
                    wr_state_next       = WR_SET_DATA_STATE;
                end
            end // WR_GET_DATA_STATE

            WR_SET_DATA_STATE: begin

                do_write_next = 1'b1;
                axil_bvalid_next = 1'b1;
                wr_state_next = WR_WAIT_FOR_BVALID_STATE;

            end // WR_SET_DATA_STATE


            WR_WAIT_FOR_BVALID_STATE: begin

                axil_bvalid_next = 1'b1;

                // Get the bresp ack
                if (axil_bvalid == 1'b1 && axil_bready == 1'b1) begin

                    // If we're ready, wait until the master asserts bvalid,
                    // and then go back to the IDLE state.
                    axil_bvalid_next    = 1'b0;
                    wr_state_next       = WR_IDLE_STATE;
                end

            end // WR_SET_DATA_STATE
        endcase
    end // COMB_LOGIC_WRITE_FSM_NEXT_STATE

    // -----------------------------------------------------------------
    // Read FSM: Combinatorial Next-State Logic
    // -----------------------------------------------------------------
    always_comb begin: READ_FSM_NEXT_STATE_LOGIC

        // Defaults...
        rd_state_next           = rd_state;
        axil_rdata_next         = axil_rdata;
        rd_addr_next            = rd_addr;
        do_rd_next              = 1'b0;
        axil_arready_next       = 1'b0;
        axil_rvalid_next        = 1'b0;

        case (rd_state)

            RD_IDLE_STATE: begin
                axil_arready_next = 1'b1; // We're ready for a read address transaction.
                if (axil_arvalid == 1'b1 && axil_arready == 1'b1) begin
                    rd_addr_next        = axil_araddr[11:0];
                    do_rd_next          = 1'b1;
                    rd_state_next       = RD_STATE;
                    axil_arready_next   = 1'b0;
                end
            end

            RD_STATE: begin
                axil_rdata_next   = rdata;
                axil_rvalid_next  = 1'b1;
                rd_state_next       = RD_ACK_STATE;
            end

            RD_ACK_STATE: begin  // RD_ACK_STATE
                axil_rvalid_next = axil_rvalid;
                if (axil_rvalid == 1'b1 && axil_rready == 1'b1) begin
                    axil_rvalid_next    = 1'b0;
                    rd_state_next       = RD_IDLE_STATE;
                end
            end

            default: begin  // RD_ACK_STATE
                axil_rvalid_next = axil_rvalid;
                if (axil_rvalid == 1'b1 && axil_rready == 1'b1) begin
                    axil_rvalid_next    = 1'b0;
                    rd_state_next       = RD_IDLE_STATE;
                end
            end
        endcase

    end // READ_FSM_NEXT_STATE_LOGIC

    // -----------------------------------------------------------------
    // Assign next state for write FSM/def. state if reset is high
    // -----------------------------------------------------------------
    always @ (posedge axi_aclk) begin : ASSIGN_WRITE_FSM_NEXT_STATE
        if (axi_aresetn == 1'b0) begin
            wr_state            <= WR_IDLE_STATE;
            do_write            <= 1'b0;
            axil_awready        <= 1'b0;
            axil_wready         <= 1'b0;
        end
        else begin
            wr_state            <= wr_state_next;
            do_write            <= do_write_next;
            axil_awready        <= axil_awready_next;
            axil_wready         <= axil_wready_next;
            axil_bvalid         <= axil_bvalid_next;
        end

        // Unconditionally flop these in
        wr_addr                 <= wr_addr_next;
        wr_data                 <= wr_data_next;
    end // ASSIGN_WRITE_FSM_NEXT_STATE

    // -----------------------------------------------------------------
    // Flop in next read FSM state, handle state under a reset
    // -----------------------------------------------------------------
    always @ (posedge axi_aclk) begin: ASSIGN_READ_FSM_NEXT_STATE
        if (axi_aresetn == 1'b0) begin
            rd_state            <= RD_IDLE_STATE;
            axil_arready        <= 1'b0;
            axil_rvalid         <= 1'b0;
            axil_rdata          <= 32'd0;
            do_rd               <= 1'b0;
        end
        else begin
            rd_state            <= rd_state_next;
            axil_rdata          <= axil_rdata_next;
            axil_arready        <= axil_arready_next;
            axil_rvalid         <= axil_rvalid_next;
            do_rd               <= do_rd_next;
        end
        rd_addr     <= rd_addr_next;
    end

    logic   [31:0]   scratch_0;
    logic            sticky_lm_full;

    // ============================================================
    // Write Logic -- BEGIN
    // ============================================================
    always @ (posedge axi_aclk) begin: REGISTER_WRITE

        // Reset read/write registers to their default value.
        if (axi_aresetn == 1'b0) begin

            scratch_0                           <= 'd0;

            hwchk_gtf_ch_gttxreset                <= 'd0;
            hwchk_gtf_ch_txpmareset               <= 'd0;
            hwchk_gtf_ch_txpcsreset               <= 'd0;
            hwchk_gtf_ch_gtrxreset                <= 'd0;
            hwchk_gtf_ch_rxpmareset               <= 'd0;
            hwchk_gtf_ch_rxdfelpmreset            <= 'd0;
            hwchk_gtf_ch_eyescanreset             <= 'd0;
            hwchk_gtf_ch_rxpcsreset               <= 'd0;
            hwchk_gtf_cm_qpll0reset               <= 'd0;

            hwchk_gtf_ch_txuserrdy                <= 'd0;
            hwchk_gtf_ch_rxuserrdy                <= 'd0;

            gtwiz_reset_tx_pll_and_datapath_in  <= 'd0;
            gtwiz_reset_tx_datapath_in          <= 'd0; // 1'b1;
            gtwiz_reset_rx_pll_and_datapath_in  <= 'd0;
            gtwiz_reset_rx_datapath_in          <= 'd0; // 1'b1;

            ctl_tx_fcs_ins_enable               <= 'd0;
            ctl_tx_start_framing_enable         <= 'd0;
            ctl_tx_custom_preamble_en           <= 'd0;
            ctl_rx_custom_preamble_en           <= 'd0;
            ctl_rx_packet_framing_enable        <= 'd0;
            //Recov: Redefined ctl_hwchk_frm_gen_en                  <= 'd0;
            ctl_hwchk_frm_gen_mode                <= 'd0;
            ctl_num_frames                      <= 'd0;
            //Recov: Redefined ctl_hwchk_mon_en                      <= 'd0;
            ctl_hwchk_max_len                     <= 'd0;
            ctl_hwchk_min_len                     <= 'd0;
            ctl_hwchk_tx_custom_preamble[31:0]    <= 32'h55555555;
            ctl_hwchk_tx_custom_preamble[63:32]   <= 32'hd5555555;
            ctl_tx_variable_ipg                 <= 'd0;
            ctl_hwchk_rx_custom_preamble[31:0]    <= 32'h55555555; //default value
            ctl_hwchk_rx_custom_preamble[63:32]   <= 32'hd5555555; //default value
            ctl_hwchk_tx_inj_err                  <= 'd0;
            ctl_hwchk_tx_inj_poison               <= 'd0;
            ctl_hwchk_tx_inj_pause                <= 'd0;
            ctl_hwchk_tx_inj_pause_sa[31:0]       <= 'd0;
            ctl_hwchk_tx_inj_pause_sa[47:32]      <= 'd0;
            ctl_hwchk_tx_inj_pause_da[31:0]       <= 'd0;
            ctl_hwchk_tx_inj_pause_da[47:32]      <= 'd0;
            ctl_hwchk_tx_inj_pause_ethtype        <= 'd0;
            ctl_hwchk_tx_inj_pause_opcode         <= 'd0;
            ctl_hwchk_tx_inj_pause_timer_ce       <= 'd0;
            ctl_hwchk_tx_inj_pause_timer_pfc0     <= 'd0;
            ctl_hwchk_tx_inj_pause_timer_pfc1     <= 'd0;
            ctl_hwchk_tx_inj_pause_timer_pfc2     <= 'd0;
            ctl_hwchk_tx_inj_pause_timer_pfc3     <= 'd0;
            ctl_hwchk_tx_inj_pause_timer_pfc4     <= 'd0;
            ctl_hwchk_tx_inj_pause_timer_pfc5     <= 'd0;
            ctl_hwchk_tx_inj_pause_timer_pfc6     <= 'd0;
            ctl_hwchk_tx_inj_pause_timer_pfc7     <= 'd0;
            stat_tick                           <= 'd0;
            ctl_hwchk_tx_start_lat_run            <= 'd0;

            ctl_correct_bitslip                 <= 1'b0;
            ctl_disable_bitslip                 <= 1'b0;
            ctl_gb_seq_sync                     <= 1'b1;

            //Recov: 
            rx_packet_count_rst                 <= 1'b0;
            fifo_rst_status                     <= 1'b0;
        end
        else begin
            //Recov: self-clearing register...
            rx_packet_count_rst                 <= 1'b0;
            fifo_rst_status                     <= 1'b0;

            // Self-clearing registers are set up in this area
            stat_tick   <= 1'b0;

            if (ack_hwchk_tx_inj_err)         ctl_hwchk_tx_inj_err       <= 1'b0;
            if (ack_hwchk_tx_inj_poison)      ctl_hwchk_tx_inj_poison    <= 1'b0;
            if (ack_hwchk_tx_inj_pause)       ctl_hwchk_tx_inj_pause     <= 1'b0;
            //Recov: Redefined... if (ack_frm_gen_done)           ctl_hwchk_frm_gen_en       <= 1'b0;
            if (ack_hwchk_tx_start_lat_run)   ctl_hwchk_tx_start_lat_run <= 1'b0;

            // End of self-clearing registers


            // Assign writeable registers to the appropriate bits of the write bus
            // if selected using address bus.
            if (do_write) begin

                // Resets to the GTF
                unique if (wr_addr == 12'h004) begin

                    hwchk_gtf_ch_gttxreset                <= wr_data[0];
                    hwchk_gtf_ch_txpmareset               <= wr_data[1];
                    hwchk_gtf_ch_txpcsreset               <= wr_data[2];
                    gtwiz_reset_tx_pll_and_datapath_in  <= wr_data[3];
                    gtwiz_reset_tx_datapath_in          <= wr_data[4];

                    hwchk_gtf_ch_gtrxreset                <= wr_data[8];
                    hwchk_gtf_ch_rxpmareset               <= wr_data[9];
                    hwchk_gtf_ch_rxdfelpmreset            <= wr_data[10];
                    hwchk_gtf_ch_eyescanreset             <= wr_data[11];
                    hwchk_gtf_ch_rxpcsreset               <= wr_data[12];
                    gtwiz_reset_rx_pll_and_datapath_in  <= wr_data[13];
                    gtwiz_reset_rx_datapath_in          <= wr_data[14];

                    hwchk_gtf_cm_qpll0reset               <= wr_data[16];

                end

                else if (wr_addr == 12'h008) begin
                    scratch_0                           <= wr_data[31:0];
                end

                else if (wr_addr == 12'h00C) begin
                    hwchk_gtf_ch_txuserrdy                <= wr_data[0];
                    hwchk_gtf_ch_rxuserrdy                <= wr_data[1];
                end

                else if (wr_addr == 12'h010) begin
                    ctl_tx_fcs_ins_enable               <= wr_data[4];
                    ctl_tx_custom_preamble_en           <= wr_data[8];
                    ctl_tx_start_framing_enable         <= wr_data[12];
                    ctl_rx_packet_framing_enable        <= wr_data[20];
                    ctl_rx_custom_preamble_en           <= wr_data[24];
                end

                else if (wr_addr == 12'h014) begin
                    ctl_hwchk_frm_gen_mode                <= wr_data[0];
                    ctl_tx_variable_ipg                 <= wr_data[8];
                end

                //Recov: Redefined above...
                //else if (wr_addr == 12'h020) begin
                //    ctl_hwchk_frm_gen_en                  <= wr_data[0];
                //    ctl_hwchk_mon_en                      <= wr_data[4];
                //end

                else if (wr_addr == 12'h024) begin
                    ctl_hwchk_max_len                     <= wr_data[13:0];
                end

                else if (wr_addr == 12'h028) begin
                    ctl_hwchk_min_len                     <= wr_data[13:0];
                end

                else if (wr_addr == 12'h02c) begin
                    ctl_num_frames                      <= wr_data[31:0];
                end

                else if (wr_addr == 12'h030) begin
                    ctl_hwchk_tx_custom_preamble[31:0]    <= wr_data[31:0];
                end
                else if (wr_addr == 12'h034) begin
                    ctl_hwchk_tx_custom_preamble[63:32]   <= wr_data[31:0];
                end

                else if (wr_addr == 12'h038) begin
                    ctl_hwchk_rx_custom_preamble[31:0]    <= wr_data[31:0];
                end
                else if (wr_addr == 12'h03c) begin
                    ctl_hwchk_rx_custom_preamble[63:32]   <= wr_data[31:0];
                end

                else if (wr_addr == 12'h040) begin
                    ctl_hwchk_tx_inj_err                  <= wr_data[0];
                end

                else if (wr_addr == 12'h044) begin
                    ctl_hwchk_tx_inj_pause                <= wr_data[0];
                end

                else if (wr_addr == 12'h050) begin
                    ctl_hwchk_tx_inj_pause_sa[31:0]       <= wr_data[31:0];
                end
                else if (wr_addr == 12'h054) begin
                    ctl_hwchk_tx_inj_pause_sa[47:32]      <= wr_data[15:0];
                end

                else if (wr_addr == 12'h058) begin
                    ctl_hwchk_tx_inj_pause_da[31:0]       <= wr_data[31:0];
                end
                else if (wr_addr == 12'h05c) begin
                    ctl_hwchk_tx_inj_pause_da[47:32]      <= wr_data[31:0];
                end

                else if (wr_addr == 12'h060) begin
                    ctl_hwchk_tx_inj_pause_ethtype        <= wr_data[15:0];
                end

                else if (wr_addr == 12'h064) begin
                    ctl_hwchk_tx_inj_pause_opcode         <= wr_data[15:0];
                end

                else if (wr_addr == 12'h068) begin
                    ctl_hwchk_tx_inj_pause_timer_ce       <= wr_data[15:0];
                end

                else if (wr_addr == 12'h06c) begin
                    ctl_hwchk_tx_inj_pause_timer_pfc0     <= wr_data[15:0];
                end

                else if (wr_addr == 12'h070) begin
                    ctl_hwchk_tx_inj_pause_timer_pfc1     <= wr_data[15:0];
                end

                else if (wr_addr == 12'h074) begin
                    ctl_hwchk_tx_inj_pause_timer_pfc2     <= wr_data[15:0];
                end

                else if (wr_addr == 12'h078) begin
                    ctl_hwchk_tx_inj_pause_timer_pfc3     <= wr_data[15:0];
                end

                else if (wr_addr == 12'h07c) begin
                    ctl_hwchk_tx_inj_pause_timer_pfc4     <= wr_data[15:0];
                end

                else if (wr_addr == 12'h080) begin
                    ctl_hwchk_tx_inj_pause_timer_pfc5     <= wr_data[15:0];
                end

                else if (wr_addr == 12'h084) begin
                    ctl_hwchk_tx_inj_pause_timer_pfc6     <= wr_data[15:0];
                end

                else if (wr_addr == 12'h088) begin
                    ctl_hwchk_tx_inj_pause_timer_pfc7     <= wr_data[15:0];
                end


                else if (wr_addr == 12'h094) begin
                    ctl_hwchk_tx_start_lat_run            <= wr_data[0];
                end
                
                else if (wr_addr == 12'h098) begin
                    ctl_hwchk_tx_inj_poison              <= wr_data[0];
                end

                else if (wr_addr == 12'h0A4) begin
                    ctl_correct_bitslip                 <= wr_data[0];
                    ctl_disable_bitslip                  <= wr_data[4];
                    ctl_gb_seq_sync                     <= wr_data[8];
                end

	            //Recov: Receive packet counter for user status
                else if (wr_addr == 12'h11c) begin
                    rx_packet_count_rst                 <= 1'b1; // ~rx_packet_count_rst;
                end

	            //Recov: Write to this register will reset FIFO Status Registers.
                else if (wr_addr == 12'h120) begin
                    fifo_rst_status                     <= 1'b1;
                end

            end

        end

    end


    always_comb begin : READ_DATA_COMBINATORIAL

        rdata = 32'h0;

        unique if (rd_addr == 12'h000) begin
            rdata[0]    = stat_gtf_tx_rst;
            rdata[1]    = stat_gtf_rx_rst;
            rdata[4]    = stat_gtf_block_lock;
        end

        else if (rd_addr == 12'h004) begin
            rdata[0]    = hwchk_gtf_ch_gttxreset;
            rdata[1]    = hwchk_gtf_ch_txpmareset;
            rdata[2]    = hwchk_gtf_ch_txpcsreset;
            rdata[3]    = gtwiz_reset_tx_pll_and_datapath_in;
            rdata[4]    = gtwiz_reset_tx_datapath_in;

            rdata[8]    = hwchk_gtf_ch_gtrxreset;
            rdata[9]    = hwchk_gtf_ch_rxpmareset;
            rdata[10]   = hwchk_gtf_ch_rxdfelpmreset;
            rdata[11]   = hwchk_gtf_ch_eyescanreset;
            rdata[12]   = hwchk_gtf_ch_rxpcsreset;
            rdata[13]   = gtwiz_reset_rx_pll_and_datapath_in;
            rdata[14]   = gtwiz_reset_rx_datapath_in;

            rdata[16]   = hwchk_gtf_cm_qpll0reset;
        end

        else if (rd_addr == 12'h008) begin
            rdata[31:0]  = scratch_0;
        end

        else if (rd_addr == 12'h00c) begin
            rdata[0]     = hwchk_gtf_ch_txuserrdy;
            rdata[1]     = hwchk_gtf_ch_rxuserrdy;
        end

        else if (rd_addr == 12'h010) begin
            rdata[4]     = ctl_tx_fcs_ins_enable;
            rdata[8]     = ctl_tx_custom_preamble_en;
            rdata[12]    = ctl_tx_start_framing_enable;
            rdata[20]    = ctl_rx_packet_framing_enable;
            rdata[24]    = ctl_rx_custom_preamble_en;
        end

        else if (rd_addr == 12'h014) begin
            rdata[0]     = ctl_hwchk_frm_gen_mode;
            rdata[8]     = ctl_tx_variable_ipg;
        end

        else if (rd_addr == 12'h020) begin
            rdata[0]     = ctl_hwchk_frm_gen_en;
            rdata[4]     = ctl_hwchk_mon_en;
        end

        else if (rd_addr == 12'h024) begin
            rdata[13:0]     = ctl_hwchk_max_len;
        end

        else if (rd_addr == 12'h028) begin
            rdata[13:0]     = ctl_hwchk_min_len;
        end

        else if (rd_addr == 12'h02c) begin
            rdata[31:0]     = ctl_num_frames;
        end

        else if (rd_addr == 12'h030) begin
            rdata[31:0]     = ctl_hwchk_tx_custom_preamble[31:0];
        end
        else if (rd_addr == 12'h034) begin
            rdata[31:0]     = ctl_hwchk_tx_custom_preamble[63:32];
        end

        else if (rd_addr == 12'h038) begin
            rdata[31:0]     = ctl_hwchk_rx_custom_preamble[31:0];
        end
        else if (rd_addr == 12'h03c) begin
            rdata[31:0]     = ctl_hwchk_rx_custom_preamble[63:32];
        end

        else if (rd_addr == 12'h040) begin
            rdata[0]     = ctl_hwchk_tx_inj_err;
        end

        else if (rd_addr == 12'h044) begin
            rdata[0]     = ctl_hwchk_tx_inj_pause;
        end

        else if (rd_addr == 12'h050) begin
            rdata[31:0]     = ctl_hwchk_tx_inj_pause_sa[31:0];
        end
        else if (rd_addr == 12'h054) begin
            rdata[15:0]     = ctl_hwchk_tx_inj_pause_sa[47:32];
        end

        else if (rd_addr == 12'h058) begin
            rdata[31:0]     = ctl_hwchk_tx_inj_pause_da[31:0];
        end
        else if (rd_addr == 12'h05c) begin
            rdata[31:0]     = ctl_hwchk_tx_inj_pause_da[47:32];
        end

        else if (rd_addr == 12'h060) begin
            rdata[15:0]     = ctl_hwchk_tx_inj_pause_ethtype;
        end

        else if (rd_addr == 12'h064) begin
            rdata[15:0]     = ctl_hwchk_tx_inj_pause_opcode;
        end

        else if (rd_addr == 12'h068) begin
            rdata[15:0]     = ctl_hwchk_tx_inj_pause_timer_ce;
        end

        else if (rd_addr == 12'h06c) begin
            rdata[15:0]     = ctl_hwchk_tx_inj_pause_timer_pfc0;
        end

        else if (rd_addr == 12'h070) begin
            rdata[15:0]     = ctl_hwchk_tx_inj_pause_timer_pfc1;
        end

        else if (rd_addr == 12'h074) begin
            rdata[15:0]     = ctl_hwchk_tx_inj_pause_timer_pfc2;
        end

        else if (rd_addr == 12'h078) begin
            rdata[15:0]     = ctl_hwchk_tx_inj_pause_timer_pfc3;
        end

        else if (rd_addr == 12'h07c) begin
            rdata[15:0]     = ctl_hwchk_tx_inj_pause_timer_pfc4;
        end

        else if (rd_addr == 12'h080) begin
            rdata[15:0]     = ctl_hwchk_tx_inj_pause_timer_pfc5;
        end

        else if (rd_addr == 12'h084) begin
            rdata[15:0]     = ctl_hwchk_tx_inj_pause_timer_pfc6;
        end

        else if (rd_addr == 12'h088) begin
            rdata[15:0]     = ctl_hwchk_tx_inj_pause_timer_pfc7;
        end

        else if (rd_addr == 12'h090) begin
            rdata[0]     = stat_tick;
        end

        else if (rd_addr == 12'h094) begin
            rdata[0]     = ctl_hwchk_tx_start_lat_run;
        end
        
        else if (rd_addr == 12'h098) begin
            rdata[0]     = ctl_hwchk_tx_inj_poison;
        end

        else if (rd_addr == 12'h0A0) begin
            rdata[6:0]      = stat_bitslip_cnt;
            rdata[14:8]     = stat_bitslip_issued;
            rdata[16]       = stat_bitslip_locked;
            rdata[17]       = stat_bitslip_busy;
            rdata[18]       = stat_bitslip_done;
            rdata[19]       = stat_excessive_bitslip;
        end
        else if (rd_addr == 12'h0A4) begin
            rdata[0]        = ctl_correct_bitslip;
            rdata[4]        = ctl_disable_bitslip;
            rdata[8]        = ctl_gb_seq_sync;
        end

        else if (rd_addr == 12'h100) begin
             rdata[15:0] = 16'h10;
        end

        else if (rd_addr == 12'h104) begin
             rdata[31:0] = tx_clk_cps;
        end

        else if (rd_addr == 12'h108) begin
             rdata[31:0] = rx_clk_cps;
        end

        else if (rd_addr == 12'h10c) begin
             rdata[31:0] = axi_aclk_cps;
        end

        else if (rd_addr == 12'h110) begin
             rdata[31:0] = gen_clk_cps;
        end

        else if (rd_addr == 12'h114) begin
             rdata[31:0] = mon_clk_cps;
        end

        else if (rd_addr == 12'h118) begin
             rdata[31:0] = lat_clk_cps;
        end

        //Recov: Receive packet counter for user status
        else if (rd_addr == 12'h11c) begin
             rdata[31:0] = rx_packet_count;
        end

        //Recov: FIFO Status Registers.
        else if (rd_addr == 12'h120) begin
             rdata[31:0] = fifo_tx_wr_count;  // Num of TX words
        end

        else if (rd_addr == 12'h124) begin
             rdata[31:0] = fifo_rx_wr_count;  // Num of RX words
        end

        else if (rd_addr == 12'h128) begin
             rdata[31:20] = 'h0;
             rdata[19]    = fifo_rx_err_overflow ;
             rdata[18]    = fifo_rx_err_underflow;
             rdata[17]    = fifo_tx_err_overflow ;
             rdata[16]    = fifo_tx_err_underflow;
             rdata[15:0]  = fifo_rd_err_count    ; // Num of error detected
        end

        else if (rd_addr == 12'h12C) begin
             rdata[31:1] = 'h0;
             rdata[0]    = fifo_tx_fcs_error;
        end

        else begin
            rdata = 32'h0;
        end


    end

endmodule
`default_nettype wire

`default_nettype none
module gtfmac_hwchk_ra_buf # (
    // MAX_CREDITS=0 implies no credits required
    parameter  MAX_CREDITS  = 8,
    parameter  BP_THRESH    = 64
) (

    // Data from traffic generator
    input  wire             in_clk,
    input  wire             in_rst,
    output reg              in_bp,
    output logic            in_overflow,

    input  wire             din_ena,
    input  wire             din_pre,
    input  wire             din_sop,
    input  wire             din_eop,
    input  wire [64-1:0]    din_data,
    input  wire [7:0]       din_last,
    input  wire             din_err,
    input  wire             din_poison,

    input  wire             out_clk,
    input  wire             out_rst,

    // data/credit interface to the DUT
    input  wire             out_credit,

    output logic            dout_ena,
    output logic            dout_pre,
    output logic [64-1:0]   dout_data,
    output logic            dout_sop,
    output logic [7:0]      dout_last,
    output logic            dout_err,
    output logic            dout_poison

);


    localparam  RAM_WIDTH   = 76;   // data + pre + sop + tlast + err + poison (was 75 before poison)
    localparam  RAM_DEPTH   = 2048;
    localparam  ADDR_WIDTH  = 11;
    localparam  PTR_WIDTH   = ADDR_WIDTH+1;


    (* ram_style = "block" *) reg  [RAM_WIDTH-1:0] ram [RAM_DEPTH-1:0];

    logic [PTR_WIDTH-1:0]       live_wr_ptr;
    logic [ADDR_WIDTH-1:0]      live_wr_addr;
    logic [ADDR_WIDTH-1:0]      out_rd_addr;

    logic [PTR_WIDTH-1:0]       in_wr_ptr, in_rd_ptr;
    logic [PTR_WIDTH-1:0]       out_wr_ptr, out_rd_ptr;

    logic                       ena, wea;
    logic                       enb;

    logic [RAM_WIDTH-1:0]       dina;
    logic [RAM_WIDTH-1:0]       doutb;

    logic [PTR_WIDTH-1:0]       in_spav;
    logic [PTR_WIDTH-1:0]       out_datav;
    logic                       out_data_rdy;

    // note - width of 'credits' must be large enough to accomodate MAX_CREDITS
    logic [3:0]                 credits;
    logic                       pop_data;

    gtfmac_hwchk_syncer_bus #(
       .WIDTH (PTR_WIDTH)
    ) i_wr_ptr_syncer (
       .clkin        (in_clk),
       .clkin_reset  (~in_rst),
       .clkout       (out_clk),
       .clkout_reset (~out_rst),

       .busin        (in_wr_ptr),
       .busout       (out_wr_ptr)
    );

    gtfmac_hwchk_syncer_bus #(
       .WIDTH (PTR_WIDTH)
    ) i_rd_ptr_syncer (
        .clkin        (out_clk),
        .clkin_reset  (~out_rst),
        .clkout       (in_clk),
        .clkout_reset (~in_rst),

        .busin        (out_rd_ptr),
        .busout       (in_rd_ptr)
    );


    always @ (posedge in_clk) begin

        in_spav <= {1'b1, in_rd_ptr[ADDR_WIDTH-1:0]} - {in_rd_ptr[PTR_WIDTH-1]  ^ live_wr_ptr[PTR_WIDTH-1], live_wr_ptr[ADDR_WIDTH-1:0]};
        in_bp   <= (in_spav < BP_THRESH) ? 1'b1 : 1'b0;

        if (in_rst) begin
            in_spav <= RAM_DEPTH;
            in_bp   <= 1'b0;
        end

    end

    assign in_overflow = (in_spav == 0) ?  din_ena : 1'b0;

    assign wea = 1'b1;

    always @ (posedge in_clk) begin

        dina        <= {din_pre, din_sop, din_last, din_err, din_poison, din_data};
        ena         <= din_ena;
        live_wr_ptr <= live_wr_ptr + din_ena;

        if (din_ena && din_eop) begin
            in_wr_ptr   <= live_wr_ptr + 1'b1;
        end

        if (in_rst) begin
            ena         <= 1'b0;
            live_wr_ptr <= {PTR_WIDTH{1'b0}};
            in_wr_ptr   <= {PTR_WIDTH{1'b0}};
        end

    end

    assign  live_wr_addr    = live_wr_ptr[ADDR_WIDTH-1:0];
    assign  out_rd_addr     = out_rd_ptr[ADDR_WIDTH-1:0];

    gtfmac_hwchk_simple_bram # (
        .RAM_WIDTH  (RAM_WIDTH),
        .RAM_DEPTH  (RAM_DEPTH),
        .ADDR_WIDTH (ADDR_WIDTH)
    ) i_ra_buf_ram
    (

        .in_clk     (in_clk),
        .out_clk    (out_clk),

        .ena        (ena),
        .wea        (wea),
        .wr_addr    (live_wr_addr),
        .dina       (dina),

        .enb        (enb),
        .rd_addr    (out_rd_addr),
        .doutb      (doutb)

    );



    // Manage Credits
    always @ (posedge out_clk) begin

        if (MAX_CREDITS > 0) begin
            case ({pop_data, out_credit})

                2'b10: begin
                    credits <= credits - 1'b1;
                end
                2'b01: begin
                    credits <= credits + 1'b1;
                end

            endcase
        end

        if (out_rst) begin
            credits <= MAX_CREDITS;
        end

    end

    assign  out_data_rdy    = out_wr_ptr != out_rd_ptr;
    assign  pop_data        = (MAX_CREDITS == 0 || credits > 0) && out_data_rdy;

    always @ (posedge out_clk) begin

        enb         <= pop_data;
        out_rd_ptr  <= out_rd_ptr + pop_data;
        out_datav   <= {1'b1, out_wr_ptr[ADDR_WIDTH-1:0]} - {out_rd_ptr[PTR_WIDTH-1] ~^ out_wr_ptr[PTR_WIDTH-1], out_rd_ptr[ADDR_WIDTH-1:0]};

        if (out_rst) begin
            enb         <= 1'b0;
            out_rd_ptr  <= {PTR_WIDTH{1'b0}};
            out_datav   <= {PTR_WIDTH{1'b0}};
        end

    end

    logic                   enb_R;
    logic [RAM_WIDTH-1:0]   doutb_R;

    always @ (posedge out_clk) begin

        enb_R       <= enb;
        dout_ena    <= enb_R;

        doutb_R     <= doutb;

        if (out_rst) begin
            enb_R       <= 1'b0;
            dout_ena    <= 1'b0;
        end

    end

    assign {dout_pre, dout_sop, dout_last, dout_err, dout_poison, dout_data} = doutb_R;

endmodule
`default_nettype wire

////////////////////////////////////////////////////////////////////////////////
//
// Description :
//   Implement a simple FIFO.
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none
module gtfmac_hwchk_simple_fifo #(
   parameter WIDTH     = 32,
   parameter REG       = 0,
   parameter DEPTH     = 16,
   parameter DEPTHLOG2 = 4,
   parameter RESET     = 0,

   parameter ALMOSTEMPTY = DEPTH/4,
   parameter ALMOSTFULL  = DEPTH-ALMOSTEMPTY,
   parameter CENTERED    = DEPTH/2,
   parameter FULL        = DEPTH
 )
(
  input  wire               clk,
  input  wire               reset,
  input  wire   [WIDTH-1:0] wdat,
  input  wire               we,

  input  wire               re,
  output reg    [WIDTH-1:0] rdat,
  output wire   [WIDTH-1:0] rdat_unreg,

  input  wire   [DEPTHLOG2:0] full_threshold,
  input  wire   [DEPTHLOG2:0] a_empty_threshold,
  input  wire   [DEPTHLOG2:0] a_full_threshold,
  input  wire   [DEPTHLOG2:0] c_threshold,

  output reg                empty,
  output reg                almost_empty,
  output reg                almost_full,
  output reg                centered,
  output wire [DEPTHLOG2:0] fill_level,
  output reg                full
);

   reg  [DEPTHLOG2-1:0] wadd_r;
   reg  [DEPTHLOG2-1:0] wadd_nxt;
   reg  [DEPTHLOG2-1:0] radd_nxt;
   reg  [DEPTHLOG2-1:0] radd_r;
   reg      [WIDTH-1:0] reg_arr_r [DEPTH-1:0];
   reg      [WIDTH-1:0] rdat_r;
   wire     [WIDTH-1:0] rdat_int;

   reg    [DEPTHLOG2:0] fill_level_cnt;
   reg    [DEPTHLOG2:0] fill_level_cnt_nxt;


   assign fill_level = fill_level_cnt;

   always @ (posedge clk) begin
      if (reset == 1'b1) begin
         wadd_r         <= {DEPTHLOG2 {1'b0}};
         radd_r         <= {DEPTHLOG2 {1'b0}};
         fill_level_cnt <= {1'b0, {DEPTHLOG2 {1'b0}}};
         empty          <= 1'b1;
         almost_empty   <= 1'b1;
         almost_full    <= 1'b0;
         centered       <= 1'b0;
         full           <= 1'b0;
      end
      else begin
         wadd_r         <= wadd_nxt;
         radd_r         <= radd_nxt;
         fill_level_cnt <= fill_level_cnt_nxt;
         empty          <= ~|fill_level_cnt_nxt;
         full           <= (fill_level_cnt_nxt == full_threshold) ? 1'b1 : 1'b0;
         almost_empty   <= (fill_level_cnt_nxt > a_empty_threshold)   ? 1'b0 : 1'b1;
         almost_full    <= (fill_level_cnt_nxt <= a_full_threshold)   ? 1'b0 : 1'b1;
         centered       <= (fill_level_cnt_nxt >= c_threshold)    ? 1'b1 : 1'b0;
      end
   end

   // Output all 0s if empty.  A 'vld' signal can then be part of the FIFOed data
   assign rdat_int   = (empty) ? {WIDTH{1'b0}} : reg_arr_r [radd_r];
   assign rdat_unreg = rdat_int;

   always @* begin
      if (REG)
         rdat = rdat_r;
      else begin
         rdat = rdat_int;
      end
   end

   always @(posedge clk) begin
      if (reset == 1'b1) begin
        rdat_r <= {WIDTH{1'b0}};
      end
      else begin
        rdat_r <= re ? rdat_int : rdat_r;
      end
   end

   // Simple fifo write read logic.
   always @* begin
      wadd_nxt =  wadd_r;
      radd_nxt =  radd_r;

      if (we == 1'b1)
         wadd_nxt = (wadd_r == DEPTH-1) ? {1'b0, {DEPTHLOG2 {1'b0}}} :  wadd_r + 1'b1;

      if (re & !empty)
         radd_nxt = (radd_r == DEPTH-1) ? {1'b0, {DEPTHLOG2 {1'b0}}} :  radd_r + 1'b1;

   end

   // Flag  and threshold logic.
   // Operates in "safe" mode, can't underflow.
   always @* begin
      // Fifo full/empty/almost.
      if ( we && ! (re && !empty) )
         fill_level_cnt_nxt = fill_level_cnt + 1;

      else if ( !we && re && !empty )
         fill_level_cnt_nxt = fill_level_cnt - 1;

      else
         fill_level_cnt_nxt = fill_level_cnt;
   end

   generate
      if ( RESET == 1 ) begin : ARRAY_RESET
         always @ (posedge clk) begin
            if (reset == 1'b1) begin
               for (int i = 0; i < DEPTH; i++) begin
                  reg_arr_r[i] <= {WIDTH {1'b0}};
               end
            end
            else begin
               if (we) reg_arr_r[wadd_r] <= wdat;
            end
         end
      end else begin: ARRAY_UNRESET
         always @(posedge clk) begin
             if (we) reg_arr_r[wadd_r] <= wdat;
         end
      end
   endgenerate

endmodule // simple_fifo
`default_nettype wire

`default_nettype none
module gtfmac_hwchk_simple_bram # (
    parameter  RAM_WIDTH   = 74,
    parameter  RAM_DEPTH   = 512,
    parameter  ADDR_WIDTH  = 9
) (

    input   wire                    in_clk,
    input   wire                    out_clk,

    input   wire                    ena,
    input   wire                    wea,
    input   wire [ADDR_WIDTH-1:0]   wr_addr,
    input   wire [RAM_WIDTH-1:0]    dina,

    input   wire                    enb,
    input   wire [ADDR_WIDTH-1:0]   rd_addr,
    output  reg  [RAM_WIDTH-1:0]    doutb

);

    (* ram_style = "block" *) reg  [RAM_WIDTH-1:0] ram [RAM_DEPTH-1:0];

    // Infer BRAM - simple dual port
    always @ (posedge in_clk) begin

        if (ena) begin
            if (wea) begin
                ram[wr_addr] <= dina;
            end
        end

    end

    always @ (posedge out_clk) begin

        if (enb) begin
            doutb   <= ram[rd_addr];
        end

    end

endmodule
`default_nettype wire
`default_nettype none
module gtfmac_hwchk_syncer_bus
#(
  parameter WIDTH = 8
 )
(
  input  wire clkin,
  input  wire clkin_reset,
  input  wire clkout,
  input  wire clkout_reset,

  input  wire [WIDTH-1:0] busin,
  output reg  [WIDTH-1:0] busout
);

  reg  [WIDTH-1:0] busout_nxt;
  reg  [WIDTH-1:0] latched_inputs;
  reg  [WIDTH-1:0] latched_inputs_nxt;

  wire ready;
  reg  req_event;
  reg  req_event_nxt;
  wire sync_req_event;
  reg  ack_event;
  reg  ack_event_nxt;
  wire sync_ack_event;

  reg ready_clkin;


  gtfmac_hwchk_syncer_level i_ready_clkout_sync (

    .clk        (clkout),
    .reset      (clkout_reset),

    .datain     (ready_clkin),
    .dataout    (ready)

  );  // i_ready_clkout_sync


  gtfmac_hwchk_syncer_level i_req_clkout_sync (

    .clk        (clkout),
    .reset      (clkout_reset),

    .datain     (req_event),
    .dataout    (sync_req_event)

  );  // i_req_clkout_sync


  gtfmac_hwchk_syncer_level i_ack_clkin_sync (

    .clk        (clkin),
    .reset      (clkin_reset),

    .datain     (ack_event),
    .dataout    (sync_ack_event)

  );  // i_ack_clkin_sync


  always @*
    begin
      req_event_nxt = ~sync_ack_event;

      if (req_event == sync_ack_event)
        begin
          latched_inputs_nxt = busin;
        end
      else
        begin
          latched_inputs_nxt = latched_inputs;
        end
    end


  always @*
    begin
      ack_event_nxt = sync_req_event;

      if (!ready)
        begin
          busout_nxt = {WIDTH{1'b0}};
        end
      else if (ack_event != sync_req_event)
        begin
          busout_nxt = latched_inputs;
        end
      else
        begin
          busout_nxt = busout;
        end
    end


  always @( posedge clkin or negedge clkin_reset )
    begin
      if ( clkin_reset != 1'b1 )
        begin
          latched_inputs <= {WIDTH{1'b0}};
          req_event      <= 1'b0;
          ready_clkin    <= 1'b0;
        end
      else
        begin
          latched_inputs <= latched_inputs_nxt;
          req_event      <= req_event_nxt;
          ready_clkin    <= 1'b1;
        end
    end


  always @( posedge clkout or negedge clkout_reset )
    begin
      if ( clkout_reset != 1'b1 )
        begin
          busout    <= {WIDTH{1'b0}};
          ack_event <= 1'b0;
        end
      else
        begin
          busout    <= busout_nxt;
          ack_event <= ack_event_nxt;
        end
    end

endmodule
`default_nettype wire

`default_nettype none
module gtfmac_hwchk_syncer_pulse (

  input  wire clkin,
  input  wire clkin_reset,
  input  wire clkout,
  input  wire clkout_reset,

  input  wire pulsein,  // clkin domain
  output reg  pulseout  // clkout domain
);

  reg  pulsein_d1;
  reg  pulsein_d1_nxt;
  reg  pulseout_nxt;

  reg  req_event;
  reg  req_event_nxt;
  wire sync_req_event;
  reg  ack_event;
  reg  ack_event_nxt;
  wire sync_ack_event;

  wire clkin_reset_out_sync;
  wire clkout_reset_in_sync;

  gtfmac_hwchk_syncer_level i_syncpls_req (

    .clk        (clkout),
    .reset      (clkout_reset),

    .datain     (req_event),
    .dataout    (sync_req_event)

  );  // i_syncpls_req


  gtfmac_hwchk_syncer_level i_syncpls_ack (

    .clk        (clkin),
    .reset      (clkin_reset),

    .datain     (ack_event),
    .dataout    (sync_ack_event)

  );  // i_syncpls_ack

  gtfmac_hwchk_syncer_reset i_syncpls_clkin_rstsync (

    .clk         (clkout),
    .reset_async (clkin_reset),
    .reset       (clkin_reset_out_sync)

  );  // i_syncpls_clkin_rstsync

  gtfmac_hwchk_syncer_reset i_syncpls_clkout_rstsync (

    .clk         (clkin),
    .reset_async (clkout_reset),
    .reset       (clkout_reset_in_sync)

  );  // i_syncpls_clkout_rstsync


  always @*
    begin
      pulsein_d1_nxt = pulsein;
      req_event_nxt  = req_event;

      if (pulsein && !pulsein_d1 && req_event == sync_ack_event)
        begin
          req_event_nxt = ~req_event;
        end
    end


  always @*
    begin
      ack_event_nxt = sync_req_event;
      pulseout_nxt  = (ack_event != sync_req_event);
    end


  always @( posedge clkin or negedge clkout_reset_in_sync )
    begin
      if ( clkout_reset_in_sync != 1'b1 )
        begin
          pulsein_d1 <= 1'b0;
          req_event  <= 1'b0;
        end
      else
        begin
          pulsein_d1 <= pulsein_d1_nxt;
          req_event  <= req_event_nxt;
        end
    end


  always @( posedge clkout or negedge clkin_reset_out_sync )
    begin
      if ( clkin_reset_out_sync != 1'b1 )
        begin
          ack_event <= 1'b0;
          pulseout  <= 1'b0;
        end
      else
        begin
          ack_event <= ack_event_nxt;
          pulseout  <= pulseout_nxt;
        end
    end

endmodule // syncer_pulse
`default_nettype wire

`default_nettype none
module gtfmac_hwchk_syncer_level
#(
  parameter WIDTH       = 1,
  parameter RESET_VALUE = 1'b0
 )
(
  input  wire clk,
  input  wire reset,

  input  wire [WIDTH-1:0] datain,
  output wire [WIDTH-1:0] dataout
);

  (* ASYNC_REG = "TRUE" *) reg  [WIDTH-1:0] dataout_reg;
  reg  [WIDTH-1:0] meta_nxt;
  wire [WIDTH-1:0] dataout_nxt;

`ifdef RTL_DEBUG
// synthesis translate_off

  integer i;
  integer seed;
  (* ASYNC_REG = "TRUE" *) reg  [WIDTH-1:0] meta;

  (* ASYNC_REG = "TRUE" *) reg  [WIDTH-1:0] meta2;
  reg  [WIDTH-1:0] meta_state;
  reg  [WIDTH-1:0] meta_state_nxt;

  initial seed       = `SEED;
  initial meta_state = {WIDTH{RESET_VALUE}};

  always @*
    begin
      for (i=0; i < WIDTH; i = i + 1)
        begin
          if ( meta_state[i] !== 1'b1 &&
               $dist_uniform(seed,0,9999) < 5000 &&
               meta[i] !== datain[i] )
            begin
              meta_nxt[i]       = meta[i];
              meta_state_nxt[i] = 1'b1;
            end
          else
            begin
              meta_nxt[i]       = datain[i];
              meta_state_nxt[i] = 1'b0;
            end
        end // for
    end

  always @( posedge clk )
    begin
      meta_state <= meta_state_nxt;
    end


// synthesis translate_on
`else
  (* ASYNC_REG = "TRUE" *) reg  [WIDTH-1:0] meta;
  (* ASYNC_REG = "TRUE" *) reg  [WIDTH-1:0] meta2;

  always @*
    begin
      meta_nxt = datain;
    end

`endif

  always @( posedge clk or negedge reset )
    begin
      if ( reset != 1'b1 )
        begin
          meta  <= {WIDTH{RESET_VALUE}};
          meta2 <= {WIDTH{RESET_VALUE}};
        end
      else
        begin
          meta  <= meta_nxt;
          meta2 <= meta;
        end
    end

  assign dataout_nxt = meta2;

  always @( posedge clk or negedge reset )
    begin
      if ( reset != 1'b1 )
        begin
          dataout_reg <= {WIDTH{RESET_VALUE}};
        end
      else
        begin
          dataout_reg <= dataout_nxt;
        end
    end

  assign dataout = dataout_reg;

endmodule // syncer_level
`default_nettype wire

`default_nettype none
module gtfmac_hwchk_syncer_reset
#(
  parameter RESET_PIPE_LEN = 3
 )
(
  input  wire clk,
  input  wire reset_async,
  output wire reset
);

  (* ASYNC_REG = "TRUE" *) reg  [RESET_PIPE_LEN-1:0] reset_pipe_retime;
  reg  reset_pipe_out;

// synthesis translate_off

  initial reset_pipe_retime  = {RESET_PIPE_LEN{1'b0}};
  initial reset_pipe_out     = 1'b0;

// synthesis translate_on

  always @(posedge clk or negedge reset_async)
    begin
      if (reset_async == 1'b0)
        begin
          reset_pipe_retime <= {RESET_PIPE_LEN{1'b0}};
          reset_pipe_out    <= 1'b0;
        end
      else
        begin
          reset_pipe_retime <= {reset_pipe_retime[RESET_PIPE_LEN-2:0], 1'b1};
          reset_pipe_out    <= reset_pipe_retime[RESET_PIPE_LEN-1];
        end
    end

  assign reset = reset_pipe_out;

endmodule
`default_nettype wire

`default_nettype none
module gtfmac_hwchk_tx_fcs (

  input  wire clk,
  input  wire reset,

  input  wire ctl_tx_add_fcs,
  input  wire ctl_tx_ignore_fcs,

  input  wire i_ena_passthrough,
  input  wire i_ena,
  input  wire i_sop,
  input  wire [64-1:0] i_dat,
  input  wire i_eop,
  input  wire [3-1:0] i_mty,
  input  wire i_err,
  input  wire i_poison,
  input  wire i_is_ctrl,

  output wire o_ena_passthrough,
  output wire o_ena,
  output wire o_sop,
  output wire [64-1:0] o_dat,
  output wire o_eop,
  output wire [3-1:0] o_mty,
  output wire o_err,
  output wire o_poison,
  output wire o_is_ctrl,

  output reg  o_crc_val,
  output reg  [31:0] o_crc,
  output reg  o_crc_bad,
  output reg  o_crc_err,
  output reg  o_crc_stomped
);

  localparam REMAINDER         = 32'h1cdf4421;
  localparam REMAINDER_STOMPED = 32'hffffffff;

  reg  [31:0] full_crc;
  reg  [31:0] full_crc_nxt;
  wire [31:0] new_full_crc;
  wire [31:0] full_crc_mod;
  wire [31:0] final_crc;

  reg  ena_passthrough_d1;
  reg  ena_d1;
  reg  sop_d1;
  reg  [64-1:0] dat_d1;
  reg  eop_d1;
  reg  [3-1:0] mty_d1;
  reg  err_d1;
  reg  poison_d1;
  reg  is_ctrl_d1;

  reg  ena_passthrough_d2;
  reg  ena_d2;
  reg  sop_d2;
  reg  [64-1:0] dat_d2;
  reg  eop_d2;
  reg  [3-1:0] mty_d2;
  reg  err_d2;
  reg  poison_d2;
  reg  is_ctrl_d2;

  reg  ena_passthrough_d3;
  reg  ena_d3;
  reg  sop_d3;
  reg  [64-1:0] dat_d3;
  reg  eop_d3;
  reg  [3-1:0] mty_d3;
  reg  err_d3;
  reg  poison_d3;
  reg  is_ctrl_d3;

  wire [64-1:0] loc_dat;
  wire loc_eop;
  wire loc_err; 
  wire loc_poison;
  wire loc_is_ctrl;
  wire [3-1:0] loc_mty;
  wire [64-1:0] added_data_d3;
  reg  [3-1:0] added_mty_d3;
  wire [31:0] spill_d3;
  wire spilled_d3;

  reg  [31:0] spill_d4;
  reg  spilled_d4;
  reg  [3-1:0] mty_spill_d4;
  reg  err_spill_d4;
  reg  poison_spill_d4;
  reg  eop_d4;


  reg  [64-1:0] i_dat_masked;

  always @*
    begin
      if (i_ena && i_eop)
        begin
          case (i_mty)
            3'd1    : i_dat_masked = {i_dat[64-1:8], 8'd0};
            3'd2    : i_dat_masked = {i_dat[64-1:16], 16'd0};
            3'd3    : i_dat_masked = {i_dat[64-1:24], 24'd0};
            3'd4    : i_dat_masked = {i_dat[64-1:32], 32'd0};
            3'd5    : i_dat_masked = {i_dat[64-1:40], 40'd0};
            3'd6    : i_dat_masked = {i_dat[64-1:48], 48'd0};
            3'd7    : i_dat_masked = {i_dat[64-1:56], 56'd0};
            default : i_dat_masked = i_dat;
          endcase
        end
      else
        begin
          i_dat_masked = i_dat;
        end
    end

  assign full_crc_mod = (i_ena && i_sop) ? {32{1'b1}} : full_crc;

  always @*
    begin
      if (i_ena)
        begin
          full_crc_nxt = new_full_crc;
        end
      else
        begin
          full_crc_nxt = full_crc;
        end
    end

  gtfmac_hwchk_crc32_gen i_CRC32_GEN (

    .data_in              (dat_swap(i_dat_masked)),
    .crc_in               (full_crc_mod),
    .crc_out              (new_full_crc)

  );  // i_CRC32_GEN




  gtfmac_hwchk_crc32_unroll_bytes i_CRC_UNROLL_BYTES (

    .clk                  (clk),
    .reset                (reset),
    .crc_in               (full_crc),
    .mty_in               (mty_d1),
    .crc_out              (final_crc)

  );  // i_CRC_UNROLL_BYTES

  wire [31:0] final_crc_mod;

  assign final_crc_mod = final_crc;

  gtfmac_hwchk_fcs_append i_TX_FCS_APPEND (

    .clk               (clk),

    .ctl_tx_add_fcs    (ctl_tx_add_fcs),

    .i_eop             (eop_d2),
    .i_dat             (dat_d2),
    .i_mty             (mty_d2),
    .i_crc             (final_crc_mod),
    .o_dat             (added_data_d3),
    .o_spill           (spill_d3),
    .o_spilled         (spilled_d3)

  );  // i_TX_FCS_APPEND

  assign loc_dat = (ctl_tx_add_fcs & spilled_d4) ? {spill_d4, 32'd0} :
                   added_data_d3;

  assign loc_mty = (ctl_tx_add_fcs & spilled_d4) ? mty_spill_d4 :
                   added_mty_d3;

  assign loc_eop = (ctl_tx_add_fcs & spilled_d4) ? 1'b1 :
                   (ctl_tx_add_fcs & spilled_d3) ? 1'b0 :
                   eop_d3;

  assign loc_err = (ctl_tx_add_fcs & spilled_d4) ? err_spill_d4 :
                   (ctl_tx_add_fcs & spilled_d3) ? 1'b0 :
                   err_d3;
                   
  assign loc_poison = (ctl_tx_add_fcs & spilled_d4) ? poison_spill_d4 :
                      (ctl_tx_add_fcs & spilled_d3) ? 1'b0 :
                      poison_d3;

  assign loc_is_ctrl = (ctl_tx_add_fcs & spilled_d4) ? 1'b0 : is_ctrl_d3;

  assign o_ena_passthrough = ena_passthrough_d3;
  assign o_ena             = ena_passthrough_d3 & (ena_d3 | spilled_d4);
  assign o_sop             = sop_d3;
  assign o_dat             = loc_dat;
  assign o_eop             = loc_eop;
  assign o_mty             = loc_mty;
  assign o_err             = loc_err;
  assign o_poison          = loc_poison;
  assign o_is_ctrl         = loc_is_ctrl;

  always @( posedge clk or negedge reset )
    begin
      if ( reset != 1'b1 )
        begin
          ena_passthrough_d1 <= 1'b0;
          ena_d1             <= 1'b0;
          is_ctrl_d1         <= 1'b1;

          ena_passthrough_d2 <= 1'b0;
          ena_d2             <= 1'b0;
          is_ctrl_d2         <= 1'b1;

          ena_passthrough_d3 <= 1'b0;
          ena_d3             <= 1'b0;
          is_ctrl_d3         <= 1'b1;

       end
      else
        begin
          ena_passthrough_d1 <= i_ena_passthrough;
          ena_d1             <= i_ena;
          is_ctrl_d1         <= i_is_ctrl;

          ena_passthrough_d2 <= ena_passthrough_d1;
          ena_d2             <= ena_d1;
          is_ctrl_d2         <= is_ctrl_d1;

          ena_passthrough_d3 <= ena_passthrough_d2;
          ena_d3             <= ena_d2;
          is_ctrl_d3         <= is_ctrl_d2;

        end
    end


  always @(posedge clk)
        begin
          sop_d1          <= i_sop;
          dat_d1          <= i_dat;
          eop_d1          <= i_eop;
          mty_d1          <= i_mty;
          err_d1          <= i_err;
          poison_d1       <= i_poison;

          sop_d2          <= sop_d1;
          dat_d2          <= dat_d1;
          eop_d2          <= eop_d1;
          mty_d2          <= mty_d1;
          err_d2          <= err_d1;
          poison_d2       <= poison_d1; 

          sop_d3          <= sop_d2;
          dat_d3          <= dat_d2;
          eop_d3          <= eop_d2;
          mty_d3          <= mty_d2;
          err_d3          <= err_d2;
          poison_d3       <= poison_d2;

        end


  always @( posedge clk or negedge reset )
    begin
      if ( reset != 1'b1 )
        begin
          full_crc         <= {32{1'b1}};

          spilled_d4       <= 1'b0;
          spill_d4         <= 32'd0;
          mty_spill_d4     <= 3'd0;
          err_spill_d4     <= 1'b0;
          poison_spill_d4  <= 1'b0;
          added_mty_d3     <= 3'd0;

          o_crc_val        <= 1'b0;
          o_crc            <= 32'd0;
          o_crc_err        <= 1'b0;
          o_crc_bad        <= 1'b0;
          o_crc_stomped    <= 1'b0;
        end
      else
        begin
          full_crc <= full_crc_nxt;

          if (ena_d3)
            begin
              spill_d4 <= spill_d3;
            end

          if (ena_passthrough_d3)
            begin
              spilled_d4   <= spilled_d3;
              mty_spill_d4 <= spilled_d3 ? mty_d3 + 3'd4 : mty_d3;
              err_spill_d4 <= err_d3;
              poison_spill_d4 <= poison_d3;
              eop_d4       <= eop_d3;
            end

          o_crc_val <= ena_d2 & eop_d2;

          if (ena_d2 && eop_d2)
            begin
              o_crc         <= final_crc;
              o_crc_err     <= (final_crc != REMAINDER) & ~ctl_tx_add_fcs & (~|err_d2);
              o_crc_bad     <= (final_crc != REMAINDER) & (final_crc != REMAINDER_STOMPED) & ~ctl_tx_add_fcs & ~ctl_tx_ignore_fcs;
              o_crc_stomped <= (final_crc == REMAINDER_STOMPED) & ~ctl_tx_add_fcs & ~ctl_tx_ignore_fcs;
              added_mty_d3  <= ctl_tx_add_fcs ? (mty_d2> 3'd3 ? mty_d2 - 3'd4 : 3'd0) : mty_d2;
            end
          else
            begin
              o_crc_err     <= 1'b0;
              o_crc_bad     <= 1'b0;
              o_crc_stomped <= 1'b0;
              added_mty_d3  <= 3'd0;
            end
        end
    end


  function [64-1:0] dat_swap ( input [64-1:0] d );
    integer i;
    for (i=0; i<64; i=i+1)
      begin
        dat_swap[i] = d[{i[15:3], ~i[2:0]}];
      end
  endfunction

endmodule  // tx_fcs
`default_nettype wire

`default_nettype none
module gtfmac_hwchk_fcs_append (

  input  wire clk,

  input  wire ctl_tx_add_fcs,

  input  wire i_eop,
  input  wire [64-1:0] i_dat,
  input  wire [3-1:0] i_mty,
  input  wire [31:0] i_crc,

  output reg  [64-1:0] o_dat,
  output reg  o_spilled,
  output reg  [31:0] o_spill
);

  wire [3-1:0] mty_m4 = i_mty-4;

  always @(posedge clk)
    begin
      o_dat <= i_dat;

      if (i_eop && ctl_tx_add_fcs)
        begin
          case (i_mty)
            3'd0:
              begin
                o_spill   <= i_crc;
                o_spilled <= 1'b1;
              end
            3'd1:
              begin
                o_spill    <= {i_crc[23:0], 8'h0};
                o_dat[7:0] <= i_crc[31:24];
                o_spilled  <= 1'b1;
              end
            3'd2:
              begin
                o_spill     <= {i_crc[15:0], 16'h0};
                o_dat[15:0] <= i_crc[31:16];
                o_spilled   <= 1'b1;
              end
            3'd3:
              begin
                o_spill     <= {i_crc[7:0], 24'h0};
                o_dat[23:0] <= i_crc[31:8];
                o_spilled   <= 1'b1;
              end
            default:
              begin
                o_spill     <= 32'd0;
                o_dat[{mty_m4, 3'b0}+:32] <= i_crc;
                o_spilled   <= 1'b0;
              end
          endcase
        end
      else
        begin
          o_spilled <= 1'b0;
          o_spill   <= 32'd0;
        end
    end

endmodule  // fcs_append
`default_nettype wire

`default_nettype none
module gtfmac_hwchk_crc32_gen #(
  parameter DATA_WIDTH = 64
) (

  input  wire [DATA_WIDTH-1:0] data_in,
  input  wire [31:0] crc_in,
  output wire [31:0] crc_out
);
  localparam [31:0] CRC_POLY = 32'b00000100110000010001110110110111 ;

  reg  [31:0] crc_var;
  integer i;

  always @*
    begin
      crc_var = crc_in;

      for (i=0; i<DATA_WIDTH; i=i+1)
        begin
          crc_var = {crc_var[30:0], 1'b0} ^ (CRC_POLY & {32{crc_var[31]^data_in[DATA_WIDTH-i-1]}});
        end
    end

  assign crc_out = crc_var;

endmodule  // crc32_gen
`default_nettype wire

`default_nettype none
module gtfmac_hwchk_crc32_unroll_bytes #(
  parameter [31:0] CRC_POLY = 32'b00000100110000010001110110110111
) (

  input  wire clk,
  input  wire reset,
  input  wire [31:0] crc_in,
  input  wire [3-1:0] mty_in,
  output reg  [31:0] crc_out
);

  wire [31:0] crc_o[8-1:0];

  always @( posedge clk or negedge reset )
    begin
      if ( reset != 1'b1 )
        begin
          crc_out <= 32'd0;
        end
      else
        begin
          crc_out <= crc_o[mty_in];
        end
    end

  gtfmac_hwchk_fcs_unroll #(
    .CRC_POLY   (CRC_POLY),
    .DATA_WIDTH (8*0)
  ) i_FCS_UNROLL_BYTES_0 (
    .crc_in     (crc_in),
    .crc_out    (crc_o[0])
  );

  gtfmac_hwchk_fcs_unroll #(
    .CRC_POLY   (CRC_POLY),
    .DATA_WIDTH (8*1)
  ) i_FCS_UNROLL_BYTES_1 (
    .crc_in     (crc_in),
    .crc_out    (crc_o[1])
  );

  gtfmac_hwchk_fcs_unroll #(
    .CRC_POLY   (CRC_POLY),
    .DATA_WIDTH (8*2)
  ) i_FCS_UNROLL_BYTES_2 (
    .crc_in     (crc_in),
    .crc_out    (crc_o[2])
  );

  gtfmac_hwchk_fcs_unroll #(
    .CRC_POLY   (CRC_POLY),
    .DATA_WIDTH (8*3)
  ) i_FCS_UNROLL_BYTES_3 (
    .crc_in     (crc_in),
    .crc_out    (crc_o[3])
  );

  gtfmac_hwchk_fcs_unroll #(
    .CRC_POLY   (CRC_POLY),
    .DATA_WIDTH (8*4)
  ) i_FCS_UNROLL_BYTES_4 (
    .crc_in     (crc_in),
    .crc_out    (crc_o[4])
  );

  gtfmac_hwchk_fcs_unroll #(
    .CRC_POLY   (CRC_POLY),
    .DATA_WIDTH (8*5)
  ) i_FCS_UNROLL_BYTES_5 (
    .crc_in     (crc_in),
    .crc_out    (crc_o[5])
  );

  gtfmac_hwchk_fcs_unroll #(
    .CRC_POLY   (CRC_POLY),
    .DATA_WIDTH (8*6)
  ) i_FCS_UNROLL_BYTES_6 (
    .crc_in     (crc_in),
    .crc_out    (crc_o[6])
  );

  gtfmac_hwchk_fcs_unroll #(
    .CRC_POLY   (CRC_POLY),
    .DATA_WIDTH (8*7)
  ) i_FCS_UNROLL_BYTES_7 (
    .crc_in     (crc_in),
    .crc_out    (crc_o[7])
  );

endmodule  // crc32_unroll_bytes
`default_nettype wire

`default_nettype none
module gtfmac_hwchk_fcs_unroll #(
  parameter DATA_WIDTH = 32,
  parameter [31:0] CRC_POLY = 32'b00000100110000010001110110110111
) (
  input  wire [31:0] crc_in,
  output reg  [31:0] crc_out
);

  always @(crc_in)
    begin :crc_loop
      reg [31:0] crc_var;    // Temporary variables used in the CRC calculation
      integer i;

      crc_var = crc_in;

      for (i=0; i<DATA_WIDTH; i=i+1)
        begin
          crc_var = {crc_var[0], crc_var[31:1]^(CRC_POLY[31:1]&{31{crc_var[0]}})};
        end

      crc_out[0] = ~crc_var[7];
      crc_out[1] = ~crc_var[6];
      crc_out[2] = ~crc_var[5];
      crc_out[3] = ~crc_var[4];
      crc_out[4] = ~crc_var[3];
      crc_out[5] = ~crc_var[2];
      crc_out[6] = ~crc_var[1];
      crc_out[7] = ~crc_var[0];
      crc_out[8] = ~crc_var[15];
      crc_out[9] = ~crc_var[14];
      crc_out[10] = ~crc_var[13];
      crc_out[11] = ~crc_var[12];
      crc_out[12] = ~crc_var[11];
      crc_out[13] = ~crc_var[10];
      crc_out[14] = ~crc_var[9];
      crc_out[15] = ~crc_var[8];
      crc_out[16] = ~crc_var[23];
      crc_out[17] = ~crc_var[22];
      crc_out[18] = ~crc_var[21];
      crc_out[19] = ~crc_var[20];
      crc_out[20] = ~crc_var[19];
      crc_out[21] = ~crc_var[18];
      crc_out[22] = ~crc_var[17];
      crc_out[23] = ~crc_var[16];
      crc_out[24] = ~crc_var[31];
      crc_out[25] = ~crc_var[30];
      crc_out[26] = ~crc_var[29];
      crc_out[27] = ~crc_var[28];
      crc_out[28] = ~crc_var[27];
      crc_out[29] = ~crc_var[26];
      crc_out[30] = ~crc_var[25];
      crc_out[31] = ~crc_var[24];
    end

endmodule
`default_nettype wire

