/*
Copyright (C) 2024, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: X11
*/

//------------------------------------------------------------------------------
//
//  Description: This module generates the AXI register accesses required by the
//               Xilinx I2C IP to execute the individual high level register 
//               from the i2c_sequencer.
//
//------------------------------------------------------------------------------

module i2c_axi_sequencer #(
    parameter   AXI_ADDR_WIDTH = 32, 
    parameter   AXI_DATA_WIDTH = 32
) (
    input  wire                       aclk         ,
    input  wire                       aresetn      ,
                            
    input  wire                       IO_CONTROL_PULSE,
    input  wire [0:0]                 IO_CONTROL_RW  ,
    input  wire [7:0]                 IO_CONTROL_ID  ,
    input  wire [7:0]                 IO_ADDR_ADDR   ,
    input  wire [7:0]                 IO_WDATA_WDATA ,
    output reg  [7:0]                 IO_RDATA_RDATA ,
    output reg                        IO_CONTROL_CMPLT,

    // Request to axi master that interfaces with I2C IP...
    output wire                       seq_axi_wr_req   ,
    output wire                       seq_axi_rd_req   ,
    output reg  [AXI_ADDR_WIDTH-1:0]  seq_axi_addr     ,
    output reg  [AXI_DATA_WIDTH-1:0]  seq_axi_wdata    ,
    input  wire                       seq_axi_ack      ,
    input  wire [AXI_DATA_WIDTH-1:0]  seq_axi_rdata 
);

// ==============================================================

localparam ST_IDLE         = 'h00;
localparam ST_CLR_ISR_0    = 'h01;
localparam ST_CLR_ISR_2    = 'h03;
localparam ST_WR_RX_PIRQ_0 = 'h05;
localparam ST_WR_TX_0      = 'h07;
localparam ST_WR_TX_2      = 'h09;
localparam ST_WR_TX_4      = 'h0b;
localparam ST_WR_TX_6      = 'h0d;
localparam ST_WR_CR_0      = 'h0f;
localparam ST_CLR_ISR_4    = 'h11;
localparam ST_CLR_ISR_6    = 'h13;
localparam ST_RD_RX_0      = 'h15;
localparam ST_RD_RX_2      = 'h17;
localparam ST_WR_TX_8      = 'h19;
localparam ST_WR_CR_2      = 'h1b;
localparam ST_CLR_ISR_8    = 'h1d;
localparam ST_CLR_ISR_9    = 'h1e;
localparam ST_CLR_ISR_A    = 'h1f;
localparam ST_CLR_ISR_B    = 'h20;
localparam ST_WR_CR_6      = 'h21;
localparam ST_COMPLETE     = 'h23;
localparam ST_CLR_ISR_4a   = 'h24;
localparam ST_CLR_ISR_6a   = 'h25;
                  
reg [7:0] cstate; 
reg [7:0] nstate;

always@(posedge aclk)
    if (!aresetn) cstate <= ST_IDLE;
    else          cstate <= nstate;
    
always@(*)
begin
    nstate = cstate;
    case (cstate)
        ST_IDLE          : if (IO_CONTROL_PULSE) nstate = ST_CLR_ISR_0;
                          
        // -----------------------------------
        //  Setup...

            // Clear ISR...
            ST_CLR_ISR_0     : if (seq_axi_ack) nstate = ST_CLR_ISR_2;
            ST_CLR_ISR_2     : if (seq_axi_ack) nstate = ST_WR_RX_PIRQ_0;
                    
            // Set RX FIFO Depth
            ST_WR_RX_PIRQ_0  : if (seq_axi_ack) nstate = ST_WR_TX_0;
    
            // Program TXFIFO Dev ID (bit 8 is start bit)
            ST_WR_TX_0       : if (seq_axi_ack) nstate = ST_WR_TX_2;
    
            // Program TXFIFO Reg Addr
            ST_WR_TX_2       : if      (seq_axi_ack && IO_CONTROL_RW) nstate = ST_WR_TX_4;
                               else if (seq_axi_ack)                  nstate = ST_WR_TX_8;

        // -----------------------------------
        //  Read Operation...

            // Program TXFIFO Dev ID (bit 8 is repeated start)
            ST_WR_TX_4       : if (seq_axi_ack) nstate = ST_WR_TX_6;
    
            // Program TXFIFO RX Bytes (bit 9 is stop bit)
            ST_WR_TX_6       : if (seq_axi_ack) nstate = ST_WR_CR_0;
    
            // Set MSMS, Set Mode
            ST_WR_CR_0       : if (seq_axi_ack) nstate = ST_CLR_ISR_4;
    
            // Wait for RX FIFO FULL
            //  -- wait for busy
            ST_CLR_ISR_4     : nstate = ST_CLR_ISR_4a;
            ST_CLR_ISR_4a    : if      (seq_axi_ack && ((seq_axi_rdata & 'h4) == 'h4) ) nstate = ST_CLR_ISR_6;
                               else if (seq_axi_ack                                   ) nstate = ST_CLR_ISR_4;
                               
            //  -- wait rx not empty
            ST_CLR_ISR_6     : nstate = ST_CLR_ISR_6a;
            ST_CLR_ISR_6a    : if      (seq_axi_ack && ((seq_axi_rdata & 'h4C) == 'h0C) ) nstate = ST_RD_RX_0;
                               else if (seq_axi_ack                                     ) nstate = ST_CLR_ISR_6;
    
            // Read RX FIFO 
            ST_RD_RX_0       : if (seq_axi_ack) nstate = ST_WR_CR_6; 
            //ST_RD_RX_2       : nstate = ST_RD_RX_3;
            //ST_RD_RX_3       : if (seq_axi_ack) nstate = ST_WR_CR_6;

        // -----------------------------------
        //  Write Operation...

            // Program TXFIFO RX Bytes (bit 9 is stop bit)
            ST_WR_TX_8       : if (seq_axi_ack) nstate = ST_WR_CR_2;
    
            // Set MSMS, Set Mode
            ST_WR_CR_2       : if (seq_axi_ack) nstate = ST_CLR_ISR_8;
    
            // Wait for TX FIFO EMPTY
            //  -- wait for busy
            ST_CLR_ISR_8     : if      (seq_axi_ack && ((seq_axi_rdata & 'h4) == 'h4) ) nstate = ST_CLR_ISR_A;
                               else if (seq_axi_ack                                   ) nstate = ST_CLR_ISR_9;
            ST_CLR_ISR_9     : nstate = ST_CLR_ISR_8;
                   
            //  -- wait for not busy
            ST_CLR_ISR_A     : if      (seq_axi_ack && ((seq_axi_rdata & 'h4) == 'h0) ) nstate = ST_WR_CR_6;
                               else if (seq_axi_ack                                   ) nstate = ST_CLR_ISR_B;
            ST_CLR_ISR_B     : nstate = ST_CLR_ISR_A;
    
        // -----------------------------------
        // Disable...
            ST_WR_CR_6       : if (seq_axi_ack) nstate = ST_COMPLETE;
    
            ST_COMPLETE      : nstate = ST_IDLE;
    endcase
end    

// ==============================================================
//  xfr bus controller...

localparam REG_ISR      = 32'h0020;
localparam REG_CR       = 32'h0100;
localparam REG_SR       = 32'h0104;
localparam REG_TXFIFO   = 32'h0108;
localparam REG_RXFIFO   = 32'h010C;
localparam REG_RX_PIRQ  = 32'h0120;
localparam REG_GPO      = 32'h0124;

localparam BIT_RD    = 'h1;
localparam BIT_START = 'h100;
localparam BIT_STOP  = 'h200;
localparam RD_BYTES  = 1;

reg wr_req;
reg rd_req;

always@(posedge aclk)
begin
    if (!aresetn)                        begin wr_req = 'h0; rd_req = 'h0; end

    // -----------------------------------
    //  Setup...
        // Clear ISR...
        else if (nstate == ST_CLR_ISR_0  )   begin wr_req = 'h0; rd_req = 'h1;  seq_axi_addr <= REG_ISR; end
        else if (nstate == ST_CLR_ISR_2  )   begin wr_req = 'h1; rd_req = 'h0;  seq_axi_addr <= REG_ISR;      seq_axi_wdata <= seq_axi_rdata; end
    
        // Set Rx FIFO Depth
        else if (nstate == ST_WR_RX_PIRQ_0 ) begin wr_req = 'h1; rd_req = 'h0;  seq_axi_addr <= REG_RX_PIRQ;  seq_axi_wdata <= RD_BYTES-1; end 
    
        // Write DevID + Wr, Reg Addr
        else if (nstate == ST_WR_TX_0    )   begin wr_req = 'h1; rd_req = 'h0;  seq_axi_addr <= REG_TXFIFO;   seq_axi_wdata <= IO_CONTROL_ID  + BIT_START; end
        else if (nstate == ST_WR_TX_2    )   begin wr_req = 'h1; rd_req = 'h0;  seq_axi_addr <= REG_TXFIFO;   seq_axi_wdata <= IO_ADDR_ADDR; end
    
    // -----------------------------------
    //  Read Operation...
        else if (nstate == ST_WR_TX_4    )   begin wr_req = 'h1; rd_req = 'h0;  seq_axi_addr <= REG_TXFIFO;   seq_axi_wdata <= IO_CONTROL_ID + BIT_START + BIT_RD; end
        else if (nstate == ST_WR_TX_6    )   begin wr_req = 'h1; rd_req = 'h0;  seq_axi_addr <= REG_TXFIFO;   seq_axi_wdata <= RD_BYTES    + BIT_STOP; end
                                            
        // Start Tx Process...               
        else if (nstate == ST_WR_CR_0    )   begin wr_req = 'h1; rd_req = 'h0;  seq_axi_addr <= REG_CR;       seq_axi_wdata <= 'h000D; end
                                            
        // Wait and Clear RX FIFO Full       
        else if (nstate == ST_CLR_ISR_4a  )   begin wr_req = 'h0; rd_req = 'h1;  seq_axi_addr <= REG_SR; end
        else if (nstate == ST_CLR_ISR_6a  )   begin wr_req = 'h0; rd_req = 'h1;  seq_axi_addr <= REG_SR; end
                                            
        // Read RX FIFO                      
        else if (nstate == ST_RD_RX_0    )   begin wr_req = 'h0; rd_req = 'h1;  seq_axi_addr <= REG_RXFIFO; end
        else if (nstate == ST_RD_RX_2    )   begin wr_req = 'h0; rd_req = 'h1;  seq_axi_addr <= REG_RXFIFO; end

    // -----------------------------------
    //  Write Operation...
        else if (nstate == ST_WR_TX_8    )   begin wr_req = 'h1; rd_req = 'h0;  seq_axi_addr <= REG_TXFIFO;  seq_axi_wdata <= IO_WDATA_WDATA + BIT_STOP; end
                                            
        // Set MSMS, Set Mode            
        else if (nstate == ST_WR_CR_2    )   begin wr_req = 'h1; rd_req = 'h0;  seq_axi_addr <= REG_CR;      seq_axi_wdata <= 'h0005; end
                                            
        // Wait and Clear TX FIFO Empty      
        else if (nstate == ST_CLR_ISR_8  )   begin wr_req = 'h0; rd_req = 'h1;  seq_axi_addr <= REG_SR; end
        else if (nstate == ST_CLR_ISR_A  )   begin wr_req = 'h0; rd_req = 'h1;  seq_axi_addr <= REG_SR; end
                                         
    // -----------------------------------
    // Disable                           
        else if (nstate == ST_WR_CR_6    )   begin wr_req = 'h1; rd_req = 'h0;  seq_axi_addr <= REG_CR;      seq_axi_wdata <= 'h0001; end
                                         
    else                                 begin wr_req = 'h0; rd_req = 'h0; end
end


// State change pulse used to gate wr/rd requests
reg [3:0] st_change;
always@(posedge aclk)
    if (!aresetn) st_change <= 'h0;
    else          st_change <= {st_change[2:0], (cstate != nstate)};

assign seq_axi_wr_req = wr_req & st_change[3];
assign seq_axi_rd_req = rd_req & st_change[3];


// ==============================================================
//   Response to user bus...

always@(posedge aclk)
begin
    if (!aresetn)
        IO_CONTROL_CMPLT <= 'h0;
    else if (IO_CONTROL_PULSE)
        IO_CONTROL_CMPLT <= 'h0;
    else if (nstate == ST_COMPLETE)
        IO_CONTROL_CMPLT <= 'h1;
end    

always@(posedge aclk)
begin
    if (!aresetn)
        IO_RDATA_RDATA <= 'h0;
    else if (seq_axi_ack && ( cstate == ST_RD_RX_0))
        IO_RDATA_RDATA <= seq_axi_rdata;
end    


endmodule

