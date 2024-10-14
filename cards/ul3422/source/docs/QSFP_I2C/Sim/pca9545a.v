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

//------------------------------------------------------------------------------

`timescale 1ns / 1ns

module PCA9545ABS #(
    parameter [7:0] DEVICE_ID = 'h42
)(
    input  wire       scl_io  ,
    inout  wire       sda_io  ,
    inout  wire [7:0] gpio_io 
);

// ---------------------------------------------------

reg RST;

initial 
begin
    RST <= 1'b0;
    #10;
    RST <= 1'b1;
    #10;
    RST <= 1'b0;
end

// ---------------------------------------------------
//  This device has four registers to control/sample
//  the 8 GPIO pins...
//    Addr  Function
//    0x00  Input value for each port 
//    0x01  Output value for each port (Default = 0x00) 
//    0x02  Polarity Control (1 = invert, 0 = normal, default = 0x00)
//    0x03  Direction Confif (1 = input, 0 = output, default = 0xFF) 

wire       addr_strobe  ;
wire       write_strobe ;
wire       read_strobe  ;
wire [7:0] wdata        ;
reg  [7:0] rdata        ;

i2c_slave_if #( 
    .device_address (DEVICE_ID) 
) i2c_slave_if (
    .enable       ( 1'b1         ) ,
    .scl_io       ( scl_io       ) ,
    .sda_io       ( sda_io       ) ,
    .addr_strobe  ( addr_strobe  ) ,
    .write_strobe ( write_strobe ) ,
    .read_strobe  ( read_strobe  ) ,
    .wdata        ( wdata        ) ,
    .rdata        ( rdata        ) 
);

// ---------------------------------------------------

reg  [7:0] r1_output_pre ; 
reg  [7:0] r2_pol_pre    ; // 1 = invert 
reg  [7:0] r3_config_pre ; // 1 = input

wire [7:0] r0_input  ; 
reg  [7:0] r1_output ; 
reg  [7:0] r2_pol    ; // 1 = invert 
reg  [7:0] r3_config ; // 1 = input

initial  r1_output_pre  <= 'h00;
initial  r2_pol_pre     <= 'h00;
//initial  r3_config  <= 'hFF;
initial  r3_config_pre  <= 'h00;  // output only

initial  r1_output  <= 'h00;
initial  r2_pol     <= 'h00;
//initial  r3_config  <= 'hFF;
initial  r3_config  <= 'h00;  // output only

reg [7:0] addr;
always@(posedge addr_strobe)
    addr <= wdata;

always@(posedge write_strobe)
    r1_output_pre <= wdata;
    //if      (addr == 'h1) r1_output_pre <= wdata;
    //else if (addr == 'h2) r2_pol_pre    <= wdata;
    //else if (addr == 'h3) r3_config_pre <= wdata;

always @(negedge write_strobe)
    r1_output <= r1_output_pre;
    //if      (addr == 'h1) r1_output <= r1_output_pre;
    //else if (addr == 'h2) r2_pol    <= r2_pol_pre   ;
    //else if (addr == 'h3) r3_config <= r3_config_pre;

always @(posedge addr_strobe)
    rdata <= r0_input ;
    //if      (wdata == 'h0) rdata <= r0_input ;
    //else if (wdata == 'h1) rdata <= r1_output;
    //else if (wdata == 'h2) rdata <= r2_pol   ;
    //else if (wdata == 'h3) rdata <= r3_config;

// ---------------------------------------------------

//IOBUF port_0 ( .IO ( gpio_0 ), .I ( r1_output[0] ), .O (r0_input[0]), .T ( r3_config[0] ));
//IOBUF port_1 ( .IO ( gpio_1 ), .I ( r1_output[1] ), .O (r0_input[1]), .T ( r3_config[1] ));
//IOBUF port_2 ( .IO ( gpio_2 ), .I ( r1_output[2] ), .O (r0_input[2]), .T ( r3_config[2] ));
//IOBUF port_3 ( .IO ( gpio_3 ), .I ( r1_output[3] ), .O (r0_input[3]), .T ( r3_config[3] ));
//IOBUF port_4 ( .IO ( gpio_4 ), .I ( r1_output[4] ), .O (r0_input[4]), .T ( r3_config[4] ));
//IOBUF port_5 ( .IO ( gpio_5 ), .I ( r1_output[5] ), .O (r0_input[5]), .T ( r3_config[5] ));
//IOBUF port_6 ( .IO ( gpio_6 ), .I ( r1_output[6] ), .O (r0_input[6]), .T ( r3_config[6] ));
//IOBUF port_7 ( .IO ( gpio_7 ), .I ( r1_output[7] ), .O (r0_input[7]), .T ( r3_config[7] ));

IOBUF port_0 ( .IO ( gpio_io[0] ), .I ( r1_output[0] ), .O (r0_input[0]), .T ( r3_config[0] ));
IOBUF port_1 ( .IO ( gpio_io[1] ), .I ( r1_output[1] ), .O (r0_input[1]), .T ( r3_config[1] ));
IOBUF port_2 ( .IO ( gpio_io[2] ), .I ( r1_output[2] ), .O (r0_input[2]), .T ( r3_config[2] ));
IOBUF port_3 ( .IO ( gpio_io[3] ), .I ( r1_output[3] ), .O (r0_input[3]), .T ( r3_config[3] ));
IOBUF port_4 ( .IO ( gpio_io[4] ), .I ( r1_output[4] ), .O (r0_input[4]), .T ( r3_config[4] ));
IOBUF port_5 ( .IO ( gpio_io[5] ), .I ( r1_output[5] ), .O (r0_input[5]), .T ( r3_config[5] ));
IOBUF port_6 ( .IO ( gpio_io[6] ), .I ( r1_output[6] ), .O (r0_input[6]), .T ( r3_config[6] ));
IOBUF port_7 ( .IO ( gpio_io[7] ), .I ( r1_output[7] ), .O (r0_input[7]), .T ( r3_config[7] ));

endmodule

