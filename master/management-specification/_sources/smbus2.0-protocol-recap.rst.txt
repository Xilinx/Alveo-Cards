I2C/SMBus Implementation and Protocol Recap
-------------------------------------------

Xilinx® Alveo™ cards support OoB communication via Standard I2C/SMBus commands at I2C slave address 0x65 (0xCA in 8-bit). The implementation is SMBus v2.0 Specification compliant. This chapter captures some of the frequently used SMBus commands between SC and Server BMC. Note that all the standard SMBus commands between SC and Server BMC are implemented without PEC. 

**NOTE:** For detailed SMBus spec, refer `System Management Bus Specification - version 2.0 <http://smbus.org/specs/smbus20.pdf>`_ 

**Figure: SMBus Packet**

.. image:: ./images/SMBus_Sample_Packet.png
   :align: center


**Table: SMBus Packet diagram element Key**

+-------------------+----------------------------------------------------------------------------------------------+
|     **Key**       |     **Description**                                                                          |
+===================+==============================================================================================+
|     S             |     Start condition                                                                          |
+-------------------+----------------------------------------------------------------------------------------------+
|     Sr            |     Repeated start condition                                                                 |
+-------------------+----------------------------------------------------------------------------------------------+
|     R             |     Read (bit value of 1)                                                                    |
+-------------------+----------------------------------------------------------------------------------------------+
|     W             |     Write (bite value of 0)                                                                  |
+-------------------+----------------------------------------------------------------------------------------------+
|     A             |     ACK                                                                                      |
+-------------------+----------------------------------------------------------------------------------------------+
|     N             |     NACK                                                                                     |
+-------------------+----------------------------------------------------------------------------------------------+
|     P             |     Stop condition                                                                           |
+-------------------+----------------------------------------------------------------------------------------------+
|     □             |     Master-to-slave                                                                          |
+-------------------+----------------------------------------------------------------------------------------------+
|     ■             |     Slave-to-master                                                                          |
+-------------------+----------------------------------------------------------------------------------------------+
|     PEC           |     Packet error code                                                                        |
+-------------------+----------------------------------------------------------------------------------------------+
|     ...           |     Continuation of protocol                                                                 |
+-------------------+----------------------------------------------------------------------------------------------+

**Figure: SMBus Commands**

.. image:: ./images/SMBus_Commands_Figure1.png
   :align: center

.. image:: ./images/SMBus_Commands_Figure2.png
   :align: center


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
