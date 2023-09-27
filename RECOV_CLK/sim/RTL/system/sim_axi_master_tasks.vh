/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/



reg            wr_req ; // pulse 
reg            rd_req ; // pulse 
reg [31:0]     addr   ; // valid on wr/rd req pulse
reg [31:0]     wdata  ; // valid on wr/rd req pulse
reg [3:0]      wstrb  ; // valid on wr/rd req pulse
wire           op_ack ; // pulse upon completion
wire [31:0]    rdata  ; // valid on op_ack pulse
reg  [31:0]    rdata_r;

task init_mem();
begin
    wr_req  = 'h0;
    rd_req  = 'h0;
    addr    = 'h0;
    wdata   = 'h0;
    wstrb   = 'h0;
    rdata_r = 'h0;
end
endtask


task write_mem( input [31:0] iaddr, input [31:0] iwdata, input [3:0] iwstrb);
begin
    @(posedge jtag_m_axi_aclk);
    wr_req = 'b1;
    wstrb  = iwstrb;
    addr   = iaddr;
    wdata  = iwdata;
    @(posedge jtag_m_axi_aclk);
    wr_req = 'b0;
    @(posedge op_ack);
    $display("%0t [INFO] %s : AXI Write : Addr=0x%08x, Data=0x%08x, Strb=0x%0x", $realtime, MODULE_NAME, addr, wdata, wstrb);
    repeat (10) @(posedge jtag_m_axi_aclk);
end
endtask


task read_mem( input [31:0] iaddr );
begin
    @(posedge jtag_m_axi_aclk);
    rd_req = 'b1;
    addr   = iaddr;
    @(posedge jtag_m_axi_aclk);
    rd_req = 'b0;
    @(posedge op_ack);
    @(negedge op_ack);
    rdata_r = rdata; 
    $display("%0t [INFO] %s : AXI Read :  Addr=0x%08x, Data=0x%08x", $realtime, MODULE_NAME, addr, rdata_r);
    repeat (10) @(posedge jtag_m_axi_aclk);
end
endtask


initial
begin
    init_mem();
end


sim_axi_master sim_axi_master (
    .jtag_m_axi_aclk     ( jtag_m_axi_aclk    ),
    .jtag_m_axi_aresetn  ( jtag_m_axi_aresetn ),

    .wr_req         ( wr_req             ),
    .rd_req         ( rd_req             ),
    .addr           ( addr               ),
    .wdata          ( wdata              ),
    .wstrb          ( wstrb              ),
    .op_ack         ( op_ack             ),
    .rdata          ( rdata              )
);
