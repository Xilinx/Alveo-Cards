#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

################################################################################
#
#  LVDS Input Clock References...
#
################################################################################
          
#
#  300 Mhz Reference clock for QDRII+ 0, Bank 73 (1.5V)
#                                                                                        
#create_clock -period 3.333 -name CLK_CLK10_LVDS_300_P   [get_ports CLK10_LVDS_300_P]

#                                                                                        
#  300 Mhz Reference clock for QDRII+ 1, Bank 71 (1.5V)                                  
#                                                                                        
#create_clock -period 3.333 -name CLK_CLK11_LVDS_300_P   [get_ports CLK11_LVDS_300_P]
                                                                                         
#                                                                                        
#  300 Mhz Reference clock for DDR1, Bank 66 (1.2V)                                      
#                                                                                        
create_clock -period 3.333 -name CLK_CLK12_LVDS_300_P   [get_ports CLK12_LVDS_300_P]

#                                                                                        
#  300 Mhz Reference clock, Bank 65 (1.8V)                                               
#                                                                                        
create_clock -period 3.333 -name CLK_CLK13_LVDS_300_P   [get_ports CLK13_LVDS_300_P]


#################################################################################
#
# GTF SYNCE INPUT CLOCK PORTS - 161.1343861 Mhz
#
#################################################################################
#
#  Constrain each clock to default 10G frequency of 161.1Mhz
#
#create_clock -period 6.207 -name CLK_SYNCE_CLK10_LVDS_P [get_ports SYNCE_CLK10_LVDS_P]
create_clock -period 6.207 -name CLK_SYNCE_CLK11_LVDS_P [get_ports SYNCE_CLK11_LVDS_P]
#create_clock -period 6.207 -name CLK_SYNCE_CLK12_LVDS_P [get_ports SYNCE_CLK12_LVDS_P]
#create_clock -period 6.207 -name CLK_SYNCE_CLK13_LVDS_P [get_ports SYNCE_CLK13_LVDS_P]
#create_clock -period 6.207 -name CLK_SYNCE_CLK14_LVDS_P [get_ports SYNCE_CLK14_LVDS_P]
#create_clock -period 6.207 -name CLK_SYNCE_CLK15_LVDS_P [get_ports SYNCE_CLK15_LVDS_P]
#create_clock -period 6.207 -name CLK_SYNCE_CLK16_LVDS_P [get_ports SYNCE_CLK16_LVDS_P]
#create_clock -period 6.207 -name CLK_SYNCE_CLK17_LVDS_P [get_ports SYNCE_CLK17_LVDS_P]

