#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

#===================================================================

source ./addr_register.tcl  -notrace
source ./procs_system.tcl   -notrace
source ./procs_renesas.tcl  -notrace
source ./procs_gtf.tcl      -notrace

#===================================================================

#
# This is the main test sequence to reset the system and configure the system...
#                       
proc setup { args } {

    set temp [list {*}$args]
    if { "-help" in $temp || "-h" in $temp } {
        puts "Usage:"
        puts "  setup <args>"
        puts "     -n_chan <integer>     Number of channels - Dflt = 4 "
        return
    }

    # following will error if $args is an odd-length list
    array set optional [list -n_chan 4 {*}$args]
    set ::frames_to_send 100
    set n_chan   $optional(-n_chan)

    set temp [reg_rd 0x14]
    if { $temp < $n_chan } {
        set temp [format "Error: Design has %d channel(s). User requesting %d channel(s)" $temp $n_chan]
        display_header $temp 2
        break
    }
    
    display_header {Apply System/GTF Resetn} 2
    hwchk_axil_write  0x0000 0x0010 0x01
    after 1000
    hwchk_axil_write  0x0000 0x0010 0x00
    after 1000
    hwchk_axil_write  0x0000 0x0010 0x01
    after 1000
        
    display_header {Enable QSFP I2C SM} 2
    hwchk_axil_write  0x50000 0x0014 0xFF
    
    #
    # Configure and Initialize GTF channels....
    #
    
    display_header {Starting Channel Init} 2
    #   init_channel { channel mode }
    #   link_channel { channel }
    #       channel: 0 to 3
    #       mode   : 0 = near, 1 = far, 2 = normal
    for {set channel 0} { $channel < $n_chan } {incr channel} {
        init_channel $channel 2
        link_channel $channel
    }
    after 1000

    # Reset Loopback FIFO
    display_header {Reset RAW Loopback Fifo and RX Packet Count} 2
    hwchk_axil_write  0x0000 0x0010 0x03
    hwchk_axil_write  0x0000 0x0010 0x01

    # Reset Rx Packet Counter
    for {set channel 0} { $channel < $n_chan } {incr channel} {
        hwchk_axil_write  [lindex $::ADDR_OFFSET_CHAN $channel] 0x011c 0x01
        hwchk_axil_write  [lindex $::ADDR_OFFSET_CHAN $channel] 0x0120 0x01
    }

    display_header {Complete...} 2
}


#
# This is the main test sequence to run data transfers...
#                       
proc runme { args } {

    set temp [list {*}$args]
    if { "-help" in $temp || "-h" in $temp } {
        puts "Usage:"
        puts "  runme <args>"
        puts "     -n_chan <integer>     Number of channels - Dflt = 4 "
        puts "     -n_frames <integer>   Number of packets per cycle (0 = continuous) - Dflt = 0"
        puts "     -n_cycles <integer>   Number of test cycles - Dflt = 1"
        puts "     -delay <integer>      Delay (in ms) of each test cyclc - Dflt = 5000"
        return
    }

    # following will error if $args is an odd-length list
    array set optional [list -n_chan 4 -n_frames 0 -n_cycles 1 -delay 5000 {*}$args]
    set n_chan   $optional(-n_chan)
    set n_frames $optional(-n_frames)
    set n_cycles $optional(-n_cycles)
    set delay    $optional(-delay)

    set temp [reg_rd 0x14]
    if { $temp < $n_chan } {
        set temp [format "Error: Design has %d channel(s). User requesting %d channel(s)" $temp $n_chan]
        display_header $temp 2
        break
    }

    # Set frames_to_send = 0 for continuous transfers
    set ::frames_to_send  $n_frames
    #set ::frames_to_send  0
    #set ::frames_to_send  8192

    display_header {Running Data Stream...} 2
    puts [format "Num Channels     = %d" $n_chan  ]
    puts [format "Num Cycles       = %d" $n_cycles]
    set temp ""
    if { $n_frames == 0 } { 
        set temp "(cont.)"
    }
    puts [format "Num Frames/Cycle = %d %s" $n_frames $temp]
    puts [format "Cycle Delay(ms)  = %d" $delay   ]

    for {set channel 0} { $channel < $n_chan } {incr channel} {
        set_frames_to_send $channel $n_frames
    }
    
    set cycle 1
    while { $cycle <= $n_cycles } {
        # Reset Rx Packet Counter
        for {set channel 0} { $channel < $n_chan } {incr channel} {
            hwchk_axil_write  [lindex $::ADDR_OFFSET_CHAN $channel] 0x011c 0x01
            hwchk_axil_write  [lindex $::ADDR_OFFSET_CHAN $channel] 0x0120 0x01
        }
    
        #
        # Perform data transfer.....
        #
        #display_header {Run Channel} 2
    
        set_frame_gen_en
        after $delay
        clear_frame_gen_en    
        after 1000
    
        #
        # Read back status of each channel....
        #
        #display_header {Read Channel Status} 2
        for {set channel 0} { $channel < $n_chan } {incr channel} {
            read_status $channel $cycle
            hwchk_axil_write  [lindex $::ADDR_OFFSET_CHAN $channel] 0x011c 0x01
            hwchk_axil_write  [lindex $::ADDR_OFFSET_CHAN $channel] 0x0120 0x01
        }
        
        incr cycle
    }
    
    display_header {Complete...} 2
}



#load_renesas_i2c_bram { coe_memfile } {
#switch_renesas_cfg    13 1

proc test { args } {

    # following will error if $args is an odd-length list
    array set optional [list -aa 5 -bb 6 {*}$args]
    set aa $optional(-aa)
    set bb $optional(-bb)
    
    puts [format "aa = %d" $aa]
    puts [format "bb = %d" $bb]

} 