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
//  /   /         Filename           : qdriip_v1_4_19_tg_pattern_gen_data.sv
// /___/   /\     Date Last Modified : $Date$
// \   \  /  \    Date Created       : Thu May 22 2014
//  \___\/\___\
//
// Device           : UltraScale
// Design Name      : Traffic Generator
// Purpose:
// This is traffic table instruction BRAM.
//
// Reference        :
// Revision History :
//*****************************************************************************

`timescale 1ps / 1ps

// BRAM
module qdriip_v1_4_19_tg_instr_bram
  #(
    parameter MEM_TYPE       = "DDR3",
    parameter SIMULATION     = "FALSE",
    parameter TCQ            = 100,    
    parameter TG_INSTR_TBL_DEPTH = 32,
    parameter TG_INSTR_PTR_WIDTH = 6,
    parameter TG_INSTR_NUM_OF_ITER_WIDTH = 16,
    parameter TG_MAX_NUM_OF_ITER_ADDR = 1024,
    parameter DEFAULT_MODE   = 0
    )
   (  
      input [1:0] 			  tg_glb_qdriv_rw_submode,
      output reg [3:0] 			  bram_instr_addr_mode[TG_INSTR_TBL_DEPTH-1:0],
      output reg [3:0] 			  bram_instr_data_mode[TG_INSTR_TBL_DEPTH-1:0],
      output reg [3:0] 			  bram_instr_rw_mode[TG_INSTR_TBL_DEPTH-1:0],
      output reg [1:0] 			  bram_instr_rw_submode[TG_INSTR_TBL_DEPTH-1:0],
      output reg [2:0] 			  bram_instr_victim_mode[TG_INSTR_TBL_DEPTH-1:0],
      output reg [31:0] 		  bram_instr_num_of_iter[TG_INSTR_TBL_DEPTH-1:0],
      output reg [9:0] 			  bram_instr_m_nops_btw_n_burst_m[TG_INSTR_TBL_DEPTH-1:0],
      output reg [31:0] 		  bram_instr_m_nops_btw_n_burst_n[TG_INSTR_TBL_DEPTH-1:0],
      output reg [TG_INSTR_PTR_WIDTH-1:0] bram_instr_nxt_instr[TG_INSTR_TBL_DEPTH-1:0]
      );
   // QDRIV Read/Write submode
   // SUBMODE under DATA_MODE
   localparam TG_RW_SUBMODE_QDRIV_PORTX_RW        = 2'b00; // PortA and PortB Write then Read
   localparam TG_RW_SUBMODE_QDRIV_PORTA_W_PORTB_R = 2'b01; // PortA Write and PortB Read
   localparam TG_RW_SUBMODE_QDRIV_PORTB_W_PORTA_R = 2'b10; // PortA Write and PortB Read
   localparam TG_RW_SUBMODE_QDRIV_PORTAB_RW       = 2'b11; // PortA and PortB with Mixed Read/Write

   // DDR3/4 Read/Write submode
   localparam TG_RW_SUBMODE_DDR_W_R               = 2'b00; // Write follows by Read
   localparam TG_RW_SUBMODE_DDR_W_R_SIMU          = 2'b01; // Write and Read in parallel

   localparam TG_RW_SUBMODE_DEFAULT               = 2'b00; // For QDR/RLD, this is default value
   
   wire [4+4+4+2+3+32+10+32+TG_INSTR_PTR_WIDTH-1:0] bram_out[TG_INSTR_TBL_DEPTH-1:0];
   wire [31:0] 					 tg_max_num_of_iter_addr;
   integer 					 i;
   
   assign tg_max_num_of_iter_addr = (MEM_TYPE == "QDRIV" && 
				     tg_glb_qdriv_rw_submode == TG_RW_SUBMODE_QDRIV_PORTX_RW) ? 
				    TG_MAX_NUM_OF_ITER_ADDR/2 :
				    TG_MAX_NUM_OF_ITER_ADDR;
   
   localparam TG_INSTR_NUM_EXIT     = 6'b111111;

   localparam TG_PATTERN_MODE_LINEAR   = 4'b0000;   
   localparam TG_PATTERN_MODE_PRBS     = 4'b0001;
   localparam TG_PATTERN_MODE_WALKING1 = 4'b0010;
   localparam TG_PATTERN_MODE_WALKING0 = 4'b0011;
   localparam TG_PATTERN_MODE_HAMMER1  = 4'b0100;
   localparam TG_PATTERN_MODE_HAMMER0  = 4'b0101;
   localparam TG_PATTERN_MODE_BRAM     = 4'b0110;
	
   localparam TG_RW_MODE_READ_ONLY  = 4'b001;
   localparam TG_RW_MODE_WRITE_ONLY = 4'b010;
   localparam TG_RW_MODE_WRITE_READ = 4'b011;
   localparam TG_RW_MODE_WRITE_ONCE_READ_FOREVER = 4'b111;
   
   localparam TG_VICTIM_MODE_NO_VICTIM     = 3'b000;
   localparam TG_VICTIM_MODE_HELD1         = 3'b001;
   localparam TG_VICTIM_MODE_HELD0         = 3'b010;   
   localparam TG_VICTIM_MODE_NONINV_AGGR   = 3'b011;
   localparam TG_VICTIM_MODE_INV_AGGR      = 3'b100;
   localparam TG_VICTIM_MODE_DELAYED_AGGR  = 3'b101;

   // TG Default Operation mode enables
   localparam TG_DEFAULT_MODE_PRBS_ADDR_INSTR = (DEFAULT_MODE & 1) > 0;
   localparam TG_DEFAULT_MODE_SIMU_WRITE_READ = (DEFAULT_MODE & 2) > 0;
   
   always@(*) begin   
      for (i=0; i<TG_INSTR_TBL_DEPTH; i=i+1) begin: bram_instr_init
	 bram_instr_addr_mode[i]            = bram_out[i][4+4+2+3+32+10+32+TG_INSTR_PTR_WIDTH +: 4];
	 bram_instr_data_mode[i]            = bram_out[i][4+2+3+32+10+32+TG_INSTR_PTR_WIDTH +: 4];
	 bram_instr_rw_mode[i]              = bram_out[i][2+3+32+10+32+TG_INSTR_PTR_WIDTH +: 4];
	 bram_instr_rw_submode[i]           = bram_out[i][3+32+10+32+TG_INSTR_PTR_WIDTH +: 2];
	 bram_instr_victim_mode[i]          = bram_out[i][32+10+32+TG_INSTR_PTR_WIDTH +: 3];
	 bram_instr_num_of_iter[i]          = bram_out[i][10+32+TG_INSTR_PTR_WIDTH +: 32];
	 bram_instr_m_nops_btw_n_burst_m[i] = bram_out[i][32+TG_INSTR_PTR_WIDTH +: 10];
	 bram_instr_m_nops_btw_n_burst_n[i] = bram_out[i][TG_INSTR_PTR_WIDTH +: 32];
	 bram_instr_nxt_instr[i]            = bram_out[i][0 +: TG_INSTR_PTR_WIDTH];
      end
   end

   //                     +--------------------------+--------------------------+-----------------------+-----------------------+--------------------------+---------------------------+-----------+-----------+------------+
   //                     | Traffic Pattern Instruction Table
   //                     | PLEASE PROGRAM ME
   //                     +--------------------------+--------------------------+-----------------------+-----------------------+--------------------------+---------------------------+-----------+-----------+------------+
   //                     |                          |                          |                       |                       |                          |                           | Burst     | Burst     |            |
   //                     | Address Pattern          | Data Pattern             | Read/Write Mode       | Read/Write Submode    | Victim Mode              | Num of Iteration          | NOP CountM| OP CountN | Next Instr |       
   //                     +--------------------------+--------------------------+-----------------------+-----------------------+--------------------------+---------------------------+-----------+-----------+------------+
if (SIMULATION == "FALSE") begin															   			   
   // Default programming (change to program different traffic pattern)										   
   assign bram_out[0 ] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  tg_max_num_of_iter_addr,    10'd0,      32'd1024,   6'd1};
   assign bram_out[1 ] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_HAMMER0,   TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  32'd1024,                   10'd0,      32'd1024,   (TG_DEFAULT_MODE_SIMU_WRITE_READ || TG_DEFAULT_MODE_PRBS_ADDR_INSTR) ? 6'd2 : 6'd0};
   if (TG_DEFAULT_MODE_SIMU_WRITE_READ) begin
   assign bram_out[2 ] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DDR_W_R_SIMU,  TG_VICTIM_MODE_NO_VICTIM,  tg_max_num_of_iter_addr/2, 10'd0,      32'd1024,   6'd3};
   assign bram_out[3 ] = {TG_PATTERN_MODE_PRBS,      TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DDR_W_R_SIMU,  TG_VICTIM_MODE_NO_VICTIM,  tg_max_num_of_iter_addr/2, 10'd0,      32'd1024,   6'd0};
   end
   else if (TG_DEFAULT_MODE_PRBS_ADDR_INSTR) begin
   assign bram_out[2 ] = {TG_PATTERN_MODE_PRBS,      TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  32'd1024,                      10'd0,      32'd1024,   6'd0};
   assign bram_out[3 ] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   end
   else begin
   assign bram_out[2 ] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[3 ] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   end
end else begin																		   						   
   assign bram_out[0 ] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  32'd1000,                   10'd0,      32'd1024,   6'd1};
   assign bram_out[1 ] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_HAMMER0,   TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  32'd1000,                   10'd0,      32'd1024,   (TG_DEFAULT_MODE_SIMU_WRITE_READ || TG_DEFAULT_MODE_PRBS_ADDR_INSTR) ? 6'd2 : TG_INSTR_NUM_EXIT};
   if (TG_DEFAULT_MODE_SIMU_WRITE_READ) begin
   assign bram_out[2 ] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DDR_W_R_SIMU,  TG_VICTIM_MODE_NO_VICTIM,  32'd1000,              10'd0,      32'd1024,   6'd3};
   assign bram_out[3 ] = {TG_PATTERN_MODE_PRBS,      TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DDR_W_R_SIMU,  TG_VICTIM_MODE_NO_VICTIM,  32'd1000,              10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   end
   else if (TG_DEFAULT_MODE_PRBS_ADDR_INSTR) begin
   assign bram_out[2 ] = {TG_PATTERN_MODE_PRBS,      TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  32'd1000,                      10'd0,   32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[3 ] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,   32'd1024,   TG_INSTR_NUM_EXIT};
   end
   else begin
   assign bram_out[2 ] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[3 ] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   end   
end																			   							   
   // Default programming (change to program different traffic pattern)										   
   assign bram_out[4 ] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[5 ] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[6 ] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[7 ] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[8 ] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[9 ] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[10] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[11] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[12] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[13] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[14] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[15] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[16] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[17] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[18] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[19] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[20] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[21] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[22] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[23] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[24] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[25] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[26] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[27] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[28] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[29] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[30] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   assign bram_out[31] = {TG_PATTERN_MODE_LINEAR,    TG_PATTERN_MODE_PRBS,      TG_RW_MODE_WRITE_READ,  TG_RW_SUBMODE_DEFAULT,  TG_VICTIM_MODE_NO_VICTIM,  TG_INSTR_NUM_OF_ITER_WIDTH, 10'd0,      32'd1024,   TG_INSTR_NUM_EXIT};
   //                     +--------------------------+--------------------------+-----------------------+-----------------------+--------------------------+---------------------------+-----------+-----------+------------+
   
endmodule

