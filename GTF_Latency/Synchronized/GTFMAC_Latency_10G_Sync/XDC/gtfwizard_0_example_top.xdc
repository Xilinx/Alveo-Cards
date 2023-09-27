#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

#################################################################################
#
# Clocks
#
#################################################################################

# Freerun Ref Clock - 161.1343861 Mhz 

create_clock -period 6.206   [get_ports refclk_p]
set_property PACKAGE_PIN U11 [get_ports refclk_p]
set_property PACKAGE_PIN U10 [get_ports refclk_n]


# common clock
create_generated_clock -name gtf_ch_rxoutclk -source [get_pins i_gtfmac/u_gtf_wiz_ip_top/gtf_ch_gtrefclk0] -multiply_by 4 [get_pins i_gtfmac/u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK]
create_generated_clock -name gtf_ch_txoutclk -source [get_pins i_gtfmac/u_gtf_wiz_ip_top/gtf_ch_gtrefclk0] -multiply_by 4 [get_pins i_gtfmac/u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK]


# cfgmclk 
create_clock -period 20.000 -name i_gtfmac/STARTUPE3_inst/CFGMCLK -waveform {0.000 10.000} [get_pins i_gtfmac/STARTUPE3_inst/CFGMCLK]


#################################################################################
#

# set_property PACKAGE_PIN AW18 [get_ports "hb_gtwiz_reset_clk_freerun_n_in"] 
# set_property PACKAGE_PIN AW19 [get_ports "hb_gtwiz_reset_clk_freerun_p_in"] 
# set_property IOSTANDARD  LVDS [get_ports "hb_gtwiz_reset_clk_freerun_n_in"] 
# set_property IOSTANDARD  LVDS [get_ports "hb_gtwiz_reset_clk_freerun_p_in"] 

#################################################################################
#
# GTF QSFP-DD 1 (Bank 230)
#
#################################################################################
#

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
set_property LOC GTF_COMMON_X1Y6	[get_cells -hierarchical -filter {NAME =~ i_gtfmac/u_gtf_wiz_ip_top/inst/gtf_common_inst/gtf_common_inst}]
set_property LOC GTF_CHANNEL_X1Y24	[get_cells -hierarchical -filter {NAME =~ i_gtfmac/u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst}]




#################################################################################
#
# False Path Contraints
#
#################################################################################




# gtf_ch_rxoutclk false paths
set_false_path -from [get_clocks gtf_ch_rxoutclk] -to [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks gtf_ch_rxoutclk] -to [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT1]]
#set_false_path -from [get_clocks i_gtfmac/u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK] -to [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT2]]
set_false_path -from [get_clocks gtf_ch_rxoutclk] -to [get_clocks gtf_ch_txoutclk]

# gtf_ch_txoutclk fals paths
set_false_path -from [get_clocks gtf_ch_txoutclk] -to [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks gtf_ch_txoutclk] -to [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT1]]
#set_false_path -from [get_clocks i_gtfmac/u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK] -to [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT2]]
set_false_path -from [get_clocks gtf_ch_txoutclk] -to [get_clocks gtf_ch_rxoutclk]

# CLKOUT0 false paths
set_false_path -from [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT0]] -to [get_clocks gtf_ch_rxoutclk]
set_false_path -from [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT0]] -to [get_clocks gtf_ch_txoutclk]
set_false_path -from [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT1]]
#set_false_path -from [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT2]]

# CLKOUT1 false paths
set_false_path -from [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT1]] -to [get_clocks gtf_ch_rxoutclk]
set_false_path -from [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT1]] -to [get_clocks gtf_ch_txoutclk]
set_false_path -from [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT0]]


# 				WARNING: following items with "# #" were commented out due to no valid object found.  Need to try and resolve

# # set_false_path -from [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins i_gtfmac/u_gtf_wiz_ip_top/inst/phase_shift_mmcm_inst/inst/mmcme4_adv_inst/CLKOUT1]]
set_false_path -from [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins i_gtfmac/u_gtf_wiz_ip_top/inst/phase_shift_mmcm_inst/inst/mmcme4_adv_inst/CLKOUT0]]
# # set_false_path -from [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins i_gtfmac/u_gtf_wiz_ip_top/inst/phase_shift_mmcm_inst/inst/mmcme4_adv_inst/CLKOUT1]]
set_false_path -from [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins i_gtfmac/u_gtf_wiz_ip_top/inst/phase_shift_mmcm_inst/inst/mmcme4_adv_inst/CLKOUT0]]
# # set_false_path -from [get_clocks -of_objects [get_pins i_gtfmac/u_gtf_wiz_ip_top/inst/phase_shift_mmcm_inst/inst/mmcme4_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT0]]
# # set_false_path -from [get_clocks -of_objects [get_pins i_gtfmac/u_gtf_wiz_ip_top/inst/phase_shift_mmcm_inst/inst/mmcme4_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT1]]
set_false_path -from [get_clocks -of_objects [get_pins i_gtfmac/u_gtf_wiz_ip_top/inst/phase_shift_mmcm_inst/inst/mmcme4_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins i_gtfmac/u_gtf_wiz_ip_top/inst/phase_shift_mmcm_inst/inst/mmcme4_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT1]]
set_false_path -from [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins i_gtfmac/u_gtf_wiz_ip_top/inst/phase_shift_mmcm_inst/inst/mmcme4_adv_inst/CLKOUT0B]]
set_false_path -from [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins i_gtfmac/u_gtf_wiz_ip_top/inst/phase_shift_mmcm_inst/inst/mmcme4_adv_inst/CLKOUT0B]]
set_false_path -from [get_clocks -of_objects [get_pins i_gtfmac/u_gtf_wiz_ip_top/inst/phase_shift_mmcm_inst/inst/mmcme4_adv_inst/CLKOUT0B]] -to [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins i_gtfmac/u_gtf_wiz_ip_top/inst/phase_shift_mmcm_inst/inst/mmcme4_adv_inst/CLKOUT0B]] -to [get_clocks -of_objects [get_pins i_gtfmac/clk_wiz_freerun_inst/inst/mmcme4_adv_inst/CLKOUT1]]

set_max_delay -through [get_nets i_gtfmac_vnc_core/i_latency/i_lat_mon/i_sync_pkt_sent_event/tx_pkt_sent] 1.950
set_min_delay -through [get_nets i_gtfmac_vnc_core/i_latency/i_lat_mon/i_sync_pkt_sent_event/tx_pkt_sent] 0.450
set_max_delay -through [get_nets i_gtfmac_vnc_core/i_latency/i_lat_mon/i_sync_tx_measured_run_event/tx_start_run] 1.950
set_min_delay -through [get_nets i_gtfmac_vnc_core/i_latency/i_lat_mon/i_sync_tx_measured_run_event/tx_start_run] 0.450

set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets axi_aclk]


# Force 1/2 cycle propagation delays from Tx signals sampled for ILA (in RX domain)
set_max_delay -to [get_pins tx_axis_tvalid_ila_r_reg[1]_srl2/D]      1.950
set_max_delay -to [get_pins tx_axis_tready_ila_r_reg[1]_srl2/D]      1.950
set_max_delay -to [get_pins tx_axis_tcan_start_ila_r_reg[1]_srl2/D]  1.950
set_max_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][0]_srl2/D]    1.950
set_max_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][1]_srl2/D]    1.950
set_max_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][2]_srl2/D]    1.950
set_max_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][3]_srl2/D]    1.950
set_max_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][4]_srl2/D]    1.950
set_max_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][5]_srl2/D]    1.950
set_max_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][6]_srl2/D]    1.950
set_max_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][7]_srl2/D]    1.950
set_max_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][8]_srl2/D]    1.950
set_max_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][9]_srl2/D]    1.950
set_max_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][10]_srl2/D]   1.950
set_max_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][11]_srl2/D]   1.950
set_max_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][12]_srl2/D]   1.950
set_max_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][13]_srl2/D]   1.950
set_max_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][14]_srl2/D]   1.950
set_max_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][15]_srl2/D]   1.950
                                                            
set_min_delay -to [get_pins tx_axis_tvalid_ila_r_reg[1]_srl2/D]      0.450
set_min_delay -to [get_pins tx_axis_tready_ila_r_reg[1]_srl2/D]      0.450
set_min_delay -to [get_pins tx_axis_tcan_start_ila_r_reg[1]_srl2/D]  0.450
set_min_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][0]_srl2/D]    0.450
set_min_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][1]_srl2/D]    0.450
set_min_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][2]_srl2/D]    0.450
set_min_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][3]_srl2/D]    0.450
set_min_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][4]_srl2/D]    0.450
set_min_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][5]_srl2/D]    0.450
set_min_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][6]_srl2/D]    0.450
set_min_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][7]_srl2/D]    0.450
set_min_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][8]_srl2/D]    0.450
set_min_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][9]_srl2/D]    0.450
set_min_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][10]_srl2/D]   0.450
set_min_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][11]_srl2/D]   0.450
set_min_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][12]_srl2/D]   0.450
set_min_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][13]_srl2/D]   0.450
set_min_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][14]_srl2/D]   0.450
set_min_delay -to [get_pins tx_axis_tdata_ila_r_reg[1][15]_srl2/D]   0.450
