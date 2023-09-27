#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#


set ADDR_OFFSET_CHAN { 0x100000
                       0x120000
                       0x140000
                       0x160000 }
                       

# Returns the value of the bits from  [highbit:lowbit]
proc bitvalue {value  highbit lowbit} {
    set width [expr {$highbit - $lowbit + 1}]
    set mask [expr {(1 << $width) - 1}]
    expr {($value >> $lowbit) & $mask}
}

#
# This procedure initializes an individual channel 
#                       
proc init_channel { channel mode } {

    set temp [format "Channel %d Init..." $channel]
    display_header $temp 1

    # Set address offset for this channel....
    set addr_offset [lindex $::ADDR_OFFSET_CHAN $channel]
    puts [format "Addr offset 0x%08x" $addr_offset]

    puts [format "Waiting for DUT to come alive..."]
    puts [format "Starting transaction on Channel-%d" $channel]
    set attempts  0
    set data  1
    while { ($data != 0x0) && ($attempts < 100000) } {
        set data [hwchk_axil_read $addr_offset 0x0]
        set data [expr $data & 0x3]
        incr attempts
    }

    puts [format "Observed gtfmac status = %0x" $data]
    if { $attempts >= 100000 } {
        puts [format "ERROR - DUT did not come out of reset"]
        puts [format "** Error: Test did not complete successfully"]
        ERROR  "DUT did not come out of reset"
    }

    puts [format "Report userrdy to the GTF"]
    set addr 0x000C
    set data 0x0003
    hwchk_axil_write $addr_offset $addr $data

    # --------------------------------------------------------------

    if { $mode == 0 } {
        puts [format "Configure near-end loopback"]
        set addr 0x10408
        set data [hwchk_axil_read $addr_offset $addr]
        set data [expr ($data & ~0x70) | (0x2 << 4)]
        hwchk_axil_write $addr_offset $addr $data
    
        # --------------------------------------------------------------

        puts [format "Reset the RX side of the GT"]
        set addr 0x10400
        set data 0x2
        hwchk_axil_write $addr_offset $addr $data
    
        set addr 0x10400
        set data 0x0
        hwchk_axil_write $addr_offset $addr $data
    }

    
    if { $mode == 2 } {
        puts [format "Configure Normal Operation"]
        set addr 0x10408
        set data [hwchk_axil_read $addr_offset $addr]
        set data [expr $data & ~0x70]
        hwchk_axil_write $addr_offset $addr $data
        
        # --------------------------------------------------------------
        
        puts [format "Reset the RX side of the GT"]
        set addr  0x10400
        set data  0x0002
        hwchk_axil_write $addr_offset $addr $data
        set addr  0x10400
        set data  0x0000
        hwchk_axil_write $addr_offset $addr $data
    }

    # --------------------------------------------------------------

    set ctl_tx_data_rate 0x0
    set ctl_rx_data_rate 0x0
    
    set addr 0x10000
    set data [expr $ctl_tx_data_rate<<1 + $ctl_rx_data_rate]
    hwchk_axil_write $addr_offset $addr $data

    puts [format "HWCHK:    Set up the TX/RX data rate to match"]
    set addr 0x10
    set data [hwchk_axil_read $addr_offset $addr]
    set data [expr ($data & ~(0x1 <<  0)) | ($ctl_tx_data_rate <<  0) ]
    set data [expr ($data & ~(0x1 << 16)) | ($ctl_rx_data_rate << 16) ]
    puts [format "        HWCHK config=%0x" $data]
    hwchk_axil_write $addr_offset $addr $data

    puts [format "Allow MAC side of the GTFMAC to bitslip"]
    set addr  0x00a4
    set data  0x0000
    set data  0x0001
    hwchk_axil_write $addr_offset $addr $data

	puts ""
	puts "Clear, then read, GTF RX block_lock status ($addr)"
    set addr 0x10130
    hwchk_axil_write $addr_offset $addr 0xFFFFFFFF
    set data [hwchk_axil_read $addr_offset $addr]
    puts "status = $data"

    # Wait for block lock
    puts [format "Waiting for HWCHK to detect block lock..."]
    set attempts 0
    set hwchk_block_lock 0
    while { ($hwchk_block_lock == 0x0) && ($attempts < 100000) } {
        set hwchk_block_lock [hwchk_axil_read $addr_offset 0xA0]
        set hwchk_block_lock [expr ($hwchk_block_lock & (0x1 << 16))]
        incr attempts
        puts [format "Block lock : 0x%08x" $hwchk_block_lock]

        #puts "Reading HWCHK BISTSLIP CONFIG 1 (Reg $addr)"
        #set addr 0xa0
        #set data [hwchk_axil_read $addr_offset $addr]
        #set bitslip_issued_cnt_gtfmac	[bitvalue $data 6 0]
        #set bitslip_issued_cnt_hwchk	[bitvalue $data 14 8]
        #set bitslip_locked				[bitvalue $data 16 16]
        #set bitslip_busy				[bitvalue $data 17 17]
        #set bitslip_done				[bitvalue $data 18 18]
        #set bitslip_gt127				[bitvalue $data 19 19]
        #
        #puts "Reg $addr						= $data"
        #puts "	bitslip_issued_cnt_gtfmac	= $bitslip_issued_cnt_gtfmac"
        #puts "	bitslip_issued_cnt_hwchk	= $bitslip_issued_cnt_hwchk"
        #puts "	bitslip_locked				= $bitslip_locked"
        #puts "	bitslip_busy				= $bitslip_busy"
        #puts "	bitslip_done				= $bitslip_done"
        #puts "	bitslip_gt127				= $bitslip_gt127"
        #
        #if { $bitslip_issued_cnt_gtfmac == 127 } {
        #    puts ""
        #    puts "	ERROR - Bitslip Error!"
        #    puts "	Exiting script..."
        #    break
        #}
    }

    if { $attempts >= 100000 } {
        puts [format "ERROR - no block lock"]
        puts [format "** Error: Test did not complete successfully"]
        ERROR  "no block lock"
    }

    puts [format "Block lock found."]

    # Only correct bitslip if we are in 10G mode
    if { $ctl_tx_data_rate == 0x0 } {

        puts [format "Allow bitslip logic to correct bitslip in the transceiver..."]
        set addr  0x00a4
        set data  0x0001
        hwchk_axil_write $addr_offset $addr $data

        set attempts 0
        set data 0
        while { ($data == 0x0) && ($attempts < 100) } {
            set data [hwchk_axil_read $addr_offset 0xA0]
            puts [format "Bitslip data..."]
            puts [format "  %2d stat_bitslip_cnt    " [expr ($data >>  0) & 0x3F]]
            puts [format "  %2d stat_bitslip_issued " [expr ($data >>  8) & 0x3F]]
            puts [format "  %2d stat_bitslip_locked " [expr ($data >> 16) & 0x01]]
            puts [format "  %2d stat_bitslip_busy   " [expr ($data >> 17) & 0x01]]
            puts [format "  %2d stat_bitslip_done   " [expr ($data >> 18) & 0x01]]
            puts [format "  %2d stat_excessive_bitslip" [expr ($data >> 19) & 0x01]]
            set data [expr $data & (1 << 18)]
            incr attempts
        }
    
        if { $attempts >= 100 } {
            puts [format "ERROR - alignment process failed"]
            puts [format "** Error: Test did not complete successfully"]
            ERROR  "alignment process failed"
        }

        puts [format "Bitslip issued."]

        puts [format "Waiting for HWCHK to detect block lock..."]
        set attempts 0
        set hwchk_block_lock 1
        while { ($hwchk_block_lock == 0x0) && ($attempts < 100000) } {
            set hwchk_block_lock [hwchk_axil_read $addr_offset 0xA0]
            set hwchk_block_lock [expr $hwchk_block_lock & (1 << 16)]
            incr attempts
        }

        if { $attempts >= 100000 } {
            puts [format "ERROR - no block lock"]
            puts [format "** Error: Test did not complete successfully"]
            ERROR  "no block lock"
        }

        puts [format "Block lock found."]

    }
    
    # Wait for rx alignment
    puts [format "Waiting for HWCHK to detect rx alignment..."]
    set attempts 0

    if { $attempts >= 100000 } {
        puts [format "ERROR - no rx alignment"]
        puts [format "** Error: Test did not complete successfully"]
        ERROR  "no rx alignment"
    }

    puts [format "rx alignment achieved."]
}


#
# This procedure continues to initialize an individual channel to good link status
#                       
proc link_channel { channel }  {
    set ctl_tx_start_framing_enable     0x0
    set ctl_tx_fcs_ins_enable           0x1
    set ctl_tx_ignore_fcs               0x0
    set ctl_rx_ignore_fcs               0x0
    set ctl_tx_custom_preamble_enable   0x0
    set ctl_rx_custom_preamble_enable   0x0
    set ctl_frm_gen_mode                0x0
    set ctl_tx_variable_ipg             0x0
    set ctl_rx_check_preamble           0x0
    set ctl_hwchk_tx_err_inj            0x0
    set ctl_hwchk_tx_poison_inj         0x0
    set ctl_tx_ipg                      0x8			

    set ctl_rx_min_packet_len           64
    set ctl_rx_max_packet_len           64
    #set frames_to_send                  5000
    # Set to 0 for continuous mode...
    set frames_to_send                  $::frames_to_send

    set temp [format "Channel %d Link..." $channel]
    display_header $temp 1

    # Set address offset for this channel....
    set addr_offset [lindex $::ADDR_OFFSET_CHAN $channel]

    puts [format "Waiting for link up."]

    set attempts 0
    set data 1
    while { ($data != 0x0) && ($attempts < 10000) } {
        set data [hwchk_axil_read $addr_offset 0x0]
        set data [expr $data & (0x0F << 8)]
        incr attempts
    }

    puts [format "After %0d attempts, observed gtfmac status = %0x" $attempts $data]

    if { $attempts >= 100 } {
        puts [format "ERROR - link down"]
        puts [format "** Error: Test did not complete successfully"]
        ERROR "link down"
    } else {
        puts [format "LINK UP"]
    }

    puts [format "GTFMAC: Configure CONFIGURATION_TX_REG1"]
    puts [format "        ctl_tx_fcs_ins_enable=%0x" $ctl_tx_fcs_ins_enable]
    puts [format "        ctl_tx_ignore_fcs=%0x" $ctl_tx_ignore_fcs]
    puts [format "        ctl_tx_custom_preamble_enable=%0x" $ctl_tx_custom_preamble_enable]
    set addr 0x10004
    set data [hwchk_axil_read $addr_offset $addr]
    puts [format "        CONFIGURATION_TX_REG1=%0x" $data]
    set data [expr ($data & ~(0x1<< 1) )| ($ctl_tx_fcs_ins_enable         <<  1)]
    set data [expr ($data & ~(0x1<< 2) )| ($ctl_tx_ignore_fcs             <<  2)]
    set data [expr ($data & ~(0x1<< 3) )| ($ctl_tx_custom_preamble_enable <<  3)]
    set data [expr ($data & ~(0xF<< 8) )| ($ctl_tx_ipg                    <<  8)]
    set data [expr ($data & ~(0x1<<12) )| ($ctl_tx_start_framing_enable   << 12)]
    puts [format "        CONFIGURATION_TX_REG1=%0x" $data]
    hwchk_axil_write $addr_offset $addr $data

    puts [format "GTFMAC: Configure CONFIGURATION_RX_REG1"]
    puts [format "        ctl_rx_ignore_fcs=%0x" $ctl_rx_ignore_fcs]
    puts [format "        ctl_rx_custom_preamble_enable=%0x" $ctl_rx_custom_preamble_enable]
    set addr 0x10008
    set data [hwchk_axil_read $addr_offset $addr]
    set data [expr ($data & ~(0x1<< 2) )| ($ctl_rx_ignore_fcs             << 2)]
    set data [expr ($data & ~(0x1<< 5) )| ($ctl_rx_check_preamble         << 5)]
    set data [expr ($data & ~(0x1<< 6) )| ($ctl_rx_custom_preamble_enable << 6)]
    hwchk_axil_write $addr_offset $addr $data

    puts [format "GTFMAC: Configure CONFIGURATION_RX_MTU1"]
    puts [format "        ctl_rx_min_packet_len=%0x" $ctl_rx_min_packet_len]
    set addr 0x1000c
    set data [hwchk_axil_read $addr_offset $addr]
    set data $ctl_rx_min_packet_len
    hwchk_axil_write $addr_offset $addr $data

    puts [format "GTFMAC: Configure CONFIGURATION_RX_MTU2"]
    puts [format "        ctl_rx_max_packet_len=%0x" $ctl_rx_max_packet_len]
    set addr 0x10010
    set data [hwchk_axil_read $addr_offset $addr]
    puts [format "        Read %0x" $data]
    set data $ctl_rx_max_packet_len
    hwchk_axil_write $addr_offset $addr $data
    set data [hwchk_axil_read $addr_offset $addr]

    puts [format "HWCHK:    Set up the HWCHK fcs_ins_enable and preamble_enable."]
    puts [format "        ctl_tx_fcs_ins_enable=%0x" $ctl_tx_fcs_ins_enable]
    puts [format "        ctl_tx_custom_preamble_enable=%0x" $ctl_tx_custom_preamble_enable]
    puts [format "        ctl_rx_custom_preamble_enable=%0x" $ctl_rx_custom_preamble_enable]
    puts [format "        ctl_tx_start_framing_enable=%0x" $ctl_tx_start_framing_enable]
    set addr 0x00010
    set data [hwchk_axil_read $addr_offset $addr]
    set data [expr ($data & ~(0x1<< 4))| ($ctl_tx_fcs_ins_enable           <<  4)]
    set data [expr ($data & ~(0x1<< 8))| ($ctl_tx_custom_preamble_enable   <<  8)]
    set data [expr ($data & ~(0x1<<12))| ($ctl_tx_start_framing_enable     << 12)]
    set data [expr ($data & ~(0x1<<24))| ($ctl_rx_custom_preamble_enable   << 24)]

    puts [format "        HWCHK config=%0x" $data]
    hwchk_axil_write $addr_offset $addr $data
    puts [format "HWCHK:    Set the Error Injection Flag"]
    puts [format "        ctl_hwchk_tx_err_inj=%0x" $ctl_hwchk_tx_err_inj]
    set addr 0x00040
    set data $ctl_hwchk_tx_err_inj
    hwchk_axil_write $addr_offset $addr $data
    
    puts [format "HWCHK:    Set the Poison Injection Flag"]
    puts [format "        ctl_hwchk_tx_poison_inj=%0x" $ctl_hwchk_tx_poison_inj]
    set addr 0x0098
    set data $ctl_hwchk_tx_poison_inj
    hwchk_axil_write $addr_offset $addr $data
    puts [format "HWCHK:    Set the min and max frame lengths for the generator."]
    puts [format "        ctl_rx_min_packet_len=%0x" $ctl_rx_min_packet_len]
    puts [format "        ctl_rx_max_packet_len=%0x" $ctl_rx_max_packet_len]
    set addr 0x0028
    set data $ctl_rx_min_packet_len
    hwchk_axil_write $addr_offset $addr $data

    set addr 0x0024
    set data $ctl_rx_max_packet_len
    hwchk_axil_write $addr_offset $addr $data

    # Set the mode
    puts [format "Set the frame generation mode."]
    puts [format "        ctl_frm_gen_mode=%0x" $ctl_frm_gen_mode]
    puts [format "        ctl_tx_variable_ipg=%0x" $ctl_tx_variable_ipg]
    set addr 0x0014
    set data 0
    set data [expr ($data & ~(0x1<< 0))| ($ctl_frm_gen_mode     <<  0)]
    set data [expr ($data & ~(0x1<< 8))| ($ctl_tx_variable_ipg  <<  8)]
    hwchk_axil_write $addr_offset $addr $data

    # Specify the number of frames
    puts [format "Configure the number of frames to send (%0d)" $frames_to_send]
    set addr 0x002c
    set data $frames_to_send
    hwchk_axil_write $addr_offset $addr $data

    puts [format "Tick the HWCHK stats to initialize them."]
    set addr 0x0090
    set data 0x1
    hwchk_axil_write $addr_offset $addr $data

    puts [format "Tick the GTFMAC stats to initialize them."]
    set addr 0x1040c
    set data 0x1
    hwchk_axil_write $addr_offset $addr $data

    #frame_gen_ready[channel] = 1;
    puts [format "Channel-%d  is ready to enable frame generator" $channel]
}

#
# This procedure kicks off a data transfer from the MAC side 
#                       

proc set_frames_to_send { channel frames_to_send }  {
    # Set address offset for this channel....
    set addr_offset [lindex $::ADDR_OFFSET_CHAN $channel]
    
    # Specify the number of frames
    #puts [format "Configure the number of frames to send (%0d)" $frames_to_send]
    set addr 0x002c
    set data $frames_to_send
    hwchk_axil_write $addr_offset $addr $data
}

#
# This procedure kicks off a data transfer from the MAC side 
#                       
proc set_frame_gen_en {} { 
    # Moved frm_gen_en to single point execution 
    #    bit 0 = GTF resetn
    #    bit 8 = TX Frm Gen Enable

    # Enable frm_gen_en
    hwchk_axil_write  0x0000 0x0010 0x0101
}

proc clear_frame_gen_en {} { 
    # Moved frm_gen_en to single point execution 
    #    bit 0 = GTF resetn
    #    bit 8 = TX Frm Gen Enable

    # Disable frm_gen_en
    hwchk_axil_write  0x0000 0x0010 0x0001
}

#proc run_channel { channel } { 
#    # Set address offset for this channel....
#    set addr_offset [lindex $::ADDR_OFFSET_CHAN $channel]
#    
#    set temp [format "   Channel %d..." $channel]
#    display_header $temp 1
#    
#    set addr  0x0020
#    set data  0x0000
#    set data  [expr $data | (1 << 0)]
#    set data  [expr $data | (1 << 4)]
#    hwchk_axil_write  $addr_offset $addr $data
#}


#
# This procedure reports on the number of received packets and error status
#                       
proc read_status { channel cycle} { 
    # Set address offset for this channel....
    set addr_offset [lindex $::ADDR_OFFSET_CHAN $channel]

    set addr    0x11c
    set data0   [hwchk_axil_read $addr_offset $addr]
    set addr    0x120
    set data1   [hwchk_axil_read $addr_offset $addr]
    set addr    0x124
    set data2   [hwchk_axil_read $addr_offset $addr]
    set addr    0x128
    set data3   [hwchk_axil_read $addr_offset $addr]
    
    puts [format "Cycle %d Channel %d, Packets = %d, FIFO Wr Count = %d, FIFO RD Count = %d, FIFO ERR Count = %d" $cycle $channel $data0 $data1 $data2 [expr $data3 & 0xFFFF]]
    
    hwchk_axil_write  0x0000 0x0010 0x03
    
    if { [expr $data3 & 0xFFFF] > 0x0 } {
        puts [format "ERROR - Data integrity"]
        ERROR  "Data integrity"
    }
}





