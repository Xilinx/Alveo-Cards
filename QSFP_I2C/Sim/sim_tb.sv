/*
Copyright (C) 2024, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: X11
*/

//------------------------------------------------------------------------------

`timescale 1ps/1ps

module sim_tb_top();

// -----------------------------------------------------------
//
// Global Simulation Timout... 
//
// -----------------------------------------------------------

initial
begin
    #20ms;
    $display("#");
    $display("# Test Failed - Sim Timeout - 200us");
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

`include "sim_axi_driver.sv"

// -----------------------------------------------------------
//
// DUT ...
//
// -----------------------------------------------------------

wire  fpga_mux_rstn      ;
wire  qsfpdd1_io_reset_b ;
wire  qsfpdd2_io_reset_b ;

wire  i2c_sda;  pullup(i2c_sda);
wire  i2c_scl;  pullup(i2c_scl);
 
qsfp_i2c_top #( 
    .SIMULATION ( "true" ) 
) u_qsfp_i2c_top (
    .clk_ddr_lvds_300_p ( refclk_300         ),
    .clk_ddr_lvds_300_n ( ~refclk_300        ),

    .fpga_mux_rstn      ( fpga_mux_rstn      ),
    .qsfpdd1_io_reset_b ( qsfpdd1_io_reset_b ),
    .qsfpdd2_io_reset_b ( qsfpdd2_io_reset_b ),

    .fpga_sda_r         ( i2c_sda            ),
    .fpga_scl_r         ( i2c_scl            )
);

// -----------------------------------------------------------
//
// External Components...
//
// -----------------------------------------------------------


// -- This io expander controls the power enable for each qsfp
wire [7:0] gpio_pwr;

tca6406a #(
    .DEVICE_ID ( 'h42 )
) tca6406a_pwr (
    .enable  ( 1'b1     ),
    .sda_io  ( i2c_sda  ),
    .scl_io  ( i2c_scl  ),
    .gpio_io ( gpio_pwr )
);

pulldown (gpio_pwr[0]);
pulldown (gpio_pwr[1]);
pulldown (gpio_pwr[2]);
pulldown (gpio_pwr[3]);
pulldown (gpio_pwr[4]);
pulldown (gpio_pwr[5]);
pulldown (gpio_pwr[6]);
pulldown (gpio_pwr[7]);

assign gpio_pwr[0] = 'h0; // gpio_pwr[1];  
assign gpio_pwr[2] = gpio_pwr[3];
assign gpio_pwr[4] = gpio_pwr[5];
assign gpio_pwr[6] = 'h0; // gpio_pwr[7];


// -- These two switches route to the qsfp's io expanders
wire [7:0] gpio_sw0;

PCA9545ABS #(
    .DEVICE_ID ( 'hE0 )
) PCA9545ABS_sw0 (
    .sda_io  ( i2c_sda  ),
    .scl_io  ( i2c_scl  ),
    .gpio_io ( gpio_sw0 )
);

pulldown (gpio_sw0[0]);  // QSFP 0 Sideband Sel 
pulldown (gpio_sw0[1]);  // QSFP 0 Module Sel
pulldown (gpio_sw0[2]);  // QSFP 1 Sideband Sel
pulldown (gpio_sw0[3]);  // QSFP 1 Module Sel
pulldown (gpio_sw0[4]);
pulldown (gpio_sw0[5]);
pulldown (gpio_sw0[6]);
pulldown (gpio_sw0[7]);


//wire [7:0] gpio_sw1;
//
//PCA9545ABS #(
//    .DEVICE_ID ( 'hE4 )
//) PCA9545ABS_sw1 (
//    .sda_io  ( i2c_sda  ),
//    .scl_io  ( i2c_scl  ),
//    .gpio_io ( gpio_sw1 )
//);
//
//pulldown (gpio_sw1[0]);  // QSFP 2 Sideband Sel 
//pulldown (gpio_sw1[1]);  // QSFP 2 Module Sel
//pulldown (gpio_sw1[2]);  // QSFP 3 Sideband Sel
//pulldown (gpio_sw1[3]);  // QSFP 3 Module Sel
//pulldown (gpio_sw1[4]);
//pulldown (gpio_sw1[5]);
//pulldown (gpio_sw1[6]);
//pulldown (gpio_sw1[7]);


// -- QSFP 0 Sideband IO Expander
wire [7:0] gpio_qsfp_0;
tca6406a #(
    .DEVICE_ID ( 'h40 )
) tca6406a_qsfp_0 (
    .enable  ( gpio_sw0[0]  ),
    .sda_io  ( i2c_sda      ),
    .scl_io  ( i2c_scl      ),
    .gpio_io ( gpio_qsfp_0  )
);

pulldown (gpio_qsfp_0[0]); // QSFP0 LPMODE
pullup   (gpio_qsfp_0[1]); // QSFP0 INTL
pullup   (gpio_qsfp_0[2]); // QSFP0 MODPRSL
pullup   (gpio_qsfp_0[3]); // QSFP0 MODSELL
pulldown (gpio_qsfp_0[4]); // QSFP0 RESETL
pulldown (gpio_qsfp_0[5]);
pulldown (gpio_qsfp_0[6]);
pulldown (gpio_qsfp_0[7]);

// -- QSFP 1 Sideband IO Expander
wire [7:0] gpio_qsfp_1;
tca6406a #(
    .DEVICE_ID ( 'h40 )
) tca6406a_qsfp_1 (
    .enable  ( gpio_sw0[2]  ),
    .sda_io  ( i2c_sda      ),
    .scl_io  ( i2c_scl      ),
    .gpio_io ( gpio_qsfp_1  )
);

pulldown (gpio_qsfp_1[0]); // QSFP1 LPMODE
pullup   (gpio_qsfp_1[1]); // QSFP1 INTL
pullup   (gpio_qsfp_1[2]); // QSFP1 MODPRSL
pullup   (gpio_qsfp_1[3]); // QSFP1 MODSELL
pulldown  (gpio_qsfp_1[4]); // QSFP1 RESETL
pulldown (gpio_qsfp_1[5]);
pulldown (gpio_qsfp_1[6]);
pulldown (gpio_qsfp_1[7]);

//// -- QSFP 2 Sideband IO Expander
//wire [7:0] gpio_qsfp_2;
//tca6406a #(
//    .DEVICE_ID ( 'h40 )
//) tca6406a_qsfp_2 (
//    .enable  ( gpio_sw1[0]  ),
//    .sda_io  ( i2c_sda      ),
//    .scl_io  ( i2c_scl      ),
//    .gpio_io ( gpio_qsfp_2  )
//);
//
//pulldown (gpio_qsfp_2[0]); // QSFP2 LPMODE
//pullup   (gpio_qsfp_2[1]); // QSFP2 INTL
//pullup   (gpio_qsfp_2[2]); // QSFP2 MODPRSL
//pullup   (gpio_qsfp_2[3]); // QSFP2 MODSELL
//pulldown (gpio_qsfp_2[4]); // QSFP2 RESETL
//pulldown (gpio_qsfp_2[5]);
//pulldown (gpio_qsfp_2[6]);
//pulldown (gpio_qsfp_2[7]);
//
//// -- QSFP 3 Sideband IO Expander
//wire [7:0] gpio_qsfp_3;
//tca6406a #(
//    .DEVICE_ID ( 'h40 )
//) tca6406a_qsfp_3 (
//    .enable  ( gpio_sw1[2]  ),
//    .sda_io  ( i2c_sda      ),
//    .scl_io  ( i2c_scl      ),
//    .gpio_io ( gpio_qsfp_3  )
//);
//
//pulldown (gpio_qsfp_3[0]); // QSFP3 LPMODE
//pullup   (gpio_qsfp_3[1]); // QSFP3 INTL
//pullup   (gpio_qsfp_3[2]); // QSFP3 MODPRSL
//pullup   (gpio_qsfp_3[3]); // QSFP3 MODSELL
//pulldown (gpio_qsfp_3[4]); // QSFP3 RESETL
//pulldown (gpio_qsfp_3[5]);
//pulldown (gpio_qsfp_3[6]);
//pulldown (gpio_qsfp_3[7]);


wire  QSFP0_LPMODE  = gpio_qsfp_0[0];
wire  QSFP0_INTL    = gpio_qsfp_0[1];
wire  QSFP0_MODPRSL = gpio_qsfp_0[2];
wire  QSFP0_MODSELL = gpio_qsfp_0[3];
wire  QSFP0_RESETL  = gpio_qsfp_0[4];
                                
wire  QSFP1_LPMODE  = gpio_qsfp_1[0];
wire  QSFP1_INTL    = gpio_qsfp_1[1];
wire  QSFP1_MODPRSL = gpio_qsfp_1[2];
wire  QSFP1_MODSELL = gpio_qsfp_1[3];
wire  QSFP1_RESETL  = gpio_qsfp_1[4];
                                
//wire  QSFP2_LPMODE  = gpio_qsfp_2[0];
//wire  QSFP2_INTL    = gpio_qsfp_2[1];
//wire  QSFP2_MODPRSL = gpio_qsfp_2[2];
//wire  QSFP2_MODSELL = gpio_qsfp_2[3];
//wire  QSFP2_RESETL  = gpio_qsfp_2[4];
//
//wire  QSFP3_LPMODE  = gpio_qsfp_3[0];
//wire  QSFP3_INTL    = gpio_qsfp_3[1];
//wire  QSFP3_MODPRSL = gpio_qsfp_3[2];
//wire  QSFP3_MODSELL = gpio_qsfp_3[3];
//wire  QSFP3_RESETL  = gpio_qsfp_3[4];

// -----------------------------------------------------------
//
//  Test sequences...
//
// -----------------------------------------------------------

`include "sim_test_seq.sv"


endmodule

