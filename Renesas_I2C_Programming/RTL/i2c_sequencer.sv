/*
Copyright (C) 2024, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: X11
*/

// This module generates the AXI register accesses required by the Xilinx I2C IP
// to execute the individual high level register from the i2c_sequencer.

module i2c_sequencer #(
    parameter   AXI_ADDR_WIDTH = 32,
    parameter   AXI_DATA_WIDTH = 32
) (
    input  wire                       aclk             ,
    input  wire                       aresetn          ,

    input  wire                       start_pulse      ,

    // Request to axi master that interfaces with I2C IP...
    output wire                       seq_axi_wr_req   ,
    output wire                       seq_axi_rd_req   ,
    output reg  [AXI_ADDR_WIDTH-1:0]  seq_axi_addr     ,
    output reg  [AXI_DATA_WIDTH-1:0]  seq_axi_wdata    ,
    input  wire                       seq_axi_ack      ,
    input  wire [AXI_DATA_WIDTH-1:0]  seq_axi_rdata    ,

    output reg  [7:0]                 xfer_count       ,
    output reg  [31:0]                xfer_offset      ,
    output reg                        xfer_enable
);


// ----------------------------------------------------------------

localparam DEV_ID_OP       = 8'h01 ;
localparam SIZE_OP         = 8'h02 ;
localparam ADDR_OP         = 8'h04 ;
localparam WDATA_OP        = 8'h08 ;
localparam WDATA_LAST_OP   = 8'h10 ;
localparam FINISHED_OP     = 8'h80 ;

localparam DEV_ID_JC_1     = 8'hB0 ;
localparam DEV_ID_JC_2     = 8'hB2 ;

reg  [15:0] cmd_ptr;
wire [15:0] instru;

blk_mem_gen_0 blk_mem_gen_0(
    .clka   ( aclk    ),
    .ena    ( 1'b1    ),
    .wea    ( 1'b0    ),
    .addra  ( cmd_ptr ),
    .dina   ( 16'h0   ),
    .douta  ( instru  )
);

wire cmd_dev_id     = (instru[15:8] == DEV_ID_OP    );
wire cmd_size       = (instru[15:8] == SIZE_OP      );
wire cmd_addr       = (instru[15:8] == ADDR_OP      );
wire cmd_wdata      = (instru[15:8] == WDATA_OP     );
wire cmd_wdata_last = (instru[15:8] == WDATA_LAST_OP);
wire cmd_finished   = (instru[15:8] == FINISHED_OP  );

// ==============================================================

reg [7:0]  io_size  ;
reg [7:0]  io_devid ;
reg [7:0]  io_addr  ;
reg        io_rw    ;

wire timer_zero;

// ==============================================================


typedef enum {
    ST_RST            ,
    ST_START          ,
    ST_DONE           ,
    ST_DELAY          ,
    ST_DELAY0         ,
    ST_NEXT           ,

    ST_DEV_ID         ,
    ST_SIZE           ,
    ST_ADDR           ,

    ST_INIT_CLR_ISR_0 ,
    ST_INIT_CLR_ISR_1 ,
    ST_INIT_RX_PIRQ_0 ,
    ST_INIT_TX_DEV_ID ,
    ST_INIT_TX_ADDR   ,

    ST_WR_TX_FIFO_0   ,
    ST_WR_TX_FIFO_1   ,
    ST_WR_WDATA       ,
    ST_WR_WDATA_LAST  ,
    ST_WR_CR_2        ,
    ST_WR_CLR_ISR_0   ,
    ST_WR_CLR_ISR_1   ,
    ST_WR_CLR_ISR_2   ,
    ST_WR_CLR_ISR_3   ,
    ST_WR_CR_6

} e_state;

e_state cstate;
e_state nstate;

always@(posedge aclk)
    if (!aresetn) cstate <= ST_RST;
    else          cstate <= nstate;

always@(*)
begin
    nstate = cstate;
    case (cstate)
        ST_RST        : if (start_pulse) nstate = ST_START ;

        ST_START      : if      ( cmd_dev_id     ) nstate = ST_DEV_ID;
                        else if ( cmd_size       ) nstate = ST_SIZE;
                        else if ( cmd_addr       ) nstate = ST_ADDR;
                        else if ( cmd_wdata      ) nstate = ST_WR_TX_FIFO_0;
                        else if ( cmd_wdata_last ) nstate = ST_WR_TX_FIFO_0;
                        else if ( cmd_finished   ) nstate = ST_DONE;

        // Load Dev ID and RW...
        ST_DEV_ID     : nstate = ST_NEXT  ;

        // Load Txfer Size...
        ST_SIZE       : nstate = ST_NEXT  ;

        // Load Addr and start I2C Initialization Sequence...
        ST_ADDR       : nstate = ST_INIT_CLR_ISR_0  ; 

        // Sequence is finished, wait here...
        ST_DONE       : nstate = ST_DONE ;

        // -----------------------------------
        //  Setup Operations...

        // Clear ISR...
        ST_INIT_CLR_ISR_0     : if (seq_axi_ack) nstate = ST_INIT_CLR_ISR_1;
        ST_INIT_CLR_ISR_1     : if (seq_axi_ack) nstate = ST_INIT_RX_PIRQ_0;

        // Set RX FIFO Depth
        ST_INIT_RX_PIRQ_0     : if (seq_axi_ack) nstate = ST_INIT_TX_DEV_ID;

        // Program TXFIFO Dev ID (bit 8 is start bit)
        ST_INIT_TX_DEV_ID     : if (seq_axi_ack) nstate = ST_INIT_TX_ADDR;

        // Program TXFIFO Reg Addr
        ST_INIT_TX_ADDR       : if (seq_axi_ack) nstate = ST_WR_CR_2; // get it started

        // Start write operation...
        // Set MSMS, Set Mode
        ST_WR_CR_2          : if (seq_axi_ack) nstate = ST_NEXT;



        // -----------------------------------
        //  Write Operations...

        // Wait for TX FIFO not full
        ST_WR_TX_FIFO_0     : if      (seq_axi_ack && ((seq_axi_rdata & 'h10) == 'h10) ) nstate = ST_WR_TX_FIFO_1  ; // Full, wait some more.
                              else if (seq_axi_ack && cmd_wdata                        ) nstate = ST_WR_WDATA      ; // Not full, more data
                              else if (seq_axi_ack && cmd_wdata_last                   ) nstate = ST_WR_WDATA_LAST ; // Not full, last data
        // FIFO is full, so check again...
        ST_WR_TX_FIFO_1     : nstate = ST_WR_TX_FIFO_0;


        // Program TXFIFO TX Bytes (bit 9 is stop bit)
        ST_WR_WDATA         : if (seq_axi_ack) nstate = ST_NEXT;

        // Last wdata byte, follow up with monitoring the xfer...
        ST_WR_WDATA_LAST    : if (seq_axi_ack) nstate = ST_WR_CLR_ISR_0; //ST_WR_CR_2;

        // Wait for TX FIFO EMPTY
        //  -- wait for busy
        ST_WR_CLR_ISR_0     : if      (seq_axi_ack && ((seq_axi_rdata & 'h4) == 'h4) ) nstate = ST_WR_CLR_ISR_2;
                              else if (seq_axi_ack                                   ) nstate = ST_WR_CLR_ISR_1;
        ST_WR_CLR_ISR_1     : nstate = ST_WR_CLR_ISR_0;

        //  -- wait for not busy
        ST_WR_CLR_ISR_2     : if      (seq_axi_ack && ((seq_axi_rdata & 'h4) == 'h0) ) nstate = ST_WR_CR_6;
                              else if (seq_axi_ack                                   ) nstate = ST_WR_CLR_ISR_3;
        ST_WR_CLR_ISR_3     : nstate = ST_WR_CLR_ISR_2;

        //  -- disable i2c
        ST_WR_CR_6          : if (seq_axi_ack) nstate = ST_DELAY;


        // -----------------------------------

        // End of sequence, delay a bit before starting the next one...
        ST_DELAY      : nstate = ST_DELAY0 ;
        ST_DELAY0     : if ( timer_zero ) nstate = ST_NEXT ;

        // Go to next step...
        ST_NEXT       : nstate = ST_START ;

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
    if (!aresetn) begin wr_req = 'h0; rd_req = 'h0; end

    // -----------------------------------
    //  Setup...

        // Clear ISR...
        else if (nstate == ST_INIT_CLR_ISR_0  )   begin wr_req = 'h0; rd_req = 'h1;  seq_axi_addr <= REG_ISR; end
        else if (nstate == ST_INIT_CLR_ISR_1  )   begin wr_req = 'h1; rd_req = 'h0;  seq_axi_addr <= REG_ISR; seq_axi_wdata <= seq_axi_rdata; end

        // Set Rx FIFO Depth
        else if (nstate == ST_INIT_RX_PIRQ_0  )   begin wr_req = 'h1; rd_req = 'h0;  seq_axi_addr <= REG_RX_PIRQ;  seq_axi_wdata <= RD_BYTES-1; end

        // Write DevID + Wr, Reg Addr
        else if (nstate == ST_INIT_TX_DEV_ID  )   begin wr_req = 'h1; rd_req = 'h0;  seq_axi_addr <= REG_TXFIFO;   seq_axi_wdata <= io_devid  + BIT_START; end
        else if (nstate == ST_INIT_TX_ADDR    )   begin wr_req = 'h1; rd_req = 'h0;  seq_axi_addr <= REG_TXFIFO;   seq_axi_wdata <= io_addr; end

    // -----------------------------------
    //  Write Operations...
        // Wait for TX FIFO not full
        else if (nstate == ST_WR_TX_FIFO_0    )   begin wr_req = 'h0; rd_req = 'h1;  seq_axi_addr <= REG_SR; end

        else if (nstate == ST_WR_WDATA        )   begin wr_req = 'h1; rd_req = 'h0;  seq_axi_addr <= REG_TXFIFO;  seq_axi_wdata <= instru[7:0]; end

        else if (nstate == ST_WR_WDATA_LAST   )   begin wr_req = 'h1; rd_req = 'h0;  seq_axi_addr <= REG_TXFIFO;  seq_axi_wdata <= instru[7:0] + BIT_STOP; end

        // Set MSMS, Set Mode
        else if (nstate == ST_WR_CR_2         )   begin wr_req = 'h1; rd_req = 'h0;  seq_axi_addr <= REG_CR;      seq_axi_wdata <= 'h0005; end

        // Wait and Clear TX FIFO Empty
        else if (nstate == ST_WR_CLR_ISR_0    )   begin wr_req = 'h0; rd_req = 'h1;  seq_axi_addr <= REG_SR; end
        else if (nstate == ST_WR_CLR_ISR_2    )   begin wr_req = 'h0; rd_req = 'h1;  seq_axi_addr <= REG_SR; end

    // -----------------------------------
    // Disable
        else if (nstate == ST_WR_CR_6         )   begin wr_req = 'h1; rd_req = 'h0;  seq_axi_addr <= REG_CR;      seq_axi_wdata <= 'h0001; end

    else begin wr_req = 'h0; rd_req = 'h0; end
end


always@(posedge aclk)
begin
    if (!aresetn)
        cmd_ptr <= 'h0;
    else if (nstate == ST_NEXT)
        cmd_ptr <= cmd_ptr + 1;
end

always@(posedge aclk)
begin
    if (!aresetn) begin
        io_devid <= 'h0;
        io_rw    <= 'h0;
    end else if (nstate == ST_DEV_ID) begin
        io_devid <= instru[7:0];
        io_rw    <= instru[0];
    end
end

always@(posedge aclk)
begin
    if (!aresetn)
        io_size <= 'h0;
    else if (nstate == ST_SIZE)
        io_size <= instru[7:0];
end

always@(posedge aclk)
begin
    if (!aresetn)
        io_addr <= 'h0;
    else if (nstate == ST_ADDR)
        io_addr <= instru[7:0];
end


always@(posedge aclk)
begin
    if (!aresetn)
        xfer_count <= 'h0;
    else if (nstate == ST_RST)
        xfer_count <= 'h0;
    else if ((cstate == ST_WR_CR_2) && seq_axi_ack)
        xfer_count <= xfer_count + 1;
end

always@(posedge aclk)
begin
    if (!aresetn)
        xfer_enable <= 'h0;
    else if (nstate == ST_RST)
        xfer_enable <= 'h0;
    else if (nstate == ST_WR_CR_2)
        xfer_enable <= 'h1;
    else if (nstate == ST_DELAY)
        xfer_enable <= 'h0;
end

always@(posedge aclk)
begin
    if (!aresetn)
        xfer_offset <= 'h0;
    else if (xfer_enable == 'h0)
        xfer_offset <= 'h0;
    else if (xfer_enable == 'h1)
        xfer_offset <= xfer_offset + 1;
end

// ----------------------------------------------------------------

reg [15:0] timer;
always@(posedge aclk)
begin
    if (!aresetn)
        timer <= 'h0;
    else if (nstate == ST_DELAY)
        timer <= 'h1000;
    else
        timer <= timer - 1;
end

assign timer_zero = (timer == 'h0);

// ----------------------------------------------------------------

// State change pulse used to gate wr/rd requests
reg [3:0] st_change;
always@(posedge aclk)
    if (!aresetn) st_change <= 'h0;
    else          st_change <= {st_change[2:0], (cstate != nstate)};

assign seq_axi_wr_req = wr_req & st_change[3];
assign seq_axi_rd_req = rd_req & st_change[3];


// ----------------------------------------------------------------

wire sim_finished = (nstate == ST_DONE) && (cstate != ST_DONE);

//reg dbg_fifo_full;
//always@(posedge aclk)
//    if (!aresetn)                        dbg_fifo_full <= 'h0;
//    else if (nstate == ST_WR_TX_FIFO_1)  dbg_fifo_full <= 'h1;
//    else if (nstate == ST_WR_WDATA)      dbg_fifo_full <= 'h0;
//    else if (nstate == ST_WR_WDATA_LAST) dbg_fifo_full <= 'h0;
    
endmodule




        //// -----------------------------------
        ////  Read Operation...
        //
        //    // Program TXFIFO Dev ID (bit 8 is repeated start)
        //    ST_WR_TX_4       : if (seq_axi_ack) nstate = ST_WR_TX_6;
        //
        //    // Program TXFIFO RX Bytes (bit 9 is stop bit)
        //    ST_WR_TX_6       : if (seq_axi_ack) nstate = ST_WR_CR_0;
        //
        //    // Set MSMS, Set Mode
        //    ST_WR_CR_0       : if (seq_axi_ack) nstate = ST_CLR_ISR_4;
        //
        //    // Wait for RX FIFO FULL
        //    //  -- wait for busy
        //    ST_CLR_ISR_4     : nstate = ST_CLR_ISR_4a;
        //    ST_CLR_ISR_4a    : if      (seq_axi_ack && ((seq_axi_rdata & 'h4) == 'h4) ) nstate = ST_CLR_ISR_6;
        //                       else if (seq_axi_ack                                   ) nstate = ST_CLR_ISR_4;
        //
        //    //  -- wait rx not empty
        //    ST_CLR_ISR_6     : nstate = ST_CLR_ISR_6a;
        //    ST_CLR_ISR_6a    : if      (seq_axi_ack && ((seq_axi_rdata & 'h4C) == 'h0C) ) nstate = ST_RD_RX_0;
        //                       else if (seq_axi_ack                                     ) nstate = ST_CLR_ISR_6;
        //
        //    // Read RX FIFO
        //    ST_RD_RX_0       : if (seq_axi_ack) nstate = ST_WR_CR_6;
        //    //ST_RD_RX_2       : nstate = ST_RD_RX_3;
        //    //ST_RD_RX_3       : if (seq_axi_ack) nstate = ST_WR_CR_6;
        //
        //// -----------------------------------
        //// Disable...
        //    ST_WR_CR_6       : if (seq_axi_ack) nstate = ST_COMPLETE;
        //
        //    ST_COMPLETE      : nstate = ST_IDLE;




    //// -----------------------------------
    ////  Read Operation...
    //    else if (nstate == ST_WR_TX_4    )   begin wr_req = 'h1; rd_req = 'h0;  seq_axi_addr <= REG_TXFIFO;   seq_axi_wdata <= io_devid + BIT_START + BIT_RD; end
    //    else if (nstate == ST_WR_TX_6    )   begin wr_req = 'h1; rd_req = 'h0;  seq_axi_addr <= REG_TXFIFO;   seq_axi_wdata <= RD_BYTES    + BIT_STOP; end
    //
    //    // Start Tx Process...
    //    else if (nstate == ST_WR_CR_0    )   begin wr_req = 'h1; rd_req = 'h0;  seq_axi_addr <= REG_CR;       seq_axi_wdata <= 'h000D; end
    //
    //    // Wait and Clear RX FIFO Full
    //    else if (nstate == ST_CLR_ISR_4a  )   begin wr_req = 'h0; rd_req = 'h1;  seq_axi_addr <= REG_SR; end
    //    else if (nstate == ST_CLR_ISR_6a  )   begin wr_req = 'h0; rd_req = 'h1;  seq_axi_addr <= REG_SR; end
    //
    //    // Read RX FIFO
    //    else if (nstate == ST_RD_RX_0    )   begin wr_req = 'h0; rd_req = 'h1;  seq_axi_addr <= REG_RXFIFO; end
    //    else if (nstate == ST_RD_RX_2    )   begin wr_req = 'h0; rd_req = 'h1;  seq_axi_addr <= REG_RXFIFO; end
