/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------
//
//  Description: This module generates the high level register operations to be
//  executed at the target I2C endpoints.  
//
//------------------------------------------------------------------------------

module i2c_sequencer (
    input  wire          aclk        ,
    input  wire          aresetn     ,
              
    input  wire  [31:0]  reg_control ,
    output wire  [31:0]  seq_status  ,

    output reg           seq_req     ,
    output reg           seq_op      ,
    output wire  [7:0]   seq_dev_id  ,
    output reg   [7:0]   seq_addr    ,
    output reg   [7:0]   seq_wdata   ,
    input  wire          seq_ack     ,
    input  wire  [7:0]   seq_rdata   
);                               

// -- A counter from reset deassertion...
reg [15:0] timer_rst;
always@(posedge aclk)
begin
    if (!aresetn) 
        timer_rst <= 'h0;
    else if (reg_control[0]) 
        timer_rst <= 'h0;
    else if (timer_rst == 'hFFFF) 
        timer_rst <= 'hFFFF;
    else 
        timer_rst <= timer_rst + 1;
end

// -- Generate a start pulse after the desired delay...
reg seq_gpio_change;
always@(posedge aclk)
begin
    if (!aresetn) 
        seq_gpio_change <= 'h0;
    else          
        seq_gpio_change <= (timer_rst == 'h1000);
end

// ----------------------------------

// -- Provide a short delay after each sequence step before advancing to the next step
reg [15:0] seq_ack_timer;
always@(posedge aclk)
begin
    if (!aresetn)   
        seq_ack_timer <= 'hFFFF;
    else if ( seq_ack )  
        seq_ack_timer <= 'h0;
    else if ( seq_ack_timer == 'hFFFF ) 
        seq_ack_timer <= 'hFFFF;
    else 
        seq_ack_timer <= seq_ack_timer + 1;
end

wire seq_ack_delay = (seq_ack_timer == 'h1800);

reg [7:0] seq_rdata_reg ;
always@(posedge aclk)
begin
    if (!aresetn)        
        seq_rdata_reg <= 'h0;
    else if ( seq_ack ) 
        seq_rdata_reg <= seq_rdata;
end

// ----------------------------------

localparam ST_IDLE     = 'h00;
localparam ST_WR_REG1  = 'h01;
localparam ST_WT_REG1  = 'h03;
localparam ST_WR_REG3  = 'h05;
localparam ST_WT_REG3  = 'h07;
localparam ST_WR_REG5  = 'h11;
localparam ST_WT_REG5  = 'h13;
//localparam ST_DONE     = 'h09;
localparam ST_DONE_0   = 'h09;
localparam ST_DONE_1   = 'h0A;


reg [7:0] cstate; 
reg [7:0] nstate;

always@(posedge aclk)
    if (!aresetn) cstate <= ST_IDLE;
    else          cstate <= nstate;
    
always@(*)
begin
    nstate = cstate;
    case (cstate)
        ST_IDLE    : if (seq_gpio_change) nstate = ST_WR_REG1;
        ST_WR_REG1 : nstate = ST_WT_REG1;                   
        ST_WT_REG1 : if (seq_ack_delay) nstate = ST_WR_REG3;                   
        ST_WR_REG3 : nstate = ST_WT_REG3;                   
        ST_WT_REG3 : if (seq_ack_delay) nstate = ST_WR_REG5;                   
        ST_WR_REG5 : nstate = ST_WT_REG5;                   
        //ST_WT_REG5 : if (seq_ack_delay) nstate = ST_DONE;                   
        //ST_DONE    : nstate = ST_IDLE;
        ST_WT_REG5 : if      (seq_ack_delay && !seq_rdata_reg[0]) nstate = ST_DONE_0;                   
		             else if (seq_ack_delay &&  seq_rdata_reg[0]) nstate = ST_DONE_1;                   
        ST_DONE_0  : if (seq_gpio_change) nstate = ST_WR_REG1;
        ST_DONE_1  : if (seq_gpio_change) nstate = ST_WR_REG1;
    endcase
end

//assign usr_status = cstate;

// ----------------------------------

assign seq_dev_id = 'h42;

always@(posedge aclk)
begin
    if (!aresetn)                      begin seq_req = 'h0; seq_op = 'h0; seq_addr = 'h00; seq_wdata <= 'h00000000; end
    //else if (nstate == ST_WR_REG1  )   begin seq_req = 'h1; seq_op = 'h1; seq_addr = 'h01; seq_wdata <= (usr_gpio_r & 'h1); end
    else if (nstate == ST_WR_REG1  )   begin seq_req = 'h1; seq_op = 'h0; seq_addr = 'h01; seq_wdata <= 'h00000001; end
    else if (nstate == ST_WR_REG3  )   begin seq_req = 'h1; seq_op = 'h0; seq_addr = 'h03; seq_wdata <= 'h000000FE; end
    else if (nstate == ST_WR_REG5  )   begin seq_req = 'h1; seq_op = 'h1; seq_addr = 'h00; seq_wdata <= 'h00000000; end    
    else                               begin seq_req = 'h0; end
end
             

assign seq_status[7:0]   = cstate;
assign seq_status[15:8]  = seq_rdata_reg;
assign seq_status[23:16] = 'h0;
assign seq_status[31:24] = 'h0;
             
endmodule


