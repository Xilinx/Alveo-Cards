#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

##################################################################
# CHECK VIVADO VERSION
##################################################################

set scripts_vivado_version 2023.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
  catch {common::send_msg_id "IPS_TCL-100" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_ip_tcl to create an updated script."}
  return 1
}

##################################################################
# START
##################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source lat_mon_ila.tcl
# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
  create_project project_1 project_1 -part xcvu2p-fsvj2104-3-e
  set_property target_language Verilog [current_project]
  set_property simulator_language Mixed [current_project]
}

##################################################################
# CHECK IPs
##################################################################

set bCheckIPs 1
set bCheckIPsPassed 1
if { $bCheckIPs == 1 } {
  set list_check_ips { xilinx.com:ip:ila:6.2 }
  set list_ips_missing ""
  common::send_msg_id "IPS_TCL-1001" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

  foreach ip_vlnv $list_check_ips {
  set ip_obj [get_ipdefs -all $ip_vlnv]
  if { $ip_obj eq "" } {
    lappend list_ips_missing $ip_vlnv
    }
  }

  if { $list_ips_missing ne "" } {
    catch {common::send_msg_id "IPS_TCL-105" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
    set bCheckIPsPassed 0
  }
}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "IPS_TCL-102" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 1
}

##################################################################
# CREATE IP lat_mon_ila
##################################################################

set lat_mon_ila [create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name lat_mon_ila]

# User Parameters
set_property -dict [list \
  CONFIG.C_DATA_DEPTH {2048} \
  CONFIG.C_INPUT_PIPE_STAGES {3} \
  CONFIG.C_NUM_OF_PROBES {12} \
  CONFIG.C_PROBE0_WIDTH {32} \
  CONFIG.C_PROBE11_WIDTH {32} \
  CONFIG.C_PROBE1_WIDTH {16} \
  CONFIG.C_PROBE2_WIDTH {16} \
  CONFIG.C_PROBE3_WIDTH {16} \
  CONFIG.C_PROBE5_WIDTH {16} \
  CONFIG.C_PROBE6_WIDTH {16} \
  CONFIG.C_PROBE7_WIDTH {16} \
  CONFIG.C_PROBE8_WIDTH {16} \
] [get_ips lat_mon_ila]

# Runtime Parameters
set_property -dict { 
  GENERATE_SYNTH_CHECKPOINT {1}
} $lat_mon_ila

##################################################################

