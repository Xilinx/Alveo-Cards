/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------
//
//  Description: AXI interface to misc. control and status registers
//
//------------------------------------------------------------------------------

`ifndef GTFMAC_VNC_VERSION
`define GTFMAC_VNC_VERSION 16'h10
`endif

module gtfmac_vnc_vnc_pif (

    // ============================================================
    // AXI Ports : BEGIN
    // ============================================================

    // AXI Globals
    input                   axi_aclk,
    input                   axi_aresetn,

    // AXI: Read Address Channel
    input   wire    [31:0]  axil_araddr,
    input   wire            axil_arvalid,
    output  reg             axil_arready,

    // Read Data Channel
    output  reg     [31:0]  axil_rdata,
    output  wire    [1:0]   axil_rresp,
    output  reg             axil_rvalid,
    input                   axil_rready,

    // Write Address Channel
    input   wire    [31:0]  axil_awaddr,
    input   wire            axil_awvalid,
    output  reg             axil_awready,

    // Write Data Channel
    input   wire    [31:0]  axil_wdata,
    input   wire            axil_wvalid,
    output  reg             axil_wready,

    // Write Response Channel
    output  reg             axil_bvalid,
    output  wire    [1:0]   axil_bresp,
    input                   axil_bready,

    // ============================================================
    // AXI Ports : END
    // ============================================================

    // Clock counters

    input       logic [31:0]    tx_clk_cps,
    input       logic [31:0]    rx_clk_cps,
    input       logic [31:0]    axi_aclk_cps,
    input       logic [31:0]    gen_clk_cps,
    input       logic [31:0]    mon_clk_cps,
    input       logic [31:0]    lat_clk_cps,

    // Debug resets
    output      logic           vnc_gtf_ch_gttxreset,
    output      logic           vnc_gtf_ch_txpmareset,
    output      logic           vnc_gtf_ch_txpcsreset,
    output      logic           vnc_gtf_ch_gtrxreset,
    output      logic           vnc_gtf_ch_rxpmareset,
    output      logic           vnc_gtf_ch_rxdfelpmreset,
    output      logic           vnc_gtf_ch_eyescanreset,
    output      logic           vnc_gtf_ch_rxpcsreset,
    output      logic           vnc_gtf_cm_qpll0reset,

    output      logic           vnc_gtf_ch_txuserrdy,
    output      logic           vnc_gtf_ch_rxuserrdy,

    output      logic           gtwiz_reset_tx_pll_and_datapath_in,
    output      logic           gtwiz_reset_tx_datapath_in,
    output      logic           gtwiz_reset_rx_pll_and_datapath_in,
    output      logic           gtwiz_reset_rx_datapath_in,

    // GTFMAC Status
    input       logic           stat_gtf_tx_rst,
    input       logic           stat_gtf_rx_rst,
    input       logic           stat_gtf_block_lock,
    input       wire            stat_gtf_rx_internal_local_fault,
    input       wire            stat_gtf_rx_local_fault,
    input       wire            stat_gtf_rx_received_local_fault,
    input       wire            stat_gtf_rx_remote_fault,

    // Bitslip correction
    output      logic           ctl_gb_seq_sync,
    output      logic           ctl_disable_bitslip,
    output      logic           ctl_correct_bitslip,
    input       logic   [6:0]   stat_bitslip_cnt,
    input       logic   [6:0]   stat_bitslip_issued,
    input       logic           stat_excessive_bitslip,
    input       logic           stat_bitslip_locked,
    input       logic           stat_bitslip_busy,
    input       logic           stat_bitslip_done,

    // Generator
    output      logic           ctl_vnc_frm_gen_en,
    output      logic           ctl_vnc_frm_gen_mode,
    output      logic   [13:0]  ctl_vnc_max_len,
    output      logic   [13:0]  ctl_vnc_min_len,
    output      logic   [31:0]  ctl_num_frames,
    input       logic           ack_frm_gen_done,

    output      logic           ctl_tx_start_framing_enable,
    output      logic           ctl_tx_custom_preamble_en,
    output      logic   [63:0]  ctl_vnc_tx_custom_preamble,
    output      logic           ctl_tx_variable_ipg,

    output      logic           ctl_tx_fcs_ins_enable,
    output      logic           ctl_tx_data_rate,

    // Monitor
    output      logic           ctl_vnc_mon_en,
    output      logic           ctl_rx_data_rate,
    output      logic           ctl_rx_packet_framing_enable,
    output      logic           ctl_rx_custom_preamble_en,
    output      logic   [63:0]  ctl_vnc_rx_custom_preamble,

    // VNC Statistics
    output      logic           stat_tick,
    output      logic [31:0]    scratch_0,


    // Latency run controls
    output      logic           ctl_vnc_tx_start_lat_run,
    input       wire            ack_vnc_tx_start_lat_run

);

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

    // Write Data - State Machine
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

    // -----------------------------------------------------------------
    // Determine next state of write FSM - combinatorial logic
    // -----------------------------------------------------------------
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

                    2'b10: begin // Have address, so get data
                        wr_state_next       = WR_GET_DATA_STATE;
                        wr_addr_next        = axil_awaddr[11:0];
                        axil_awready_next   = 1'b0;
                    end

                    2'b01: begin // Have data, get address
                        wr_state_next       = WR_GET_ADDR_STATE;
                        wr_data_next        = axil_wdata;
                        axil_wready_next    = 1'b0;
                    end

                    2'b11: begin // Have both..
                        wr_state_next       = WR_SET_DATA_STATE;
                        wr_addr_next        = axil_awaddr[11:0];
                        wr_data_next        = axil_wdata;
                        axil_wready_next    = 1'b0;
                    end

                    2'b00: begin // Have nothing!
                        // Do nothing. Just wait.
                        wr_state_next = WR_IDLE_STATE;
                    end
                endcase
            end // WR_IDLE_STATE

            WR_GET_ADDR_STATE: begin

                // If we're here, it's implied that (axil_wvalid
                // & axil_wready) == 1'b1 on the previous aclk rising edge.

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
                    axil_wready_next    = 1'b0; // De-assert 'ready' on the next cycle
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

                    // If we're ready, wait until the master asserts bvalid,
                    // and then go back to the IDLE state.
                    axil_bvalid_next    = 1'b0;
                    wr_state_next       = WR_IDLE_STATE;
                end

            end // WR_SET_DATA_STATE
        endcase
    end // COMB_LOGIC_WRITE_FSM_NEXT_STATE

    // -----------------------------------------------------------------
    // Read FSM: Combinatorial Next-State Logic
    // -----------------------------------------------------------------
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
                axil_arready_next = 1'b1; // We're ready for a read address transaction.
                if (axil_arvalid == 1'b1 && axil_arready == 1'b1) begin
                    rd_addr_next        = axil_araddr[11:0];
                    do_rd_next          = 1'b1;
                    rd_state_next       = RD_STATE;
                    axil_arready_next   = 1'b0;
                end
            end

            RD_STATE: begin
                axil_rdata_next   = rdata;
                axil_rvalid_next  = 1'b1;
                rd_state_next       = RD_ACK_STATE;
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

    // -----------------------------------------------------------------
    // Assign next state for write FSM/def. state if reset is high
    // -----------------------------------------------------------------
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

        // Unconditionally flop these in
        wr_addr                 <= wr_addr_next;
        wr_data                 <= wr_data_next;
    end // ASSIGN_WRITE_FSM_NEXT_STATE

    // -----------------------------------------------------------------
    // Flop in next read FSM state, handle state under a reset
    // -----------------------------------------------------------------
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

    //logic   [31:0]   scratch_0;
    logic            sticky_lm_full;

    // ============================================================
    // Write Logic -- BEGIN
    // ============================================================
    always @ (posedge axi_aclk) begin: REGISTER_WRITE

        // Reset read/write registers to their default value.
        if (axi_aresetn == 1'b0) begin

            scratch_0                           <= 'd0;

            vnc_gtf_ch_gttxreset                <= 'd0;
            vnc_gtf_ch_txpmareset               <= 'd0;
            vnc_gtf_ch_txpcsreset               <= 'd0;
            vnc_gtf_ch_gtrxreset                <= 'd0;
            vnc_gtf_ch_rxpmareset               <= 'd0;
            vnc_gtf_ch_rxdfelpmreset            <= 'd0;
            vnc_gtf_ch_eyescanreset             <= 'd0;
            vnc_gtf_ch_rxpcsreset               <= 'd0;
            vnc_gtf_cm_qpll0reset               <= 'd0;

            vnc_gtf_ch_txuserrdy                <= 'd0;
            vnc_gtf_ch_rxuserrdy                <= 'd0;

            gtwiz_reset_tx_pll_and_datapath_in  <= 'd0;
            gtwiz_reset_tx_datapath_in          <= 'd0; // 1'b1;
            gtwiz_reset_rx_pll_and_datapath_in  <= 'd0;
            gtwiz_reset_rx_datapath_in          <= 'd0; // 1'b1;

            ctl_tx_data_rate                    <= 'd0;
            ctl_tx_fcs_ins_enable               <= 'd0;
            ctl_tx_start_framing_enable         <= 'd0;
            ctl_tx_custom_preamble_en           <= 'd0;
            ctl_rx_data_rate                    <= 'd0;
            ctl_rx_custom_preamble_en           <= 'd0;
            ctl_rx_packet_framing_enable        <= 'd0;
            ctl_vnc_frm_gen_en                  <= 'd0;
            ctl_vnc_frm_gen_mode                <= 'd0;
            ctl_num_frames                      <= 'd0;
            ctl_vnc_mon_en                      <= 'd0;
            ctl_vnc_max_len                     <= 'd0;
            ctl_vnc_min_len                     <= 'd0;
            ctl_vnc_tx_custom_preamble[31:0]    <= 32'h555555d5;
            ctl_vnc_tx_custom_preamble[63:32]   <= 32'h55555555;
            ctl_tx_variable_ipg                 <= 'd0;
            ctl_vnc_rx_custom_preamble[31:0]    <= 'd0;
            ctl_vnc_rx_custom_preamble[63:32]   <= 'd0;
            stat_tick                           <= 'd0;
            ctl_vnc_tx_start_lat_run            <= 'd0;

            ctl_correct_bitslip                 <= 1'b0;
            ctl_disable_bitslip                 <= 1'b0;
            ctl_gb_seq_sync                     <= 1'b1;

        end
        else begin
            // Self-clearing registers are set up in this area
            stat_tick   <= 1'b0;

            if (ack_frm_gen_done)           ctl_vnc_frm_gen_en       <= 1'b0;
            if (ack_vnc_tx_start_lat_run)   ctl_vnc_tx_start_lat_run <= 1'b0;

            // End of self-clearing registers


            // Assign writeable registers to the appropriate bits of the write bus
            // if selected using address bus.
            if (do_write) begin

                // Resets to the GTF
                unique if (wr_addr == 12'h004) begin

                    vnc_gtf_ch_gttxreset                <= wr_data[0];
                    vnc_gtf_ch_txpmareset               <= wr_data[1];
                    vnc_gtf_ch_txpcsreset               <= wr_data[2];
                    gtwiz_reset_tx_pll_and_datapath_in  <= wr_data[3];
                    gtwiz_reset_tx_datapath_in          <= wr_data[4];

                    vnc_gtf_ch_gtrxreset                <= wr_data[8];
                    vnc_gtf_ch_rxpmareset               <= wr_data[9];
                    vnc_gtf_ch_rxdfelpmreset            <= wr_data[10];
                    vnc_gtf_ch_eyescanreset             <= wr_data[11];
                    vnc_gtf_ch_rxpcsreset               <= wr_data[12];
                    gtwiz_reset_rx_pll_and_datapath_in  <= wr_data[13];
                    gtwiz_reset_rx_datapath_in          <= wr_data[14];

                    vnc_gtf_cm_qpll0reset               <= wr_data[16];

                end

                else if (wr_addr == 12'h008) begin
                    scratch_0                           <= wr_data[31:0];
                end

                else if (wr_addr == 12'h00C) begin
                    vnc_gtf_ch_txuserrdy                <= wr_data[0];
                    vnc_gtf_ch_rxuserrdy                <= wr_data[1];
                end

                else if (wr_addr == 12'h010) begin
                    ctl_tx_data_rate                    <= wr_data[0];
                    ctl_tx_fcs_ins_enable               <= wr_data[4];
                    //ctl_tx_custom_preamble_en           <= wr_data[8];
                    ctl_tx_start_framing_enable         <= wr_data[12];
                    
                    ctl_rx_data_rate                    <= wr_data[16];
                    ctl_rx_packet_framing_enable        <= wr_data[20];
                    //ctl_rx_custom_preamble_en           <= wr_data[24];
                end

                else if (wr_addr == 12'h014) begin
                    ctl_vnc_frm_gen_mode                <= wr_data[0];
                    ctl_tx_variable_ipg                 <= wr_data[8];
                end

                else if (wr_addr == 12'h020) begin
                    ctl_vnc_frm_gen_en                  <= wr_data[0];
                    ctl_vnc_mon_en                      <= wr_data[4];
                end

                else if (wr_addr == 12'h024) begin
                    ctl_vnc_max_len                     <= wr_data[13:0];
                end

                else if (wr_addr == 12'h028) begin
                    ctl_vnc_min_len                     <= wr_data[13:0];
                end

                else if (wr_addr == 12'h02c) begin
                    ctl_num_frames                      <= wr_data[31:0];
                end

                //else if (wr_addr == 12'h030) begin
                //    ctl_vnc_tx_custom_preamble[31:0]    <= wr_data[31:0];
                //end
                //else if (wr_addr == 12'h034) begin
                //    ctl_vnc_tx_custom_preamble[63:32]   <= wr_data[31:0];
                //end
                //
                //else if (wr_addr == 12'h038) begin
                //    ctl_vnc_rx_custom_preamble[31:0]    <= wr_data[31:0];
                //end
                //else if (wr_addr == 12'h03c) begin
                //    ctl_vnc_rx_custom_preamble[63:32]   <= wr_data[31:0];
                //end

                else if (wr_addr == 12'h090) begin
                    stat_tick                           <= wr_data[0];
                end

                else if (wr_addr == 12'h094) begin
                    ctl_vnc_tx_start_lat_run            <= wr_data[0];
                end

                else if (wr_addr == 12'h0A4) begin
                    ctl_correct_bitslip                 <= wr_data[0];
                    ctl_disable_bitslip                  <= wr_data[4];
                    ctl_gb_seq_sync                     <= wr_data[8];
                end

            end

        end

    end


    always_comb begin : READ_DATA_COMBINATORIAL

        rdata = 32'h0;

        unique if (rd_addr == 12'h000) begin
            rdata[0]    = stat_gtf_tx_rst;
            rdata[1]    = stat_gtf_rx_rst;
            rdata[4]    = stat_gtf_block_lock;
            rdata[8]    = stat_gtf_rx_internal_local_fault;
            rdata[9]    = stat_gtf_rx_local_fault;
            rdata[10]   = stat_gtf_rx_received_local_fault;
            rdata[11]   = stat_gtf_rx_remote_fault;
        end

        else if (rd_addr == 12'h004) begin
            rdata[0]    = vnc_gtf_ch_gttxreset;
            rdata[1]    = vnc_gtf_ch_txpmareset;
            rdata[2]    = vnc_gtf_ch_txpcsreset;
            rdata[3]    = gtwiz_reset_tx_pll_and_datapath_in;
            rdata[4]    = gtwiz_reset_tx_datapath_in;

            rdata[8]    = vnc_gtf_ch_gtrxreset;
            rdata[9]    = vnc_gtf_ch_rxpmareset;
            rdata[10]   = vnc_gtf_ch_rxdfelpmreset;
            rdata[11]   = vnc_gtf_ch_eyescanreset;
            rdata[12]   = vnc_gtf_ch_rxpcsreset;
            rdata[13]   = gtwiz_reset_rx_pll_and_datapath_in;
            rdata[14]   = gtwiz_reset_rx_datapath_in;

            rdata[16]   = vnc_gtf_cm_qpll0reset;
        end

        else if (rd_addr == 12'h008) begin
            rdata[31:0]  = scratch_0;
        end

        else if (rd_addr == 12'h00c) begin
            rdata[0]     = vnc_gtf_ch_txuserrdy;
            rdata[1]     = vnc_gtf_ch_rxuserrdy;
        end

        else if (rd_addr == 12'h010) begin
            rdata[0]     = ctl_tx_data_rate;
            rdata[4]     = ctl_tx_fcs_ins_enable;
            rdata[8]     = ctl_tx_custom_preamble_en;
            rdata[12]    = ctl_tx_start_framing_enable;
            rdata[16]    = ctl_rx_data_rate;
            rdata[20]    = ctl_rx_custom_preamble_en;
            rdata[24]    = ctl_rx_packet_framing_enable;
        end

        else if (rd_addr == 12'h014) begin
            rdata[0]     = ctl_vnc_frm_gen_mode;
            rdata[8]     = ctl_tx_variable_ipg;
        end

        else if (rd_addr == 12'h020) begin
            rdata[0]     = ctl_vnc_frm_gen_en;
            rdata[4]     = ctl_vnc_mon_en;
        end

        else if (rd_addr == 12'h024) begin
            rdata[13:0]     = ctl_vnc_max_len;
        end

        else if (rd_addr == 12'h028) begin
            rdata[13:0]     = ctl_vnc_min_len;
        end

        else if (rd_addr == 12'h02c) begin
            rdata[31:0]     = ctl_num_frames;
        end

        else if (rd_addr == 12'h030) begin
            rdata[31:0]     = ctl_vnc_tx_custom_preamble[31:0];
        end
        else if (rd_addr == 12'h034) begin
            rdata[31:0]     = ctl_vnc_tx_custom_preamble[63:32];
        end

        else if (rd_addr == 12'h038) begin
            rdata[31:0]     = ctl_vnc_rx_custom_preamble[31:0];
        end
        else if (rd_addr == 12'h03c) begin
            rdata[31:0]     = ctl_vnc_rx_custom_preamble[63:32];
        end

        else if (rd_addr == 12'h090) begin
            rdata[0]     = stat_tick;
        end

        else if (rd_addr == 12'h094) begin
            rdata[0]     = ctl_vnc_tx_start_lat_run;
        end

        else if (rd_addr == 12'h0A0) begin
            rdata[6:0]      = stat_bitslip_cnt;
            rdata[14:8]     = stat_bitslip_issued;
            rdata[16]       = stat_bitslip_locked;
            rdata[17]       = stat_bitslip_busy;
            rdata[18]       = stat_bitslip_done;
            rdata[19]       = stat_excessive_bitslip;
        end
        else if (rd_addr == 12'h0A4) begin
            rdata[0]        = ctl_correct_bitslip;
            rdata[4]        = ctl_disable_bitslip;
            rdata[8]        = ctl_gb_seq_sync;
        end

        else if (rd_addr == 12'h100) begin
             rdata[15:0] = `GTFMAC_VNC_VERSION;
        end

        else if (rd_addr == 12'h104) begin
             rdata[31:0] = tx_clk_cps;
        end

        else if (rd_addr == 12'h108) begin
             rdata[31:0] = rx_clk_cps;
        end

        else if (rd_addr == 12'h10c) begin
             rdata[31:0] = axi_aclk_cps;
        end

        else if (rd_addr == 12'h110) begin
             rdata[31:0] = gen_clk_cps;
        end

        else if (rd_addr == 12'h114) begin
             rdata[31:0] = mon_clk_cps;
        end

        else if (rd_addr == 12'h118) begin
             rdata[31:0] = lat_clk_cps;
        end

        else begin
            rdata = 32'h0;
        end
    end

endmodule
