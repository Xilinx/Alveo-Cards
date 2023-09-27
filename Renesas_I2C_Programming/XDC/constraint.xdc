#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

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
#  300 Mhz Reference clock, Bank 65 (1.8V)                                               
#                                                                                        
set_property PACKAGE_PIN AW18                [get_ports "CLK13_LVDS_300_N"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L14N_T2L_N3_GC_A05_D21_65
set_property IOSTANDARD  LVDS                [get_ports "CLK13_LVDS_300_N"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L14N_T2L_N3_GC_A05_D21_65
set_property PACKAGE_PIN AW19                [get_ports "CLK13_LVDS_300_P"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L14P_T2L_N2_GC_A04_D20_65
set_property IOSTANDARD  LVDS                [get_ports "CLK13_LVDS_300_P"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L14P_T2L_N2_GC_A04_D20_65


#################################################################################
#
#  I2C Interface to ...
#       Jitter Cleaner 1 & 2,
#       Clock Generator,
#       DDR Power Enable I2C I/O Expander
#
#################################################################################

set_property PACKAGE_PIN AR20                [get_ports "CLKGEN_SCL"]                ;# Bank  65 VCCO - +1V8_SYS                               - IO_L23P_T3U_N8_I2C_SCLK_65
set_property IOSTANDARD  LVCMOS18            [get_ports "CLKGEN_SCL"]                ;# Bank  65 VCCO - +1V8_SYS                               - IO_L23P_T3U_N8_I2C_SCLK_65
set_property PACKAGE_PIN AT20                [get_ports "CLKGEN_SDA"]                ;# Bank  65 VCCO - +1V8_SYS                               - IO_L23N_T3U_N9_PERSTN1_I2C_SDA_65
set_property IOSTANDARD  LVCMOS18            [get_ports "CLKGEN_SDA"]                ;# Bank  65 VCCO - +1V8_SYS                               - IO_L23N_T3U_N9_PERSTN1_I2C_SDA_65

