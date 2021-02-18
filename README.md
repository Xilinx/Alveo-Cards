<table class="sphinxhide">
 <tr>
   <td align="center"><img src="https://www.xilinx.com/content/dam/xilinx/imgs/press/media-kits/corporate/xilinx-logo.png" width="30%"/><h1>Alveo Debug Guide</h1>
   </td>
 </tr>
</table>

# Overview

This guide is designed to help users quickly isolate, debug and resolve a wide range of Alveo™ card related issues within the Vitis™/XRT flow, from card install through to hardware validation.

## Usage
Similar issues are grouped into categories in the sidebar and in the table below allowing you to quickly narrow down the problem area.  Click on the link matching your issue to be taken to the category. Within each category, an extensive list of encountered issues along with detailed error messages, symptoms and resolution steps are provided.

This guide uses terms like reboot, shut down, cold boot and unplug.  See [Terminology](docs/terminology.md) for a list of defined terms.

## Supported cards

This guide supports the following production Alveo cards

* U50
* U50LV
* U200
* U250
* U280

## Issue area
Use the following table to narrow down the issue area.  


| Issue Area      | Items Covered |
| ----------- | ----------- |
| [Card Install](docs/card-install.md)   |Recommended process for card installation<ul><li>Available user guides</li><li>Common issues</li></ul>|
|[Card Validation](docs/card-validation.md)   |Common issues encountered while running `xbutil validate`|
|[Modifying XRT/Platform](docs/modifying-xrt-platform.md)  |Recommended XRT and platform installation procedures<ul><li>Upgrading XRT or a platform   </li><li>Downgrading XRT or a platform </li><li>Uninstalling XRT </ul></li>|
| [Card Not Recognized](docs/card-not-recognized.md)  |Common issues with BIOS, OS and `lspci` card recognition<ul><li>System does not recognize card          </li><li>BIOS settings                    </li><li>Usage of USB cable               </li>LED status</li></ul>|
| [Package Manager](docs/package-manager.md)   |Package manager install issues covering:<ul><li>yum/apt                               </li><li>rpms/debs                             </li><li>pyopencl                              </li><li>Package manager install dependencies  </li></ul>|
| [XRT Troubleshooting](docs/xrt-troubleshooting.md)  |Common XRT issues<ul><li>XRT drivers not recognizing the card</li></ul>|
|[SC Troubleshooting](docs/sc-troubleshooting.md)   |Common Satellite Controller issues<ul><li>Bad XMC error                                                   </li><li>`xbgmgmt flash --scan` reporting SC version mismatches   </li><li>`xbutil query` showing zero voltage or temperature                   </li><li>SC reporting UNKNOWN or INACTIVE                                        </li></ul>|
|[Application Crash](docs/application-crash.md) |Steps to determine if HW is causing an application crash|
|[Power Delivery](docs/power-delivery.md)   |Confirmation that hardware (server and card) can work together for heavy acceleration|
| [Common Steps](docs/common-steps.md)     | Reference procedures for all debugging sections 						<ul><li> Sudo and root access</li><li>System details including OS release, PCIe and CPU status</li><li>XRT compatibility</li><li>Determining platform and SC on card and system</li><li>Monitoring card power and temperature</li></ul>|

## Xilinx Support

For additional support resources such as Answers, Documentation, Downloads, and Alerts, see the [Xilinx Support pages](http://www.xilinx.com/support). For additional assistance, post your question on the Xilinx Community Forums – [Alveo Accelerator Card](https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo).

## License

All software including scripts in this distribution are licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

All images and documentation, including all debug and support documentation, are licensed under the Creative Commons (CC) Attribution 4.0 International License (the "CC-BY-4.0 License"); you may not use this file except in compliance with the CC-BY-4.0 License.

You may obtain a copy of the CC-BY-4.0 License at
[https://creativecommons.org/licenses/by/4.0/]( https://creativecommons.org/licenses/by/4.0/)


Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

<p align="center"><sup>XD027 | &copy; Copyright 2021 Xilinx, Inc.</sup></p>
