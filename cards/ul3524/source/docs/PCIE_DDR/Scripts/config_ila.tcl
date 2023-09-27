#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

set_property PROBES.FILE      {<path to sherman.ltx>} [get_hw_devices xcvu2p_0]
set_property FULL_PROBES.FILE {<path to sherman.ltx>} [get_hw_devices xcvu2p_0]
refresh_hw_device [lindex [get_hw_devices xcvu2p_0] 0]

set_property TRIGGER_COMPARE_VALUE eq1'b1 [get_hw_probes design_1_wrapper/design_1_i/system_ila_0/inst/net_slot_0_axi_awvalid -of_objects [get_hw_ilas -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"design_1_wrapper/design_1_i/system_ila_0/inst/ila_lib"}]]
set_property TRIGGER_COMPARE_VALUE eq1'b1 [get_hw_probes design_1_wrapper/design_1_i/system_ila_0/inst/net_slot_0_axi_arvalid -of_objects [get_hw_ilas -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"design_1_wrapper/design_1_i/system_ila_0/inst/ila_lib"}]]
set_property CONTROL.TRIGGER_CONDITION OR [get_hw_ilas -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"design_1_wrapper/design_1_i/system_ila_0/inst/ila_lib"}]
set_property CONTROL.TRIGGER_POSITION 100 [get_hw_ilas -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"design_1_wrapper/design_1_i/system_ila_0/inst/ila_lib"}]

set_property TRIGGER_COMPARE_VALUE eq1'b1 [get_hw_probes design_1_wrapper/design_1_i/system_ila_1/inst/net_slot_0_axi_arvalid -of_objects [get_hw_ilas -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"design_1_wrapper/design_1_i/system_ila_1/inst/ila_lib"}]]
set_property TRIGGER_COMPARE_VALUE eq1'b1 [get_hw_probes design_1_wrapper/design_1_i/system_ila_1/inst/net_slot_0_axi_awvalid -of_objects [get_hw_ilas -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"design_1_wrapper/design_1_i/system_ila_1/inst/ila_lib"}]]
set_property CONTROL.TRIGGER_CONDITION OR [get_hw_ilas -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"design_1_wrapper/design_1_i/system_ila_1/inst/ila_lib"}]
set_property CONTROL.TRIGGER_POSITION 100 [get_hw_ilas -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"design_1_wrapper/design_1_i/system_ila_1/inst/ila_lib"}]

set_property TRIGGER_COMPARE_VALUE eq1'bR [get_hw_probes ddr_i2c_top/s_axi_aresetn -of_objects [get_hw_ilas -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"ddr_i2c_top/ila_0"}]]
set_property CONTROL.TRIGGER_POSITION 1000 [get_hw_ilas -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"ddr_i2c_top/ila_0"}]

set_property TRIGGER_COMPARE_VALUE eq1'b1 [get_hw_probes design_1_wrapper/design_1_i/system_ila_2/inst/net_slot_0_axi_arvalid -of_objects [get_hw_ilas -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"design_1_wrapper/design_1_i/system_ila_2/inst/ila_lib"}]]
set_property TRIGGER_COMPARE_VALUE eq1'b1 [get_hw_probes design_1_wrapper/design_1_i/system_ila_2/inst/net_slot_0_axi_awvalid -of_objects [get_hw_ilas -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"design_1_wrapper/design_1_i/system_ila_2/inst/ila_lib"}]]
set_property CONTROL.TRIGGER_CONDITION OR [get_hw_ilas -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"design_1_wrapper/design_1_i/system_ila_2/inst/ila_lib"}]
set_property CONTROL.TRIGGER_POSITION 100 [get_hw_ilas -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"design_1_wrapper/design_1_i/system_ila_2/inst/ila_lib"}]