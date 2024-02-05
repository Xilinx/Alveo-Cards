/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------


//------{
`timescale 1ps/1ps

`default_nettype none
(* DowngradeIPIdentifiedWarnings="yes" *)
module gtfwizard_0_delay_powergood # (
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
  (*  ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg [4:0] intclk_rrst_n_r = 5'd0;
  (*  ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg [8:0] wait_cnt;
  (*  ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) (* KEEP = "TRUE" *) reg int_pwr_on_fsm = 1'b0;
  (*  ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) (* KEEP = "TRUE" *) reg pwr_on_fsm = 1'b0;
  wire intclk_rrst_n;
  
  //--------------------------------------------------------------------------
  //  POWER ON FSM Encoding
  //-------------------------------------------------------------------------- 
  localparam PWR_ON_WAIT_CNT           = 1'b0;
  localparam PWR_ON_DONE               = 1'b1; 
  
  //--------------------------------------------------------------------------------------------------
  //  Reset Synchronizer
  //--------------------------------------------------------------------------------------------------
  always @ (posedge GT_TXOUTCLKPCS or negedge GT_GTPOWERGOOD)
  begin
      if (!GT_GTPOWERGOOD)
          intclk_rrst_n_r <= 5'd0;
      else if(!int_pwr_on_fsm)
          intclk_rrst_n_r <= {intclk_rrst_n_r[3:0], 1'd1}; 
  end

  assign intclk_rrst_n = intclk_rrst_n_r[4];

  //--------------------------------------------------------------------------------------------------
  //  Wait counter 
  //--------------------------------------------------------------------------------------------------
  always @ (posedge GT_TXOUTCLKPCS)
  begin
    if (!intclk_rrst_n)
    	wait_cnt <= 9'd0;
    else begin
    	if (int_pwr_on_fsm == PWR_ON_WAIT_CNT)
    		wait_cnt <= {wait_cnt[7:0],1'b1};
    	else
    		wait_cnt <= wait_cnt;
    end
  end

  //--------------------------------------------------------------------------------------------------
  // Power On FSM
  //--------------------------------------------------------------------------------------------------

  always @ (posedge GT_TXOUTCLKPCS or negedge GT_GTPOWERGOOD)
  begin
    if (!GT_GTPOWERGOOD)
    begin
      int_pwr_on_fsm <= PWR_ON_WAIT_CNT;
    end
    else begin
      case (int_pwr_on_fsm)
        PWR_ON_WAIT_CNT :
          begin
            int_pwr_on_fsm <= (wait_cnt[7] == 1'b1) ? PWR_ON_DONE : PWR_ON_WAIT_CNT;
          end 

        PWR_ON_DONE :
          begin
            int_pwr_on_fsm <= PWR_ON_DONE;
          end

        default :
        begin
          int_pwr_on_fsm <= PWR_ON_WAIT_CNT;
        end
      endcase
    end
  end

  always @(posedge GT_TXOUTCLKPCS)
    pwr_on_fsm <= int_pwr_on_fsm;

  assign GT_TXPISOPD      = pwr_on_fsm ? USER_TXPISOPD : 1'b1;
  assign GT_GTTXRESET     = pwr_on_fsm ? USER_GTTXRESET : !GT_GTPOWERGOOD;
  assign GT_TXPMARESET    = pwr_on_fsm ? USER_TXPMARESET : 1'b0;
  assign USER_GTPOWERGOOD = pwr_on_fsm; 

end
endgenerate

endmodule
`default_nettype wire
//------}
