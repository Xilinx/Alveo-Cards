/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`timescale 1 ps / 1 ps

`define PERIOD_300MHZ_PS  1667
`define PERIOD_161MHZ_PS  3106
`define PERIOD_100MHZ_PS  5000
`define PERIOD_33MHZ_PS  15152
`define PERIOD_25MHZ_PS  20000
`define PERIOD_18MHZ_PS  27778

`define PERIOD_80MHZ_PS  6250
`define PERIOD_70MHZ_PS  7143
`define PERIOD_60MHZ_PS  8333
`define PERIOD_50MHZ_PS  10000
`define PERIOD_40MHZ_PS  12500
`define PERIOD_30MHZ_PS  16664
`define PERIOD_20MHZ_PS  25000
`define PERIOD_10MHZ_PS  50000

module sim_tb ();
localparam MODULE_NAME = "sim_tb";

// -----------------------------------------------------------
// 
//    Signal Connectivity... 
//
// -----------------------------------------------------------

wire jtag_m_axi_aclk   ;
wire jtag_m_axi_aresetn;
`include "sim_wires.sv"

// -----------------------------------------------------------
//
// Clocks and resets... 
//
// -----------------------------------------------------------

`include "sim_clk_reset.sv"

// -----------------------------------------------------------
//
// AXI Register Definitions... 
//
// -----------------------------------------------------------

//`include "system/sim_tb_addr.v"

// --------------------------------------------------------------

integer ii;
integer file_coe;
integer temp;

string         string0;
reg [8*16-1:0] string1;

function [31:0] hex_str_to_int2;
    input string temp1;
    string temp2;
    begin
        temp2 = temp1.substr(0,4);
        hex_str_to_int2 = temp2.atohex();
    end
endfunction


// -----------------------------------------------------------
// 
//    AXI Tasks and Master AXI Driver
//
// -----------------------------------------------------------

//`include "system/sim_axi_master_tasks.vh"

`include "sim_axi_driver.sv"


//sim_axi_monitor #(
//    .INST_NAME ( "sim_axi_monitor" ),
//    .DEBUG_MSG ( "false" )
//) sim_axi_monitor ();


// -----------------------------------------------------------
// 
//    Dummy Renesas I2C Peripherals...
//
// -----------------------------------------------------------

`include "renesas_i2c/renesas_i2c.vh"


// -----------------------------------------------------------
// 
//    Dummy QSFP I2C Peripherals...
//
// -----------------------------------------------------------

//`include "qsfp_i2c/qsfp_i2c.vh"


// -----------------------------------------------------------
// 
//    GTF Config and Execute Sequences...
//
// -----------------------------------------------------------

`include "gtf_tb.sv"


// -----------------------------------------------------------
// 
//    DUT...
//
// -----------------------------------------------------------
    
clk_recov  #(
    .SIMULATION("true"),
    .NUM_CHANNEL(1)
) clk_recov (
    .gtf_ch_gtftxn_0    ( gtf_ch_gtftxn_0     ),
    .gtf_ch_gtftxp_0    ( gtf_ch_gtftxp_0     ),
    .gtf_ch_gtfrxn_0    ( gtf_ch_gtftxn_1     ),
    .gtf_ch_gtfrxp_0    ( gtf_ch_gtftxp_1     ),

    .gtf_ch_gtftxn_1    ( gtf_ch_gtftxn_1     ),
    .gtf_ch_gtftxp_1    ( gtf_ch_gtftxp_1     ),
    .gtf_ch_gtfrxn_1    ( gtf_ch_gtftxn_0     ),
    .gtf_ch_gtfrxp_1    ( gtf_ch_gtftxp_0     ),

    // Free running 300 Mhz Ref Clock
    .CLK13_LVDS_300_P   ( refclk_300          ),
    .CLK13_LVDS_300_N   ( ~refclk_300         ),

    .CLK12_LVDS_300_P   ( refclk_300          ),
    .CLK12_LVDS_300_N   ( ~refclk_300         ),

    // GT Input clock
    .SYNCE_CLK10_LVDS_P ( SYNCE_CLK_LVDS_P    ), 
    .SYNCE_CLK10_LVDS_N ( ~SYNCE_CLK_LVDS_P   ), 

    .SYNCE_CLK11_LVDS_P ( SYNCE_CLK_LVDS_P    ), 
    .SYNCE_CLK11_LVDS_N ( ~SYNCE_CLK_LVDS_P   ), 

    .SYNCE_CLK12_LVDS_P ( SYNCE_CLK_LVDS_P    ), 
    .SYNCE_CLK12_LVDS_N ( ~SYNCE_CLK_LVDS_P   ), 
                          
    .SYNCE_CLK13_LVDS_P ( SYNCE_CLK_LVDS_P    ), 
    .SYNCE_CLK13_LVDS_N ( ~SYNCE_CLK_LVDS_P   ), 

    .SYNCE_CLK14_LVDS_P ( SYNCE_CLK_LVDS_P    ), 
    .SYNCE_CLK14_LVDS_N ( ~SYNCE_CLK_LVDS_P   ), 
                          
    .SYNCE_CLK15_LVDS_P ( SYNCE_CLK_LVDS_P    ), 
    .SYNCE_CLK15_LVDS_N ( ~SYNCE_CLK_LVDS_P   ), 

    .SYNCE_CLK16_LVDS_P ( SYNCE_CLK_LVDS_P    ), 
    .SYNCE_CLK16_LVDS_N ( ~SYNCE_CLK_LVDS_P   ), 
                          
    .SYNCE_CLK17_LVDS_P ( SYNCE_CLK_LVDS_P    ), 
    .SYNCE_CLK17_LVDS_N ( ~SYNCE_CLK_LVDS_P   ), 

    //.RECOV_CLK10_LVDS_P (                     ),
    //.RECOV_CLK10_LVDS_N (                     ),

    .RECOV_CLK11_LVDS_P (                     ),
    .RECOV_CLK11_LVDS_N (                     ),

    // Renesas I2C...
    .CLKGEN_SDA         ( CLKGEN_SDA          ),
    .CLKGEN_SCL         ( CLKGEN_SCL          ),

    // Renesas GPIO and Resetn...
    .JITT_RESETN        ( JITT_RESETN         ),
                                             
    .JITT1_GPOI5        ( JITT1_GPOI5         ),
    .JITT1_GPOI4        ( JITT1_GPOI4         ),
    .JITT1_GPOI3        ( JITT1_GPOI3         ),
    .JITT1_GPOI2        ( JITT1_GPOI2         ),
    .JITT1_GPOI1        ( JITT1_GPOI1         ),
    .JITT1_GPOI0        ( JITT1_GPOI0         ),
                                             
    .JITT2_GPOI5        ( JITT2_GPOI5         ),
    .JITT2_GPOI4        ( JITT2_GPOI4         ),
    .JITT2_GPOI3        ( JITT2_GPOI3         ),
    .JITT2_GPOI2        ( JITT2_GPOI2         ),
    .JITT2_GPOI1        ( JITT2_GPOI1         ),
    .JITT2_GPOI0        ( JITT2_GPOI0         ),
    
    // QSFP Related Signals
    .FPGA_MUX0_RSTN     ( FPGA_MUX0_RSTN      ),
    .FPGA_MUX1_RSTN     ( FPGA_MUX1_RSTN      ),
    .QSFPDD0_IO_RESET_B ( QSFPDD0_IO_RESET_B  ),
    .QSFPDD1_IO_RESET_B ( QSFPDD1_IO_RESET_B  ),
    .QSFPDD2_IO_RESET_B ( QSFPDD2_IO_RESET_B  ),
    .QSFPDD3_IO_RESET_B ( QSFPDD3_IO_RESET_B  ),

    .FPGA_SDA_R         ( FPGA_SDA_R          ),
    .FPGA_SCL_R         ( FPGA_SCL_R          )    
);

// --------------------------------------------------------------
     
endmodule
