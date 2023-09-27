/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`timescale 1ns / 1ps

//
// 16-bit Parallel PRBS Generator for 2^31-1 with feedback of X31 + X28 + 1
//
// Initial seed is all zeros
//
// Data must be sent MSB to LSB to match a standard PRBS pattern
//
// This Verilog code was automatically generated using prbs_gen version 1.8 - 04/09/2003
//

module prbs_16_2v31_x31_x28_2 (CE, R, C, Q);
input CE;
input R;
input C;
output [15:0] Q;

reg [47:1] PRBS = 0;

assign Q = PRBS[47:32];

always @ (posedge C) begin
    if (R) begin
      PRBS[47:1] <= 47'h1C7F000000F1;
	end else if (CE) begin
      PRBS[47] <= PRBS[31];
      PRBS[46] <= PRBS[30];
      PRBS[45] <= PRBS[29];
      PRBS[44] <= PRBS[28];
      PRBS[43] <= PRBS[27];
      PRBS[42] <= PRBS[26];
      PRBS[41] <= PRBS[25];
      PRBS[40] <= PRBS[24];
      PRBS[39] <= PRBS[23];
      PRBS[38] <= PRBS[22];
      PRBS[37] <= PRBS[21];
      PRBS[36] <= PRBS[20];
      PRBS[35] <= PRBS[19];
      PRBS[34] <= PRBS[18];
      PRBS[33] <= PRBS[17];
      PRBS[32] <= PRBS[16];
      PRBS[31] <= PRBS[15];
      PRBS[30] <= PRBS[14];
      PRBS[29] <= PRBS[13];
      PRBS[28] <= PRBS[12];
      PRBS[27] <= PRBS[11];
      PRBS[26] <= PRBS[10];
      PRBS[25] <= PRBS[ 9];
      PRBS[24] <= PRBS[ 8];
      PRBS[23] <= PRBS[ 7];
      PRBS[22] <= PRBS[ 6];
      PRBS[21] <= PRBS[ 5];
      PRBS[20] <= PRBS[ 4];
      PRBS[19] <= PRBS[ 3];
      PRBS[18] <= PRBS[ 2];
      PRBS[17] <= PRBS[ 1];
      PRBS[16] <= PRBS[28] ~^ PRBS[31];
      PRBS[15] <= PRBS[27] ~^ PRBS[30];
      PRBS[14] <= PRBS[26] ~^ PRBS[29];
      PRBS[13] <= PRBS[25] ~^ PRBS[28];
      PRBS[12] <= PRBS[24] ~^ PRBS[27];
      PRBS[11] <= PRBS[23] ~^ PRBS[26];
      PRBS[10] <= PRBS[22] ~^ PRBS[25];
      PRBS[ 9] <= PRBS[21] ~^ PRBS[24];
      PRBS[ 8] <= PRBS[20] ~^ PRBS[23];
      PRBS[ 7] <= PRBS[19] ~^ PRBS[22];
      PRBS[ 6] <= PRBS[18] ~^ PRBS[21];
      PRBS[ 5] <= PRBS[17] ~^ PRBS[20];
      PRBS[ 4] <= PRBS[16] ~^ PRBS[19];
      PRBS[ 3] <= PRBS[15] ~^ PRBS[18];
      PRBS[ 2] <= PRBS[14] ~^ PRBS[17];
      PRBS[ 1] <= PRBS[13] ~^ PRBS[16];
    end
  end
endmodule

