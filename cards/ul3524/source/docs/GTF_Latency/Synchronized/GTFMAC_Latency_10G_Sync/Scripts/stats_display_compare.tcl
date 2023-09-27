#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

source -notrace helpers.tcl


proc stats_comparison {stat1 name1 stat2 name2 } {
	if { $stat1 == $stat2 } {
		puts $::fp_stats "PASS:: $name1 compared to $name2 : [hex2dec [string range $stat1 2 end]] is equal to [hex2dec [string range $stat2 2 end]]"
		return 1
	} else {
		puts $::fp_stats "FAIL!:: $name1 compared to $name2 : [hex2dec [string range $stat1 2 end]] is not equal to [hex2dec [string range $stat2 2 end]] "
		return 0
	}
}
proc show_stat_value {addr name } {
	set val [reg_rd $addr]
	set set_len 50
	set name_len [string length $name]
	set space_len [expr { $set_len - $name_len }]
	set space [string repeat " " $space_len]
	puts $::fp_stats "$name $space= $val ([hex2dec [string range $val 2 end]])"
	return $val
}

proc show_var_value {var name } {
	set val $var
	set set_len 50
	set name_len [string length $name]
	set space_len [expr { $set_len - $name_len }]
	set space [string repeat " " $space_len]
	puts $::fp_stats "$name $space= $val ([expr $val * 1])"
	return $val
}

proc lsb_msb_append { lsb msb } {
	set msb [format 0x%x $msb]
	if { $msb == 0x0} {
	    set lsb [format 0x%x $lsb]
		return $lsb
	} else {
		set lsb [string range $lsb 2 end]
		set sum $msb
		append sum $lsb
		return $sum
	}
}

proc lsb_msb_append_4h { lsb msb } {
	set shifted_msb	[format 0x%x [expr {$msb * 0x10000}]]
	set sum [format 0x%x [expr {$lsb + $shifted_msb}]]
    return $sum

}
proc val_larger {stat_name stat_val expected_val } {
	if { $stat_val > $expected_val} {
		puts $::fp_stats "PASS:: $stat_name : [hex2dec [string range $stat_val 2 end]] is larger than [hex2dec [string range $expected_val 2 end]]"
		return 1
		
	} else { 
		puts $::fp_stats "FAIL!:: $stat_name : [hex2dec [string range $stat_val 2 end]] is not larger to [hex2dec [string range $expected_val 2 end]]"
		return 0
	}
}


proc val_compare {stat_name stat_val expected_val } {

	if { $stat_val == $expected_val} {
		puts $::fp_stats "PASS:: $stat_name : [hex2dec [string range $stat_val 2 end]] is equal to [hex2dec [string range $expected_val 2 end]]"
		return 1
		
	} else { 
		puts $::fp_stats "FAIL!:: $stat_name : [hex2dec [string range $stat_val 2 end]] is not equal to [hex2dec [string range $expected_val 2 end]]"
		return 0
	}	
}

proc stat_val_compare {stat_name stat_val expected_val } {

	if { $stat_val == $expected_val} {
		puts $::fp_stats "PASS:: $stat_name : $stat_val is equal to $expected_val"
		return 1
		
	} else { 
		puts $::fp_stats "FAIL!:: $stat_name : $stat_val is not equal to $expected_val"
		return 0
	}
	
}

proc non_sticky_read {addr name } { 
	set addr $addr
	reg_wr $addr 0xFFFFFFFF
	set data [reg_rd $addr]
	set set_len 50
	set name_len [string length $name]
	set space_len [expr { $set_len - $name_len }]
	set space [string repeat " " $space_len]
	puts $::fp_stats "$name $space= $data ([hex2dec [string range $data 2 end]])"
	return $data

}

proc test_check { prev cur } {
	return [expr { $prev * $cur } ]
}

 
set result 1
puts $::fp_stats "************VNC stats************"
puts $::fp_stats "~~tx side~~"
set addr 0x400; set stat_vnc_tx_unicast_lsb                [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_unicast_lsb						              = $stat_vnc_tx_unicast_lsb ([hex2dec [string range $stat_vnc_tx_unicast_lsb 2 end]])"
set addr 0x404; set stat_vnc_tx_unicast_msb                [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_unicast_msb                                   = $stat_vnc_tx_unicast_msb ([hex2dec [string range $stat_vnc_tx_unicast_msb 2 end]])"
set addr 0x408; set stat_vnc_tx_multicast_lsb              [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_multicast_lsb                                 = $stat_vnc_tx_multicast_lsb ([hex2dec [string range $stat_vnc_tx_multicast_lsb 2 end]])"
set addr 0x40C; set stat_vnc_tx_multicast_msb              [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_multicast_msb                                 = $stat_vnc_tx_multicast_msb ([hex2dec [string range $stat_vnc_tx_multicast_msb 2 end]])"
set addr 0x410; set stat_vnc_tx_broadcast_lsb              [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_broadcast_lsb                                 = $stat_vnc_tx_broadcast_lsb ([hex2dec [string range $stat_vnc_tx_broadcast_lsb 2 end]])"
set addr 0x414; set stat_vnc_tx_broadcast_msb              [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_broadcast_msb                                 = $stat_vnc_tx_broadcast_msb ([hex2dec [string range $stat_vnc_tx_broadcast_msb 2 end]])"
set addr 0x418; set stat_vnc_tx_vlan_lsb                   [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_vlan_lsb                                      = $stat_vnc_tx_vlan_lsb ([hex2dec [string range $stat_vnc_tx_vlan_lsb 2 end]])"
set addr 0x41C; set stat_vnc_tx_vlan_msb                   [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_vlan_msb                                      = $stat_vnc_tx_vlan_msb ([hex2dec [string range $stat_vnc_tx_vlan_msb 2 end]])"
set addr 0x420; set stat_vnc_tx_total_packets_lsb          [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_total_packets_lsb                             = $stat_vnc_tx_total_packets_lsb ([hex2dec [string range $stat_vnc_tx_total_packets_lsb 2 end]])"
set addr 0x424; set stat_vnc_tx_total_packets_msb          [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_total_packets_msb                             = $stat_vnc_tx_total_packets_msb ([hex2dec [string range $stat_vnc_tx_total_packets_msb 2 end]])"
set addr 0x428; set stat_vnc_tx_total_bytes_lsb            [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_total_bytes_lsb                               = $stat_vnc_tx_total_bytes_lsb ([hex2dec [string range $stat_vnc_tx_total_bytes_lsb 2 end]])"
set addr 0x42C; set stat_vnc_tx_total_bytes_msb            [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_total_bytes_msb                               = $stat_vnc_tx_total_bytes_msb ([hex2dec [string range $stat_vnc_tx_total_bytes_msb 2 end]])"
set addr 0x430; set stat_vnc_tx_total_good_packets_lsb     [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_total_good_packets_lsb                        = $stat_vnc_tx_total_good_packets_lsb ([hex2dec [string range $stat_vnc_tx_total_good_packets_lsb 2 end]])"
set addr 0x434; set stat_vnc_tx_total_good_packets_msb     [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_total_good_packets_msb                        = $stat_vnc_tx_total_good_packets_msb ([hex2dec [string range $stat_vnc_tx_total_good_packets_msb 2 end]])"
set addr 0x438; set stat_vnc_tx_total_good_bytes_lsb       [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_total_good_bytes_lsb                          = $stat_vnc_tx_total_good_bytes_lsb ([hex2dec [string range $stat_vnc_tx_total_good_bytes_lsb 2 end]])"
set addr 0x43C; set stat_vnc_tx_total_good_bytes_msb       [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_total_good_bytes_msb                          = $stat_vnc_tx_total_good_bytes_msb ([hex2dec [string range $stat_vnc_tx_total_good_bytes_msb 2 end]])"
set addr 0x440; set stat_vnc_tx_packet_64_bytes_lsb        [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_64_bytes_lsb                           = $stat_vnc_tx_packet_64_bytes_lsb ([hex2dec [string range $stat_vnc_tx_packet_64_bytes_lsb 2 end]])"
set addr 0x444; set stat_vnc_tx_packet_64_bytes_msb        [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_64_bytes_msb                           = $stat_vnc_tx_packet_64_bytes_msb ([hex2dec [string range $stat_vnc_tx_packet_64_bytes_msb 2 end]])"
set addr 0x448; set stat_vnc_tx_packet_65_127_bytes_lsb    [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_65_127_bytes_lsb                       = $stat_vnc_tx_packet_65_127_bytes_lsb ([hex2dec [string range $stat_vnc_tx_packet_65_127_bytes_lsb 2 end]])"
set addr 0x44C; set stat_vnc_tx_packet_65_127_bytes_msb    [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_65_127_bytes_msb                       = $stat_vnc_tx_packet_65_127_bytes_msb ([hex2dec [string range $stat_vnc_tx_packet_65_127_bytes_msb 2 end]])"
set addr 0x450; set stat_vnc_tx_packet_128_255_bytes_lsb   [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_128_255_bytes_lsb                      = $stat_vnc_tx_packet_128_255_bytes_lsb ([hex2dec [string range $stat_vnc_tx_packet_128_255_bytes_lsb 2 end]])"
set addr 0x454; set stat_vnc_tx_packet_128_255_bytes_msb   [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_128_255_bytes_msb                      = $stat_vnc_tx_packet_128_255_bytes_msb ([hex2dec [string range $stat_vnc_tx_packet_128_255_bytes_msb 2 end]])"
set addr 0x458; set stat_vnc_tx_packet_256_511_bytes_lsb   [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_256_511_bytes_lsb                      = $stat_vnc_tx_packet_256_511_bytes_lsb ([hex2dec [string range $stat_vnc_tx_packet_256_511_bytes_lsb 2 end]])"
set addr 0x45C; set stat_vnc_tx_packet_256_511_bytes_msb   [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_256_511_bytes_msb                      = $stat_vnc_tx_packet_256_511_bytes_msb ([hex2dec [string range $stat_vnc_tx_packet_256_511_bytes_msb 2 end]])"
set addr 0x460; set stat_vnc_tx_packet_512_1023_bytes_lsb  [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_512_1023_bytes_lsb                     = $stat_vnc_tx_packet_512_1023_bytes_lsb ([hex2dec [string range $stat_vnc_tx_packet_512_1023_bytes_lsb 2 end]])"
set addr 0x464; set stat_vnc_tx_packet_512_1023_bytes_msb  [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_512_1023_bytes_msb                     = $stat_vnc_tx_packet_512_1023_bytes_msb ([hex2dec [string range $stat_vnc_tx_packet_512_1023_bytes_msb 2 end]])"
set addr 0x468; set stat_vnc_tx_packet_1024_1518_bytes_lsb [reg_rd $addr] ;    	puts $::fp_stats "stat_vnc_tx_packet_1024_1518_bytes_lsb                    = $stat_vnc_tx_packet_1024_1518_bytes_lsb  ([hex2dec [string range $stat_vnc_tx_packet_1024_1518_bytes_lsb  2 end]])"
set addr 0x46C; set stat_vnc_tx_packet_1024_1518_bytes_msb [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_1024_1518_bytes_msb                    = $stat_vnc_tx_packet_1024_1518_bytes_msb ([hex2dec [string range $stat_vnc_tx_packet_1024_1518_bytes_msb 2 end]])"
set addr 0x470; set stat_vnc_tx_packet_1519_1522_bytes_lsb [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_1519_1522_bytes_lsb                    = $stat_vnc_tx_packet_1519_1522_bytes_lsb  ([hex2dec [string range $stat_vnc_tx_packet_1519_1522_bytes_lsb  2 end]])"
set addr 0x474; set stat_vnc_tx_packet_1519_1522_bytes_msb [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_1519_1522_bytes_msb                    = $stat_vnc_tx_packet_1519_1522_bytes_msb ([hex2dec [string range $stat_vnc_tx_packet_1519_1522_bytes_msb 2 end]])"
set addr 0x478; set stat_vnc_tx_packet_1523_1548_bytes_lsb [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_1523_1548_bytes_lsb                    = $stat_vnc_tx_packet_1523_1548_bytes_lsb ([hex2dec [string range $stat_vnc_tx_packet_1523_1548_bytes_lsb 2 end]])"
set addr 0x47C; set stat_vnc_tx_packet_1523_1548_bytes_msb [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_1523_1548_bytes_msb                    = $stat_vnc_tx_packet_1523_1548_bytes_msb ([hex2dec [string range $stat_vnc_tx_packet_1523_1548_bytes_msb 2 end]])"
set addr 0x480; set stat_vnc_tx_packet_1549_2047_bytes_lsb [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_1549_2047_bytes_lsb                    = $stat_vnc_tx_packet_1549_2047_bytes_lsb ([hex2dec [string range $stat_vnc_tx_packet_1549_2047_bytes_lsb 2 end]])"
set addr 0x484; set stat_vnc_tx_packet_1549_2047_bytes_msb [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_1549_2047_bytes_msb                    = $stat_vnc_tx_packet_1549_2047_bytes_msb ([hex2dec [string range $stat_vnc_tx_packet_1549_2047_bytes_msb 2 end]])"
set addr 0x488; set stat_vnc_tx_packet_2048_4095_bytes_lsb [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_2048_4095_bytes_lsb                    = $stat_vnc_tx_packet_2048_4095_bytes_lsb ([hex2dec [string range $stat_vnc_tx_packet_2048_4095_bytes_lsb 2 end]])"
set addr 0x48C; set stat_vnc_tx_packet_2048_4095_bytes_msb [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_2048_4095_bytes_msb                    = $stat_vnc_tx_packet_2048_4095_bytes_msb ([hex2dec [string range $stat_vnc_tx_packet_2048_4095_bytes_msb 2 end]])"
set addr 0x490; set stat_vnc_tx_packet_4096_8191_bytes_lsb [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_4096_8191_bytes_lsb                    = $stat_vnc_tx_packet_4096_8191_bytes_lsb ([hex2dec [string range $stat_vnc_tx_packet_4096_8191_bytes_lsb 2 end]])"
set addr 0x494; set stat_vnc_tx_packet_4096_8191_bytes_msb [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_4096_8191_bytes_msb                    = $stat_vnc_tx_packet_4096_8191_bytes_msb ([hex2dec [string range $stat_vnc_tx_packet_4096_8191_bytes_msb 2 end]])"
set addr 0x498; set stat_vnc_tx_packet_8192_9215_bytes_lsb [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_8192_9215_bytes_lsb                    = $stat_vnc_tx_packet_8192_9215_bytes_lsb ([hex2dec [string range $stat_vnc_tx_packet_8192_9215_bytes_lsb 2 end]])"
set addr 0x49C; set stat_vnc_tx_packet_8192_9215_bytes_msb [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_8192_9215_bytes_msb                    = $stat_vnc_tx_packet_8192_9215_bytes_msb ([hex2dec [string range $stat_vnc_tx_packet_8192_9215_bytes_msb 2 end]])"
set addr 0x4a0; set stat_vnc_tx_packet_small_lsb           [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_small_lsb                              = $stat_vnc_tx_packet_small_lsb ([hex2dec [string range $stat_vnc_tx_packet_small_lsb 2 end]])"
set addr 0x4a4; set stat_vnc_tx_packet_small_msb           [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_small_msb                              = $stat_vnc_tx_packet_small_msb ([hex2dec [string range $stat_vnc_tx_packet_small_msb 2 end]])"
set addr 0x4a8; set stat_vnc_tx_packet_large_lsb           [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_large_lsb                              = $stat_vnc_tx_packet_large_lsb ([hex2dec [string range $stat_vnc_tx_packet_large_lsb 2 end]])"
set addr 0x4aC; set stat_vnc_tx_packet_large_msb           [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_packet_large_msb                              = $stat_vnc_tx_packet_large_msb ([hex2dec [string range $stat_vnc_tx_packet_large_msb 2 end]])"
set addr 0x4b0; set stat_vnc_tx_frame_error_lsb            [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_frame_error_lsb                               = $stat_vnc_tx_frame_error_lsb ([hex2dec [string range $stat_vnc_tx_frame_error_lsb 2 end]])"
set addr 0x4b4; set stat_vnc_tx_frame_error_msb            [reg_rd $addr] ;     puts $::fp_stats "stat_vnc_tx_frame_error_msb                               = $stat_vnc_tx_frame_error_msb ([hex2dec [string range $stat_vnc_tx_frame_error_msb 2 end]])"
set addr 0x4b8; set stat_tx_unfout                     	   [reg_rd $addr] ;     puts $::fp_stats "stat_tx_unfout                                            = $stat_tx_unfout ([hex2dec [string range $stat_tx_unfout 2 end]])"

set addr 0x030; set ctl_vnc_tx_custom_preamble_lsb [reg_rd $addr];              puts $::fp_stats "ctl_vnc_tx_custom_preamble_lsb                            = $ctl_vnc_tx_custom_preamble_lsb ([hex2dec [string range $ctl_vnc_tx_custom_preamble_lsb 2 end]])"
set addr 0x034; set ctl_vnc_tx_custom_preamble_msb [reg_rd $addr];              puts $::fp_stats "ctl_vnc_tx_custom_preamble_msb                            = $ctl_vnc_tx_custom_preamble_msb ([hex2dec [string range $ctl_vnc_tx_custom_preamble_msb 2 end]])"

puts $::fp_stats "~~rx side~~"																														                
set addr 0x600; set stat_vnc_rx_unicast_lsb [reg_rd $addr];                     puts $::fp_stats "stat_vnc_rx_unicast_lsb                                   = $stat_vnc_rx_unicast_lsb ([hex2dec [string range $stat_vnc_rx_unicast_lsb 2 end]])"
set addr 0x604; set stat_vnc_rx_unicast_msb [reg_rd $addr];                     puts $::fp_stats "stat_vnc_rx_unicast_msb                                   = $stat_vnc_rx_unicast_msb ([hex2dec [string range $stat_vnc_rx_unicast_msb 2 end]])"
set addr 0x608; set stat_vnc_rx_multicast_lsb [reg_rd $addr];                   puts $::fp_stats "stat_vnc_rx_multicast_lsb                                 = $stat_vnc_rx_multicast_lsb ([hex2dec [string range $stat_vnc_rx_multicast_lsb 2 end]])"
set addr 0x60C; set stat_vnc_rx_multicast_msb [reg_rd $addr];                   puts $::fp_stats "stat_vnc_rx_multicast_msb                                 = $stat_vnc_rx_multicast_msb ([hex2dec [string range $stat_vnc_rx_multicast_msb 2 end]])"
set addr 0x610; set stat_vnc_rx_broadcast_lsb [reg_rd $addr];                   puts $::fp_stats "stat_vnc_rx_broadcast_lsb                                 = $stat_vnc_rx_broadcast_lsb ([hex2dec [string range $stat_vnc_rx_broadcast_lsb 2 end]])"
set addr 0x614; set stat_vnc_rx_broadcast_msb [reg_rd $addr];                   puts $::fp_stats "stat_vnc_rx_broadcast_msb                                 = $stat_vnc_rx_broadcast_msb ([hex2dec [string range $stat_vnc_rx_broadcast_msb 2 end]])"
set addr 0x618; set stat_vnc_rx_vlan_lsb [reg_rd $addr];                        puts $::fp_stats "stat_vnc_rx_vlan_lsb                                      = $stat_vnc_rx_vlan_lsb ([hex2dec [string range $stat_vnc_rx_vlan_lsb 2 end]])"
set addr 0x61C; set stat_vnc_rx_vlan_msb [reg_rd $addr];                        puts $::fp_stats "stat_vnc_rx_vlan_msb                                      = $stat_vnc_rx_vlan_msb ([hex2dec [string range $stat_vnc_rx_vlan_msb 2 end]])"
																																                
set addr 0x620; set stat_vnc_rx_total_packets_lsb [reg_rd $addr];               puts $::fp_stats "stat_vnc_rx_total_packets_lsb                             = $stat_vnc_rx_total_packets_lsb ([hex2dec [string range $stat_vnc_rx_total_packets_lsb 2 end]])"
set addr 0x624; set stat_vnc_rx_total_packets_msb [reg_rd $addr];               puts $::fp_stats "stat_vnc_rx_total_packets_msb                             = $stat_vnc_rx_total_packets_msb ([hex2dec [string range $stat_vnc_rx_total_packets_msb 2 end]])"
set addr 0x628; set stat_vnc_rx_total_bytes_lsb [reg_rd $addr];                 puts $::fp_stats "stat_vnc_rx_total_bytes_lsb                               = $stat_vnc_rx_total_bytes_lsb ([hex2dec [string range $stat_vnc_rx_total_bytes_lsb 2 end]])"
set addr 0x62C; set stat_vnc_rx_total_bytes_msb [reg_rd $addr];                 puts $::fp_stats "stat_vnc_rx_total_bytes_msb                               = $stat_vnc_rx_total_bytes_msb ([hex2dec [string range $stat_vnc_rx_total_bytes_msb 2 end]])"

set addr 0x630; set stat_vnc_rx_total_good_packets_lsb [reg_rd $addr];          puts $::fp_stats "stat_vnc_rx_total_good_packets_lsb                        = $stat_vnc_rx_total_good_packets_lsb ([hex2dec [string range $stat_vnc_rx_total_good_packets_lsb 2 end]])"
set addr 0x634; set stat_vnc_rx_total_good_packets_msb [reg_rd $addr];          puts $::fp_stats "stat_vnc_rx_total_good_packets_msb                        = $stat_vnc_rx_total_good_packets_msb ([hex2dec [string range $stat_vnc_rx_total_good_packets_msb 2 end]])"
set addr 0x638; set stat_vnc_rx_total_good_bytes_lsb [reg_rd $addr];            puts $::fp_stats "stat_vnc_rx_total_good_bytes_lsb                          = $stat_vnc_rx_total_good_bytes_lsb ([hex2dec [string range $stat_vnc_rx_total_good_bytes_lsb 2 end]])"
set addr 0x63C; set stat_vnc_rx_total_good_bytes_msb [reg_rd $addr];            puts $::fp_stats "stat_vnc_rx_total_good_bytes_msb                          = $stat_vnc_rx_total_good_bytes_msb ([hex2dec [string range $stat_vnc_rx_total_good_bytes_msb 2 end]])"
																															                
set addr 0x640; set stat_vnc_rx_packet_64_bytes_lsb [reg_rd $addr];             puts $::fp_stats "stat_vnc_rx_packet_64_bytes_lsb                           = $stat_vnc_rx_packet_64_bytes_lsb ([hex2dec [string range $stat_vnc_rx_packet_64_bytes_lsb 2 end]])"
set addr 0x644; set stat_vnc_rx_packet_64_bytes_msb [reg_rd $addr];             puts $::fp_stats "stat_vnc_rx_packet_64_bytes_msb                           = $stat_vnc_rx_packet_64_bytes_msb ([hex2dec [string range $stat_vnc_rx_packet_64_bytes_msb 2 end]])"
set addr 0x648; set stat_vnc_rx_packet_65_127_bytes_lsb [reg_rd $addr];         puts $::fp_stats "stat_vnc_rx_packet_65_127_bytes_lsb                       = $stat_vnc_rx_packet_65_127_bytes_lsb ([hex2dec [string range $stat_vnc_rx_packet_65_127_bytes_lsb 2 end]])"
set addr 0x64C; set stat_vnc_rx_packet_65_127_bytes_msb [reg_rd $addr];         puts $::fp_stats "stat_vnc_rx_packet_65_127_bytes_msb                       = $stat_vnc_rx_packet_65_127_bytes_msb ([hex2dec [string range $stat_vnc_rx_packet_65_127_bytes_msb 2 end]])"
set addr 0x650; set stat_vnc_rx_packet_128_255_bytes_lsb [reg_rd $addr];        puts $::fp_stats "stat_vnc_rx_packet_128_255_bytes_lsb                      = $stat_vnc_rx_packet_128_255_bytes_lsb ([hex2dec [string range $stat_vnc_rx_packet_128_255_bytes_lsb 2 end]])"
set addr 0x654; set stat_vnc_rx_packet_128_255_bytes_msb [reg_rd $addr];        puts $::fp_stats "stat_vnc_rx_packet_128_255_bytes_msb                      = $stat_vnc_rx_packet_128_255_bytes_msb ([hex2dec [string range $stat_vnc_rx_packet_128_255_bytes_msb 2 end]])"
set addr 0x658; set stat_vnc_rx_packet_256_511_bytes_lsb [reg_rd $addr];        puts $::fp_stats "stat_vnc_rx_packet_256_511_bytes_lsb                      = $stat_vnc_rx_packet_256_511_bytes_lsb ([hex2dec [string range $stat_vnc_rx_packet_256_511_bytes_lsb 2 end]])"
set addr 0x65C; set stat_vnc_rx_packet_256_511_bytes_msb [reg_rd $addr];        puts $::fp_stats "stat_vnc_rx_packet_256_511_bytes_msb                      = $stat_vnc_rx_packet_256_511_bytes_msb ([hex2dec [string range $stat_vnc_rx_packet_256_511_bytes_msb 2 end]])"
set addr 0x660; set stat_vnc_rx_packet_512_1023_bytes_lsb [reg_rd $addr];       puts $::fp_stats "stat_vnc_rx_packet_512_1023_bytes_lsb                     = $stat_vnc_rx_packet_512_1023_bytes_lsb ([hex2dec [string range $stat_vnc_rx_packet_512_1023_bytes_lsb 2 end]])"
set addr 0x664; set stat_vnc_rx_packet_512_1023_bytes_msb [reg_rd $addr];       puts $::fp_stats "stat_vnc_rx_packet_512_1023_bytes_msb                     = $stat_vnc_rx_packet_512_1023_bytes_msb ([hex2dec [string range $stat_vnc_rx_packet_512_1023_bytes_msb 2 end]])"
set addr 0x668; set stat_vnc_rx_packet_1024_1518_bytes_lsb [reg_rd $addr];      puts $::fp_stats "stat_vnc_rx_packet_1024_1518_bytes_lsb                    = $stat_vnc_rx_packet_1024_1518_bytes_lsb ([hex2dec [string range $stat_vnc_rx_packet_1024_1518_bytes_lsb 2 end]])"
set addr 0x66C; set stat_vnc_rx_packet_1024_1518_bytes_msb [reg_rd $addr];      puts $::fp_stats "stat_vnc_rx_packet_1024_1518_bytes_msb                    = $stat_vnc_rx_packet_1024_1518_bytes_msb ([hex2dec [string range $stat_vnc_rx_packet_1024_1518_bytes_msb 2 end]])"
set addr 0x670; set stat_vnc_rx_packet_1519_1522_bytes_lsb [reg_rd $addr];      puts $::fp_stats "stat_vnc_rx_packet_1519_1522_bytes_lsb                    = $stat_vnc_rx_packet_1519_1522_bytes_lsb ([hex2dec [string range $stat_vnc_rx_packet_1519_1522_bytes_lsb 2 end]])"
set addr 0x674; set stat_vnc_rx_packet_1519_1522_bytes_msb [reg_rd $addr];      puts $::fp_stats "stat_vnc_rx_packet_1519_1522_bytes_msb                    = $stat_vnc_rx_packet_1519_1522_bytes_msb ([hex2dec [string range $stat_vnc_rx_packet_1519_1522_bytes_msb 2 end]])"
set addr 0x678; set stat_vnc_rx_packet_1523_1548_bytes_lsb [reg_rd $addr];      puts $::fp_stats "stat_vnc_rx_packet_1523_1548_bytes_lsb                    = $stat_vnc_rx_packet_1523_1548_bytes_lsb ([hex2dec [string range $stat_vnc_rx_packet_1523_1548_bytes_lsb 2 end]])"
set addr 0x67C; set stat_vnc_rx_packet_1523_1548_bytes_msb [reg_rd $addr];      puts $::fp_stats "stat_vnc_rx_packet_1523_1548_bytes_msb                    = $stat_vnc_rx_packet_1523_1548_bytes_msb ([hex2dec [string range $stat_vnc_rx_packet_1523_1548_bytes_msb 2 end]])"
set addr 0x680; set stat_vnc_rx_packet_1549_2047_bytes_lsb [reg_rd $addr];      puts $::fp_stats "stat_vnc_rx_packet_1549_2047_bytes_lsb                    = $stat_vnc_rx_packet_1549_2047_bytes_lsb ([hex2dec [string range $stat_vnc_rx_packet_1549_2047_bytes_lsb 2 end]])"
set addr 0x684; set stat_vnc_rx_packet_1549_2047_bytes_msb [reg_rd $addr];      puts $::fp_stats "stat_vnc_rx_packet_1549_2047_bytes_msb                    = $stat_vnc_rx_packet_1549_2047_bytes_msb ([hex2dec [string range $stat_vnc_rx_packet_1549_2047_bytes_msb 2 end]])"
set addr 0x688; set stat_vnc_rx_packet_2048_4095_bytes_lsb [reg_rd $addr];      puts $::fp_stats "stat_vnc_rx_packet_2048_4095_bytes_lsb                    = $stat_vnc_rx_packet_2048_4095_bytes_lsb ([hex2dec [string range $stat_vnc_rx_packet_2048_4095_bytes_lsb 2 end]])"
set addr 0x68C; set stat_vnc_rx_packet_2048_4095_bytes_msb [reg_rd $addr];      puts $::fp_stats "stat_vnc_rx_packet_2048_4095_bytes_msb                    = $stat_vnc_rx_packet_2048_4095_bytes_msb ([hex2dec [string range $stat_vnc_rx_packet_2048_4095_bytes_msb 2 end]])"
set addr 0x690; set stat_vnc_rx_packet_4096_8191_bytes_lsb [reg_rd $addr];      puts $::fp_stats "stat_vnc_rx_packet_4096_8191_bytes_lsb                    = $stat_vnc_rx_packet_4096_8191_bytes_lsb ([hex2dec [string range $stat_vnc_rx_packet_4096_8191_bytes_lsb 2 end]])"
set addr 0x694; set stat_vnc_rx_packet_4096_8191_bytes_msb [reg_rd $addr];      puts $::fp_stats "stat_vnc_rx_packet_4096_8191_bytes_msb                    = $stat_vnc_rx_packet_4096_8191_bytes_msb ([hex2dec [string range $stat_vnc_rx_packet_4096_8191_bytes_msb 2 end]])"
set addr 0x698; set stat_vnc_rx_packet_8192_9215_bytes_lsb [reg_rd $addr];      puts $::fp_stats "stat_vnc_rx_packet_8192_9215_bytes_lsb                    = $stat_vnc_rx_packet_8192_9215_bytes_lsb ([hex2dec [string range $stat_vnc_rx_packet_8192_9215_bytes_lsb 2 end]])"
set addr 0x69C; set stat_vnc_rx_packet_8192_9215_bytes_msb [reg_rd $addr];      puts $::fp_stats "stat_vnc_rx_packet_8192_9215_bytes_msb                    = $stat_vnc_rx_packet_8192_9215_bytes_msb ([hex2dec [string range $stat_vnc_rx_packet_8192_9215_bytes_msb 2 end]])"
																																                
set addr 0x6a0; set stat_vnc_rx_inrangeerr_lsb [reg_rd $addr];                  puts $::fp_stats "stat_vnc_rx_inrangeerr_lsb                                = $stat_vnc_rx_inrangeerr_lsb ([hex2dec [string range $stat_vnc_rx_inrangeerr_lsb 2 end]])"
set addr 0x6a4; set stat_vnc_rx_inrangeerr_msb [reg_rd $addr];                  puts $::fp_stats "stat_vnc_rx_inrangeerr_msb                                = $stat_vnc_rx_inrangeerr_msb ([hex2dec [string range $stat_vnc_rx_inrangeerr_msb 2 end]])"
set addr 0x6a8; set stat_vnc_rx_bad_fcs_lsb [reg_rd $addr];                     puts $::fp_stats "stat_vnc_rx_bad_fcs_lsb                                   = $stat_vnc_rx_bad_fcs_lsb ([hex2dec [string range $stat_vnc_rx_bad_fcs_lsb 2 end]])"
set addr 0x6aC; set stat_vnc_rx_bad_fcs_msb [reg_rd $addr];                     puts $::fp_stats "stat_vnc_rx_bad_fcs_msb                                   = $stat_vnc_rx_bad_fcs_msb ([hex2dec [string range $stat_vnc_rx_bad_fcs_msb 2 end]])"
set addr 0x6b0; set stat_vnc_rx_oversize_lsb [reg_rd $addr];                    puts $::fp_stats "stat_vnc_rx_oversize_lsb                                  = $stat_vnc_rx_oversize_lsb ([hex2dec [string range $stat_vnc_rx_oversize_lsb 2 end]])"
set addr 0x6b4; set stat_vnc_rx_oversize_msb [reg_rd $addr];                    puts $::fp_stats "stat_vnc_rx_oversize_msb                                  = $stat_vnc_rx_oversize_msb ([hex2dec [string range $stat_vnc_rx_oversize_msb 2 end]])"
set addr 0x6b8; set stat_vnc_rx_undersize_lsb [reg_rd $addr];                   puts $::fp_stats "stat_vnc_rx_undersize_lsb                                 = $stat_vnc_rx_undersize_lsb ([hex2dec [string range $stat_vnc_rx_undersize_lsb 2 end]])"
set addr 0x6bC; set stat_vnc_rx_undersize_msb [reg_rd $addr];                   puts $::fp_stats "stat_vnc_rx_undersize_msb                                 = $stat_vnc_rx_undersize_msb ([hex2dec [string range $stat_vnc_rx_undersize_msb 2 end]])"
set addr 0x6c0; set stat_vnc_rx_toolong_lsb [reg_rd $addr];                     puts $::fp_stats "stat_vnc_rx_toolong_lsb                                   = $stat_vnc_rx_toolong_lsb ([hex2dec [string range $stat_vnc_rx_toolong_lsb 2 end]])"
set addr 0x6c4; set stat_vnc_rx_toolong_msb [reg_rd $addr];                     puts $::fp_stats "stat_vnc_rx_toolong_msb                                   = $stat_vnc_rx_toolong_msb ([hex2dec [string range $stat_vnc_rx_toolong_msb 2 end]])"
set addr 0x6c8; set stat_vnc_rx_packet_small_lsb [reg_rd $addr];                puts $::fp_stats "stat_vnc_rx_packet_small_lsb                              = $stat_vnc_rx_packet_small_lsb ([hex2dec [string range $stat_vnc_rx_packet_small_lsb 2 end]])"
set addr 0x6cC; set stat_vnc_rx_packet_small_msb [reg_rd $addr];                puts $::fp_stats "stat_vnc_rx_packet_small_msb                              = $stat_vnc_rx_packet_small_msb ([hex2dec [string range $stat_vnc_rx_packet_small_msb 2 end]])"
set addr 0x6d0; set stat_vnc_rx_packet_large_lsb [reg_rd $addr];                puts $::fp_stats "stat_vnc_rx_packet_large_lsb                              = $stat_vnc_rx_packet_large_lsb ([hex2dec [string range $stat_vnc_rx_packet_large_lsb 2 end]])"
set addr 0x6d4; set stat_vnc_rx_packet_large_msb [reg_rd $addr];                puts $::fp_stats "stat_vnc_rx_packet_large_msb                              = $stat_vnc_rx_packet_large_msb ([hex2dec [string range $stat_vnc_rx_packet_large_msb 2 end]])"
set addr 0x6d8; set stat_vnc_rx_jabber_lsb [reg_rd $addr];                      puts $::fp_stats "stat_vnc_rx_jabber_lsb                                    = $stat_vnc_rx_jabber_lsb ([hex2dec [string range $stat_vnc_rx_jabber_lsb 2 end]])"
set addr 0x6dC; set stat_vnc_rx_jabber_msb [reg_rd $addr];                      puts $::fp_stats "stat_vnc_rx_jabber_msb                                    = $stat_vnc_rx_jabber_msb ([hex2dec [string range $stat_vnc_rx_jabber_msb 2 end]])"
set addr 0x6e0; set stat_vnc_rx_fragment_lsb [reg_rd $addr];                    puts $::fp_stats "stat_vnc_rx_fragment_lsb                                  = $stat_vnc_rx_fragment_lsb ([hex2dec [string range $stat_vnc_rx_fragment_lsb 2 end]])"
set addr 0x6e4; set stat_vnc_rx_fragment_msb [reg_rd $addr];                    puts $::fp_stats "stat_vnc_rx_fragment_msb                                  = $stat_vnc_rx_fragment_msb ([hex2dec [string range $stat_vnc_rx_fragment_msb 2 end]])"
set addr 0x6e8; set stat_vnc_rx_packet_bad_fcs_lsb [reg_rd $addr];              puts $::fp_stats "stat_vnc_rx_packet_bad_fcs_lsb                            = $stat_vnc_rx_packet_bad_fcs_lsb ([hex2dec [string range $stat_vnc_rx_packet_bad_fcs_lsb 2 end]])"
set addr 0x6eC; set stat_vnc_rx_packet_bad_fcs_msb [reg_rd $addr];              puts $::fp_stats "stat_vnc_rx_packet_bad_fcs_msb                            = $stat_vnc_rx_packet_bad_fcs_msb ([hex2dec [string range $stat_vnc_rx_packet_bad_fcs_msb 2 end]])"
set addr 0x6f0; set stat_vnc_rx_user_pause_lsb [reg_rd $addr];                  puts $::fp_stats "stat_vnc_rx_user_pause_lsb                                = $stat_vnc_rx_user_pause_lsb ([hex2dec [string range $stat_vnc_rx_user_pause_lsb 2 end]])"
set addr 0x6f4; set stat_vnc_rx_user_pause_msb [reg_rd $addr];                  puts $::fp_stats "stat_vnc_rx_user_pause_msb                                = $stat_vnc_rx_user_pause_msb ([hex2dec [string range $stat_vnc_rx_user_pause_msb 2 end]])"
set addr 0x6f8; set stat_vnc_rx_pause_lsb [reg_rd $addr];                       puts $::fp_stats "stat_vnc_rx_pause_lsb                                     = $stat_vnc_rx_pause_lsb ([hex2dec [string range $stat_vnc_rx_pause_lsb 2 end]])"
set addr 0x6fC; set stat_vnc_rx_pause_msb [reg_rd $addr];                       puts $::fp_stats "stat_vnc_rx_pause_msb                                     = $stat_vnc_rx_pause_msb ([hex2dec [string range $stat_vnc_rx_pause_msb 2 end]])"
set addr 0x700; set stat_vnc_rx_bad_preamble_lsb [reg_rd $addr];                puts $::fp_stats "stat_vnc_rx_bad_preamble_lsb                              = $stat_vnc_rx_bad_preamble_lsb ([hex2dec [string range $stat_vnc_rx_bad_preamble_lsb 2 end]])"
set addr 0x704; set stat_vnc_rx_bad_preamble_msb [reg_rd $addr];                puts $::fp_stats "stat_vnc_rx_bad_preamble_msb                              = $stat_vnc_rx_bad_preamble_msb ([hex2dec [string range $stat_vnc_rx_bad_preamble_msb 2 end]])"

set addr 0x038; set ctl_vnc_rx_custom_preamble_lsb [reg_rd $addr];              puts $::fp_stats "ctl_vnc_rx_custom_preamble_lsb                            = $ctl_vnc_rx_custom_preamble_lsb ([hex2dec [string range $ctl_vnc_rx_custom_preamble_lsb 2 end]])"
set addr 0x03C; set ctl_vnc_rx_custom_preamble_msb [reg_rd $addr];              puts $::fp_stats "ctl_vnc_rx_custom_preamble_msb                            = $ctl_vnc_rx_custom_preamble_msb ([hex2dec [string range $ctl_vnc_rx_custom_preamble_msb 2 end]])"

puts $::fp_stats "************GTFMAC stats************"
puts $::fp_stats "~~tx side~~"
set status_tx_cycle_soft_count_lsb [show_stat_value 0x10508 "status_tx_cycle_soft_count_lsb"]
set status_tx_cycle_soft_count_msb [show_stat_value 0x1050C "status_tx_cycle_soft_count_msb"]
set stat_tx_frame_error_soft_lsb [show_stat_value 0x106A0 "stat_tx_frame_error_soft_lsb"]
set stat_tx_frame_error_soft_msb [show_stat_value 0x106A4 "stat_tx_frame_error_soft_msb"]
set stat_tx_total_packets_soft_lsb [show_stat_value 0x10700 "stat_tx_total_packets_soft_lsb"]
set stat_tx_total_packets_soft_msb [show_stat_value 0x10704 "stat_tx_total_packets_soft_msb"]
set stat_tx_total_good_packets_soft_lsb [show_stat_value 0x10708 "stat_tx_total_good_packets_soft_lsb"]
set stat_tx_total_good_packets_soft_msb [show_stat_value 0x1070C "stat_tx_total_good_packets_soft_msb"]
set stat_tx_total_bytes_soft_lsb [show_stat_value 0x10710 "stat_tx_total_bytes_soft_lsb"]
set stat_tx_total_bytes_soft_msb [show_stat_value 0x10714 "stat_tx_total_bytes_soft_msb"]
set stat_tx_total_good_bytes_soft_lsb [show_stat_value 0x10718 "stat_tx_total_good_bytes_soft_lsb"]
set stat_tx_total_good_bytes_soft_msb [show_stat_value 0x1071C "stat_tx_total_good_bytes_soft_msb"]
set stat_tx_packet_64_bytes_soft_lsb [show_stat_value 0x10720 "stat_tx_packet_64_bytes_soft_lsb"]
set stat_tx_packet_64_bytes_soft_msb [show_stat_value 0x10724 "stat_tx_packet_64_bytes_soft_msb"]
set stat_tx_packet_65_127_bytes_soft_lsb [show_stat_value 0x10728 "stat_tx_packet_65_127_bytes_soft_lsb"]
set stat_tx_packet_65_127_bytes_soft_msb [show_stat_value 0x1072C "stat_tx_packet_65_127_bytes_soft_msb"]
set stat_tx_packet_128_255_bytes_soft_msb [show_stat_value 0x10734 "stat_tx_packet_128_255_bytes_soft_msb"]
set stat_tx_packet_128_255_bytes_soft_lsb [show_stat_value 0x10730 "stat_tx_packet_128_255_bytes_soft_lsb"]
set stat_tx_packet_256_511_bytes_soft_msb [show_stat_value 0x1073C "stat_tx_packet_256_511_bytes_soft_msb"]
set stat_tx_packet_256_511_bytes_soft_lsb [show_stat_value 0x10738 "stat_tx_packet_256_511_bytes_soft_lsb"]
set stat_tx_packet_512_1023_bytes_soft_msb [show_stat_value 0x10744 "stat_tx_packet_512_1023_bytes_soft_msb"]
set stat_tx_packet_512_1023_bytes_soft_lsb [show_stat_value 0x10740 "stat_tx_packet_512_1023_bytes_soft_lsb"]
set stat_tx_packet_1024_1518_bytes_soft_lsb [show_stat_value 0x10748 "stat_tx_packet_1024_1518_bytes_soft_lsb"]
set stat_tx_packet_1024_1518_bytes_soft_msb [show_stat_value 0x1074C "stat_tx_packet_1024_1518_bytes_soft_msb"]
set stat_tx_packet_1519_1522_bytes_soft_lsb [show_stat_value 0x10750 "stat_tx_packet_1519_1522_bytes_soft_lsb"]
set stat_tx_packet_1519_1522_bytes_soft_msb [show_stat_value 0x10754 "stat_tx_packet_1519_1522_bytes_soft_msb"]
set stat_tx_packet_1523_1548_bytes_soft_lsb [show_stat_value 0x10758 "stat_tx_packet_1523_1548_bytes_soft_lsb"]
set stat_tx_packet_1523_1548_bytes_soft_msb [show_stat_value 0x1075C "stat_tx_packet_1523_1548_bytes_soft_msb"]
set stat_tx_packet_1549_2047_bytes_soft_lsb [show_stat_value 0x10760 "stat_tx_packet_1549_2047_bytes_soft_lsb"]
set stat_tx_packet_1549_2047_bytes_soft_msb [show_stat_value 0x10764 "stat_tx_packet_1549_2047_bytes_soft_msb"]
set stat_tx_packet_2048_4095_bytes_soft_lsb [show_stat_value 0x10768 "stat_tx_packet_2048_4095_bytes_soft_lsb"]
set stat_tx_packet_2048_4095_bytes_soft_msb [show_stat_value 0x1076C "stat_tx_packet_2048_4095_bytes_soft_msb"]
set stat_tx_packet_4096_8191_bytes_soft_lsb [show_stat_value 0x10770 "stat_tx_packet_4096_8191_bytes_soft_lsb"]
set stat_tx_packet_4096_8191_bytes_soft_msb [show_stat_value 0x10774 "stat_tx_packet_4096_8191_bytes_soft_msb"]
set stat_tx_packet_8192_9215_bytes_soft_lsb [show_stat_value 0x10778 "stat_tx_packet_8192_9215_bytes_soft_lsb"]
set stat_tx_packet_8192_9215_bytes_soft_msb [show_stat_value 0x1077C "stat_tx_packet_8192_9215_bytes_soft_msb"]
set stat_tx_packet_large_soft_lsb [show_stat_value 0x10780 "stat_tx_packet_large_soft_lsb"]
set stat_tx_packet_large_soft_msb [show_stat_value 0x10784 "stat_tx_packet_large_soft_msb"]
set stat_tx_packet_small_soft_lsb [show_stat_value 0x10788 "stat_tx_packet_small_soft_lsb"]
set stat_tx_packet_small_soft_msb [show_stat_value 0x1078C "stat_tx_packet_small_soft_msb"]
set stat_tx_bad_fcs_soft_lsb [show_stat_value 0x107B8 "stat_tx_bad_fcs_soft_lsb"]
set stat_tx_bad_fcs_soft_msb [show_stat_value 0x107BC "stat_tx_bad_fcs_soft_msb"]
set stat_tx_unicast_soft_lsb [show_stat_value 0x107D0 "stat_tx_unicast_soft_lsb"]
set stat_tx_unicast_soft_msb [show_stat_value 0x107D4 "stat_tx_unicast_soft_msb"]
set stat_tx_multicast_soft_lsb [show_stat_value 0x107D8 "stat_tx_multicast_soft_lsb"]
set stat_tx_multicast_soft_msb [show_stat_value 0x107DC "stat_tx_multicast_soft_msb"]
set stat_tx_broadcast_soft_lsb [show_stat_value 0x107E0 "stat_tx_broadcast_soft_lsb"]
set stat_tx_broadcast_soft_msb [show_stat_value 0x107E4 "stat_tx_broadcast_soft_msb"]
set stat_tx_vlan_soft_lsb [show_stat_value 0x107E8 "stat_tx_vlan_soft_lsb"]
set stat_tx_vlan_soft_msb [show_stat_value 0x107EC "stat_tx_vlan_soft_msb"]
set stat_tx_total_err_bytes_soft_lsb [show_stat_value 0x10950 "stat_tx_total_err_bytes_soft_lsb"]
set stat_tx_total_err_bytes_soft_msb [show_stat_value 0x10954 "stat_tx_total_err_bytes_soft_msb"]

puts $::fp_stats "~~rx side~~"
set status_rx_cycle_soft_count_lsb [show_stat_value 0x10500 "status_rx_cycle_soft_count_lsb"]
set status_rx_cycle_soft_count_msb [show_stat_value 0x10504 "status_rx_cycle_soft_count_msb"]
set stat_rx_framing_err_soft_lsb [show_stat_value 0x10648 "stat_rx_framing_err_soft_lsb"]
set stat_rx_framing_err_soft_msb [show_stat_value 0x1064C "stat_rx_framing_err_soft_msb"]
set stat_rx_bad_code_soft_lsb [show_stat_value 0x10660 "stat_rx_bad_code_soft_lsb"]
set stat_rx_bad_code_soft_msb [show_stat_value 0x10664 "stat_rx_bad_code_soft_msb"]
set stat_rx_total_packets_soft_lsb [show_stat_value 0x10808 "stat_rx_total_packets_soft_lsb"]
set stat_rx_total_packets_soft_msb [show_stat_value 0x1080C "stat_rx_total_packets_soft_msb"]
set stat_rx_total_good_packets_soft_lsb [show_stat_value 0x10810 "stat_rx_total_good_packets_soft_lsb"]
set stat_rx_total_good_packets_soft_msb [show_stat_value 0x10814 "stat_rx_total_good_packets_soft_msb"]
set stat_rx_total_bytes_soft_lsb [show_stat_value 0x10818 "stat_rx_total_bytes_soft_lsb"]
set stat_rx_total_bytes_soft_msb [show_stat_value 0x1081C "stat_rx_total_bytes_soft_msb"]
set stat_rx_total_good_bytes_soft_lsb [show_stat_value 0x10820 "stat_rx_total_good_bytes_soft_lsb"]
set stat_rx_total_good_bytes_soft_msb [show_stat_value 0x10824 "stat_rx_total_good_bytes_soft_msb"]
set stat_rx_packet_64_bytes_soft_lsb [show_stat_value 0x10828 "stat_rx_packet_64_bytes_soft_lsb"]
set stat_rx_packet_64_bytes_soft_msb [show_stat_value 0x1082C "stat_rx_packet_64_bytes_soft_msb"]
set stat_rx_packet_65_127_bytes_soft_lsb [show_stat_value 0x10830 "stat_rx_packet_65_127_bytes_soft_lsb"]
set stat_rx_packet_65_127_bytes_soft_msb [show_stat_value 0x10834 "stat_rx_packet_65_127_bytes_soft_msb"]
set stat_rx_packet_128_255_bytes_soft_lsb [show_stat_value 0x10838 "stat_rx_packet_128_255_bytes_soft_lsb"]
set stat_rx_packet_128_255_bytes_soft_msb [show_stat_value 0x1083C "stat_rx_packet_128_255_bytes_soft_msb"]
set stat_rx_packet_256_511_bytes_soft_lsb [show_stat_value 0x10840 "stat_rx_packet_256_511_bytes_soft_lsb"]
set stat_rx_packet_256_511_bytes_soft_msb [show_stat_value 0x10844 "stat_rx_packet_256_511_bytes_soft_msb"]
set stat_rx_packet_512_1023_bytes_soft_lsb [show_stat_value 0x10848 "stat_rx_packet_512_1023_bytes_soft_lsb"]
set stat_rx_packet_512_1023_bytes_soft_msb [show_stat_value 0x1084C "stat_rx_packet_512_1023_bytes_soft_msb"]
set stat_rx_packet_1024_1518_bytes_soft_lsb [show_stat_value 0x10850 "stat_rx_packet_1024_1518_bytes_soft_lsb"]
set stat_rx_packet_1024_1518_bytes_soft_msb [show_stat_value 0x10854 "stat_rx_packet_1024_1518_bytes_soft_msb"]
set stat_rx_packet_1519_1522_bytes_soft_lsb [show_stat_value 0x10858 "stat_rx_packet_1519_1522_bytes_soft_lsb"]
set stat_rx_packet_1519_1522_bytes_soft_msb [show_stat_value 0x1085C "stat_rx_packet_1519_1522_bytes_soft_msb"]
set stat_rx_packet_1523_1548_bytes_soft_lsb [show_stat_value 0x10860 "stat_rx_packet_1523_1548_bytes_soft_lsb"]
set stat_rx_packet_1523_1548_bytes_soft_msb [show_stat_value 0x10864 "stat_rx_packet_1523_1548_bytes_soft_msb"]
set stat_rx_packet_1549_2047_bytes_soft_lsb [show_stat_value 0x10868 "stat_rx_packet_1549_2047_bytes_soft_lsb"]
set stat_rx_packet_1549_2047_bytes_soft_msb [show_stat_value 0x1086C "stat_rx_packet_1549_2047_bytes_soft_msb"]
set stat_rx_packet_2048_4095_bytes_soft_lsb [show_stat_value 0x10870 "stat_rx_packet_2048_4095_bytes_soft_lsb"]
set stat_rx_packet_2048_4095_bytes_soft_msb [show_stat_value 0x10874 "stat_rx_packet_2048_4095_bytes_soft_msb"]
set stat_rx_packet_4096_8191_bytes_soft_lsb [show_stat_value 0x10878 "stat_rx_packet_4096_8191_bytes_soft_lsb"]
set stat_rx_packet_4096_8191_bytes_soft_msb [show_stat_value 0x1087C "stat_rx_packet_4096_8191_bytes_soft_msb"]
set stat_rx_packet_8192_9215_bytes_soft_lsb [show_stat_value 0x10880 "stat_rx_packet_8192_9215_bytes_soft_lsb"]
set stat_rx_packet_8192_9215_bytes_soft_msb [show_stat_value 0x10884 "stat_rx_packet_8192_9215_bytes_soft_msb"]
set stat_rx_packet_large_soft_lsb [show_stat_value 0x10888 "stat_rx_packet_large_soft_lsb"]
set stat_rx_packet_large_soft_msb [show_stat_value 0x1088C "stat_rx_packet_large_soft_msb"]
set stat_rx_packet_small_soft_lsb [show_stat_value 0x10890 "stat_rx_packet_small_soft_lsb"]
set stat_rx_packet_small_soft_msb [show_stat_value 0x10894 "stat_rx_packet_small_soft_msb"]
set stat_rx_undersize_soft_lsb [show_stat_value 0x10898 "stat_rx_undersize_soft_lsb"]
set stat_rx_undersize_soft_msb [show_stat_value 0x1089C "stat_rx_undersize_soft_msb"]
set stat_rx_fragment_soft_lsb [show_stat_value 0x108A0 "stat_rx_fragment_soft_lsb"]
set stat_rx_fragment_soft_msb [show_stat_value 0x108A4 "stat_rx_fragment_soft_msb"]
set stat_rx_oversize_soft_lsb [show_stat_value 0x108A8 "stat_rx_oversize_soft_lsb"]
set stat_rx_oversize_soft_msb [show_stat_value 0x108AC "stat_rx_oversize_soft_msb"]
set stat_rx_toolong_soft_lsb [show_stat_value 0x108B0 "stat_rx_toolong_soft_lsb"]
set stat_rx_toolong_soft_msb [show_stat_value 0x108B4 "stat_rx_toolong_soft_msb"]
set stat_rx_jabber_soft_lsb [show_stat_value 0x108B8 "stat_rx_jabber_soft_lsb"]
set stat_rx_jabber_soft_msb [show_stat_value 0x108BC "stat_rx_jabber_soft_msb"]
set stat_rx_bad_fcs_soft_lsb [show_stat_value 0x108C0 "stat_rx_bad_fcs_soft_lsb"]
set stat_rx_bad_fcs_soft_msb [show_stat_value 0x108C4 "stat_rx_bad_fcs_soft_msb"]
set stat_rx_packet_bad_fcs_soft_lsb [show_stat_value 0x108C8 "stat_rx_packet_bad_fcs_soft_lsb"]
set stat_rx_packet_bad_fcs_soft_msb [show_stat_value 0x108CC "stat_rx_packet_bad_fcs_soft_msb"]
set stat_rx_stomped_fcs_soft_lsb [show_stat_value 0x108D0 "stat_rx_stomped_fcs_soft_lsb"]
set stat_rx_stomped_fcs_soft_msb [show_stat_value 0x108D4 "stat_rx_stomped_fcs_soft_msb"]

set stat_rx_unicast_soft_lsb [show_stat_value 0x108D8 "stat_rx_unicast_soft_lsb"]
set stat_rx_unicast_soft_msb [show_stat_value 0x108DC "stat_rx_unicast_soft_msb"]
set stat_rx_multicast_soft_lsb [show_stat_value 0x108E0 "stat_rx_multicast_soft_lsb"]
set stat_rx_multicast_soft_msb [show_stat_value 0x108E4 "stat_rx_multicast_soft_msb"]
set stat_rx_broadcast_soft_lsb [show_stat_value 0x108E8 "stat_rx_broadcast_soft_lsb"]
set stat_rx_broadcast_soft_msb [show_stat_value 0x108EC "stat_rx_broadcast_soft_msb"]
set stat_rx_vlan_soft_lsb [show_stat_value 0x108F0 "stat_rx_vlan_soft_lsb"]
set stat_rx_vlan_soft_msb [show_stat_value 0x108F4 "stat_rx_vlan_soft_msb"]

set stat_rx_pause_soft_lsb [show_stat_value 0x108F8 "stat_rx_pause_soft_lsb"]
set stat_rx_pause_soft_msb [show_stat_value 0x108FC "stat_rx_pause_soft_msb"]
set stat_rx_user_pause_soft_lsb [show_stat_value 0x10900 "stat_rx_user_pause_soft_lsb"]
set stat_rx_user_pause_soft_msb [show_stat_value 0x10904 "stat_rx_user_pause_soft_msb"]
set stat_rx_inrangeerr_soft_lsb [show_stat_value 0x10908 "stat_rx_inrangeerr_soft_lsb"]
set stat_rx_inrangeerr_soft_msb [show_stat_value 0x1090C "stat_rx_inrangeerr_soft_msb"]
set stat_rx_truncated_soft_lsb [show_stat_value 0x10910 "stat_rx_truncated_soft_lsb"]
set stat_rx_truncated_soft_msb [show_stat_value 0x10914 "stat_rx_truncated_soft_msb"]
set stat_rx_test_pattern_mismatch_soft_lsb [show_stat_value 0x10918 "stat_rx_test_pattern_mismatch_soft_lsb"]
set stat_rx_test_pattern_mismatch_soft_msb [show_stat_value 0x1091C "stat_rx_test_pattern_mismatch_soft_msb"]
set stat_rx_total_err_bytes_soft_lsb [show_stat_value 0x10958 "stat_rx_total_err_bytes_soft_lsb"]
set stat_rx_total_err_bytes_soft_msb [show_stat_value 0x1095C "stat_rx_total_err_bytes_soft_msb"]
set stat_rx_bad_std_preamble_count_soft_lsb [show_stat_value 0x10960 "stat_rx_bad_std_preamble_count_soft_lsb"]
set stat_rx_bad_std_preamble_count_soft_msb [show_stat_value 0x10964 "stat_rx_bad_std_preamble_count_soft_msb"]

#msb lsb appended stats ###############################################-EG
# #######################VNC#############################
set stat_vnc_tx_unicast  [lsb_msb_append $stat_vnc_tx_unicast_lsb $stat_vnc_tx_unicast_msb]
set stat_vnc_tx_multicast [lsb_msb_append $stat_vnc_tx_multicast_lsb $stat_vnc_tx_multicast_msb]
set stat_vnc_tx_broadcast [lsb_msb_append $stat_vnc_tx_broadcast_lsb $stat_vnc_tx_broadcast_msb]
set stat_vnc_tx_vlan [lsb_msb_append $stat_vnc_tx_vlan_lsb $stat_vnc_tx_vlan_msb]

set stat_vnc_tx_total_packets [lsb_msb_append $stat_vnc_tx_total_packets_lsb $stat_vnc_tx_total_packets_msb]
set stat_vnc_tx_total_bytes [lsb_msb_append $stat_vnc_tx_total_bytes_lsb $stat_vnc_tx_total_bytes_msb]
set stat_vnc_tx_total_good_packets [lsb_msb_append $stat_vnc_tx_total_good_packets_lsb $stat_vnc_tx_total_good_packets_msb]
set stat_vnc_tx_total_good_bytes [lsb_msb_append $stat_vnc_tx_total_good_bytes_lsb $stat_vnc_tx_total_good_bytes_msb]
set stat_vnc_tx_packet_64_bytes [lsb_msb_append $stat_vnc_tx_packet_64_bytes_lsb $stat_vnc_tx_packet_64_bytes_msb]
set stat_vnc_tx_packet_65_127_bytes [lsb_msb_append $stat_vnc_tx_packet_65_127_bytes_lsb $stat_vnc_tx_packet_65_127_bytes_msb]
set stat_vnc_tx_packet_128_255_bytes [lsb_msb_append $stat_vnc_tx_packet_128_255_bytes_lsb $stat_vnc_tx_packet_128_255_bytes_msb]
set stat_vnc_tx_packet_256_511_bytes [lsb_msb_append $stat_vnc_tx_packet_256_511_bytes_lsb $stat_vnc_tx_packet_256_511_bytes_msb]
set stat_vnc_tx_packet_512_1023_bytes [lsb_msb_append $stat_vnc_tx_packet_512_1023_bytes_lsb $stat_vnc_tx_packet_512_1023_bytes_msb]
set stat_vnc_tx_packet_1024_1518_bytes [lsb_msb_append $stat_vnc_tx_packet_1024_1518_bytes_lsb $stat_vnc_tx_packet_1024_1518_bytes_msb]
set stat_vnc_tx_packet_1519_1522_bytes [lsb_msb_append $stat_vnc_tx_packet_1519_1522_bytes_lsb $stat_vnc_tx_packet_1519_1522_bytes_msb]
set stat_vnc_tx_packet_1523_1548_bytes [lsb_msb_append $stat_vnc_tx_packet_1523_1548_bytes_lsb $stat_vnc_tx_packet_1523_1548_bytes_msb]
set stat_vnc_tx_packet_1549_2047_bytes [lsb_msb_append $stat_vnc_tx_packet_1549_2047_bytes_lsb $stat_vnc_tx_packet_1549_2047_bytes_msb]
set stat_vnc_tx_packet_2048_4095_bytes [lsb_msb_append $stat_vnc_tx_packet_2048_4095_bytes_lsb $stat_vnc_tx_packet_2048_4095_bytes_msb]
set stat_vnc_tx_packet_4096_8191_bytes [lsb_msb_append $stat_vnc_tx_packet_4096_8191_bytes_lsb $stat_vnc_tx_packet_4096_8191_bytes_msb]
set stat_vnc_tx_packet_8192_9215_bytes [lsb_msb_append $stat_vnc_tx_packet_8192_9215_bytes_lsb $stat_vnc_tx_packet_8192_9215_bytes_msb]
set stat_vnc_tx_packet_small [lsb_msb_append $stat_vnc_tx_packet_small_lsb $stat_vnc_tx_packet_small_msb]
set stat_vnc_tx_packet_large [lsb_msb_append $stat_vnc_tx_packet_large_lsb $stat_vnc_tx_packet_large_msb]
set ctl_vnc_tx_custom_preamble [lsb_msb_append $ctl_vnc_tx_custom_preamble_lsb $ctl_vnc_tx_custom_preamble_msb]

#tx only
set stat_vnc_tx_frame_error [lsb_msb_append $stat_vnc_tx_frame_error_lsb $stat_vnc_tx_frame_error_msb]
set stat_vnc_tx_error_unfout [format 0x%x [expr $stat_tx_unfout & 0x0000FFFF]] 
set stat_vnc_tx_error_overflow [format 0x%x [expr ($stat_tx_unfout & 0xFFFF0000) >> 16]]

set stat_vnc_rx_unicast  [lsb_msb_append $stat_vnc_rx_unicast_lsb $stat_vnc_rx_unicast_msb]
set stat_vnc_rx_multicast [lsb_msb_append $stat_vnc_rx_multicast_lsb $stat_vnc_rx_multicast_msb]
set stat_vnc_rx_broadcast [lsb_msb_append $stat_vnc_rx_broadcast_lsb $stat_vnc_rx_broadcast_msb]
set stat_vnc_rx_vlan [lsb_msb_append $stat_vnc_rx_vlan_lsb $stat_vnc_rx_vlan_msb]
set stat_vnc_rx_total_packets [lsb_msb_append $stat_vnc_rx_total_packets_lsb $stat_vnc_rx_total_packets_msb]
set stat_vnc_rx_total_bytes [lsb_msb_append $stat_vnc_rx_total_bytes_lsb $stat_vnc_rx_total_bytes_msb]
set stat_vnc_rx_total_good_packets [lsb_msb_append $stat_vnc_rx_total_good_packets_lsb $stat_vnc_rx_total_good_packets_msb]
set stat_vnc_rx_total_good_bytes [lsb_msb_append $stat_vnc_rx_total_good_bytes_lsb $stat_vnc_rx_total_good_bytes_msb]
set stat_vnc_rx_packet_64_bytes [lsb_msb_append $stat_vnc_rx_packet_64_bytes_lsb $stat_vnc_rx_packet_64_bytes_msb]
set stat_vnc_rx_packet_65_127_bytes [lsb_msb_append $stat_vnc_rx_packet_65_127_bytes_lsb $stat_vnc_rx_packet_65_127_bytes_msb]
set stat_vnc_rx_packet_128_255_bytes [lsb_msb_append $stat_vnc_rx_packet_128_255_bytes_lsb $stat_vnc_rx_packet_128_255_bytes_msb]
set stat_vnc_rx_packet_256_511_bytes [lsb_msb_append $stat_vnc_rx_packet_256_511_bytes_lsb $stat_vnc_rx_packet_256_511_bytes_msb]
set stat_vnc_rx_packet_512_1023_bytes [lsb_msb_append $stat_vnc_rx_packet_512_1023_bytes_lsb $stat_vnc_rx_packet_512_1023_bytes_msb]
set stat_vnc_rx_packet_1024_1518_bytes [lsb_msb_append $stat_vnc_rx_packet_1024_1518_bytes_lsb $stat_vnc_rx_packet_1024_1518_bytes_msb]
set stat_vnc_rx_packet_1519_1522_bytes [lsb_msb_append $stat_vnc_rx_packet_1519_1522_bytes_lsb $stat_vnc_rx_packet_1519_1522_bytes_msb]
set stat_vnc_rx_packet_1523_1548_bytes [lsb_msb_append $stat_vnc_rx_packet_1523_1548_bytes_lsb $stat_vnc_rx_packet_1523_1548_bytes_msb]
set stat_vnc_rx_packet_1549_2047_bytes [lsb_msb_append $stat_vnc_rx_packet_1549_2047_bytes_lsb $stat_vnc_rx_packet_1549_2047_bytes_msb]
set stat_vnc_rx_packet_2048_4095_bytes [lsb_msb_append $stat_vnc_rx_packet_2048_4095_bytes_lsb $stat_vnc_rx_packet_2048_4095_bytes_msb]
set stat_vnc_rx_packet_4096_8191_bytes [lsb_msb_append $stat_vnc_rx_packet_4096_8191_bytes_lsb $stat_vnc_rx_packet_4096_8191_bytes_msb]
set stat_vnc_rx_packet_8192_9215_bytes [lsb_msb_append $stat_vnc_rx_packet_8192_9215_bytes_lsb $stat_vnc_rx_packet_8192_9215_bytes_msb]
set stat_vnc_rx_packet_small [lsb_msb_append $stat_vnc_rx_packet_small_lsb $stat_vnc_rx_packet_small_msb]
set stat_vnc_rx_packet_large [lsb_msb_append $stat_vnc_rx_packet_large_lsb $stat_vnc_rx_packet_large_msb]
set stat_vnc_rx_inrangeerr [lsb_msb_append $stat_vnc_rx_inrangeerr_lsb $stat_vnc_rx_inrangeerr_msb]
set stat_vnc_rx_bad_fcs [lsb_msb_append $stat_vnc_rx_bad_fcs_lsb $stat_vnc_rx_bad_fcs_msb]
set stat_vnc_rx_oversize [lsb_msb_append $stat_vnc_rx_oversize_lsb $stat_vnc_rx_oversize_msb]
set stat_vnc_rx_undersize [lsb_msb_append $stat_vnc_rx_undersize_lsb $stat_vnc_rx_undersize_msb]
set stat_vnc_rx_toolong [lsb_msb_append $stat_vnc_rx_toolong_lsb $stat_vnc_rx_toolong_msb]
set stat_vnc_rx_jabber [lsb_msb_append $stat_vnc_rx_jabber_lsb $stat_vnc_rx_jabber_msb]
set stat_vnc_rx_fragment [lsb_msb_append $stat_vnc_rx_fragment_lsb $stat_vnc_rx_fragment_msb]
set stat_vnc_rx_packet_bad_fcs [lsb_msb_append $stat_vnc_rx_packet_bad_fcs_lsb $stat_vnc_rx_packet_bad_fcs_msb]
set stat_vnc_rx_user_pause [lsb_msb_append $stat_vnc_rx_user_pause_lsb $stat_vnc_rx_user_pause_msb]
set stat_vnc_rx_pause [lsb_msb_append $stat_vnc_rx_pause_lsb $stat_vnc_rx_pause_msb]
set stat_vnc_rx_bad_preamble [lsb_msb_append $stat_vnc_rx_bad_preamble_lsb $stat_vnc_rx_bad_preamble_msb]
set ctl_vnc_rx_custom_preamble [lsb_msb_append $ctl_vnc_rx_custom_preamble_lsb $ctl_vnc_rx_custom_preamble_msb]

# ###################GTFMAC#################
set status_tx_cycle_soft_count [lsb_msb_append $status_tx_cycle_soft_count_lsb $status_tx_cycle_soft_count_msb]
set stat_tx_unicast_soft  [lsb_msb_append $stat_tx_unicast_soft_lsb $stat_tx_unicast_soft_msb]
set stat_tx_multicast_soft [lsb_msb_append $stat_tx_multicast_soft_lsb $stat_tx_multicast_soft_msb]
set stat_tx_broadcast_soft [lsb_msb_append $stat_tx_broadcast_soft_lsb $stat_tx_broadcast_soft_msb]
set stat_tx_vlan_soft [lsb_msb_append $stat_tx_vlan_soft_lsb $stat_tx_vlan_soft_msb]

set stat_tx_total_packets_soft [lsb_msb_append $stat_tx_total_packets_soft_lsb $stat_tx_total_packets_soft_msb]
set stat_tx_total_bytes_soft [lsb_msb_append $stat_tx_total_bytes_soft_lsb $stat_tx_total_bytes_soft_msb]
set stat_tx_total_good_packets_soft [lsb_msb_append $stat_tx_total_good_packets_soft_lsb $stat_tx_total_good_packets_soft_msb]
set stat_tx_total_good_bytes_soft [lsb_msb_append $stat_tx_total_good_bytes_soft_lsb $stat_tx_total_good_bytes_soft_msb]
set stat_tx_packet_64_bytes_soft [lsb_msb_append $stat_tx_packet_64_bytes_soft_lsb $stat_tx_packet_64_bytes_soft_msb]
set stat_tx_packet_65_127_bytes_soft [lsb_msb_append $stat_tx_packet_65_127_bytes_soft_lsb $stat_tx_packet_65_127_bytes_soft_msb]
set stat_tx_packet_128_255_bytes_soft [lsb_msb_append $stat_tx_packet_128_255_bytes_soft_lsb $stat_tx_packet_128_255_bytes_soft_msb]
set stat_tx_packet_256_511_bytes_soft [lsb_msb_append $stat_tx_packet_256_511_bytes_soft_lsb $stat_tx_packet_256_511_bytes_soft_msb]
set stat_tx_packet_512_1023_bytes_soft [lsb_msb_append $stat_tx_packet_512_1023_bytes_soft_lsb $stat_tx_packet_512_1023_bytes_soft_msb]
set stat_tx_packet_1024_1518_bytes_soft [lsb_msb_append $stat_tx_packet_1024_1518_bytes_soft_lsb $stat_tx_packet_1024_1518_bytes_soft_msb]
set stat_tx_packet_1519_1522_bytes_soft [lsb_msb_append $stat_tx_packet_1519_1522_bytes_soft_lsb $stat_tx_packet_1519_1522_bytes_soft_msb]
set stat_tx_packet_1523_1548_bytes_soft [lsb_msb_append $stat_tx_packet_1523_1548_bytes_soft_lsb $stat_tx_packet_1523_1548_bytes_soft_msb]
set stat_tx_packet_1549_2047_bytes_soft [lsb_msb_append $stat_tx_packet_1549_2047_bytes_soft_lsb $stat_tx_packet_1549_2047_bytes_soft_msb]
set stat_tx_packet_2048_4095_bytes_soft [lsb_msb_append $stat_tx_packet_2048_4095_bytes_soft_lsb $stat_tx_packet_2048_4095_bytes_soft_msb]
set stat_tx_packet_4096_8191_bytes_soft [lsb_msb_append $stat_tx_packet_4096_8191_bytes_soft_lsb $stat_tx_packet_4096_8191_bytes_soft_msb]
set stat_tx_packet_8192_9215_bytes_soft [lsb_msb_append $stat_tx_packet_8192_9215_bytes_soft_lsb $stat_tx_packet_8192_9215_bytes_soft_msb]
set stat_tx_packet_small_soft [lsb_msb_append $stat_tx_packet_small_soft_lsb $stat_tx_packet_small_soft_msb]
set stat_tx_packet_large_soft [lsb_msb_append $stat_tx_packet_large_soft_lsb $stat_tx_packet_large_soft_msb]
set stat_tx_frame_error_soft [lsb_msb_append $stat_tx_frame_error_soft_lsb $stat_tx_frame_error_soft_msb]
set stat_tx_total_err_bytes_soft [lsb_msb_append $stat_tx_total_err_bytes_soft_lsb $stat_tx_total_err_bytes_soft_msb]

#gtfmac tx only
set stat_tx_bad_fcs_soft [lsb_msb_append $stat_tx_bad_fcs_soft_lsb $stat_tx_bad_fcs_soft_msb]

set status_rx_cycle_soft_count [lsb_msb_append $status_rx_cycle_soft_count_lsb $status_rx_cycle_soft_count_msb]
set stat_rx_unicast_soft  [lsb_msb_append $stat_rx_unicast_soft_lsb $stat_rx_unicast_soft_msb]
set stat_rx_multicast_soft [lsb_msb_append $stat_rx_multicast_soft_lsb $stat_rx_multicast_soft_msb]
set stat_rx_broadcast_soft [lsb_msb_append $stat_rx_broadcast_soft_lsb $stat_rx_broadcast_soft_msb]
set stat_rx_vlan_soft [lsb_msb_append $stat_rx_vlan_soft_lsb $stat_rx_vlan_soft_msb]
set stat_rx_total_packets_soft [lsb_msb_append $stat_rx_total_packets_soft_lsb $stat_rx_total_packets_soft_msb]
set stat_rx_total_bytes_soft [lsb_msb_append $stat_rx_total_bytes_soft_lsb $stat_rx_total_bytes_soft_msb]
set stat_rx_total_good_packets_soft [lsb_msb_append $stat_rx_total_good_packets_soft_lsb $stat_rx_total_good_packets_soft_msb]
set stat_rx_total_good_bytes_soft [lsb_msb_append $stat_rx_total_good_bytes_soft_lsb $stat_rx_total_good_bytes_soft_msb]
set stat_rx_packet_64_bytes_soft [lsb_msb_append $stat_rx_packet_64_bytes_soft_lsb $stat_rx_packet_64_bytes_soft_msb]
set stat_rx_packet_65_127_bytes_soft [lsb_msb_append $stat_rx_packet_65_127_bytes_soft_lsb $stat_rx_packet_65_127_bytes_soft_msb]
set stat_rx_packet_128_255_bytes_soft [lsb_msb_append $stat_rx_packet_128_255_bytes_soft_lsb $stat_rx_packet_128_255_bytes_soft_msb]
set stat_rx_packet_256_511_bytes_soft [lsb_msb_append $stat_rx_packet_256_511_bytes_soft_lsb $stat_rx_packet_256_511_bytes_soft_msb]
set stat_rx_packet_512_1023_bytes_soft [lsb_msb_append $stat_rx_packet_512_1023_bytes_soft_lsb $stat_rx_packet_512_1023_bytes_soft_msb]
set stat_rx_packet_1024_1518_bytes_soft [lsb_msb_append $stat_rx_packet_1024_1518_bytes_soft_lsb $stat_rx_packet_1024_1518_bytes_soft_msb]
set stat_rx_packet_1519_1522_bytes_soft [lsb_msb_append $stat_rx_packet_1519_1522_bytes_soft_lsb $stat_rx_packet_1519_1522_bytes_soft_msb]
set stat_rx_packet_1523_1548_bytes_soft [lsb_msb_append $stat_rx_packet_1523_1548_bytes_soft_lsb $stat_rx_packet_1523_1548_bytes_soft_msb]
set stat_rx_packet_1549_2047_bytes_soft [lsb_msb_append $stat_rx_packet_1549_2047_bytes_soft_lsb $stat_rx_packet_1549_2047_bytes_soft_msb]
set stat_rx_packet_2048_4095_bytes_soft [lsb_msb_append $stat_rx_packet_2048_4095_bytes_soft_lsb $stat_rx_packet_2048_4095_bytes_soft_msb]
set stat_rx_packet_4096_8191_bytes_soft [lsb_msb_append $stat_rx_packet_4096_8191_bytes_soft_lsb $stat_rx_packet_4096_8191_bytes_soft_msb]
set stat_rx_packet_8192_9215_bytes_soft [lsb_msb_append $stat_rx_packet_8192_9215_bytes_soft_lsb $stat_rx_packet_8192_9215_bytes_soft_msb]
set stat_rx_packet_small_soft [lsb_msb_append $stat_rx_packet_small_soft_lsb $stat_rx_packet_small_soft_msb]
set stat_rx_packet_large_soft [lsb_msb_append $stat_rx_packet_large_soft_lsb $stat_rx_packet_large_soft_msb]
set stat_rx_inrangeerr_soft [lsb_msb_append $stat_rx_inrangeerr_soft_lsb $stat_rx_inrangeerr_soft_msb]
set stat_rx_bad_fcs_soft [lsb_msb_append $stat_rx_bad_fcs_soft_lsb $stat_rx_bad_fcs_soft_msb]
set stat_rx_oversize_soft [lsb_msb_append $stat_rx_oversize_soft_lsb $stat_rx_oversize_soft_msb]
set stat_rx_undersize_soft [lsb_msb_append $stat_rx_undersize_soft_lsb $stat_rx_undersize_soft_msb]
set stat_rx_toolong_soft [lsb_msb_append $stat_rx_toolong_soft_lsb $stat_rx_toolong_soft_msb]
set stat_rx_jabber_soft [lsb_msb_append $stat_rx_jabber_soft_lsb $stat_rx_jabber_soft_msb]
set stat_rx_fragment_soft [lsb_msb_append $stat_rx_fragment_soft_lsb $stat_rx_fragment_soft_msb]
set stat_rx_packet_bad_fcs_soft [lsb_msb_append $stat_rx_packet_bad_fcs_soft_lsb $stat_rx_packet_bad_fcs_soft_msb]
set stat_rx_user_pause_soft [lsb_msb_append $stat_rx_user_pause_soft_lsb $stat_rx_user_pause_soft_msb]
set stat_rx_pause_soft [lsb_msb_append $stat_rx_pause_soft_lsb $stat_rx_pause_soft_msb]
set stat_rx_total_err_bytes_soft [lsb_msb_append $stat_rx_total_err_bytes_soft_lsb $stat_rx_total_err_bytes_soft_msb]


#gtfmac rx only
set stat_rx_bad_code_soft [lsb_msb_append $stat_rx_bad_code_soft_lsb $stat_rx_bad_code_soft_msb]
set stat_rx_stomped_fcs_soft [lsb_msb_append $stat_rx_stomped_fcs_soft_lsb $stat_rx_stomped_fcs_soft_msb]
set stat_rx_truncated_soft [lsb_msb_append $stat_rx_truncated_soft_lsb $stat_rx_truncated_soft_msb]
set stat_rx_test_pattern_mismatch_soft [lsb_msb_append $stat_rx_test_pattern_mismatch_soft_lsb $stat_rx_test_pattern_mismatch_soft_msb]
set stat_rx_stomped_fcs_soft [lsb_msb_append $stat_rx_stomped_fcs_soft_lsb $stat_rx_stomped_fcs_soft_msb]
set stat_rx_bad_std_preamble_count_soft [lsb_msb_append $stat_rx_bad_std_preamble_count_soft_lsb $stat_rx_bad_std_preamble_count_soft_msb]

puts $::fp_stats "************Config dump************"
set vnc_config_reg							        [	show_stat_value   0x00010		 "vnc_config_reg"										 			]
set ctl_num_frames							        [	show_stat_value   0x0002c		 "ctl_num_frames"	                                                ]
set traffic_duration							    [	show_var_value	[format 0x%08x $::test_duration] "traffic_duration"	 				                ]
set tx_custom_preamble  							[	show_var_value	$ctl_vnc_tx_custom_preamble    "tx_custom_preamble"	 				            ]
set rx_custom_preamble  							[	show_var_value	$ctl_vnc_rx_custom_preamble    "rx_custom_preamble"	 				            ]
  
set mode_reg										[	show_stat_value   0x10000		 "mode_reg"										 					]
set configuration_tx_reg1						    [	show_stat_value   0x10004		 "configuration_tx_reg1"											]
set configuration_rx_reg1	                        [	show_stat_value   0x10008		 "configuration_rx_reg1"	                    					]
set configuration_rx_mtu1	                        [	show_stat_value   0x1000C		 "configuration_rx_mtu1"	                    					]
set configuration_rx_mtu2	                        [	show_stat_value   0x10010		 "configuration_rx_mtu2"	                    					]
set configuration_revision_reg	                    [	show_stat_value   0x10014		 "configuration_revision_reg"	                					]
set debug_reg	                                    [	show_stat_value   0x10018		 "debug_reg"	                                					]
set tick_reg	                                    [	show_stat_value   0x10028		 "tick_reg"	                                						]
set reset_reg	                                    [	show_stat_value   0x1002C		 "reset_reg"	                                					]
set configuration_tx_flow_control_reg1	            [	show_stat_value   0x10030		 "configuration_tx_flow_control_reg1"        						]
set configuration_tx_flow_control_refresh_reg1	    [	show_stat_value   0x10034		 "configuration_tx_flow_control_refresh_reg1"						]
set configuration_tx_flow_control_refresh_reg2	    [	show_stat_value   0x10038		 "configuration_tx_flow_control_refresh_reg2"						]
set configuration_tx_flow_control_refresh_reg3	    [	show_stat_value   0x1003C		 "configuration_tx_flow_control_refresh_reg3"						]
set configuration_tx_flow_control_refresh_reg4	    [	show_stat_value   0x10040		 "configuration_tx_flow_control_refresh_reg4"						]
set configuration_tx_flow_control_refresh_reg5	    [	show_stat_value   0x10044		 "configuration_tx_flow_control_refresh_reg5"						]
set configuration_tx_flow_control_refresh_reg6	    [	show_stat_value   0x10048		 "configuration_tx_flow_control_refresh_reg6"						]
set configuration_tx_flow_control_refresh_reg7	    [	show_stat_value   0x1004C		 "configuration_tx_flow_control_refresh_reg7"						]
set configuration_tx_flow_control_refresh_reg8	    [	show_stat_value   0x10050		 "configuration_tx_flow_control_refresh_reg8"						]
set configuration_tx_flow_control_refresh_reg9	    [	show_stat_value   0x10054		 "configuration_tx_flow_control_refresh_reg9"						]
set configuration_tx_flow_control_quanta_reg1	    [	show_stat_value   0x10058		 "configuration_tx_flow_control_quanta_reg1"						]
set configuration_tx_flow_control_quanta_reg2	    [	show_stat_value   0x1005C		 "configuration_tx_flow_control_quanta_reg2"						]
set configuration_tx_flow_control_quanta_reg3	    [	show_stat_value   0x10060		 "configuration_tx_flow_control_quanta_reg3"						]
set configuration_tx_flow_control_quanta_reg4	    [	show_stat_value   0x10064		 "configuration_tx_flow_control_quanta_reg4"						]
set configuration_tx_flow_control_quanta_reg5	    [	show_stat_value   0x10068		 "configuration_tx_flow_control_quanta_reg5"						]
set configuration_tx_flow_control_quanta_reg6	    [	show_stat_value   0x1006C		 "configuration_tx_flow_control_quanta_reg6"						]
set configuration_tx_flow_control_quanta_reg7	    [	show_stat_value   0x10070		 "configuration_tx_flow_control_quanta_reg7"						]
set configuration_tx_flow_control_quanta_reg8	    [	show_stat_value   0x10074		 "configuration_tx_flow_control_quanta_reg8"						]
set configuration_tx_flow_control_quanta_reg9	    [	show_stat_value   0x10078		 "configuration_tx_flow_control_quanta_reg9"						]
set configuration_tx_flow_control_ppp_etype_reg	    [	show_stat_value   0x1007C		 "configuration_tx_flow_control_ppp_etype_reg"						]
set configuration_tx_flow_control_ppp_op_reg	    [	show_stat_value   0x10080		 "configuration_tx_flow_control_ppp_op_reg"							]
set configuration_tx_flow_control_gpp_etype_reg	    [	show_stat_value   0x10084		 "configuration_tx_flow_control_gpp_etype_reg"						]
set configuration_tx_flow_control_gpp_op_reg	    [	show_stat_value   0x10088		 "configuration_tx_flow_control_gpp_op_reg"							]
												
puts $::fp_stats "************stat dump************"
set ctrl_code [reg_rd 0x10140]
set stat_tx_status_reg1				[ 	non_sticky_read		 	0x1011C			 "stat_tx_status_reg1"											    ]
set stat_rx_status_reg1             [	non_sticky_read		 	0x10120			 "stat_rx_status_reg1"      										]
set stat_tx_rt_status_reg1          [	non_sticky_read		 	0x10124			 "stat_tx_rt_status_reg1"   										]
set stat_rx_rt_status_reg1          [	non_sticky_read		 	0x10128			 "stat_rx_rt_status_reg1"   										]
set stat_rx_block_lock_reg          [	non_sticky_read		 	0x10130			 "stat_rx_block_lock_reg"   										]
set stat_tx_flow_control_reg1       [	non_sticky_read		 	0x10134			 "stat_tx_flow_control_reg1"										]
set stat_rx_flow_control_reg1       [	non_sticky_read		 	0x10138			 "stat_rx_flow_control_reg1"										]
set stat_rx_flow_control_reg2       [	non_sticky_read		 	0x1013C			 "stat_rx_flow_control_reg2"										]
set stat_rx_valid_ctrl_code         [	show_stat_value		 	0x10140          "stat_rx_valid_ctrl_code"  										]
set stat_rx_bit_slip                [	non_sticky_read		 	0x10144			 "stat_rx_bit_slip"         										]
set stat_rx_cycle_count_lsb         [	non_sticky_read		 	0x10148			 "stat_rx_cycle_count_lsb" 										    ]
set stat_rx_cycle_count_msb         [	non_sticky_read		 	0x1014C			 "stat_rx_cycle_count_msb" 										    ]
set stat_rx_cycle_count             [   lsb_msb_append_4h $stat_rx_cycle_count_lsb $stat_rx_cycle_count_msb]
set stat_tx_cycle_count_lsb         [	non_sticky_read		 	0x10150			 "stat_tx_cycle_count_lsb" 										    ]
set stat_tx_cycle_count_msb         [	non_sticky_read		 	0x10154			 "stat_tx_cycle_count_msb" 										    ]
set stat_tx_cycle_count             [   lsb_msb_append_4h $stat_tx_cycle_count_lsb $stat_tx_cycle_count_msb]


puts $::fp_stats "************************Various stats comparison************************"
puts $::fp_stats "************tx/rx comparison************"
puts $::fp_stats "~~VNC~~"

set result [test_check $result [stats_comparison $stat_vnc_tx_unicast "stat_vnc_tx_unicast" $stat_vnc_rx_unicast "stat_vnc_rx_unicast"                                                         ]]
set result [test_check $result [stats_comparison $stat_vnc_tx_multicast "stat_vnc_tx_multicast" $stat_vnc_rx_multicast "stat_vnc_rx_multicast"                                                 ]]
set result [test_check $result [stats_comparison $stat_vnc_tx_broadcast "stat_vnc_tx_broadcast" $stat_vnc_rx_broadcast "stat_vnc_rx_broadcast"                                                 ]]
set result [test_check $result [stats_comparison $stat_vnc_tx_vlan "stat_vnc_tx_vlan" $stat_vnc_rx_vlan "stat_vnc_rx_vlan"																		]]

set result [test_check $result [stats_comparison $stat_vnc_tx_total_packets "stat_vnc_tx_total_packets" $stat_vnc_rx_total_packets "stat_vnc_rx_total_packets"                                     ]]
set result [test_check $result [stats_comparison $stat_vnc_tx_total_good_packets "stat_vnc_tx_total_good_packets" $stat_vnc_rx_total_good_packets "stat_vnc_rx_total_good_packets"                 ]]
set result [test_check $result [stats_comparison $stat_vnc_tx_total_bytes "stat_vnc_tx_total_bytes" $stat_vnc_rx_total_bytes "stat_vnc_rx_total_bytes"                                             ]]
set result [test_check $result [stats_comparison $stat_vnc_tx_total_good_bytes "stat_vnc_tx_total_good_bytes" $stat_vnc_rx_total_good_bytes "stat_vnc_rx_total_good_bytes"                                             ]]
set result [test_check $result [stats_comparison $stat_vnc_tx_packet_64_bytes "stat_vnc_tx_packet_64_bytes" $stat_vnc_rx_packet_64_bytes "stat_vnc_rx_packet_64_bytes"                             ]]
set result [test_check $result [stats_comparison $stat_vnc_tx_packet_65_127_bytes "stat_vnc_tx_packet_65_127_bytes" $stat_vnc_rx_packet_65_127_bytes "stat_vnc_rx_packet_65_127_bytes"             ]]
set result [test_check $result [stats_comparison $stat_vnc_tx_packet_128_255_bytes "stat_vnc_tx_packet_128_255_bytes" $stat_vnc_rx_packet_128_255_bytes "stat_vnc_rx_packet_128_255_bytes"         ]]
set result [test_check $result [stats_comparison $stat_vnc_tx_packet_256_511_bytes "stat_vnc_tx_packet_256_511_bytes" $stat_vnc_rx_packet_256_511_bytes "stat_vnc_rx_packet_256_511_bytes"         ]]
set result [test_check $result [stats_comparison $stat_vnc_tx_packet_512_1023_bytes "stat_vnc_tx_packet_512_1023_bytes" $stat_vnc_rx_packet_512_1023_bytes "stat_vnc_rx_packet_512_1023_bytes"     ]]
set result [test_check $result [stats_comparison $stat_vnc_tx_packet_1024_1518_bytes "stat_vnc_tx_packet_1024_1518_bytes" $stat_vnc_rx_packet_1024_1518_bytes "stat_vnc_rx_packet_1024_1518_bytes" ]]
set result [test_check $result [stats_comparison $stat_vnc_tx_packet_1519_1522_bytes "stat_vnc_tx_packet_1519_1522_bytes" $stat_vnc_rx_packet_1519_1522_bytes "stat_vnc_rx_packet_1519_1522_bytes" ]]
set result [test_check $result [stats_comparison $stat_vnc_tx_packet_1523_1548_bytes "stat_vnc_tx_packet_1523_1548_bytes" $stat_vnc_rx_packet_1523_1548_bytes "stat_vnc_rx_packet_1523_1548_bytes" ]]
set result [test_check $result [stats_comparison $stat_vnc_tx_packet_1549_2047_bytes "stat_vnc_tx_packet_1549_2047_bytes" $stat_vnc_rx_packet_1549_2047_bytes "stat_vnc_rx_packet_1549_2047_bytes" ]]
set result [test_check $result [stats_comparison $stat_vnc_tx_packet_2048_4095_bytes "stat_vnc_tx_packet_2048_4095_bytes" $stat_vnc_rx_packet_2048_4095_bytes "stat_vnc_rx_packet_2048_4095_bytes" ]]
set result [test_check $result [stats_comparison $stat_vnc_tx_packet_4096_8191_bytes "stat_vnc_tx_packet_4096_8191_bytes" $stat_vnc_rx_packet_4096_8191_bytes "stat_vnc_rx_packet_4096_8191_bytes" ]]
set result [test_check $result [stats_comparison $stat_vnc_tx_packet_8192_9215_bytes "stat_vnc_tx_packet_8192_9215_bytes" $stat_vnc_rx_packet_8192_9215_bytes "stat_vnc_rx_packet_8192_9215_bytes"	]]
set result [test_check $result [stats_comparison $stat_vnc_tx_packet_large "stat_vnc_tx_packet_large" $stat_vnc_rx_packet_large "stat_vnc_rx_packet_large"                                          ]]
set result [test_check $result [stats_comparison $stat_vnc_tx_packet_small "stat_vnc_tx_packet_small" $stat_vnc_rx_packet_small "stat_vnc_rx_packet_small"                                          ]]

puts $::fp_stats "~~DUT~~"

set result [test_check $result [stats_comparison $stat_tx_total_packets_soft "stat_tx_total_packets_soft" $stat_rx_total_packets_soft "stat_rx_total_packets_soft"                                      ]]
set result [test_check $result [stats_comparison $stat_tx_total_good_packets_soft "stat_tx_total_good_packets_soft" $stat_rx_total_good_packets_soft "stat_rx_total_good_packets_soft"                  ]]
set result [test_check $result [stats_comparison $stat_tx_total_bytes_soft "stat_tx_total_bytes_soft" $stat_rx_total_bytes_soft "stat_rx_total_bytes_soft"                                              ]]
set result [test_check $result [stats_comparison $stat_tx_total_good_bytes_soft "stat_tx_total_good_bytes_soft" $stat_rx_total_good_bytes_soft "stat_rx_total_good_bytes_soft"                          ]]
set result [test_check $result [stats_comparison $stat_tx_packet_64_bytes_soft "stat_tx_packet_64_bytes_soft" $stat_rx_packet_64_bytes_soft "stat_rx_packet_64_bytes_soft"                              ]]
set result [test_check $result [stats_comparison $stat_tx_packet_65_127_bytes_soft "stat_tx_packet_65_127_bytes_soft" $stat_rx_packet_65_127_bytes_soft "stat_rx_packet_65_127_bytes_soft"              ]]
set result [test_check $result [stats_comparison $stat_tx_packet_128_255_bytes_soft "stat_tx_packet_128_255_bytes_soft" $stat_rx_packet_128_255_bytes_soft "stat_rx_packet_128_255_bytes_soft"          ]]
set result [test_check $result [stats_comparison $stat_tx_packet_256_511_bytes_soft "stat_tx_packet_256_511_bytes_soft" $stat_rx_packet_256_511_bytes_soft "stat_rx_packet_256_511_bytes_soft"          ]]
set result [test_check $result [stats_comparison $stat_tx_packet_512_1023_bytes_soft "stat_tx_packet_512_1023_bytes_soft" $stat_rx_packet_512_1023_bytes_soft "stat_rx_packet_512_1023_bytes_soft"      ]]
set result [test_check $result [stats_comparison $stat_tx_packet_1024_1518_bytes_soft "stat_tx_packet_1024_1518_bytes_soft" $stat_rx_packet_1024_1518_bytes_soft "stat_rx_packet_1024_1518_bytes_soft"  ]]
set result [test_check $result [stats_comparison $stat_tx_packet_1519_1522_bytes_soft "stat_tx_packet_1519_1522_bytes_soft" $stat_rx_packet_1519_1522_bytes_soft "stat_rx_packet_1519_1522_bytes_soft"  ]]
set result [test_check $result [stats_comparison $stat_tx_packet_1523_1548_bytes_soft "stat_tx_packet_1523_1548_bytes_soft" $stat_rx_packet_1523_1548_bytes_soft "stat_rx_packet_1523_1548_bytes_soft"  ]]
set result [test_check $result [stats_comparison $stat_tx_packet_1549_2047_bytes_soft "stat_tx_packet_1549_2047_bytes_soft" $stat_rx_packet_1549_2047_bytes_soft "stat_rx_packet_1549_2047_bytes_soft"  ]]
set result [test_check $result [stats_comparison $stat_tx_packet_2048_4095_bytes_soft "stat_tx_packet_2048_4095_bytes_soft" $stat_rx_packet_2048_4095_bytes_soft "stat_rx_packet_2048_4095_bytes_soft"  ]]
set result [test_check $result [stats_comparison $stat_tx_packet_4096_8191_bytes_soft "stat_tx_packet_4096_8191_bytes_soft" $stat_rx_packet_4096_8191_bytes_soft "stat_rx_packet_4096_8191_bytes_soft"  ]]
set result [test_check $result [stats_comparison $stat_tx_packet_8192_9215_bytes_soft "stat_tx_packet_8192_9215_bytes_soft" $stat_rx_packet_8192_9215_bytes_soft "stat_rx_packet_8192_9215_bytes_soft"  ]]
set result [test_check $result [stats_comparison $stat_tx_packet_large_soft "stat_tx_packet_large_soft" $stat_rx_packet_large_soft "stat_rx_packet_large_soft"                                          ]]
set result [test_check $result [stats_comparison $stat_tx_packet_small_soft "stat_tx_packet_small_soft" $stat_rx_packet_small_soft "stat_rx_packet_small_soft"                                          ]]
set result [test_check $result [stats_comparison $stat_tx_unicast_soft "stat_tx_unicast_soft" $stat_rx_unicast_soft "stat_rx_unicast_soft"                                                              ]]
set result [test_check $result [stats_comparison $stat_tx_multicast_soft "stat_tx_multicast_soft" $stat_rx_multicast_soft "stat_rx_multicast_soft"                                                      ]]
set result [test_check $result [stats_comparison $stat_tx_broadcast_soft "stat_tx_broadcast_soft" $stat_rx_broadcast_soft "stat_rx_broadcast_soft"                                                      ]]
set result [test_check $result [stats_comparison $stat_tx_vlan_soft "stat_tx_vlan_soft" $stat_rx_vlan_soft "stat_rx_vlan_soft"																			]]	

puts $::fp_stats "************counts/good counts comparison************"
puts $::fp_stats "~~VNC~~"

set result [test_check $result [stats_comparison $stat_vnc_tx_total_packets "stat_vnc_tx_total_packets" $stat_vnc_tx_total_good_packets "stat_vnc_tx_total_good_packets"       ]]
set result [test_check $result [stats_comparison $stat_vnc_tx_total_bytes "stat_vnc_tx_total_bytes" $stat_vnc_tx_total_good_bytes "stat_vnc_tx_total_good_bytes"               ]]
set result [test_check $result [stats_comparison $stat_vnc_rx_total_packets "stat_vnc_rx_total_packets" $stat_vnc_rx_total_good_packets "stat_vnc_rx_total_good_packets"       ]]
set result [test_check $result [stats_comparison $stat_vnc_rx_total_bytes "stat_vnc_rx_total_bytes" $stat_vnc_rx_total_good_bytes "stat_vnc_rx_total_good_bytes"               ]]
																																															                                                                                                                                                                        
puts $::fp_stats "~~DUT~~"                                                                                                                                                                 
set result [test_check $result [stats_comparison $stat_tx_total_packets_soft "stat_tx_total_packets_soft" $stat_tx_total_good_packets_soft "stat_tx_total_good_packets_soft"   ]]
set result [test_check $result [stats_comparison $stat_tx_total_bytes_soft "stat_tx_total_bytes_soft" $stat_tx_total_good_bytes_soft "stat_tx_total_good_bytes_soft"           ]]
set result [test_check $result [stats_comparison $stat_rx_total_packets_soft "stat_rx_total_packets_soft" $stat_rx_total_good_packets_soft "stat_rx_total_good_packets_soft"   ]]
set result [test_check $result [stats_comparison $stat_rx_total_bytes_soft "stat_rx_total_bytes_soft" $stat_rx_total_good_bytes_soft "stat_rx_total_good_bytes_soft"           ]]																																													

puts $::fp_stats "************VNC/DUT comparison************"
set result [test_check $result [stats_comparison  $stat_vnc_tx_unicast "stat_vnc_tx_unicast"  $stat_tx_unicast_soft  "stat_tx_unicast_soft"              ]]
set result [test_check $result [stats_comparison  $stat_vnc_tx_multicast "stat_vnc_tx_multicast"  $stat_tx_multicast_soft "stat_tx_multicast_soft"  ]]
set result [test_check $result [stats_comparison  $stat_vnc_tx_broadcast "stat_vnc_tx_broadcast"  $stat_tx_broadcast_soft "stat_tx_broadcast_soft"  ]]
set result [test_check $result [stats_comparison  $stat_vnc_tx_vlan "stat_vnc_tx_vlan"  $stat_tx_vlan_soft "stat_tx_vlan_soft"								]]

set result [test_check $result [stats_comparison  $stat_vnc_tx_total_packets "stat_vnc_tx_total_packets"  $stat_tx_total_packets_soft "stat_tx_total_packets_soft"                                                             ]]
set result [test_check $result [stats_comparison  $stat_vnc_tx_total_good_packets "stat_vnc_tx_total_good_packets"  $stat_tx_total_good_packets_soft "stat_tx_total_good_packets_soft"                               ]]
set result [test_check $result [stats_comparison  $stat_vnc_tx_total_bytes "stat_vnc_tx_total_bytes"  $stat_tx_total_bytes_soft "stat_tx_total_bytes_soft"                                                                         ]]
set result [test_check $result [stats_comparison  $stat_vnc_tx_total_good_bytes "stat_vnc_tx_total_good_bytes"  $stat_tx_total_good_bytes_soft "stat_tx_total_good_bytes_soft"                                                      ]]
set result [test_check $result [stats_comparison  $stat_vnc_tx_packet_64_bytes "stat_vnc_tx_packet_64_bytes"  $stat_tx_packet_64_bytes_soft "stat_tx_packet_64_bytes_soft"                                                 ]]
set result [test_check $result [stats_comparison  $stat_vnc_tx_packet_65_127_bytes "stat_vnc_tx_packet_65_127_bytes"  $stat_tx_packet_65_127_bytes_soft "stat_tx_packet_65_127_bytes_soft"                         ]]
set result [test_check $result [stats_comparison  $stat_vnc_tx_packet_128_255_bytes "stat_vnc_tx_packet_128_255_bytes"  $stat_tx_packet_128_255_bytes_soft "stat_tx_packet_128_255_bytes_soft"                   ]]
set result [test_check $result [stats_comparison  $stat_vnc_tx_packet_256_511_bytes "stat_vnc_tx_packet_256_511_bytes"  $stat_tx_packet_256_511_bytes_soft "stat_tx_packet_256_511_bytes_soft"                   ]]
set result [test_check $result [stats_comparison  $stat_vnc_tx_packet_512_1023_bytes "stat_vnc_tx_packet_512_1023_bytes"  $stat_tx_packet_512_1023_bytes_soft "stat_tx_packet_512_1023_bytes_soft"             ]]
set result [test_check $result [stats_comparison  $stat_vnc_tx_packet_1024_1518_bytes "stat_vnc_tx_packet_1024_1518_bytes"  $stat_tx_packet_1024_1518_bytes_soft "stat_tx_packet_1024_1518_bytes_soft"       ]]
set result [test_check $result [stats_comparison  $stat_vnc_tx_packet_1519_1522_bytes "stat_vnc_tx_packet_1519_1522_bytes"  $stat_tx_packet_1519_1522_bytes_soft "stat_tx_packet_1519_1522_bytes_soft"       ]]
set result [test_check $result [stats_comparison  $stat_vnc_tx_packet_1523_1548_bytes "stat_vnc_tx_packet_1523_1548_bytes"  $stat_tx_packet_1523_1548_bytes_soft "stat_tx_packet_1523_1548_bytes_soft"       ]]
set result [test_check $result [stats_comparison  $stat_vnc_tx_packet_1549_2047_bytes "stat_vnc_tx_packet_1549_2047_bytes"  $stat_tx_packet_1549_2047_bytes_soft "stat_tx_packet_1549_2047_bytes_soft"       ]]
set result [test_check $result [stats_comparison  $stat_vnc_tx_packet_2048_4095_bytes "stat_vnc_tx_packet_2048_4095_bytes"  $stat_tx_packet_2048_4095_bytes_soft "stat_tx_packet_2048_4095_bytes_soft"       ]]
set result [test_check $result [stats_comparison  $stat_vnc_tx_packet_4096_8191_bytes "stat_vnc_tx_packet_4096_8191_bytes"  $stat_tx_packet_4096_8191_bytes_soft "stat_tx_packet_4096_8191_bytes_soft"       ]]
set result [test_check $result [stats_comparison  $stat_vnc_tx_packet_8192_9215_bytes "stat_vnc_tx_packet_8192_9215_bytes"  $stat_tx_packet_8192_9215_bytes_soft "stat_tx_packet_8192_9215_bytes_soft"		]]

set result [test_check $result [stats_comparison  $stat_vnc_tx_packet_small "stat_vnc_tx_packet_small"  $stat_tx_packet_small_soft "stat_tx_packet_small_soft"    ]]
set result [test_check $result [stats_comparison  $stat_vnc_tx_packet_large "stat_vnc_tx_packet_large"  $stat_tx_packet_large_soft "stat_tx_packet_large_soft"    ]]
set result [test_check $result [stats_comparison  $stat_vnc_tx_frame_error "stat_vnc_tx_frame_error"  $stat_tx_frame_error_soft "stat_tx_frame_error_soft"			]]


set result [test_check $result [stats_comparison  $stat_vnc_rx_unicast "stat_vnc_rx_unicast"  $stat_rx_unicast_soft "stat_rx_unicast_soft"              ]]
set result [test_check $result [stats_comparison  $stat_vnc_rx_multicast "stat_vnc_rx_multicast"  $stat_rx_multicast_soft "stat_rx_multicast_soft"  ]]
set result [test_check $result [stats_comparison  $stat_vnc_rx_broadcast "stat_vnc_rx_broadcast"  $stat_rx_broadcast_soft "stat_rx_broadcast_soft"  ]]
set result [test_check $result [stats_comparison  $stat_vnc_rx_vlan "stat_vnc_rx_vlan"  $stat_rx_vlan_soft "stat_rx_vlan_soft"								]]

set result [test_check $result [stats_comparison  $stat_vnc_rx_total_packets "stat_vnc_rx_total_packets"  $stat_rx_total_packets_soft "stat_rx_total_packets_soft"                                                             ]]
set result [test_check $result [stats_comparison  $stat_vnc_rx_total_good_packets "stat_vnc_rx_total_good_packets"  $stat_rx_total_good_packets_soft "stat_rx_total_good_packets_soft"                               ]]
set result [test_check $result [stats_comparison  $stat_vnc_rx_total_bytes "stat_vnc_rx_total_bytes"  $stat_rx_total_bytes_soft "stat_rx_total_bytes_soft"                                                                         ]]
set result [test_check $result [stats_comparison  $stat_vnc_rx_total_good_bytes "stat_vnc_rx_total_good_bytes"  $stat_rx_total_good_bytes_soft "stat_rx_total_good_bytes_soft"                                                      ]]
set result [test_check $result [stats_comparison  $stat_vnc_rx_packet_64_bytes "stat_vnc_rx_packet_64_bytes"  $stat_rx_packet_64_bytes_soft "stat_rx_packet_64_bytes_soft"                                          ]]
set result [test_check $result [stats_comparison  $stat_vnc_rx_packet_65_127_bytes "stat_vnc_rx_packet_65_127_bytes"  $stat_rx_packet_65_127_bytes_soft "stat_rx_packet_65_127_bytes_soft"                  ]]
set result [test_check $result [stats_comparison  $stat_vnc_rx_packet_128_255_bytes "stat_vnc_rx_packet_128_255_bytes"  $stat_rx_packet_128_255_bytes_soft "stat_rx_packet_128_255_bytes_soft"            ]]
set result [test_check $result [stats_comparison  $stat_vnc_rx_packet_256_511_bytes "stat_vnc_rx_packet_256_511_bytes"  $stat_rx_packet_256_511_bytes_soft "stat_rx_packet_256_511_bytes_soft"            ]]
set result [test_check $result [stats_comparison  $stat_vnc_rx_packet_512_1023_bytes "stat_vnc_rx_packet_512_1023_bytes"  $stat_rx_packet_512_1023_bytes_soft "stat_rx_packet_512_1023_bytes_soft"      ]]
set result [test_check $result [stats_comparison  $stat_vnc_rx_packet_1024_1518_bytes "stat_vnc_rx_packet_1024_1518_bytes"  $stat_rx_packet_1024_1518_bytes_soft "stat_rx_packet_1024_1518_bytes_soft"]]
set result [test_check $result [stats_comparison  $stat_vnc_rx_packet_1519_1522_bytes "stat_vnc_rx_packet_1519_1522_bytes"  $stat_rx_packet_1519_1522_bytes_soft "stat_rx_packet_1519_1522_bytes_soft"]]
set result [test_check $result [stats_comparison  $stat_vnc_rx_packet_1523_1548_bytes "stat_vnc_rx_packet_1523_1548_bytes"  $stat_rx_packet_1523_1548_bytes_soft "stat_rx_packet_1523_1548_bytes_soft"]]
set result [test_check $result [stats_comparison  $stat_vnc_rx_packet_1549_2047_bytes "stat_vnc_rx_packet_1549_2047_bytes"  $stat_rx_packet_1549_2047_bytes_soft "stat_rx_packet_1549_2047_bytes_soft"]]
set result [test_check $result [stats_comparison  $stat_vnc_rx_packet_2048_4095_bytes "stat_vnc_rx_packet_2048_4095_bytes"  $stat_rx_packet_2048_4095_bytes_soft "stat_rx_packet_2048_4095_bytes_soft"]]
set result [test_check $result [stats_comparison  $stat_vnc_rx_packet_4096_8191_bytes "stat_vnc_rx_packet_4096_8191_bytes"  $stat_rx_packet_4096_8191_bytes_soft "stat_rx_packet_4096_8191_bytes_soft"]]
set result [test_check $result [stats_comparison  $stat_vnc_rx_packet_8192_9215_bytes "stat_vnc_rx_packet_8192_9215_bytes"  $stat_rx_packet_8192_9215_bytes_soft "stat_rx_packet_8192_9215_bytes_soft"]]


set result [test_check $result [stats_comparison  $stat_vnc_rx_inrangeerr "stat_vnc_rx_inrangeerr" $stat_rx_inrangeerr_soft "stat_rx_inrangeerr_soft"                           ]	]
set result [test_check $result [stats_comparison  $stat_vnc_rx_bad_fcs "stat_vnc_rx_bad_fcs" $stat_rx_bad_fcs_soft "stat_rx_bad_fcs_soft"                                        ]     ]
set result [test_check $result [stats_comparison  $stat_vnc_rx_oversize "stat_vnc_rx_oversize" $stat_rx_oversize_soft "stat_rx_oversize_soft"                                   ]     ]
set result [test_check $result [stats_comparison  $stat_vnc_rx_undersize "stat_vnc_rx_undersize" $stat_rx_undersize_soft "stat_rx_undersize_soft"                              ]     ]
set result [test_check $result [stats_comparison  $stat_vnc_rx_toolong "stat_vnc_rx_toolong" $stat_rx_toolong_soft "stat_rx_toolong_soft"                                        ]     ]
set result [test_check $result [stats_comparison  $stat_vnc_rx_packet_small "stat_vnc_rx_packet_small" $stat_rx_packet_small_soft "stat_rx_packet_small_soft"               ]     ]
set result [test_check $result [stats_comparison  $stat_vnc_rx_packet_large "stat_vnc_rx_packet_large" $stat_rx_packet_large_soft "stat_rx_packet_large_soft"               ]     ]
set result [test_check $result [stats_comparison  $stat_vnc_rx_jabber "stat_vnc_rx_jabber" $stat_rx_jabber_soft "stat_rx_jabber_soft"                                               ]    ]
set result [test_check $result [stats_comparison  $stat_vnc_rx_fragment "stat_vnc_rx_fragment" $stat_rx_fragment_soft "stat_rx_fragment_soft"                                   ]     ]
set result [test_check $result [stats_comparison  $stat_vnc_rx_packet_bad_fcs "stat_vnc_rx_packet_bad_fcs" $stat_rx_packet_bad_fcs_soft "stat_rx_packet_bad_fcs_soft"     ]     ]
set result [test_check $result [stats_comparison  $stat_vnc_rx_user_pause "stat_vnc_rx_user_pause" $stat_rx_user_pause_soft "stat_rx_user_pause_soft"						   ]    ]
set result [test_check $result [stats_comparison  $stat_vnc_rx_pause "stat_vnc_rx_pause" $stat_rx_pause_soft "stat_rx_pause_soft"													]   ]

puts $::fp_stats "************Value check************"                                                                                                                                                                            
puts $::fp_stats "~~VNC~~"     
#EG add val_compare
set result [test_check $result [val_larger "stat_vnc_tx_total_packets"	$stat_vnc_tx_total_packets 0x0000]]
set result [test_check $result [val_larger "stat_vnc_tx_total_bytes"	$stat_vnc_tx_total_bytes 0x0000]]
set result [test_check $result [val_compare "stat_vnc_tx_frame_error"	$stat_vnc_tx_frame_error 0x0000]]
set result [test_check $result [val_compare "stat_vnc_tx_error_unfout"	$stat_vnc_tx_error_unfout 0x0000]]
set result [test_check $result [val_compare "stat_vnc_tx_error_overflow"	$stat_vnc_tx_error_overflow 0x0000]]

set result [test_check $result [val_larger "stat_vnc_rx_total_packets"	$stat_vnc_rx_total_packets 0x0000]]
set result [test_check $result [val_larger "stat_vnc_rx_total_bytes"	$stat_vnc_rx_total_bytes 0x0000]]
set result [test_check $result [val_compare "stat_vnc_rx_inrangeerr"	$stat_vnc_rx_inrangeerr 0x0000]]
set result [test_check $result [val_compare "stat_vnc_rx_bad_fcs"	$stat_vnc_rx_bad_fcs 0x0000]]
set result [test_check $result [val_compare "stat_vnc_rx_oversize"	$stat_vnc_rx_oversize 0x0000]]
set result [test_check $result [val_compare "stat_vnc_rx_undersize"	$stat_vnc_rx_undersize 0x0000]]
set result [test_check $result [val_compare "stat_vnc_rx_toolong"	$stat_vnc_rx_toolong 0x0000]]
set result [test_check $result [val_compare "stat_vnc_rx_jabber"	$stat_vnc_rx_jabber 0x0000]]
set result [test_check $result [val_compare "stat_vnc_rx_fragment"	$stat_vnc_rx_fragment 0x0000]]
set result [test_check $result [val_compare "stat_vnc_rx_packet_bad_fcs"	$stat_vnc_rx_packet_bad_fcs 0x0000]]
set result [test_check $result [val_compare "stat_vnc_rx_bad_preamble"	$stat_vnc_rx_bad_preamble 0x0000]]

puts $::fp_stats "~~DUT~~" 
set result [test_check $result [val_larger "status_tx_cycle_soft_count"	$status_tx_cycle_soft_count 0x0000]]
set result [test_check $result [val_larger "stat_tx_cycle_count" $stat_tx_cycle_count 0x0000]]
set result [test_check $result [val_larger "stat_tx_total_packets_soft" $stat_tx_total_packets_soft 0x0000]]
set result [test_check $result [val_larger "stat_tx_total_bytes_soft" $stat_tx_total_bytes_soft 0x0000]]
set result [test_check $result [val_compare "stat_tx_frame_error_soft" $stat_tx_frame_error_soft 0x0000]]
set result [test_check $result [val_compare "stat_tx_total_err_bytes_soft" $stat_tx_total_err_bytes_soft 0x0000]]
set result [test_check $result [val_compare "stat_tx_bad_fcs_soft" $stat_tx_bad_fcs_soft 0x0000]]

set result [test_check $result [val_larger "status_rx_cycle_soft_count"	$status_rx_cycle_soft_count	0x0000]]
set result [test_check $result [val_larger "stat_rx_cycle_count" $stat_tx_cycle_count	0x0000]]
set result [test_check $result [val_larger "stat_rx_total_packets_soft" $stat_rx_total_packets_soft 0x0000]]
set result [test_check $result [val_larger "stat_rx_total_bytes_soft" $stat_rx_total_bytes_soft 0x0000]]
set result [test_check $result [val_compare "stat_rx_inrangeerr_soft" $stat_rx_inrangeerr_soft 0x0000]]
set result [test_check $result [val_compare "stat_rx_bad_fcs_soft" $stat_rx_bad_fcs_soft 0x0000]]
set result [test_check $result [val_compare "stat_rx_oversize_soft" $stat_rx_oversize_soft 0x0000]]
set result [test_check $result [val_compare "stat_rx_undersize_soft" $stat_rx_undersize_soft 0x0000]]                                                                                                                                                            
set result [test_check $result [val_compare "stat_rx_toolong_soft" $stat_rx_toolong_soft 0x0000]]                                                                                                                                                            
set result [test_check $result [val_compare "stat_rx_jabber_soft" $stat_rx_jabber_soft 0x0000]]                                                                                                                                                            
set result [test_check $result [val_compare "stat_rx_fragment_soft" $stat_rx_fragment_soft 0x0000]]                                                                                                                                                            
set result [test_check $result [val_compare "stat_rx_packet_bad_fcs_soft" $stat_rx_packet_bad_fcs_soft 0x0000]]                                                                                                                                                            
set result [test_check $result [val_compare "stat_rx_bad_code_soft" $stat_rx_bad_code_soft 0x0000]]                                                                                                                                                            
set result [test_check $result [val_compare "stat_rx_stomped_fcs_soft" $stat_rx_stomped_fcs_soft 0x0000]]                                                                                                                                                            
set result [test_check $result [val_compare "stat_rx_truncated_soft" $stat_rx_truncated_soft 0x0000]]  
set result [test_check $result [val_compare "stat_rx_test_pattern_mismatch_soft" $stat_rx_test_pattern_mismatch_soft 0x0000]]                                                                 
set result [test_check $result [val_compare "stat_rx_total_err_bytes_soft" $stat_rx_total_err_bytes_soft 0x0000]]                                                                 
set result [test_check $result [val_compare "stat_rx_bad_std_preamble_count_soft" $stat_rx_bad_std_preamble_count_soft 0x0000]]                                                                 

# needs to get expected good values from somewhere 
puts $::fp_stats "************stats check************"

set data [reg_rd 0xa0]
set bitslip_cnt     [string range $data 8 end]
set result [test_check $result [stat_val_compare				stat_tx_status_reg1			 $stat_tx_status_reg1			0x0008								]		]
set result [test_check $result [stat_val_compare				stat_rx_status_reg1          $stat_rx_status_reg1        	0x4001                              ]       ]
set result [test_check $result [stat_val_compare				stat_tx_rt_status_reg1       $stat_tx_rt_status_reg1     	0x0008                              ]       ]
set result [test_check $result [stat_val_compare				stat_rx_rt_status_reg1       $stat_rx_rt_status_reg1     	0x4001                              ]       ]
set result [test_check $result [stat_val_compare				stat_rx_block_lock_reg       $stat_rx_block_lock_reg     	0x0001                              ]       ]
set result [test_check $result [stat_val_compare				stat_rx_valid_ctrl_code      $stat_rx_valid_ctrl_code  		0x0001                              ]       ]
# set result [test_check $result [stat_val_compare				stat_rx_bit_slip             $stat_rx_bit_slip           	$bitslip_cnt                        ]       ]
# set result [test_check $result [stat_val_compare				stat_tx_flow_control_reg1    $stat_tx_flow_control_reg1  	                                    ]   ]
# set result [test_check $result [stat_val_compare				stat_rx_flow_control_reg1    $stat_rx_flow_control_reg1                                         ]   ]
# set result [test_check $result [stat_val_compare				stat_rx_flow_control_reg2    $stat_rx_flow_control_reg2                                         ]   ]

if {$result == 1 } {
	puts $::fp_stats "test passed"
} else {
	puts $::fp_stats "test failed"
}
