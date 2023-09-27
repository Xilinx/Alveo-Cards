/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/
  
module ddr_i2c_top #(
    parameter   AXI_ADDR_WIDTH = 32, 
    parameter   AXI_DATA_WIDTH = 32
) (
    output wire [31:0]                   seq_status     ,
    input  wire                          s_axi_aclk     ,
    input  wire                          s_axi_aresetn  ,
    input  wire                          sys_aclk_10M   ,

    input  wire [AXI_ADDR_WIDTH-1:0]     s_axi_araddr   ,
    input  wire                          s_axi_arvalid  ,
    output wire                          s_axi_arready  ,

    input  wire [AXI_ADDR_WIDTH-1:0]     s_axi_awaddr   ,
    input  wire                          s_axi_awvalid  ,
    output wire                          s_axi_awready  ,

    input  wire                          s_axi_bready   ,
    output wire [1:0]                    s_axi_bresp    ,
    output wire                          s_axi_bvalid   ,

    input  wire                          s_axi_rready   ,
    output wire [AXI_DATA_WIDTH-1:0]     s_axi_rdata    ,
    output wire [1:0]                    s_axi_rresp    ,
    output wire                          s_axi_rvalid   ,

    input  wire [AXI_DATA_WIDTH-1:0]     s_axi_wdata    ,
    input  wire [AXI_DATA_WIDTH/8-1:0]   s_axi_wstrb    ,
    input  wire                          s_axi_wvalid   ,
    output wire                          s_axi_wready   ,

    inout  wire                          i2c_sda        ,
    inout  wire                          i2c_scl

);
 
 

localparam AXI_ADDR_WIDTH_0 = 9;
localparam AXI_DATA_WIDTH_0 = 32;


// User Register I/F Interface...
wire                           user_wr_en  ;
wire                           user_rd_en  ;
wire [AXI_ADDR_WIDTH-1:0]      user_waddr  ;
wire [AXI_ADDR_WIDTH-1:0]      user_raddr  ;
wire [AXI_DATA_WIDTH-1:0]      user_wdata  ;
wire [AXI_DATA_WIDTH/8-1:0]    user_wstrb  ;
wire [AXI_DATA_WIDTH-1:0]      user_rdata  ;
reg                            user_wr_ack ;
reg                            user_rd_ack ;

// Sequqencer Register I/F Interface...
wire                           seq_req     ;
wire                           seq_op      ;
wire  [7:0]                    seq_dev_id  ;
wire  [7:0]                    seq_addr    ;
wire  [7:0]                    seq_wdata   ;
wire                           seq_ack     ;
wire  [7:0]                    seq_rdata   ;

// AXI Sequencer Register Interface... 
wire                           seq_axi_wr_req ; // pulse 
wire                           seq_axi_rd_req ; // pulse 
wire [AXI_ADDR_WIDTH_0-1:0]    seq_axi_addr   ; // valid on wr/rd req pulse
wire [AXI_DATA_WIDTH_0-1:0]    seq_axi_wdata  ; // valid on wr/rd req pulse
wire [AXI_DATA_WIDTH_0/8-1:0]  seq_axi_wstrb  ; // valid on wr/rd req pulse
wire                           seq_axi_ack    ; // pulse upon completion
wire [AXI_DATA_WIDTH_0-1:0]    seq_axi_rdata  ; // valid on op_ack pulse

// Seq->I2C AXI Interface...
wire [AXI_ADDR_WIDTH_0-1:0]    m0_axi_araddr   ;
wire                           m0_axi_arvalid  ;
wire                           m0_axi_arready  ;

wire [AXI_ADDR_WIDTH_0-1:0]    m0_axi_awaddr   ;
wire                           m0_axi_awvalid  ;
wire                           m0_axi_awready  ;

wire                           m0_axi_bready   ;
wire [1:0]                     m0_axi_bresp    ;
wire                           m0_axi_bvalid   ;

wire                           m0_axi_rready   ;
wire [AXI_DATA_WIDTH_0-1:0]    m0_axi_rdata    ;
wire [1:0]                     m0_axi_rresp    ;
wire                           m0_axi_rvalid   ;

wire [AXI_DATA_WIDTH_0-1:0]    m0_axi_wdata    ;
wire [AXI_DATA_WIDTH_0/8-1:0]  m0_axi_wstrb    ;
wire                           m0_axi_wvalid   ;
wire                           m0_axi_wready   ;
    

// -----------------------------------------------------------
// 
//    User AXI Interface...
//
// -----------------------------------------------------------
    
axi_slave axi_slave (
    .s_axi_aclk     ( s_axi_aclk      ),
    .s_axi_aresetn  ( s_axi_aresetn   ),

    .s_axi_araddr   ( s_axi_araddr    ),
    .s_axi_arvalid  ( s_axi_arvalid   ),
    .s_axi_arready  ( s_axi_arready   ),

    .s_axi_awaddr   ( s_axi_awaddr    ),
    .s_axi_awvalid  ( s_axi_awvalid   ),
    .s_axi_awready  ( s_axi_awready   ),

    .s_axi_bready   ( s_axi_bready    ),
    .s_axi_bresp    ( s_axi_bresp     ),
    .s_axi_bvalid   ( s_axi_bvalid    ),

    .s_axi_rready   ( s_axi_rready    ),
    .s_axi_rdata    ( s_axi_rdata     ),
    .s_axi_rresp    ( s_axi_rresp     ),
    .s_axi_rvalid   ( s_axi_rvalid    ),

    .s_axi_wdata    ( s_axi_wdata     ),
    .s_axi_wstrb    ( s_axi_wstrb     ),
    .s_axi_wvalid   ( s_axi_wvalid    ),
    .s_axi_wready   ( s_axi_wready    ),

    .wr_en          ( user_wr_en      ),
    .rd_en          ( user_rd_en      ),
    .waddr          ( user_waddr      ),
    .raddr          ( user_raddr      ),
    .wdata          ( user_wdata      ),
    .wstrb          ( user_wstrb      ),
    .rdata          ( user_rdata      ),
    .wr_ack         ( user_wr_ack     ),
    .rd_ack         ( user_rd_ack     )
);
 
always@(posedge s_axi_aclk)
begin
    if (!s_axi_aresetn) 
        user_wr_ack <= 'h0;
    else
        user_wr_ack <= user_wr_en;
end

always@(posedge s_axi_aclk)
begin
    if (!s_axi_aresetn) 
        user_rd_ack <= 'h0;
    else
        user_rd_ack <= user_rd_en;
end

reg [31:0] reg_control;
always@(posedge s_axi_aclk)
begin
    if (!s_axi_aresetn) 
        reg_control <= 'h0;
    else if (user_wr_en && (user_waddr == 'h00)) 
        reg_control <= user_wdata;
end

wire [31:0] seq_status;
assign user_rdata[7:0]   = reg_control[7:0];
assign user_rdata[15:8]  = seq_status[7:0];
assign user_rdata[23:16] = seq_status[15:8];
assign user_rdata[31:24] = 'h0;

 
// -----------------------------------------------------------
// 
//    I2C Operation Sequencer....
//
// -----------------------------------------------------------

i2c_sequencer  i2c_sequencer  (
    .aclk         ( s_axi_aclk    ),
    .aresetn      ( s_axi_aresetn ),
    
    .reg_control  ( reg_control   ),
    .seq_status   ( seq_status    ),

    .seq_req      ( seq_req       ),
    .seq_op       ( seq_op        ),
    .seq_dev_id   ( seq_dev_id    ),
    .seq_addr     ( seq_addr      ),
    .seq_wdata    ( seq_wdata     ),
    .seq_ack      ( seq_ack       ),
    .seq_rdata    ( seq_rdata     )
);                                       

// -----------------------------------------------------------
// 
//    I2C AXI Sequencer....
//
// -----------------------------------------------------------

i2c_axi_sequencer  #(
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH_0 ), 
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH_0 )
) i2c_axi_sequencer (
    .aclk             ( s_axi_aclk      ),
    .aresetn          ( s_axi_aresetn   ),

    .seq_req          ( seq_req         ),
    .seq_op           ( seq_op          ),
    .seq_dev_id       ( seq_dev_id      ),
    .seq_addr         ( seq_addr        ),
    .seq_wdata        ( seq_wdata       ),
    .seq_ack          ( seq_ack         ),
    .seq_rdata        ( seq_rdata       ),

    .seq_axi_wr_req   ( seq_axi_wr_req      ),
    .seq_axi_rd_req   ( seq_axi_rd_req      ),
    .seq_axi_addr     ( seq_axi_addr        ),
    .seq_axi_wdata    ( seq_axi_wdata       ),
    .seq_axi_ack      ( seq_axi_ack         ),
    .seq_axi_rdata    ( seq_axi_rdata       )      
);                                     

assign i2c_wstrb = {AXI_DATA_WIDTH_0/8 {1'b1} };

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
    .m_axi_araddr   ( m0_axi_araddr   ),
    .m_axi_arvalid  ( m0_axi_arvalid  ),
    .m_axi_arready  ( m0_axi_arready  ),

    .m_axi_awaddr   ( m0_axi_awaddr   ),
    .m_axi_awvalid  ( m0_axi_awvalid  ),
    .m_axi_awready  ( m0_axi_awready  ),

    .m_axi_bready   ( m0_axi_bready   ),
    .m_axi_bresp    ( m0_axi_bresp    ),
    .m_axi_bvalid   ( m0_axi_bvalid   ),

    .m_axi_rready   ( m0_axi_rready   ),
    .m_axi_rdata    ( m0_axi_rdata    ),
    .m_axi_rresp    ( m0_axi_rresp    ),
    .m_axi_rvalid   ( m0_axi_rvalid   ),

    .m_axi_wdata    ( m0_axi_wdata    ),
    .m_axi_wstrb    ( m0_axi_wstrb    ),
    .m_axi_wvalid   ( m0_axi_wvalid   ),
    .m_axi_wready   ( m0_axi_wready   )
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
    .s_axi_aresetn   ( s_axi_aresetn    ),
    .s_axi_awaddr    ( m0_axi_awaddr    ),
    .s_axi_awvalid   ( m0_axi_awvalid   ),
    .s_axi_awready   ( m0_axi_awready   ),
    .s_axi_wdata     ( m0_axi_wdata     ),
    .s_axi_wstrb     ( m0_axi_wstrb     ),
    .s_axi_wvalid    ( m0_axi_wvalid    ),
    .s_axi_wready    ( m0_axi_wready    ),
    .s_axi_bresp     ( m0_axi_bresp     ),
    .s_axi_bvalid    ( m0_axi_bvalid    ),
    .s_axi_bready    ( m0_axi_bready    ),
    .s_axi_araddr    ( m0_axi_araddr    ),
    .s_axi_arvalid   ( m0_axi_arvalid   ),
    .s_axi_arready   ( m0_axi_arready   ),
    .s_axi_rdata     ( m0_axi_rdata     ),
    .s_axi_rresp     ( m0_axi_rresp     ),
    .s_axi_rvalid    ( m0_axi_rvalid    ),
    .s_axi_rready    ( m0_axi_rready    ),
    
    
    .sda_i           ( sda_i            ),
    .sda_o           ( sda_o            ),
    .sda_t           ( sda_t            ),
    .scl_i           ( scl_i            ),
    .scl_o           ( scl_o            ),
    .scl_t           ( scl_t            ),
    .iic2intc_irpt   (                  ),
    .gpo             (                  )
  );                                   


IOBUF IOBUF_SDA( .IO(i2c_sda), .I(sda_o), .O(sda_i), .T(sda_t));
IOBUF IOBUF_SCL( .IO(i2c_scl), .I(scl_o), .O(scl_i), .T(scl_t));

ila_0 ila_0 (
    .clk    ( sys_aclk_10M  ),
    .probe0 ( s_axi_aresetn ),
    .probe1 ( sda_i         ),
    .probe2 ( sda_o         ),
    .probe3 ( sda_t         ),
    .probe4 ( scl_i         ),
    .probe5 ( scl_o         ),
    .probe6 ( scl_t         ),
    .probe7 ( seq_status[7:0] )
);

endmodule

