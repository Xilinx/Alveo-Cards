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
// /___/   /\     Date Last Modified : $Date: 2014/09/03 $
// \   \  /  \    Date Created       : Thu May 22 2014
//  \___\/\___\
//
// Device           : UltraScale
// Design Name      : Traffic Generator
// Purpose:
// This is a TG 4:1 to 2:1 nCK_PER_CLK converter for
// DDR3/4, RLD2/3 2:1 mode in BL8
// Reference        :
// Revision History :
//*****************************************************************************

`timescale 1ps / 1ps

module qdriip_v1_4_19_tg_2to1_converter 
  #(
    parameter MEM_TYPE         = "DDR3",
    parameter TCQ              = 100,
    parameter APP_DATA_WIDTH   = 32,
    parameter APP_DATA_WIDTH_2_1 = APP_DATA_WIDTH << 1,   //2x of APP_DATA_WIDTH
    parameter APP_ADDR_WIDTH   = 32,
    parameter APP_CMD_WIDTH    = 3,
    parameter NUM_DQ_PINS      = 64,
    parameter DM_WIDTH = (MEM_TYPE == "RLD3" || MEM_TYPE == "RLD2") ? 18 : 8
    )
   (
    input 			 clk,
    input 			 rst,

    // App interface
    input 			 app_rdy, // DDR3/4, RLD3 Interface
    input 			 app_wdf_rdy, // DDR3/4, RLD3 Interface
    input 			 app_rd_data_valid, // DDR3/4, RLD3, QDRIIP Interface
    input [APP_DATA_WIDTH-1:0] 	 app_rd_data, // DDR3/4, RLD3, QDRIIP (0/1) Interface
    output [APP_CMD_WIDTH-1:0] 	 app_cmd, // DDR3/4, RLD3, QDRIIP (READ 0/1) Interface
    output [APP_ADDR_WIDTH-1:0]  app_addr, // DDR3/4, RLD3, QDRIIP (READ 0/1) Interface
    output 			 app_en, // DDR3/4, RLD3, QDRIIP (READ 0/1) Interface
    output [(APP_DATA_WIDTH/DM_WIDTH)-1:0] 	 app_wdf_mask, // DDR3/4, RLD3, QDRIIP (WRITE 0/1) Interface
    output [APP_DATA_WIDTH-1: 0] app_wdf_data, // DDR3/4, RLD3, QDRIIP (WRITE 0/1) Interface
    output 			 app_wdf_end, // DDR3/4, RLD3 Interface
    output 			 app_wdf_wren, // DDR3/4, RLD3, QDRIIP (WRITE 0/1)  Interface

    // TG interface
    output 		 tg_rdy, // DDR3/4, RLD3 Interface
    output 			 tg_wdf_rdy, // DDR3/4, RLD3 Interface
    output reg		 tg_rd_data_valid, // DDR3/4, RLD3, QDRIIP Interface
    output reg [APP_DATA_WIDTH_2_1-1:0]  tg_rd_data, // DDR3/4, RLD3, QDRIIP (0/1) Interface
    input [APP_CMD_WIDTH-1:0] 	 tg_cmd, // DDR3/4, RLD3, QDRIIP (READ 0/1) Interface
    input [APP_ADDR_WIDTH-1:0] 	 tg_addr, // DDR3/4, RLD3, QDRIIP (READ 0/1) Interface
    input 			 tg_en, // DDR3/4, RLD3, QDRIIP (READ 0/1) Interface
    input [(APP_DATA_WIDTH_2_1/DM_WIDTH)-1:0] 	 tg_wdf_mask, // DDR3/4, RLD3, QDRIIP (WRITE 0/1) Interface  //ekim ???
    input [APP_DATA_WIDTH_2_1-1: 0]  tg_wdf_data, // DDR3/4, RLD3, QDRIIP (WRITE 0/1) Interface
    input 			 tg_wdf_end, // DDR3/4, RLD3 Interface
    input 			 tg_wdf_wren // DDR3/4, RLD3, QDRIIP (WRITE 0/1)  Interface

 );

  localparam CONV_FIFO_WIDTH = 1 + APP_CMD_WIDTH + APP_ADDR_WIDTH ;
  localparam CONV_DATA_FIFO_WIDTH = APP_DATA_WIDTH;
  localparam APP_READ =  3'b001;  
  localparam APP_WRITE = 3'b000;
  localparam DQ_PER_DQS = (MEM_TYPE=="DDR3")? 8 : 9;
  localparam NUM_DQS = NUM_DQ_PINS/DQ_PER_DQS; //only for DDR3 

/*   
  function [APP_DATA_WIDTH-1:0] swizzle_ui_out_l ( input [APP_DATA_WIDTH_2_1-1:0] tg_in, 
                                                   input integer num_dqs, 
                                                   input integer dq_width);
    integer i;
    for (i = 0; i<num_dqs; i= i+1) begin
      swizzle_ui_out_l[i*8+:8] = tg_in[(64*i)+:8];                         //rise0
      swizzle_ui_out_l[((i*8)+dq_width)+:8] = tg_in[((64*i)+8) +:8];       //fall0
      swizzle_ui_out_l[((i*8)+dq_width*2)+:8] = tg_in[((64*i)+16) +:8];    //rise1
      swizzle_ui_out_l[((i*8)+dq_width*3)+:8] = tg_in[((64*i)+24) +:8];    //fall1
    end
  endfunction
      
  function [APP_DATA_WIDTH-1:0] swizzle_ui_out_m ( input [APP_DATA_WIDTH_2_1-1:0] tg_in, 
                                                   input integer num_dqs, 
                                                   input integer dq_width);
    integer i;
    for (i = 0; i<num_dqs; i= i+1) begin
      swizzle_ui_out_m[(i*8)+:8] = tg_in[((64*i)+32)+:8];                  //rise2
      swizzle_ui_out_m[((i*8)+dq_width*1)+:8] = tg_in[((64*i)+40)+:8];     //fall2
      swizzle_ui_out_m[((i*8)+dq_width*2)+:8] = tg_in[((64*i)+48) +:8];    //rise3
      swizzle_ui_out_m[((i*8)+dq_width*3)+:8] = tg_in[((64*i)+56) +:8];    //fall3
    end
  endfunction

  function [APP_DATA_WIDTH_2_1-1:0] unswizzle_tg_out ( input [APP_DATA_WIDTH-1:0] ui_in_m, 
                                                       input [APP_DATA_WIDTH-1:0] ui_in_l, 
                                                       input integer num_dqs, 
                                                       input integer dq_width);
    integer i;
    for (i=0; i<num_dqs; i=i+1) begin
      unswizzle_tg_out[(64*i)+:8] = ui_in_l[(i*8)+:8];                      //rise0
      unswizzle_tg_out[((64*i)+8) +:8] = ui_in_l[((i*8)+dq_width) +:8];     //fall0
      unswizzle_tg_out[((64*i)+16) +:8] = ui_in_l[((i*8)+dq_width*2) +:8];  //rise1
      unswizzle_tg_out[((64*i)+24) +:8] = ui_in_l[((i*8)+dq_width*3) +:8];  //fall1
      
      unswizzle_tg_out[((64*i)+32) +:8] = ui_in_m[(i*8) +:8];                //rise2
      unswizzle_tg_out[((64*i)+40) +:8] = ui_in_m[((i*8)+dq_width*1) +:8];   //fall2
      unswizzle_tg_out[((64*i)+48) +:8] = ui_in_m[((i*8)+dq_width*2) +:8];   //rise3
      unswizzle_tg_out[((64*i)+56) +:8] = ui_in_m[((i*8)+dq_width*3) +:8];   //fall3
    end
  endfunction
*/
 
  wire fifo_app_en;                                   //app_en to UI (fifo output)
  wire [APP_CMD_WIDTH-1:0] fifo_app_cmd;              //app_cmd to UI (fifo output)
  wire [APP_ADDR_WIDTH-1:0]fifo_app_addr;             //app_addr to UI (fifo output)
  reg [APP_ADDR_WIDTH-1:0]fifo_app_addr_r;            //app_addr to UI (fifo output)
  wire [APP_DATA_WIDTH-1:0] fifo_app_wdf_data;        //app_wdf_data to UI (fifo output)
  reg fifo_second_write;                              //indicate this is second word of write
  reg  app_en_int_reg;                                //delayed tg_en (fifo input)
  wire cmd_rden;                                      //read enable for cmd fifo
  wire data_rden;                                     //read enable for data fifo
  reg  [CONV_FIFO_WIDTH-1:0] app_fifo_in;             //cmd fifo input data 
  wire [CONV_FIFO_WIDTH-1:0] fifo_out;                //dmc fifo output
  wire [APP_DATA_WIDTH-1:0] app_wdf_data_0;           //first write data
  reg [APP_DATA_WIDTH-1:0] app_wdf_data_1;            //second write data
  wire [APP_DATA_WIDTH-1:0] app_wdf_data_1_wire;      //second write data 
  wire tg_cmd_write;                                  //cmd is write
  reg  app_rd_val_cnt;                                //read data counter
  reg  write_second_data;                             //second data write (used for data fifo input)
  reg  write_second_data_r;                           //second data write (used for data fifo inpput)
  reg [APP_ADDR_WIDTH-1:0] tg_addr_r;                 //registered tg_addr
  reg [APP_CMD_WIDTH-1:0] tg_cmd_r;                   //registered tg_cmd

  reg  [CONV_DATA_FIFO_WIDTH-1:0] app_fifo_data_in;  //data fifo input
  wire [CONV_DATA_FIFO_WIDTH-1:0] fifo_data_out;     //data fifo output
  wire fifo_empty;                                   //cmd fifo empty
  wire fifo_data_empty;                              //data fifo empty
  wire fifo_cmd_full;                                //cmd fifo full
  wire fifo_data_full;                               //data fifo full
  wire fifo_full;                                    //either cmd or data fifo full
  wire cmd_wren;                                     //write enable for cmd fifo
  wire data_wren;                                    //write enable for data fifo

  reg  [APP_DATA_WIDTH-1:0]      app_rd_data_r;      //read data from UI (registered version)

  //FIFO input related signals
  // Removed swizzle to have it controlled in qdriip_v1_4_19_tg_victim_data.sv
//  assign app_wdf_data_0 = (MEM_TYPE == "DDR3")? swizzle_ui_out_l(tg_wdf_data, NUM_DQS, NUM_DQ_PINS)
//                          :tg_wdf_data[APP_DATA_WIDTH-1:0];  
//  assign app_wdf_data_1_wire = (MEM_TYPE == "DDR3")? swizzle_ui_out_m(tg_wdf_data, NUM_DQS, NUM_DQ_PINS)
//                          :tg_wdf_data[APP_DATA_WIDTH_2_1-1:APP_DATA_WIDTH];
  assign app_wdf_data_0 = tg_wdf_data[APP_DATA_WIDTH-1:0];
  assign app_wdf_data_1_wire = tg_wdf_data[APP_DATA_WIDTH_2_1-1:APP_DATA_WIDTH];
  assign tg_cmd_write = (tg_en && tg_rdy && (tg_cmd == APP_WRITE)) 
                        | ((tg_cmd_r == APP_WRITE) && ~(tg_en && tg_rdy && tg_cmd==APP_READ)) ;
  assign fifo_full = fifo_cmd_full | fifo_data_full;
  assign cmd_wren = app_en_int_reg && ~fifo_full ;
  assign data_wren = ((tg_cmd_write & app_en_int_reg)|write_second_data_r) && ~fifo_full; 

  //FIFO output related signals
  assign fifo_app_en = fifo_out[CONV_FIFO_WIDTH-1];
  assign fifo_app_cmd = fifo_out[(APP_ADDR_WIDTH)+:APP_CMD_WIDTH];
  assign fifo_app_addr = fifo_out[APP_ADDR_WIDTH-1:0];
  assign fifo_app_wdf_data = fifo_data_out[APP_DATA_WIDTH-1:0];
  
  assign app_en = ~fifo_empty & fifo_app_en;
  assign app_addr = fifo_app_addr;
  assign app_cmd = fifo_app_cmd;
  assign app_wdf_data = fifo_app_wdf_data;
  assign app_wdf_end =  fifo_second_write;
  assign app_wdf_wren   = ~fifo_data_empty & app_wdf_rdy;
 
 //Current TG doesn't support write mask.
  assign app_wdf_mask = 'h0 ;
  
  assign cmd_rden = app_en & app_rdy;       
  assign data_rden = app_wdf_wren;
 
  assign tg_rdy = ~(app_en_int_reg && (tg_cmd_r == APP_WRITE)) & ~fifo_full;
  assign tg_wdf_rdy = tg_rdy;
  
  qdriip_v1_4_19_tg_fifo
   #(
     .TCQ (100),
     .WIDTH  (CONV_FIFO_WIDTH),
     .DEPTH  (2),
     .LOG2DEPTH (1)
    )
  u_conv_fifo
   (
     .clk  (clk),
     .rst  (rst),
     .wren (cmd_wren ),
     .rden (cmd_rden),
     .din  (app_fifo_in), 
     .dout (fifo_out),
     .full (fifo_cmd_full),
     .empty (fifo_empty)
    );

  qdriip_v1_4_19_tg_fifo
   #(
     .TCQ (100),
     .WIDTH (CONV_DATA_FIFO_WIDTH),
     .DEPTH (4),
     .LOG2DEPTH (2)
     )
   u_conv_data_fifo
    (
     .clk   (clk),
     .rst   (rst),
     .wren  (data_wren),
     .rden  (data_rden),
     .din   (app_fifo_data_in),
     .dout  (fifo_data_out),
     .full  (fifo_data_full),
     .empty (fifo_data_empty)
    );

  
  // ********* INTERFACE BWTWEEN TG and CONV FIFO ********/
  //FIFO write - registered version of app_en
  //if fifo_full happening, the value should kept until fifo become unfull
  //this is used for write enable for cmd fifo
  always @ (posedge clk) begin
    if(rst) app_en_int_reg <= #TCQ 1'b0;
    else if (~fifo_full) app_en_int_reg <= #TCQ tg_en && tg_rdy;
  end

  always @ (posedge clk) begin
    if(tg_en && tg_rdy)
      app_fifo_in <= #TCQ {1'b1, tg_cmd, tg_addr}; 
  end

  always @ (posedge clk) begin
    if(tg_en && tg_rdy && tg_cmd_write)  
      app_fifo_data_in <= #TCQ app_wdf_data_0;
    else if(app_en_int_reg & tg_cmd_write)
      app_fifo_data_in <= #TCQ app_wdf_data_1;
  end

  always @ (posedge clk)
    if(tg_en && tg_rdy) begin
      tg_addr_r <= #TCQ tg_addr;
      tg_cmd_r <= #TCQ tg_cmd;
      app_wdf_data_1 <= #TCQ app_wdf_data_1_wire; 
    end

  //whenever first write happen, write_second_data set to 1
  //It should not change when fifo is full
  always @ (posedge clk) begin
    if (rst) write_second_data <= #TCQ 1'b0;
    else if(tg_en && tg_rdy & tg_cmd_write & ~write_second_data)
        write_second_data <= #TCQ 1'b1;
    else write_second_data <= #TCQ 1'b0; 
  end
  //write_second_data
  always @ (posedge clk) begin
    if(rst) write_second_data_r <= #TCQ 1'b0;
    else if (tg_cmd_write & ~fifo_full) write_second_data_r <= #TCQ write_second_data;
  end
  
  //INTERFACE between conv FIFO and UI
  always @ (posedge clk) 
    if(rst) fifo_second_write <= #TCQ 1'b0;
    else if (app_wdf_wren) fifo_second_write <=#TCQ ~fifo_second_write;

  always @ (posedge clk)
    if(app_en) fifo_app_addr_r <= #TCQ fifo_app_addr;
  
   // ********* INTERFACE for APP_READ ********/ 
  always @ (posedge clk) begin
    if(rst) app_rd_val_cnt <= #TCQ 1'b0;
    else if(app_rd_data_valid) app_rd_val_cnt <= #TCQ~app_rd_val_cnt;
  end

  //Need data formulate
  always @ (posedge clk) begin
    if(app_rd_data_valid)
      app_rd_data_r <= #TCQ app_rd_data;
  end
  assign tg_rd_data_valid = app_rd_data_valid & app_rd_val_cnt;
  // Removed swizzle to have it controlled in qdriip_v1_4_19_tg_victim_data.sv
//  assign tg_rd_data = (MEM_TYPE == "DDR3")? unswizzle_tg_out (app_rd_data,app_rd_data_r, NUM_DQS, NUM_DQ_PINS)
//                      : {app_rd_data, app_rd_data_r};  
  assign tg_rd_data = {app_rd_data, app_rd_data_r}; 
endmodule
