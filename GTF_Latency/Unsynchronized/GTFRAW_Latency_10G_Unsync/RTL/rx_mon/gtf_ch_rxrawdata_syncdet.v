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

module gtf_ch_rxrawdata_syncdet (
    input  wire        gtwiz_reset_rx_sync  ,
    input  wire        gtf_rxusrclk2_out    ,
    input  wire [31:0] gtf_ch_rxrawdata_in  ,
    output reg  [15:0] gtf_ch_rxrawdata_out ,
    output wire [15:0] gtf_ch_rxrawdata_samp,
    output reg         sync_det
);

wire [15:0] sync_pattern = 'h0080;

// Register rx data to form 32 bit signal... 
reg [15:0] gtf_ch_rxrawdata_d0;
reg [15:0] gtf_ch_rxrawdata_d1;
always@(posedge gtf_rxusrclk2_out)
begin
    if (gtwiz_reset_rx_sync) begin
        gtf_ch_rxrawdata_d0 <= 'h0;
        gtf_ch_rxrawdata_d1 <= 'h0;
    end else begin
        gtf_ch_rxrawdata_d0 <= gtf_ch_rxrawdata_in;
        gtf_ch_rxrawdata_d1 <= gtf_ch_rxrawdata_d0;
    end 
end

wire [31:0] gtf_ch_rxrawdata_32 = {gtf_ch_rxrawdata_d0, gtf_ch_rxrawdata_d1};

assign gtf_ch_rxrawdata_samp = gtf_ch_rxrawdata_d0[15:0];

// Look for sync pattern within 32 bit signal....
reg [15:0] bitslip_det;
always@(*)
begin
    bitslip_det[0]  = (sync_pattern == gtf_ch_rxrawdata_32[15+0 :0 ]);
    bitslip_det[1]  = (sync_pattern == gtf_ch_rxrawdata_32[15+1 :1 ]);
    bitslip_det[2]  = (sync_pattern == gtf_ch_rxrawdata_32[15+2 :2 ]);
    bitslip_det[3]  = (sync_pattern == gtf_ch_rxrawdata_32[15+3 :3 ]);
    bitslip_det[4]  = (sync_pattern == gtf_ch_rxrawdata_32[15+4 :4 ]);
    bitslip_det[5]  = (sync_pattern == gtf_ch_rxrawdata_32[15+5 :5 ]);
    bitslip_det[6]  = (sync_pattern == gtf_ch_rxrawdata_32[15+6 :6 ]);
    bitslip_det[7]  = (sync_pattern == gtf_ch_rxrawdata_32[15+7 :7 ]);
    bitslip_det[8]  = (sync_pattern == gtf_ch_rxrawdata_32[15+8 :8 ]);
    bitslip_det[9]  = (sync_pattern == gtf_ch_rxrawdata_32[15+9 :9 ]);
    bitslip_det[10] = (sync_pattern == gtf_ch_rxrawdata_32[15+10:10]);
    bitslip_det[11] = (sync_pattern == gtf_ch_rxrawdata_32[15+11:11]);
    bitslip_det[12] = (sync_pattern == gtf_ch_rxrawdata_32[15+12:12]);
    bitslip_det[13] = (sync_pattern == gtf_ch_rxrawdata_32[15+13:13]);
    bitslip_det[14] = (sync_pattern == gtf_ch_rxrawdata_32[15+14:14]);
    bitslip_det[15] = (sync_pattern == gtf_ch_rxrawdata_32[15+15:15]);
end

wire [15:0]  gtf_ch_rxrawdata_32_00 = gtf_ch_rxrawdata_32[15+0 :0 ];
wire [15:0]  gtf_ch_rxrawdata_32_01 = gtf_ch_rxrawdata_32[15+1 :1 ];
wire [15:0]  gtf_ch_rxrawdata_32_02 = gtf_ch_rxrawdata_32[15+2 :2 ];
wire [15:0]  gtf_ch_rxrawdata_32_03 = gtf_ch_rxrawdata_32[15+3 :3 ];
wire [15:0]  gtf_ch_rxrawdata_32_04 = gtf_ch_rxrawdata_32[15+4 :4 ];
wire [15:0]  gtf_ch_rxrawdata_32_05 = gtf_ch_rxrawdata_32[15+5 :5 ];
wire [15:0]  gtf_ch_rxrawdata_32_06 = gtf_ch_rxrawdata_32[15+6 :6 ];
wire [15:0]  gtf_ch_rxrawdata_32_07 = gtf_ch_rxrawdata_32[15+7 :7 ];
wire [15:0]  gtf_ch_rxrawdata_32_08 = gtf_ch_rxrawdata_32[15+8 :8 ];
wire [15:0]  gtf_ch_rxrawdata_32_09 = gtf_ch_rxrawdata_32[15+9 :9 ];
wire [15:0]  gtf_ch_rxrawdata_32_10 = gtf_ch_rxrawdata_32[15+10:10];
wire [15:0]  gtf_ch_rxrawdata_32_11 = gtf_ch_rxrawdata_32[15+11:11];
wire [15:0]  gtf_ch_rxrawdata_32_12 = gtf_ch_rxrawdata_32[15+12:12];
wire [15:0]  gtf_ch_rxrawdata_32_13 = gtf_ch_rxrawdata_32[15+13:13];
wire [15:0]  gtf_ch_rxrawdata_32_14 = gtf_ch_rxrawdata_32[15+14:14];
wire [15:0]  gtf_ch_rxrawdata_32_15 = gtf_ch_rxrawdata_32[15+15:15];


// Record the bitslip results....
reg [15:0] bitslip_det_r;
always@(posedge gtf_rxusrclk2_out)
begin
    if (gtwiz_reset_rx_sync) begin
        bitslip_det_r <= 'h0;
    end else begin
        bitslip_det_r <= bitslip_det;
    end 
end

// If one of the bits is set, then the pattern was found....
wire bitslip_det_r_or = |bitslip_det_r;

// Store the bitslip value to apply to future data.
reg [15:0] bitslip_det_r0;
always@(posedge gtf_rxusrclk2_out)
begin
    if (gtwiz_reset_rx_sync) begin
        bitslip_det_r0 <= 'h0;
    end else if (bitslip_det_r_or) begin
        bitslip_det_r0 <= bitslip_det_r;
    end 
end

// Declare sync detect if the pattern is found... 
always@(posedge gtf_rxusrclk2_out)
begin
    if (gtwiz_reset_rx_sync) begin
        sync_det <= 'h0;
    end else begin
        sync_det <= bitslip_det_r_or;
    end 
end

// Use the recorded bitslip value to align the data....
wire [15:0] gtf_ch_rxrawdata_mux = ( {16{bitslip_det_r0[0] }} & gtf_ch_rxrawdata_32[15+0 +0:0 +0]) | 
                                   ( {16{bitslip_det_r0[1] }} & gtf_ch_rxrawdata_32[15+1 +0:1 +0]) |
                                   ( {16{bitslip_det_r0[2] }} & gtf_ch_rxrawdata_32[15+2 +0:2 +0]) |
                                   ( {16{bitslip_det_r0[3] }} & gtf_ch_rxrawdata_32[15+3 +0:3 +0]) |
                                   ( {16{bitslip_det_r0[4] }} & gtf_ch_rxrawdata_32[15+4 +0:4 +0]) |
                                   ( {16{bitslip_det_r0[5] }} & gtf_ch_rxrawdata_32[15+5 +0:5 +0]) |
                                   ( {16{bitslip_det_r0[6] }} & gtf_ch_rxrawdata_32[15+6 +0:6 +0]) |
                                   ( {16{bitslip_det_r0[7] }} & gtf_ch_rxrawdata_32[15+7 +0:7 +0]) |
                                   ( {16{bitslip_det_r0[8] }} & gtf_ch_rxrawdata_32[15+8 +0:8 +0]) |
                                   ( {16{bitslip_det_r0[9] }} & gtf_ch_rxrawdata_32[15+9 +0:9 +0]) |
                                   ( {16{bitslip_det_r0[10]}} & gtf_ch_rxrawdata_32[15+10+0:10+0]) |
                                   ( {16{bitslip_det_r0[11]}} & gtf_ch_rxrawdata_32[15+11+0:11+0]) |
                                   ( {16{bitslip_det_r0[12]}} & gtf_ch_rxrawdata_32[15+12+0:12+0]) |
                                   ( {16{bitslip_det_r0[13]}} & gtf_ch_rxrawdata_32[15+13+0:13+0]) |
                                   ( {16{bitslip_det_r0[14]}} & gtf_ch_rxrawdata_32[15+14+0:14+0]) |
                                   ( {16{bitslip_det_r0[15]}} & gtf_ch_rxrawdata_32[15+15+0:15+0]) ;
//...register for clean timing...
reg [15:0] gtf_ch_rxrawdata_mux_r ;
always@(posedge gtf_rxusrclk2_out)
begin
    if (gtwiz_reset_rx_sync) begin
        gtf_ch_rxrawdata_mux_r <= 'h0;
        gtf_ch_rxrawdata_out   <= 'h0;
    end else begin
        gtf_ch_rxrawdata_mux_r <= gtf_ch_rxrawdata_mux;
        gtf_ch_rxrawdata_out   <= gtf_ch_rxrawdata_mux_r;
    end 
end


endmodule


