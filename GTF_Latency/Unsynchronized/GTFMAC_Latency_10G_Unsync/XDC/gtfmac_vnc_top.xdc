#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

################################################################################
#
# Freerun Clock
#
################################################################################
#
#  300 Mhz Reference clock, Bank 65 (1.8V)     
#      CLK13_LVDS_300_P/N

set_property PACKAGE_PIN AW18 [get_ports "hb_gtwiz_reset_clk_freerun_n_in"] 
set_property PACKAGE_PIN AW19 [get_ports "hb_gtwiz_reset_clk_freerun_p_in"] 
set_property IOSTANDARD  LVDS [get_ports "hb_gtwiz_reset_clk_freerun_n_in"] 
set_property IOSTANDARD  LVDS [get_ports "hb_gtwiz_reset_clk_freerun_p_in"] 

################################################################################
#
# GTF QSFP-DD 1 (Bank 230)
#
################################################################################
#
#  161.1343861 Mhz Ref Clock
#
create_clock -period 6.206   [get_ports refclk_p]
set_property PACKAGE_PIN U11 [get_ports refclk_p]
set_property PACKAGE_PIN U10 [get_ports refclk_n]

#
#  TX1_P/N, RX1_P/N
#
set_property PACKAGE_PIN Y9 [get_ports gtf_ch_gtftxp]
set_property PACKAGE_PIN Y8 [get_ports gtf_ch_gtftxn]
set_property PACKAGE_PIN V4 [get_ports gtf_ch_gtfrxp]
set_property PACKAGE_PIN V3 [get_ports gtf_ch_gtfrxn]

#
#  GT Location
#
set_property LOC GTF_COMMON_X1Y6   [get_cells -hierarchical -filter {NAME =~ i_gtfmac/example_gtf_common_inst/gtf_common_inst}]
set_property LOC GTF_CHANNEL_X1Y24 [get_cells -hierarchical -filter {NAME =~ i_gtfmac/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst}]


################################################################################
#
# Clock Contraints
#
#################################################################################
create_generated_clock -name CLK_RXOUTCLK [get_pins i_gtfmac/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK]
create_generated_clock -name CLK_TXOUTCLK [get_pins i_gtfmac/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK]

################################################################################
#
# False Path Contraints
#
################################################################################
set_false_path -from [get_clocks CLK_RXOUTCLK] -to [get_clocks -of_objects [get_pins clk_wiz_0_inst/inst/mmcme4_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks CLK_RXOUTCLK] -to [get_clocks -of_objects [get_pins clk_wiz_0_inst/inst/mmcme4_adv_inst/CLKOUT1]]
set_false_path -from [get_clocks CLK_RXOUTCLK] -to [get_clocks CLK_TXOUTCLK]

set_false_path -from [get_clocks CLK_TXOUTCLK] -to [get_clocks -of_objects [get_pins clk_wiz_0_inst/inst/mmcme4_adv_inst/CLKOUT0]] 
set_false_path -from [get_clocks CLK_TXOUTCLK] -to [get_clocks -of_objects [get_pins clk_wiz_0_inst/inst/mmcme4_adv_inst/CLKOUT1]] 
set_false_path -from [get_clocks CLK_TXOUTCLK] -to [get_clocks CLK_RXOUTCLK]

set_false_path -from [get_clocks -of_objects [get_pins clk_wiz_0_inst/inst/mmcme4_adv_inst/CLKOUT0]] -to [get_clocks CLK_RXOUTCLK]
set_false_path -from [get_clocks -of_objects [get_pins clk_wiz_0_inst/inst/mmcme4_adv_inst/CLKOUT0]] -to [get_clocks CLK_TXOUTCLK] 
set_false_path -from [get_clocks -of_objects [get_pins clk_wiz_0_inst/inst/mmcme4_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins clk_wiz_0_inst/inst/mmcme4_adv_inst/CLKOUT1]] 

set_false_path -from [get_clocks -of_objects [get_pins clk_wiz_0_inst/inst/mmcme4_adv_inst/CLKOUT1]] -to [get_clocks CLK_RXOUTCLK]
set_false_path -from [get_clocks -of_objects [get_pins clk_wiz_0_inst/inst/mmcme4_adv_inst/CLKOUT1]] -to [get_clocks CLK_TXOUTCLK] 
set_false_path -from [get_clocks -of_objects [get_pins clk_wiz_0_inst/inst/mmcme4_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins clk_wiz_0_inst/inst/mmcme4_adv_inst/CLKOUT0]] 


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
