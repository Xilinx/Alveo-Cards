/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`timescale 1 ps / 1 ps

module clk_reset (
    input  wire sys_clk_300_p,
    input  wire sys_clk_300_n,
    output wire sys_clk_100  ,
    output wire sys_rst_100  ,
    output wire sys_clk_50   ,
    output wire sys_rst_50
);

//------------------------------------------
// System 100Mhz Clock Reference

clk_wiz_0 clk_wiz_100mhz
(
    .clk_in1_p  ( sys_clk_300_p      ),
    .clk_in1_n  ( sys_clk_300_n      ),
    .clk_out1   ( sys_clk_100        ),
    .clk_out2   ( sys_clk_50         ),
    .locked     ( sys_clk_100_locked )
);

wire sys_rstn_100;
syncer_reset syncer_reset_100
(
    .clk          ( sys_clk_100         ),
    .resetn_async ( sys_clk_100_locked  ),
    .resetn       ( sys_rstn_100        )
);

assign sys_rst_100 = ~sys_rstn_100;


wire sys_rstn_50;
syncer_reset syncer_reset_50
(
    .clk          ( sys_clk_50         ),
    .resetn_async ( sys_clk_100_locked ),
    .resetn       ( sys_rstn_50        )
);

assign sys_rst_50 = ~sys_rstn_50;

endmodule


 