/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

******************************************************************************/
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor             : Xilinx
// \   \   \/     Version            : 1.1
//  \   \         Application        : QDRIIP
//  /   /         Filename           : qdriip_v1_4_19_hw_tg.sv
// /___/   /\     Date Last Modified : $Date: 2014/09/03 $
// \   \  /  \    Date Created       : Thu May 22 2014
//  \___\/\___\
//
// Device           : UltraScale
// Design Name      : Traffic Generator
// Purpose          : 
// This is Traffic Generator Arbiter.
// It is only activated in some of the tg_rw_submode.
// When activated,
//    - tg core acts like a dual port (one read only, one write only) machine
//    - arbiter block arbitrates between Write and Read requests.
//    - arbiter block translates dual port (one read only, one write only) back to single shared write/read port
// Reference        :
// Revision History :
//*****************************************************************************

`timescale 1ps / 1ps

module qdriip_v1_4_19_tg_arbiter #(
  parameter TCQ              = 100,
  parameter MEM_ARCH         = "ULTRASCALE", // Memory Architecture: ULTRASCALE, 7SERIES
  parameter MEM_TYPE         = "DDR3", // DDR3, DDR4, RLD2, RLD3, QDRIIP, QDRIV
  parameter APP_DATA_WIDTH   = 32,        // DDR data bus width.
  parameter APP_ADDR_WIDTH   = 32,        // Address bus width of the 
  parameter APP_CMD_WIDTH    = 3,
  parameter DM_WIDTH = (MEM_TYPE == "RLD3" || MEM_TYPE == "RLD2") ? 18 : 8
 )
   (
   input 				      clk, // memory controller (MC) user interface (UI) clock
   input 				      rst, // MC UI reset signal.
   input 				      init_calib_complete_r,
   input [1:0] 				      tg_rw_submode,
    
    // TG to APP direction
   input 				      tg1_rdy,
   input 				      tg1_wdf_rdy,
   output reg [APP_CMD_WIDTH-1:0] 	      tg1_cmd,
   output reg [APP_ADDR_WIDTH-1:0] 	      tg1_addr,
   output reg 				      tg1_en,
   output reg [(APP_DATA_WIDTH/DM_WIDTH)-1:0] tg1_wdf_mask, 
   output reg [APP_DATA_WIDTH-1: 0] 	      tg1_wdf_data,
   output reg 				      tg1_wdf_end,
   output reg 				      tg1_wdf_wren,

   output reg 				      tg1_wdf_en,
   output reg [APP_ADDR_WIDTH-1:0] 	      tg1_wdf_addr,
   output reg [APP_CMD_WIDTH-1:0] 	      tg1_wdf_cmd,
    
    // APP to TG direction
   output reg 				      tg0_rdy,
   output reg 				      tg0_wdf_rdy,
   input [APP_CMD_WIDTH-1:0] 		      tg0_cmd,
   input [APP_ADDR_WIDTH-1:0] 		      tg0_addr,
   input 				      tg0_en,
   input [(APP_DATA_WIDTH/DM_WIDTH)-1:0]      tg0_wdf_mask, 
   input [APP_DATA_WIDTH-1: 0] 		      tg0_wdf_data,
   input 				      tg0_wdf_end,
   input 				      tg0_wdf_wren,

   input 				      tg0_wdf_en,
   input [APP_ADDR_WIDTH-1:0] 		      tg0_wdf_addr,
   input [APP_CMD_WIDTH-1:0] 		      tg0_wdf_cmd
    );

   // DDR3/4 Read/Write submode
   localparam TG_RW_SUBMODE_DDR_W_R               = 2'b00; // Write follows by Read
   localparam TG_RW_SUBMODE_DDR_W_R_SIMU          = 2'b01; // Write and Read in parallel

   localparam TG_RW_SELECT_WRITE                  = 1'b1;
   localparam TG_RW_SELECT_READ                   = 1'b0;

   reg [31:0] 				      tg_arbiter;
   wire 				      tg_rw_select;
   wire 				      tg_wren_rdy;
   wire 				      tg_rden_rdy;
   wire 				      tg_wren;
   wire 				      tg_rden;
   
   always @(posedge clk) begin
      if (rst) begin
	 tg_arbiter <= #TCQ 'h1;
      end
      else if (init_calib_complete_r) begin
	 // lfsr Tap 32, 22, 2, 1
	 tg_arbiter <= #TCQ {tg_arbiter[30:0],
			     tg_arbiter[32-1]^tg_arbiter[22-1]^tg_arbiter[2-1]^tg_arbiter[1-1]};
      end
   end

   assign tg_rw_select = tg_arbiter[0];
   assign tg_wr_rdy   = (tg_rw_select==TG_RW_SELECT_WRITE) && tg1_rdy && tg1_wdf_rdy;
   assign tg_rd_rdy   = (tg_rw_select==TG_RW_SELECT_READ)  && tg1_rdy;
   assign tg_wren     = tg0_wdf_en && tg_wr_rdy;
   assign tg_rden     = tg0_en     && tg_rd_rdy;
   
   always @(*) begin
      if ((MEM_TYPE != "QDRIIP" && MEM_TYPE != "QDRIV") && (tg_rw_submode == TG_RW_SUBMODE_DDR_W_R_SIMU)) begin
	 tg0_rdy          = tg_rd_rdy;
	 tg0_wdf_rdy      = tg_wr_rdy;

	 tg1_en           = tg_wren || tg_rden;
	 tg1_cmd          = (tg_rw_select==TG_RW_SELECT_WRITE) ? tg0_wdf_cmd  : tg0_cmd;
	 tg1_addr         = (tg_rw_select==TG_RW_SELECT_WRITE) ? tg0_wdf_addr : tg0_addr;
	 
	 tg1_wdf_mask     = tg0_wdf_mask;
	 tg1_wdf_data     = tg0_wdf_data;
	 tg1_wdf_end      = tg_wren;
	 tg1_wdf_wren     = tg_wren;

	 tg1_wdf_en       = 'h0;
	 tg1_wdf_addr     = 'h0;
	 tg1_wdf_cmd      = 'h0;
      end
      else begin
	 tg0_rdy          = tg1_rdy;
	 tg0_wdf_rdy      = tg1_wdf_rdy;
	 
	 tg1_en           = tg0_en;
	 tg1_cmd          = tg0_cmd;
	 tg1_addr         = tg0_addr;
	 tg1_wdf_mask     = tg0_wdf_mask;
	 tg1_wdf_data     = tg0_wdf_data;
	 tg1_wdf_end      = tg0_wdf_end;
	 tg1_wdf_wren     = tg0_wdf_wren;
	 
	 tg1_wdf_en       = tg0_wdf_en;
	 tg1_wdf_addr     = tg0_wdf_addr;
	 tg1_wdf_cmd      = tg0_wdf_cmd;
      end
   end
endmodule