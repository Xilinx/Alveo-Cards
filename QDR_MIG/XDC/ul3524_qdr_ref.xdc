#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

################################################################################
#
#
#   UL3524 - Master XDC
#   Revision: 1.01 (08/26/2022)

# This XDC contains the necessary pinout, clock, and configuration information to get started on a design.
# Please see UG1585 for more information on board components including part numbers, I2C bus details, clock and power trees.

#
# Bitstream generation
set_property CONFIG_VOLTAGE 1.8                        [current_design]
set_property BITSTREAM.CONFIG.CONFIGFALLBACK Enable    [current_design] ;# Golden image is the fall back image if new bitstream is corrupted.
set_property BITSTREAM.GENERAL.COMPRESS TRUE           [current_design]
set_property CONFIG_MODE SPIx4                         [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4           [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 63.8          [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN disable [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES        [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup         [current_design] ;# Choices are pullnone, pulldown, and pullup.
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR Yes       [current_design]

#
# Power Constraint to enable a warning if design will possibly be over the card's power limit
#
# Use the 63W operating conditions for the UL3524 (default)
set_operating_conditions -design_power_budget 63

#################################################################################
#
# I2C Address Table
#
#################################################################################
#
#     I2C Bus, Device, Description                   Slave Address
#                                                    8-bit    7-Bit
# -----------------------------------                -----    -----
# Power PMBUS_SCL/SCA for +0V9_VCCINT                
#     Renesas ISL68224IRAZ                           0xC0     0x60
#                                                    
# System I2C_MAIN_SCL/SDA                            
#     EEPROM (STM M24C64)                            0xA4     0x52
#                                                    0xB4     0x5A
#     Temp Diode (TI TMP411CDGKT)                    0x9C     0x4E
#     Temp Sense Left (NXP LM75BTP)                  0x90     0x48
#     Temp Sense Right (NXP LM75BTP)                 0x92     0x49
#                                                    
# Clocks CLKGEN_SCL/SDA                              
#     Clock Generator (Renesas RC21008AQ)            0x12     0x09
#     Jitter Cleaner 1 (Renesas RC38612A002GN2)      0xB0     0x58
#     Jitter Cleaner 2 (Renesas RC38612A002GN2)      0xB2     0x59
#     I/O Expander (TI TCA6408APWR) for DDR 2V5VPP   0x42     0x21
#                                                    
# QSFP I2C Busses                                    
#     MUX0 (PCA9545A, A1=0, A0=0)                    0xE0     0x70
#     MUX1 (PCA9545A, A1=1, A0=0)                    0xE4     0x72
#     I/O Expander (TI TCA6408APWR)                  0x42     0x21
#         For Enable Control and Power Good Status        
#                                                    
# QSFP Power Control                                 
#     Module Slave Address                           0xA0     0x50
#         per QSFP-DD hardware spec 3.0 Sept 2017    
#     I/O Expander (TI TCA6408APWR)                  0x40     0x20
#         for QSFP LowSpeed Control
#   

#################################################################################
#
#  LVDS Input Clock References...
#
#################################################################################

#
#  300 Mhz Reference clock for QDRII+ 0, Bank 73 (1.5V)
#                                                                                        
set_property PACKAGE_PIN E17                 [get_ports "CLK10_LVDS_300_N"]              ;# Bank  73 VCCO - +1V5_SYS                               - IO_L11N_T1U_N9_GC_73
set_property IOSTANDARD  LVDS                [get_ports "CLK10_LVDS_300_N"]              ;# Bank  73 VCCO - +1V5_SYS                               - IO_L11N_T1U_N9_GC_73
set_property PACKAGE_PIN E18                 [get_ports "CLK10_LVDS_300_P"]              ;# Bank  73 VCCO - +1V5_SYS                               - IO_L11P_T1U_N8_GC_73
set_property IOSTANDARD  LVDS                [get_ports "CLK10_LVDS_300_P"]              ;# Bank  73 VCCO - +1V5_SYS                               - IO_L11P_T1U_N8_GC_73

#################################################################################
#
#  QDRII+ 0 Interface...
#
#################################################################################

#
#  GSI QDRII+ - 288Mb, 18-bit Data Interface, 550 Mhz 
#     Banks 72, 73 (1.5V)
#
set_property PACKAGE_PIN H24                 [get_ports "QDR0_CQN"]                      ;# Bank  72 VCCO - +1V5_SYS                               - IO_L10P_T1U_N6_QBC_AD4P_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_CQN"]                      ;# Bank  72 VCCO - +1V5_SYS                               - IO_L10P_T1U_N6_QBC_AD4P_72
set_property PACKAGE_PIN K20                 [get_ports "QDR0_CQP"]                      ;# Bank  72 VCCO - +1V5_SYS                               - IO_L7P_T1L_N0_QBC_AD13P_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_CQP"]                      ;# Bank  72 VCCO - +1V5_SYS                               - IO_L7P_T1L_N0_QBC_AD13P_72
set_property PACKAGE_PIN D20                 [get_ports "QDR0_KN"]                       ;# Bank  72 VCCO - +1V5_SYS                               - IO_L16N_T2U_N7_QBC_AD3N_72
set_property IOSTANDARD  DIFF_HSTL_I_DCI     [get_ports "QDR0_KN"]                       ;# Bank  72 VCCO - +1V5_SYS                               - IO_L16N_T2U_N7_QBC_AD3N_72
set_property PACKAGE_PIN E20                 [get_ports "QDR0_KP"]                       ;# Bank  72 VCCO - +1V5_SYS                               - IO_L16P_T2U_N6_QBC_AD3P_72
set_property IOSTANDARD  DIFF_HSTL_I_DCI     [get_ports "QDR0_KP"]                       ;# Bank  72 VCCO - +1V5_SYS                               - IO_L16P_T2U_N6_QBC_AD3P_72
set_property PACKAGE_PIN F18                 [get_ports "QDR0_RN"]                       ;# Bank  73 VCCO - +1V5_SYS                               - IO_T1U_N12_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_RN"]                       ;# Bank  73 VCCO - +1V5_SYS                               - IO_T1U_N12_73
set_property PACKAGE_PIN L18                 [get_ports "QDR0_WN"]                       ;# Bank  73 VCCO - +1V5_SYS                               - IO_L2P_T0L_N2_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_WN"]                       ;# Bank  73 VCCO - +1V5_SYS                               - IO_L2P_T0L_N2_73
set_property PACKAGE_PIN D18                 [get_ports "QDR0_DOFFN"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L12P_T1U_N10_GC_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_DOFFN"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L12P_T1U_N10_GC_73
set_property PACKAGE_PIN B20                 [get_ports "QDR0_BWN[0]"]                   ;# Bank  72 VCCO - +1V5_SYS                               - IO_L19N_T3L_N1_DBC_AD9N_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_BWN[0]"]                   ;# Bank  72 VCCO - +1V5_SYS                               - IO_L19N_T3L_N1_DBC_AD9N_72
set_property PACKAGE_PIN F20                 [get_ports "QDR0_BWN[1]"]                   ;# Bank  72 VCCO - +1V5_SYS                               - IO_L15N_T2L_N5_AD11N_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_BWN[1]"]                   ;# Bank  72 VCCO - +1V5_SYS                               - IO_L15N_T2L_N5_AD11N_72
set_property PACKAGE_PIN M17                 [get_ports "QDR0_A[0]"]                     ;# Bank  73 VCCO - +1V5_SYS                               - IO_L1P_T0L_N0_DBC_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_A[0]"]                     ;# Bank  73 VCCO - +1V5_SYS                               - IO_L1P_T0L_N0_DBC_73
set_property PACKAGE_PIN L17                 [get_ports "QDR0_A[1]"]                     ;# Bank  73 VCCO - +1V5_SYS                               - IO_L1N_T0L_N1_DBC_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_A[1]"]                     ;# Bank  73 VCCO - +1V5_SYS                               - IO_L1N_T0L_N1_DBC_73
set_property PACKAGE_PIN B16                 [get_ports "QDR0_A[2]"]                     ;# Bank  73 VCCO - +1V5_SYS                               - IO_L14N_T2L_N3_GC_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_A[2]"]                     ;# Bank  73 VCCO - +1V5_SYS                               - IO_L14N_T2L_N3_GC_73
set_property PACKAGE_PIN C16                 [get_ports "QDR0_A[3]"]                     ;# Bank  73 VCCO - +1V5_SYS                               - IO_L13N_T2L_N1_GC_QBC_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_A[3]"]                     ;# Bank  73 VCCO - +1V5_SYS                               - IO_L13N_T2L_N1_GC_QBC_73
set_property PACKAGE_PIN K17                 [get_ports "QDR0_A[4]"]                     ;# Bank  73 VCCO - +1V5_SYS                               - IO_L2N_T0L_N3_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_A[4]"]                     ;# Bank  73 VCCO - +1V5_SYS                               - IO_L2N_T0L_N3_73
set_property PACKAGE_PIN F19                 [get_ports "QDR0_A[5]"]                     ;# Bank  73 VCCO - +1V5_SYS                               - IO_L7N_T1L_N1_QBC_AD13N_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_A[5]"]                     ;# Bank  73 VCCO - +1V5_SYS                               - IO_L7N_T1L_N1_QBC_AD13N_73
set_property PACKAGE_PIN G17                 [get_ports "QDR0_A[6]"]                     ;# Bank  73 VCCO - +1V5_SYS                               - IO_L6P_T0U_N10_AD6P_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_A[6]"]                     ;# Bank  73 VCCO - +1V5_SYS                               - IO_L6P_T0U_N10_AD6P_73
set_property PACKAGE_PIN F17                 [get_ports "QDR0_A[7]"]                     ;# Bank  73 VCCO - +1V5_SYS                               - IO_L6N_T0U_N11_AD6N_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_A[7]"]                     ;# Bank  73 VCCO - +1V5_SYS                               - IO_L6N_T0U_N11_AD6N_73
set_property PACKAGE_PIN C19                 [get_ports "QDR0_A[8]"]                     ;# Bank  73 VCCO - +1V5_SYS                               - IO_L8N_T1L_N3_AD5N_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_A[8]"]                     ;# Bank  73 VCCO - +1V5_SYS                               - IO_L8N_T1L_N3_AD5N_73
set_property PACKAGE_PIN A19                 [get_ports "QDR0_A[9]"]                     ;# Bank  73 VCCO - +1V5_SYS                               - IO_L9N_T1L_N5_AD12N_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_A[9]"]                     ;# Bank  73 VCCO - +1V5_SYS                               - IO_L9N_T1L_N5_AD12N_73
set_property PACKAGE_PIN A18                 [get_ports "QDR0_A[10]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L10P_T1U_N6_QBC_AD4P_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_A[10]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L10P_T1U_N6_QBC_AD4P_73
set_property PACKAGE_PIN H19                 [get_ports "QDR0_A[11]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L4N_T0U_N7_DBC_AD7N_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_A[11]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L4N_T0U_N7_DBC_AD7N_73
set_property PACKAGE_PIN D19                 [get_ports "QDR0_A[12]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L8P_T1L_N2_AD5P_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_A[12]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L8P_T1L_N2_AD5P_73
set_property PACKAGE_PIN C18                 [get_ports "QDR0_A[13]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L12N_T1U_N11_GC_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_A[13]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L12N_T1U_N11_GC_73
set_property PACKAGE_PIN C17                 [get_ports "QDR0_A[14]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L13P_T2L_N0_GC_QBC_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_A[14]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L13P_T2L_N0_GC_QBC_73
set_property PACKAGE_PIN L19                 [get_ports "QDR0_A[15]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L3P_T0L_N4_AD15P_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_A[15]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L3P_T0L_N4_AD15P_73
set_property PACKAGE_PIN K18                 [get_ports "QDR0_A[16]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L3N_T0L_N5_AD15N_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_A[16]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L3N_T0L_N5_AD15N_73
set_property PACKAGE_PIN J19                 [get_ports "QDR0_A[17]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L4P_T0U_N6_DBC_AD7P_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_A[17]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L4P_T0U_N6_DBC_AD7P_73
set_property PACKAGE_PIN B19                 [get_ports "QDR0_A[18]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L9P_T1L_N4_AD12P_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_A[18]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L9P_T1L_N4_AD12P_73
set_property PACKAGE_PIN B17                 [get_ports "QDR0_A[19]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L14P_T2L_N2_GC_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_A[19]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L14P_T2L_N2_GC_73
set_property PACKAGE_PIN A17                 [get_ports "QDR0_A[20]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L10N_T1U_N7_QBC_AD4N_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_A[20]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L10N_T1U_N7_QBC_AD4N_73
set_property PACKAGE_PIN G19                 [get_ports "QDR0_A[21]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L7P_T1L_N0_QBC_AD13P_73
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_A[21]"]                    ;# Bank  73 VCCO - +1V5_SYS                               - IO_L7P_T1L_N0_QBC_AD13P_73
set_property PACKAGE_PIN B24                 [get_ports "QDR0_D[0]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L21N_T3L_N5_AD8N_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_D[0]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L21N_T3L_N5_AD8N_72
set_property PACKAGE_PIN D24                 [get_ports "QDR0_D[1]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L20P_T3L_N2_AD1P_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_D[1]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L20P_T3L_N2_AD1P_72
set_property PACKAGE_PIN C24                 [get_ports "QDR0_D[2]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L21P_T3L_N4_AD8P_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_D[2]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L21P_T3L_N4_AD8P_72
set_property PACKAGE_PIN A24                 [get_ports "QDR0_D[3]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L22P_T3U_N6_DBC_AD0P_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_D[3]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L22P_T3U_N6_DBC_AD0P_72
set_property PACKAGE_PIN C23                 [get_ports "QDR0_D[4]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L20N_T3L_N3_AD1N_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_D[4]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L20N_T3L_N3_AD1N_72
set_property PACKAGE_PIN A23                 [get_ports "QDR0_D[5]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L22N_T3U_N7_DBC_AD0N_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_D[5]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L22N_T3U_N7_DBC_AD0N_72
set_property PACKAGE_PIN A22                 [get_ports "QDR0_D[6]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L23N_T3U_N9_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_D[6]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L23N_T3U_N9_72
set_property PACKAGE_PIN B22                 [get_ports "QDR0_D[7]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L23P_T3U_N8_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_D[7]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L23P_T3U_N8_72
set_property PACKAGE_PIN B21                 [get_ports "QDR0_D[8]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L24P_T3U_N10_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_D[8]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L24P_T3U_N10_72
set_property PACKAGE_PIN E21                 [get_ports "QDR0_D[9]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L17P_T2U_N8_AD10P_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_D[9]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L17P_T2U_N8_AD10P_72
set_property PACKAGE_PIN D21                 [get_ports "QDR0_D[10]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L17N_T2U_N9_AD10N_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_D[10]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L17N_T2U_N9_AD10N_72
set_property PACKAGE_PIN G20                 [get_ports "QDR0_D[11]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L15P_T2L_N4_AD11P_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_D[11]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L15P_T2L_N4_AD11P_72
set_property PACKAGE_PIN E22                 [get_ports "QDR0_D[12]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L14N_T2L_N3_GC_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_D[12]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L14N_T2L_N3_GC_72
set_property PACKAGE_PIN F22                 [get_ports "QDR0_D[13]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L13N_T2L_N1_GC_QBC_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_D[13]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L13N_T2L_N1_GC_QBC_72
set_property PACKAGE_PIN G22                 [get_ports "QDR0_D[14]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L13P_T2L_N0_GC_QBC_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_D[14]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L13P_T2L_N0_GC_QBC_72
set_property PACKAGE_PIN F23                 [get_ports "QDR0_D[15]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L14P_T2L_N2_GC_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_D[15]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L14P_T2L_N2_GC_72
set_property PACKAGE_PIN F24                 [get_ports "QDR0_D[16]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L18P_T2U_N10_AD2P_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_D[16]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L18P_T2U_N10_AD2P_72
set_property PACKAGE_PIN E23                 [get_ports "QDR0_D[17]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L18N_T2U_N11_AD2N_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_D[17]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L18N_T2U_N11_AD2N_72
set_property PACKAGE_PIN N24                 [get_ports "QDR0_Q[0]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L1P_T0L_N0_DBC_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_Q[0]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L1P_T0L_N0_DBC_72
set_property PACKAGE_PIN M24                 [get_ports "QDR0_Q[1]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L2P_T0L_N2_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_Q[1]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L2P_T0L_N2_72
set_property PACKAGE_PIN N23                 [get_ports "QDR0_Q[2]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L1N_T0L_N1_DBC_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_Q[2]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L1N_T0L_N1_DBC_72
set_property PACKAGE_PIN K23                 [get_ports "QDR0_Q[3]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L3N_T0L_N5_AD15N_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_Q[3]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L3N_T0L_N5_AD15N_72
set_property PACKAGE_PIN J23                 [get_ports "QDR0_Q[4]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L9N_T1L_N5_AD12N_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_Q[4]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L9N_T1L_N5_AD12N_72
set_property PACKAGE_PIN N22                 [get_ports "QDR0_Q[5]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L4P_T0U_N6_DBC_AD7P_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_Q[5]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L4P_T0U_N6_DBC_AD7P_72
set_property PACKAGE_PIN H22                 [get_ports "QDR0_Q[6]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L11N_T1U_N9_GC_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_Q[6]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L11N_T1U_N9_GC_72
set_property PACKAGE_PIN H21                 [get_ports "QDR0_Q[7]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L12P_T1U_N10_GC_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_Q[7]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L12P_T1U_N10_GC_72
set_property PACKAGE_PIN J21                 [get_ports "QDR0_Q[8]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L8N_T1L_N3_AD5N_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_Q[8]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L8N_T1L_N3_AD5N_72
set_property PACKAGE_PIN J20                 [get_ports "QDR0_Q[9]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L7N_T1L_N1_QBC_AD13N_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_Q[9]"]                     ;# Bank  72 VCCO - +1V5_SYS                               - IO_L7N_T1L_N1_QBC_AD13N_72
set_property PACKAGE_PIN K21                 [get_ports "QDR0_Q[10]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L8P_T1L_N2_AD5P_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_Q[10]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L8P_T1L_N2_AD5P_72
set_property PACKAGE_PIN N21                 [get_ports "QDR0_Q[11]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L5P_T0U_N8_AD14P_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_Q[11]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L5P_T0U_N8_AD14P_72
set_property PACKAGE_PIN M22                 [get_ports "QDR0_Q[12]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L4N_T0U_N7_DBC_AD7N_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_Q[12]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L4N_T0U_N7_DBC_AD7N_72
set_property PACKAGE_PIN H23                 [get_ports "QDR0_Q[13]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L11P_T1U_N8_GC_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_Q[13]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L11P_T1U_N8_GC_72
set_property PACKAGE_PIN L23                 [get_ports "QDR0_Q[14]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L3P_T0L_N4_AD15P_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_Q[14]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L3P_T0L_N4_AD15P_72
set_property PACKAGE_PIN G24                 [get_ports "QDR0_Q[15]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L10N_T1U_N7_QBC_AD4N_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_Q[15]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L10N_T1U_N7_QBC_AD4N_72
set_property PACKAGE_PIN L24                 [get_ports "QDR0_Q[16]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L2N_T0L_N3_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_Q[16]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L2N_T0L_N3_72
set_property PACKAGE_PIN J24                 [get_ports "QDR0_Q[17]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L9P_T1L_N4_AD12P_72
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_Q[17]"]                    ;# Bank  72 VCCO - +1V5_SYS 
                                                                                                                                                                             
