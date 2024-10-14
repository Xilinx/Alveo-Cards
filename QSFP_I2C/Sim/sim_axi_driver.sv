/*
Copyright (C) 2024, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: X11
*/

logic               jtag_axil_aclk    ;
logic               jtag_axil_aresetn ;

logic   [2:0]       jtag_axil_arprot  ;
logic   [31:0]      jtag_axil_araddr  ;
logic               jtag_axil_arvalid ;
logic               jtag_axil_arready ;

logic   [31:0]      jtag_axil_rdata   ;
logic   [1:0]       jtag_axil_rresp   ;
logic               jtag_axil_rvalid  ;
logic               jtag_axil_rready  ;

logic   [2:0]       jtag_axil_awprot  ;
logic   [31:0]      jtag_axil_awaddr  ;
logic               jtag_axil_awvalid ;
logic               jtag_axil_awready ;

logic   [31:0]      jtag_axil_wdata   ;
logic               jtag_axil_wvalid  ;
logic               jtag_axil_wready  ;

logic   [3:0]       jtag_axil_wstrb   ;
logic   [1:0]       jtag_axil_bresp   ;
logic               jtag_axil_bvalid  ;
logic               jtag_axil_bready  ;

logic               jtag_axil_rd_busy ;
logic               jtag_axil_wr_busy ;

initial begin
    jtag_axil_arprot     = 'h0;
    jtag_axil_araddr     = 'h0;
    jtag_axil_arvalid    = 'h0;
    jtag_axil_rready     = 'h0;
    jtag_axil_awprot     = 'h0;
    jtag_axil_awaddr     = 'h0;
    jtag_axil_awvalid    = 'h0;
    jtag_axil_wdata      = 'h0;
    jtag_axil_wstrb      = 'hF;
    jtag_axil_wvalid     = 'h0;
    jtag_axil_bready     = 'h0;

    jtag_axil_rd_busy    = 'h0;
    jtag_axil_wr_busy    = 'h0;

    // Integrated GTF example design, AXI to top level
    
    force   jtag_axil_aclk     = sim_tb_top.u_qsfp_i2c_top.jtag_axil_aclk     ;
    force   jtag_axil_aresetn  = sim_tb_top.u_qsfp_i2c_top.jtag_axil_aresetn  ;
    
    force   sim_tb_top.u_qsfp_i2c_top.jtag_axil_araddr    = jtag_axil_araddr  ;
    force   sim_tb_top.u_qsfp_i2c_top.jtag_axil_arvalid   = jtag_axil_arvalid ;
    force   sim_tb_top.u_qsfp_i2c_top.jtag_axil_rready    = jtag_axil_rready  ;
    force   sim_tb_top.u_qsfp_i2c_top.jtag_axil_awaddr    = jtag_axil_awaddr  ;
    force   sim_tb_top.u_qsfp_i2c_top.jtag_axil_awvalid   = jtag_axil_awvalid ;
    force   sim_tb_top.u_qsfp_i2c_top.jtag_axil_wdata     = jtag_axil_wdata   ;
    force   sim_tb_top.u_qsfp_i2c_top.jtag_axil_wstrb     = jtag_axil_wstrb   ;
    force   sim_tb_top.u_qsfp_i2c_top.jtag_axil_wvalid    = jtag_axil_wvalid  ;
    force   sim_tb_top.u_qsfp_i2c_top.jtag_axil_bready    = jtag_axil_bready  ;
    //force   sim_tb_top.u_qsfp_i2c_top.jtag_axil_awprot    = jtag_axil_awprot  ;
    //force   sim_tb_top.u_qsfp_i2c_top.jtag_axil_arprot    = jtag_axil_arprot  ;

    force   jtag_axil_arready  = sim_tb_top.u_qsfp_i2c_top.jtag_axil_arready  ;
    force   jtag_axil_rdata    = sim_tb_top.u_qsfp_i2c_top.jtag_axil_rdata    ;
    force   jtag_axil_rresp    = sim_tb_top.u_qsfp_i2c_top.jtag_axil_rresp    ;
    force   jtag_axil_rvalid   = sim_tb_top.u_qsfp_i2c_top.jtag_axil_rvalid   ;
    force   jtag_axil_awready  = sim_tb_top.u_qsfp_i2c_top.jtag_axil_awready  ;
    force   jtag_axil_wready   = sim_tb_top.u_qsfp_i2c_top.jtag_axil_wready   ;
    force   jtag_axil_bresp    = sim_tb_top.u_qsfp_i2c_top.jtag_axil_bresp    ;
    force   jtag_axil_bvalid   = sim_tb_top.u_qsfp_i2c_top.jtag_axil_bvalid   ;
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

        @ (negedge jtag_axil_aclk);

        jtag_axil_rd_busy    = 1'b1;
    
        // The Master puts an address on the Read Address channel as well as asserting ARVALID,
        // indicating the address is valid, and RREADY, indicating the master is ready to receive data from the slave.
        jtag_axil_araddr     = rd_addr + offset_addr;
        jtag_axil_arvalid    = 1'b1;
        jtag_axil_rready     = 1'b1;

        fork

            begin

                // The Slave asserts ARREADY, indicating that it is ready to receive the address on the bus.
                do begin
                    @ (posedge jtag_axil_aclk);
                end
                while (!jtag_axil_arready);

                // Since both ARVALID and ARREADY are asserted, on the next rising clock edge the handshake occurs, 
                // after this the master and slave deassert ARVALID and the ARREADY, respectively. (At this point, the slave has received the requested address).
                @ (negedge jtag_axil_aclk);
                jtag_axil_arvalid    = 1'b0;

            end

            begin

                // The Slave puts the requested data on the Read Data channel and asserts RVALID, 
                // indicating the data in the channel is valid. The slave can also put a response on RRESP, though this does not occur here.
                do begin
                    @ (posedge jtag_axil_aclk);
                end
                while (!jtag_axil_rvalid);

                @ (negedge jtag_axil_aclk);
                //result  = jtag_axil_rdata;
    
                // Since both RREADY and RVALID are asserted, the next rising clock edge completes the transaction. RREADY and RVALID can now be deasserted.
                jtag_axil_arvalid    = 1'b0;
                jtag_axil_rready     = 1'b0;

            end

            begin
                do begin
                    @ (negedge jtag_axil_aclk);
                    result  = jtag_axil_rdata;
                end
                while (!jtag_axil_rvalid);
            end

        join

        @ (negedge jtag_axil_aclk);
        rd_data = result;

        jtag_axil_rd_busy = 1'b0;

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

        @ (negedge jtag_axil_aclk);

        jtag_axil_wr_busy    = 1'b1;

        jtag_axil_awaddr     = wr_addr + offset_addr;
        jtag_axil_wdata      = wr_data;
        jtag_axil_awvalid    = 1'b1;
        jtag_axil_wvalid     = 1'b1;
        jtag_axil_bready     = 1'b1;

        fork

            begin
                // The Slave asserts AWREADY and WREADY on the Write Address and Write Data channels, respectively.
                do begin
                    @ (posedge jtag_axil_aclk);
                end
                while (!jtag_axil_awready);
                @ (negedge jtag_axil_aclk);
                jtag_axil_awvalid    = 1'b0;
            end
            begin
                do begin
                    @ (posedge jtag_axil_aclk);
                end
                while (!jtag_axil_wready);
                @ (negedge jtag_axil_aclk);
                jtag_axil_wvalid     = 1'b0;
            end

            begin
                // The Slave asserts BVALID, indicating there is a valid reponse on the Write response channel. 
                // (in this case the response is 2'b00, that being 'OKAY').
                do begin
                    @ (posedge jtag_axil_aclk);
                end 
                while (!jtag_axil_bvalid);

                // The next rising clock edge completes the transaction, with both the Ready and Valid signals on the write response channel high.
                @ (negedge jtag_axil_aclk);
                jtag_axil_bready     = 1'b0;
            end
        join

        @ (negedge jtag_axil_aclk);
        jtag_axil_wr_busy = 1'b0;

    end

endtask
