# 
# Copyright (C) 2024, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: X11
# 

# ################################################################################
#
#  Constants
#
# ################################################################################

# I2c device id's....
set DEV_ID_POWER    0x42
set DEV_ID_MUX0     0xE0
set DEV_ID_QSFP_SB  0x40
set DEV_ID_QSFP_I2C 0xA0

# ################################################################################
#
#  Helper Functions... 
#
# ################################################################################


# Write a device register.  Both address and value should be presented as hex (0x...).  
# NOTE: All 4 bytes must be specified (ie, including leading 00s if necessary such as 0x00000000)
proc reg_wr {address value} {
    set address [string range $address 2 [expr {[string length $address]-1}]]
    set value "00000000[string range $value 2 [expr {[string length $value]-1}]]"
    set value [string range $value [expr {[string length $value]-8}] [expr {[string length $value]-1}]]
    #puts "\[reg_wr\] $address = $value" 
    create_hw_axi_txn -quiet -force wr_tx [get_hw_axis hw_axi_1] -address $address -data $value -type write
    run_hw_axi -quiet wr_tx
}

# Read a device register.  Both address and value should be presented as hex (0x...).  
proc reg_rd {address} {
    set temp $address
    set address [string range $address 2 [expr {[string length $address]-1}]]
    create_hw_axi_txn -quiet -force rd_tx [get_hw_axis hw_axi_1] -address $address -type read
    run_hw_axi -quiet rd_tx
    set rdata 0x[get_property DATA [get_hw_axi_txn rd_tx]]
    #puts "\[reg_rd\] $temp = $rdata"
    return $rdata
    #return 0x[get_property DATA [get_hw_axi_txn rd_tx]]
}

proc hex2dec {largeHex} {
    set res 0
    foreach hexDigit [split $largeHex {}] {
        set new 0x$hexDigit
        set res [expr {16*$res + $new}]
    }
    return $res
}


# I2C Read Operation - writes address, then device id/control with Read Bit Set
proc i2c_rd {dev_id address} {
    reg_wr 0x04 $address
    reg_wr 0x00 0x[format %X [expr $dev_id + (1<<31)]]
    
    set rdata [reg_rd 0x00]
    if { ($rdata & 0x40000000) != 0x0} {
        after 100
        set rdata [reg_rd 0x00]
    }
    set rdata [reg_rd 0x0c]
    puts "\[i2c_rd\] $dev_id $address = $rdata"
    return $rdata
}

proc i2c_rd_quiet {dev_id address} {
    reg_wr 0x04 $address
    reg_wr 0x00 0x[format %X [expr $dev_id + (1<<31)]]
    
    set rdata [reg_rd 0x00]
    if { ($rdata & 0x40000000) != 0x0} {
        after 100
        set rdata [reg_rd 0x00]
    }
    set rdata [reg_rd 0x0c]
    #puts "\[i2c_rd\] $dev_id $address = $rdata"
    return $rdata
}

# I2C Write Operation - writes address and data, then device id/control 
proc i2c_wr {dev_id address wdata} {
    puts "\[i2c_wr\] $dev_id $address = $wdata" 
    reg_wr 0x04 $address
    reg_wr 0x08 $wdata
    reg_wr 0x00 $dev_id 
    
    set rdata [reg_rd 0x00]
    if { ($rdata & 0x40000000) != 0x0} {
        after 100
        set rdata [reg_rd 0x00]
    }
}


# Programs I2C Mux peripherals to desired QSFP SB Peripheral
proc select_qsfp_sb {index} {
    global DEV_ID_MUX0 
    global DEV_ID_MUX1 
    puts "-- Select Gate Mux's to QSFP $index SB"
    if { $index == 0} {
        i2c_wr $DEV_ID_MUX0 0x01 0x01
    } elseif { $index == 1} {
        i2c_wr $DEV_ID_MUX0 0x04 0x04
    } elseif { $index == 2} {
        i2c_wr $DEV_ID_MUX0 0x00 0x00
    } elseif { $index == 3} {
        i2c_wr $DEV_ID_MUX0 0x00 0x00
    }   
}
 
# Programs I2C Mux peripherals to desired QSFP Module I2C Pins
proc select_qsfp_i2c {index} {
    global DEV_ID_MUX0 
    global DEV_ID_MUX1 
    puts "-- Select Gate Mux's to QSFP $index I2C"
    if { $index == 0} {
        i2c_wr $DEV_ID_MUX0 0x02 0x02
    } elseif { $index == 1} {
        i2c_wr $DEV_ID_MUX0 0x08 0x08
    } elseif { $index == 2} {
        i2c_wr $DEV_ID_MUX0 0x00 0x00
    } elseif { $index == 3} {
        i2c_wr $DEV_ID_MUX0 0x00 0x00
    }   
}
 
 
 # Disables the power planes for all QSFP Modules
 proc disable_qsfp_power {} {
    global DEV_ID_POWER
    puts "-- Disable Power to QSFP 1-2  (set output value and output enable)"
    i2c_rd $DEV_ID_POWER 0x0
    i2c_wr $DEV_ID_POWER 0x1 0x00
    i2c_wr $DEV_ID_POWER 0x3 0x55
    i2c_rd $DEV_ID_POWER 0x0
}
 

# Enables the power planes for all QSFP Modules
proc enable_qsfp_power {} {
    global DEV_ID_POWER
    puts "-- Enable Power to QSFP 1-2  (set output value and output enable)"
    i2c_rd $DEV_ID_POWER 0x0
    i2c_wr $DEV_ID_POWER 0x1 0xAA
    i2c_wr $DEV_ID_POWER 0x3 0x55
    i2c_rd $DEV_ID_POWER 0x0
}
 
 
 
# ---------------------------------------------------------------
# SB Control/Status bits
#   0 - LPMODE    (output, 0 = hw control, high power)
#   1 - INTL      (input,  0 = interrupt)
#   2 - MODPRSTL  (input,  0 = present)
#   3 - MODSELL   (output, 0 = I2C enable)
#   4 - RESETL    (output, 1 = enabled)

proc assert_qsfp_sb_reset {} {
    global DEV_ID_QSFP_SB
    puts "-- Asserting QSFP Reset"
    # Resetn = 0, LPMODE = 0, MODSEL = 0;
    i2c_wr $DEV_ID_QSFP_SB 0x01 0x00
    # Set output enable for bits 0,3:7
    i2c_wr $DEV_ID_QSFP_SB 0x03 0x06
}


proc deassert_qsfp_sb_reset {} {
    global DEV_ID_QSFP_SB
    puts "-- Deasserting QSFP Reset"
    # Resetn = 1, LPMODE = 0, MODSEL = 0;
    i2c_wr $DEV_ID_QSFP_SB 0x01 0x10
    # Set output enable for bits 0,3:7
    i2c_wr $DEV_ID_QSFP_SB 0x03 0x06
}

proc read_qsfp_sb_status {} {
    global DEV_ID_QSFP_SB
    puts "-- Reading QSFP SB Status"
    set temp [i2c_rd $DEV_ID_QSFP_SB 0x00]
    return $temp;
}

proc read_qsfp_sb_status_quiet {} {
    global DEV_ID_QSFP_SB
    #puts "-- Reading QSFP SB Status"
    set temp [i2c_rd_quiet $DEV_ID_QSFP_SB 0x00]
    return $temp;
}
 

# ################################################################################
#
#  Main Test Sequences...
#
# ################################################################################


proc qsfp_enable_power {} {
    puts ""
    puts "-- Deassert Resets to I2C I/O Expanders and Switches and I2C Controller"
    reg_wr 0x10 0x7F
    
    
    puts ""
    puts "-- Disable and re-enable QSFP power domains..."
    disable_qsfp_power
    after 1000
    enable_qsfp_power
    
    
    puts ""
    puts "-- Enable QSFP 0..."
    # Select sideband routing...
    select_qsfp_sb 0
    # Toggle RESETL...
    assert_qsfp_sb_reset
    deassert_qsfp_sb_reset
    # Readback SB status...
    read_qsfp_sb_status
}


proc qsfp_scan_loop {} {
    puts ""
    puts "Example Loop to Check for Module Insertion/Removal..."
    
    set status_modprstl_prev -1
    while { 1 == 1 } {
        # Read Status from QSFP SB...
        set temp [read_qsfp_sb_status_quiet]
        
        # Extract MODPRSTL Status...
        set status_modprstl_curr [expr ([expr $temp] >> 2) & 1] 
        if { $status_modprstl_curr != $status_modprstl_prev} {
            if { $status_modprstl_curr == 1 } {
                puts "QSFP Module Removed..."
            } else {
                puts "QSFP Module Inserted..."
            }
        }
        
        # Update status history...
        set status_modprstl_prev $status_modprstl_curr
        
        # Delay a bit and resample...
        after 1000
    }
}


proc qsfp_access_i2c {} {
    set DEV_ID_QSFP_I2C 0xA0

    puts ""
    puts "Example QSFP 0 MODULE I2C Access..."
    
    select_qsfp_i2c 0
    
    puts ""
    puts "-- Read Module State Register (Lower Page, Address 0x03)"
    i2c_rd $DEV_ID_QSFP_I2C 0x03
    
    # Voltage Values are 16 bit unsigned values with 100uV/bit resolution
    puts ""
    puts "-- Read Module Supply Voltage MSB (Lower Page, Address 0x10)"
    set msb [string range [i2c_rd $DEV_ID_QSFP_I2C 0x10] 8 9]
    puts "-- Read Module Supply Voltage LSB (Lower Page, Address 0x11)"
    set lsb [string range [i2c_rd $DEV_ID_QSFP_I2C 0x11] 8 9]
    set value [expr 0x$msb$lsb * 0.0001] 
    set value [string range $value 0 4]
    puts "-- Calculated Supply Voltage : $value Volts"

    
    # Temperature Values are 2bit complement numbers, 1/256 increments, -128 to 128'C range)
    puts ""
    puts "-- Read Module Temp MSB 1 (Lower Page, Address 0x18)"
    set msb [string range [i2c_rd $DEV_ID_QSFP_I2C 0x18] 8 9]
    puts "-- Read Module Temp LSB 1 (Lower Page, Address 0x19)"
    set lsb [string range [i2c_rd $DEV_ID_QSFP_I2C 0x19] 8 9]
    set value [expr 0x$msb$lsb / 256.0] 
    set value [string range $value 0 6]
    puts "-- Calculated Module Temp 1 : $value 'C"
    

    puts ""
    puts "-- Read Module Temp MSB 2 (Page 3, Address 0x98)"
    i2c_wr $DEV_ID_QSFP_I2C 0x7F 0x03
    set msb [string range [i2c_rd $DEV_ID_QSFP_I2C 0x98] 8 9]
    puts "-- Read Module Temp LSB 2 (Page 3, Address 0x99)"
    i2c_wr $DEV_ID_QSFP_I2C 0x7F 0x03
    set lsb [string range [i2c_rd $DEV_ID_QSFP_I2C 0x99] 8 9]
    set value [expr 0x$msb$lsb / 256.0] 
    set value [string range $value 0 6]
    puts "-- Calculated Module Temp 2 : $value 'C"
    

    puts ""
    puts "-- Read Module Temp MSB 3 (Lower Page, Address 0x0E)"
    set msb [string range [i2c_rd $DEV_ID_QSFP_I2C 0x0E] 8 9]
    puts "-- Read Module Temp LSB 3 (Lower Page, Address 0x0F)"
    set lsb [string range [i2c_rd $DEV_ID_QSFP_I2C 0x0F] 8 9]
    set value [expr 0x$msb$lsb / 256.0] 
    set value [string range $value 0 6]
    puts "-- Calculated Module Temp 3 : $value 'C"
    

    puts ""
    puts "-- Read Module Temp MSB 4 (Page 3, Address 0x9A)"
    i2c_wr $DEV_ID_QSFP_I2C 0x7F 0x03
    set msb [string range [i2c_rd $DEV_ID_QSFP_I2C 0x9A] 8 9]
    puts "-- Read Module Temp LSB 4 (Page 3, Address 0x9B)"
    i2c_wr $DEV_ID_QSFP_I2C 0x7F 0x03
    set lsb [string range [i2c_rd $DEV_ID_QSFP_I2C 0x9B] 8 9]
    set value [expr 0x$msb$lsb / 256.0] 
    set value [string range $value 0 6]
    puts "-- Calculated Module Temp 4 : $value 'C"
}

