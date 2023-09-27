/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`timescale 1 ps / 1 ps

module clk_recov #(
    parameter SIMULATION = "false",
    parameter integer NUM_CHANNEL = 4
) (
    output wire [NUM_CHANNEL-1:0] gtf_ch_gtftxn_0 ,
    output wire [NUM_CHANNEL-1:0] gtf_ch_gtftxp_0 ,
    input  wire [NUM_CHANNEL-1:0] gtf_ch_gtfrxn_0 ,
    input  wire [NUM_CHANNEL-1:0] gtf_ch_gtfrxp_0 ,

    output wire [NUM_CHANNEL-1:0] gtf_ch_gtftxn_1 ,
    output wire [NUM_CHANNEL-1:0] gtf_ch_gtftxp_1 ,
    input  wire [NUM_CHANNEL-1:0] gtf_ch_gtfrxn_1 ,
    input  wire [NUM_CHANNEL-1:0] gtf_ch_gtfrxp_1 ,

    input  wire CLK12_LVDS_300_P   ,
    input  wire CLK12_LVDS_300_N   ,
                
    // 300 Mhz Input Reference Clock
    input  wire CLK13_LVDS_300_P   ,
    input  wire CLK13_LVDS_300_N   ,
         
    // GTF Input Reference Clocks
    input  wire SYNCE_CLK10_LVDS_P ,
    input  wire SYNCE_CLK10_LVDS_N ,

    input  wire SYNCE_CLK11_LVDS_P ,
    input  wire SYNCE_CLK11_LVDS_N ,

    input  wire SYNCE_CLK12_LVDS_P ,
    input  wire SYNCE_CLK12_LVDS_N ,

    input  wire SYNCE_CLK13_LVDS_P ,
    input  wire SYNCE_CLK13_LVDS_N ,

    input  wire SYNCE_CLK14_LVDS_P ,
    input  wire SYNCE_CLK14_LVDS_N ,

    input  wire SYNCE_CLK15_LVDS_P ,
    input  wire SYNCE_CLK15_LVDS_N ,

    input  wire SYNCE_CLK16_LVDS_P ,
    input  wire SYNCE_CLK16_LVDS_N ,

    input  wire SYNCE_CLK17_LVDS_P ,
    input  wire SYNCE_CLK17_LVDS_N ,
    
    //output wire RECOV_CLK10_LVDS_P ,
    //output wire RECOV_CLK10_LVDS_N ,
    
    output wire RECOV_CLK11_LVDS_P ,
    output wire RECOV_CLK11_LVDS_N ,
    
    // Jitter Cleaner I2C I/F
    inout  wire CLKGEN_SDA         ,
    inout  wire CLKGEN_SCL         ,
                             
    // Jitter Cleaner Reset and GPIO 
    inout  wire JITT_RESETN        ,
                                   
    inout  wire JITT1_GPOI5        ,
    inout  wire JITT1_GPOI4        ,
    inout  wire JITT1_GPOI3        ,
    inout  wire JITT1_GPOI2        ,
    inout  wire JITT1_GPOI1        ,
    inout  wire JITT1_GPOI0        ,
    
    inout  wire JITT2_GPOI5        ,
    inout  wire JITT2_GPOI4        ,
    inout  wire JITT2_GPOI3        ,
    inout  wire JITT2_GPOI2        ,
    inout  wire JITT2_GPOI1        ,
    inout  wire JITT2_GPOI0        ,
    
    // QSFP I2C Peripheral Resets
    output wire FPGA_MUX0_RSTN     , 
    output wire FPGA_MUX1_RSTN     , 
    output wire QSFPDD0_IO_RESET_B , 
    output wire QSFPDD1_IO_RESET_B , 
    output wire QSFPDD2_IO_RESET_B , 
    output wire QSFPDD3_IO_RESET_B , 
                
    // QSFP I2C Interface
    inout  wire FPGA_SDA_R         ,
    inout  wire FPGA_SCL_R

);


// ---------------------------------------------------------------
//
//  50/100Mhz System Clock & Reset
//
// ---------------------------------------------------------------
wire sys_clk_100;
wire sys_rst_100;
wire sys_clk_50 ;
wire sys_rst_50 ;

clk_reset clk_reset (
    .sys_clk_300_p ( CLK13_LVDS_300_P ),
    .sys_clk_300_n ( CLK13_LVDS_300_N ),
    .sys_clk_100   ( sys_clk_100   ),
    .sys_rst_100   ( sys_rst_100   ),
    .sys_clk_50    ( sys_clk_50    ),
    .sys_rst_50    ( sys_rst_50    )
);

wire sys_if_clk  = sys_clk_100;
wire sys_if_rstn = ~sys_rst_100;

 
// -----------------------------------------------------------
// 
//  GTF Freerunning Clock
//
// -----------------------------------------------------------
wire    clk_wiz_reset = 1'b0;

wire    CLK12_LVDS_300;
wire    gtf_clk_200mhz;
wire    gtf_clk_425mhz;
wire    gtf_clk_wiz_locked;

IBUFDS ibufds_clk_freerun_inst (
  .I  ( CLK12_LVDS_300_P ),
  .IB ( CLK12_LVDS_300_N ),
  .O  ( CLK12_LVDS_300   )
);

gtfwizard_0_example_clk_wiz clk_wiz_300_to_161_inst
   (
    // Clock in ports
    .clk_in1        ( CLK12_LVDS_300     ), // input 300 Mhz clock
    // Clock out ports
    .clk_out1       ( gtf_clk_200mhz     ), // output clk_out_200MHz
    .clk_out2       ( gtf_clk_425mhz     ), // output clk_out_425Mhz
    // Status and control signals
    .locked         ( gtf_clk_wiz_locked )  // output locked
   );    

wire gtf_freerun_clk;
wire gtf_sys_clk_out;

BUFG bufg_clk_freerun_inst (
  .I ( gtf_clk_200mhz  ),
  .O ( gtf_freerun_clk )
);

BUFG bufg_clk_sys_inst (
  .I ( gtf_clk_425mhz  ),
  .O ( gtf_sys_clk_out )
);


// ---------------------------------------------------------------
//
//  JTAG/AXI Interface
//
// ---------------------------------------------------------------

wire           jtag_m_axi_aclk     = sys_if_clk  ;
wire           jtag_m_axi_aresetn  = sys_if_rstn ;
wire [31 : 0]  jtag_m_axi_awaddr   ;
wire [2 : 0]   jtag_m_axi_awprot   ;
wire           jtag_m_axi_awvalid  ;
wire           jtag_m_axi_awready  ;
wire [31 : 0]  jtag_m_axi_wdata    ;
wire [3 : 0]   jtag_m_axi_wstrb    ;
wire           jtag_m_axi_wvalid   ;
wire           jtag_m_axi_wready   ;
wire [1 : 0]   jtag_m_axi_bresp    ;
wire           jtag_m_axi_bvalid   ;
wire           jtag_m_axi_bready   ;
wire [31 : 0]  jtag_m_axi_araddr   ;
wire [2 : 0]   jtag_m_axi_arprot   ;
wire           jtag_m_axi_arvalid  ;
wire           jtag_m_axi_arready  ;
wire [31 : 0]  jtag_m_axi_rdata    ;
wire [1 : 0]   jtag_m_axi_rresp    ;
wire           jtag_m_axi_rvalid   ;
wire           jtag_m_axi_rready   ;


generate
if (SIMULATION == "false") begin
jtag_axi_0 jtag_axi_0 (
    .aclk           ( sys_if_clk         ),
    .aresetn        ( sys_if_rstn        ),
    
    .m_axi_awaddr   ( jtag_m_axi_awaddr  ),
    .m_axi_awprot   ( jtag_m_axi_awprot  ),
    .m_axi_awvalid  ( jtag_m_axi_awvalid ),
    .m_axi_awready  ( jtag_m_axi_awready ),
    .m_axi_wdata    ( jtag_m_axi_wdata   ),
    .m_axi_wstrb    ( jtag_m_axi_wstrb   ),
    .m_axi_wvalid   ( jtag_m_axi_wvalid  ),
    .m_axi_wready   ( jtag_m_axi_wready  ),
    .m_axi_bresp    ( jtag_m_axi_bresp   ),
    .m_axi_bvalid   ( jtag_m_axi_bvalid  ),
    .m_axi_bready   ( jtag_m_axi_bready  ),
    .m_axi_araddr   ( jtag_m_axi_araddr  ),
    .m_axi_arprot   ( jtag_m_axi_arprot  ),
    .m_axi_arvalid  ( jtag_m_axi_arvalid ),
    .m_axi_arready  ( jtag_m_axi_arready ),
    .m_axi_rdata    ( jtag_m_axi_rdata   ),
    .m_axi_rresp    ( jtag_m_axi_rresp   ),
    .m_axi_rvalid   ( jtag_m_axi_rvalid  ),
    .m_axi_rready   ( jtag_m_axi_rready  )
);
end
endgenerate
  
    
// ---------------------------------------------------------------
//
//  System AXI Interconnect
//
// ---------------------------------------------------------------

wire         M_AXI_0_aclk     ;
wire         M_AXI_0_aresetn  ;
wire [31:0]  M_AXI_0_araddr   ;
wire [2:0]   M_AXI_0_arprot   ;
wire         M_AXI_0_arready  ;
wire         M_AXI_0_arvalid  ;
wire [31:0]  M_AXI_0_awaddr   ;
wire [2:0]   M_AXI_0_awprot   ;
wire         M_AXI_0_awready  ;
wire         M_AXI_0_awvalid  ;
wire         M_AXI_0_bready   ;
wire [1:0]   M_AXI_0_bresp    ;
wire         M_AXI_0_bvalid   ;
wire [31:0]  M_AXI_0_rdata    ;
wire         M_AXI_0_rready   ;
wire [1:0]   M_AXI_0_rresp    ;
wire         M_AXI_0_rvalid   ;
wire [31:0]  M_AXI_0_wdata    ;
wire         M_AXI_0_wready   ;
wire [3:0]   M_AXI_0_wstrb    ;
wire         M_AXI_0_wvalid   ;

wire         M_AXI_1_aclk     ;
wire         M_AXI_1_aresetn  ;
wire [31:0]  M_AXI_1_araddr   ;
wire [2:0]   M_AXI_1_arprot   ;
wire         M_AXI_1_arready  ;
wire         M_AXI_1_arvalid  ;
wire [31:0]  M_AXI_1_awaddr   ;
wire [2:0]   M_AXI_1_awprot   ;
wire         M_AXI_1_awready  ;
wire         M_AXI_1_awvalid  ;
wire         M_AXI_1_bready   ;
wire [1:0]   M_AXI_1_bresp    ;
wire         M_AXI_1_bvalid   ;
wire [31:0]  M_AXI_1_rdata    ;
wire         M_AXI_1_rready   ;
wire [1:0]   M_AXI_1_rresp    ;
wire         M_AXI_1_rvalid   ;
wire [31:0]  M_AXI_1_wdata    ;
wire         M_AXI_1_wready   ;
wire [3:0]   M_AXI_1_wstrb    ;
wire         M_AXI_1_wvalid   ;
  
wire         M_AXI_2_aclk     ;
wire         M_AXI_2_aresetn  ;
wire [31:0]  M_AXI_2_araddr   ;
wire [2:0]   M_AXI_2_arprot   ;
wire         M_AXI_2_arready  ;
wire         M_AXI_2_arvalid  ;
wire [31:0]  M_AXI_2_awaddr   ;
wire [2:0]   M_AXI_2_awprot   ;
wire         M_AXI_2_awready  ;
wire         M_AXI_2_awvalid  ;
wire         M_AXI_2_bready   ;
wire [1:0]   M_AXI_2_bresp    ;
wire         M_AXI_2_bvalid   ;
wire [31:0]  M_AXI_2_rdata    ;
wire         M_AXI_2_rready   ;
wire [1:0]   M_AXI_2_rresp    ;
wire         M_AXI_2_rvalid   ;
wire [31:0]  M_AXI_2_wdata    ;
wire         M_AXI_2_wready   ;
wire [3:0]   M_AXI_2_wstrb    ;
wire         M_AXI_2_wvalid   ;
  
design_1 design_1 (
    .aclk_0           ( sys_if_clk          ),
    .aresetn_0        ( sys_if_rstn         ),
    
    .S_AXI_0_araddr   ( jtag_m_axi_araddr   ),
    .S_AXI_0_arprot   ( jtag_m_axi_arprot   ),
    .S_AXI_0_arready  ( jtag_m_axi_arready  ),
    .S_AXI_0_arvalid  ( jtag_m_axi_arvalid  ),
    .S_AXI_0_awaddr   ( jtag_m_axi_awaddr   ),
    .S_AXI_0_awprot   ( jtag_m_axi_awprot   ),
    .S_AXI_0_awready  ( jtag_m_axi_awready  ),
    .S_AXI_0_awvalid  ( jtag_m_axi_awvalid  ),
    .S_AXI_0_bready   ( jtag_m_axi_bready   ),
    .S_AXI_0_bresp    ( jtag_m_axi_bresp    ),
    .S_AXI_0_bvalid   ( jtag_m_axi_bvalid   ),
    .S_AXI_0_rdata    ( jtag_m_axi_rdata    ),
    .S_AXI_0_rready   ( jtag_m_axi_rready   ),
    .S_AXI_0_rresp    ( jtag_m_axi_rresp    ),
    .S_AXI_0_rvalid   ( jtag_m_axi_rvalid   ),
    .S_AXI_0_wdata    ( jtag_m_axi_wdata    ),
    .S_AXI_0_wready   ( jtag_m_axi_wready   ),
    .S_AXI_0_wstrb    ( jtag_m_axi_wstrb    ),
    .S_AXI_0_wvalid   ( jtag_m_axi_wvalid   ),
                        
    // System Peripheral Interface
    .M_AXI_0_aclk     ( sys_if_clk          ),
    .M_AXI_0_aresetn  ( sys_if_rstn         ),
    .M_AXI_0_araddr   ( M_AXI_0_araddr      ),
    .M_AXI_0_arprot   ( M_AXI_0_arprot      ),
    .M_AXI_0_arready  ( M_AXI_0_arready     ),
    .M_AXI_0_arvalid  ( M_AXI_0_arvalid     ),
    .M_AXI_0_awaddr   ( M_AXI_0_awaddr      ),
    .M_AXI_0_awprot   ( M_AXI_0_awprot      ),
    .M_AXI_0_awready  ( M_AXI_0_awready     ),
    .M_AXI_0_awvalid  ( M_AXI_0_awvalid     ),
    .M_AXI_0_bready   ( M_AXI_0_bready      ),
    .M_AXI_0_bresp    ( M_AXI_0_bresp       ),
    .M_AXI_0_bvalid   ( M_AXI_0_bvalid      ),
    .M_AXI_0_rdata    ( M_AXI_0_rdata       ),
    .M_AXI_0_rready   ( M_AXI_0_rready      ),
    .M_AXI_0_rresp    ( M_AXI_0_rresp       ),
    .M_AXI_0_rvalid   ( M_AXI_0_rvalid      ),
    .M_AXI_0_wdata    ( M_AXI_0_wdata       ),
    .M_AXI_0_wready   ( M_AXI_0_wready      ),
    .M_AXI_0_wstrb    ( M_AXI_0_wstrb       ),
    .M_AXI_0_wvalid   ( M_AXI_0_wvalid      ),

    // GTF Interface
    .M_AXI_1_aclk     ( M_AXI_1_aclk        ),
    .M_AXI_1_aresetn  ( M_AXI_1_aresetn     ),
    .M_AXI_1_araddr   ( M_AXI_1_araddr      ),
    .M_AXI_1_arprot   ( M_AXI_1_arprot      ),
    .M_AXI_1_arready  ( M_AXI_1_arready     ),
    .M_AXI_1_arvalid  ( M_AXI_1_arvalid     ),
    .M_AXI_1_awaddr   ( M_AXI_1_awaddr      ),
    .M_AXI_1_awprot   ( M_AXI_1_awprot      ),
    .M_AXI_1_awready  ( M_AXI_1_awready     ),
    .M_AXI_1_awvalid  ( M_AXI_1_awvalid     ),
    .M_AXI_1_bready   ( M_AXI_1_bready      ),
    .M_AXI_1_bresp    ( M_AXI_1_bresp       ),
    .M_AXI_1_bvalid   ( M_AXI_1_bvalid      ),
    .M_AXI_1_rdata    ( M_AXI_1_rdata       ),
    .M_AXI_1_rready   ( M_AXI_1_rready      ),
    .M_AXI_1_rresp    ( M_AXI_1_rresp       ),
    .M_AXI_1_rvalid   ( M_AXI_1_rvalid      ),
    .M_AXI_1_wdata    ( M_AXI_1_wdata       ),
    .M_AXI_1_wready   ( M_AXI_1_wready      ),
    .M_AXI_1_wstrb    ( M_AXI_1_wstrb       ),
    .M_AXI_1_wvalid   ( M_AXI_1_wvalid      ),

    // GTF Interface
    .M_AXI_2_aclk     ( M_AXI_2_aclk        ),
    .M_AXI_2_aresetn  ( M_AXI_2_aresetn     ),
    .M_AXI_2_araddr   ( M_AXI_2_araddr      ),
    .M_AXI_2_arprot   ( M_AXI_2_arprot      ),
    .M_AXI_2_arready  ( M_AXI_2_arready     ),
    .M_AXI_2_arvalid  ( M_AXI_2_arvalid     ),
    .M_AXI_2_awaddr   ( M_AXI_2_awaddr      ),
    .M_AXI_2_awprot   ( M_AXI_2_awprot      ),
    .M_AXI_2_awready  ( M_AXI_2_awready     ),
    .M_AXI_2_awvalid  ( M_AXI_2_awvalid     ),
    .M_AXI_2_bready   ( M_AXI_2_bready      ),
    .M_AXI_2_bresp    ( M_AXI_2_bresp       ),
    .M_AXI_2_bvalid   ( M_AXI_2_bvalid      ),
    .M_AXI_2_rdata    ( M_AXI_2_rdata       ),
    .M_AXI_2_rready   ( M_AXI_2_rready      ),
    .M_AXI_2_rresp    ( M_AXI_2_rresp       ),
    .M_AXI_2_rvalid   ( M_AXI_2_rvalid      ),
    .M_AXI_2_wdata    ( M_AXI_2_wdata       ),
    .M_AXI_2_wready   ( M_AXI_2_wready      ),
    .M_AXI_2_wstrb    ( M_AXI_2_wstrb       ),
    .M_AXI_2_wvalid   ( M_AXI_2_wvalid      )
);


// ---------------------------------------------------------------
//
//  System PIF
//
// ---------------------------------------------------------------

wire        sys_if_wen   ;    
wire [31:0] sys_if_addr  ;   
wire [31:0] sys_if_wdata ;  
wire [31:0] sys_if_rdata ; 

reg_axi_slave reg_axi_slave(
    .s_axi_aclk     ( sys_if_clk        ),
    .s_axi_aresetn  ( sys_if_rstn       ),

    .s_axi_awaddr   ( M_AXI_0_awaddr    ),
    .s_axi_awvalid  ( M_AXI_0_awvalid   ),
    .s_axi_awready  ( M_AXI_0_awready   ),
    .s_axi_wdata    ( M_AXI_0_wdata     ),
    .s_axi_wstrb    ( M_AXI_0_wstrb     ),
    .s_axi_wvalid   ( M_AXI_0_wvalid    ),
    .s_axi_wready   ( M_AXI_0_wready    ),
    .s_axi_bresp    ( M_AXI_0_bresp     ),
    .s_axi_bvalid   ( M_AXI_0_bvalid    ),
    .s_axi_bready   ( M_AXI_0_bready    ),

    .s_axi_araddr   ( M_AXI_0_araddr    ),
    .s_axi_arvalid  ( M_AXI_0_arvalid   ),
    .s_axi_arready  ( M_AXI_0_arready   ),
    .s_axi_rdata    ( M_AXI_0_rdata     ),
    .s_axi_rresp    ( M_AXI_0_rresp     ),
    .s_axi_rvalid   ( M_AXI_0_rvalid    ),
    .s_axi_rready   ( M_AXI_0_rready    ),

    .wr_en          ( sys_if_wen        ),
    .addr           ( sys_if_addr       ),
    .wdata          ( sys_if_wdata      ),
    .wstrb          (                   ),
    .rdata          ( sys_if_rdata      )
);


// ---------------------------------------------------------------
//
//  Mux System Write Enable and Read Data
//
// ---------------------------------------------------------------

wire [31:0] sys_if_addr_0  = {16'h0000, sys_if_addr[15:0]};

wire        sys_if_wen_0   ;     
wire [31:0] sys_if_rdata_0 ;

wire        sys_if_wen_1   ;     
wire [31:0] sys_if_rdata_1 ;

wire        sys_if_wen_2   ;     
wire [31:0] sys_if_rdata_2 ;

wire        sys_if_wen_3   ;     
wire [31:0] sys_if_rdata_3 ;

wire        sys_if_wen_4   ;     
wire [31:0] sys_if_rdata_4 ;

wire        sys_if_wen_5   ;     
wire [31:0] sys_if_rdata_5 ;

wire        sys_if_wen_6   ;     
wire [31:0] sys_if_rdata_6 = 'h0;

wire        sys_if_wen_7   ;     
wire [31:0] sys_if_rdata_7 = 'h0;


sys_if_switch sys_if_switch (
    // System Interface
    .sys_if_wen     ( sys_if_wen     ),
    .sys_if_addr    ( sys_if_addr    ),
    .sys_if_rdata   ( sys_if_rdata   ),

    // Input clock to be sampled....
    .sys_if_wen_0   ( sys_if_wen_0   ),  
    .sys_if_rdata_0 ( sys_if_rdata_0 ),

    .sys_if_wen_1   ( sys_if_wen_1   ),  
    .sys_if_rdata_1 ( sys_if_rdata_1 ),

    .sys_if_wen_2   ( sys_if_wen_2   ),  
    .sys_if_rdata_2 ( sys_if_rdata_2 ),

    .sys_if_wen_3   ( sys_if_wen_3   ),  
    .sys_if_rdata_3 ( sys_if_rdata_3 ),

    .sys_if_wen_4   ( sys_if_wen_4   ),  
    .sys_if_rdata_4 ( sys_if_rdata_4 ),

    .sys_if_wen_5   ( sys_if_wen_5   ),  
    .sys_if_rdata_5 ( sys_if_rdata_5 ),

    .sys_if_wen_6   ( sys_if_wen_6   ),  
    .sys_if_rdata_6 ( sys_if_rdata_6 ),

    .sys_if_wen_7   ( sys_if_wen_7   ),  
    .sys_if_rdata_7 ( sys_if_rdata_7 )
);


// ---------------------------------------------------------------
//
//  System Registers
//
// ---------------------------------------------------------------

// ======================================================================
//                          0123456789abcdef
localparam HEADER_STRING = "Clk Recov 1.1   ";

wire [31:0] IO_HEADER0_VALUE  = HEADER_STRING[8*16-1:8*12];
wire [31:0] IO_HEADER1_VALUE  = HEADER_STRING[8*12-1:8*8];
wire [31:0] IO_HEADER2_VALUE  = HEADER_STRING[8*8-1:8*4];
wire [31:0] IO_HEADER3_VALUE  = HEADER_STRING[8*4-1:8*0];

// ======================================================================
//  System Register Interface

wire [31:0] IO_SCRATCH_VALUE;
system_regs #(
    .NUM_CHANNEL ( NUM_CHANNEL )
) system_regs (
    // System Register Interface...
    .sys_if_clk    ( sys_if_clk     ),
    .sys_if_rstn   ( sys_if_rstn    ),
    .sys_if_wen    ( sys_if_wen_0   ),
    .sys_if_addr   ( sys_if_addr_0  ),
    .sys_if_wdata  ( sys_if_wdata   ),
    .sys_if_rdata  ( sys_if_rdata_0 ),

    // Internal Module Signals...
    .IO_HEADER0_VALUE ( IO_HEADER0_VALUE ),
    .IO_HEADER1_VALUE ( IO_HEADER1_VALUE ),
    .IO_HEADER2_VALUE ( IO_HEADER2_VALUE ),
    .IO_HEADER3_VALUE ( IO_HEADER3_VALUE ),
    .IO_SCRATCH_VALUE ( IO_SCRATCH_VALUE )
);


// ---------------------------------------------------------------
//
//  GTF SYNCE_CLK Buffering
//
// ---------------------------------------------------------------
// These two clocks use IBUFDS in their respective blocks, don't buffer here...
//     SYNCE_CLK11_LVDS_P/N -> GTF 0 (MAC)
//     SYNCE_CLK16_LVDS_P/N -> GTF 1 (RAW)

wire [7:0] SYNCE_CLK_OUT ;

system_gtf_clk_buffer #(
    .CLK_BUS_WIDTH ( 6 )
) system_gtf_clk_buffer (
    .SYNCE_CLK_LVDS_P ( { SYNCE_CLK17_LVDS_P,
                          SYNCE_CLK15_LVDS_P,
                          SYNCE_CLK14_LVDS_P,
                          SYNCE_CLK13_LVDS_P,
                          SYNCE_CLK12_LVDS_P,
                          SYNCE_CLK10_LVDS_P } ),
    .SYNCE_CLK_LVDS_N ( { SYNCE_CLK17_LVDS_N,
                          SYNCE_CLK15_LVDS_N,
                          SYNCE_CLK14_LVDS_N,
                          SYNCE_CLK13_LVDS_N,
                          SYNCE_CLK12_LVDS_N,
                          SYNCE_CLK10_LVDS_N } ),
    .SYNCE_CLK_OUT    ( SYNCE_CLK_OUT          )
);

wire SYNCE_CLK17_OUT = SYNCE_CLK_OUT[5];
wire SYNCE_CLK16_OUT ;
wire SYNCE_CLK15_OUT = SYNCE_CLK_OUT[4];
wire SYNCE_CLK14_OUT = SYNCE_CLK_OUT[3];
wire SYNCE_CLK13_OUT = SYNCE_CLK_OUT[2];
wire SYNCE_CLK12_OUT = SYNCE_CLK_OUT[1];
wire SYNCE_CLK11_OUT ;
wire SYNCE_CLK10_OUT = SYNCE_CLK_OUT[0];


// ---------------------------------------------------------------
//
//  Frequency Counter and Clock Source
//
// ---------------------------------------------------------------

freq_counter_top freq_counter_top (
    // System Interface
    .sys_if_clk    ( sys_if_clk         ),
    .sys_if_rstn   ( sys_if_rstn        ),
    .sys_if_wen    ( sys_if_wen_1       ),
    .sys_if_addr   ( sys_if_addr_0      ),
    .sys_if_wdata  ( sys_if_wdata       ),
    .sys_if_rdata  ( sys_if_rdata_1     ),
    // Clock to be sampled....
    .clk_samp_7    ( SYNCE_CLK17_OUT    ),
    .clk_samp_6    ( SYNCE_CLK16_OUT    ),
    .clk_samp_5    ( SYNCE_CLK15_OUT    ),
    .clk_samp_4    ( SYNCE_CLK14_OUT    ),
    .clk_samp_3    ( SYNCE_CLK13_OUT    ),
    .clk_samp_2    ( SYNCE_CLK12_OUT    ),
    .clk_samp_1    ( SYNCE_CLK11_OUT    ),
    .clk_samp_0    ( SYNCE_CLK10_OUT    )
);


// ---------------------------------------------------------------
//
//  Renesas GPIO and Reset 
//
// ---------------------------------------------------------------

renesas_gpio renesas_gpio (
    // System Interface
    .sys_if_clk    ( sys_if_clk     ),
    .sys_if_rstn   ( sys_if_rstn    ),
    .sys_if_wen    ( sys_if_wen_2   ),
    .sys_if_addr   ( sys_if_addr_0  ),
    .sys_if_wdata  ( sys_if_wdata   ),
    .sys_if_rdata  ( sys_if_rdata_2 ),

    // Input clock to be sampled....
    .JITT1_RESETn ( JITT_RESETN     ),

    .JITT1_GPIO5  ( JITT1_GPOI5     ),
    .JITT1_GPIO4  ( JITT1_GPOI4     ),
    .JITT1_GPIO3  ( JITT1_GPOI3     ),
    .JITT1_GPIO2  ( JITT1_GPOI2     ),
    .JITT1_GPIO1  ( JITT1_GPOI1     ),
    .JITT1_GPIO0  ( JITT1_GPOI0     ),

    .JITT2_GPIO5  ( JITT2_GPOI5     ),
    .JITT2_GPIO4  ( JITT2_GPOI4     ),
    .JITT2_GPIO3  ( JITT2_GPOI3     ),
    .JITT2_GPIO2  ( JITT2_GPOI2     ),
    .JITT2_GPIO1  ( JITT2_GPOI1     ),
    .JITT2_GPIO0  ( JITT2_GPOI0     )
);

// ---------------------------------------------------------------
//
//  Renesas BRAM 
//
// ---------------------------------------------------------------
wire        i2c_clkb   ;
wire        i2c_web    ;
wire [15:0] i2c_addrb  ;
wire [15:0] i2c_dinb   ;
wire [15:0] i2c_doutb  ;   


renesas_bram renesas_bram (
    // System Interface
    .sys_if_clk    ( sys_if_clk     ),
    .sys_if_rstn   ( sys_if_rstn    ),
    .sys_if_wen    ( sys_if_wen_3   ),
    .sys_if_addr   ( sys_if_addr_0  ),
    .sys_if_wdata  ( sys_if_wdata   ),
    .sys_if_rdata  ( sys_if_rdata_3 ),

    .i2c_clkb      ( i2c_clkb       ),
    .i2c_web       ( i2c_web        ),
    .i2c_addrb     ( i2c_addrb      ),
    .i2c_dinb      ( i2c_dinb       ),
    .i2c_doutb     ( i2c_doutb      )
);




// ---------------------------------------------------------------
//
//  Renesas BRAM 
//
// ---------------------------------------------------------------

renesas_i2c_top renesas_i2c_top (
    // System Interface
    .sys_if_clk    ( sys_if_clk     ),
    .sys_if_rstn   ( sys_if_rstn    ),
    .sys_if_wen    ( sys_if_wen_4   ),
    .sys_if_addr   ( sys_if_addr_0  ),
    .sys_if_wdata  ( sys_if_wdata   ),
    .sys_if_rdata  ( sys_if_rdata_4 ),

    .i2c_clkb      ( i2c_clkb       ),
    .i2c_web       ( i2c_web        ),
    .i2c_addrb     ( i2c_addrb      ),
    .i2c_dinb      ( i2c_dinb       ),
    .i2c_doutb     ( i2c_doutb      ),

    .sys_clk_50    ( sys_clk_50     ),
    .sys_rst_50    ( sys_rst_50     ),

    .CLKGEN_SDA    ( CLKGEN_SDA     ),
    .CLKGEN_SCL    ( CLKGEN_SCL     )

);


// ---------------------------------------------------------------
//
//  QSFP I2C Controller
//
// ---------------------------------------------------------------

qsfp_i2c_top qsfp_i2c_top (
    // System Interface
    .sys_if_clk         ( sys_if_clk           ),
    .sys_if_rstn        ( sys_if_rstn          ),
    .sys_if_wen         ( sys_if_wen_5         ),
    .sys_if_addr        ( sys_if_addr_0        ),
    .sys_if_wdata       ( sys_if_wdata         ),
    .sys_if_rdata       ( sys_if_rdata_5       ),

    .FPGA_MUX0_RSTN     ( FPGA_MUX0_RSTN       ),
    .FPGA_MUX1_RSTN     ( FPGA_MUX1_RSTN       ),
    .QSFPDD0_IO_RESET_B ( QSFPDD0_IO_RESET_B   ),
    .QSFPDD1_IO_RESET_B ( QSFPDD1_IO_RESET_B   ),
    .QSFPDD2_IO_RESET_B ( QSFPDD2_IO_RESET_B   ),
    .QSFPDD3_IO_RESET_B ( QSFPDD3_IO_RESET_B   ),

    .FPGA_SDA_R         ( FPGA_SDA_R           ),
    .FPGA_SCL_R         ( FPGA_SCL_R           )
);


// -----------------------------------------------------------
// 
//  GTF Port 0
//
// -----------------------------------------------------------

wire SYNCE_CLK11_INT;
wire RECOV_CLK10_INT;

gtf_top_0 #( 
    .NUM_CHANNEL  ( NUM_CHANNEL  )
) gtf_top_0 (
    .gtf_ch_gtftxn      ( gtf_ch_gtftxn_0      ),
    .gtf_ch_gtftxp      ( gtf_ch_gtftxp_0      ),
    .gtf_ch_gtfrxn      ( gtf_ch_gtfrxn_0      ),
    .gtf_ch_gtfrxp      ( gtf_ch_gtfrxp_0      ),

    // Input differential SYNCE clock
    .SYNCE_CLK_LVDS_P   ( SYNCE_CLK11_LVDS_P   ),
    .SYNCE_CLK_LVDS_N   ( SYNCE_CLK11_LVDS_N   ),
    // Single ended SYNCE clock for freq measurement
    .SYNCE_CLK_OUT      ( SYNCE_CLK11_INT      ),

    // Freerunning 200Mhz, 425Mhz system clock and reset
    .gtf_freerun_clk    ( gtf_freerun_clk      ),
    .gtf_sys_clk_out    ( gtf_sys_clk_out      ),
    .gtf_clk_wiz_locked ( gtf_clk_wiz_locked   ),

    // Freerunning 100Mhz system clock and reset
    .sys_if_clk         ( sys_if_clk           ),   
    .sys_if_rstn        ( sys_if_rstn          ),
    
    // User GTF Reset...
    .sys_gtf_resetn     ( IO_SCRATCH_VALUE[0]  ),

    // JTAG/AXI Interface
    .s_axil_aclk        ( M_AXI_1_aclk         ),
    .s_axil_aresetn     ( M_AXI_1_aresetn      ),
    .s_axil_awaddr      ( M_AXI_1_awaddr & 32'h000F_FFFF ),
    .s_axil_awprot      ( M_AXI_1_awprot       ),
    .s_axil_awvalid     ( M_AXI_1_awvalid      ),
    .s_axil_awready     ( M_AXI_1_awready      ),
    .s_axil_wdata       ( M_AXI_1_wdata        ),
    .s_axil_wstrb       ( M_AXI_1_wstrb        ),
    .s_axil_wvalid      ( M_AXI_1_wvalid       ),
    .s_axil_wready      ( M_AXI_1_wready       ),
    .s_axil_bresp       ( M_AXI_1_bresp        ),
    .s_axil_bvalid      ( M_AXI_1_bvalid       ),
    .s_axil_bready      ( M_AXI_1_bready       ),
    .s_axil_araddr      ( M_AXI_1_araddr & 32'h000F_FFFF ),
    .s_axil_arprot      ( M_AXI_1_arprot       ),
    .s_axil_arvalid     ( M_AXI_1_arvalid      ),
    .s_axil_arready     ( M_AXI_1_arready      ),
    .s_axil_rdata       ( M_AXI_1_rdata        ),
    .s_axil_rresp       ( M_AXI_1_rresp        ),
    .s_axil_rvalid      ( M_AXI_1_rvalid       ),
    .s_axil_rready      ( M_AXI_1_rready       ),

    // Differential RECOV clock to I/O if desired
    .RECOV_CLK10_INT    ( RECOV_CLK10_INT      ),
    .RECOV_CLK10_LVDS_P ( RECOV_CLK11_LVDS_P   ),
    .RECOV_CLK10_LVDS_N ( RECOV_CLK11_LVDS_N   ),

    // User reset to loopback fifo
    .fifo_rst           ( IO_SCRATCH_VALUE[1]  ),
    
    .ctl_hwchk_frm_gen_en_in ( IO_SCRATCH_VALUE[8]  ),
    .ctl_hwchk_mon_en_in     ( IO_SCRATCH_VALUE[9]  )      
);                                            

// BUFG to move SYNCE clock onto fabric for frequency measurement
BUFG_GT BUFG_GT_INST_11 (
    .CE         ( 1'b1             ),
    .CEMASK     ( 1'b0             ),
    .CLR        ( 1'b0             ),
    .CLRMASK    ( 1'b0             ),
    .DIV        ( 3'b0             ),
    .I          ( SYNCE_CLK11_INT  ),
    .O          ( SYNCE_CLK11_OUT  )
);


// -----------------------------------------------------------
// 
//  GTF Port 1
//
// -----------------------------------------------------------

wire SYNCE_CLK16_INT;

gtf_top_1 #( 
    .NUM_CHANNEL  ( NUM_CHANNEL  )
) gtf_top_1 (
    .gtf_ch_gtftxn      ( gtf_ch_gtftxn_1      ),
    .gtf_ch_gtftxp      ( gtf_ch_gtftxp_1      ),
    .gtf_ch_gtfrxn      ( gtf_ch_gtfrxn_1      ),
    .gtf_ch_gtfrxp      ( gtf_ch_gtfrxp_1      ),

    // Input differential SYNCE clock
    .SYNCE_CLK_LVDS_P   ( SYNCE_CLK16_LVDS_P   ),
    .SYNCE_CLK_LVDS_N   ( SYNCE_CLK16_LVDS_N   ),
    // Single ended SYNCE clock for freq measurement
    .SYNCE_CLK_OUT      ( SYNCE_CLK16_INT      ),

    // Freerunning 200Mhz, 425Mhz system clock and reset
    .gtf_freerun_clk    ( gtf_freerun_clk      ),
    .gtf_sys_clk_out    ( gtf_sys_clk_out      ),
    .gtf_clk_wiz_locked ( gtf_clk_wiz_locked   ),

    // Freerunning 100Mhz system clock and reset
    .sys_if_clk         ( sys_if_clk           ),   
    .sys_if_rstn        ( sys_if_rstn          ),

    // User GTF Reset...
    .sys_gtf_resetn     ( IO_SCRATCH_VALUE[0]  ),

    // JTAG/AXI Interface
    .s_axil_aclk        ( M_AXI_2_aclk         ),
    .s_axil_aresetn     ( M_AXI_2_aresetn      ),
    .s_axil_awaddr      ( M_AXI_2_awaddr & 32'h000F_FFFF ),
    .s_axil_awprot      ( M_AXI_2_awprot       ),
    .s_axil_awvalid     ( M_AXI_2_awvalid      ),
    .s_axil_awready     ( M_AXI_2_awready      ),
    .s_axil_wdata       ( M_AXI_2_wdata        ),
    .s_axil_wstrb       ( M_AXI_2_wstrb        ),
    .s_axil_wvalid      ( M_AXI_2_wvalid       ),
    .s_axil_wready      ( M_AXI_2_wready       ),
    .s_axil_bresp       ( M_AXI_2_bresp        ),
    .s_axil_bvalid      ( M_AXI_2_bvalid       ),
    .s_axil_bready      ( M_AXI_2_bready       ),
    .s_axil_araddr      ( M_AXI_2_araddr & 32'h000F_FFFF ),
    .s_axil_arprot      ( M_AXI_2_arprot       ),
    .s_axil_arvalid     ( M_AXI_2_arvalid      ),
    .s_axil_arready     ( M_AXI_2_arready      ),
    .s_axil_rdata       ( M_AXI_2_rdata        ),
    .s_axil_rresp       ( M_AXI_2_rresp        ),
    .s_axil_rvalid      ( M_AXI_2_rvalid       ),
    .s_axil_rready      ( M_AXI_2_rready       )

    // Differential SYNCE clock to I/O if desired
    //.RECOV_CLK10_INT    ( ), // RECOV_CLK10_INT      ),
    //.RECOV_CLK10_LVDS_P ( ), // RECOV_CLK10_LVDS_P   ),
    //.RECOV_CLK10_LVDS_N ( ), // RECOV_CLK10_LVDS_N   )

);                                            


// BUFG to move SYNCE clock onto fabric for frequency measurement
BUFG_GT BUFG_GT_INST_16 (
    .CE         ( 1'b1             ),
    .CEMASK     ( 1'b0             ),
    .CLR        ( 1'b0             ),
    .CLRMASK    ( 1'b0             ),
    .DIV        ( 3'b0             ),
    .I          ( SYNCE_CLK16_INT  ),
    .O          ( SYNCE_CLK16_OUT  )
);

endmodule
