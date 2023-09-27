/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

module renesas_gpio (
    // System Interface
    input  wire        sys_if_clk    ,   
    input  wire        sys_if_rstn   ,
    input  wire        sys_if_wen    ,    
    input  wire [31:0] sys_if_addr   ,   
    input  wire [31:0] sys_if_wdata  ,  
    output wire [31:0] sys_if_rdata  , 

    // ....
    inout  wire        JITT1_RESETn  ,

    inout  wire        JITT1_GPIO5   ,
    inout  wire        JITT1_GPIO4   ,
    inout  wire        JITT1_GPIO3   ,
    inout  wire        JITT1_GPIO2   ,
    inout  wire        JITT1_GPIO1   ,
    inout  wire        JITT1_GPIO0   ,

    inout  wire        JITT2_GPIO5   ,
    inout  wire        JITT2_GPIO4   ,
    inout  wire        JITT2_GPIO3   ,
    inout  wire        JITT2_GPIO2   ,
    inout  wire        JITT2_GPIO1   ,
    inout  wire        JITT2_GPIO0   
);

// ======================================================================
//                          0123456789abcdef
localparam HEADER_STRING = "JC GPIO Rev 1.1 ";

wire [31:0] IO_HEADER0_VALUE  = HEADER_STRING[8*16-1:8*12];
wire [31:0] IO_HEADER1_VALUE  = HEADER_STRING[8*12-1:8*8];
wire [31:0] IO_HEADER2_VALUE  = HEADER_STRING[8*8-1:8*4];
wire [31:0] IO_HEADER3_VALUE  = HEADER_STRING[8*4-1:8*0];

// ======================================================================
//  System Register Interface

wire [5:0] jitt1_gpio_i;
wire [5:0] jitt1_gpio_o;
wire [5:0] jitt1_gpio_t;

wire [5:0] jitt2_gpio_i;
wire [5:0] jitt2_gpio_o;
wire [5:0] jitt2_gpio_t;

wire       jitt_resetn_i;
wire       jitt_resetn_o;
wire       jitt_resetn_t;

renesas_gpio_regs renesas_gpio_regs (
    // System Register Interface...
    .sys_if_clk   ( sys_if_clk     ),
    .sys_if_rstn  ( sys_if_rstn    ),
    .sys_if_wen   ( sys_if_wen     ),
    .sys_if_addr  ( sys_if_addr    ),
    .sys_if_wdata ( sys_if_wdata   ),
    .sys_if_rdata ( sys_if_rdata   ),

    // Internal Module Signals...
    .IO_HEADER0_VALUE         ( IO_HEADER0_VALUE ),
    .IO_HEADER1_VALUE         ( IO_HEADER1_VALUE ),
    .IO_HEADER2_VALUE         ( IO_HEADER2_VALUE ),
    .IO_HEADER3_VALUE         ( IO_HEADER3_VALUE ),

    .IO_JITT_RSTN_IN_VALUE    ( jitt_resetn_i    ),
    .IO_JITT_RSTN_OUT_VALUE   ( jitt_resetn_o    ),
    .IO_JITT_RSTN_CFG_VALUE   ( jitt_resetn_t    ),
    .IO_JITT1_GPIO_IN_VALUE   ( jitt1_gpio_i     ),
    .IO_JITT1_GPIO_OUT_VALUE  ( jitt1_gpio_o     ),
    .IO_JITT1_GPIO_CFG_VALUE  ( jitt1_gpio_t     ),
    .IO_JITT2_GPIO_IN_VALUE   ( jitt2_gpio_i     ),
    .IO_JITT2_GPIO_OUT_VALUE  ( jitt2_gpio_o     ),
    .IO_JITT2_GPIO_CFG_VALUE  ( jitt2_gpio_t     )
);


// ======================================================================
//  IOBUF instances for GPIO Pins....

IOBUF  IO_JITT1_RESETN ( .IO( JITT1_RESETn ), .I( jitt_resetn_o ), .O( jitt_resetn_i ), .T( jitt_resetn_t ) );

IOBUF  IO_JITT1_GPIO5 ( .IO( JITT1_GPIO5 ), .I( jitt1_gpio_o[5] ), .O( jitt1_gpio_i[5] ), .T( jitt1_gpio_t[5] ) );
IOBUF  IO_JITT1_GPIO4 ( .IO( JITT1_GPIO4 ), .I( jitt1_gpio_o[4] ), .O( jitt1_gpio_i[4] ), .T( jitt1_gpio_t[4] ) );
IOBUF  IO_JITT1_GPIO3 ( .IO( JITT1_GPIO3 ), .I( jitt1_gpio_o[3] ), .O( jitt1_gpio_i[3] ), .T( jitt1_gpio_t[3] ) );
IOBUF  IO_JITT1_GPIO2 ( .IO( JITT1_GPIO2 ), .I( jitt1_gpio_o[2] ), .O( jitt1_gpio_i[2] ), .T( jitt1_gpio_t[2] ) );
IOBUF  IO_JITT1_GPIO1 ( .IO( JITT1_GPIO1 ), .I( jitt1_gpio_o[1] ), .O( jitt1_gpio_i[1] ), .T( jitt1_gpio_t[1] ) );
IOBUF  IO_JITT1_GPIO0 ( .IO( JITT1_GPIO0 ), .I( jitt1_gpio_o[0] ), .O( jitt1_gpio_i[0] ), .T( jitt1_gpio_t[0] ) );

IOBUF  IO_JITT2_GPIO5 ( .IO( JITT2_GPIO5 ), .I( jitt2_gpio_o[5] ), .O( jitt2_gpio_i[5] ), .T( jitt2_gpio_t[5] ) );
IOBUF  IO_JITT2_GPIO4 ( .IO( JITT2_GPIO4 ), .I( jitt2_gpio_o[4] ), .O( jitt2_gpio_i[4] ), .T( jitt2_gpio_t[4] ) );
IOBUF  IO_JITT2_GPIO3 ( .IO( JITT2_GPIO3 ), .I( jitt2_gpio_o[3] ), .O( jitt2_gpio_i[3] ), .T( jitt2_gpio_t[3] ) );
IOBUF  IO_JITT2_GPIO2 ( .IO( JITT2_GPIO2 ), .I( jitt2_gpio_o[2] ), .O( jitt2_gpio_i[2] ), .T( jitt2_gpio_t[2] ) );
IOBUF  IO_JITT2_GPIO1 ( .IO( JITT2_GPIO1 ), .I( jitt2_gpio_o[1] ), .O( jitt2_gpio_i[1] ), .T( jitt2_gpio_t[1] ) );
IOBUF  IO_JITT2_GPIO0 ( .IO( JITT2_GPIO0 ), .I( jitt2_gpio_o[0] ), .O( jitt2_gpio_i[0] ), .T( jitt2_gpio_t[0] ) );


// -----------------------------------------------------------
// 
//    ILA to View I2C Transactions...
//
// -----------------------------------------------------------

//reg       ila_jitt_resetn_i ;
//reg       ila_jitt_resetn_o ;
//reg       ila_jitt_resetn_t ;
//reg [5:0] ila_jitt1_gpio_i  ;
//reg [5:0] ila_jitt1_gpio_o  ;
//reg [5:0] ila_jitt1_gpio_t  ;
//reg [5:0] ila_jitt2_gpio_i  ;
//reg [5:0] ila_jitt2_gpio_o  ;
//reg [5:0] ila_jitt2_gpio_t  ;
//
//always@(posedge sys_if_clk)
//begin
//    ila_jitt_resetn_i <= jitt_resetn_i ;
//    ila_jitt_resetn_o <= jitt_resetn_o ;
//    ila_jitt_resetn_t <= jitt_resetn_t ;
//    ila_jitt1_gpio_i  <= jitt1_gpio_i  ;
//    ila_jitt1_gpio_o  <= jitt1_gpio_o  ;
//    ila_jitt1_gpio_t  <= jitt1_gpio_t  ;
//    ila_jitt2_gpio_i  <= jitt2_gpio_i  ;
//    ila_jitt2_gpio_o  <= jitt2_gpio_o  ;
//    ila_jitt2_gpio_t  <= jitt2_gpio_t  ;
//end
//
//
//ila_gpio ila_gpio (
//    .clk     ( sys_if_clk     ),
//    .probe0  ( jitt_resetn_i  ),  // 1b
//    .probe1  ( jitt_resetn_o  ),  // 1b
//    .probe2  ( jitt_resetn_t  ),  // 1b
//    .probe3  ( jitt1_gpio_i   ),  // 6b
//    .probe4  ( jitt1_gpio_o   ),  // 6b
//    .probe5  ( jitt1_gpio_t   ),  // 6b
//    .probe6  ( jitt2_gpio_i   ),  // 6b
//    .probe7  ( jitt2_gpio_o   ),  // 6b
//    .probe8  ( jitt2_gpio_t   ),  // 6b
//    .probe9  ( 6'h0           )   // 6b
//);


endmodule
