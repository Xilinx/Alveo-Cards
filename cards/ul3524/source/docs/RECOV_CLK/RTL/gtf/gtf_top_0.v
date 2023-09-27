/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

module gtf_top_0 # (
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
    input  wire                     s_axil_rready      ,
    
    // Differential SYNCE clock to I/O if desired
    output wire                     RECOV_CLK10_INT    ,
    output wire                     RECOV_CLK10_LVDS_P ,
    output wire                     RECOV_CLK10_LVDS_N ,

    // User loopback FIFO Reset...
    input  wire                     fifo_rst           ,

    input  wire                     ctl_hwchk_frm_gen_en_in , 
    input  wire                     ctl_hwchk_mon_en_in              
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
    .clk     ( gtf_freerun_clk       ),
    .resetn  ( sys_gtf_resetn        ),
    .datain  ( timer_ne_0            ),
    .dataout ( hb_gtwiz_reset_all_in )
);

//-----------------------------------------------
// Simple delayed system reset...

wire  [NUM_CHANNEL-1:0]  link_status_out ;
    
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

// Create a basic stable link monitor which is set after 2048 consecutive 
// cycles of link up and is reset after any link loss
reg [10:0] link_up_ctr [NUM_CHANNEL-1:0] ; //= 11'd0;
reg [NUM_CHANNEL-1:0] link_stable ; //= 1'b0;

genvar ii;
generate
for(ii=0;ii<NUM_CHANNEL;ii=ii+1) begin
    always @(posedge gtf_freerun_clk) begin
        if ( hb_gtwiz_reset_all_in ) begin
            link_up_ctr[ii] <= 11'd0;
            link_stable[ii] <= 1'b0;
        end else if (link_status_out !== 1'b1) begin
            link_up_ctr[ii] <= 11'd0;
            link_stable[ii] <= 1'b0;
        end else begin
            if (&link_up_ctr[ii])
                link_stable[ii] <= 1'b1;
            else
                link_up_ctr[ii] <= link_up_ctr[ii] + 11'd1;
        end
    end
end
endgenerate    
    
gtfwizard_mac_gtfmac_ex # (
    .ONE_SECOND_COUNT   (28'h1000),  // for simulation purposes
    .NUM_CHANNEL        (NUM_CHANNEL)
)  u_gtfwizard_0_example_gtfmac_top (

    .gtf_ch_gtftxn                      ( gtf_ch_gtftxn              ), 
    .gtf_ch_gtftxp                      ( gtf_ch_gtftxp              ), 
    .gtf_ch_gtfrxn                      ( gtf_ch_gtfrxn              ), 
    .gtf_ch_gtfrxp                      ( gtf_ch_gtfrxp              ), 
                                                     
    .refclk_p                           ( SYNCE_CLK_LVDS_P           ), 
    .refclk_n                           ( SYNCE_CLK_LVDS_N           ), 
                                                                    
    .hb_gtwiz_reset_clk_freerun_p_in    (                            ), // NC
    .hb_gtwiz_reset_clk_freerun_n_in    (                            ), // NC
    .hb_gtwiz_reset_all_in              ( hb_gtwiz_reset_all_in      ), 
    
    .link_status_out                    ( link_status_out            ), 
                                                                    
    // Unused input signals to GTF MAC example design
    .link_down_latched_reset_in         ( link_down_latched_reset_in ),
                                                                    
    // Unused output signals from GTF MAC example design
    .clk_wiz_locked_out                 ( clk_wiz_locked_out         ),
    .gtwiz_reset_tx_done_out            ( gtwiz_reset_tx_done_out    ), 
    .gtwiz_reset_rx_done_out            ( gtwiz_reset_rx_done_out    ), 
    .gtf_cm_qpll0_lock                  ( gtf_cm_qpll0_lock          ), 
    .rxbuffbypass_complete_flg          ( rxbuffbypass_complete_flg  ), 
    .gtf_ch_txsyncdone                  ( gtf_ch_txsyncdone          ), 
    .gtf_ch_rxsyncdone                  ( gtf_ch_rxsyncdone          ), 
    .link_maintained                    ( link_maintained            ), 
    .link_down_latched_out              ( link_down_latched_out      ),

	// JTAG/AXI Bus Interface
    .s_axil_aclk                        ( s_axil_aclk                ),
    .s_axil_aresetn                     ( s_axil_aresetn             ),
    .s_axil_awaddr                      ( s_axil_awaddr              ),
    .s_axil_awprot                      ( s_axil_awprot              ),
    .s_axil_awvalid                     ( s_axil_awvalid             ),
    .s_axil_awready                     ( s_axil_awready             ),
    .s_axil_wdata                       ( s_axil_wdata               ),
    .s_axil_wstrb                       ( s_axil_wstrb               ),
    .s_axil_wvalid                      ( s_axil_wvalid              ),
    .s_axil_wready                      ( s_axil_wready              ),
    .s_axil_bresp                       ( s_axil_bresp               ),
    .s_axil_bvalid                      ( s_axil_bvalid              ),
    .s_axil_bready                      ( s_axil_bready              ),
    .s_axil_araddr                      ( s_axil_araddr              ),
    .s_axil_arprot                      ( s_axil_arprot              ),
    .s_axil_arvalid                     ( s_axil_arvalid             ),
    .s_axil_arready                     ( s_axil_arready             ),
    .s_axil_rdata                       ( s_axil_rdata               ),
    .s_axil_rresp                       ( s_axil_rresp               ),
    .s_axil_rvalid                      ( s_axil_rvalid              ),
    .s_axil_rready                      ( s_axil_rready              ),

	// Single ended SYNCE clock for frequency measurement
    .SYNCE_CLK_OUT                      ( SYNCE_CLK_OUT              ), 

	// Port Recov Clock to I/O                 
    .RECOV_CLK10_INT                    ( RECOV_CLK10_INT            ),
    .RECOV_CLK10_LVDS_P                 ( RECOV_CLK10_LVDS_P         ),
    .RECOV_CLK10_LVDS_N                 ( RECOV_CLK10_LVDS_N         ),
                
    // 425 Mhz system clock
    .sys_clk_out                        ( gtf_sys_clk_out            ),

    // 200 Mhz system clock
    .freerun_clk                        ( gtf_freerun_clk            ),

	// User signal to reset loopback FIFO...
    .fifo_rst                           ( fifo_rst                   ),
    
    .ctl_hwchk_frm_gen_en_in            ( ctl_hwchk_frm_gen_en_in    ),
    .ctl_hwchk_mon_en_in                ( ctl_hwchk_mon_en_in        )
); 

endmodule
