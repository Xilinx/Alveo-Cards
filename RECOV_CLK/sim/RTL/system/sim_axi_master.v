/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`timescale 1 ps / 1 ps

// This module translates a simple register access interface to 
// generate a single AXI Lite master operation.
  
module sim_axi_master #(
    parameter   INST_NAME = "sim_axi_master",
    parameter   AXI_ADDR_WIDTH = 32, 
    parameter   AXI_DATA_WIDTH = 32
) (
    output wire                          jtag_m_axi_aclk     ,
    output wire                          jtag_m_axi_aresetn  ,
                                         
    // Simple TG Interface...
    input  wire                          wr_req         , // pulse 
    input  wire                          rd_req         , // pulse 
    input  wire [AXI_ADDR_WIDTH-1:0]     addr           , // valid on wr/rd req pulse
    input  wire [AXI_DATA_WIDTH-1:0]     wdata          , // valid on wr/rd req pulse
    input  wire [AXI_DATA_WIDTH/8-1:0]   wstrb          , // valid on wr/rd req pulse
    output wire                          op_ack         , // pulse upon completion
    output reg  [AXI_DATA_WIDTH-1:0]     rdata            // valid on op_ack pulse
);
 
// -----------------------------------------------------------
// Local AXI Master Interface...

reg   [AXI_ADDR_WIDTH-1:0]     jtag_m_axi_araddr   ;
reg                            jtag_m_axi_arvalid  ;
wire                           jtag_m_axi_arready  ;

reg   [AXI_ADDR_WIDTH-1:0]     jtag_m_axi_awaddr   ;
reg                            jtag_m_axi_awvalid  ;
wire                           jtag_m_axi_awready  ;

reg                            jtag_m_axi_bready   ;
wire  [1:0]                    jtag_m_axi_bresp    ;
wire                           jtag_m_axi_bvalid   ;

reg                            jtag_m_axi_rready   ;
wire  [AXI_DATA_WIDTH-1:0]     jtag_m_axi_rdata    ;
wire  [1:0]                    jtag_m_axi_rresp    ;
wire                           jtag_m_axi_rvalid   ;

reg   [AXI_DATA_WIDTH-1:0]     jtag_m_axi_wdata    ;
reg   [AXI_DATA_WIDTH/8-1:0]   jtag_m_axi_wstrb    ;
reg                            jtag_m_axi_wvalid   ;
wire                           jtag_m_axi_wready   ;



// -----------------------------------------------------------
// Mapping to DUT AXI Interface...
// assign                  jtag_m_axi_aclk     =  sim_tb.clk_recov.jtag_m_axi_aclk    ;
// assign                  jtag_m_axi_aresetn  =  sim_tb.clk_recov.jtag_m_axi_aresetn ;
// 
// 
// assign sim_tb.clk_recov.jtag_m_axi_araddr   =  jtag_m_axi_araddr                   ;
// assign sim_tb.clk_recov.jtag_m_axi_arvalid  =  jtag_m_axi_arvalid                  ;
// assign                  jtag_m_axi_arready  =  sim_tb.clk_recov.jtag_m_axi_arready ;
// 
// assign sim_tb.clk_recov.jtag_m_axi_awaddr   =  jtag_m_axi_awaddr                   ;
// assign sim_tb.clk_recov.jtag_m_axi_awvalid  =  jtag_m_axi_awvalid                  ;
// assign                  jtag_m_axi_awready  =  sim_tb.clk_recov.jtag_m_axi_awready ;
// 
// assign sim_tb.clk_recov.jtag_m_axi_bready   =  jtag_m_axi_bready                   ;
// assign                  jtag_m_axi_bresp    =  sim_tb.clk_recov.jtag_m_axi_bresp   ;
// assign                  jtag_m_axi_bvalid   =  sim_tb.clk_recov.jtag_m_axi_bvalid  ;
// 
// assign sim_tb.clk_recov.jtag_m_axi_rready   =  jtag_m_axi_rready                   ;
// assign                  jtag_m_axi_rdata    =  sim_tb.clk_recov.jtag_m_axi_rdata   ;
// assign                  jtag_m_axi_rresp    =  sim_tb.clk_recov.jtag_m_axi_rresp   ;
// assign                  jtag_m_axi_rvalid   =  sim_tb.clk_recov.jtag_m_axi_rvalid  ;
// 
// assign sim_tb.clk_recov.jtag_m_axi_wdata    =  jtag_m_axi_wdata                    ;
// assign sim_tb.clk_recov.jtag_m_axi_wstrb    =  jtag_m_axi_wstrb                    ;
// assign sim_tb.clk_recov.jtag_m_axi_wvalid   =  jtag_m_axi_wvalid                   ;
// assign                  jtag_m_axi_wready   =  sim_tb.clk_recov.jtag_m_axi_wready  ;
// 
// assign sim_tb.clk_recov.jtag_m_axi_awprot   = 'h0;
// assign sim_tb.clk_recov.jtag_m_axi_arprot   = 'h0;

// -----------------------------------------------------------

reg wr_req_0;
always@(posedge jtag_m_axi_aclk)
begin
    if (!jtag_m_axi_aresetn) begin
        wr_req_0 <= 'h0;
    end else begin
        wr_req_0 <= wr_req;
    end
end

reg rd_req_0;
always@(posedge jtag_m_axi_aclk)
begin
    if (!jtag_m_axi_aresetn) begin
        rd_req_0 <= 'h0;
    end else begin
        rd_req_0 <= rd_req;
    end
end

// -----------------------------------------------------------

always@(posedge jtag_m_axi_aclk)
begin
    if (!jtag_m_axi_aresetn) begin
        jtag_m_axi_wdata  <= 'h0;
        jtag_m_axi_wstrb  <= 'h0;
        jtag_m_axi_awaddr <= 'h0;
    end else if (wr_req) begin
        jtag_m_axi_wdata  <= wdata;
        jtag_m_axi_wstrb  <= wstrb;
        jtag_m_axi_awaddr <= addr;
    end
end

always@(posedge jtag_m_axi_aclk)
begin
    if (!jtag_m_axi_aresetn) begin
        jtag_m_axi_araddr <= 'h0;
    end else if (rd_req) begin
        jtag_m_axi_araddr <= addr;
    end
end

// -----------------------------------------------------------

always@(posedge jtag_m_axi_aclk)
begin
    if (!jtag_m_axi_aresetn)
        jtag_m_axi_awvalid <= 'h0;
    else if (jtag_m_axi_awvalid && jtag_m_axi_awready)
        jtag_m_axi_awvalid <= 'h0;
    else if (wr_req_0)
        jtag_m_axi_awvalid <= 'h1;
end

always@(posedge jtag_m_axi_aclk)
begin
    if (!jtag_m_axi_aresetn)
        jtag_m_axi_wvalid <= 'h0;
    else if (jtag_m_axi_wvalid && jtag_m_axi_wready)
        jtag_m_axi_wvalid <= 'h0;
    else if (wr_req_0)
        jtag_m_axi_wvalid <= 'h1;
end

always@(posedge jtag_m_axi_aclk)
begin
    if (!jtag_m_axi_aresetn)
        jtag_m_axi_arvalid <= 'h0;
    else if (jtag_m_axi_arvalid && jtag_m_axi_arready)
        jtag_m_axi_arvalid <= 'h0;
    else if (rd_req_0)
        jtag_m_axi_arvalid <= 'h1;
end

always@(posedge jtag_m_axi_aclk)
begin
    if (!jtag_m_axi_aresetn)
        jtag_m_axi_rready <= 'h0;
    else if (jtag_m_axi_rvalid && jtag_m_axi_rready)
        jtag_m_axi_rready <= 'h0;
    else if (rd_req_0)
        jtag_m_axi_rready <= 'h1;
end

always@(posedge jtag_m_axi_aclk)
begin
    if (!jtag_m_axi_aresetn)
        jtag_m_axi_bready <= 'h0;
    else if (jtag_m_axi_bvalid && jtag_m_axi_bready)
        jtag_m_axi_bready <= 'h0;
    else if (wr_req_0)
        jtag_m_axi_bready <= 'h1;
end

// -----------------------------------------------------------

wire wr_ack;
reg wr_ack_a; 
always@(posedge jtag_m_axi_aclk)
begin
    if (!jtag_m_axi_aresetn) 
        wr_ack_a <= 'h0;
    else if (wr_ack)
        wr_ack_a <= 'h0;
    else if (jtag_m_axi_awready && jtag_m_axi_awvalid) 
        wr_ack_a <= 'h1;
end

reg wr_ack_d; 
always@(posedge jtag_m_axi_aclk)
begin
    if (!jtag_m_axi_aresetn) 
        wr_ack_d <= 'h0;
    else if (wr_ack)
        wr_ack_d <= 'h0;
    else if (jtag_m_axi_wready && jtag_m_axi_wvalid) 
        wr_ack_d <= 'h1;
end

reg wr_ack_b; 
always@(posedge jtag_m_axi_aclk)
begin
    if (!jtag_m_axi_aresetn) 
        wr_ack_b <= 'h0;
    else if (wr_ack)
        wr_ack_b <= 'h0;
    else if (jtag_m_axi_bready && jtag_m_axi_bvalid) 
        wr_ack_b <= 'h1;
end

assign wr_ack = wr_ack_a & wr_ack_d & wr_ack_b;

wire rd_ack;
reg rd_ack_a; 
always@(posedge jtag_m_axi_aclk)
begin
    if (!jtag_m_axi_aresetn) 
        rd_ack_a <= 'h0;
    else if (rd_ack)
        rd_ack_a <= 'h0;
    else if (jtag_m_axi_arready && jtag_m_axi_arvalid) 
        rd_ack_a <= 'h1;
end

reg rd_ack_d; 
always@(posedge jtag_m_axi_aclk)
begin
    if (!jtag_m_axi_aresetn) 
        rd_ack_d <= 'h0;
    else if (rd_ack)
        rd_ack_d <= 'h0;
    else if (jtag_m_axi_rready && jtag_m_axi_rvalid) 
        rd_ack_d <= 'h1;
end

assign rd_ack = rd_ack_a & rd_ack_d;

assign op_ack = wr_ack | rd_ack;

// -----------------------------------------------------------

always@(posedge jtag_m_axi_aclk)
begin
    if (!jtag_m_axi_aresetn) 
        rdata <= 'h0;
    else if (jtag_m_axi_rready && jtag_m_axi_rvalid) 
        rdata <= jtag_m_axi_rdata;
end

// -----------------------------------------------------------

endmodule


