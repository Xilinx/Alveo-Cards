#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

proc post_config_ip { cell args } {
}

# proc init {cellpath otherInfo } {
# 	set cell_handle [get_bd_cells $cellpath]
# 	set paramList "ID_WIDTH"

# 	bd::mark_propagate_only $cell_handle $paramList
# }


proc propagate {cellpath otherInfo } {
    set busif [get_bd_intf_pins $cellpath/s_axi]
    set id_wid [expr [get_property CONFIG.ID_WIDTH $busif]]
    set_property CONFIG.ID_WIDTH $id_wid [get_bd_cells $cellpath]
}



