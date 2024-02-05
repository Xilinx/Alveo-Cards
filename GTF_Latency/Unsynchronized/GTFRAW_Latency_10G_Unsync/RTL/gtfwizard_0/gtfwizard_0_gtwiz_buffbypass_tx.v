/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------


`timescale 1ps/1ps
`default_nettype none
(* DowngradeIPIdentifiedWarnings="yes" *)
module gtfwizard_0_gtwiz_buffbypass_tx #(

  parameter integer P_BUFFER_BYPASS_MODE       = 0,
  parameter integer P_TOTAL_NUMBER_OF_CHANNELS = 1,
  parameter integer P_MASTER_CHANNEL_POINTER   = 0

)(

  // User interface ports
  input  wire gtwiz_buffbypass_tx_clk_in,
  input  wire gtwiz_buffbypass_tx_reset_in,
  input  wire gtwiz_buffbypass_tx_start_user_in,
  input  wire gtwiz_buffbypass_tx_resetdone_in,
  input  wire gtwiz_buffbypass_tx_phdlypd_in,
  output reg  gtwiz_buffbypass_tx_done_out  = 1'b0,
  output reg  gtwiz_buffbypass_tx_error_out = 1'b0,

  // Transceiver interface ports
  input  wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txphaligndone_in,
  input  wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txphinitdone_in,
  input  wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txdlysresetdone_in,
  input  wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txsyncout_in,
  input  wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txsyncdone_in,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txphdlyreset_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txphalign_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txphalignen_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txphdlypd_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txphinit_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txphovrden_out,
  output reg  [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txdlysreset_out = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}},
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txdlybypass_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txdlyen_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txdlyovrden_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txphdlytstclk_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txdlyhold_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txdlyupdown_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txsyncmode_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txsyncallin_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] txsyncin_out

);


  // -------------------------------------------------------------------------------------------------------------------
  // Transmitter buffer bypass conditional generation, based on parameter values in module instantiation
  // -------------------------------------------------------------------------------------------------------------------
  localparam [1:0] ST_BUFFBYPASS_TX_IDLE                 = 2'd0;
  localparam [1:0] ST_BUFFBYPASS_TX_DEASSERT_TXDLYSRESET = 2'd1;
  localparam [1:0] ST_BUFFBYPASS_TX_WAIT_TXSYNCDONE      = 2'd2;
  localparam [1:0] ST_BUFFBYPASS_TX_DONE                 = 2'd3;

  generate if (1) begin: gen_gtwiz_buffbypass_tx_main

    // Use auto mode buffer bypass
    if (P_BUFFER_BYPASS_MODE == 0) begin : gen_auto_mode

      // For single-lane auto mode buffer bypass, perform specified input port tie-offs
      if (P_TOTAL_NUMBER_OF_CHANNELS == 1) begin : gen_assign_one_chan
        assign txphdlyreset_out  = 1'b0;
        assign txphalign_out     = 1'b0;
        assign txphalignen_out   = 1'b0;
        assign txphdlypd_out     = gtwiz_buffbypass_tx_phdlypd_in;
        assign txphinit_out      = 1'b0;
        assign txphovrden_out    = 1'b0;
        assign txdlybypass_out   = 1'b0;
        assign txdlyen_out       = 1'b0;
        assign txdlyovrden_out   = 1'b0;
        assign txphdlytstclk_out = 1'b0;
        assign txdlyhold_out     = 1'b0;
        assign txdlyupdown_out   = 1'b0;
        assign txsyncmode_out    = 1'b1;
        assign txsyncallin_out   = txphaligndone_in;
        assign txsyncin_out      = 1'b0;
      end

      // For multi-lane auto mode buffer bypass, perform specified master and slave lane input port tie-offs
      else begin : gen_assign_multi_chan
        assign txphdlyreset_out  = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
        assign txphalign_out     = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
        assign txphalignen_out   = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
        assign txphdlypd_out     = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
        assign txphinit_out      = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
        assign txphovrden_out    = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
        assign txdlybypass_out   = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
        assign txdlyen_out       = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
        assign txdlyovrden_out   = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
        assign txphdlytstclk_out = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
        assign txdlyhold_out     = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
        assign txdlyupdown_out   = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};

        genvar gi;
        for (gi = 0; gi < P_TOTAL_NUMBER_OF_CHANNELS; gi = gi + 1) begin : gen_assign_txsyncmode
          if (gi == P_MASTER_CHANNEL_POINTER)
            assign txsyncmode_out[gi] = 1'b1;
          else
            assign txsyncmode_out[gi] = 1'b0;
        end

        assign txsyncallin_out = {P_TOTAL_NUMBER_OF_CHANNELS{&txphaligndone_in}};
        assign txsyncin_out    = {P_TOTAL_NUMBER_OF_CHANNELS{txsyncout_in[P_MASTER_CHANNEL_POINTER]}};
      end

      // Detect the rising edge of the transmitter reset done re-synchronized input. Assign an internal buffer bypass
      // start signal to the OR of this reset done indicator, and the synchronous buffer bypass procedure user request.
      wire gtwiz_buffbypass_tx_resetdone_sync_int;

     xpm_cdc_async_rst # (
      .DEST_SYNC_FF (5),
      .RST_ACTIVE_HIGH (0)
     ) reset_synchronizer_resetdone_inst (
       .src_arst  (gtwiz_buffbypass_tx_resetdone_in),
       .dest_arst (gtwiz_buffbypass_tx_resetdone_sync_int),
       .dest_clk  (gtwiz_buffbypass_tx_clk_in)
     );


      reg  gtwiz_buffbypass_tx_resetdone_reg = 1'b0;
      wire gtwiz_buffbypass_tx_start_int;

      always @(posedge gtwiz_buffbypass_tx_clk_in) begin
        if (gtwiz_buffbypass_tx_reset_in)
          gtwiz_buffbypass_tx_resetdone_reg <= 1'b0;
        else
          gtwiz_buffbypass_tx_resetdone_reg <= gtwiz_buffbypass_tx_resetdone_sync_int;
      end

      assign gtwiz_buffbypass_tx_start_int = (gtwiz_buffbypass_tx_resetdone_sync_int &&
                                             ~gtwiz_buffbypass_tx_resetdone_reg) || gtwiz_buffbypass_tx_start_user_in;

      // Synchronize the master channel's buffer bypass completion output (TXSYNCDONE) into the local clock domain
      // and detect its rising edge for purposes of safe state machine transitions
      reg  gtwiz_buffbypass_tx_master_syncdone_sync_reg = 1'b0;
      wire gtwiz_buffbypass_tx_master_syncdone_sync_int;
      wire gtwiz_buffbypass_tx_master_syncdone_sync_re;

      xpm_cdc_sync_rst # (
       .DEST_SYNC_FF (4),
       .INIT         (0)
      ) bit_synchronizer_mastersyncdone_inst (
        .src_rst  (txsyncdone_in[P_MASTER_CHANNEL_POINTER]),
        .dest_rst (gtwiz_buffbypass_tx_master_syncdone_sync_int),
        .dest_clk (gtwiz_buffbypass_tx_clk_in)
      );


      always @(posedge gtwiz_buffbypass_tx_clk_in)
        gtwiz_buffbypass_tx_master_syncdone_sync_reg <= gtwiz_buffbypass_tx_master_syncdone_sync_int;

      assign gtwiz_buffbypass_tx_master_syncdone_sync_re = gtwiz_buffbypass_tx_master_syncdone_sync_int &&
                                                          ~gtwiz_buffbypass_tx_master_syncdone_sync_reg;

      // Synchronize the master channel's phase alignment completion output (TXPHALIGNDONE) into the local clock domain
      wire gtwiz_buffbypass_tx_master_phaligndone_sync_int;

      xpm_cdc_sync_rst # (
       .DEST_SYNC_FF (4),
       .INIT         (0)
      )  bit_synchronizer_masterphaligndone_inst (
        .src_rst  (txphaligndone_in[P_MASTER_CHANNEL_POINTER]),
        .dest_rst (gtwiz_buffbypass_tx_master_phaligndone_sync_int),
        .dest_clk (gtwiz_buffbypass_tx_clk_in)
      );

      // Implement a simple state machine to perform the transmitter auto mode buffer bypass procedure
      reg [1:0] sm_buffbypass_tx = ST_BUFFBYPASS_TX_IDLE;

      always @(posedge gtwiz_buffbypass_tx_clk_in) begin
        if (gtwiz_buffbypass_tx_reset_in) begin
          gtwiz_buffbypass_tx_done_out  <= 1'b0;
          gtwiz_buffbypass_tx_error_out <= 1'b0;
          txdlysreset_out               <= {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
          sm_buffbypass_tx              <= ST_BUFFBYPASS_TX_IDLE;
        end
        else begin
          case (sm_buffbypass_tx)

            // Upon assertion of the internal buffer bypass start signal, assert TXDLYSRESET output(s)
            default: begin
              if (gtwiz_buffbypass_tx_start_int) begin
                gtwiz_buffbypass_tx_done_out  <= 1'b0;
                gtwiz_buffbypass_tx_error_out <= 1'b0;
                txdlysreset_out               <= {P_TOTAL_NUMBER_OF_CHANNELS{1'b1}};
                sm_buffbypass_tx              <= ST_BUFFBYPASS_TX_DEASSERT_TXDLYSRESET;
              end
            end

            // De-assert the TXDLYSRESET output(s)
            ST_BUFFBYPASS_TX_DEASSERT_TXDLYSRESET: begin
              txdlysreset_out  <= {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}};
              sm_buffbypass_tx <= ST_BUFFBYPASS_TX_WAIT_TXSYNCDONE;
            end

            // Upon assertion of the synchronized TXSYNCDONE indicator, transition to the final state
            ST_BUFFBYPASS_TX_WAIT_TXSYNCDONE: begin
              if (gtwiz_buffbypass_tx_master_syncdone_sync_re)
                sm_buffbypass_tx <= ST_BUFFBYPASS_TX_DONE;
            end

            // Assert the buffer bypass procedure done user indicator, and set the procedure error flag if the
            // synchronized TXPHALIGNDONE indicator is not high
            ST_BUFFBYPASS_TX_DONE: begin
              gtwiz_buffbypass_tx_done_out  <= 1'b1;
              gtwiz_buffbypass_tx_error_out <= ~gtwiz_buffbypass_tx_master_phaligndone_sync_int;
              sm_buffbypass_tx              <= ST_BUFFBYPASS_TX_IDLE;
            end

          endcase
        end
      end

    end
  end
  endgenerate


endmodule
`default_nettype wire

