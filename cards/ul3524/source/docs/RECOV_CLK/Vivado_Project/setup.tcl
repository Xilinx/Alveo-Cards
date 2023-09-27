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

# -- Design Files
add_files -fileset sources_1 ${_origin_dir_}/RTL/sync/syncer_level.sv
add_files -fileset sources_1 ${_origin_dir_}/RTL/sync/syncer_pulse.sv
add_files -fileset sources_1 ${_origin_dir_}/RTL/sync/syncer_bus.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/sync/syncer_reset.sv

add_files -fileset sources_1 ${_origin_dir_}/RTL/freq_counter/freq_counter_regs.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/freq_counter/freq_counter.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/freq_counter/freq_counter_top.v

add_files -fileset sources_1 ${_origin_dir_}/RTL/renesas_gpio/renesas_gpio_regs.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/renesas_gpio/renesas_gpio.v

add_files -fileset sources_1 ${_origin_dir_}/RTL/renesas_i2c/renesas_bram.v 
add_files -fileset sources_1 ${_origin_dir_}/RTL/renesas_i2c/renesas_i2c_regs.v 
add_files -fileset sources_1 ${_origin_dir_}/RTL/renesas_i2c/renesas_i2c_sequencer.sv 
add_files -fileset sources_1 ${_origin_dir_}/RTL/renesas_i2c/renesas_i2c_axi_master.v 
add_files -fileset sources_1 ${_origin_dir_}/RTL/renesas_i2c/renesas_i2c_top.v

add_files -fileset sources_1 ${_origin_dir_}/RTL/qsfp_i2c/RTL/state_machine/state_machine_pwr.v 
add_files -fileset sources_1 ${_origin_dir_}/RTL/qsfp_i2c/RTL/state_machine/state_machine_top.v 
add_files -fileset sources_1 ${_origin_dir_}/RTL/qsfp_i2c/RTL/state_machine/state_machine_sb.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/qsfp_i2c/RTL/qsfp_axi_master.v 
add_files -fileset sources_1 ${_origin_dir_}/RTL/qsfp_i2c/RTL/qsfp_i2c_axi_sequencer.v 
add_files -fileset sources_1 ${_origin_dir_}/RTL/qsfp_i2c/RTL/qsfp_i2c_regs.v 
add_files -fileset sources_1 ${_origin_dir_}/RTL/qsfp_i2c/RTL/qsfp_i2c_top.v 

add_files -fileset sources_1 ${_origin_dir_}/RTL/system/system_regs.v	
add_files -fileset sources_1 ${_origin_dir_}/RTL/system/system_gtf_clk_buffer.v	
add_files -fileset sources_1 ${_origin_dir_}/RTL/system/sys_if_switch.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/system/reg_axi_slave.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/system/clk_reset.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/clk_recov.v

add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_mac_ex/imports/gtfwizard_mac_example_gtfmac_hwchk_bitslip.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_mac_ex/imports/gtfwizard_mac_example_init.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_mac_ex/imports/gtfwizard_mac_fab_wrap.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_mac_ex/imports/gtfwizard_mac_gtf_common.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_mac_ex/imports/gtfwizard_mac_gtfmac_ex.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_mac_ex/imports/gtfwizard_mac_gtfmac_hwchk_core.sv
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_mac_ex/imports/ila_mac_fifo.v

add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_mac_ex/gtfwizard_mac/gtfwizard_mac_delay_powergood.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_mac_ex/gtfwizard_mac/gtfwizard_mac_gtf_channel.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_mac_ex/gtfwizard_mac/gtfwizard_mac_gtf_ch_drp_align_switch.sv
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_mac_ex/gtfwizard_mac/gtfwizard_mac_gtfmac_wrapper_axi_custom_crossbar.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_mac_ex/gtfwizard_mac/gtfwizard_mac_gtfmac_wrapper_axi_if_soft_top.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_mac_ex/gtfwizard_mac/gtfwizard_mac_gtfmac_wrapper_axi_slave_2_ipif.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_mac_ex/gtfwizard_mac/gtfwizard_mac_gtfmac_wrapper_drp_bridge.sv
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_mac_ex/gtfwizard_mac/gtfwizard_mac_gtfmac_wrapper_pif_soft_registers.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_mac_ex/gtfwizard_mac/gtfwizard_mac_gtfmac_wrapper_stats_gasket.sv
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_mac_ex/gtfwizard_mac/gtfwizard_mac_gtwiz_buffbypass_rx.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_mac_ex/gtfwizard_mac/gtfwizard_mac_gtwiz_buffbypass_tx.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_mac_ex/gtfwizard_mac/gtfwizard_mac_reset.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_mac_ex/gtfwizard_mac/gtfwizard_mac_rules_output.vh
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_mac_ex/gtfwizard_mac/gtfwizard_mac_top.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_mac_ex/gtfwizard_mac/gtfwizard_mac.v

add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_raw_ex/imports/gtfwizard_raw_example_init.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_raw_ex/imports/gtfwizard_raw_example_top.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_raw_ex/imports/gtfwizard_raw_gtf_common.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtfwizard_raw_ex/imports/gtfwizard_raw_rules_output.vh

#add_files -fileset sources_1 ${_origin_dir_}/RTL/gtf/gtf_top.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtf/gtf_top_0.v
add_files -fileset sources_1 ${_origin_dir_}/RTL/gtf/gtf_top_1.v

# These need to be imported vs added so as to keep all associated files in the project build folder...
import_files -norecurse ${_origin_dir_}/RTL/gtfwizard_raw_ex/ip/gtfwizard_raw/gtfwizard_raw.xci
import_files -norecurse ${_origin_dir_}/RTL/gtfwizard_mac_ex/ip/gtfwizard_mac_axi_crossbar_inst/gtfwizard_mac_axi_crossbar_inst.xci
source ${_origin_dir_}/RTL/gtfwizard_mac_ex/ip/gtfwizard_mac_example_axil_ctrl.tcl

update_compile_order -fileset sources_1

# -- Simulation Files

add_files -fileset sim_1 ${_origin_dir_}/sim/RTL/qsfp_i2c/pca9545a.v 
add_files -fileset sim_1 ${_origin_dir_}/sim/RTL/qsfp_i2c/tca6406a.v 
add_files -fileset sim_1 ${_origin_dir_}/sim/RTL/qsfp_i2c/qsfp_i2c.vh 

add_files -fileset sim_1 ${_origin_dir_}/sim/RTL/renesas_i2c/RC38612A002GN2.v 
add_files -fileset sim_1 ${_origin_dir_}/sim/RTL/renesas_i2c/renesas_i2c.vh 

add_files -fileset sim_1 ${_origin_dir_}/sim/RTL/system/sim_i2c_slave_if.v	
add_files -fileset sim_1 ${_origin_dir_}/sim/RTL/system/sim_axi_master_tasks.vh
add_files -fileset sim_1 ${_origin_dir_}/sim/RTL/system/sim_tb_addr.v	
add_files -fileset sim_1 ${_origin_dir_}/sim/RTL/system/sim_axi_master.v
add_files -fileset sim_1 ${_origin_dir_}/sim/RTL/system/sim_axi_monitor.v

add_files -fileset sim_1 ${_origin_dir_}/sim/RTL/sim_tb.v
add_files -fileset sim_1 ${_origin_dir_}/sim/RTL/qsfp_i2c/i2c_slave_if.v

add_files -fileset sim_1 -norecurse ${_origin_dir_}/sim/sim_tb_behav.wcfg
set_property xsim.view ${_origin_dir_}/sim/sim_tb_behav.wcfg [get_filesets sim_1]


set_property file_type SystemVerilog [get_files  ${_origin_dir_}/sim/RTL/sim_tb.v]

# -- Constraint Files
add_files -fileset constrs_1 -norecurse ${_origin_dir_}/XDC/constraint.xdc	


# Generate AXI Subsystem using block diagram tcl script that configures axi interconnects...
source ${_origin_dir_}/RTL/system/axi_subsys.tcl


# Generate JTAG to AXI Master IP
create_ip -name jtag_axi -vendor xilinx.com -library ip -version 1.2 -module_name jtag_axi_0
set_property CONFIG.PROTOCOL {2} [get_ips jtag_axi_0]


# Generate System Clock
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0
set_property -dict [list \
  CONFIG.CLKIN1_JITTER_PS {33.330000000000005} \
  CONFIG.CLKOUT1_JITTER {101.475} \
  CONFIG.CLKOUT1_PHASE_ERROR {77.836} \
  CONFIG.CLKOUT2_JITTER {116.415} \
  CONFIG.CLKOUT2_PHASE_ERROR {77.836} \
  CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {50} \
  CONFIG.CLKOUT2_USED {true} \
  CONFIG.MMCM_CLKFBOUT_MULT_F {4.000} \
  CONFIG.MMCM_CLKOUT1_DIVIDE {24} \
  CONFIG.MMCM_CLKIN1_PERIOD {3.333} \
  CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
  CONFIG.PRIM_IN_FREQ {300.000} \
  CONFIG.USE_RESET {false} \
  CONFIG.NUM_OUT_CLKS {2} \
] [get_ips clk_wiz_0]
set_property CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} [get_ips clk_wiz_0]

# 
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name gtfwizard_0_example_clk_wiz
set_property -dict [list \
  CONFIG.CLKIN1_JITTER_PS {33.330000000000005} \
  CONFIG.CLKOUT1_DRIVES {Buffer} \
  CONFIG.CLKOUT1_JITTER {87.024} \
  CONFIG.CLKOUT1_PHASE_ERROR {75.422} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {200.000} \
  CONFIG.CLKOUT2_DRIVES {Buffer} \
  CONFIG.CLKOUT2_JITTER {75.082} \
  CONFIG.CLKOUT2_PHASE_ERROR {75.422} \
  CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {425.000} \
  CONFIG.CLKOUT2_USED {true} \
  CONFIG.CLKOUT3_DRIVES {Buffer} \
  CONFIG.CLKOUT4_DRIVES {Buffer} \
  CONFIG.CLKOUT5_DRIVES {Buffer} \
  CONFIG.CLKOUT6_DRIVES {Buffer} \
  CONFIG.CLKOUT7_DRIVES {Buffer} \
  CONFIG.MMCM_CLKFBOUT_MULT_F {4.250} \
  CONFIG.MMCM_CLKIN1_PERIOD {3.333} \
  CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {6.375} \
  CONFIG.MMCM_CLKOUT1_DIVIDE {3} \
  CONFIG.NUM_OUT_CLKS {2} \
  CONFIG.PRIM_IN_FREQ {300.000} \
  CONFIG.PRIM_SOURCE {Global_buffer} \
  CONFIG.SECONDARY_SOURCE {Single_ended_clock_capable_pin} \
  CONFIG.USE_PHASE_ALIGNMENT {true} \
] [get_ips gtfwizard_0_example_clk_wiz]

# Dummy secondary 33 Mhz clock
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_1
set_property -dict [list \
  CONFIG.CLKOUT1_JITTER {252.007} \
  CONFIG.CLKOUT1_PHASE_ERROR {354.739} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {33.000} \
  CONFIG.MMCM_CLKFBOUT_MULT_F {119.625} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {36.250} \
  CONFIG.MMCM_DIVCLK_DIVIDE {10} \
  CONFIG.PRIM_SOURCE {No_buffer} \
  CONFIG.USE_RESET {true} \
] [get_ips clk_wiz_1]


# Generate Dual Port BRAM for Jitt I2C Controller
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name blk_mem_gen_0
set_property -dict [list \
  CONFIG.Enable_A {Always_Enabled} \
  CONFIG.Enable_B {Always_Enabled} \
  CONFIG.Memory_Type {True_Dual_Port_RAM} \
  CONFIG.Write_Depth_A {16384} \
  CONFIG.Write_Width_A {32} \
  CONFIG.Write_Width_B {16} \
] [get_ips blk_mem_gen_0]


## Generate ILA for JTAG/AXI I/F
#create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_axi
#set_property -dict [list \
#  CONFIG.C_DATA_DEPTH {2048} \
#  CONFIG.C_MONITOR_TYPE {Native} \
#  CONFIG.C_NUM_OF_PROBES {15} \
#  CONFIG.C_PROBE0_WIDTH {32} \
#  CONFIG.C_PROBE12_WIDTH {32} \
#  CONFIG.C_PROBE3_WIDTH {32} \
#  CONFIG.C_PROBE4_WIDTH {4} \
#  CONFIG.C_PROBE9_WIDTH {32} \
#  CONFIG.Component_Name {ila_axi} \
#] [get_ips ila_axi]
#
#
## Generate ILA for Jitt I2C Controller
#create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_i2c
#set_property -dict [list \
#  CONFIG.C_DATA_DEPTH {65536} \
#  CONFIG.C_INPUT_PIPE_STAGES {1} \
#  CONFIG.C_NUM_OF_PROBES {6} \
#  CONFIG.C_PROBE2_WIDTH {8} \
#  CONFIG.C_PROBE3_WIDTH {32} \
#  CONFIG.C_PROBE5_WIDTH {8} \
#  CONFIG.Component_Name {ila_i2c} \
#] [get_ips ila_i2c]
#
#
## Generate ILA for Jitt GPIO
#create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_gpio
#set_property -dict [list \
#  CONFIG.C_DATA_DEPTH {2048} \
#  CONFIG.C_INPUT_PIPE_STAGES {1} \
#  CONFIG.C_NUM_OF_PROBES {10} \
#  CONFIG.C_PROBE3_WIDTH {6} \
#  CONFIG.C_PROBE4_WIDTH {6} \
#  CONFIG.C_PROBE5_WIDTH {6} \
#  CONFIG.C_PROBE6_WIDTH {6} \
#  CONFIG.C_PROBE7_WIDTH {6} \
#  CONFIG.C_PROBE8_WIDTH {6} \
#  CONFIG.C_PROBE9_WIDTH {6} \
#  CONFIG.Component_Name {ila_gpio} \
#] [get_ips ila_gpio]
#
#
## Generate ILA for frequency monitor
#create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_freq
#set_property -dict [list \
#  CONFIG.ALL_PROBE_SAME_MU {false} \
#  CONFIG.C_DATA_DEPTH {2048} \
#  CONFIG.C_INPUT_PIPE_STAGES {1} \
#  CONFIG.C_NUM_OF_PROBES {4} \
#  CONFIG.C_PROBE1_WIDTH {32} \
#  CONFIG.C_PROBE2_WIDTH {32} \
#  CONFIG.Component_Name {ila_freq} \
#] [get_ips ila_freq]


create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_mac_fifo
set_property -dict [list \
  CONFIG.C_DATA_DEPTH {16384} \
  CONFIG.C_INPUT_PIPE_STAGES {2} \
  CONFIG.C_NUM_OF_PROBES {13} \
  CONFIG.C_PROBE11_TYPE {0} \
  CONFIG.C_PROBE11_WIDTH {3} \
  CONFIG.C_PROBE12_TYPE {1} \
  CONFIG.C_PROBE12_WIDTH {64} \
  CONFIG.C_PROBE2_WIDTH {32} \
  CONFIG.C_PROBE7_WIDTH {3} \
  CONFIG.C_PROBE8_TYPE {1} \
  CONFIG.C_PROBE8_WIDTH {64} \
  CONFIG.Component_Name {ila_mac_fifo} \
] [get_ips ila_mac_fifo]


# Generate I2C Controller for Jitt
create_ip -name axi_iic -vendor xilinx.com -library ip -version 2.1 -module_name axi_iic_0
set_property -dict [list \
  CONFIG.AXI_ACLK_FREQ_MHZ {50} \
] [get_ips axi_iic_0]


# Generate I2C Controller for QSFP
create_ip -name axi_iic -vendor xilinx.com -library ip -version 2.1 -module_name axi_iic_qsfp
set_property -dict [list \
  CONFIG.AXI_ACLK_FREQ_MHZ {100} \
] [get_ips axi_iic_qsfp]

# FIFO used in RAW GTF Port to loopback data from RX to TX clock domains
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name fifo_raw_loopback
set_property -dict [list \
  CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} \
  CONFIG.Input_Data_Width {90} \
  CONFIG.Input_Depth {256} \
  CONFIG.Overflow_Flag {true} \
  CONFIG.Underflow_Flag {true} \
  CONFIG.Use_Embedded_Registers {false} \
  CONFIG.Valid_Flag {true} \
  CONFIG.Write_Acknowledge_Flag {true} \
] [get_ips fifo_raw_loopback]

update_compile_order -fileset sources_1
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name fifo_mac_data_sync
set_property -dict [list \
  CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} \
  CONFIG.Input_Data_Width {70} \
  CONFIG.Input_Depth {4096} \
  CONFIG.Use_Embedded_Registers {false} \
] [get_ips fifo_mac_data_sync]


# # Generate Simple AXI-BRAM Instance 
# create_ip -name axi_bram_ctrl -vendor xilinx.com -library ip -version 4.1 -module_name axi_bram_ctrl_0
# set_property -dict [list \
#   CONFIG.BMG_INSTANCE {INTERNAL} \
#   CONFIG.PROTOCOL {AXI4LITE} \
# ] [get_ips axi_bram_ctrl_0]


# Set top Module...
set_property top clk_recov [current_fileset]
set_property top sim_tb    [get_filesets sim_1]

# Update compile order...
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Change placer directive for better timing closure.
#set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE ExtraNetDelay_high [get_runs impl_1]
set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE ExtraNetDelay_low [get_runs impl_1]

puts {Setup complete...}
