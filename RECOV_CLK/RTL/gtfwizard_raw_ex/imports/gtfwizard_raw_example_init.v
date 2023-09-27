/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------


`timescale 1ps/1ps

// =====================================================================================================================
// This example design initialization module provides a demonstration of how initialization logic can be constructed to
// interact with and enhance the reset controller helper block in order to assist with successful system bring-up. This
// example initialization logic monitors for timely reset completion, retrying resets as necessary to mitigate problems
// with system bring-up such as clock or data connection readiness. This is an example and can be modified as necessary.
// =====================================================================================================================

`default_nettype none
module gtfwizard_raw_example_init # (

  parameter real   P_FREERUN_FREQUENCY    = 200,
  parameter real   P_TX_TIMER_DURATION_US = 30000,
  parameter real   P_RX_TIMER_DURATION_US = 130000

)(

  input  wire      clk_freerun_in,
  input  wire      reset_all_in,
  input  wire      tx_init_done_in,
  input  wire      rx_init_done_in,
  input  wire      rx_data_good_in,
  output reg       reset_all_out = 1'b0,
  output reg       reset_rx_out  = 1'b0,
  output reg       init_done_out = 1'b0,
  output reg [3:0] retry_ctr_out = 4'd0

);

  wire     reset_all_sync;

  // -------------------------------------------------------------------------------------------------------------------
  // Synchronizers
  // -------------------------------------------------------------------------------------------------------------------

  // Synchronize the "reset all" input signal into the free-running clock domain
  // The reset_all_in input should be driven by the master "reset all" example design input
  xpm_cdc_async_rst # (
    .DEST_SYNC_FF (5),
    .RST_ACTIVE_HIGH(1)
  ) u_init_reset_all_in_sync (
    .dest_clk  (clk_freerun_in),
    .src_arst  (reset_all_in),
    .dest_arst (reset_all_sync)
  );

  // Synchronize the TX initialization done indicator into the free-running clock domain
  // The tx_init_done_in input should be driven by the signal or logical combination of signals that represents a
  // completed TX initialization process; for example, the reset helper block gtwiz_reset_tx_done_out signal, or the
  // logical AND of gtwiz_reset_tx_done_out with gtwiz_buffbypass_tx_done_out if the TX buffer is bypassed.
  wire tx_init_done_sync;
  assign tx_init_done_sync  = tx_init_done_in; //synchronized in top level above <>_example_top
  /*xpm_cdc_single #(
   .DEST_SYNC_FF(3),   // DECIMAL; range: 2-10
   .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
   .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   .SRC_INPUT_REG(0)   // DECIMAL; 0=do not register input, 1=register input
   ) u_tx_init_done_inst (
     .dest_out (tx_init_done_sync),
     .dest_clk (clk_freerun_in),
     .src_clk  (1'b0),
     .src_in   (tx_init_done_in)
   );*/

  // Synchronize the RX initialization done indicator into the free-running clock domain
  // The rx_init_done_in input should be driven by the signal or logical combination of signals that represents a
  // completed RX initialization process; for example, the reset helper block gtwiz_reset_rx_done_out signal, or the
  // logical AND of gtwiz_reset_rx_done_out with gtwiz_buffbypass_rx_done_out if the RX elastic buffer is bypassed.
  wire rx_init_done_sync;
  assign rx_init_done_sync  = rx_init_done_in; //synchronized in top level above <>_example_top
  /*xpm_cdc_single #(
   .DEST_SYNC_FF(3),   // DECIMAL; range: 2-10
   .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
   .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   .SRC_INPUT_REG(0)   // DECIMAL; 0=do not register input, 1=register input
   ) u_rx_init_done_inst (
     .dest_out (rx_init_done_sync),
     .dest_clk (clk_freerun_in),
     .src_clk  (1'b0),
     .src_in   (rx_init_done_in)
   );*/

  // Synchronize the RX data good indicator into the free-running clock domain
  // The rx_data_good_in input should be driven the user application's indication of continual good data reception.
  // The example design drives rx_data_good_in high when no PRBS checker errors are seen in the 8 most recent
  // consecutive clock cycles of data reception.
  wire rx_data_good_sync;
  xpm_cdc_single #(
   .DEST_SYNC_FF(3),   // DECIMAL; range: 2-10
   .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
   .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   .SRC_INPUT_REG(0)   // DECIMAL; 0=do not register input, 1=register input
   ) u_rx_data_good_inst (
     .dest_out (rx_data_good_sync),
     .dest_clk (clk_freerun_in),
     .src_clk  (1'b0),
     .src_in   (rx_data_good_in)
   );

  // -------------------------------------------------------------------------------------------------------------------
  // Timer
  // -------------------------------------------------------------------------------------------------------------------

  // Declare registers and local parameters used for the shared TX and RX initialization timer
  // The free-running clock frequency is specified by the P_FREERUN_FREQUENCY parameter. The TX initialization timer
  // duration is specified by the P_TX_TIMER_DURATION_US parameter (default 30,000us), and the resulting terminal count
  // is assigned to p_tx_timer_term_cyc_int. The RX initialization timer duration is specified by the
  // P_RX_TIMER_DURATION_US parameter (default 130,000us), and the resulting terminal count is assigned to
  // p_rx_timer_term_cyc_int.
  reg         timer_clr = 1'b1;
  reg  [24:0] timer_ctr = 25'd0;
  reg         tx_timer_sat = 1'b0;
  reg         rx_timer_sat = 1'b0;
  wire [24:0] p_tx_timer_term_cyc_int = P_TX_TIMER_DURATION_US * P_FREERUN_FREQUENCY;
  wire [24:0] p_rx_timer_term_cyc_int = P_RX_TIMER_DURATION_US * P_FREERUN_FREQUENCY;

  // When the timer is enabled by the initialization state machine, increment the timer_ctr counter until its value
  // reaches p_rx_timer_term_cyc_int RX terminal count and rx_timer_sat is asserted. Assert tx_timer_sat when the
  // counter value reaches the p_tx_timer_term_cyc_int TX terminal count. Clear the timer and remove assertions when the
  // timer is disabled by the initialization state machine.
  always @(posedge clk_freerun_in) begin
    if (timer_clr) begin
      timer_ctr    <= 25'd0;
      tx_timer_sat <= 1'b0;
      rx_timer_sat <= 1'b0;
    end
    else begin
      if (timer_ctr == p_tx_timer_term_cyc_int)
        tx_timer_sat <= 1'b1;

      if (timer_ctr == p_rx_timer_term_cyc_int)
        rx_timer_sat <= 1'b1;
      else
        timer_ctr <= timer_ctr + 25'd1;
    end
  end


  // -------------------------------------------------------------------------------------------------------------------
  // Retry counter
  // -------------------------------------------------------------------------------------------------------------------

  // Increment the retry_ctr_out register for each TX or RX reset asserted by the initialization state machine until the
  // register saturates at 4'd15. This value, which is initialized on device programming and is never reset, could be
  // useful for debugging purposes. The initialization state machine will continue to retry as needed beyond the retry
  // register saturation point indicated, so 4'd15 should be interpreted as "15 or more attempts since programming."
  reg retry_ctr_incr = 1'b0;

  always @(posedge clk_freerun_in) begin
    if ((retry_ctr_incr == 1'b1) && (retry_ctr_out != 4'd15))
      retry_ctr_out <= retry_ctr_out + 4'd1;
  end


  // -------------------------------------------------------------------------------------------------------------------
  // Initialization state machine
  // -------------------------------------------------------------------------------------------------------------------

  // Declare local parameters and state register for the initialization state machine
  localparam [1:0] ST_START       = 2'd0;
  localparam [1:0] ST_TX_WAIT     = 2'd1;
  localparam [1:0] ST_RX_WAIT     = 2'd2;
  localparam [1:0] ST_MONITOR     = 2'd3;
  reg        [1:0] sm_init        = ST_START;
  reg              sm_init_active = 1'b0;

  // Implement the initialization state machine control and its outputs as a single sequential process. The state
  // machine is reset by the synchronized reset_all_in input, and does not begin operating until its first use. Note
  // that this state machine is designed to interact with and enhance the reset controller helper block.
  always @(posedge clk_freerun_in) begin
    if (reset_all_sync) begin
      timer_clr      <= 1'b1;
      reset_all_out  <= 1'b0;
      reset_rx_out   <= 1'b0;
      retry_ctr_incr <= 1'b0;
      init_done_out  <= 1'b0;
      sm_init_active <= 1'b1;
      sm_init        <= ST_START;
    end
    else begin
      case (sm_init)

        // When starting the initialization procedure, clear the timer and remove reset outputs, then proceed to wait
        // for completion of TX initialization
        ST_START: begin
          if (sm_init_active) begin
            timer_clr      <= 1'b1;
            reset_all_out  <= 1'b0;
            reset_rx_out   <= 1'b0;
            retry_ctr_incr <= 1'b0;
            sm_init        <= ST_TX_WAIT;
          end
        end

        // Enable the timer. If TX initialization completes before the counter's TX terminal count, clear the timer and
        // proceed to wait for RX initialization. If the TX terminal count is reached, clear the timer, assert the
        // reset_all_out output (which in this example causes a master reset_all assertion), and increment the retry
        // counter. Completion conditions for TX initialization are described above.
        ST_TX_WAIT: begin
          if (tx_init_done_sync) begin
            timer_clr <= 1'b1;
            sm_init   <= ST_RX_WAIT;
          end
          else begin
            if (tx_timer_sat) begin
              timer_clr      <= 1'b1;
              reset_all_out  <= 1'b1;
              retry_ctr_incr <= 1'b1;
              sm_init        <= ST_START;
            end
            else begin
              timer_clr <= 1'b0;
            end
          end
        end

        // Enable the timer. When the RX terminal count is reached, check whether RX initialization has completed and
        // whether the data good indicator is high. If both conditions are met, transition to the MONITOR state. If
        // either condition is not met, then clear the timer, assert the reset_rx_out output (which in this example
        // either drives gtwiz_reset_rx_pll_and_datapath_in or gtwiz_reset_rx_datapath_in, depending on PLL sharing),
        // and increnent the retry counter.
        ST_RX_WAIT: begin
          if (rx_timer_sat) begin
            if (rx_init_done_sync && rx_data_good_sync) begin
              init_done_out <= 1'b1;
              sm_init       <= ST_MONITOR;
            end
            else begin
              timer_clr      <= 1'b1;
              reset_rx_out   <= 1'b1;
              retry_ctr_incr <= 1'b1;
              sm_init        <= ST_START;
            end
          end
          else begin
            timer_clr <= 1'b0;
          end
        end

        // In this MONITOR state, assert the init_done_out output for use as desired. If RX initialization or the data
        // good indicator is lost while in this state, reset the RX components as described in the ST_RX_WAIT state.
        ST_MONITOR: begin
          if (~rx_init_done_sync || ~rx_data_good_sync) begin
            init_done_out  <= 1'b0;
            timer_clr      <= 1'b1;
            reset_rx_out   <= 1'b1;
            retry_ctr_incr <= 1'b1;
            sm_init        <= ST_START;
          end
        end

      endcase
    end
  end


endmodule
`default_nettype wire
