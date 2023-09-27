#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

################################################################################
#
# I2C Address Table
#
################################################################################
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

################################################################################
#
#  LVDS Input Clock References...
#
################################################################################
                                                                                        
#                                                                                        
#  300 Mhz Reference clock, Bank 65 (1.8V)                                               
#                                                                                        
set_property PACKAGE_PIN AW18                [get_ports "CLK13_LVDS_300_N"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L14N_T2L_N3_GC_A05_D21_65
set_property IOSTANDARD  LVDS                [get_ports "CLK13_LVDS_300_N"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L14N_T2L_N3_GC_A05_D21_65
set_property PACKAGE_PIN AW19                [get_ports "CLK13_LVDS_300_P"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L14P_T2L_N2_GC_A04_D20_65
set_property IOSTANDARD  LVDS                [get_ports "CLK13_LVDS_300_P"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L14P_T2L_N2_GC_A04_D20_65


################################################################################
#
#  QSFP MGTF Interfaces...
#
################################################################################

#
#  QSFPDD Resetn Connections - Bank 88 (3.3V)
#     Active Low Reset FPGA Output Signal to I2C I/O Expanders interfacing
#     to QSFP's Low Speed Interface (LPMODE, INTn, MODPRSTn, MODSELn, RESETn)
#
set_property PACKAGE_PIN M16                 [get_ports "QSFPDD0_IO_RESET_B"]            ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L4P_AD12P_93
set_property IOSTANDARD  LVCMOS33            [get_ports "QSFPDD0_IO_RESET_B"]            ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L4P_AD12P_93
set_property PACKAGE_PIN H16                 [get_ports "QSFPDD1_IO_RESET_B"]            ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L8N_HDGC_93
set_property IOSTANDARD  LVCMOS33            [get_ports "QSFPDD1_IO_RESET_B"]            ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L8N_HDGC_93
set_property PACKAGE_PIN F15                 [get_ports "QSFPDD2_IO_RESET_B"]            ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L9N_AD11N_93
set_property IOSTANDARD  LVCMOS33            [get_ports "QSFPDD2_IO_RESET_B"]            ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L9N_AD11N_93
set_property PACKAGE_PIN G16                 [get_ports "QSFPDD3_IO_RESET_B"]            ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L9P_AD11P_93
set_property IOSTANDARD  LVCMOS33            [get_ports "QSFPDD3_IO_RESET_B"]            ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L9P_AD11P_93


################################################################################
#
#  QSFPDD I2C Interface...Bank 93 (3.3V)
#
################################################################################

#  I2C Connections and Expander/Mux Reset...
#       FPGA_SCL_R, FPGA_SDA_R :: I2C Slave Interface to I2C MUX0, I2C MUX1, QSFPDD Power I/O Expander - External Pullup
#       FPGA_MUX0_RSTN         :: Active Low Reset to I2C MUX0 and MUX1 (QSFPDD 0,1,2,3) - External Pullup
#       FPGA_MUX1_RSTN         :: Active Low Reset to I2C Expander (QSFPDD Power) - External Pullup
#       FPGA_MUX0_INTN         :: Active Low Interrupt from I2C MUX0 (QSFPDD 0 & 1) - External Pullup
#       FPGA_MUX1_INTN         :: Active Low Interrupt from I2C MUX1 (QSFPDD 2 & 3) - External Pullup
#       FPGA_OC_INTN           :: Active Low Interrupt from I2C Expander (QSFPDD Power) - External Pullup

set_property PACKAGE_PIN F12                 [get_ports "FPGA_SCL_R"]                  ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L12P_AD8P_93
set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_SCL_R"]                  ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L12P_AD8P_93
set_property PACKAGE_PIN F11                 [get_ports "FPGA_SDA_R"]                  ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L12N_AD8N_93
set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_SDA_R"]                  ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L12N_AD8N_93

set_property PACKAGE_PIN G14                 [get_ports "FPGA_MUX0_RSTN"]              ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L11P_AD9P_93
set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_MUX0_RSTN"]              ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L11P_AD9P_93
set_property PACKAGE_PIN G15                 [get_ports "FPGA_MUX1_RSTN"]              ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L10P_AD10P_93
set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_MUX1_RSTN"]              ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L10P_AD10P_93

#set_property PACKAGE_PIN F13                 [get_ports "FPGA_MUX0_INTN"]              ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L11N_AD9N_93
#set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_MUX0_INTN"]              ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L11N_AD9N_93
#set_property PACKAGE_PIN F14                 [get_ports "FPGA_MUX1_INTN"]              ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L10N_AD10N_93
#set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_MUX1_INTN"]              ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L10N_AD10N_93
#set_property PACKAGE_PIN J16                 [get_ports "FPGA_OC_INTN"]                ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L8P_HDGC_93
#set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_OC_INTN"]                ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L8P_HDGC_93
