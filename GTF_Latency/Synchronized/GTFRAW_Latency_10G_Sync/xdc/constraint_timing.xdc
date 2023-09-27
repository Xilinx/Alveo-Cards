#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#


#################################################################################
#
# False Path Contraints
#
#################################################################################

# Common False Path
#set_false_path -to   [get_cells -hierarchical -filter  {NAME =~ *meta_reg[0]}]
#set_false_path -from [get_pins -filter {REF_PIN_NAME =~ C}   -of_objects [get_cells -hierarchical -filter {NAME=~ "*latched_inputs*[*]"}] ] -to [get_pins -filter {REF_PIN_NAME =~ D} -of_objects [get_cells -hierarchical -filter {NAME=~ "*busout_reg*[*]"}]]
#set_false_path -to   [get_pins -filter {REF_PIN_NAME =~ CLR} -of_objects [get_cells -hierarchical -filter {NAME =~ "*reset_pipe_out*"}]]
#set_false_path -to   [get_pins -filter {REF_PIN_NAME =~ CLR} -of_objects [get_cells -hierarchical -filter {NAME =~ "*reset_pipe_retime*"}]]
#set_false_path -to   [get_pins -filter {REF_PIN_NAME =~ CLR} -of_objects [get_cells -hierarchical -filter {NAME =~ "*resetn_pipe_out*"}]]
#set_false_path -to   [get_pins -filter {REF_PIN_NAME =~ CLR} -of_objects [get_cells -hierarchical -filter {NAME =~ "*resetn_pipe_retime*"}]]
#set_false_path -to   [get_pins -filter {REF_PIN_NAME =~ C}   -of_objects [get_cells -hierarchical -filter {NAME =~ "*clkin_reset_r2*"}]]
#set_false_path -to   [get_pins -filter {REF_PIN_NAME =~ C}   -of_objects [get_cells -hierarchical -filter {NAME =~ "*clkout_reset_r2*"}]]
#set_false_path -from [get_pins -filter {REF_PIN_NAME =~ C}   -of_objects [get_cells -hierarchical -filter {NAME =~ "*rx_resetn_pulse_reg*"}]]



#
# Common Clocks
#   CLKOUT0 = 200 Mhz
#   CLKOUT1 = 425 Mhz
#
set CLK_REF_200 [get_clocks -of_objects [get_pins u_gtfwizard_raw_example_top/clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]]
set CLK_REF_425 [get_clocks -of_objects [get_pins u_gtfwizard_raw_example_top/clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]]

set CLK_REF_100 [get_clocks -of_objects [get_pins clk_reset/clk_wiz_100mhz/inst/mmcme4_adv_inst/CLKOUT0]]
set CLK_REF_50  [get_clocks -of_objects [get_pins clk_reset/clk_wiz_100mhz/inst/mmcme4_adv_inst/CLKOUT1]]

set_false_path -from $CLK_REF_200 -to $CLK_REF_425
set_false_path -from $CLK_REF_100 -to $CLK_REF_425
set_false_path -from $CLK_REF_50  -to $CLK_REF_425

set_false_path -from $CLK_REF_425 -to $CLK_REF_200
set_false_path -from $CLK_REF_100 -to $CLK_REF_200
set_false_path -from $CLK_REF_50  -to $CLK_REF_200

set_false_path -from $CLK_REF_425 -to $CLK_REF_100
set_false_path -from $CLK_REF_200 -to $CLK_REF_100
set_false_path -from $CLK_REF_50  -to $CLK_REF_100

set_false_path -from $CLK_REF_425 -to $CLK_REF_50
set_false_path -from $CLK_REF_200 -to $CLK_REF_50
set_false_path -from $CLK_REF_100 -to $CLK_REF_50


#
# False path dealing with frequency monitor for SYNCE clocks
#    
#set_false_path -from [get_clocks CLK_SYNCE_CLK10_LVDS_P] -to ${CLK_REF_100}
set_false_path -from [get_clocks CLK_SYNCE_CLK11_LVDS_P] -to ${CLK_REF_100}
#set_false_path -from [get_clocks CLK_SYNCE_CLK12_LVDS_P] -to ${CLK_REF_100}
#set_false_path -from [get_clocks CLK_SYNCE_CLK13_LVDS_P] -to ${CLK_REF_100}
#set_false_path -from [get_clocks CLK_SYNCE_CLK14_LVDS_P] -to ${CLK_REF_100}
#set_false_path -from [get_clocks CLK_SYNCE_CLK15_LVDS_P] -to ${CLK_REF_100}
#set_false_path -from [get_clocks CLK_SYNCE_CLK16_LVDS_P] -to ${CLK_REF_100}
#set_false_path -from [get_clocks CLK_SYNCE_CLK17_LVDS_P] -to ${CLK_REF_100}

#set_false_path -from  ${CLK_REF_100} -to [get_clocks CLK_SYNCE_CLK10_LVDS_P]    
set_false_path -from  ${CLK_REF_100} -to [get_clocks CLK_SYNCE_CLK11_LVDS_P]    
#set_false_path -from  ${CLK_REF_100} -to [get_clocks CLK_SYNCE_CLK12_LVDS_P]    
#set_false_path -from  ${CLK_REF_100} -to [get_clocks CLK_SYNCE_CLK13_LVDS_P]    
#set_false_path -from  ${CLK_REF_100} -to [get_clocks CLK_SYNCE_CLK14_LVDS_P]    
#set_false_path -from  ${CLK_REF_100} -to [get_clocks CLK_SYNCE_CLK15_LVDS_P]    
#set_false_path -from  ${CLK_REF_100} -to [get_clocks CLK_SYNCE_CLK16_LVDS_P]    
#set_false_path -from  ${CLK_REF_100} -to [get_clocks CLK_SYNCE_CLK17_LVDS_P]    


#
# MAC 0
#
#set_property FORCE_MAX_FANOUT 3 [get_cells u_gtfwizard_raw_example_top/i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/i_axi_if_soft_top/i_pif_registers/tx_resetn_pulse_len_reg[0]]
#set_property FORCE_MAX_FANOUT 3 [get_cells u_gtfwizard_raw_example_top/i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/i_axi_if_soft_top/i_pif_registers/rx_resetn_pulse_len_reg[0]]
#set_property USER_CLUSTER uc_group_gtf_q0_ch00_tx_001 [list [get_cells u_gtfwizard_raw_example_top/gtfmac_hwchk_core_gen[0].i_gtfmac_hwchk_core/i_tx_gen/i_tx_frm_gen/frames_to_send_reg[*]] \
#                                                            [get_cells u_gtfwizard_raw_example_top/gtfmac_hwchk_core_gen[0].i_gtfmac_hwchk_core/i_tx_gen/i_tx_frm_gen/data_reg[*]] ]

#set_max_delay -from [get_clocks -of_objects [get_pins u_gtfwizard_raw_example_top/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/phase_shift_mmcm_inst/inst/mmcme4_adv_inst/CLKOUT0B]] \
#              -to   $CLK_REF_100 \
#              -datapath_only 10.000
#    
#set_max_delay -from [get_clocks -of_objects [get_pins u_gtfwizard_raw_example_top/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK]] \
#              -to   $CLK_REF_200 \
#              -datapath_only 10.000
#set_max_delay -from $CLK_REF_200 \
#              -to   [get_clocks -of_objects [get_pins u_gtfwizard_raw_example_top/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK]] \
#              -datapath_only 10.000
#set_max_delay -from [get_clocks -of_objects [get_pins u_gtfwizard_raw_example_top/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK]] \
#              -to   $CLK_REF_200 \
#              -datapath_only 10.000
#set_max_delay -from $CLK_REF_200 \
#              -to   [get_clocks -of_objects [get_pins u_gtfwizard_raw_example_top/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK]] \
#              -datapath_only 10.000
#              
#set_max_delay -from [get_clocks -of_objects [get_pins u_gtfwizard_raw_example_top/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK]] \
#              -to   $CLK_REF_100 \
#              -datapath_only 10.000
#set_max_delay -from $CLK_REF_100 \
#              -to   [get_clocks -of_objects [get_pins u_gtfwizard_raw_example_top/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK]] \
#              -datapath_only 10.000
#set_max_delay -from [get_clocks -of_objects [get_pins u_gtfwizard_raw_example_top/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK]] \
#              -to   $CLK_REF_100 \
#              -datapath_only 10.000
#set_max_delay -from $CLK_REF_100 \
#              -to   [get_clocks -of_objects [get_pins u_gtfwizard_raw_example_top/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK]] \
#              -datapath_only 10.000
#

#create_clock -period 1.551 -name RXOUTCLK0 [get_pins u_gtfwizard_raw_example_top/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK]
#set CLK_RXOUTCLK0  [get_clocks -of_objects [get_pins u_gtfwizard_raw_example_top/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK]]
#
##create_clock -period 6.207 -name TXOUTCLK0 [get_pins u_gtfwizard_raw_example_top/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK]
#
##set_max_delay -from $TXOUTCLK0 \
##              -to   $RXOUTCLK0 \
##              -datapath_only .750
##
##set_max_delay -from $RXOUTCLK0 \
##              -to   $TXOUTCLK0 \
##              -datapath_only .750
#
##set_max_delay -from $TXOUTCLK0   -to $CLK_RXOUTCLK0   -datapath_only  0.750
##set_max_delay -from $TXOUTCLK0   -to $CLK_REF_200 -datapath_only 10.000
##set_max_delay -from $TXOUTCLK0   -to $CLK_REF_100 -datapath_only 10.000
#                                 
##set_max_delay -from $CLK_RXOUTCLK0   -to $TXOUTCLK0   -datapath_only  0.750
#set_max_delay -from $CLK_RXOUTCLK0   -to $CLK_REF_200 -datapath_only 10.000
#set_max_delay -from $CLK_RXOUTCLK0   -to $CLK_REF_100 -datapath_only 10.000
#
##set_max_delay -from $CLK_REF_200 -to $TXOUTCLK0   -datapath_only 10.000
#set_max_delay -from $CLK_REF_200 -to $CLK_RXOUTCLK0   -datapath_only 10.000
#
##set_max_delay -from $CLK_REF_100 -to $TXOUTCLK0   -datapath_only 10.000                                                  
#set_max_delay -from $CLK_REF_100 -to $CLK_RXOUTCLK0   -datapath_only 10.000
#
#
##get_clocks -of_objects [get_pins u_gtfwizard_raw_example_top/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK]
#


create_clock -period 1.551 -name RXOUTCLK0 [get_pins u_gtfwizard_raw_example_top/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK]
set CLK_RXOUTCLK0  [get_clocks -of_objects [get_pins u_gtfwizard_raw_example_top/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK]]
set CLK_TXUSRCLK   [get_clocks -of_objects [get_pins u_gtfwizard_raw_example_top/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/phase_shift_mmcm_inst/inst/mmcme4_adv_inst/CLKOUT0]]
set CLK_RXUSRCLK   [get_clocks -of_objects [get_pins u_gtfwizard_raw_example_top/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/phase_shift_mmcm_inst/inst/mmcme4_adv_inst/CLKOUT0B]]

set_false_path -from $CLK_REF_200  -to $CLK_TXUSRCLK
set_false_path -from $CLK_REF_200  -to $CLK_RXUSRCLK
                                   
set_false_path -from $CLK_REF_100  -to $CLK_TXUSRCLK
set_false_path -from $CLK_REF_100  -to $CLK_RXUSRCLK

set_false_path -from $CLK_TXUSRCLK -to $CLK_REF_200
set_false_path -from $CLK_TXUSRCLK -to $CLK_REF_100

set_false_path -from $CLK_RXUSRCLK -to $CLK_REF_200
set_false_path -from $CLK_RXUSRCLK -to $CLK_REF_100




#set_max_delay -from [get_pins gtfmac_vnc_latency/i_lat_mon/tx_pkt_sent_0_reg/C] \
#              -to   [get_pins gtfmac_vnc_latency/i_lat_mon/tx_pkt_sent_rx_reg/D] \
#              2.000
# 
#set_min_delay -from [get_pins gtfmac_vnc_latency/i_lat_mon/tx_pkt_sent_0_reg/C] \
#              -to   [get_pins gtfmac_vnc_latency/i_lat_mon/tx_pkt_sent_rx_reg/D] \
#              1.000


#u_gtfwizard_raw_example_top/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/phase_shift_mmcm_inst/inst/mmcme4_adv_inst/CLKIN1

