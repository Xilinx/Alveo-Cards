/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`timescale 1ns / 1ps

module	data_check_64b_v1_2	(
	datain1,	
	datain2,	
	clk,	
	CE,	
	error	
	);	

parameter integer width = 64;

input		[(width - 1):0] datain1;
input		[(width - 1):0] datain2;
input		clk;
input		CE;

output	error;	

wire		[(width - 1):0] mismatch;
wire		[(width - 1):0] mismatch_fd;

wire		[15:0] error_int_1st;
wire		[15:0] error_fd_1st;

wire		[3:0] error_int_2nd;
wire		[3:0] error_fd_2nd;

wire		error_int_3rd;
wire		error_fd_3rd;

wire		[(width - 1):0] error_fd;

assign error = error_fd_3rd;

genvar i;

generate

for(i=0; i<width; i=i+1) 
begin: inst

assign mismatch[i] = datain1[i] ^ datain2[i];
FDRE	fd0	(.CE(CE), .R(1'b0), .D(mismatch[i]),	.Q(mismatch_fd[i]),	.C(clk)); 

end
endgenerate

generate
for(i=0; i<16; i=i+1) 
begin: error_1st

assign error_int_1st[i] = mismatch_fd[(i*4)] | mismatch_fd[(i*4+1)] | mismatch_fd[(i*4+2)] | mismatch_fd[(i*4+3)];
FDRE	fd_error_1st	(.CE(1'b1), .R(1'b0), .D(error_int_1st[i]),	.Q(error_fd_1st[i]),	.C(clk));


end
endgenerate

generate
for(i=0; i<4; i=i+1) 
begin: error_2nd

assign error_int_2nd[i] = error_fd_1st[(i*4)] | error_fd_1st[(i*4+1)] | error_fd_1st[(i*4+2)] | error_fd_1st[(i*4+3)];
FDRE	fd_error_2nd	(.CE(1'b1), .R(1'b0), .D(error_int_2nd[i]),	.Q(error_fd_2nd[i]),	.C(clk));


end
endgenerate

assign error_int_3rd = error_fd_2nd[0] | error_fd_2nd[1] | error_fd_2nd[2] | error_fd_2nd[3];
FDRE	fd_error_3rd	(.CE(1'b1), .R(1'b0), .D(error_int_3rd),	.Q(error_fd_3rd),	.C(clk));

endmodule									