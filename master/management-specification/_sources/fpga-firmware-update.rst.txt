FPGA Flash Update Commands
--------------------------

In the Alveo™ U30, the satellite controller (SC) supports an out-of-band method of FPGA flash image upgrade. Optionally, Server BMC shall initiate and perform the upgrade process by sending the I2C commands to the satellite controller firmware. The out-of-band FPGA FW update is supported at I2C address 0x65 (0xCA in 8-bit). Currently, Satellite Controller supports only 100 KHz I2C speed for all the FPGA flash update commands mentioned in this section. 

**Note:** The satellite controller will perform I2C clock-stretching, wherever applicable, to perform the requested actions.

**Note:** It is recommended for the BMC to add 2 seconds as inter-command interval.

In addition to the FPGA flash update via OoB, SC also supports other FPGA flash related operations like:

-  Enable or Disable Write Protect (WP#) settings

-  FPGA flash image read-back

-  Flash image authentication via MAC/HASH calculation 

-  Copy of flash image from one flash to another (F2F copy)

The table below lists all the commands supported/needed for FPGA flash operations. Currently, the FPGA flash operation commands are supported only for Alveo™ U30.

**Note:** MAC in this chapter refers to Message Authentication Code and it can also be referred as HASH. MAC/HASH calculation of the entire or sometimes few select FPGA flash sectors is performed at the request of BMC, to validate the flash contents haven't been tampered with.

*Table:* **FPGA Flash Upgrade Commands**

+-------------+----------------------------+----------------------------------+-----------------------------+
| **Command** | **Command Description**    | **Server BMC Action**            | **SC Action**               |
+=============+============================+==================================+=============================+
|     0x40    | FPGA\_RESET\_DEVICE        | B0 from BMC:                     | See table 'Flash Operation  |
|             |                            |                                  |                             |
|             |                            | 0x01: FPGA devices               | Return Codes' for SC's      |
|             |                            |                                  |                             |
|             |                            | 0x02: SC FW                      | response                    |
|             |                            |                                  |                             |
+-------------+----------------------------+----------------------------------+-----------------------------+
|     0x41    | FPGA\_GET\_FW\_VER         | B0 from BMC:                     | B0 – Valid Byte             |
|             |                            |                                  |                             |
|             |                            | 0x01: FPGA1 Primary              | B1 - Minor revision         |
|             |                            |                                  |                             |
|             |                            | 0x02: FPGA1 Recovery             | B2 - Major revision         |
|             |                            |                                  |                             |
|             |                            | 0x03: FPGA2 Primary (if present) |                             |
|             |                            |                                  |                             |
|             |                            | 0x04: FPGA2 Recovery(if present) |                             |
|             |                            |                                  |                             |
+-------------+----------------------------+----------------------------------+-----------------------------+
|     0x42    | FPGA\_SET\_TARGET\_DEVICE  | B0 from BMC                      | See table 'Flash Operation  |
|             |                            |                                  |                             |
|             |                            | 0x01: FPGA1 Primary              | Return Codes' for SC's      |
|             |                            |                                  |                             |
|             |                            | 0x02: FPGA1 Recovery             | response                    |
|             |                            |                                  |                             |
|             |                            | 0x03: FPGA2 Primary (if present) |                             |
|             |                            |                                  |                             |
|             |                            | 0x04: FPGA2 Recovery(if present) |                             |
|             |                            |                                  |                             |
+-------------+----------------------------+----------------------------------+-----------------------------+
|     0x43    | FPGA\_SET\_BOOT\_DEVICE    | B0 from BMC:                     | See table 'Flash Operation  |
|             |                            |                                  |                             |
|             |                            | 0x01: FPGA1 Primary              | Return Codes' for SC's      |
|             |                            |                                  |                             |
|             |                            | 0x02: FPGA1 Recovery             | response                    |
|             |                            |                                  |                             |
|             |                            | 0x03: FPGA2 Primary (if present) |                             |
|             |                            |                                  |                             |
|             |                            | 0x04: FPGA2 Recovery(if present) |                             |
|             |                            |                                  |                             |
+-------------+----------------------------+----------------------------------+-----------------------------+
|     0x44    | FPGA\_SC\_SET\_WRITE       | B0 from BMC:                     | See table 'Flash Operation  |
|             |                            |                                  |                             |
|             | \_ENABLE                   | 0x01: FPGA1 Primary              | Return Codes' for SC's      |
|             |                            |                                  |                             |
|             |                            | 0x02: FPGA1 Recovery             | response                    |
|             | Provides control to SC     |                                  |                             |
|             |                            | 0x03: FPGA2 Primary (if present) |                             |
|             | over WP# pins and enables  |                                  |                             |
|             |                            | 0x04: FPGA2 Recovery(if present) |                             |
|             | SC to access QSPI flash    |                                  |                             |
|             |                            | B1 from BMC:                     |                             |
|             |                            |                                  |                             |
|             |                            | 0x01: WP enable                  |                             |
|             |                            |                                  |                             |
|             |                            | 0x02: WP disable                 |                             |
|             |                            |                                  |                             |
+-------------+----------------------------+----------------------------------+-----------------------------+
|     0x45    | FLASH\_SET\_WRITE\_ENABLE  | B0 from BMC:                     | See table 'Flash Operation  |
|             |                            |                                  |                             |
|             |                            | 0x01: FPGA1 Primary              | Return Codes' for SC's      |
|             |                            |                                  |                             |
|             |                            | 0x02: FPGA1 Recovery             | response                    |
|             | Provides control to SC     |                                  |                             |
|             |                            | 0x03: FPGA2 Primary (if present) |                             |
|             | over WP# pins and enables  |                                  |                             |
|             |                            | 0x04: FPGA2 Recovery(if present) |                             |
|             | FPGA to access QSPI flash  |                                  |                             |
|             |                            | B1 from BMC:                     |                             |
|             |                            |                                  |                             |
|             |                            | 0x01: WP enable                  |                             |
|             |                            |                                  |                             |
|             |                            | 0x02: WP disable                 |                             |
|             |                            |                                  |                             |
+-------------+----------------------------+----------------------------------+-----------------------------+
|     0x46    | FLASH\_GET\_WRITE          | B0 from BMC:                     | Byte 0: SC WP Status        |
|             |                            |                                  |                             |
|             | \_PROTECT\_STATES          | 0x01: FPGA1 Primary              | 0x01: WP enabled            |
|             |                            |                                  |                             |
|             |                            | 0x02: FPGA1 Recovery             | 0x02: WP disabled           |
|             |                            |                                  |                             |
|             |                            | 0x03: FPGA2 Primary (if present) | Byte 1: FPGA WP Status      |
|             |                            |                                  |                             |
|             |                            | 0x04: FPGA2 Recovery(if present) | 0x01: WP enabled            |
|             |                            |                                  |                             |
|             |                            |                                  | 0x02: WP disabled           |
|             |                            |                                  |                             |
+-------------+----------------------------+----------------------------------+-----------------------------+
|     0x47    | FLASH\_RX\_DATA\_BLOCK     | BMC sends data bytes             | N/A                         |
|             |                            |                                  |                             |
|             | SC accumulates 252 bytes   | D0, D1 ... D251                  |                             |
|             |                            |                                  |                             |
|             | from each transaction to   |                                  |                             |
|             |                            |                                  |                             |
|             | form 64KB sector & writes  |                                  |                             |
|             |                            |                                  |                             |
|             | it into QSPI flash         |                                  |                             |
|             |                            |                                  |                             |
+-------------+----------------------------+----------------------------------+-----------------------------+
|     0x48    | FLASH\_BLOCK\_CRC\_CHECK   | BMC sends 8 byte CRC             | See table 'Flash Operation  |
|             |                            |                                  |                             |
|             | SC compares CRC, writes 1  | B1, B2 ... B8                    | Return Codes' for SC's      |
|             |                            |                                  |                             |
|             | sector to flash, rechecks  |                                  | response                    |
|             |                            |                                  |                             |
|             | CRC with FPGA device       |                                  |                             |
|             |                            |                                  |                             |
+-------------+----------------------------+----------------------------------+-----------------------------+
|     0x49    | FLASH\_SECTOR\_SET\_SEQ    | B0: Sector number (low byte)     | See table 'Flash Operation  |
|             |                            |                                  |                             |
|             | \_NUM                      | B0: Sector number (high byte)    | Return Codes' for SC's      |
|             |                            |                                  |                             |
|             |                            |                                  | response                    |
|             |                            |                                  |                             |
+-------------+----------------------------+----------------------------------+-----------------------------+
|     0x4A    | FLASH\_COPY\_FIRMWARE      | B0: Source flash device          | See table 'Flash Operation  |
|             |                            |                                  |                             |
|             |                            | 0x01: FPGA1 Primary              | Return Codes' for SC's      |
|             |                            |                                  |                             |
|             |                            | 0x02: FPGA1 Recovery             | response                    |
|             |                            |                                  |                             |
|             |                            | 0x03: FPGA2 Primary (if present) |                             |
|             |                            |                                  |                             |
|             |                            | 0x04: FPGA2 Recovery(if present) |                             |
|             |                            |                                  |                             |
|             |                            | B0: Destination flash device     |                             |
|             |                            |                                  |                             |
|             |                            | 0x01: FPGA1 Primary              |                             |
|             |                            |                                  |                             |
|             |                            | 0x02: FPGA1 Recovery             |                             |
|             |                            |                                  |                             |
|             |                            | 0x03: FPGA2 Primary (if present) |                             |
|             |                            |                                  |                             |
|             |                            | 0x04: FPGA2 Recovery(if present) |                             |
|             |                            |                                  |                             |
+-------------+----------------------------+----------------------------------+-----------------------------+
|     0x4B    | FPGA\_GET\_FIRMWARE        | N/A                              | See table 'Flash Operation  |
|             |                            |                                  |                             |
|             | \_STATUS                   |                                  | Return Codes' for SC's      |
|             |                            |                                  |                             |
|             |                            |                                  | response                    |
|             |                            |                                  |                             |
+-------------+----------------------------+----------------------------------+-----------------------------+
|     0x4C    | FPGA\_SET\_KEY\_NONCE      | B0 from BMC:                     | See table 'Flash Operation  |
|             |                            |                                  |                             |
|             | BMC sends key and nonce    | 0x01: FPGA1 Primary              | Return Codes' for SC's      |
|             |                            |                                  |                             |
|             | that's randomly generated. | 0x02: FPGA1 Recovery             | response                    |
|             |                            |                                  |                             |
|             | SC stores both in internal | 0x03: FPGA2 Primary (if present) |                             |
|             |                            |                                  |                             |
|             | flash (Non-volatile)       | 0x04: FPGA2 Recovery(if present) |                             |
|             |                            |                                  |                             |
|             |                            | B1 - B16: Key                    |                             |
|             |                            |                                  |                             |
|             |                            | B17 – B28: Nonce                 |                             |
|             |                            |                                  |                             |
+-------------+----------------------------+----------------------------------+-----------------------------+
|     0x4D    | FPGA\_CALC\_MAC            | B0 from BMC:                     | See table 'Flash Operation  |
|             |                            |                                  |                             |
|             | SC increments nonce by 1,  | 0x01: FPGA1 Primary              | Return Codes' for SC's      |
|             |                            |                                  |                             |
|             | calculates hash using the  | 0x02: FPGA1 Recovery             | response                    |
|             |                            |                                  |                             |
|             | existing key & new nonce,  | 0x03: FPGA2 Primary (if present) |                             |
|             |                            |                                  |                             |
|             | and stores MAC/hash value  | 0x04: FPGA2 Recovery(if present) |                             |
|             |                            |                                  |                             |
|             | in SC's internal flash     |                                  |                             |
|             |                            |                                  |                             |
+-------------+----------------------------+----------------------------------+-----------------------------+
|     0x4E    | FPGA\_VERIFY\_MAC          | B0 from BMC:                     | See table 'Flash Operation  |
|             |                            |                                  |                             |
|             | SC calculates hash using   | 0x01: FPGA1 Primary              | Return Codes' for SC's      |
|             |                            |                                  |                             |
|             | existing key & nonce, and  | 0x02: FPGA1 Recovery             | response                    |
|             |                            |                                  |                             |
|             | stores MAC/hash value in   | 0x03: FPGA2 Primary (if present) |                             |
|             |                            |                                  |                             |
|             | SC's internal flash        | 0x04: FPGA2 Recovery(if present) |                             |
|             |                            |                                  |                             |
+-------------+----------------------------+----------------------------------+-----------------------------+
|     0x4F    | FPGA\_GET\_MAC\_STATUS     | B0 from BMC:                     | Byte B0 from SC:            |
|             |                            |                                  |                             |
|             | SC responds with status of | 0x01: FPGA1 Primary              | See table 'Flash Operation  |
|             |                            |                                  |                             |
|             | MAC/has calculation or     | 0x02: FPGA1 Recovery             | Return Codes' for           |
|             |                            |                                  |                             |
|             | verification along with    | 0x03: FPGA2 Primary (if present) | response                    |
|             |                            |                                  |                             |
|             | the 16-byte MAC value      | 0x04: FPGA2 Recovery(if present) | Bytes B1 - B16 from SC:     |
|             |                            |                                  |                             |
|             |                            | B1 from BMC:                     | 16 byte MAC/hash value      |
|             |                            |                                  |                             |
|             |                            | 0x01: Get CALC\_MAC status       |                             |
|             |                            |                                  |                             |
|             |                            | 0x02: Get VERIFY\_MAC status     |                             |
|             |                            |                                  |                             |
+-------------+----------------------------+----------------------------------+-----------------------------+
|     0x50    | FPGA\_SET\_IMAGE\_SIZE     | B0 from BMC:                     | N/A                         |
|             |                            |                                  |                             |
|             |                            | 0x01: FPGA1 Primary              |                             |
|             |                            |                                  |                             |
|             |                            | 0x02: FPGA1 Recovery             |                             |
|             |                            |                                  |                             |
|             |                            | 0x03: FPGA2 Primary (if present) |                             |
|             |                            |                                  |                             |
|             |                            | 0x04: FPGA2 Recovery(if present) |                             |
|             |                            |                                  |                             |
|             |                            | B1 - B4 from BMC (LSB first):    |                             |
|             |                            |                                  |                             |
|             |                            | Size of QSPI image in bytes      |                             |
|             |                            |                                  |                             |
+-------------+----------------------------+----------------------------------+-----------------------------+
|     0x51    | NOTIFY\_WP\_TO\_FPGA       | B0 from BMC:                     |  Byte B0 from SC:           |
|             |                            |                                  |                             |
|             |                            | 0x01: FPGA1 Primary              |  0x01: Operation Success    |
|             |                            |                                  |                             |
|             |                            | 0x02: FPGA1 Recovery             |  0x02: Operation failure    |
|             |                            |                                  |                             |
|             |                            | 0x03: FPGA2 Primary (if present) |                             |
|             |                            |                                  |                             |
|             |                            | 0x04: FPGA2 Recovery(if present) |                             |
|             |                            |                                  |                             |
+-------------+----------------------------+----------------------------------+-----------------------------+
|    0x52     | FPGA\_UART\_DEBUG\_CONTROL | B0 from BMC:                     |  Byte B0 from SC:           |
|             |                            |                                  |                             |
|             |                            | 0x01: FPGA1                      | 0x01: Operation Success     |
|             |                            |                                  |                             |
|             |                            | 0x02: FPGA2                      | 0x02: Operation failure     |
|             |                            |                                  |                             |
|             |                            |                                  | 0x03: Operation unsupported |
|             |                            |                                  |                             |
+-------------+----------------------------+----------------------------------+-----------------------------+
|    0x53     | SET\_FPGA\_FLASH\_READBACK | B0: Start sector num (low byte)  | See table 'Flash Operation  |
|             |                            |                                  |                             |
|             | \_SECTOR\_RANGE            | B1: Start sector num (high byte) | Return Codes' for SC's      |
|             |                            |                                  |                             |
|             |                            | B2: End sector num (low byte)    | response                    |
|             |                            |                                  |                             |
|             |                            | B4: End sector num (high byte)   |                             |
|             |                            |                                  |                             |
+-------------+----------------------------+----------------------------------+-----------------------------+
|    0x54     | FPGA\_FLASH\_TX            | BMC sends repeated-start         | SC sends 252 data bytes:    |
|             |                            |                                  |                             |
|             | \_DATA\_BLOCK              | I2C command                      | D0, D1 ... D251             |
|             |                            |                                  |                             |
+-------------+----------------------------+----------------------------------+-----------------------------+


*Table:* **Flash Operation Return Codes**

+--------------------+----------------------------------------------------------------------------------------+
| **Response Code**  | **Description**                                                                        |
+====================+========================================================================================+
| 0x00               | Reserved                                                                               |
+--------------------+----------------------------------------------------------------------------------------+
| 0x01               | Operation success                                                                      |
+--------------------+----------------------------------------------------------------------------------------+
| 0x02               | Operation failed                                                                       |
+--------------------+----------------------------------------------------------------------------------------+
| 0x03               | Operation Not Supported                                                                |
+--------------------+----------------------------------------------------------------------------------------+
| 0x04               | Flash erase failed. Abort operation, rectify error and re-initiate from start          |
+--------------------+----------------------------------------------------------------------------------------+
| 0x05               | Flash write failed. Abort operation, rectify error and re-initiate from start          |
+--------------------+----------------------------------------------------------------------------------------+
| 0x06               | Flash read failed. Abort operation, rectify error and re-initiate from start           |
+--------------------+----------------------------------------------------------------------------------------+
| 0x07               | Flash CRC failed. Abort operation, rectify error and re-initiate from start            |
+--------------------+----------------------------------------------------------------------------------------+
| 0x08               | Invalid Selection                                                                      |
+--------------------+----------------------------------------------------------------------------------------+
| 0x09               | FPGA\_GENERAL\_ERROR                                                                   |
+--------------------+----------------------------------------------------------------------------------------+
| 0x0A               | FPGA\_MAC\_CALCULATION\_INVALID                                                        |
+--------------------+----------------------------------------------------------------------------------------+
| 0x0B               | FPGA\_INVALID\_IMAGE\_LENGTH                                                           |
+--------------------+----------------------------------------------------------------------------------------+
| 0x0C               | QSPI SC disable WP failed. Abort operation, rectify error and re-initiate from start   |
+--------------------+----------------------------------------------------------------------------------------+
| 0x0D               | QSPI wrong MCS file format. Abort operation, rectify error and re-initiate from start  |
+--------------------+----------------------------------------------------------------------------------------+
| 0x0E               | Set the KEY and/or NONCE before proceeding for MAC Calculation                         |
+--------------------+----------------------------------------------------------------------------------------+
| 0x0F               | MAC calculation not performed. Please send command 0x4D before MAC verify              |
+--------------------+----------------------------------------------------------------------------------------+
| 0x10               | FLASH\_RX\_DATA\_BLOCK command in-progress                                             |
+--------------------+----------------------------------------------------------------------------------------+
| 0x11               | FPGA1 primary flash update in-progress                                                 |
+--------------------+----------------------------------------------------------------------------------------+
| 0x12               | FPGA1 recovery flash update in-progress                                                |
+--------------------+----------------------------------------------------------------------------------------+
| 0x13               | FPGA2 primary flash update in-progress                                                 |
+--------------------+----------------------------------------------------------------------------------------+
| 0x14               | FPGA2 recovery flash update in-progress                                                |
+--------------------+----------------------------------------------------------------------------------------+
| 0x15–0x1F          | Reserved                                                                               |
+--------------------+----------------------------------------------------------------------------------------+
| 0x20               | FLASH\_BLOCK\_CRC\_CHECK command in-progress                                           |
+--------------------+----------------------------------------------------------------------------------------+
| 0x21               | FPGA\_CRC\_CHECK\_STATUS\_IN\_PROGRESS                                                 |
+--------------------+----------------------------------------------------------------------------------------+
| 0x22               | QSPI_SET_UPDATE_DEVICE_NOT_SENT (send command 0x42)                                    |
+--------------------+----------------------------------------------------------------------------------------+
| 0x23               | QSPI_SC_SET_WRITE_NOT_ENABLED (send command 0x44)                                      |
+--------------------+----------------------------------------------------------------------------------------+
| 0x24–0x2F          | Reserved                                                                               |
+--------------------+----------------------------------------------------------------------------------------+
| 0x30               | FLASH\_COPY\_FIRMWARE command in-progress                                              |
+--------------------+----------------------------------------------------------------------------------------+
| 0x31               | FPGA1 primary to FPGA1 recovery flash copy in-progress                                 |
+--------------------+----------------------------------------------------------------------------------------+
| 0x32               | FPGA1 primary to FPGA2 primary flash copy in-progress                                  |
+--------------------+----------------------------------------------------------------------------------------+
| 0x33               | FPGA1 primary to FPGA2 recovery flash copy in-progress                                 |
+--------------------+----------------------------------------------------------------------------------------+
| 0x34               | FPGA1 recovery to FPGA1 primary flash copy in-progress                                 |
+--------------------+----------------------------------------------------------------------------------------+
| 0x35               | FPGA1 recovery to FPGA2 primary flash copy in-progress                                 |
+--------------------+----------------------------------------------------------------------------------------+
| 0x36               | FPGA1 recovery to FPGA2 recovery flash copy in-progress                                |
+--------------------+----------------------------------------------------------------------------------------+
| 0x37               | FPGA2 primary to FPGA1 primary flash copy in-progress                                  |
+--------------------+----------------------------------------------------------------------------------------+
| 0x38               | FPGA2 primary to FPGA1 recovery flash copy in-progress                                 |
+--------------------+----------------------------------------------------------------------------------------+
| 0x39               | FPGA2 primary to FPGA2 recovery flash copy in-progress                                 |
+--------------------+----------------------------------------------------------------------------------------+
| 0x3A               | FPGA2 recovery to FPGA1 primary flash copy in-progress                                 |
+--------------------+----------------------------------------------------------------------------------------+
| 0x3B               | FPGA2 recovery to FPGA1 recovery flash copy in-progress                                |
+--------------------+----------------------------------------------------------------------------------------+
| 0x3C               | FPGA2 recovery to FPGA2 primary flash copy in-progress                                 |
+--------------------+----------------------------------------------------------------------------------------+
| 0x3D–0x3F          | Reserved                                                                               |
+--------------------+----------------------------------------------------------------------------------------+
| 0x40               | FPGA\_CALC\_MAC command in-progress                                                    |
+--------------------+----------------------------------------------------------------------------------------+
| 0x41               | FPGA1 primary MAC calculation in-progress                                              |
+--------------------+----------------------------------------------------------------------------------------+
| 0x42               | FPGA1 recovery MAC calculation in-progress                                             |
+--------------------+----------------------------------------------------------------------------------------+
| 0x43               | FPGA2 primary MAC calculation in-progress                                              |
+--------------------+----------------------------------------------------------------------------------------+
| 0x44               | FPGA2 recovery MAC calculation in-progress                                             |
+--------------------+----------------------------------------------------------------------------------------+
| 0x45               | FPGA\_KEY\_NONCE update in-progress                                                    |
+--------------------+----------------------------------------------------------------------------------------+
| 0x46–0x4F          | Reserved                                                                               |
+--------------------+----------------------------------------------------------------------------------------+
| 0x50               | FPGA\_VERIFY\_MAC command in-progress                                                  |
+--------------------+----------------------------------------------------------------------------------------+
| 0x51               | FPGA1 primary MAC verification in-progress                                             |
+--------------------+----------------------------------------------------------------------------------------+
| 0x52               | FPGA1 recovery MAC verification in-progress                                            |
+--------------------+----------------------------------------------------------------------------------------+
| 0x53               | FPGA2 primary MAC verification in-progress                                             |
+--------------------+----------------------------------------------------------------------------------------+
| 0x54               | FPGA2 recovery MAC verification in-progress                                            |
+--------------------+----------------------------------------------------------------------------------------+
| 0x54–0xEF          | Reserved                                                                               |
+--------------------+----------------------------------------------------------------------------------------+
| 0xFF               | FPGA\_NO\_OPERATION                                                                    |
+--------------------+----------------------------------------------------------------------------------------+

0x40 - FPGA\_RESET\_DEVICE
~~~~~~~~~~~~~~~~~~~~~~~~~~

The BMC can send the FPGA\_RESET\_DEVICE command to reset FPGA device(s) or SC FW. For SC reset (warm reset), the satellite
controller firmware responds with the status and reboots itself. In Alveo U30, the reset command will reset both the FPGA devices
(ZYNQ1 and ZYNQ2) and internally, both PS (Processing Subsystem) and PL (Programmable Logic) will reload from flash device.

*Table:* **FPGA\_RESET\_DEVICE Server BMC Request**

+-----------------------+--------------------------------+
|     **Server BMC Request**                             |
+=======================+================================+
|     Command code      |     0x40                       |
+-----------------------+--------------------------------+
|     Byte0             |     0x01: FPGA devices         |
|                       |                                |
|                       |     0x02: SC FW                |
+-----------------------+--------------------------------+

*Table:* **FPGA\_RESET\_DEVICE Xilinx Alveo Card Response**

+-------------+------+----------------------------------------------------------------+
| **Xilinx Alveo Card Response**                                                      |
+=============+======+================================================================+
| Data bytes  | B0   | See table 'Flash Operation Return Codes' for SC's response     |
+-------------+------+----------------------------------------------------------------+

0x41 - FPGA\_GET\_FW\_VER
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The BMC sends this command to fetch the FW version running in either FPGA1 or FPGA2 device. This command is currently supported only in the Alveo U30 data accelerator card. The byte 0 (validity byte) in response from SC must be read first.

*Table:* **FPGA\_GET\_FW\_VER Server BMC Request**

+--------------------+-----------------------------------------------------+
|     **Server BMC Request**                                               |
+====================+=====================================================+
|     Command code   |     0x41                                            |
+--------------------+-----------------------------------------------------+
|     Byte0          |     0x01: FPGA1 primary flash device                |
|                    |                                                     |
|                    |     0x02: FPGA1 recovery flash device               |
|                    |                                                     |
|                    |     0x03: FPGA2 primary flash device (if present)   |
|                    |                                                     |
|                    |     0x04: FPGA2 recovery flash device (if present)  |
+--------------------+-----------------------------------------------------+

*Table:* **FPGA\_GET\_FW\_VER Xilinx Alveo Card Response**

+-------------+---------+-------------------------------------------+
| **Xilinx Alveo Card Response**                                    |
+=============+=========+===========================================+
| Data bytes  | B0      | B0 - Valid Byte                           |
|             |         |                                           |
|             |         | 0x00 - Not supported (B1, B2 - Invalid)   |
|             |         |                                           |
|             |         | 0x01 - Unknown or Reduced Service         |
|             |         |                                           |
|             |         | 0x02 - reserved                           |
|             |         |                                           |
|             |         | 0x03 - No error; Valid B1 & B2 bytes      |
|             |         |                                           |
|             | B1, B2  | B1 – Minor version; B2 – Major version    |
+-------------+---------+-------------------------------------------+


0x42 - FPGA\_SET\_TARGET\_DEVICE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

BMC sends the FPGA\_SET\_TARGET\_DEVICE command to select the flash
device to initiate the FW upgrade.

**NOTE:** This command is not persistence across SC reboots. On boot-up, SC restores the default configuration (i.e.) Primary flash as teh target device.  

*Table:* **FPGA\_SET\_TARGET\_DEVICE Server BMC Request**

+----------------+-------------------------------------------------+
| **Server BMC Request**                                           |
+================+=================================================+
| Command code   | 0x42                                            |
+----------------+-------------------------------------------------+
| Byte0          | 0x01: FPGA1 primary flash device                |
|                |                                                 |
|                | 0x02: FPGA1 recovery flash device               |
|                |                                                 |
|                | 0x03: FPGA2 primary flash device (if present)   |
|                |                                                 |
|                | 0x04: FPGA2 recovery flash device (if present)  |
+----------------+-------------------------------------------------+

*Table:* **FPGA\_SET\_TARGET\_DEVICE Xilinx Alveo Card Response**

+-------------+------+----------------------------------------------------------------+
| **Xilinx Alveo Card Response**                                                      |
+=============+======+================================================================+
| Data bytes  | B0   | See table 'Flash Operation Return Codes' for SC's response     |
+-------------+------+----------------------------------------------------------------+

0x43 - FPGA\_SET\_BOOT\_DEVICE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The BMC sends the FPGA\_SET\_BOOT\_DEVICE command to set the boot
device. The SC FW stores this information in the internal flash memory and
restores the configuration in case of server cool boot or power cycle.

**Note:** Primary flash device is selected as the boot
device/default configuration in FPGA1 (and FPGA2 if present).

*Table:* **FPGA\_SET\_BOOT\_DEVICE Server BMC Request**

+----------------+-------------------------------------------------+
|     **Server BMC Request**                                       |
+================+=================================================+
| Command code   | 0x43                                            |
+----------------+-------------------------------------------------+
| Byte0          | 0x01– FPGA1 primary flash device                |
|                |                                                 |
|                | 0x02– FPGA1 recovery flash device               |
|                |                                                 |
|                | 0x03– FPGA2 primary flash device (if present)   |
|                |                                                 |
|                | 0x04– FPGA2 recovery flash device (if present)  |
+----------------+-------------------------------------------------+

*Table:* **FPGA\_SET\_BOOT\_DEVICE Xilinx Alveo Card Response**

+-------------+-------------+-----------------------------+
|     **Xilinx Alveo Card Response**                      |
+=============+=============+=============================+
| Data bytes  |     Byte0   |     0x01– Request success   |
|             |             |                             |
|             |             |     0x02– Request failed    |
+-------------+-------------+-----------------------------+

0x44 - FPGA\_SC\_SET\_WRITE\_ENABLE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The BMC sends the FPGA\_SC\_SET\_WRITE\_ENABLE command to enable/disable write protect for SPI mode from the SC point of view. This command must follow FPGA\_SET\_TARGET\_DEVICE. When the SC has write protect mode disabled, only the SC has the access to QSPI flash and only SC can write into the flash via SPI (x1 mode). In this case, FPGA can not read from FPGA flash.

For both hyperscaler and OEM customers, by default, SC WP# is enabled (i.e.) FPGA has read-only access. The actual FPGA WP# state (write access) is controlled by command 0x45.

**Note:** The SC will not store this configuration (from command 0x44)  in any persistence memory. A SC reboot or device power cycle results in loss of configuration. During the subsequent boot-up, the SC will restore the default configuration (i.e.) WP enabled.

*Table:* **FPGA\_SC\_SET\_WRITE\_ENABLE Server BMC Request**

+-------------------+-----------------------------------------------------+
|     **Server BMC Request**                                              |
+===================+=====================================================+
|     Command code  |     0x44                                            |
+-------------------+-----------------------------------------------------+
|     Byte0         |     0x01: FPGA1 primary flash device                |
|                   |                                                     |
|                   |     0x02: FPGA1 recovery flash device               |
|                   |                                                     |
|                   |     0x03: FPGA2 primary flash device (if present)   |
|                   |                                                     |
|                   |     0x04: FPGA2 recovery flash device (if present)  |
+-------------------+-----------------------------------------------------+
|     Byte1         |     0x01: WP enable                                 |
|                   |                                                     |
|                   |     0x02: WP disable                                |
+-------------------+-----------------------------------------------------+

*Table:* **FPGA\_SC\_SET\_WRITE\_ENABLE Xilinx Alveo Card Response**

+-------------+------+----------------------------------------------------------------+
| **Xilinx Alveo Card Response**                                                      |
+=============+======+================================================================+
| Data bytes  | B0   | See table 'Flash Operation Return Codes' for SC's response     |
+-------------+------+----------------------------------------------------------------+

0x45 - FLASH\_SET\_WRITE\_ENABLE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The BMC can send the FLASH\_SET\_WRITE\_ENABLE command to enable/disable write protect the QSPI flash device in either ZYNQ
device. This command must follow FPGA\_SC\_SET\_WRITE\_ENABLE for any FPGA flash FW upgrade.

For Hyperscaler customers, by default, the FPGA flash devices are write protected and can only run in x2 SPI mode as a preferred/secured mode. 

When write protect is disabled, the QSPI flash device can be accessed in x1, x2, or x4 SPI Mode and FPGA has the write access to the QSPI devices. This is the default mode configured for OEM customers. SC FW configures this mode based on FRU parameters written into its EEPROM.

**Note:** The SC will not store this configuration (from command 0x45) in any persistence memory. A SC reboot or device power cycle results in the loss of configuration. During the subsequent boot-up, the SC will restore the default configuration (i.e.) WP enabled.

*Table:* **FLASH\_SET\_WRITE\_ENABLE Server BMC Request**

+---------------+-------------------------------------------------+
|     **Server BMC Request**                                      |
+===============+=================================================+
| Command code  | 0x45                                            |
+---------------+-------------------------------------------------+
| Byte0         | 0x01: FPGA1 primary flash device                |
|               |                                                 |
|               | 0x02: FPGA1 recovery flash device               |
|               |                                                 |
|               | 0x03: FPGA2 primary flash device (if present)   |
|               |                                                 |
|               | 0x04: FPGA2 recovery flash device (if present)  |
+---------------+-------------------------------------------------+
| Byte1         | 0x01: WP enable                                 |
|               |                                                 |
|               | 0x02: WP disable                                |
+---------------+-------------------------------------------------+

*Table:* **FLASH\_SET\_WRITE\_ENABLE Xilinx Alveo Card Response**

+-------------+------+----------------------------------------------------------------+
| **Xilinx Alveo Card Response**                                                      |
+=============+======+================================================================+
| Data bytes  | B0   | See table 'Flash Operation Return Codes' for SC's response     |
+-------------+------+----------------------------------------------------------------+

0x46 - FLASH\_GET\_WRITE\_PROTECT\_STATES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The BMC can send the FLASH\_GET\_WRITE\_PROTECT\_STATES command to
get the write protect state for all the flash devices.

*Table:* **FLASH\_GET\_WRITE\_PROTECT\_STATES Server BMC Request**

+---------------+-------------------------------------------------+
|     **Server BMC Request**                                      |
+===============+=================================================+
| Command code  | 0x46                                            |
+---------------+-------------------------------------------------+
| Byte0         | 0x01: FPGA1 primary flash device                |
|               |                                                 |
|               | 0x02: FPGA1 recovery flash device               |
|               |                                                 |
|               | 0x03: FPGA2 primary flash device (if present)   |
|               |                                                 |
|               | 0x04: FPGA2 recovery flash device (if present)  |
+---------------+-------------------------------------------------+

*Table:* **FLASH\_GET\_WRITE\_PROTECT\_STATES Xilinx Alveo Card Response**

+-------------+-------------+----------------------------------------------+
|     **Xilinx Alveo Card Response**                                       |
+=============+=============+==============================================+
| Data bytes  | Byte0       | Byte 0: SC WP Status                         |  
|             |             |                                              |
|             |             | 0x01: WP enabled ; 0x02: WP disabled         |
+-------------+-------------+----------------------------------------------+
|             | Byte 1      | Byte 1: FPGA WP Status                       |
|             |             |                                              |
|             |             | 0x01: WP enabled ; 0x02: WP disabled         |
+-------------+-------------+----------------------------------------------+

0x47 - FLASH\_RX\_DATA\_BLOCK
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The BMC sends data blocks using the FLASH\_RX\_DATA\_BLOCK command. Data (or payload) is the FW for QSPI flash devices. The SC accumulates 252 byte data from each transaction to build up 64 Kbyte blocks and write into QSPI flash. The sector size for QSPI flash is 64 Kbyte and the SC will cache 1 block of data in the internal SRAM before writing it to QSPI. This command must be preceded by the FPGA\_SET\_TARGET\_DEVICE, FPGA\_SC\_SET\_WRITE\_ENABLE, and FLASH\_SET\_WRITE\_ENABLE commands.

**Note:** The maximum supported size of each I2C transaction is 252 bytes.

*Table:* **FLASH\_RX\_DATA\_BLOCK Server BMC Request**

+---------------+----------------------------------------------------------------+
| **Server BMC Request**                                                         |
+===============+================================================================+
| Command code  | 0x47                                                           |
+---------------+----------------------------------------------------------------+
| Length byte 0 | Total number of bytes in the current I2C transaction (command) |
+---------------+----------------------------------------------------------------+
| Data bytes    | D1, D2, … D252                                                 |
+---------------+----------------------------------------------------------------+

*Table:* **FLASH\_RX\_DATA\_BLOCK Xilinx Alveo Card Response**

+-------------+------+----------------------------------------------------------------+
| **Xilinx Alveo Card Response**                                                      |
+=============+======+================================================================+
| Data bytes  | B0   | See table 'Flash Operation Return Codes' for SC's response     |
+-------------+------+----------------------------------------------------------------+

0x48 - FLASH\_BLOCK\_CRC\_CHECK
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The BMC sends the FLASH\_BLOCK\_CRC\_CHECK command to check the CRC from the previous block and tracks the number of bytes sent to the SC. After sending 64K bytes, the BMC sends this command to initiate CRC check. The BMC sends 64-bit CRC (data payload and start address of the block) for the previous 64 Kbyte block along with this command request. This command also indicates the completion of the 64 Kbyte block transfer from the BMC to the SC, which immediately
returns the status CRC\_CHECK\_IN\_PROGRESS. This command is a trigger for the SC to start all the flash write and CRC check
operations in the background. The BMC can poll the FPGA\_GET\_FIRMWARE\_STATUS command periodically for completion
status before moving to next sector. See table 'Flash Operation Return Codes' for SC's response

*Table 97:* **FLASH\_BLOCK\_CRC\_CHECK Server BMC Server**

+--------------+-------------------+
|     **Server BMC Request**       |
+==============+===================+
| Command code | 0x48              |
+--------------+-------------------+
| Data bytes   | D1 … D8           |
|              |                   |
|              | 64-bit CRC data   |
+--------------+-------------------+

*Table:* **FLASH\_BLOCK\_CRC\_CHECK Xilinx Alveo Card Response**

+-------------+------+----------------------------------------------------------------+
| **Xilinx Alveo Card Response**                                                      |
+=============+======+================================================================+
| Data bytes  | B0   | See table 'Flash Operation Return Codes' for SC's response     |
+-------------+------+----------------------------------------------------------------+

0x49 - FLASH\_SECTOR\_SET\_SEQ\_NUM
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The FPGA flash FW image update needs to be implemented with the retry mechanism in both the server BMC and the Alveo SC.

The BMC sends the FLASH\_SECTOR\_SET\_SEQ\_NUM command to set the sequence number (or the sector number) of the sector at which the SC needs to write into the FPGA Flash. This retry mechanism is needed to restart the FPGA FW upgrade process from the point where it was terminated previously. The termination reason could be a reboot of the SC FW, the BMC FW, power loss, or any user triggered event.

When server BMC wants to restart the FPGA FW upgrade process from the middle, the BMC sends a valid 2-byte sequence number. The BMC may keep track of the sequence number and keep updating by 1 for every successful response from the SC for the command FLASH\_BLOCK\_CRC\_CHECK.

The SC will calculate the sector start address based on the sequence number and the fixed start offset (expected to be 0x0) of the FW inside flash. Responsibility is on the BMC to send the correct sequence number and its corresponding payload. Otherwise the SC may write into a non- contiguous flash sector and may end up corrupting the FW.

**Note:** The SC will not store the sector information in persistence memory. On boot-up, default value 0x00 will be assigned.

*Table:* **FLASH\_SECTOR\_SET\_SEQ\_NUM Server BMC Request**

+--------------+---------------------------------+
|     **Server BMC Request**                     |
+==============+=================================+
| Command code | 0x49                            |
+--------------+---------------------------------+
| Data bytes   | B0– Sector number (low byte)    |
|              |                                 |
|              | B1– Sector number (high byte)   |
+--------------+---------------------------------+

*Table:* **FLASH\_SECTOR\_SET\_SEQ\_NUM Xilinx Alveo Card Response**

+-------------+-----------------------------+
|     **Xilinx Alveo Card Response**        |
+=============+=============================+
| Data bytes  |     Byte0                   |
|             |                             |
|             |     0x01: Request success   |
|             |                             |
|             |     0x02: Request failed    |
+-------------+-----------------------------+

0x4A - FLASH\_COPY\_FIRMWARE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The BMC sends the FLASH\_COPY\_FIRMWARE command to initiate the copy of FW from one QSPI flash device to another. The BMC sends the source and destination flash devices via this command. Upon receiving this command the SC:

1. Copies the sector contents from the source device into 64 Kbyte SRAM within SC FW.

2. Checks the CRC.

3. Copies the contents into the destination device, checks the CRC, and updates the sector sequence number.

4. If failure occurs in the middle of copy, erase all sectors in destination device (no retry support).

5. If the CRC is copied successfully, proceed with next sector.

6. The BMC can obtain the status of the copy from the FLASH\_COPY\_FIRMWARE\_STATUS command.

**Note:** If the BMC sends another copy command while the previous copy is in-progress, the SC will ignore the request and respond appropriate error code. The BMC must check the status via the COPY\_FIRMWARE\_STATUS command and re-trigger. This command is currently supported only for Alveo U30.

*Table:* **FPGA\_COPY\_FIRMWARE Server BMC Request**

+--------------+-------------------------------------------------+
|     **Server BMC Request**                                     |
+==============+=================================================+
| Command code | 0x4A                                            |
+--------------+-------------------------------------------------+
| Byte0        | B0 – Source flash device:                       |
|              |                                                 |
|              | 0x01 - FPGA1 Primary flash device               |
|              |                                                 |
|              | 0x02 - FPGA1 Recovery flash device              |
|              |                                                 |
|              | 0x03 - FPGA2 Primary flash device               |
|              |                                                 |
|              | 0x04 - FPGA2 Recovery flash device              |
+--------------+-------------------------------------------------+
| Byte1        | B1 – Destination flash device:                  |
|              |                                                 |
|              | 0x01 - FPGA1 Primary flash device               |
|              |                                                 |
|              | 0x02 - FPGA1 Recovery flash device              |
|              |                                                 |
|              | 0x03 - FPGA2 Primary flash device               |
|              |                                                 |
|              | 0x04 - FPGA2 Recovery flash device              |
+--------------+-------------------------------------------------+

*Table:* **FPGA\_COPY\_FIRMWARE Xilinx Alveo Card Response**

+-------------+------+----------------------------------------------------------------+
| **Xilinx Alveo Card Response**                                                      |
+=============+======+================================================================+
| Data bytes  | B0   | See table 'Flash Operation Return Codes' for SC's response     |
+-------------+------+----------------------------------------------------------------+

0x4B - FPGA\_GET\_FIRMWARE\_STATUS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The BMC sends the FPGA\_GET\_FIRMWARE\_STATUS command to obtain the status of the previously triggered commands like
FLASH\_BLOCK\_CRC\_CHECK and/or FLASH\_COPY\_FIRMWARE commands.

*Table:* **FPGA\_GET\_FIRMWARE\_STATUS Server BMC request**

+---------------+--------+
| **Server BMC Request** |
+===============+========+
| Command code  | 0x4B   |
+---------------+--------+
| Byte0         | N/A    |
+---------------+--------+

*Table:* **FPGA\_GET\_FIRMWARE\_STATUS Xilinx Alveo Card Response**

+-------------+------+----------------------------------------------------------------+
| **Xilinx Alveo Card Response**                                                      |
+=============+======+================================================================+
| Data bytes  | B0   | See table 'Flash Operation Return Codes' for SC's response     |
+-------------+------+----------------------------------------------------------------+

0x4C - FPGA\_SET\_KEY\_NONCE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

BMC provides the SC with a randomly generated key and nonce. The SC writes the 16-byte AES128 key and 96-bit (12-byte) nonce value to the Non-volatile memory. The SC provisions storage for one key and one nonce per flash device (non-volatile memory). 

SC uses 15-byte nonce, by padding 3 bytes (with 0x00) at the start, to the 12-byte nonce sent by BMC (i.e.) LSB 3 bytes are 0x00. In other words, Bytes[14-3] are the 12-bytes of nonce sent by BMC and Bytes[2-0] are 0x00 0x00 0x00. 

BMC must use the exact nonce scheme to calculate the MAC value for comparison. The BMC is expected to select the target flash device.

*Table:* **FPGA\_SET\_KEY\_NONCE Server BMC Request**

+--------------+-------------------------------------------------+
|     **Server BMC Request**                                     |
+==============+=================================================+
| Command code | 0x4C                                            |
+--------------+-------------------------------------------------+
| Byte0        | B0 – Target flash device:                       |
|              |                                                 |
|              | 0x01 - FPGA1 Primary flash device               |
|              |                                                 |
|              | 0x02 - FPGA1 Recovery flash device              |
|              |                                                 |
|              | 0x03 - FPGA2 Primary flash device               |
|              |                                                 |
|              | 0x04 - FPGA2 Recovery flash device              |
+--------------+-------------------------------------------------+
| Byte1 -16    | 16-byte key                                     |
+--------------+-------------------------------------------------+
| Byte17 - 28  | 12-byte nonce                                   |
+--------------+-------------------------------------------------+

*Table:* **FPGA\_SET\_KEY\_NONCE Xilinx Alveo Card Response**

+-------------+------+----------------------------------------------------------------+
| **Xilinx Alveo Card Response**                                                      |
+=============+======+================================================================+
| Data bytes  | B0   | See table 'Flash Operation Return Codes' for SC's response     |
+-------------+------+----------------------------------------------------------------+

0x4D - FPGA\_CALC\_MAC
~~~~~~~~~~~~~~~~~~~~~~

**Note:** This command is optional. If sent, this command must be preceded by FPGA\_SET\_KEY\_NONCE. This command is only supported in Alveo U30

The BMC is expected to call the FPGA\_CALC\_MAC command after the entire flash image is written. The BMC is expected to select the target flash device. Upon receiving the command 0x4D, SC increments the stored nonce by 1, calculates the MAC of the entire 128 MByte region of the FPGA flash device, using the existing key and the new nonce. The calculated MAC/HASH value is returned to BMC via the status command 0x4F. SC does not store the MAC/HASH value in Non-volatile memory.


*Table:* **FPGA\_CALC\_MAC Server BMC Request**

+--------------+-------------------------------------------------+
|     **Server BMC Request**                                     |
+==============+=================================================+
| Command code | 0x4D                                            |
+--------------+-------------------------------------------------+
| Byte0        | B0 – Target flash device:                       |
|              |                                                 |
|              | 0x01 - FPGA1 Primary flash device               |
|              |                                                 |
|              | 0x02 - FPGA1 Recovery flash device              |
|              |                                                 |
|              | 0x03 - FPGA2 Primary flash device               |
|              |                                                 |
|              | 0x04 - FPGA2 Recovery flash device              |
+--------------+-------------------------------------------------+


*Table:* **FPGA\_CALC\_MAC Xilinx Alveo Card Response**

+-------------+------+----------------------------------------------------------------+
| **Xilinx Alveo Card Response**                                                      |
+=============+======+================================================================+
| Data bytes  | B0   | See table 'Flash Operation Return Codes' for SC's response     |
+-------------+------+----------------------------------------------------------------+

0x4E - FPGA\_VERIFY\_MAC
~~~~~~~~~~~~~~~~~~~~~~~~

**NOTE:** This command must be preceded by FPGA\_SET\_KEY\_NONCE. This command is supported only in Alveo U30.

The BMC sends the FPGA\_VERIFY\_MAC command to validate the FPGA flash image. The SC calculates the MAC/HASH of the entire 128 MByte region using the existing key and existing nonce value. The calculated MAC/HASH value is returned to BMC via the status command 0x4F. SC does not store the MAC/HASH value in Non-volatile memory.

*Table:* **FPGA\_VERIFY\_MAC Server BMC Request**

+--------------+-------------------------------------------------+
|     **Server BMC Request**                                     |
+==============+=================================================+
| Command code | 0x4E                                            |
+--------------+-------------------------------------------------+
| Byte0        | B0 – Target flash device:                       |
|              |                                                 |
|              | 0x01 - FPGA1 Primary flash device               |
|              |                                                 |
|              | 0x02 - FPGA1 Recovery flash device              |
|              |                                                 |
|              | 0x03 - FPGA2 Primary flash device               |
|              |                                                 |
|              | 0x04 - FPGA2 Recovery flash device              |
+--------------+-------------------------------------------------+

*Table:* **FPGA\_VERIFY\_MAC Xilinx Alveo Card Response**

+-------------+------+----------------------------------------------------------------+
| **Xilinx Alveo Card Response**                                                      |
+=============+======+================================================================+
| Data bytes  | B0   | See table 'Flash Operation Return Codes' for SC's response     |
+-------------+------+----------------------------------------------------------------+

0x4F - FPGA\_GET\_MAC\_STATUS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This command is only supported in Alveo U30 card. The BMC sends the FPGA\_GET\_MAC\_STATUS command to get the
status of FPGA\_CALC\_MAC or FPGA\_VERIFY\_MAC command. SC responds with the status of MAC/HASH calculation or
verification (Byte 0) and 16-byte MAC/HASH value (Bytes 1-17) as response.

**Note:** Server BMC must use the same key and nonce that the satellite controller used to compute the MAC/HASH value to obtain same results. Refer 0x4C and 0x4D command description for details.

*Table:* **FPGA\_GET\_MAC\_STATUS Server BMC Request**

+--------------+-------------------------------------------------+
|     **Server BMC Request**                                     |
+==============+=================================================+
| Command code | 0x4F                                            |
+--------------+-------------------------------------------------+
| Byte0        | 0x01 - FPGA1 Primary flash device               |
|              |                                                 |
|              | 0x02 - FPGA1 Recovery flash device              |
|              |                                                 |
|              | 0x03 - FPGA2 Primary flash device               |
|              |                                                 |
|              | 0x04 - FPGA2 Recovery flash device              |
+--------------+-------------------------------------------------+
| Byte1        | 0x01 – Get FPGA\_CALC\_MAC status               |
|              |                                                 |
|              | 0x02 – Get FPGA\_VERIFY\_MAC status             |
+--------------+-------------------------------------------------+

*Table:* **FPGA\_GET\_MAC\_STATUS Xilinx Alveo Card Response**

+-------------+--------------+------------------------------------------------------------+
| **Xilinx Alveo Card Response**                                                          |
+=============+==============+============================================================+
| Data bytes  | B0           | See table 'Flash Operation Return Codes' for SC's response |
+-------------+--------------+------------------------------------------------------------+
|             | Bytes 1 - 16 | 16 Byte MAC value (LSB first)                              |
+-------------+--------------+------------------------------------------------------------+

0x50 - FPGA\_SET\_IMAGE\_SIZE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Optionally, BMC can send the command 0x50 to notify SC about the size of the FPGA image that it indents to update. The byte-0 selects the target FPGA flash device and the byte1 – byte 4 (4 bytes, unsigned, LSB first) represents the size of flash image in bytes.

**NOTE:** On boot-up, SC restores the image size to default 128 MBytes to address entire flash memory.

*Table:* **FPGA\_SET\_IMAGE\_SIZE server BMC request**

+--------------+-------------------------------------------------+
|     **Server BMC request**                                     |
+==============+=================================================+
| Command code | 0x50                                            |
+--------------+-------------------------------------------------+
| Byte0        | 0x01 - FPGA1 Primary flash device               |
|              |                                                 |
|              | 0x02 - FPGA1 Recovery flash device              |
|              |                                                 |
|              | 0x03 - FPGA2 Primary flash device               |
|              |                                                 |
|              | 0x04 - FPGA2 Recovery flash device              |
+--------------+-------------------------------------------------+
| Byte 1-4     | Size of QSPI image (in bytes)                   |
+--------------+-------------------------------------------------+

*Table:* **FPGA\_SET\_IMAGE\_SIZE Xilinx Alveo Card Response**

+-------------+------+----------------------------------------------------------------+
| **Xilinx Alveo Card Response**                                                      |
+=============+======+================================================================+
| Data bytes  | B0   | See table 'Flash Operation Return Codes' for SC's response     |
+-------------+------+----------------------------------------------------------------+

0x51 - NOTIFY\_WP\_TO\_FPGA
~~~~~~~~~~~~~~~~~~~~~~~~~~~

BMC sends this command to request SC to notify the FPGA device about WP status of the flash device. In turn, SC communicates the flash device WP status to FPGA via UART messages. BMC shall send this command prior to initiating the in-band QSPI FW update so that host OS can read the WP status from PCIe BAR config space.

*Table:* **NOTIFY\_WP\_TO\_FPGA server BMC request**

+--------------+-------------------------------------------------+
|     **Server BMC request**                                     |
+==============+=================================================+
| Command code | 0x51                                            |
+--------------+-------------------------------------------------+
| Byte0        | 0x01 - FPGA1 Primary flash device               |
|              |                                                 |
|              | 0x02 - FPGA1 Recovery flash device              |
|              |                                                 |
|              | 0x03 - FPGA2 Primary flash device               |
|              |                                                 |
|              | 0x04 - FPGA2 Recovery flash device              |
+--------------+-------------------------------------------------+


*Table:* **NOTIFY\_WP\_TO\_FPGA Xilinx Alveo Card Response**

+-------------+------+---------------------------+
| **Xilinx Alveo Card Response**                 |
+=============+======+===========================+
| Data bytes  | B0   | 0x01: Operation Success   |
|             |      |                           |
|             |      | 0x02: Operation failure   |
+-------------+------+---------------------------+


0x52 - FPGA\_UART\_DEBUG\_CONTROL
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

BMC sends this command to FPGA to enable/disable the debug UART. SC communicates this information to the respective ZYNQ/FPGA device. By default, the debug UART is disabled during production settings and it can optionally be enabled for debug purposes. 

*Table:* **FPGA\_UART\_DEBUG\_CONTROL server BMC request**

+--------------+----------------+
|     **Server BMC request**    |
+==============+================+
| Command code | 0x52           |
+--------------+----------------+
| Byte0        | 0x01 - FPGA1   |
|              |                |
|              | 0x02 - FPGA2   |
+--------------+----------------+


*Table:* **FPGA\_UART\_DEBUG\_CONTROL Xilinx Alveo Card Response**

+-------------+------+-----------------------------+
| **Xilinx Alveo Card Response**                   |
+=============+======+=============================+
| Data bytes  | B0   | 0x01: Operation Success     |
|             |      |                             |
|             |      | 0x02: Operation failure     |
|             |      |                             |
|             |      | 0x03: Operation unsupported |
+-------------+------+-----------------------------+


*Table:* **FPGA\_SET\_FLASH\_READBACK\_DEVICE Xilinx Alveo Card Response**

+-------------+------+----------------------------------------------------------------+
| **Xilinx Alveo Card Response**                                                      |
+=============+======+================================================================+
| Data bytes  | B0   | See table 'Flash Operation Return Codes' for SC's response     |
+-------------+------+----------------------------------------------------------------+


0x53 - SET\_FPGA\_FLASH\_READBACK\_SECTOR\_RANGE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

BMC sends this command to set the start and end sectors for the FPGA flash content read-back. The range is between sectors 0 and 2047. SC fetches 1 sector at a time from FPGA flash device and transfers it to BMC via command 0x54.

*Table:* **SET\_FPGA\_FLASH\_READBACK\_SECTOR\_RANGE server BMC request**

+--------------+-------------------------------------------------+
|     **Server BMC request**                                     |
+==============+=================================================+
| Command code | 0x53                                            |
+--------------+-------------------------------------------------+
| Byte0        | Start sector number (low byte)                  |
+--------------+-------------------------------------------------+
| Byte1        | Start sector number (high byte)                 |
+--------------+-------------------------------------------------+
| Byte2        | End sector number (low byte)                    |
+--------------+-------------------------------------------------+
| Byte3        | End sector number (high byte)                   |
+--------------+-------------------------------------------------+


*Table:* **SET\_FPGA\_FLASH\_READBACK\_SECTOR\_RANGE Xilinx Alveo Card Response**

+-------------+------+----------------------------------------------------------------+
| **Xilinx Alveo Card Response**                                                      |
+=============+======+================================================================+
| Data bytes  | B0   | See table 'Flash Operation Return Codes' for SC's response     |
+-------------+------+----------------------------------------------------------------+


0x54 - FPGA\_FLASH\_TX\_DATA\_BLOCK
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

BMC sends this command in repeated-start mode to fetch the data from FPGA flash. Before sending the command 0x54, BMC needs to send the commands in sequence (i.e.) command 0x42 (set target device), command 0x53 (set sectors) and command 0x4B (poll the status).

- Upon requested, SC will read 1 sector (64 KB) from FPGA flash device, compares the CRC before signaling BMC about read-back readiness (via 0x4B command)

- After SC is ready with the payload, BMC can send the read-back command in repeated-start mode to fetch 1 sector of data. The maximum bytes sent per transaction is limited to 252 bytes.

- After successfully receiving 64 KB payload, BMC needs to poll the status command 0x4B (SC's readiness for next sector) before proceeding to issue read-back command 0x54 for the next sector

- No retry is supported in case of any failure/interruption in the middle of sector read-back.  But BMC can send the command 0x49 to force set the start sector from which it wants to resume/retry the read-back operation

- Upon receiving the updated start sector number (via 0x49 command), SC starts the read-back process from the beginning of the sector. Once again, BMC needs to follow the same sequence of commands (i.e.) poll the status command 0x4B before issuing 0x54.


*Table:* **FPGA\_FLASH\_TX\_DATA\_BLOCK server BMC request**

+--------------+-------------------------------------------------+
|     **Server BMC request**                                     |
+==============+=================================================+
| Command code | 0x54                                            |
+--------------+-------------------------------------------------+
| Byte0        | BMC sends repeated-start I2C command            |
+--------------+-------------------------------------------------+

*Table:* **FPGA\_FLASH\_TX\_DATA\_BLOCK Xilinx Alveo Card Response**

+-------------+-----------------+-----------------------------+
| **Xilinx Alveo Card Response**                              |
+=============+=================+=============================+
| Data bytes  | D0, D1 ... D251 | SC sends 252 data bytes     |
+-------------+-----------------+-----------------------------+


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

	<p align="center"><sup>XD038 | &copy; Copyright 2021 Xilinx, Inc.</sup></p>
