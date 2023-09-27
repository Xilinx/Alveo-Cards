/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/


module gtfmac_vnc_top # (
    parameter   SIMULATION         = "false",
    parameter   ONE_SECOND_COUNT   = 28'd200_000_000
)
(

    // exdes IOs
    output  wire                gtf_ch_gtftxn,
    output  wire                gtf_ch_gtftxp,
    input   wire                gtf_ch_gtfrxn,
    input   wire                gtf_ch_gtfrxp,

    input   wire                refclk_p,
    input   wire                refclk_n
	
);

	
////////////////////////////////////////////
// VIO
////////////////////////////////////////////
// Only include VIO for H/W build, not simulation

	// VIO outputs
    wire			hb_gtwiz_reset_all_in;
    wire			link_down_latched_reset_in;
	
	// VIO inputs
    wire			link_status_out;
    wire			link_down_latched_out;
    wire			link_maintained;

    wire			gtf_ch_rxsyncdone;
    wire			gtf_ch_txsyncdone;
    wire			pass;
    wire			state_check;
    wire			wa_complete_flg;


//
    wire            tx_axis_clk;
    wire            tx_axis_rst;

    wire            rx_axis_clk;
    wire            rx_axis_rst;

    wire            sys_clk;
    wire            sys_rst;

    wire            lat_clk;
    wire            lat_rstn;

    wire            f_clk;
    wire            f_rst;

    wire            stat_gtf_rx_internal_local_fault;
    wire            stat_gtf_rx_local_fault;
    wire            stat_gtf_rx_received_local_fault;
    wire            stat_gtf_rx_remote_fault;

    wire            vnc_gtf_ch_gttxreset;
    wire            vnc_gtf_ch_txpmareset;
    wire            vnc_gtf_ch_txpcsreset;
    wire            vnc_gtf_ch_gtrxreset;
    wire            vnc_gtf_ch_rxpmareset;
    wire            vnc_gtf_ch_rxdfelpmreset;
    wire            vnc_gtf_ch_eyescanreset;
    wire            vnc_gtf_ch_rxpcsreset;
    wire            vnc_gtf_cm_qpll0reset;

    wire            stat_gtf_rx_block_lock;
    wire            gtf_rx_bitslip;
    wire            gtf_rx_disable_bitslip;
    wire            gtf_rx_slip_pma;
    wire            gtf_rx_slip_pma_rdy;
    wire            gtf_rx_gb_seq_sync;
    wire            gtf_rx_slip_one_ui;

    wire            tx_axis_tready;
    wire            tx_axis_tvalid;
    wire [63:0]     tx_axis_tdata;
    wire [7:0]      tx_axis_tlast;
    wire [7:0]      tx_axis_tpre;
    wire            tx_axis_terr;
    wire [4:0]      tx_axis_tterm;
    wire [1:0]      tx_axis_tsof;
    wire            tx_axis_tpoison;
    wire            tx_axis_tcan_start;
    wire            tx_ptp_sop;
    wire            tx_ptp_sop_pos;
    wire            tx_gb_seq_start;
    wire            tx_unfout;

    wire            rx_axis_tvalid;
    wire [63:0]     rx_axis_tdata;
    wire [7:0]      rx_axis_tlast;
    wire [7:0]      rx_axis_tpre;
    wire            rx_axis_terr;
    wire [4:0]      rx_axis_tterm;
    wire [1:0]      rx_axis_tsof;

    wire    [31:0]      vnc_axil_araddr;
    wire                vnc_axil_arvalid;
    wire                vnc_axil_arready;
    wire    [31:0]      vnc_axil_rdata;
    wire    [1:0]       vnc_axil_rresp;
    wire                vnc_axil_rvalid;
    wire                vnc_axil_rready;
    wire    [31:0]      vnc_axil_awaddr;
    wire                vnc_axil_awvalid;
    wire                vnc_axil_awready;
    wire    [31:0]      vnc_axil_wdata;
    wire                vnc_axil_wvalid;
    wire                vnc_axil_wready;
    wire                vnc_axil_bvalid;
    wire    [1:0]       vnc_axil_bresp;
    wire                vnc_axil_bready;

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

    wire    [31:0]      gtf_axil_araddr;
    wire                gtf_axil_arvalid;
    wire                gtf_axil_arready;
    wire    [31:0]      gtf_axil_rdata;
    wire    [1:0]       gtf_axil_rresp;
    wire                gtf_axil_rvalid;
    wire                gtf_axil_rready;
    wire    [31:0]      gtf_axil_awaddr;
    wire                gtf_axil_awvalid;
    wire                gtf_axil_awready;
    wire    [31:0]      gtf_axil_wdata;
    wire                gtf_axil_wvalid;
    wire                gtf_axil_wready;
    wire                gtf_axil_bvalid;
    wire    [1:0]       gtf_axil_bresp;
    wire                gtf_axil_bready;

    wire    [2:0]       gtf_axil_arprot;
    wire    [2:0]       gtf_axil_awprot;
    wire    [3:0]       gtf_axil_wstrb;

    wire                axi_aclk;
    wire                axi_aresetn;

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
    
    wire                vnc_rx_custom_preamble_en; //EG
    
    // Latency monitor ILA signals
    wire    [15:0]      lat_mon_sent_time_ila;              
    wire    [15:0]      lat_mon_rcvd_time_ila;              
    wire    [15:0]      lat_mon_delta_time_ila;             
    wire                lat_mon_send_event_ila;             
    wire                lat_mon_rcv_event_ila;
    wire    [31:0]      lat_mon_delta_time_idx_ila;         

generate
if (SIMULATION == "false") begin
    vio_1 vio_top_level (
        .clk          ( axi_aclk					),
        
        .probe_in0    ( link_status_out				),
        .probe_in1    ( link_down_latched_out		),
        .probe_in2    ( link_maintained				),
        .probe_in3    ( gtf_ch_rxsyncdone			),
        .probe_in4    ( gtf_ch_txsyncdone			),
        .probe_in5    ( pass						),
        .probe_in6    ( state_check ),
        .probe_in7    ( wa_complete_flg				),
        .probe_in8    ( state_check					),
        
        .probe_out0   ( hb_gtwiz_reset_all_in		),
        .probe_out1   ( link_down_latched_reset_in	)
    );
end
endgenerate

    jtag_axi_0 u_jtag_axi_0 (
      .aclk             (axi_aclk),         // input wire aclk
      .aresetn          (axi_aresetn),      // input wire aresetn
      .m_axi_awaddr     (s_axil_awaddr),    // output wire [31 : 0] m_axi_awaddr
      .m_axi_awprot     (s_axil_awprot),    // output wire [2 : 0] m_axi_awprot
      .m_axi_awvalid    (s_axil_awvalid),   // output wire m_axi_awvalid
      .m_axi_awready    (s_axil_awready),   // input wire m_axi_awready
      .m_axi_wdata      (s_axil_wdata),     // output wire [31 : 0] m_axi_wdata
      .m_axi_wstrb      (s_axil_wstrb),     // output wire [3 : 0] m_axi_wstrb
      .m_axi_wvalid     (s_axil_wvalid),    // output wire m_axi_wvalid
      .m_axi_wready     (s_axil_wready),    // input wire m_axi_wready
      .m_axi_bresp      (s_axil_bresp),     // input wire [1 : 0] m_axi_bresp
      .m_axi_bvalid     (s_axil_bvalid),    // input wire m_axi_bvalid
      .m_axi_bready     (s_axil_bready),    // output wire m_axi_bready
      .m_axi_araddr     (s_axil_araddr),    // output wire [31 : 0] m_axi_araddr
      .m_axi_arprot     (s_axil_arprot),    // output wire [2 : 0] m_axi_arprot
      .m_axi_arvalid    (s_axil_arvalid),   // output wire m_axi_arvalid
      .m_axi_arready    (s_axil_arready),   // input wire m_axi_arready
      .m_axi_rdata      (s_axil_rdata),     // input wire [31 : 0] m_axi_rdata
      .m_axi_rresp      (s_axil_rresp),     // input wire [1 : 0] m_axi_rresp
      .m_axi_rvalid     (s_axil_rvalid),    // input wire m_axi_rvalid
      .m_axi_rready     (s_axil_rready)     // output wire m_axi_rready
    );


    axil_ctrl i_axil_ctrl (

        .ACLK_0                             (axi_aclk),
        .ARESETN_0                          (axi_aresetn),

        .M00_AXI_0_araddr                   (vnc_axil_araddr),
        .M00_AXI_0_arprot                   (),
        .M00_AXI_0_arready                  (vnc_axil_arready),
        .M00_AXI_0_arvalid                  (vnc_axil_arvalid),
        .M00_AXI_0_awaddr                   (vnc_axil_awaddr),
        .M00_AXI_0_awprot                   (),
        .M00_AXI_0_awready                  (vnc_axil_awready),
        .M00_AXI_0_awvalid                  (vnc_axil_awvalid),
        .M00_AXI_0_bready                   (vnc_axil_bready),
        .M00_AXI_0_bresp                    (vnc_axil_bresp),
        .M00_AXI_0_bvalid                   (vnc_axil_bvalid),
        .M00_AXI_0_rdata                    (vnc_axil_rdata),
        .M00_AXI_0_rready                   (vnc_axil_rready),
        .M00_AXI_0_rresp                    (vnc_axil_rresp),
        .M00_AXI_0_rvalid                   (vnc_axil_rvalid),
        .M00_AXI_0_wdata                    (vnc_axil_wdata),
        .M00_AXI_0_wready                   (vnc_axil_wready),
        .M00_AXI_0_wstrb                    (),
        .M00_AXI_0_wvalid                   (vnc_axil_wvalid),

        .M01_AXI_0_araddr                   (gtf_axil_araddr),
        .M01_AXI_0_arprot                   (gtf_axil_arprot),
        .M01_AXI_0_arready                  (gtf_axil_arready),
        .M01_AXI_0_arvalid                  (gtf_axil_arvalid),
        .M01_AXI_0_awaddr                   (gtf_axil_awaddr),
        .M01_AXI_0_awprot                   (gtf_axil_awprot),
        .M01_AXI_0_awready                  (gtf_axil_awready),
        .M01_AXI_0_awvalid                  (gtf_axil_awvalid),
        .M01_AXI_0_bready                   (gtf_axil_bready),
        .M01_AXI_0_bresp                    (gtf_axil_bresp),
        .M01_AXI_0_bvalid                   (gtf_axil_bvalid),
        .M01_AXI_0_rdata                    (gtf_axil_rdata),
        .M01_AXI_0_rready                   (gtf_axil_rready),
        .M01_AXI_0_rresp                    (gtf_axil_rresp),
        .M01_AXI_0_rvalid                   (gtf_axil_rvalid),
        .M01_AXI_0_wdata                    (gtf_axil_wdata),
        .M01_AXI_0_wready                   (gtf_axil_wready),
        .M01_AXI_0_wstrb                    (gtf_axil_wstrb),
        .M01_AXI_0_wvalid                   (gtf_axil_wvalid),

        .M02_AXI_0_araddr                   (lat_axil_araddr),
        .M02_AXI_0_arprot                   (),
        .M02_AXI_0_arready                  (lat_axil_arready),
        .M02_AXI_0_arvalid                  (lat_axil_arvalid),
        .M02_AXI_0_awaddr                   (lat_axil_awaddr),
        .M02_AXI_0_awprot                   (),
        .M02_AXI_0_awready                  (lat_axil_awready),
        .M02_AXI_0_awvalid                  (lat_axil_awvalid),
        .M02_AXI_0_bready                   (lat_axil_bready),
        .M02_AXI_0_bresp                    (lat_axil_bresp),
        .M02_AXI_0_bvalid                   (lat_axil_bvalid),
        .M02_AXI_0_rdata                    (lat_axil_rdata),
        .M02_AXI_0_rready                   (lat_axil_rready),
        .M02_AXI_0_rresp                    (lat_axil_rresp),
        .M02_AXI_0_rvalid                   (lat_axil_rvalid),
        .M02_AXI_0_wdata                    (lat_axil_wdata),
        .M02_AXI_0_wready                   (lat_axil_wready),
        .M02_AXI_0_wstrb                    (),
        .M02_AXI_0_wvalid                   (lat_axil_wvalid),

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

    // GTF (MAC mode) example design
    gtfwizard_0_example_top i_gtfmac (

        // Control plane
        .aclk                               (axi_aclk),
        .aresetn                            (axi_aresetn),

        .s_axi_awaddr                       ({16'd0, gtf_axil_awaddr[15:0]}),   // input     wire [31 : 0]
        .s_axi_awprot                       (gtf_axil_awprot),                  // output    wire [2 : 0]
        .s_axi_awvalid                      (gtf_axil_awvalid),                 // input     wire
        .s_axi_awready                      (gtf_axil_awready),                 // output    wire
        .s_axi_wdata                        (gtf_axil_wdata),                   // input     wire [31 : 0]
        .s_axi_wstrb                        (gtf_axil_wstrb),                   // output    wire [3 : 0]
        .s_axi_wvalid                       (gtf_axil_wvalid),                  // input     wire
        .s_axi_wready                       (gtf_axil_wready),                  // output    wire
        .s_axi_bresp                        (gtf_axil_bresp),                   // output    wire [1 : 0]
        .s_axi_bvalid                       (gtf_axil_bvalid),                  // output    wire
        .s_axi_bready                       (gtf_axil_bready),                  // input     wire
        .s_axi_araddr                       ({16'd0, gtf_axil_araddr[15:0]}),   // input     wire [31 : 0]
        .s_axi_arprot                       (gtf_axil_arprot),                  // output    wire [2 : 0]
        .s_axi_arvalid                      (gtf_axil_arvalid),                 // input     wire
        .s_axi_arready                      (gtf_axil_arready),                 // output    wire
        .s_axi_rdata                        (gtf_axil_rdata),                   // output    wire [31 : 0]
        .s_axi_rresp                        (gtf_axil_rresp),                   // output    wire [1 : 0]
        .s_axi_rvalid                       (gtf_axil_rvalid),                  // output    wire
        .s_axi_rready                       (gtf_axil_rready),                  // input     wire

        // original exdes IOs
        .gtf_ch_gtftxn                      (gtf_ch_gtftxn),                    // output
        .gtf_ch_gtftxp                      (gtf_ch_gtftxp),                    // output
        .gtf_ch_gtfrxn                      (gtf_ch_gtfrxn),                    // input
        .gtf_ch_gtfrxp                      (gtf_ch_gtfrxp),                    // input

        .refclk_p                           (refclk_p),                         // input
        .refclk_n                           (refclk_n),                         // input

        .hb_gtwiz_reset_all_in              (hb_gtwiz_reset_all_in),            // input

        .link_down_latched_reset_in         (link_down_latched_reset_in),       // input
        .link_status_out                    (link_status_out),                  // output reg
        .link_down_latched_out              (link_down_latched_out),            // output reg
        .link_maintained                    (link_maintained),                  // output wire

        .gtf_ch_rxsyncdone                  (gtf_ch_rxsyncdone),                // output  wire
        .gtf_ch_txsyncdone                  (gtf_ch_txsyncdone),                // output  wire
        .pass                               (pass),                             // output  wire
        .state_check                        (state_check),                      // output  wire
        .wa_complete_flg                    (wa_complete_flg),                  // output  wire

        // generated clocks and resets from exdes
        .tx_axis_clk                        (tx_axis_clk),
        .tx_axis_rst                        (tx_axis_rst),

        .rx_axis_clk                        (rx_axis_clk),
        .rx_axis_rst                        (rx_axis_rst),

        // lat_clk_out is a 'fast' clock (1050 MHz) that we are not using now
        .lat_clk_out                        (),
        .lat_rstn_out                       (),

        .sys_clk_out                        (sys_clk),
        .sys_rst_out                        (sys_rst),

        // vnc IOs

        .vnc_gtf_ch_gttxreset               (vnc_gtf_ch_gttxreset),             // input //EG
        .vnc_gtf_ch_txpmareset              (vnc_gtf_ch_txpmareset),           // input //EG
        .vnc_gtf_ch_txpcsreset              (vnc_gtf_ch_txpcsreset),            // input
        .vnc_gtf_ch_gtrxreset               (vnc_gtf_ch_gtrxreset),             // input //EG
        .vnc_gtf_ch_rxpmareset              (vnc_gtf_ch_rxpmareset),            // input //EG
        .vnc_gtf_ch_rxdfelpmreset           (vnc_gtf_ch_rxdfelpmreset),         // input
        .vnc_gtf_ch_eyescanreset            (vnc_gtf_ch_eyescanreset),          // input
        .vnc_gtf_ch_rxpcsreset              (vnc_gtf_ch_rxpcsreset),            // input
        .vnc_gtf_cm_qpll0reset              (vnc_gtf_cm_qpll0reset),            // input //EG

        .vnc_gtf_ch_txuserrdy               (vnc_gtf_ch_txuserrdy),
        .vnc_gtf_ch_rxuserrdy               (vnc_gtf_ch_rxuserrdy),

        .gtwiz_reset_tx_pll_and_datapath_in (gtwiz_reset_tx_pll_and_datapath_in),
        .gtwiz_reset_tx_datapath_in         (gtwiz_reset_tx_datapath_in),
        .gtwiz_reset_rx_pll_and_datapath_in (gtwiz_reset_rx_pll_and_datapath_in),
        .gtwiz_reset_rx_datapath_in         (gtwiz_reset_rx_datapath_in),

        .gtf_ch_statrxinternallocalfault    (stat_gtf_rx_internal_local_fault),
        .gtf_ch_statrxlocalfault            (stat_gtf_rx_local_fault),
        .gtf_ch_statrxreceivedlocalfault    (stat_gtf_rx_received_local_fault),
        .gtf_ch_statrxremotefault           (stat_gtf_rx_remote_fault),

        .gtf_ch_statrxblocklock             (stat_gtf_rx_block_lock),           // output  wire
        .gtf_ch_rxbitslip                   (gtf_rx_bitslip),                   // output  wire
        .gtf_ch_pcsrsvdin_0                 (gtf_rx_gb_seq_sync),               // input   wire
        .gtf_ch_pcsrsvdin_1                 (gtf_rx_disable_bitslip),           // input   wire
        .gtf_ch_rxslippma                   (gtf_rx_slip_pma),                  // input   wire
        .gtf_ch_rxslippmardy                (gtf_rx_slip_pma_rdy),              // output  wire
        .gtf_ch_gtrsvd_8                    (gtf_rx_slip_one_ui),               // input   wire

        .gtf_ch_txaxistready                (tx_axis_tready),                   // output  wire
        .gtf_ch_txaxistvalid                (tx_axis_tvalid),                   // input   wire
        .gtf_ch_txaxistdata                 (tx_axis_tdata),                    // input   wire [63:0]
        .gtf_ch_txaxistlast                 (tx_axis_tlast),                    // input   wire [7:0]
        .gtf_ch_txaxistpre                  (tx_axis_tpre),                     // input   wire [7:0]
        .gtf_ch_txaxisterr                  (tx_axis_terr),                     // input   wire
        .gtf_ch_txaxistterm                 (tx_axis_tterm),                    // input   wire [4:0]
        .gtf_ch_txaxistsof                  (tx_axis_tsof),                     // input   wire [1:0]
        .gtf_ch_txaxistpoison               (tx_axis_tpoison),                  // input   wire
        .gtf_ch_pcsrsvdout_2                (tx_axis_tcan_start),               // output  wire
        .gtf_ch_txptpsop                    (tx_ptp_sop),                       // output  wire
        .gtf_ch_txptpsoppos                 (tx_ptp_sop_pos),                   // output  wire
        .gtf_ch_txgbseqstart                (tx_gb_seq_start),                  // output  wire
        .gtf_ch_txunfout                    (tx_unfout),                        // output  wire

        .gtf_ch_rxaxistvalid                (rx_axis_tvalid),                   // output  wire
        .gtf_ch_rxaxistdata                 (rx_axis_tdata),                    // output  wire [63:0]
        .gtf_ch_rxaxistlast                 (rx_axis_tlast),                    // output  wire [7:0]
        .gtf_ch_rxaxistpre                  (rx_axis_tpre),                     // output  wire [7:0]
        .gtf_ch_rxaxisterr                  (rx_axis_terr),                     // output  wire
        .gtf_ch_rxaxistterm                 (rx_axis_tterm),                    // output  wire [4:0]
        .gtf_ch_rxaxistsof                  (rx_axis_tsof),                     // output  wire [1:0]
        .vnc_rx_custom_preamble_en_in       (vnc_rx_custom_preamble_en)         // output  wire       //EG

    );

    gtfmac_vnc_core # (
        .SIMULATION         (SIMULATION),
        .ONE_SECOND_COUNT   (ONE_SECOND_COUNT)
    )
    i_gtfmac_vnc_core (

        .axi_aclk                           (axi_aclk),                         // input
        .axi_aresetn                        (axi_aresetn),                      // input

        .vnc_axil_araddr                    (vnc_axil_araddr),                  // input   wire    [31:0]
        .vnc_axil_arvalid                   (vnc_axil_arvalid),                 // input   wire
        .vnc_axil_arready                   (vnc_axil_arready),                 // output  reg
        .vnc_axil_rdata                     (vnc_axil_rdata),                   // output  reg     [31:0]
        .vnc_axil_rresp                     (vnc_axil_rresp),                   // output  wire    [1:0]
        .vnc_axil_rvalid                    (vnc_axil_rvalid),                  // output  reg
        .vnc_axil_rready                    (vnc_axil_rready),                  // input
        .vnc_axil_awaddr                    (vnc_axil_awaddr),                  // input   wire    [31:0]
        .vnc_axil_awvalid                   (vnc_axil_awvalid),                 // input   wire
        .vnc_axil_awready                   (vnc_axil_awready),                 // output  reg
        .vnc_axil_wdata                     (vnc_axil_wdata),                   // input   wire    [31:0]
        .vnc_axil_wvalid                    (vnc_axil_wvalid),                  // input   wire
        .vnc_axil_wready                    (vnc_axil_wready),                  // output  reg
        .vnc_axil_bvalid                    (vnc_axil_bvalid),                  // output  reg
        .vnc_axil_bresp                     (vnc_axil_bresp),                   // output  wire    [1:0]
        .vnc_axil_bready                    (vnc_axil_bready),                  // input

        .lat_axil_araddr                    (lat_axil_araddr),                  // input   wire    [31:0]
        .lat_axil_arvalid                   (lat_axil_arvalid),                 // input   wire
        .lat_axil_arready                   (lat_axil_arready),                 // output  reg
        .lat_axil_rdata                     (lat_axil_rdata),                   // output  reg     [31:0]
        .lat_axil_rresp                     (lat_axil_rresp),                   // output  wire    [1:0]
        .lat_axil_rvalid                    (lat_axil_rvalid),                  // output  reg
        .lat_axil_rready                    (lat_axil_rready),                  // input
        .lat_axil_awaddr                    (lat_axil_awaddr),                  // input   wire    [31:0]
        .lat_axil_awvalid                   (lat_axil_awvalid),                 // input   wire
        .lat_axil_awready                   (lat_axil_awready),                 // output  reg
        .lat_axil_wdata                     (lat_axil_wdata),                   // input   wire    [31:0]
        .lat_axil_wvalid                    (lat_axil_wvalid),                  // input   wire
        .lat_axil_wready                    (lat_axil_wready),                  // output  reg
        .lat_axil_bvalid                    (lat_axil_bvalid),                  // output  reg
        .lat_axil_bresp                     (lat_axil_bresp),                   // output  wire    [1:0]
        .lat_axil_bready                    (lat_axil_bready),                  // input

        .gen_clk                            (sys_clk),                          // input       wire
        .gen_rst                            (sys_rst),                          // input       wire

        .mon_clk                            (sys_clk),                          // input       wire
        .mon_rst                            (sys_rst),                          // input       wire

        .lat_clk                            (lat_clk),                          // input       wire
        .lat_rstn                           (lat_rstn),                         // input       wire

        .tx_clk                             (tx_axis_clk),                      // input       wire
        .tx_rst                             (tx_axis_rst),                      // input       wire

        .tx_axis_tready                     (tx_axis_tready),                   // input       wire
        .tx_axis_tvalid                     (tx_axis_tvalid),                   // output      wire
        .tx_axis_tdata                      (tx_axis_tdata),                    // output      wire [63:0]
        .tx_axis_tlast                      (tx_axis_tlast),                    // output      wire [7:0]
        .tx_axis_tpre                       (tx_axis_tpre),                     // output      wire [7:0]
        .tx_axis_terr                       (tx_axis_terr),                     // output      wire
        .tx_axis_tterm                      (tx_axis_tterm),                    // output      wire [4:0]
        .tx_axis_tsof                       (tx_axis_tsof),                     // output      wire [1:0]
        .tx_axis_tpoison                    (tx_axis_tpoison),                  // output      wire
        .tx_axis_tcan_start                 (tx_axis_tcan_start),               // input       wire
        .tx_ptp_sop                         (tx_ptp_sop),                       // input       wire
        .tx_ptp_sop_pos                     (tx_ptp_sop_pos),                   // input       wire
        .tx_gb_seq_start                    (tx_gb_seq_start),                  // input       wire
        .tx_unfout                          (tx_unfout),                        // input       wire

        .rx_clk                             (rx_axis_clk),                      // input       wire
        .rx_rst                             (rx_axis_rst),                      // input       wire

        .rx_axis_tvalid                     (rx_axis_tvalid),                   // input       wire
        .rx_axis_tdata                      (rx_axis_tdata),                    // input       wire [63:0]
        .rx_axis_tlast                      (rx_axis_tlast),                    // input       wire [7:0]
        .rx_axis_tpre                       (rx_axis_tpre),                     // input       wire [7:0]
        .rx_axis_terr                       (rx_axis_terr),                     // input       wire
        .rx_axis_tterm                      (rx_axis_tterm),                    // input       wire [4:0]
        .rx_axis_tsof                       (rx_axis_tsof),                     // input       wire [1:0]

        .stat_gtf_rx_internal_local_fault   (stat_gtf_rx_internal_local_fault), // input
        .stat_gtf_rx_local_fault            (stat_gtf_rx_local_fault),          // input
        .stat_gtf_rx_received_local_fault   (stat_gtf_rx_received_local_fault), // input
        .stat_gtf_rx_remote_fault           (stat_gtf_rx_remote_fault),         // input

        .vnc_gtf_ch_gttxreset               (vnc_gtf_ch_gttxreset),             // output
        .vnc_gtf_ch_txpmareset              (vnc_gtf_ch_txpmareset),            // output
        .vnc_gtf_ch_txpcsreset              (vnc_gtf_ch_txpcsreset),            // output
        .vnc_gtf_ch_gtrxreset               (vnc_gtf_ch_gtrxreset),             // output
        .vnc_gtf_ch_rxpmareset              (vnc_gtf_ch_rxpmareset),            // output
        .vnc_gtf_ch_rxdfelpmreset           (vnc_gtf_ch_rxdfelpmreset),         // output
        .vnc_gtf_ch_eyescanreset            (vnc_gtf_ch_eyescanreset),          // output
        .vnc_gtf_ch_rxpcsreset              (vnc_gtf_ch_rxpcsreset),            // output
        .vnc_gtf_cm_qpll0reset              (vnc_gtf_cm_qpll0reset),            // output

        .vnc_gtf_ch_txuserrdy               (vnc_gtf_ch_txuserrdy),
        .vnc_gtf_ch_rxuserrdy               (vnc_gtf_ch_rxuserrdy),

        .gtwiz_reset_tx_pll_and_datapath_in (gtwiz_reset_tx_pll_and_datapath_in),
        .gtwiz_reset_tx_datapath_in         (gtwiz_reset_tx_datapath_in),
        .gtwiz_reset_rx_pll_and_datapath_in (gtwiz_reset_rx_pll_and_datapath_in),
        .gtwiz_reset_rx_datapath_in         (gtwiz_reset_rx_datapath_in),

        .block_lock                         (stat_gtf_rx_block_lock),           // input   logic
        .rx_bitslip                         (gtf_rx_bitslip),                   // input   logic
        .rx_disable_bitslip                 (gtf_rx_disable_bitslip),           // output  logic
        .rx_gb_seq_sync                     (gtf_rx_gb_seq_sync),               // output  wire

        .rx_slip_pma                        (gtf_rx_slip_pma),                  // output  logic
        .rx_slip_pma_rdy                    (gtf_rx_slip_pma_rdy),              // input   logic
        .rx_slip_one_ui                     (gtf_rx_slip_one_ui),               // output  logic
        
        .vnc_rx_custom_preamble_en          (vnc_rx_custom_preamble_en),        //output wire

        // Latency monitor ILA signals
        .lat_mon_sent_time_ila              (lat_mon_sent_time_ila),
        .lat_mon_rcvd_time_ila              (lat_mon_rcvd_time_ila),
        .lat_mon_delta_time_ila             (lat_mon_delta_time_ila),
        .lat_mon_send_event_ila             (lat_mon_send_event_ila),
        .lat_mon_rcv_event_ila              (lat_mon_rcv_event_ila),
        .lat_mon_delta_time_idx_ila         (lat_mon_delta_time_idx_ila) 

    );


//------------------------------------------------------------------------------
//
//    ILA  
//
//------------------------------------------------------------------------------

// Delaying Tx and Rx ILA signals by 3 clock cyles to align with the latency monitor signals

//  TX Related Signals...
reg        tx_axis_tvalid_ila;
reg        tx_axis_tvalid_ila_r [3:0];
           
reg        tx_axis_tready_ila; 
reg        tx_axis_tready_ila_r [3:0];

reg [15:0] tx_axis_tdata_ila;
reg [15:0] tx_axis_tdata_ila_r [3:0];

reg        tx_axis_tcan_start_ila;
reg        tx_axis_tcan_start_ila_r [3:0];


//  RX Related Signals...
reg        rx_axis_tvalid_ila;
reg        rx_axis_tvalid_ila_r [3:0];

reg [15:0] rx_axis_tdata_ila;
reg [15:0] rx_axis_tdata_ila_r [3:0];
    
reg [1:0]  rx_axis_tsof_ila;
reg [1:0]  rx_axis_tsof_ila_r [3:0];

int ii;

always @(posedge tx_axis_clk) begin
    tx_axis_tvalid_ila_r[0]     <= tx_axis_tvalid;
    tx_axis_tready_ila_r[0]     <= tx_axis_tready;
    tx_axis_tdata_ila_r[0]      <= tx_axis_tdata[15:0];
    tx_axis_tcan_start_ila_r[0] <= tx_axis_tcan_start;
    for (ii = 1 ; ii < 4; ii++) begin
        tx_axis_tvalid_ila_r[ii]     <= tx_axis_tvalid_ila_r[ii-1];
        tx_axis_tready_ila_r[ii]     <= tx_axis_tready_ila_r[ii-1];
        tx_axis_tdata_ila_r[ii]      <= tx_axis_tdata_ila_r[ii-1];
        tx_axis_tcan_start_ila_r[ii] <= tx_axis_tcan_start_ila_r[ii-1];
    end
end

always @(posedge rx_axis_clk) begin
    rx_axis_tvalid_ila_r[0] <= rx_axis_tvalid;
    rx_axis_tdata_ila_r[0]  <= rx_axis_tdata[15:0];
    rx_axis_tsof_ila_r[0]   <= rx_axis_tsof;
    for (ii = 1 ; ii < 4; ii++) begin
        rx_axis_tvalid_ila_r[ii] <= rx_axis_tvalid_ila_r[ii-1];
        rx_axis_tdata_ila_r[ii]  <= rx_axis_tdata_ila_r[ii-1];
        rx_axis_tsof_ila_r[ii]   <= rx_axis_tsof_ila_r[ii-1];
    end
end

ila_latency gtfmac_ila_inst0 (
    .clk     ( rx_axis_clk                ),
    
    // Latency monitor ILA signals
    .probe0  ( lat_mon_sent_time_ila      ), // 16b
    .probe1  ( lat_mon_rcvd_time_ila      ), // 16b
    .probe2  ( lat_mon_delta_time_ila     ), // 16b
    .probe3  ( lat_mon_send_event_ila     ),
    .probe4  ( lat_mon_rcv_event_ila      ),
    .probe5  ( lat_mon_delta_time_idx_ila ), // 32b
    
    // TX AXI-Stream signals
    .probe6  ( tx_axis_tvalid_ila_r[3]     ),
    .probe7  ( tx_axis_tready_ila_r[3]     ),
    .probe8  ( tx_axis_tdata_ila_r[3]      ), // 16b
    .probe9  ( tx_axis_tcan_start_ila_r[3] ),
    
    // RX AXI-Stream signals
    .probe10 ( rx_axis_tvalid_ila_r[3]     ),
    .probe11 ( rx_axis_tdata_ila_r[3]      ), // 16b
    .probe12 ( rx_axis_tsof_ila_r[3]       )  // 2b
);

endmodule

module gtfmac_vnc_core # (
    parameter   SIMULATION         = "false",
    parameter   ONE_SECOND_COUNT   = 28'd200_000_000
)
(

    ////////////////////////////////////////////////////////////////
    // AXI-Lite Interface
    ////////////////////////////////////////////////////////////////

    input       wire            axi_aclk,
    input       wire            axi_aresetn,

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

    ////////////////////////////////////////////////////////////////
    // Control and Status
    ////////////////////////////////////////////////////////////////

    // Debug resets
    output      logic           vnc_gtf_ch_gttxreset,
    output      logic           vnc_gtf_ch_txpmareset,
    output      logic           vnc_gtf_ch_txpcsreset,
    output      logic           vnc_gtf_ch_gtrxreset,
    output      logic           vnc_gtf_ch_rxpmareset,
    output      logic           vnc_gtf_ch_rxdfelpmreset,
    output      logic           vnc_gtf_ch_eyescanreset,
    output      logic           vnc_gtf_ch_rxpcsreset,
    output      logic           vnc_gtf_cm_qpll0reset,

    output      logic           vnc_gtf_ch_txuserrdy,
    output      logic           vnc_gtf_ch_rxuserrdy,

    output      logic           gtwiz_reset_tx_pll_and_datapath_in,
    output      logic           gtwiz_reset_tx_datapath_in,
    output      logic           gtwiz_reset_rx_pll_and_datapath_in,
    output      logic           gtwiz_reset_rx_datapath_in,

    input   wire                stat_gtf_rx_internal_local_fault,
    input   wire                stat_gtf_rx_local_fault,
    input   wire                stat_gtf_rx_received_local_fault,
    input   wire                stat_gtf_rx_remote_fault,

    input   logic               block_lock,
    input   logic               rx_bitslip,
    output  logic               rx_disable_bitslip,
    output  logic               rx_gb_seq_sync,

    output  logic               rx_slip_pma,
    input   logic               rx_slip_pma_rdy,
    output  logic               rx_slip_one_ui,
    output  wire                vnc_rx_custom_preamble_en, //EG                         

    // Latency monitor ILA signals
    output  wire [15:0]         lat_mon_sent_time_ila,              
    output  wire [15:0]         lat_mon_rcvd_time_ila,              
    output  wire [15:0]         lat_mon_delta_time_ila,             
    output  wire                lat_mon_send_event_ila,             
    output  wire                lat_mon_rcv_event_ila,
    output  wire [31:0]         lat_mon_delta_time_idx_ila        
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

    wire            ctl_vnc_frm_gen_en;
    wire            ctl_vnc_frm_gen_mode;
    wire    [13:0]  ctl_vnc_max_len;
    wire    [13:0]  ctl_vnc_min_len;

    wire            ctl_tx_custom_preamble_en;
    wire    [63:0]  ctl_vnc_tx_custom_preamble;
    wire            ctl_tx_variable_ipg;

    wire            ctl_tx_fcs_ins_enable;
    wire            ctl_tx_data_rate;

    wire            ctl_vnc_tx_inj_err;
    wire            ack_vnc_tx_inj_err;
    
    wire            ctl_vnc_tx_inj_poison; //EG
    wire            ack_vnc_tx_inj_poison; //EG

    wire            ctl_vnc_tx_inj_pause;
    wire    [47:0]  ctl_vnc_tx_inj_pause_sa;
    wire    [47:0]  ctl_vnc_tx_inj_pause_da;
    wire    [15:0]  ctl_vnc_tx_inj_pause_ethtype;
    wire    [15:0]  ctl_vnc_tx_inj_pause_opcode;
    wire    [15:0]  ctl_vnc_tx_inj_pause_timer_ce;
    wire    [15:0]  ctl_vnc_tx_inj_pause_timer_pfc0;
    wire    [15:0]  ctl_vnc_tx_inj_pause_timer_pfc1;
    wire    [15:0]  ctl_vnc_tx_inj_pause_timer_pfc2;
    wire    [15:0]  ctl_vnc_tx_inj_pause_timer_pfc3;
    wire    [15:0]  ctl_vnc_tx_inj_pause_timer_pfc4;
    wire    [15:0]  ctl_vnc_tx_inj_pause_timer_pfc5;
    wire    [15:0]  ctl_vnc_tx_inj_pause_timer_pfc6;
    wire    [15:0]  ctl_vnc_tx_inj_pause_timer_pfc7;
    wire            ack_vnc_tx_inj_pause;

    wire            ctl_vnc_mon_en;
    wire            ctl_rx_data_rate;
    wire            ctl_rx_packet_framing_enable;
    wire            ctl_rx_custom_preamble_en;
    wire    [63:0]  ctl_vnc_rx_custom_preamble;
    wire    [31:0]  ctl_num_frames;

    wire            stat_tick_from_pif;
    wire            stat_tick_from_vio;
    wire            stat_tick;

    wire [63:0]     stat_vnc_tx_total_bytes;
    wire [63:0]     stat_vnc_tx_total_good_bytes;
    wire [63:0]     stat_vnc_tx_total_packets;
    wire [63:0]     stat_vnc_tx_total_good_packets;
    wire [63:0]     stat_vnc_tx_broadcast;
    wire [63:0]     stat_vnc_tx_multicast;
    wire [63:0]     stat_vnc_tx_unicast;
    wire [63:0]     stat_vnc_tx_vlan;

    wire [63:0]     stat_vnc_tx_packet_64_bytes;
    wire [63:0]     stat_vnc_tx_packet_65_127_bytes;
    wire [63:0]     stat_vnc_tx_packet_128_255_bytes;
    wire [63:0]     stat_vnc_tx_packet_256_511_bytes;
    wire [63:0]     stat_vnc_tx_packet_512_1023_bytes;
    wire [63:0]     stat_vnc_tx_packet_1024_1518_bytes;
    wire [63:0]     stat_vnc_tx_packet_1519_1522_bytes;
    wire [63:0]     stat_vnc_tx_packet_1523_1548_bytes;
    wire [63:0]     stat_vnc_tx_packet_1549_2047_bytes;
    wire [63:0]     stat_vnc_tx_packet_2048_4095_bytes;
    wire [63:0]     stat_vnc_tx_packet_4096_8191_bytes;
    wire [63:0]     stat_vnc_tx_packet_8192_9215_bytes;

    wire [63:0]     stat_vnc_tx_packet_small;
    wire [63:0]     stat_vnc_tx_packet_large;
    wire [63:0]     stat_vnc_tx_frame_error;

    wire [63:0]     stat_vnc_rx_unicast;
    wire [63:0]     stat_vnc_rx_multicast;
    wire [63:0]     stat_vnc_rx_broadcast;
    wire [63:0]     stat_vnc_rx_bad_preamble; //EG
    wire [63:0]     stat_vnc_rx_good_tsof_codeword;
    wire [63:0]     stat_vnc_rx_vlan;

    wire [63:0]     stat_vnc_rx_total_bytes;
    wire [63:0]     stat_vnc_rx_total_good_bytes;
    wire [63:0]     stat_vnc_rx_total_packets;
    wire [63:0]     stat_vnc_rx_total_good_packets;

    wire [63:0]     stat_vnc_rx_inrangeerr;
    wire [63:0]     stat_vnc_rx_bad_fcs;

    wire [63:0]     stat_vnc_rx_packet_64_bytes;
    wire [63:0]     stat_vnc_rx_packet_65_127_bytes;
    wire [63:0]     stat_vnc_rx_packet_128_255_bytes;
    wire [63:0]     stat_vnc_rx_packet_256_511_bytes;
    wire [63:0]     stat_vnc_rx_packet_512_1023_bytes;
    wire [63:0]     stat_vnc_rx_packet_1024_1518_bytes;
    wire [63:0]     stat_vnc_rx_packet_1519_1522_bytes;
    wire [63:0]     stat_vnc_rx_packet_1523_1548_bytes;
    wire [63:0]     stat_vnc_rx_packet_1549_2047_bytes;
    wire [63:0]     stat_vnc_rx_packet_2048_4095_bytes;
    wire [63:0]     stat_vnc_rx_packet_4096_8191_bytes;
    wire [63:0]     stat_vnc_rx_packet_8192_9215_bytes;

    wire [63:0]     stat_vnc_rx_oversize;
    wire [63:0]     stat_vnc_rx_undersize;
    wire [63:0]     stat_vnc_rx_toolong;
    wire [63:0]     stat_vnc_rx_packet_small;
    wire [63:0]     stat_vnc_rx_packet_large;
    wire [63:0]     stat_vnc_rx_jabber;
    wire [63:0]     stat_vnc_rx_fragment;
    wire [63:0]     stat_vnc_rx_packet_bad_fcs;

    wire [63:0]     stat_vnc_rx_user_pause;
    wire [63:0]     stat_vnc_rx_pause;

    wire   [15:0]   stat_vnc_tx_overflow;
    wire   [15:0]   stat_tx_unfout;

    logic           ctl_gb_seq_sync;
    logic           ctl_disable_bitslip;
    logic           ctl_correct_bitslip;
    logic  [6:0]    stat_bitslip_cnt;
    logic  [6:0]    stat_bitslip_issued;
    logic           stat_excessive_bitslip;
    logic           stat_bitslip_locked;
    logic           stat_bitslip_busy;
    logic           stat_bitslip_done;


    assign  stat_tick   = stat_tick_from_pif;
    assign vnc_rx_custom_preamble_en = ctl_rx_custom_preamble_en; //EG
    
    gtfmac_vnc_tx_gen  i_tx_gen    (

        .axi_aclk                           (axi_aclk),
        .axi_aresetn                        (axi_aresetn),

        .gen_clk                            (gen_clk),                          // input       wire
        .gen_rst                            (gen_rst),                          // input       wire

        .ctl_vnc_frm_gen_en                 (ctl_vnc_frm_gen_en),               // input       wire
        .ctl_vnc_frm_gen_mode               (ctl_vnc_frm_gen_mode),             // input       wire
        .ctl_vnc_max_len                    (ctl_vnc_max_len),                  // input       wire    [13:0]
        .ctl_vnc_min_len                    (ctl_vnc_min_len),                  // input       wire    [13:0]
        .ctl_num_frames                     (ctl_num_frames),                   // input       wire    [31:0]
        .ack_frm_gen_done                   (ack_frm_gen_done),                 // output      wire

        .ctl_tx_start_framing_enable        (ctl_tx_start_framing_enable),      // input       wire
        .ctl_tx_custom_preamble_en          (ctl_tx_custom_preamble_en),        // input       wire
        .ctl_vnc_tx_custom_preamble         (ctl_vnc_tx_custom_preamble),       // input       wire    [63:0]
        .ctl_tx_variable_ipg                (ctl_tx_variable_ipg),              // input       wire

        .ctl_tx_fcs_ins_enable              (ctl_tx_fcs_ins_enable),            // input       wire
        .ctl_tx_data_rate                   (ctl_tx_data_rate),

        .ctl_vnc_tx_inj_err                 (ctl_vnc_tx_inj_err),               // input       wire
        .ack_vnc_tx_inj_err                 (ack_vnc_tx_inj_err),               // output      reg
        
        .ctl_vnc_tx_inj_poison              (ctl_vnc_tx_inj_poison),            // input       wire //EG
        .ack_vnc_tx_inj_poison              (ack_vnc_tx_inj_poison),            // output      reg //EG

        .ctl_vnc_tx_start_lat_run           (ctl_vnc_tx_start_lat_run),         // input
        .ack_vnc_tx_start_lat_run           (ack_vnc_tx_start_lat_run),         // output

        .ctl_vnc_tx_inj_pause               (ctl_vnc_tx_inj_pause),             // input       wire
        .ctl_vnc_tx_inj_pause_sa            (ctl_vnc_tx_inj_pause_sa),          // input       wire    [47:0]
        .ctl_vnc_tx_inj_pause_da            (ctl_vnc_tx_inj_pause_da),          // input       wire    [47:0]
        .ctl_vnc_tx_inj_pause_ethtype       (ctl_vnc_tx_inj_pause_ethtype),     // input       wire    [15:0]
        .ctl_vnc_tx_inj_pause_opcode        (ctl_vnc_tx_inj_pause_opcode),      // input       wire    [15:0]
        .ctl_vnc_tx_inj_pause_timer_ce      (ctl_vnc_tx_inj_pause_timer_ce),    // input       wire    [15:0]
        .ctl_vnc_tx_inj_pause_timer_pfc0    (ctl_vnc_tx_inj_pause_timer_pfc0),  // input       wire    [15:0]
        .ctl_vnc_tx_inj_pause_timer_pfc1    (ctl_vnc_tx_inj_pause_timer_pfc1),  // input       wire    [15:0]
        .ctl_vnc_tx_inj_pause_timer_pfc2    (ctl_vnc_tx_inj_pause_timer_pfc2),  // input       wire    [15:0]
        .ctl_vnc_tx_inj_pause_timer_pfc3    (ctl_vnc_tx_inj_pause_timer_pfc3),  // input       wire    [15:0]
        .ctl_vnc_tx_inj_pause_timer_pfc4    (ctl_vnc_tx_inj_pause_timer_pfc4),  // input       wire    [15:0]
        .ctl_vnc_tx_inj_pause_timer_pfc5    (ctl_vnc_tx_inj_pause_timer_pfc5),  // input       wire    [15:0]
        .ctl_vnc_tx_inj_pause_timer_pfc6    (ctl_vnc_tx_inj_pause_timer_pfc6),  // input       wire    [15:0]
        .ctl_vnc_tx_inj_pause_timer_pfc7    (ctl_vnc_tx_inj_pause_timer_pfc7),  // input       wire    [15:0]
        .ack_vnc_tx_inj_pause               (ack_vnc_tx_inj_pause),             // output      wire

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

        .stat_tick                          (stat_tick),                        // input       wire

        .stat_vnc_tx_overflow               (stat_vnc_tx_overflow),             // output      wire
        .stat_tx_unfout                     (stat_tx_unfout),                   // output      wire

        .stat_vnc_tx_total_bytes            (stat_vnc_tx_total_bytes),          // output      wire [31:0]
        .stat_vnc_tx_total_good_bytes       (stat_vnc_tx_total_good_bytes),     // output      wire [31:0]
        .stat_vnc_tx_total_packets          (stat_vnc_tx_total_packets),        // output      wire [31:0]
        .stat_vnc_tx_total_good_packets     (stat_vnc_tx_total_good_packets),   // output      wire [31:0]
        .stat_vnc_tx_broadcast              (stat_vnc_tx_broadcast),            // output      wire [31:0]
        .stat_vnc_tx_multicast              (stat_vnc_tx_multicast),            // output      wire [31:0]
        .stat_vnc_tx_unicast                (stat_vnc_tx_unicast),              // output      wire [31:0]
        .stat_vnc_tx_vlan                   (stat_vnc_tx_vlan),                 // output      wire [31:0]

        .stat_vnc_tx_packet_64_bytes        (stat_vnc_tx_packet_64_bytes),          // output      wire [31:0]
        .stat_vnc_tx_packet_65_127_bytes    (stat_vnc_tx_packet_65_127_bytes),      // output      wire [31:0]
        .stat_vnc_tx_packet_128_255_bytes   (stat_vnc_tx_packet_128_255_bytes),     // output      wire [31:0]
        .stat_vnc_tx_packet_256_511_bytes   (stat_vnc_tx_packet_256_511_bytes),     // output      wire [31:0]
        .stat_vnc_tx_packet_512_1023_bytes  (stat_vnc_tx_packet_512_1023_bytes),    // output      wire [31:0]
        .stat_vnc_tx_packet_1024_1518_bytes (stat_vnc_tx_packet_1024_1518_bytes),   // output      wire [31:0]
        .stat_vnc_tx_packet_1519_1522_bytes (stat_vnc_tx_packet_1519_1522_bytes),   // output      wire [31:0]
        .stat_vnc_tx_packet_1523_1548_bytes (stat_vnc_tx_packet_1523_1548_bytes),   // output      wire [31:0]
        .stat_vnc_tx_packet_1549_2047_bytes (stat_vnc_tx_packet_1549_2047_bytes),   // output      wire [31:0]
        .stat_vnc_tx_packet_2048_4095_bytes (stat_vnc_tx_packet_2048_4095_bytes),   // output      wire [31:0]
        .stat_vnc_tx_packet_4096_8191_bytes (stat_vnc_tx_packet_4096_8191_bytes),   // output      wire [31:0]
        .stat_vnc_tx_packet_8192_9215_bytes (stat_vnc_tx_packet_8192_9215_bytes),   // output      wire [31:0]

        .stat_vnc_tx_packet_small           (stat_vnc_tx_packet_small),     // output      wire [31:0]
        .stat_vnc_tx_packet_large           (stat_vnc_tx_packet_large),     // output      wire [31:0]
        .stat_vnc_tx_frame_error            (stat_vnc_tx_frame_error),      // output      wire [31:0]
        .stat_vnc_tx_bad_fcs                ()

    );


    gtfmac_vnc_rx_mon i_rx_mon (

        .mon_clk                            (mon_clk),                              // input       wire
        .mon_rst                            (mon_rst),                              // input       wire

        .ctl_vnc_mon_en                     (ctl_vnc_mon_en),                       // input       wire
        .ctl_rx_data_rate                   (ctl_rx_data_rate),                     // input       wire
        .ctl_rx_packet_framing_enable       (ctl_rx_packet_framing_enable),         // input       wire
        .ctl_rx_custom_preamble_en          (ctl_rx_custom_preamble_en),            // input       wire
        .ctl_vnc_rx_custom_preamble         (ctl_vnc_rx_custom_preamble),           // input       wire    [63:0]
        .ctl_vnc_max_len                    (ctl_vnc_max_len),                      // input       wire    [13:0]
        .ctl_vnc_min_len                    (ctl_vnc_min_len),                      // input       wire    [13:0]

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

        .stat_tick                          (stat_tick),                            // input       wire

        .stat_vnc_rx_unicast                (stat_vnc_rx_unicast),                  // output      wire [63:0]
        .stat_vnc_rx_multicast              (stat_vnc_rx_multicast),                // output      wire [63:0]
        .stat_vnc_rx_broadcast              (stat_vnc_rx_broadcast),                // output      wire [63:0]
        .stat_vnc_rx_bad_preamble           (stat_vnc_rx_bad_preamble),             // output      wire [63:0] //EG    
        .stat_vnc_rx_good_tsof_codeword     (stat_vnc_rx_good_tsof_codeword),
        .stat_vnc_rx_vlan                   (stat_vnc_rx_vlan),                     // output      wire [63:0]

        .stat_vnc_rx_total_bytes            (stat_vnc_rx_total_bytes),              // output      wire [63:0]
        .stat_vnc_rx_total_good_bytes       (stat_vnc_rx_total_good_bytes),         // output      wire [63:0]
        .stat_vnc_rx_total_packets          (stat_vnc_rx_total_packets),            // output      wire [63:0]
        .stat_vnc_rx_total_good_packets     (stat_vnc_rx_total_good_packets),       // output      wire [63:0]

        .stat_vnc_rx_inrangeerr             (stat_vnc_rx_inrangeerr),               // output      wire [63:0]
        .stat_vnc_rx_bad_fcs                (stat_vnc_rx_bad_fcs),                  // output      wire [63:0]

        .stat_vnc_rx_packet_64_bytes        (stat_vnc_rx_packet_64_bytes),          // output      wire [63:0]
        .stat_vnc_rx_packet_65_127_bytes    (stat_vnc_rx_packet_65_127_bytes),      // output      wire [63:0]
        .stat_vnc_rx_packet_128_255_bytes   (stat_vnc_rx_packet_128_255_bytes),     // output      wire [63:0]
        .stat_vnc_rx_packet_256_511_bytes   (stat_vnc_rx_packet_256_511_bytes),     // output      wire [63:0]
        .stat_vnc_rx_packet_512_1023_bytes  (stat_vnc_rx_packet_512_1023_bytes),    // output      wire [63:0]
        .stat_vnc_rx_packet_1024_1518_bytes (stat_vnc_rx_packet_1024_1518_bytes),   // output      wire [63:0]
        .stat_vnc_rx_packet_1519_1522_bytes (stat_vnc_rx_packet_1519_1522_bytes),   // output      wire [63:0]
        .stat_vnc_rx_packet_1523_1548_bytes (stat_vnc_rx_packet_1523_1548_bytes),   // output      wire [63:0]
        .stat_vnc_rx_packet_1549_2047_bytes (stat_vnc_rx_packet_1549_2047_bytes),   // output      wire [63:0]
        .stat_vnc_rx_packet_2048_4095_bytes (stat_vnc_rx_packet_2048_4095_bytes),   // output      wire [63:0]
        .stat_vnc_rx_packet_4096_8191_bytes (stat_vnc_rx_packet_4096_8191_bytes),   // output      wire [63:0]
        .stat_vnc_rx_packet_8192_9215_bytes (stat_vnc_rx_packet_8192_9215_bytes),   // output      wire [63:0]

        .stat_vnc_rx_oversize               (stat_vnc_rx_oversize),                 // output      wire [63:0]
        .stat_vnc_rx_undersize              (stat_vnc_rx_undersize),                // output      wire [63:0]
        .stat_vnc_rx_toolong                (stat_vnc_rx_toolong),                  // output      wire [63:0]
        .stat_vnc_rx_packet_small           (stat_vnc_rx_packet_small),             // output      wire [63:0]
        .stat_vnc_rx_packet_large           (stat_vnc_rx_packet_large),             // output      wire [63:0]
        .stat_vnc_rx_jabber                 (stat_vnc_rx_jabber),                   // output      wire [63:0]
        .stat_vnc_rx_fragment               (stat_vnc_rx_fragment),                 // output      wire [63:0]
        .stat_vnc_rx_packet_bad_fcs         (stat_vnc_rx_packet_bad_fcs),           // output      wire [63:0]

        .stat_vnc_rx_user_pause             (stat_vnc_rx_user_pause),               // output      wire [63:0]
        .stat_vnc_rx_pause                  (stat_vnc_rx_pause)                     // output      wire [63:0]

    );


    gtfmac_vnc_latency #( 
        .SIMULATION (SIMULATION)
    ) i_latency (

        .data_rate                          (ctl_tx_data_rate),

        .tx_clk                             (tx_clk),                               // input       wire
        .tx_rstn                            (~tx_rst),                              // input       wire

        .rx_clk                             (rx_clk),                               // input       wire
        .rx_rstn                            (~rx_rst),                              // input       wire

        .lat_clk                            (lat_clk),                              // input       wire
        .lat_rstn                           (lat_rstn),                             // input       wire

        .axi_clk                            (axi_aclk),                             // input       wire
        .axi_rstn                           (axi_aresetn),                          // input       wire

        .tx_sopin                           (tx_sop),                               // input       wire
        .tx_enain                           (tx_axis_tvalid),                       // input       wire
        .tx_rdyout                          (tx_axis_tready),                       // input       wire
        .tx_can_start                       (tx_axis_tcan_start),                   // input       wire
        .tx_start_measured_run              (tx_start_measured_run),                // output      wire
        .tx_eopin                           (|tx_axis_tlast),                       // input       wire

        .rx_sof                             (|rx_axis_tsof),                        // input       wire
        .rx_start_measured_run              (rx_start_measured_run),                // input       wire

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
        .lat_mon_delta_time_idx_ila         (lat_mon_delta_time_idx_ila)
    );

    wire    [6:0]   bs_stat_bitslip_cnt;
    wire    [6:0]   bs_stat_bitslip_issued;

    wire            rx_f_rst;


    gtfmac_vnc_bitslip i_bitslip (

        .rx_clk                             (rx_clk),                               // input   logic
        .rx_rst                             (rx_rst),                               // input   logic

        .ctl_gb_seq_sync                    (ctl_gb_seq_sync),                      // input   logic
        .ctl_disable_bitslip                (ctl_disable_bitslip),                  // input   logic
        .ctl_correct_bitslip                (ctl_correct_bitslip),                  // input   logic
        .ctl_rx_data_rate                   (ctl_rx_data_rate),                     // input   wire

        .stat_bitslip_cnt                   (bs_stat_bitslip_cnt),                  // output  logic  [6:0]
        .stat_bitslip_issued                (bs_stat_bitslip_issued),               // output  logic  [6:0]
        .stat_excessive_bitslip             (stat_excessive_bitslip),               // output  logic
        .stat_locked                        (stat_bitslip_locked),                  // output  logic
        .stat_busy                          (stat_bitslip_busy),                    // output  logic
        .stat_done                          (stat_bitslip_done),                    // output  logic

        .rx_block_lock                      (block_lock),                           // input   logic
        .rx_bitslip                         (rx_bitslip),                           // input   logic
        .bs_gb_seq_sync                     (rx_gb_seq_sync),                       // output  logic
        .bs_disable_bitslip                 (rx_disable_bitslip),                   // output  logic

        .rx_slip_pma_rdy                    (rx_slip_pma_rdy),                      // input   logic
        .bs_slip_pma                        (rx_slip_pma),                          // output  logic
        .bs_slip_one_ui                     (rx_slip_one_ui)                        // output  logic

    );

    gtfmac_vnc_syncer_bus #(
       .WIDTH (7)
    ) i_stat_bitslip_cnt (
       .clkin        (rx_clk),
       .clkin_reset  (~rx_rst),
       .clkout       (axi_aclk),
       .clkout_reset (axi_aresetn),

       .busin        (bs_stat_bitslip_cnt),
       .busout       (stat_bitslip_cnt)
    );

    gtfmac_vnc_syncer_bus #(
       .WIDTH (7)
    ) i_stat_bitslip_issued (
       .clkin        (rx_clk),
       .clkin_reset  (~rx_rst),
       .clkout       (axi_aclk),
       .clkout_reset (axi_aresetn),

       .busin        (bs_stat_bitslip_issued),
       .busout       (stat_bitslip_issued)
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

    gtfmac_vnc_syncer_level i_sync_gtfmac_rx_rst (

      .clk        (axi_aclk),
      .reset      (axi_aresetn),

      .datain     (rx_rst),
      .dataout    (stat_gtf_rx_rst_sync)

    );

    gtfmac_vnc_syncer_level i_sync_gtfmac_tx_rst (

      .clk        (axi_aclk),
      .reset      (axi_aresetn),

      .datain     (tx_rst),
      .dataout    (stat_gtf_tx_rst_sync)

    );

    gtfmac_vnc_syncer_level i_sync_gtfmac_block_lock (

      .clk        (axi_aclk),
      .reset      (axi_aresetn),

      .datain     (block_lock),
      .dataout    (stat_gtf_block_lock_sync)

    );

    gtfmac_vnc_syncer_level i_sync_gtfmac_internal_local_fault (

      .clk        (axi_aclk),
      .reset      (axi_aresetn),

      .datain     (stat_gtf_rx_internal_local_fault),
      .dataout    (stat_gtf_rx_internal_local_fault_sync)

    );

    gtfmac_vnc_syncer_level i_sync_gtfmac_local_fault (

      .clk        (axi_aclk),
      .reset      (axi_aresetn),

      .datain     (stat_gtf_rx_local_fault),
      .dataout    (stat_gtf_rx_local_fault_sync)

    );

    gtfmac_vnc_syncer_level i_sync_gtfmac_received_local_fault (

      .clk        (axi_aclk),
      .reset      (axi_aresetn),

      .datain     (stat_gtf_rx_received_local_fault),
      .dataout    (stat_gtf_rx_received_local_fault_sync)

    );

    gtfmac_vnc_syncer_level i_sync_gtfmac_remote_fault (

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


    gtfmac_vnc_clock_count i_clock_count_tx_clk (
        .clk                (tx_clk),
        .one_second_edge    (one_second_edge),
        .clocks_per_second  (tx_clk_cps)
    );

    gtfmac_vnc_clock_count i_clock_count_rx_clk (
        .clk                (rx_clk),
        .one_second_edge    (one_second_edge),
        .clocks_per_second  (rx_clk_cps)
    );

    gtfmac_vnc_clock_count i_clock_count_aclk (
        .clk                (axi_aclk),
        .one_second_edge    (one_second_edge),
        .clocks_per_second  (axi_aclk_cps)
    );

    gtfmac_vnc_clock_count i_clock_count_gen_clk (
        .clk                (gen_clk),
        .one_second_edge    (one_second_edge),
        .clocks_per_second  (gen_clk_cps)
    );

    gtfmac_vnc_clock_count i_clock_count_mon_clk (
        .clk                (mon_clk),
        .one_second_edge    (one_second_edge),
        .clocks_per_second  (mon_clk_cps)
    );

    gtfmac_vnc_clock_count i_clock_count_lat_clk (
        .clk                (lat_clk),
        .one_second_edge    (one_second_edge),
        .clocks_per_second  (lat_clk_cps)
    );


    gtfmac_vnc_vnc_pif i_vnc_pif (

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

        .tx_clk_cps                         (tx_clk_cps),
        .rx_clk_cps                         (rx_clk_cps),
        .axi_aclk_cps                       (axi_aclk_cps),
        .gen_clk_cps                        (gen_clk_cps),
        .mon_clk_cps                        (mon_clk_cps),
        .lat_clk_cps                        (lat_clk_cps),

        // Debug resets
        .vnc_gtf_ch_gttxreset               (vnc_gtf_ch_gttxreset),
        .vnc_gtf_ch_txpmareset              (vnc_gtf_ch_txpmareset),
        .vnc_gtf_ch_txpcsreset              (vnc_gtf_ch_txpcsreset),
        .vnc_gtf_ch_gtrxreset               (vnc_gtf_ch_gtrxreset),
        .vnc_gtf_ch_rxpmareset              (vnc_gtf_ch_rxpmareset),
        .vnc_gtf_ch_rxdfelpmreset           (vnc_gtf_ch_rxdfelpmreset),
        .vnc_gtf_ch_eyescanreset            (vnc_gtf_ch_eyescanreset),
        .vnc_gtf_ch_rxpcsreset              (vnc_gtf_ch_rxpcsreset),
        .vnc_gtf_cm_qpll0reset              (vnc_gtf_cm_qpll0reset),

        .vnc_gtf_ch_txuserrdy               (vnc_gtf_ch_txuserrdy),
        .vnc_gtf_ch_rxuserrdy               (vnc_gtf_ch_rxuserrdy),

        .gtwiz_reset_tx_pll_and_datapath_in (gtwiz_reset_tx_pll_and_datapath_in),
        .gtwiz_reset_tx_datapath_in         (gtwiz_reset_tx_datapath_in),
        .gtwiz_reset_rx_pll_and_datapath_in (gtwiz_reset_rx_pll_and_datapath_in),
        .gtwiz_reset_rx_datapath_in         (gtwiz_reset_rx_datapath_in),

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

        .ctl_vnc_tx_inj_err                 (ctl_vnc_tx_inj_err),                   // output      logic
        .ack_vnc_tx_inj_err                 (ack_vnc_tx_inj_err),                   // input       wire
        
        .ctl_vnc_tx_inj_poison              (ctl_vnc_tx_inj_poison),                // output      logic //EG
        .ack_vnc_tx_inj_poison              (ack_vnc_tx_inj_poison),                // input       wire //EG

        .ctl_vnc_tx_start_lat_run           (ctl_vnc_tx_start_lat_run),             // output
        .ack_vnc_tx_start_lat_run           (ack_vnc_tx_start_lat_run),             // input

        .ctl_vnc_tx_inj_pause               (ctl_vnc_tx_inj_pause),                 // output      logic
        .ctl_vnc_tx_inj_pause_sa            (ctl_vnc_tx_inj_pause_sa),              // output      logic   [47:0]
        .ctl_vnc_tx_inj_pause_da            (ctl_vnc_tx_inj_pause_da),              // output      logic   [47:0]
        .ctl_vnc_tx_inj_pause_ethtype       (ctl_vnc_tx_inj_pause_ethtype),         // output      logic   [15:0]
        .ctl_vnc_tx_inj_pause_opcode        (ctl_vnc_tx_inj_pause_opcode),          // output      logic   [15:0]
        .ctl_vnc_tx_inj_pause_timer_ce      (ctl_vnc_tx_inj_pause_timer_ce),        // output      logic   [15:0]
        .ctl_vnc_tx_inj_pause_timer_pfc0    (ctl_vnc_tx_inj_pause_timer_pfc0),      // output      logic   [15:0]
        .ctl_vnc_tx_inj_pause_timer_pfc1    (ctl_vnc_tx_inj_pause_timer_pfc1),      // output      logic   [15:0]
        .ctl_vnc_tx_inj_pause_timer_pfc2    (ctl_vnc_tx_inj_pause_timer_pfc2),      // output      logic   [15:0]
        .ctl_vnc_tx_inj_pause_timer_pfc3    (ctl_vnc_tx_inj_pause_timer_pfc3),      // output      logic   [15:0]
        .ctl_vnc_tx_inj_pause_timer_pfc4    (ctl_vnc_tx_inj_pause_timer_pfc4),      // output      logic   [15:0]
        .ctl_vnc_tx_inj_pause_timer_pfc5    (ctl_vnc_tx_inj_pause_timer_pfc5),      // output      logic   [15:0]
        .ctl_vnc_tx_inj_pause_timer_pfc6    (ctl_vnc_tx_inj_pause_timer_pfc6),      // output      logic   [15:0]
        .ctl_vnc_tx_inj_pause_timer_pfc7    (ctl_vnc_tx_inj_pause_timer_pfc7),      // output      logic   [15:0]
        .ack_vnc_tx_inj_pause               (ack_vnc_tx_inj_pause),                 // input       logic

        // Monitor
        .ctl_vnc_mon_en                     (ctl_vnc_mon_en),                       // output      logic
        .ctl_rx_data_rate                   (ctl_rx_data_rate),                     // output      logic
        .ctl_rx_packet_framing_enable       (ctl_rx_packet_framing_enable),         // output      logic
        .ctl_rx_custom_preamble_en          (ctl_rx_custom_preamble_en),            // output      logic
        .ctl_vnc_rx_custom_preamble         (ctl_vnc_rx_custom_preamble),           // output      logic   [63:0]

        // VNC Statistics
        .stat_tick                          (stat_tick_from_pif),                   // output      logic

        .stat_vnc_tx_total_bytes            (stat_vnc_tx_total_bytes),              // input       wire [63:0]
        .stat_vnc_tx_total_good_bytes       (stat_vnc_tx_total_good_bytes),         // input       wire [63:0]
        .stat_vnc_tx_total_packets          (stat_vnc_tx_total_packets),            // input       wire [63:0]
        .stat_vnc_tx_total_good_packets     (stat_vnc_tx_total_good_packets),       // input       wire [63:0]
        .stat_vnc_tx_broadcast              (stat_vnc_tx_broadcast),                // input       wire [63:0]
        .stat_vnc_tx_multicast              (stat_vnc_tx_multicast),                // input       wire [63:0]
        .stat_vnc_tx_unicast                (stat_vnc_tx_unicast),                  // input       wire [63:0]
        .stat_vnc_tx_vlan                   (stat_vnc_tx_vlan),                     // input       wire [63:0]

        .stat_vnc_tx_packet_64_bytes        (stat_vnc_tx_packet_64_bytes),          // input       wire [63:0]
        .stat_vnc_tx_packet_65_127_bytes    (stat_vnc_tx_packet_65_127_bytes),      // input       wire [63:0]
        .stat_vnc_tx_packet_128_255_bytes   (stat_vnc_tx_packet_128_255_bytes),     // input       wire [63:0]
        .stat_vnc_tx_packet_256_511_bytes   (stat_vnc_tx_packet_256_511_bytes),     // input       wire [63:0]
        .stat_vnc_tx_packet_512_1023_bytes  (stat_vnc_tx_packet_512_1023_bytes),    // input       wire [63:0]
        .stat_vnc_tx_packet_1024_1518_bytes (stat_vnc_tx_packet_1024_1518_bytes),   // input       wire [63:0]
        .stat_vnc_tx_packet_1519_1522_bytes (stat_vnc_tx_packet_1519_1522_bytes),   // input       wire [63:0]
        .stat_vnc_tx_packet_1523_1548_bytes (stat_vnc_tx_packet_1523_1548_bytes),   // input       wire [63:0]
        .stat_vnc_tx_packet_1549_2047_bytes (stat_vnc_tx_packet_1549_2047_bytes),   // input       wire [63:0]
        .stat_vnc_tx_packet_2048_4095_bytes (stat_vnc_tx_packet_2048_4095_bytes),   // input       wire [63:0]
        .stat_vnc_tx_packet_4096_8191_bytes (stat_vnc_tx_packet_4096_8191_bytes),   // input       wire [63:0]
        .stat_vnc_tx_packet_8192_9215_bytes (stat_vnc_tx_packet_8192_9215_bytes),   // input       wire [63:0]

        .stat_vnc_tx_packet_small           (stat_vnc_tx_packet_small),             // input       wire [63:0]
        .stat_vnc_tx_packet_large           (stat_vnc_tx_packet_large),             // input       wire [63:0]
        .stat_vnc_tx_frame_error            (stat_vnc_tx_frame_error),              // input       wire [63:0]

        .stat_tx_unfout                     (stat_tx_unfout),                       // input       wire
        .stat_vnc_tx_overflow               (stat_vnc_tx_overflow),                 // input       wire

        .stat_vnc_rx_unicast                (stat_vnc_rx_unicast),                  // input       wire [63:0]
        .stat_vnc_rx_multicast              (stat_vnc_rx_multicast),                // input       wire [63:0]
        .stat_vnc_rx_broadcast              (stat_vnc_rx_broadcast),                // input       wire [63:0]
        .stat_vnc_rx_bad_preamble           (stat_vnc_rx_bad_preamble),             // input       wire [63:0] //EG
        .stat_vnc_rx_good_tsof_codeword      (stat_vnc_rx_good_tsof_codeword),        // input       wire [63:0]
        .stat_vnc_rx_vlan                   (stat_vnc_rx_vlan),                     // input       wire [63:0]

        .stat_vnc_rx_total_bytes            (stat_vnc_rx_total_bytes),              // input       wire [63:0]
        .stat_vnc_rx_total_good_bytes       (stat_vnc_rx_total_good_bytes),         // input       wire [63:0]
        .stat_vnc_rx_total_packets          (stat_vnc_rx_total_packets),            // input       wire [63:0]
        .stat_vnc_rx_total_good_packets     (stat_vnc_rx_total_good_packets),       // input       wire [63:0]

        .stat_vnc_rx_inrangeerr             (stat_vnc_rx_inrangeerr),               // input       wire [63:0]
        .stat_vnc_rx_bad_fcs                (stat_vnc_rx_bad_fcs),                  // input       wire [63:0]

        .stat_vnc_rx_packet_64_bytes        (stat_vnc_rx_packet_64_bytes),          // input       wire [63:0]
        .stat_vnc_rx_packet_65_127_bytes    (stat_vnc_rx_packet_65_127_bytes),      // input       wire [63:0]
        .stat_vnc_rx_packet_128_255_bytes   (stat_vnc_rx_packet_128_255_bytes),     // input       wire [63:0]
        .stat_vnc_rx_packet_256_511_bytes   (stat_vnc_rx_packet_256_511_bytes),     // input       wire [63:0]
        .stat_vnc_rx_packet_512_1023_bytes  (stat_vnc_rx_packet_512_1023_bytes),    // input       wire [63:0]
        .stat_vnc_rx_packet_1024_1518_bytes (stat_vnc_rx_packet_1024_1518_bytes),   // input       wire [63:0]
        .stat_vnc_rx_packet_1519_1522_bytes (stat_vnc_rx_packet_1519_1522_bytes),   // input       wire [63:0]
        .stat_vnc_rx_packet_1523_1548_bytes (stat_vnc_rx_packet_1523_1548_bytes),   // input       wire [63:0]
        .stat_vnc_rx_packet_1549_2047_bytes (stat_vnc_rx_packet_1549_2047_bytes),   // input       wire [63:0]
        .stat_vnc_rx_packet_2048_4095_bytes (stat_vnc_rx_packet_2048_4095_bytes),   // input       wire [63:0]
        .stat_vnc_rx_packet_4096_8191_bytes (stat_vnc_rx_packet_4096_8191_bytes),   // input       wire [63:0]
        .stat_vnc_rx_packet_8192_9215_bytes (stat_vnc_rx_packet_8192_9215_bytes),   // input       wire [63:0]

        .stat_vnc_rx_oversize               (stat_vnc_rx_oversize),                 // input       wire [63:0]
        .stat_vnc_rx_undersize              (stat_vnc_rx_undersize),                // input       wire [63:0]
        .stat_vnc_rx_toolong                (stat_vnc_rx_toolong),                  // input       wire [63:0]
        .stat_vnc_rx_packet_small           (stat_vnc_rx_packet_small),             // input       wire [63:0]
        .stat_vnc_rx_packet_large           (stat_vnc_rx_packet_large),             // input       wire [63:0]
        .stat_vnc_rx_jabber                 (stat_vnc_rx_jabber),                   // input       wire [63:0]
        .stat_vnc_rx_fragment               (stat_vnc_rx_fragment),                 // input       wire [63:0]
        .stat_vnc_rx_packet_bad_fcs         (stat_vnc_rx_packet_bad_fcs),           // input       wire [63:0]
        

        .stat_vnc_rx_user_pause             (stat_vnc_rx_user_pause),               // input       wire [63:0]
        .stat_vnc_rx_pause                  (stat_vnc_rx_pause)                     // input       wire [63:0]

    );




endmodule

module gtfmac_vnc_tx_gen (

    input       wire            axi_aclk,
    input       wire            axi_aresetn,

    input       wire            gen_clk,
    input       wire            gen_rst,

    input       wire            ctl_vnc_frm_gen_en,
    input       wire            ctl_vnc_frm_gen_mode,
    input       wire    [13:0]  ctl_vnc_max_len,
    input       wire    [13:0]  ctl_vnc_min_len,
    input       wire    [31:0]  ctl_num_frames,
    output      wire            ack_frm_gen_done,

    input       wire            ctl_tx_custom_preamble_en,
    input       wire    [63:0]  ctl_vnc_tx_custom_preamble,
    input       wire            ctl_tx_start_framing_enable,
    input       wire            ctl_tx_variable_ipg,

    input       wire            ctl_tx_fcs_ins_enable,
    input       wire            ctl_tx_data_rate,

    input       wire            ctl_vnc_tx_inj_err,
    output      wire            ack_vnc_tx_inj_err,
    
    input       wire            ctl_vnc_tx_inj_poison, //EG
    output      wire            ack_vnc_tx_inj_poison, //EG

    input       wire            ctl_vnc_tx_start_lat_run,
    output      wire            ack_vnc_tx_start_lat_run,

    input       wire            ctl_vnc_tx_inj_pause,
    input       wire    [47:0]  ctl_vnc_tx_inj_pause_sa,
    input       wire    [47:0]  ctl_vnc_tx_inj_pause_da,
    input       wire    [15:0]  ctl_vnc_tx_inj_pause_ethtype,
    input       wire    [15:0]  ctl_vnc_tx_inj_pause_opcode,
    input       wire    [15:0]  ctl_vnc_tx_inj_pause_timer_ce,
    input       wire    [15:0]  ctl_vnc_tx_inj_pause_timer_pfc0,
    input       wire    [15:0]  ctl_vnc_tx_inj_pause_timer_pfc1,
    input       wire    [15:0]  ctl_vnc_tx_inj_pause_timer_pfc2,
    input       wire    [15:0]  ctl_vnc_tx_inj_pause_timer_pfc3,
    input       wire    [15:0]  ctl_vnc_tx_inj_pause_timer_pfc4,
    input       wire    [15:0]  ctl_vnc_tx_inj_pause_timer_pfc5,
    input       wire    [15:0]  ctl_vnc_tx_inj_pause_timer_pfc6,
    input       wire    [15:0]  ctl_vnc_tx_inj_pause_timer_pfc7,
    output      wire            ack_vnc_tx_inj_pause,

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
    output      wire [15:0]     stat_vnc_tx_overflow,
    output      wire [15:0]     stat_tx_unfout,

    input       wire            stat_clk,
    input       wire            stat_rst,
    input       wire            stat_tick,

    output      wire [63:0]     stat_vnc_tx_total_bytes,
    output      wire [63:0]     stat_vnc_tx_total_good_bytes,
    output      wire [63:0]     stat_vnc_tx_total_packets,
    output      wire [63:0]     stat_vnc_tx_total_good_packets,
    output      wire [63:0]     stat_vnc_tx_broadcast,
    output      wire [63:0]     stat_vnc_tx_multicast,
    output      wire [63:0]     stat_vnc_tx_unicast,
    output      wire [63:0]     stat_vnc_tx_vlan,

    output      wire [63:0]     stat_vnc_tx_packet_64_bytes,
    output      wire [63:0]     stat_vnc_tx_packet_65_127_bytes,
    output      wire [63:0]     stat_vnc_tx_packet_128_255_bytes,
    output      wire [63:0]     stat_vnc_tx_packet_256_511_bytes,
    output      wire [63:0]     stat_vnc_tx_packet_512_1023_bytes,
    output      wire [63:0]     stat_vnc_tx_packet_1024_1518_bytes,
    output      wire [63:0]     stat_vnc_tx_packet_1519_1522_bytes,
    output      wire [63:0]     stat_vnc_tx_packet_1523_1548_bytes,
    output      wire [63:0]     stat_vnc_tx_packet_1549_2047_bytes,
    output      wire [63:0]     stat_vnc_tx_packet_2048_4095_bytes,
    output      wire [63:0]     stat_vnc_tx_packet_4096_8191_bytes,
    output      wire [63:0]     stat_vnc_tx_packet_8192_9215_bytes,

    output      wire [63:0]     stat_vnc_tx_packet_small,
    output      wire [63:0]     stat_vnc_tx_packet_large,
    output      wire [63:0]     stat_vnc_tx_frame_error,
    output      wire [63:0]     stat_vnc_tx_bad_fcs

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
    wire                frm_gen_poison; //EG

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
    wire                fcs_poison; //EG

    wire                tx_credit;

    wire                buf_ena;
    wire                buf_pre;
    wire                buf_sop;
    wire    [63:0]      buf_data;
    wire    [7:0]       buf_last;
    wire                buf_err;
    wire                buf_poison; //EG

    wire                tx_buffer_overflow;
    wire                frm_gen_done;


    gtfmac_vnc_prbs_gen_64 i_prbs_gen_64 (

        .clk        (gen_clk),
        .rst        (gen_rst),

        .en         (1'b1),
        .prbs_out   (prbs_data)

    );

    wire    ctl_tx_inj_err_sync;
    wire    ctl_tx_inj_poison_sync; //EG
    wire    ack_tx_inj_pause;
    wire    frm_gen_en;
    wire    ctl_vnc_tx_start_lat_run_sync;
    wire    ack_tx_start_lat_run;

    gtfmac_vnc_syncer_level i_sync_ctl_tx_inj_err (

      .reset      (~gen_rst),
      .clk        (gen_clk),

      .datain     (ctl_vnc_tx_inj_err),
      .dataout    (ctl_vnc_tx_inj_err_sync)

    );
    
    gtfmac_vnc_syncer_level i_sync_ctl_tx_inj_poison ( //EG

      .reset      (~gen_rst),
      .clk        (gen_clk),

      .datain     (ctl_vnc_tx_inj_poison),
      .dataout    (ctl_vnc_tx_inj_poison_sync)

    );

    gtfmac_vnc_syncer_level i_sync_ctl_frm_gen_en (

      .reset      (~gen_rst),
      .clk        (gen_clk),

      .datain     (ctl_vnc_frm_gen_en),
      .dataout    (frm_gen_en)

    );

    gtfmac_vnc_syncer_pulse i_ack_ctl_frm_gen_done (
       .clkin        (gen_clk),
       .clkin_reset  (~gen_rst),
       .clkout       (axi_aclk),
       .clkout_reset (axi_aresetn),

       .pulsein      (frm_gen_done),
       .pulseout     (ack_frm_gen_done)
    );

    gtfmac_vnc_syncer_pulse i_ack_vnc_tx_inj_err (
       .clkin        (gen_clk),
       .clkin_reset  (~gen_rst),
       .clkout       (axi_aclk),
       .clkout_reset (axi_aresetn),

       .pulsein      (frm_gen_err),
       .pulseout     (ack_vnc_tx_inj_err)
    );
    
    gtfmac_vnc_syncer_pulse i_ack_vnc_tx_inj_poison ( //EG
       .clkin        (gen_clk),
       .clkin_reset  (~gen_rst),
       .clkout       (axi_aclk),
       .clkout_reset (axi_aresetn),

       .pulsein      (frm_gen_poison),
       .pulseout     (ack_vnc_tx_inj_poison) 
    );

    gtfmac_vnc_syncer_pulse i_ack_vnc_tx_inj_pause (
       .clkin        (gen_clk),
       .clkin_reset  (~gen_rst),
       .clkout       (axi_aclk),
       .clkout_reset (axi_aresetn),

       .pulsein      (ack_tx_inj_pause),
       .pulseout     (ack_vnc_tx_inj_pause)
    );

    gtfmac_vnc_syncer_level i_sync_ctl_vnc_tx_start_lat_run (

      .reset      (~gen_rst),
      .clk        (gen_clk),

      .datain     (ctl_vnc_tx_start_lat_run),
      .dataout    (ctl_vnc_tx_start_lat_run_sync)

    );

    gtfmac_vnc_syncer_pulse i_ack_vnc_tx_start_lat_run (
       .clkin        (gen_clk),
       .clkin_reset  (~gen_rst),
       .clkout       (axi_aclk),
       .clkout_reset (axi_aresetn),

       .pulsein      (ack_tx_start_lat_run),
       .pulseout     (ack_vnc_tx_start_lat_run)
    );

    gtfmac_vnc_tx_frm_gen i_tx_frm_gen  (

        .clk                            (gen_clk),
        .rst                            (gen_rst),
        .bp                             (bp),

        .ctl_frm_gen_en                 (frm_gen_en),
        .ctl_frm_gen_mode               (ctl_vnc_frm_gen_mode),
        .ctl_max_len                    (ctl_vnc_max_len),
        .ctl_min_len                    (ctl_vnc_min_len),
        .ctl_num_frames                 (ctl_num_frames),
        .frm_gen_done                   (frm_gen_done),

        .ctl_tx_start_framing_enable    (ctl_tx_start_framing_enable),
        .ctl_tx_custom_preamble_en      (ctl_tx_custom_preamble_en),
        .ctl_tx_custom_preamble         (ctl_vnc_tx_custom_preamble),
        .ctl_tx_fcs_ins_enable          (ctl_tx_fcs_ins_enable),

        .ctl_tx_inj_err                 (ctl_vnc_tx_inj_err_sync),
        
        .ctl_tx_inj_poison              (ctl_vnc_tx_inj_poison_sync), //EG

        .ctl_tx_start_lat_run           (ctl_vnc_tx_start_lat_run_sync),
        .ack_tx_start_lat_run           (ack_tx_start_lat_run),

        .ctl_tx_inj_pause               (ctl_vnc_tx_inj_pause),
        .ctl_tx_inj_pause_sa            (ctl_vnc_tx_inj_pause_sa),
        .ctl_tx_inj_pause_da            (ctl_vnc_tx_inj_pause_da),
        .ctl_tx_inj_pause_ethtype       (ctl_vnc_tx_inj_pause_ethtype),
        .ctl_tx_inj_pause_opcode        (ctl_vnc_tx_inj_pause_opcode),
        .ctl_tx_inj_pause_timer_ce      (ctl_vnc_tx_inj_pause_timer_ce),
        .ctl_tx_inj_pause_timer_pfc0    (ctl_vnc_tx_inj_pause_timer_pfc0),
        .ctl_tx_inj_pause_timer_pfc1    (ctl_vnc_tx_inj_pause_timer_pfc1),
        .ctl_tx_inj_pause_timer_pfc2    (ctl_vnc_tx_inj_pause_timer_pfc2),
        .ctl_tx_inj_pause_timer_pfc3    (ctl_vnc_tx_inj_pause_timer_pfc3),
        .ctl_tx_inj_pause_timer_pfc4    (ctl_vnc_tx_inj_pause_timer_pfc4),
        .ctl_tx_inj_pause_timer_pfc5    (ctl_vnc_tx_inj_pause_timer_pfc5),
        .ctl_tx_inj_pause_timer_pfc6    (ctl_vnc_tx_inj_pause_timer_pfc6),
        .ctl_tx_inj_pause_timer_pfc7    (ctl_vnc_tx_inj_pause_timer_pfc7),
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
        .poison                         (frm_gen_poison), //EG

        .bad_fcs_incr                   (frm_gen_bad_fcs),
        .vlan_incr                      (frm_gen_vlan),
        .broadcast_incr                 (frm_gen_broadcast),
        .multicast_incr                 (frm_gen_multicast),
        .unicast_incr                   (frm_gen_unicast)

    );


    // This logic has a latency of three cycles (d3)
    gtfmac_vnc_tx_fcs  i_tx_fcs  (

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
        .i_poison               (frm_gen_poison), //EG

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
        .o_poison               (fcs_poison), //EG

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



    gtfmac_vnc_ra_buf   # (
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
        .din_poison                     (fcs_poison), //EG

        .in_overflow                    (),  // TODO

        .out_clk                        (tx_clk),
        .out_rst                        (tx_rst),

        .out_credit                     (tx_credit),

        .dout_ena                       (buf_ena),
        .dout_pre                       (buf_pre),
        .dout_sop                       (buf_sop),
        .dout_data                      (buf_data),
        .dout_last                      (buf_last),
        .dout_err                       (buf_err),
        .dout_poison                    (buf_poison) //EG


    );


    gtfmac_vnc_tx_gtfmac_if  # (
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

    gtfmac_vnc_pkt_stat i_tx_gen_stat   (

        .clk                            (gen_clk),
        .rst                            (gen_rst),

        .din_ena                        (fcs_ena),
        .din_pre                        (fcs_pre),
        .din_sop                        (fcs_sop),
        .din_data                       (fcs_data),
        .din_eop                        (fcs_eop),
        .din_mty                        (fcs_mty),
        .din_err                        (fcs_err),
        .din_empty                      (1'b0),

        .din_bad_fcs                    (fcs_bad_fcs),
        .din_vlan                       (fcs_vlan),
        .din_broadcast                  (fcs_broadcast),
        .din_multicast                  (fcs_multicast),
        .din_unicast                    (fcs_unicast),

        .add_4                          (ctl_tx_fcs_ins_enable),

        .stat_clk                       (stat_clk),
        .stat_rst                       (stat_rst),
        .stat_tick                      (stat_tick),

        // Packet and Byte Counters
        .stat_total_bytes               (stat_vnc_tx_total_bytes),
        .stat_total_good_bytes          (stat_vnc_tx_total_good_bytes),
        .stat_total_packets             (stat_vnc_tx_total_packets),
        .stat_total_good_packets        (stat_vnc_tx_total_good_packets),
        .stat_broadcast                 (stat_vnc_tx_broadcast),
        .stat_multicast                 (stat_vnc_tx_multicast),
        .stat_unicast                   (stat_vnc_tx_unicast),
        .stat_vlan                      (stat_vnc_tx_vlan),

        // Bucket Counters
        .stat_packet_64_bytes           (stat_vnc_tx_packet_64_bytes),
        .stat_packet_65_127_bytes       (stat_vnc_tx_packet_65_127_bytes),
        .stat_packet_128_255_bytes      (stat_vnc_tx_packet_128_255_bytes),
        .stat_packet_256_511_bytes      (stat_vnc_tx_packet_256_511_bytes),
        .stat_packet_512_1023_bytes     (stat_vnc_tx_packet_512_1023_bytes),
        .stat_packet_1024_1518_bytes    (stat_vnc_tx_packet_1024_1518_bytes),
        .stat_packet_1519_1522_bytes    (stat_vnc_tx_packet_1519_1522_bytes),
        .stat_packet_1523_1548_bytes    (stat_vnc_tx_packet_1523_1548_bytes),
        .stat_packet_1549_2047_bytes    (stat_vnc_tx_packet_1549_2047_bytes),
        .stat_packet_2048_4095_bytes    (stat_vnc_tx_packet_2048_4095_bytes),
        .stat_packet_4096_8191_bytes    (stat_vnc_tx_packet_4096_8191_bytes),
        .stat_packet_8192_9215_bytes    (stat_vnc_tx_packet_8192_9215_bytes),

        // Error Counters
        .stat_packet_small              (stat_vnc_tx_packet_small),
        .stat_packet_large              (stat_vnc_tx_packet_large),
        .stat_bad_fcs                   (stat_vnc_tx_bad_fcs),
        .stat_frame_error               (stat_vnc_tx_frame_error)

    );

    wire    tx_tick;

    gtfmac_vnc_syncer_pulse i_tx_stat_tick (
       .clkin        (stat_clk),
       .clkin_reset  (~stat_rst),
       .clkout       (tx_clk),
       .clkout_reset (~tx_rst),

       .pulsein      (stat_tick),
       .pulseout     (tx_tick)
    );


    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (16),
        .EDGE           (1),
        .SATURATE       (1)
    )
    i_stat_tx_buffer_overflow   (

        .clk        (tx_clk),
        .incr       (tx_buffer_overflow),
        .snapshot   (tx_tick),
        .stat       (stat_vnc_tx_overflow)
    );


    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (16),
        .EDGE           (1),
        .SATURATE       (1)
    )
    i_stat_tx_unfout   (

        .clk        (tx_clk),
        .incr       (tx_unfout),
        .snapshot   (tx_tick),
        .stat       (stat_tx_unfout)
    );


endmodule

module gtfmac_vnc_tx_frm_gen (

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
    
    input       wire            ctl_tx_inj_poison, //EG

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

    gtfmac_vnc_syncer_level i_sync_frm_gen_mode (

      .reset      (~rst),
      .clk        (clk),

      .datain     (ctl_frm_gen_mode),
      .dataout    (frm_gen_mode)

    );

    logic   frm_gen_en, frm_gen_en_R;

    gtfmac_vnc_syncer_level i_sync_frm_gen_en (

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
        poison                  <= 1'b0; //EG
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
                    poison              <= ctl_tx_inj_poison; //EG
                    cycle_cnt           <= 11'd0;
                    state               <= IDLE_STATE;
                end
                else if (cycle_cnt == 10'd8 && !ctl_tx_fcs_ins_enable) begin // 60B
                    eop                 <= 1'b1;
                    mty                 <= 4'd4;
                    ack_tx_inj_pause    <= 1'b1;
                    err                 <= ctl_tx_inj_err;
                    poison              <= ctl_tx_inj_poison; //EG
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
                        poison          <= ctl_tx_inj_poison; //EG
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
            poison                  <= 1'b0; //EG
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

module gtfmac_vnc_prbs_gen_64 (
  input en,
  output [63:0] prbs_out,
  input rst,
  input clk);

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

module gtfmac_vnc_tx_gtfmac_if # (
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
    input   wire            din_poison, //EG
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
    assign  gen_tpoison = din_poison; // TODO
//    assign  gen_tpoison = 1'b0; // TODO

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

    gtfmac_vnc_simple_fifo #(
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

module gtfmac_vnc_rx_mon (

    input       wire            mon_clk,
    input       wire            mon_rst,

    input       wire            ctl_vnc_mon_en,
    input       wire            ctl_rx_data_rate,
    input       wire            ctl_rx_packet_framing_enable,
    input       wire            ctl_rx_custom_preamble_en,
    input       wire    [63:0]  ctl_vnc_rx_custom_preamble,
    input       wire    [13:0]  ctl_vnc_max_len,
    input       wire    [13:0]  ctl_vnc_min_len,

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
    input       wire            stat_tick,

    output      wire [63:0]     stat_vnc_rx_unicast,
    output      wire [63:0]     stat_vnc_rx_multicast,
    output      wire [63:0]     stat_vnc_rx_broadcast,
    output      wire [63:0]     stat_vnc_rx_bad_preamble,
    output      wire [63:0]     stat_vnc_rx_good_tsof_codeword,
    output      wire [63:0]     stat_vnc_rx_vlan,

    output      wire [63:0]     stat_vnc_rx_total_bytes,
    output      wire [63:0]     stat_vnc_rx_total_good_bytes,
    output      wire [63:0]     stat_vnc_rx_total_packets,
    output      wire [63:0]     stat_vnc_rx_total_good_packets,

    output      wire [63:0]     stat_vnc_rx_inrangeerr,
    output      wire [63:0]     stat_vnc_rx_bad_fcs,

    output      wire [63:0]     stat_vnc_rx_packet_64_bytes,
    output      wire [63:0]     stat_vnc_rx_packet_65_127_bytes,
    output      wire [63:0]     stat_vnc_rx_packet_128_255_bytes,
    output      wire [63:0]     stat_vnc_rx_packet_256_511_bytes,
    output      wire [63:0]     stat_vnc_rx_packet_512_1023_bytes,
    output      wire [63:0]     stat_vnc_rx_packet_1024_1518_bytes,
    output      wire [63:0]     stat_vnc_rx_packet_1519_1522_bytes,
    output      wire [63:0]     stat_vnc_rx_packet_1523_1548_bytes,
    output      wire [63:0]     stat_vnc_rx_packet_1549_2047_bytes,
    output      wire [63:0]     stat_vnc_rx_packet_2048_4095_bytes,
    output      wire [63:0]     stat_vnc_rx_packet_4096_8191_bytes,
    output      wire [63:0]     stat_vnc_rx_packet_8192_9215_bytes,

    output      wire [63:0]     stat_vnc_rx_oversize,
    output      wire [63:0]     stat_vnc_rx_undersize,
    output      wire [63:0]     stat_vnc_rx_toolong,
    output      wire [63:0]     stat_vnc_rx_packet_small,
    output      wire [63:0]     stat_vnc_rx_packet_large,
    output      wire [63:0]     stat_vnc_rx_jabber,
    output      wire [63:0]     stat_vnc_rx_fragment,
    output      wire [63:0]     stat_vnc_rx_packet_bad_fcs,

    output      wire [63:0]     stat_vnc_rx_user_pause,
    output      wire [63:0]     stat_vnc_rx_pause


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
    wire                fcs_crc_bad;
    
    wire                tsof_codeword_matched;


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

    gtfmac_vnc_ra_buf   # (
        .MAX_CREDITS    (0)
    )
    i_rx_mon_buf   (

        .in_clk                         (rx_clk),
        .in_rst                         (rx_rst),

        .in_bp                          (),
        .in_overflow                    (), // TODO

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

    gtfmac_vnc_mon_parser  i_mon_parser (

        .clk                            (mon_clk),                      // input   wire
        .rst                            (mon_rst),                      // input   wire

        .ctl_rx_custom_preamble_en      (ctl_rx_custom_preamble_en),    // input   wire
        .ctl_rx_custom_preamble         (ctl_vnc_rx_custom_preamble),   // input   wire
        
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
    gtfmac_vnc_tx_fcs  i_rx_fcs  (

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


    gtfmac_vnc_pkt_stat i_rx_mon_stat   (

        .clk                            (mon_clk),
        .rst                            (mon_rst),

        .din_ena                        (fcs_ena),
        .din_pre                        (1'b0),
        .din_sop                        (fcs_sop),
        .din_data                       (fcs_data),
        .din_eop                        (fcs_eop),
        .din_mty                        (fcs_mty),
        .din_err                        (fcs_err),
        .din_empty                      (fcs_ena & fcs_empty), 

        .din_bad_fcs                    (fcs_crc_val & fcs_crc_bad),
        
        .din_preamble_bad               (fcs_preamble_bad), //EG
        .din_codeword_matched           (fcs_codeword_matched),
        .din_vlan                       (fcs_vlan),
        .din_broadcast                  (fcs_broadcast),
        .din_multicast                  (fcs_multicast),
        .din_unicast                    (fcs_unicast),

        .add_4                          (1'b0),

        .stat_clk                       (stat_clk),
        .stat_rst                       (stat_rst),
        .stat_tick                      (stat_tick),

        // Packet and Byte Counters
        .stat_total_bytes               (stat_vnc_rx_total_bytes),
        .stat_total_good_bytes          (stat_vnc_rx_total_good_bytes),
        .stat_total_packets             (stat_vnc_rx_total_packets),
        .stat_total_good_packets        (stat_vnc_rx_total_good_packets),
        .stat_broadcast                 (stat_vnc_rx_broadcast),
        .stat_multicast                 (stat_vnc_rx_multicast),
        .stat_unicast                   (stat_vnc_rx_unicast),
        .stat_bad_preamble              (stat_vnc_rx_bad_preamble), //EG
        .stat_good_codeword             (stat_vnc_rx_good_tsof_codeword),
        .stat_vlan                      (stat_vnc_rx_vlan),

        // Bucket Counters
        .stat_packet_64_bytes           (stat_vnc_rx_packet_64_bytes),
        .stat_packet_65_127_bytes       (stat_vnc_rx_packet_65_127_bytes),
        .stat_packet_128_255_bytes      (stat_vnc_rx_packet_128_255_bytes),
        .stat_packet_256_511_bytes      (stat_vnc_rx_packet_256_511_bytes),
        .stat_packet_512_1023_bytes     (stat_vnc_rx_packet_512_1023_bytes),
        .stat_packet_1024_1518_bytes    (stat_vnc_rx_packet_1024_1518_bytes),
        .stat_packet_1519_1522_bytes    (stat_vnc_rx_packet_1519_1522_bytes),
        .stat_packet_1523_1548_bytes    (stat_vnc_rx_packet_1523_1548_bytes),
        .stat_packet_1549_2047_bytes    (stat_vnc_rx_packet_1549_2047_bytes),
        .stat_packet_2048_4095_bytes    (stat_vnc_rx_packet_2048_4095_bytes),
        .stat_packet_4096_8191_bytes    (stat_vnc_rx_packet_4096_8191_bytes),
        .stat_packet_8192_9215_bytes    (stat_vnc_rx_packet_8192_9215_bytes),

        // Error Counters
        .stat_packet_small              (stat_vnc_rx_packet_small),
        .stat_packet_large              (stat_vnc_rx_packet_large),
        .stat_bad_fcs                   (stat_vnc_rx_bad_fcs),
        .stat_frame_error               ()

    );


endmodule

module gtfmac_vnc_mon_parser (

    input   wire            clk,
    input   wire            rst,

    input   wire            ctl_rx_custom_preamble_en,
    input   wire   [63:0]   ctl_rx_custom_preamble,
    input   wire            tsof_codeword_matched, //EG specified wire type

    input   logic           din_ena,
    input   logic           din_sop,
    input   logic  [63:0]   din_data,
    input   logic           din_eop,
    input   logic  [2:0]    din_mty,
    input   logic           din_err,
    input   logic           din_empty,

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

module gtfmac_vnc_rx_gtfmac_if (

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
    
    logic  [7:0]    expected_cw;//EG capture expected cw based on prev sof value
    logic  [7:0]    q_rx_axis_tpre_d;
    
    
    always @(posedge rx_axis_clk) begin //Kennan
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
                        
                        ///////////////// Start of simultaneous eop/sop //EG
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
                        ///////////////// End of simultaneous eop/sop //EG

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

// ***************************************************************************
// Misc control and status registers
// ***************************************************************************

`ifndef GTFMAC_VNC_VERSION
`define GTFMAC_VNC_VERSION 16'h10
`endif

module gtfmac_vnc_vnc_pif (

    // ============================================================
    // AXI Ports : BEGIN
    // ============================================================

    // AXI Globals
    input                   axi_aclk,
    input                   axi_aresetn,

    // AXI: Read Address Channel
    input   wire    [31:0]  axil_araddr,
    input   wire            axil_arvalid,
    output  reg             axil_arready,

    // Read Data Channel
    output  reg     [31:0]  axil_rdata,
    output  wire    [1:0]   axil_rresp,
    output  reg             axil_rvalid,
    input                   axil_rready,

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
    input                   axil_bready,

    // ============================================================
    // AXI Ports : END
    // ============================================================

    // Clock counters

    input       logic [31:0]    tx_clk_cps,
    input       logic [31:0]    rx_clk_cps,
    input       logic [31:0]    axi_aclk_cps,
    input       logic [31:0]    gen_clk_cps,
    input       logic [31:0]    mon_clk_cps,
    input       logic [31:0]    lat_clk_cps,

    // Debug resets
    output      logic           vnc_gtf_ch_gttxreset,
    output      logic           vnc_gtf_ch_txpmareset,
    output      logic           vnc_gtf_ch_txpcsreset,
    output      logic           vnc_gtf_ch_gtrxreset,
    output      logic           vnc_gtf_ch_rxpmareset,
    output      logic           vnc_gtf_ch_rxdfelpmreset,
    output      logic           vnc_gtf_ch_eyescanreset,
    output      logic           vnc_gtf_ch_rxpcsreset,
    output      logic           vnc_gtf_cm_qpll0reset,

    output      logic           vnc_gtf_ch_txuserrdy,
    output      logic           vnc_gtf_ch_rxuserrdy,

    output      logic           gtwiz_reset_tx_pll_and_datapath_in,
    output      logic           gtwiz_reset_tx_datapath_in,
    output      logic           gtwiz_reset_rx_pll_and_datapath_in,
    output      logic           gtwiz_reset_rx_datapath_in,

    // GTFMAC Status
    input       logic           stat_gtf_tx_rst,
    input       logic           stat_gtf_rx_rst,
    input       logic           stat_gtf_block_lock,
    input       wire            stat_gtf_rx_internal_local_fault,
    input       wire            stat_gtf_rx_local_fault,
    input       wire            stat_gtf_rx_received_local_fault,
    input       wire            stat_gtf_rx_remote_fault,

    // Bitslip correction
    output      logic           ctl_gb_seq_sync,
    output      logic           ctl_disable_bitslip,
    output      logic           ctl_correct_bitslip,
    input       logic   [6:0]   stat_bitslip_cnt,
    input       logic   [6:0]   stat_bitslip_issued,
    input       logic           stat_excessive_bitslip,
    input       logic           stat_bitslip_locked,
    input       logic           stat_bitslip_busy,
    input       logic           stat_bitslip_done,

    // Generator
    output      logic           ctl_vnc_frm_gen_en,
    output      logic           ctl_vnc_frm_gen_mode,
    output      logic   [13:0]  ctl_vnc_max_len,
    output      logic   [13:0]  ctl_vnc_min_len,
    output      logic   [31:0]  ctl_num_frames,
    input       logic           ack_frm_gen_done,

    output      logic           ctl_tx_start_framing_enable,
    output      logic           ctl_tx_custom_preamble_en,
    output      logic   [63:0]  ctl_vnc_tx_custom_preamble,
    output      logic           ctl_tx_variable_ipg,

    output      logic           ctl_tx_fcs_ins_enable,
    output      logic           ctl_tx_data_rate,

    output      logic           ctl_vnc_tx_inj_err,
    input       wire            ack_vnc_tx_inj_err,
    
    output      logic           ctl_vnc_tx_inj_poison, //EG
    input       wire            ack_vnc_tx_inj_poison, //EG

    output      logic           ctl_vnc_tx_inj_pause,
    output      logic   [47:0]  ctl_vnc_tx_inj_pause_sa,
    output      logic   [47:0]  ctl_vnc_tx_inj_pause_da,
    output      logic   [15:0]  ctl_vnc_tx_inj_pause_ethtype,
    output      logic   [15:0]  ctl_vnc_tx_inj_pause_opcode,
    output      logic   [15:0]  ctl_vnc_tx_inj_pause_timer_ce,
    output      logic   [15:0]  ctl_vnc_tx_inj_pause_timer_pfc0,
    output      logic   [15:0]  ctl_vnc_tx_inj_pause_timer_pfc1,
    output      logic   [15:0]  ctl_vnc_tx_inj_pause_timer_pfc2,
    output      logic   [15:0]  ctl_vnc_tx_inj_pause_timer_pfc3,
    output      logic   [15:0]  ctl_vnc_tx_inj_pause_timer_pfc4,
    output      logic   [15:0]  ctl_vnc_tx_inj_pause_timer_pfc5,
    output      logic   [15:0]  ctl_vnc_tx_inj_pause_timer_pfc6,
    output      logic   [15:0]  ctl_vnc_tx_inj_pause_timer_pfc7,
    input       logic           ack_vnc_tx_inj_pause,

    // Monitor
    output      logic           ctl_vnc_mon_en,
    output      logic           ctl_rx_data_rate,
    output      logic           ctl_rx_packet_framing_enable,
    output      logic           ctl_rx_custom_preamble_en,
    output      logic   [63:0]  ctl_vnc_rx_custom_preamble,

    // VNC Statistics
    output      logic           stat_tick,

    // Latency run controls
    output      logic           ctl_vnc_tx_start_lat_run,
    input       wire            ack_vnc_tx_start_lat_run,

    input       wire [63:0]     stat_vnc_tx_total_bytes,
    input       wire [63:0]     stat_vnc_tx_total_good_bytes,
    input       wire [63:0]     stat_vnc_tx_total_packets,
    input       wire [63:0]     stat_vnc_tx_total_good_packets,
    input       wire [63:0]     stat_vnc_tx_broadcast,
    input       wire [63:0]     stat_vnc_tx_multicast,
    input       wire [63:0]     stat_vnc_tx_unicast,
    input       wire [63:0]     stat_vnc_tx_vlan,

    input       wire [63:0]     stat_vnc_tx_packet_64_bytes,
    input       wire [63:0]     stat_vnc_tx_packet_65_127_bytes,
    input       wire [63:0]     stat_vnc_tx_packet_128_255_bytes,
    input       wire [63:0]     stat_vnc_tx_packet_256_511_bytes,
    input       wire [63:0]     stat_vnc_tx_packet_512_1023_bytes,
    input       wire [63:0]     stat_vnc_tx_packet_1024_1518_bytes,
    input       wire [63:0]     stat_vnc_tx_packet_1519_1522_bytes,
    input       wire [63:0]     stat_vnc_tx_packet_1523_1548_bytes,
    input       wire [63:0]     stat_vnc_tx_packet_1549_2047_bytes,
    input       wire [63:0]     stat_vnc_tx_packet_2048_4095_bytes,
    input       wire [63:0]     stat_vnc_tx_packet_4096_8191_bytes,
    input       wire [63:0]     stat_vnc_tx_packet_8192_9215_bytes,

    input       wire [63:0]     stat_vnc_tx_packet_small,
    input       wire [63:0]     stat_vnc_tx_packet_large,
    input       wire [63:0]     stat_vnc_tx_frame_error,

    input       wire [15:0]     stat_tx_unfout,
    input       wire [15:0]     stat_vnc_tx_overflow,

    input       wire [63:0]     stat_vnc_rx_unicast,
    input       wire [63:0]     stat_vnc_rx_multicast,
    input       wire [63:0]     stat_vnc_rx_broadcast,
    input       wire [63:0]     stat_vnc_rx_bad_preamble,
    input       wire [63:0]     stat_vnc_rx_good_tsof_codeword,
    input       wire [63:0]     stat_vnc_rx_vlan,

    input       wire [63:0]     stat_vnc_rx_total_bytes,
    input       wire [63:0]     stat_vnc_rx_total_good_bytes,
    input       wire [63:0]     stat_vnc_rx_total_packets,
    input       wire [63:0]     stat_vnc_rx_total_good_packets,

    input       wire [63:0]     stat_vnc_rx_inrangeerr,
    input       wire [63:0]     stat_vnc_rx_bad_fcs,

    input       wire [63:0]     stat_vnc_rx_packet_64_bytes,
    input       wire [63:0]     stat_vnc_rx_packet_65_127_bytes,
    input       wire [63:0]     stat_vnc_rx_packet_128_255_bytes,
    input       wire [63:0]     stat_vnc_rx_packet_256_511_bytes,
    input       wire [63:0]     stat_vnc_rx_packet_512_1023_bytes,
    input       wire [63:0]     stat_vnc_rx_packet_1024_1518_bytes,
    input       wire [63:0]     stat_vnc_rx_packet_1519_1522_bytes,
    input       wire [63:0]     stat_vnc_rx_packet_1523_1548_bytes,
    input       wire [63:0]     stat_vnc_rx_packet_1549_2047_bytes,
    input       wire [63:0]     stat_vnc_rx_packet_2048_4095_bytes,
    input       wire [63:0]     stat_vnc_rx_packet_4096_8191_bytes,
    input       wire [63:0]     stat_vnc_rx_packet_8192_9215_bytes,

    input       wire [63:0]     stat_vnc_rx_oversize,
    input       wire [63:0]     stat_vnc_rx_undersize,
    input       wire [63:0]     stat_vnc_rx_toolong,
    input       wire [63:0]     stat_vnc_rx_packet_small,
    input       wire [63:0]     stat_vnc_rx_packet_large,
    input       wire [63:0]     stat_vnc_rx_jabber,
    input       wire [63:0]     stat_vnc_rx_fragment,
    input       wire [63:0]     stat_vnc_rx_packet_bad_fcs,

    input       wire [63:0]     stat_vnc_rx_user_pause,
    input       wire [63:0]     stat_vnc_rx_pause

);

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

            vnc_gtf_ch_gttxreset                <= 'd0;
            vnc_gtf_ch_txpmareset               <= 'd0;
            vnc_gtf_ch_txpcsreset               <= 'd0;
            vnc_gtf_ch_gtrxreset                <= 'd0;
            vnc_gtf_ch_rxpmareset               <= 'd0;
            vnc_gtf_ch_rxdfelpmreset            <= 'd0;
            vnc_gtf_ch_eyescanreset             <= 'd0;
            vnc_gtf_ch_rxpcsreset               <= 'd0;
            vnc_gtf_cm_qpll0reset               <= 'd0;

            vnc_gtf_ch_txuserrdy                <= 'd0;
            vnc_gtf_ch_rxuserrdy                <= 'd0;

            gtwiz_reset_tx_pll_and_datapath_in  <= 'd0;
            gtwiz_reset_tx_datapath_in          <= 'd0; // 1'b1;
            gtwiz_reset_rx_pll_and_datapath_in  <= 'd0;
            gtwiz_reset_rx_datapath_in          <= 'd0; // 1'b1;

            ctl_tx_data_rate                    <= 'd0;
            ctl_tx_fcs_ins_enable               <= 'd0;
            ctl_tx_start_framing_enable         <= 'd0;
            ctl_tx_custom_preamble_en           <= 'd0;
            ctl_rx_data_rate                    <= 'd0;
            ctl_rx_custom_preamble_en           <= 'd0;
            ctl_rx_packet_framing_enable        <= 'd0;
            ctl_vnc_frm_gen_en                  <= 'd0;
            ctl_vnc_frm_gen_mode                <= 'd0;
            ctl_num_frames                      <= 'd0;
            ctl_vnc_mon_en                      <= 'd0;
            ctl_vnc_max_len                     <= 'd0;
            ctl_vnc_min_len                     <= 'd0;
            ctl_vnc_tx_custom_preamble[31:0]    <= 32'h55555555;
            ctl_vnc_tx_custom_preamble[63:32]   <= 32'hd5555555;
            ctl_tx_variable_ipg                 <= 'd0;
            ctl_vnc_rx_custom_preamble[31:0]    <= 32'h55555555; //EG default value
            ctl_vnc_rx_custom_preamble[63:32]   <= 32'hd5555555; //EG default value
            ctl_vnc_tx_inj_err                  <= 'd0;
            ctl_vnc_tx_inj_poison               <= 'd0; //EG
            ctl_vnc_tx_inj_pause                <= 'd0;
            ctl_vnc_tx_inj_pause_sa[31:0]       <= 'd0;
            ctl_vnc_tx_inj_pause_sa[47:32]      <= 'd0;
            ctl_vnc_tx_inj_pause_da[31:0]       <= 'd0;
            ctl_vnc_tx_inj_pause_da[47:32]      <= 'd0;
            ctl_vnc_tx_inj_pause_ethtype        <= 'd0;
            ctl_vnc_tx_inj_pause_opcode         <= 'd0;
            ctl_vnc_tx_inj_pause_timer_ce       <= 'd0;
            ctl_vnc_tx_inj_pause_timer_pfc0     <= 'd0;
            ctl_vnc_tx_inj_pause_timer_pfc1     <= 'd0;
            ctl_vnc_tx_inj_pause_timer_pfc2     <= 'd0;
            ctl_vnc_tx_inj_pause_timer_pfc3     <= 'd0;
            ctl_vnc_tx_inj_pause_timer_pfc4     <= 'd0;
            ctl_vnc_tx_inj_pause_timer_pfc5     <= 'd0;
            ctl_vnc_tx_inj_pause_timer_pfc6     <= 'd0;
            ctl_vnc_tx_inj_pause_timer_pfc7     <= 'd0;
            stat_tick                           <= 'd0;
            ctl_vnc_tx_start_lat_run            <= 'd0;

            ctl_correct_bitslip                 <= 1'b0;
            ctl_disable_bitslip                 <= 1'b0;
            ctl_gb_seq_sync                     <= 1'b1;

        end
        else begin
            // Self-clearing registers are set up in this area
            stat_tick   <= 1'b0;

            if (ack_vnc_tx_inj_err)         ctl_vnc_tx_inj_err       <= 1'b0;
            if (ack_vnc_tx_inj_poison)      ctl_vnc_tx_inj_poison    <= 1'b0; //EG
            if (ack_vnc_tx_inj_pause)       ctl_vnc_tx_inj_pause     <= 1'b0;
            if (ack_frm_gen_done)           ctl_vnc_frm_gen_en       <= 1'b0;
            if (ack_vnc_tx_start_lat_run)   ctl_vnc_tx_start_lat_run <= 1'b0;

            // End of self-clearing registers


            // Assign writeable registers to the appropriate bits of the write bus
            // if selected using address bus.
            if (do_write) begin

                // Resets to the GTF
                unique if (wr_addr == 12'h004) begin

                    vnc_gtf_ch_gttxreset                <= wr_data[0];
                    vnc_gtf_ch_txpmareset               <= wr_data[1];
                    vnc_gtf_ch_txpcsreset               <= wr_data[2];
                    gtwiz_reset_tx_pll_and_datapath_in  <= wr_data[3];
                    gtwiz_reset_tx_datapath_in          <= wr_data[4];

                    vnc_gtf_ch_gtrxreset                <= wr_data[8];
                    vnc_gtf_ch_rxpmareset               <= wr_data[9];
                    vnc_gtf_ch_rxdfelpmreset            <= wr_data[10];
                    vnc_gtf_ch_eyescanreset             <= wr_data[11];
                    vnc_gtf_ch_rxpcsreset               <= wr_data[12];
                    gtwiz_reset_rx_pll_and_datapath_in  <= wr_data[13];
                    gtwiz_reset_rx_datapath_in          <= wr_data[14];

                    vnc_gtf_cm_qpll0reset               <= wr_data[16];

                end

                else if (wr_addr == 12'h008) begin
                    scratch_0                           <= wr_data[31:0];
                end

                else if (wr_addr == 12'h00C) begin
                    vnc_gtf_ch_txuserrdy                <= wr_data[0];
                    vnc_gtf_ch_rxuserrdy                <= wr_data[1];
                end

                else if (wr_addr == 12'h010) begin
                    ctl_tx_data_rate                    <= wr_data[0];
                    ctl_tx_fcs_ins_enable               <= wr_data[4];
                    ctl_tx_custom_preamble_en           <= wr_data[8];
                    ctl_tx_start_framing_enable         <= wr_data[12];
                    ctl_rx_data_rate                    <= wr_data[16];
                    ctl_rx_packet_framing_enable        <= wr_data[20];
                    ctl_rx_custom_preamble_en           <= wr_data[24];
                end

                else if (wr_addr == 12'h014) begin
                    ctl_vnc_frm_gen_mode                <= wr_data[0];
                    ctl_tx_variable_ipg                 <= wr_data[8];
                end

                else if (wr_addr == 12'h020) begin
                    ctl_vnc_frm_gen_en                  <= wr_data[0];
                    ctl_vnc_mon_en                      <= wr_data[4];
                end

                else if (wr_addr == 12'h024) begin
                    ctl_vnc_max_len                     <= wr_data[13:0];
                end

                else if (wr_addr == 12'h028) begin
                    ctl_vnc_min_len                     <= wr_data[13:0];
                end

                else if (wr_addr == 12'h02c) begin
                    ctl_num_frames                      <= wr_data[31:0];
                end

                else if (wr_addr == 12'h030) begin
                    ctl_vnc_tx_custom_preamble[31:0]    <= wr_data[31:0];
                end
                else if (wr_addr == 12'h034) begin
                    ctl_vnc_tx_custom_preamble[63:32]   <= wr_data[31:0];
                end

                else if (wr_addr == 12'h038) begin
                    ctl_vnc_rx_custom_preamble[31:0]    <= wr_data[31:0];
                end
                else if (wr_addr == 12'h03c) begin
                    ctl_vnc_rx_custom_preamble[63:32]   <= wr_data[31:0];
                end

                else if (wr_addr == 12'h040) begin
                    ctl_vnc_tx_inj_err                  <= wr_data[0];
                end

                else if (wr_addr == 12'h044) begin
                    ctl_vnc_tx_inj_pause                <= wr_data[0];
                end

                else if (wr_addr == 12'h050) begin
                    ctl_vnc_tx_inj_pause_sa[31:0]       <= wr_data[31:0];
                end
                else if (wr_addr == 12'h054) begin
                    ctl_vnc_tx_inj_pause_sa[47:32]      <= wr_data[15:0];
                end

                else if (wr_addr == 12'h058) begin
                    ctl_vnc_tx_inj_pause_da[31:0]       <= wr_data[31:0];
                end
                else if (wr_addr == 12'h05c) begin
                    ctl_vnc_tx_inj_pause_da[47:32]      <= wr_data[31:0];
                end

                else if (wr_addr == 12'h060) begin
                    ctl_vnc_tx_inj_pause_ethtype        <= wr_data[15:0];
                end

                else if (wr_addr == 12'h064) begin
                    ctl_vnc_tx_inj_pause_opcode         <= wr_data[15:0];
                end

                else if (wr_addr == 12'h068) begin
                    ctl_vnc_tx_inj_pause_timer_ce       <= wr_data[15:0];
                end

                else if (wr_addr == 12'h06c) begin
                    ctl_vnc_tx_inj_pause_timer_pfc0     <= wr_data[15:0];
                end

                else if (wr_addr == 12'h070) begin
                    ctl_vnc_tx_inj_pause_timer_pfc1     <= wr_data[15:0];
                end

                else if (wr_addr == 12'h074) begin
                    ctl_vnc_tx_inj_pause_timer_pfc2     <= wr_data[15:0];
                end

                else if (wr_addr == 12'h078) begin
                    ctl_vnc_tx_inj_pause_timer_pfc3     <= wr_data[15:0];
                end

                else if (wr_addr == 12'h07c) begin
                    ctl_vnc_tx_inj_pause_timer_pfc4     <= wr_data[15:0];
                end

                else if (wr_addr == 12'h080) begin
                    ctl_vnc_tx_inj_pause_timer_pfc5     <= wr_data[15:0];
                end

                else if (wr_addr == 12'h084) begin
                    ctl_vnc_tx_inj_pause_timer_pfc6     <= wr_data[15:0];
                end

                else if (wr_addr == 12'h088) begin
                    ctl_vnc_tx_inj_pause_timer_pfc7     <= wr_data[15:0];
                end

                else if (wr_addr == 12'h090) begin
                    stat_tick                           <= wr_data[0];
                end

                else if (wr_addr == 12'h094) begin
                    ctl_vnc_tx_start_lat_run            <= wr_data[0];
                end
                
                else if (wr_addr == 12'h098) begin
                    ctl_vnc_tx_inj_poison              <= wr_data[0]; //EG
                end

                else if (wr_addr == 12'h0A4) begin
                    ctl_correct_bitslip                 <= wr_data[0];
                    ctl_disable_bitslip                  <= wr_data[4];
                    ctl_gb_seq_sync                     <= wr_data[8];
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
            rdata[8]    = stat_gtf_rx_internal_local_fault;
            rdata[9]    = stat_gtf_rx_local_fault;
            rdata[10]   = stat_gtf_rx_received_local_fault;
            rdata[11]   = stat_gtf_rx_remote_fault;
        end

        else if (rd_addr == 12'h004) begin
            rdata[0]    = vnc_gtf_ch_gttxreset;
            rdata[1]    = vnc_gtf_ch_txpmareset;
            rdata[2]    = vnc_gtf_ch_txpcsreset;
            rdata[3]    = gtwiz_reset_tx_pll_and_datapath_in;
            rdata[4]    = gtwiz_reset_tx_datapath_in;

            rdata[8]    = vnc_gtf_ch_gtrxreset;
            rdata[9]    = vnc_gtf_ch_rxpmareset;
            rdata[10]   = vnc_gtf_ch_rxdfelpmreset;
            rdata[11]   = vnc_gtf_ch_eyescanreset;
            rdata[12]   = vnc_gtf_ch_rxpcsreset;
            rdata[13]   = gtwiz_reset_rx_pll_and_datapath_in;
            rdata[14]   = gtwiz_reset_rx_datapath_in;

            rdata[16]   = vnc_gtf_cm_qpll0reset;
        end

        else if (rd_addr == 12'h008) begin
            rdata[31:0]  = scratch_0;
        end

        else if (rd_addr == 12'h00c) begin
            rdata[0]     = vnc_gtf_ch_txuserrdy;
            rdata[1]     = vnc_gtf_ch_rxuserrdy;
        end

        else if (rd_addr == 12'h010) begin
            rdata[0]     = ctl_tx_data_rate;
            rdata[4]     = ctl_tx_fcs_ins_enable;
            rdata[8]     = ctl_tx_custom_preamble_en;
            rdata[12]    = ctl_tx_start_framing_enable;
            rdata[16]    = ctl_rx_data_rate;
            rdata[20]    = ctl_rx_packet_framing_enable;
            rdata[24]    = ctl_rx_custom_preamble_en;
        end

        else if (rd_addr == 12'h014) begin
            rdata[0]     = ctl_vnc_frm_gen_mode;
            rdata[8]     = ctl_tx_variable_ipg;
        end

        else if (rd_addr == 12'h020) begin
            rdata[0]     = ctl_vnc_frm_gen_en;
            rdata[4]     = ctl_vnc_mon_en;
        end

        else if (rd_addr == 12'h024) begin
            rdata[13:0]     = ctl_vnc_max_len;
        end

        else if (rd_addr == 12'h028) begin
            rdata[13:0]     = ctl_vnc_min_len;
        end

        else if (rd_addr == 12'h02c) begin
            rdata[31:0]     = ctl_num_frames;
        end

        else if (rd_addr == 12'h030) begin
            rdata[31:0]     = ctl_vnc_tx_custom_preamble[31:0];
        end
        else if (rd_addr == 12'h034) begin
            rdata[31:0]     = ctl_vnc_tx_custom_preamble[63:32];
        end

        else if (rd_addr == 12'h038) begin
            rdata[31:0]     = ctl_vnc_rx_custom_preamble[31:0];
        end
        else if (rd_addr == 12'h03c) begin
            rdata[31:0]     = ctl_vnc_rx_custom_preamble[63:32];
        end

        else if (rd_addr == 12'h040) begin
            rdata[0]     = ctl_vnc_tx_inj_err;
        end

        else if (rd_addr == 12'h044) begin
            rdata[0]     = ctl_vnc_tx_inj_pause;
        end

        else if (rd_addr == 12'h050) begin
            rdata[31:0]     = ctl_vnc_tx_inj_pause_sa[31:0];
        end
        else if (rd_addr == 12'h054) begin
            rdata[15:0]     = ctl_vnc_tx_inj_pause_sa[47:32];
        end

        else if (rd_addr == 12'h058) begin
            rdata[31:0]     = ctl_vnc_tx_inj_pause_da[31:0];
        end
        else if (rd_addr == 12'h05c) begin
            rdata[31:0]     = ctl_vnc_tx_inj_pause_da[47:32];
        end

        else if (rd_addr == 12'h060) begin
            rdata[15:0]     = ctl_vnc_tx_inj_pause_ethtype;
        end

        else if (rd_addr == 12'h064) begin
            rdata[15:0]     = ctl_vnc_tx_inj_pause_opcode;
        end

        else if (rd_addr == 12'h068) begin
            rdata[15:0]     = ctl_vnc_tx_inj_pause_timer_ce;
        end

        else if (rd_addr == 12'h06c) begin
            rdata[15:0]     = ctl_vnc_tx_inj_pause_timer_pfc0;
        end

        else if (rd_addr == 12'h070) begin
            rdata[15:0]     = ctl_vnc_tx_inj_pause_timer_pfc1;
        end

        else if (rd_addr == 12'h074) begin
            rdata[15:0]     = ctl_vnc_tx_inj_pause_timer_pfc2;
        end

        else if (rd_addr == 12'h078) begin
            rdata[15:0]     = ctl_vnc_tx_inj_pause_timer_pfc3;
        end

        else if (rd_addr == 12'h07c) begin
            rdata[15:0]     = ctl_vnc_tx_inj_pause_timer_pfc4;
        end

        else if (rd_addr == 12'h080) begin
            rdata[15:0]     = ctl_vnc_tx_inj_pause_timer_pfc5;
        end

        else if (rd_addr == 12'h084) begin
            rdata[15:0]     = ctl_vnc_tx_inj_pause_timer_pfc6;
        end

        else if (rd_addr == 12'h088) begin
            rdata[15:0]     = ctl_vnc_tx_inj_pause_timer_pfc7;
        end

        else if (rd_addr == 12'h090) begin
            rdata[0]     = stat_tick;
        end

        else if (rd_addr == 12'h094) begin
            rdata[0]     = ctl_vnc_tx_start_lat_run;
        end
        
        else if (rd_addr == 12'h098) begin
            rdata[0]     = ctl_vnc_tx_inj_poison; //EG
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
             rdata[15:0] = `GTFMAC_VNC_VERSION;
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

        // TRANSMIT STATS
        else if (rd_addr == 12'h400) begin
            rdata = stat_vnc_tx_unicast[31:0];
        end
        else if (rd_addr == 12'h404) begin
            rdata = stat_vnc_tx_unicast[63:32];
        end
        else if (rd_addr == 12'h408) begin
            rdata = stat_vnc_tx_multicast[31:0];
        end
        else if (rd_addr == 12'h40c) begin
            rdata = stat_vnc_tx_multicast[63:32];
        end
        else if (rd_addr == 12'h410) begin
            rdata = stat_vnc_tx_broadcast[31:0];
        end
        else if (rd_addr == 12'h414) begin
            rdata = stat_vnc_tx_broadcast[63:32];
        end
        else if (rd_addr == 12'h418) begin
            rdata = stat_vnc_tx_vlan[31:0];
        end
        else if (rd_addr == 12'h41c) begin
            rdata = stat_vnc_tx_vlan[63:32];
        end

        else if (rd_addr == 12'h420) begin
            rdata = stat_vnc_tx_total_packets[31:0];
        end
        else if (rd_addr == 12'h424) begin
            rdata = stat_vnc_tx_total_packets[63:32];
        end
        else if (rd_addr == 12'h428) begin
            rdata = stat_vnc_tx_total_bytes[31:0];
        end
        else if (rd_addr == 12'h42c) begin
            rdata = stat_vnc_tx_total_bytes[63:32];
        end
        else if (rd_addr == 12'h430) begin
            rdata = stat_vnc_tx_total_good_packets[31:0];
        end
        else if (rd_addr == 12'h434) begin
            rdata = stat_vnc_tx_total_good_packets[63:32];
        end
        else if (rd_addr == 12'h438) begin
            rdata = stat_vnc_tx_total_good_bytes[31:0];
        end
        else if (rd_addr == 12'h43c) begin
            rdata = stat_vnc_tx_total_good_bytes[63:32];
        end

        else if (rd_addr == 12'h440) begin
            rdata = stat_vnc_tx_packet_64_bytes[31:0];
        end
        else if (rd_addr == 12'h444) begin
            rdata = stat_vnc_tx_packet_64_bytes[63:32];
        end
        else if (rd_addr == 12'h448) begin
            rdata = stat_vnc_tx_packet_65_127_bytes[31:0];
        end
        else if (rd_addr == 12'h44c) begin
            rdata = stat_vnc_tx_packet_65_127_bytes[63:32];
        end
        else if (rd_addr == 12'h450) begin
            rdata = stat_vnc_tx_packet_128_255_bytes[31:0];
        end
        else if (rd_addr == 12'h454) begin
            rdata = stat_vnc_tx_packet_128_255_bytes[63:32];
        end
        else if (rd_addr == 12'h458) begin
            rdata = stat_vnc_tx_packet_256_511_bytes[31:0];
        end
        else if (rd_addr == 12'h45c) begin
            rdata = stat_vnc_tx_packet_256_511_bytes[63:32];
        end
        else if (rd_addr == 12'h460) begin
            rdata = stat_vnc_tx_packet_512_1023_bytes[31:0];
        end
        else if (rd_addr == 12'h464) begin
            rdata = stat_vnc_tx_packet_512_1023_bytes[63:32];
        end
        else if (rd_addr == 12'h468) begin
            rdata = stat_vnc_tx_packet_1024_1518_bytes[31:0];
        end
        else if (rd_addr == 12'h46c) begin
            rdata = stat_vnc_tx_packet_1024_1518_bytes[63:32];
        end
        else if (rd_addr == 12'h470) begin
            rdata = stat_vnc_tx_packet_1519_1522_bytes[31:0];
        end
        else if (rd_addr == 12'h474) begin
            rdata = stat_vnc_tx_packet_1519_1522_bytes[63:32];
        end
        else if (rd_addr == 12'h478) begin
            rdata = stat_vnc_tx_packet_1523_1548_bytes[31:0];
        end
        else if (rd_addr == 12'h47c) begin
            rdata = stat_vnc_tx_packet_1523_1548_bytes[63:32];
        end
        else if (rd_addr == 12'h480) begin
            rdata = stat_vnc_tx_packet_1549_2047_bytes[31:0];
        end
        else if (rd_addr == 12'h484) begin
            rdata = stat_vnc_tx_packet_1549_2047_bytes[63:32];
        end
        else if (rd_addr == 12'h488) begin
            rdata = stat_vnc_tx_packet_2048_4095_bytes[31:0];
        end
        else if (rd_addr == 12'h48c) begin
            rdata = stat_vnc_tx_packet_2048_4095_bytes[63:32];
        end
        else if (rd_addr == 12'h490) begin
            rdata = stat_vnc_tx_packet_4096_8191_bytes[31:0];
        end
        else if (rd_addr == 12'h494) begin
            rdata = stat_vnc_tx_packet_4096_8191_bytes[63:32];
        end
        else if (rd_addr == 12'h498) begin
            rdata = stat_vnc_tx_packet_8192_9215_bytes[31:0];
        end
        else if (rd_addr == 12'h49c) begin
            rdata = stat_vnc_tx_packet_8192_9215_bytes[63:32];
        end
        else if (rd_addr == 12'h4a0) begin
            rdata = stat_vnc_tx_packet_small[31:0];
        end
        else if (rd_addr == 12'h4a4) begin
            rdata = stat_vnc_tx_packet_small[63:32];
        end
        else if (rd_addr == 12'h4a8) begin
            rdata = stat_vnc_tx_packet_large[31:0];
        end
        else if (rd_addr == 12'h4ac) begin
            rdata = stat_vnc_tx_packet_large[63:32];
        end
        else if (rd_addr == 12'h4b0) begin
            rdata = stat_vnc_tx_frame_error[31:0];
        end
        else if (rd_addr == 12'h4b4) begin
            rdata = stat_vnc_tx_frame_error[63:32];
        end
        else if (rd_addr == 12'h4b8) begin
            rdata[15:0]  = stat_tx_unfout;
            rdata[31:16] = stat_vnc_tx_overflow;
        end

        // RECEIVE STATS
        else if (rd_addr == 12'h600) begin
            rdata = stat_vnc_rx_unicast[31:0];
        end
        else if (rd_addr == 12'h604) begin
            rdata = stat_vnc_rx_unicast[63:32];
        end
        else if (rd_addr == 12'h608) begin
            rdata = stat_vnc_rx_multicast[31:0];
        end
        else if (rd_addr == 12'h60c) begin
            rdata = stat_vnc_rx_multicast[63:32];
        end
        else if (rd_addr == 12'h610) begin
            rdata = stat_vnc_rx_broadcast[31:0];
        end
        else if (rd_addr == 12'h614) begin
            rdata = stat_vnc_rx_broadcast[63:32];
        end
        else if (rd_addr == 12'h618) begin
            rdata = stat_vnc_rx_vlan[31:0];
        end
        else if (rd_addr == 12'h61c) begin
            rdata = stat_vnc_rx_vlan[63:32];
        end

        else if (rd_addr == 12'h620) begin
            rdata = stat_vnc_rx_total_packets[31:0];
        end
        else if (rd_addr == 12'h624) begin
            rdata = stat_vnc_rx_total_packets[63:32];
        end
        else if (rd_addr == 12'h628) begin
            rdata = stat_vnc_rx_total_bytes[31:0];
        end
        else if (rd_addr == 12'h62c) begin
            rdata = stat_vnc_rx_total_bytes[63:32];
        end
        else if (rd_addr == 12'h630) begin
            rdata = stat_vnc_rx_total_good_packets[31:0];
        end
        else if (rd_addr == 12'h634) begin
            rdata = stat_vnc_rx_total_good_packets[63:32];
        end
        else if (rd_addr == 12'h638) begin
            rdata = stat_vnc_rx_total_good_bytes[31:0];
        end
        else if (rd_addr == 12'h63c) begin
            rdata = stat_vnc_rx_total_good_bytes[63:32];
        end

        else if (rd_addr == 12'h640) begin
            rdata = stat_vnc_rx_packet_64_bytes[31:0];
        end
        else if (rd_addr == 12'h644) begin
            rdata = stat_vnc_rx_packet_64_bytes[63:32];
        end
        else if (rd_addr == 12'h648) begin
            rdata = stat_vnc_rx_packet_65_127_bytes[31:0];
        end
        else if (rd_addr == 12'h64c) begin
            rdata = stat_vnc_rx_packet_65_127_bytes[63:32];
        end
        else if (rd_addr == 12'h650) begin
            rdata = stat_vnc_rx_packet_128_255_bytes[31:0];
        end
        else if (rd_addr == 12'h654) begin
            rdata = stat_vnc_rx_packet_128_255_bytes[63:32];
        end
        else if (rd_addr == 12'h658) begin
            rdata = stat_vnc_rx_packet_256_511_bytes[31:0];
        end
        else if (rd_addr == 12'h65c) begin
            rdata = stat_vnc_rx_packet_256_511_bytes[63:32];
        end
        else if (rd_addr == 12'h660) begin
            rdata = stat_vnc_rx_packet_512_1023_bytes[31:0];
        end
        else if (rd_addr == 12'h664) begin
            rdata = stat_vnc_rx_packet_512_1023_bytes[63:32];
        end
        else if (rd_addr == 12'h668) begin
            rdata = stat_vnc_rx_packet_1024_1518_bytes[31:0];
        end
        else if (rd_addr == 12'h66c) begin
            rdata = stat_vnc_rx_packet_1024_1518_bytes[63:32];
        end
        else if (rd_addr == 12'h670) begin
            rdata = stat_vnc_rx_packet_1519_1522_bytes[31:0];
        end
        else if (rd_addr == 12'h674) begin
            rdata = stat_vnc_rx_packet_1519_1522_bytes[63:32];
        end
        else if (rd_addr == 12'h678) begin
            rdata = stat_vnc_rx_packet_1523_1548_bytes[31:0];
        end
        else if (rd_addr == 12'h67c) begin
            rdata = stat_vnc_rx_packet_1523_1548_bytes[63:32];
        end
        else if (rd_addr == 12'h680) begin
            rdata = stat_vnc_rx_packet_1549_2047_bytes[31:0];
        end
        else if (rd_addr == 12'h684) begin
            rdata = stat_vnc_rx_packet_1549_2047_bytes[63:32];
        end
        else if (rd_addr == 12'h688) begin
            rdata = stat_vnc_rx_packet_2048_4095_bytes[31:0];
        end
        else if (rd_addr == 12'h68c) begin
            rdata = stat_vnc_rx_packet_2048_4095_bytes[63:32];
        end
        else if (rd_addr == 12'h690) begin
            rdata = stat_vnc_rx_packet_4096_8191_bytes[31:0];
        end
        else if (rd_addr == 12'h694) begin
            rdata = stat_vnc_rx_packet_4096_8191_bytes[63:32];
        end
        else if (rd_addr == 12'h698) begin
            rdata = stat_vnc_rx_packet_8192_9215_bytes[31:0];
        end
        else if (rd_addr == 12'h69c) begin
            rdata = stat_vnc_rx_packet_8192_9215_bytes[63:32];
        end

        else if (rd_addr == 12'h6a0) begin
            rdata = stat_vnc_rx_inrangeerr[31:0];
        end
        else if (rd_addr == 12'h6a4) begin
            rdata = stat_vnc_rx_inrangeerr[63:32];
        end
        else if (rd_addr == 12'h6a8) begin
            rdata = stat_vnc_rx_bad_fcs[31:0];
        end
        else if (rd_addr == 12'h6ac) begin
            rdata = stat_vnc_rx_bad_fcs[63:32];
        end
        else if (rd_addr == 12'h6b0) begin
            rdata = stat_vnc_rx_oversize[31:0];
        end
        else if (rd_addr == 12'h6b4) begin
            rdata = stat_vnc_rx_oversize[63:32];
        end
        else if (rd_addr == 12'h6b8) begin
            rdata = stat_vnc_rx_undersize[31:0];
        end
        else if (rd_addr == 12'h6bc) begin
            rdata = stat_vnc_rx_undersize[63:32];
        end
        else if (rd_addr == 12'h6c0) begin
            rdata = stat_vnc_rx_toolong[31:0];
        end
        else if (rd_addr == 12'h6c4) begin
            rdata = stat_vnc_rx_toolong[63:32];
        end
        else if (rd_addr == 12'h6c8) begin
            rdata = stat_vnc_rx_packet_small[31:0];
        end
        else if (rd_addr == 12'h6cc) begin
            rdata = stat_vnc_rx_packet_small[63:32];
        end
        else if (rd_addr == 12'h6d0) begin
            rdata = stat_vnc_rx_packet_large[31:0];
        end
        else if (rd_addr == 12'h6d4) begin
            rdata = stat_vnc_rx_packet_large[63:32];
        end
        else if (rd_addr == 12'h6d8) begin
            rdata = stat_vnc_rx_jabber[31:0];
        end
        else if (rd_addr == 12'h6dc) begin
            rdata = stat_vnc_rx_jabber[63:32];
        end
        else if (rd_addr == 12'h6e0) begin
            rdata = stat_vnc_rx_fragment[31:0];
        end
        else if (rd_addr == 12'h6e4) begin
            rdata = stat_vnc_rx_fragment[63:32];
        end
        else if (rd_addr == 12'h6e8) begin
            rdata = stat_vnc_rx_packet_bad_fcs[31:0];
        end
        else if (rd_addr == 12'h6ec) begin
            rdata = stat_vnc_rx_packet_bad_fcs[63:32];
        end
        else if (rd_addr == 12'h6f0) begin
            rdata = stat_vnc_rx_user_pause[31:0];
        end
        else if (rd_addr == 12'h6f4) begin
            rdata = stat_vnc_rx_user_pause[63:32];
        end
        else if (rd_addr == 12'h6f8) begin
            rdata = stat_vnc_rx_pause[31:0];
        end
        else if (rd_addr == 12'h6fc) begin
            rdata = stat_vnc_rx_pause[63:32];
        end
        else if (rd_addr == 12'h700) begin //EG
            rdata = stat_vnc_rx_bad_preamble[31:0];
        end
        else if (rd_addr == 12'h704) begin
            rdata = stat_vnc_rx_bad_preamble[63:32];
        end
        else if (rd_addr == 12'h708) begin
            rdata = stat_vnc_rx_good_tsof_codeword[31:0];
        end    
        else if (rd_addr == 12'h70c) begin
            rdata = stat_vnc_rx_good_tsof_codeword[63:32];
        end  
        else begin
            rdata = 32'h0;
        end


    end

endmodule


module gtfmac_vnc_ra_buf # (
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
    input  wire             din_poison, //EG

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
    output logic            dout_poison //EG

);


    localparam  RAM_WIDTH   = 76;   // data + pre + sop + tlast + err + poison (was 75 before poison) //EG
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

    gtfmac_vnc_syncer_bus #(
       .WIDTH (PTR_WIDTH)
    ) i_wr_ptr_syncer (
       .clkin        (in_clk),
       .clkin_reset  (~in_rst),
       .clkout       (out_clk),
       .clkout_reset (~out_rst),

       .busin        (in_wr_ptr),
       .busout       (out_wr_ptr)
    );

    gtfmac_vnc_syncer_bus #(
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

    gtfmac_vnc_simple_bram # (
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
    input   wire            din_codeword_matched,
    input   wire            din_preamble_bad, //EG
    input   wire            din_vlan,
    input   wire            din_broadcast,
    input   wire            din_multicast,
    input   wire            din_unicast,

    input   wire            add_4,

    input   wire            stat_clk,
    input   wire            stat_rst,
    input   wire            stat_tick,

    output  wire    [63:0]  stat_total_bytes,
    output  wire    [63:0]  stat_total_good_bytes,
    output  wire    [63:0]  stat_total_packets,
    output  wire    [63:0]  stat_total_good_packets,
    output  wire    [63:0]  stat_broadcast,
    output  wire    [63:0]  stat_multicast,
    output  wire    [63:0]  stat_unicast,
    output  wire    [63:0]  stat_vlan,
    output  wire    [63:0]  stat_bad_preamble, //EG
    output  wire    [63:0]  stat_good_codeword,  // this port needs to be instantiated at upper level

    output  wire    [63:0]  stat_packet_64_bytes,
    output  wire    [63:0]  stat_packet_65_127_bytes,
    output  wire    [63:0]  stat_packet_128_255_bytes,
    output  wire    [63:0]  stat_packet_256_511_bytes,
    output  wire    [63:0]  stat_packet_512_1023_bytes,
    output  wire    [63:0]  stat_packet_1024_1518_bytes,
    output  wire    [63:0]  stat_packet_1519_1522_bytes,
    output  wire    [63:0]  stat_packet_1523_1548_bytes,
    output  wire    [63:0]  stat_packet_1549_2047_bytes,
    output  wire    [63:0]  stat_packet_2048_4095_bytes,
    output  wire    [63:0]  stat_packet_4096_8191_bytes,
    output  wire    [63:0]  stat_packet_8192_9215_bytes,

    output  wire    [63:0]  stat_packet_small,
    output  wire    [63:0]  stat_packet_large,
    output  wire    [63:0]  stat_bad_fcs,
    output  wire    [63:0]  stat_frame_error

);


    logic           frame_active;
    logic   [13:0]  byte_count;
    logic           is_preamble_bad; //EG
    logic           is_codeword_matched;
    logic           is_vlan;
    logic           is_broadcast;
    logic           is_multicast;
    logic           is_unicast;
    logic           is_err;
    logic           is_bad_fcs;
    logic           stat_incr;

    logic   [13:0]  stat_total_bytes_incr;
    logic   [13:0]  stat_total_good_bytes_incr;
    logic           stat_total_packets_incr;
    logic           stat_total_good_packets_incr;
    logic           stat_broadcast_incr;
    logic           stat_multicast_incr;
    logic           stat_unicast_incr;
    logic           stat_preamble_bad_incr; //EG
    logic           stat_codeword_matched_incr;
    logic           stat_vlan_incr;
    logic           stat_packet_64_bytes_incr;
    logic           stat_packet_65_127_bytes_incr;
    logic           stat_packet_128_255_bytes_incr;
    logic           stat_packet_256_511_bytes_incr;
    logic           stat_packet_512_1023_bytes_incr;
    logic           stat_packet_1024_1518_bytes_incr;
    logic           stat_packet_1519_1522_bytes_incr;
    logic           stat_packet_1523_1548_bytes_incr;
    logic           stat_packet_1549_2047_bytes_incr;
    logic           stat_packet_2048_4095_bytes_incr;
    logic           stat_packet_4096_8191_bytes_incr;
    logic           stat_packet_8192_9215_bytes_incr;
    logic           stat_packet_small_incr;
    logic           stat_packet_large_incr;
    logic           stat_bad_fcs_incr;
    logic           stat_frame_error_incr;


    always @(posedge clk) begin

        stat_incr       <= 1'b0;

        if (frame_active) begin

            if (din_ena) begin

                is_err          <= din_err;
                is_bad_fcs      <= din_bad_fcs;

                if (din_eop) begin
                    byte_count      <= byte_count + (14'd8 - din_mty) + {11'd0, add_4, 2'd0};
                    frame_active    <= 1'b0;
                    stat_incr       <= 1'b1;
                end
                else begin
                    byte_count  <= byte_count + 14'd8;
                end

            end

        end
        else begin
            is_preamble_bad     <= 1'b0; //EG
            is_codeword_matched <= 1'b0; 
            is_vlan             <= 1'b0;
            is_broadcast        <= 1'b0;
            is_multicast        <= 1'b0;
            is_unicast          <= 1'b0;
            is_err              <= 1'b0;
            is_bad_fcs          <= 1'b0;

            if (din_empty) begin
                byte_count      <= 14'd0;
                stat_incr       <= 1'b1;
            end
            else if (din_ena && din_sop) begin
                byte_count          <= 14'd8;
                is_preamble_bad     <= din_preamble_bad; //EG
                is_codeword_matched <= din_codeword_matched;
                is_vlan             <= din_vlan;
                is_broadcast        <= din_broadcast;
                is_multicast        <= din_multicast;
                is_unicast          <= din_unicast;
                is_err              <= din_err;
                is_bad_fcs          <= din_bad_fcs;
                frame_active        <= 1'b1;
            end

        end

        if (rst) begin
            frame_active        <= 1'b0;
            is_preamble_bad     <= 1'b0; //EG
            is_codeword_matched <= 1'b0;
            is_vlan             <= 1'b0;
            is_broadcast        <= 1'b0;
            is_multicast        <= 1'b0;
            is_unicast          <= 1'b0;
            is_err              <= 1'b0;
            is_bad_fcs          <= 1'b0;
            stat_incr           <= 1'b0;
        end

    end


    // We won't reset these incr signals, because the stat_collector
    // requires a 'tick' before the stats start being collected.
    always @(posedge clk) begin

        stat_total_bytes_incr            <= 14'd0;
        stat_total_good_bytes_incr       <= 14'd0;
        stat_total_packets_incr          <= 1'b0;
        stat_total_good_packets_incr     <= 1'b0;
        stat_broadcast_incr              <= 1'b0;
        stat_multicast_incr              <= 1'b0;
        stat_unicast_incr                <= 1'b0;
        stat_preamble_bad_incr           <= 1'b0; //EG
        stat_codeword_matched_incr       <= 1'b0;
        stat_vlan_incr                   <= 1'b0;
        stat_packet_64_bytes_incr        <= 1'b0;
        stat_packet_65_127_bytes_incr    <= 1'b0;
        stat_packet_128_255_bytes_incr   <= 1'b0;
        stat_packet_256_511_bytes_incr   <= 1'b0;
        stat_packet_512_1023_bytes_incr  <= 1'b0;
        stat_packet_1024_1518_bytes_incr <= 1'b0;
        stat_packet_1519_1522_bytes_incr <= 1'b0;
        stat_packet_1523_1548_bytes_incr <= 1'b0;
        stat_packet_1549_2047_bytes_incr <= 1'b0;
        stat_packet_2048_4095_bytes_incr <= 1'b0;
        stat_packet_4096_8191_bytes_incr <= 1'b0;
        stat_packet_8192_9215_bytes_incr <= 1'b0;
        stat_packet_small_incr           <= 1'b0;
        stat_packet_large_incr           <= 1'b0;
        stat_bad_fcs_incr                <= 1'b0;
        stat_frame_error_incr            <= 1'b0;

        if (stat_incr) begin

            stat_total_bytes_incr            <= byte_count;
            stat_total_good_bytes_incr       <= (is_err) ? 14'd0 : byte_count;
            stat_total_packets_incr          <= 1'b1;
            stat_total_good_packets_incr     <= (is_err) ? 1'b0 : 1'b1;
            stat_broadcast_incr              <= is_broadcast;
            stat_multicast_incr              <= is_multicast;
            stat_unicast_incr                <= is_unicast;
            stat_vlan_incr                   <= is_vlan;
            stat_preamble_bad_incr           <= is_preamble_bad; //EG
            stat_codeword_matched_incr       <= is_codeword_matched;

            stat_bad_fcs_incr                <= is_bad_fcs;
            stat_frame_error_incr            <= is_err;
            
            if (byte_count <  64)                           stat_packet_small_incr           <= 1'b1; //EG                         
            if (byte_count == 64)                           stat_packet_64_bytes_incr        <= 1'b1;
            if (byte_count >= 65   && byte_count <= 127)    stat_packet_65_127_bytes_incr    <= 1'b1;
            if (byte_count >= 128  && byte_count <= 255)    stat_packet_128_255_bytes_incr   <= 1'b1;
            if (byte_count >= 256  && byte_count <= 511)    stat_packet_256_511_bytes_incr   <= 1'b1;
            if (byte_count >= 512  && byte_count <= 1023)   stat_packet_512_1023_bytes_incr  <= 1'b1;
            if (byte_count >= 1024 && byte_count <= 1518)   stat_packet_1024_1518_bytes_incr <= 1'b1;
            if (byte_count >= 1519 && byte_count <= 1522)   stat_packet_1519_1522_bytes_incr <= 1'b1;
            if (byte_count >= 1523 && byte_count <= 1548)   stat_packet_1523_1548_bytes_incr <= 1'b1;
            if (byte_count >= 1549 && byte_count <= 2047)   stat_packet_1549_2047_bytes_incr <= 1'b1;
            if (byte_count >= 2048 && byte_count <= 4095)   stat_packet_2048_4095_bytes_incr <= 1'b1;
            if (byte_count >= 4096 && byte_count <= 8191)   stat_packet_4096_8191_bytes_incr <= 1'b1;
            if (byte_count >= 8192 && byte_count <= 9215)   stat_packet_8192_9215_bytes_incr <= 1'b1;
            if (byte_count >  9215)                         stat_packet_large_incr           <= 1'b1; //EG
                            
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
        .INCR_WIDTH     (14),
        .CNTR_WIDTH     (64)
    )
    i_stat_total_bytes   (

        .clk        (clk),
        .incr       (stat_total_bytes_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_total_bytes)
    );


    gtfmac_vnc_stat_collector # (
        .INCR_WIDTH     (14),
        .CNTR_WIDTH     (64)
    )
    i_stat_total_good_bytes (

        .clk        (clk),
        .incr       (stat_total_good_bytes_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_total_good_bytes)
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


    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_total_good_packets (

        .clk        (clk),
        .incr       (stat_total_good_packets_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_total_good_packets)
    );


    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_broadcast (

        .clk        (clk),
        .incr       (stat_broadcast_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_broadcast)
    );


    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_multicast (

        .clk        (clk),
        .incr       (stat_multicast_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_multicast)
    );


    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_unicast (

        .clk        (clk),
        .incr       (stat_unicast_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_unicast)
    );


    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_vlan (

        .clk        (clk),
        .incr       (stat_vlan_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_vlan)
    );
    
    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_bad_preamble (

        .clk        (clk),
        .incr       (stat_preamble_bad_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_bad_preamble)
    );
    
    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_good_codeword (

        .clk        (clk),
        .incr       (stat_codeword_matched_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_good_codeword)
    );


    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_packet_64_bytes (

        .clk        (clk),
        .incr       (stat_packet_64_bytes_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_packet_64_bytes)
    );


    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_packet_65_127_bytes (

        .clk        (clk),
        .incr       (stat_packet_65_127_bytes_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_packet_65_127_bytes)
    );


    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_packet_128_255_bytes (

        .clk        (clk),
        .incr       (stat_packet_128_255_bytes_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_packet_128_255_bytes)
    );


    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_packet_256_511_bytes (

        .clk        (clk),
        .incr       (stat_packet_256_511_bytes_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_packet_256_511_bytes)
    );


    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_packet_512_1023_bytes (

        .clk        (clk),
        .incr       (stat_packet_512_1023_bytes_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_packet_512_1023_bytes)
    );


    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_packet_1024_1518_bytes (

        .clk        (clk),
        .incr       (stat_packet_1024_1518_bytes_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_packet_1024_1518_bytes)
    );


    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_packet_1519_1522_bytes (

        .clk        (clk),
        .incr       (stat_packet_1519_1522_bytes_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_packet_1519_1522_bytes)
    );


    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_packet_1523_1548_bytes (

        .clk        (clk),
        .incr       (stat_packet_1523_1548_bytes_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_packet_1523_1548_bytes)
    );


    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_packet_1549_2047_bytes (

        .clk        (clk),
        .incr       (stat_packet_1549_2047_bytes_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_packet_1549_2047_bytes)
    );


    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_packet_2048_4095_bytes (

        .clk        (clk),
        .incr       (stat_packet_2048_4095_bytes_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_packet_2048_4095_bytes)
    );


    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_packet_4096_8191_bytes (

        .clk        (clk),
        .incr       (stat_packet_4096_8191_bytes_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_packet_4096_8191_bytes)
    );


    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_packet_8192_9215_bytes (

        .clk        (clk),
        .incr       (stat_packet_8192_9215_bytes_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_packet_8192_9215_bytes)
    );


    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_packet_small (

        .clk        (clk),
        .incr       (stat_packet_small_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_packet_small)
    );


    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_packet_large (

        .clk        (clk),
        .incr       (stat_packet_large_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_packet_large)
    );


    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_bad_fcs (

        .clk        (clk),
        .incr       (stat_bad_fcs_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_bad_fcs)
    );


    gtfmac_vnc_stat_collector # (
        .CNTR_WIDTH     (64)
    )
    i_stat_frame_error (

        .clk        (clk),
        .incr       (stat_frame_error_incr),
        .snapshot   (lcl_tick),
        .stat       (stat_frame_error)
    );



endmodule

/////////////////////////////////////////////////////////////////////////////
// Bitslip adjustment module for GTFMAC
/////////////////////////////////////////////////////////////////////////////
//
// THEORY OF OPERATION
//
//  - during reset, this logic holds bs_disable_bitslip=1 to give time for
//      the GTFMAC to complete its reset
//
//  - once reset is cleared, bs_disable_bitslip is set to '0' which allows the
//      GTFMAC to start tracking the bitslip.
//
//  - rx_bitslip will pulse to '1' for each adjustment by GTFMAC.  This logic counts
//      the number of these slips.
//
//  - once block_lock is achieved (rx_block_lock=1), this logic asserts bs_disable_bitslip=1
//      again, and waits for the user to initiate the correction process.  The process is started
//      once the user asserts ctl_correct_bitslip=1.
//
//  - for every two pulses of rx_bitslip observed after reset, this logic asserts bs_slip_pma and
//      waits for rx_slip_pma_rdy to toggle from 1 -> 0. This process repeats until either zero or one
//      rx_bitslip pulses remain unaccounted for.
//
//  - if an odd number of rx_bitslip pulses were observed, this logic finishes by asserting bs_slip_one_ui=1
//      which is the final adjustment.
//
//  - this logic asserts bs_gb_seq_sync for 8 clocks to reset the MAC portion of the GTFMAC.  Block-lock
//      should then be re-aquired.
//
//  bitslip/gtfmac signal mappings:
//
//      rx_block_lock       = gtf_ch_statrxblocklock
//      rx_bitslip          = gtf_ch_rxbitslip
//      bs_gb_seq_sync      = gtf_ch_pcsrsvdin[0]
//      bs_disable_bitslip  = gtf_ch_pcsrsvdin[1]
//      bs_slip_pma         = gtf_ch_rxslippma
//      bs_slip_one_ui      = gtf_ch_gtrsvd[8]
//      rx_slip_pma_rdy     = gtf_ch_rxslippmardy
//


module gtfmac_vnc_bitslip (

    input   logic           rx_clk,
    input   logic           rx_rst,

    input   logic           ctl_gb_seq_sync,
    input   logic           ctl_disable_bitslip,
    input   logic           ctl_correct_bitslip,
    input   logic           ctl_rx_data_rate,

    output  logic  [6:0]    stat_bitslip_cnt,
    output  logic  [6:0]    stat_bitslip_issued,

    output  logic           stat_excessive_bitslip,
    output  logic           stat_locked,
    output  logic           stat_busy,
    output  logic           stat_done,

    input   logic           rx_block_lock,
    input   logic           rx_bitslip,
    output  logic           bs_gb_seq_sync,
    output  logic           bs_disable_bitslip,

    output  logic           bs_slip_pma,
    output  logic           bs_slip_one_ui,
    input   logic           rx_slip_pma_rdy

);

    logic   [2:0]   state;
    logic   [6:0]   bitslip_delta;

    logic           bs_bitslip_R, bs_bitslip_R2;
    logic           bs_bitslip_re;

    logic           sm_gb_seq_sync;
    assign          bs_gb_seq_sync = ctl_gb_seq_sync | sm_gb_seq_sync;

    logic           sm_disable_bitslip, usr_disable_bitslip;
    assign          bs_disable_bitslip = sm_disable_bitslip | usr_disable_bitslip;

    logic           bs_slip_pma_rdy;
    logic           usr_enable_bitslip;
    logic           bs_correct_bitslip;
    logic           bs_bitslip;
    logic           bs_block_lock;

    assign          bs_bitslip_re = bs_bitslip_R & ~bs_bitslip_R2;

    localparam
                SYNC_STATE              = 3'd0,
                CORRECT_BITSLIP_STATE   = 3'd1,
                ACK_SLIP_STATE          = 3'd2,
                BLOCK_LOCK_STATE        = 3'd3,
                RESYNC_STATE            = 3'd4,
                DONE_STATE              = 3'd5;


    gtfmac_vnc_syncer_level i_disable_bitslip (

      .clk        (rx_clk),
      .reset      (~rx_rst),

      .datain     (ctl_disable_bitslip),
      .dataout    (usr_disable_bitslip)

    );

    gtfmac_vnc_syncer_level i_correct_bitslip (

      .clk        (rx_clk),
      .reset      (~rx_rst),

      .datain     (ctl_correct_bitslip),
      .dataout    (bs_correct_bitslip)

    );

    assign bs_slip_pma_rdy      = rx_slip_pma_rdy;
    assign bs_bitslip           = rx_bitslip;
    assign bs_block_lock        = rx_block_lock;

    logic   [3:0]   seq_sync_cnt;
    logic   [7:0]   q_bs_block_lock;

    always @(posedge rx_clk) begin

        begin

            bs_bitslip_R     <= bs_bitslip;
            bs_bitslip_R2    <= bs_bitslip_R;
            seq_sync_cnt     <= (|seq_sync_cnt) ? seq_sync_cnt - 1'b1 : 4'd0;

            q_bs_block_lock  <= {q_bs_block_lock[6:0], bs_block_lock};
            stat_locked      <= q_bs_block_lock[7];

            case (state)

                SYNC_STATE: begin

                    sm_disable_bitslip      <= 1'b0;

                    if (bs_bitslip_re) begin
                        if (&stat_bitslip_cnt == 1'b1) begin
                            stat_excessive_bitslip  <= 1'b1;
                            state                   <= DONE_STATE;
                        end
                        else begin
                            stat_bitslip_cnt    <= stat_bitslip_cnt + 1'b1;
                        end
                    end

                    if (stat_locked) begin
                        // Only disable bitslip if we are in 10G mode
                        sm_disable_bitslip  <= (ctl_rx_data_rate) ? 1'b0 : 1'b1;
                        state               <= (ctl_rx_data_rate) ? DONE_STATE: BLOCK_LOCK_STATE;
                    end


                end

                BLOCK_LOCK_STATE: begin

                    if (bs_correct_bitslip) begin
                        bitslip_delta   <= stat_bitslip_cnt - stat_bitslip_issued;
                        state           <= CORRECT_BITSLIP_STATE;
                    end

                end


                CORRECT_BITSLIP_STATE: begin

                    stat_busy    <= 1'b1;

                    if (bitslip_delta >= 7'd2) begin
                        bs_slip_pma             <= 1'b1;
                        stat_bitslip_issued     <= stat_bitslip_issued + 7'd2;
                        state                   <= ACK_SLIP_STATE;
                    end
                    else if (bitslip_delta > 7'd0) begin
                        bs_slip_one_ui          <= 1'b1;
                        stat_bitslip_issued     <= stat_bitslip_issued + 7'd1;
                        bitslip_delta           <= 7'd0;
                    end
                    else begin
                        seq_sync_cnt            <= 4'd15;
                        state                   <= RESYNC_STATE;
                    end

                end

                ACK_SLIP_STATE: begin

                    if (!bs_slip_pma_rdy) begin
                        bs_slip_pma     <= 1'b0;
                    end

                    if (bs_slip_pma == 1'b0 && bs_slip_pma_rdy == 1'b1) begin
                        bitslip_delta   <= stat_bitslip_cnt - stat_bitslip_issued;
                        state           <= CORRECT_BITSLIP_STATE;
                    end

                end

                RESYNC_STATE: begin
                    if (seq_sync_cnt == 4'd8) begin
                        sm_gb_seq_sync  <= 1'b1;
                    end
                    else if (seq_sync_cnt == 4'd1) begin
                        sm_gb_seq_sync  <= 1'b0;
                    end
                    else if (seq_sync_cnt == 4'd0) begin
                        state   <= DONE_STATE;
                    end
                end

                default: begin  // DONE_STATE
                    stat_busy       <= 1'b0;
                    stat_done       <= 1'b1;
                end

            endcase

        end


        if (rx_rst) begin
            state                   <= 'd0;
            bs_bitslip_R            <= 1'b0;
            bs_bitslip_R2           <= 1'b0;
            stat_locked             <= 1'b0;
            stat_bitslip_cnt        <= 'd0;
            stat_bitslip_issued     <= 'd0;
            stat_excessive_bitslip  <= 'd0;
            stat_busy               <= 1'b0;
            stat_done               <= 1'b0;
            sm_disable_bitslip      <= 1'b0;
            sm_gb_seq_sync          <= 1'b0;
            bs_slip_pma             <= 'd0;
            bs_slip_one_ui          <= 'd0;
            seq_sync_cnt            <= 3'd0;
            q_bs_block_lock         <= 8'd0;
        end

    end


endmodule

module gtfmac_vnc_stat_dbg (

    input   wire            axi_aclk,
    input   wire            axi_aresetn,

    output  wire            stat_tick,

    input   wire [63:0]     stat_vnc_tx_total_bytes,
    input   wire [63:0]     stat_vnc_rx_total_bytes,

    input   wire [63:0]     stat_vnc_tx_total_good_bytes,
    input   wire [63:0]     stat_vnc_rx_total_good_bytes,

    input   wire [63:0]     stat_vnc_tx_total_packets,
    input   wire [63:0]     stat_vnc_rx_total_packets,

    input   wire [63:0]     stat_vnc_tx_total_good_packets,
    input   wire [63:0]     stat_vnc_rx_total_good_packets,

    input   wire [63:0]     stat_vnc_tx_broadcast,
    input   wire [63:0]     stat_vnc_rx_broadcast,

    input   wire [63:0]     stat_vnc_tx_multicast,
    input   wire [63:0]     stat_vnc_rx_multicast,

    input   wire [63:0]     stat_vnc_tx_unicast,
    input   wire [63:0]     stat_vnc_rx_unicast,

    input   wire [63:0]     stat_vnc_tx_vlan,
    input   wire [63:0]     stat_vnc_rx_vlan,

    input   wire [63:0]     stat_vnc_tx_packet_64_bytes,
    input   wire [63:0]     stat_vnc_rx_packet_64_bytes,

    input   wire [63:0]     stat_vnc_tx_packet_65_127_bytes,
    input   wire [63:0]     stat_vnc_rx_packet_65_127_bytes,

    input   wire [63:0]     stat_vnc_tx_packet_128_255_bytes,
    input   wire [63:0]     stat_vnc_rx_packet_128_255_bytes,

    input   wire [63:0]     stat_vnc_tx_packet_256_511_bytes,
    input   wire [63:0]     stat_vnc_rx_packet_256_511_bytes,

    input   wire [63:0]     stat_vnc_tx_packet_512_1023_bytes,
    input   wire [63:0]     stat_vnc_rx_packet_512_1023_bytes,

    input   wire [63:0]     stat_vnc_tx_packet_1024_1518_bytes,
    input   wire [63:0]     stat_vnc_rx_packet_1024_1518_bytes,

    input   wire [63:0]     stat_vnc_tx_packet_1519_1522_bytes,
    input   wire [63:0]     stat_vnc_rx_packet_1519_1522_bytes,

    input   wire [63:0]     stat_vnc_tx_packet_1523_1548_bytes,
    input   wire [63:0]     stat_vnc_rx_packet_1523_1548_bytes,

    input   wire [63:0]     stat_vnc_tx_packet_1549_2047_bytes,
    input   wire [63:0]     stat_vnc_rx_packet_1549_2047_bytes,

    input   wire [63:0]     stat_vnc_tx_packet_2048_4095_bytes,
    input   wire [63:0]     stat_vnc_rx_packet_2048_4095_bytes,

    input   wire [63:0]     stat_vnc_tx_packet_4096_8191_bytes,
    input   wire [63:0]     stat_vnc_rx_packet_4096_8191_bytes,

    input   wire [63:0]     stat_vnc_tx_packet_8192_9215_bytes,
    input   wire [63:0]     stat_vnc_rx_packet_8192_9215_bytes,

    input   wire            stat_tx_unfout,
    input   wire            stat_vnc_tx_overflow

);

    logic   stat_vnc_total_bytes_match;
    logic   stat_vnc_total_good_bytes_match;
    logic   stat_vnc_total_packets_match;
    logic   stat_vnc_total_good_packets_match;
    logic   stat_vnc_broadcast_match;
    logic   stat_vnc_multicast_match;
    logic   stat_vnc_unicast_match;
    logic   stat_vnc_vlan_match;
    logic   stat_vnc_packet_64_bytes_match;
    logic   stat_vnc_packet_65_127_bytes_match;
    logic   stat_vnc_packet_128_255_bytes_match;
    logic   stat_vnc_packet_256_511_bytes_match;
    logic   stat_vnc_packet_512_1023_bytes_match;
    logic   stat_vnc_packet_1024_1518_bytes_match;
    logic   stat_vnc_packet_1519_1522_bytes_match;
    logic   stat_vnc_packet_1523_1548_bytes_match;
    logic   stat_vnc_packet_1549_2047_bytes_match;
    logic   stat_vnc_packet_2048_4095_bytes_match;
    logic   stat_vnc_packet_4096_8191_bytes_match;
    logic   stat_vnc_packet_8192_9215_bytes_match;


    gtfmac_vnc_syncer_level i_sync_vio_stat_tick (

      .reset      (axi_aresetn),
      .clk        (axi_aclk),

      .datain     (stat_tick_vio),
      .dataout    (stat_tick)

    );


    always @ (*) begin

        stat_vnc_total_bytes_match              = (stat_vnc_tx_total_bytes == stat_vnc_rx_total_bytes) ? 1'b1 : 1'b0;
        stat_vnc_total_good_bytes_match         = (stat_vnc_tx_total_good_bytes == stat_vnc_rx_total_good_bytes) ? 1'b1 : 1'b0;
        stat_vnc_total_packets_match            = (stat_vnc_tx_total_packets == stat_vnc_rx_total_packets) ? 1'b1 : 1'b0;
        stat_vnc_total_good_packets_match       = (stat_vnc_tx_total_good_packets == stat_vnc_rx_total_good_packets) ? 1'b1 : 1'b0;
        stat_vnc_broadcast_match                = (stat_vnc_tx_broadcast == stat_vnc_rx_broadcast) ? 1'b1 : 1'b0;
        stat_vnc_multicast_match                = (stat_vnc_tx_multicast == stat_vnc_rx_multicast) ? 1'b1 : 1'b0;
        stat_vnc_unicast_match                  = (stat_vnc_tx_unicast == stat_vnc_rx_unicast) ? 1'b1 : 1'b0;
        stat_vnc_vlan_match                     = (stat_vnc_tx_vlan == stat_vnc_rx_vlan) ? 1'b1 : 1'b0;
        stat_vnc_packet_64_bytes_match          = (stat_vnc_tx_packet_64_bytes == stat_vnc_rx_packet_64_bytes) ? 1'b1 : 1'b0;
        stat_vnc_packet_65_127_bytes_match      = (stat_vnc_tx_packet_65_127_bytes == stat_vnc_rx_packet_65_127_bytes) ? 1'b1 : 1'b0;
        stat_vnc_packet_128_255_bytes_match     = (stat_vnc_tx_packet_128_255_bytes == stat_vnc_rx_packet_128_255_bytes) ? 1'b1 : 1'b0;
        stat_vnc_packet_256_511_bytes_match     = (stat_vnc_tx_packet_256_511_bytes == stat_vnc_rx_packet_256_511_bytes) ? 1'b1 : 1'b0;
        stat_vnc_packet_512_1023_bytes_match    = (stat_vnc_tx_packet_512_1023_bytes == stat_vnc_rx_packet_512_1023_bytes) ? 1'b1 : 1'b0;
        stat_vnc_packet_1024_1518_bytes_match   = (stat_vnc_tx_packet_1024_1518_bytes == stat_vnc_rx_packet_1024_1518_bytes) ? 1'b1 : 1'b0;
        stat_vnc_packet_1519_1522_bytes_match   = (stat_vnc_tx_packet_1519_1522_bytes == stat_vnc_rx_packet_1519_1522_bytes) ? 1'b1 : 1'b0;
        stat_vnc_packet_1523_1548_bytes_match   = (stat_vnc_tx_packet_1523_1548_bytes == stat_vnc_rx_packet_1523_1548_bytes) ? 1'b1 : 1'b0;
        stat_vnc_packet_1549_2047_bytes_match   = (stat_vnc_tx_packet_1549_2047_bytes == stat_vnc_rx_packet_1549_2047_bytes) ? 1'b1 : 1'b0;
        stat_vnc_packet_2048_4095_bytes_match   = (stat_vnc_tx_packet_2048_4095_bytes == stat_vnc_rx_packet_2048_4095_bytes) ? 1'b1 : 1'b0;
        stat_vnc_packet_4096_8191_bytes_match   = (stat_vnc_tx_packet_4096_8191_bytes == stat_vnc_rx_packet_4096_8191_bytes) ? 1'b1 : 1'b0;
        stat_vnc_packet_8192_9215_bytes_match   = (stat_vnc_tx_packet_8192_9215_bytes == stat_vnc_rx_packet_8192_9215_bytes) ? 1'b1 : 1'b0;

    end


    vnc_stat_vio_0  i_vnc_stat_vio_0 (

        .clk            (axi_aclk),

        .probe_in0      (stat_vnc_total_bytes_match),
        .probe_in1      (stat_vnc_total_good_bytes_match),
        .probe_in2      (stat_vnc_total_packets_match),
        .probe_in3      (stat_vnc_total_good_packets_match),
        .probe_in4      (stat_vnc_broadcast_match),
        .probe_in5      (stat_vnc_multicast_match),
        .probe_in6      (stat_vnc_unicast_match),
        .probe_in7      (stat_vnc_vlan_match),
        .probe_in8      (stat_vnc_packet_64_bytes_match),
        .probe_in9      (stat_vnc_packet_65_127_bytes_match),
        .probe_in10     (stat_vnc_packet_128_255_bytes_match),
        .probe_in11     (stat_vnc_packet_256_511_bytes_match),
        .probe_in12     (stat_vnc_packet_512_1023_bytes_match),
        .probe_in13     (stat_vnc_packet_1024_1518_bytes_match),
        .probe_in14     (stat_vnc_packet_1519_1522_bytes_match),
        .probe_in15     (stat_vnc_packet_1523_1548_bytes_match),
        .probe_in16     (stat_vnc_packet_1549_2047_bytes_match),
        .probe_in17     (stat_vnc_packet_2048_4095_bytes_match),
        .probe_in18     (stat_vnc_packet_4096_8191_bytes_match),
        .probe_in19     (stat_vnc_packet_8192_9215_bytes_match),

        .probe_out0     (stat_tick_vio)

    );



endmodule

module gtfmac_vnc_latency # (

    parameter  SIMULATION       = "false",
    parameter  TIMER_WIDTH      = 16,
    parameter  RAM_DEPTH        = 4096,
    parameter  RAM_ADDR_WIDTH   = 12

)
(

    input       wire            data_rate,

    input       wire            tx_clk,
    input       wire            tx_rstn,

    input       wire            rx_clk,
    input       wire            rx_rstn,

    input       wire            lat_clk,
    input       wire            lat_rstn,

    input       wire            axi_clk,
    input       wire            axi_rstn,

    // Signalling from the MAC
    input       wire            tx_sopin,
    input       wire            tx_enain,
    input       wire            tx_rdyout,
    input       wire            tx_can_start,
    input       wire            tx_eopin,
    input       wire            tx_start_measured_run,

    input       wire            rx_sof,
    input       wire            rx_start_measured_run,

    // processor interface
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

    // Latency ILA
    output wire [15:0]          lat_mon_sent_time_ila,
    output wire [15:0]          lat_mon_rcvd_time_ila,
    output wire [15:0]          lat_mon_delta_time_ila,
    output wire                 lat_mon_send_event_ila,
    output wire                 lat_mon_rcv_event_ila,
    output wire [31:0]          lat_mon_delta_time_idx_ila
);

    logic                           go;             // start collecting samples
    logic                           full;           // status and also auto-clears go
    logic   [RAM_ADDR_WIDTH:0]      datav;          // Number of records
    logic                           pop;            // pop next entry
    logic                           clear;          // reset all pointers.  Assumes go=0
    logic   [RAM_ADDR_WIDTH-1:0]    lat_pkt_cnt;    // number of packets to collect

    logic   [TIMER_WIDTH-1:0]       tx_time;        // transmit time
    logic   [TIMER_WIDTH-1:0]       rx_time;        // receive time
    logic                           time_rdy;       // pulse when a read has occurred

    gtfmac_vnc_lat_mon # (
        .SIMULATION         (SIMULATION),
        .TIMER_WIDTH        (TIMER_WIDTH),
        .RAM_DEPTH          (RAM_DEPTH),
        .RAM_ADDR_WIDTH     (RAM_ADDR_WIDTH)
    )
    i_lat_mon   (

        .tx_clk                     (tx_clk),
        .tx_rstn                    (tx_rstn),

        .rx_clk                     (rx_clk),
        .rx_rstn                    (rx_rstn),

        .lat_clk                    (lat_clk),
        .lat_rstn                   (lat_rstn),

        .tx_sopin                   (tx_sopin),
        .tx_enain                   (tx_enain),
        .tx_rdyout                  (tx_rdyout),
        .tx_can_start               (tx_can_start),
        .tx_start_latency_run       (tx_start_measured_run),
        .tx_eopin                   (tx_eopin),

        .rx_sof                     (rx_sof),
        .rx_start_latency_run       (rx_start_measured_run),

        .axi_clk                    (axi_clk),
        .axi_rstn                   (axi_rstn),

        .data_rate                  (data_rate),
        .go                         (go),
        .full                       (full),
        .datav                      (datav),
        .pop                        (pop),
        .clear                      (clear),
        .lat_pkt_cnt                (lat_pkt_cnt),

        .tx_time                    (tx_time),
        .rx_time                    (rx_time),
        .time_rdy                   (time_rdy),

        // Latency monitor ILA signals
        .lat_mon_sent_time_ila      (lat_mon_sent_time_ila),
        .lat_mon_rcvd_time_ila      (lat_mon_rcvd_time_ila),
        .lat_mon_delta_time_ila     (lat_mon_delta_time_ila),
        .lat_mon_send_event_ila     (lat_mon_send_event_ila),
        .lat_mon_rcv_event_ila      (lat_mon_rcv_event_ila),
        .lat_mon_delta_time_idx_ila (lat_mon_delta_time_idx_ila)
    );

    gtfmac_vnc_lat_mon_pif  # (
        .TIMER_WIDTH        (TIMER_WIDTH),
        .RAM_ADDR_WIDTH     (RAM_ADDR_WIDTH)
    )
    i_lat_mon_pif   (

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

        .lm_go                      (go),
        .lm_full                    (full),
        .lm_datav                   (datav),
        .lm_pop                     (pop),
        .lm_clear                   (clear),
        .lm_lat_pkt_cnt             (lat_pkt_cnt),

        .lm_snd_time                (tx_time),
        .lm_rcv_time                (rx_time),
        .lm_time_rdy                (time_rdy)

    );


endmodule

module gtfmac_vnc_lat_mon # (
    parameter  SIMULATION       = "false",
    parameter  TIMER_WIDTH      = 16,
    parameter  RAM_DEPTH        = 4096,
    parameter  RAM_ADDR_WIDTH   = 12

)
(

    input       wire        tx_clk,
    input       wire        tx_rstn,

    input       wire        rx_clk,
    input       wire        rx_rstn,

    input       wire        lat_clk,
    input       wire        lat_rstn,

    input       wire        tx_sopin,
    input       wire        tx_enain,
    input       wire        tx_rdyout,
    input       wire        tx_can_start,
    input       wire        tx_eopin,

    input       wire        rx_sof,

    // These signals indicate that the sop of the NEXT packet will be collected for latency purposes
    input       wire                        tx_start_latency_run,   // co-incident with tx_sopin
    input       wire                        rx_start_latency_run,   // collected from MAC DA (comes after rx_sop)
    input       wire    [11:0]              lat_pkt_cnt,            // Number of frames to monitor.

    // processor interface
    input       wire                        axi_clk,
    input       wire                        axi_rstn,

    input       logic                       data_rate,  // data rate (0=10G, 1=25G)
    input       logic                       go,         // start collecting samples
    output      logic                       full,       // status and also auto-clears go
    output      logic   [RAM_ADDR_WIDTH:0]  datav,      // Number of records
    input       logic                       pop,        // pop next entry
    input       logic                       clear,      // reset all pointers.  Assumes go=0

    output      logic   [TIMER_WIDTH-1:0]   tx_time,    // transmit time
    output      logic   [TIMER_WIDTH-1:0]   rx_time,    // receive time
    output      logic                       time_rdy,    // pulse when a read has occurred

    // Latency monitor ILA signals
    output      wire    [15:0]              lat_mon_sent_time_ila,
    output      wire    [15:0]              lat_mon_rcvd_time_ila,
    output      wire    [15:0]              lat_mon_delta_time_ila,
    output      wire                        lat_mon_send_event_ila,
    output      wire                        lat_mon_rcv_event_ila,
    output      wire    [31:0]              lat_mon_delta_time_idx_ila

);

    localparam  RAM_WIDTH   = TIMER_WIDTH;
    localparam  ADDR_WIDTH  = RAM_ADDR_WIDTH;
    localparam  PTR_WIDTH   = RAM_ADDR_WIDTH+1;
    localparam  FULL_THRESH = RAM_DEPTH-12;

    reg     tx_pkt_sent;
    reg     rx_pkt_rcvd;

    reg     tx_init_run;
    reg     tx_start_run;
    reg     rx_start_run;

    reg     wait_for_can_start;

    reg     [TIMER_WIDTH-1:0]      timer;

    wire    sync_pkt_sent;
    wire    sync_pkt_rcvd;
    reg     sync_pkt_sent_R;
    reg     sync_pkt_rcvd_R;

    // These need to be delayed to ensure they come later than the send event they're associated with
    localparam LAT_START_DLY = 4;
    logic                         sync_tx_start_run;
    logic                         sync_rx_start_run;
    logic                         sync_tx_start_run_R;
    logic   [LAT_START_DLY-1:0]   sync_rx_start_run_R;

    wire    pkt_sent;
    wire    pkt_rcvd;

    (* ram_style = "block" *) reg  [RAM_WIDTH-1:0] tx_samples [RAM_DEPTH-1:0];
    (* ram_style = "block" *) reg  [RAM_WIDTH-1:0] rx_samples [RAM_DEPTH-1:0];

    logic   [PTR_WIDTH-1:0]     tx_wr_ptr, gry_tx_wr_ptr, gry_axi_tx_wr_ptr, axi_tx_wr_ptr;
    logic   [PTR_WIDTH-1:0]     rx_wr_ptr, gry_rx_wr_ptr, gry_axi_rx_wr_ptr, axi_rx_wr_ptr;

    logic   [PTR_WIDTH-1:0]     axi_rd_ptr, gry_axi_rd_ptr, gry_tx_rd_ptr, tx_rd_ptr;

    logic                       pop_R;
    logic  [TIMER_WIDTH-1:0]    axi_tx_time, axi_rx_time;

    logic                       clear_sync;

    logic   tx_start_run_pending;

    always @ (posedge tx_clk) begin

        if (tx_start_latency_run) begin
            tx_start_run_pending    <= 1'b1;
        end
        else if (tx_start_run_pending && tx_eopin) begin
            tx_start_run_pending    <= 1'b0;
            tx_start_run            <= ~tx_start_run;
        end

        if (tx_rstn == 1'b0) begin
            tx_start_run_pending    <= 1'b0;
            tx_start_run            <= 1'b0;
        end

    end

    // Level-sensitive signals that change state when an event occurs
    always @ (posedge tx_clk) begin

        if (wait_for_can_start) begin
            if (tx_can_start) begin
                tx_pkt_sent         <= ~tx_pkt_sent;
                wait_for_can_start  <= 0;
            end
        end
        else if (tx_sopin && tx_enain && tx_rdyout) begin
            if (tx_can_start || data_rate) begin
                tx_pkt_sent             <= ~tx_pkt_sent;
            end
            else begin
                wait_for_can_start      <= 1'b1;
            end
        end

        if (tx_rstn == 1'b0) begin
            tx_pkt_sent             <= 0;
            wait_for_can_start      <= 0;
        end

    end

    always @ (posedge rx_clk) begin

        if (rx_sof == 1'b1) begin
            rx_pkt_rcvd    <= ~rx_pkt_rcvd;
        end

        if (rx_start_latency_run) begin
            rx_start_run   <= ~rx_start_run;
        end

        if (rx_rstn == 1'b0) begin
            rx_pkt_rcvd             <= 0;
            rx_start_run   <= 0;
        end

    end

    // Apply sim wire delay to reflect hardware
    reg tx_pkt_sent_delay;
    generate
    if (SIMULATION == "true")  
        always@*  tx_pkt_sent_delay <= #1 tx_pkt_sent;
    else
        always@*  tx_pkt_sent_delay <= tx_pkt_sent;
    endgenerate
    
    gtfmac_vnc_syncer_level i_sync_pkt_sent_event (

      .reset      (lat_rstn),
      .clk        (lat_clk),

      .datain     (tx_pkt_sent_delay),
      .dataout    (sync_pkt_sent)

    );

    gtfmac_vnc_syncer_level i_sync_pkt_rcvd_event (

      .reset      (lat_rstn),
      .clk        (lat_clk),

      .datain     (rx_pkt_rcvd),
      .dataout    (sync_pkt_rcvd)

    );

    gtfmac_vnc_syncer_level i_sync_tx_measured_run_event (

      .reset      (lat_rstn),
      .clk        (lat_clk),

      .datain     (tx_start_run),
      .dataout    (sync_tx_start_run)

    );

    gtfmac_vnc_syncer_level i_sync_rx_measured_run_event (

      .reset      (lat_rstn),
      .clk        (lat_clk),

      .datain     (rx_start_run),
      .dataout    (sync_rx_start_run)

    );

    gtfmac_vnc_syncer_pulse i_sync_clear (
       .clkin        (axi_clk),
       .clkin_reset  (axi_rstn),
       .clkout       (lat_clk),
       .clkout_reset (lat_rstn),

       .pulsein      (clear),
       .pulseout     (clear_sync)
    );


    // Edge Detect
    always @ (posedge lat_clk) begin

        sync_pkt_sent_R    <= sync_pkt_sent;
        sync_pkt_rcvd_R    <= sync_pkt_rcvd;

        sync_tx_start_run_R    <= sync_tx_start_run;
        sync_rx_start_run_R    <= {sync_rx_start_run_R[LAT_START_DLY-2:0], sync_rx_start_run};

        if (lat_rstn == 1'b0) begin
            sync_pkt_sent_R         <= 0;
            sync_pkt_rcvd_R         <= 0;
            sync_tx_start_run_R     <= 0;
            sync_rx_start_run_R     <= 0;
        end

    end

    // Packet sent/receive pulse in the lat_clk domain
    assign  pkt_sent    = sync_pkt_sent_R ^ sync_pkt_sent;
    assign  pkt_rcvd    = sync_pkt_rcvd_R ^ sync_pkt_rcvd;

    // MEASURED RUNS
    logic           tx_go;
    logic           rx_go;
    logic   [11:0]  tx_pkt_rem;
    logic   [11:0]  rx_pkt_rem;

    always @ (posedge lat_clk) begin

        if (sync_tx_start_run_R ^ sync_tx_start_run) begin
            tx_go       <= 1'b1;
            tx_pkt_rem  <= lat_pkt_cnt;
        end
        else if (tx_go) begin
            if (pkt_sent) begin
                tx_pkt_rem  <= tx_pkt_rem - 1'b1;
            end
            else if (|tx_pkt_rem == 1'b0) begin
                tx_go   <= 1'b0;
            end
        end

        if (lat_rstn == 1'b0) begin
            tx_go   <= 1'b0;
        end

    end

    always @ (posedge lat_clk) begin

        if (sync_rx_start_run_R[LAT_START_DLY-1] ^ sync_rx_start_run_R[LAT_START_DLY-2]) begin
            rx_go       <= 1'b1;
            rx_pkt_rem  <= lat_pkt_cnt;
        end
        else if (rx_go) begin
            if (pkt_rcvd) begin
                rx_pkt_rem  <= rx_pkt_rem - 1'b1;
            end
            else if (|rx_pkt_rem == 1'b0) begin
                rx_go   <= 1'b0;
            end
        end

        if (lat_rstn == 1'b0) begin
            rx_go   <= 1'b0;
        end

    end

    // Timer
    always @ (posedge lat_clk) begin

        timer <= timer + 1;

        if (lat_rstn == 1'b0) begin
            timer <= 0;
        end

    end

    // "Open ended" latency run
    // Track how many frames are in the pipeline (max 15).  'go' is a signal from the PIF
    // that tells us to capture timers.  If we become full, go will self-clear which will
    // prevent an overflow, and the logic below ensures we push an equal number of send and
    // receive times so the CPU doesn't get confused.

    logic   [TIMER_WIDTH-1:0]   sent_time;
    logic   [TIMER_WIDTH-1:0]   rcvd_time;
    logic                       push_sent, push_rcvd;
    logic   [3:0]               pending_cnt;

    logic   send_event, rcv_event, rx_pending;

    logic   go_sync;

    gtfmac_vnc_syncer_level i_sync_go (

      .reset      (lat_rstn),
      .clk        (lat_clk),

      .datain     (go),
      .dataout    (go_sync)

    );

    assign  send_event  = pkt_sent & (go_sync | tx_go);
    assign  rx_pending  = |pending_cnt;
    assign  rcv_event   = pkt_rcvd & (rx_pending | rx_go);

    // Capture timer
    always @ (posedge lat_clk) begin

        push_sent   <= 1'b0;
        push_rcvd   <= 1'b0;

        if (send_event && !clear_sync) begin
            sent_time   <= timer;
            push_sent   <= 1'b1;
        end

        if (rcv_event && !clear_sync) begin
            rcvd_time   <= timer;
            push_rcvd   <= 1'b1;
        end

        if (lat_rstn == 1'b0) begin
            push_sent   <= 1'b0;
            push_rcvd   <= 1'b0;
        end

    end

    // The "pending" queue is only used when we are in open-ended measurement mode
    // If we are in a "run", we don't increment or decrement the pending_cnt
    always @ (posedge lat_clk) begin
        if (clear_sync) begin
            pending_cnt <= 'd0;
        end
        else begin
            case ({send_event & go_sync, rcv_event & rx_pending})

                2'b10: begin
                    pending_cnt <= pending_cnt + 1'b1;
                end

                2'b01: begin
                    pending_cnt <= pending_cnt - 1'b1;
                end

            endcase
        end

        if (lat_rstn == 1'b0) begin
            pending_cnt <= 'd0;
        end

    end

    // Manage the send and receive queue
    always @ (posedge lat_clk) begin

        if (clear_sync) begin
            tx_wr_ptr   <= 'd0;
            rx_wr_ptr   <= 'd0;
        end
        else begin

            if (push_sent) begin
                tx_wr_ptr   <= tx_wr_ptr + 1'b1;
            end

            if (push_rcvd) begin
                rx_wr_ptr   <= rx_wr_ptr + 1'b1;
            end

        end

        if (lat_rstn == 1'b0) begin
            tx_wr_ptr   <= 'd0;
            rx_wr_ptr   <= 'd0;
        end

    end

    assign time_rdy  = pop_R;

    always @ (posedge axi_clk) begin

        pop_R       <= pop;

        tx_time     <= axi_tx_time;
        rx_time     <= axi_rx_time;

        if (clear) begin
            axi_rd_ptr  <= 'd0;
        end
        else if (pop_R) begin
            axi_rd_ptr  <= axi_rd_ptr + 1'b1;
        end

        if (axi_rstn == 1'b0) begin
            pop_R       <= 1'b0;
            axi_rd_ptr  <= 'd0;
        end

    end

    // TX samples
    gtfmac_vnc_simple_bram # (
        .RAM_WIDTH  (RAM_WIDTH),
        .RAM_DEPTH  (RAM_DEPTH),
        .ADDR_WIDTH (ADDR_WIDTH)
    ) i_tx_sample_ram
    (

        .in_clk     (lat_clk),
        .out_clk    (axi_clk),

        .ena        (push_sent),
        .wea        (1'b1),
        .wr_addr    (tx_wr_ptr[ADDR_WIDTH-1:0]),
        .dina       (sent_time),

        .enb        (pop),
        .rd_addr    (axi_rd_ptr[ADDR_WIDTH-1:0]),
        .doutb      (axi_tx_time)

    );


    // RX samples
    gtfmac_vnc_simple_bram # (
        .RAM_WIDTH  (RAM_WIDTH),
        .RAM_DEPTH  (RAM_DEPTH),
        .ADDR_WIDTH (ADDR_WIDTH)
    ) i_rx_sample_ram
    (

        .in_clk     (lat_clk),
        .out_clk    (axi_clk),

        .ena        (push_rcvd),
        .wea        (1'b1),
        .wr_addr    (rx_wr_ptr[ADDR_WIDTH-1:0]),
        .dina       (rcvd_time),

        .enb        (pop),
        .rd_addr    (axi_rd_ptr[ADDR_WIDTH-1:0]),
        .doutb      (axi_rx_time)

    );


    always @ (posedge axi_clk) begin

        full    <= (datav >= FULL_THRESH) ? 1'b1 : 1'b0;
        datav   <= {1'b1, axi_rx_wr_ptr[ADDR_WIDTH-1:0]} - {axi_rd_ptr[PTR_WIDTH-1] ~^ axi_rx_wr_ptr[PTR_WIDTH-1], axi_rd_ptr[ADDR_WIDTH-1:0]};

        if (axi_rstn == 1'b0) begin
            full    <= 1'b0;
            datav   <= 'd0;
        end

    end


    always @ (posedge lat_clk) begin

        gry_tx_wr_ptr   <= f_bin2grayc(tx_wr_ptr, PTR_WIDTH);
        gry_rx_wr_ptr   <= f_bin2grayc(rx_wr_ptr, PTR_WIDTH);

        if (lat_rstn == 1'b0) begin
            gry_tx_wr_ptr   <= 'd0;
            gry_rx_wr_ptr   <= 'd0;
        end

    end

    gtfmac_vnc_syncer_level # (
        .WIDTH(PTR_WIDTH)
    )
    i_sync_tx_wr_ptr (

      .reset      (axi_rstn),
      .clk        (axi_clk),

      .datain     (gry_tx_wr_ptr),
      .dataout    (gry_axi_tx_wr_ptr)

    );

    gtfmac_vnc_syncer_level # (
        .WIDTH(PTR_WIDTH)
    )
    i_sync_rx_wr_ptr (

      .reset      (axi_rstn),
      .clk        (axi_clk),

      .datain     (gry_rx_wr_ptr),
      .dataout    (gry_axi_rx_wr_ptr)

    );


    always @ (posedge axi_clk) begin

        axi_tx_wr_ptr   <= f_grayc2bin(gry_axi_tx_wr_ptr, PTR_WIDTH);
        axi_rx_wr_ptr   <= f_grayc2bin(gry_axi_rx_wr_ptr, PTR_WIDTH);

        if (axi_rstn == 1'b0) begin
            axi_tx_wr_ptr   <= 'd0;
            axi_rx_wr_ptr   <= 'd0;
        end

    end

   function [16-1:0] f_bin2grayc (
     input [16-1:0] binin,
     input integer width
   );
   begin: main_f_bin2grayc

      f_bin2grayc = 16'b0;
      // Need width to be fixed. f_bin2grayc[width-1:0] =  binin[width-1] ^ {1'b0, binin[width-1:0]};
      f_bin2grayc[width-1] = binin[width-1];

      for (int i = 0; i < width -1; i++) begin
         f_bin2grayc[i] = binin[i] ^ binin[i+1];
      end
   end
   endfunction

   function [16-1:0] f_grayc2bin (
     input [16-1:0] grayin,
     input integer width
   );
   begin: main_f_grayc2bin

      f_grayc2bin          = 16'b0;
      f_grayc2bin[width-1] = grayin[width-1];

      for (int i = width - 2; i >= 0; i--) begin
         f_grayc2bin[i] = f_grayc2bin[i+1] ^ grayin[i];
      end
   end
   endfunction


    // ##################################################################
    //
    //   Delta Time Calculation
    //
    // ##################################################################

    reg  [15:0] delta_time;
    reg         delta_time_calc_ready_r0;
    reg         delta_time_calc_ready_r1;
    reg         delta_time_calc_ready_r2;
    
    // Delta Data
    reg  [31:0] delta_time_accu;
    reg  [31:0] delta_time_idx ;
    reg  [15:0] delta_time_max ;
    reg  [15:0] delta_time_min ;

    // Do not apply adjustment factor as it's now a fractional value..
    wire [15:0] delta_adj_factor = 0; // DELTA_ADJ_FACTOR;

    // Asserted when ready to calculate the delta time between a pair rcvd_time and sent_time
    always @(posedge lat_clk) begin
        if (!lat_rstn) begin
            delta_time_calc_ready_r0 <= 0;
        end else begin
            delta_time_calc_ready_r0 <= (rcv_event & !clear_sync) & (rx_pending == 1'b1);
            delta_time_calc_ready_r1 <= delta_time_calc_ready_r0;
            delta_time_calc_ready_r2 <= delta_time_calc_ready_r1;
        end
    end

    // Figure out latency and keep track of index
    always @(posedge lat_clk) begin
        if (!lat_rstn) begin
            delta_time <= 0;
            delta_time_idx <= 0;
        end else begin
            if (delta_time_calc_ready_r0) begin
                delta_time <= rcvd_time - sent_time - delta_adj_factor;
                delta_time_idx <= delta_time_idx + 1;
            end
        end
    end

    // Calculate min & max and add up delta_time for avg value calculation on the host
    always @(posedge lat_clk) begin
        if (!lat_rstn) begin
            delta_time_accu <= 0;
            delta_time_max <= 0;
            delta_time_min <= '1;
        end else begin
            if (delta_time_calc_ready_r1) begin
                delta_time_accu <= delta_time_accu + delta_time;

                if (delta_time > delta_time_max) begin
                    delta_time_max <= delta_time;
                end
                
                if (delta_time < delta_time_min) begin
                    delta_time_min <= delta_time;
                end
            end
        end
    end

    //// Delta Control 
    //reg         delta_done;
    //reg         delta_done_sync;
    //
    //always @(posedge lat_clk) begin
    //    if (!lat_rstn) begin
    //        delta_done <= 0;
    //    end else begin
    //        if ((delta_time_idx == lat_pkt_cnt) && (delta_time_idx > 0)) begin
    //            delta_done <= 1;
    //        end else begin
    //            delta_done <= 0;
    //        end
    //    end
    //end
    //
    //gtfmac_vnc_syncer_level # (
    //    .WIDTH(1)
    //)
    //i_sync_delta_done (
    //  .reset      (axi_rstn),
    //  .clk        (axi_clk),
    //  .datain     (delta_done),
    //  .dataout    (delta_done_sync)
    //);
    
   // ##################################################################
   //
   //   Assign ILA Signals
   //
   // ##################################################################
    
   assign lat_mon_sent_time_ila      = sent_time;
   assign lat_mon_rcvd_time_ila      = rcvd_time;
   assign lat_mon_delta_time_ila     = delta_time;
   assign lat_mon_send_event_ila     = send_event;
   assign lat_mon_rcv_event_ila      = rcv_event;
   assign lat_mon_delta_time_idx_ila = delta_time_idx;

endmodule

// ***************************************************************************
// Misc control and status registers
// ***************************************************************************

module gtfmac_vnc_lat_mon_pif # (
    parameter   TIMER_WIDTH     = 16,
    parameter   RAM_DEPTH       = 4096,
    parameter   RAM_ADDR_WIDTH  = 12
)
(

    input   wire            axi_aclk,
    input   wire            axi_aresetn,

    input   wire    [31:0]  axil_araddr,
    input   wire            axil_arvalid,
    output  reg             axil_arready,

    output  reg     [31:0]  axil_rdata,
    output  wire    [1:0]   axil_rresp,
    output  reg             axil_rvalid,
    input   wire            axil_rready,

    input   wire    [31:0]  axil_awaddr,
    input   wire            axil_awvalid,
    output  reg             axil_awready,

    input   wire    [31:0]  axil_wdata,
    input   wire            axil_wvalid,
    output  reg             axil_wready,

    output  reg             axil_bvalid,
    output  wire    [1:0]   axil_bresp,
    input   wire            axil_bready,

    output  logic                           lm_go,
    input   logic                           lm_full,
    input   logic   [RAM_ADDR_WIDTH:0]      lm_datav,
    output  logic                           lm_pop,
    output  logic                           lm_clear,
    input   logic   [TIMER_WIDTH-1:0]       lm_snd_time,
    input   logic   [TIMER_WIDTH-1:0]       lm_rcv_time,
    input   logic                           lm_time_rdy,
    output  logic   [RAM_ADDR_WIDTH-1:0]    lm_lat_pkt_cnt

);

    localparam      SEND_TIME_FIFO_ADDR = 12'h008;

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

                    2'b10: begin
                        wr_state_next       = WR_GET_DATA_STATE;
                        wr_addr_next        = axil_awaddr[11:0]; // Flop in the address
                        axil_awready_next   = 1'b0; // De-assert address 'ready' sig.
                    end

                    2'b01: begin
                        wr_state_next       = WR_GET_ADDR_STATE;
                        wr_data_next        = axil_wdata;
                        axil_wready_next    = 1'b0;
                    end

                    2'b11: begin
                        wr_state_next       = WR_SET_DATA_STATE;
                        wr_addr_next        = axil_awaddr[11:0];
                        wr_data_next        = axil_wdata;
                        axil_wready_next    = 1'b0;
                    end

                    2'b00: begin
                        wr_state_next = WR_IDLE_STATE;
                    end
                endcase
            end // WR_IDLE_STATE

            WR_GET_ADDR_STATE: begin


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
                    axil_wready_next    = 1'b0;
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

                    axil_bvalid_next    = 1'b0;
                    wr_state_next       = WR_IDLE_STATE;
                end

            end // WR_SET_DATA_STATE
        endcase
    end // COMB_LOGIC_WRITE_FSM_NEXT_STATE

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
                axil_arready_next = 1'b1;
                if (axil_arvalid == 1'b1 && axil_arready == 1'b1) begin
                    rd_addr_next        = axil_araddr[11:0];
                    do_rd_next          = 1'b1;
                    rd_state_next       = (axil_araddr[11:0] == SEND_TIME_FIFO_ADDR) ? RD_FIFO_STATE : RD_STATE;
                    axil_arready_next   = 1'b0;
                end
            end

            RD_STATE: begin
                axil_rdata_next   = rdata;
                axil_rvalid_next  = 1'b1;
                rd_state_next       = RD_ACK_STATE;
            end

            RD_FIFO_STATE: begin
                if (lm_time_rdy) begin
                    rd_state_next       = RD_STATE;
                end
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

        wr_addr                 <= wr_addr_next;
        wr_data                 <= wr_data_next;
    end // ASSIGN_WRITE_FSM_NEXT_STATE

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

    always @ (posedge axi_aclk) begin: REGISTER_WRITE

        if (axi_aresetn == 1'b0) begin

            lm_go                               <= 'd0;
            lm_pop                              <= 'd0;
            lm_clear                            <= 'd0;
            sticky_lm_full                      <= 1'b0;
            lm_lat_pkt_cnt                      <= {RAM_ADDR_WIDTH{1'b0}};

        end
        else begin

            lm_clear    <= 1'b0;
            lm_pop      <= 1'b0;

            if (do_rd_next && rd_addr_next == SEND_TIME_FIFO_ADDR) begin
                lm_pop  <= 1'b1;
            end

            if (lm_full)                sticky_lm_full           <= 1'b1;
            if (lm_full)                lm_go                    <= 1'b0;


            if (do_write) begin

                if (wr_addr == 12'h000) begin
                    lm_go           <= wr_data[0];
                    lm_clear        <= wr_data[4];
                end
                else if (wr_addr == 12'h004) begin
                    sticky_lm_full  <= ~wr_data[16]; // W1C
                end
                else if (wr_addr == 12'h010) begin
                    lm_lat_pkt_cnt  <= wr_data[RAM_ADDR_WIDTH-1:0];
                end

            end

        end

    end


    always_comb begin : READ_DATA_COMBINATORIAL

        rdata = 32'h0;

        unique if (rd_addr == 12'h000) begin
            rdata[0]        = lm_go;
        end
        else if (rd_addr == 12'h004) begin
            rdata[RAM_ADDR_WIDTH:0] = lm_datav;
            rdata[16]               = sticky_lm_full;
        end

        //  Special handling by the AXI-Lite state machine above
        else if (rd_addr == SEND_TIME_FIFO_ADDR) begin
            rdata[TIMER_WIDTH-1:0]      = lm_snd_time;
            rdata[TIMER_WIDTH-1+16:16]  = lm_rcv_time;
        end
        else if (rd_addr == 12'h010) begin
            rdata[RAM_ADDR_WIDTH-1:0]   = lm_lat_pkt_cnt;
        end

        else begin
            rdata = 32'h0;
        end


    end

endmodule

/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

////////////////////////////////////////////////////////////////////////////////
// Hierarchy :
//    super_module :
//      sub_module :
//
// Description :
//   This module increments a counter by the amount 'incr' on a clock-by-clock
//   basis.  It's assumed that retiming happens outside the block - for example,
//   the 'snapshot' pulse should be retimined into the 'clk' domain by
//   a syncer_pulse, and the counter_hold should be retimed (if necessary)
//   outside too.
//
//   NOTE:  rst was removed from this logic to reduce routing congestion.
//          Consequently the driver/verif env is required to "tick" (assert
//          snapshot input) after reset to bring the values to a known state.
//
//   NOTE:  If INCR_WIDTH > 1, then only capture the initial change, and wait
//          for incr to return to 0 before capturing another change.
//
////////////////////////////////////////////////////////////////////////////////

module gtfmac_vnc_stat_collector #(
   parameter INCR_WIDTH = 1,
   parameter CNTR_WIDTH = 32,
   parameter EDGE       = 0,  // Capture rising edge only.
   parameter SATURATE   = 0   // Stop counting, no overflow

) (
   input                        clk,
   input       [INCR_WIDTH-1:0] incr,
   input                        snapshot,
   output wire [CNTR_WIDTH-1:0] stat
);

   reg                    snapshot_R;
   reg   [CNTR_WIDTH-1:0] counter;
   reg   [CNTR_WIDTH-1:0] counter_hold;
   logic [INCR_WIDTH-1:0] incr_int;
   logic                  capture;

   assign stat = counter_hold;

   generate
      if (EDGE == 0) begin : no_edge_detect
         assign incr_int = incr;
      end
      else begin : edge_detect
         logic incr_R;

         always @(posedge clk) begin
             if (|incr == 1'b1) begin
                 incr_R <= 1'b1;
             end
             else if (|incr == 1'b0) begin
                 incr_R <= 1'b0;
             end
         end

         assign incr_int = {INCR_WIDTH{~incr_R}} & incr;
      end
   endgenerate

   always @ (posedge clk) begin
      snapshot_R <= snapshot;
      capture    <= ~snapshot_R & snapshot;

      if (capture == 1'b1) begin
         counter_hold <= counter;
         counter      <= incr_int;
      end
      else begin
         if (SATURATE == 0 || SATURATE == 1 && (&counter) == 1'b0) begin
            counter <=  counter + incr_int;
         end
      end
   end

endmodule

/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

////////////////////////////////////////////////////////////////////////////////
// Hierarchy :
//    super_module :
//      sub_module :
//
// Description :
//   Implement a simple FIFO.
//
////////////////////////////////////////////////////////////////////////////////

module gtfmac_vnc_simple_fifo #(
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

  input       [DEPTHLOG2:0] full_threshold,
  input       [DEPTHLOG2:0] a_empty_threshold,
  input       [DEPTHLOG2:0] a_full_threshold,
  input       [DEPTHLOG2:0] c_threshold,

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

module gtfmac_vnc_simple_bram # (
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

module gtfmac_vnc_clock_count (
   input   wire          clk,
   input   wire          one_second_edge,
   output  wire [32-1:0] clocks_per_second
);

   wire          ticks_per_one_second_edge_sync;
   wire          one_second_passed;
   reg  [32-1:0] one_second_count_live;
   reg  [32-1:0] one_second_count_snap;
   reg           ticks_per_one_second_edge_sync_d;

   assign clocks_per_second = one_second_count_snap;

   gtfmac_vnc_syncer_level #(
      .WIDTH (1)
   ) retime_ticks_per_one_second_edge (
      .datain  (one_second_edge),
      .dataout (ticks_per_one_second_edge_sync),
      .clk     (clk) ,
      .reset   (1'b1)
   );

   // Keep a copy from one cycle back.
   always @(posedge clk) begin
      ticks_per_one_second_edge_sync_d <= ticks_per_one_second_edge_sync;
   end

   // Edge detection
   assign one_second_passed = ticks_per_one_second_edge_sync_d ^
                              ticks_per_one_second_edge_sync;

   always @(posedge clk) begin
      if (one_second_passed == 1'b1) begin
         one_second_count_snap <= one_second_count_live;
         one_second_count_live <= 32'd0;
      end else begin
         one_second_count_live <= one_second_count_live + 1'b1;
      end
   end

endmodule

module gtfmac_vnc_syncer_bus
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


  gtfmac_vnc_syncer_level i_ready_clkout_sync (

    .clk        (clkout),
    .reset      (clkout_reset),

    .datain     (ready_clkin),
    .dataout    (ready)

  );  // i_ready_clkout_sync


  gtfmac_vnc_syncer_level i_req_clkout_sync (

    .clk        (clkout),
    .reset      (clkout_reset),

    .datain     (req_event),
    .dataout    (sync_req_event)

  );  // i_req_clkout_sync


  gtfmac_vnc_syncer_level i_ack_clkin_sync (

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

module gtfmac_vnc_syncer_pulse (

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

  gtfmac_vnc_syncer_level i_syncpls_req (

    .clk        (clkout),
    .reset      (clkout_reset),

    .datain     (req_event),
    .dataout    (sync_req_event)

  );  // i_syncpls_req


  gtfmac_vnc_syncer_level i_syncpls_ack (

    .clk        (clkin),
    .reset      (clkin_reset),

    .datain     (ack_event),
    .dataout    (sync_ack_event)

  );  // i_syncpls_ack

  gtfmac_vnc_syncer_reset i_syncpls_clkin_rstsync (

    .clk         (clkout),
    .reset_async (clkin_reset),
    .reset       (clkin_reset_out_sync)

  );  // i_syncpls_clkin_rstsync

  gtfmac_vnc_syncer_reset i_syncpls_clkout_rstsync (

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

`ifdef SARANCE_RTL_DEBUG
`endif


endmodule // syncer_pulse

module gtfmac_vnc_syncer_level
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

`ifdef SARANCE_RTL_DEBUG
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

`ifdef SARANCE_RTL_DEBUG
// synthesis translate_off
// synthesis translate_on
`endif

endmodule // syncer_level

module gtfmac_vnc_syncer_reset
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

module gtfmac_vnc_tx_fcs (

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
  input  wire i_poison, //EG
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
  reg  poison_d1; //EG
  reg  is_ctrl_d1;

  reg  ena_passthrough_d2;
  reg  ena_d2;
  reg  sop_d2;
  reg  [64-1:0] dat_d2;
  reg  eop_d2;
  reg  [3-1:0] mty_d2;
  reg  err_d2;
  reg  poison_d2; //EG
  reg  is_ctrl_d2;

  reg  ena_passthrough_d3;
  reg  ena_d3;
  reg  sop_d3;
  reg  [64-1:0] dat_d3;
  reg  eop_d3;
  reg  [3-1:0] mty_d3;
  reg  err_d3;
  reg  poison_d3; //EG
  reg  is_ctrl_d3;

  wire [64-1:0] loc_dat;
  wire loc_eop;
  wire loc_err; 
  wire loc_poison; //EG
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

  gtfmac_vnc_crc32_gen i_CRC32_GEN (

    .data_in              (dat_swap(i_dat_masked)),
    .crc_in               (full_crc_mod),
    .crc_out              (new_full_crc)

  );  // i_CRC32_GEN




  gtfmac_vnc_crc32_unroll_bytes i_CRC_UNROLL_BYTES (

    .clk                  (clk),
    .reset                (reset),
    .crc_in               (full_crc),
    .mty_in               (mty_d1),
    .crc_out              (final_crc)

  );  // i_CRC_UNROLL_BYTES

  wire [31:0] final_crc_mod;

  assign final_crc_mod = final_crc;

  gtfmac_vnc_fcs_append i_TX_FCS_APPEND (

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
                   
  assign loc_poison = (ctl_tx_add_fcs & spilled_d4) ? poison_spill_d4 : //EG
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
  assign o_poison          = loc_poison; //EG
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
              poison_spill_d4 <= poison_d3; //EG
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

module gtfmac_vnc_fcs_append (

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

module gtfmac_vnc_crc32_gen #(
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

module gtfmac_vnc_crc32_unroll_bytes #(
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

  gtfmac_vnc_fcs_unroll #(
    .CRC_POLY   (CRC_POLY),
    .DATA_WIDTH (8*0)
  ) i_FCS_UNROLL_BYTES_0 (
    .crc_in     (crc_in),
    .crc_out    (crc_o[0])
  );

  gtfmac_vnc_fcs_unroll #(
    .CRC_POLY   (CRC_POLY),
    .DATA_WIDTH (8*1)
  ) i_FCS_UNROLL_BYTES_1 (
    .crc_in     (crc_in),
    .crc_out    (crc_o[1])
  );

  gtfmac_vnc_fcs_unroll #(
    .CRC_POLY   (CRC_POLY),
    .DATA_WIDTH (8*2)
  ) i_FCS_UNROLL_BYTES_2 (
    .crc_in     (crc_in),
    .crc_out    (crc_o[2])
  );

  gtfmac_vnc_fcs_unroll #(
    .CRC_POLY   (CRC_POLY),
    .DATA_WIDTH (8*3)
  ) i_FCS_UNROLL_BYTES_3 (
    .crc_in     (crc_in),
    .crc_out    (crc_o[3])
  );

  gtfmac_vnc_fcs_unroll #(
    .CRC_POLY   (CRC_POLY),
    .DATA_WIDTH (8*4)
  ) i_FCS_UNROLL_BYTES_4 (
    .crc_in     (crc_in),
    .crc_out    (crc_o[4])
  );

  gtfmac_vnc_fcs_unroll #(
    .CRC_POLY   (CRC_POLY),
    .DATA_WIDTH (8*5)
  ) i_FCS_UNROLL_BYTES_5 (
    .crc_in     (crc_in),
    .crc_out    (crc_o[5])
  );

  gtfmac_vnc_fcs_unroll #(
    .CRC_POLY   (CRC_POLY),
    .DATA_WIDTH (8*6)
  ) i_FCS_UNROLL_BYTES_6 (
    .crc_in     (crc_in),
    .crc_out    (crc_o[6])
  );

  gtfmac_vnc_fcs_unroll #(
    .CRC_POLY   (CRC_POLY),
    .DATA_WIDTH (8*7)
  ) i_FCS_UNROLL_BYTES_7 (
    .crc_in     (crc_in),
    .crc_out    (crc_o[7])
  );

endmodule  // crc32_unroll_bytes

module gtfmac_vnc_fcs_unroll #(
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