/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`default_nettype none
module syncer_reset
#(
  parameter RESET_PIPE_LEN = 3
 )
(
  input  wire clk,
  input  wire resetn_async,
  output wire resetn
);

  (* ASYNC_REG = "TRUE" *) reg  [RESET_PIPE_LEN-1:0] resetn_pipe_retime;
  reg  resetn_pipe_out;

// synthesis translate_off

  initial resetn_pipe_retime  = {RESET_PIPE_LEN{1'b0}};
  initial resetn_pipe_out     = 1'b0;

// synthesis translate_on

  always @(posedge clk or negedge resetn_async)
    begin
      if (resetn_async == 1'b0)
        begin
          resetn_pipe_retime <= {RESET_PIPE_LEN{1'b0}};
          resetn_pipe_out    <= 1'b0;
        end
      else
        begin
          resetn_pipe_retime <= {resetn_pipe_retime[RESET_PIPE_LEN-2:0], 1'b1};
          resetn_pipe_out    <= resetn_pipe_retime[RESET_PIPE_LEN-1];
        end
    end

  assign resetn = resetn_pipe_out;

endmodule
`default_nettype wire
