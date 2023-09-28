/*
Copyright (C) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`timescale 1ns / 1ps  

module FINN_Latency_Top_TB;

reg clk;
// reg clkn;
// reg rst = 1'b0;;

// reg m_axis_0_tready;
// reg [63:0] s_axis_0_tdata;
// reg s_axis_0_tvalid;

// reg [7:0] m_axis_0_tdata_r1;

parameter PERIOD = 3.3333;

// initial begin
//     clk = 1'b0;
//     clkn = 1'b1;
//     // rst = 1'b1;
//     // #(PERIOD*10);
//     // rst = 1'b0;
//     // #(PERIOD*10);
//     // rst = 1'b1;
// end

/*initial begin
    m_axis_0_tready = 1'b1;
    s_axis_0_tdata = 64'h0;
    s_axis_0_tvalid = 1'b0;
    
    #(PERIOD*100);
    
    m_axis_0_tready = 1'b1;
    s_axis_0_tdata = 64'hDEADBEEFDEADBEEF;
    s_axis_0_tvalid = 1'b1;
    
    #(PERIOD*10);
       
    m_axis_0_tready = 1'b1;
    s_axis_0_tdata = 64'h0;
    s_axis_0_tvalid = 1'b0;   
    
    #(PERIOD*30);
    
    m_axis_0_tready = 1'b1;
    s_axis_0_tdata = 64'hDEADBEEFDEADBEEF;
    s_axis_0_tvalid = 1'b1;  
    
    #(PERIOD*10);
    
    m_axis_0_tready = 1'b1;
    s_axis_0_tdata = 64'h0;
    s_axis_0_tvalid = 1'b0;  
    
    #(PERIOD*30);
    
    m_axis_0_tready = 1'b1;
    s_axis_0_tdata = 64'hDEADBEEFDEADBEEF;
    s_axis_0_tvalid = 1'b1;
    
    #(PERIOD*10);
    
    m_axis_0_tready = 1'b1;
    s_axis_0_tdata = 64'h0;
    s_axis_0_tvalid = 1'b0;  
    
    #(PERIOD*30);
    
    m_axis_0_tready = 1'b1;
    s_axis_0_tdata = 64'hDEADBEEFDEADBEEF;
    s_axis_0_tvalid = 1'b1;
    
    #(PERIOD*10);
    
    m_axis_0_tready = 1'b1;
    s_axis_0_tdata = 64'h0;
    s_axis_0_tvalid = 1'b0;            
end */

always begin
    clk = 1'b0;
    // clkn = 1'b1;
    #(PERIOD/2);
    clk = 1'b1;
    // clkn = 1'b0;
    #(PERIOD/2);
end

FINN_Latency_Top i_FINN_Latency_Top(
    .clk(clk),                                  // input wire    
    .clkn(~clk));      
    // .rst(rst),                                  // input wire          
                                       
                                       
    // .m_axis_0_tdata_r1(m_axis_0_tdata_r1),      // output reg [7 : 0]  
    // .m_axis_0_tready(1'b1),          // input wire          
    // .m_axis_0_tvalid_r1(m_axis_0_tvalid_r1));   // output reg          
                                                 
    // .s_axis_0_tdata(s_axis_0_tdata),            // input wire [63 : 0] 
    // .s_axis_0_tready_r1(s_axis_0_tready_r1),    // output reg          
    // .s_axis_0_tvalid(s_axis_0_tvalid));         // input wire          
    
endmodule
