/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------


`timescale 1ps/1ps

// =====================================================================================================================
// This example design top simulation module instantiates the example design top module, provides basic stimulus to it
// while looping back transceiver data from transmit to receive, and utilizes the PRBS checker-based link status
// indicator to demonstrate simple data integrity checking of the design. This module is for use in simulation only.
// =====================================================================================================================

`default_nettype none
module sim_top ();

   // GTF channels
   // Valid values are from 1 to 4	   
   parameter integer NUM_CHANNEL = 1; 
   // Free running clock period in ps
   // Valid ps value is generated from 100MHz to 250MHz clock period
   parameter C_FREERUN_CLK_PERIOD = 5000.0;

    `include "sim_clk_reset.sv"
    `include "sim_axi_driver.sv"
  

    wire [NUM_CHANNEL-1:0]    serial_p;
    wire [NUM_CHANNEL-1:0]    serial_n;
    
    gtfwizard_raw_top0  #(
        .NUM_CHANNEL ( NUM_CHANNEL ),
        .SIMULATION  ( "true"      )
    ) u_gtfwizard_raw_gtfraw_ex (
        .gtf_ch_gtftxn          ( ), //serial_n          ),
        .gtf_ch_gtftxp          ( ), //serial_p          ),
        .gtf_ch_gtfrxn          ( ), //serial_n          ),
        .gtf_ch_gtfrxp          ( ), //serial_p          ),
    
        .SYNCE_CLK11_LVDS_P     ( SYNCE_CLK_LVDS_P  ),
        .SYNCE_CLK11_LVDS_N     ( ~SYNCE_CLK_LVDS_P ),
    
        .CLK12_LVDS_300_P       (  refclk_300       ),
        .CLK12_LVDS_300_N       (  ~refclk_300      ),
    
        .CLK13_LVDS_300_P       (  refclk_300       ),
        .CLK13_LVDS_300_N       (  ~refclk_300      )
    );


    /////////////////////////////////////////////////////////////////////////////////////////////
    //  HWCHK Test 
    /////////////////////////////////////////////////////////////////////////////////////////////

    reg simulation_timeout_check = 1'b0;
    initial begin
        // Create a basic timeout indicator which is used to abort the simulation of no link is achieved after 15ms
        simulation_timeout_check = 1'b0;
        #15E13;
        simulation_timeout_check = 1'b1;
        $display("Time : %15d fs   FAIL: simulation timeout. Link never achieved.", $time);
        $display("** Error: Test did not complete successfully");
        $finish;
    end

    reg [31:0]  axi_addr_offset;
    reg [31:0]  axi_addr       ;
    reg [31:0]  axi_data       ;
                

    reg         link_stable       = 'h0;
    reg         link_status       = 'h0;
    reg         link_down_latched = 'h0;

    reg [15:0]  err_inj_remain    ;
    reg [15:0]  lat_remain        ;

    reg [15:0]  lat_rx_time    ;
    reg [15:0]  lat_tx_time    ;
    
    real        lat_delta;

    real        lat, lat_cnt, lat_min, lat_max;
    real        lat_total;
    real        VNC_LATENCY_CLK_PERIOD_NS;   // Set based on the configured data rate

    integer     ERROR_INJ_DELAY = 40;
    integer     ERROR_INJ_COUNT = 10;

    initial
    begin
    
        axi_addr_offset = 'h0;
    
        // Wait for clock/rst....
        @(posedge refclk_300_rst); 
        repeat (1000) @(posedge refclk_300);

        //  Apply System Resets...
        //  Set - gtwiz_reset_all
        //        gtf_ch_txdp_reset
        //        gtf_ch_rxdp_reset
        $display("Time : %15d fs   Set and clear system resets...", $time);
        axi_addr  = 'h04;
        axi_data  = 'h07;
        sim_axil_write( axi_addr_offset, axi_addr, axi_data);
        //  Clear - gtwiz_reset_all
        axi_addr  = 'h04;
        axi_data  = 'h06;
        sim_axil_write( axi_addr_offset, axi_addr, axi_data);
        //  Clear - gtf_ch_txdp_reset
        //          gtf_ch_rxdp_reset
        axi_addr  = 'h04;
        axi_data  = 'h00;
        sim_axil_write( axi_addr_offset, axi_addr, axi_data);

        //Wait for Link Stable to go high....
        $display("Time : %15d fs   Wait for link stable...", $time);
        axi_addr  = 'h00;
        axi_data  = 'h00;
        link_stable = axi_data[1];
        while (link_stable === 'h0) begin
            repeat (100) @(posedge refclk_300);
            sim_axil_read( axi_addr_offset, axi_addr, axi_data);
            link_stable = axi_data[1];
        end


        $display("Time : %15d fs   Initial link achieved across all transceiver channels.", $time);        
        // Delay 10 ns
        #10000;
        
        $display("Time : %15d fs   Setup Error Inject and Latency.", $time);
        // Set Error Inject Count
        axi_addr  = 'h10;
        axi_data  = ERROR_INJ_COUNT;
        sim_axil_write( axi_addr_offset, axi_addr, axi_data);
        
        // Set Error Inject Delay Count
        axi_addr  = 'h14;
        axi_data  = ERROR_INJ_DELAY;
        sim_axil_write( axi_addr_offset, axi_addr, axi_data);
        
        // Set Latency count
        axi_addr  = 'h20;
        axi_data  = ERROR_INJ_COUNT;
        sim_axil_write( axi_addr_offset, axi_addr, axi_data);
        
        // Enable Latency Logic
        axi_addr  = 'h04;
        axi_data  = 'h010;
        sim_axil_write( axi_addr_offset, axi_addr, axi_data);
        
        // Clear Latency Pointers...
        axi_addr    = 'h04;
        axi_data[6] = 1   ; // (W1C)
        sim_axil_write( axi_addr_offset, axi_addr, axi_data);
        
        // Enable Err Inject Logic
        axi_addr  = 'h04;
        axi_data  = 'h110;
        sim_axil_write( axi_addr_offset, axi_addr, axi_data);
        
        // Loop until Error Inject Logic complete
        $display("Time : %15d fs   Latency Loop.", $time);
        
        err_inj_remain = 'hFF ;
        lat_remain     = 'hFF ;
        
        lat_cnt   = 0;
        lat_min   = 1000;
        lat_max   = 0;
        lat_total = 0;
        VNC_LATENCY_CLK_PERIOD_NS = 1.5515;  // 644 MHz

        while ( !((err_inj_remain == 'h0) && (lat_remain == 'h0)) )
        begin
        
            // Check for latency data pending....
            axi_addr = 'h24;
            sim_axil_read( axi_addr_offset, axi_addr, axi_data);
            if ( axi_data[15:0] != 'h0) begin
                // latency data available, pulse pop bit ...
                axi_addr  = 'h04;
                sim_axil_read( axi_addr_offset, axi_addr, axi_data);
                axi_data[5] = 1'b1; //set pop (W1C)
                sim_axil_write( axi_addr_offset, axi_addr, axi_data);
                
                // Read latency TX/RX timer values....
                axi_addr  = 'h28;
                sim_axil_read( axi_addr_offset, axi_addr, axi_data);
                lat_tx_time = axi_data;
                axi_addr  = 'h2C;
                sim_axil_read( axi_addr_offset, axi_addr, axi_data);
                lat_rx_time = axi_data;
                
                if (lat_rx_time - lat_tx_time > 0) begin
                    lat = lat_rx_time - lat_tx_time - 6.5;
                end else begin
                    lat = 65535 - lat_rx_time + lat_rx_time - 6.5;
                end
                
                $display("Time : %15d fs   Latency: %3d ::  Rx=%6d Tx=%6d  Delta=%.3f cycles", 
                        $time       , 
                        lat_cnt + 1 , 
                        lat_rx_time , 
                        lat_tx_time , 
                        lat         );
                        
                lat_cnt = lat_cnt + 1;
                
                if (lat < lat_min)
                    lat_min = lat;

                if (lat > lat_max)
                    lat_max = lat;

                lat_total = lat_total + lat;
                
            end
            
            // Read error inject and latency counters for remaining samples....
            axi_addr  = 'h18;
            sim_axil_read( axi_addr_offset, axi_addr, axi_data);
            err_inj_remain = axi_data[15:0];
        
            axi_addr  = 'h24;
            sim_axil_read( axi_addr_offset, axi_addr, axi_data);
            lat_remain = axi_data[15:0];
        end
        $display("Time : %15d fs   Latency Loop Done.", $time);
        
        $display("\n%0t Latency calculation:  %0.1f/%0.2f/%0.1f ticks (%0d records).  %0.2f ns/%0.2f ns/%0.2f ns\n", 
                        $time, 
                        lat_min, lat_total/lat_cnt, lat_max, 
                        lat_cnt, 
                        lat_min*VNC_LATENCY_CLK_PERIOD_NS, 
                        lat_total/lat_cnt*VNC_LATENCY_CLK_PERIOD_NS, 
                        lat_max*VNC_LATENCY_CLK_PERIOD_NS
                );

        
        // Reset the latched link down indicator, which is always set prior to initially achieving link
        $display("Time : %15d ps   Resetting latched link down indicator.", $time);
        $display("Time : %15d fs   Continuing simulation for 50us to check for maintenance of link.", $time);
        #5E7;
    
        axi_addr  = 'h00;
        axi_data  = 'h00;
        sim_axil_read( axi_addr_offset, axi_addr, axi_data);
        link_status       = axi_data[0];
        link_down_latched = axi_data[2];

        // At simulation completion, if the link indicator is still high and no intermittent link loss was detected,
        // display a success message. Otherwise, display a failure message. Complete the simulation in either case.
        if ((link_status === 1'b1) && (link_down_latched === 1'b0)) begin
            $display("Time : %15d fs   PASS: simulation completed with maintained link.", $time);
            $display("** Test completed successfully");
        end else begin
            $display("Time : %15d fs   FAIL: simulation completed with subsequent link loss after after initial link.", $time);
            $display("** Error: Test did not complete successfully");
        end
        #1000;
    
    $finish;
    end

endmodule
`default_nettype wire
