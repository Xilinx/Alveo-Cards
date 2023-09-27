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
//  /   /         Filename           : qdriip_v1_4_19_sync.sv
// /___/   /\     Date Last Modified : $Date: 2015/01/22 $
// \   \  /  \    Date Created       : Thu Apr 18 2013
//  \___\/\___\
//
// Device           : UltraScale
// Design Name      : QDRII+ SRAM
// Purpose          :
//                   qdriip_v1_4_19_sync module
// Reference        :
// Revision History :
//*****************************************************************************

`timescale 1ps/1ps

module qdriip_v1_4_19_sync #(
    parameter       SYNC_MTBF               = 2
   ,parameter       WIDTH                   = 8
   ,parameter       INSERT_DELAY            = 0
   ,parameter       MAX_DELAY               = 3000
   ,parameter       TCQ                     = 100
)(
    input                         clk
   ,input [WIDTH-1:0]             data_in
   ,output [WIDTH-1:0]            data_out
);

genvar wd;
generate
  for (wd=0; wd<WIDTH; wd=wd+1) begin : SYNC
    (* dont_touch = "true" *) (* ASYNC_REG = "TRUE" *) reg [SYNC_MTBF-1:0] sync_reg;

    reg data_in_delayed = 1'b0;

    wire sync_in = INSERT_DELAY ? data_in_delayed : data_in[wd];

    assign data_out[wd] = sync_reg[SYNC_MTBF-1];

    always @(posedge clk) begin
      sync_reg <= #TCQ {sync_reg[0+:SYNC_MTBF-1], sync_in};
    end

    //synthesis translate_off
      integer DELAY_VAL = $urandom_range(0,MAX_DELAY);

      always @(*) data_in_delayed <= #(DELAY_VAL) data_in[wd];
    //synthesis translate_on

  end
endgenerate

endmodule
