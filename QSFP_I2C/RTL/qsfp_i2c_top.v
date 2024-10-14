/*
Copyright (C) 2024, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: X11
*/

//------------------------------------------------------------------------------
//
//  Description: This is a simple automated I2C controller that does the bare 
//               minumum to power up the QSFP modules and initialize the QSFP 
//               sideband signal. It also includes a simple AXI interface to 
//               provide monitoring or control left up to the user's 
//               requirements.
//
//------------------------------------------------------------------------------

module qsfp_i2c_top #(
    parameter   USE_JTAG_AXI   = "true",
    parameter   SIMULATION     = "false",
    parameter   AXI_ADDR_WIDTH = 32, 
    parameter   AXI_DATA_WIDTH = 32
) (
    input  wire     clk_ddr_lvds_300_p ,
    input  wire     clk_ddr_lvds_300_n ,
                    
    output wire     fpga_mux_rstn      , 
    //output wire     fpga_mux1_rstn     , // 3524 Only
    output wire     qsfpdd1_io_reset_b , 
    output wire     qsfpdd2_io_reset_b , 
    //output wire     qsfpdd3_io_reset_b , // 3524 Only
    //output wire     qsfpdd4_io_reset_b , // 3524 Only
                    
    inout  wire     fpga_sda_r         ,
    inout  wire     fpga_scl_r
);
 
 
localparam AXI_ADDR_WIDTH_0 = 9;
localparam AXI_DATA_WIDTH_0 = 32;

 
// -----------------------------------------------------------
// 
//    I2C Component Resets....
//
// -----------------------------------------------------------

// Go ahead and keep the resets disabled....
assign fpga_mux_rstn      = 1'b1; // IO_RESETB_WDATA[0];
//assign fpga_mux1_rstn     = 1'b1;
assign qsfpdd1_io_reset_b = 1'b1; // IO_RESETB_WDATA[2];
assign qsfpdd2_io_reset_b = 1'b1; // IO_RESETB_WDATA[3];
//assign qsfpdd2_io_reset_b = 1'b1; 
//assign qsfpdd3_io_reset_b = 1'b1; 
wire   I2C_RESETB         = 1'b1; // IO_RESETB_WDATA[6];


// -----------------------------------------------------------
// 
//    System Clock....
//
// -----------------------------------------------------------

wire    s_axi_aclk     ;
wire    s_axi_aresetn  ;

clk_wiz_0 clk_wiz_0 
(
    .clk_in1_p  ( clk_ddr_lvds_300_p ),
    .clk_in1_n  ( clk_ddr_lvds_300_n ),
    .clk_out1   ( s_axi_aclk         ),
    .locked     ( s_axi_aresetn      )
);


// -----------------------------------------------------------
// 
//    JTAG AXI Interface....
//
// -----------------------------------------------------------

wire                           jtag_axil_aclk    = s_axi_aclk;
wire                           jtag_axil_aresetn = s_axi_aresetn;

wire [AXI_ADDR_WIDTH-1:0]      jtag_axil_araddr  ;
wire                           jtag_axil_arvalid ;
wire                           jtag_axil_arready ;
                                                
wire [AXI_ADDR_WIDTH-1:0]      jtag_axil_awaddr  ;
wire                           jtag_axil_awvalid ;
wire                           jtag_axil_awready ;
                                                
wire                           jtag_axil_bready  ;
wire [1:0]                     jtag_axil_bresp   ;
wire                           jtag_axil_bvalid  ;
                                                
wire                           jtag_axil_rready  ;
wire [AXI_DATA_WIDTH-1:0]      jtag_axil_rdata   ;
wire [1:0]                     jtag_axil_rresp   ;
wire                           jtag_axil_rvalid  ;
                                                
wire [AXI_DATA_WIDTH-1:0]      jtag_axil_wdata   ;
wire [AXI_DATA_WIDTH/8-1:0]    jtag_axil_wstrb   ;
wire                           jtag_axil_wvalid  ;
wire                           jtag_axil_wready  ;
 
wire                           dbg_sda_i         ;
wire                           dbg_scl_i         ;

wire                           IO_CONTROL_PULSE  ;
wire [0:0]                     IO_CONTROL_RW     ;
wire [7:0]                     IO_CONTROL_ID     ;
wire [7:0]                     IO_ADDR_ADDR      ;
wire [7:0]                     IO_WDATA_WDATA    ;
wire [7:0]                     IO_RDATA_RDATA    ;
wire                           IO_CONTROL_CMPLT  ;
wire [6:0]                     IO_RESETB_WDATA   ;

 
generate
if (USE_JTAG_AXI == "true" ) begin
// -----------------------------------------------------------
// 
//    JTAG AXI I/F....
//
// -----------------------------------------------------------

jtag_axi_0 jtag_axi_0 (
    .aclk           ( jtag_axil_aclk    ),    
    .aresetn        ( jtag_axil_aresetn ),    
    .m_axi_awaddr   ( jtag_axil_awaddr  ),
    .m_axi_awprot   (                   ),
    .m_axi_awvalid  ( jtag_axil_awvalid ),
    .m_axi_awready  ( jtag_axil_awready ),
    .m_axi_wdata    ( jtag_axil_wdata   ),
    .m_axi_wstrb    ( jtag_axil_wstrb   ),
    .m_axi_wvalid   ( jtag_axil_wvalid  ),
    .m_axi_wready   ( jtag_axil_wready  ),
    .m_axi_bresp    ( jtag_axil_bresp   ),
    .m_axi_bvalid   ( jtag_axil_bvalid  ),
    .m_axi_bready   ( jtag_axil_bready  ),
    .m_axi_araddr   ( jtag_axil_araddr  ),
    .m_axi_arprot   (                   ),
    .m_axi_arvalid  ( jtag_axil_arvalid ),
    .m_axi_arready  ( jtag_axil_arready ),
    .m_axi_rdata    ( jtag_axil_rdata   ),
    .m_axi_rresp    ( jtag_axil_rresp   ),
    .m_axi_rvalid   ( jtag_axil_rvalid  ),
    .m_axi_rready   ( jtag_axil_rready  )
);


reg_qsfp_i2c_top reg_qsfp_i2c_top(
    .aclk             ( jtag_axil_aclk    ),
    .aresetn          ( jtag_axil_aresetn ),
    .m_axi_awaddr     ( jtag_axil_awaddr  ),
    .m_axi_awprot     ( 'h0               ),
    .m_axi_awvalid    ( jtag_axil_awvalid ),
    .m_axi_awready    ( jtag_axil_awready ),
    .m_axi_wdata      ( jtag_axil_wdata   ),
    .m_axi_wstrb      ( jtag_axil_wstrb   ),
    .m_axi_wvalid     ( jtag_axil_wvalid  ),
    .m_axi_wready     ( jtag_axil_wready  ),
    .m_axi_bresp      ( jtag_axil_bresp   ),
    .m_axi_bvalid     ( jtag_axil_bvalid  ),
    .m_axi_bready     ( jtag_axil_bready  ),
    .m_axi_araddr     ( jtag_axil_araddr  ),
    .m_axi_arprot     ( 'h0               ),
    .m_axi_arvalid    ( jtag_axil_arvalid ),
    .m_axi_arready    ( jtag_axil_arready ),
    .m_axi_rdata      ( jtag_axil_rdata   ),
    .m_axi_rresp      ( jtag_axil_rresp   ),
    .m_axi_rvalid     ( jtag_axil_rvalid  ),
    .m_axi_rready     ( jtag_axil_rready  ),

    .IO_CONTROL_PULSE ( IO_CONTROL_PULSE  ),
    .IO_CONTROL_RW    ( IO_CONTROL_RW     ),
    .IO_CONTROL_ID    ( IO_CONTROL_ID     ),
    .IO_ADDR_ADDR     ( IO_ADDR_ADDR      ),
    .IO_WDATA_WDATA   ( IO_WDATA_WDATA    ),
    .IO_RDATA_RDATA   ( IO_RDATA_RDATA    ),
    .IO_CONTROL_CMPLT ( IO_CONTROL_CMPLT  ),
    .IO_RESETB_WDATA  ( IO_RESETB_WDATA   )
);

end else begin

// -----------------------------------------------------------
// 
//    Automated State Machine....
//
// -----------------------------------------------------------

state_machine_top #(
    .SIMULATION ( SIMULATION )
) state_machine_top (
    .clk              ( s_axi_aclk       ),
    .rst              ( ~s_axi_aresetn   ),
    
    .dbg_sda_i        ( dbg_sda_i        ),
    .dbg_scl_i        ( dbg_scl_i        ),

    .IO_CONTROL_PULSE ( IO_CONTROL_PULSE ),
    .IO_CONTROL_RW    ( IO_CONTROL_RW    ),
    .IO_CONTROL_ID    ( IO_CONTROL_ID    ),
    .IO_ADDR_ADDR     ( IO_ADDR_ADDR     ),
    .IO_WDATA_WDATA   ( IO_WDATA_WDATA   ),
    .IO_RDATA_RDATA   ( IO_RDATA_RDATA   ),
    .IO_CONTROL_CMPLT ( IO_CONTROL_CMPLT )
);

end
endgenerate


// -----------------------------------------------------------
// 
//    I2C AXI Sequencer....
//
// -----------------------------------------------------------

// AXI Sequencer Register Interface... 
wire                           seq_axi_wr_req ; // pulse 
wire                           seq_axi_rd_req ; // pulse 
wire [AXI_ADDR_WIDTH_0-1:0]    seq_axi_addr   ; // valid on wr/rd req pulse
wire [AXI_DATA_WIDTH_0-1:0]    seq_axi_wdata  ; // valid on wr/rd req pulse
wire [AXI_DATA_WIDTH_0/8-1:0]  seq_axi_wstrb  ; // valid on wr/rd req pulse
wire                           seq_axi_ack    ; // pulse upon completion
wire [AXI_DATA_WIDTH_0-1:0]    seq_axi_rdata  ; // valid on op_ack pulse


// Seq->I2C AXI Interface...
wire [AXI_ADDR_WIDTH_0-1:0]    m_axi_araddr   ;
wire                           m_axi_arvalid  ;
wire                           m_axi_arready  ;

wire [AXI_ADDR_WIDTH_0-1:0]    m_axi_awaddr   ;
wire                           m_axi_awvalid  ;
wire                           m_axi_awready  ;

wire                           m_axi_bready   ;
wire [1:0]                     m_axi_bresp    ;
wire                           m_axi_bvalid   ;

wire                           m_axi_rready   ;
wire [AXI_DATA_WIDTH_0-1:0]    m_axi_rdata    ;
wire [1:0]                     m_axi_rresp    ;
wire                           m_axi_rvalid   ;

wire [AXI_DATA_WIDTH_0-1:0]    m_axi_wdata    ;
wire [AXI_DATA_WIDTH_0/8-1:0]  m_axi_wstrb    ;
wire                           m_axi_wvalid   ;
wire                           m_axi_wready   ;
    
    
i2c_axi_sequencer  #(
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH_0 ), 
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH_0 )
) i2c_axi_sequencer (
    .aclk             ( s_axi_aclk       ),
    .aresetn          ( s_axi_aresetn    ),

    .IO_CONTROL_PULSE ( IO_CONTROL_PULSE ),
    .IO_CONTROL_RW    ( IO_CONTROL_RW    ),
    .IO_CONTROL_ID    ( IO_CONTROL_ID    ),
    .IO_ADDR_ADDR     ( IO_ADDR_ADDR     ),
    .IO_WDATA_WDATA   ( IO_WDATA_WDATA   ),
    .IO_RDATA_RDATA   ( IO_RDATA_RDATA   ),
    .IO_CONTROL_CMPLT ( IO_CONTROL_CMPLT ),

    .seq_axi_wr_req   ( seq_axi_wr_req   ),
    .seq_axi_rd_req   ( seq_axi_rd_req   ),
    .seq_axi_addr     ( seq_axi_addr     ),
    .seq_axi_wdata    ( seq_axi_wdata    ),
    .seq_axi_ack      ( seq_axi_ack      ),
    .seq_axi_rdata    ( seq_axi_rdata    )      
);                                     

assign seq_axi_wstrb = {AXI_DATA_WIDTH_0/8 {1'b1} };

   
// -----------------------------------------------------------
// 
//    AXI I/F Driver....
//
// -----------------------------------------------------------

axi_master  #(
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH_0 ), 
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH_0 )
) axi_master_0 (
    .m_axi_aclk     ( s_axi_aclk      ),
    .m_axi_aresetn  ( s_axi_aresetn   ),
                                         
    // Simple TG Interface...
    .wr_req         ( seq_axi_wr_req  ), 
    .rd_req         ( seq_axi_rd_req  ), 
    .addr           ( seq_axi_addr    ), 
    .wdata          ( seq_axi_wdata   ), 
    .wstrb          ( seq_axi_wstrb   ), 
    .op_ack         ( seq_axi_ack     ), 
    .rdata          ( seq_axi_rdata   ), 
    
    // AXI Master Interface...
    .m_axi_araddr   ( m_axi_araddr    ),
    .m_axi_arvalid  ( m_axi_arvalid   ),
    .m_axi_arready  ( m_axi_arready   ),
                                      
    .m_axi_awaddr   ( m_axi_awaddr    ),
    .m_axi_awvalid  ( m_axi_awvalid   ),
    .m_axi_awready  ( m_axi_awready   ),
                                      
    .m_axi_bready   ( m_axi_bready    ),
    .m_axi_bresp    ( m_axi_bresp     ),
    .m_axi_bvalid   ( m_axi_bvalid    ),
                                      
    .m_axi_rready   ( m_axi_rready    ),
    .m_axi_rdata    ( m_axi_rdata     ),
    .m_axi_rresp    ( m_axi_rresp     ),
    .m_axi_rvalid   ( m_axi_rvalid    ),
                                      
    .m_axi_wdata    ( m_axi_wdata     ),
    .m_axi_wstrb    ( m_axi_wstrb     ),
    .m_axi_wvalid   ( m_axi_wvalid    ),
    .m_axi_wready   ( m_axi_wready    )
);
 
 
 
// -----------------------------------------------------------
// 
//    I2C Controller IP....
//
// -----------------------------------------------------------

wire sda_i ;
wire sda_o ;
wire sda_t ;
wire scl_i ;
wire scl_o ;
wire scl_t ;

axi_iic_0 axi_iic_0 (
    .s_axi_aclk      ( s_axi_aclk       ),
    
    .s_axi_aresetn   ( s_axi_aresetn & I2C_RESETB),
    .s_axi_awaddr    ( m_axi_awaddr     ),
    .s_axi_awvalid   ( m_axi_awvalid    ),
    .s_axi_awready   ( m_axi_awready    ),
    .s_axi_wdata     ( m_axi_wdata      ),
    .s_axi_wstrb     ( m_axi_wstrb      ),
    .s_axi_wvalid    ( m_axi_wvalid     ),
    .s_axi_wready    ( m_axi_wready     ),
    .s_axi_bresp     ( m_axi_bresp      ),
    .s_axi_bvalid    ( m_axi_bvalid     ),
    .s_axi_bready    ( m_axi_bready     ),
    .s_axi_araddr    ( m_axi_araddr     ),
    .s_axi_arvalid   ( m_axi_arvalid    ),
    .s_axi_arready   ( m_axi_arready    ),
    .s_axi_rdata     ( m_axi_rdata      ),
    .s_axi_rresp     ( m_axi_rresp      ),
    .s_axi_rvalid    ( m_axi_rvalid     ),
    .s_axi_rready    ( m_axi_rready     ),
    
    .sda_i           ( sda_i            ),
    .sda_o           ( sda_o            ),
    .sda_t           ( sda_t            ),
    .scl_i           ( scl_i            ),
    .scl_o           ( scl_o            ),
    .scl_t           ( scl_t            ),
    .iic2intc_irpt   (                  ),
    .gpo             (                  )
  );                                   


IOBUF IOBUF_SDA( .IO(fpga_sda_r), .I(sda_o), .O(sda_i), .T(sda_t));
IOBUF IOBUF_SCL( .IO(fpga_scl_r), .I(scl_o), .O(scl_i), .T(scl_t));


// -----------------------------------------------------------
// 
//    ILA to View I2C Transactions...
//
// -----------------------------------------------------------


ila_0 ila_0 (
    .clk     ( s_axi_aclk       ),
    .probe0  ( sda_o            ), // 1b
    .probe1  ( sda_i            ), // 1b
    .probe2  ( sda_t            ), // 1b
    .probe3  ( scl_o            ), // 1b
    .probe4  ( scl_i            ), // 1b
    .probe5  ( scl_t            ), // 1b
    .probe6  ( IO_CONTROL_PULSE ), // 1b
    .probe7  ( IO_CONTROL_CMPLT ), // 1b
    .probe8  ( IO_CONTROL_ID    ), // 8b
    .probe9  ( IO_ADDR_ADDR     )  // 8b
);

assign dbg_sda_i = sda_i;
assign dbg_scl_i = scl_i;


endmodule

