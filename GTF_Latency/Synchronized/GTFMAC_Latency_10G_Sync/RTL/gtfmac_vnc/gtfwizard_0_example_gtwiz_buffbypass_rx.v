/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

// ***************************
// * DO NOT MODIFY THIS FILE *
// ***************************

`timescale 1ps/1ps

module gtfwizard_0_example_gtwiz_buffbypass_rx #(
  parameter COMMON_CLOCK = 0 //common clock
)( 

  // User interface ports
  input  wire gtwiz_rx_clk_in,
  input  wire gtwiz_rx_reset_in,
  input  wire gtwiz_rx_start_user_in,
  input  wire gtwiz_rx_resetdone_in,
  input  wire dmon_bad_align_in, //flag for bad alignment
  input  wire drp_reconfig_done_in, //flag for dynamic reconfig to auto mode
  input  wire workaround_bypass_in, //ctrl that sets module to auto mode when high
  input  wire force_bad_align_in, //ctrl for forcing a bad alignment in workaround mode (will not work in auto mode)
  output wire drp_reconfig_rdy_out, //flag to top level that module is ready for auto mode
  output wire drp_switch_am_out, //flag to switch to AM or MM
  output reg  gtwiz_rx_done_out  = 1'b0, //workaround complete flag
  output reg  gtwiz_rx_error_out = 1'b0, //not used currently    

  // Transceiver interface ports
  input  wire rxphaligndone_in,
  input  wire rxphalignerr_in,
  input  wire rxdlysresetdone_in,
  input  wire rxsyncout_in,
  input  wire rxsyncdone_in,
  output wire rxphdlyreset_out,
  output wire rxphalign_out,
  output wire rxphalignen_out,
  output wire rxphdlypd_out,
  output wire rxphovrden_out,
  output reg  rxdlysreset_out = 1'b0,
  output wire rxdlybypass_out,
  output wire rxdlyen_out,
  output wire rxdlyovrden_out,
  output wire rxsyncmode_out,
  output wire rxsyncallin_out,
  output wire rxsyncin_out,
  
  // Debug port FSM state
  output wire [2:0]  sm_buffbypass_rx_mm_out,
  output reg  [15:0] manual_cnt_out = 0,
  output reg         tx_rdy_out //common clock  

);

  localparam [2:0] ST_MM_BUFFBYPASS_RX_IDLE                 = 3'd0;
  localparam [2:0] ST_MM_BUFFBYPASS_RX_WAIT_DRP_RECONFIG    = 3'd1;
  localparam [2:0] ST_MM_BUFFBYPASS_RX_WAIT_RXDLYRESETDONE  = 3'd2;
  localparam [2:0] ST_MM_BUFFBYPASS_RX_WAIT_RXPHALIGNDONE   = 3'd3;
  localparam [2:0] ST_MM_BUFFBYPASS_RX_POLL_DMON            = 3'd4;
  localparam [2:0] ST_AM_BUFFBYPASS_RX_WAIT_DRP_RECONFIG    = 3'd5;
  localparam [2:0] ST_AM_BUFFBYPASS_RX_DEASSERT_RXDLYSRESET = 3'd6;
  localparam [2:0] ST_AM_BUFFBYPASS_RX_DONE                 = 3'd7;

  // Detect the rising edge of these various inputs for synchronization
  wire gtwiz_rx_resetdone_sync_int;
  reg  gtwiz_rx_resetdone_reg = 1'b0;
  reg  gtwiz_rx_start; //posedge for synced resetdone
  
  wire gtwiz_rx_reset_sync;
  
  wire gtwiz_rx_phaligndone_sync_int;
  reg  gtwiz_rx_phaligndone_reg; 
  reg  gtwiz_rx_phaligndone_posedge; //final posedge for phaligndone
  
  // Synchronize the buffer bypass completion output (RXSYNCDONE) into the local clock domain
  // and detect its rising edge for purposes of safe state machine transitions
  wire gtwiz_rx_syncdone_sync_int;
  reg  gtwiz_rx_syncdone_reg = 1'b0;
  reg  gtwiz_rx_syncdone_posedge; //posedge of syncdone synced version
  
  wire gtwiz_rx_phalignerr_sync_int;
  reg  gtwiz_rx_phalignerr_reg;
  reg  gtwiz_rx_phalignerr_posedge;
  
  wire gtwiz_rx_rxdlysresetdone_sync_int;
  reg  gtwiz_rx_rxdlysresetdone_reg; 
  reg  gtwiz_rx_rxdlysresetdone_posedge; //final posedge for rxdlysresetdone
  
  // Synchronize the drp_reconfig_done_in into the local clock domain
  // Detect the rising edge of the drp_reconfig_done_in re-synchronized input.
  wire gtwiz_rx_drp_reconfig_done_sync_int;
  reg  gtwiz_rx_drp_reconfig_done_reg; 
  reg  gtwiz_rx_drp_reconfig_done_posedge; //final posedge for drp_reconfig

  wire workaround_bypass_sync;
  
  // Synchronize the dmon_bad_align_in into the local clock domain
  wire gtwiz_rx_dmon_bad_align_sync;
  
  wire force_bad_align_sync;
  
  xpm_cdc_sync_rst # (
    .DEST_SYNC_FF (4),
    .INIT         (0) 
  ) bit_synchronizer_phalignerr_inst (
    .dest_clk (gtwiz_rx_clk_in),
    .src_rst  (rxphalignerr_in),
    .dest_rst (gtwiz_rx_phalignerr_sync_int)
  );
  
  xpm_cdc_sync_rst # (
    .DEST_SYNC_FF (4),
    .INIT         (0) 
  ) reset_synchronizer_resetdone_inst (
    .dest_clk (gtwiz_rx_clk_in),
    .src_rst  (gtwiz_rx_resetdone_in),
    .dest_rst (gtwiz_rx_resetdone_sync_int)
  );
  
  xpm_cdc_sync_rst # (
    .DEST_SYNC_FF (4),
    .INIT          (0)
  ) bit_synchronizer_phaligndone_inst (
    .dest_clk (gtwiz_rx_clk_in),
    .src_rst  (rxphaligndone_in),
    .dest_rst (gtwiz_rx_phaligndone_sync_int)
  );

  xpm_cdc_sync_rst # (
    .DEST_SYNC_FF (4),
    .INIT          (0)
  ) bit_synchronizer_syncdone_inst (
    .dest_clk (gtwiz_rx_clk_in),
    .src_rst  (rxsyncdone_in),
    .dest_rst (gtwiz_rx_syncdone_sync_int)
  );
 
  // Synchronize the input reset(derived from rxresetdone) into the local clock domain
  xpm_cdc_sync_rst # (
    .DEST_SYNC_FF (4),
    .INIT         (0)
  ) bit_synchronizer_rx_reset_in_inst (
    .dest_clk (gtwiz_rx_clk_in),
    .src_rst  (gtwiz_rx_reset_in),
    .dest_rst (gtwiz_rx_reset_sync)
  );

  xpm_cdc_sync_rst # (
    .DEST_SYNC_FF (4),
    .INIT         (0)
  ) bit_synchronizer_drp_reconfig_done_inst (
    .dest_clk (gtwiz_rx_clk_in),
    .src_rst  (drp_reconfig_done_in),
    .dest_rst (gtwiz_rx_drp_reconfig_done_sync_int)
  );
  
  xpm_cdc_sync_rst # (
    .DEST_SYNC_FF (4),
    .INIT          (0)
  ) bit_synchronizer_dmon_bad_align_inst (
    .dest_clk (gtwiz_rx_clk_in),
    .src_rst  (dmon_bad_align_in),
    .dest_rst (gtwiz_rx_dmon_bad_align_sync)
  );
  
  // Synchronize the rxdlysresetdone_in into the local clock domain
  // Detect the rising edge of the rxdlysresetdone re-synchronized input.
  xpm_cdc_sync_rst # (
    .DEST_SYNC_FF (4),
    .INIT          (0)
  ) bit_synchronizer_rxdlysresetdone_inst (
    .dest_clk (gtwiz_rx_clk_in),
    .src_rst  (rxdlysresetdone_in),
    .dest_rst (gtwiz_rx_rxdlysresetdone_sync_int)
  );

  xpm_cdc_sync_rst # (
    .DEST_SYNC_FF (4),
    .INIT          (0)
  ) bit_synchronizer_workaroundbypass_inst (
    .dest_clk (gtwiz_rx_clk_in),
    .src_rst  (workaround_bypass_in),
    .dest_rst (workaround_bypass_sync)
  );
  
  xpm_cdc_sync_rst # (
    .DEST_SYNC_FF (4),
    .INIT          (0)
  ) bit_synchronizer_forcebadalign_inst (
    .dest_clk (gtwiz_rx_clk_in),
    .src_rst  (force_bad_align_in),
    .dest_rst (force_bad_align_sync)
  );

  always @(posedge gtwiz_rx_clk_in) begin
    if (gtwiz_rx_reset_sync) begin
      gtwiz_rx_resetdone_reg <= 1'b0; 
      gtwiz_rx_rxdlysresetdone_reg <= 1'b0;
      gtwiz_rx_phaligndone_reg <= 1'b0;
      gtwiz_rx_drp_reconfig_done_reg <= 1'b0;
      gtwiz_rx_syncdone_reg <= 1'b0; //originally was not set to 0
      gtwiz_rx_phalignerr_reg <= 1'b0;
	  
      gtwiz_rx_start <= 1'b0;
      gtwiz_rx_rxdlysresetdone_posedge <= 1'b0;
      gtwiz_rx_phaligndone_posedge <= 1'b0;
      gtwiz_rx_drp_reconfig_done_posedge <= 1'b0;
      gtwiz_rx_syncdone_posedge <= 1'b0;
      gtwiz_rx_phalignerr_posedge <= 1'b0;
	  
    end else begin
      gtwiz_rx_resetdone_reg         <= gtwiz_rx_resetdone_sync_int; 
      gtwiz_rx_rxdlysresetdone_reg   <= gtwiz_rx_rxdlysresetdone_sync_int;
      gtwiz_rx_phaligndone_reg       <= gtwiz_rx_phaligndone_sync_int;
      gtwiz_rx_drp_reconfig_done_reg <= gtwiz_rx_drp_reconfig_done_sync_int;
      gtwiz_rx_syncdone_reg          <= gtwiz_rx_syncdone_sync_int;
      gtwiz_rx_phaligndone_reg       <= gtwiz_rx_phaligndone_sync_int;
	  
      gtwiz_rx_start                     <= (gtwiz_rx_resetdone_sync_int && ~gtwiz_rx_resetdone_reg) || gtwiz_rx_start_user_in;
      gtwiz_rx_rxdlysresetdone_posedge   <= gtwiz_rx_rxdlysresetdone_sync_int && ~gtwiz_rx_rxdlysresetdone_reg;
      gtwiz_rx_phaligndone_posedge       <= gtwiz_rx_phaligndone_sync_int && ~gtwiz_rx_phaligndone_reg;
      gtwiz_rx_drp_reconfig_done_posedge <= gtwiz_rx_drp_reconfig_done_sync_int && ~gtwiz_rx_drp_reconfig_done_reg;
      gtwiz_rx_syncdone_posedge          <= gtwiz_rx_syncdone_sync_int && ~gtwiz_rx_syncdone_reg;
      gtwiz_rx_phalignerr_posedge        <= gtwiz_rx_phalignerr_sync_int && ~gtwiz_rx_phalignerr_reg;
    end
  end

  reg rxphdlyreset;
  reg rxphalign;
  reg rxphalignen;
  reg rxdlybypass;
  reg rxdlyen;
  reg rxdlysreset;
  reg drp_reconfig_rdy;
  reg drp_switch_am;
  
  reg [2:0] sm_buffbypass_rx_mm   = ST_MM_BUFFBYPASS_RX_IDLE; //default state
  assign sm_buffbypass_rx_mm_out  = sm_buffbypass_rx_mm;
  assign rxphdlyreset_out         = rxphdlyreset;
  assign rxphalign_out            = rxphalign;
  assign rxphalignen_out          = rxphalignen;
  assign rxphdlypd_out            = 1'b0; //tie low for bypass mode
  assign rxphovrden_out           = 1'b0; //tie off
  assign rxdlybypass_out          = rxdlybypass; 
  assign rxdlyen_out              = rxdlyen; //this is not enabled intentionally due to MM workaround
  assign rxdlyovrden_out          = 1'b0; //overides rx delay
  assign rxsyncmode_out           = 1'b1; //Auto mode only
  assign rxsyncallin_out          = rxphaligndone_in; //Auto mode only
  assign rxsyncin_out             = 1'b0; //Auto mode only
  assign drp_reconfig_rdy_out     = drp_reconfig_rdy;
  assign drp_switch_am_out        = drp_switch_am;

  //begin manual mode state machine
  always @(posedge gtwiz_rx_clk_in) begin
    if (gtwiz_rx_reset_sync) begin
      //default signals here
      gtwiz_rx_done_out   <= 1'b0;
      gtwiz_rx_error_out  <= 1'b0;
      rxphdlyreset        <= 1'b0;
      rxdlybypass         <= 1'b0;
      rxphalign           <= 1'b0;
      rxphalignen         <= 1'b0;
      rxdlysreset_out     <= 1'b0;
      rxdlyen             <= 1'b0; //Not enabled for MM Mode workaround
      drp_reconfig_rdy    <= 1'b0;
      drp_switch_am       <= 1'b0; //set up for switch to mm
      manual_cnt_out      <= 0;
      tx_rdy_out          <= 1'b0; //common clock
      sm_buffbypass_rx_mm <= ST_MM_BUFFBYPASS_RX_IDLE; //send to Auto Mode if bypass input high
    end
    
    else begin
      case(sm_buffbypass_rx_mm)
        default: begin
          if (gtwiz_rx_start) begin
            gtwiz_rx_done_out   <= 1'b0;
            gtwiz_rx_error_out  <= 1'b0;
            rxphdlyreset        <= 1'b0;
            rxdlybypass         <= 1'b0;
            drp_reconfig_rdy    <= 1'b0;
            rxphalignen         <= 1'b1;
            manual_cnt_out      <= 0;
            drp_switch_am       <= 1'b0; //set up for switch to mm
            tx_rdy_out          <= 1'b0; //common clock
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
          if (gtwiz_rx_drp_reconfig_done_posedge) begin //wait for GTF drp reconfig posedge
            rxdlysreset_out     <= 1'b1;
            drp_reconfig_rdy    <= 1'b0;
            sm_buffbypass_rx_mm <= ST_MM_BUFFBYPASS_RX_WAIT_RXDLYRESETDONE; //continue normal MM sequence
          end
          else 
            drp_reconfig_rdy <= 1'b1; 
        end

        ST_MM_BUFFBYPASS_RX_WAIT_RXDLYRESETDONE: begin
          if (gtwiz_rx_rxdlysresetdone_posedge) begin
            rxdlysreset_out     <= 1'b0;
            rxphalign           <= 1'b1;
            sm_buffbypass_rx_mm <= ST_MM_BUFFBYPASS_RX_WAIT_RXPHALIGNDONE; 
          end 
          else begin
            drp_reconfig_rdy    <= 1'b0;
            rxdlysreset_out     <= 1'b1;
            rxphalign           <= 1'b0;
            sm_buffbypass_rx_mm <= ST_MM_BUFFBYPASS_RX_WAIT_RXDLYRESETDONE;
          end
        end

        ST_MM_BUFFBYPASS_RX_WAIT_RXPHALIGNDONE: begin
          if (gtwiz_rx_phaligndone_posedge) begin
            rxphalign           <= 1'b0;
            sm_buffbypass_rx_mm <= ST_MM_BUFFBYPASS_RX_POLL_DMON;
          end
          else if (gtwiz_rx_phalignerr_posedge) begin
            manual_cnt_out      <= manual_cnt_out + 1;
            rxphalign           <= 1'b0;
            sm_buffbypass_rx_mm <= ST_MM_BUFFBYPASS_RX_WAIT_RXDLYRESETDONE;
          end
          else begin //EG redundant clause
            rxphalign           <= 1'b1;
            sm_buffbypass_rx_mm <= ST_MM_BUFFBYPASS_RX_WAIT_RXPHALIGNDONE;
          end
        end

        ST_MM_BUFFBYPASS_RX_POLL_DMON: begin
          if (gtwiz_rx_dmon_bad_align_sync != force_bad_align_sync || workaround_bypass_sync) begin //bad align, continue to auto mode
            gtwiz_rx_done_out             <= 1'b0;
            gtwiz_rx_error_out            <= 1'b0;
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
          else begin
            if (manual_cnt_out > 0) begin
            end
            manual_cnt_out       <= manual_cnt_out + 1;
            sm_buffbypass_rx_mm  <= ST_MM_BUFFBYPASS_RX_WAIT_RXDLYRESETDONE; //rerun manual mode
          end
        end

        ST_AM_BUFFBYPASS_RX_WAIT_DRP_RECONFIG: begin
          if (gtwiz_rx_drp_reconfig_done_posedge) begin //wait for GTF drp reconfig posedge (equiv to ST_BUFFBYPASS_RX_IDLE)
            rxdlysreset_out     <= 1'b1;
            drp_reconfig_rdy    <= 1'b0;
            tx_rdy_out          <= 1'b1; //common clock
            sm_buffbypass_rx_mm <= ST_AM_BUFFBYPASS_RX_DEASSERT_RXDLYSRESET;
          end
        end

        ST_AM_BUFFBYPASS_RX_DEASSERT_RXDLYSRESET: begin //equiv to ST_BUFFBYPASS_RX_DEASSERT_RXDLYSRESET + ST_BUFFBYPASS_RX_WAIT_RXSYNCDONE
          rxdlysreset_out <= 1'b0;
          tx_rdy_out      <= 1'b0; //common clock
          if (gtwiz_rx_syncdone_posedge)
            sm_buffbypass_rx_mm <= ST_AM_BUFFBYPASS_RX_DONE;
        end

        ST_AM_BUFFBYPASS_RX_DONE: begin //equiv to ST_BUFFBYPASS_RX_DONE
          gtwiz_rx_done_out   <= 1'b1;
          gtwiz_rx_error_out  <= ~gtwiz_rx_phaligndone_sync_int || (gtwiz_rx_dmon_bad_align_sync != force_bad_align_sync);
          sm_buffbypass_rx_mm <= ST_MM_BUFFBYPASS_RX_IDLE;
        end
      endcase
    end
  end  
endmodule
