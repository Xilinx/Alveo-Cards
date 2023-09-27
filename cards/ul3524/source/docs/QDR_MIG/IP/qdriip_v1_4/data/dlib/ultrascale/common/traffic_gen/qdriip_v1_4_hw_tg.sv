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
// This is Traffic Generator top level wrapper.
// Interface to communicated with APP interface.
// Reference        :
// Revision History :
//*****************************************************************************

`timescale 1ps / 1ps

module qdriip_v1_4_19_hw_tg #(
  parameter SIMULATION       = "FALSE",        
  parameter TCQ              = 100,
  parameter MEM_ARCH         = "ULTRASCALE", // Memory Architecture: ULTRASCALE, 7SERIES
  parameter MEM_TYPE         = "DDR3", // DDR3, DDR4, RLD2, RLD3, QDRIIP, QDRIV
  parameter APP_DATA_WIDTH   = 32,        // DDR data bus width.
  parameter APP_ADDR_WIDTH   = 32,        // Address bus width of the 
  //parameter RLD_BANK_WIDTH   = 4,         // RLD3 - 4, RLD2 - 3
  parameter APP_CMD_WIDTH    = 3,
  parameter NUM_DQ_PINS      = 36,        // DDR data bus width.
                                          //memory controller user interface.
  parameter DM_WIDTH = (MEM_TYPE == "RLD3" || MEM_TYPE == "RLD2") ? 18 : 8,
  parameter nCK_PER_CLK      = 4,
  parameter CMD_PER_CLK      = 1,
  parameter ECC              = "OFF",
			
  // Parameter for 2:1 controller in BL8 mode
  parameter EN_2_1_CONVERTER   = ((MEM_ARCH == "7SERIES") && ((MEM_TYPE == "DDR3") || (MEM_TYPE == "RLD2") || (MEM_TYPE == "RLD3")) && (nCK_PER_CLK == 2) && (CMD_PER_CLK == 0.5)) ? "TRUE" : "FALSE",
  parameter APP_DATA_WIDTH_2_1 = (EN_2_1_CONVERTER == "TRUE") ? (APP_DATA_WIDTH << 1) : APP_DATA_WIDTH,
  parameter CMD_PER_CLK_2_1    = (EN_2_1_CONVERTER == "TRUE") ? 1 : CMD_PER_CLK,
			
  parameter TG_PATTERN_MODE_PRBS_ADDR_SEED = 44'hba987654321,
  parameter TG_PATTERN_MODE_PRBS_DATA_WIDTH = 23,
  parameter [APP_DATA_WIDTH_2_1-1:0] TG_PATTERN_MODE_LINEAR_DATA_SEED = 1152'h777777777_777777777_666666666_666666666_555555555_555555555_444444444_444444444_333333333_333333333_222222222_222222222_111111111_111111111_000000000_000000000_777777777_777777777_666666666_666666666_555555555_555555555_444444444_444444444_333333333_333333333_222222222_222222222_111111111_111111111_000000000_000000000,
  parameter TG_WATCH_DOG_MAX_CNT = 16'd10000,
  parameter TG_INSTR_SM_WIDTH  = 4,
  parameter DEFAULT_MODE = 0 // Default model is a Vector. For a given bit location, value 0 is disable and value 1 is enable.
			     // BIT0 definition: Add an extra instruction to default instruction table with PRBS Address and PRBS Data.
  )
  (
  // ********* ALL SIGNALS AT THIS INTERFACE ARE ACTIVE HIGH SIGNALS ********/
   input 				       clk, // memory controller (MC) user interface (UI) clock
   input 				       rst, // MC UI reset signal.
   input 				       init_calib_complete, // MC calibration done signal coming from MC UI.
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

   output 				       compare_error, // Memory READ_DATA and example TB
                                              // WRITE_DATA compare error.

   input 				       vio_tg_rst, // TG reset TG
   input 				       vio_tg_start, // TG start enable TG
   input 				       vio_tg_restart, // TG restart
   input 				       vio_tg_pause, // TG pause (level signal)
   input 				       vio_tg_err_chk_en, // If Error check is enabled (level signal), 
                                                              //    TG will stop after first error. 
                                                              // Else, 
                                                              //    TG will continue on the rest of the programmed instructions
   input 				       vio_tg_err_clear, // Clear Error excluding sticky bit (pos edge triggered)
   input 				       vio_tg_err_clear_all, // Clear Error including sticky bit (pos edge triggered)
   input 				       vio_tg_err_continue, // Continue run after Error detected (pos edge triggered)
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
   input [APP_ADDR_WIDTH/CMD_PER_CLK-1:0]      vio_tg_glb_start_addr,
   input [1:0] 				       vio_tg_glb_qdriv_rw_submode,   
    // - status register
   output [TG_INSTR_SM_WIDTH-1:0] 	       vio_tg_status_state,
   output 				       vio_tg_status_err_bit_valid, // Intermediate error detected
   output [APP_DATA_WIDTH_2_1-1:0] 	       vio_tg_status_err_bit, // Intermediate error bit pattern
   output [APP_ADDR_WIDTH-1:0] 		       vio_tg_status_err_addr, // Intermediate error address
   output 				       vio_tg_status_exp_bit_valid, // immediate expected bit
   output [APP_DATA_WIDTH_2_1-1:0] 	       vio_tg_status_exp_bit,
   output 				       vio_tg_status_read_bit_valid, // immediate read data bit
   output [APP_DATA_WIDTH_2_1-1:0] 	       vio_tg_status_read_bit,
   output 				       vio_tg_status_first_err_bit_valid, // first logged error bit and address
   output [APP_DATA_WIDTH_2_1-1:0] 	       vio_tg_status_first_err_bit,
   output [APP_ADDR_WIDTH-1:0] 		       vio_tg_status_first_err_addr,
   output 				       vio_tg_status_first_exp_bit_valid, // first logged error, expected data and address
   output [APP_DATA_WIDTH_2_1-1:0] 	       vio_tg_status_first_exp_bit,
   output 				       vio_tg_status_first_read_bit_valid, // first logged error, read data and address
   output [APP_DATA_WIDTH_2_1-1:0] 	       vio_tg_status_first_read_bit,
   output 				       vio_tg_status_err_bit_sticky_valid, // Accumulated error detected
   output [APP_DATA_WIDTH_2_1-1:0] 	       vio_tg_status_err_bit_sticky, // Accumulated error bit pattern
   output 				       vio_tg_status_err_type_valid, // Read/Write error detected
   output 				       vio_tg_status_err_type, // Read/Write error type
    //output [31:0] 			   vio_tg_status_tot_rd_cnt,
    //output [31:0] 			   vio_tg_status_tot_wr_cnt,
    //output [31:0] 			   vio_tg_status_tot_rd_req_cyc_cnt,
    //output [31:0] 			   vio_tg_status_tot_wr_req_cyc_cnt,
   output 				       vio_tg_status_wr_done, // In Write Read mode, this signal will be pulsed after every Write/Read cycle
   output 				       vio_tg_status_done,
   output 				       vio_tg_status_watch_dog_hang, // Watch dog detected traffic stopped unexpectedly

   output 				       tg_ila_debug // place holder for ILA
  );

//*****************************************************************************
// Fixed constant parameters. 
// DO NOT CHANGE these values. 
// As they are meant to be fixed to those values by design.
//*****************************************************************************
// This is the starting address from which the transaction are addressed to
//localparam BEGIN_ADDRESS               = 32'h00000100 ;               
// Data mask width
//localparam MASK_SIZE                   = APP_DATA_WIDTH_2_1;              
   localparam NUM_DQ_PINS_ECC = (ECC == "ON") ? ((NUM_DQ_PINS/8)%8)*8 : 0;
   localparam NUM_DQ_PINS_POST_ECC = NUM_DQ_PINS - NUM_DQ_PINS_ECC;
   
// Internal signals
   reg 					       init_calib_complete_r;

   wire [1:0] 				       tg_rw_submode;
   wire 				       tg0_rdy;
   wire 				       tg0_wdf_rdy;
   wire [CMD_PER_CLK_2_1-1:0] 		       tg0_rd_data_valid;
   wire [APP_DATA_WIDTH_2_1-1 : 0] 	       tg0_rd_data;
   wire [APP_CMD_WIDTH-1:0] 		       tg0_cmd;
   wire [APP_ADDR_WIDTH-1:0] 		       tg0_addr;
   wire 				       tg0_en;
   wire [(APP_DATA_WIDTH_2_1/DM_WIDTH)-1:0]    tg0_wdf_mask;   
   wire [APP_DATA_WIDTH_2_1-1: 0] 	       tg0_wdf_data;
   wire 				       tg0_wdf_end;
   wire 				       tg0_wdf_wren;

   wire 				       tg0_wdf_en;
   wire [APP_ADDR_WIDTH-1:0] 		       tg0_wdf_addr;
   wire [APP_CMD_WIDTH-1:0] 		       tg0_wdf_cmd;
   
   wire 				       tg1_rdy;
   wire 				       tg1_wdf_rdy;
   wire [CMD_PER_CLK_2_1-1:0] 		       tg1_rd_data_valid;
   wire [APP_DATA_WIDTH_2_1-1 : 0] 	       tg1_rd_data;
   wire [APP_CMD_WIDTH-1:0] 		       tg1_cmd;
   wire [APP_ADDR_WIDTH-1:0] 		       tg1_addr;
   wire 				       tg1_en;
   wire [(APP_DATA_WIDTH_2_1/DM_WIDTH)-1:0]    tg1_wdf_mask;   
   wire [APP_DATA_WIDTH_2_1-1: 0] 	       tg1_wdf_data;
   wire 				       tg1_wdf_end;
   wire 				       tg1_wdf_wren;

   wire 				       tg1_wdf_en;
   wire [APP_ADDR_WIDTH-1:0] 		       tg1_wdf_addr;
   wire [APP_CMD_WIDTH-1:0] 		       tg1_wdf_cmd;

//*****************************************************************************
//Init calib complete has to be asserted before any command can be driven out.
//Registering init_calib_complete to meet timing
//*****************************************************************************
always @ (posedge clk)  
  init_calib_complete_r <= #TCQ init_calib_complete;

//   assign app_en       = tg_en;
//   assign app_cmd      = tg_cmd;
//   assign app_addr     = tg_addr;
//   assign app_wdf_mask = tg_wdf_mask;
//   assign app_wdf_data = tg_wdf_data;
//   assign app_wdf_end  = tg_wdf_end;
//   assign app_wdf_wren = tg_wdf_wren;
   assign compare_error = vio_tg_status_err_bit_sticky_valid;
   

//*******************************************************************************
// TG top
   qdriip_v1_4_19_tg_top
     #(
       .SIMULATION (SIMULATION),
       .MEM_ARCH(MEM_ARCH),
       .MEM_TYPE(MEM_TYPE),
       .TCQ(TCQ),
       .APP_DATA_WIDTH(APP_DATA_WIDTH_2_1),
       .APP_ADDR_WIDTH(APP_ADDR_WIDTH),
       .APP_CMD_WIDTH(APP_CMD_WIDTH),
       .NUM_DQ_PINS(NUM_DQ_PINS_POST_ECC),
       .nCK_PER_CLK((EN_2_1_CONVERTER == "TRUE") ? 4 : nCK_PER_CLK),
       .CMD_PER_CLK(CMD_PER_CLK_2_1),
       .TG_PATTERN_MODE_PRBS_DATA_WIDTH(TG_PATTERN_MODE_PRBS_DATA_WIDTH),
       .TG_PATTERN_MODE_PRBS_ADDR_SEED (TG_PATTERN_MODE_PRBS_ADDR_SEED),
       .TG_PATTERN_MODE_LINEAR_DATA_SEED (TG_PATTERN_MODE_LINEAR_DATA_SEED),
       .TG_WATCH_DOG_MAX_CNT(TG_WATCH_DOG_MAX_CNT),
       .TG_INSTR_SM_WIDTH(TG_INSTR_SM_WIDTH),
       .DEFAULT_MODE(DEFAULT_MODE)
       )
   u_qdriip_v1_4_19_tg_top
     (
      .tg_clk(clk),
      .tg_rst(rst),
      .tg_calib_complete(init_calib_complete_r),
      .vio_tg_rst(vio_tg_rst),
      .vio_tg_start(vio_tg_start),
      .vio_tg_restart(vio_tg_restart),
      .vio_tg_pause(vio_tg_pause),
      .vio_tg_err_chk_en(vio_tg_err_chk_en),
      .vio_tg_err_clear(vio_tg_err_clear),
      .vio_tg_err_clear_all(vio_tg_err_clear_all),
      .vio_tg_err_continue(vio_tg_err_continue),
      .vio_tg_direct_instr_en(vio_tg_direct_instr_en),
      .vio_tg_instr_program_en(vio_tg_instr_program_en),
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
      .vio_tg_glb_start_addr(vio_tg_glb_start_addr),
      .vio_tg_glb_qdriv_rw_submode(vio_tg_glb_qdriv_rw_submode),
      
      .vio_tg_status_state(vio_tg_status_state),
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
      .vio_tg_status_err_type_valid(vio_tg_status_err_type_valid),
      .vio_tg_status_err_type(vio_tg_status_err_type),
      //.vio_tg_status_tot_rd_cnt(vio_tg_status_tot_rd_cnt),	          
      //.vio_tg_status_tot_wr_cnt(vio_tg_status_tot_wr_cnt),	    
      //.vio_tg_status_tot_rd_req_cyc_cnt(vio_tg_status_tot_rd_req_cyc_cnt),
      //.vio_tg_status_tot_wr_req_cyc_cnt(vio_tg_status_tot_wr_req_cyc_cnt),
      .vio_tg_status_wr_done(vio_tg_status_wr_done),
      .vio_tg_status_done(vio_tg_status_done),
      .vio_tg_status_watch_dog_hang(vio_tg_status_watch_dog_hang),
      .app_rdy(tg0_rdy),
      .app_wdf_rdy(tg0_wdf_rdy),
      .app_rd_data_valid(tg0_rd_data_valid),
      .app_rd_data(tg0_rd_data),
      .app_cmd(tg0_cmd),
      .app_addr(tg0_addr),
      .app_en(tg0_en),
      .app_wdf_mask(tg0_wdf_mask),
      .app_wdf_data(tg0_wdf_data),
      .app_wdf_end(tg0_wdf_end),
      .app_wdf_wren(tg0_wdf_wren),
      // QDRIIP
      .app_wdf_en(tg0_wdf_en),
      .app_wdf_addr(tg0_wdf_addr),
      .app_wdf_cmd(tg0_wdf_cmd),
      
      .tg_rw_submode(tg_rw_submode)
      //.tg_ila_debug(tg_ila_debug)
      );

   // Arbiter between Read/Write request
   qdriip_v1_4_19_tg_arbiter
     #(
       .TCQ(TCQ),
       .MEM_ARCH(MEM_ARCH),
       .MEM_TYPE(MEM_TYPE),
       .APP_DATA_WIDTH(APP_DATA_WIDTH_2_1),
       .APP_ADDR_WIDTH(APP_ADDR_WIDTH),
       .APP_CMD_WIDTH(APP_CMD_WIDTH)
       )
   u_qdriip_v1_4_19_tg_arbiter
     (
      .clk(clk),
      .rst(rst),
      .init_calib_complete_r(init_calib_complete_r),
      .tg_rw_submode(tg_rw_submode),

      .tg1_rdy(tg1_rdy),
      .tg1_wdf_rdy(tg1_wdf_rdy),
      .tg1_cmd(tg1_cmd),
      .tg1_addr(tg1_addr),
      .tg1_en(tg1_en),
      .tg1_wdf_mask(tg1_wdf_mask),
      .tg1_wdf_data(tg1_wdf_data),
      .tg1_wdf_end(tg1_wdf_end),
      .tg1_wdf_wren(tg1_wdf_wren),
      .tg1_wdf_en(tg1_wdf_en),
      .tg1_wdf_addr(tg1_wdf_addr),
      .tg1_wdf_cmd(tg1_wdf_cmd),

      .tg0_rdy(tg0_rdy),
      .tg0_wdf_rdy(tg0_wdf_rdy),
      .tg0_cmd(tg0_cmd),
      .tg0_addr(tg0_addr),
      .tg0_en(tg0_en),
      .tg0_wdf_mask(tg0_wdf_mask),
      .tg0_wdf_data(tg0_wdf_data),
      .tg0_wdf_end(tg0_wdf_end),
      .tg0_wdf_wren(tg0_wdf_wren),
      .tg0_wdf_en(tg0_wdf_en),
      .tg0_wdf_addr(tg0_wdf_addr),
      .tg0_wdf_cmd(tg0_wdf_cmd)
      );

   assign tg0_rd_data_valid = tg1_rd_data_valid;
   assign tg0_rd_data       = tg1_rd_data;   
   
   generate
      if (EN_2_1_CONVERTER == "FALSE") begin
	 assign tg1_rdy           = app_rdy;
	 assign tg1_wdf_rdy       = app_wdf_rdy;
	 assign tg1_rd_data_valid = app_rd_data_valid;
	 assign tg1_rd_data       = app_rd_data;
	 
	 assign app_cmd          = tg1_cmd;
	 assign app_addr         = tg1_addr;
	 assign app_en           = tg1_en;
	 assign app_wdf_mask     = tg1_wdf_mask;
	 assign app_wdf_data     = tg1_wdf_data;
	 assign app_wdf_end      = tg1_wdf_end;
	 assign app_wdf_wren     = tg1_wdf_wren;
	 
	 assign app_wdf_en       = tg1_wdf_en;
	 assign app_wdf_addr     = tg1_wdf_addr;
	 assign app_wdf_cmd      = tg1_wdf_cmd;
      end
      else begin
	 qdriip_v1_4_19_tg_2to1_converter
	   #(
	     //.MEM_TYPE(MEM_TYPE),
	     .TCQ(TCQ),
	     .APP_DATA_WIDTH(APP_DATA_WIDTH),
	     .APP_ADDR_WIDTH(APP_ADDR_WIDTH),
	     .APP_CMD_WIDTH(APP_CMD_WIDTH),
	     //.CMD_PER_CLK(CMD_PER_CLK_2_1),
	     .NUM_DQ_PINS(NUM_DQ_PINS_POST_ECC)
	     )
	 u_qdriip_v1_4_19_tg_2to1_converter
	   (
	    .clk(clk),
	    .rst(rst|vio_tg_rst),
	    .app_rdy(app_rdy),
	    .app_wdf_rdy(app_wdf_rdy),
	    .app_rd_data_valid(| app_rd_data_valid),
	    .app_rd_data(app_rd_data),
	    .app_cmd(app_cmd),
	    .app_addr(app_addr),
	    .app_en(app_en),
	    .app_wdf_mask(app_wdf_mask),
	    .app_wdf_data(app_wdf_data),
	    .app_wdf_end(app_wdf_end),
	    .app_wdf_wren(app_wdf_wren),
	    
	    .tg_rdy(tg1_rdy),
	    .tg_wdf_rdy(tg1_wdf_rdy),
	    .tg_rd_data_valid(tg1_rd_data_valid),
	    .tg_rd_data(tg1_rd_data),
	    .tg_cmd(tg1_cmd),
	    .tg_addr(tg1_addr),
	    .tg_en(tg1_en),
	    .tg_wdf_mask(tg1_wdf_mask),
	    .tg_wdf_data(tg1_wdf_data),
	    .tg_wdf_end(tg1_wdf_end),
	    .tg_wdf_wren(tg1_wdf_wren)
	    );

	 assign app_wdf_en       = tg1_wdf_en;
	 assign app_wdf_addr     = tg1_wdf_addr;
	 assign app_wdf_cmd      = tg1_wdf_cmd;
      end
   endgenerate

  //***************************************************************************
  // Reporting the test case status
  //***************************************************************************
//synthesis translate_off
generate
   if (MEM_TYPE != "QDRIV") begin
      initial
	begin : Logging
	   fork
              begin : calibration_done
		 wait (init_calib_complete);
		 wait (vio_tg_status_done);
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
