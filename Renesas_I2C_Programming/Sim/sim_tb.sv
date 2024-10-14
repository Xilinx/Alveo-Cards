/*
Copyright (C) 2024, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: X11
*/

`timescale 1ps/1ps

module sim_tb_top();

// -----------------------------------------------------------
//
// Global Simulation Timout... 
//
// -----------------------------------------------------------

initial
begin
    #9ms;
    $display("#");
    $display("# Test Failed - Sim Timeout - 9us");
    $display("#");
    $finish();    
end


// -----------------------------------------------------------
//
// Clocks and resets... 
//
// -----------------------------------------------------------

`include "sim_clk_reset.sv"

// -----------------------------------------------------------
//
// User AXI-Lite I/F to JTAG AXI IP... 
//
// -----------------------------------------------------------

//`include "sim_axi_driver.sv"

// -----------------------------------------------------------
// 
//    DUT....
//
// -----------------------------------------------------------

wire  i2c_sda;  pullup(i2c_sda);
wire  i2c_scl;  pullup(i2c_scl);
 
renesas_i2c_top #(
    .SIMULATION("true")
) u_renesas_i2c_top (
    .clk_sys_lvds_300_p ( refclk_300    ),
    .clk_sys_lvds_300_n ( ~refclk_300   ),

    .clkgen_sda_r       ( i2c_sda       ),
    .clkgen_scl_r       ( i2c_scl       )
);
 

// -----------------------------------------------------------
// 
//    External Components....
//
// -----------------------------------------------------------

RC38612A002GN2 #(
    .DEVICE_ID ( 'hB0 )
) RC38612A002GN2_0 (
    .enable  ( 1'b1     ),
    .sda_io  ( i2c_sda  ),
    .scl_io  ( i2c_scl  )
);

RC38612A002GN2 #(
    .DEVICE_ID ( 'hB2 )
) RC38612A002GN2_1 (
    .enable  ( 1'b1     ),
    .sda_io  ( i2c_sda  ),
    .scl_io  ( i2c_scl  )
);

// -----------------------------------------------------------
//
//  Test sequences...
//
// -----------------------------------------------------------

`include "sim_test_seq.sv"


endmodule

