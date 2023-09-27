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
//  /   /         Filename              : qdriip_v1_4_19_rd_bit_slip.v
// /___/   /\     Date Last Modified    : 2016/11/30
// \   \  /  \    Date Created          : Thu Oct 24 2013
//  \___\/\___\
//
//Device            : Ultrascale 
//Design            : QDRII+ SRAM
//Purpose           :
//                   Bitwise staging of read data for bitslip 
//Reference         :
//Revision History  :
//*****************************************************************************

`timescale 1ps/1ps

module qdriip_v1_4_19_rd_bit_slip #
(
   parameter TCQ        = 100  
)
(
   input               clk,        // fabric clock
   input               rst,        // reset
   input [1:0]         slip,       // bit slip
   input [1:0]         rvalid_stg, // one cycle staging for early bits 
   input      [3:0]    data_in,    // data in is a flat array of 8x 
   output reg [3:0]    data_out    // data out is a flat array of 8x SV restriction
);


integer i,j;
// should use a bram array for this array
reg shift_array[7:0];
reg [3:0] data_in_r;
reg [3:0] data_in_2r;
wire [3:0] data_in_mux;

always @(posedge clk) begin
  data_in_r <= #TCQ data_in;
  data_in_2r <= #TCQ data_in_r;
end  

// selection of data_in from the option reg stage or unregistered version
// bit_valid_stg will be set based on read valid calibration 
assign data_in_mux = rvalid_stg[1] ? data_in_2r : (rvalid_stg[0] ? data_in_r : data_in);


always @(posedge clk) begin
   for (i = 0; i < 4; i = i + 1)  begin
      if (rst) 
          shift_array[i] <= #TCQ 'b0;
      else begin
          shift_array[3-i] <= #TCQ data_in_mux[i]; 
          shift_array[7-i]  <= #TCQ shift_array[3-i];  
      end
  end
end

always @(*) begin
     for (i = 0; i< 4; i = i+1)    
       data_out[i] = shift_array[slip +3-i];
end 

endmodule

