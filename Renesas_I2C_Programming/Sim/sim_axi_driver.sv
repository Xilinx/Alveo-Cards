/*
Copyright (C) 2024, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: X11
*/

logic               JTAG_AXIL_aclk    ;
logic               JTAG_AXIL_aresetn ;

logic   [31:0]      JTAG_AXIL_araddr  ;
logic               JTAG_AXIL_arvalid ;
logic               JTAG_AXIL_rready  ;
logic   [31:0]      JTAG_AXIL_awaddr  ;
logic               JTAG_AXIL_awvalid ;
logic   [31:0]      JTAG_AXIL_wdata   ;
logic               JTAG_AXIL_wvalid  ;
logic               JTAG_AXIL_bready  ;
logic   [2 : 0]     JTAG_AXIL_awprot  ;
logic   [3 : 0]     JTAG_AXIL_wstrb   ;
logic   [2 : 0]     JTAG_AXIL_arprot  ;

logic               JTAG_AXIL_arready ;
logic   [31:0]      JTAG_AXIL_rdata   ;
logic   [1:0]       JTAG_AXIL_rresp   ;
logic               JTAG_AXIL_rvalid  ;
logic               JTAG_AXIL_awready ;
logic               JTAG_AXIL_wready  ;
logic               JTAG_AXIL_bvalid  ;
logic   [1:0]       JTAG_AXIL_bresp   ;

logic               JTAG_AXIL_rd_busy ;
logic               JTAG_AXIL_wr_busy ;

initial begin
    JTAG_AXIL_araddr     = 'h0;
    JTAG_AXIL_arvalid    = 'h0;
    JTAG_AXIL_rready     = 'h0;
    JTAG_AXIL_awaddr     = 'h0;
    JTAG_AXIL_awvalid    = 'h0;
    JTAG_AXIL_wdata      = 'h0;
    JTAG_AXIL_wvalid     = 'h0;
    JTAG_AXIL_bready     = 'h0;
    JTAG_AXIL_awprot     = 'h0;
    JTAG_AXIL_wstrb      = 'hF;
    JTAG_AXIL_arprot     = 'h0;

    JTAG_AXIL_rd_busy    = 'h0;
    JTAG_AXIL_wr_busy    = 'h0;

    // Integrated GTF example design, AXI to top level
    force   sim_tb_top.u_pcie_ddr_top.JTAG_AXIL_awaddr    = JTAG_AXIL_awaddr  ;
    force   sim_tb_top.u_pcie_ddr_top.JTAG_AXIL_awprot    = JTAG_AXIL_awprot  ;
    force   sim_tb_top.u_pcie_ddr_top.JTAG_AXIL_awvalid   = JTAG_AXIL_awvalid ;
    force   sim_tb_top.u_pcie_ddr_top.JTAG_AXIL_wdata     = JTAG_AXIL_wdata   ;
    force   sim_tb_top.u_pcie_ddr_top.JTAG_AXIL_wstrb     = JTAG_AXIL_wstrb   ;
    force   sim_tb_top.u_pcie_ddr_top.JTAG_AXIL_wvalid    = JTAG_AXIL_wvalid  ;
    force   sim_tb_top.u_pcie_ddr_top.JTAG_AXIL_bready    = JTAG_AXIL_bready  ;
    force   sim_tb_top.u_pcie_ddr_top.JTAG_AXIL_araddr    = JTAG_AXIL_araddr  ;
    force   sim_tb_top.u_pcie_ddr_top.JTAG_AXIL_arprot    = JTAG_AXIL_arprot  ;
    force   sim_tb_top.u_pcie_ddr_top.JTAG_AXIL_arvalid   = JTAG_AXIL_arvalid ;
    force   sim_tb_top.u_pcie_ddr_top.JTAG_AXIL_rready    = JTAG_AXIL_rready  ;
    
    force   JTAG_AXIL_aclk     = sim_tb_top.u_pcie_ddr_top.JTAG_AXI_0_aclk    ;
    force   JTAG_AXIL_aresetn  = sim_tb_top.u_pcie_ddr_top.JTAG_AXI_0_aresetn ;
    
    force   JTAG_AXIL_arready  = sim_tb_top.u_pcie_ddr_top.JTAG_AXIL_arready  ;
    force   JTAG_AXIL_rdata    = sim_tb_top.u_pcie_ddr_top.JTAG_AXIL_rdata    ;
    force   JTAG_AXIL_rresp    = sim_tb_top.u_pcie_ddr_top.JTAG_AXIL_rresp    ;
    force   JTAG_AXIL_rvalid   = sim_tb_top.u_pcie_ddr_top.JTAG_AXIL_rvalid   ;
    force   JTAG_AXIL_awready  = sim_tb_top.u_pcie_ddr_top.JTAG_AXIL_awready  ;
    force   JTAG_AXIL_wready   = sim_tb_top.u_pcie_ddr_top.JTAG_AXIL_wready   ;
    force   JTAG_AXIL_bvalid   = sim_tb_top.u_pcie_ddr_top.JTAG_AXIL_bvalid   ;
    force   JTAG_AXIL_bresp    = sim_tb_top.u_pcie_ddr_top.JTAG_AXIL_bresp    ;
end


/////////////////////////////////////////////////////////////////////////////////////////////
// TASKS
/////////////////////////////////////////////////////////////////////////////////////////////

task sim_axi_read;
    input  [31:0] offset_addr;
    input  [31:0] rd_addr;
    output [31:0] rd_data;

    begin

        logic   [31:0]  result;

        @ (negedge JTAG_AXIL_aclk);

        JTAG_AXIL_rd_busy    = 1'b1;
    
        // The Master puts an address on the Read Address channel as well as asserting ARVALID,
        // indicating the address is valid, and RREADY, indicating the master is ready to receive data from the slave.
        JTAG_AXIL_araddr     = rd_addr + offset_addr;
        JTAG_AXIL_arvalid    = 1'b1;
        JTAG_AXIL_rready     = 1'b1;

        fork

            begin

                // The Slave asserts ARREADY, indicating that it is ready to receive the address on the bus.
                do begin
                    @ (posedge JTAG_AXIL_aclk);
                end
                while (!JTAG_AXIL_arready);

                // Since both ARVALID and ARREADY are asserted, on the next rising clock edge the handshake occurs, 
                // after this the master and slave deassert ARVALID and the ARREADY, respectively. (At this point, the slave has received the requested address).
                @ (negedge JTAG_AXIL_aclk);
                JTAG_AXIL_arvalid    = 1'b0;

            end

            begin

                // The Slave puts the requested data on the Read Data channel and asserts RVALID, 
                // indicating the data in the channel is valid. The slave can also put a response on RRESP, though this does not occur here.
                do begin
                    @ (posedge JTAG_AXIL_aclk);
                end
                while (!JTAG_AXIL_rvalid);

                @ (negedge JTAG_AXIL_aclk);
                //result  = JTAG_AXIL_rdata;
    
                // Since both RREADY and RVALID are asserted, the next rising clock edge completes the transaction. RREADY and RVALID can now be deasserted.
                JTAG_AXIL_arvalid    = 1'b0;
                JTAG_AXIL_rready     = 1'b0;

            end

            begin
                do begin
                    @ (negedge JTAG_AXIL_aclk);
                    result  = JTAG_AXIL_rdata;
                end
                while (!JTAG_AXIL_rvalid);
            end

        join

        @ (negedge JTAG_AXIL_aclk);
        rd_data = result;

        JTAG_AXIL_rd_busy = 1'b0;

    end

endtask



task sim_axi_write;
    input [31:0] offset_addr;
    input [31:0] wr_addr;
    input [31:0] wr_data;

    begin


        // The Master puts an address on the Write Address channel and data on the Write data channel. 
        // At the same time it asserts AWVALID and WVALID indicating the address and data on the respective 
        // channels is valid. BREADY is also asserted by the Master, indicating it is ready to receive a response.

        @ (negedge JTAG_AXIL_aclk);

        JTAG_AXIL_wr_busy    = 1'b1;

        JTAG_AXIL_awaddr     = wr_addr + offset_addr;
        JTAG_AXIL_wdata      = wr_data;
        JTAG_AXIL_awvalid    = 1'b1;
        JTAG_AXIL_wvalid     = 1'b1;
        JTAG_AXIL_bready     = 1'b1;

        fork

            begin
                // The Slave asserts AWREADY and WREADY on the Write Address and Write Data channels, respectively.
                do begin
                    @ (posedge JTAG_AXIL_aclk);
                end
                while (!JTAG_AXIL_awready);
                @ (negedge JTAG_AXIL_aclk);
                JTAG_AXIL_awvalid    = 1'b0;
            end
            begin
                do begin
                    @ (posedge JTAG_AXIL_aclk);
                end
                while (!JTAG_AXIL_wready);
                @ (negedge JTAG_AXIL_aclk);
                JTAG_AXIL_wvalid     = 1'b0;
            end

            begin
                // The Slave asserts BVALID, indicating there is a valid reponse on the Write response channel. 
                // (in this case the response is 2'b00, that being 'OKAY').
                do begin
                    @ (posedge JTAG_AXIL_aclk);
                end 
                while (!JTAG_AXIL_bvalid);

                // The next rising clock edge completes the transaction, with both the Ready and Valid signals on the write response channel high.
                @ (negedge JTAG_AXIL_aclk);
                JTAG_AXIL_bready     = 1'b0;
            end
        join

        @ (negedge JTAG_AXIL_aclk);
        JTAG_AXIL_wr_busy = 1'b0;

    end

endtask
