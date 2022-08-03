FRU Common Header
-----------------

The common header section is mandatory for all Alveo™ Products. This section holds version information for the overall format specification, including offsets to the other area, as shown in the following table. The other areas can be present based on the application of the device. An area is inferred as *null* or *not present* when the common header has a value of 00h for the starting offset of that area.

*Table :* **Common Header**

+---------------+--------------------------+---------------+---------------+--------------------------------+
| **Byte**      | **Field Description**    | **Size**      | **Byte**      |     **Notes**                  |
| **Address**   |                          | **(bytes)**   | **Address**   |                                |
+===============+==========================+===============+===============+================================+
| 0             | Common Header            | 1             | 0x01          | Version number =0x01           |
|               | Format version           |               |               |                                |
+---------------+--------------------------+---------------+---------------+--------------------------------+
| 1             | Internal user area       | 1             | 0x00          | Not present                    |
+---------------+--------------------------+---------------+---------------+--------------------------------+
| 2             | Chassis information area | 1             | 0x00          | Not present                    |
+---------------+--------------------------+---------------+---------------+--------------------------------+
| 3             | Board information area   | 1             | 0x01          | Starting offset: 8;            |
|               |                          |               |               |                                |
|               |                          |               |               | offset in multiples of 8 bytes |
+---------------+--------------------------+---------------+---------------+--------------------------------+
| 4             | Product information area | 1             | 0x09          | Starting offset: 72;           |
|               |                          |               |               |                                |
|               |                          |               |               | offset in multiples of 8 bytes |
+---------------+--------------------------+---------------+---------------+--------------------------------+
| 5             | Multi-record area        | 1             | 0x12          | Starting offset: 144;          |
|               |                          |               |               |                                |
|               |                          |               |               | offset in multiples of 8 bytes |
+---------------+--------------------------+---------------+---------------+--------------------------------+
| 6             | Reserved                 | 1             | 0x00          |                                |
+---------------+--------------------------+---------------+---------------+--------------------------------+
| 7             | Common header checksum   | 1             | 0xE3          |                                |
+---------------+--------------------------+---------------+---------------+--------------------------------+


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

