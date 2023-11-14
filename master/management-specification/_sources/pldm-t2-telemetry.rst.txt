PLDM Telemetry
--------------

Alveo™ supports PLDM Over MCTP Over SMBus at slave address 0x30 (8-bit). The latest sensor information is stored locally in SC FW and is reported to server BMC via PLDM Type-2 commands. Sensor information is reported to the BMC via the platform descriptor record (PDR). 
	
**PLDM Over MCTP Over SMBus Protocol**

Alveo™ PLDM implementation adheres to the following DMTF specifications:

1. *PLDM Base Specification* (`[DSP0240] <https://www.dmtf.org/dsp/DSP0240>`__)
2. *PLDM for Platform Monitoring and Control Specification* (`[DSP0248] <https://www.dmtf.org/dsp/DSP0248>`__)

**List of supported PLDM Type-2 commands**

**Numeric Sensor commands**

1. SetNumericSensorEnable
2. GetSensorReading
3. GetSensorThresholds

**Effecter commands**

1. SetNumericEffecterEnable
2. SetNumericEffecterValue
3. GetNumericEffecterValue

**NOTE:** Effecter commands are supported only in Alveo™ MA35D product

**PDR repository commands**

1. GetPDRRepositoryInfo
2. GetPDR
3. GetPDRRepositorySignature

**PLDM PDR types**

**Table: List of supported PDR types**

+---------------------+------------------------------+------------------------------+
| **PDR Type Number** | **PDR Type Name**            | **Notes**                    |
+=====================+==============================+==============================+
| 1 (0x01)            | Terminus Locator PDR         |                              |
+---------------------+------------------------------+------------------------------+
| 2 (0x02)            | Numeric Sensor PDR           |                              |
+---------------------+------------------------------+------------------------------+
| 6 (0x06)            | Sensor Auxiliary Names PDR   |                              |
+---------------------+------------------------------+------------------------------+
| 9 (0x09)            | Numeric Effecter PDR         | Supported only in MA35D      |
+---------------------+------------------------------+------------------------------+
| 13 (0x0D)           | Effecter Auxiliary Names PDR | Supported only in MA35D      |
+---------------------+------------------------------+------------------------------+

**PLDM sensors**

**Table: List of Numeric sensors supported in Alveo™ products**

Applicable to Alveo™ U200, U250, U280, U50, U50LV, U30, U55C, U55N, UL3xxx & V70 products.

+---------------+----------------------------------+-------------------------------------------------------------------------+
| **Sensor ID** |  **Sensor Name**                 | **Description**                                                         |
+===============+==================================+=========================================================================+
|  **Numeric sensor - Thermal**                                                                                              |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  1 (0x01)     | FPGA  Temperature                |  Consolidated FPGA die/junction temperature                             |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  2 (0x02)     | Board Temperature                |  Max of (Inlet, outlet, VRM) temperature                                |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  3 (0x03)     | QSFP0 Temperature                |  QSFP0 temperature when present (N/A for U30, U55C, UL3xxx & V70)       |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  4 (0x04)     | QSFP1 Temperature                |  QSFP1 temperature when present ((N/A for U30, U55C, UL3xxx & V70)      |
+---------------+----------------------------------+-------------------------------------------------------------------------+

**Table: List of Numeric sensors supported in MA35D product**

+---------------+----------------------------------+-------------------------------------------------------------------------+
| **Sensor ID** |  **Sensor Name**                 | **Description**                                                         |
+===============+==================================+=========================================================================+
|  **Numeric sensor - Thermal**                                                                                              |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  1 (0x01)     | ASIC1 Temperature                |  ASIC device temperature retrieved from ASIC1                           |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  2 (0x02)     | ASIC2 Temperature                |  ASIC device temperature retrieved from ASIC2                           |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  3 (0x03)     | Inlet Temperature                |  Board Inlet temperature sensor (placed near IO bracket)                |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  4 (0x04)     | Normalized VRM Temperature       |  Normalized temperature sensor value from the Voltage Regulators (VRM)  |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  **Numeric sensor - Electrical**                                                                                           |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  5 (0x05)     | 3v3 Aux Voltage                  |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  6 (0x06)     | 3v3 Pex Voltage                  |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  7 (0x07)     | 12v Pex Voltage                  |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  8 (0x08)     | ASIC1 Voltage                    | ASIC voltage retrieved from ASIC1                                       |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  9 (0x09)     | ASIC2 Voltage                    | ASIC voltage retrieved from ASIC2                                       |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  10 (0x0A)    | 3v3 Aux Current                  |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  11 (0x0B)    | 3v3 Pex Current                  |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  12 (0x0C)    | 12v Pex Current                  |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  13 (0x0D)    | Total Power                      | Total Power consumption of the MA35D board                              |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  **Numeric sensor - Firmware Versions**                                                                                    |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  14 (0x0E)    | SC FW Version                    |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  15 (0x0F)    | ASIC1 ZSP FW Version             |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  16 (0x10)    | ASIC2 ZSP FW Version             |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  27 (0x1B)    | ASIC1 eSecure FW Version         |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  28 (0x1C)    | ASIC2 eSecure FW Version         |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  **Numeric sensor - ASIC Info - Heartbeat, Errors & PCIe**                                                                 |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  17 (0x11)    | ASIC1 Heartbeat sensor           |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  18 (0x12)    | ASIC2 Heartbeat sensor           |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  19 (0x13)    | ASIC1 PCIe Correctable Errors    |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  20 (0x14)    | ASIC2 PCIe Correctable Errors    |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  21 (0x15)    | ASIC1 PCIe Uncorrectable Errors  |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  22 (0x16)    | ASIC2 PCIe Uncorrectable Errors  |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  23 (0x17)    | ASIC1 ECC Correctable Errors     |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  24 (0x18)    | ASIC2 ECC Correctable Errors     |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  25 (0x19)    | ASIC1 ECC Uncorrectable Errors   |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  26 (0x1A)    | ASIC2 ECC Uncorrectable Errors   |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  29 (0x1D)    | ASIC1 PCIe Link Speed            |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  30 (0x1E)    | ASIC2 PCIe Link Speed            |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  31 (0x1F)    | ASIC1 PCIe Link Width            |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+
|  32 (0x20)    | ASIC2 PCIe Link Width            |                                                                         |
+---------------+----------------------------------+-------------------------------------------------------------------------+


**Table: List of Effecters sensors supported in MA35D product**

+---------------+----------------------------------+--------------------------------------------------------------------------+
| **Sensor ID** |  **Sensor Name**                 | **Description**                                                          |
+===============+==================================+==========================================================================+
|  **Effecters - Resets and SPI flash WP config**                                                                             |
+---------------+----------------------------------+--------------------------------------------------------------------------+
|  1 (0x01)     | ASIC1 reset                      | Effector to reset ASIC1; SC resets ASIC1 via GPIO signal                 |
+---------------+----------------------------------+--------------------------------------------------------------------------+
|  2 (0x02)     | ASIC2 reset                      | Effector to reset ASIC2; SC resets ASIC1 via GPIO signal                 |
+---------------+----------------------------------+--------------------------------------------------------------------------+
|  3 (0x03)     | SC reset                         | Effector to soft reset MSP432 MCU                                        |
+---------------+----------------------------------+--------------------------------------------------------------------------+
|  4 (0x04)     | ASIC1 SPI flash WP set           | Effector to enable/disable ASIC1 flash Write Protect; Default: WP enable |
+---------------+----------------------------------+--------------------------------------------------------------------------+
|  5 (0x05)     | ASIC2 SPI flash WP set           | Effector to enable/disable ASIC2 flash Write Protect; Default: WP enable |
+---------------+----------------------------------+--------------------------------------------------------------------------+

**NOTE:** Effecter values range between 0x00 and 0x01. For ASIC/SC resets, sending 0x01 results in reset. For flash Write Protects, sending 0x01 disables WP and 0x00 enables it back.

**AMD Support**

For support resources such as answers, documentation, downloads, and forums, see the `Alveo Accelerator Cards AMD/Xilinx Community Forum <https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo>`_.

**License**

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at
`http://www.apache.org/licenses/LICENSE-2.0 <http://www.apache.org/licenses/LICENSE-2.0>`_

All images and documentation, including all debug and support documentation, are licensed under the Creative Commons (CC) Attribution 4.0 International License (the "CC-BY-4.0 License"); you may not use this file except in compliance with the CC-BY-4.0 License.

You may obtain a copy of the CC-BY-4.0 License at
`https://creativecommons.org/licenses/by/4.0/ <https://creativecommons.org/licenses/by/4.0/>`_

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.


.. raw:: html

	<p align="center"><sup>XD038 | &copy; Copyright 2023, Advanced Micro Devices Inc.</sup></p>
