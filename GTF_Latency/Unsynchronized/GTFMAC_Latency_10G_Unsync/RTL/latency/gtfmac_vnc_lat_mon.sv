/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

module gtfmac_vnc_lat_mon # (
    parameter  TIMER_WIDTH      = 16,
    parameter  RAM_DEPTH        = 4096,
    parameter  RAM_ADDR_WIDTH   = 12
)
(
    input       wire        axi_clk,
    input       wire        axi_rstn,

    input       wire        tx_clk,
    input       wire        tx_rstn,

    input       wire        rx_clk,
    input       wire        rx_rstn,

    input       wire        lat_clk,
    input       wire        lat_rstn,

    // Control Signals from PIF
    input       logic                       go,         // start collecting samples
    input       logic                       pop,        // pop next entry
    input       logic                       clear,      // reset all pointers.  Assumes go=0
    input       logic   [31:0]              lat_pkt_cnt,// Number of frames to monitor.

    // Status Signals to PIF
    output      logic                       full,       // status and also auto-clears go
    output      logic   [RAM_ADDR_WIDTH:0]  datav,      // Number of records
    output      logic                       time_rdy,   // pulse when a read has occurred
    
    // Event Time Stamps
    output      logic   [TIMER_WIDTH-1:0]   tx_time,    // transmit time
    output      logic   [TIMER_WIDTH-1:0]   rx_time,    // receive time
    
    // Delta Data
    output logic [31:0]            delta_time_accu,
    output logic [31:0]            delta_time_idx,
    output logic [TIMER_WIDTH-1:0] delta_time_max,
    output logic [TIMER_WIDTH-1:0] delta_time_min,

    // Delta Control
    output logic delta_done_sync,
    output logic [TIMER_WIDTH-1:0] delta_adj_factor,

    // Latency monitor ILA signals
    output wire [TIMER_WIDTH-1:0] lat_mon_sent_time_ila,
    output wire [TIMER_WIDTH-1:0] lat_mon_rcvd_time_ila,
    output wire [TIMER_WIDTH-1:0] lat_mon_delta_time_ila,
    output wire                   lat_mon_send_event_ila,
    output wire                   lat_mon_rcv_event_ila,
    output wire [31:0]            lat_mon_delta_time_idx_ila,

    input       wire        pattern_sent,
    input       wire        pattern_rcvd,

    input       wire        tx_sopin,
    input       wire        tx_enain,
    input       wire        tx_rdyout,
    input       wire        tx_can_start,
    input       wire        tx_eopin,

    input       wire        rx_sof,

    // These signals indicate that the sop of the NEXT packet will be collected for latency purposes
    input       wire        tx_start_latency_run,   // co-incident with tx_sopin
    input       wire        rx_start_latency_run,   // collected from MAC DA (comes after rx_sop)

    // processor interface

    input       logic       data_rate  // data rate (0=10G, 1=25G)    
);

    `include "gtfmac_vnc_top.vh"

    localparam  RAM_WIDTH   = TIMER_WIDTH;
    localparam  ADDR_WIDTH  = RAM_ADDR_WIDTH;
    localparam  PTR_WIDTH   = RAM_ADDR_WIDTH + 1;
    localparam  FULL_THRESH = RAM_DEPTH - 12;

    localparam  LAT_START_DLY = 4;

    localparam  DELTA_ADJ_FACTOR = 1; 


// ##################################################################
//
//   Sync Logic From PIF
//
// ##################################################################
    logic   clear_sync;
    logic   go_sync;

    gtfmac_vnc_syncer_pulse i_sync_clear (
       .clkin        (axi_clk),
       .clkin_reset  (axi_rstn),
       .clkout       (lat_clk),
       .clkout_reset (lat_rstn),
       .pulsein      (clear),
       .pulseout     (clear_sync)
    );

    gtfmac_vnc_syncer_level i_sync_go (
      .reset      (lat_rstn),
      .clk        (lat_clk),
      .datain     (go),
      .dataout    (go_sync)
    );


// ##################################################################
//
//   TX Sent Event Logic
//
// ##################################################################

    reg     tx_pkt_sent_0;
    reg     tx_pkt_sent_1;
    reg     tx_init_run;
    reg     tx_start_run;
    wire    sync_pkt_sent;
    reg     sync_pkt_sent_R;

    logic   sync_tx_start_run;
    logic   sync_tx_start_run_R;

    wire    pkt_sent;
    reg     wait_for_can_start;
    logic           tx_go;
    logic   [11:0]  tx_pkt_rem;





    logic   tx_start_run_pending;
    wire    tx_start_latency_run;
    wire    tx_eopin;
    always @ (posedge tx_clk) begin
        if (tx_rstn == 1'b0) begin
            tx_start_run_pending    <= 1'b0;
            tx_start_run            <= 1'b0;
        end
        else if (tx_start_latency_run) begin
            tx_start_run_pending    <= 1'b1;
        end
        else if (tx_start_run_pending && tx_eopin) begin
            tx_start_run_pending    <= 1'b0;
            tx_start_run            <= ~tx_start_run;
        end
    end

    wire tx_pkt_sent;
    // Level-sensitive signals that change state when an event occurs
    always @ (posedge tx_clk) begin
        if (tx_rstn == 1'b0) begin
            tx_pkt_sent_0           <= 0;
            wait_for_can_start      <= 0;
        end
        else if (wait_for_can_start) begin
            if (tx_can_start) begin
                tx_pkt_sent_0       <= ~tx_pkt_sent;
                wait_for_can_start  <= 0;
            end
        end
        else if (tx_sopin && tx_enain && tx_rdyout) begin
            if (tx_can_start || data_rate) begin
                tx_pkt_sent_0           <= ~tx_pkt_sent;
            end
            else begin
                wait_for_can_start      <= 1'b1;
            end
        end
    end
    
    always @ (posedge tx_clk) begin
        if (tx_rstn == 1'b0) begin
            tx_pkt_sent_1 <= 0;
        end
        else if (pattern_sent) begin
            tx_pkt_sent_1 <= ~tx_pkt_sent;
        end

    end
    
	assign tx_pkt_sent = tx_pkt_sent_0;
	
    gtfmac_vnc_syncer_level i_sync_pkt_sent_event (
      .reset      (lat_rstn),
      .clk        (lat_clk),
      .datain     (tx_pkt_sent),
      .dataout    (sync_pkt_sent)
    );

    gtfmac_vnc_syncer_level i_sync_tx_measured_run_event (
      .reset      (lat_rstn),
      .clk        (lat_clk),
      .datain     (tx_start_run),
      .dataout    (sync_tx_start_run)
    );

    // Edge Detect
    always @ (posedge lat_clk) begin
        if (lat_rstn == 1'b0) begin
            sync_pkt_sent_R         <= 0;
            sync_tx_start_run_R     <= 0;
        end else begin
            sync_pkt_sent_R         <= sync_pkt_sent;
            sync_tx_start_run_R     <= sync_tx_start_run;
        end
    end

    // Packet sent/receive pulse in the lat_clk domain
    assign pkt_sent = sync_pkt_sent_R ^ sync_pkt_sent;


    // MEASURED RUNS
    always @ (posedge lat_clk) begin
        if (lat_rstn == 1'b0) begin
            tx_go   <= 1'b0;
        end
        else if (sync_tx_start_run_R ^ sync_tx_start_run) begin
            tx_go       <= 1'b1;
            tx_pkt_rem  <= lat_pkt_cnt;
        end
        else if (tx_go) begin
            if (pkt_sent) begin
                tx_pkt_rem  <= tx_pkt_rem - 1'b1;
            end
            else if (|tx_pkt_rem == 1'b0) begin
                tx_go   <= 1'b0;
            end
        end
    end
    
// ##################################################################
//
//   RX Received Event Logic
//
// ##################################################################


    reg     rx_pkt_rcvd;
    reg     rx_start_run;
    wire    sync_pkt_rcvd;
    reg     sync_pkt_rcvd_R;

    logic   sync_rx_start_run;
    logic   [LAT_START_DLY-1:0] sync_rx_start_run_R;

    wire    pkt_rcvd;

    logic           rx_go;
    logic   [11:0]  rx_pkt_rem;

	wire rx_sof_trig = rx_sof;

    always @ (posedge rx_clk) begin

        if (rx_sof_trig == 1'b1) begin
            rx_pkt_rcvd    <= ~rx_pkt_rcvd;
        end

        if (rx_start_latency_run) begin
            rx_start_run   <= ~rx_start_run;
        end

        if (rx_rstn == 1'b0) begin
            rx_pkt_rcvd    <= 0;
            rx_start_run   <= 0;
        end

    end

    gtfmac_vnc_syncer_level i_sync_pkt_rcvd_event (
      .reset      (lat_rstn),
      .clk        (lat_clk),
      .datain     (rx_pkt_rcvd),
      .dataout    (sync_pkt_rcvd)
    );


    gtfmac_vnc_syncer_level i_sync_rx_measured_run_event (
      .reset      (lat_rstn),
      .clk        (lat_clk),
      .datain     (rx_start_run),
      .dataout    (sync_rx_start_run)
    );


    // Edge Detect
    always @ (posedge lat_clk) begin
        if (lat_rstn == 1'b0) begin
            sync_pkt_rcvd_R         <= 0;
            sync_rx_start_run_R     <= 0;
        end else begin
            sync_pkt_rcvd_R         <= sync_pkt_rcvd;
            sync_rx_start_run_R     <= {sync_rx_start_run_R[LAT_START_DLY-2:0], sync_rx_start_run};
        end
    end
    
    // Packet sent/receive pulse in the lat_clk domain
    assign pkt_rcvd = sync_pkt_rcvd_R ^ sync_pkt_rcvd;


    // MEASURED RUNS
    always @ (posedge lat_clk) begin
        if (lat_rstn == 1'b0) begin
            rx_go   <= 1'b0;
        end
        else if (sync_rx_start_run_R[LAT_START_DLY-1] ^ sync_rx_start_run_R[LAT_START_DLY-2]) begin
            rx_go       <= 1'b1;
            rx_pkt_rem  <= lat_pkt_cnt;
        end
        else if (rx_go) begin
            if (pkt_rcvd) begin
                rx_pkt_rem  <= rx_pkt_rem - 1'b1;
            end
            else if (|rx_pkt_rem == 1'b0) begin
                rx_go   <= 1'b0;
            end
        end
    end


// ##################################################################
//
//   Universal Timer
//
// ##################################################################

    reg     [TIMER_WIDTH-1:0]      timer;
    
    always @ (posedge lat_clk) begin
        timer <= timer + 1;
        if (lat_rstn == 1'b0) begin
            timer <= 0;
        end
    end


    // "Open ended" latency run
    // Track how many frames are in the pipeline (max 15).  'go' is a signal from the PIF
    // that tells us to capture timers.  If we become full, go will self-clear which will
    // prevent an overflow, and the logic below ensures we push an equal number of send and
    // receive times so the CPU doesn't get confused.

    logic [TIMER_WIDTH-1:0]     sent_time;
    logic [TIMER_WIDTH-1:0]     rcvd_time;
    logic                       push_sent;
    logic                       push_rcvd;
    logic [3:0]                 pending_cnt;

    logic                       send_event; 
    logic                       rcv_event;
    logic                       rx_pending;

    assign  send_event  = pkt_sent & (go_sync | tx_go);
    assign  rcv_event   = pkt_rcvd & (rx_pending | rx_go);
    assign  rx_pending  = |pending_cnt;

    // Capture timer
    always @ (posedge lat_clk) begin
        push_sent   <= 1'b0;
        push_rcvd   <= 1'b0;

        if (send_event && !clear_sync) begin
            sent_time   <= timer;
            push_sent   <= 1'b1;
        end

        if (rcv_event && !clear_sync) begin
            rcvd_time   <= timer;
            push_rcvd   <= 1'b1;
        end

        if (lat_rstn == 1'b0) begin
            push_sent   <= 1'b0;
            push_rcvd   <= 1'b0;
        end
    end

    reg [TIMER_WIDTH-1:0] delta_time;
    reg                   delta_time_calc_ready_r0;
    reg                   delta_time_calc_ready_r1;
    reg                   delta_time_calc_ready_r2;
    
    // Asserted when ready to calculate the delta time between a pair rcvd_time and sent_time
    always @(posedge lat_clk) begin
        if (!lat_rstn) begin
            delta_time_calc_ready_r0 <= 0;
        end else begin
            delta_time_calc_ready_r0 <= (rcv_event & !clear_sync) & (rx_pending == 1'b1);
            delta_time_calc_ready_r1 <= delta_time_calc_ready_r0;
            delta_time_calc_ready_r2 <= delta_time_calc_ready_r1;
        end
    end

    assign delta_adj_factor = DELTA_ADJ_FACTOR;

    // Figure out latency and keep track of index
    always @(posedge lat_clk) begin
        if (!lat_rstn) begin
            delta_time <= 0;
            delta_time_idx <= 0;
        end else begin
            if (delta_time_calc_ready_r0) begin
                delta_time <= rcvd_time - sent_time - delta_adj_factor;
                delta_time_idx <= delta_time_idx + 1;
            end
        end
    end

    // Calculate min & max and add up delta_time for avg value calculation on the host
    always @(posedge lat_clk) begin
        if (!lat_rstn) begin
            delta_time_accu <= 0;
            delta_time_max <= 0;
            delta_time_min <= '1;
        end else begin
            if (delta_time_calc_ready_r1) begin
                delta_time_accu <= delta_time_accu + delta_time;

                if (delta_time > delta_time_max) begin
                    delta_time_max <= delta_time;
                end
                
                if (delta_time < delta_time_min) begin
                    delta_time_min <= delta_time;
                end
            end
        end
    end

    reg delta_done;

    always @(posedge lat_clk) begin
        if (!lat_rstn) begin
            delta_done <= 0;
        end else begin
            if ((delta_time_idx == lat_pkt_cnt) && (delta_time_idx > 0)) begin
                delta_done <= 1;
            end else begin
                delta_done <= 0;
            end
        end
    end

    gtfmac_vnc_syncer_level # (
        .WIDTH(1)
    )
    i_sync_delta_done (
      .reset      (axi_rstn),
      .clk        (axi_clk),
      .datain     (delta_done),
      .dataout    (delta_done_sync)
    );

    // The "pending" queue is only used when we are in open-ended measurement mode
    // If we are in a "run", we don't increment or decrement the pending_cnt
    always @ (posedge lat_clk) begin
        if (lat_rstn == 1'b0) begin
            pending_cnt <= 'd0;
        end else if (clear_sync) begin
            pending_cnt <= 'd0;
        end else begin
            case ({send_event & go_sync, rcv_event & rx_pending})
                2'b10: begin
                    pending_cnt <= pending_cnt + 1'b1;
                end
                2'b01: begin
                    pending_cnt <= pending_cnt - 1'b1;
                end
            endcase
        end
    end


// ##################################################################
//
//   Dual Port BRAM Sample Storage
//
// ##################################################################

    logic   [PTR_WIDTH-1:0]     tx_wr_ptr, gry_tx_wr_ptr, gry_axi_tx_wr_ptr, axi_tx_wr_ptr;
    logic   [PTR_WIDTH-1:0]     rx_wr_ptr, gry_rx_wr_ptr, gry_axi_rx_wr_ptr, axi_rx_wr_ptr;

    logic   [PTR_WIDTH-1:0]     axi_rd_ptr, gry_axi_rd_ptr, gry_tx_rd_ptr, tx_rd_ptr;

    logic                       pop_R;
    logic  [TIMER_WIDTH-1:0]    axi_tx_time, axi_rx_time;


    // Manage the send and receive queue
    always @ (posedge lat_clk) begin
        if (lat_rstn == 1'b0) begin
            tx_wr_ptr   <= 'd0;
        end
        else if (clear_sync) begin
            tx_wr_ptr   <= 'd0;
        end
        else if (push_sent) begin
            tx_wr_ptr   <= tx_wr_ptr + 1'b1;
        end
    end

    always @ (posedge lat_clk) begin

        if (lat_rstn == 1'b0) begin
            rx_wr_ptr   <= 'd0;
        end
        else if (clear_sync) begin
            rx_wr_ptr   <= 'd0;
        end
        else if (push_rcvd) begin
            rx_wr_ptr   <= rx_wr_ptr + 1'b1;
        end
    end

    always @ (posedge axi_clk) begin
        if (axi_rstn == 1'b0) begin
            axi_rd_ptr  <= 'd0;
        end
        else if (clear) begin
            axi_rd_ptr  <= 'd0;
        end
        else if (pop_R) begin
            axi_rd_ptr  <= axi_rd_ptr + 1'b1;
        end
    end

    always @ (posedge axi_clk) begin
        if (axi_rstn == 1'b0) begin
            pop_R <= 1'b0;
        end else begin
            pop_R <= pop;
        end
    end
    assign time_rdy  = pop_R;
    
    always @ (posedge axi_clk) begin
        tx_time     <= axi_tx_time;
        rx_time     <= axi_rx_time;
    end

    
    // TX samples
    gtfmac_vnc_simple_bram # (
        .RAM_WIDTH  (RAM_WIDTH),
        .RAM_DEPTH  (RAM_DEPTH),
        .ADDR_WIDTH (ADDR_WIDTH)
    ) i_tx_sample_ram
    (
        .in_clk     (lat_clk),
        .out_clk    (axi_clk),

        .ena        (push_sent),
        .wea        (1'b1),
        .wr_addr    (tx_wr_ptr[ADDR_WIDTH-1:0]),
        .dina       (sent_time),

        .enb        (pop),
        .rd_addr    (axi_rd_ptr[ADDR_WIDTH-1:0]),
        .doutb      (axi_tx_time)
    );


    // RX samples
    gtfmac_vnc_simple_bram # (
        .RAM_WIDTH  (RAM_WIDTH),
        .RAM_DEPTH  (RAM_DEPTH),
        .ADDR_WIDTH (ADDR_WIDTH)
    ) i_rx_sample_ram
    (
        .in_clk     (lat_clk),
        .out_clk    (axi_clk),

        .ena        (push_rcvd),
        .wea        (1'b1),
        .wr_addr    (rx_wr_ptr[ADDR_WIDTH-1:0]),
        .dina       (rcvd_time),

        .enb        (pop),
        .rd_addr    (axi_rd_ptr[ADDR_WIDTH-1:0]),
        .doutb      (axi_rx_time)
    );

    // BRAM Status for PIF
    always @ (posedge axi_clk) begin
        if (axi_rstn == 1'b0) begin
            full    <= 1'b0;
            datav   <= 'd0;
        end else begin
            full    <= (datav >= FULL_THRESH) ? 1'b1 : 1'b0;
            datav   <= {1'b1, axi_rx_wr_ptr[ADDR_WIDTH-1:0]} - {axi_rd_ptr[PTR_WIDTH-1] ~^ axi_rx_wr_ptr[PTR_WIDTH-1], axi_rd_ptr[ADDR_WIDTH-1:0]};
       end
    end
    

    // BRAM Gray Code Addressing Sync
    always @ (posedge lat_clk) begin
        if (lat_rstn == 1'b0) begin
            gry_tx_wr_ptr   <= 'd0;
            gry_rx_wr_ptr   <= 'd0;
        end else begin
            gry_tx_wr_ptr   <= f_bin2grayc(tx_wr_ptr, PTR_WIDTH);
            gry_rx_wr_ptr   <= f_bin2grayc(rx_wr_ptr, PTR_WIDTH);
        end
    end

    gtfmac_vnc_syncer_level # (
        .WIDTH(PTR_WIDTH)
    )
    i_sync_tx_wr_ptr (
      .reset      (axi_rstn),
      .clk        (axi_clk),
      .datain     (gry_tx_wr_ptr),
      .dataout    (gry_axi_tx_wr_ptr)
    );

    gtfmac_vnc_syncer_level # (
        .WIDTH(PTR_WIDTH)
    )
    i_sync_rx_wr_ptr (
      .reset      (axi_rstn),
      .clk        (axi_clk),
      .datain     (gry_rx_wr_ptr),
      .dataout    (gry_axi_rx_wr_ptr)
    );


    always @ (posedge axi_clk) begin
        if (axi_rstn == 1'b0) begin
            axi_tx_wr_ptr   <= 'd0;
            axi_rx_wr_ptr   <= 'd0;
        end else begin
            axi_tx_wr_ptr   <= f_grayc2bin(gry_axi_tx_wr_ptr, PTR_WIDTH);
            axi_rx_wr_ptr   <= f_grayc2bin(gry_axi_rx_wr_ptr, PTR_WIDTH);
        end
    end


    function [16-1:0] f_bin2grayc (
        input [16-1:0] binin,
        input integer width
    );
    begin: main_f_bin2grayc

        f_bin2grayc = 16'b0;
        // Need width to be fixed. f_bin2grayc[width-1:0] =  binin[width-1] ^ {1'b0, binin[width-1:0]};
        f_bin2grayc[width-1] = binin[width-1];

        for (int i = 0; i < width -1; i++) begin
            f_bin2grayc[i] = binin[i] ^ binin[i+1];
        end
    end
    endfunction

    function [16-1:0] f_grayc2bin (
        input [16-1:0] grayin,
        input integer width
    );
    begin: main_f_grayc2bin

        f_grayc2bin          = 16'b0;
        f_grayc2bin[width-1] = grayin[width-1];

        for (int i = width - 2; i >= 0; i--) begin
            f_grayc2bin[i] = f_grayc2bin[i+1] ^ grayin[i];
        end
    end
    endfunction


// ##################################################################
//
//   Assign ILA Signals
//
// ##################################################################
    
    assign lat_mon_sent_time_ila = sent_time;
    assign lat_mon_rcvd_time_ila = rcvd_time;
    assign lat_mon_delta_time_ila = delta_time;
    assign lat_mon_send_event_ila = send_event;
    assign lat_mon_rcv_event_ila = rcv_event;
    assign lat_mon_delta_time_idx_ila = delta_time_idx;

    (* MARK_DEBUG = "TRUE" *) wire [31:0] delta_time_accu_ila = delta_time_accu;
    (* MARK_DEBUG = "TRUE" *) wire [31:0] delta_time_idx_ila = delta_time_idx;
    (* MARK_DEBUG = "TRUE" *) wire [TIMER_WIDTH-1:0] delta_time_max_ila = delta_time_max;
    (* MARK_DEBUG = "TRUE" *) wire [TIMER_WIDTH-1:0] delta_time_min_ila = delta_time_min;
    (* MARK_DEBUG = "TRUE" *) wire delta_done_ila = delta_done;
    
    // lat_mon_ila lat_mon_ila_inst (    
    //     .clk(lat_clk),
    //     .probe0(delta_time_accu_ila),
    //     .probe1(delta_time_idx_ila),
    //     .probe2(delta_time_max_ila),
    //     .probe3(delta_time_min_ila),
    //     .probe4(delta_done_ila)
    // );

endmodule
