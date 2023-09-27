#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

## Project    : UltraScale+ FPGA PCI Express CCIX v4.0 Integrated Block
## File       : xilinx_pcie4_uscale_plus_x0y0.xdc
## Version    : 1.0 
##-----------------------------------------------------------------------------
#
################################################################################
# Vivado - PCIe GUI / User Configuration 
################################################################################
# Link Speed   - Gen4 - 16.0 Gb/s
# Link Width   - X8
# AXIST Width  - 512-bit
# AXIST Frequ  - 250 MHz = User Clock
# Core Clock   - 500 MHz
# Pipe Clock   - 125 MHz (Gen1) / 250 MHz (Gen2/Gen3/Gen4)
#
# Family       - virtexuplus
# Part         - xcvu2p
# Package      - fsvj2104
# Speed grade  - -3
# PCIe Block   - X0Y0
#
#
#
# Enabled - GEN4_EIEOS: (Spec 0.7 -> 0.5+) 
#
# PLL TYPE     - QPLL0
#
##########################################################################################################################
# # # #                            User Time Names / User Time Groups / Time Specs                                 # # # #
##########################################################################################################################
create_clock -name sys_clk -period 10 [get_ports sys_clk_p]
# False path constraint on sys_rst_n is now moved to IP level *_impl_*.xdc file. Please check design source/* area for reference.
# set_false_path -from [get_ports sys_rst_n]
#set_property PULLUP true [get_ports sys_rst_n]
#set_property IOSTANDARD LVCMOS18 [get_ports sys_rst_n]

#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *_PERSTN0_65}] [get_ports sys_rst_n] 
#
##########################################################################################################################
# # # #                                                                                                            # # # #
##########################################################################################################################
#
#
#set_property LOC [get_package_pins -of_objects [get_bels [get_sites -filter {NAME =~ *COMMON*} -of_objects [get_iobanks -of_objects [get_sites GTYE4_CHANNEL_X0Y7]]]/REFCLK0P]] [get_ports sys_clk_p]
#set_property LOC [get_package_pins -of_objects [get_bels [get_sites -filter {NAME =~ *COMMON*} -of_objects [get_iobanks -of_objects [get_sites GTYE4_CHANNEL_X0Y7]]]/REFCLK0N]] [get_ports sys_clk_n]




##########################################################################################################################
# # # #                                                                                                            # # # #
##########################################################################################################################
#
# BITFILE/BITSTREAM compress options
# Flash type constraints. These should be modified to match the target board.
#set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
#set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type1 [current_design]
#set_property CONFIG_MODE BPI16 [current_design]
#set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
#set_property BITSTREAM.CONFIG.UNUSEDPIN Pulldown [current_design]
#
#
#
#
# ASYNC CLOCK GROUPINGS
# sys_clk vs TXOUTCLK
set_clock_groups -name async18 -asynchronous -group [get_clocks {sys_clk}] -group [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ *gen_channel_container[1].*gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -name async19 -asynchronous -group [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ *gen_channel_container[1].*gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]] -group [get_clocks {sys_clk}]
# sys_clk vs pclk
set_clock_groups -name async1 -asynchronous \
    -group [get_clocks {sys_clk}] \
    -group [get_clocks -of_objects [get_pins design_1_wrapper/design_1_i/xdma_0/inst/pcie4c_ip_i/inst/design_1_xdma_0_0_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_pclk/O]]

set_clock_groups -name async2 -asynchronous \
    -group [get_clocks -of_objects [get_pins design_1_wrapper/design_1_i/xdma_0/inst/pcie4c_ip_i/inst/design_1_xdma_0_0_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_pclk/O]] \
    -group [get_clocks {sys_clk}]

#
#
#
# Add/Edit Pblock slice constraints for 512b soft logic to improve timing
#create_pblock soft_512b; add_cells_to_pblock [get_pblocks soft_512b] [get_cells {pcie4c_uscale_plus_0_i/inst/pcie4c_uscale_plus_0_pcie_4_0_pipe_inst/pcie_4_0_init_ctrl_inst pcie4c_uscale_plus_0_i/inst/pcie4c_uscale_plus_0_pcie_4_0_pipe_inst/pcie4_0_512b_intfc_mod}]
# Keep This Logic Left/Right Side Of The PCIe Block (Whichever is near to the FPGA Boundary)
#resize_pblock [get_pblocks soft_512b] -add {SLICE_X0Y181:SLICE_X11Y238}
#set_property EXCLUDE_PLACEMENT 1 [get_pblocks soft_512b]
#
set_clock_groups -name async24 -asynchronous \
    -group [get_clocks -of_objects [get_pins design_1_wrapper/design_1_i/xdma_0/inst/pcie4c_ip_i/inst/design_1_xdma_0_0_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_intclk/O]] \
    -group [get_clocks {sys_clk}]

#create_waiver -type METHODOLOGY -id {LUTAR-1} -user "pcie4c_uscale_plus" -desc "user link up is synchroized in the user clk so it is safe to ignore"  -internal -scoped -tags 1024539  -objects [get_cells { pcie_app_uscale_i/PIO_i/len_i[5]_i_4 }] -objects [get_pins { pcie4c_uscale_plus_0_i/inst/user_lnk_up_cdc/arststages_ff_reg[0]/CLR pcie4c_uscale_plus_0_i/inst/user_lnk_up_cdc/arststages_ff_reg[1]/CLR }] 


#################################################################################
#                                                                                        
#  300 Mhz Reference clock for DDR1, Bank 66 (1.2V)                                      
#                                                                                        
#################################################################################
set_property PACKAGE_PIN AY22                [get_ports "C0_SYS_CLK_0_clk_n"]              ;# Bank  66 VCCO - 1V2_VCCO                               - IO_L13N_T2L_N1_GC_QBC_66
set_property IOSTANDARD  LVDS                [get_ports "C0_SYS_CLK_0_clk_n"]              ;# Bank  66 VCCO - 1V2_VCCO                               - IO_L13N_T2L_N1_GC_QBC_66
set_property PACKAGE_PIN AW23                [get_ports "C0_SYS_CLK_0_clk_p"]              ;# Bank  66 VCCO - 1V2_VCCO                               - IO_L13P_T2L_N0_GC_QBC_66
set_property IOSTANDARD  LVDS                [get_ports "C0_SYS_CLK_0_clk_p"]              ;# Bank  66 VCCO - 1V2_VCCO                               - IO_L13P_T2L_N0_GC_QBC_66
                                                                                         
#################################################################################
#                                                                                        
#  300 Mhz Reference clock, Bank 65 (1.8V)                                               
#                                                                                        
#################################################################################
set_property PACKAGE_PIN AW18                [get_ports "CLK_IN1_D_0_clk_n"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L14N_T2L_N3_GC_A05_D21_65
set_property IOSTANDARD  LVDS                [get_ports "CLK_IN1_D_0_clk_n"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L14N_T2L_N3_GC_A05_D21_65
set_property PACKAGE_PIN AW19                [get_ports "CLK_IN1_D_0_clk_p"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L14P_T2L_N2_GC_A04_D20_65
set_property IOSTANDARD  LVDS                [get_ports "CLK_IN1_D_0_clk_p"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L14P_T2L_N2_GC_A04_D20_65
          
#################################################################################
#
#  I2C Interface to ...
#       Jitter Cleaner 1 & 2,
#       Clock Generator,
#       DDR Power Enable I2C I/O Expander
#
#################################################################################

set_property PACKAGE_PIN AR20                [get_ports "i2c_scl"]                ;# Bank  65 VCCO - +1V8_SYS                               - IO_L23P_T3U_N8_I2C_SCLK_65
set_property IOSTANDARD  LVCMOS18            [get_ports "i2c_scl"]                ;# Bank  65 VCCO - +1V8_SYS                               - IO_L23P_T3U_N8_I2C_SCLK_65
set_property PACKAGE_PIN AT20                [get_ports "i2c_sda"]                ;# Bank  65 VCCO - +1V8_SYS                               - IO_L23N_T3U_N9_PERSTN1_I2C_SDA_65
set_property IOSTANDARD  LVCMOS18            [get_ports "i2c_sda"]                ;# Bank  65 VCCO - +1V8_SYS                               - IO_L23N_T3U_N9_PERSTN1_I2C_SDA_65
             

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
#set_property PACKAGE_PIN AP19                [get_ports "PCIE_HOST_DETECT"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L24N_T3U_N11_DOUT_CSO_B_65
#set_property IOSTANDARD  LVCMOS18            [get_ports "PCIE_HOST_DETECT"]              ;# Bank  65 VCCO - +1V8_SYS                               - IO_L24N_T3U_N11_DOUT_CSO_B_65
set_property PACKAGE_PIN AT19                [get_ports "sys_rst_n"]                     ;# Bank  65 VCCO - +1V8_SYS                               - IO_T3U_N12_PERSTN0_65
set_property IOSTANDARD  LVCMOS18            [get_ports "sys_rst_n"]                     ;# Bank  65 VCCO - +1V8_SYS                               - IO_T3U_N12_PERSTN0_65
#set_property PACKAGE_PIN AR18                [get_ports "PEX_PWRBRKN_FPGA_65"]           ;# Bank  65 VCCO - +1V8_SYS                               - IO_L21P_T3L_N4_AD8P_D06_65
#set_property IOSTANDARD  LVCMOS18            [get_ports "PEX_PWRBRKN_FPGA_65"]           ;# Bank  65 VCCO - +1V8_SYS                               - IO_L21P_T3L_N4_AD8P_D06_65

#
#  LVDS Input Reference Clock for PCIe, Bank 225 (1.2V)
#    Typical GT pin constraints are embedded in the IP
#
set_property PACKAGE_PIN AV8                 [get_ports "sys_clk_n"]             ;# Bank 225 - MGTREFCLK0N_225
set_property PACKAGE_PIN AV9                 [get_ports "sys_clk_p"]             ;# Bank 225 - MGTREFCLK0P_225

#
#  On Board 100 Mhz Reference clock for PCIe, Bank 225 (1.2V)
#    Typical GT pin constraints are embedded in the IP
#
#set_property PACKAGE_PIN AR10                [get_ports "CLK0_LVDS_100_N"]               ;# Bank 225 - MGTREFCLK1N_225
#set_property PACKAGE_PIN AR11                [get_ports "CLK0_LVDS_100_P"]               ;# Bank 225 - MGTREFCLK1P_225

#
#  PCIe Data Connections - Bank 224 and Bank 225 (1.2V)
#    Typical GT pin constraints are embedded in the IP
#
set_property PACKAGE_PIN AT3                 [get_ports "pcie_mgt_0_rxn[0]"]                   ;# Bank 225 - MGTYRXN3_225
set_property PACKAGE_PIN AT4                 [get_ports "pcie_mgt_0_rxp[0]"]                   ;# Bank 225 - MGTYRXP3_225
set_property PACKAGE_PIN AU1                 [get_ports "pcie_mgt_0_rxn[1]"]                   ;# Bank 225 - MGTYRXN2_225
set_property PACKAGE_PIN AU2                 [get_ports "pcie_mgt_0_rxp[1]"]                   ;# Bank 225 - MGTYRXP2_225
set_property PACKAGE_PIN AV3                 [get_ports "pcie_mgt_0_rxn[2]"]                   ;# Bank 225 - MGTYRXN1_225
set_property PACKAGE_PIN AV4                 [get_ports "pcie_mgt_0_rxp[2]"]                   ;# Bank 225 - MGTYRXP1_225
set_property PACKAGE_PIN AW1                 [get_ports "pcie_mgt_0_rxn[3]"]                   ;# Bank 225 - MGTYRXN0_225
set_property PACKAGE_PIN AW2                 [get_ports "pcie_mgt_0_rxp[3]"]                   ;# Bank 225 - MGTYRXP0_225
set_property PACKAGE_PIN AY3                 [get_ports "pcie_mgt_0_rxn[4]"]                   ;# Bank 224 - MGTYRXN3_224
set_property PACKAGE_PIN AY4                 [get_ports "pcie_mgt_0_rxp[4]"]                   ;# Bank 224 - MGTYRXP3_224
set_property PACKAGE_PIN BA1                 [get_ports "pcie_mgt_0_rxn[5]"]                   ;# Bank 224 - MGTYRXN2_224
set_property PACKAGE_PIN BA2                 [get_ports "pcie_mgt_0_rxp[5]"]                   ;# Bank 224 - MGTYRXP2_224
set_property PACKAGE_PIN BB3                 [get_ports "pcie_mgt_0_rxn[6]"]                   ;# Bank 224 - MGTYRXN1_224
set_property PACKAGE_PIN BB4                 [get_ports "pcie_mgt_0_rxp[6]"]                   ;# Bank 224 - MGTYRXP1_224
set_property PACKAGE_PIN BC1                 [get_ports "pcie_mgt_0_rxn[7]"]                   ;# Bank 224 - MGTYRXN0_224
set_property PACKAGE_PIN BC2                 [get_ports "pcie_mgt_0_rxp[7]"]                   ;# Bank 224 - MGTYRXP0_224

set_property PACKAGE_PIN AW6                 [get_ports "pcie_mgt_0_txn[0]"]                   ;# Bank 225 - MGTYTXN3_225
set_property PACKAGE_PIN AW7                 [get_ports "pcie_mgt_0_txp[0]"]                   ;# Bank 225 - MGTYTXP3_225
set_property PACKAGE_PIN BA6                 [get_ports "pcie_mgt_0_txn[1]"]                   ;# Bank 225 - MGTYTXN2_225
set_property PACKAGE_PIN BA7                 [get_ports "pcie_mgt_0_txp[1]"]                   ;# Bank 225 - MGTYTXP2_225
set_property PACKAGE_PIN BC6                 [get_ports "pcie_mgt_0_txn[2]"]                   ;# Bank 225 - MGTYTXN1_225
set_property PACKAGE_PIN BC7                 [get_ports "pcie_mgt_0_txp[2]"]                   ;# Bank 225 - MGTYTXP1_225
set_property PACKAGE_PIN BD8                 [get_ports "pcie_mgt_0_txn[3]"]                   ;# Bank 225 - MGTYTXN0_225
set_property PACKAGE_PIN BD9                 [get_ports "pcie_mgt_0_txp[3]"]                   ;# Bank 225 - MGTYTXP0_225
set_property PACKAGE_PIN BD4                 [get_ports "pcie_mgt_0_txn[4]"]                   ;# Bank 224 - MGTYTXN3_224
set_property PACKAGE_PIN BD5                 [get_ports "pcie_mgt_0_txp[4]"]                   ;# Bank 224 - MGTYTXP3_224
set_property PACKAGE_PIN BE6                 [get_ports "pcie_mgt_0_txn[5]"]                   ;# Bank 224 - MGTYTXN2_224
set_property PACKAGE_PIN BE7                 [get_ports "pcie_mgt_0_txp[5]"]                   ;# Bank 224 - MGTYTXP2_224
set_property PACKAGE_PIN BF8                 [get_ports "pcie_mgt_0_txn[6]"]                   ;# Bank 224 - MGTYTXN1_224
set_property PACKAGE_PIN BF9                 [get_ports "pcie_mgt_0_txp[6]"]                   ;# Bank 224 - MGTYTXP1_224
set_property PACKAGE_PIN BF4                 [get_ports "pcie_mgt_0_txn[7]"]                   ;# Bank 224 - MGTYTXN0_224
set_property PACKAGE_PIN BF5                 [get_ports "pcie_mgt_0_txp[7]"]                   ;# Bank 224 - MGTYTXP0_224


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
#  DDR Interface...
#
#################################################################################

#
#  DDR4 RESET_GATE Active High Output from Ultrascale+ Device to hold all External DDR4 interfaces in Self refresh.
#                  This Output disconnects the Memory interface reset and holds it in active and pulls the Clock Enables signal on the Memory Interfaces.
#                  Refer to XAPP1321 for details on Self refresh mode.
#
#set_property PACKAGE_PIN AU20                [get_ports "RESET_GATE_R"]                  ;# Bank  65 VCCO - +1V8_SYS                               - IO_L22P_T3U_N6_DBC_AD0P_D04_65
#set_property IOSTANDARD  LVCMOS18            [get_ports "RESET_GATE_R"]                  ;# Bank  65 VCCO - +1V8_SYS                               - IO_L22P_T3U_N6_DBC_AD0P_D04_65


#
#  DDR4 RDIMM Controller 0, 72-bit Data Interface, x4 Components, Single Rank
#     Banks 66, 67, 68 (1.2V)
#     Part Number MT40A2G8SA-062E (x8 comp, x72@2666)
#
set_property PACKAGE_PIN BB25                [get_ports "C0_DDR4_0_ck_c[0]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_CK0_C           - IO_L7N_T1L_N1_QBC_AD13N_66
set_property IOSTANDARD  DIFF_SSTL12_DCI     [get_ports "C0_DDR4_0_ck_c[0]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_CK0_C           - IO_L7N_T1L_N1_QBC_AD13N_66
set_property PACKAGE_PIN BA25                [get_ports "C0_DDR4_0_ck_t[0]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_CK0_T           - IO_L7P_T1L_N0_QBC_AD13P_66
set_property IOSTANDARD  DIFF_SSTL12_DCI     [get_ports "C0_DDR4_0_ck_t[0]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_CK0_T           - IO_L7P_T1L_N0_QBC_AD13P_66
set_property PACKAGE_PIN BC24                [get_ports "C0_DDR4_0_cke[0]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_CKE0            - IO_L8N_T1L_N3_AD5N_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_cke[0]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_CKE0            - IO_L8N_T1L_N3_AD5N_66
set_property PACKAGE_PIN BF25                [get_ports "C0_DDR4_0_cs_n[0]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_CS0_B           - IO_L1P_T0L_N0_DBC_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_cs_n[0]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_CS0_B           - IO_L1P_T0L_N0_DBC_66
set_property PACKAGE_PIN BD25                [get_ports "C0_DDR4_0_odt[0]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_ODT0            - IO_L5P_T0U_N8_AD14P_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_odt[0]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_ODT0            - IO_L5P_T0U_N8_AD14P_66
#set_property PACKAGE_PIN BC23                [get_ports "c0_ddr4_parity"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_PARITY          - IO_L6P_T0U_N10_AD6P_66
#set_property IOSTANDARD  SSTL12_DCI          [get_ports "c0_ddr4_parity"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_PARITY          - IO_L6P_T0U_N10_AD6P_66
set_property PACKAGE_PIN AT23                [get_ports "C0_DDR4_0_reset_n"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_RESET_B         - IO_T3U_N12_66
set_property IOSTANDARD  LVCMOS12            [get_ports "C0_DDR4_0_reset_n"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_RESET_B         - IO_T3U_N12_66
set_property DRIVE       8                   [get_ports "C0_DDR4_0_reset_n"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_RESET_B         - IO_T3U_N12_66
set_property PACKAGE_PIN BE21                [get_ports "C0_DDR4_0_act_n"]                 ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_ACT_B           - IO_L3N_T0L_N5_AD15N_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_act_n"]                 ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_ACT_B           - IO_L3N_T0L_N5_AD15N_66
#set_property PACKAGE_PIN AU25                [get_ports "c0_ddr4_alert_n"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_ALERT_B         - IO_L16P_T2U_N6_QBC_AD3P_66
#set_property IOSTANDARD  LVCMOS12            [get_ports "c0_ddr4_alert_n"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_ALERT_B         - IO_L16P_T2U_N6_QBC_AD3P_66
#set_property DRIVE       8                   [get_ports "c0_ddr4_alert_n"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_ALERT_B         - IO_L16P_T2U_N6_QBC_AD3P_66
set_property PACKAGE_PIN AW21                [get_ports "C0_DDR4_0_ba[0]"]                 ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_BA0             - IO_L10P_T1U_N6_QBC_AD4P_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_ba[0]"]                 ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_BA0             - IO_L10P_T1U_N6_QBC_AD4P_66
set_property PACKAGE_PIN BB21                [get_ports "C0_DDR4_0_ba[1]"]                 ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_BA1             - IO_L9P_T1L_N4_AD12P_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_ba[1]"]                 ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_BA1             - IO_L9P_T1L_N4_AD12P_66
set_property PACKAGE_PIN AY21                [get_ports "C0_DDR4_0_bg[0]"]                 ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_BG0             - IO_L10N_T1U_N7_QBC_AD4N_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_bg[0]"]                 ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_BG0             - IO_L10N_T1U_N7_QBC_AD4N_66
set_property PACKAGE_PIN AY25                [get_ports "C0_DDR4_0_bg[1]"]                 ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_BG1             - IO_L15N_T2L_N5_AD11N_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_bg[1]"]                 ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_BG1             - IO_L15N_T2L_N5_AD11N_66
set_property PACKAGE_PIN BD23                [get_ports "C0_DDR4_0_adr[0]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A0              - IO_L6N_T0U_N11_AD6N_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_adr[0]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A0              - IO_L6N_T0U_N11_AD6N_66
set_property PACKAGE_PIN AV23                [get_ports "C0_DDR4_0_adr[1]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A1              - IO_L17P_T2U_N8_AD10P_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_adr[1]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A1              - IO_L17P_T2U_N8_AD10P_66
set_property PACKAGE_PIN BE22                [get_ports "C0_DDR4_0_adr[2]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A2              - IO_L4N_T0U_N7_DBC_AD7N_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_adr[2]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A2              - IO_L4N_T0U_N7_DBC_AD7N_66
set_property PACKAGE_PIN BF22                [get_ports "C0_DDR4_0_adr[3]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A3              - IO_L2N_T0L_N3_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_adr[3]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A3              - IO_L2N_T0L_N3_66
set_property PACKAGE_PIN BF23                [get_ports "C0_DDR4_0_adr[4]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A4              - IO_L2P_T0L_N2_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_adr[4]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A4              - IO_L2P_T0L_N2_66
set_property PACKAGE_PIN BE23                [get_ports "C0_DDR4_0_adr[5]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A5              - IO_L4P_T0U_N6_DBC_AD7P_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_adr[5]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A5              - IO_L4P_T0U_N6_DBC_AD7P_66
set_property PACKAGE_PIN BA22                [get_ports "C0_DDR4_0_adr[6]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A6              - IO_T1U_N12_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_adr[6]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A6              - IO_T1U_N12_66
set_property PACKAGE_PIN BA23                [get_ports "C0_DDR4_0_adr[7]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A7              - IO_L12N_T1U_N11_GC_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_adr[7]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A7              - IO_L12N_T1U_N11_GC_66
set_property PACKAGE_PIN BB22                [get_ports "C0_DDR4_0_adr[8]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A8              - IO_L11P_T1U_N8_GC_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_adr[8]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A8              - IO_L11P_T1U_N8_GC_66
set_property PACKAGE_PIN AU24                [get_ports "C0_DDR4_0_adr[9]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A9              - IO_L16N_T2U_N7_QBC_AD3N_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_adr[9]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A9              - IO_L16N_T2U_N7_QBC_AD3N_66
set_property PACKAGE_PIN BE25                [get_ports "C0_DDR4_0_adr[10]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A10             - IO_L5N_T0U_N9_AD14N_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_adr[10]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A10             - IO_L5N_T0U_N9_AD14N_66
set_property PACKAGE_PIN BA24                [get_ports "C0_DDR4_0_adr[11]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A11             - IO_L12P_T1U_N10_GC_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_adr[11]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A11             - IO_L12P_T1U_N10_GC_66
set_property PACKAGE_PIN BF24                [get_ports "C0_DDR4_0_adr[12]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A12             - IO_L1N_T0L_N1_DBC_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_adr[12]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A12             - IO_L1N_T0L_N1_DBC_66
set_property PACKAGE_PIN BD21                [get_ports "C0_DDR4_0_adr[13]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A13             - IO_L3P_T0L_N4_AD15P_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_adr[13]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A13             - IO_L3P_T0L_N4_AD15P_66
set_property PACKAGE_PIN BC22                [get_ports "C0_DDR4_0_adr[14]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_WE_B            - IO_L11N_T1U_N9_GC_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_adr[14]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_WE_B            - IO_L11N_T1U_N9_GC_66
set_property PACKAGE_PIN BB24                [get_ports "C0_DDR4_0_adr[15]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_CAS_B           - IO_L8P_T1L_N2_AD5P_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_adr[15]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_CAS_B           - IO_L8P_T1L_N2_AD5P_66
set_property PACKAGE_PIN BC21                [get_ports "C0_DDR4_0_adr[16]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_RAS_B           - IO_L9N_T1L_N5_AD12N_66
set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_adr[16]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_RAS_B           - IO_L9N_T1L_N5_AD12N_66
#set_property PACKAGE_PIN AV22                [get_ports "C0_DDR4_0_adr[17]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A17             - IO_L17N_T2U_N9_AD10N_66
#set_property IOSTANDARD  SSTL12_DCI          [get_ports "C0_DDR4_0_adr[17]"]               ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_A17             - IO_L17N_T2U_N9_AD10N_66
set_property PACKAGE_PIN AU26                [get_ports "C0_DDR4_0_dm_n[0]"]           ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B0           - IO_L19P_T3L_N0_DBC_AD9P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dm_n[0]"]           ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B0           - IO_L19P_T3L_N0_DBC_AD9P_67
set_property PACKAGE_PIN AW33                [get_ports "C0_DDR4_0_dm_n[1]"]           ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B1           - IO_L19P_T3L_N0_DBC_AD9P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dm_n[1]"]           ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B1           - IO_L19P_T3L_N0_DBC_AD9P_68
set_property PACKAGE_PIN BE35                [get_ports "C0_DDR4_0_dm_n[2]"]           ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B2           - IO_L1P_T0L_N0_DBC_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dm_n[2]"]           ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B2           - IO_L1P_T0L_N0_DBC_68
set_property PACKAGE_PIN AY28                [get_ports "C0_DDR4_0_dm_n[3]"]           ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B3           - IO_L13P_T2L_N0_GC_QBC_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dm_n[3]"]           ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B3           - IO_L13P_T2L_N0_GC_QBC_67
set_property PACKAGE_PIN BA35                [get_ports "C0_DDR4_0_dm_n[4]"]           ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B4           - IO_L13P_T2L_N0_GC_QBC_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dm_n[4]"]           ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B4           - IO_L13P_T2L_N0_GC_QBC_68
set_property PACKAGE_PIN BC29                [get_ports "C0_DDR4_0_dm_n[5]"]           ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B5           - IO_L7P_T1L_N0_QBC_AD13P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dm_n[5]"]           ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B5           - IO_L7P_T1L_N0_QBC_AD13P_67
set_property PACKAGE_PIN AT22                [get_ports "C0_DDR4_0_dm_n[6]"]           ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B6           - IO_L19P_T3L_N0_DBC_AD9P_66
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dm_n[6]"]           ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B6           - IO_L19P_T3L_N0_DBC_AD9P_66
set_property PACKAGE_PIN BE30                [get_ports "C0_DDR4_0_dm_n[7]"]           ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B7           - IO_L1P_T0L_N0_DBC_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dm_n[7]"]           ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B7           - IO_L1P_T0L_N0_DBC_67
set_property PACKAGE_PIN BE37                [get_ports "C0_DDR4_0_dm_n[8]"]           ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B8           - IO_L7P_T1L_N0_QBC_AD13P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dm_n[8]"]           ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DM_B8           - IO_L7P_T1L_N0_QBC_AD13P_68
set_property PACKAGE_PIN AU27                [get_ports "C0_DDR4_0_dq[0]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ0             - IO_L20P_T3L_N2_AD1P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[0]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ0             - IO_L20P_T3L_N2_AD1P_67
set_property PACKAGE_PIN AT30                [get_ports "C0_DDR4_0_dq[1]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ1             - IO_L21P_T3L_N4_AD8P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[1]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ1             - IO_L21P_T3L_N4_AD8P_67
set_property PACKAGE_PIN AV27                [get_ports "C0_DDR4_0_dq[2]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ2             - IO_L20N_T3L_N3_AD1N_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[2]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ2             - IO_L20N_T3L_N3_AD1N_67
set_property PACKAGE_PIN AR28                [get_ports "C0_DDR4_0_dq[3]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ3             - IO_L23P_T3U_N8_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[3]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ3             - IO_L23P_T3U_N8_67
set_property PACKAGE_PIN AT27                [get_ports "C0_DDR4_0_dq[4]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ4             - IO_L24N_T3U_N11_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[4]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ4             - IO_L24N_T3U_N11_67
set_property PACKAGE_PIN AU31                [get_ports "C0_DDR4_0_dq[5]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ5             - IO_L21N_T3L_N5_AD8N_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[5]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ5             - IO_L21N_T3L_N5_AD8N_67
set_property PACKAGE_PIN AR27                [get_ports "C0_DDR4_0_dq[6]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ6             - IO_L24P_T3U_N10_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[6]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ6             - IO_L24P_T3U_N10_67
set_property PACKAGE_PIN AT28                [get_ports "C0_DDR4_0_dq[7]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ7             - IO_L23N_T3U_N9_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[7]"]                 ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ7             - IO_L23N_T3U_N9_67
set_property PACKAGE_PIN AV33                [get_ports "C0_DDR4_0_dq[8]"]                 ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ8             - IO_L20P_T3L_N2_AD1P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[8]"]                 ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ8             - IO_L20P_T3L_N2_AD1P_68
set_property PACKAGE_PIN AR31                [get_ports "C0_DDR4_0_dq[9]"]                 ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ9             - IO_L24P_T3U_N10_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[9]"]                 ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ9             - IO_L24P_T3U_N10_68
set_property PACKAGE_PIN AW34                [get_ports "C0_DDR4_0_dq[10]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ10            - IO_L20N_T3L_N3_AD1N_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[10]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ10            - IO_L20N_T3L_N3_AD1N_68
set_property PACKAGE_PIN AT32                [get_ports "C0_DDR4_0_dq[11]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ11            - IO_L24N_T3U_N11_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[11]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ11            - IO_L24N_T3U_N11_68
set_property PACKAGE_PIN AU32                [get_ports "C0_DDR4_0_dq[12]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ12            - IO_L21P_T3L_N4_AD8P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[12]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ12            - IO_L21P_T3L_N4_AD8P_68
set_property PACKAGE_PIN AR33                [get_ports "C0_DDR4_0_dq[13]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ13            - IO_L23N_T3U_N9_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[13]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ13            - IO_L23N_T3U_N9_68
set_property PACKAGE_PIN AV32                [get_ports "C0_DDR4_0_dq[14]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ14            - IO_L21N_T3L_N5_AD8N_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[14]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ14            - IO_L21N_T3L_N5_AD8N_68
set_property PACKAGE_PIN AR32                [get_ports "C0_DDR4_0_dq[15]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ15            - IO_L23P_T3U_N8_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[15]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ15            - IO_L23P_T3U_N8_68
set_property PACKAGE_PIN BE32                [get_ports "C0_DDR4_0_dq[16]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ16            - IO_L3P_T0L_N4_AD15P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[16]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ16            - IO_L3P_T0L_N4_AD15P_68
set_property PACKAGE_PIN BF34                [get_ports "C0_DDR4_0_dq[17]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ17            - IO_L2N_T0L_N3_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[17]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ17            - IO_L2N_T0L_N3_68
set_property PACKAGE_PIN BF32                [get_ports "C0_DDR4_0_dq[18]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ18            - IO_L3N_T0L_N5_AD15N_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[18]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ18            - IO_L3N_T0L_N5_AD15N_68
set_property PACKAGE_PIN BF33                [get_ports "C0_DDR4_0_dq[19]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ19            - IO_L2P_T0L_N2_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[19]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ19            - IO_L2P_T0L_N2_68
set_property PACKAGE_PIN BC32                [get_ports "C0_DDR4_0_dq[20]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ20            - IO_L5P_T0U_N8_AD14P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[20]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ20            - IO_L5P_T0U_N8_AD14P_68
set_property PACKAGE_PIN BD34                [get_ports "C0_DDR4_0_dq[21]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ21            - IO_L6N_T0U_N11_AD6N_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[21]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ21            - IO_L6N_T0U_N11_AD6N_68
set_property PACKAGE_PIN BC33                [get_ports "C0_DDR4_0_dq[22]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ22            - IO_L6P_T0U_N10_AD6P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[22]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ22            - IO_L6P_T0U_N10_AD6P_68
set_property PACKAGE_PIN BD33                [get_ports "C0_DDR4_0_dq[23]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ23            - IO_L5N_T0U_N9_AD14N_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[23]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ23            - IO_L5N_T0U_N9_AD14N_68
set_property PACKAGE_PIN AW31                [get_ports "C0_DDR4_0_dq[24]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ24            - IO_L15N_T2L_N5_AD11N_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[24]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ24            - IO_L15N_T2L_N5_AD11N_67
set_property PACKAGE_PIN AV28                [get_ports "C0_DDR4_0_dq[25]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ25            - IO_L17P_T2U_N8_AD10P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[25]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ25            - IO_L17P_T2U_N8_AD10P_67
set_property PACKAGE_PIN AV31                [get_ports "C0_DDR4_0_dq[26]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ26            - IO_L15P_T2L_N4_AD11P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[26]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ26            - IO_L15P_T2L_N4_AD11P_67
set_property PACKAGE_PIN AY26                [get_ports "C0_DDR4_0_dq[27]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ27            - IO_L18N_T2U_N11_AD2N_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[27]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ27            - IO_L18N_T2U_N11_AD2N_67
set_property PACKAGE_PIN AW30                [get_ports "C0_DDR4_0_dq[28]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ28            - IO_L14P_T2L_N2_GC_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[28]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ28            - IO_L14P_T2L_N2_GC_67
set_property PACKAGE_PIN AW26                [get_ports "C0_DDR4_0_dq[29]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ29            - IO_L18P_T2U_N10_AD2P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[29]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ29            - IO_L18P_T2U_N10_AD2P_67
set_property PACKAGE_PIN AY31                [get_ports "C0_DDR4_0_dq[30]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ30            - IO_L14N_T2L_N3_GC_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[30]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ30            - IO_L14N_T2L_N3_GC_67
set_property PACKAGE_PIN AW28                [get_ports "C0_DDR4_0_dq[31]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ31            - IO_L17N_T2U_N9_AD10N_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[31]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ31            - IO_L17N_T2U_N9_AD10N_67
set_property PACKAGE_PIN BB32                [get_ports "C0_DDR4_0_dq[32]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ32            - IO_L15N_T2L_N5_AD11N_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[32]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ32            - IO_L15N_T2L_N5_AD11N_68
set_property PACKAGE_PIN AY35                [get_ports "C0_DDR4_0_dq[33]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ33            - IO_L17N_T2U_N9_AD10N_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[33]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ33            - IO_L17N_T2U_N9_AD10N_68
set_property PACKAGE_PIN BA32                [get_ports "C0_DDR4_0_dq[34]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ34            - IO_L15P_T2L_N4_AD11P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[34]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ34            - IO_L15P_T2L_N4_AD11P_68
set_property PACKAGE_PIN AW35                [get_ports "C0_DDR4_0_dq[35]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ35            - IO_L17P_T2U_N8_AD10P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[35]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ35            - IO_L17P_T2U_N8_AD10P_68
set_property PACKAGE_PIN BB35                [get_ports "C0_DDR4_0_dq[36]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ36            - IO_L14N_T2L_N3_GC_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[36]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ36            - IO_L14N_T2L_N3_GC_68
set_property PACKAGE_PIN AY36                [get_ports "C0_DDR4_0_dq[37]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ37            - IO_L18N_T2U_N11_AD2N_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[37]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ37            - IO_L18N_T2U_N11_AD2N_68
set_property PACKAGE_PIN BB34                [get_ports "C0_DDR4_0_dq[38]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ38            - IO_L14P_T2L_N2_GC_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[38]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ38            - IO_L14P_T2L_N2_GC_68
set_property PACKAGE_PIN AW36                [get_ports "C0_DDR4_0_dq[39]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ39            - IO_L18P_T2U_N10_AD2P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[39]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ39            - IO_L18P_T2U_N10_AD2P_68
set_property PACKAGE_PIN BA28                [get_ports "C0_DDR4_0_dq[40]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ40            - IO_L12N_T1U_N11_GC_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[40]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ40            - IO_L12N_T1U_N11_GC_67
set_property PACKAGE_PIN BC31                [get_ports "C0_DDR4_0_dq[41]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ41            - IO_L8N_T1L_N3_AD5N_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[41]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ41            - IO_L8N_T1L_N3_AD5N_67
set_property PACKAGE_PIN BB27                [get_ports "C0_DDR4_0_dq[42]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ42            - IO_L11P_T1U_N8_GC_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[42]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ42            - IO_L11P_T1U_N8_GC_67
set_property PACKAGE_PIN BA30                [get_ports "C0_DDR4_0_dq[43]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ43            - IO_L9N_T1L_N5_AD12N_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[43]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ43            - IO_L9N_T1L_N5_AD12N_67
set_property PACKAGE_PIN BC27                [get_ports "C0_DDR4_0_dq[44]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ44            - IO_L11N_T1U_N9_GC_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[44]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ44            - IO_L11N_T1U_N9_GC_67
set_property PACKAGE_PIN BB31                [get_ports "C0_DDR4_0_dq[45]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ45            - IO_L8P_T1L_N2_AD5P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[45]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ45            - IO_L8P_T1L_N2_AD5P_67
set_property PACKAGE_PIN BA27                [get_ports "C0_DDR4_0_dq[46]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ46            - IO_L12P_T1U_N10_GC_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[46]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ46            - IO_L12P_T1U_N10_GC_67
set_property PACKAGE_PIN AY30                [get_ports "C0_DDR4_0_dq[47]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ47            - IO_L9P_T1L_N4_AD12P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[47]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ47            - IO_L9P_T1L_N4_AD12P_67
set_property PACKAGE_PIN AR26                [get_ports "C0_DDR4_0_dq[48]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ48            - IO_L21P_T3L_N4_AD8P_66
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[48]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ48            - IO_L21P_T3L_N4_AD8P_66
set_property PACKAGE_PIN AP23                [get_ports "C0_DDR4_0_dq[49]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ49            - IO_L23P_T3U_N8_66
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[49]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ49            - IO_L23P_T3U_N8_66
set_property PACKAGE_PIN AR25                [get_ports "C0_DDR4_0_dq[50]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ50            - IO_L20P_T3L_N2_AD1P_66
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[50]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ50            - IO_L20P_T3L_N2_AD1P_66
set_property PACKAGE_PIN AR23                [get_ports "C0_DDR4_0_dq[51]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ51            - IO_L23N_T3U_N9_66
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[51]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ51            - IO_L23N_T3U_N9_66
set_property PACKAGE_PIN AT25                [get_ports "C0_DDR4_0_dq[52]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ52            - IO_L21N_T3L_N5_AD8N_66
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[52]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ52            - IO_L21N_T3L_N5_AD8N_66
set_property PACKAGE_PIN AR22                [get_ports "C0_DDR4_0_dq[53]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ53            - IO_L24P_T3U_N10_66
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[53]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ53            - IO_L24P_T3U_N10_66
set_property PACKAGE_PIN AT24                [get_ports "C0_DDR4_0_dq[54]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ54            - IO_L20N_T3L_N3_AD1N_66
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[54]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ54            - IO_L20N_T3L_N3_AD1N_66
set_property PACKAGE_PIN AR21                [get_ports "C0_DDR4_0_dq[55]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ55            - IO_L24N_T3U_N11_66
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[55]"]                ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ55            - IO_L24N_T3U_N11_66
set_property PACKAGE_PIN BD26                [get_ports "C0_DDR4_0_dq[56]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ56            - IO_L5P_T0U_N8_AD14P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[56]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ56            - IO_L5P_T0U_N8_AD14P_67
set_property PACKAGE_PIN BF28                [get_ports "C0_DDR4_0_dq[57]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ57            - IO_L2P_T0L_N2_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[57]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ57            - IO_L2P_T0L_N2_67
set_property PACKAGE_PIN BE26                [get_ports "C0_DDR4_0_dq[58]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ58            - IO_L5N_T0U_N9_AD14N_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[58]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ58            - IO_L5N_T0U_N9_AD14N_67
set_property PACKAGE_PIN BE28                [get_ports "C0_DDR4_0_dq[59]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ59            - IO_L3N_T0L_N5_AD15N_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[59]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ59            - IO_L3N_T0L_N5_AD15N_67
set_property PACKAGE_PIN BC26                [get_ports "C0_DDR4_0_dq[60]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ60            - IO_L6N_T0U_N11_AD6N_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[60]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ60            - IO_L6N_T0U_N11_AD6N_67
set_property PACKAGE_PIN BF29                [get_ports "C0_DDR4_0_dq[61]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ61            - IO_L2N_T0L_N3_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[61]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ61            - IO_L2N_T0L_N3_67
set_property PACKAGE_PIN BB26                [get_ports "C0_DDR4_0_dq[62]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ62            - IO_L6P_T0U_N10_AD6P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[62]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ62            - IO_L6P_T0U_N10_AD6P_67
set_property PACKAGE_PIN BD28                [get_ports "C0_DDR4_0_dq[63]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ63            - IO_L3P_T0L_N4_AD15P_67
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[63]"]                ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ63            - IO_L3P_T0L_N4_AD15P_67
set_property PACKAGE_PIN BD38                [get_ports "C0_DDR4_0_dq[64]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ64            - IO_L9N_T1L_N5_AD12N_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[64]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ64            - IO_L9N_T1L_N5_AD12N_68
set_property PACKAGE_PIN BC36                [get_ports "C0_DDR4_0_dq[65]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ65            - IO_L12P_T1U_N10_GC_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[65]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ65            - IO_L12P_T1U_N10_GC_68
set_property PACKAGE_PIN BC38                [get_ports "C0_DDR4_0_dq[66]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ66            - IO_L9P_T1L_N4_AD12P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[66]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ66            - IO_L9P_T1L_N4_AD12P_68
set_property PACKAGE_PIN BD36                [get_ports "C0_DDR4_0_dq[67]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ67            - IO_L12N_T1U_N11_GC_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[67]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ67            - IO_L12N_T1U_N11_GC_68
set_property PACKAGE_PIN BE38                [get_ports "C0_DDR4_0_dq[68]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ68            - IO_L8P_T1L_N2_AD5P_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[68]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ68            - IO_L8P_T1L_N2_AD5P_68
set_property PACKAGE_PIN BC34                [get_ports "C0_DDR4_0_dq[69]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ69            - IO_L11P_T1U_N8_GC_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[69]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ69            - IO_L11P_T1U_N8_GC_68
set_property PACKAGE_PIN BD35                [get_ports "C0_DDR4_0_dq[70]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ70            - IO_L11N_T1U_N9_GC_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[70]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ70            - IO_L11N_T1U_N9_GC_68
set_property PACKAGE_PIN BF38                [get_ports "C0_DDR4_0_dq[71]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ71            - IO_L8N_T1L_N3_AD5N_68
set_property IOSTANDARD  POD12_DCI           [get_ports "C0_DDR4_0_dq[71]"]                ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQ71            - IO_L8N_T1L_N3_AD5N_68
set_property PACKAGE_PIN AU30                [get_ports "C0_DDR4_0_dqs_c[0]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C0          - IO_L22N_T3U_N7_DBC_AD0N_67
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "C0_DDR4_0_dqs_c[0]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C0          - IO_L22N_T3U_N7_DBC_AD0N_67
set_property PACKAGE_PIN AV34                [get_ports "C0_DDR4_0_dqs_c[1]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C1          - IO_L22N_T3U_N7_DBC_AD0N_68
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "C0_DDR4_0_dqs_c[1]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C1          - IO_L22N_T3U_N7_DBC_AD0N_68
set_property PACKAGE_PIN BE31                [get_ports "C0_DDR4_0_dqs_c[2]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C2          - IO_L4N_T0U_N7_DBC_AD7N_68
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "C0_DDR4_0_dqs_c[2]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C2          - IO_L4N_T0U_N7_DBC_AD7N_68
set_property PACKAGE_PIN AW29                [get_ports "C0_DDR4_0_dqs_c[3]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C3          - IO_L16N_T2U_N7_QBC_AD3N_67
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "C0_DDR4_0_dqs_c[3]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C3          - IO_L16N_T2U_N7_QBC_AD3N_67
set_property PACKAGE_PIN BA33                [get_ports "C0_DDR4_0_dqs_c[4]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C4          - IO_L16N_T2U_N7_QBC_AD3N_68
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "C0_DDR4_0_dqs_c[4]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C4          - IO_L16N_T2U_N7_QBC_AD3N_68
set_property PACKAGE_PIN BB30                [get_ports "C0_DDR4_0_dqs_c[5]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C5          - IO_L10N_T1U_N7_QBC_AD4N_67
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "C0_DDR4_0_dqs_c[5]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C5          - IO_L10N_T1U_N7_QBC_AD4N_67
set_property PACKAGE_PIN AP24                [get_ports "C0_DDR4_0_dqs_c[6]"]              ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C6          - IO_L22N_T3U_N7_DBC_AD0N_66
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "C0_DDR4_0_dqs_c[6]"]              ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C6          - IO_L22N_T3U_N7_DBC_AD0N_66
set_property PACKAGE_PIN BF27                [get_ports "C0_DDR4_0_dqs_c[7]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C7          - IO_L4N_T0U_N7_DBC_AD7N_67
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "C0_DDR4_0_dqs_c[7]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C7          - IO_L4N_T0U_N7_DBC_AD7N_67
set_property PACKAGE_PIN BC37                [get_ports "C0_DDR4_0_dqs_c[8]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C8          - IO_L10N_T1U_N7_QBC_AD4N_68
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "C0_DDR4_0_dqs_c[8]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_C8          - IO_L10N_T1U_N7_QBC_AD4N_68
set_property PACKAGE_PIN AT29                [get_ports "C0_DDR4_0_dqs_t[0]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T0          - IO_L22P_T3U_N6_DBC_AD0P_67
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "C0_DDR4_0_dqs_t[0]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T0          - IO_L22P_T3U_N6_DBC_AD0P_67
set_property PACKAGE_PIN AU34                [get_ports "C0_DDR4_0_dqs_t[1]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T1          - IO_L22P_T3U_N6_DBC_AD0P_68
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "C0_DDR4_0_dqs_t[1]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T1          - IO_L22P_T3U_N6_DBC_AD0P_68
set_property PACKAGE_PIN BD31                [get_ports "C0_DDR4_0_dqs_t[2]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T2          - IO_L4P_T0U_N6_DBC_AD7P_68
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "C0_DDR4_0_dqs_t[2]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T2          - IO_L4P_T0U_N6_DBC_AD7P_68
set_property PACKAGE_PIN AV29                [get_ports "C0_DDR4_0_dqs_t[3]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T3          - IO_L16P_T2U_N6_QBC_AD3P_67
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "C0_DDR4_0_dqs_t[3]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T3          - IO_L16P_T2U_N6_QBC_AD3P_67
set_property PACKAGE_PIN AY32                [get_ports "C0_DDR4_0_dqs_t[4]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T4          - IO_L16P_T2U_N6_QBC_AD3P_68
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "C0_DDR4_0_dqs_t[4]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T4          - IO_L16P_T2U_N6_QBC_AD3P_68
set_property PACKAGE_PIN BB29                [get_ports "C0_DDR4_0_dqs_t[5]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T5          - IO_L10P_T1U_N6_QBC_AD4P_67
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "C0_DDR4_0_dqs_t[5]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T5          - IO_L10P_T1U_N6_QBC_AD4P_67
set_property PACKAGE_PIN AP25                [get_ports "C0_DDR4_0_dqs_t[6]"]              ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T6          - IO_L22P_T3U_N6_DBC_AD0P_66
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "C0_DDR4_0_dqs_t[6]"]              ;# Bank  66 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T6          - IO_L22P_T3U_N6_DBC_AD0P_66
set_property PACKAGE_PIN BE27                [get_ports "C0_DDR4_0_dqs_t[7]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T7          - IO_L4P_T0U_N6_DBC_AD7P_67
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "C0_DDR4_0_dqs_t[7]"]              ;# Bank  67 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T7          - IO_L4P_T0U_N6_DBC_AD7P_67
set_property PACKAGE_PIN BB37                [get_ports "C0_DDR4_0_dqs_t[8]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T8          - IO_L10P_T1U_N6_QBC_AD4P_68
set_property IOSTANDARD  DIFF_POD12_DCI      [get_ports "C0_DDR4_0_dqs_t[8]"]              ;# Bank  68 VCCO  - 1V2_VCCO -Net DDR4_C0_DQS_T8          - IO_L10P_T1U_N6_QBC_AD4P_68


