/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

module gtfmac_vnc_tx_gtfmac_if # (
   parameter AXI_IF_DEPTH = 4'd8    // Needs to match credit depth of tx_gen_buf
)
(

    input   wire            tx_axis_clk,
    input   wire            tx_axis_rst,

    input   wire            din_ena,
    input   wire            din_pre,
    input   wire            din_sop,
    input   wire [63:0]     din_data,
    input   wire [7:0]      din_last,
    input   wire            din_err,
    output  wire            tx_credit,

    input   wire            tx_axis_tready,
    output  logic           tx_axis_tvalid,

    output  logic           tx_sop,
    output  logic [63:0]    tx_axis_tdata,
    output  logic [7:0]     tx_axis_tlast,
    output  logic [7:0]     tx_axis_tpre,
    output  logic           tx_axis_terr,
    output  logic [4:0]     tx_axis_tterm,
    output  logic [1:0]     tx_axis_tsof,
    output  logic           tx_axis_tpoison,
    input   wire            tx_axis_tcan_start,
    input   wire            tx_unfout,

    output  logic           tx_start_measured_run,

    input   wire            tx_ptp_sop,
    input   wire            tx_ptp_sop_pos,

    input   wire            tx_gb_seq_start,
    output  logic           tx_gb_seq_sync,

    input   wire            ctl_tx_fcs_ins_enable,
    input   wire            ctl_tx_data_rate,
    input   wire            ctl_tx_custom_preamble_en,
    input   wire            ctl_tx_start_framing_enable,
    input   wire            ctl_tx_variable_ipg,

    output  logic           tx_buffer_overflow

);

`include "gtfmac_vnc_top.vh"

    wire [63:0]     gen_tdata;
    wire [7:0]      gen_tlast;
    wire [7:0]      gen_tpre;
    wire            gen_terr;
    wire [4:0]      gen_tterm;
    wire [1:0]      gen_tsof;
    wire            gen_tpoison;
    wire            gen_sop;
    wire            gen_lat;

    wire            out_sop, out_lat;
    wire [63:0]     out_tdata;
    wire [7:0]      out_tlast;
    wire [7:0]      out_tpre;
    wire            out_terr;
    wire [4:0]      out_tterm;
    wire [1:0]      out_tsof;
    wire            out_tpoison;

    reg [1:0]       dm_cnt;
    reg [2:0]       eop_count;
    logic           data_valid;

    logic [2:0]     ipg, cnt;


    // Insert gaps between frames, if we are "ctl_tx_variable_ipg"
    always @(posedge tx_axis_clk) begin

        cnt    <= cnt + 1'b1;

        if (ctl_tx_variable_ipg) begin

            if (eop_count == 2'd1 && |cnt == 1'b1) begin
                ipg <= cnt;
            end
            else if (|ipg) begin
                ipg <= ipg - 1'b1;
            end

        end

        if (tx_axis_rst == 1'b1) begin
            ipg     <= 3'd0;
            cnt    <= 3'd0;
        end

    end


    // Stage outbound frames in this FIFO.  A credit is generated when the read side pops a cycle.
    wire    pop_axi_fifo;
    wire    data_fifo_empty;
    wire    axi_full;

    wire    no_rd   = data_fifo_empty || (|ipg) || ctl_tx_variable_ipg && (eop_count == 2'd1 && |cnt == 1'b1);


    assign pop_axi_fifo     = (dm_cnt == 0 || eop_count == 2'd1) && ((tx_axis_tready && data_valid && !no_rd) || !(data_valid || no_rd));
    assign tx_credit        = pop_axi_fifo;

    // Create the GTFMAC-facing signalling based on the din input.

    assign  gen_sop     = din_sop & ~ctl_tx_custom_preamble_en | din_pre & ctl_tx_custom_preamble_en;
    assign  gen_lat     = din_sop && din_data[15:0] == 16'hFACE;
    assign  gen_tdata   = din_data;
    assign  gen_tlast   = din_last;
    assign  gen_tpre    = {8{ctl_tx_custom_preamble_en & din_pre}};
    assign  gen_terr    = din_err;
    assign  gen_tterm   = 5'd0;
    assign  gen_tsof    = {1'b0, ctl_tx_start_framing_enable & din_pre};
    assign  gen_tpoison = 1'b0; // TODO

    localparam  FIFO_WIDTH  =
                   1  +  // sop
                   1  +  // lat
                   64 +  // data
                   8  +  // tlast
                   8  +  // tpre
                   1  +  // terr
                   5  +  // tterm
                   1  +  // tpoison
                   2     // tsof
                   ;

    logic   [FIFO_WIDTH-1:0]    adv_spare;
    logic   [1:0]               adv_tsof;

    gtfmac_vnc_simple_fifo #(
       .WIDTH     (FIFO_WIDTH),
       .REG       (1),
       .DEPTH     (AXI_IF_DEPTH),
       .DEPTHLOG2 (4)  // Max 15
    ) i_axi_fifo  (
       .clk               (tx_axis_clk),
       .reset             (tx_axis_rst),

       .we                (din_ena),
       .wdat              ({gen_sop, gen_lat, gen_tdata, gen_tlast, gen_tpre, gen_terr, gen_tterm, gen_tpoison, gen_tsof}),

       .re                (pop_axi_fifo),
       .rdat_unreg        ({adv_spare[FIFO_WIDTH-1:2], adv_tsof}),
       .rdat              ({out_sop, out_lat, out_tdata, out_tlast, out_tpre, out_terr, out_tterm, out_tpoison, out_tsof}),

       .full_threshold    (AXI_IF_DEPTH[4:0]),
       .a_empty_threshold (5'd0),
       .a_full_threshold  (5'd0),
       .c_threshold       (5'd0),

       .empty             (data_fifo_empty),
       .almost_empty      (),
       .almost_full       (),
       .centered          (),
       .fill_level        (),
       .full              (axi_full)
    );

    assign  tx_buffer_overflow    = axi_full & din_ena & ~pop_axi_fifo;

    logic   tready;
    assign  tready = tx_axis_tready | out_tsof[0];

    always @(posedge tx_axis_clk) begin

        if (pop_axi_fifo == 1'b1) begin
            data_valid      <= 1'b1;
            tx_axis_tvalid  <= ~adv_tsof[0];
            dm_cnt          <= (ctl_tx_data_rate) ? 2'd0 : 2'd3;
        end
        else begin

            if (|dm_cnt && tready) begin
                dm_cnt <= dm_cnt - 1'b1;
            end

            if (tready & data_valid == 1'b1 && (|dm_cnt == 1'b0 || eop_count == 2'd1) ) begin
                data_valid      <= 1'b0;
                tx_axis_tvalid  <= 1'b0;
            end

        end

        if (tx_axis_rst == 1'b1) begin
           data_valid       <= 1'b0;
           tx_axis_tvalid   <= 1'b0;
           dm_cnt           <= 2'd0;
        end
    end

    always @(posedge tx_axis_clk) begin

        if (|eop_count & tready) begin
            eop_count <= eop_count - 1'b1;
        end
        else if (ctl_tx_data_rate == 1'b0) begin

            if (tready & data_valid & |tx_axis_tlast[1:0]) begin
                eop_count   <= (ctl_tx_fcs_ins_enable) ? 2'd1 : 2'd3;
            end

        end

        if (tx_axis_rst == 1'b1) begin
            eop_count   <= 3'd0;
        end

    end

    always @ (*) begin

        tx_sop                  = (ctl_tx_data_rate || !ctl_tx_data_rate && dm_cnt == 2'd3) ? out_sop : 1'b0;
        tx_axis_tdata           = out_tdata;

        if (!ctl_tx_data_rate) begin

            tx_axis_tlast   = 8'h0;
            tx_axis_tpre    = 8'h0;

            case (dm_cnt)

                2'd3: begin
                    tx_axis_tdata[15:0]     = out_tdata[15:0];
                    tx_axis_tlast[1:0]      = out_tlast[1:0];
                    tx_axis_tpre[1:0]       = out_tpre[1:0];
                    tx_start_measured_run   = out_lat;
                end

                2'd2: begin
                    tx_axis_tdata[15:0]     = out_tdata[31:16];
                    tx_axis_tlast[1:0]      = out_tlast[3:2];
                    tx_axis_tpre[1:0]       = out_tpre[3:2];
                    tx_start_measured_run   = 1'b0;
                end

                2'd1: begin
                    tx_axis_tdata[15:0]     = out_tdata[47:32];
                    tx_axis_tlast[1:0]      = out_tlast[5:4];
                    tx_axis_tpre[1:0]       = out_tpre[5:4];
                    tx_start_measured_run   = 1'b0;
                end

                default: begin
                    tx_axis_tdata[15:0]     = out_tdata[63:48];
                    tx_axis_tlast[1:0]      = out_tlast[7:6];
                    tx_axis_tpre[1:0]       = out_tpre[7:6];
                    tx_start_measured_run   = 1'b0;
                end

            endcase

        end
        else begin

            tx_axis_tlast           = out_tlast;
            tx_axis_tpre            = out_tpre;
            tx_start_measured_run   = out_lat;

        end
    end

    always @ (*) begin

        if (ctl_tx_data_rate || dm_cnt == 2'd3) begin
            tx_axis_terr            = out_terr;
            tx_axis_tterm           = out_tterm;
            tx_axis_tsof            = out_tsof;
            tx_axis_tpoison         = out_tpoison;
        end
        else begin
            tx_axis_terr            = 1'b0;
            tx_axis_tterm           = 5'd0;
            tx_axis_tsof            = 2'd0;
            tx_axis_tpoison         = 1'b0;
        end

    end


endmodule
