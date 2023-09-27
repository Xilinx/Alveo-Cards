/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`timescale 1 ps / 1 ps

module sim_top();

// -----------------------------------------------------------
// 
//    Clock and Reset Generation
//
// -----------------------------------------------------------

// Clock  = 125 Mhz
reg          c0_sys_clk_p;
wire         c0_sys_clk_n = ~c0_sys_clk_p;

initial      
begin
    c0_sys_clk_p = 1'b0;
    forever
    begin
        c0_sys_clk_p = #1667 ~c0_sys_clk_p;
    end
end

// -----------------------------------------------------------

initial      
begin
    #100
    sim_top.renesas_i2c_top.vio_rstn_r = 'h0;
    repeat (100) @(negedge sim_top.renesas_i2c_top.s_axi_aclk);
    sim_top.renesas_i2c_top.vio_rstn_r = 'h1;
end

initial      
begin
    wait (sim_top.renesas_i2c_top.i2c_sequencer.sim_finished === 1);
    wait (sim_top.renesas_i2c_top.i2c_sequencer.sim_finished === 0);
    //repeat (1000) @(posedge c0_sys_clk_p);
    // Delay 100 us
    #100000000
    $finish();
end



// -----------------------------------------------------------
// 
//    DUT....
//
// -----------------------------------------------------------

wire  i2c_sda;  pullup(i2c_sda);
wire  i2c_scl;  pullup(i2c_scl);
 
renesas_i2c_top #(
    .SIMULATION("true")
) renesas_i2c_top (
    .CLK13_LVDS_300_P ( c0_sys_clk_p ),
    .CLK13_LVDS_300_N ( c0_sys_clk_n ),

    .CLKGEN_SDA ( i2c_sda ),
    .CLKGEN_SCL ( i2c_scl )
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

endmodule
