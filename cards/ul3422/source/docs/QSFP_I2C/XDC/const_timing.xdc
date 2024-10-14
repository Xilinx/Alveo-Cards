# 
# Copyright (C) 2024, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: X11
# 
#
############################################################################
#
#
#   UL3422 - Master XDC
#
#
############################################################################
#	REVISION HISTORY
############################################################################
#
#   Revision: 0.01 (internal)   (08/22/2023)
#		* Two additional reference clock mapped on Bank 65
#       * Two SYNCE clock added on GT Banks 129 & 226
#       * Extra sideband signals on ARF interface are removed
#       * DDR placement not optimized 
#   Revision: 0.00 (internal)   (06/27/2023)
#		* Initial Version from UL3422 Feasibility Study. Released on 27Jun2023
#
#
# This XDC contains the necessary pinout, clock, and configuration information to get started on a design.
# Please see UG1585 for more information on board components including part numbers, I2C bus details, clock and power trees.
#
##################################################################################################################################################################

################################################################################
#
#  LVDS Input Clock References...
#
################################################################################

#                                                                                        
#  300 Mhz Reference clock for DDR1, Bank 66 (1.2V)                                      
#                                                                                        
create_clock -period 3.333 -name clk_ddr_lvds_300_p   [get_ports clk_ddr_lvds_300_p]
