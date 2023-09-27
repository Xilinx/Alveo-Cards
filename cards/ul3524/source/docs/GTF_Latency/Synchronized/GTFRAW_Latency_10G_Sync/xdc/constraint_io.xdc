#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
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

#                                                                                        
#  300 Mhz Reference clock for QDRII+ 1, Bank 71 (1.5V)                                  
#                                                                                        
#set_property PACKAGE_PIN G27                 [get_ports "CLK11_LVDS_300_N"]              ;# Bank  71 VCCO - +1V5_SYS                               - IO_L12N_T1U_N11_GC_71
#set_property IOSTANDARD  LVDS                [get_ports "CLK11_LVDS_300_N"]              ;# Bank  71 VCCO - +1V5_SYS                               - IO_L12N_T1U_N11_GC_71
#set_property PACKAGE_PIN G26                 [get_ports "CLK11_LVDS_300_P"]              ;# Bank  71 VCCO - +1V5_SYS                               - IO_L12P_T1U_N10_GC_71
#set_property IOSTANDARD  LVDS                [get_ports "CLK11_LVDS_300_P"]              ;# Bank  71 VCCO - +1V5_SYS                               - IO_L12P_T1U_N10_GC_71
                                                                                         
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
#set_property PACKAGE_PIN M16                 [get_ports "QSFPDD0_IO_RESET_B"]            ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L4P_AD12P_93
#set_property IOSTANDARD  LVCMOS33            [get_ports "QSFPDD0_IO_RESET_B"]            ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L4P_AD12P_93
#set_property PACKAGE_PIN H16                 [get_ports "QSFPDD1_IO_RESET_B"]            ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L8N_HDGC_93
#set_property IOSTANDARD  LVCMOS33            [get_ports "QSFPDD1_IO_RESET_B"]            ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L8N_HDGC_93
#set_property PACKAGE_PIN F15                 [get_ports "QSFPDD2_IO_RESET_B"]            ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L9N_AD11N_93
#set_property IOSTANDARD  LVCMOS33            [get_ports "QSFPDD2_IO_RESET_B"]            ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L9N_AD11N_93
#set_property PACKAGE_PIN G16                 [get_ports "QSFPDD3_IO_RESET_B"]            ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L9P_AD11P_93
#set_property IOSTANDARD  LVCMOS33            [get_ports "QSFPDD3_IO_RESET_B"]            ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L9P_AD11P_93

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

#set_property PACKAGE_PIN F12                 [get_ports "FPGA_SCL_R"]                  ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L12P_AD8P_93
#set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_SCL_R"]                  ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L12P_AD8P_93
#set_property PACKAGE_PIN F11                 [get_ports "FPGA_SDA_R"]                  ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L12N_AD8N_93
#set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_SDA_R"]                  ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L12N_AD8N_93
#
#set_property PACKAGE_PIN G14                 [get_ports "FPGA_MUX0_RSTN"]              ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L11P_AD9P_93
#set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_MUX0_RSTN"]              ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L11P_AD9P_93
#set_property PACKAGE_PIN G15                 [get_ports "FPGA_MUX1_RSTN"]              ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L10P_AD10P_93
#set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_MUX1_RSTN"]              ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L10P_AD10P_93
#
##set_property PACKAGE_PIN F13                 [get_ports "FPGA_MUX0_INTN"]              ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L11N_AD9N_93
##set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_MUX0_INTN"]              ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L11N_AD9N_93
##set_property PACKAGE_PIN F14                 [get_ports "FPGA_MUX1_INTN"]              ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L10N_AD10N_93
##set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_MUX1_INTN"]              ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L10N_AD10N_93
##set_property PACKAGE_PIN J16                 [get_ports "FPGA_OC_INTN"]                ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L8P_HDGC_93
##set_property IOSTANDARD  LVCMOS33            [get_ports "FPGA_OC_INTN"]                ;# Bank  93 VCCO - +3V3_SYS_FPGA                          - IO_L8P_HDGC_93


#################################################################################
#
# GTF SYNCE INPUT CLOCK PORTS
#
#################################################################################

#
#  QSFPDD 3 GTF Connections - Bank 226, 227
#    Typical pin constraints are embedded in the IP
#
set_property PACKAGE_PIN AJ10                [get_ports "SYNCE_CLK11_LVDS_N"]            ;# Bank 227 - MGTREFCLK0N_227
set_property PACKAGE_PIN AJ11                [get_ports "SYNCE_CLK11_LVDS_P"]            ;# Bank 227 - MGTREFCLK0P_227

#set_property PACKAGE_PIN AN10                [get_ports "SYNCE_CLK10_LVDS_N"]            ;# Bank 226 - MGTREFCLK0N_226
#set_property PACKAGE_PIN AN11                [get_ports "SYNCE_CLK10_LVDS_P"]            ;# Bank 226 - MGTREFCLK0P_226


#################################################################################
#
# Mapping...
#
#################################################################################

#   QSFP    Ports   Bank    ClockRegion    SYNC CLK
#   0       0       227     X5Y3           SYNCE_CLK11_LVDS_N


#################################################################################
#
# GT Location
#
#################################################################################

# Bank 227

set_property LOC GTF_COMMON_X1Y3    [get_cells -hierarchical -filter {NAME =~ u_gtfwizard_raw_example_top/example_gtf_common_inst/gtf_common_inst}]
#set_property LOC GTF_CHANNEL_X1Y16  [get_cells -hierarchical -filter {NAME =~ u_gtfwizard_raw_example_top/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst}]


set_property CLOCK_DEDICATED_ROUTE FALSE          [get_nets u_gtfwizard_raw_example_top/example_gtf_common_inst/gtf_ch_qpll0clk]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets u_gtfwizard_raw_example_top/example_gtf_common_inst/gtf_ch_qpll1clk]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets u_gtfwizard_raw_example_top/example_gtf_common_inst/gtf_ch_qpll0refclk]


#################################################################################
#
# GTF QSFP 0[1:4]
#
#################################################################################

# bank 227
set_property PACKAGE_PIN AK3 [get_ports gtf_ch_gtfrxn[0]]
set_property PACKAGE_PIN AK4 [get_ports gtf_ch_gtfrxp[0]]
#set_property PACKAGE_PIN AJ1 [get_ports gtf_ch_gtfrxn[1]]
#set_property PACKAGE_PIN AJ2 [get_ports gtf_ch_gtfrxp[1]]
#set_property PACKAGE_PIN AH3 [get_ports gtf_ch_gtfrxn[2]]
#set_property PACKAGE_PIN AH4 [get_ports gtf_ch_gtfrxp[2]]
#set_property PACKAGE_PIN AG1 [get_ports gtf_ch_gtfrxn[3]]
#set_property PACKAGE_PIN AG2 [get_ports gtf_ch_gtfrxp[3]]
set_property PACKAGE_PIN AM8 [get_ports gtf_ch_gtftxn[0]]
set_property PACKAGE_PIN AM9 [get_ports gtf_ch_gtftxp[0]]
#set_property PACKAGE_PIN AL6 [get_ports gtf_ch_gtftxn[1]]
#set_property PACKAGE_PIN AL7 [get_ports gtf_ch_gtftxp[1]]
#set_property PACKAGE_PIN AK8 [get_ports gtf_ch_gtftxn[2]]
#set_property PACKAGE_PIN AK9 [get_ports gtf_ch_gtftxp[2]]
#set_property PACKAGE_PIN AJ6 [get_ports gtf_ch_gtftxn[3]]
#set_property PACKAGE_PIN AJ7 [get_ports gtf_ch_gtftxp[3]]


#################################################################################
#
# Restrict QSFP0[0:3] Logic to Row Y3 (bank 228)
#
#################################################################################

set pblock_qsfp_0_lo [create_pblock pblock_qsfp_0_lo]
resize_pblock $pblock_qsfp_0_lo -add CLOCKREGION_X0Y3:CLOCKREGION_X5Y3

add_cells_to_pblock $pblock_qsfp_0_lo [get_cells -hierarchical -filter {NAME =~ u_gtfwizard_raw_example_top/gen_blk_multi_ch[0].*}]
#add_cells_to_pblock $pblock_qsfp_0_lo [get_cells -hierarchical -filter {NAME =~ u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[0].i_gtfmac_hwchk_core}]

##################################################################################
##
## Restrict RX/TX GTFMAC IF and Rate Adapter Buffers close to GTF resources
##
##################################################################################
#
#set PBLOCK_X4Y3_X5Y3 [create_pblock PBLOCK_X4Y3_X5Y3]
#resize_pblock $PBLOCK_X4Y3_X5Y3 -add CLOCKREGION_X4Y3:CLOCKREGION_X5Y3
#
#add_cells_to_pblock $PBLOCK_X4Y3_X5Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[0]*" &&  NAME =~  "*i_rx_mon*" && NAME =~  "*i_rx_gtfmac_if*" } ] 
##add_cells_to_pblock $PBLOCK_X4Y3_X5Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[1]*" &&  NAME =~  "*i_rx_mon*" && NAME =~  "*i_rx_gtfmac_if*" } ] 
##add_cells_to_pblock $PBLOCK_X4Y3_X5Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[2]*" &&  NAME =~  "*i_rx_mon*" && NAME =~  "*i_rx_gtfmac_if*" } ] 
##add_cells_to_pblock $PBLOCK_X4Y3_X5Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[3]*" &&  NAME =~  "*i_rx_mon*" && NAME =~  "*i_rx_gtfmac_if*" } ] 
#
#add_cells_to_pblock $PBLOCK_X4Y3_X5Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[0]*" &&  NAME =~  "*i_rx_mon*" && NAME =~  "*i_rx_mon_buf*" } ]   
##add_cells_to_pblock $PBLOCK_X4Y3_X5Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[1]*" &&  NAME =~  "*i_rx_mon*" && NAME =~  "*i_rx_mon_buf*" } ]   
##add_cells_to_pblock $PBLOCK_X4Y3_X5Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[2]*" &&  NAME =~  "*i_rx_mon*" && NAME =~  "*i_rx_mon_buf*" } ]   
##add_cells_to_pblock $PBLOCK_X4Y3_X5Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[3]*" &&  NAME =~  "*i_rx_mon*" && NAME =~  "*i_rx_mon_buf*" } ]   
#
#add_cells_to_pblock $PBLOCK_X4Y3_X5Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[0]*" &&  NAME =~  "*i_tx_gen*" && NAME =~  "*i_tx_gtfmac_if*" } ] 
##add_cells_to_pblock $PBLOCK_X4Y3_X5Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[1]*" &&  NAME =~  "*i_tx_gen*" && NAME =~  "*i_tx_gtfmac_if*" } ] 
##add_cells_to_pblock $PBLOCK_X4Y3_X5Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[2]*" &&  NAME =~  "*i_tx_gen*" && NAME =~  "*i_tx_gtfmac_if*" } ] 
##add_cells_to_pblock $PBLOCK_X4Y3_X5Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[3]*" &&  NAME =~  "*i_tx_gen*" && NAME =~  "*i_tx_gtfmac_if*" } ] 
#
#add_cells_to_pblock $PBLOCK_X4Y3_X5Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[0]*" &&  NAME =~  "*i_tx_gen*" && NAME =~  "*i_tx_gen_buf*" } ]   
##add_cells_to_pblock $PBLOCK_X4Y3_X5Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[1]*" &&  NAME =~  "*i_tx_gen*" && NAME =~  "*i_tx_gen_buf*" } ]   
##add_cells_to_pblock $PBLOCK_X4Y3_X5Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[2]*" &&  NAME =~  "*i_tx_gen*" && NAME =~  "*i_tx_gen_buf*" } ]   
##add_cells_to_pblock $PBLOCK_X4Y3_X5Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[3]*" &&  NAME =~  "*i_tx_gen*" && NAME =~  "*i_tx_gen_buf*" } ]   
#
#set PBLOCK_X3Y3_X4Y3 [create_pblock PBLOCK_X3Y3_X4Y3]
#resize_pblock $PBLOCK_X3Y3_X4Y3 -add CLOCKREGION_X3Y3:CLOCKREGION_X4Y3
#
#add_cells_to_pblock $PBLOCK_X3Y3_X4Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[0]*" &&  NAME =~  "*i_rx_mon*" && NAME =~  "*i_rx_fcs*" } ]       
##add_cells_to_pblock $PBLOCK_X3Y3_X4Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[1]*" &&  NAME =~  "*i_rx_mon*" && NAME =~  "*i_rx_fcs*" } ]       
##add_cells_to_pblock $PBLOCK_X3Y3_X4Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[2]*" &&  NAME =~  "*i_rx_mon*" && NAME =~  "*i_rx_fcs*" } ]       
##add_cells_to_pblock $PBLOCK_X3Y3_X4Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[3]*" &&  NAME =~  "*i_rx_mon*" && NAME =~  "*i_rx_fcs*" } ]       
#
#add_cells_to_pblock $PBLOCK_X3Y3_X4Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[0]*" &&  NAME =~  "*i_rx_mon*" && NAME =~  "*i_mon_parser*" } ]   
##add_cells_to_pblock $PBLOCK_X3Y3_X4Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[1]*" &&  NAME =~  "*i_rx_mon*" && NAME =~  "*i_mon_parser*" } ]   
##add_cells_to_pblock $PBLOCK_X3Y3_X4Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[2]*" &&  NAME =~  "*i_rx_mon*" && NAME =~  "*i_mon_parser*" } ]   
##add_cells_to_pblock $PBLOCK_X3Y3_X4Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[3]*" &&  NAME =~  "*i_rx_mon*" && NAME =~  "*i_mon_parser*" } ]   
#
#add_cells_to_pblock $PBLOCK_X3Y3_X4Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[0]*" &&  NAME =~  "*i_tx_gen*" && NAME =~  "*i_tx_fcs*" } ]       
##add_cells_to_pblock $PBLOCK_X3Y3_X4Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[1]*" &&  NAME =~  "*i_tx_gen*" && NAME =~  "*i_tx_fcs*" } ]       
##add_cells_to_pblock $PBLOCK_X3Y3_X4Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[2]*" &&  NAME =~  "*i_tx_gen*" && NAME =~  "*i_tx_fcs*" } ]       
##add_cells_to_pblock $PBLOCK_X3Y3_X4Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[3]*" &&  NAME =~  "*i_tx_gen*" && NAME =~  "*i_tx_fcs*" } ]       
#
#add_cells_to_pblock $PBLOCK_X3Y3_X4Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[0]*" &&  NAME =~  "*i_tx_gen*" && NAME =~  "*i_tx_frm_gen*" } ]   
##add_cells_to_pblock $PBLOCK_X3Y3_X4Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[1]*" &&  NAME =~  "*i_tx_gen*" && NAME =~  "*i_tx_frm_gen*" } ]   
##add_cells_to_pblock $PBLOCK_X3Y3_X4Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[2]*" &&  NAME =~  "*i_tx_gen*" && NAME =~  "*i_tx_frm_gen*" } ]   
##add_cells_to_pblock $PBLOCK_X3Y3_X4Y3 [get_cells -hierarchical -filter { NAME =~  "*u_gtfwizard_mac_gtfmac_ex/gtfmac_hwchk_core_gen[3]*" &&  NAME =~  "*i_tx_gen*" && NAME =~  "*i_tx_frm_gen*" } ]   
#
