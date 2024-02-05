/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

`timescale 1ps/1ps

module gtfwizard_0_example_gtwiz_drp_align_switch (
  input  wire       freerun_clk_in,
  input  wire       gtwiz_buffbypass_rx_reset_in,
  input  wire       AM_switch_in,
  input  wire       drp_reconfig_rdy_in,
  input  wire       drprdy_in,
  input  wire [15:0] drpdo_in,
  output reg        drp_reconfig_done_out,
  output reg        drpen_out,
  output reg        drpwe_out,
  output reg [9:0]  drpaddr_out, 
  output reg [15:0] drpdi_out
); 

  localparam [2:0] ST_BUFFBYPASS_RX_DRP_IDLE                   = 3'd0;
  localparam [2:0] ST_BUFFBYPASS_RX_DRP_START_RD               = 3'd1;
  localparam [2:0] ST_BUFFBYPASS_RX_DRP_WAIT_RDY_RD            = 3'd2;
  localparam [2:0] ST_BUFFBYPASS_RX_DRP_VAL_CHK                = 3'd3;
  localparam [2:0] ST_BUFFBYPASS_RX_DRP_START_WR               = 3'd4;
  localparam [2:0] ST_BUFFBYPASS_RX_DRP_WAIT_RDY_WR            = 3'd5;
  localparam [2:0] ST_BUFFBYPASS_RX_DRP_WAIT_RCFG_RDY_DEASSERT = 3'd6;
  
  reg [2:0]  sm_buffbypass_rx_drp = ST_BUFFBYPASS_RX_DRP_IDLE;
  reg [15:0] data_reg = 16'h0000;
  

  always @(posedge freerun_clk_in) begin
    if (gtwiz_buffbypass_rx_reset_in) begin
      //default signals here
      drp_reconfig_done_out    <= 1'b0; 
      drpen_out                <= 1'b0;
      drpwe_out                <= 1'b0;
      drpaddr_out              <= 10'h000; 
      drpdi_out                <= 16'h0000;
      data_reg                <= 16'h0000;
      sm_buffbypass_rx_drp <= ST_BUFFBYPASS_RX_DRP_IDLE;
    end
    
    else begin
      case (sm_buffbypass_rx_drp)
        default: begin //initialize regs
          drp_reconfig_done_out    <= 1'b0;
          drpen_out                <= 1'b0;
          drpwe_out                <= 1'b0;
          drpaddr_out              <= 10'h000; 
          drpdi_out                <= 16'h0000;
          data_reg                <= 16'h0000;
          if (drp_reconfig_rdy_in) begin //wait for rcfg request from buffbypass_rx
            sm_buffbypass_rx_drp <= ST_BUFFBYPASS_RX_DRP_START_RD;
          end
        end
		
        ST_BUFFBYPASS_RX_DRP_START_RD: begin //read RXSYNC_OVRD value
          drpen_out            <= 1'b1;
          drpwe_out            <= 1'b0;
          drpaddr_out          <= 10'h8a; //RXSYNC_OVRD address
          sm_buffbypass_rx_drp <= ST_BUFFBYPASS_RX_DRP_WAIT_RDY_RD;
        end

        ST_BUFFBYPASS_RX_DRP_WAIT_RDY_RD: begin //wait for drp read to finish
          drpen_out               <= 1'b0;
          drpwe_out               <= 1'b0;
          drpaddr_out             <= 10'h00;
          if (drprdy_in) begin
            data_reg              <= drpdo_in;
            sm_buffbypass_rx_drp  <= ST_BUFFBYPASS_RX_DRP_VAL_CHK;
          end
        end

        ST_BUFFBYPASS_RX_DRP_VAL_CHK: begin //check if already in desired mode, skip write if so
          if (data_reg[14] != AM_switch_in) begin
            drp_reconfig_done_out <= 1'b1;
            sm_buffbypass_rx_drp  <= ST_BUFFBYPASS_RX_DRP_WAIT_RCFG_RDY_DEASSERT;
          end
          else begin
            data_reg[14]          <= ~data_reg[14]; //switch RXSYNC_OVRD value
            sm_buffbypass_rx_drp  <= ST_BUFFBYPASS_RX_DRP_START_WR;
          end
        end

        ST_BUFFBYPASS_RX_DRP_START_WR: begin //initiate drp write for AM or MM
          drpen_out               <= 1'b1;
          drpwe_out               <= 1'b1;
          drpaddr_out             <= 10'h8a; //RXSYNC_OVRD address
          drpdi_out               <= data_reg;
          sm_buffbypass_rx_drp    <= ST_BUFFBYPASS_RX_DRP_WAIT_RDY_WR;
        end

        ST_BUFFBYPASS_RX_DRP_WAIT_RDY_WR: begin
          drpen_out               <= 1'b0;
          drpwe_out               <= 1'b0;
          drpaddr_out             <= 10'h00; 
          drpdi_out               <= 16'h0000;
          if (drprdy_in) begin
            drp_reconfig_done_out <= 1'b1;
            sm_buffbypass_rx_drp  <= ST_BUFFBYPASS_RX_DRP_WAIT_RCFG_RDY_DEASSERT;
          end
        end
        
        ST_BUFFBYPASS_RX_DRP_WAIT_RCFG_RDY_DEASSERT: begin
          if (~drp_reconfig_rdy_in) begin
            drp_reconfig_done_out <= 1'b0;
            sm_buffbypass_rx_drp  <= ST_BUFFBYPASS_RX_DRP_IDLE;
          end
        end

      endcase
    end
  end
endmodule