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
#  300 Mhz Reference clock for QDRII+ 0, Bank 73 (1.5V)
#                                                                                        
#set_property PACKAGE_PIN E17                 [get_ports "CLK10_LVDS_300_N"]              ;# Bank  73 VCCO - +1V5_SYS                               - IO_L11N_T1U_N9_GC_73
#set_property IOSTANDARD  LVDS                [get_ports "CLK10_LVDS_300_N"]              ;# Bank  73 VCCO - +1V5_SYS                               - IO_L11N_T1U_N9_GC_73
#set_property PACKAGE_PIN E18                 [get_ports "CLK10_LVDS_300_P"]              ;# Bank  73 VCCO - +1V5_SYS                               - IO_L11P_T1U_N8_GC_73
#set_property IOSTANDARD  LVDS                [get_ports "CLK10_LVDS_300_P"]              ;# Bank  73 VCCO - +1V5_SYS                               - IO_L11P_T1U_N8_GC_73
#create_clock -period 3.333 -name CLK_CLK10_LVDS_300_P   [get_ports CLK10_LVDS_300_P]

#                                                                                        
#  300 Mhz Reference clock for QDRII+ 1, Bank 71 (1.5V)                                  
#                                                                                        
#set_property PACKAGE_PIN G27                 [get_ports "CLK11_LVDS_300_N"]              ;# Bank  71 VCCO - +1V5_SYS                               - IO_L12N_T1U_N11_GC_71
#set_property IOSTANDARD  LVDS                [get_ports "CLK11_LVDS_300_N"]              ;# Bank  71 VCCO - +1V5_SYS                               - IO_L12N_T1U_N11_GC_71
#set_property PACKAGE_PIN G26                 [get_ports "CLK11_LVDS_300_P"]              ;# Bank  71 VCCO - +1V5_SYS                               - IO_L12P_T1U_N10_GC_71
#set_property IOSTANDARD  LVDS                [get_ports "CLK11_LVDS_300_P"]              ;# Bank  71 VCCO - +1V5_SYS                               - IO_L12P_T1U_N10_GC_71
#create_clock -period 3.333 -name CLK_CLK11_LVDS_300_P   [get_ports CLK11_LVDS_300_P]
                                                                                         
#                                                                                        
#  300 Mhz Reference clock for DDR1, Bank 66 (1.2V)                                      
#                                                                                        
set_property PACKAGE_PIN AY22                [get_ports "CLK12_LVDS_300_N"]              ;# Bank  66 VCCO - 1V2_VCCO                               - IO_L13N_T2L_N1_GC_QBC_66
set_property IOSTANDARD  LVDS                [get_ports "CLK12_LVDS_300_N"]              ;# Bank  66 VCCO - 1V2_VCCO                               - IO_L13N_T2L_N1_GC_QBC_66
set_property PACKAGE_PIN AW23                [get_ports "CLK12_LVDS_300_P"]              ;# Bank  66 VCCO - 1V2_VCCO                               - IO_L13P_T2L_N0_GC_QBC_66
set_property IOSTANDARD  LVDS                [get_ports "CLK12_LVDS_300_P"]              ;# Bank  66 VCCO - 1V2_VCCO                               - IO_L13P_T2L_N0_GC_QBC_66
create_clock -period 3.333 -name CLK_CLK12_LVDS_300_P   [get_ports CLK12_LVDS_300_P]


                                    
#                                                                                        
#  300 Mhz Reference clock, Bank 65 (1.8V)                                               
#                                                                                        
set_property PACKAGE_PIN AW18                [get_ports "CLK13_LVDS_300_N"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L14N_T2L_N3_GC_A05_D21_65
set_property IOSTANDARD  LVDS                [get_ports "CLK13_LVDS_300_N"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L14N_T2L_N3_GC_A05_D21_65
set_property PACKAGE_PIN AW19                [get_ports "CLK13_LVDS_300_P"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L14P_T2L_N2_GC_A04_D20_65
set_property IOSTANDARD  LVDS                [get_ports "CLK13_LVDS_300_P"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L14P_T2L_N2_GC_A04_D20_65
#create_clock -period 3.333 -name CLK_CLK13_LVDS_300_P   [get_ports CLK13_LVDS_300_P]

#set_property PACKAGE_PIN BF18                [get_ports "RECOV_CLK10_LVDS_N"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L3N_T0L_N5_AD15N_A27_65
#set_property IOSTANDARD  LVDS                [get_ports "RECOV_CLK10_LVDS_N"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L3N_T0L_N5_AD15N_A27_65
#set_property PACKAGE_PIN BE18                [get_ports "RECOV_CLK10_LVDS_P"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L3P_T0L_N4_AD15P_A26_65
#set_property IOSTANDARD  LVDS                [get_ports "RECOV_CLK10_LVDS_P"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L3P_T0L_N4_AD15P_A26_65

set_property PACKAGE_PIN BF19                [get_ports "RECOV_CLK11_LVDS_N"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L4N_T0U_N7_DBC_AD7N_A25_65
set_property IOSTANDARD  LVDS                [get_ports "RECOV_CLK11_LVDS_N"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L4N_T0U_N7_DBC_AD7N_A25_65
set_property PACKAGE_PIN BF20                [get_ports "RECOV_CLK11_LVDS_P"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L4P_T0U_N6_DBC_AD7P_A24_65
set_property IOSTANDARD  LVDS                [get_ports "RECOV_CLK11_LVDS_P"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L4P_T0U_N6_DBC_AD7P_A24_65

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


#################################################################################
#
#  Jitter Cleaner GPIO and Reset Signals...
#
#################################################################################

#
#  Jitter Resetn - Active Low Output Signal to Jitter Cleaner 1 & 2, Banks 65 (1.8V)
#
set_property PACKAGE_PIN AY16                [get_ports "JITT_RESETN"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L10N_T1U_N7_QBC_AD4N_A13_D29_65
set_property IOSTANDARD  LVCMOS18            [get_ports "JITT_RESETN"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L10N_T1U_N7_QBC_AD4N_A13_D29_65

#
#  Jitter Cleaner 1 GPIO - Banks 65 (1.8V)
#
set_property PACKAGE_PIN AP16                [get_ports "JITT1_GPOI0"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L19P_T3L_N0_DBC_AD9P_D10_65
set_property IOSTANDARD  LVCMOS18            [get_ports "JITT1_GPOI0"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L19P_T3L_N0_DBC_AD9P_D10_65
set_property PACKAGE_PIN AT17                [get_ports "JITT1_GPOI1"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L18P_T2U_N10_AD2P_D12_65
set_property IOSTANDARD  LVCMOS18            [get_ports "JITT1_GPOI1"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L18P_T2U_N10_AD2P_D12_65
set_property PACKAGE_PIN AU16                [get_ports "JITT1_GPOI2"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L18N_T2U_N11_AD2N_D13_65
set_property IOSTANDARD  LVCMOS18            [get_ports "JITT1_GPOI2"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L18N_T2U_N11_AD2N_D13_65
set_property PACKAGE_PIN AV19                [get_ports "JITT1_GPOI3"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_T2U_N12_CSI_ADV_B_65
set_property IOSTANDARD  LVCMOS18            [get_ports "JITT1_GPOI3"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_T2U_N12_CSI_ADV_B_65
set_property PACKAGE_PIN AR16                [get_ports "JITT1_GPOI4"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L19N_T3L_N1_DBC_AD9N_D11_65
set_property IOSTANDARD  LVCMOS18            [get_ports "JITT1_GPOI4"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L19N_T3L_N1_DBC_AD9N_D11_65
set_property PACKAGE_PIN AP18                [get_ports "JITT1_GPOI5"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L20P_T3L_N2_AD1P_D08_65
set_property IOSTANDARD  LVCMOS18            [get_ports "JITT1_GPOI5"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L20P_T3L_N2_AD1P_D08_65
#Removed: set_property PACKAGE_PIN AV16                [get_ports "JITT1_GPOI9"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L17N_T2U_N9_AD10N_D15_65
#Removed: set_property IOSTANDARD  LVCMOS18            [get_ports "JITT1_GPOI9"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L17N_T2U_N9_AD10N_D15_65

#
#  Jitter Cleaner 2 GPIO - Banks 65 (1.8V)
#
set_property PACKAGE_PIN AY17                [get_ports "JITT2_GPOI0"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L12P_T1U_N10_GC_A08_D24_65
set_property IOSTANDARD  LVCMOS18            [get_ports "JITT2_GPOI0"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L12P_T1U_N10_GC_A08_D24_65
set_property PACKAGE_PIN BB19                [get_ports "JITT2_GPOI1"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L11N_T1U_N9_GC_A11_D27_65
set_property IOSTANDARD  LVCMOS18            [get_ports "JITT2_GPOI1"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L11N_T1U_N9_GC_A11_D27_65
set_property PACKAGE_PIN BA17                [get_ports "JITT2_GPOI2"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L12N_T1U_N11_GC_A09_D25_65
set_property IOSTANDARD  LVCMOS18            [get_ports "JITT2_GPOI2"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L12N_T1U_N11_GC_A09_D25_65
set_property PACKAGE_PIN BC18                [get_ports "JITT2_GPOI3"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_T1U_N12_SMBALERT_65
set_property IOSTANDARD  LVCMOS18            [get_ports "JITT2_GPOI3"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_T1U_N12_SMBALERT_65
set_property PACKAGE_PIN AY18                [get_ports "JITT2_GPOI4"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L13P_T2L_N0_GC_QBC_A06_D22_65
set_property IOSTANDARD  LVCMOS18            [get_ports "JITT2_GPOI4"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L13P_T2L_N0_GC_QBC_A06_D22_65
set_property PACKAGE_PIN BA19                [get_ports "JITT2_GPOI5"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L11P_T1U_N8_GC_A10_D26_65
set_property IOSTANDARD  LVCMOS18            [get_ports "JITT2_GPOI5"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L11P_T1U_N8_GC_A10_D26_65
    

#################################################################################
#
#  SYNCE_CLK Pins and Internal FPGA LOC's
#
#################################################################################

#                             FPGA DETAILS                        JC-1 Detail
#              ---------------------------------------------  --------------------
# CLOCK        PIN (P/N)  BANK  COMMON LOC       CLOCKREGION  Pin Name  Pin #(P/N)
# -----------  ---------  ----  ---------------  -----------  --------  ----------
# SYNCE_CLK10  AN11/AN10  226   GTF_COMMON_X1Y2  X5Y2         Q5        39/40
# SYNCE_CLK11  AJ11/AJ10  227   GTF_COMMON_X1Y3  X5Y3         Q6        36/35
# SYNCE_CLK12  AE11/AE10  228   GTF_COMMON_X1Y4  X5Y4         Q10       45/46
# SYNCE_CLK13  AA11/AA10  229   GTF_COMMON_X1Y5  X5Y5         Q4        42/43
# SYNCE_CLK14  U11/U10    230   GTF_COMMON_X1Y6  X5Y6         Q9        51/50
# SYNCE_CLK15  N11/N10    231   GTF_COMMON_X1Y7  X5Y7         Q0        65/64
# SYNCE_CLK16  H9/H8      232   GTF_COMMON_X1Y8  X5Y8         Q1        61/62
# SYNCE_CLK17  D9/D8      233   GTF_COMMON_X1Y9  X5Y9         Q3        54/53


#
#  QSFPDD 0 GTF Connections - Bank 232, 233
#    Typical pin constraints are embedded in the IP
#
#set_property PACKAGE_PIN H8                  [get_ports "SYNCE_CLK16_LVDS_N"]            ;# Bank 232 - MGTREFCLK0N_232
#set_property PACKAGE_PIN H9                  [get_ports "SYNCE_CLK16_LVDS_P"]            ;# Bank 232 - MGTREFCLK0P_232

set_property PACKAGE_PIN D8                  [get_ports "SYNCE_CLK17_LVDS_N"]            ;# Bank 233 - MGTREFCLK0N_233
set_property PACKAGE_PIN D9                  [get_ports "SYNCE_CLK17_LVDS_P"]            ;# Bank 233 - MGTREFCLK0P_233

#
#  QSFPDD 1 GTF Connections - Bank 230, 231
#    Typical pin constraints are embedded in the IP
#
set_property PACKAGE_PIN U10                 [get_ports "SYNCE_CLK14_LVDS_N"]            ;# Bank 230 - MGTREFCLK0N_230
set_property PACKAGE_PIN U11                 [get_ports "SYNCE_CLK14_LVDS_P"]            ;# Bank 230 - MGTREFCLK0P_230

set_property PACKAGE_PIN N10                 [get_ports "SYNCE_CLK15_LVDS_N"]            ;# Bank 231 - MGTREFCLK0N_231
set_property PACKAGE_PIN N11                 [get_ports "SYNCE_CLK15_LVDS_P"]            ;# Bank 231 - MGTREFCLK0P_231

#
#  QSFPDD 2 GTF Connections - Bank 228, 229
#    Typical pin constraints are embedded in the IP
#
set_property PACKAGE_PIN AE10                [get_ports "SYNCE_CLK12_LVDS_N"]            ;# Bank 228 - MGTREFCLK0N_228
set_property PACKAGE_PIN AE11                [get_ports "SYNCE_CLK12_LVDS_P"]            ;# Bank 228 - MGTREFCLK0P_228

set_property PACKAGE_PIN AA10                [get_ports "SYNCE_CLK13_LVDS_N"]            ;# Bank 229 - MGTREFCLK0N_229
set_property PACKAGE_PIN AA11                [get_ports "SYNCE_CLK13_LVDS_P"]            ;# Bank 229 - MGTREFCLK0P_229

#
# Constrain each clock to default 10G frequency of 161.1Mhz
#
create_clock -period 6.207 -name CLK_SYNCE_CLK10_LVDS_P [get_ports SYNCE_CLK10_LVDS_P]
create_clock -period 6.207 -name CLK_SYNCE_CLK11_LVDS_P [get_ports SYNCE_CLK11_LVDS_P]
create_clock -period 6.207 -name CLK_SYNCE_CLK12_LVDS_P [get_ports SYNCE_CLK12_LVDS_P]
create_clock -period 6.207 -name CLK_SYNCE_CLK13_LVDS_P [get_ports SYNCE_CLK13_LVDS_P]
create_clock -period 6.207 -name CLK_SYNCE_CLK14_LVDS_P [get_ports SYNCE_CLK14_LVDS_P]
create_clock -period 6.207 -name CLK_SYNCE_CLK15_LVDS_P [get_ports SYNCE_CLK15_LVDS_P]
create_clock -period 6.207 -name CLK_SYNCE_CLK16_LVDS_P [get_ports SYNCE_CLK16_LVDS_P]
create_clock -period 6.207 -name CLK_SYNCE_CLK17_LVDS_P [get_ports SYNCE_CLK17_LVDS_P]


#
#  QSFPDD 3 GTF Connections - Bank 226, 227
#    Typical pin constraints are embedded in the IP
#
set_property PACKAGE_PIN AJ10                [get_ports "SYNCE_CLK11_LVDS_N"]            ;# Bank 227 - MGTREFCLK0N_227
set_property PACKAGE_PIN AJ11                [get_ports "SYNCE_CLK11_LVDS_P"]            ;# Bank 227 - MGTREFCLK0P_227

set_property PACKAGE_PIN AK3                 [get_ports "gtf_ch_gtfrxn_0[0]"]            ;# Bank 227 - MGTFRXN0_227
set_property PACKAGE_PIN AK4                 [get_ports "gtf_ch_gtfrxp_0[0]"]            ;# Bank 227 - MGTFRXP0_227
set_property PACKAGE_PIN AJ1                 [get_ports "gtf_ch_gtfrxn_0[1]"]            ;# Bank 227 - MGTFTXN0_227
set_property PACKAGE_PIN AJ2                 [get_ports "gtf_ch_gtfrxp_0[1]"]            ;# Bank 227 - MGTFTXP0_227
set_property PACKAGE_PIN AH3                 [get_ports "gtf_ch_gtfrxn_0[2]"]            ;# Bank 227 - MGTFRXN0_227
set_property PACKAGE_PIN AH4                 [get_ports "gtf_ch_gtfrxp_0[2]"]            ;# Bank 227 - MGTFRXP0_227
set_property PACKAGE_PIN AG1                 [get_ports "gtf_ch_gtfrxn_0[3]"]            ;# Bank 227 - MGTFTXN0_227
set_property PACKAGE_PIN AG2                 [get_ports "gtf_ch_gtfrxp_0[3]"]            ;# Bank 227 - MGTFTXP0_227
set_property PACKAGE_PIN AM8                 [get_ports "gtf_ch_gtftxn_0[0]"]            ;# Bank 227 - MGTFRXN0_227
set_property PACKAGE_PIN AM9                 [get_ports "gtf_ch_gtftxp_0[0]"]            ;# Bank 227 - MGTFRXP0_227
set_property PACKAGE_PIN AL6                 [get_ports "gtf_ch_gtftxn_0[1]"]            ;# Bank 227 - MGTFTXN0_227
set_property PACKAGE_PIN AL7                 [get_ports "gtf_ch_gtftxp_0[1]"]            ;# Bank 227 - MGTFTXP0_227
set_property PACKAGE_PIN AK8                 [get_ports "gtf_ch_gtftxn_0[2]"]            ;# Bank 227 - MGTFRXN0_227
set_property PACKAGE_PIN AK9                 [get_ports "gtf_ch_gtftxp_0[2]"]            ;# Bank 227 - MGTFRXP0_227
set_property PACKAGE_PIN AJ6                 [get_ports "gtf_ch_gtftxn_0[3]"]            ;# Bank 227 - MGTFTXN0_227
set_property PACKAGE_PIN AJ7                 [get_ports "gtf_ch_gtftxp_0[3]"]            ;# Bank 227 - MGTFTXP0_227


#
#  QSFPDD 0 GTF Connections - Bank 232, 233
#    Typical pin constraints are embedded in the IP
#
set_property PACKAGE_PIN H8                  [get_ports "SYNCE_CLK16_LVDS_N"]            ;# Bank 232 - MGTREFCLK0N_232
set_property PACKAGE_PIN H9                  [get_ports "SYNCE_CLK16_LVDS_P"]            ;# Bank 232 - MGTREFCLK0P_232

set_property PACKAGE_PIN K3                  [get_ports "gtf_ch_gtfrxn_1[0]"]            ;# Bank 232 - MGTFRXN0_232
set_property PACKAGE_PIN K4                  [get_ports "gtf_ch_gtfrxp_1[0]"]            ;# Bank 232 - MGTFRXP0_232
set_property PACKAGE_PIN J1                  [get_ports "gtf_ch_gtfrxn_1[1]"]            ;# Bank 232 - MGTFRXN1_232
set_property PACKAGE_PIN J2                  [get_ports "gtf_ch_gtfrxp_1[1]"]            ;# Bank 232 - MGTFRXP1_232
set_property PACKAGE_PIN H3                  [get_ports "gtf_ch_gtfrxn_1[2]"]            ;# Bank 232 - MGTFRXN2_232
set_property PACKAGE_PIN H4                  [get_ports "gtf_ch_gtfrxp_1[2]"]            ;# Bank 232 - MGTFRXP2_232
set_property PACKAGE_PIN G1                  [get_ports "gtf_ch_gtfrxn_1[3]"]            ;# Bank 232 - MGTFRXN3_232
set_property PACKAGE_PIN G2                  [get_ports "gtf_ch_gtfrxp_1[3]"]            ;# Bank 232 - MGTFRXP3_232
set_property PACKAGE_PIN M8                  [get_ports "gtf_ch_gtftxn_1[0]"]            ;# Bank 232 - MGTFTXN0_232
set_property PACKAGE_PIN M9                  [get_ports "gtf_ch_gtftxp_1[0]"]            ;# Bank 232 - MGTFTXP0_232
set_property PACKAGE_PIN L6                  [get_ports "gtf_ch_gtftxn_1[1]"]            ;# Bank 232 - MGTFTXN1_232
set_property PACKAGE_PIN L7                  [get_ports "gtf_ch_gtftxp_1[1]"]            ;# Bank 232 - MGTFTXP1_232
set_property PACKAGE_PIN K8                  [get_ports "gtf_ch_gtftxn_1[2]"]            ;# Bank 232 - MGTFTXN2_232
set_property PACKAGE_PIN K9                  [get_ports "gtf_ch_gtftxp_1[2]"]            ;# Bank 232 - MGTFTXP2_232
set_property PACKAGE_PIN J6                  [get_ports "gtf_ch_gtftxn_1[3]"]            ;# Bank 232 - MGTFTXN3_232
set_property PACKAGE_PIN J7                  [get_ports "gtf_ch_gtftxp_1[3]"]            ;# Bank 232 - MGTFTXP3_232




#
# LOC constraints for input SYNCE_CLK components...
#    (Vivado tends to place them in unroutable locations if this is not done)


# SYNCE_CLK17_LVDS
set pblock_bank_233 [create_pblock pblock_bank_233]
resize_pblock $pblock_bank_233 -add { CLOCKREGION_X5Y9:CLOCKREGION_X5Y9 }
add_cells_to_pblock $pblock_bank_233 [get_cells -quiet [list system_gtf_clk_buffer/genblk1[5].BUFG_GT_INST      \
                                                             system_gtf_clk_buffer/genblk1[5].IBUFDS_GTE4_INST] ]
set_property LOC GTF_COMMON_X1Y9 [get_cells system_gtf_clk_buffer/genblk1[5].IBUFDS_GTE4_INST]


# SYNCE_CLK16_LVDS
set pblock_bank_232 [create_pblock pblock_bank_232] 
resize_pblock $pblock_bank_232 -add { CLOCKREGION_X5Y8:CLOCKREGION_X5Y8 }
add_cells_to_pblock $pblock_bank_232 [get_cells gtf_top_1/gtfwizard_raw_example_top/IBUFDS_GTE4_INST]
set_property LOC GTF_COMMON_X1Y8   [get_cells gtf_top_1/gtfwizard_raw_example_top/example_gtf_common_inst/gtf_common_inst]
set_property LOC GTF_CHANNEL_X1Y32 [get_cells gtf_top_1/gtfwizard_raw_example_top/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst]
set_property LOC GTF_CHANNEL_X1Y33 [get_cells gtf_top_1/gtfwizard_raw_example_top/gen_blk_multi_ch[1].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst]
set_property LOC GTF_CHANNEL_X1Y34 [get_cells gtf_top_1/gtfwizard_raw_example_top/gen_blk_multi_ch[2].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst]
set_property LOC GTF_CHANNEL_X1Y35 [get_cells gtf_top_1/gtfwizard_raw_example_top/gen_blk_multi_ch[3].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst]


# SYNCE_CLK15_LVDS
set pblock_bank_231 [create_pblock pblock_bank_231] 
resize_pblock $pblock_bank_231 -add { CLOCKREGION_X5Y7:CLOCKREGION_X5Y7 }
add_cells_to_pblock $pblock_bank_231 [get_cells -quiet [list system_gtf_clk_buffer/genblk1[4].BUFG_GT_INST      \
                                                             system_gtf_clk_buffer/genblk1[4].IBUFDS_GTE4_INST] ]
set_property LOC GTF_COMMON_X1Y7 [get_cells system_gtf_clk_buffer/genblk1[4].IBUFDS_GTE4_INST]


# SYNCE_CLK14_LVDS
set pblock_bank_230 [create_pblock pblock_bank_230] 
resize_pblock $pblock_bank_230 -add { CLOCKREGION_X5Y6:CLOCKREGION_X5Y6 }
add_cells_to_pblock $pblock_bank_230 [get_cells -quiet [list system_gtf_clk_buffer/genblk1[3].BUFG_GT_INST      \
                                                             system_gtf_clk_buffer/genblk1[3].IBUFDS_GTE4_INST] ]
set_property LOC GTF_COMMON_X1Y6 [get_cells system_gtf_clk_buffer/genblk1[3].IBUFDS_GTE4_INST]


# SYNCE_CLK13_LVDS
set pblock_bank_229 [create_pblock pblock_bank_229] 
resize_pblock $pblock_bank_229 -add { CLOCKREGION_X5Y5:CLOCKREGION_X5Y5 }
add_cells_to_pblock $pblock_bank_229 [get_cells -quiet [list system_gtf_clk_buffer/genblk1[2].BUFG_GT_INST      \
                                                             system_gtf_clk_buffer/genblk1[2].IBUFDS_GTE4_INST] ]
set_property LOC GTF_COMMON_X1Y5 [get_cells system_gtf_clk_buffer/genblk1[2].IBUFDS_GTE4_INST]


# SYNCE_CLK12_LVDS
set pblock_bank_228 [create_pblock pblock_bank_228] 
resize_pblock $pblock_bank_228 -add { CLOCKREGION_X5Y4:CLOCKREGION_X5Y4 }
add_cells_to_pblock $pblock_bank_228 [get_cells -quiet [list system_gtf_clk_buffer/genblk1[1].BUFG_GT_INST      \
                                                             system_gtf_clk_buffer/genblk1[1].IBUFDS_GTE4_INST] ]
set_property LOC GTF_COMMON_X1Y4 [get_cells system_gtf_clk_buffer/genblk1[1].IBUFDS_GTE4_INST]


# SYNCE_CLK11_LVDS
set pblock_bank_227 [create_pblock pblock_bank_227] 
resize_pblock $pblock_bank_227 -add { CLOCKREGION_X5Y3:CLOCKREGION_X5Y3 \
                                      RAMB36_X14Y36:RAMB36_X15Y47       \
                                      RAMB18_X14Y72:RAMB18_X15Y95       \
                                      DSP48E2_X5Y72:DSP48E2_X5Y95       \
                                      SLICE_X123Y180:SLICE_X141Y239     }
#add_cells_to_pblock $pblock_bank_227 [get_cells -quiet gtf_top_0/u_gtfwizard_0_example_gtfmac_top/gtfmac_hwchk_core_gen[3].i_gtfmac_hwchk_core]
#add_cells_to_pblock $pblock_bank_227 [get_cells -quiet gtf_top_0/u_gtfwizard_0_example_gtfmac_top/gtfmac_hwchk_core_gen[2].i_gtfmac_hwchk_core]
add_cells_to_pblock $pblock_bank_227 [get_cells gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/IBUFDS_GTE4_INST]
set_property LOC GTF_COMMON_X1Y3   [get_cells gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/example_gtf_common_inst/gtf_common_inst]
set_property LOC GTF_CHANNEL_X1Y12 [get_cells gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst]
set_property LOC GTF_CHANNEL_X1Y13 [get_cells gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[1].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst]
set_property LOC GTF_CHANNEL_X1Y14 [get_cells gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[2].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst]
set_property LOC GTF_CHANNEL_X1Y15 [get_cells gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[3].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst]


# SYNCE_CLK10_LVDS
set pblock_bank_226 [create_pblock pblock_bank_226] 
resize_pblock $pblock_bank_226 -add { CLOCKREGION_X5Y2:CLOCKREGION_X5Y2 \
                                      RAMB36_X14Y24:RAMB36_X15Y35       \
                                      RAMB18_X14Y48:RAMB18_X15Y71       \
                                      DSP48E2_X5Y48:DSP48E2_X5Y71       \
                                      SLICE_X123Y120:SLICE_X141Y179     }
add_cells_to_pblock $pblock_bank_226 [get_cells -quiet [list system_gtf_clk_buffer/genblk1[0].BUFG_GT_INST      \
                                                             system_gtf_clk_buffer/genblk1[0].IBUFDS_GTE4_INST] ]
set_property LOC GTF_COMMON_X1Y2 [get_cells system_gtf_clk_buffer/genblk1[0].IBUFDS_GTE4_INST]


#################################################################################
#
#  Inter Clock False Path Constraints....
#
#################################################################################

set_false_path -to [get_cells -hierarchical -filter  {NAME =~ *meta_reg[0]}]

create_generated_clock -name GTF_0_RXOUTCLK_0 \
                       -source        [get_pins gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/IBUFDS_GTE4_INST/O] \
                       -multiply_by 4 [get_pins gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK]

create_generated_clock -name GTF_0_TXOUTCLK_0 \
                       -source        [get_pins gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/IBUFDS_GTE4_INST/O] \
                       -multiply_by 4 [get_pins gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK]

create_generated_clock -name GTF_0_RXOUTCLK_1 \
                       -source        [get_pins gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/IBUFDS_GTE4_INST/O] \
                       -multiply_by 4 [get_pins gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[1].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK]

create_generated_clock -name GTF_0_TXOUTCLK_1 \
                       -source        [get_pins gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/IBUFDS_GTE4_INST/O] \
                       -multiply_by 4 [get_pins gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[1].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK]

create_generated_clock -name GTF_0_RXOUTCLK_2 \
                       -source        [get_pins gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/IBUFDS_GTE4_INST/O] \
                       -multiply_by 4 [get_pins gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[2].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK]

create_generated_clock -name GTF_0_TXOUTCLK_2 \
                       -source        [get_pins gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/IBUFDS_GTE4_INST/O] \
                       -multiply_by 4 [get_pins gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[2].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK]

create_generated_clock -name GTF_0_RXOUTCLK_3 \
                       -source        [get_pins gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/IBUFDS_GTE4_INST/O] \
                       -multiply_by 4 [get_pins gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[3].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK]

create_generated_clock -name GTF_0_TXOUTCLK_3 \
                       -source        [get_pins gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/IBUFDS_GTE4_INST/O] \
                       -multiply_by 4 [get_pins gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[3].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK]


set_false_path  -from [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] \
                -to   [list [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] \
                            [get_clocks GTF_0_RXOUTCLK_0] \
                            [get_clocks GTF_0_RXOUTCLK_1] \
                            [get_clocks GTF_0_RXOUTCLK_2] \
                            [get_clocks GTF_0_RXOUTCLK_3] \
                            [get_clocks GTF_0_TXOUTCLK_0] \
                            [get_clocks GTF_0_TXOUTCLK_1] \
                            [get_clocks GTF_0_TXOUTCLK_2] \
                            [get_clocks GTF_0_TXOUTCLK_3] ]

set_false_path  -from [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] \
                -to   [list [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] \
                            [get_clocks GTF_0_RXOUTCLK_0] \
                            [get_clocks GTF_0_RXOUTCLK_1] \
                            [get_clocks GTF_0_RXOUTCLK_2] \
                            [get_clocks GTF_0_RXOUTCLK_3] \
                            [get_clocks GTF_0_TXOUTCLK_0] \
                            [get_clocks GTF_0_TXOUTCLK_1] \
                            [get_clocks GTF_0_TXOUTCLK_2] \
                            [get_clocks GTF_0_TXOUTCLK_3] ]
                
set_false_path  -from [get_clocks GTF_0_TXOUTCLK_0] \
                -to   [list [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] \
                            [get_clocks GTF_0_TXOUTCLK_1] \
                            [get_clocks GTF_0_TXOUTCLK_2] \
                            [get_clocks GTF_0_TXOUTCLK_3] \
                            [get_clocks GTF_0_RXOUTCLK_0] \
                            [get_clocks GTF_0_RXOUTCLK_1] \
                            [get_clocks GTF_0_RXOUTCLK_2] \
                            [get_clocks GTF_0_RXOUTCLK_3] ]

set_false_path  -from [get_clocks GTF_0_TXOUTCLK_1] \
                -to   [list [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] \
                            [get_clocks GTF_0_TXOUTCLK_0] \
                            [get_clocks GTF_0_TXOUTCLK_2] \
                            [get_clocks GTF_0_TXOUTCLK_3] \
                            [get_clocks GTF_0_RXOUTCLK_0] \
                            [get_clocks GTF_0_RXOUTCLK_1] \
                            [get_clocks GTF_0_RXOUTCLK_2] \
                            [get_clocks GTF_0_RXOUTCLK_3] ]

set_false_path  -from [get_clocks GTF_0_TXOUTCLK_2] \
                -to   [list [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] \
                            [get_clocks GTF_0_TXOUTCLK_0] \
                            [get_clocks GTF_0_TXOUTCLK_1] \
                            [get_clocks GTF_0_TXOUTCLK_3] \
                            [get_clocks GTF_0_RXOUTCLK_0] \
                            [get_clocks GTF_0_RXOUTCLK_1] \
                            [get_clocks GTF_0_RXOUTCLK_2] \
                            [get_clocks GTF_0_RXOUTCLK_3] ]

set_false_path  -from [get_clocks GTF_0_TXOUTCLK_3] \
                -to   [list [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] \
                            [get_clocks GTF_0_TXOUTCLK_0] \
                            [get_clocks GTF_0_TXOUTCLK_1] \
                            [get_clocks GTF_0_TXOUTCLK_2] \
                            [get_clocks GTF_0_RXOUTCLK_0] \
                            [get_clocks GTF_0_RXOUTCLK_1] \
                            [get_clocks GTF_0_RXOUTCLK_2] \
                            [get_clocks GTF_0_RXOUTCLK_3] ]

set_false_path  -from [get_clocks GTF_0_RXOUTCLK_0] \
                -to   [list [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] \
                            [get_clocks GTF_0_TXOUTCLK_0] \
                            [get_clocks GTF_0_TXOUTCLK_1] \
                            [get_clocks GTF_0_TXOUTCLK_2] \
                            [get_clocks GTF_0_TXOUTCLK_3] \
                            [get_clocks GTF_0_RXOUTCLK_1] \
                            [get_clocks GTF_0_RXOUTCLK_2] \
                            [get_clocks GTF_0_RXOUTCLK_3] ]

set_false_path  -from [get_clocks GTF_0_RXOUTCLK_1] \
                -to   [list [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] \
                            [get_clocks GTF_0_TXOUTCLK_0] \
                            [get_clocks GTF_0_TXOUTCLK_1] \
                            [get_clocks GTF_0_TXOUTCLK_2] \
                            [get_clocks GTF_0_TXOUTCLK_3] \
                            [get_clocks GTF_0_RXOUTCLK_0] \
                            [get_clocks GTF_0_RXOUTCLK_2] \
                            [get_clocks GTF_0_RXOUTCLK_3] ]

set_false_path  -from [get_clocks GTF_0_RXOUTCLK_2] \
                -to   [list [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] \
                            [get_clocks GTF_0_TXOUTCLK_0] \
                            [get_clocks GTF_0_TXOUTCLK_1] \
                            [get_clocks GTF_0_TXOUTCLK_2] \
                            [get_clocks GTF_0_TXOUTCLK_3] \
                            [get_clocks GTF_0_RXOUTCLK_0] \
                            [get_clocks GTF_0_RXOUTCLK_1] \
                            [get_clocks GTF_0_RXOUTCLK_3] ]

set_false_path  -from [get_clocks GTF_0_RXOUTCLK_3] \
                -to   [list [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] \
                            [get_clocks GTF_0_TXOUTCLK_0] \
                            [get_clocks GTF_0_TXOUTCLK_1] \
                            [get_clocks GTF_0_TXOUTCLK_2] \
                            [get_clocks GTF_0_TXOUTCLK_3] \
                            [get_clocks GTF_0_RXOUTCLK_0] \
                            [get_clocks GTF_0_RXOUTCLK_1] \
                            [get_clocks GTF_0_RXOUTCLK_2] ]


#################################################################################
#
#  Inter Clock False Path Constraints....
#
#################################################################################

create_generated_clock -name GTF_1_TXOUTCLK_0 \
                       [get_pins gtf_top_1/gtfwizard_raw_example_top/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK]

create_generated_clock -name GTF_1_TXOUTCLK_1 \
                       [get_pins gtf_top_1/gtfwizard_raw_example_top/gen_blk_multi_ch[1].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK]

create_generated_clock -name GTF_1_TXOUTCLK_2 \
                       [get_pins gtf_top_1/gtfwizard_raw_example_top/gen_blk_multi_ch[2].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK]

create_generated_clock -name GTF_1_TXOUTCLK_3 \
                       [get_pins gtf_top_1/gtfwizard_raw_example_top/gen_blk_multi_ch[3].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK]

create_generated_clock -name GTF_1_RXOUTCLK_0 \
                       [get_pins gtf_top_1/gtfwizard_raw_example_top/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK]

create_generated_clock -name GTF_1_RXOUTCLK_1 \
                       [get_pins gtf_top_1/gtfwizard_raw_example_top/gen_blk_multi_ch[1].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK]

create_generated_clock -name GTF_1_RXOUTCLK_2 \
                       [get_pins gtf_top_1/gtfwizard_raw_example_top/gen_blk_multi_ch[2].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK]

create_generated_clock -name GTF_1_RXOUTCLK_3 \
                       [get_pins gtf_top_1/gtfwizard_raw_example_top/gen_blk_multi_ch[3].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK]

set_false_path  -from [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] \
                -to   [list [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] \
                            [get_clocks GTF_1_TXOUTCLK_0] \
                            [get_clocks GTF_1_TXOUTCLK_1] \
                            [get_clocks GTF_1_TXOUTCLK_2] \
                            [get_clocks GTF_1_TXOUTCLK_3] \
                            [get_clocks GTF_1_RXOUTCLK_0] \
                            [get_clocks GTF_1_RXOUTCLK_1] \
                            [get_clocks GTF_1_RXOUTCLK_2] \
                            [get_clocks GTF_1_RXOUTCLK_3] ]

set_false_path  -from [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] \
                -to   [list [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] \
                            [get_clocks GTF_1_TXOUTCLK_0] \
                            [get_clocks GTF_1_TXOUTCLK_1] \
                            [get_clocks GTF_1_TXOUTCLK_2] \
                            [get_clocks GTF_1_TXOUTCLK_3] \
                            [get_clocks GTF_1_RXOUTCLK_0] \
                            [get_clocks GTF_1_RXOUTCLK_1] \
                            [get_clocks GTF_1_RXOUTCLK_2] \
                            [get_clocks GTF_1_RXOUTCLK_3] ]

set_false_path  -from [get_clocks GTF_1_TXOUTCLK_0] \
                -to   [list [get_clocks GTF_1_TXOUTCLK_1] \
                            [get_clocks GTF_1_TXOUTCLK_2] \
                            [get_clocks GTF_1_TXOUTCLK_3] \
                            [get_clocks GTF_1_RXOUTCLK_0] \
                            [get_clocks GTF_1_RXOUTCLK_1] \
                            [get_clocks GTF_1_RXOUTCLK_2] \
                            [get_clocks GTF_1_RXOUTCLK_3] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] ]

set_false_path  -from [get_clocks GTF_1_TXOUTCLK_1] \
                -to   [list [get_clocks GTF_1_TXOUTCLK_0] \
                            [get_clocks GTF_1_TXOUTCLK_2] \
                            [get_clocks GTF_1_TXOUTCLK_3] \
                            [get_clocks GTF_1_RXOUTCLK_0] \
                            [get_clocks GTF_1_RXOUTCLK_1] \
                            [get_clocks GTF_1_RXOUTCLK_2] \
                            [get_clocks GTF_1_RXOUTCLK_3] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] ]

set_false_path  -from [get_clocks GTF_1_TXOUTCLK_2] \
                -to   [list [get_clocks GTF_1_TXOUTCLK_0] \
                            [get_clocks GTF_1_TXOUTCLK_1] \
                            [get_clocks GTF_1_TXOUTCLK_3] \
                            [get_clocks GTF_1_RXOUTCLK_0] \
                            [get_clocks GTF_1_RXOUTCLK_1] \
                            [get_clocks GTF_1_RXOUTCLK_2] \
                            [get_clocks GTF_1_RXOUTCLK_3] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] ]

set_false_path  -from [get_clocks GTF_1_TXOUTCLK_3] \
                -to   [list [get_clocks GTF_1_TXOUTCLK_0] \
                            [get_clocks GTF_1_TXOUTCLK_1] \
                            [get_clocks GTF_1_TXOUTCLK_2] \
                            [get_clocks GTF_1_RXOUTCLK_0] \
                            [get_clocks GTF_1_RXOUTCLK_1] \
                            [get_clocks GTF_1_RXOUTCLK_2] \
                            [get_clocks GTF_1_RXOUTCLK_3] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] ]

set_false_path  -from [get_clocks GTF_1_RXOUTCLK_0] \
                -to   [list [get_clocks GTF_1_TXOUTCLK_0] \
                            [get_clocks GTF_1_TXOUTCLK_1] \
                            [get_clocks GTF_1_TXOUTCLK_2] \
                            [get_clocks GTF_1_TXOUTCLK_3] \
                            [get_clocks GTF_1_RXOUTCLK_1] \
                            [get_clocks GTF_1_RXOUTCLK_2] \
                            [get_clocks GTF_1_RXOUTCLK_3] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] ]

set_false_path  -from [get_clocks GTF_1_RXOUTCLK_1] \
                -to   [list [get_clocks GTF_1_TXOUTCLK_0] \
                            [get_clocks GTF_1_TXOUTCLK_1] \
                            [get_clocks GTF_1_TXOUTCLK_2] \
                            [get_clocks GTF_1_TXOUTCLK_3] \
                            [get_clocks GTF_1_RXOUTCLK_0] \
                            [get_clocks GTF_1_RXOUTCLK_2] \
                            [get_clocks GTF_1_RXOUTCLK_3] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] ]

set_false_path  -from [get_clocks GTF_1_RXOUTCLK_2] \
                -to   [list [get_clocks GTF_1_TXOUTCLK_0] \
                            [get_clocks GTF_1_TXOUTCLK_1] \
                            [get_clocks GTF_1_TXOUTCLK_2] \
                            [get_clocks GTF_1_TXOUTCLK_3] \
                            [get_clocks GTF_1_RXOUTCLK_0] \
                            [get_clocks GTF_1_RXOUTCLK_1] \
                            [get_clocks GTF_1_RXOUTCLK_3] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] ]

set_false_path  -from [get_clocks GTF_1_RXOUTCLK_3] \
                -to   [list [get_clocks GTF_1_TXOUTCLK_0] \
                            [get_clocks GTF_1_TXOUTCLK_1] \
                            [get_clocks GTF_1_TXOUTCLK_2] \
                            [get_clocks GTF_1_TXOUTCLK_3] \
                            [get_clocks GTF_1_RXOUTCLK_0] \
                            [get_clocks GTF_1_RXOUTCLK_1] \
                            [get_clocks GTF_1_RXOUTCLK_2] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] \
                            [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] ]


#################################################################################
#
#  Timing Constraints...
#
#################################################################################
set_false_path -from [get_pins -hierarchical -filter { NAME =~  "gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/delay_powergood_inst/gen_powergood_delay.intclk_rrst_n_r_reg[*]/C" } ] \
               -to   [get_pins -hierarchical -filter { NAME =~  "gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/delay_powergood_inst/gen_powergood_delay.wait_cnt_reg[*]/R" } ]
 
set_false_path -from [get_pins -hierarchical -filter { NAME =~  "gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/delay_powergood_inst/gen_powergood_delay.intclk_rrst_n_r_reg[*]/C" } ] \
               -to   [get_pins -hierarchical -filter { NAME =~  "gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/delay_powergood_inst/gen_powergood_delay.wait_cnt_reg[*]/D"}]

set_false_path -from [get_pins -hierarchical -filter { NAME =~  "gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/delay_powergood_inst/gen_powergood_delay.intclk_rrst_n_r_reg[*]/C" } ] \
               -to   [get_pins -hierarchical -filter { NAME =~  "gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/delay_powergood_inst/gen_powergood_delay.wait_cnt_reg[*]/CE"}]

set_false_path -from [get_pins -hierarchical -filter { NAME =~  "gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/delay_powergood_inst/gen_powergood_delay.int_pwr_on_fsm_reg/C" } ] \
               -to   [get_pins -hierarchical -filter { NAME =~  "gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/delay_powergood_inst/gen_powergood_delay.intclk_rrst_n_r_reg[*]/CE" } ]

set_false_path -from [get_pins -hierarchical -filter { NAME =~  "gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/delay_powergood_inst/gen_powergood_delay.int_pwr_on_fsm_reg/C" } ] \
               -to   [get_pins -hierarchical -filter { NAME =~  "gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/delay_powergood_inst/gen_powergood_delay.wait_cnt_reg[*]/CE" } ]

set_false_path -from [get_pins -hierarchical -filter { NAME =~  "gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/delay_powergood_inst/gen_powergood_delay.wait_cnt_reg[*]/C" } ] \
               -to   [get_pins -hierarchical -filter { NAME =~  "gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/delay_powergood_inst/gen_powergood_delay.wait_cnt_reg[*]/D" } ]
               
set_false_path -from [get_pins -hierarchical -filter { NAME =~  "gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/delay_powergood_inst/gen_powergood_delay.wait_cnt_reg[*]/C" } ] \
               -to   [get_pins -hierarchical -filter { NAME =~  "gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/delay_powergood_inst/gen_powergood_delay.int_pwr_on_fsm_reg/D" } ]

set_false_path -from [get_pins -hierarchical -filter { NAME =~  "gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/delay_powergood_inst/gen_powergood_delay.int_pwr_on_fsm_reg/C" } ] \
               -to   [get_pins -hierarchical -filter { NAME =~  "gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/D" } ]


#################################################################################
#
#  False Path Timing Constraints for Freq. Monitors...
#
#################################################################################

set_false_path  -from [get_clocks -of_objects [get_pins clk_reset/clk_wiz_100mhz/inst/mmcme4_adv_inst/CLKOUT0]] \
                -to   [list [get_clocks CLK_SYNCE_CLK10_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK11_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK12_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK13_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK14_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK15_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK16_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK17_LVDS_P] \
                            [get_clocks GTF_0_RXOUTCLK_0] \
                            [get_clocks GTF_0_RXOUTCLK_1] \
                            [get_clocks GTF_0_RXOUTCLK_2] \
                            [get_clocks GTF_0_RXOUTCLK_3] \
                            [get_clocks GTF_0_TXOUTCLK_0] \
                            [get_clocks GTF_0_TXOUTCLK_1] \
                            [get_clocks GTF_0_TXOUTCLK_2] \
                            [get_clocks GTF_0_TXOUTCLK_3] \
                            [get_clocks GTF_1_RXOUTCLK_0] \
                            [get_clocks GTF_1_RXOUTCLK_1] \
                            [get_clocks GTF_1_RXOUTCLK_2] \
                            [get_clocks GTF_1_RXOUTCLK_3] \
                            [get_clocks GTF_1_TXOUTCLK_0] \
                            [get_clocks GTF_1_TXOUTCLK_1] \
                            [get_clocks GTF_1_TXOUTCLK_2] \
                            [get_clocks GTF_1_TXOUTCLK_3] \
                            [get_clocks -of_objects [get_pins {gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[0].u_bufg_gt_gtf_recov_clk/O}]] ]

set_false_path  -from [get_clocks -of_objects [get_pins clk_reset/clk_wiz_100mhz/inst/mmcme4_adv_inst/CLKOUT1]] \
                -to   [list [get_clocks CLK_SYNCE_CLK10_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK11_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK12_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK13_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK14_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK15_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK16_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK17_LVDS_P] \
                            [get_clocks GTF_0_RXOUTCLK_0] \
                            [get_clocks GTF_0_RXOUTCLK_1] \
                            [get_clocks GTF_0_RXOUTCLK_2] \
                            [get_clocks GTF_0_RXOUTCLK_3] \
                            [get_clocks GTF_0_TXOUTCLK_0] \
                            [get_clocks GTF_0_TXOUTCLK_1] \
                            [get_clocks GTF_0_TXOUTCLK_2] \
                            [get_clocks GTF_0_TXOUTCLK_3] \
                            [get_clocks GTF_1_RXOUTCLK_0] \
                            [get_clocks GTF_1_RXOUTCLK_1] \
                            [get_clocks GTF_1_RXOUTCLK_2] \
                            [get_clocks GTF_1_RXOUTCLK_3] \
                            [get_clocks GTF_1_TXOUTCLK_0] \
                            [get_clocks GTF_1_TXOUTCLK_1] \
                            [get_clocks GTF_1_TXOUTCLK_2] \
                            [get_clocks GTF_1_TXOUTCLK_3] \
                            [get_clocks -of_objects [get_pins {gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[0].u_bufg_gt_gtf_recov_clk/O}]] ]

set_false_path  -from [list [get_clocks CLK_SYNCE_CLK10_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK11_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK12_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK13_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK14_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK15_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK16_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK17_LVDS_P] \
                            [get_clocks GTF_0_RXOUTCLK_0] \
                            [get_clocks GTF_0_RXOUTCLK_1] \
                            [get_clocks GTF_0_RXOUTCLK_2] \
                            [get_clocks GTF_0_RXOUTCLK_3] \
                            [get_clocks GTF_0_TXOUTCLK_0] \
                            [get_clocks GTF_0_TXOUTCLK_1] \
                            [get_clocks GTF_0_TXOUTCLK_2] \
                            [get_clocks GTF_0_TXOUTCLK_3] \
                            [get_clocks GTF_1_RXOUTCLK_0] \
                            [get_clocks GTF_1_RXOUTCLK_1] \
                            [get_clocks GTF_1_RXOUTCLK_2] \
                            [get_clocks GTF_1_RXOUTCLK_3] \
                            [get_clocks GTF_1_TXOUTCLK_0] \
                            [get_clocks GTF_1_TXOUTCLK_1] \
                            [get_clocks GTF_1_TXOUTCLK_2] \
                            [get_clocks GTF_1_TXOUTCLK_3] \
                            [get_clocks -of_objects [get_pins {gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[0].u_bufg_gt_gtf_recov_clk/O}]] ] \
                -to   [get_clocks -of_objects [get_pins clk_reset/clk_wiz_100mhz/inst/mmcme4_adv_inst/CLKOUT0]] 
                
set_false_path  -from [list [get_clocks CLK_SYNCE_CLK10_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK11_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK12_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK13_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK14_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK15_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK16_LVDS_P] \
                            [get_clocks CLK_SYNCE_CLK17_LVDS_P] \
                            [get_clocks GTF_0_RXOUTCLK_0] \
                            [get_clocks GTF_0_RXOUTCLK_1] \
                            [get_clocks GTF_0_RXOUTCLK_2] \
                            [get_clocks GTF_0_RXOUTCLK_3] \
                            [get_clocks GTF_0_TXOUTCLK_0] \
                            [get_clocks GTF_0_TXOUTCLK_1] \
                            [get_clocks GTF_0_TXOUTCLK_2] \
                            [get_clocks GTF_0_TXOUTCLK_3] \
                            [get_clocks GTF_1_RXOUTCLK_0] \
                            [get_clocks GTF_1_RXOUTCLK_1] \
                            [get_clocks GTF_1_RXOUTCLK_2] \
                            [get_clocks GTF_1_RXOUTCLK_3] \
                            [get_clocks GTF_1_TXOUTCLK_0] \
                            [get_clocks GTF_1_TXOUTCLK_1] \
                            [get_clocks GTF_1_TXOUTCLK_2] \
                            [get_clocks GTF_1_TXOUTCLK_3] \
                            [get_clocks -of_objects [get_pins {gtf_top_0/u_gtfwizard_0_example_gtfmac_top/i_gtfmac/gen_blk_multi_ch[0].u_bufg_gt_gtf_recov_clk/O}]] ] \
                -to   [get_clocks -of_objects [get_pins clk_reset/clk_wiz_100mhz/inst/mmcme4_adv_inst/CLKOUT1]]
                
                
set_false_path -from [get_pins {gtf_top_1/gtfwizard_raw_example_top/gen_blk_multi_ch[0].reset_all_in_sync/arststages_ff_reg[4]/C}]
             