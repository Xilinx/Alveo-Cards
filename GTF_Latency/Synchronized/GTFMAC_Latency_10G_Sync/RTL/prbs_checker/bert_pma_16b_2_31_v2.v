/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2022 03:09:11 PM
// Design Name: 
// Module Name: bert_pma_16b_2_31_v2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1 ps / 1 ps


module bert_pma_16b_2_31_v2 (

	txclk,
	rxclk,
	txrst,
	rxrst,
	txen,
	rxen,
	sync,
	error_counter_ce,
	data_in,
	data_out,
	det,
	test1,
	test2,
	pass
	);

parameter MAC_OR_RAW_MODE = 0;

input	txclk;
input	rxclk;
input	txrst;
input	rxrst;
input	txen;
input	rxen;
input	sync;
input	error_counter_ce;
input	[15:0] data_in;

output	[15:0] data_out;
output	det;
output	test1;
output	test2;
output	pass;

wire [15:0] data_in_dly0;
wire [15:0] data_in_dly1;
wire [15:0] data_in_dly2;
wire [15:0] data_in_dly3;
wire [15:0] data_in_dly4;
wire [15:0] data_in_dly5;
wire [15:0] data_in_dly6;
wire [15:0] data_in_dly7;
wire [15:0] data_in_dly8;
wire [15:0] data_in_dly9;
wire [15:0] data_in_dly10;
wire [15:0] data_in_dly11;
wire [15:0] data_in_dly12;
wire [15:0] data_in_dly13;
wire [15:0] data_in_dly14;
wire [15:0] data_in_dly15;
wire [15:0] data_in_dly16;

wire	[15:0] prbs_rx_out0;
//wire	[15:0] prbs_rx_out1;

wire  err;
wire  det_int;
wire  pass_fd;
wire  lut_error_det_ce;

wire sync_fd1;
wire sync_fd;
wire txen_fd1;
wire txen_fd;
wire datastuck0;
wire datastuck1;

wire det;
wire test1;
wire test2;
wire pass;


genvar i;

assign det = det_int;
assign pass = ~pass_fd;
assign test_1 = data_in_dly3[0];
assign test_2 = prbs_rx_out0[0];

if (MAC_OR_RAW_MODE == 1) begin
	assign txen_fd = txen;
	// FDRE FD_TXEN1 (.CE(1'b1), .R(1'b0), .D(txen), .C(txclk), .Q(txen_fd));
end else begin
	FDRE FD_TXEN (.CE(1'b1), .R(1'b0), .D(txen), .C(txclk), .Q(txen_fd1));
	FDRE FD_TXEN1 (.CE(1'b1), .R(1'b0), .D(txen_fd1), .C(txclk), .Q(txen_fd));
end

FDRE FD_SYNC (.CE(1'b1), .R(1'b0), .D(sync), .C(rxclk), .Q(sync_fd1)); 		// hgchoy : use rxclk instead of txclk
FDRE FD_SYNC1 (.CE(1'b1), .R(1'b0), .D(sync_fd1), .C(rxclk), .Q(sync_fd)); 	// hgchoy : use rxclk instead of txclk

prbs_16_2v31_x31_x28_2 prbs_tx (
	.CE (txen_fd),
	.R (txrst),
	.C (txclk),
	.Q (data_out[15:0])
	);

reg rxen_fd1, rxen_fd2, rxen_fd3, rxen_fd4, rxen_fd5 = 0;

always @ (posedge rxclk) begin
	rxen_fd1 <=	rxen;
    rxen_fd2 <= rxen_fd1;	
	rxen_fd3 <= rxen_fd2;	
    rxen_fd4 <= rxen_fd3;	
    rxen_fd5 <= rxen_fd4;	
end

det_prbs_pma_16b_2_31_x31_x28_1_v1 start_prbs_det0 (
	.data0 (data_in_dly4[15:0]),
	.data1 (data_in_dly5[15:0]),
	.data2 (data_in_dly6[15:0]),
	.data3 (data_in_dly7[15:0]),
	.data4 (data_in_dly8[15:0]),
	.data5 (data_in_dly9[15:0]),
	.data6 (data_in_dly10[15:0]),
	.data7 (data_in_dly11[15:0]),
	.prbsrx (prbs_rx_out0[15:0]),
	.clk (rxclk),
	.ce (MAC_OR_RAW_MODE ? rxen_fd3 : 1'b1),
	.en_det (sync_fd1), //original sync
	.rst (rxrst),
	.detect (det_int)
	);


prbs_ext_16_2v31_x31_x28_1 prbs_rx0 (
	.CE (MAC_OR_RAW_MODE ? rxen_fd3 : 1'b1),
	.rxen (rxen),
	.rxen_fd1 (rxen_fd1),
	.rxen_fd2 (rxen_fd2),
	.rxen_fd3 (rxen_fd3),
	// .sync(MAC_OR_RAW_MODE ? sync_fd2: sync_fd2),
	.sync(sync_fd),
	.syncdatain_dly0(data_in_dly0[15:0]),
	.syncdatain_dly1(data_in_dly1[15:0]),
	.syncdatain_dly2(data_in_dly2[15:0]),
	.R (rxrst),
	.C (rxclk),
	.Q (prbs_rx_out0[15:0])
	);
	
		
data_check_16b_v1_2 check0 (
	.datain1(data_in_dly3[15:0]),
	.datain2(prbs_rx_out0[15:0]),
	.CE (MAC_OR_RAW_MODE ? rxen_fd3 : 1'b1),
	.clk(rxclk),
	.error(err)
	);
	
	
	
	
assign datastuck0 = ((data_in_dly0[15:0] == 16'b0) && (data_in_dly1[15:0] == 16'b0) && (data_in_dly2[15:0] == 16'b0)) ? 1:0;
assign datastuck1 = ((data_in_dly0[15:0] == 16'hFFFF) && (data_in_dly1[15:0] == 16'hFFFF) && (data_in_dly2[15:0] == 16'hFFFF)) ? 1:0;	


assign lut_error_det_ce = (err | (rxen&datastuck0) | (rxen&datastuck1)) & error_counter_ce;

	FDRE error_det (
		.C	(rxclk),
		.CE	(lut_error_det_ce),
		.R	(rxrst),
		.D	(1'b1),
		.Q	(pass_fd)
		);

generate 
	for (i=0; i<16; i=i+1)
	begin: inst	

		FDRE FDDLY0  (.CE(MAC_OR_RAW_MODE ? rxen : 1'b1), .R(1'b0), .D(data_in[i]), .C(rxclk), .Q(data_in_dly0[i]));
		// FDRE FDDLY0  (.CE(1'b1), .R(1'b0), .D(data_in[i] & rxen), .C(rxclk), .Q(data_in_dly0[i]));
		FDRE FDDLY1  (.CE(1'b1), .R(1'b0), .D(data_in_dly0[i]), .C(rxclk), .Q(data_in_dly1[i]));
		FDRE FDDLY2  (.CE(1'b1), .R(1'b0), .D(data_in_dly1[i]), .C(rxclk), .Q(data_in_dly2[i]));
		FDRE FDDLY3  (.CE(1'b1), .R(1'b0), .D(data_in_dly2[i]), .C(rxclk), .Q(data_in_dly3[i]));
		FDRE FDDLY4  (.CE(1'b1), .R(1'b0), .D(data_in_dly3[i]), .C(rxclk), .Q(data_in_dly4[i]));
		FDRE FDDLY5  (.CE(1'b1), .R(1'b0), .D(data_in_dly4[i]), .C(rxclk), .Q(data_in_dly5[i]));
		FDRE FDDLY6  (.CE(1'b1), .R(1'b0), .D(data_in_dly5[i]), .C(rxclk), .Q(data_in_dly6[i]));
		FDRE FDDLY7  (.CE(1'b1), .R(1'b0), .D(data_in_dly6[i]), .C(rxclk), .Q(data_in_dly7[i]));
		FDRE FDDLY8  (.CE(1'b1), .R(1'b0), .D(data_in_dly7[i]), .C(rxclk), .Q(data_in_dly8[i]));
		FDRE FDDLY9  (.CE(1'b1), .R(1'b0), .D(data_in_dly8[i]), .C(rxclk), .Q(data_in_dly9[i]));
		FDRE FDDLY10  (.CE(1'b1), .R(1'b0), .D(data_in_dly9[i]), .C(rxclk), .Q(data_in_dly10[i]));
		FDRE FDDLY11  (.CE(1'b1), .R(1'b0), .D(data_in_dly10[i]), .C(rxclk), .Q(data_in_dly11[i]));
		FDRE FDDLY12  (.CE(1'b1), .R(1'b0), .D(data_in_dly11[i]), .C(rxclk), .Q(data_in_dly12[i]));
		FDRE FDDLY13  (.CE(1'b1), .R(1'b0), .D(data_in_dly12[i]), .C(rxclk), .Q(data_in_dly13[i]));
		// FDRE FDDLY14  (.CE(1'b1), .R(1'b0), .D(data_in_dly13[i]), .C(rxclk), .Q(data_in_dly14[i]));
		// FDRE FDDLY15  (.CE(1'b1), .R(1'b0), .D(data_in_dly14[i]), .C(rxclk), .Q(data_in_dly15[i]));
		// FDRE FDDLY16  (.CE(1'b1), .R(1'b0), .D(data_in_dly15[i]), .C(rxclk), .Q(data_in_dly16[i]));
end
endgenerate

endmodule
