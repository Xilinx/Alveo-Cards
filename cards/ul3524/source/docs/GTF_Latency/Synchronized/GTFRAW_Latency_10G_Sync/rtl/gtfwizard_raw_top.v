/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

  
`timescale 1fs/1fs
module gtfwizard_raw_top0 # (
    parameter           COMMON_CLOCK     = "true",
    parameter           ONE_SECOND_COUNT = 28'd200_000_000,
    parameter integer   NUM_CHANNEL      = 1,
    parameter           SIMULATION       = "false"
)
(
    // exdes IOs
    output  wire  [NUM_CHANNEL-1:0]  gtf_ch_gtftxn          ,
    output  wire  [NUM_CHANNEL-1:0]  gtf_ch_gtftxp          ,
    input   wire  [NUM_CHANNEL-1:0]  gtf_ch_gtfrxn          ,
    input   wire  [NUM_CHANNEL-1:0]  gtf_ch_gtfrxp          ,

    input   wire                     SYNCE_CLK11_LVDS_P     ,
    input   wire                     SYNCE_CLK11_LVDS_N     ,

    input   wire                     CLK12_LVDS_300_P       ,
    input   wire                     CLK12_LVDS_300_N       ,

    input   wire                     CLK13_LVDS_300_P       ,
    input   wire                     CLK13_LVDS_300_N       
); 


// ---------------------------------------------------------------
//
//  50/100Mhz System Clock & Reset
//
// ---------------------------------------------------------------
wire sys_clk_100;
wire sys_rst_100;
wire sys_clk_50 ;
wire sys_rst_50 ;

clk_reset clk_reset (
    .sys_clk_300_p ( CLK13_LVDS_300_P ),
    .sys_clk_300_n ( CLK13_LVDS_300_N ),
    .sys_clk_100   ( sys_clk_100      ),
    .sys_rst_100   ( sys_rst_100      ),
    .sys_clk_50    ( sys_clk_50       ),
    .sys_rst_50    ( sys_rst_50       )
);

wire sys_if_clk  = sys_clk_100;
wire sys_if_rstn = ~sys_rst_100;


//------------------------------------------------------------------------------
//
//    JTAG Interface for HW Manager 
//
//------------------------------------------------------------------------------
wire            axi_clk      = sys_if_clk  ;
wire            axi_rstn     = sys_if_rstn ;

// Master JTAG AXI I/F to AXI Interconnect...
wire [31:0]     jtag_axil_araddr    ;
wire            jtag_axil_arvalid   ;
wire            jtag_axil_rready    ;
wire [31:0]     jtag_axil_awaddr    ;
wire [2:0]      jtag_axil_awprot    ;
wire [2:0]      jtag_axil_arprot    ;
wire [3:0]      jtag_axil_wstrb     ;
wire            jtag_axil_awvalid   ;
wire [31:0]     jtag_axil_wdata     ;
wire            jtag_axil_wvalid    ;
wire            jtag_axil_bready    ;
wire            jtag_axil_arready   ;
wire [31:0]     jtag_axil_rdata     ;
wire [1:0]      jtag_axil_rresp     ;
wire            jtag_axil_rvalid    ;
wire            jtag_axil_awready   ;
wire            jtag_axil_wready    ;
wire            jtag_axil_bvalid    ;
wire [1:0]      jtag_axil_bresp     ;

jtag_axi_0 u_jtag_axi_0 (
    // Common AXI I/F Clock and Reset
    .aclk             ( axi_clk           ),   // input wire aclk
    .aresetn          ( axi_rstn          ),   // input wire aresetn

    // JTAG AXI I/F to AXI Interconnect
    .m_axi_awaddr     ( jtag_axil_awaddr  ),   // output wire [31 : 0] 
    .m_axi_awprot     ( jtag_axil_awprot  ),   // output wire [2 : 0] 
    .m_axi_awvalid    ( jtag_axil_awvalid ),   // output wire 
    .m_axi_awready    ( jtag_axil_awready ),   // input  wire 
    .m_axi_wdata      ( jtag_axil_wdata   ),   // output wire [31 : 0] 
    .m_axi_wstrb      ( jtag_axil_wstrb   ),   // output wire [3 : 0] 
    .m_axi_wvalid     ( jtag_axil_wvalid  ),   // output wire 
    .m_axi_wready     ( jtag_axil_wready  ),   // input  wire 
    .m_axi_bresp      ( jtag_axil_bresp   ),   // input  wire [1 : 0] 
    .m_axi_bvalid     ( jtag_axil_bvalid  ),   // input  wire 
    .m_axi_bready     ( jtag_axil_bready  ),   // output wire 
    .m_axi_araddr     ( jtag_axil_araddr  ),   // output wire [31 : 0] 
    .m_axi_arprot     ( jtag_axil_arprot  ),   // output wire [2 : 0] 
    .m_axi_arvalid    ( jtag_axil_arvalid ),   // output wire 
    .m_axi_arready    ( jtag_axil_arready ),   // input  wire 
    .m_axi_rdata      ( jtag_axil_rdata   ),   // input  wire [31 : 0] 
    .m_axi_rresp      ( jtag_axil_rresp   ),   // input  wire [1 : 0] 
    .m_axi_rvalid     ( jtag_axil_rvalid  ),   // input  wire 
    .m_axi_rready     ( jtag_axil_rready  )    // output wire 
);


wire                   hb_gtwiz_reset_all_in       ;
wire [NUM_CHANNEL-1:0] hb_gtf_ch_txdp_reset_in     ;
wire [NUM_CHANNEL-1:0] hb_gtf_ch_rxdp_reset_in     ;

reg                    link_stable                 ;  // Set when link status is sustained
wire [NUM_CHANNEL-1:0] link_status_out             ;  // Instantaineous Link Status signal
wire [NUM_CHANNEL-1:0] link_down_latched_out       ;  // Set when link status fails
reg  [NUM_CHANNEL-1:0] link_down_latched_reset_in  ;  // Set automatically when link stable is attained
reg  [10:0]            link_up_ctr                 ;  // Counter used to determine link stable status


wire [0:0]  IO_CONTROL_GTWIZ_RESET_ALL    ;
wire [0:0]  IO_CONTROL_GTF_CH_TXDP_RESET  ;
wire [0:0]  IO_CONTROL_GTF_CH_RXDP_RESET  ;
wire [0:0]  IO_CONTROL_LAT_ENABLE         ;
wire [0:0]  IO_CONTROL_LAT_POP            ;
wire [0:0]  IO_CONTROL_LAT_CLEAR          ;
wire [0:0]  IO_CONTROL_ERR_INJ_START      ;
wire [15:0] IO_ERR_INJ_COUNT_VALUE        ;
wire [15:0] IO_ERR_INJ_DELAY_VALUE        ;
wire [15:0] IO_LAT_PKT_CNT_VALUE          ;
wire [0:0]  IO_STATUS_LINK_STATUS         = link_status_out[0]    ;
wire [0:0]  IO_STATUS_LINK_STABLE         = link_stable           ;
wire [0:0]  IO_STATUS_LINK_DOWN_LATCHED   = link_down_latched_out ;
wire [15:0] IO_ERR_INJ_REMAIN_VALUE       ;
wire [15:0] IO_LAT_PENDING_VALUE          ;
wire [15:0] IO_LAT_TX_TIME_VALUE          ;
wire [15:0] IO_LAT_RX_TIME_VALUE          ;
wire [31:0] IO_LAT_DELTA_ACC_VALUE        ;
wire [31:0] IO_LAT_DELTA_IDX_VALUE        ;
wire [15:0] IO_LAT_DELTA_MAX_VALUE        ;
wire [15:0] IO_LAT_DELTA_MIN_VALUE        ;
wire [15:0] IO_LAT_DELTA_ADJ_VALUE        ;

reg_latency_raw_top reg_latency_raw_top (
    .aclk                          ( axi_clk                     ),
    .aresetn                       ( axi_rstn                    ),
    .m_axi_awaddr                  ( jtag_axil_awaddr            ),
    .m_axi_awprot                  ( jtag_axil_awprot            ),
    .m_axi_awvalid                 ( jtag_axil_awvalid           ),
    .m_axi_awready                 ( jtag_axil_awready           ),
    .m_axi_wdata                   ( jtag_axil_wdata             ),
    .m_axi_wstrb                   ( jtag_axil_wstrb             ),
    .m_axi_wvalid                  ( jtag_axil_wvalid            ),
    .m_axi_wready                  ( jtag_axil_wready            ),
    .m_axi_bresp                   ( jtag_axil_bresp             ),
    .m_axi_bvalid                  ( jtag_axil_bvalid            ),
    .m_axi_bready                  ( jtag_axil_bready            ),
    .m_axi_araddr                  ( jtag_axil_araddr            ),
    .m_axi_arprot                  ( jtag_axil_arprot            ),
    .m_axi_arvalid                 ( jtag_axil_arvalid           ),
    .m_axi_arready                 ( jtag_axil_arready           ),
    .m_axi_rdata                   ( jtag_axil_rdata             ),
    .m_axi_rresp                   ( jtag_axil_rresp             ),
    .m_axi_rvalid                  ( jtag_axil_rvalid            ),
    .m_axi_rready                  ( jtag_axil_rready            ),

    .IO_STATUS_LINK_STATUS         ( IO_STATUS_LINK_STATUS       ),
    .IO_STATUS_LINK_STABLE         ( IO_STATUS_LINK_STABLE       ),
    .IO_STATUS_LINK_DOWN_LATCHED   ( IO_STATUS_LINK_DOWN_LATCHED ),

    .IO_CONTROL_GTWIZ_RESET_ALL    ( hb_gtwiz_reset_all_in       ),
    .IO_CONTROL_GTF_CH_TXDP_RESET  ( hb_gtf_ch_txdp_reset_in     ),
    .IO_CONTROL_GTF_CH_RXDP_RESET  ( hb_gtf_ch_rxdp_reset_in     ),

    .IO_CONTROL_LAT_ENABLE         ( IO_CONTROL_LAT_ENABLE       ),
    .IO_CONTROL_LAT_POP            ( IO_CONTROL_LAT_POP          ),
    .IO_CONTROL_LAT_CLEAR          ( IO_CONTROL_LAT_CLEAR        ),
    .IO_CONTROL_ERR_INJ_START      ( IO_CONTROL_ERR_INJ_START    ),

    .IO_ERR_INJ_COUNT_VALUE        ( IO_ERR_INJ_COUNT_VALUE      ),
    .IO_ERR_INJ_DELAY_VALUE        ( IO_ERR_INJ_DELAY_VALUE      ),
    .IO_ERR_INJ_REMAIN_VALUE       ( IO_ERR_INJ_REMAIN_VALUE     ),

    .IO_LAT_PKT_CNT_VALUE          ( IO_LAT_PKT_CNT_VALUE        ),
    .IO_LAT_PENDING_VALUE          ( IO_LAT_PENDING_VALUE        ),

    .IO_LAT_TX_TIME_VALUE          ( IO_LAT_TX_TIME_VALUE        ),
    .IO_LAT_RX_TIME_VALUE          ( IO_LAT_RX_TIME_VALUE        ),
    .IO_LAT_DELTA_ACC_VALUE        ( IO_LAT_DELTA_ACC_VALUE      ),
    .IO_LAT_DELTA_IDX_VALUE        ( IO_LAT_DELTA_IDX_VALUE      ),
    .IO_LAT_DELTA_MAX_VALUE        ( IO_LAT_DELTA_MAX_VALUE      ),
    .IO_LAT_DELTA_MIN_VALUE        ( IO_LAT_DELTA_MIN_VALUE      ),
    .IO_LAT_DELTA_ADJ_VALUE        ( IO_LAT_DELTA_ADJ_VALUE      )
);
    
// ---------------------------------------------------------------
//
//  GTF Instance...
//
// ---------------------------------------------------------------

wire                   clk_wiz_locked_out      ; //  output status
wire [NUM_CHANNEL-1:0] gtwiz_reset_tx_done_out ; //  output status
wire [NUM_CHANNEL-1:0] gtwiz_reset_rx_done_out ; //  output status
wire                   gtf_cm_qpll0_lock       ; //  output status


// clock and reset sources for latency logic....
wire            tx_clk       ;
wire            tx_rstn      ;
wire            rx_clk       ;
wire            rx_rstn      ;
wire            lat_clk      ;
wire            lat_rstn     ;

// signals used for latency event triggers...
wire            pattern_sent ;
wire            pattern_rcvd ;

wire [31:0]     rx_prbs_data_in_0_ila     ;
wire [15:0]     rx_prbs_data_in_sel_1_ila ;
wire [15:0]     rx_prbs_data_in_sel_0_ila ;
wire [15:0]     rx_prbs_prbs_reg_ila      ;
wire            rx_prbs_prbs_error_ila    ;
wire [15:0]     rx_prbs_data_in_tx_ila    ;
  
    
gtfwizard_raw_example_top # (
    .SIMULATION   ( SIMULATION   ),
    .COMMON_CLOCK ( COMMON_CLOCK ),
    .NUM_CHANNEL  ( NUM_CHANNEL  )
) u_gtfwizard_raw_example_top (
    .dbg_tx_clk                        ( tx_clk                         ),
    .dbg_tx_rstn                       ( tx_rstn                        ),
    .dbg_rx_clk                        ( rx_clk                         ),
    .dbg_rx_rstn                       ( rx_rstn                        ),
    .dbg_lat_clk                       ( lat_clk                        ),
    .dbg_lat_rstn                      ( lat_rstn                       ),
    .dbg_pattern_sent                  ( pattern_sent                   ),
    .dbg_pattern_rcvd                  ( pattern_rcvd                   ),
                                                                                        
    .error_inj_en                      ( IO_CONTROL_ERR_INJ_START       ),
    .error_inj_count                   ( IO_ERR_INJ_COUNT_VALUE         ),
    .error_inj_remain                  ( IO_ERR_INJ_REMAIN_VALUE        ),
    .error_inj_delay                   ( IO_ERR_INJ_DELAY_VALUE         ),
                                                                        
    .rx_prbs_data_in_0_ila             ( rx_prbs_data_in_0_ila          ),
    .rx_prbs_data_in_sel_1_ila         ( rx_prbs_data_in_sel_1_ila      ),
    .rx_prbs_data_in_sel_0_ila         ( rx_prbs_data_in_sel_0_ila      ),
    .rx_prbs_prbs_reg_ila              ( rx_prbs_prbs_reg_ila           ),
    .rx_prbs_prbs_error_ila            ( rx_prbs_prbs_error_ila         ),
    .rx_prbs_data_in_tx_ila            ( rx_prbs_data_in_tx_ila         ),

    .gtf_ch_gtftxn                     ( gtf_ch_gtftxn                  ),
    .gtf_ch_gtftxp                     ( gtf_ch_gtftxp                  ),
    .gtf_ch_gtfrxn                     ( gtf_ch_gtfrxn                  ),
    .gtf_ch_gtfrxp                     ( gtf_ch_gtfrxp                  ),

    .refclk_p                          ( SYNCE_CLK11_LVDS_P             ),
    .refclk_n                          ( SYNCE_CLK11_LVDS_N             ),

    .hb_gtwiz_reset_clk_freerun_p_in   ( CLK12_LVDS_300_P               ),
    .hb_gtwiz_reset_clk_freerun_n_in   ( CLK12_LVDS_300_N               ),

    .hb_gtwiz_reset_all_in             ( hb_gtwiz_reset_all_in          ),
    .hb_gtf_ch_txdp_reset_in           ( hb_gtf_ch_txdp_reset_in        ),
    .hb_gtf_ch_rxdp_reset_in           ( hb_gtf_ch_rxdp_reset_in        ),
                                                                    
    .clk_wiz_locked_out                ( clk_wiz_locked_out             ),
    .gtwiz_reset_tx_done_out           ( gtwiz_reset_tx_done_out        ),
    .gtwiz_reset_rx_done_out           ( gtwiz_reset_rx_done_out        ),
    .gtf_cm_qpll0_lock                 ( gtf_cm_qpll0_lock              ),
                                                                    
    .link_down_latched_reset_in        ( link_down_latched_reset_in     ),
    .link_status_out                   ( link_status_out                ),
    .link_down_latched_out             ( link_down_latched_out          )
);


// ---------------------------------------------------------------
//
//  Link Status Logic....
//
// ---------------------------------------------------------------

// Create a basic stable link monitor which is set after 2048 consecutive cycles of link up and is reset after any link loss
always @(posedge sys_clk_100) 
begin
    if (sys_rst_100) begin
        link_up_ctr <= 'h0;
        link_stable <= 'h0;
    end else if (link_status_out[0] == 'h0) begin
        link_up_ctr <= 'h0;
        link_stable <= 'h0;
    end else if (link_status_out[0] === 'h1) begin
        if (&link_up_ctr)
            link_stable <= 'h1;
        else
            link_up_ctr <= link_up_ctr + 1;
    end
end

reg link_stable_0;
always @(posedge sys_clk_100) 
begin
    link_stable_0 <= link_stable;
end

reg [7:0] link_stable_dly;
always @(posedge sys_clk_100) 
begin
    link_stable_dly <= {link_stable_dly[6:0], ~link_stable_0 & link_stable};
end

always @(posedge sys_clk_100) 
begin
    if (sys_rst_100) 
        link_down_latched_reset_in <= 'h0;
    else
        link_down_latched_reset_in <= |link_stable_dly;
end



// ---------------------------------------------------------------
//
//  Latency Measurment Logic....
//
// ---------------------------------------------------------------

// Latency ILA   
localparam TIMER_WIDTH = 16;                                       
wire [TIMER_WIDTH-1:0]     lat_mon_sent_time_ila      ;
wire [TIMER_WIDTH-1:0]     lat_mon_rcvd_time_ila      ;
wire [TIMER_WIDTH-1:0]     lat_mon_delta_time_ila     ;
wire                       lat_mon_send_event_ila     ;
wire                       lat_mon_rcv_event_ila      ;
wire [31:0]                lat_mon_delta_time_idx_ila ;

gtfmac_vnc_latency gtfmac_vnc_latency (
    // AXI I/F to JTAG 
    .axi_clk                    ( axi_clk                    ),
    .axi_rstn                   ( axi_rstn                   ),
                                
    // Clock and resets from respective),
    .tx_clk                     ( tx_clk                     ),
    .tx_rstn                    ( tx_rstn                    ),
                                                             
    .rx_clk                     ( rx_clk                     ),
    .rx_rstn                    ( rx_rstn                    ),
                                                             
    .lat_clk                    ( lat_clk                    ),
    .lat_rstn                   ( lat_rstn                   ),
                                                             
    .pattern_sent               ( pattern_sent               ),
    .pattern_rcvd               ( pattern_rcvd               ),
                                                             
    .go                         ( IO_CONTROL_LAT_ENABLE      ),
    .pop                        ( IO_CONTROL_LAT_POP         ),
    .clear                      ( IO_CONTROL_LAT_CLEAR       ),
    .lat_pkt_cnt                ( IO_LAT_PKT_CNT_VALUE       ),
                                                             
    .full                       ( IO_STATUS_LAT_FULL         ),
    .datav                      ( IO_LAT_PENDING_VALUE       ),
    .time_rdy                   (                            ),
    .tx_time                    ( IO_LAT_TX_TIME_VALUE       ),
    .rx_time                    ( IO_LAT_RX_TIME_VALUE       ),
                                                             
    .delta_time_accu            ( IO_LAT_DELTA_ACC_VALUE     ),
    .delta_time_idx             ( IO_LAT_DELTA_IDX_VALUE     ),
    .delta_time_max             ( IO_LAT_DELTA_MAX_VALUE     ),
    .delta_time_min             ( IO_LAT_DELTA_MIN_VALUE     ),
    .delta_adj_factor           ( IO_LAT_DELTA_ADJ_VALUE     ),
    .delta_done_sync            ( IO_STATUS_LAT_DONE         ),

    .lat_mon_sent_time_ila      ( lat_mon_sent_time_ila      ),
    .lat_mon_rcvd_time_ila      ( lat_mon_rcvd_time_ila      ),
    .lat_mon_delta_time_ila     ( lat_mon_delta_time_ila     ),
    .lat_mon_send_event_ila     ( lat_mon_send_event_ila     ),
    .lat_mon_rcv_event_ila      ( lat_mon_rcv_event_ila      ),
    .lat_mon_delta_time_idx_ila ( lat_mon_delta_time_idx_ila )
);


// ---------------------------------------------------------------
//
//  ILA for status...
//
// ---------------------------------------------------------------

generate
if (SIMULATION == "false" ) begin
    lat_mon_ila lat_mon_ila (
        .clk     ( rx_clk                     ),
        .probe0  ( rx_prbs_data_in_0_ila      ), // 32
        .probe1  ( rx_prbs_data_in_sel_1_ila  ), // 16
        .probe2  ( rx_prbs_data_in_sel_0_ila  ), // 16
        .probe3  ( rx_prbs_prbs_reg_ila       ), // 16
        .probe4  ( rx_prbs_prbs_error_ila     ), // 1
        .probe5  ( rx_prbs_data_in_tx_ila     ), // 16
        .probe6  ( lat_mon_sent_time_ila      ), // 16
        .probe7  ( lat_mon_rcvd_time_ila      ), // 16
        .probe8  ( lat_mon_delta_time_ila     ), // 16
        .probe9  ( lat_mon_send_event_ila     ), // 1
        .probe10 ( lat_mon_rcv_event_ila      ), // 1
        .probe11 ( 'h0                        )  // 32
    );
end
endgenerate

// ---------------------------------------------------------------
//
//  System VIO for status...
//
// ---------------------------------------------------------------

generate
if (SIMULATION == "false" ) begin
    vio_system vio_system_0 (
        .clk        ( sys_clk_100                   ),
        .probe_in0  ( hb_gtwiz_reset_all_in         ),
        .probe_in1  ( hb_gtf_ch_txdp_reset_in       ),
        .probe_in2  ( hb_gtf_ch_rxdp_reset_in       ),
        .probe_in3  ( link_status_out[0]            ),
        .probe_in4  ( link_down_latched_out[0]      ),
        .probe_in5  ( link_down_latched_reset_in[0] ),
        .probe_in6  ( 'h0 ),
        .probe_in7  ( 'h0 )
    );
end
endgenerate

endmodule

