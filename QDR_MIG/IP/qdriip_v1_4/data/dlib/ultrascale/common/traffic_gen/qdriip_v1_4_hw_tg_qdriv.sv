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
// This is Traffic Generator top level wrapper for QDRIV interface.
// Interface to communicated with APP interface.
// Reference        :
// Revision History :
//*****************************************************************************

`timescale 1ps / 1ps

module qdriip_v1_4_19_hw_tg_qdriv #(
  parameter SIMULATION       = "FALSE",        
  parameter TCQ              = 100,
  parameter MEM_ARCH         = "ULTRASCALE", // Memory Architecture: ULTRASCALE
  parameter MEM_TYPE         = "QDRIV",      // QDRIV
  parameter APP_DATA_WIDTH   = 288,        // QDRIV data bus width for each port.
  parameter APP_ADDR_WIDTH   = 22*4,         // QDRIV Address bus width for each port.
  parameter APP_CMD_WIDTH    = 2*4,
  parameter NUM_DQ_PINS      = 36,        // QDRIV data bus width for each port.
  parameter nCK_PER_CLK      = 4,
  parameter CMD_PER_CLK      = 4,
  parameter NUM_PORT         = 2,
			      
  // Parameter for 2:1 controller in BL8 mode
  parameter EN_2_1_CONVERTER   = "FALSE",
			
  parameter TG_PATTERN_MODE_PRBS_ADDR_SEED = 44'hba987654321,
  parameter TG_PATTERN_MODE_PRBS_DATA_WIDTH = 23,
  parameter [APP_DATA_WIDTH-1:0] TG_PATTERN_MODE_LINEAR_DATA_SEED = 1152'h777777777_777777777_666666666_666666666_555555555_555555555_444444444_444444444_333333333_333333333_222222222_222222222_111111111_111111111_000000000_000000000_777777777_777777777_666666666_666666666_555555555_555555555_444444444_444444444_333333333_333333333_222222222_222222222_111111111_111111111_000000000_000000000,
  parameter TG_WATCH_DOG_MAX_CNT = 16'd10000,
  parameter TG_INSTR_SM_WIDTH  = 4,
  parameter DEFAULT_MODE = 0
  )
  (
  // ********* ALL SIGNALS AT THIS INTERFACE ARE ACTIVE HIGH SIGNALS ********/
   input 				       clk, // memory controller (MC) user interface (UI) clock
   input 				       rst, // MC UI reset signal.
   input 				       init_calib_complete, // MC calibration done signal coming from MC UI.
/*
   // DDR3/4, RLD3, QDRIIP Shared Interface
   input 				       app_rdy, // cmd fifo ready signal coming from MC UI.
   input 				       app_wdf_rdy, // write data fifo ready signal coming from MC UI.
   input [CMD_PER_CLK_2_1-1:0] 		       app_rd_data_valid, // read data valid signal coming from MC UI
   input [APP_DATA_WIDTH-1 : 0] 	       app_rd_data, // read data bus coming from MC UI
   output [APP_CMD_WIDTH-1 : 0] 	       app_cmd, // command bus to the MC UI
   output [APP_ADDR_WIDTH-1 : 0] 	       app_addr, // address bus to the MC UI
   output 				       app_en, // command enable signal to MC UI.
   output [(APP_DATA_WIDTH/DM_WIDTH)-1 : 0]    app_wdf_mask, // write data mask signal which
                                              // is tied to 0 in this example.
   output [APP_DATA_WIDTH-1: 0] 	       app_wdf_data, // write data bus to MC UI.
   output 				       app_wdf_end, // write burst end signal to MC UI
   output 				       app_wdf_wren, // write enable signal to MC UI

  // QDRIIP Interface
   output 				       app_wdf_en, // QDRIIP, write enable
   output [APP_ADDR_WIDTH-1:0] 		       app_wdf_addr, // QDRIIP, write address
   output [APP_CMD_WIDTH-1:0] 		       app_wdf_cmd, // QDRIIP write command
*/
   // QDRIV Interface
   output reg 				       app_cmd_en_a,
   output reg [APP_CMD_WIDTH-1:0] 	       app_cmd_a,
   output reg [APP_ADDR_WIDTH-1:0] 	       app_addr_a,
   output reg [APP_DATA_WIDTH-1:0] 	       app_wrdata_a,
   input 				       app_cmd_rdy_a,
   input [APP_DATA_WIDTH-1:0] 		       app_rddata_a,
   input [CMD_PER_CLK-1:0] 		       app_rddata_valid_a,
   output reg 				       app_cmd_en_b,
   output reg [APP_CMD_WIDTH-1:0] 	       app_cmd_b,
   output reg [APP_ADDR_WIDTH-1:0] 	       app_addr_b,
   output reg [APP_DATA_WIDTH-1:0] 	       app_wrdata_b,
   input 				       app_cmd_rdy_b,
   input [APP_DATA_WIDTH-1:0] 		       app_rddata_b,
   input [CMD_PER_CLK-1:0] 		       app_rddata_valid_b,
   output reg 				       compare_error, // Memory READ_DATA and example TB
                                              // WRITE_DATA compare error.

   input [NUM_PORT-1:0] 		       vio_tg_rst, // TG reset TG
   input [NUM_PORT-1:0] 		       vio_tg_start, // TG start enable TG
   input [NUM_PORT-1:0] 		       vio_tg_restart, // TG restart
   input [NUM_PORT-1:0] 		       vio_tg_pause, // TG pause (level signal)
   input [NUM_PORT-1:0] 		       vio_tg_err_chk_en, // If Error check is enabled (level signal), 
                                                                  //    TG will stop after first error. 
                                                                  // Else, 
                                                                  //    TG will continue on the rest of the programmed instructions
   input [NUM_PORT-1:0] 		       vio_tg_err_clear, // Clear Error excluding sticky bit (pos edge triggered)
   input [NUM_PORT-1:0] 		       vio_tg_err_clear_all, // Clear Error including sticky bit (pos edge triggered)
   input [NUM_PORT-1:0] 		       vio_tg_err_continue, // Continue run after Error detected (pos edge triggered)
    // TG programming interface
    // - instruction table programming interface
   input 				       vio_tg_instr_program_en, // VIO to enable instruction programming
   input 				       vio_tg_direct_instr_en, // VIO to enable direct instruction
   input [4:0] 				       vio_tg_instr_num, // VIO to program instruction number
   input [3:0] 				       vio_tg_instr_addr_mode, // VIO to program address mode
   input [3:0] 				       vio_tg_instr_data_mode, // VIO to program data mode
   input [3:0] 				       vio_tg_instr_rw_mode, // VIO to program read/write mode
   input [1:0] 				       vio_tg_instr_rw_submode, // VIO to program read/write submode
   input [2:0] 				       vio_tg_instr_victim_mode, // VIO to program victim mode
   input [31:0] 			       vio_tg_instr_num_of_iter, // VIO to program number of iteration per instruction
   input [9:0] 				       vio_tg_instr_m_nops_btw_n_burst_m, // VIO to program number of NOPs between BURSTs
   input [31:0] 			       vio_tg_instr_m_nops_btw_n_burst_n, // VIO to program number of BURSTs between NOPs
   input [5:0] 				       vio_tg_instr_nxt_instr, // VIO to program next instruction pointer
    // TG PRBS Data Seed programming interface
   input 				       vio_tg_seed_program_en, // VIO to enable prbs data seed programming
   input [7:0] 				       vio_tg_seed_num, // VIO to program prbs data seed number
   input [TG_PATTERN_MODE_PRBS_DATA_WIDTH-1:0] vio_tg_seed, // VIO to program prbs data seed
    // - global parameter register
   input [7:0] 				       vio_tg_glb_victim_bit, // Define Victim bit in data pattern
   input [4:0] 				       vio_tg_glb_victim_aggr_delay, // Define aggressor pattern to be N-clk-delay of victim pattern
   //input [APP_ADDR_WIDTH/CMD_PER_CLK-1:0]      vio_tg_glb_start_addr,
   input [1:0] 				       vio_tg_glb_qdriv_rw_submode,
    // - status register
   output [TG_INSTR_SM_WIDTH-1:0] 	       vio_tg_status_state[NUM_PORT],
   output [NUM_PORT-1:0] 		       vio_tg_status_err_bit_valid, // Intermediate error detected
   output [APP_DATA_WIDTH-1:0] 		       vio_tg_status_err_bit[NUM_PORT], // Intermediate error bit pattern
   output [APP_ADDR_WIDTH-1:0] 		       vio_tg_status_err_addr[NUM_PORT], // Intermediate error address
   output [NUM_PORT-1:0] 		       vio_tg_status_exp_bit_valid, // immediate expected bit
   output [APP_DATA_WIDTH-1:0] 		       vio_tg_status_exp_bit[NUM_PORT],
   output [NUM_PORT-1:0] 		       vio_tg_status_read_bit_valid, // immediate read data bit
   output [APP_DATA_WIDTH-1:0] 		       vio_tg_status_read_bit[NUM_PORT],
   output [NUM_PORT-1:0] 		       vio_tg_status_first_err_bit_valid, // first logged error bit and address
   output [APP_DATA_WIDTH-1:0] 		       vio_tg_status_first_err_bit[NUM_PORT],
   output [APP_ADDR_WIDTH-1:0] 		       vio_tg_status_first_err_addr[NUM_PORT],
   output [NUM_PORT-1:0] 		       vio_tg_status_first_exp_bit_valid, // first logged error, expected data and address
   output [APP_DATA_WIDTH-1:0] 		       vio_tg_status_first_exp_bit[NUM_PORT],
   output [NUM_PORT-1:0] 		       vio_tg_status_first_read_bit_valid, // first logged error, read data and address
   output [APP_DATA_WIDTH-1:0] 		       vio_tg_status_first_read_bit[NUM_PORT],
   output [NUM_PORT-1:0] 		       vio_tg_status_err_bit_sticky_valid, // Accumulated error detected
   output [APP_DATA_WIDTH-1:0] 		       vio_tg_status_err_bit_sticky[NUM_PORT], // Accumulated error bit pattern
   output [NUM_PORT-1:0] 		       vio_tg_status_err_type_valid, // Read/Write error detected
   output [NUM_PORT-1:0] 		       vio_tg_status_err_type, // Read/Write error type

   output [NUM_PORT-1:0] 		       vio_tg_status_wr_done, // In Write Read mode, this signal will be pulsed after every Write/Read cycle
   output reg [NUM_PORT-1:0] 		       vio_tg_status_done,
   output [NUM_PORT-1:0] 		       vio_tg_status_watch_dog_hang, // Watch dog detected traffic stopped unexpectedly
   output 				       tg_ila_debug, // place holder for ILA
   output [APP_DATA_WIDTH-1:0] 		       exp_read_data_A,
   output [APP_DATA_WIDTH-1:0] 		       exp_read_data_B
  );

   localparam TG0   = 1'b0;
   localparam TG1   = 1'b1;
   localparam PORTA = 1'b0;
   localparam PORTB = 1'b1;

   localparam WRITE_OPCODE = 2'b11;
   localparam READ_OPCODE  = 2'b10;

   // QDRIV Read/Write submode
   // SUBMODE under DATA_MODE
   localparam TG_RW_SUBMODE_QDRIV_PORTX_RW        = 2'b00; // PortA and PortB Write then Read
   localparam TG_RW_SUBMODE_QDRIV_PORTA_W_PORTB_R = 2'b01; // PortA Write and PortB Read
   localparam TG_RW_SUBMODE_QDRIV_PORTB_W_PORTA_R = 2'b10; // PortA Write and PortB Read
   localparam TG_RW_SUBMODE_QDRIV_PORTAB_RW       = 2'b11; // PortA and PortB with Mixed Read/Write
   
   reg [NUM_PORT-1:0] 			       app_rdy;   
   reg [APP_DATA_WIDTH-1:0] 		       app_rd_data[NUM_PORT];
   reg [NUM_PORT-1:0] 			       app_rd_data_end;
   reg [CMD_PER_CLK-1:0] 		       app_rd_data_valid[NUM_PORT];
   reg [NUM_PORT-1:0] 			       app_wdf_rdy;
   
   reg [NUM_PORT-1:0] 			       app_en;
   reg [APP_CMD_WIDTH-1:0] 		       app_cmd[NUM_PORT];
   reg [APP_ADDR_WIDTH-1:0] 		       app_addr[NUM_PORT];

   reg [NUM_PORT-1:0] 			       app_wdf_wren;
   reg [NUM_PORT-1:0] 			       app_wdf_end;
   //reg [APP_MASK_WIDTH-1:0] 		       app_wdf_mask[NUM_PORT];
   reg [APP_DATA_WIDTH-1:0] 		       app_wdf_data[NUM_PORT];

   reg [NUM_PORT-1:0] 			       app_wdf_en; // QDRIIP, write enable
   reg [APP_ADDR_WIDTH-1:0] 		       app_wdf_addr[NUM_PORT]; // QDRIIP, write address
   reg [APP_CMD_WIDTH-1:0] 		       app_wdf_cmd[NUM_PORT]; // QDRIIP write command
   
   reg [NUM_PORT-1:0] 			       data_compare_error;   

   reg [APP_ADDR_WIDTH/CMD_PER_CLK-1:0]        tg_glb_start_addr[NUM_PORT];
   
   reg [CMD_PER_CLK-1:0] 		       app_rd_map[NUM_PORT];
   reg [CMD_PER_CLK-1:0] 		       app_wr_map[NUM_PORT];
   reg [APP_CMD_WIDTH-1:0] 		       app_cmd_mix_a;
   reg [APP_ADDR_WIDTH-1:0] 		       app_addr_mix_a;
   reg [APP_CMD_WIDTH-1:0] 		       app_cmd_mix_b;
   reg [APP_ADDR_WIDTH-1:0] 		       app_addr_mix_b;   
   reg [APP_DATA_WIDTH-1:0] 		       app_wrdata_mix_a;
   reg [APP_DATA_WIDTH-1:0] 		       app_wrdata_mix_b;   
   
   reg [NUM_PORT-1:0] 			       tg_status_done;
   
   wire [CMD_PER_CLK-1:0] 		       rd_data_request_dout[NUM_PORT];
   wire [NUM_PORT-1:0] 			       rd_data_request_fifo_full;
   wire [NUM_PORT-1:0] 			       rd_data_request_fifo_empty;
   wire [CMD_PER_CLK-1:0] 		       rd_data_request_mask[NUM_PORT];
   
   wire [APP_DATA_WIDTH/CMD_PER_CLK-1:0]       rd_data_fifo[NUM_PORT][CMD_PER_CLK];
   wire [CMD_PER_CLK-1:0] 		       rd_data_fifo_full[NUM_PORT];
   wire [CMD_PER_CLK-1:0] 		       rd_data_fifo_empty[NUM_PORT];
   
   wire [NUM_PORT-1:0] 			       rd_data_fifo_read;

   integer 				       i, j;
   genvar 				       r, s;

   always@(*) begin
      for(i=0; i<NUM_PORT; i=i+1) begin
	 for(j=0; j<CMD_PER_CLK; j=j+1) begin
	    //app_rd_map[i][j] = app_en[i]     && app_addr[i][CMD_PER_CLK+2]     ? ~app_addr[i][j+2]    :  app_addr[i][j+2];
	    //app_wr_map[i][j] = app_wdf_en[i] && app_wdf_addr[i][CMD_PER_CLK+2] ? app_wdf_addr[i][j+2] : ~app_wdf_addr[i][j+2];
	    app_rd_map[i][j] = app_en[i]     ? app_addr[i][CMD_PER_CLK+2]     ? app_addr[i][j+2]     : ~app_addr[i][j+2]     : 1'b0;
	    app_wr_map[i][j] = app_wdf_en[i] ? app_wdf_addr[i][CMD_PER_CLK+2] ? app_wdf_addr[i][j+2] : ~app_wdf_addr[i][j+2] : 1'b0;
	 end
      end
      
      for(i=0; i<CMD_PER_CLK; i=i+1) begin
	 app_cmd_mix_a[i*2+:2] = app_rd_map[TG0][i] ? app_cmd[TG0][i*2+:2] :
	                         app_wr_map[TG0][i] ? app_wdf_cmd[TG0][i*2+:2] :
	                         2'b00;
	 app_cmd_mix_b[i*2+:2] = app_rd_map[TG1][i] ? app_cmd[TG1][i*2+:2] :
				 app_wr_map[TG1][i] ? app_wdf_cmd[TG1][i*2+:2] :
	                         2'b00;
	 app_addr_mix_a[i*APP_ADDR_WIDTH/CMD_PER_CLK+:APP_ADDR_WIDTH/CMD_PER_CLK]   = app_rd_map[TG0][i] ? app_addr[TG0][i*APP_ADDR_WIDTH/CMD_PER_CLK+:APP_ADDR_WIDTH/CMD_PER_CLK] :
										      app_wr_map[TG0][i] ? app_wdf_addr[TG0][i*APP_ADDR_WIDTH/CMD_PER_CLK+:APP_ADDR_WIDTH/CMD_PER_CLK] :
										      {APP_ADDR_WIDTH/CMD_PER_CLK{1'b0}};
	 app_addr_mix_b[i*APP_ADDR_WIDTH/CMD_PER_CLK+:APP_ADDR_WIDTH/CMD_PER_CLK]   = app_rd_map[TG1][i] ? app_addr[TG1][i*APP_ADDR_WIDTH/CMD_PER_CLK+:APP_ADDR_WIDTH/CMD_PER_CLK] :
										      app_wr_map[TG1][i] ? app_wdf_addr[TG1][i*APP_ADDR_WIDTH/CMD_PER_CLK+:APP_ADDR_WIDTH/CMD_PER_CLK] :
										      {APP_ADDR_WIDTH/CMD_PER_CLK{1'b0}};
	 app_wrdata_mix_a[i*APP_DATA_WIDTH/CMD_PER_CLK+:APP_DATA_WIDTH/CMD_PER_CLK] = app_rd_map[TG0][i] ? {APP_DATA_WIDTH/CMD_PER_CLK{1'b0}} :
										      app_wr_map[TG0][i] ? app_wdf_data[TG0][i*APP_DATA_WIDTH/CMD_PER_CLK+:APP_DATA_WIDTH/CMD_PER_CLK] :
										      {APP_DATA_WIDTH/CMD_PER_CLK{1'b0}};
	 app_wrdata_mix_b[i*APP_DATA_WIDTH/CMD_PER_CLK+:APP_DATA_WIDTH/CMD_PER_CLK] = app_rd_map[TG1][i] ? {APP_DATA_WIDTH/CMD_PER_CLK{1'b0}} :
										      app_wr_map[TG1][i] ? app_wdf_data[TG1][i*APP_DATA_WIDTH/CMD_PER_CLK+:APP_DATA_WIDTH/CMD_PER_CLK] :
										      {APP_DATA_WIDTH/CMD_PER_CLK{1'b0}};
      end      
   end
   
// QDRIV TG and Internal HW TG connectivity
   always@(*) begin
      if (vio_tg_glb_qdriv_rw_submode == TG_RW_SUBMODE_QDRIV_PORTX_RW) begin
	 // TG0 => Port A
	 app_cmd_en_a       = app_en[TG0] || app_wdf_en[TG0];
	 app_cmd_a          = app_en[TG0] ? app_cmd[TG0]  : app_wdf_cmd[TG0];
	 app_addr_a         = app_en[TG0] ? app_addr[TG0] : app_wdf_addr[TG0];
	 app_wrdata_a       = app_wdf_data[TG0];

	 app_rdy[TG0]       = app_cmd_rdy_a;
	 app_wdf_rdy[TG0]   = app_cmd_rdy_a;

	 app_rd_data[TG0]       = app_rddata_a;
	 app_rd_data_valid[TG0] = app_rddata_valid_a;

	 tg_glb_start_addr[TG0] = 'h0;

	 // TG1 => Port B
	 app_cmd_en_b       = app_en[TG1] || app_wdf_en[TG1];
	 app_cmd_b          = app_en[TG1] ? app_cmd[TG1]  : app_wdf_cmd[TG1];
	 app_addr_b         = app_en[TG1] ? app_addr[TG1] : app_wdf_addr[TG1];
	 app_wrdata_b       = app_wdf_data[TG1];

	 app_rdy[TG1]       = app_cmd_rdy_b;
	 app_wdf_rdy[TG1]   = app_cmd_rdy_b;

	 app_rd_data[TG1]       = app_rddata_b;
	 app_rd_data_valid[TG1] = app_rddata_valid_b;

	 tg_glb_start_addr[TG1] = 2**(APP_ADDR_WIDTH/CMD_PER_CLK)/CMD_PER_CLK/2;

	 // Common output
	 compare_error      = data_compare_error[TG0] || data_compare_error[TG1];
	 vio_tg_status_done = tg_status_done;
      end
      else if (vio_tg_glb_qdriv_rw_submode == TG_RW_SUBMODE_QDRIV_PORTA_W_PORTB_R) begin
	 // TG0 write => PortA 
	 // TG0 read  => PortB
	 app_cmd_en_a       = app_wdf_en[TG0];
	 app_cmd_a          = app_wdf_cmd[TG0];
	 app_addr_a         = app_wdf_addr[TG0];
	 app_wrdata_a       = app_wdf_data[TG0];

	 app_rdy[TG0]       = app_cmd_rdy_b;
	 app_wdf_rdy[TG0]   = app_cmd_rdy_a;

	 app_rd_data[TG0]       = app_rddata_b;
	 app_rd_data_valid[TG0] = app_rddata_valid_b;

	 tg_glb_start_addr[TG0] = 'h0;

	 // TG1 idle
	 app_cmd_en_b       = app_en[TG0];
	 app_cmd_b          = app_cmd[TG0];
	 app_addr_b         = app_addr[TG0];
	 app_wrdata_b       = 'h0;

	 app_rdy[TG1]       = 'h0;
	 app_wdf_rdy[TG1]   = 'h0;

	 app_rd_data[TG1]       = 'h0;
	 app_rd_data_valid[TG1] = 'h0;

	 tg_glb_start_addr[TG1] = 'h0;

	 // Common output
	 compare_error      = data_compare_error[TG0];
	 vio_tg_status_done[TG0] = tg_status_done[TG0];
	 vio_tg_status_done[TG1] = 1'b1;
      end
      else if (vio_tg_glb_qdriv_rw_submode == TG_RW_SUBMODE_QDRIV_PORTB_W_PORTA_R) begin
	 // TG0 write => PortB 
	 // TG0 read  => PortA
	 app_cmd_en_b       = app_wdf_en[TG0];
	 app_cmd_b          = app_wdf_cmd[TG0];
	 app_addr_b         = app_wdf_addr[TG0];
	 app_wrdata_b       = app_wdf_data[TG0];

	 app_rdy[TG0]       = app_cmd_rdy_a;
	 app_wdf_rdy[TG0]   = app_cmd_rdy_b;

	 app_rd_data[TG0]       = app_rddata_a;
	 app_rd_data_valid[TG0] = app_rddata_valid_a;

	 tg_glb_start_addr[TG0] = 'h0;

	 // TG1 idle
	 app_cmd_en_a       = app_en[TG0];
	 app_cmd_a          = app_cmd[TG0];
	 app_addr_a         = app_addr[TG0];
	 app_wrdata_a       = 'h0;

	 app_rdy[TG1]       = 'h0;
	 app_wdf_rdy[TG1]   = 'h0;

	 app_rd_data[TG1]       = 'h0;
	 app_rd_data_valid[TG1] = 'h0;

	 tg_glb_start_addr[TG1] = 'h0;

	 // Common output
	 compare_error      = data_compare_error[TG0];
	 vio_tg_status_done[TG0] = tg_status_done[TG0];
	 vio_tg_status_done[TG1] = 1'b1;	 
      end
      else begin // TG_RW_SUBMODE_QDRIV_PORTAB_RW
	 // TG0 => Port A
	 app_cmd_en_a       = app_en[TG0] || app_wdf_en[TG0];
	 app_cmd_a          = app_cmd_mix_a;
	 app_addr_a         = app_addr_mix_a;
	 app_wrdata_a       = app_wrdata_mix_a;                               //Nice to Zero out Non-Write data

	 app_rdy[TG0]       = app_cmd_rdy_a;
	 app_wdf_rdy[TG0]   = app_cmd_rdy_a;

	 app_rd_data[TG0]       = app_rddata_a;
	 app_rd_data_valid[TG0] = app_rddata_valid_a; // Need to update hw_tg, 2:1 converter, tg_top, tg_errchecker for multiple valid bit error check handling.

	 tg_glb_start_addr[TG0] = 'h0;

	 // TG1 => Port B
	 app_cmd_en_b       = app_en[TG1] || app_wdf_en[TG1];
	 app_cmd_b          = app_cmd_mix_b;
	 app_addr_b         = app_addr_mix_b;
	 app_wrdata_b       = app_wrdata_mix_b;

	 app_rdy[TG1]       = app_cmd_rdy_b;
	 app_wdf_rdy[TG1]   = app_cmd_rdy_b;

	 app_rd_data[TG1]       = app_rddata_b;
	 app_rd_data_valid[TG1] = app_rddata_valid_b;

	 tg_glb_start_addr[TG1] = 2**(APP_ADDR_WIDTH/CMD_PER_CLK)/CMD_PER_CLK/2;

	 // Common output
	 compare_error      = data_compare_error[TG0] || data_compare_error[TG1];
	 vio_tg_status_done = tg_status_done;
      end
   end

   // Read request fifo for portA
   mig_v7_0_tg_fifo
     #(
       .TCQ(TCQ),
       .WIDTH(CMD_PER_CLK),
       .DEPTH(32),
       .LOG2DEPTH(5)
       )
   u_mig_v7_0_tg_read_request_fifo_a
     (
      .clk (clk),
      .rst (rst),
      .wren (app_cmd_en_a && app_cmd_rdy_a &&
	     ((app_cmd_a[7:6] == READ_OPCODE) ||
	      (app_cmd_a[5:4] == READ_OPCODE) ||
	      (app_cmd_a[3:2] == READ_OPCODE) ||
	      (app_cmd_a[1:0] == READ_OPCODE))),
      .rden (rd_data_fifo_read[PORTA] && ~rd_data_request_fifo_empty[PORTA]),
      .din ({(app_cmd_a[7:6] == READ_OPCODE),
	     (app_cmd_a[5:4] == READ_OPCODE),
	     (app_cmd_a[3:2] == READ_OPCODE),
	     (app_cmd_a[1:0] == READ_OPCODE)}),
      .dout (rd_data_request_dout[PORTA]),
      .full (rd_data_request_fifo_full[PORTA]),
      .empty (rd_data_request_fifo_empty[PORTA])
      );

   // Read request fifo for portB
   mig_v7_0_tg_fifo
     #(
       .TCQ(TCQ),
       .WIDTH(CMD_PER_CLK),
       .DEPTH(32),
       .LOG2DEPTH(5)
       )
   u_mig_v7_0_tg_read_request_fifo_b
     (
      .clk (clk),
      .rst (rst),
      .wren (app_cmd_en_b && app_cmd_rdy_b &&
	     ((app_cmd_b[7:6] == READ_OPCODE) ||
	      (app_cmd_b[5:4] == READ_OPCODE) ||
	      (app_cmd_b[3:2] == READ_OPCODE) ||
	      (app_cmd_b[1:0] == READ_OPCODE))),
      .rden (rd_data_fifo_read[PORTB] && ~rd_data_request_fifo_empty[PORTB]),
      .din ({(app_cmd_b[7:6] == READ_OPCODE),
	     (app_cmd_b[5:4] == READ_OPCODE),
	     (app_cmd_b[3:2] == READ_OPCODE),
	     (app_cmd_b[1:0] == READ_OPCODE)}),
      .dout (rd_data_request_dout[PORTB]),
      .full (rd_data_request_fifo_full[PORTB]),
      .empty (rd_data_request_fifo_empty[PORTB])
      );
   

   generate
      for (s = 0; s < CMD_PER_CLK; s = s + 1) begin: gen_read_data_fifo_channel
	 // Read data fifo for portA
	 mig_v7_0_tg_fifo
	       #(
		 .TCQ(TCQ),
		 .WIDTH(APP_DATA_WIDTH/CMD_PER_CLK),
		 .DEPTH(4),
		 .LOG2DEPTH(4)
		 )
	 u_mig_v7_0_tg_read_data_fifo_a
	       (
		.clk (clk),
		.rst (rst),
		.wren (app_rddata_valid_a[s]),
		.rden (rd_data_fifo_read[PORTA] & ~rd_data_fifo_empty[PORTA][s]),
		.din (app_rddata_a[s*APP_DATA_WIDTH/CMD_PER_CLK+:APP_DATA_WIDTH/CMD_PER_CLK]),
		.dout (rd_data_fifo[PORTA][s]),
		.full (rd_data_fifo_full[PORTA][s]),
		.empty (rd_data_fifo_empty[PORTA][s])
		);

	 // Read data fifo for portB
	 mig_v7_0_tg_fifo
	       #(
		 .TCQ(TCQ),
		 .WIDTH(APP_DATA_WIDTH/CMD_PER_CLK),
		 .DEPTH(4),
		 .LOG2DEPTH(4)
		 )
	 u_mig_v7_0_tg_read_data_fifo_b
	       (
		.clk (clk),
		.rst (rst),
		.wren (app_rddata_valid_b[s]),
		.rden (rd_data_fifo_read[PORTB] & ~rd_data_fifo_empty[PORTB][s]),
		.din (app_rddata_b[s*APP_DATA_WIDTH/CMD_PER_CLK+:APP_DATA_WIDTH/CMD_PER_CLK]),
		.dout (rd_data_fifo[PORTB][s]),
		.full (rd_data_fifo_full[PORTB][s]),
		.empty (rd_data_fifo_empty[PORTB][s])
		);	 
      end
   endgenerate

   assign rd_data_request_mask[PORTA] = ({CMD_PER_CLK{~rd_data_request_fifo_empty[PORTA]}} & rd_data_request_dout[PORTA]);
   assign rd_data_request_mask[PORTB] = ({CMD_PER_CLK{~rd_data_request_fifo_empty[PORTB]}} & rd_data_request_dout[PORTB]);
   
   assign rd_data_fifo_read[PORTA] = ((~rd_data_fifo_empty[PORTA]) & rd_data_request_mask[PORTA]) == rd_data_request_mask[PORTA];
   assign rd_data_fifo_read[PORTB] = ((~rd_data_fifo_empty[PORTB]) & rd_data_request_mask[PORTB]) == rd_data_request_mask[PORTB];

// TG instantiation   
// Port A
   qdriip_v1_4_19_hw_tg #
     (
      .SIMULATION     (SIMULATION),
      .TCQ            (TCQ),
      .MEM_ARCH       (MEM_ARCH),
      .MEM_TYPE       (MEM_TYPE),
      
      .APP_DATA_WIDTH (APP_DATA_WIDTH),
      .APP_ADDR_WIDTH (APP_ADDR_WIDTH),
      .APP_CMD_WIDTH  (APP_CMD_WIDTH),
      .NUM_DQ_PINS    (NUM_DQ_PINS),     
      
      .nCK_PER_CLK    (nCK_PER_CLK),
      .CMD_PER_CLK    (CMD_PER_CLK),
      .TG_PATTERN_MODE_PRBS_ADDR_SEED (TG_PATTERN_MODE_PRBS_ADDR_SEED),
      .TG_PATTERN_MODE_PRBS_DATA_WIDTH (TG_PATTERN_MODE_PRBS_DATA_WIDTH),
      .TG_PATTERN_MODE_LINEAR_DATA_SEED (TG_PATTERN_MODE_LINEAR_DATA_SEED),
      .TG_WATCH_DOG_MAX_CNT (TG_WATCH_DOG_MAX_CNT),
      .TG_INSTR_SM_WIDTH(TG_INSTR_SM_WIDTH),
      .DEFAULT_MODE(DEFAULT_MODE)
      )
   u_qdriip_v1_4_19_hw_tg_tg0
     (
      .clk                                     (clk),
      .rst                                     (rst),
      .app_rdy                                 (app_rdy[TG0]),
      .init_calib_complete                     (init_calib_complete),
      .app_rd_data_valid                       (app_rd_data_valid[TG0]),
      .app_rd_data                             (app_rd_data[TG0]),
      .app_wdf_rdy                             (app_wdf_rdy[TG0]),
      .app_en                                  (app_en[TG0]),
      .app_cmd                                 (app_cmd[TG0]),
      .app_addr                                (app_addr[TG0]),
      .app_wdf_wren                            (app_wdf_wren[TG0]),
      .app_wdf_end                             (app_wdf_end[TG0]),
      //.app_wdf_mask                            (app_wdf_mask[TG0]),
      .app_wdf_data                            (app_wdf_data[TG0]),
      .app_wdf_en                              (app_wdf_en[TG0]),
      .app_wdf_cmd                             (app_wdf_cmd[TG0]),
      .app_wdf_addr                            (app_wdf_addr[TG0]),
      
      .compare_error                           (data_compare_error[TG0]),       
      
      .vio_tg_rst(vio_tg_rst[TG0]),
      .vio_tg_start(vio_tg_start[TG0]),
      .vio_tg_restart(vio_tg_restart[TG0]),
      .vio_tg_pause(vio_tg_pause[TG0]),
      .vio_tg_err_chk_en(vio_tg_err_chk_en[TG0]),
      .vio_tg_err_clear(vio_tg_err_clear[TG0]),
      .vio_tg_err_clear_all(vio_tg_err_clear_all[TG0]),
      .vio_tg_err_continue(vio_tg_err_continue[TG0]),
  
      .vio_tg_instr_program_en(vio_tg_instr_program_en),
      .vio_tg_direct_instr_en(vio_tg_direct_instr_en),
      .vio_tg_instr_num(vio_tg_instr_num),
      .vio_tg_instr_addr_mode(vio_tg_instr_addr_mode),
      .vio_tg_instr_data_mode(vio_tg_instr_data_mode),
      .vio_tg_instr_rw_mode(vio_tg_instr_rw_mode),
      .vio_tg_instr_rw_submode(vio_tg_instr_rw_submode),
      .vio_tg_instr_victim_mode(vio_tg_instr_victim_mode),
      .vio_tg_instr_num_of_iter(vio_tg_instr_num_of_iter),
      .vio_tg_instr_m_nops_btw_n_burst_m(vio_tg_instr_m_nops_btw_n_burst_m),
      .vio_tg_instr_m_nops_btw_n_burst_n(vio_tg_instr_m_nops_btw_n_burst_n),
      .vio_tg_instr_nxt_instr(vio_tg_instr_nxt_instr),
      
      .vio_tg_seed_program_en(vio_tg_seed_program_en),
      .vio_tg_seed_num(vio_tg_seed_num),
      .vio_tg_seed(vio_tg_seed),
      
      .vio_tg_glb_victim_bit(vio_tg_glb_victim_bit),		    
      .vio_tg_glb_victim_aggr_delay(vio_tg_glb_victim_aggr_delay),	    
      .vio_tg_glb_start_addr(tg_glb_start_addr[TG0]),
      .vio_tg_glb_qdriv_rw_submode(vio_tg_glb_qdriv_rw_submode),
      
      .vio_tg_status_state(vio_tg_status_state[TG0]),
      .vio_tg_status_err_bit_valid(vio_tg_status_err_bit_valid[TG0]),
      .vio_tg_status_err_bit(vio_tg_status_err_bit[TG0]), 	    
      .vio_tg_status_err_addr(vio_tg_status_err_addr[TG0]),
      .vio_tg_status_exp_bit_valid(vio_tg_status_exp_bit_valid[TG0]),
      .vio_tg_status_exp_bit(vio_tg_status_exp_bit[TG0]),
      .vio_tg_status_read_bit_valid(vio_tg_status_read_bit_valid[TG0]),
      .vio_tg_status_read_bit(vio_tg_status_read_bit[TG0]),
      
      .vio_tg_status_first_err_bit_valid(vio_tg_status_first_err_bit_valid[TG0]),
      .vio_tg_status_first_err_bit(vio_tg_status_first_err_bit[TG0]),
      .vio_tg_status_first_err_addr(vio_tg_status_first_err_addr[TG0]),
      .vio_tg_status_first_exp_bit_valid(vio_tg_status_first_exp_bit_valid[TG0]),
      .vio_tg_status_first_exp_bit(vio_tg_status_first_exp_bit[TG0]),
      .vio_tg_status_first_read_bit_valid(vio_tg_status_first_read_bit_valid[TG0]),
      .vio_tg_status_first_read_bit(vio_tg_status_first_read_bit[TG0]),
      .vio_tg_status_err_bit_sticky_valid(vio_tg_status_err_bit_sticky_valid[TG0]),
      .vio_tg_status_err_bit_sticky(vio_tg_status_err_bit_sticky[TG0]),          
      .vio_tg_status_err_type_valid(vio_tg_status_err_type_valid[TG0]),
      .vio_tg_status_err_type(vio_tg_status_err_type[TG0]),

      .vio_tg_status_wr_done(vio_tg_status_wr_done[TG0]),
      .vio_tg_status_done(tg_status_done[TG0]),
      .vio_tg_status_watch_dog_hang(vio_tg_status_watch_dog_hang[TG0]),
      .exp_read_data (exp_read_data_A)
      );


// Port B
   qdriip_v1_4_19_hw_tg #
     (
      .SIMULATION     (SIMULATION),
      .TCQ            (TCQ),
      .MEM_ARCH       (MEM_ARCH),
      .MEM_TYPE       (MEM_TYPE),
      .APP_DATA_WIDTH (APP_DATA_WIDTH),
      .APP_ADDR_WIDTH (APP_ADDR_WIDTH),
      .APP_CMD_WIDTH  (APP_CMD_WIDTH),
      .NUM_DQ_PINS    (NUM_DQ_PINS),     
      
      .nCK_PER_CLK    (nCK_PER_CLK),
      .CMD_PER_CLK    (CMD_PER_CLK),
      .TG_PATTERN_MODE_PRBS_ADDR_SEED (TG_PATTERN_MODE_PRBS_ADDR_SEED),
      .TG_PATTERN_MODE_PRBS_DATA_WIDTH (TG_PATTERN_MODE_PRBS_DATA_WIDTH),
      .TG_PATTERN_MODE_LINEAR_DATA_SEED (TG_PATTERN_MODE_LINEAR_DATA_SEED),
      .TG_WATCH_DOG_MAX_CNT (TG_WATCH_DOG_MAX_CNT),
      .TG_INSTR_SM_WIDTH(TG_INSTR_SM_WIDTH)
      )
   u_qdriip_v1_4_19_hw_tg_tg1
     (
      .clk                                     (clk),
      .rst                                     (rst),
      .app_rdy                                 (app_rdy[TG1]),
      .init_calib_complete                     (init_calib_complete),
      .app_rd_data_valid                       (app_rd_data_valid[TG1]),
      .app_rd_data                             (app_rd_data[TG1]),
      .app_wdf_rdy                             (app_wdf_rdy[TG1]),
      .app_en                                  (app_en[TG1]),
      .app_cmd                                 (app_cmd[TG1]),
      .app_addr                                (app_addr[TG1]),
      .app_wdf_wren                            (app_wdf_wren[TG1]),
      .app_wdf_end                             (app_wdf_end[TG1]),
      //.app_wdf_mask                            (app_wdf_mask[TG1]),
      .app_wdf_data                            (app_wdf_data[TG1]),
      .app_wdf_en                              (app_wdf_en[TG1]),
      .app_wdf_cmd                             (app_wdf_cmd[TG1]),
      .app_wdf_addr                            (app_wdf_addr[TG1]),
      
      .compare_error                           (data_compare_error[TG1]),       
      
      .vio_tg_rst(vio_tg_rst[TG1]),
      .vio_tg_start(vio_tg_start[TG1]),
      .vio_tg_restart(vio_tg_restart[TG1]),
      .vio_tg_pause(vio_tg_pause[TG1]),
      .vio_tg_err_chk_en(vio_tg_err_chk_en[TG1]),
      .vio_tg_err_clear(vio_tg_err_clear[TG1]),
      .vio_tg_err_clear_all(vio_tg_err_clear_all[TG1]),
      .vio_tg_err_continue(vio_tg_err_continue[TG1]),

      .vio_tg_instr_program_en(vio_tg_instr_program_en),
      .vio_tg_direct_instr_en(vio_tg_direct_instr_en),
      .vio_tg_instr_num(vio_tg_instr_num),
      .vio_tg_instr_addr_mode(vio_tg_instr_addr_mode),
      .vio_tg_instr_data_mode(vio_tg_instr_data_mode),
      .vio_tg_instr_rw_mode(vio_tg_instr_rw_mode),
      .vio_tg_instr_rw_submode(vio_tg_instr_rw_submode),
      .vio_tg_instr_victim_mode(vio_tg_instr_victim_mode),
      .vio_tg_instr_num_of_iter(vio_tg_instr_num_of_iter),
      .vio_tg_instr_m_nops_btw_n_burst_m(vio_tg_instr_m_nops_btw_n_burst_m),
      .vio_tg_instr_m_nops_btw_n_burst_n(vio_tg_instr_m_nops_btw_n_burst_n),
      .vio_tg_instr_nxt_instr(vio_tg_instr_nxt_instr),
      
      .vio_tg_seed_program_en(vio_tg_seed_program_en),
      .vio_tg_seed_num(vio_tg_seed_num),
      .vio_tg_seed(vio_tg_seed),
      
      .vio_tg_glb_victim_bit(vio_tg_glb_victim_bit),		    
      .vio_tg_glb_victim_aggr_delay(vio_tg_glb_victim_aggr_delay),	    
      .vio_tg_glb_start_addr(tg_glb_start_addr[TG1]),
      .vio_tg_glb_qdriv_rw_submode(vio_tg_glb_qdriv_rw_submode),
      
      .vio_tg_status_state(vio_tg_status_state[TG1]),
      .vio_tg_status_err_bit_valid(vio_tg_status_err_bit_valid[TG1]),
      .vio_tg_status_err_bit(vio_tg_status_err_bit[TG1]), 	    
      .vio_tg_status_err_addr(vio_tg_status_err_addr[TG1]),
      .vio_tg_status_exp_bit_valid(vio_tg_status_exp_bit_valid[TG1]),
      .vio_tg_status_exp_bit(vio_tg_status_exp_bit[TG1]),
      .vio_tg_status_read_bit_valid(vio_tg_status_read_bit_valid[TG1]),
      .vio_tg_status_read_bit(vio_tg_status_read_bit[TG1]),
      
      .vio_tg_status_first_err_bit_valid(vio_tg_status_first_err_bit_valid[TG1]),
      .vio_tg_status_first_err_bit(vio_tg_status_first_err_bit[TG1]),
      .vio_tg_status_first_err_addr(vio_tg_status_first_err_addr[TG1]),
      .vio_tg_status_first_exp_bit_valid(vio_tg_status_first_exp_bit_valid[TG1]),
      .vio_tg_status_first_exp_bit(vio_tg_status_first_exp_bit[TG1]),
      .vio_tg_status_first_read_bit_valid(vio_tg_status_first_read_bit_valid[TG1]),
      .vio_tg_status_first_read_bit(vio_tg_status_first_read_bit[TG1]),
      .vio_tg_status_err_bit_sticky_valid(vio_tg_status_err_bit_sticky_valid[TG1]),
      .vio_tg_status_err_bit_sticky(vio_tg_status_err_bit_sticky[TG1]),          
      .vio_tg_status_err_type_valid(vio_tg_status_err_type_valid[TG1]),
      .vio_tg_status_err_type(vio_tg_status_err_type[TG1]),

      .vio_tg_status_wr_done(vio_tg_status_wr_done[TG1]),
      .vio_tg_status_done(tg_status_done[TG1]),
      .vio_tg_status_watch_dog_hang(vio_tg_status_watch_dog_hang[TG1]),
      .exp_read_data (exp_read_data_B)
      );
   
  //***************************************************************************
  // Reporting the test case status
  //***************************************************************************
//synthesis translate_off
generate
   if (MEM_TYPE == "QDRIV") begin
      initial
	begin : Logging
	   fork
              begin : calibration_done
		 wait (init_calib_complete);
		 wait (&vio_tg_status_done);
		 if (!compare_error) begin
		    $display("TEST PASSED");
		 end
		 else begin
		    $display("TEST FAILED: DATA ERROR");
		 end
		 repeat (10) @(posedge clk); #TCQ
		   $finish;
              end
	   join
	end
   end
endgenerate
//synthesis translate_on

endmodule