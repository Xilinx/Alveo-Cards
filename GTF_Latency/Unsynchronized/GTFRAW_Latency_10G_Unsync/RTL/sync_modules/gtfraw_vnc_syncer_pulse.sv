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

module gtfraw_vnc_syncer_pulse (

  input  wire clkin,
  input  wire clkin_reset,
  input  wire clkout,
  input  wire clkout_reset,

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

  wire clkin_reset_out_sync;
  wire clkout_reset_in_sync;

  gtfraw_vnc_syncer_level i_syncpls_req (

    .clk        (clkout),
    .reset      (clkout_reset),

    .datain     (req_event),
    .dataout    (sync_req_event)

  );  // i_syncpls_req


  gtfraw_vnc_syncer_level i_syncpls_ack (

    .clk        (clkin),
    .reset      (clkin_reset),

    .datain     (ack_event),
    .dataout    (sync_ack_event)

  );  // i_syncpls_ack

  gtfraw_vnc_syncer_reset i_syncpls_clkin_rstsync (

    .clk         (clkout),
    .reset_async (clkin_reset),
    .reset       (clkin_reset_out_sync)

  );  // i_syncpls_clkin_rstsync

  gtfraw_vnc_syncer_reset i_syncpls_clkout_rstsync (

    .clk         (clkin),
    .reset_async (clkout_reset),
    .reset       (clkout_reset_in_sync)

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


  always @( posedge clkin or negedge clkout_reset_in_sync )
    begin
      if ( clkout_reset_in_sync != 1'b1 )
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


  always @( posedge clkout or negedge clkin_reset_out_sync )
    begin
      if ( clkin_reset_out_sync != 1'b1 )
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

`ifdef SARANCE_RTL_DEBUG
`endif

endmodule // syncer_pulse
