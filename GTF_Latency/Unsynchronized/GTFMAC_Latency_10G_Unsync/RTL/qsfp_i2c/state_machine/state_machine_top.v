/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

module state_machine_top #(
    parameter SIMULATION = "false"
) (
    input  wire                      clk              ,
    input  wire                      rst              ,

    input  wire                      dbg_sda_i        ,
    input  wire                      dbg_scl_i        ,


    output wire                      IO_CONTROL_PULSE ,
    output wire [0:0]                IO_CONTROL_RW    ,
    output wire [7:0]                IO_CONTROL_ID    ,
    output wire [7:0]                IO_ADDR_ADDR     ,
    output wire [7:0]                IO_WDATA_WDATA   ,
    input  wire [7:0]                IO_RDATA_RDATA   ,
    input  wire                      IO_CONTROL_CMPLT 
);


//wire vio_rstn ; // = 1'b1;
wire vio_rstn_0 = 1'b1;

//vio_0 vio_0
//(
//    .clk        ( clk           ),
//    .probe_out0 ( vio_rstn      ),
//    .probe_out1 (               ),
//    .probe_out2 (               ),
//    .probe_out3 (               )
//);

// ----------------------------------------------------------------

wire [31:0] timer_rst_dly_rst;
assign timer_rst_dly_rst = (SIMULATION == "true") ? 500 : 50000000;

reg [31:0] timer_rst_dly;
always@(posedge clk)
begin
    if (rst || !vio_rstn_0)
        timer_rst_dly <= timer_rst_dly_rst;
    else if (timer_rst_dly == 'h0)
        timer_rst_dly <= 'h0;
    else
        timer_rst_dly <= timer_rst_dly - 1;
end

wire rst_sm = (timer_rst_dly != 'h0);

           
// ----------------------------------------------------------------


reg           SM_PWR_START  ;
wire          SM_PWR_CMPLT  ;
reg     [3:0] SM_QSFP_INIT  ;
reg     [3:0] SM_QSFP_START ;
wire    [3:0] SM_QSFP_CMPLT ;

// ----------------------------------------------------------------
           
wire timer_zero;

           
localparam ST_RST0           = 'h00;
localparam ST_RST1           = 'h01;
localparam ST_RST2           = 'h02;
localparam ST_RST3           = 'h03;
localparam ST_IDLE           = 'h04;

localparam ST_PWR_INIT       = 'h10;
localparam ST_PWR_WAIT       = 'h11;

localparam ST_QSFP0_INIT     = 'h12;
localparam ST_QSFP0_WAIT0    = 'h13;
localparam ST_QSFP0_SCAN     = 'h14;
localparam ST_QSFP0_WAIT1    = 'h15;

localparam ST_QSFP1_INIT     = 'h16;
localparam ST_QSFP1_WAIT0    = 'h17;
localparam ST_QSFP1_SCAN     = 'h18;
localparam ST_QSFP1_WAIT1    = 'h19;

localparam ST_QSFP2_INIT     = 'h1a;
localparam ST_QSFP2_WAIT0    = 'h1b;
localparam ST_QSFP2_SCAN     = 'h1c;
localparam ST_QSFP2_WAIT1    = 'h1d;

localparam ST_QSFP3_INIT     = 'h1e;
localparam ST_QSFP3_WAIT0    = 'h1f;
localparam ST_QSFP3_SCAN     = 'h20;
localparam ST_QSFP3_WAIT1    = 'h21;

localparam ST_DELAY          = 'h05;

reg [7:0] cstate;
reg [7:0] nstate;

always@(posedge clk)
begin
    if (rst_sm)
        cstate <= ST_RST0;
    else
        cstate <= nstate;
end

always@*
begin
    nstate = cstate;
    case (cstate)
        ST_RST0        : nstate = ST_RST1       ;
        ST_RST1        : nstate = ST_RST2       ;
        ST_RST2        : nstate = ST_RST3       ;
        ST_RST3        : nstate = ST_IDLE       ;
        ST_IDLE        : nstate = ST_PWR_INIT   ;
        
        // Initialize Power
        ST_PWR_INIT    : nstate = ST_PWR_WAIT ;
        ST_PWR_WAIT    : if (SM_PWR_CMPLT) nstate = ST_QSFP0_INIT ;

        // Initizlize SB
        ST_QSFP0_INIT  : nstate = ST_QSFP0_WAIT0 ;
        ST_QSFP0_WAIT0 : if (SM_QSFP_CMPLT[0]) nstate = ST_QSFP1_INIT ;
        
        ST_QSFP1_INIT  : nstate = ST_QSFP1_WAIT0 ;
        ST_QSFP1_WAIT0 : if (SM_QSFP_CMPLT[1]) nstate = ST_QSFP2_INIT ;
        
        ST_QSFP2_INIT  : nstate = ST_QSFP2_WAIT0 ;
        ST_QSFP2_WAIT0 : if (SM_QSFP_CMPLT[2]) nstate = ST_QSFP3_INIT ;
        
        ST_QSFP3_INIT  : nstate = ST_QSFP3_WAIT0 ;
        ST_QSFP3_WAIT0 : if (SM_QSFP_CMPLT[3]) nstate = ST_QSFP0_SCAN ;
        
        // Scan SB Loop
        ST_QSFP0_SCAN  : nstate = ST_QSFP0_WAIT1 ;
        ST_QSFP0_WAIT1 : if (SM_QSFP_CMPLT[0]) nstate = ST_QSFP1_SCAN ;
        
        ST_QSFP1_SCAN  : nstate = ST_QSFP1_WAIT1 ;
        ST_QSFP1_WAIT1 : if (SM_QSFP_CMPLT[1]) nstate = ST_QSFP2_SCAN ;
        
        ST_QSFP2_SCAN  : nstate = ST_QSFP2_WAIT1 ;
        ST_QSFP2_WAIT1 : if (SM_QSFP_CMPLT[2]) nstate = ST_QSFP3_SCAN ;
        
        ST_QSFP3_SCAN  : nstate = ST_QSFP3_WAIT1 ;
        ST_QSFP3_WAIT1 : if (SM_QSFP_CMPLT[3]) nstate = ST_DELAY ;

        ST_DELAY       : if (SIMULATION == "true") 
                            nstate = ST_DELAY;
                         else if (timer_zero) 
                            nstate = ST_QSFP0_SCAN;
    endcase
end

// ----------------------------------------------------------------

reg [31:0] timer;
always@(posedge clk)
begin
    if (rst_sm)
        timer <= 'h0;
    else if (nstate == ST_QSFP3_WAIT1)
        timer <= 50000000;
    else
        timer <= timer - 1;
end

assign timer_zero = (timer == 'h0);


// ----------------------------------------------------------------

always@(posedge clk)
begin
    if (rst_sm) begin
        SM_PWR_START     <= 'h0;
        SM_QSFP_INIT     <= 'h0;
        SM_QSFP_START    <= 'h0;
    end else if (nstate == ST_PWR_INIT) begin
        SM_PWR_START     <= 'h1;
        SM_QSFP_INIT     <= 'h0;
        SM_QSFP_START    <= 'h0;
        
    end else if (nstate == ST_QSFP0_INIT) begin
        SM_PWR_START     <= 'h0;
        SM_QSFP_INIT     <= 'h1;
        SM_QSFP_START    <= 'h1;
    end else if (nstate == ST_QSFP0_SCAN) begin
        SM_PWR_START     <= 'h0;
        SM_QSFP_INIT     <= 'h0;
        SM_QSFP_START    <= 'h1;
        
    end else if (nstate == ST_QSFP1_INIT) begin
        SM_PWR_START     <= 'h0;
        SM_QSFP_INIT     <= 'h2;
        SM_QSFP_START    <= 'h2;
    end else if (nstate == ST_QSFP1_SCAN) begin
        SM_PWR_START     <= 'h0;
        SM_QSFP_INIT     <= 'h0;
        SM_QSFP_START    <= 'h2;
        
    end else if (nstate == ST_QSFP2_INIT) begin
        SM_PWR_START     <= 'h0;
        SM_QSFP_INIT     <= 'h4;
        SM_QSFP_START    <= 'h4;
    end else if (nstate == ST_QSFP2_SCAN) begin
        SM_PWR_START     <= 'h0;
        SM_QSFP_INIT     <= 'h0;
        SM_QSFP_START    <= 'h4;
        
    end else if (nstate == ST_QSFP3_INIT) begin
        SM_PWR_START     <= 'h0;
        SM_QSFP_INIT     <= 'h8;
        SM_QSFP_START    <= 'h8;
    end else if (nstate == ST_QSFP3_SCAN) begin
        SM_PWR_START     <= 'h0;
        SM_QSFP_INIT     <= 'h0;
        SM_QSFP_START    <= 'h8;
        
    end else begin
        SM_PWR_START     <= 'h0;
        SM_QSFP_INIT     <= 'h0;
        SM_QSFP_START    <= 'h0;
    end
end

// ----------------------------------------------------------------


wire       XP_IO_CONTROL_PULSE ;
wire [0:0] XP_IO_CONTROL_RW    ;
wire [7:0] XP_IO_CONTROL_ID    ;
wire [7:0] XP_IO_ADDR_ADDR     ;
wire [7:0] XP_IO_WDATA_WDATA   ;
wire [7:0] XP_IO_RDATA_RDATA   ;
wire       XP_IO_CONTROL_CMPLT ;
           
wire       X0_IO_CONTROL_PULSE ;
wire [0:0] X0_IO_CONTROL_RW    ;
wire [7:0] X0_IO_CONTROL_ID    ;
wire [7:0] X0_IO_ADDR_ADDR     ;
wire [7:0] X0_IO_WDATA_WDATA   ;
wire [7:0] X0_IO_RDATA_RDATA   ;
wire       X0_IO_CONTROL_CMPLT ;
           
wire       X1_IO_CONTROL_PULSE ;
wire [0:0] X1_IO_CONTROL_RW    ;
wire [7:0] X1_IO_CONTROL_ID    ;
wire [7:0] X1_IO_ADDR_ADDR     ;
wire [7:0] X1_IO_WDATA_WDATA   ;
wire [7:0] X1_IO_RDATA_RDATA   ;
wire       X1_IO_CONTROL_CMPLT ;
           
wire       X2_IO_CONTROL_PULSE ;
wire [0:0] X2_IO_CONTROL_RW    ;
wire [7:0] X2_IO_CONTROL_ID    ;
wire [7:0] X2_IO_ADDR_ADDR     ;
wire [7:0] X2_IO_WDATA_WDATA   ;
wire [7:0] X2_IO_RDATA_RDATA   ;
wire       X2_IO_CONTROL_CMPLT ;
           
wire       X3_IO_CONTROL_PULSE ;
wire [0:0] X3_IO_CONTROL_RW    ;
wire [7:0] X3_IO_CONTROL_ID    ;
wire [7:0] X3_IO_ADDR_ADDR     ;
wire [7:0] X3_IO_WDATA_WDATA   ;
wire [7:0] X3_IO_RDATA_RDATA   ;
wire       X3_IO_CONTROL_CMPLT ;

wire [7:0] dbg_cstate_pwr ;
wire [7:0] dbg_cstate_qsfp_0;
wire [7:0] dbg_cstate_qsfp_1;
wire [7:0] dbg_cstate_qsfp_2;
wire [7:0] dbg_cstate_qsfp_3;

state_machine_pwr #(
    .SIMULATION ( SIMULATION )
) state_machine_pwr(
    .clk              ( clk                 ),
    .rst              ( rst_sm              ),
    
    .dbg_cstate       ( dbg_cstate_pwr      ),

    .start            ( SM_PWR_START        ),
    .complete         ( SM_PWR_CMPLT        ),

    .IO_CONTROL_PULSE ( XP_IO_CONTROL_PULSE ),
    .IO_CONTROL_RW    ( XP_IO_CONTROL_RW    ),
    .IO_CONTROL_ID    ( XP_IO_CONTROL_ID    ),
    .IO_ADDR_ADDR     ( XP_IO_ADDR_ADDR     ),
    .IO_WDATA_WDATA   ( XP_IO_WDATA_WDATA   ),
    .IO_RDATA_RDATA   ( XP_IO_RDATA_RDATA   ),
    .IO_CONTROL_CMPLT ( XP_IO_CONTROL_CMPLT )
);



state_machine_sb #(
    .MUX0_VALUE ( 'h01 ),
    .MUX1_VALUE ( 'h00 )
) state_machine_sb_0 (
    .clk              ( clk                 ),
    .rst              ( rst_sm              ),
                                            
    .dbg_cstate       ( dbg_cstate_qsfp_0   ),

    .start            ( SM_QSFP_START[0]    ),
    .init             ( SM_QSFP_INIT[0]     ),
    .complete         ( SM_QSFP_CMPLT[0]    ),

    .IO_CONTROL_PULSE ( X0_IO_CONTROL_PULSE ),
    .IO_CONTROL_RW    ( X0_IO_CONTROL_RW    ),
    .IO_CONTROL_ID    ( X0_IO_CONTROL_ID    ),
    .IO_ADDR_ADDR     ( X0_IO_ADDR_ADDR     ),
    .IO_WDATA_WDATA   ( X0_IO_WDATA_WDATA   ),
    .IO_RDATA_RDATA   ( X0_IO_RDATA_RDATA   ),
    .IO_CONTROL_CMPLT ( X0_IO_CONTROL_CMPLT )
);


state_machine_sb #(
    .MUX0_VALUE ( 'h04 ),
    .MUX1_VALUE ( 'h00 )
) state_machine_sb_1 (
    .clk              ( clk                 ),
    .rst              ( rst_sm              ),
                                            
    .dbg_cstate       ( dbg_cstate_qsfp_1   ),

    .start            ( SM_QSFP_START[1]    ),
    .init             ( SM_QSFP_INIT[1]     ),
    .complete         ( SM_QSFP_CMPLT[1]    ),

    .IO_CONTROL_PULSE ( X1_IO_CONTROL_PULSE ),
    .IO_CONTROL_RW    ( X1_IO_CONTROL_RW    ),
    .IO_CONTROL_ID    ( X1_IO_CONTROL_ID    ),
    .IO_ADDR_ADDR     ( X1_IO_ADDR_ADDR     ),
    .IO_WDATA_WDATA   ( X1_IO_WDATA_WDATA   ),
    .IO_RDATA_RDATA   ( X1_IO_RDATA_RDATA   ),
    .IO_CONTROL_CMPLT ( X1_IO_CONTROL_CMPLT )
);

state_machine_sb #(
    .MUX0_VALUE ( 'h00 ),
    .MUX1_VALUE ( 'h01 )
) state_machine_sb_2 (
    .clk              ( clk                 ),
    .rst              ( rst_sm              ),
                                            
    .dbg_cstate       ( dbg_cstate_qsfp_2   ),

    .start            ( SM_QSFP_START[2]    ),
    .init             ( SM_QSFP_INIT[2]     ),
    .complete         ( SM_QSFP_CMPLT[2]    ),

    .IO_CONTROL_PULSE ( X2_IO_CONTROL_PULSE ),
    .IO_CONTROL_RW    ( X2_IO_CONTROL_RW    ),
    .IO_CONTROL_ID    ( X2_IO_CONTROL_ID    ),
    .IO_ADDR_ADDR     ( X2_IO_ADDR_ADDR     ),
    .IO_WDATA_WDATA   ( X2_IO_WDATA_WDATA   ),
    .IO_RDATA_RDATA   ( X2_IO_RDATA_RDATA   ),
    .IO_CONTROL_CMPLT ( X2_IO_CONTROL_CMPLT )
);

state_machine_sb #(
    .MUX0_VALUE ( 'h00 ),
    .MUX1_VALUE ( 'h04 )
) state_machine_sb_3 (
    .clk              ( clk                 ),
    .rst              ( rst_sm              ),
                                            
    .dbg_cstate       ( dbg_cstate_qsfp_3   ),

    .start            ( SM_QSFP_START[3]    ),
    .init             ( SM_QSFP_INIT[3]     ),
    .complete         ( SM_QSFP_CMPLT[3]    ),

    .IO_CONTROL_PULSE ( X3_IO_CONTROL_PULSE ),
    .IO_CONTROL_RW    ( X3_IO_CONTROL_RW    ),
    .IO_CONTROL_ID    ( X3_IO_CONTROL_ID    ),
    .IO_ADDR_ADDR     ( X3_IO_ADDR_ADDR     ),
    .IO_WDATA_WDATA   ( X3_IO_WDATA_WDATA   ),
    .IO_RDATA_RDATA   ( X3_IO_RDATA_RDATA   ),
    .IO_CONTROL_CMPLT ( X3_IO_CONTROL_CMPLT )
);


assign IO_CONTROL_PULSE  = XP_IO_CONTROL_PULSE | X0_IO_CONTROL_PULSE | X1_IO_CONTROL_PULSE | X2_IO_CONTROL_PULSE | X3_IO_CONTROL_PULSE ;
assign IO_CONTROL_RW     = XP_IO_CONTROL_RW    | X0_IO_CONTROL_RW    | X1_IO_CONTROL_RW    | X2_IO_CONTROL_RW    | X3_IO_CONTROL_RW    ;
assign IO_CONTROL_ID     = XP_IO_CONTROL_ID    | X0_IO_CONTROL_ID    | X1_IO_CONTROL_ID    | X2_IO_CONTROL_ID    | X3_IO_CONTROL_ID    ;
assign IO_ADDR_ADDR      = XP_IO_ADDR_ADDR     | X0_IO_ADDR_ADDR     | X1_IO_ADDR_ADDR     | X2_IO_ADDR_ADDR     | X3_IO_ADDR_ADDR     ;
assign IO_WDATA_WDATA    = XP_IO_WDATA_WDATA   | X0_IO_WDATA_WDATA   | X1_IO_WDATA_WDATA   | X2_IO_WDATA_WDATA   | X3_IO_WDATA_WDATA   ;


assign X0_IO_RDATA_RDATA    = IO_RDATA_RDATA    ;
assign X0_IO_CONTROL_CMPLT  = IO_CONTROL_CMPLT  ;
assign X1_IO_RDATA_RDATA    = IO_RDATA_RDATA    ;
assign X1_IO_CONTROL_CMPLT  = IO_CONTROL_CMPLT  ;
assign X2_IO_RDATA_RDATA    = IO_RDATA_RDATA    ;
assign X2_IO_CONTROL_CMPLT  = IO_CONTROL_CMPLT  ;
assign X3_IO_RDATA_RDATA    = IO_RDATA_RDATA    ;
assign X3_IO_CONTROL_CMPLT  = IO_CONTROL_CMPLT  ;
assign XP_IO_RDATA_RDATA    = IO_RDATA_RDATA    ;
assign XP_IO_CONTROL_CMPLT  = IO_CONTROL_CMPLT  ;



//ila_1 ila_1 (
//    .clk     ( clk               ),
//    .probe0  ( rst               ),  // 1
//    .probe1  ( cstate            ),  // 8 
//    .probe2  ( dbg_cstate_pwr    ),  // 8 
//    .probe3  ( dbg_cstate_qsfp_0 ),  // 8
//    .probe4  ( dbg_cstate_qsfp_1 ),  // 8 
//    .probe5  ( dbg_cstate_qsfp_2 ),  // 8
//    .probe6  ( dbg_cstate_qsfp_3 ),  // 8
//    .probe7  ( IO_CONTROL_PULSE  ),  // 1
//    .probe8  ( IO_CONTROL_RW     ),  // 1
//    .probe9  ( IO_CONTROL_ID     ),  // 8
//    .probe10 ( IO_ADDR_ADDR      ),  // 8
//    .probe11 ( IO_WDATA_WDATA    ),  // 8
//    .probe12 ( IO_RDATA_RDATA    ),  // 8
//    .probe13 ( IO_CONTROL_CMPLT  ),  // 1
//    .probe14 ( dbg_sda_i         ),  // 1
//    .probe15 ( dbg_scl_i         )   // 1
//);

 
 
endmodule
