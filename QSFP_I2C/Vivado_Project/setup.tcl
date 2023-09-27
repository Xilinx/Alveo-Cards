#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

# Typical usage: source ./setup.tcl

# Create the project and directory structure
set _script_dir_ [eval pwd]

# Set the reference directory to where repo is
set _origin_dir_ [file dirname ${_script_dir_}]

set _proj_name_ project_1
set _part_name_ xcvu2p-fsvj2104-3-e
set _proj_path_ ${_script_dir_}/${_proj_name_}

create_project -force ${_proj_name_} ${_proj_path_} -part ${_part_name_}

# Add various sources to the project
add_files ${_origin_dir_}/RTL

add_files -norecurse -fileset constrs_1 ${_origin_dir_}/XDC/constraint.xdc

add_files -fileset sim_1 ${_origin_dir_}/Sim

# Generate I2C Wizard IP
create_ip -name axi_iic -vendor xilinx.com -library ip -version 2.1 -module_name axi_iic_0
set_property -dict [list CONFIG.AXI_ACLK_FREQ_MHZ {50}] [get_ips axi_iic_0]

# Generate ILA Wizard IP
create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_0
set_property -dict [list \
  CONFIG.C_DATA_DEPTH {65536} \
  CONFIG.C_INPUT_PIPE_STAGES {1} \
  CONFIG.C_NUM_OF_PROBES {10} \
] [get_ips ila_0]

# Generate JTAG to AXI Master IP
create_ip -name jtag_axi -vendor xilinx.com -library ip -version 1.2 -module_name jtag_axi_0
set_property CONFIG.PROTOCOL {2} [get_ips jtag_axi_0]

# Generate Clock Wizard IP
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0
set_property -dict [list \
  CONFIG.CLKIN1_JITTER_PS {33.330000000000005} \
  CONFIG.CLKOUT1_JITTER {116.415} \
  CONFIG.CLKOUT1_PHASE_ERROR {77.836} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50.000} \
  CONFIG.MMCM_CLKFBOUT_MULT_F {4.000} \
  CONFIG.MMCM_CLKIN1_PERIOD {3.333} \
  CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {24.000} \
  CONFIG.PRIM_IN_FREQ {300} \
  CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
  CONFIG.USE_RESET {false} \
] [get_ips clk_wiz_0]

# Set top Module...
set_property top qsfp_i2c_top [current_fileset]

# Update compile order...
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts {Setup complete...}
