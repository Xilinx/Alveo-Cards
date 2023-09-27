#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

# Typical usage: source ./setup.tcl
# Create the project and directory structure

# Set to where the script is
# set _script_dir_ [file normalize [info script]]

# Set to the current location of Vivado, recommend CDing to Script/
set _script_dir_ [eval pwd]

# Set the reference directory to where repo is
set _origin_dir_ [file dirname ${_script_dir_}]

set _proj_name_ project_1
set _part_name_ xcvu2p-fsvj2104-3-e
set _proj_path_ ${_script_dir_}/${_proj_name_}

create_project -force ${_proj_name_} ${_proj_path_} -part ${_part_name_}

# Add various sources to the project
add_files -norecurse ${_origin_dir_}/RTL/qdriip_ref_simple_top.sv \
${_origin_dir_}/RTL/simple_axi_master.sv

add_files -norecurse -fileset sim_1 ${_origin_dir_}/Sim/G82582DT20E.v \
${_origin_dir_}/Sim/qdriip_ref_simple_tb.sv \
${_origin_dir_}/Sim/qdriip_ref_simple_tb_behav.wcfg

add_files -norecurse -fileset constrs_1 ${_origin_dir_}/XDC/ul3524_qdr_ref.xdc

# set_property xsim.view ${_origin_dir_}/Vivado_Project/qdriip_ref_simple_tb_behav.wcfg [get_filesets sim_1]

# Add external IP repo path and rebuild
set_property ip_repo_paths [list ${_origin_dir_}/IP] [current_project]
update_ip_catalog -rebuild

# Generate QDRII+ IP
create_ip -name qdriip -vendor xilinx.com -library ip -version 1.4 -module_name qdriip_0
set_property -dict [list \
  CONFIG.C0.QDRIIP_TimePeriod {1818} \
  CONFIG.C0.QDRIIP_InputClockPeriod {3334} \
  CONFIG.C0.QDRIIP_BurstLen {4} \
  CONFIG.C0.QDRIIP_MemoryPart {GS82582DT20GE-550} \
] [get_ips qdriip_0]
generate_target {instantiation_template} [get_files ${_proj_path_}/${_proj_name_}.srcs/sources_1/ip/qdriip_0/qdriip_0.xci]

# Generate AXI-QDRII+ Bridge IP
create_ip -name axi_qdriip_bridge -vendor xilinx.com -library ip -version 1.0 -module_name axi_qdriip_bridge_0
generate_target {instantiation_template} [get_files ${_proj_path_}/${_proj_name_}.srcs/sources_1/ip/axi_qdriip_bridge_0/axi_qdriip_bridge_0.xci]

# Generate VIO IP
create_ip -name vio -vendor xilinx.com -library ip -version 3.0 -module_name vio_0
set_property -dict [list \
  CONFIG.C_NUM_PROBE_IN {5} \
  CONFIG.C_PROBE_IN3_WIDTH {7} \
] [get_ips vio_0]
generate_target {instantiation_template} [get_files ${_proj_path_}/${_proj_name_}.srcs/sources_1/ip/vio_0/vio_0.xci]

# Generate ILA IP
create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_0
set_property -dict [list \
  CONFIG.C_DATA_DEPTH {16384} \
  CONFIG.C_NUM_OF_PROBES {21} \
  CONFIG.C_PROBE0_WIDTH {32} \
  CONFIG.C_PROBE1_WIDTH {8} \
  CONFIG.C_PROBE5_WIDTH {64} \
  CONFIG.C_PROBE6_WIDTH {8} \
  CONFIG.C_PROBE9_WIDTH {2} \
  CONFIG.C_PROBE12_WIDTH {32} \
  CONFIG.C_PROBE13_WIDTH {8} \
  CONFIG.C_PROBE16_WIDTH {64} \
  CONFIG.C_PROBE17_WIDTH {2} \
] [get_ips ila_0]
generate_target {instantiation_template} [get_files ${_proj_path_}/${_proj_name_}.srcs/sources_1/ip/ila_0/ila_0.xci]

# Update to set top and file compile order
set_property top qdriip_ref_simple_top [current_fileset]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1


puts {Setup complete...}
