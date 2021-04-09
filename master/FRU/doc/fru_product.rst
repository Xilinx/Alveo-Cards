FRU Product Info
----------------

**Product Information Area**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This section describes the production information FRU data that is
stored in this region, as detailed in the following table.

*Table :* **Product Information Area**

+-------------+-----------------------+-------------+--------------------------+----------------+
| **Byte**    | **Field Description** | **Size**    | **Format**               | **Default**    |
| **Address** |                       | **(bytes)** |                          | **Value**      |
+=============+=======================+=============+==========================+================+
| 72          | Product information   | 1           | Binary; version 1.0      | 0x01           |
|             |                       |             |                          |                |
|             | area format version   |             |                          |                | 
|             |                       |             |                          |                |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 73          | Product information   | 1           | Binary; 72 bytes         | 0x09           |
|             |                       |             |                          |                |
|             | area length           |             |                          |                |
|             |                       |             |                          |                |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 74          | Language code         | 1           | Binary                   | 0x00           |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 75          | Manufacturer name     | 1           | 8-bit ASCII & Length: 6  | 0xC6           |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 76          | Manufacturer name     | 6           | ASCII                    | 0x58 0x49 0x4C |
|             |                       |             |                          |                |
|             |                       |             |                          | 0x49 0x4E 0x58 |
|             |                       |             |                          |                |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 82          | Product name          | 1           | 8-bit ASCII & Length: 16 | 0xD0           |
|             |                       |             |                          |                |
|             | type/length byte      |             |                          |                |
|             |                       |             |                          |                |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 83          | Product name          | 16          | ASCII                    | TBD            |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 99          | Product part number   | 1           | 8-bit ASCII & Length: 9  | 0xC9           |
|             |                       |             |                          |                |
|             | type/length byte      |             |                          |                |
|             |                       |             |                          |                |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 100         | Product part number   | 9           | ASCII                    | TBD            |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 109         | Product version       | 1           | 8-bit ASCII & Length: 3  | 0xC8           |
|             |                       |             |                          |                |
|             | type/length byte      |             |                          |                |
|             |                       |             |                          |                |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 110         | Product version       | 8           | ASCII                    | TBD            |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 118         | Product serial number | 1           | 8-bit ASCII & Length: 14 | 0xCE           |
|             |                       |             |                          |                |
|             | type/length byte      |             |                          |                |
|             |                       |             |                          |                |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 119         | Product serial number | 14          | ASCII                    | TBD            |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 133         | Asset tag             | 1           | N/A                      | 0x0            | 
|             |                       |             |                          |                |
|             | type/length byte      |             |                          |                |
|             |                       |             |                          |                |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 134         | Asset tag             | 0           | N/A                      | N/A            |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 134         | FRU file ID           | 1           | Binary & Length: 1       | 0x01           |
|             |                       |             |                          |                |
|             | type/length byte      |             |                          |                |
|             |                       |             |                          |                |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 135         | FRU file ID           | 1           | Binary                   | 0x00           |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 136         | End of fields         | 1           | Binary                   | 0xC1           |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 137         | Pad                   | 6           | Binary                   | 0x00 0x00 0x00 |
|             |                       |             |                          |                |
|             |                       |             |                          | 0x00 0x00 0x00 |
|             |                       |             |                          |                |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 143         | Product information   | 1           | Binary                   | TBD            |
|             |                       |             |                          |                |       
|             | area checksum         |             |                          |                |       
|             |                       |             |                          |                |
+-------------+-----------------------+-------------+--------------------------+----------------+

**Product Information Area Format Version**

*Table:* **Product Information Area Format Version**

+----------+-------------------------------------------------------------------------------------+
| **Bits** |     **Meaning**                                                                     |
+==========+=====================================================================================+
| 7:4      | Reserved                                                                            |
+----------+-------------------------------------------------------------------------------------+
| 3:0      | Format version number, 0001b for IPMI FRU Spec. The value for this field is 0x01.   |
+----------+-------------------------------------------------------------------------------------+


**Product Information Area Length**

**Note:** This field is denoted in multiples of 8.

The elements of the product information area are padded up to the
nearest 8-byte boundary (using absolute offsets). The default pad
value is 0x0. The total length of the board information area is in
8-byte units.

Example Content: 0Eh x 8 byte = 72 bytes

**Language Code**

Default value 00h indicates that the language code is English and
all fields encoded as an 11b type are specified in single-byte ASCII
format.

**Note:** For a detailed list of available language codes, refer
to the `IPMI FRU Specification <https://www.intel.com/content/dam/www/public/us/en/documents/specification-updates/ipmi-platform-mgt-fru-info-storage-def-v1-0-rev-1-3-spec-update.pdf>`__

Example Content: 0x00 indicates English

**Manufacturer Name**

The value for this field is Xilinx encoded in 8-bit ACSII + Latin 1.
The values for this field are 0x58, 0x49, 0x4C, 0x49, 0x4E, and
0x58.

**Manufacturer Type/Length Byte**

This value defines the type and length of the board manufacturer
field. See :ref:`Appendix A` for information on the IPMI defined type/length byte format. The fixed
value for this field is 0xC6, which is decoded as 8-bit ASCII +
Latin , and 6 bytes long.

**Product Name**

The ASCII character value consists of the variable-length product
name (maximum length is 16 bytes). The product name is programmed at
the time of manufacturing. This value is static for a given board.
If the value is less than the chosen board product name length, the
remaining/ trailing bytes will occupy empty spaces.

**Product Name Type/Length Byte**

This value defines the type and length of the product name field.
See :ref:`Appendix A` for information on the IPMI defined type/length byte format. The fixed value for this field
is 0xD0, which is decoded as 8-bit ASCII + Latin 1, and 16 bytes
long.

**Product Part Number**

The ASCII character value consists of the variable-length part
number (maximum length is 9 bytes). The part number is programmed at
the time of manufacturing. This value is static for a given board.
If the value is less than the chosen board part number length the
remaining bytes are filled with 0x00.

**Product Part Number Type/Length Byte**

This value defines the type and length of the part number field. 
See :ref:`Appendix A` for information on the IPMI defined type/length byte format. The fixed value for this field is 0xC9, which is decoded as 8-bit ASCII + Latin 1, and 9 bytes long.

**Product Version**

The ASCII character value consists of the variable-length board
revision number (maximum length is 8 bytes). The revision number is
programmed at the time of manufacturing. This value is static for a
given board. If the value is less than the chosen board revision
number length, any remaining/trailing bytes will occupy empty
spaces.

**Product Version Type/Length Byte**

This value defines the type and length of the board revision number
field. See :ref:`Appendix A` for information on the IPMI defined type/length byte format. The fixed
value for this field is 0xC8, which is decoded as 8-bit ASCII +
Latin 1, and 8 bytes long.

**Product Serial Number**

The ASCII character value consists of the variable-length serial
number (maximum length is 14 bytes). The serial number is programmed
at the time of manufacturing. This value is static for a given
board. If the value is less than the chosen board serial number
length, the remaining/ trailing bytes will occupy empty spaces.

**Product Serial Number Type/Length Byte**

This value defines the type and length of the board serial number
field. See :ref:`Appendix A` for information on the IPMI defined type/length byte format. The fixed
value for this field is 0xCE, which is decoded as 8-bit ASCII +
Latin 1, and 14 bytes long.

**Asset Tag**

The asset tag is N/A for Alveo cards.

**Asset Tag Type/Length Byte**

This field is will be set to 0x0.

**FRU File ID**

This field is used to indicate the version of the binary data used
to program the FRU storage device. It is intended to aid with FRU
file data identification and its use is optional. Non-00h and
non-FFh content indicates that this field is being used for FRU file
version identification.

-  0x00: This field is unused for version identification

-  0x01: Version 1 of FRU data

-  0x02: Version 2 of FRU data

-  0xnn: Version nn of FRU data

-  0xFF: This field is used for version identification

The Xilinx fixed value for this field is 0x00.

**FRU File ID Type/Length Byte**

This value defines the type and length of the FRU file ID field. 
See :ref:`Appendix A` for information on the IPMI
defined type/length byte format. The fixed value for this field is
0x01, which is decoded as binary data, and 1 byte long.

**End of Fields**

The value for this field is 0xC1.

**Pad**

Pad with 0x00 until the board information area ends on an 8-byte
boundary (relative to absolute offsets).

**Product Information Area Checksum**

See :ref:`Appendix A` for guidance.


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

