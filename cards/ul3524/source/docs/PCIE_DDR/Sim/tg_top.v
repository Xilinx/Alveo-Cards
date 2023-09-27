/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

module tg_top #(
    parameter   AXI_ADDR_WIDTH = 32, 
    parameter   AXI_DATA_WIDTH = 32
) (
    input  wire                          m_axi_aclk     ,
    input  wire                          m_axi_aresetn  ,
                                         
    // AXI Master Interface...
    output wire [AXI_ADDR_WIDTH-1:0]     m_axi_araddr   ,
    output wire                          m_axi_arvalid  ,
    input  wire                          m_axi_arready  ,
                        
    output wire [AXI_ADDR_WIDTH-1:0]     m_axi_awaddr   ,
    output wire                          m_axi_awvalid  ,
    input  wire                          m_axi_awready  ,

    output wire                          m_axi_bready   ,
    input  wire [1:0]                    m_axi_bresp    ,
    input  wire                          m_axi_bvalid   ,

    output wire                          m_axi_rready   ,
    input  wire [AXI_DATA_WIDTH-1:0]     m_axi_rdata    ,
    input  wire [1:0]                    m_axi_rresp    ,
    input  wire                          m_axi_rvalid   ,

    output wire [AXI_DATA_WIDTH-1:0]     m_axi_wdata    ,
    output wire [AXI_DATA_WIDTH/8-1:0]   m_axi_wstrb    ,
    output wire                          m_axi_wvalid   ,
    input  wire                          m_axi_wready   
);


// Simple TG Interface...
reg                           wr_req ; // pulse 
reg                           rd_req ; // pulse 
reg  [AXI_ADDR_WIDTH-1:0]     addr   ; // valid on wr/rd req pulse
reg  [AXI_DATA_WIDTH-1:0]     wdata  ; // valid on wr/rd req pulse
reg  [AXI_DATA_WIDTH/8-1:0]   wstrb  ; // valid on wr/rd req pulse
wire                          op_ack ; // pulse upon completion
wire [AXI_DATA_WIDTH-1:0]     rdata  ; // valid on op_ack pulse
    

// -----------------------------------------------------------
// 
//    AXI Master....
//
// -----------------------------------------------------------

tg_axi_master #(
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ), 
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH )
) axi_master (
    .m_axi_aclk     ( m_axi_aclk     ),
    .m_axi_aresetn  ( m_axi_aresetn  ),
                               
    // Simple TG Interface...  
    .wr_req         ( wr_req         ),
    .rd_req         ( rd_req         ),
    .addr           ( addr           ),
    .wdata          ( wdata          ),
    .wstrb          ( wstrb          ),
    .op_ack         ( op_ack         ),
    .rdata          ( rdata          ),
                                    
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
//    AXI Write Function....
//
// -----------------------------------------------------------

task axi_clear();
    begin
        // Clear axi command...
        wr_req  <= 'h0;
        rd_req  <= 'h0;
        addr    <= 'h0;
        wdata   <= 'h0;
        wstrb   <= 'h0;
    end
endtask

// -----------------------------------------------------------
// 
//    AXI Write Function....
//
// -----------------------------------------------------------

task axi_write();
    input [AXI_ADDR_WIDTH-1:0]   i_addr ;
    input [AXI_DATA_WIDTH-1:0]   i_wdata;
    input [AXI_DATA_WIDTH/8-1:0] i_wstrb;    
    begin
        // Initiate axi command...
        @(posedge m_axi_aclk);
        wr_req  <= 1'b1;
        rd_req  <= 1'b0;
        addr    <= i_addr;
        wdata   <= i_wdata;
        wstrb   <= i_wstrb;
        @(posedge m_axi_aclk);
        wr_req  <= 1'b0;
    
        // ...wait for operation to complete...
        @(negedge m_axi_aclk);
        while ( !op_ack )
            @(negedge m_axi_aclk);
            
        // Debug trace...
        $display("[AXI WR] 0x%02x = 0x%08x (0x%01x)", addr, wdata, wstrb);

        // ...delay a few more cycles....
        repeat (5) @(posedge m_axi_aclk);
    end
endtask

// -----------------------------------------------------------
// 
//    AXI Read Function....
//
// -----------------------------------------------------------

reg [AXI_DATA_WIDTH-1:0]   i_rdata;

task axi_read();
    input [AXI_ADDR_WIDTH-1:0]   i_addr ;
    begin
        // Initiate axi command...
        @(posedge m_axi_aclk);
        wr_req  <= 1'b0;
        rd_req  <= 1'b1;
        addr    <= i_addr;
        wdata   <= 'h0;
        wstrb   <= 'h0;
        @(posedge m_axi_aclk);
        rd_req  <= 1'b0;
    
        // ...wait for operation to complete...
        @(negedge m_axi_aclk);
        while ( !op_ack )
            @(negedge m_axi_aclk);
        // ...record read data...
        i_rdata <= rdata;
        
        // Debug trace...
        $display("[AXI RD] 0x%02x = 0x%08x", addr, rdata);

        // ...delay a few more cycles....
        repeat (5) @(posedge m_axi_aclk);
    end
endtask


// -----------------------------------------------------------
// 
//    Main Sequence....
//
// -----------------------------------------------------------

initial
begin
    // Initialize variables...
    axi_clear();
    
    // Wait for reset release...
    @(posedge m_axi_aresetn);
    
    // Delay a Bit
    repeat (100) @(posedge m_axi_aclk);
    
    // Main traffic generation sequence....
    
    axi_read ( 'h00 );
    while ( (i_rdata[15:8] != 'h9) && (i_rdata[15:8] != 'hA) )
    begin
        repeat (5000) @(posedge m_axi_aclk);
        axi_read ( 'h00 );
    end
    
    // ...delay a few more cycles....
    repeat (100) @(posedge m_axi_aclk);

    $display("...Test Completed...");
    $finish();
end

endmodule

    