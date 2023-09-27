/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//******************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor             : Xilinx
// \   \   \/     Version            : 1.1
//  \   \         Application        : QDRIIP
//  /   /         Filename           : qdriip_v1_4_19_cal_r2f_sync.sv
// /___/   /\     Date Last Modified : $Date: 2015/01/22 $
// \   \  /  \    Date Created       : Thu Apr 18 2013
//  \___\/\___\
//
// Device           : UltraScale
// Design Name      : QDRII+ SRAM
// Purpose          :
//                   qdriip_v1_4_19_cal_r2f_sync module
// Reference        :
// Revision History :
//*****************************************************************************

`timescale 1ps/1ps

module qdriip_v1_4_19_cal_r2f_sync #(
    parameter     SYNC_MTBF   = 2
   ,parameter     TCQ         = 100
)(
    input                          div_clk
   ,input                          riu_clk_rst
   ,input                          riu_clk

   ,input [27:0] io_address_rclk
   ,input        io_addr_strobe_rclk
   ,input        io_write_strobe_rclk
   ,input [31:0] io_write_data_rclk
   ,input        bisc_complete_rclk
   ,input        vtc_complete_rclk
   ,input        riu_access

   ,(* dont_touch = "true" *) output reg        io_addr_strobe
   ,(* dont_touch = "true" *) output reg [27:0] io_address
   ,(* dont_touch = "true" *) output reg        io_write_strobe
   ,(* dont_touch = "true" *) output reg [31:0] io_write_data
   ,(* dont_touch = "true" *) output reg        bisc_complete
   ,(* dont_touch = "true" *) output reg        vtc_complete
);

  localparam INSERT_DELAY = 0; // Insert delay for simulations
  localparam HANDSHAKE_MAX_DELAY = 3000; // Fabric Clock Max frequency 333MHz
  localparam STATIC_MAX_DELAY = 10000; // Max delay for static signals

  reg  io_addr_strobe_rclk_lvl;
  wire io_addr_strobe_lvl;
  reg  io_addr_strobe_lvl_r1;
  reg  io_addr_strobe_lvl_r2;
  reg  io_write_strobe_rclk_lvl;
  reg  bisc_complete_rclk_in;
  reg  vtc_complete_rclk_in;

  // Pulse to Level conversion of addr_strobe in RIU clock domain
  always @(posedge riu_clk) begin
    if (riu_clk_rst)
      io_addr_strobe_rclk_lvl <= #TCQ 0;
    else if (io_addr_strobe_rclk & ~riu_access)
      io_addr_strobe_rclk_lvl <= #TCQ ~io_addr_strobe_rclk_lvl;
  end

  // Pulse to Level conversion of write_strobe in RIU clock domain
  always @(posedge riu_clk) begin
    if(io_addr_strobe_rclk)
      io_write_strobe_rclk_lvl <= #TCQ io_write_strobe_rclk;
  end

  // Sampling bisc_complete and vtc_complete signals before synchronization
  always @(posedge riu_clk) begin
      bisc_complete_rclk_in <= #TCQ bisc_complete_rclk;
      vtc_complete_rclk_in <= #TCQ vtc_complete_rclk;
  end

  // Synchronization logic
  qdriip_v1_4_19_sync #(SYNC_MTBF, 01, INSERT_DELAY, HANDSHAKE_MAX_DELAY, TCQ) u_addr_strobe_sync (div_clk, io_addr_strobe_rclk_lvl, io_addr_strobe_lvl);
  qdriip_v1_4_19_sync #(SYNC_MTBF, 28, INSERT_DELAY, HANDSHAKE_MAX_DELAY, TCQ) u_address_sync (div_clk, io_address_rclk, io_address);
  qdriip_v1_4_19_sync #(SYNC_MTBF, 01, INSERT_DELAY, HANDSHAKE_MAX_DELAY, TCQ) u_write_strobe_sync (div_clk, io_write_strobe_rclk_lvl, io_write_strobe);
  qdriip_v1_4_19_sync #(SYNC_MTBF, 32, INSERT_DELAY, HANDSHAKE_MAX_DELAY, TCQ) u_write_data_sync (div_clk, io_write_data_rclk, io_write_data);

  qdriip_v1_4_19_sync #(SYNC_MTBF, 01, INSERT_DELAY, STATIC_MAX_DELAY, TCQ) u_bisc_complete_sync (div_clk, bisc_complete_rclk_in, bisc_complete);
  qdriip_v1_4_19_sync #(SYNC_MTBF, 01, INSERT_DELAY, STATIC_MAX_DELAY, TCQ) u_vtc_complete_sync (div_clk, vtc_complete_rclk_in, vtc_complete);

  // Level to Pulse conversion of addr_strobe in Fabric clock domain
  always @(posedge div_clk) begin // PS
    io_addr_strobe_lvl_r1 <= #TCQ io_addr_strobe_lvl;
    io_addr_strobe_lvl_r2 <= #TCQ io_addr_strobe_lvl_r1;
    io_addr_strobe <= #TCQ io_addr_strobe_lvl_r1 ^ io_addr_strobe_lvl_r2;
  end

endmodule

