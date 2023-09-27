/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------


//------{
`timescale 1ps/1ps

`default_nettype none
(* DowngradeIPIdentifiedWarnings="yes" *)
module gtfwizard_raw_delay_powergood # (
  parameter C_USER_GTPOWERGOOD_DELAY_EN = 0
)(
  input wire GT_TXOUTCLKPCS,

  input wire GT_GTPOWERGOOD,
  input wire USER_GTTXRESET,
  input wire USER_TXPMARESET,
  input wire USER_TXPISOPD,

  output wire USER_GTPOWERGOOD,
  output wire GT_GTTXRESET,
  output wire GT_TXPMARESET,
  output wire GT_TXPISOPD
);

generate if (C_USER_GTPOWERGOOD_DELAY_EN == 0)
begin : gen_powergood_nodelay
  assign GT_TXPISOPD      = USER_TXPISOPD;
  assign GT_GTTXRESET     = USER_GTTXRESET;
  assign GT_TXPMARESET    = USER_TXPMARESET;
  assign USER_GTPOWERGOOD = GT_GTPOWERGOOD;
end
else
begin: gen_powergood_delay
  reg [15:0] counter;
  always @ (posedge GT_TXOUTCLKPCS or negedge GT_GTPOWERGOOD)
  begin
      if (!GT_GTPOWERGOOD)
          counter <= 5'd0;
      else
          counter <= {counter[14:0], 1'd1}; 
  end

  reg pwr_on_fsm;
  always @(posedge GT_TXOUTCLKPCS)
    pwr_on_fsm <= counter[13];

  assign GT_TXPISOPD      = pwr_on_fsm ? USER_TXPISOPD : 1'b1;
  assign GT_GTTXRESET     = pwr_on_fsm ? USER_GTTXRESET : !GT_GTPOWERGOOD;
  assign GT_TXPMARESET    = pwr_on_fsm ? USER_TXPMARESET : 1'b0;
  assign USER_GTPOWERGOOD = pwr_on_fsm; 

end
endgenerate

endmodule
`default_nettype wire
//------}


//OVERKILL  (*  ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg [4:0] intclk_rrst_n_r = 5'd0;
//OVERKILL  (*  ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg [8:0] wait_cnt;
//OVERKILL  (*  ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) (* KEEP = "TRUE" *) reg int_pwr_on_fsm = 1'b0;
//OVERKILL  (*  ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) (* KEEP = "TRUE" *) reg pwr_on_fsm = 1'b0;
//OVERKILL  wire intclk_rrst_n;
//OVERKILL  
//OVERKILL  //--------------------------------------------------------------------------
//OVERKILL  //  POWER ON FSM Encoding
//OVERKILL  //-------------------------------------------------------------------------- 
//OVERKILL  localparam PWR_ON_WAIT_CNT           = 1'b0;
//OVERKILL  localparam PWR_ON_DONE               = 1'b1; 
//OVERKILL  
//OVERKILL  //--------------------------------------------------------------------------------------------------
//OVERKILL  //  Reset Synchronizer
//OVERKILL  //--------------------------------------------------------------------------------------------------
//OVERKILL  always @ (posedge GT_TXOUTCLKPCS or negedge GT_GTPOWERGOOD)
//OVERKILL  begin
//OVERKILL      if (!GT_GTPOWERGOOD)
//OVERKILL          intclk_rrst_n_r <= 5'd0;
//OVERKILL      else if(!int_pwr_on_fsm)
//OVERKILL          intclk_rrst_n_r <= {intclk_rrst_n_r[3:0], 1'd1}; 
//OVERKILL  end
//OVERKILL
//OVERKILL  assign intclk_rrst_n = intclk_rrst_n_r[4];
//OVERKILL
//OVERKILL  //--------------------------------------------------------------------------------------------------
//OVERKILL  //  Wait counter 
//OVERKILL  //--------------------------------------------------------------------------------------------------
//OVERKILL  always @ (posedge GT_TXOUTCLKPCS)
//OVERKILL  begin
//OVERKILL    if (!intclk_rrst_n)
//OVERKILL    	wait_cnt <= 9'd0;
//OVERKILL    else begin
//OVERKILL    	if (int_pwr_on_fsm == PWR_ON_WAIT_CNT)
//OVERKILL    		wait_cnt <= {wait_cnt[7:0],1'b1};
//OVERKILL    	else
//OVERKILL    		wait_cnt <= wait_cnt;
//OVERKILL    end
//OVERKILL  end
//OVERKILL
//OVERKILL  //--------------------------------------------------------------------------------------------------
//OVERKILL  // Power On FSM
//OVERKILL  //--------------------------------------------------------------------------------------------------
//OVERKILL
//OVERKILL  always @ (posedge GT_TXOUTCLKPCS or negedge GT_GTPOWERGOOD)
//OVERKILL  begin
//OVERKILL    if (!GT_GTPOWERGOOD)
//OVERKILL    begin
//OVERKILL      int_pwr_on_fsm <= PWR_ON_WAIT_CNT;
//OVERKILL    end
//OVERKILL    else begin
//OVERKILL      case (int_pwr_on_fsm)
//OVERKILL        PWR_ON_WAIT_CNT :
//OVERKILL          begin
//OVERKILL            int_pwr_on_fsm <= (wait_cnt[7] == 1'b1) ? PWR_ON_DONE : PWR_ON_WAIT_CNT;
//OVERKILL          end 
//OVERKILL
//OVERKILL        PWR_ON_DONE :
//OVERKILL          begin
//OVERKILL            int_pwr_on_fsm <= PWR_ON_DONE;
//OVERKILL          end
//OVERKILL
//OVERKILL        default :
//OVERKILL        begin
//OVERKILL          int_pwr_on_fsm <= PWR_ON_WAIT_CNT;
//OVERKILL        end
//OVERKILL      endcase
//OVERKILL    end
//OVERKILL  end
//OVERKILL
//OVERKILL  always @(posedge GT_TXOUTCLKPCS)
//OVERKILL    pwr_on_fsm <= int_pwr_on_fsm;
//OVERKILL
//OVERKILL  assign GT_TXPISOPD      = pwr_on_fsm ? USER_TXPISOPD : 1'b1;
//OVERKILL  assign GT_GTTXRESET     = pwr_on_fsm ? USER_GTTXRESET : !GT_GTPOWERGOOD;
//OVERKILL  assign GT_TXPMARESET    = pwr_on_fsm ? USER_TXPMARESET : 1'b0;
//OVERKILL  assign USER_GTPOWERGOOD = pwr_on_fsm; 

