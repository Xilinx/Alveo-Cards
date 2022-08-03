FRU Board Info
--------------

**Board Information Area**
~~~~~~~~~~~~~~~~~~~~~~~~~~

This section describes the board information FRU data that is stored in this region, as detailed in the following table.

*Table:* **Board Information Area**

+-------------+-----------------------+-------------+--------------------------+----------------+
| **Byte**    | **Field Description** | **Size**    | **Format**               | **Default**    |
| **Address** |                       | **(bytes)** |                          | **Value**      |
+=============+=======================+=============+==========================+================+
| 8           | Board area format     | 1           | Binary;                  | 0x01           |
|             |                       |             |                          |                |
|             | version               |             | version 1.0              |                |
|             |                       |             |                          |                |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 9           | Board area length     | 1           | Binary; 64 bytes         | 0x08           |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 10          | Language code         | 1           | Binary                   | 0x00           |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 11          | Manufacturing         | 3           | Binary                   | 0x00 0x00 0x00 |
|             |                       |             |                          |                |
|             | date/time             |             |                          |                |
|             |                       |             |                          |                |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 14          | Board manufacturer    | 1           | 8-bit ASCII; Length: 6   | 0xC6           |
|             |                       |             |                          |                |
|             | type/length byte      |             |                          |                |
|             |                       |             |                          |                |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 15          | Board manufacturer    | 6           | ASCII                    | 0x58 0x49 0x4C |
|             |                       |             |                          |                |
|             |                       |             |                          | 0x49 0x4E 0x58 |
|             |                       |             |                          |                |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 21          | Board product name    | 1           | 8-bit ASCII; Length: 16  | 0xD0           |
|             |                       |             |                          |                |
|             | type/length byte      |             |                          |                |
|             |                       |             |                          |                |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 22          | Board product name    | 16          | ASCII                    | TBD            |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 38          | Board serial number   | 1           | 8-bit ASCII; Length: 14  | 0xCE           |
|             |                       |             |                          |                |
|             | type/length byte      |             |                          |                |
|             |                       |             |                          |                |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 39          | Board serial number   | 14          | ASCII                    | TBD            |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 53          | Board part number     | 1           | 8-bit ASCII; Length: 9   | 0xC9           |
|             |                       |             |                          |                |
|             | type/length byte      |             |                          |                |
|             |                       |             |                          |                |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 54          | Board part number     | 9           | ASCII                    | TBD            |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 63          | FRU file ID           | 1           | Binary; Length: 1        | 0x01           |
|             |                       |             |                          |                |
|             | type/length byte      |             |                          |                |
|             |                       |             |                          |                |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 64          | FRU file ID           | 1           | Binary                   | 0x00           |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 65          | End of fields         | 1           | Binary                   | 0xC1           |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 66          | Pad                   | 5           | Binary                   | 0x00 0x00 0x00 |
|             |                       |             |                          |                |
|             |                       |             |                          | 0x00 0x00      |
|             |                       |             |                          |                |
+-------------+-----------------------+-------------+--------------------------+----------------+
| 71          | Board info area       | 1           | Binary                   | TBD            |
|             |                       |             |                          |                |
|             | checksum              |             |                          |                |
|             |                       |             |                          |                |
+-------------+-----------------------+-------------+--------------------------+----------------+

**Board Area Format Version**

The following table describes the board area format version field.

*Table:* **Board Area Format Version**

+----------+-------------------------------------------------------------------------------------+
| **Bits** |     **Meaning**                                                                     |
+==========+=====================================================================================+
| 7:4      | Reserved                                                                            |
+----------+-------------------------------------------------------------------------------------+
| 3:0      | Format version number, 0001b for IPMI FRU Spec. The value for this field is 0x01.   |
+----------+-------------------------------------------------------------------------------------+

**Board Information Area Length**

**Note:** This field is denoted in multiples of 8.

The elements of the board information area are padded up to the
nearest 8-byte boundary (using absolute offsets). The default pad
value is 0x0. The total length of the board information area is in
8-byte units.

Example Content: 0Eh x 8 byte = 64 bytes

**Language Code**

Default value 00h indicates that the language code is English and
all fields encoded as an 11b type are specified in single-byte ASCII
format.

**Note:** For a detailed list of available language codes, refer
to the `IPMI FRU Specification <https://www.intel.com/content/dam/www/public/us/en/documents/specification-updates/ipmi-platform-mgt-fru-info-storage-def-v1-0-rev-1-3-spec-update.pdf>`__

Example Content: 0x00 indicates English

**Manufacturing Date and Time**

This value specifies the date and time that the board was
manufactured. This field value is the numeric value that is
calculated as the number of minutes from 0:00 hours on 1 January
1996 (1/1/96), and stored as the least-significant byte first (i.e., in
offset 03h). If the field is not specified, the default value is
000000h.

**Note:** There are 525950 minutes in a non-leap year or 527040
minutes in a leap year. This algorithm times out in the year 2028.

**Manufacturer Name**

The value for this field is Xilinx encoded in 8-bit ACSII + Latin 1.
The values for this field are 0x58, 0x49, 0x4C, 0x49, 0x4E, and
0x58.

**Manufacturer Type/Length Byte**

This value defines the type and length of the board manufacturer field. 
See :ref:`Appendix A` for information on the IPMI defined type/length byte format. The fixed
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

**Board Serial Number**

The ASCII character value consists of the variable-length serial
number (maximum length is 14 bytes). The serial number is programmed
at the time of manufacturing. This value is static for a given
board. If the value is less than the chosen board serial number
length, the remaining/ trailing bytes will occupy empty spaces.

**Board Serial Number Type/Length Byte**

This value defines the type and length of the board serial number
field. See :ref:`Appendix A` for information on the IPMI defined type/length byte format. The fixed
value for this field is 0xCE, which is decoded as 8-bit ASCII +
Latin 1, and 14 bytes long.

**Part Number**

The ASCII character value consists of the variable-length part
number (maximum length is 9 bytes). The part number is programmed at
the time of manufacturing. This value is static for a given board.
If the value is less than the chosen board part number length the
remaining bytes are filled with 0x00.

**Part Number Type/Length Byte**

This value defines the type and length of the part number field. 
See :ref:`Appendix A` for information on the IPMI defined type/length byte format. The fixed value for this field is 0xC9, which is decoded as 8-bit ASCII + Latin 1, and 9 bytes long.

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

**Board Area Checksum**

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

