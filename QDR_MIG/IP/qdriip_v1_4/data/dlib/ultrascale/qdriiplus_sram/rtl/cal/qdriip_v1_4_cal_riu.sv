/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor                : Xilinx
// \   \   \/     Version               : 1.1
//  \   \         Application           : QDRIIP
//  /   /         Filename              : qdriip_v1_4_19_cal_riu.v
// /___/   /\     Date Last Modified    : $Date: 2015/02/17 $
// \   \  /  \    Date Created          : Thu Oct 24 2013
//  \___\/\___\
//
//Device            : Ultrascale 
//Design            : QDRII+ SRAM
//Purpose           :
//         Instantiates all modules required for the calibration such as 
//         Microblaze, cal_addr_decoder and config_rom. It also has the
//         XSDB debug interface.
//Reference         :
//Revision History  :
//*****************************************************************************

`timescale 1ps/1ps

module qdriip_v1_4_19_cal_riu #
(
    parameter TCQ				= 100
   ,parameter MCS_ECC_ENABLE        = "FALSE"
   ,parameter C_FAMILY                          = "kintexu"
)(
   // Clock and reset in RIU domain
    input  riu_clk
   ,input  riu_clk_rst

   // reset to microblaze
   ,input reset_ub_riuclk

   // Read data input from RIU interface
   ,input [31:0] riu2mcs_rd_data
   ,input        riu2mcs_valid

   // Read data input from fabric in RIU domain
   ,input [31:0] fab2mcs_rd_data
   ,input        fab2mcs_io_ready

   // MicroBlaze outputs
   ,(* dont_touch = "true" *) output reg        io_addr_strobe_rclk
   ,(* dont_touch = "true" *) output reg [31:0] io_address_rclk
   ,(* dont_touch = "true" *) output reg [31:0] io_write_data_rclk
   ,(* dont_touch = "true" *) output reg        io_write_strobe_rclk
   ,output LMB_UE //MCS Local Memory Uncorrectable Error
   ,output LMB_CE //MCS Local Memory Correctable Error

   // Misc inputs from fabric
   ,output reg ub_rst_out_rclk
   ,output riu_access
);

wire [31:0] io_address_ub;
wire        io_addr_strobe_ub;
wire        io_addr_strobe_ub_vld;
reg         io_addr_strobe_ub_hold;
wire [31:0] io_write_data_ub;
wire        io_write_strobe_ub;
wire [31:0] io_read_data_mux;
reg         io_addr_strobe_vld_rclk;
reg [31:0]  io_read_data_ub;
reg         io_ready_ub;
wire [31:0] Trace_PC;
reg         riu_rd_val;
reg         riu_rd_val_r;
reg         riu_rd_val_r1;
reg         riu_rd_val_r2;
reg         io_addr_strobe_rclk_int;
wire        mcs2pll_rst;

//#############################################################################

// Check the RIU and Fabric resets and hold the Microblaze transactions until they are released.
reg [15:0] fab_riu_rst_pipe;
wire fab_riu_rst = |fab_riu_rst_pipe;

always @(posedge riu_clk)
  fab_riu_rst_pipe <= #TCQ {fab_riu_rst_pipe, riu_clk_rst};
  //fab_riu_rst_pipe <= #TCQ {fab_riu_rst_pipe, (riu_clk_rst | fab_rst_sync)};

assign io_addr_strobe_ub_vld = fab_riu_rst ? 1'b0 : (io_addr_strobe_ub | io_addr_strobe_ub_hold);

always @(posedge riu_clk) begin
  if(reset_ub_riuclk)
    io_addr_strobe_ub_hold <= #TCQ 1'b0;
  else if(fab_riu_rst & io_addr_strobe_ub)
    io_addr_strobe_ub_hold <= #TCQ 1'b1;
  else if(~fab_riu_rst)
    io_addr_strobe_ub_hold <= #TCQ 1'b0;
end

always @(posedge riu_clk) begin
  if (reset_ub_riuclk) begin
    io_addr_strobe_rclk  <= #TCQ 1'b0;
    io_write_strobe_rclk <= #TCQ 1'b0;
  end else begin
    io_address_rclk <= #TCQ io_address_ub[29:2];
    io_addr_strobe_rclk <= #TCQ io_addr_strobe_ub_vld & ~mcs2pll_rst;
    io_addr_strobe_rclk_int <= #TCQ io_addr_strobe_ub;
    io_write_data_rclk <= #TCQ io_write_data_ub;
    io_write_strobe_rclk <= #TCQ io_write_strobe_ub;
  end
end

//always @(posedge riu_clk) begin // PS Level
//  if(io_addr_strobe_vld_rclk & ~riu_access & ~mcs2pll_rst)
//    io_addr_strobe_lvl_rclk <= #TCQ ~io_addr_strobe_lvl_rclk;
//end

// Special register to reset the cal logic except the uB!
assign mcs2pll_rst = (io_address_ub[29:2] == 28'h0020002);

always @(posedge riu_clk) begin
   if (reset_ub_riuclk)
     ub_rst_out_rclk <= #TCQ 1'b0;
   else if (io_addr_strobe_rclk_int && io_write_strobe_rclk && mcs2pll_rst)
     ub_rst_out_rclk <= #TCQ io_write_data_rclk[0];
end

assign riu_access = (io_address_rclk[12] | io_address_rclk[13] | 
                     io_address_rclk[14] | io_address_rclk[15] | 
                     io_address_rclk [16]) & 
                    ((~io_address_rclk[17]) & (~io_address_rclk[18]) &
                     (~io_address_rclk[19]) & (~io_address_rclk[20]) &
                     (~io_address_rclk[21]) & (~io_address_rclk[22]) &
                     (~io_address_rclk[23]));

//-----------------------------------------------------------------------------
// Microblaze MCS core instantiation
//-----------------------------------------------------------------------------
// For non-calibration simulation, Microblaze mcs static netlist will be used. 
// This part of code will be used only for non-calibration simulation.
// Don't add/remove the i/o ports or parameters from the SIMULATION section of 
// code, since it doe not affect the functionality.
//-----------------------------------------------------------------------------
  `ifndef ENABLE_MICROBLAZE_BFM
generate
  if (MCS_ECC_ENABLE == "FALSE") begin : generate_mcs_noecc
    // Microblaze MCS core
    //MCS V3.0 instance
    microblaze_mcs_0  mcs0 (
      .Clk                (riu_clk),
      .Reset              (reset_ub_riuclk),
      .IO_addr_strobe     (io_addr_strobe_ub),
      .IO_read_strobe     (),
      .IO_write_strobe    (io_write_strobe_ub),
      .IO_address         (io_address_ub),
      .IO_byte_enable     (),
      .IO_write_data      (io_write_data_ub),
      .IO_read_data       (io_read_data_ub),
      .IO_ready           (io_ready_ub),
      .TRACE_pc           (Trace_PC)
    );
    assign LMB_UE = 1'b0;
    assign LMB_CE = 1'b0;
  end else begin : generate_mcs_ecc
    // Microblaze MCS core
    //MCS V3.0 instance
    microblaze_mcs_0 mcs0 (
      .Clk                (riu_clk),
      .Reset              (reset_ub_riuclk),
      .LMB_UE             (LMB_UE),
      .LMB_CE             (LMB_CE),
      .IO_addr_strobe     (io_addr_strobe_ub),
      .IO_read_strobe     (),
      .IO_write_strobe    (io_write_strobe_ub),
      .IO_address         (io_address_ub),
      .IO_byte_enable     (),
      .IO_write_data      (io_write_data_ub),
      .IO_read_data       (io_read_data_ub),
      .IO_ready           (io_ready_ub),
      .TRACE_pc           (Trace_PC)
    );
    end
endgenerate

  `endif
//////////////////////
  assign io_read_data_mux = riu_access ? riu2mcs_rd_data : fab2mcs_rd_data;

  always @(posedge riu_clk) begin
    io_read_data_ub <= #TCQ io_read_data_mux;
  end

// wait until riu write finished
reg any_clb2riu_wr_wait;
integer n;
wire [4:0] riu_nibble;
reg [11:0] clb2riu_wr_en;

assign riu_nibble = io_address_rclk[10:6];
always @ (posedge riu_clk)
begin
  for (n = 0; n < 12; n = n + 1) begin: gen_riu_nibble_sel
    if (riu_clk_rst)
      clb2riu_wr_en[n] <= #TCQ 1'b0;
    else
      clb2riu_wr_en[n] <= #TCQ ((2*n == riu_nibble) | (2*n+1 == riu_nibble) ) & io_addr_strobe_rclk_int & io_write_strobe_rclk & riu_access;
  end
end

always @(posedge riu_clk) begin
   if (reset_ub_riuclk)
     any_clb2riu_wr_wait <= 0;
   else if (|clb2riu_wr_en)
     any_clb2riu_wr_wait <= 1;
   else if ((any_clb2riu_wr_wait && riu2mcs_valid) || io_ready_ub)
     any_clb2riu_wr_wait <= 0;
end

  always @ (posedge riu_clk) begin
    if (mcs2pll_rst) // Microblaze reset access
      io_ready_ub <= #TCQ io_addr_strobe_rclk_int;
    //else if (riu_access && any_clb2riu_wr_wait) // RIU Write
    //  io_ready_ub <= #TCQ riu2mcs_valid;
    //else if (riu_access) // RIU Read
    //  io_ready_ub <= #TCQ riu_rd_val_r1;
    else if (riu_access) // RIU access
      io_ready_ub <= #TCQ riu2mcs_valid;
    else
      io_ready_ub <= #TCQ fab2mcs_io_ready;
  end

  ////used for generation io ready for RIU read (data become valid after one clock of nibble sel)
  //always @ (posedge riu_clk) begin
  //  riu_rd_val <= #TCQ  io_addr_strobe_vld_rclk & ~io_write_strobe_rclk;
  //  riu_rd_val_r <= #TCQ  riu_rd_val;
  //  riu_rd_val_r1 <= #TCQ  riu_rd_val_r;
  //  riu_rd_val_r2 <= #TCQ  riu_rd_val_r1;
  //end

endmodule
