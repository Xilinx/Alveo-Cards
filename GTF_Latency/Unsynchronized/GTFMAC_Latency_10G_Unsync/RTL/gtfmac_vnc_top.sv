/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

`include "gtfmac_vnc_top.vh"

module gtfmac_vnc_top # (
    parameter ONE_SECOND_COUNT = 28'd200_000_000,
    parameter TIMER_WIDTH      = 16,
    parameter RAM_ADDR_WIDTH   = 12,
    parameter SIMULATION       = "false"
)
(
    // exdes IOs
    output  wire                gtf_ch_gtftxn,
    output  wire                gtf_ch_gtftxp,
    input   wire                gtf_ch_gtfrxn,
    input   wire                gtf_ch_gtfrxp,

    input   wire                refclk_p,
    input   wire                refclk_n,

    input   wire                hb_gtwiz_reset_clk_freerun_p_in,
    input   wire                hb_gtwiz_reset_clk_freerun_n_in,

    // QSFP IOs
    output wire                 FPGA_MUX0_RSTN, 
    output wire                 FPGA_MUX1_RSTN,
    output wire                 QSFPDD0_IO_RESET_B, 
    output wire                 QSFPDD1_IO_RESET_B,
    output wire                 QSFPDD2_IO_RESET_B, 
    output wire                 QSFPDD3_IO_RESET_B, 
    
    inout  wire                 FPGA_SDA_R,
    inout  wire                 FPGA_SCL_R

);

    // System Reset...
    wire            hb_gtwiz_reset_all_in;

    // To-do: Make them outputs for sim
    wire gtwiz_reset_tx_done_out;
    wire gtwiz_reset_rx_done_out;
    wire gtf_cm_qpll0_lock;

    // Master JTAG AXI I/F to AXI Interconnect...
    wire            axi_aclk ;
    wire            axi_aresetn;

    wire [31:0]     jtag_axil_araddr;
    wire            jtag_axil_arvalid;
    wire            jtag_axil_rready;
    wire [31:0]     jtag_axil_awaddr;
    wire [2:0]      jtag_axil_awprot;
    wire [2:0]      jtag_axil_arprot;
    wire [3:0]      jtag_axil_wstrb;
    wire            jtag_axil_awvalid;
    wire [31:0]     jtag_axil_wdata;
    wire            jtag_axil_wvalid;
    wire            jtag_axil_bready;
    wire            jtag_axil_arready;
    wire [31:0]     jtag_axil_rdata;
    wire [1:0]      jtag_axil_rresp;
    wire            jtag_axil_rvalid;
    wire            jtag_axil_awready;
    wire            jtag_axil_wready;
    wire            jtag_axil_bvalid;
    wire [1:0]      jtag_axil_bresp;
    
    //  VNC Control Module AXI Interface
    wire [31:0]     vnc_axil_araddr;
    wire            vnc_axil_arvalid;
    wire            vnc_axil_arready;
    wire [31:0]     vnc_axil_rdata;
    wire [1:0]      vnc_axil_rresp;
    wire            vnc_axil_rvalid;
    wire            vnc_axil_rready;
    wire [31:0]     vnc_axil_awaddr;
    wire            vnc_axil_awvalid;
    wire            vnc_axil_awready;
    wire [31:0]     vnc_axil_wdata;
    wire            vnc_axil_wvalid;
    wire            vnc_axil_wready;
    wire            vnc_axil_bvalid;
    wire [1:0]      vnc_axil_bresp;
    wire            vnc_axil_bready;

    // GTF AXI Interface
    wire [31:0]     gtf_axil_araddr;
    wire            gtf_axil_arvalid;
    wire            gtf_axil_arready;
    wire [31:0]     gtf_axil_rdata;
    wire [1:0]      gtf_axil_rresp;
    wire            gtf_axil_rvalid;
    wire            gtf_axil_rready;
    wire [31:0]     gtf_axil_awaddr;
    wire            gtf_axil_awvalid;
    wire            gtf_axil_awready;
    wire [31:0]     gtf_axil_wdata;
    wire            gtf_axil_wvalid;
    wire            gtf_axil_wready;
    wire            gtf_axil_bvalid;
    wire [1:0]      gtf_axil_bresp;
    wire            gtf_axil_bready;
    wire [2:0]      gtf_axil_arprot;
    wire [2:0]      gtf_axil_awprot;
    wire [3:0]      gtf_axil_wstrb;

    // Latency Module AXI Interface
    wire [31:0]     lat_axil_araddr;
    wire            lat_axil_arvalid;
    wire            lat_axil_arready;
    wire [31:0]     lat_axil_rdata;
    wire [1:0]      lat_axil_rresp;
    wire            lat_axil_rvalid;
    wire            lat_axil_rready;
    wire [31:0]     lat_axil_awaddr;
    wire            lat_axil_awvalid;
    wire            lat_axil_awready;
    wire [31:0]     lat_axil_wdata;
    wire            lat_axil_wvalid;
    wire            lat_axil_wready;
    wire            lat_axil_bvalid;
    wire [1:0]      lat_axil_bresp;
    wire            lat_axil_bready;

    // Link Status/Control
    wire            link_down_latched_reset_in;
    wire            link_status_out;
    wire            link_down_latched_out;
    wire            link_maintained;

    // 644 Mhz RX/TXUSRCLK from GTF
    wire            tx_axis_clk;
    wire            tx_axis_rst;
    wire            rx_axis_clk;
    wire            rx_axis_rst;

    // 425 Mhz System clock generated from 300 Mhz freerunning clock
    wire            sys_rst;

    // Latency clock
    wire   lat_clk;
    wire   lat_rstn;
    assign lat_clk  = rx_axis_clk;
    assign lat_rstn = ~rx_axis_rst;


    // Latency monitor ILA signals
    wire [TIMER_WIDTH-1:0] lat_mon_sent_time_ila;              
    wire [TIMER_WIDTH-1:0] lat_mon_rcvd_time_ila;              
    wire [TIMER_WIDTH-1:0] lat_mon_delta_time_ila;             
    wire                   lat_mon_send_event_ila;             
    wire                   lat_mon_rcv_event_ila;
    wire [31:0]            lat_mon_delta_time_idx_ila;         


    // GTF TX Resets from VNC Core
    wire            vnc_gtf_ch_gttxreset;
    wire            vnc_gtf_ch_txpmareset;
    wire            vnc_gtf_ch_txpcsreset;
    wire            vnc_gtf_ch_gtrxreset;

    // GTF RX Resets from VNC Core
    wire            vnc_gtf_ch_rxpmareset;
    wire            vnc_gtf_ch_rxdfelpmreset;
    wire            vnc_gtf_ch_eyescanreset;
    wire            vnc_gtf_ch_rxpcsreset;
    wire            vnc_gtf_cm_qpll0reset;
    wire            gtwiz_reset_tx_pll_and_datapath_in;
    wire            gtwiz_reset_tx_datapath_in;
    wire            gtwiz_reset_rx_pll_and_datapath_in;
    wire            gtwiz_reset_rx_datapath_in;



    wire            gtf_ch_rxsyncdone;
    wire            gtf_ch_txsyncdone;
    wire            wa_complete_flg;

    wire            stat_gtf_rx_internal_local_fault;
    wire            stat_gtf_rx_local_fault;
    wire            stat_gtf_rx_received_local_fault;
    wire            stat_gtf_rx_remote_fault;

    wire            stat_gtf_rx_block_lock;
    wire            gtf_rx_bitslip;
    wire            gtf_rx_disable_bitslip;
    wire            gtf_rx_slip_pma;
    wire            gtf_rx_slip_pma_rdy;
    wire            gtf_rx_gb_seq_sync;
    wire            gtf_rx_slip_one_ui;


    // RX/TX Rawdata and SOF Signals
    wire [39:0]     gtf_ch_txrawdata;
    wire [39:0]     gtf_ch_rxrawdata;


    // RX/TX AXI-S and SOF Signals
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

    wire            f_clk;
    wire            f_rst;

    wire       ctl_gb_seq_sync;                
    wire       ctl_disable_bitslip;            
    wire       ctl_correct_bitslip;            
    wire [6:0] stat_bitslip_cnt;               
    wire [6:0] stat_bitslip_issued;            
    wire       stat_excessive_bitslip;         
    wire       stat_bitslip_locked;            
    wire       stat_bitslip_busy;              
    wire       stat_bitslip_done;              

generate
if ( SIMULATION == "false") begin
    vio_1 vio_inst (
        .clk          ( axi_aclk                   ),
        
        .probe_in0    ( link_status_out            ),
        .probe_in1    ( link_down_latched_out      ),
        .probe_in2    ( link_maintained            ),
        .probe_in3    ( gtf_ch_rxsyncdone          ),
        .probe_in4    ( gtf_ch_txsyncdone          ),
        .probe_in5    ( 'h0                        ),
        .probe_in6    ( 'h0                        ),
        .probe_in7    ( wa_complete_flg            ),
        .probe_in8    ( gtf_ch_gtrxreset           ),
        .probe_in9    ( gtf_ch_gtrxreset           ),
        
        .probe_out0   ( hb_gtwiz_reset_all_in      )
    );
end
endgenerate

    wire freerun_clk;
    wire sys_clk_out;
    wire qsfp_i2c_clk;
    wire clk_wiz_reset = 1'b0;
    wire clk_locked;

    clk_wiz_0 clk_wiz_0_inst (
        // Clock out ports
        .clk_out1       (freerun_clk),   // output 200 MHz
        .clk_out2       (sys_clk_out),   // output 425 MHz
        .clk_out3       (qsfp_i2c_clk),  // output 50 MHz
        // Status and control signals
        .reset          (clk_wiz_reset), // input reset
        .locked         (clk_locked),    // output locked
        // Clock in ports
        .clk_in1_p      (hb_gtwiz_reset_clk_freerun_p_in),
        .clk_in1_n      (hb_gtwiz_reset_clk_freerun_n_in)
    );    

//------------------------------------------------------------------------------
//
//    JTAG Interface for HW Manager 
//
//------------------------------------------------------------------------------

    jtag_axi_0 u_jtag_axi_0 (
        // Common AXI I/F Clock and Reset
        .aclk             (axi_aclk),         // input wire aclk
        .aresetn          (axi_aresetn),      // input wire aresetn

        // JTAG AXI I/F to AXI Interconnect
        .m_axi_awaddr     (jtag_axil_awaddr),    // output wire [31 : 0] m_axi_awaddr
        .m_axi_awprot     (jtag_axil_awprot),    // output wire [2 : 0] m_axi_awprot
        .m_axi_awvalid    (jtag_axil_awvalid),   // output wire m_axi_awvalid
        .m_axi_awready    (jtag_axil_awready),   // input wire m_axi_awready
        .m_axi_wdata      (jtag_axil_wdata),     // output wire [31 : 0] m_axi_wdata
        .m_axi_wstrb      (jtag_axil_wstrb),     // output wire [3 : 0] m_axi_wstrb
        .m_axi_wvalid     (jtag_axil_wvalid),    // output wire m_axi_wvalid
        .m_axi_wready     (jtag_axil_wready),    // input wire m_axi_wready
        .m_axi_bresp      (jtag_axil_bresp),     // input wire [1 : 0] m_axi_bresp
        .m_axi_bvalid     (jtag_axil_bvalid),    // input wire m_axi_bvalid
        .m_axi_bready     (jtag_axil_bready),    // output wire m_axi_bready
        .m_axi_araddr     (jtag_axil_araddr),    // output wire [31 : 0] m_axi_araddr
        .m_axi_arprot     (jtag_axil_arprot),    // output wire [2 : 0] m_axi_arprot
        .m_axi_arvalid    (jtag_axil_arvalid),   // output wire m_axi_arvalid
        .m_axi_arready    (jtag_axil_arready),   // input wire m_axi_arready
        .m_axi_rdata      (jtag_axil_rdata),     // input wire [31 : 0] m_axi_rdata
        .m_axi_rresp      (jtag_axil_rresp),     // input wire [1 : 0] m_axi_rresp
        .m_axi_rvalid     (jtag_axil_rvalid),    // input wire m_axi_rvalid
        .m_axi_rready     (jtag_axil_rready)     // output wire m_axi_rready
    );


//------------------------------------------------------------------------------
//
//    AXI Interconnect from JTAG Interface
//
//------------------------------------------------------------------------------

    axil_ctrl i_axil_ctrl (
        // Common AXI I/F Clock and Reset
        .ACLK_0                             (axi_aclk),
        .ARESETN_0                          (axi_aresetn),

        // AXI I/F from JTAG AXI I/F Module
        .S00_AXI_0_araddr                   (jtag_axil_araddr),
        .S00_AXI_0_arprot                   (jtag_axil_arprot),
        .S00_AXI_0_arready                  (jtag_axil_arready),
        .S00_AXI_0_arvalid                  (jtag_axil_arvalid),
        .S00_AXI_0_awaddr                   (jtag_axil_awaddr),
        .S00_AXI_0_awprot                   (jtag_axil_awprot),
        .S00_AXI_0_awready                  (jtag_axil_awready),
        .S00_AXI_0_awvalid                  (jtag_axil_awvalid),
        .S00_AXI_0_bready                   (jtag_axil_bready),
        .S00_AXI_0_bresp                    (jtag_axil_bresp),
        .S00_AXI_0_bvalid                   (jtag_axil_bvalid),
        .S00_AXI_0_rdata                    (jtag_axil_rdata),
        .S00_AXI_0_rready                   (jtag_axil_rready),
        .S00_AXI_0_rresp                    (jtag_axil_rresp),
        .S00_AXI_0_rvalid                   (jtag_axil_rvalid),
        .S00_AXI_0_wdata                    (jtag_axil_wdata),
        .S00_AXI_0_wready                   (jtag_axil_wready),
        .S00_AXI_0_wstrb                    (jtag_axil_wstrb),
        .S00_AXI_0_wvalid                   (jtag_axil_wvalid),

        // VNC Control Module AXI Interface
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

        // GTF AXI Interface
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

        // Latency Module AXI Interface
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
        .M02_AXI_0_wvalid                   (lat_axil_wvalid)
    );

//------------------------------------------------------------------------------
//
//   GTF (MAC mode) VNC Core
//
//------------------------------------------------------------------------------

    wire pattern_sent;  
    wire pattern_rcvd;  

    gtfmac_vnc_core # (
        .ONE_SECOND_COUNT   (ONE_SECOND_COUNT)
    ) i_gtfmac_vnc_core (
        // Common AXI I/F Clock and Reset
        .axi_aclk                           (axi_aclk),                         // input
        .axi_aresetn                        (axi_aresetn),                      // input

        //  VNC Control Module AXI Interface
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

        //  Latency Monitor AXI Interface
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

        // 644 Mhz TX and RX USR Clock domains...
        .tx_clk                             (tx_axis_clk),                      // input wire
        .tx_rst                             (tx_axis_rst),                      // input wire
        .rx_clk                             (rx_axis_clk),                      // input wire
        .rx_rst                             (rx_axis_rst),                      // input wire

        // 425 Mhz System Clock
        .gen_clk                            (sys_clk_out),                          // input       wire
        .gen_rst                            (sys_rst),                          // input       wire

        // Monitor Clock
        .mon_clk                            (sys_clk_out),                          // input       wire
        .mon_rst                            (sys_rst),                          // input       wire
    
        // Latency Clock
        .lat_clk                            (lat_clk),                          // input       wire
        .lat_rstn                           (lat_rstn),                         // input       wire

        .pattern_sent                       (pattern_sent),  
        .pattern_rcvd                       (pattern_rcvd),  

        // Tx/RX RawData
        .gtf_ch_txrawdata                   (gtf_ch_txrawdata),
        .gtf_ch_rxrawdata                   (gtf_ch_rxrawdata),

        // Tx/RX AXI-S Data
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

        .rx_axis_tvalid                     (rx_axis_tvalid),                   // input       wire
        .rx_axis_tdata                      (rx_axis_tdata),                    // input       wire [63:0]
        .rx_axis_tlast                      (rx_axis_tlast),                    // input       wire [7:0]
        .rx_axis_tpre                       (rx_axis_tpre),                     // input       wire [7:0]
        .rx_axis_terr                       (rx_axis_terr),                     // input       wire
        .rx_axis_tterm                      (rx_axis_tterm),                    // input       wire [4:0]
        .rx_axis_tsof                       (rx_axis_tsof),                     // input       wire [1:0]

        // GTF TX/RX Resets from VNC Core
        .vnc_gtf_ch_gttxreset               (vnc_gtf_ch_gttxreset),             // output
        .vnc_gtf_ch_txpmareset              (vnc_gtf_ch_txpmareset),            // output
        .vnc_gtf_ch_txpcsreset              (vnc_gtf_ch_txpcsreset),            // output
        .vnc_gtf_ch_gtrxreset               (vnc_gtf_ch_gtrxreset),             // output
        .vnc_gtf_ch_rxpmareset              (vnc_gtf_ch_rxpmareset),            // output
        .vnc_gtf_ch_rxdfelpmreset           (vnc_gtf_ch_rxdfelpmreset),         // output
        .vnc_gtf_ch_eyescanreset            (vnc_gtf_ch_eyescanreset),          // output
        .vnc_gtf_ch_rxpcsreset              (vnc_gtf_ch_rxpcsreset),            // output
        .vnc_gtf_cm_qpll0reset              (vnc_gtf_cm_qpll0reset),            // output
        .gtwiz_reset_tx_pll_and_datapath_in (gtwiz_reset_tx_pll_and_datapath_in),
        .gtwiz_reset_tx_datapath_in         (gtwiz_reset_tx_datapath_in),
        .gtwiz_reset_rx_pll_and_datapath_in (gtwiz_reset_rx_pll_and_datapath_in),
        .gtwiz_reset_rx_datapath_in         (gtwiz_reset_rx_datapath_in),

        // Latency monitor ILA signals
        .lat_mon_sent_time_ila              (lat_mon_sent_time_ila),
        .lat_mon_rcvd_time_ila              (lat_mon_rcvd_time_ila),
        .lat_mon_delta_time_ila             (lat_mon_delta_time_ila),
        .lat_mon_send_event_ila             (lat_mon_send_event_ila),
        .lat_mon_rcv_event_ila              (lat_mon_rcv_event_ila),
        .lat_mon_delta_time_idx_ila         (lat_mon_delta_time_idx_ila),

        .stat_gtf_rx_internal_local_fault   (stat_gtf_rx_internal_local_fault), // input
        .stat_gtf_rx_local_fault            (stat_gtf_rx_local_fault),          // input
        .stat_gtf_rx_received_local_fault   (stat_gtf_rx_received_local_fault), // input
        .stat_gtf_rx_remote_fault           (stat_gtf_rx_remote_fault),         // input

        .vnc_gtf_ch_txuserrdy               (vnc_gtf_ch_txuserrdy),
        .vnc_gtf_ch_rxuserrdy               (vnc_gtf_ch_rxuserrdy),

        .block_lock                         (stat_gtf_rx_block_lock),           // input
        
        // Bitslip correction - to gtfwizard_0_fab_wrap
        .ctl_gb_seq_sync                    (ctl_gb_seq_sync),     
        .ctl_disable_bitslip                (ctl_disable_bitslip),
        .ctl_correct_bitslip                (ctl_correct_bitslip),
        .stat_bitslip_cnt                   (stat_bitslip_cnt),
        .stat_bitslip_issued                (stat_bitslip_issued),
        .stat_excessive_bitslip             (stat_excessive_bitslip),
        .stat_bitslip_locked                (stat_bitslip_locked),
        .stat_bitslip_busy                  (stat_bitslip_busy),
        .stat_bitslip_done                  (stat_bitslip_done)
    );

//------------------------------------------------------------------------------
//
//   GTF (MAC mode) fabric wrapper design
//
//------------------------------------------------------------------------------

    gtfwizard_0_fab_wrap # (
        .NUM_CHANNEL(1)
    ) i_gtfmac (
        // Control plane
        .aclk                               (axi_aclk),
        .aresetn                            (axi_aresetn),

        .s_axi_awaddr                       ({16'b0, gtf_axil_awaddr[15:0]}),   // input  wire [31 : 0]
        .s_axi_awprot                       (gtf_axil_awprot),                  // output wire [2 : 0]
        .s_axi_awvalid                      (gtf_axil_awvalid),                 // input  wire
        .s_axi_awready                      (gtf_axil_awready),                 // output wire
        .s_axi_wdata                        (gtf_axil_wdata),                   // input  wire [31 : 0]
        .s_axi_wstrb                        (gtf_axil_wstrb),                   // output wire [3 : 0]
        .s_axi_wvalid                       (gtf_axil_wvalid),                  // input  wire
        .s_axi_wready                       (gtf_axil_wready),                  // output wire
        .s_axi_bresp                        (gtf_axil_bresp),                   // output wire [1 : 0]
        .s_axi_bvalid                       (gtf_axil_bvalid),                  // output wire
        .s_axi_bready                       (gtf_axil_bready),                  // input  wire
        .s_axi_araddr                       ({16'b0, gtf_axil_araddr[15:0]}),   // input  wire [31 : 0]
        .s_axi_arprot                       (gtf_axil_arprot),                  // output wire [2 : 0]
        .s_axi_arvalid                      (gtf_axil_arvalid),                 // input  wire
        .s_axi_arready                      (gtf_axil_arready),                 // output wire
        .s_axi_rdata                        (gtf_axil_rdata),                   // output wire [31 : 0]
        .s_axi_rresp                        (gtf_axil_rresp),                   // output wire [1 : 0]
        .s_axi_rvalid                       (gtf_axil_rvalid),                  // output wire
        .s_axi_rready                       (gtf_axil_rready),                  // input  wire

        // original exdes IOs
        .gtf_ch_gtftxn                      (gtf_ch_gtftxn),                    // output
        .gtf_ch_gtftxp                      (gtf_ch_gtftxp),                    // output
        .gtf_ch_gtfrxn                      (gtf_ch_gtfrxn),                    // input
        .gtf_ch_gtfrxp                      (gtf_ch_gtfrxp),                    // input

        .refclk_p                           (refclk_p),                         // input
        .refclk_n                           (refclk_n),                         // input
        .freerun_clk                        (freerun_clk),                      // input
        .hb_gtwiz_reset_all_in              (hb_gtwiz_reset_all_in),            // input

        .gtwiz_reset_tx_done_out            (gtwiz_reset_tx_done_out),          //output
        .gtwiz_reset_rx_done_out            (gtwiz_reset_rx_done_out),          //output
        .gtf_cm_qpll0_lock                  (gtf_cm_qpll0_lock),                //output

        .link_down_latched_reset_in         (link_down_latched_reset_in),       // input
        .link_status_out                    (link_status_out),                  // output
        .link_down_latched_out              (link_down_latched_out),            // output
        .link_maintained                    (link_maintained),                  // output

        .gtf_ch_rxsyncdone                  (gtf_ch_rxsyncdone),                // output
        .gtf_ch_txsyncdone                  (gtf_ch_txsyncdone),                // output
        .wa_complete_flg                    (wa_complete_flg),                  // output

        // generated clocks and resets from exdes
        .tx_axis_clk                        (tx_axis_clk),                      // output
        .tx_axis_rst                        (tx_axis_rst),                      // output

        .rx_axis_clk                        (rx_axis_clk),                      // output 
        .rx_axis_rst                        (rx_axis_rst),                      // output 

        .sys_clk_out                        (sys_clk_out),                      // input 
        .sys_rst_out                        (sys_rst),                          // output 

        .hb_gtf_ch_txdp_reset_in            (1'b0),                             // input 
        .hb_gtf_ch_rxdp_reset_in            (1'b0),                             // input 

        // PTP signals
        // .gtf_ch_rxptpsop                    (rx_ptp_sop),                    // output wire
        // .gtf_ch_rxptpsoppos                 (rx_ptp_sop_pos),                // output wire
        // .gtf_ch_rxgbseqstart                (rx_gb_seq_start),               // output wire

        // hwchk IOs
        .hwchk_gtf_ch_gttxreset             (vnc_gtf_ch_gttxreset),             // input 
        .hwchk_gtf_ch_txpmareset            (vnc_gtf_ch_txpmareset),            // input  
        .hwchk_gtf_ch_txpcsreset            (vnc_gtf_ch_txpcsreset),            // input 
        .hwchk_gtf_ch_gtrxreset             (vnc_gtf_ch_gtrxreset),             // input  
        .hwchk_gtf_ch_rxpmareset            (vnc_gtf_ch_rxpmareset),            // input 
        .hwchk_gtf_ch_rxdfelpmreset         (vnc_gtf_ch_rxdfelpmreset),         // input 
        .hwchk_gtf_ch_eyescanreset          (vnc_gtf_ch_eyescanreset),          // input 
        .hwchk_gtf_ch_rxpcsreset            (vnc_gtf_ch_rxpcsreset),            // input 
        .hwchk_gtf_cm_qpll0reset            (vnc_gtf_cm_qpll0reset),            // input 

        .hwchk_gtf_ch_txuserrdy             (vnc_gtf_ch_txuserrdy),             // input 
        .hwchk_gtf_ch_rxuserrdy             (vnc_gtf_ch_txuserrdy),             // input 

        .gtwiz_reset_tx_pll_and_datapath_in (gtwiz_reset_tx_pll_and_datapath_in), // input 
        .gtwiz_reset_tx_datapath_in         (gtwiz_reset_tx_datapath_in),         // input 
        .gtwiz_reset_rx_pll_and_datapath_in (gtwiz_reset_rx_pll_and_datapath_in), // input 
        .gtwiz_reset_rx_datapath_in         (gtwiz_reset_rx_datapath_in),         // input 

        .gtf_ch_statrxinternallocalfault    (stat_gtf_rx_internal_local_fault), // output 
        .gtf_ch_statrxlocalfault            (stat_gtf_rx_local_fault),          // output 
        .gtf_ch_statrxreceivedlocalfault    (stat_gtf_rx_received_local_fault), // output 
        .gtf_ch_statrxremotefault           (stat_gtf_rx_remote_fault),         // output  
        .gtf_ch_statrxblocklock             (stat_gtf_rx_block_lock),           // output 

        .gtf_ch_txaxistready                (tx_axis_tready),                   // output
        .gtf_ch_txaxistvalid                (tx_axis_tvalid),                   // input 
        .gtf_ch_txaxistdata                 (tx_axis_tdata),                    // input [63:0]
        .gtf_ch_txaxistlast                 (tx_axis_tlast),                    // input [7:0]
        .gtf_ch_txaxistpre                  (tx_axis_tpre),                     // input [7:0]
        .gtf_ch_txaxisterr                  (tx_axis_terr),                     // input
        .gtf_ch_txaxistterm                 (tx_axis_tterm),                    // input [4:0]
        .gtf_ch_txaxistsof                  (tx_axis_tsof),                     // input [1:0]
        .gtf_ch_txaxistpoison               (tx_axis_tpoison),                  // input 
        .gtf_ch_txaxistcanstart             (tx_axis_tcan_start),               // output
        .gtf_ch_txptpsop                    (tx_ptp_sop),                       // output
        .gtf_ch_txptpsoppos                 (tx_ptp_sop_pos),                   // output
        .gtf_ch_txgbseqstart                (tx_gb_seq_start),                  // output
        .gtf_ch_txunfout                    (tx_unfout),                        // output
        
        // PTP signals
        // .tx_ptp_tstamp_out                  (tx_ptp_tstamp_out      ),       // output
        // .rx_ptp_tstamp_out                  (rx_ptp_tstamp_out      ),       // output
        // .rx_ptp_tstamp_valid_out            (rx_ptp_tstamp_valid_out),       // output
        // .tx_ptp_tstamp_valid_out            (tx_ptp_tstamp_valid_out),       // output

        .ctl_gb_seq_sync                    (ctl_gb_seq_sync       ),           // input
        .ctl_disable_bitslip                (ctl_disable_bitslip   ),           // input
        .ctl_correct_bitslip                (ctl_correct_bitslip   ),           // input
        .stat_bitslip_cnt                   (stat_bitslip_cnt      ),           // output
        .stat_bitslip_issued                (stat_bitslip_issued   ),           // output
        .stat_excessive_bitslip             (stat_excessive_bitslip),           // output
        .stat_bitslip_locked                (stat_bitslip_locked   ),           // output
        .stat_bitslip_busy                  (stat_bitslip_busy     ),           // output
        .stat_bitslip_done                  (stat_bitslip_done     ),           // output

        .gtf_ch_rxaxistvalid                (rx_axis_tvalid),                   // output
        .gtf_ch_rxaxistdata                 (rx_axis_tdata),                    // output [63:0]
        .gtf_ch_rxaxistlast                 (rx_axis_tlast),                    // output [7:0]
        .gtf_ch_rxaxistpre                  (rx_axis_tpre),                     // output [7:0]
        .gtf_ch_rxaxisterr                  (rx_axis_terr),                     // output
        .gtf_ch_rxaxistterm                 (rx_axis_tterm),                    // output [4:0]
        .gtf_ch_rxaxistsof                  (rx_axis_tsof)                      // output [1:0]
    );
    
//------------------------------------------------------------------------------
//
//    QSFP I2C Power
//
//    Enable QSFP power via a I2C FSM
//
//------------------------------------------------------------------------------

    qsfp_i2c_top i_qsfp_i2c_top (
        .s_axi_aclk(qsfp_i2c_clk),
        .s_axi_aresetn(locked),

        .FPGA_MUX0_RSTN(FPGA_MUX0_RSTN), 
        .FPGA_MUX1_RSTN(FPGA_MUX1_RSTN),
        .QSFPDD0_IO_RESET_B(QSFPDD0_IO_RESET_B), 
        .QSFPDD1_IO_RESET_B(QSFPDD1_IO_RESET_B), 
        .QSFPDD2_IO_RESET_B(QSFPDD2_IO_RESET_B), 
        .QSFPDD3_IO_RESET_B(QSFPDD3_IO_RESET_B),

        .FPGA_SDA_R(FPGA_SDA_R),
        .FPGA_SCL_R(FPGA_SCL_R)
    );

//------------------------------------------------------------------------------
//
//    ILA  
//
//------------------------------------------------------------------------------

// Delaying Tx and Rx ILA signals by 3 clock cyles to align them with the latency monitor signals


//  TX Related Signals...
logic  tx_axis_tvalid_ila;
logic  tx_axis_tvalid_ila_r [3:0];
assign tx_axis_tvalid_ila_r[0] = tx_axis_tvalid;
assign tx_axis_tvalid_ila      = tx_axis_tvalid_ila_r[3];

logic  tx_axis_tready_ila; 
logic  tx_axis_tready_ila_r [3:0];
assign tx_axis_tready_ila_r[0] = tx_axis_tready;
assign tx_axis_tready_ila      = tx_axis_tready_ila_r[3];

logic  [15:0] tx_axis_tdata_ila;
logic  [15:0] tx_axis_tdata_ila_r [3:0];
assign tx_axis_tdata_ila_r[0] = tx_axis_tdata;
assign tx_axis_tdata_ila      = tx_axis_tdata_ila_r[3];

logic  tx_axis_tcan_start_ila;
logic  tx_axis_tcan_start_ila_r [3:0];
assign tx_axis_tcan_start_ila_r[0] = tx_axis_tcan_start;
assign tx_axis_tcan_start_ila      = tx_axis_tcan_start_ila_r[3];

//  Unused TX Related Signals...
// --------------------------------------------------
//logic  [7:0] tx_axis_tlast_ila;
//logic  [7:0] tx_axis_tlast_ila_r [3:0];
//assign tx_axis_tlast_ila_r[0] = tx_axis_tlast;
//assign tx_axis_tlast_ila      = tx_axis_tlast_ila_r[3];
//
//logic  [7:0] tx_axis_tpre_ila;
//logic  [7:0] tx_axis_tpre_ila_r [3:0];
//assign tx_axis_tpre_ila_r[0] = tx_axis_tpre;
//assign tx_axis_tpre_ila      = tx_axis_tpre_ila_r[3];
//
//logic  tx_axis_terr_ila;
//logic  tx_axis_terr_ila_r [3:0];
//assign tx_axis_terr_ila_r[0] = tx_axis_terr;
//assign tx_axis_terr_ila      = tx_axis_terr_ila_r[3];
//
//logic  [4:0] tx_axis_tterm_ila;
//logic  [4:0] tx_axis_tterm_ila_r [3:0];
//assign tx_axis_tterm_ila_r[0] = tx_axis_tterm;
//assign tx_axis_tterm_ila      = tx_axis_tterm_ila_r[3];
//
//logic  [1:0] tx_axis_tsof_ila;
//logic  [1:0] tx_axis_tsof_ila_r [3:0];
//assign tx_axis_tsof_ila_r[0] = tx_axis_tsof;
//assign tx_axis_tsof_ila      = tx_axis_tsof_ila_r[3];


//  RX Related Signals...
logic rx_axis_tvalid_ila;
logic rx_axis_tvalid_ila_r [3:0];
assign rx_axis_tvalid_ila_r[0] = rx_axis_tvalid;
assign rx_axis_tvalid_ila      = rx_axis_tvalid_ila_r[3];

logic [15:0] rx_axis_tdata_ila;
logic [15:0] rx_axis_tdata_ila_r [3:0];
assign rx_axis_tdata_ila_r[0] = rx_axis_tdata;
assign rx_axis_tdata_ila      = rx_axis_tdata_ila_r[3];

logic  [1:0] rx_axis_tsof_ila;
logic  [1:0] rx_axis_tsof_ila_r [3:0];
assign rx_axis_tsof_ila_r[0] = rx_axis_tsof;
assign rx_axis_tsof_ila      = rx_axis_tsof_ila_r[3];


//  Unused RX Related Signals...
// --------------------------------------------------
//logic  [7:0] rx_axis_tlast_ila;
//logic [7:0] rx_axis_tlast_ila_r [3:0];
//assign rx_axis_tlast_ila_r[0] = rx_axis_tlast;
//assign rx_axis_tlast_ila      = rx_axis_tlast_ila_r[3];
//
//logic  [7:0] rx_axis_tpre_ila;
//logic  [7:0] rx_axis_tpre_ila_r [3:0];
//assign rx_axis_tpre_ila_r[0] = rx_axis_tpre;
//assign rx_axis_tpre_ila      = rx_axis_tpre_ila_r[3];
//
//logic  rx_axis_terr_ila;
//logic  rx_axis_terr_ila_r [3:0];
//assign rx_axis_terr_ila_r[0] = rx_axis_terr;
//assign rx_axis_terr_ila      = rx_axis_terr_ila_r[3];
//
//logic  [4:0] rx_axis_tterm_ila;
//logic  [4:0] rx_axis_tterm_ila_r [3:0];
//assign rx_axis_tterm_ila_r[0] = rx_axis_tterm;
//assign rx_axis_tterm_ila      = rx_axis_tterm_ila_r[3];


int ii;

always @(posedge tx_axis_clk) begin
    for (ii = 1 ; ii < 4; ii++) begin
        tx_axis_tvalid_ila_r[ii]     <= tx_axis_tvalid_ila_r[ii-1];
        tx_axis_tready_ila_r[ii]     <= tx_axis_tready_ila_r[ii-1];
        tx_axis_tdata_ila_r[ii]      <= tx_axis_tdata_ila_r[ii-1];
        tx_axis_tcan_start_ila_r[ii] <= tx_axis_tcan_start_ila_r[ii-1];

        //tx_axis_tlast_ila_r[ii]      <= tx_axis_tlast_ila_r[ii-1];
        //tx_axis_tpre_ila_r[ii]       <= tx_axis_tpre_ila_r[ii-1];
        //tx_axis_terr_ila_r[ii]       <= tx_axis_terr_ila_r[ii-1];
        //tx_axis_tterm_ila_r[ii]      <= tx_axis_tterm_ila_r[ii-1];
        //tx_axis_tsof_ila_r[ii]       <= tx_axis_tsof_ila_r[ii-1];
    end
end

always @(posedge rx_axis_clk) begin
    for (ii = 1 ; ii < 4; ii++) begin
        rx_axis_tvalid_ila_r[ii] <= rx_axis_tvalid_ila_r[ii-1];
        rx_axis_tdata_ila_r[ii]  <= rx_axis_tdata_ila_r[ii-1];
        rx_axis_tsof_ila_r[ii]   <= rx_axis_tsof_ila_r[ii-1];

        //rx_axis_tlast_ila_r[ii]  <= rx_axis_tlast_ila_r[ii-1];
        //rx_axis_tpre_ila_r[ii]   <= rx_axis_tpre_ila_r[ii-1];
        //rx_axis_terr_ila_r[ii]   <= rx_axis_terr_ila_r[ii-1];
        //rx_axis_tterm_ila_r[ii]  <= rx_axis_tterm_ila_r[ii-1];
    end
end

ila_0 gtfmac_ila_inst0 (
    .clk     ( rx_axis_clk                ),
    
    // Latency monitor ILA signals
    .probe0  ( lat_mon_sent_time_ila      ), // 16b
    .probe1  ( lat_mon_rcvd_time_ila      ), // 16b
    .probe2  ( lat_mon_delta_time_ila     ), // 16b
    .probe3  ( lat_mon_send_event_ila     ),
    .probe4  ( lat_mon_rcv_event_ila      ),
    .probe5  ( lat_mon_delta_time_idx_ila ), // 32b
    
    // TX AXI-Stream signals
    .probe6  ( tx_axis_tvalid_ila         ),
    .probe7  ( tx_axis_tready_ila         ),
    .probe8  ( tx_axis_tdata_ila          ), // 16b
    .probe9  ( tx_axis_tcan_start_ila     ),
    
    // RX AXI-Stream signals
    .probe10 ( rx_axis_tvalid_ila         ),
    .probe11 ( rx_axis_tdata_ila          ), // 16b
    .probe12 ( rx_axis_tsof_ila           )  // 2b

    // .probe13 ( tx_axis_tlast_ila         ), // 8b
    // .probe14 ( tx_axis_tpre_ila          ), // 8b
    // .probe15 ( tx_axis_terr_ila          ), 
    // .probe16 ( tx_axis_tterm_ila         ), // 5b
    // .probe17 ( tx_axis_tsof_ila          ), // 2b
                  
    // .probe18 ( rx_axis_tlast_ila         ), // 8b
    // .probe19 ( rx_axis_tpre_ila          ), // 8b
    // .probe20 ( rx_axis_terr_ila          ), 
    // .probe21 ( rx_axis_tterm_ila         )  // 5b
);

endmodule
