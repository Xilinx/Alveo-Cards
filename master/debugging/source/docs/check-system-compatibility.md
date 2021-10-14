<table class="sphinxhide">
 <tr>
   <td align="center"><img src="https://www.xilinx.com/content/dam/xilinx/imgs/press/media-kits/corporate/xilinx-logo.png" width="30%"/><h1>Alveo Debug Guide</h1>
   </td>
 </tr>
</table>

# Checking System Compatibility
This page will help you determine if your host machine is compatible with the Vitis Alveo flow. It is part of the larger Alveo debug guide. If you are just starting to debug, please consult the [main page](../README.md) to determine if this is the best page for your purposes

## System Compatibility Checks
Ensure your system is compatible with XRT and the Alveo Card by confirming the following:

- The [Linux OS](common-steps.md#determine-linux-release) and [Kernel](common-steps.md#determine-linux-kernel-and-header-information) are compatible with those supported by the [XRT drivers](https://github.com/Xilinx/XRT/blob/master/src/runtime_src/doc/toc/system_requirements.rst).
- The [host machine and hypervisor](common-steps.md#host-machine-and-hypervisor-information) are compatible.
- PCIe slot is compatible
   * Ensure the [PCIe slot type and speed](common-steps.md#determine-pcie-slot-type-and-speed) match the card deployment platform requirements.
   * Confirm the PCIe slot provides 75W
     * Covered in the host computer's documentation
- For U200/U250/U280 Alveo cards, ensure the 8-pin PCIe AUX power is connected
     * If AUX power is missing contact your system vendor to acquire the needed cabling.  This [AR 72298](https://www.xilinx.com/support/answers/72298.html) provides additional guidance.
     *  For each card, review the output from `sudo xbmgmt examine -d <management BDF>` for confirmation of PCIe AUX power
     *  A 225W card will have the entry: `Max Power            : 225W`


### Xilinx Support

For additional support resources such as Answers, Documentation, Downloads, and Alerts, see the [Xilinx Support pages](http://www.xilinx.com/support). For additional assistance, post your question on the Xilinx Community Forums – [Alveo Accelerator Card](https://support.xilinx.com/s/topic/0TO2E000000YKXlWAO/alveo-accelerator-cards). 

Have a suggestion, or found an issue please send an email to alveo_cards_debugging@xilinx.com .

### License

All software including scripts in this distribution are licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

All images and documentation, including all debug and support documentation, are licensed under the Creative Commons (CC) Attribution 4.0 International License (the "CC-BY-4.0 License"); you may not use this file except in compliance with the CC-BY-4.0 License.

You may obtain a copy of the CC-BY-4.0 License at
[https://creativecommons.org/licenses/by/4.0/]( https://creativecommons.org/licenses/by/4.0/)


Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

<p align="center"><sup>XD027 | &copy; Copyright 2021 Xilinx, Inc.</sup></p>
