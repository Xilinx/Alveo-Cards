/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------


`timescale 1ps/1ps
`default_nettype none
module gtfwizard_mac_gtf_ch_drp_align_switch #(
	parameter BYPASS_DA = 1'b0
)(
  input  wire        freerun_clk_in,
  input  wire        gtwiz_buffbypass_rx_reset_in,
  input  wire        am_switch_in,
  input  wire        drp_reconfig_rdy_in, 
  input  wire        drprdy_in,
  input  wire [15:0] drpdo_in,
  output reg         drp_reconfig_done_out,
  output reg         drpen_out,
  output reg         drpwe_out,
  output reg  [9:0]  drpaddr_out, 
  output reg  [15:0] drpdi_out
); 
  

  localparam NUM_REG = 3;

  localparam [9:0] DMONITOR_CFG1_ADDR 		= 10'h03A;
  localparam [9:0] RXSYNC_OVRD_ADDR 		= 10'h08A;
  localparam [9:0] RXPH_MONITOR_SEL_ADDR 	= 10'h061;
  
  localparam [15:0] DMONITOR_CFG1_MASK 		= ~(8'hFF  << 8);
  localparam [15:0] RXSYNC_OVRD_MASK 		= ~((1'h1 << 14) | (1'h1 << 8)); //[8]: RXSYNC_SKIP_DA, [14]: RXSYNC_OVRD
  localparam [15:0] RXPH_MONITOR_SEL_MASK	= ~(5'h1F << 11);
  
  localparam [15:0] DMONITOR_CFG1_DATA 		= 8'h83 << 8;
  localparam [15:0] RXSYNC_OVRD_DATA 		= (1'h1 << 14)  | (1'h1 << 8); //set RXSYNC_SKIP_DA = 1 during manual mode
  localparam [15:0] RXPH_MONITOR_SEL_DATA	= 5'h10 << 11;
  
  localparam [9:0] DRP_ADDR_ARR [0:NUM_REG-1] 	= {DMONITOR_CFG1_ADDR, RXPH_MONITOR_SEL_ADDR, RXSYNC_OVRD_ADDR};
  localparam [15:0] DRP_MASK_ARR [0:NUM_REG-1] 	= {DMONITOR_CFG1_MASK, RXPH_MONITOR_SEL_MASK, RXSYNC_OVRD_MASK};
  localparam [15:0] DRP_DATA_ARR [0:NUM_REG-1] 	= {DMONITOR_CFG1_DATA, RXPH_MONITOR_SEL_DATA, RXSYNC_OVRD_DATA};

  localparam NUM_REG_LOG2 = $clog2(NUM_REG);
  reg [NUM_REG_LOG2-1:0] reg_idx;

  reg  [2:0]  sm_buffbypass_rx_drp;
  wire [15:0] curr_mask   = DRP_MASK_ARR[reg_idx];
  wire [9:0]  curr_addr   = DRP_ADDR_ARR[reg_idx];
  wire [15:0] curr_wrdata = (reg_idx == (NUM_REG-1) && am_switch_in) ? (BYPASS_DA << 8) : DRP_DATA_ARR[reg_idx]; 

  localparam [2:0] ST_AM_BUFFBYPASS_RX_DRP_IDLE              = 3'd0;
  localparam [2:0] ST_AM_BUFFBYPASS_RX_DRP_START             = 3'd1;
  localparam [2:0] ST_AM_BUFFBYPASS_RX_DRP_WAIT_RDY          = 3'd2;
  localparam [2:0] ST_AM_BUFFBYPASS_RX_DRP_WAIT_RDY_DEASSERT = 3'd3;

  localparam [2:0] ST_AM_BUFFBYPASS_RX_DRP_RD                = 3'd4;
  localparam [2:0] ST_AM_BUFFBYPASS_RX_DRP_RD_WAIT           = 3'd5;
  localparam [2:0] ST_AM_BUFFBYPASS_RX_DRP_WR                = 3'd6;
  localparam [2:0] ST_AM_BUFFBYPASS_RX_DRP_WR_WAIT           = 3'd7;
  
	reg d_drp_reconfig_rdy_in; 
	always @(posedge freerun_clk_in)
		d_drp_reconfig_rdy_in <= drp_reconfig_rdy_in;

	always @(posedge freerun_clk_in) 
	begin
    if (gtwiz_buffbypass_rx_reset_in) 
    begin
      //default signals here
      drp_reconfig_done_out    <= 1'b0; 
      drpen_out                <= 1'b0;
      drpwe_out                <= 1'b0;
      drpaddr_out              <= 10'h000; 
      drpdi_out                <= 16'h0000;
      reg_idx <= {NUM_REG_LOG2{1'b0}};
      sm_buffbypass_rx_drp <= ST_AM_BUFFBYPASS_RX_DRP_IDLE;   
    end
    
    else begin
      case (sm_buffbypass_rx_drp)
        default: 
        begin
          drp_reconfig_done_out    <= 1'b0;
          drpen_out                <= 1'b0;
          drpwe_out                <= 1'b0;
          drpaddr_out              <= 10'h000; 
          drpdi_out                <= 16'h0000;
          reg_idx                  <= {NUM_REG_LOG2{1'b0}};
          if (drp_reconfig_rdy_in & ~d_drp_reconfig_rdy_in) 
          begin 
            //sm_buffbypass_rx_drp <= ST_AM_BUFFBYPASS_RX_DRP_START;
            sm_buffbypass_rx_drp <= ST_AM_BUFFBYPASS_RX_DRP_RD;
          end
        end

        //DRP read
        ST_AM_BUFFBYPASS_RX_DRP_RD: 
        begin
          drp_reconfig_done_out <= 1'b0;
          drpen_out             <= 1'b1;
          drpwe_out             <= 1'b0;
          drpaddr_out           <= curr_addr;
          sm_buffbypass_rx_drp  <= ST_AM_BUFFBYPASS_RX_DRP_RD_WAIT;
        end
        ST_AM_BUFFBYPASS_RX_DRP_RD_WAIT: 
        begin
          drp_reconfig_done_out <= 1'b0;
          drpen_out             <= 1'b0;
          drpwe_out             <= 1'b0;
          if (drprdy_in) 
          begin
            drpdi_out             <= curr_wrdata | (curr_mask & drpdo_in);
            sm_buffbypass_rx_drp  <= ST_AM_BUFFBYPASS_RX_DRP_WR;
          end
        end
        ST_AM_BUFFBYPASS_RX_DRP_WR: 
        begin
          drp_reconfig_done_out <= 1'b0;
          drpen_out             <= 1'b1;
          drpwe_out             <= 1'b1;
          sm_buffbypass_rx_drp  <= ST_AM_BUFFBYPASS_RX_DRP_WR_WAIT;
        end
        ST_AM_BUFFBYPASS_RX_DRP_WR_WAIT: 
        begin
          drpen_out             <= 1'b0;
          drpwe_out             <= 1'b0;
          if (drprdy_in) 
          begin
            if(reg_idx < (NUM_REG-1)) 
            begin
              drp_reconfig_done_out <= 1'b0;
              reg_idx               <= reg_idx + 1'b1;
              sm_buffbypass_rx_drp  <= ST_AM_BUFFBYPASS_RX_DRP_RD;
            end
            else 
            begin
              drp_reconfig_done_out <= 1'b1;
              sm_buffbypass_rx_drp  <= ST_AM_BUFFBYPASS_RX_DRP_IDLE;			
            end
          end
        end
      endcase
    end
  end
endmodule
`default_nettype wire
