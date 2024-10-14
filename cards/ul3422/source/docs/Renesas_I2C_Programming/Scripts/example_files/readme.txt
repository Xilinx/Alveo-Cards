# (c) Copyright 2019-2022 Xilinx, Inc. All rights reserved.
# (c) Copyright 2022-2024 Advanced Micro Devices, Inc. All rights reserved.
# This file contains confidential and proprietary information
# of Xilinx, Inc. and is protected under U.S. and
# international copyright and other intellectual property
# laws.
# DISCLAIMER
# This disclaimer is not a license and does not grant any
# rights to the materials distributed herewith. Except as
# otherwise provided in a valid license issued to you by
# Xilinx, and to the maximum extent permitted by applicable
# law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
# WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
# AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
# BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
# INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
# (2) Xilinx shall not be liable (whether in contract or tort,
# including negligence, or under any other theory of
# liability) for any loss or damage of any kind or nature
# related to, arising under or in connection with these
# materials, including for any direct, or any indirect,
# special, incidental, or consequential loss or damage
# (including loss of data, profits, goodwill, or any type of
# loss or damage suffered as a result of any action brought
# by a third party) even if such damage or loss was
# reasonably foreseeable or Xilinx had been advised of the
# possibility of the same.
# CRITICAL APPLICATIONS
# Xilinx proddcts are not designed or intended to be fail-
# safe, or for use in any application requiring fail-safe
# performance, such as life-support or safety devices or
# systems, Class III medical devices, nuclear facilities,
# applications related to the deployment of airbags, or any
# other applications that could lead to death, personal
# injury, or severe property or environmental damage
# (individually and collectively, "Critical
# Applications"). Customer assumes the sole risk and
# liability of any use of Xilinx proddcts in Critical
# Applications, subject only to applicable laws and
# regulations governing limitations on proddct liability.
# THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
# PART OF THIS FILE AT ALL TIMES.
# 
#

Below are some examples for how to convert the sequence script file to a BRAM coe file..

Usage:
    ./txt_to_mem.pl -i <input txt file> -o <output coe file> -id <target device ID (0x format)>


Examples:


./txt_to_mem.pl -i  seq_example.txt \
                -o  seq_example.coe \
                -id 0xB0
                
./txt_to_mem.pl -i  RC38612_20221006_094953_programming_161MHz_to_100MHz_config13_v2.txt \
                -o  RC38612_20221006_094953_programming_161MHz_to_100MHz_config13_v2.coe \
                -id 0xB0
                
./txt_to_mem.pl -i  RC38612_20221006_095803_programming_161MHz_to_100MHz_config15_v2.txt \
                -o  RC38612_20221006_095803_programming_161MHz_to_100MHz_config15_v2.coe \
                -id 0xB0
                