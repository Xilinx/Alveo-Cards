#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

create_clock -period 3.333 [get_ports hb_gtwiz_reset_clk_freerun_p_in]
set_property PACKAGE_PIN AW19 [get_ports hb_gtwiz_reset_clk_freerun_p_in]
set_property IOSTANDARD LVDS [get_ports hb_gtwiz_reset_clk_freerun_p_in]
create_clock -period 6.206 [get_ports refclk_p]
set_property LOC GTF_COMMON_X1Y2 [get_cells -hierarchical -filter {NAME =~ i_gtfmac/example_gtf_common_inst/gtf_common_inst}]
set_property PACKAGE_PIN AP4 [get_ports gtf_ch_gtfrxp[0]]
set_property PACKAGE_PIN AT9 [get_ports gtf_ch_gtftxp[0]]

set_property PACKAGE_PIN AN11 [get_ports refclk_p]
create_generated_clock -name i_gtfmac/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK -source [get_pins i_gtfmac/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/gtf_ch_gtrefclk0] -multiply_by 4 [get_pins i_gtfmac/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK]
create_generated_clock -name i_gtfmac/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK -source [get_pins i_gtfmac/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/gtf_ch_gtrefclk0] -multiply_by 4 [get_pins i_gtfmac/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK]

set_false_path -to [get_cells -hierarchical -filter  {NAME =~ *meta_reg[0]}]

set_false_path -from [get_clocks i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK] -to [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK] -to [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]]
set_false_path -from [get_clocks i_gtfmac/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK] -to [get_clocks i_gtfmac/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK]

set_false_path -from [get_clocks i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK] -to [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] 
set_false_path -from [get_clocks i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK] -to [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] 
set_false_path -from [get_clocks i_gtfmac/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK] -to [get_clocks i_gtfmac/gen_blk_multi_ch[0].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK]

set_false_path -from [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] -to [get_clocks i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK]
set_false_path -from [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] -to [get_clocks i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK] 
set_false_path -from [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] 

set_false_path -from [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] -to [get_clocks i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/RXOUTCLK]
set_false_path -from [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] -to [get_clocks i_gtfmac/gen_blk_multi_ch[*].u_gtf_wiz_ip_top/inst/gtf_channel_inst/gtf_channel_inst/TXOUTCLK] 
set_false_path -from [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins clk_wiz_300_to_161_inst/inst/mmcme4_adv_inst/CLKOUT0]] 

