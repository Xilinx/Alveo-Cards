#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#


set channel          0
set addr_offset      0x100000        
set ctl_tx_data_rate 0x0 
set ctl_rx_data_rate 0x0 
set op_mode    NEAR
#set op_mode    NAR
#set op_mode    NORMAL


set HWCHK_LATENCY_CLK_PERIOD_NS  1.5515  # 644 MHz

# wait for axi_aresetn == 1
set data 0
#while { $data == 0} {
#    set data [expr [reg_rd_offset $addr_offset 0xasdfasdsf] & 1]
#}


puts [format "Waiting for DUT to come alive..."]
puts [format "Starting transaction on Channel-%d" channel]

set attempts 0
set data     1
while { ( $data != 0 ) && ($attempts < 100000) } {
    set data [expr [reg_rd_offset $addr_offset 0x0000] & 3]
    incr attempts
}

puts [format "Observed gtfmac status = %0x" $data]

if { [catch { $attempts >= 100000 } ] } { 
    puts [format "ERROR - DUT did not come out of reset" ]
    puts [format "** Error: Test did not complete successfully" ]
    "error stop"
}

puts [format "Report userrdy to the GTF" ]
set addr  0x000C
set data  0x0003
reg_wr_offset  $addr_offset $addr $data 0xF

# Set Operation Mode (normal or loopback)
if { $op_mode == "NEAR" } {
    puts [format "Configure near-end loopback" ]
    #set  data[6:4] = 3'b010
    set op_mode_value 0x0020
}
if { $op_mode == "FAR" } {
    puts [format "Configure far-end loopback" ]
    #set data[6:4] = 3'b100
    set op_mode_value 0x0040
}
if { $op_mode == "NORMAL" } {
    puts [format "Configure Normal Operation" ]
    #set data[6:4] = 3'b000
    set op_mode_value 0x0000
}
set addr    0x10408
set data [reg_rd_offset $addr_offset $addr]
# op mode value in bits 6:4
set data [expr ( $data & 0xFFFFFF8F ) | $op_mode_value]
reg_wr_offset $addr_offset $addr $data


puts [format "Reset the RX side of the GT"]
set addr    0x0010400
set data    0x002
reg_wr_offset $addr_offset $addr $data

set addr    0x0010400
set data    0x000
reg_wr_offset $addr_offset $addr $data

set addr    0x001_0000
hwchk_axil_write $addr_offset $addr [expr $ctl_tx_data_rate*2 + $ctl_rx_data_rate] 

puts [format "HWCHK:    Set up the TX/RX data rate to match"]
set addr    0x0010
set data  [reg_rd_offset $addr_offset 0x0000]
set data  [expr $data | ($ctl_tx_data_rate << 0)  ]
set data  [expr $data | ($ctl_rx_data_rate << 16) ]
puts [format "        HWCHK config=%0x" $data ]
reg_wr_offset $addr_offset $addr $data

puts [format "Allow MAC side of the GTFMAC to bitslip"]
set addr    0x00a4
set data    0x000
reg_wr_offset $addr_offset $addr $data


# Wait for block lock
puts [format "Waiting for HWCHK to detect block lock..."]
set attempts         0
set hwchk_block_lock 1
while { ($hwchk_block_lock != 0) && ($attempts < 100000) {
    set hwchk_block_lock  [reg_rd_offset $addr_offset 0x00A0]
    set hwchk_block_lock  [expr $hwchk_block_lock & (1 << 16) ]
    incr attempts
}

if { $attempts >= 100000 } {
    puts [format "ERROR - no block lock"]
    puts [format "** Error: Test did not complete successfully" ]
    "error stop"
}

puts [format "Block lock found."]

# Only correct bitslip if we are in 10G mode
if { $ctl_tx_data_rate == 0 } {

    puts [format "Allow bitslip logic to correct bitslip in the transceiver..."]
    set addr    0xa4
    set data    0x01
    reg_wr_offset $addr_offset $addr $data

    set attempts 0
    set data     1
    while { ($data != 0) && ($attempts < 100) {
        set data  [reg_rd_offset $addr_offset 0x00A0]
        set data   [expr $data & (1 << 18)]
        incr attempts
    }

    if { $attempts >= 100 } {
        puts [format "ERROR - alignment process failed"]
        puts [format "** Error: Test did not complete successfully"]
        "error stop"
    }

    puts [format "Bitslip issued."]

    puts [format "Waiting for HWCHK to detect block lock..."]
    set attempts         0
    set hwchk_block_lock 0
    while (!hwchk_block_lock && attempts < 100000 )
        set hwchk_block_lock  [reg_rd_offset $addr_offset 0x00A0]
        set hwchk_block_lock  [expr $hwchk_block_lock & (1 << 16)]
        incr attempts
    }

    if { $attempts >= 100000 } {
        puts [format "ERROR - no block lock"]
        puts [format "** Error: Test did not complete successfully" ]
        "error stop"
    }

    puts [format "Block lock found."]
}


# Wait for rx alignment
puts [format "Waiting for HWCHK to detect rx alignment..."]
set attempts        0
set wa_complete_flg 0
while { {$wa_complete_flg != 0} && {$attempts < 100000)} {
    #100000 attempts += 1
}

if { $attempts >= 100000 } {
    puts [format "ERROR - no rx alignment"]
    puts [format "** Error: Test did not complete successfully"]
    "error stop"
}

puts [format "rx alignment achieved."]


puts [format "Waiting for link up."]

set attempts  0
set data      0
while { ($data != 0) && {$attempts < 10000) } {
    set data [reg_rd_offset $addr_offset 0x0000]
    set data [expt $data & (0xF << 8)]
    incr attempts
}
puts [format "After %0d attempts, observed gtfmac status = %0x", $time, attempts, data)

if { $attempts >= 100 } {
    puts [format "ERROR - link down"]
    puts [format "** Error: Test did not complete successfully"]
    "error stop"
} else {
    puts [format "LINK UP"]
}


puts [format "GTFMAC: Configure CONFIGURATION_TX_REG1"]
puts [format "        ctl_tx_fcs_ins_enable=%0x" $ctl_tx_fcs_ins_enable]
puts [format "        ctl_tx_ignore_fcs=%0x" $ctl_tx_ignore_fcs]
puts [format "        ctl_tx_custom_preamble_enable=%0x" $ctl_tx_custom_preamble_enable]
set addr 0x10004
set data [reg_rd_offset $addr_offset $addr]
puts [format "        CONFIGURATION_TX_REG1=%0x" $data]
set data [expr $data & ~(0x1 << 1 ) | ($ctl_tx_fcs_ins_enable         << 1 )] # [1]     
set data [expr $data & ~(0x1 << 2 ) | ($ctl_tx_ignore_fcs             << 2 )] # [2]     
set data [expr $data & ~(0x1 << 3 ) | ($ctl_tx_custom_preamble_enable << 3 )] # [3]     
set data [expr $data & ~(0xF << 8 ) | ($ctl_tx_ipg                    << 8 )] # [11:8]  
set data [expr $data & ~(0x1 << 12) | ($ctl_tx_start_framing_enable   << 12)] # [12]    
puts [format "        CONFIGURATION_TX_REG1=%0x" $data]
reg_wr_offset $addr_offset $addr $data

puts [format "GTFMAC: Configure CONFIGURATION_RX_REG1"]
puts [format "        ctl_rx_ignore_fcs=%0x" $ctl_rx_ignore_fcs]
puts [format "        ctl_rx_custom_preamble_enable=%0x" $ctl_rx_custom_preamble_enable]
set addr 0x10008
set data [reg_rd_offset $addr_offset $addr]
set data [expr $data & ~(0x1 << 2 ) | ($ctl_rx_ignore_fcs               << 2 )] # [2]     
set data [expr $data & ~(0x1 << 5 ) | ($ctl_rx_check_preamble           << 5 )] # [5]     
set data [expr $data & ~(0x1 << 6 ) | ($ctl_rx_custom_preamble_enable   << 6 )] # [6]     
reg_wr_offset $addr_offset $addr $data

puts [format "GTFMAC: Configure CONFIGURATION_RX_MTU1"]
puts [format "        ctl_rx_min_packet_len=%0x" $ctl_rx_min_packet_len]
set addr 0x1000c
set data [reg_rd_offset $addr_offset $addr]
set data $ctl_rx_min_packet_len
reg_wr_offset $addr_offset $addr $data

puts [format "GTFMAC: Configure CONFIGURATION_RX_MTU2"]
puts [format "        ctl_rx_max_packet_len=%0x" $ctl_rx_max_packet_len]
set addr 0x10010
set data [reg_rd_offset $addr_offset $addr]
puts [format "        Read %0x" $data]
set data $ctl_rx_max_packet_len
reg_wr_offset $addr_offset $addr $data
set data [reg_rd_offset $addr_offset $addr]

puts [format "HWCHK:    Set up the HWCHK fcs_ins_enable and preamble_enable."]
puts [format "        ctl_tx_fcs_ins_enable=%0x" $ctl_tx_fcs_ins_enable]
puts [format "        ctl_tx_custom_preamble_enable=%0x" $ctl_tx_custom_preamble_enable]
puts [format "        ctl_rx_custom_preamble_enable=%0x" $ctl_rx_custom_preamble_enable]
puts [format "        ctl_tx_start_framing_enable=%0x" $ctl_tx_start_framing_enable]
set addr 0x0010
set data [reg_rd_offset $addr_offset $addr]
set data [expr $data | ($ctl_tx_fcs_ins_enable << 4)         ]
set data [expr $data | ($ctl_tx_custom_preamble_enable << 8) ]
set data [expr $data | ($ctl_tx_start_framing_enable << 12)  ]
set data [expr $data | ($ctl_rx_custom_preamble_enable << 24)]

puts [format "        HWCHK config=%0x" $data]
reg_wr_offset $addr_offset $addr $data

puts [format "HWCHK:    Set the Error Injection Flag"]
puts [format "        ctl_hwchk_tx_err_inj=%0x" $ctl_hwchk_tx_err_inj]
set addr 0x0040
set data $ctl_hwchk_tx_err_inj
reg_wr_offset $addr_offset $addr $data

puts [format "HWCHK:    Set the Poison Injection Flag"]
puts [format "        ctl_hwchk_tx_poison_inj=%0x" $ctl_hwchk_tx_poison_inj]
set addr 0x0098
set data $ctl_hwchk_tx_poison_inj
reg_wr_offset $addr_offset $addr $data

puts [format "HWCHK:    Set the min and max frame lengths for the generator."]
puts [format "        ctl_rx_min_packet_len=%0x" $ctl_rx_min_packet_len]
puts [format "        ctl_rx_max_packet_len=%0x" $ctl_rx_max_packet_len]
set addr 0x0028
set data $ctl_rx_min_packet_len
reg_wr_offset $addr_offset $addr $data

set addr 0x0024
set data $ctl_rx_max_packet_len
reg_wr_offset $addr_offset $addr $data

# Set the mode
puts [format "Set the frame generation mode."]
puts [format "        ctl_frm_gen_mode=%0x" ctl_frm_gen_mode)
puts [format "        ctl_tx_variable_ipg=%0x" ctl_tx_variable_ipg)
set addr 0x0014
set data 0
set data [expr $data & ~(0x1 << 0 ) | ($ctl_frm_gen_mode    << 0 )] # [0]     
set data [expr $data & ~(0x1 << 8 ) | ($ctl_tx_variable_ipg << 8 )] # [8]     
reg_wr_offset $addr_offset $addr $data

# Specify the number of frames
puts [format "Configure the number of frames to send (%0d)" $frames_to_send ]
set addr 0x002c
set data $frames_to_send
reg_wr_offset $addr_offset $addr $data

puts [format "Tick the HWCHK stats to initialize them."]
set addr 0x0090
set data 0x1
reg_wr_offset $addr_offset $addr $data

puts [format "Tick the GTFMAC stats to initialize them."]
set addr 0x10000 | 0x040C
set data 0x1
reg_wr_offset $addr_offset $addr $data

#set frame_gen_ready 1
#puts [format "Channel-%d  is ready to enable frame generator" $channel ]
#if { $channel == 0 } {
#    wait(&frame_gen_ready == 1)
#}

puts [format "Enable the frame generator and monitor for channel-%d" $channel]
set addr 0x0020
set data 0
set data [expr $data | (1 << 0) ] # gen_en
set data [expr $data | (1 << 4) ] # mon_en
reg_wr_offset $addr_offset $addr $data
set frame_gen_ready 0

set stop_req 0
set stopping 0

# Wait for 
wait(frames_received_l == frames_to_send || timed_out)

puts [format "stop_req = %d"  stop_req)

set stopping 1
 
# Disable the frame generator
set addr 0x0020
set data 0
set data [incr $data | (1'b0 << 0)] # gen_en
reg_wr_offset $addr_offset $addr $data

# delay a bit
after 5000

done


-----------------

fork

    # Thread 1 - wait for done or timeout...
    begin
        fork 
            begin
                fork
                    begin
                        #10ms
                        puts [format "Watchdog reached...", $time)
                        set timed_out 1
                    end
                join_none
                
                wait(frames_received_l == frames_to_send || timed_out)
                
                disable fork
            end 
        join

        puts [format "Stopping...", $time)
        set stop_req 1
        set frame_gen_ready 1
    end


    # Thread 1 - Read data when done.
    begin
        #set lat_cnt   0
        #set lat_min   1000
        #set lat_max   0
        #set lat_total 0
        
        while { $stopping == 0 } {
            #5ns
            if { $stop_req == 1 } {
                puts [format "stop_req = %d"  stop_req)

                set stopping 1
                
                if { $channel != 0 } {
                  wait(frame_gen_ready[channel-1] == 1)
                  wait(frame_gen_ready[channel-1] == 0)
                }
                 
                # Disable the frame generator
                set addr 0x0020
                set data 0
                set data [incr $data | (1'b0 << 0)] # gen_en
                reg_wr_offset $addr_offset $addr $data

                # Flush pipeline
                #repeat (5000) @(negedge axi_aclk)
            }

        }
        
    end
    
join


initial begin
    fork
        begin
            set frames_received_0 0
            forever begin
                wait (sim_tb.clk_recov.gtf_top.u_gtfwizard_0_example_gtfmac_top.gtfmac_hwchk_core_gen[0].i_gtfmac_hwchk_core.i_rx_mon.stat_total_packets_incr === 1);
                wait (sim_tb.clk_recov.gtf_top.u_gtfwizard_0_example_gtfmac_top.gtfmac_hwchk_core_gen[0].i_gtfmac_hwchk_core.i_rx_mon.stat_total_packets_incr === 0);
                frames_received_0 = frames_received_0 + 1;
                puts [format "Received frame %0d for channel-0" $frames_received_0]
            end
        end
    join
end
 
initial begin
    fork
        begin
            hwchk_test (0, 32'h0_0000, frames_received_0);
        end
    join
    $finish;
end
    