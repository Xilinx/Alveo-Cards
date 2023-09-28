############################################################################
#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#
############################################################################
#
#
#   UL3524 - Master XDC
#
#
############################################################################
#	REVISION HISTORY
############################################################################
#
#   Revision: 1.01				(08/26/2022)
#		* Renamed file
#	Revision: 1.02				(08/18/2023)
#		* Removed reference to UL3x24 in comments
#		* Updated comments for clarity
#		* Updated copyright and license notice
#
#
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
# Power PMBUS_SCL/SCA for +0V9_VCCINT   - Accessible from BMC or SC only             
#     Renesas ISL68224IRAZ                           0xC0     0x60
#                                                    
# System I2C_MAIN_SCL/SDA   - Accessible from SC only                         
#     EEPROM (STM M24C64)                            0xA4     0x52
#                                                    0xB4     0x5A
#     Temp Diode (TI TMP411CDGKT)                    0x9C     0x4E
#     Temp Sense Left (NXP LM75BTP)                  0x90     0x48
#     Temp Sense Right (NXP LM75BTP)                 0x92     0x49
#                                                    
# Clocks CLKGEN_SCL/SDA    - Accessible from FPGA only                          
#     Clock Generator (Renesas RC21008AQ)            0x12     0x09
#     Jitter Cleaner 1 (Renesas RC38612A002GN2)      0xB0     0x58
#     Jitter Cleaner 2 (Renesas RC38612A002GN2)      0xB2     0x59
#     I/O Expander (TI TCA6408APWR) for DDR 2V5VPP   0x42     0x21
#                                                    
# QSFP I2C Busses  - Accessible from FPGA only                                    
#     MUX0 (PCA9545A, A1=0, A0=0)                    0xE0     0x70
#     MUX1 (PCA9545A, A1=1, A0=0)                    0xE4     0x72
#     I/O Expander (TI TCA6408APWR)                  0x42     0x21
#         For Enable Control and Power Good Status        
#                                                    
# QSFP Power Control   - Accessible from FPGA only                              
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
                                                                                         
#                                                                                        
#  300 Mhz Reference clock for QDRII+ 1, Bank 71 (1.5V)                                  
#                                                                                        
set_property PACKAGE_PIN G27                 [get_ports "CLK11_LVDS_300_N"]              ;# Bank  71 VCCO - +1V5_SYS                               - IO_L12N_T1U_N11_GC_71
set_property IOSTANDARD  LVDS                [get_ports "CLK11_LVDS_300_N"]              ;# Bank  71 VCCO - +1V5_SYS                               - IO_L12N_T1U_N11_GC_71
set_property PACKAGE_PIN G26                 [get_ports "CLK11_LVDS_300_P"]              ;# Bank  71 VCCO - +1V5_SYS                               - IO_L12P_T1U_N10_GC_71
set_property IOSTANDARD  LVDS                [get_ports "CLK11_LVDS_300_P"]              ;# Bank  71 VCCO - +1V5_SYS                               - IO_L12P_T1U_N10_GC_71
                                                                                         
#                                                                                        
#  300 Mhz Reference clock for DDR1, Bank 66 (1.2V)                                      
#                                                                                        
set_property PACKAGE_PIN AY22                [get_ports "CLK12_LVDS_300_N"]              ;# Bank  66 VCCO - 1V2_VCCO                               - IO_L13N_T2L_N1_GC_QBC_66
set_property IOSTANDARD  LVDS                [get_ports "CLK12_LVDS_300_N"]              ;# Bank  66 VCCO - 1V2_VCCO                               - IO_L13N_T2L_N1_GC_QBC_66
set_property PACKAGE_PIN AW23                [get_ports "CLK12_LVDS_300_P"]              ;# Bank  66 VCCO - 1V2_VCCO                               - IO_L13P_T2L_N0_GC_QBC_66
set_property IOSTANDARD  LVDS                [get_ports "CLK12_LVDS_300_P"]              ;# Bank  66 VCCO - 1V2_VCCO                               - IO_L13P_T2L_N0_GC_QBC_66
                                                                                         
#                                                                                        
#  300 Mhz Reference clock, Bank 65 (1.8V)                                               
#                                                                                        
set_property PACKAGE_PIN AW18                [get_ports "CLK13_LVDS_300_N"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L14N_T2L_N3_GC_A05_D21_65
set_property IOSTANDARD  LVDS                [get_ports "CLK13_LVDS_300_N"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L14N_T2L_N3_GC_A05_D21_65
set_property PACKAGE_PIN AW19                [get_ports "CLK13_LVDS_300_P"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L14P_T2L_N2_GC_A04_D20_65
set_property IOSTANDARD  LVDS                [get_ports "CLK13_LVDS_300_P"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L14P_T2L_N2_GC_A04_D20_65


#################################################################################
#
#  PCIe Interface x8, G4...
#
#################################################################################

#
#  PCIe Connections - Bank 65 (1.8V)
#    PCIE_HOST_DETECT    - Active high input indicating if the board is plugged into a host
#    PCIE_PERST_LS_65    - Active low input from PCIe Connector to Ultrascale+ Device to detect presence.
#    PEX_PWRBRKN_FPGA_65 - Active low input from PCIe Connector Signaling PCIe card to shut down card power in Server failing condition.
set_property PACKAGE_PIN AP19                [get_ports "PCIE_HOST_DETECT"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L24N_T3U_N11_DOUT_CSO_B_65
set_property IOSTANDARD  LVCMOS18            [get_ports "PCIE_HOST_DETECT"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L24N_T3U_N11_DOUT_CSO_B_65
set_property PACKAGE_PIN AT19                [get_ports "PCIE_PERST_LS_65"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_T3U_N12_PERSTN0_65
set_property IOSTANDARD  LVCMOS18            [get_ports "PCIE_PERST_LS_65"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_T3U_N12_PERSTN0_65
set_property PACKAGE_PIN AR18                [get_ports "PEX_PWRBRKN_FPGA_65"]           ;# Bank  65 VCCO - +1V8_SYS                               - IO_L21P_T3L_N4_AD8P_D06_65
set_property IOSTANDARD  LVCMOS18            [get_ports "PEX_PWRBRKN_FPGA_65"]           ;# Bank  65 VCCO - +1V8_SYS                               - IO_L21P_T3L_N4_AD8P_D06_65

#
#  LVDS Input Reference Clock for PCIe, Bank 225 (1.2V)
#    Typical GT pin constraints are embedded in the IP
#
set_property PACKAGE_PIN AV8                 [get_ports "PCIE_REFCLK_BUF_N"]             ;# Bank 225 - MGTREFCLK0N_225
set_property PACKAGE_PIN AV9                 [get_ports "PCIE_REFCLK_BUF_P"]             ;# Bank 225 - MGTREFCLK0P_225

#
#  On Board 100 Mhz Reference clock for PCIe, Bank 225 (1.2V)
#    Typical GT pin constraints are embedded in the IP
#
set_property PACKAGE_PIN AR10                [get_ports "CLK0_LVDS_100_N"]               ;# Bank 225 - MGTREFCLK1N_225
set_property PACKAGE_PIN AR11                [get_ports "CLK0_LVDS_100_P"]               ;# Bank 225 - MGTREFCLK1P_225

#
#  PCIe Data Connections - Bank 224 and Bank 225 (1.2V)
#    Typical GT pin constraints are embedded in the IP
#
set_property PACKAGE_PIN AT3                 [get_ports "PEX_RX_N[0]"]                   ;# Bank 225 - MGTYRXN3_225
set_property PACKAGE_PIN AT4                 [get_ports "PEX_RX_P[0]"]                   ;# Bank 225 - MGTYRXP3_225
set_property PACKAGE_PIN AU1                 [get_ports "PEX_RX_N[1]"]                   ;# Bank 225 - MGTYRXN2_225
set_property PACKAGE_PIN AU2                 [get_ports "PEX_RX_P[1]"]                   ;# Bank 225 - MGTYRXP2_225
set_property PACKAGE_PIN AV3                 [get_ports "PEX_RX_N[2]"]                   ;# Bank 225 - MGTYRXN1_225
set_property PACKAGE_PIN AV4                 [get_ports "PEX_RX_P[2]"]                   ;# Bank 225 - MGTYRXP1_225
set_property PACKAGE_PIN AW1                 [get_ports "PEX_RX_N[3]"]                   ;# Bank 225 - MGTYRXN0_225
set_property PACKAGE_PIN AW2                 [get_ports "PEX_RX_P[3]"]                   ;# Bank 225 - MGTYRXP0_225
set_property PACKAGE_PIN AY3                 [get_ports "PEX_RX_N[4]"]                   ;# Bank 224 - MGTYRXN3_224
set_property PACKAGE_PIN AY4                 [get_ports "PEX_RX_P[4]"]                   ;# Bank 224 - MGTYRXP3_224
set_property PACKAGE_PIN BA1                 [get_ports "PEX_RX_N[5]"]                   ;# Bank 224 - MGTYRXN2_224
set_property PACKAGE_PIN BA2                 [get_ports "PEX_RX_P[5]"]                   ;# Bank 224 - MGTYRXP2_224
set_property PACKAGE_PIN BB3                 [get_ports "PEX_RX_N[6]"]                   ;# Bank 224 - MGTYRXN1_224
set_property PACKAGE_PIN BB4                 [get_ports "PEX_RX_P[6]"]                   ;# Bank 224 - MGTYRXP1_224
set_property PACKAGE_PIN BC1                 [get_ports "PEX_RX_N[7]"]                   ;# Bank 224 - MGTYRXN0_224
set_property PACKAGE_PIN BC2                 [get_ports "PEX_RX_P[7]"]                   ;# Bank 224 - MGTYRXP0_224

set_property PACKAGE_PIN AW6                 [get_ports "PEX_TX_N[0]"]                   ;# Bank 225 - MGTYTXN3_225
set_property PACKAGE_PIN AW7                 [get_ports "PEX_TX_P[0]"]                   ;# Bank 225 - MGTYTXP3_225
set_property PACKAGE_PIN BA6                 [get_ports "PEX_TX_N[1]"]                   ;# Bank 225 - MGTYTXN2_225
set_property PACKAGE_PIN BA7                 [get_ports "PEX_TX_P[1]"]                   ;# Bank 225 - MGTYTXP2_225
set_property PACKAGE_PIN BC6                 [get_ports "PEX_TX_N[2]"]                   ;# Bank 225 - MGTYTXN1_225
set_property PACKAGE_PIN BC7                 [get_ports "PEX_TX_P[2]"]                   ;# Bank 225 - MGTYTXP1_225
set_property PACKAGE_PIN BD8                 [get_ports "PEX_TX_N[3]"]                   ;# Bank 225 - MGTYTXN0_225
set_property PACKAGE_PIN BD9                 [get_ports "PEX_TX_P[3]"]                   ;# Bank 225 - MGTYTXP0_225
set_property PACKAGE_PIN BD4                 [get_ports "PEX_TX_N[4]"]                   ;# Bank 224 - MGTYTXN3_224
set_property PACKAGE_PIN BD5                 [get_ports "PEX_TX_P[4]"]                   ;# Bank 224 - MGTYTXP3_224
set_property PACKAGE_PIN BE6                 [get_ports "PEX_TX_N[5]"]                   ;# Bank 224 - MGTYTXN2_224
set_property PACKAGE_PIN BE7                 [get_ports "PEX_TX_P[5]"]                   ;# Bank 224 - MGTYTXP2_224
set_property PACKAGE_PIN BF8                 [get_ports "PEX_TX_N[6]"]                   ;# Bank 224 - MGTYTXN1_224
set_property PACKAGE_PIN BF9                 [get_ports "PEX_TX_P[6]"]                   ;# Bank 224 - MGTYTXP1_224
set_property PACKAGE_PIN BF4                 [get_ports "PEX_TX_N[7]"]                   ;# Bank 224 - MGTYTXN0_224
set_property PACKAGE_PIN BF5                 [get_ports "PEX_TX_P[7]"]                   ;# Bank 224 - MGTYTXP0_224

#################################################################################
#
#  DDR Interface...
#
#################################################################################

#
#  DDR4 RESET_GATE Active High Output from Ultrascale+ Device to hold all External DDR4 interfaces in Self refresh.
#                  This Output disconnects the Memory interface reset and holds it in active and pulls the Clock Enables signal on the Memory Interfaces.
#
set_property PACKAGE_PIN AU20                [get_ports "RESET_GATE_R"]                  ;# Bank  65 VCCO - +1V8_SYS                               - IO_L22P_T3U_N6_DBC_AD0P_D04_65
set_property IOSTANDARD  LVCMOS18            [get_ports "RESET_GATE_R"]                  ;# Bank  65 VCCO - +1V8_SYS                               - IO_L22P_T3U_N6_DBC_AD0P_D04_65


#
#  DDR4 RDIMM Controller 0, 72-bit Data Interface, x4 Components, Single Rank
#     Banks 66, 67, 68 (1.2V)
#     Part Number MT40A2G8SA-062E (x8 comp, x72@2666)
#
set_property PACKAGE_PIN BB25                [get_ports "c0_ddr4_ck_c[0]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_CK0_C           - IO_L7N_T1L_N1_QBC_AD13N_66
set_property IOSTANDARD  DIFF_SSTL12_DCI     [get_ports "c0_ddr4_ck_c[0]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_CK0_C           - IO_L7N_T1L_N1_QBC_AD13N_66
set_property PACKAGE_PIN BA25                [get_ports "c0_ddr4_ck_t[0]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_CK0_T           - IO_L7P_T1L_N0_QBC_AD13P_66
set_property IOSTANDARD  DIFF_SSTL12_DCI     [get_ports "c0_ddr4_ck_t[0]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_CK0_T           - IO_L7P_T1L_N0_QBC_AD13P_66
set_property PACKAGE_PIN BC24                [get_ports "c0_ddr4_cke[0]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_CKE0            - IO_L8N_T1L_N3_AD5N_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_cke[0]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_CKE0            - IO_L8N_T1L_N3_AD5N_66
set_property PACKAGE_PIN BF25                [get_ports "c0_ddr4_cs_n[0]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_CS0_B           - IO_L1P_T0L_N0_DBC_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_cs_n[0]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_CS0_B           - IO_L1P_T0L_N0_DBC_66
set_property PACKAGE_PIN BD25                [get_ports "c0_ddr4_odt[0]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_ODT0            - IO_L5P_T0U_N8_AD14P_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_odt[0]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_ODT0            - IO_L5P_T0U_N8_AD14P_66
set_property PACKAGE_PIN BC23                [get_ports "c0_ddr4_parity"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_PARITY          - IO_L6P_T0U_N10_AD6P_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_parity"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_PARITY          - IO_L6P_T0U_N10_AD6P_66
set_property PACKAGE_PIN AT23                [get_ports "c0_ddr4_reset_n"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_RESET_B         - IO_T3U_N12_66
set_property IOSTANDARD  LVCMOS12            [get_ports "c0_ddr4_reset_n"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_RESET_B         - IO_T3U_N12_66
set_property DRIVE       8                   [get_ports "c0_ddr4_reset_n"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_RESET_B         - IO_T3U_N12_66
set_property PACKAGE_PIN BE21                [get_ports "c0_ddr4_act_n"]                 ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_ACT_B           - IO_L3N_T0L_N5_AD15N_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_act_n"]                 ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_ACT_B           - IO_L3N_T0L_N5_AD15N_66
set_property PACKAGE_PIN AU25                [get_ports "c0_ddr4_alert_n"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_ALERT_B         - IO_L16P_T2U_N6_QBC_AD3P_66
set_property IOSTANDARD  LVCMOS12            [get_ports "c0_ddr4_alert_n"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_ALERT_B         - IO_L16P_T2U_N6_QBC_AD3P_66
set_property DRIVE       8                   [get_ports "c0_ddr4_alert_n"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_ALERT_B         - IO_L16P_T2U_N6_QBC_AD3P_66
set_property PACKAGE_PIN AW21                [get_ports "c0_ddr4_ba[0]"]                 ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_BA0             - IO_L10P_T1U_N6_QBC_AD4P_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_ba[0]"]                 ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_BA0             - IO_L10P_T1U_N6_QBC_AD4P_66
set_property PACKAGE_PIN BB21                [get_ports "c0_ddr4_ba[1]"]                 ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_BA1             - IO_L9P_T1L_N4_AD12P_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_ba[1]"]                 ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_BA1             - IO_L9P_T1L_N4_AD12P_66
set_property PACKAGE_PIN AY21                [get_ports "c0_ddr4_bg[0]"]                 ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_BG0             - IO_L10N_T1U_N7_QBC_AD4N_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_bg[0]"]                 ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_BG0             - IO_L10N_T1U_N7_QBC_AD4N_66
set_property PACKAGE_PIN AY25                [get_ports "c0_ddr4_bg[1]"]                 ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_BG1             - IO_L15N_T2L_N5_AD11N_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_bg[1]"]                 ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_BG1             - IO_L15N_T2L_N5_AD11N_66
set_property PACKAGE_PIN BD23                [get_ports "c0_ddr4_adr[0]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A0              - IO_L6N_T0U_N11_AD6N_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_adr[0]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A0              - IO_L6N_T0U_N11_AD6N_66
set_property PACKAGE_PIN AV23                [get_ports "c0_ddr4_adr[1]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A1              - IO_L17P_T2U_N8_AD10P_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_adr[1]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A1              - IO_L17P_T2U_N8_AD10P_66
set_property PACKAGE_PIN BE22                [get_ports "c0_ddr4_adr[2]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A2              - IO_L4N_T0U_N7_DBC_AD7N_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_adr[2]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A2              - IO_L4N_T0U_N7_DBC_AD7N_66
set_property PACKAGE_PIN BF22                [get_ports "c0_ddr4_adr[3]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A3              - IO_L2N_T0L_N3_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_adr[3]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A3              - IO_L2N_T0L_N3_66
set_property PACKAGE_PIN BF23                [get_ports "c0_ddr4_adr[4]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A4              - IO_L2P_T0L_N2_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_adr[4]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A4              - IO_L2P_T0L_N2_66
set_property PACKAGE_PIN BE23                [get_ports "c0_ddr4_adr[5]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A5              - IO_L4P_T0U_N6_DBC_AD7P_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_adr[5]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A5              - IO_L4P_T0U_N6_DBC_AD7P_66
set_property PACKAGE_PIN BA22                [get_ports "c0_ddr4_adr[6]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A6              - IO_T1U_N12_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_adr[6]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A6              - IO_T1U_N12_66
set_property PACKAGE_PIN BA23                [get_ports "c0_ddr4_adr[7]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A7              - IO_L12N_T1U_N11_GC_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_adr[7]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A7              - IO_L12N_T1U_N11_GC_66
set_property PACKAGE_PIN BB22                [get_ports "c0_ddr4_adr[8]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A8              - IO_L11P_T1U_N8_GC_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_adr[8]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A8              - IO_L11P_T1U_N8_GC_66
set_property PACKAGE_PIN AU24                [get_ports "c0_ddr4_adr[9]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A9              - IO_L16N_T2U_N7_QBC_AD3N_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_adr[9]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A9              - IO_L16N_T2U_N7_QBC_AD3N_66
set_property PACKAGE_PIN BE25                [get_ports "c0_ddr4_adr[10]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A10             - IO_L5N_T0U_N9_AD14N_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_adr[10]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A10             - IO_L5N_T0U_N9_AD14N_66
set_property PACKAGE_PIN BA24                [get_ports "c0_ddr4_adr[11]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A11             - IO_L12P_T1U_N10_GC_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_adr[11]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A11             - IO_L12P_T1U_N10_GC_66
set_property PACKAGE_PIN BF24                [get_ports "c0_ddr4_adr[12]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A12             - IO_L1N_T0L_N1_DBC_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_adr[12]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A12             - IO_L1N_T0L_N1_DBC_66
set_property PACKAGE_PIN BD21                [get_ports "c0_ddr4_adr[13]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A13             - IO_L3P_T0L_N4_AD15P_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_adr[13]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A13             - IO_L3P_T0L_N4_AD15P_66
set_property PACKAGE_PIN BC22                [get_ports "c0_ddr4_adr[14]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_WE_B            - IO_L11N_T1U_N9_GC_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_adr[14]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_WE_B            - IO_L11N_T1U_N9_GC_66
set_property PACKAGE_PIN BB24                [get_ports "c0_ddr4_adr[15]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_CAS_B           - IO_L8P_T1L_N2_AD5P_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_adr[15]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_CAS_B           - IO_L8P_T1L_N2_AD5P_66
set_property PACKAGE_PIN BC21                [get_ports "c0_ddr4_adr[16]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_RAS_B           - IO_L9N_T1L_N5_AD12N_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_adr[16]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_RAS_B           - IO_L9N_T1L_N5_AD12N_66
set_property PACKAGE_PIN AV22                [get_ports "c0_ddr4_adr[17]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A17             - IO_L17N_T2U_N9_AD10N_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_adr[17]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A17             - IO_L17N_T2U_N9_AD10N_66
set_property PACKAGE_PIN AU26                [get_ports "c0_ddr4_dm_dbi_n[0]"]           ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B0           - IO_L19P_T3L_N0_DBC_AD9P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dm_dbi_n[0]"]           ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B0           - IO_L19P_T3L_N0_DBC_AD9P_67
set_property PACKAGE_PIN AW33                [get_ports "c0_ddr4_dm_dbi_n[1]"]           ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B1           - IO_L19P_T3L_N0_DBC_AD9P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dm_dbi_n[1]"]           ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B1           - IO_L19P_T3L_N0_DBC_AD9P_68
set_property PACKAGE_PIN BE35                [get_ports "c0_ddr4_dm_dbi_n[2]"]           ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B2           - IO_L1P_T0L_N0_DBC_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dm_dbi_n[2]"]           ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B2           - IO_L1P_T0L_N0_DBC_68
set_property PACKAGE_PIN AY28                [get_ports "c0_ddr4_dm_dbi_n[3]"]           ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B3           - IO_L13P_T2L_N0_GC_QBC_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dm_dbi_n[3]"]           ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B3           - IO_L13P_T2L_N0_GC_QBC_67
set_property PACKAGE_PIN BA35                [get_ports "c0_ddr4_dm_dbi_n[4]"]           ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B4           - IO_L13P_T2L_N0_GC_QBC_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dm_dbi_n[4]"]           ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B4           - IO_L13P_T2L_N0_GC_QBC_68
set_property PACKAGE_PIN BC29                [get_ports "c0_ddr4_dm_dbi_n[5]"]           ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B5           - IO_L7P_T1L_N0_QBC_AD13P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dm_dbi_n[5]"]           ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B5           - IO_L7P_T1L_N0_QBC_AD13P_67
set_property PACKAGE_PIN AT22                [get_ports "c0_ddr4_dm_dbi_n[6]"]           ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B6           - IO_L19P_T3L_N0_DBC_AD9P_66
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dm_dbi_n[6]"]           ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B6           - IO_L19P_T3L_N0_DBC_AD9P_66
set_property PACKAGE_PIN BE30                [get_ports "c0_ddr4_dm_dbi_n[7]"]           ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B7           - IO_L1P_T0L_N0_DBC_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dm_dbi_n[7]"]           ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B7           - IO_L1P_T0L_N0_DBC_67
set_property PACKAGE_PIN BE37                [get_ports "c0_ddr4_dm_dbi_n[8]"]           ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B8           - IO_L7P_T1L_N0_QBC_AD13P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dm_dbi_n[8]"]           ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B8           - IO_L7P_T1L_N0_QBC_AD13P_68
set_property PACKAGE_PIN AU27                [get_ports "c0_ddr4_dq[0]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ0             - IO_L20P_T3L_N2_AD1P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[0]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ0             - IO_L20P_T3L_N2_AD1P_67
set_property PACKAGE_PIN AT30                [get_ports "c0_ddr4_dq[1]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ1             - IO_L21P_T3L_N4_AD8P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[1]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ1             - IO_L21P_T3L_N4_AD8P_67
set_property PACKAGE_PIN AV27                [get_ports "c0_ddr4_dq[2]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ2             - IO_L20N_T3L_N3_AD1N_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[2]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ2             - IO_L20N_T3L_N3_AD1N_67
set_property PACKAGE_PIN AR28                [get_ports "c0_ddr4_dq[3]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ3             - IO_L23P_T3U_N8_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[3]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ3             - IO_L23P_T3U_N8_67
set_property PACKAGE_PIN AT27                [get_ports "c0_ddr4_dq[4]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ4             - IO_L24N_T3U_N11_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[4]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ4             - IO_L24N_T3U_N11_67
set_property PACKAGE_PIN AU31                [get_ports "c0_ddr4_dq[5]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ5             - IO_L21N_T3L_N5_AD8N_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[5]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ5             - IO_L21N_T3L_N5_AD8N_67
set_property PACKAGE_PIN AR27                [get_ports "c0_ddr4_dq[6]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ6             - IO_L24P_T3U_N10_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[6]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ6             - IO_L24P_T3U_N10_67
set_property PACKAGE_PIN AT28                [get_ports "c0_ddr4_dq[7]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ7             - IO_L23N_T3U_N9_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[7]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ7             - IO_L23N_T3U_N9_67
set_property PACKAGE_PIN AV33                [get_ports "c0_ddr4_dq[8]"]                 ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ8             - IO_L20P_T3L_N2_AD1P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[8]"]                 ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ8             - IO_L20P_T3L_N2_AD1P_68
set_property PACKAGE_PIN AR31                [get_ports "c0_ddr4_dq[9]"]                 ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ9             - IO_L24P_T3U_N10_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[9]"]                 ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ9             - IO_L24P_T3U_N10_68
set_property PACKAGE_PIN AW34                [get_ports "c0_ddr4_dq[10]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ10            - IO_L20N_T3L_N3_AD1N_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[10]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ10            - IO_L20N_T3L_N3_AD1N_68
set_property PACKAGE_PIN AT32                [get_ports "c0_ddr4_dq[11]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ11            - IO_L24N_T3U_N11_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[11]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ11            - IO_L24N_T3U_N11_68
set_property PACKAGE_PIN AU32                [get_ports "c0_ddr4_dq[12]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ12            - IO_L21P_T3L_N4_AD8P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[12]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ12            - IO_L21P_T3L_N4_AD8P_68
set_property PACKAGE_PIN AR33                [get_ports "c0_ddr4_dq[13]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ13            - IO_L23N_T3U_N9_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[13]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ13            - IO_L23N_T3U_N9_68
set_property PACKAGE_PIN AV32                [get_ports "c0_ddr4_dq[14]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ14            - IO_L21N_T3L_N5_AD8N_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[14]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ14            - IO_L21N_T3L_N5_AD8N_68
set_property PACKAGE_PIN AR32                [get_ports "c0_ddr4_dq[15]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ15            - IO_L23P_T3U_N8_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[15]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ15            - IO_L23P_T3U_N8_68
set_property PACKAGE_PIN BE32                [get_ports "c0_ddr4_dq[16]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ16            - IO_L3P_T0L_N4_AD15P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[16]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ16            - IO_L3P_T0L_N4_AD15P_68
set_property PACKAGE_PIN BF34                [get_ports "c0_ddr4_dq[17]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ17            - IO_L2N_T0L_N3_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[17]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ17            - IO_L2N_T0L_N3_68
set_property PACKAGE_PIN BF32                [get_ports "c0_ddr4_dq[18]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ18            - IO_L3N_T0L_N5_AD15N_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[18]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ18            - IO_L3N_T0L_N5_AD15N_68
set_property PACKAGE_PIN BF33                [get_ports "c0_ddr4_dq[19]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ19            - IO_L2P_T0L_N2_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[19]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ19            - IO_L2P_T0L_N2_68
set_property PACKAGE_PIN BC32                [get_ports "c0_ddr4_dq[20]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ20            - IO_L5P_T0U_N8_AD14P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[20]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ20            - IO_L5P_T0U_N8_AD14P_68
set_property PACKAGE_PIN BD34                [get_ports "c0_ddr4_dq[21]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ21            - IO_L6N_T0U_N11_AD6N_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[21]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ21            - IO_L6N_T0U_N11_AD6N_68
set_property PACKAGE_PIN BC33                [get_ports "c0_ddr4_dq[22]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ22            - IO_L6P_T0U_N10_AD6P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[22]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ22            - IO_L6P_T0U_N10_AD6P_68
set_property PACKAGE_PIN BD33                [get_ports "c0_ddr4_dq[23]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ23            - IO_L5N_T0U_N9_AD14N_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[23]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ23            - IO_L5N_T0U_N9_AD14N_68
set_property PACKAGE_PIN AW31                [get_ports "c0_ddr4_dq[24]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ24            - IO_L15N_T2L_N5_AD11N_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[24]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ24            - IO_L15N_T2L_N5_AD11N_67
set_property PACKAGE_PIN AV28                [get_ports "c0_ddr4_dq[25]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ25            - IO_L17P_T2U_N8_AD10P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[25]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ25            - IO_L17P_T2U_N8_AD10P_67
set_property PACKAGE_PIN AV31                [get_ports "c0_ddr4_dq[26]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ26            - IO_L15P_T2L_N4_AD11P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[26]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ26            - IO_L15P_T2L_N4_AD11P_67
set_property PACKAGE_PIN AY26                [get_ports "c0_ddr4_dq[27]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ27            - IO_L18N_T2U_N11_AD2N_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[27]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ27            - IO_L18N_T2U_N11_AD2N_67
set_property PACKAGE_PIN AW30                [get_ports "c0_ddr4_dq[28]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ28            - IO_L14P_T2L_N2_GC_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[28]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ28            - IO_L14P_T2L_N2_GC_67
set_property PACKAGE_PIN AW26                [get_ports "c0_ddr4_dq[29]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ29            - IO_L18P_T2U_N10_AD2P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[29]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ29            - IO_L18P_T2U_N10_AD2P_67
set_property PACKAGE_PIN AY31                [get_ports "c0_ddr4_dq[30]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ30            - IO_L14N_T2L_N3_GC_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[30]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ30            - IO_L14N_T2L_N3_GC_67
set_property PACKAGE_PIN AW28                [get_ports "c0_ddr4_dq[31]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ31            - IO_L17N_T2U_N9_AD10N_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[31]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ31            - IO_L17N_T2U_N9_AD10N_67
set_property PACKAGE_PIN BB32                [get_ports "c0_ddr4_dq[32]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ32            - IO_L15N_T2L_N5_AD11N_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[32]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ32            - IO_L15N_T2L_N5_AD11N_68
set_property PACKAGE_PIN AY35                [get_ports "c0_ddr4_dq[33]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ33            - IO_L17N_T2U_N9_AD10N_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[33]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ33            - IO_L17N_T2U_N9_AD10N_68
set_property PACKAGE_PIN BA32                [get_ports "c0_ddr4_dq[34]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ34            - IO_L15P_T2L_N4_AD11P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[34]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ34            - IO_L15P_T2L_N4_AD11P_68
set_property PACKAGE_PIN AW35                [get_ports "c0_ddr4_dq[35]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ35            - IO_L17P_T2U_N8_AD10P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[35]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ35            - IO_L17P_T2U_N8_AD10P_68
set_property PACKAGE_PIN BB35                [get_ports "c0_ddr4_dq[36]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ36            - IO_L14N_T2L_N3_GC_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[36]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ36            - IO_L14N_T2L_N3_GC_68
set_property PACKAGE_PIN AY36                [get_ports "c0_ddr4_dq[37]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ37            - IO_L18N_T2U_N11_AD2N_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[37]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ37            - IO_L18N_T2U_N11_AD2N_68
set_property PACKAGE_PIN BB34                [get_ports "c0_ddr4_dq[38]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ38            - IO_L14P_T2L_N2_GC_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[38]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ38            - IO_L14P_T2L_N2_GC_68
set_property PACKAGE_PIN AW36                [get_ports "c0_ddr4_dq[39]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ39            - IO_L18P_T2U_N10_AD2P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[39]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ39            - IO_L18P_T2U_N10_AD2P_68
set_property PACKAGE_PIN BA28                [get_ports "c0_ddr4_dq[40]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ40            - IO_L12N_T1U_N11_GC_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[40]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ40            - IO_L12N_T1U_N11_GC_67
set_property PACKAGE_PIN BC31                [get_ports "c0_ddr4_dq[41]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ41            - IO_L8N_T1L_N3_AD5N_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[41]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ41            - IO_L8N_T1L_N3_AD5N_67
set_property PACKAGE_PIN BB27                [get_ports "c0_ddr4_dq[42]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ42            - IO_L11P_T1U_N8_GC_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[42]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ42            - IO_L11P_T1U_N8_GC_67
set_property PACKAGE_PIN BA30                [get_ports "c0_ddr4_dq[43]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ43            - IO_L9N_T1L_N5_AD12N_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[43]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ43            - IO_L9N_T1L_N5_AD12N_67
set_property PACKAGE_PIN BC27                [get_ports "c0_ddr4_dq[44]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ44            - IO_L11N_T1U_N9_GC_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[44]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ44            - IO_L11N_T1U_N9_GC_67
set_property PACKAGE_PIN BB31                [get_ports "c0_ddr4_dq[45]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ45            - IO_L8P_T1L_N2_AD5P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[45]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ45            - IO_L8P_T1L_N2_AD5P_67
set_property PACKAGE_PIN BA27                [get_ports "c0_ddr4_dq[46]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ46            - IO_L12P_T1U_N10_GC_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[46]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ46            - IO_L12P_T1U_N10_GC_67
set_property PACKAGE_PIN AY30                [get_ports "c0_ddr4_dq[47]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ47            - IO_L9P_T1L_N4_AD12P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[47]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ47            - IO_L9P_T1L_N4_AD12P_67
set_property PACKAGE_PIN AR26                [get_ports "c0_ddr4_dq[48]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ48            - IO_L21P_T3L_N4_AD8P_66
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[48]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ48            - IO_L21P_T3L_N4_AD8P_66
set_property PACKAGE_PIN AP23                [get_ports "c0_ddr4_dq[49]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ49            - IO_L23P_T3U_N8_66
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[49]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ49            - IO_L23P_T3U_N8_66
set_property PACKAGE_PIN AR25                [get_ports "c0_ddr4_dq[50]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ50            - IO_L20P_T3L_N2_AD1P_66
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[50]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ50            - IO_L20P_T3L_N2_AD1P_66
set_property PACKAGE_PIN AR23                [get_ports "c0_ddr4_dq[51]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ51            - IO_L23N_T3U_N9_66
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[51]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ51            - IO_L23N_T3U_N9_66
set_property PACKAGE_PIN AT25                [get_ports "c0_ddr4_dq[52]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ52            - IO_L21N_T3L_N5_AD8N_66
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[52]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ52            - IO_L21N_T3L_N5_AD8N_66
set_property PACKAGE_PIN AR22                [get_ports "c0_ddr4_dq[53]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ53            - IO_L24P_T3U_N10_66
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[53]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ53            - IO_L24P_T3U_N10_66
set_property PACKAGE_PIN AT24                [get_ports "c0_ddr4_dq[54]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ54            - IO_L20N_T3L_N3_AD1N_66
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[54]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ54            - IO_L20N_T3L_N3_AD1N_66
set_property PACKAGE_PIN AR21                [get_ports "c0_ddr4_dq[55]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ55            - IO_L24N_T3U_N11_66
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[55]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ55            - IO_L24N_T3U_N11_66
set_property PACKAGE_PIN BD26                [get_ports "c0_ddr4_dq[56]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ56            - IO_L5P_T0U_N8_AD14P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[56]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ56            - IO_L5P_T0U_N8_AD14P_67
set_property PACKAGE_PIN BF28                [get_ports "c0_ddr4_dq[57]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ57            - IO_L2P_T0L_N2_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[57]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ57            - IO_L2P_T0L_N2_67
set_property PACKAGE_PIN BE26                [get_ports "c0_ddr4_dq[58]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ58            - IO_L5N_T0U_N9_AD14N_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[58]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ58            - IO_L5N_T0U_N9_AD14N_67
set_property PACKAGE_PIN BE28                [get_ports "c0_ddr4_dq[59]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ59            - IO_L3N_T0L_N5_AD15N_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[59]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ59            - IO_L3N_T0L_N5_AD15N_67
set_property PACKAGE_PIN BC26                [get_ports "c0_ddr4_dq[60]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ60            - IO_L6N_T0U_N11_AD6N_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[60]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ60            - IO_L6N_T0U_N11_AD6N_67
set_property PACKAGE_PIN BF29                [get_ports "c0_ddr4_dq[61]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ61            - IO_L2N_T0L_N3_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[61]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ61            - IO_L2N_T0L_N3_67
set_property PACKAGE_PIN BB26                [get_ports "c0_ddr4_dq[62]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ62            - IO_L6P_T0U_N10_AD6P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[62]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ62            - IO_L6P_T0U_N10_AD6P_67
set_property PACKAGE_PIN BD28                [get_ports "c0_ddr4_dq[63]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ63            - IO_L3P_T0L_N4_AD15P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[63]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ63            - IO_L3P_T0L_N4_AD15P_67
set_property PACKAGE_PIN BD38                [get_ports "c0_ddr4_dq[64]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ64            - IO_L9N_T1L_N5_AD12N_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[64]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ64            - IO_L9N_T1L_N5_AD12N_68
set_property PACKAGE_PIN BC36                [get_ports "c0_ddr4_dq[65]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ65            - IO_L12P_T1U_N10_GC_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[65]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ65            - IO_L12P_T1U_N10_GC_68
set_property PACKAGE_PIN BC38                [get_ports "c0_ddr4_dq[66]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ66            - IO_L9P_T1L_N4_AD12P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[66]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ66            - IO_L9P_T1L_N4_AD12P_68
set_property PACKAGE_PIN BD36                [get_ports "c0_ddr4_dq[67]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ67            - IO_L12N_T1U_N11_GC_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[67]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ67            - IO_L12N_T1U_N11_GC_68
set_property PACKAGE_PIN BE38                [get_ports "c0_ddr4_dq[68]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ68            - IO_L8P_T1L_N2_AD5P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[68]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ68            - IO_L8P_T1L_N2_AD5P_68
set_property PACKAGE_PIN BC34                [get_ports "c0_ddr4_dq[69]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ69            - IO_L11P_T1U_N8_GC_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[69]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ69            - IO_L11P_T1U_N8_GC_68
set_property PACKAGE_PIN BD35                [get_ports "c0_ddr4_dq[70]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ70            - IO_L11N_T1U_N9_GC_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[70]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ70            - IO_L11N_T1U_N9_GC_68
set_property PACKAGE_PIN BF38                [get_ports "c0_ddr4_dq[71]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ71            - IO_L8N_T1L_N3_AD5N_68
set_property IOSTANDARD  POD12_DCI           [get_ports "c0_ddr4_dq[71]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ71            - IO_L8N_T1L_N3_AD5N_68
set_property PACKAGE_PIN AU30                [get_ports "c0_ddr4_dqs_c[0]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C0          - IO_L22N_T3U_N7_DBC_AD0N_67
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "c0_ddr4_dqs_c[0]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C0          - IO_L22N_T3U_N7_DBC_AD0N_67
set_property PACKAGE_PIN AV34                [get_ports "c0_ddr4_dqs_c[1]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C1          - IO_L22N_T3U_N7_DBC_AD0N_68
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "c0_ddr4_dqs_c[1]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C1          - IO_L22N_T3U_N7_DBC_AD0N_68
set_property PACKAGE_PIN BE31                [get_ports "c0_ddr4_dqs_c[2]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C2          - IO_L4N_T0U_N7_DBC_AD7N_68
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "c0_ddr4_dqs_c[2]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C2          - IO_L4N_T0U_N7_DBC_AD7N_68
set_property PACKAGE_PIN AW29                [get_ports "c0_ddr4_dqs_c[3]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C3          - IO_L16N_T2U_N7_QBC_AD3N_67
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "c0_ddr4_dqs_c[3]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C3          - IO_L16N_T2U_N7_QBC_AD3N_67
set_property PACKAGE_PIN BA33                [get_ports "c0_ddr4_dqs_c[4]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C4          - IO_L16N_T2U_N7_QBC_AD3N_68
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "c0_ddr4_dqs_c[4]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C4          - IO_L16N_T2U_N7_QBC_AD3N_68
set_property PACKAGE_PIN BB30                [get_ports "c0_ddr4_dqs_c[5]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C5          - IO_L10N_T1U_N7_QBC_AD4N_67
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "c0_ddr4_dqs_c[5]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C5          - IO_L10N_T1U_N7_QBC_AD4N_67
set_property PACKAGE_PIN AP24                [get_ports "c0_ddr4_dqs_c[6]"]              ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C6          - IO_L22N_T3U_N7_DBC_AD0N_66
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "c0_ddr4_dqs_c[6]"]              ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C6          - IO_L22N_T3U_N7_DBC_AD0N_66
set_property PACKAGE_PIN BF27                [get_ports "c0_ddr4_dqs_c[7]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C7          - IO_L4N_T0U_N7_DBC_AD7N_67
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "c0_ddr4_dqs_c[7]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C7          - IO_L4N_T0U_N7_DBC_AD7N_67
set_property PACKAGE_PIN BC37                [get_ports "c0_ddr4_dqs_c[8]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C8          - IO_L10N_T1U_N7_QBC_AD4N_68
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "c0_ddr4_dqs_c[8]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C8          - IO_L10N_T1U_N7_QBC_AD4N_68
set_property PACKAGE_PIN AT29                [get_ports "c0_ddr4_dqs_t[0]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T0          - IO_L22P_T3U_N6_DBC_AD0P_67
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "c0_ddr4_dqs_t[0]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T0          - IO_L22P_T3U_N6_DBC_AD0P_67
set_property PACKAGE_PIN AU34                [get_ports "c0_ddr4_dqs_t[1]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T1          - IO_L22P_T3U_N6_DBC_AD0P_68
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "c0_ddr4_dqs_t[1]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T1          - IO_L22P_T3U_N6_DBC_AD0P_68
set_property PACKAGE_PIN BD31                [get_ports "c0_ddr4_dqs_t[2]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T2          - IO_L4P_T0U_N6_DBC_AD7P_68
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "c0_ddr4_dqs_t[2]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T2          - IO_L4P_T0U_N6_DBC_AD7P_68
set_property PACKAGE_PIN AV29                [get_ports "c0_ddr4_dqs_t[3]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T3          - IO_L16P_T2U_N6_QBC_AD3P_67
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "c0_ddr4_dqs_t[3]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T3          - IO_L16P_T2U_N6_QBC_AD3P_67
set_property PACKAGE_PIN AY32                [get_ports "c0_ddr4_dqs_t[4]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T4          - IO_L16P_T2U_N6_QBC_AD3P_68
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "c0_ddr4_dqs_t[4]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T4          - IO_L16P_T2U_N6_QBC_AD3P_68
set_property PACKAGE_PIN BB29                [get_ports "c0_ddr4_dqs_t[5]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T5          - IO_L10P_T1U_N6_QBC_AD4P_67
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "c0_ddr4_dqs_t[5]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T5          - IO_L10P_T1U_N6_QBC_AD4P_67
set_property PACKAGE_PIN AP25                [get_ports "c0_ddr4_dqs_t[6]"]              ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T6          - IO_L22P_T3U_N6_DBC_AD0P_66
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "c0_ddr4_dqs_t[6]"]              ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T6          - IO_L22P_T3U_N6_DBC_AD0P_66
set_property PACKAGE_PIN BE27                [get_ports "c0_ddr4_dqs_t[7]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T7          - IO_L4P_T0U_N6_DBC_AD7P_67
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "c0_ddr4_dqs_t[7]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T7          - IO_L4P_T0U_N6_DBC_AD7P_67
set_property PACKAGE_PIN BB37                [get_ports "c0_ddr4_dqs_t[8]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T8          - IO_L10P_T1U_N6_QBC_AD4P_68
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "c0_ddr4_dqs_t[8]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T8          - IO_L10P_T1U_N6_QBC_AD4P_68


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
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR0_Q[17]"]                    ;# Bank  72 VCCO - +1V5_SYS                               - IO_L9P_T1L_N4_AD12P_72


#################################################################################
#
#  QDRII+ 1 Interface...
#
#################################################################################

#
#  GSI QDRII+ - 288Mb, 18-bit Data Interface, 550 Mhz 
#     Banks 70, 71 (1.5V)
#
set_property PACKAGE_PIN J28                 [get_ports "QDR1_CQN"]                      ;# Bank  71 VCCO - +1V5_SYS                               - IO_L7P_T1L_N0_QBC_AD13P_71
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_CQN"]                      ;# Bank  71 VCCO - +1V5_SYS                               - IO_L7P_T1L_N0_QBC_AD13P_71
set_property PACKAGE_PIN G25                 [get_ports "QDR1_CQP"]                      ;# Bank  71 VCCO - +1V5_SYS                               - IO_L10P_T1U_N6_QBC_AD4P_71
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_CQP"]                      ;# Bank  71 VCCO - +1V5_SYS                               - IO_L10P_T1U_N6_QBC_AD4P_71
set_property PACKAGE_PIN F30                 [get_ports "QDR1_KN"]                       ;# Bank  70 VCCO - +1V5_SYS                               - IO_L10N_T1U_N7_QBC_AD4N_70
set_property IOSTANDARD  DIFF_HSTL_I_DCI     [get_ports "QDR1_KN"]                       ;# Bank  70 VCCO - +1V5_SYS                               - IO_L10N_T1U_N7_QBC_AD4N_70
set_property PACKAGE_PIN G30                 [get_ports "QDR1_KP"]                       ;# Bank  70 VCCO - +1V5_SYS                               - IO_L10P_T1U_N6_QBC_AD4P_70
set_property IOSTANDARD  DIFF_HSTL_I_DCI     [get_ports "QDR1_KP"]                       ;# Bank  70 VCCO - +1V5_SYS                               - IO_L10P_T1U_N6_QBC_AD4P_70
set_property PACKAGE_PIN D33                 [get_ports "QDR1_RN"]                       ;# Bank  70 VCCO - +1V5_SYS                               - IO_L17P_T2U_N8_AD10P_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_RN"]                       ;# Bank  70 VCCO - +1V5_SYS                               - IO_L17P_T2U_N8_AD10P_70
set_property PACKAGE_PIN E32                 [get_ports "QDR1_WN"]                       ;# Bank  70 VCCO - +1V5_SYS                               - IO_L15N_T2L_N5_AD11N_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_WN"]                       ;# Bank  70 VCCO - +1V5_SYS                               - IO_L15N_T2L_N5_AD11N_70
set_property PACKAGE_PIN C33                 [get_ports "QDR1_DOFFN"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L17N_T2U_N9_AD10N_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_DOFFN"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L17N_T2U_N9_AD10N_70
set_property PACKAGE_PIN J31                 [get_ports "QDR1_BWN[0]"]                   ;# Bank  70 VCCO - +1V5_SYS                               - IO_L5N_T0U_N9_AD14N_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_BWN[0]"]                   ;# Bank  70 VCCO - +1V5_SYS                               - IO_L5N_T0U_N9_AD14N_70
set_property PACKAGE_PIN G31                 [get_ports "QDR1_BWN[1]"]                   ;# Bank  70 VCCO - +1V5_SYS                               - IO_L9N_T1L_N5_AD12N_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_BWN[1]"]                   ;# Bank  70 VCCO - +1V5_SYS                               - IO_L9N_T1L_N5_AD12N_70
set_property PACKAGE_PIN F34                 [get_ports "QDR1_A[0]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L13P_T2L_N0_GC_QBC_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_A[0]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L13P_T2L_N0_GC_QBC_70
set_property PACKAGE_PIN F33                 [get_ports "QDR1_A[1]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L14P_T2L_N2_GC_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_A[1]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L14P_T2L_N2_GC_70
set_property PACKAGE_PIN B32                 [get_ports "QDR1_A[2]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L23P_T3U_N8_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_A[2]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L23P_T3U_N8_70
set_property PACKAGE_PIN A32                 [get_ports "QDR1_A[3]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L24N_T3U_N11_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_A[3]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L24N_T3U_N11_70
set_property PACKAGE_PIN E33                 [get_ports "QDR1_A[4]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L14N_T2L_N3_GC_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_A[4]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L14N_T2L_N3_GC_70
set_property PACKAGE_PIN B31                 [get_ports "QDR1_A[5]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L24P_T3U_N10_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_A[5]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L24P_T3U_N10_70
set_property PACKAGE_PIN D31                 [get_ports "QDR1_A[6]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L16P_T2U_N6_QBC_AD3P_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_A[6]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L16P_T2U_N6_QBC_AD3P_70
set_property PACKAGE_PIN C31                 [get_ports "QDR1_A[7]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L16N_T2U_N7_QBC_AD3N_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_A[7]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L16N_T2U_N7_QBC_AD3N_70
set_property PACKAGE_PIN A35                 [get_ports "QDR1_A[8]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L21N_T3L_N5_AD8N_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_A[8]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L21N_T3L_N5_AD8N_70
set_property PACKAGE_PIN B35                 [get_ports "QDR1_A[9]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L21P_T3L_N4_AD8P_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_A[9]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L21P_T3L_N4_AD8P_70
set_property PACKAGE_PIN B34                 [get_ports "QDR1_A[10]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L22P_T3U_N6_DBC_AD0P_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_A[10]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L22P_T3U_N6_DBC_AD0P_70
set_property PACKAGE_PIN C36                 [get_ports "QDR1_A[11]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L20P_T3L_N2_AD1P_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_A[11]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L20P_T3L_N2_AD1P_70
set_property PACKAGE_PIN E35                 [get_ports "QDR1_A[12]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L13N_T2L_N1_GC_QBC_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_A[12]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L13N_T2L_N1_GC_QBC_70
set_property PACKAGE_PIN A34                 [get_ports "QDR1_A[13]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L22N_T3U_N7_DBC_AD0N_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_A[13]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L22N_T3U_N7_DBC_AD0N_70
set_property PACKAGE_PIN C34                 [get_ports "QDR1_A[14]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L18N_T2U_N11_AD2N_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_A[14]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L18N_T2U_N11_AD2N_70
set_property PACKAGE_PIN E36                 [get_ports "QDR1_A[15]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_T2U_N12_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_A[15]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_T2U_N12_70
set_property PACKAGE_PIN D36                 [get_ports "QDR1_A[16]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L19N_T3L_N1_DBC_AD9N_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_A[16]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L19N_T3L_N1_DBC_AD9N_70
set_property PACKAGE_PIN B36                 [get_ports "QDR1_A[17]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L20N_T3L_N3_AD1N_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_A[17]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L20N_T3L_N3_AD1N_70
set_property PACKAGE_PIN D35                 [get_ports "QDR1_A[18]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L19P_T3L_N0_DBC_AD9P_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_A[18]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L19P_T3L_N0_DBC_AD9P_70
set_property PACKAGE_PIN A33                 [get_ports "QDR1_A[19]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L23N_T3U_N9_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_A[19]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L23N_T3U_N9_70
set_property PACKAGE_PIN D34                 [get_ports "QDR1_A[20]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L18P_T2U_N10_AD2P_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_A[20]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L18P_T2U_N10_AD2P_70
set_property PACKAGE_PIN C32                 [get_ports "QDR1_A[21]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_T3U_N12_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_A[21]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_T3U_N12_70
set_property PACKAGE_PIN J30                 [get_ports "QDR1_D[0]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L4N_T0U_N7_DBC_AD7N_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_D[0]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L4N_T0U_N7_DBC_AD7N_70
set_property PACKAGE_PIN K33                 [get_ports "QDR1_D[1]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L6P_T0U_N10_AD6P_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_D[1]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L6P_T0U_N10_AD6P_70
set_property PACKAGE_PIN K31                 [get_ports "QDR1_D[2]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L5P_T0U_N8_AD14P_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_D[2]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L5P_T0U_N8_AD14P_70
set_property PACKAGE_PIN K30                 [get_ports "QDR1_D[3]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L4P_T0U_N6_DBC_AD7P_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_D[3]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L4P_T0U_N6_DBC_AD7P_70
set_property PACKAGE_PIN L34                 [get_ports "QDR1_D[4]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L1N_T0L_N1_DBC_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_D[4]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L1N_T0L_N1_DBC_70
set_property PACKAGE_PIN M32                 [get_ports "QDR1_D[5]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L2N_T0L_N3_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_D[5]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L2N_T0L_N3_70
set_property PACKAGE_PIN L30                 [get_ports "QDR1_D[6]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L3N_T0L_N5_AD15N_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_D[6]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L3N_T0L_N5_AD15N_70
set_property PACKAGE_PIN M31                 [get_ports "QDR1_D[7]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L2P_T0L_N2_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_D[7]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L2P_T0L_N2_70
set_property PACKAGE_PIN M30                 [get_ports "QDR1_D[8]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L3P_T0L_N4_AD15P_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_D[8]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L3P_T0L_N4_AD15P_70
set_property PACKAGE_PIN H31                 [get_ports "QDR1_D[9]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L9P_T1L_N4_AD12P_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_D[9]"]                     ;# Bank  70 VCCO - +1V5_SYS                               - IO_L9P_T1L_N4_AD12P_70
set_property PACKAGE_PIN F32                 [get_ports "QDR1_D[10]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L12N_T1U_N11_GC_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_D[10]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L12N_T1U_N11_GC_70
set_property PACKAGE_PIN G32                 [get_ports "QDR1_D[11]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L12P_T1U_N10_GC_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_D[11]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L12P_T1U_N10_GC_70
set_property PACKAGE_PIN H32                 [get_ports "QDR1_D[12]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L11P_T1U_N8_GC_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_D[12]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L11P_T1U_N8_GC_70
set_property PACKAGE_PIN H33                 [get_ports "QDR1_D[13]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L11N_T1U_N9_GC_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_D[13]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L11N_T1U_N9_GC_70
set_property PACKAGE_PIN G34                 [get_ports "QDR1_D[14]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L8P_T1L_N2_AD5P_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_D[14]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L8P_T1L_N2_AD5P_70
set_property PACKAGE_PIN H34                 [get_ports "QDR1_D[15]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L7N_T1L_N1_QBC_AD13N_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_D[15]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L7N_T1L_N1_QBC_AD13N_70
set_property PACKAGE_PIN F35                 [get_ports "QDR1_D[16]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L8N_T1L_N3_AD5N_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_D[16]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L8N_T1L_N3_AD5N_70
set_property PACKAGE_PIN J34                 [get_ports "QDR1_D[17]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L7P_T1L_N0_QBC_AD13P_70
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_D[17]"]                    ;# Bank  70 VCCO - +1V5_SYS                               - IO_L7P_T1L_N0_QBC_AD13P_70
set_property PACKAGE_PIN L28                 [get_ports "QDR1_Q[0]"]                     ;# Bank  71 VCCO - +1V5_SYS                               - IO_L3P_T0L_N4_AD15P_71
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_Q[0]"]                     ;# Bank  71 VCCO - +1V5_SYS                               - IO_L3P_T0L_N4_AD15P_71
set_property PACKAGE_PIN L29                 [get_ports "QDR1_Q[1]"]                     ;# Bank  71 VCCO - +1V5_SYS                               - IO_L3N_T0L_N5_AD15N_71
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_Q[1]"]                     ;# Bank  71 VCCO - +1V5_SYS                               - IO_L3N_T0L_N5_AD15N_71
set_property PACKAGE_PIN K27                 [get_ports "QDR1_Q[2]"]                     ;# Bank  71 VCCO - +1V5_SYS                               - IO_L4P_T0U_N6_DBC_AD7P_71
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_Q[2]"]                     ;# Bank  71 VCCO - +1V5_SYS                               - IO_L4P_T0U_N6_DBC_AD7P_71
set_property PACKAGE_PIN K28                 [get_ports "QDR1_Q[3]"]                     ;# Bank  71 VCCO - +1V5_SYS                               - IO_L4N_T0U_N7_DBC_AD7N_71
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_Q[3]"]                     ;# Bank  71 VCCO - +1V5_SYS                               - IO_L4N_T0U_N7_DBC_AD7N_71
set_property PACKAGE_PIN L25                 [get_ports "QDR1_Q[4]"]                     ;# Bank  71 VCCO - +1V5_SYS                               - IO_L5P_T0U_N8_AD14P_71
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_Q[4]"]                     ;# Bank  71 VCCO - +1V5_SYS                               - IO_L5P_T0U_N8_AD14P_71
set_property PACKAGE_PIN K26                 [get_ports "QDR1_Q[5]"]                     ;# Bank  71 VCCO - +1V5_SYS                               - IO_L5N_T0U_N9_AD14N_71
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_Q[5]"]                     ;# Bank  71 VCCO - +1V5_SYS                               - IO_L5N_T0U_N9_AD14N_71
set_property PACKAGE_PIN H29                 [get_ports "QDR1_Q[6]"]                     ;# Bank  71 VCCO - +1V5_SYS                               - IO_L8N_T1L_N3_AD5N_71
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_Q[6]"]                     ;# Bank  71 VCCO - +1V5_SYS                               - IO_L8N_T1L_N3_AD5N_71
set_property PACKAGE_PIN F29                 [get_ports "QDR1_Q[7]"]                     ;# Bank  71 VCCO - +1V5_SYS                               - IO_L9N_T1L_N5_AD12N_71
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_Q[7]"]                     ;# Bank  71 VCCO - +1V5_SYS                               - IO_L9N_T1L_N5_AD12N_71
set_property PACKAGE_PIN H26                 [get_ports "QDR1_Q[8]"]                     ;# Bank  71 VCCO - +1V5_SYS                               - IO_L11P_T1U_N8_GC_71
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_Q[8]"]                     ;# Bank  71 VCCO - +1V5_SYS                               - IO_L11P_T1U_N8_GC_71
set_property PACKAGE_PIN F25                 [get_ports "QDR1_Q[9]"]                     ;# Bank  71 VCCO - +1V5_SYS                               - IO_L10N_T1U_N7_QBC_AD4N_71
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_Q[9]"]                     ;# Bank  71 VCCO - +1V5_SYS                               - IO_L10N_T1U_N7_QBC_AD4N_71
set_property PACKAGE_PIN G29                 [get_ports "QDR1_Q[10]"]                    ;# Bank  71 VCCO - +1V5_SYS                               - IO_L9P_T1L_N4_AD12P_71
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_Q[10]"]                    ;# Bank  71 VCCO - +1V5_SYS                               - IO_L9P_T1L_N4_AD12P_71
set_property PACKAGE_PIN H27                 [get_ports "QDR1_Q[11]"]                    ;# Bank  71 VCCO - +1V5_SYS                               - IO_L11N_T1U_N9_GC_71
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_Q[11]"]                    ;# Bank  71 VCCO - +1V5_SYS                               - IO_L11N_T1U_N9_GC_71
set_property PACKAGE_PIN H28                 [get_ports "QDR1_Q[12]"]                    ;# Bank  71 VCCO - +1V5_SYS                               - IO_L7N_T1L_N1_QBC_AD13N_71
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_Q[12]"]                    ;# Bank  71 VCCO - +1V5_SYS                               - IO_L7N_T1L_N1_QBC_AD13N_71
set_property PACKAGE_PIN J29                 [get_ports "QDR1_Q[13]"]                    ;# Bank  71 VCCO - +1V5_SYS                               - IO_L8P_T1L_N2_AD5P_71
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_Q[13]"]                    ;# Bank  71 VCCO - +1V5_SYS                               - IO_L8P_T1L_N2_AD5P_71
set_property PACKAGE_PIN M27                 [get_ports "QDR1_Q[14]"]                    ;# Bank  71 VCCO - +1V5_SYS                               - IO_L2N_T0L_N3_71
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_Q[14]"]                    ;# Bank  71 VCCO - +1V5_SYS                               - IO_L2N_T0L_N3_71
set_property PACKAGE_PIN M26                 [get_ports "QDR1_Q[15]"]                    ;# Bank  71 VCCO - +1V5_SYS                               - IO_L1N_T0L_N1_DBC_71
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_Q[15]"]                    ;# Bank  71 VCCO - +1V5_SYS                               - IO_L1N_T0L_N1_DBC_71
set_property PACKAGE_PIN N27                 [get_ports "QDR1_Q[16]"]                    ;# Bank  71 VCCO - +1V5_SYS                               - IO_L2P_T0L_N2_71
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_Q[16]"]                    ;# Bank  71 VCCO - +1V5_SYS                               - IO_L2P_T0L_N2_71
set_property PACKAGE_PIN N26                 [get_ports "QDR1_Q[17]"]                    ;# Bank  71 VCCO - +1V5_SYS                               - IO_L1P_T0L_N0_DBC_71
set_property IOSTANDARD  HSTL_I_DCI          [get_ports "QDR1_Q[17]"]                    ;# Bank  71 VCCO - +1V5_SYS                               - IO_L1P_T0L_N0_DBC_71

#################################################################################
#
#  QSFP MGTF Interfaces...
#
#################################################################################

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

#
#  Cage LED's Driven by FPGA - Active High, Bank 88 (3.3V)
#
set_property PACKAGE_PIN AR13                [get_ports "QSFPDD0_LED"]                   ;# Bank  88 VCCO - +3V3_SYS_FPGA                          - IO_L12N_AD0N_88
set_property IOSTANDARD  LVCMOS33            [get_ports "QSFPDD0_LED"]                   ;# Bank  88 VCCO - +3V3_SYS_FPGA                          - IO_L12N_AD0N_88
set_property PACKAGE_PIN AP13                [get_ports "QSFPDD1_LED"]                   ;# Bank  88 VCCO - +3V3_SYS_FPGA                          - IO_L12P_AD0P_88
set_property IOSTANDARD  LVCMOS33            [get_ports "QSFPDD1_LED"]                   ;# Bank  88 VCCO - +3V3_SYS_FPGA                          - IO_L12P_AD0P_88
set_property PACKAGE_PIN AP14                [get_ports "QSFPDD2_LED"]                   ;# Bank  88 VCCO - +3V3_SYS_FPGA                          - IO_L11N_AD1N_88
set_property IOSTANDARD  LVCMOS33            [get_ports "QSFPDD2_LED"]                   ;# Bank  88 VCCO - +3V3_SYS_FPGA                          - IO_L11N_AD1N_88
set_property PACKAGE_PIN AP15                [get_ports "QSFPDD3_LED"]                   ;# Bank  88 VCCO - +3V3_SYS_FPGA                          - IO_L11P_AD1P_88
set_property IOSTANDARD  LVCMOS33            [get_ports "QSFPDD3_LED"]                   ;# Bank  88 VCCO - +3V3_SYS_FPGA                          - IO_L11P_AD1P_88


#
#  QSFPDD 0 GTF Connections - Bank 232, 233
#    Typical pin constraints are embedded in the IP
#
set_property PACKAGE_PIN H8                  [get_ports "SYNCE_CLK16_LVDS_N"]            ;# Bank 232 - MGTREFCLK0N_232
set_property PACKAGE_PIN H9                  [get_ports "SYNCE_CLK16_LVDS_P"]            ;# Bank 232 - MGTREFCLK0P_232
set_property PACKAGE_PIN K3                  [get_ports "QSFPDD0_RX_N[1]"]               ;# Bank 232 - MGTFRXN0_232
set_property PACKAGE_PIN K4                  [get_ports "QSFPDD0_RX_P[1]"]               ;# Bank 232 - MGTFRXP0_232
set_property PACKAGE_PIN J1                  [get_ports "QSFPDD0_RX_N[2]"]               ;# Bank 232 - MGTFRXN1_232
set_property PACKAGE_PIN J2                  [get_ports "QSFPDD0_RX_P[2]"]               ;# Bank 232 - MGTFRXP1_232
set_property PACKAGE_PIN H3                  [get_ports "QSFPDD0_RX_N[3]"]               ;# Bank 232 - MGTFRXN2_232
set_property PACKAGE_PIN H4                  [get_ports "QSFPDD0_RX_P[3]"]               ;# Bank 232 - MGTFRXP2_232
set_property PACKAGE_PIN G1                  [get_ports "QSFPDD0_RX_N[4]"]               ;# Bank 232 - MGTFRXN3_232
set_property PACKAGE_PIN G2                  [get_ports "QSFPDD0_RX_P[4]"]               ;# Bank 232 - MGTFRXP3_232
set_property PACKAGE_PIN M8                  [get_ports "QSFPDD0_TX_N[1]"]               ;# Bank 232 - MGTFTXN0_232
set_property PACKAGE_PIN M9                  [get_ports "QSFPDD0_TX_P[1]"]               ;# Bank 232 - MGTFTXP0_232
set_property PACKAGE_PIN L6                  [get_ports "QSFPDD0_TX_N[2]"]               ;# Bank 232 - MGTFTXN1_232
set_property PACKAGE_PIN L7                  [get_ports "QSFPDD0_TX_P[2]"]               ;# Bank 232 - MGTFTXP1_232
set_property PACKAGE_PIN K8                  [get_ports "QSFPDD0_TX_N[3]"]               ;# Bank 232 - MGTFTXN2_232
set_property PACKAGE_PIN K9                  [get_ports "QSFPDD0_TX_P[3]"]               ;# Bank 232 - MGTFTXP2_232
set_property PACKAGE_PIN J6                  [get_ports "QSFPDD0_TX_N[4]"]               ;# Bank 232 - MGTFTXN3_232
set_property PACKAGE_PIN J7                  [get_ports "QSFPDD0_TX_P[4]"]               ;# Bank 232 - MGTFTXP3_232

set_property PACKAGE_PIN D8                  [get_ports "SYNCE_CLK17_LVDS_N"]            ;# Bank 233 - MGTREFCLK0N_233
set_property PACKAGE_PIN D9                  [get_ports "SYNCE_CLK17_LVDS_P"]            ;# Bank 233 - MGTREFCLK0P_233
set_property PACKAGE_PIN F3                  [get_ports "QSFPDD0_RX_N[5]"]               ;# Bank 233 - MGTFRXN0_233
set_property PACKAGE_PIN F4                  [get_ports "QSFPDD0_RX_P[5]"]               ;# Bank 233 - MGTFRXP0_233
set_property PACKAGE_PIN E1                  [get_ports "QSFPDD0_RX_N[6]"]               ;# Bank 233 - MGTFRXN1_233
set_property PACKAGE_PIN E2                  [get_ports "QSFPDD0_RX_P[6]"]               ;# Bank 233 - MGTFRXP1_233
set_property PACKAGE_PIN D3                  [get_ports "QSFPDD0_RX_N[7]"]               ;# Bank 233 - MGTFRXN2_233
set_property PACKAGE_PIN D4                  [get_ports "QSFPDD0_RX_P[7]"]               ;# Bank 233 - MGTFRXP2_233
set_property PACKAGE_PIN B3                  [get_ports "QSFPDD0_RX_N[8]"]               ;# Bank 233 - MGTFRXN3_233
set_property PACKAGE_PIN B4                  [get_ports "QSFPDD0_RX_P[8]"]               ;# Bank 233 - MGTFRXP3_233
set_property PACKAGE_PIN G6                  [get_ports "QSFPDD0_TX_N[5]"]               ;# Bank 233 - MGTFTXN0_233
set_property PACKAGE_PIN G7                  [get_ports "QSFPDD0_TX_P[5]"]               ;# Bank 233 - MGTFTXP0_233
set_property PACKAGE_PIN E6                  [get_ports "QSFPDD0_TX_N[6]"]               ;# Bank 233 - MGTFTXN1_233
set_property PACKAGE_PIN E7                  [get_ports "QSFPDD0_TX_P[6]"]               ;# Bank 233 - MGTFTXP1_233
set_property PACKAGE_PIN C6                  [get_ports "QSFPDD0_TX_N[7]"]               ;# Bank 233 - MGTFTXN2_233
set_property PACKAGE_PIN C7                  [get_ports "QSFPDD0_TX_P[7]"]               ;# Bank 233 - MGTFTXP2_233
set_property PACKAGE_PIN A6                  [get_ports "QSFPDD0_TX_N[8]"]               ;# Bank 233 - MGTFTXN3_233
set_property PACKAGE_PIN A7                  [get_ports "QSFPDD0_TX_P[8]"]               ;# Bank 233 - MGTFTXP3_233

#
#  QSFPDD 1 GTF Connections - Bank 230, 231
#    Typical pin constraints are embedded in the IP
#
set_property PACKAGE_PIN U10                 [get_ports "SYNCE_CLK14_LVDS_N"]            ;# Bank 230 - MGTREFCLK0N_230
set_property PACKAGE_PIN U11                 [get_ports "SYNCE_CLK14_LVDS_P"]            ;# Bank 230 - MGTREFCLK0P_230
set_property PACKAGE_PIN V3                  [get_ports "QSFPDD1_RX_N[1]"]               ;# Bank 230 - MGTFRXN0_230
set_property PACKAGE_PIN V4                  [get_ports "QSFPDD1_RX_P[1]"]               ;# Bank 230 - MGTFRXP0_230
set_property PACKAGE_PIN U1                  [get_ports "QSFPDD1_RX_N[2]"]               ;# Bank 230 - MGTFRXN1_230
set_property PACKAGE_PIN U2                  [get_ports "QSFPDD1_RX_P[2]"]               ;# Bank 230 - MGTFRXP1_230
set_property PACKAGE_PIN T3                  [get_ports "QSFPDD1_RX_N[3]"]               ;# Bank 230 - MGTFRXN2_230
set_property PACKAGE_PIN T4                  [get_ports "QSFPDD1_RX_P[3]"]               ;# Bank 230 - MGTFRXP2_230
set_property PACKAGE_PIN R1                  [get_ports "QSFPDD1_RX_N[4]"]               ;# Bank 230 - MGTFRXN3_230
set_property PACKAGE_PIN R2                  [get_ports "QSFPDD1_RX_P[4]"]               ;# Bank 230 - MGTFRXP3_230
set_property PACKAGE_PIN Y8                  [get_ports "QSFPDD1_TX_N[1]"]               ;# Bank 230 - MGTFTXN0_230
set_property PACKAGE_PIN Y9                  [get_ports "QSFPDD1_TX_P[1]"]               ;# Bank 230 - MGTFTXP0_230
set_property PACKAGE_PIN W6                  [get_ports "QSFPDD1_TX_N[2]"]               ;# Bank 230 - MGTFTXN1_230
set_property PACKAGE_PIN W7                  [get_ports "QSFPDD1_TX_P[2]"]               ;# Bank 230 - MGTFTXP1_230
set_property PACKAGE_PIN V8                  [get_ports "QSFPDD1_TX_N[3]"]               ;# Bank 230 - MGTFTXN2_230
set_property PACKAGE_PIN V9                  [get_ports "QSFPDD1_TX_P[3]"]               ;# Bank 230 - MGTFTXP2_230
set_property PACKAGE_PIN U6                  [get_ports "QSFPDD1_TX_N[4]"]               ;# Bank 230 - MGTFTXN3_230
set_property PACKAGE_PIN U7                  [get_ports "QSFPDD1_TX_P[4]"]               ;# Bank 230 - MGTFTXP3_230

set_property PACKAGE_PIN N10                 [get_ports "SYNCE_CLK15_LVDS_N"]            ;# Bank 231 - MGTREFCLK0N_231
set_property PACKAGE_PIN N11                 [get_ports "SYNCE_CLK15_LVDS_P"]            ;# Bank 231 - MGTREFCLK0P_231
set_property PACKAGE_PIN P3                  [get_ports "QSFPDD1_RX_N[5]"]               ;# Bank 231 - MGTFRXN0_231
set_property PACKAGE_PIN P4                  [get_ports "QSFPDD1_RX_P[5]"]               ;# Bank 231 - MGTFRXP0_231
set_property PACKAGE_PIN N1                  [get_ports "QSFPDD1_RX_N[6]"]               ;# Bank 231 - MGTFRXN1_231
set_property PACKAGE_PIN N2                  [get_ports "QSFPDD1_RX_P[6]"]               ;# Bank 231 - MGTFRXP1_231
set_property PACKAGE_PIN M3                  [get_ports "QSFPDD1_RX_N[7]"]               ;# Bank 231 - MGTFRXN2_231
set_property PACKAGE_PIN M4                  [get_ports "QSFPDD1_RX_P[7]"]               ;# Bank 231 - MGTFRXP2_231
set_property PACKAGE_PIN L1                  [get_ports "QSFPDD1_RX_N[8]"]               ;# Bank 231 - MGTFRXN3_231
set_property PACKAGE_PIN L2                  [get_ports "QSFPDD1_RX_P[8]"]               ;# Bank 231 - MGTFRXP3_231
set_property PACKAGE_PIN T8                  [get_ports "QSFPDD1_TX_N[5]"]               ;# Bank 231 - MGTFTXN0_231
set_property PACKAGE_PIN T9                  [get_ports "QSFPDD1_TX_P[5]"]               ;# Bank 231 - MGTFTXP0_231
set_property PACKAGE_PIN R6                  [get_ports "QSFPDD1_TX_N[6]"]               ;# Bank 231 - MGTFTXN1_231
set_property PACKAGE_PIN R7                  [get_ports "QSFPDD1_TX_P[6]"]               ;# Bank 231 - MGTFTXP1_231
set_property PACKAGE_PIN P8                  [get_ports "QSFPDD1_TX_N[7]"]               ;# Bank 231 - MGTFTXN2_231
set_property PACKAGE_PIN P9                  [get_ports "QSFPDD1_TX_P[7]"]               ;# Bank 231 - MGTFTXP2_231
set_property PACKAGE_PIN N6                  [get_ports "QSFPDD1_TX_N[8]"]               ;# Bank 231 - MGTFTXN3_231
set_property PACKAGE_PIN N7                  [get_ports "QSFPDD1_TX_P[8]"]               ;# Bank 231 - MGTFTXP3_231

#
#  QSFPDD 2 GTF Connections - Bank 228, 229
#    Typical pin constraints are embedded in the IP
#
set_property PACKAGE_PIN AE10                [get_ports "SYNCE_CLK12_LVDS_N"]            ;# Bank 228 - MGTREFCLK0N_228
set_property PACKAGE_PIN AE11                [get_ports "SYNCE_CLK12_LVDS_P"]            ;# Bank 228 - MGTREFCLK0P_228
set_property PACKAGE_PIN AF3                 [get_ports "QSFPDD2_RX_N[1]"]               ;# Bank 228 - MGTFRXN0_228
set_property PACKAGE_PIN AF4                 [get_ports "QSFPDD2_RX_P[1]"]               ;# Bank 228 - MGTFRXP0_228
set_property PACKAGE_PIN AE1                 [get_ports "QSFPDD2_RX_N[2]"]               ;# Bank 228 - MGTFRXN1_228
set_property PACKAGE_PIN AE2                 [get_ports "QSFPDD2_RX_P[2]"]               ;# Bank 228 - MGTFRXP1_228
set_property PACKAGE_PIN AD3                 [get_ports "QSFPDD2_RX_N[3]"]               ;# Bank 228 - MGTFRXN2_228
set_property PACKAGE_PIN AD4                 [get_ports "QSFPDD2_RX_P[3]"]               ;# Bank 228 - MGTFRXP2_228
set_property PACKAGE_PIN AC1                 [get_ports "QSFPDD2_RX_N[4]"]               ;# Bank 228 - MGTFRXN3_228
set_property PACKAGE_PIN AC2                 [get_ports "QSFPDD2_RX_P[4]"]               ;# Bank 228 - MGTFRXP3_228
set_property PACKAGE_PIN AH8                 [get_ports "QSFPDD2_TX_N[1]"]               ;# Bank 228 - MGTFTXN0_228
set_property PACKAGE_PIN AH9                 [get_ports "QSFPDD2_TX_P[1]"]               ;# Bank 228 - MGTFTXP0_228
set_property PACKAGE_PIN AG6                 [get_ports "QSFPDD2_TX_N[2]"]               ;# Bank 228 - MGTFTXN1_228
set_property PACKAGE_PIN AG7                 [get_ports "QSFPDD2_TX_P[2]"]               ;# Bank 228 - MGTFTXP1_228
set_property PACKAGE_PIN AF8                 [get_ports "QSFPDD2_TX_N[3]"]               ;# Bank 228 - MGTFTXN2_228
set_property PACKAGE_PIN AF9                 [get_ports "QSFPDD2_TX_P[3]"]               ;# Bank 228 - MGTFTXP2_228
set_property PACKAGE_PIN AE6                 [get_ports "QSFPDD2_TX_N[4]"]               ;# Bank 228 - MGTFTXN3_228
set_property PACKAGE_PIN AE7                 [get_ports "QSFPDD2_TX_P[4]"]               ;# Bank 228 - MGTFTXP3_228

set_property PACKAGE_PIN AA10                [get_ports "SYNCE_CLK13_LVDS_N"]            ;# Bank 229 - MGTREFCLK0N_229
set_property PACKAGE_PIN AA11                [get_ports "SYNCE_CLK13_LVDS_P"]            ;# Bank 229 - MGTREFCLK0P_229
set_property PACKAGE_PIN AB3                 [get_ports "QSFPDD2_RX_N[5]"]               ;# Bank 229 - MGTFRXN0_229
set_property PACKAGE_PIN AB4                 [get_ports "QSFPDD2_RX_P[5]"]               ;# Bank 229 - MGTFRXP0_229
set_property PACKAGE_PIN AA1                 [get_ports "QSFPDD2_RX_N[6]"]               ;# Bank 229 - MGTFRXN1_229
set_property PACKAGE_PIN AA2                 [get_ports "QSFPDD2_RX_P[6]"]               ;# Bank 229 - MGTFRXP1_229
set_property PACKAGE_PIN Y3                  [get_ports "QSFPDD2_RX_N[7]"]               ;# Bank 229 - MGTFRXN2_229
set_property PACKAGE_PIN Y4                  [get_ports "QSFPDD2_RX_P[7]"]               ;# Bank 229 - MGTFRXP2_229
set_property PACKAGE_PIN W1                  [get_ports "QSFPDD2_RX_N[8]"]               ;# Bank 229 - MGTFRXN3_229
set_property PACKAGE_PIN W2                  [get_ports "QSFPDD2_RX_P[8]"]               ;# Bank 229 - MGTFRXP3_229
set_property PACKAGE_PIN AD8                 [get_ports "QSFPDD2_TX_N[5]"]               ;# Bank 229 - MGTFTXN0_229
set_property PACKAGE_PIN AD9                 [get_ports "QSFPDD2_TX_P[5]"]               ;# Bank 229 - MGTFTXP0_229
set_property PACKAGE_PIN AC6                 [get_ports "QSFPDD2_TX_N[6]"]               ;# Bank 229 - MGTFTXN1_229
set_property PACKAGE_PIN AC7                 [get_ports "QSFPDD2_TX_P[6]"]               ;# Bank 229 - MGTFTXP1_229
set_property PACKAGE_PIN AB8                 [get_ports "QSFPDD2_TX_N[7]"]               ;# Bank 229 - MGTFTXN2_229
set_property PACKAGE_PIN AB9                 [get_ports "QSFPDD2_TX_P[7]"]               ;# Bank 229 - MGTFTXP2_229
set_property PACKAGE_PIN AA6                 [get_ports "QSFPDD2_TX_N[8]"]               ;# Bank 229 - MGTFTXN3_229
set_property PACKAGE_PIN AA7                 [get_ports "QSFPDD2_TX_P[8]"]               ;# Bank 229 - MGTFTXP3_229

#
#  QSFPDD 3 GTF Connections - Bank 226, 227
#    Typical pin constraints are embedded in the IP
#
set_property PACKAGE_PIN AJ10                [get_ports "SYNCE_CLK11_LVDS_N"]            ;# Bank 227 - MGTREFCLK0N_227
set_property PACKAGE_PIN AJ11                [get_ports "SYNCE_CLK11_LVDS_P"]            ;# Bank 227 - MGTREFCLK0P_227
set_property PACKAGE_PIN AK3                 [get_ports "QSFPDD3_RX_N[1]"]               ;# Bank 227 - MGTFRXN0_227
set_property PACKAGE_PIN AK4                 [get_ports "QSFPDD3_RX_P[1]"]               ;# Bank 227 - MGTFRXP0_227
set_property PACKAGE_PIN AJ1                 [get_ports "QSFPDD3_RX_N[2]"]               ;# Bank 227 - MGTFRXN1_227
set_property PACKAGE_PIN AJ2                 [get_ports "QSFPDD3_RX_P[2]"]               ;# Bank 227 - MGTFRXP1_227
set_property PACKAGE_PIN AH3                 [get_ports "QSFPDD3_RX_N[3]"]               ;# Bank 227 - MGTFRXN2_227
set_property PACKAGE_PIN AH4                 [get_ports "QSFPDD3_RX_P[3]"]               ;# Bank 227 - MGTFRXP2_227
set_property PACKAGE_PIN AG1                 [get_ports "QSFPDD3_RX_N[4]"]               ;# Bank 227 - MGTFRXN3_227
set_property PACKAGE_PIN AG2                 [get_ports "QSFPDD3_RX_P[4]"]               ;# Bank 227 - MGTFRXP3_227
set_property PACKAGE_PIN AM8                 [get_ports "QSFPDD3_TX_N[1]"]               ;# Bank 227 - MGTFTXN0_227
set_property PACKAGE_PIN AM9                 [get_ports "QSFPDD3_TX_P[1]"]               ;# Bank 227 - MGTFTXP0_227
set_property PACKAGE_PIN AL6                 [get_ports "QSFPDD3_TX_N[2]"]               ;# Bank 227 - MGTFTXN1_227
set_property PACKAGE_PIN AL7                 [get_ports "QSFPDD3_TX_P[2]"]               ;# Bank 227 - MGTFTXP1_227
set_property PACKAGE_PIN AK8                 [get_ports "QSFPDD3_TX_N[3]"]               ;# Bank 227 - MGTFTXN2_227
set_property PACKAGE_PIN AK9                 [get_ports "QSFPDD3_TX_P[3]"]               ;# Bank 227 - MGTFTXP2_227
set_property PACKAGE_PIN AJ6                 [get_ports "QSFPDD3_TX_N[4]"]               ;# Bank 227 - MGTFTXN3_227
set_property PACKAGE_PIN AJ7                 [get_ports "QSFPDD3_TX_P[4]"]               ;# Bank 227 - MGTFTXP3_227

set_property PACKAGE_PIN AN10                [get_ports "SYNCE_CLK10_LVDS_N"]            ;# Bank 226 - MGTREFCLK0N_226
set_property PACKAGE_PIN AN11                [get_ports "SYNCE_CLK10_LVDS_P"]            ;# Bank 226 - MGTREFCLK0P_226
set_property PACKAGE_PIN AP3                 [get_ports "QSFPDD3_RX_N[5]"]               ;# Bank 226 - MGTFRXN0_226
set_property PACKAGE_PIN AP4                 [get_ports "QSFPDD3_RX_P[5]"]               ;# Bank 226 - MGTFRXP0_226
set_property PACKAGE_PIN AN1                 [get_ports "QSFPDD3_RX_N[6]"]               ;# Bank 226 - MGTFRXN1_226
set_property PACKAGE_PIN AN2                 [get_ports "QSFPDD3_RX_P[6]"]               ;# Bank 226 - MGTFRXP1_226
set_property PACKAGE_PIN AM3                 [get_ports "QSFPDD3_RX_N[7]"]               ;# Bank 226 - MGTFRXN2_226
set_property PACKAGE_PIN AM4                 [get_ports "QSFPDD3_RX_P[7]"]               ;# Bank 226 - MGTFRXP2_226
set_property PACKAGE_PIN AL1                 [get_ports "QSFPDD3_RX_N[8]"]               ;# Bank 226 - MGTFRXN3_226
set_property PACKAGE_PIN AL2                 [get_ports "QSFPDD3_RX_P[8]"]               ;# Bank 226 - MGTFRXP3_226
set_property PACKAGE_PIN AT8                 [get_ports "QSFPDD3_TX_N[5]"]               ;# Bank 226 - MGTFTXN0_226
set_property PACKAGE_PIN AT9                 [get_ports "QSFPDD3_TX_P[5]"]               ;# Bank 226 - MGTFTXP0_226
set_property PACKAGE_PIN AR6                 [get_ports "QSFPDD3_TX_N[6]"]               ;# Bank 226 - MGTFTXN1_226
set_property PACKAGE_PIN AR7                 [get_ports "QSFPDD3_TX_P[6]"]               ;# Bank 226 - MGTFTXP1_226
set_property PACKAGE_PIN AP8                 [get_ports "QSFPDD3_TX_N[7]"]               ;# Bank 226 - MGTFTXN2_226
set_property PACKAGE_PIN AP9                 [get_ports "QSFPDD3_TX_P[7]"]               ;# Bank 226 - MGTFTXP2_226
set_property PACKAGE_PIN AN6                 [get_ports "QSFPDD3_TX_N[8]"]               ;# Bank 226 - MGTFTXN3_226
set_property PACKAGE_PIN AN7                 [get_ports "QSFPDD3_TX_P[8]"]               ;# Bank 226 - MGTFTXP3_226

#################################################################################
#
#  ARF6 MGTF Interfaces...
#
#################################################################################

#
#  ARF I2C Interface to J10 & J5, Bank 93 (3.3V), External Pullup
#
set_property PACKAGE_PIN M14                 [get_ports "ARF_I2C_SCL"]                   ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L2P_AD14P_93
set_property IOSTANDARD  LVCMOS33            [get_ports "ARF_I2C_SCL"]                   ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L2P_AD14P_93
set_property PACKAGE_PIN M13                 [get_ports "ARF_I2C_SDA"]                   ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L2N_AD14N_93
set_property IOSTANDARD  LVCMOS33            [get_ports "ARF_I2C_SDA"]                   ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L2N_AD14N_93
                                                                                         
#                                                                                        
#  ARF Reset and Selects to J10 & J5, Bank 93 (3.3V), External Pullups                   
#                                                                                        
set_property PACKAGE_PIN K15                 [get_ports "ARF_IO0_RST"]                   ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L3N_AD13N_93
set_property IOSTANDARD  LVCMOS33            [get_ports "ARF_IO0_RST"]                   ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L3N_AD13N_93
set_property PACKAGE_PIN L15                 [get_ports "ARF_IO1_RST"]                   ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L3P_AD13P_93
set_property IOSTANDARD  LVCMOS33            [get_ports "ARF_IO1_RST"]                   ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L3P_AD13P_93
set_property PACKAGE_PIN H14                 [get_ports "ARF_IO2_RST"]                   ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L7N_HDGC_93
set_property IOSTANDARD  LVCMOS33            [get_ports "ARF_IO2_RST"]                   ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L7N_HDGC_93
set_property PACKAGE_PIN H13                 [get_ports "ARF_IO3_RST"]                   ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L6N_HDGC_93
set_property IOSTANDARD  LVCMOS33            [get_ports "ARF_IO3_RST"]                   ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L6N_HDGC_93
set_property PACKAGE_PIN K16                 [get_ports "ARF_MUX_RESET"]                 ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L5P_HDGC_93
set_property IOSTANDARD  LVCMOS33            [get_ports "ARF_MUX_RESET"]                 ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L5P_HDGC_93
set_property PACKAGE_PIN L13                 [get_ports "ARF_MUX_INTN"]                  ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L1P_AD15P_93
set_property IOSTANDARD  LVCMOS33            [get_ports "ARF_MUX_INTN"]                  ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L1P_AD15P_93

#
#  ARF 0 GTF Connections to Expansion Connector - Bank 132, 133
#    Typical pin constraints are embedded in the IP
#
set_property PACKAGE_PIN D39                 [get_ports "SYNCE_CLK27_LVDS_N"]            ;# Bank 133 - MGTREFCLK0N_133
set_property PACKAGE_PIN D38                 [get_ports "SYNCE_CLK27_LVDS_P"]            ;# Bank 133 - MGTREFCLK0P_133
set_property PACKAGE_PIN F44                 [get_ports "QSFPDD4_RX_N[1]"]               ;# Bank 133 - MGTFRXN0_133
set_property PACKAGE_PIN F43                 [get_ports "QSFPDD4_RX_P[1]"]               ;# Bank 133 - MGTFRXP0_133
set_property PACKAGE_PIN E46                 [get_ports "QSFPDD4_RX_N[2]"]               ;# Bank 133 - MGTFRXN1_133
set_property PACKAGE_PIN E45                 [get_ports "QSFPDD4_RX_P[2]"]               ;# Bank 133 - MGTFRXP1_133
set_property PACKAGE_PIN D44                 [get_ports "QSFPDD4_RX_N[3]"]               ;# Bank 133 - MGTFRXN2_133
set_property PACKAGE_PIN D43                 [get_ports "QSFPDD4_RX_P[3]"]               ;# Bank 133 - MGTFRXP2_133
set_property PACKAGE_PIN B44                 [get_ports "QSFPDD4_RX_N[4]"]               ;# Bank 133 - MGTFRXN3_133
set_property PACKAGE_PIN B43                 [get_ports "QSFPDD4_RX_P[4]"]               ;# Bank 133 - MGTFRXP3_133
set_property PACKAGE_PIN G41                 [get_ports "QSFPDD4_TX_N[1]"]               ;# Bank 133 - MGTFTXN0_133
set_property PACKAGE_PIN G40                 [get_ports "QSFPDD4_TX_P[1]"]               ;# Bank 133 - MGTFTXP0_133
set_property PACKAGE_PIN E41                 [get_ports "QSFPDD4_TX_N[2]"]               ;# Bank 133 - MGTFTXN1_133
set_property PACKAGE_PIN E40                 [get_ports "QSFPDD4_TX_P[2]"]               ;# Bank 133 - MGTFTXP1_133
set_property PACKAGE_PIN C41                 [get_ports "QSFPDD4_TX_N[3]"]               ;# Bank 133 - MGTFTXN2_133
set_property PACKAGE_PIN C40                 [get_ports "QSFPDD4_TX_P[3]"]               ;# Bank 133 - MGTFTXP2_133
set_property PACKAGE_PIN A41                 [get_ports "QSFPDD4_TX_N[4]"]               ;# Bank 133 - MGTFTXN3_133
set_property PACKAGE_PIN A40                 [get_ports "QSFPDD4_TX_P[4]"]               ;# Bank 133 - MGTFTXP3_133

set_property PACKAGE_PIN H39                 [get_ports "SYNCE_CLK26_LVDS_N"]            ;# Bank 132 - MGTREFCLK0N_132
set_property PACKAGE_PIN H38                 [get_ports "SYNCE_CLK26_LVDS_P"]            ;# Bank 132 - MGTREFCLK0P_132
set_property PACKAGE_PIN K44                 [get_ports "QSFPDD4_RX_N[5]"]               ;# Bank 132 - MGTFRXN0_132
set_property PACKAGE_PIN K43                 [get_ports "QSFPDD4_RX_P[5]"]               ;# Bank 132 - MGTFRXP0_132
set_property PACKAGE_PIN J46                 [get_ports "QSFPDD4_RX_N[6]"]               ;# Bank 132 - MGTFRXN1_132
set_property PACKAGE_PIN J45                 [get_ports "QSFPDD4_RX_P[6]"]               ;# Bank 132 - MGTFRXP1_132
set_property PACKAGE_PIN H44                 [get_ports "QSFPDD4_RX_N[7]"]               ;# Bank 132 - MGTFRXN2_132
set_property PACKAGE_PIN H43                 [get_ports "QSFPDD4_RX_P[7]"]               ;# Bank 132 - MGTFRXP2_132
set_property PACKAGE_PIN G46                 [get_ports "QSFPDD4_RX_N[8]"]               ;# Bank 132 - MGTFRXN3_132
set_property PACKAGE_PIN G45                 [get_ports "QSFPDD4_RX_P[8]"]               ;# Bank 132 - MGTFRXP3_132
set_property PACKAGE_PIN M39                 [get_ports "QSFPDD4_TX_N[5]"]               ;# Bank 132 - MGTFTXN0_132
set_property PACKAGE_PIN M38                 [get_ports "QSFPDD4_TX_P[5]"]               ;# Bank 132 - MGTFTXP0_132
set_property PACKAGE_PIN L41                 [get_ports "QSFPDD4_TX_N[6]"]               ;# Bank 132 - MGTFTXN1_132
set_property PACKAGE_PIN L40                 [get_ports "QSFPDD4_TX_P[6]"]               ;# Bank 132 - MGTFTXP1_132
set_property PACKAGE_PIN K39                 [get_ports "QSFPDD4_TX_N[7]"]               ;# Bank 132 - MGTFTXN2_132
set_property PACKAGE_PIN K38                 [get_ports "QSFPDD4_TX_P[7]"]               ;# Bank 132 - MGTFTXP2_132
set_property PACKAGE_PIN J41                 [get_ports "QSFPDD4_TX_N[8]"]               ;# Bank 132 - MGTFTXN3_132
set_property PACKAGE_PIN J40                 [get_ports "QSFPDD4_TX_P[8]"]               ;# Bank 132 - MGTFTXP3_132

#
#  ARF 1 GTF Connections to Expansion Connector - Bank 130, 131
#    Typical pin constraints are embedded in the IP
#
set_property PACKAGE_PIN L37                 [get_ports "SYNCE_CLK25_LVDS_N"]            ;# Bank 131 - MGTREFCLK0N_131
set_property PACKAGE_PIN L36                 [get_ports "SYNCE_CLK25_LVDS_P"]            ;# Bank 131 - MGTREFCLK0P_131
set_property PACKAGE_PIN P44                 [get_ports "QSFPDD5_RX_N[1]"]               ;# Bank 131 - MGTFRXN0_131
set_property PACKAGE_PIN P43                 [get_ports "QSFPDD5_RX_P[1]"]               ;# Bank 131 - MGTFRXP0_131
set_property PACKAGE_PIN N46                 [get_ports "QSFPDD5_RX_N[2]"]               ;# Bank 131 - MGTFRXN1_131
set_property PACKAGE_PIN N45                 [get_ports "QSFPDD5_RX_P[2]"]               ;# Bank 131 - MGTFRXP1_131
set_property PACKAGE_PIN M44                 [get_ports "QSFPDD5_RX_N[3]"]               ;# Bank 131 - MGTFRXN2_131
set_property PACKAGE_PIN M43                 [get_ports "QSFPDD5_RX_P[3]"]               ;# Bank 131 - MGTFRXP2_131
set_property PACKAGE_PIN L46                 [get_ports "QSFPDD5_RX_N[4]"]               ;# Bank 131 - MGTFRXN3_131
set_property PACKAGE_PIN L45                 [get_ports "QSFPDD5_RX_P[4]"]               ;# Bank 131 - MGTFRXP3_131
set_property PACKAGE_PIN T39                 [get_ports "QSFPDD5_TX_N[1]"]               ;# Bank 131 - MGTFTXN0_131
set_property PACKAGE_PIN T38                 [get_ports "QSFPDD5_TX_P[1]"]               ;# Bank 131 - MGTFTXP0_131
set_property PACKAGE_PIN R41                 [get_ports "QSFPDD5_TX_N[2]"]               ;# Bank 131 - MGTFTXN1_131
set_property PACKAGE_PIN R40                 [get_ports "QSFPDD5_TX_P[2]"]               ;# Bank 131 - MGTFTXP1_131
set_property PACKAGE_PIN P39                 [get_ports "QSFPDD5_TX_N[3]"]               ;# Bank 131 - MGTFTXN2_131
set_property PACKAGE_PIN P38                 [get_ports "QSFPDD5_TX_P[3]"]               ;# Bank 131 - MGTFTXP2_131
set_property PACKAGE_PIN N41                 [get_ports "QSFPDD5_TX_N[4]"]               ;# Bank 131 - MGTFTXN3_131
set_property PACKAGE_PIN N40                 [get_ports "QSFPDD5_TX_P[4]"]               ;# Bank 131 - MGTFTXP3_131

set_property PACKAGE_PIN R37                 [get_ports "SYNCE_CLK24_LVDS_N"]            ;# Bank 130 - MGTREFCLK0N_130
set_property PACKAGE_PIN R36                 [get_ports "SYNCE_CLK24_LVDS_P"]            ;# Bank 130 - MGTREFCLK0P_130
set_property PACKAGE_PIN V44                 [get_ports "QSFPDD5_RX_N[5]"]               ;# Bank 130 - MGTFRXN0_130
set_property PACKAGE_PIN V43                 [get_ports "QSFPDD5_RX_P[5]"]               ;# Bank 130 - MGTFRXP0_130
set_property PACKAGE_PIN U46                 [get_ports "QSFPDD5_RX_N[6]"]               ;# Bank 130 - MGTFRXN1_130
set_property PACKAGE_PIN U45                 [get_ports "QSFPDD5_RX_P[6]"]               ;# Bank 130 - MGTFRXP1_130
set_property PACKAGE_PIN T44                 [get_ports "QSFPDD5_RX_N[7]"]               ;# Bank 130 - MGTFRXN2_130
set_property PACKAGE_PIN T43                 [get_ports "QSFPDD5_RX_P[7]"]               ;# Bank 130 - MGTFRXP2_130
set_property PACKAGE_PIN R46                 [get_ports "QSFPDD5_RX_N[8]"]               ;# Bank 130 - MGTFRXN3_130
set_property PACKAGE_PIN R45                 [get_ports "QSFPDD5_RX_P[8]"]               ;# Bank 130 - MGTFRXP3_130
set_property PACKAGE_PIN Y39                 [get_ports "QSFPDD5_TX_N[5]"]               ;# Bank 130 - MGTFTXN0_130
set_property PACKAGE_PIN Y38                 [get_ports "QSFPDD5_TX_P[5]"]               ;# Bank 130 - MGTFTXP0_130
set_property PACKAGE_PIN W41                 [get_ports "QSFPDD5_TX_N[6]"]               ;# Bank 130 - MGTFTXN1_130
set_property PACKAGE_PIN W40                 [get_ports "QSFPDD5_TX_P[6]"]               ;# Bank 130 - MGTFTXP1_130
set_property PACKAGE_PIN V39                 [get_ports "QSFPDD5_TX_N[7]"]               ;# Bank 130 - MGTFTXN2_130
set_property PACKAGE_PIN V38                 [get_ports "QSFPDD5_TX_P[7]"]               ;# Bank 130 - MGTFTXP2_130
set_property PACKAGE_PIN U41                 [get_ports "QSFPDD5_TX_N[8]"]               ;# Bank 130 - MGTFTXN3_130
set_property PACKAGE_PIN U40                 [get_ports "QSFPDD5_TX_P[8]"]               ;# Bank 130 - MGTFTXP3_130

#
#  ARF 2  GTF Connections to Expansion Connector - Bank 128, 129
#    Typical pin constraints are embedded in the IP
#
set_property PACKAGE_PIN W37                 [get_ports "SYNCE_CLK23_LVDS_N"]            ;# Bank 129 - MGTREFCLK0N_129
set_property PACKAGE_PIN W36                 [get_ports "SYNCE_CLK23_LVDS_P"]            ;# Bank 129 - MGTREFCLK0P_129
set_property PACKAGE_PIN AB44                [get_ports "QSFPDD6_RX_N[1]"]               ;# Bank 129 - MGTFRXN0_129
set_property PACKAGE_PIN AB43                [get_ports "QSFPDD6_RX_P[1]"]               ;# Bank 129 - MGTFRXP0_129
set_property PACKAGE_PIN AA46                [get_ports "QSFPDD6_RX_N[2]"]               ;# Bank 129 - MGTFRXN1_129
set_property PACKAGE_PIN AA45                [get_ports "QSFPDD6_RX_P[2]"]               ;# Bank 129 - MGTFRXP1_129
set_property PACKAGE_PIN Y44                 [get_ports "QSFPDD6_RX_N[3]"]               ;# Bank 129 - MGTFRXN2_129
set_property PACKAGE_PIN Y43                 [get_ports "QSFPDD6_RX_P[3]"]               ;# Bank 129 - MGTFRXP2_129
set_property PACKAGE_PIN W46                 [get_ports "QSFPDD6_RX_N[4]"]               ;# Bank 129 - MGTFRXN3_129
set_property PACKAGE_PIN W45                 [get_ports "QSFPDD6_RX_P[4]"]               ;# Bank 129 - MGTFRXP3_129
set_property PACKAGE_PIN AD39                [get_ports "QSFPDD6_TX_N[1]"]               ;# Bank 129 - MGTFTXN0_129
set_property PACKAGE_PIN AD38                [get_ports "QSFPDD6_TX_P[1]"]               ;# Bank 129 - MGTFTXP0_129
set_property PACKAGE_PIN AC41                [get_ports "QSFPDD6_TX_N[2]"]               ;# Bank 129 - MGTFTXN1_129
set_property PACKAGE_PIN AC40                [get_ports "QSFPDD6_TX_P[2]"]               ;# Bank 129 - MGTFTXP1_129
set_property PACKAGE_PIN AB39                [get_ports "QSFPDD6_TX_N[3]"]               ;# Bank 129 - MGTFTXN2_129
set_property PACKAGE_PIN AB38                [get_ports "QSFPDD6_TX_P[3]"]               ;# Bank 129 - MGTFTXP2_129
set_property PACKAGE_PIN AA41                [get_ports "QSFPDD6_TX_N[4]"]               ;# Bank 129 - MGTFTXN3_129
set_property PACKAGE_PIN AA40                [get_ports "QSFPDD6_TX_P[4]"]               ;# Bank 129 - MGTFTXP3_129

set_property PACKAGE_PIN AC37                [get_ports "SYNCE_CLK22_LVDS_N"]            ;# Bank 128 - MGTREFCLK0N_128
set_property PACKAGE_PIN AC36                [get_ports "SYNCE_CLK22_LVDS_P"]            ;# Bank 128 - MGTREFCLK0P_128
set_property PACKAGE_PIN AF44                [get_ports "QSFPDD6_RX_N[5]"]               ;# Bank 128 - MGTFRXN0_128
set_property PACKAGE_PIN AF43                [get_ports "QSFPDD6_RX_P[5]"]               ;# Bank 128 - MGTFRXP0_128
set_property PACKAGE_PIN AE46                [get_ports "QSFPDD6_RX_N[6]"]               ;# Bank 128 - MGTFRXN1_128
set_property PACKAGE_PIN AE45                [get_ports "QSFPDD6_RX_P[6]"]               ;# Bank 128 - MGTFRXP1_128
set_property PACKAGE_PIN AD44                [get_ports "QSFPDD6_RX_N[7]"]               ;# Bank 128 - MGTFRXN2_128
set_property PACKAGE_PIN AD43                [get_ports "QSFPDD6_RX_P[7]"]               ;# Bank 128 - MGTFRXP2_128
set_property PACKAGE_PIN AC46                [get_ports "QSFPDD6_RX_N[8]"]               ;# Bank 128 - MGTFRXN3_128
set_property PACKAGE_PIN AC45                [get_ports "QSFPDD6_RX_P[8]"]               ;# Bank 128 - MGTFRXP3_128
set_property PACKAGE_PIN AH39                [get_ports "QSFPDD6_TX_N[5]"]               ;# Bank 128 - MGTFTXN0_128
set_property PACKAGE_PIN AH38                [get_ports "QSFPDD6_TX_P[5]"]               ;# Bank 128 - MGTFTXP0_128
set_property PACKAGE_PIN AG41                [get_ports "QSFPDD6_TX_N[6]"]               ;# Bank 128 - MGTFTXN1_128
set_property PACKAGE_PIN AG40                [get_ports "QSFPDD6_TX_P[6]"]               ;# Bank 128 - MGTFTXP1_128
set_property PACKAGE_PIN AF39                [get_ports "QSFPDD6_TX_N[7]"]               ;# Bank 128 - MGTFTXN2_128
set_property PACKAGE_PIN AF38                [get_ports "QSFPDD6_TX_P[7]"]               ;# Bank 128 - MGTFTXP2_128
set_property PACKAGE_PIN AE41                [get_ports "QSFPDD6_TX_N[8]"]               ;# Bank 128 - MGTFTXN3_128
set_property PACKAGE_PIN AE40                [get_ports "QSFPDD6_TX_P[8]"]               ;# Bank 128 - MGTFTXP3_128

#
#  ARF 3 GTF Connections to Expansion Connector - Bank 126, 127
#    Typical pin constraints are embedded in the IP
#
set_property PACKAGE_PIN AG37                [get_ports "SYNCE_CLK21_LVDS_N"]            ;# Bank 127 - MGTREFCLK0N_127
set_property PACKAGE_PIN AG36                [get_ports "SYNCE_CLK21_LVDS_P"]            ;# Bank 127 - MGTREFCLK0P_127
set_property PACKAGE_PIN AK44                [get_ports "QSFPDD7_RX_N[1]"]               ;# Bank 127 - MGTFRXN0_127
set_property PACKAGE_PIN AK43                [get_ports "QSFPDD7_RX_P[1]"]               ;# Bank 127 - MGTFRXP0_127
set_property PACKAGE_PIN AJ46                [get_ports "QSFPDD7_RX_N[2]"]               ;# Bank 127 - MGTFRXN1_127
set_property PACKAGE_PIN AJ45                [get_ports "QSFPDD7_RX_P[2]"]               ;# Bank 127 - MGTFRXP1_127
set_property PACKAGE_PIN AH44                [get_ports "QSFPDD7_RX_N[3]"]               ;# Bank 127 - MGTFRXN2_127
set_property PACKAGE_PIN AH43                [get_ports "QSFPDD7_RX_P[3]"]               ;# Bank 127 - MGTFRXP2_127
set_property PACKAGE_PIN AG46                [get_ports "QSFPDD7_RX_N[4]"]               ;# Bank 127 - MGTFRXN3_127
set_property PACKAGE_PIN AG45                [get_ports "QSFPDD7_RX_P[4]"]               ;# Bank 127 - MGTFRXP3_127
set_property PACKAGE_PIN AM39                [get_ports "QSFPDD7_TX_N[1]"]               ;# Bank 127 - MGTFTXN0_127
set_property PACKAGE_PIN AM38                [get_ports "QSFPDD7_TX_P[1]"]               ;# Bank 127 - MGTFTXP0_127
set_property PACKAGE_PIN AL41                [get_ports "QSFPDD7_TX_N[2]"]               ;# Bank 127 - MGTFTXN1_127
set_property PACKAGE_PIN AL40                [get_ports "QSFPDD7_TX_P[2]"]               ;# Bank 127 - MGTFTXP1_127
set_property PACKAGE_PIN AK39                [get_ports "QSFPDD7_TX_N[3]"]               ;# Bank 127 - MGTFTXN2_127
set_property PACKAGE_PIN AK38                [get_ports "QSFPDD7_TX_P[3]"]               ;# Bank 127 - MGTFTXP2_127
set_property PACKAGE_PIN AJ41                [get_ports "QSFPDD7_TX_N[4]"]               ;# Bank 127 - MGTFTXN3_127
set_property PACKAGE_PIN AJ40                [get_ports "QSFPDD7_TX_P[4]"]               ;# Bank 127 - MGTFTXP3_127

set_property PACKAGE_PIN AL37                [get_ports "SYNCE_CLK20_LVDS_N"]            ;# Bank 126 - MGTREFCLK0N_126
set_property PACKAGE_PIN AL36                [get_ports "SYNCE_CLK20_LVDS_P"]            ;# Bank 126 - MGTREFCLK0P_126
set_property PACKAGE_PIN AP44                [get_ports "QSFPDD7_RX_N[5]"]               ;# Bank 126 - MGTFRXN0_126
set_property PACKAGE_PIN AP43                [get_ports "QSFPDD7_RX_P[5]"]               ;# Bank 126 - MGTFRXP0_126
set_property PACKAGE_PIN AN46                [get_ports "QSFPDD7_RX_N[6]"]               ;# Bank 126 - MGTFRXN1_126
set_property PACKAGE_PIN AN45                [get_ports "QSFPDD7_RX_P[6]"]               ;# Bank 126 - MGTFRXP1_126
set_property PACKAGE_PIN AM44                [get_ports "QSFPDD7_RX_N[7]"]               ;# Bank 126 - MGTFRXN2_126
set_property PACKAGE_PIN AM43                [get_ports "QSFPDD7_RX_P[7]"]               ;# Bank 126 - MGTFRXP2_126
set_property PACKAGE_PIN AL46                [get_ports "QSFPDD7_RX_N[8]"]               ;# Bank 126 - MGTFRXN3_126
set_property PACKAGE_PIN AL45                [get_ports "QSFPDD7_RX_P[8]"]               ;# Bank 126 - MGTFRXP3_126
set_property PACKAGE_PIN AT39                [get_ports "QSFPDD7_TX_N[5]"]               ;# Bank 126 - MGTFTXN0_126
set_property PACKAGE_PIN AT38                [get_ports "QSFPDD7_TX_P[5]"]               ;# Bank 126 - MGTFTXP0_126
set_property PACKAGE_PIN AR41                [get_ports "QSFPDD7_TX_N[6]"]               ;# Bank 126 - MGTFTXN1_126
set_property PACKAGE_PIN AR40                [get_ports "QSFPDD7_TX_P[6]"]               ;# Bank 126 - MGTFTXP1_126
set_property PACKAGE_PIN AP39                [get_ports "QSFPDD7_TX_N[7]"]               ;# Bank 126 - MGTFTXN2_126
set_property PACKAGE_PIN AP38                [get_ports "QSFPDD7_TX_P[7]"]               ;# Bank 126 - MGTFTXP2_126
set_property PACKAGE_PIN AN41                [get_ports "QSFPDD7_TX_N[8]"]               ;# Bank 126 - MGTFTXN3_126
set_property PACKAGE_PIN AN40                [get_ports "QSFPDD7_TX_P[8]"]               ;# Bank 126 - MGTFTXP3_126



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

#
#  Jitter Cleaner Recovery Clock to FPGA GTF RefClock Input, Banks 129, 130, 229, 231 (1.5V)
#    Typical pin constraints are embedded in the IP
#
set_property PACKAGE_PIN W10                 [get_ports "RECOV_CLK12_LVDS_N"]          ;# Bank 229 - MGTREFCLK1N_229
set_property PACKAGE_PIN W11                 [get_ports "RECOV_CLK12_LVDS_P"]          ;# Bank 229 - MGTREFCLK1P_229
set_property PACKAGE_PIN J10                 [get_ports "RECOV_CLK13_LVDS_N"]          ;# Bank 231 - MGTREFCLK1N_231
set_property PACKAGE_PIN J11                 [get_ports "RECOV_CLK13_LVDS_P"]          ;# Bank 231 - MGTREFCLK1P_231

set_property PACKAGE_PIN U37                 [get_ports "RECOV_CLK22_LVDS_N"]          ;# Bank 129 - MGTREFCLK1N_129
set_property PACKAGE_PIN U36                 [get_ports "RECOV_CLK22_LVDS_P"]          ;# Bank 129 - MGTREFCLK1P_129
set_property PACKAGE_PIN N37                 [get_ports "RECOV_CLK23_LVDS_N"]          ;# Bank 130 - MGTREFCLK1N_130
set_property PACKAGE_PIN N36                 [get_ports "RECOV_CLK23_LVDS_P"]          ;# Bank 130 - MGTREFCLK1P_130

#
#  Jitter Cleaner Recovery Clocks to FPGA HDIO Input, Banks 65 (1.8V)
#
set_property PACKAGE_PIN BF18                [get_ports "RECOV_CLK10_LVDS_N"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L3N_T0L_N5_AD15N_A27_65
set_property IOSTANDARD  LVDS                [get_ports "RECOV_CLK10_LVDS_N"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L3N_T0L_N5_AD15N_A27_65
set_property PACKAGE_PIN BE18                [get_ports "RECOV_CLK10_LVDS_P"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L3P_T0L_N4_AD15P_A26_65
set_property IOSTANDARD  LVDS                [get_ports "RECOV_CLK10_LVDS_P"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L3P_T0L_N4_AD15P_A26_65
set_property PACKAGE_PIN BF19                [get_ports "RECOV_CLK11_LVDS_N"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L4N_T0U_N7_DBC_AD7N_A25_65
set_property IOSTANDARD  LVDS                [get_ports "RECOV_CLK11_LVDS_N"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L4N_T0U_N7_DBC_AD7N_A25_65
set_property PACKAGE_PIN BF20                [get_ports "RECOV_CLK11_LVDS_P"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L4P_T0U_N6_DBC_AD7P_A24_65
set_property IOSTANDARD  LVDS                [get_ports "RECOV_CLK11_LVDS_P"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L4P_T0U_N6_DBC_AD7P_A24_65

set_property PACKAGE_PIN BD19                [get_ports "RECOV_CLK20_LVDS_N"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L6N_T0U_N11_AD6N_A21_65
set_property IOSTANDARD  LVDS                [get_ports "RECOV_CLK20_LVDS_N"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L6N_T0U_N11_AD6N_A21_65
set_property PACKAGE_PIN BC19                [get_ports "RECOV_CLK20_LVDS_P"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L6P_T0U_N10_AD6P_A20_65
set_property IOSTANDARD  LVDS                [get_ports "RECOV_CLK20_LVDS_P"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L6P_T0U_N10_AD6P_A20_65
set_property PACKAGE_PIN BB20                [get_ports "RECOV_CLK21_LVDS_N"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L7N_T1L_N1_QBC_AD13N_A19_65
set_property IOSTANDARD  LVDS                [get_ports "RECOV_CLK21_LVDS_N"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L7N_T1L_N1_QBC_AD13N_A19_65
set_property PACKAGE_PIN BA20                [get_ports "RECOV_CLK21_LVDS_P"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L7P_T1L_N0_QBC_AD13P_A18_65
set_property IOSTANDARD  LVDS                [get_ports "RECOV_CLK21_LVDS_P"]          ;# Bank  65 VCCO - +1V8_SYS                               - IO_L7P_T1L_N0_QBC_AD13P_A18_65



#################################################################################
#
#  Satellite Controller I/F Signals
#
#################################################################################

#  Active Low Interrupt from Satellite Controller to FPGA - Bank 93 (3.3V)
#
set_property PACKAGE_PIN M15                 [get_ports "FPGA_GPIO2"]                  ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L4N_AD12N_93
set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_GPIO2"]                  ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L4N_AD12N_93


#  FPGA UART Interface to Satellite Controller (115200, No parity, 8 bits, 1 stop bit) - Bank 88 (3.3V)
#    FPGA_SUC_RXD  Input from Satellite Controller UART to FPGA
#    FPGA_SUC_RXD  Output from FPGA to Satellite Controller UART
#
set_property PACKAGE_PIN BE15                [get_ports "FPGA_SUC_RXD"]                ;# Bank  88 VCCO - +3V3_SYS_FPGA                          - IO_L2N_AD10N_88
set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_SUC_RXD"]                ;# Bank  88 VCCO - +3V3_SYS_FPGA                          - IO_L2N_AD10N_88
set_property PACKAGE_PIN BD15                [get_ports "FPGA_SUC_TXD"]                ;# Bank  88 VCCO - +3V3_SYS_FPGA                          - IO_L2P_AD10P_88
set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_SUC_TXD"]                ;# Bank  88 VCCO - +3V3_SYS_FPGA                          - IO_L2P_AD10P_88

#
#  FPGA UART Interface to FTDI FT4232 Port 3 of 4 (User selectable Baud) - Bank 88 (3.3V)
#    FPGA_UART2_RXD  Input from FT4232 UART to FPGA
#    FPGA_UART2_TXD  Output from FPGA to FT4232 UART
#
set_property PACKAGE_PIN BB14                [get_ports "FPGA_UART2_RXD"]              ;# Bank  88 VCCO - +3V3_SYS_FPGA                          - IO_L4N_AD8N_88
set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_UART2_RXD"]              ;# Bank  88 VCCO - +3V3_SYS_FPGA                          - IO_L4N_AD8N_88
set_property PACKAGE_PIN BA14                [get_ports "FPGA_UART2_TXD"]              ;# Bank  88 VCCO - +3V3_SYS_FPGA                          - IO_L4P_AD8P_88
set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_UART2_TXD"]              ;# Bank  88 VCCO - +3V3_SYS_FPGA                          - IO_L4P_AD8P_88

#
#  FPGA UART Interface to FTDI FT4232 Port 4 of 4 (User selectable Baud) used by the ADK2 Debug Connector - Bank 88 (3.3V)
#    FPGA_UART1_RXD  Input from FT4232 UART to FPGA
#    FPGA_UART1_TXD  Output from FPGA to FT4232 UART
#
set_property PACKAGE_PIN BD14                [get_ports "FPGA_UART1_RXD"]              ;# Bank  88 VCCO - +3V3_SYS_FPGA                          - IO_L3N_AD9N_88
set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_UART1_RXD"]              ;# Bank  88 VCCO - +3V3_SYS_FPGA                          - IO_L3N_AD9N_88
set_property PACKAGE_PIN BC14                [get_ports "FPGA_UART1_TXD"]              ;# Bank  88 VCCO - +3V3_SYS_FPGA                          - IO_L3P_AD9P_88
set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_UART1_TXD"]              ;# Bank  88 VCCO - +3V3_SYS_FPGA                          - IO_L3P_AD9P_88



#################################################################################
#
#  I2C Interface to ...
#       Jitter Cleaner 1 & 2,
#       Clock Generator,
#       DDR Power Enable I2C I/O Expander
#
#################################################################################

set_property PACKAGE_PIN AR20                [get_ports "CLKGEN_SCL_R"]                ;# Bank  65 VCCO - +1V8_SYS                               - IO_L23P_T3U_N8_I2C_SCLK_65
set_property IOSTANDARD  LVCMOS18            [get_ports "CLKGEN_SCL_R"]                ;# Bank  65 VCCO - +1V8_SYS                               - IO_L23P_T3U_N8_I2C_SCLK_65
set_property PACKAGE_PIN AT20                [get_ports "CLKGEN_SDA_R"]                ;# Bank  65 VCCO - +1V8_SYS                               - IO_L23N_T3U_N9_PERSTN1_I2C_SDA_65
set_property IOSTANDARD  LVCMOS18            [get_ports "CLKGEN_SDA_R"]                ;# Bank  65 VCCO - +1V8_SYS                               - IO_L23N_T3U_N9_PERSTN1_I2C_SDA_65


#################################################################################
#
#  DDR Power Enable I/O Expander Reset
#
#################################################################################

# Active Low Reset to DDR Power Enable I/O Expander - External Pulldown - Bank 65 (1.8V)
set_property PACKAGE_PIN AU19                [get_ports "DDR_PSUIO_RESET"]             ;# Bank  65 VCCO - +1V8_SYS                               - IO_L22N_T3U_N7_DBC_AD0N_D05_65
set_property IOSTANDARD  LVCMOS18            [get_ports "DDR_PSUIO_RESET"]             ;# Bank  65 VCCO - +1V8_SYS                               - IO_L22N_T3U_N7_DBC_AD0N_D05_65


#################################################################################
#
#  QSFPDD I2C Interface...Bank 93 (3.3V)
#
#################################################################################

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

set_property PACKAGE_PIN F13                 [get_ports "FPGA_MUX0_INTN"]              ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L11N_AD9N_93
set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_MUX0_INTN"]              ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L11N_AD9N_93
set_property PACKAGE_PIN F14                 [get_ports "FPGA_MUX1_INTN"]              ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L10N_AD10N_93
set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_MUX1_INTN"]              ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L10N_AD10N_93
set_property PACKAGE_PIN J16                 [get_ports "FPGA_OC_INTN"]                ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L8P_HDGC_93
set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_OC_INTN"]                ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L8P_HDGC_93


#################################################################################
#
#  Clock Generator Connection Signals...Bank 65 (1.8V)
#
#################################################################################

# Active Low Loss of Lock Signal from Clock Generator
set_property PACKAGE_PIN BE16                [get_ports "CLKGEN_APLL_LOL"]             ;# Bank  65 VCCO - +1V8_SYS                               - IO_L1N_T0L_N1_DBC_RS1_65
set_property IOSTANDARD  LVCMOS18            [get_ports "CLKGEN_APLL_LOL"]             ;# Bank  65 VCCO - +1V8_SYS                               - IO_L1N_T0L_N1_DBC_RS1_65

# Active Low Reset Signal to Clock Generator
set_property PACKAGE_PIN AT18                [get_ports "CLKGEN_RST_B_R"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L21N_T3L_N5_AD8N_D07_65
set_property IOSTANDARD  LVCMOS18            [get_ports "CLKGEN_RST_B_R"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L21N_T3L_N5_AD8N_D07_65


#################################################################################
#
#  Miscellaneous Connections....
#
#################################################################################

#
#  PPS Connection - Bank 88 (3.3V)
#     Uncomment following properties if PPS pins used in your design
#
#  -- UL3524 Configuration
#set_property PACKAGE_PIN BF14                [get_ports "PPS_IN_FPGA"]                 ;# Bank  88 VCCO - +3V3_SYS_FPGA                          - IO_L1N_AD11N_88
#set_property IOSTANDARD  LVCMOS33            [get_ports "PPS_IN_FPGA"]                 ;# Bank  88 VCCO - +3V3_SYS_FPGA                          - IO_L1N_AD11N_88

#
#  75Mhz Osc for FPGA Configuration - Bank 65 (1.8V)
#     This pin is meant for configuration, not general use
#
#set_property PACKAGE_PIN AP20                [get_ports "CLK_EMCCLK_75M_BANK65"]       ;# Bank  65 VCCO - +1V8_SYS                               - IO_L24P_T3U_N10_EMCCLK_65
#set_property IOSTANDARD  LVCMOS18            [get_ports "CLK_EMCCLK_75M_BANK65"]       ;# Bank  65 VCCO - +1V8_SYS                               - IO_L24P_T3U_N10_EMCCLK_65

#
#  Probe Point - Bank 65 (1.8V)
#     Uncomment following properties if TESTCLK used in your design
#     TESTCLK is a testpoint on the card and not accessible
#
#set_property PACKAGE_PIN BD16                [get_ports "TESTCLK_OUT"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L1P_T0L_N0_DBC_RS0_65
#set_property IOSTANDARD  LVCMOS18            [get_ports "TESTCLK_OUT"]                 ;# Bank  65 VCCO - +1V8_SYS                               - IO_L1P_T0L_N0_DBC_RS0_65


#################################################################################
#
#  Tied pins not meant for customer designs....
#
#################################################################################

# These pins are listed for reference only as they are externally connected to pull up/down resisters or grounds.  
# They are not to be used for customer design and should be treated with caution.

#set_property PACKAGE_PIN BC46                [get_ports "GND_MGTFRXN0_124"]                  ;# Bank 124 - MGTFRXN0_124
#set_property PACKAGE_PIN BA46                [get_ports "GND_MGTFRXN1_124"]                  ;# Bank 124 - MGTFRXN1_124
#set_property PACKAGE_PIN AY44                [get_ports "GND_MGTFRXN2_124"]                  ;# Bank 124 - MGTFRXN2_124
#set_property PACKAGE_PIN AW46                [get_ports "GND_MGTFRXN3_124"]                  ;# Bank 124 - MGTFRXN3_124

#set_property PACKAGE_PIN BC45                [get_ports "GND_MGTFRXP0_124"]                  ;# Bank 124 - MGTFRXP0_124
#set_property PACKAGE_PIN BA45                [get_ports "GND_MGTFRXP1_124"]                  ;# Bank 124 - MGTFRXP1_124
#set_property PACKAGE_PIN AY43                [get_ports "GND_MGTFRXP2_124"]                  ;# Bank 124 - MGTFRXP2_124
#set_property PACKAGE_PIN AW45                [get_ports "GND_MGTFRXP3_124"]                  ;# Bank 124 - MGTFRXP3_124

#set_property PACKAGE_PIN AV44                [get_ports "GND_MGTFRXN0_125"]                  ;# Bank 125 - MGTFRXN0_125
#set_property PACKAGE_PIN AU46                [get_ports "GND_MGTFRXN1_125"]                  ;# Bank 125 - MGTFRXN1_125
#set_property PACKAGE_PIN AT44                [get_ports "GND_MGTFRXN2_125"]                  ;# Bank 125 - MGTFRXN2_125
#set_property PACKAGE_PIN AR46                [get_ports "GND_MGTFRXN3_125"]                  ;# Bank 125 - MGTFRXN3_125

#set_property PACKAGE_PIN AV43                [get_ports "GND_MGTFRXP0_125"]                  ;# Bank 125 - MGTFRXP0_125
#set_property PACKAGE_PIN AU45                [get_ports "GND_MGTFRXP1_125"]                  ;# Bank 125 - MGTFRXP1_125
#set_property PACKAGE_PIN AT43                [get_ports "GND_MGTFRXP2_125"]                  ;# Bank 125 - MGTFRXP2_125
#set_property PACKAGE_PIN AR45                [get_ports "GND_MGTFRXP3_125"]                  ;# Bank 125 - MGTFRXP3_125

#set_property PACKAGE_PIN AR36                [get_ports "R100_PULLUP_1v2_MGTAVTT_BANK_125"]  ;# Bank 125 - MGTRREF_L                                    
#set_property PACKAGE_PIN L11                 [get_ports "R100_PULLUP_1v2_MGTAVTT_BANK_231"]  ;# Bank 231 - MGTRREF_RN                                   
#set_property PACKAGE_PIN AU11                [get_ports "R100_PULLUP_1v2_MGTAVTT_BANK_225"]  ;# Bank 225 - MGTRREF_RS                                   

#set_property PACKAGE_PIN BD24                [get_ports "R240_PULLDOWN_BANK_66"]             ;# Bank  66 VCCO - 1V2_VCCO                                - IO_T0U_N12_VRP_66
#set_property PACKAGE_PIN BD29                [get_ports "R240_PULLDOWN_BANK_67"]             ;# Bank  67 VCCO - 1V2_VCCO                                - IO_T0U_N12_VRP_67
#set_property PACKAGE_PIN BE33                [get_ports "R240_PULLDOWN_BANK_68"]             ;# Bank  68 VCCO - 1V2_VCCO                                - IO_T0U_N12_VRP_68
#set_property PACKAGE_PIN H18                 [get_ports "R240_PULLDOWN_BANK_73"]             ;# Bank  73 VCCO - +1V5_SYS                                - IO_T0U_N12_VRP_73
#set_property PACKAGE_PIN L22                 [get_ports "R240_PULLDOWN_BANK_72"]             ;# Bank  72 VCCO - +1V5_SYS                                - IO_T0U_N12_VRP_72
#set_property PACKAGE_PIN L32                 [get_ports "R240_PULLDOWN_BANK_70"]             ;# Bank  70 VCCO - +1V5_SYS                                - IO_T0U_N12_VRP_70
#set_property PACKAGE_PIN L27                 [get_ports "R240_PULLDOWN_BANK_71"]             ;# Bank  71 VCCO - +1V5_SYS                                - IO_T0U_N12_VRP_71
