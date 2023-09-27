/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`timescale 1ns / 1ps

`timescale 1 ps / 1 ps
//det_prbs_40b_2_31_x31_x28_1_v2_1nc.v to det_prbs_40b_2_31_x31_x28_1_v2_2nc.v
//replace LUT4 to AND4

module det_prbs_pma_64b_2_31_x31_x28_1_v1 (prbsrx, data0, data1, data2, data3, data4, data5, data6, data7, clk, ce, en_det, rst, detect);

input	[63:0] prbsrx;
input	[63:0] data0;
input	[63:0] data1;
input	[63:0] data2;
input	[63:0] data3;
input	[63:0] data4;
input	[63:0] data5;
input	[63:0] data6;
input	[63:0] data7;
input	clk;
input	ce;
input	en_det;
input	rst;
output 	detect;

reg 	[63:0] prbsrx_reg0;
reg 	[63:0] prbsrx_reg1;
reg 	[63:0] prbsrx_reg2;
reg 	[63:0] prbsrx_reg3;
reg 	[63:0] prbsrx_reg4;
reg 	[63:0] prbsrx_reg5;
reg 	[63:0] prbsrx_reg6;
reg 	[63:0] prbsrx_reg7;

reg 	 ce_reg0;
reg 	 ce_reg1;
reg 	 ce_reg2;
reg 	 ce_reg3;
reg 	 ce_reg4;
reg 	 ce_reg5;
reg 	 ce_reg6;
reg 	 ce_reg7;
always @ (posedge clk or posedge rst) begin
	if (rst) begin
		prbsrx_reg0<=0;
		prbsrx_reg1<=0;
		prbsrx_reg2<=0;
		prbsrx_reg3<=0;
		prbsrx_reg4<=0;
		prbsrx_reg5<=0;		
		prbsrx_reg6<=0;
		prbsrx_reg7<=0;
		ce_reg0<=0;
		ce_reg1<=0;
		ce_reg2<=0;
		ce_reg3<=0;
		ce_reg4<=0;
		ce_reg5<=0;
		ce_reg6<=0;
		ce_reg7<=0;
	end
	else begin
		prbsrx_reg0 <= prbsrx;
		prbsrx_reg1 <= prbsrx_reg0;
		prbsrx_reg2 <= prbsrx_reg1;
		prbsrx_reg3 <= prbsrx_reg2;
		prbsrx_reg4 <= prbsrx_reg3;
		prbsrx_reg5 <= prbsrx_reg4;
		prbsrx_reg6 <= prbsrx_reg5;
		prbsrx_reg7 <= prbsrx_reg6;
		ce_reg0 <= ce;
		ce_reg1 <= ce_reg0;
		ce_reg2 <= ce_reg1;
		ce_reg3 <= ce_reg2;
		ce_reg4 <= ce_reg3;
		ce_reg5 <= ce_reg4;
		ce_reg6 <= ce_reg5;
		ce_reg7 <= ce_reg6;
	end
end


data_check_64b_v1_2 check0 (
	.datain1(data0[63:0]),
	.datain2(prbsrx_reg0[63:0]),
	.clk(clk),
	.CE(ce_reg0),
	.error(err0)
	);

data_check_64b_v1_2 check1 (
	.datain1(data1[63:0]),
	.datain2(prbsrx_reg1[63:0]),
	.clk(clk),
	.CE(ce_reg1),
	.error(err1)
	);

data_check_64b_v1_2 check2 (
	.datain1(data2[63:0]),
	.datain2(prbsrx_reg2[63:0]),
	.clk(clk),
	.CE(ce_reg2),
	.error(err2)
	);

data_check_64b_v1_2 check3 (
	.datain1(data3[63:0]),
	.datain2(prbsrx_reg3[63:0]),
	.clk(clk),
	.CE(ce_reg3),
	.error(err3)
	);

data_check_64b_v1_2 check4 (
	.datain1(data4[63:0]),
	.datain2(prbsrx_reg4[63:0]),
	.clk(clk),
	.CE(ce_reg4),
	.error(err4)
	);

data_check_64b_v1_2 check5 (
	.datain1(data5[63:0]),
	.datain2(prbsrx_reg5[63:0]),
	.clk(clk),
	.CE(ce_reg5),
	.error(err5)
	);

data_check_64b_v1_2 check6 (
	.datain1(data6[63:0]),
	.datain2(prbsrx_reg6[63:0]),
	.clk(clk),
	.CE(ce_reg6),
	.error(err6)
	);

data_check_64b_v1_2 check7 (
	.datain1(data7[63:0]),
	.datain2(prbsrx_reg7[63:0]),
	.clk(clk),
	.CE(ce_reg7),
	.error(err7)
	);

assign err_00 = ~err7 & ~err6 & ~err5 & ~err4;
assign err_01 = ~err3 & ~err2 & ~err1 & ~err0;

FDRE FD_err00 (.CE(1'b1), .R(1'b0), .D(err_00), .C(clk), .Q(err_00_fd));
FDRE FD_err01 (.CE(1'b1), .R(1'b0), .D(err_01), .C(clk), .Q(err_01_fd));

FDRE FD_rst_err_det (.CE(1'b1), .R(1'b0), .D(rst), .C(clk), .Q(rst_err_det));
FDRE FD_rst_err_det_fd (.CE(1'b1), .R(1'b0), .D(rst_err_det), .C(clk), .Q(rst_err_det_fd));

assign err = ~rst & en_det & err_01_fd & err_00_fd;

FDRE error_det0 (
	.C	(clk),
	.CE	(err),
	.R	(rst_err_det_fd),
	.D	(1'b1),
	.Q	(detect)
	);


endmodule