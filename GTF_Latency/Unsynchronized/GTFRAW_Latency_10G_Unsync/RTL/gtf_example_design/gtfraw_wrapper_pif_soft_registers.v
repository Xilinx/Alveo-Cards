/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

module gtfraw_wrapper_pif_soft_registers
#(
  parameter ADDR_WIDTH = 16,
  parameter DATA_WIDTH = 32
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

  output reg  rx_resetn_out,
  output reg  tx_resetn_out,

  input  wire pm_tick,
  input  wire Bus2IP_Clk,
  input  wire Bus2IP_Resetn,
  input  wire [ADDR_WIDTH-1:0] Bus2IP_Addr,
  input  wire Bus2IP_RNW,
  input  wire Bus2IP_CS,
  input  wire Bus2IP_RdCE,
  input  wire Bus2IP_WrCE,
  input  wire [DATA_WIDTH-1:0] Bus2IP_Data,
  output reg  [DATA_WIDTH-1:0] IP2Bus_Data,
  output reg  IP2Bus_WrAck,
  output reg  IP2Bus_RdAck,
  output reg  IP2Bus_WrError,
  output reg  IP2Bus_RdError

);

  reg  AXI_Reset;

  reg  [ADDR_WIDTH-1:0] Bus2IP_Addr_reg;
  reg  Bus2IP_RNW_reg;
  reg  Bus2IP_CS_reg;
  reg  Bus2IP_RdCE_reg;
  reg  Bus2IP_WrCE_reg;
  reg  [DATA_WIDTH-1:0] Bus2IP_Data_reg;

  always @( posedge Bus2IP_Clk )
    begin
      AXI_Reset       <= Bus2IP_Resetn;
      Bus2IP_Addr_reg <= Bus2IP_Addr;
      Bus2IP_RNW_reg  <= Bus2IP_RNW;
      Bus2IP_CS_reg   <= Bus2IP_CS;
      Bus2IP_RdCE_reg <= Bus2IP_RdCE;
      Bus2IP_WrCE_reg <= Bus2IP_WrCE;
      Bus2IP_Data_reg <= Bus2IP_Data;
    end

  reg rx_reset_r;
  reg tx_reset_r;

  always @(posedge Bus2IP_Clk)
    begin
      rx_resetn_out       <= rx_reset_r & AXI_Reset;
      tx_resetn_out       <= tx_reset_r & AXI_Reset;
    end

  reg  ctl_tx_send_lfi_r;
  reg  ctl_tx_send_rfi_r;
  reg  ctl_tx_send_idle_r;
  reg  [2:0] ctl_local_loopback_r;
  reg  ctl_gt_reset_all_r;
  reg  ctl_gt_tx_reset_r;
  reg  ctl_gt_rx_reset_r;
  reg  ctl_tx_send_lfi_out;
  reg  ctl_tx_send_rfi_out;
  reg  ctl_tx_send_idle_out;
  reg  [2:0] ctl_local_loopback_out;
  reg  ctl_gt_reset_all_out;
  reg  ctl_gt_tx_reset_out;
  reg  ctl_gt_rx_reset_out;

  assign ctl_tx_send_lfi = ctl_tx_send_lfi_out;
  assign ctl_tx_send_rfi = ctl_tx_send_rfi_out;
  assign ctl_tx_send_idle = ctl_tx_send_idle_out;
  assign ctl_local_loopback = ctl_local_loopback_out;
  assign ctl_gt_reset_all = ctl_gt_reset_all_out;
  assign ctl_gt_tx_reset = ctl_gt_tx_reset_out;
  assign ctl_gt_rx_reset = ctl_gt_rx_reset_out;


  wire AXI_Reset_rx_clk_sync;
  wire AXI_Reset_tx_clk_sync;

  gtfraw_wrapper_syncer_reset i_AXI_RESET_RX_SYNC (

    .clk             (rx_clk),
    .reset_async     (AXI_Reset),
    .reset           (AXI_Reset_rx_clk_sync)

  );

  gtfraw_wrapper_syncer_reset i_AXI_RESET_TX_SYNC (

    .clk             (tx_clk),
    .reset_async     (AXI_Reset),
    .reset           (AXI_Reset_tx_clk_sync)

  );

  reg [10-1:0] rx_resetn_pulse_len;
  reg [10-1:0] tx_resetn_pulse_len;
  reg rx_resetn_d1;
  reg tx_resetn_d1;

  always @( posedge rx_clk or negedge AXI_Reset_rx_clk_sync )
    begin
      if ( AXI_Reset_rx_clk_sync != 1'b1 )
        begin
          rx_resetn_d1        <= 1'b1;
          rx_resetn_pulse_len <= {10{1'b0}};
        end
      else if ( (rx_resetn_d1 == 1'b1) && (rx_resetn == 1'b0) )
        begin
          rx_resetn_d1        <= rx_resetn;
          rx_resetn_pulse_len <= {10{1'b0}};
        end
      else
        begin
          rx_resetn_d1        <= rx_resetn;
          rx_resetn_pulse_len <= {1'b1, rx_resetn_pulse_len[10-1:1]};
        end
    end

  always @( posedge tx_clk or negedge AXI_Reset_tx_clk_sync )
    begin
      if ( AXI_Reset_tx_clk_sync != 1'b1 )
        begin
          tx_resetn_d1        <= 1'b1;
          tx_resetn_pulse_len <= {10{1'b0}};
        end
      else if ( (tx_resetn_d1 == 1'b1) && (tx_resetn == 1'b0) )
        begin
          tx_resetn_d1        <= tx_resetn;
          tx_resetn_pulse_len <= {10{1'b0}};
        end
      else
        begin
          tx_resetn_d1        <= tx_resetn;
          tx_resetn_pulse_len <= {1'b1, tx_resetn_pulse_len[10-1:1]};
        end
    end

  wire rx_resetn_pulse;
  wire tx_resetn_pulse;
  assign rx_resetn_pulse = rx_resetn_pulse_len[0];
  assign tx_resetn_pulse = tx_resetn_pulse_len[0];


  reg  tick_reg_mode_sel_r;
  reg  tick_reg_r;
  reg  tick_r;
  wire rx_clk_tick_r;
  wire tx_clk_tick_r;
  wire rx_clk_tick_retimed;
  wire tx_clk_tick_retimed;



  reg  [31:0] user_reg0_r;
  reg  [31:0] user_reg1_r;

  reg  statsreg_read_req;
  reg  statsreg_read_ack;
  wire rx_clk_statsreg_hold_r;
  wire tx_clk_statsreg_hold_r;
  wire rx_clk_statsreg_hold;
  wire tx_clk_statsreg_hold;



  reg  [7-1:0] timeout_counter;
  reg  timeout_error;

  wire stat_rx_cycle_soft = 1'b1;
  wire stat_tx_cycle_soft = 1'b1;


  wire write_req;
  reg  write_req_d1;
  reg  write_req_d2;
  wire AXI_write;
  reg  ctl_reg_write_hold;
  assign write_req = Bus2IP_CS_reg & ~Bus2IP_RNW_reg;
  assign AXI_write = write_req & write_req_d2;

  always @( posedge Bus2IP_Clk or negedge AXI_Reset )
    begin
      if ( AXI_Reset != 1'b1 )
        begin
          ctl_reg_write_hold <= 1'b0;
          write_req_d1       <= 1'b0;
          write_req_d2       <= 1'b0;
        end
      else
        begin
          ctl_reg_write_hold <= write_req | IP2Bus_WrAck;
          write_req_d1       <= write_req;
          write_req_d2       <= write_req_d1;
        end
    end

  wire ctl_reg_write_enable_tx_clk_sync;

  // The dataout FF typically drives the CE pin on FFs in the tx_clk domain.
  // Invert going into the syncer_level module so that the CE pin can be
  // driven directly, which can be better-handled by Vivado during replication.
  gtfraw_wrapper_syncer_level #(
    .WIDTH        (1)
  ) i_ctl_reg_tx_clk_write_hold_syncer (
    .clk          (tx_clk),
    .reset        (tx_resetn_pulse),
    .datain       (!ctl_reg_write_hold),
    .dataout      (ctl_reg_write_enable_tx_clk_sync )
  );

  wire ctl_reg_write_enable_rx_clk_sync;

  // The dataout FF typically drives the CE pin on FFs in the rx_clk domain.
  // Invert going into the syncer_level module so that the CE pin can be
  // driven directly, which can be better-handled by Vivado during replication.
  gtfraw_wrapper_syncer_level #(
    .WIDTH        (1)
  ) i_ctl_reg_rx_clk_write_hold_syncer (
    .clk          (rx_clk),
    .reset        (rx_resetn_pulse),
    .datain       (!ctl_reg_write_hold),
    .dataout      (ctl_reg_write_enable_rx_clk_sync )
  );


  always @(*)
    begin
      ctl_local_loopback_out = ctl_local_loopback_r;
    end

  always @( posedge tx_clk )
    begin
      if (ctl_reg_write_enable_tx_clk_sync == 1'b1) begin
        ctl_tx_send_lfi_out <= ctl_tx_send_lfi_r;
      end
    end

  always @( posedge tx_clk )
    begin
      if (ctl_reg_write_enable_tx_clk_sync == 1'b1) begin
        ctl_tx_send_idle_out <= ctl_tx_send_idle_r;
      end
    end

  always @( posedge tx_clk )
    begin
      if (ctl_reg_write_enable_tx_clk_sync == 1'b1) begin
        ctl_tx_send_rfi_out <= ctl_tx_send_rfi_r;
      end
    end

  always @(*)
    begin
      ctl_gt_reset_all_out = ctl_gt_reset_all_r;
    end

  always @(*)
    begin
      ctl_gt_tx_reset_out = ctl_gt_tx_reset_r;
    end

  always @(*)
    begin
      ctl_gt_rx_reset_out = ctl_gt_rx_reset_r;
    end


  reg  [DATA_WIDTH-1:0] write_data_r;
  reg  IP2Bus_WrAck_d1;

  always @( posedge Bus2IP_Clk or negedge AXI_Reset )
    begin
      if ( AXI_Reset != 1'b1 )
      begin
         IP2Bus_WrAck  <= 1'b0;
         IP2Bus_WrAck_d1 <= 1'b0;
         IP2Bus_WrError <= 1'b0;
         write_data_r <= 'b0;
         // Registers resets.
         tick_reg_mode_sel_r <= 'b1;
         ctl_local_loopback_r <= 3'b0;
         tick_reg_r <= 'b0;
         ctl_tx_send_lfi_r <= 'b0;
         ctl_tx_send_idle_r <= 'b0;
         ctl_tx_send_rfi_r <= 'b0;
         user_reg0_r <= 'b0;
         ctl_gt_reset_all_r <= 'b0;
         ctl_gt_tx_reset_r <= 'b0;
         ctl_gt_rx_reset_r <= 'b0;

      end
    else
      begin

         // Self clearing
         tick_reg_r <= 'b0;
         write_data_r <= 'b0;
         IP2Bus_WrAck_d1 <= 1'b0;
         IP2Bus_WrError <= 1'b0;
         //- Write transaction

         if (AXI_write)
          begin
            write_data_r <= Bus2IP_Data_reg;
            case ({Bus2IP_Addr_reg[ADDR_WIDTH-1:2],2'b0})


               'h0400 : begin  // GT_RESET_SOFT_REG
                          ctl_gt_reset_all_r <= Bus2IP_Data_reg[0];
                          ctl_gt_rx_reset_r <= Bus2IP_Data_reg[1];
                          ctl_gt_tx_reset_r <= Bus2IP_Data_reg[2];
                        end

               'h0404 : begin  // CONFIGURATION_TX_SOFT_REG
                          ctl_tx_send_lfi_r <= Bus2IP_Data_reg[0];
                          ctl_tx_send_rfi_r <= Bus2IP_Data_reg[1];
                          ctl_tx_send_idle_r <= Bus2IP_Data_reg[2];
                        end

               'h0408 : begin  // MODE_SOFT_REG
                          tick_reg_mode_sel_r <= Bus2IP_Data_reg[0];
                          ctl_local_loopback_r <= Bus2IP_Data_reg[6:4];
                        end

               'h040C : begin  // TICK_SOFT_REG
                          tick_reg_r <= Bus2IP_Data_reg[0];
                        end

               'h0410 : begin  // USER_SOFT_REG_0
                          user_reg0_r <= Bus2IP_Data_reg[32-1:0];
                        end
              default : begin
                IP2Bus_WrError <= 1'b1;
              end
            endcase
            IP2Bus_WrAck  <= 1'b1;
          end // cs
        else
          begin
            IP2Bus_WrAck  <= 1'b0;
          end // cs
       end // reset
      end // always @ block. WRITE

//
// Setup Stats: latch regs, counters.
//

  wire [48-1:0] stat_rx_bad_fcs_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_bad_fcs_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_bad_fcs ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_bad_fcs_count )
   );


  wire [48-1:0] stat_rx_packet_128_255_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_128_255_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_128_255_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_128_255_bytes_count )
   );


  wire [48-1:0] stat_rx_total_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(4),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_total_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_total_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_total_bytes_count )
   );


  wire [48-1:0] stat_rx_pause_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_pause_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_pause ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_pause_count )
   );


  wire [48-1:0] stat_rx_packet_1523_1548_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_1523_1548_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_1523_1548_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_1523_1548_bytes_count )
   );


  wire [48-1:0] stat_tx_multicast_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_multicast_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_multicast ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_multicast_count )
   );


  wire [48-1:0] stat_tx_packet_4096_8191_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_4096_8191_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_4096_8191_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_4096_8191_bytes_count )
   );


  wire [48-1:0] stat_tx_total_good_packets_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_total_good_packets_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_total_good_packets ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_total_good_packets_count )
   );

  wire [1-1:0] stat_rx_bad_preamble_sync;
  wire [1-1:0] stat_rx_bad_preamble_r = stat_rx_bad_preamble_sync;
  gtfraw_wrapper_syncer_level #(
    .WIDTH        (1)
  ) i_reg_stat_rx_bad_preamble_syncer (
    .clk          (Bus2IP_Clk),
    .reset        (AXI_Reset),
    .datain       (stat_rx_bad_preamble),
    .dataout      (stat_rx_bad_preamble_sync)
  );

  wire [1-1:0] stat_rx_hi_ber_sync;
  wire [1-1:0] stat_rx_hi_ber_r = stat_rx_hi_ber_sync;
  gtfraw_wrapper_syncer_level #(
    .WIDTH        (1)
  ) i_reg_stat_rx_hi_ber_syncer (
    .clk          (Bus2IP_Clk),
    .reset        (AXI_Reset),
    .datain       (stat_rx_hi_ber),
    .dataout      (stat_rx_hi_ber_sync)
  );

  wire [1-1:0] stat_rx_status_sync;
  wire [1-1:0] stat_rx_status_r = stat_rx_status_sync;
  gtfraw_wrapper_syncer_level #(
    .WIDTH        (1)
  ) i_reg_stat_rx_status_syncer (
    .clk          (Bus2IP_Clk),
    .reset        (AXI_Reset),
    .datain       (stat_rx_status),
    .dataout      (stat_rx_status_sync)
  );

  wire [1-1:0] stat_rx_pkt_err_sync;
  wire [1-1:0] stat_rx_pkt_err_r = stat_rx_pkt_err_sync;
  gtfraw_wrapper_syncer_level #(
    .WIDTH        (1)
  ) i_reg_stat_rx_pkt_err_syncer (
    .clk          (Bus2IP_Clk),
    .reset        (AXI_Reset),
    .datain       (stat_rx_pkt_err),
    .dataout      (stat_rx_pkt_err_sync)
  );

  wire [1-1:0] stat_rx_received_local_fault_sync;
  wire [1-1:0] stat_rx_received_local_fault_r = stat_rx_received_local_fault_sync;
  gtfraw_wrapper_syncer_level #(
    .WIDTH        (1)
  ) i_reg_stat_rx_received_local_fault_syncer (
    .clk          (Bus2IP_Clk),
    .reset        (AXI_Reset),
    .datain       (stat_rx_received_local_fault),
    .dataout      (stat_rx_received_local_fault_sync)
  );

  wire [1-1:0] stat_rx_remote_fault_sync;
  wire [1-1:0] stat_rx_remote_fault_r = stat_rx_remote_fault_sync;
  gtfraw_wrapper_syncer_level #(
    .WIDTH        (1)
  ) i_reg_stat_rx_remote_fault_syncer (
    .clk          (Bus2IP_Clk),
    .reset        (AXI_Reset),
    .datain       (stat_rx_remote_fault),
    .dataout      (stat_rx_remote_fault_sync)
  );

  wire [1-1:0] stat_rx_got_signal_os_sync;
  wire [1-1:0] stat_rx_got_signal_os_r = stat_rx_got_signal_os_sync;
  gtfraw_wrapper_syncer_level #(
    .WIDTH        (1)
  ) i_reg_stat_rx_got_signal_os_syncer (
    .clk          (Bus2IP_Clk),
    .reset        (AXI_Reset),
    .datain       (stat_rx_got_signal_os),
    .dataout      (stat_rx_got_signal_os_sync)
  );

  wire [1-1:0] stat_rx_framing_err_sync;
  wire [1-1:0] stat_rx_framing_err_r = stat_rx_framing_err_sync;
  gtfraw_wrapper_syncer_level #(
    .WIDTH        (1)
  ) i_reg_stat_rx_framing_err_syncer (
    .clk          (Bus2IP_Clk),
    .reset        (AXI_Reset),
    .datain       (stat_rx_framing_err),
    .dataout      (stat_rx_framing_err_sync)
  );

  wire [1-1:0] stat_rx_clk_align_sync;
  wire [1-1:0] stat_rx_clk_align_r = stat_rx_clk_align_sync;
  gtfraw_wrapper_syncer_level #(
    .WIDTH        (1)
  ) i_reg_stat_rx_clk_align_syncer (
    .clk          (Bus2IP_Clk),
    .reset        (AXI_Reset),
    .datain       (stat_rx_clk_align),
    .dataout      (stat_rx_clk_align_sync)
  );

  wire [1-1:0] stat_rx_truncated_sync;
  wire [1-1:0] stat_rx_truncated_r = stat_rx_truncated_sync;
  gtfraw_wrapper_syncer_level #(
    .WIDTH        (1)
  ) i_reg_stat_rx_truncated_syncer (
    .clk          (Bus2IP_Clk),
    .reset        (AXI_Reset),
    .datain       (stat_rx_truncated),
    .dataout      (stat_rx_truncated_sync)
  );

  wire [1-1:0] stat_rx_bad_sfd_sync;
  wire [1-1:0] stat_rx_bad_sfd_r = stat_rx_bad_sfd_sync;
  gtfraw_wrapper_syncer_level #(
    .WIDTH        (1)
  ) i_reg_stat_rx_bad_sfd_syncer (
    .clk          (Bus2IP_Clk),
    .reset        (AXI_Reset),
    .datain       (stat_rx_bad_sfd),
    .dataout      (stat_rx_bad_sfd_sync)
  );

  wire [1-1:0] stat_rx_local_fault_sync;
  wire [1-1:0] stat_rx_local_fault_r = stat_rx_local_fault_sync;
  gtfraw_wrapper_syncer_level #(
    .WIDTH        (1)
  ) i_reg_stat_rx_local_fault_syncer (
    .clk          (Bus2IP_Clk),
    .reset        (AXI_Reset),
    .datain       (stat_rx_local_fault),
    .dataout      (stat_rx_local_fault_sync)
  );

  wire [1-1:0] stat_rx_bad_code_sync;
  wire [1-1:0] stat_rx_bad_code_r = stat_rx_bad_code_sync;
  gtfraw_wrapper_syncer_level #(
    .WIDTH        (1)
  ) i_reg_stat_rx_bad_code_syncer (
    .clk          (Bus2IP_Clk),
    .reset        (AXI_Reset),
    .datain       (stat_rx_bad_code),
    .dataout      (stat_rx_bad_code_sync)
  );

  wire [1-1:0] stat_rx_internal_local_fault_sync;
  wire [1-1:0] stat_rx_internal_local_fault_r = stat_rx_internal_local_fault_sync;
  gtfraw_wrapper_syncer_level #(
    .WIDTH        (1)
  ) i_reg_stat_rx_internal_local_fault_syncer (
    .clk          (Bus2IP_Clk),
    .reset        (AXI_Reset),
    .datain       (stat_rx_internal_local_fault),
    .dataout      (stat_rx_internal_local_fault_sync)
  );


  wire [48-1:0] stat_tx_packet_256_511_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_256_511_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_256_511_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_256_511_bytes_count )
   );


  wire [48-1:0] stat_rx_packet_512_1023_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_512_1023_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_512_1023_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_512_1023_bytes_count )
   );


  wire [48-1:0] stat_tx_broadcast_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_broadcast_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_broadcast ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_broadcast_count )
   );


  wire [48-1:0] stat_tx_bad_fcs_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_bad_fcs_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_bad_fcs ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_bad_fcs_count )
   );


  wire [48-1:0] stat_rx_packet_4096_8191_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_4096_8191_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_4096_8191_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_4096_8191_bytes_count )
   );


  wire [48-1:0] stat_tx_packet_2048_4095_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_2048_4095_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_2048_4095_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_2048_4095_bytes_count )
   );


  wire [48-1:0] stat_rx_toolong_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_toolong_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_toolong ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_toolong_count )
   );


  wire [48-1:0] stat_rx_undersize_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_undersize_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_undersize ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_undersize_count )
   );


  wire [48-1:0] stat_rx_packet_64_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_64_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_64_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_64_bytes_count )
   );


  wire [48-1:0] stat_rx_total_err_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(14),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_total_err_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_total_err_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_total_err_bytes_count )
   );


  wire [48-1:0] stat_tx_total_good_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(14),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_total_good_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_total_good_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_total_good_bytes_count )
   );


  wire [48-1:0] stat_tx_total_packets_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_total_packets_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_total_packets ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_total_packets_count )
   );


  wire [48-1:0] stat_tx_packet_1523_1548_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_1523_1548_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_1523_1548_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_1523_1548_bytes_count )
   );


  wire [48-1:0] stat_tx_unicast_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_unicast_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_unicast ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_unicast_count )
   );


  wire [48-1:0] stat_tx_packet_1549_2047_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_1549_2047_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_1549_2047_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_1549_2047_bytes_count )
   );


  wire [48-1:0] stat_tx_packet_8192_9215_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_8192_9215_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_8192_9215_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_8192_9215_bytes_count )
   );


  wire [48-1:0] stat_rx_packet_1024_1518_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_1024_1518_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_1024_1518_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_1024_1518_bytes_count )
   );


  wire [48-1:0] stat_rx_inrangeerr_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_inrangeerr_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_inrangeerr ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_inrangeerr_count )
   );


  wire [48-1:0] stat_rx_packet_65_127_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_65_127_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_65_127_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_65_127_bytes_count )
   );


  wire [48-1:0] stat_rx_total_good_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(14),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_total_good_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_total_good_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_total_good_bytes_count )
   );


  wire [48-1:0] stat_rx_oversize_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_oversize_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_oversize ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_oversize_count )
   );


  wire [48-1:0] stat_rx_bad_code_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_bad_code_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_bad_code ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_bad_code_count )
   );


  wire [48-1:0] stat_tx_packet_65_127_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_65_127_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_65_127_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_65_127_bytes_count )
   );


  wire [48-1:0] stat_rx_packet_256_511_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_256_511_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_256_511_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_256_511_bytes_count )
   );


  wire [48-1:0] stat_tx_vlan_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_vlan_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_vlan ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_vlan_count )
   );


  wire [48-1:0] stat_tx_packet_64_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_64_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_64_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_64_bytes_count )
   );


  wire [48-1:0] stat_rx_vlan_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_vlan_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_vlan ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_vlan_count )
   );


  wire [48-1:0] stat_rx_total_good_packets_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_total_good_packets_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_total_good_packets ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_total_good_packets_count )
   );


  wire [48-1:0] stat_rx_stomped_fcs_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_stomped_fcs_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_stomped_fcs ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_stomped_fcs_count )
   );


  wire [48-1:0] stat_tx_total_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(4),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_total_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_total_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_total_bytes_count )
   );


  wire [48-1:0] stat_tx_packet_128_255_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_128_255_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_128_255_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_128_255_bytes_count )
   );


  wire [48-1:0] stat_rx_user_pause_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_user_pause_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_user_pause ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_user_pause_count )
   );


  wire [48-1:0] stat_rx_broadcast_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_broadcast_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_broadcast ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_broadcast_count )
   );


  wire [48-1:0] stat_tx_total_err_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(14),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_total_err_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_total_err_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_total_err_bytes_count )
   );


  wire [48-1:0] stat_rx_cycle_soft_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_cycle_soft_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_cycle_soft ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_cycle_soft_count )
   );


  wire [48-1:0] stat_tx_cycle_soft_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_cycle_soft_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_cycle_soft ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_cycle_soft_count )
   );


  wire [48-1:0] stat_rx_total_packets_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_total_packets_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_total_packets ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_total_packets_count )
   );


  wire [48-1:0] stat_tx_packet_512_1023_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_512_1023_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_512_1023_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_512_1023_bytes_count )
   );


  wire [48-1:0] stat_tx_frame_error_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_frame_error_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_frame_error ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_frame_error_count )
   );


  wire [48-1:0] stat_rx_packet_1549_2047_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_1549_2047_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_1549_2047_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_1549_2047_bytes_count )
   );


  wire [48-1:0] stat_rx_packet_bad_fcs_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_bad_fcs_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_bad_fcs ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_bad_fcs_count )
   );


  wire [48-1:0] stat_rx_packet_1519_1522_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_1519_1522_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_1519_1522_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_1519_1522_bytes_count )
   );


  wire [48-1:0] stat_rx_fragment_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_fragment_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_fragment ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_fragment_count )
   );


  wire [48-1:0] stat_rx_framing_err_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_framing_err_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_framing_err ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_framing_err_count )
   );


  wire [48-1:0] stat_rx_packet_large_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_large_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_large ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_large_count )
   );


  wire [48-1:0] stat_rx_multicast_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_multicast_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_multicast ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_multicast_count )
   );


  wire [48-1:0] stat_rx_packet_2048_4095_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_2048_4095_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_2048_4095_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_2048_4095_bytes_count )
   );


  wire [48-1:0] stat_tx_packet_small_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_small_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_small ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_small_count )
   );


  wire [48-1:0] stat_rx_packet_8192_9215_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_8192_9215_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_8192_9215_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_8192_9215_bytes_count )
   );


  wire [48-1:0] stat_tx_packet_1519_1522_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_1519_1522_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_1519_1522_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_1519_1522_bytes_count )
   );


  wire [48-1:0] stat_rx_unicast_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_unicast_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_unicast ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_unicast_count )
   );


  wire [48-1:0] stat_rx_jabber_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_jabber_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_jabber ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_jabber_count )
   );


  wire [48-1:0] stat_rx_packet_small_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_small_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_small ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_small_count )
   );


  wire [48-1:0] stat_tx_packet_large_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_large_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_large ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_large_count )
   );


  wire [48-1:0] stat_tx_packet_1024_1518_bytes_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_1024_1518_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_resetn_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_1024_1518_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_1024_1518_bytes_count )
   );


  wire [48-1:0] stat_rx_truncated_count;
  gtfraw_wrapper_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_truncated_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_resetn_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_truncated ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_truncated_count )
   );


  wire tick_rx_clk_not_ready_r = 1'b0;
  wire tick_tx_clk_not_ready_r = 1'b0;


  // read side.
  always @( posedge Bus2IP_Clk or negedge AXI_Reset )
    begin
      if ( AXI_Reset != 1'b1 )
      begin
        IP2Bus_RdAck   <= 1'b0;
        IP2Bus_RdError <= 1'b0;
        IP2Bus_Data    <= 'b0;
        statsreg_read_req <= 1'b0;

      end
    else
      begin

         // clear on read signals.

         //- Read transaction
         IP2Bus_Data    <= 'b0;
         IP2Bus_RdAck   <= 1'b1;
         IP2Bus_RdError <= 1'b0;

         statsreg_read_req <= 1'b0;

         if (Bus2IP_CS_reg & Bus2IP_RNW_reg)
          begin
            case ({Bus2IP_Addr_reg[ADDR_WIDTH-1:2],2'b0})


               'h0400 : begin  // GT_RESET_SOFT_REG
                          IP2Bus_Data[0] <= ctl_gt_reset_all_r;
                          IP2Bus_Data[1] <= ctl_gt_rx_reset_r;
                          IP2Bus_Data[2] <= ctl_gt_tx_reset_r;
                        end

               'h0404 : begin  // CONFIGURATION_TX_SOFT_REG
                          IP2Bus_Data[0] <= ctl_tx_send_lfi_r;
                          IP2Bus_Data[1] <= ctl_tx_send_rfi_r;
                          IP2Bus_Data[2] <= ctl_tx_send_idle_r;
                        end

               'h0408 : begin  // MODE_SOFT_REG
                          IP2Bus_Data[0]   <= tick_reg_mode_sel_r;
                          IP2Bus_Data[6:4] <= ctl_local_loopback_r;
                        end

               'h0410 : begin  // USER_SOFT_REG_0
                          IP2Bus_Data[32-1:0] <= user_reg0_r;
                        end

               'h0500 : begin  // STAT_RX_CYCLE_SOFT_COUNT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_cycle_soft_count[31:0];
                        end

               'h0504 : begin  // STAT_RX_CYCLE_SOFT_COUNT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_cycle_soft_count[47:32];
                        end

               'h0508 : begin  // STAT_TX_CYCLE_SOFT_COUNT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_cycle_soft_count[31:0];
                        end

               'h050C : begin  // STAT_TX_CYCLE_SOFT_COUNT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_cycle_soft_count[47:32];
                        end

               'h0510 : begin  // STAT_RX_RT_STATUS_SOFT_REG1
                          IP2Bus_Data[0] <= stat_rx_status_r;
                          IP2Bus_Data[1] <= stat_rx_hi_ber_r;
                          IP2Bus_Data[2] <= stat_rx_remote_fault_r;
                          IP2Bus_Data[3] <= stat_rx_local_fault_r;
                          IP2Bus_Data[4] <= stat_rx_internal_local_fault_r;
                          IP2Bus_Data[5] <= stat_rx_received_local_fault_r;
                          IP2Bus_Data[6] <= stat_rx_bad_preamble_r;
                          IP2Bus_Data[7] <= stat_rx_bad_sfd_r;
                          IP2Bus_Data[8] <= stat_rx_got_signal_os_r;
                          IP2Bus_Data[9] <= stat_rx_bad_code_r;
                          IP2Bus_Data[11] <= stat_rx_framing_err_r;
                          IP2Bus_Data[12] <= stat_rx_pkt_err_r;
                          IP2Bus_Data[13] <= stat_rx_truncated_r;
                          IP2Bus_Data[14] <= stat_rx_clk_align_r;
                        end

               'h0648 : begin  // STAT_RX_FRAMING_ERR_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_framing_err_count[31:0];
                        end

               'h064C : begin  // STAT_RX_FRAMING_ERR_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_framing_err_count[47:32];
                        end

               'h0660 : begin  // STAT_RX_BAD_CODE_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_bad_code_count[31:0];
                        end

               'h0664 : begin  // STAT_RX_BAD_CODE_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_bad_code_count[47:32];
                        end

               'h06A0 : begin  // STAT_TX_FRAME_ERROR_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_frame_error_count[31:0];
                        end

               'h06A4 : begin  // STAT_TX_FRAME_ERROR_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_frame_error_count[47:32];
                        end

               'h0700 : begin  // STAT_TX_TOTAL_PACKETS_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_total_packets_count[31:0];
                        end

               'h0704 : begin  // STAT_TX_TOTAL_PACKETS_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_total_packets_count[47:32];
                        end

               'h0708 : begin  // STAT_TX_TOTAL_GOOD_PACKETS_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_total_good_packets_count[31:0];
                        end

               'h070C : begin  // STAT_TX_TOTAL_GOOD_PACKETS_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_total_good_packets_count[47:32];
                        end

               'h0710 : begin  // STAT_TX_TOTAL_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_total_bytes_count[31:0];
                        end

               'h0714 : begin  // STAT_TX_TOTAL_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_total_bytes_count[47:32];
                        end

               'h0718 : begin  // STAT_TX_TOTAL_GOOD_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_total_good_bytes_count[31:0];
                        end

               'h071C : begin  // STAT_TX_TOTAL_GOOD_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_total_good_bytes_count[47:32];
                        end

               'h0720 : begin  // STAT_TX_PACKET_64_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_packet_64_bytes_count[31:0];
                        end

               'h0724 : begin  // STAT_TX_PACKET_64_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_packet_64_bytes_count[47:32];
                        end

               'h0728 : begin  // STAT_TX_PACKET_65_127_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_packet_65_127_bytes_count[31:0];
                        end

               'h072C : begin  // STAT_TX_PACKET_65_127_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_packet_65_127_bytes_count[47:32];
                        end

               'h0730 : begin  // STAT_TX_PACKET_128_255_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_packet_128_255_bytes_count[31:0];
                        end

               'h0734 : begin  // STAT_TX_PACKET_128_255_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_packet_128_255_bytes_count[47:32];
                        end

               'h0738 : begin  // STAT_TX_PACKET_256_511_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_packet_256_511_bytes_count[31:0];
                        end

               'h073C : begin  // STAT_TX_PACKET_256_511_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_packet_256_511_bytes_count[47:32];
                        end

               'h0740 : begin  // STAT_TX_PACKET_512_1023_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_packet_512_1023_bytes_count[31:0];
                        end

               'h0744 : begin  // STAT_TX_PACKET_512_1023_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_packet_512_1023_bytes_count[47:32];
                        end

               'h0748 : begin  // STAT_TX_PACKET_1024_1518_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_packet_1024_1518_bytes_count[31:0];
                        end

               'h074C : begin  // STAT_TX_PACKET_1024_1518_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_packet_1024_1518_bytes_count[47:32];
                        end

               'h0750 : begin  // STAT_TX_PACKET_1519_1522_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_packet_1519_1522_bytes_count[31:0];
                        end

               'h0754 : begin  // STAT_TX_PACKET_1519_1522_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_packet_1519_1522_bytes_count[47:32];
                        end

               'h0758 : begin  // STAT_TX_PACKET_1523_1548_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_packet_1523_1548_bytes_count[31:0];
                        end

               'h075C : begin  // STAT_TX_PACKET_1523_1548_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_packet_1523_1548_bytes_count[47:32];
                        end

               'h0760 : begin  // STAT_TX_PACKET_1549_2047_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_packet_1549_2047_bytes_count[31:0];
                        end

               'h0764 : begin  // STAT_TX_PACKET_1549_2047_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_packet_1549_2047_bytes_count[47:32];
                        end

               'h0768 : begin  // STAT_TX_PACKET_2048_4095_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_packet_2048_4095_bytes_count[31:0];
                        end

               'h076C : begin  // STAT_TX_PACKET_2048_4095_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_packet_2048_4095_bytes_count[47:32];
                        end

               'h0770 : begin  // STAT_TX_PACKET_4096_8191_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_packet_4096_8191_bytes_count[31:0];
                        end

               'h0774 : begin  // STAT_TX_PACKET_4096_8191_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_packet_4096_8191_bytes_count[47:32];
                        end

               'h0778 : begin  // STAT_TX_PACKET_8192_9215_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_packet_8192_9215_bytes_count[31:0];
                        end

               'h077C : begin  // STAT_TX_PACKET_8192_9215_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_packet_8192_9215_bytes_count[47:32];
                        end

               'h0780 : begin  // STAT_TX_PACKET_LARGE_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_packet_large_count[31:0];
                        end

               'h0784 : begin  // STAT_TX_PACKET_LARGE_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_packet_large_count[47:32];
                        end

               'h0788 : begin  // STAT_TX_PACKET_SMALL_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_packet_small_count[31:0];
                        end

               'h078C : begin  // STAT_TX_PACKET_SMALL_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_packet_small_count[47:32];
                        end

               'h07B8 : begin  // STAT_TX_BAD_FCS_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_bad_fcs_count[31:0];
                        end

               'h07BC : begin  // STAT_TX_BAD_FCS_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_bad_fcs_count[47:32];
                        end

               'h07D0 : begin  // STAT_TX_UNICAST_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_unicast_count[31:0];
                        end

               'h07D4 : begin  // STAT_TX_UNICAST_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_unicast_count[47:32];
                        end

               'h07D8 : begin  // STAT_TX_MULTICAST_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_multicast_count[31:0];
                        end

               'h07DC : begin  // STAT_TX_MULTICAST_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_multicast_count[47:32];
                        end

               'h07E0 : begin  // STAT_TX_BROADCAST_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_broadcast_count[31:0];
                        end

               'h07E4 : begin  // STAT_TX_BROADCAST_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_broadcast_count[47:32];
                        end

               'h07E8 : begin  // STAT_TX_VLAN_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_vlan_count[31:0];
                        end

               'h07EC : begin  // STAT_TX_VLAN_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_vlan_count[47:32];
                        end

               'h0808 : begin  // STAT_RX_TOTAL_PACKETS_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_total_packets_count[31:0];
                        end

               'h080C : begin  // STAT_RX_TOTAL_PACKETS_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_total_packets_count[47:32];
                        end

               'h0810 : begin  // STAT_RX_TOTAL_GOOD_PACKETS_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_total_good_packets_count[31:0];
                        end

               'h0814 : begin  // STAT_RX_TOTAL_GOOD_PACKETS_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_total_good_packets_count[47:32];
                        end

               'h0818 : begin  // STAT_RX_TOTAL_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_total_bytes_count[31:0];
                        end

               'h081C : begin  // STAT_RX_TOTAL_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_total_bytes_count[47:32];
                        end

               'h0820 : begin  // STAT_RX_TOTAL_GOOD_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_total_good_bytes_count[31:0];
                        end

               'h0824 : begin  // STAT_RX_TOTAL_GOOD_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_total_good_bytes_count[47:32];
                        end

               'h0828 : begin  // STAT_RX_PACKET_64_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_packet_64_bytes_count[31:0];
                        end

               'h082C : begin  // STAT_RX_PACKET_64_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_packet_64_bytes_count[47:32];
                        end

               'h0830 : begin  // STAT_RX_PACKET_65_127_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_packet_65_127_bytes_count[31:0];
                        end

               'h0834 : begin  // STAT_RX_PACKET_65_127_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_packet_65_127_bytes_count[47:32];
                        end

               'h0838 : begin  // STAT_RX_PACKET_128_255_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_packet_128_255_bytes_count[31:0];
                        end

               'h083C : begin  // STAT_RX_PACKET_128_255_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_packet_128_255_bytes_count[47:32];
                        end

               'h0840 : begin  // STAT_RX_PACKET_256_511_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_packet_256_511_bytes_count[31:0];
                        end

               'h0844 : begin  // STAT_RX_PACKET_256_511_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_packet_256_511_bytes_count[47:32];
                        end

               'h0848 : begin  // STAT_RX_PACKET_512_1023_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_packet_512_1023_bytes_count[31:0];
                        end

               'h084C : begin  // STAT_RX_PACKET_512_1023_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_packet_512_1023_bytes_count[47:32];
                        end

               'h0850 : begin  // STAT_RX_PACKET_1024_1518_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_packet_1024_1518_bytes_count[31:0];
                        end

               'h0854 : begin  // STAT_RX_PACKET_1024_1518_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_packet_1024_1518_bytes_count[47:32];
                        end

               'h0858 : begin  // STAT_RX_PACKET_1519_1522_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_packet_1519_1522_bytes_count[31:0];
                        end

               'h085C : begin  // STAT_RX_PACKET_1519_1522_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_packet_1519_1522_bytes_count[47:32];
                        end

               'h0860 : begin  // STAT_RX_PACKET_1523_1548_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_packet_1523_1548_bytes_count[31:0];
                        end

               'h0864 : begin  // STAT_RX_PACKET_1523_1548_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_packet_1523_1548_bytes_count[47:32];
                        end

               'h0868 : begin  // STAT_RX_PACKET_1549_2047_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_packet_1549_2047_bytes_count[31:0];
                        end

               'h086C : begin  // STAT_RX_PACKET_1549_2047_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_packet_1549_2047_bytes_count[47:32];
                        end

               'h0870 : begin  // STAT_RX_PACKET_2048_4095_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_packet_2048_4095_bytes_count[31:0];
                        end

               'h0874 : begin  // STAT_RX_PACKET_2048_4095_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_packet_2048_4095_bytes_count[47:32];
                        end

               'h0878 : begin  // STAT_RX_PACKET_4096_8191_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_packet_4096_8191_bytes_count[31:0];
                        end

               'h087C : begin  // STAT_RX_PACKET_4096_8191_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_packet_4096_8191_bytes_count[47:32];
                        end

               'h0880 : begin  // STAT_RX_PACKET_8192_9215_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_packet_8192_9215_bytes_count[31:0];
                        end

               'h0884 : begin  // STAT_RX_PACKET_8192_9215_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_packet_8192_9215_bytes_count[47:32];
                        end

               'h0888 : begin  // STAT_RX_PACKET_LARGE_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_packet_large_count[31:0];
                        end

               'h088C : begin  // STAT_RX_PACKET_LARGE_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_packet_large_count[47:32];
                        end

               'h0890 : begin  // STAT_RX_PACKET_SMALL_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_packet_small_count[31:0];
                        end

               'h0894 : begin  // STAT_RX_PACKET_SMALL_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_packet_small_count[47:32];
                        end

               'h0898 : begin  // STAT_RX_UNDERSIZE_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_undersize_count[31:0];
                        end

               'h089C : begin  // STAT_RX_UNDERSIZE_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_undersize_count[47:32];
                        end

               'h08A0 : begin  // STAT_RX_FRAGMENT_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_fragment_count[31:0];
                        end

               'h08A4 : begin  // STAT_RX_FRAGMENT_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_fragment_count[47:32];
                        end

               'h08A8 : begin  // STAT_RX_OVERSIZE_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_oversize_count[31:0];
                        end

               'h08AC : begin  // STAT_RX_OVERSIZE_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_oversize_count[47:32];
                        end

               'h08B0 : begin  // STAT_RX_TOOLONG_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_toolong_count[31:0];
                        end

               'h08B4 : begin  // STAT_RX_TOOLONG_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_toolong_count[47:32];
                        end

               'h08B8 : begin  // STAT_RX_JABBER_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_jabber_count[31:0];
                        end

               'h08BC : begin  // STAT_RX_JABBER_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_jabber_count[47:32];
                        end

               'h08C0 : begin  // STAT_RX_BAD_FCS_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_bad_fcs_count[31:0];
                        end

               'h08C4 : begin  // STAT_RX_BAD_FCS_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_bad_fcs_count[47:32];
                        end

               'h08C8 : begin  // STAT_RX_PACKET_BAD_FCS_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_packet_bad_fcs_count[31:0];
                        end

               'h08CC : begin  // STAT_RX_PACKET_BAD_FCS_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_packet_bad_fcs_count[47:32];
                        end

               'h08D0 : begin  // STAT_RX_STOMPED_FCS_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_stomped_fcs_count[31:0];
                        end

               'h08D4 : begin  // STAT_RX_STOMPED_FCS_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_stomped_fcs_count[47:32];
                        end

               'h08D8 : begin  // STAT_RX_UNICAST_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_unicast_count[31:0];
                        end

               'h08DC : begin  // STAT_RX_UNICAST_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_unicast_count[47:32];
                        end

               'h08E0 : begin  // STAT_RX_MULTICAST_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_multicast_count[31:0];
                        end

               'h08E4 : begin  // STAT_RX_MULTICAST_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_multicast_count[47:32];
                        end

               'h08E8 : begin  // STAT_RX_BROADCAST_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_broadcast_count[31:0];
                        end

               'h08EC : begin  // STAT_RX_BROADCAST_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_broadcast_count[47:32];
                        end

               'h08F0 : begin  // STAT_RX_VLAN_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_vlan_count[31:0];
                        end

               'h08F4 : begin  // STAT_RX_VLAN_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_vlan_count[47:32];
                        end

               'h08F8 : begin  // STAT_RX_PAUSE_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_pause_count[31:0];
                        end

               'h08FC : begin  // STAT_RX_PAUSE_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_pause_count[47:32];
                        end

               'h0900 : begin  // STAT_RX_USER_PAUSE_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_user_pause_count[31:0];
                        end

               'h0904 : begin  // STAT_RX_USER_PAUSE_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_user_pause_count[47:32];
                        end

               'h0908 : begin  // STAT_RX_INRANGEERR_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_inrangeerr_count[31:0];
                        end

               'h090C : begin  // STAT_RX_INRANGEERR_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_inrangeerr_count[47:32];
                        end

               'h0910 : begin  // STAT_RX_TRUNCATED_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_truncated_count[31:0];
                        end

               'h0914 : begin  // STAT_RX_TRUNCATED_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_truncated_count[47:32];
                        end

               'h0950 : begin  // STAT_TX_TOTAL_ERR_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_tx_total_err_bytes_count[31:0];
                        end

               'h0954 : begin  // STAT_TX_TOTAL_ERR_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_tx_total_err_bytes_count[47:32];
                        end

               'h0958 : begin  // STAT_RX_TOTAL_ERR_BYTES_SOFT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[32-1:0] <= stat_rx_total_err_bytes_count[31:0];
                        end

               'h095C : begin  // STAT_RX_TOTAL_ERR_BYTES_SOFT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;

                          IP2Bus_Data[16-1:0] <= stat_rx_total_err_bytes_count[47:32];
                        end
              default : begin
                IP2Bus_RdError  <= 1'b1;
              end
            endcase
          end
        else
          begin
            IP2Bus_RdAck  <= 1'b0;
          end
        end
      end // always @ block. READ



  wire pm_tick_sync;

  gtfraw_wrapper_syncer_level #(
    .WIDTH        (1)
  ) i_reg_pm_tick_syncer (
    .clk          (Bus2IP_Clk),
    .reset        (AXI_Reset),
    .datain       (pm_tick),
    .dataout      (pm_tick_sync )
  );

  gtfraw_wrapper_syncer_pulse i_pmtick_rx_clk_syncer (

  .clkin        ( Bus2IP_Clk ),
  .clkin_reset  ( 1'b1 ),
  .clkout       ( rx_clk ),
  .clkout_reset ( rx_resetn ),
  .pulsein      ( tick_r ),  // clkin domain
  .pulseout     ( rx_clk_tick_retimed )  // clkout domain
  );

  assign rx_clk_tick_r = rx_clk_tick_retimed;

  gtfraw_wrapper_syncer_pulse i_pmtick_tx_clk_syncer (

  .clkin        ( Bus2IP_Clk ),
  .clkin_reset  ( 1'b1 ),
  .clkout       ( tx_clk ),
  .clkout_reset ( tx_resetn ),
  .pulsein      ( tick_r ),  // clkin domain
  .pulseout     ( tx_clk_tick_retimed )  // clkout domain
  );

  assign tx_clk_tick_r = tx_clk_tick_retimed;

  reg  [3:0] tick_rr;
  wire tick_out;

  assign tick_out = tick_reg_mode_sel_r ? tick_reg_r : pm_tick_sync;

  always @( posedge Bus2IP_Clk or negedge AXI_Reset )
    begin
      if ( AXI_Reset != 1'b1 )
        begin
          tick_r  <= 1'b0;
          tick_rr <=  'b0;
        end
      else
        begin
          tick_r  <= ~tick_rr[3] && tick_rr[2];
          tick_rr <= {tick_rr[2:0], tick_out};
        end
    end

  wire rx_clk_statsreg_read_req_sync;
  wire tx_clk_statsreg_read_req_sync;
  wire axi_rx_clk_statsreg_hold_sync;
  wire axi_tx_clk_statsreg_hold_sync;
  wire statsreg_hold_sync;
  reg  statsreg_hold_sync_d1;

  gtfraw_wrapper_syncer_level #(
    .WIDTH        (1)
  ) i_statsreg_read_req_rx_clk_syncer (
    .clk          (rx_clk),
    .reset        (AXI_Reset_rx_clk_sync),
    .datain       (statsreg_read_req),
    .dataout      (rx_clk_statsreg_read_req_sync)
  );

  assign rx_clk_statsreg_hold = rx_clk_statsreg_read_req_sync;


  assign rx_clk_statsreg_hold_r = rx_clk_statsreg_hold;

  gtfraw_wrapper_syncer_level #(
    .WIDTH        (1)
  ) i_rx_clk_statsreg_hold_syncer (
    .clk         ( Bus2IP_Clk ),
    .reset       ( AXI_Reset ),
    .datain      ( rx_clk_statsreg_hold_r ),
    .dataout     ( axi_rx_clk_statsreg_hold_sync )
  );

  gtfraw_wrapper_syncer_level #(
    .WIDTH        (1)
  ) i_statsreg_read_req_tx_clk_syncer (
    .clk          (tx_clk),
    .reset        (AXI_Reset_tx_clk_sync),
    .datain       (statsreg_read_req),
    .dataout      (tx_clk_statsreg_read_req_sync)
  );

  assign tx_clk_statsreg_hold = tx_clk_statsreg_read_req_sync;


  assign tx_clk_statsreg_hold_r = tx_clk_statsreg_hold;

  gtfraw_wrapper_syncer_level #(
    .WIDTH        (1)
  ) i_tx_clk_statsreg_hold_syncer (
    .clk         ( Bus2IP_Clk ),
    .reset       ( AXI_Reset ),
    .datain      ( tx_clk_statsreg_hold_r ),
    .dataout     ( axi_tx_clk_statsreg_hold_sync )
  );

  assign statsreg_hold_sync = axi_rx_clk_statsreg_hold_sync & axi_tx_clk_statsreg_hold_sync;

  always @( posedge Bus2IP_Clk or negedge AXI_Reset )
    begin
      if ( AXI_Reset != 1'b1 )
        begin
          statsreg_read_ack     <= 1'b0;
          statsreg_hold_sync_d1 <= 1'b0;
        end
      else
        begin
          statsreg_hold_sync_d1 <= statsreg_hold_sync;
          statsreg_read_ack     <= statsreg_hold_sync & ~statsreg_hold_sync_d1;
        end
    end

  always @( posedge Bus2IP_Clk or negedge AXI_Reset )
    begin
      if ( AXI_Reset != 1'b1 )
        begin
          timeout_counter <= 7'd0;
          timeout_error   <= 1'b0;
        end
      else
        begin
          timeout_error <= &timeout_counter;
          if (Bus2IP_CS_reg & Bus2IP_RNW_reg)
            timeout_counter <= timeout_counter + 1;
          else
            timeout_counter <= 7'd0;
        end
    end

endmodule
