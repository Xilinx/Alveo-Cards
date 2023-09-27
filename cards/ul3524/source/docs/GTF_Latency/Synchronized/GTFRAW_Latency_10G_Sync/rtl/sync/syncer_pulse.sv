/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`default_nettype none
module syncer_pulse (

  input  wire clkin,
  input  wire clkin_resetn,
  input  wire clkout,
  input  wire clkout_resetn,

  input  wire pulsein,  // clkin domain
  output reg  pulseout  // clkout domain
);

  reg  pulsein_d1;
  reg  pulsein_d1_nxt;
  reg  pulseout_nxt;

  reg  req_event;
  reg  req_event_nxt;
  wire sync_req_event;
  reg  ack_event;
  reg  ack_event_nxt;
  wire sync_ack_event;

  wire clkin_resetn_out_sync;
  wire clkout_resetn_in_sync;
 (* keep = "true" *) reg  clkin_resetn_r1;
 (* keep = "true" *) reg  clkin_resetn_r2;
 (* keep = "true" *) reg  clkout_resetn_r1;
 (* keep = "true" *) reg  clkout_resetn_r2;

  always @(posedge clkin)
  begin
    clkin_resetn_r1      <=      clkin_resetn;
    clkin_resetn_r2      <=      clkin_resetn;
  end

  always @(posedge clkout)
  begin
    clkout_resetn_r1     <=      clkout_resetn;
    clkout_resetn_r2     <=      clkout_resetn;
  end

  syncer_level i_syncpls_req (

    .clk        (clkout),
    .resetn     (clkout_resetn_r1),

    .datain     (req_event),
    .dataout    (sync_req_event)

  );  // i_syncpls_req


  syncer_level i_syncpls_ack (

    .clk        (clkin),
    .resetn     (clkin_resetn_r1),

    .datain     (ack_event),
    .dataout    (sync_ack_event)

  );  // i_syncpls_ack

  syncer_reset i_syncpls_clkin_rstsync (

    .clk          (clkout),
    .resetn_async (clkin_resetn_r2),
    .resetn       (clkin_resetn_out_sync)

  );  // i_syncpls_clkin_rstsync

  syncer_reset i_syncpls_clkout_rstsync (

    .clk          (clkin),
    .resetn_async (clkout_resetn_r2),
    .resetn       (clkout_resetn_in_sync)

  );  // i_syncpls_clkout_rstsync


  always @*
    begin
      pulsein_d1_nxt = pulsein;
      req_event_nxt  = req_event;

      if (pulsein && !pulsein_d1 && req_event == sync_ack_event)
        begin
          req_event_nxt = ~req_event;
        end
    end


  always @*
    begin
      ack_event_nxt = sync_req_event;
      pulseout_nxt  = (ack_event != sync_req_event);
    end


  always @( posedge clkin or negedge clkout_resetn_in_sync )
    begin
      if ( clkout_resetn_in_sync != 1'b1 )
        begin
          pulsein_d1 <= 1'b0;
          req_event  <= 1'b0;
        end
      else
        begin
          pulsein_d1 <= pulsein_d1_nxt;
          req_event  <= req_event_nxt;
        end
    end


  always @( posedge clkout or negedge clkin_resetn_out_sync )
    begin
      if ( clkin_resetn_out_sync != 1'b1 )
        begin
          ack_event <= 1'b0;
          pulseout  <= 1'b0;
        end
      else
        begin
          ack_event <= ack_event_nxt;
          pulseout  <= pulseout_nxt;
        end
    end

endmodule // syncer_pulse
`default_nettype wire
