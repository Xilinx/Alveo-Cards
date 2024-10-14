/*
Copyright (C) 2024, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: X11
*/


initial
begin
    // (units, precision, suffix)
    $timeformat( -9, 0, " ns");
end 


// --------------------------------------------------------------
//
// 100 Mhz System Reference Clock 
//

reg refclk_100;
reg refclk_100_rst;

initial
begin
    refclk_100 = 0;
    forever
    begin
        refclk_100 = #5000  ~refclk_100;
    end
end

initial      
begin
    #100
    refclk_100_rst = 'h1;
    repeat (100) @(negedge refclk_100);
    refclk_100_rst = 'h0;
end


// --------------------------------------------------------------
//
// 300 Mhz System Reference Clock 
//

reg refclk_300;
reg refclk_300_rst;

initial
begin
    refclk_300 = 0;
    forever
    begin
        refclk_300 = #1666  ~refclk_300;
    end
end

initial      
begin
    #100
    refclk_300_rst = 'h1;
    repeat (100) @(negedge refclk_300);
    refclk_300_rst = 'h0;
end


// --------------------------------------------------------------
//
// 161 Mhz GTF Reference Clock 
//

reg refclk_161;
reg refclk_161_rst;

initial
begin
    refclk_161 = 0;
    forever
    begin
        refclk_161 = #3103  ~refclk_161;
    end
end

initial      
begin
    #100
    refclk_161_rst = 'h1;
    repeat (100) @(negedge refclk_161);
    refclk_161_rst = 'h0;
end

// --------------------------------------------------------------
//
// System Timer 
//

reg [31:0] timer_sys;
always@(posedge refclk_300)
    if (refclk_300_rst)
        timer_sys <= 'h0;
    else
        timer_sys <= timer_sys + 1;


