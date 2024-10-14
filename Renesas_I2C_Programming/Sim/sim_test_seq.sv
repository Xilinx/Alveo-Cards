/*
Copyright (C) 2024, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: X11
*/


initial      
begin
    #1
    sim_tb_top.u_renesas_i2c_top.vio_rstn_r = 'h0;
    repeat (100) @(negedge sim_tb_top.u_renesas_i2c_top.s_axi_aclk);
    sim_tb_top.u_renesas_i2c_top.vio_rstn_r = 'h1;

    wait (sim_tb_top.u_renesas_i2c_top.i2c_sequencer.sim_finished === 1);
    wait (sim_tb_top.u_renesas_i2c_top.i2c_sequencer.sim_finished === 0);

    #100000000

    $display("#");
    $display("# Test Completed");
    $display("#");
    $finish();    
end

