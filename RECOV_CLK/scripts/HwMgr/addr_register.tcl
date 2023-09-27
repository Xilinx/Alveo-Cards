#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#


# -------------------------------------------------------
#  System Registers...
set ADDR_SYS_HEADER0                0x00000000
set ADDR_SYS_HEADER1                0x00000004
set ADDR_SYS_HEADER2                0x00000008
set ADDR_SYS_HEADER3                0x0000000C

# -------------------------------------------------------
#  Frequency Counter Registers...
set ADDR_FC_HEADER0                 0x00010000
set ADDR_FC_HEADER1                 0x00010004
set ADDR_FC_HEADER2                 0x00010008
set ADDR_FC_HEADER3                 0x0001000C
set ADDR_FC_STATUS                  0x00010010
set ADDR_FC_CONTROL                 0x00010014
set ADDR_FC_SAMP_WIDTH              0x00010018
set ADDR_FC_SAMP_COUNT_0            0x00010020
set ADDR_FC_SAMP_COUNT_1            0x00010024
set ADDR_FC_SAMP_COUNT_2            0x00010028
set ADDR_FC_SAMP_COUNT_3            0x0001002c
set ADDR_FC_SAMP_COUNT_4            0x00010030
set ADDR_FC_SAMP_COUNT_5            0x00010034
set ADDR_FC_SAMP_COUNT_6            0x00010038
set ADDR_FC_SAMP_COUNT_7            0x0001003c

# -------------------------------------------------------
#  Jitter Cleaner Reset and GPIO
set ADDR_JC_GPIO_HEADER0            0x00020000
set ADDR_JC_GPIO_HEADER1            0x00020004
set ADDR_JC_GPIO_HEADER2            0x00020008
set ADDR_JC_GPIO_HEADER3            0x0002000C
set ADDR_JC_GPIO_JITT_RSTN_IN       0x00020010
set ADDR_JC_GPIO_JITT_RSTN_OUT      0x00020014
set ADDR_JC_GPIO_JITT_RSTN_CFG      0x00020018
set ADDR_JC_GPIO_JITT1_GPIO_IN      0x00020020
set ADDR_JC_GPIO_JITT1_GPIO_OUT     0x00020024
set ADDR_JC_GPIO_JITT1_GPIO_CFG     0x00020028
set ADDR_JC_GPIO_JITT2_GPIO_IN      0x00020030
set ADDR_JC_GPIO_JITT2_GPIO_OUT     0x00020034
set ADDR_JC_GPIO_JITT2_GPIO_CFG     0x00020038

# -------------------------------------------------------
#  Jitter Cleaner Reset and GPIO
set ADDR_JC_BRAM                    0x00030000

# -------------------------------------------------------
#  Jitter Cleaner I2C Controller
set ADDR_JC_I2C_HEADER0             0x00040000
set ADDR_JC_I2C_HEADER1             0x00040004
set ADDR_JC_I2C_HEADER2             0x00040008
set ADDR_JC_I2C_HEADER3             0x0004000C
set ADDR_JC_I2C_STATUS              0x00040010
set ADDR_JC_I2C_CONTROL             0x00040014


# -------------------------------------------------------
#  Jitter Cleaner I2C Controller
set ADDR_HEADER0                    0x00050000
set ADDR_HEADER1                    0x00050004
set ADDR_HEADER2                    0x00050008
set ADDR_HEADER3                    0x0005000C
set ADDR_STATUS                     0x00050010
set ADDR_CONTROL                    0x00050014
set ADDR_STATUS_TOP                 0x00050020
set ADDR_STATUS_PWR                 0x00050024
set ADDR_STATUS_P0                  0x00050028
set ADDR_STATUS_P1                  0x0005002c
set ADDR_STATUS_P2                  0x00050030
set ADDR_STATUS_P3                  0x00050034
