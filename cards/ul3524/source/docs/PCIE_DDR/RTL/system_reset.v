/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

module system_reset (
    input   wire    clk_sys_p   ,
    input   wire    clk_sys_n   ,

    output  wire    sys_aclk    ,
    output  reg     sys_aresetn ,
    
    output  wire    sys_aclk_10M
);


// ##########################################################################
// #
// # Startup Block
// #
// ##########################################################################

wire      CFGMCLK;
wire      EOS;

// STARTUPE3: UltraScale STARTUP Block
STARTUPE3 #(
    .PROG_USR("FALSE"),    // Activate program event security feature. Requires encrypted bitstreams.
    .SIM_CCLK_FREQ(0.0)    // Set the Configuration Clock Frequency(ns) for simulation
)
STARTUPE3_inst (
    .CFGCLK(),             // 1-bit output: Configuration main clock output
    .CFGMCLK(CFGMCLK),     // 1-bit output: Configuration internal oscillator clock output
    .DI(),                 // 4-bit output: Allow receiving on the D input pin
    .EOS(EOS),             // 1-bit output: Active-High output signal indicating the End Of Startup
    .PREQ(),               // 1-bit output: PROGRAM request to fabric output
    .DO(),                 // 4-bit input: Allows control of the D pin output
    .DTS(),                // 4-bit input: Allows tristate of the D pin
    .FCSBO(),              // 1-bit input: Contols the FCS_B pin for flash access
    .FCSBTS(),             // 1-bit input: Tristate the FCS_B pin
    .GSR(),                // 1-bit input: Global Set/Reset input (GSR cannot be used for the port)
    .GTS(),                // 1-bit input: Global 3-state input (GTS cannot be used for the port name)
    .KEYCLEARB(),          // 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
    .PACK(),               // 1-bit input: PROGRAM acknowledge input
    .USRCCLKO(),           // 1-bit input: User CCLK input
    .USRCCLKTS(),          // 1-bit input: User CCLK 3-state enable input
    .USRDONEO(),           // 1-bit input: User DONE pin output control
    .USRDONETS()           // 1-bit input: User DONE 3-state enable output
);

// ##########################################################################
// #
// # Clock Generation
// #
// ##########################################################################


// Input buffering
//------------------------------------
wire clk_in1_clk_wiz_0;

IBUFDS clkin1_ibufds (
    .I  ( clk_sys_p         ),
    .IB ( clk_sys_n         ),
    .O  ( clk_in1_clk_wiz_0 )
);


// Clocking PRIMITIVE
//------------------------------------

// INPUT_FREQ * CLKFBOUT_MULT_F / CLKOUT0_DIVIDE_F = OUTPUT FREQ
//  CLKOUT0 = 300 Mhz * 4.000 / 12.000 = 100Mhz  
//  CLKOUT1 = 300 Mhz * 4.000 / 128.000 = 10Mhz  
      
wire clk_out0_clk_wiz_0;
wire locked_int;
wire clkfbout_clk_wiz_0;
  
MMCME4_ADV #(
    .BANDWIDTH            ("OPTIMIZED"),
    .CLKOUT4_CASCADE      ("FALSE"),
    .COMPENSATION         ("AUTO"),
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (1),
    .CLKFBOUT_MULT_F      (4.000),
    .CLKFBOUT_PHASE       (0.000),
    .CLKFBOUT_USE_FINE_PS ("FALSE"),
    .CLKOUT0_DIVIDE_F     (12.000),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKOUT0_USE_FINE_PS  ("FALSE"),
    .CLKOUT1_DIVIDE       (120),
    .CLKOUT1_PHASE        (0.000),
    .CLKOUT1_DUTY_CYCLE   (0.500),
    .CLKOUT1_USE_FINE_PS  ("FALSE"),
    .CLKIN1_PERIOD        (3.333)
) mmcme4_adv_inst (
     // Input clock control
    .CLKFBIN             ( clkfbout_clk_wiz_0 ),
    .CLKIN1              ( clk_in1_clk_wiz_0  ),
    .CLKIN2              ( 1'b0               ),
    // Output Clocks                          
    .CLKFBOUT            ( clkfbout_clk_wiz_0 ),
    .CLKFBOUTB           (                    ),
    .CLKOUT0             ( clk_out0_clk_wiz_0 ),
    .CLKOUT0B            (                    ),
    .CLKOUT1             ( clk_out1_clk_wiz_0 ),
    .CLKOUT1B            (                    ),
    .CLKOUT2             (                    ),
    .CLKOUT2B            (                    ),
    .CLKOUT3             (                    ),
    .CLKOUT3B            (                    ),
    .CLKOUT4             (                    ),
    .CLKOUT5             (                    ),
    .CLKOUT6             (                    ),
     // Tied to always select the primary input clock
    .CLKINSEL            ( 1'b1               ),
    // Ports for dynamic reconfiguration      
    .DADDR               ( 7'h0               ),
    .DCLK                ( 1'b0               ),
    .DEN                 ( 1'b0               ),
    .DI                  ( 16'h0              ),
    .DO                  (                    ),
    .DRDY                (                    ),
    .DWE                 ( 1'b0               ),
    .CDDCDONE            (                    ),
    .CDDCREQ             ( 1'b0               ),
    // Ports for dynamic phase shift          
    .PSCLK               ( 1'b0               ),
    .PSEN                ( 1'b0               ),
    .PSINCDEC            ( 1'b0               ),
    .PSDONE              (                    ),
    // Other control and status signals       
    .LOCKED              ( locked_int         ),
    .CLKINSTOPPED        (                    ),
    .CLKFBSTOPPED        (                    ),
    .PWRDWN              ( 1'b0               ),
    .RST                 ( ~EOS               )
);

// Output buffering
//-----------------------------------

BUFG clkout0_buf (
    .I   (clk_out0_clk_wiz_0),
    .O   (sys_aclk)
);

BUFG clkout1_buf (
    .I   (clk_out1_clk_wiz_0),
    .O   (sys_aclk_10M)
);


// ##########################################################################
// #
// # Sys Resetn Generation
// #
// ##########################################################################

reg [31:0] timer;
always@(posedge sys_aclk)
begin
    if (!locked_int)
        timer <= 'h0;
    else if (timer == 'hFFFF)
        timer <= 'hFFFF;
    else
        timer <= timer + 1;
end

always@(posedge sys_aclk)
begin
    if (!locked_int)
        sys_aresetn <= 'h0;
    else if (timer == 'h0100)
        sys_aresetn <= 'h1;
end


endmodule
