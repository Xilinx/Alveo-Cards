/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

module gtfmac_wrapper_wrapper_stats_gasket (

  input  wire        tx_axis_tpoison,
  input  wire [ 7:0] tx_axis_tlast,
  input  wire [ 4:0] tx_axis_tterm,
  input  wire        tx_axis_tready,

  input  wire        ctl_rx_data_rate,
  input  wire        ctl_rx_ignore_fcs,
  input  wire [7:0]  ctl_rx_min_packet_len,
  input  wire [15:0] ctl_rx_max_packet_len,
  input  wire        ctl_tx_data_rate,
  input  wire        ctl_tx_fcs_ins_enable,
  input  wire        ctl_tx_ignore_fcs,
  input  wire        ctl_tx_packet_framing_enable,

  input  wire [3:0]  gtfmac_stat_rx_bytes,
  input  wire        gtfmac_stat_rx_pkt,
  input  wire        gtfmac_stat_rx_pkt_err,
  input  wire        gtfmac_stat_rx_truncated,
  input  wire        gtfmac_stat_rx_bad_fcs,
  input  wire        gtfmac_stat_rx_stomped_fcs,
                     
  input  reg         gtfmac_stat_rx_unicast,
  input  reg         gtfmac_stat_rx_multicast,
  input  reg         gtfmac_stat_rx_broadcast,
  input  reg         gtfmac_stat_rx_vlan,
  input  reg         gtfmac_stat_rx_inrangeerr,
                     
  output wire        stat_rx_unicast,
  output wire        stat_rx_multicast,
  output wire        stat_rx_broadcast,
  output wire        stat_rx_vlan,
  output wire        stat_rx_inrangeerr,
  output wire        stat_rx_bad_fcs,

  output wire  [ 3:0] stat_rx_total_bytes            ,
  output wire  [13:0] stat_rx_total_err_bytes        ,
  output wire  [13:0] stat_rx_total_good_bytes       ,
  output wire         stat_rx_total_packets          ,
  output wire         stat_rx_total_good_packets     ,
  output wire         stat_rx_packet_64_bytes        ,
  output wire         stat_rx_packet_65_127_bytes    ,
  output wire         stat_rx_packet_128_255_bytes   ,
  output wire         stat_rx_packet_256_511_bytes   ,
  output wire         stat_rx_packet_512_1023_bytes  ,
  output wire         stat_rx_packet_1024_1518_bytes ,
  output wire         stat_rx_packet_1519_1522_bytes ,
  output wire         stat_rx_packet_1523_1548_bytes ,
  output wire         stat_rx_packet_1549_2047_bytes ,
  output wire         stat_rx_packet_2048_4095_bytes ,
  output wire         stat_rx_packet_4096_8191_bytes ,
  output wire         stat_rx_packet_8192_9215_bytes ,
  output wire         stat_rx_oversize               ,
  output wire         stat_rx_undersize              ,
  output wire         stat_rx_toolong                ,
  output wire         stat_rx_packet_small           ,
  output wire         stat_rx_packet_large           ,
  output wire         stat_rx_user_pause             ,
  output wire         stat_rx_pause                  ,
  output wire         stat_rx_jabber                 ,
  output wire         stat_rx_fragment               ,
  output wire         stat_rx_packet_bad_fcs         ,

  input  wire [3:0]   gtfmac_stat_tx_bytes,
  input  wire         gtfmac_stat_tx_pkt,
  input  wire         gtfmac_stat_tx_pkt_err,
  input  wire         gtfmac_stat_tx_bad_fcs,
  input  wire         gtfmac_stat_tx_multicast,
  input  wire         gtfmac_stat_tx_unicast  ,
  input  wire         gtfmac_stat_tx_broadcast,
  input  wire         gtfmac_stat_tx_vlan     ,
                      
  output wire         stat_tx_bad_fcs               ,
  output wire         stat_tx_broadcast             ,
  output wire         stat_tx_multicast             ,
  output wire         stat_tx_unicast               ,
  output wire         stat_tx_vlan                  ,


  output wire [ 3:0] stat_tx_total_bytes            ,
  output wire [13:0] stat_tx_total_err_bytes        ,
  output wire [13:0] stat_tx_total_good_bytes       ,
  output wire        stat_tx_total_packets          ,
  output wire        stat_tx_total_good_packets     ,
  output wire        stat_tx_packet_64_bytes        ,
  output wire        stat_tx_packet_65_127_bytes    ,
  output wire        stat_tx_packet_128_255_bytes   ,
  output wire        stat_tx_packet_256_511_bytes   ,
  output wire        stat_tx_packet_512_1023_bytes  ,
  output wire        stat_tx_packet_1024_1518_bytes ,
  output wire        stat_tx_packet_1519_1522_bytes ,
  output wire        stat_tx_packet_1523_1548_bytes ,
  output wire        stat_tx_packet_1549_2047_bytes ,
  output wire        stat_tx_packet_2048_4095_bytes ,
  output wire        stat_tx_packet_4096_8191_bytes ,
  output wire        stat_tx_packet_8192_9215_bytes ,
  output wire        stat_tx_packet_small           ,
  output wire        stat_tx_packet_large           ,
  output wire        stat_tx_frame_error            ,

  input  wire  [8:0] gtfmac_rx_pause_quanta,
  input  wire  [8:0] gtfmac_rx_pause_req   ,
  //output reg   [8:0] gtfmac_rx_pause_ack   ,
  input  wire        gtfmac_rx_pause_valid ,

  output wire [15:0] stat_rx_pause_quanta0          ,
  output wire [15:0] stat_rx_pause_quanta1          ,
  output wire [15:0] stat_rx_pause_quanta2          ,
  output wire [15:0] stat_rx_pause_quanta3          ,
  output wire [15:0] stat_rx_pause_quanta4          ,
  output wire [15:0] stat_rx_pause_quanta5          ,
  output wire [15:0] stat_rx_pause_quanta6          ,
  output wire [15:0] stat_rx_pause_quanta7          ,
  output wire [15:0] stat_rx_pause_quanta8          ,
  output wire [ 8:0] stat_rx_pause_valid            ,
  output wire [ 8:0] stat_rx_pause_req              ,
  //input  wire [ 8:0] stat_rx_pause_ack   ,

  input  wire rx_clk,
  input  wire tx_clk,
  input  wire rx_reset,
  input  wire tx_reset
);

    assign stat_rx_unicast                    = 'h0;
    assign stat_rx_multicast                  = 'h0;
    assign stat_rx_broadcast                  = 'h0;
    assign stat_rx_vlan                       = 'h0;
    assign stat_rx_inrangeerr                 = 'h0;
    assign stat_rx_bad_fcs                    = 'h0;

    assign stat_rx_total_bytes                = 'h0;
    assign stat_rx_total_err_bytes            = 'h0;
    assign stat_rx_total_good_bytes           = 'h0;
    assign stat_rx_total_packets              = 'h0;
    assign stat_rx_total_good_packets         = 'h0;
    assign stat_rx_packet_64_bytes            = 'h0;
    assign stat_rx_packet_65_127_bytes        = 'h0;
    assign stat_rx_packet_128_255_bytes       = 'h0;
    assign stat_rx_packet_256_511_bytes       = 'h0;
    assign stat_rx_packet_512_1023_bytes      = 'h0;
    assign stat_rx_packet_1024_1518_bytes     = 'h0;
    assign stat_rx_packet_1519_1522_bytes     = 'h0;
    assign stat_rx_packet_1523_1548_bytes     = 'h0;
    assign stat_rx_packet_1549_2047_bytes     = 'h0;
    assign stat_rx_packet_2048_4095_bytes     = 'h0;
    assign stat_rx_packet_4096_8191_bytes     = 'h0;
    assign stat_rx_packet_8192_9215_bytes     = 'h0;
    assign stat_rx_oversize                   = 'h0;
    assign stat_rx_undersize                  = 'h0;
    assign stat_rx_toolong                    = 'h0;
    assign stat_rx_packet_small               = 'h0;
    assign stat_rx_packet_large               = 'h0;
    assign stat_rx_user_pause                 = 'h0;
    assign stat_rx_pause                      = 'h0;
    assign stat_rx_jabber                     = 'h0;
    assign stat_rx_fragment                   = 'h0;
    assign stat_rx_packet_bad_fcs             = 'h0;

    assign stat_tx_bad_fcs                    = 'h0;
    assign stat_tx_broadcast                  = 'h0;
    assign stat_tx_multicast                  = 'h0;
    assign stat_tx_unicast                    = 'h0;
    assign stat_tx_vlan                       = 'h0;

    assign stat_tx_total_bytes                = 'h0;
    assign stat_tx_total_err_bytes            = 'h0;
    assign stat_tx_total_good_bytes           = 'h0;
    assign stat_tx_total_packets              = 'h0;
    assign stat_tx_total_good_packets         = 'h0;
    assign stat_tx_packet_64_bytes            = 'h0;
    assign stat_tx_packet_65_127_bytes        = 'h0;
    assign stat_tx_packet_128_255_bytes       = 'h0;
    assign stat_tx_packet_256_511_bytes       = 'h0;
    assign stat_tx_packet_512_1023_bytes      = 'h0;
    assign stat_tx_packet_1024_1518_bytes     = 'h0;
    assign stat_tx_packet_1519_1522_bytes     = 'h0;
    assign stat_tx_packet_1523_1548_bytes     = 'h0;
    assign stat_tx_packet_1549_2047_bytes     = 'h0;
    assign stat_tx_packet_2048_4095_bytes     = 'h0;
    assign stat_tx_packet_4096_8191_bytes     = 'h0;
    assign stat_tx_packet_8192_9215_bytes     = 'h0;
    assign stat_tx_packet_small               = 'h0;
    assign stat_tx_packet_large               = 'h0;
    assign stat_tx_frame_error                = 'h0;
    assign stat_rx_pause_quanta0              = 'h0;
    assign stat_rx_pause_quanta1              = 'h0;
    assign stat_rx_pause_quanta2              = 'h0;
    assign stat_rx_pause_quanta3              = 'h0;
    assign stat_rx_pause_quanta4              = 'h0;
    assign stat_rx_pause_quanta5              = 'h0;
    assign stat_rx_pause_quanta6              = 'h0;
    assign stat_rx_pause_quanta7              = 'h0;
    assign stat_rx_pause_quanta8              = 'h0;
    assign stat_rx_pause_valid                = 'h0;
    assign stat_rx_pause_req                  = 'h0;

/*
  wire [8:0]  gtfmac_stat_tx_pause_valid     ;
  reg         stat_tx_user_pause             ;
  reg         stat_tx_pause                  ;

  reg  [15:0] rx_byte_count, tx_byte_count;
  reg  [15:0] reg_rx_byte_count, saved_rx_byte_count;
  reg         rx_is_oversize;
  reg         reg_rx_pkt, reg_tx_pkt;
  reg         reg_rx_pkt_stall;
  reg         reg_rx_pkt_done;
  reg  [ 3:0] reg_rx_bytes, reg_tx_bytes;
  reg         reg_tx_tpoison;
  reg  [ 3:0] pipe_tx_last;
  reg         reg_tx_poison_fcs;
  reg         del_tpoison;
  reg  [ 3:0] tpoison_cnt;
  reg         reg_rx_pkt_err, reg_tx_pkt_err;
  reg         reg_rx_pkt_err_early;
  reg         reg_rx_inrange_err, saved_rx_inrange_err;
  reg         reg_rx_fcs_err, saved_rx_fcs_err;
  reg         reg_rx_unicast, reg_rx_multicast, reg_rx_broadcast, reg_rx_vlan;
  reg         saved_rx_unicast, saved_rx_multicast, saved_rx_broadcast, saved_rx_vlan;
  reg         reg_rx_was_truncated, saved_rx_was_truncated;
  reg  [ 4:0] reg_rx_late_error_count;

  reg  [ 5:0] [15:0] pipe_tx_byte_count ;
  reg  [ 5:0] [ 3:0] pipe_tx_bytes;
  reg  [ 5:0]        pipe_tx_pkt        ;
  reg  [ 5:0]        pipe_tx_pkt_err    ;
  reg  [ 5:0]        pipe_tx_bad_pkt    ;
  reg  [ 5:0]        pipe_tx_broadcast  ;
  reg  [ 5:0]        pipe_tx_multicast  ;
  reg  [ 5:0]        pipe_tx_unicast    ;
  reg  [ 5:0]        pipe_tx_vlan       ;
  reg  [ 5:0]        pipe_tx_bad_fcs    ;

  reg         reg_tx_broadcast;
  reg         reg_tx_multicast;
  reg         reg_tx_unicast  ;
  reg         reg_tx_vlan     ;
  reg         reg_tx_fcs_err;
  reg         reg_rx_bad_fcs;

  assign stat_rx_bad_fcs = reg_rx_bad_fcs;

  wire        pipe_tx_pkt_out        = pipe_tx_pkt       [ 5];
  wire        pipe_tx_pkt_err_out    = pipe_tx_pkt_err   [ 5];
  wire        pipe_tx_bad_pkt_out    = pipe_tx_bad_pkt   [ 5];
  wire        pipe_tx_broadcast_out  = pipe_tx_broadcast [ 5];
  wire        pipe_tx_multicast_out  = pipe_tx_multicast [ 5];
  wire        pipe_tx_unicast_out    = pipe_tx_unicast   [ 5];
  wire        pipe_tx_vlan_out       = pipe_tx_vlan      [ 5];
  wire [15:0] pipe_tx_byte_count_out = pipe_tx_byte_count[ 5];
  wire [ 3:0] pipe_tx_bytes_out      = pipe_tx_bytes     [ 5];
  wire        pipe_tx_bad_fcs_out    = pipe_tx_bad_fcs   [ 5];

  always@(*) begin
    stat_rx_total_bytes   = reg_rx_bytes;
    stat_rx_total_packets = reg_rx_pkt_done;

    rx_is_oversize = reg_rx_was_truncated | ( (|reg_rx_byte_count[15:14]) && ~&ctl_rx_max_packet_len); // || (reg_rx_byte_count > ctl_rx_max_packet_len);

    if(reg_rx_pkt_done) begin
      if(reg_rx_pkt_err || reg_rx_inrange_err || (reg_rx_fcs_err && !ctl_rx_ignore_fcs) || rx_is_oversize) begin
        stat_rx_total_err_bytes        = (|reg_rx_byte_count[15:14]) ? 14'h3FFF : reg_rx_byte_count[13:0];
        stat_rx_total_good_bytes       = 0;
        stat_rx_total_good_packets     = 0;
        stat_rx_multicast              = 0;
        stat_rx_broadcast              = 0;
        stat_rx_unicast                = 0;
        stat_rx_vlan                   = 0;
      end
      else begin
        stat_rx_total_err_bytes        = 0;
        stat_rx_total_good_bytes       = (|reg_rx_byte_count[15:14]) ? 14'h3FFF : reg_rx_byte_count[13:0];
        stat_rx_total_good_packets     = 1'b1;
        stat_rx_multicast              = reg_rx_multicast;
        stat_rx_broadcast              = reg_rx_broadcast;
        stat_rx_unicast                = reg_rx_unicast  ;
        stat_rx_vlan                   = reg_rx_vlan     ;
      end
      if(reg_rx_fcs_err) begin
        stat_rx_jabber         = rx_is_oversize && !ctl_rx_ignore_fcs;
        stat_rx_fragment       = (reg_rx_byte_count < ctl_rx_min_packet_len) && !ctl_rx_ignore_fcs;
        stat_rx_packet_bad_fcs = !reg_rx_was_truncated && (reg_rx_byte_count>=16'd64);
      end
      else begin
        stat_rx_jabber         = 0;
        stat_rx_fragment       = 0;
        stat_rx_packet_bad_fcs = 0;
      end
      stat_rx_packet_64_bytes        = (reg_rx_byte_count ==   64                         );
      stat_rx_packet_65_127_bytes    = (reg_rx_byte_count >=   65 && reg_rx_byte_count <=  127);
      stat_rx_packet_128_255_bytes   = (reg_rx_byte_count >=  128 && reg_rx_byte_count <=  255);
      stat_rx_packet_256_511_bytes   = (reg_rx_byte_count >=  256 && reg_rx_byte_count <=  511);
      stat_rx_packet_512_1023_bytes  = (reg_rx_byte_count >=  512 && reg_rx_byte_count <= 1023);
      stat_rx_packet_1024_1518_bytes = (reg_rx_byte_count >= 1024 && reg_rx_byte_count <= 1518);
      stat_rx_packet_1519_1522_bytes = (reg_rx_byte_count >= 1519 && reg_rx_byte_count <= 1522);
      stat_rx_packet_1523_1548_bytes = (reg_rx_byte_count >= 1523 && reg_rx_byte_count <= 1548);
      stat_rx_packet_1549_2047_bytes = (reg_rx_byte_count >= 1549 && reg_rx_byte_count <= 2047);
      stat_rx_packet_2048_4095_bytes = (reg_rx_byte_count >= 2048 && reg_rx_byte_count <= 4095);
      stat_rx_packet_4096_8191_bytes = (reg_rx_byte_count >= 4096 && reg_rx_byte_count <= 8191);
      stat_rx_packet_8192_9215_bytes = (reg_rx_byte_count >= 8192 && reg_rx_byte_count <= 9215);
      stat_rx_oversize               = (ctl_rx_ignore_fcs || !reg_rx_fcs_err) && rx_is_oversize;
      stat_rx_undersize              = (ctl_rx_ignore_fcs || !reg_rx_fcs_err) && (reg_rx_byte_count < ctl_rx_min_packet_len         );
      stat_rx_packet_small           = (reg_rx_byte_count <64                             );
      stat_rx_packet_large           = (reg_rx_byte_count >9215                           );
      stat_rx_toolong                = (rx_is_oversize                                );
      stat_rx_inrangeerr             = reg_rx_inrange_err && !(reg_rx_fcs_err && !ctl_rx_ignore_fcs) && !reg_rx_pkt_err;
    end
    else begin
      stat_rx_total_err_bytes        =  'h0;
      stat_rx_total_good_bytes       =  'h0;
      stat_rx_total_good_packets     =  'h0;
      stat_rx_packet_64_bytes        = 1'b0;
      stat_rx_packet_65_127_bytes    = 1'b0;
      stat_rx_packet_128_255_bytes   = 1'b0;
      stat_rx_packet_256_511_bytes   = 1'b0;
      stat_rx_packet_512_1023_bytes  = 1'b0;
      stat_rx_packet_1024_1518_bytes = 1'b0;
      stat_rx_packet_1519_1522_bytes = 1'b0;
      stat_rx_packet_1523_1548_bytes = 1'b0;
      stat_rx_packet_1549_2047_bytes = 1'b0;
      stat_rx_packet_2048_4095_bytes = 1'b0;
      stat_rx_packet_4096_8191_bytes = 1'b0;
      stat_rx_packet_8192_9215_bytes = 1'b0;
      stat_rx_oversize               = 1'b0;
      stat_rx_undersize              = 1'b0;
      stat_rx_packet_small           = 1'b0;
      stat_rx_packet_large           = 1'b0;
      stat_rx_toolong                = 1'b0;
      stat_rx_jabber                 = 1'b0;
      stat_rx_fragment               = 1'b0;
      stat_rx_packet_bad_fcs         = 1'b0;
      stat_rx_multicast              = 1'b0;
      stat_rx_broadcast              = 1'b0;
      stat_rx_unicast                = 1'b0;
      stat_rx_vlan                   = 1'b0;
      stat_rx_inrangeerr             = 1'b0;
    end

    stat_tx_total_bytes   = pipe_tx_bytes_out;
    stat_tx_total_packets = pipe_tx_pkt_out;
    stat_tx_frame_error   = pipe_tx_pkt_err_out;
    stat_tx_bad_fcs       = pipe_tx_bad_fcs_out;
    stat_tx_broadcast     = pipe_tx_broadcast_out;
    stat_tx_multicast     = pipe_tx_multicast_out;
    stat_tx_unicast       = pipe_tx_unicast_out;
    stat_tx_vlan          = pipe_tx_vlan_out;

    if(pipe_tx_pkt_out) begin
      if(pipe_tx_bad_pkt_out) begin
        stat_tx_total_err_bytes        = pipe_tx_byte_count_out;
        stat_tx_total_good_bytes       = 0;
        stat_tx_total_good_packets     = 0;
      end
      else begin
        stat_tx_total_err_bytes        = 0;
        stat_tx_total_good_bytes       = pipe_tx_byte_count_out;
        stat_tx_total_good_packets     = 1'b1;
      end
      stat_tx_packet_64_bytes        = (pipe_tx_byte_count_out ==   64                         );
      stat_tx_packet_65_127_bytes    = (pipe_tx_byte_count_out >=   65 && pipe_tx_byte_count_out <=  127);
      stat_tx_packet_128_255_bytes   = (pipe_tx_byte_count_out >=  128 && pipe_tx_byte_count_out <=  255);
      stat_tx_packet_256_511_bytes   = (pipe_tx_byte_count_out >=  256 && pipe_tx_byte_count_out <=  511);
      stat_tx_packet_512_1023_bytes  = (pipe_tx_byte_count_out >=  512 && pipe_tx_byte_count_out <= 1023);
      stat_tx_packet_1024_1518_bytes = (pipe_tx_byte_count_out >= 1024 && pipe_tx_byte_count_out <= 1518);
      stat_tx_packet_1519_1522_bytes = (pipe_tx_byte_count_out >= 1519 && pipe_tx_byte_count_out <= 1522);
      stat_tx_packet_1523_1548_bytes = (pipe_tx_byte_count_out >= 1523 && pipe_tx_byte_count_out <= 1548);
      stat_tx_packet_1549_2047_bytes = (pipe_tx_byte_count_out >= 1549 && pipe_tx_byte_count_out <= 2047);
      stat_tx_packet_2048_4095_bytes = (pipe_tx_byte_count_out >= 2048 && pipe_tx_byte_count_out <= 4095);
      stat_tx_packet_4096_8191_bytes = (pipe_tx_byte_count_out >= 4096 && pipe_tx_byte_count_out <= 8191);
      stat_tx_packet_8192_9215_bytes = (pipe_tx_byte_count_out >= 8192 && pipe_tx_byte_count_out <= 9215);
      stat_tx_packet_small           = (pipe_tx_byte_count_out <64                             );
      stat_tx_packet_large           = (pipe_tx_byte_count_out >9215                           );
    end
    else begin
      stat_tx_total_err_bytes        =  'h0;
      stat_tx_total_good_bytes       =  'h0;
      stat_tx_total_good_packets     =  'h0;
      stat_tx_packet_64_bytes        = 1'b0;
      stat_tx_packet_65_127_bytes    = 1'b0;
      stat_tx_packet_128_255_bytes   = 1'b0;
      stat_tx_packet_256_511_bytes   = 1'b0;
      stat_tx_packet_512_1023_bytes  = 1'b0;
      stat_tx_packet_1024_1518_bytes = 1'b0;
      stat_tx_packet_1519_1522_bytes = 1'b0;
      stat_tx_packet_1523_1548_bytes = 1'b0;
      stat_tx_packet_1549_2047_bytes = 1'b0;
      stat_tx_packet_2048_4095_bytes = 1'b0;
      stat_tx_packet_4096_8191_bytes = 1'b0;
      stat_tx_packet_8192_9215_bytes = 1'b0;
      stat_tx_packet_small           = 1'b0;
      stat_tx_packet_large           = 1'b0;
    end

  end

  always@(posedge rx_clk or negedge rx_reset)
    if(!rx_reset) begin
      rx_byte_count <= 'h0;
      reg_rx_pkt    <= 'h0;
      reg_rx_pkt_stall    <= 'h0;
      reg_rx_pkt_err<= 'h0;
      reg_rx_pkt_err_early <= 'h0;
      reg_rx_fcs_err<= 'h0;
      reg_rx_bytes  <= 'h0;
      reg_rx_late_error_count <= 'h0;
      reg_rx_inrange_err <= 'b0;
      reg_rx_byte_count <= 'h0;
      reg_rx_unicast <='b0;
      reg_rx_broadcast <='b0;
      reg_rx_multicast <='b0;
      reg_rx_vlan <='b0;
      reg_rx_pkt_done    <= 1'b0;
      saved_rx_byte_count     <= 16'b0;
      saved_rx_inrange_err <=  1'b0;
      saved_rx_fcs_err     <=  1'b0;
      saved_rx_multicast      <=  1'b0;
      saved_rx_broadcast      <=  1'b0;
      saved_rx_unicast        <=  1'b0;
      saved_rx_vlan           <=  1'b0;
      saved_rx_was_truncated  <=  1'b0;
      reg_rx_bad_fcs          <= 'h0;
    end
    else begin
      reg_rx_bytes   <= gtfmac_stat_rx_bytes;
      reg_rx_pkt     <= gtfmac_stat_rx_pkt;

      if (rx_byte_count + gtfmac_stat_rx_bytes >= 16'hffff) rx_byte_count <= 16'hffff;
      else rx_byte_count <= rx_byte_count + gtfmac_stat_rx_bytes;
      if(reg_rx_pkt) begin
        rx_byte_count <= gtfmac_stat_rx_bytes;
      end

      reg_rx_pkt_done           <= 1'b0;
      reg_rx_pkt_err_early      <= (gtfmac_stat_rx_pkt_err || reg_rx_pkt_err_early) && !reg_rx_pkt_stall;
      if(reg_rx_late_error_count>0) reg_rx_late_error_count <= reg_rx_late_error_count-1;
      if(gtfmac_stat_rx_pkt) begin
        if(!(gtfmac_stat_rx_pkt_err || reg_rx_pkt_err_early)) reg_rx_late_error_count <= ctl_rx_data_rate ? 5'd3 : 5'd9;
        else if (reg_rx_pkt_stall)                     reg_rx_late_error_count <= 5'd0;
        reg_rx_pkt_stall        <=!(gtfmac_stat_rx_pkt_err || reg_rx_pkt_err_early || (gtfmac_stat_rx_bad_fcs & !ctl_rx_ignore_fcs)) || reg_rx_pkt_stall;
        reg_rx_pkt_done         <= (gtfmac_stat_rx_pkt_err || reg_rx_pkt_err_early || (gtfmac_stat_rx_bad_fcs && !ctl_rx_ignore_fcs));
        reg_rx_pkt_err          <= (reg_rx_pkt_stall ? 1'b0 : gtfmac_stat_rx_pkt_err) || reg_rx_pkt_err_early;
        reg_rx_pkt_err_early    <= reg_rx_pkt_err_early ? gtfmac_stat_rx_pkt_err : reg_rx_pkt_stall && gtfmac_stat_rx_pkt_err;  //if err_early then back-to-back errors
        saved_rx_byte_count     <= gtfmac_stat_rx_bytes + (reg_rx_pkt ? 16'b0 : rx_byte_count);
        saved_rx_inrange_err    <= gtfmac_stat_rx_inrangeerr;
        saved_rx_fcs_err        <= gtfmac_stat_rx_bad_fcs | gtfmac_stat_rx_stomped_fcs;
        saved_rx_multicast      <= gtfmac_stat_rx_multicast;
        saved_rx_broadcast      <= gtfmac_stat_rx_broadcast;
        saved_rx_unicast        <= gtfmac_stat_rx_unicast;
        saved_rx_vlan           <= gtfmac_stat_rx_vlan;
        saved_rx_was_truncated  <= gtfmac_stat_rx_truncated;
        if(reg_rx_pkt_stall) begin
          reg_rx_byte_count     <= reg_rx_byte_count    ;
          reg_rx_inrange_err    <= reg_rx_inrange_err;
          reg_rx_fcs_err        <= reg_rx_fcs_err    ;
          reg_rx_multicast      <= reg_rx_multicast     ;
          reg_rx_broadcast      <= reg_rx_broadcast     ;
          reg_rx_unicast        <= reg_rx_unicast       ;
          reg_rx_vlan           <= reg_rx_vlan          ;
          reg_rx_was_truncated  <= reg_rx_was_truncated ;
        end
        else begin
          reg_rx_byte_count     <= gtfmac_stat_rx_bytes + (reg_rx_pkt ? 16'b0 : rx_byte_count);
          reg_rx_inrange_err    <= gtfmac_stat_rx_inrangeerr;
          reg_rx_fcs_err        <= gtfmac_stat_rx_bad_fcs | gtfmac_stat_rx_stomped_fcs | (reg_rx_pkt && gtfmac_stat_rx_pkt);
          reg_rx_multicast      <= gtfmac_stat_rx_multicast;
          reg_rx_broadcast      <= gtfmac_stat_rx_broadcast;
          reg_rx_unicast        <= gtfmac_stat_rx_unicast;
          reg_rx_vlan           <= gtfmac_stat_rx_vlan;
          reg_rx_was_truncated  <= gtfmac_stat_rx_truncated;
        end
      end
      else if(reg_rx_pkt_stall && ((reg_rx_late_error_count==5'b0) || gtfmac_stat_rx_pkt_err || (|gtfmac_stat_rx_bytes))) begin
        reg_rx_pkt_stall        <= 1'b0;
        reg_rx_pkt_done         <= 1'b1;
        reg_rx_pkt_err          <= gtfmac_stat_rx_pkt_err || reg_rx_pkt_err_early;
        reg_rx_late_error_count <= 5'b0;
        reg_rx_pkt_err_early    <= 1'b0;
        reg_rx_byte_count       <= saved_rx_byte_count;
        reg_rx_inrange_err      <= saved_rx_inrange_err;
        reg_rx_fcs_err          <= saved_rx_fcs_err    ;
        reg_rx_multicast        <= saved_rx_multicast     ;
        reg_rx_broadcast        <= saved_rx_broadcast     ;
        reg_rx_unicast          <= saved_rx_unicast       ;
        reg_rx_vlan             <= saved_rx_vlan          ;
        reg_rx_was_truncated    <= saved_rx_was_truncated ;
      end
      else if(reg_rx_pkt_done) begin
        reg_rx_pkt_err          <= 1'b0;
        reg_rx_pkt_err_early    <= 1'b0;
      end
      reg_rx_bad_fcs            <= gtfmac_stat_rx_bad_fcs  || (reg_rx_pkt && gtfmac_stat_rx_pkt) ;
    end

  always@(posedge tx_clk or negedge tx_reset)
    if(!tx_reset) begin
      tx_byte_count <= 'h0;
      reg_tx_bytes  <= 'h0;
      reg_tx_pkt    <= 'h0;
      reg_tx_pkt_err<= 'h0;
      reg_tx_fcs_err<= 'h0;
      stat_tx_pause       <= 'h0;
      stat_tx_user_pause  <= 'h0;
      pipe_tx_bad_fcs   [ 5:0] <= 'h0;
      pipe_tx_pkt_err   [ 5:0] <= 'h0;
      pipe_tx_bad_pkt   [ 5:0] <= 'h0;
      pipe_tx_broadcast [ 5:0] <= 'h0;
      pipe_tx_multicast [ 5:0] <= 'h0;
      pipe_tx_unicast [ 5:0] <= 'h0;
      pipe_tx_vlan      [ 5:0] <= 'h0;
      pipe_tx_pkt       [ 5:0] <= 'h0;
      pipe_tx_byte_count[ 5:0] <= 'h0;
      pipe_tx_bytes     [ 5:0] <= 'h0;
      pipe_tx_last   <= 'h0;
      reg_tx_broadcast  <= 'h0;
      reg_tx_multicast  <= 'h0;
      reg_tx_unicast    <= 'h0;
      reg_tx_vlan       <= 'h0;
      reg_tx_poison_fcs <= 'h0;
      reg_tx_tpoison   <= 'h0;
      del_tpoison   <= 'h0;
      tpoison_cnt <= 'h0;
    end
    else begin
      pipe_tx_pkt       [ 5:0] <= {pipe_tx_pkt        [ 4:0],reg_tx_pkt};
      pipe_tx_broadcast [ 5:0] <= {pipe_tx_broadcast  [ 4] && !(reg_tx_tpoison && pipe_tx_pkt[4]),
                                   pipe_tx_broadcast  [ 3] && !(reg_tx_tpoison && pipe_tx_pkt[3]),
                                   pipe_tx_broadcast  [2:0],
                                   reg_tx_broadcast};
      pipe_tx_multicast [ 5:0] <= {pipe_tx_multicast  [ 4] && !(reg_tx_tpoison && pipe_tx_pkt[4]),
                                   pipe_tx_multicast  [ 3] && !(reg_tx_tpoison && pipe_tx_pkt[3]),
                                   pipe_tx_multicast  [2:0],
                                   reg_tx_multicast};
      pipe_tx_unicast [ 5:0] <=   {pipe_tx_unicast  [ 4] && !(reg_tx_tpoison && pipe_tx_pkt[4]),
                                   pipe_tx_unicast  [ 3] && !(reg_tx_tpoison && pipe_tx_pkt[3]),
                                   pipe_tx_unicast  [2:0],
                                   reg_tx_unicast};
      pipe_tx_vlan    [ 5:0] <=   {pipe_tx_vlan     [ 4] && !(reg_tx_tpoison && pipe_tx_pkt[4]),
                                   pipe_tx_vlan     [ 3] && !(reg_tx_tpoison && pipe_tx_pkt[3]),
                                   pipe_tx_vlan     [2:0],
                                   reg_tx_vlan   };
      pipe_tx_pkt_err   [ 5:0] <= {pipe_tx_pkt_err    [   4] || (reg_tx_tpoison && pipe_tx_pkt[4]),
                                   pipe_tx_pkt_err    [   3] || (reg_tx_tpoison && pipe_tx_pkt[3]),
                                   pipe_tx_pkt_err    [   2] ,
                                   pipe_tx_pkt_err    [   1] ,
                                   pipe_tx_pkt_err    [   0] ,
                                   reg_tx_pkt && reg_tx_pkt_err};
      pipe_tx_bad_pkt   [ 5:0] <= {pipe_tx_bad_pkt    [   4] || (reg_tx_tpoison && pipe_tx_pkt[4]),
                                   pipe_tx_bad_pkt    [   3] || (reg_tx_tpoison && pipe_tx_pkt[3]),
                                   pipe_tx_bad_pkt    [   2] ,
                                   pipe_tx_bad_pkt    [   1] ,
                                   pipe_tx_bad_pkt    [   0] ,
                                   reg_tx_pkt && (reg_tx_pkt_err || (tx_byte_count < 64) || (reg_tx_fcs_err && !ctl_tx_ignore_fcs)) };
      pipe_tx_byte_count[ 5:0] <= {pipe_tx_byte_count [ 4:0],reg_tx_pkt ? tx_byte_count : 16'b0};
      pipe_tx_bytes     [ 5:0] <= {pipe_tx_bytes      [ 4:0],reg_tx_bytes                      };
      pipe_tx_bad_fcs   [ 5:0] <= {pipe_tx_bad_fcs[ 4:0],reg_tx_fcs_err}; // ||(reg_tx_poison_fcs && reg_tx_pkt)};

      if (tx_byte_count + gtfmac_stat_tx_bytes >= 14'h3fff) tx_byte_count <= 14'h3fff;
      else tx_byte_count <= tx_byte_count + gtfmac_stat_tx_bytes;
      if(reg_tx_pkt) tx_byte_count <= gtfmac_stat_tx_bytes;

      reg_tx_broadcast <= gtfmac_stat_tx_broadcast;
      reg_tx_multicast <= gtfmac_stat_tx_multicast;
      reg_tx_unicast   <= gtfmac_stat_tx_unicast  ;
      reg_tx_vlan      <= gtfmac_stat_tx_vlan     ;
      reg_tx_fcs_err <= gtfmac_stat_tx_bad_fcs;
      reg_tx_bytes   <= gtfmac_stat_tx_bytes;
      reg_tx_pkt     <= gtfmac_stat_tx_pkt;
      reg_tx_pkt_err <= gtfmac_stat_tx_pkt_err;
      stat_tx_pause  <= gtfmac_stat_tx_pause_valid[8];
      stat_tx_user_pause  <= |gtfmac_stat_tx_pause_valid[7:0];

      //TPOISON LOGIC
      if(tx_axis_tready) pipe_tx_last[3:0] <= {pipe_tx_last[2:0],1'b0};
      reg_tx_poison_fcs <= (reg_tx_poison_fcs || (pipe_tx_last[3] && reg_tx_tpoison));
      if(ctl_tx_data_rate==1'b0) begin  //ctl_tx_data_rate=1 (10G)
        if(ctl_tx_packet_framing_enable==1'b0) begin    //Early EOP Mode
          if(tx_axis_tlast>8'h0) begin
            reg_tx_tpoison <= tx_axis_tpoison;
            tpoison_cnt <= 4'h7;
            if(ctl_tx_fcs_ins_enable==1'b0) pipe_tx_last[3:0] <= {pipe_tx_last[2:0],1'h1};
            else                            pipe_tx_last[3:0] <= {pipe_tx_last[2  ],3'h4};
            reg_tx_poison_fcs <= 1'b0;
          end
          else begin
            if(tpoison_cnt > 0) begin
              reg_tx_tpoison <= reg_tx_tpoison || tx_axis_tpoison;
              //a stall in the first three cycles should not affect the count
              if(ctl_tx_fcs_ins_enable==1'b0) begin
                tpoison_cnt <= (tpoison_cnt>4'h4) ? tpoison_cnt - tx_axis_tready : tpoison_cnt -1;
              end
              else  begin
                tpoison_cnt <= (tpoison_cnt>4'h6) ? tpoison_cnt - tx_axis_tready : tpoison_cnt -1;
              end
            end
            //else reg_tx_tpoison <= 'h0;
          end
        end //!ctl_tx_packet_framing_enable
        else begin  //Packet Framing Mode
          del_tpoison <= tx_axis_tpoison;  //Use for tterm=='h10
          if(tx_axis_tterm!=5'h0) begin
            reg_tx_tpoison <= tx_axis_tpoison || ((tx_axis_tterm==5'h10) && del_tpoison);
            reg_tx_poison_fcs <= 1'b0;
            if(ctl_tx_fcs_ins_enable==1'b0) begin
              tpoison_cnt <= 4'h7;
              pipe_tx_last[3:0] <= {pipe_tx_last[2:0],1'h1};
            end
            else begin
              tpoison_cnt <= (tx_axis_tterm>=5'h14) ? 4'hb : 4'h7; //based on tterm select how long to watch for tpoison
              pipe_tx_last[3:0] <= {pipe_tx_last[2  ],3'h4};
            end
          end
          else begin
            if(tpoison_cnt > 0) begin
              reg_tx_tpoison <= reg_tx_tpoison || tx_axis_tpoison;
              tpoison_cnt <= tpoison_cnt -1;
            end
            //else reg_tx_tpoison <= 'h0;
          end
        end
      end //ctl_tx_data_rate= 0 (10G)
      else begin //ctl_tx_data_rate= 1 (25G)
        if(ctl_tx_packet_framing_enable==1'b0) begin   //Early EOP mode
          if(tx_axis_tlast>8'b0) begin
            reg_tx_tpoison <= tx_axis_tpoison;
            if (ctl_tx_fcs_ins_enable==1'b0 && tx_axis_tlast>8'h2)       tpoison_cnt <= 4'h3;
            else if (ctl_tx_fcs_ins_enable==1'b1 && tx_axis_tlast>8'h20) tpoison_cnt <= 4'h3;
            else                                                         tpoison_cnt <= 4'h2;
            if(tx_axis_tlast>8'h2) pipe_tx_last[3:0] <= {pipe_tx_last[2],3'h4}; //tlast in the next cycle
            else                   pipe_tx_last[3:0] <=                   4'h8 ; //tlast in the current cycle
            reg_tx_poison_fcs <= 1'b0;
          end
          else begin
            if(tpoison_cnt > 0) begin
              reg_tx_tpoison <= reg_tx_tpoison || tx_axis_tpoison;
              tpoison_cnt <= (tpoison_cnt>4'h2) ? tpoison_cnt - tx_axis_tready : tpoison_cnt -1;
            end
            //else reg_tx_tpoison <= 'h0;
          end
        end
        else begin //Packet Framing Mode
          del_tpoison <= tx_axis_tpoison;  //Use for tterm=='h10
          if(tx_axis_tterm!=5'h0) begin
            reg_tx_tpoison <= tx_axis_tpoison || ((tx_axis_tterm==5'h10) && del_tpoison);
            tpoison_cnt <= 4'h2;
          end
          else begin
            if(tpoison_cnt > 0) begin
              reg_tx_tpoison <= reg_tx_tpoison || tx_axis_tpoison;
              tpoison_cnt <= tpoison_cnt -1;
            end
            //else reg_tx_tpoison <= 'h0;
          end
        end
      end
    end



  reg   [15:0] quanta0;
  reg   [15:0] quanta1;
  reg   [15:0] quanta2;
  reg   [15:0] quanta3;
  reg   [15:0] quanta4;
  reg   [15:0] quanta5;
  reg   [15:0] quanta6;
  reg   [15:0] quanta7;
  reg   [15:0] quanta8;
  reg   [ 8:0] valid;
  reg   [ 7:0] qerr  ;
  reg   [ 4:0] count;
  reg          active;
  reg          ready;

  wire gtfmac_rx_pause_start = gtfmac_rx_pause_quanta[8];

  always@(posedge rx_clk or negedge rx_reset)
  if(!rx_reset) begin
    quanta0 <= 16'b0;
    quanta1 <= 16'b0;
    quanta2 <= 16'b0;
    quanta3 <= 16'b0;
    quanta4 <= 16'b0;
    quanta5 <= 16'b0;
    quanta6 <= 16'b0;
    quanta7 <= 16'b0;
    quanta8 <= 16'b0;
    valid <= 9'b0;
    qerr   <= 8'b0;
    count <= 6'b0;
    active <= 1'b0;
    ready <= 1'b0;
    stat_rx_user_pause <=0;
    stat_rx_pause <=0;
    stat_rx_pause_valid <=0;
    stat_rx_pause_req <= 0;
  end
  else begin
    stat_rx_pause_req <= gtfmac_rx_pause_req;

    if(active) begin
      count <= count + 1;
      stat_rx_user_pause <= 1'b0;
      stat_rx_pause <= 1'b0;
      case(count)
        5'd1 : begin quanta0[ 7:0] <= gtfmac_rx_pause_quanta[7:0];                                    end
        5'd2 : begin quanta1[15:8] <= gtfmac_rx_pause_quanta[7:0]; valid[1] <= gtfmac_rx_pause_valid; end
        5'd3 : begin quanta1[ 7:0] <= gtfmac_rx_pause_quanta[7:0]; stat_rx_user_pause <= gtfmac_rx_pause_valid; end
        5'd4 : begin quanta2[15:8] <= gtfmac_rx_pause_quanta[7:0]; valid[2] <= gtfmac_rx_pause_valid; end
        5'd5 : begin quanta2[ 7:0] <= gtfmac_rx_pause_quanta[7:0]; stat_rx_user_pause <= gtfmac_rx_pause_valid; end
        5'd6 : begin quanta3[15:8] <= gtfmac_rx_pause_quanta[7:0]; valid[3] <= gtfmac_rx_pause_valid; end
        5'd7 : begin quanta3[ 7:0] <= gtfmac_rx_pause_quanta[7:0]; stat_rx_user_pause <= gtfmac_rx_pause_valid; end
        5'd8 : begin quanta4[15:8] <= gtfmac_rx_pause_quanta[7:0]; valid[4] <= gtfmac_rx_pause_valid; end
        5'd9 : begin quanta4[ 7:0] <= gtfmac_rx_pause_quanta[7:0]; stat_rx_pause <= gtfmac_rx_pause_valid; end
        5'd10: begin quanta5[15:8] <= gtfmac_rx_pause_quanta[7:0]; valid[5] <= gtfmac_rx_pause_valid; end
        5'd11: begin quanta5[ 7:0] <= gtfmac_rx_pause_quanta[7:0]; stat_rx_pause <= gtfmac_rx_pause_valid; end
        5'd12: begin quanta6[15:8] <= gtfmac_rx_pause_quanta[7:0]; valid[6] <= gtfmac_rx_pause_valid; end
        5'd13: begin quanta6[ 7:0] <= gtfmac_rx_pause_quanta[7:0]; stat_rx_pause <= gtfmac_rx_pause_valid; end
        5'd14: begin quanta7[15:8] <= gtfmac_rx_pause_quanta[7:0]; valid[7] <= gtfmac_rx_pause_valid; end
        5'd15: begin quanta7[ 7:0] <= gtfmac_rx_pause_quanta[7:0];                                    end
        5'd16: begin quanta8[15:8] <= gtfmac_rx_pause_quanta[7:0]; valid[8] <= gtfmac_rx_pause_valid; end
        5'd17: begin quanta8[ 7:0] <= gtfmac_rx_pause_quanta[7:0];
                     active <=0; ready<=1; count<=0;
                     stat_rx_pause_valid <=   valid;
                    //  stat_rx_pause       <=   valid[8]   &&  !gtfmac_rx_pause_valid;
                    //  stat_rx_user_pause  <=  !valid[8]   &&  !(|qerr [7:0])        ;
               end
        default:begin
                     stat_rx_pause      <= 0;
                     stat_rx_user_pause <= 0;
                     active <= 0; ready <= 0;
                end
      endcase
    end
    else begin
        ready <= 1'b0;
        stat_rx_pause_valid <= 9'b0;
        stat_rx_pause       <= 1'b0;
        stat_rx_user_pause  <= 1'b0;
      if(gtfmac_rx_pause_start) begin
        active        <= 1'b1;
        count         <= 6'b1;
        quanta0[15:8] <= gtfmac_rx_pause_quanta[7:0];
        valid[0]      <= gtfmac_rx_pause_valid;
      end
    end

  end

  always@(*) begin
    stat_rx_pause_quanta0 = ready ?  quanta0 : 16'b0;
    stat_rx_pause_quanta1 = ready ?  quanta1 : 16'b0;
    stat_rx_pause_quanta2 = ready ?  quanta2 : 16'b0;
    stat_rx_pause_quanta3 = ready ?  quanta3 : 16'b0;
    stat_rx_pause_quanta4 = ready ?  quanta4 : 16'b0;
    stat_rx_pause_quanta5 = ready ?  quanta5 : 16'b0;
    stat_rx_pause_quanta6 = ready ?  quanta6 : 16'b0;
    stat_rx_pause_quanta7 = ready ?  quanta7 : 16'b0;
    stat_rx_pause_quanta8 = ready ?  quanta8 : 16'b0;
    //gtfmac_rx_pause_ack   = stat_rx_pause_ack      ;
  end
*/

endmodule
