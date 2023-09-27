/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

module renesas_i2c_top #(
    parameter SIMULATION = "false"
) (
    input  wire        sys_if_clk   ,
    input  wire        sys_if_rstn  ,
    input  wire        sys_if_wen   , 
    input  wire [31:0] sys_if_addr  ,
    input  wire [31:0] sys_if_wdata ,
    output wire [31:0] sys_if_rdata , 

    output wire        i2c_clkb     ,
    output wire        i2c_web      ,
    output wire [15:0] i2c_addrb    ,
    output wire [15:0] i2c_dinb     ,
    input  wire [15:0] i2c_doutb    ,

    input  wire        sys_clk_50   ,
    input  wire        sys_rst_50   ,

    inout  wire        CLKGEN_SDA   ,
    inout  wire        CLKGEN_SCL
);
 
// ======================================================================
//                          0123456789abcdef
localparam HEADER_STRING = "JC I2C Rev 1.1  ";

wire [31:0] IO_HEADER0_VALUE  = HEADER_STRING[8*16-1:8*12];
wire [31:0] IO_HEADER1_VALUE  = HEADER_STRING[8*12-1:8*8];
wire [31:0] IO_HEADER2_VALUE  = HEADER_STRING[8*8-1:8*4];
wire [31:0] IO_HEADER3_VALUE  = HEADER_STRING[8*4-1:8*0];


// ======================================================================
//  System Register Interface

localparam AXI_ADDR_WIDTH_0 = 9;
localparam AXI_DATA_WIDTH_0 = 32;

wire [0:0]  IO_CONTROL_RESETN ;
wire [0:0]  IO_CONTROL_START  ;
wire [31:0] IO_STATUS_VALUE   ;

renesas_i2c_regs renesas_i2c_regs (
    // System Register Interface...
    .sys_if_clk        ( sys_if_clk        ),
    .sys_if_rstn       ( sys_if_rstn       ),
    .sys_if_wen        ( sys_if_wen        ),
    .sys_if_addr       ( sys_if_addr       ),
    .sys_if_wdata      ( sys_if_wdata      ),
    .sys_if_rdata      ( sys_if_rdata      ),

    // Internal Module Signals...
    .IO_HEADER0_VALUE  ( IO_HEADER0_VALUE  ),
    .IO_HEADER1_VALUE  ( IO_HEADER1_VALUE  ),
    .IO_HEADER2_VALUE  ( IO_HEADER2_VALUE  ),
    .IO_HEADER3_VALUE  ( IO_HEADER3_VALUE  ),

    .IO_CONTROL_RESETN ( IO_CONTROL_RESETN ),
    .IO_CONTROL_START  ( IO_CONTROL_START  ),
    .IO_STATUS_VALUE   ( IO_STATUS_VALUE   )
    
);

// ======================================================================

wire IO_CONTROL_START_sync;
syncer_pulse syncer_pulse (
    .clkin          ( sys_if_clk             ), 
    .clkin_resetn   ( sys_if_rstn            ), 
    .clkout         ( sys_clk_50             ), 
    .clkout_resetn  ( ~sys_rst_50            ), 

    .pulsein        ( IO_CONTROL_START       ), 
    .pulseout       ( IO_CONTROL_START_sync  ) 
);

wire s_axi_aclk    = sys_clk_50;
reg  s_axi_aresetn ;
always@(posedge s_axi_aclk)
begin
    s_axi_aresetn <= ~sys_rst_50 & IO_CONTROL_RESETN;
end

// -----------------------------------------------------------
// 
//    Clock Generation....
//       CLK IN  - 300Mhz
//       CLK OUT - 50Mhz
//
// -----------------------------------------------------------
//clk_wiz_1 clk_wiz_1 
// (
//    .clk_in1_p  ( CLK13_LVDS_300_P ),
//    .clk_in1_n  ( CLK13_LVDS_300_N ),
//    .clk_out1   ( s_axi_aclk       ),
//    .locked     ( locked           )
// );
 
// -------------------------------------------------

reg [15:0] timer_start;
always@(posedge s_axi_aclk)
begin
    if (!IO_CONTROL_RESETN)
        timer_start <= 'h0;
    else if (IO_CONTROL_START_sync == 1)
        timer_start <= 'h20;
    else if (timer_start == 0)
        timer_start <= 'h0;
    else
        timer_start <= timer_start - 1;
end

wire start_pulse = (timer_start == 'h1);

// -------------------------------------------------

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
                                      
wire  [7:0]                    xfer_count     ;
wire  [31:0]                   xfer_offset    ;
wire                           xfer_enable    ;
       
// -----------------------------------------------------------
// 
//    I2C Command Sequencer....
//
// -------------------------------------------------

wire       end_pulse ;    
wire [7:0] dbg_cstate;     

renesas_i2c_sequencer  #(
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH_0 ), 
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH_0 )
) renesas_i2c_sequencer (
    .aclk             ( s_axi_aclk      ),
    .aresetn          ( s_axi_aresetn   ),

    .start_pulse      ( start_pulse     ),
    .end_pulse        ( end_pulse       ),

    .i2c_clkb         ( i2c_clkb        ),
    .i2c_web          ( i2c_web         ),
    .i2c_addrb        ( i2c_addrb       ),
    .i2c_dinb         ( i2c_dinb        ),
    .i2c_doutb        ( i2c_doutb       ),

    .seq_axi_wr_req   ( seq_axi_wr_req  ),
    .seq_axi_rd_req   ( seq_axi_rd_req  ),
    .seq_axi_addr     ( seq_axi_addr    ),
    .seq_axi_wdata    ( seq_axi_wdata   ),
    .seq_axi_ack      ( seq_axi_ack     ),
    .seq_axi_rdata    ( seq_axi_rdata   ),

    .xfer_count       ( xfer_count      ),
    .xfer_offset      ( xfer_offset     ),
    .xfer_enable      ( xfer_enable     ),
    .dbg_cstate       ( dbg_cstate      )
);                                      

assign seq_axi_wstrb = {AXI_DATA_WIDTH_0/8 {1'b1} };

// -----------------------------------------------------------
// 
//    AXI I/F Driver....
//
// -----------------------------------------------------------

renesas_i2c_axi_master  #(
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH_0 ), 
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH_0 )
) renesas_i2c_axi_master (
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
    
    .s_axi_aresetn   ( s_axi_aresetn    ), // & I2C_RESETB),
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


IOBUF IOBUF_SDA( .IO(CLKGEN_SDA), .I(sda_o), .O(sda_i), .T(sda_t));
IOBUF IOBUF_SCL( .IO(CLKGEN_SCL), .I(scl_o), .O(scl_i), .T(scl_t));

assign IO_STATUS_VALUE[0]     = end_pulse;
assign IO_STATUS_VALUE[7:1]   = 'h0;
assign IO_STATUS_VALUE[15:8]  = dbg_cstate;
assign IO_STATUS_VALUE[31:16] = 'h0;
   

// -----------------------------------------------------------
// 
//    ILA to View I2C Transactions...
//
// -----------------------------------------------------------

//reg         ila_scl ;
//reg         ila_sda ;
//reg  [7:0]  ila_xfer_count ;
//reg  [31:0] ila_xfer_offset;
//reg         ila_xfer_enable;
//
//
//always@(posedge s_axi_aclk)
//begin
//    ila_scl         <= scl_i          ;
//    ila_sda         <= sda_i          ;
//    ila_xfer_count  <= xfer_count     ;
//    ila_xfer_offset <= xfer_offset    ;
//    ila_xfer_enable <= xfer_enable    ;
//end
//
//
//ila_i2c ila_i2c (
//    .clk     ( s_axi_aclk       ),
//    .probe0  ( ila_scl          ),  // 1b
//    .probe1  ( ila_sda          ),  // 1b
//    .probe2  ( ila_xfer_count   ),  // 8b
//    .probe3  ( ila_xfer_offset  ),  // 32b
//    .probe4  ( ila_xfer_enable  ),  // 1b
//    .probe5  ( dbg_cstate       )   // 8b
//);


endmodule

