/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

`timescale 1ps/1ps

`include "gtfraw_vnc_top.vh"

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
      #125000
      forever
      begin
        // 333 Mhz...
        freerun_clk = #1666  ~freerun_clk;
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

    // MAC stats
    reg     [63:0]      status_rx_cycle_soft_count;
    reg     [63:0]      status_tx_cycle_soft_count;


    reg [31:0]  frames_received;
    bit         timed_out = '0;

    initial begin

        frames_received = 0;

        forever begin
            //wait (gtfwizard_0_example_top_sim.u_exdes_top.i_gtfraw_vnc_core.i_rx_mon.i_rx_mon_stat.i_stat_total_packets.incr === 1);
            //wait (gtfwizard_0_example_top_sim.u_exdes_top.i_gtfraw_vnc_core.i_rx_mon.i_rx_mon_stat.i_stat_total_packets.incr === 0);
            wait (gtfwizard_0_example_top_sim.u_exdes_top.i_gtfraw_vnc_core.i_rx_mon.tick_r === 1);
            wait (gtfwizard_0_example_top_sim.u_exdes_top.i_gtfraw_vnc_core.i_rx_mon.tick_r === 0);
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

        force   gtfraw_vnc_top.jtag_axil_awaddr  = s_axil_awaddr;
        force   gtfraw_vnc_top.jtag_axil_awprot  = s_axil_awprot;
        force   gtfraw_vnc_top.jtag_axil_awvalid = s_axil_awvalid;
        force   gtfraw_vnc_top.jtag_axil_wdata   = s_axil_wdata;
        force   gtfraw_vnc_top.jtag_axil_wstrb   = s_axil_wstrb;
        force   gtfraw_vnc_top.jtag_axil_wvalid  = s_axil_wvalid;
        force   gtfraw_vnc_top.jtag_axil_bready  = s_axil_bready;
        force   gtfraw_vnc_top.jtag_axil_araddr  = s_axil_araddr;
        force   gtfraw_vnc_top.jtag_axil_arprot  = s_axil_arprot;
        force   gtfraw_vnc_top.jtag_axil_arvalid = s_axil_arvalid;
        force   gtfraw_vnc_top.jtag_axil_rready  = s_axil_rready;

        force   axi_aclk                         = gtfraw_vnc_top.axi_aclk;
        force   axi_aresetn                      = gtfraw_vnc_top.axi_aresetn;
 
        force   s_axil_arready                   = gtfraw_vnc_top.jtag_axil_arready;
        force   s_axil_rdata                     = gtfraw_vnc_top.jtag_axil_rdata;
        force   s_axil_rresp                     = gtfraw_vnc_top.jtag_axil_rresp;
        force   s_axil_rvalid                    = gtfraw_vnc_top.jtag_axil_rvalid;
        force   s_axil_awready                   = gtfraw_vnc_top.jtag_axil_awready;
        force   s_axil_wready                    = gtfraw_vnc_top.jtag_axil_wready;
        force   s_axil_bvalid                    = gtfraw_vnc_top.jtag_axil_bvalid;
        force   s_axil_bresp                     = gtfraw_vnc_top.jtag_axil_bresp;

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
        
        $display("%t Observed gtfraw status = %0x", $time, data);

        if (attempts >= 100000) begin
            $display("%t ERROR - DUT did not come out of reset", $time);
            $finish;
        end

        $display("%t Report userrdy to the GTF", $time);
        addr    = 32'hC;
        data    = 32'h3;
        vnc_axil_write  (addr, data);

        $display("%t Configure near-end loopback", $time);
        addr    = 32'h1_0408;
        vnc_axil_read (addr, data);
        data[6:4] = 3'b010;
        vnc_axil_write  (addr, data);

        $display("%t Reset the RX side of the GT", $time);
        addr    = 32'h1_0400;
        data    = 32'h2;
        vnc_axil_write  (addr, data);

        addr    = 32'h1_0400;
        data    = 32'h0;
        vnc_axil_write  (addr, data);

        $display("%t GTFRAW: Collect MODE_REG", $time);
        addr    = 32'h1_0000;
        vnc_axil_read (addr, data);
        ctl_rx_data_rate = data[0];
        ctl_tx_data_rate = data[1];
        $display("%t         ctl_rx_data_rate=%0x", $time, ctl_rx_data_rate);
        $display("%t         ctl_tx_data_rate=%0x", $time, ctl_tx_data_rate);

        if (ctl_rx_data_rate == 1'b1) begin
            VNC_LATENCY_CLK_PERIOD_NS = 2.4824;  // 402.5 MHz
        end
        else begin
            VNC_LATENCY_CLK_PERIOD_NS = 1.5515;  // 644 MHz
        end

        $display("%t VNC:    Set up the TX/RX data rate to match", $time);
        addr    = 32'h10;
        vnc_axil_read (addr, data);
        data    = data | (ctl_tx_data_rate << 0);
        data    = data | (ctl_rx_data_rate << 16);
        $display("%t         VNC config=%0x", $time, data);
        vnc_axil_write  (addr, data);

        $display("%t Allow MAC side of the GTFRAW to bitslip", $time);
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
        do begin
            repeat (1000) @(negedge axi_aclk);
        end
        while ( link_stable == 'h0 );

        attempts = 0;
        do begin
            
            vnc_axil_read (32'h0, data);
            data     = data & (4'hF << 8);
            attempts += 1;

        end
        while (!(data == 32'h0) && attempts < 10_000 );

        $display("%t After %0d attempts, observed gtfraw status = %0x", $time, attempts, data);

        if (attempts >= 200) begin
            $display("%t ERROR - link down", $time);
            $finish;
        end
        else begin
            $display("%t LINK UP", $time);
        end

        $display("%t GTFRAW: Configure CONFIGURATION_TX_REG1", $time);
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

        $display("%t GTFRAW: Configure CONFIGURATION_RX_REG1", $time);
        $display("%t         ctl_rx_ignore_fcs=%0x", $time, ctl_rx_ignore_fcs);
        $display("%t         ctl_rx_custom_preamble_enable=%0x", $time, ctl_rx_custom_preamble_enable);
        addr    = 32'h1_0008;
        vnc_axil_read (addr, data);
        data[2]     = ctl_rx_ignore_fcs;
        data[6]     = ctl_rx_custom_preamble_enable;
        vnc_axil_write  (addr, data);

        $display("%t GTFRAW: Configure CONFIGURATION_RX_MTU1", $time);
        $display("%t         ctl_rx_min_packet_len=%0x", $time, ctl_rx_min_packet_len);
        addr    = 32'h1_000c;
        vnc_axil_read (addr, data);
        data    = ctl_rx_min_packet_len;
        vnc_axil_write  (addr, data);

        $display("%t GTFRAW: Configure CONFIGURATION_RX_MTU2", $time);
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

        $display("%t Tick the GTFRAW stats to initialize them.", $time);
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

        $display("%t Tick the GTFRAW stats to initialize them.", $time);
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
                                lat = rcv_time - snd_time - 5;
                            end
                            else begin
                                lat = 65535 - snd_time + rcv_time - 5;
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

        $display("%t Tick the GTFRAW stats for collection", $time);
        addr    = 32'h1_0000 | 32'h40C;
        data    = 32'h1;
        vnc_axil_write  (addr, data);

        // env.wait_tc_clk(50);
        repeat (50) @(negedge axi_aclk);

        $display("%0t Latency calculation:  %0d/%0.2f/%0d ticks (%0d records).  %0.2f ns/%0.2f ns/%0.2f ns", $time, lat_min, lat_total/lat_cnt, lat_max, lat_cnt, 
                                                                                                                    lat_min*VNC_LATENCY_CLK_PERIOD_NS, lat_total/lat_cnt*VNC_LATENCY_CLK_PERIOD_NS, lat_max*VNC_LATENCY_CLK_PERIOD_NS
                );

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

    gtfraw_vnc_top # (
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

    assign gtfraw_vnc_top.hb_gtwiz_reset_all_in      = hb_gtwiz_reset_all_in  ;
    assign gtfraw_vnc_top.link_down_latched_reset_in = link_down_latched_reset;
    assign link_status             = gtfraw_vnc_top.link_status_out            ;
    assign link_down_latched       = gtfraw_vnc_top.link_down_latched_out      ;


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

    always@(posedge gtfwizard_0_example_top_sim.u_exdes_top.i_gtfraw.tx_axis_clk)
    begin
        time_samp[6] <= time_samp[7];
        time_samp[7] <= $realtime;
    end

    always@(posedge gtfwizard_0_example_top_sim.u_exdes_top.i_gtfraw.rx_axis_clk)
    begin
        time_samp[8] <= time_samp[9];
        time_samp[9] <= $realtime;
        
        time_samp[10] <= $realtime - time_samp[7];
    end

endmodule
