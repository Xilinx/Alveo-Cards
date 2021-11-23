<table class="sphinxhide">
 <tr>
   <td align="center"><img src="https://www.xilinx.com/content/dam/xilinx/imgs/press/media-kits/corporate/xilinx-logo.png" width="30%"/><h1>Alveo Debug Guide</h1>
   </td>
 </tr>
</table>

# Card Installation

  This page will help guide your installation of one or more Alveo™ cards into a host server or workstation for a Vitis™ flow.  In addition, it covers various use cases.  If you are just starting to debug, please consult the [main page](../README.md) to determine if this is the best page for your purposes.

## Card Installation Guides

Card installation consists of intalling the card into a server and software installation.  The installation steps for both are provided in the respective card installation guide.  Links to various guides are given in the table below.  The [Alveo landing page](https://www.xilinx.com/products/boards-and-kits/alveo.html) provides additional card details along with links to software installation downloads.

| Card | Installation guide                                                                                                                                                                                                     |
| ---- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| U50  | [Alveo U50 Data Center Accelerator Card Installation Guide (UG1370)]( https://www.xilinx.com/cgi-bin/docs/bkdoc?k=accelerator-cards;v=latest;d=ug1370-u50-installation.pdf)                                   |
| U55C  | [Alveo U55C Data Center Accelerator Card Installation Guide (UG1468)]( https://www.xilinx.com/cgi-bin/docs/bkdoc?k=accelerator-cards;v=latest;d=ug1468-u55c-installation.pdf)  AVAILALABLE DECEMBER 2021                                 |
| U200 | [Getting Started with Alveo Data Center Acceleration Cards (UG1301)](https://www.xilinx.com/cgi-bin/docs/bkdoc?k=accelerator-cards;v=latest;d=ug1301-getting-started-guide-alveo-accelerator-cards.pdf)                             |
| U250 | [Getting Started with Alveo Data Center Acceleration Cards (UG1301)](https://www.xilinx.com/cgi-bin/docs/bkdoc?k=accelerator-cards;v=latest;d=ug1301-getting-started-guide-alveo-accelerator-cards.pdf)                             |
| U280 | [Getting Started with Alveo Data Center Acceleration Cards (UG1301)](https://www.xilinx.com/cgi-bin/docs/bkdoc?k=accelerator-cards;v=latest;d=ug1301-getting-started-guide-alveo-accelerator-cards.pdf) |


## You Will Need

For card installation, you will need to:
- Have [Root/sudo permissions](common-steps.md#root-sudo-access)
- Confirm [System compatibility](check-system-compatibility.md)
- Confirm proper airflow requirements are met.  See the respective Alveo card Data Sheet from the [Alveo landing page](https://www.xilinx.com/products/boards-and-kits/alveo.html)

## Common Cases
- - -
### Installing a passive card into a workstation
- This is not supported.
- Passive cards are only supported in servers.

IMPORTANT: Since workstations do not provide enough airflow to cool passive cards, it is easy to damage passive cards in a workstation.

- - -
###  Card used in Vivado flow

- This guide only covers Vitis flow.
- Request access to the [Alveo-Vivado lounge](https://www.xilinx.com/member/alveo-vivado.html) for Vivado™ related content. 

- - -
### Error message during install

If you encounter an error during card installation, search the following sections for support
  * [Card not recognized](card-not-recognized.md) helps when card is not recognized by the host.
  * See [Package manager](package-manager.md) for issues while installing the `.deb` or `.rpm` installation packages
  * Search the [Xilinx forums](https://support.xilinx.com/s/topic/0TO2E000000YKXlWAO/alveo-accelerator-cards) for a similar issue

- - -
### PCIe slot provides <75W power

PCIe slots providing less than 75W of power are not tested by Xilinx. This is not supported.

- - -
### Card requires PCIe AUX power but not supplied by the host

This configuration is not tested by Xilinx. This is not supported.

- - -
### More cards than compatible PCIe slots

Each Alveo card is designed to be installed in a compatible PCIe slot. Slot requirements and card form factors are documented in each card's [installation guide](card-install.md#card-installation-guides). A host which is populated with more cards than compatible PCIe slots, as in the case of a PCIe expander, may cause issues with the host or card.  Xilinx recommends limiting the number of installed cards to match the number of compatible PCIe slots.
- - -
### Card operates for a while, then shuts down

 The card may be overheating and subsequently shutting down.  Ensure adequate air flow.  See [Card not recognized during operation](card-not-recognized.md#card-not-recognized-during-operation)
 * For operating conditions, including airflow requirements, reference the respective Alveo Data Sheets within the [Alveo landing page](https://www.xilinx.com/products/boards-and-kits/alveo.html).

 - - -

### Xilinx Support

For additional support resources such as Answers, Documentation, Downloads, and Alerts, see the [Xilinx Support pages](http://www.xilinx.com/support). For additional assistance, post your question on the Xilinx Community Forums – [Alveo Accelerator Cards](https://support.xilinx.com/s/topic/0TO2E000000YKXlWAO/alveo-accelerator-cards). 

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
