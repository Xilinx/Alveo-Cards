/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

module bitslip_raw (
    input   wire        clk                    ,
    input   wire        rstn                   ,
    input   wire [15:0] gtf_ch_rxrawdata       ,
    output  wire [15:0] gtf_ch_rxrawdata_samp  ,
    output  wire [15:0] gtf_ch_rxrawdata_align ,
    output  wire [7:0]  bitslip_value          ,
    output  wire        locked                 ,
    output  wire        error                  ,
    input   wire        en
);

// ---------------------------------------

wire      timer_eq_0;
wire      prbs_locked;
reg [7:0] bs_count;

// ---------------------------------------

localparam ST_RST   = 'h00;
localparam ST_START = 'h01;
localparam ST_DELAY = 'h02;
localparam ST_CHECK = 'h03;
localparam ST_INCR  = 'h04;
localparam ST_FAIL  = 'h05;
localparam ST_PASS  = 'h06;



reg [7:0] cstate;
reg [7:0] nstate;

always@(posedge clk)
begin
    if (!rstn) cstate <= ST_RST;
    else       cstate <= nstate;
end

always@(*)
begin
    nstate = cstate;
    case (cstate)
        ST_RST   : if (en == 1) nstate = ST_START;
        ST_START : nstate = ST_DELAY;
        ST_DELAY : if (timer_eq_0) nstate = ST_CHECK;
        ST_CHECK : if (prbs_locked) nstate = ST_PASS;
                   else nstate = ST_INCR;
        ST_INCR  : if (bs_count == 16) nstate = ST_FAIL;
                   else nstate = ST_START;
        ST_FAIL  : nstate = ST_RST;
        ST_PASS  : if (prbs_locked) nstate = ST_PASS;
                   else nstate = ST_RST;
    endcase
end

// ---------------------------------------

reg [7:0] timer;
always@(posedge clk)
begin
    if (!rstn)
        timer <= 'h0;
    else if (nstate == ST_START)
        timer <= 'h20;
    else if (timer == 0)
        timer <= 'h0;
    else
        timer <= timer - 1;
end

assign timer_eq_0 = (timer == 'h0);

// ---------------------------------------

always@(posedge clk)
begin
    if (!rstn)
        bs_count <= 'h0;
    else if (nstate == ST_RST)
        bs_count <= 'h0;
    else if (nstate == ST_INCR)
        bs_count <= bs_count + 1;
end

// ---------------------------------------

reg [31:0] data_32b;

always@(posedge clk)
    data_32b <= {gtf_ch_rxrawdata, data_32b[31:16]};

// ---------------------------------------

reg [15:0] data_sft;
always@(posedge clk)
begin
  data_sft <= ({16{bs_count ==  0}} & data_32b[31- 0:16- 0]) |
              ({16{bs_count ==  1}} & data_32b[31- 1:16- 1]) |
              ({16{bs_count ==  2}} & data_32b[31- 2:16- 2]) |
              ({16{bs_count ==  3}} & data_32b[31- 3:16- 3]) |
              ({16{bs_count ==  4}} & data_32b[31- 4:16- 4]) |
              ({16{bs_count ==  5}} & data_32b[31- 5:16- 5]) |
              ({16{bs_count ==  6}} & data_32b[31- 6:16- 6]) |
              ({16{bs_count ==  7}} & data_32b[31- 7:16- 7]) |
              ({16{bs_count ==  8}} & data_32b[31- 8:16- 8]) |
              ({16{bs_count ==  9}} & data_32b[31- 9:16- 9]) |
              ({16{bs_count == 10}} & data_32b[31-10:16-10]) |
              ({16{bs_count == 11}} & data_32b[31-11:16-11]) |
              ({16{bs_count == 12}} & data_32b[31-12:16-12]) |
              ({16{bs_count == 13}} & data_32b[31-13:16-13]) |
              ({16{bs_count == 14}} & data_32b[31-14:16-14]) |
              ({16{bs_count == 15}} & data_32b[31-15:16-15]) |
              ({16{bs_count == 16}} & data_32b[31-16:16-16]) |
              'h0;
end

reg [15:0] data_sft2;
always@(posedge clk)
begin
    data_sft2 <= data_sft;
end

// ---------------------------------------

reg [15:0] next_prbs;
always@(posedge clk)
begin
    next_prbs <= { data_sft2[14:0], 
                   data_sft2[15] ^ data_sft2[14] ^ data_sft2[12] ^ data_sft2[3] };
end

reg [3:0] prbs_good;
always@(posedge clk)
begin
    prbs_good <= {prbs_good[2:0], (next_prbs == data_sft2)};
end

assign error = prbs_good[0] & (next_prbs != data_sft2);

reg [7:0] prbs_good_count;
always@(posedge clk)
begin
    if (nstate == ST_START)
        prbs_good_count <= 'h0;
    else if ( |prbs_good && (prbs_good_count == 8))
        prbs_good_count <= 'h8;
    else if ( |prbs_good )
        prbs_good_count <= prbs_good_count + 1;
    else
        prbs_good_count <= 'h0;
end

assign prbs_locked = (prbs_good_count > 7);


// ---------------------------------------

assign gtf_ch_rxrawdata_samp   = data_32b[31:15];
assign gtf_ch_rxrawdata_align  = data_sft2[15:0];
assign locked = (cstate == ST_PASS) && (gtf_ch_rxrawdata_align != 'h0000);
assign bitslip_value = bs_count;

endmodule


 
 
 