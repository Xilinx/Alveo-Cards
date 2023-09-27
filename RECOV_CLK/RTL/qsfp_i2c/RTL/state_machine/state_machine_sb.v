/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------
//  SB Control/Status bits
//   0 - LPMODE    (output, 0 = hw control, high power)
//   1 - INTL      (input,  0 = interrupt)
//   2 - MODPRSTL  (input,  0 = present)
//   3 - MODSELL   (output, 0 = I2C enable)
//   4 - RESETL    (output, 1 = enabled)

module state_machine_sb #(
    parameter [7:0] MUX0_VALUE = 'h01,
    parameter [7:0] MUX1_VALUE = 'h00
) (
    input  wire                      clk              ,
    input  wire                      rst              ,
    input  wire                      start            ,
    input  wire                      init             ,
    output reg                       complete         ,
    
    output wire [7:0]                dbg_cstate       ,
    output wire                      dbg_plug_state   ,
                                            
    output reg                       IO_CONTROL_PULSE ,
    output reg  [0:0]                IO_CONTROL_RW    ,
    output reg  [7:0]                IO_CONTROL_ID    ,
    output reg  [7:0]                IO_ADDR_ADDR     ,
    output reg  [7:0]                IO_WDATA_WDATA   ,
    input  wire [7:0]                IO_RDATA_RDATA   ,
    input  wire                      IO_CONTROL_CMPLT
);

// ----------------------------------------------------------------

reg init_r;
always@(posedge clk)
begin
    if (rst)
        init_r <= 'h0;
    else if (start) 
        init_r <= init;
end


localparam READ_OP         = 1'b1 ;
localparam WRITE_OP        = 1'b0 ;

localparam DEV_ID_POWER     = 8'h42 ;
localparam DEV_ID_MUX0      = 8'hE0 ;
localparam DEV_ID_MUX1      = 8'hE4 ;
localparam DEV_ID_QSFP_SB   = 8'h40 ;
localparam DEV_ID_QSFP_I2C  = 8'hA0 ;

// ----------------------------------------------------------------

localparam num_cmds = 5;

// 1'b0, ID[7:0], Addr[7:0], Wdata[7:0]
reg [24:0] instru [0:7];

initial
begin
    // Select and Init...
    instru[00]  = { WRITE_OP, DEV_ID_MUX0,    MUX0_VALUE, MUX0_VALUE }; 
    instru[01]  = { WRITE_OP, DEV_ID_MUX1,    MUX1_VALUE, MUX1_VALUE }; 
    instru[02]  = { WRITE_OP, DEV_ID_QSFP_SB, 8'h01, 8'h00 }; 
    instru[03]  = { WRITE_OP, DEV_ID_QSFP_SB, 8'h03, 8'h06 }; 

    // Read Value
    instru[04]  = { READ_OP,  DEV_ID_QSFP_SB, 8'h00, 8'h00 }; 

    // Reset
    instru[05]  = { WRITE_OP, DEV_ID_QSFP_SB, 8'h01, 8'h00 }; 

    // Enable
    instru[06]  = { WRITE_OP, DEV_ID_QSFP_SB, 8'h01, 8'h10 }; 

end

           
           
// ----------------------------------------------------------------
reg [7:0] r_value;
reg plug_state;

           
wire timer_zero;
wire last_cmd  ;
           
localparam ST_RST        = 'h00;
localparam ST_START      = 'h01;
localparam ST_START_0    = 'h02;
localparam ST_PAUSE_0    = 'h03;
localparam ST_DELAY_0    = 'h04;
localparam ST_START_1    = 'h05;
localparam ST_PAUSE_1    = 'h06;
localparam ST_DELAY_1    = 'h07;
localparam ST_START_2    = 'h08;
localparam ST_PAUSE_2    = 'h09;
localparam ST_DELAY_2    = 'h0a;
localparam ST_START_3    = 'h0b;
localparam ST_PAUSE_3    = 'h0c;
localparam ST_DELAY_3    = 'h0d;
localparam ST_START_4    = 'h0e;
localparam ST_PAUSE_4    = 'h0f;
localparam ST_DELAY_4    = 'h10;
localparam ST_START_5    = 'h11;
localparam ST_PAUSE_5    = 'h12;
localparam ST_DELAY_5    = 'h13;
localparam ST_START_6    = 'h14;
localparam ST_PAUSE_6    = 'h15;
localparam ST_DELAY_6    = 'h16;
localparam ST_DONE       = 'h17;

reg [7:0] cstate;
reg [7:0] nstate;
assign dbg_cstate = cstate;

always@(posedge clk)
begin
    if (rst)
        cstate <= ST_RST;
    else
        cstate <= nstate;
end

always@*
begin
    nstate = cstate;
    case (cstate)
        ST_RST      : nstate = ST_START ;
        ST_START    : if (start) nstate = ST_START_0 ;

        // Select Mux0
        ST_START_0  : nstate = ST_PAUSE_0 ;
        ST_PAUSE_0  : if ( IO_CONTROL_CMPLT ) nstate = ST_DELAY_0 ;       
        ST_DELAY_0  : if ( timer_zero) nstate = ST_START_1 ;

        // Select Mux1
        ST_START_1  : nstate = ST_PAUSE_1 ;
        ST_PAUSE_1  : if ( IO_CONTROL_CMPLT ) nstate = ST_DELAY_1 ;       
        ST_DELAY_1  : if      ( timer_zero &&  init_r) nstate = ST_START_2 ;
                      else if ( timer_zero && !init_r) nstate = ST_START_4 ;
                      
        // Init Output Value...
        ST_START_2  : nstate = ST_PAUSE_2 ;
        ST_PAUSE_2  : if ( IO_CONTROL_CMPLT ) nstate = ST_DELAY_2 ;       
        ST_DELAY_2  : if ( timer_zero) nstate = ST_START_3 ;

        // Init Output Config...
        ST_START_3  : nstate = ST_PAUSE_3 ;
        ST_PAUSE_3  : if ( IO_CONTROL_CMPLT ) nstate = ST_DELAY_3 ;       
        ST_DELAY_3  : if ( timer_zero) nstate = ST_DONE ;

        
        // Scan...
        ST_START_4  : nstate = ST_PAUSE_4 ;
        ST_PAUSE_4  : if ( IO_CONTROL_CMPLT ) nstate = ST_DELAY_4 ;       
        ST_DELAY_4  : if      ( timer_zero &&  plug_state && !r_value[2] ) nstate = ST_START_6 ;
                      else if ( timer_zero && !plug_state &&  r_value[2] ) nstate = ST_START_5 ;
                      else if ( timer_zero )  nstate = ST_DONE ;
        
        // Removed...apply reset
        ST_START_5  : nstate = ST_PAUSE_5 ;
        ST_PAUSE_5  : if ( IO_CONTROL_CMPLT ) nstate = ST_DELAY_5 ;       
        ST_DELAY_5  : if ( timer_zero) nstate = ST_DONE ;
        
        // Inserted...deassert reset
        ST_START_6  : nstate = ST_PAUSE_6 ;
        ST_PAUSE_6  : if ( IO_CONTROL_CMPLT ) nstate = ST_DELAY_6 ;       
        ST_DELAY_6  : if ( timer_zero) nstate = ST_DONE ;

        ST_DONE     : nstate = ST_START ;
    endcase
end

// ----------------------------------------------------------------


always@(posedge clk)
begin
    if (rst)
        complete <= 'h0;
    else
        complete <= (nstate == ST_DONE);
end

reg [15:0] timer;
always@(posedge clk)
begin
    if (rst)
        timer <= 'h0;
    else if ((nstate == ST_PAUSE_0) || 
             (nstate == ST_PAUSE_1) || 
             (nstate == ST_PAUSE_2) || 
             (nstate == ST_PAUSE_3) || 
             (nstate == ST_PAUSE_4) || 
             (nstate == ST_PAUSE_5) || 
             (nstate == ST_PAUSE_6) ) 
        //timer <= 'h0080;
        timer <= 'h0400;
    else
        timer <= timer - 1;
end

assign timer_zero = (timer == 'h0);

always@(posedge clk)
begin
    if (rst)
        r_value <= 'h0;
    else if ((cstate == ST_PAUSE_4) && IO_CONTROL_CMPLT && IO_CONTROL_RW)
        r_value <= IO_RDATA_RDATA;
end

// Plug state : 0 = inserted, 1 = removed
always@(posedge clk)
begin
    if (rst)
        plug_state <= 'h1;
    else if (nstate == ST_START_5)
        plug_state <= r_value[2];
    else if (nstate == ST_START_6)
        plug_state <= r_value[2];
end

// Dbg Plug state : 1 = inserted, 0 = removed
assign dbg_plug_state = ~plug_state;

// ----------------------------------------------------------------

always@(posedge clk)
begin
    if (rst) begin
        IO_CONTROL_PULSE <= 'h0;
        IO_CONTROL_RW    <= 'h0;
        IO_CONTROL_ID    <= 'h0;
        IO_ADDR_ADDR     <= 'h0;
        IO_WDATA_WDATA   <= 'h0;
    end else if (nstate == ST_START_0) begin
        IO_CONTROL_PULSE <= 'h1;
        IO_CONTROL_RW    <= instru[0][24];
        IO_CONTROL_ID    <= instru[0][23:16];
        IO_ADDR_ADDR     <= instru[0][15:8];
        IO_WDATA_WDATA   <= instru[0][7:0];
    end else if (nstate == ST_START_1) begin
        IO_CONTROL_PULSE <= 'h1;
        IO_CONTROL_RW    <= instru[1][24];
        IO_CONTROL_ID    <= instru[1][23:16];
        IO_ADDR_ADDR     <= instru[1][15:8];
        IO_WDATA_WDATA   <= instru[1][7:0];
    end else if (nstate == ST_START_2) begin
        IO_CONTROL_PULSE <= 'h1;
        IO_CONTROL_RW    <= instru[2][24];
        IO_CONTROL_ID    <= instru[2][23:16];
        IO_ADDR_ADDR     <= instru[2][15:8];
        IO_WDATA_WDATA   <= instru[2][7:0];
    end else if (nstate == ST_START_3) begin
        IO_CONTROL_PULSE <= 'h1;
        IO_CONTROL_RW    <= instru[3][24];
        IO_CONTROL_ID    <= instru[3][23:16];
        IO_ADDR_ADDR     <= instru[3][15:8];
        IO_WDATA_WDATA   <= instru[3][7:0];
    end else if (nstate == ST_START_4) begin
        IO_CONTROL_PULSE <= 'h1;
        IO_CONTROL_RW    <= instru[4][24];
        IO_CONTROL_ID    <= instru[4][23:16];
        IO_ADDR_ADDR     <= instru[4][15:8];
        IO_WDATA_WDATA   <= instru[4][7:0];
    end else if (nstate == ST_START_5) begin
        IO_CONTROL_PULSE <= 'h1;
        IO_CONTROL_RW    <= instru[5][24];
        IO_CONTROL_ID    <= instru[5][23:16];
        IO_ADDR_ADDR     <= instru[5][15:8];
        IO_WDATA_WDATA   <= instru[5][7:0];
    end else if (nstate == ST_START_6) begin
        IO_CONTROL_PULSE <= 'h1;
        IO_CONTROL_RW    <= instru[6][24];
        IO_CONTROL_ID    <= instru[6][23:16];
        IO_ADDR_ADDR     <= instru[6][15:8];
        IO_WDATA_WDATA   <= instru[6][7:0];
    end else if (nstate == ST_DONE) begin
        IO_CONTROL_PULSE <= 'h0;
        IO_CONTROL_RW    <= 'h0;
        IO_CONTROL_ID    <= 'h0;
        IO_ADDR_ADDR     <= 'h0;
        IO_WDATA_WDATA   <= 'h0;
    end else begin
        IO_CONTROL_PULSE <= 'h0;
    end
end

// ----------------------------------------------------------------

wire sim_finished = (nstate == ST_DONE) && (cstate != ST_DONE);


//ila_1 ila_1 (
//    .clk     ( clk              ),
//    .probe0  ( rst              ),
//    .probe1  ( start            ),
//    .probe2  ( complete         ),
//    .probe3  ( cstate           ),
//    .probe4  ( r_value          ),
//    .probe5  ( 1'b0             ),
//    .probe6  ( IO_CONTROL_PULSE ),
//    .probe7  ( IO_CONTROL_RW    ),
//    .probe8  ( IO_CONTROL_ID    ),
//    .probe9  ( IO_ADDR_ADDR     ),
//    .probe10 ( IO_WDATA_WDATA   ),
//    .probe11 ( IO_RDATA_RDATA   ),
//    .probe12 ( IO_CONTROL_CMPLT )
//);



endmodule
