/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

// Frequency counter...
//
//   Determine sample duration...
//      Sample window(sec's) = Freq(clk_samp) * samp_count_in 
//
//   Frequency Calculation...
//      Freq(clk) = Freq(clk_samp) * samp_count_in / samp_count_out


module freq_counter_top (
    // System Interface
    input  wire        sys_if_clk    ,   
    input  wire        sys_if_rstn   ,
    input  wire        sys_if_wen    ,    
    input  wire [31:0] sys_if_addr   ,   
    input  wire [31:0] sys_if_wdata  ,  
    output wire [31:0] sys_if_rdata  , 

    // Input clock to be sampled....
    input  wire        clk_samp_0    ,      
    input  wire        clk_samp_1    ,      
    input  wire        clk_samp_2    ,      
    input  wire        clk_samp_3    ,      
    input  wire        clk_samp_4    ,      
    input  wire        clk_samp_5    ,      
    input  wire        clk_samp_6    ,      
    input  wire        clk_samp_7          
);


// ======================================================================
//                          0123456789abcdef
localparam HEADER_STRING = "FreqMon Rev 1.1 ";

wire [31:0] IO_HEADER0_VALUE  = HEADER_STRING[8*16-1:8*12];
wire [31:0] IO_HEADER1_VALUE  = HEADER_STRING[8*12-1:8*8];
wire [31:0] IO_HEADER2_VALUE  = HEADER_STRING[8*8-1:8*4];
wire [31:0] IO_HEADER3_VALUE  = HEADER_STRING[8*4-1:8*0];

// ======================================================================
//  System Register Interface

wire         start_pulse    ;
wire [31:0]  samp_count_in  ;
//reg  [31:0]  samp_count_out ;
reg          sample_valid   ;

reg  [31:0] IO_SAMP_COUNT_0_VALUE;
reg  [31:0] IO_SAMP_COUNT_1_VALUE;
reg  [31:0] IO_SAMP_COUNT_2_VALUE;
reg  [31:0] IO_SAMP_COUNT_3_VALUE;
reg  [31:0] IO_SAMP_COUNT_4_VALUE;
reg  [31:0] IO_SAMP_COUNT_5_VALUE;
reg  [31:0] IO_SAMP_COUNT_6_VALUE;
reg  [31:0] IO_SAMP_COUNT_7_VALUE;


freq_counter_regs freq_counter_regs (
    // System Register Interface...
    .sys_if_clk   ( sys_if_clk     ),
    .sys_if_rstn  ( sys_if_rstn    ),
    .sys_if_wen   ( sys_if_wen     ),
    .sys_if_addr  ( sys_if_addr    ),
    .sys_if_wdata ( sys_if_wdata   ),
    .sys_if_rdata ( sys_if_rdata   ),

    // Internal Module Signals...
    .IO_HEADER0_VALUE       ( IO_HEADER0_VALUE ),
    .IO_HEADER1_VALUE       ( IO_HEADER1_VALUE ),
    .IO_HEADER2_VALUE       ( IO_HEADER2_VALUE ),
    .IO_HEADER3_VALUE       ( IO_HEADER3_VALUE ),

    .IO_STATUS_SAMP_VALID   ( sample_valid     ),
    .IO_CONTROL_RESETN      (                  ),
    .IO_CONTROL_SAMP_START  ( start_pulse      ),
    .IO_SAMP_WIDTH_VALUE    ( samp_count_in    ),
    //.IO_SAMP_COUNT_VALUE    ( samp_count_out   ),
    
    .IO_SAMP_COUNT_0_VALUE  ( IO_SAMP_COUNT_0_VALUE ),
    .IO_SAMP_COUNT_1_VALUE  ( IO_SAMP_COUNT_1_VALUE ),
    .IO_SAMP_COUNT_2_VALUE  ( IO_SAMP_COUNT_2_VALUE ),
    .IO_SAMP_COUNT_3_VALUE  ( IO_SAMP_COUNT_3_VALUE ),
    .IO_SAMP_COUNT_4_VALUE  ( IO_SAMP_COUNT_4_VALUE ),
    .IO_SAMP_COUNT_5_VALUE  ( IO_SAMP_COUNT_5_VALUE ),
    .IO_SAMP_COUNT_6_VALUE  ( IO_SAMP_COUNT_6_VALUE ),
    .IO_SAMP_COUNT_7_VALUE  ( IO_SAMP_COUNT_7_VALUE )
    
);


// ======================================================================
//  sys_if_clk domain

wire timer0_eq_0;
wire timer1_eq_0;

localparam ST_IDLE      = 'h0;
localparam ST_RUNNING   = 'h1;
localparam ST_DELAY     = 'h2;
localparam ST_COMPLETE  = 'h3;

reg [3:0] cstate;
reg [3:0] nstate;

always@(posedge sys_if_clk)
begin
    if (!sys_if_rstn)
        cstate <= 'h0;
    else
        cstate <= nstate;
end

always@*
begin
    nstate = cstate;
    case (cstate)
        ST_IDLE     : if (start_pulse) nstate = ST_RUNNING;
        ST_RUNNING  : if (timer0_eq_0) nstate = ST_DELAY;
        ST_DELAY    : if (timer1_eq_0) nstate = ST_COMPLETE;
        ST_COMPLETE : nstate = ST_IDLE;
    endcase
end

// ======================================================================

reg [17:0] timer0;
always@(posedge sys_if_clk)
begin
    if (!sys_if_rstn)
        timer0 <= 'h0;
    else if (start_pulse)
        timer0 = samp_count_in - 1;
    else if (timer0 == 0)
        timer0 <= 'h0;
    else
        timer0 <= timer0 - 1;
end

assign timer0_eq_0 = (timer0 == 'h0);

reg [17:0] timer1;
always@(posedge sys_if_clk)
begin
    if (!sys_if_rstn)
        timer1 <= 'h0;
    else if (nstate == ST_RUNNING)
        timer1 = 1000; // 10 us delay 
    else if (timer1 == 0)
        timer1 <= 'h0;
    else
        timer1 <= timer1 - 1;
end

assign timer1_eq_0 = (timer1 == 'h1);


reg en_sample_0;
reg en_sample_1;
always@(posedge sys_if_clk)
begin
    if (!sys_if_rstn) begin
        en_sample_0 <= 'h0;
        en_sample_1 <= 'h0;
    end else begin
        en_sample_0 <= (nstate == ST_RUNNING);
        en_sample_1 <= en_sample_0;
    end
end

// ======================================================================
//  clk_samp domain

wire [31:0] clk_count_0;
wire [31:0] clk_count_1;
wire [31:0] clk_count_2;
wire [31:0] clk_count_3;
wire [31:0] clk_count_4;
wire [31:0] clk_count_5;
wire [31:0] clk_count_6;
wire [31:0] clk_count_7;

freq_counter freq_counter_0 (
    .sys_if_rstn ( sys_if_rstn   ),
    .en_sample   ( en_sample_0   ),
    .clk_samp    ( clk_samp_0    ),
    .clk_count   ( clk_count_0   )
);

freq_counter freq_counter_1 (
    .sys_if_rstn ( sys_if_rstn   ),
    .en_sample   ( en_sample_0   ),
    .clk_samp    ( clk_samp_1    ),
    .clk_count   ( clk_count_1   )
);

freq_counter freq_counter_2 (
    .sys_if_rstn ( sys_if_rstn   ),
    .en_sample   ( en_sample_0   ),
    .clk_samp    ( clk_samp_2    ),
    .clk_count   ( clk_count_2   )
);

freq_counter freq_counter_3 (
    .sys_if_rstn ( sys_if_rstn   ),
    .en_sample   ( en_sample_0   ),
    .clk_samp    ( clk_samp_3    ),
    .clk_count   ( clk_count_3   )
);

freq_counter freq_counter_4 (
    .sys_if_rstn ( sys_if_rstn   ),
    .en_sample   ( en_sample_0   ),
    .clk_samp    ( clk_samp_4    ),
    .clk_count   ( clk_count_4   )
);

freq_counter freq_counter_5 (
    .sys_if_rstn ( sys_if_rstn   ),
    .en_sample   ( en_sample_0   ),
    .clk_samp    ( clk_samp_5    ),
    .clk_count   ( clk_count_5   )
);

freq_counter freq_counter_6 (
    .sys_if_rstn ( sys_if_rstn   ),
    .en_sample   ( en_sample_0   ),
    .clk_samp    ( clk_samp_6    ),
    .clk_count   ( clk_count_6   )
);

freq_counter freq_counter_7 (
    .sys_if_rstn ( sys_if_rstn   ),
    .en_sample   ( en_sample_0   ),
    .clk_samp    ( clk_samp_7    ),
    .clk_count   ( clk_count_7   )
);

// ======================================================================
//  sync counter value back to sample clock

always@(posedge sys_if_clk)
begin
    if ( !sys_if_rstn )
        sample_valid <= 0;
    else if (start_pulse)
        sample_valid <= 0;
    else if (timer1_eq_0)
        sample_valid <= 1;
end

always@(posedge sys_if_clk)
begin
    if (!sys_if_rstn) begin
        IO_SAMP_COUNT_0_VALUE <= 'hFFFFFFFF;
        IO_SAMP_COUNT_1_VALUE <= 'hFFFFFFFF;
        IO_SAMP_COUNT_2_VALUE <= 'hFFFFFFFF;
        IO_SAMP_COUNT_3_VALUE <= 'hFFFFFFFF;
        IO_SAMP_COUNT_4_VALUE <= 'hFFFFFFFF;
        IO_SAMP_COUNT_5_VALUE <= 'hFFFFFFFF;
        IO_SAMP_COUNT_6_VALUE <= 'hFFFFFFFF;
        IO_SAMP_COUNT_7_VALUE <= 'hFFFFFFFF;
    end else if (timer1_eq_0) begin
        IO_SAMP_COUNT_0_VALUE <= clk_count_0;
        IO_SAMP_COUNT_1_VALUE <= clk_count_1;
        IO_SAMP_COUNT_2_VALUE <= clk_count_2;
        IO_SAMP_COUNT_3_VALUE <= clk_count_3;
        IO_SAMP_COUNT_4_VALUE <= clk_count_4;
        IO_SAMP_COUNT_5_VALUE <= clk_count_5;
        IO_SAMP_COUNT_6_VALUE <= clk_count_6;
        IO_SAMP_COUNT_7_VALUE <= clk_count_7;
    end
end

// -----------------------------------------------------------
// 
//    ILA to View I2C Transactions...
//
// -----------------------------------------------------------

//reg         ila_start_pulse    ;
//reg [31:0]  ila_samp_count_in  ;
//reg [31:0]  ila_samp_count_out ;
//reg         ila_sample_valid   ;
//
//always@(posedge sys_if_clk)
//begin
//    ila_start_pulse    <= start_pulse    ;
//    ila_samp_count_in  <= samp_count_in  ;
//    ila_samp_count_out <= clk_count_0    ;
//    ila_sample_valid   <= sample_valid   ;
//end
//
//ila_freq ila_freq (
//    .clk     ( sys_if_clk           ),
//    .probe0  ( ila_start_pulse      ),  // 1b
//    .probe1  ( ila_samp_count_in    ),  // 32b
//    .probe2  ( ila_samp_count_out   ),  // 32b
//    .probe3  ( ila_sample_valid     )   // 1b
//);


endmodule

