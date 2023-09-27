/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

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

//// Clock  = 50 Mhz
//reg           ref_clk_50;
//initial       ref_clk_50 <= 1'b0;
//always #10000 ref_clk_50 <= ~ref_clk_50;
//
//// Clock  = 100 Mhz
//reg          ref_clk_100;
//initial      ref_clk_100 <= 1'b0;
//always #5000 ref_clk_100 <= ~ref_clk_100;
//
//
//
//reg sys_resetn;
//initial 
//begin
//    sys_resetn <= 1'b1;
//    #1;
//    sys_resetn <= 1'b0;
//    repeat (100) @(posedge ref_clk_50);
//    sys_resetn <= 1'b1;
//end

localparam ST_DELAY = 'h05;
initial
begin
    // Wait until state machine is completed...
    wait (sim_top.qsfp_i2c_top.state_machine_top.cstate == ST_DELAY);
    // delay 1ms...
    #1000000000; 
    $finish();
end
// -----------------------------------------------------------

localparam AXI_ADDR_WIDTH = 32;
localparam AXI_DATA_WIDTH = 32;

wire                          m_axi_aclk    ; // output of DUT = ref_clk_50;
wire                          m_axi_aresetn ; // output of DUT = sys_resetn;


// AXI Master Interface...
wire [AXI_ADDR_WIDTH-1:0]     m_axi_araddr   ;
wire                          m_axi_arvalid  ;
wire                          m_axi_arready  ;

wire [AXI_ADDR_WIDTH-1:0]     m_axi_awaddr   ;
wire                          m_axi_awvalid  ;
wire                          m_axi_awready  ;

wire                          m_axi_bready   ;
wire [1:0]                    m_axi_bresp    ;
wire                          m_axi_bvalid   ;

wire                          m_axi_rready   ;
wire [AXI_DATA_WIDTH-1:0]     m_axi_rdata    ;
wire [1:0]                    m_axi_rresp    ;
wire                          m_axi_rvalid   ;

wire [AXI_DATA_WIDTH-1:0]     m_axi_wdata    ;
wire [AXI_DATA_WIDTH/8-1:0]   m_axi_wstrb    ;
wire                          m_axi_wvalid   ;
wire                          m_axi_wready   ;

// I2C Signals to DUT....
//assign sim_top.qsfp_i2c_top.s_axi_aclk     = m_axi_aclk    ;
//assign sim_top.qsfp_i2c_top.s_axi_aresetn  = m_axi_aresetn ;
//
//assign sim_top.qsfp_i2c_top.s_axi_araddr   = m_axi_araddr  ;
//assign sim_top.qsfp_i2c_top.s_axi_arvalid  = m_axi_arvalid ;
//
//assign sim_top.qsfp_i2c_top.s_axi_awaddr   = m_axi_awaddr  ;
//assign sim_top.qsfp_i2c_top.s_axi_awvalid  = m_axi_awvalid ;
//
//assign sim_top.qsfp_i2c_top.s_axi_bready   = m_axi_bready  ;
//
//assign sim_top.qsfp_i2c_top.s_axi_rready   = m_axi_rready  ;
//
//assign sim_top.qsfp_i2c_top.s_axi_wdata    = m_axi_wdata   ;
//assign sim_top.qsfp_i2c_top.s_axi_wstrb    = m_axi_wstrb   ;
//assign sim_top.qsfp_i2c_top.s_axi_wvalid   = m_axi_wvalid  ;
//
//// I2C Signals from DUT...
//assign m_axi_arready = sim_top.qsfp_i2c_top.s_axi_arready ;
//assign m_axi_awready = sim_top.qsfp_i2c_top.s_axi_awready ;
//                                                          
//assign m_axi_wready  = sim_top.qsfp_i2c_top.s_axi_wready  ;
//assign m_axi_bresp   = sim_top.qsfp_i2c_top.s_axi_bresp   ;
//assign m_axi_bvalid  = sim_top.qsfp_i2c_top.s_axi_bvalid  ;
//                                                          
//assign m_axi_rdata   = sim_top.qsfp_i2c_top.s_axi_rdata   ;
//assign m_axi_rresp   = sim_top.qsfp_i2c_top.s_axi_rresp   ;
//assign m_axi_rvalid  = sim_top.qsfp_i2c_top.s_axi_rvalid  ;


// -----------------------------------------------------------
// 
//    Traffic Generator to AXI Master....
//
// -----------------------------------------------------------

tg_top #(
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ), 
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH )
) tg_top (
    .m_axi_aclk     ( m_axi_aclk     ),
    .m_axi_aresetn  ( m_axi_aresetn  ),

    // AXI Master Interface...  
    .m_axi_araddr   ( m_axi_araddr   ),
    .m_axi_arvalid  ( m_axi_arvalid  ),
    .m_axi_arready  ( m_axi_arready  ),

    .m_axi_awaddr   ( m_axi_awaddr   ),
    .m_axi_awvalid  ( m_axi_awvalid  ),
    .m_axi_awready  ( m_axi_awready  ),

    .m_axi_bready   ( m_axi_bready   ),
    .m_axi_bresp    ( m_axi_bresp    ),
    .m_axi_bvalid   ( m_axi_bvalid   ),

    .m_axi_rready   ( m_axi_rready   ),
    .m_axi_rdata    ( m_axi_rdata    ),
    .m_axi_rresp    ( m_axi_rresp    ),
    .m_axi_rvalid   ( m_axi_rvalid   ),

    .m_axi_wdata    ( m_axi_wdata    ),
    .m_axi_wstrb    ( m_axi_wstrb    ),
    .m_axi_wvalid   ( m_axi_wvalid   ),
    .m_axi_wready   ( m_axi_wready   )
);

// -----------------------------------------------------------
// 
//    DUT....
//
// -----------------------------------------------------------

wire  i2c_sda;  pullup(i2c_sda);
wire  i2c_scl;  pullup(i2c_scl);
 
qsfp_i2c_top #( 
    .SIMULATION ( "true" ) 
) qsfp_i2c_top (
    .CLK13_LVDS_300_P ( c0_sys_clk_p ),
    .CLK13_LVDS_300_N ( c0_sys_clk_n ),

    .FPGA_SDA_R       ( i2c_sda      ),
    .FPGA_SCL_R       ( i2c_scl      )
);
 

// -----------------------------------------------------------
// 
//    External Components....
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

assign gpio_pwr[0] = gpio_pwr[1];  
assign gpio_pwr[2] = gpio_pwr[3];
assign gpio_pwr[4] = gpio_pwr[5];
assign gpio_pwr[6] = gpio_pwr[7];


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


wire [7:0] gpio_sw1;

PCA9545ABS #(
    .DEVICE_ID ( 'hE4 )
) PCA9545ABS_sw1 (
    .sda_io  ( i2c_sda  ),
    .scl_io  ( i2c_scl  ),
    .gpio_io ( gpio_sw1 )
);

pulldown (gpio_sw1[0]);  // QSFP 2 Sideband Sel 
pulldown (gpio_sw1[1]);  // QSFP 2 Module Sel
pulldown (gpio_sw1[2]);  // QSFP 3 Sideband Sel
pulldown (gpio_sw1[3]);  // QSFP 3 Module Sel
pulldown (gpio_sw1[4]);
pulldown (gpio_sw1[5]);
pulldown (gpio_sw1[6]);
pulldown (gpio_sw1[7]);


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

// -- QSFP 2 Sideband IO Expander
wire [7:0] gpio_qsfp_2;
tca6406a #(
    .DEVICE_ID ( 'h40 )
) tca6406a_qsfp_2 (
    .enable  ( gpio_sw1[0]  ),
    .sda_io  ( i2c_sda      ),
    .scl_io  ( i2c_scl      ),
    .gpio_io ( gpio_qsfp_2  )
);

pulldown (gpio_qsfp_2[0]); // QSFP2 LPMODE
pullup   (gpio_qsfp_2[1]); // QSFP2 INTL
pullup   (gpio_qsfp_2[2]); // QSFP2 MODPRSL
pullup   (gpio_qsfp_2[3]); // QSFP2 MODSELL
pulldown (gpio_qsfp_2[4]); // QSFP2 RESETL
pulldown (gpio_qsfp_2[5]);
pulldown (gpio_qsfp_2[6]);
pulldown (gpio_qsfp_2[7]);

// -- QSFP 3 Sideband IO Expander
wire [7:0] gpio_qsfp_3;
tca6406a #(
    .DEVICE_ID ( 'h40 )
) tca6406a_qsfp_3 (
    .enable  ( gpio_sw1[2]  ),
    .sda_io  ( i2c_sda      ),
    .scl_io  ( i2c_scl      ),
    .gpio_io ( gpio_qsfp_3  )
);

pulldown (gpio_qsfp_3[0]); // QSFP3 LPMODE
pullup   (gpio_qsfp_3[1]); // QSFP3 INTL
pullup   (gpio_qsfp_3[2]); // QSFP3 MODPRSL
pullup   (gpio_qsfp_3[3]); // QSFP3 MODSELL
pulldown (gpio_qsfp_3[4]); // QSFP3 RESETL
pulldown (gpio_qsfp_3[5]);
pulldown (gpio_qsfp_3[6]);
pulldown (gpio_qsfp_3[7]);


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
                                
wire  QSFP2_LPMODE  = gpio_qsfp_2[0];
wire  QSFP2_INTL    = gpio_qsfp_2[1];
wire  QSFP2_MODPRSL = gpio_qsfp_2[2];
wire  QSFP2_MODSELL = gpio_qsfp_2[3];
wire  QSFP2_RESETL  = gpio_qsfp_2[4];

wire  QSFP3_LPMODE  = gpio_qsfp_3[0];
wire  QSFP3_INTL    = gpio_qsfp_3[1];
wire  QSFP3_MODPRSL = gpio_qsfp_3[2];
wire  QSFP3_MODSELL = gpio_qsfp_3[3];
wire  QSFP3_RESETL  = gpio_qsfp_3[4];
endmodule
