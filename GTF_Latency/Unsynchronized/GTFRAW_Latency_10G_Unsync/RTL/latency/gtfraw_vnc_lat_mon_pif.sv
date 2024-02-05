/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------
//
//  Description: AXI interface to misc. control and status registers
//
//------------------------------------------------------------------------------

// ***************************************************************************
// Misc control and status registers
// ***************************************************************************

module gtfraw_vnc_lat_mon_pif # (
    parameter   TIMER_WIDTH     = 16,
    parameter   RAM_DEPTH       = 4096,
    parameter   RAM_ADDR_WIDTH  = 12
)
(
    // AXI I/F 
    input   wire            axi_aclk,
    input   wire            axi_aresetn,

    input   wire    [31:0]  axil_araddr,
    input   wire            axil_arvalid,
    output  reg             axil_arready,

    output  reg     [31:0]  axil_rdata,
    output  wire    [1:0]   axil_rresp,
    output  reg             axil_rvalid,
    input   wire            axil_rready,

    input   wire    [31:0]  axil_awaddr,
    input   wire            axil_awvalid,
    output  reg             axil_awready,

    input   wire    [31:0]  axil_wdata,
    input   wire            axil_wvalid,
    output  reg             axil_wready,

    output  reg             axil_bvalid,
    output  wire    [1:0]   axil_bresp,
    input   wire            axil_bready,

    output  logic                           lm_go,
    input   logic                           lm_full,
    input   logic   [RAM_ADDR_WIDTH:0]      lm_datav,
    output  logic                           lm_pop,
    output  logic                           lm_clear,
    input   logic   [TIMER_WIDTH-1:0]       lm_snd_time,
    input   logic   [TIMER_WIDTH-1:0]       lm_rcv_time,
    input   logic                           lm_time_rdy,
    output  logic   [31:0]                  lm_lat_pkt_cnt,

    // Delta Data
    input   logic [31:0]                    lm_delta_time_accu,
    input   logic [31:0]                    lm_delta_time_idx,
    input   logic [TIMER_WIDTH-1:0]         lm_delta_time_max,
    input   logic [TIMER_WIDTH-1:0]         lm_delta_time_min,

    // Delta Control
    input   logic                           lm_delta_done_sync,
    input   logic [TIMER_WIDTH-1:0]         lm_delta_adj_factor
);

    localparam SEND_TIME_FIFO_ADDR = 12'h008;

    reg             axil_bvalid_next;
    reg     [2:0]   wr_state, wr_state_next;
    reg             do_write, do_write_next;
    reg     [11:0]  wr_addr, wr_addr_next;
    reg     [31:0]  wr_data, wr_data_next;
    reg             axil_awready_next;
    reg             axil_wready_next;
    reg             axil_arready_next, axil_arvalid_next, axil_rvalid_next;
    reg     [31:0]  rdata;
    reg     [31:0]  axil_rdata_next;
    reg     [11:0]  rd_addr, rd_addr_next;
    reg     [2:0]   rd_state, rd_state_next;
    reg             do_rd, do_rd_next;

    localparam      WR_IDLE_STATE               = 3'd0,
                    WR_GET_ADDR_STATE           = 3'd1,
                    WR_GET_DATA_STATE           = 3'd2,
                    WR_SET_DATA_STATE           = 3'd3,
                    WR_WAIT_FOR_BVALID_STATE    = 3'd4;

    localparam      RD_IDLE_STATE               = 3'd0,
                    RD_STATE                    = 3'd1,
                    RD_ACK_STATE                = 3'd2,
                    RD_FIFO_STATE               = 3'd3;


    assign axil_bresp = 2'd0; // Tie to 'OKAY'.
    assign axil_rresp = 2'd0; // Tie to 'Okay;.

    always_comb begin: COMB_LOGIC_WRITE_FSM_NEXT_STATE

        // Defaults.
        wr_state_next           = wr_state;
        wr_addr_next            = wr_addr;
        wr_data_next            = wr_data;
        do_write_next           = 1'b0;
        axil_awready_next       = 1'b0;
        axil_wready_next        = 1'b0;
        axil_bvalid_next        = 1'b0;

        case (wr_state)
            WR_IDLE_STATE: begin

                axil_awready_next = 1'b1;
                axil_wready_next = 1'b1;

                case ({axil_awvalid & axil_awready, axil_wvalid & axil_wready})

                    2'b10: begin
                        wr_state_next       = WR_GET_DATA_STATE;
                        wr_addr_next        = axil_awaddr[11:0]; // Flop in the address
                        axil_awready_next   = 1'b0; // De-assert address 'ready' sig.
                    end

                    2'b01: begin
                        wr_state_next       = WR_GET_ADDR_STATE;
                        wr_data_next        = axil_wdata;
                        axil_wready_next    = 1'b0;
                    end

                    2'b11: begin
                        wr_state_next       = WR_SET_DATA_STATE;
                        wr_addr_next        = axil_awaddr[11:0];
                        wr_data_next        = axil_wdata;
                        axil_wready_next    = 1'b0;
                    end

                    2'b00: begin
                        wr_state_next = WR_IDLE_STATE;
                    end
                endcase
            end // WR_IDLE_STATE

            WR_GET_ADDR_STATE: begin


                axil_awready_next         = 1'b1;
                wr_addr_next              = axil_awaddr[11:0];

                if (axil_awvalid & axil_awready) begin
                    axil_awready_next   = 1'b0;
                    wr_state_next       = WR_SET_DATA_STATE;
                end
            end // WR_GET_ADDR_STATE

            WR_GET_DATA_STATE: begin

                axil_wready_next        = 1'b1;

                if (axil_wvalid & axil_wready) begin
                    axil_wready_next    = 1'b0;
                    wr_data_next        = axil_wdata;
                    wr_state_next       = WR_SET_DATA_STATE;
                end
            end // WR_GET_DATA_STATE

            WR_SET_DATA_STATE: begin

                do_write_next = 1'b1;
                axil_bvalid_next = 1'b1;
                wr_state_next = WR_WAIT_FOR_BVALID_STATE;

            end // WR_SET_DATA_STATE


            WR_WAIT_FOR_BVALID_STATE: begin

                axil_bvalid_next = 1'b1;

                // Get the bresp ack
                if (axil_bvalid == 1'b1 && axil_bready == 1'b1) begin

                    axil_bvalid_next    = 1'b0;
                    wr_state_next       = WR_IDLE_STATE;
                end

            end // WR_SET_DATA_STATE
        endcase
    end // COMB_LOGIC_WRITE_FSM_NEXT_STATE

    always_comb begin: READ_FSM_NEXT_STATE_LOGIC

        // Defaults...
        rd_state_next           = rd_state;
        axil_rdata_next         = axil_rdata;
        rd_addr_next            = rd_addr;
        do_rd_next              = 1'b0;
        axil_arready_next       = 1'b0;
        axil_rvalid_next        = 1'b0;

        case (rd_state)

            RD_IDLE_STATE: begin
                axil_arready_next = 1'b1;
                if (axil_arvalid == 1'b1 && axil_arready == 1'b1) begin
                    rd_addr_next        = axil_araddr[11:0];
                    do_rd_next          = 1'b1;
                    rd_state_next       = (axil_araddr[11:0] == SEND_TIME_FIFO_ADDR) ? RD_FIFO_STATE : RD_STATE;
                    axil_arready_next   = 1'b0;
                end
            end

            RD_STATE: begin
                axil_rdata_next   = rdata;
                axil_rvalid_next  = 1'b1;
                rd_state_next       = RD_ACK_STATE;
            end

            RD_FIFO_STATE: begin
                if (lm_time_rdy) begin
                    rd_state_next       = RD_STATE;
                end
            end

            RD_ACK_STATE: begin  // RD_ACK_STATE
                axil_rvalid_next = axil_rvalid;
                if (axil_rvalid == 1'b1 && axil_rready == 1'b1) begin
                    axil_rvalid_next    = 1'b0;
                    rd_state_next       = RD_IDLE_STATE;
                end
            end

            default: begin  // RD_ACK_STATE
                axil_rvalid_next = axil_rvalid;
                if (axil_rvalid == 1'b1 && axil_rready == 1'b1) begin
                    axil_rvalid_next    = 1'b0;
                    rd_state_next       = RD_IDLE_STATE;
                end
            end
        endcase

    end // READ_FSM_NEXT_STATE_LOGIC

    always @ (posedge axi_aclk) begin : ASSIGN_WRITE_FSM_NEXT_STATE
        if (axi_aresetn == 1'b0) begin
            wr_state            <= WR_IDLE_STATE;
            do_write            <= 1'b0;
            axil_awready        <= 1'b0;
            axil_wready         <= 1'b0;
        end
        else begin
            wr_state            <= wr_state_next;
            do_write            <= do_write_next;
            axil_awready        <= axil_awready_next;
            axil_wready         <= axil_wready_next;
            axil_bvalid         <= axil_bvalid_next;
        end

        wr_addr                 <= wr_addr_next;
        wr_data                 <= wr_data_next;
    end // ASSIGN_WRITE_FSM_NEXT_STATE

    always @ (posedge axi_aclk) begin: ASSIGN_READ_FSM_NEXT_STATE
        if (axi_aresetn == 1'b0) begin
            rd_state            <= RD_IDLE_STATE;
            axil_arready        <= 1'b0;
            axil_rvalid         <= 1'b0;
            axil_rdata          <= 32'd0;
            do_rd               <= 1'b0;
        end
        else begin
            rd_state            <= rd_state_next;
            axil_rdata          <= axil_rdata_next;
            axil_arready        <= axil_arready_next;
            axil_rvalid         <= axil_rvalid_next;
            do_rd               <= do_rd_next;
        end
        rd_addr     <= rd_addr_next;
    end

    logic   [31:0]   scratch_0;
    logic            sticky_lm_full;

    always @ (posedge axi_aclk) begin: REGISTER_WRITE

        if (axi_aresetn == 1'b0) begin

            lm_go                               <= 'd0;
            lm_pop                              <= 'd0;
            lm_clear                            <= 'd0;
            sticky_lm_full                      <= 1'b0;
            lm_lat_pkt_cnt                      <= '0;

        end
        else begin

            lm_clear    <= 1'b0;
            lm_pop      <= 1'b0;

            if (do_rd_next && rd_addr_next == SEND_TIME_FIFO_ADDR) begin
                lm_pop  <= 1'b1;
            end

            if (lm_full)                sticky_lm_full           <= 1'b1;
            // if (lm_full)                lm_go                    <= 1'b0;


            if (do_write) begin

                if (wr_addr == 12'h000) begin
                    lm_go           <= wr_data[0];
                    lm_clear        <= wr_data[4];
                end
                else if (wr_addr == 12'h004) begin
                    sticky_lm_full  <= ~wr_data[16]; // W1C
                end
                else if (wr_addr == 12'h012) begin
                    lm_lat_pkt_cnt  <= wr_data;
                end

            end

        end

    end


    always_comb begin : READ_DATA_COMBINATORIAL

        rdata = 32'h0;

        unique if (rd_addr == 12'h000) begin
            rdata[0]        = lm_go;
        end
        else if (rd_addr == 12'h004) begin
            rdata[RAM_ADDR_WIDTH:0] = lm_datav;
            rdata[16]               = sticky_lm_full;
        end

        //  Special handling by the AXI-Lite state machine above
        else if (rd_addr == SEND_TIME_FIFO_ADDR) begin
            rdata[TIMER_WIDTH-1:0]      = lm_snd_time;
            rdata[TIMER_WIDTH-1+16:16]  = lm_rcv_time;
        end
        else if (rd_addr == 12'h012) begin
            rdata = lm_lat_pkt_cnt;
        end
        else if (rd_addr == 12'h016) begin
            rdata = lm_delta_time_accu;
        end
        else if (rd_addr == 12'h020) begin
            rdata = lm_delta_time_idx;
        end
        else if (rd_addr == 12'h024) begin
            rdata[15:0] = lm_delta_time_max;
            rdata[31:16] = lm_delta_time_min;
        end
        else if (rd_addr == 12'h028) begin
            rdata = {31'b0, lm_delta_done_sync};
        end
        else if (rd_addr == 12'h032) begin
            rdata = {16'b0, lm_delta_adj_factor};
        end
        else begin
            rdata = 32'h0;
        end
    end

endmodule
