/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

`timescale 1ps/1ps

`include "gtfmac_vnc_top.vh"

module gtfwizard_0_example_top_sim ();

    real time_samp [19:0];
    
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
      #200000			// Adjusting delay impacts the latency due to phase difference in tx and rx user clocks 
      forever
      begin
        // 333 Mhz...
        freerun_clk = #1666  ~freerun_clk;
        // 400 Mhz...
        //freerun_clk = #1250  ~freerun_clk;
      end
    end

    reg hb_gtwiz_reset_all_in = 1'b1;
    initial begin
      hb_gtwiz_reset_all_in = 1'b1;
      repeat (1000) @(posedge freerun_clk);
      hb_gtwiz_reset_all_in = 1'b0;
    end


    // Declare registers and wires to interface to the PRBS-based link status ports
    reg  link_down_latched_reset = 1'b0;
    wire link_status;
    wire link_down_latched;


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
/*
    initial
    begin
        // Await de-assertion of the master reset signal
        @(negedge hb_gtwiz_reset_all_in);
        $display("=====================================================================================================");
        $display("The selected configuration may or may not achieve stable PRBS-based link in loopback, due to its use mode");
        $display("When using these asymmetric features, user-specified bit patterns cause feature-specific");
        $display("behavior that may periodically disrupt the data stream due to coincidental matches of the provided");
        $display("PRBS pattern, causing checker mismatches and resulting in no, or lost lock. The IP core therefore");
        $display("disables checking of the PRBS-based link status within this simulation testbench. This simulation will");
        $display("simply run for a short period of time and then end with a test completed successfully message, but it");
        $display("should not be construed to mean that data integrity was observed in this configuration. You may wish");
        $display("to extend this simulation period to observe actual behavior, which is not predictable by this IP core.");
        $display("=====================================================================================================");
    
        // Await assertion of initial link indication or simulation timeout indicator
        @(posedge link_stable, simulation_timeout_check);
        if (simulation_timeout_check) begin
          $display("Time : %15d fs   FAIL: simulation timeout. Link never achieved.", $time);
          $display("** Error: Test did not complete successfully");
          $finish;
        end
        else begin
          $display("Time : %15d fs   Initial link achieved across all transceiver channels.", $time);
          // Reset the latched link down indicator, which is always set prior to initially achieving link
          $display("Time : %12d ps   Resetting latched link down indicator.", $time);
          link_down_latched_reset = 1'b1;
          repeat (5) @(freerun_clk);
          link_down_latched_reset = 1'b0;
        
          $display("Time : %15d fs   Continuing simulation for 50us to check for maintenance of link.", $time);
          #5E7;
        end
    
        // At simulation completion, if the link indicator is still high and no intermittent link loss was detected,
        // display a success message. Otherwise, display a failure message. Complete the simulation in either case.
        if ((link_status === 1'b1) && (link_down_latched === 1'b0)) begin
          $display("Time : %15d fs   PASS: simulation completed with maintained link.", $time);
          $display("** Test completed successfully");
        end
        else begin
          $display("Time : %15d fs   FAIL: simulation completed with subsequent link loss after after initial link.", $time);
          $display("** Error: Test did not complete successfully");
        end
    
      $finish;
    
    end
*/
    

    /////////////////////////////////////////////////////////////////////////////////////////////
    //  VNC Test 
    /////////////////////////////////////////////////////////////////////////////////////////////

    //parameter  VNC_LATENCY_CLK_PERIOD_NS  = 1.242;  // 805 MHz
    real  VNC_LATENCY_CLK_PERIOD_NS;   // Set based on the configured data rate

    // device config
    logic   ctl_tx_data_rate;
    logic   ctl_rx_data_rate;

    wire    ctl_tx_fcs_ins_enable           = 1'b0;
    wire    ctl_tx_ignore_fcs               = 1'b0;
    wire    ctl_rx_ignore_fcs               = 1'b0;
    wire    ctl_tx_custom_preamble_enable   = 1'b0;
    wire    ctl_rx_custom_preamble_enable   = 1'b0;
    wire    ctl_frm_gen_mode                = 1'b0; // 0=random, 1=incr. pattern
    wire    ctl_tx_variable_ipg             = 1'b0;
    wire    [13:0] ctl_rx_min_packet_len    = 14'd64;
    wire    [13:0] ctl_rx_max_packet_len    = 14'd1500;
    wire    [31:0] frames_to_send           = `CONFIG_FRAMES_TO_SEND; //32'd400;

    // Our local "copy" of the axi_aclk (for generating AXI-Lite transactions)
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

    reg     [31:0]      addr, data;
    reg     [15:0]      snd_time, rcv_time;
    reg     [15:0]      datav;
    reg     [31:0]      vnc_block_lock;
    integer             attempts;

    integer             lat, lat_cnt, lat_min, lat_max;
    real                lat_total;

    reg                 stop_req, stopping;

    // VNC stats
    reg     [63:0]      stat_vnc_tx_total_bytes;
    reg     [63:0]      stat_vnc_tx_total_good_bytes;
    reg     [63:0]      stat_vnc_tx_total_packets;
    reg     [63:0]      stat_vnc_tx_total_good_packets;
    reg     [63:0]      stat_vnc_tx_broadcast;
    reg     [63:0]      stat_vnc_tx_multicast;
    reg     [63:0]      stat_vnc_tx_unicast;
    reg     [63:0]      stat_vnc_tx_vlan;

    reg     [63:0]      stat_vnc_tx_packet_64_bytes;
    reg     [63:0]      stat_vnc_tx_packet_65_127_bytes;
    reg     [63:0]      stat_vnc_tx_packet_128_255_bytes;
    reg     [63:0]      stat_vnc_tx_packet_256_511_bytes;
    reg     [63:0]      stat_vnc_tx_packet_512_1023_bytes;
    reg     [63:0]      stat_vnc_tx_packet_1024_1518_bytes;
    reg     [63:0]      stat_vnc_tx_packet_1519_1522_bytes;
    reg     [63:0]      stat_vnc_tx_packet_1523_1548_bytes;
    reg     [63:0]      stat_vnc_tx_packet_1549_2047_bytes;
    reg     [63:0]      stat_vnc_tx_packet_2048_4095_bytes;
    reg     [63:0]      stat_vnc_tx_packet_4096_8191_bytes;
    reg     [63:0]      stat_vnc_tx_packet_8192_9215_bytes;

    reg     [63:0]      stat_vnc_tx_packet_small;
    reg     [63:0]      stat_vnc_tx_packet_large;
    reg     [63:0]      stat_vnc_tx_frame_error;
 
    reg                 stat_tx_unfout;
    reg                 stat_vnc_tx_overflow;

    reg     [63:0]      stat_vnc_rx_unicast;
    reg     [63:0]      stat_vnc_rx_multicast;
    reg     [63:0]      stat_vnc_rx_broadcast;
    reg     [63:0]      stat_vnc_rx_vlan;

    reg     [63:0]      stat_vnc_rx_total_bytes;
    reg     [63:0]      stat_vnc_rx_total_good_bytes;
    reg     [63:0]      stat_vnc_rx_total_packets;
    reg     [63:0]      stat_vnc_rx_total_good_packets;

    reg     [63:0]      stat_vnc_rx_inrangeerr;
    reg     [63:0]      stat_vnc_rx_bad_fcs;

    reg     [63:0]      stat_vnc_rx_packet_64_bytes;
    reg     [63:0]      stat_vnc_rx_packet_65_127_bytes;
    reg     [63:0]      stat_vnc_rx_packet_128_255_bytes;
    reg     [63:0]      stat_vnc_rx_packet_256_511_bytes;
    reg     [63:0]      stat_vnc_rx_packet_512_1023_bytes;
    reg     [63:0]      stat_vnc_rx_packet_1024_1518_bytes;
    reg     [63:0]      stat_vnc_rx_packet_1519_1522_bytes;
    reg     [63:0]      stat_vnc_rx_packet_1523_1548_bytes;
    reg     [63:0]      stat_vnc_rx_packet_1549_2047_bytes;
    reg     [63:0]      stat_vnc_rx_packet_2048_4095_bytes;
    reg     [63:0]      stat_vnc_rx_packet_4096_8191_bytes;
    reg     [63:0]      stat_vnc_rx_packet_8192_9215_bytes;

    reg     [63:0]      stat_vnc_rx_oversize;
    reg     [63:0]      stat_vnc_rx_undersize;
    reg     [63:0]      stat_vnc_rx_toolong;
    reg     [63:0]      stat_vnc_rx_packet_small;
    reg     [63:0]      stat_vnc_rx_packet_large;
    reg     [63:0]      stat_vnc_rx_jabber;
    reg     [63:0]      stat_vnc_rx_fragment;
    reg     [63:0]      stat_vnc_rx_packet_bad_fcs;

    reg     [63:0]      stat_vnc_rx_user_pause;
    reg     [63:0]      stat_vnc_rx_pause;

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
    

    //initial begin
    //
    //    $vcdpluson();
    //
    //end

    reg [31:0]  frames_received;
    bit         timed_out = '0;

    initial begin

        frames_received = 0;

        forever begin
            //wait (gtfwizard_0_example_top_sim.u_exdes_top.i_gtfmac_vnc_core.i_rx_mon.i_rx_mon_stat.i_stat_total_packets.incr === 1);
            //wait (gtfwizard_0_example_top_sim.u_exdes_top.i_gtfmac_vnc_core.i_rx_mon.i_rx_mon_stat.i_stat_total_packets.incr === 0);
            wait (gtfwizard_0_example_top_sim.u_exdes_top.i_gtfmac_vnc_core.i_rx_mon.i_rx_mon_stat.i_stat_total_packets.incr === 1);
            wait (gtfwizard_0_example_top_sim.u_exdes_top.i_gtfmac_vnc_core.i_rx_mon.i_rx_mon_stat.i_stat_total_packets.incr === 0);
            frames_received = frames_received + 1;
            $display("%t Received frame %0d", $time, frames_received);
        end

    end

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

        force   gtfmac_vnc_top.jtag_axil_awaddr  = s_axil_awaddr;
        force   gtfmac_vnc_top.jtag_axil_awprot  = s_axil_awprot;
        force   gtfmac_vnc_top.jtag_axil_awvalid = s_axil_awvalid;
        force   gtfmac_vnc_top.jtag_axil_wdata   = s_axil_wdata;
        force   gtfmac_vnc_top.jtag_axil_wstrb   = s_axil_wstrb;
        force   gtfmac_vnc_top.jtag_axil_wvalid  = s_axil_wvalid;
        force   gtfmac_vnc_top.jtag_axil_bready  = s_axil_bready;
        force   gtfmac_vnc_top.jtag_axil_araddr  = s_axil_araddr;
        force   gtfmac_vnc_top.jtag_axil_arprot  = s_axil_arprot;
        force   gtfmac_vnc_top.jtag_axil_arvalid = s_axil_arvalid;
        force   gtfmac_vnc_top.jtag_axil_rready  = s_axil_rready;

        force   axi_aclk                         = gtfmac_vnc_top.axi_aclk;
        force   axi_aresetn                      = gtfmac_vnc_top.axi_aresetn;
 
        force   s_axil_arready                   = gtfmac_vnc_top.jtag_axil_arready;
        force   s_axil_rdata                     = gtfmac_vnc_top.jtag_axil_rdata;
        force   s_axil_rresp                     = gtfmac_vnc_top.jtag_axil_rresp;
        force   s_axil_rvalid                    = gtfmac_vnc_top.jtag_axil_rvalid;
        force   s_axil_awready                   = gtfmac_vnc_top.jtag_axil_awready;
        force   s_axil_wready                    = gtfmac_vnc_top.jtag_axil_wready;
        force   s_axil_bvalid                    = gtfmac_vnc_top.jtag_axil_bvalid;
        force   s_axil_bresp                     = gtfmac_vnc_top.jtag_axil_bresp;

    end


    // Our testcase:
    //  - wait for the VNC to detect block block
    //  - align bitslip
    //  - init stats
    //  - send traffic
    //  - collect stats
    //  - compare TX and RX stats

    initial begin

        wait (axi_aresetn == 1'b1);

        repeat (1000) @(negedge axi_aclk);

        $display("%t Waiting for DUT to come alive...", $time);
        attempts = 0;
        do begin
            
            vnc_axil_read (32'h000, data);
            data     = data & 32'h3;
            attempts += 1;

        end
        while (data != 32'h0 && attempts < 100_000 );

        $display("%t Measured Clock Periods/Freq...", $time);
        $display("%t     [CLKIN]        %7.3f ns (%7.3f MHz)", $time, (time_samp[1] - time_samp[0]) / 1000.0, 1000000.0 / (time_samp[1] - time_samp[0]) );
        $display("%t     [CLKOUT1]      %7.3f ns (%7.3f MHz)", $time, (time_samp[3] - time_samp[2]) / 1000.0, 1000000.0 / (time_samp[3] - time_samp[2]) );
        $display("%t     [CLKOUT2]      %7.3f ns (%7.3f MHz)", $time, (time_samp[5] - time_samp[4]) / 1000.0, 1000000.0 / (time_samp[5] - time_samp[4]) );
        $display("%t     [TX CLK]       %7.3f ns (%7.3f MHz)", $time, (time_samp[7] - time_samp[6]) / 1000.0, 1000000.0 / (time_samp[7] - time_samp[6]) );
        $display("%t     [RX CLK]       %7.3f ns (%7.3f MHz)", $time, (time_samp[9] - time_samp[8]) / 1000.0, 1000000.0 / (time_samp[9] - time_samp[8]) );
        $display("%t     [TX->RX Dly]   %7.3f ns ", $time, time_samp[10] / 1000.0 );
        
        $display("%t Observed gtfmac status = %0x", $time, data);

        if (attempts >= 100000) begin
            $display("%t ERROR - DUT did not come out of reset", $time);
            $finish;
        end


		$display( "========================================");
		$display( "	Running bring-up procedure...");
		$display( "========================================");
		$display( "");


        $display("%t Read the GTF currently configured data rate", $time);
        addr    = 32'h1_0000;
        vnc_axil_read (addr, data);
        ctl_rx_data_rate = data[0];
        ctl_tx_data_rate = data[1];
        $display("%t         ctl_rx_data_rate=%0x", $time, ctl_rx_data_rate);
        $display("%t         ctl_tx_data_rate=%0x", $time, ctl_tx_data_rate);

        if (ctl_rx_data_rate == 1'b1) begin
            VNC_LATENCY_CLK_PERIOD_NS = 2.4824;  // 402.5 MHz
			$display( "	GTF is configured for 25G" );

        end
        else begin
            VNC_LATENCY_CLK_PERIOD_NS = 1.5515;  // 644 MHz
			$display( "	GTF is configured for 10G" );
       end



        $display("%t Enable tx_userrdy / rx_userrdy", $time);
        addr    = 32'hC;
        data    = 32'h3;
        vnc_axil_write  (addr, data);


        $display("%t Configure near-end loopback", $time);
        addr    = 32'h1_0408;
		data    = 32'h21;

        //vnc_axil_read (addr, data);
        //data[6:4] = 3'b010;
        vnc_axil_write  (addr, data);

        $display("%t Reset the RX side of the GT", $time);
        addr    = 32'h1_0400;
        data    = 32'h2;
        vnc_axil_write  (addr, data);
        data    = 32'h0;
        vnc_axil_write  (addr, data);


        $display("%t VNC:    Set up the TX/RX data rate to match", $time);
        addr    = 32'h10;
        vnc_axil_read (addr, data);
        data    = data | (ctl_tx_data_rate << 0);
        data    = data | (ctl_rx_data_rate << 16);
        $display("%t         VNC config=%0x", $time, data);
        vnc_axil_write  (addr, data);

        $display("%t Allow MAC side of the GTFMAC to bitslip", $time);
        addr    = 32'ha4;
        data    = 32'h0;
        vnc_axil_write  (addr, data);

        // Wait for block lock
        $display("%t Waiting for VNC to detect block lock...", $time);
        attempts = 0;
        do begin
            
            vnc_axil_read (32'h0A0, vnc_block_lock);
            vnc_block_lock   = vnc_block_lock & (1 << 16);
            attempts += 1;

        end
        while (!vnc_block_lock && attempts < 100_000 );

        if (attempts >= 100_000) begin
            $display("%t ERROR - no block lock", $time);
            $finish;
        end

        $display("%t Block lock found.", $time);

        // Only correct bitslip if we are in 10G mode
        if (!ctl_tx_data_rate) begin

            $display("%t Allow bitslip logic to correct bitslip in the transceiver...", $time);
            addr    = 32'ha4;
            data    = 32'h1;
            vnc_axil_write  (addr, data);

            attempts = 0;
            do begin
                
                vnc_axil_read (32'h0A0, data);
                data    = data & (1 << 18); // done bit
                attempts += 1;
     
            end
            while (!data && attempts < 100 );
     
            if (attempts >= 100) begin
                $display("%t ERROR - alignment process failed", $time);
                $finish;
            end

            $display("%t Bitslip issued.", $time);

            $display("%t Waiting for VNC to detect block lock...", $time);
            attempts = 0;
            do begin
                
                vnc_axil_read (32'h0A0, vnc_block_lock);
                vnc_block_lock    = vnc_block_lock & (1 << 16);
                attempts += 1;

            end
            while (!vnc_block_lock && attempts < 100_000 );

            if (attempts >= 100_000) begin
                $display("%t ERROR - no block lock", $time);
                $finish;
            end

            $display("%t Block lock found.", $time);

        end

        $display("%t Waiting for link up.", $time);

        attempts = 0;
        do begin
            
            vnc_axil_read (32'h0, data);
            data     = data & (4'hF << 8);
            attempts += 1;

        end
        while (!(data == 32'h0) && attempts < 10_000 );

        $display("%t After %0d attempts, observed gtfmac status = %0x", $time, attempts, data);

        if (attempts >= 100) begin
            $display("%t ERROR - link down", $time);
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
        vnc_axil_read (addr, data);
        $display("%t         CONFIGURATION_TX_REG1=%0x", $time, data);
        data[1]     = ctl_tx_fcs_ins_enable;
        data[2]     = ctl_tx_ignore_fcs;
        data[3]     = ctl_tx_custom_preamble_enable;
        $display("%t         CONFIGURATION_TX_REG1=%0x", $time, data);
        vnc_axil_write  (addr, data);

        $display("%t GTFMAC: Configure CONFIGURATION_RX_REG1", $time);
        $display("%t         ctl_rx_ignore_fcs=%0x", $time, ctl_rx_ignore_fcs);
        $display("%t         ctl_rx_custom_preamble_enable=%0x", $time, ctl_rx_custom_preamble_enable);
        addr    = 32'h1_0008;
        vnc_axil_read (addr, data);
        data[2]     = ctl_rx_ignore_fcs;
        data[6]     = ctl_rx_custom_preamble_enable;
        vnc_axil_write  (addr, data);

        $display("%t GTFMAC: Configure CONFIGURATION_RX_MTU1", $time);
        $display("%t         ctl_rx_min_packet_len=%0x", $time, ctl_rx_min_packet_len);
        addr    = 32'h1_000c;
        vnc_axil_read (addr, data);
        data    = ctl_rx_min_packet_len;
        vnc_axil_write  (addr, data);

        $display("%t GTFMAC: Configure CONFIGURATION_RX_MTU2", $time);
        $display("%t         ctl_rx_max_packet_len=%0x", $time, ctl_rx_max_packet_len);
        addr    = 32'h1_0010;
        vnc_axil_read (addr, data);
        $display("%t         Read %0x", $time, data);
        data    = ctl_rx_max_packet_len;
        vnc_axil_write  (addr, data);
        vnc_axil_read (addr, data);

        $display("%t VNC:    Set up the VNC fcs_ins_enable and preamble_enable.", $time);
        $display("%t         ctl_tx_fcs_ins_enable=%0x", $time, ctl_tx_fcs_ins_enable);
        $display("%t         ctl_tx_custom_preamble_enable=%0x", $time, ctl_tx_custom_preamble_enable);
        $display("%t         ctl_rx_custom_preamble_enable=%0x", $time, ctl_rx_custom_preamble_enable);
        addr    = 32'h10;
        vnc_axil_read (addr, data);
        data    = data | (ctl_tx_fcs_ins_enable << 4);
        data    = data | (ctl_tx_custom_preamble_enable << 8);
        data    = data | (ctl_rx_custom_preamble_enable << 24);
        $display("%t         VNC config=%0x", $time, data);
        vnc_axil_write  (addr, data);

        $display("%t VNC:    Set the min and max frame lengths for the generator.", $time);
        $display("%t         ctl_rx_min_packet_len=%0x", $time, ctl_rx_min_packet_len);
        $display("%t         ctl_rx_max_packet_len=%0x", $time, ctl_rx_max_packet_len);
        addr    = 32'h28;
        data    = ctl_rx_min_packet_len;
        vnc_axil_write  (addr, data);

        addr    = 32'h24;
        data    = ctl_rx_max_packet_len;
        vnc_axil_write  (addr, data);

        // Set the mode
        $display("%t Set the frame generation mode.", $time);
        $display("%t         ctl_frm_gen_mode=%0x", $time, ctl_frm_gen_mode);
        $display("%t         ctl_tx_variable_ipg=%0x", $time, ctl_tx_variable_ipg);
        addr    = 32'h14;
        data    = 0;
        data[0] = ctl_frm_gen_mode;
        data[8] = ctl_tx_variable_ipg;
        vnc_axil_write  (addr, data);

        // Specify the number of frames
        $display("%t Configure the number of frames to send (%0d)", $time, frames_to_send);
        addr    = 32'h2c;
        data    = frames_to_send;
        vnc_axil_write  (addr, data);

        // Specify the number of frames to the latency monitor
        addr    = 32'h8012;
        vnc_axil_write  (addr, data);

        // Enable the latency monitor
        $display("%t Enable the latency monitor.", $time);
        addr    = 32'h8000;
        data    = 0;
        data    = data | (1'b1 << 0); // lm_go
        vnc_axil_write  (addr, data);

        $display("%t Tick the VNC stats to initialize them.", $time);
        addr    = 32'h90;
        data    = 32'h1;
        vnc_axil_write  (addr, data);

        $display("%t Tick the GTFMAC stats to initialize them.", $time);
        addr    = 32'h1_0000 | 32'h40C;
        data    = 32'h1;
        vnc_axil_write  (addr, data);

        $display("%t Enable the frame generator and monitor.", $time);
        addr    = 32'h20;
        data    = 0;
        data    = data | (1'b1 << 0); // gen_en
        data    = data | (1'b1 << 4); // mon_en
        vnc_axil_write  (addr, data);


/*
        // From the board env
        vnc_axil_write (32'h10000,32'h00000000);
        vnc_axil_write (32'h10004,32'h00000c03);
        vnc_axil_write (32'h10008,32'h00000039);
        vnc_axil_write (32'h10,32'h00000010);
        vnc_axil_write (32'h28,32'h00000040);
        vnc_axil_write (32'h24,32'h00002580);
        vnc_axil_write (32'h14,32'h00000000);
        vnc_axil_write (32'h14,32'h00000001);
        vnc_axil_write (32'h2c,frames_to_send);

        $display("%t Tick the VNC stats to initialize them.", $time);
        addr    = 32'h90;
        data    = 32'h1;
        vnc_axil_write  (addr, data);

        $display("%t Tick the GTFMAC stats to initialize them.", $time);
        addr    = 32'h1_0000 | 32'h40C;
        data    = 32'h1;
        vnc_axil_write  (addr, data);

        vnc_axil_write (32'h8000,32'h00000001);
        vnc_axil_write (32'h20,32'h00000011);
*/


        stop_req = 0;
        stopping = 0;

        fork
            
            begin
                lat_cnt   = 0;
                lat_min   = 1000;
                lat_max   = 0;
                lat_total = 0;
                do begin

                    /*
                    if (frames_received == 25) begin
                        $display("%t Start latency run", $time);
                        addr    = 32'h94;
                        data[0] = 1'b1;
                        vnc_axil_write  (addr, data);
                    end
                    else */
                    
                    if (stop_req) begin

                        stopping = 1;

                        // Disable the frame generator
                        addr    = 32'h20;
                        data    = 0;
                        data    = data | (1'b0 << 0); // gen_en
                        vnc_axil_write  (addr, data);

                        // Flush pipeline
                        repeat (5000) @(negedge axi_aclk);

                    end

                    vnc_axil_read (32'h8004, datav);  // data available

                    if (data[16]) begin
                        $display("ERROR:  FIFO overflow!");
                        $finish;
                    end

                    if (datav > 0) begin

                        // $display("There are %0d entries available to read.", datav);

                        for (int i=0;i<datav;i=i+1) begin
                            //$display("%t Reading time....", $time);
                            vnc_axil_read (32'h8008, {rcv_time, snd_time});

                            // Compute the delta between the send time and the receive time
                            // We can take away one clock, because rx_tsof is launched off of the previous
                            // rxusrclk rising edge, and it's agreed that this is the end measurement time.
                            if (rcv_time - snd_time > 0) begin
                                lat = rcv_time - snd_time - 1;
                            end
                            else begin
                                lat = 65535 - snd_time + rcv_time - 1;
                            end
                            $display("%0t Latency: %d ::  %0d %0d %0d", $time, lat_cnt + 1, rcv_time, snd_time, lat);

                            // $display("%0t Latency:  %0d ticks (%0.2f ns)", $time, lat, lat*VNC_LATENCY_CLK_PERIOD_NS);

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
                  wait(frames_received == frames_to_send || timed_out);
                  disable fork;
                end join

                $display("%t Stopping...", $time);
                stop_req    = 1;

            end

        join

        $display("%t Stopped.", $time);

        $display("%t Tick the VNC stats for collection.", $time);
        addr    = 32'h90;
        data    = 32'h1;
        vnc_axil_write  (addr, data);

        $display("%t Tick the GTFMAC stats for collection", $time);
        addr    = 32'h1_0000 | 32'h40C;
        data    = 32'h1;
        vnc_axil_write  (addr, data);

        // env.wait_tc_clk(50);
        repeat (50) @(negedge axi_aclk);

        $display("%0t Latency calculation:  %0d/%0.2f/%0d ticks (%0d records).  %0.2f ns/%0.2f ns/%0.2f ns", $time, lat_min, lat_total/lat_cnt, lat_max, lat_cnt, 
                                                                                                                    lat_min*VNC_LATENCY_CLK_PERIOD_NS, lat_total/lat_cnt*VNC_LATENCY_CLK_PERIOD_NS, lat_max*VNC_LATENCY_CLK_PERIOD_NS
                );
`ifdef CONFIG_DISPLAY_TB_REGS
        // Read out the VNC stats
        addr = 32'h400; vnc_axil_read (addr, stat_vnc_tx_unicast[31:0]);
        addr = 32'h404; vnc_axil_read (addr, stat_vnc_tx_unicast[63:32]);
        addr = 32'h408; vnc_axil_read (addr, stat_vnc_tx_multicast[31:0]);
        addr = 32'h40c; vnc_axil_read (addr, stat_vnc_tx_multicast[63:32]);
        addr = 32'h410; vnc_axil_read (addr, stat_vnc_tx_broadcast[31:0]);
        addr = 32'h414; vnc_axil_read (addr, stat_vnc_tx_broadcast[63:32]);
        addr = 32'h418; vnc_axil_read (addr, stat_vnc_tx_vlan[31:0]);
        addr = 32'h41c; vnc_axil_read (addr, stat_vnc_tx_vlan[63:32]);

        addr = 32'h420; vnc_axil_read (addr, stat_vnc_tx_total_packets[31:0]);
        addr = 32'h424; vnc_axil_read (addr, stat_vnc_tx_total_packets[63:32]);
        addr = 32'h428; vnc_axil_read (addr, stat_vnc_tx_total_bytes[31:0]);
        addr = 32'h42c; vnc_axil_read (addr, stat_vnc_tx_total_bytes[63:32]);
        addr = 32'h430; vnc_axil_read (addr, stat_vnc_tx_total_good_packets[31:0]);
        addr = 32'h434; vnc_axil_read (addr, stat_vnc_tx_total_good_packets[63:32]);
        addr = 32'h438; vnc_axil_read (addr, stat_vnc_tx_total_good_bytes[31:0]);
        addr = 32'h43c; vnc_axil_read (addr, stat_vnc_tx_total_good_bytes[63:32]);

        addr = 32'h440; vnc_axil_read (addr, stat_vnc_tx_packet_64_bytes[31:0]);
        addr = 32'h444; vnc_axil_read (addr, stat_vnc_tx_packet_64_bytes[63:32]);
        addr = 32'h448; vnc_axil_read (addr, stat_vnc_tx_packet_65_127_bytes[31:0]);
        addr = 32'h44c; vnc_axil_read (addr, stat_vnc_tx_packet_65_127_bytes[63:32]);
        addr = 32'h450; vnc_axil_read (addr, stat_vnc_tx_packet_128_255_bytes[31:0]);
        addr = 32'h454; vnc_axil_read (addr, stat_vnc_tx_packet_128_255_bytes[63:32]);
        addr = 32'h458; vnc_axil_read (addr, stat_vnc_tx_packet_256_511_bytes[31:0]);
        addr = 32'h45c; vnc_axil_read (addr, stat_vnc_tx_packet_256_511_bytes[63:32]);
        addr = 32'h460; vnc_axil_read (addr, stat_vnc_tx_packet_512_1023_bytes[31:0]);
        addr = 32'h464; vnc_axil_read (addr, stat_vnc_tx_packet_512_1023_bytes[63:32]);
        addr = 32'h468; vnc_axil_read (addr, stat_vnc_tx_packet_1024_1518_bytes[31:0]);
        addr = 32'h46c; vnc_axil_read (addr, stat_vnc_tx_packet_1024_1518_bytes[63:32]);
        addr = 32'h470; vnc_axil_read (addr, stat_vnc_tx_packet_1519_1522_bytes[31:0]);
        addr = 32'h474; vnc_axil_read (addr, stat_vnc_tx_packet_1519_1522_bytes[63:32]);
        addr = 32'h478; vnc_axil_read (addr, stat_vnc_tx_packet_1523_1548_bytes[31:0]);
        addr = 32'h47c; vnc_axil_read (addr, stat_vnc_tx_packet_1523_1548_bytes[63:32]);
        addr = 32'h480; vnc_axil_read (addr, stat_vnc_tx_packet_1549_2047_bytes[31:0]);
        addr = 32'h484; vnc_axil_read (addr, stat_vnc_tx_packet_1549_2047_bytes[63:32]);
        addr = 32'h488; vnc_axil_read (addr, stat_vnc_tx_packet_2048_4095_bytes[31:0]);
        addr = 32'h48c; vnc_axil_read (addr, stat_vnc_tx_packet_2048_4095_bytes[63:32]);
        addr = 32'h490; vnc_axil_read (addr, stat_vnc_tx_packet_4096_8191_bytes[31:0]);
        addr = 32'h494; vnc_axil_read (addr, stat_vnc_tx_packet_4096_8191_bytes[63:32]);
        addr = 32'h498; vnc_axil_read (addr, stat_vnc_tx_packet_8192_9215_bytes[31:0]);
        addr = 32'h49c; vnc_axil_read (addr, stat_vnc_tx_packet_8192_9215_bytes[63:32]);
        addr = 32'h4a0; vnc_axil_read (addr, stat_vnc_tx_packet_small[31:0]);
        addr = 32'h4a4; vnc_axil_read (addr, stat_vnc_tx_packet_small[63:32]);
        addr = 32'h4a8; vnc_axil_read (addr, stat_vnc_tx_packet_large[31:0]);
        addr = 32'h4ac; vnc_axil_read (addr, stat_vnc_tx_packet_large[63:32]);
        addr = 32'h4b0; vnc_axil_read (addr, stat_vnc_tx_frame_error[31:0]);
        addr = 32'h4b4; vnc_axil_read (addr, stat_vnc_tx_frame_error[63:32]);

        addr = 32'h4b8; vnc_axil_read(addr, data);
        stat_tx_unfout       = data[0];
        stat_vnc_tx_overflow = data[4];

        addr = 32'h600; vnc_axil_read (addr, stat_vnc_rx_unicast[31:0]);
        addr = 32'h604; vnc_axil_read (addr, stat_vnc_rx_unicast[63:32]);
        addr = 32'h608; vnc_axil_read (addr, stat_vnc_rx_multicast[31:0]);
        addr = 32'h60c; vnc_axil_read (addr, stat_vnc_rx_multicast[63:32]);
        addr = 32'h610; vnc_axil_read (addr, stat_vnc_rx_broadcast[31:0]);
        addr = 32'h614; vnc_axil_read (addr, stat_vnc_rx_broadcast[63:32]);
        addr = 32'h618; vnc_axil_read (addr, stat_vnc_rx_vlan[31:0]);
        addr = 32'h61c; vnc_axil_read (addr, stat_vnc_rx_vlan[63:32]);

        addr = 32'h620; vnc_axil_read (addr, stat_vnc_rx_total_packets[31:0]);
        addr = 32'h624; vnc_axil_read (addr, stat_vnc_rx_total_packets[63:32]);
        addr = 32'h628; vnc_axil_read (addr, stat_vnc_rx_total_bytes[31:0]);
        addr = 32'h62c; vnc_axil_read (addr, stat_vnc_rx_total_bytes[63:32]);
        addr = 32'h630; vnc_axil_read (addr, stat_vnc_rx_total_good_packets[31:0]);
        addr = 32'h634; vnc_axil_read (addr, stat_vnc_rx_total_good_packets[63:32]);
        addr = 32'h638; vnc_axil_read (addr, stat_vnc_rx_total_good_bytes[31:0]);
        addr = 32'h63c; vnc_axil_read (addr, stat_vnc_rx_total_good_bytes[63:32]);

        addr = 32'h640; vnc_axil_read (addr, stat_vnc_rx_packet_64_bytes[31:0]);
        addr = 32'h644; vnc_axil_read (addr, stat_vnc_rx_packet_64_bytes[63:32]);
        addr = 32'h648; vnc_axil_read (addr, stat_vnc_rx_packet_65_127_bytes[31:0]);
        addr = 32'h64c; vnc_axil_read (addr, stat_vnc_rx_packet_65_127_bytes[63:32]);
        addr = 32'h650; vnc_axil_read (addr, stat_vnc_rx_packet_128_255_bytes[31:0]);
        addr = 32'h654; vnc_axil_read (addr, stat_vnc_rx_packet_128_255_bytes[63:32]);
        addr = 32'h658; vnc_axil_read (addr, stat_vnc_rx_packet_256_511_bytes[31:0]);
        addr = 32'h65c; vnc_axil_read (addr, stat_vnc_rx_packet_256_511_bytes[63:32]);
        addr = 32'h660; vnc_axil_read (addr, stat_vnc_rx_packet_512_1023_bytes[31:0]);
        addr = 32'h664; vnc_axil_read (addr, stat_vnc_rx_packet_512_1023_bytes[63:32]);
        addr = 32'h668; vnc_axil_read (addr, stat_vnc_rx_packet_1024_1518_bytes[31:0]);
        addr = 32'h66c; vnc_axil_read (addr, stat_vnc_rx_packet_1024_1518_bytes[63:32]);
        addr = 32'h670; vnc_axil_read (addr, stat_vnc_rx_packet_1519_1522_bytes[31:0]);
        addr = 32'h674; vnc_axil_read (addr, stat_vnc_rx_packet_1519_1522_bytes[63:32]);
        addr = 32'h678; vnc_axil_read (addr, stat_vnc_rx_packet_1523_1548_bytes[31:0]);
        addr = 32'h67c; vnc_axil_read (addr, stat_vnc_rx_packet_1523_1548_bytes[63:32]);
        addr = 32'h680; vnc_axil_read (addr, stat_vnc_rx_packet_1549_2047_bytes[31:0]);
        addr = 32'h684; vnc_axil_read (addr, stat_vnc_rx_packet_1549_2047_bytes[63:32]);
        addr = 32'h688; vnc_axil_read (addr, stat_vnc_rx_packet_2048_4095_bytes[31:0]);
        addr = 32'h68c; vnc_axil_read (addr, stat_vnc_rx_packet_2048_4095_bytes[63:32]);
        addr = 32'h690; vnc_axil_read (addr, stat_vnc_rx_packet_4096_8191_bytes[31:0]);
        addr = 32'h694; vnc_axil_read (addr, stat_vnc_rx_packet_4096_8191_bytes[63:32]);
        addr = 32'h698; vnc_axil_read (addr, stat_vnc_rx_packet_8192_9215_bytes[31:0]);
        addr = 32'h69c; vnc_axil_read (addr, stat_vnc_rx_packet_8192_9215_bytes[63:32]);

        addr = 32'h6a0; vnc_axil_read (addr, stat_vnc_rx_inrangeerr[31:0]);
        addr = 32'h6a4; vnc_axil_read (addr, stat_vnc_rx_inrangeerr[63:32]);
        addr = 32'h6a8; vnc_axil_read (addr, stat_vnc_rx_bad_fcs[31:0]);
        addr = 32'h6ac; vnc_axil_read (addr, stat_vnc_rx_bad_fcs[63:32]);
        addr = 32'h6b0; vnc_axil_read (addr, stat_vnc_rx_oversize[31:0]);
        addr = 32'h6b4; vnc_axil_read (addr, stat_vnc_rx_oversize[63:32]);
        addr = 32'h6b8; vnc_axil_read (addr, stat_vnc_rx_undersize[31:0]);
        addr = 32'h6bc; vnc_axil_read (addr, stat_vnc_rx_undersize[63:32]);
        addr = 32'h6c0; vnc_axil_read (addr, stat_vnc_rx_toolong[31:0]);
        addr = 32'h6c4; vnc_axil_read (addr, stat_vnc_rx_toolong[63:32]);
        addr = 32'h6c8; vnc_axil_read (addr, stat_vnc_rx_packet_small[31:0]);
        addr = 32'h6cc; vnc_axil_read (addr, stat_vnc_rx_packet_small[63:32]);
        addr = 32'h6d0; vnc_axil_read (addr, stat_vnc_rx_packet_large[31:0]);
        addr = 32'h6d4; vnc_axil_read (addr, stat_vnc_rx_packet_large[63:32]);
        addr = 32'h6d8; vnc_axil_read (addr, stat_vnc_rx_jabber[31:0]);
        addr = 32'h6dc; vnc_axil_read (addr, stat_vnc_rx_jabber[63:32]);
        addr = 32'h6e0; vnc_axil_read (addr, stat_vnc_rx_fragment[31:0]);
        addr = 32'h6e4; vnc_axil_read (addr, stat_vnc_rx_fragment[63:32]);
        addr = 32'h6e8; vnc_axil_read (addr, stat_vnc_rx_packet_bad_fcs[31:0]);
        addr = 32'h6ec; vnc_axil_read (addr, stat_vnc_rx_packet_bad_fcs[63:32]);
        addr = 32'h6f0; vnc_axil_read (addr, stat_vnc_rx_user_pause[31:0]);
        addr = 32'h6f4; vnc_axil_read (addr, stat_vnc_rx_user_pause[63:32]);
        addr = 32'h6f8; vnc_axil_read (addr, stat_vnc_rx_pause[31:0]);
        addr = 32'h6fc; vnc_axil_read (addr, stat_vnc_rx_pause[63:32]);

        $display("-- VNC STATISTICS -----------------------------------");
        $display("    stat_vnc_tx_unicast                   = %0d", stat_vnc_tx_unicast);
        $display("    stat_vnc_tx_multicast                 = %0d", stat_vnc_tx_multicast);
        $display("    stat_vnc_tx_broadcast                 = %0d", stat_vnc_tx_broadcast);
        $display("    stat_vnc_tx_vlan                      = %0d", stat_vnc_tx_vlan);

        $display("    stat_vnc_tx_total_packets             = %0d", stat_vnc_tx_total_packets);
        $display("    stat_vnc_tx_total_bytes               = %0d", stat_vnc_tx_total_bytes);
        $display("    stat_vnc_tx_total_good_packets        = %0d", stat_vnc_tx_total_good_packets);
        $display("    stat_vnc_tx_total_good_bytes          = %0d", stat_vnc_tx_total_good_bytes);

        $display("    stat_vnc_tx_packet_64_bytes           = %0d", stat_vnc_tx_packet_64_bytes);
        $display("    stat_vnc_tx_packet_65_127_bytes       = %0d", stat_vnc_tx_packet_65_127_bytes);
        $display("    stat_vnc_tx_packet_128_255_bytes      = %0d", stat_vnc_tx_packet_128_255_bytes);
        $display("    stat_vnc_tx_packet_256_511_bytes      = %0d", stat_vnc_tx_packet_256_511_bytes);
        $display("    stat_vnc_tx_packet_512_1023_bytes     = %0d", stat_vnc_tx_packet_512_1023_bytes);
        $display("    stat_vnc_tx_packet_1024_1518_bytes    = %0d", stat_vnc_tx_packet_1024_1518_bytes);
        $display("    stat_vnc_tx_packet_1519_1522_bytes    = %0d", stat_vnc_tx_packet_1519_1522_bytes);
        $display("    stat_vnc_tx_packet_1523_1548_bytes    = %0d", stat_vnc_tx_packet_1523_1548_bytes);
        $display("    stat_vnc_tx_packet_1549_2047_bytes    = %0d", stat_vnc_tx_packet_1549_2047_bytes);
        $display("    stat_vnc_tx_packet_2048_4095_bytes    = %0d", stat_vnc_tx_packet_2048_4095_bytes);
        $display("    stat_vnc_tx_packet_4096_8191_bytes    = %0d", stat_vnc_tx_packet_4096_8191_bytes);
        $display("    stat_vnc_tx_packet_8192_9215_bytes    = %0d", stat_vnc_tx_packet_8192_9215_bytes);
        $display("    stat_vnc_tx_packet_small              = %0d", stat_vnc_tx_packet_small);
        $display("    stat_vnc_tx_packet_large              = %0d", stat_vnc_tx_packet_large);
        $display("    stat_vnc_tx_frame_error               = %0d", stat_vnc_tx_frame_error);

        $display("    stat_vnc_rx_unicast                   = %0d", stat_vnc_rx_unicast);
        $display("    stat_vnc_rx_multicast                 = %0d", stat_vnc_rx_multicast);
        $display("    stat_vnc_rx_broadcast                 = %0d", stat_vnc_rx_broadcast);
        $display("    stat_vnc_rx_vlan                      = %0d", stat_vnc_rx_vlan);

        $display("    stat_vnc_rx_total_packets             = %0d", stat_vnc_rx_total_packets);
        $display("    stat_vnc_rx_total_bytes               = %0d", stat_vnc_rx_total_bytes);
        $display("    stat_vnc_rx_total_good_packets        = %0d", stat_vnc_rx_total_good_packets);
        $display("    stat_vnc_rx_total_good_bytes          = %0d", stat_vnc_rx_total_good_bytes);

        $display("    stat_vnc_rx_packet_64_bytes           = %0d", stat_vnc_rx_packet_64_bytes);
        $display("    stat_vnc_rx_packet_65_127_bytes       = %0d", stat_vnc_rx_packet_65_127_bytes);
        $display("    stat_vnc_rx_packet_128_255_bytes      = %0d", stat_vnc_rx_packet_128_255_bytes);
        $display("    stat_vnc_rx_packet_256_511_bytes      = %0d", stat_vnc_rx_packet_256_511_bytes);
        $display("    stat_vnc_rx_packet_512_1023_bytes     = %0d", stat_vnc_rx_packet_512_1023_bytes);
        $display("    stat_vnc_rx_packet_1024_1518_bytes    = %0d", stat_vnc_rx_packet_1024_1518_bytes);
        $display("    stat_vnc_rx_packet_1519_1522_bytes    = %0d", stat_vnc_rx_packet_1519_1522_bytes);
        $display("    stat_vnc_rx_packet_1523_1548_bytes    = %0d", stat_vnc_rx_packet_1523_1548_bytes);
        $display("    stat_vnc_rx_packet_1549_2047_bytes    = %0d", stat_vnc_rx_packet_1549_2047_bytes);
        $display("    stat_vnc_rx_packet_2048_4095_bytes    = %0d", stat_vnc_rx_packet_2048_4095_bytes);
        $display("    stat_vnc_rx_packet_4096_8191_bytes    = %0d", stat_vnc_rx_packet_4096_8191_bytes);
        $display("    stat_vnc_rx_packet_8192_9215_bytes    = %0d", stat_vnc_rx_packet_8192_9215_bytes);

        $display("    stat_vnc_rx_inrangeerr                = %0d", stat_vnc_rx_inrangeerr);
        $display("    stat_vnc_rx_bad_fcs                   = %0d", stat_vnc_rx_bad_fcs);
        $display("    stat_vnc_rx_oversize                  = %0d", stat_vnc_rx_oversize);
        $display("    stat_vnc_rx_undersize                 = %0d", stat_vnc_rx_undersize);
        $display("    stat_vnc_rx_toolong                   = %0d", stat_vnc_rx_toolong);
        $display("    stat_vnc_rx_packet_small              = %0d", stat_vnc_rx_packet_small);
        $display("    stat_vnc_rx_packet_large              = %0d", stat_vnc_rx_packet_large);
        $display("    stat_vnc_rx_jabber                    = %0d", stat_vnc_rx_jabber);
        $display("    stat_vnc_rx_fragment                  = %0d", stat_vnc_rx_fragment);
        $display("    stat_vnc_rx_packet_bad_fcs            = %0d", stat_vnc_rx_packet_bad_fcs);
        $display("    stat_vnc_rx_user_pause                = %0d", stat_vnc_rx_user_pause);
        $display("    stat_vnc_rx_pause                     = %0d", stat_vnc_rx_pause);

        $display("    stat_tx_unfout                        = %0d", stat_tx_unfout);
        $display("    stat_vnc_tx_overflow                  = %0d", stat_vnc_tx_overflow);


        // Integrity checking
        if (stat_vnc_tx_total_bytes != stat_vnc_rx_total_bytes) begin
            $display ("ERROR:  stat_vnc_tx_total_bytes != stat_vnc_rx_total_bytes (%0d != %0d)", stat_vnc_tx_total_bytes, stat_vnc_rx_total_bytes);
        end
        if (stat_vnc_tx_total_good_bytes != stat_vnc_rx_total_good_bytes) begin
            $display ("ERROR:  stat_vnc_tx_total_good_bytes != stat_vnc_rx_total_good_bytes (%0d != %0d)", stat_vnc_tx_total_good_bytes, stat_vnc_rx_total_good_bytes);
        end
        if (stat_vnc_tx_total_packets != stat_vnc_rx_total_packets) begin
            $display ("ERROR:  stat_vnc_tx_total_packets !+ stat_vnc_rx_total_packets (%0d != %0d)", stat_vnc_tx_total_packets, stat_vnc_rx_total_packets);
        end
        if (stat_vnc_tx_total_good_packets != stat_vnc_rx_total_good_packets) begin
            $display ("ERROR:  stat_vnc_tx_total_good_packets != stat_vnc_rx_total_good_packets (%0d != %0d)", stat_vnc_tx_total_good_packets, stat_vnc_rx_total_good_packets);
        end
        if (stat_vnc_tx_broadcast != stat_vnc_rx_broadcast) begin
            $display ("ERROR:  stat_vnc_tx_broadcast != stat_vnc_rx_broadcast (%0d != %0d)", stat_vnc_tx_broadcast, stat_vnc_rx_broadcast);
        end
        if (stat_vnc_tx_multicast != stat_vnc_rx_multicast) begin
            $display ("ERROR:  stat_vnc_tx_multicast != stat_vnc_rx_multicast (%0d != %0d)", stat_vnc_tx_multicast, stat_vnc_rx_multicast);
        end
        if (stat_vnc_tx_unicast != stat_vnc_rx_unicast) begin
            $display ("ERROR:  stat_vnc_tx_unicast != stat_vnc_rx_unicast (%0d != %0d)", stat_vnc_tx_unicast, stat_vnc_rx_unicast);
        end
        if (stat_vnc_tx_vlan != stat_vnc_rx_vlan) begin
            $display ("ERROR:  stat_vnc_tx_vlan != stat_vnc_rx_vlan (%0d != %0d)", stat_vnc_tx_vlan, stat_vnc_rx_vlan);
        end

        if (stat_vnc_tx_broadcast + stat_vnc_tx_multicast + stat_vnc_tx_unicast != stat_vnc_tx_total_packets) begin
            $display ("ERROR:  stat_vnc_tx_broadcast + stat_vnc_tx_multicast + stat_vnc_tx_unicast != stat_vnc_tx_total_packets");
        end

        if (stat_vnc_tx_packet_64_bytes != stat_vnc_rx_packet_64_bytes) begin
            $display ("ERROR:  stat_vnc_tx_packet_64_bytes != stat_vnc_rx_packet_64_bytes (%0d != %0d)", stat_vnc_tx_packet_64_bytes, stat_vnc_rx_packet_64_bytes);
        end
        if (stat_vnc_tx_packet_65_127_bytes != stat_vnc_rx_packet_65_127_bytes) begin
            $display ("ERROR:  stat_vnc_tx_packet_65_127_bytes != stat_vnc_rx_packet_65_127_bytes (%0d != %0d)", stat_vnc_tx_packet_65_127_bytes, stat_vnc_rx_packet_65_127_bytes);
        end
        if (stat_vnc_tx_packet_128_255_bytes    != stat_vnc_rx_packet_128_255_bytes) begin
            $display ("ERROR:  stat_vnc_tx_packet_128_255_bytes != stat_vnc_rx_packet_128_255_bytes (%0d != %0d)", stat_vnc_tx_packet_128_255_bytes, stat_vnc_rx_packet_128_255_bytes);
        end
        if (stat_vnc_tx_packet_256_511_bytes    != stat_vnc_rx_packet_256_511_bytes) begin
            $display ("ERROR:  stat_vnc_tx_packet_256_511_bytes != stat_vnc_rx_packet_256_511_bytes (%0d != %0d)", stat_vnc_tx_packet_256_511_bytes, stat_vnc_rx_packet_256_511_bytes);
        end
        if (stat_vnc_tx_packet_512_1023_bytes   != stat_vnc_rx_packet_512_1023_bytes) begin
            $display ("ERROR:  stat_vnc_tx_packet_512_1023_bytes != stat_vnc_rx_packet_512_1023_bytes (%0d != %0d)", stat_vnc_tx_packet_512_1023_bytes, stat_vnc_rx_packet_512_1023_bytes);
        end
        if (stat_vnc_tx_packet_1024_1518_bytes  != stat_vnc_rx_packet_1024_1518_bytes) begin
            $display ("ERROR:  stat_vnc_tx_packet_1024_1518_bytes != stat_vnc_rx_packet_1024_1518_bytes (%0d != %0d)", stat_vnc_tx_packet_1024_1518_bytes, stat_vnc_rx_packet_1024_1518_bytes);
        end
        if (stat_vnc_tx_packet_1519_1522_bytes  != stat_vnc_rx_packet_1519_1522_bytes) begin
            $display ("ERROR:  stat_vnc_tx_packet_1519_1522_bytes != stat_vnc_rx_packet_1519_1522_bytes (%0d != %0d)", stat_vnc_tx_packet_1519_1522_bytes, stat_vnc_rx_packet_1519_1522_bytes);
        end
        if (stat_vnc_tx_packet_1523_1548_bytes  != stat_vnc_rx_packet_1523_1548_bytes) begin
            $display ("ERROR:  stat_vnc_tx_packet_1523_1548_bytes != stat_vnc_rx_packet_1523_1548_bytes (%0d != %0d)", stat_vnc_tx_packet_1523_1548_bytes, stat_vnc_rx_packet_1523_1548_bytes);
        end
        if (stat_vnc_tx_packet_1549_2047_bytes  != stat_vnc_rx_packet_1549_2047_bytes) begin
            $display ("ERROR:  stat_vnc_tx_packet_1549_2047_bytes != stat_vnc_rx_packet_1549_2047_bytes (%0d != %0d)", stat_vnc_tx_packet_1549_2047_bytes, stat_vnc_rx_packet_1549_2047_bytes);
        end
        if (stat_vnc_tx_packet_2048_4095_bytes  != stat_vnc_rx_packet_2048_4095_bytes) begin
            $display ("ERROR:  stat_vnc_tx_packet_2048_4095_bytes != stat_vnc_rx_packet_2048_4095_bytes (%0d != %0d)", stat_vnc_tx_packet_2048_4095_bytes, stat_vnc_rx_packet_2048_4095_bytes);
        end
        if (stat_vnc_tx_packet_4096_8191_bytes  != stat_vnc_rx_packet_4096_8191_bytes) begin
            $display ("ERROR:  stat_vnc_tx_packet_4096_8191_bytes != stat_vnc_rx_packet_4096_8191_bytes (%0d != %0d)", stat_vnc_tx_packet_4096_8191_bytes, stat_vnc_rx_packet_4096_8191_bytes);
        end
        if (stat_vnc_tx_packet_8192_9215_bytes  != stat_vnc_rx_packet_8192_9215_bytes) begin
            $display ("ERROR:  stat_vnc_tx_packet_8192_9215_bytes != stat_vnc_rx_packet_8192_9215_bytes (%0d != %0d)", stat_vnc_tx_packet_8192_9215_bytes, stat_vnc_rx_packet_8192_9215_bytes);
        end

        if (stat_tx_unfout || stat_vnc_tx_overflow) begin
            $display ("ERROR:  stat_tx_unfout || stat_vnc_tx_overflow");
        end

        addr = 32'h1_0500; vnc_axil_read (addr, status_rx_cycle_soft_count[31:0]);
        addr = 32'h1_0504; vnc_axil_read (addr, status_rx_cycle_soft_count[63:32]);
        addr = 32'h1_0508; vnc_axil_read (addr, status_tx_cycle_soft_count[31:0]);
        addr = 32'h1_050C; vnc_axil_read (addr, status_tx_cycle_soft_count[63:32]);
        addr = 32'h1_0648; vnc_axil_read (addr, stat_rx_framing_err_soft[31:0]);
        addr = 32'h1_064C; vnc_axil_read (addr, stat_rx_framing_err_soft[63:32]);
        addr = 32'h1_0660; vnc_axil_read (addr, stat_rx_bad_code_soft[31:0]);
        addr = 32'h1_0664; vnc_axil_read (addr, stat_rx_bad_code_soft[63:32]);
        addr = 32'h1_06A0; vnc_axil_read (addr, stat_tx_frame_error_soft[31:0]);
        addr = 32'h1_06A4; vnc_axil_read (addr, stat_tx_frame_error_soft[63:32]);
        addr = 32'h1_0700; vnc_axil_read (addr, stat_tx_total_packets_soft[31:0]);
        addr = 32'h1_0704; vnc_axil_read (addr, stat_tx_total_packets_soft[63:32]);
        addr = 32'h1_0708; vnc_axil_read (addr, stat_tx_total_good_packets_soft[31:0]);
        addr = 32'h1_070C; vnc_axil_read (addr, stat_tx_total_good_packets_soft[63:32]);
        addr = 32'h1_0710; vnc_axil_read (addr, stat_tx_total_bytes_soft[31:0]);
        addr = 32'h1_0714; vnc_axil_read (addr, stat_tx_total_bytes_soft[63:32]);
        addr = 32'h1_0718; vnc_axil_read (addr, stat_tx_total_good_bytes_soft[31:0]);
        addr = 32'h1_071C; vnc_axil_read (addr, stat_tx_total_good_bytes_soft[63:32]);
        addr = 32'h1_0720; vnc_axil_read (addr, stat_tx_packet_64_bytes_soft[31:0]);
        addr = 32'h1_0724; vnc_axil_read (addr, stat_tx_packet_64_bytes_soft[63:32]);
        addr = 32'h1_0728; vnc_axil_read (addr, stat_tx_packet_65_127_bytes_soft[31:0]);
        addr = 32'h1_072C; vnc_axil_read (addr, stat_tx_packet_65_127_bytes_soft[63:32]);
        addr = 32'h1_0730; vnc_axil_read (addr, stat_tx_packet_128_255_bytes_soft[31:0]);
        addr = 32'h1_0734; vnc_axil_read (addr, stat_tx_packet_128_255_bytes_soft[63:32]);
        addr = 32'h1_0738; vnc_axil_read (addr, stat_tx_packet_256_511_bytes_soft[31:0]);
        addr = 32'h1_073C; vnc_axil_read (addr, stat_tx_packet_256_511_bytes_soft[63:32]);
        addr = 32'h1_0740; vnc_axil_read (addr, stat_tx_packet_512_1023_bytes_soft[31:0]);
        addr = 32'h1_0744; vnc_axil_read (addr, stat_tx_packet_512_1023_bytes_soft[63:32]);
        addr = 32'h1_0748; vnc_axil_read (addr, stat_tx_packet_1024_1518_bytes_soft[31:0]);
        addr = 32'h1_074C; vnc_axil_read (addr, stat_tx_packet_1024_1518_bytes_soft[63:32]);
        addr = 32'h1_0750; vnc_axil_read (addr, stat_tx_packet_1519_1522_bytes_soft[31:0]);
        addr = 32'h1_0754; vnc_axil_read (addr, stat_tx_packet_1519_1522_bytes_soft[63:32]);
        addr = 32'h1_0758; vnc_axil_read (addr, stat_tx_packet_1523_1548_bytes_soft[31:0]);
        addr = 32'h1_075C; vnc_axil_read (addr, stat_tx_packet_1523_1548_bytes_soft[63:32]);
        addr = 32'h1_0760; vnc_axil_read (addr, stat_tx_packet_1549_2047_bytes_soft[31:0]);
        addr = 32'h1_0764; vnc_axil_read (addr, stat_tx_packet_1549_2047_bytes_soft[63:32]);
        addr = 32'h1_0768; vnc_axil_read (addr, stat_tx_packet_2048_4095_bytes_soft[31:0]);
        addr = 32'h1_076C; vnc_axil_read (addr, stat_tx_packet_2048_4095_bytes_soft[63:32]);
        addr = 32'h1_0770; vnc_axil_read (addr, stat_tx_packet_4096_8191_bytes_soft[31:0]);
        addr = 32'h1_0774; vnc_axil_read (addr, stat_tx_packet_4096_8191_bytes_soft[63:32]);
        addr = 32'h1_0778; vnc_axil_read (addr, stat_tx_packet_8192_9215_bytes_soft[31:0]);
        addr = 32'h1_077C; vnc_axil_read (addr, stat_tx_packet_8192_9215_bytes_soft[63:32]);
        addr = 32'h1_0780; vnc_axil_read (addr, stat_tx_packet_large_soft[31:0]);
        addr = 32'h1_0784; vnc_axil_read (addr, stat_tx_packet_large_soft[63:32]);
        addr = 32'h1_0788; vnc_axil_read (addr, stat_tx_packet_small_soft[31:0]);
        addr = 32'h1_078C; vnc_axil_read (addr, stat_tx_packet_small_soft[63:32]);
        addr = 32'h1_07B8; vnc_axil_read (addr, stat_tx_bad_fcs_soft[31:0]);
        addr = 32'h1_07BC; vnc_axil_read (addr, stat_tx_bad_fcs_soft[63:32]);
        addr = 32'h1_07D0; vnc_axil_read (addr, stat_tx_unicast_soft[31:0]);
        addr = 32'h1_07D4; vnc_axil_read (addr, stat_tx_unicast_soft[63:32]);
        addr = 32'h1_07D8; vnc_axil_read (addr, stat_tx_multicast_soft[31:0]);
        addr = 32'h1_07DC; vnc_axil_read (addr, stat_tx_multicast_soft[63:32]);
        addr = 32'h1_07E0; vnc_axil_read (addr, stat_tx_broadcast_soft[31:0]);
        addr = 32'h1_07E4; vnc_axil_read (addr, stat_tx_broadcast_soft[63:32]);
        addr = 32'h1_07E8; vnc_axil_read (addr, stat_tx_vlan_soft[31:0]);
        addr = 32'h1_07EC; vnc_axil_read (addr, stat_tx_vlan_soft[63:32]);

        addr = 32'h1_0808; vnc_axil_read (addr, stat_rx_total_packets_soft[31:0]);
        addr = 32'h1_080C; vnc_axil_read (addr, stat_rx_total_packets_soft[63:32]);
        addr = 32'h1_0810; vnc_axil_read (addr, stat_rx_total_good_packets_soft[31:0]);
        addr = 32'h1_0814; vnc_axil_read (addr, stat_rx_total_good_packets_soft[63:32]);
        addr = 32'h1_0818; vnc_axil_read (addr, stat_rx_total_bytes_soft[31:0]);
        addr = 32'h1_081C; vnc_axil_read (addr, stat_rx_total_bytes_soft[63:32]);
        addr = 32'h1_0820; vnc_axil_read (addr, stat_rx_total_good_bytes_soft[31:0]);
        addr = 32'h1_0824; vnc_axil_read (addr, stat_rx_total_good_bytes_soft[63:32]);
        addr = 32'h1_0828; vnc_axil_read (addr, stat_rx_packet_64_bytes_soft[31:0]);
        addr = 32'h1_082C; vnc_axil_read (addr, stat_rx_packet_64_bytes_soft[63:32]);
        addr = 32'h1_0830; vnc_axil_read (addr, stat_rx_packet_65_127_bytes_soft[31:0]);
        addr = 32'h1_0834; vnc_axil_read (addr, stat_rx_packet_65_127_bytes_soft[63:32]);
        addr = 32'h1_0838; vnc_axil_read (addr, stat_rx_packet_128_255_bytes_soft[31:0]);
        addr = 32'h1_083C; vnc_axil_read (addr, stat_rx_packet_128_255_bytes_soft[63:32]);
        addr = 32'h1_0840; vnc_axil_read (addr, stat_rx_packet_256_511_bytes_soft[31:0]);
        addr = 32'h1_0844; vnc_axil_read (addr, stat_rx_packet_256_511_bytes_soft[63:32]);
        addr = 32'h1_0848; vnc_axil_read (addr, stat_rx_packet_512_1023_bytes_soft[31:0]);
        addr = 32'h1_084C; vnc_axil_read (addr, stat_rx_packet_512_1023_bytes_soft[63:32]);
        addr = 32'h1_0850; vnc_axil_read (addr, stat_rx_packet_1024_1518_bytes_soft[31:0]);
        addr = 32'h1_0854; vnc_axil_read (addr, stat_rx_packet_1024_1518_bytes_soft[63:32]);
        addr = 32'h1_0858; vnc_axil_read (addr, stat_rx_packet_1519_1522_bytes_soft[31:0]);
        addr = 32'h1_085C; vnc_axil_read (addr, stat_rx_packet_1519_1522_bytes_soft[63:32]);
        addr = 32'h1_0860; vnc_axil_read (addr, stat_rx_packet_1523_1548_bytes_soft[31:0]);
        addr = 32'h1_0864; vnc_axil_read (addr, stat_rx_packet_1523_1548_bytes_soft[63:32]);
        addr = 32'h1_0868; vnc_axil_read (addr, stat_rx_packet_1549_2047_bytes_soft[31:0]);
        addr = 32'h1_086C; vnc_axil_read (addr, stat_rx_packet_1549_2047_bytes_soft[63:32]);
        addr = 32'h1_0870; vnc_axil_read (addr, stat_rx_packet_2048_4095_bytes_soft[31:0]);
        addr = 32'h1_0874; vnc_axil_read (addr, stat_rx_packet_2048_4095_bytes_soft[63:32]);
        addr = 32'h1_0878; vnc_axil_read (addr, stat_rx_packet_4096_8191_bytes_soft[31:0]);
        addr = 32'h1_087C; vnc_axil_read (addr, stat_rx_packet_4096_8191_bytes_soft[63:32]);
        addr = 32'h1_0880; vnc_axil_read (addr, stat_rx_packet_8192_9215_bytes_soft[31:0]);
        addr = 32'h1_0884; vnc_axil_read (addr, stat_rx_packet_8192_9215_bytes_soft[63:32]);
        addr = 32'h1_0888; vnc_axil_read (addr, stat_rx_packet_large_soft[31:0]);
        addr = 32'h1_088C; vnc_axil_read (addr, stat_rx_packet_large_soft[63:32]);
        addr = 32'h1_0890; vnc_axil_read (addr, stat_rx_packet_small_soft[31:0]);
        addr = 32'h1_0894; vnc_axil_read (addr, stat_rx_packet_small_soft[63:32]);
        addr = 32'h1_0898; vnc_axil_read (addr, stat_rx_undersize_soft[31:0]);
        addr = 32'h1_089C; vnc_axil_read (addr, stat_rx_undersize_soft[63:32]);
        addr = 32'h1_08A0; vnc_axil_read (addr, stat_rx_fragment_soft[31:0]);
        addr = 32'h1_08A4; vnc_axil_read (addr, stat_rx_fragment_soft[63:32]);
        addr = 32'h1_08A8; vnc_axil_read (addr, stat_rx_oversize_soft[31:0]);
        addr = 32'h1_08AC; vnc_axil_read (addr, stat_rx_oversize_soft[63:32]);
        addr = 32'h1_08B0; vnc_axil_read (addr, stat_rx_toolong_soft[31:0]);
        addr = 32'h1_08B4; vnc_axil_read (addr, stat_rx_toolong_soft[63:32]);
        addr = 32'h1_08B8; vnc_axil_read (addr, stat_rx_jabber_soft[31:0]);
        addr = 32'h1_08BC; vnc_axil_read (addr, stat_rx_jabber_soft[63:32]);
        addr = 32'h1_08C0; vnc_axil_read (addr, stat_rx_bad_fcs_soft[31:0]);
        addr = 32'h1_08C4; vnc_axil_read (addr, stat_rx_bad_fcs_soft[63:32]);
        addr = 32'h1_08C8; vnc_axil_read (addr, stat_rx_packet_bad_fcs_soft[31:0]);
        addr = 32'h1_08CC; vnc_axil_read (addr, stat_rx_packet_bad_fcs_soft[63:32]);
        addr = 32'h1_08D0; vnc_axil_read (addr, stat_rx_stomped_fcs_soft[31:0]);
        addr = 32'h1_08D4; vnc_axil_read (addr, stat_rx_stomped_fcs_soft[63:32]);
        addr = 32'h1_08D8; vnc_axil_read (addr, stat_rx_unicast_soft[31:0]);
        addr = 32'h1_08DC; vnc_axil_read (addr, stat_rx_unicast_soft[63:32]);
        addr = 32'h1_08E0; vnc_axil_read (addr, stat_rx_multicast_soft[31:0]);
        addr = 32'h1_08E4; vnc_axil_read (addr, stat_rx_multicast_soft[63:32]);
        addr = 32'h1_08E8; vnc_axil_read (addr, stat_rx_broadcast_soft[31:0]);
        addr = 32'h1_08EC; vnc_axil_read (addr, stat_rx_broadcast_soft[63:32]);
        addr = 32'h1_08F0; vnc_axil_read (addr, stat_rx_vlan_soft[31:0]);
        addr = 32'h1_08F4; vnc_axil_read (addr, stat_rx_vlan_soft[63:32]);
        addr = 32'h1_08F8; vnc_axil_read (addr, stat_rx_pause_soft[31:0]);
        addr = 32'h1_08FC; vnc_axil_read (addr, stat_rx_pause_soft[63:32]);
        addr = 32'h1_0900; vnc_axil_read (addr, stat_rx_user_pause_soft[31:0]);
        addr = 32'h1_0904; vnc_axil_read (addr, stat_rx_user_pause_soft[63:32]);
        addr = 32'h1_0908; vnc_axil_read (addr, stat_rx_inrangeerr_soft[31:0]);
        addr = 32'h1_090C; vnc_axil_read (addr, stat_rx_inrangeerr_soft[63:32]);
        addr = 32'h1_0910; vnc_axil_read (addr, stat_rx_truncated_soft[31:0]);
        addr = 32'h1_0914; vnc_axil_read (addr, stat_rx_truncated_soft[63:32]);
        addr = 32'h1_0918; vnc_axil_read (addr, stat_rx_test_pattern_mismatch_soft[31:0]);
        addr = 32'h1_091C; vnc_axil_read (addr, stat_rx_test_pattern_mismatch_soft[63:32]);


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

        // Integrity checking with VNC stats
        if (stat_tx_frame_error_soft != 0) begin
            $display ("ERROR: stat_tx_frame_error_soft != 0");
        end
        if (stat_tx_total_packets_soft != stat_vnc_tx_total_packets) begin
            $display ("ERROR: stat_tx_total_packets_soft != stat_vnc_tx_total_packets (%0d != %0d)",stat_tx_total_packets_soft, stat_vnc_tx_total_packets);
        end
        if (stat_tx_total_good_packets_soft != stat_vnc_tx_total_good_packets) begin
            $display ("ERROR: stat_tx_total_good_packets_soft != stat_vnc_tx_total_good_packets (%0d != %0d)",stat_tx_total_good_packets_soft, stat_vnc_tx_total_good_packets);
        end
        if (stat_tx_total_bytes_soft != stat_vnc_tx_total_bytes) begin
            $display ("ERROR: stat_tx_total_bytes_soft != stat_vnc_tx_total_bytes (%0d != %0d)",stat_tx_total_bytes_soft, stat_vnc_tx_total_bytes);
        end
        if (stat_tx_total_good_bytes_soft != stat_vnc_tx_total_good_bytes) begin
            $display ("ERROR: stat_tx_total_good_bytes_soft != stat_vnc_tx_total_good_bytes (%0d != %0d)",stat_tx_total_good_bytes_soft, stat_vnc_tx_total_good_bytes);
        end
        if (stat_tx_packet_64_bytes_soft != stat_vnc_tx_packet_64_bytes) begin
            $display ("ERROR: stat_tx_packet_64_bytes_soft != stat_vnc_tx_packet_64_bytes (%0d != %0d)",stat_tx_packet_64_bytes_soft, stat_vnc_tx_packet_64_bytes);
        end
        if (stat_tx_packet_65_127_bytes_soft != stat_vnc_tx_packet_65_127_bytes) begin
            $display ("ERROR: stat_tx_packet_65_127_bytes_soft != stat_vnc_tx_packet_65_127_bytes (%0d != %0d)",stat_tx_packet_65_127_bytes_soft, stat_vnc_tx_packet_65_127_bytes);
        end
        if (stat_tx_packet_128_255_bytes_soft != stat_vnc_tx_packet_128_255_bytes) begin
            $display ("ERROR: stat_tx_packet_128_255_bytes_soft != stat_vnc_tx_packet_128_255_bytes (%0d != %0d)",stat_tx_packet_128_255_bytes_soft, stat_vnc_tx_packet_128_255_bytes);
        end
        if (stat_tx_packet_256_511_bytes_soft != stat_vnc_tx_packet_256_511_bytes) begin
            $display ("ERROR: stat_tx_packet_256_511_bytes_soft != stat_vnc_tx_packet_256_511_bytes (%0d != %0d)",stat_tx_packet_256_511_bytes_soft, stat_vnc_tx_packet_256_511_bytes);
        end
        if (stat_tx_packet_512_1023_bytes_soft != stat_vnc_tx_packet_512_1023_bytes) begin
            $display ("ERROR: stat_tx_packet_512_1023_bytes_soft != stat_vnc_tx_packet_512_1023_bytes (%0d != %0d)",stat_tx_packet_512_1023_bytes_soft, stat_vnc_tx_packet_512_1023_bytes);
        end
        if (stat_tx_packet_1024_1518_bytes_soft != stat_vnc_tx_packet_1024_1518_bytes) begin
            $display ("ERROR: stat_tx_packet_1024_1518_bytes_soft != stat_vnc_tx_packet_1024_1518_bytes (%0d != %0d)",stat_tx_packet_1024_1518_bytes_soft, stat_vnc_tx_packet_1024_1518_bytes);
        end
        if (stat_tx_packet_1519_1522_bytes_soft != stat_vnc_tx_packet_1519_1522_bytes) begin
            $display ("ERROR: stat_tx_packet_1519_1522_bytes_soft != stat_vnc_tx_packet_1519_1522_bytes (%0d != %0d)",stat_tx_packet_1519_1522_bytes_soft, stat_vnc_tx_packet_1519_1522_bytes);
        end
        if (stat_tx_packet_1523_1548_bytes_soft != stat_vnc_tx_packet_1523_1548_bytes) begin
            $display ("ERROR: stat_tx_packet_1523_1548_bytes_soft != stat_vnc_tx_packet_1523_1548_bytes (%0d != %0d)",stat_tx_packet_1523_1548_bytes_soft, stat_vnc_tx_packet_1523_1548_bytes);
        end
        if (stat_tx_packet_1549_2047_bytes_soft != stat_vnc_tx_packet_1549_2047_bytes) begin
            $display ("ERROR: stat_tx_packet_1549_2047_bytes_soft != stat_vnc_tx_packet_1549_2047_bytes (%0d != %0d)",stat_tx_packet_1549_2047_bytes_soft, stat_vnc_tx_packet_1549_2047_bytes);
        end
        if (stat_tx_packet_2048_4095_bytes_soft != stat_vnc_tx_packet_2048_4095_bytes) begin
            $display ("ERROR: stat_tx_packet_2048_4095_bytes_soft != stat_vnc_tx_packet_2048_4095_bytes (%0d != %0d)",stat_tx_packet_2048_4095_bytes_soft, stat_vnc_tx_packet_2048_4095_bytes);
        end
        if (stat_tx_packet_4096_8191_bytes_soft != stat_vnc_tx_packet_4096_8191_bytes) begin
            $display ("ERROR: stat_tx_packet_4096_8191_bytes_soft != stat_vnc_tx_packet_4096_8191_bytes (%0d != %0d)",stat_tx_packet_4096_8191_bytes_soft, stat_vnc_tx_packet_4096_8191_bytes);
        end
        if (stat_tx_packet_8192_9215_bytes_soft != stat_vnc_tx_packet_8192_9215_bytes) begin
            $display ("ERROR: stat_tx_packet_8192_9215_bytes_soft != stat_vnc_tx_packet_8192_9215_bytes (%0d != %0d)",stat_tx_packet_8192_9215_bytes_soft, stat_vnc_tx_packet_8192_9215_bytes);
        end
        if (stat_tx_packet_large_soft != stat_vnc_tx_packet_large) begin
            $display ("ERROR: stat_tx_packet_large_soft != stat_vnc_tx_packet_large (%0d != %0d)",stat_tx_packet_large_soft, stat_vnc_tx_packet_large);
        end
        if (stat_tx_packet_small_soft != stat_vnc_tx_packet_small) begin
            $display ("ERROR: stat_tx_packet_small_soft != stat_vnc_tx_packet_small (%0d != %0d)",stat_tx_packet_small_soft, stat_vnc_tx_packet_small);
        end
        if (stat_tx_bad_fcs_soft != 0) begin
            $display ("ERROR: stat_tx_bad_fcs_soft != 0 (%0d != %0d)",stat_tx_bad_fcs_soft, 0);
        end
        if (stat_tx_unicast_soft != stat_vnc_tx_unicast) begin
            $display ("ERROR: stat_tx_unicast_soft != stat_vnc_tx_unicast (%0d != %0d)",stat_tx_unicast_soft, stat_vnc_tx_unicast);
        end
        if (stat_tx_multicast_soft != stat_vnc_tx_multicast) begin
            $display ("ERROR: stat_tx_multicast_soft != stat_vnc_tx_multicast (%0d != %0d)",stat_tx_multicast_soft, stat_vnc_tx_multicast);
        end
        if (stat_tx_broadcast_soft != stat_vnc_tx_broadcast) begin
            $display ("ERROR: stat_tx_broadcast_soft != stat_vnc_tx_broadcast (%0d != %0d)",stat_tx_broadcast_soft, stat_vnc_tx_broadcast);
        end
        if (stat_tx_vlan_soft != stat_vnc_tx_vlan) begin
            $display ("ERROR: stat_tx_vlan_soft != stat_vnc_tx_vlan (%0d != %0d)",stat_tx_vlan_soft, stat_vnc_tx_vlan);
        end

        if (stat_rx_framing_err_soft != 0) begin
            $display ("ERROR: stat_rx_framing_err_soft != 0 (%0d != %0d)",stat_rx_framing_err_soft, 0);
        end
        if (stat_rx_bad_code_soft != 0) begin
            $display ("ERROR: stat_rx_bad_code_soft != 0 (%0d != %0d)",stat_rx_bad_code_soft, 0);
        end
        if (stat_rx_total_packets_soft != stat_vnc_rx_total_packets) begin
            $display ("ERROR: stat_rx_total_packets_soft != stat_vnc_rx_total_packets (%0d != %0d)",stat_rx_total_packets_soft, stat_vnc_rx_total_packets);
        end
        if (stat_rx_total_good_packets_soft != stat_vnc_rx_total_good_packets) begin
            $display ("ERROR: stat_rx_total_good_packets_soft != stat_vnc_rx_total_good_packets (%0d != %0d)",stat_rx_total_good_packets_soft, stat_vnc_rx_total_good_packets);
        end
        if (stat_rx_total_bytes_soft != stat_vnc_rx_total_bytes) begin
            $display ("ERROR: stat_rx_total_bytes_soft != stat_vnc_rx_total_bytes (%0d != %0d)",stat_rx_total_bytes_soft, stat_vnc_rx_total_bytes);
        end
        if (stat_rx_total_good_bytes_soft != stat_vnc_rx_total_good_bytes) begin
            $display ("ERROR: stat_rx_total_good_bytes_soft != stat_vnc_rx_total_good_bytes (%0d != %0d)",stat_rx_total_good_bytes_soft, stat_vnc_rx_total_good_bytes);
        end
        if (stat_rx_packet_64_bytes_soft != stat_vnc_rx_packet_64_bytes) begin
            $display ("ERROR: stat_rx_packet_64_bytes_soft != stat_vnc_rx_packet_64_bytes (%0d != %0d)",stat_rx_packet_64_bytes_soft, stat_vnc_rx_packet_64_bytes);
        end
        if (stat_rx_packet_65_127_bytes_soft != stat_vnc_rx_packet_65_127_bytes) begin
            $display ("ERROR: stat_rx_packet_65_127_bytes_soft != stat_vnc_rx_packet_65_127_bytes (%0d != %0d)",stat_rx_packet_65_127_bytes_soft, stat_vnc_rx_packet_65_127_bytes);
        end
        if (stat_rx_packet_128_255_bytes_soft != stat_vnc_rx_packet_128_255_bytes) begin
            $display ("ERROR: stat_rx_packet_128_255_bytes_soft != stat_vnc_rx_packet_128_255_bytes (%0d != %0d)",stat_rx_packet_128_255_bytes_soft, stat_vnc_rx_packet_128_255_bytes);
        end
        if (stat_rx_packet_256_511_bytes_soft != stat_vnc_rx_packet_256_511_bytes) begin
            $display ("ERROR: stat_rx_packet_256_511_bytes_soft != stat_vnc_rx_packet_256_511_bytes (%0d != %0d)",stat_rx_packet_256_511_bytes_soft, stat_vnc_rx_packet_256_511_bytes);
        end
        if (stat_rx_packet_512_1023_bytes_soft != stat_vnc_rx_packet_512_1023_bytes) begin
            $display ("ERROR: stat_rx_packet_512_1023_bytes_soft != stat_vnc_rx_packet_512_1023_bytes (%0d != %0d)",stat_rx_packet_512_1023_bytes_soft, stat_vnc_rx_packet_512_1023_bytes);
        end
        if (stat_rx_packet_1024_1518_bytes_soft != stat_vnc_rx_packet_1024_1518_bytes) begin
            $display ("ERROR: stat_rx_packet_1024_1518_bytes_soft != stat_vnc_rx_packet_1024_1518_bytes (%0d != %0d)",stat_rx_packet_1024_1518_bytes_soft, stat_vnc_rx_packet_1024_1518_bytes);
        end
        if (stat_rx_packet_1519_1522_bytes_soft != stat_vnc_rx_packet_1519_1522_bytes) begin
            $display ("ERROR: stat_rx_packet_1519_1522_bytes_soft != stat_vnc_rx_packet_1519_1522_bytes (%0d != %0d)",stat_rx_packet_1519_1522_bytes_soft, stat_vnc_rx_packet_1519_1522_bytes);
        end
        if (stat_rx_packet_1523_1548_bytes_soft != stat_vnc_rx_packet_1523_1548_bytes) begin
            $display ("ERROR: stat_rx_packet_1523_1548_bytes_soft != stat_vnc_rx_packet_1523_1548_bytes (%0d != %0d)",stat_rx_packet_1523_1548_bytes_soft, stat_vnc_rx_packet_1523_1548_bytes);
        end
        if (stat_rx_packet_1549_2047_bytes_soft != stat_vnc_rx_packet_1549_2047_bytes) begin
            $display ("ERROR: stat_rx_packet_1549_2047_bytes_soft != stat_vnc_rx_packet_1549_2047_bytes (%0d != %0d)",stat_rx_packet_1549_2047_bytes_soft, stat_vnc_rx_packet_1549_2047_bytes);
        end
        if (stat_rx_packet_2048_4095_bytes_soft != stat_vnc_rx_packet_2048_4095_bytes) begin
            $display ("ERROR: stat_rx_packet_2048_4095_bytes_soft != stat_vnc_rx_packet_2048_4095_bytes (%0d != %0d)",stat_rx_packet_2048_4095_bytes_soft, stat_vnc_rx_packet_2048_4095_bytes);
        end
        if (stat_rx_packet_4096_8191_bytes_soft != stat_vnc_rx_packet_4096_8191_bytes) begin
            $display ("ERROR: stat_rx_packet_4096_8191_bytes_soft != stat_vnc_rx_packet_4096_8191_bytes (%0d != %0d)",stat_rx_packet_4096_8191_bytes_soft, stat_vnc_rx_packet_4096_8191_bytes);
        end
        if (stat_rx_packet_8192_9215_bytes_soft != stat_vnc_rx_packet_8192_9215_bytes) begin
            $display ("ERROR: stat_rx_packet_8192_9215_bytes_soft != stat_vnc_rx_packet_8192_9215_bytes (%0d != %0d)",stat_rx_packet_8192_9215_bytes_soft, stat_vnc_rx_packet_8192_9215_bytes);
        end
        if (stat_rx_packet_large_soft != stat_vnc_rx_oversize) begin
            $display ("ERROR: stat_rx_packet_large_soft != stat_vnc_rx_oversize (%0d != %0d)",stat_rx_packet_large_soft, stat_vnc_rx_oversize);
        end
        if (stat_rx_packet_small_soft != stat_vnc_rx_undersize) begin
            $display ("ERROR: stat_rx_packet_small_soft != stat_vnc_rx_undersize (%0d != %0d)",stat_rx_packet_small_soft, stat_vnc_rx_undersize);
        end
        if (stat_rx_undersize_soft != stat_vnc_rx_undersize) begin
            $display ("ERROR: stat_rx_undersize_soft != stat_vnc_rx_undersize (%0d != %0d)",stat_rx_undersize_soft, stat_vnc_rx_undersize);
        end
        if (stat_rx_fragment_soft != stat_vnc_rx_fragment) begin
            $display ("ERROR: stat_rx_fragment_soft != stat_vnc_rx_fragment (%0d != %0d)",stat_rx_fragment_soft, stat_vnc_rx_fragment);
        end
        if (stat_rx_oversize_soft != stat_vnc_rx_oversize) begin
            $display ("ERROR: stat_rx_oversize_soft != stat_vnc_rx_oversize (%0d != %0d)",stat_rx_oversize_soft, stat_vnc_rx_oversize);
        end
        if (stat_rx_toolong_soft != stat_vnc_rx_toolong) begin
            $display ("ERROR: stat_rx_toolong_soft != stat_vnc_rx_toolong (%0d != %0d)",stat_rx_toolong_soft, stat_vnc_rx_toolong);
        end
        if (stat_rx_jabber_soft != stat_vnc_rx_jabber) begin
            $display ("ERROR: stat_rx_jabber_soft != stat_vnc_rx_jabber (%0d != %0d)",stat_rx_jabber_soft, stat_vnc_rx_jabber);
        end
        if (stat_rx_bad_fcs_soft != stat_vnc_rx_bad_fcs) begin
            $display ("ERROR: stat_rx_bad_fcs_soft != stat_vnc_rx_bad_fcs (%0d != %0d)",stat_rx_bad_fcs_soft, stat_vnc_rx_bad_fcs);
        end
        if (stat_rx_packet_bad_fcs_soft != stat_vnc_rx_bad_fcs) begin
            $display ("ERROR: stat_rx_packet_bad_fcs_soft != stat_vnc_rx_bad_fcs (%0d != %0d)",stat_rx_packet_bad_fcs_soft, stat_vnc_rx_bad_fcs);
        end
        if (stat_rx_unicast_soft != stat_vnc_rx_unicast) begin
            $display ("ERROR: stat_rx_unicast_soft != stat_vnc_rx_unicast (%0d != %0d)",stat_rx_unicast_soft, stat_vnc_rx_unicast);
        end
        if (stat_rx_multicast_soft != stat_vnc_rx_multicast) begin
            $display ("ERROR: stat_rx_multicast_soft != stat_vnc_rx_multicast (%0d != %0d)",stat_rx_multicast_soft, stat_vnc_rx_multicast);
        end
        if (stat_rx_broadcast_soft != stat_vnc_rx_broadcast) begin
            $display ("ERROR: stat_rx_broadcast_soft != stat_vnc_rx_broadcast (%0d != %0d)",stat_rx_broadcast_soft, stat_vnc_rx_broadcast);
        end
        if (stat_rx_vlan_soft != stat_vnc_rx_vlan) begin
            $display ("ERROR: stat_rx_vlan_soft != stat_vnc_rx_vlan (%0d != %0d)",stat_rx_vlan_soft, stat_vnc_rx_vlan);
        end
        if (stat_rx_pause_soft != stat_vnc_rx_pause) begin
            $display ("ERROR: stat_rx_pause_soft != stat_vnc_rx_pause (%0d != %0d)",stat_rx_pause_soft, stat_vnc_rx_pause);
        end
        if (stat_rx_user_pause_soft != stat_vnc_rx_user_pause) begin
            $display ("ERROR: stat_rx_user_pause_soft != stat_vnc_rx_user_pause (%0d != %0d)",stat_rx_user_pause_soft, stat_vnc_rx_user_pause);
        end
        if (stat_rx_inrangeerr_soft != stat_vnc_rx_inrangeerr) begin
            $display ("ERROR: stat_rx_inrangeerr_soft != stat_vnc_rx_inrangeerr (%0d != %0d)",stat_rx_inrangeerr_soft, stat_vnc_rx_inrangeerr);
        end
`endif

        //if (stat_rx_stomped_fcs_soft != XX) begin
        //end
        //if (stat_rx_truncated_soft != XX) begin
        //end
        //if (stat_rx_test_pattern_mismatch_soft != XX) begin
        //end

        $finish;

    end



    /////////////////////////////////////////////////////////////////////////////////////////////
    // DUT 
    /////////////////////////////////////////////////////////////////////////////////////////////

    gtfmac_vnc_top # (
        .SIMULATION         ("true"),
        .ONE_SECOND_COUNT   (28'h1000)  // for simulation purposes
    ) 
    u_exdes_top (

/*
        .axi_aclk                           (axi_aclk),                         // input   wire                
        .axi_aresetn                        (axi_aresetn),                      // input   wire                
                                                                            
        .s_axil_araddr                      (s_axil_araddr),                  // input   wire    [31:0]      
        .s_axil_arvalid                     (s_axil_arvalid),                 // input   wire                
        .s_axil_arready                     (s_axil_arready),                 // output  wire                
        .s_axil_rdata                       (s_axil_rdata),                   // output  wire    [31:0]      
        .s_axil_rresp                       (s_axil_rresp),                   // output  wire    [1:0]       
        .s_axil_rvalid                      (s_axil_rvalid),                  // output  wire                
        .s_axil_rready                      (s_axil_rready),                  // input   wire                
        .s_axil_awaddr                      (s_axil_awaddr),                  // input   wire    [31:0]      
        .s_axil_awvalid                     (s_axil_awvalid),                 // input   wire                
        .s_axil_awready                     (s_axil_awready),                 // output  wire                
        .s_axil_wdata                       (s_axil_wdata),                   // input   wire    [31:0]      
        .s_axil_wvalid                      (s_axil_wvalid),                  // input   wire                
        .s_axil_wready                      (s_axil_wready),                  // output  wire                
        .s_axil_bvalid                      (s_axil_bvalid),                  // output  wire                
        .s_axil_bresp                       (s_axil_bresp),                   // output  wire    [1:0]       
        .s_axil_bready                      (s_axil_bready),                  // input   wire                
*/

        // exdes IOs
        .gtf_ch_gtftxn                      (gtf_ch_gtftxn),                         // output  wire                
        .gtf_ch_gtftxp                      (gtf_ch_gtftxp),                         // output  wire                
        .gtf_ch_gtfrxn                      (gtf_ch_gtftxn),                         // input   wire                
        .gtf_ch_gtfrxp                      (gtf_ch_gtftxp),                         // input   wire                
                                                                            
        .refclk_p                           (refclk),                           // input   wire                
        .refclk_n                           (~refclk),                          // input   wire                

        .hb_gtwiz_reset_clk_freerun_p_in    (freerun_clk),                      // input   wire                
        .hb_gtwiz_reset_clk_freerun_n_in    (~freerun_clk)                      // input   wire     
                                                                            
    );

    assign gtfmac_vnc_top.hb_gtwiz_reset_all_in      = hb_gtwiz_reset_all_in  ;
    assign gtfmac_vnc_top.link_down_latched_reset_in = link_down_latched_reset;
    assign link_status             = gtfmac_vnc_top.link_status_out            ;
    assign link_down_latched       = gtfmac_vnc_top.link_down_latched_out      ;

    /////////////////////////////////////////////////////////////////////////////////////////////
    // TASKS
    /////////////////////////////////////////////////////////////////////////////////////////////

    task vnc_axil_read;

        input  [31:0] rd_addr;
        output [31:0] rd_data;

        begin

            logic   [31:0]  result;

            @ (negedge axi_aclk);

            s_axi_rd_busy = 1'b1;
        
            // The Master puts an address on the Read Address channel as well as asserting ARVALID,
            // indicating the address is valid, and RREADY, indicating the master is ready to receive data from the slave.
            s_axil_araddr     = rd_addr;
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

    task vnc_axil_write;
    
        input [31:0] wr_addr;
        input [31:0] wr_data;

        begin


            // The Master puts an address on the Write Address channel and data on the Write data channel. 
            // At the same time it asserts AWVALID and WVALID indicating the address and data on the respective 
            // channels is valid. BREADY is also asserted by the Master, indicating it is ready to receive a response.

            @ (negedge axi_aclk);

            s_axi_wr_busy     = 1'b1;
    
            s_axil_awaddr     = wr_addr;
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
                    // (in this case the response is 2’b00, that being ‘OKAY’).
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

    always@(posedge gtfwizard_0_example_top_sim.u_exdes_top.clk_wiz_0_inst.clk_in1_p)
    begin
        time_samp[0] <= time_samp[1];
        time_samp[1] <= $realtime;
    end

    always@(posedge gtfwizard_0_example_top_sim.u_exdes_top.clk_wiz_0_inst.clk_out1)
    begin
        time_samp[2] <= time_samp[3];
        time_samp[3] <= $realtime;
    end

    always@(posedge gtfwizard_0_example_top_sim.u_exdes_top.clk_wiz_0_inst.clk_out2)
    begin
        time_samp[4] <= time_samp[5];
        time_samp[5] <= $realtime;
    end

    always@(posedge gtfwizard_0_example_top_sim.u_exdes_top.i_gtfmac.tx_axis_clk)
    begin
        time_samp[6] <= time_samp[7];
        time_samp[7] <= $realtime;
    end

    always@(posedge gtfwizard_0_example_top_sim.u_exdes_top.i_gtfmac.rx_axis_clk)
    begin
        time_samp[8] <= time_samp[9];
        time_samp[9] <= $realtime;
        
        time_samp[10] <= $realtime - time_samp[7];
    end

endmodule
