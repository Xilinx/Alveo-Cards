/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

module gtfraw_wrapper_axi_if_soft_top #(
  parameter C_S_AXI_ADDR_WIDTH = 32,   // Width of M_AXI address bus
  parameter C_S_AXI_DATA_WIDTH = 32    // Width of M_AXI data bus
)
(
  output wire ctl_tx_send_lfi,
  output wire ctl_tx_send_rfi,
  output wire ctl_tx_send_idle,
  output wire [2:0] ctl_local_loopback,
  output wire ctl_gt_reset_all,
  output wire ctl_gt_tx_reset,
  output wire ctl_gt_rx_reset,

  input  wire stat_rx_framing_err,
  input  wire stat_rx_hi_ber,
  input  wire stat_rx_status,
  input  wire stat_rx_bad_code,
  input  wire stat_rx_total_packets,
  input  wire stat_rx_total_good_packets,
  input  wire [3:0] stat_rx_total_bytes,
  input  wire [13:0] stat_rx_total_good_bytes,
  input  wire stat_rx_packet_small,
  input  wire stat_rx_jabber,
  input  wire stat_rx_packet_large,
  input  wire stat_rx_oversize,
  input  wire stat_rx_undersize,
  input  wire stat_rx_toolong,
  input  wire stat_rx_fragment,
  input  wire stat_rx_packet_64_bytes,
  input  wire stat_rx_packet_65_127_bytes,
  input  wire stat_rx_packet_128_255_bytes,
  input  wire stat_rx_packet_256_511_bytes,
  input  wire stat_rx_packet_512_1023_bytes,
  input  wire stat_rx_packet_1024_1518_bytes,
  input  wire stat_rx_packet_1519_1522_bytes,
  input  wire stat_rx_packet_1523_1548_bytes,
  input  wire [13:0] stat_rx_total_err_bytes,
  input  wire stat_rx_bad_fcs,
  input  wire stat_rx_packet_bad_fcs,
  input  wire stat_rx_stomped_fcs,
  input  wire stat_rx_packet_1549_2047_bytes,
  input  wire stat_rx_packet_2048_4095_bytes,
  input  wire stat_rx_packet_4096_8191_bytes,
  input  wire stat_rx_packet_8192_9215_bytes,
  input  wire stat_rx_unicast,
  input  wire stat_rx_multicast,
  input  wire stat_rx_broadcast,
  input  wire stat_rx_vlan,
  input  wire stat_rx_pause,
  input  wire stat_rx_user_pause,
  input  wire stat_rx_inrangeerr,
  input  wire stat_rx_clk_align,
  input  wire stat_rx_bit_slip,
  input  wire stat_rx_pkt_err,
  input  wire stat_rx_bad_preamble,
  input  wire stat_rx_bad_sfd,
  input  wire stat_rx_got_signal_os,
  input  wire stat_rx_truncated,
  input  wire stat_rx_local_fault,
  input  wire stat_rx_remote_fault,
  input  wire stat_rx_internal_local_fault,
  input  wire stat_rx_received_local_fault,
  input  wire stat_tx_total_packets,
  input  wire [3:0] stat_tx_total_bytes,
  input  wire stat_tx_total_good_packets,
  input  wire [13:0] stat_tx_total_good_bytes,
  input  wire stat_tx_packet_64_bytes,
  input  wire stat_tx_packet_65_127_bytes,
  input  wire stat_tx_packet_128_255_bytes,
  input  wire stat_tx_packet_256_511_bytes,
  input  wire stat_tx_packet_512_1023_bytes,
  input  wire stat_tx_packet_1024_1518_bytes,
  input  wire stat_tx_packet_1519_1522_bytes,
  input  wire stat_tx_packet_1523_1548_bytes,
  input  wire stat_tx_packet_large,
  input  wire stat_tx_packet_small,
  input  wire [13:0] stat_tx_total_err_bytes,
  input  wire stat_tx_packet_1549_2047_bytes,
  input  wire stat_tx_packet_2048_4095_bytes,
  input  wire stat_tx_packet_4096_8191_bytes,
  input  wire stat_tx_packet_8192_9215_bytes,
  input  wire stat_tx_unicast,
  input  wire stat_tx_multicast,
  input  wire stat_tx_broadcast,
  input  wire stat_tx_vlan,
  input  wire stat_tx_bad_fcs,
  input  wire stat_tx_frame_error,

  input  rx_clk,
  input  rx_resetn,
  input  tx_clk,
  input  tx_resetn,

  output wire rx_resetn_out,
  output wire tx_resetn_out,

  input  wire s_axi_aclk,
  input  wire s_axi_aresetn,
  input  wire [31:0] s_axi_awaddr,
  input  wire s_axi_awvalid,
  output wire s_axi_awready,
  input  wire [31:0] s_axi_wdata,
  input  wire [3:0] s_axi_wstrb,
  input  wire s_axi_wvalid,
  output wire s_axi_wready,
  output wire [1:0] s_axi_bresp,
  output wire s_axi_bvalid,
  input  wire s_axi_bready,
  input  wire [31:0] s_axi_araddr,
  input  wire s_axi_arvalid,
  output wire s_axi_arready,
  output wire [31:0] s_axi_rdata,
  output wire [1:0] s_axi_rresp,
  output wire s_axi_rvalid,
  input  wire s_axi_rready,
  input  wire pm_tick
);

  wire Bus2IP_Clk;
  wire Bus2IP_Resetn;
  wire [C_S_AXI_ADDR_WIDTH-1:0]   Bus2IP_Addr;
  wire Bus2IP_RNW;
  wire Bus2IP_CS;
  wire Bus2IP_RdCE;    // Not used
  wire Bus2IP_WrCE;    // Not used
  wire [C_S_AXI_DATA_WIDTH-1:0]   Bus2IP_Data;
  wire [C_S_AXI_DATA_WIDTH/8-1:0] Bus2IP_BE;
  wire [C_S_AXI_DATA_WIDTH-1:0]   IP2Bus_Data;
  wire IP2Bus_WrAck;
  wire IP2Bus_RdAck;
  wire IP2Bus_WrError;
  wire IP2Bus_RdError;




 gtfraw_wrapper_pif_soft_registers #(
  .ADDR_WIDTH(16),
  .DATA_WIDTH(C_S_AXI_DATA_WIDTH)
 ) i_pif_registers (
  // Stats and ctl
    .ctl_tx_send_lfi (ctl_tx_send_lfi),
    .ctl_tx_send_rfi (ctl_tx_send_rfi),
    .ctl_tx_send_idle (ctl_tx_send_idle),
    .ctl_local_loopback (ctl_local_loopback),
    .ctl_gt_reset_all (ctl_gt_reset_all),
    .ctl_gt_tx_reset (ctl_gt_tx_reset),
    .ctl_gt_rx_reset (ctl_gt_rx_reset),
    .stat_rx_framing_err (stat_rx_framing_err),
    .stat_rx_hi_ber (stat_rx_hi_ber),
    .stat_rx_status (stat_rx_status),
    .stat_rx_bad_code (stat_rx_bad_code),
    .stat_rx_total_packets (stat_rx_total_packets),
    .stat_rx_total_good_packets (stat_rx_total_good_packets),
    .stat_rx_total_bytes (stat_rx_total_bytes),
    .stat_rx_total_good_bytes (stat_rx_total_good_bytes),
    .stat_rx_packet_small (stat_rx_packet_small),
    .stat_rx_jabber (stat_rx_jabber),
    .stat_rx_packet_large (stat_rx_packet_large),
    .stat_rx_oversize (stat_rx_oversize),
    .stat_rx_undersize (stat_rx_undersize),
    .stat_rx_toolong (stat_rx_toolong),
    .stat_rx_fragment (stat_rx_fragment),
    .stat_rx_packet_64_bytes (stat_rx_packet_64_bytes),
    .stat_rx_packet_65_127_bytes (stat_rx_packet_65_127_bytes),
    .stat_rx_packet_128_255_bytes (stat_rx_packet_128_255_bytes),
    .stat_rx_packet_256_511_bytes (stat_rx_packet_256_511_bytes),
    .stat_rx_packet_512_1023_bytes (stat_rx_packet_512_1023_bytes),
    .stat_rx_packet_1024_1518_bytes (stat_rx_packet_1024_1518_bytes),
    .stat_rx_packet_1519_1522_bytes (stat_rx_packet_1519_1522_bytes),
    .stat_rx_packet_1523_1548_bytes (stat_rx_packet_1523_1548_bytes),
    .stat_rx_total_err_bytes (stat_rx_total_err_bytes),
    .stat_rx_bad_fcs (stat_rx_bad_fcs),
    .stat_rx_packet_bad_fcs (stat_rx_packet_bad_fcs),
    .stat_rx_stomped_fcs (stat_rx_stomped_fcs),
    .stat_rx_packet_1549_2047_bytes (stat_rx_packet_1549_2047_bytes),
    .stat_rx_packet_2048_4095_bytes (stat_rx_packet_2048_4095_bytes),
    .stat_rx_packet_4096_8191_bytes (stat_rx_packet_4096_8191_bytes),
    .stat_rx_packet_8192_9215_bytes (stat_rx_packet_8192_9215_bytes),
    .stat_rx_unicast (stat_rx_unicast),
    .stat_rx_multicast (stat_rx_multicast),
    .stat_rx_broadcast (stat_rx_broadcast),
    .stat_rx_vlan (stat_rx_vlan),
    .stat_rx_pause (stat_rx_pause),
    .stat_rx_user_pause (stat_rx_user_pause),
    .stat_rx_inrangeerr (stat_rx_inrangeerr),
    .stat_rx_clk_align (stat_rx_clk_align),
    .stat_rx_bit_slip (stat_rx_bit_slip),
    .stat_rx_pkt_err (stat_rx_pkt_err),
    .stat_rx_bad_preamble (stat_rx_bad_preamble),
    .stat_rx_bad_sfd (stat_rx_bad_sfd),
    .stat_rx_got_signal_os (stat_rx_got_signal_os),
    .stat_rx_truncated (stat_rx_truncated),
    .stat_rx_local_fault (stat_rx_local_fault),
    .stat_rx_remote_fault (stat_rx_remote_fault),
    .stat_rx_internal_local_fault (stat_rx_internal_local_fault),
    .stat_rx_received_local_fault (stat_rx_received_local_fault),
    .stat_tx_total_packets (stat_tx_total_packets),
    .stat_tx_total_bytes (stat_tx_total_bytes),
    .stat_tx_total_good_packets (stat_tx_total_good_packets),
    .stat_tx_total_good_bytes (stat_tx_total_good_bytes),
    .stat_tx_packet_64_bytes (stat_tx_packet_64_bytes),
    .stat_tx_packet_65_127_bytes (stat_tx_packet_65_127_bytes),
    .stat_tx_packet_128_255_bytes (stat_tx_packet_128_255_bytes),
    .stat_tx_packet_256_511_bytes (stat_tx_packet_256_511_bytes),
    .stat_tx_packet_512_1023_bytes (stat_tx_packet_512_1023_bytes),
    .stat_tx_packet_1024_1518_bytes (stat_tx_packet_1024_1518_bytes),
    .stat_tx_packet_1519_1522_bytes (stat_tx_packet_1519_1522_bytes),
    .stat_tx_packet_1523_1548_bytes (stat_tx_packet_1523_1548_bytes),
    .stat_tx_packet_large (stat_tx_packet_large),
    .stat_tx_packet_small (stat_tx_packet_small),
    .stat_tx_total_err_bytes (stat_tx_total_err_bytes),
    .stat_tx_packet_1549_2047_bytes (stat_tx_packet_1549_2047_bytes),
    .stat_tx_packet_2048_4095_bytes (stat_tx_packet_2048_4095_bytes),
    .stat_tx_packet_4096_8191_bytes (stat_tx_packet_4096_8191_bytes),
    .stat_tx_packet_8192_9215_bytes (stat_tx_packet_8192_9215_bytes),
    .stat_tx_unicast (stat_tx_unicast),
    .stat_tx_multicast (stat_tx_multicast),
    .stat_tx_broadcast (stat_tx_broadcast),
    .stat_tx_vlan (stat_tx_vlan),
    .stat_tx_bad_fcs (stat_tx_bad_fcs),
    .stat_tx_frame_error (stat_tx_frame_error),

  .rx_clk                 ( rx_clk               ),
  .rx_resetn      ( rx_resetn    ),
  .tx_clk                 ( tx_clk               ),
  .tx_resetn      ( tx_resetn    ),

  .rx_resetn_out  ( rx_resetn_out),
  .tx_resetn_out  ( tx_resetn_out),

  .pm_tick                ( pm_tick              ),
  .Bus2IP_Clk             ( Bus2IP_Clk           ),
  .Bus2IP_Resetn          ( Bus2IP_Resetn        ),
  .Bus2IP_Addr            ( Bus2IP_Addr[16-1:0]  ),
  .Bus2IP_RNW             ( Bus2IP_RNW           ),
  .Bus2IP_CS              ( Bus2IP_CS            ),
  .Bus2IP_RdCE            ( Bus2IP_RdCE          ),
  .Bus2IP_WrCE            ( Bus2IP_WrCE          ),
  .Bus2IP_Data            ( Bus2IP_Data          ),
  .IP2Bus_Data            ( IP2Bus_Data          ),
  .IP2Bus_WrAck           ( IP2Bus_WrAck         ),
  .IP2Bus_RdAck           ( IP2Bus_RdAck         ),
  .IP2Bus_WrError         ( IP2Bus_WrError       ),
  .IP2Bus_RdError         ( IP2Bus_RdError       )

 );


 gtfraw_wrapper_axi_slave_2_ipif #(
  .C_S_AXI_ADDR_WIDTH (C_S_AXI_ADDR_WIDTH),   // Width of M_AXI address bus
  .C_S_AXI_DATA_WIDTH (C_S_AXI_DATA_WIDTH)    // Width of M_AXI data bus
 ) i_axi_slave_2_ipif (
  .s_axi_aclk       ( s_axi_aclk     ),
  .s_axi_aresetn    ( s_axi_aresetn  ),
  .s_axi_awaddr     ( s_axi_awaddr   ),
  .s_axi_awvalid    ( s_axi_awvalid  ),
  .s_axi_awready    ( s_axi_awready  ),
  .s_axi_wdata      ( s_axi_wdata    ),
  .s_axi_wstrb      ( s_axi_wstrb    ),
  .s_axi_wvalid     ( s_axi_wvalid   ),
  .s_axi_wready     ( s_axi_wready   ),
  .s_axi_bresp      ( s_axi_bresp    ),
  .s_axi_bvalid     ( s_axi_bvalid   ),
  .s_axi_bready     ( s_axi_bready   ),
  .s_axi_araddr     ( s_axi_araddr   ),
  .s_axi_arvalid    ( s_axi_arvalid  ),
  .s_axi_arready    ( s_axi_arready  ),
  .s_axi_rdata      ( s_axi_rdata    ),
  .s_axi_rresp      ( s_axi_rresp    ),
  .s_axi_rvalid     ( s_axi_rvalid   ),
  .s_axi_rready     ( s_axi_rready   ),
  .Bus2IP_Clk       ( Bus2IP_Clk     ),
  .Bus2IP_Resetn    ( Bus2IP_Resetn  ),
  .Bus2IP_Addr      ( Bus2IP_Addr    ),
  .Bus2IP_RNW       ( Bus2IP_RNW     ),
  .Bus2IP_CS        ( Bus2IP_CS      ),
  .Bus2IP_RdCE      ( Bus2IP_RdCE    ),    // Not used
  .Bus2IP_WrCE      ( Bus2IP_WrCE    ),    // Not used
  .Bus2IP_Data      ( Bus2IP_Data    ),
  .Bus2IP_BE        ( Bus2IP_BE      ),
  .IP2Bus_Data      ( IP2Bus_Data    ),
  .IP2Bus_WrAck     ( IP2Bus_WrAck   ),
  .IP2Bus_RdAck     ( IP2Bus_RdAck   ),
  .IP2Bus_WrError   ( IP2Bus_WrError ),
  .IP2Bus_RdError   ( IP2Bus_RdError )
 );


endmodule
