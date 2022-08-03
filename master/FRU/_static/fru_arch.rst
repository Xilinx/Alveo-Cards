Alveo™ FRU Architecture
-----------------------

The satellite controller firmware supports FRU data via a dedicated I2C slave address 0x50 (0xA0 in 8-bit). Alveo™ FRU implementation is fully compliant with `Intelligent Platform Management Interface (IPMI) FRU Specification v1.0 r1.3 <https://www.intel.com/content/dam/www/public/us/en/documents/specification-updates/ipmi-platform-mgt-fru-info-storage-def-v1-0-rev-1-3-spec-update.pdf>`__.

***Note*:** Only 2-byte FRU addressing is supported in Alveo™ FRU data. 1-byte (8-bit) FRU read requests are unsupported and will be responded with 0xFF.

Detailed FRU retrieval information and command usage are captured in `Alveo™ Card Management Specification
<https://xilinx.github.io/Alveo-Cards/master/management-specification/alveo-fru.html>`__.

**Byte Ordering (Endianness)**

All multi-byte fields represented in this document are little-endian, unless otherwise noted.


**FRU Storage Organization**

The following table details the layout and storage organization of
EEPROM contents. This scheme takes into consideration variable
lengths and future changes (i.e., expansion, reduction, and removal)
associated with each section. The common header section specifies
the variable length of each region. If necessary, a FRU data
management entity can change the allocations from their initial
values.

**Xilinx Field Replaceable Unit Architecture**

*Table:* **Recommended for 1 Kb (or more) EEPROM Organization**

+--------------------------------+------------+---------------------------------------------------------------+
| **FRU Area**                   | **Size**   | **Description**                                               |
+================================+============+===============================================================+
|  Common header                 | 8 bytes    | This is a mandatory section for all Xilinx accelerator        |
|                                |            |                                                               |
|                                |            | board implementations. It holds FRU specification             |  
|                                |            |                                                               |
|                                |            | version information and offsets to other areas.               |
+--------------------------------+------------+---------------------------------------------------------------+
| Board information area         | 64 bytes   | This area provides general FRU information (serial            |
|                                |            |                                                               |
|                                |            | number, part number, manufacturer information,                |
|                                |            |                                                               |
|                                |            | manufacturing date, etc.) about the board.                    |
+--------------------------------+------------+---------------------------------------------------------------+
| Product information area       | 72 bytes   | This area provides general FRU information (serial            |
|                                |            |                                                               |
|                                |            | number, part number, and manufacturer                         |
|                                |            |                                                               |
|                                |            | information). The contents from this section will be          |
|                                |            |                                                               |
|                                |            | used by server BMC to display in GUI or CLI.                  |
+--------------------------------+------------+---------------------------------------------------------------+
|     Multi-record area          |            | This region is OEM implementation specific.                   |
+--------------------------------+------------+---------------------------------------------------------------+
|     Record 1                   | x bytes    |                                                               |
+--------------------------------+------------+---------------------------------------------------------------+
|     Record 2                   | x bytes    |                                                               |
+--------------------------------+------------+---------------------------------------------------------------+
|     ...                        | x bytes    |                                                               |
+--------------------------------+------------+---------------------------------------------------------------+
|     Record n                   | x bytes    |                                                               |
+--------------------------------+------------+---------------------------------------------------------------+

**Xilinx Support**

For support resources such as answers, documentation, downloads, and forums, see the `Alveo Accelerator Cards Xilinx Community Forum <https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo>`_.

**License**

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at
`http://www.apache.org/licenses/LICENSE-2.0 <http://www.apache.org/licenses/LICENSE-2.0>`_

All images and documentation, including all debug and support documentation, are licensed under the Creative Commons (CC) Attribution 4.0 International License (the "CC-BY-4.0 License"); you may not use this file except in compliance with the CC-BY-4.0 License.

You may obtain a copy of the CC-BY-4.0 License at
`https://creativecommons.org/licenses/by/4.0/ <https://creativecommons.org/licenses/by/4.0/>`_

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.


.. raw:: html

	<p align="center"><sup>XD059 | &copy; Copyright 2021 Xilinx, Inc.</sup></p>
