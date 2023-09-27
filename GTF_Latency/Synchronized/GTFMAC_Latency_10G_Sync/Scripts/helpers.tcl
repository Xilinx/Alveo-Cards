#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

# Release GTWiz via VIO
proc reset_vio {} {
    puts "========================================"
    puts "Resetting hb_gtwiz_reset_all_in..."
	puts "========================================"
    reset_hw_vio_outputs [get_hw_vios]
    # vio_inst -> vio_top_level
    set_property OUTPUT_VALUE 1 [get_hw_probes hb_gtwiz_reset_all_in -of_objects [get_hw_vios -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"vio_top_level"}]]
    commit_hw_vio [get_hw_probes {hb_gtwiz_reset_all_in} -of_objects [get_hw_vios -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"vio_top_level"}]]

	sleep 2   
 
	set_property OUTPUT_VALUE 0 [get_hw_probes hb_gtwiz_reset_all_in -of_objects [get_hw_vios -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"vio_top_level"}]]
    commit_hw_vio [get_hw_probes {hb_gtwiz_reset_all_in} -of_objects [get_hw_vios -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"vio_top_level"}]]

    puts "	Reset complete..."
}

# Reset design
proc reset_design {} {
    set addr 0x10400
	puts "========================================"
    puts "Resetting design..."
	puts "========================================"
	reg_wr $addr 0x00000001 
	reg_wr $addr 0x00000000
	sleep 1
    puts "	Reset complete..."
}


# Write a device register.
# Both address and value should be presented as hex (0x...).  
# All 4 bytes must be specified (ie, including leading 00s if necessary)
proc reg_wr {address value} {
    set address [string range $address 2 [expr {[string length $address]-1}]]
	set value [format 0x%08x $value]
	create_hw_axi_txn -quiet -force wr_tx [get_hw_axis hw_axi_1] -address $address -data $value -type write
    run_hw_axi -quiet wr_tx
}

# Read a device register.  Both address and value should be presented as hex (0x...).  
proc reg_rd {address} {
    set address [string range $address 2 [expr {[string length $address]-1}]]
    create_hw_axi_txn -quiet -force rd_tx [get_hw_axis hw_axi_1] -address $address -type read
    run_hw_axi -quiet rd_tx
    return 0x[get_property DATA [get_hw_axi_txn rd_tx]]
}

proc hex2dec {largeHex} {
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


proc bringup {} {

    puts "========================================"
    puts "	Running bring-up procedure..."
    puts "========================================"
	puts ""

    set addr 0x10000
    puts "========================================"
    puts "Read the GTF currently configured data rate $addr)"
	puts "========================================"
    set mode_reg [string range [reg_rd $addr] 9 end]
	

    # Assuming the TX and RX have the same rate
    if { $mode_reg == "3" } {
        # 25G
        set rate 1
        puts "	GTF is configured for 25G"
    } elseif { $mode_reg == "0" } {
        # 10G
        set rate 0
        puts "	GTF is configured for 10G"
    } else {
        puts "	ERROR - invalid rate!"
		puts "	Exiting script"
		break
    }


#redundant data rate write
reg_wr 0x10000 [format 0x%08X $mode_reg]

    puts "========================================"
	puts "Set VNC Data Rate to Match GTFMAC"
    puts "========================================"
	set addr 0x10
	reg_rmw $addr 0 1 0b${rate}
	reg_rmw $addr 16 1 0b${rate}

	puts ""
    puts "========================================"
    puts "Read GTF status from VNC."
    puts "========================================"
    set data [reg_rd 0x0]
    puts "	gtf_status = $data"
	
 	# Enable tx_userrdy / rx_userrdy
    set addr 0xC
    puts "	Enable tx_userrdy / rx_userrdy ($addr)"
    reg_wr $addr 0x00000003 
	
	
	# Configure loop back register, depending on loopback mode defined in test
    if {$::loopback_mode == 0} {
        set addr 0x10408
		puts ""
        puts "	Configure near-end loopback ($addr)"
        reg_wr $addr 0x00000021 
    } elseif {$::loopback_mode == 1} {
        set addr 0x10408
		puts ""
        puts "	Configure external loopback ($addr)"
        reg_wr $addr 0x00000001
    }





    # Lock in the loopback mode - per the UG1549
	set addr 0x4
	puts ""
    puts "========================================"
    puts "Assert rxpmareset ($addr)"
    puts "========================================"
    reg_wr $addr 0x00000200 
    reg_wr $addr 0x00000000 

	sleep 1
	
    set addr 0x108
	puts ""
	puts "========================================"
    puts "Display RX clock ($addr)"
    puts "========================================"
    set data [reg_rd $addr]
    set freq [expr [hex2dec [string range $data 2 end]] / 1000 / 1000]
    puts "	rxusrclk = $data ($freq MHz)"


    set addr 0xa4
	puts ""
    puts "========================================"
    puts "Clear gb_seq_sync and allow MAC side of the GTFMAC to bitslip ($addr)"
    puts "========================================"
    reg_wr $addr 0x00000000
	sleep 1

    if { $rate == 0 } {

        set addr 0xa4
		puts ""
		puts "========================================"
        puts "10G:  Allow GTF to correct bitslip in the transceiver ($addr)"
		puts "========================================"
        reg_wr $addr 0x00000001
        sleep 1

		set addr 0xa0
		puts "========================================"
		puts "Reading HWCHK BISTSLIP CONFIG 1 (Reg $addr)"
		puts "========================================"
		set data [reg_rd $addr]
		set bitslip_issued_cnt_gtfmac	[bitvalue $data 6 0]
		set bitslip_issued_cnt_hwchk	[bitvalue $data 14 8]
		set bitslip_locked				[bitvalue $data 16 16]
		set bitslip_busy				[bitvalue $data 17 17]
		set bitslip_done				[bitvalue $data 18 18]
		set bitslip_gt127				[bitvalue $data 19 19]

		puts "Reg $addr						= $data"
		puts "	bitslip_issued_cnt_gtfmac	= $bitslip_issued_cnt_gtfmac"
		puts "	bitslip_issued_cnt_hwchk	= $bitslip_issued_cnt_hwchk"
		puts "	bitslip_locked				= $bitslip_locked"
		puts "	bitslip_busy				= $bitslip_busy"
		puts "	bitslip_done				= $bitslip_done"
		puts "	bitslip_gt127				= $bitslip_gt127"

    }

    set addr 0x10130
	puts ""
	puts "========================================"
	puts "Clear, then read, GTF RX block_lock status from GTFMAC ($addr)"
    puts "========================================"
    reg_wr $addr 0xFFFFFFFF
    set data [reg_rd $addr]
	puts "status = $data"
	if {$data == 0x1} {
		puts "Block lock received from GTFMAC"
	} else {
		puts "Error: GTFMAC block lock failed"
		break
	}
	 after 100



    set addr 0x0
	puts ""
	puts "========================================"
    puts "Reading link status from VNC ($addr)"
    puts "========================================"
    set data [reg_rd $addr]
    puts "status = $data"
	
	if {$data == 0x10} {
		puts "	VNC: Block lock received, ready to send traffic"
	} else {
		puts "	Error: VNC block lock failed"
		break
	}
	after 100
}


proc send_pkts {} {

	set addr 0x10130
	puts "Clear, then read, block_lock status from GTFMAC ($addr)"
	set addr $addr
	reg_wr $addr 0xFFFFFFFF
	set data [reg_rd $addr]
	puts "status = $data"
	if {$data == 0x1} {
		puts "Block lock received from GTFMAC"
	} else {
		puts "Error: GTFMAC block lock failed"
		break
	}
	 after 100


	set addr 0x8000
	puts "Enable the latency monitor ($addr)"
	reg_wr $addr 0x00000001

	set addr 0x20
	puts "Enable the frame generator and monitor ($addr)"
	reg_wr $addr 0x00000011

	sleep 2


	if {$::pkt_cnt > 0} {
		# Check to see if test completed successfully
		set busy [string range [reg_rd 0x20] 9 end]
		if { $busy == 1 } {
			puts "  **************** Packets not received.  Expecting $::pkt_cnt.  Canceling test. ****************"
		}
	} else {
		# for continuous pkts
		puts "sending traffic for $::test_duration seconds"
		sleep $::test_duration
		puts "Done"
	}

	set addr 0x8000
	puts "Disable the latency monitor ($addr)"
	reg_wr $addr 0x00000000

	set addr 0x20
	puts "Disable the frame generator then monitor ($addr)"
	reg_wr $addr 0x00000010
	reg_wr $addr 0x00000000

	if {$::get_stats} {
		puts "Collect stats"
		get_stats
		source -notrace stats_display_compare.tcl
	}

	puts "Collect latency records"
	get_latency

}

proc setup_vnc {} {
	#GTFMAC Controls #############################################
	set ctl_tx_fcs_ins_enable 1
	set ctl_tx_ignore_fcs 0
	set ctl_tx_custom_preamble_enable 0
	set ctl_tx_packet_framing_enable 0
	#default ipg = 12
	set ctl_tx_ipg 12
	set ctl_tx_start_framing_enable 1

	set ctl_rx_ignore_fcs 0
	set ctl_rx_check_sfd 0
	set ctl_rx_check_preamble 0
	set ctl_rx_custom_preamble_enable 0
	set ctl_rx_packet_framing_enable 0

	#VNC Controls #################################################
	#set pkt_cnt 60
	set ctl_vnc_frm_gen_mode 0
	set ctl_tx_variable_ipg 0
	set ctl_vnc_tx_inj_err 0
	set ctl_vnc_tx_inj_poison 0

	#remainder matches GTFMAC
	set ctl_vnc_tx_fcs_ins_enable $ctl_tx_fcs_ins_enable
	set ctl_vnc_tx_custom_preamble_enable $ctl_tx_custom_preamble_enable
	set ctl_vnc_tx_start_framing_enable $ctl_tx_start_framing_enable
	set ctl_vnc_rx_packet_framing_enable $ctl_rx_packet_framing_enable
	set ctl_vnc_rx_custom_preamble_enable $ctl_rx_custom_preamble_enable


bringup


#Control Num Packets/Traffic Time ############################
puts "Sending $::pkt_cnt frames."
set addr 0x2c
set pkt_cnt_hex [format 0x%08X $::pkt_cnt]
puts "Configure VNC frame send count ($addr)"
puts "  frames_to_send=$pkt_cnt_hex  ($::pkt_cnt)"
reg_wr $addr $pkt_cnt_hex



    set addr 0x10000
    puts "Collect the currently configured data rate from the GTF ($addr)"
    set mode_reg [string range [reg_rd $addr] 9 end]
    # Assuming the TX and RX have the same rate
    if { $mode_reg == "3" } {
        # 25G
        set rate 1
        puts "	GTF is configured for 25G"
    } elseif { $mode_reg == "0" } {
        # 10G
        set rate 0
        puts "	GTF is configured for 10G"
    } else {
        puts "	ERROR - invalid rate!"
		puts "	Exiting script"
		break
    }



#redundant data rate write
reg_wr 0x10000 [format 0x%08X $mode_reg]


    set addr 0x10004 
    puts "Configure CONFIGURATION_TX_REG1 ($addr)"
	puts "  ctl_tx_fcs_ins_enable =$ctl_tx_fcs_ins_enable"
	puts "  ctl_tx_ignore_fcs =$ctl_tx_ignore_fcs"
	puts "  ctl_tx_custom_preamble_enable = $ctl_tx_custom_preamble_enable" 
	puts "  ctl_tx_packet_framing_enable = $ctl_tx_packet_framing_enable" 
	puts "  ctl_tx_start_framing_enable = $ctl_tx_start_framing_enable" 
	#default val
    reg_wr $addr 0x00000c03

	reg_rmw $addr 1 4 0b${ctl_tx_packet_framing_enable}${ctl_tx_custom_preamble_enable}${ctl_tx_ignore_fcs}${ctl_tx_fcs_ins_enable}
	reg_rmw $addr 8 5 0x${ctl_tx_start_framing_enable}[format %X $ctl_tx_ipg]


set addr 0x10008
puts "Configure CONFIGURATION_RX_REG1 ($addr)"
puts "  ctl_rx_ignore_fcs=$ctl_rx_ignore_fcs"
puts "  ctl_rx_packet_framing_enable=$ctl_rx_packet_framing_enable"
puts "  ctl_rx_custom_preamble_enable=$ctl_rx_custom_preamble_enable"
puts "  ctl_rx_check_preamble=$ctl_rx_check_preamble"
puts "  ctl_rx_check_sfd=$ctl_rx_check_sfd"
#default val
reg_wr $addr 0x00000039

reg_rmw $addr 2 1 0b${ctl_rx_ignore_fcs}
reg_rmw $addr 4 4 0b${ctl_rx_packet_framing_enable}${ctl_rx_custom_preamble_enable}${ctl_rx_check_preamble}${ctl_rx_check_sfd}



set addr 0x10
puts "Configure VNC Control ($addr)"
puts "  ctl_tx_data_rate=$rate"
puts "  ctl_rx_data_rate=$rate"

puts "  ctl_vnc_tx_fcs_ins_enable=$ctl_vnc_tx_fcs_ins_enable"
puts "  ctl_vnc_tx_custom_preamble_enable=$ctl_vnc_tx_custom_preamble_enable"
puts "  ctl_vnc_tx_start_framing_enable=$ctl_vnc_tx_start_framing_enable"
puts "  ctl_vnc_rx_packet_framing_enable=$ctl_vnc_rx_packet_framing_enable"
puts "  ctl_vnc_rx_custom_preamble_enable=$ctl_vnc_rx_custom_preamble_enable"

reg_wr $addr 0x0${ctl_vnc_rx_custom_preamble_enable}${ctl_vnc_rx_packet_framing_enable}${rate}${ctl_vnc_tx_start_framing_enable}${ctl_vnc_tx_custom_preamble_enable}${ctl_vnc_tx_fcs_ins_enable}${rate}

if {$ctl_vnc_tx_inj_err} {
	set addr 0x40
	puts "Configure VNC for Error Injection ($addr)"
	reg_wr $addr 0x0000000${ctl_vnc_tx_inj_err}
}

if {$ctl_vnc_tx_inj_poison} {
	set addr 0x98
	puts "Configure VNC for Poison Injection ($addr)"
	reg_wr $addr 0x0000000${ctl_vnc_tx_inj_poison}
}

puts "set vnc custom preambles"
#tx custom lower
set addr1 0x30

#tx custom upper
set addr2 0x34

#rx custom lower
set addr3 0x38

#rx custom upper
set addr4 0x3C

puts "write to vnc custom preamble"

#NOTE: only upper 56 bits are read. least signif byte is replaced with start codeword on receive
#default preamble value is 0xd555_5555_5555_5555
#tx custom preamble
reg_wr $addr1 0xdeadbead
reg_wr $addr2 0xbad0beef

#rx_custom preamble
reg_wr $addr3 0xdeadbead
reg_wr $addr4 0xbad0beef

set_frame_length 0x00000040 0x00002580

set addr 0x14
puts "Configure VNC frame generation mode ($addr)"
puts "  Note:  creating a rising edge on the frm_gen_mode"
puts "         to ensure that VNC starts with the min_frm_len."
reg_wr $addr 0x00000000
after 200
reg_wr $addr 0x00000001
after 200
if {$ctl_vnc_frm_gen_mode == 0} {
    puts "setting frm gen back to random mode"
	reg_wr $addr 0x00000000
}
puts "  ctl_frm_gen_mode=$ctl_vnc_frm_gen_mode    [expr {$ctl_vnc_frm_gen_mode ? "(incremental)" : "(random)"}]"
puts "  ctl_tx_variable_ipg=$ctl_tx_variable_ipg    [expr {$ctl_tx_variable_ipg ? "(enable variable IPG)" : "(disable variable IPG)"}]"



	# Clear stats (tick)
	if {$::get_stats} {
		get_stats
	}
}



proc get_latency {} {

	# Set the period of the latency measurement clock
	set addr 0x10000
	set mode_reg [string range [reg_rd $addr] 9 end]
	if { $mode_reg == "3" } {
		# 25G
		set period 2.4824
	} elseif { $mode_reg == "0" } {
		# 10G
		set period 1.5515
	} else {
		puts "ERROR - invalid rate!"
	}
	puts "Latency clock period is $period"
	
	# Set the adjustment factor - compensation for the fact that RX_TSOF is launched off of
	# the preceeding RXUSRCLK
	set adj 1
	
	
	# add back half a cycle to accommodate for 180 degree phase shift on 
	# txusrclk in phase controlled design 
	set phase_adj 0.5
	
	# Get the number of records
	set datav [reg_rd 0x8004]
	
	set lat_fifo_full [string range $datav 5 5]
	if { $lat_fifo_full > 0 } {
		puts "Latency FIFO is full.  Clearing flag."
		reg_wr 0x8004 0x00010000
	}
	
	set records_hex [string range $datav 6 end]
	set records [hex2dec $records_hex]
	
	puts "Found $records latency records"
	puts "Skipping first $::skip_first_n_records records: [expr $records - $::skip_first_n_records] records remain" 
	
	set total_latency 0
	set min_latency 1000
	set max_latency 0

	# count number of time specific latency encountered
	set cnt_3_5 0
	set cnt_4_5 0
	set cnt_5_5 0
	set cnt_x	0

if { $records > 0 } {
    for {set i 0} {$i < $records} {incr i} {
        set latency [reg_rd 0x8008]
		set records_used [expr $records- $::skip_first_n_records]
		
		# Collect records only after first $::skip_first_n_records samples
		if {$i >= $::skip_first_n_records} {
			
			set rcv_time_hex [string range $latency 2 5]
			set snd_time_hex [string range $latency 6 end]
			set rcv_time [hex2dec $rcv_time_hex] 
			set snd_time [hex2dec $snd_time_hex] 
			set delta [expr $rcv_time - $snd_time]
			if { $delta > 0 } {
				set delta_cnt [expr $rcv_time - $snd_time - $adj + $phase_adj]
				set delta_ns [format %.4f [expr $delta_cnt * $period]]
			} elseif { $delta < 0 } {
				set delta_cnt [expr 65535 - $snd_time + $rcv_time - $adj + $phase_adj]
				set delta_ns [format %.4f [expr $delta_cnt * $period]]
			}
			if { $::debug == "1" } {
				puts "Record [expr $i - $::skip_first_n_records] : $delta_ns ns ($delta_cnt clocks))"
			}

			# Update distribution bins
			if {$delta_cnt == 3.5} {
				incr cnt_3_5
			} elseif {$delta_cnt == 4.5} {
				incr cnt_4_5
			} elseif {$delta_cnt == 5.5} {
				incr cnt_5_5
			} else {
				incr cnt_x
			}

			set total_latency [expr $total_latency + $delta_ns]
			if { $delta_ns < $min_latency } {
				set min_latency $delta_ns
			}
			if { $delta_ns > $max_latency } {
				set max_latency $delta_ns
			}
		}
	}

		set avg_latency [format %.4f [expr $total_latency / $records_used]]
		

		set cnt_3_5_percent [expr $cnt_3_5*100 / $records_used]
		set cnt_4_5_percent [expr $cnt_4_5*100 / $records_used]
		set cnt_5_5_percent [expr $cnt_5_5*100 / $records_used]
		set cnt_x_percent [expr $cnt_x*100 / $records_used]
		

		puts ""
		puts "============================"
		puts "Test Number: $::index"
		puts "============================"


		# Put same information into log file
		puts $::fp ""
		puts $::fp "============================"
		puts $::fp "Test Number: $::index"
		puts $::fp "============================"

		# Create & display table with the latency values
		set w1 8
		set w2 8
		set	w3 8
		set wtotal_half 13

		set sep +[string repeat - $w1]+[string repeat - $w2]+[string repeat - $w3]+
		puts $sep
		puts "+       Latency (ns)       +"
		puts $sep
		puts [format "|%-*s|%-*s|%-*s|" $w1 "Min" $w2 "Avg" $w3 "Max"]
		puts $sep
		puts [format "|%*.4f|%*.4f|%*.4f|" $w1 $min_latency $w2 $avg_latency $w3 $max_latency]
		puts $sep
		puts ""

		# Put same information into log file
		puts $::fp $sep
		puts $::fp "+       Latency (ns)       +"
		puts $::fp $sep
		puts $::fp [format "|%-*s|%-*s|%-*s|" $w1 "Min" $w2 "Avg" $w3 "Max"]
		puts $::fp $sep
		puts $::fp [format "|%*.4f|%*.4f|%*.4f|" $w1 $min_latency $w2 $avg_latency $w3 $max_latency]
		puts $::fp $sep
		puts $::fp ""



		# Create & display table with the latency distribution
		set w0 12
		set w1 8
		set w2 8
		set	w3 8
		set w4 8
		set w5 8
		set	w6 8
		set wtotal 25

		set sep +[string repeat - $w0]+[string repeat - $w3]+[string repeat - $w4]+[string repeat - $w5]+[string repeat - $w6]+
		puts $sep
		puts "+           Latency Distribution (clocks)        +"
		puts $sep
		puts [format "|%-*s|%*s|%*s|%*s|%*s|" $w0 " " $w3 "3.5" $w4 "4.5" $w5 "5.5" $w6 "Other"]
		puts $sep
		puts [format "|%-*s|%*.d|%*.d|%*.d|%*.d|" $w0 "Clk Cnt" $w3 $cnt_3_5 $w4 $cnt_4_5 $w5 $cnt_5_5 $w6 $cnt_x]
		puts $sep
		puts [format "|%-*s|%*.d|%*.d|%*.d|%*.d|" $w0 "Clk Cnt (%)" $w3 $cnt_3_5_percent $w4 $cnt_4_5_percent $w5 $cnt_5_5_percent $w6 $cnt_x_percent]
		puts $sep

		# Put same information into log file
		puts $::fp $sep
		puts $::fp "+         Latency Distribution (clocks)        +"
		puts $::fp $sep
		puts $::fp [format "|%-*s|%*s|%*s|%*s|%*s|" $w0 " " $w3 "3.5" $w4 "4.5" $w5 "5.5" $w6 "Other"]
		puts $::fp $sep
		puts $::fp [format "|%-*s|%*.d|%*.d|%*.d|%*.d|" $w0 "Clk Cnt" $w3 $cnt_3_5 $w4 $cnt_4_5 $w5 $cnt_5_5 $w6 $cnt_x]
		puts $::fp $sep
		puts $::fp [format "|%-*s|%*.d|%*.d|%*.d|%*.d|" $w0 "Clk Cnt(%)" $w3 $cnt_3_5_percent $w4 $cnt_4_5_percent $w5 $cnt_5_5_percent $w6 $cnt_x_percent]
		puts $::fp $sep

		
	
		# Put latency info into CSV file
		puts $::fp_csv "$min_latency,$avg_latency,$max_latency" 



	} else	{
		puts ""
		puts "=========================================================================================="
		puts "No records found.  Error."
		puts "=========================================================================================="
		
		# Put same information into log file
		puts $::fp ""
		puts $::fp "=========================================================================================="
		puts $::fp "Test Number: $::index"
		puts $::fp "No records found.  Error."
		puts $::fp "=========================================================================================="
		
	}
}



proc get_stats {} {
	puts "Tick the VNC stats"
	reg_wr 0x90 0x00000001

	puts "Tick the GTFMAC soft stats"
	reg_wr 0x1040c 0x00000001

	puts "Tick the GTFMAC stats"
	reg_wr 0x10028 0x00000001
}

proc reg_rmw { address start_bit width val } {
	set read_val [reg_rd $address]
	# set read_val [expr 0x$read_val]
	set mask [expr (1 << $width) - 1]
	set mask [expr ~($mask << $start_bit)]
	set val  [expr ($read_val & $mask) | ($val << $start_bit)]
	set val [format 0x%08x $val]
	reg_wr $address $val
}

proc putsfile { outputfile text } {
	puts $text
	puts $outputfile $text
}

proc set_addr {curr_ch address} {
    variable addr
    set addr [format 0x%08x [expr $address | ($curr_ch << 20)]] 
}

proc set_frame_length { min max } {
	set addr 0x1000C
	puts "Configure gtfmac min frame length ($addr)"
	puts "  ctl_rx_min_packet_len=$min"
	reg_wr $addr $min

	set addr 0x10010
	puts "Configure gtfmac max frame length ($addr)"
	puts "  ctl_rx_max_packet_len=$max"
	reg_wr $addr $max

	set addr 0x28
	puts "Configure VNC min frame length ($addr)"
	puts "  ctl_rx_min_packet_len=$min"
	reg_wr $addr $min

	set addr 0x24
	puts "Configure VNC max frame length ($addr)"
	puts "  ctl_rx_max_packet_len=$max"
	reg_wr $addr $max

}