/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`timescale 1 ps / 1 ps
//`define ADD_FCS   


module mac_standard_prbs (

	txclk,
	rxclk,
	txrst,
	rxrst,
	preable_en,
	txen,
	tlast_en,
	sync,
	error_counter_ce,
	data_in,
	data_out,
	pre_data_out,
	det,
	test1,
	test2,
	pass,
	txaxistvalid,
	txaxistready,
	txgbseqstart,
	txaxistlast,
	txaxissof,
	
	rxaxistvalid
);

parameter WIDTH = 16;
parameter PREABLE_BYTE = 3;
localparam MAC_OR_RAW_MODE = 1;	// 0 -- raw, 1 -- mac

input	txclk;
input	rxclk;
input	txrst;
input	rxrst;
input	preable_en;
input	txen;
input	tlast_en;
input	sync;
input	error_counter_ce;
input	[WIDTH-1:0] data_in;

output	[WIDTH-1:0] data_out;
output	[7:0] pre_data_out;
output	det;
output	test1;
output	test2;
output	pass;
output	txaxistvalid;
input	txaxistready;
input	txgbseqstart;
output	[7:0] txaxistlast;
input	rxaxistvalid;
output  [1:0] txaxissof;



wire tlast_en_sticky;
reg [2:0] count_tlast;
wire tvalid_en;

reg txaxistvalid = 0;
reg [1:0] txaxissof = 0;
reg [7:0] pre_data_out = 0;
reg [7:0] txaxistlast = 0;
//reg [7:0] txaxistlast_reg0 = 0;
//reg [7:0] txaxistlast_reg1 = 0;
//reg [7:0] txaxistlast_reg2 = 0;
//reg [7:0] txaxistlast_reg3 = 0;
//reg [7:0] txaxistlast_reg4 = 0;
//reg [7:0] txaxistlast_reg5 = 0;

reg preable_en_reg0 = 0;
reg preable_en_reg1 = 0;
reg preable_en_reg2 = 0;
// axistlast for fcs = 0, for mac25
// 0x1,  the last 7 bytes are in A0 [55:0]
// 0x2,  the last 7 bytes are in A0 [63:8]
// 0x4,  the last 7 bytes are in A0 [63:16] + A1 [7:0]
// 0x8,  the last 7 bytes are in A0 [63:24] + A1 [15:0]
// 0x10, the last 7 bytes are in A0 [63:32] + A1 [23:0]
// 0x20, the last 7 bytes are in A0 [63:40] + A1 [31:0]
// 0x40, the last 7 bytes are in A0 [63:48] + A1 [39:0]
// 0x80, the last 7 bytes are in A0 [63:56] + A1 [47:0]

// fcs = 1, for mac25
// 0x1,  the last 3 bytes are in A0 [23:0]
// 0x2,  the last 3 bytes are in A0 [31:8]
// 0x4,  the last 3 bytes are in A0 [39:16]
// 0x8,  the last 3 bytes are in A0 [47:24]
// 0x10, the last 3 bytes are in A0 [55:32]
// 0x20, the last 3 bytes are in A0 [63:40]
// 0x40, the last 3 bytes are in A0 [63:48] + A1 [7:0]
// 0x80, the last 3 bytes are in A0 [63:56] + A1 [15:0]

reg [7:0] txsequence;	// 8 bits txsequence, keeps on rotating every 256 cycles
reg last_byte_detect = 0;
// wire divclk;


FDCE txaxistlast_sticky (.D(1'b1), .Q(tlast_en_sticky), .CE(tlast_en&txaxistready), .CLR(txrst|preable_en), .C(txclk)); 

`ifdef ADD_FCS
assign tvalid_en = (tlast_en_sticky) && ((count_tlast < 3'd1) || ((count_tlast == 3'd1)&& !txaxistready));
`else
assign tvalid_en = (tlast_en_sticky) && ((count_tlast < 3'd3) || ((count_tlast == 3'd3)&& !txaxistready));
`endif


always @ (posedge txclk) begin
    $display("txaxistready: %d, txaxistvalid: %d, txaxistdata:0x%h", txaxistready, txaxistvalid, data_out);
    $display("tlast_en:%d, tlast_en_sticky:%d, count_tlast:%d, tvalid_en:%d, txaxistlast:%d",tlast_en, tlast_en_sticky, count_tlast, tvalid_en, txaxistlast);
end


if (MAC_OR_RAW_MODE) begin
	// clock divider by 2, to allow more margin
	// div2 seq_clk (.O(divclk), .RST(rst), .I(txclk));  
	always @ (posedge txclk) begin
		if (txrst) begin
			txaxistlast <= 'b0;
		end else if (tlast_en) begin
			txaxistlast <= 'h2;
		end else if (txaxistready == 0) begin	// hold the data till valid
			txaxistlast <= txaxistlast;
		end	else begin
			txaxistlast <= 'b0;
		end		
	end
	
	`ifdef ADD_FCS	
	always @ (posedge txclk) begin
		if (txrst) begin
		  count_tlast <= 'd0;
		end else if (tlast_en_sticky) begin
		    if (((count_tlast < 3'd2) && ( txaxistready == 1'b1) ) ) //|| (count_tlast == 3'd2))
		          count_tlast <= count_tlast +1;
		end else 
		    count_tlast <= 'd0;
    end
    `else
    always @ (posedge txclk) begin
		if (txrst) begin
		  count_tlast <= 'd0;
		end else if (tlast_en_sticky) begin
		    if (((count_tlast < 3'd4) && ( txaxistready == 1'b1) ) ) //|| (count_tlast == 3'd2))
		          count_tlast <= count_tlast +1;
		end else 
		    count_tlast <= 'd0;
    end
    `endif
		
	always @ (posedge txclk) begin
		if (txrst) begin
			txaxistvalid <= 'b0;
		end else begin
		    if (tvalid_en)
		          txaxistvalid <= 1'b1;
		    else
			    txaxistvalid <= txen | preable_en;
		end		
//		if (rst) begin
//			txaxissof <= 'b0;
//		end else if (preable_en) begin
//			txaxissof <= 2'b1;
//		end	else begin
//			txaxissof <= 'b0;
//		end
		if (txrst) begin
			pre_data_out <= 'b0;
		end else if (preable_en | preable_en_reg0 | preable_en_reg1 | preable_en_reg2) begin
			pre_data_out <= PREABLE_BYTE;
		end	else begin
			pre_data_out <= 'b0;
		end
		
		// if (rst) begin
			// TXAXISTREADY <= 'b0;
			// txgbseqstart <= 'b0;
		// end	else begin
			// TXAXISTREADY <= |(txsequence);
			// txgbseqstart <= ~TXAXISTREADY;
		// end
	end
end
bert_pma_top  #(
	.WIDTH				(WIDTH),
	.MAC_OR_RAW_MODE	(MAC_OR_RAW_MODE)		
) bert_pma_top (
	.txclk				(txclk),
	.rxclk				(rxclk),
	.txrst				(txrst),
	.rxrst				(rxrst),
	.txen				(txaxistready & txaxistvalid),
	.rxen				(rxaxistvalid),
	.sync				(sync),
	.error_counter_ce	(error_counter_ce),
	.data_in			(data_in),
	.data_out			(data_out),
	.det 				(det),
	.test1 				(),
	.test2 				(),
	.pass				(pass)
	
);




endmodule