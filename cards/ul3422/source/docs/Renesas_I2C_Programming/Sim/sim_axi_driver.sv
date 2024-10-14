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
