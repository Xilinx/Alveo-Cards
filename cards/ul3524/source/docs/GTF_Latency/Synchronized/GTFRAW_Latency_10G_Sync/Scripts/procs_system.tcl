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
proc sim_axil_write {offset address wdata} {
    # Re-format input value to 32-bit
    set address_int [format "0x%08x" [expr $offset + $address]]
    set value [reg_wr $address_int $wdata]
}


# Read a device register.  Address should be presented as hex (0x...).  Returns a hex value (0x...)
proc sim_axil_read {offset address} {
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


# Sleep for N seconds
proc sleep {N} {
	after [expr {int ($N *1000)}]
	puts ""
	puts "	----> Wait $N second(s) <----"
	puts ""

}


# Returns the value of the bits from  [highbit:lowbit]
proc bitvalue {value  highbit lowbit} {
    set width [expr {$highbit - $lowbit + 1}]
    set mask [expr {(1 << $width) - 1}]
    expr {($value >> $lowbit) & $mask}
}


# Sets value0[highbit:lowbit] = value1 and returns new value0
proc bitset { value0 highbit lowbit value1 } {
    set width [expr {$highbit - $lowbit + 1}]
    set mask  [expr {(1 << $width) - 1}]
    expr ($value0 & ~($mask << $lowbit)) | ($value1 << $lowbit)
}


#
# Logging function to display formatted debug headers....
#
proc display_header { string0 level} {
    if { $level == 3 } {
        puts "####################################"
        puts "#"
        puts "# $string0"
        puts "#"
        puts "####################################"
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



