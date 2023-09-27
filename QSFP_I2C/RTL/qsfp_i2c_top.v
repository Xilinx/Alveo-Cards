/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
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
    parameter   USE_JTAG_AXI   = "false",
    parameter   SIMULATION     = "false",
    parameter   AXI_ADDR_WIDTH = 32, 
    parameter   AXI_DATA_WIDTH = 32
) (
    input  wire                          CLK13_LVDS_300_P,
    input  wire                          CLK13_LVDS_300_N,
    
    output wire                          FPGA_MUX0_RSTN , 
    output wire                          FPGA_MUX1_RSTN , 
    output wire                          QSFPDD0_IO_RESET_B , 
    output wire                          QSFPDD1_IO_RESET_B , 
    output wire                          QSFPDD2_IO_RESET_B , 
    output wire                          QSFPDD3_IO_RESET_B , 
    
    inout  wire                          FPGA_SDA_R ,
    inout  wire                          FPGA_SCL_R

);
 
 
localparam AXI_ADDR_WIDTH_0 = 9;
localparam AXI_DATA_WIDTH_0 = 32;

 
// -----------------------------------------------------------
// 
//    I2C Component Resets....
//
// -----------------------------------------------------------

// Go ahead and keep the resets disabled....
assign FPGA_MUX0_RSTN     = 1'b1; // IO_RESETB_WDATA[0];
assign FPGA_MUX1_RSTN     = 1'b1; // IO_RESETB_WDATA[1];
assign QSFPDD0_IO_RESET_B = 1'b1; // IO_RESETB_WDATA[2];
assign QSFPDD1_IO_RESET_B = 1'b1; // IO_RESETB_WDATA[3];
assign QSFPDD2_IO_RESET_B = 1'b1; // IO_RESETB_WDATA[4];
assign QSFPDD3_IO_RESET_B = 1'b1; // IO_RESETB_WDATA[5];
wire   I2C_RESETB         = 1'b1; // IO_RESETB_WDATA[6];


// -----------------------------------------------------------
// 
//    System Clock....
//
// -----------------------------------------------------------

wire                          s_axi_aclk     ;
wire                          s_axi_aresetn  ;

clk_wiz_0 clk_wiz_0 
 (
    .clk_in1_p  ( CLK13_LVDS_300_P ),
    .clk_in1_n  ( CLK13_LVDS_300_N ),
    .clk_out1   ( s_axi_aclk       ),
    .locked     ( s_axi_aresetn    )
 );


wire                           IO_CONTROL_PULSE ;
wire [0:0]                     IO_CONTROL_RW    ;
wire [7:0]                     IO_CONTROL_ID    ;
wire [7:0]                     IO_ADDR_ADDR     ;
wire [7:0]                     IO_WDATA_WDATA   ;
wire [7:0]                     IO_RDATA_RDATA   ;
wire                           IO_CONTROL_CMPLT ;
wire [6:0]                     IO_RESETB_WDATA  ;


wire [AXI_ADDR_WIDTH-1:0]      s_axi_araddr     ;
wire                           s_axi_arvalid    ;
wire                           s_axi_arready    ;
                                                
wire [AXI_ADDR_WIDTH-1:0]      s_axi_awaddr     ;
wire                           s_axi_awvalid    ;
wire                           s_axi_awready    ;
                                                
wire                           s_axi_bready     ;
wire [1:0]                     s_axi_bresp      ;
wire                           s_axi_bvalid     ;
                                                
wire                           s_axi_rready     ;
wire [AXI_DATA_WIDTH-1:0]      s_axi_rdata      ;
wire [1:0]                     s_axi_rresp      ;
wire                           s_axi_rvalid     ;
                                                
wire [AXI_DATA_WIDTH-1:0]      s_axi_wdata      ;
wire [AXI_DATA_WIDTH/8-1:0]    s_axi_wstrb      ;
wire                           s_axi_wvalid     ;
wire                           s_axi_wready     ;
 
wire                           dbg_sda_i        ;
wire                           dbg_scl_i        ;

 
generate
if (USE_JTAG_AXI == "true" ) begin
// -----------------------------------------------------------
// 
//    JTAG AXI I/F....
//
// -----------------------------------------------------------

jtag_axi_0 jtag_axi_0 (
    .aclk           ( s_axi_aclk    ),    
    .aresetn        ( s_axi_aresetn ),    
    .m_axi_awaddr   ( s_axi_awaddr  ),
    .m_axi_awprot   (               ),
    .m_axi_awvalid  ( s_axi_awvalid ),
    .m_axi_awready  ( s_axi_awready ),
    .m_axi_wdata    ( s_axi_wdata   ),
    .m_axi_wstrb    ( s_axi_wstrb   ),
    .m_axi_wvalid   ( s_axi_wvalid  ),
    .m_axi_wready   ( s_axi_wready  ),
    .m_axi_bresp    ( s_axi_bresp   ),
    .m_axi_bvalid   ( s_axi_bvalid  ),
    .m_axi_bready   ( s_axi_bready  ),
    .m_axi_araddr   ( s_axi_araddr  ),
    .m_axi_arprot   (               ),
    .m_axi_arvalid  ( s_axi_arvalid ),
    .m_axi_arready  ( s_axi_arready ),
    .m_axi_rdata    ( s_axi_rdata   ),
    .m_axi_rresp    ( s_axi_rresp   ),
    .m_axi_rvalid   ( s_axi_rvalid  ),
    .m_axi_rready   ( s_axi_rready  )
);


reg_qsfp_i2c_top reg_qsfp_i2c_top(
    .aclk             ( s_axi_aclk       ),
    .aresetn          ( s_axi_aresetn    ),
    .m_axi_awaddr     ( s_axi_awaddr     ),
    .m_axi_awprot     ( 'h0              ),
    .m_axi_awvalid    ( s_axi_awvalid    ),
    .m_axi_awready    ( s_axi_awready    ),
    .m_axi_wdata      ( s_axi_wdata      ),
    .m_axi_wstrb      ( s_axi_wstrb      ),
    .m_axi_wvalid     ( s_axi_wvalid     ),
    .m_axi_wready     ( s_axi_wready     ),
    .m_axi_bresp      ( s_axi_bresp      ),
    .m_axi_bvalid     ( s_axi_bvalid     ),
    .m_axi_bready     ( s_axi_bready     ),
    .m_axi_araddr     ( s_axi_araddr     ),
    .m_axi_arprot     ( 'h0              ),
    .m_axi_arvalid    ( s_axi_arvalid    ),
    .m_axi_arready    ( s_axi_arready    ),
    .m_axi_rdata      ( s_axi_rdata      ),
    .m_axi_rresp      ( s_axi_rresp      ),
    .m_axi_rvalid     ( s_axi_rvalid     ),
    .m_axi_rready     ( s_axi_rready     ),

    .IO_CONTROL_PULSE ( IO_CONTROL_PULSE ),
    .IO_CONTROL_RW    ( IO_CONTROL_RW    ),
    .IO_CONTROL_ID    ( IO_CONTROL_ID    ),
    .IO_ADDR_ADDR     ( IO_ADDR_ADDR     ),
    .IO_WDATA_WDATA   ( IO_WDATA_WDATA   ),
    .IO_RDATA_RDATA   ( IO_RDATA_RDATA   ),
    .IO_CONTROL_CMPLT ( IO_CONTROL_CMPLT ),
    .IO_RESETB_WDATA  ( IO_RESETB_WDATA  )
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
    .aclk             ( s_axi_aclk      ),
    .aresetn          ( s_axi_aresetn   ),

    .IO_CONTROL_PULSE ( IO_CONTROL_PULSE ),
    .IO_CONTROL_RW    ( IO_CONTROL_RW   ),
    .IO_CONTROL_ID    ( IO_CONTROL_ID   ),
    .IO_ADDR_ADDR     ( IO_ADDR_ADDR    ),
    .IO_WDATA_WDATA   ( IO_WDATA_WDATA  ),
    .IO_RDATA_RDATA   ( IO_RDATA_RDATA  ),
    .IO_CONTROL_CMPLT ( IO_CONTROL_CMPLT ),

    .seq_axi_wr_req   ( seq_axi_wr_req      ),
    .seq_axi_rd_req   ( seq_axi_rd_req      ),
    .seq_axi_addr     ( seq_axi_addr        ),
    .seq_axi_wdata    ( seq_axi_wdata       ),
    .seq_axi_ack      ( seq_axi_ack         ),
    .seq_axi_rdata    ( seq_axi_rdata       )      
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
    .wr_req         ( seq_axi_wr_req      ), 
    .rd_req         ( seq_axi_rd_req      ), 
    .addr           ( seq_axi_addr        ), 
    .wdata          ( seq_axi_wdata       ), 
    .wstrb          ( seq_axi_wstrb       ), 
    .op_ack         ( seq_axi_ack         ), 
    .rdata          ( seq_axi_rdata       ), 
    
    // AXI Master Interface...
    .m_axi_araddr   ( m_axi_araddr      ),
    .m_axi_arvalid  ( m_axi_arvalid     ),
    .m_axi_arready  ( m_axi_arready     ),
                                        
    .m_axi_awaddr   ( m_axi_awaddr      ),
    .m_axi_awvalid  ( m_axi_awvalid     ),
    .m_axi_awready  ( m_axi_awready     ),
                                        
    .m_axi_bready   ( m_axi_bready      ),
    .m_axi_bresp    ( m_axi_bresp       ),
    .m_axi_bvalid   ( m_axi_bvalid      ),
                                        
    .m_axi_rready   ( m_axi_rready      ),
    .m_axi_rdata    ( m_axi_rdata       ),
    .m_axi_rresp    ( m_axi_rresp       ),
    .m_axi_rvalid   ( m_axi_rvalid      ),
                                        
    .m_axi_wdata    ( m_axi_wdata       ),
    .m_axi_wstrb    ( m_axi_wstrb       ),
    .m_axi_wvalid   ( m_axi_wvalid      ),
    .m_axi_wready   ( m_axi_wready      )
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


IOBUF IOBUF_SDA( .IO(FPGA_SDA_R), .I(sda_o), .O(sda_i), .T(sda_t));
IOBUF IOBUF_SCL( .IO(FPGA_SCL_R), .I(scl_o), .O(scl_i), .T(scl_t));


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

