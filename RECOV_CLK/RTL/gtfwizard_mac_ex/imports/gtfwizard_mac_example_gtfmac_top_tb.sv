/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------


`timescale 1ps/1ps
module gtfwizard_mac_gtfmac_ex_sim ();

   parameter integer NUM_CHANNEL = 1; 


    reg refclk;
    reg freerun_clk;

    initial
    begin
      refclk = 0;
      forever
      begin
        refclk = #3103  ~refclk;
      end
    end

    initial
    begin
      freerun_clk = 0;
      forever
      begin
        freerun_clk = #1666  ~freerun_clk;
      
      end
    end

    reg hb_gtwiz_reset_all_in = 1'b1;
    initial begin
      hb_gtwiz_reset_all_in = 1'b1;
      repeat (1000) @(posedge freerun_clk);
      hb_gtwiz_reset_all_in = 1'b0;
    end

    initial
    begin
       if($time == 2000000000)  begin
         $display("\nTB_GTF_MAC : simination time out\n");
         $finish;
       end  
    end

    // Declare registers and wires to interface to the PRBS-based link status ports
    reg  link_down_latched_reset = 1'b0;
    wire link_status;
    wire link_down_latched;
    wire i_gtwiz_reset_tx_done_out;
    wire i_gtwiz_reset_rx_done_out;
    wire i_gtf_cm_qpll0_lock;
    wire clk_wiz_locked_out;


    reg simulation_timeout_check = 1'b0;
    initial begin
    // Create a basic timeout indicator which is used to abort the simulation of no link is achieved after 15ms
      simulation_timeout_check = 1'b0;
      #15E13;
      simulation_timeout_check = 1'b1;
    end

    // Create a basic stable link monitor which is set after 2048 consecutive cycles of link up and is reset after any
    // link loss
    reg [10:0] link_up_ctr = 11'd0;
    reg        link_stable = 1'b0;
    always @(posedge freerun_clk) begin
      if (link_status !== 1'b1) begin
        link_up_ctr <= 11'd0;
        link_stable <= 1'b0;
      end
      else begin
        if (&link_up_ctr)
          link_stable <= 1'b1;
        else
          link_up_ctr <= link_up_ctr + 11'd1;
      end
    end
    
    wire serial_p,serial_n;
    

    /////////////////////////////////////////////////////////////////////////////////////////////
    //  HWCHK Test 
    /////////////////////////////////////////////////////////////////////////////////////////////

    int frames_received_0;
    

    bit [0:0] frame_gen_ready;
    bit [0:0] frame_stat_ready;

       logic               axi_aclk;
    logic               axi_aresetn;

    logic   [31:0]      s_axil_araddr;
    logic               s_axil_arvalid;
    logic               s_axil_rready;
    logic   [31:0]      s_axil_awaddr;
    logic               s_axil_awvalid;
    logic   [31:0]      s_axil_wdata;
    logic               s_axil_wvalid;
    logic               s_axil_bready;
    logic   [2 : 0]     s_axil_awprot;
    logic   [3 : 0]     s_axil_wstrb;
    logic   [2 : 0]     s_axil_arprot;

    logic               s_axil_arready;
    logic   [31:0]      s_axil_rdata;
    logic   [1:0]       s_axil_rresp;
    logic               s_axil_rvalid;
    logic               s_axil_awready;
    logic               s_axil_wready;
    logic               s_axil_bvalid;
    logic   [1:0]       s_axil_bresp;


    logic               s_axi_rd_busy;
    logic               s_axi_wr_busy;
    logic               wa_complete_flg;

   
    initial begin
        s_axil_araddr     = 'd0;
        s_axil_arvalid    = 'd0;
        s_axil_rready     = 'd0;
        s_axil_awaddr     = 'd0;
        s_axil_awvalid    = 'd0;
        s_axil_wdata      = 'd0;
        s_axil_wvalid     = 'd0;
        s_axil_bready     = 'd0;
        s_axil_awprot     = 'd0;
        s_axil_wstrb      = 'd0;
        s_axil_arprot     = 'd0;

        s_axi_rd_busy     = 'd0;
        s_axi_wr_busy     = 'd0;

        force   gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.s_axil_awaddr    = s_axil_awaddr;
        force   gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.s_axil_awprot    = s_axil_awprot;
        force   gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.s_axil_awvalid   = s_axil_awvalid;
        force   gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.s_axil_wdata     = s_axil_wdata;
        force   gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.s_axil_wstrb     = s_axil_wstrb;
        force   gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.s_axil_wvalid    = s_axil_wvalid;
        force   gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.s_axil_bready    = s_axil_bready;
        force   gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.s_axil_araddr    = s_axil_araddr;
        force   gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.s_axil_arprot    = s_axil_arprot;
        force   gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.s_axil_arvalid   = s_axil_arvalid;
        force   gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.s_axil_rready    = s_axil_rready;

        force   axi_aclk                        = gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.axi_aclk;
        force   axi_aresetn                     = gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.axi_aresetn;

        force   s_axil_arready                  = gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.s_axil_arready;
        force   s_axil_rdata                    = gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.s_axil_rdata;
        force   s_axil_rresp                    = gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.s_axil_rresp;
        force   s_axil_rvalid                   = gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.s_axil_rvalid;
        force   s_axil_awready                  = gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.s_axil_awready;
        force   s_axil_wready                   = gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.s_axil_wready;
        force   s_axil_bvalid                   = gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.s_axil_bvalid;
        force   s_axil_bresp                    = gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.s_axil_bresp;
	force   wa_complete_flg                 = &gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.i_gtfmac.gtwiz_buffbypass_rx_done_out_i;

    end

    initial begin
      fork
       begin
        frames_received_0 = 0;

        forever begin
            wait (gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.gtfmac_hwchk_core_gen[0].i_gtfmac_hwchk_core.i_rx_mon.stat_total_packets_incr === 1);
            wait (gtfwizard_mac_gtfmac_ex_sim.u_gtfwizard_mac_example_gtfmac_top.gtfmac_hwchk_core_gen[0].i_gtfmac_hwchk_core.i_rx_mon.stat_total_packets_incr === 0);
            frames_received_0 = frames_received_0 + 1;
            $display("%t Received frame %0d for channel-0", $time, frames_received_0);
        end
       end
  
      join

    end
 
    initial begin
      fork
        begin
  
          hwchk_test (0,32'h0_0000,frames_received_0);
        end
  
      join
        $finish;
    end
    /////////////////////////////////////////////////////////////////////////////////////////////
    // DUT 
    /////////////////////////////////////////////////////////////////////////////////////////////

    gtfwizard_mac_gtfmac_ex # (
        .ONE_SECOND_COUNT   (28'h1000),  // for simulation purposes
        .NUM_CHANNEL        (1)
    ) 
    u_gtfwizard_mac_example_gtfmac_top (


        // exdes IOs
        .gtf_ch_gtftxn                      (/*serial_n*/),                         // output  wire                
        .gtf_ch_gtftxp                      (/*serial_p*/),                         // output  wire                
        .gtf_ch_gtfrxn                      (/*serial_n*/),                         // input   wire                
        .gtf_ch_gtfrxp                      (/*serial_p*/),                         // input   wire                
                                                                            
        .refclk_p                           (refclk),                           // input   wire                
        .refclk_n                           (~refclk),                          // input   wire 

        .hb_gtwiz_reset_clk_freerun_p_in    (freerun_clk),                      // input   wire                
        .hb_gtwiz_reset_clk_freerun_n_in    (~freerun_clk),                     // input   wire                
        .clk_wiz_locked_out                 (clk_wiz_locked_out),               // output   wire                
        .hb_gtwiz_reset_all_in              (hb_gtwiz_reset_all_in),            // input   wire                
        .gtwiz_reset_tx_done_out            (i_gtwiz_reset_tx_done_out),          //output
        .gtwiz_reset_rx_done_out            (i_gtwiz_reset_rx_done_out),          //output
        .gtf_cm_qpll0_lock                  (i_gtf_cm_qpll0_lock),                //output
                                                                            
        .rxbuffbypass_complete_flg          (),                                                                    
        .gtf_ch_txsyncdone                  (),                                                                    
        .gtf_ch_rxsyncdone                  (),                                                                    
        .link_maintained                    (),                                                                    
        .link_down_latched_reset_in         (link_down_latched_reset),          // input   wire                
        .link_status_out                    (link_status),                      // output  wire                
        .link_down_latched_out              (link_down_latched)                 // output  wire                

    );

    /////////////////////////////////////////////////////////////////////////////////////////////
    //  HWCHK Test 
    /////////////////////////////////////////////////////////////////////////////////////////////

    /////////////////////////////////////////////////////////////////////////////////////////////
    // TASKS
    /////////////////////////////////////////////////////////////////////////////////////////////

    task hwchk_axil_read;
        input  [31:0] offset_addr;
        input  [31:0] rd_addr;
        output [31:0] rd_data;

        begin

            logic   [31:0]  result;

            @ (negedge axi_aclk);

            s_axi_rd_busy = 1'b1;
        
            // The Master puts an address on the Read Address channel as well as asserting ARVALID,
            // indicating the address is valid, and RREADY, indicating the master is ready to receive data from the slave.
            s_axil_araddr     = rd_addr + offset_addr;
            s_axil_arvalid    = 1'b1;
            s_axil_rready     = 1'b1;

            fork

                begin

                    // The Slave asserts ARREADY, indicating that it is ready to receive the address on the bus.
                    do begin
                        @ (posedge axi_aclk);
                    end
                    while (!s_axil_arready);

                    // Since both ARVALID and ARREADY are asserted, on the next rising clock edge the handshake occurs, 
                    // after this the master and slave deassert ARVALID and the ARREADY, respectively. (At this point, the slave has received the requested address).
                    @ (negedge axi_aclk);
                    s_axil_arvalid    = 1'b0;

                end

                begin

                    // The Slave puts the requested data on the Read Data channel and asserts RVALID, 
                    // indicating the data in the channel is valid. The slave can also put a response on RRESP, though this does not occur here.
                    do begin
                        @ (posedge axi_aclk);
                    end
                    while (!s_axil_rvalid);

                    @ (negedge axi_aclk);
                    result  = s_axil_rdata;
        
                    // Since both RREADY and RVALID are asserted, the next rising clock edge completes the transaction. RREADY and RVALID can now be deasserted.
                    s_axil_arvalid    = 1'b0;
                    s_axil_rready     = 1'b0;

                end

            join

            @ (negedge axi_aclk);
            rd_data = result;

            s_axi_rd_busy = 1'b0;

        end

    endtask

    task hwchk_axil_write;
        input  [31:0] offset_addr;
        input [31:0] wr_addr;
        input [31:0] wr_data;

        begin


            // The Master puts an address on the Write Address channel and data on the Write data channel. 
            // At the same time it asserts AWVALID and WVALID indicating the address and data on the respective 
            // channels is valid. BREADY is also asserted by the Master, indicating it is ready to receive a response.

            @ (negedge axi_aclk);

            s_axi_wr_busy     = 1'b1;
    
            s_axil_awaddr     = wr_addr + offset_addr;
            s_axil_wdata      = wr_data;
            s_axil_awvalid    = 1'b1;
            s_axil_wvalid     = 1'b1;
            s_axil_bready     = 1'b1;

            fork

                begin
                    // The Slave asserts AWREADY and WREADY on the Write Address and Write Data channels, respectively.
                    do begin
                        @ (posedge axi_aclk);
                    end
                    while (!s_axil_awready);
                    @ (negedge axi_aclk);
                    s_axil_awvalid    = 1'b0;
                end
                begin
                    do begin
                        @ (posedge axi_aclk);
                    end
                    while (!s_axil_wready);
                    @ (negedge axi_aclk);
                    s_axil_wvalid     = 1'b0;
                end

                begin
                    // The Slave asserts BVALID, indicating there is a valid reponse on the Write response channel. 
                    // (in this case the response is 2'b00, that being 'OKAY').
                    do begin
                        @ (posedge axi_aclk);
                    end 
                    while (!s_axil_bvalid);

                    // The next rising clock edge completes the transaction, with both the Ready and Valid signals on the write response channel high.
                    @ (negedge axi_aclk);
                    s_axil_bready     = 1'b0;
                end
            join

            @ (negedge axi_aclk);
            s_axi_wr_busy = 1'b0;

        end

    endtask

  task automatic hwchk_test(int channel, reg [31:0] offset, ref int frames_received_l); 
       // Our local "copy" of the axi_aclk (for generating AXI-Lite transactions)
   begin

    reg     [31:0]      addr_offset;// = 32'h0_0000;
    real  HWCHK_LATENCY_CLK_PERIOD_NS;   // Set based on the configured data rate

    // device config
    logic   ctl_tx_data_rate;
    logic   ctl_rx_data_rate;
    logic    ctl_tx_start_framing_enable;//     = 1'b0; 
    logic    ctl_tx_fcs_ins_enable;//           = 1'b1;
    logic    ctl_tx_ignore_fcs;//               = 1'b0;
    logic    ctl_rx_ignore_fcs;//               = 1'b0;
    logic    ctl_tx_custom_preamble_enable;//   = 1'b0;
    logic    ctl_rx_custom_preamble_enable;//   = 1'b0;
    logic    ctl_frm_gen_mode;//                = 1'b0; // 0=random, 1=incr. pattern
    logic    ctl_tx_variable_ipg;//             = 1'b0;
    logic    [13:0] ctl_rx_min_packet_len;//    = 14'd64;
    logic    [13:0] ctl_rx_max_packet_len;//    = 14'd1500;
    logic    [31:0] frames_to_send;//           = 32'd50;//32'd400;
	logic    ctl_rx_check_preamble;//           = 1'b0; 
    logic    ctl_hwchk_tx_err_inj;//              = 1'b0; 
    logic    ctl_hwchk_tx_poison_inj;//           = 1'b0; 
    logic    [3:0] ctl_tx_ipg;//                = 4'd8;								


    reg     [31:0]      addr, data;
    reg     [15:0]      snd_time, rcv_time;
    reg     [15:0]      datav;
    reg     [31:0]      hwchk_block_lock;
    integer             attempts;

    integer             lat, lat_cnt, lat_min, lat_max;
    real                lat_total;

    reg                 stop_req, stopping;

    // HWCHK stats
    reg     [63:0]      stat_hwchk_tx_total_bytes;
    reg     [63:0]      stat_hwchk_tx_total_good_bytes;
    reg     [63:0]      stat_hwchk_tx_total_packets;
    reg     [63:0]      stat_hwchk_tx_total_good_packets;
    reg     [63:0]      stat_hwchk_tx_broadcast;
    reg     [63:0]      stat_hwchk_tx_multicast;
    reg     [63:0]      stat_hwchk_tx_unicast;
    reg     [63:0]      stat_hwchk_tx_vlan;

    reg     [63:0]      stat_hwchk_tx_packet_64_bytes;
    reg     [63:0]      stat_hwchk_tx_packet_65_127_bytes;
    reg     [63:0]      stat_hwchk_tx_packet_128_255_bytes;
    reg     [63:0]      stat_hwchk_tx_packet_256_511_bytes;
    reg     [63:0]      stat_hwchk_tx_packet_512_1023_bytes;
    reg     [63:0]      stat_hwchk_tx_packet_1024_1518_bytes;
    reg     [63:0]      stat_hwchk_tx_packet_1519_1522_bytes;
    reg     [63:0]      stat_hwchk_tx_packet_1523_1548_bytes;
    reg     [63:0]      stat_hwchk_tx_packet_1549_2047_bytes;
    reg     [63:0]      stat_hwchk_tx_packet_2048_4095_bytes;
    reg     [63:0]      stat_hwchk_tx_packet_4096_8191_bytes;
    reg     [63:0]      stat_hwchk_tx_packet_8192_9215_bytes;

    reg     [63:0]      stat_hwchk_tx_packet_small;
    reg     [63:0]      stat_hwchk_tx_packet_large;
    reg     [63:0]      stat_hwchk_tx_frame_error;
 
    reg                 stat_tx_unfout;
    reg                 stat_hwchk_tx_overflow;

    reg     [63:0]      stat_hwchk_rx_unicast;
    reg     [63:0]      stat_hwchk_rx_multicast;
    reg     [63:0]      stat_hwchk_rx_broadcast;
    reg     [63:0]      stat_hwchk_rx_vlan;

    reg     [63:0]      stat_hwchk_rx_total_bytes;
    reg     [63:0]      stat_hwchk_rx_total_good_bytes;
    reg     [63:0]      stat_hwchk_rx_total_packets;
    reg     [63:0]      stat_hwchk_rx_total_good_packets;

    reg     [63:0]      stat_hwchk_rx_inrangeerr;
    reg     [63:0]      stat_hwchk_rx_bad_fcs;

    reg     [63:0]      stat_hwchk_rx_packet_64_bytes;
    reg     [63:0]      stat_hwchk_rx_packet_65_127_bytes;
    reg     [63:0]      stat_hwchk_rx_packet_128_255_bytes;
    reg     [63:0]      stat_hwchk_rx_packet_256_511_bytes;
    reg     [63:0]      stat_hwchk_rx_packet_512_1023_bytes;
    reg     [63:0]      stat_hwchk_rx_packet_1024_1518_bytes;
    reg     [63:0]      stat_hwchk_rx_packet_1519_1522_bytes;
    reg     [63:0]      stat_hwchk_rx_packet_1523_1548_bytes;
    reg     [63:0]      stat_hwchk_rx_packet_1549_2047_bytes;
    reg     [63:0]      stat_hwchk_rx_packet_2048_4095_bytes;
    reg     [63:0]      stat_hwchk_rx_packet_4096_8191_bytes;
    reg     [63:0]      stat_hwchk_rx_packet_8192_9215_bytes;

    reg     [63:0]      stat_hwchk_rx_oversize;
    reg     [63:0]      stat_hwchk_rx_undersize;
    reg     [63:0]      stat_hwchk_rx_toolong;
    reg     [63:0]      stat_hwchk_rx_packet_small;
    reg     [63:0]      stat_hwchk_rx_packet_large;
    reg     [63:0]      stat_hwchk_rx_jabber;
    reg     [63:0]      stat_hwchk_rx_fragment;
    reg     [63:0]      stat_hwchk_rx_packet_bad_fcs;

    reg     [63:0]      stat_hwchk_rx_user_pause;
    reg     [63:0]      stat_hwchk_rx_pause;
	reg     [63:0]      stat_hwchk_rx_bad_preamble_count;
	reg     [63:0]      stat_hwchk_rx_good_tsof_codeword;												   

    // MAC stats
    reg     [63:0]      status_rx_cycle_soft_count;
    reg     [63:0]      status_tx_cycle_soft_count;
    reg     [63:0]      stat_rx_framing_err_soft;
    reg     [63:0]      stat_rx_bad_code_soft;
    reg     [63:0]      stat_tx_frame_error_soft;
    reg     [63:0]      stat_tx_total_packets_soft;
    reg     [63:0]      stat_tx_total_good_packets_soft;
    reg     [63:0]      stat_tx_total_bytes_soft;
    reg     [63:0]      stat_tx_total_good_bytes_soft;
    reg     [63:0]      stat_tx_packet_64_bytes_soft;
    reg     [63:0]      stat_tx_packet_65_127_bytes_soft;
    reg     [63:0]      stat_tx_packet_128_255_bytes_soft;
    reg     [63:0]      stat_tx_packet_256_511_bytes_soft;
    reg     [63:0]      stat_tx_packet_512_1023_bytes_soft;
    reg     [63:0]      stat_tx_packet_1024_1518_bytes_soft;
    reg     [63:0]      stat_tx_packet_1519_1522_bytes_soft;
    reg     [63:0]      stat_tx_packet_1523_1548_bytes_soft;
    reg     [63:0]      stat_tx_packet_1549_2047_bytes_soft;
    reg     [63:0]      stat_tx_packet_2048_4095_bytes_soft;
    reg     [63:0]      stat_tx_packet_4096_8191_bytes_soft;
    reg     [63:0]      stat_tx_packet_8192_9215_bytes_soft;
    reg     [63:0]      stat_tx_packet_large_soft;
    reg     [63:0]      stat_tx_packet_small_soft;
    reg     [63:0]      stat_tx_bad_fcs_soft;
    reg     [63:0]      stat_tx_unicast_soft;
    reg     [63:0]      stat_tx_multicast_soft;
    reg     [63:0]      stat_tx_broadcast_soft;
    reg     [63:0]      stat_tx_vlan_soft;

    reg     [63:0]      stat_rx_total_packets_soft;
    reg     [63:0]      stat_rx_total_good_packets_soft;
    reg     [63:0]      stat_rx_total_bytes_soft;
    reg     [63:0]      stat_rx_total_good_bytes_soft;
    reg     [63:0]      stat_rx_packet_64_bytes_soft;
    reg     [63:0]      stat_rx_packet_65_127_bytes_soft;
    reg     [63:0]      stat_rx_packet_128_255_bytes_soft;
    reg     [63:0]      stat_rx_packet_256_511_bytes_soft;
    reg     [63:0]      stat_rx_packet_512_1023_bytes_soft;
    reg     [63:0]      stat_rx_packet_1024_1518_bytes_soft;
    reg     [63:0]      stat_rx_packet_1519_1522_bytes_soft;
    reg     [63:0]      stat_rx_packet_1523_1548_bytes_soft;
    reg     [63:0]      stat_rx_packet_1549_2047_bytes_soft;
    reg     [63:0]      stat_rx_packet_2048_4095_bytes_soft;
    reg     [63:0]      stat_rx_packet_4096_8191_bytes_soft;
    reg     [63:0]      stat_rx_packet_8192_9215_bytes_soft;
    reg     [63:0]      stat_rx_packet_large_soft;
    reg     [63:0]      stat_rx_packet_small_soft;
    reg     [63:0]      stat_rx_undersize_soft;
    reg     [63:0]      stat_rx_fragment_soft;
    reg     [63:0]      stat_rx_oversize_soft;
    reg     [63:0]      stat_rx_toolong_soft;
    reg     [63:0]      stat_rx_jabber_soft;
    reg     [63:0]      stat_rx_bad_fcs_soft;
    reg     [63:0]      stat_rx_packet_bad_fcs_soft;
    reg     [63:0]      stat_rx_stomped_fcs_soft;
    reg     [63:0]      stat_rx_unicast_soft;
    reg     [63:0]      stat_rx_multicast_soft;
    reg     [63:0]      stat_rx_broadcast_soft;
    reg     [63:0]      stat_rx_vlan_soft;
    reg     [63:0]      stat_rx_pause_soft;
    reg     [63:0]      stat_rx_user_pause_soft;
    reg     [63:0]      stat_rx_inrangeerr_soft;
    reg     [63:0]      stat_rx_truncated_soft;
    reg     [63:0]      stat_rx_test_pattern_mismatch_soft;
    reg     [63:0]      stat_rx_bad_std_preamble_count_soft; 																	 

    bit         timed_out;// = '0;

//    initial begin
    ctl_tx_start_framing_enable     = 1'b0; 
    ctl_tx_fcs_ins_enable           = 1'b1;
    ctl_tx_ignore_fcs               = 1'b0;
    ctl_rx_ignore_fcs               = 1'b0;
    ctl_tx_custom_preamble_enable   = 1'b0;
    ctl_rx_custom_preamble_enable   = 1'b0;
    ctl_frm_gen_mode                = 1'b0; // 0=random, 1=incr. pattern
    ctl_tx_variable_ipg             = 1'b0;
    ctl_rx_min_packet_len    = 14'd64;
    ctl_rx_max_packet_len    = 14'd1500;
    frames_to_send           = 32'd50;//32'd400;
    ctl_rx_check_preamble           = 1'b0; 
    ctl_hwchk_tx_err_inj              = 1'b0; 
    ctl_hwchk_tx_poison_inj           = 1'b0; 
    ctl_tx_ipg                = 4'd8;			
    timed_out = 0;

//  fork

//  begin




    // Our testcase:
    //  - wait for the HWCHK to detect block block
    //  - align bitslip
    //  - init stats
    //  - send traffic
    //  - collect stats
    //  - compare TX and RX stats

//    initial begin

        addr_offset = offset;//32'h0_0000;
        wait (axi_aresetn == 1'b1);

        repeat (1000) @(negedge axi_aclk);

        $display("%t Waiting for DUT to come alive...", $time);
        $display("%t Starting transaction on Channel-%d",$time,channel);
        attempts = 0;
        do begin
            
            hwchk_axil_read (addr_offset,32'h000, data);
            data     = data & 32'h3;
            attempts += 1;

        end
        while (data != 32'h0 && attempts < 100_000 );

        $display("%t Observed gtfmac status = %0x", $time, data);

        if (attempts >= 100000) begin
            $display("%t ERROR - DUT did not come out of reset", $time);
            $display("** Error: Test did not complete successfully");
            $finish;
        end

        $display("%t Report userrdy to the GTF", $time);
        addr    = 32'hC;
        data    = 32'h3;
        hwchk_axil_write  (addr_offset,addr, data);

        $display("%t Configure near-end loopback", $time);
        addr    = 32'h1_0408;
        hwchk_axil_read (addr_offset,addr, data);
        data[6:4] = 3'b010;
        hwchk_axil_write  (addr_offset,addr, data);

        $display("%t Reset the RX side of the GT", $time);
        addr    = 32'h1_0400;
        data    = 32'h2;
        hwchk_axil_write  (addr_offset,addr, data);

        addr    = 32'h1_0400;
        data    = 32'h0;
        hwchk_axil_write  (addr_offset,addr, data);

        ctl_tx_data_rate = 1'b0; 
        ctl_rx_data_rate = 1'b0; 
        HWCHK_LATENCY_CLK_PERIOD_NS = 1.5515;  // 644 MHz
        addr    = 32'h1_0000;
        hwchk_axil_write (addr_offset, addr, {ctl_tx_data_rate, ctl_rx_data_rate});

        $display("%t HWCHK:    Set up the TX/RX data rate to match", $time);
        addr    = 32'h10;
        hwchk_axil_read (addr_offset,addr, data);
        data    = data | (ctl_tx_data_rate << 0);
        data    = data | (ctl_rx_data_rate << 16);
        $display("%t         HWCHK config=%0x", $time, data);
        hwchk_axil_write  (addr_offset,addr, data);

        $display("%t Allow MAC side of the GTFMAC to bitslip", $time);
        addr    = 32'ha4;
        data    = 32'h0;
        hwchk_axil_write  (addr_offset,addr, data);

        // Wait for block lock
        $display("%t Waiting for HWCHK to detect block lock...", $time);
        attempts = 0;
        do begin
            
            hwchk_axil_read (addr_offset,32'h0A0, hwchk_block_lock);
            hwchk_block_lock   = hwchk_block_lock & (1 << 16);
            attempts += 1;

        end
        while (!hwchk_block_lock && attempts < 100_000 );

        if (attempts >= 100_000) begin
            $display("%t ERROR - no block lock", $time);
            $display("** Error: Test did not complete successfully");
            $finish;
        end

        $display("%t Block lock found.", $time);

        // Only correct bitslip if we are in 10G mode
        if (!ctl_tx_data_rate) begin

            $display("%t Allow bitslip logic to correct bitslip in the transceiver...", $time);
            addr    = 32'ha4;
            data    = 32'h1;
            hwchk_axil_write  (addr_offset,addr, data);

            attempts = 0;
            do begin
                
                hwchk_axil_read (addr_offset,32'h0A0, data);
                data    = data & (1 << 18); // done bit
                attempts += 1;
     
            end
            while (!data && attempts < 100 );
     
            if (attempts >= 100) begin
                $display("%t ERROR - alignment process failed", $time);
                $display("** Error: Test did not complete successfully");
                $finish;
            end

            $display("%t Bitslip issued.", $time);

            $display("%t Waiting for HWCHK to detect block lock...", $time);
            attempts = 0;
            do begin
                
                hwchk_axil_read (addr_offset,32'h0A0, hwchk_block_lock);
                hwchk_block_lock    = hwchk_block_lock & (1 << 16);
                attempts += 1;

            end
            while (!hwchk_block_lock && attempts < 100_000 );

            if (attempts >= 100_000) begin
                $display("%t ERROR - no block lock", $time);
                $display("** Error: Test did not complete successfully");
                $finish;
            end

            $display("%t Block lock found.", $time);

        end
        // Wait for rx alignment
        $display("%t Waiting for HWCHK to detect rx alignment...", $time);
        attempts = 0;
        do begin
            #100000 attempts += 1;
        end
        while (!wa_complete_flg && attempts < 100_000 );

        if (attempts >= 100_000) begin
            $display("%t ERROR - no rx alignment", $time);
            $display("** Error: Test did not complete successfully");
            $finish;
        end

        $display("%t rx alignment achieved.", $time);


        $display("%t Waiting for link up.", $time);

        attempts = 0;
        do begin
            
            hwchk_axil_read (addr_offset,32'h0, data);
            data     = data & (4'hF << 8);
            attempts += 1;

        end
        while (!(data == 32'h0) && attempts < 10_000 );

        $display("%t After %0d attempts, observed gtfmac status = %0x", $time, attempts, data);

        if (attempts >= 100) begin
            $display("%t ERROR - link down", $time);
            $display("** Error: Test did not complete successfully");
            $finish;
        end
        else begin
            $display("%t LINK UP", $time);
        end

        $display("%t GTFMAC: Configure CONFIGURATION_TX_REG1", $time);
        $display("%t         ctl_tx_fcs_ins_enable=%0x", $time, ctl_tx_fcs_ins_enable);
        $display("%t         ctl_tx_ignore_fcs=%0x", $time, ctl_tx_ignore_fcs);
        $display("%t         ctl_tx_custom_preamble_enable=%0x", $time, ctl_tx_custom_preamble_enable);
        addr    = 32'h1_0004;
        hwchk_axil_read (addr_offset,addr, data);
        $display("%t         CONFIGURATION_TX_REG1=%0x", $time, data);
        data[1]     = ctl_tx_fcs_ins_enable;
        data[2]     = ctl_tx_ignore_fcs;
        data[3]     = ctl_tx_custom_preamble_enable;
        data[11:8]  = ctl_tx_ipg;
        data[12]    = ctl_tx_start_framing_enable;
        $display("%t         CONFIGURATION_TX_REG1=%0x", $time, data);
        hwchk_axil_write  (addr_offset,addr, data);

        $display("%t GTFMAC: Configure CONFIGURATION_RX_REG1", $time);
        $display("%t         ctl_rx_ignore_fcs=%0x", $time, ctl_rx_ignore_fcs);
        $display("%t         ctl_rx_custom_preamble_enable=%0x", $time, ctl_rx_custom_preamble_enable);
        addr    = 32'h1_0008;
        hwchk_axil_read (addr_offset,addr, data);
        data[2]     = ctl_rx_ignore_fcs;
        data[5]     = ctl_rx_check_preamble;
        data[6]     = ctl_rx_custom_preamble_enable;
        hwchk_axil_write  (addr_offset,addr, data);

        $display("%t GTFMAC: Configure CONFIGURATION_RX_MTU1", $time);
        $display("%t         ctl_rx_min_packet_len=%0x", $time, ctl_rx_min_packet_len);
        addr    = 32'h1_000c;
        hwchk_axil_read (addr_offset,addr, data);
        data    = ctl_rx_min_packet_len;
        hwchk_axil_write  (addr_offset,addr, data);

        $display("%t GTFMAC: Configure CONFIGURATION_RX_MTU2", $time);
        $display("%t         ctl_rx_max_packet_len=%0x", $time, ctl_rx_max_packet_len);
        addr    = 32'h1_0010;
        hwchk_axil_read (addr_offset,addr, data);
        $display("%t         Read %0x", $time, data);
        data    = ctl_rx_max_packet_len;
        hwchk_axil_write  (addr_offset,addr, data);
        hwchk_axil_read (addr_offset,addr, data);

        $display("%t HWCHK:    Set up the HWCHK fcs_ins_enable and preamble_enable.", $time);
        $display("%t         ctl_tx_fcs_ins_enable=%0x", $time, ctl_tx_fcs_ins_enable);
        $display("%t         ctl_tx_custom_preamble_enable=%0x", $time, ctl_tx_custom_preamble_enable);
        $display("%t         ctl_rx_custom_preamble_enable=%0x", $time, ctl_rx_custom_preamble_enable);
        $display("%t         ctl_tx_start_framing_enable=%0x", $time, ctl_tx_start_framing_enable);
        addr    = 32'h10;
        hwchk_axil_read (addr_offset,addr, data);
        data    = data | (ctl_tx_fcs_ins_enable << 4);
        data    = data | (ctl_tx_custom_preamble_enable << 8);
        data    = data | (ctl_tx_start_framing_enable << 12);
        data    = data | (ctl_rx_custom_preamble_enable << 24);
        $display("%t         HWCHK config=%0x", $time, data);
        hwchk_axil_write  (addr_offset,addr, data);
        $display("%t HWCHK:    Set the Error Injection Flag", $time);
        $display("%t         ctl_hwchk_tx_err_inj=%0x", $time, ctl_hwchk_tx_err_inj);
        addr    = 32'h40;
        data    = ctl_hwchk_tx_err_inj;
        hwchk_axil_write  (addr_offset,addr, data);
        
        $display("%t HWCHK:    Set the Poison Injection Flag", $time);
        $display("%t         ctl_hwchk_tx_poison_inj=%0x", $time, ctl_hwchk_tx_poison_inj);
        addr    = 32'h98;
        data    = ctl_hwchk_tx_poison_inj;
        hwchk_axil_write  (addr_offset,addr, data);
        $display("%t HWCHK:    Set the min and max frame lengths for the generator.", $time);
        $display("%t         ctl_rx_min_packet_len=%0x", $time, ctl_rx_min_packet_len);
        $display("%t         ctl_rx_max_packet_len=%0x", $time, ctl_rx_max_packet_len);
        addr    = 32'h28;
        data    = ctl_rx_min_packet_len;
        hwchk_axil_write  (addr_offset,addr, data);

        addr    = 32'h24;
        data    = ctl_rx_max_packet_len;
        hwchk_axil_write  (addr_offset,addr, data);

        // Set the mode
        $display("%t Set the frame generation mode.", $time);
        $display("%t         ctl_frm_gen_mode=%0x", $time, ctl_frm_gen_mode);
        $display("%t         ctl_tx_variable_ipg=%0x", $time, ctl_tx_variable_ipg);
        addr    = 32'h14;
        data    = 0;
        data[0] = ctl_frm_gen_mode;
        data[8] = ctl_tx_variable_ipg;
        hwchk_axil_write  (addr_offset,addr, data);

        // Specify the number of frames
        $display("%t Configure the number of frames to send (%0d)", $time, frames_to_send);
        addr    = 32'h2c;
        data    = frames_to_send;
        hwchk_axil_write  (addr_offset,addr, data);

        $display("%t Tick the HWCHK stats to initialize them.", $time);
        addr    = 32'h90;
        data    = 32'h1;
        hwchk_axil_write  (addr_offset,addr, data);

        $display("%t Tick the GTFMAC stats to initialize them.", $time);
        addr    = 32'h1_0000 | 32'h40C;
        data    = 32'h1;
        hwchk_axil_write  (addr_offset,addr, data);

        frame_gen_ready[channel] = 1;
        $display("%t Channel-%d  is ready to enable frame generator",$time,channel);
        if(channel == 0)
          wait(&frame_gen_ready == 1);
        else begin
          wait(frame_gen_ready[channel-1] == 1);
          wait(frame_gen_ready[channel-1] == 0);
        end

        $display("%t Enable the frame generator and monitor for channel-%d", $time,channel);
        addr    = 32'h20;
        data    = 0;
        data    = data | (1'b1 << 0); // gen_en
        data    = data | (1'b1 << 4); // mon_en
        hwchk_axil_write  (addr_offset,addr, data);
        frame_gen_ready[channel] = 0;

        stop_req = 0;
        stopping = 0;

        fork
            
            begin
                lat_cnt   = 0;
                lat_min   = 1000;
                lat_max   = 0;
                lat_total = 0;
                do begin

                    
                    #5ns;
                    //$display("%t stop_req = %d", $time, stop_req);
                    if (stop_req) begin
                        $display("%t stop_req = %d", $time, stop_req);

                        stopping = 1;
                         if(channel != 0) begin
                           wait(frame_gen_ready[channel-1] == 1);
                           wait(frame_gen_ready[channel-1] == 0);
                         end
                        // Disable the frame generator
                        addr    = 32'h20;
                        data    = 0;
                        data    = data | (1'b0 << 0); // gen_en
                        hwchk_axil_write  (addr_offset,addr, data);

                        // Flush pipeline
                        repeat (5000) @(negedge axi_aclk);

                    end

                    datav = 0;

                    if (data[16]) begin
                        $display("ERROR:  FIFO overflow!");
                        $display("** Error: Test did not complete successfully");
                        $finish;
                    end
                    
                    //$display("Debug after IF");

                    if (datav > 0) begin

                        // $display("There are %0d entries available to read.", datav);

                        for (int i=0;i<datav;i=i+1) begin
                            hwchk_axil_read (addr_offset,32'h8008, {rcv_time, snd_time});

                            // Compute the delta between the send time and the receive time
                            // We can take away one clock, because rx_tsof is launched off of the previous
                            // rxusrclk rising edge, and it's agreed that this is the end measurement time.
                            if (rcv_time - snd_time > 0) begin
                                lat = rcv_time - snd_time - 1;
                            end
                            else begin
                                lat = 65535 - snd_time + rcv_time - 1;
                            end

                            if (lat < lat_min)
                                lat_min = lat;

                            if (lat > lat_max)
                                lat_max = lat;

                            lat_total = lat_total + lat;

                            lat_cnt = lat_cnt + 1;

                        end

                    end

                end
                while (!stopping);
                
            end
            
            begin

                fork begin
                  fork
                      begin
                        #10ms;
                        $display("%t Watchdog reached...", $time);
                        timed_out = '1;
                      end
                  join_none
                  wait(frames_received_l == frames_to_send || timed_out);
                  disable fork;
                end join

                $display("%t Stopping...", $time);
                stop_req    = 1;
                frame_gen_ready[channel] = 1;
            end

        join

        $display("%t Stopped.", $time);
        frame_gen_ready[channel] = 0;
        frame_stat_ready[channel] = 1;
        $display("%t Channel-%d  is ready to read status registers",$time,channel);
        if(channel == 0)
          wait(&frame_stat_ready == 1);
        else begin
          wait(frame_stat_ready[channel-1] == 1);
          wait(frame_stat_ready[channel-1] == 0);
        end
        $display("%t Channel-%d  is starting reading status registers",$time,channel);

        $display("%t Tick the HWCHK stats for collection.", $time);
        addr    = 32'h90;
        data    = 32'h1;
        hwchk_axil_write  (addr_offset,addr, data);

        $display("%t Tick the GTFMAC stats for collection", $time);
        addr    = 32'h1_0000 | 32'h40C;
        data    = 32'h1;
        hwchk_axil_write  (addr_offset,addr, data);

        repeat (50) @(negedge axi_aclk);


        addr = 32'h1_0500; hwchk_axil_read (addr_offset,addr, status_rx_cycle_soft_count[31:0]);
        addr = 32'h1_0504; hwchk_axil_read (addr_offset,addr, status_rx_cycle_soft_count[63:32]);
        addr = 32'h1_0508; hwchk_axil_read (addr_offset,addr, status_tx_cycle_soft_count[31:0]);
        addr = 32'h1_050C; hwchk_axil_read (addr_offset,addr, status_tx_cycle_soft_count[63:32]);
        addr = 32'h1_0648; hwchk_axil_read (addr_offset,addr, stat_rx_framing_err_soft[31:0]);
        addr = 32'h1_064C; hwchk_axil_read (addr_offset,addr, stat_rx_framing_err_soft[63:32]);
        addr = 32'h1_0660; hwchk_axil_read (addr_offset,addr, stat_rx_bad_code_soft[31:0]);
        addr = 32'h1_0664; hwchk_axil_read (addr_offset,addr, stat_rx_bad_code_soft[63:32]);
        addr = 32'h1_06A0; hwchk_axil_read (addr_offset,addr, stat_tx_frame_error_soft[31:0]);
        addr = 32'h1_06A4; hwchk_axil_read (addr_offset,addr, stat_tx_frame_error_soft[63:32]);
        addr = 32'h1_0700; hwchk_axil_read (addr_offset,addr, stat_tx_total_packets_soft[31:0]);
        addr = 32'h1_0704; hwchk_axil_read (addr_offset,addr, stat_tx_total_packets_soft[63:32]);
        addr = 32'h1_0708; hwchk_axil_read (addr_offset,addr, stat_tx_total_good_packets_soft[31:0]);
        addr = 32'h1_070C; hwchk_axil_read (addr_offset,addr, stat_tx_total_good_packets_soft[63:32]);
        addr = 32'h1_0710; hwchk_axil_read (addr_offset,addr, stat_tx_total_bytes_soft[31:0]);
        addr = 32'h1_0714; hwchk_axil_read (addr_offset,addr, stat_tx_total_bytes_soft[63:32]);
        addr = 32'h1_0718; hwchk_axil_read (addr_offset,addr, stat_tx_total_good_bytes_soft[31:0]);
        addr = 32'h1_071C; hwchk_axil_read (addr_offset,addr, stat_tx_total_good_bytes_soft[63:32]);
        addr = 32'h1_0720; hwchk_axil_read (addr_offset,addr, stat_tx_packet_64_bytes_soft[31:0]);
        addr = 32'h1_0724; hwchk_axil_read (addr_offset,addr, stat_tx_packet_64_bytes_soft[63:32]);
        addr = 32'h1_0728; hwchk_axil_read (addr_offset,addr, stat_tx_packet_65_127_bytes_soft[31:0]);
        addr = 32'h1_072C; hwchk_axil_read (addr_offset,addr, stat_tx_packet_65_127_bytes_soft[63:32]);
        addr = 32'h1_0730; hwchk_axil_read (addr_offset,addr, stat_tx_packet_128_255_bytes_soft[31:0]);
        addr = 32'h1_0734; hwchk_axil_read (addr_offset,addr, stat_tx_packet_128_255_bytes_soft[63:32]);
        addr = 32'h1_0738; hwchk_axil_read (addr_offset,addr, stat_tx_packet_256_511_bytes_soft[31:0]);
        addr = 32'h1_073C; hwchk_axil_read (addr_offset,addr, stat_tx_packet_256_511_bytes_soft[63:32]);
        addr = 32'h1_0740; hwchk_axil_read (addr_offset,addr, stat_tx_packet_512_1023_bytes_soft[31:0]);
        addr = 32'h1_0744; hwchk_axil_read (addr_offset,addr, stat_tx_packet_512_1023_bytes_soft[63:32]);
        addr = 32'h1_0748; hwchk_axil_read (addr_offset,addr, stat_tx_packet_1024_1518_bytes_soft[31:0]);
        addr = 32'h1_074C; hwchk_axil_read (addr_offset,addr, stat_tx_packet_1024_1518_bytes_soft[63:32]);
        addr = 32'h1_0750; hwchk_axil_read (addr_offset,addr, stat_tx_packet_1519_1522_bytes_soft[31:0]);
        addr = 32'h1_0754; hwchk_axil_read (addr_offset,addr, stat_tx_packet_1519_1522_bytes_soft[63:32]);
        addr = 32'h1_0758; hwchk_axil_read (addr_offset,addr, stat_tx_packet_1523_1548_bytes_soft[31:0]);
        addr = 32'h1_075C; hwchk_axil_read (addr_offset,addr, stat_tx_packet_1523_1548_bytes_soft[63:32]);
        addr = 32'h1_0760; hwchk_axil_read (addr_offset,addr, stat_tx_packet_1549_2047_bytes_soft[31:0]);
        addr = 32'h1_0764; hwchk_axil_read (addr_offset,addr, stat_tx_packet_1549_2047_bytes_soft[63:32]);
        addr = 32'h1_0768; hwchk_axil_read (addr_offset,addr, stat_tx_packet_2048_4095_bytes_soft[31:0]);
        addr = 32'h1_076C; hwchk_axil_read (addr_offset,addr, stat_tx_packet_2048_4095_bytes_soft[63:32]);
        addr = 32'h1_0770; hwchk_axil_read (addr_offset,addr, stat_tx_packet_4096_8191_bytes_soft[31:0]);
        addr = 32'h1_0774; hwchk_axil_read (addr_offset,addr, stat_tx_packet_4096_8191_bytes_soft[63:32]);
        addr = 32'h1_0778; hwchk_axil_read (addr_offset,addr, stat_tx_packet_8192_9215_bytes_soft[31:0]);
        addr = 32'h1_077C; hwchk_axil_read (addr_offset,addr, stat_tx_packet_8192_9215_bytes_soft[63:32]);
        addr = 32'h1_0780; hwchk_axil_read (addr_offset,addr, stat_tx_packet_large_soft[31:0]);
        addr = 32'h1_0784; hwchk_axil_read (addr_offset,addr, stat_tx_packet_large_soft[63:32]);
        addr = 32'h1_0788; hwchk_axil_read (addr_offset,addr, stat_tx_packet_small_soft[31:0]);
        addr = 32'h1_078C; hwchk_axil_read (addr_offset,addr, stat_tx_packet_small_soft[63:32]);
        addr = 32'h1_07B8; hwchk_axil_read (addr_offset,addr, stat_tx_bad_fcs_soft[31:0]);
        addr = 32'h1_07BC; hwchk_axil_read (addr_offset,addr, stat_tx_bad_fcs_soft[63:32]);
        addr = 32'h1_07D0; hwchk_axil_read (addr_offset,addr, stat_tx_unicast_soft[31:0]);
        addr = 32'h1_07D4; hwchk_axil_read (addr_offset,addr, stat_tx_unicast_soft[63:32]);
        addr = 32'h1_07D8; hwchk_axil_read (addr_offset,addr, stat_tx_multicast_soft[31:0]);
        addr = 32'h1_07DC; hwchk_axil_read (addr_offset,addr, stat_tx_multicast_soft[63:32]);
        addr = 32'h1_07E0; hwchk_axil_read (addr_offset,addr, stat_tx_broadcast_soft[31:0]);
        addr = 32'h1_07E4; hwchk_axil_read (addr_offset,addr, stat_tx_broadcast_soft[63:32]);
        addr = 32'h1_07E8; hwchk_axil_read (addr_offset,addr, stat_tx_vlan_soft[31:0]);
        addr = 32'h1_07EC; hwchk_axil_read (addr_offset,addr, stat_tx_vlan_soft[63:32]);

        addr = 32'h1_0808; hwchk_axil_read (addr_offset,addr, stat_rx_total_packets_soft[31:0]);
        addr = 32'h1_080C; hwchk_axil_read (addr_offset,addr, stat_rx_total_packets_soft[63:32]);
        addr = 32'h1_0810; hwchk_axil_read (addr_offset,addr, stat_rx_total_good_packets_soft[31:0]);
        addr = 32'h1_0814; hwchk_axil_read (addr_offset,addr, stat_rx_total_good_packets_soft[63:32]);
        addr = 32'h1_0818; hwchk_axil_read (addr_offset,addr, stat_rx_total_bytes_soft[31:0]);
        addr = 32'h1_081C; hwchk_axil_read (addr_offset,addr, stat_rx_total_bytes_soft[63:32]);
        addr = 32'h1_0820; hwchk_axil_read (addr_offset,addr, stat_rx_total_good_bytes_soft[31:0]);
        addr = 32'h1_0824; hwchk_axil_read (addr_offset,addr, stat_rx_total_good_bytes_soft[63:32]);
        addr = 32'h1_0828; hwchk_axil_read (addr_offset,addr, stat_rx_packet_64_bytes_soft[31:0]);
        addr = 32'h1_082C; hwchk_axil_read (addr_offset,addr, stat_rx_packet_64_bytes_soft[63:32]);
        addr = 32'h1_0830; hwchk_axil_read (addr_offset,addr, stat_rx_packet_65_127_bytes_soft[31:0]);
        addr = 32'h1_0834; hwchk_axil_read (addr_offset,addr, stat_rx_packet_65_127_bytes_soft[63:32]);
        addr = 32'h1_0838; hwchk_axil_read (addr_offset,addr, stat_rx_packet_128_255_bytes_soft[31:0]);
        addr = 32'h1_083C; hwchk_axil_read (addr_offset,addr, stat_rx_packet_128_255_bytes_soft[63:32]);
        addr = 32'h1_0840; hwchk_axil_read (addr_offset,addr, stat_rx_packet_256_511_bytes_soft[31:0]);
        addr = 32'h1_0844; hwchk_axil_read (addr_offset,addr, stat_rx_packet_256_511_bytes_soft[63:32]);
        addr = 32'h1_0848; hwchk_axil_read (addr_offset,addr, stat_rx_packet_512_1023_bytes_soft[31:0]);
        addr = 32'h1_084C; hwchk_axil_read (addr_offset,addr, stat_rx_packet_512_1023_bytes_soft[63:32]);
        addr = 32'h1_0850; hwchk_axil_read (addr_offset,addr, stat_rx_packet_1024_1518_bytes_soft[31:0]);
        addr = 32'h1_0854; hwchk_axil_read (addr_offset,addr, stat_rx_packet_1024_1518_bytes_soft[63:32]);
        addr = 32'h1_0858; hwchk_axil_read (addr_offset,addr, stat_rx_packet_1519_1522_bytes_soft[31:0]);
        addr = 32'h1_085C; hwchk_axil_read (addr_offset,addr, stat_rx_packet_1519_1522_bytes_soft[63:32]);
        addr = 32'h1_0860; hwchk_axil_read (addr_offset,addr, stat_rx_packet_1523_1548_bytes_soft[31:0]);
        addr = 32'h1_0864; hwchk_axil_read (addr_offset,addr, stat_rx_packet_1523_1548_bytes_soft[63:32]);
        addr = 32'h1_0868; hwchk_axil_read (addr_offset,addr, stat_rx_packet_1549_2047_bytes_soft[31:0]);
        addr = 32'h1_086C; hwchk_axil_read (addr_offset,addr, stat_rx_packet_1549_2047_bytes_soft[63:32]);
        addr = 32'h1_0870; hwchk_axil_read (addr_offset,addr, stat_rx_packet_2048_4095_bytes_soft[31:0]);
        addr = 32'h1_0874; hwchk_axil_read (addr_offset,addr, stat_rx_packet_2048_4095_bytes_soft[63:32]);
        addr = 32'h1_0878; hwchk_axil_read (addr_offset,addr, stat_rx_packet_4096_8191_bytes_soft[31:0]);
        addr = 32'h1_087C; hwchk_axil_read (addr_offset,addr, stat_rx_packet_4096_8191_bytes_soft[63:32]);
        addr = 32'h1_0880; hwchk_axil_read (addr_offset,addr, stat_rx_packet_8192_9215_bytes_soft[31:0]);
        addr = 32'h1_0884; hwchk_axil_read (addr_offset,addr, stat_rx_packet_8192_9215_bytes_soft[63:32]);
        addr = 32'h1_0888; hwchk_axil_read (addr_offset,addr, stat_rx_packet_large_soft[31:0]);
        addr = 32'h1_088C; hwchk_axil_read (addr_offset,addr, stat_rx_packet_large_soft[63:32]);
        addr = 32'h1_0890; hwchk_axil_read (addr_offset,addr, stat_rx_packet_small_soft[31:0]);
        addr = 32'h1_0894; hwchk_axil_read (addr_offset,addr, stat_rx_packet_small_soft[63:32]);
        addr = 32'h1_0898; hwchk_axil_read (addr_offset,addr, stat_rx_undersize_soft[31:0]);
        addr = 32'h1_089C; hwchk_axil_read (addr_offset,addr, stat_rx_undersize_soft[63:32]);
        addr = 32'h1_08A0; hwchk_axil_read (addr_offset,addr, stat_rx_fragment_soft[31:0]);
        addr = 32'h1_08A4; hwchk_axil_read (addr_offset,addr, stat_rx_fragment_soft[63:32]);
        addr = 32'h1_08A8; hwchk_axil_read (addr_offset,addr, stat_rx_oversize_soft[31:0]);
        addr = 32'h1_08AC; hwchk_axil_read (addr_offset,addr, stat_rx_oversize_soft[63:32]);
        addr = 32'h1_08B0; hwchk_axil_read (addr_offset,addr, stat_rx_toolong_soft[31:0]);
        addr = 32'h1_08B4; hwchk_axil_read (addr_offset,addr, stat_rx_toolong_soft[63:32]);
        addr = 32'h1_08B8; hwchk_axil_read (addr_offset,addr, stat_rx_jabber_soft[31:0]);
        addr = 32'h1_08BC; hwchk_axil_read (addr_offset,addr, stat_rx_jabber_soft[63:32]);
        addr = 32'h1_08C0; hwchk_axil_read (addr_offset,addr, stat_rx_bad_fcs_soft[31:0]);
        addr = 32'h1_08C4; hwchk_axil_read (addr_offset,addr, stat_rx_bad_fcs_soft[63:32]);
        addr = 32'h1_08C8; hwchk_axil_read (addr_offset,addr, stat_rx_packet_bad_fcs_soft[31:0]);
        addr = 32'h1_08CC; hwchk_axil_read (addr_offset,addr, stat_rx_packet_bad_fcs_soft[63:32]);
        addr = 32'h1_08D0; hwchk_axil_read (addr_offset,addr, stat_rx_stomped_fcs_soft[31:0]);
        addr = 32'h1_08D4; hwchk_axil_read (addr_offset,addr, stat_rx_stomped_fcs_soft[63:32]);
        addr = 32'h1_08D8; hwchk_axil_read (addr_offset,addr, stat_rx_unicast_soft[31:0]);
        addr = 32'h1_08DC; hwchk_axil_read (addr_offset,addr, stat_rx_unicast_soft[63:32]);
        addr = 32'h1_08E0; hwchk_axil_read (addr_offset,addr, stat_rx_multicast_soft[31:0]);
        addr = 32'h1_08E4; hwchk_axil_read (addr_offset,addr, stat_rx_multicast_soft[63:32]);
        addr = 32'h1_08E8; hwchk_axil_read (addr_offset,addr, stat_rx_broadcast_soft[31:0]);
        addr = 32'h1_08EC; hwchk_axil_read (addr_offset,addr, stat_rx_broadcast_soft[63:32]);
        addr = 32'h1_08F0; hwchk_axil_read (addr_offset,addr, stat_rx_vlan_soft[31:0]);
        addr = 32'h1_08F4; hwchk_axil_read (addr_offset,addr, stat_rx_vlan_soft[63:32]);
        addr = 32'h1_08F8; hwchk_axil_read (addr_offset,addr, stat_rx_pause_soft[31:0]);
        addr = 32'h1_08FC; hwchk_axil_read (addr_offset,addr, stat_rx_pause_soft[63:32]);
        addr = 32'h1_0900; hwchk_axil_read (addr_offset,addr, stat_rx_user_pause_soft[31:0]);
        addr = 32'h1_0904; hwchk_axil_read (addr_offset,addr, stat_rx_user_pause_soft[63:32]);
        addr = 32'h1_0908; hwchk_axil_read (addr_offset,addr, stat_rx_inrangeerr_soft[31:0]);
        addr = 32'h1_090C; hwchk_axil_read (addr_offset,addr, stat_rx_inrangeerr_soft[63:32]);
        addr = 32'h1_0910; hwchk_axil_read (addr_offset,addr, stat_rx_truncated_soft[31:0]);
        addr = 32'h1_0914; hwchk_axil_read (addr_offset,addr, stat_rx_truncated_soft[63:32]);
        addr = 32'h1_0918; hwchk_axil_read (addr_offset,addr, stat_rx_test_pattern_mismatch_soft[31:0]);
        addr = 32'h1_091C; hwchk_axil_read (addr_offset,addr, stat_rx_test_pattern_mismatch_soft[63:32]);


        $display("-- MAC STATISTICS -----------------------------------");
        $display("    status_tx_cycle_soft_count            = %0d", status_tx_cycle_soft_count);
        $display("    stat_tx_frame_error_soft              = %0d", stat_tx_frame_error_soft);
        $display("    stat_tx_total_packets_soft            = %0d", stat_tx_total_packets_soft);
        $display("    stat_tx_total_good_packets_soft       = %0d", stat_tx_total_good_packets_soft);
        $display("    stat_tx_total_bytes_soft              = %0d", stat_tx_total_bytes_soft);
        $display("    stat_tx_total_good_bytes_soft         = %0d", stat_tx_total_good_bytes_soft);
        $display("    stat_tx_packet_64_bytes_soft          = %0d", stat_tx_packet_64_bytes_soft);
        $display("    stat_tx_packet_65_127_bytes_soft      = %0d", stat_tx_packet_65_127_bytes_soft);
        $display("    stat_tx_packet_128_255_bytes_soft     = %0d", stat_tx_packet_128_255_bytes_soft);
        $display("    stat_tx_packet_256_511_bytes_soft     = %0d", stat_tx_packet_256_511_bytes_soft);
        $display("    stat_tx_packet_512_1023_bytes_soft    = %0d", stat_tx_packet_512_1023_bytes_soft);
        $display("    stat_tx_packet_1024_1518_bytes_soft   = %0d", stat_tx_packet_1024_1518_bytes_soft);
        $display("    stat_tx_packet_1519_1522_bytes_soft   = %0d", stat_tx_packet_1519_1522_bytes_soft);
        $display("    stat_tx_packet_1523_1548_bytes_soft   = %0d", stat_tx_packet_1523_1548_bytes_soft);
        $display("    stat_tx_packet_1549_2047_bytes_soft   = %0d", stat_tx_packet_1549_2047_bytes_soft);
        $display("    stat_tx_packet_2048_4095_bytes_soft   = %0d", stat_tx_packet_2048_4095_bytes_soft);
        $display("    stat_tx_packet_4096_8191_bytes_soft   = %0d", stat_tx_packet_4096_8191_bytes_soft);
        $display("    stat_tx_packet_8192_9215_bytes_soft   = %0d", stat_tx_packet_8192_9215_bytes_soft);
        $display("    stat_tx_packet_large_soft             = %0d", stat_tx_packet_large_soft);
        $display("    stat_tx_packet_small_soft             = %0d", stat_tx_packet_small_soft);
        $display("    stat_tx_bad_fcs_soft                  = %0d", stat_tx_bad_fcs_soft);
        $display("    stat_tx_unicast_soft                  = %0d", stat_tx_unicast_soft);
        $display("    stat_tx_multicast_soft                = %0d", stat_tx_multicast_soft);
        $display("    stat_tx_broadcast_soft                = %0d", stat_tx_broadcast_soft);
        $display("    stat_tx_vlan_soft                     = %0d", stat_tx_vlan_soft);

        $display("    status_rx_cycle_soft_count            = %0d", status_rx_cycle_soft_count);
        $display("    stat_rx_framing_err_soft              = %0d", stat_rx_framing_err_soft);
        $display("    stat_rx_bad_code_soft                 = %0d", stat_rx_bad_code_soft);
        $display("    stat_rx_total_packets_soft            = %0d", stat_rx_total_packets_soft);
        $display("    stat_rx_total_good_packets_soft       = %0d", stat_rx_total_good_packets_soft);
        $display("    stat_rx_total_bytes_soft              = %0d", stat_rx_total_bytes_soft);
        $display("    stat_rx_total_good_bytes_soft         = %0d", stat_rx_total_good_bytes_soft);
        $display("    stat_rx_packet_64_bytes_soft          = %0d", stat_rx_packet_64_bytes_soft);
        $display("    stat_rx_packet_65_127_bytes_soft      = %0d", stat_rx_packet_65_127_bytes_soft);
        $display("    stat_rx_packet_128_255_bytes_soft     = %0d", stat_rx_packet_128_255_bytes_soft);
        $display("    stat_rx_packet_256_511_bytes_soft     = %0d", stat_rx_packet_256_511_bytes_soft);
        $display("    stat_rx_packet_512_1023_bytes_soft    = %0d", stat_rx_packet_512_1023_bytes_soft);
        $display("    stat_rx_packet_1024_1518_bytes_soft   = %0d", stat_rx_packet_1024_1518_bytes_soft);
        $display("    stat_rx_packet_1519_1522_bytes_soft   = %0d", stat_rx_packet_1519_1522_bytes_soft);
        $display("    stat_rx_packet_1523_1548_bytes_soft   = %0d", stat_rx_packet_1523_1548_bytes_soft);
        $display("    stat_rx_packet_1549_2047_bytes_soft   = %0d", stat_rx_packet_1549_2047_bytes_soft);
        $display("    stat_rx_packet_2048_4095_bytes_soft   = %0d", stat_rx_packet_2048_4095_bytes_soft);
        $display("    stat_rx_packet_4096_8191_bytes_soft   = %0d", stat_rx_packet_4096_8191_bytes_soft);
        $display("    stat_rx_packet_8192_9215_bytes_soft   = %0d", stat_rx_packet_8192_9215_bytes_soft);
        $display("    stat_rx_packet_large_soft             = %0d", stat_rx_packet_large_soft);
        $display("    stat_rx_packet_small_soft             = %0d", stat_rx_packet_small_soft);
        $display("    stat_rx_undersize_soft                = %0d", stat_rx_undersize_soft);
        $display("    stat_rx_fragment_soft                 = %0d", stat_rx_fragment_soft);
        $display("    stat_rx_oversize_soft                 = %0d", stat_rx_oversize_soft);
        $display("    stat_rx_toolong_soft                  = %0d", stat_rx_toolong_soft);
        $display("    stat_rx_jabber_soft                   = %0d", stat_rx_jabber_soft);
        $display("    stat_rx_bad_fcs_soft                  = %0d", stat_rx_bad_fcs_soft);
        $display("    stat_rx_packet_bad_fcs_soft           = %0d", stat_rx_packet_bad_fcs_soft);
        $display("    stat_rx_stomped_fcs_soft              = %0d", stat_rx_stomped_fcs_soft);
        $display("    stat_rx_unicast_soft                  = %0d", stat_rx_unicast_soft);
        $display("    stat_rx_multicast_soft                = %0d", stat_rx_multicast_soft);
        $display("    stat_rx_broadcast_soft                = %0d", stat_rx_broadcast_soft);
        $display("    stat_rx_vlan_soft                     = %0d", stat_rx_vlan_soft);
        $display("    stat_rx_pause_soft                    = %0d", stat_rx_pause_soft);
        $display("    stat_rx_user_pause_soft               = %0d", stat_rx_user_pause_soft);
        $display("    stat_rx_inrangeerr_soft               = %0d", stat_rx_inrangeerr_soft);
        $display("    stat_rx_truncated_soft                = %0d", stat_rx_truncated_soft);
        $display("    stat_rx_test_pattern_mismatch_soft    = %0d", stat_rx_test_pattern_mismatch_soft);

        frame_stat_ready[channel] = 0;
        $display("%t Channel-%d  is done with reading status registers",$time,channel);

//tx and rx soft reg comparison
        // Integrity checking with GTF Mac tx,rx soft stats
        if (stat_tx_frame_error_soft != 0) begin
            $display ("ERROR: stat_tx_frame_error_soft != 0");
        end
        if (stat_tx_total_packets_soft != stat_rx_total_packets_soft) begin
            $display ("ERROR: stat_tx_total_packets_soft != stat_rx_total_packets (%0d != %0d)",stat_tx_total_packets_soft, stat_rx_total_packets_soft);
        end
        if (stat_tx_total_good_packets_soft != stat_rx_total_good_packets_soft) begin
            $display ("ERROR: stat_tx_total_good_packets_soft != stat_rx_total_good_packets (%0d != %0d)",stat_tx_total_good_packets_soft, stat_rx_total_good_packets_soft);
        end
        if (stat_tx_total_bytes_soft != stat_rx_total_bytes_soft) begin
            $display ("ERROR: stat_tx_total_bytes_soft != stat_rx_total_bytes (%0d != %0d)",stat_tx_total_bytes_soft, stat_rx_total_bytes_soft);
        end
        if (stat_tx_total_good_bytes_soft != stat_rx_total_good_bytes_soft) begin
            $display ("ERROR: stat_tx_total_good_bytes_soft != stat_rx_total_good_bytes (%0d != %0d)",stat_tx_total_good_bytes_soft, stat_rx_total_good_bytes_soft);
        end
        if (stat_tx_packet_64_bytes_soft != stat_rx_packet_64_bytes_soft) begin
            $display ("ERROR: stat_tx_packet_64_bytes_soft != stat_rx_packet_64_bytes (%0d != %0d)",stat_tx_packet_64_bytes_soft, stat_rx_packet_64_bytes_soft);
        end
        if (stat_tx_packet_65_127_bytes_soft != stat_rx_packet_65_127_bytes_soft) begin
            $display ("ERROR: stat_tx_packet_65_127_bytes_soft != stat_rx_packet_65_127_bytes (%0d != %0d)",stat_tx_packet_65_127_bytes_soft, stat_rx_packet_65_127_bytes_soft);
        end
        if (stat_tx_packet_128_255_bytes_soft != stat_rx_packet_128_255_bytes_soft) begin
            $display ("ERROR: stat_tx_packet_128_255_bytes_soft != stat_rx_packet_128_255_bytes (%0d != %0d)",stat_tx_packet_128_255_bytes_soft, stat_rx_packet_128_255_bytes_soft);
        end
        if (stat_tx_packet_256_511_bytes_soft != stat_rx_packet_256_511_bytes_soft) begin
            $display ("ERROR: stat_tx_packet_256_511_bytes_soft != stat_rx_packet_256_511_bytes (%0d != %0d)",stat_tx_packet_256_511_bytes_soft, stat_rx_packet_256_511_bytes_soft);
        end
        if (stat_tx_packet_512_1023_bytes_soft != stat_rx_packet_512_1023_bytes_soft) begin
            $display ("ERROR: stat_tx_packet_512_1023_bytes_soft != stat_rx_packet_512_1023_bytes (%0d != %0d)",stat_tx_packet_512_1023_bytes_soft, stat_rx_packet_512_1023_bytes_soft);
        end
        if (stat_tx_packet_1024_1518_bytes_soft != stat_rx_packet_1024_1518_bytes_soft) begin
            $display ("ERROR: stat_tx_packet_1024_1518_bytes_soft != stat_rx_packet_1024_1518_bytes (%0d != %0d)",stat_tx_packet_1024_1518_bytes_soft, stat_rx_packet_1024_1518_bytes_soft);
        end
        if (stat_tx_packet_1519_1522_bytes_soft != stat_rx_packet_1519_1522_bytes_soft) begin
            $display ("ERROR: stat_tx_packet_1519_1522_bytes_soft != stat_rx_packet_1519_1522_bytes (%0d != %0d)",stat_tx_packet_1519_1522_bytes_soft, stat_rx_packet_1519_1522_bytes_soft);
        end
        if (stat_tx_packet_1523_1548_bytes_soft != stat_rx_packet_1523_1548_bytes_soft) begin
            $display ("ERROR: stat_tx_packet_1523_1548_bytes_soft != stat_rx_packet_1523_1548_bytes (%0d != %0d)",stat_tx_packet_1523_1548_bytes_soft, stat_rx_packet_1523_1548_bytes_soft);
        end
        if (stat_tx_packet_1549_2047_bytes_soft != stat_rx_packet_1549_2047_bytes_soft) begin
            $display ("ERROR: stat_tx_packet_1549_2047_bytes_soft != stat_rx_packet_1549_2047_bytes (%0d != %0d)",stat_tx_packet_1549_2047_bytes_soft, stat_rx_packet_1549_2047_bytes_soft);
        end
        if (stat_tx_packet_2048_4095_bytes_soft != stat_rx_packet_2048_4095_bytes_soft) begin
            $display ("ERROR: stat_tx_packet_2048_4095_bytes_soft != stat_rx_packet_2048_4095_bytes (%0d != %0d)",stat_tx_packet_2048_4095_bytes_soft, stat_rx_packet_2048_4095_bytes_soft);
        end
        if (stat_tx_packet_4096_8191_bytes_soft != stat_rx_packet_4096_8191_bytes_soft) begin
            $display ("ERROR: stat_tx_packet_4096_8191_bytes_soft != stat_rx_packet_4096_8191_bytes (%0d != %0d)",stat_tx_packet_4096_8191_bytes_soft, stat_rx_packet_4096_8191_bytes_soft);
        end
        if (stat_tx_packet_8192_9215_bytes_soft != stat_rx_packet_8192_9215_bytes_soft) begin
            $display ("ERROR: stat_tx_packet_8192_9215_bytes_soft != stat_rx_packet_8192_9215_bytes (%0d != %0d)",stat_tx_packet_8192_9215_bytes_soft, stat_rx_packet_8192_9215_bytes_soft);
        end
        if (stat_tx_packet_large_soft != stat_rx_packet_large_soft) begin
            $display ("ERROR: stat_tx_packet_large_soft != stat_rx_packet_large (%0d != %0d)",stat_tx_packet_large_soft, stat_rx_packet_large_soft);
        end
        if (stat_tx_packet_small_soft != stat_rx_packet_small_soft) begin
            $display ("ERROR: stat_tx_packet_small_soft != stat_rx_packet_small (%0d != %0d)",stat_tx_packet_small_soft, stat_rx_packet_small_soft);
        end
        if (stat_tx_bad_fcs_soft != 0) begin
            $display ("ERROR: stat_tx_bad_fcs_soft != 0 (%0d != %0d)",stat_tx_bad_fcs_soft, 0);
        end
        if (stat_tx_unicast_soft != stat_rx_unicast_soft) begin
            $display ("ERROR: stat_tx_unicast_soft != stat_rx_unicast (%0d != %0d)",stat_tx_unicast_soft, stat_rx_unicast_soft);
        end
        if (stat_tx_multicast_soft != stat_rx_multicast_soft) begin
            $display ("ERROR: stat_tx_multicast_soft != stat_rx_multicast (%0d != %0d)",stat_tx_multicast_soft, stat_rx_multicast_soft);
        end
        if (stat_tx_broadcast_soft != stat_rx_broadcast_soft) begin
            $display ("ERROR: stat_tx_broadcast_soft != stat_rx_broadcast (%0d != %0d)",stat_tx_broadcast_soft, stat_rx_broadcast_soft);
        end
        if (stat_tx_vlan_soft != stat_rx_vlan_soft) begin
            $display ("ERROR: stat_tx_vlan_soft != stat_rx_vlan (%0d != %0d)",stat_tx_vlan_soft, stat_rx_vlan_soft);
        end

        if (stat_rx_framing_err_soft != 0) begin
            $display ("ERROR: stat_rx_framing_err_soft != 0 (%0d != %0d)",stat_rx_framing_err_soft, 0);
        end
        if (stat_rx_bad_code_soft != 0) begin
            $display ("ERROR: stat_rx_bad_code_soft != 0 (%0d != %0d)",stat_rx_bad_code_soft, 0);
        end

        if (stat_rx_total_packets_soft == stat_tx_total_packets_soft) 
        begin
            $display("%t Number of frames transmitted (%0d) are equal to number of frames received (%0d) for channel-%d", $time, stat_tx_total_packets_soft, stat_rx_total_packets_soft,channel);
        end
        else
        begin
            $display ("ERROR: Number of frames transmitted (%d) are NOT EQUAL to number of frames received (%d) for channel-%d", stat_tx_total_packets_soft, stat_rx_total_packets_soft,channel);
        end

        $display("** Test completed successfully channel-%d",channel);

//        $finish;

//    end
  end
      
// join
  endtask




endmodule
