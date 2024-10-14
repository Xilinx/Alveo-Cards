# 
# Copyright (C) 2024, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: X11
#
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
                