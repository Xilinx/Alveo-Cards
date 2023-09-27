/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

module pcie_ddr_top (
  input  wire        sys_clk_p           ,
  input  wire        sys_clk_n           ,
  input  wire        sys_rst_n           ,
  input  wire [7:0]  pcie_mgt_0_rxn      ,
  input  wire [7:0]  pcie_mgt_0_rxp      ,
  output wire [7:0]  pcie_mgt_0_txn      ,
  output wire [7:0]  pcie_mgt_0_txp      ,
                                      
  input  wire        C0_SYS_CLK_0_clk_n  ,
  input  wire        C0_SYS_CLK_0_clk_p  ,
  output wire        C0_DDR4_0_act_n     ,
  output wire [16:0] C0_DDR4_0_adr       ,
  output wire [1:0]  C0_DDR4_0_ba        ,
  output wire [1:0]  C0_DDR4_0_bg        ,
  output wire [0:0]  C0_DDR4_0_ck_c      ,
  output wire [0:0]  C0_DDR4_0_ck_t      ,
  output wire [0:0]  C0_DDR4_0_cke       ,
  output wire [0:0]  C0_DDR4_0_cs_n      ,
  inout  wire [8:0]  C0_DDR4_0_dm_n      ,
  inout  wire [71:0] C0_DDR4_0_dq        ,
  inout  wire [8:0]  C0_DDR4_0_dqs_c     ,
  inout  wire [8:0]  C0_DDR4_0_dqs_t     ,
  output wire [0:0]  C0_DDR4_0_odt       ,
  output wire        C0_DDR4_0_reset_n   ,

  input  wire        CLK_IN1_D_0_clk_n   ,
  input  wire        CLK_IN1_D_0_clk_p   ,
  
  output wire        DDR_PSUIO_RESET     ,
                                      
  inout  wire        i2c_sda             ,
  inout  wire        i2c_scl             

);

// Need to enable the DDR I2C I/O Expander 
assign DDR_PSUIO_RESET = 1;

// -- Input clocking and reset....

wire         m_axi_aclk    ;
wire         m_axi_aresetn ;   
wire         sys_aclk_10M  ;
 
 // 300Mhz -> 100 Mhz
system_reset system_reset (
    .clk_sys_p   ( CLK_IN1_D_0_clk_p ),
    .clk_sys_n   ( CLK_IN1_D_0_clk_n ),
    .sys_aclk    ( m_axi_aclk        ),
    .sys_aresetn ( m_axi_aresetn     ),
    .sys_aclk_10M( sys_aclk_10M      )
);

 
// -- Input clocking and reset....
wire sys_clk_0    ;        
wire sys_clk_gt_0 ;        
wire sys_rst_n_0  ; 

IBUF   sys_reset_n_ibuf (
    .O( sys_rst_n_0 ), 
    .I( sys_rst_n   )
);

IBUFDS_GTE4 # (.REFCLK_HROW_CK_SEL(2'b00)) 
refclk_ibuf (
    .O      ( sys_clk_gt_0  ), 
    .ODIV2  ( sys_clk_0     ), 
    .I      ( sys_clk_p     ), 
    .CEB    ( 1'b0          ), 
    .IB     ( sys_clk_n     )
);

// ----------------------------------------
wire          c0_ddr4_ui_clk                ;                    
wire          c0_ddr4_ui_clk_sync_rst       ;                    


wire          M00_ACLK_0           = m_axi_aclk      ; 
wire          M00_ARESETN_0        = m_axi_aresetn   ; 
wire [31:0]   M00_AXI_0_araddr     ;
wire [2:0]    M00_AXI_0_arprot     ;
wire          M00_AXI_0_arready    ;
wire          M00_AXI_0_arvalid    ;
wire [31:0]   M00_AXI_0_awaddr     ;
wire [2:0]    M00_AXI_0_awprot     ;
wire          M00_AXI_0_awready    ;
wire          M00_AXI_0_awvalid    ;
wire          M00_AXI_0_bready     ;
wire [1:0]    M00_AXI_0_bresp      ;
wire          M00_AXI_0_bvalid     ;
wire [31:0]   M00_AXI_0_rdata      ;
wire          M00_AXI_0_rready     ;
wire [1:0]    M00_AXI_0_rresp      ;
wire          M00_AXI_0_rvalid     ;
wire [31:0]   M00_AXI_0_wdata      ;
wire          M00_AXI_0_wready     ;
wire [3:0]    M00_AXI_0_wstrb      ;
wire          M00_AXI_0_wvalid     ;

wire          M01_ACLK_0           = c0_ddr4_ui_clk;
wire          M01_ARESETN_0        = ~c0_ddr4_ui_clk_sync_rst;
wire [33:0]   M01_AXI_0_araddr     ;
wire [1:0]    M01_AXI_0_arburst    ;
wire [3:0]    M01_AXI_0_arcache    ;
wire [3:0]    M01_AXI_0_arid       ;
wire [7:0]    M01_AXI_0_arlen      ;
wire [0:0]    M01_AXI_0_arlock     ;
wire [2:0]    M01_AXI_0_arprot     ;
wire [3:0]    M01_AXI_0_arqos      ;
wire          M01_AXI_0_arready    ;
wire [3:0]    M01_AXI_0_arregion   ;
wire [2:0]    M01_AXI_0_arsize     ;
wire          M01_AXI_0_arvalid    ;
wire [33:0]   M01_AXI_0_awaddr     ;
wire [1:0]    M01_AXI_0_awburst    ;
wire [3:0]    M01_AXI_0_awcache    ;
wire [3:0]    M01_AXI_0_awid       ;
wire [7:0]    M01_AXI_0_awlen      ;
wire [0:0]    M01_AXI_0_awlock     ;
wire [2:0]    M01_AXI_0_awprot     ;
wire [3:0]    M01_AXI_0_awqos      ;
wire          M01_AXI_0_awready    ;
wire [3:0]    M01_AXI_0_awregion   ;
wire [2:0]    M01_AXI_0_awsize     ;
wire          M01_AXI_0_awvalid    ;
wire [3:0]    M01_AXI_0_bid        ;
wire          M01_AXI_0_bready     ;
wire [1:0]    M01_AXI_0_bresp      ;
wire          M01_AXI_0_bvalid     ;
wire [511:0]  M01_AXI_0_rdata      ;
wire [3:0]    M01_AXI_0_rid        ;
wire          M01_AXI_0_rlast      ;
wire          M01_AXI_0_rready     ;
wire [1:0]    M01_AXI_0_rresp      ;
wire          M01_AXI_0_rvalid     ;
wire [511:0]  M01_AXI_0_wdata      ;
wire          M01_AXI_0_wlast      ;
wire          M01_AXI_0_wready     ;
wire [63:0]   M01_AXI_0_wstrb      ;
wire          M01_AXI_0_wvalid     ;
  
design_1_wrapper design_1_wrapper (
    .sys_clk_0              ( sys_clk_0          ),
    .sys_clk_gt_0           ( sys_clk_gt_0       ),
    .sys_rst_n_0            ( sys_rst_n_0        ),
                            
    .pcie_mgt_0_rxn         ( pcie_mgt_0_rxn     ),
    .pcie_mgt_0_rxp         ( pcie_mgt_0_rxp     ),
    .pcie_mgt_0_txn         ( pcie_mgt_0_txn     ),
    .pcie_mgt_0_txp         ( pcie_mgt_0_txp     ),
                            
    .M00_ACLK_0             ( M00_ACLK_0         ),
    .M00_ARESETN_0          ( M00_ARESETN_0      ),
    .M00_AXI_0_araddr       ( M00_AXI_0_araddr   ),
    .M00_AXI_0_arprot       ( M00_AXI_0_arprot   ),
    .M00_AXI_0_arready      ( M00_AXI_0_arready  ),
    .M00_AXI_0_arvalid      ( M00_AXI_0_arvalid  ),
    .M00_AXI_0_awaddr       ( M00_AXI_0_awaddr   ),
    .M00_AXI_0_awprot       ( M00_AXI_0_awprot   ),
    .M00_AXI_0_awready      ( M00_AXI_0_awready  ),
    .M00_AXI_0_awvalid      ( M00_AXI_0_awvalid  ),
    .M00_AXI_0_bready       ( M00_AXI_0_bready   ),
    .M00_AXI_0_bresp        ( M00_AXI_0_bresp    ),
    .M00_AXI_0_bvalid       ( M00_AXI_0_bvalid   ),
    .M00_AXI_0_rdata        ( M00_AXI_0_rdata    ),
    .M00_AXI_0_rready       ( M00_AXI_0_rready   ),
    .M00_AXI_0_rresp        ( M00_AXI_0_rresp    ),
    .M00_AXI_0_rvalid       ( M00_AXI_0_rvalid   ),
    .M00_AXI_0_wdata        ( M00_AXI_0_wdata    ),
    .M00_AXI_0_wready       ( M00_AXI_0_wready   ),
    .M00_AXI_0_wstrb        ( M00_AXI_0_wstrb    ),
    .M00_AXI_0_wvalid       ( M00_AXI_0_wvalid   ),
                            
    .M01_ACLK_0             ( M01_ACLK_0         ),
    .M01_ARESETN_0          ( M01_ARESETN_0      ),
    .M01_AXI_0_araddr       ( M01_AXI_0_araddr   ),
    .M01_AXI_0_arburst      ( M01_AXI_0_arburst  ),
    .M01_AXI_0_arcache      ( M01_AXI_0_arcache  ),
    .M01_AXI_0_arid         ( M01_AXI_0_arid     ),
    .M01_AXI_0_arlen        ( M01_AXI_0_arlen    ),
    .M01_AXI_0_arlock       ( M01_AXI_0_arlock   ),
    .M01_AXI_0_arprot       ( M01_AXI_0_arprot   ),
    .M01_AXI_0_arqos        ( M01_AXI_0_arqos    ),
    .M01_AXI_0_arready      ( M01_AXI_0_arready  ),
    .M01_AXI_0_arregion     ( M01_AXI_0_arregion ),
    .M01_AXI_0_arsize       ( M01_AXI_0_arsize   ),
    .M01_AXI_0_arvalid      ( M01_AXI_0_arvalid  ),
    .M01_AXI_0_awaddr       ( M01_AXI_0_awaddr   ),
    .M01_AXI_0_awburst      ( M01_AXI_0_awburst  ),
    .M01_AXI_0_awcache      ( M01_AXI_0_awcache  ),
    .M01_AXI_0_awid         ( M01_AXI_0_awid     ),
    .M01_AXI_0_awlen        ( M01_AXI_0_awlen    ),
    .M01_AXI_0_awlock       ( M01_AXI_0_awlock   ),
    .M01_AXI_0_awprot       ( M01_AXI_0_awprot   ),
    .M01_AXI_0_awqos        ( M01_AXI_0_awqos    ),
    .M01_AXI_0_awready      ( M01_AXI_0_awready  ),
    .M01_AXI_0_awregion     ( M01_AXI_0_awregion ),
    .M01_AXI_0_awsize       ( M01_AXI_0_awsize   ),
    .M01_AXI_0_awvalid      ( M01_AXI_0_awvalid  ),
    .M01_AXI_0_bid          ( M01_AXI_0_bid      ),
    .M01_AXI_0_bready       ( M01_AXI_0_bready   ),
    .M01_AXI_0_bresp        ( M01_AXI_0_bresp    ),
    .M01_AXI_0_bvalid       ( M01_AXI_0_bvalid   ),
    .M01_AXI_0_rdata        ( M01_AXI_0_rdata    ),
    .M01_AXI_0_rid          ( M01_AXI_0_rid      ),
    .M01_AXI_0_rlast        ( M01_AXI_0_rlast    ),
    .M01_AXI_0_rready       ( M01_AXI_0_rready   ),
    .M01_AXI_0_rresp        ( M01_AXI_0_rresp    ),
    .M01_AXI_0_rvalid       ( M01_AXI_0_rvalid   ),
    .M01_AXI_0_wdata        ( M01_AXI_0_wdata    ),
    .M01_AXI_0_wlast        ( M01_AXI_0_wlast    ),
    .M01_AXI_0_wready       ( M01_AXI_0_wready   ),
    .M01_AXI_0_wstrb        ( M01_AXI_0_wstrb    ),
    .M01_AXI_0_wvalid       ( M01_AXI_0_wvalid   ),

    .S_AXI_B_0_araddr       ( 'h0     ), //   input  [31:0]  
    .S_AXI_B_0_arburst      ( 'h0     ), //   input  [1:0]   
    .S_AXI_B_0_arid         ( 'h0     ), //   input  [3:0]   
    .S_AXI_B_0_arlen        ( 'h0     ), //   input  [7:0]   
    .S_AXI_B_0_arready      (         ), //   output         
    .S_AXI_B_0_arregion     ( 'h0     ), //   input  [3:0]   
    .S_AXI_B_0_arsize       ( 'h0     ), //   input  [2:0]   
    .S_AXI_B_0_arvalid      ( 'h0     ), //   input          
    .S_AXI_B_0_awaddr       ( 'h0     ), //   input  [31:0]  
    .S_AXI_B_0_awburst      ( 'h0     ), //   input  [1:0]   
    .S_AXI_B_0_awid         ( 'h0     ), //   input  [3:0]   
    .S_AXI_B_0_awlen        ( 'h0     ), //   input  [7:0]   
    .S_AXI_B_0_awready      (         ), //   output         
    .S_AXI_B_0_awregion     ( 'h0     ), //   input  [3:0]   
    .S_AXI_B_0_awsize       ( 'h0     ), //   input  [2:0]   
    .S_AXI_B_0_awvalid      ( 'h0     ), //   input          
    .S_AXI_B_0_bid          (         ), //   output [3:0]   
    .S_AXI_B_0_bready       ( 'h0     ), //   input          
    .S_AXI_B_0_bresp        (         ), //   output [1:0]   
    .S_AXI_B_0_bvalid       (         ), //   output         
    .S_AXI_B_0_rdata        (         ), //   output [511:0] 
    .S_AXI_B_0_rid          (         ), //   output [3:0]   
    .S_AXI_B_0_rlast        (         ), //   output         
    .S_AXI_B_0_rready       ( 'h0     ), //   input          
    .S_AXI_B_0_rresp        (         ), //   output [1:0]   
    .S_AXI_B_0_rvalid       (         ), //   output         
    .S_AXI_B_0_wdata        ( 'h0     ), //   input  [511:0] 
    .S_AXI_B_0_wlast        ( 'h0     ), //   input          
    .S_AXI_B_0_wready       (         ), //   output         
    .S_AXI_B_0_wstrb        ( 'h0     ), //   input  [63:0]  
    .S_AXI_B_0_wvalid       ( 'h0     ), //   input          

    .S_AXI_LITE_0_araddr    ( 'h0     ), //   input  [31:0]  
    .S_AXI_LITE_0_arprot    ( 'h0     ), //   input  [2:0]   
    .S_AXI_LITE_0_arready   (         ), //   output         
    .S_AXI_LITE_0_arvalid   ( 'h0     ), //   input          
    .S_AXI_LITE_0_awaddr    ( 'h0     ), //   input  [31:0]  
    .S_AXI_LITE_0_awprot    ( 'h0     ), //   input  [2:0]   
    .S_AXI_LITE_0_awready   (         ), //   output         
    .S_AXI_LITE_0_awvalid   ( 'h0     ), //   input          
    .S_AXI_LITE_0_bready    ( 'h0     ), //   input          
    .S_AXI_LITE_0_bresp     (         ), //   output [1:0]   
    .S_AXI_LITE_0_bvalid    (         ), //   output         
    .S_AXI_LITE_0_rdata     (         ), //   output [31:0]  
    .S_AXI_LITE_0_rready    ( 'h0     ), //   input          
    .S_AXI_LITE_0_rresp     (         ), //   output [1:0]   
    .S_AXI_LITE_0_rvalid    (         ), //   output         
    .S_AXI_LITE_0_wdata     ( 'h0     ), //   input  [31:0]  
    .S_AXI_LITE_0_wready    (         ), //   output         
    .S_AXI_LITE_0_wstrb     ( 'h0     ), //   input  [3:0]   
    .S_AXI_LITE_0_wvalid    ( 'h0     )  //   input          
);

wire [31:0] IO_TEST0_VALUE ;
wire [31:0] IO_TEST1_VALUE ;
wire [31:0] IO_TEST2_VALUE ;
wire [31:0] IO_TEST3_VALUE ;

//assign IO_TEST3_VALUE = IO_TEST0_VALUE + IO_TEST1_VALUE + IO_TEST2_VALUE;

reg_reference_top reg_reference_top(
    .IO_TEST0_VALUE ( IO_TEST0_VALUE       ),
    .IO_TEST1_VALUE ( IO_TEST1_VALUE       ),
    .IO_TEST2_VALUE ( IO_TEST2_VALUE       ),
    .IO_TEST3_VALUE ( IO_TEST3_VALUE       ),

    .aclk           ( m_axi_aclk           ),
    .aresetn        ( m_axi_aresetn        ),
    .m_axi_awaddr   ( M00_AXI_0_awaddr     ),
    .m_axi_awprot   ( M00_AXI_0_awprot     ),
    .m_axi_awvalid  ( M00_AXI_0_awvalid    ),
    .m_axi_awready  ( M00_AXI_0_awready    ),
    .m_axi_wdata    ( M00_AXI_0_wdata      ),
    .m_axi_wstrb    ( M00_AXI_0_wstrb      ),
    .m_axi_wvalid   ( M00_AXI_0_wvalid     ),
    .m_axi_wready   ( M00_AXI_0_wready     ),
    .m_axi_bresp    ( M00_AXI_0_bresp      ),
    .m_axi_bvalid   ( M00_AXI_0_bvalid     ),
    .m_axi_bready   ( M00_AXI_0_bready     ),
    .m_axi_araddr   ( M00_AXI_0_araddr     ),
    .m_axi_arprot   ( M00_AXI_0_arprot     ),
    .m_axi_arvalid  ( M00_AXI_0_arvalid    ),
    .m_axi_arready  ( M00_AXI_0_arready    ),
    .m_axi_rdata    ( M00_AXI_0_rdata      ),
    .m_axi_rresp    ( M00_AXI_0_rresp      ),
    .m_axi_rvalid   ( M00_AXI_0_rvalid     ),
    .m_axi_rready   ( M00_AXI_0_rready     )
);

assign i2c_resetn = m_axi_aresetn & IO_TEST0_VALUE[0];  

ddr_i2c_top ddr_i2c_top (
    .seq_status     ( IO_TEST3_VALUE ),
    .s_axi_aclk     ( m_axi_aclk     ),
    .s_axi_aresetn  ( i2c_resetn     ),
    .sys_aclk_10M   ( sys_aclk_10M   ),

    .s_axi_araddr   ( 'h0            ),
    .s_axi_arvalid  ( 'h0            ),
    .s_axi_arready  (                ),

    .s_axi_awaddr   ( 'h0            ),
    .s_axi_awvalid  ( 'h0            ),
    .s_axi_awready  (                ),

    .s_axi_bready   ( 'h0            ),
    .s_axi_bresp    (                ),
    .s_axi_bvalid   (                ),

    .s_axi_rready   ( 'h0            ),
    .s_axi_rdata    (                ),
    .s_axi_rresp    (                ),
    .s_axi_rvalid   (                ),

    .s_axi_wdata    ( 'h0            ),
    .s_axi_wstrb    ( 'h0            ),
    .s_axi_wvalid   ( 'h0            ),
    .s_axi_wready   (                ),

    .i2c_sda        ( i2c_sda        ),
    .i2c_scl        ( i2c_scl        )
);


wire         c0_init_calib_complete        ;                 

wire [31:0]  c0_ddr4_s_axi_ctrl_araddr     = 'h0;                    
wire         c0_ddr4_s_axi_ctrl_arready    ;                    
wire         c0_ddr4_s_axi_ctrl_arvalid    = 'h0;                    
wire [31:0]  c0_ddr4_s_axi_ctrl_awaddr     = 'h0;                    
wire         c0_ddr4_s_axi_ctrl_awready    ;                    
wire         c0_ddr4_s_axi_ctrl_awvalid    = 'h0;                    
wire         c0_ddr4_s_axi_ctrl_bready     = 'h0;                    
wire [1:0]   c0_ddr4_s_axi_ctrl_bresp      ;                    
wire         c0_ddr4_s_axi_ctrl_bvalid     ;                    
wire [31:0]  c0_ddr4_s_axi_ctrl_rdata      ;                    
wire         c0_ddr4_s_axi_ctrl_rready     = 'h0;                    
wire [1:0]   c0_ddr4_s_axi_ctrl_rresp      ;                    
wire         c0_ddr4_s_axi_ctrl_rvalid     ;                    
wire [31:0]  c0_ddr4_s_axi_ctrl_wdata      = 'h0;                    
wire         c0_ddr4_s_axi_ctrl_wready     ;                    
wire         c0_ddr4_s_axi_ctrl_wvalid     = 'h0; 
    
assign ddr_sys_rst = IO_TEST0_VALUE[1];      

ddr4_0 ddr4_0 (
    .sys_rst                     (  ddr_sys_rst                   ), //  input                              

    .c0_sys_clk_p                (  C0_SYS_CLK_0_clk_p            ), //  input                              
    .c0_sys_clk_n                (  C0_SYS_CLK_0_clk_n            ), //  input                              

    .c0_ddr4_act_n               (  C0_DDR4_0_act_n               ), //  output                               
    .c0_ddr4_adr                 (  C0_DDR4_0_adr                 ), //  output [16:0]                        
    .c0_ddr4_ba                  (  C0_DDR4_0_ba                  ), //  output [1:0]                     
    .c0_ddr4_bg                  (  C0_DDR4_0_bg                  ), //  output [1:0]                     
    .c0_ddr4_cke                 (  C0_DDR4_0_cke                 ), //  output [0:0]                     
    .c0_ddr4_odt                 (  C0_DDR4_0_odt                 ), //  output [0:0]                     
    .c0_ddr4_cs_n                (  C0_DDR4_0_cs_n                ), //  output [0:0]                       
    .c0_ddr4_ck_t                (  C0_DDR4_0_ck_t                ), //  output [0:0]                       
    .c0_ddr4_ck_c                (  C0_DDR4_0_ck_c                ), //  output [0:0]                        
    .c0_ddr4_reset_n             (  C0_DDR4_0_reset_n             ), //  output                             
    .c0_ddr4_dm_dbi_n            (  C0_DDR4_0_dm_n                ), //  inout  [8:0]                       
    .c0_ddr4_dq                  (  C0_DDR4_0_dq                  ), //  inout  [71:0]                        
    .c0_ddr4_dqs_c               (  C0_DDR4_0_dqs_c               ), //  inout  [8:0]                      
    .c0_ddr4_dqs_t               (  C0_DDR4_0_dqs_t               ), //  inout  [8:0]                      
                                                             
                                                             
    .c0_init_calib_complete      (  c0_init_calib_complete        ), //  output                          
    .c0_ddr4_ui_clk              (  c0_ddr4_ui_clk                ), //  output                             
    .c0_ddr4_ui_clk_sync_rst     (  c0_ddr4_ui_clk_sync_rst       ), //  output                             

    .c0_ddr4_s_axi_ctrl_araddr   (  c0_ddr4_s_axi_ctrl_araddr     ), //  input  [31:0]                      
    .c0_ddr4_s_axi_ctrl_arready  (  c0_ddr4_s_axi_ctrl_arready    ), //  output                             
    .c0_ddr4_s_axi_ctrl_arvalid  (  c0_ddr4_s_axi_ctrl_arvalid    ), //  input                              
    .c0_ddr4_s_axi_ctrl_awaddr   (  c0_ddr4_s_axi_ctrl_awaddr     ), //  input  [31:0]                      
    .c0_ddr4_s_axi_ctrl_awready  (  c0_ddr4_s_axi_ctrl_awready    ), //  output                             
    .c0_ddr4_s_axi_ctrl_awvalid  (  c0_ddr4_s_axi_ctrl_awvalid    ), //  input                              
    .c0_ddr4_s_axi_ctrl_bready   (  c0_ddr4_s_axi_ctrl_bready     ), //  input                              
    .c0_ddr4_s_axi_ctrl_bresp    (  c0_ddr4_s_axi_ctrl_bresp      ), //  output [1:0]                       
    .c0_ddr4_s_axi_ctrl_bvalid   (  c0_ddr4_s_axi_ctrl_bvalid     ), //  output                             
    .c0_ddr4_s_axi_ctrl_rdata    (  c0_ddr4_s_axi_ctrl_rdata      ), //  output [31:0]                      
    .c0_ddr4_s_axi_ctrl_rready   (  c0_ddr4_s_axi_ctrl_rready     ), //  input                              
    .c0_ddr4_s_axi_ctrl_rresp    (  c0_ddr4_s_axi_ctrl_rresp      ), //  output [1:0]                       
    .c0_ddr4_s_axi_ctrl_rvalid   (  c0_ddr4_s_axi_ctrl_rvalid     ), //  output                             
    .c0_ddr4_s_axi_ctrl_wdata    (  c0_ddr4_s_axi_ctrl_wdata      ), //  input  [31:0]                      
    .c0_ddr4_s_axi_ctrl_wready   (  c0_ddr4_s_axi_ctrl_wready     ), //  output                             
    .c0_ddr4_s_axi_ctrl_wvalid   (  c0_ddr4_s_axi_ctrl_wvalid     ), //  input                              

    .c0_ddr4_aresetn             (  ~c0_ddr4_ui_clk_sync_rst      ), //  input                              
    .c0_ddr4_s_axi_araddr        (  M01_AXI_0_araddr & 'h3FFFFFFF ), //  input  [33:0]                      
    .c0_ddr4_s_axi_arburst       (  M01_AXI_0_arburst             ), //  input  [1:0]                       
    .c0_ddr4_s_axi_arcache       (  M01_AXI_0_arcache             ), //  input  [3:0]                       
    .c0_ddr4_s_axi_arid          (  M01_AXI_0_arid                ), //  input  [3:0]                       
    .c0_ddr4_s_axi_arlen         (  M01_AXI_0_arlen               ), //  input  [7:0]                       
    .c0_ddr4_s_axi_arlock        (  M01_AXI_0_arlock              ), //  input  [0:0]                       
    .c0_ddr4_s_axi_arprot        (  M01_AXI_0_arprot              ), //  input  [2:0]                       
    .c0_ddr4_s_axi_arqos         (  M01_AXI_0_arqos               ), //  input  [3:0]                       
    .c0_ddr4_s_axi_arready       (  M01_AXI_0_arready             ), //  output                             
    .c0_ddr4_s_axi_arsize        (  M01_AXI_0_arsize              ), //  input  [2:0]                       
    .c0_ddr4_s_axi_arvalid       (  M01_AXI_0_arvalid             ), //  input                              
    .c0_ddr4_s_axi_awaddr        (  M01_AXI_0_awaddr & 'h3FFFFFFF ), //  input  [33:0]                      
    .c0_ddr4_s_axi_awburst       (  M01_AXI_0_awburst             ), //  input  [1:0]                       
    .c0_ddr4_s_axi_awcache       (  M01_AXI_0_awcache             ), //  input  [3:0]                       
    .c0_ddr4_s_axi_awid          (  M01_AXI_0_awid                ), //  input  [3:0]                       
    .c0_ddr4_s_axi_awlen         (  M01_AXI_0_awlen               ), //  input  [7:0]                       
    .c0_ddr4_s_axi_awlock        (  M01_AXI_0_awlock              ), //  input  [0:0]                       
    .c0_ddr4_s_axi_awprot        (  M01_AXI_0_awprot              ), //  input  [2:0]                       
    .c0_ddr4_s_axi_awqos         (  M01_AXI_0_awqos               ), //  input  [3:0]                       
    .c0_ddr4_s_axi_awready       (  M01_AXI_0_awready             ), //  output                             
    .c0_ddr4_s_axi_awsize        (  M01_AXI_0_awsize              ), //  input  [2:0]                       
    .c0_ddr4_s_axi_awvalid       (  M01_AXI_0_awvalid             ), //  input                              
    .c0_ddr4_s_axi_bid           (  M01_AXI_0_bid                 ), //  output [3:0]                       
    .c0_ddr4_s_axi_bready        (  M01_AXI_0_bready              ), //  input                              
    .c0_ddr4_s_axi_bresp         (  M01_AXI_0_bresp               ), //  output [1:0]                       
    .c0_ddr4_s_axi_bvalid        (  M01_AXI_0_bvalid              ), //  output                             
    .c0_ddr4_s_axi_rdata         (  M01_AXI_0_rdata               ), //  output [511:0]                     
    .c0_ddr4_s_axi_rid           (  M01_AXI_0_rid                 ), //  output [3:0]                       
    .c0_ddr4_s_axi_rlast         (  M01_AXI_0_rlast               ), //  output                             
    .c0_ddr4_s_axi_rready        (  M01_AXI_0_rready              ), //  input                              
    .c0_ddr4_s_axi_rresp         (  M01_AXI_0_rresp               ), //  output [1:0]                       
    .c0_ddr4_s_axi_rvalid        (  M01_AXI_0_rvalid              ), //  output                             
    .c0_ddr4_s_axi_wdata         (  M01_AXI_0_wdata               ), //  input  [511:0]                     
    .c0_ddr4_s_axi_wlast         (  M01_AXI_0_wlast               ), //  input                              
    .c0_ddr4_s_axi_wready        (  M01_AXI_0_wready              ), //  output                             
    .c0_ddr4_s_axi_wstrb         (  M01_AXI_0_wstrb               ), //  input  [63:0]                      
    .c0_ddr4_s_axi_wvalid        (  M01_AXI_0_wvalid              ), //  input                              
                                     
    .c0_ddr4_interrupt           (                                ), //  output                             
    .dbg_bus                     (                                ), //  output wire [511:0]                
    .dbg_clk                     (                                )  //  output                             
);

endmodule
