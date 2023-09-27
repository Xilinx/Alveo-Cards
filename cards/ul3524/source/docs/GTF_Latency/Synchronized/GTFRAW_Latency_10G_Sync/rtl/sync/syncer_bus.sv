/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`default_nettype none
module syncer_bus
#(
  parameter WIDTH = 8
 )
(
  input  wire clkin,
  input  wire clkin_resetn,
  input  wire clkout,
  input  wire clkout_resetn,

  input  wire [WIDTH-1:0] busin,
  output reg  [WIDTH-1:0] busout
);

  reg  [WIDTH-1:0] busout_nxt;
  reg  [WIDTH-1:0] latched_inputs;
  reg  [WIDTH-1:0] latched_inputs_nxt;

  wire ready;
  reg  req_event;
  reg  req_event_nxt;
  wire sync_req_event;
  reg  ack_event;
  reg  ack_event_nxt;
  wire sync_ack_event;

 (* keep = "true" *) reg ready_clkin;


  syncer_level i_ready_clkout_sync (

    .clk        (clkout),
    .resetn     (clkout_resetn),

    .datain     (ready_clkin),
    .dataout    (ready)

  );  // i_ready_clkout_sync


  syncer_level i_req_clkout_sync (

    .clk        (clkout),
    .resetn     (clkout_resetn),

    .datain     (req_event),
    .dataout    (sync_req_event)

  );  // i_req_clkout_sync


  syncer_level i_ack_clkin_sync (

    .clk        (clkin),
    .resetn     (clkin_resetn),

    .datain     (ack_event),
    .dataout    (sync_ack_event)

  );  // i_ack_clkin_sync


  always @*
    begin
      req_event_nxt = ~sync_ack_event;

      if (req_event == sync_ack_event)
        begin
          latched_inputs_nxt = busin;
        end
      else
        begin
          latched_inputs_nxt = latched_inputs;
        end
    end


  always @*
    begin
      ack_event_nxt = sync_req_event;

      if (!ready)
        begin
          busout_nxt = {WIDTH{1'b0}};
        end
      else if (ack_event != sync_req_event)
        begin
          busout_nxt = latched_inputs;
        end
      else
        begin
          busout_nxt = busout;
        end
    end


  always @( posedge clkin or negedge clkin_resetn )
    begin
      if ( clkin_resetn != 1'b1 )
        begin
          latched_inputs <= {WIDTH{1'b0}};
          req_event      <= 1'b0;
          ready_clkin    <= 1'b0;
        end
      else
        begin
          latched_inputs <= latched_inputs_nxt;
          req_event      <= req_event_nxt;
          ready_clkin    <= 1'b1;
        end
    end


  always @( posedge clkout or negedge clkout_resetn )
    begin
      if ( clkout_resetn != 1'b1 )
        begin
          busout    <= {WIDTH{1'b0}};
          ack_event <= 1'b0;
        end
      else
        begin
          busout    <= busout_nxt;
          ack_event <= ack_event_nxt;
        end
    end

endmodule
`default_nettype wire
