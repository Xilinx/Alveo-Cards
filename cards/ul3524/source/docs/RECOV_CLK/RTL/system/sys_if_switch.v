/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

module sys_if_switch (
    // System Interface
    input  wire        sys_if_wen      ,    
    input  wire [31:0] sys_if_addr     ,   
    output wire [31:0] sys_if_rdata    , 

    // Input clock to be sampled....
    output wire        sys_if_wen_0    ,     
    input  wire [31:0] sys_if_rdata_0  ,

    output wire        sys_if_wen_1    ,     
    input  wire [31:0] sys_if_rdata_1  ,

    output wire        sys_if_wen_2    ,     
    input  wire [31:0] sys_if_rdata_2  ,

    output wire        sys_if_wen_3    ,     
    input  wire [31:0] sys_if_rdata_3  ,

    output wire        sys_if_wen_4    ,     
    input  wire [31:0] sys_if_rdata_4  ,

    output wire        sys_if_wen_5    ,     
    input  wire [31:0] sys_if_rdata_5  ,

    output wire        sys_if_wen_6    ,     
    input  wire [31:0] sys_if_rdata_6  ,

    output wire        sys_if_wen_7    ,     
    input  wire [31:0] sys_if_rdata_7  
);


// ======================================================================
//  Signals to simplify code...
wire addr_sel_0 = ( sys_if_addr[31:16] == 'h0000 );
wire addr_sel_1 = ( sys_if_addr[31:16] == 'h0001 );
wire addr_sel_2 = ( sys_if_addr[31:16] == 'h0002 );
wire addr_sel_3 = ( sys_if_addr[31:16] == 'h0003 );
wire addr_sel_4 = ( sys_if_addr[31:16] == 'h0004 );
wire addr_sel_5 = ( sys_if_addr[31:16] == 'h0005 );
wire addr_sel_6 = ( sys_if_addr[31:16] == 'h0006 );
wire addr_sel_7 = ( sys_if_addr[31:16] == 'h0007 );


// ======================================================================
//  Filter write enables with proper addresses ranges...
assign sys_if_wen_0 = sys_if_wen && addr_sel_0;
assign sys_if_wen_1 = sys_if_wen && addr_sel_1;
assign sys_if_wen_2 = sys_if_wen && addr_sel_2;
assign sys_if_wen_3 = sys_if_wen && addr_sel_3;
assign sys_if_wen_4 = sys_if_wen && addr_sel_4;
assign sys_if_wen_5 = sys_if_wen && addr_sel_5;
assign sys_if_wen_6 = sys_if_wen && addr_sel_6;
assign sys_if_wen_7 = sys_if_wen && addr_sel_7;



// ======================================================================
//  Mux returned read data...

assign sys_if_rdata = ({32{addr_sel_0}} & sys_if_rdata_0) | 
                      ({32{addr_sel_1}} & sys_if_rdata_1) | 
                      ({32{addr_sel_2}} & sys_if_rdata_2) | 
                      ({32{addr_sel_3}} & sys_if_rdata_3) | 
                      ({32{addr_sel_4}} & sys_if_rdata_4) | 
                      ({32{addr_sel_5}} & sys_if_rdata_5) | 
                      ({32{addr_sel_6}} & sys_if_rdata_6) | 
                      ({32{addr_sel_7}} & sys_if_rdata_7) | 
                      32'h0;

endmodule









