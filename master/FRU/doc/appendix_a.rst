Appendix A
----------

Checksum Calculation
~~~~~~~~~~~~~~~~~~~~

Checksum ranges are noted throughout this specification. These are
provided as a range of bytes to include within the checksum
calculation. These are not provided as a range for the resultant
checksum value.

Steps for calculating checksums:

1. Set checksum value to zero (0).

2. Perform a byte-wise sum of all other bytes within the specified range.

3. Subtract byte-wise sum from step 2 from zero (0).

4. Assign value from step 3 to checksum.

Checksum ranges that include the checksum itself assume a value of
zero or do not include the checksum in the range at all. Padded
ranges might include the pads. This does not affect the outcome of
the checksum calculation since the pad values themselves are
required to be 0x00.


Type/Length Byte Format
~~~~~~~~~~~~~~~~~~~~~~~

The following table presents the specification for the type/length
byte format as detailed in `IPMI Specification
v2.0 <https://www.intel.com/content/www/us/en/servers/ipmi/ipmi-second-gen-interface-spec-v2-rev1-1.html>`__,
at section 13 of the document.

*Table:* **Type/Length Format**

+--------------+------------------------------------------------------------------------------+
|     **Bits** |  **Meaning**                                                                 |
+--------------+------------------------------------------------------------------------------+
| 7:6          |  Type code                                                                   |
+--------------+------------------------------------------------------------------------------+
| 00…          |  Binary or unspecified                                                       |
+--------------+------------------------------------------------------------------------------+
| 01…          |  Binary-coded decimal plus                                                   |
+--------------+------------------------------------------------------------------------------+
| 10…          |  6-bit ASCII packed (overrides language codes)                               |
+--------------+------------------------------------------------------------------------------+
| 11…          |  Interpretation depends on language codes. 11b indicates 8-bit ASCII +       |
|              |                                                                              |
|              |  Latin 1 if the language code is English for the area or record containing   |
|              |                                                                              |
|              |  the field, or 2-byte UNICODE (least significant byte first) if the language |
|              |                                                                              |
|              |  code is not English. At least two bytes of data must be present when this   |
|              |                                                                              |
|              |  type is used. Therefore, the length (number of data bytes) will always be   |
|              |                                                                              |
|              |  >1 if data is present, 0 if data is not present.                            |
+--------------+------------------------------------------------------------------------------+
| 5:0          |  Number of data bytes                                                        |
|              |                                                                              |
|              |  000000 indicates that the field is empty. When the type code is 11b, a      |
|              |                                                                              |
|              |  length of 000001 indicates ‘end of fields, i.e., Type/Length = C1h          |
|              |                                                                              |
|              |  indicates end of fields.                                                    |
+--------------+------------------------------------------------------------------------------+

**ASCII+LATIN1** is derived from the first 256 characters of unicode
2.0. The first 256 codes of unicode follow ISO 646 (ASCII) and ISO
8859/1 (Latin 1). The Unicode *C0 Controls and Basic Latin* set
defines the first 128 8-bit characters (00h-7Fh), and the *C1
Controls and Latin-1 Supplement* defines the second 128 (80h-FFh).

**6-bit ASCII** is the 64 characters starting from character 20h
(space) from the ASCII+LATIN1 set. For example, 6- bit ASCII value
000000b maps to 20h (space), 000001b maps to 21h (!), etc.., 

Packed 6-bit ASCII takes the 6-bit characters and packs four characters to
every three bytes, with the first character in the least significant
six bits of the first byte.


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
