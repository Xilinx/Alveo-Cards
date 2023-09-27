#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

load librdi_iptasks[info sharedlibextension]

package require xilinx::board 1.0
namespace import ::xilinx::board::*

variable tcl_scope
variable tcl_IPINST

set tcl_scope xgui
set tcl_IPINST [ ::ipgui::current_inst ]

source_subcore_ipfile xilinx.com:ip:mem:1.4 utility/utility.tcl
set memType "QDRIIP"

set assignmentAffectedList {}
   
        tcl::lappend assignmentAffectedList PARAM_VALUE.C0.QDRIIP_MemoryPart
        tcl::lappend assignmentAffectedList PARAM_VALUE.C0.QDRIIP_DataWidth
		tcl::lappend assignmentAffectedList PARAM_VALUE.C0.ControllerType

set modelparamDependantList {}

   

        tcl::lappend modelparamDependantList PARAM_VALUE.C0.QDRIIP_MemoryPart
        tcl::lappend modelparamDependantList PARAM_VALUE.C0.QDRIIP_DataWidth
		tcl::lappend modelparamDependantList PARAM_VALUE.C0.QDRIIP_CustomParts
		tcl::lappend modelparamDependantList PARAM_VALUE.C0.ControllerType

set cust_params {}

    
        tcl::lappend cust_params PARAM_VALUE.C0.QDRIIP_TimePeriod
        tcl::lappend cust_params PARAM_VALUE.C0.QDRIIP_InputClockPeriod
		    tcl::lappend cust_params PARAM_VALUE.C0.QDRIIP_Specify_MandD
		    tcl::lappend cust_params PARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT
		    tcl::lappend cust_params PARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE
		    tcl::lappend cust_params PARAM_VALUE.C0.QDRIIP_CLKOUT0_DIVIDE
        tcl::lappend cust_params PARAM_VALUE.C0.QDRIIP_CustomParts
        tcl::lappend cust_params PARAM_VALUE.C0.QDRIIP_MemoryType
        tcl::lappend cust_params PARAM_VALUE.C0.QDRIIP_MemoryPart
        tcl::lappend cust_params PARAM_VALUE.C0.QDRIIP_DataWidth
        tcl::lappend cust_params PARAM_VALUE.C0.ControllerType
        tcl::lappend cust_params PARAM_VALUE.System_Clock
        tcl::lappend cust_params PARAM_VALUE.IS_FROM_PHY
        tcl::lappend cust_params PARAM_VALUE.C0.QDRIIP_BurstLen
		tcl::lappend cust_params PARAM_VALUE.No_Controller
		tcl::lappend cust_params PARAM_VALUE.Default_Bank_Selections

array set required_params_qdrx {
ControllerType          { }
TimePeriod              { ControllerType }
MemoryType              { ControllerType TimePeriod CustomParts }
BurstLen                { ControllerType TimePeriod CustomParts }
MemoryPart              { ControllerType TimePeriod BurstLen CustomParts QDRII_GSI_EN }
DataWidth               { ControllerType TimePeriod BurstLen MemoryPart }
InputClockPeriod        { ControllerType TimePeriod }
}

## call common proc from helper core
[common_procs $memType $assignmentAffectedList $modelparamDependantList $cust_params [array get required_params_qdrx]]

proc update_loadPkg {PROJECT_PARAM.PART} {
###########################  loading the package  ####################################################
#set instname [ get_property name $IPINST ]
set ipName [ ::ipgui::current_inst ]
set datadir [ get_data_dir ]
set fpgapart [ get_project_property "PART" ]
set board [ get_project_property "BOARD" ]
set args1 [ list -part $fpgapart -datadir $datadir -ip $ipName -version 1.3 -controllertype "qdriiplus_sram" -board $board]
memory::memory_v1::Ip_memory_loadPkg {*}$args1
######################################################################################################
}


set params {}

set temp_params {}

    
        tcl::lappend temp_params PARAM_VALUE.C0.QDRIIP_TimePeriod
        tcl::lappend temp_params PARAM_VALUE.C0.QDRIIP_InputClockPeriod
        tcl::lappend temp_params PARAM_VALUE.C0.QDRIIP_Specify_MandD
	    	tcl::lappend temp_params PARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT
	    	tcl::lappend temp_params PARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE
	    	tcl::lappend temp_params PARAM_VALUE.C0.QDRIIP_CLKOUT0_DIVIDE
        tcl::lappend temp_params PARAM_VALUE.C0.QDRIIP_CustomParts
        tcl::lappend temp_params PARAM_VALUE.C0.QDRIIP_MemoryType
        tcl::lappend temp_params PARAM_VALUE.C0.QDRIIP_MemoryPart
        tcl::lappend temp_params PARAM_VALUE.C0.QDRIIP_DataWidth
        tcl::lappend temp_params PARAM_VALUE.C0.ControllerType
        tcl::lappend temp_params PARAM_VALUE.C0.QDRIIP_BurstLen




proc uninit { IPINST } {
    set ipName [ ::ipgui::current_inst ]
    set instname [ get_property name $IPINST ]
    set datadir [ get_data_dir ]
    #set fpgapart [ get_project_property "PART" ]

    set args1 [ list -datadir $datadir -ip $ipName -version 1.3]
    #send_msg INFO 1233 "its unloading for $ipName"
    memory::memory_v1::Ip_memory_unLoadPkg {*}$args1

}

array set pwr_est_variable_map {
MODELPARAM_VALUE.CAL_INPUT_CLK_PERIOD			  {Power_MMCM_CLK}
PARAM_VALUE.Debug_Signal						  {Power_Debug_Signal}
MODELPARAM_VALUE.C0.QDRIIP_nCK_PER_CLK			  {Power_nCK_PER_CLK}
MODELPARAM_VALUE.C0.QDRIIP_NUM_DEVICES            {Power_NUM_DEVICES}
PARAM_VALUE.C0.QDRIIP_MCS_ECC                     {Power_MCS_ECC}
PARAM_VALUE.C0.QDRIIP_DataWidth			          {Power_DQ_WIDTH}
PARAM_VALUE.C0.QDRIIP_MemoryPart                  {Power_MemoryPart}
PARAM_VALUE.Phy_Only                              {Power_Phy_Only}
PARAM_VALUE.C0.QDRIIP_TimePeriod                  {Power_TimePeriod}
MODELPARAM_VALUE.C0.APP_ADDR_WIDTH                {Power_APP_ADDR_WIDTH}
MODELPARAM_VALUE.C0.ControllerType                {Power_ControllerType}
MODELPARAM_VALUE.C0.QDRIIP_ADDR_WIDTH             {Power_ADDR_WIDTH}
MODELPARAM_VALUE.C0.QDRIIP_BANK_WIDTH             {Power_BANK_WIDTH}
MODELPARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT          {Power_CLKFBOUT_MULT}
MODELPARAM_VALUE.C0.QDRIIP_CLKIN_PERIOD           {Power_CLKIN_PERIOD}
MODELPARAM_VALUE.C0.QDRIIP_CLKOUTPHY_MODE         {Power_CLKOUTPHY_MODE}
MODELPARAM_VALUE.C0.QDRIIP_COMP_DENSITY           {Power_COMP_DENSITY}
MODELPARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE          {Power_DIVCLK_DIVIDE}
MODELPARAM_VALUE.C0.QDRIIP_MEMORY_TYPE            {Power_MEMORY_TYPE}
MODELPARAM_VALUE.C0.QDRIIP_MEM_COMP_WIDTH         {Power_MEM_COMP_WIDTH}
MODELPARAM_VALUE.C0.QDRIIP_MEM_DENSITY            {Power_MEM_DENSITY}
MODELPARAM_VALUE.C0.QDRIIP_MEM_DENSITY_GB         {Power_MEM_DENSITY_GB}
MODELPARAM_VALUE.C0.QDRIIP_MEM_DEVICE_WIDTH       {Power_MEM_DEVICE_WIDTH}
MODELPARAM_VALUE.C0.MEM_TYPE                    {Power_MEM_TYPE}
PARAM_VALUE.C0.QDRIIP_CLKOUT0_DIVIDE              {Power_CLKOUT0_DIVIDE}
MODELPARAM_VALUE.CLKOUT1_DIVIDE                 {Power_CLKOUT1_DIVIDE}
MODELPARAM_VALUE.CLKOUT2_DIVIDE                 {Power_CLKOUT2_DIVIDE}
MODELPARAM_VALUE.CLKOUT3_DIVIDE                 {Power_CLKOUT3_DIVIDE}
MODELPARAM_VALUE.CLKOUT4_DIVIDE                 {Power_CLKOUT4_DIVIDE}
PROJECT_PARAM.ARCHITECTURE                      {Power_ARCHITECTURE}
PROJECT_PARAM.DEVICE                            {Power_DEVICE}
PROJECT_PARAM.PACKAGE                           {Power_PACKAGE}
PROJECT_PARAM.SPEEDGRADE                        {Power_SPEEDGRADE}
PROJECT_PARAM.TEMPERATURE_GRADE                 {Power_TEMPERATURE_GRADE}
PROJECT_PARAM.PART                              {Power_PART}
}
proc estimate_power {
MODELPARAM_VALUE.CAL_INPUT_CLK_PERIOD
PARAM_VALUE.Debug_Signal
MODELPARAM_VALUE.C0.QDRIIP_nCK_PER_CLK
MODELPARAM_VALUE.C0.QDRIIP_NUM_DEVICES
PARAM_VALUE.C0.QDRIIP_MCS_ECC
PARAM_VALUE.C0.QDRIIP_DataWidth
PARAM_VALUE.C0.QDRIIP_MemoryPart
PARAM_VALUE.Phy_Only
PARAM_VALUE.C0.QDRIIP_TimePeriod
MODELPARAM_VALUE.C0.APP_ADDR_WIDTH
MODELPARAM_VALUE.C0.ControllerType
MODELPARAM_VALUE.C0.QDRIIP_ADDR_WIDTH
MODELPARAM_VALUE.C0.QDRIIP_BANK_WIDTH
MODELPARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT
MODELPARAM_VALUE.C0.QDRIIP_CLKIN_PERIOD
MODELPARAM_VALUE.C0.QDRIIP_CLKOUTPHY_MODE
MODELPARAM_VALUE.C0.QDRIIP_COMP_DENSITY
MODELPARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE
MODELPARAM_VALUE.C0.QDRIIP_MEMORY_TYPE
MODELPARAM_VALUE.C0.QDRIIP_MEM_COMP_WIDTH
MODELPARAM_VALUE.C0.QDRIIP_MEM_DENSITY
MODELPARAM_VALUE.C0.QDRIIP_MEM_DENSITY_GB
MODELPARAM_VALUE.C0.QDRIIP_MEM_DEVICE_WIDTH
MODELPARAM_VALUE.C0.MEM_TYPE
PARAM_VALUE.C0.QDRIIP_CLKOUT0_DIVIDE
MODELPARAM_VALUE.CLKOUT1_DIVIDE
MODELPARAM_VALUE.CLKOUT2_DIVIDE
MODELPARAM_VALUE.CLKOUT3_DIVIDE
MODELPARAM_VALUE.CLKOUT4_DIVIDE
PROJECT_PARAM.ARCHITECTURE
PROJECT_PARAM.DEVICE
PROJECT_PARAM.PACKAGE
PROJECT_PARAM.SPEEDGRADE
PROJECT_PARAM.TEMPERATURE_GRADE
PROJECT_PARAM.PART
} {
  variable pwr_est_variable_map
	set param_list {}
  send_msg INFO 110 "var--[array get pwr_est_variable_map]"
    lappend param_list $pwr_est_variable_map(MODELPARAM_VALUE.CAL_INPUT_CLK_PERIOD)
    lappend param_list [get_property value ${MODELPARAM_VALUE.CAL_INPUT_CLK_PERIOD}]
    lappend param_list $pwr_est_variable_map(PARAM_VALUE.Debug_Signal)
    lappend param_list [get_property value ${PARAM_VALUE.Debug_Signal}]
    lappend param_list $pwr_est_variable_map(MODELPARAM_VALUE.C0.QDRIIP_nCK_PER_CLK)
    lappend param_list [get_property value ${MODELPARAM_VALUE.C0.QDRIIP_nCK_PER_CLK}]
	lappend param_list $pwr_est_variable_map(MODELPARAM_VALUE.C0.QDRIIP_NUM_DEVICES)
	lappend param_list [get_property value ${MODELPARAM_VALUE.C0.QDRIIP_NUM_DEVICES}]
	lappend param_list $pwr_est_variable_map(PARAM_VALUE.C0.QDRIIP_MCS_ECC)
	lappend param_list [get_property value ${PARAM_VALUE.C0.QDRIIP_MCS_ECC}]
	lappend param_list $pwr_est_variable_map(PARAM_VALUE.C0.QDRIIP_DataWidth)
	lappend param_list [get_property value ${PARAM_VALUE.C0.QDRIIP_DataWidth}]
	lappend param_list $pwr_est_variable_map(PARAM_VALUE.C0.QDRIIP_MemoryPart)
	lappend param_list [get_property value ${PARAM_VALUE.C0.QDRIIP_MemoryPart}]
	lappend param_list $pwr_est_variable_map(PARAM_VALUE.Phy_Only)
	lappend param_list [get_property value ${PARAM_VALUE.Phy_Only}]
	lappend param_list $pwr_est_variable_map(PARAM_VALUE.C0.QDRIIP_TimePeriod)
	lappend param_list [get_property value ${PARAM_VALUE.C0.QDRIIP_TimePeriod}]
	lappend param_list $pwr_est_variable_map(MODELPARAM_VALUE.C0.APP_ADDR_WIDTH)
	lappend param_list [get_property value ${MODELPARAM_VALUE.C0.APP_ADDR_WIDTH}]
	lappend param_list $pwr_est_variable_map(MODELPARAM_VALUE.C0.ControllerType)
	lappend param_list [get_property value ${MODELPARAM_VALUE.C0.ControllerType}]
	lappend param_list $pwr_est_variable_map(MODELPARAM_VALUE.C0.QDRIIP_ADDR_WIDTH)
	lappend param_list [get_property value ${MODELPARAM_VALUE.C0.QDRIIP_ADDR_WIDTH}]
	lappend param_list $pwr_est_variable_map(MODELPARAM_VALUE.C0.QDRIIP_BANK_WIDTH)
	lappend param_list [get_property value ${MODELPARAM_VALUE.C0.QDRIIP_BANK_WIDTH}]
	lappend param_list $pwr_est_variable_map(MODELPARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT)
	lappend param_list [get_property value ${MODELPARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT}]
	lappend param_list $pwr_est_variable_map(MODELPARAM_VALUE.C0.QDRIIP_CLKIN_PERIOD)
	lappend param_list [get_property value ${MODELPARAM_VALUE.C0.QDRIIP_CLKIN_PERIOD}]
	lappend param_list $pwr_est_variable_map(MODELPARAM_VALUE.C0.QDRIIP_CLKOUTPHY_MODE)
	lappend param_list [get_property value ${MODELPARAM_VALUE.C0.QDRIIP_CLKOUTPHY_MODE}]
	lappend param_list $pwr_est_variable_map(MODELPARAM_VALUE.C0.QDRIIP_COMP_DENSITY)
	lappend param_list [get_property value ${MODELPARAM_VALUE.C0.QDRIIP_COMP_DENSITY}]
	lappend param_list $pwr_est_variable_map(MODELPARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE)
	lappend param_list [get_property value ${MODELPARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE}]
	lappend param_list $pwr_est_variable_map(MODELPARAM_VALUE.C0.QDRIIP_MEMORY_TYPE)
	lappend param_list [get_property value ${MODELPARAM_VALUE.C0.QDRIIP_MEMORY_TYPE}]
	lappend param_list $pwr_est_variable_map(MODELPARAM_VALUE.C0.QDRIIP_MEM_COMP_WIDTH)
	lappend param_list [get_property value ${MODELPARAM_VALUE.C0.QDRIIP_MEM_COMP_WIDTH}]
	lappend param_list $pwr_est_variable_map(MODELPARAM_VALUE.C0.QDRIIP_MEM_DENSITY)
	lappend param_list [get_property value ${MODELPARAM_VALUE.C0.QDRIIP_MEM_DENSITY}]
	lappend param_list $pwr_est_variable_map(MODELPARAM_VALUE.C0.QDRIIP_MEM_DENSITY_GB)
	lappend param_list [get_property value ${MODELPARAM_VALUE.C0.QDRIIP_MEM_DENSITY_GB}]
	lappend param_list $pwr_est_variable_map(MODELPARAM_VALUE.C0.QDRIIP_MEM_DEVICE_WIDTH)
	lappend param_list [get_property value ${MODELPARAM_VALUE.C0.QDRIIP_MEM_DEVICE_WIDTH}]
	lappend param_list $pwr_est_variable_map(MODELPARAM_VALUE.C0.MEM_TYPE)
	lappend param_list [get_property value ${MODELPARAM_VALUE.C0.MEM_TYPE}]
	lappend param_list $pwr_est_variable_map(PARAM_VALUE.C0.QDRIIP_CLKOUT0_DIVIDE)
	lappend param_list [get_property value ${PARAM_VALUE.C0.QDRIIP_CLKOUT0_DIVIDE}]
	lappend param_list $pwr_est_variable_map(MODELPARAM_VALUE.CLKOUT1_DIVIDE)
	lappend param_list [get_property value ${MODELPARAM_VALUE.CLKOUT1_DIVIDE}]
	lappend param_list $pwr_est_variable_map(MODELPARAM_VALUE.CLKOUT2_DIVIDE)
	lappend param_list [get_property value ${MODELPARAM_VALUE.CLKOUT2_DIVIDE}]
	lappend param_list $pwr_est_variable_map(MODELPARAM_VALUE.CLKOUT3_DIVIDE)
	lappend param_list [get_property value ${MODELPARAM_VALUE.CLKOUT3_DIVIDE}]
	lappend param_list $pwr_est_variable_map(MODELPARAM_VALUE.CLKOUT4_DIVIDE)
	lappend param_list [get_property value ${MODELPARAM_VALUE.CLKOUT4_DIVIDE}]
	lappend param_list $pwr_est_variable_map(PROJECT_PARAM.ARCHITECTURE)
	lappend param_list ${PROJECT_PARAM.ARCHITECTURE}
	lappend param_list $pwr_est_variable_map(PROJECT_PARAM.DEVICE)
	lappend param_list ${PROJECT_PARAM.DEVICE}
	lappend param_list $pwr_est_variable_map(PROJECT_PARAM.PACKAGE)
	lappend param_list ${PROJECT_PARAM.PACKAGE}
	lappend param_list $pwr_est_variable_map(PROJECT_PARAM.SPEEDGRADE)
	lappend param_list ${PROJECT_PARAM.SPEEDGRADE}
	lappend param_list $pwr_est_variable_map(PROJECT_PARAM.TEMPERATURE_GRADE)
	lappend param_list ${PROJECT_PARAM.TEMPERATURE_GRADE}
	lappend param_list $pwr_est_variable_map(PROJECT_PARAM.PART)
	lappend param_list ${PROJECT_PARAM.PART}
	return [Ip_power_est_get_power_estimation $param_list]
}

proc init_gui { IPINST } {


    ipgui::add_param $IPINST -name Component_Name -widget comboBox -parent $IPINST
# #####################################################################################################################################
    #set_property allow_viewchange true [ipgui::get_canvasspec -of $IPINST]
    #set_property show_wizard true [ipgui::get_canvasspec -of $IPINST]
    #add_board_tab $IPINST -display_name {"C0_CLOCK_BOARD_INTERFACE" CO_SYS_CLK "RESET_BOARD_INTERFACE" SYSTEM_RESET}
	
    set page1 [ ipgui::add_page $IPINST -name  "Basic" -parent $IPINST ]
    set_property display_name "Basic" $page1
    
    set group_2_page1 [ipgui::add_panel $IPINST -parent $page1 -name "Controller & Interface Options" -layout horizontal ]
	set Select_controller [ipgui::add_param $IPINST -name C0.ControllerType -parent $group_2_page1 -widget comboBox]
	set_property display_name "Controller Type" $Select_controller
    set_property visible false $Select_controller
	
	set pane10 [ipgui::add_group $IPINST -parent $page1 -name "Mode_and_Interface" -layout horizontal]
    
    set PHY_Only [ipgui::add_param $IPINST -name Phy_Only -widget comboBox -parent $pane10]
    set_property display_name "Controller/PHY Mode" $PHY_Only
	set_property visible false $PHY_Only
	
    #set_property tooltip  "Supports DDR3 SDRAM and DDR4 SDRAM controllers." $PHY_Only    
   
# ###########################   Controller Page # ###########################################################
            set page2 [ ipgui::add_panel $IPINST -name  "C0.QDRIIP.Controller"  -parent $page1]
            set_property visible false $page2

            set pane9 [ipgui::add_panel $IPINST -parent $page2 -name pane9 -layout horizontal ]
            set clocking_options_group [add_group -name "C0.QDRIIP.Clocking" -parent $pane9 $IPINST -layout horizontal]
            set_property display_name "Clocking" $clocking_options_group

            set Clock_Period [ipgui::add_param $IPINST -name C0.QDRIIP_TimePeriod -parent $clocking_options_group -show_range false]
            set_property display_name "Memory Device Interface Speed (ps)" $Clock_Period
            set_property tooltip "Choose the clock period for the desired frequency. The allowed period range is a function of the selected FPGA part and FPGA speed grade." $Clock_Period
            ipgui::add_row $IPINST -parent $clocking_options_group

            set freq_text [ipgui::add_dynamic_text $IPINST -name "C0.dynamic_clock_period" -parent $clocking_options_group -tclproc get_clock_peiod]
            set dynamic_text [ipgui::add_dynamic_text $IPINST -name "dynamic_range" -parent $clocking_options_group -tclproc dynamic_range]
            ipgui::add_row $IPINST -parent $clocking_options_group

			set dci_cascade_text [ipgui::add_dynamic_text $IPINST -name "dci_cascade_range" -parent $clocking_options_group -tclproc dci_cascade_range]
			ipgui::add_row $IPINST -parent $clocking_options_group
			
				#### New addition for Specify M and D options
			set pane19 [ipgui::add_panel $IPINST -parent $page2 -name clocking_options_group -layout horizontal ]
			set Auto_Comp_MandD_grp   [ipgui::add_group $IPINST -parent $pane19 -name "M and D Options" -layout vertical -header_param "C0.QDRIIP_Specify_MandD"]
			
			set InputClockPeriod [ipgui::add_param $IPINST -name C0.QDRIIP_InputClockPeriod -widget comboBox -parent $Auto_Comp_MandD_grp]
            set_property display_name "Reference Input Clock Speed (ps)" $InputClockPeriod
            set_property tooltip "Select the period for the MMCM input clock (CLKIN). QDRIIP determines the allowable input clock periods based on the Memory Clock Period entered above and the clocking guidelines listed in the Product Guide. The generated design will use the selected Input Clock and Memory Clock Periods to generate the required MMCM parameters. If the required input clock period is not available, the Memory Clock Period must be modified." $InputClockPeriod
			ipgui::add_row $IPINST -parent $Auto_Comp_MandD_grp
			
			set panel3 [ ipgui::add_panel $IPINST -name  "display_calc_Ref_Clk_usingMandD"  -parent $Auto_Comp_MandD_grp -layout horizontal]
			
			set display_static [ipgui::add_static_text $IPINST -name "display_static" -parent $panel3 -text "Reference Input Clock Speed (ps)"]
			set auto_ip_clk [ipgui::add_dynamic_text $IPINST -name "auto_ip_clk_range" -parent $panel3 -tclproc auto_ip_clk_range -display_border true]
			set_property visible false  $display_static
			set_property visible false  $auto_ip_clk
			
			#### New addition for Specify M and D options
            
            set panel0 [ipgui::add_panel $IPINST -parent $page2 -name panel0 -layout horizontal ]
            set Controller_options_group [add_group -name "C0.QDRIIP.Controller Options" -parent $panel0 $IPINST]
            set_property display_name "Controller Options" $Controller_options_group
            
            #set custom_part_grp [ipgui::add_group $IPINST -parent $Controller_options_group -name custom_part_grp -header_param C0.QDRIIP_isCustom -layout vertical ]
            #set_property display_name "Custom Parts data file" $custom_part_grp
            
            set isCustom [ipgui::add_param $IPINST -name C0.QDRIIP_isCustom -widget checkBox -parent $Controller_options_group]
            set_property display_name "Enable Custom Parts Data File" $isCustom
            set customCSV [ipgui::add_param $IPINST -name C0.QDRIIP_CustomParts -widget limWidthFileBrowser -parent $Controller_options_group]
            set_property display_name "Custom Parts Data File" $customCSV
            set customPart_text [ ipgui::add_static_text -name "customPart_text" -text "A complete list of valid values and sample CSV files can be found <html> <a href = \"http://www.xilinx.com/support/answers/63462.html\">here</html>" -has_hypertext true -parent $Controller_options_group $IPINST]	
            set_property tooltip "Load the CSV formatted file to have the custom parts support following the below said sample CSV file format.\nSimulations are not supported for custom part." $customCSV

         
                set BurstLen [ipgui::add_param $IPINST -name C0.QDRIIP_BurstLen -widget comboBox -parent $Controller_options_group]
                set_property display_name "Burst Length" $BurstLen
				set_property tooltip "The list of Burst Length depends on the selected clock period(ps)" $BurstLen
            
            set Memory_Part [ipgui::add_param $IPINST -name C0.QDRIIP_MemoryPart -widget comboBox -parent $Controller_options_group]
            set_property display_name "Memory Part" $Memory_Part
            set memory_part_text [ipgui::add_dynamic_text $IPINST -name "Memory_part_details" -parent $Controller_options_group -tclproc qdrii_memory_part_details]
            set temp_grade_info [ipgui::add_static_text $IPINST -name "temp_grade_info" -parent $Controller_options_group -text "The natively supported devices in the Memory Part list contain temperature grade designations\n but the IP always assumes 1.2V VDDQ operation.  Additionally the controller behavior does not \nchange based on the temperature grade of the selected device."]
            #set_property tooltip "Memory Part contains Temperature Grade designation also and IP functionality does not have impact based on temperature grade" $Memory_Part
           
            set Data_Width [ipgui::add_param $IPINST -name C0.QDRIIP_DataWidth -widget comboBox -parent $Controller_options_group]
            set_property display_name "Data Width" $Data_Width
            set_property tooltip "The data width value can be selected here based on the memory type selected earlier. The list shows all supported data widths for the selected part." $Data_Width

           
             #### New addition for Specify M and D options - New page Advanced_Clocking added ######
            set page4 [ ipgui::add_page $IPINST -name  "Advanced_Clocking" -parent $IPINST ]
			set Auto_Comp_MandD_panel [ipgui::add_panel  $IPINST -parent $page4 -name Auto_Comp_MandD_panel -layout vertical]
			
			
			
			set adv_clocking_options_group [add_group -name "C0.QDRIIP.Adv_Clocking" -parent $Auto_Comp_MandD_panel $IPINST -layout vertical]
            set_property display_name "Specify M and D" $adv_clocking_options_group

			ipgui::add_row $IPINST -parent $adv_clocking_options_group
			
			ipgui::add_dynamic_text $IPINST -name "ref_text" -parent $adv_clocking_options_group -tclproc get_ref
			
			ipgui::add_row $IPINST -parent $adv_clocking_options_group
			
			set form_text [ipgui::add_static_text $IPINST -parent $adv_clocking_options_group -name form_text -text "<b>Formulae used for calculation</b>"]
			set MMCM_txt [ipgui::add_static_text $IPINST -parent $adv_clocking_options_group -name clkin_txt -text "MMCM_CLKOUT(MHz) = tCK/2 , where tCK is Memory Device Interface Speed(MHz) selected in basic page" ]
			set clkin_txt [ipgui::add_static_text $IPINST -parent $adv_clocking_options_group -name clkin_txt -text "CLKIN(MHz) = (MMCM_CLKOUT(MHz)*D*D0)/M" ]
			set vco_txt [ipgui::add_static_text $IPINST -parent $adv_clocking_options_group -name vco_txt -text "VCO(MHz) = (CLKIN(MHz)*M)/D" ]
      set pfd_txt [ipgui::add_static_text $IPINST -parent $adv_clocking_options_group -name pfd_txt -text "PFD(MHz) = CLKIN(MHz)/D" ]
			
			
			ipgui::add_row $IPINST -parent $adv_clocking_options_group
			
			set inside_Auto_Comp_MandD_panel [ipgui::add_panel  $IPINST -parent $adv_clocking_options_group -name inside_Auto_Comp_MandD_panel -layout vertical]
			
			set table1 [ipgui::add_table $IPINST -name "table1" -rows "3" -columns "2" -parent $inside_Auto_Comp_MandD_panel]
		
			set C_TABLE_ROW4 [ipgui::add_static_text $IPINST -parent $table1 -name C_TABLE_ROW5 -text "CLKFBOUT_MULT (M)" ]
	
			set C_TABLE_ROW5 [ipgui::add_static_text $IPINST -parent $table1 -name C_TABLE_ROW6 -text "DIVCLK_DIVIDE (D)" ]
			
			set C_TABLE_ROW6 [ipgui::add_static_text $IPINST -parent $table1 -name C_TABLE_ROW7 -text "CLKOUT0_DIVIDE (D0)" ]
			
			#set C_TABLE_ROW7 [ipgui::add_static_text $IPINST -parent $table1 -name C_TABLE_ROW5 -text "CLKFBOUT_MULT (M)" ]
	
			#set C_TABLE_ROW8 [ipgui::add_static_text $IPINST -parent $table1 -name C_TABLE_ROW6 -text "DIVCLK_DIVIDE (D)" ]
			
			#set C_TABLE_ROW9 [ipgui::add_static_text $IPINST -parent $table1 -name C_TABLE_ROW7 -text "CLKOUT0_DIVIDE (D0)" ]
			
			set_property cell_location 0,0 $C_TABLE_ROW4
			set_property cell_location 1,0 $C_TABLE_ROW5
			set_property cell_location 2,0 $C_TABLE_ROW6
			
			#set_property cell_location 3,0 $C_TABLE_ROW7
			#set_property cell_location 4,0 $C_TABLE_ROW8
			#set_property cell_location 5,0 $C_TABLE_ROW9
			
			
			ipgui::add_row $IPINST -parent $adv_clocking_options_group
			
			set table2 [ipgui::add_table $IPINST -name "table2" -rows "3" -columns "2" -parent $inside_Auto_Comp_MandD_panel]
			
			set C_TABLE_ROW7 [ipgui::add_static_text $IPINST -parent $table2 -name C_TABLE_ROW8 -text "VCO (MHz)" ]
			
			set C_TABLE_ROW8 [ipgui::add_static_text $IPINST -parent $table2 -name C_TABLE_ROW4 -text "Reference Input Clock Speed (ps)" ]

      set C_TABLE_ROW9 [ipgui::add_static_text $IPINST -parent $table2 -name C_TABLE_ROW9 -text "PFD (MHz)" ]
			
			set_property cell_location 0,0 $C_TABLE_ROW7
			set_property cell_location 1,0 $C_TABLE_ROW8
			set_property cell_location 2,0 $C_TABLE_ROW9
			
			set M_val [ipgui::add_param $IPINST -name C0.QDRIIP_CLKFBOUT_MULT -parent $table1 -show_range false]
			set_property cell_location 0,1 $M_val
			
			set D_val [ipgui::add_param $IPINST -name C0.QDRIIP_DIVCLK_DIVIDE -parent $table1 -show_range false]
			set_property cell_location 1,1 $D_val
			
			set D0_val [ipgui::add_param $IPINST -name C0.QDRIIP_CLKOUT0_DIVIDE -parent $table1 -show_range false]
            set_property cell_location 2,1 $D0_val
			
			set VCO_val [ipgui::add_dynamic_text $IPINST -name vco_range -parent $table2 -display_border true -tclproc vco_range]
			set_property cell_location 0,1 $VCO_val
			
			set ip_clk_val [ipgui::add_dynamic_text $IPINST -name ip_clk_range -parent $table2 -display_border true -tclproc ip_clk_range]
			set_property cell_location 1,1 $ip_clk_val
		  
      set pfd_val [ipgui::add_dynamic_text $IPINST -name pfd_val_range -parent $table2 -display_border true -tclproc pfd_val_range]
		  set_property cell_location 2,1 $pfd_val  
			#ipgui::add_row $IPINST -parent $Auto_Comp_MandD_grp
			
			
			set ADV_CLOCK_WARNING [ipgui::add_static_text -name "ADV_CLOCK_WARNING" -text "<b>Clocking design rule checks are only done for QDRII specific rules and refer to clocking section in PG150 for info on clocking rules.<br/>Verify changes by running the Vivado implementation tools. See UG572 for more information on clocking and the MMCM.</b>"  -parent $adv_clocking_options_group $IPINST]


			set fpga_options_group1 [add_group -name "System_Clock_Option" -parent $page4 $IPINST]
			set System_Clock [ipgui::add_param $IPINST -name System_Clock -widget comboBox -parent $fpga_options_group1]
			set_property display_name "Reference Input Clock Configuration" $System_Clock
			set_property tooltip "Choose the desired input clock configuration." $System_Clock
	
	set clock_options [add_group -name "Additional Clock Outputs" -parent $page4 $IPINST]
    
    set min_version [ string index [get_property ipdef $IPINST] end]
    set maj_version [ string index [get_property ipdef $IPINST] end-2]
    
    set text1 [ipgui::add_static_text -name "QDRIIP_CLOCK" -text "QDRIIP can generate up to 4 additional clocks to be used in Fabric logic.This\n will be generated from the same MMCM which is used for generation of UI CLK.\nAll the values in the additional clocks drop downs are calculated considering the\nselected MMCM VCO frequency in Mhz.\nFor complete details on clocking of QDRIIP, refer to <html> <a href = \"http://www.xilinx.com/support/documentation/ip_documentation/mig/v${maj_version}_${min_version}/pg150-ultrascale-mis.pdf\">QDRIIP product Guide</html>" -has_hypertext true -parent $clock_options $IPINST]

    set pane2 [ipgui::add_panel $IPINST -parent $clock_options -name pane2 -layout horizontal ]

    set clock_1 [ipgui::add_param $IPINST -name ADDN_UI_CLKOUT1_FREQ_HZ -widget comboBox -parent $pane2]
    set_property display_name "Clock 1 (MHz)" $clock_1
    ipgui::add_dynamic_text $IPINST -name "clock1_text" -parent $pane2 -tclproc get_clock1
    ipgui::add_row $IPINST -parent $pane2

    set clock_2 [ipgui::add_param $IPINST -name ADDN_UI_CLKOUT2_FREQ_HZ -widget comboBox -parent $pane2]
    set_property display_name "Clock 2 (MHz)" $clock_2
    ipgui::add_dynamic_text $IPINST -name "clock2_text" -parent $pane2 -tclproc get_clock2
    ipgui::add_row $IPINST -parent $pane2

    set clock_3 [ipgui::add_param $IPINST -name ADDN_UI_CLKOUT3_FREQ_HZ -widget comboBox -parent $pane2]
    set_property display_name "Clock 3 (MHz)" $clock_3
    ipgui::add_dynamic_text $IPINST -name "clock3_text" -parent $pane2 -tclproc get_clock3
    ipgui::add_row $IPINST -parent $pane2

    set clock_4 [ipgui::add_param $IPINST -name ADDN_UI_CLKOUT4_FREQ_HZ -widget comboBox -parent $pane2]
    set_property display_name "Clock 4 (MHz)" $clock_4
    ipgui::add_dynamic_text $IPINST -name "clock4_text" -parent $pane2 -tclproc get_clock4
    ipgui::add_row $IPINST -parent $pane2

	#set clock_6 [ipgui::add_param $IPINST -name CLKOUT6 -widget checkBox -parent $pane2]
    #set_property display_name "Run calibration at max speed" $clock_6
    #set_property tooltip  "Upon enabling this option, calibration will run at frequency closer to 200MHz and less than 200 MHZ" $clock_6
    #ipgui::add_row $IPINST -parent $pane2
	
           
           

 # ################################# Common Page ####################################################

    set page2 [ ipgui::add_page $IPINST -name  "Advanced_Options" -parent $IPINST ]
    set_property visible false $page2
    set fpga_options_group [add_group -name "FPGA Options" -parent $page2 $IPINST]
    set DCI_Cascade [ipgui::add_param $IPINST -name DCI_Cascade -parent $fpga_options_group]
    set_property display_name "DCI Cascade" $DCI_Cascade
    set_property enabled false $DCI_Cascade
    set_property visible false $DCI_Cascade

	set Internal_Vref [ipgui::add_param $IPINST -name Internal_Vref -parent $fpga_options_group -widget checkBox]
    set_property display_name "Internal Vref" $Internal_Vref
	set_property tooltip "If internal VREF is enabled, the VREF pins should be pulled to ground by a 500-ohm resistor. For more information, see the UltraScale™ Architecture-Based FPGAs SelectIO™ Resources User Guide (UG571)" $Internal_Vref
	

    #Adding ILA Debug Enablement
    
    set panel1 [ipgui::add_panel $IPINST -parent $page2 -name panel1 -layout horizontal ]
    set Debug_Signal [ipgui::add_param $IPINST -name Debug_Signal -parent $panel1]
    set_property display_name "Debug Signals for controller" $Debug_Signal
    set_property tooltip "Enabling this feature will connect status signals to the ChipScope ILA core in the example design top module." $Debug_Signal
    set_property enabled false $Debug_Signal

    set mcs_ecc_options [add_group -name "MicroBlaze MCS ECC option" -parent $page2 $IPINST]
	set MCS_ECC [ipgui::add_param $IPINST -name C0.QDRIIP_MCS_ECC -widget checkBox -parent $mcs_ecc_options]
	set_property display_name "MicroBlaze MCS ECC" $MCS_ECC
    set_property tooltip "The BRAM size will increase if ECC option for MicroBlaze MCS is selected." $MCS_ECC

    set simulation_options_group [add_group -name "Simulation Options" -parent $page2 $IPINST]
    set Simulation_Mode [ipgui::add_param $IPINST -name Simulation_Mode -widget comboBox -parent $simulation_options_group]
    set_property display_name "Simulation Mode" $Simulation_Mode
    set_property tooltip "This option is valid for simulations only. Upon selecting BFM option, uses behavioral model for XiPhy libraries which speeds up simulations run time. Option Unisim, uses Unisim libraries for XiPhy primitives" $Simulation_Mode

    set example_tg_options [add_group -name "Example Design Options" -parent $page2 $IPINST]
    set Example_TG [ipgui::add_param $IPINST -name Example_TG -widget comboBox -parent $example_tg_options]
    set_property display_name "Example Design Test Bench" $Example_TG
    set_property tooltip "Select the Test bench for Example Design. <br/> <br/><b>SIMPLE_TG</b> - Simple Write and Read Transaction.<br/> <b>ADVANCED_TG</b> - Complex Write and Read Transaction. <br/> " $Example_TG
	
	###################### I/O Planner and Design Checklist Page#######################################################################################################
  ######I/O Planner###################
	set page3 [ ipgui::add_page $IPINST -name  "I/O Planning and Design Checklist" -parent $IPINST ]
  set IO_Planning_group [ipgui::add_group -name "I/O Planning" -parent $page3 $IPINST]
	set text1 [ipgui::add_static_text -name "I/O Planner text" -text "<br/>The methodology for assigning I/O pins for QDRIIP IP interfaces has changed. Rather than assign I/Os within the IP, <br/>they are now assigned in the main Vivado I/O Planner along with the I/Os for the rest of the design. To access the Vivado <br/>I/O Planning environment, open the Elaborated RTL Design or Synthesized Design and select the I/O Planning layout option <br/>from the top menu bar. The QDRIIP IP I/O byte groups are available for bank assignment using a similar dialog as used <br/>previously within the IP.  " -parent $IO_Planning_group $IPINST]
	set text1 [ipgui::add_static_text -name "I/O Planner text1" -text "\nRefer to the Vivado Design Suite User Guide: <html> <a href = \"http://www.xilinx.com/cgi-bin/docs/rdoc?v=latest;d=ug899-vivado-io-clock-planning.pdf\">I/O and Clock Planning</a> or the Using Memory Controller IP with UltraScale Devices<br/> <a href = \"http://www.xilinx.com/training/vivado/using-ultrascale-memory-controller-ip.htm\">QuickTake video tutorial</a> for more information.Performing I/O planning for the Memory IP IOs, requires the IP to be instantiated<br/> into a top-level design or example design. </html>" -has_hypertext true -parent $IO_Planning_group $IPINST]

  ######Design Checklist##############
    #set_property visible false $page6
    set group_1_page3 [ipgui::add_group $IPINST -parent $page3 -name "Design Checklist: Usage Information" -layout vertical]
    set text  [ipgui::add_static_text -name "checklist1" -text "<br/>A QDRIIP Design Methodology Checklist is available to plan, design, and debug with QDRIIP. The checklist organizes information <br/>that is critical to successful QDRIIP operation especially at top supported data rates. It includes information on core definition <br/>and generation, pin, clocking, and board planning, simulation, design flow, and hardware debug .  The checklist is provided <br/>as an Excel spreadsheet that organizes all information needed when working with QDRIIP, where to go for more information,<br/> a check of whether the item has been reviewed, and sections to add notes should there be follow on questions or items to <br/>check at a later time. The checklist should be used throughout the design, bring-up, and debug of QDRIIP cores." -parent $group_1_page3 $IPINST] 
    set text1 [ipgui::add_static_text -name "checklist2" -text "Checklist can be found <html> <a href = \"http://www.xilinx.com/support/answers/59625.html\">here</html>" -has_hypertext true -parent $group_1_page3 $IPINST]	

  set ddr_param [get_param ipgui.displayPowerEstimation]
  if { $ddr_param == "1" || $ddr_param == "true" } {
	set Power_Estimation [	ipgui::add_page  $IPINST  -left  -name Power_Estimation -layout vertical]
    set_property display_name "Power Estimation" $Power_Estimation
	set LHSlabel [	ipgui::add_static_text  $IPINST -name LHSlabel -parent  $Power_Estimation  -text "Estimated power:" ]
	set Estimated_Power_for_IP [	ipgui::add_dynamic_text  $IPINST -name Estimated_Power_for_IP -parent  $Power_Estimation  -tclproc "estimate_power" ]
  }
	
}
# ##################################################################################################################
proc port_info {IPINST } {
    #set value [get_property value ${PARAM_VALUE.System_Clock} ]
    return "value1, value2,value3"
}


proc init_params { IPINST PARAM_VALUE.GPIO1_BOARD_INTERFACE } {
  
    set param_list {}
    lappend param_list "PARAM_VALUE.ADDN_UI_CLKOUT1_FREQ_HZ"
    lappend param_list "PARAM_VALUE.ADDN_UI_CLKOUT2_FREQ_HZ"
    lappend param_list "PARAM_VALUE.ADDN_UI_CLKOUT3_FREQ_HZ"
    lappend param_list "PARAM_VALUE.ADDN_UI_CLKOUT4_FREQ_HZ"
    ipgui::update_params -params_list $param_list $IPINST
    
	
    
}

proc init_meta_params {IPINST } {
	add_meta_param $IPINST -name loadPkg -type string
    add_meta_param $IPINST -name metaCustomization_params -type array
    add_meta_param $IPINST -name metaModelparams -type array
    add_meta_param $IPINST -name metaClockingmodelparams -type array
    add_meta_param $IPINST -name metaBankmodelparams -type array
	add_meta_param $IPINST -name storeTimePeriod -type string
	add_meta_param $IPINST -name storeInputClkPeriod -type string
	add_meta_param $IPINST -name storeAddUIClk1 -type list -value ""
	add_meta_param $IPINST -name storeAddUIClk2 -type list -value ""
	add_meta_param $IPINST -name storeAddUIClk3 -type list -value ""
	add_meta_param $IPINST -name storeAddUIClk4 -type list -value ""
	add_meta_param $IPINST -name previous_values -type list
}


proc update_PARAM_VALUE.No_Controller {IPINST PARAM_VALUE.No_Controller PARAM_VALUE.C0.ControllerType } {
    if { [get_property value ${PARAM_VALUE.C0.ControllerType}] == "None" } {
        set_property value 0 ${PARAM_VALUE.No_Controller}
        #reset all params
    } else {
        set_property value 1 ${PARAM_VALUE.No_Controller}
    }
}
proc update_storeTimePeriod {PARAM_VALUE.C0.QDRIIP_TimePeriod} {
	set storeTimePeriod [get_property value ${PARAM_VALUE.C0.QDRIIP_TimePeriod}]
	return $storeTimePeriod
}

proc update_storeInputClkPeriod {PARAM_VALUE.C0.QDRIIP_InputClockPeriod PARAM_VALUE.C0.QDRIIP_Specify_MandD PARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT PARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE PARAM_VALUE.C0.QDRIIP_CLKOUT0_DIVIDE PARAM_VALUE.C0.QDRIIP_TimePeriod} {
   
  set Auto_M_D [get_property value ${PARAM_VALUE.C0.QDRIIP_Specify_MandD}]
	if {$Auto_M_D} {
	     set Mval [get_property value ${PARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT}]
	     set Dval [get_property value ${PARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE}]
	     set D0val [get_property value ${PARAM_VALUE.C0.QDRIIP_CLKOUT0_DIVIDE}]
	     
	     set CLKOUT [get_property value ${PARAM_VALUE.C0.QDRIIP_TimePeriod} ]
	     set phy_clk_ratio 4
       set CLKOUT_MHz [expr 1.0/$CLKOUT * 1000000.00 ]
	     set mhz_clkout [expr $CLKOUT_MHz / $phy_clk_ratio]
	     set CLKIN_MHz [cal_clkin_MHz $mhz_clkout $Mval $Dval $D0val]
	     set CLKIN_ps [cal_clkin_ps [expr $CLKOUT * $phy_clk_ratio] $Mval $Dval $D0val]
#send_msg INFO 234 "CLKIN_ps $CLKIN_ps"
       set storeInputClkPeriod $CLKIN_ps
	} else {
	     set storeInputClkPeriod [get_property value ${PARAM_VALUE.C0.QDRIIP_InputClockPeriod}] 
	}
	return $storeInputClkPeriod
	
}

proc reset_storeAddUIClk1 {PARAM_VALUE.ADDN_UI_CLKOUT1_FREQ_HZ} {
	set storeAddUIClk1 [get_metaparam_value storeAddUIClk1] 
	set new_timePeriod [get_metaparam_value storeTimePeriod]
	set new_inputClkPeriod [get_metaparam_value storeInputClkPeriod]
	set add_ui_clk [get_property value ${PARAM_VALUE.ADDN_UI_CLKOUT1_FREQ_HZ}]
	if {$storeAddUIClk1 == ""} {
		if {$add_ui_clk != "None"} {
			return [list "TP" $new_timePeriod "IP" $new_inputClkPeriod "AU" $add_ui_clk]
		} else {
			return [list "TP" $new_timePeriod "IP" $new_inputClkPeriod "AU" 900]
		}
	}
	#send_msg INFO 111 "storeAddUIClk1 $storeAddUIClk1"
	
	set old_timePeriod [tcl::lindex [split [get_metaparam_value storeAddUIClk1] " "] 1]
	set old_inputClkPeriod [tcl::lindex [split [get_metaparam_value storeAddUIClk1] " "] 3]
	set old_add_ui_clk [tcl::lindex [split [get_metaparam_value storeAddUIClk1] " "] 5]
	#send_msg INFO 222 "old_values $old_timePeriod $old_inputClkPeriod $old_add_ui_clk"
	
	#send_msg INFO 333 "new_values $new_timePeriod $new_inputClkPeriod"
	
	set add_ui_clk [get_property value ${PARAM_VALUE.ADDN_UI_CLKOUT1_FREQ_HZ}]
	if {$old_timePeriod == $new_timePeriod  && $old_inputClkPeriod == $new_inputClkPeriod && $add_ui_clk != "None" } {
		set new_list_values [list "TP" $new_timePeriod "IP" $new_inputClkPeriod "AU" $add_ui_clk]
		#send_msg INFO 444 "storeAddUIClk1 $new_list_values"
		return $new_list_values
		
	} else {
		if { $old_add_ui_clk != "None" } {
		  set new_list_with_old_ui_clk [list "TP" $new_timePeriod "IP" $new_inputClkPeriod "AU" $old_add_ui_clk]
		  #send_msg INFO 444 "storeAddUIClk2 $new_list_with_old_ui_clk [get_metaparam_value storeAddUIClk1]"
		  return	$new_list_with_old_ui_clk
		}
	}
	
}

proc reset_storeAddUIClk2 {PARAM_VALUE.ADDN_UI_CLKOUT2_FREQ_HZ} {
	set storeAddUIClk2 [get_metaparam_value storeAddUIClk2] 
	set new_timePeriod [get_metaparam_value storeTimePeriod]
	set new_inputClkPeriod [get_metaparam_value storeInputClkPeriod]
	
	set add_ui_clk [get_property value ${PARAM_VALUE.ADDN_UI_CLKOUT2_FREQ_HZ}]
	if {$storeAddUIClk2 == ""} {
		if {$add_ui_clk != "None"} {
			return [list "TP" $new_timePeriod "IP" $new_inputClkPeriod "AU" $add_ui_clk]
		} else {
			return [list "TP" $new_timePeriod "IP" $new_inputClkPeriod "AU" 900]
		}
	}
	#send_msg INFO 111 "storeAddUIClk2 $storeAddUIClk2"
	
	set old_timePeriod [tcl::lindex [split [get_metaparam_value storeAddUIClk2] " "] 1]
	set old_inputClkPeriod [tcl::lindex [split [get_metaparam_value storeAddUIClk2] " "] 3]
	set old_add_ui_clk [tcl::lindex [split [get_metaparam_value storeAddUIClk2] " "] 5]
	#send_msg INFO 222 "old_values $old_timePeriod $old_inputClkPeriod $old_add_ui_clk"
	
	#send_msg INFO 333 "new_values $new_timePeriod $new_inputClkPeriod"
	
	set add_ui_clk [get_property value ${PARAM_VALUE.ADDN_UI_CLKOUT2_FREQ_HZ}]
	if {$old_timePeriod == $new_timePeriod  && $old_inputClkPeriod == $new_inputClkPeriod && $add_ui_clk != "None" } {
		set new_list_values [list "TP" $new_timePeriod "IP" $new_inputClkPeriod "AU" $add_ui_clk]
		#send_msg INFO 444 "storeAddUIClk2 $new_list_values"
		return $new_list_values
		
	} else {
		if { $old_add_ui_clk != "None" } {
		  set new_list_with_old_ui_clk [list "TP" $new_timePeriod "IP" $new_inputClkPeriod "AU" $old_add_ui_clk]
		  #send_msg INFO 444 "storeAddUIClk2 $new_list_with_old_ui_clk [get_metaparam_value storeAddUIClk2]"
		  return	$new_list_with_old_ui_clk
		}
	}
	
}

proc reset_storeAddUIClk3 {PARAM_VALUE.ADDN_UI_CLKOUT3_FREQ_HZ} {
	set storeAddUIClk3 [get_metaparam_value storeAddUIClk3] 
	set new_timePeriod [get_metaparam_value storeTimePeriod]
	set new_inputClkPeriod [get_metaparam_value storeInputClkPeriod]
	
	set add_ui_clk [get_property value ${PARAM_VALUE.ADDN_UI_CLKOUT3_FREQ_HZ}]
	if {$storeAddUIClk3 == ""} {
		if {$add_ui_clk != "None"} {
			return [list "TP" $new_timePeriod "IP" $new_inputClkPeriod "AU" $add_ui_clk]
		} else {
			return [list "TP" $new_timePeriod "IP" $new_inputClkPeriod "AU" 900]
		}
	}
	#send_msg INFO 111 "storeAddUIClk3 $storeAddUIClk3"
	
	set old_timePeriod [tcl::lindex [split [get_metaparam_value storeAddUIClk3] " "] 1]
	set old_inputClkPeriod [tcl::lindex [split [get_metaparam_value storeAddUIClk3] " "] 3]
	set old_add_ui_clk [tcl::lindex [split [get_metaparam_value storeAddUIClk3] " "] 5]
	#send_msg INFO 222 "old_values $old_timePeriod $old_inputClkPeriod $old_add_ui_clk"
	
	#send_msg INFO 333 "new_values $new_timePeriod $new_inputClkPeriod"
	
	set add_ui_clk [get_property value ${PARAM_VALUE.ADDN_UI_CLKOUT3_FREQ_HZ}]
	if {$old_timePeriod == $new_timePeriod  && $old_inputClkPeriod == $new_inputClkPeriod && $add_ui_clk != "None" } {
		set new_list_values [list "TP" $new_timePeriod "IP" $new_inputClkPeriod "AU" $add_ui_clk]
		#send_msg INFO 444 "storeAddUIClk3 $new_list_values"
		return $new_list_values
		
	} else {
		if { $old_add_ui_clk != "None" } {
		  set new_list_with_old_ui_clk [list "TP" $new_timePeriod "IP" $new_inputClkPeriod "AU" $old_add_ui_clk]
		  #send_msg INFO 444 "storeAddUIClk3 $new_list_with_old_ui_clk [get_metaparam_value storeAddUIClk3]"
		  return	$new_list_with_old_ui_clk
		}
	}
	
}

proc reset_storeAddUIClk4 {PARAM_VALUE.ADDN_UI_CLKOUT4_FREQ_HZ} {
	set storeAddUIClk4 [get_metaparam_value storeAddUIClk4] 
	set new_timePeriod [get_metaparam_value storeTimePeriod]
	set new_inputClkPeriod [get_metaparam_value storeInputClkPeriod]
	
	set add_ui_clk [get_property value ${PARAM_VALUE.ADDN_UI_CLKOUT4_FREQ_HZ}]
	if {$storeAddUIClk4 == ""} {
		if {$add_ui_clk != "None"} {
			return [list "TP" $new_timePeriod "IP" $new_inputClkPeriod "AU" $add_ui_clk]
		} else {
			return [list "TP" $new_timePeriod "IP" $new_inputClkPeriod "AU" 900]
		}
	}
	#send_msg INFO 111 "storeAddUIClk4 $storeAddUIClk4"
	
	set old_timePeriod [tcl::lindex [split [get_metaparam_value storeAddUIClk4] " "] 1]
	set old_inputClkPeriod [tcl::lindex [split [get_metaparam_value storeAddUIClk4] " "] 3]
	set old_add_ui_clk [tcl::lindex [split [get_metaparam_value storeAddUIClk4] " "] 5]
	#send_msg INFO 222 "old_values $old_timePeriod $old_inputClkPeriod $old_add_ui_clk"
	
	#send_msg INFO 333 "new_values $new_timePeriod $new_inputClkPeriod"
	
	set add_ui_clk [get_property value ${PARAM_VALUE.ADDN_UI_CLKOUT4_FREQ_HZ}]
	if {$old_timePeriod == $new_timePeriod  && $old_inputClkPeriod == $new_inputClkPeriod && $add_ui_clk != "None" } {
		set new_list_values [list "TP" $new_timePeriod "IP" $new_inputClkPeriod "AU" $add_ui_clk]
		#send_msg INFO 444 "storeAddUIClk4 $new_list_values"
		return $new_list_values
		
	} else {
		if { $old_add_ui_clk != "None" } {
		  set new_list_with_old_ui_clk [list "TP" $new_timePeriod "IP" $new_inputClkPeriod "AU" $old_add_ui_clk]
		  #send_msg INFO 444 "storeAddUIClk4 $new_list_with_old_ui_clk [get_metaparam_value storeAddUIClk4]"
		  return	$new_list_with_old_ui_clk
		}
	}
	
}

proc update_PARAM_VALUE.ADDN_UI_CLKOUT1_FREQ_HZ {PARAM_VALUE.ADDN_UI_CLKOUT1_FREQ_HZ PARAM_VALUE.C0.QDRIIP_Specify_MandD PARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT PARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE PARAM_VALUE.C0.QDRIIP_CLKOUT0_DIVIDE PARAM_VALUE.C0.QDRIIP_TimePeriod PARAM_VALUE.C0.QDRIIP_InputClockPeriod PARAM_VALUE.C0.ControllerType  MODELPARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE MODELPARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT } {
    set check 0
    set freq 800
    set divclk_div 1
    set clkfbout_mult 1

    set add_ui_clk1 [get_property value ${PARAM_VALUE.ADDN_UI_CLKOUT1_FREQ_HZ}]
	set user_changed_value_add_ui_clk [lindex [get_metaparam_value storeAddUIClk1] 5]


   if { [get_property value ${PARAM_VALUE.C0.ControllerType}] == "QDRIIPLUS_SRAM" } {
        set Auto_M_D [get_property value ${PARAM_VALUE.C0.QDRIIP_Specify_MandD}]
		if {$Auto_M_D} {
			set Mval [get_property value ${PARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT}]
			set Dval [get_property value ${PARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE}]
			set D0val [get_property value ${PARAM_VALUE.C0.QDRIIP_CLKOUT0_DIVIDE}]
			set CLKOUT [get_property value ${PARAM_VALUE.C0.QDRIIP_TimePeriod} ] 
			set phy_clk_ratio 2
			set freq [cal_clkin_ps [expr $CLKOUT * $phy_clk_ratio] $Mval $Dval $D0val]	
		} else {
        set freq [expr [get_property value ${PARAM_VALUE.C0.QDRIIP_InputClockPeriod} ]]
		}
        if {[get_property value ${MODELPARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE} ] == "" || [ get_property value ${MODELPARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT} ] == ""} {
            return ;        
        } else {
            set divclk_div [expr int([ get_property value ${MODELPARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE} ])]
            set clkfbout_mult [expr int([ get_property value ${MODELPARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT} ])]
        }
        set check 1
    }

    if { $check == 1 } {
		set new_list  [getMMCMClockList1 $freq  $divclk_div $clkfbout_mult]
		set new_val "None"
		if {$add_ui_clk1 != "None"} {
			set index [tcl::lsearch $new_list "None"]
			set new_list [lreplace $new_list $index $index]
			set created_list {}
			set created_list [regsub -all "," $new_list " "]
			set new_val [closest $user_changed_value_add_ui_clk $created_list]
			tcl::lappend new_list ","
			tcl::lappend new_list "None"
		}
		
        set_property range_value "$new_val,$new_list"  ${PARAM_VALUE.ADDN_UI_CLKOUT1_FREQ_HZ}
    } else {
       set_property range "None" ${PARAM_VALUE.ADDN_UI_CLKOUT1_FREQ_HZ} 
    } 
}

proc update_PARAM_VALUE.ADDN_UI_CLKOUT2_FREQ_HZ {PARAM_VALUE.ADDN_UI_CLKOUT2_FREQ_HZ PARAM_VALUE.C0.QDRIIP_Specify_MandD PARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT PARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE PARAM_VALUE.C0.QDRIIP_CLKOUT0_DIVIDE PARAM_VALUE.C0.QDRIIP_TimePeriod PARAM_VALUE.C0.QDRIIP_InputClockPeriod PARAM_VALUE.C0.ControllerType MODELPARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE MODELPARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT } {
    set check 0
    set freq 800
    set divclk_div 1
    set clkfbout_mult 1
	
	set add_ui_clk2 [get_property value ${PARAM_VALUE.ADDN_UI_CLKOUT2_FREQ_HZ}]
	set user_changed_value_add_ui_clk [lindex [get_metaparam_value storeAddUIClk2] 5]
	
    if { [get_property value ${PARAM_VALUE.C0.ControllerType}] == "QDRIIPLUS_SRAM" } {
        set Auto_M_D [get_property value ${PARAM_VALUE.C0.QDRIIP_Specify_MandD}]
		if {$Auto_M_D} {
			set Mval [get_property value ${PARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT}]
			set Dval [get_property value ${PARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE}]
			set D0val [get_property value ${PARAM_VALUE.C0.QDRIIP_CLKOUT0_DIVIDE}]
			set CLKOUT [get_property value ${PARAM_VALUE.C0.QDRIIP_TimePeriod} ] 
			set phy_clk_ratio 2
			set freq [cal_clkin_ps [expr $CLKOUT * $phy_clk_ratio] $Mval $Dval $D0val]	
		} else {
        set freq [expr [get_property value ${PARAM_VALUE.C0.QDRIIP_InputClockPeriod} ]]
		}
        if {[get_property value ${MODELPARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE} ] == "" || [ get_property value ${MODELPARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT} ] == ""} {
            return ;        
        } else {
            set divclk_div [expr int([ get_property value ${MODELPARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE} ])]
            set clkfbout_mult [expr int([ get_property value ${MODELPARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT} ])]
        }
        set check 1
    }

    if { $check == 1 } {
        set new_list  [getMMCMClockList1 $freq  $divclk_div $clkfbout_mult]
		set new_val "None"
		if {$add_ui_clk2 != "None"} {
			set index [tcl::lsearch $new_list "None"]
			set new_list [lreplace $new_list $index $index]
			set created_list {}
			set created_list [regsub -all "," $new_list " "]
			set new_val [closest $user_changed_value_add_ui_clk $created_list]
			tcl::lappend new_list ","
			tcl::lappend new_list "None"
		}
		
        set_property range_value "$new_val,$new_list"  ${PARAM_VALUE.ADDN_UI_CLKOUT2_FREQ_HZ}
    } else {
       set_property range "None" ${PARAM_VALUE.ADDN_UI_CLKOUT2_FREQ_HZ} 
    }
}

proc update_PARAM_VALUE.ADDN_UI_CLKOUT3_FREQ_HZ {PARAM_VALUE.ADDN_UI_CLKOUT3_FREQ_HZ  PARAM_VALUE.C0.QDRIIP_Specify_MandD PARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT PARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE PARAM_VALUE.C0.QDRIIP_CLKOUT0_DIVIDE PARAM_VALUE.C0.QDRIIP_TimePeriod PARAM_VALUE.C0.QDRIIP_InputClockPeriod PARAM_VALUE.C0.ControllerType MODELPARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE MODELPARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT } {
    set check 0
    set freq 800
    set divclk_div 1
    set clkfbout_mult 1
	
	set add_ui_clk3 [get_property value ${PARAM_VALUE.ADDN_UI_CLKOUT3_FREQ_HZ}]
	set user_changed_value_add_ui_clk [lindex [get_metaparam_value storeAddUIClk3] 5]
	
    if { [get_property value ${PARAM_VALUE.C0.ControllerType}] == "QDRIIPLUS_SRAM" } {
        set Auto_M_D [get_property value ${PARAM_VALUE.C0.QDRIIP_Specify_MandD}]
		if {$Auto_M_D} {
			set Mval [get_property value ${PARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT}]
			set Dval [get_property value ${PARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE}]
			set D0val [get_property value ${PARAM_VALUE.C0.QDRIIP_CLKOUT0_DIVIDE}]
			set CLKOUT [get_property value ${PARAM_VALUE.C0.QDRIIP_TimePeriod} ] 
			set phy_clk_ratio 2
			set freq [cal_clkin_ps [expr $CLKOUT * $phy_clk_ratio] $Mval $Dval $D0val]	
		} else {
        set freq [expr [get_property value ${PARAM_VALUE.C0.QDRIIP_InputClockPeriod} ]]
		}
        if {[get_property value ${MODELPARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE} ] == "" || [ get_property value ${MODELPARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT} ] == ""} {
            return ;        
        } else {
            set divclk_div [expr int([ get_property value ${MODELPARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE} ])]
            set clkfbout_mult [expr int([ get_property value ${MODELPARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT} ])]
        }
        set check 1
    }

    if { $check == 1 } {
        set new_list  [getMMCMClockList1 $freq  $divclk_div $clkfbout_mult]
		set new_val "None"
		if {$add_ui_clk3 != "None"} {
			set index [tcl::lsearch $new_list "None"]
			set new_list [lreplace $new_list $index $index]
			set created_list {}
			set created_list [regsub -all "," $new_list " "]
			set new_val [closest $user_changed_value_add_ui_clk $created_list]
			tcl::lappend new_list ","
			tcl::lappend new_list "None"
		}
		
        set_property range_value "$new_val,$new_list"  ${PARAM_VALUE.ADDN_UI_CLKOUT3_FREQ_HZ}
    } else {
       set_property range "None" ${PARAM_VALUE.ADDN_UI_CLKOUT3_FREQ_HZ} 
    }  
}

proc update_PARAM_VALUE.ADDN_UI_CLKOUT4_FREQ_HZ {PARAM_VALUE.ADDN_UI_CLKOUT4_FREQ_HZ PARAM_VALUE.C0.QDRIIP_Specify_MandD PARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT PARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE PARAM_VALUE.C0.QDRIIP_CLKOUT0_DIVIDE PARAM_VALUE.C0.QDRIIP_TimePeriod PARAM_VALUE.C0.QDRIIP_InputClockPeriod PARAM_VALUE.C0.ControllerType MODELPARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE MODELPARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT } {
    set check 0
    set freq 800
    set divclk_div 1
    set clkfbout_mult 1
	
	set add_ui_clk4 [get_property value ${PARAM_VALUE.ADDN_UI_CLKOUT4_FREQ_HZ}]
	set user_changed_value_add_ui_clk [lindex [get_metaparam_value storeAddUIClk4] 5]
	
    if { [get_property value ${PARAM_VALUE.C0.ControllerType}] == "QDRIIPLUS_SRAM" } {
        set Auto_M_D [get_property value ${PARAM_VALUE.C0.QDRIIP_Specify_MandD}]
		if {$Auto_M_D} {
			set Mval [get_property value ${PARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT}]
			set Dval [get_property value ${PARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE}]
			set D0val [get_property value ${PARAM_VALUE.C0.QDRIIP_CLKOUT0_DIVIDE}]
			set CLKOUT [get_property value ${PARAM_VALUE.C0.QDRIIP_TimePeriod} ] 
			set phy_clk_ratio 2
			set freq [cal_clkin_ps [expr $CLKOUT * $phy_clk_ratio] $Mval $Dval $D0val]	
		} else {
        set freq [expr [get_property value ${PARAM_VALUE.C0.QDRIIP_InputClockPeriod} ]]
		}
        if {[get_property value ${MODELPARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE} ] == "" || [ get_property value ${MODELPARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT} ] == ""} {
            return ;        
        } else {
            set divclk_div [expr int([ get_property value ${MODELPARAM_VALUE.C0.QDRIIP_DIVCLK_DIVIDE} ])]
            set clkfbout_mult [expr int([ get_property value ${MODELPARAM_VALUE.C0.QDRIIP_CLKFBOUT_MULT} ])]
        }
        set check 1
    }

    if { $check == 1 } {
        set new_list  [getMMCMClockList1 $freq  $divclk_div $clkfbout_mult]
		set new_val "None"
		if {$add_ui_clk4 != "None"} {
			set index [tcl::lsearch $new_list "None"]
			set new_list [lreplace $new_list $index $index]
			set created_list {}
			set created_list [regsub -all "," $new_list " "]
			set new_val [closest $user_changed_value_add_ui_clk $created_list]
			tcl::lappend new_list ","
			tcl::lappend new_list "None"
		}
		
        set_property range_value "$new_val,$new_list"  ${PARAM_VALUE.ADDN_UI_CLKOUT4_FREQ_HZ}
    } else {
       set_property range "None" ${PARAM_VALUE.ADDN_UI_CLKOUT4_FREQ_HZ} 
    }
}



# ############################ User Parameter update ##########################################################
proc update_PARAM_VALUE.C0.ControllerType { PARAM_VALUE.C0.ControllerType PROJECT_PARAM.DEVICE } {

		
    set vivado_mode [ getVivadoMode ]
	
    if { $vivado_mode == "xpg_bd"} {
        set_property range "QDRIIPLUS_SRAM" ${PARAM_VALUE.C0.ControllerType}
    } else {
        set_property range "QDRIIPLUS_SRAM" ${PARAM_VALUE.C0.ControllerType}  
	}
}



###############################################################################
## Create the update_* procs
###############################################################################


foreach p $params {
    set dependant_list {}
    tcl::lappend dependant_list $p
    tcl::lappend dependant_list PARAM_VALUE.C0.ControllerType
    tcl::lappend dependant_list PARAM_VALUE.C0.QDRIIP_MemoryPart
    tcl::lappend dependant_list PARAM_VALUE.C0.QDRIIP_DataWidth
    set parameter $p

    EvalSubstituting {dependant_list parameter } {

        proc update_${p} { $dependant_list } {
            set handle [set $parameter]
            set value [get_property default_value $handle ]
            set_property value $value $handle
        }
    } 0
}



set modelparams_qdrx [ list ADDR_WIDTH NUM_DEVICES BURST_LEN SPEED_GRADE MEM_DENSITY BANK_WIDTH MEMORY_TYPE MEM_DENSITY_MB MEM_DENSITY_GB DCI_CASCADE_CUTOFF COMP_DENSITY MEM_DEVICE_WIDTH DATABITS_PER_STROBE MEM_COMP_WIDTH CLKIN_PERIOD nCK_PER_CLK tCK MEM_READ_LATENCY IS_CUSTOM ]



        set IPINST {$IPINST}
        foreach p $modelparams_qdrx {
            set dependant_list {}
            tcl::lappend dependant_list MODELPARAM_VALUE.C0.QDRIIP_${p}
            set parameter MODELPARAM_VALUE.C0.QDRIIP_${p}
            EvalSubstituting {dependant_list cust_params parameter } {

                proc update_MODELPARAM_VALUE.C0.QDRIIP_${p} { $dependant_list $cust_params } {

                    set handle [set $parameter]
                    if { [get_property value ${PARAM_VALUE.C0.ControllerType}] == "None" } {
                        set value [get_property default_value $handle ]
                        set_property value $value $handle
                        return
                    }
                    array set cust [get_metaparam_value metaModelparams]
                    if {[info exists cust($parameter)]} {
                        set_property value $cust($parameter) $handle
                    } else  {
                    }
                }
            } 0
        }
   


proc qdrii_memory_part_details {IPINST PARAM_VALUE.C0.ControllerType PARAM_VALUE.C0.QDRIIP_MemoryPart MODELPARAM_VALUE.C0.QDRIIP_MEM_DENSITY MODELPARAM_VALUE.C0.QDRIIP_MEM_DEVICE_WIDTH MODELPARAM_VALUE.C0.QDRIIP_ADDR_WIDTH} {
	
	

		set  update_memorypart [list MEM_DENSITY MEM_DEVICE_WIDTH ADDR_WIDTH ]
		foreach p $update_memorypart {
			set parameter MODELPARAM_VALUE.C0.QDRIIP_${p}
			set handle [set $parameter]
			
			array set cust [get_metaparam_value metaModelparams]
			if {[info exists cust($parameter)]} {
				set [ string tolower $handle ] $cust($parameter)
			} else  {
			}
		}
		
		return "Memory Details: ${c0.qdriip_mem_density}, x${c0.qdriip_mem_device_width}, Address=${c0.qdriip_addr_width}"
	
}


proc update_gui_for_PARAM_VALUE.C0.ControllerType { IPINST PARAM_VALUE.C0.ControllerType   } {

    
		set_property visible true [ ipgui::get_panelspec "C0.QDRIIP.Controller" -of $IPINST ]
		
		set_property visible false [ ipgui::get_groupspec Mode_and_Interface -of $IPINST ]
		set_property visible true [ ipgui::get_pagespec "Advanced_Options" -of $IPINST ]
		set_property visible true [ ipgui::get_pagespec "I/O Planning and Design Checklist" -of $IPINST ]

    
}

proc validate_PARAM_VALUE.Phy_Only {PARAM_VALUE.Phy_Only PARAM_VALUE.C0.ControllerType } {
	return true
}
 proc update_PARAM_VALUE.C0.QDRIIP_MCS_ECC {PARAM_VALUE.C0.QDRIIP_MCS_ECC PROJECT_PARAM.PART} {
 	set_property enabled true ${PARAM_VALUE.C0.QDRIIP_MCS_ECC}
}
proc update_PARAM_VALUE.Phy_Only {PARAM_VALUE.Phy_Only PARAM_VALUE.C0.ControllerType} {
	set_property value "Complete_Memory_Controller" ${PARAM_VALUE.Phy_Only}
	set_property enabled false ${PARAM_VALUE.Phy_Only}  
}

proc update_PARAM_VALUE.Debug_Signal { PARAM_VALUE.Debug_Signal PARAM_VALUE.C0.ControllerType PARAM_VALUE.No_Controller} {

    if { [ get_property value ${PARAM_VALUE.No_Controller}  ] != 0 } {
       
            set_property enabled true ${PARAM_VALUE.Debug_Signal}
            set_property value Disable ${PARAM_VALUE.Debug_Signal}
        
    }
   
}


proc update_MODELPARAM_VALUE.CUSTOM_PART_ATTRIBUTES {IPINST MODELPARAM_VALUE.CUSTOM_PART_ATTRIBUTES  PARAM_VALUE.C0.ControllerType PARAM_VALUE.C0.QDRIIP_isCustom PARAM_VALUE.C0.QDRIIP_CustomParts PARAM_VALUE.C0.QDRIIP_MemoryPart PARAM_VALUE.Component_Name } {

 set memName [ get_property value ${PARAM_VALUE.C0.ControllerType} ] 
 set is_custom [ get_property value ${PARAM_VALUE.C0.QDRIIP_isCustom}] 
 set customPartCSVPath [ get_property value ${PARAM_VALUE.C0.QDRIIP_CustomParts}] 
 set memPartSel [ get_property value ${PARAM_VALUE.C0.QDRIIP_MemoryPart}]
 set instname [ ::ipgui::current_inst ]
 set absPath [ ipgui::get_absolute_path -ipinst $IPINST -path $customPartCSVPath ]
 set cust_part_string ""
 #send_msg INFO 34567 "is_custom $is_custom memPartSel $memPartSel"
 if {$is_custom} {
 set custom_part_attrib [memory::memory_v1::Ip_memory_retrieveCustomPartsData $absPath $memPartSel $memName $instname]
 

# send_msg INFO 45678 "custom_part_attrib $custom_part_attrib";
	while { [llength $custom_part_attrib] > 0 } {
		set custom_part_attrib [lassign $custom_part_attrib param value]
		append cust_part_string $param " "
		append cust_part_string $value
		append cust_part_string "$"
	}
	
	## CustomPart_ParamName Value $ CustomPart_AnotherParamName Value $
 #send_msg INFO 222 "cust_part_string $cust_part_string"
 } else {
 set cust_part_string "NONE"
 }
 set_property value $cust_part_string ${MODELPARAM_VALUE.CUSTOM_PART_ATTRIBUTES}
}


proc update_MODELPARAM_VALUE.C0.QDRIIP_tCK { MODELPARAM_VALUE.C0.QDRIIP_tCK PARAM_VALUE.C0.QDRIIP_TimePeriod } {
    set_property value [get_property value ${PARAM_VALUE.C0.QDRIIP_TimePeriod} ] ${MODELPARAM_VALUE.C0.QDRIIP_tCK}
}

proc update_MODELPARAM_VALUE.C0.QDRIIP_DATA_WIDTH { MODELPARAM_VALUE.C0.QDRIIP_DATA_WIDTH PARAM_VALUE.C0.QDRIIP_DataWidth } {
    set_property value [get_property value ${PARAM_VALUE.C0.QDRIIP_DataWidth} ] ${MODELPARAM_VALUE.C0.QDRIIP_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C0.QDRIIP_CLKIN_PERIOD { MODELPARAM_VALUE.C0.QDRIIP_CLKIN_PERIOD PARAM_VALUE.C0.QDRIIP_InputClockPeriod } {
    set_property value [get_property value ${PARAM_VALUE.C0.QDRIIP_InputClockPeriod} ] ${MODELPARAM_VALUE.C0.QDRIIP_CLKIN_PERIOD}
}

proc update_MODELPARAM_VALUE.C0.QDRIIP_NUM_DEVICES { MODELPARAM_VALUE.C0.QDRIIP_NUM_DEVICES MODELPARAM_VALUE.C0.QDRIIP_MEM_DEVICE_WIDTH PARAM_VALUE.C0.QDRIIP_DataWidth } {

    set dwidth [get_property value ${PARAM_VALUE.C0.QDRIIP_DataWidth} ]
    set deviceWidth [get_property value ${MODELPARAM_VALUE.C0.QDRIIP_MEM_DEVICE_WIDTH} ]
    if { $deviceWidth > 0 } {
        set value  [expr $dwidth/$deviceWidth]
        set_property value $value ${MODELPARAM_VALUE.C0.QDRIIP_NUM_DEVICES}
    }
}


proc update_MODELPARAM_VALUE.C0.QDRIIP_VrefVoltage { MODELPARAM_VALUE.C0.QDRIIP_VrefVoltage MODELPARAM_VALUE.C0.QDRIIP_MemoryVoltage } {
    set value [string trimright [ get_property value ${MODELPARAM_VALUE.C0.QDRIIP_MemoryVoltage} ] V ]
	set_property value [expr $value/2] ${MODELPARAM_VALUE.C0.QDRIIP_VrefVoltage}
}



# ##########################################
proc validate_PARAM_VALUE.C0.QDRIIP_MemoryName { PARAM_VALUE.C0.QDRIIP_MemoryName } {
    if { [get_property value ${PARAM_VALUE.C0.QDRIIP_MemoryName} ]  == "" } {
        return false
    }
    return true
}

proc validate_PARAM_VALUE.Component_name {PARAM_VALUE.Component_Name} {

  set compName [ get_property value ${PARAM_VALUE.Component_Name} ]
  if {[string match *_phy $compName]} {
		set_property errmsg "Component Name cannot end with \"_phy\" as there is a subcore instance with this name that causes design generation failure ." ${PARAM_VALUE.Component_Name}
        return false
 }
  return true
}

proc validate_PARAM_VALUE.C0.ControllerType { PARAM_VALUE.C0.ControllerType } {
    if { [get_property value ${PARAM_VALUE.C0.ControllerType}] == "QDRIIPLUS_SRAM" || [get_property value ${PARAM_VALUE.C0.ControllerType}] == "None" } {
        return true
    }
    return false
}


# ################################################## QDRIIP ################################################################################################
proc validate_PARAM_VALUE.C0.QDRIIP_MemoryPart { PARAM_VALUE.C0.QDRIIP_MemoryPart PARAM_VALUE.C0.QDRIIP_BurstLen PARAM_VALUE.C0.ControllerType PARAM_VALUE.C0.QDRIIP_TimePeriod } {

    
        set timePeriod [ get_property value ${PARAM_VALUE.C0.QDRIIP_TimePeriod} ]
        set ipName  [ ::ipgui::current_inst ]
        
        set paramList {}
        set datadir [ get_data_dir ]
        set fpgapart [ get_project_property PART ]
        lappend paramList -part $fpgapart
        lappend paramList -datadir $datadir
        lappend paramList C0.ControllerType [ get_property value ${PARAM_VALUE.C0.ControllerType} ]
        lappend paramList C0.QDRIIP_BurstLen [ get_property value ${PARAM_VALUE.C0.QDRIIP_BurstLen} ]
        lappend paramList C0.QDRIIP_TimePeriod [ get_property value ${PARAM_VALUE.C0.QDRIIP_TimePeriod} ]
		lappend paramList C0.QDRIIP_MemoryPart [ get_property value ${PARAM_VALUE.C0.QDRIIP_MemoryPart} ]
        
		# Get TimePeriod Min Max Range from timeperiods.csv
        set timePeriodMap [ memory::memory_v1::Ip_memory_getMinMaxPeriodOfMemoryPart "modelparam" -ip $ipName -type "mig" {*}$paramList ]    
         while { [llength $timePeriodMap] > 0 } {
             set timePeriodMap [ lassign $timePeriodMap param value ]
             if { $param == "tmin" } {
                 set mem_minPeriod $value
             } elseif { $param == "tmax" } {
                 set mem_maxPeriod $value
             }
         }
 
		# Get TimePeriod Min Max Range from memParts.csv
		set args [ list -part $fpgapart -tag $ipName -ip $ipName -version 1.3 -Controller 0 -datadir $datadir ]
		set design_timePeriodMap [ memory::memory_v1::Ip_memory_customize "TimePeriod" {*}$args ]
		
		while { [ llength $design_timePeriodMap ] > 0 } {
            set design_timePeriodMap [ lassign $design_timePeriodMap opt val  ]
            set opt [ string trimleft $opt - ]
            if { $opt == "range"} {
				set value1 [split $val ,]
                set desminValue [lindex  $value1 0]
				set desmaxValue [lindex  $value1 1]
				}
		}
		
		# Get the min and max periods from the above 2 timeperiod ranges
		set minmaxList {}
	   lappend minmaxList $mem_minPeriod
	   lappend minmaxList $mem_maxPeriod
	   lappend minmaxList $desminValue
	   lappend minmaxList $desmaxValue
	   lsort -increasing $minmaxList
	   
	   set minPeriod [lindex $minmaxList 0 ]
	   set maxPeriod [lindex $minmaxList 3 ]
	  
        if { $timePeriod >= $minPeriod && $timePeriod <= $maxPeriod } {
        } elseif {$minPeriod == "NA" || $maxPeriod == "NA"} {
		set_property errmsg "The FPGA board selected has slow speed for the selected configuration, please select a higher speed FPGA" ${PARAM_VALUE.C0.QDRIIP_MemoryPart}
		return false
    ####To fix for CR:965371, where FPGA max. period is lessthan the min. period of Memory part
    #Here:Min_period:Memory Part Min. period, Max_period:FPGA Max. Period
		} elseif {$minPeriod > $maxPeriod} {
            set_property errmsg "Selected memory part supported time period range is ($mem_minPeriod-$mem_maxPeriod) ps and FPGA supported time period range is ($desminValue-$desmaxValue) ps.Hence Selected Memory Part is not supported for this FPGA" ${PARAM_VALUE.C0.QDRIIP_MemoryPart}
            return false
    } else {
            set_property errmsg "Selected memory part is supported only for a memory device interface speed between $minPeriod and $maxPeriod" ${PARAM_VALUE.C0.QDRIIP_MemoryPart}
            return false
        }
   
    return true
}

proc validate_PARAM_VALUE.C0.QDRIIP_BurstLen { PARAM_VALUE.C0.QDRIIP_BurstLen PARAM_VALUE.C0.ControllerType PARAM_VALUE.C0.QDRIIP_TimePeriod } {

    
        set timePeriod [ get_property value ${PARAM_VALUE.C0.QDRIIP_TimePeriod} ]
        set ipName  [ ::ipgui::current_inst ]
        
        set paramList {}
        set datadir [ get_data_dir ]
        set fpgapart [ get_project_property PART ]
        lappend paramList -part $fpgapart
        lappend paramList -datadir $datadir
        lappend paramList C0.ControllerType [ get_property value ${PARAM_VALUE.C0.ControllerType} ]
        lappend paramList C0.QDRIIP_BurstLen [ get_property value ${PARAM_VALUE.C0.QDRIIP_BurstLen} ]
        lappend paramList C0.QDRIIP_TimePeriod [ get_property value ${PARAM_VALUE.C0.QDRIIP_TimePeriod} ]
        
        set timePeriodMap [ memory::memory_v1::Ip_memory_getMinMaxPeriodOfMemoryType "modelparam" -ip $ipName -type "mig" {*}$paramList ]    
        while { [llength $timePeriodMap] > 0 } {
            set timePeriodMap [ lassign $timePeriodMap param value ]
            if { $param == "tmin" } {
                set mem_minPeriod $value
            } elseif { $param == "tmax" } {
                set mem_maxPeriod $value
            }
        }
        
		# Get TimePeriod Min Max Range from memParts.csv
		set args [ list -part $fpgapart -tag $ipName -ip $ipName -version 1.3 -Controller 0 -datadir $datadir ]
		set design_timePeriodMap [ memory::memory_v1::Ip_memory_customize "TimePeriod" {*}$args ]
		
		while { [ llength $design_timePeriodMap ] > 0 } {
            set design_timePeriodMap [ lassign $design_timePeriodMap opt val  ]
            set opt [ string trimleft $opt - ]
            if { $opt == "range"} {
				set value1 [split $val ,]
                set desminValue [lindex  $value1 0]
				set desmaxValue [lindex  $value1 1]
			}
		}
		
		# Get the min and max periods from the above 2 timeperiod ranges
		set minmaxList {}
	   lappend minmaxList $mem_minPeriod
	   lappend minmaxList $mem_maxPeriod
	   lappend minmaxList $desminValue
	   lappend minmaxList $desmaxValue
	   lsort -increasing $minmaxList
	   
	   set minPeriod [lindex $minmaxList 0 ]
	   set maxPeriod [lindex $minmaxList 3 ]
	  
	  
        if { $timePeriod >= $minPeriod && $timePeriod <= $maxPeriod } {
        } elseif {$minPeriod == "NA" || $maxPeriod == "NA"} {
		set_property errmsg "The FPGA board selected has slow speed for the selected configuration, please select a higher speed FPGA" ${PARAM_VALUE.C0.QDRIIP_BurstLen}
		return false
		} else {
            set_property errmsg "Selected memory type is supported only for a memory device interface speed between $minPeriod and $maxPeriod" ${PARAM_VALUE.C0.QDRIIP_BurstLen}
            return false
        }
    
    return true
}



proc memx_sub { subName } {

 
        return "QDRIIPLUS_SRAM"
    
}

proc memx { memory } {

    
        return "qdriip"
    
}
#send_msg INFO 111 "procs called : [info procs]"
