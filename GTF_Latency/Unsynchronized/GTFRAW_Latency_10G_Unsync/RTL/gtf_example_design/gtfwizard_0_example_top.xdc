#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#


create_clock -period 3.333 [get_ports hb_gtwiz_reset_clk_freerun_p_in]
set_property PACKAGE_PIN AW19 [get_ports hb_gtwiz_reset_clk_freerun_p_in]
set_property IOSTANDARD LVDS [get_ports hb_gtwiz_reset_clk_freerun_p_in]
create_clock -period 6.206 [get_ports refclk_p]
set_property LOC GTF_COMMON_X1Y2 [get_cells -hierarchical -filter {NAME =~ example_gtf_common_inst/gtf_common_inst}]
set_property LOC GTF_COMMON_X1Y2 [get_cells IBUFDS_GTE4_INST]
#create_clock -period 6.206 [get_ports refclk_p]
set_property PACKAGE_PIN AN11 [get_ports refclk_p]

set_property PACKAGE_PIN AP4 [get_ports gtf_ch_gtfrxp[0]]
set_property PACKAGE_PIN AT9 [get_ports gtf_ch_gtftxp[0]]


