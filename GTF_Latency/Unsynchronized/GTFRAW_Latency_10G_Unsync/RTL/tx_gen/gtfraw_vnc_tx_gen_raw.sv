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

module gtfraw_vnc_tx_gen_raw (

    input       wire            axi_aclk,
    input       wire            axi_aresetn,

    input       wire            gen_clk,
    input       wire            gen_rst,

    input       wire            ctl_vnc_frm_gen_en,
    input       wire    [31:0]  ctl_num_frames,
    output      wire            ack_frm_gen_done,

    input       wire            tx_clk,
    input       wire            tx_rst,

    output      wire [15:0]     gtf_ch_txrawdata,
    output      wire            gtf_ch_txrawdata_sof

);

    // -- Input signals sync'd to tx_clk domain
    wire frm_gen_en;
    gtfraw_vnc_syncer_level i_sync_ctl_frm_gen_en (
      .reset      (~tx_rst),
      .clk        (tx_clk),
      .datain     (ctl_vnc_frm_gen_en),
      .dataout    (frm_gen_en)

    );

    reg [15:0] counter;
    always@(posedge tx_clk)
    begin
        if (tx_rst)
            counter <= 'h0;
        else if (!frm_gen_en)
            counter <= 'h0;
        else if (counter == 200)
            counter <= 'h0;
        else 
            counter <= counter + 1;
    end

    wire tx_prbs_sof = (counter ==  10);
    wire tx_prbs_eof = (counter == 110);
    

    wire [15:0] txdata_prbs;
    
/*    // 16 bit prbs = 16,15,13,4
    prbs_16 #( .SEEDVALUE ('h1234) ) prbs_16 (
        .clk      ( tx_clk           ),
        .rstn     ( ~tx_rst          ),
        .en       ( 1'b1             ),
        .prbs_out ( txdata_prbs      ),
    
        .sync_en  ( 'h0              ),
        .prbs_in  (                  ),
        .sync_det (                  )
    );
*/

    // ===============================================

    reg [15:0] prbs_reg;
    always@(posedge tx_clk)
    begin
        if (tx_rst)
            prbs_reg <= 'h1234;
        else
            prbs_reg <= { prbs_reg[14:0], 
                          prbs_reg[15] ^ prbs_reg[14] ^ prbs_reg[12] ^ prbs_reg[3] };
    end

    assign txdata_prbs = prbs_reg;

    // ===============================================

    //assign gtf_ch_txrawdata = tx_prbs_sof ? 'h0100 : txdata_prbs;
    assign gtf_ch_txrawdata = tx_prbs_sof ? 'h8001 : txdata_prbs;
    //assign gtf_ch_txrawdata = txdata_prbs ^ {15'h0, tx_prbs_sof};

    //wire   tx_prbs_sof = frm_gen_en && 
    //                    ( ('h1234 == gtf_ch_txrawdata) || 
    //                      ('h88C0 == gtf_ch_txrawdata) || 
    //                      ('h66A2 == gtf_ch_txrawdata) || 
    //                      ('h281D == gtf_ch_txrawdata) );
    //
    //wire   tx_prbs_eof = frm_gen_en && 
    //                    ( ('h1D74 == gtf_ch_txrawdata) || 
    //                      ('h8C62 == gtf_ch_txrawdata) || 
    //                      ('h13B0 == gtf_ch_txrawdata) || 
    //                      ('hADFA == gtf_ch_txrawdata) );

    reg [31:0] num_frames;
    always@(posedge tx_clk)
    begin
        if (tx_rst) begin
            num_frames <= 'h0;
        end else if (!frm_gen_en) begin
            num_frames <= 'h0;
        end else if (tx_prbs_eof) begin
            num_frames <= num_frames + 1;
        end 
    end

    wire frm_gen_done = (num_frames == ctl_num_frames) && frm_gen_en;

    // -- Output signals sync'd to axi_aclk domain

    gtfraw_vnc_syncer_pulse i_ack_ctl_frm_gen_done (
       .clkin        (tx_clk),
       .clkin_reset  (~tx_rst),
       .clkout       (axi_aclk),
       .clkout_reset (axi_aresetn),

       .pulsein      (frm_gen_done),
       .pulseout     (ack_frm_gen_done)
    );
    
    //assign gtf_ch_txrawdata      = tx_prbs_data;
    assign gtf_ch_txrawdata_sof  = tx_prbs_sof;
    
    //assign ack_frm_gen_done     = 1'b0;
    //assign gtf_ch_txrawdata_sof = 1'b0;
   

/*
    // -- Input signals sync'd to tx_clk domain
    wire frm_gen_en;
    gtfraw_vnc_syncer_level i_sync_ctl_frm_gen_en (
      .reset      (~tx_rst),
      .clk        (tx_clk),
      .datain     (ctl_vnc_frm_gen_en),
      .dataout    (frm_gen_en)

    );
    
    
    // TX PRBS Data - always running but repeats after ctl_vnc_max_len clock cycles
    reg [13:0] prbs_counter;
    wire   tx_prbs_max = (prbs_counter == 500);
    wire   tx_prbs_min = (prbs_counter == 0);

    always@(posedge tx_clk)
    begin
        if (tx_rst) begin
            prbs_counter <= 'h2;
        end else if (tx_prbs_max) begin
            prbs_counter <= 'h0;
        end else begin
            prbs_counter <= prbs_counter + 1;
        end 
    end
    
    
    wire [15:0] tx_prbs_data;
    
    gtfraw_vnc_frm_gen_prbs gtfraw_vnc_frm_gen_prbs_tx (
        .RST      (tx_rst | tx_prbs_min),
        .CLK      (tx_clk),
        .DATA_IN  (16'b0),
        .EN       (1'b1),
        .DATA_OUT (tx_prbs_data)
    );


    wire   tx_prbs_sof = frm_gen_en && ('h0080 == tx_prbs_data);    
    wire   tx_prbs_eof = frm_gen_en && (450 == prbs_counter);


    reg [31:0] num_frames;
    always@(posedge tx_clk)
    begin
        if (tx_rst) begin
            num_frames <= 'h0;
        end else if (!frm_gen_en) begin
            num_frames <= 'h0;
        end else if (tx_prbs_eof) begin
            num_frames <= num_frames + 1;
        end 
    end

    wire frm_gen_done = (num_frames == ctl_num_frames) && frm_gen_en;

    // -- Output signals sync'd to axi_aclk domain

    gtfraw_vnc_syncer_pulse i_ack_ctl_frm_gen_done (
       .clkin        (tx_clk),
       .clkin_reset  (~tx_rst),
       .clkout       (axi_aclk),
       .clkout_reset (axi_aresetn),

       .pulsein      (frm_gen_done),
       .pulseout     (ack_frm_gen_done)
    );
    
    assign gtf_ch_txrawdata      = tx_prbs_data;
    assign gtf_ch_txrawdata_sof  = tx_prbs_sof;
*/

endmodule

