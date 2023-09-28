#*****************************************************************************************
#  xdc file for FINN_Latency Reference Design
#*****************************************************************************************

#*****************************************************************************************
#  Timing Constraints
#*****************************************************************************************

create_clock -period 3.000 -name clk -waveform {0.000 1.500} [get_ports clk]


#*****************************************************************************************
#  Pin and Port Constraints
#*****************************************************************************************

set_property IOSTANDARD LVCMOS18 [get_ports {m_axis_0_tdata_r1[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {m_axis_0_tdata_r1[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {m_axis_0_tdata_r1[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {m_axis_0_tdata_r1[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {m_axis_0_tdata_r1[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {m_axis_0_tdata_r1[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {m_axis_0_tdata_r1[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {m_axis_0_tdata_r1[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports m_axis_0_tvalid_r1]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports clk]

set_property PACKAGE_PIN F15 [get_ports {m_axis_0_tdata_r1[7]}]
set_property PACKAGE_PIN G16 [get_ports {m_axis_0_tdata_r1[6]}]
set_property PACKAGE_PIN F14 [get_ports {m_axis_0_tdata_r1[5]}]
set_property PACKAGE_PIN G15 [get_ports {m_axis_0_tdata_r1[4]}]
set_property PACKAGE_PIN F13 [get_ports {m_axis_0_tdata_r1[3]}]
set_property PACKAGE_PIN G14 [get_ports {m_axis_0_tdata_r1[2]}]
set_property PACKAGE_PIN F11 [get_ports {m_axis_0_tdata_r1[1]}]
set_property PACKAGE_PIN F12 [get_ports {m_axis_0_tdata_r1[0]}]
set_property PACKAGE_PIN J16 [get_ports m_axis_0_tvalid_r1]
set_property PACKAGE_PIN AW19 [get_ports clk]
set_property PACKAGE_PIN AW18 [get_ports clkn]
