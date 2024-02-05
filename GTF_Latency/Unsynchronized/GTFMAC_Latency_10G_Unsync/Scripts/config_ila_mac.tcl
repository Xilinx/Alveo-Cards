#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

# Configure lat_ila
set_property TRIGGER_COMPARE_VALUE eq1'b1 [get_hw_probes lat_mon_rcv_event_ila -of_objects [get_hw_ilas -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"gtfmac_ila_inst0"}]]
set_property CONTROL.TRIGGER_POSITION 4087 [get_hw_ilas -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"gtfmac_ila_inst0"}]
