﻿<table class="sphinxhide">
 <tr>
   <td align="center"><img src="https://www.xilinx.com/content/dam/xilinx/imgs/press/media-kits/corporate/xilinx-logo.png" width="30%"/><h1>Alveo Debug Guide</h1>
   </td>
 </tr>
</table>

# Card Installation

  This page will help guide your installation of one or more Alveo™ cards into a host server or workstation for a Vitis™ flow.  In addition, it covers various use cases.  If you are just starting to debug, please consult the [main page](../README.md) to determine if this is the best page for your purposes.

## Card Installation Guides

For Alveo card and software installation, follow the procedures outlined in the respective installation guide outlined in the table below.  For additional card details see the [Alveo landing page](https://www.xilinx.com/products/boards-and-kits/alveo.html).

| Card | Installation guide                                                                                                                                                                                                     |
| ---- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| U50  | [Alveo U50 Data Center Accelerator Card Installation Guide v1.7 (UG1370)]( https://www.xilinx.com/support/documentation/boards_and_kits/accelerator-cards/1_7/ug1370-u50-installation.pdf)                                   |
| U200 | [Getting Started with Alveo Data Center Acceleration Cards v1.7 (UG1301)](https://www.xilinx.com/support/documentation/boards_and_kits/accelerator-cards/1_7/ug1301-getting-started-guide-alveo-accelerator-cards.pdf)                             |
| U250 | [Getting Started with Alveo Data Center Acceleration Cards v1.7 (UG1301)](https://www.xilinx.com/support/documentation/boards_and_kits/accelerator-cards/1_7/ug1301-getting-started-guide-alveo-accelerator-cards.pdf)                             |
| U280 | [Getting Started with Alveo Data Center Acceleration Cards v1.5 (UG1301)](https://www.xilinx.com/support/documentation/boards_and_kits/accelerator-cards/1_5/ug1301-getting-started-guide-alveo-accelerator-cards.pdf) |


## You Will Need

For card installation, you will need to:
- Have [Root/sudo permissions](common-steps.md#root-sudo-access)
- Confirm [System compatibility](check-system-compatibility.md)
- Confirm proper airflow, these requirements are located in the respective Alveo Data Sheets from the [Alveo landing page](https://www.xilinx.com/products/boards-and-kits/alveo.html)

## Common Cases
- - -
### Installing a passive card into a workstation
- This is not supported.
- Passive cards are only supported in servers.

**WARNING:** Workstations do not provide enough airflow to cool passive cards. It is easy to damage passive cards in a workstation.

- - -
###  Card used in Vivado flow

- This debug guide is for Vitis flow only.
- See the [Alveo-Vivado page](https://www.xilinx.com/member/alveo-vivado.html) for Vivado™ related content.

- - -
### Error message during install

* Resolve by noting the error and:
  * Checking the [Package manager](package-manager.md) section
  * Searching the [Xilinx forums](https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo) for a similar issue

- - -
### PCIe slot provides <75W power

*  This configuration is not tested by Xilinx. This is not supported.

- - -
### Card requires PCIe AUX power but not supplied by the host

* This configuration is not tested by Xilinx. This is not supported.

- - -
### More cards than in-spec slots

 * Limit the number of cards you will install.

- - -
### Card operates for a while, then shuts down

 * Ensure adequate air flow.  
 * For operating conditions, including airflow requirements, reference the respective Alveo Data Sheets within the [Alveo landing page](https://www.xilinx.com/products/boards-and-kits/alveo.html).

 - - -

### Xilinx Support

For additional support resources such as Answers, Documentation, Downloads, and Alerts, see the [Xilinx Support pages](http://www.xilinx.com/support). For additional assistance, post your question on the Xilinx Community Forums – [Alveo Accelerator Card](https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo).

### License

All software including scripts in this distribution are licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

All images and documentation, including all debug and support documentation, are licensed under the Creative Commons (CC) Attribution 4.0 International License (the "CC-BY-4.0 License"); you may not use this file except in compliance with the CC-BY-4.0 License.

You may obtain a copy of the CC-BY-4.0 License at
[https://creativecommons.org/licenses/by/4.0/]( https://creativecommons.org/licenses/by/4.0/)


Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

<p align="center"><sup>XD027 | &copy; Copyright 2021 Xilinx, Inc.</sup></p>