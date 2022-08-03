FRU Multi Records 
-----------------

**Multi-Record Area**
~~~~~~~~~~~~~~~~~~~~~

This section describes the how Xilinx specific data as well as
server OEM specific data is represented. While all FRU data is
exposed via I2C raw commands, some of the Multi-Records(MR) are reserved
for Xilinx or for server OEM. Not all records in this multi-record
area are relevant to every server OEM where an Alveo card is
supported/qualified.

**Table: Multi-Record (MR) Type**

+-------------------+-----------------------------------------------------------+
| **Record ID**     | **Record Type**                                           |
+===================+===========================================================+
| 0x00 – 0x0F       | IPMI specific  - Refer IPMI FRU Spec                      |
+-------------------+-----------------------------------------------------------+
| 0x10 – 0xBF       | Reserved                                                  |
+-------------------+-----------------------------------------------------------+
| 0xC0 – 0xCF       | Reserved                                                  |
+-------------------+-----------------------------------------------------------+
| 0xD0              | Alveo card thermal information                            |
+-------------------+-----------------------------------------------------------+
| 0xD1              | Alveo card power information                              |
+-------------------+-----------------------------------------------------------+
| 0xD2              | Xilinx Alveo card information                             |
+-------------------+-----------------------------------------------------------+
| 0xD3 - 0xDF       | Xilinx reserved                                           |
+-------------------+-----------------------------------------------------------+
| 0xE0 - 0xFF       | OEM Reserved                                              |
+-------------------+-----------------------------------------------------------+

**Multi-Record (MR) Information**

This field enables the software to determine record form at version.
Refer to the `IPMI FRU Specification <https://www.intel.com/content/dam/www/public/us/en/documents/specification-updates/ipmi-platform-mgt-fru-info-storage-def-v1-0-rev-1-3-spec-update.pdf>`__,
section 6.1.2 for additional information. The bits are defined in the following table.

**Table: Multi-Record Information**

+-----------+------------------------------------------+
| **Bits**  | **Description**                          |
+===========+==========================================+
| Bits 7:7  | End of List                              |
+-----------+------------------------------------------+
| Bits 6:4  | Reserved, 000b                           |
+-----------+------------------------------------------+
| Bits 3:0  | Record Format Version                    |
|           |                                          |
|           | 0x02 for IPMI FRU v1.0; 0x00 otherwise   |
+-----------+------------------------------------------+

**Multi-Record (MR) Checksum**

**Record Checksum**

The record checksum covers byte positions after the header
(following offset 0x04). This value must be calculated before the
record header checksum. In the following example, the bytes 0x05 to
0x09 are used to calculate the record checksum.

**Record Header Checksum**

The checksum covers byte positions 0x00 to 0x03. This value must be
calculated after the record checksum and updated at byte offset
0x04.

**Table: Record and Record Header Checksum Example**

+-----------------+---------------------------------+------------------+-----------------------------+
| **Byte Offset** | **Field Description**           | **Size (bytes)** | **Sample Value**            |
+=================+=================================+==================+=============================+
| 0               | Record type (multi-record area) | 1                | 0xD0 (Xilinx Thermal Info)  |
+-----------------+---------------------------------+------------------+-----------------------------+
| 1               | Record information              | 1                | 0x02 (multi-record area)    |
+-----------------+---------------------------------+------------------+-----------------------------+
| 2               | Record length                   | 1                | 0x05                        |
+-----------------+---------------------------------+------------------+-----------------------------+
| 3               | Record checksum                 | 1                | 0xA6                        |
+-----------------+---------------------------------+------------------+-----------------------------+
| 4               | Record header checksum          | 1                | 0x93                        |
+-----------------+---------------------------------+------------------+-----------------------------+
| 5               | Data                            | 1                | 0x01                        |
+-----------------+---------------------------------+------------------+-----------------------------+
| 6               | Data                            | 1                | 0x02                        |
+-----------------+---------------------------------+------------------+-----------------------------+
| 7               | Data                            | 1                | 0xF0                        |
+-----------------+---------------------------------+------------------+-----------------------------+
| 8               | Data                            | 1                | 0xAA                        |
+-----------------+---------------------------------+------------------+-----------------------------+
| 9               | Data                            | 1                | 0xBD                        |
+-----------------+---------------------------------+------------------+-----------------------------+

**Multi-Record AreLayout**

**Table: Multi-Record Area Layout**

+------------------------------+----------------------+------------+-------------------+--------------------+
| **Field Description**        |     **Size (bytes)** | **Format** | **Default Value** | **Comment**        |
+==============================+======================+============+===================+====================+
| Xilinx multi-record header   | 9                    | Binary     | 0x00              | Xilinx OEM thermal |
|                              |                      |            |                   |                    |
|                              |                      |            |                   | information        |
+------------------------------+----------------------+------------+-------------------+--------------------+
| Record                       | 21                   | Binary     | 0x00              | TBD                |
+------------------------------+----------------------+------------+-------------------+--------------------+
| Xilinx multi-record header   | 9                    | Binary     | 0x00              | Xilinx OEM power   |
|                              |                      |            |                   |                    |
|                              |                      |            |                   | information        |
+------------------------------+----------------------+------------+-------------------+--------------------+
| Record                       | 11                   | Binary     | 0x00              | TBD                |
+------------------------------+----------------------+------------+-------------------+--------------------+
| Xilinx multi-record header   | 9                    | Binary     | 0x00              | OEM reserved       |
+------------------------------+----------------------+------------+-------------------+--------------------+
| Record                       | 21                   | Binary     | 0x00              | TBD                |
+------------------------------+----------------------+------------+-------------------+--------------------+
| Xilinx multi-record header   | 9                    | Binary     | 0x00              | OEM reserved       |
+------------------------------+----------------------+------------+-------------------+--------------------+
| Record                       | 11                   | Binary     | 0x00              | TBD                |
+------------------------------+----------------------+------------+-------------------+--------------------+
| Xilinx multi-record header   | 9                    | Binary     | 0x00              | OEM reserved       |
|                              |                      |            |                   |                    |
|                              |                      |            |                   | (end of records)   |
+------------------------------+----------------------+------------+-------------------+--------------------+
| Record                       | 6                    | Binary     | 0x00              | TBD                |
+------------------------------+----------------------+------------+-------------------+--------------------+


**Xilinx Multi-Record Header**

The multi-area record header is defined by the IPMI specification
(byte address 0-4). The OEM specific information can be derived from
the 3-byte manufacturer identification field and the 1-byte version
number field (byte address 5 and 8). The IPMI header along with the
two additional fields (manufacturing ID and version number) are
called Xilinx header for the multi-record area, which is nine bytes
long. All of the Xilinx multi-record area has this header to the
convenience of manufacturer identification. This helps server OEMs
to parse and make sense of data that is relevant to their server
platforms. Per the IPMI specification, the total length of record is
256.

**Table: Xilinx Multi-Record Header**

+-------------+------------------+-------------+------------+-------------+----------------------------+
| **Byte**    | **Field**        | **Size**    | **Format** | **Default** | **Notes**                  |
| **Address** | **Description**  | **(bytes)** |            | **Value**   |                            |
+=============+==================+=============+============+=============+============================+
| 0           | Record type      | 1           | Binary     | 0x00        | Refer MR Type table        |
+-------------+------------------+-------------+------------+-------------+----------------------------+
| 1           | Record info      | 1           | Binary     | 0x00        | Refer MR Info table        |
+-------------+------------------+-------------+------------+-------------+----------------------------+
| 2           | Record length    | 1           | Binary     | 0x00        |                            |
+-------------+------------------+-------------+------------+-------------+----------------------------+
| 3           | Record checksum  | 1           | Binary     | 0x00        | Refer MR checksum table    |
+-------------+------------------+-------------+------------+-------------+----------------------------+
| 4           | Header checksum  | 1           | Binary     | 0x00        | Refer MR checksum table    |
+-------------+------------------+-------------+------------+-------------+----------------------------+
| 5           | Manufacturer ID  | 3           | Binary     | 0xDA 0x10   | Xilinx IANA ID             |
|             |                  |             |            |             |                            |
|             |                  |             |            | 0x00        |                            |
+-------------+------------------+-------------+------------+-------------+----------------------------+
| 8           | Version number   | 1           | Binary     | 0x01        |                            |
+-------------+------------------+-------------+------------+-------------+----------------------------+

**Record Type**

This unsigned byte is used to identify the information contained in
the record. Refer to Multi-Record Information table.

**Record Information**

Refer to Multi-Record Information table

**End of List**

This bit indicates whether or not this is the last record in the
multi-record area. If this bit is zero, it indicates that one or
more records follow.

**Record Format Version**

The area version format is stored in the lower nibble of the second
byte. This field is used to identify the revision level of
information stored in this area. This number starts at zero for each
new area. If changes need to be made to the record (e.g., fields
added/removed) the version number should be increased to reflect the
change. Unless otherwise noted, the record format version for all
record types is 02h for this specification, including OEM record
types. The latter provision is to provide for standardized data
fields that precede the OEM specific data within the OEM record.

**Record Length**

This unsigned byte indicates the number of bytes of data in the
record. This byte can also be used to find the next area in the
list. If the end of list bit is zero, the length can be added to the
starting offset of the current record data to get the offset of the
next record header. This field allows for 0 to 255 bytes of data for
each record.

**Version Number**

For Xilinx OEM multi-records, the version number is 0x01.

**Manufacturer ID**

The manufacturer ID field correlates multi-record information to a
specific OEM. For Xilinx, the manufacturer ID is 4314 (0x10DA). Per
the IPMI specification, this field is three bytes in long. For
Xilinx specific multi-records, the full manufacturer ID, in LSB
first, is 0xDA 0x10 0x00.

**Note:** Look up the manufacturer ID in the following web-page.
The Manufacturer ID is a 20-bit value derived from the IANA Private
Enterprise ID.

https://www.iana.org/assignments/enterprise-numbers/enterprise-numbers


**Xilinx OEM Record — Thermal**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

**Table: Xilinx Thermal Information Record**

+------------+------------------------+-------------+-----------------------+---------------------------+
| **Byte**   | **Field**              | **Size**    | **Format**            | **Default**               |
| **Offset** | **Description**        | **(bytes)** |                       | **Value**                 |
+============+========================+=============+=======================+===========================+
| 0          | Record type            | 1           | Xilinx Thermal Info   | 0xD0                      |
+------------+------------------------+-------------+-----------------------+---------------------------+
| 1          | Record info            | 1           | MR area               | 0x02                      |
+------------+------------------------+-------------+-----------------------+---------------------------+
| 2          | Record length          | 1           | Binary; Excluding pad | 0x19 (25 bytes)           |
+------------+------------------------+-------------+-----------------------+---------------------------+
| 3          | Record checksum        | 1           | Binary                | TBD                       |
+------------+------------------------+-------------+-----------------------+---------------------------+
| 4          | Record header checksum | 1           | Binary                | TBD                       |
+------------+------------------------+-------------+-----------------------+---------------------------+
| 5          | Manufacturer ID        | 3           | Binary                | 0xDA 0x10 0x00            |
+------------+------------------------+-------------+-----------------------+---------------------------+
| 8          | Version number         | 1           | Binary                | 0x01                      |
+------------+------------------------+-------------+-----------------------+---------------------------+
| 9          | Reserved               | 21          | Binary                | TBD                       |
+------------+------------------------+-------------+-----------------------+---------------------------+

**Record Type**

The record type IDor Xilinx OEM information is 0xD0.

**Record Information**

The record information is 0x02. Refer to Multi-Record Information table

**Length**

The length of Xilinx thermal record is 25 bytes, excluding 5 pad
bytes.

**Record Checksum**

Refer to Refer to Multi-Record Checksum table

**Record Header Checksum**

Refer to Refer to Multi-Record Checksum table

**Manufacturer ID**

For Xilinx, the manufacturer ID is 4314 (0x10DA). Per the IPMI
specification, where LSB is first, Xilinx manufacturer ID is 0xDA
0x10 0x00.

**Version Number**

The Xilinx record version is 0x01.

**Reserved**

The values in these bytes are reserved and might not default to 0x00.

**Xilinx OEM Record — Power**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Table: Xilinx Power Information Record**

+------------+------------------------+-------------+-----------------------+---------------------------+
| **Byte**   | **Field**              | **Size**    | **Format**            | **Default**               |
| **Offset** | **Description**        | **(bytes)** |                       | **Value**                 |
+============+========================+=============+=======================+===========================+
| 0          | Record type            | 1           | Xilinx Power Info     | 0xD1                      |
+------------+------------------------+-------------+-----------------------+---------------------------+
| 1          | Record info            | 1           | MR area               | 0x02                      |
+------------+------------------------+-------------+-----------------------+---------------------------+
| 2          | Record length          | 1           | Binary; Excluding pad | 0x10 (18 bytes)           |
+------------+------------------------+-------------+-----------------------+---------------------------+
| 3          | Record checksum        | 1           | Binary                | TBD                       |
+------------+------------------------+-------------+-----------------------+---------------------------+
| 4          | Record header checksum | 1           | Binary                | TBD                       |
+------------+------------------------+-------------+-----------------------+---------------------------+
| 5          | Manufacturer ID        | 3           | Binary                | 0xDA 0x10 0x00            |
+------------+------------------------+-------------+-----------------------+---------------------------+
| 8          | Version number         | 1           | Binary                | 0x01                      |
+------------+------------------------+-------------+-----------------------+---------------------------+
| 9          | Reserved               | 21          | Binary                | TBD                       |
+------------+------------------------+-------------+-----------------------+---------------------------+

**Record Type**

Record Type ID for Xilinx OEM Information is 0xD1.

**Record Information**

Record information is 0x02. Refer OEM Reserved Multi-Records table for more info

**Record Length**

The length of Xilinx thermal record is 25 bytes, excluding five pad
bytes.

**Checksum**

Refer to Refer to Multi-Record Checksum table

**Record Header Checksum**

Refer to Refer to Multi-Record Checksum table

**Manufacturer ID**

The Xilinx manufacturer ID is 4314 (0x10DA). Per IPMI specification,
in LSB first, the Xilinx manufacturer ID is 0xDA 0x10 0x00.

**Version Number**

Xilinx record version is 0x01.

**Reserved**

The values in these bytes are TBD and might not default to 0x00.

**Xilinx OEM Record — Board**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Table: Xilinx Board Information Record**

+------------+------------------------+-------------+-----------------------+---------------------------+
| **Byte**   | **Field**              | **Size**    | **Format**            | **Default**               |
| **Offset** | **Description**        | **(bytes)** |                       | **Value**                 |
+============+========================+=============+=======================+===========================+
| 0          | Record type            | 1           | Xilinx Board Info     | 0xD2                      |
+------------+------------------------+-------------+-----------------------+---------------------------+
| 1          | Record info            | 1           | MR area               | 0x02                      |
+------------+------------------------+-------------+-----------------------+---------------------------+
| 2          | Record length          | 1           | Binary; Excluding pad | 0x50 (80 bytes)           |
+------------+------------------------+-------------+-----------------------+---------------------------+
| 3          | Record checksum        | 1           | Binary                | TBD                       |
+------------+------------------------+-------------+-----------------------+---------------------------+
| 4          | Record header checksum | 1           | Binary                | TBD                       |
+------------+------------------------+-------------+-----------------------+---------------------------+
| 5          | Manufacturer ID        | 3           | Binary                | 0xDA 0x10 0x00            |
+------------+------------------------+-------------+-----------------------+---------------------------+
| 8          | Version number         | 1           | Binary                | 0x01                      |
+------------+------------------------+-------------+-----------------------+---------------------------+
| 9          | Reserved               | 80          | Binary                | TBD                       |
+------------+------------------------+-------------+-----------------------+---------------------------+

**Record Type**

Record Type ID for Xilinx OEM Information is 0xD2.

**Record Information**

Record information is 0x02. Refer OEM Reserved Multi-Records table for more info

**Record Length**

The length of Xilinx thermal record is 25 bytes, excluding five pad
bytes.

**Checksum**

Refer to Refer to Multi-Record Checksum table

**Record Header Checksum**

Refer to Refer to Multi-Record Checksum table

**Manufacturer ID**

The Xilinx manufacturer ID is 4314 (0x10DA). Per IPMI specification,
in LSB first, the Xilinx manufacturer ID is 0xDA 0x10 0x00.

**Version Number**

Xilinx record version is 0x01.

**Reserved**

The values in these bytes are TBD and might not default to 0x00.

**OEM Reserved Multi-Records**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Per the `IPMI FRU Specification <https://www.intel.com/content/dam/www/public/us/en/documents/specification-updates/ipmi-platform-mgt-fru-info-storage-def-v1-0-rev-1-3-spec-update.pdf>`__,
multi-records can be OEM specific. The Alveo card FRU has three Xilinx specific (OEM) contents, as detailed in the following table.

**Table: OEM Reserved Multi-Records**

+-----------------------+-------------+------------+-------------+---------------------------------+
| **Field Description** | **Size**    | **Format** | **Default** | **Comment**                     |
|                       | **(bytes)** |            | **Value**   |                                 |
+=======================+=============+============+=============+=================================+
| Xilinx MR header      | 9           | Binary     | 0x00        | OEM reserved                    |
+-----------------------+-------------+------------+-------------+---------------------------------+
| Record data           | 21          | Binary     | 0x00        | TBD                             |
+-----------------------+-------------+------------+-------------+---------------------------------+
| Xilinx MR header      | 9           | Binary     | 0x00        | OEM reserved                    |
+-----------------------+-------------+------------+-------------+---------------------------------+
| Record data           | 11          | Binary     | 0x00        | TBD                             |
+-----------------------+-------------+------------+-------------+---------------------------------+
| Xilinx MR header      | 9           | Binary     | 0x00        | OEM reserved - (End of Records) |
+-----------------------+-------------+------------+-------------+---------------------------------+
| Record data           | 6           | Binary     | 0x00        | TBD                             |
+-----------------------+-------------+------------+-------------+---------------------------------+



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

