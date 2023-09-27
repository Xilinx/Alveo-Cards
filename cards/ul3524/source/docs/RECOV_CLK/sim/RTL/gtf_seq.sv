/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------


//`timescale 1ps/1ps
//module gtfwizard_0_gtfmac_ex_sim ();

   parameter integer NUM_CHANNEL = 1; 

    // ----------------------------------------------------
    
    reg SYNCE_CLK_LVDS_P;

    initial
    begin
      SYNCE_CLK_LVDS_P = 0;
      forever
      begin
        SYNCE_CLK_LVDS_P = #3103  ~SYNCE_CLK_LVDS_P;
      end
    end

    // ----------------------------------------------------

    wire [3:0] gtf_ch_gtftxn_0 ;
    wire [3:0] gtf_ch_gtftxp_0 ;
    wire [3:0] gtf_ch_gtfrxn_0 ;
    wire [3:0] gtf_ch_gtfrxp_0 ;
    
    wire [3:0] gtf_ch_gtftxn_1 ;
    wire [3:0] gtf_ch_gtftxp_1 ;
    wire [3:0] gtf_ch_gtfrxn_1 ;
    wire [3:0] gtf_ch_gtfrxp_1 ;


    /////////////////////////////////////////////////////////////////////////////////////////////
    //  HWCHK Test 
    /////////////////////////////////////////////////////////////////////////////////////////////

    int       frames_received_0;
    bit [0:0] frame_gen_ready;
    bit [0:0] frame_stat_ready;

    reg     [31:0]      addr;
    reg     [31:0]      addr_offset;
    reg     [31:0]      data;

    initial begin
      fork
       begin
        frames_received_0 = 0;

        //forever begin
        //    //wait (gtfwizard_0_gtfmac_ex_sim.u_gtfwizard_0_example_gtfmac_top.gtfmac_hwchk_core_gen[0].i_gtfmac_hwchk_core.i_rx_mon.stat_total_packets_incr === 1);
        //    //wait (gtfwizard_0_gtfmac_ex_sim.u_gtfwizard_0_example_gtfmac_top.gtfmac_hwchk_core_gen[0].i_gtfmac_hwchk_core.i_rx_mon.stat_total_packets_incr === 0);
        //    //wait (sim_tb.clk_recov.gtf_top.u_gtfwizard_0_example_gtfmac_top.gtfmac_hwchk_core_gen[0].i_gtfmac_hwchk_core.i_rx_mon.stat_total_packets_incr === 1);
        //    //wait (sim_tb.clk_recov.gtf_top.u_gtfwizard_0_example_gtfmac_top.gtfmac_hwchk_core_gen[0].i_gtfmac_hwchk_core.i_rx_mon.stat_total_packets_incr === 0);
        //    //frames_received_0 = frames_received_0 + 1;
        //    //$display("%t Received frame %0d for channel-0", $time, frames_received_0);
        //end
       end
  
      join

    end
 
    initial begin
      fork
        begin
            // Release GTF Reset...
            hwchk_axil_write  ('h0, 'h0010, 'h1);
            repeat (1000) @(negedge axi_aclk);

            //$display("%t Start QSFP I2C", $time);
            //addr_offset = 32'h5_0000;
            //addr        = 32'h0014;
            //data        = 32'h0000_00FF;
            //hwchk_axil_write  (addr_offset, addr, data);

            $display("%t # ", $time);
            $display("%t # Starting Init", $time);
            $display("%t # ", $time);
            init_channel( 0, 32'h10_0000); 
            init_channel( 1, 32'h12_0000); 
            init_channel( 2, 32'h14_0000); 
            init_channel( 3, 32'h16_0000);
            
            $display("%t # ", $time);
            $display("%t # Started Link", $time);
            $display("%t # ", $time);
            link_channel( 0, 32'h10_0000); 
            link_channel( 1, 32'h12_0000); 
            link_channel( 2, 32'h14_0000); 
            link_channel( 3, 32'h16_0000); 

            $display("%t # ", $time);
            $display("%t # lets go...", $time);
            $display("%t # ", $time);
            run_channel();
            
            $display("%t # ", $time);
            $display("%t # Ready...", $time);
            $display("%t # ", $time);
            
            // Channel, Offset, frames received
            //hwchk_test ( 0, 32'h10_0000, frames_received_0);
            //hwchk_test ( 1, 32'h12_0000, frames_received_0);
            //hwchk_test ( 2, 32'h14_0000, frames_received_0);
            //hwchk_test ( 3, 32'h16_0000, frames_received_0);
            //hwchk_test ( 0, 32'h00_0000, frames_received_0);
        end
  
      join
        $finish;
    end



    /////////////////////////////////////////////////////////////////////////////////////////////
    //  HWCHK Test 
    /////////////////////////////////////////////////////////////////////////////////////////////


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


    bit                 timed_out;// = '0;

//    initial begin
    ctl_tx_start_framing_enable     = 1'b0; 
    ctl_tx_fcs_ins_enable           = 1'b1;
    ctl_tx_ignore_fcs               = 1'b0;
    ctl_rx_ignore_fcs               = 1'b0;
    ctl_tx_custom_preamble_enable   = 1'b0;
    ctl_rx_custom_preamble_enable   = 1'b0;
    ctl_frm_gen_mode                = 1'b0; // 0=random, 1=incr. pattern
    ctl_tx_variable_ipg             = 1'b0;
    ctl_rx_min_packet_len           = 14'd64;
    ctl_rx_max_packet_len           = 14'd1500;
    frames_to_send                  = 32'd50;//32'd400;
    frames_to_send                  = 32'd10;//32'd400;
    ctl_rx_check_preamble           = 1'b0; 
    ctl_hwchk_tx_err_inj            = 1'b0; 
    ctl_hwchk_tx_poison_inj         = 1'b0; 
    ctl_tx_ipg                      = 4'd8;			
    timed_out                       = 0;


    // Our testcase:
    //  - wait for the HWCHK to detect block block
    //  - align bitslip
    //  - init stats
    //  - send traffic
    //  - collect stats
    //  - compare TX and RX stats

    //    initial begin

        hwchk_axil_write  ('h0, 'h10, 'h1);


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

        //'h0408 : begin  // MODE_SOFT_REG
        //           tick_reg_mode_sel_r <= Bus2IP_Data_reg[0];
        //           ctl_local_loopback_r <= Bus2IP_Data_reg[6:4];
        //         end
                        
        //$display("%t Configure near-end loopback", $time);
        //addr    = 32'h1_0408;
        //hwchk_axil_read (addr_offset,addr, data);
        //data      = 32'h0;
        //data[6:4] = 3'b010;
        //data[0]   = 1'b1;
        //hwchk_axil_write  (addr_offset,addr, data);

        //$display("%t Configure far-end loopback", $time);
        //addr    = 32'h1_0408;
        //hwchk_axil_read (addr_offset,addr, data);
        //data[6:4] = 3'b100;
        //hwchk_axil_write  (addr_offset,addr, data);

        $display("%t Configure Normal Operation", $time);
        addr    = 32'h1_0408;
        hwchk_axil_read (addr_offset,addr, data);
        data      = 32'h0;
        data[6:4] = 3'b000;
        data[0]   = 1'b1;
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

                        $display("%t disable fram gen", $time);
                        // Disable the frame generator
                        addr    = 32'h20;
                        data    = 0;
                        data    = data | (1'b0 << 0); // gen_en
                        hwchk_axil_write  (addr_offset,addr, data);

                        $display("%t flush", $time);
                        // Flush pipeline
                        repeat (5000) @(negedge axi_aclk);
                    end

                    /*
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
                    */
                end
                while (!stopping);
                $display("%t thread 1 finished", $time);
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
                $display("%t thread 2 finished", $time);
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


  end
      
// join
  endtask



task automatic init_channel(int channel, reg [31:0] offset); 
begin

    reg     [31:0]      addr_offset;// = 32'h0_0000;
    real    HWCHK_LATENCY_CLK_PERIOD_NS;   // Set based on the configured data rate
    
    // device config
    logic        ctl_tx_data_rate;
    logic        ctl_rx_data_rate;
    logic        ctl_tx_start_framing_enable;   //  = 1'b0; 
    logic        ctl_tx_fcs_ins_enable;         //  = 1'b1;
    logic        ctl_tx_ignore_fcs;             //  = 1'b0;
    logic        ctl_rx_ignore_fcs;             //  = 1'b0;
    logic        ctl_tx_custom_preamble_enable; //  = 1'b0;
    logic        ctl_rx_custom_preamble_enable; //  = 1'b0;
    logic        ctl_frm_gen_mode;              //  = 1'b0; // 0=random, 1=incr. pattern
    logic        ctl_tx_variable_ipg;           //  = 1'b0;
    logic [13:0] ctl_rx_min_packet_len;         //  = 14'd64;
    logic [13:0] ctl_rx_max_packet_len;         //  = 14'd1500;
    logic [31:0] frames_to_send;                //  = 32'd50;//32'd400;
    logic        ctl_rx_check_preamble;         //  = 1'b0; 
    logic        ctl_hwchk_tx_err_inj;          //  = 1'b0; 
    logic        ctl_hwchk_tx_poison_inj;       //  = 1'b0; 
    logic [3:0]  ctl_tx_ipg;                    //  = 4'd8;								
    
    reg   [31:0] addr, data;
    reg   [15:0] snd_time, rcv_time;
    reg   [15:0] datav;
    reg   [31:0] hwchk_block_lock;
    integer      attempts;
    
    integer      lat, lat_cnt, lat_min, lat_max;
    real         lat_total;
    reg          stop_req, stopping;
    bit          timed_out;   // = '0;
    
    // initial begin
    ctl_tx_start_framing_enable     = 1'b0; 
    ctl_tx_fcs_ins_enable           = 1'b1;
    ctl_tx_ignore_fcs               = 1'b0;
    ctl_rx_ignore_fcs               = 1'b0;
    ctl_tx_custom_preamble_enable   = 1'b0;
    ctl_rx_custom_preamble_enable   = 1'b0;
    ctl_frm_gen_mode                = 1'b0; // 0=random, 1=incr. pattern
    ctl_tx_variable_ipg             = 1'b0;
    ctl_rx_min_packet_len           = 14'd64;
    ctl_rx_max_packet_len           = 14'd1500;
    frames_to_send                  = 32'd50;//32'd400;
    frames_to_send                  = 32'd10;//32'd400;
    ctl_rx_check_preamble           = 1'b0; 
    ctl_hwchk_tx_err_inj            = 1'b0; 
    ctl_hwchk_tx_poison_inj         = 1'b0; 
    ctl_tx_ipg                      = 4'd8;			
    timed_out                       = 0;

    HWCHK_LATENCY_CLK_PERIOD_NS = 1.5515;  // 644 MHz

    // Our testcase:
    //  - wait for the HWCHK to detect block block
    //  - align bitslip
    //  - init stats
    //  - send traffic
    //  - collect stats
    //  - compare TX and RX stats

    $display("%t # ", $time);
    $display("%t # Channel %d Init...", $time, channel);
    $display("%t # ", $time);

    //    initial begin
    addr_offset = offset; //32'h0_0000;
    //repeat (1000) @(negedge axi_aclk);
    
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

    // --------------------------------------------------------------
    
    $display("%t Configure near-end loopback", $time);
    addr    = 32'h1_0408;
    hwchk_axil_read (addr_offset,addr, data);
    data[6:4] = 3'b010;
    hwchk_axil_write  (addr_offset,addr, data);

    //$display("%t Configure far-end loopback", $time);
    //addr    = 32'h1_0408;
    //hwchk_axil_read (addr_offset,addr, data);
    //data[6:4] = 3'b100;
    //hwchk_axil_write  (addr_offset,addr, data);

    //$display("%t Configure Normal Operation", $time);
    //addr    = 32'h1_0408;
    //hwchk_axil_read (addr_offset,addr, data);
    //data[6:4] = 3'b000;
    //hwchk_axil_write  (addr_offset,addr, data);

    // --------------------------------------------------------------
    
    $display("%t Reset the RX side of the GT", $time);
    addr    = 32'h1_0400;
    data    = 32'h2;
    hwchk_axil_write  (addr_offset,addr, data);

    addr    = 32'h1_0400;
    data    = 32'h0;
    hwchk_axil_write  (addr_offset,addr, data);

    ctl_tx_data_rate = 1'b0; 
    ctl_rx_data_rate = 1'b0; 
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

end
endtask



task automatic link_channel(int channel, reg [31:0] offset); 
begin
    reg     [31:0]      addr_offset;// = 32'h0_0000;
    real    HWCHK_LATENCY_CLK_PERIOD_NS;   // Set based on the configured data rate
    
    // device config
    logic        ctl_tx_data_rate;
    logic        ctl_rx_data_rate;
    logic        ctl_tx_start_framing_enable;   //  = 1'b0; 
    logic        ctl_tx_fcs_ins_enable;         //  = 1'b1;
    logic        ctl_tx_ignore_fcs;             //  = 1'b0;
    logic        ctl_rx_ignore_fcs;             //  = 1'b0;
    logic        ctl_tx_custom_preamble_enable; //  = 1'b0;
    logic        ctl_rx_custom_preamble_enable; //  = 1'b0;
    logic        ctl_frm_gen_mode;              //  = 1'b0; // 0=random, 1=incr. pattern
    logic        ctl_tx_variable_ipg;           //  = 1'b0;
    logic [13:0] ctl_rx_min_packet_len;         //  = 14'd64;
    logic [13:0] ctl_rx_max_packet_len;         //  = 14'd1500;
    logic [31:0] frames_to_send;                //  = 32'd50;//32'd400;
    logic        ctl_rx_check_preamble;         //  = 1'b0; 
    logic        ctl_hwchk_tx_err_inj;          //  = 1'b0; 
    logic        ctl_hwchk_tx_poison_inj;       //  = 1'b0; 
    logic [3:0]  ctl_tx_ipg;                    //  = 4'd8;								
    
    reg   [31:0] addr, data;
    reg   [15:0] snd_time, rcv_time;
    reg   [15:0] datav;
    reg   [31:0] hwchk_block_lock;
    integer      attempts;
    
    integer      lat, lat_cnt, lat_min, lat_max;
    real         lat_total;
    reg          stop_req, stopping;
    bit          timed_out;   // = '0;
    
    // initial begin
    ctl_tx_start_framing_enable     = 1'b0; 
    ctl_tx_fcs_ins_enable           = 1'b1;
    ctl_tx_ignore_fcs               = 1'b0;
    ctl_rx_ignore_fcs               = 1'b0;
    ctl_tx_custom_preamble_enable   = 1'b0;
    ctl_rx_custom_preamble_enable   = 1'b0;
    ctl_frm_gen_mode                = 1'b0; // 0=random, 1=incr. pattern
    ctl_tx_variable_ipg             = 1'b0;
    ctl_rx_min_packet_len           = 14'd64;
    ctl_rx_max_packet_len           = 14'd1500;
    frames_to_send                  = 32'd50;//32'd400;
    frames_to_send                  = 32'd10;//32'd400;
    ctl_rx_check_preamble           = 1'b0; 
    ctl_hwchk_tx_err_inj            = 1'b0; 
    ctl_hwchk_tx_poison_inj         = 1'b0; 
    ctl_tx_ipg                      = 4'd8;			
    timed_out                       = 0;

    HWCHK_LATENCY_CLK_PERIOD_NS = 1.5515;  // 644 MHz

    addr_offset = offset;

    $display("%t # ", $time);
    $display("%t # Channel %d Link...", $time, channel);
    $display("%t # ", $time);

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
    //if(channel == 0)
    //    wait(&frame_gen_ready == 1);
    //else begin
    //    wait(frame_gen_ready[channel-1] == 1);
    //    wait(frame_gen_ready[channel-1] == 0);
    //end
end
endtask

//endmodule





task automatic run_channel(); 
begin
    int        channel;
    reg [31:0] offset;

    reg     [31:0]      addr_offset;// = 32'h0_0000;
    real    HWCHK_LATENCY_CLK_PERIOD_NS;   // Set based on the configured data rate
    
    // device config
    logic        ctl_tx_data_rate;
    logic        ctl_rx_data_rate;
    logic        ctl_tx_start_framing_enable;   //  = 1'b0; 
    logic        ctl_tx_fcs_ins_enable;         //  = 1'b1;
    logic        ctl_tx_ignore_fcs;             //  = 1'b0;
    logic        ctl_rx_ignore_fcs;             //  = 1'b0;
    logic        ctl_tx_custom_preamble_enable; //  = 1'b0;
    logic        ctl_rx_custom_preamble_enable; //  = 1'b0;
    logic        ctl_frm_gen_mode;              //  = 1'b0; // 0=random, 1=incr. pattern
    logic        ctl_tx_variable_ipg;           //  = 1'b0;
    logic [13:0] ctl_rx_min_packet_len;         //  = 14'd64;
    logic [13:0] ctl_rx_max_packet_len;         //  = 14'd1500;
    logic [31:0] frames_to_send;                //  = 32'd50;//32'd400;
    logic        ctl_rx_check_preamble;         //  = 1'b0; 
    logic        ctl_hwchk_tx_err_inj;          //  = 1'b0; 
    logic        ctl_hwchk_tx_poison_inj;       //  = 1'b0; 
    logic [3:0]  ctl_tx_ipg;                    //  = 4'd8;								
    
    reg   [31:0] addr, data;
    reg   [15:0] snd_time, rcv_time;
    reg   [15:0] datav;
    reg   [31:0] hwchk_block_lock;
    integer      attempts;
    
    integer      lat, lat_cnt, lat_min, lat_max;
    real         lat_total;
    reg          stop_req, stopping;
    bit          timed_out;   // = '0;
    
    reg [31:0] pkt_received_0 ;
    reg [31:0] pkt_received_1 ;
    reg [31:0] pkt_received_2 ;
    reg [31:0] pkt_received_3 ;
    
    // initial begin
    ctl_tx_start_framing_enable     = 1'b0; 
    ctl_tx_fcs_ins_enable           = 1'b1;
    ctl_tx_ignore_fcs               = 1'b0;
    ctl_rx_ignore_fcs               = 1'b0;
    ctl_tx_custom_preamble_enable   = 1'b0;
    ctl_rx_custom_preamble_enable   = 1'b0;
    ctl_frm_gen_mode                = 1'b0; // 0=random, 1=incr. pattern
    ctl_tx_variable_ipg             = 1'b0;
    ctl_rx_min_packet_len           = 14'd64;
    ctl_rx_max_packet_len           = 14'd1500;
    frames_to_send                  = 32'd50;//32'd400;
    frames_to_send                  = 32'd10;//32'd400;
    ctl_rx_check_preamble           = 1'b0; 
    ctl_hwchk_tx_err_inj            = 1'b0; 
    ctl_hwchk_tx_poison_inj         = 1'b0; 
    ctl_tx_ipg                      = 4'd8;			
    timed_out                       = 0;

    HWCHK_LATENCY_CLK_PERIOD_NS = 1.5515;  // 644 MHz

    channel     = 0;
    addr_offset = 'h10_0000;
    $display("%t Enable the frame generator and monitor for channel-%d", $time,channel);
    addr    = 32'h20;
    data    = 0;
    data    = data | (1'b1 << 0); // gen_en
    data    = data | (1'b1 << 4); // mon_en
    hwchk_axil_write  (addr_offset,addr, data);
    frame_gen_ready[channel] = 0;

    channel     = 1;
    addr_offset = 'h12_0000;
    $display("%t Enable the frame generator and monitor for channel-%d", $time,channel);
    addr    = 32'h20;
    data    = 0;
    data    = data | (1'b1 << 0); // gen_en
    data    = data | (1'b1 << 4); // mon_en
    hwchk_axil_write  (addr_offset,addr, data);
    frame_gen_ready[channel] = 0;

    channel     = 2;
    addr_offset = 'h14_0000;
    $display("%t Enable the frame generator and monitor for channel-%d", $time,channel);
    addr    = 32'h20;
    data    = 0;
    data    = data | (1'b1 << 0); // gen_en
    data    = data | (1'b1 << 4); // mon_en
    hwchk_axil_write  (addr_offset,addr, data);
    frame_gen_ready[channel] = 0;

    channel     = 3;
    addr_offset = 'h16_0000;
    $display("%t Enable the frame generator and monitor for channel-%d", $time,channel);
    addr    = 32'h20;
    data    = 0;
    data    = data | (1'b1 << 0); // gen_en
    data    = data | (1'b1 << 4); // mon_en
    hwchk_axil_write  (addr_offset,addr, data);
    frame_gen_ready[channel] = 0;


    do
    begin
        repeat (100) @(negedge axi_aclk);
        pkt_received_0 = sim_tb.clk_recov.gtf_top_0.u_gtfwizard_0_example_gtfmac_top.gtfmac_hwchk_core_gen[0].i_gtfmac_hwchk_core.i_rx_mon.rx_packet_count;
        pkt_received_1 = sim_tb.clk_recov.gtf_top_0.u_gtfwizard_0_example_gtfmac_top.gtfmac_hwchk_core_gen[1].i_gtfmac_hwchk_core.i_rx_mon.rx_packet_count;
        //pkt_received_2 = sim_tb.clk_recov.gtf_top_0.u_gtfwizard_0_example_gtfmac_top.gtfmac_hwchk_core_gen[2].i_gtfmac_hwchk_core.i_rx_mon.rx_packet_count;
        //pkt_received_3 = sim_tb.clk_recov.gtf_top_0.u_gtfwizard_0_example_gtfmac_top.gtfmac_hwchk_core_gen[3].i_gtfmac_hwchk_core.i_rx_mon.rx_packet_count;
        $display("%t Packets received", $time);
        $display("            %d : %d", 0, pkt_received_0);
        $display("            %d : %d", 1, pkt_received_1);
        $display("            %d : %d", 2, pkt_received_2);
        $display("            %d : %d", 3, pkt_received_3);
    end
    while ( (pkt_received_0 < 10) ||
            (pkt_received_1 < 10) ||
            (pkt_received_2 < 10) ||
            (pkt_received_3 < 10)  );
    
    repeat (1000) @(negedge axi_aclk);

//    received = sim_tb.clk_recov.gtf_top_0.u_gtfwizard_0_example_gtfmac_top.gtfmac_hwchk_core_gen[0].i_gtfmac_hwchk_core.i_rx_mon.stat_total_packets_incr
//
//
//
//
//    
//    stop_req = 0;
//    stopping = 0;
//    
//    fork
//        
//        begin
//            lat_cnt   = 0;
//            lat_min   = 1000;
//            lat_max   = 0;
//            lat_total = 0;
//            do begin
//    
//                
//                #5ns;
//                //$display("%t stop_req = %d", $time, stop_req);
//                if (stop_req) begin
//                    $display("%t stop_req = %d", $time, stop_req);
//    
//                    stopping = 1;
//                    if(channel != 0) begin
//                    wait(frame_gen_ready[channel-1] == 1);
//                    wait(frame_gen_ready[channel-1] == 0);
//                    end
//    
//                    $display("%t disable fram gen", $time);
//                    // Disable the frame generator
//                    addr    = 32'h20;
//                    data    = 0;
//                    data    = data | (1'b0 << 0); // gen_en
//                    hwchk_axil_write  (addr_offset,addr, data);
//    
//                    $display("%t flush", $time);
//                    // Flush pipeline
//                    repeat (5000) @(negedge axi_aclk);
//                end
//    
//                /*
//                datav = 0;
//    
//                if (data[16]) begin
//                    $display("ERROR:  FIFO overflow!");
//                    $display("** Error: Test did not complete successfully");
//                    $finish;
//                end
//                
//                //$display("Debug after IF");
//    
//                if (datav > 0) begin
//    
//                    // $display("There are %0d entries available to read.", datav);
//    
//                    for (int i=0;i<datav;i=i+1) begin
//                        hwchk_axil_read (addr_offset,32'h8008, {rcv_time, snd_time});
//    
//                        // Compute the delta between the send time and the receive time
//                        // We can take away one clock, because rx_tsof is launched off of the previous
//                        // rxusrclk rising edge, and it's agreed that this is the end measurement time.
//                        if (rcv_time - snd_time > 0) begin
//                            lat = rcv_time - snd_time - 1;
//                        end
//                        else begin
//                            lat = 65535 - snd_time + rcv_time - 1;
//                        end
//    
//                        if (lat < lat_min)
//                            lat_min = lat;
//    
//                        if (lat > lat_max)
//                            lat_max = lat;
//    
//                        lat_total = lat_total + lat;
//    
//                        lat_cnt = lat_cnt + 1;
//    
//                    end
//    
//                end
//                */
//            end
//            while (!stopping);
//            $display("%t thread 1 finished", $time);
//        end
//        
//        begin
//    
//            fork begin
//            fork
//                begin
//                    #10ms;
//                    $display("%t Watchdog reached...", $time);
//                    timed_out = '1;
//                end
//            join_none
//            wait(frames_received_l == frames_to_send || timed_out);
//            disable fork;
//            end join
//    
//            $display("%t Stopping...", $time);
//            stop_req    = 1;
//            frame_gen_ready[channel] = 1;
//            $display("%t thread 2 finished", $time);
//        end
//    
//    join
//    
//    $display("%t Stopped.", $time);
//    frame_gen_ready[channel] = 0;
//    frame_stat_ready[channel] = 1;
//    $display("%t Channel-%d  is ready to read status registers",$time,channel);
//    if(channel == 0)
//    wait(&frame_stat_ready == 1);
//    else begin
//    wait(frame_stat_ready[channel-1] == 1);
//    wait(frame_stat_ready[channel-1] == 0);
//    end
//    $display("%t Channel-%d  is starting reading status registers",$time,channel);
//    
//    $display("%t Tick the HWCHK stats for collection.", $time);
//    addr    = 32'h90;
//    data    = 32'h1;
//    hwchk_axil_write  (addr_offset,addr, data);
//    
//    $display("%t Tick the GTFMAC stats for collection", $time);
//    addr    = 32'h1_0000 | 32'h40C;
//    data    = 32'h1;
//    hwchk_axil_write  (addr_offset,addr, data);
//    
    repeat (50) @(negedge axi_aclk);
end
endtask




