#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

#
# Common Register Access Procs
#

# Write a device register.  Both address and value should be presented as hex (0x...).  
proc reg_wr {address value} {
    # Re-format input values to 32-bit
    set address [format %08x [expr $address]]
    set value   [format %08x [expr $value]]
    # Send xfer...
    create_hw_axi_txn -quiet -force wr_tx [get_hw_axis hw_axi_1] -address $address -data $value -type write
    run_hw_axi -quiet wr_tx
    #puts [format "\[DEBUG\] reg_wr 0x%s 0x%s" $address $value]
}


# Read a device register.  Address should be presented as hex (0x...).  Returns a hex value (0x...)
proc reg_rd {address} {
    # Re-format input value to 32-bit
    set address [format %08x [expr $address]]
    # Send xfer...
    create_hw_axi_txn -quiet -force rd_tx [get_hw_axis hw_axi_1] -address $address -type read
    run_hw_axi -quiet rd_tx
    # Return a hex value (0x...)
    set value [format "0x%s" [get_property DATA [get_hw_axi_txn rd_tx]]]
    #puts [format "\[DEBUG\] reg_rd 0x%s %s" $address $value]
    return $value
}


# Write a device register.  Both addresses and value should be presented as hex (0x...)
proc hwchk_axil_write {offset address wdata} {
    # Re-format input value to 32-bit
    set address_int [format "0x%08x" [expr $offset + $address]]
    set value [reg_wr $address_int $wdata]
}


# Read a device register.  Address should be presented as hex (0x...).  Returns a hex value (0x...)
proc hwchk_axil_read {offset address} {
    # Re-format input value to 32-bit
    set address_int [format "0x%08x" [expr $offset + $address]]
    set value [reg_rd $address_int]
    return $value
}


# Converts large hex value to decimal (can lead with '0x')
proc hex2dec {largeHex} {
    # Remove '0x' prefix if present...
    set largeHex [string trimleft $largeHex 0x]
    # Loop through each digit...
    set res 0
    foreach hexDigit [split $largeHex {}] {
        set new 0x$hexDigit
        set res [expr {16*$res + $new}]
    }
    return $res
}



#
# Logging function to display formatted debug headers....
#
proc display_header { string0 level} {
    if { $level == 3 } {
        puts "#"
        puts "#"
        puts "# $string0"
        puts "#"
        puts "#"
    }
    if { $level == 2 } {
        puts "#"
        puts "# $string0"
        puts "#"
    }
    if { $level == 1 } {
        puts "-"
        puts "- $string0"
        puts "-"
    }
    if { $level == 0 } {
        puts "-- $string0"
    }
}



#
# Logging function to display ASCII header registers of various functional logic blocks...
#
proc disp_headers {} {
    set temp0         [string range [reg_rd [expr $::ADDR_SYS_HEADER0]] 2 end]
    set temp0 ${temp0}[string range [reg_rd [expr $::ADDR_SYS_HEADER1]] 2 end]
    set temp0 ${temp0}[string range [reg_rd [expr $::ADDR_SYS_HEADER2]] 2 end]
    set temp0 ${temp0}[string range [reg_rd [expr $::ADDR_SYS_HEADER3]] 2 end]
    puts [format "\[HEADER\] %s" [binary format H* $temp0]]

    set temp0         [string range [reg_rd [expr $::ADDR_FC_HEADER0]] 2 end]
    set temp0 ${temp0}[string range [reg_rd [expr $::ADDR_FC_HEADER1]] 2 end]
    set temp0 ${temp0}[string range [reg_rd [expr $::ADDR_FC_HEADER2]] 2 end]
    set temp0 ${temp0}[string range [reg_rd [expr $::ADDR_FC_HEADER3]] 2 end]
    puts [format "\[HEADER\] %s" [binary format H* $temp0]]

    set temp0         [string range [reg_rd [expr $::ADDR_JC_GPIO_HEADER0]] 2 end]
    set temp0 ${temp0}[string range [reg_rd [expr $::ADDR_JC_GPIO_HEADER1]] 2 end]
    set temp0 ${temp0}[string range [reg_rd [expr $::ADDR_JC_GPIO_HEADER2]] 2 end]
    set temp0 ${temp0}[string range [reg_rd [expr $::ADDR_JC_GPIO_HEADER3]] 2 end]
    puts [format "\[HEADER\] %s" [binary format H* $temp0]]

    set temp0         [string range [reg_rd [expr $::ADDR_JC_I2C_HEADER0]] 2 end]
    set temp0 ${temp0}[string range [reg_rd [expr $::ADDR_JC_I2C_HEADER1]] 2 end]
    set temp0 ${temp0}[string range [reg_rd [expr $::ADDR_JC_I2C_HEADER2]] 2 end]
    set temp0 ${temp0}[string range [reg_rd [expr $::ADDR_JC_I2C_HEADER3]] 2 end]
    puts [format "\[HEADER\] %s" [binary format H* $temp0]]
}



#
# Function to sample and display clock frequency measurement..
#                       
proc measure_frequency {} {
    display_header {Clock Freq Measurement...} 1
    
    # release reset
    reg_wr [expr $::ADDR_FC_CONTROL] 0x00000001
    
    # set 1ms sample window
    reg_wr [expr $::ADDR_FC_SAMP_WIDTH] 0x000186a0
    
    # Sample a few...
    # Set start bit....
    reg_wr [expr $::ADDR_FC_CONTROL] 0x00000003
    
    # Wait for end of sample...
    set temp 0
    while { $temp == 0x0 } {
        set temp [expr [reg_rd [expr $::ADDR_FC_STATUS]] & 0x1 ]
    }            
    
    # Print results
    puts [format "    Index     MHz"]
    puts [format "    -----   -------"]
    for {set ii 0} {$ii < 8} {incr ii} {
        set temp [hwchk_axil_read  0x0 [expr $::ADDR_FC_SAMP_COUNT_0 + 4 * $ii]]
        set temp [expr $temp / 1000.0]
        puts [format "      %d     %7.3f" $ii $temp]
    }
    puts ""
}

