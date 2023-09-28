#
# Copyright (C) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

#*****************************************************************************************
# Build script for FINN Latency design
# Typical usage: source ./setup.tcl
#*****************************************************************************************

# Create the project and directory structure
set _script_dir_ [eval pwd]

# Set the reference directory to where repo is
set _origin_dir_ [file dirname ${_script_dir_}]

puts $_origin_dir_

set _proj_name_ FINN_Latency
set _part_name_ xcvu2p-fsvj2104-3-e
set _proj_path_ ${_script_dir_}/${_proj_name_}

set_msg_config -id {Designutils 20-1275} -severity "CRITICAL WARNING" -new_severity "INFO"

puts "message suppressed"

create_project -force ${_proj_name_} ${_proj_path_} -part ${_part_name_}

# Add various sources to the project

add_files ${_origin_dir_}/RTL

add_files -fileset sim_1 ${_origin_dir_}/Sim

add_files -norecurse -fileset constrs_1 ${_origin_dir_}/XDC/FINN_Latency.xdc

# add_files -fileset sim_1 -norecurse ${_origin_dir_}/Sim/FINN_Latency_Top_TB.sv

update_compile_order -fileset sim_1

# Set file type of Verilog files to SystemVerilog
set_property file_type {SystemVerilog} [get_files *.sv]

add_files -fileset sim_1 -norecurse ${_origin_dir_}/Sim/FINN_Latency_Top_TB_behav.wcfg

set_property xsim.view ${_origin_dir_}/Sim/FINN_Latency_Top_TB_behav.wcfg [get_filesets sim_1]

# #################################################################
# CREATE IP REPOSITORY for FINN block
#
# this block needs to be gunzipped and tar extracted first manually
#
# #################################################################

set_property  ip_repo_paths  ${_origin_dir_}/IP/finn-mlp-design/prebuilt/UL3524_Launch_Sept23 [current_project]
update_ip_catalog

create_ip -name finn_design -vendor xilinx_finn -library finn -version 1.0 -module_name finn_design_0
generate_target {instantiation_template} [get_files ${_origin_dir_}/Vivado_Project/FINN_Latency/FINN_Latency.srcs/sources_1/ip/finn_design_0/finn_design_0.xci]

update_compile_order -fileset sources_1
generate_target all [get_files  ${_origin_dir_}/Vivado_Project/FINN_Latency/FINN_Latency.srcs/sources_1/ip/finn_design_0/finn_design_0.xci]

export_ip_user_files -of_objects [get_files ${_origin_dir_}/Vivado_Project/FINN_Latency/FINN_Latency.srcs/sources_1/ip/finn_design_0/finn_design_0.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] ${_origin_dir_}/Vivado_Project/FINN_Latency/FINN_Latency.srcs/sources_1/ip/finn_design_0/finn_design_0.xci]

export_simulation -of_objects [get_files ${_origin_dir_}/Vivado_Project/FINN_Latency/FINN_Latency.srcs/sources_1/ip/finn_design_0/finn_design_0.xci] -directory ${_origin_dir_}/Vivado_Project/FINN_Latency/FINN_Latency.ip_user_files/sim_scripts -ip_user_files_dir ${_origin_dir_}/Vivado_Project/FINN_Latency/FINN_Latency.ip_user_files -ipstatic_source_dir ${_origin_dir_}/Vivado_Project/FINN_Latency/FINN_Latency.ip_user_files/ipstatic -lib_map_path [list {modelsim=/group/cdc_co/members/lasonj/ull28Aug2023/Reference-Designs/UL3524/FINN_Latency/Vivado_Project/FINN_Latency/FINN_Latency.cache/compile_simlib/modelsim} {questa=/group/cdc_co/members/lasonj/ull28Aug2023/Reference-Designs/UL3524/FINN_Latency/Vivado_Project/FINN_Latency/FINN_Latency.cache/compile_simlib/questa} {xcelium=/group/cdc_co/members/lasonj/ull28Aug2023/Reference-Designs/UL3524/FINN_Latency/Vivado_Project/FINN_Latency/FINN_Latency.cache/compile_simlib/xcelium} {vcs=/group/cdc_co/members/lasonj/ull28Aug2023/Reference-Designs/UL3524/FINN_Latency/Vivado_Project/FINN_Latency/FINN_Latency.cache/compile_simlib/vcs} {riviera=/group/cdc_co/members/lasonj/ull28Aug2023/Reference-Designs/UL3524/FINN_Latency/Vivado_Project/FINN_Latency/FINN_Latency.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet

update_compile_order -fileset sources_1

exec cp ${_origin_dir_}/Vivado_Project/FINN_Latency/FINN_Latency.gen/sources_1/ip/finn_design_0/sim/finn_design_0.v ${_origin_dir_}/Sim



if 0 {
set_property  ip_repo_paths  ${_origin_dir_}/FINNIPRepo/v5/output_finn_latency-mlp_xcvu2p-fsvj2104-3-e [current_project]
update_ip_catalog

# #################################################################
# CREATE FINN IP
#
# #################################################################


create_ip -name finn_design -vendor xilinx_finn -library finn -version 1.0 -module_name finn_design_0
generate_target {instantiation_template} [get_files ${_origin_dir_}/Vivado_Project/FINN_Latency/FINN_Latency.srcs/sources_1/ip/finn_design_0/finn_design_0.xci]

update_compile_order -fileset sources_1
generate_target all [get_files  ${_origin_dir_}/Vivado_Project/FINN_Latency/FINN_Latency.srcs/sources_1/ip/finn_design_0/finn_design_0.xci]

export_ip_user_files -of_objects [get_files ${_origin_dir_}/Vivado_Project/FINN_Latency/FINN_Latency.srcs/sources_1/ip/finn_design_0/finn_design_0.xci] -no_script -sync -force -quiet

export_simulation -of_objects [get_files ${_origin_dir_}/Vivado_Project/FINN_Latency/FINN_Latency.srcs/sources_1/ip/finn_design_0/finn_design_0.xci] -directory ${_origin_dir_}/Vivado_Project/FINN_Latency/FINN_Latency.ip_user_files/sim_scripts -ip_user_files_dir ${_origin_dir_}/Vivado_Project/FINN_Latency/FINN_Latency.ip_user_files -ipstatic_source_dir ${_origin_dir_}/Vivado_Project/FINN_Latency/FINN_Latency.ip_user_files/ipstatic -lib_map_path [list {modelsim=/group/cdc_co/members/lasonj/ull/Reference-Designs/UL3x24/FINN_Latency/Vivado_Project/FINN_Latency/FINN_Latency.cache/compile_simlib/modelsim} {questa=/group/cdc_co/members/lasonj/ull/Reference-Designs/UL3x24/FINN_Latency/Vivado_Project/FINN_Latency/FINN_Latency.cache/compile_simlib/questa} {xcelium=/group/cdc_co/members/lasonj/ull/Reference-Designs/UL3x24/FINN_Latency/Vivado_Project/FINN_Latency/FINN_Latency.cache/compile_simlib/xcelium} {vcs=/group/cdc_co/members/lasonj/ull/Reference-Designs/UL3x24/FINN_Latency/Vivado_Project/FINN_Latency/FINN_Latency.cache/compile_simlib/vcs} {riviera=/group/cdc_co/members/lasonj/ull/Reference-Designs/UL3x24/FINN_Latency/Vivado_Project/FINN_Latency/FINN_Latency.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet

update_compile_order -fileset sources_1

exec cp ${_origin_dir_}/Vivado_Project/FINN_Latency/FINN_Latency.gen/sources_1/ip/finn_design_0/sim/finn_design_0.v ${_origin_dir_}/Sim

}

# #################################################################
# CREATE IP clk_wiz_0
# #################################################################

create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0

set_property -dict [list \
  CONFIG.CLKIN1_JITTER_PS {33.330000000000005} \
  CONFIG.CLKOUT1_JITTER {80.786} \
  CONFIG.CLKOUT1_PHASE_ERROR {77.836} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {320.00} \
  CONFIG.MMCM_CLKFBOUT_MULT_F {4.000} \
  CONFIG.MMCM_CLKIN1_PERIOD {3.333} \
  CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {3.750} \
  CONFIG.OPTIMIZE_CLOCKING_STRUCTURE_EN {true} \
  CONFIG.PRIM_IN_FREQ {300} \
  CONFIG.RESET_PORT {resetn} \
  CONFIG.RESET_TYPE {ACTIVE_LOW} \
  CONFIG.USE_RESET {false} \
] [get_ips clk_wiz_0]

generate_target {instantiation_template} [get_files ${_proj_path_}/${_proj_name_}.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci]

# #################################################################
# CREATE IP ila_0
# #################################################################

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_0

# User Parameters
set_property -dict [list \
  CONFIG.C_ADV_TRIGGER {true} \
  CONFIG.C_DATA_DEPTH {4096} \
  CONFIG.C_EN_STRG_QUAL {1} \
  CONFIG.C_INPUT_PIPE_STAGES {2} \
  CONFIG.C_NUM_OF_PROBES {5} \
  CONFIG.C_PROBE0_WIDTH {64} \
  CONFIG.C_PROBE15_WIDTH {1} \
  CONFIG.C_PROBE16_WIDTH {1} \
  CONFIG.C_PROBE17_WIDTH {1} \
  CONFIG.C_PROBE18_WIDTH {1} \
  CONFIG.C_PROBE19_WIDTH {1} \
  CONFIG.C_PROBE22_WIDTH {1} \
  CONFIG.C_PROBE23_WIDTH {1} \
  CONFIG.C_PROBE24_WIDTH {1} \
  CONFIG.C_PROBE25_WIDTH {1} \
  CONFIG.C_PROBE27_WIDTH {1} \
  CONFIG.C_PROBE3_WIDTH {8} \
  CONFIG.C_PROBE6_WIDTH {1} \
  CONFIG.C_PROBE7_WIDTH {1} \
  CONFIG.C_PROBE8_WIDTH {1} \
  CONFIG.C_PROBE9_WIDTH {1} \
] [get_ips ila_0]

generate_target {instantiation_template} [get_files ${_proj_path_}/${_proj_name_}.srcs/sources_1/ip/ila_0/ila_0.xci]

##################################################################
# MAIN FLOW
##################################################################

puts {synth_design begin...}

launch_runs synth_1 -jobs 28

wait_on_run synth_1

puts {Synthesis complete...}



# update_compile_order -fileset sim_1



puts {Disble clk wiz xdc file...}
# 
# set_property is_enabled false [get_files  /group/cdc_co/members/lasonj/ull18Sep2023/Reference-Designs/UL3524/FINN_Latency/Vivado_Project/FINN_Latency/FINN_Latency.gen/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc]
set_property is_enabled false [get_files  $_origin_dir_/Vivado_Project/FINN_Latency/FINN_Latency.gen/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc]
# 
puts {xdc for clk wiz disabled...}

reset_run clk_wiz_0_synth_1
reset_run synth_1

puts {Run Implementation...}

launch_runs impl_1 -jobs 28

wait_on_run impl_1

puts {Implementation complete...}

puts {Setup complete...}


