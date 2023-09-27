/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

module gtf_top # (
    parameter  integer     LOOPBACKMODE = 1,
    parameter  integer     NUM_CHANNEL = 1
) (
    output wire  [NUM_CHANNEL-1:0]  gtf_ch_gtftxn      ,
    output wire  [NUM_CHANNEL-1:0]  gtf_ch_gtftxp      ,
    input  wire  [NUM_CHANNEL-1:0]  gtf_ch_gtfrxn      ,
    input  wire  [NUM_CHANNEL-1:0]  gtf_ch_gtfrxp      ,

    input  wire                     gtf_freerun_clk    ,
    input  wire                     gtf_sys_clk_out    ,
    input  wire                     gtf_clk_wiz_locked ,
    //input  wire                     CLK12_LVDS_300_P   ,
    //input  wire                     CLK12_LVDS_300_N   ,
                        
    output wire                     SYNCE_CLK_OUT      ,
    input  wire                     SYNCE_CLK_LVDS_P   ,
    input  wire                     SYNCE_CLK_LVDS_N   ,

    input  wire                     sys_if_clk         ,   
    input  wire                     sys_if_rstn        ,
    
    input  wire                     sys_gtf_resetn     ,

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
    
    
    output wire                     gtf_recov_clk_sel  ,
    output wire                     RECOV_CLK10_LVDS_P ,
    output wire                     RECOV_CLK10_LVDS_N ,

    output wire [NUM_CHANNEL-1:0]   tx_axis_clk        ,
    output wire [NUM_CHANNEL-1:0]   rx_axis_clk

);

//-----------------------------------------------

//localparam NUM_CHANNEL = 1;

wire                     freerun_clk_200Mhz           ;
wire                     hb_gtwiz_reset_all_in        ;  // active high reset
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


wire clk_wiz_locked_out_sync;
syncer_level #(
    .WIDTH       ( 1    ),
    .RESET_VALUE ( 1'b0 )
) syncer_level_clk_locked (
    .clk     ( freerun_clk_200Mhz      ),
    .resetn  ( sys_if_rstn             ),
    .datain  ( gtf_clk_wiz_locked      ),
    //.datain  ( clk_wiz_locked_out      ),
    .dataout ( clk_wiz_locked_out_sync )
);

reg [31:0] timer;
//always@(posedge sys_if_clk)
always@(posedge freerun_clk_200Mhz)
begin
    if (!clk_wiz_locked_out_sync)
        timer <= 100;
    else if (timer == 'h0)
        timer <= 'h0;
    else
        timer <= timer - 1;
end

wire timer_ne_0 = ~(timer == 0);

syncer_level #(
    .WIDTH       ( 1    ),
    .RESET_VALUE ( 1'b1 )
) syncer_level_reset (
    .clk     ( freerun_clk_200Mhz    ),
    .resetn  ( sys_gtf_resetn        ),
    .datain  ( timer_ne_0            ),
    .dataout ( hb_gtwiz_reset_all_in )
);

//ila_0 ila_0 (
//    .clk    ( freerun_clk_200Mhz      ),
//    .probe0 ( clk_wiz_locked_out_sync ),
//    .probe1 ( timer_ne_0              ),
//    .probe2 ( sys_gtf_resetn          ),
//    .probe3 ( hb_gtwiz_reset_all_in   )
//);


// hb_gtwiz_reset_all_in - active high reset

// Create a basic stable link monitor which is set after 2048 consecutive 
// cycles of link up and is reset after any link loss
reg [10:0] link_up_ctr [NUM_CHANNEL-1:0] ; //= 11'd0;
reg [NUM_CHANNEL-1:0] link_stable ; //= 1'b0;

genvar ii;
generate
for(ii=0;ii<NUM_CHANNEL;ii=ii+1) begin
    always @(posedge freerun_clk_200Mhz) begin
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
    
gtfwizard_0_gtfmac_ex # (
    .LOOPBACKMODE       (LOOPBACKMODE),
    .ONE_SECOND_COUNT   (28'h1000),  // for simulation purposes
    .NUM_CHANNEL        (NUM_CHANNEL)
)  u_gtfwizard_0_example_gtfmac_top (

    // exdes IOs
    .gtf_ch_gtftxn                      ( gtf_ch_gtftxn              ), 
    .gtf_ch_gtftxp                      ( gtf_ch_gtftxp              ), 
    .gtf_ch_gtfrxn                      ( gtf_ch_gtfrxn              ), 
    .gtf_ch_gtfrxp                      ( gtf_ch_gtfrxp              ), 
                                                     
    .SYNCE_CLK_OUT                      ( SYNCE_CLK_OUT              ),                                                     
    .refclk_p                           ( SYNCE_CLK_LVDS_P           ), 
    .refclk_n                           ( SYNCE_CLK_LVDS_N           ), 
                                                                    
    .gtf_freerun_clk                    ( gtf_freerun_clk            ), 
    .gtf_sys_clk_out                    ( gtf_sys_clk_out            ), 
    //.hb_gtwiz_reset_clk_freerun_p_in    ( CLK12_LVDS_300_P           ), 
    //.hb_gtwiz_reset_clk_freerun_n_in    ( CLK12_LVDS_300_N           ), 
    .hb_gtwiz_reset_all_in              ( hb_gtwiz_reset_all_in      ), 
    .freerun_clk                        ( freerun_clk_200Mhz         ), 
    
    .link_status_out                    ( link_status_out            ), 
                                                                    
    // Unused input signals
    .link_down_latched_reset_in         ( link_down_latched_reset_in ),
    .clk_wiz_locked_out                 ( clk_wiz_locked_out         ), 
                                                                    
    // Unused output signals
    .gtwiz_reset_tx_done_out            ( gtwiz_reset_tx_done_out    ), 
    .gtwiz_reset_rx_done_out            ( gtwiz_reset_rx_done_out    ), 
    .gtf_cm_qpll0_lock                  ( gtf_cm_qpll0_lock          ), 
    .rxbuffbypass_complete_flg          ( rxbuffbypass_complete_flg  ), 
    .gtf_ch_txsyncdone                  ( gtf_ch_txsyncdone          ), 
    .gtf_ch_rxsyncdone                  ( gtf_ch_rxsyncdone          ), 
    .link_maintained                    ( link_maintained            ), 
    .link_down_latched_out              ( link_down_latched_out      ),


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

    .gtf_recov_clk_sel                  ( gtf_recov_clk_sel          ),
    .RECOV_CLK10_LVDS_P                 ( RECOV_CLK10_LVDS_P         ),
    .RECOV_CLK10_LVDS_N                 ( RECOV_CLK10_LVDS_N         ),
                
    .tx_axis_clk                        ( tx_axis_clk                ),
    .rx_axis_clk                        ( rx_axis_clk                )
); 
    
endmodule
    
  
//   always @(posedge freerun_clk)
//   begin
//     if (gtwiz_reset_all_in[i])
//     begin
//       int_rx_received[16*(i+1)-1:16*i]      <= 16'h0;
//       int_tx_ack[16*(i+1)-1:16*i]           <= 16'h0;
//       int_gt_locked[i]                      <= 1'b0;
//       int_block_lock[i]                     <= 1'b0;
//     end
//     else
//     begin
//       int_rx_received[16*(i+1)-1:16*i]      <= (gtf_ch_rxaxistvalid[i]==1'b1) ? 
//                                                     16'h0 : 
//                                                     int_rx_received[16*(i+1)-1:16*i]+1'b1;
//       
//       int_block_lock[i]                     <= (int_rx_received[16*(i+1)-1:16*i]>= 16'h8fff)? 
//                                                     1'b0 : 
//                                                     (int_block_lock[i] || (gtf_ch_txaxistready[i]==1'b1));
// 
//       int_tx_ack[16*(i+1)-1:16*i]           <= (gtf_ch_txaxistready[i]==1'b1) ? 
//                                                     16'h0 : 
//                                                     int_tx_ack[16*(i+1)-1:16*i]+1'b1;      
//       
//       int_gt_locked[i]                      <= (int_tx_ack[16*(i+1)-1:16*i] >= 16'h8fff)? 
//                                                     1'b0 : 
//                                                     (int_gt_locked[i] || (gtf_ch_rxaxistvalid[i]==1'b1));
//     end
//   end
//   
//   
//   assign status_int_mac[i] = (int_gt_locked[i] && int_block_lock[i]);
// 
// 
// status_int_freerun_sync[i]  <---- status_int_mac[i]
// 
// 
// 
//     
//   always @(posedge gtf_rxusrclk2_out[i]) begin
//     if (gtwiz_reset_rx_sync[i] || gtf_wiz_reset_rx_datapath_init_sync[i])
//       link_status_out[i] <= 1'b0;
//     else
//       link_status_out[i] <= status_int_freerun_sync[i];
//   end
//   
//   always @(posedge gtf_rxusrclk2_out[i]) begin
//     if (link_down_latched_reset_in[i])
//       link_down_latched_out[i] <= 1'b0;
//     else if (!link_status_out[i])
//       link_down_latched_out[i] <= 1'b1;
//   end  
// 
//   assign link_maintained[i] = ((~link_down_latched_out[i]) && (link_status_out[i]));
//   
// 
// if    link_down_latched_out == 1 , reset with  link_down_latched_reset_in
    