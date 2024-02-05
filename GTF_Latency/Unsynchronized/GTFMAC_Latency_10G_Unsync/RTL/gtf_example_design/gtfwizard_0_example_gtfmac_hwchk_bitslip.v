/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------


/////////////////////////////////////////////////////////////////////////////
// Bitslip adjustment module for GTFMAC
/////////////////////////////////////////////////////////////////////////////
//
// THEORY OF OPERATION
//
//  - during reset, this logic holds bs_disable_bitslip=1 to give time for
//      the GTFMAC to complete its reset
//
//  - once reset is cleared, bs_disable_bitslip is set to '0' which allows the
//      GTFMAC to start tracking the bitslip.
//
//  - rx_bitslip will pulse to '1' for each adjustment by GTFMAC.  This logic counts
//      the number of these slips.
//
//  - once block_lock is achieved (rx_block_lock=1), this logic asserts bs_disable_bitslip=1
//      again, and waits for the user to initiate the correction process.  The process is started
//      once the user asserts ctl_correct_bitslip=1.
//
//  - for every two pulses of rx_bitslip observed after reset, this logic asserts bs_slip_pma and
//      waits for rx_slip_pma_rdy to toggle from 1 -> 0. This process repeats until either zero or one
//      rx_bitslip pulses remain unaccounted for.
//
//  - if an odd number of rx_bitslip pulses were observed, this logic finishes by asserting bs_slip_one_ui=1
//      which is the final adjustment.
//
//  - this logic asserts bs_gb_seq_sync for 8 clocks to reset the MAC portion of the GTFMAC.  Block-lock
//      should then be re-aquired.
//
//  bitslip/gtfmac signal mappings:
//
//      rx_block_lock       = gtf_ch_statrxblocklock
//      rx_bitslip          = gtf_ch_rxbitslip
//      bs_gb_seq_sync      = gtf_ch_pcsrsvdin[0]
//      bs_disable_bitslip  = gtf_ch_pcsrsvdin[1]
//      bs_slip_pma         = gtf_ch_rxslippma
//      bs_slip_one_ui      = gtf_ch_gtrsvd[8]
//      rx_slip_pma_rdy     = gtf_ch_rxslippmardy
//
////////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps
`default_nettype none
(* DowngradeIPIdentifiedWarnings="yes" *)
module gtfwizard_0_example_gtfmac_hwchk_bitslip (

    input   wire           rx_clk,
    input   wire           rx_rst,

    input   wire           ctl_gb_seq_sync,
    input   wire           ctl_disable_bitslip,
    input   wire           ctl_correct_bitslip,
    input   wire           ctl_rx_data_rate,

    output  reg    [6:0]    stat_bitslip_cnt,
    output  reg    [6:0]    stat_bitslip_issued,

    output  reg             stat_excessive_bitslip,
    output  reg             stat_locked,
    output  reg             stat_busy,
    output  reg             stat_done,

    input   wire           rx_block_lock,
    input   wire           rx_bitslip,
    output  wire           bs_gb_seq_sync,
    output  wire           bs_disable_bitslip,

    output  reg            bs_slip_pma,
    output  reg            bs_slip_one_ui,
    input   wire           rx_slip_pma_rdy

);

    reg   [2:0]   state;
    reg   [6:0]   bitslip_delta;

    reg           bs_bitslip_R, bs_bitslip_R2;
    wire          bs_bitslip_re;

    reg           sm_gb_seq_sync;
    assign        bs_gb_seq_sync = ctl_gb_seq_sync | sm_gb_seq_sync;

    reg           sm_disable_bitslip; 
    wire          usr_disable_bitslip;
    assign        bs_disable_bitslip = sm_disable_bitslip | usr_disable_bitslip;

    wire          bs_slip_pma_rdy;
    wire          bs_correct_bitslip;
    wire          bs_bitslip;
    wire          bs_block_lock;

    assign          bs_bitslip_re = bs_bitslip_R & ~bs_bitslip_R2;

    localparam
                SYNC_STATE              = 3'd0,
                CORRECT_BITSLIP_STATE   = 3'd1,
                ACK_SLIP_STATE          = 3'd2,
                BLOCK_LOCK_STATE        = 3'd3,
                RESYNC_STATE            = 3'd4,
                DONE_STATE              = 3'd5;


    example_gtfmac_hwchk_bitlip_syncer_level i_disable_bitslip (

      .clk        (rx_clk),
      .reset      (~rx_rst),

      .datain     (ctl_disable_bitslip),
      .dataout    (usr_disable_bitslip)

    );

    example_gtfmac_hwchk_bitlip_syncer_level i_correct_bitslip (

      .clk        (rx_clk),
      .reset      (~rx_rst),

      .datain     (ctl_correct_bitslip),
      .dataout    (bs_correct_bitslip)

    );

    assign bs_slip_pma_rdy      = rx_slip_pma_rdy;
    assign bs_bitslip           = rx_bitslip;
    assign bs_block_lock        = rx_block_lock;

    reg   [3:0]   seq_sync_cnt;
    reg   [7:0]   q_bs_block_lock;

    always @(posedge rx_clk) begin

        begin

            bs_bitslip_R     <= bs_bitslip;
            bs_bitslip_R2    <= bs_bitslip_R;
            seq_sync_cnt     <= (|seq_sync_cnt) ? seq_sync_cnt - 1'b1 : 4'd0;

            q_bs_block_lock  <= {q_bs_block_lock[6:0], bs_block_lock};
            stat_locked      <= q_bs_block_lock[7];

            case (state)

                SYNC_STATE: begin

                    sm_disable_bitslip      <= 1'b0;

                    if (bs_bitslip_re) begin
                        if (&stat_bitslip_cnt == 1'b1) begin
                            stat_excessive_bitslip  <= 1'b1;
                            state                   <= DONE_STATE;
                        end
                        else begin
                            stat_bitslip_cnt    <= stat_bitslip_cnt + 1'b1;
                        end
                    end

                    if (stat_locked) begin
                        // Only disable bitslip if we are in 10G mode
                        sm_disable_bitslip  <= (ctl_rx_data_rate) ? 1'b0 : 1'b1;
                        state               <= (ctl_rx_data_rate) ? DONE_STATE: BLOCK_LOCK_STATE;
                    end


                end

                BLOCK_LOCK_STATE: begin

                    if (bs_correct_bitslip) begin
                        bitslip_delta   <= stat_bitslip_cnt - stat_bitslip_issued;
                        state           <= CORRECT_BITSLIP_STATE;
                    end

                end


                CORRECT_BITSLIP_STATE: begin

                    stat_busy    <= 1'b1;

                    if (bitslip_delta >= 7'd2) begin
                        bs_slip_pma             <= 1'b1;
                        stat_bitslip_issued     <= stat_bitslip_issued + 7'd2;
                        state                   <= ACK_SLIP_STATE;
                    end
                    else if (bitslip_delta > 7'd0) begin
                        bs_slip_one_ui          <= 1'b1;
                        stat_bitslip_issued     <= stat_bitslip_issued + 7'd1;
                        bitslip_delta           <= 7'd0;
                    end
                    else begin
                        seq_sync_cnt            <= 4'd15;
                        state                   <= RESYNC_STATE;
                    end

                end

                ACK_SLIP_STATE: begin

                    if (!bs_slip_pma_rdy) begin
                        bs_slip_pma     <= 1'b0;
                    end

                    if (bs_slip_pma == 1'b0 && bs_slip_pma_rdy == 1'b1) begin
                        bitslip_delta   <= stat_bitslip_cnt - stat_bitslip_issued;
                        state           <= CORRECT_BITSLIP_STATE;
                    end

                end

                RESYNC_STATE: begin
                    if (seq_sync_cnt == 4'd8) begin
                        sm_gb_seq_sync  <= 1'b1;
                    end
                    else if (seq_sync_cnt == 4'd1) begin
                        sm_gb_seq_sync  <= 1'b0;
                    end
                    else if (seq_sync_cnt == 4'd0) begin
                        state   <= DONE_STATE;
                    end
                end

                default: begin  // DONE_STATE
                    stat_busy       <= 1'b0;
                    stat_done       <= 1'b1;
                end

            endcase

        end


        if (rx_rst) begin
            state                   <= 'd0;
            bs_bitslip_R            <= 1'b0;
            bs_bitslip_R2           <= 1'b0;
            stat_locked             <= 1'b0;
            stat_bitslip_cnt        <= 'd0;
            stat_bitslip_issued     <= 'd0;
            stat_excessive_bitslip  <= 'd0;
            stat_busy               <= 1'b0;
            stat_done               <= 1'b0;
            sm_disable_bitslip      <= 1'b0;
            sm_gb_seq_sync          <= 1'b0;
            bs_slip_pma             <= 'd0;
            bs_slip_one_ui          <= 'd0;
            seq_sync_cnt            <= 3'd0;
            q_bs_block_lock         <= 8'd0;
        end

    end


endmodule
`default_nettype wire

`default_nettype none
module example_gtfmac_hwchk_bitlip_syncer_level
#(
  parameter WIDTH       = 1,
  parameter RESET_VALUE = 1'b0
 )
(
  input  wire clk,
  input  wire reset,

  input  wire [WIDTH-1:0] datain,
  output wire [WIDTH-1:0] dataout
);

  (* ASYNC_REG = "TRUE" *) reg  [WIDTH-1:0] dataout_reg;
  reg  [WIDTH-1:0] meta_nxt;
  wire [WIDTH-1:0] dataout_nxt;

`ifdef RTL_DEBUG
// synthesis translate_off

  integer i;
  integer seed;
  (* ASYNC_REG = "TRUE" *) reg  [WIDTH-1:0] meta;

  (* ASYNC_REG = "TRUE" *) reg  [WIDTH-1:0] meta2;
  reg  [WIDTH-1:0] meta_state;
  reg  [WIDTH-1:0] meta_state_nxt;

  initial seed       = `SEED;
  initial meta_state = {WIDTH{RESET_VALUE}};

  always @*
    begin
      for (i=0; i < WIDTH; i = i + 1)
        begin
          if ( meta_state[i] !== 1'b1 &&
               $dist_uniform(seed,0,9999) < 5000 &&
               meta[i] !== datain[i] )
            begin
              meta_nxt[i]       = meta[i];
              meta_state_nxt[i] = 1'b1;
            end
          else
            begin
              meta_nxt[i]       = datain[i];
              meta_state_nxt[i] = 1'b0;
            end
        end // for
    end

  always @( posedge clk )
    begin
      meta_state <= meta_state_nxt;
    end

// synthesis translate_on
`else
  (* ASYNC_REG = "TRUE" *) reg  [WIDTH-1:0] meta;
  (* ASYNC_REG = "TRUE" *) reg  [WIDTH-1:0] meta2;

  always @*
    begin
      meta_nxt = datain;
    end

`endif

  always @( posedge clk or negedge reset )
    begin
      if ( reset != 1'b1 )
        begin
          meta  <= {WIDTH{RESET_VALUE}};
          meta2 <= {WIDTH{RESET_VALUE}};
        end
      else
        begin
          meta  <= meta_nxt;
          meta2 <= meta;
        end
    end

  assign dataout_nxt = meta2;

  always @( posedge clk or negedge reset )
    begin
      if ( reset != 1'b1 )
        begin
          dataout_reg <= {WIDTH{RESET_VALUE}};
        end
      else
        begin
          dataout_reg <= dataout_nxt;
        end
    end

  assign dataout = dataout_reg;

endmodule // syncer_level
`default_nettype wire

