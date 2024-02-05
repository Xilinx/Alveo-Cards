/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------
//
//  Description: This is a simple automated I2C controller that does the bare 
//               minumum to power up the QSFP modules and initialize the QSFP 
//               sideband signal. It also includes a simple AXI interface to 
//               provide monitoring or control left up to the user's 
//               requirements.
//
//------------------------------------------------------------------------------

module gtfraw_vnc_rx_mon (

    // RX Monitor Clock (RX User Clock)
    input       wire            mon_clk,
    input       wire            mon_rst,

    // RX User clock and reset
    input       wire            rx_clk,
    input       wire            rx_rst,

    // Raw data from GTF sampled by 1 RX clock.... 
    input       wire [15:0]     gtf_ch_rxrawdata_align,
    input       wire            sync_error,
    
    // Aligned RX Raw Data from GTF...
    input       wire [15:0]     gtf_ch_rxrawdata,     
    output      wire            gtf_ch_rxrawdata_sof,

    // RX AXIS I/F from GTF and SOF marker to Latency Monitor
    input       wire            rx_axis_tvalid,
    input       wire [63:0]     rx_axis_tdata,
    input       wire [7:0]      rx_axis_tlast,
    input       wire [7:0]      rx_axis_tpre,
    input       wire            rx_axis_terr,
    input       wire [4:0]      rx_axis_tterm,
    input       wire [1:0]      rx_axis_tsof,
    output      wire            rx_start_measured_run,

    input       wire            ctl_vnc_mon_en,
    input       wire            ctl_rx_data_rate,
    input       wire            ctl_rx_packet_framing_enable,
    input       wire            ctl_rx_custom_preamble_en,
    input       wire    [63:0]  ctl_vnc_rx_custom_preamble,
    input       wire    [13:0]  ctl_vnc_max_len,
    input       wire    [13:0]  ctl_vnc_min_len,

    input       wire            stat_clk,
    input       wire            stat_rst,
    input       wire            stat_tick
    
);


    // Look for a sample with a single asserted bit preceeded by word with no bits set....
    wire  gtf_ch_rxrawdata_trig = sync_error;
    
    // Gate the pattern detection with the frame enable window...
    assign gtf_ch_rxrawdata_sof = ctl_vnc_mon_en ? {1'b0, sync_error} : 'h0;


    // The tick_r signal is used with the sim testbench...
    logic tick_r;
    always @(posedge rx_clk) begin
        if (rx_rst) 
            tick_r <= 'h0;
        else 
            tick_r <= gtf_ch_rxrawdata_sof; 
    end

    assign rx_start_measured_run = 'h0;

/*
    // In parallel to generating bit aligned data, check for sync trigger in which
    // a data sample of all 0's is followed by a data sample with a single asserted bit.
    // This only happens once as determined by the TX pattern generator BRAM contents. 

    // Register previous RX data...
    reg [15:0] gtf_ch_rxrawdata_r;
    always@(posedge rx_clk)
    begin
        gtf_ch_rxrawdata_r <= gtf_ch_rxrawdata_align;
    end
    
    // Look for a sample with a single asserted bit preceeded by word with no bits set....
    wire  gtf_ch_rxrawdata_trig = ( ( gtf_ch_rxrawdata_align == 'h8000) ||
                                    ( gtf_ch_rxrawdata_align == 'h4000) ||
                                    ( gtf_ch_rxrawdata_align == 'h2000) ||
                                    ( gtf_ch_rxrawdata_align == 'h1000) ||
                                    ( gtf_ch_rxrawdata_align == 'h0800) ||
                                    ( gtf_ch_rxrawdata_align == 'h0400) ||
                                    ( gtf_ch_rxrawdata_align == 'h0200) ||
                                    ( gtf_ch_rxrawdata_align == 'h0100) ||
                                    ( gtf_ch_rxrawdata_align == 'h0080) ||
                                    ( gtf_ch_rxrawdata_align == 'h0040) ||
                                    ( gtf_ch_rxrawdata_align == 'h0020) ||
                                    ( gtf_ch_rxrawdata_align == 'h0010) ||
                                    ( gtf_ch_rxrawdata_align == 'h0008) ||
                                    ( gtf_ch_rxrawdata_align == 'h0004) ||
                                    ( gtf_ch_rxrawdata_align == 'h0002) ||
                                    ( gtf_ch_rxrawdata_align == 'h0001) ) && (gtf_ch_rxrawdata_r == 'h0);
    
    // Gate the pattern detection with the frame enable window...
    assign gtf_ch_rxrawdata_sof = ctl_vnc_mon_en ? {1'b0, gtf_ch_rxrawdata_trig} : 'h0;


    // The tick_r signal is used with the sim testbench...
    logic tick_r;
    always @(posedge rx_clk) begin
        if (rx_rst) 
            tick_r <= 'h0;
        else 
            tick_r <= gtf_ch_rxrawdata_sof; 
    end

    assign rx_start_measured_run = 'h0;
*/

endmodule
