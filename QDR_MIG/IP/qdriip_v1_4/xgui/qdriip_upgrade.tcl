#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

load librdi_iptasks[info sharedlibextension]

namespace eval qdriip_v1_4_utils {

    proc validate_upgrade_from_mig_v7_1 {xciValues} {
   
        namespace import ::xcoUpgradeLib::\*
        upvar $xciValues valueArray
      
        set controllerType [getParameter C0.ControllerType valueArray]
        if { ${controllerType} == "QDRIIPLUS_SRAM" } {
            return true
        }
        return false
    }
    
    proc validate_upgrade_from_mig_v7_0 {xciValues} {
   
        namespace import ::xcoUpgradeLib::\*
        upvar $xciValues valueArray
      
        set controllerType [getParameter C0.ControllerType valueArray]
        if { ${controllerType} == "QDRIIPLUS_SRAM" } {
            return true
        }
        return false
    }

    proc validate_upgrade_from_mig_v6_1 {xciValues} {
   
        namespace import ::xcoUpgradeLib::\*
        upvar $xciValues valueArray
      
        set controllerType [getParameter C0.ControllerType valueArray]
        if { ${controllerType} == "QDRIIPLUS_SRAM" } {
            return true
        }
        return false
    }

    proc validate_upgrade_from_mig_v6_0 {xciValues} {
   
        namespace import ::xcoUpgradeLib::\*
        upvar $xciValues valueArray
      
        set controllerType [getParameter C0.ControllerType valueArray]
        if { ${controllerType} == "QDRIIPLUS_SRAM" } {
            return true
        }
        return false
    }

    proc validate_upgrade_from_mig_v5_0 {xciValues} {
   
        namespace import ::xcoUpgradeLib::\*
        upvar $xciValues valueArray
      
        set controllerType [getParameter C0.ControllerType valueArray]
        if { ${controllerType} == "QDRIIPLUS_SRAM" } {
            return true
        }
        return false
    }

    proc validate_upgrade_from_mig_v4_2 {xciValues} {
   
        namespace import ::xcoUpgradeLib::\*
        upvar $xciValues valueArray
      
        set controllerType [getParameter C0.ControllerType valueArray]
        if { ${controllerType} == "QDRIIPLUS_SRAM" } {
            return true
        }
        return false
    }

    proc validate_upgrade_from_mig_v4_1 {xciValues} {
   
        namespace import ::xcoUpgradeLib::\*
        upvar $xciValues valueArray
      
        set controllerType [getParameter C0.ControllerType valueArray]
        if { ${controllerType} == "QDRIIPLUS_SRAM" } {
            return true
        }
        return false
    }

    proc validate_upgrade_from_mig_v4_0 {xciValues} {
   
        namespace import ::xcoUpgradeLib::\*
        upvar $xciValues valueArray
      
        set controllerType [getParameter C0.ControllerType valueArray]
        if { ${controllerType} == "QDRIIPLUS_SRAM" } {
            return true
        }
        return false
    }
	
    proc get_data_dir { } {
         set subcore_vlnv "xilinx.com:ip:mem:1.4"
         set property_name "absolute_path"
         set file_name "csv/time_periods.csv"
         set file_path [ xit::get_ipfile_property -vlnv $subcore_vlnv -ipfile $file_name -property $property_name -of [xit::current_scope] ]
         set file_path [string map {"/time_periods.csv" ""} $file_path]
         return $file_path
    }	
   
    proc verify_isResetRequired {xciValues} {
        upvar $xciValues valueArray
        set retVal [ check_before_upgrade valueArray ]
        ## retVal 2 indicates that part is mismatched, hence going for the defaults of the Memory Controller selected
        if { $retVal == 2 } {         
            foreach {key value} [array get valueArray] {
                if {[string match -nocase "*C0.ControllerType*" $key]} {
                } else {
                    set key [string map {parameter:  ""} $key]
                    removeParameter $key valueArray
                }
            }
        
            set cntrl_type [getParameter C0.ControllerType valueArray]
            send_msg INFO 2 "Resetting to default configuration of $cntrl_type."
            return 2
        }

        ## retVal 3 indicates the controller type set to NONE, hence defaulting to DDR4_SDRAM interface
        if { $retVal == 3 } {
            foreach {key value} [array get valueArray] {
                    set key [string map {parameter:  ""} $key]
                    removeParameter $key valueArray
            }       
            setParameter C0.ControllerType "DDR4_SDRAM" valueArray 
            send_msg INFO 2 "Resetting to default configuration of DDR4_SDRAM."
            return 3
        }
    }
  
proc closest {value list} {
		set minElement [lindex $list 0]
		set minDist [expr {abs($value-$minElement)}]
		foreach i [lrange $list 1 end] {	
			if {abs($value-$i) < $minDist} {
				set minDist [expr {abs($value-$i)}]
				set minElement $i	   
			}
		}
		return $minElement
}

proc getMMCMClockList1 { InputClkfreq  divClk_div clkFBOut_mult} {

    
    set clockList {}    

    if { [info exists InputClkfreq ] && [info exists divClk_div ]  && [info exists clkFBOut_mult ] } {
        set clkout 10
        set i 1
        while { $i<139 } {
            set clkout [expr { round([ expr (1.0 * 1000000 * $clkFBOut_mult / ($divClk_div * $i * $InputClkfreq)) ])} ]
            set clkout_divide [expr int([ expr (1.0 * 1000000 * $clkFBOut_mult / ($divClk_div * $clkout * $InputClkfreq)) ]) ]
            # Added the new check CLKOUT*_DIVIDE should be within the 1-128 limit as per the UltraScale MMCM Clocking guidelines (CR# 820754)
            if { $clkout >= 10 && $clkout <= 600 && $clkout_divide >= 1 && $clkout_divide <= 128 } {
                tcl::lappend clockList $clkout
            }
            set i [ expr {$i + 1} ]
        }
    }
    set cList [ lsort -real -decreasing -unique $clockList ]

    set clockList1 {}  
	#tcl::lappend clockList1 "None" ; None is not permitted while comparision . So setting default value 900; (we are comparing values in closest proc) 	
    tcl::lappend clockList1 900
    foreach item $cList {
        tcl::lappend clockList1 ","
        tcl::lappend clockList1 $item
    }

    return $clockList1;
}	


	proc upgrade_from_qdriip_v1_2 {xciValues} {
        namespace import ::xcoUpgradeLib::\*
        upvar $xciValues valueArray
		
		set add_ui_clk1 [getParameter ADDN_UI_CLKOUT1_FREQ_HZ valueArray]
		set add_ui_clk2 [getParameter ADDN_UI_CLKOUT2_FREQ_HZ valueArray]
		set add_ui_clk3 [getParameter ADDN_UI_CLKOUT3_FREQ_HZ valueArray]
		set add_ui_clk4 [getParameter ADDN_UI_CLKOUT4_FREQ_HZ valueArray]
		
		
		if {$add_ui_clk1 != "None" || $add_ui_clk2 != "None" || $add_ui_clk3 != "None" ||  $add_ui_clk4 != "None"} {
		
		set check 0
		set freq 800
		set divclk_div 1
		set clkfbout_mult 1

	
		if { [getParameter C0.ControllerType valueArray] == "QDRIIPLUS_SRAM" } {
			set freq [expr [getParameter C0.QDRIIP_InputClockPeriod valueArray]]
			if {[getModelParameter C0.QDRIIP_DIVCLK_DIVIDE valueArray] == "" || [getModelParameter C0.QDRIIP_CLKFBOUT_MULT valueArray ] == ""} {
				return ;        
			} else {
				set divclk_div [expr int([getModelParameter C0.QDRIIP_DIVCLK_DIVIDE valueArray])]
				set clkfbout_mult [expr int([getModelParameter C0.QDRIIP_CLKFBOUT_MULT valueArray ])]
			}
			set check 1
		} 

		
		if { $check == 1 } {
			set new_list [getMMCMClockList1 $freq  $divclk_div $clkfbout_mult]
		} else {
			set new_list "None"
		}
		set created_list {}
		set created_list [regsub -all "," $new_list " "]
		
		
		if {$add_ui_clk1 != "None"} {
			set new_val [closest $add_ui_clk1 $created_list]
      if {$add_ui_clk1 != $new_val} {
			  send_msg INFO 2 "Unable to set the value $add_ui_clk1 on parameter ADDN UI CLKOUT1 FREQ HZ.Restoring to the closest possible value $new_val"
			  setParameter ADDN_UI_CLKOUT1_FREQ_HZ "$new_val" valueArray
      }
		}
		
		
		
		if {$add_ui_clk2 != "None"} {
			set new_val [closest $add_ui_clk2 $created_list]
      if {$add_ui_clk2 != $new_val} {
			  send_msg INFO 2 "Unable to set the value $add_ui_clk2 on parameter ADDN UI CLKOUT2 FREQ HZ.Restoring to the closest possible value $new_val"
			  setParameter ADDN_UI_CLKOUT2_FREQ_HZ "$new_val" valueArray
      }
		}
		
		
		if {$add_ui_clk3 != "None"} {
			set new_val [closest $add_ui_clk3 $created_list]
      if {$add_ui_clk3 != $new_val} {
			  send_msg INFO 2 "Unable to set the value $add_ui_clk3 on parameter ADDN UI CLKOUT3 FREQ HZ.Restoring to the closest possible value $new_val"
			  setParameter ADDN_UI_CLKOUT3_FREQ_HZ "$new_val" valueArray
      }
		}
		
		
		if {$add_ui_clk4 != "None"} {
			set new_val [closest $add_ui_clk4 $created_list]
      if {$add_ui_clk4 != $new_val} {
			  send_msg INFO 2 "Unable to set the value $add_ui_clk4 on parameter ADDN UI CLKOUT4 FREQ HZ.Restoring to the closest possible value $new_val"
			  setParameter ADDN_UI_CLKOUT4_FREQ_HZ "$new_val" valueArray
      }
		}
		}
		
		
	namespace forget ::xcoUpgradeLib::\*
	
    } 
	
	
  
	proc upgrade_from_qdriip_v1_1 {xciValues} {
        namespace import ::xcoUpgradeLib::\*
        upvar $xciValues valueArray
		
		set add_ui_clk1 [getParameter ADDN_UI_CLKOUT1_FREQ_HZ valueArray]
		set add_ui_clk2 [getParameter ADDN_UI_CLKOUT2_FREQ_HZ valueArray]
		set add_ui_clk3 [getParameter ADDN_UI_CLKOUT3_FREQ_HZ valueArray]
		set add_ui_clk4 [getParameter ADDN_UI_CLKOUT4_FREQ_HZ valueArray]
		
		
		if {$add_ui_clk1 != "None" || $add_ui_clk2 != "None" || $add_ui_clk3 != "None" ||  $add_ui_clk4 != "None"} {
		
		set check 0
		set freq 800
		set divclk_div 1
		set clkfbout_mult 1

	
		if { [getParameter C0.ControllerType valueArray] == "QDRIIPLUS_SRAM" } {
			set freq [expr [getParameter C0.QDRIIP_InputClockPeriod valueArray]]
			if {[getModelParameter C0.QDRIIP_DIVCLK_DIVIDE valueArray] == "" || [getModelParameter C0.QDRIIP_CLKFBOUT_MULT valueArray ] == ""} {
				return ;        
			} else {
				set divclk_div [expr int([getModelParameter C0.QDRIIP_DIVCLK_DIVIDE valueArray])]
				set clkfbout_mult [expr int([getModelParameter C0.QDRIIP_CLKFBOUT_MULT valueArray ])]
			}
			set check 1
		} 

		
		if { $check == 1 } {
			set new_list [getMMCMClockList1 $freq  $divclk_div $clkfbout_mult]
		} else {
			set new_list "None"
		}
		set created_list {}
		set created_list [regsub -all "," $new_list " "]
		
		
		if {$add_ui_clk1 != "None"} {
			set new_val [closest $add_ui_clk1 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk1 on parameter ADDN UI CLKOUT1 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT1_FREQ_HZ "$new_val" valueArray
		}
		
		
		
		if {$add_ui_clk2 != "None"} {
			set new_val [closest $add_ui_clk2 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk2 on parameter ADDN UI CLKOUT2 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT2_FREQ_HZ "$new_val" valueArray
		}
		
		
		if {$add_ui_clk3 != "None"} {
			set new_val [closest $add_ui_clk3 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk3 on parameter ADDN UI CLKOUT3 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT3_FREQ_HZ "$new_val" valueArray
		}
		
		
		if {$add_ui_clk4 != "None"} {
			set new_val [closest $add_ui_clk4 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk4 on parameter ADDN UI CLKOUT4 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT4_FREQ_HZ "$new_val" valueArray
		}
		}
		
		
	namespace forget ::xcoUpgradeLib::\*
	
    } 
	
    proc upgrade_from_qdriip_v1_0 {xciValues} {
        namespace import ::xcoUpgradeLib::\*
        upvar $xciValues valueArray
		
		set add_ui_clk1 [getParameter ADDN_UI_CLKOUT1_FREQ_HZ valueArray]
		set add_ui_clk2 [getParameter ADDN_UI_CLKOUT2_FREQ_HZ valueArray]
		set add_ui_clk3 [getParameter ADDN_UI_CLKOUT3_FREQ_HZ valueArray]
		set add_ui_clk4 [getParameter ADDN_UI_CLKOUT4_FREQ_HZ valueArray]
		
		
		if {$add_ui_clk1 != "None" || $add_ui_clk2 != "None" || $add_ui_clk3 != "None" ||  $add_ui_clk4 != "None"} {
		
		set check 0
		set freq 800
		set divclk_div 1
		set clkfbout_mult 1

	
		if { [getParameter C0.ControllerType valueArray] == "QDRIIPLUS_SRAM" } {
			set freq [expr [getParameter C0.QDRIIP_InputClockPeriod valueArray]]
			if {[getModelParameter C0.QDRIIP_DIVCLK_DIVIDE valueArray] == "" || [getModelParameter C0.QDRIIP_CLKFBOUT_MULT valueArray ] == ""} {
				return ;        
			} else {
				set divclk_div [expr int([getModelParameter C0.QDRIIP_DIVCLK_DIVIDE valueArray])]
				set clkfbout_mult [expr int([getModelParameter C0.QDRIIP_CLKFBOUT_MULT valueArray ])]
			}
			set check 1
		} 

		
		if { $check == 1 } {
			set new_list [getMMCMClockList1 $freq  $divclk_div $clkfbout_mult]
			#send_msg INFO 5 "new_list $new_list"
		} else {
			set new_list "None"
		}
		set created_list {}
		set created_list [regsub -all "," $new_list " "]
		
		
		if {$add_ui_clk1 != "None"} {
			set new_val [closest $add_ui_clk1 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk1 on parameter ADDN UI CLKOUT1 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT1_FREQ_HZ "$new_val" valueArray
		}
		
		
		
		if {$add_ui_clk2 != "None"} {
			set new_val [closest $add_ui_clk2 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk2 on parameter ADDN UI CLKOUT2 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT2_FREQ_HZ "$new_val" valueArray
		}
		
		
		if {$add_ui_clk3 != "None"} {
			set new_val [closest $add_ui_clk3 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk3 on parameter ADDN UI CLKOUT3 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT3_FREQ_HZ "$new_val" valueArray
		}
		
		
		if {$add_ui_clk4 != "None"} {
			set new_val [closest $add_ui_clk4 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk4 on parameter ADDN UI CLKOUT4 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT4_FREQ_HZ "$new_val" valueArray
		}
		}
		
		
	namespace forget ::xcoUpgradeLib::\*
	
    } 
 
    proc upgrade_from_mig_v7_1 {xciValues} {
        namespace import ::xcoUpgradeLib::\*
        upvar $xciValues valueArray
        set return_value [verify_isResetRequired valueArray]
        if { $return_value == 2 || $return_value == 3 } {
            namespace forget ::xcoUpgradeLib::\*
            return;
        }
		
		set add_ui_clk1 [getParameter ADDN_UI_CLKOUT1_FREQ_HZ valueArray]
		set add_ui_clk2 [getParameter ADDN_UI_CLKOUT2_FREQ_HZ valueArray]
		set add_ui_clk3 [getParameter ADDN_UI_CLKOUT3_FREQ_HZ valueArray]
		set add_ui_clk4 [getParameter ADDN_UI_CLKOUT4_FREQ_HZ valueArray]
		
		
		if {$add_ui_clk1 != "None" || $add_ui_clk2 != "None" || $add_ui_clk3 != "None" ||  $add_ui_clk4 != "None"} {
		
		set check 0
		set freq 800
		set divclk_div 1
		set clkfbout_mult 1

	
		if { [getParameter C0.ControllerType valueArray] == "QDRIIPLUS_SRAM" } {
			set freq [expr [getParameter C0.QDRIIP_InputClockPeriod valueArray]]
			if {[getModelParameter C0.QDRIIP_DIVCLK_DIVIDE valueArray] == "" || [getModelParameter C0.QDRIIP_CLKFBOUT_MULT valueArray ] == ""} {
				return ;        
			} else {
				set divclk_div [expr int([getModelParameter C0.QDRIIP_DIVCLK_DIVIDE valueArray])]
				set clkfbout_mult [expr int([getModelParameter C0.QDRIIP_CLKFBOUT_MULT valueArray ])]
			}
			set check 1
		} 

		
		if { $check == 1 } {
			set new_list [getMMCMClockList1 $freq  $divclk_div $clkfbout_mult]
			send_msg INFO 5 "new_list $new_list"
		} else {
			set new_list "None"
		}
		set created_list {}
		set created_list [regsub -all "," $new_list " "]
		
		
		if {$add_ui_clk1 != "None"} {
			set new_val [closest $add_ui_clk1 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk1 on parameter ADDN UI CLKOUT1 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT1_FREQ_HZ "$new_val" valueArray
		}
		
		
		
		if {$add_ui_clk2 != "None"} {
			set new_val [closest $add_ui_clk2 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk2 on parameter ADDN UI CLKOUT2 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT2_FREQ_HZ "$new_val" valueArray
		}
		
		
		if {$add_ui_clk3 != "None"} {
			set new_val [closest $add_ui_clk3 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk3 on parameter ADDN UI CLKOUT3 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT3_FREQ_HZ "$new_val" valueArray
		}
		
		
		if {$add_ui_clk4 != "None"} {
			set new_val [closest $add_ui_clk4 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk4 on parameter ADDN UI CLKOUT4 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT4_FREQ_HZ "$new_val" valueArray
		}
		}
		
        removeParameter Enable_Phy_Only valueArray     
        addParameter Phy_Only "Complete_Memory_Controller" valueArray
		addParameter Internal_Vref true valueArray
        namespace forget ::xcoUpgradeLib::\*
    }

   proc upgrade_from_mig_v4_1 {xciValues} {
      namespace import ::xcoUpgradeLib::\*
      upvar $xciValues valueArray

      removeParameter C0.DDR3_IsAXI valueArray
      removeParameter C0.DDR4_IsAXI valueArray

      removeParameter C0.Bank valueArray  
      removeParameter XADC valueArray  
      removeParameter Sample_Data_Width valueArray
      removeParameter C0.DDR4_CasWriteLatency valueArray
      removeParameter C0.DDR4_CasLatency valueArray
      removeParameter C0.DDR4_InputClockPeriod valueArray

      removeParameter C0.DDR3_AxiAddressWidth valueArray
      removeParameter C0.DDR4_AxiAddressWidth valueArray
      
      removeParameter C0.DDR3_OnDieTermination valueArray

      for { set l 0 } { $l < 4 } { incr l } {
            addParameter c0_ck_c_${l} NONE valueArray
        }
      for { set l 0 } { $l < 4 } { incr l } {
            addParameter c0_ck_t_${l} NONE valueArray
        }
      
	  
	  
      set mem_part [getParameter C0.DDR4_MemoryPart valueArray]
      set new_part [get_new_mem_part $mem_part] 
        if { $new_part != "Not_changed"} {
         setParameter C0.DDR4_MemoryPart $new_part valueArray
         send_msg INFO 1 "MemoryPart $mem_part is now renamed to $new_part \n"
        }

      set mempart2 [ getParameter C0.RLD3_MemoryPart valueArray]
      if { [getParameter C0.ControllerType valueArray] == "RLDRAM3" && [ string match "*MT44K16M36RB*" $mempart2] } {
        setParameter C0.RLD3_BurstLength "4" valueArray
        send_msg INFO 2 "MemoryPart $mempart2 does not support Burst Length 8. Setting Value 4 \n"
        }   
      set ck_c [getParameter c0_ck_c valueArray]
      set ck_t [getParameter c0_ck_t valueArray]
      
      setParameter c0_ck_c_0 $ck_c valueArray
      setParameter c0_ck_t_0 $ck_t valueArray
      if { [getParameter C0.ControllerType valueArray] == "RLDRAM3" } {
        setParameter c0_ck_p [getParameter c0_ck_p_0 valueArray] valueArray
        setParameter c0_ck_n [getParameter c0_ck_n_0 valueArray] valueArray
        setParameter c0_ck_p_0 "NONE" valueArray
        setParameter c0_ck_n_0 "NONE" valueArray
      }
      removeParameter c0_par valueArray
      removeParameter c0_ck_c valueArray
      removeParameter c0_ck_t valueArray
      send_msg INFO 2 "Default simulation is made as BFM which uses behavioral models for XiPhy libraries. \n In order to use Unisims for XiPhy libraries, regenerate the design with Simulation Mode option value as Unisim. \n"
      namespace forget ::xcoUpgradeLib::\*
      return
   }
   
   proc upgrade_from_mig_v4_2 {xciValues} {
      namespace import ::xcoUpgradeLib::\*
      upvar $xciValues valueArray

      removeParameter C0.DDR3_IsAXI valueArray
      removeParameter C0.DDR4_IsAXI valueArray

      removeParameter C0.Bank valueArray  
      removeParameter XADC valueArray  
      removeParameter Sample_Data_Width valueArray  

      removeParameter C0.DDR3_AxiAddressWidth valueArray
      removeParameter C0.DDR4_AxiAddressWidth valueArray
      
      removeParameter C0.DDR3_OnDieTermination valueArray

      for { set l 0 } { $l < 4 } { incr l } {
            addParameter c0_ck_c_${l} NONE valueArray
        }
      for { set l 0 } { $l < 4 } { incr l } {
            addParameter c0_ck_t_${l} NONE valueArray
        }
      
      set mem_part [getParameter C0.DDR4_MemoryPart valueArray]
      set new_part [get_new_mem_part $mem_part] 
        if { $new_part != "Not_changed"} {
         setParameter C0.DDR4_MemoryPart $new_part valueArray
         send_msg INFO 1 "MemoryPart $mem_part is now renamed to $new_part \n"
        }

      set mempart2 [ getParameter C0.RLD3_MemoryPart valueArray]
      if { [getParameter C0.ControllerType valueArray] == "RLDRAM3" && [ string match "*MT44K16M36RB*" $mempart2] } {
        setParameter C0.RLD3_BurstLength "4" valueArray
        send_msg INFO 2 "MemoryPart $mempart2 does not support Burst Length 8. Setting Value 4 \n"
        }   
      set ck_c [getParameter c0_ck_c valueArray]
      set ck_t [getParameter c0_ck_t valueArray]
      
      setParameter c0_ck_c_0 $ck_c valueArray
      setParameter c0_ck_t_0 $ck_t valueArray
      if { [getParameter C0.ControllerType valueArray] == "RLDRAM3" } {
        setParameter c0_ck_p [getParameter c0_ck_p_0 valueArray] valueArray
        setParameter c0_ck_n [getParameter c0_ck_n_0 valueArray] valueArray
        setParameter c0_ck_p_0 "NONE" valueArray
        setParameter c0_ck_n_0 "NONE" valueArray
      }
      removeParameter c0_par valueArray
      removeParameter c0_ck_c valueArray
      removeParameter c0_ck_t valueArray
      send_msg INFO 2 "Default simulation is made as BFM which uses behavioral models for XiPhy libraries. \n In order to use Unisims for XiPhy libraries, regenerate the design with Simulation Mode option value as Unisim. \n"
      namespace forget ::xcoUpgradeLib::\*
      return
   }

   proc upgrade_from_mig_v5_0 {xciValues} {
      namespace import ::xcoUpgradeLib::\*
      upvar $xciValues valueArray
      set return_value [verify_isResetRequired valueArray]
      if { $return_value == 2 || $return_value == 3 } {
            namespace forget ::xcoUpgradeLib::\*
            return;
      }

      removeParameter C0.DDR3_OnDieTermination valueArray
      
      for { set l 0 } { $l < 4 } { incr l } {
            addParameter c0_ck_c_${l} NONE valueArray
        }
      for { set l 0 } { $l < 4 } { incr l } {
            addParameter c0_ck_t_${l} NONE valueArray
        }
      
	  set add_ui_clk1 [getParameter ADDN_UI_CLKOUT1_FREQ_HZ valueArray]
		set add_ui_clk2 [getParameter ADDN_UI_CLKOUT2_FREQ_HZ valueArray]
		set add_ui_clk3 [getParameter ADDN_UI_CLKOUT3_FREQ_HZ valueArray]
		set add_ui_clk4 [getParameter ADDN_UI_CLKOUT4_FREQ_HZ valueArray]
		
		
		if {$add_ui_clk1 != "None" || $add_ui_clk2 != "None" || $add_ui_clk3 != "None" ||  $add_ui_clk4 != "None"} {
		
		set check 0
		set freq 800
		set divclk_div 1
		set clkfbout_mult 1

	
		if { [getParameter C0.ControllerType valueArray] == "QDRIIPLUS_SRAM" } {
			set freq [expr [getParameter C0.QDRIIP_InputClockPeriod valueArray]]
			if {[getModelParameter C0.QDRIIP_DIVCLK_DIVIDE valueArray] == "" || [getModelParameter C0.QDRIIP_CLKFBOUT_MULT valueArray ] == ""} {
				return ;        
			} else {
				set divclk_div [expr int([getModelParameter C0.QDRIIP_DIVCLK_DIVIDE valueArray])]
				set clkfbout_mult [expr int([getModelParameter C0.QDRIIP_CLKFBOUT_MULT valueArray ])]
			}
			set check 1
		} 

		
		if { $check == 1 } {
			set new_list [getMMCMClockList1 $freq  $divclk_div $clkfbout_mult]
			send_msg INFO 5 "new_list $new_list"
		} else {
			set new_list "None"
		}
		set created_list {}
		set created_list [regsub -all "," $new_list " "]
		
		
		if {$add_ui_clk1 != "None"} {
			set new_val [closest $add_ui_clk1 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk1 on parameter ADDN UI CLKOUT1 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT1_FREQ_HZ "$new_val" valueArray
		}
		
		
		
		if {$add_ui_clk2 != "None"} {
			set new_val [closest $add_ui_clk2 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk2 on parameter ADDN UI CLKOUT2 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT2_FREQ_HZ "$new_val" valueArray
		}
		
		
		if {$add_ui_clk3 != "None"} {
			set new_val [closest $add_ui_clk3 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk3 on parameter ADDN UI CLKOUT3 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT3_FREQ_HZ "$new_val" valueArray
		}
		
		
		if {$add_ui_clk4 != "None"} {
			set new_val [closest $add_ui_clk4 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk4 on parameter ADDN UI CLKOUT4 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT4_FREQ_HZ "$new_val" valueArray
		}
		}
		
      set mem_part [getParameter C0.DDR4_MemoryPart valueArray]
      set new_part [get_new_mem_part $mem_part] 
        if { $new_part != "Not_changed"} {
         setParameter C0.DDR4_MemoryPart $new_part valueArray
         send_msg INFO 1 "MemoryPart $mem_part is now renamed to $new_part \n"
        }

      set mempart2 [ getParameter C0.RLD3_MemoryPart valueArray]
      if { [getParameter C0.ControllerType valueArray] == "RLDRAM3" && [ string match "*MT44K16M36RB*" $mempart2] } {
        setParameter C0.RLD3_BurstLength "4" valueArray
        send_msg INFO 2 "MemoryPart $mempart2 does not support Burst Length 8. Setting Value 4 \n"
        }   
      set ck_c [getParameter c0_ck_c valueArray]
      set ck_t [getParameter c0_ck_t valueArray]
      setParameter c0_ck_c_0 $ck_c valueArray
      setParameter c0_ck_t_0 $ck_t valueArray
      if { [getParameter C0.ControllerType valueArray] == "RLDRAM3" } {
        setParameter c0_ck_p [getParameter c0_ck_p_0 valueArray] valueArray
        setParameter c0_ck_n [getParameter c0_ck_n_0 valueArray] valueArray
        setParameter c0_ck_p_0 "NONE" valueArray
        setParameter c0_ck_n_0 "NONE" valueArray
      }
      removeParameter c0_par valueArray
      removeParameter c0_ck_c valueArray
      removeParameter c0_ck_t valueArray
      
      set datadir [get_data_dir]
      if { [ file exists $datadir ] == 0 } {
            send_msg "ERROR" 2000 "IP Component directory path ($datadir) mentioned is not valid. Please provide valid IP Dir path"
      }
      
      data_width_change valueArray $datadir
      xdc_dump valueArray $datadir 
      send_msg INFO 2 "Default simulation is made as BFM which uses behavioral models for XiPhy libraries. \n In order to use Unisims for XiPhy libraries, regenerate the design with Simulation Mode option value as Unisim. \n"
      if { [getParameter C0.ControllerType valueArray] == "DDR4_SDRAM" && [ string tolower [ getParameter C0.DDR4_AxiSelection valueArray] ] == "false" } {
            addParameter C0.DDR4_AutoPrecharge "true" valueArray
        }
      if { [getParameter C0.ControllerType valueArray] == "DDR3_SDRAM" && [ string tolower [ getParameter C0.DDR3_AxiSelection valueArray] ] == "false" } {
            addParameter C0.DDR3_AutoPrecharge "true" valueArray
        }
        
      namespace forget ::xcoUpgradeLib::\*
   }
# ################################### Upgrade proc from 2014.4 ############################
    proc memx { controller xciValues } {
        
        upvar $xciValues valueArray
        switch -glob [ getParameter C${controller}.ControllerType valueArray] {
            *QDR*  { return qdriip }
            *RLD*  { return rld3 }
            *DDR4* { return ddr4 }
            *DDR3*  { return ddr3 }
        }
        return "none"
    }

    proc get_custArray { xciValues } {
        upvar $xciValues valueArray
        set cust_params {}
        foreach c { 0 } {
            set memTypes [ string toupper [memx $c valueArray] ]
            foreach memType $memTypes {
                tcl::lappend cust_params C${c}.${memType}_TimePeriod
                tcl::lappend cust_params C${c}.${memType}_InputClockPeriod
                tcl::lappend cust_params C${c}.${memType}_MemoryType
                tcl::lappend cust_params C${c}.${memType}_MemoryPart
                tcl::lappend cust_params C${c}.${memType}_DataWidth
                tcl::lappend cust_params C${c}.ControllerType
                tcl::lappend cust_params C${c}.${memType}_MemoryName
                
                if { $memType == "DDR3" || $memType == "DDR4" || $memType == "RLD3"} {                
                    tcl::lappend cust_params C${c}.${memType}_DataMask
                    tcl::lappend cust_params C${c}.${memType}_PhyClockRatio
                    tcl::lappend cust_params C${c}.${memType}_BurstLength
                    tcl::lappend cust_params C${c}.${memType}_MemoryVoltage
                } else {
                tcl::lappend cust_params C${c}.${memType}_BurstLen
                }
                
                if { $memType == "DDR3" || $memType == "DDR4" } {
                    tcl::lappend cust_params C${c}.${memType}_Ordering
                    tcl::lappend cust_params C${c}.${memType}_CasLatency
                    tcl::lappend cust_params C${c}.${memType}_CasWriteLatency
                    tcl::lappend cust_params C${c}.${memType}_OnDieTermination
                    tcl::lappend cust_params C${c}.${memType}_ChipSelect
                    tcl::lappend cust_params C${c}.${memType}_AxiSelection
                    tcl::lappend cust_params C${c}.${memType}_Mem_Add_Map
                    tcl::lappend cust_params C${c}.${memType}_AxiDataWidth
                    tcl::lappend cust_params C${c}.${memType}_AxiArbitrationScheme
                    tcl::lappend cust_params C${c}.${memType}_AxiIDWidth
                    tcl::lappend cust_params C${c}.${memType}_AxiAddressWidth
                    tcl::lappend cust_params C${c}.${memType}_AxiNarrowBurst
                    tcl::lappend cust_params Phy_Only
                }
            }
        }
        tcl::lappend cust_params No_Controller
        tcl::lappend cust_params Default_Bank_Selections

        set hlist "$cust_params"
        array set custArray {}
        while { [llength   $hlist] > 0 } {
            set hlist [ lassign $hlist param]
            set param_handle $param
            set custArray($param_handle) [getParameter $param_handle valueArray]
        }
        return [array get custArray ]
    }
    
    proc setInstanceAllParamList { xciValues datadir } {
        upvar $xciValues valueArray
    
        set paramList {}
        array set cust [get_custArray valueArray]
        foreach {key value} [array get cust] {
            lappend paramList $key $value
        }
    
        set fpgapart  [ipxit::get_project_property PART ]
        lappend paramList -part $fpgapart
        lappend paramList -datadir $datadir
        return $paramList
    }
    
    proc LoadPinInfo { xciValues } {

        upvar $xciValues valueArray
        set InstName [getParameter Component_Name valueArray]
        set memname [ string tolower [getParameter C0.ControllerType valueArray] ]
        set MemPart [getParameter C0.[string toupper [memx 0 valueArray]]_MemoryPart valueArray]
        set bitsPerStrobe [ memory_v1_Ip_memory_getDataBitsPerStrobe $InstName $memname $MemPart ]
        memory_v1_Ip_memory_setDataBitsPerStrobe $bitsPerStrobe $InstName
        foreach c  { 0 } {

            for { set l 0 } { $l < 144 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_dq_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_dq[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                            memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 72 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_d_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_d[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 72 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_q_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_q[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 22 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_adr_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_adr[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {   
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 22 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_addr_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_addr[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {   
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 22 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_a_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_a[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 22 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_sa_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_sa[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 36 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_dm_dbi_n_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_dm_dbi_n[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 36 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_dm_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_dm[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }   
            }

            for { set l 0 } { $l < 36 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_dqs_c_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_dqs_c[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 36 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_dqs_t_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_dqs_t[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 36 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_dqs_p_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_dqs_p[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 36 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_dqs_n_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_dqs_n[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 4 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_ba_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_ba[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 4 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_k_p_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_k_p[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 4 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_k_n_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_k_n[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 4 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_cq_n_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_cq_n[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {               
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 4 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_cq_p_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_cq_p[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 4 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_bw_n_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_bw_n[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 3 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_bg_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_bg[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 4 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_cke_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_cke[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 4 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_ck_p_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_ck_p[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 4 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_ck_n_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_ck_n[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }
            
            for { set l 0 } { $l < 4 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_ck_t_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_ck_t[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }
            
            for { set l 0 } { $l < 4 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_ck_c_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_ck_c[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }         

            for { set l 0 } { $l < 4 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_cs_n_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_cs_n[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 4 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_odt_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_odt[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }                   
                }
            }

            for { set l 0 } { $l < 8 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_qk_p_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_qk_p[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 8 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_qk_n_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_qk_n[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 8 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_dk_p_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_dk_p[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 8 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_dk_n_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_dk_n[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            for { set l 0 } { $l < 4 } { incr l } {
                set bank_byte_pin [ getParameter c${c}_qvld_${l} valueArray ]
                set portstring c${c}_[memx $c valueArray]_qvld[${l}]
                if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                    if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                        memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                    }
                }
            }

            set bank_byte_pin [ getParameter c${c}_ref_n valueArray ]
            set portstring c${c}_[memx $c valueArray]_ref_n
            if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                    memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                }
            }

            set bank_byte_pin [ getParameter c${c}_cs_n valueArray ]
            set portstring c${c}_[memx $c valueArray]_cs_n
            if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                    memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                }
            }

            set bank_byte_pin [ getParameter c${c}_reset_n valueArray ]
            set portstring c${c}_[memx $c valueArray]_reset_n
            if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                    memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                }
            }

            set bank_byte_pin [ getParameter c${c}_act_n valueArray ]
            set portstring c${c}_[memx $c valueArray]_act_n
            if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                    memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                }
            }

            set bank_byte_pin [ getParameter c${c}_cas_n valueArray ]
            set portstring c${c}_[memx $c valueArray]_cas_n
            if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                    memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                }
            }

            set bank_byte_pin [ getParameter c${c}_ras_n valueArray ]
            set portstring c${c}_[memx $c valueArray]_ras_n
            if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                    memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                }
            }

            set bank_byte_pin [ getParameter c${c}_we_n valueArray ]
            set portstring c${c}_[memx $c valueArray]_we_n
            if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                    memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                }
            }

            set bank_byte_pin [ getParameter c${c}_parity valueArray ]
            set portstring c${c}_[memx $c valueArray]_parity
            if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                    memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                }
            }

            set bank_byte_pin [ getParameter c${c}_ck_p valueArray ]
            set portstring c${c}_[memx $c valueArray]_ck_p
            if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                    memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                }
            }

            set bank_byte_pin [ getParameter c${c}_ck_n valueArray ]
            set portstring c${c}_[memx $c valueArray]_ck_n
            if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                    memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                }
            }

            set bank_byte_pin [ getParameter c${c}_r_n valueArray ]
            set portstring c${c}_[memx $c valueArray]_r_n
            if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                    memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                }
            }

            set bank_byte_pin [ getParameter c${c}_w_n valueArray]
            set portstring c${c}_[memx $c valueArray]_w_n
            if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                    memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                }
            }

            set bank_byte_pin [ getParameter c${c}_doff_n valueArray]
            set portstring c${c}_[memx $c valueArray]_doff_n
            if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                    memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                }
            }

            ##Added for having the System Pins configuration in the IO Planner

            set bank_byte_pin [ getParameter sys_rst valueArray ]
            set portstring sys_rst
            if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                    memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                }
            }

            set bank_byte_pin [ getParameter c${c}_init_calib_complete valueArray ]
            set portstring c${c}_init_calib_complete
            if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                    memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                }
            }

            set bank_byte_pin [ getParameter c${c}_data_compare_error valueArray ]
            set portstring c${c}_data_compare_error
            if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                    memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                }   
            }

            set bank_byte_pin [ getParameter c${c}_sys_clk_p valueArray ]
            set portstring c${c}_sys_clk_p
            if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                    memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                }
            }

            set bank_byte_pin [ getParameter c${c}_sys_clk_n valueArray ]
            set portstring c${c}_sys_clk_n
            if { [ string compare $bank_byte_pin "NONE" ] != 0} {
                if [regexp {bank(.*).byte(.*).pin(.*)} $bank_byte_pin matched bankno byte pin] {
                    memory_v1_Ip_memory_setSignal $c $bankno $byte $pin $portstring $InstName
                }
            }

            ## End of System Pin properties
        }
    }
    
    
    proc setAllBankByteList { xciValues } {
    
        upvar $xciValues valueArray
        set BankByteList {}
    
        foreach c { 0 } {
            for { set l 0 } { $l < 137 } { } {
                set u [expr $l + 7]
                set val [getParameter c${c}.dq_${l}_${u} valueArray]
                if { [string compare $val "NONE" ] != 0 } {
                    set bank_byte [ getParameter c${c}.dq_${l}_${u} valueArray ]
                    set bytestring C0.DQ[${l}-${u}]
                    if [ regexp {bank(.*).byte(.*)} $bank_byte matched bankno byte ] {
                        lappend BankByteList $bytestring $bankno $byte
                    }
                }
                set l [expr $l + 8]
            }
            
            for { set l 0 } { $l < 64 } { } {
                set u [expr $l + 8]
                set val [getParameter c${c}.dq_${l}_${u} valueArray]
                if { [string compare $val "NONE" ] != 0 } {
                    set bank_byte [ getParameter c${c}.dq_${l}_${u} valueArray ]
                    set bytestring C0.DQ[${l}-${u}]
                    if [ regexp {bank(.*).byte(.*)} $bank_byte matched bankno byte ] {
                        lappend BankByteList $bytestring $bankno $byte
                    }
                }
                set l [expr $l + 9]
            }
            
            for { set l 0 } { $l < 64 } { } {
                set u [expr $l + 8]
                set val [getParameter c${c}.d_${l}_${u} valueArray]
                if { [string compare $val "NONE" ] != 0 } {
                    set bank_byte [ getParameter c${c}.d_${l}_${u} valueArray ]
                    set bytestring C0.D[${l}-${u}]
                    if [ regexp {bank(.*).byte(.*)} $bank_byte matched bankno byte ] {
                        lappend BankByteList $bytestring $bankno $byte
                    }
                }
                set l [expr $l + 9]
            }
            
            foreach a { 0 1 2 3 } {
                set val [getParameter c${c}.q_${a} valueArray]
                if { [string compare $val "NONE" ] != 0 } {
                    set bank_byte [ getParameter c${c}.q_${a} valueArray ]
                    set bytestring C0.Q-${a}
                    if [ regexp {bank(.*).byte(.*)} $bank_byte matched bankno byte ] {
                        lappend BankByteList $bytestring $bankno $byte
                    }
                }
            }
            
            foreach a { 0 1 2 3 } {
                set val [getParameter c${c}.addr_ct_${a} valueArray]
                if { [string compare $val "NONE" ] != 0 } {
                    set bank_byte [ getParameter c${c}.addr_ct_${a} valueArray ]
                    set bytestring C0.Address/Ctrl-${a}
                    if [ regexp {bank(.*).byte(.*)} $bank_byte matched bankno byte ] {
                        lappend BankByteList $bytestring $bankno $byte
                    }
                }
            }
        }
        return $BankByteList
    }
    
    proc xdc_generate { xciValues datadir } {

        upvar $xciValues valueArray
        
        set fpgapart [ ipxit::get_project_property "PART" ]
        set InstName [ getParameter Component_Name valueArray ]
        set sysClkType [ getParameter System_Clock valueArray ]
        set internalVref [ string tolower [ getParameter Internal_Vref valueArray ] ]
        set args [ list -part $fpgapart -datadir $datadir -ip $InstName ]
        set memname [ string tolower [getParameter C0.ControllerType valueArray] ]
        memory_v1_Ip_memory_getXDCInfo_upgrade "0" $memname ${sysClkType} ${internalVref} {*}$args
    }
    
    proc xdc_output_impedence { xciValues datadir } {
        upvar $xciValues valueArray
        
        set fpgapart [ ipxit::get_project_property "PART" ]
        set InstName [ getParameter Component_Name valueArray ]
        set args [ list -part $fpgapart -datadir $datadir -ip $InstName ]
        set memname [ string tolower [getParameter C0.ControllerType valueArray] ]
        memory_v1_Ip_memory_getOutputImpedencePorts "0" $memname {*}$args
    }

    proc xdc_iostandards { xciValues datadir } {
        upvar $xciValues valueArray

        set fpgapart [ ipxit::get_project_property "PART" ]
        set InstName [ getParameter Component_Name valueArray ]
        set args [ list -part $fpgapart -datadir $datadir -ip $InstName ]
        set memname [ string tolower [getParameter C0.ControllerType valueArray] ]
        set sysClkType [ getParameter System_Clock valueArray ]
        memory_v1_Ip_memory_getIOStandardConstraints "0" $memname $sysClkType {*}$args
    }

    proc xdc_dump { xciValues datadir } {
        upvar $xciValues valueArray
        load librdi_iptasks[info sharedlibextension]

        set InstName [ getParameter Component_Name valueArray ]
        set tempArray [ setInstanceAllParamList valueArray $datadir ]
        set BankByteArray [ setAllBankByteList valueArray ]
        
        #set fpgapart [ ipxit::get_project_property "PART" ]
    set fpgapart [ getOption part valueArray ]
        set args1 [ list -part $fpgapart -datadir $datadir -ip $InstName -version 1.4 -controllertype "qdriiplus_sram" ]
        
        memory_v1_Ip_memory_loadPkg {*}$args1
        
        set memname [ string tolower [getParameter C0.ControllerType valueArray] ]
        set MemPart [getParameter C0.[string toupper [memx 0 valueArray]]_MemoryPart valueArray]
        set deviceWidth [ memory_v1_Ip_memory_getDeviceWidth $InstName $memname $MemPart ]
        
        if { [ llength BankByteArray ] > 0 } {
            memory_v1_Ip_memory_setSelectedBytes_upgrade $InstName {*}$BankByteArray {*}$tempArray
        }
        LoadPinInfo valueArray 
        memory_v1_Ip_memory_updateBankBytePropertiesAsPerPins $InstName $deviceWidth
        set constraint_data [ xdc_generate valueArray $datadir ]
        set sys_rst_pin ""
        set sys_rst_ioStd "" 
        set instDir [ipxit::current_outdir]  
        set fileName "${InstName}_upgrade.xdc"
        set infile $instDir/$fileName
        set ipfile [ ipxit::add_ipfile -force $infile ]
        #set ipfile [ xit::add_ipfile -force -processingOrder late -usedIn [ list synthesis implementation ] $infile ]
        foreach item $constraint_data {
            set isSysRstMatch [ string match *sys_rst* $item ]
            if { $isSysRstMatch != 0 } {
                 set property [ lindex [ split $item " " ] 1 ]
                 set value [ lindex [ split $item " " ] 2 ]
                 if { $property == "PACKAGE_PIN" } {
                    set sys_rst_pin $value
                 } elseif { $property == "IOSTANDARD" } {
                    set sys_rst_ioStd $value
                 }
            } else {
                ipxit::puts_ipfile $ipfile $item
            }
        }
        
        ipxit::puts_ipfile $ipfile "\n"
        ipxit::puts_ipfile $ipfile "\n"
        
        set impedence_data [ xdc_output_impedence valueArray $datadir ]
        foreach impedence $impedence_data {
            ipxit::puts_ipfile $ipfile $impedence
        }
        
        ipxit::puts_ipfile $ipfile "\n"
        ipxit::puts_ipfile $ipfile "\n"
        
        set ioStandards_data [ xdc_iostandards valueArray $datadir ]
        foreach ioStd $ioStandards_data {
            ipxit::puts_ipfile $ipfile $ioStd
        }
        ipxit::puts_ipfile $ipfile "\n"
        
        if { $memname == "ddr4_sdram" } {
            ipxit::puts_ipfile $ipfile "set_property IBUF_LOW_PWR FALSE  \[get_ports \{c0_ddr4_dq[*] c0_ddr4_dqs_t[*] c0_ddr4_dqs_c[*] c0_ddr4_dm_dbi_n[*]\}\]"    
        } elseif { $memname == "ddr3_sdram" } {
            ipxit::puts_ipfile $ipfile "set_property IBUF_LOW_PWR FALSE  \[get_ports \{c0_ddr3_dq[*] c0_ddr3_dqs_p[*] c0_ddr3_dqs_n[*]\}\]"
        } elseif { $memname == "rldram3" } {
            ipxit::puts_ipfile $ipfile "set_property IBUF_LOW_PWR FALSE  \[get_ports \{c0_rld3_dq\[*\]\}\]"
        }
        
        ipxit::close_ipfile $ipfile
        memory_v1_Ip_memory_unLoadPkg {*}$args1
        send_msg INFO 3 "The following XDC file has been generated based upon the previous pin assignments:\n $infile \n To migrate the Memory I/O Constraints to 2015.1, open the Elaborated RTL Design in Vivado and type read_xdc -cell <mig-cell-name> -file <fullname> \n to populate the scoped IO constraints. Then use the Save Constraints command to save them to the top-level XDC file. \n Refer to the 2015.1 Release Notes for more information.\n\n"
        
        if {$sys_rst_ioStd != "" && $sys_rst_pin != ""} {
            send_msg INFO 5 "The I/O buffer on the sys_rst pin has been removed in 2015.1 to allow you to use a common reset across your design. \nIf you would like to maintain its assignment as an I/O in your migrated design, assign the \nPACKAGE_PIN property to $sys_rst_pin and IOStandard to $sys_rst_ioStd in the Vivado I/O Planner.\n\n"    
        }   
    }
    
    proc memory_voltage_change { xciValues datadir } {
    
        upvar $xciValues valueArray
        load librdi_iptasks[info sharedlibextension]
        set InstName [ getParameter Component_Name valueArray ]
        
        #set fpgapart [ ipxit::get_project_property "PART" ]
        set fpgapart [ getOption part valueArray ]
        set args1 [ list -part $fpgapart -datadir $datadir -ip $InstName -version 1.4 -controllertype "qdriiplus_sram" ]
        memory_v1_Ip_memory_loadPkg {*}$args1
        
        set MemName [ string tolower [getParameter C0.ControllerType valueArray] ]
        if { $MemName == "ddr3_sdram" || $MemName == "ddr4_sdram" } {
            set MemPart [getParameter C0.[string toupper [memx 0 valueArray]]_MemoryPart valueArray]
            set TimePeriod [getParameter C0.[string toupper [memx 0 valueArray]]_TimePeriod valueArray]
            set MemoryType [getParameter C0.[string toupper [memx 0 valueArray]]_MemoryType valueArray]
            set MemoryVoltage [getParameter C0.[string toupper [memx 0 valueArray]]_MemoryVoltage valueArray]
            
            set ioVoltages [ memory_v1_Ip_memory_getValidMemoryVoltages $InstName $MemName $TimePeriod $MemoryType $MemPart ]
            
            set isValid 0
            foreach value $ioVoltages {
                if { $value == $MemoryVoltage  } {
                    set isValid 1
                    break
                }
            }
            
            if { $isValid == 0 && [ llength $ioVoltages ] > 0 } {
                set validValue [ lindex $ioVoltages 0 ]
                setParameter C0.[string toupper [memx 0 valueArray]]_MemoryVoltage $validValue valueArray
                send_msg INFO 5 "MemoryVoltage $MemoryVoltage is invalid for the selected configuration. Setting Value to $validValue \n"
            }
        }
        memory_v1_Ip_memory_unLoadPkg {*}$args1
    }
    
     proc data_width_change { xciValues datadir } {
        
        upvar $xciValues valueArray
        load librdi_iptasks[info sharedlibextension]
        set InstName [ getParameter Component_Name valueArray ]
        
        #set fpgapart [ ipxit::get_project_property "PART" ]
        set fpgapart [ getOption part valueArray ]  
        set args1 [ list -part $fpgapart -datadir $datadir -ip $InstName -version 1.4 -controllertype "qdriiplus_sram" ]
        
        memory_v1_Ip_memory_loadPkg {*}$args1

        set memname [ string tolower [getParameter C0.ControllerType valueArray] ]
        set MemPart [getParameter C0.[string toupper [memx 0 valueArray]]_MemoryPart valueArray]
        set deviceWidth [ memory_v1_Ip_memory_getDeviceWidth $InstName $memname $MemPart ]
        
        set MemType1 [getParameter C0.[string toupper [memx 0 valueArray]]_MemoryType valueArray ]
        if { ([getParameter C0.ControllerType valueArray] == "DDR4_SDRAM" || [getParameter C0.ControllerType valueArray] == "DDR3_SDRAM") && $MemType1 == "Components" } {
            set dataWidth [getParameter C0.[string toupper [memx 0 valueArray]]_DataWidth valueArray ]
            if { $deviceWidth == "4" && $dataWidth > "32" } {
                setParameter C0.[string toupper [memx 0 valueArray]]_DataWidth "32" valueArray
                send_msg INFO 5 "The following memoryPart $MemPart does not support Data Width greater than 32. Setting Value 32 \n"
            } elseif { $deviceWidth == "8" && $dataWidth > "72" } {
                setParameter C0.[string toupper [memx 0 valueArray]]_DataWidth "72" valueArray
                send_msg INFO 5 "The following memoryPart $MemPart does not support Data Width greater than 72. Setting Value 72 \n"
            }
        }
        memory_v1_Ip_memory_unLoadPkg {*}$args1
     
    }
    
    proc parameter_clean_up { xciValues } {
        upvar $xciValues valueArray
        
        foreach c  { 0 } { 
            for { set l 0 } { $l < 72 } { incr l } {
                removeParameter c${c}_d_${l} valueArray
            }
            
            for { set l 0 } { $l < 4 } { incr l } {
                removeParameter c${c}_k_p_${l} valueArray
            }
            
            for { set l 0 } { $l < 4 } { incr l } {
                removeParameter c${c}_k_n_${l} valueArray
            }
            
            for { set l 0 } { $l < 4 } { incr l } {
                removeParameter c${c}_bw_n_${l} valueArray
            }
            
            for { set l 0 } { $l < 22 } { incr l } {
                removeParameter c${c}_sa_${l} valueArray
            }
            
            for { set l 0 } { $l < 72 } { incr l } {
                removeParameter c${c}_q_${l} valueArray
            }
            
            for { set l 0 } { $l < 4 } { incr l } {
                removeParameter c${c}_cq_p_${l} valueArray
            }
            
            for { set l 0 } { $l < 4 } { incr l } {
                removeParameter c${c}_cq_n_${l} valueArray
            }
            
            removeParameter c${c}_r_n valueArray
            removeParameter c${c}_w_n valueArray
            removeParameter c${c}_doff_n valueArray
            # ###########################################################
            
            for { set l 0 } { $l < 144 } { incr l } {
                removeParameter c${c}_dq_${l} valueArray
            }
            
            for { set l 0 } { $l < 22 } { incr l } {
                removeParameter c${c}_adr_${l} valueArray
            }
            
            for { set l 0 } { $l < 22 } { incr l } {
                removeParameter c${c}_addr_${l} valueArray
            }
            
            for { set l 0 } { $l < 24 } { incr l } {
                removeParameter c${c}_a_${l} valueArray
            }
            
            for { set l 0 } { $l < 36 } { incr l } {
                removeParameter c${c}_dm_dbi_n_${l} valueArray
            }
            
            for { set l 0 } { $l < 36 } { incr l } {
                removeParameter c${c}_dm_${l} valueArray
            }
            
            for { set l 0 } { $l < 36 } { incr l } {
                removeParameter c${c}_dqs_c_${l} valueArray
            }
            
            for { set l 0 } { $l < 36 } { incr l } {
                removeParameter c${c}_dqs_t_${l} valueArray
            }
            
            for { set l 0 } { $l < 36 } { incr l } {
                removeParameter c${c}_dqs_p_${l} valueArray
            }
            
            for { set l 0 } { $l < 36 } { incr l } {
                removeParameter c${c}_dqs_n_${l} valueArray
            }
            
            for { set l 0 } { $l < 8 } { incr l } {
                removeParameter c${c}_dk_p_${l} valueArray
            }
            
            for { set l 0 } { $l < 8 } { incr l } {
                removeParameter c${c}_dk_n_${l} valueArray
            }
            
            for { set l 0 } { $l < 8 } { incr l } {
                removeParameter c${c}_qk_p_${l} valueArray
            }
            
            for { set l 0 } { $l < 8 } { incr l } {
                removeParameter c${c}_qk_n_${l} valueArray
            }
            
            for { set l 0 } { $l < 4 } { incr l } {
                removeParameter c${c}_qvld_${l} valueArray
            }
            
            for { set l 0 } { $l < 4 } { incr l } {
                    removeParameter c${c}_ba_${l} valueArray
            }
            
            for { set l 0 } { $l < 3 } { incr l } {
                    removeParameter c${c}_bg_${l} valueArray
            }
            
            for { set l 0 } { $l < 4 } { incr l } {
                    removeParameter c${c}_cke_${l} valueArray
            }
            
            for { set l 0 } { $l < 4 } { incr l } {
                    removeParameter c${c}_ck_p_${l} valueArray
            }
            
            for { set l 0 } { $l < 4 } { incr l } {
                    removeParameter c${c}_ck_n_${l} valueArray
            }
            
            for { set l 0 } { $l < 4 } { incr l } {
                    removeParameter c${c}_cs_n_${l} valueArray
            }
            
            for { set l 0 } { $l < 4 } { incr l } {
                    removeParameter c${c}_odt_${l} valueArray
            }
            
            for { set l 0 } { $l < 4 } { incr l } {
                removeParameter c0_ck_c_${l} valueArray
            }
            
            for { set l 0 } { $l < 4 } { incr l } {
                removeParameter c0_ck_t_${l} valueArray
            }
            
            removeParameter sys_rst valueArray
            removeParameter c${c}_reset_n valueArray
            removeParameter c${c}_act_n valueArray
            removeParameter c${c}_ras_n valueArray
            removeParameter c${c}_cas_n valueArray
            removeParameter c${c}_we_n valueArray
            removeParameter c${c}_parity valueArray
            #removeParameter c${c}_ck_c valueArray
            #removeParameter c${c}_ck_t valueArray
            removeParameter c${c}_ck_n valueArray
            removeParameter c${c}_ck_p valueArray
            removeParameter c${c}_cs_n valueArray
            removeParameter c${c}_ref_n valueArray
            
            removeParameter c${c}_sys_clk_p valueArray
            removeParameter c${c}_sys_clk_n valueArray
            removeParameter c${c}_data_compare_error valueArray
            removeParameter c${c}_init_calib_complete valueArray
            removeParameter Internal_Vref valueArray
            
            for { set l 0 } { $l < 137 } { } {
                set u [expr $l + 7]
                removeParameter c${c}.dq_${l}_${u} valueArray
                set l [expr $l + 8]
            }
            
            for { set l 0 } { $l < 64 } { } {
                set u [expr $l + 8]
                removeParameter c${c}.dq_${l}_${u} valueArray
                set l [expr $l + 9]
            }
            
            for { set l 0 } { $l < 64 } { } {
                set u [expr $l + 8]
                removeParameter c${c}.d_${l}_${u} valueArray
                set l [expr $l + 9]
            }
            
            foreach a { 0 1 2 3 } {
                removeParameter c${c}.q_${a} valueArray
            }
            
            foreach a { 0 1 2 3 } {
                removeParameter c${c}.addr_ct_${a} valueArray
            }
        }
    }
    
    proc upgrade_from_mig_v6_0 { xciValues } { 
     
        namespace import ::xcoUpgradeLib::\*
        upvar $xciValues valueArray
        
        addParameter Enable_Phy_Only false valueArray
        
        removeParameter c0_ck_c valueArray
        removeParameter c0_ck_t valueArray
        
        upgrade_from_mig_v6_1 valueArray
    }
    
    proc upgrade_from_mig_v6_1 { xciValues } {
    
        namespace import ::xcoUpgradeLib::\*
        upvar $xciValues valueArray
        set return_value [verify_isResetRequired valueArray]
      if { $return_value == 2 || $return_value == 3 } {
            namespace forget ::xcoUpgradeLib::\*
            return;
      }

		set add_ui_clk1 [getParameter ADDN_UI_CLKOUT1_FREQ_HZ valueArray]
		set add_ui_clk2 [getParameter ADDN_UI_CLKOUT2_FREQ_HZ valueArray]
		set add_ui_clk3 [getParameter ADDN_UI_CLKOUT3_FREQ_HZ valueArray]
		set add_ui_clk4 [getParameter ADDN_UI_CLKOUT4_FREQ_HZ valueArray]
		
		
		if {$add_ui_clk1 != "None" || $add_ui_clk2 != "None" || $add_ui_clk3 != "None" ||  $add_ui_clk4 != "None"} {
		
		set check 0
		set freq 800
		set divclk_div 1
		set clkfbout_mult 1

	
		if { [getParameter C0.ControllerType valueArray] == "QDRIIPLUS_SRAM" } {
			set freq [expr [getParameter C0.QDRIIP_InputClockPeriod valueArray]]
			if {[getModelParameter C0.QDRIIP_DIVCLK_DIVIDE valueArray] == "" || [getModelParameter C0.QDRIIP_CLKFBOUT_MULT valueArray ] == ""} {
				return ;        
			} else {
				set divclk_div [expr int([getModelParameter C0.QDRIIP_DIVCLK_DIVIDE valueArray])]
				set clkfbout_mult [expr int([getModelParameter C0.QDRIIP_CLKFBOUT_MULT valueArray ])]
			}
			set check 1
		} 

		
		if { $check == 1 } {
			set new_list [getMMCMClockList1 $freq  $divclk_div $clkfbout_mult]
			send_msg INFO 5 "new_list $new_list"
		} else {
			set new_list "None"
		}
		set created_list {}
		set created_list [regsub -all "," $new_list " "]
		
		
		if {$add_ui_clk1 != "None"} {
			set new_val [closest $add_ui_clk1 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk1 on parameter ADDN UI CLKOUT1 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT1_FREQ_HZ "$new_val" valueArray
		}
		
		
		
		if {$add_ui_clk2 != "None"} {
			set new_val [closest $add_ui_clk2 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk2 on parameter ADDN UI CLKOUT2 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT2_FREQ_HZ "$new_val" valueArray
		}
		
		
		if {$add_ui_clk3 != "None"} {
			set new_val [closest $add_ui_clk3 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk3 on parameter ADDN UI CLKOUT3 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT3_FREQ_HZ "$new_val" valueArray
		}
		
		
		if {$add_ui_clk4 != "None"} {
			set new_val [closest $add_ui_clk4 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk4 on parameter ADDN UI CLKOUT4 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT4_FREQ_HZ "$new_val" valueArray
		}
		}
        if { [getParameter C0.ControllerType valueArray] == "DDR4_SDRAM"  && [getParameter C0.DDR4_MemoryType valueArray ] != "Components"} {
            set mem_part [getParameter C0.DDR4_MemoryPart valueArray]
                set new_part [get_new_mem_part $mem_part]   
            if { $new_part != "Not_changed"} {
            setParameter C0.DDR4_MemoryPart $new_part valueArray
            send_msg INFO 1 "MemoryPart $mem_part is now renamed to $new_part \n"
            }
         }  elseif { [getParameter C0.ControllerType valueArray] == "DDR3_SDRAM"    && [getParameter C0.DDR3_MemoryType valueArray ] != "Components" } {
            set mem_part [getParameter C0.DDR3_MemoryPart valueArray]
                set new_part [get_new_mem_part $mem_part]   
            if { $new_part != "Not_changed"} {  
             setParameter C0.DDR3_MemoryPart $new_part valueArray
             send_msg INFO 1 "MemoryPart $mem_part is now renamed to $new_part \n"
            }
        }
        
        set mempart2 [ getParameter C0.RLD3_MemoryPart valueArray]
        if { [getParameter C0.ControllerType valueArray] == "RLDRAM3" && [ string match "*MT44K16M36RB*" $mempart2] } {
            setParameter C0.RLD3_BurstLength "4" valueArray
            send_msg INFO 2 "MemoryPart $mempart2 does not support Burst Length 8. Setting Value 4 \n"
        }
        if { [getParameter C0.ControllerType valueArray] == "DDR4_SDRAM" && [ string tolower [ getParameter C0.DDR4_AxiSelection valueArray] ] == "false" } {
            addParameter C0.DDR4_AutoPrecharge "true" valueArray
        }
        if { [getParameter C0.ControllerType valueArray] == "DDR3_SDRAM" && [ string tolower [ getParameter C0.DDR3_AxiSelection valueArray] ] == "false" } {
            addParameter C0.DDR3_AutoPrecharge "true" valueArray
        }
		
        removeParameter Enable_Phy_Only valueArray
        addParameter Phy_Only "Complete_Memory_Controller" valueArray
		
        
        set datadir [get_data_dir]
        if { [ file exists $datadir ] == 0 } {
            send_msg "ERROR" 2000 "IP Component directory path ($datadir) mentioned is not valid. Please provide valid IP Dir path"
        }
    
        memory_voltage_change valueArray $datadir
        data_width_change valueArray $datadir
        xdc_dump valueArray $datadir
        parameter_clean_up valueArray
		
		addParameter Internal_Vref true valueArray
		
        if { [getParameter C0.DDR4_MemoryVoltage valueArray] == "1.2" } { 
            setParameter C0.DDR4_MemoryVoltage 1.2V valueArray
        }
        if { [getParameter C0.RLD3_MemoryVoltage valueArray ] == "1.2" } {
            setParameter C0.RLD3_MemoryVoltage 1.2V valueArray
        }
        send_msg INFO 2 "Default simulation is made as BFM which uses behavioural models for XiPhy libraries. \n In order to use Unisims for XiPhy libraries, regenerate the design with Simulation Mode option value as Unisim. \n"
        namespace forget ::xcoUpgradeLib::\*
   } 

   proc upgrade_from_mig_v7_0 {xciValues} {
        namespace import ::xcoUpgradeLib::\*
        upvar $xciValues valueArray
        set return_value [verify_isResetRequired valueArray]
        if { $return_value == 2 || $return_value == 3 } {
            namespace forget ::xcoUpgradeLib::\*
            return;
        }
		
		set add_ui_clk1 [getParameter ADDN_UI_CLKOUT1_FREQ_HZ valueArray]
		set add_ui_clk2 [getParameter ADDN_UI_CLKOUT2_FREQ_HZ valueArray]
		set add_ui_clk3 [getParameter ADDN_UI_CLKOUT3_FREQ_HZ valueArray]
		set add_ui_clk4 [getParameter ADDN_UI_CLKOUT4_FREQ_HZ valueArray]
		
		
		if {$add_ui_clk1 != "None" || $add_ui_clk2 != "None" || $add_ui_clk3 != "None" ||  $add_ui_clk4 != "None"} {
		
		set check 0
		set freq 800
		set divclk_div 1
		set clkfbout_mult 1

	
		if { [getParameter C0.ControllerType valueArray] == "QDRIIPLUS_SRAM" } {
			set freq [expr [getParameter C0.QDRIIP_InputClockPeriod valueArray]]
			if {[getModelParameter C0.QDRIIP_DIVCLK_DIVIDE valueArray] == "" || [getModelParameter C0.QDRIIP_CLKFBOUT_MULT valueArray ] == ""} {
				return ;        
			} else {
				set divclk_div [expr int([getModelParameter C0.QDRIIP_DIVCLK_DIVIDE valueArray])]
				set clkfbout_mult [expr int([getModelParameter C0.QDRIIP_CLKFBOUT_MULT valueArray ])]
			}
			set check 1
		} 

		
		if { $check == 1 } {
			set new_list [getMMCMClockList1 $freq  $divclk_div $clkfbout_mult]
			send_msg INFO 5 "new_list $new_list"
		} else {
			set new_list "None"
		}
		set created_list {}
		set created_list [regsub -all "," $new_list " "]
		
		
		if {$add_ui_clk1 != "None"} {
			set new_val [closest $add_ui_clk1 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk1 on parameter ADDN UI CLKOUT1 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT1_FREQ_HZ "$new_val" valueArray
		}
		
		
		
		if {$add_ui_clk2 != "None"} {
			set new_val [closest $add_ui_clk2 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk2 on parameter ADDN UI CLKOUT2 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT2_FREQ_HZ "$new_val" valueArray
		}
		
		
		if {$add_ui_clk3 != "None"} {
			set new_val [closest $add_ui_clk3 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk3 on parameter ADDN UI CLKOUT3 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT3_FREQ_HZ "$new_val" valueArray
		}
		
		
		if {$add_ui_clk4 != "None"} {
			set new_val [closest $add_ui_clk4 $created_list]
			send_msg INFO 2 "Unable to set the value $add_ui_clk4 on parameter ADDN UI CLKOUT4 FREQ HZ.Restoring to the closest possible value $new_val"
			setParameter ADDN_UI_CLKOUT4_FREQ_HZ "$new_val" valueArray
		}
		}
		
        removeParameter Enable_Phy_Only valueArray     
        addParameter Phy_Only "Complete_Memory_Controller" valueArray
		addParameter Internal_Vref true valueArray
        namespace forget ::xcoUpgradeLib::\*
   }

    proc get_new_mem_part {old_part} {
        set mem_part_dict {
            MT40A256M16HA-083 EDY4016AABG-DR-F
            MTA8ATF51264HZ-2G1A1 MTA8ATF51264AZ-2G1
            MTA18ASF1G72HZ-2G4 MTA18ASF1G72HZ-2G3 
            MTA18ASF1G72HZ-2G4A1 MTA18ASF1G72HZ-2G3
            MTA18ASF1G72HZ-2G1A1 MTA18ASF1G72HZ-2G1
            MTA8ATF51264AZ-2G1A1 MTA8ATF51264AZ-2G1
            MTA9ASF51272AZ-2G1A1 MTA9ASF51272AZ-2G1
            MTA18ASF1G72AZ-2G1A1 MTA18ASF1G72AZ-2G1
            MT16KTF1G64HZ-1G9E1 MT16KTF1G64HZ-1G9
            MT16KTF1G64HZ-1G6E1 MT16KTF1G64HZ-1G6
            MT18JSF1G72AZ-1G9E3 MT18JSF1G72AZ-1G9
            MT18JSF1G72AZ-1G6E1 MT18JSF1G72AZ-1G6
            MT18JSF51272AZ-1G4K1 MT18JSF51272AZ-1G4
            MT18KSF1G72AZ-1G6E1 MT18KSF1G72AZ-1G6
            MT18KSF1G72AZ-1G4E1 MT18KSF1G72AZ-1G4
        }
        if {[dict exists $mem_part_dict $old_part]} {
            set new_part [dict get $mem_part_dict $old_part]
            return $new_part
        } else {
            return "Not_changed"    
        }
    }
    proc check_before_upgrade {xciValues} {
        upvar $xciValues valueArray  
        set currentDevice ""
        set oldDevice ""
        set currentDevice [ getOriginalOption part valueArray ]
        set oldDevice [ getOption part valueArray ]

        set olddevice [ getOption device valueArray ] 
        set oldpackage [ getOption package valueArray ] 
        set oldspeedgrade [ getOption speedgrade valueArray ] 
        set currentdevice [ getOriginalOption device valueArray ] 
        set currentpackage [ getOriginalOption package valueArray ] 
        set currentspeedgrade [ getOriginalOption speedgrade valueArray ]


        ## We treat it as a part change only when a device / package /speedgrade change; other things like temperature grade and engineering sample change (es1/es2) is not being considered as part change. 
        if {( [ string compare $currentdevice $olddevice ] != 0) || ([ string compare $currentpackage $oldpackage ] != 0) || ([ string compare $currentspeedgrade $oldspeedgrade ] != 0)} {
            if { [getParameter C0.ControllerType valueArray] == "None" } { 
                return 3
            }
            return 2
        }

        if { [getParameter C0.ControllerType valueArray] == "None" } { 
            return 3
        }
        return 1
    }
}

