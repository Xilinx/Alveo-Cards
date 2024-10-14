/*
(c) Copyright 2019-2022 Xilinx, Inc. All rights reserved.
(c) Copyright 2022-2024 Advanced Micro Devices, Inc. All rights reserved.
This file contains confidential and proprietary information
of Xilinx, Inc. and is protected under U.S. and
international copyright and other intellectual property
laws.
DISCLAIMER
This disclaimer is not a license and does not grant any
rights to the materials distributed herewith. Except as
otherwise provided in a valid license issued to you by
Xilinx, and to the maximum extent permitted by applicable
law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
(2) Xilinx shall not be liable (whether in contract or tort,
including negligence, or under any other theory of
liability) for any loss or damage of any kind or nature
related to, arising under or in connection with these
materials, including for any direct, or any indirect,
special, incidental, or consequential loss or damage
(including loss of data, profits, goodwill, or any type of
loss or damage suffered as a result of any action brought
by a third party) even if such damage or loss was
reasonably foreseeable or Xilinx had been advised of the
possibility of the same.
CRITICAL APPLICATIONS
Xilinx proddcts are not designed or intended to be fail-
safe, or for use in any application requiring fail-safe
performance, such as life-support or safety devices or
systems, Class III medical devices, nuclear facilities,
applications related to the deployment of airbags, or any
other applications that could lead to death, personal
injury, or severe property or environmental damage
(individually and collectively, "Critical
Applications"). Customer assumes the sole risk and
liability of any use of Xilinx proddcts in Critical
Applications, subject only to applicable laws and
regulations governing limitations on proddct liability.
THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
PART OF THIS FILE AT ALL TIMES.

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


