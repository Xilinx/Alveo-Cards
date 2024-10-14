/*
(c) Copyright 2019-2022 Xilinx, Inc. All rights reserved.
(c) Copyright 2022-2024 Advanced Micro Devices, Inc. All rights reserved.
This file contains confidential and proprietary information
of Xilinx, Inc. and is protected under U.S. and
international copyright and other intellectual property
laws.
DISCLAIMER
This disclaimer is not a license and does not grant any
rights to the materials distributed herewith. Except as
otherwise provided in a valid license issued to you by
Xilinx, and to the maximum extent permitted by applicable
law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
(2) Xilinx shall not be liable (whether in contract or tort,
including negligence, or under any other theory of
liability) for any loss or damage of any kind or nature
related to, arising under or in connection with these
materials, including for any direct, or any indirect,
special, incidental, or consequential loss or damage
(including loss of data, profits, goodwill, or any type of
loss or damage suffered as a result of any action brought
by a third party) even if such damage or loss was
reasonably foreseeable or Xilinx had been advised of the
possibility of the same.
CRITICAL APPLICATIONS
Xilinx proddcts are not designed or intended to be fail-
safe, or for use in any application requiring fail-safe
performance, such as life-support or safety devices or
systems, Class III medical devices, nuclear facilities,
applications related to the deployment of airbags, or any
other applications that could lead to death, personal
injury, or severe property or environmental damage
(individually and collectively, "Critical
Applications"). Customer assumes the sole risk and
liability of any use of Xilinx proddcts in Critical
Applications, subject only to applicable laws and
regulations governing limitations on proddct liability.
THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
PART OF THIS FILE AT ALL TIMES.

*/


module renesas_i2c_top #(
    parameter SIMULATION = "false"
) (
    input  wire     clk_sys_lvds_300_p,
    input  wire     clk_sys_lvds_300_n,
                    
    inout  wire     clkgen_sda_r ,
    inout  wire     clkgen_scl_r
);
 
localparam AXI_ADDR_WIDTH_0 = 9;
localparam AXI_DATA_WIDTH_0 = 32;


wire s_axi_aclk     ;
wire s_axi_aresetn  ;

// -----------------------------------------------------------
// 
//    Clock Generation....
//       CLK IN  - 300Mhz
//       CLK OUT - 50Mhz
//
// -----------------------------------------------------------
clk_wiz_0 clk_wiz_0 
 (
    .clk_in1_p  ( clk_sys_lvds_300_p ),
    .clk_in1_n  ( clk_sys_lvds_300_n ),
    .clk_out1   ( s_axi_aclk       ),
    .locked     ( s_axi_aresetn    )
 );
 
// -----------------------------------------------------------
// 
//    I2C AXI Sequencer....
//
// -----------------------------------------------------------

wire vio_rstn;
reg  vio_rstn_r;
generate
if (SIMULATION == "false") begin
    vio_0 vio_0
    (
        .clk        ( s_axi_aclk    ),
        .probe_out0 ( vio_rstn      )
    );
end else begin
    assign vio_rstn = vio_rstn_r;
end
endgenerate

// -------------------------------------------------

reg [15:0] timer_start;
always@(posedge s_axi_aclk)
begin
    if (!vio_rstn)
        timer_start <= 'h2000;
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

i2c_sequencer  #(
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH_0 ), 
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH_0 )
) i2c_sequencer (
    .aclk             ( s_axi_aclk      ),
    .aresetn          ( s_axi_aresetn   ),

    .start_pulse      ( start_pulse     ),

    .seq_axi_wr_req   ( seq_axi_wr_req  ),
    .seq_axi_rd_req   ( seq_axi_rd_req  ),
    .seq_axi_addr     ( seq_axi_addr    ),
    .seq_axi_wdata    ( seq_axi_wdata   ),
    .seq_axi_ack      ( seq_axi_ack     ),
    .seq_axi_rdata    ( seq_axi_rdata   ),      

    .xfer_count       ( xfer_count      ),
    .xfer_offset      ( xfer_offset     ),
    .xfer_enable      ( xfer_enable     )
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


IOBUF IOBUF_SDA( .IO(clkgen_sda_r), .I(sda_o), .O(sda_i), .T(sda_t));
IOBUF IOBUF_SCL( .IO(clkgen_scl_r), .I(scl_o), .O(scl_i), .T(scl_t));


// -----------------------------------------------------------
// 
//    ILA to View I2C Transactions...
//
// -----------------------------------------------------------

reg         ila_scl ;
reg         ila_sda ;
reg  [7:0]  ila_xfer_count ;
reg  [31:0] ila_xfer_offset;
reg         ila_xfer_enable;


always@(posedge s_axi_aclk)
begin
    ila_scl         <= scl_i          ;
    ila_sda         <= sda_i          ;
    ila_xfer_count  <= xfer_count     ;
    ila_xfer_offset <= xfer_offset    ;
    ila_xfer_enable <= xfer_enable    ;
end


ila_0 ila_0 (
    .clk     ( s_axi_aclk       ),
    .probe0  ( ila_scl          ),  // 1b
    .probe1  ( ila_sda          ),  // 1b
    .probe2  ( ila_xfer_count   ),  // 8b
    .probe3  ( ila_xfer_offset  ),  // 32b
    .probe4  ( ila_xfer_enable  )   // 1b
);

endmodule

