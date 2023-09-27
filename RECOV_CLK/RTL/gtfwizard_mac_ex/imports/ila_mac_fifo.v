/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

module ila_mac_fifo_top #(
    parameter ENABLE_ILA_MAC_FIFO = 0
)(
    input       wire            axi_aclk                 ,
    input       wire            fifo_rst                 ,
    input       wire            fifo_rst_status          ,
    output      wire            fifo_rd_fcs_error_pif    ,
    output      reg  [31:0]     fifo_rd_err_count        ,

    output      reg             fifo_rx_err_overflow     ,
    output      reg             fifo_rx_err_underflow    ,
    output      reg  [31:0]     fifo_rx_wr_count         ,

    output      reg             fifo_tx_err_overflow     ,
    output      reg             fifo_tx_err_underflow    ,
    output      reg  [31:0]     fifo_tx_wr_count         ,

    ////////////////////////////////////////////////////////////////
    // TX Interface
    ////////////////////////////////////////////////////////////////

    input       wire            tx_clk                   ,
    input       wire            tx_rst                   ,

    input       wire            tx_axis_tready           ,
    input       wire            tx_axis_tvalid           ,
    input       wire [63:0]     tx_axis_tdata            ,
    input       wire [7:0]      tx_axis_tlast            ,
    input       wire [1:0]      tx_axis_tsof             ,
    input       wire            tx_axis_tcan_start       ,

    ////////////////////////////////////////////////////////////////
    // RX Interface
    ////////////////////////////////////////////////////////////////

    input       wire            rx_clk                   ,
    input       wire            rx_rst                   ,

    input       wire            rx_axis_tvalid           ,
    input       wire [63:0]     rx_axis_tdata            ,
    input       wire [7:0]      rx_axis_tlast            ,
    input       wire [1:0]      rx_axis_tsof             ,

    ////////////////////////////////////////////////////////////////
    // RD CLOCK
    ////////////////////////////////////////////////////////////////

    input       wire            fifo_rd_fifo_clk         ,

    input       wire            mon_clk                  ,
    input       wire            fcs_crc_bad

);


    ////////////////////////////////////////////////////////////////
    // Reset Sync's....
    ////////////////////////////////////////////////////////////////

    // Resets for three domains accessing the data stream FIFOs and comparator...
    wire fifo_rst_sync_tx;
    gtfmac_hwchk_syncer_pulse i_sync_fifo_rst_tx (
       .clkin        (axi_aclk),
       .clkin_reset  (1'b1),
       .clkout       (tx_clk),
       .clkout_reset (1'b1),
       .pulsein      (fifo_rst_status),
       .pulseout     (fifo_rst_sync_tx)
    );

    wire fifo_rst_sync_rx;
    gtfmac_hwchk_syncer_pulse i_sync_fifo_rst_rx (
       .clkin        (axi_aclk),
       .clkin_reset  (1'b1),
       .clkout       (rx_clk),
       .clkout_reset (1'b1),
       .pulsein      (fifo_rst_status),
       .pulseout     (fifo_rst_sync_rx)
    );

    wire fifo_rst_sync_rd;
    gtfmac_hwchk_syncer_pulse i_sync_fifo_rst (
       .clkin        (axi_aclk),
       .clkin_reset  (1'b1),
       .clkout       (fifo_rd_fifo_clk),
       .clkout_reset (1'b1),
       .pulsein      (fifo_rst_status),
       .pulseout     (fifo_rst_sync_rd)
    );

    wire        fifo_rd_fcs_rden    ;

    ////////////////////////////////////////////////////////////////
    // TX Interface
    ////////////////////////////////////////////////////////////////

    reg            r0_tx_axis_tready     ;
    reg            r0_tx_axis_tvalid     ;
    reg [15:0]     r0_tx_axis_tdata      ;
    reg [7:0]      r0_tx_axis_tlast      ;
    reg [1:0]      r0_tx_axis_tsof       ;
    reg            r0_tx_axis_tcan_start ;

    reg            r1_tx_axis_tready     ;
    reg            r1_tx_axis_tvalid     ;
    reg [15:0]     r1_tx_axis_tdata      ;
    reg [7:0]      r1_tx_axis_tlast      ;
    reg [1:0]      r1_tx_axis_tsof       ;
    reg            r1_tx_axis_tcan_start ;

    always@(posedge tx_clk)
    begin
        if (tx_rst) begin
            r0_tx_axis_tready     = 'h0;
            r0_tx_axis_tvalid     = 'h0;
            r0_tx_axis_tdata      = 'h0;
            r0_tx_axis_tlast      = 'h0;
            r0_tx_axis_tsof       = 'h0;
            r0_tx_axis_tcan_start = 'h0;
        end else begin
            r0_tx_axis_tready     = tx_axis_tready      ;
            r0_tx_axis_tvalid     = tx_axis_tvalid      ;
            r0_tx_axis_tdata      = tx_axis_tdata[15:0] ;
            r0_tx_axis_tlast      = tx_axis_tlast       ;
            r0_tx_axis_tsof       = tx_axis_tsof        ;
            r0_tx_axis_tcan_start = tx_axis_tcan_start  ;
        end
    end

    reg r1_tx_axis_tdata_df1c ;
    reg r1_tx_axis_tdata_2144 ;

    always@(posedge tx_clk)
    begin
        if (tx_rst) begin
            r1_tx_axis_tdata_df1c = 'h0;
            r1_tx_axis_tdata_2144 = 'h0;
            r1_tx_axis_tready     = 'h0;
            r1_tx_axis_tvalid     = 'h0;
            r1_tx_axis_tdata      = 'h0;
            r1_tx_axis_tlast      = 'h0;
            r1_tx_axis_tsof       = 'h0;
            r1_tx_axis_tcan_start = 'h0;
        end else begin
            r1_tx_axis_tdata_df1c = (r0_tx_axis_tdata == 'hdf1c);
            r1_tx_axis_tdata_2144 = (r0_tx_axis_tdata == 'h2144);
            r1_tx_axis_tready     = r0_tx_axis_tready    ;
            r1_tx_axis_tvalid     = r0_tx_axis_tvalid    ;
            r1_tx_axis_tdata      = r0_tx_axis_tdata     ;
            r1_tx_axis_tlast      = r0_tx_axis_tlast     ;
            r1_tx_axis_tsof       = r0_tx_axis_tsof      ;
            r1_tx_axis_tcan_start = r0_tx_axis_tcan_start;
        end
    end

    reg [3:0]  r2_tx_dm;
    reg        r2_tx_axis_tvalid ;
    reg [63:0] r2_tx_axis_tdata  ;

    always@(posedge tx_clk)
    begin
        if ( fifo_rst_sync_tx ) begin
            r2_tx_axis_tvalid <= 'h0;
            r2_tx_axis_tdata  <= 'h0;
            r2_tx_dm          <= 'h1;
        end else if ( r1_tx_axis_tready      &&
                      r1_tx_axis_tvalid      &&
                      ~r1_tx_axis_tdata_df1c &&
                      ~r1_tx_axis_tdata_2144 ) begin
            r2_tx_dm          <= {r2_tx_dm[2:0], r2_tx_dm[3]};
            r2_tx_axis_tvalid <= 'h1;
            if (r2_tx_dm[0]) r2_tx_axis_tdata[15:0]  <= r1_tx_axis_tdata[15:0] ;
            if (r2_tx_dm[1]) r2_tx_axis_tdata[31:16] <= r1_tx_axis_tdata[15:0] ;
            if (r2_tx_dm[2]) r2_tx_axis_tdata[47:32] <= r1_tx_axis_tdata[15:0] ;
            if (r2_tx_dm[3]) r2_tx_axis_tdata[63:48] <= r1_tx_axis_tdata[15:0] ;
        end else begin
            r2_tx_axis_tvalid <= 'h0;
        end
    end

    wire        fifo_tx_fcs_full    ;
    wire        fifo_tx_fcs_empty   ;
    wire [69:0] fifo_rd_fcs_data_tx ;

    fifo_mac_data_sync fifo_mac_data_sync_tx (
        .rst         ( fifo_rst                        ),
        .wr_clk      ( tx_clk                          ),
        .din         ( { 6'h0 ,
                         r2_tx_axis_tdata }            ),
        .wr_en       ( r2_tx_axis_tvalid & r2_tx_dm[0] ),
        .full        ( fifo_tx_fcs_full                ),

        .rd_clk      ( fifo_rd_fifo_clk                ),
        .rd_en       ( fifo_rd_fcs_rden                ),
        .dout        ( fifo_rd_fcs_data_tx             ),
        .empty       ( fifo_tx_fcs_empty               ),

        .wr_rst_busy (                                 ),
        .rd_rst_busy (                                 )
    );


    ////////////////////////////////////////////////////////////////
    // RX Interface
    ////////////////////////////////////////////////////////////////

    reg            r0_rx_axis_tvalid     ;
    reg [15:0]     r0_rx_axis_tdata      ;
    reg [7:0]      r0_rx_axis_tlast      ;
    reg [1:0]      r0_rx_axis_tsof       ;

    reg            r1_rx_axis_tvalid     ;
    reg [15:0]     r1_rx_axis_tdata      ;
    reg [7:0]      r1_rx_axis_tlast      ;
    reg [1:0]      r1_rx_axis_tsof       ;

    always@(posedge rx_clk)
    begin
        if (rx_rst) begin
            r0_rx_axis_tvalid     = 'h0;
            r0_rx_axis_tdata      = 'h0;
            r0_rx_axis_tlast      = 'h0;
            r0_rx_axis_tsof       = 'h0;
        end else begin
            r0_rx_axis_tvalid     = rx_axis_tvalid      ;
            r0_rx_axis_tdata      = rx_axis_tdata[15:0] ;
            r0_rx_axis_tlast      = rx_axis_tlast       ;
            r0_rx_axis_tsof       = rx_axis_tsof        ;
        end
    end

    reg r1_rx_axis_tdata_df1c ;
    reg r1_rx_axis_tdata_2144 ;

    always@(posedge rx_clk)
    begin
        if (rx_rst) begin
            r1_rx_axis_tdata_df1c = 'h0;
            r1_rx_axis_tdata_2144 = 'h0;
            r1_rx_axis_tvalid     = 'h0;
            r1_rx_axis_tdata      = 'h0;
            r1_rx_axis_tlast      = 'h0;
            r1_rx_axis_tsof       = 'h0;
        end else begin
            r1_rx_axis_tdata_df1c = (r0_rx_axis_tdata == 'hdf1c);
            r1_rx_axis_tdata_2144 = (r0_rx_axis_tdata == 'h2144);
            r1_rx_axis_tvalid     = r0_rx_axis_tvalid    ;
            r1_rx_axis_tdata      = r0_rx_axis_tdata     ;
            r1_rx_axis_tlast      = r0_rx_axis_tlast     ;
            r1_rx_axis_tsof       = r0_rx_axis_tsof      ;
        end
    end

    reg [3:0]  r2_rx_dm;
    reg        r2_rx_axis_tvalid ;
    reg [63:0] r2_rx_axis_tdata  ;

    always@(posedge rx_clk)
    begin
        if ( fifo_rst_sync_rx ) begin
            r2_rx_axis_tvalid <= 'h0;
            r2_rx_axis_tdata  <= 'h0;
            r2_rx_dm          <= 'h1;
        end else if ( r1_rx_axis_tvalid      &&
                      ~r1_rx_axis_tdata_df1c &&
                      ~r1_rx_axis_tdata_2144 ) begin
            r2_rx_dm          <= {r2_rx_dm[2:0], r2_rx_dm[3]};
            r2_rx_axis_tvalid <= 'h1;
            if (r2_rx_dm[0]) r2_rx_axis_tdata[15:0]  <= r1_rx_axis_tdata[15:0] ;
            if (r2_rx_dm[1]) r2_rx_axis_tdata[31:16] <= r1_rx_axis_tdata[15:0] ;
            if (r2_rx_dm[2]) r2_rx_axis_tdata[47:32] <= r1_rx_axis_tdata[15:0] ;
            if (r2_rx_dm[3]) r2_rx_axis_tdata[63:48] <= r1_rx_axis_tdata[15:0] ;
        end else begin
            r2_rx_axis_tvalid <= 'h0;
        end
    end

    wire        fifo_rx_fcs_full    ;
    wire        fifo_rx_fcs_empty   ;
    wire [69:0] fifo_rd_fcs_data_rx ;

    fifo_mac_data_sync fifo_mac_data_sync_rx (
        .rst         ( fifo_rst                        ),
        .wr_clk      ( rx_clk                          ),
        .din         ( { 6'h0 ,
                         r2_rx_axis_tdata }            ),
        .wr_en       ( r2_rx_axis_tvalid & r2_rx_dm[0] ),
        .full        ( fifo_rx_fcs_full                ),

        .rd_clk      ( fifo_rd_fifo_clk                ),
        .rd_en       ( fifo_rd_fcs_rden                ),
        .dout        ( fifo_rd_fcs_data_rx             ),
        .empty       ( fifo_rx_fcs_empty               ),

        .wr_rst_busy (                                 ),
        .rd_rst_busy (                                 )
    );


    ////////////////////////////////////////////////////////////////
    // RD Interface
    ////////////////////////////////////////////////////////////////


	// Control logic to read and compare TX/RX data from the two FIFOS...
    assign fifo_rd_fcs_rden = ( !fifo_tx_fcs_empty && !fifo_rx_fcs_empty);

    reg fifo_rd_fcs_rden_r;
    always@(posedge fifo_rd_fifo_clk)
    begin
        if (fifo_rst_sync_rd)
            fifo_rd_fcs_rden_r <= 'h0;
        else
            fifo_rd_fcs_rden_r <= fifo_rd_fcs_rden;
    end


    reg fcs_crc_bad_0;
    reg fcs_crc_bad_1;
    reg fcs_crc_bad_2;
    reg fcs_crc_bad_3;
    always@(posedge mon_clk)
    begin
        fcs_crc_bad_3 <= fcs_crc_bad;
        fcs_crc_bad_0 <= fcs_crc_bad_3;
        fcs_crc_bad_1 <= fcs_crc_bad_0;
        fcs_crc_bad_2 <= fcs_crc_bad_0 & ~fcs_crc_bad_1;
    end

    reg [31:0] fifo_rd_fcs_count;
    reg        fifo_rd_fcs_error;

generate
if( ENABLE_ILA_MAC_FIFO == 1 ) begin
    ila_mac_fifo ila_mac_fifo (
        .clk        ( fifo_rd_fifo_clk          ), // 425 Mhz
        .probe0     ( fifo_rst_sync_rd          ), // 1b

        .probe1     ( fifo_rd_fcs_rden          ), // 1b
        .probe2     ( fifo_rd_fcs_count         ), // 32b
        .probe3     ( fcs_crc_bad_2             ), // 1b
        .probe4     ( fifo_rd_fcs_error         ), // 1b

        .probe5     ( 1'h0                      ), // 1b
        .probe6     ( 1'h0                      ), // 1b
        .probe7     ( 3'h0                      ), // 3b
        .probe8     ( fifo_rd_fcs_data_tx[63:0] ), // 64b

        .probe9     ( 1'h0                      ), // 1b
        .probe10    ( 1'h0                      ), // 1b
        .probe11    ( 3'h0                      ), // 3b
        .probe12    ( fifo_rd_fcs_data_rx[63:0] )  // 64b
    );
end
endgenerate

    ////////////////////////////////////////////////////////////////
    // Status
    ////////////////////////////////////////////////////////////////

    // Status registers for TX stream side (word count, overflow latch, underflow latch)
    always@(posedge tx_clk)
    begin
        if(fifo_rst_sync_tx)
            fifo_tx_wr_count <= 'h0;
        else if (r2_tx_axis_tvalid & r2_tx_dm[0])
            fifo_tx_wr_count <= fifo_tx_wr_count + 1;
    end

    always@(posedge tx_clk)
    begin
        if(fifo_rst_sync_tx)
            fifo_tx_err_overflow <= 'h0;
        else if (r2_tx_axis_tvalid & r2_tx_dm[0] && fifo_tx_fcs_full)
            fifo_tx_err_overflow <= 1'b1;
    end

    always@(posedge fifo_rd_fifo_clk)
    begin
        if(fifo_rst_sync_rd)
            fifo_tx_err_underflow <= 'h0;
        else if (fifo_rd_fcs_rden && fifo_tx_fcs_empty)
            fifo_tx_err_underflow <= 1'b1;
    end


    // Status registers for RX stream side (word count, overflow latch, underflow latch)
    always@(posedge rx_clk)
    begin
        if(fifo_rst_sync_rx)
            fifo_rx_wr_count <= 'h0;
        else if (r2_rx_axis_tvalid & r2_rx_dm[0])
            fifo_rx_wr_count <= fifo_rx_wr_count + 1;
    end

    always@(posedge rx_clk)
    begin
        if(fifo_rst_sync_rx)
            fifo_rx_err_overflow <= 'h0;
        else if (r2_rx_axis_tvalid & r2_rx_dm[0] && fifo_rx_fcs_full)
            fifo_rx_err_overflow <= 1'b1;
    end

    always@(posedge fifo_rd_fifo_clk)
    begin
        if(fifo_rst_sync_rd)
            fifo_rx_err_underflow <= 'h0;
        else if (fifo_rd_fcs_rden && fifo_rx_fcs_empty)
            fifo_rx_err_underflow <= 1'b1;
    end



    // Status registers for RD stream side
    always@(posedge fifo_rd_fifo_clk)
    begin
        if (fifo_rst_sync_rd)
            fifo_rd_fcs_count <= 'h0;
        else if (fifo_rd_fcs_rden )
            fifo_rd_fcs_count <= fifo_rd_fcs_count + 1;
    end

    always@(posedge fifo_rd_fifo_clk)
    begin
        if (fifo_rst_sync_rd)
            fifo_rd_fcs_error <= 'h0;
        else if (fifo_rd_fcs_rden_r )
            fifo_rd_fcs_error <= fifo_rd_fcs_error | (fifo_rd_fcs_data_tx != fifo_rd_fcs_data_rx);
        else
            fifo_rd_fcs_error <= 'h0;
    end

    assign fifo_rd_fcs_error_pif = fifo_rd_fcs_error;

    always@(posedge fifo_rd_fifo_clk)
    begin
        if (fifo_rst_sync_rd)
            fifo_rd_err_count <= 'h0;
        else if (fifo_rd_err_count == 'hFFFF )
            fifo_rd_err_count <= 'hFFFF;
        else if (fifo_rd_fcs_error )
            fifo_rd_err_count <= fifo_rd_err_count + 1;
    end

endmodule
