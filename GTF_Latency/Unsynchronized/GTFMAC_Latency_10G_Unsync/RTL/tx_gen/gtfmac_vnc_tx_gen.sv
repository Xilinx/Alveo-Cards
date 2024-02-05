/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

module gtfmac_vnc_tx_gen (

    input       wire            axi_aclk,
    input       wire            axi_aresetn,

    // TX Generator Clock (TX User Clock)
    input       wire            gen_clk,
    input       wire            gen_rst,

    // TX User clock and reset
    input       wire            tx_clk,
    input       wire            tx_rst,

    // TX AXIS I/F to GTF and SOF marker to Latency Monitor
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

    input       wire            ctl_vnc_frm_gen_en,
    input       wire    [31:0]  ctl_num_frames,
    output      wire            ack_frm_gen_done,

    input       wire            ctl_vnc_frm_gen_mode,
    input       wire    [13:0]  ctl_vnc_max_len,
    input       wire    [13:0]  ctl_vnc_min_len,

    input       wire            ctl_tx_custom_preamble_en,
    input       wire    [63:0]  ctl_vnc_tx_custom_preamble,
    input       wire            ctl_tx_start_framing_enable,
    input       wire            ctl_tx_variable_ipg,

    input       wire            ctl_tx_fcs_ins_enable,
    input       wire            ctl_tx_data_rate,

    input       wire            ctl_vnc_tx_start_lat_run,
    output      wire            ack_vnc_tx_start_lat_run
);


// ##################################################################
//
//   Sync Logic From AXI Domain
//
// ##################################################################
    // Syn
    // -- Input signals sync'd to tx_clk domain

    wire frm_gen_en;
    gtfmac_vnc_syncer_level i_sync_ctl_frm_gen_en (
      .reset      (~gen_rst),
      .clk        (gen_clk),
      .datain     (ctl_vnc_frm_gen_en),
      .dataout    (frm_gen_en)
    );

    wire ctl_vnc_tx_start_lat_run_sync;
    gtfmac_vnc_syncer_level i_sync_ctl_vnc_tx_start_lat_run (
      .reset      (~gen_rst),
      .clk        (gen_clk),
      .datain     (ctl_vnc_tx_start_lat_run),
      .dataout    (ctl_vnc_tx_start_lat_run_sync)
    );

    wire frm_gen_en_tx;
    gtfmac_vnc_syncer_level i_sync_ctl_frm_gen_en_tx (
      .reset      (~tx_rst),
      .clk        (tx_clk),
      .datain     (ctl_vnc_frm_gen_en),
      .dataout    (frm_gen_en_tx)

    );

    wire ctl_vnc_tx_start_lat_run_sync_tx;
    gtfmac_vnc_syncer_level i_sync_ctl_vnc_tx_start_lat_run_tx (
      .reset      (~tx_rst),
      .clk        (tx_clk),
      .datain     (ctl_vnc_tx_start_lat_run),
      .dataout    (ctl_vnc_tx_start_lat_run_sync_tx)
    );


// ##################################################################
//
//   Sync Logic To AXI Domain
//
// ##################################################################

    wire frm_gen_done;
    gtfmac_vnc_syncer_pulse i_ack_ctl_frm_gen_done (
       .clkin        (gen_clk),
       .clkin_reset  (~gen_rst),
       .clkout       (axi_aclk),
       .clkout_reset (axi_aresetn),

       .pulsein      (frm_gen_done),
       .pulseout     ()//ack_frm_gen_done)
    );

    wire ack_tx_start_lat_run;
    gtfmac_vnc_syncer_pulse i_ack_vnc_tx_start_lat_run (
       .clkin        (gen_clk),
       .clkin_reset  (~gen_rst),
       .clkout       (axi_aclk),
       .clkout_reset (axi_aresetn),

       .pulsein      (ack_tx_start_lat_run),
       .pulseout     ()//ack_vnc_tx_start_lat_run)
    );

    wire frm_gen_done_tx;
    gtfmac_vnc_syncer_pulse i_ack_ctl_frm_gen_done_tx (
       .clkin        (tx_clk),
       .clkin_reset  (~tx_rst),
       .clkout       (axi_aclk),
       .clkout_reset (axi_aresetn),
 
       .pulsein      (frm_gen_done_tx),
       .pulseout     (ack_frm_gen_done)
    );
 
 
    wire ack_tx_start_lat_run_tx;
    gtfmac_vnc_syncer_pulse i_ack_vnc_tx_start_lat_run_tx (
       .clkin        (tx_clk),
       .clkin_reset  (~tx_rst),
       .clkout       (axi_aclk),
       .clkout_reset (axi_aresetn),
 
       .pulsein      (ack_tx_start_lat_run_tx),
       .pulseout     (ack_vnc_tx_start_lat_run)
    );


// ##################################################################
//
//   Data Generator...
//
// ##################################################################

wire                tx_credit;

// Frame bus to GTFMAC I/F module
wire                buf_ena;
wire                buf_pre;
wire                buf_sop;
wire    [63:0]      buf_data;
wire    [7:0]       buf_last;
wire                buf_err;


gtfmac_vnc_ra_buf_0 i_tx_gen_buf (
    .clk            ( tx_clk          ),
    .rst            ( tx_rst          ),

    .ctl_frm_gen_en ( frm_gen_en_tx   ),
    .frm_gen_done   ( frm_gen_done_tx ),

    .din_ena        ( buf_ena         ),
    .din_sop        ( buf_sop         ),
    .din_last       ( buf_last        ),             
    .din_pre        ( buf_pre         ),
    .din_err        ( buf_err         ),
    .din_data       ( buf_data        ),
    .tx_credit      ( tx_credit       ),

    //.ctl_max_len    ( 'h40 + 'h20 ), //ctl_vnc_max_len ),
    .ctl_max_len    ( 'h400           ), //ctl_vnc_max_len ),
    .ctl_num_frames ( ctl_num_frames  )
);

reg ack_tx_start_lat_run_0;
always@(posedge tx_clk)
begin
    if (tx_rst)
        ack_tx_start_lat_run_0 <= 'h0;
    else
        ack_tx_start_lat_run_0 <= ctl_vnc_tx_start_lat_run_sync_tx;
end
assign ack_tx_start_lat_run_tx = ack_tx_start_lat_run_0;


// ##################################################################
//
//   Frame Bus to AXIS I/F
//
// ##################################################################

    wire tx_buffer_overflow;


    gtfmac_vnc_tx_gtfmac_if  # (
        .AXI_IF_DEPTH   (8)
    )
    i_tx_gtfmac_if  (

        .tx_axis_clk                    (tx_clk),
        .tx_axis_rst                    (tx_rst),

        // Frame Bus from Rate Adapter
        .din_ena                        (buf_ena),
        .din_pre                        (buf_pre),
        .din_sop                        (buf_sop),
        .din_data                       (buf_data),
        .din_err                        (buf_err),
        .din_last                       (buf_last),
        .tx_credit                      (tx_credit),

        // Start of packet for Latency Measurement
        .tx_sop                         (tx_sop),                   // for latency measurement
    
        // Tx AXI-S bus to GTF
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

        // Unused....
        .tx_ptp_sop                     (tx_ptp_sop),               // input wire
        .tx_ptp_sop_pos                 (tx_ptp_sop_pos),           // input wire
        .tx_gb_seq_start                (tx_gb_seq_start),          // input wire
        .tx_gb_seq_sync                 (),                         // output  wire

        // Configuration...
        .ctl_tx_fcs_ins_enable          (ctl_tx_fcs_ins_enable),
        .ctl_tx_data_rate               (ctl_tx_data_rate),
        .ctl_tx_custom_preamble_en      (ctl_tx_custom_preamble_en),
        .ctl_tx_start_framing_enable    (ctl_tx_start_framing_enable),
        .ctl_tx_variable_ipg            (ctl_tx_variable_ipg),

        // Status....
        .tx_buffer_overflow             (tx_buffer_overflow)

    );


endmodule
