/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/
`timescale 1ns / 1ps

// -------------------------------------------------------------------------------------- //
// Wrapper for bert
// -------------------------------------
// Version     : 1.0
// Date        : 24 June 2013
// Author      : Haur Guang, Choy
// Change log  :
//              (1.0: Haur Guang, Choy)
//                1) This is the wrapper created to include all the bert.
//                
// -------------------------------------------------------------------------------------- //


module bert_pma_top 
#(
	parameter WIDTH = 16,
	parameter MAC_OR_RAW_MODE = 0
)
(
	input 	wire			txclk,
	input	wire			rxclk,
	input 	wire			txrst,
	input 	wire			rxrst,
	input 	wire			txen,
	input 	wire			rxen,
	input 	wire			sync,
	input 	wire			error_counter_ce,
	input 	wire	[WIDTH-1:0] 	data_in,

	output 	wire	[WIDTH-1:0] 	data_out,
	output 	wire			det,
	output 	wire			test1,
	output 	wire			test2,
	output 	wire			pass
);


generate

if ( WIDTH == 16 )
begin
	bert_pma_16b_2_31_v2 #(
		.MAC_OR_RAW_MODE (MAC_OR_RAW_MODE)
		
	) bert_16b (
		.txclk			( txclk ),
		.rxclk			( rxclk ),
		.txrst			( txrst ),
		.rxrst			( rxrst ),
		.txen			( txen ),
		.rxen			( rxen ),
		.sync			( sync ),
		.error_counter_ce	( error_counter_ce ),
		.data_in		( data_in[WIDTH-1:0] ),
		.data_out		( data_out[WIDTH-1:0] ),
		.det			( det ),
		.test1			( test1 ),
		.test2			( test2 ),
		.pass			( pass )
	);
end

else if ( WIDTH == 64 )
begin
	bert_pma_64b_2_31_v2 #(
		.MAC_OR_RAW_MODE (MAC_OR_RAW_MODE)
	) bert_64b (
		.txclk			( txclk ),
		.rxclk			( rxclk ),
		.rst			( txrst ),
		.txen			( txen ),
		.rxen			( rxen ),
		.sync			( sync ),
		.error_counter_ce	( error_counter_ce ),
		.data_in		( data_in[WIDTH-1:0] ),
		.data_out		( data_out[WIDTH-1:0] ),
		.det			( det ),
		.test1			( test1 ),
		.test2			( test2 ),
		.pass			( pass )
	);
end

endgenerate


endmodule
