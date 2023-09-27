/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

logic               axi_aclk;
logic               axi_aresetn;

logic   [31:0]      s_axil_araddr;
logic               s_axil_arvalid;
logic               s_axil_rready;
logic   [31:0]      s_axil_awaddr;
logic               s_axil_awvalid;
logic   [31:0]      s_axil_wdata;
logic               s_axil_wvalid;
logic               s_axil_bready;
logic   [2 : 0]     s_axil_awprot;
logic   [3 : 0]     s_axil_wstrb;
logic   [2 : 0]     s_axil_arprot;

logic               s_axil_arready;
logic   [31:0]      s_axil_rdata;
logic   [1:0]       s_axil_rresp;
logic               s_axil_rvalid;
logic               s_axil_awready;
logic               s_axil_wready;
logic               s_axil_bvalid;
logic   [1:0]       s_axil_bresp;

logic               s_axi_rd_busy;
logic               s_axi_wr_busy;
logic               wa_complete_flg;


initial begin
    s_axil_araddr     = 'd0;
    s_axil_arvalid    = 'd0;
    s_axil_rready     = 'd0;
    s_axil_awaddr     = 'd0;
    s_axil_awvalid    = 'd0;
    s_axil_wdata      = 'd0;
    s_axil_wvalid     = 'd0;
    s_axil_bready     = 'd0;
    s_axil_awprot     = 'd0;
    s_axil_wstrb      = 'd0;
    s_axil_arprot     = 'd0;

    s_axi_rd_busy     = 'd0;
    s_axi_wr_busy     = 'd0;

    // Integrated GTF example design, AXI to top level
    force   sim_tb.clk_recov.jtag_m_axi_awaddr    = s_axil_awaddr;
    force   sim_tb.clk_recov.jtag_m_axi_awprot    = s_axil_awprot;
    force   sim_tb.clk_recov.jtag_m_axi_awvalid   = s_axil_awvalid;
    force   sim_tb.clk_recov.jtag_m_axi_wdata     = s_axil_wdata;
    force   sim_tb.clk_recov.jtag_m_axi_wstrb     = s_axil_wstrb;
    force   sim_tb.clk_recov.jtag_m_axi_wvalid    = s_axil_wvalid;
    force   sim_tb.clk_recov.jtag_m_axi_bready    = s_axil_bready;
    force   sim_tb.clk_recov.jtag_m_axi_araddr    = s_axil_araddr;
    force   sim_tb.clk_recov.jtag_m_axi_arprot    = s_axil_arprot;
    force   sim_tb.clk_recov.jtag_m_axi_arvalid   = s_axil_arvalid;
    force   sim_tb.clk_recov.jtag_m_axi_rready    = s_axil_rready;
    
    force   axi_aclk        = sim_tb.clk_recov.jtag_m_axi_aclk;
    force   axi_aresetn     = sim_tb.clk_recov.jtag_m_axi_aresetn;
                            
    force   s_axil_arready  = sim_tb.clk_recov.jtag_m_axi_arready;
    force   s_axil_rdata    = sim_tb.clk_recov.jtag_m_axi_rdata;
    force   s_axil_rresp    = sim_tb.clk_recov.jtag_m_axi_rresp;
    force   s_axil_rvalid   = sim_tb.clk_recov.jtag_m_axi_rvalid;
    force   s_axil_awready  = sim_tb.clk_recov.jtag_m_axi_awready;
    force   s_axil_wready   = sim_tb.clk_recov.jtag_m_axi_wready;
    force   s_axil_bvalid   = sim_tb.clk_recov.jtag_m_axi_bvalid;
    force   s_axil_bresp    = sim_tb.clk_recov.jtag_m_axi_bresp;
    //force   wa_complete_flg = &sim_tb.clk_recov.gtf_top_0.u_gtfwizard_0_example_gtfmac_top.i_gtfmac.gtwiz_buffbypass_rx_done_out_i;
end

/////////////////////////////////////////////////////////////////////////////////////////////
// TASKS
/////////////////////////////////////////////////////////////////////////////////////////////

task hwchk_axil_read;
    input  [31:0] offset_addr;
    input  [31:0] rd_addr;
    output [31:0] rd_data;

    begin

        logic   [31:0]  result;

        @ (negedge axi_aclk);

        s_axi_rd_busy = 1'b1;
    
        // The Master puts an address on the Read Address channel as well as asserting ARVALID,
        // indicating the address is valid, and RREADY, indicating the master is ready to receive data from the slave.
        s_axil_araddr     = rd_addr + offset_addr;
        s_axil_arvalid    = 1'b1;
        s_axil_rready     = 1'b1;

        fork

            begin

                // The Slave asserts ARREADY, indicating that it is ready to receive the address on the bus.
                do begin
                    @ (posedge axi_aclk);
                end
                while (!s_axil_arready);

                // Since both ARVALID and ARREADY are asserted, on the next rising clock edge the handshake occurs, 
                // after this the master and slave deassert ARVALID and the ARREADY, respectively. (At this point, the slave has received the requested address).
                @ (negedge axi_aclk);
                s_axil_arvalid    = 1'b0;

            end

            begin

                // The Slave puts the requested data on the Read Data channel and asserts RVALID, 
                // indicating the data in the channel is valid. The slave can also put a response on RRESP, though this does not occur here.
                do begin
                    @ (posedge axi_aclk);
                end
                while (!s_axil_rvalid);

                @ (negedge axi_aclk);
                result  = s_axil_rdata;
    
                // Since both RREADY and RVALID are asserted, the next rising clock edge completes the transaction. RREADY and RVALID can now be deasserted.
                s_axil_arvalid    = 1'b0;
                s_axil_rready     = 1'b0;

            end

        join

        @ (negedge axi_aclk);
        rd_data = result;

        s_axi_rd_busy = 1'b0;

    end

endtask



task hwchk_axil_write;
    input [31:0] offset_addr;
    input [31:0] wr_addr;
    input [31:0] wr_data;

    begin


        // The Master puts an address on the Write Address channel and data on the Write data channel. 
        // At the same time it asserts AWVALID and WVALID indicating the address and data on the respective 
        // channels is valid. BREADY is also asserted by the Master, indicating it is ready to receive a response.

        @ (negedge axi_aclk);

        s_axi_wr_busy     = 1'b1;

        s_axil_awaddr     = wr_addr + offset_addr;
        s_axil_wdata      = wr_data;
        s_axil_awvalid    = 1'b1;
        s_axil_wvalid     = 1'b1;
        s_axil_bready     = 1'b1;

        fork

            begin
                // The Slave asserts AWREADY and WREADY on the Write Address and Write Data channels, respectively.
                do begin
                    @ (posedge axi_aclk);
                end
                while (!s_axil_awready);
                @ (negedge axi_aclk);
                s_axil_awvalid    = 1'b0;
            end
            begin
                do begin
                    @ (posedge axi_aclk);
                end
                while (!s_axil_wready);
                @ (negedge axi_aclk);
                s_axil_wvalid     = 1'b0;
            end

            begin
                // The Slave asserts BVALID, indicating there is a valid reponse on the Write response channel. 
                // (in this case the response is 2'b00, that being 'OKAY').
                do begin
                    @ (posedge axi_aclk);
                end 
                while (!s_axil_bvalid);

                // The next rising clock edge completes the transaction, with both the Ready and Valid signals on the write response channel high.
                @ (negedge axi_aclk);
                s_axil_bready     = 1'b0;
            end
        join

        @ (negedge axi_aclk);
        s_axi_wr_busy = 1'b0;

    end

endtask


/*
//
//  Monistor for JTAG AXI Interface...
//
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

wire                           jtag_m_axi_rready   = sim_tb.clk_recov.jtag_m_axi_rready ;
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