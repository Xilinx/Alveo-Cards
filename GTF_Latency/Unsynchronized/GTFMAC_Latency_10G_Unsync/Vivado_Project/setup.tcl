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

add_files -fileset sim_1 ${_origin_dir_}/Sim

add_files -norecurse -fileset constrs_1 ${_origin_dir_}/XDC/gtfmac_vnc_top.xdc

# Set file type of Verilog files to SystemVerilog
set_property file_type {SystemVerilog} [get_files *.v]

# Generate GTF Wizard IP
create_ip -name gtfwizard -vendor xilinx.com -library ip -version 1.0 -module_name gtfwizard_0
set_property CONFIG.PRESET {GTF-10G-MAC} [get_ips gtfwizard_0]
generate_target {instantiation_template} [get_files ${_proj_path_}/${_proj_name_}.srcs/sources_1/ip/gtfwizard_0/gtfwizard_0.xci]

# Generate Clock Wizard IP - 300 MHz to 200 MHz / 425 MHz / 50 MHz
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0
set_property -dict [list \
  CONFIG.CLKIN1_JITTER_PS {33.330000000000005} \
  CONFIG.CLKOUT1_DRIVES {BUFG} \
  CONFIG.CLKOUT1_JITTER {87.024} \
  CONFIG.CLKOUT1_PHASE_ERROR {75.422} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {200} \
  CONFIG.CLKOUT2_DRIVES {BUFG} \
  CONFIG.CLKOUT2_JITTER {75.082} \
  CONFIG.CLKOUT2_PHASE_ERROR {75.422} \
  CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {425} \
  CONFIG.CLKOUT2_USED {true} \
  CONFIG.CLKOUT3_DRIVES {Buffer} \
  CONFIG.CLKOUT4_DRIVES {Buffer} \
  CONFIG.CLKOUT5_DRIVES {Buffer} \
  CONFIG.CLKOUT6_DRIVES {Buffer} \
  CONFIG.CLKOUT7_DRIVES {Buffer} \
  CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
  CONFIG.MMCM_CLKFBOUT_MULT_F {4.250} \
  CONFIG.MMCM_CLKIN1_PERIOD {3.333} \
  CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {6.375} \
  CONFIG.MMCM_CLKOUT1_DIVIDE {3} \
  CONFIG.NUM_OUT_CLKS {2} \
  CONFIG.OPTIMIZE_CLOCKING_STRUCTURE_EN {true} \
  CONFIG.PRIM_IN_FREQ {300} \
  CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
  CONFIG.SECONDARY_SOURCE {Single_ended_clock_capable_pin} \
  CONFIG.USE_PHASE_ALIGNMENT {true} \
] [get_ips clk_wiz_0]

set_property -dict [list \
  CONFIG.CLKOUT1_DRIVES {Buffer} \
  CONFIG.CLKOUT1_JITTER {120.537} \
  CONFIG.CLKOUT1_PHASE_ERROR {109.126} \
  CONFIG.CLKOUT2_DRIVES {Buffer} \
  CONFIG.CLKOUT2_JITTER {104.468} \
  CONFIG.CLKOUT2_PHASE_ERROR {109.126} \
  CONFIG.CLKOUT3_JITTER {158.034} \
  CONFIG.CLKOUT3_PHASE_ERROR {109.126} \
  CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {50} \
  CONFIG.CLKOUT3_USED {true} \
  CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
  CONFIG.MMCM_CLKFBOUT_MULT_F {8.500} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {4.250} \
  CONFIG.MMCM_CLKOUT1_DIVIDE {2} \
  CONFIG.MMCM_CLKOUT2_DIVIDE {17} \
  CONFIG.MMCM_DIVCLK_DIVIDE {3} \
  CONFIG.NUM_OUT_CLKS {3} \
] [get_ips clk_wiz_0]

generate_target {instantiation_template} [get_files ${_proj_path_}/${_proj_name_}.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci]

# Generate AXI I2C IP
create_ip -name axi_iic -vendor xilinx.com -library ip -version 2.1 -module_name axi_iic_0
set_property -dict [list CONFIG.AXI_ACLK_FREQ_MHZ {50}] [get_ips axi_iic_0]

# Generate JTAG AXI IP
create_ip -name jtag_axi -vendor xilinx.com -library ip -version 1.2 -module_name jtag_axi_0
set_property CONFIG.PROTOCOL {2} [get_ips jtag_axi_0]
generate_target {instantiation_template} [get_files ${_proj_path_}/${_proj_name_}.srcs/sources_1/ip/jtag_axi_0/jtag_axi_0.xci]

# Generate AXI Crossbar IP
create_ip -name axi_crossbar -vendor xilinx.com -library ip -version 2.1 -module_name AXI_CROSSBAR_GTFMAC
set_property -dict [list \
  CONFIG.ADDR_RANGES {2} \
  CONFIG.CONNECTIVITY_MODE {SASD} \
  CONFIG.M00_A00_ADDR_WIDTH {10} \
  CONFIG.M00_READ_ISSUING {1} \
  CONFIG.M00_WRITE_ISSUING {1} \
  CONFIG.M01_A00_ADDR_WIDTH {10} \
  CONFIG.M01_A00_BASE_ADDR {0x0000000000000400} \
  CONFIG.M01_A01_ADDR_WIDTH {11} \
  CONFIG.M01_A01_BASE_ADDR {0x0000000000000800} \
  CONFIG.M01_READ_ISSUING {1} \
  CONFIG.M01_WRITE_ISSUING {1} \
  CONFIG.M02_READ_ISSUING {1} \
  CONFIG.M02_WRITE_ISSUING {1} \
  CONFIG.M03_READ_ISSUING {1} \
  CONFIG.M03_WRITE_ISSUING {1} \
  CONFIG.M04_READ_ISSUING {1} \
  CONFIG.M04_WRITE_ISSUING {1} \
  CONFIG.M05_READ_ISSUING {1} \
  CONFIG.M05_WRITE_ISSUING {1} \
  CONFIG.M06_READ_ISSUING {1} \
  CONFIG.M06_WRITE_ISSUING {1} \
  CONFIG.M07_READ_ISSUING {1} \
  CONFIG.M07_WRITE_ISSUING {1} \
  CONFIG.M08_READ_ISSUING {1} \
  CONFIG.M08_WRITE_ISSUING {1} \
  CONFIG.M09_READ_ISSUING {1} \
  CONFIG.M09_WRITE_ISSUING {1} \
  CONFIG.M10_READ_ISSUING {1} \
  CONFIG.M10_WRITE_ISSUING {1} \
  CONFIG.M11_READ_ISSUING {1} \
  CONFIG.M11_WRITE_ISSUING {1} \
  CONFIG.M12_READ_ISSUING {1} \
  CONFIG.M12_WRITE_ISSUING {1} \
  CONFIG.M13_READ_ISSUING {1} \
  CONFIG.M13_WRITE_ISSUING {1} \
  CONFIG.M14_READ_ISSUING {1} \
  CONFIG.M14_WRITE_ISSUING {1} \
  CONFIG.M15_READ_ISSUING {1} \
  CONFIG.M15_WRITE_ISSUING {1} \
  CONFIG.PROTOCOL {AXI4LITE} \
  CONFIG.R_REGISTER {1} \
  CONFIG.S00_READ_ACCEPTANCE {1} \
  CONFIG.S00_SINGLE_THREAD {1} \
  CONFIG.S00_WRITE_ACCEPTANCE {1} \
  CONFIG.S01_READ_ACCEPTANCE {1} \
  CONFIG.S01_WRITE_ACCEPTANCE {1} \
  CONFIG.S02_READ_ACCEPTANCE {1} \
  CONFIG.S02_WRITE_ACCEPTANCE {1} \
  CONFIG.S03_READ_ACCEPTANCE {1} \
  CONFIG.S03_WRITE_ACCEPTANCE {1} \
  CONFIG.S04_READ_ACCEPTANCE {1} \
  CONFIG.S04_WRITE_ACCEPTANCE {1} \
  CONFIG.S05_READ_ACCEPTANCE {1} \
  CONFIG.S05_WRITE_ACCEPTANCE {1} \
  CONFIG.S06_READ_ACCEPTANCE {1} \
  CONFIG.S06_WRITE_ACCEPTANCE {1} \
  CONFIG.S07_READ_ACCEPTANCE {1} \
  CONFIG.S07_WRITE_ACCEPTANCE {1} \
  CONFIG.S08_READ_ACCEPTANCE {1} \
  CONFIG.S08_WRITE_ACCEPTANCE {1} \
  CONFIG.S09_READ_ACCEPTANCE {1} \
  CONFIG.S09_WRITE_ACCEPTANCE {1} \
  CONFIG.S10_READ_ACCEPTANCE {1} \
  CONFIG.S10_WRITE_ACCEPTANCE {1} \
  CONFIG.S11_READ_ACCEPTANCE {1} \
  CONFIG.S11_WRITE_ACCEPTANCE {1} \
  CONFIG.S12_READ_ACCEPTANCE {1} \
  CONFIG.S12_WRITE_ACCEPTANCE {1} \
  CONFIG.S13_READ_ACCEPTANCE {1} \
  CONFIG.S13_WRITE_ACCEPTANCE {1} \
  CONFIG.S14_READ_ACCEPTANCE {1} \
  CONFIG.S14_WRITE_ACCEPTANCE {1} \
  CONFIG.S15_READ_ACCEPTANCE {1} \
  CONFIG.S15_WRITE_ACCEPTANCE {1} \
] [get_ips AXI_CROSSBAR_GTFMAC]
generate_target {instantiation_template} [get_files ${_proj_path_}/${_proj_name_}.srcs/sources_1/ip/AXI_CROSSBAR_GTFMAC/AXI_CROSSBAR_GTFMAC.xci]

# Generate BRAM for TX Data pattern
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name blk_mem_gen_prbs
set_property -dict [list \
  CONFIG.Coe_File ${_origin_dir_}/RTL/prbs/bram.coe \
  CONFIG.Component_Name {blk_mem_gen_prbs} \
  CONFIG.Load_Init_File {true} \
  CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
  CONFIG.Write_Depth_A {1024} \
] [get_ips blk_mem_gen_prbs]
generate_target {instantiation_template} [get_files ${_proj_path_}/${_proj_name_}.srcs/sources_1/ip/blk_mem_gen_prbs/blk_mem_gen_prbs.xci]
update_compile_order -fileset sources_1

# Generate VIO IP
create_ip -name vio -vendor xilinx.com -library ip -version 3.0 -module_name vio_0
set_property -dict [list \
  CONFIG.C_NUM_PROBE_IN {18} \
  CONFIG.C_NUM_PROBE_OUT {14} \
  CONFIG.C_PROBE_IN16_WIDTH {3} \
  CONFIG.C_PROBE_OUT1_INIT_VAL {0x1} \
] [get_ips vio_0]
generate_target {instantiation_template} [get_files ${_proj_path_}/${_proj_name_}.srcs/sources_1/ip/vio_0/vio_0.xci]

# Generate top level VIO (temporary)
create_ip -name vio -vendor xilinx.com -library ip -version 3.0 -module_name vio_1
set_property CONFIG.C_NUM_PROBE_IN {10} [get_ips vio_1]
set_property CONFIG.C_NUM_PROBE_OUT {1} [get_ips vio_1]
generate_target {instantiation_template} [get_files ${_proj_path_}/${_proj_name_}.srcs/sources_1/ip/vio_1/vio_1.xci]

# Generate ILA of TX/RX Timing
create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_0
set_property -dict [list \
  CONFIG.C_DATA_DEPTH {16384} \
  CONFIG.C_NUM_OF_PROBES {13} \
  CONFIG.C_PROBE0_WIDTH  {16} \
  CONFIG.C_PROBE1_WIDTH  {16} \
  CONFIG.C_PROBE2_WIDTH  {16} \
  CONFIG.C_PROBE5_WIDTH  {32} \
  CONFIG.C_PROBE8_WIDTH  {16} \
  CONFIG.C_PROBE11_WIDTH {16} \
  CONFIG.C_PROBE12_WIDTH {2}  \
  CONFIG.C_INPUT_PIPE_STAGES {2} \
] [get_ips ila_0]
generate_target {instantiation_template} [get_files ${_proj_path_}/${_proj_name_}.srcs/sources_1/ip/ila_0/ila_0.xci]

#update_compile_order -fileset sources_1
#create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name blk_mem_gen_0
#set_property -dict [list \
#  CONFIG.Coe_File ${_origin_dir_}/RTL/prbs/bram.coe \
#  CONFIG.Load_Init_File {true} \
#  CONFIG.Write_Depth_A {1024} \
#] [get_ips blk_mem_gen_0]
#generate_target {instantiation_template} [get_files ${_origin_dir_}/Vivado_Project/${_proj_name_}/${_proj_name_}.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0.xci]

# CHANGE DESIGN NAME HERE
variable design_name
set design_name axil_ctrl

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1

##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################

# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set M00_AXI_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI_0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI4LITE} \
   ] $M00_AXI_0

  set M01_AXI_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M01_AXI_0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI4LITE} \
   ] $M01_AXI_0

  set M02_AXI_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M02_AXI_0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.PROTOCOL {AXI4LITE} \
   ] $M02_AXI_0

  set S00_AXI_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI_0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.MAX_BURST_LENGTH {1} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $S00_AXI_0


  # Create ports
  set ACLK_0 [ create_bd_port -dir I -type clk -freq_hz 125000000 ACLK_0 ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI_0:M01_AXI_0:S00_AXI_0:M02_AXI_0} \
   CONFIG.ASSOCIATED_RESET {ARESETN_0} \
 ] $ACLK_0
  set ARESETN_0 [ create_bd_port -dir I -type rst ARESETN_0 ]

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property CONFIG.NUM_MI {3} $axi_interconnect_0


  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_0_1 [get_bd_intf_ports S00_AXI_0] [get_bd_intf_pins axi_interconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_ports M00_AXI_0] [get_bd_intf_pins axi_interconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_ports M01_AXI_0] [get_bd_intf_pins axi_interconnect_0/M01_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M02_AXI [get_bd_intf_ports M02_AXI_0] [get_bd_intf_pins axi_interconnect_0/M02_AXI]

  # Create port connections
  connect_bd_net -net ACLK_0_1 [get_bd_ports ACLK_0] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins axi_interconnect_0/M02_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK]
  connect_bd_net -net ARESETN_0_1 [get_bd_ports ARESETN_0] [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins axi_interconnect_0/M02_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x00008000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs M00_AXI_0/Reg] -force
  assign_bd_address -offset 0x00010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs M01_AXI_0/Reg] -force
  assign_bd_address -offset 0x00008000 -range 0x00008000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs M02_AXI_0/Reg] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()

##################################################################
# MAIN FLOW
##################################################################

create_root_design ""

set_property top gtfwizard_0_example_top_sim [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

set_property top gtfmac_vnc_top [current_fileset]

# Update to set top and file compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts {Setup complete...}
