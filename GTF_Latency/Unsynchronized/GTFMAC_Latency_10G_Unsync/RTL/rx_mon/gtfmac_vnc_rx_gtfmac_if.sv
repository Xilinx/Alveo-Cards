/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

module gtfmac_vnc_rx_gtfmac_if (

    input   wire            rx_axis_clk,
    input   wire            rx_axis_rst,

    input   wire            ctl_rx_data_rate,
    input   wire            ctl_rx_custom_preamble_en,

    input   wire            rx_axis_tvalid,
    input   wire   [63:0]   rx_axis_tdata,
    input   wire   [7:0]    rx_axis_tlast,
    input   wire   [7:0]    rx_axis_tpre,
    input   wire            rx_axis_terr,
    input   wire   [4:0]    rx_axis_tterm,
    input   wire   [1:0]    rx_axis_tsof,


    output  logic           dout_ena,
    output  logic           dout_sop,
    output  logic  [63:0]   dout_data,
    output  logic           dout_eop,
    output  logic  [2:0]    dout_mty,
    output  logic           dout_err,
    output  logic           dout_empty,
    output  logic           rx_start_measured_run,

    output  logic           stat_bad_tpre,
    output  logic           stat_unexpected_tpre,
    output  logic           stat_missing_preamble,
    output  logic           stat_missed_tterm,
    output  logic           stat_terminate_during_preamble,
    output  logic           stat_missed_tsof,
    output  logic           stat_incomplete_preamble,
    output  logic           stat_invalid_tterm


);

    logic   [1:0]   cycle_cnt;
    logic           frame_active;
    logic           collect_preamble;
    logic           late_eop;
    logic           new_frame;
    logic           flush;

    logic           ena, hold_ena;
    logic           sop, hold_sop;
    logic           get_da;
    logic  [63:0]   data, hold_data;
    logic           eop, hold_eop;
    logic           err, hold_err;
    logic  [2:0]    mty, hold_mty;
    logic           delayed_empty, empty, hold_empty;
    logic  [4:0]    tterm;
    logic  [4:0]    err_cnt;

    logic           q_rx_axis_tvalid;
    logic  [63:0]   q_rx_axis_tdata;
    logic  [7:0]    q_rx_axis_tlast;
    logic  [7:0]    q_rx_axis_tpre;
    logic           q_rx_axis_terr;
    logic  [4:0]    q_rx_axis_tterm;
    logic  [1:0]    q_rx_axis_tsof;

    always @(posedge rx_axis_clk) begin

        ena                 <= 1'b0;
        sop                 <= 1'b0;
        eop                 <= 1'b0;
        err                 <= 1'b0;
        mty                 <= 3'd0;
        late_eop            <= 1'b0;
        delayed_empty       <= 1'b0;
        empty               <= 1'b0;
        flush               <= 1'b0;

        q_rx_axis_tvalid    <= rx_axis_tvalid;
        q_rx_axis_tdata     <= rx_axis_tdata;
        q_rx_axis_tlast     <= rx_axis_tlast;
        q_rx_axis_tpre      <= rx_axis_tpre;
        q_rx_axis_terr      <= rx_axis_terr;
        q_rx_axis_tterm     <= rx_axis_tterm;
        q_rx_axis_tsof      <= rx_axis_tsof;

        stat_bad_tpre                   <= 1'b0;
        stat_unexpected_tpre            <= 1'b0;
        stat_missing_preamble           <= 1'b0;
        stat_missed_tterm               <= 1'b0;
        stat_terminate_during_preamble  <= 1'b0;
        stat_missed_tsof                <= 1'b0;
        stat_incomplete_preamble        <= 1'b0;
        stat_invalid_tterm              <= 1'b0;

        if (frame_active == 1'b0) begin

            cycle_cnt           <= 2'd0;
            collect_preamble    <= 1'b0;
            new_frame           <= 1'b0;

            if (q_rx_axis_tsof[1]) begin

                frame_active    <= 1'b1;
                flush           <= |err_cnt;
                err_cnt         <= 5'd0;

                if (ctl_rx_data_rate && q_rx_axis_tterm == 5'h18) begin
                    tterm           <= 5'h18;
                    delayed_empty   <= 1'b1;
                end

                if (|q_rx_axis_tpre) begin
                    data    <= q_rx_axis_tdata;
                    if (!ctl_rx_data_rate) begin
                        collect_preamble    <= 1'b1;
                        cycle_cnt           <= 2'd1;
                        new_frame           <= 1'b1;
                    end
                    else begin
                        ena                 <= 1'b1;
                        sop                 <= 1'b1;
                    end
                end
                else begin
                    new_frame   <= 1'b1;
                end

            end // q_rx_axis_tsof[1]
            else if (err_cnt == 5'd1 || q_rx_axis_terr) begin
                flush       <= 1'b1;
                err         <= q_rx_axis_terr;
                err_cnt     <= 5'd0;
            end
            else begin
                err_cnt     <= (|err_cnt) ? err_cnt - 1'b1 : 5'd0;
            end


        end
        else begin  // frame_active == 1

            if (ctl_rx_data_rate) begin // 25G

                err         <= q_rx_axis_terr;
                data        <= q_rx_axis_tdata;

                // Capture tterm for future integrity check
                if (!tterm[4]) begin
                    tterm       <= q_rx_axis_tterm;
                end

                if (q_rx_axis_tlast[0] || new_frame && q_rx_axis_tterm == 5'h10 || delayed_empty) begin

                    new_frame       <= 1'b0;
                    frame_active    <= 1'b0;
                    err_cnt         <= 5'd2;

                    if (new_frame) begin
                        ena             <= 1'b1;
                        sop             <= 1'b1;
                        eop             <= 1'b1;
                        empty           <= 1'b1;
                    end
                    else begin
                        late_eop        <= 1'b1;
                    end

                end
                else if (q_rx_axis_tvalid) begin

                    new_frame       <= 1'b0;
                    ena             <= 1'b1;
                    sop             <= new_frame;

                    if (|q_rx_axis_tlast) begin

                        eop             <= 1'b1;
                        frame_active    <= 1'b0;
                        err_cnt         <= 5'd2;

                        case (q_rx_axis_tlast)

                            8'b0000_0010: begin mty         <= 3'd7; end
                            8'b0000_0100: begin mty         <= 3'd6; end
                            8'b0000_1000: begin mty         <= 3'd5; end
                            8'b0001_0000: begin mty         <= 3'd4; end
                            8'b0010_0000: begin mty         <= 3'd3; end
                            8'b0100_0000: begin mty         <= 3'd2; end
                            8'b1000_0000: begin mty         <= 3'd1; end
                            default:      begin mty         <= 3'd0; end

                        endcase

                    end

                end // if (q_rx_axis_tvalid)

            end
            else begin  // 10G

                err <= err | q_rx_axis_terr;

                // Capture tterm for future integrity check
                if (!tterm[4]) begin
                    tterm       <= q_rx_axis_tterm;
                end

                case (cycle_cnt)

                    2'd0: begin
                        data <= {48'd0, q_rx_axis_tdata[15:0]};
                    end
                    2'd1: begin
                        data[31:16] <= q_rx_axis_tdata[15:0];
                    end
                    2'd2: begin
                        data[47:32] <= q_rx_axis_tdata[15:0];
                    end
                    default: begin
                        data[63:48] <= q_rx_axis_tdata[15:0];
                    end

                endcase

                if (|q_rx_axis_tpre || q_rx_axis_tvalid) begin
                    cycle_cnt   <= cycle_cnt + 1'b1;
                end

                if (new_frame && q_rx_axis_tterm[4] == 1'b1) begin

                    new_frame       <= 1'b0;
                    frame_active    <= 1'b0;
                    err_cnt         <= 5'd9;

                    ena             <= 1'b1;
                    sop             <= 1'b1;
                    eop             <= 1'b1;
                    empty           <= 1'b1;

                end
                else if (|q_rx_axis_tlast[1:0] || (|q_rx_axis_tpre || q_rx_axis_tvalid) && cycle_cnt == 2'd3) begin

                    ena                 <= 1'b1;
                    sop                 <= new_frame;
                    new_frame           <= 1'b0;
                    collect_preamble    <= 1'b0;

                    if (|q_rx_axis_tlast[1:0]) begin

                        frame_active    <= 1'b0;
                        err_cnt         <= 5'd9;

                        if (q_rx_axis_tlast[0] && cycle_cnt == 2'd0) begin
                            late_eop    <= 1'b1;
                            ena         <= 1'b0;
                        end
                        else begin
                            eop         <= 1'b1;
                        end

                        case (cycle_cnt)

                            2'd0: begin
                                mty <= (q_rx_axis_tlast[0]) ? 3'd0 : 3'd7;    // late eop
                            end
                            2'd1: begin
                                mty <= (q_rx_axis_tlast[0]) ? 3'd6 : 3'd5;
                            end
                            2'd2: begin
                                mty <= (q_rx_axis_tlast[0]) ? 3'd4 : 3'd3;
                            end
                            default: begin
                                mty <= (q_rx_axis_tlast[0]) ? 3'd2 : 3'd1;
                            end

                        endcase

                    end

                end

            end

        end


        if (rx_axis_rst == 1'b1) begin

            q_rx_axis_tvalid    <= 1'b0;

            ena                 <= 1'b0;
            sop                 <= 1'b0;
            eop                 <= 1'b0;
            err                 <= 1'b0;
            mty                 <= 3'd0;
            late_eop            <= 1'b0;
            empty               <= 1'b0;
            delayed_empty       <= 1'b0;

            cycle_cnt           <= 2'd0;
            collect_preamble    <= 1'b0;
            new_frame           <= 1'b0;
            frame_active        <= 1'b0;
            flush               <= 1'b0;
            err_cnt             <= 5'd0;

            stat_bad_tpre                   <= 1'b0;
            stat_unexpected_tpre            <= 1'b0;
            stat_missing_preamble           <= 1'b0;
            stat_missed_tterm               <= 1'b0;
            stat_terminate_during_preamble  <= 1'b0;
            stat_missed_tsof                <= 1'b0;
            stat_incomplete_preamble        <= 1'b0;
            stat_invalid_tterm              <= 1'b0;

        end

    end


    always @(posedge rx_axis_clk) begin

        dout_ena                <= 1'b0;
        dout_sop                <= 1'b0;
        dout_data               <= 1'b0;
        dout_eop                <= 1'b0;
        dout_mty                <= 1'b0;
        dout_err                <= 1'b0;
        dout_empty              <= 1'b0;
        rx_start_measured_run   <= 1'b0;

        begin

            if (ena || flush) begin

                hold_ena    <= ena;
                hold_sop    <= sop;
                get_da      <= hold_sop;
                hold_data   <= data;
                hold_eop    <= eop;
                hold_mty    <= mty;
                hold_err    <= err;
                hold_empty  <= empty;

            end
            else if (late_eop) begin
                hold_eop    <= 1'b1;
                hold_err    <= hold_err | err;
            end

            // If we are holding and new data comes in, or a flush, push out to to the datapath
            if (hold_ena && ena || flush) begin

                dout_ena                <= hold_ena;
                dout_sop                <= hold_sop;
                dout_data               <= hold_data;
                dout_eop                <= hold_eop | late_eop;
                dout_mty                <= hold_mty;
                dout_err                <= hold_err | err;
                dout_empty              <= hold_empty;

                // Signal to the latency measurement logic whether to begin a 'run'.  If we have
                // custom_preamble enabled, then SOP will be the preamble and we want to wait for the DA.
                // If not, then SOP will be the DA and we start the run.
                rx_start_measured_run   <= (hold_data[15:0] == 16'hFACE) ? (hold_sop & ~ctl_rx_custom_preamble_en | get_da & ctl_rx_custom_preamble_en) : 1'b0;

            end

        end

        if (rx_axis_rst == 1'b1) begin
            dout_ena                <= 1'b0;
            dout_sop                <= 1'b0;
            dout_eop                <= 1'b0;
            dout_mty                <= 1'b0;
            dout_err                <= 1'b0;
            dout_empty              <= 1'b0;

            rx_start_measured_run   <= 1'b0;
            get_da                  <= 1'b0;

            hold_ena                <= 1'b0;
            hold_sop                <= 1'b0;
            hold_eop                <= 1'b0;
            hold_mty                <= 1'b0;
            hold_err                <= 1'b0;
            hold_empty              <= 1'b0;
        end


    end

endmodule

