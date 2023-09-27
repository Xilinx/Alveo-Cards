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
module gtfwizard_raw_example_top_sim ();

   // GTF channels
   // Valid values are from 1 to 4	   
   parameter integer NUM_CHANNEL = 1; 
   // Free running clock period in ps
   // Valid ps value is generated from 100MHz to 250MHz clock period
   parameter C_FREERUN_CLK_PERIOD = 5000.0;

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
    freerun_clk = #(C_FREERUN_CLK_PERIOD/2.0)  ~freerun_clk;
  end
end


  reg                       simulation_timeout_check = 1'b0;
  reg                       hb_gtwiz_reset_all_in = 1'b1;
  reg  [NUM_CHANNEL-1:0]    hb_gtf_ch_txdp_reset_in = {NUM_CHANNEL{1'b1}};
  reg  [NUM_CHANNEL-1:0]    hb_gtf_ch_rxdp_reset_in = {NUM_CHANNEL{1'b1}};
  wire [NUM_CHANNEL-1:0]    serial_p;
  wire [NUM_CHANNEL-1:0]    serial_n;
  // Declare registers and wires to interface to the PRBS-based link status ports
  reg  [NUM_CHANNEL-1:0]    link_down_latched_reset = {NUM_CHANNEL{1'b0}};
  wire [NUM_CHANNEL-1:0]    link_status;
  wire [NUM_CHANNEL-1:0]    link_down_latched;
  reg  [11*NUM_CHANNEL-1:0] link_up_ctr = {NUM_CHANNEL{11'd0}};
  reg  [NUM_CHANNEL-1:0]    link_stable = {NUM_CHANNEL{1'b0}};
  wire clk_wiz_locked_out;

  initial begin
    hb_gtwiz_reset_all_in = 1'b1;
    repeat (1000) @(posedge freerun_clk);
    hb_gtwiz_reset_all_in = 1'b0;
  end

  initial begin
  // Create a basic timeout indicator which is used to abort the simulation of no link is achieved after 15ms
    simulation_timeout_check = 1'b0;
    #15E13;
    simulation_timeout_check = 1'b1;
  end

  initial
  begin
    // Await de-assertion of the master reset signal
    @(negedge hb_gtf_ch_txdp_reset_in[0]);    
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
  end

  genvar i;
  generate
  for (i=0; i<NUM_CHANNEL; i=i+1) begin : gen_blk_multi_ch_sim
  initial begin
    hb_gtf_ch_txdp_reset_in[i] = 1'b1;
    hb_gtf_ch_rxdp_reset_in[i] = 1'b1;
    repeat (1000) @(posedge freerun_clk);
    hb_gtf_ch_txdp_reset_in[i] = 1'b0;
    hb_gtf_ch_rxdp_reset_in[i] = 1'b0;
  end

  // Create a basic stable link monitor which is set after 2048 consecutive cycles of link up and is reset after any
  // link loss
  always @(posedge freerun_clk) begin
    if (link_status[i] !== 1'b1) begin
      link_up_ctr[11*(i+1)-1:11*i] <= 11'd0;
      link_stable[i] <= 1'b0;
    end
    else begin
      if (&link_up_ctr[11*(i+1)-1:11*i])
        link_stable[i] <= 1'b1;
      else
        link_up_ctr[11*(i+1)-1:11*i] <= link_up_ctr[11*(i+1)-1:11*i] + 11'd1;
    end
  end

  initial
  begin

    // Await assertion of initial link indication or simulation timeout indicator
    @(posedge link_stable[i], simulation_timeout_check);
    if (simulation_timeout_check) begin
      $display("Time : %15d fs   FAIL: simulation timeout. Link never achieved.", $time);
      $display("** Error: Test did not complete successfully");
      $finish;
    end
    else begin
      $display("Time : %15d fs   Initial link achieved across all transceiver channels.", $time);
      // Reset the latched link down indicator, which is always set prior to initially achieving link
      $display("Time : %12d ps   Resetting latched link down indicator.", $time);
      link_down_latched_reset[i] = 1'b1;
      repeat (5) @(freerun_clk);
      link_down_latched_reset[i] = 1'b0;

      $display("Time : %15d fs   Continuing simulation for 50us to check for maintenance of link.", $time);
      #5E7;
    end

      // At simulation completion, if the link indicator is still high and no intermittent link loss was detected,
      // display a success message. Otherwise, display a failure message. Complete the simulation in either case.
      if ((link_status[i] === 1'b1) && (link_down_latched[i] === 1'b0)) begin
        $display("Time : %15d fs   PASS: simulation completed with maintained link.", $time);
        $display("** Test completed successfully");
      end
      else begin
        $display("Time : %15d fs   FAIL: simulation completed with subsequent link loss after after initial link.", $time);
        $display("** Error: Test did not complete successfully");
      end
    #1000;

    $finish;
   end

end
endgenerate

gtfwizard_raw_example_top  u_exdes_top (
  .refclk_p                          (refclk                        ),
  .refclk_n                          (~refclk                       ),
  .gtf_ch_gtftxp                     (serial_p                      ),
  .gtf_ch_gtftxn                     (serial_n                      ),
  .gtf_ch_gtfrxp                     (serial_p                      ),
  .gtf_ch_gtfrxn                     (serial_n                      ),
  .link_down_latched_reset_in        (link_down_latched_reset       ),
  .link_status_out                   (link_status                   ),
  .link_down_latched_out             (link_down_latched             ),
  .hb_gtwiz_reset_clk_freerun_p_in   (freerun_clk                   ),
  .hb_gtwiz_reset_clk_freerun_n_in   (~freerun_clk                  ),
  .clk_wiz_locked_out                (clk_wiz_locked_out            ),
  .gtwiz_reset_tx_done_out           (                              ),  //output wire [NUM_CHANNEL-1:0] gtwiz_reset_tx_done_out,
  .gtwiz_reset_rx_done_out           (                              ),  //output wire [NUM_CHANNEL-1:0] gtwiz_reset_rx_done_out,
  .gtf_cm_qpll0_lock                 (                              ),  //output wire                   gtf_cm_qpll0_lock,
  .hb_gtwiz_reset_all_in             (hb_gtwiz_reset_all_in         ),
  .hb_gtf_ch_txdp_reset_in           (hb_gtf_ch_txdp_reset_in       ),
  .hb_gtf_ch_rxdp_reset_in           (hb_gtf_ch_rxdp_reset_in       )  
);

endmodule
`default_nettype wire
