/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`timescale 1ps/1ps
module bidir_delay #(parameter DELAY = 60) (
     inout  a, b,
     input a2b
);

assign  #DELAY b = a2b ? a : 1'bz;
assign  #DELAY a = a2b ? 1'bz : b;

endmodule 
