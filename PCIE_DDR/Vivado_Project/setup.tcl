#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

# ------------------------------------------------------
#
# Setup Environment/Project
#
# ------------------------------------------------------

cd ..
set PROJPATH [eval pwd]
set PROJNAME project_1

create_project ${PROJNAME} ${PROJPATH}/Vivado_Project/${PROJNAME} -part xcvu2p-fsvj2104-3-e


# ------------------------------------------------------
#
# Add Source Files...
#
# ------------------------------------------------------

add_files -norecurse -scan_for_includes ${PROJPATH}/RTL/system_reset.v 
add_files -norecurse -scan_for_includes ${PROJPATH}/RTL/reg_axi_slave.v 
add_files -norecurse -scan_for_includes ${PROJPATH}/RTL/reg_reference_logic.v 
add_files -norecurse -scan_for_includes ${PROJPATH}/RTL/reg_reference_top.v 
add_files -norecurse -scan_for_includes ${PROJPATH}/RTL/axi_master.v 
add_files -norecurse -scan_for_includes ${PROJPATH}/RTL/axi_slave.v 
add_files -norecurse -scan_for_includes ${PROJPATH}/RTL/i2c_axi_sequencer.v 
add_files -norecurse -scan_for_includes ${PROJPATH}/RTL/i2c_sequencer.v
add_files -norecurse -scan_for_includes ${PROJPATH}/RTL/ddr_i2c_top.v 
add_files -norecurse -scan_for_includes ${PROJPATH}/RTL/pcie_ddr_top.v 

add_files -fileset sim_1 ${PROJPATH}/Sim/

add_files -fileset constrs_1 -norecurse ${PROJPATH}/XDC/xilinx_pcie4_uscale_plus_x0y0.xdc

# ------------------------------------------------------
#
# Add IIC...
#
# ------------------------------------------------------

create_ip -name axi_iic -vendor xilinx.com -library ip -version 2.1 -module_name axi_iic_0
set_property CONFIG.AXI_ACLK_FREQ_MHZ {100} [get_ips axi_iic_0]

generate_target {instantiation_template} [get_files ${PROJPATH}/Vivado_Project/${PROJNAME}/${PROJNAME}.srcs/sources_1/ip/axi_iic_0/axi_iic_0.xci]

# ------------------------------------------------------
#
# Add ILA for I2C...
#
# ------------------------------------------------------

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_0
set_property -dict [list \
  CONFIG.C_DATA_DEPTH {65536} \
  CONFIG.C_INPUT_PIPE_STAGES {1} \
  CONFIG.C_NUM_OF_PROBES {8} \
  CONFIG.C_PROBE7_WIDTH {8}
] [get_ips ila_0]

generate_target {instantiation_template} [get_files ${PROJPATH}/Vivado_Project/${PROJNAME}/${PROJNAME}.srcs/sources_1/ip/ila_0/ila_0.xci]

# ------------------------------------------------------
#
# Add DDR...
#
# ------------------------------------------------------

create_ip -name ddr4 -vendor xilinx.com -library ip -version 2.2 -module_name ddr4_0

set_property -dict [list \
  CONFIG.C0.DDR4_AxiSelection {true} \
  CONFIG.C0.DDR4_DataWidth {72} \
  CONFIG.C0.DDR4_InputClockPeriod {3334} \
  CONFIG.C0.DDR4_MemoryPart {MT40A2G8VA-062E} \
] [get_ips ddr4_0]

generate_target {instantiation_template} [get_files ${PROJPATH}/Vivado_Project/${PROJNAME}/${PROJNAME}.srcs/sources_1/ip/ddr4_0/ddr4_0.xci]

# ------------------------------------------------------
#
# Add PCIE and AXI Interconnect...
#
# ------------------------------------------------------

source ${PROJPATH}/Vivado_Project/gen_pcie_axi_2023.tcl

make_wrapper -files [get_files ${PROJPATH}/Vivado_Project/${PROJNAME}/${PROJNAME}.srcs/sources_1/bd/design_1/design_1.bd] -top
add_files -norecurse ${PROJPATH}/Vivado_Project/${PROJNAME}/${PROJNAME}.gen/sources_1/bd/design_1/hdl/design_1_wrapper.v

# Set top instance...
set_property top pcie_ddr_top [get_filesets sources_1]
set_property top sim_top [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
