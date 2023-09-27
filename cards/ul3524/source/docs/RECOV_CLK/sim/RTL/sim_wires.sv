/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/


// --------------------------------------------------------------
//
//    GTF Signals...
//

wire [0:0] gtf_ch_gtftxn_0;
wire [0:0] gtf_ch_gtftxp_0;
wire [0:0] gtf_ch_gtfrxn_0;
wire [0:0] gtf_ch_gtfrxp_0;

wire [0:0] gtf_ch_gtftxn_1;
wire [0:0] gtf_ch_gtftxp_1;
wire [0:0] gtf_ch_gtfrxn_1;
wire [0:0] gtf_ch_gtfrxp_1;


// --------------------------------------------------------------
//
//    Renesas Signals...
//

wire JITT_RESETN ; pullup( JITT_RESETN );

wire JITT1_GPOI5 ; pullup( JITT1_GPOI5 );
wire JITT1_GPOI4 ; pullup( JITT1_GPOI4 );
wire JITT1_GPOI3 ; pullup( JITT1_GPOI3 );
wire JITT1_GPOI2 ; pullup( JITT1_GPOI2 );
wire JITT1_GPOI1 ; pullup( JITT1_GPOI1 );
wire JITT1_GPOI0 ; pullup( JITT1_GPOI0 );

wire JITT2_GPOI5 ; pullup( JITT2_GPOI5 );
wire JITT2_GPOI4 ; pullup( JITT2_GPOI4 );
wire JITT2_GPOI3 ; pullup( JITT2_GPOI3 );
wire JITT2_GPOI2 ; pullup( JITT2_GPOI2 );
wire JITT2_GPOI1 ; pullup( JITT2_GPOI1 );
wire JITT2_GPOI0 ; pullup( JITT2_GPOI0 );

// --------------------------------------------------------------
//
//    QSFP Signals...
//

wire FPGA_MUX0_RSTN     ; pullup( FPGA_MUX0_RSTN     );
wire FPGA_MUX1_RSTN     ; pullup( FPGA_MUX1_RSTN     );
wire QSFPDD0_IO_RESET_B ; pullup( QSFPDD0_IO_RESET_B );
wire QSFPDD1_IO_RESET_B ; pullup( QSFPDD1_IO_RESET_B );
wire QSFPDD2_IO_RESET_B ; pullup( QSFPDD2_IO_RESET_B );
wire QSFPDD3_IO_RESET_B ; pullup( QSFPDD3_IO_RESET_B );


// --------------------------------------------------------------
//
//    I2C Signals...
//

wire CLKGEN_SDA ; pullup( CLKGEN_SDA );
wire CLKGEN_SCL ; pullup( CLKGEN_SCL );

wire FPGA_SDA_R ; pullup( FPGA_SDA_R );
wire FPGA_SCL_R ; pullup( FPGA_SCL_R );
