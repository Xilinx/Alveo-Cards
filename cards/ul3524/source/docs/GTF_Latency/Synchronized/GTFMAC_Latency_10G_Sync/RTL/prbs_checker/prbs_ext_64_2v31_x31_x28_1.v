/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2022 03:33:55 PM
// Design Name: 
// Module Name: prbs_ext_64_2v31_x31_x28_1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//
// 64-bit Parallel PRBS Generator for 2^31-1 with feedback of X31 + X28
//
// Initial seed is all ones
//
// Data must be sent MSB to LSB to match a standard PRBS pattern
//
// This Verilog code was automatically generated using prbs_gen version 1.8 - 04/09/2003
//

module prbs_ext_64_2v31_x31_x28_1 (CE, R, C, sync, syncdatain_dly0, syncdatain_dly1, syncdatain_dly2, Q);
input CE;
input R;
input C;
input sync;
input [63:0] syncdatain_dly0;
input [63:0] syncdatain_dly1;
input [63:0] syncdatain_dly2;

output [63:0] Q;


reg [95:1] PRBS;

reg sync_reg1;
reg sync_reg2;

assign Q = PRBS[95:32];

always @ (posedge C or posedge R) begin
	if (R) begin
		sync_reg1 <=0;
		sync_reg2 <=0;
	end else begin
		sync_reg1 <= sync;
		sync_reg2 <= sync_reg1;
	end
end


always @ (posedge C) begin
    if (R) begin
      PRBS[ 95:65] <= 31'b1111111111111111111111111111111;
      PRBS[ 64:1 ] <= 64'b0000000000000000000000000000111000000000000000000000000011111100;
    end else if (sync_reg1 && !sync_reg2) begin
      PRBS[ 95:1] <=  {syncdatain_dly1[63:0],syncdatain_dly0[63:33]};
    end else if (sync_reg1 && sync_reg2 && CE) begin
      PRBS[95] <= PRBS[31];
      PRBS[94] <= PRBS[30];
      PRBS[93] <= PRBS[29];
      PRBS[92] <= PRBS[28];
      PRBS[91] <= PRBS[27];
      PRBS[90] <= PRBS[26];
      PRBS[89] <= PRBS[25];
      PRBS[88] <= PRBS[24];
      PRBS[87] <= PRBS[23];
      PRBS[86] <= PRBS[22];
      PRBS[85] <= PRBS[21];
      PRBS[84] <= PRBS[20];
      PRBS[83] <= PRBS[19];
      PRBS[82] <= PRBS[18];
      PRBS[81] <= PRBS[17];
      PRBS[80] <= PRBS[16];
      PRBS[79] <= PRBS[15];
      PRBS[78] <= PRBS[14];
      PRBS[77] <= PRBS[13];
      PRBS[76] <= PRBS[12];
      PRBS[75] <= PRBS[11];
      PRBS[74] <= PRBS[10];
      PRBS[73] <= PRBS[ 9];
      PRBS[72] <= PRBS[ 8];
      PRBS[71] <= PRBS[ 7];
      PRBS[70] <= PRBS[ 6];
      PRBS[69] <= PRBS[ 5];
      PRBS[68] <= PRBS[ 4];
      PRBS[67] <= PRBS[ 3];
      PRBS[66] <= PRBS[ 2];
      PRBS[65] <= PRBS[ 1];
      PRBS[64] <= PRBS[28] ~^ PRBS[31];
      PRBS[63] <= PRBS[27] ~^ PRBS[30];
      PRBS[62] <= PRBS[26] ~^ PRBS[29];
      PRBS[61] <= PRBS[25] ~^ PRBS[28];
      PRBS[60] <= PRBS[24] ~^ PRBS[27];
      PRBS[59] <= PRBS[23] ~^ PRBS[26];
      PRBS[58] <= PRBS[22] ~^ PRBS[25];
      PRBS[57] <= PRBS[21] ~^ PRBS[24];
      PRBS[56] <= PRBS[20] ~^ PRBS[23];
      PRBS[55] <= PRBS[19] ~^ PRBS[22];
      PRBS[54] <= PRBS[18] ~^ PRBS[21];
      PRBS[53] <= PRBS[17] ~^ PRBS[20];
      PRBS[52] <= PRBS[16] ~^ PRBS[19];
      PRBS[51] <= PRBS[15] ~^ PRBS[18];
      PRBS[50] <= PRBS[14] ~^ PRBS[17];
      PRBS[49] <= PRBS[13] ~^ PRBS[16];
      PRBS[48] <= PRBS[12] ~^ PRBS[15];
      PRBS[47] <= PRBS[11] ~^ PRBS[14];
      PRBS[46] <= PRBS[10] ~^ PRBS[13];
      PRBS[45] <= PRBS[ 9] ~^ PRBS[12];
      PRBS[44] <= PRBS[ 8] ~^ PRBS[11];
      PRBS[43] <= PRBS[ 7] ~^ PRBS[10];
      PRBS[42] <= PRBS[ 6] ~^ PRBS[ 9];
      PRBS[41] <= PRBS[ 5] ~^ PRBS[ 8];
      PRBS[40] <= PRBS[ 4] ~^ PRBS[ 7];
      PRBS[39] <= PRBS[ 3] ~^ PRBS[ 6];
      PRBS[38] <= PRBS[ 2] ~^ PRBS[ 5];
      PRBS[37] <= PRBS[ 1] ~^ PRBS[ 4];
      PRBS[36] <= PRBS[ 3] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[35] <= PRBS[ 2] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[34] <= PRBS[ 1] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[33] <= PRBS[25] ~^ PRBS[31];
      PRBS[32] <= PRBS[24] ~^ PRBS[30];
      PRBS[31] <= PRBS[23] ~^ PRBS[29];
      PRBS[30] <= PRBS[22] ~^ PRBS[28];
      PRBS[29] <= PRBS[21] ~^ PRBS[27];
      PRBS[28] <= PRBS[20] ~^ PRBS[26];
      PRBS[27] <= PRBS[19] ~^ PRBS[25];
      PRBS[26] <= PRBS[18] ~^ PRBS[24];
      PRBS[25] <= PRBS[17] ~^ PRBS[23];
      PRBS[24] <= PRBS[16] ~^ PRBS[22];
      PRBS[23] <= PRBS[15] ~^ PRBS[21];
      PRBS[22] <= PRBS[14] ~^ PRBS[20];
      PRBS[21] <= PRBS[13] ~^ PRBS[19];
      PRBS[20] <= PRBS[12] ~^ PRBS[18];
      PRBS[19] <= PRBS[11] ~^ PRBS[17];
      PRBS[18] <= PRBS[10] ~^ PRBS[16];
      PRBS[17] <= PRBS[ 9] ~^ PRBS[15];
      PRBS[16] <= PRBS[ 8] ~^ PRBS[14];
      PRBS[15] <= PRBS[ 7] ~^ PRBS[13];
      PRBS[14] <= PRBS[ 6] ~^ PRBS[12];
      PRBS[13] <= PRBS[ 5] ~^ PRBS[11];
      PRBS[12] <= PRBS[ 4] ~^ PRBS[10];
      PRBS[11] <= PRBS[ 3] ~^ PRBS[ 9];
      PRBS[10] <= PRBS[ 2] ~^ PRBS[ 8];
      PRBS[ 9] <= PRBS[ 1] ~^ PRBS[ 7];
      PRBS[ 8] <= PRBS[ 6] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[ 7] <= PRBS[ 5] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[ 6] <= PRBS[ 4] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[ 5] <= PRBS[ 3] ~^ PRBS[25] ~^ PRBS[28];
      PRBS[ 4] <= PRBS[ 2] ~^ PRBS[24] ~^ PRBS[27];
      PRBS[ 3] <= PRBS[ 1] ~^ PRBS[23] ~^ PRBS[26];
      PRBS[ 2] <= PRBS[22] ~^ PRBS[25] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[ 1] <= PRBS[21] ~^ PRBS[24] ~^ PRBS[27] ~^ PRBS[30];
    end
  end
endmodule
