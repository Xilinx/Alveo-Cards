/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------
  
module tg_axi_slave #(
    parameter   AXI_ADDR_WIDTH = 32, 
    parameter   AXI_DATA_WIDTH = 32
) (
    input  wire                          s_axi_aclk     ,
    input  wire                          s_axi_aresetn  ,
                                         
    input  wire [AXI_ADDR_WIDTH-1:0]     s_axi_araddr   ,
    input  wire                          s_axi_arvalid  ,
    output reg                           s_axi_arready  ,
                                         
    input  wire [AXI_ADDR_WIDTH-1:0]     s_axi_awaddr   ,
    input  wire                          s_axi_awvalid  ,
    output reg                           s_axi_awready  ,
                                         
    input  wire                          s_axi_bready   ,
    output wire [1:0]                    s_axi_bresp    ,
    output reg                           s_axi_bvalid   ,
                                         
    input  wire                          s_axi_rready   ,
    output reg  [AXI_DATA_WIDTH-1:0]     s_axi_rdata    ,
    output wire [1:0]                    s_axi_rresp    ,
    output reg                           s_axi_rvalid   ,
                                         
    input  wire [AXI_DATA_WIDTH-1:0]     s_axi_wdata    ,
    input  wire [AXI_DATA_WIDTH/8-1:0]   s_axi_wstrb    ,
    input  wire                          s_axi_wvalid   ,
    output reg                           s_axi_wready   ,
                                         
    output wire                          wr_en          ,
    output wire                          rd_en          ,
    output reg  [AXI_ADDR_WIDTH-1:0]     waddr          ,
    output reg  [AXI_ADDR_WIDTH-1:0]     raddr          ,
    output reg  [AXI_DATA_WIDTH:0]       wdata          ,
    output reg  [AXI_DATA_WIDTH/8-1:0]   wstrb          ,
    input  wire [AXI_DATA_WIDTH:0]       rdata          ,
    input  wire                          wr_ack         ,
    input  wire                          rd_ack
);
 
// -----------------------------------------------------------

always@(posedge s_axi_aclk)
begin
    if (!s_axi_aresetn)
        s_axi_arready <= 'h0;
    else
        s_axi_arready <= !s_axi_arready && s_axi_arvalid;
end

always@(posedge s_axi_aclk)
begin
    if (!s_axi_aresetn)
        s_axi_awready <= 'h0;
    else
        s_axi_awready <= !s_axi_awready && s_axi_awvalid;
end

always@(posedge s_axi_aclk)
begin
    if (!s_axi_aresetn)
        raddr <= 'h0;
    else if (s_axi_arvalid && s_axi_arready)
        raddr <= s_axi_araddr;
end

always@(posedge s_axi_aclk)
begin
    if (!s_axi_aresetn)
        waddr <= 'h0;
    else if (s_axi_awvalid && s_axi_awready)
        waddr <= s_axi_awaddr;
end

// -----------------------------------------------------------

always@(posedge s_axi_aclk)
begin
    if (!s_axi_aresetn)
        s_axi_wready <= 'h0;
    else
        s_axi_wready <= !s_axi_wready && s_axi_wvalid;
end

always@(posedge s_axi_aclk)
begin
    if (!s_axi_aresetn)
        wdata <= 'h0;
    else if (s_axi_wvalid && s_axi_wready)
        wdata <= s_axi_wdata;
end

always@(posedge s_axi_aclk)
begin
    if (!s_axi_aresetn)
        wstrb <= 'h0;
    else if (s_axi_wvalid && s_axi_wready)
        wstrb <= s_axi_wstrb;
end

reg [1:0] reg_wen;
always@(posedge s_axi_aclk)
begin
    if (!s_axi_aresetn)
        reg_wen[0] <= 'h0;
    else if (s_axi_wvalid && s_axi_wready)
        reg_wen[0] <= 'h1;
    else if (wr_ack)
        reg_wen[0] <= 'h0;
end

always@(posedge s_axi_aclk)
begin
    if (!s_axi_aresetn)
        reg_wen[1] <= 'h0;
    else if (s_axi_awvalid && s_axi_awready)
        reg_wen[1] <= 'h1;
    else if (wr_ack)
        reg_wen[1] <= 'h0;
end

wire wr_en_0 = (reg_wen[1:0] == 'h3);
reg  wr_en_1;
always@(posedge s_axi_aclk)
begin
    if (!s_axi_aresetn)
        wr_en_1 <= 'h0;
    else
        wr_en_1 <= wr_en_0;
end
assign wr_en = !wr_en_1 && wr_en_0;

assign s_axi_bresp = 'h0;
always@(posedge s_axi_aclk)
begin
    if (!s_axi_aresetn)
        s_axi_bvalid <= 'h0;
    else if (s_axi_bvalid && s_axi_bready)
        s_axi_bvalid <= 1'b0;
    else if ((reg_wen == 'h3) && wr_ack)
        s_axi_bvalid <= 1'b1;
end

// -----------------------------------------------------------------------------

assign s_axi_rresp = 'h0;

reg reg_ren;
always@(posedge s_axi_aclk)
begin
    if (!s_axi_aresetn)
        reg_ren <= 'h0;
    else if (s_axi_arvalid && s_axi_arready)
        reg_ren <= 'h1;
    else if (rd_ack)
        reg_ren <= 'h0;
end

wire rd_en_0 = reg_ren;
reg  rd_en_1;
always@(posedge s_axi_aclk)
begin
    if (!s_axi_aresetn)
        rd_en_1 <= 'h0;
    else
        rd_en_1 <= rd_en_0;
end
assign rd_en = !rd_en_1 && rd_en_0;

always@(posedge s_axi_aclk)
begin
    if (!s_axi_aresetn)
        s_axi_rvalid <= 'h0;
    else if (s_axi_rvalid && s_axi_rready)
        s_axi_rvalid <= 1'b0;
    else if (reg_ren && rd_ack)
        s_axi_rvalid <= 1'b1;
end

always@(posedge s_axi_aclk)
begin
    if (!s_axi_aresetn)
        s_axi_rdata <= 'h0;
    else if (reg_ren && rd_ack)
        s_axi_rdata <= rdata;
end

endmodule

