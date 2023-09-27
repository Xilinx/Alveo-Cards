/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/


//-------------------------------------------------------
// System Registers...
localparam ADDR_SYS_HEADER0 = 'h00000000;
localparam ADDR_SYS_HEADER1 = 'h00000004;
localparam ADDR_SYS_HEADER2 = 'h00000008;
localparam ADDR_SYS_HEADER3 = 'h0000000C;

//-------------------------------------------------------
// Frequency Counter Registers...
localparam ADDR_FC_HEADER0      = 'h00010000;
localparam ADDR_FC_HEADER1      = 'h00010004;
localparam ADDR_FC_HEADER2      = 'h00010008;
localparam ADDR_FC_HEADER3      = 'h0001000C;
localparam ADDR_FC_STATUS       = 'h00010010;
localparam ADDR_FC_CONTROL      = 'h00010014;
localparam ADDR_FC_SAMP_WIDTH   = 'h00010018;
localparam ADDR_FC_SAMP_COUNT_0 = 'h00010020;
localparam ADDR_FC_SAMP_COUNT_1 = 'h00010024;
localparam ADDR_FC_SAMP_COUNT_2 = 'h00010028;
localparam ADDR_FC_SAMP_COUNT_3 = 'h0001002c;
localparam ADDR_FC_SAMP_COUNT_4 = 'h00010030;
localparam ADDR_FC_SAMP_COUNT_5 = 'h00010034;
localparam ADDR_FC_SAMP_COUNT_6 = 'h00010038;
localparam ADDR_FC_SAMP_COUNT_7 = 'h0001003c;


//-------------------------------------------------------
// Jitter Cleaner Reset and GPIO
localparam ADDR_JC_GPIO_HEADER0         = 'h00020000;
localparam ADDR_JC_GPIO_HEADER1         = 'h00020004;
localparam ADDR_JC_GPIO_HEADER2         = 'h00020008;
localparam ADDR_JC_GPIO_HEADER3         = 'h0002000C;
localparam ADDR_JC_GPIO_JITT_RSTN_IN    = 'h00020010;
localparam ADDR_JC_GPIO_JITT_RSTN_OUT   = 'h00020014;
localparam ADDR_JC_GPIO_JITT_RSTN_CFG   = 'h00020018;
localparam ADDR_JC_GPIO_JITT1_GPIO_IN   = 'h00020020;
localparam ADDR_JC_GPIO_JITT1_GPIO_OUT  = 'h00020024;
localparam ADDR_JC_GPIO_JITT1_GPIO_CFG  = 'h00020028;
localparam ADDR_JC_GPIO_JITT2_GPIO_IN   = 'h00020030;
localparam ADDR_JC_GPIO_JITT2_GPIO_OUT  = 'h00020034;
localparam ADDR_JC_GPIO_JITT2_GPIO_CFG  = 'h00020038;


//-------------------------------------------------------
// Jitter Cleaner Reset and GPIO
localparam ADDR_JC_BRAM  = 'h00030000;


//-------------------------------------------------------
// Jitter Cleaner I2C Controller
localparam ADDR_JC_I2C_HEADER0 = 'h00040000;
localparam ADDR_JC_I2C_HEADER1 = 'h00040004;
localparam ADDR_JC_I2C_HEADER2 = 'h00040008;
localparam ADDR_JC_I2C_HEADER3 = 'h0004000C;
localparam ADDR_JC_I2C_STATUS  = 'h00040010;
localparam ADDR_JC_I2C_CONTROL = 'h00040014;


//-------------------------------------------------------
// QSFP I2C 
localparam ADDR_QSFP_HEADER0     = 'h00050000;
localparam ADDR_QSFP_HEADER1     = 'h00050004;
localparam ADDR_QSFP_HEADER2     = 'h00050008;
localparam ADDR_QSFP_HEADER3     = 'h0005000C;
localparam ADDR_QSFP_STATUS      = 'h00050010;
localparam ADDR_QSFP_CONTROL     = 'h00050014;
localparam ADDR_QSFP_STATUS_TOP  = 'h00050020;
localparam ADDR_QSFP_STATUS_PWR  = 'h00050024;
localparam ADDR_QSFP_STATUS_P0   = 'h00050028;
localparam ADDR_QSFP_STATUS_P1   = 'h0005002c;
localparam ADDR_QSFP_STATUS_P2   = 'h00050030;
localparam ADDR_QSFP_STATUS_P3   = 'h00050034;
