#!/bin/bash

######################
# License
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at[http://www.apache.org/licenses/LICENSE-2.0]( http://www.apache.org/licenses/LICENSE-2.0 )
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
# 
# XD027 | Copyright 2021 Xilinx, Inc.
######################

if [ "$#" -ne 1 ]; then
	echo "This script expects only one command line arguement specifying the cardID."
	echo "Please enter: loop_query.sh <cardID> on the command line"
else
	card=$1
	for j in {1..400}; do
		/opt/xilinx/xrt/bin/xbutil query -d $card | grep -A 28 PCB
		sleep 3
		echo "-----------------------"
		echo "-----------------------"
	done
fi
