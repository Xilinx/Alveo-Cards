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
//  /   /         Filename           : qdriip_v1_4_19_tg_top.sv
// /___/   /\     Date Last Modified : $Date: 2014/09/05 $
// \   \  /  \    Date Created       : Thu May 22 2014
//  \___\/\___\
//
// Device           : UltraScale
// Design Name      : Traffic Generator
// Purpose:
// This is a programmable traffic generator.
// The traffic generator contains a 32 entry traffic pattern table programmable through VIO.
//
// Each traffic pattern could be programmed with user choice of
// - address mode (linear, PRBS, walking1/0) 
// - data mode (linear, PRBS, walking1/0, hammer1/0
// - read/write mode (write-read, write-only, read-only, write-once-read-forever)
// - number of command per traffic pattern
// - number of NOPs after Bursts
// - number of Bursts before NOP
// - next instruction
//
// User could create a sequence of traffic pattern by programming "next instruction" pointer
//
// This traffic generator waits for calibration complete (init_calib_complete)
// Upon calibration complete, traffic generator would start sending traffic sequence
// according to user programming in the traffic pattern table.
//
// For Write-read mode or Write-once-Read-forever modes, error check could be enabled 
// (Write-only or Read-only modes do not have error check)
// User could choose either
// - stop traffic upon first error seen. Bit-wise data mismatch and address location are available in VIO.
//   Traffic generator would perform read check to detect if mismatch seen is "WRITE" error or "READ" error.
//   User could continue traffic after checking error OR restart traffic.
// - continue traffic when error is seen. Bit-wise sticky bit mismatch is available in VIO.
// 
// Other features:
// - User could pause and un-pause traffic.
// - User could pause traffic, re-program traffic pattern, and restart traffic generator when
//   new traffic pattern programming is needed.
//
// Important Note:
// For Write-read mode or Write-once-Read-forever modes, this traffic generator would issue all write
// traffic, follow by all read traffic. During read data check, expected read traffic is generated
// on-the-fly and compared with read data.
// If a memory address is written more than once with different data pattern, traffic generator 
// would create false error check.
// It is recommended, for a given traffic pattern programmed, number of command must be less than 
// available address space programmed.
//
// Reference        :
// Revision History :
//*****************************************************************************

`timescale 1ps / 1ps

//`ifdef SIMULATION
`define MCP(signal,signal_mcp,width,mcp_cycle) \
   reg [15:0] mcp_cnt_``signal; \
   reg [width-1:0] reg_``signal_mcp; \
   wire       switch_``signal_mcp; \
   assign switch_``signal_mcp = | (``signal_mcp^reg_``signal_mcp); \
   assign ``signal = ((mcp_cnt_``signal=='h0) && ~switch_``signal_mcp) ? ``signal_mcp : 'hx; \
   always@(posedge tg_clk /*|| posedge switch_``signal_mcp*/) begin \
      if (tg_rst || switch_``signal_mcp) begin \
	 mcp_cnt_``signal <= #TCQ ``mcp_cycle-'h2; \
      end \
      else if (mcp_cnt_``signal > 'h0) begin \
	 mcp_cnt_``signal <= #TCQ mcp_cnt_``signal - 'h1; \
      end \
         reg_``signal_mcp <= #TCQ ``signal_mcp; \
   end
//`else \
//   assign signal_m = signal; \
//`endif
`define MCP2D(signal,signal_mcp,width,index,mcp_cycle) \
   reg [15:0] mcp_cnt_``signal``index; \
   reg [width-1:0] reg_``signal_mcp``index; \
   wire       switch_``signal_mcp``index; \
   assign switch_``signal_mcp``index = | (``signal_mcp[``index]^reg_``signal_mcp``index); \
   assign ``signal[``index] = ((mcp_cnt_``signal``index=='h0) && ~switch_``signal_mcp``index) ? ``signal_mcp[``index] : 'hx; \
   always@(posedge tg_clk /*|| posedge switch_``signal_mcp*/) begin \
      if (tg_rst || switch_``signal_mcp``index) begin \
	 mcp_cnt_``signal``index <= #TCQ ``mcp_cycle-'h2; \
      end \
      else if (mcp_cnt_``signal``index > 'h0) begin \
	 mcp_cnt_``signal``index <= #TCQ mcp_cnt_``signal``index - 'h1; \
      end \
         reg_``signal_mcp``index <= #TCQ ``signal_mcp[``index]; \
   end

// Test Pattern Generation
module qdriip_v1_4_19_tg_top
  #(
    parameter SIMULATION     = "FALSE",
    parameter MEM_ARCH       = "ULTRASCALE", // Memory Architecture: ULTRASCALE, 7SERIES
    parameter MEM_TYPE       = "DDR3", // DDR3, DDR4, RLD2, RLD3, QDRIIP, QDRIV
    parameter TCQ            = 100,    
    parameter APP_DATA_WIDTH = 576,
    parameter APP_ADDR_WIDTH = 28,
    parameter APP_CMD_WIDTH  = 3,
    parameter NUM_DQ_PINS    = 72,
    parameter DM_WIDTH = (MEM_TYPE == "RLD3" || MEM_TYPE == "RLD2") ? 18 : 8,
    parameter nCK_PER_CLK    = 4,
    parameter CMD_PER_CLK    = 2,
    parameter TG_PATTERN_MODE_PRBS_DATA_WIDTH = 23,
    parameter [APP_ADDR_WIDTH/CMD_PER_CLK-1:0] TG_PATTERN_MODE_PRBS_ADDR_SEED = 44'hba987654321,
    parameter [APP_DATA_WIDTH-1:0] TG_PATTERN_MODE_LINEAR_DATA_SEED = 1152'h777777777_777777777_666666666_666666666_555555555_555555555_444444444_444444444_333333333_333333333_222222222_222222222_111111111_111111111_000000000_000000000_777777777_777777777_666666666_666666666_555555555_555555555_444444444_444444444_333333333_333333333_222222222_222222222_111111111_111111111_000000000_000000000,
    parameter TG_WATCH_DOG_MAX_CNT = 16'd10000,
    parameter TG_INSTR_SM_WIDTH  = 4,
    parameter DEFAULT_MODE = 0
    )
   (
    input 					tg_clk,
    input 					tg_rst,
    input 					tg_calib_complete, // Calibration complete
    // TG control interface
    input 					vio_tg_rst, // TG reset TG
    input 					vio_tg_start, // TG start enable TG
    input 					vio_tg_restart, // TG restart
    input 					vio_tg_pause, // TG pause (level signal)
    input 					vio_tg_err_chk_en, // If Error check is enabled (level signal), 
                                                              //    TG will stop after first error. 
                                                              // Else, 
                                                              //    TG will continue on the rest of the programmed instructions
    input 					vio_tg_err_clear, // Clear Error excluding sticky bit (pos edge triggered)
    input 					vio_tg_err_clear_all, // Clear Error including sticky bit (pos edge triggered)
    input 					vio_tg_err_continue, // Continue run after Error detected (pos edge triggered)
    // TG programming interface
    // - instruction table programming interface
    input 					vio_tg_instr_program_en, // VIO to enable instruction programming
    input 					vio_tg_direct_instr_en, // VIO to enable direct instruction
    input [4:0] 				vio_tg_instr_num, // VIO to program instruction number
    input [3:0] 				vio_tg_instr_addr_mode, // VIO to program address mode
    input [3:0] 				vio_tg_instr_data_mode, // VIO to program data mode
    input [3:0] 				vio_tg_instr_rw_mode, // VIO to program read/write mode
    input [1:0] 				vio_tg_instr_rw_submode, // VIO to program read/write submode (Only Valid for DDR)
    input [2:0] 				vio_tg_instr_victim_mode, // VIO to program victim mode
    input [31:0] 				vio_tg_instr_num_of_iter, // VIO to program number of iteration per instruction
    input [9:0] 				vio_tg_instr_m_nops_btw_n_burst_m, // VIO to program number of NOPs between BURSTs
    input [31:0] 				vio_tg_instr_m_nops_btw_n_burst_n, // VIO to program number of BURSTs between NOPs
    input [5:0] 				vio_tg_instr_nxt_instr, // VIO to program next instruction pointer
    // TG PRBS Data Seed programming interface
    input 					vio_tg_seed_program_en, // VIO to enable prbs data seed programming
    input [7:0] 				vio_tg_seed_num, // VIO to program prbs data seed number
    input [TG_PATTERN_MODE_PRBS_DATA_WIDTH-1:0] vio_tg_seed, // VIO to program prbs data seed
    // - global parameter register
    input [7:0] 				vio_tg_glb_victim_bit, // Define Victim bit in data pattern
    input [4:0] 				vio_tg_glb_victim_aggr_delay, // Define aggressor pattern to be N-clk-delay of victim pattern
    input [APP_ADDR_WIDTH/CMD_PER_CLK-1:0] 	vio_tg_glb_start_addr,
    //input [1:0] 				vio_tg_glb_ddr_rw_submode,
    input [1:0] 				vio_tg_glb_qdriv_rw_submode,
    // - status register
    output reg [TG_INSTR_SM_WIDTH-1:0] 		vio_tg_status_state,
    output 					vio_tg_status_err_bit_valid, // Intermediate error detected
    output [APP_DATA_WIDTH-1:0] 		vio_tg_status_err_bit, // Intermediate error bit pattern
    output [APP_ADDR_WIDTH-1:0] 		vio_tg_status_err_addr, // Intermediate error address
    output 					vio_tg_status_exp_bit_valid, // immediate expected bit
    output [APP_DATA_WIDTH-1:0] 		vio_tg_status_exp_bit,
    output 					vio_tg_status_read_bit_valid, // immediate read data bit
    output [APP_DATA_WIDTH-1:0] 		vio_tg_status_read_bit,
    output 					vio_tg_status_first_err_bit_valid, // first logged error bit and address
    output [APP_DATA_WIDTH-1:0] 		vio_tg_status_first_err_bit,
    output [APP_ADDR_WIDTH-1:0] 		vio_tg_status_first_err_addr,
    output 					vio_tg_status_first_exp_bit_valid, // first logged error, expected data and address
    output [APP_DATA_WIDTH-1:0] 		vio_tg_status_first_exp_bit,
    output 					vio_tg_status_first_read_bit_valid, // first logged error, read data and address
    output [APP_DATA_WIDTH-1:0] 		vio_tg_status_first_read_bit,
    output 					vio_tg_status_err_bit_sticky_valid, // Accumulated error detected
    output [APP_DATA_WIDTH-1:0] 		vio_tg_status_err_bit_sticky, // Accumulated error bit pattern
    output 					vio_tg_status_err_type_valid, // Read/Write error detected
    output 					vio_tg_status_err_type, // Read/Write error type
    //output [31:0] 			   vio_tg_status_tot_rd_cnt,
    //output [31:0] 			   vio_tg_status_tot_wr_cnt,
    //output [31:0] 			   vio_tg_status_tot_rd_req_cyc_cnt,
    //output [31:0] 			   vio_tg_status_tot_wr_req_cyc_cnt,
    output reg 					vio_tg_status_wr_done, // In Write Read mode, this signal will be pulsed after every Write/Read cycle
    output 					vio_tg_status_done,
    output 					vio_tg_status_watch_dog_hang, // Watch dog detected traffic stopped unexpectedly
    
    // App interface
    input 					app_rdy, // DDR3/4, RLD3 Interface
    input 					app_wdf_rdy, // DDR3/4, RLD3 Interface
    input [CMD_PER_CLK-1:0] 			app_rd_data_valid, // DDR3/4, RLD3, QDRIIP Interface
    input [APP_DATA_WIDTH-1:0] 			app_rd_data, // DDR3/4, RLD3, QDRIIP (0/1) Interface
    output [APP_CMD_WIDTH-1:0] 			app_cmd, // DDR3/4, RLD3, QDRIIP (READ 0/1) Interface
    output [APP_ADDR_WIDTH-1:0] 		app_addr, // DDR3/4, RLD3, QDRIIP (READ 0/1) Interface
    output 					app_en, // DDR3/4, RLD3, QDRIIP (READ 0/1) Interface
    output [APP_DATA_WIDTH/DM_WIDTH-1:0] 	app_wdf_mask, // DDR3/4, RLD3, QDRIIP (WRITE 0/1) Interface
    output [APP_DATA_WIDTH-1: 0] 		app_wdf_data, // DDR3/4, RLD3, QDRIIP (WRITE 0/1) Interface
    output 					app_wdf_end, // DDR3/4, RLD3 Interface
    output 					app_wdf_wren, // DDR3/4, RLD3, QDRIIP (WRITE 0/1)  Interface
    // QDRIIP Interface
    output 					app_wdf_en, // QDRIIP (WRITE 0/1) Interface
    output [APP_ADDR_WIDTH-1:0] 		app_wdf_addr, // QDRIIP (WRITE 0/1) Interface
    output [APP_CMD_WIDTH-1:0] 			app_wdf_cmd, // QDRIIP (READ 0/1) Interface    
    
    // TG RW Submode needs to be passed to external gluelogic
    output [1:0]                                tg_rw_submode
    // ILA debug
    //output [398:0] 				tg_ila_debug
    
    );

   localparam VIO_TG_RST_WIDTH_FO = 18;
   localparam LOG2_MAX_READ_DELAY = 4;
   localparam TG_MEM_MAX_ADDR_SPACE  = ((MEM_TYPE == "RLD2") || (MEM_TYPE == "RLD3"))    ? (2**(APP_ADDR_WIDTH/CMD_PER_CLK))/CMD_PER_CLK :
				       ((MEM_TYPE == "QDRIIP") || (MEM_TYPE == "QDRIV")) ? (2**(APP_ADDR_WIDTH/CMD_PER_CLK))/CMD_PER_CLK :
				       (2**(APP_ADDR_WIDTH-3))/CMD_PER_CLK;
   localparam TG_PRBS_MAX_ADDR_SPACE = 2**(TG_PATTERN_MODE_PRBS_DATA_WIDTH-3);
			  
   localparam TG_MAX_NUM_OF_ITER_ADDR = (TG_PRBS_MAX_ADDR_SPACE < TG_MEM_MAX_ADDR_SPACE) ? TG_PRBS_MAX_ADDR_SPACE : TG_MEM_MAX_ADDR_SPACE;
   localparam TG_INSTR_TBL_DEPTH = 32;   
   localparam TG_INSTR_PTR_WIDTH = 6;
   localparam TG_INSTR_NUM_EXIT     = 6'b111111;
   //localparam TG_INSTR_NUM_OF_ITER_BASE   = 0;
   localparam TG_INSTR_NUM_OF_ITER_WIDTH  = 16;
   
   localparam RLD_BANK_WIDTH = (MEM_TYPE == "RLD3") ? 4 : 3;
   localparam TG_PATTERN_MODE_PRBS_ADDR_WIDTH 
     = ((MEM_TYPE == "RLD3") || (MEM_TYPE == "RLD2")) ? APP_ADDR_WIDTH/CMD_PER_CLK - RLD_BANK_WIDTH :
       APP_ADDR_WIDTH/CMD_PER_CLK - 3;
   
   // TG_PATTERN_MODE_PRBS_DATA_SEED NOT USED
   // Coded in qdriip_v1_4_19_tg_data_prbs.sv
   //localparam TG_PATTERN_MODE_PRBS_DATA_SEED = 1152'h777777777_777777777_666666666_666666666_555555555_555555555_444444444_444444444_333333333_333333333_222222222_222222222_111111111_111111111_000000000_000000000_777777777_777777777_666666666_666666666_555555555_555555555_444444444_444444444_333333333_333333333_222222222_222222222_111111111_111111111_000000000_000000000;
   //localparam TG_PATTERN_MODE_PRBS_ADDR_SEED = 44'hba987654321;
   //localparam TG_PATTERN_MODE_LINEAR_DATA_SEED = 1152'h777777777_777777777_666666666_666666666_555555555_555555555_444444444_444444444_333333333_333333333_222222222_222222222_111111111_111111111_000000000_000000000_777777777_777777777_666666666_666666666_555555555_555555555_444444444_444444444_333333333_333333333_222222222_222222222_111111111_111111111_000000000_000000000;
   // TG_PATTERN_MODE_LINEAR_ADDR_SEED NOT USED
   // Programmable in VIO
   //localparam TG_PATTERN_MODE_LINEAR_ADDR_SEED = 44'h123456789ab;

   localparam TG_PATTERN_MODE_PRBS_ADDR_NUM_OF_POLY_TAP
     = ((TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 8) ||
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 12) ||
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 13) ||
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 14) ||
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 16) ||
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 19) ||
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 24) ||
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 26) ||
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 27) ||
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 30) ||							
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 32) ||
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 34)) ? 4 :
       ((TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 9) ||
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 10) ||
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 11) ||
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 15) ||
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 17) ||
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 18) ||
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 20) ||
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 21) ||
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 22) ||
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 23) ||							
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 25) ||
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 28) ||
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 29) ||
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 31) ||							
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 33)) ? 2 : 2;

    localparam TG_PATTERN_MODE_PRBS_ADDR_POLY_TAP0 
      = TG_PATTERN_MODE_PRBS_ADDR_WIDTH;

    localparam TG_PATTERN_MODE_PRBS_ADDR_POLY_TAP1
      = (TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 8) ? 6 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 9) ? 5 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 10) ? 7 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 11) ? 9 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 12) ? 6 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 13) ? 4 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 14) ? 5 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 15) ? 14 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 16) ? 15 : 							
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 17) ? 14 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 18) ? 11 :
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 19) ? 6 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 20) ? 17 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 21) ? 19 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 22) ? 21 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 23) ? 18 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 24) ? 23 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 25) ? 22 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 26) ? 6 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 27) ? 5 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 28) ? 25 : 							
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 29) ? 27 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 30) ? 6 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 31) ? 28 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 32) ? 22 : 							
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 33) ? 20 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 34) ? 27 : 1;

    localparam TG_PATTERN_MODE_PRBS_ADDR_POLY_TAP2
      = (TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 8) ? 5 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 12) ? 4 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 13) ? 3 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 14) ? 3 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 16) ? 13 : 							
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 19) ? 2 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 24) ? 22 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 26) ? 2 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 27) ? 2 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 30) ? 4 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 32) ? 2 : 							
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 34) ? 2 : 1;

    localparam TG_PATTERN_MODE_PRBS_ADDR_POLY_TAP3
      = (TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 8) ? 4 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 12) ? 1 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 13) ? 1 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 14) ? 1 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 16) ? 4 : 							
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 19) ? 1 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 24) ? 17 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 26) ? 1 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 27) ? 1 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 30) ? 1 : 
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 32) ? 1 : 							
	(TG_PATTERN_MODE_PRBS_ADDR_WIDTH == 34) ? 1 : 1;

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

   localparam TG_INSTR_START     = 4'b0000;
   localparam TG_INSTR_LOAD      = 4'b0001;
   localparam TG_INSTR_DINIT     = 4'b0010;
   localparam TG_INSTR_EXE       = 4'b0011;
   localparam TG_INSTR_RWLOAD    = 4'b0100;
   localparam TG_INSTR_ERRWAIT   = 4'b0101;
   localparam TG_INSTR_ERRCHK    = 4'b0110;
   localparam TG_INSTR_ERRDONE   = 4'b0111;
   localparam TG_INSTR_PAUSE     = 4'b1000;
   localparam TG_INSTR_PAUSEWAIT = 4'b1101;
   localparam TG_INSTR_LDWAIT    = 4'b1001;
   localparam TG_INSTR_RWWAIT    = 4'b1010;
   localparam TG_INSTR_DNWAIT    = 4'b1011;
   localparam TG_INSTR_DONE      = 4'b1100;

   // WRITE OPCODE used per interface
   localparam TG_WRITE_OPCODE    = (MEM_TYPE == "DDR3" || MEM_TYPE == "DDR4") ? {{APP_CMD_WIDTH/CMD_PER_CLK-1{1'b0}}, 1'b0} :
				   (MEM_TYPE == "RLD2" || MEM_TYPE == "RLD3") ? {{APP_CMD_WIDTH/CMD_PER_CLK-1{1'b0}}, 1'b0} :
				   (MEM_TYPE == "QDRIIP")                     ? {{APP_CMD_WIDTH/CMD_PER_CLK-1{1'b0}}, 1'b0} :
				   (MEM_TYPE == "QDRIV")                      ? 2'b11 : 'h0;
   
   localparam TG_READ_OPCODE     = (MEM_TYPE == "DDR3" || MEM_TYPE == "DDR4") ? {{APP_CMD_WIDTH/CMD_PER_CLK-1{1'b0}}, 1'b1} :
				   (MEM_TYPE == "RLD2" || MEM_TYPE == "RLD3") ? {{APP_CMD_WIDTH/CMD_PER_CLK-1{1'b0}}, 1'b1} :
				   (MEM_TYPE == "QDRIIP")                     ? {{APP_CMD_WIDTH/CMD_PER_CLK-1{1'b0}}, 1'b1} :
				   (MEM_TYPE == "QDRIV")                      ? 2'b10 : 'h1;
   
   // QDRIV Read/Write submode
   // SUBMODE under DATA_MODE
   localparam TG_RW_SUBMODE_QDRIV_PORTX_RW        = 2'b00; // PortA and PortB Write then Read
   localparam TG_RW_SUBMODE_QDRIV_PORTA_W_PORTB_R = 2'b01; // PortA Write and PortB Read
   localparam TG_RW_SUBMODE_QDRIV_PORTB_W_PORTA_R = 2'b10; // PortA Write and PortB Read
   localparam TG_RW_SUBMODE_QDRIV_PORTAB_RW       = 2'b11; // PortA and PortB with Mixed Read/Write
   
   // DDR3/4 Read/Write submode
   localparam TG_RW_SUBMODE_DDR_W_R               = 2'b00; // Write follows by Read
   localparam TG_RW_SUBMODE_DDR_W_R_SIMU          = 2'b01; // Write and Read in parallel
   
   // local TG signals
   // TG pattern programming
   reg 					   tg_start;
   reg 					   tg_restart; // TG will start at rising edge of vio_tg_start
   reg                                     tg_instr_program_en;
   reg [4:0] 				   tg_instr_num;
   reg [3:0] 				   tg_instr_addr_mode[TG_INSTR_TBL_DEPTH-1:0];
   reg [3:0] 				   tg_instr_data_mode[TG_INSTR_TBL_DEPTH-1:0];
   reg [3:0] 				   tg_instr_rw_mode[TG_INSTR_TBL_DEPTH-1:0];
   reg [1:0] 				   tg_instr_rw_submode[TG_INSTR_TBL_DEPTH-1:0];
   reg [2:0] 				   tg_instr_victim_mode[TG_INSTR_TBL_DEPTH-1:0];
   reg [31:0] 				   tg_instr_num_of_iter[TG_INSTR_TBL_DEPTH-1:0];
   reg [9:0] 				   tg_instr_m_nops_btw_n_burst_m[TG_INSTR_TBL_DEPTH-1:0];
   reg [31:0] 				   tg_instr_m_nops_btw_n_burst_n[TG_INSTR_TBL_DEPTH-1:0];
   reg [TG_INSTR_PTR_WIDTH-1:0] 	   tg_instr_nxt_instr[TG_INSTR_TBL_DEPTH-1:0];

   reg [VIO_TG_RST_WIDTH_FO-1:0] 	   tg_rst_int;   
   reg [7:0] 				   tg_glb_victim_bit;     
   reg [4:0] 				   tg_glb_victim_aggr_delay;
   reg [APP_ADDR_WIDTH/CMD_PER_CLK-1:0]    tg_glb_start_addr;

   wire [3:0] 				   bram_instr_addr_mode[TG_INSTR_TBL_DEPTH-1:0];
   wire [3:0] 				   bram_instr_data_mode[TG_INSTR_TBL_DEPTH-1:0];
   wire [3:0] 				   bram_instr_rw_mode[TG_INSTR_TBL_DEPTH-1:0];
   wire [1:0] 				   bram_instr_rw_submode[TG_INSTR_TBL_DEPTH-1:0];
   wire [2:0] 				   bram_instr_victim_mode[TG_INSTR_TBL_DEPTH-1:0];
   wire [31:0] 				   bram_instr_num_of_iter[TG_INSTR_TBL_DEPTH-1:0];
   wire [9:0] 				   bram_instr_m_nops_btw_n_burst_m[TG_INSTR_TBL_DEPTH-1:0];
   wire [31:0] 				   bram_instr_m_nops_btw_n_burst_n[TG_INSTR_TBL_DEPTH-1:0];
   wire [TG_INSTR_PTR_WIDTH-1:0] 	   bram_instr_nxt_instr[TG_INSTR_TBL_DEPTH-1:0];   
   
   // TG State machine signals
   // States
   [TG_INSTR_SM_WIDTH-1:0] 		   tg_instr_sm_ps;

   reg 					   tg_instr_start_s;
   reg 					   tg_instr_start_s_r; 
   reg 					   tg_instr_start_s_p;
   reg 					   tg_instr_start_s_p2;   

   reg 					   tg_instr_load_s;  
   reg 					   tg_instr_load_s_r;
   reg 					   tg_instr_load_s_p;
   reg 					   tg_instr_load_s_p2;
   reg 					   tg_instr_dinit_s; 
   reg 					   tg_instr_exe_s;
   reg 					   tg_instr_exe_s_r;
   reg 					   tg_instr_rwload_s;
   reg 					   tg_instr_rwload_s_r;
   reg 					   tg_instr_rwload_s_p;
   reg 					   tg_instr_rwload_s_p2;
   reg 					   tg_instr_errchk_s;
   reg 					   tg_instr_pause_s; 
   reg 					   tg_instr_pausewait_s; 
   reg 					   tg_instr_ldwait_s;
   reg 					   tg_instr_dnwait_s;
   reg 					   tg_instr_done_s;
   reg 					   tg_instr_errwait_s;
   reg 					   tg_instr_rwwait_s;
   reg 					   tg_instr_errdone_s;
   
   //wire 				   tg_instr_start_s   = (tg_instr_sm_ps == TG_INSTR_START);
   //wire 				   tg_instr_load_s    = (tg_instr_sm_ps == TG_INSTR_LOAD);
   //wire 				   tg_instr_dinit_s   = (tg_instr_sm_ps == TG_INSTR_DINIT);
   //wire 				   tg_instr_exe_s     = (tg_instr_sm_ps == TG_INSTR_EXE);
   //wire 				   tg_instr_rwload_s  = (tg_instr_sm_ps == TG_INSTR_RWLOAD);
   //wire 				   tg_instr_errchk_s  = (tg_instr_sm_ps == TG_INSTR_ERRCHK);
   //wire 				   tg_instr_pause_s   = (tg_instr_sm_ps == TG_INSTR_PAUSE);
   //wire 				   tg_instr_ldwait_s  = (tg_instr_sm_ps == TG_INSTR_LDWAIT);
   //wire 				   tg_instr_dnwait_s  = (tg_instr_sm_ps == TG_INSTR_DNWAIT);
   //wire 				   tg_instr_done_s    = (tg_instr_sm_ps == TG_INSTR_DONE);
   //wire 				   tg_instr_errwait_s = (tg_instr_sm_ps == TG_INSTR_ERRWAIT);
   //wire 				   tg_instr_rwwait_s  = (tg_instr_sm_ps == TG_INSTR_RWWAIT);
   //wire 				   tg_instr_errdone_s = (tg_instr_sm_ps == TG_INSTR_ERRDONE);
   
   // Arcs
   wire 				   arc_tg_instr_start_start;
   wire 				   arc_tg_instr_start_load;
   wire 				   arc_tg_instr_load_dinit;
   wire 				   arc_tg_instr_dinit_exe;
   wire 				   arc_tg_instr_exe_rwwait;
   wire 				   arc_tg_instr_rwload_dinit;
   wire 				   arc_tg_instr_exe_ldwait;
   wire 				   arc_tg_instr_exe_dnwait;
   wire 				   arc_tg_instr_exe_pausewait;
   wire 				   arc_tg_instr_pause_exe;
   wire 				   arc_tg_instr_pausewait_pause;
   wire 				   arc_tg_instr_pause_start;
   wire 				   arc_tg_instr_ldwait_load;
   wire 				   arc_tg_instr_rwwait_rwload;
   wire 				   arc_tg_instr_dnwait_done;
   wire 				   arc_tg_instr_done_start;   
   wire 				   arc_tg_instr_exe_errwait;
   wire 				   arc_tg_instr_errwait_errchk;
   wire 				   arc_tg_instr_errchk_errdone;
   wire 				   arc_tg_instr_errdone_start;
   wire                                    arc_tg_instr_errdone_exe;
   wire 				   arc_tg_instr_errdone_done; // This is a special case when read reached end count while in errwait state. SM needs to transition to done/load/rwload depends on current instruction
   wire 				   arc_tg_instr_errdone_load; // This is a special case when read reached end count while in errwait state. SM needs to transition to done/load/rwload depends on current instruction
   wire 				   arc_tg_instr_errdone_rwload; // This is a special case when read reached end count while in errwait state. SM needs to transition to done/load/rwload depends on current instruction
   wire 				   arc_tg_instr_ldwait_errwait;
   wire 				   arc_tg_instr_rwwait_errwait;
   wire 				   arc_tg_instr_dnwait_errwait;   
   
   // Start - user restart TG
   reg 					   instr_restart;
   reg 					   tg_restart_r;
   // Load - loading current instruction and reset instruction states
   reg [TG_INSTR_PTR_WIDTH-1:0] 	   tg_curr_instr_ptr;
   reg [3:0] 				   tg_curr_addr_mode;
   reg [3:0] 				   tg_curr_data_mode;
   reg [3:0] 				   tg_curr_rw_mode;
   reg [1:0] 				   tg_curr_rw_submode;
   reg [2:0] 				   tg_curr_victim_mode;
   reg [31:0] 				   tg_curr_num_of_iter;
   reg [31:0] 				   tg_curr_num_of_iter_minus1;
   reg [9:0] 				   tg_curr_m_nops_btw_n_burst_m;
   reg [31:0] 				   tg_curr_m_nops_btw_n_burst_n;
   reg [9:0] 				   tg_curr_m_nops_btw_n_burst_m_minus1;
   reg [31:0] 				   tg_curr_m_nops_btw_n_burst_n_minus1;
   reg [TG_INSTR_PTR_WIDTH-1:0] 	   tg_curr_nxt_instr;
   
   reg [31:0] 				   tg_curr_num_of_iter_rd_cnt;
   reg [31:0] 				   tg_curr_num_of_iter_rd_cnt_r;
   reg [31:0] 				   tg_curr_num_of_iter_wr_cnt;
   reg 					   tg_curr_read_check_en;
   reg 					   tg_curr_read_cmd;
   reg 					   tg_curr_write_cmd;
   reg 					   tg_curr_nxt_rwwait;
   
   reg 					   tg_curr_write_nop_state;
   reg [9:0] 				   tg_curr_write_nop_cnt;
   reg [31:0] 				   tg_curr_write_burst_cnt;   
   reg [9:0] 				   tg_curr_read_nop_cnt;
   reg [31:0] 				   tg_curr_read_burst_cnt;      
   reg 					   tg_curr_read_nop_state;

   wire 				   tg_xload_done;
   reg [4:0] 				   tg_xload_cnt;
   
   // Exe - sending traffic pattern to app interface
   wire 				   write_pattern_valid;
   wire [APP_DATA_WIDTH-1:0] 		   write_pattern;
   reg 					   write_data_valid;
   reg [APP_DATA_WIDTH-1:0] 		   write_data;
   wire 				   write_addr_valid;
   wire 				   write_addr_repeat;
   wire [APP_ADDR_WIDTH/CMD_PER_CLK-1:0]   write_addr[CMD_PER_CLK];
   
   wire 				   read_addr_valid;
   wire 				   read_addr_repeat;
   wire [APP_ADDR_WIDTH/CMD_PER_CLK-1:0]   read_addr[CMD_PER_CLK];
   wire 				   exp_read_addr_valid;
   wire [CMD_PER_CLK-1:0] 		   exp_read_addr_valid_vec;
   wire 				   exp_read_addr_repeat;
   wire [APP_ADDR_WIDTH/CMD_PER_CLK-1:0]   exp_read_addr[CMD_PER_CLK];
   
   wire 				   exp_read_pattern_valid;
   wire [APP_DATA_WIDTH-1:0] 		   exp_read_pattern;
   wire 				   exp_read_data_valid;
   wire [CMD_PER_CLK-1:0] 		   exp_read_data_valid_vec;
   wire [APP_DATA_WIDTH-1:0] 		   exp_read_data;
   
   reg [CMD_PER_CLK-1:0] 		   app_rd_data_valid_r;
   reg [APP_DATA_WIDTH-1:0] 		   app_rd_data_r;
   
   wire 			exe_app_write_en;   
   wire 			exe_app_read_en;
   wire 				   exe_app_en;
   wire 				   err_app_en;
   wire 			tg_write_rdy;
   wire 			tg_read_rdy;   

   // Err check - Error detection
   wire 				   tg_errchk_found;
   wire 				   tg_errchk_done;
   reg [2:0] 				   tg_wait_state_cnt;
   wire 				   tg_wait_state_done;
   reg 					   tg_err_clear;
   reg 					   tg_err_clear_r;
   reg 					   instr_err_clear;
   reg 					   tg_err_clear_all;
   reg 					   tg_err_clear_all_r;
   reg 					   instr_err_clear_all;
   reg 					   tg_err_continue;
   reg 					   tg_err_continue_r;
   wire 				   instr_err_continue;
   
   wire 				   tg_read_test_en;   
   wire 				   tg_read_test_done;
   wire 				   tg_read_test_valid;
   wire [APP_ADDR_WIDTH-1:0] 		   tg_read_test_addr;
   
   genvar 				   tg_i;

   // MCP simulation signals
   reg [3:0] 			 tg_instr_addr_mode_mcp[TG_INSTR_TBL_DEPTH-1:0];
   reg [3:0] 			 tg_instr_data_mode_mcp[TG_INSTR_TBL_DEPTH-1:0];
   reg [3:0] 			 tg_instr_rw_mode_mcp[TG_INSTR_TBL_DEPTH-1:0];
   reg [1:0] 			 tg_instr_rw_submode_mcp[TG_INSTR_TBL_DEPTH-1:0];
   reg [2:0] 			 tg_instr_victim_mode_mcp[TG_INSTR_TBL_DEPTH-1:0];
   reg [31:0] 			 tg_instr_num_of_iter_mcp[TG_INSTR_TBL_DEPTH-1:0];
   reg [9:0] 			 tg_instr_m_nops_btw_n_burst_m_mcp[TG_INSTR_TBL_DEPTH-1:0];
   reg [31:0] 			 tg_instr_m_nops_btw_n_burst_n_mcp[TG_INSTR_TBL_DEPTH-1:0];
   reg [TG_INSTR_PTR_WIDTH-1:0]  tg_instr_nxt_instr_mcp[TG_INSTR_TBL_DEPTH-1:0];

   reg [7:0] 			 tg_glb_victim_bit_mcp;     
   reg [4:0] 			 tg_glb_victim_aggr_delay_mcp;
   reg [APP_ADDR_WIDTH/CMD_PER_CLK-1:0] 	 tg_glb_start_addr_mcp;
   
   reg 				 tg_instr_start_s_p2_mcp;   
   reg 				 tg_instr_load_s_p2_mcp;
   reg 				 tg_instr_rwload_s_p2_mcp;
   reg [TG_INSTR_PTR_WIDTH-1:0]  tg_curr_instr_ptr_mcp;
   reg [3:0] 			 tg_curr_addr_mode_mcp;
   reg [3:0] 			 tg_curr_data_mode_mcp;
   reg [3:0] 			 tg_curr_rw_mode_mcp;
   reg [1:0] 			 tg_curr_rw_submode_mcp;
   reg [2:0] 			 tg_curr_victim_mode_mcp;
   reg [31:0] 			 tg_curr_num_of_iter_mcp;
   reg [31:0] 			 tg_curr_num_of_iter_minus1_mcp;
   reg [9:0] 			 tg_curr_m_nops_btw_n_burst_m_mcp;
   reg [31:0] 			 tg_curr_m_nops_btw_n_burst_n_mcp;
   reg [TG_INSTR_PTR_WIDTH-1:0]  tg_curr_nxt_instr_mcp;
   reg 				 tg_curr_read_cmd_mcp;
   reg 				 tg_curr_write_cmd_mcp;
   reg 				 tg_curr_nxt_rwwait_mcp;           
   
//`define MCP_CHECK_DISABLE   
`ifdef SIMULATION
 `ifndef MCP_CHECK_DISABLE
  `define MCP_SIM
 `endif
`endif

`ifdef MCP_SIM
//   generate
//      for (tg_i=0; tg_i<TG_INSTR_TBL_DEPTH; tg_i=tg_i+1) begin: tg_instr_mcp
//	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,tg_i,4);
//	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,tg_i,4);
//	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,tg_i,4);
//	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,tg_i,4);
//	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,tg_i,4);
//	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,tg_i,4);
//	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,tg_i,4);
//	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,tg_i,4);
//      end
//   endgenerate
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,0,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,0,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,0,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,0,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,0,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,0,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,0,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,0,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,0,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,1,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,1,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,1,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,1,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,1,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,1,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,1,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,1,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,1,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,2,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,2,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,2,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,2,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,2,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,2,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,2,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,2,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,2,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,3,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,3,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,3,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,3,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,3,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,3,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,3,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,3,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,3,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,4,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,4,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,4,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,4,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,4,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,4,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,4,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,4,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,4,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,5,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,5,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,5,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,5,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,5,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,5,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,5,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,5,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,5,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,6,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,6,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,6,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,6,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,6,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,6,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,6,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,6,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,6,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,7,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,7,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,7,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,7,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,7,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,7,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,7,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,7,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,7,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,8,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,8,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,8,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,8,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,8,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,8,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,8,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,8,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,8,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,9,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,9,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,9,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,9,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,9,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,9,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,9,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,9,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,9,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,10,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,10,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,10,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,10,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,10,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,10,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,10,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,10,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,10,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,11,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,11,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,11,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,11,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,11,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,11,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,11,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,11,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,11,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,12,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,12,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,12,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,12,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,12,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,12,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,12,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,12,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,12,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,13,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,13,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,13,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,13,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,13,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,13,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,13,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,13,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,13,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,14,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,14,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,14,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,14,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,14,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,14,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,14,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,14,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,14,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,15,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,15,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,15,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,15,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,15,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,15,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,15,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,15,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,15,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,16,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,16,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,16,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,16,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,16,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,16,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,16,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,16,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,16,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,17,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,17,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,17,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,17,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,17,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,17,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,17,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,17,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,17,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,18,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,18,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,18,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,18,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,18,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,18,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,18,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,18,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,18,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,19,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,19,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,19,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,19,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,19,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,19,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,19,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,19,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,19,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,20,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,20,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,20,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,20,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,20,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,20,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,20,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,20,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,20,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,21,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,21,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,21,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,21,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,21,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,21,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,21,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,21,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,21,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,22,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,22,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,22,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,22,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,22,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,22,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,22,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,22,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,22,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,23,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,23,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,23,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,23,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,23,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,23,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,23,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,23,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,23,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,24,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,24,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,24,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,24,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,24,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,24,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,24,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,24,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,24,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,25,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,25,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,25,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,25,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,25,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,25,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,25,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,25,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,25,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,26,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,26,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,26,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,26,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,26,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,26,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,26,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,26,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,26,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,27,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,27,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,27,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,27,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,27,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,27,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,27,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,27,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,27,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,28,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,28,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,28,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,28,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,28,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,28,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,28,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,28,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,28,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,29,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,29,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,29,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,29,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,29,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,29,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,29,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,29,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,29,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,30,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,30,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,30,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,30,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,30,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,30,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,30,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,30,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,30,4);
	 `MCP2D(tg_instr_addr_mode,tg_instr_addr_mode_mcp,4,31,4);
	 `MCP2D(tg_instr_data_mode,tg_instr_data_mode_mcp,4,31,4);
	 `MCP2D(tg_instr_rw_mode,tg_instr_rw_mode_mcp,4,31,4);
	 `MCP2D(tg_instr_rw_submode,tg_instr_rw_submode_mcp,2,31,4);
	 `MCP2D(tg_instr_victim_mode,tg_instr_victim_mode_mcp,3,31,4);
	 `MCP2D(tg_instr_num_of_iter,tg_instr_num_of_iter_mcp,32,31,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_m,tg_instr_m_nops_btw_n_burst_m_mcp,10,31,4);
	 `MCP2D(tg_instr_m_nops_btw_n_burst_n,tg_instr_m_nops_btw_n_burst_n_mcp,32,31,4);
	 `MCP2D(tg_instr_nxt_instr,tg_instr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,31,4);

   `MCP(tg_glb_victim_bit,tg_glb_victim_bit_mcp,8,4);
   `MCP(tg_glb_victim_aggr_delay,tg_glb_victim_aggr_delay_mcp,5,4);
   `MCP(tg_glb_start_addr,tg_glb_start_addr_mcp,APP_ADDR_WIDTH/CMD_PER_CLK,4);
   
   `MCP(tg_instr_start_s_p2,tg_instr_start_s_p2_mcp,1,4);
   `MCP(tg_instr_load_s_p2,tg_instr_load_s_p2_mcp,1,4);
   `MCP(tg_instr_rwload_s_p2,tg_instr_rwload_s_p2_mcp,1,4);
   `MCP(tg_curr_instr_ptr,tg_curr_instr_ptr_mcp,TG_INSTR_PTR_WIDTH,4);
   `MCP(tg_curr_addr_mode,tg_curr_addr_mode_mcp,4,4);
   `MCP(tg_curr_data_mode,tg_curr_data_mode_mcp,4,4);   
   `MCP(tg_curr_rw_mode,tg_curr_rw_mode_mcp,4,4);   
   `MCP(tg_curr_rw_submode,tg_curr_rw_submode_mcp,2,4);
   `MCP(tg_curr_victim_mode,tg_curr_victim_mode_mcp,3,4);   
   `MCP(tg_curr_num_of_iter,tg_curr_num_of_iter_mcp,32,4);   
   `MCP(tg_curr_num_of_iter_minus1,tg_curr_num_of_iter_minus1_mcp,32,4);   
   `MCP(tg_curr_m_nops_btw_n_burst_m,tg_curr_m_nops_btw_n_burst_m_mcp,10,4);
   `MCP(tg_curr_m_nops_btw_n_burst_n,tg_curr_m_nops_btw_n_burst_n_mcp,32,4);
   `MCP(tg_curr_nxt_instr,tg_curr_nxt_instr_mcp,TG_INSTR_PTR_WIDTH,4);
   `MCP(tg_curr_read_cmd,tg_curr_read_cmd_mcp,1,4);
   `MCP(tg_curr_write_cmd,tg_curr_write_cmd_mcp,1,4);
   `MCP(tg_curr_nxt_rwwait,tg_curr_nxt_rwwait_mcp,1,4);
`else // !`ifdef SIMULATION
   assign tg_instr_addr_mode = tg_instr_addr_mode_mcp;
   assign tg_instr_data_mode = tg_instr_data_mode_mcp;
   assign tg_instr_rw_mode   = tg_instr_rw_mode_mcp;
   assign tg_instr_rw_submode  = tg_instr_rw_submode_mcp;
   assign tg_instr_victim_mode = tg_instr_victim_mode_mcp;
   assign tg_instr_num_of_iter = tg_instr_num_of_iter_mcp;
   assign tg_instr_m_nops_btw_n_burst_m = tg_instr_m_nops_btw_n_burst_m_mcp;
   assign tg_instr_m_nops_btw_n_burst_n = tg_instr_m_nops_btw_n_burst_n_mcp;
   assign tg_instr_nxt_instr = tg_instr_nxt_instr_mcp;
   
   assign tg_glb_victim_bit    = tg_glb_victim_bit_mcp;
   assign tg_glb_victim_aggr_delay = tg_glb_victim_aggr_delay_mcp;
   assign tg_glb_start_addr    = tg_glb_start_addr_mcp;

   assign tg_instr_start_s_p2  = tg_instr_start_s_p2_mcp;
   assign tg_instr_load_s_p2   = tg_instr_load_s_p2_mcp;
   assign tg_instr_rwload_s_p2 = tg_instr_rwload_s_p2_mcp;
   assign tg_curr_instr_ptr    = tg_curr_instr_ptr_mcp;
   assign tg_curr_addr_mode    = tg_curr_addr_mode_mcp;		   
   assign tg_curr_data_mode    = tg_curr_data_mode_mcp;		   
   assign tg_curr_rw_mode      = tg_curr_rw_mode_mcp;		   
   assign tg_curr_rw_submode   = tg_curr_rw_submode_mcp;		   
   assign tg_curr_victim_mode  = tg_curr_victim_mode_mcp;	   
   assign tg_curr_num_of_iter  = tg_curr_num_of_iter_mcp;	   
   assign tg_curr_num_of_iter_minus1   = tg_curr_num_of_iter_minus1_mcp;   
   assign tg_curr_m_nops_btw_n_burst_m = tg_curr_m_nops_btw_n_burst_m_mcp; 
   assign tg_curr_m_nops_btw_n_burst_n = tg_curr_m_nops_btw_n_burst_n_mcp; 
   assign tg_curr_nxt_instr    = tg_curr_nxt_instr_mcp;		   
   assign tg_curr_read_cmd     = tg_curr_read_cmd_mcp;		   
   assign tg_curr_write_cmd    = tg_curr_write_cmd_mcp;		   
   assign tg_curr_nxt_rwwait   = tg_curr_nxt_rwwait_mcp;           
`endif // !`ifdef SIMULATION
   
   assign tg_rw_submode        = tg_curr_rw_submode;
   
   // *************************************************************************
   // Populate Instruction Table
   // - vio_tg_instr_program_en enables instruction table programming.
   // - tg_instr_num selects which tg_instruction entry  to be programmed.
   //   the selected instruction entry will be modified by all associated vio_tg_instr* registers 
   // *************************************************************************   

   always@(posedge tg_clk) begin
      if (tg_rst) begin
	 tg_rst_int[VIO_TG_RST_WIDTH_FO-1:0] <= #TCQ {VIO_TG_RST_WIDTH_FO{1'b0}};
      end
      else begin
	 tg_rst_int[VIO_TG_RST_WIDTH_FO-1:0] <= #TCQ {VIO_TG_RST_WIDTH_FO{vio_tg_rst}};
      end
   end

   always@(posedge tg_clk) begin
      if (tg_rst | tg_rst_int[0]) begin
	 tg_instr_num        <= #TCQ 'h0;
	 tg_instr_program_en <= #TCQ 'h0;
      end
      else begin
	 tg_instr_num        <= #TCQ vio_tg_instr_num;
	 tg_instr_program_en <= #TCQ vio_tg_instr_program_en;
      end
   end

   generate
      for (tg_i=0; tg_i<TG_INSTR_TBL_DEPTH; tg_i=tg_i+1) begin: tg_instr_init
	 always@(posedge tg_clk) begin
	    if (tg_rst | tg_rst_int[1]) begin
	       // Default traffic table programming after reset
	       tg_instr_addr_mode_mcp[tg_i]             <= #TCQ bram_instr_addr_mode[tg_i];
	       tg_instr_data_mode_mcp[tg_i]             <= #TCQ bram_instr_data_mode[tg_i];
	       tg_instr_rw_mode_mcp[tg_i]               <= #TCQ bram_instr_rw_mode[tg_i];
	       tg_instr_rw_submode_mcp[tg_i]            <= #TCQ bram_instr_rw_submode[tg_i];
	       tg_instr_victim_mode_mcp[tg_i]           <= #TCQ bram_instr_victim_mode[tg_i];
	       tg_instr_num_of_iter_mcp[tg_i]           <= #TCQ bram_instr_num_of_iter[tg_i];
	       tg_instr_m_nops_btw_n_burst_m_mcp[tg_i]  <= #TCQ bram_instr_m_nops_btw_n_burst_m[tg_i];
	       tg_instr_m_nops_btw_n_burst_n_mcp[tg_i]  <= #TCQ bram_instr_m_nops_btw_n_burst_n[tg_i];
	       tg_instr_nxt_instr_mcp[tg_i]             <= #TCQ bram_instr_nxt_instr[tg_i];	       
	    end
	    else if (tg_instr_program_en && (tg_instr_num == tg_i)) begin
	       // If there is a valid tg_instr_num, write the corresponding instruction into local register
	       tg_instr_addr_mode_mcp[tg_i]             <= #TCQ vio_tg_instr_addr_mode;
	       tg_instr_data_mode_mcp[tg_i]             <= #TCQ vio_tg_instr_data_mode;
	       tg_instr_rw_mode_mcp[tg_i]               <= #TCQ vio_tg_instr_rw_mode;
	       tg_instr_rw_submode_mcp[tg_i]            <= #TCQ vio_tg_instr_rw_submode;
	       tg_instr_victim_mode_mcp[tg_i]           <= #TCQ vio_tg_instr_victim_mode;
	       tg_instr_num_of_iter_mcp[tg_i]           <= #TCQ vio_tg_instr_num_of_iter;
	       tg_instr_m_nops_btw_n_burst_m_mcp[tg_i]  <= #TCQ vio_tg_instr_m_nops_btw_n_burst_m;
	       tg_instr_m_nops_btw_n_burst_n_mcp[tg_i]  <= #TCQ vio_tg_instr_m_nops_btw_n_burst_n;
	       tg_instr_nxt_instr_mcp[tg_i]             <= #TCQ vio_tg_instr_nxt_instr;
	    end
	 end
      end
   endgenerate

   // Instruction Table BRAM
   qdriip_v1_4_19_tg_instr_bram
     #(
       .MEM_TYPE(MEM_TYPE),
       .SIMULATION(SIMULATION),
       .TCQ(TCQ),
       .TG_INSTR_TBL_DEPTH(TG_INSTR_TBL_DEPTH),
       .TG_INSTR_PTR_WIDTH(TG_INSTR_PTR_WIDTH),
       .TG_INSTR_NUM_OF_ITER_WIDTH(TG_INSTR_NUM_OF_ITER_WIDTH),
       .TG_MAX_NUM_OF_ITER_ADDR(TG_MAX_NUM_OF_ITER_ADDR),
       .DEFAULT_MODE(DEFAULT_MODE)
       )
   u_qdriip_v1_4_19_tg_instr_bram
     (
      .tg_glb_qdriv_rw_submode(vio_tg_glb_qdriv_rw_submode),
      .bram_instr_addr_mode(bram_instr_addr_mode),
      .bram_instr_data_mode(bram_instr_data_mode),
      .bram_instr_rw_mode(bram_instr_rw_mode),
      .bram_instr_rw_submode(bram_instr_rw_submode),
      .bram_instr_victim_mode(bram_instr_victim_mode),
      .bram_instr_num_of_iter(bram_instr_num_of_iter),
      .bram_instr_m_nops_btw_n_burst_m(bram_instr_m_nops_btw_n_burst_m),
      .bram_instr_m_nops_btw_n_burst_n(bram_instr_m_nops_btw_n_burst_n),
      .bram_instr_nxt_instr(bram_instr_nxt_instr)
      );
   
   // *************************************************************************
   // TG Main State machine
   // *************************************************************************    
   // Need to fix last write / last read with iteration based on address width, to prevent data overwritten on same address
   wire last_read_done1;
   wire last_write_done1;
   reg last_read_done2;
   reg last_write_done2;   
   wire last_read_done;   
   wire last_write_done;
   wire write_read_done;
   reg write_read_done_r;
   
   wire 						  app_write_fifo_empty;
   wire 						  app_write_fifo_full;
   wire 						  app_write_fifo_wren;
   wire 						  app_write_fifo_rden;
   reg 							  app_write_fifo_rden_r;
   wire [1+APP_DATA_WIDTH+APP_ADDR_WIDTH+APP_CMD_WIDTH-1:0] app_write_fifo_dout;
   wire [APP_CMD_WIDTH-1:0] 				  app_write_fifo_cmd;
   wire [APP_ADDR_WIDTH-1:0] 				  app_write_fifo_addr;
   wire 						  app_write_fifo_addr_repeat;
   
   wire 						  app_read_fifo_empty;
   wire 						  app_read_fifo_full;
   wire 						  app_read_fifo_wren;
   wire 						  app_read_fifo_rden;
   reg 							  app_read_fifo_rden_r;
   wire [APP_ADDR_WIDTH+APP_CMD_WIDTH-1:0] 		  app_read_fifo_dout;
   wire [APP_CMD_WIDTH-1:0] 				  app_read_fifo_cmd;
   wire [APP_ADDR_WIDTH-1:0] 				  app_read_fifo_addr;

   reg 							  last_read_almost_done;
   reg 							  last_write_almost_done;
   
   always@(posedge tg_clk) begin
      app_write_fifo_rden_r <= #TCQ app_write_fifo_rden;
      app_read_fifo_rden_r  <= #TCQ app_read_fifo_rden;      
   end
   
   always@(posedge tg_clk) begin
      if (tg_instr_load_s_p2 | tg_instr_rwload_s_p2) begin
	 last_read_almost_done  <= #TCQ 'h0;
	 last_write_almost_done <= #TCQ 'h0;
	 //last_read_done1        <= #TCQ 'h0;
	 //last_write_done1       <= #TCQ 'h0;
	 last_read_done2        <= #TCQ 'h0;
	 last_write_done2       <= #TCQ 'h0;
      end
      else begin
	 // Timing Fix:
	 // Added extra stage to flop N-1 count condition
	 last_read_almost_done  <= #TCQ
				   ((tg_curr_num_of_iter_rd_cnt[31:24] == tg_curr_num_of_iter_minus1[31:24]) &&
				    (tg_curr_num_of_iter_rd_cnt[23:16] == tg_curr_num_of_iter_minus1[23:16]) &&
				    (tg_curr_num_of_iter_rd_cnt[15:8]  == tg_curr_num_of_iter_minus1[15:8]) &&
	   			    (tg_curr_num_of_iter_rd_cnt[7:0]   == tg_curr_num_of_iter_minus1[7:0]));
	 last_write_almost_done <= #TCQ
				   ((tg_curr_num_of_iter_wr_cnt[31:24] == tg_curr_num_of_iter_minus1[31:24]) &&
				    (tg_curr_num_of_iter_wr_cnt[23:16] == tg_curr_num_of_iter_minus1[23:16]) &&
				    (tg_curr_num_of_iter_wr_cnt[15:8]  == tg_curr_num_of_iter_minus1[15:8]) &&
	   			    (tg_curr_num_of_iter_wr_cnt[7:0]   == tg_curr_num_of_iter_minus1[7:0]));
	 last_read_done2        <= #TCQ last_read_done2  | (tg_instr_exe_s_r && last_read_almost_done  && (app_read_fifo_rden  || app_read_fifo_rden_r));
	 last_write_done2       <= #TCQ last_write_done2 | (tg_instr_exe_s_r && last_write_almost_done && (app_write_fifo_rden || app_write_fifo_rden_r));
      end
   end
   assign last_read_done1        = last_read_almost_done  && app_read_fifo_rden_r;
   assign last_write_done1       = last_write_almost_done && app_write_fifo_rden_r;   
   assign last_read_done         = last_read_done1  || last_read_done2;
   assign last_write_done        = last_write_done1 || last_write_done2;   
   
   assign write_read_done = (~tg_curr_read_cmd && ~tg_curr_write_cmd) ||
			    (~tg_curr_read_cmd &&  tg_curr_write_cmd && last_write_done) ||
			    ( tg_curr_read_cmd && ~tg_curr_write_cmd && last_read_done) ||
			    ( tg_curr_read_cmd &&  tg_curr_write_cmd && last_read_done && last_write_done);
      
   always@(posedge tg_clk) begin
      if (tg_instr_dinit_s) begin
	 write_read_done_r <= #TCQ 1'b0;
      end
      else if ((tg_instr_exe_s || tg_instr_pausewait_s || tg_instr_errwait_s) && write_read_done) begin
	 write_read_done_r <= #TCQ 1'b1;
      end
   end
   
   // State Arcs
   assign arc_tg_instr_start_start    = instr_restart;
   assign arc_tg_instr_start_load     = tg_xload_done && tg_calib_complete && tg_start; 
   assign arc_tg_instr_load_dinit     = tg_xload_done; // N cycles to load next instruction
   assign arc_tg_instr_dinit_exe      = exp_read_data_valid && exp_read_addr_valid;

   assign arc_tg_instr_exe_ldwait     = write_read_done && ~tg_curr_nxt_rwwait &&
					~tg_curr_nxt_instr[TG_INSTR_PTR_WIDTH-1]; // Done with current instruction, load next instruction
   assign arc_tg_instr_exe_rwwait     = write_read_done && tg_curr_nxt_rwwait; // Done with part of the current instruction, update command read/write
   assign arc_tg_instr_exe_dnwait     = write_read_done && ~tg_curr_nxt_rwwait &&
					tg_curr_nxt_instr[TG_INSTR_PTR_WIDTH-1]; // Done with all instruction
//   assign arc_tg_instr_exe_ldwait     = write_read_done && app_fifo_empty && ~tg_curr_nxt_rwwait &&
//					~tg_curr_nxt_instr[TG_INSTR_PTR_WIDTH-1]; // Done with current instruction, load next instruction
//   assign arc_tg_instr_exe_rwwait     = write_read_done && app_fifo_empty && tg_curr_nxt_rwwait; // Done with part of the current instruction, update command read/write
//   assign arc_tg_instr_exe_dnwait     = write_read_done && app_fifo_empty && ~tg_curr_nxt_rwwait &&
//					tg_curr_nxt_instr[TG_INSTR_PTR_WIDTH-1]; // Done with all instruction
   
   assign arc_tg_instr_rwload_dinit   = tg_xload_done; // N cycles to transition from Write state to Read state
   assign arc_tg_instr_exe_errwait    = vio_tg_err_chk_en && tg_errchk_found; // Transition to Err state upon error detected
   assign arc_tg_instr_ldwait_load    = tg_errchk_done && tg_wait_state_done || (tg_curr_write_cmd && ~tg_curr_read_cmd); // Wait for all read error check completion before load
   assign arc_tg_instr_rwwait_rwload  = tg_errchk_done && tg_wait_state_done || (tg_curr_write_cmd && ~tg_curr_read_cmd); // Wait for all read error check completion before rwload
   assign arc_tg_instr_dnwait_done    = tg_errchk_done && tg_wait_state_done || (tg_curr_write_cmd && ~tg_curr_read_cmd); // Wait for all read error check completion before done
   assign arc_tg_instr_ldwait_errwait = vio_tg_err_chk_en && tg_errchk_found; // Transition to Err state upon error detected
   assign arc_tg_instr_rwwait_errwait = vio_tg_err_chk_en && tg_errchk_found; // Transition to Err state upon error detected
   assign arc_tg_instr_dnwait_errwait = vio_tg_err_chk_en && tg_errchk_found; // Transition to Err state upon error detected
   
   assign arc_tg_instr_exe_pausewait  = vio_tg_pause; // Pause / Restart
   assign arc_tg_instr_pausewait_pause = tg_errchk_done && tg_wait_state_done;
   assign arc_tg_instr_pause_exe      = ~vio_tg_pause;
   assign arc_tg_instr_pause_start    = instr_restart;

   assign arc_tg_instr_done_start     = instr_restart; // user restart TG

   assign arc_tg_instr_errwait_errchk = tg_errchk_done && tg_wait_state_done; // Wait for all outstanding read error check completion before read test
   assign arc_tg_instr_errchk_errdone = tg_read_test_done; // Wait for read test done
   assign arc_tg_instr_errdone_start  = instr_restart; // user restart TG
   assign arc_tg_instr_errdone_exe    = instr_err_continue && ~write_read_done_r; // user continue on execution after read test is done
   assign arc_tg_instr_errdone_done   = instr_err_continue && write_read_done_r && ~tg_curr_nxt_rwwait &&
					tg_curr_nxt_instr[TG_INSTR_PTR_WIDTH-1]; // This is a special case when read reached end count while in errwait state. SM needs to transition to done/load/rwload depends on current instruction
   assign arc_tg_instr_errdone_load   = instr_err_continue && write_read_done_r && ~tg_curr_nxt_rwwait &&
					~tg_curr_nxt_instr[TG_INSTR_PTR_WIDTH-1]; // This is a special case when read reached end count while in errwait state. SM needs to transition to done/load/rwload depends on current instruction
   assign arc_tg_instr_errdone_rwload = instr_err_continue && write_read_done_r && tg_curr_nxt_rwwait; // This is a special case when read reached end count while in errwait state. SM needs to transition to done/load/rwload depends on current instruction
   
   always@(posedge tg_clk) begin
      if (tg_rst | tg_rst_int[2]) begin
	 tg_instr_sm_ps <= #TCQ TG_INSTR_START;
	 tg_instr_start_s   <= #TCQ 1'b1;
	 tg_instr_load_s    <= #TCQ 1'b0;
	 tg_instr_dinit_s   <= #TCQ 1'b0;
	 tg_instr_exe_s     <= #TCQ 1'b0;
	 tg_instr_rwload_s  <= #TCQ 1'b0;
	 tg_instr_errchk_s  <= #TCQ 1'b0;
	 tg_instr_pause_s   <= #TCQ 1'b0;
	 tg_instr_pausewait_s <= #TCQ 1'b0;
	 tg_instr_ldwait_s  <= #TCQ 1'b0;
	 tg_instr_dnwait_s  <= #TCQ 1'b0;
	 tg_instr_done_s    <= #TCQ 1'b0;
	 tg_instr_errwait_s <= #TCQ 1'b0;
	 tg_instr_rwwait_s  <= #TCQ 1'b0;
	 tg_instr_errdone_s <= #TCQ 1'b0;	 
      end
      else begin
	 casez (tg_instr_sm_ps)
	   TG_INSTR_START:
	     begin
		if (arc_tg_instr_start_load) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_LOAD;
		   tg_instr_start_s <= #TCQ 1'b0;
		   tg_instr_load_s  <= #TCQ 1'b1;
		end
		else if (arc_tg_instr_start_start) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_START;
		   tg_instr_start_s <= #TCQ 1'b1;		   
		end
	     end
	   TG_INSTR_LOAD:
	     begin
		if (arc_tg_instr_load_dinit) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_DINIT;
		   tg_instr_load_s <= #TCQ 1'b0;
		   tg_instr_dinit_s  <= #TCQ 1'b1;
		end
	     end
	   TG_INSTR_DINIT:
	     begin
		if (arc_tg_instr_dinit_exe) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_EXE;
		   tg_instr_dinit_s <= #TCQ 1'b0;
		   tg_instr_exe_s  <= #TCQ 1'b1;
		end
	     end
	   TG_INSTR_EXE:
	     begin
		if (arc_tg_instr_exe_dnwait) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_DNWAIT;
		   tg_instr_exe_s <= #TCQ 1'b0;
		   tg_instr_dnwait_s  <= #TCQ 1'b1;
		end
		else if (arc_tg_instr_exe_ldwait) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_LDWAIT;
		   tg_instr_exe_s <= #TCQ 1'b0;
		   tg_instr_ldwait_s  <= #TCQ 1'b1;
		end
		else if (arc_tg_instr_exe_rwwait) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_RWWAIT;
		   tg_instr_exe_s <= #TCQ 1'b0;
		   tg_instr_rwwait_s  <= #TCQ 1'b1;
		end
		else if (arc_tg_instr_exe_errwait) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_ERRWAIT;		   
		   tg_instr_exe_s <= #TCQ 1'b0;
		   tg_instr_errwait_s  <= #TCQ 1'b1;
		end		
		else if (arc_tg_instr_exe_pausewait) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_PAUSEWAIT;		   
		   tg_instr_exe_s <= #TCQ 1'b0;
		   tg_instr_pausewait_s  <= #TCQ 1'b1;
		end
	     end
	   TG_INSTR_RWWAIT:
	     begin
		if (arc_tg_instr_rwwait_errwait) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_ERRWAIT;		   
		   tg_instr_rwwait_s <= #TCQ 1'b0;
		   tg_instr_errwait_s  <= #TCQ 1'b1;
		end
		else if (arc_tg_instr_rwwait_rwload) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_RWLOAD;
		   tg_instr_rwwait_s <= #TCQ 1'b0;
		   tg_instr_rwload_s  <= #TCQ 1'b1;
		end
	     end
	   TG_INSTR_RWLOAD:
	     begin
		if (arc_tg_instr_rwload_dinit) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_DINIT;
		   tg_instr_rwload_s <= #TCQ 1'b0;
		   tg_instr_dinit_s  <= #TCQ 1'b1;
		end
	     end
	   TG_INSTR_ERRWAIT:
	     begin
		if (arc_tg_instr_errwait_errchk) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_ERRCHK;
		   tg_instr_errwait_s <= #TCQ 1'b0;
		   tg_instr_errchk_s  <= #TCQ 1'b1;
		end
	     end
	   TG_INSTR_ERRCHK:
	     begin
		if (arc_tg_instr_errchk_errdone) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_ERRDONE;
		   tg_instr_errchk_s <= #TCQ 1'b0;
		   tg_instr_errdone_s  <= #TCQ 1'b1;
		end
	     end
	   TG_INSTR_ERRDONE:
	     begin
		if (arc_tg_instr_errdone_start) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_START;
		   tg_instr_errdone_s <= #TCQ 1'b0;
		   tg_instr_start_s  <= #TCQ 1'b1;
		end
		else if (arc_tg_instr_errdone_exe) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_EXE;
		   tg_instr_errdone_s <= #TCQ 1'b0;
		   tg_instr_exe_s  <= #TCQ 1'b1;
		end
		else if (arc_tg_instr_errdone_done) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_DONE;
		   tg_instr_errdone_s <= #TCQ 1'b0;
		   tg_instr_done_s  <= #TCQ 1'b1;
		end
		else if (arc_tg_instr_errdone_load) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_LOAD;
		   tg_instr_errdone_s <= #TCQ 1'b0;
		   tg_instr_load_s  <= #TCQ 1'b1;
		end
		else if (arc_tg_instr_errdone_rwload) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_RWLOAD;
		   tg_instr_errdone_s <= #TCQ 1'b0;
		   tg_instr_rwload_s  <= #TCQ 1'b1;
		end
	     end	   
	   TG_INSTR_PAUSEWAIT:
	     begin
		if (arc_tg_instr_pausewait_pause) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_PAUSE;
		   tg_instr_pausewait_s <= #TCQ 1'b0;
		   tg_instr_pause_s     <= #TCQ 1'b1;
		end
	     end
	   TG_INSTR_PAUSE:
	     begin
		if (arc_tg_instr_pause_start) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_START;
		   tg_instr_pause_s <= #TCQ 1'b0;
		   tg_instr_start_s  <= #TCQ 1'b1;
		end
		else if (arc_tg_instr_pause_exe) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_EXE;
		   tg_instr_pause_s <= #TCQ 1'b0;
		   tg_instr_exe_s  <= #TCQ 1'b1;
		end
	     end
	   TG_INSTR_DNWAIT:
	     begin
		if (arc_tg_instr_dnwait_errwait) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_ERRWAIT;		   
		   tg_instr_dnwait_s <= #TCQ 1'b0;
		   tg_instr_errwait_s  <= #TCQ 1'b1;
		end
		else if (arc_tg_instr_dnwait_done) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_DONE;
		   tg_instr_dnwait_s <= #TCQ 1'b0;
		   tg_instr_done_s  <= #TCQ 1'b1;
		end
	     end	   
	   TG_INSTR_LDWAIT:
	     begin
		if (arc_tg_instr_ldwait_errwait) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_ERRWAIT;		   
		   tg_instr_ldwait_s <= #TCQ 1'b0;
		   tg_instr_errwait_s  <= #TCQ 1'b1;		
		end
		else if (arc_tg_instr_ldwait_load) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_LOAD;
		   tg_instr_ldwait_s <= #TCQ 1'b0;
		   tg_instr_load_s  <= #TCQ 1'b1;
		end
	     end
	   TG_INSTR_DONE:
	     begin
		if (arc_tg_instr_done_start) begin
		   tg_instr_sm_ps <= #TCQ TG_INSTR_START;
		   tg_instr_done_s <= #TCQ 1'b0;
		   tg_instr_start_s  <= #TCQ 1'b1;
		end
	     end	   
	   default:
	     begin
		$display ("tg_instr_sm_ps: UNKNOWN STATE ERROR - STATE HEX=%x\n", tg_instr_sm_ps);
	     end
	 endcase
      end
   end

   // Load and Reload timer
   always@(posedge tg_clk) begin
      if (tg_rst || tg_rst_int[3] || ~tg_calib_complete || tg_xload_done) begin
	 tg_xload_cnt  <= #TCQ 'h0;
      end
      else if (tg_instr_start_s || tg_instr_load_s || tg_instr_rwload_s) begin
	 tg_xload_cnt  <= #TCQ tg_xload_cnt + 'h1;	 
      end
   end
   assign tg_xload_done = (tg_xload_cnt == 5'd31); // give enough cycles for load or rwload to reset all read/write pattern engines
   
   always@(posedge tg_clk) begin
      if (tg_rst || tg_rst_int[3]) begin
	 tg_instr_start_s_r   <= #TCQ 1'h0;
	 tg_instr_start_s_p   <= #TCQ 1'h0;
	 tg_instr_load_s_r    <= #TCQ 1'h0;
	 tg_instr_load_s_p    <= #TCQ 1'h0;	 
	 tg_instr_rwload_s_r  <= #TCQ 1'h0;
	 tg_instr_rwload_s_p  <= #TCQ 1'h0;

	 //`ifdef SIMULATION
	 tg_instr_start_s_p2_mcp  <= #TCQ 1'h0;
	 tg_instr_load_s_p2_mcp   <= #TCQ 1'h0;
	 tg_instr_rwload_s_p2_mcp <= #TCQ 1'h0;	 
	 //`else
	 //tg_instr_start_s_p2  <= #TCQ 1'h0;
	 //tg_instr_load_s_p2   <= #TCQ 1'h0;
	 //tg_instr_rwload_s_p2 <= #TCQ 1'h0;
	 //`endif
	 
	 tg_instr_exe_s_r     <= #TCQ 1'h0;
      end
      else begin
	 tg_instr_start_s_r   <= #TCQ tg_instr_start_s;
	 tg_instr_start_s_p   <= #TCQ tg_instr_start_s  && (tg_xload_cnt >= 5'd8) && (tg_xload_cnt < 5'd16);
	 tg_instr_load_s_r    <= #TCQ tg_instr_load_s;
	 tg_instr_load_s_p    <= #TCQ tg_instr_load_s   && (tg_xload_cnt >= 5'd8) && (tg_xload_cnt < 5'd16);
	 tg_instr_rwload_s_r  <= #TCQ tg_instr_rwload_s;
	 tg_instr_rwload_s_p  <= #TCQ tg_instr_rwload_s && (tg_xload_cnt >= 5'd8) && (tg_xload_cnt < 5'd16);

	 //`ifdef SIMULATION
	 tg_instr_start_s_p2_mcp  <= #TCQ tg_instr_start_s_p;	 
	 tg_instr_load_s_p2_mcp   <= #TCQ tg_instr_load_s_p;	 
	 tg_instr_rwload_s_p2_mcp <= #TCQ tg_instr_rwload_s_p;
	 //`else
	 //tg_instr_start_s_p2  <= #TCQ tg_instr_start_s_p;
	 //tg_instr_load_s_p2   <= #TCQ tg_instr_load_s_p;
	 //tg_instr_rwload_s_p2 <= #TCQ tg_instr_rwload_s_p;
	 //`endif

	 tg_instr_exe_s_r     <= #TCQ tg_instr_exe_s;
      end
   end

   always@(posedge tg_clk) begin
      if (tg_rst | tg_rst_int[2]) begin
	 vio_tg_status_state <= #TCQ TG_INSTR_START;
      end
      else begin
	 vio_tg_status_state <= #TCQ tg_instr_sm_ps;
      end
   end
   
   // *************************************************************************    
   // User Control 
   // *************************************************************************    
   // TG Restart Machine
   // - Restart signal is used to restart main state machine in the following scenerios
   // 1) after all instructions are done
   // 2) after pause
   // 3) after error check
//   always@(posedge tg_clk) begin
//      tg_restart   <= #TCQ vio_tg_restart;
//      tg_restart_r <= #TCQ tg_restart;
//   end
//   assign instr_restart = tg_restart && ~tg_restart_r;
   always@(posedge tg_clk) begin
      tg_restart    <= #TCQ vio_tg_restart;
      instr_restart <= #TCQ tg_restart;
   end

   always@(posedge tg_clk) begin
      tg_start    <= #TCQ vio_tg_start;
   end
   
   // TG Error Clear
   // - Clear Error status
   always@(posedge tg_clk) begin
      tg_err_clear   <= #TCQ vio_tg_err_clear;
      tg_err_clear_r <= #TCQ tg_err_clear;
   end
   assign instr_err_clear = ~tg_err_clear && tg_err_clear_r;
//   // Level input
//   always@(posedge tg_clk) begin
//      tg_err_clear    <= #TCQ vio_tg_err_clear;
//      instr_err_clear <= #TCQ tg_err_clear;
//   end
   always@(posedge tg_clk) begin
      tg_err_clear_all   <= #TCQ vio_tg_err_clear_all;
      tg_err_clear_all_r <= #TCQ tg_err_clear_all;
   end
   assign instr_err_clear_all = ~tg_err_clear_all && tg_err_clear_all_r;
   
   // TG Error Continue
   // - Continue execution after error detection (with vio_tg_err_chk_en)
   always@(posedge tg_clk) begin
      tg_err_continue   <= #TCQ vio_tg_err_continue;
      tg_err_continue_r <= #TCQ tg_err_continue;
   end
   assign instr_err_continue = ~tg_err_continue_r && tg_err_continue;

   
   // *************************************************************************    
   // TG Load Instruction 
   // *************************************************************************    
   // - Load new instruction into instruction pointer
   always@(posedge tg_clk) begin
      if (tg_instr_start_s_p2) begin
	 //`ifdef SIMULATION
	 tg_curr_instr_ptr_mcp <= #TCQ 6'b0;
	 //`else
	 //tg_curr_instr_ptr     <= #TCQ 6'b0;
	 //`endif
      end
      else if (tg_instr_ldwait_s || tg_instr_dnwait_s) begin
	 //`ifdef SIMULATION
	 tg_curr_instr_ptr_mcp <= #TCQ tg_curr_nxt_instr;
	 //`else
	 //tg_curr_instr_ptr     <= #TCQ tg_curr_nxt_instr;
	 //`endif	 
      end
   end
   
   always@(posedge tg_clk) begin
      if (tg_instr_load_s_p2) begin
	 if (vio_tg_direct_instr_en) begin
	    tg_curr_addr_mode_mcp            <= #TCQ vio_tg_instr_addr_mode;
	    tg_curr_data_mode_mcp            <= #TCQ vio_tg_instr_data_mode;
	    tg_curr_rw_mode_mcp              <= #TCQ vio_tg_instr_rw_mode;
	    tg_curr_rw_submode_mcp           <= #TCQ vio_tg_instr_rw_submode;
	    tg_curr_victim_mode_mcp          <= #TCQ vio_tg_instr_victim_mode;
	    tg_curr_num_of_iter_mcp          <= #TCQ vio_tg_instr_num_of_iter;
	    tg_curr_num_of_iter_minus1_mcp   <= #TCQ vio_tg_instr_num_of_iter-'h1;
	    tg_curr_m_nops_btw_n_burst_m_mcp <= #TCQ vio_tg_instr_m_nops_btw_n_burst_m;
	    tg_curr_m_nops_btw_n_burst_n_mcp <= #TCQ vio_tg_instr_m_nops_btw_n_burst_n;
	    tg_curr_nxt_instr_mcp            <= #TCQ vio_tg_instr_nxt_instr;
	    tg_curr_read_check_en            <= #TCQ (vio_tg_instr_rw_mode == TG_RW_MODE_WRITE_READ) ||
						(vio_tg_instr_rw_mode == TG_RW_MODE_WRITE_ONCE_READ_FOREVER);
	 end
	 else begin
	    // MCPs
	    // Load New instruction
	    //`ifdef SIMULATION
	    tg_curr_addr_mode_mcp            <= #TCQ tg_instr_addr_mode[tg_curr_instr_ptr];
	    tg_curr_data_mode_mcp            <= #TCQ tg_instr_data_mode[tg_curr_instr_ptr];
	    tg_curr_rw_mode_mcp              <= #TCQ tg_instr_rw_mode[tg_curr_instr_ptr];
	    tg_curr_rw_submode_mcp           <= #TCQ tg_instr_rw_submode[tg_curr_instr_ptr];
	    tg_curr_victim_mode_mcp          <= #TCQ tg_instr_victim_mode[tg_curr_instr_ptr];
	    tg_curr_num_of_iter_mcp          <= #TCQ tg_instr_num_of_iter[tg_curr_instr_ptr];
	    tg_curr_num_of_iter_minus1_mcp   <= #TCQ tg_instr_num_of_iter[tg_curr_instr_ptr]-'h1;
	    tg_curr_m_nops_btw_n_burst_m_mcp <= #TCQ tg_instr_m_nops_btw_n_burst_m[tg_curr_instr_ptr];
	    tg_curr_m_nops_btw_n_burst_n_mcp <= #TCQ tg_instr_m_nops_btw_n_burst_n[tg_curr_instr_ptr];
	    tg_curr_nxt_instr_mcp            <= #TCQ tg_instr_nxt_instr[tg_curr_instr_ptr];           
	    //`else // !`ifdef SIMULATION
	    //tg_curr_addr_mode            <= #TCQ tg_instr_addr_mode[tg_curr_instr_ptr];
	    //tg_curr_data_mode            <= #TCQ tg_instr_data_mode[tg_curr_instr_ptr];
	    //tg_curr_rw_mode              <= #TCQ tg_instr_rw_mode[tg_curr_instr_ptr];
	    //tg_curr_victim_mode          <= #TCQ tg_instr_victim_mode[tg_curr_instr_ptr];
	    //tg_curr_num_of_iter          <= #TCQ tg_instr_num_of_iter[tg_curr_instr_ptr];
	    //tg_curr_num_of_iter_minus1   <= #TCQ tg_instr_num_of_iter[tg_curr_instr_ptr]-'h1;
	    //tg_curr_m_nops_btw_n_burst_m <= #TCQ tg_instr_m_nops_btw_n_burst_m[tg_curr_instr_ptr];
	    //tg_curr_m_nops_btw_n_burst_n <= #TCQ tg_instr_m_nops_btw_n_burst_n[tg_curr_instr_ptr];
	    //tg_curr_nxt_instr            <= #TCQ tg_instr_nxt_instr[tg_curr_instr_ptr];           
	    //`endif
	 
	    tg_curr_read_check_en        <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_READ) ||
					    (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_ONCE_READ_FOREVER);
	 end
      end
   end

   always@(posedge tg_clk) begin
      // MCPs
      tg_glb_victim_bit_mcp            <= #TCQ vio_tg_glb_victim_bit;
      tg_glb_victim_aggr_delay_mcp     <= #TCQ vio_tg_glb_victim_aggr_delay;
      tg_glb_start_addr_mcp            <= #TCQ vio_tg_glb_start_addr;
   end
   
   // *************************************************************************   
   // App interface I/O
   // *************************************************************************    
   wire [APP_CMD_WIDTH-1:0] 	 app_cmd_int;
   wire [APP_ADDR_WIDTH-1:0] 	 app_addr_int;
   wire 			 app_en_int;
   wire 			 app_wdf_write_addr_repeat;
   // QDR - Only issue read if write is ahead of read
   reg [LOG2_MAX_READ_DELAY:0] tg_wr_rd_diff_cnt;
   always@(posedge tg_clk) begin
      if (tg_instr_dinit_s) begin
	 tg_wr_rd_diff_cnt <= #TCQ 'h0;
      end
      else begin
	 casez ({app_write_fifo_rden, app_read_fifo_rden})
	   2'b00, 2'b11: tg_wr_rd_diff_cnt <= #TCQ tg_wr_rd_diff_cnt;
	   2'b01:        tg_wr_rd_diff_cnt <= #TCQ tg_wr_rd_diff_cnt-'h1;
	   2'b10:        tg_wr_rd_diff_cnt <= #TCQ tg_wr_rd_diff_cnt+'h1;
	 endcase
      end
   end
	 
   generate
      if (MEM_TYPE == "QDRIV") begin
	 assign tg_write_rdy = (vio_tg_glb_qdriv_rw_submode == TG_RW_SUBMODE_QDRIV_PORTX_RW) ? 
			       app_rdy && app_wdf_rdy :
			       (vio_tg_glb_qdriv_rw_submode == TG_RW_SUBMODE_QDRIV_PORTAB_RW) ? 
			       app_wdf_rdy && (tg_wr_rd_diff_cnt <= {1'b1, {LOG2_MAX_READ_DELAY{1'b0}}}) :
			       app_wdf_rdy && (tg_wr_rd_diff_cnt != {1'b0, {LOG2_MAX_READ_DELAY{1'b1}}});
	 assign tg_read_rdy  = (vio_tg_glb_qdriv_rw_submode == TG_RW_SUBMODE_QDRIV_PORTX_RW) ?
			       app_rdy :
			       (vio_tg_glb_qdriv_rw_submode == TG_RW_SUBMODE_QDRIV_PORTAB_RW) ? 
			       app_rdy     && (tg_wr_rd_diff_cnt == {1'b1, {LOG2_MAX_READ_DELAY{1'b0}}}) :
			       app_rdy     && (tg_wr_rd_diff_cnt != {1'b0, {LOG2_MAX_READ_DELAY{1'b0}}});
      end
      else if (MEM_TYPE == "QDRIIP") begin
	 assign tg_write_rdy = app_wdf_rdy && (tg_wr_rd_diff_cnt != {1'b0, {LOG2_MAX_READ_DELAY{1'b1}}});
	 assign tg_read_rdy  = app_rdy     && (tg_wr_rd_diff_cnt != {1'b0, {LOG2_MAX_READ_DELAY{1'b0}}});
      end
      else begin
	 assign tg_write_rdy = (tg_rw_submode == TG_RW_SUBMODE_DDR_W_R_SIMU) ?
			       app_wdf_rdy && (tg_wr_rd_diff_cnt != {1'b0, {LOG2_MAX_READ_DELAY{1'b1}}}) :
			       app_rdy && app_wdf_rdy;
	 assign tg_read_rdy  = (tg_rw_submode == TG_RW_SUBMODE_DDR_W_R_SIMU) ? 
			       app_rdy     && (tg_wr_rd_diff_cnt != {1'b0, {LOG2_MAX_READ_DELAY{1'b0}}}) :
			       app_rdy;
      end
   endgenerate
   
   generate
      for (tg_i=0; tg_i<CMD_PER_CLK; tg_i=tg_i+1) begin : gen_lbl_app_cmd
	 assign app_write_fifo_cmd[APP_CMD_WIDTH/CMD_PER_CLK*tg_i +: APP_CMD_WIDTH/CMD_PER_CLK] = TG_WRITE_OPCODE[APP_CMD_WIDTH/CMD_PER_CLK-1:0];
	 assign app_read_fifo_cmd[APP_CMD_WIDTH/CMD_PER_CLK*tg_i +: APP_CMD_WIDTH/CMD_PER_CLK]  = TG_READ_OPCODE[APP_CMD_WIDTH/CMD_PER_CLK-1:0];
	 assign app_write_fifo_addr[(APP_ADDR_WIDTH/CMD_PER_CLK)*tg_i +: (APP_ADDR_WIDTH/CMD_PER_CLK)]
	   = write_addr[tg_i];
	 assign app_write_fifo_addr_repeat = write_addr_repeat;
	 assign app_read_fifo_addr[(APP_ADDR_WIDTH/CMD_PER_CLK)*tg_i +: (APP_ADDR_WIDTH/CMD_PER_CLK)] 
	   = read_addr[tg_i];
      end
   endgenerate

   generate
      if (MEM_TYPE == "QDRIIP" || MEM_TYPE == "QDRIV") begin
	 assign app_cmd_int  = tg_instr_errchk_s ? {CMD_PER_CLK{TG_READ_OPCODE[APP_CMD_WIDTH/CMD_PER_CLK-1:0]}} :
				app_read_fifo_dout[0 +: APP_CMD_WIDTH];
	 assign app_addr_int = tg_instr_errchk_s ? tg_read_test_addr :
				app_read_fifo_dout[APP_CMD_WIDTH +: APP_ADDR_WIDTH];
	 assign app_wdf_cmd  = app_write_fifo_dout[0 +: APP_CMD_WIDTH];
	 assign app_wdf_addr = app_write_fifo_dout[APP_CMD_WIDTH +: APP_ADDR_WIDTH];
      end
      else begin
	 assign app_cmd_int  = (tg_rw_submode == TG_RW_SUBMODE_DDR_W_R_SIMU) ?
			       tg_instr_errchk_s ? {CMD_PER_CLK{TG_READ_OPCODE[APP_CMD_WIDTH/CMD_PER_CLK-1:0]}} :
			       app_read_fifo_dout[0 +: APP_CMD_WIDTH]
	                       :
			       tg_instr_errchk_s ? {CMD_PER_CLK{TG_READ_OPCODE[APP_CMD_WIDTH/CMD_PER_CLK-1:0]}} :
			       app_write_fifo_rden ? 
			       app_write_fifo_dout[0 +: APP_CMD_WIDTH] :
			       app_read_fifo_dout[0 +: APP_CMD_WIDTH];
	 
	 assign app_addr_int = (tg_rw_submode == TG_RW_SUBMODE_DDR_W_R_SIMU) ?
			       tg_instr_errchk_s ? tg_read_test_addr :	    
			       app_read_fifo_dout[APP_CMD_WIDTH +: APP_ADDR_WIDTH]
	                       :
			       tg_instr_errchk_s ? tg_read_test_addr :
			       app_write_fifo_rden  ?
			       app_write_fifo_dout[APP_CMD_WIDTH +: APP_ADDR_WIDTH] :
			       app_read_fifo_dout[APP_CMD_WIDTH +: APP_ADDR_WIDTH];
	 
	 assign app_wdf_cmd  = (tg_rw_submode == TG_RW_SUBMODE_DDR_W_R_SIMU) ?
			       app_write_fifo_dout[0 +: APP_CMD_WIDTH]
	                       :
			       'h0;
	 
	 assign app_wdf_addr = (tg_rw_submode == TG_RW_SUBMODE_DDR_W_R_SIMU) ?
			       app_write_fifo_dout[APP_CMD_WIDTH +: APP_ADDR_WIDTH]
	                       :
			       'h0;
      end
   endgenerate

   assign exe_app_write_en = (tg_instr_exe_s_r && tg_curr_write_cmd /*&& ~last_write_done*/ && ~app_write_fifo_full && ~tg_curr_write_nop_state && write_addr_valid);
   assign exe_app_read_en  = (tg_instr_exe_s_r && tg_curr_read_cmd  /*&& ~last_read_done */ && ~app_read_fifo_full  && ~tg_curr_read_nop_state  && read_addr_valid);
   //assign exe_app_en       = exe_app_write_en || exe_app_read_en;			 
   assign err_app_en       = (tg_instr_errchk_s && tg_read_rdy && tg_read_test_en);
   assign tg_read_test_valid = err_app_en;

   //assign app_fifo_wren = exe_app_en | err_app_en;
   //assign app_fifo_rden = app_read_fifo_rden || app_write_fifo_rden;
   assign app_read_fifo_wren  = exe_app_read_en;
   assign app_read_fifo_rden  = tg_instr_exe_s_r && ~app_read_fifo_empty  && tg_read_rdy;
   assign app_write_fifo_wren = exe_app_write_en;
   assign app_write_fifo_rden = tg_instr_exe_s_r && ~app_write_fifo_empty && tg_write_rdy;

   generate
      if (MEM_TYPE == "QDRIIP" || MEM_TYPE == "QDRIV") begin
	 assign app_en_int   = (tg_instr_exe_s_r && ~app_read_fifo_empty && ~last_read_done && tg_read_rdy)  || err_app_en;
	 //assign app_wdf_en   = (app_write_fifo_rden && ~last_write_done);
	 assign app_wdf_en   = (tg_instr_exe_s_r && ~app_write_fifo_empty && ~last_write_done && tg_write_rdy);
      end
      else begin   
	 assign app_en_int   = (tg_rw_submode == TG_RW_SUBMODE_DDR_W_R_SIMU) ?
			       (tg_instr_exe_s_r && ~app_read_fifo_empty && ~last_read_done && tg_read_rdy)  || err_app_en
			       :
			       (tg_instr_exe_s_r && ~app_write_fifo_empty && ~last_write_done && tg_write_rdy) || 
			       (tg_instr_exe_s_r && ~app_read_fifo_empty && ~last_read_done && tg_read_rdy)  || err_app_en;
				  
	 assign app_wdf_en   = (tg_rw_submode == TG_RW_SUBMODE_DDR_W_R_SIMU) ?
			       (tg_instr_exe_s_r && ~app_write_fifo_empty && ~last_write_done && tg_write_rdy)
	                       :
			       1'b0;
      end
   endgenerate
   assign app_wdf_mask = {APP_DATA_WIDTH/DM_WIDTH{1'b0}};
   assign app_wdf_data = app_write_fifo_dout[APP_CMD_WIDTH+APP_ADDR_WIDTH +: APP_DATA_WIDTH];
   assign app_wdf_wren = (app_write_fifo_rden && ~last_write_done);
   assign app_wdf_end  = app_wdf_wren;
   assign app_wdf_write_addr_repeat = app_write_fifo_dout[APP_CMD_WIDTH+APP_ADDR_WIDTH+APP_DATA_WIDTH +: 1];
   
   // Adding Delay stage for QDRIIP Read path
   // This is pure delay stage with no enable control
   /*
   generate
      if (MEM_TYPE == "QDRIIP") begin
	 reg [QDRIIP_READ_DELAY-1:0] app_en_delay;
	 reg [APP_CMD_WIDTH-1:0] app_cmd_delay[QDRIIP_READ_DELAY];
	 reg [APP_ADDR_WIDTH-1:0] app_addr_delay[QDRIIP_READ_DELAY];
	 
	 for (tg_i=0; tg_i<QDRIIP_READ_DELAY; tg_i=tg_i+1) begin
	    always @(posedge tg_clk) begin
	       if (tg_rst || tg_rst_int[4]) begin
		  app_en_delay[tg_i]   <= #TCQ 'h0;
	       end
	       else begin
		  if (tg_i == 0) begin
		     app_en_delay[0]   <= #TCQ app_en_int;
		     app_cmd_delay[0]  <= #TCQ app_cmd_int;	 
		     app_addr_delay[0] <= #TCQ app_addr_int;
		  end
		  else begin
		     app_en_delay[tg_i]   <= #TCQ app_en_delay[tg_i-1];
		     app_cmd_delay[tg_i]  <= #TCQ app_cmd_delay[tg_i-1];
		     app_addr_delay[tg_i] <= #TCQ app_addr_delay[tg_i-1];
		  end
	       end
	    end
	 end
	 assign app_en   = app_en_delay[QDRIIP_READ_DELAY-1];
	 assign app_cmd  = app_cmd_delay[QDRIIP_READ_DELAY-1];	 
	 assign app_addr = app_addr_delay[QDRIIP_READ_DELAY-1];
      end
      else begin
	 assign app_en   = app_en_int;
	 assign app_cmd  = app_cmd_int;	 
	 assign app_addr = app_addr_int;	 
      end
   endgenerate
   */
   assign app_en   = app_en_int;
   assign app_cmd  = app_cmd_int;	 
   assign app_addr = app_addr_int;	 
	  	 
   qdriip_v1_4_19_tg_fifo
     #(
       .TCQ(TCQ),
       .WIDTH(1+APP_DATA_WIDTH+APP_ADDR_WIDTH+APP_CMD_WIDTH),
       .DEPTH(4),
       .LOG2DEPTH(2)
       )
   u_qdriip_v1_4_19_tg_write_fifo
     (
      .clk (tg_clk),
      .rst (tg_instr_load_s_p2 | tg_instr_rwload_s_p2),
      .wren (app_write_fifo_wren),
      .rden (app_write_fifo_rden),
      .din ({write_addr_repeat, write_data, app_write_fifo_addr, app_write_fifo_cmd}),
      .dout (app_write_fifo_dout),
      .full (app_write_fifo_full),
      .empty (app_write_fifo_empty)
      );

   qdriip_v1_4_19_tg_fifo
     #(
       .TCQ(TCQ),
       .WIDTH(APP_ADDR_WIDTH+APP_CMD_WIDTH),
       .DEPTH(4),
       .LOG2DEPTH(2)
       )
   u_qdriip_v1_4_19_tg_read_fifo
     (
      .clk (tg_clk),
      .rst (tg_instr_load_s_p2 | tg_instr_rwload_s_p2),
      .wren (app_read_fifo_wren),
      .rden (app_read_fifo_rden),
      .din ({app_read_fifo_addr, app_read_fifo_cmd}),
      .dout (app_read_fifo_dout),
      .full (app_read_fifo_full),
      .empty (app_read_fifo_empty)
      );
   
   // *************************************************************************    
   // NO OP Status Tracking
   // *************************************************************************    
   // - Keep track of number of Burst cycles and number of NOP cycles spent for both read and write requests
   // - Stop sending read or write command when in NO OP State
   always@(posedge tg_clk) begin
      tg_curr_m_nops_btw_n_burst_m_minus1 <= #TCQ (tg_curr_m_nops_btw_n_burst_m>'h0) ? (tg_curr_m_nops_btw_n_burst_m - 'h1) : 'h0;
      tg_curr_m_nops_btw_n_burst_n_minus1 <= #TCQ (tg_curr_m_nops_btw_n_burst_n>'h0) ? (tg_curr_m_nops_btw_n_burst_n - 'h1) : 'h0;
   end
      
   always@(posedge tg_clk) begin
      if (tg_instr_load_s_p2) begin
	 tg_curr_write_nop_state      <= #TCQ 1'b0;
	 tg_curr_write_nop_cnt        <= #TCQ 10'b0;
	 tg_curr_write_burst_cnt      <= #TCQ 32'b0;
	 tg_curr_read_nop_state       <= #TCQ 1'b0;
	 tg_curr_read_nop_cnt         <= #TCQ 10'b0;
	 tg_curr_read_burst_cnt       <= #TCQ 32'b0;
      end
      else if (tg_instr_exe_s_r) begin
	 // Write Nop tracking
	 if (tg_curr_write_cmd) begin
	    if (tg_curr_write_nop_state) begin
	       tg_curr_write_nop_cnt   <= #TCQ tg_curr_write_nop_cnt + 10'b1;
	       if (tg_curr_write_nop_cnt == tg_curr_m_nops_btw_n_burst_m_minus1) begin
		  tg_curr_write_nop_state <= #TCQ 1'b0;
		  tg_curr_write_nop_cnt   <= #TCQ 10'b0;
	       end
	    end
	    else begin
	       if (exe_app_write_en) begin
		  if (tg_curr_write_burst_cnt == tg_curr_m_nops_btw_n_burst_n_minus1) begin
		     tg_curr_write_nop_state <= #TCQ 1'b1;
		     tg_curr_write_burst_cnt <= #TCQ 32'b0;
		  end
		  else begin
		     tg_curr_write_burst_cnt   <= #TCQ tg_curr_write_burst_cnt + 32'b1;
		  end
	       end
	    end
	 end

	 // Read Nop tracking
	 if (tg_curr_read_cmd) begin
	    if (tg_curr_read_nop_state) begin
	       tg_curr_read_nop_cnt    <= #TCQ tg_curr_read_nop_cnt + 10'b1;
	       if (tg_curr_read_nop_cnt == tg_curr_m_nops_btw_n_burst_m_minus1) begin
		  tg_curr_read_nop_state <= #TCQ 1'b0;
		  tg_curr_read_nop_cnt   <= #TCQ 10'b0;
	       end
	    end
	    else begin
	       if (exe_app_read_en) begin
		  if (tg_curr_read_burst_cnt == tg_curr_m_nops_btw_n_burst_n_minus1) begin
		     tg_curr_read_nop_state <= #TCQ 1'b1;
		     tg_curr_read_burst_cnt <= #TCQ 32'b0;
		  end
		  else begin
		     tg_curr_read_burst_cnt    <= #TCQ tg_curr_read_burst_cnt + 32'b1;
		  end
	       end
	    end
	 end
      end
   end
   
   // *************************************************************************    
   // Command counter
   // *************************************************************************    
   // - Keep track of number of read/write commands issued in EXE state
   always@(posedge tg_clk) begin
      if (tg_instr_load_s_p2 | tg_instr_rwload_s_p2) begin
	 // MCPs
	 tg_curr_num_of_iter_rd_cnt <= #TCQ 16'b0;	 
	 tg_curr_num_of_iter_wr_cnt <= #TCQ 16'b0;	 
      end
      else if (tg_instr_exe_s_r) begin
	 // Need to fix for QDR WRITE_READ_MODE
	 if (app_read_fifo_rden && ~last_read_done) begin
	    tg_curr_num_of_iter_rd_cnt <= #TCQ tg_curr_num_of_iter_rd_cnt + 16'b1; 
	 end
	 if (app_write_fifo_rden && ~last_write_done) begin
	    tg_curr_num_of_iter_wr_cnt <= #TCQ tg_curr_num_of_iter_wr_cnt + 16'b1; 
	 end
      end
   end

   always@(posedge tg_clk) begin
      if (tg_instr_load_s_p2 | tg_instr_rwload_s_p2) begin
	 // MCPs
	 tg_curr_num_of_iter_rd_cnt_r <= #TCQ 16'b0;	       
      end
      else begin
	 tg_curr_num_of_iter_rd_cnt_r <= #TCQ tg_curr_num_of_iter_rd_cnt;
      end
   end

   // *************************************************************************    
   // Read Write Load
   // - This is a state to keep track of whether 
   //   Read or/and Write command will be enabled in EXE State
   //   for a given Read/Write Mode programmed
   // *************************************************************************    

   generate 
      if (MEM_TYPE == "QDRIV") begin
	 always@(posedge tg_clk) begin
	    if (vio_tg_glb_qdriv_rw_submode == TG_RW_SUBMODE_QDRIV_PORTX_RW) begin
	       // MCPs
	       if (tg_instr_load_s_p2) begin
		  tg_curr_read_cmd_mcp   <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_READ_ONLY);
		  tg_curr_write_cmd_mcp  <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] != TG_RW_MODE_READ_ONLY);
		  tg_curr_nxt_rwwait_mcp <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_READ) ||
					    (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_ONCE_READ_FOREVER);
	       end
	       else if (tg_instr_rwload_s_p2) begin
		  tg_curr_write_cmd_mcp  <= #TCQ 1'b0;
		  tg_curr_read_cmd_mcp   <= #TCQ 1'b1;
		  tg_curr_nxt_rwwait_mcp <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_ONCE_READ_FOREVER);
	       end
	    end
	    else begin
	       // MCPs
	       if (tg_instr_load_s_p2) begin
		  tg_curr_read_cmd_mcp   <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_READ_ONLY) || 
					    (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_READ) ||
					    (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_ONCE_READ_FOREVER);
		  tg_curr_write_cmd_mcp  <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] != TG_RW_MODE_READ_ONLY);
    		  tg_curr_nxt_rwwait_mcp <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_ONCE_READ_FOREVER);
	       end
	       else if (tg_instr_rwload_s_p2) begin
		  tg_curr_write_cmd_mcp  <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_READ) || (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_ONLY);
		  tg_curr_read_cmd_mcp   <= #TCQ 1'b1;
		  tg_curr_nxt_rwwait_mcp <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_ONCE_READ_FOREVER);
	       end
	    end
	 end
      end
      else if (MEM_TYPE == "QDRIIP") begin
	 always@(posedge tg_clk) begin
	    // MCPs
	    if (tg_instr_load_s_p2) begin
	       tg_curr_read_cmd_mcp   <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_READ_ONLY) || 
					 (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_READ) ||
					 (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_ONCE_READ_FOREVER);
	       tg_curr_write_cmd_mcp  <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] != TG_RW_MODE_READ_ONLY);
    	       tg_curr_nxt_rwwait_mcp <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_ONCE_READ_FOREVER);
	    end
	    else if (tg_instr_rwload_s_p2) begin
	       tg_curr_write_cmd_mcp  <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_READ) || (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_ONLY);
	       tg_curr_read_cmd_mcp   <= #TCQ 1'b1;
	       tg_curr_nxt_rwwait_mcp <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_ONCE_READ_FOREVER);
	    end
	 end
      end
      else begin
	 always@(posedge tg_clk) begin
	    if (tg_rw_submode == TG_RW_SUBMODE_DDR_W_R_SIMU) begin
	       // MCPs
	       if (tg_instr_load_s_p2) begin
		  tg_curr_read_cmd_mcp   <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_READ_ONLY) ||
					    (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_READ) ||
					    (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_ONCE_READ_FOREVER);		  
		  tg_curr_write_cmd_mcp  <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] != TG_RW_MODE_READ_ONLY);
		  tg_curr_nxt_rwwait_mcp <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_ONCE_READ_FOREVER);
	       end
	       else if (tg_instr_rwload_s_p2) begin
		  tg_curr_write_cmd_mcp  <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_READ) || (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_ONLY);
		  tg_curr_read_cmd_mcp   <= #TCQ 1'b1;
		  tg_curr_nxt_rwwait_mcp <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_ONCE_READ_FOREVER);
	       end
	    end
	    else begin
	       // MCPs
	       if (tg_instr_load_s_p2) begin
		  tg_curr_read_cmd_mcp   <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_READ_ONLY);
		  tg_curr_write_cmd_mcp  <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] != TG_RW_MODE_READ_ONLY);
		  tg_curr_nxt_rwwait_mcp <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_READ) ||
					    (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_ONCE_READ_FOREVER);
	       end
	       else if (tg_instr_rwload_s_p2) begin
		  tg_curr_write_cmd_mcp  <= #TCQ 1'b0;
		  tg_curr_read_cmd_mcp   <= #TCQ 1'b1;
		  tg_curr_nxt_rwwait_mcp <= #TCQ (tg_instr_rw_mode[tg_curr_instr_ptr] == TG_RW_MODE_WRITE_ONCE_READ_FOREVER);
	       end
	    end
	 end
      end
   endgenerate

   // *************************************************************************    
   // Data and Address Generation blocks
   // *************************************************************************
   // Write Data Engine
   // - Generated in 2 stages
   // - Stage1 - Data pattern generation
   // - Stage2 - Victim pattern generation

   // Load PRBS Data seed
   wire [TG_PATTERN_MODE_PRBS_DATA_WIDTH-1:0] 	    default_data_prbs_seed[144-1:0];
   reg [TG_PATTERN_MODE_PRBS_DATA_WIDTH-1:0] 	    data_prbs_seed[NUM_DQ_PINS-1:0];

   qdriip_v1_4_19_tg_data_prbs_seed
     #(
       .TG_PATTERN_MODE_PRBS_DATA_WIDTH(TG_PATTERN_MODE_PRBS_DATA_WIDTH)
       )
   u_qdriip_v1_4_19_tg_data_prbs_seed 
     (
      .default_data_prbs_seed(default_data_prbs_seed)
      );

   generate
      for (tg_i=0; tg_i<NUM_DQ_PINS; tg_i=tg_i+1) begin: tg_seed_init
	 always@(posedge tg_clk) begin
	    if (tg_rst | tg_rst_int[15]) begin
	       data_prbs_seed[tg_i] <= #TCQ default_data_prbs_seed[tg_i];
	    end
	    else if (vio_tg_seed_program_en && (vio_tg_seed_num == tg_i)) begin
	       data_prbs_seed[tg_i] <= #TCQ vio_tg_seed;
	    end
	 end
      end
   endgenerate
						    
   qdriip_v1_4_19_tg_pattern_gen_data // Stage1 - Data pattern generation
     #(
       .TCQ(TCQ),
       .APP_DATA_WIDTH(APP_DATA_WIDTH),
       .NUM_DQ_PINS(NUM_DQ_PINS),
       .nCK_PER_CLK(nCK_PER_CLK),
       .PRBS_WIDTH(TG_PATTERN_MODE_PRBS_DATA_WIDTH)
       )
   u_qdriip_v1_4_19_tg_pattern_gen_write_data
     (
      .clk (tg_clk),
      .rst (tg_rst | tg_rst_int[6]),
      //.calib_complete (tg_calib_complete),
      .pattern_load (tg_instr_load_s_p2 | tg_instr_rwload_s_p2),
      .pattern_done (1'b0),
      .pattern_linear_seed (TG_PATTERN_MODE_LINEAR_DATA_SEED),
      .pattern_prbs_seed (data_prbs_seed/*[NUM_DQ_PINS-1:0]*/),
      .pattern_mode (tg_curr_data_mode),
      .pattern_en (tg_instr_exe_s_r && tg_curr_write_cmd /*&& ~last_write_done*/ && ~tg_curr_write_nop_state),
      .pattern_hold (app_write_fifo_full),
      .pattern_valid (write_pattern_valid),
      .pattern_out (write_pattern)
      );

   
   qdriip_v1_4_19_tg_victim_data // Stage2 - Victim pattern generation
     #(
       .TCQ(TCQ),
       .APP_DATA_WIDTH(APP_DATA_WIDTH),
       .NUM_DQ_PINS(NUM_DQ_PINS),
       .nCK_PER_CLK(nCK_PER_CLK),
       .MEM_ARCH(MEM_ARCH),
       .MEM_TYPE(MEM_TYPE)
           )
   u_qdriip_v1_4_19_tg_victim_write_data
     (
      .clk (tg_clk),
      .rst (tg_rst | tg_rst_int[7] | tg_instr_load_s_p2 | tg_instr_rwload_s_p2),
      //.calib_complete (tg_calib_complete),
      .victim_mode(tg_curr_victim_mode),
      .victim_aggr_delay(tg_glb_victim_aggr_delay),
      .victim_bit(tg_glb_victim_bit),
      .victim_en(tg_instr_exe_s_r && tg_curr_write_cmd /*&& ~last_write_done*/ && ~tg_curr_write_nop_state && write_pattern_valid),
      .victim_hold (app_write_fifo_full),
      .victim_in(write_pattern),
      .victim_valid(write_data_valid),
      .victim_out(write_data)
      );

   // Write Address Engine
//   wire [(APP_ADDR_WIDTH/CMD_PER_CLK)-TG_LOWER_ADDR_WIDTH-1:0] local_upper_write_addr [CMD_PER_CLK];
//   wire [TG_LOWER_ADDR_WIDTH-1:0] 		 local_lower_write_addr [CMD_PER_CLK];
   qdriip_v1_4_19_tg_pattern_gen_addr
     #(
       .TCQ(TCQ),
       .APP_ADDR_WIDTH(APP_ADDR_WIDTH/CMD_PER_CLK),
       .CMD_PER_CLK(CMD_PER_CLK),
       .PRBS_WIDTH(TG_PATTERN_MODE_PRBS_ADDR_WIDTH),
       .NUM_OF_POLY_TAP(TG_PATTERN_MODE_PRBS_ADDR_NUM_OF_POLY_TAP),
       .POLY_TAP0(TG_PATTERN_MODE_PRBS_ADDR_POLY_TAP0),
       .POLY_TAP1(TG_PATTERN_MODE_PRBS_ADDR_POLY_TAP1),
       .POLY_TAP2(TG_PATTERN_MODE_PRBS_ADDR_POLY_TAP2),
       .POLY_TAP3(TG_PATTERN_MODE_PRBS_ADDR_POLY_TAP3),
       .MEM_TYPE(MEM_TYPE),
       .RLD_BANK_WIDTH(RLD_BANK_WIDTH)
    )
   u_qdriip_v1_4_19_tg_pattern_gen_write_addr
     (
      .clk (tg_clk),
      .rst (tg_rst | tg_rst_int[8]),
      //.calib_complete (tg_calib_complete),
      .pattern_load (tg_instr_load_s_p2 | tg_instr_rwload_s_p2),
      .pattern_done (1'b0),
      .pattern_prbs_seed (TG_PATTERN_MODE_PRBS_ADDR_SEED),
      .pattern_linear_seed (tg_glb_start_addr),
      .pattern_mode (tg_curr_addr_mode),
      .pattern_en (tg_instr_exe_s_r && tg_curr_write_cmd /*&& ~last_write_done*/ && ~tg_curr_write_nop_state),
      .pattern_hold (app_write_fifo_full),
      .pattern_valid (write_addr_valid),
      .pattern_repeat(write_addr_repeat),
      .pattern_out (write_addr)
      );
   
//   generate
//      for (tg_i=0; tg_i<CMD_PER_CLK; tg_i=tg_i+1) begin : gen_lbl_write_addr
//	 assign local_lower_write_addr[tg_i] = 'h0;
//	 assign write_addr[tg_i]       = {local_upper_write_addr[tg_i], local_lower_write_addr[tg_i]};
//      end
//   endgenerate
   
   // Read Data Engine
   // - Generated in 2 stages
   // - Stage1 - Data pattern generation
   // - Stage2 - Victim pattern generation
   qdriip_v1_4_19_tg_pattern_gen_data // Stage1 - Data pattern generation
     #(
       .TCQ(TCQ),
       .APP_DATA_WIDTH(APP_DATA_WIDTH),
       .NUM_DQ_PINS(NUM_DQ_PINS),
       .nCK_PER_CLK(nCK_PER_CLK),
       .PRBS_WIDTH(TG_PATTERN_MODE_PRBS_DATA_WIDTH)
       )
   u_qdriip_v1_4_19_tg_pattern_gen_exp_read_data
     (
      .clk (tg_clk),
      .rst (tg_rst | tg_rst_int[9]),
      //.calib_complete (tg_calib_complete),
      .pattern_load (tg_instr_load_s_p2 | tg_instr_rwload_s_p2),
      .pattern_done (1'b0),
      .pattern_prbs_seed (data_prbs_seed/*[NUM_DQ_PINS-1:0]*/),
      .pattern_linear_seed (TG_PATTERN_MODE_LINEAR_DATA_SEED),
      .pattern_mode (tg_curr_data_mode),
      .pattern_en (tg_instr_dinit_s || tg_instr_exe_s || tg_instr_pausewait_s || tg_instr_rwwait_s || tg_instr_ldwait_s || tg_instr_dnwait_s || tg_instr_errwait_s),
      .pattern_hold (~(|app_rd_data_valid_r) && exp_read_data_valid),
      .pattern_valid (exp_read_pattern_valid),
      .pattern_out (exp_read_pattern)
      );
   
   qdriip_v1_4_19_tg_victim_data // Stage2 - Victim pattern generation
     #(
       .TCQ(TCQ),
       .APP_DATA_WIDTH(APP_DATA_WIDTH),
       .NUM_DQ_PINS(NUM_DQ_PINS),
       .nCK_PER_CLK(nCK_PER_CLK),
       .MEM_ARCH(MEM_ARCH),
       .MEM_TYPE(MEM_TYPE)
           )
   u_qdriip_v1_4_19_tg_victim_exp_read_data
     (
      .clk (tg_clk),
      .rst (tg_rst | tg_rst_int[10] | tg_instr_load_s_p2 | tg_instr_rwload_s_p2),
      //.calib_complete (tg_calib_complete),
      .victim_mode(tg_curr_victim_mode),
      .victim_aggr_delay(tg_glb_victim_aggr_delay),
      .victim_bit(tg_glb_victim_bit),
      .victim_en(exp_read_pattern_valid),
      .victim_hold(~(|app_rd_data_valid_r) && exp_read_data_valid),
      .victim_in(exp_read_pattern),
      .victim_valid(exp_read_data_valid),
      .victim_out(exp_read_data)
      );

   assign exp_read_data_valid_vec = (MEM_TYPE != "QDRIV") || (vio_tg_glb_qdriv_rw_submode != TG_RW_SUBMODE_QDRIV_PORTAB_RW) ? 
				    {CMD_PER_CLK{exp_read_data_valid}} :
				    {CMD_PER_CLK{exp_read_data_valid}} | exp_read_addr[0][CMD_PER_CLK+2] ? exp_read_addr[0][2+:CMD_PER_CLK] : ~exp_read_addr[0][2+:CMD_PER_CLK];
   
   // Read Address Engine
   // Read Address sent to read data Checker
//   wire [(APP_ADDR_WIDTH/CMD_PER_CLK)-TG_LOWER_ADDR_WIDTH-1:0] local_upper_exp_read_addr [CMD_PER_CLK];
//   wire [TG_LOWER_ADDR_WIDTH-1:0] 		 local_lower_exp_read_addr [CMD_PER_CLK];
   qdriip_v1_4_19_tg_pattern_gen_addr
     #(
       .TCQ(TCQ),
       .APP_ADDR_WIDTH(APP_ADDR_WIDTH/CMD_PER_CLK),
       .CMD_PER_CLK(CMD_PER_CLK),
       .PRBS_WIDTH(TG_PATTERN_MODE_PRBS_ADDR_WIDTH),
       .NUM_OF_POLY_TAP(TG_PATTERN_MODE_PRBS_ADDR_NUM_OF_POLY_TAP),
       .POLY_TAP0(TG_PATTERN_MODE_PRBS_ADDR_POLY_TAP0),
       .POLY_TAP1(TG_PATTERN_MODE_PRBS_ADDR_POLY_TAP1),
       .POLY_TAP2(TG_PATTERN_MODE_PRBS_ADDR_POLY_TAP2),
       .POLY_TAP3(TG_PATTERN_MODE_PRBS_ADDR_POLY_TAP3),
       .MEM_TYPE(MEM_TYPE),
       .RLD_BANK_WIDTH(RLD_BANK_WIDTH)
    )
   u_qdriip_v1_4_19_tg_pattern_gen_exp_read_addr
     (
      .clk (tg_clk),
      .rst (tg_rst | tg_rst_int[11]),
      //.calib_complete (tg_calib_complete),
      .pattern_load (tg_instr_load_s_p2 | tg_instr_rwload_s_p2),
      .pattern_done (1'b0),
      .pattern_prbs_seed (TG_PATTERN_MODE_PRBS_ADDR_SEED),
      .pattern_linear_seed (tg_glb_start_addr),
      .pattern_mode (tg_curr_addr_mode),
      .pattern_en (tg_instr_dinit_s || tg_instr_exe_s || tg_instr_pausewait_s || tg_instr_rwwait_s || tg_instr_ldwait_s || tg_instr_dnwait_s || tg_instr_errwait_s),
      .pattern_hold (~(|app_rd_data_valid_r) && exp_read_addr_valid),
      .pattern_valid (exp_read_addr_valid),
      .pattern_repeat(exp_read_addr_repeat),
      .pattern_out (exp_read_addr)
      );

   assign exp_read_addr_valid_vec = (MEM_TYPE != "QDRIV") || (vio_tg_glb_qdriv_rw_submode != TG_RW_SUBMODE_QDRIV_PORTAB_RW) ? 
				    {CMD_PER_CLK{exp_read_addr_valid}} :
				    {CMD_PER_CLK{exp_read_addr_valid}} | exp_read_addr[0][CMD_PER_CLK+2] ? exp_read_addr[0][2+:CMD_PER_CLK] : ~exp_read_addr[0][2+:CMD_PER_CLK];

//   generate
//      for (tg_i=0; tg_i<CMD_PER_CLK; tg_i=tg_i+1) begin : gen_lbl_exp_read_addr
//	 assign local_lower_exp_read_addr[tg_i] = 'h0;
//	 assign exp_read_addr[tg_i]       = {local_upper_exp_read_addr[tg_i], local_lower_exp_read_addr[tg_i]};
//      end
//   endgenerate

   
   // Read Address sent to memory
//   wire [(APP_ADDR_WIDTH/CMD_PER_CLK)-TG_LOWER_ADDR_WIDTH-1:0] local_upper_read_addr [CMD_PER_CLK];
//   wire [TG_LOWER_ADDR_WIDTH-1:0] 		 local_lower_read_addr [CMD_PER_CLK];
   qdriip_v1_4_19_tg_pattern_gen_addr
     #(
       .TCQ(TCQ),
       .APP_ADDR_WIDTH(APP_ADDR_WIDTH/CMD_PER_CLK),
       .CMD_PER_CLK(CMD_PER_CLK),
       .PRBS_WIDTH(TG_PATTERN_MODE_PRBS_ADDR_WIDTH),
       .NUM_OF_POLY_TAP(TG_PATTERN_MODE_PRBS_ADDR_NUM_OF_POLY_TAP),
       .POLY_TAP0(TG_PATTERN_MODE_PRBS_ADDR_POLY_TAP0),
       .POLY_TAP1(TG_PATTERN_MODE_PRBS_ADDR_POLY_TAP1),
       .POLY_TAP2(TG_PATTERN_MODE_PRBS_ADDR_POLY_TAP2),
       .POLY_TAP3(TG_PATTERN_MODE_PRBS_ADDR_POLY_TAP3),
       .MEM_TYPE(MEM_TYPE),
       .RLD_BANK_WIDTH(RLD_BANK_WIDTH)
    )
   u_qdriip_v1_4_19_tg_pattern_gen_request_read_addr
     (
      .clk (tg_clk),
      .rst (tg_rst | tg_rst_int[12]),
      //.calib_complete (tg_calib_complete),
      .pattern_load (tg_instr_load_s_p2 | tg_instr_rwload_s_p2),
      .pattern_done (1'b0),
      .pattern_prbs_seed (TG_PATTERN_MODE_PRBS_ADDR_SEED),
      .pattern_linear_seed (tg_glb_start_addr),
      .pattern_mode (tg_curr_addr_mode),
      .pattern_en (tg_instr_exe_s_r && tg_curr_read_cmd /*&& ~last_read_done*/ && ~tg_curr_read_nop_state),
      .pattern_hold (app_read_fifo_full),
      .pattern_valid (read_addr_valid),
      .pattern_repeat(read_addr_repeat),
      .pattern_out (read_addr)
      );

//   generate
//      for (tg_i=0; tg_i<CMD_PER_CLK; tg_i=tg_i+1) begin : gen_lbl_read_addr
//	 assign local_lower_read_addr[tg_i] = 'h0;
//	 assign read_addr[tg_i]       = {local_upper_read_addr[tg_i], local_lower_read_addr[tg_i]};
//      end
//   endgenerate

   always@(posedge tg_clk) begin
      if (tg_rst || tg_rst_int[5]) begin
	 app_rd_data_valid_r <= #TCQ {CMD_PER_CLK{1'b0}};
      end
      else begin
	 app_rd_data_valid_r <= #TCQ app_rd_data_valid;
	 app_rd_data_r       <= #TCQ app_rd_data;
      end
   end
   
   // *************************************************************************
   // Wait State sample counter
   // *************************************************************************    
   always@(posedge tg_clk) begin
      if (tg_instr_pausewait_s || tg_instr_rwwait_s || tg_instr_ldwait_s || tg_instr_dnwait_s || tg_instr_errwait_s) begin
	 tg_wait_state_cnt <= #TCQ tg_wait_state_cnt + 3'b1;
      end
      else begin
	 tg_wait_state_cnt <= #TCQ 3'b0;
      end
   end
   assign tg_wait_state_done = tg_wait_state_cnt[2];

   // *************************************************************************    
   // Read Data Checker and Error Detection
   // - For Write-read mode or Write-once-Read-forever modes,
   //   check for read data mismatch
   // - If there is read data mismatch, performs read test to categorize
   //   whether there is READ or WRITE error
   // *************************************************************************    
   qdriip_v1_4_19_tg_errchk
     #(
       .TCQ(TCQ),
       .APP_DATA_WIDTH(APP_DATA_WIDTH),
       .APP_ADDR_WIDTH(APP_ADDR_WIDTH),
       .NUM_DQ_PINS(NUM_DQ_PINS),
       .nCK_PER_CLK(nCK_PER_CLK),       
       .CMD_PER_CLK(CMD_PER_CLK),
       .MEM_TYPE(MEM_TYPE)
       )
   u_qdriip_v1_4_19_tg_errchk
     (
      .clk (tg_clk),
      .rst (tg_rst | tg_rst_int[16] | tg_instr_start_s_p2 | instr_restart),
      .vio_tg_err_chk_en(vio_tg_err_chk_en), 	     
      .tg_glb_qdriv_rw_submode(vio_tg_glb_qdriv_rw_submode),
      .instr_err_clear(instr_err_clear),
      .instr_err_clear_all(instr_err_clear_all),
      //.tg_instr_sm_ps(tg_instr_sm_ps),
      .tg_instr_exe_s(tg_instr_exe_s_r),
      .tg_instr_pausewait_s(tg_instr_pausewait_s),
      .tg_instr_rwwait_s(tg_instr_rwwait_s),
      .tg_instr_ldwait_s(tg_instr_ldwait_s),
      .tg_instr_dnwait_s(tg_instr_dnwait_s),
      .tg_instr_errwait_s(tg_instr_errwait_s),
      .tg_instr_errchk_s(tg_instr_errchk_s),
      .tg_instr_load_s(tg_instr_load_s_p2),      
      .tg_instr_rwload_s(tg_instr_rwload_s),
      .tg_curr_read_check_en(tg_curr_read_check_en),
      .mem_read_data_valid(app_rd_data_valid_r),
      .mem_read_data(app_rd_data_r),		     
      .exp_num_of_iter(tg_curr_num_of_iter_rd_cnt_r),
      .exp_read_addr_valid(exp_read_addr_valid_vec),	     
      .exp_read_addr(exp_read_addr),		     
      .exp_read_data_valid(exp_read_data_valid_vec),	     
      .exp_read_data(exp_read_data),		     
      .tg_errchk_found(tg_errchk_found),
      .tg_errchk_done(tg_errchk_done),      
      .vio_tg_status_err_bit_valid(vio_tg_status_err_bit_valid),
      .vio_tg_status_err_bit(vio_tg_status_err_bit),
      .vio_tg_status_err_addr(vio_tg_status_err_addr),
      .vio_tg_status_exp_bit_valid(vio_tg_status_exp_bit_valid),
      .vio_tg_status_exp_bit(vio_tg_status_exp_bit),
      .vio_tg_status_read_bit_valid(vio_tg_status_read_bit_valid),
      .vio_tg_status_read_bit(vio_tg_status_read_bit),
      .vio_tg_status_first_err_bit_valid(vio_tg_status_first_err_bit_valid),
      .vio_tg_status_first_err_bit(vio_tg_status_first_err_bit),
      .vio_tg_status_first_err_addr(vio_tg_status_first_err_addr),
      .vio_tg_status_first_exp_bit_valid(vio_tg_status_first_exp_bit_valid),
      .vio_tg_status_first_exp_bit(vio_tg_status_first_exp_bit),
      .vio_tg_status_first_read_bit_valid(vio_tg_status_first_read_bit_valid),
      .vio_tg_status_first_read_bit(vio_tg_status_first_read_bit),
      .vio_tg_status_err_bit_sticky_valid(vio_tg_status_err_bit_sticky_valid),
      .vio_tg_status_err_bit_sticky(vio_tg_status_err_bit_sticky),
      .tg_read_test_en(tg_read_test_en),
      .tg_read_test_done(tg_read_test_done),
      .tg_read_test_valid(tg_read_test_valid),
      .tg_read_test_addr(tg_read_test_addr),
      .vio_tg_status_err_type_valid(vio_tg_status_err_type_valid),
      .vio_tg_status_err_type(vio_tg_status_err_type)
      );

   // *************************************************************************    
   // Watch Dog
   // - Check if there is
   //   1) Read/Write Command issued
   //   2) Read Data return
   //   within a fixed number of cycle when TG is activated
   // *************************************************************************    
   reg [15:0] watch_dog_cnt;
   wire       watch_dog_enable;
   reg        watch_dog_rst;
   
   assign watch_dog_enable = (tg_instr_exe_s || 
			      tg_instr_pausewait_s ||
			      tg_instr_ldwait_s ||
			      tg_instr_dnwait_s ||			      
			      tg_instr_rwwait_s ||
			      tg_instr_errwait_s);
   always@(posedge tg_clk) begin
      if (tg_rst | tg_rst_int[14]) begin
	 watch_dog_rst <= #TCQ 'h0;
      end
      else begin
	 watch_dog_rst <= #TCQ app_en | (|app_rd_data_valid_r);
      end
   end

   always@(posedge tg_clk) begin
      if (tg_rst | tg_rst_int[14] | watch_dog_rst | tg_instr_load_s_p2) begin
	 watch_dog_cnt <= #TCQ 'h0;
      end
      else if (watch_dog_enable && ~vio_tg_status_watch_dog_hang) begin
	 watch_dog_cnt <= #TCQ watch_dog_cnt + 'h1;
      end
   end

   assign vio_tg_status_done           = tg_instr_done_s;
   assign vio_tg_status_watch_dog_hang = (watch_dog_cnt > TG_WATCH_DOG_MAX_CNT);

   always@(posedge tg_clk) begin
      if (tg_rst || tg_rst_int[5]) begin
	 vio_tg_status_wr_done <= #TCQ 'h0;
      end
      else begin
	 vio_tg_status_wr_done <= #TCQ ((arc_tg_instr_ldwait_load && tg_instr_ldwait_s) ||  (arc_tg_instr_dnwait_done && tg_instr_dnwait_s)) &&
				  (tg_curr_rw_mode == TG_RW_MODE_WRITE_READ);
      end
   end
   
   //*******************************************************************************
   // ILA debug (399)
   /*
   assign tg_ila_debug = {tg_instr_sm_ps,       // 4
			  tg_curr_instr_ptr,    // 6
			  tg_curr_addr_mode,    // 4
			  tg_curr_data_mode,    // 4
			  tg_curr_rw_mode,      // 2
			  tg_curr_num_of_iter,  // 32
			  app_en,               // 1
			  app_wdf_wren,         // 1
			  app_rdy,              // 1
			  app_wdf_rdy,          // 1
			  app_cmd,              // 6 RLD3-BL4-W36
			  app_addr,             // 48 RLD3-BL4-W36
			  app_wdf_data,         // 288 RLD3-BL4-W36
			  app_rd_data_valid     // 1
			  };
   */
   //*******************************************************************************
   //synthesis translate_off
   always@(posedge tg_clk) begin
`ifndef USE_FIFO
      // Flag User if Write address wrapped around to the first written address
      if (tg_instr_exe_s_r && app_wdf_wren) begin
	 REPEATED_ADDR: assert (~app_wdf_write_addr_repeat) begin
	 end
	 else begin
	    $display ($time, "Warning: Write Address Wrapped around\n It could create false error if same address is written with different data more than once\n");
	 end
      end
`else
      // Need to add assertion when FIFO is used
`endif            
   end
   //synthesis translate_on     
   
endmodule // tg_top
