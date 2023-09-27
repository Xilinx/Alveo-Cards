/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

module gtf_top_1 # (
    parameter  integer     NUM_CHANNEL = 1
) (
    output wire  [NUM_CHANNEL-1:0]  gtf_ch_gtftxn      ,
    output wire  [NUM_CHANNEL-1:0]  gtf_ch_gtftxp      ,
    input  wire  [NUM_CHANNEL-1:0]  gtf_ch_gtfrxn      ,
    input  wire  [NUM_CHANNEL-1:0]  gtf_ch_gtfrxp      ,

    // Input differential SYNCE clock
    input  wire                     SYNCE_CLK_LVDS_P   ,
    input  wire                     SYNCE_CLK_LVDS_N   ,
    // Single ended SYNCE clock for freq measurement
    output wire                     SYNCE_CLK_OUT      ,

    // Freerunning 200Mhz, 425Mhz system clock and reset
    input  wire                     gtf_freerun_clk    ,
    input  wire                     gtf_sys_clk_out    ,
    input  wire                     gtf_clk_wiz_locked ,

    // Freerunning 100Mhz system clock and reset
    input  wire                     sys_if_clk         ,   
    input  wire                     sys_if_rstn        ,
    
    // User GTF Reset...
    input  wire                     sys_gtf_resetn     ,

    // JTAG/AXI Interface
    output wire                     s_axil_aclk        ,
    output wire                     s_axil_aresetn     ,
    input  wire [31:0]              s_axil_awaddr      ,
    input  wire [2:0]               s_axil_awprot      ,
    input  wire                     s_axil_awvalid     ,
    output wire                     s_axil_awready     ,
    input  wire [31:0]              s_axil_wdata       ,
    input  wire [3:0]               s_axil_wstrb       ,
    input  wire                     s_axil_wvalid      ,
    output wire                     s_axil_wready      ,
    output wire [1:0]               s_axil_bresp       ,
    output wire                     s_axil_bvalid      ,
    input  wire                     s_axil_bready      ,
    input  wire [31:0]              s_axil_araddr      ,
    input  wire [2:0]               s_axil_arprot      ,
    input  wire                     s_axil_arvalid     ,
    output wire                     s_axil_arready     ,
    output wire [31:0]              s_axil_rdata       ,
    output wire [1:0]               s_axil_rresp       ,
    output wire                     s_axil_rvalid      ,
    input  wire                     s_axil_rready      
    
    // Differential SYNCE clock to I/O if desired
    //output wire                     RECOV_CLK10_INT    ,
    //output wire                     RECOV_CLK10_LVDS_P ,
    //output wire                     RECOV_CLK10_LVDS_N 

);

//-----------------------------------------------
// Simple delayed system reset...

wire clk_wiz_locked_out_sync;
syncer_level #(
    .WIDTH       ( 1    ),
    .RESET_VALUE ( 1'b0 )
) syncer_level_clk_locked (
    .clk     ( gtf_freerun_clk         ),
    .resetn  ( sys_if_rstn             ),
    .datain  ( gtf_clk_wiz_locked      ),
    .dataout ( clk_wiz_locked_out_sync )
);

reg [31:0] timer;
always@(posedge gtf_freerun_clk)
begin
    if (!clk_wiz_locked_out_sync)
        timer <= 100;
    else if (timer == 'h0)
        timer <= 'h0;
    else
        timer <= timer - 1;
end

wire timer_ne_0 = ~(timer == 0);

wire hb_gtwiz_reset_all_in ;  // active high reset
syncer_level #(
    .WIDTH       ( 1    ),
    .RESET_VALUE ( 1'b1 )
) syncer_level_reset (
    .clk     ( gtf_freerun_clk            ),
    .resetn  ( sys_gtf_resetn             ),
    .datain  ( timer_ne_0                 ),
    .dataout ( hb_gtwiz_reset_all_in      )
);

//-----------------------------------------------
// Auto reset for channel rx/tx datapaths

reg [15:0] rst_timer = 1000;
always@(posedge gtf_freerun_clk)
begin
    if (hb_gtwiz_reset_all_in)
        rst_timer <= 1000;
    else if (rst_timer == 0) 
        rst_timer <= 'h0;
    else
        rst_timer <= rst_timer - 1;
end
wire rst_timer_eq_1 = (rst_timer == 'h1);

reg  [NUM_CHANNEL-1:0] hb_gtf_ch_txdp_reset_in;
reg  [NUM_CHANNEL-1:0] hb_gtf_ch_rxdp_reset_in;

genvar jj;
generate
for (jj=0; jj<NUM_CHANNEL; jj=jj+1) begin : gen_gtf_ch_reset_in

    initial begin
    hb_gtf_ch_txdp_reset_in[jj] = 1'b1;
    hb_gtf_ch_rxdp_reset_in[jj] = 1'b1;
    end
    
    always@(posedge gtf_freerun_clk)
    begin
        if (hb_gtwiz_reset_all_in) begin
            hb_gtf_ch_txdp_reset_in[jj] <= 1'b1;
            hb_gtf_ch_rxdp_reset_in[jj] <= 1'b1;
        end else if (rst_timer_eq_1) begin
            hb_gtf_ch_txdp_reset_in[jj] <= 1'b0;
            hb_gtf_ch_rxdp_reset_in[jj] <= 1'b0;
        end
    end
    
end    
endgenerate    
    
//-----------------------------------------------
// Simple delayed system reset...

wire  [NUM_CHANNEL-1:0]  link_status_out              ;
    
// Unused input signals
wire  [NUM_CHANNEL-1:0]  link_down_latched_reset_in   = 'h0;

// Unused output signals
wire                     clk_wiz_locked_out           ;
wire  [NUM_CHANNEL-1:0]  link_down_latched_out        ;
wire  [NUM_CHANNEL-1:0]  gtwiz_reset_tx_done_out      ;
wire  [NUM_CHANNEL-1:0]  gtwiz_reset_rx_done_out      ;
wire                     gtf_cm_qpll0_lock            ;
wire  [NUM_CHANNEL-1:0]  link_maintained              ;
wire  [NUM_CHANNEL-1:0]  gtf_ch_rxsyncdone            ;
wire  [NUM_CHANNEL-1:0]  gtf_ch_txsyncdone            ;
wire  [NUM_CHANNEL-1:0]  rxbuffbypass_complete_flg    ;
reg   [4:0]              link_down_latched_reset_0 [NUM_CHANNEL-1:0];

// Create a basic stable link monitor which is set after 2048 consecutive 
// cycles of link up and is reset after any link loss
reg [10:0] link_up_ctr [NUM_CHANNEL-1:0] ; //= 11'd0;
reg [NUM_CHANNEL-1:0] link_stable   ; //= 1'b0;
reg [NUM_CHANNEL-1:0] link_stable_r ; //= 1'b0;

genvar ii;
generate
for (ii=0; ii<NUM_CHANNEL; ii=ii+1) begin : gen_blk_multi_ch_sim

    always @(posedge gtf_freerun_clk) 
    begin
        if ( hb_gtwiz_reset_all_in ) begin
            link_up_ctr[ii] <= 11'd0;
            link_stable[ii] <= 1'b0;
        end else if (link_status_out[ii] !== 1'b1) begin
            link_up_ctr[ii] <= 11'd0;
            link_stable[ii] <= 1'b0;
        end else begin
            if (&link_up_ctr[ii])
                link_stable[ii] <= 1'b1;
            else
                link_up_ctr[ii] <= link_up_ctr[ii] + 11'd1;
        end
    end

    always @(posedge gtf_freerun_clk) 
    begin
        link_stable_r[ii] <= link_stable[ii];
    end

    always@(posedge gtf_freerun_clk)
    begin
        // Rising edge of link_stable....
        if (link_stable[ii] && !link_stable_r[ii]) begin
            link_down_latched_reset_0[ii] <= 'h1F;
        end else begin
            link_down_latched_reset_0[ii] <= {link_down_latched_reset_0[ii][3:0], 1'b0};
        end
    end

    assign link_down_latched_reset_in[ii] = link_down_latched_reset_0[ii][4];

end
endgenerate

// -----------------------------------------
// JTAG/AXI bus is not connected in GTF RAW design, so tie it off.
    
assign s_axil_aclk    = 'h0;
assign s_axil_aresetn = 'h0;
assign s_axil_awready = 'h1;
assign s_axil_wready  = 'h0;
assign s_axil_bresp   = 'h0;
assign s_axil_bvalid  = 'h0;
assign s_axil_arready = 'h1;
assign s_axil_rdata   = 'h0;
assign s_axil_rresp   = 'h0;
assign s_axil_rvalid  = 'h0;

// -----------------------------------------
    
gtfwizard_raw_example_top # (
    .NUM_CHANNEL (NUM_CHANNEL)
) gtfwizard_raw_example_top (

    .gtf_ch_gtftxn                        ( gtf_ch_gtftxn              ),
    .gtf_ch_gtftxp                        ( gtf_ch_gtftxp              ),
    .gtf_ch_gtfrxn                        ( gtf_ch_gtfrxn              ),
    .gtf_ch_gtfrxp                        ( gtf_ch_gtfrxp              ),

    .refclk_p                             ( SYNCE_CLK_LVDS_P           ),
    .refclk_n                             ( SYNCE_CLK_LVDS_N           ),
                                                                       
    .hb_gtwiz_reset_clk_freerun_p_in      (                            ), // NC
    .hb_gtwiz_reset_clk_freerun_n_in      (                            ), // NC
    .hb_gtwiz_reset_all_in                ( hb_gtwiz_reset_all_in      ),
                                                                       
    .hb_gtf_ch_txdp_reset_in              ( hb_gtf_ch_txdp_reset_in    ),
    .hb_gtf_ch_rxdp_reset_in              ( hb_gtf_ch_rxdp_reset_in    ),
                                                                       
    .link_status_out                      ( link_status_out            ),

    // Unused output signals from GTF MAC example design
    .clk_wiz_locked_out                   ( clk_wiz_locked_out         ), // NC
    .gtwiz_reset_tx_done_out              ( gtwiz_reset_tx_done_out    ),
    .gtwiz_reset_rx_done_out              ( gtwiz_reset_rx_done_out    ),
    .gtf_cm_qpll0_lock                    ( gtf_cm_qpll0_lock          ),                                                                       
    .link_down_latched_out                ( link_down_latched_out      ),

    // Single ended SYNCE Clock output
    .SYNCE_CLK_OUT                        ( SYNCE_CLK_OUT              ),
                                                                       
	// Port Recov Clock to I/O if desired               
    //.RECOV_CLK10_INT                    ( RECOV_CLK10_INT            ),
    //.RECOV_CLK10_LVDS_P                 ( RECOV_CLK10_LVDS_P         ),
    //.RECOV_CLK10_LVDS_N                 ( RECOV_CLK10_LVDS_N         ),

    // 200Mhz single ended freerun clock
    .freerun_clk                          ( gtf_freerun_clk            ) 
);
 

    
endmodule
    
