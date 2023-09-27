/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor                : Xilinx
// \   \   \/     Version               : 1.1
//  \   \         Application           : QDRIIP
//  /   /         Filename              : qdriip_v1_4_19_cal.v
// /___/   /\     Date Last Modified    : 2016/11/30
// \   \  /  \    Date Created          : Thu Oct 24 2013
//  \___\/\___\
//
//Device            : Ultrascale 
//Design            : QDRII+ SRAM
//Purpose           :
//             Contains all instances of the calibration logic.
//Reference         :
//Revision History  :
//*****************************************************************************

`timescale 1ps/1ps

module qdriip_v1_4_19_cal #(

    parameter integer ABITS         = 20
   ,parameter integer DBITS         = 36
   ,parameter integer BYTES         = 0
   ,parameter integer DBYTES        = 4
   ,parameter integer BURST_LEN     = 4
   ,parameter CAL_MODE 		    = "FAST"
   ,parameter MCS_ECC_ENABLE        = "FALSE"
   ,parameter integer tCK	    = 2500
   ,parameter integer TCQ	    = tCK/2
   ,parameter MEM_LATENCY 	    = "2.5"
   ,parameter NO_OF_DEVICES         = 2
   ,parameter CLK_2TO1		    = "TRUE"
   ,parameter C_FAMILY              = "kintexu"
   ,parameter SIM_MODE              = "FULL"
)(
   // Reset and clocks
    input                           div_clk
   ,input                           div_clk_rst
   ,input			    riu_clk
   ,input			    riu_clk_rst
   ,input                           vtc_complete_riuclk
   ,input                           bisc_complete_riuclk
   ,input  [DBITS*4-1:0]            mcal_dqin
   ,output                          en_vtc_riuclk
   ,output reg                      cal_done
   ,output [3:0]                    cal_doff_n
   ,output [(NO_OF_DEVICES*4)-1:0]  cal_k     
   ,output [3:0]                    cal_wps_n
   ,output [ABITS*4-1:0]            cal_addr
   ,output [DBYTES*4*9-1:0]         cal_dout
   ,output [DBYTES*4-1:0]           cal_bws_n
   ,output [3:0]                    cal_rps_n
   ,output [2*DBITS-1:0]            rd_data_slip 
   ,output [2*DBITS-1:0]            wr_data_slip 
   ,output [2*(DBITS/9)-1:0]        wr_bws_slip 
   ,output [2:0]                    addr_slip
   ,output [4:0]                    rd_valid_cnt
   ,output [2*DBITS-1:0]            fabric_slip
   ,output                          rd_valid_stg
   ,output [31:0]                   all_nibbles_t_b
   ,output                          clb2phy_rden
   ,output                          LMB_UE 
   ,output                          LMB_CE
   //Interface with MicroBlaze
   ,output [31:0]                   io_address_riuclk
   ,output                          io_addr_strobe_riuclk
   ,output                          io_write_strobe_riuclk
   ,output [31:0]                   io_write_data_riuclk
   ,input [31:0]                    riu2clb_rd_data_riuclk
   ,input                           riu2clb_valid_riuclk
   ,output                          riu_access

   // Debug ports
   ,output [299:0]                  dbg_cal_bus
   ,input  [36:0]                   sl_iport0
   ,output [16:0]                   sl_oport0
 
   //Reset signals from/to MB
   ,output                          ub_rst_out
   ,input                           reset_ub

   ,input [DBYTES*9*4-1:0]          traffic_error
   ,output                          traffic_clr_error
   ,input [3:0]                     win_start
   ,input                           traffic_wr_done
   ,output [31:0]                   win_status
);

//For fastening the simulation step size is scaled based on frequency
//for 300-400MHz -> step size is 45 taps
//for 400-500MHz -> step size is 35 taps
//for 500-600MHz -> step size is 25 taps
//for 600-715MHz -> step size is 15 taps
localparam STEP_SIZE       = ((CAL_MODE == "FAST") || (CAL_MODE == "SKIP")) ? 
     ((tCK > 2500) ? 60 : ((tCK > 2000 ) ? 50 : ((tCK > 1667) ? 45 : 30 ))) : 
     ((CAL_MODE =="SIM_FULL") ? 5 : 1 ) ;
// 105us for pwr up sequence to complete (spec says 100us as the time required, 
// but to be on the safer side and to compensate the initial time for the phy
// to stabilize adding extra 5 us.
localparam PWR_UP_SEQ_CLK       = (105000000/(tCK*2)) +  1 ; 
localparam PWR_UP_SEQ_TIME_CLK  = (STEP_SIZE >= 5) ? 10 : PWR_UP_SEQ_CLK;
localparam RDLVL                = "ON"; //valid configuration ON, OFF
localparam K_TO_WR_CAL          = "ON"; //valid configuration ON, OFF

// Wire declarations
integer unsigned   idx; 
wire               vtc_complete ;
wire               bisc_complete ;
wire [27:0]        io_address;
wire               io_addr_strobe;
wire [31:0]        io_write_data;
wire               io_write_strobe;
wire               io_addr_strobe_lvl_riuclk;
wire [31:0]        io_read_data_riuclk;
wire               io_ready_riuclk;
wire [31:0]        io_read_data;
wire               en_vtc;
wire               io_ready;
//(* dont_touch = "true" *) reg [31:0] io_read_data_in;
//(* dont_touch = "true" *) reg en_vtc_in;

(* keep = "TUE" *) reg div_clk_rst_r1;

//***************** Start of the RTL ***********************//

// Display message to convey the calibration status
always@(posedge cal_done) begin
  if (CAL_MODE != "SKIP") begin
    $display("====================================");
    $display(" Calibration completed successfully");
    $display("====================================");
  end
end

  always @(posedge div_clk)
    div_clk_rst_r1 <= div_clk_rst;

qdriip_v1_4_19_cal_f2r_sync # (
    .TCQ               (TCQ)
) u_cal_f2r_sync (
     .div_clk                           (div_clk)
    ,.div_clk_rst                       (div_clk_rst_r1)
    ,.en_vtc                            (en_vtc)
    ,.io_ready                          (io_ready)
    ,.io_read_data                      (io_read_data)

    ,.riu_clk                           (riu_clk)
    ,.en_vtc_rclk                       (en_vtc_riuclk)
    ,.io_ready_rclk                     (io_ready_riuclk)
    ,.io_read_data_rclk                 (io_read_data_riuclk)
);

qdriip_v1_4_19_cal_r2f_sync # (
    .TCQ               (TCQ)
) u_cal_r2f_sync (
     .riu_clk                           (riu_clk)
    ,.riu_clk_rst                       (riu_clk_rst)
    ,.io_address_rclk                   (io_address_riuclk[27:0])
    ,.io_addr_strobe_rclk               (io_addr_strobe_riuclk)
    ,.io_write_strobe_rclk              (io_write_strobe_riuclk)
    ,.io_write_data_rclk                (io_write_data_riuclk)
    ,.bisc_complete_rclk                (bisc_complete_riuclk)
    ,.vtc_complete_rclk                 (vtc_complete_riuclk)
    ,.riu_access                        (riu_access)

    ,.div_clk                           (div_clk)
    ,.io_addr_strobe                    (io_addr_strobe)
    ,.io_address                        (io_address)
    ,.io_write_data                     (io_write_data)
    ,.io_write_strobe                   (io_write_strobe)
    ,.bisc_complete                     (bisc_complete)
    ,.vtc_complete                      (vtc_complete)
);

qdriip_v1_4_19_cal_riu # (
     .TCQ              (TCQ)
    ,.MCS_ECC_ENABLE   (MCS_ECC_ENABLE)
) u_cal_riu (
     .riu_clk                           (riu_clk)
    ,.riu_clk_rst                       (riu_clk_rst)
    ,.riu2mcs_valid                     (riu2clb_valid_riuclk)
    ,.riu2mcs_rd_data                   (riu2clb_rd_data_riuclk)
    ,.fab2mcs_rd_data                   (io_read_data_riuclk)
    ,.fab2mcs_io_ready                  (io_ready_riuclk)
    ,.reset_ub_riuclk                   (reset_ub)
    ,.LMB_UE                            (LMB_UE)
    ,.LMB_CE                            (LMB_CE) 
    ,.riu_access                        (riu_access)
    ,.io_address_rclk                   (io_address_riuclk)
    ,.io_addr_strobe_rclk               (io_addr_strobe_riuclk)
    ,.io_write_strobe_rclk              (io_write_strobe_riuclk)
    ,.io_write_data_rclk                (io_write_data_riuclk)
    ,.ub_rst_out_rclk                   (ub_rst_out)
);

//Instance of the calibration module
qdriip_v1_4_19_cal_fab #
(
   .ABITS                (ABITS)
  ,.DBITS                (DBITS)
  ,.DBYTES               (DBYTES)
  ,.BURST_LEN            (BURST_LEN)
  ,.BYTES                (BYTES)
  ,.RDLVL		 (RDLVL)		
  ,.K_TO_WR_CAL	         (K_TO_WR_CAL)	
  ,.STEP_SIZE		 (STEP_SIZE)
  ,.CAL_MODE		 (CAL_MODE)
  ,.tCK                  (tCK)
  ,.MEM_LATENCY          (MEM_LATENCY)
  ,.PWR_UP_SEQ_TIME_CLK  (PWR_UP_SEQ_TIME_CLK)
  ,.TCQ		         (TCQ)
  ,.NO_OF_DEVICES	 (NO_OF_DEVICES)
  ,.CLK_2TO1		 (CLK_2TO1)
  ,.C_FAMILY             (C_FAMILY)
  ,.SIM_MODE             (SIM_MODE)
) cal_fab (

  //clock and reset signals
   .clk                                 (div_clk)
  ,.rst                                 (div_clk_rst_r1)

  //outputs from calibration logic
  ,.bisc_complete                       (bisc_complete)
  ,.vtc_complete                        (vtc_complete)
  ,.mcal_dqin                           (mcal_dqin)
  ,.cal_done_r                          (cal_done)
  ,.en_vtc                              (en_vtc)
  ,.cal_doff_n                          (cal_doff_n )
  ,.cal_k                               (cal_k)
  ,.cal_wps_n                           (cal_wps_n)
  ,.cal_addr                            (cal_addr)
  ,.cal_dout                            (cal_dout)
  ,.cal_bws_n                           (cal_bws_n)
  ,.cal_rps_n                           (cal_rps_n)
  ,.rd_data_slip                        (rd_data_slip)
  ,.wr_data_slip                        (wr_data_slip)
  ,.wr_bws_slip                         (wr_bws_slip)
  ,.addr_slip                           (addr_slip)
  ,.rd_valid_cnt                        (rd_valid_cnt)
  ,.fabric_slip                         (fabric_slip)
  ,.rd_valid_stg                        (rd_valid_stg)
  ,.all_nibbles_t_b                     (all_nibbles_t_b)
  ,.clb2phy_rden                        (clb2phy_rden)
  
  ,.io_address                          (io_address)
  ,.io_addr_strobe                      (io_addr_strobe)
  ,.io_write_strobe                     (io_write_strobe)
  ,.io_write_data                       (io_write_data)
  ,.io_read_data                        (io_read_data)
  ,.io_ready                            (io_ready)
  
  ,.sl_iport0                           (sl_iport0)
  ,.sl_oport0                           (sl_oport0)
  ,.dbg_bus                             (dbg_cal_bus)

  ,.traffic_error                       (traffic_error)
  ,.traffic_clr_error                   (traffic_clr_error)
  ,.win_start                           (win_start)
  ,.traffic_wr_done                     (traffic_wr_done)
  ,.win_status                          (win_status)
);

endmodule

