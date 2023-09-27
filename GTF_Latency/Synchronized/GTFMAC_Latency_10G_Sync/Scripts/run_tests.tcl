#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

# include the csv package
package require csv

source -notrace helpers.tcl

# #################
# Set args
# #################

# 0: FIFO test mode
# 1: Continuos test mode
set ::test_mode 0

# 0: Near-end
# 1: External
set ::loopback_mode 0

# Number of test iterations
set ::num_test 50

# Number of packets to send per test
# Maximum number of packets in FIFO test mode: 4084
# If more than 800,000,000 packets are sent in continous mode, 
# registers can overflow causing inaccurate latency results.
set ::pkt_cnt 250

# when set to 1, stats collected and saved to file
set ::get_stats 0

# Number of iterations to poll for completion before indicating pkt not received and try again
set ::poll_iterations 5

# global debug - provides verbose output display
set ::debug 1


#test duration in seconds for traffic  (only valid when pkt_cnt = 0)
set ::test_duration 300


# Date and time for file name
set system_time [clock seconds]
set system_date [clock format $system_time -format {%b_%d_%Y_%H_%M_%S}]
# set file name for the output log file
set file_name_log ./Test_Output/latency_measurement_$system_date.log
# set file name for the output csv file
set file_name_csv ./Test_Output/latency_measurement_$system_date.csv
# set file name for the output stats file
set file_name_stats ./Test_Output/stats_$system_date.csv

# Open file for test output
set ::fp [open "$file_name_log" w]
# open csv file for test output
set ::fp_csv [open "$file_name_csv" w]
# open file for stats output
set ::fp_stats [open "$file_name_stats" w]

# May be necessary to clear the pipeline - skip first n records as 
# they will have erroneous values
set ::skip_first_n_records 10


# Write parameters to file
	puts $::fp "=========================================================================================="
	puts $::fp "TEST SETUP"
	puts $::fp "=========================================================================================="
	puts $::fp "test_mode: $::test_mode"
	puts $::fp "loopback_mode: $::loopback_mode"
	puts $::fp "num_test: $::num_test"
	puts $::fp "pkt_cnt: $::pkt_cnt"
	puts $::fp "=========================================================================================="

# #################
# Main Procedure  
# #################

	# Loop design reset, bringup, and test for a number of test iteration
	for {set ::index 0} {$::index < $::num_test} {incr ::index} {
		puts ""
		puts "============================"
		puts "Test Number: $::index"
		puts "============================"

		reset_design
		setup_vnc
		send_pkts
	}

	# Close file 
	close $::fp
	close $::fp_csv
	close $::fp_stats

	puts "=========================================================================================="
	puts "									Test Complete"
	puts "=========================================================================================="
