#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

# Reset design
proc reset_design {} {
    puts "========================================"
    puts "Resetting design..."
	puts "========================================"
    reset_hw_vio_outputs [get_hw_vios]
    set_property OUTPUT_VALUE 1 [get_hw_probes hb_gtwiz_reset_all_in -of_objects [get_hw_vios -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"vio_inst"}]]
    commit_hw_vio [get_hw_probes {hb_gtwiz_reset_all_in} -of_objects [get_hw_vios -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"vio_inst"}]]

	sleep 2   
 
	set_property OUTPUT_VALUE 0 [get_hw_probes hb_gtwiz_reset_all_in -of_objects [get_hw_vios -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"vio_inst"}]]
    commit_hw_vio [get_hw_probes {hb_gtwiz_reset_all_in} -of_objects [get_hw_vios -of_objects [get_hw_devices xcvu2p_0] -filter {CELL_NAME=~"vio_inst"}]]

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

    if { $rate == "0" } {

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
}

proc send_pkts {} {
    puts "Sending $::pkt_cnt frames."

    # Configure number of packets to send for the VNC and the Latency Monitor
    set addr 0x2c
    set lat_addr 0x8012
    set pkt_cnt_hex [format 0x%.8X $::pkt_cnt]
    puts "Configure VNC and Latency Monitor packet send count ($addr)"
    puts "frames_to_send=$pkt_cnt_hex  ($::pkt_cnt)"
    reg_wr $addr $pkt_cnt_hex
    reg_wr $lat_addr $pkt_cnt_hex

    setup_vnc

    set addr 0x8000
    puts "Enable the latency monitor ($addr)"
    reg_wr $addr 0x00000001

    set addr 0x20
    puts "Enable the frame generator and monitor ($addr)"
    reg_wr $addr 0x00000011

    # Completed if frame generator is disabled and the latency monitor is done
    puts "Poll for completion"
    set busy 1
    while { $busy == 1 } {
        sleep 1
        set frm_gen_en [string range [reg_rd 0x20] 9 end]
        set lm_delta_done [string range [reg_rd 0x8028] 9 end]
        
        # Check progress
        set delta_time_idx [hex2dec [string range [reg_rd 0x8020] 2 end]]
        puts "Sent $delta_time_idx packets..."
        set addr 0x2c
        set mode_reg [string range [reg_rd $addr] 2 end]
        puts $mode_reg

        if {[expr {$lm_delta_done & !$frm_gen_en}]} {
            set busy 0
        }
    }
    puts "Done"

    set addr 0x8000
    puts "Disable the latency monitor ($addr)"
    reg_wr $addr 0x00000000

    set addr 0x20
    puts "Disable the frame generator then monitor ($addr)"
    reg_wr $addr 0x00000010
    reg_wr $addr 0x00000000

	puts "Collect latency records"
	return [get_latency]
}

proc setup_vnc {} {
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

    set addr 0x10004 
    puts "Configure CONFIGURATION_TX_REG1 ($addr)"
    puts "  ctl_tx_fcs_ins_enable=1"
    puts "  ctl_tx_ignore_fcs=0"
    puts "  ctl_tx_custom_preamble_enable=0"
    reg_wr $addr 0x00000c03

    set addr 0x10008
    puts "Configure CONFIGURATION_RX_REG1 ($addr)"
    puts "  ctl_rx_ignore_fcs=0"
    puts "  ctl_rx_custom_preamble_enable=0"
    reg_wr $addr 0x00000039
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

    # Read from GTF the adjustment factor 
    # Compensation for the fact that RX_TSOF is launched off of the preceeding RXUSRCLK
    set adj [hex2dec [string range [reg_rd 0x8032] 2 end]]
    puts "Adjustment factor: $adj"

    # Get the number of records
    set datav [reg_rd 0x8004]

    set lat_fifo_full [string range $datav 5 5]
    if { $lat_fifo_full > 0 } {
        puts "Latency FIFO is full. Clearing flag."
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
	set cnt_1 0
	set cnt_2 0
	set cnt_3 0
	set cnt_4 0
	set cnt_5 0
	set cnt_x 0
	

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
					set delta_cnt [expr $rcv_time - $snd_time - $adj]
					set delta_ns [format %.4f [expr $delta_cnt * $period]]
				} elseif { $delta < 0 } {
					set delta_cnt [expr 65535 - $snd_time + $rcv_time - $adj]
					set delta_ns [format %.4f [expr $delta_cnt * $period]]
				}
				
				if { $::debug == "1" } {
					puts "Record [expr $i - $::skip_first_n_records] : $delta_ns ns ($delta_cnt clocks))"
				}


				# Update distribution bins
				if {$delta_cnt == 1} {
					incr cnt_1
				} elseif {$delta_cnt == 2} {
					incr cnt_2
				} elseif {$delta_cnt == 3} {
					incr cnt_3
				} elseif {$delta_cnt == 4} {
					incr cnt_4
				} elseif {$delta_cnt == 5} {
					incr cnt_5
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
		

		set cnt_1_percent [expr $cnt_1*100 / $records_used]
		set cnt_2_percent [expr $cnt_2*100 / $records_used]
		set cnt_3_percent [expr $cnt_3*100 / $records_used]
		set cnt_4_percent [expr $cnt_4*100 / $records_used]
		set cnt_5_percent [expr $cnt_5*100 / $records_used]
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

		set sep +[string repeat - $w0]+[string repeat - $w1]+[string repeat - $w2]+[string repeat - $w3]+[string repeat - $w4]+[string repeat - $w5]+[string repeat - $w6]+
		puts $sep
		puts "+                   Latency Distribution (clocks)                +"
		puts $sep
		puts [format "|%-*s|%*s|%*s|%*s|%*s|%*s|%*s|" $w0 " " $w1 "1" $w2 "2" $w3 "3" $w4 "4" $w5 "5" $w6 "Other"]
		puts $sep
		puts [format "|%-*s|%*.d|%*.d|%*.d|%*.d|%*.d|%*.d|" $w0 "Clk Cnt" $w1 $cnt_1 $w2 $cnt_2 $w3 $cnt_3 $w4 $cnt_4 $w5 $cnt_5 $w6 $cnt_x]
		puts $sep
		puts [format "|%-*s|%*.d|%*.d|%*.d|%*.d|%*.d|%*.d|" $w0 "Clk Cnt(%)" $w1 $cnt_1_percent $w2 $cnt_2_percent $w3 $cnt_3_percent $w4 $cnt_4_percent $w5 $cnt_5_percent $w6 $cnt_x_percent]
		puts $sep

		# Put same information into log file
		puts $::fp $sep
		puts $::fp "+                   Latency Distribution (clocks)                +"
		puts $::fp $sep
		puts $::fp [format "|%-*s|%*s|%*s|%*s|%*s|%*s|%*s|" $w0 " " $w1 "1" $w2 "2" $w3 "3" $w4 "4" $w5 "5" $w6 "Other"]
		puts $::fp $sep
		puts $::fp [format "|%-*s|%*.d|%*.d|%*.d|%*.d|%*.d|%*.d|" $w0 "Clk Cnt" $w1 $cnt_1 $w2 $cnt_2 $w3 $cnt_3 $w4 $cnt_4 $w5 $cnt_5 $w6 $cnt_x]
		puts $::fp $sep
		puts $::fp [format "|%-*s|%*.d|%*.d|%*.d|%*.d|%*.d|%*.d|" $w0 "Clk Cnt(%)" $w1 $cnt_1_percent $w2 $cnt_2_percent $w3 $cnt_3_percent $w4 $cnt_4_percent $w5 $cnt_5_percent $w6 $cnt_x_percent]
		puts $::fp $sep

		
	
		# Put latency info into CSV file
		puts $::fp_csv "$min_latency,$avg_latency,$max_latency" 



	} else	{
		puts ""
		puts "=========================================================================================="
		puts "Test Number: $::index"
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


