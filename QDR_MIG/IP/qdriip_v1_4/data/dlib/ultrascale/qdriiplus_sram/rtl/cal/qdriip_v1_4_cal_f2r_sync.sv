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
//  /   /         Filename           : qdriip_v1_4_19_cal_f2r_sync.sv
// /___/   /\     Date Last Modified : $Date: 2015/01/22 $
// \   \  /  \    Date Created       : Thu Apr 18 2013
//  \___\/\___\
//
// Device           : UltraScale
// Design Name      : QDRII+ SRAM
// Purpose          :
//                   qdriip_v1_4_19_cal_f2r_sync module
// Reference        :
// Revision History :
//*****************************************************************************

`timescale 1ps/1ps

module qdriip_v1_4_19_cal_f2r_sync #(
    parameter  SYNC_MTBF   = 2
   ,parameter  TCQ         = 100
)(
    input riu_clk
   ,input div_clk
   ,input div_clk_rst

   ,input        en_vtc
   ,input        io_ready
   ,input [31:0] io_read_data

   ,(* dont_touch = "true" *) output reg        en_vtc_rclk
   ,(* dont_touch = "true" *) output reg        io_ready_rclk
   ,(* dont_touch = "true" *) output reg [31:0] io_read_data_rclk
);

  localparam INSERT_DELAY = 0; // Insert delay for simulations
  localparam HANDSHAKE_MAX_DELAY = 5000; // RIU Clock Max frequency 200MHz
  localparam STATIC_MAX_DELAY = 10000; // Max delay for static signals

  reg io_ready_lvl;
  reg [31:0] io_read_data_samp;
  reg io_ready_rclk_lvl_r1;
  reg io_ready_rclk_lvl_r2;
  reg en_vtc_samp;
  wire io_ready_rclk_lvl;

  // Pulse to Level conversion of io_ready in Fabric clock domain
  always @(posedge div_clk) begin // PS Level
    if (div_clk_rst)
      io_ready_lvl <= #TCQ 0;
    else if(io_ready)
      io_ready_lvl <= #TCQ ~io_ready_lvl;
  end

  // Sampling the io_read_data to make it stable for an entire transaction
  always @(posedge div_clk) begin
    if (io_ready)
      io_read_data_samp <= #TCQ io_read_data;
  end

  // Sampling en_vtc before synchronization
  always @(posedge div_clk) begin
      en_vtc_samp <= #TCQ en_vtc;
  end

  // Synchronization logic
  qdriip_v1_4_19_sync #(SYNC_MTBF, 01, INSERT_DELAY, STATIC_MAX_DELAY, TCQ) u_en_vtc_sync (riu_clk, en_vtc_samp, en_vtc_rclk);
  qdriip_v1_4_19_sync #(SYNC_MTBF, 01, INSERT_DELAY, HANDSHAKE_MAX_DELAY, TCQ) u_io_ready_sync (riu_clk, io_ready_lvl, io_ready_rclk_lvl);
  qdriip_v1_4_19_sync #(SYNC_MTBF, 32, INSERT_DELAY, HANDSHAKE_MAX_DELAY, TCQ) u_io_read_data_sync (riu_clk, io_read_data_samp, io_read_data_rclk);

  // Level to Pulse conversion of io_ready in RIU clock domain
  always @(posedge riu_clk) begin // PS
    io_ready_rclk_lvl_r1  <= #TCQ io_ready_rclk_lvl;
    io_ready_rclk_lvl_r2  <= #TCQ io_ready_rclk_lvl_r1;
    io_ready_rclk  <= #TCQ io_ready_rclk_lvl_r1 ^ io_ready_rclk_lvl_r2;
  end

endmodule

