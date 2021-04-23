Appendix A
----------

Alveo™  PCIe Information
~~~~~~~~~~~~~~~~~~~~~~~~

The table below captures the PCIe information for the following Alveo™ products:
-  U2xx(U200, U250, U280)
-  U50x (U50, U50C, U50LV)
-  U30
-  U55N
-  VCK5000

**NOTE:** The following PCIe information are constant across all Alveo™ cards.

-  **Vendor ID**     : ** 0x10EE**

-  **Subsystem VID** : ** 0x10EE**

-  **Subsystem DID** : ** 0x000E**


**Table: Alveo PCIe Device ID**

+-------------------------+----------------------------------------------+
| **Card/Shell**          | **Device ID**                                |
+=========================+==============================================+
| U200 Golden             | 0xD000                                       |
+-------------------------+----------------------------------------------+
| U200 XDMA & 2RP         | PF0=0x5000 PF1=0x5001 PF2=0x5002 PF3=0x5003  |
+-------------------------+----------------------------------------------+
| U200 QDMA               | PF0=0x5010 PF1=0x5011 PF2=0x5012 PF3=0x5013  |
+-------------------------+----------------------------------------------+
| U250 Golden             | 0xD004                                       |
+-------------------------+----------------------------------------------+
| U250 XDMA & 2RP         | PF0=0x5004 PF1=0x5005 PF2=0x5006 PF3=0x5007  |
+-------------------------+----------------------------------------------+
| U250 QDMA               | PF0=0x5014 PF1=0x5015 PF2=0x5016 PF3=0x5017  |
+-------------------------+----------------------------------------------+
| U280 Golden             | 0xD00C                                       |
+-------------------------+----------------------------------------------+
| U280 XDMA               | PF0=0x500C PF1=0x500D PF2=0x500E PF3=0x500F  |
+-------------------------+----------------------------------------------+
| U50 Golden              | 0xD020                                       |
+-------------------------+----------------------------------------------+
| U50 XDMA                | PF0=0x5020 PF1=0x5021 PF2=0x5022 PF3=0x5023  |
+-------------------------+----------------------------------------------+
| U50LV XMDA              | PF0=0x5060 PF1=0x5061 PF2=0x5062 PF3=0x5063  |
+-------------------------+----------------------------------------------+
| U50C                    | PF0=0x506C PF1=0x506D PF2=0x506E PF3=0x506F  |
+-------------------------+----------------------------------------------+
| U30 Golden              | 0xD03C                                       |
+-------------------------+----------------------------------------------+
| U30 XDMA                | PF0=0x503C PF1=0x503D PF2=0x503E PF3=0x503F  |
+-------------------------+----------------------------------------------+
| U30 Golden (2RP)        | 0xD13C                                       |
+-------------------------+----------------------------------------------+
| U30 XDMA 2RP            | PF0=0x513C PF1=0x513D PF2=0x513E PF3=0x513F  |
+-------------------------+----------------------------------------------+
| U55N                    | PF0=0x5058 PF1=0x5059 PF2=0x505A PF3=0x505B  |
+-------------------------+----------------------------------------------+
| U55C                    | PF0=0x505C PF1=0x505D PF2=0x505E PF3=0x505F  |
+-------------------------+----------------------------------------------+
| VCK5000 XDMA            | PF0=0x5044 PF1=0x5045 PF2=0x5046 PF3=0x5047  |
+-------------------------+----------------------------------------------+
| VCK5000 QDMA            | PF0=0x5048 PF1=0x5049 PF2=0x504A PF3=0x504B  |
+-------------------------+----------------------------------------------+

PF -> Physical Function
**lspci command usage:** sudo lspci -s :03:00.0 -vv


Temperature Limits
~~~~~~~~~~~~~~~~~~

**Table: QSFP Temperature Limits**

The following table captures the QSFP temperature limits for all QSFP capable Alveo™ products - U2xx(U200, U250, U280), U50x (U50, U50C, U50LV) , U55x (U55N, U55C) and VCK5000 products.

+---------------------------------+-------------------------+--------------------------+-----------------------+
|  **Sensor Name**                |     **Warning Limit**   |     **Critical Limit**   |     **Fatal Limit**   |
+=================================+=========================+==========================+=======================+
| QSFP temperature [1]            |                         |                          |                       |
|                                 |                         |                          |                       |
| Commercial Type                 |     65°C                |     70°C                 |     75°C              |
|                                 |                         |                          |                       |
| Industrial Type                 |     80°C                |     85°C                 |     90°C              |
+---------------------------------+-------------------------+--------------------------+-----------------------+

**Notes:**

[1] QSFP temperature limits may vary based on the device OEM (manufacturer) and model. For thermal references, QSFP devices are broadly categorized as Commercial or Industrial type. 

Wherever supported by the QSFP device, SC FW accesses the 'Max case temperature' via I2C read at register offset 190 as per the SFF-8636 2.10a specification and dynamically sets the device specific critical thermal limit. For QSFP devices that doesn't support SFF-8636 spec, SC FW assigns the critical limit as 70°C for Commercial (when register offset 190 returns 0x00) or 85°C for Industrial (when register returns 0xFF).

-  Warning limit = (Max case temperature - 5)
-  Critical limit = Max case temperature
-  Fatal limit = (Max case temperature + 5)

For additional thermal information, refer to the data sheet specific to the Alveo™ product:

-  `Alveo U200/U250 <https://www.xilinx.com/support/documentation/data_sheets/ds962-u200-u250.pdf>`__

-  `Alveo U280 <https://www.xilinx.com/support/documentation/data_sheets/ds963-u280.pdf>`__

-  `Alveo U50 <https://www.xilinx.com/support/documentation/data_sheets/ds965-u50.pdf>`__

**Table: FPGA and Board Temperature Limits**

+---------------------------------+-------------------------+--------------------------+-----------------------+
|  **Sensor Name**                |     **Warning Limit**   |     **Critical Limit**   |     **Fatal Limit**   |
+=================================+=========================+==========================+=======================+
|     **U200/U250**                                                                                            |
+---------------------------------+-------------------------+--------------------------+-----------------------+
| FPGA Device temperature         |     88°C                |     97°C                 |     107°C             |
+---------------------------------+-------------------------+--------------------------+-----------------------+
| Board temperature [4]           |     100°C               |     110°C                |     125°C             |
+---------------------------------+-------------------------+--------------------------+-----------------------+
|     **U280**                                                                                                 |
+---------------------------------+-------------------------+--------------------------+-----------------------+
| Logical FPGA temperature [2]    |     88°C                |     97°C                 |     107°C             |
+---------------------------------+-------------------------+--------------------------+-----------------------+
| Board temperature [4]           |     100°C               |     110°C                |     125°C             |
+---------------------------------+-------------------------+--------------------------+-----------------------+
| **U50, U50LV, U55N**                                                                                         |
+---------------------------------+-------------------------+--------------------------+-----------------------+
| Logical FPGA temperature [2]    |     88°C                |     97°C                 |     107°C             |
+---------------------------------+-------------------------+--------------------------+-----------------------+
| Board temperature [4]           |     100°C               |     110°C                |     125°C             |
+---------------------------------+-------------------------+--------------------------+-----------------------+
| **U50C**                                                                                                     |
+---------------------------------+-------------------------+--------------------------+-----------------------+
| Logical FPGA temperature [2]    |     88°C                |     100°C                |     107°C             |
+---------------------------------+-------------------------+--------------------------+-----------------------+
| Board temperature [40]          |     100°C               |     110°C                |     125°C             |
+---------------------------------+-------------------------+--------------------------+-----------------------+
| **U30** [3]                                                                                                  |
+---------------------------------+-------------------------+--------------------------+-----------------------+
| Max FPGA junction temperature   |     90°C                |     95°C                 |     100°C             |
|                                 |                         |                          |                       |
| (Max of ZYNQ1 & ZYNQ2 FPGA)     |                         |                          |                       |
+---------------------------------+-------------------------+--------------------------+-----------------------+
| Board temperature               |     75°C                |     80°C                 |     85°C              |
+---------------------------------+-------------------------+--------------------------+-----------------------+

[2] Logical device temperature is maximum of FPGA die temperature and the HBM temperature.

**Note:** Alveo™ U30 specific

[3] The OTP (One Time Programmable) values are programmed onto the temperature sensor device at the time of Manufacturing. Additionally, on boot-up, SC also configures the temperature device to ensure the temperature sensor device automatically shuts down the ZYNQ devices when either ZYNQ or board temperature exceeds the fatal limit.

[4] Board temperature is the maximum value among various on-board temperature sensors like inlet, outlet and VCCINT (PWM controller). 

***Note*:** The SC FW automatically shuts down the power to FPGA when any of the temperature value exceeds the fatal limit.

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
