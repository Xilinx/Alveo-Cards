#!/bin/bash

######################
# License
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at[http://www.apache.org/licenses/LICENSE-2.0]( http://www.apache.org/licenses/LICENSE-2.0 )
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
# 
# XD027 | Copyright 2021 Xilinx, Inc.
######################

#output file
FILE="xrtLog.txt"

function log() {
	echo "*****" | tee -a $FILE
	echo "Running $1" | tee -a $FILE
	echo "***** $1 " >>$FILE
	echo "$(eval $1)" >>$FILE
 return 0
}

echo "Running XRT log creation script"
echo "This will take a couple minutes"
echo "You will need sudo access and may be prompted for your password"

if [ -z "$XILINX_XRT" ] 
then
	echo "XRT environment does not appear to be setup. Sourcing /opt/xilinx/xrt/setup.sh"
	source /opt/xilinx/xrt/setup.sh
fi

rm $FILE
log "dmesg"
log "uname -r"
log "cat /etc/*-release"
log "which sudo"
log "sudo lspci -vv -d 10ee:"
log "sudo dmidecode"
log "ps -au"

number_of_cards=$( /opt/xilinx/xrt/bin/xbutil examine | grep -c ....:..:...1 )

echo "Number of cards found: $number_of_cards"

for d in $(eval echo "{1..$((number_of_cards))}"); do 
	mbdf=$( /opt/xilinx/xrt/bin/xbmgmt examine | grep -o ....:..:...0 | sed -n "$d"p)
	log "sudo /opt/xilinx/xrt/bin/xbmgmt examine -d $mbdf"	
	ubdf=$( /opt/xilinx/xrt/bin/xbutil examine | grep -o ....:..:...1 | sed -n "$d"p)
	log "/opt/xilinx/xrt/bin/xbutil examine -d $ubdf -r all"
	log "/opt/xilinx/xrt/bin/xbutil validate -d $ubdf --verbose"
	
done
log "dmesg"


echo "review $FILE before sharing"
