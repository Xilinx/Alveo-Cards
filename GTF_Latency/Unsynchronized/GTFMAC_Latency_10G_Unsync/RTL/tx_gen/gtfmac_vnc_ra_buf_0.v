/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

module gtfmac_vnc_ra_buf_0 (
    input  wire            clk            ,
    input  wire            rst            ,
    
    input  wire            ctl_frm_gen_en ,
    output reg             frm_gen_done   ,
    
    output wire            din_ena        ,
    output reg             din_sop        ,
    output reg  [7:0]      din_last       ,                                  
    output wire            din_pre        ,
    output wire            din_err        ,
    output wire [63:0]     din_data       ,
    input  wire            tx_credit      ,
    
    input  wire [13:0]     ctl_max_len    ,
    input  wire [31:0]     ctl_num_frames 

);


reg ctl_frm_gen_en_r;
always@(posedge clk)
begin
    if (rst)
        ctl_frm_gen_en_r <= 'h0;
    else
        ctl_frm_gen_en_r <= ctl_frm_gen_en;
end
wire frm_en_edge = ~ctl_frm_gen_en_r & ctl_frm_gen_en;

// ##########################################################

reg [7:0] credits;
always@(posedge clk)
begin
    if (rst)
        credits <= 'h0;
    else if ( !tx_credit &&  din_ena )
        credits <= credits + 1;
    else if (  tx_credit && !din_ena )
        credits <= credits - 1;
end

wire space_avail = (credits < 5);

// ##########################################################

wire last_frame;
wire wrd_next_last;

localparam ST_RST  = 'h0;
localparam ST_IDLE = 'h1;
localparam ST_SOP  = 'h2;
localparam ST_DATA = 'h3;
localparam ST_LAST = 'h4;
localparam ST_DONE = 'h5;

reg [3:0] cstate;
reg [3:0] nstate;

always@(posedge clk)
    if (rst)
        cstate <= ST_RST;
    else
        cstate <= nstate;

always@(*)
begin
    nstate = cstate;
    case (cstate)
        ST_RST  : nstate = ST_IDLE;
        ST_IDLE : if (frm_en_edge) nstate = ST_SOP;
        ST_SOP  : if(space_avail) nstate = ST_DATA;
        ST_DATA : if(space_avail && wrd_next_last) nstate = ST_LAST;
        ST_LAST : if(space_avail && last_frame) nstate = ST_DONE;
                  else if(space_avail && !last_frame) nstate = ST_SOP;
        ST_DONE : nstate = ST_IDLE;
    endcase
end

// ##########################################################

assign din_pre = 'h0;
assign din_err = 'h0;
    
assign din_ena = space_avail && 
                 ( (cstate == ST_SOP ) || 
                   (cstate == ST_DATA) || 
                   (cstate == ST_LAST) );

always@(posedge clk)
begin
    if (rst)
        din_sop <= 'h0;
    else
        din_sop <= (nstate == ST_SOP);
end

always@(posedge clk)
begin
    if (rst)
        din_last <= 'h0;
    else
        din_last <= (nstate == ST_LAST) ? 'h20 : 'h00;
end


reg [15:0] wrd_count;
always@(posedge clk)
begin
    if (rst)
        wrd_count <= 'h0;
    else if ( cstate == ST_IDLE )
        wrd_count <= 'h1;
    else if ( cstate == ST_SOP)
        wrd_count <= 'h1;
    else if ( space_avail )
        wrd_count <= wrd_count + 1;
end

wire [13:0] ctl_max_len_0 =  {3'h00, ctl_max_len[13:3] } - 1;
assign wrd_next_last = (wrd_count == (ctl_max_len_0 - 1));

// ------------------------------------------
//
//reg  [15:0] frm_count;
//wire [15:0] frm_count_plus_1 = frm_count + 1;
//always@(posedge clk)
//begin
//    if (rst)
//        frm_count <= 'h0;
//    else if ( nstate == ST_IDLE )
//        frm_count <= 'h0;
//    else if ( (cstate == ST_DATA) && (nstate == ST_LAST) )
//        frm_count <= frm_count_plus_1;
//end
//
//assign last_frame = (frm_count == ctl_num_frames);
//
// ------------------------------------------

reg  [31:0] frm_count;
wire [31:0] frm_count_plus_1 = frm_count + 1;
always@(posedge clk)
begin
    if (rst)
        frm_count <= 'h1;
    else if ( nstate == ST_IDLE )
        frm_count <= 'h1;
    else if ( (cstate == ST_LAST) && (nstate == ST_SOP) )
        frm_count <= frm_count_plus_1;
end

reg r_last_frame;
always@(posedge clk)
begin
    if (rst)
        r_last_frame <= 'h0;
    else
        r_last_frame <= (frm_count == ctl_num_frames);
end
assign last_frame = r_last_frame;

// ------------------------------------------

always@(posedge clk)
begin
    if (rst)
        frm_gen_done <= 'h0;
    else
        frm_gen_done <= (nstate == ST_DONE);
end


// ##########################################################

wire data_en =  (( cstate == ST_SOP  ) ||
                 ( cstate == ST_DATA ) ||
                 ( cstate == ST_LAST ) ) && space_avail;


gtfmac_vnc_prbs_gen_64_0 gtfmac_vnc_prbs_gen_64_0 (
    .rst      ( rst      ),
    .clk      ( clk      ),
    .en       ( data_en  ),
    .prbs_out ( din_data )
);

endmodule


