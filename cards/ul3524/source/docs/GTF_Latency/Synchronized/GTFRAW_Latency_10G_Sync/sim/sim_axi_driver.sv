/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

logic               axi_aclk        ;
logic               axi_aresetn     ;

logic   [31:0]      s_axil_araddr   ;
logic               s_axil_arvalid  ;
logic               s_axil_rready   ;
logic   [31:0]      s_axil_awaddr   ;
logic               s_axil_awvalid  ;
logic   [31:0]      s_axil_wdata    ;
logic               s_axil_wvalid   ;
logic               s_axil_bready   ;
logic   [2 : 0]     s_axil_awprot   ;
logic   [3 : 0]     s_axil_wstrb    ;
logic   [2 : 0]     s_axil_arprot   ;

logic               s_axil_arready  ;
logic   [31:0]      s_axil_rdata    ;
logic   [1:0]       s_axil_rresp    ;
logic               s_axil_rvalid   ;
logic               s_axil_awready  ;
logic               s_axil_wready   ;
logic               s_axil_bvalid   ;
logic   [1:0]       s_axil_bresp    ;

logic               s_axi_rd_busy   ;
logic               s_axi_wr_busy   ;
//logic               wa_complete_flg ;


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
    force   sim_top.u_gtfwizard_raw_gtfraw_ex.jtag_axil_awaddr    = s_axil_awaddr  ;
    force   sim_top.u_gtfwizard_raw_gtfraw_ex.jtag_axil_awprot    = s_axil_awprot  ;
    force   sim_top.u_gtfwizard_raw_gtfraw_ex.jtag_axil_awvalid   = s_axil_awvalid ;
    force   sim_top.u_gtfwizard_raw_gtfraw_ex.jtag_axil_wdata     = s_axil_wdata   ;
    force   sim_top.u_gtfwizard_raw_gtfraw_ex.jtag_axil_wstrb     = s_axil_wstrb   ;
    force   sim_top.u_gtfwizard_raw_gtfraw_ex.jtag_axil_wvalid    = s_axil_wvalid  ;
    force   sim_top.u_gtfwizard_raw_gtfraw_ex.jtag_axil_bready    = s_axil_bready  ;
    force   sim_top.u_gtfwizard_raw_gtfraw_ex.jtag_axil_araddr    = s_axil_araddr  ;
    force   sim_top.u_gtfwizard_raw_gtfraw_ex.jtag_axil_arprot    = s_axil_arprot  ;
    force   sim_top.u_gtfwizard_raw_gtfraw_ex.jtag_axil_arvalid   = s_axil_arvalid ;
    force   sim_top.u_gtfwizard_raw_gtfraw_ex.jtag_axil_rready    = s_axil_rready  ;

    force   axi_aclk        = sim_top.u_gtfwizard_raw_gtfraw_ex.axi_clk        ;
    force   axi_aresetn     = sim_top.u_gtfwizard_raw_gtfraw_ex.axi_rstn       ;

    force   s_axil_arready  = sim_top.u_gtfwizard_raw_gtfraw_ex.jtag_axil_arready  ;
    force   s_axil_rdata    = sim_top.u_gtfwizard_raw_gtfraw_ex.jtag_axil_rdata    ;
    force   s_axil_rresp    = sim_top.u_gtfwizard_raw_gtfraw_ex.jtag_axil_rresp    ;
    force   s_axil_rvalid   = sim_top.u_gtfwizard_raw_gtfraw_ex.jtag_axil_rvalid   ;
    force   s_axil_awready  = sim_top.u_gtfwizard_raw_gtfraw_ex.jtag_axil_awready  ;
    force   s_axil_wready   = sim_top.u_gtfwizard_raw_gtfraw_ex.jtag_axil_wready   ;
    force   s_axil_bvalid   = sim_top.u_gtfwizard_raw_gtfraw_ex.jtag_axil_bvalid   ;
    force   s_axil_bresp    = sim_top.u_gtfwizard_raw_gtfraw_ex.jtag_axil_bresp    ;
    //force   wa_complete_flg = &sim_top.u_gtfwizard_raw_gtfraw_ex.gtf_top_0.u_gtfwizard_0_example_gtfmac_top.i_gtfmac.gtwiz_buffbypass_rx_done_out_i;
end

/////////////////////////////////////////////////////////////////////////////////////////////
// TASKS
/////////////////////////////////////////////////////////////////////////////////////////////

task sim_axil_read;
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



task sim_axil_write;
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

