#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

source ./procs_system.tcl


set NUM_TESTS       10
set ERROR_INJ_COUNT 250


proc reset_design {} {

    set axi_addr_offset 0x0000
    set axi_addr        0x0000
    set axi_data        0x0000

    #  Apply System Resets...
    #  Set - gtwiz_reset_all
    #        gtf_ch_txdp_reset
    #        gtf_ch_rxdp_reset
    puts [format "Set and clear system resets..."]
    set axi_addr  0x04
    set axi_data  0x07
    sim_axil_write $axi_addr_offset $axi_addr $axi_data
    
    #  Clear - gtwiz_reset_all
    set axi_addr  0x04
    set axi_data  0x06
    sim_axil_write $axi_addr_offset $axi_addr $axi_data
    
    #  Clear - gtf_ch_txdp_reset
    #          gtf_ch_rxdp_reset
    set axi_addr  0x04
    set axi_data  0x00
    sim_axil_write $axi_addr_offset $axi_addr $axi_data

    #Wait for Link Stable to go high....
    puts [format "Wait for link stable..."]
    set axi_addr    0x00
    set link_stable 0x00
    while { $link_stable == 0x0 } { 
        set link_stable [sim_axil_read $axi_addr_offset $axi_addr]
        set link_stable [expr $link_stable & 0x2]
    }

    puts [format "Initial link achieved."]

}


proc runme { cycle } {

    set axi_addr_offset 0x0000
    set axi_addr        0x0000
    set axi_data        0x0000

    puts [format "Setup Error Inject and Latency."]
    # Set Error Inject Count
    set axi_addr   0x10
    set axi_data   $::ERROR_INJ_COUNT
    sim_axil_write $axi_addr_offset $axi_addr $axi_data
    
    # Set Error Inject Delay Count
    set axi_addr   0x14
    set axi_data   $::ERROR_INJ_DELAY
    sim_axil_write $axi_addr_offset $axi_addr $axi_data
    
    # Set Latency count
    set axi_addr   0x20
    set axi_data   $::ERROR_INJ_COUNT
    sim_axil_write $axi_addr_offset $axi_addr $axi_data
    
    # Enable Latency Logic
    set axi_addr   0x04
    set axi_data   0x010
    sim_axil_write $axi_addr_offset $axi_addr $axi_data
    
    # Clear Latency Pointers...(set bit 6, W1C)
    set axi_addr   0x04
    set axi_data   [expr $axi_data | 0x040]
    sim_axil_write $axi_addr_offset $axi_addr $axi_data
    
    # Enable Err Inject Logic...(set bit 8, W1C)
    set axi_addr   0x04
    set axi_data   [expr $axi_data | 0x100]
    sim_axil_write $axi_addr_offset $axi_addr $axi_data
    
    # Loop until Error Inject Logic complete
    puts [format "Latency Loop."]
    set lat_cnt         0x0  
    set err_inj_remain  0xFF 
    set lat_remain      0xFF 
    
    set value_num    0.0
    set value_max    0.0
    set value_min 1000.0
    set value_ave    0.0
    set value_0p5    0
    set value_1p5    0
    set value_2p5    0
    set value_3p5    0
    
    while { [expr $err_inj_remain + $lat_remain] > 0 } {
    
        # Check for latency data pending....
        set axi_addr  0x24
        set axi_data [sim_axil_read $axi_addr_offset $axi_addr]
        if { ($axi_data & 0xFFFF) != 0x0} {
            # latency data available, pulse pop bit ...
            set axi_addr   0x04
            set axi_data [sim_axil_read $axi_addr_offset $axi_addr]
            # Set pop bit (bit 5 W1C)
            set axi_data   [expr $axi_data | 0x20]
            sim_axil_write $axi_addr_offset $axi_addr $axi_data
            
            # Read latency TX/RX timer values....
            set axi_addr   0x28
            set axi_data [sim_axil_read $axi_addr_offset $axi_addr]
            set lat_tx_time  $axi_data
            set axi_addr   0x2C
            set axi_data [sim_axil_read $axi_addr_offset $axi_addr]
            set lat_rx_time  $axi_data
            
            if { [expr $lat_rx_time - $lat_tx_time] > 0} { 
                set lat_delta  [expr $lat_rx_time - $lat_tx_time]
            } else {
                set lat_delta  [expr 65535 - $lat_rx_time + $lat_rx_time]
            }
            
            puts [format "Latency: %3d -- Tx=%6d Rx=%6d (Delta = %d) %6.3f cycles" [expr $lat_cnt + 1] $lat_tx_time $lat_rx_time $lat_delta [expr $lat_delta - 6.5] ]
            set lat_cnt [expr $lat_cnt + 1]

            set value     [expr $lat_delta - 6.5]
            set value_num [expr $value_num + 1.0]
            set value_ave [expr $value_ave + $value]
            
            if { $value > $value_max} {
                set value_max $value
            }
            
            if { $value < $value_min} {
                set value_min $value
            }    
            
            if { $value == 0.5} {
                incr value_0p5
            }    
            if { $value == 1.5} {
                incr value_1p5
            }    
            if { $value == 2.5} {
                incr value_2p5
            }    
            if { $value == 3.5} {
                incr value_3p5
            }    
            
        }
        
        # Read error inject and latency counters for remaining samples....
        set axi_addr   0x18
        set axi_data [sim_axil_read $axi_addr_offset $axi_addr]
        set err_inj_remain [expr $axi_data & 0xFFFF]
        
        set axi_addr   0x24
        set axi_data [sim_axil_read $axi_addr_offset $axi_addr]
        set lat_remain [expr $axi_data & 0xFFFF]
    }
    
    set value_ave [expr $value_ave / $value_num]
    
    #puts [format "N:%d   Min:%.3f    Max:%.3f   Ave:%.3f" [expr int($value_num)] $value_min $value_max $value_ave]
    puts [format "Latency Loop Done."]

    set fp [open "gtf_raw_latency.csv" a+]
    puts $fp [format "%.3f,%.3f,%.3f" $value_min $value_max $value_ave]
    close $fp
    
    set fp [open "gtf_raw_latency.log" a+]
    puts $fp [format "=========================================================================================="]
    puts $fp [format "Test Number: %d" $cycle] 
    puts $fp [format "Latency (min/avg/max):  %.3fns / %.3fns / %.3fns" $value_min $value_ave $value_max]
    puts $fp [format "Clk Cnts  (0.5, 1.5, 2.5, 3.5): %d  / %d  / %d / %d" $value_0p5 $value_1p5 $value_2p5 $value_3p5]
    set value_0p5 [expr 100.0 * $value_0p5 / $value_num]
    set value_1p5 [expr 100.0 * $value_1p5 / $value_num]
    set value_2p5 [expr 100.0 * $value_2p5 / $value_num]
    set value_3p5 [expr 100.0 * $value_3p5 / $value_num]
    puts $fp [format "Percent   (0.5, 1.5, 2.5, 3.5): %.0f%% / %.0f%% / %.0f%% / %.0f%%" $value_0p5 $value_1p5 $value_2p5 $value_3p5]
    puts $fp [format "=========================================================================================="]
    puts $fp [format ""]

    close $fp
}


proc runall { cycle_num } {
    
    
    for {set ii 0} {$ii<$cycle_num} {incr ii} {
        puts [format "########################"]
        puts [format "#"]
        puts [format "# Cycle %d" $ii]
        puts [format "#"]
        puts [format "########################"]
    
        after 1000
        reset_design
        after 1000
        runme $ii
        after 1000
    }
    
    #close $::fp
}


# Script defaults to auto start running.... 
runall $NUM_TESTS


