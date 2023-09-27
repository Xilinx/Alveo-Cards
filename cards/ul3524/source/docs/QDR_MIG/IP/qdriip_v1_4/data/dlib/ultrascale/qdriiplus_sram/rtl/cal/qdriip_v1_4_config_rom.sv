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
//  /   /         Filename              : qdriip_v1_4_19_config_rom.v
// /___/   /\     Date Last Modified    : 2016/11/30
// \   \  /  \    Date Created          : Thu Oct 24 2013
//  \___\/\___\
//
//Device            : Ultrascale 
//Design            : QDRII+ SRAM
//Purpose           :
//             ROM with the design parameters saved in it. Microblaze reads
//             this ROM to know the design configuration.
//Reference         :
//Revision History  :
//*****************************************************************************
`timescale 1ps/1ps
module qdriip_v1_4_19_config_rom #
  ( parameter MEM0 = 32'h0000,
    parameter MEM1 = 32'h0000,
    parameter MEM2 = 32'h0000,
    parameter MEM3 = 32'h0000,
    parameter MEM4 = 32'h0000,
    parameter MEM5 = 32'h0000,
    parameter MEM6 = 32'h0000,
    parameter MEM7 = 32'h0000,
    parameter MEM8 = 32'h0000,
    parameter MEM9 = 32'h0000,
    parameter MEM10 = 32'h0000,
    parameter MEM11 = 32'h0000,
    parameter MEM12 = 32'h0000,
    parameter MEM13 = 32'h0000,
    parameter MEM14 = 32'h0000,
    parameter MEM15 = 32'h0000,
    parameter MEM16 = 32'h0000,
    parameter MEM17 = 32'h0000,
    parameter MEM18 = 32'h0000,
    parameter MEM19 = 32'h0000,
    parameter MEM20 = 32'h0000,
    parameter MEM21 = 32'h0000,
    parameter MEM22 = 32'h0000,
    parameter MEM23 = 32'h0000,
    parameter MEM24 = 32'h0000,
    parameter MEM25 = 32'h0000,
    parameter MEM26 = 32'h0000,
    parameter MEM27 = 32'h0000,
    parameter MEM28 = 32'h0000,
    parameter MEM29 = 32'h0000,
    parameter MEM30 = 32'h0000,
    parameter MEM31 = 32'h0000,
    parameter MEM32 = 32'h0000,
    parameter MEM33 = 32'h0000,
    parameter MEM34 = 32'h0000,
    parameter MEM35 = 32'h0000,
    parameter MEM36 = 32'h0000,
    parameter MEM37 = 32'h0000,
    parameter MEM38 = 32'h0000,
    parameter MEM39 = 32'h0000,
    parameter MEM40 = 32'h0000,
    parameter MEM41 = 32'h0000,
    parameter MEM42 = 32'h0000,
    parameter MEM43 = 32'h0000,
    parameter MEM44 = 32'h0000,
    parameter MEM45 = 32'h0000,
    parameter MEM46 = 32'h0000,
    parameter MEM47 = 32'h0000,
    parameter MEM48 = 32'h0000,
    parameter MEM49 = 32'h0000,
    parameter MEM50 = 32'h0000,
    parameter MEM51 = 32'h0000,
    parameter MEM52 = 32'h0000,
    parameter MEM53 = 32'h0000,
    parameter MEM54 = 32'h0000,
    parameter MEM55 = 32'h0000,
    parameter MEM56 = 32'h0000,
    parameter MEM57 = 32'h0000,
    parameter MEM58 = 32'h0000,
    parameter MEM59 = 32'h0000,
    parameter MEM60 = 32'h0000,
    parameter MEM61 = 32'h0000,
    parameter MEM62 = 32'h0000,
    parameter MEM63 = 32'h0000,
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 6 , // DEPTH = 64, ADDR_WIDTH = 6; 
    parameter DEPTH = 64
    

  )
  (

   input                        clk_i,
   input                        rst_i,
   input  [ADDR_WIDTH - 1:0]                      rd_addr,
   output reg [DATA_WIDTH -1:0] dout_o
  );
   





    reg    [DATA_WIDTH - 1:0]  mem[0:DEPTH - 1]; 
    reg    [ADDR_WIDTH - 1:0]  rd_addr_reg;
/*
parameter mif_file = "stimulus.mif";  
initial
begin
    $readmemb(mif_file,mem, 0, DATA_WIDTH);
end
*/


initial begin
// content formats
//        {burst length, instruction, address}
mem[0]  = MEM0; 
mem[1]  = MEM1; 
mem[2]  = MEM2; 
mem[3]  = MEM3; 
mem[4]  = MEM4; 
mem[5]  = MEM5; 
mem[6]  = MEM6; 
mem[7]  = MEM7; 
mem[8]  = MEM8; 
mem[9]  = MEM9; 
mem[10] = MEM10;
mem[11] = MEM11;
mem[12] = MEM12;
mem[13] = MEM13;
mem[14] = MEM14;
mem[15] = MEM15;
mem[16] = MEM16;
mem[17] = MEM17;
mem[18] = MEM18;
mem[19] = MEM19;
mem[20] = MEM20;
mem[21] = MEM21;
mem[22] = MEM22;
mem[23] = MEM23;
mem[24] = MEM24;
mem[25] = MEM25;
mem[26] = MEM26;
mem[27] = MEM27;
mem[28] = MEM28;
mem[29] = MEM29;
mem[30] = MEM30;
mem[31] = MEM31;
mem[32] = MEM32;
mem[33] = MEM33;
mem[34] = MEM34;
mem[35] = MEM35;
mem[36] = MEM36;
mem[37] = MEM37;
mem[38] = MEM38;
mem[39] = MEM39;
mem[40] = MEM40;
mem[41] = MEM41;
mem[42] = MEM42;
mem[43] = MEM43;
mem[44] = MEM44;
mem[45] = MEM45;
mem[46] = MEM46;
mem[47] = MEM47;
mem[48] = MEM48;
mem[49] = MEM49;
mem[50] = MEM50;
mem[51] = MEM51;
mem[52] = MEM52;
mem[53] = MEM53;
mem[54] = MEM54;
mem[55] = MEM55;
mem[56] = MEM56;
mem[57] = MEM57;
mem[58] = MEM58;
mem[59] = MEM59;
mem[60] = MEM60;
mem[61] = MEM61;
mem[62] = MEM62;
mem[63] = MEM63;

end





always @ (posedge clk_i)
begin


      dout_o  <= mem[rd_addr];   //

    end

endmodule
