# 
# Copyright (C) 2024, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: X11
# 
# Create the project and directory structure
set _script_dir_ [eval pwd]

# Set the reference directory to where repo is
set _origin_dir_ [file dirname ${_script_dir_}]

set _proj_name_ project_1
set _proj_path_ ${_script_dir_}/${_proj_name_}


#
# Launch synthesis as quick way to build IP modules in parallel...
#

puts "#"
puts "#"
puts "#  Synthesizing IP Blocks..."
puts "#"
puts "#"

reset_run synth_1
launch_runs synth_1 -jobs 12

generate_target all [get_files  ${_proj_path_}/${_proj_name_}.srcs/sources_1/ip/jtag_axi_0/jtag_axi_0.xci]
wait_on_runs synth_1


#
# Launch Simulation  
#

puts "#"
puts "#"
puts "#  Launching simulation..."
puts "#"
puts "#"

if { [current_sim] != "" } {
    puts "Closing current simulation first..."
    close_sim
}

launch_simulation

puts "#"
puts "#"
puts "#  Simulation Setup Complete"
puts "#"
puts "#"
