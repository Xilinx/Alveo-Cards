/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------


`timescale 1ps/1ps

`default_nettype none
(* DowngradeIPIdentifiedWarnings="yes" *)
module gtfwizard_raw_gtwiz_buffbypass_rx #(
  parameter 		COMMON_CLOCK               = "true",
  parameter integer P_BUFFER_BYPASS_MODE       = 0,
  parameter integer P_TOTAL_NUMBER_OF_CHANNELS = 1,
  parameter integer P_MASTER_CHANNEL_POINTER   = 0

)(

  // User interface ports
  input  wire gtwiz_buffbypass_rx_clk_in,
  input  wire gtwiz_buffbypass_rx_reset_in,
  input  wire gtwiz_buffbypass_rx_start_user_in,
  input  wire gtwiz_buffbypass_rx_resetdone_in,
  input  wire dmon_bad_align_in, //flag for bad alignment
  input  wire drp_reconfig_done_in, //flag for dynamic reconfig to auto mode
  input  wire workaround_bypass_in, //ctrl that sets module to auto mode when high
  input  wire force_bad_align_in, //ctrl for forcing a bad alignment in workaround mode (will not work in auto mode)
  output wire drp_reconfig_rdy_out, //flag to top level that module is ready for auto mode
  output wire drp_switch_am_out, //flag to switch to AM or MM
  input  wire gtwiz_buffbypass_rx_phdlypd_in,
  output reg  gtwiz_buffbypass_rx_done_out  = 1'b0, //workaround complete flag
  output reg  gtwiz_buffbypass_rx_error_out = 1'b0, //not used currently 

  // Transceiver interface ports
  input  wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] rxphaligndone_in,
  input  wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] rxdlysresetdone_in,
  input  wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] rxsyncout_in,
  input  wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] rxsyncdone_in,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] rxphdlyreset_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] rxphalign_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] rxphalignen_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] rxphdlypd_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] rxphovrden_out,
  output reg  [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] rxdlysreset_out = {P_TOTAL_NUMBER_OF_CHANNELS{1'b0}},
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] rxdlybypass_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] rxdlyen_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] rxdlyovrden_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] rxsyncmode_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] rxsyncallin_out,
  output wire [(P_TOTAL_NUMBER_OF_CHANNELS-1):0] rxsyncin_out,
  
  // Debug port FSM state
  output wire [2:0] sm_buffbypass_rx_mm_out,
  
  output reg        tx_rdy_out //common clock  

);

reg i_tx_rdy_out;
generate
if ( COMMON_CLOCK == "true") begin
  always @* tx_rdy_out = i_tx_rdy_out;  
end else begin
  always @* tx_rdy_out = 'h0;  
end
endgenerate

  localparam [2:0] ST_MM_BUFFBYPASS_RX_IDLE                 = 3'd0;
  localparam [2:0] ST_MM_BUFFBYPASS_RX_WAIT_DRP_RECONFIG    = 3'd1;
  localparam [2:0] ST_MM_BUFFBYPASS_RX_WAIT_RXDLYRESETDONE  = 3'd2;
  localparam [2:0] ST_MM_BUFFBYPASS_RX_WAIT_RXPHALIGNDONE   = 3'd3;
  localparam [2:0] ST_MM_BUFFBYPASS_RX_POLL_DMON            = 3'd4;
  localparam [2:0] ST_AM_BUFFBYPASS_RX_WAIT_DRP_RECONFIG    = 3'd5;
  localparam [2:0] ST_AM_BUFFBYPASS_RX_DEASSERT_RXDLYSRESET = 3'd6;
  localparam [2:0] ST_AM_BUFFBYPASS_RX_DONE                 = 3'd7;

  // Detect the rising edge of these various inputs for synchronization
  wire gtwiz_buffbypass_rx_resetdone_sync_int;
  reg  gtwiz_buffbypass_rx_resetdone_reg = 1'b0;
  wire gtwiz_buffbypass_rx_start_int; //posedge for synced resetdone
  wire gtwiz_buffbypass_rx_reset_sync;
  reg  gtwiz_buffbypass_rx_master_phaligndone_reg; 
  wire gtwiz_buffbypass_rx_master_phaligndone_posedge; //final posedge for phaligndone
  
  // Synchronize the master channel's buffer bypass completion output (RXSYNCDONE) into the local clock domain
  // and detect its rising edge for purposes of safe state machine transitions
  reg  gtwiz_buffbypass_rx_master_syncdone_sync_reg = 1'b0;
  wire gtwiz_buffbypass_rx_master_syncdone_sync_int;
  wire gtwiz_buffbypass_rx_master_syncdone_sync_re; //posedge of syncdone synced version

  wire gtwiz_buffbypass_rx_master_phaligndone_sync_int;
  wire workaround_bypass_sync;
  
  // Synchronize the drp_reconfig_done_in into the local clock domain
  // Detect the rising edge of the drp_reconfig_done_in re-synchronized input.
  wire gtwiz_buffbypass_rx_drp_reconfig_done_sync;
  reg  gtwiz_buffbypass_rx_drp_reconfig_done_reg; 
  wire gtwiz_buffbypass_rx_drp_reconfig_done_posedge; //final posedge for drp_reconfig

  // Synchronize the dmon_bad_align_in into the local clock domain
  wire gtwiz_buffbypass_rx_dmon_bad_align_sync;

  wire gtwiz_buffbypass_rx_master_rxdlysresetdone_sync_int;
  reg  gtwiz_buffbypass_rx_master_rxdlysresetdone_reg; 
  wire gtwiz_buffbypass_rx_master_rxdlysresetdone_posedge; //final posedge for rxdlysresetdone
  
  wire force_bad_align_sync;

  xpm_cdc_sync_rst # (
    .DEST_SYNC_FF (4),
    .INIT         (0) 
  ) reset_synchronizer_resetdone_inst (
    .dest_clk (gtwiz_buffbypass_rx_clk_in),
    .src_rst  (gtwiz_buffbypass_rx_resetdone_in),
    .dest_rst (gtwiz_buffbypass_rx_resetdone_sync_int)
  );
  
  xpm_cdc_sync_rst # (
    .DEST_SYNC_FF (4),
    .INIT          (0)
  ) bit_synchronizer_masterphaligndone_inst (
    .dest_clk (gtwiz_buffbypass_rx_clk_in),
    .src_rst  (rxphaligndone_in[P_MASTER_CHANNEL_POINTER]),
    .dest_rst (gtwiz_buffbypass_rx_master_phaligndone_sync_int)
  );

  xpm_cdc_sync_rst # (
    .DEST_SYNC_FF (4),
    .INIT          (0)
  ) bit_synchronizer_mastersyncdone_inst (
    .dest_clk (gtwiz_buffbypass_rx_clk_in),
    .src_rst  (rxsyncdone_in[P_MASTER_CHANNEL_POINTER]),
    .dest_rst (gtwiz_buffbypass_rx_master_syncdone_sync_int)
  );
 
  // Synchronize the input reset(derived from rxresetdone) into the local clock domain
  xpm_cdc_sync_rst # (
    .DEST_SYNC_FF (4),
    .INIT         (0)
  ) bit_synchronizer_rx_reset_in_inst (
    .dest_clk (gtwiz_buffbypass_rx_clk_in),
    .src_rst  (gtwiz_buffbypass_rx_reset_in),
    .dest_rst (gtwiz_buffbypass_rx_reset_sync)
  );

  xpm_cdc_sync_rst # (
    .DEST_SYNC_FF (4),
    .INIT         (0)
  ) bit_synchronizer_drp_reconfig_done_inst (
    .dest_clk (gtwiz_buffbypass_rx_clk_in),
    .src_rst  (drp_reconfig_done_in),
    .dest_rst (gtwiz_buffbypass_rx_drp_reconfig_done_sync)
  );
  
  xpm_cdc_sync_rst # (
    .DEST_SYNC_FF (4),
    .INIT          (0)
  ) bit_synchronizer_dmon_bad_align_inst (
    .dest_clk (gtwiz_buffbypass_rx_clk_in),
    .src_rst  (dmon_bad_align_in),
    .dest_rst (gtwiz_buffbypass_rx_dmon_bad_align_sync)
  );
  
  // Synchronize the rxdlysresetdone_in into the local clock domain
  // Detect the rising edge of the rxdlysresetdone re-synchronized input.
  xpm_cdc_sync_rst # (
    .DEST_SYNC_FF (4),
    .INIT          (0)
  ) bit_synchronizer_rxdlysresetdone_inst (
    .dest_clk (gtwiz_buffbypass_rx_clk_in),
    .src_rst  (rxdlysresetdone_in),
    .dest_rst (gtwiz_buffbypass_rx_master_rxdlysresetdone_sync_int)
  );

  xpm_cdc_sync_rst # (
    .DEST_SYNC_FF (4),
    .INIT          (0)
  ) bit_synchronizer_workaroundbypass_inst (
    .dest_clk (gtwiz_buffbypass_rx_clk_in),
    .src_rst  (workaround_bypass_in),
    .dest_rst (workaround_bypass_sync)
  );
  
  xpm_cdc_sync_rst # (
    .DEST_SYNC_FF (4),
    .INIT          (0)
  ) bit_synchronizer_forcebadalign_inst (
    .dest_clk (gtwiz_buffbypass_rx_clk_in),
    .src_rst  (force_bad_align_in),
    .dest_rst (force_bad_align_sync)
  );

  always @(posedge gtwiz_buffbypass_rx_clk_in) begin
    if (gtwiz_buffbypass_rx_reset_sync) begin
      gtwiz_buffbypass_rx_resetdone_reg <= 1'b0; 
      gtwiz_buffbypass_rx_master_rxdlysresetdone_reg <= 1'b0;
      gtwiz_buffbypass_rx_master_phaligndone_reg <= 1'b0;
      gtwiz_buffbypass_rx_drp_reconfig_done_reg <= 1'b0;
      gtwiz_buffbypass_rx_master_syncdone_sync_reg <= 1'b0; //originally was not set to 0
    end else begin
      gtwiz_buffbypass_rx_resetdone_reg <= gtwiz_buffbypass_rx_resetdone_sync_int; 
      gtwiz_buffbypass_rx_master_rxdlysresetdone_reg <= gtwiz_buffbypass_rx_master_rxdlysresetdone_sync_int;
      gtwiz_buffbypass_rx_master_phaligndone_reg <= gtwiz_buffbypass_rx_master_phaligndone_sync_int;
      gtwiz_buffbypass_rx_drp_reconfig_done_reg <= gtwiz_buffbypass_rx_drp_reconfig_done_sync;
      gtwiz_buffbypass_rx_master_syncdone_sync_reg <= gtwiz_buffbypass_rx_master_syncdone_sync_int;
    end
  end

  assign gtwiz_buffbypass_rx_start_int = (gtwiz_buffbypass_rx_resetdone_sync_int && ~gtwiz_buffbypass_rx_resetdone_reg) || gtwiz_buffbypass_rx_start_user_in;
  assign gtwiz_buffbypass_rx_master_rxdlysresetdone_posedge = gtwiz_buffbypass_rx_master_rxdlysresetdone_sync_int && ~gtwiz_buffbypass_rx_master_rxdlysresetdone_reg;
  assign gtwiz_buffbypass_rx_master_phaligndone_posedge = gtwiz_buffbypass_rx_master_phaligndone_sync_int && ~gtwiz_buffbypass_rx_master_phaligndone_reg;
  assign gtwiz_buffbypass_rx_drp_reconfig_done_posedge = gtwiz_buffbypass_rx_drp_reconfig_done_sync && ~gtwiz_buffbypass_rx_drp_reconfig_done_reg;
  assign gtwiz_buffbypass_rx_master_syncdone_sync_re = gtwiz_buffbypass_rx_master_syncdone_sync_int && ~gtwiz_buffbypass_rx_master_syncdone_sync_reg;
  
  reg rxphdlyreset;
  reg rxphalign;
  reg rxphalignen;
  reg rxdlybypass;
  reg rxdlyen;
  reg rxdlysreset;
  reg drp_reconfig_rdy;
  reg drp_switch_am;
  
  reg [2:0] sm_buffbypass_rx_mm = ST_MM_BUFFBYPASS_RX_IDLE; //default state
  assign sm_buffbypass_rx_mm_out  = sm_buffbypass_rx_mm;
  assign rxphdlyreset_out     = rxphdlyreset;
  assign rxphalign_out        = rxphalign;
  assign rxphalignen_out      = rxphalignen;
  assign rxphdlypd_out        = gtwiz_buffbypass_rx_phdlypd_in;
  assign rxphovrden_out       = 1'b0; //tie off
  assign rxdlybypass_out      = rxdlybypass; 
  assign rxdlyen_out          = rxdlyen; //this is not enabled intentionally due to MM workaround
  assign rxdlyovrden_out      = 1'b0; //overides rx delay
  assign rxsyncmode_out       = 1'b1; //Auto mode only
  assign rxsyncallin_out      = rxphaligndone_in; //Auto mode only
  assign rxsyncin_out         = 1'b0; //Auto mode only
  assign drp_reconfig_rdy_out = drp_reconfig_rdy;
  assign drp_switch_am_out    = drp_switch_am;

  //begin manual mode state machine
  always @(posedge gtwiz_buffbypass_rx_clk_in) begin
    if (gtwiz_buffbypass_rx_reset_sync) begin
      //default signals here
      gtwiz_buffbypass_rx_done_out  <= 1'b0;
      gtwiz_buffbypass_rx_error_out <= 1'b0;
      rxphdlyreset        <= 1'b0;
      rxdlybypass         <= 1'b0;
      rxphalign           <= 1'b0;
      rxphalignen         <= 1'b0;
      rxdlysreset_out     <= 1'b0;
      rxdlyen             <= 1'b0; //Not enabled for MM Mode workaround
      drp_reconfig_rdy    <= 1'b0;
      drp_switch_am       <= 1'b0; //set up for switch to mm
      i_tx_rdy_out        <= 1'b0; //common clock
      sm_buffbypass_rx_mm <= ST_MM_BUFFBYPASS_RX_IDLE; //send to Auto Mode if bypass input high
    end
    else begin
      case(sm_buffbypass_rx_mm)
        default: begin
          if (gtwiz_buffbypass_rx_start_int) begin
            rxphdlyreset     <= 1'b0;
            rxdlybypass      <= 1'b0;
            drp_reconfig_rdy <= 1'b0;
            rxphalignen         <= 1'b1;
            drp_switch_am       <= 1'b0; //set up for switch to mm
            gtwiz_buffbypass_rx_done_out  <= 1'b0; 
            gtwiz_buffbypass_rx_error_out <= 1'b0;
            i_tx_rdy_out        <= 1'b0; //common clock
            sm_buffbypass_rx_mm <= ST_MM_BUFFBYPASS_RX_WAIT_DRP_RECONFIG; 
            
            //(last assignment wins) go to auto mode instead 
            if(workaround_bypass_sync) begin
              rxphalignen         <= 1'b0;
              drp_switch_am       <= 1'b1; //set up for switch to am
              sm_buffbypass_rx_mm <= ST_MM_BUFFBYPASS_RX_POLL_DMON;
            end
          end
        end

        ST_MM_BUFFBYPASS_RX_WAIT_DRP_RECONFIG: begin
          if (gtwiz_buffbypass_rx_drp_reconfig_done_posedge) begin //wait for GTF drp reconfig posedge
            rxdlysreset_out     <= 1'b1;
            drp_reconfig_rdy    <= 1'b0;
            sm_buffbypass_rx_mm <= ST_MM_BUFFBYPASS_RX_WAIT_RXDLYRESETDONE; //continue normal MM sequence
          end
          else 
            drp_reconfig_rdy <= 1'b1; 
        end

        ST_MM_BUFFBYPASS_RX_WAIT_RXDLYRESETDONE: begin
          if (gtwiz_buffbypass_rx_master_rxdlysresetdone_posedge) begin
            rxdlysreset_out <= 1'b0;
            rxphalign <= 1'b1;
            sm_buffbypass_rx_mm <= ST_MM_BUFFBYPASS_RX_WAIT_RXPHALIGNDONE; 
          end 
          else begin
          drp_reconfig_rdy <= 1'b0;
          rxdlysreset_out  <= 1'b1;
          rxphalign        <= 1'b0;
          sm_buffbypass_rx_mm <= ST_MM_BUFFBYPASS_RX_WAIT_RXDLYRESETDONE;
          end
        end

        ST_MM_BUFFBYPASS_RX_WAIT_RXPHALIGNDONE: begin
          if (gtwiz_buffbypass_rx_master_phaligndone_posedge) begin
            // rxdlyen <= 1'b1; //dont use for MM workaround
            rxphalign <= 1'b0;
            sm_buffbypass_rx_mm <= ST_MM_BUFFBYPASS_RX_POLL_DMON;
          end
          else begin
            rxphalign <= 1'b1;
            sm_buffbypass_rx_mm <= ST_MM_BUFFBYPASS_RX_WAIT_RXPHALIGNDONE;
          end
        end

        ST_MM_BUFFBYPASS_RX_POLL_DMON: begin
          if (gtwiz_buffbypass_rx_dmon_bad_align_sync != force_bad_align_sync || workaround_bypass_sync) begin //bad align, continue to auto mode
            gtwiz_buffbypass_rx_done_out  <= 1'b0;
            gtwiz_buffbypass_rx_error_out <= 1'b0;
            rxdlysreset_out               <= 1'b0;
            rxphdlyreset                  <= 1'b0;
            rxphalign                     <= 1'b0;
            rxphalignen                   <= 1'b0;
            rxdlybypass                   <= 1'b0;
            rxdlyen                       <= 1'b0;
            drp_switch_am                 <= 1'b1; //set up for switch to am
            drp_reconfig_rdy              <= 1'b1;
            sm_buffbypass_rx_mm           <= ST_AM_BUFFBYPASS_RX_WAIT_DRP_RECONFIG;
          end
          else 
            sm_buffbypass_rx_mm <= ST_MM_BUFFBYPASS_RX_WAIT_RXDLYRESETDONE; //rerun manual mode
        end

        ST_AM_BUFFBYPASS_RX_WAIT_DRP_RECONFIG: begin
          if (gtwiz_buffbypass_rx_drp_reconfig_done_posedge) begin //wait for GTF drp reconfig posedge (equiv to ST_BUFFBYPASS_RX_IDLE)
            rxdlysreset_out     <= 1'b1;
            drp_reconfig_rdy    <= 1'b0;
            i_tx_rdy_out        <= 1'b1; //common clock
            sm_buffbypass_rx_mm <= ST_AM_BUFFBYPASS_RX_DEASSERT_RXDLYSRESET;
          end
        end

        ST_AM_BUFFBYPASS_RX_DEASSERT_RXDLYSRESET: begin //equiv to ST_BUFFBYPASS_RX_DEASSERT_RXDLYSRESET + ST_BUFFBYPASS_RX_WAIT_RXSYNCDONE
          rxdlysreset_out <= 1'b0;
          i_tx_rdy_out    <= 1'b0; //common clock
          if (gtwiz_buffbypass_rx_master_syncdone_sync_re)
            sm_buffbypass_rx_mm <= ST_AM_BUFFBYPASS_RX_DONE;
        end

        ST_AM_BUFFBYPASS_RX_DONE: begin //equiv to ST_BUFFBYPASS_RX_DONE
          gtwiz_buffbypass_rx_done_out  <= 1'b1;
          gtwiz_buffbypass_rx_error_out <= ~gtwiz_buffbypass_rx_master_phaligndone_sync_int;
          sm_buffbypass_rx_mm <= ST_MM_BUFFBYPASS_RX_IDLE;
        end
      endcase
    end
  end  
endmodule
`default_nettype wire


