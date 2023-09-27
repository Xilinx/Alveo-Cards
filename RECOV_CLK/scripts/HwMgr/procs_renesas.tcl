#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#


#
# Reset JITT I2C Controller
#
proc reset_jitt_i2c {} {
    display_header "Reset JITT I2C" 0

    # release logic reset...
    reg_wr [expr $::ADDR_JC_I2C_CONTROL] 0x0000
    puts ""
}


#
# Enable JITT I2C Controller
#
proc enable_jitt_i2c {} {
    display_header "Enable JITT I2C" 0

    # release logic reset...
    reg_wr [expr $::ADDR_JC_I2C_CONTROL] 0x0001
    puts ""
}


#
# Launch JITT I2C Controller
#
proc run_jitt_i2c {} {
    display_header "Run JITT I2C" 0

    # release logic reset...
    reg_wr [expr $::ADDR_JC_I2C_CONTROL] 0x0001
    
    # send pulse 
    reg_wr [expr $::ADDR_JC_I2C_CONTROL] 0x0003
    
    # wait until done...
    set temp 0
    while { $temp == 0 } {
        set temp [expr [reg_rd [expr $::ADDR_JC_I2C_STATUS]] & 1]
    }
    puts ""
}


#
# Set JITT RESETn
#
proc set_jitt_resetn {} {
    display_header "Set JITT1 Resetn" 0
    # Set output value = 1
    reg_wr [expr $::ADDR_JC_GPIO_JITT_RSTN_OUT] 0x0001
    # Set I/O config to output enable
    reg_wr [expr $::ADDR_JC_GPIO_JITT_RSTN_CFG] 0x0000
    puts ""
}


#
# Clear JITT RESETn
#
proc clear_jitt_resetn {} {
    display_header "Clear JITT1 Resetn" 0
    # Set output value = 0
    reg_wr [expr $::ADDR_JC_GPIO_JITT_RSTN_OUT] 0x0000
    # Set I/O config to output enable
    reg_wr [expr $::ADDR_JC_GPIO_JITT_RSTN_CFG] 0x0000
    puts ""
}


#
# Read JITT RESETn
#
proc read_jitt_resetn {} {
    display_header "Read JITT1 Resetn" 0
    # Read input value
    set temp [reg_rd [expr $::ADDR_JC_GPIO_JITT_RSTN_IN]]
    puts [format "   Input    : $temp"]
    set temp [reg_rd [expr $::ADDR_JC_GPIO_JITT_RSTN_OUT]]
    puts [format "   Output   : $temp"]
    set temp [reg_rd [expr $::ADDR_JC_GPIO_JITT_RSTN_CFG]]
    puts [format "   Config   : $temp"]
    puts ""
}


#
# Enable and Program JITT1 GPIO
#
proc set_jitt1_GPIO { value } {
    display_header "Set JITT1 GPIO" 0
    # 'value' is a 6 bit hex value '0x..'
    # Set output values
    reg_wr [expr $::ADDR_JC_GPIO_JITT1_GPIO_OUT] $value
    # Set I/O config to output enable
    reg_wr [expr $::ADDR_JC_GPIO_JITT1_GPIO_CFG] 0x0000
    puts ""
}


#
# Read JITT1 GPIO
#
proc read_jitt1_GPIO {} {
    # Read input value
    display_header "Read JITT1 GPIO" 0
    set temp [reg_rd [expr $::ADDR_JC_GPIO_JITT1_GPIO_IN]]
    puts [format "   Input    : $temp"]
    set temp [reg_rd [expr $::ADDR_JC_GPIO_JITT1_GPIO_OUT]]
    puts [format "   Output   : $temp"]
    set temp [reg_rd [expr $::ADDR_JC_GPIO_JITT1_GPIO_CFG]]
    puts [format "   Config   : $temp"]
    puts ""
}


#===================================================================


#
# Load Jitt I2C BRAM...
#
proc load_renesas_i2c_bram { coe_memfile } {
    display_header "Load JITT I2C BRAM" 1
    display_header "(may take 5-10 sec)" 0
    
    #check if file exists
    if { [file exists $coe_memfile] == 0 } {
        puts "ERROR: file does not exist : $coe_memfile"
        return
    }

    # Read file....
    set ifile [open $coe_memfile]
    set ilines [split [read $ifile] "\n"]
    close $ifile; 
    
    # Loop through the COE data file...
    #    1. first two lines of coe file are headers/
    #    2. each line ends in a comma or semicolon
    set nn 0
    for {set ii 2} {$ii < [llength $ilines]} {incr ii} {
        set addr [expr $::ADDR_JC_BRAM + $nn]
        set data [lindex $ilines $ii]
        set data [string range $data 0 3]
        set data "0x$data"
    
        reg_wr $addr $data    
        set nn [expr $nn + 4]
    }
    puts ""
}

#===================================================================

proc switch_renesas_cfg { config0 en_i2c_xfer } {

    # Measure frequency
    #measure_frequency
    
    # Set Reset
    #set_jitt_resetn
    #read_jitt_resetn
    
    # Set Config 15 (Default)
    set_jitt1_GPIO $config0
    read_jitt1_GPIO
    
    # Toggle Reset
    clear_jitt_resetn
    read_jitt_resetn
    set_jitt_resetn
    read_jitt_resetn
    after 1000

    if { $en_i2c_xfer == 1} {
        # Reset I2C
        reset_jitt_i2c
        after 1000
        enable_jitt_i2c

        # Send I2C Sequence...
        run_jitt_i2c
        after 1000
    }

    # Remeasure frequency...
    measure_frequency
}
