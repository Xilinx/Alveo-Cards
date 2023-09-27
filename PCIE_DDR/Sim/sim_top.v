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

initial      c0_sys_clk_p <= 1'b0;
always #1667 c0_sys_clk_p <= ~c0_sys_clk_p;

// Clock  = 50 Mhz
reg           ref_clk_50;
initial       ref_clk_50 <= 1'b0;
always #10000 ref_clk_50 <= ~ref_clk_50;

// Clock  = 100 Mhz
reg          ref_clk_100;
initial      ref_clk_100 <= 1'b0;
always #5000 ref_clk_100 <= ~ref_clk_100;



reg sys_resetn;
initial 
begin
    sys_resetn <= 1'b1;
    #1;
    sys_resetn <= 1'b0;
    repeat (100) @(posedge ref_clk_50);
    sys_resetn <= 1'b1;
end

// -----------------------------------------------------------

localparam AXI_ADDR_WIDTH = 32;
localparam AXI_DATA_WIDTH = 32;

wire  m_axi_aclk    = ref_clk_50;
wire  m_axi_aresetn = sys_resetn;


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
 
ddr_i2c_top ddr_i2c_top (
    .s_axi_aclk     ( m_axi_aclk    ),
    .s_axi_aresetn  ( m_axi_aresetn ),

    // AXI Master Interface...  
    .s_axi_araddr   ( m_axi_araddr   ),
    .s_axi_arvalid  ( m_axi_arvalid  ),
    .s_axi_arready  ( m_axi_arready  ),
                      
    .s_axi_awaddr   ( m_axi_awaddr   ),
    .s_axi_awvalid  ( m_axi_awvalid  ),
    .s_axi_awready  ( m_axi_awready  ),
                      
    .s_axi_bready   ( m_axi_bready   ),
    .s_axi_bresp    ( m_axi_bresp    ),
    .s_axi_bvalid   ( m_axi_bvalid   ),
                      
    .s_axi_rready   ( m_axi_rready   ),
    .s_axi_rdata    ( m_axi_rdata    ),
    .s_axi_rresp    ( m_axi_rresp    ),
    .s_axi_rvalid   ( m_axi_rvalid   ),
                      
    .s_axi_wdata    ( m_axi_wdata    ),
    .s_axi_wstrb    ( m_axi_wstrb    ),
    .s_axi_wvalid   ( m_axi_wvalid   ),
    .s_axi_wready   ( m_axi_wready   ),

    .i2c_sda        ( i2c_sda        ),
    .i2c_scl        ( i2c_scl        )
);
 

// -----------------------------------------------------------
// 
//    External Components....
//
// -----------------------------------------------------------

wire [7:0] gpio_io;

tca6406a #(
    .DEVICE_ID ( 'h42 )
) tca6406a (
    .enable  ( 1'b1    ),
    .sda_io  ( i2c_sda ),
    .scl_io  ( i2c_scl ),
    .gpio_io ( gpio_io )
);

pulldown (gpio_io[0]);
pulldown (gpio_io[1]);
pulldown (gpio_io[2]);
pulldown (gpio_io[3]);
pulldown (gpio_io[4]);
pullup   (gpio_io[5]);
pulldown (gpio_io[6]);
pullup   (gpio_io[7]);

endmodule
