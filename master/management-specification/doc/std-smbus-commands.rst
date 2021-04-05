I2C/SMBus Commands
------------------

Xilinx® Alveo™ cards support OoB communication via Standard I2C/SMBus commands at I2C address 0x65 (0xCA in 8-bit). While 100 KHz and 400 KHz are standard among Server BMCs, I2C speeds between 90 KHz and 700 KHz are tested and supported by Satellite Controller. 

The following table lists the supported commands:

**Table: Supported I2C/SMBus Commands**

+----------------------------+---------------------------------+----------------------+--------------------------+
| **Command/Register Value** | **Command Description**         | **Transaction Type** | **Number of Resp Bytes** |
+============================+=================================+======================+==========================+
|   0x01                     | Maximum DIMM temperature        |     Read byte        |     1                    |
+----------------------------+---------------------------------+----------------------+--------------------------+
|   0x02                     | Maximum card temperature        |     Read byte        |     1                    |
+----------------------------+---------------------------------+----------------------+--------------------------+
|   0x03                     | Card power consumption          |     Read word        |     2                    |
+----------------------------+---------------------------------+----------------------+--------------------------+
|   0x04                     | Satellite Controller FW version |     Block read       |     4                    |
+----------------------------+---------------------------------+----------------------+--------------------------+
|   0x05                     | Maximum FPGA die temperature    |     Read byte        |     1                    |
+----------------------------+---------------------------------+----------------------+--------------------------+
|   0x06                     | Maximum QSFP temperature        |     Read byte        |     1                    |
+----------------------------+---------------------------------+----------------------+--------------------------+
|   0x0F                     | FPGA Reset                      |     Write byte       |     1                    |
+----------------------------+---------------------------------+----------------------+--------------------------+
|   0x20                     | Critical Sensor Data Record     |     Block read       |     64                   |
+----------------------------+---------------------------------+----------------------+--------------------------+


**Note:** Xilinx recommends waiting for 1–2 ms between any two I2C
transactions. Without the delay, uninterrupted I2C operation isn’t
guaranteed.


0x01–Maximum DIMM Temperature
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Note:** Not applicable for U30 cards.

The DIMMs in the Alveo™ cards with the number varying with each
model. The primary motivation for server BMC to read the DIMM
temperature is to provide closed-loop thermal monitoring. The best
way to expose the DIMM temperature is to provide maximum value of
all the DIMM temperature values. SC FW keeps track of
temperature values internally for all the DIMMs present in the Alveo
card, exposing only the maximum DIMM temperature value to
server BMC. Server BMC uses command code 0x01 to read the max the
DIMM temperature value. The response data from the Xilinx FPGA card
is 1-byte temperature data (twos complement) and the range is -128°C
to 127°C.

**Table: Maximum DIMM, Server BMC Request**

+--------------------------------+------------+
|     **Server BMC Request**                  |
+================================+============+
| Command code                   |     0x01   |
+--------------------------------+------------+
| Data bytes                     |     N/A    |
+--------------------------------+------------+

**Table: Maximum DIMM, Xilinx Alveo Card Response**

+------------+----------------+-------------------------------------------------------------+
| ** Xilinx Alveo™ Card Response **                                                         |
+============+================+=============================================================+
| Data bytes |     [Byte 0]   | 1-byte temperature data (2’s complement) and                |
|            |                |                                                             |
|            |                | the range is -128 °C to 127 °C                              |
|            |                |                                                             |
|            |                | For example:                                                |
|            |                |                                                             |
|            |                | [Byte 0] = 0xFE presents –2°C                               |
|            |                |                                                             |
|            |                | [Byte 0] = 0x23 presents 35°C                               |
+------------+----------------+-------------------------------------------------------------+

0x02–Maximum Board Temperature
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Server BMC uses register 0x02 to read the maximum board temperature
value. The response data from the Xilinx Alveo™ card is 1-byte
temperature data (twos complement) and the range is -128°C to 127°C.

**Table: Maximum Board Temperature, Server BMC Request**

+--------------------------------+------------+
|     **Server BMC Request**                  |
+================================+============+
| Command code                   |     0x02   |
+--------------------------------+------------+
| Data bytes                     |     N/A    |
+--------------------------------+------------+

**Table: Maximum Board Temperature, Xilinx Alveo Card Response**

+------------+----------------+-------------------------------------------------------------+
| ** Xilinx Alveo™ Card Response **                                                         |
+============+================+=============================================================+
| Data bytes |     [Byte 0]   | 1-byte temperature data (twos complement) and               |
|            |                |                                                             |
|            |                | the range is -128°C to 127°C                                |
|            |                |                                                             |
|            |                | For example:                                                |
|            |                |                                                             |
|            |                | [Byte 0] = 0xFE presents -2°C                               |
|            |                |                                                             |
|            |                | [Byte 0] = 0x23 presents 35°C                               |
+------------+----------------+-------------------------------------------------------------+

0x03–Board Power Consumption
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Server BMC uses register 0x03 to read the current board power
consumption value. The response data from the Xilinx Alveo™ card is
2-byte power consumption data (LSB first), unit is in watts (W).

**Table: Board Power Consumption, Server BMC Request**

+--------------------------------+------------+
|     **Server BMC Request**                  |
+================================+============+
| Command code                   |     0x03   |
+--------------------------------+------------+
| Data bytes                     |     N/A    |
+--------------------------------+------------+

**Table: Board Power Consumption, Xilinx Alveo Card Response**

+------------+----------------+-------------------------------------------------------------+
| ** Xilinx Alveo™ Card Response **                                                         |
+============+================+=============================================================+
| Data bytes |     [Byte 0]   |     2-byte temperature data in watts (W). For example:      |
|            |                |                                                             |
|            |                |     [Byte 0] [Byte 1] = 0x32 0x00 presents 50W (0x0032)     |
|            |                |                                                             |
|            |                |     [Byte 0] [Byte 1] = 0x20 0x01 presents 288W (0x0120)    |
+------------+----------------+-------------------------------------------------------------+

0x04–Satellite Controller Firmware Version
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Server BMC uses register 0x04 to read the current SC FW version,
which follows xx.yy.zz formatting. The response data from the Xilinx
Alveo™ card is 4 bytes.

**Table:  SC Firmware Version, Server BMC Request**


+--------------------------------+------------+
|     **Server BMC Request**                  |
+================================+============+
| Command code                   |     0x04   |
+--------------------------------+------------+
| Data bytes                     |     N/A    |
+--------------------------------+------------+

**Table:  SC Firmware Version, Xilinx Alveo Card Response**

+------------+----------------+-------------------------------------------------------------+
| ** Xilinx Alveo™ Card Response **                                                         |
+============+================+=============================================================+
| Data bytes |     [Byte 0]   | 4-byte firmware version – LSB first                         |
|            |                |                                                             |
|            |     [Byte 1]   | [Byte 0] – Firmware version ; [Byte 1] – Major revision     |
|            |                |                                                             |
|            |     [Byte 2]   | [Byte 2] – Minor revision ; [Byte 3] - Reserved             |
|            |                |                                                             |
|            |     [Byte 3]   | For example:                                                |
|            |                |                                                             |
|            |                | v6.2.11 = 0x00 0x0B 0x02 0x06                               |
|            |                |                                                             |
|            |                | v7.13.9 = 0x00 0x09 0x0D 0x07                               |
+------------+----------------+-------------------------------------------------------------+


0x05–Maximum FPGA Die Temperature
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Server BMC uses register 0x05 to read the maximum FPGA die temperature
value. The response data from the Xilinx Alveo™ card is 1-byte
temperature data (twos complement) and the range is -128°C to 127°C.

**Table: FPGA Die Temperature**

+--------------------------------+------------+
|     **Server BMC Request**                  |
+================================+============+
| Command code                   |     0x05   |
+--------------------------------+------------+
| Data bytes                     |     N/A    |
+--------------------------------+------------+

**Table: Max FPGA die Temperature, Xilinx Alveo Card Response**

+------------+----------------+-------------------------------------------------------------+
| ** Xilinx Alveo™ Card Response **                                                         |
+============+================+=============================================================+
| Data bytes |     [Byte 0]   | 1-byte temperature data (twos complement) and               |
|            |                |                                                             |
|            |                |  the range is -128 to 127°C.                                |
|            |                |                                                             |
|            |                | For example:                                                |
|            |                |                                                             |
|            |                | [Byte 0] = 0xFE presents -2°C                               |
|            |                |                                                             |
|            |                | [Byte 0] = 0x23 presents 35°C                               |
+------------+----------------+-------------------------------------------------------------+

0x06–Maximum QSFP Temperature
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Note:** Not applicable for U30 cards.

The Alveo™ card comes with network interface (i.e., QSFP or SFP-DD)
modules. The number of SFP modules varies depending on the model.
The primary incentive for server BMC to read the SFP temperature is
to provide closed-loop thermal monitoring. The most effective way to
expose the SFP temperature is to provide the maximum value of all
the SFP temperature values.

MSP432 FW internally tracks temperature values for all the SFP
modules present in an Alveo™ card, exposing only the maximum SFP
temperature value to server BMC.

Server BMC uses register 0x06 to read the maximum QSFP temperature
value. The response data from the Xilinx FPGA card is 1-byte
temperature data (twos complement) and the range is -128°C to 127°C.

**Table: Maximum QSFP Temperature, Server BMC Request**

+--------------------------------+------------+
|     **Server BMC Request**                  |
+================================+============+
| Command code                   |     0x06   |
+--------------------------------+------------+
| Data bytes                     |     N/A    |
+--------------------------------+------------+

**Table: Maximum QSFP Temperature, Xilinx Alveo Card Response**

+------------+----------------+-------------------------------------------------------------+
| ** Xilinx Alveo™ Card Response **                                                         |
+============+================+=============================================================+
| Data bytes |     [Byte 0]   | 1-byte temperature data (twos complement) and               |
|            |                |                                                             |
|            |                | the range is -128°C to 127°C.                               |
|            |                |                                                             |
|            |                | For example:                                                |
|            |                |                                                             |
|            |                | [Byte 0] = 0xFE presents -2°C                               |
|            |                |                                                             |
|            |                | [Byte 0] = 0x23 presents 35°C                               |
+------------+----------------+-------------------------------------------------------------+

0x0F–Reset FPGA
~~~~~~~~~~~~~~~

A reset of the FPGA through the out-of-band channel is a desirable operation to bring the FPGA
out of any stuck condition (i.e., PCIe link down, FPGA lock-up, user workload corruption/hang)
leaving any in-band operation ineffective. Server BMC uses register 0x0F to request the reset of
the FPGA. Wherever applicable, SC has the capability to reset the FPGA. This feature/option may not be available in all products and when supported, SC firmware responds with the status 0x01 immediately and runs the operation in the background.

**Table: Reset FPGA server BMC request**

+----------------+-------------------------------------------+
|     **Server BMC Request**                                 |
+================+===========================================+
| Command code   | 0x0F                                      |
+----------------+-------------------------------------------+
| Data bytes     | B0: 0x01 - Cold reset;  0x02 - Warm reset |
+----------------+-------------------------------------------+

**Table: Reset FPGA, Xilinx Alveo Card Response**

+------------+----------------+-------------------------------------------------------------+
| ** Xilinx Alveo™ Card Response **                                                         |
+============+================+=============================================================+
| Data bytes |     [Byte 0]   | 0x01 - FPGA reset initiated                                 |
|            |                |                                                             |
|            |                | 0x02 - Request failed                                       |
|            |                |                                                             |
|            |                | 0x03 - Operation not supported                              |
+------------+----------------+-------------------------------------------------------------+

0x20–Critical Sensor Data Record (CSDR) Command
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Note:** Currently, this command is only supported in Alveo™ U30 cards.

The CSDR command implementation is Block Read from server BMC’s perspective and SC sends the data LSB first (i.e.) Byte 0, Byte 1 ... Byte 63 order. 

See Block Read command from :ref:`I2C/SMBus Implementation and Protocol Recap` for more details. 

The following sensor information are packaged into the SDR response (64 bytes): 

-  Status: Contains TCRIT, PG, ZYNQ error and other status information.

-  Temperature: FPGA, inlet, and outlet sensors.

-  Total power consumption: 3V3 I/V, 12V I/V, 12VAUX I/V.

-  DDR errors: Recoverable and non-recoverable errors.

-  PCIe errors: Recoverable and non-recoverable errors.

-  Network status and temperature, if applicable.

**Table: CSDR Command**

+----------------+----------------------+------------------------------------------+-----------------+
| **Offset**     | **Number of Bytes**  | **Register Description**                 | **Notes**       |
+================+======================+==========================================+=================+
| 0              |     4                | Board status information                 |                 |
+----------------+----------------------+------------------------------------------+-----------------+
| 4              |     4                | Board security status information        |                 |
+----------------+----------------------+------------------------------------------+-----------------+
| 8              |     1                | Board inlet temperature                  |                 |
+----------------+----------------------+------------------------------------------+-----------------+
| 9              |     1                | Board outlet temperature                 |                 |
+----------------+----------------------+------------------------------------------+-----------------+
| 10             |     4                | Board edge connector 3.3V input sensor   |                 |
+----------------+----------------------+------------------------------------------+-----------------+
| 14             |     4                | Board edge connector 12V input sensor    |                 |
+----------------+----------------------+------------------------------------------+-----------------+
| 18             |     4                | Board AUX connector 12V input sensor     |                 |
+----------------+----------------------+------------------------------------------+-----------------+
| 22             |     2                | Board total power consumption            |                 |
+----------------+----------------------+------------------------------------------+-----------------+
| 24             |     1                | Device 1 status information              |                 |
+----------------+----------------------+------------------------------------------+-----------------+
| 25             |     2                | Device 1 junction temperature            |                 |
+----------------+----------------------+------------------------------------------+-----------------+
| 27             |     10               | Device 1 advanced error counters         |                 |
+----------------+----------------------+------------------------------------------+-----------------+
| 37             |     1                | Device 2 status information              |                 |
+----------------+----------------------+------------------------------------------+-----------------+
| 38             |     2                | Device 2 junction temperature            |                 |
+----------------+----------------------+------------------------------------------+-----------------+
| 40             |     10               | Device 2 advanced error counters         |                 |
+----------------+----------------------+------------------------------------------+-----------------+
| 50             |     1                | Network module 0 temperature             | N/A for U30     |
+----------------+----------------------+------------------------------------------+-----------------+
| 51             |     2                | Network module 0 status                  | N/A for U30     |
+----------------+----------------------+------------------------------------------+-----------------+
| 53             |     1                | Network module 1 temperature             | N/A for U30     |
+----------------+----------------------+------------------------------------------+-----------------+
| 54             |     2                | Network module 1 status                  | N/A for U30     |
+----------------+----------------------+------------------------------------------+-----------------+
| 56             |     8                | Reserved                                 |                 |
+----------------+----------------------+------------------------------------------+-----------------+

Critical Sensor Data Record (CSDR) Command Response
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Table: Board Status Information**

+---------------+----------------------------------+---------------------+----------------------------------+
| **Bit Field** | **Bit Field Mapping**            | **Data Format**     | **Sensor Description**           |
+===============+==================================+=====================+==================================+
| Bit[31:19]    | Reserved                         |     N/A             |     N/A                          |
+---------------+----------------------------------+---------------------+----------------------------------+
| Bit[18]       | AUX power cable present          | 1-bit unsigned;     | 0 – No AUX power cable           |
|               |                                  |                     |                                  |
|               |                                  | Unit: state         | 1 – AUX cable present            |
|               |                                  |                     |                                  |
+---------------+----------------------------------+---------------------+----------------------------------+
| Bit[17]       | Network module 1 MODPRSNT        | 1-bit unsigned;     | 0 – Not present                  |
|               |                                  |                     |                                  |
|               |                                  | Unit: state         | 1 – Present                      |
|               |                                  |                     |                                  |
+---------------+----------------------------------+---------------------+----------------------------------+
| Bit[16]       | Network module 0 MODPRSNT        | 1-bit unsigned;     | 0 – Not present                  |
|               |                                  |                     |                                  |
|               |                                  | Unit: state         | 1 – Present                      |
|               |                                  |                     |                                  |
+---------------+----------------------------------+---------------------+----------------------------------+
| Bit[15:12]    | HBM\_CATTRIP event counter       | 4-bits unsigned;    | Number of HBM CATTRIP events,    |
|               |                                  |                     |                                  |
|               |                                  | Unit: count         | after SC code update             |
|               |                                  |                     |                                  |
+---------------+----------------------------------+---------------------+----------------------------------+
| Bit[11:8]     | TWARN event counter              | 4-bits unsigned;    | Number of TWARN events,          |
|               |                                  |                     |                                  |
|               |                                  | Unit: count         | after SC power up.               |
|               |                                  |                     |                                  |
+---------------+----------------------------------+---------------------+----------------------------------+
| Bit[7:4]      | Power good event counter         | 4-bits unsigned;    | Number of power good events,     |
|               |                                  |                     |                                  |
|               |                                  | Unit: count         | after SC power up.               |
|               |                                  |                     |                                  |
+---------------+----------------------------------+---------------------+----------------------------------+
| Bit[3:0]      | TCRIT event counter              | 4-bits unsigned;    | Number of TCRIT events,          |
|               |                                  |                     |                                  |
|               |                                  | Unit: count         | after SC power up.               |
|               |                                  |                     |                                  |
+---------------+----------------------------------+---------------------+----------------------------------+

**Table: Board Security Status Information**

+---------------+----------------------------------+---------------------+---------------------------------------------+
| **Bit Field** | **Bit Field Mapping**            | **Data Format**     | **Sensor Description**                      |
+===============+==================================+=====================+=============================================+
| Bit[31:16]    | Reserved                         |                     |                                             |
+---------------+----------------------------------+---------------------+---------------------------------------------+
| Bit[15]       | JTAG Access                      | 1-bit unsigned;     | 0: Disabled                                 |
|               |                                  |                     |                                             |
|               |                                  | Unit: state         | 1: Enabled                                  |
|               |                                  |                     |                                             |
+---------------+----------------------------------+---------------------+---------------------------------------------+
| Bit[14:11]    | Flash authentication status      | 4-bit unsigned;     | State: 0=NOT DONE, 1=DONE                   |
|               |                                  |                     |                                             |
|               |                                  | Unit: state         | Bit 14: FPGA2 Recovery flash device         |
|               |                                  |                     |                                             |
|               |                                  |                     | Bit 13: FPGA2 Primary flash device          |
|               |                                  |                     |                                             |
|               |                                  |                     | Bit 12: FPGA1 Recovery flash device         |
|               |                                  |                     |                                             |
|               |                                  |                     | Bit 11: FPGA1 Primary flash device          |
|               |                                  |                     |                                             |
+---------------+----------------------------------+---------------------+---------------------------------------------+
| Bit[10]       | SC\_SPI\_DEV2\_CTRL5             | NA                  | Reserved                                    |
+---------------+----------------------------------+---------------------+---------------------------------------------+
| Bit[9]        | SC\_SPI\_DEV2\_CTRL4             | 1-bit unsigned;     | For flash control modes 2b'00 and 2b'10:    |
|               |                                  |                     |                                             |
|               |                                  | Unit: state         | 0: Flash write protect                      |
|               |                                  |                     |                                             |
|               |                                  |                     | 1: Flash write enable                       |
|               |                                  |                     |                                             |
+---------------+----------------------------------+---------------------+---------------------------------------------+
| Bit[8:7]      | SC\_SPI\_DEV2\_CTRL3,1           | 2-bit unsigned;     | 2b'00: DEV2 x2 with WP; 2b'10 DEV2 x4 no WP |
|               |                                  |                     |                                             |
|               | Dev flash mode control           | Unit: state         | 2b‘01: SC x1 with WP; 2b‘11 Not Valid       |
|               |                                  |                     |                                             |
+---------------+----------------------------------+---------------------+---------------------------------------------+
| Bit[6]        | SC\_SPI\_DEV2\_CTRL2             | 1-bit unsigned;     | 0: DEV2 primary flash selected              |
|               |                                  |                     |                                             |
|               | Primary/Recovery flash selected  | Unit: state         | 1: DEV2 recovery flash selected             |
|               |                                  |                     |                                             |
+---------------+----------------------------------+---------------------+---------------------------------------------+
| Bit[5]        | SC\_SPI\_DEV1\_CTRL5             | NA                  | Reserved                                    |
+---------------+----------------------------------+---------------------+---------------------------------------------+
| Bit[4]        | SC\_SPI\_DEV1\_CTRL4             | 1-bit unsigned      | For Flash Control Modes 2b'00 and 2b'10:    |
|               |                                  |                     |                                             |
|               |                                  | Unit: state         | 0: Flash Write Protect                      |
|               |                                  |                     |                                             |
|               |                                  |                     | 1: Flash Write Enable                       |
|               |                                  |                     |                                             |
+---------------+----------------------------------+---------------------+---------------------------------------------+
| Bit[3:2]      | SC\_SPI\_DEV1\_CTRL3,1           | 2-bit unsigned;     | 2b'00: DEV1 x2 with WP; 2b'10 DEV1 x4 no WP |
|               |                                  |                     |                                             |
|               | Dev flash mode control           | Unit: state         | 2b‘01: SC x1 with WP; 2b‘11 Not Valid       |
|               |                                  |                     |                                             |
+---------------+----------------------------------+---------------------+---------------------------------------------+
| Bit[1]        | SC\_SPI\_DEV1\_CTRL2             | 1-bit unsigned;     | 0: DEV1 primary flash selected              |
|               |                                  |                     |                                             |
|               | Primary/Recovery flash selected  | Unit: state         | 1: DEV1 recovery flash selected             |
|               |                                  |                     |                                             |
+---------------+----------------------------------+---------------------+---------------------------------------------+
| Bit[0]        | SC\_SPI\_DEV\_SEL; Connects      | 1-bit unsigned;     | 0: SC to DEV1 SPI                           |
|               |                                  |                     |                                             |
|               | SC to SPI MUX of Dev 1 or Dev 2  | Unit: state         | 1: SC to DEV2 SPI                           |
|               |                                  |                     |                                             |
+---------------+----------------------------------+---------------------+---------------------------------------------+

**Table: Board Temperature, Voltage, Current and Power sensors**

+---------------+----------------------------------+-------------------------+---------------------------------------------+
| **Bit Field** | **Bit Field Mapping**            | **Data Format**         | **Sensor Description**                      |
+===============+==================================+=========================+=============================================+
| **Board Inlet Temperature**                                                                                              |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Byte 0        | Inlet temp sensor value          | 1-byte two's compliment | Range: –128 to 127°C                        |
|               |                                  |                         |                                             |
|               | (located at back bracket)        | Unit: Celsius           | Example: 0x21= 33°C, 0xFE = -2°C            |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| **Board Outlet Temperature**                                                                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Byte 0        | Outlet temp sensor value         | 1-byte two's compliment | Range: –128 to 127°C                        |
|               |                                  |                         |                                             |
|               | (located at IO bracket)          | Unit: Celsius           | Example: 0x21= 33°C, 0xFE = -2°C            |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| **Board Edge Connector 3.3V Input Sensor** - Not applicable for U30 cards                                                |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Byte[3:2]     | Edge Connector 3.3V input voltage| 2-byte unsigned         | Voltage in volts                            |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Byte[1:0]     | Edge Connector 3.3V input current| 2-byte unsigned         | Current in amps                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| **Board Edge Connector 12V Input Sensor**                                                                                |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Byte[3:2]     | Edge Connector 12V input voltage | 2-byte unsigned         | Voltage in volts, LSB 1.25mV; 0x2570=11.98V |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Byte[1:0]     | Edge connector 12V input current | 2-byte unsigned         | Current in amps, LSB 1.25mA; 0x2710=12.5A   |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| **Board AUX Connector 12V Input Sensor** - Not applicable for U30 cards                                                  |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Byte[3:2]     | AUX connector 12V input voltage  | 2-byte unsigned         | Voltage in volts                            |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Byte[1:0]     | AUX connector 12V input current  | 2-byte unsigned         | Current in amps                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| **Board Total Power**                                                                                                    |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Byte[1:0]     | Total card power                 | 2-bytes unsigned        | [Byte 0] [Byte 1] = 0x32 0x00               |
|               |                                  |                         |                                             |
|               |                                  | LSB first; Unit: watts  | presents 50W (0x0032)                       |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+

**Table: FPGA Device 1 and 2 - Status, Temperature & Error information**

+---------------+----------------------------------+-------------------------+---------------------------------------------+
| **Bit Field** | **Bit Field Mapping**            | **Data Format**         | **Sensor Description**                      |
+===============+==================================+=========================+=============================================+
| **Device 1 Status Information**                                                                                          |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bits[7:4]     | KeepAlive enum                   | 4-bits unsigned;        | Heart bit counter from FPGA device          |
|               |                                  |                         |                                             |
|               |                                  | Unit: count             |                                             |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[3]        | ERRORn\_STATUS                   | 1-bit unsigned;         | Device PS\_ERROR\_STATUS pin status         |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | For details refer [*]                       |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[2]        | ERRORn                           | 1-bit unsigned          | Device PS\_ERROR\_OUT pin status            |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | For details refer [*]                       |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[1]        | INIT\_B                          | 1-bit unsigned          | Device INIT\_B pin status                   |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | For details refer [**]                      |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[0]        | FPGA\_DONE                       | 1-bit unsigned          | Device DONE pin status                      |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | For details refer [**]                      |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| **Device 1 Junction Temperature**                                                                                        |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[15:8]     | HBM junction temperature         | 1-byte two's compliment | NA for U30                                  |
|               |                                  |                         |                                             |
|               |                                  | Unit: Celsius           | Example: 0x21= 33°C, 0xFE = -2°C            |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[7:0]      | FPGA junction temperature        | 1-byte two's compliment | 0xFE presents –2°C; 0x23=35°C               |
|               |                                  |                         |                                             |
|               |                                  | Unit: Celsius           | Example: 0x21= 33°C, 0xFE = -2°C            |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| **Device 1 Advanced Error Counters**                                                                                     |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Byte[9:6]     | PCIe correctable error counter   | 4-bytes unsigned;       | Number of correctable PCIe errors for       |
|               |                                  |                         |                                             |
|               |                                  | LSB First; Unit: count  | device 1 after device/SC reboot             |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Byte[5:4]     | PCIe uncorrectable error counter | 2-bytes unsigned;       | Number of uncorrectable PCIe errors for     |
|               |                                  |                         |                                             |
|               |                                  | LSB First; Unit: count  | device 1 after device/SC reboot             |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Byte[3:2]     | DDR correctable error counter    | 2-bytes unsigned;       | Number of correctable DDR errors for        |
|               |                                  |                         |                                             |
|               |                                  | LSB First; Unit: count  | device 1 after device/SC reboot             |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Byte[1:0]     | DDR uncorrectable error counter  | 2-bytes unsigned;       | Number of uncorrectable DDR errors for      |
|               |                                  |                         |                                             |
|               |                                  | LSB First; Unit: count  | device 1 after device/SC reboot             |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| **Device 2 Status Information**                                                                                          |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bits[7:4]     | KeepAlive enum                   | 4-bits unsigned;        | Heart bit counter from FPGA device          |
|               |                                  |                         |                                             |
|               |                                  | Unit: count             |                                             |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[3]        | ERRORn\_STATUS                   | 1-bit unsigned;         | Device PS\_ERROR\_STATUS pin status         |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | For details refer [*]                       |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[2]        | ERRORn                           | 1-bit unsigned          | Device PS\_ERROR\_OUT pin status            |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | For details refer [*]                       |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[1]        | INIT\_B                          | 1-bit unsigned          | Device INIT\_B pin status                   |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | For details refer [**]                      |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[0]        | FPGA\_DONE                       | 1-bit unsigned          | Device DONE pin status                      |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | For details refer [**]                      |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| **Device 2 Junction Temperature**                                                                                        |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[15:8]     | HBM junction temperature         | 1-byte two's compliment | NA for U30                                  |
|               |                                  |                         |                                             |
|               |                                  | Unit: Celsius           | Example: 0x21= 33°C, 0xFE = -2°C            |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[7:0]      | FPGA junction temperature        | 1-byte two's compliment | 0xFE presents –2°C; 0x23=35°C               |
|               |                                  |                         |                                             |
|               |                                  | Unit: Celsius           | Example: 0x21= 33°C, 0xFE = -2°C            |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| **Device 2 Advanced Error Counters**                                                                                     |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Byte[9:6]     | PCIe correctable error counter   | 4-bytes unsigned;       | Number of correctable PCIe errors for       |
|               |                                  |                         |                                             |
|               |                                  | LSB First; Unit: count  | device 2 after device/SC reboot             |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Byte[5:4]     | PCIe uncorrectable error counter | 2-bytes unsigned;       | Number of uncorrectable PCIe errors for     |
|               |                                  |                         |                                             |
|               |                                  | LSB First; Unit: count  | device 2 after device/SC reboot             |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Byte[3:2]     | DDR correctable error counter    | 2-bytes unsigned;       | Number of correctable DDR errors for        |
|               |                                  |                         |                                             |
|               |                                  | LSB First; Unit: count  | device 2 after device/SC reboot             |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Byte[1:0]     | DDR uncorrectable error counter  | 2-bytes unsigned;       | Number of uncorrectable DDR errors for      |
|               |                                  |                         |                                             |
|               |                                  | LSB First; Unit: count  | device 2 after device/SC reboot             |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| **[*]** ->  See Zynq UltraScale+ Device Technical Reference Manual for signal definition                                 |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| **[**]** -> See UltraScale Architecture Configuration User Guide for signal definition                                   |
+---------------+----------------------------------+-------------------------+---------------------------------------------+

**Table: Network Module (QSFP) - Temperature and Status information**

**Note:** Not applicable for U30 cards.

+---------------+----------------------------------+-------------------------+---------------------------------------------+
| **Bit Field** | **Bit Field Mapping**            | **Data Format**         | **Sensor Description**                      |
+===============+==================================+=========================+=============================================+
| **Network Module 0 Temperature**                                                                                         |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Byte 0        | Network module 0 temperature     | 1-byte two's compliment | Range: –128 to 127°C;                       |
|               |                                  |                         |                                             |
|               |                                  | Unit: Celsius           | Example: 0x21= 33°C, 0xFE = -2°C            |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| **Network Module 0 Status**                                                                                              |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[15]       | Reserved                         | N/A                     | N/A                                         |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[14]       | OverCurrentL                     | 1-bit unsigned          | 0: Normal operation                         |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | 1: Over-current event                       |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[13]       | PowerEnL                         | 1-bit unsigned          | 0: Power off                                |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | 1: Power enabled                            |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[12:11]    | TxFault[1:0]                     | 2-bit unsigned          | [1:0] for SFP-DD                            |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | [0] for SFP N/A for QSFP 0: No Event        |
|               |                                  |                         |                                             |
|               |                                  |                         | 1: Transmitter detected a fault             |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[10:9]     | TxDisable[1:0]                   | 2-bit unsigned          | [1:0] for SFP-DD                            |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | [0] for SFP N/A for QSFP 0: No Event        |
|               |                                  |                         |                                             |
|               |                                  |                         | 1: Transmitter output turned off by host    |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[8:7]      | RxLos[1:0]                       | 2-bit unsigned          | [1:0] for SFP-DD                            |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | [0] for SFP N/A for QSFP 0: No Event        |
|               |                                  |                         |                                             |
|               |                                  |                         | 1: Optical signal level low                 |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[6:3]      | RS0-[2:1],RS1-[2:1]              | 4-bit unsigned          | 4 bits for SFP-DD; 2 bits for SFP;          |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | N/A for QSFP; Speed select by host          |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[2]        | LPMode                           | 1-bit unsigned          | All module types: Power Mode Control from   |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | host; 0: Normal; 1: Low Power Mode          |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[1]        | IntL                             | 1-bit unsigned          | QSFP only                                   |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | 0: No event; 1: Interrupt asserted          |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[0]        | ModPrsL                          | 1-bit unsigned          | All module types:                           |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | 0: module absent, 1: module present         |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| **Network Module 1 Temperature**                                                                                         |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Byte 0        | Network module 0 temperature     | 1-byte two's compliment | Range: –128 to 127°C;                       |
|               |                                  |                         |                                             |
|               |                                  | Unit: Celsius           | Example: 0x21= 33°C, 0xFE = -2°C            |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| **Network Module 1 Status**                                                                                              |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[15]       | Reserved                         | N/A                     | N/A                                         |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[14]       | OverCurrentL                     | 1-bit unsigned          | 0: Normal operation                         |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | 1: Over-current event                       |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[13]       | PowerEnL                         | 1-bit unsigned          | 0: Power off                                |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | 1: Power enabled                            |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[12:11]    | TxFault[1:0]                     | 2-bit unsigned          | [1:0] for SFP-DD                            |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | [0] for SFP N/A for QSFP 0: No Event        |
|               |                                  |                         |                                             |
|               |                                  |                         | 1: Transmitter detected a fault             |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[10:9]     | TxDisable[1:0]                   | 2-bit unsigned          | [1:0] for SFP-DD                            |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | [0] for SFP N/A for QSFP 0: No Event        |
|               |                                  |                         |                                             |
|               |                                  |                         | 1: Transmitter output turned off by host    |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[8:7]      | RxLos[1:0]                       | 2-bit unsigned          | [1:0] for SFP-DD                            |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | [0] for SFP N/A for QSFP 0: No Event        |
|               |                                  |                         |                                             |
|               |                                  |                         | 1: Optical signal level low                 |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[6:3]      | RS0-[2:1],RS1-[2:1]              | 4-bit unsigned          | 4 bits for SFP-DD; 2 bits for SFP;          |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | N/A for QSFP; Speed select by host          |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[2]        | LPMode                           | 1-bit unsigned          | All module types: Power Mode Control from   |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | host; 0: Normal; 1: Low Power Mode          |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[1]        | IntL                             | 1-bit unsigned          | QSFP only                                   |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | 0: No event; 1: Interrupt asserted          |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+
| Bit[0]        | ModPrsL                          | 1-bit unsigned          | All module types:                           |
|               |                                  |                         |                                             |
|               |                                  | Unit: state             | 0: module absent, 1: module present         |
|               |                                  |                         |                                             |
+---------------+----------------------------------+-------------------------+---------------------------------------------+

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
