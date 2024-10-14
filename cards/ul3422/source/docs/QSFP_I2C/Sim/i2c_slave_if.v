/*
(c) Copyright 2019-2022 Xilinx, Inc. All rights reserved.
(c) Copyright 2022-2024 Advanced Micro Devices, Inc. All rights reserved.
This file contains confidential and proprietary information
of Xilinx, Inc. and is protected under U.S. and
international copyright and other intellectual property
laws.
DISCLAIMER
This disclaimer is not a license and does not grant any
rights to the materials distributed herewith. Except as
otherwise provided in a valid license issued to you by
Xilinx, and to the maximum extent permitted by applicable
law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
(2) Xilinx shall not be liable (whether in contract or tort,
including negligence, or under any other theory of
liability) for any loss or damage of any kind or nature
related to, arising under or in connection with these
materials, including for any direct, or any indirect,
special, incidental, or consequential loss or damage
(including loss of data, profits, goodwill, or any type of
loss or damage suffered as a result of any action brought
by a third party) even if such damage or loss was
reasonably foreseeable or Xilinx had been advised of the
possibility of the same.
CRITICAL APPLICATIONS
Xilinx proddcts are not designed or intended to be fail-
safe, or for use in any application requiring fail-safe
performance, such as life-support or safety devices or
systems, Class III medical devices, nuclear facilities,
applications related to the deployment of airbags, or any
other applications that could lead to death, personal
injury, or severe property or environmental damage
(individually and collectively, "Critical
Applications"). Customer assumes the sole risk and
liability of any use of Xilinx proddcts in Critical
Applications, subject only to applicable laws and
regulations governing limitations on proddct liability.
THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
PART OF THIS FILE AT ALL TIMES.

*/

//------------------------------------------------------------------------------

`timescale 1ns / 1ns

module i2c_slave_if #(
    parameter [7:0] device_address = 'hA0
)(
    input  wire       enable       ,
    input  wire       scl_io       ,
    inout  wire       sda_io       ,
    
    output wire       addr_strobe  ,
    output wire       write_strobe ,
    output wire       read_strobe  ,
    output wire [7:0] wdata        ,
    input  wire [7:0] rdata        
);

// ---------------------------------------------------

reg RST;

initial 
begin
    RST <= 1'b0;
    #10;
    RST <= 1'b1;
    #10;
    RST <= 1'b0;
end

// ---------------------------------------------------

wire scl_o   = 'h0;
wire scl_i   ;
wire scl_tri = 'h1;

IOBUF scl_inst (
    .IO ( scl_io  ),
    .I  ( scl_o   ),
    .O  ( scl_i   ),
    .T  ( scl_tri )
);

wire sda_o  = 'h0;
wire sda_i  ;
wire sda_tri;

IOBUF  sda_inst (
    .IO ( sda_io  ),
    .I  ( sda_o   ),
    .O  ( sda_i   ),
    .T  ( sda_tri )
);


wire SCL = scl_i | (~enable);
wire SDA = sda_i | (~enable);


// https://dlbeer.co.nz/articles/i2c.html

//parameter [6:0] device_address = 7'h55;
//parameter [6:0] device_address = 7'h68;
//parameter [6:0] device_address = 7'h34;



// ==============================
//  Start Detection
//     - set on SDA drop while SCL=1
//     - reset when SCL rises

reg     start_detect;
reg     start_resetter;
wire    start_rst = RST | start_resetter;

always @ (posedge start_rst or negedge SDA)
begin
    if (start_rst)
        start_detect <= 1'b0;
    else
        start_detect <= SCL;
end

always @ (posedge RST or posedge SCL)
begin
    if (RST)
        start_resetter <= 1'b0;
    else
        start_resetter <= start_detect;
end


// ==============================
//  Stop Detection
//     - set on SDA rise while SCL=1
//     - reset when SCL rises

reg     stop_detect;
reg     stop_resetter;
wire    stop_rst = RST | stop_resetter;

always @ (posedge stop_rst or posedge SDA)
begin   
    if (stop_rst)
        stop_detect <= 1'b0;
    else
        stop_detect <= SCL;
end

always @ (posedge RST or posedge SCL)
begin   
    if (RST)
        stop_resetter <= 1'b0;
    else
        stop_resetter <= stop_detect;
end


// ==============================
//  Latch Input Data

reg [3:0]   bit_counter;
wire        lsb_bit = (bit_counter == 4'h7) && !start_detect;
wire        ack_bit = (bit_counter == 4'h8) && !start_detect;

always @ (negedge SCL)
begin
    if (ack_bit || start_detect)
        bit_counter <= 4'h0;
    else
        bit_counter <= bit_counter + 4'h1;
end

reg [7:0]   input_shift;
wire        address_detect = (input_shift[7:1] == device_address[7:1]);
wire        read_write_bit = input_shift[0];

always @ (posedge SCL)
    if (!ack_bit)
        input_shift <= {input_shift[6:0], SDA};

reg     master_ack;
always @ (posedge SCL)
    if (ack_bit)
        master_ack <= ~SDA;
                
// ==============================
//  State Machine
                
parameter [2:0] STATE_IDLE      = 3'h0,
                STATE_DEV_ADDR  = 3'h1,
                STATE_READ      = 3'h2,
                STATE_IDX_PTR   = 3'h3,
                STATE_WRITE     = 3'h4;

reg [2:0]       state;

always @ (posedge RST or negedge SCL)
begin
    if (RST)
        state <= STATE_IDLE;
    else if (start_detect)
        state <= STATE_DEV_ADDR;
    else if (ack_bit)
        begin
            case (state)
            STATE_IDLE:
                    state <= STATE_IDLE;
    
            STATE_DEV_ADDR:
                if (!address_detect)
                    state <= STATE_IDLE;
                else if (read_write_bit)
                    state <= STATE_READ;
                else
                    state <= STATE_IDX_PTR;
    
            STATE_READ:
                if (master_ack)
                    state <= STATE_READ;
                else
                    state <= STATE_IDLE;
    
            STATE_IDX_PTR:
                state <= STATE_WRITE;
    
            STATE_WRITE:
                state <= STATE_WRITE;
            endcase
        end
end


// ==============================
//  Register Transfers
reg [7:0] index_pointer; 
always @ (posedge RST or negedge SCL)
begin
    if (RST)
        index_pointer <= 8'h00;
    else if (stop_detect)
        index_pointer <= 8'h00;
    else if (ack_bit)
    begin
        if (state == STATE_IDX_PTR)
            index_pointer <= input_shift;
        else
            index_pointer <= index_pointer + 8'h01;
    end
end

reg [7:0] output_shift;
always @ (negedge SCL)
begin   
    if (lsb_bit)
        output_shift <= rdata;
    else
        output_shift <= {output_shift[6:0], 1'b0};
end

// ==============================
//  Output Driver
reg     output_control;
// assign  SDA = output_control ? 1'bz : 1'b0;

always @ (posedge RST or negedge SCL)
begin   
    if (RST)
        output_control <= 1'b1;
    else if (start_detect)
        output_control <= 1'b1;
    else if (lsb_bit)
        begin   
        output_control <=
            !(  ((state == STATE_DEV_ADDR) && address_detect) ||
                (state == STATE_IDX_PTR) ||
                (state == STATE_WRITE)
            );
        end
    else if (ack_bit)
        begin
        // Deliver the first bit of the next slave-to-master
        // transfer, if applicable.
        if (((state == STATE_READ) && master_ack) ||
            ((state == STATE_DEV_ADDR) &&
                address_detect && read_write_bit))
                output_control <= output_shift[7];
        else
                output_control <= 1'b1;
        end
    else if (state == STATE_READ)
        output_control <= output_shift[7];
    else
        output_control <= 1'b1;
end

assign sda_tri = output_control;


// ------------------------------------------------------

reg read_mode;
always @ (posedge SCL)
begin   
    if (ack_bit && address_detect) read_mode = read_write_bit;
end
        
assign addr_strobe  = (state == STATE_IDX_PTR  ) && ack_bit;
assign write_strobe = (state == STATE_WRITE    ) && ack_bit;
assign read_strobe  = (state == STATE_DEV_ADDR ) && ack_bit && address_detect;
assign wdata        = input_shift;

// ------------------------------------------------------
//initial
//begin
//    $timeformat(-9, 2, " ns");
//end
//
//always @ (negedge SCL)
//    if (write_strobe) 
//        $display("[%0t] i2c :: Write : 0x%02x = 0x%02x", $realtime, index_pointer, input_shift);
//
//always @ (posedge SCL)
//    if (address_detect && ack_bit && (state == STATE_DEV_ADDR) && read_write_bit)  
//        $display("[%0t] i2c :: Read  : 0x%02x = 0x%02x", $realtime, index_pointer, output_shift);
//
endmodule