/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`timescale 1 ps / 1 ps

module system_gtf_clk_buffer #(
    parameter SIMULATION    = "false",
    parameter CLK_BUS_WIDTH = 8
) (
    input  wire [CLK_BUS_WIDTH-1:0] SYNCE_CLK_LVDS_P,
    input  wire [CLK_BUS_WIDTH-1:0] SYNCE_CLK_LVDS_N,
    output wire [CLK_BUS_WIDTH-1:0] SYNCE_CLK_OUT
);


wire [CLK_BUS_WIDTH-1:0] SYNCE_CLK_i;

genvar ii;
generate
for (ii=0;ii<CLK_BUS_WIDTH;ii=ii+1) begin
    
    IBUFDS_GTE4 #(
        .REFCLK_EN_TX_PATH  (1'b0),
        .REFCLK_HROW_CK_SEL (2'b00),
        .REFCLK_ICNTL_RX    (2'b00)
    ) IBUFDS_GTE4_INST (
    .I     (SYNCE_CLK_LVDS_P[ii]),
    .IB    (SYNCE_CLK_LVDS_N[ii]),
    .CEB   (1'b0),
    .O     (),
    .ODIV2 (SYNCE_CLK_i[ii])
    );
    
    BUFG_GT BUFG_GT_INST (
        .CE         ( 1'b1              ),
        .CEMASK     ( 1'b0              ),
        .CLR        ( 1'b0              ),
        .CLRMASK    ( 1'b0              ),
        .DIV        ( 3'b0              ),
        .I          ( SYNCE_CLK_i[ii]   ),
        .O          ( SYNCE_CLK_OUT[ii] )
    );

end
endgenerate

endmodule
