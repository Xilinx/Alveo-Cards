/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------
//
//  Description: This is a simple automated I2C controller that does the bare 
//  minumum to power up the QSFP modules and initialize the QSFP sideband 
//  signal. It also includes a simple AXI interface to provide monitoring or 
//  control left up to the user's requirements
//
//------------------------------------------------------------------------------

module qsfp_i2c_top #(
    parameter   AXI_ADDR_WIDTH = 32, 
    parameter   AXI_DATA_WIDTH = 32
) (
    // System Interface
    input  wire        sys_if_clk         ,   
    input  wire        sys_if_rstn        ,
    input  wire        sys_if_wen         ,    
    input  wire [31:0] sys_if_addr        ,   
    input  wire [31:0] sys_if_wdata       ,  
    output wire [31:0] sys_if_rdata       , 
    
    output wire        FPGA_MUX0_RSTN     , 
    output wire        FPGA_MUX1_RSTN     , 
    output wire        QSFPDD0_IO_RESET_B , 
    output wire        QSFPDD1_IO_RESET_B , 
    output wire        QSFPDD2_IO_RESET_B , 
    output wire        QSFPDD3_IO_RESET_B , 
    
    inout  wire        FPGA_SDA_R         ,
    inout  wire        FPGA_SCL_R

);
 
localparam AXI_ADDR_WIDTH_0 = 9;
localparam AXI_DATA_WIDTH_0 = 32;

 
// ======================================================================
//                          0123456789abcdef
localparam HEADER_STRING = "QSFP I2C Rev 1.1";

wire [31:0] IO_HEADER0_VALUE  = HEADER_STRING[8*16-1:8*12];
wire [31:0] IO_HEADER1_VALUE  = HEADER_STRING[8*12-1:8*8];
wire [31:0] IO_HEADER2_VALUE  = HEADER_STRING[8*8-1:8*4];
wire [31:0] IO_HEADER3_VALUE  = HEADER_STRING[8*4-1:8*0];


// -----------------------------------------------------------
// 
//    Automated State Machine....
//
// -----------------------------------------------------------

wire [0:0]  IO_CONTROL_RESETN_TOP     ; // output 
wire [0:0]  IO_CONTROL_RESETN_I2C     ; // output 
wire [0:0]  IO_CONTROL_RESETN_MUX0    ; // output 
wire [0:0]  IO_CONTROL_RESETN_MUX1    ; // output 
wire [0:0]  IO_CONTROL_RESETN_QSFP_0  ; // output 
wire [0:0]  IO_CONTROL_RESETN_QSFP_1  ; // output 
wire [0:0]  IO_CONTROL_RESETN_QSFP_2  ; // output 
wire [0:0]  IO_CONTROL_RESETN_QSFP_3  ; // output 

wire [31:0] IO_STATUS_VALUE           ; // input  
wire [7:0]  IO_STATUS_TOP_CSTATE      ; // input  
wire [7:0]  IO_STATUS_PWR_CSTATE      ; // input  
wire [7:0]  IO_STATUS_P0_CSTATE       ; // input  
wire [0:0]  IO_STATUS_P0_INSERTED     ; // input  
wire [7:0]  IO_STATUS_P1_CSTATE       ; // input  
wire [0:0]  IO_STATUS_P1_INSERTED     ; // input  
wire [7:0]  IO_STATUS_P2_CSTATE       ; // input  
wire [0:0]  IO_STATUS_P2_INSERTED     ; // input  
wire [7:0]  IO_STATUS_P3_CSTATE       ; // input  
wire [0:0]  IO_STATUS_P3_INSERTED     ; // input  


qsfp_i2c_regs qsfp_i2c_regs (
    // System Register Interface...
    .sys_if_clk                ( sys_if_clk                   ),
    .sys_if_rstn               ( sys_if_rstn                  ),
    .sys_if_wen                ( sys_if_wen                   ),
    .sys_if_addr               ( sys_if_addr                  ),
    .sys_if_wdata              ( sys_if_wdata                 ),
    .sys_if_rdata              ( sys_if_rdata                 ),

    // Internal Module Signals...
    .IO_HEADER0_VALUE          ( IO_HEADER0_VALUE             ),
    .IO_HEADER1_VALUE          ( IO_HEADER1_VALUE             ),
    .IO_HEADER2_VALUE          ( IO_HEADER2_VALUE             ),
    .IO_HEADER3_VALUE          ( IO_HEADER3_VALUE             ),

    .IO_CONTROL_RESETN_TOP     ( IO_CONTROL_RESETN_TOP        ),
    .IO_CONTROL_RESETN_I2C     ( IO_CONTROL_RESETN_I2C        ),
    .IO_CONTROL_RESETN_MUX0    ( IO_CONTROL_RESETN_MUX0       ),
    .IO_CONTROL_RESETN_MUX1    ( IO_CONTROL_RESETN_MUX1       ),
    .IO_CONTROL_RESETN_QSFP_0  ( IO_CONTROL_RESETN_QSFP_0     ),
    .IO_CONTROL_RESETN_QSFP_1  ( IO_CONTROL_RESETN_QSFP_1     ),
    .IO_CONTROL_RESETN_QSFP_2  ( IO_CONTROL_RESETN_QSFP_2     ),
    .IO_CONTROL_RESETN_QSFP_3  ( IO_CONTROL_RESETN_QSFP_3     ),
    
    .IO_STATUS_VALUE           ( IO_STATUS_VALUE              ),
    .IO_STATUS_TOP_CSTATE      ( IO_STATUS_TOP_CSTATE         ),
    .IO_STATUS_PWR_CSTATE      ( IO_STATUS_PWR_CSTATE         ),
    .IO_STATUS_P0_CSTATE       ( IO_STATUS_P0_CSTATE          ),
    .IO_STATUS_P0_INSERTED     ( IO_STATUS_P0_INSERTED        ),
    .IO_STATUS_P1_CSTATE       ( IO_STATUS_P1_CSTATE          ),
    .IO_STATUS_P1_INSERTED     ( IO_STATUS_P1_INSERTED        ),
    .IO_STATUS_P2_CSTATE       ( IO_STATUS_P2_CSTATE          ),
    .IO_STATUS_P2_INSERTED     ( IO_STATUS_P2_INSERTED        ),
    .IO_STATUS_P3_CSTATE       ( IO_STATUS_P3_CSTATE          ),
    .IO_STATUS_P3_INSERTED     ( IO_STATUS_P3_INSERTED        )
);


wire sys_if_rstn_0;
syncer_level syncer_level (
    .clk     ( sys_if_clk            ),
    .resetn  ( sys_if_rstn           ),
    .datain  ( IO_CONTROL_RESETN_TOP ),
    .dataout ( sys_if_rstn_0         )
);

wire sys_if_rstn_1 = sys_if_rstn_0 & sys_if_rstn;


// -----------------------------------------------------------
// 
//    Automated State Machine....
//
// -----------------------------------------------------------

wire        IO_CONTROL_PULSE ;
wire [0:0]  IO_CONTROL_RW    ;
wire [7:0]  IO_CONTROL_ID    ;
wire [7:0]  IO_ADDR_ADDR     ;
wire [7:0]  IO_WDATA_WDATA   ;
wire [7:0]  IO_RDATA_RDATA   ;
wire        IO_CONTROL_CMPLT ;
//wire [6:0]  IO_RESETB_WDATA  = 6'h7F;


wire dbg_sda_i;
wire dbg_scl_i;


qsfp_state_machine_top qsfp_state_machine_top (
    .clk               ( sys_if_clk            ),
    .rst               ( ~sys_if_rstn_1        ),
                                               
    .dbg_sda_i         ( dbg_sda_i             ),
    .dbg_scl_i         ( dbg_scl_i             ),
                                               
    .IO_CONTROL_PULSE  ( IO_CONTROL_PULSE      ),
    .IO_CONTROL_RW     ( IO_CONTROL_RW         ),
    .IO_CONTROL_ID     ( IO_CONTROL_ID         ),
    .IO_ADDR_ADDR      ( IO_ADDR_ADDR          ),
    .IO_WDATA_WDATA    ( IO_WDATA_WDATA        ),
    .IO_RDATA_RDATA    ( IO_RDATA_RDATA        ),
    .IO_CONTROL_CMPLT  ( IO_CONTROL_CMPLT      ),
            
    .dbg_cstate_top    ( IO_STATUS_TOP_CSTATE  ),
    .dbg_cstate_pwr    ( IO_STATUS_PWR_CSTATE  ),
    .dbg_cstate_qsfp_0 ( IO_STATUS_P0_CSTATE   ),
    .dbg_cstate_qsfp_1 ( IO_STATUS_P1_CSTATE   ),
    .dbg_cstate_qsfp_2 ( IO_STATUS_P2_CSTATE   ),
    .dbg_cstate_qsfp_3 ( IO_STATUS_P3_CSTATE   ),
    .dbg_plug_state_0  ( IO_STATUS_P0_INSERTED ),
    .dbg_plug_state_1  ( IO_STATUS_P1_INSERTED ),
    .dbg_plug_state_2  ( IO_STATUS_P2_INSERTED ),
    .dbg_plug_state_3  ( IO_STATUS_P3_INSERTED )
);

// -----------------------------------------------------------
// 
//    I2C Component Resets....
//
// -----------------------------------------------------------

// Go ahead and keep the resets disabled....
assign FPGA_MUX0_RSTN     = IO_CONTROL_RESETN_MUX0  ;
assign FPGA_MUX1_RSTN     = IO_CONTROL_RESETN_MUX1  ;
assign QSFPDD0_IO_RESET_B = IO_CONTROL_RESETN_QSFP_0;
assign QSFPDD1_IO_RESET_B = IO_CONTROL_RESETN_QSFP_1;
assign QSFPDD2_IO_RESET_B = IO_CONTROL_RESETN_QSFP_2;
assign QSFPDD3_IO_RESET_B = IO_CONTROL_RESETN_QSFP_3;
wire   I2C_RESETB         = IO_CONTROL_RESETN_I2C;


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
    
    
qsfp_i2c_axi_sequencer  #(
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH_0 ), 
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH_0 )
) qsfp_i2c_axi_sequencer (
    .aclk             ( sys_if_clk           ),
    .aresetn          ( sys_if_rstn_1        ),
                                             
    .IO_CONTROL_PULSE ( IO_CONTROL_PULSE     ),
    .IO_CONTROL_RW    ( IO_CONTROL_RW        ),
    .IO_CONTROL_ID    ( IO_CONTROL_ID        ),
    .IO_ADDR_ADDR     ( IO_ADDR_ADDR         ),
    .IO_WDATA_WDATA   ( IO_WDATA_WDATA       ),
    .IO_RDATA_RDATA   ( IO_RDATA_RDATA       ),
    .IO_CONTROL_CMPLT ( IO_CONTROL_CMPLT     ),
                                             
    .seq_axi_wr_req   ( seq_axi_wr_req       ),
    .seq_axi_rd_req   ( seq_axi_rd_req       ),
    .seq_axi_addr     ( seq_axi_addr         ),
    .seq_axi_wdata    ( seq_axi_wdata        ),
    .seq_axi_ack      ( seq_axi_ack          ),
    .seq_axi_rdata    ( seq_axi_rdata        )
);                                     

assign seq_axi_wstrb = {AXI_DATA_WIDTH_0/8 {1'b1} };

   
// -----------------------------------------------------------
// 
//    AXI I/F Driver....
//
// -----------------------------------------------------------

qsfp_axi_master  #(
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH_0 ), 
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH_0 )
) qsfp_axi_master (
    .m_axi_aclk     ( sys_if_clk        ),
    .m_axi_aresetn  ( sys_if_rstn_1     ),
                                         
    // Simple TG Interface...
    .wr_req         ( seq_axi_wr_req    ), 
    .rd_req         ( seq_axi_rd_req    ), 
    .addr           ( seq_axi_addr      ), 
    .wdata          ( seq_axi_wdata     ), 
    .wstrb          ( seq_axi_wstrb     ), 
    .op_ack         ( seq_axi_ack       ), 
    .rdata          ( seq_axi_rdata     ), 
    
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

axi_iic_qsfp axi_iic_qsfp (
    .s_axi_aclk      ( sys_if_clk       ),
    
    .s_axi_aresetn   ( sys_if_rstn_1 & I2C_RESETB),
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


//ila_0 ila_0 (
//    .clk     ( sys_if_clk       ),
//    .probe0  ( sda_o            ), // 1b
//    .probe1  ( sda_i            ), // 1b
//    .probe2  ( sda_t            ), // 1b
//    .probe3  ( scl_o            ), // 1b
//    .probe4  ( scl_i            ), // 1b
//    .probe5  ( scl_t            ), // 1b
//    .probe6  ( IO_CONTROL_PULSE ), // 1b
//    .probe7  ( IO_CONTROL_CMPLT ), // 1b
//    .probe8  ( IO_CONTROL_ID    ), // 8b
//    .probe9  ( IO_ADDR_ADDR     )  // 8b
//);

assign dbg_sda_i = sda_i;
assign dbg_scl_i = scl_i;


endmodule

