/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------
//
//  Description: This is a simple automated I2C controller that does the bare 
//               minumum to power up the QSFP modules and initialize the QSFP 
//               sideband signal. It also includes a simple AXI interface to 
//               provide monitoring or control left up to the user's 
//               requirements.
//
//------------------------------------------------------------------------------

module gtfraw_vnc_syncer_reset
#(
  parameter RESET_PIPE_LEN = 3
 )
(
  input  wire clk,
  input  wire reset_async,
  output wire reset
);

  (* ASYNC_REG = "TRUE" *) reg  [RESET_PIPE_LEN-1:0] reset_pipe_retime;
  reg  reset_pipe_out;

// synthesis translate_off

  initial reset_pipe_retime  = {RESET_PIPE_LEN{1'b0}};
  initial reset_pipe_out     = 1'b0;

// synthesis translate_on

  always @(posedge clk or negedge reset_async)
    begin
      if (reset_async == 1'b0)
        begin
          reset_pipe_retime <= {RESET_PIPE_LEN{1'b0}};
          reset_pipe_out    <= 1'b0;
        end
      else
        begin
          reset_pipe_retime <= {reset_pipe_retime[RESET_PIPE_LEN-2:0], 1'b1};
          reset_pipe_out    <= reset_pipe_retime[RESET_PIPE_LEN-1];
        end
    end

  assign reset = reset_pipe_out;

endmodule
