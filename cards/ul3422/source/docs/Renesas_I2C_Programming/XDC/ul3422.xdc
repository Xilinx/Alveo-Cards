# 
# Copyright (C) 2024, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: X11
# 
#
############################################################################
#
#
#   UL3422 - Master XDC
#
#
############################################################################
#	REVISION HISTORY
############################################################################
#
#   Revision: 0.01 (internal)   (08/22/2023)
#		* Two additional reference clock mapped on Bank 65
#       * Two SYNCE clock added on GT Banks 129 & 226
#       * Extra sideband signals on ARF interface are removed
#       * DDR placement not optimized 
#   Revision: 0.00 (internal)   (06/27/2023)
#		* Initial Version from UL3422 Feasibility Study. Released on 27Jun2023
#
#
# This XDC contains the necessary pinout, clock, and configuration information to get started on a design.
# Please see UG1585 for more information on board components including part numbers, I2C bus details, clock and power trees.
#
##################################################################################################################################################################

#
# Bitstream generation
#
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


#################################################################################
#
#  LVDS Input Clock References...
#
#################################################################################

#
#  300 Mhz Reference DDR I/F clock, Bank 66 (1.5V)
#
set_property PACKAGE_PIN    AY22             [get_ports clk_ddr_lvds_300_n]    ;# Bank 66   - 1V2_VCC0  - CLK_DDR_LVDS_300_N        - IO_L13N_T2L_N1_GC_QBC_66_AY22
set_property IOSTANDARD     LVDS             [get_ports clk_ddr_lvds_300_n]    ;# Bank 66   - 1V2_VCC0  - CLK_DDR_LVDS_300_N        - IO_L13N_T2L_N1_GC_QBC_66_AY22
set_property PACKAGE_PIN    AW23             [get_ports clk_ddr_lvds_300_p]    ;# Bank 66   - 1V2_VCC0  - CLK_DDR_LVDS_300_P        - IO_L13P_T2L_N0_GC_QBC_66_AW23
set_property IOSTANDARD     LVDS             [get_ports clk_ddr_lvds_300_p]    ;# Bank 66   - 1V2_VCC0  - CLK_DDR_LVDS_300_P        - IO_L13P_T2L_N0_GC_QBC_66_AW23
                                                                                            
#                                                                                           
#  300 Mhz Reference system clock, Bank 65 (1.8V)                                           
#                                                                                           
set_property PACKAGE_PIN    AW18             [get_ports clk_sys_lvds_300_n]    ;# Bank 65   - 1V8_SYS   - CLK_SYS_LVDS_300_N        - IO_L14N_T2L_N3_GC_A05_D21_65_AW18
set_property IOSTANDARD     LVDS             [get_ports clk_sys_lvds_300_n]    ;# Bank 65   - 1V8_SYS   - CLK_SYS_LVDS_300_N        - IO_L14N_T2L_N3_GC_A05_D21_65_AW18
set_property PACKAGE_PIN    AW19             [get_ports clk_sys_lvds_300_p]    ;# Bank 65   - 1V8_SYS   - CLK_SYS_LVDS_300_P        - IO_L14P_T2L_N2_GC_A04_D20_65_AW19
set_property IOSTANDARD     LVDS             [get_ports clk_sys_lvds_300_p]    ;# Bank 65   - 1V8_SYS   - CLK_SYS_LVDS_300_P        - IO_L14P_T2L_N2_GC_A04_D20_65_AW19


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

set_property PACKAGE_PIN    F12              [get_ports fpga_scl_r]            ;# Bank 93   - 3V3_VCC0  - FPGA_SCL_R                - IO_L12P_AD8P_93_F12
set_property IOSTANDARD     LVCMOS33         [get_ports fpga_scl_r]            ;# Bank 93   - 3V3_VCC0  - FPGA_SCL_R                - IO_L12P_AD8P_93_F12
set_property PACKAGE_PIN    F11              [get_ports fpga_sda_r]            ;# Bank 93   - 3V3_VCC0  - FPGA_SDA_R                - IO_L12N_AD8N_93_F11
set_property IOSTANDARD     LVCMOS33         [get_ports fpga_sda_r]            ;# Bank 93   - 3V3_VCC0  - FPGA_SDA_R                - IO_L12N_AD8N_93_F11
                                                                                                                                    
set_property PACKAGE_PIN    F13              [get_ports fpga_mux_intn]         ;# Bank 93   - 3V3_VCC0  - FPGA_MUX0_INTN            - IO_L11N_AD9N_93_F13
set_property IOSTANDARD     LVCMOS33         [get_ports fpga_mux_intn]         ;# Bank 93   - 3V3_VCC0  - FPGA_MUX0_INTN            - IO_L11N_AD9N_93_F13
set_property PACKAGE_PIN    G14              [get_ports fpga_mux_rstn]         ;# Bank 93   - 3V3_VCC0  - FPGA_MUX_RSTN             - IO_L11P_AD9P_93_G14
set_property IOSTANDARD     LVCMOS33         [get_ports fpga_mux_rstn]         ;# Bank 93   - 3V3_VCC0  - FPGA_MUX_RSTN             - IO_L11P_AD9P_93_G14
set_property PACKAGE_PIN    J16              [get_ports fpga_oc_intn]          ;# Bank 93   - 3V3_VCC0  - FPGA_OC_INTN              - IO_L8P_HDGC_93_J16
set_property IOSTANDARD     LVCMOS33         [get_ports fpga_oc_intn]          ;# Bank 93   - 3V3_VCC0  - FPGA_OC_INTN              - IO_L8P_HDGC_93_J16
set_property PACKAGE_PIN    G15              [get_ports fpga_oc_rstn]          ;# Bank 93   - 3V3_VCC0  - FPGA_OC_RSTN              - IO_L10P_AD10P_93_G15
set_property IOSTANDARD     LVCMOS33         [get_ports fpga_oc_rstn]          ;# Bank 93   - 3V3_VCC0  - FPGA_OC_RSTN              - IO_L10P_AD10P_93_G15
                                                                                                                                    
                                                                                                                                    
#################################################################################                                                   
#                                                                                                                                   
#  QSFP MGTF Interface...                                                                                                           
#                                                                                                                                   
#################################################################################                                                   
                                                                                                                                    
#                                                                                                                                   
#  QSFPDD Resetn Connections - Bank 88 (3.3V)                                                                                       
#     Active Low Reset FPGA Output Signal to I2C I/O Expanders interfacing                                                          
#     to QSFP's Low Speed Interface (LPMODE, INTn, MODPRSTn, MODSELn, RESETn)                                                       
#                                                                                                                                   
set_property PACKAGE_PIN    H16              [get_ports qsfpdd1_io_reset_b]    ;# Bank 93   - 3V3_VCC0  - QSFPDD1_IO_RESET_B        - IO_L8N_HDGC_93_H16
set_property IOSTANDARD     LVCMOS33         [get_ports qsfpdd1_io_reset_b]    ;# Bank 93   - 3V3_VCC0  - QSFPDD1_IO_RESET_B        - IO_L8N_HDGC_93_H16
set_property PACKAGE_PIN    F15              [get_ports qsfpdd2_io_reset_b]    ;# Bank 93   - 3V3_VCC0  - QSFPDD2_IO_RESET_B        - IO_L9N_AD11N_93_F15
set_property IOSTANDARD     LVCMOS33         [get_ports qsfpdd2_io_reset_b]    ;# Bank 93   - 3V3_VCC0  - QSFPDD2_IO_RESET_B        - IO_L9N_AD11N_93_F15
                                                                                                                                    
#                                                                                                                                   
#  Cage LED's Driven by FPGA - Active High, Bank 88 (3.3V)                                                                          
#                                                                                                                                   
set_property PACKAGE_PIN    AP13             [get_ports qsfpdd1_led]           ;# Bank 88   - 1V2_VCC0  - QSFPDD1_LED               - IO_L12P_AD0P_88_AP13
set_property IOSTANDARD     LVCMOS33         [get_ports qsfpdd1_led]           ;# Bank 88   - 1V2_VCC0  - QSFPDD1_LED               - IO_L12P_AD0P_88_AP13
set_property PACKAGE_PIN    AP14             [get_ports qsfpdd2_led]           ;# Bank 88   - 1V2_VCC0  - QSFPDD2_LED               - IO_L11N_AD1N_88_AP14
set_property IOSTANDARD     LVCMOS33         [get_ports qsfpdd2_led]           ;# Bank 88   - 1V2_VCC0  - QSFPDD2_LED               - IO_L11N_AD1N_88_AP14
                                                                                                                                    
#                                                                                                                                   
#  Alternate SYNCE Clock port - Bank 129                                                                                            
#                                                                                                                                   
set_property PACKAGE_PIN    W37              [get_ports synce_clk_129_lvds_n]  ;# Bank 129              - SYNCE_CLK_129_LVDS_N      - MGTREFCLK0N_129_W37
set_property IOSTANDARD     LVDS             [get_ports synce_clk_129_lvds_n]  ;# Bank 129              - SYNCE_CLK_129_LVDS_N      - MGTREFCLK0N_129_W37
set_property PACKAGE_PIN    W36              [get_ports synce_clk_129_lvds_p]  ;# Bank 129              - SYNCE_CLK_129_LVDS_P      - MGTREFCLK0P_129_W36
set_property IOSTANDARD     LVDS             [get_ports synce_clk_129_lvds_p]  ;# Bank 129              - SYNCE_CLK_129_LVDS_P      - MGTREFCLK0P_129_W36
                                                                                                                                    
#                                                                                                                                   
#  QSFPDD 1 GTF Connections - Bank 127, 128                                                                                         
#    Typical pin constraints are embedded in the IP                                                                                 
#                                                                                                                                   
set_property PACKAGE_PIN    AG37             [get_ports synce_clk_127_lvds_n]  ;# Bank 127              - SYNCE_CLK_127_LVDS_N      - MGTREFCLK0N_127_AG37
set_property PACKAGE_PIN    AG36             [get_ports synce_clk_127_lvds_p]  ;# Bank 127              - SYNCE_CLK_127_LVDS_P      - MGTREFCLK0P_127_AG36
set_property PACKAGE_PIN    AK44             [get_ports qsfpdd1_rx1_n]         ;# Bank 127              - QSFPDD1_RX1_N             - MGTFRXN0_127_AK44
set_property PACKAGE_PIN    AK43             [get_ports qsfpdd1_rx1_p]         ;# Bank 127              - QSFPDD1_RX1_P             - MGTFRXP0_127_AK43
set_property PACKAGE_PIN    AJ46             [get_ports qsfpdd1_rx2_n]         ;# Bank 127              - QSFPDD1_RX2_N             - MGTFRXN1_127_AJ46
set_property PACKAGE_PIN    AJ45             [get_ports qsfpdd1_rx2_p]         ;# Bank 127              - QSFPDD1_RX2_P             - MGTFRXP1_127_AJ45
set_property PACKAGE_PIN    AH44             [get_ports qsfpdd1_rx3_n]         ;# Bank 127              - QSFPDD1_RX3_N             - MGTFRXN2_127_AH44
set_property PACKAGE_PIN    AH43             [get_ports qsfpdd1_rx3_p]         ;# Bank 127              - QSFPDD1_RX3_P             - MGTFRXP2_127_AH43
set_property PACKAGE_PIN    AG46             [get_ports qsfpdd1_rx4_n]         ;# Bank 127              - QSFPDD1_RX4_N             - MGTFRXN3_127_AG46
set_property PACKAGE_PIN    AG45             [get_ports qsfpdd1_rx4_p]         ;# Bank 127              - QSFPDD1_RX4_P             - MGTFRXP3_127_AG45
set_property PACKAGE_PIN    AM39             [get_ports qsfpdd1_tx1_n]         ;# Bank 127              - QSFPDD1_TX1_N             - MGTFTXN0_127_AM39
set_property PACKAGE_PIN    AM38             [get_ports qsfpdd1_tx1_p]         ;# Bank 127              - QSFPDD1_TX1_P             - MGTFTXP0_127_AM38
set_property PACKAGE_PIN    AL41             [get_ports qsfpdd1_tx2_n]         ;# Bank 127              - QSFPDD1_TX2_N             - MGTFTXN1_127_AL41
set_property PACKAGE_PIN    AL40             [get_ports qsfpdd1_tx2_p]         ;# Bank 127              - QSFPDD1_TX2_P             - MGTFTXP1_127_AL40
set_property PACKAGE_PIN    AK39             [get_ports qsfpdd1_tx3_n]         ;# Bank 127              - QSFPDD1_TX3_N             - MGTFTXN2_127_AK39
set_property PACKAGE_PIN    AK38             [get_ports qsfpdd1_tx3_p]         ;# Bank 127              - QSFPDD1_TX3_P             - MGTFTXP2_127_AK38
set_property PACKAGE_PIN    AJ41             [get_ports qsfpdd1_tx4_n]         ;# Bank 127              - QSFPDD1_TX4_N             - MGTFTXN3_127_AJ41
set_property PACKAGE_PIN    AJ40             [get_ports qsfpdd1_tx4_p]         ;# Bank 127              - QSFPDD1_TX4_P             - MGTFTXP3_127_AJ40
                                                                                                                                      
                                                                                                                                      
set_property PACKAGE_PIN    AC37             [get_ports synce_clk_128_lvds_n]  ;# Bank 128              - SYNCE_CLK_128_LVDS_N      - MGTREFCLK0N_128_AC37
set_property PACKAGE_PIN    AC36             [get_ports synce_clk_128_lvds_p]  ;# Bank 128              - SYNCE_CLK_128_LVDS_P      - MGTREFCLK0P_128_AC36
set_property PACKAGE_PIN    AF44             [get_ports qsfpdd1_rx5_n]         ;# Bank 128              - QSFPDD1_RX5_N             - MGTFRXN0_128_AF44
set_property PACKAGE_PIN    AF43             [get_ports qsfpdd1_rx5_p]         ;# Bank 128              - QSFPDD1_RX5_P             - MGTFRXP0_128_AF43
set_property PACKAGE_PIN    AE46             [get_ports qsfpdd1_rx6_n]         ;# Bank 128              - QSFPDD1_RX6_N             - MGTFRXN1_128_AE46
set_property PACKAGE_PIN    AE45             [get_ports qsfpdd1_rx6_p]         ;# Bank 128              - QSFPDD1_RX6_P             - MGTFRXP1_128_AE45
set_property PACKAGE_PIN    AD44             [get_ports qsfpdd1_rx7_n]         ;# Bank 128              - QSFPDD1_RX7_N             - MGTFRXN2_128_AD44
set_property PACKAGE_PIN    AD43             [get_ports qsfpdd1_rx7_p]         ;# Bank 128              - QSFPDD1_RX7_P             - MGTFRXP2_128_AD43
set_property PACKAGE_PIN    AC46             [get_ports qsfpdd1_rx8_n]         ;# Bank 128              - QSFPDD1_RX8_N             - MGTFRXN3_128_AC46
set_property PACKAGE_PIN    AC45             [get_ports qsfpdd1_rx8_p]         ;# Bank 128              - QSFPDD1_RX8_P             - MGTFRXP3_128_AC45
set_property PACKAGE_PIN    AH39             [get_ports qsfpdd1_tx5_n]         ;# Bank 128              - QSFPDD1_TX5_N             - MGTFTXN0_128_AH39
set_property PACKAGE_PIN    AH38             [get_ports qsfpdd1_tx5_p]         ;# Bank 128              - QSFPDD1_TX5_P             - MGTFTXP0_128_AH38
set_property PACKAGE_PIN    AG41             [get_ports qsfpdd1_tx6_n]         ;# Bank 128              - QSFPDD1_TX6_N             - MGTFTXN1_128_AG41
set_property PACKAGE_PIN    AG40             [get_ports qsfpdd1_tx6_p]         ;# Bank 128              - QSFPDD1_TX6_P             - MGTFTXP1_128_AG40
set_property PACKAGE_PIN    AF39             [get_ports qsfpdd1_tx7_n]         ;# Bank 128              - QSFPDD1_TX7_N             - MGTFTXN2_128_AF39
set_property PACKAGE_PIN    AF38             [get_ports qsfpdd1_tx7_p]         ;# Bank 128              - QSFPDD1_TX7_P             - MGTFTXP2_128_AF38
set_property PACKAGE_PIN    AE41             [get_ports qsfpdd1_tx8_n]         ;# Bank 128              - QSFPDD1_TX8_N             - MGTFTXN3_128_AE41
set_property PACKAGE_PIN    AE40             [get_ports qsfpdd1_tx8_p]         ;# Bank 128              - QSFPDD1_TX8_P             - MGTFTXP3_128_AE40
                                                                                                                                    
#                                                                                                                                   
#  QSFPDD 2 GTF Connections - Bank 130, 131                                                                                         
#    Typical pin constraints are embedded in the IP                                                                                 
#                                                                                                                                   
set_property PACKAGE_PIN    R37              [get_ports synce_clk_130_lvds_n]  ;# Bank 130              - SYNCE_CLK_130_LVDS_N      - MGTREFCLK0N_130_R37
set_property PACKAGE_PIN    R36              [get_ports synce_clk_130_lvds_p]  ;# Bank 130              - SYNCE_CLK_130_LVDS_P      - MGTREFCLK0P_130_R36
set_property PACKAGE_PIN    V44              [get_ports qsfpdd2_rx1_n]         ;# Bank 130              - QSFPDD2_RX1_N             - MGTFRXN0_130_V44
set_property PACKAGE_PIN    V43              [get_ports qsfpdd2_rx1_p]         ;# Bank 130              - QSFPDD2_RX1_P             - MGTFRXP0_130_V43
set_property PACKAGE_PIN    U46              [get_ports qsfpdd2_rx2_n]         ;# Bank 130              - QSFPDD2_RX2_N             - MGTFRXN1_130_U46
set_property PACKAGE_PIN    U45              [get_ports qsfpdd2_rx2_p]         ;# Bank 130              - QSFPDD2_RX2_P             - MGTFRXP1_130_U45
set_property PACKAGE_PIN    T44              [get_ports qsfpdd2_rx3_n]         ;# Bank 130              - QSFPDD2_RX3_N             - MGTFRXN2_130_T44
set_property PACKAGE_PIN    T43              [get_ports qsfpdd2_rx3_p]         ;# Bank 130              - QSFPDD2_RX3_P             - MGTFRXP2_130_T43
set_property PACKAGE_PIN    R46              [get_ports qsfpdd2_rx4_n]         ;# Bank 130              - QSFPDD2_RX4_N             - MGTFRXN3_130_R46
set_property PACKAGE_PIN    R45              [get_ports qsfpdd2_rx4_p]         ;# Bank 130              - QSFPDD2_RX4_P             - MGTFRXP3_130_R45
set_property PACKAGE_PIN    Y39              [get_ports qsfpdd2_tx1_n]         ;# Bank 130              - QSFPDD2_TX1_N             - MGTFTXN0_130_Y39
set_property PACKAGE_PIN    Y38              [get_ports qsfpdd2_tx1_p]         ;# Bank 130              - QSFPDD2_TX1_P             - MGTFTXP0_130_Y38
set_property PACKAGE_PIN    W41              [get_ports qsfpdd2_tx2_n]         ;# Bank 130              - QSFPDD2_TX2_N             - MGTFTXN1_130_W41
set_property PACKAGE_PIN    W40              [get_ports qsfpdd2_tx2_p]         ;# Bank 130              - QSFPDD2_TX2_P             - MGTFTXP1_130_W40
set_property PACKAGE_PIN    V39              [get_ports qsfpdd2_tx3_n]         ;# Bank 130              - QSFPDD2_TX3_N             - MGTFTXN2_130_V39
set_property PACKAGE_PIN    V38              [get_ports qsfpdd2_tx3_p]         ;# Bank 130              - QSFPDD2_TX3_P             - MGTFTXP2_130_V38
set_property PACKAGE_PIN    U41              [get_ports qsfpdd2_tx4_n]         ;# Bank 130              - QSFPDD2_TX4_N             - MGTFTXN3_130_U41
set_property PACKAGE_PIN    U40              [get_ports qsfpdd2_tx4_p]         ;# Bank 130              - QSFPDD2_TX4_P             - MGTFTXP3_130_U40
                                                                                                                                      
set_property PACKAGE_PIN    L37              [get_ports synce_clk_131_lvds_n]  ;# Bank 131              - SYNCE_CLK_131_LVDS_N      - MGTREFCLK0N_131_L37
set_property PACKAGE_PIN    L36              [get_ports synce_clk_131_lvds_p]  ;# Bank 131              - SYNCE_CLK_131_LVDS_P      - MGTREFCLK0P_131_L36
set_property PACKAGE_PIN    P44              [get_ports qsfpdd2_rx5_n]         ;# Bank 131              - QSFPDD2_RX5_N             - MGTFRXN0_131_P44
set_property PACKAGE_PIN    P43              [get_ports qsfpdd2_rx5_p]         ;# Bank 131              - QSFPDD2_RX5_P             - MGTFRXP0_131_P43
set_property PACKAGE_PIN    N46              [get_ports qsfpdd2_rx6_n]         ;# Bank 131              - QSFPDD2_RX6_N             - MGTFRXN1_131_N46
set_property PACKAGE_PIN    N45              [get_ports qsfpdd2_rx6_p]         ;# Bank 131              - QSFPDD2_RX6_P             - MGTFRXP1_131_N45
set_property PACKAGE_PIN    M44              [get_ports qsfpdd2_rx7_n]         ;# Bank 131              - QSFPDD2_RX7_N             - MGTFRXN2_131_M44
set_property PACKAGE_PIN    M43              [get_ports qsfpdd2_rx7_p]         ;# Bank 131              - QSFPDD2_RX7_P             - MGTFRXP2_131_M43
set_property PACKAGE_PIN    L46              [get_ports qsfpdd2_rx8_n]         ;# Bank 131              - QSFPDD2_RX8_N             - MGTFRXN3_131_L46
set_property PACKAGE_PIN    L45              [get_ports qsfpdd2_rx8_p]         ;# Bank 131              - QSFPDD2_RX8_P             - MGTFRXP3_131_L45
set_property PACKAGE_PIN    T39              [get_ports qsfpdd2_tx5_n]         ;# Bank 131              - QSFPDD2_TX5_N             - MGTFTXN0_131_T39
set_property PACKAGE_PIN    T38              [get_ports qsfpdd2_tx5_p]         ;# Bank 131              - QSFPDD2_TX5_P             - MGTFTXP0_131_T38
set_property PACKAGE_PIN    R41              [get_ports qsfpdd2_tx6_n]         ;# Bank 131              - QSFPDD2_TX6_N             - MGTFTXN1_131_R41
set_property PACKAGE_PIN    R40              [get_ports qsfpdd2_tx6_p]         ;# Bank 131              - QSFPDD2_TX6_P             - MGTFTXP1_131_R40
set_property PACKAGE_PIN    P39              [get_ports qsfpdd2_tx7_n]         ;# Bank 131              - QSFPDD2_TX7_N             - MGTFTXN2_131_P39
set_property PACKAGE_PIN    P38              [get_ports qsfpdd2_tx7_p]         ;# Bank 131              - QSFPDD2_TX7_P             - MGTFTXP2_131_P38
set_property PACKAGE_PIN    N41              [get_ports qsfpdd2_tx8_n]         ;# Bank 131              - QSFPDD2_TX8_N             - MGTFTXN3_131_N41
set_property PACKAGE_PIN    N40              [get_ports qsfpdd2_tx8_p]         ;# Bank 131              - QSFPDD2_TX8_P             - MGTFTXP3_131_N40


#################################################################################
#
#  ARF6 MGTF Interfaces...
#
#################################################################################

#
#  ARF I2C Interface to J10 & J5, Bank 93 (3.3V), External Pullup
#
set_property PACKAGE_PIN    M14              [get_ports arf_i2c_scl]           ;# Bank 93   - 3V3_VCC0  - ARF_I2C_SCL               - IO_L2P_AD14P_93_M14
set_property IOSTANDARD     LVCMOS33         [get_ports arf_i2c_scl]           ;# Bank 93   - 3V3_VCC0  - ARF_I2C_SCL               - IO_L2P_AD14P_93_M14
set_property PACKAGE_PIN    M13              [get_ports arf_i2c_sda]           ;# Bank 93   - 3V3_VCC0  - ARF_I2C_SDA               - IO_L2N_AD14N_93_M13
set_property IOSTANDARD     LVCMOS33         [get_ports arf_i2c_sda]           ;# Bank 93   - 3V3_VCC0  - ARF_I2C_SDA               - IO_L2N_AD14N_93_M13
                                                                                            
#                                                                                           
#  ARF Reset and Selects to J10 & J5, Bank 93 (3.3V), External Pullups                      
#                                                                                           
set_property PACKAGE_PIN    K15              [get_ports arf_io0_rst]           ;# Bank 93   - 3V3_VCC0  - ARF_IO0_RST               - IO_L3N_AD13N_93_K15
set_property IOSTANDARD     LVCMOS33         [get_ports arf_io0_rst]           ;# Bank 93   - 3V3_VCC0  - ARF_IO0_RST               - IO_L3N_AD13N_93_K15
set_property PACKAGE_PIN    L15              [get_ports arf_io1_rst]           ;# Bank 93   - 3V3_VCC0  - ARF_IO1_RST               - IO_L3P_AD13P_93_L15
set_property IOSTANDARD     LVCMOS33         [get_ports arf_io1_rst]           ;# Bank 93   - 3V3_VCC0  - ARF_IO1_RST               - IO_L3P_AD13P_93_L15
set_property PACKAGE_PIN    L13              [get_ports arf_mux_intn]          ;# Bank 93   - 3V3_VCC0  - ARF_MUX_INTN              - IO_L1P_AD15P_93_L13
set_property IOSTANDARD     LVCMOS33         [get_ports arf_mux_intn]          ;# Bank 93   - 3V3_VCC0  - ARF_MUX_INTN              - IO_L1P_AD15P_93_L13
set_property PACKAGE_PIN    K16              [get_ports arf_mux_reset]         ;# Bank 93   - 3V3_VCC0  - ARF_MUX_RESET             - IO_L5P_HDGC_93_K16
set_property IOSTANDARD     LVCMOS33         [get_ports arf_mux_reset]         ;# Bank 93   - 3V3_VCC0  - ARF_MUX_RESET             - IO_L5P_HDGC_93_K16

#
#  ARF 0 GTF Connections to Expansion Connector - Bank 227, 228
#    Typical pin constraints are embedded in the IP
#
set_property PACKAGE_PIN    AN10             [get_ports synce_clk_226_lvds_n]  ;# Bank 226              - SYNCE_CLK_226_LVDS_N      - MGTREFCLK0N_226_AN10
set_property PACKAGE_PIN    AN11             [get_ports synce_clk_226_lvds_p]  ;# Bank 226              - SYNCE_CLK_226_LVDS_P      - MGTREFCLK0P_226_AN11
set_property PACKAGE_PIN    AJ10             [get_ports synce_clk_227_lvds_n]  ;# Bank 227              - SYNCE_CLK_227_LVDS_N      - MGTREFCLK0N_227_AJ10
set_property PACKAGE_PIN    AJ11             [get_ports synce_clk_227_lvds_p]  ;# Bank 227              - SYNCE_CLK_227_LVDS_P      - MGTREFCLK0P_227_AJ11
set_property PACKAGE_PIN    AK3              [get_ports qsfpdd3_arf1_rx1_n]    ;# Bank 227              - QSFPDD3_ARF1_RX1_N        - MGTFRXN0_227_AK3
set_property PACKAGE_PIN    AK4              [get_ports qsfpdd3_arf1_rx1_p]    ;# Bank 227              - QSFPDD3_ARF1_RX1_P        - MGTFRXP0_227_AK4
set_property PACKAGE_PIN    AJ1              [get_ports qsfpdd3_arf1_rx2_n]    ;# Bank 227              - QSFPDD3_ARF1_RX2_N        - MGTFRXN1_227_AJ1
set_property PACKAGE_PIN    AJ2              [get_ports qsfpdd3_arf1_rx2_p]    ;# Bank 227              - QSFPDD3_ARF1_RX2_P        - MGTFRXP1_227_AJ2
set_property PACKAGE_PIN    AH3              [get_ports qsfpdd3_arf1_rx3_n]    ;# Bank 227              - QSFPDD3_ARF1_RX3_N        - MGTFRXN2_227_AH3
set_property PACKAGE_PIN    AH4              [get_ports qsfpdd3_arf1_rx3_p]    ;# Bank 227              - QSFPDD3_ARF1_RX3_P        - MGTFRXP2_227_AH4
set_property PACKAGE_PIN    AG1              [get_ports qsfpdd3_arf1_rx4_n]    ;# Bank 227              - QSFPDD3_ARF1_RX4_N        - MGTFRXN3_227_AG1
set_property PACKAGE_PIN    AG2              [get_ports qsfpdd3_arf1_rx4_p]    ;# Bank 227              - QSFPDD3_ARF1_RX4_P        - MGTFRXP3_227_AG2
set_property PACKAGE_PIN    AM8              [get_ports qsfpdd3_arf1_tx1_n]    ;# Bank 227              - QSFPDD3_ARF1_TX1_N        - MGTFTXN0_227_AM8
set_property PACKAGE_PIN    AM9              [get_ports qsfpdd3_arf1_tx1_p]    ;# Bank 227              - QSFPDD3_ARF1_TX1_P        - MGTFTXP0_227_AM9
set_property PACKAGE_PIN    AL6              [get_ports qsfpdd3_arf1_tx2_n]    ;# Bank 227              - QSFPDD3_ARF1_TX2_N        - MGTFTXN1_227_AL6
set_property PACKAGE_PIN    AL7              [get_ports qsfpdd3_arf1_tx2_p]    ;# Bank 227              - QSFPDD3_ARF1_TX2_P        - MGTFTXP1_227_AL7
set_property PACKAGE_PIN    AK8              [get_ports qsfpdd3_arf1_tx3_n]    ;# Bank 227              - QSFPDD3_ARF1_TX3_N        - MGTFTXN2_227_AK8
set_property PACKAGE_PIN    AK9              [get_ports qsfpdd3_arf1_tx3_p]    ;# Bank 227              - QSFPDD3_ARF1_TX3_P        - MGTFTXP2_227_AK9
set_property PACKAGE_PIN    AJ6              [get_ports qsfpdd3_arf1_tx4_n]    ;# Bank 227              - QSFPDD3_ARF1_TX4_N        - MGTFTXN3_227_AJ6
set_property PACKAGE_PIN    AJ7              [get_ports qsfpdd3_arf1_tx4_p]    ;# Bank 227              - QSFPDD3_ARF1_TX4_P        - MGTFTXP3_227_AJ7
                                                                                                                                    
set_property PACKAGE_PIN    AE10             [get_ports synce_clk_228_lvds_n]  ;# Bank 228              - SYNCE_CLK_228_LVDS_N      - MGTREFCLK0N_228_AE10
set_property PACKAGE_PIN    AE11             [get_ports synce_clk_228_lvds_p]  ;# Bank 228              - SYNCE_CLK_228_LVDS_P      - MGTREFCLK0P_228_AE11
set_property PACKAGE_PIN    AF3              [get_ports qsfpdd3_arf1_rx5_n]    ;# Bank 228              - QSFPDD3_ARF1_RX5_N        - MGTFRXN0_228_AF3
set_property PACKAGE_PIN    AF4              [get_ports qsfpdd3_arf1_rx5_p]    ;# Bank 228              - QSFPDD3_ARF1_RX5_P        - MGTFRXP0_228_AF4
set_property PACKAGE_PIN    AE1              [get_ports qsfpdd3_arf1_rx6_n]    ;# Bank 228              - QSFPDD3_ARF1_RX6_N        - MGTFRXN1_228_AE1
set_property PACKAGE_PIN    AE2              [get_ports qsfpdd3_arf1_rx6_p]    ;# Bank 228              - QSFPDD3_ARF1_RX6_P        - MGTFRXP1_228_AE2
set_property PACKAGE_PIN    AD3              [get_ports qsfpdd3_arf1_rx7_n]    ;# Bank 228              - QSFPDD3_ARF1_RX7_N        - MGTFRXN2_228_AD3
set_property PACKAGE_PIN    AD4              [get_ports qsfpdd3_arf1_rx7_p]    ;# Bank 228              - QSFPDD3_ARF1_RX7_P        - MGTFRXP2_228_AD4
set_property PACKAGE_PIN    AC1              [get_ports qsfpdd3_arf1_rx8_n]    ;# Bank 228              - QSFPDD3_ARF1_RX8_N        - MGTFRXN3_228_AC1
set_property PACKAGE_PIN    AC2              [get_ports qsfpdd3_arf1_rx8_p]    ;# Bank 228              - QSFPDD3_ARF1_RX8_P        - MGTFRXP3_228_AC2
set_property PACKAGE_PIN    AH8              [get_ports qsfpdd3_arf1_tx5_n]    ;# Bank 228              - QSFPDD3_ARF1_TX5_N        - MGTFTXN0_228_AH8
set_property PACKAGE_PIN    AH9              [get_ports qsfpdd3_arf1_tx5_p]    ;# Bank 228              - QSFPDD3_ARF1_TX5_P        - MGTFTXP0_228_AH9
set_property PACKAGE_PIN    AG6              [get_ports qsfpdd3_arf1_tx6_n]    ;# Bank 228              - QSFPDD3_ARF1_TX6_N        - MGTFTXN1_228_AG6
set_property PACKAGE_PIN    AG7              [get_ports qsfpdd3_arf1_tx6_p]    ;# Bank 228              - QSFPDD3_ARF1_TX6_P        - MGTFTXP1_228_AG7
set_property PACKAGE_PIN    AF8              [get_ports qsfpdd3_arf1_tx7_n]    ;# Bank 228              - QSFPDD3_ARF1_TX7_N        - MGTFTXN2_228_AF8
set_property PACKAGE_PIN    AF9              [get_ports qsfpdd3_arf1_tx7_p]    ;# Bank 228              - QSFPDD3_ARF1_TX7_P        - MGTFTXP2_228_AF9
set_property PACKAGE_PIN    AE6              [get_ports qsfpdd3_arf1_tx8_n]    ;# Bank 228              - QSFPDD3_ARF1_TX8_N        - MGTFTXN3_228_AE6
set_property PACKAGE_PIN    AE7              [get_ports qsfpdd3_arf1_tx8_p]    ;# Bank 228              - QSFPDD3_ARF1_TX8_P        - MGTFTXP3_228_AE7

#
#  ARF 1 GTF Connections to Expansion Connector - Bank 229, 230
#    Typical pin constraints are embedded in the IP
#
set_property PACKAGE_PIN    AA10             [get_ports synce_clk_229_lvds_n]  ;# Bank 229              - SYNCE_CLK_229_LVDS_N      - MGTREFCLK0N_229_AA10
set_property PACKAGE_PIN    AA11             [get_ports synce_clk_229_lvds_p]  ;# Bank 229              - SYNCE_CLK_229_LVDS_P      - MGTREFCLK0P_229_AA11
set_property PACKAGE_PIN    AB3              [get_ports qsfpdd4_arf2_rx1_n]    ;# Bank 229              - QSFPDD4_ARF2_RX1_N        - MGTFRXN0_229_AB3
set_property PACKAGE_PIN    AB4              [get_ports qsfpdd4_arf2_rx1_p]    ;# Bank 229              - QSFPDD4_ARF2_RX1_P        - MGTFRXP0_229_AB4
set_property PACKAGE_PIN    AA1              [get_ports qsfpdd4_arf2_rx2_n]    ;# Bank 229              - QSFPDD4_ARF2_RX2_N        - MGTFRXN1_229_AA1
set_property PACKAGE_PIN    AA2              [get_ports qsfpdd4_arf2_rx2_p]    ;# Bank 229              - QSFPDD4_ARF2_RX2_P        - MGTFRXP1_229_AA2
set_property PACKAGE_PIN    Y3               [get_ports qsfpdd4_arf2_rx3_n]    ;# Bank 229              - QSFPDD4_ARF2_RX3_N        - MGTFRXN2_229_Y3
set_property PACKAGE_PIN    Y4               [get_ports qsfpdd4_arf2_rx3_p]    ;# Bank 229              - QSFPDD4_ARF2_RX3_P        - MGTFRXP2_229_Y4
set_property PACKAGE_PIN    W1               [get_ports qsfpdd4_arf2_rx4_n]    ;# Bank 229              - QSFPDD4_ARF2_RX4_N        - MGTFRXN3_229_W1
set_property PACKAGE_PIN    W2               [get_ports qsfpdd4_arf2_rx4_p]    ;# Bank 229              - QSFPDD4_ARF2_RX4_P        - MGTFRXP3_229_W2
set_property PACKAGE_PIN    AD8              [get_ports qsfpdd4_arf2_tx1_n]    ;# Bank 229              - QSFPDD4_ARF2_TX1_N        - MGTFTXN0_229_AD8
set_property PACKAGE_PIN    AD9              [get_ports qsfpdd4_arf2_tx1_p]    ;# Bank 229              - QSFPDD4_ARF2_TX1_P        - MGTFTXP0_229_AD9
set_property PACKAGE_PIN    AC6              [get_ports qsfpdd4_arf2_tx2_n]    ;# Bank 229              - QSFPDD4_ARF2_TX2_N        - MGTFTXN1_229_AC6
set_property PACKAGE_PIN    AC7              [get_ports qsfpdd4_arf2_tx2_p]    ;# Bank 229              - QSFPDD4_ARF2_TX2_P        - MGTFTXP1_229_AC7
set_property PACKAGE_PIN    AB8              [get_ports qsfpdd4_arf2_tx3_n]    ;# Bank 229              - QSFPDD4_ARF2_TX3_N        - MGTFTXN2_229_AB8
set_property PACKAGE_PIN    AB9              [get_ports qsfpdd4_arf2_tx3_p]    ;# Bank 229              - QSFPDD4_ARF2_TX3_P        - MGTFTXP2_229_AB9
set_property PACKAGE_PIN    AA6              [get_ports qsfpdd4_arf2_tx4_n]    ;# Bank 229              - QSFPDD4_ARF2_TX4_N        - MGTFTXN3_229_AA6
set_property PACKAGE_PIN    AA7              [get_ports qsfpdd4_arf2_tx4_p]    ;# Bank 229              - QSFPDD4_ARF2_TX4_P        - MGTFTXP3_229_AA7
                                                                                                                                      
set_property PACKAGE_PIN    U10              [get_ports synce_clk_230_lvds_n]  ;# Bank 230              - SYNCE_CLK_230_LVDS_N      - MGTREFCLK0N_230_U10
set_property PACKAGE_PIN    U11              [get_ports synce_clk_230_lvds_p]  ;# Bank 230              - SYNCE_CLK_230_LVDS_P      - MGTREFCLK0P_230_U11
set_property PACKAGE_PIN    V3               [get_ports qsfpdd4_arf2_rx5_n]    ;# Bank 230              - QSFPDD4_ARF2_RX5_N        - MGTFRXN0_230_V3
set_property PACKAGE_PIN    V4               [get_ports qsfpdd4_arf2_rx5_p]    ;# Bank 230              - QSFPDD4_ARF2_RX5_P        - MGTFRXP0_230_V4
set_property PACKAGE_PIN    U1               [get_ports qsfpdd4_arf2_rx6_n]    ;# Bank 230              - QSFPDD4_ARF2_RX6_N        - MGTFRXN1_230_U1
set_property PACKAGE_PIN    U2               [get_ports qsfpdd4_arf2_rx6_p]    ;# Bank 230              - QSFPDD4_ARF2_RX6_P        - MGTFRXP1_230_U2
set_property PACKAGE_PIN    T3               [get_ports qsfpdd4_arf2_rx7_n]    ;# Bank 230              - QSFPDD4_ARF2_RX7_N        - MGTFRXN2_230_T3
set_property PACKAGE_PIN    T4               [get_ports qsfpdd4_arf2_rx7_p]    ;# Bank 230              - QSFPDD4_ARF2_RX7_P        - MGTFRXP2_230_T4
set_property PACKAGE_PIN    R1               [get_ports qsfpdd4_arf2_rx8_n]    ;# Bank 230              - QSFPDD4_ARF2_RX8_N        - MGTFRXN3_230_R1
set_property PACKAGE_PIN    R2               [get_ports qsfpdd4_arf2_rx8_p]    ;# Bank 230              - QSFPDD4_ARF2_RX8_P        - MGTFRXP3_230_R2
set_property PACKAGE_PIN    Y8               [get_ports qsfpdd4_arf2_tx5_n]    ;# Bank 230              - QSFPDD4_ARF2_TX5_N        - MGTFTXN0_230_Y8
set_property PACKAGE_PIN    Y9               [get_ports qsfpdd4_arf2_tx5_p]    ;# Bank 230              - QSFPDD4_ARF2_TX5_P        - MGTFTXP0_230_Y9
set_property PACKAGE_PIN    W6               [get_ports qsfpdd4_arf2_tx6_n]    ;# Bank 230              - QSFPDD4_ARF2_TX6_N        - MGTFTXN1_230_W6
set_property PACKAGE_PIN    W7               [get_ports qsfpdd4_arf2_tx6_p]    ;# Bank 230              - QSFPDD4_ARF2_TX6_P        - MGTFTXP1_230_W7
set_property PACKAGE_PIN    V8               [get_ports qsfpdd4_arf2_tx7_n]    ;# Bank 230              - QSFPDD4_ARF2_TX7_N        - MGTFTXN2_230_V8
set_property PACKAGE_PIN    V9               [get_ports qsfpdd4_arf2_tx7_p]    ;# Bank 230              - QSFPDD4_ARF2_TX7_P        - MGTFTXP2_230_V9
set_property PACKAGE_PIN    U6               [get_ports qsfpdd4_arf2_tx8_n]    ;# Bank 230              - QSFPDD4_ARF2_TX8_N        - MGTFTXN3_230_U6
set_property PACKAGE_PIN    U7               [get_ports qsfpdd4_arf2_tx8_p]    ;# Bank 230              - QSFPDD4_ARF2_TX8_P        - MGTFTXP3_230_U7


#################################################################################
#
#  DDR Interface...
#
#################################################################################

#
#  DDR4 RDIMM Controller 0, 72-bit Data Interface, x4 Components, Single Rank
#     Banks 66, 67, 68 (1.2V)
#     Part Number MT40A2G8SA-062E (x8 comp, x72@2666)
#

#  -- DDR_DQS
set_property PACKAGE_PIN    AU30             [get_ports CH0_DDR4_dqs_c[0]]     ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQS_C0            - IO_L22N_T3U_N7_DBC_AD0N_67_AU30
set_property IOSTANDARD     DIFF_POD12_DCI   [get_ports CH0_DDR4_dqs_c[0]]     ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQS_C0            - IO_L22N_T3U_N7_DBC_AD0N_67_AU30
set_property PACKAGE_PIN    AV34             [get_ports CH0_DDR4_dqs_c[1]]     ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQS_C1            - IO_L22N_T3U_N7_DBC_AD0N_68_AV34
set_property IOSTANDARD     DIFF_POD12_DCI   [get_ports CH0_DDR4_dqs_c[1]]     ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQS_C1            - IO_L22N_T3U_N7_DBC_AD0N_68_AV34
set_property PACKAGE_PIN    BE31             [get_ports CH0_DDR4_dqs_c[2]]     ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQS_C2            - IO_L4N_T0U_N7_DBC_AD7N_68_BE31
set_property IOSTANDARD     DIFF_POD12_DCI   [get_ports CH0_DDR4_dqs_c[2]]     ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQS_C2            - IO_L4N_T0U_N7_DBC_AD7N_68_BE31
set_property PACKAGE_PIN    AW29             [get_ports CH0_DDR4_dqs_c[3]]     ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQS_C3            - IO_L16N_T2U_N7_QBC_AD3N_67_AW29
set_property IOSTANDARD     DIFF_POD12_DCI   [get_ports CH0_DDR4_dqs_c[3]]     ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQS_C3            - IO_L16N_T2U_N7_QBC_AD3N_67_AW29
set_property PACKAGE_PIN    BA33             [get_ports CH0_DDR4_dqs_c[4]]     ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQS_C4            - IO_L16N_T2U_N7_QBC_AD3N_68_BA33
set_property IOSTANDARD     DIFF_POD12_DCI   [get_ports CH0_DDR4_dqs_c[4]]     ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQS_C4            - IO_L16N_T2U_N7_QBC_AD3N_68_BA33
set_property PACKAGE_PIN    BB30             [get_ports CH0_DDR4_dqs_c[5]]     ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQS_C5            - IO_L10N_T1U_N7_QBC_AD4N_67_BB30
set_property IOSTANDARD     DIFF_POD12_DCI   [get_ports CH0_DDR4_dqs_c[5]]     ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQS_C5            - IO_L10N_T1U_N7_QBC_AD4N_67_BB30
set_property PACKAGE_PIN    AP24             [get_ports CH0_DDR4_dqs_c[6]]     ;# Bank 66   - 1V2_VCC0  - DDR4_C0_DQS_C6            - IO_L22N_T3U_N7_DBC_AD0N_66_AP24
set_property IOSTANDARD     DIFF_POD12_DCI   [get_ports CH0_DDR4_dqs_c[6]]     ;# Bank 66   - 1V2_VCC0  - DDR4_C0_DQS_C6            - IO_L22N_T3U_N7_DBC_AD0N_66_AP24
set_property PACKAGE_PIN    BF27             [get_ports CH0_DDR4_dqs_c[7]]     ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQS_C7            - IO_L4N_T0U_N7_DBC_AD7N_67_BF27
set_property IOSTANDARD     DIFF_POD12_DCI   [get_ports CH0_DDR4_dqs_c[7]]     ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQS_C7            - IO_L4N_T0U_N7_DBC_AD7N_67_BF27
set_property PACKAGE_PIN    BC37             [get_ports CH0_DDR4_dqs_c[8]]     ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQS_C8            - IO_L10N_T1U_N7_QBC_AD4N_68_BC37
set_property IOSTANDARD     DIFF_POD12_DCI   [get_ports CH0_DDR4_dqs_c[8]]     ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQS_C8            - IO_L10N_T1U_N7_QBC_AD4N_68_BC37
set_property PACKAGE_PIN    AT29             [get_ports CH0_DDR4_dqs_t[0]]     ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQS_T0            - IO_L22P_T3U_N6_DBC_AD0P_67_AT29
set_property IOSTANDARD     DIFF_POD12_DCI   [get_ports CH0_DDR4_dqs_t[0]]     ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQS_T0            - IO_L22P_T3U_N6_DBC_AD0P_67_AT29
set_property PACKAGE_PIN    AU34             [get_ports CH0_DDR4_dqs_t[1]]     ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQS_T1            - IO_L22P_T3U_N6_DBC_AD0P_68_AU34
set_property IOSTANDARD     DIFF_POD12_DCI   [get_ports CH0_DDR4_dqs_t[1]]     ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQS_T1            - IO_L22P_T3U_N6_DBC_AD0P_68_AU34
set_property PACKAGE_PIN    BD31             [get_ports CH0_DDR4_dqs_t[2]]     ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQS_T2            - IO_L4P_T0U_N6_DBC_AD7P_68_BD31
set_property IOSTANDARD     DIFF_POD12_DCI   [get_ports CH0_DDR4_dqs_t[2]]     ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQS_T2            - IO_L4P_T0U_N6_DBC_AD7P_68_BD31
set_property PACKAGE_PIN    AV29             [get_ports CH0_DDR4_dqs_t[3]]     ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQS_T3            - IO_L16P_T2U_N6_QBC_AD3P_67_AV29
set_property IOSTANDARD     DIFF_POD12_DCI   [get_ports CH0_DDR4_dqs_t[3]]     ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQS_T3            - IO_L16P_T2U_N6_QBC_AD3P_67_AV29
set_property PACKAGE_PIN    AY32             [get_ports CH0_DDR4_dqs_t[4]]     ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQS_T4            - IO_L16P_T2U_N6_QBC_AD3P_68_AY32
set_property IOSTANDARD     DIFF_POD12_DCI   [get_ports CH0_DDR4_dqs_t[4]]     ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQS_T4            - IO_L16P_T2U_N6_QBC_AD3P_68_AY32
set_property PACKAGE_PIN    BB29             [get_ports CH0_DDR4_dqs_t[5]]     ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQS_T5            - IO_L10P_T1U_N6_QBC_AD4P_67_BB29
set_property IOSTANDARD     DIFF_POD12_DCI   [get_ports CH0_DDR4_dqs_t[5]]     ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQS_T5            - IO_L10P_T1U_N6_QBC_AD4P_67_BB29
set_property PACKAGE_PIN    AP25             [get_ports CH0_DDR4_dqs_t[6]]     ;# Bank 66   - 1V2_VCC0  - DDR4_C0_DQS_T6            - IO_L22P_T3U_N6_DBC_AD0P_66_AP25
set_property IOSTANDARD     DIFF_POD12_DCI   [get_ports CH0_DDR4_dqs_t[6]]     ;# Bank 66   - 1V2_VCC0  - DDR4_C0_DQS_T6            - IO_L22P_T3U_N6_DBC_AD0P_66_AP25
set_property PACKAGE_PIN    BE27             [get_ports CH0_DDR4_dqs_t[7]]     ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQS_T7            - IO_L4P_T0U_N6_DBC_AD7P_67_BE27
set_property IOSTANDARD     DIFF_POD12_DCI   [get_ports CH0_DDR4_dqs_t[7]]     ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQS_T7            - IO_L4P_T0U_N6_DBC_AD7P_67_BE27
set_property PACKAGE_PIN    BB37             [get_ports CH0_DDR4_dqs_t[8]]     ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQS_T8            - IO_L10P_T1U_N6_QBC_AD4P_68_BB37
set_property IOSTANDARD     DIFF_POD12_DCI   [get_ports CH0_DDR4_dqs_t[8]]     ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQS_T8            - IO_L10P_T1U_N6_QBC_AD4P_68_BB37
                                                                                            
#  -- DDR_DQ                                                                                
set_property PACKAGE_PIN    AU27             [get_ports CH0_DDR4_dq[0]]        ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ0               - IO_L20P_T3L_N2_AD1P_67_AU27
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[0]]        ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ0               - IO_L20P_T3L_N2_AD1P_67_AU27
set_property PACKAGE_PIN    AT30             [get_ports CH0_DDR4_dq[1]]        ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ1               - IO_L21P_T3L_N4_AD8P_67_AT30
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[1]]        ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ1               - IO_L21P_T3L_N4_AD8P_67_AT30
set_property PACKAGE_PIN    AV27             [get_ports CH0_DDR4_dq[2]]        ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ2               - IO_L20N_T3L_N3_AD1N_67_AV27
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[2]]        ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ2               - IO_L20N_T3L_N3_AD1N_67_AV27
set_property PACKAGE_PIN    AR28             [get_ports CH0_DDR4_dq[3]]        ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ3               - IO_L23P_T3U_N8_67_AR28
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[3]]        ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ3               - IO_L23P_T3U_N8_67_AR28
set_property PACKAGE_PIN    AT27             [get_ports CH0_DDR4_dq[4]]        ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ4               - IO_L24N_T3U_N11_67_AT27
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[4]]        ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ4               - IO_L24N_T3U_N11_67_AT27
set_property PACKAGE_PIN    AU31             [get_ports CH0_DDR4_dq[5]]        ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ5               - IO_L21N_T3L_N5_AD8N_67_AU31
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[5]]        ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ5               - IO_L21N_T3L_N5_AD8N_67_AU31
set_property PACKAGE_PIN    AR27             [get_ports CH0_DDR4_dq[6]]        ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ6               - IO_L24P_T3U_N10_67_AR27
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[6]]        ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ6               - IO_L24P_T3U_N10_67_AR27
set_property PACKAGE_PIN    AT28             [get_ports CH0_DDR4_dq[7]]        ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ7               - IO_L23N_T3U_N9_67_AT28
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[7]]        ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ7               - IO_L23N_T3U_N9_67_AT28
set_property PACKAGE_PIN    AV33             [get_ports CH0_DDR4_dq[8]]        ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ8               - IO_L20P_T3L_N2_AD1P_68_AV33
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[8]]        ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ8               - IO_L20P_T3L_N2_AD1P_68_AV33
set_property PACKAGE_PIN    AR31             [get_ports CH0_DDR4_dq[9]]        ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ9               - IO_L24P_T3U_N10_68_AR31
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[9]]        ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ9               - IO_L24P_T3U_N10_68_AR31
set_property PACKAGE_PIN    AW34             [get_ports CH0_DDR4_dq[10]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ10              - IO_L20N_T3L_N3_AD1N_68_AW34
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[10]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ10              - IO_L20N_T3L_N3_AD1N_68_AW34
set_property PACKAGE_PIN    AT32             [get_ports CH0_DDR4_dq[11]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ11              - IO_L24N_T3U_N11_68_AT32
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[11]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ11              - IO_L24N_T3U_N11_68_AT32
set_property PACKAGE_PIN    AU32             [get_ports CH0_DDR4_dq[12]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ12              - IO_L21P_T3L_N4_AD8P_68_AU32
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[12]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ12              - IO_L21P_T3L_N4_AD8P_68_AU32
set_property PACKAGE_PIN    AR33             [get_ports CH0_DDR4_dq[13]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ13              - IO_L23N_T3U_N9_68_AR33
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[13]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ13              - IO_L23N_T3U_N9_68_AR33
set_property PACKAGE_PIN    AV32             [get_ports CH0_DDR4_dq[14]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ14              - IO_L21N_T3L_N5_AD8N_68_AV32
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[14]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ14              - IO_L21N_T3L_N5_AD8N_68_AV32
set_property PACKAGE_PIN    AR32             [get_ports CH0_DDR4_dq[15]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ15              - IO_L23P_T3U_N8_68_AR32
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[15]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ15              - IO_L23P_T3U_N8_68_AR32
set_property PACKAGE_PIN    BE32             [get_ports CH0_DDR4_dq[16]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ16              - IO_L3P_T0L_N4_AD15P_68_BE32
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[16]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ16              - IO_L3P_T0L_N4_AD15P_68_BE32
set_property PACKAGE_PIN    BF34             [get_ports CH0_DDR4_dq[17]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ17              - IO_L2N_T0L_N3_68_BF34
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[17]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ17              - IO_L2N_T0L_N3_68_BF34
set_property PACKAGE_PIN    BF32             [get_ports CH0_DDR4_dq[18]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ18              - IO_L3N_T0L_N5_AD15N_68_BF32
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[18]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ18              - IO_L3N_T0L_N5_AD15N_68_BF32
set_property PACKAGE_PIN    BF33             [get_ports CH0_DDR4_dq[19]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ19              - IO_L2P_T0L_N2_68_BF33
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[19]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ19              - IO_L2P_T0L_N2_68_BF33
set_property PACKAGE_PIN    BC32             [get_ports CH0_DDR4_dq[20]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ20              - IO_L5P_T0U_N8_AD14P_68_BC32
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[20]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ20              - IO_L5P_T0U_N8_AD14P_68_BC32
set_property PACKAGE_PIN    BD34             [get_ports CH0_DDR4_dq[21]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ21              - IO_L6N_T0U_N11_AD6N_68_BD34
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[21]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ21              - IO_L6N_T0U_N11_AD6N_68_BD34
set_property PACKAGE_PIN    BC33             [get_ports CH0_DDR4_dq[22]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ22              - IO_L6P_T0U_N10_AD6P_68_BC33
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[22]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ22              - IO_L6P_T0U_N10_AD6P_68_BC33
set_property PACKAGE_PIN    BD33             [get_ports CH0_DDR4_dq[23]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ23              - IO_L5N_T0U_N9_AD14N_68_BD33
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[23]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ23              - IO_L5N_T0U_N9_AD14N_68_BD33
set_property PACKAGE_PIN    AW31             [get_ports CH0_DDR4_dq[24]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ24              - IO_L15N_T2L_N5_AD11N_67_AW31
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[24]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ24              - IO_L15N_T2L_N5_AD11N_67_AW31
set_property PACKAGE_PIN    AV28             [get_ports CH0_DDR4_dq[25]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ25              - IO_L17P_T2U_N8_AD10P_67_AV28
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[25]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ25              - IO_L17P_T2U_N8_AD10P_67_AV28
set_property PACKAGE_PIN    AV31             [get_ports CH0_DDR4_dq[26]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ26              - IO_L15P_T2L_N4_AD11P_67_AV31
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[26]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ26              - IO_L15P_T2L_N4_AD11P_67_AV31
set_property PACKAGE_PIN    AY26             [get_ports CH0_DDR4_dq[27]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ27              - IO_L18N_T2U_N11_AD2N_67_AY26
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[27]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ27              - IO_L18N_T2U_N11_AD2N_67_AY26
set_property PACKAGE_PIN    AW30             [get_ports CH0_DDR4_dq[28]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ28              - IO_L14P_T2L_N2_GC_67_AW30
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[28]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ28              - IO_L14P_T2L_N2_GC_67_AW30
set_property PACKAGE_PIN    AW26             [get_ports CH0_DDR4_dq[29]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ29              - IO_L18P_T2U_N10_AD2P_67_AW26
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[29]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ29              - IO_L18P_T2U_N10_AD2P_67_AW26
set_property PACKAGE_PIN    AY31             [get_ports CH0_DDR4_dq[30]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ30              - IO_L14N_T2L_N3_GC_67_AY31
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[30]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ30              - IO_L14N_T2L_N3_GC_67_AY31
set_property PACKAGE_PIN    AW28             [get_ports CH0_DDR4_dq[31]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ31              - IO_L17N_T2U_N9_AD10N_67_AW28
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[31]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ31              - IO_L17N_T2U_N9_AD10N_67_AW28
set_property PACKAGE_PIN    BB32             [get_ports CH0_DDR4_dq[32]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ32              - IO_L15N_T2L_N5_AD11N_68_BB32
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[32]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ32              - IO_L15N_T2L_N5_AD11N_68_BB32
set_property PACKAGE_PIN    AY35             [get_ports CH0_DDR4_dq[33]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ33              - IO_L17N_T2U_N9_AD10N_68_AY35
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[33]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ33              - IO_L17N_T2U_N9_AD10N_68_AY35
set_property PACKAGE_PIN    BA32             [get_ports CH0_DDR4_dq[34]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ34              - IO_L15P_T2L_N4_AD11P_68_BA32
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[34]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ34              - IO_L15P_T2L_N4_AD11P_68_BA32
set_property PACKAGE_PIN    AW35             [get_ports CH0_DDR4_dq[35]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ35              - IO_L17P_T2U_N8_AD10P_68_AW35
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[35]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ35              - IO_L17P_T2U_N8_AD10P_68_AW35
set_property PACKAGE_PIN    BB35             [get_ports CH0_DDR4_dq[36]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ36              - IO_L14N_T2L_N3_GC_68_BB35
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[36]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ36              - IO_L14N_T2L_N3_GC_68_BB35
set_property PACKAGE_PIN    AY36             [get_ports CH0_DDR4_dq[37]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ37              - IO_L18N_T2U_N11_AD2N_68_AY36
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[37]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ37              - IO_L18N_T2U_N11_AD2N_68_AY36
set_property PACKAGE_PIN    BB34             [get_ports CH0_DDR4_dq[38]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ38              - IO_L14P_T2L_N2_GC_68_BB34
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[38]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ38              - IO_L14P_T2L_N2_GC_68_BB34
set_property PACKAGE_PIN    AW36             [get_ports CH0_DDR4_dq[39]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ39              - IO_L18P_T2U_N10_AD2P_68_AW36
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[39]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ39              - IO_L18P_T2U_N10_AD2P_68_AW36
set_property PACKAGE_PIN    BA28             [get_ports CH0_DDR4_dq[40]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ40              - IO_L12N_T1U_N11_GC_67_BA28
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[40]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ40              - IO_L12N_T1U_N11_GC_67_BA28
set_property PACKAGE_PIN    BC31             [get_ports CH0_DDR4_dq[41]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ41              - IO_L8N_T1L_N3_AD5N_67_BC31
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[41]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ41              - IO_L8N_T1L_N3_AD5N_67_BC31
set_property PACKAGE_PIN    BB27             [get_ports CH0_DDR4_dq[42]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ42              - IO_L11P_T1U_N8_GC_67_BB27
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[42]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ42              - IO_L11P_T1U_N8_GC_67_BB27
set_property PACKAGE_PIN    BA30             [get_ports CH0_DDR4_dq[43]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ43              - IO_L9N_T1L_N5_AD12N_67_BA30
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[43]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ43              - IO_L9N_T1L_N5_AD12N_67_BA30
set_property PACKAGE_PIN    BC27             [get_ports CH0_DDR4_dq[44]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ44              - IO_L11N_T1U_N9_GC_67_BC27
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[44]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ44              - IO_L11N_T1U_N9_GC_67_BC27
set_property PACKAGE_PIN    BB31             [get_ports CH0_DDR4_dq[45]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ45              - IO_L8P_T1L_N2_AD5P_67_BB31
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[45]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ45              - IO_L8P_T1L_N2_AD5P_67_BB31
set_property PACKAGE_PIN    BA27             [get_ports CH0_DDR4_dq[46]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ46              - IO_L12P_T1U_N10_GC_67_BA27
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[46]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ46              - IO_L12P_T1U_N10_GC_67_BA27
set_property PACKAGE_PIN    AY30             [get_ports CH0_DDR4_dq[47]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ47              - IO_L9P_T1L_N4_AD12P_67_AY30
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[47]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ47              - IO_L9P_T1L_N4_AD12P_67_AY30
set_property PACKAGE_PIN    AR26             [get_ports CH0_DDR4_dq[48]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_DQ48              - IO_L21P_T3L_N4_AD8P_66_AR26
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[48]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_DQ48              - IO_L21P_T3L_N4_AD8P_66_AR26
set_property PACKAGE_PIN    AP23             [get_ports CH0_DDR4_dq[49]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_DQ49              - IO_L23P_T3U_N8_66_AP23
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[49]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_DQ49              - IO_L23P_T3U_N8_66_AP23
set_property PACKAGE_PIN    AR25             [get_ports CH0_DDR4_dq[50]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_DQ50              - IO_L20P_T3L_N2_AD1P_66_AR25
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[50]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_DQ50              - IO_L20P_T3L_N2_AD1P_66_AR25
set_property PACKAGE_PIN    AR23             [get_ports CH0_DDR4_dq[51]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_DQ51              - IO_L23N_T3U_N9_66_AR23
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[51]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_DQ51              - IO_L23N_T3U_N9_66_AR23
set_property PACKAGE_PIN    AT25             [get_ports CH0_DDR4_dq[52]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_DQ52              - IO_L21N_T3L_N5_AD8N_66_AT25
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[52]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_DQ52              - IO_L21N_T3L_N5_AD8N_66_AT25
set_property PACKAGE_PIN    AR22             [get_ports CH0_DDR4_dq[53]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_DQ53              - IO_L24P_T3U_N10_66_AR22
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[53]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_DQ53              - IO_L24P_T3U_N10_66_AR22
set_property PACKAGE_PIN    AT24             [get_ports CH0_DDR4_dq[54]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_DQ54              - IO_L20N_T3L_N3_AD1N_66_AT24
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[54]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_DQ54              - IO_L20N_T3L_N3_AD1N_66_AT24
set_property PACKAGE_PIN    AR21             [get_ports CH0_DDR4_dq[55]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_DQ55              - IO_L24N_T3U_N11_66_AR21
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[55]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_DQ55              - IO_L24N_T3U_N11_66_AR21
set_property PACKAGE_PIN    BD26             [get_ports CH0_DDR4_dq[56]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ56              - IO_L5P_T0U_N8_AD14P_67_BD26
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[56]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ56              - IO_L5P_T0U_N8_AD14P_67_BD26
set_property PACKAGE_PIN    BF28             [get_ports CH0_DDR4_dq[57]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ57              - IO_L2P_T0L_N2_67_BF28
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[57]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ57              - IO_L2P_T0L_N2_67_BF28
set_property PACKAGE_PIN    BE26             [get_ports CH0_DDR4_dq[58]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ58              - IO_L5N_T0U_N9_AD14N_67_BE26
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[58]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ58              - IO_L5N_T0U_N9_AD14N_67_BE26
set_property PACKAGE_PIN    BE28             [get_ports CH0_DDR4_dq[59]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ59              - IO_L3N_T0L_N5_AD15N_67_BE28
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[59]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ59              - IO_L3N_T0L_N5_AD15N_67_BE28
set_property PACKAGE_PIN    BC26             [get_ports CH0_DDR4_dq[60]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ60              - IO_L6N_T0U_N11_AD6N_67_BC26
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[60]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ60              - IO_L6N_T0U_N11_AD6N_67_BC26
set_property PACKAGE_PIN    BF29             [get_ports CH0_DDR4_dq[61]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ61              - IO_L2N_T0L_N3_67_BF29
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[61]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ61              - IO_L2N_T0L_N3_67_BF29
set_property PACKAGE_PIN    BB26             [get_ports CH0_DDR4_dq[62]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ62              - IO_L6P_T0U_N10_AD6P_67_BB26
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[62]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ62              - IO_L6P_T0U_N10_AD6P_67_BB26
set_property PACKAGE_PIN    BD28             [get_ports CH0_DDR4_dq[63]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ63              - IO_L3P_T0L_N4_AD15P_67_BD28
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[63]]       ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DQ63              - IO_L3P_T0L_N4_AD15P_67_BD28
set_property PACKAGE_PIN    BD38             [get_ports CH0_DDR4_dq[64]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ64              - IO_L9N_T1L_N5_AD12N_68_BD38
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[64]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ64              - IO_L9N_T1L_N5_AD12N_68_BD38
set_property PACKAGE_PIN    BC36             [get_ports CH0_DDR4_dq[65]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ65              - IO_L12P_T1U_N10_GC_68_BC36
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[65]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ65              - IO_L12P_T1U_N10_GC_68_BC36
set_property PACKAGE_PIN    BC38             [get_ports CH0_DDR4_dq[66]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ66              - IO_L9P_T1L_N4_AD12P_68_BC38
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[66]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ66              - IO_L9P_T1L_N4_AD12P_68_BC38
set_property PACKAGE_PIN    BD36             [get_ports CH0_DDR4_dq[67]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ67              - IO_L12N_T1U_N11_GC_68_BD36
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[67]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ67              - IO_L12N_T1U_N11_GC_68_BD36
set_property PACKAGE_PIN    BE38             [get_ports CH0_DDR4_dq[68]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ68              - IO_L8P_T1L_N2_AD5P_68_BE38
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[68]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ68              - IO_L8P_T1L_N2_AD5P_68_BE38
set_property PACKAGE_PIN    BC34             [get_ports CH0_DDR4_dq[69]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ69              - IO_L11P_T1U_N8_GC_68_BC34
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[69]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ69              - IO_L11P_T1U_N8_GC_68_BC34
set_property PACKAGE_PIN    BD35             [get_ports CH0_DDR4_dq[70]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ70              - IO_L11N_T1U_N9_GC_68_BD35
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[70]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ70              - IO_L11N_T1U_N9_GC_68_BD35
set_property PACKAGE_PIN    BF38             [get_ports CH0_DDR4_dq[71]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ71              - IO_L8N_T1L_N3_AD5N_68_BF38
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dq[71]]       ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DQ71              - IO_L8N_T1L_N3_AD5N_68_BF38
                                                                                            
#  -- DDR_ADDR                                                                              
set_property PACKAGE_PIN    BD23             [get_ports CH0_DDR4_adr[0]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A0                - IO_L6N_T0U_N11_AD6N_66_BD23
set_property IOSTANDARD     SSTL12_DCI       [get_ports CH0_DDR4_adr[0]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A0                - IO_L6N_T0U_N11_AD6N_66_BD23
set_property PACKAGE_PIN    AV23             [get_ports CH0_DDR4_adr[1]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A1                - IO_L17P_T2U_N8_AD10P_66_AV23
set_property IOSTANDARD     SSTL12_DCI       [get_ports CH0_DDR4_adr[1]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A1                - IO_L17P_T2U_N8_AD10P_66_AV23
set_property PACKAGE_PIN    BE22             [get_ports CH0_DDR4_adr[2]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A2                - IO_L4N_T0U_N7_DBC_AD7N_66_BE22
set_property IOSTANDARD     SSTL12_DCI       [get_ports CH0_DDR4_adr[2]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A2                - IO_L4N_T0U_N7_DBC_AD7N_66_BE22
set_property PACKAGE_PIN    BF22             [get_ports CH0_DDR4_adr[3]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A3                - IO_L2N_T0L_N3_66_BF22
set_property IOSTANDARD     SSTL12_DCI       [get_ports CH0_DDR4_adr[3]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A3                - IO_L2N_T0L_N3_66_BF22
set_property PACKAGE_PIN    BF23             [get_ports CH0_DDR4_adr[4]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A4                - IO_L2P_T0L_N2_66_BF23
set_property IOSTANDARD     SSTL12_DCI       [get_ports CH0_DDR4_adr[4]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A4                - IO_L2P_T0L_N2_66_BF23
set_property PACKAGE_PIN    BE23             [get_ports CH0_DDR4_adr[5]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A5                - IO_L4P_T0U_N6_DBC_AD7P_66_BE23
set_property IOSTANDARD     SSTL12_DCI       [get_ports CH0_DDR4_adr[5]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A5                - IO_L4P_T0U_N6_DBC_AD7P_66_BE23
set_property PACKAGE_PIN    BA22             [get_ports CH0_DDR4_adr[6]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A6                - IO_T1U_N12_66_BA22
set_property IOSTANDARD     SSTL12_DCI       [get_ports CH0_DDR4_adr[6]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A6                - IO_T1U_N12_66_BA22
set_property PACKAGE_PIN    BA23             [get_ports CH0_DDR4_adr[7]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A7                - IO_L12N_T1U_N11_GC_66_BA23
set_property IOSTANDARD     SSTL12_DCI       [get_ports CH0_DDR4_adr[7]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A7                - IO_L12N_T1U_N11_GC_66_BA23
set_property PACKAGE_PIN    BB22             [get_ports CH0_DDR4_adr[8]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A8                - IO_L11P_T1U_N8_GC_66_BB22
set_property IOSTANDARD     SSTL12_DCI       [get_ports CH0_DDR4_adr[8]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A8                - IO_L11P_T1U_N8_GC_66_BB22
set_property PACKAGE_PIN    AU24             [get_ports CH0_DDR4_adr[9]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A9                - IO_L16N_T2U_N7_QBC_AD3N_66_AU24
set_property IOSTANDARD     SSTL12_DCI       [get_ports CH0_DDR4_adr[9]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A9                - IO_L16N_T2U_N7_QBC_AD3N_66_AU24
set_property PACKAGE_PIN    BE25             [get_ports CH0_DDR4_adr[10]]      ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A10               - IO_L5N_T0U_N9_AD14N_66_BE25
set_property IOSTANDARD     SSTL12_DCI       [get_ports CH0_DDR4_adr[10]]      ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A10               - IO_L5N_T0U_N9_AD14N_66_BE25
set_property PACKAGE_PIN    BA24             [get_ports CH0_DDR4_adr[11]]      ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A11               - IO_L12P_T1U_N10_GC_66_BA24
set_property IOSTANDARD     SSTL12_DCI       [get_ports CH0_DDR4_adr[11]]      ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A11               - IO_L12P_T1U_N10_GC_66_BA24
set_property PACKAGE_PIN    BF24             [get_ports CH0_DDR4_adr[12]]      ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A12               - IO_L1N_T0L_N1_DBC_66_BF24
set_property IOSTANDARD     SSTL12_DCI       [get_ports CH0_DDR4_adr[12]]      ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A12               - IO_L1N_T0L_N1_DBC_66_BF24
set_property PACKAGE_PIN    BD21             [get_ports CH0_DDR4_adr[13]]      ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A13               - IO_L3P_T0L_N4_AD15P_66_BD21
set_property IOSTANDARD     SSTL12_DCI       [get_ports CH0_DDR4_adr[13]]      ;# Bank 66   - 1V2_VCC0  - DDR4_C0_A13               - IO_L3P_T0L_N4_AD15P_66_BD21
set_property PACKAGE_PIN    BB24             [get_ports CH0_DDR4_adr[15]]      ;# Bank 66   - 1V2_VCC0  - DDR4_C0_CAS_B             - IO_L8P_T1L_N2_AD5P_66_BB24
set_property IOSTANDARD     SSTL12_DCI       [get_ports CH0_DDR4_adr[15]]      ;# Bank 66   - 1V2_VCC0  - DDR4_C0_CAS_B             - IO_L8P_T1L_N2_AD5P_66_BB24
set_property PACKAGE_PIN    BC21             [get_ports CH0_DDR4_adr[16]]      ;# Bank 66   - 1V2_VCC0  - DDR4_C0_RAS_B             - IO_L9N_T1L_N5_AD12N_66_BC21
set_property IOSTANDARD     SSTL12_DCI       [get_ports CH0_DDR4_adr[16]]      ;# Bank 66   - 1V2_VCC0  - DDR4_C0_RAS_B             - IO_L9N_T1L_N5_AD12N_66_BC21
set_property PACKAGE_PIN    BC22             [get_ports CH0_DDR4_adr[14]]      ;# Bank 66   - 1V2_VCC0  - DDR4_C0_WE_B              - IO_L11N_T1U_N9_GC_66_BC22
set_property IOSTANDARD     SSTL12_DCI       [get_ports CH0_DDR4_adr[14]]      ;# Bank 66   - 1V2_VCC0  - DDR4_C0_WE_B              - IO_L11N_T1U_N9_GC_66_BC22
                                                                                            
#  -- DDR_DM                                                                                
set_property PACKAGE_PIN    AU26             [get_ports CH0_DDR4_dm_n[0]]      ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DM_B0             - IO_L19P_T3L_N0_DBC_AD9P_67_AU26
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dm_n[0]]      ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DM_B0             - IO_L19P_T3L_N0_DBC_AD9P_67_AU26
set_property PACKAGE_PIN    AW33             [get_ports CH0_DDR4_dm_n[1]]      ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DM_B1             - IO_L19P_T3L_N0_DBC_AD9P_68_AW33
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dm_n[1]]      ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DM_B1             - IO_L19P_T3L_N0_DBC_AD9P_68_AW33
set_property PACKAGE_PIN    BE35             [get_ports CH0_DDR4_dm_n[2]]      ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DM_B2             - IO_L1P_T0L_N0_DBC_68_BE35
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dm_n[2]]      ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DM_B2             - IO_L1P_T0L_N0_DBC_68_BE35
set_property PACKAGE_PIN    AY28             [get_ports CH0_DDR4_dm_n[3]]      ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DM_B3             - IO_L13P_T2L_N0_GC_QBC_67_AY28
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dm_n[3]]      ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DM_B3             - IO_L13P_T2L_N0_GC_QBC_67_AY28
set_property PACKAGE_PIN    BA35             [get_ports CH0_DDR4_dm_n[4]]      ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DM_B4             - IO_L13P_T2L_N0_GC_QBC_68_BA35
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dm_n[4]]      ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DM_B4             - IO_L13P_T2L_N0_GC_QBC_68_BA35
set_property PACKAGE_PIN    BC29             [get_ports CH0_DDR4_dm_n[5]]      ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DM_B5             - IO_L7P_T1L_N0_QBC_AD13P_67_BC29
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dm_n[5]]      ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DM_B5             - IO_L7P_T1L_N0_QBC_AD13P_67_BC29
set_property PACKAGE_PIN    AT22             [get_ports CH0_DDR4_dm_n[6]]      ;# Bank 66   - 1V2_VCC0  - DDR4_C0_DM_B6             - IO_L19P_T3L_N0_DBC_AD9P_66_AT22
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dm_n[6]]      ;# Bank 66   - 1V2_VCC0  - DDR4_C0_DM_B6             - IO_L19P_T3L_N0_DBC_AD9P_66_AT22
set_property PACKAGE_PIN    BE30             [get_ports CH0_DDR4_dm_n[7]]      ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DM_B7             - IO_L1P_T0L_N0_DBC_67_BE30
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dm_n[7]]      ;# Bank 67   - 1V2_VCC0  - DDR4_C0_DM_B7             - IO_L1P_T0L_N0_DBC_67_BE30
set_property PACKAGE_PIN    BE37             [get_ports CH0_DDR4_dm_n[8]]      ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DM_B8             - IO_L7P_T1L_N0_QBC_AD13P_68_BE37
set_property IOSTANDARD     POD12_DCI        [get_ports CH0_DDR4_dm_n[8]]      ;# Bank 68   - 1V2_VCC0  - DDR4_C0_DM_B8             - IO_L7P_T1L_N0_QBC_AD13P_68_BE37
                                                                                            
#  -- DDR_BA                                                                                
set_property PACKAGE_PIN    AW21             [get_ports CH0_DDR4_ba[0]]        ;# Bank 66   - 1V2_VCC0  - DDR4_C0_BA0               - IO_L10P_T1U_N6_QBC_AD4P_66_AW21
set_property IOSTANDARD     SSTL12_DCI       [get_ports CH0_DDR4_ba[0]]        ;# Bank 66   - 1V2_VCC0  - DDR4_C0_BA0               - IO_L10P_T1U_N6_QBC_AD4P_66_AW21
set_property PACKAGE_PIN    BB21             [get_ports CH0_DDR4_ba[1]]        ;# Bank 66   - 1V2_VCC0  - DDR4_C0_BA1               - IO_L9P_T1L_N4_AD12P_66_BB21
set_property IOSTANDARD     SSTL12_DCI       [get_ports CH0_DDR4_ba[1]]        ;# Bank 66   - 1V2_VCC0  - DDR4_C0_BA1               - IO_L9P_T1L_N4_AD12P_66_BB21
set_property PACKAGE_PIN    AY21             [get_ports CH0_DDR4_bg[0]]        ;# Bank 66   - 1V2_VCC0  - DDR4_C0_BG0               - IO_L10N_T1U_N7_QBC_AD4N_66_AY21
set_property IOSTANDARD     SSTL12_DCI       [get_ports CH0_DDR4_bg[0]]        ;# Bank 66   - 1V2_VCC0  - DDR4_C0_BG0               - IO_L10N_T1U_N7_QBC_AD4N_66_AY21
set_property PACKAGE_PIN    AY25             [get_ports CH0_DDR4_bg[1]]        ;# Bank 66   - 1V2_VCC0  - DDR4_C0_BG1               - IO_L15N_T2L_N5_AD11N_66_AY25
set_property IOSTANDARD     SSTL12_DCI       [get_ports CH0_DDR4_bg[1]]        ;# Bank 66   - 1V2_VCC0  - DDR4_C0_BG1               - IO_L15N_T2L_N5_AD11N_66_AY25
                                                                                            
#  -- DDR_CLK                                                                               
set_property PACKAGE_PIN    BB25             [get_ports CH0_DDR4_ck_c[0]]      ;# Bank 66   - 1V2_VCC0  - DDR4_C0_CK0_C             - IO_L7N_T1L_N1_QBC_AD13N_66_BB25
set_property IOSTANDARD     LVDS             [get_ports CH0_DDR4_ck_c[0]]      ;# Bank 66   - 1V2_VCC0  - DDR4_C0_CK0_C             - IO_L7N_T1L_N1_QBC_AD13N_66_BB25
set_property PACKAGE_PIN    BA25             [get_ports CH0_DDR4_ck_t[0]]      ;# Bank 66   - 1V2_VCC0  - DDR4_C0_CK0_T             - IO_L7P_T1L_N0_QBC_AD13P_66_BA25
set_property IOSTANDARD     LVDS             [get_ports CH0_DDR4_ck_t[0]]      ;# Bank 66   - 1V2_VCC0  - DDR4_C0_CK0_T             - IO_L7P_T1L_N0_QBC_AD13P_66_BA25
                                                                                            
#  -- DDR Other                                                                             
set_property PACKAGE_PIN    BE21             [get_ports CH0_DDR4_act_n]        ;# Bank 66   - 1V2_VCC0  - DDR4_C0_ACT_B             - IO_L3N_T0L_N5_AD15N_66_BE21
set_property IOSTANDARD     LVCMOS12         [get_ports CH0_DDR4_act_n]        ;# Bank 66   - 1V2_VCC0  - DDR4_C0_ACT_B             - IO_L3N_T0L_N5_AD15N_66_BE21
set_property PACKAGE_PIN    BC24             [get_ports CH0_DDR4_cke[0]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_CKE0              - IO_L8N_T1L_N3_AD5N_66_BC24
set_property IOSTANDARD     LVCMOS12         [get_ports CH0_DDR4_cke[0]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_CKE0              - IO_L8N_T1L_N3_AD5N_66_BC24
set_property PACKAGE_PIN    BF25             [get_ports CH0_DDR4_cs_n[0]]      ;# Bank 66   - 1V2_VCC0  - DDR4_C0_CS0_B             - IO_L1P_T0L_N0_DBC_66_BF25
set_property IOSTANDARD     LVCMOS12         [get_ports CH0_DDR4_cs_n[0]]      ;# Bank 66   - 1V2_VCC0  - DDR4_C0_CS0_B             - IO_L1P_T0L_N0_DBC_66_BF25
set_property PACKAGE_PIN    BD25             [get_ports CH0_DDR4_odt[0]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_ODT0              - IO_L5P_T0U_N8_AD14P_66_BD25
set_property IOSTANDARD     LVCMOS12         [get_ports CH0_DDR4_odt[0]]       ;# Bank 66   - 1V2_VCC0  - DDR4_C0_ODT0              - IO_L5P_T0U_N8_AD14P_66_BD25
set_property PACKAGE_PIN    AT23             [get_ports CH0_DDR4_reset_b_fpga] ;# Bank 66   - 1V2_VCC0  - DDR4_C0_RESET_B_FPGA      - IO_T3U_N12_66_AT23
set_property IOSTANDARD     LVCMOS12         [get_ports CH0_DDR4_reset_b_fpga] ;# Bank 66   - 1V2_VCC0  - DDR4_C0_RESET_B_FPGA      - IO_T3U_N12_66_AT23
                                                                                            
set_property PACKAGE_PIN    AU20             [get_ports CH0_DDR4_reset_gate_r] ;# Bank 65   - 1V8_SYS   - DDR4_C0_RESET_GATE_R      - IO_L22P_T3U_N6_DBC_AD0P_D04_65_AU20
set_property IOSTANDARD     LVCMOS18         [get_ports CH0_DDR4_reset_gate_r] ;# Bank 65   - 1V8_SYS   - DDR4_C0_RESET_GATE_R      - IO_L22P_T3U_N6_DBC_AD0P_D04_65_AU20


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
set_property PACKAGE_PIN    AP19             [get_ports pcie_host_detect]      ;# Bank 65   - 1V8_SYS   - PCIE_HOST_DETECT          - IO_L24N_T3U_N11_DOUT_CSO_B_65_AP19
set_property IOSTANDARD     LVCMOS18         [get_ports pcie_host_detect]      ;# Bank 65   - 1V8_SYS   - PCIE_HOST_DETECT          - IO_L24N_T3U_N11_DOUT_CSO_B_65_AP19
set_property PACKAGE_PIN    AT19             [get_ports pcie_perst_ls_65]      ;# Bank 65   - 1V8_SYS   - PCIE_PERST_LS_65          - IO_T3U_N12_PERSTN0_65_AT19
set_property IOSTANDARD     LVCMOS18         [get_ports pcie_perst_ls_65]      ;# Bank 65   - 1V8_SYS   - PCIE_PERST_LS_65          - IO_T3U_N12_PERSTN0_65_AT19
set_property PACKAGE_PIN    AR18             [get_ports pex_pwrbrkn_fpga_65]   ;# Bank 65   - 1V8_SYS   - PEX_PWRBRKN_FPGA_65       - IO_L21P_T3L_N4_AD8P_D06_65_AR18
set_property IOSTANDARD     LVCMOS18         [get_ports pex_pwrbrkn_fpga_65]   ;# Bank 65   - 1V8_SYS   - PEX_PWRBRKN_FPGA_65       - IO_L21P_T3L_N4_AD8P_D06_65_AR18

#
#  LVDS Input Reference Clock for PCIe, Bank 225 (1.2V)
#    Typical GT pin constraints are embedded in the IP
#
set_property PACKAGE_PIN    AV8              [get_ports pcie_refclk_buf_n]     ;# Bank 225              - PCIE_REFCLK_BUF_N         - MGTREFCLK0N_225_AV8
set_property IOSTANDARD     LVDS             [get_ports pcie_refclk_buf_n]     ;# Bank 225              - PCIE_REFCLK_BUF_N         - MGTREFCLK0N_225_AV8
set_property PACKAGE_PIN    AV9              [get_ports pcie_refclk_buf_p]     ;# Bank 225              - PCIE_REFCLK_BUF_P         - MGTREFCLK0P_225_AV9
set_property IOSTANDARD     LVDS             [get_ports pcie_refclk_buf_p]     ;# Bank 225              - PCIE_REFCLK_BUF_P         - MGTREFCLK0P_225_AV9

#
#  On Board 100 Mhz Reference clock for PCIe, Bank 225 (1.2V)
#    Typical GT pin constraints are embedded in the IP
#
set_property PACKAGE_PIN    AR10             [get_ports clk_pcie_lvds_100_n]   ;# Bank 225              - CLK_PCIE_LVDS_100_N       - MGTREFCLK1N_225_AR10
set_property IOSTANDARD     LVDS             [get_ports clk_pcie_lvds_100_n]   ;# Bank 225              - CLK_PCIE_LVDS_100_N       - MGTREFCLK1N_225_AR10
set_property PACKAGE_PIN    AR11             [get_ports clk_pcie_lvds_100_p]   ;# Bank 225              - CLK_PCIE_LVDS_100_P       - MGTREFCLK1P_225_AR11
set_property IOSTANDARD     LVDS             [get_ports clk_pcie_lvds_100_p]   ;# Bank 225              - CLK_PCIE_LVDS_100_P       - MGTREFCLK1P_225_AR11
                                            
#
#  PCIe Data Connections - Bank 224 and Bank 225 (1.2V)
#    Typical GT pin constraints are embedded in the IP
#
set_property PACKAGE_PIN    AT3              [get_ports pex_rx0_n]             ;# Bank 225              - PEX_RX0_N                 - MGTYRXN3_225_AT3
set_property PACKAGE_PIN    AT4              [get_ports pex_rx0_p]             ;# Bank 225              - PEX_RX0_P                 - MGTYRXP3_225_AT4
set_property PACKAGE_PIN    AU1              [get_ports pex_rx1_n]             ;# Bank 225              - PEX_RX1_N                 - MGTYRXN2_225_AU1
set_property PACKAGE_PIN    AU2              [get_ports pex_rx1_p]             ;# Bank 225              - PEX_RX1_P                 - MGTYRXP2_225_AU2
set_property PACKAGE_PIN    AV3              [get_ports pex_rx2_n]             ;# Bank 225              - PEX_RX2_N                 - MGTYRXN1_225_AV3
set_property PACKAGE_PIN    AV4              [get_ports pex_rx2_p]             ;# Bank 225              - PEX_RX2_P                 - MGTYRXP1_225_AV4
set_property PACKAGE_PIN    AW1              [get_ports pex_rx3_n]             ;# Bank 225              - PEX_RX3_N                 - MGTYRXN0_225_AW1
set_property PACKAGE_PIN    AW2              [get_ports pex_rx3_p]             ;# Bank 225              - PEX_RX3_P                 - MGTYRXP0_225_AW2
set_property PACKAGE_PIN    AY3              [get_ports pex_rx4_n]             ;# Bank 224              - PEX_RX4_N                 - MGTYRXN3_224_AY3
set_property PACKAGE_PIN    AY4              [get_ports pex_rx4_p]             ;# Bank 224              - PEX_RX4_P                 - MGTYRXP3_224_AY4
set_property PACKAGE_PIN    BA1              [get_ports pex_rx5_n]             ;# Bank 224              - PEX_RX5_N                 - MGTYRXN2_224_BA1
set_property PACKAGE_PIN    BA2              [get_ports pex_rx5_p]             ;# Bank 224              - PEX_RX5_P                 - MGTYRXP2_224_BA2
set_property PACKAGE_PIN    BB3              [get_ports pex_rx6_n]             ;# Bank 224              - PEX_RX6_N                 - MGTYRXN1_224_BB3
set_property PACKAGE_PIN    BB4              [get_ports pex_rx6_p]             ;# Bank 224              - PEX_RX6_P                 - MGTYRXP1_224_BB4
set_property PACKAGE_PIN    BC1              [get_ports pex_rx7_n]             ;# Bank 224              - PEX_RX7_N                 - MGTYRXN0_224_BC1
set_property PACKAGE_PIN    BC2              [get_ports pex_rx7_p]             ;# Bank 224              - PEX_RX7_P                 - MGTYRXP0_224_BC2
                                                                                                                                    
set_property PACKAGE_PIN    AW6              [get_ports pex_tx0_n]             ;# Bank 225              - PEX_TX0_N                 - MGTYTXN3_225_AW6
set_property PACKAGE_PIN    AW7              [get_ports pex_tx0_p]             ;# Bank 225              - PEX_TX0_P                 - MGTYTXP3_225_AW7
set_property PACKAGE_PIN    BA6              [get_ports pex_tx1_n]             ;# Bank 225              - PEX_TX1_N                 - MGTYTXN2_225_BA6
set_property PACKAGE_PIN    BA7              [get_ports pex_tx1_p]             ;# Bank 225              - PEX_TX1_P                 - MGTYTXP2_225_BA7
set_property PACKAGE_PIN    BC6              [get_ports pex_tx2_n]             ;# Bank 225              - PEX_TX2_N                 - MGTYTXN1_225_BC6
set_property PACKAGE_PIN    BC7              [get_ports pex_tx2_p]             ;# Bank 225              - PEX_TX2_P                 - MGTYTXP1_225_BC7
set_property PACKAGE_PIN    BD8              [get_ports pex_tx3_n]             ;# Bank 225              - PEX_TX3_N                 - MGTYTXN0_225_BD8
set_property PACKAGE_PIN    BD9              [get_ports pex_tx3_p]             ;# Bank 225              - PEX_TX3_P                 - MGTYTXP0_225_BD9
set_property PACKAGE_PIN    BD4              [get_ports pex_tx4_n]             ;# Bank 224              - PEX_TX4_N                 - MGTYTXN3_224_BD4
set_property PACKAGE_PIN    BD5              [get_ports pex_tx4_p]             ;# Bank 224              - PEX_TX4_P                 - MGTYTXP3_224_BD5
set_property PACKAGE_PIN    BE6              [get_ports pex_tx5_n]             ;# Bank 224              - PEX_TX5_N                 - MGTYTXN2_224_BE6
set_property PACKAGE_PIN    BE7              [get_ports pex_tx5_p]             ;# Bank 224              - PEX_TX5_P                 - MGTYTXP2_224_BE7
set_property PACKAGE_PIN    BF8              [get_ports pex_tx6_n]             ;# Bank 224              - PEX_TX6_N                 - MGTYTXN1_224_BF8
set_property PACKAGE_PIN    BF9              [get_ports pex_tx6_p]             ;# Bank 224              - PEX_TX6_P                 - MGTYTXP1_224_BF9
set_property PACKAGE_PIN    BF4              [get_ports pex_tx7_n]             ;# Bank 224              - PEX_TX7_N                 - MGTYTXN0_224_BF4
set_property PACKAGE_PIN    BF5              [get_ports pex_tx7_p]             ;# Bank 224              - PEX_TX7_P                 - MGTYTXP0_224_BF5


#################################################################################
#
#  Jitter Cleaner GPIO and Reset Signals...
#
#################################################################################

#
#  Jitter Resetn - Active Low Output Signal to Jitter Cleaner 1 & 2, Banks 65 (1.8V)
#
set_property PACKAGE_PIN    AY16             [get_ports jitt_resetn]           ;# Bank 65   - 1V8_SYS   - JITT_RESETN               - IO_L10N_T1U_N7_QBC_AD4N_A13_D29_65_AY16
set_property IOSTANDARD     LVCMOS18         [get_ports jitt_resetn]           ;# Bank 65   - 1V8_SYS   - JITT_RESETN               - IO_L10N_T1U_N7_QBC_AD4N_A13_D29_65_AY16
                                                                                            
#                                                                                           
#  Jitter Cleaner GPIO - Banks 65 (1.8V)                                                    
#                                                                                           
set_property PACKAGE_PIN    AP16             [get_ports jitt1_gpoi0]           ;# Bank 65   - 1V8_SYS   - JITT1_GPOI0               - IO_L19P_T3L_N0_DBC_AD9P_D10_65_AP16
set_property IOSTANDARD     LVCMOS18         [get_ports jitt1_gpoi0]           ;# Bank 65   - 1V8_SYS   - JITT1_GPOI0               - IO_L19P_T3L_N0_DBC_AD9P_D10_65_AP16
set_property PACKAGE_PIN    AT17             [get_ports jitt1_gpoi1]           ;# Bank 65   - 1V8_SYS   - JITT1_GPOI1               - IO_L18P_T2U_N10_AD2P_D12_65_AT17
set_property IOSTANDARD     LVCMOS18         [get_ports jitt1_gpoi1]           ;# Bank 65   - 1V8_SYS   - JITT1_GPOI1               - IO_L18P_T2U_N10_AD2P_D12_65_AT17
set_property PACKAGE_PIN    AU16             [get_ports jitt1_gpoi2]           ;# Bank 65   - 1V8_SYS   - JITT1_GPOI2               - IO_L18N_T2U_N11_AD2N_D13_65_AU16
set_property IOSTANDARD     LVCMOS18         [get_ports jitt1_gpoi2]           ;# Bank 65   - 1V8_SYS   - JITT1_GPOI2               - IO_L18N_T2U_N11_AD2N_D13_65_AU16
set_property PACKAGE_PIN    AV19             [get_ports jitt1_gpoi3]           ;# Bank 65   - 1V8_SYS   - JITT1_GPOI3               - IO_T2U_N12_CSI_ADV_B_65_AV19
set_property IOSTANDARD     LVCMOS18         [get_ports jitt1_gpoi3]           ;# Bank 65   - 1V8_SYS   - JITT1_GPOI3               - IO_T2U_N12_CSI_ADV_B_65_AV19
set_property PACKAGE_PIN    AR16             [get_ports jitt1_gpoi4]           ;# Bank 65   - 1V8_SYS   - JITT1_GPOI4               - IO_L19N_T3L_N1_DBC_AD9N_D11_65_AR16
set_property IOSTANDARD     LVCMOS18         [get_ports jitt1_gpoi4]           ;# Bank 65   - 1V8_SYS   - JITT1_GPOI4               - IO_L19N_T3L_N1_DBC_AD9N_D11_65_AR16
set_property PACKAGE_PIN    AP18             [get_ports jitt1_gpoi5]           ;# Bank 65   - 1V8_SYS   - JITT1_GPOI5               - IO_L20P_T3L_N2_AD1P_D08_65_AP18
set_property IOSTANDARD     LVCMOS18         [get_ports jitt1_gpoi5]           ;# Bank 65   - 1V8_SYS   - JITT1_GPOI5               - IO_L20P_T3L_N2_AD1P_D08_65_AP18

#
#  Jitter Cleaner Recovery Clock from FPGA GTF RefClock Output, Banks 127, 130, 227, 229 (1.5V)
#    Typical pin constraints are embedded in the IP
#
set_property PACKAGE_PIN    AE37             [get_ports recov_clk_127_lvds_n]  ;# Bank 127              - RECOV_CLK_127_LVDS_N      - MGTREFCLK1N_127_AE37
set_property IOSTANDARD     LVDS             [get_ports recov_clk_127_lvds_n]  ;# Bank 127              - RECOV_CLK_127_LVDS_N      - MGTREFCLK1N_127_AE37
set_property PACKAGE_PIN    AE36             [get_ports recov_clk_127_lvds_p]  ;# Bank 127              - RECOV_CLK_127_LVDS_P      - MGTREFCLK1P_127_AE36
set_property IOSTANDARD     LVDS             [get_ports recov_clk_127_lvds_p]  ;# Bank 127              - RECOV_CLK_127_LVDS_P      - MGTREFCLK1P_127_AE36
set_property PACKAGE_PIN    N37              [get_ports recov_clk_130_lvds_n]  ;# Bank 130              - RECOV_CLK_130_LVDS_N      - MGTREFCLK1N_130_N37
set_property IOSTANDARD     LVDS             [get_ports recov_clk_130_lvds_n]  ;# Bank 130              - RECOV_CLK_130_LVDS_N      - MGTREFCLK1N_130_N37
set_property PACKAGE_PIN    N36              [get_ports recov_clk_130_lvds_p]  ;# Bank 130              - RECOV_CLK_130_LVDS_P      - MGTREFCLK1P_130_N36
set_property IOSTANDARD     LVDS             [get_ports recov_clk_130_lvds_p]  ;# Bank 130              - RECOV_CLK_130_LVDS_P      - MGTREFCLK1P_130_N36
                                                                                                                                      
set_property PACKAGE_PIN    AG10             [get_ports recov_clk_227_lvds_n]  ;# Bank 227              - RECOV_CLK_227_LVDS_N      - MGTREFCLK1N_227_AG10
set_property IOSTANDARD     LVDS             [get_ports recov_clk_227_lvds_n]  ;# Bank 227              - RECOV_CLK_227_LVDS_N      - MGTREFCLK1N_227_AG10
set_property PACKAGE_PIN    AG11             [get_ports recov_clk_227_lvds_p]  ;# Bank 227              - RECOV_CLK_227_LVDS_P      - MGTREFCLK1P_227_AG11
set_property IOSTANDARD     LVDS             [get_ports recov_clk_227_lvds_p]  ;# Bank 227              - RECOV_CLK_227_LVDS_P      - MGTREFCLK1P_227_AG11
set_property PACKAGE_PIN    W10              [get_ports recov_clk_229_lvds_n]  ;# Bank 229              - RECOV_CLK_229_LVDS_N      - MGTREFCLK1N_229_W10
set_property IOSTANDARD     LVDS             [get_ports recov_clk_229_lvds_n]  ;# Bank 229              - RECOV_CLK_229_LVDS_N      - MGTREFCLK1N_229_W10
set_property PACKAGE_PIN    W11              [get_ports recov_clk_229_lvds_p]  ;# Bank 229              - RECOV_CLK_229_LVDS_P      - MGTREFCLK1P_229_W11
set_property IOSTANDARD     LVDS             [get_ports recov_clk_229_lvds_p]  ;# Bank 229              - RECOV_CLK_229_LVDS_P      - MGTREFCLK1P_229_W11

#
#  Jitter Cleaner Recovery Clocks from FPGA HDIO Input, Banks 65 (1.8V)
#
set_property PACKAGE_PIN    BF19             [get_ports recov_clk_65_lvds_n]   ;# Bank 65   - 1V8_SYS   - RECOV_CLK_65_LVDS_N       - IO_L4N_T0U_N7_DBC_AD7N_A25_65_BF19
set_property IOSTANDARD     LVDS             [get_ports recov_clk_65_lvds_n]   ;# Bank 65   - 1V8_SYS   - RECOV_CLK_65_LVDS_N       - IO_L4N_T0U_N7_DBC_AD7N_A25_65_BF19
set_property PACKAGE_PIN    BF20             [get_ports recov_clk_65_lvds_p]   ;# Bank 65   - 1V8_SYS   - RECOV_CLK_65_LVDS_P       - IO_L4P_T0U_N6_DBC_AD7P_A24_65_BF20
set_property IOSTANDARD     LVDS             [get_ports recov_clk_65_lvds_p]   ;# Bank 65   - 1V8_SYS   - RECOV_CLK_65_LVDS_P       - IO_L4P_T0U_N6_DBC_AD7P_A24_65_BF20

#
#  Jitter Cleaner Synce Clocks to FPGA HDIO Input, Banks 65 (1.8V)
#
set_property PACKAGE_PIN    BA17             [get_ports synce_clk_65_1_lvds_n] ;# Bank 65   - 1V8_SYS   - SYNCE_CLK_65_1_LVDS_N     - IO_L12N_T1U_N11_GC_A09_D25_65_BA17
set_property IOSTANDARD     LVDS             [get_ports synce_clk_65_1_lvds_n] ;# Bank 65   - 1V8_SYS   - SYNCE_CLK_65_1_LVDS_N     - IO_L12N_T1U_N11_GC_A09_D25_65_BA17
set_property PACKAGE_PIN    AY17             [get_ports synce_clk_65_1_lvds_p] ;# Bank 65   - 1V8_SYS   - SYNCE_CLK_65_1_LVDS_P     - IO_L12P_T1U_N10_GC_A08_D24_65_AY17
set_property IOSTANDARD     LVDS             [get_ports synce_clk_65_1_lvds_p] ;# Bank 65   - 1V8_SYS   - SYNCE_CLK_65_1_LVDS_P     - IO_L12P_T1U_N10_GC_A08_D24_65_AY17
set_property PACKAGE_PIN    BB20             [get_ports synce_clk_65_2_lvds_n] ;# Bank 65   - 1V8_SYS   - SYNCE_CLK_65_2_LVDS_N     - IO_L7N_T1L_N1_QBC_AD13N_A19_65_BB20
set_property IOSTANDARD     LVDS             [get_ports synce_clk_65_2_lvds_n] ;# Bank 65   - 1V8_SYS   - SYNCE_CLK_65_2_LVDS_N     - IO_L7N_T1L_N1_QBC_AD13N_A19_65_BB20
set_property PACKAGE_PIN    BA20             [get_ports synce_clk_65_2_lvds_p] ;# Bank 65   - 1V8_SYS   - SYNCE_CLK_65_2_LVDS_P     - IO_L7P_T1L_N0_QBC_AD13P_A18_65_BA20
set_property IOSTANDARD     LVDS             [get_ports synce_clk_65_2_lvds_p] ;# Bank 65   - 1V8_SYS   - SYNCE_CLK_65_2_LVDS_P     - IO_L7P_T1L_N0_QBC_AD13P_A18_65_BA20


#################################################################################
#
#  Satellite Controller I/F Signals
#
#################################################################################

#  Active Low Interrupt from Satellite Controller to FPGA - Bank 93 (3.3V)
#
set_property PACKAGE_PIN    M15              [get_ports fpga_gpio2]            ;# Bank 93   - 3V3_VCC0  - FPGA_GPIO2                - IO_L4N_AD12N_93_M15
set_property IOSTANDARD     LVCMOS33         [get_ports fpga_gpio2]            ;# Bank 93   - 3V3_VCC0  - FPGA_GPIO2                - IO_L4N_AD12N_93_M15
                                                                                                                                    
#  FPGA UART Interface to Satellite Controller (115200, No parity, 8 bits, 1 stop bit) - Bank 88 (3.3V)                             
#    FPGA_SUC_RXD  Input from Satellite Controller UART to FPGA                                                                     
#    FPGA_SUC_RXD  Output from FPGA to Satellite Controller UART                                                                    
#                                                                                                                                   
set_property PACKAGE_PIN    BE15             [get_ports fpga_suc_rxd_r]        ;# Bank 88   - 3V3_VCC0  - FPGA_SUC_RXD_R            - IO_L2N_AD10N_88_BE15
set_property IOSTANDARD     LVCMOS33         [get_ports fpga_suc_rxd_r]        ;# Bank 88   - 3V3_VCC0  - FPGA_SUC_RXD_R            - IO_L2N_AD10N_88_BE15
set_property PACKAGE_PIN    BD15             [get_ports fpga_suc_txd_r]        ;# Bank 88   - 3V3_VCC0  - FPGA_SUC_TXD_R            - IO_L2P_AD10P_88_BD15
set_property IOSTANDARD     LVCMOS33         [get_ports fpga_suc_txd_r]        ;# Bank 88   - 3V3_VCC0  - FPGA_SUC_TXD_R            - IO_L2P_AD10P_88_BD15
                                                                                                                                    
#                                                                                                                                   
#  FPGA UART Interface to FTDI FT4232 Port 3 of 4 (User selectable Baud) - Bank 88 (3.3V)                                           
#    FPGA_UART2_RXD  Input from FT4232 UART to FPGA                                                                                 
#    FPGA_UART2_TXD  Output from FPGA to FT4232 UART                                                                                
#                                                                                                                                   
set_property PACKAGE_PIN    BB14             [get_ports fpga_uart2_rxd]        ;# Bank 88   - 3V3_VCC0  - FPGA_UART2_RXD            - IO_L4N_AD8N_88_BB14
set_property IOSTANDARD     LVCMOS33         [get_ports fpga_uart2_rxd]        ;# Bank 88   - 3V3_VCC0  - FPGA_UART2_RXD            - IO_L4N_AD8N_88_BB14
set_property PACKAGE_PIN    BA14             [get_ports fpga_uart2_txd_r]      ;# Bank 88   - 3V3_VCC0  - FPGA_UART2_TXD_R          - IO_L4P_AD8P_88_BA14
set_property IOSTANDARD     LVCMOS33         [get_ports fpga_uart2_txd_r]      ;# Bank 88   - 3V3_VCC0  - FPGA_UART2_TXD_R          - IO_L4P_AD8P_88_BA14
                                                                                                                                    
#                                                                                                                                   
#  FPGA UART Interface to FTDI FT4232 Port 4 of 4 (User selectable Baud) used by the ADK2 Debug Connector - Bank 88 (3.3V)          
#    FPGA_UART1_RXD  Input from FT4232 UART to FPGA                                                                                 
#    FPGA_UART1_TXD  Output from FPGA to FT4232 UART                                                                                
#                                                                                                                                   
set_property PACKAGE_PIN    BD14             [get_ports fpga_uart1_rxd]        ;# Bank 88   - 3V3_VCC0  - FPGA_UART1_RXD            - IO_L3N_AD9N_88_BD14
set_property IOSTANDARD     LVCMOS33         [get_ports fpga_uart1_rxd]        ;# Bank 88   - 3V3_VCC0  - FPGA_UART1_RXD            - IO_L3N_AD9N_88_BD14
set_property PACKAGE_PIN    BC14             [get_ports fpga_uart1_txd_r]      ;# Bank 88   - 3V3_VCC0  - FPGA_UART1_TXD_R          - IO_L3P_AD9P_88_BC14
set_property IOSTANDARD     LVCMOS33         [get_ports fpga_uart1_txd_r]      ;# Bank 88   - 3V3_VCC0  - FPGA_UART1_TXD_R          - IO_L3P_AD9P_88_BC14


#################################################################################
#
#  I2C Interface to ...
#       Jitter Cleaner 1 & 2,
#       Clock Generator,
#       DDR Power Enable I2C I/O Expander
#
#################################################################################

set_property PACKAGE_PIN    AR20             [get_ports clkgen_scl_r]          ;# Bank 65   - 1V8_SYS   - CLKGEN_SCL_R              - IO_L23P_T3U_N8_I2C_SCLK_65_AR20
set_property IOSTANDARD     LVCMOS18         [get_ports clkgen_scl_r]          ;# Bank 65   - 1V8_SYS   - CLKGEN_SCL_R              - IO_L23P_T3U_N8_I2C_SCLK_65_AR20
set_property PACKAGE_PIN    AT20             [get_ports clkgen_sda_r]          ;# Bank 65   - 1V8_SYS   - CLKGEN_SDA_R              - IO_L23N_T3U_N9_PERSTN1_I2C_SDA_65_AT20
set_property IOSTANDARD     LVCMOS18         [get_ports clkgen_sda_r]          ;# Bank 65   - 1V8_SYS   - CLKGEN_SDA_R              - IO_L23N_T3U_N9_PERSTN1_I2C_SDA_65_AT20


#################################################################################
#
#  DDR Power Enable I/O Expander Reset
#
#################################################################################

# Active Low Reset to DDR Power Enable I/O Expander - External Pulldown - Bank 65 (1.8V)
set_property PACKAGE_PIN    AU19             [get_ports ddr_psuio_reset]       ;# Bank 65   - 1V8_SYS   - DDR_PSUIO_RESET           - IO_L22N_T3U_N7_DBC_AD0N_D05_65_AU19
set_property IOSTANDARD     LVCMOS18         [get_ports ddr_psuio_reset]       ;# Bank 65   - 1V8_SYS   - DDR_PSUIO_RESET           - IO_L22N_T3U_N7_DBC_AD0N_D05_65_AU19


#################################################################################
#
#  Clock Generator Connection Signals...Bank 65 (1.8V)
#
#################################################################################

# Active Low Loss of Lock Signal from Clock Generator
set_property PACKAGE_PIN    BE16             [get_ports clkgen_apll_lol]       ;# Bank 65   - 1V8_SYS   - CLKGEN_APLL_LOL           - IO_L1N_T0L_N1_DBC_RS1_65_BE16
set_property IOSTANDARD     LVCMOS18         [get_ports clkgen_apll_lol]       ;# Bank 65   - 1V8_SYS   - CLKGEN_APLL_LOL           - IO_L1N_T0L_N1_DBC_RS1_65_BE16
                                                                                            
# Active Low Reset Signal to Clock Generator                                                
set_property PACKAGE_PIN    AT18             [get_ports clkgen_rst_b_r]        ;# Bank 65   - 1V8_SYS   - CLKGEN_RST_B_R            - IO_L21N_T3L_N5_AD8N_D07_65_AT18
set_property IOSTANDARD     LVCMOS18         [get_ports clkgen_rst_b_r]        ;# Bank 65   - 1V8_SYS   - CLKGEN_RST_B_R            - IO_L21N_T3L_N5_AD8N_D07_65_AT18


#################################################################################
#
#  Miscellaneous Connections....
#
#################################################################################

#
#  PPS Connection - Bank 88 (3.3V)
#     Uncomment following properties if PPS pins used in your design
#
# set_property PACKAGE_PIN    BF14            [get_ports pps_in_fpga]            ;# Bank 88   - 3V3_VCC0  - PPS_IN_FPGA               - IO_L1N_AD11N_88_BF14
# set_property IOSTANDARD     LVCMOS33        [get_ports pps_in_fpga]            ;# Bank 88   - 3V3_VCC0  - PPS_IN_FPGA               - IO_L1N_AD11N_88_BF14
# set_property PACKAGE_PIN    BF15            [get_ports pps_out_fpga]           ;# Bank 88   - 3V3_VCC0  - PPS_OUT_FPGA              - IO_L1P_AD11P_88_BF15
# set_property IOSTANDARD     LVCMOS33        [get_ports pps_out_fpga]           ;# Bank 88   - 3V3_VCC0  - PPS_OUT_FPGA              - IO_L1P_AD11P_88_BF15
                                                                                              
#                                                                                             
#  75Mhz Osc for FPGA Configuration - Bank 65 (1.8V)                                          
#     This pin is meant for configuration, not general use                                    
#                                                                                             
# set_property PACKAGE_PIN    AP20            [get_ports clk_emcclk_75m_bank65]  ;# Bank 65   - 1V8_SYS   - CLK_EMCCLK_75M_BANK65     - IO_L24P_T3U_N10_EMCCLK_65_AP20
# set_property IOSTANDARD     LVCMOS18        [get_ports clk_emcclk_75m_bank65]  ;# Bank 65   - 1V8_SYS   - CLK_EMCCLK_75M_BANK65     - IO_L24P_T3U_N10_EMCCLK_65_AP20
                                                                                                                                    
#                                                                                                                                   
#  Probe Point - Bank 65 (1.8V)                                                                                                     
#     Uncomment following properties if TESTCLK used in your design                                                                 
#     TESTCLK is a testpoint on the card and not accessible                                                                         
#                                                                                                                                   
# set_property PACKAGE_PIN    BD16            [get_ports testclk_out]            ;# Bank 65   - 1V8_SYS   - TESTCLK_OUT               - IO_L1P_T0L_N0_DBC_RS0_65_BD16
# set_property IOSTANDARD     LVCMOS18        [get_ports testclk_out]            ;# Bank 65   - 1V8_SYS   - TESTCLK_OUT               - IO_L1P_T0L_N0_DBC_RS0_65_BD16


#################################################################################
#
#  FPGA Programming I/O...Bank 0 (1.8V)
#
#################################################################################
# set_property PACKAGE_PIN    BF12            [get_ports fpga_cclk_r]            ;# Bank 0    - 1V8_VCC0  - FPGA_CCLK_R               - CCLK_0_BF12
# set_property IOSTANDARD     LVCMOS18        [get_ports fpga_cclk_r]            ;# Bank 0    - 1V8_VCC0  - FPGA_CCLK_R               - CCLK_0_BF12
# set_property PACKAGE_PIN    AV13            [get_ports boot_mode0]             ;# Bank 0    - 1V8_VCC0  - BOOT_MODE0                - M0_0_AV13
# set_property IOSTANDARD     LVCMOS18        [get_ports boot_mode0]             ;# Bank 0    - 1V8_VCC0  - BOOT_MODE0                - M0_0_AV13
# set_property PACKAGE_PIN    AW13            [get_ports boot_mode1]             ;# Bank 0    - 1V8_VCC0  - BOOT_MODE1                - M1_0_AW13
# set_property IOSTANDARD     LVCMOS18        [get_ports boot_mode1]             ;# Bank 0    - 1V8_VCC0  - BOOT_MODE1                - M1_0_AW13
# set_property PACKAGE_PIN    AW11            [get_ports boot_mode2]             ;# Bank 0    - 1V8_VCC0  - BOOT_MODE2                - M2_0_AW11
# set_property IOSTANDARD     LVCMOS18        [get_ports boot_mode2]             ;# Bank 0    - 1V8_VCC0  - BOOT_MODE2                - M2_0_AW11
# set_property PACKAGE_PIN    BA12            [get_ports done_0]                 ;# Bank 0    - 1V8_VCC0  - DONE_0                    - DONE_0_BA12
# set_property IOSTANDARD     LVCMOS18        [get_ports done_0]                 ;# Bank 0    - 1V8_VCC0  - DONE_0                    - DONE_0_BA12
# set_property PACKAGE_PIN    BC11            [get_ports fpga_spi_cs]            ;# Bank 0    - 1V8_VCC0  - FPGA_SPI_CS               - RDWR_FCS_B_0_BC11
# set_property IOSTANDARD     LVCMOS18        [get_ports fpga_spi_cs]            ;# Bank 0    - 1V8_VCC0  - FPGA_SPI_CS               - RDWR_FCS_B_0_BC11
# set_property PACKAGE_PIN    BD13            [get_ports fpga_spi_dq0]           ;# Bank 0    - 1V8_VCC0  - FPGA_SPI_DQ0              - D00_MOSI_0_BD13
# set_property IOSTANDARD     LVCMOS18        [get_ports fpga_spi_dq0]           ;# Bank 0    - 1V8_VCC0  - FPGA_SPI_DQ0              - D00_MOSI_0_BD13
# set_property PACKAGE_PIN    BE12            [get_ports fpga_spi_dq1]           ;# Bank 0    - 1V8_VCC0  - FPGA_SPI_DQ1              - D01_DIN_0_BE12
# set_property IOSTANDARD     LVCMOS18        [get_ports fpga_spi_dq1]           ;# Bank 0    - 1V8_VCC0  - FPGA_SPI_DQ1              - D01_DIN_0_BE12
# set_property PACKAGE_PIN    BD11            [get_ports fpga_spi_dq2_wp#]       ;# Bank 0    - 1V8_VCC0  - FPGA_SPI_DQ2_WP#          - D02_0_BD11
# set_property IOSTANDARD     LVCMOS18        [get_ports fpga_spi_dq2_wp#]       ;# Bank 0    - 1V8_VCC0  - FPGA_SPI_DQ2_WP#          - D02_0_BD11
# set_property PACKAGE_PIN    BE11            [get_ports fpga_spi_dq3_hold_b]    ;# Bank 0    - 1V8_VCC0  - FPGA_SPI_DQ3_HOLD_B       - D03_0_BE11
# set_property IOSTANDARD     LVCMOS18        [get_ports fpga_spi_dq3_hold_b]    ;# Bank 0    - 1V8_VCC0  - FPGA_SPI_DQ3_HOLD_B       - D03_0_BE11
# set_property PACKAGE_PIN    BF13            [get_ports fpga_tck]               ;# Bank 0    - 1V8_VCC0  - FPGA_TCK                  - TCK_0_BF13
# set_property IOSTANDARD     LVCMOS18        [get_ports fpga_tck]               ;# Bank 0    - 1V8_VCC0  - FPGA_TCK                  - TCK_0_BF13
# set_property PACKAGE_PIN    BC13            [get_ports fpga_tdi]               ;# Bank 0    - 1V8_VCC0  - FPGA_TDI                  - TDI_0_BC13
# set_property IOSTANDARD     LVCMOS18        [get_ports fpga_tdi]               ;# Bank 0    - 1V8_VCC0  - FPGA_TDI                  - TDI_0_BC13
# set_property PACKAGE_PIN    BE13            [get_ports fpga_tms]               ;# Bank 0    - 1V8_VCC0  - FPGA_TMS                  - TMS_0_BE13
# set_property IOSTANDARD     LVCMOS18        [get_ports fpga_tms]               ;# Bank 0    - 1V8_VCC0  - FPGA_TMS                  - TMS_0_BE13
# set_property PACKAGE_PIN    AY13            [get_ports init_b_0]               ;# Bank 0    - 1V8_VCC0  - INIT_B_0                  - INIT_B_0_AY13
# set_property IOSTANDARD     LVCMOS18        [get_ports init_b_0]               ;# Bank 0    - 1V8_VCC0  - INIT_B_0                  - INIT_B_0_AY13
# set_property PACKAGE_PIN    BB11            [get_ports program_b_0]            ;# Bank 0    - 1V8_VCC0  - PROGRAM_B_0               - PROGRAM_B_0_BB11
# set_property IOSTANDARD     LVCMOS18        [get_ports program_b_0]            ;# Bank 0    - 1V8_VCC0  - PROGRAM_B_0               - PROGRAM_B_0_BB11
# set_property PACKAGE_PIN    BA13            [get_ports pudc_b_0]               ;# Bank 0    - 1V8_VCC0  - PUDC_B_0                  - PUDC_B_0_BA13
# set_property IOSTANDARD     LVCMOS18        [get_ports pudc_b_0]               ;# Bank 0    - 1V8_VCC0  - PUDC_B_0                  - PUDC_B_0_BA13

################################################################################
#
#  LVDS Input Clock References...
#
################################################################################

#                                                                                        
#  300 Mhz Reference clock for DDR1, Bank 66 (1.2V)                                      
#                                                                                        
#create_clock -period 3.333 -name clk_ddr_lvds_300_p   [get_ports clk_ddr_lvds_300_p]

#                                                                                        
#  300 Mhz Reference clock, Bank 65 (1.8V)                                               
#                                                                                        
#create_clock -period 3.333 -name clk_sys_lvds_300_p   [get_ports clk_sys_lvds_300_p]

#
#  LVDS Input Reference Clock for PCIe, Bank 225 (1.2V)
#    Typical GT pin constraints are embedded in the IP
#
create_clock -name sys_clk -period 10 [get_ports pcie_refclk_buf_p]

# -------------------------------------------------------------------

# ASYNC CLOCK GROUPINGS

set SYS_CLK     [get_clocks sys_clk]
set TXOUTCLK    [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ *gen_channel_container[1].*gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set PCIE_CLK    [get_clocks -of_objects [get_pins design_1_wrapper/design_1_i/xdma_0/inst/pcie4c_ip_i/inst/design_1_xdma_0_0_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_pclk/O]] 
set PCIE_CLK2   [get_clocks -of_objects [get_pins design_1_wrapper/design_1_i/xdma_0/inst/pcie4c_ip_i/inst/design_1_xdma_0_0_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_intclk/O]]


set_clock_groups -name async18 \
                 -asynchronous \
                 -group $SYS_CLK \
                 -group $TXOUTCLK 
                 
set_clock_groups -name async19 \
                 -asynchronous \
                 -group $TXOUTCLK \
                 -group $SYS_CLK

set_clock_groups -name async1 \
                 -asynchronous \
                 -group $SYS_CLK \
                 -group $PCIE_CLK

set_clock_groups -name async2 \
                 -asynchronous \
                 -group $PCIE_CLK \
                 -group $SYS_CLK

set_clock_groups -name async24 \
                 -asynchronous \
                 -group $PCIE_CLK2 \
                 -group $SYS_CLK

