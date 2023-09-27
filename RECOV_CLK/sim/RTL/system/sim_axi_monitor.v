/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`timescale 1 ps / 1 ps

/*
module sim_axi_monitor #(
    parameter   INST_NAME = "dflt_axi_monitor",
    parameter   DEBUG_MSG = "false",
    parameter   AXI_ADDR_WIDTH = 32, 
    parameter   AXI_DATA_WIDTH = 32
) ();


// -----------------------------------------------------------
// Mapping to DUT AXI Interface...

wire                           jtag_m_axi_aclk     = sim_tb.clk_recov.jtag_m_axi_aclk    ;
wire                           jtag_m_axi_aresetn  = sim_tb.clk_recov.jtag_m_axi_aresetn ;

wire  [AXI_ADDR_WIDTH-1:0]     jtag_m_axi_araddr   = sim_tb.clk_recov.jtag_m_axi_araddr  ;
wire                           jtag_m_axi_arvalid  = sim_tb.clk_recov.jtag_m_axi_arvalid ;
wire                           jtag_m_axi_arready  = sim_tb.clk_recov.jtag_m_axi_arready ;

wire  [AXI_ADDR_WIDTH-1:0]     jtag_m_axi_awaddr   = sim_tb.clk_recov.jtag_m_axi_awaddr  ;
wire                           jtag_m_axi_awvalid  = sim_tb.clk_recov.jtag_m_axi_awvalid ;
wire                           jtag_m_axi_awready  = sim_tb.clk_recov.jtag_m_axi_awready ;

wire                           jtag_m_axi_bready   = sim_tb.clk_recov.jtag_m_axi_bready  ;
wire  [1:0]                    jtag_m_axi_bresp    = sim_tb.clk_recov.jtag_m_axi_bresp   ;
wire                           jtag_m_axi_bvalid   = sim_tb.clk_recov.jtag_m_axi_bvalid  ;

wire                           jtag_m_axi_rready   = sim_tb.clk_recov. jtag_m_axi_rready ;
wire  [AXI_DATA_WIDTH-1:0]     jtag_m_axi_rdata    = sim_tb.clk_recov.jtag_m_axi_rdata   ;
wire  [1:0]                    jtag_m_axi_rresp    = sim_tb.clk_recov.jtag_m_axi_rresp   ;
wire                           jtag_m_axi_rvalid   = sim_tb.clk_recov.jtag_m_axi_rvalid  ;

wire  [AXI_DATA_WIDTH-1:0]     jtag_m_axi_wdata    = sim_tb.clk_recov.jtag_m_axi_wdata   ;
wire  [AXI_DATA_WIDTH/8-1:0]   jtag_m_axi_wstrb    = sim_tb.clk_recov.jtag_m_axi_wstrb   ;
wire                           jtag_m_axi_wvalid   = sim_tb.clk_recov.jtag_m_axi_wvalid  ;
wire                           jtag_m_axi_wready   = sim_tb.clk_recov.jtag_m_axi_wready  ;

// -----------------------------------------------------------
// Messaging...

generate
if (DEBUG_MSG == "true") begin
    initial
    begin
        // (units, precision, suffix)
        $timeformat( -9, 0, " ns");
    end 
    
    reg   [AXI_ADDR_WIDTH-1:0]     jtag_m_axi_araddr_r   ;
    reg   [AXI_ADDR_WIDTH-1:0]     jtag_m_axi_awaddr_r   ;
    reg   [AXI_DATA_WIDTH-1:0]     jtag_m_axi_rdata_r    ;
    reg   [AXI_DATA_WIDTH-1:0]     jtag_m_axi_wdata_r    ;
    reg   [AXI_DATA_WIDTH/8-1:0]   jtag_m_axi_wstrb_r    ;
    
    always@(posedge jtag_m_axi_aclk)
        if ( jtag_m_axi_arvalid && jtag_m_axi_arready) jtag_m_axi_araddr_r <= jtag_m_axi_araddr;
    
    always@(posedge jtag_m_axi_aclk)
        if ( jtag_m_axi_awvalid && jtag_m_axi_awready) jtag_m_axi_awaddr_r <= jtag_m_axi_awaddr;
    
    always@(posedge jtag_m_axi_aclk)
        if ( jtag_m_axi_wvalid && jtag_m_axi_wready) jtag_m_axi_wdata_r <= jtag_m_axi_wdata;
    
    always@(posedge jtag_m_axi_aclk)
        if ( jtag_m_axi_wvalid && jtag_m_axi_wready) jtag_m_axi_wstrb_r <= jtag_m_axi_wstrb;
        
    always@(posedge jtag_m_axi_aclk)
        if ( jtag_m_axi_bvalid && jtag_m_axi_bready) $display("%0t [DEBUG] %s : AXI Write : Addr=0x%08x, Data=0x%08x, Strb=0x%0x", 
            $realtime, INST_NAME, jtag_m_axi_awaddr_r, jtag_m_axi_wdata_r, jtag_m_axi_wstrb_r);
    
    always@(posedge jtag_m_axi_aclk)
        if ( jtag_m_axi_rvalid && jtag_m_axi_rready) $display("%0t [DEBUG] %s : AXI Read :  Addr=0x%08x, Data=0x%08x", 
            $realtime, INST_NAME, jtag_m_axi_araddr_r, jtag_m_axi_rdata);
    
end
endgenerate

endmodule
*/
