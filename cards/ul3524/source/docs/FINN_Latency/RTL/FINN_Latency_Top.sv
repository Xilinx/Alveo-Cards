/*
Copyright (C) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/16/2023 02:06:14 PM
// Design Name: 
// Module Name: FINNLatencyTop
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FINN_Latency_Top
#(parameter SIM = 0)


(
    input wire clk,
    input wire clkn,
    // input wire rst,
    
    
    output reg [7 : 0]  m_axis_0_tdata_r1,  
    // input wire          m_axis_0_tready,          
    output reg          m_axis_0_tvalid_r1 
          
    // input wire [63 : 0] s_axis_0_tdata,  
    // output reg          s_axis_0_tready_r1,         
    // input wire          s_axis_0_tvalid               
    
    );
    
    
 // reg [63:0] s_axis_0_tdata_r1;
 // reg        s_axis_0_tvalid_r1;
 
 //   reg [7:0]  m_axis_0_tdata_r1;
    reg [7:0]  m_axis_0_tdata;
    // reg        m_axis_0_tready_r1;
 
    
// clocking
    wire iclk;
    wire sys_clk;
    wire locked;

IBUFDS ibufds_clk_freerun_inst (
  .I  ( clk ),
  .IB ( clkn ),
  .O  ( iclk   )
);

//----------------------------------------------------------------------------
//  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
//   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
//----------------------------------------------------------------------------
// clk_out1__320.00000______0.000______50.0_______80.786_____77.836
//
//----------------------------------------------------------------------------
// Input Clock   Freq (MHz)    Input Jitter (UI)
//----------------------------------------------------------------------------
// __primary_____________300____________0.010

  clk_wiz_0 clk_generator
   (
    // Clock out ports
    .clk_out1(sys_clk),     // output clk_out1
    // Status and control signals
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(iclk)      // input clk_in1
);

syncer_reset syncer_reset_322
(
    .clk          ( sys_clk ),
    .resetn_async ( locked  ),
    .resetn       ( sys_rst )
);

// stimulus generation

wire    [63:0]  stimulus_out;
reg     [63:0]  stimulus_out_reg;
wire            tvalid_out;
reg             tvalid_out_reg;
wire            tready_from_finn;

stimulus i_stimulus
(   
    .clk                (sys_clk),
    .rst                (sys_rst),
    .stimulus_out       (stimulus_out),
    .tvalid_out         (tvalid_out)
);
      
always @(posedge sys_clk) begin
    m_axis_0_tdata_r1   <= m_axis_0_tdata;
    m_axis_0_tvalid_r1  <= m_axis_0_tvalid;
    // s_axis_0_tdata_r1   <= s_axis_0_tdata;
    // s_axis_0_tvalid_r1  <= s_axis_0_tvalid;
    
    // m_axis_0_tready_r1  <= m_axis_0_tready;
    // s_axis_0_tready_r1  <= s_axis_0_tready;
    stimulus_out_reg    <= stimulus_out;
    tvalid_out_reg      <= tvalid_out;
 end 
  
finn_design_0 my_finn_design_0 (
  .ap_clk(sys_clk),                         // input wire ap_clk
  .ap_rst_n(sys_rst),                       // input wire ap_rst_n
  
  .m_axis_0_tdata   (m_axis_0_tdata),       // output wire [7 : 0] m_axis_0_tdata
  .m_axis_0_tready  (1'b1),                 // input wire m_axis_0_tready
  .m_axis_0_tvalid  (m_axis_0_tvalid),      // output wire m_axis_0_tvalid
  
  .s_axis_0_tdata   (stimulus_out_reg),     // input wire [63 : 0] s_axis_0_tdata
  .s_axis_0_tready  (tready_from_finn),     // output wire s_axis_0_tready
  .s_axis_0_tvalid  (tvalid_out_reg)        // input wire s_axis_0_tvalid
);    

ila_0 i_ila_0 (
	.clk(sys_clk), // input wire clk


	.probe0(stimulus_out_reg), // input wire [63:0]  probe0  
	.probe1(tvalid_out_reg), // input wire [0:0]  probe1 
	.probe2(tready_from_finn), // input wire [0:0]  probe2 
	.probe3(m_axis_0_tdata), // input wire [7:0]  probe3 
	.probe4(m_axis_0_tvalid) // input wire [0:0]  probe4
);  
      
endmodule

module syncer_reset
#(
  parameter RESET_PIPE_LEN = 3
 )
(
  input  wire clk,
  input  wire resetn_async,
  output wire resetn
);

  (* ASYNC_REG = "TRUE" *) reg  [RESET_PIPE_LEN-1:0] resetn_pipe_retime;
  reg  resetn_pipe_out;

// synthesis translate_off

  initial resetn_pipe_retime  = {RESET_PIPE_LEN{1'b0}};
  initial resetn_pipe_out     = 1'b0;

// synthesis translate_on

  always @(posedge clk or negedge resetn_async)
    begin
      if (resetn_async == 1'b0)
        begin
          resetn_pipe_retime <= {RESET_PIPE_LEN{1'b0}};
          resetn_pipe_out    <= 1'b0;
        end
      else
        begin
          resetn_pipe_retime <= {resetn_pipe_retime[RESET_PIPE_LEN-2:0], 1'b1};
          resetn_pipe_out    <= resetn_pipe_retime[RESET_PIPE_LEN-1];
        end
    end

  assign resetn = resetn_pipe_out;

endmodule

// stimulus generator module

module stimulus

(
    input wire clk,
    input wire rst,
    output wire [63:0] stimulus_out,
    output wire tvalid_out
);

reg [6:0] stim_count;
reg [63:0] stim_value;
reg         tvalid;

assign tvalid_out   = tvalid;
assign stimulus_out = stim_value;

// 64 bit counter

always @(posedge clk) begin
    if (rst == 1'b0) begin
            stim_count <= 7'h0;
        end
        else begin
            stim_count <= stim_count + 1'b1;
        end
    end
    
 // stimulus
 
 always @(posedge clk) begin
    if (rst == 1'b0) begin
            stim_value  <= 63'h0;
            tvalid      <= 1'b0;
        end
        else if ((stim_count >= 7'd20) & (stim_count < 7'd30)) begin
            stim_value  <= 64'hABCDABCDEFABCDEF;
            tvalid      <= 1'b1;
        end
        else if ((stim_count >= 7'd84) & (stim_count < 7'd94)) begin
            stim_value  <= 64'h0;
            tvalid      <= 1'b1;
        end
        else begin
            stim_value  <= 64'h0;
            tvalid      <= 1'b0;
        end
    end
    
 endmodule
            

