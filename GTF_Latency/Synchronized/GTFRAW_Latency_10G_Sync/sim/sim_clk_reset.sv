/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/


`define PERIOD_300MHZ_PS 3333
`define PERIOD_161MHZ_PS 6207

initial
begin
    // (units, precision, suffix)
    $timeformat( -9, 0, " ns");
end 


// --------------------------------------------------------------
//
// 300 Mhz System Reference Clock 
//

reg refclk_300;
reg refclk_300_rst;

initial      
begin
    refclk_300 = 1'b0;
    forever
    begin
        refclk_300 = #(`PERIOD_300MHZ_PS/2) ~refclk_300;
    end
end


initial      
begin
    refclk_300_rst = 'h0;
    #100
    refclk_300_rst = 'h1;
    repeat (100) @(negedge refclk_300);
    refclk_300_rst = 'h0;
end



// --------------------------------------------------------------
//
// 161 Mhz GTF Reference Clock 
//

reg SYNCE_CLK_LVDS_P;

initial
begin
    SYNCE_CLK_LVDS_P = 0;
    forever
    begin
        SYNCE_CLK_LVDS_P = #(`PERIOD_161MHZ_PS/2) ~SYNCE_CLK_LVDS_P;
    end
end
    


// --------------------------------------------------------------
//
// System Timer 
//

reg [63:0] timer_sys;
always@(posedge refclk_300)
    if (refclk_300_rst)
        timer_sys <= 'h0;
    else
        timer_sys <= timer_sys + 1;

// --------------------------------------------------------------


