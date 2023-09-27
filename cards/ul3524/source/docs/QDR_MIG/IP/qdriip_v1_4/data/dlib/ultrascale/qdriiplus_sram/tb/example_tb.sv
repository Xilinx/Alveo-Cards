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
//  /   /         Filename           : example_tb.sv
// /___/   /\     Date Last Modified : $Date: 2014/09/03 $
// \   \  /  \    Date Created       : Thu Apr 18 2013
//  \___\/\___\
//
// Device           : UltraScale 
// Design Name      : QDRIIP SRAM EXAMPLE TB
// Purpose          : This is an  example test-bench that shows how to interface
//                    to the Memory controller (MC) User Interface (UI). This  
//                    example works for QDRIIP memory controller generated 
//                    from QDRIIP IP. 
//                    This module waits for the calibration complete 
//                    (init_calib_complete) to pass the traffic to the MC.
//
//                    This TB generates 100 write transactions 
//                    followed by 100 read transactions to the MC.
//                    Checks if the data that is read back from the 
//                    memory is correct. After 100 writes and reads, no other
//                    commands will be issued by this TG.
//
//                    All READ and WRITE transactions in this example TB are of 
//                    QDRIIP BURST LENGTH (BL) 8. In a single clock cycle 1 BL8
//                    transaction will be generated
//
//                    The fabric to DRAM clock ratio is 4:1. In each fabric 
//                    clock cycle 8 beats of data will be written during 
//                    WRITE transactions and 8 beats of data will be received 
//                    during READ transactions.
//
//                    The results of this example_tb is guaranteed only for  
//                    100 write and 100 read transactions.
//                    The results of this example_tb is not guaranteed beyond 
//                    100 write and 100 read transactions.
//
// Reference        :
// Revision History :
//*****************************************************************************

`timescale 1ps/1ps

module example_tb #(
  parameter SIMULATION       = "FALSE",   // This parameter must be
                                          // TRUE for simulations and 
                                          // FALSE for implementation.
                                          //
  parameter APP_DATA_WIDTH   = 32,        // QDRIIP data bus width.
  parameter APP_ADDR_WIDTH   = 32         // Address bus width of the 
                                          //memory controller user interface.
  )
  (
  // ********* ALL SIGNALS AT THIS INTERFACE ARE ACTIVE HIGH SIGNALS ********/
  input clk,                 // MC UI clock
                             //
  input rst,                 // MC UI reset signal.
                             //
  input init_calib_complete, // MC calibration done signal coming from MC UI.
                             //
  input app_rdy,             // cmd fifo ready signal coming from MC UI.
                             //
  input app_wdf_rdy,         // write data fifo ready signal coming from MC UI.
                             //
  input app_rd_data_valid,   // read data valid signal coming from MC UI
                             //
  input [APP_DATA_WIDTH-1 : 0]  app_rd_data, // read data bus coming from MC UI
                                             //
  output [2 : 0]                app_cmd,     // command bus to the MC UI
                                             //
  output [APP_ADDR_WIDTH-1 : 0] app_addr,    // address bus to the MC UI
                                             //
  output                        app_en,      // command enable signal to MC UI.
                                             //
  output [APP_DATA_WIDTH/9 -1 : 0] app_wdf_mask, // write data mask signal which
                                              // is tied to 0 in this example.
					      //
  output [APP_DATA_WIDTH-1: 0]  app_wdf_data, // write data bus to MC UI.
                                              //
  output                        app_wdf_end,  // write burst end signal to MC UI
                                              //
  output                        app_wdf_wren, // write enable signal to MC UI
                                              //
  output                        compare_error,// Memory READ_DATA and example TB
                                              // WRITE_DATA compare error.
  output                        wr_rd_complete,                                              

  output [APP_DATA_WIDTH-1:0]   exp_rd_data   // Expected read data
);

//*****************************************************************************
// Fixed constant parameters. 
// DO NOT CHANGE these values. 
// As they are meant to be fixed to those values by design.
//*****************************************************************************
localparam BEGIN_ADDRESS = 32'h00000000 ; // This is the starting address from
                                     // which the transaction are addressed to
localparam NUM_TRANSACT  = 200 ; // Total number of transactions
localparam NUM_WRITES = (NUM_TRANSACT/2) ;// Total Number of WRITE transactions
localparam NUM_READS  = (NUM_TRANSACT/2) ;// Total Number of READ transactions
localparam TCQ  = 100; // To model the clock to out delay

 
localparam INT_DATA_WIDTH  = 9 ; // Internal data width for write and read data.  
                              // set to 9 bit. Data generation is always 2 bytes
                        // For higher data widths the 9-bit data is duplicated.

//************************
// Instruction encoding 
//************************
localparam RD_INSTR = 3'b001; // Read command
localparam WR_INSTR = 3'b000; // Write command

// Internal signals
reg  [2 :0]                     cmd;               // Command instruction 
reg  [APP_ADDR_WIDTH-1:0]       cmd_addr;          // Command address
reg [9 :0]                      cmd_cnt ;          // Command count
reg                             cmd_en;            // Command enable 
reg                             compare_error_int; // Compare error
reg  [INT_DATA_WIDTH-1:0]       exp_rd_data_int; // Internal Expected read data
reg                             init_calib_complete_r;// Registered version of 
                                                       // init_calib_complete
reg  [INT_DATA_WIDTH-1: 0]      wr_data;       // Write data internal signal
reg                             wr_en;         // Write enable signal
reg [(APP_DATA_WIDTH/8)-1 : 0]  error_byte;    // Data error per byte
reg [APP_DATA_WIDTH-1 : 0]      app_rd_data_r1; // Registered version of input 
                                                // read data
reg                             app_rd_data_valid_r1; // Registered version of
                                                      // input read data valid

//*****************************************************************************
//Init calib complete has to be asserted before any command can be driven out.
//Registering the init_calib_complete to meet timing
//*****************************************************************************
always @ (posedge clk)  
  init_calib_complete_r <= #TCQ init_calib_complete;
  
//*****************************************************************************
// Command enable signal generation to the MC
//*****************************************************************************
// The app_en signal is used to qualify the command on the command bus 
// to the MC.
// The command on the command bus is considered accepted by the 
// MC When app_rdy signal from the UI is asserted.
// The app_en signal is asserted at the same clock cycle.
//*****************************************************************************
assign app_en    = cmd_en & (app_rdy) ;

//*****************************************************************************
// Command generation for the MC
//*****************************************************************************
// The app_cmd signal is the command issued to the MC.
// The cmd is set to Write command till the 100 write commands are 
// issued to the UI after calibration complete.
// The cmd is set to Read command after the 100 write commands are completed 
// and 100 read commands are issued to the UI.
//*****************************************************************************
assign app_cmd       = cmd;

//*****************************************************************************
// Command Address generation to the MC
//*****************************************************************************
// The app_addr signal is the command address issued to the MC.
//
// The cmd_addr is initialised to BEGIN_ADDRESS and increments by 8(`h8)
// when command enable is '1' and MC command fifo is ready.  
//
// The cmd_addr is initialized with BEGIN_ADDRESS again when write commands 
// are completed to start the read commands.
// *****************************************************************************

// This is the address going to the MC
assign app_addr  = cmd_addr;

// Command Address to the Memory controller
always @(posedge clk)
begin
  if(rst)
    cmd_addr <= #TCQ BEGIN_ADDRESS;
  else if (cmd_en & app_rdy)
    if (cmd_addr < ((NUM_WRITES-1)*8))
      cmd_addr <= #TCQ cmd_addr + 4'b1000;

    // The cmd_cnt value is 99 when it completes 100 write transactions.
    // The cmd_addr is initialized with BEGIN_ADDRESS when write commands
    // are completed (cmd_cnt = 99).        
    else if (cmd_cnt == ((NUM_WRITES-1)))
      cmd_addr <= #TCQ BEGIN_ADDRESS;
end

//*****************************************************************************
// Write enable signal generation to the MC
//*****************************************************************************
// The app_wdf_wren signal is the write enable issued to the MC.
// When the app_wdf_wren is high, the write data is written into the 
// write data fifo.
// The app_wdf_wren signal is asserted for the write command when both 
// MC write fifo and MC command fifo are ready.
//*****************************************************************************
assign app_wdf_wren     = wr_en & (app_rdy) ;

//*****************************************************************************
// Write end signal generation to the MC
//*****************************************************************************
// The app_wdf_end signal is the write end information to the MC.
// The UI requires, the app_wdf_end signal to be asserted at 
// the end of the data phase. 
// In 4:1 clock ratio and  BL8 mode, the data phase is only one cycle 
// and the app_wdf_end signal is asserted whenever wr_en is asserted.
//*****************************************************************************
assign app_wdf_end    = wr_en & (app_rdy)  ;

//*****************************************************************************
// Write data generation to the MC
//*****************************************************************************
// The app_wdf_data bus is the write data issued to the MC.
// For 4:1 clock ratio in BL8 Mode, the data has to be provided for the entire
// BL8 burst in one clock cycle (User interface clock cycle).
//
// The data has to be provided in the following format:
// FALL3->RISE3->FALL2->RISE2->FALL1->RISE1->FALL0->RISE0
// 
// For an 16 bit interface, 16 * 8 = 128 bits of data will be provided in the
// each clock cycle. LSB 16-bits corresponds to RISE0 and MSB 16-bits 
// corresponds to FALL3.
//
// The wr_data is initialised to BEGIN_ADDRESS and
// increments by 8(`h8) when wr_en is '1'to generate the write data.
// The write data generated will be same as command address.
// 
//*****************************************************************************

//Data duplication
assign app_wdf_data   = {(APP_DATA_WIDTH/INT_DATA_WIDTH){wr_data}};

always @ (posedge clk)
begin
  if (rst )
    wr_data <= BEGIN_ADDRESS;
  else if (wr_en & app_rdy )
    if (wr_data < ((NUM_WRITES-1)*8))
      wr_data <= #TCQ wr_data + 4'b1000 ;
end

//*****************************************************************************
// Write data mask to the MC
// ** The write data mask is set to zero in this example_tb **
// This is the simple traffic generator, if write data mask is toggled
// more logic would be required to qualify the read data.
// To keep it simple and have less logic write data mask is always held low.
//*****************************************************************************
// The app_wdf_mask signal tied to 0 in this example.
// If the mask signal need to be toggled, the timing is same as write data.
//*****************************************************************************
assign app_wdf_mask   = 0 ;

//*****************************************************************************
//  WRITE/READ Transaction generation :
//  Following logic controls the read-write operations after calibration is 
//  done. 
//  The cmd is set to WR_INSTR for 100 write commands. Write command 
//  phase is completed the cycle when the cmd_cnt reaches a value of 99 and
//  the write command is accepted by the MC. 
//  
//  Finally, the read command phase starts and 100 read commands are issued. 
//*****************************************************************************
always @(posedge clk)
begin
  if(rst | ~init_calib_complete_r) begin
    wr_en            <= #TCQ 1'b0;
    cmd_en           <= #TCQ 1'b0;
    cmd              <= #TCQ WR_INSTR;
  // Generate 100 write commands till the cmd_cnt reaches a value of 99
  end else if (cmd_cnt < (NUM_WRITES-1)) begin
    cmd             <= #TCQ WR_INSTR;
    cmd_en          <= #TCQ app_rdy;
    wr_en           <= #TCQ app_wdf_rdy;
  // Generate 100 read commands after cmd_cnt reaches 99
  end else if (cmd_cnt == (NUM_WRITES-1) & cmd_en & app_rdy) begin
    cmd             <= #TCQ RD_INSTR;
    cmd_en          <= #TCQ app_rdy ;
    wr_en           <= #TCQ 1'b0;
  end else if (cmd_cnt == (NUM_TRANSACT-1) & cmd_en & app_rdy) begin
    cmd_en          <= #TCQ 1'b0;
    wr_en           <= #TCQ 1'b0;
  end
end

//*****************************************************************************
//  Command Counter :
//      This command counter counts the number of commands issued to the 
//      MC UI. 
//*****************************************************************************
always @(posedge clk )
begin
  if(rst)
    cmd_cnt <= #TCQ 'b0;
  else if (cmd_en & app_rdy)
    if (cmd_cnt < NUM_TRANSACT)
      cmd_cnt <= #TCQ cmd_cnt + 'b1;
end

//*****************************************************************************
// Expected Read data generation:
// The expected read data (exp_rd_data_int) is initialised to BEGIN_ADDRESS and
// increments by 8(`h8) when app_rd_data_valid is '1' to generate the read data.
// The read data generated will be same as command address.
//
// The read data from the UI is valid when the app_rd_data_valid signal 
// is asserted to '1'.
//*****************************************************************************
assign exp_rd_data = {(APP_DATA_WIDTH/INT_DATA_WIDTH){exp_rd_data_int}};

always @(posedge clk )
begin
  if(rst)
    exp_rd_data_int <= #TCQ BEGIN_ADDRESS;
  else if (app_rd_data_valid_r1)
    if (exp_rd_data_int < ((NUM_READS-1)*8)) 
      exp_rd_data_int <= #TCQ exp_rd_data_int + 4'b1000;
end

//*****************************************************************************
// Registering data read from the UI and data valid to meet the timing.
//*****************************************************************************
always @(posedge clk )
begin
  app_rd_data_r1       <= #TCQ app_rd_data;
  app_rd_data_valid_r1 <= #TCQ app_rd_data_valid;
end

//*****************************************************************************
// Read data comparison:
// The compare error (compare_error_int) signal is asserted when the 
// expected read data (exp_rd_data) is not matching with the data 
// read from the UI (app_rd_data_r1) when app_rd_data_valid_r1 is '1'.
//*****************************************************************************
assign compare_error  = compare_error_int;

genvar i;
for (i = 0; i < (APP_DATA_WIDTH/8); i = i + 1) 
begin: gen_cmp_4
  always @ (posedge clk) begin
      if (app_rd_data_valid_r1)
        //synthesis translate_off
        if (SIMULATION=="TRUE")
          error_byte[i]  <= #TCQ (app_rd_data_r1[8*(i+1)-1:8*i] !== exp_rd_data[8*(i+1)-1:8*i]) ; 
        else 
  	    //synthesis translate_on
          error_byte[i]  <= #TCQ (app_rd_data_r1[8*(i+1)-1:8*i] != exp_rd_data[8*(i+1)-1:8*i]) ;  
      else
        error_byte[i]  <= #TCQ 1'b0;
  end
end

// Compare error is OR of all byte errors
always @(posedge clk )
begin
  if(rst | ~init_calib_complete_r)
    compare_error_int <= #TCQ 1'b0;
  else 
    compare_error_int <= #TCQ | error_byte ;
  //synthesis translate_off
  if (compare_error_int)
    $display ("ERROR: Expected data=%h, Received data=%h @ %t" ,exp_rd_data, 
               app_rd_data_r1, $time);
  //synthesis translate_on

end

//*******************************************************************************
//  Read Counter :
//      This Read counter counts the number of app_rd_data_valid issued by the MC
//      UI and generates a pulse (wr_rd_complete) when the number of
//      consequent app_rd_data_valid becomes equal to the 100 .
//      This wr_rd_complete is used to indicates the completion of 100 write and
//      100 read transactions status.
//*******************************************************************************
reg              wr_rd_complete_r;
reg [9 :0]       rd_cnt ;
always @(posedge clk)
begin
  if(rst | ~init_calib_complete_r) begin
    rd_cnt           <= #TCQ 'b0;
    wr_rd_complete_r <= #TCQ 'b0;
  end else if(app_rd_data_valid) begin
    rd_cnt <= #TCQ (rd_cnt + 1'b1) ; 
    if (rd_cnt == (NUM_READS-1)) begin
       wr_rd_complete_r <= #TCQ 1'b1 ;
    end
  end
end

assign wr_rd_complete = wr_rd_complete_r;

//*******************************************************************************
// SIMULATION ONLY
//*******************************************************************************
//synthesis translate_off
initial
begin : Logging
  wait (wr_rd_complete);
  $display("100 Writes and 100 Reads to the memory completed");
  #1000;
  if (!compare_error) begin
    $display("Test Completed Successfully");
    $display("TEST PASSED");
  end
  else begin
    $display("TEST FAILED: DATA ERROR");
  end
  $display("INFO: Timing violations reported by memory model could be incorrect due to model issue. Please check the violations and contact Cypress for further assistance.");
  $finish;
end
//synthesis translate_on
//*******************************************************************************

endmodule
