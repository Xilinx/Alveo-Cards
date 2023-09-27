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

# Remove project folder if already exists...
if { [file exist ${_origin_dir_}/Vivado_project/${_proj_name_}] == 1 } {
    file delete ${_origin_dir_}/Vivado_project/${_proj_name_}
}

create_project -force ${_proj_name_} ${_proj_path_} -part ${_part_name_}


#
# RTL Design Files
#
add_files -fileset sources_1 ${_origin_dir_}/rtl/sync/syncer_level.sv
add_files -fileset sources_1 ${_origin_dir_}/rtl/sync/syncer_pulse.sv
add_files -fileset sources_1 ${_origin_dir_}/rtl/sync/syncer_reset.sv

add_files -fileset sources_1 ${_origin_dir_}/rtl/imports/gtfwizard_raw_example_init.v
add_files -fileset sources_1 ${_origin_dir_}/rtl/imports/gtfwizard_raw_example_top.v
add_files -fileset sources_1 ${_origin_dir_}/rtl/imports/gtfwizard_raw_gtf_common.v

add_files -fileset sources_1 ${_origin_dir_}/rtl/latency/gtfmac_vnc_latency.sv
add_files -fileset sources_1 ${_origin_dir_}/rtl/latency/gtfmac_vnc_lat_mon.sv
add_files -fileset sources_1 ${_origin_dir_}/rtl/latency/gtfmac_vnc_simple_bram.sv

add_files -fileset sources_1 ${_origin_dir_}/rtl/system/clk_reset.v
add_files -fileset sources_1 ${_origin_dir_}/rtl/system/reg_axi_slave.v
add_files -fileset sources_1 ${_origin_dir_}/rtl/system/reg_latency_raw_logic.v
add_files -fileset sources_1 ${_origin_dir_}/rtl/system/reg_latency_raw_top.v

add_files -fileset sources_1 ${_origin_dir_}/rtl/gtfwizard_raw/gtfwizard_raw_delay_powergood.v
add_files -fileset sources_1 ${_origin_dir_}/rtl/gtfwizard_raw/gtfwizard_raw_gtf_channel.v
add_files -fileset sources_1 ${_origin_dir_}/rtl/gtfwizard_raw/gtfwizard_raw_gtf_ch_drp_align_switch.sv
add_files -fileset sources_1 ${_origin_dir_}/rtl/gtfwizard_raw/gtfwizard_raw_gtwiz_buffbypass_rx.v
add_files -fileset sources_1 ${_origin_dir_}/rtl/gtfwizard_raw/gtfwizard_raw_gtwiz_buffbypass_tx.v
add_files -fileset sources_1 ${_origin_dir_}/rtl/gtfwizard_raw/gtfwizard_raw_reset.v
add_files -fileset sources_1 ${_origin_dir_}/rtl/gtfwizard_raw/gtfwizard_raw_rules_output.vh
add_files -fileset sources_1 ${_origin_dir_}/rtl/gtfwizard_raw/gtfwizard_raw_top.v
add_files -fileset sources_1 ${_origin_dir_}/rtl/gtfwizard_raw/gtfwizard_raw.v

add_files -fileset sources_1 ${_origin_dir_}/rtl/gtfwizard_raw_top.v

#
# Simulation files...  (also pulls in additional local sv files in sim folder)
#
set_property SOURCE_SET sources_1 [get_filesets sim_1]
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 ${_origin_dir_}/sim/sim_top.sv

add_files -fileset sim_1 -norecurse ${_origin_dir_}/sim/sim_top_behav.wcfg


#
# Design IP Files and Scripts...
#
source ${_origin_dir_}/ip/clk_wiz_0.tcl
source ${_origin_dir_}/ip/clk_wiz_1.tcl
source ${_origin_dir_}/ip/jtag_axi_0.tcl
source ${_origin_dir_}/ip/vio_system.tcl
source ${_origin_dir_}/ip/ila_prbs_rx.tcl
source ${_origin_dir_}/ip/lat_mon_ila.tcl

import_files -norecurse ${_origin_dir_}/ip/gtfwizard_raw_example_clk_wiz/gtfwizard_raw_example_clk_wiz.xci


#
# Constraint files...
#
add_files -fileset constrs_1 -norecurse ${_origin_dir_}/xdc/constraint_synth.xdc
add_files -fileset constrs_1 -norecurse ${_origin_dir_}/xdc/constraint_io.xdc
add_files -fileset constrs_1 -norecurse ${_origin_dir_}/xdc/constraint_timing.xdc

set_property used_in_synthesis false [get_files ${_origin_dir_}/xdc/constraint_io.xdc]
set_property used_in_synthesis false [get_files ${_origin_dir_}/xdc/constraint_timing.xdc]

#
# Finish Environment Setup...
#
set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE ExtraNetDelay_low [get_runs impl_1]

set_property top        gtfwizard_raw_top0           [current_fileset]
set_property top_lib    xil_defaultlib               [get_filesets sim_1]
set_property top        sim_top                      [get_filesets sim_1]

update_compile_order -fileset sim_1
update_compile_order -fileset sources_1


# Remove critical warnings about clock creation overrides...
set_msg_config -suppress -id {Constraints 18-1055} 
set_msg_config -suppress -id {Constraints 18-1056} 



