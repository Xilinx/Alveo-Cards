PMCI Support
------------

Alveo™ products supports PLDM over MCTP over SMBus at slave address 0x18 (0x30 in 8-bit). The latest sensor information is stored locally in SC FW and is reported to server BMC via PLDM Type-2 commands. Sensor information is reported to the BMC via the platform descriptor record (PDR). 
	
**PLDM Over MCTP Over SMBus Protocol**

SC firmware supports the SMBus discovery via the default SMBus 2.0 at I2C slave address 0x61 (0xC2 in 8-bit) and the MCTP/PLDM protocol at I2C slave address 0x18 (0x30 in 8-bit). Alveo OoB implementation adheres to the following DMTF specifications:

1. *MCTP Base Specification* (`[DSP0236] <https://www.dmtf.org/dsp/DSP0236>`__)
2. *MCTP SMBus Binding Spec* (`[DSP0237] <https://www.dmtf.org/dsp/DSP0237>`__)
3. *PLDM Base Specification* (`[DSP0240] <https://www.dmtf.org/dsp/DSP0240>`__)
4. *PLDM for Platform Monitoring and Control Specification* (`[DSP0248] <https://www.dmtf.org/dsp/DSP0248>`__)

**Default SMBus 2.0 commands**

For the purposes of SMBus address discovery (at default SMBus address 0xC2 (8-bit)), Alveo™ cards are 'Fixed and Non-Discoverable Device'. Only Get UDID (general) and Get UDID (directed) commands are supported.

MCTP control messages
~~~~~~~~~~~~~~~~~~~~~

The following MCTP control commands are supported in the SC:

**Table: Supported MCTP control commands and description**

+--------------------------+--------+--------------------------------------------------------------------------------+
|  **Command**             | **ID** | **Description**                                                                |
+==========================+========+================================================================================+
| Set Endpoint ID          |  0x01  | Assigns an EID to the endpoint at the given physical address                   |
+--------------------------+--------+--------------------------------------------------------------------------------+
| Get Endpoint ID          |  0x02  | Returns the EID presently assigned to an endpoint                              |
+--------------------------+--------+--------------------------------------------------------------------------------+
| Get Endpoint UUID        |  0x03  | Retrieves a per-device unique UUID associated with the endpoint                |
+--------------------------+--------+--------------------------------------------------------------------------------+
| Get MCTP Version Support |  0x04  | Lists which versions of the MCTP control protocol are supported on an endpoint |
+--------------------------+--------+--------------------------------------------------------------------------------+
| Get Message Type Support |  0x05  | Lists the message types that an endpoint supports                              |
+--------------------------+--------+--------------------------------------------------------------------------------+


PLDM Telemetry Commands
~~~~~~~~~~~~~~~~~~~~~~~

The following PLDM Type-0 (Control & Discovery) commands are supported in the SC:

**Table: Supported PLDM Type-0 commands and description**

+-----------------+--------+-------------------------------------------------------------------------------------------+
|  **Command**    | **ID** | **Description**                                                                           |
+=================+========+===========================================================================================+
| SetTID          |  0x01  | Sets the terminus ID (TID) for a PLDM terminus                                            |
+-----------------+--------+-------------------------------------------------------------------------------------------+
| GetTID          |  0x02  | Returns the present TID setting for a PLDM terminus                                       |
+-----------------+--------+-------------------------------------------------------------------------------------------+
| GetPLDMVersion  |  0x03  | Returns versions for PLDM base & type specification                                       |
+-----------------+--------+-------------------------------------------------------------------------------------------+
| GetPLDMTypes    |  0x04  | Returns PLDM type capabilities and list of the supported PLDM types                       |
+-----------------+--------+-------------------------------------------------------------------------------------------+
| GetPLDMCommands |  0x05  | Returns PLDM command capabilities supported for a specific PLDM type and version          |
+-----------------+--------+-------------------------------------------------------------------------------------------+

The following PLDM Type-2 (Numeric, Effecter & PDR) commands are supported in the SC:

**Table: Supported PLDM Type-2 commands and description**

+--------------------------+--------+----------------------------------------------------------------------------------+
|  **Command**             | **ID** | **Description**                                                                  |
+==========================+========+==================================================================================+
| SetNumericSensorEnable   |  0x10  | Command to set the operational state of the sensor                               |
+--------------------------+--------+----------------------------------------------------------------------------------+
| GetSensorReading         |  0x11  | Returns present reading and threshold event state values from a numeric sensor   |
+--------------------------+--------+----------------------------------------------------------------------------------+
| GetSensorThresholds      |  0x12  | Returns the present threshold settings for a PLDM numeric sensor                 |
+--------------------------+--------+----------------------------------------------------------------------------------+
| SetNumericEffecterEnable |  0x30  | Command is used to enable or disable Effecter operation                          |
+--------------------------+--------+----------------------------------------------------------------------------------+
| SetNumericEffecterValue  |  0x31  | Command is used to set the value for a PLDM Numeric Effecter                     |
+--------------------------+--------+----------------------------------------------------------------------------------+
| GetNumericEffecterValue  |  0x32  | Command is used to return the present numeric setting of a PLDM Numeric Effecter |
+--------------------------+--------+----------------------------------------------------------------------------------+
| GetPDRRepositoryInfo     |  0x50  | Returns size & number of records in PDR and time stamps on last PRD update       |
+--------------------------+--------+----------------------------------------------------------------------------------+
| GetPDR                   |  0x51  | Returns individual PDRs from a PDR repository                                    |
+--------------------------+--------+----------------------------------------------------------------------------------+
| GetPDRRepoSignature      |  0x53  | Returns a signature that changes when the PDR repo has been changed              |
+--------------------------+--------+----------------------------------------------------------------------------------+


Sample PLDM Transaction
~~~~~~~~~~~~~~~~~~~~~~~

This section examines a sample PLDM request and response message. For this example, the BMC on the server has a I2C address of 0x20 and the SC has an I2C address of 0xCE.

PLDM Request
~~~~~~~~~~~~

The PLDM request originates from the server BMC and SC FW receives this request via I2C interface at address 0xCE. The MCTP packet encapsulation and the different fields are explained in the *MCTP SMBus/I2C Transport Binding Specification*

    *Figure:* **PLDM Request**

.. image:: ./images/BMC-request.png
   :align: center


A request sent from the BMC to the SC will resemble the following table.

.. image:: ./images/SC-request.png
   :align: center

The blue section is the PLDM message that can be decoded, as explained in the *PLDM Base Specification*

**Table: PLDM Message Payload**

.. image:: ./images/payload.png
   :align: center

***Note*:** The PLDM completion code is present only in PDM response
messages.

The blue section in the previous message decoded using the PLDM message scheme resembles the following figure.

**Table: PLDM Message Scheme**

.. image:: ./images/message-scheme.png
   :align: center

Hdr and PLDM completion code field only applies to PLDM responses,
not PLDM requests. PLDM Command code 0x11 corresponds to the
GetSensorReading and the payload can now be decoded, as detailed in
the following table.

**Table: PLDM Completion Codes**

+--------------+------------------------+---------------------------------+
|     **Type** |     **Request Data**   |     **Value In Our Examples**   |
+==============+========================+=================================+
|     uint16   |     Sensor ID          |     0x0001                      |
+--------------+------------------------+---------------------------------+
|     bool8    |     rearmEventState    |     0x00                        |
+--------------+------------------------+---------------------------------+

Now the SC knows that the server BMC is requesting a sensor reading
with sensor ID 0x01.

PLDM Response
~~~~~~~~~~~~~

The SC frames the response to each valid PLDM request in the background and 
sends the response in SMBus master mode. This section provides a detailed explanation 
of how the SC PLDM packets. Additionally, the details about how MCTP packets are within each 
PLDM packet gets built is also provided.

The following table details the response for GetSensorReading.

**Table: GetSensorReading Response**

+---------------+--------------------------------+---------------------------------+
|     **Type**  |     **Request Data**           |     **Value In Our Examples**   |
+===============+================================+=================================+
|     enum8     |     completionCode             |     0x00                        |
+---------------+--------------------------------+---------------------------------+
|     enum8     |     sensorDataSize             |     0x02                        |
+---------------+--------------------------------+---------------------------------+
|     enum8     |     sensorOperationalState     |     0x00                        |
+---------------+--------------------------------+---------------------------------+
|     enum8     |     sensoreventMessageEnable   |     0x00                        |
+---------------+--------------------------------+---------------------------------+
|     enum8     |     presentState               |     0x01                        |
+---------------+--------------------------------+---------------------------------+
|     enum8     |     previousState              |     0x00                        |
+---------------+--------------------------------+---------------------------------+
|     enum8     |     eventState                 |     0x01                        |
+---------------+--------------------------------+---------------------------------+
|     uint16    |     presentReading             |     0x002A                      |
+---------------+--------------------------------+---------------------------------+

The response that gets plugged into the PLDM message scheme resembles the following table.

.. image:: ./images/response.png
   :align: center

The PLDM message encapsulated inside MCTP response resembles the following table.

**Table: PDLM Message in MCTP Response**


The server BMC decodes the MCTP response it receives to obtain the sensor readings.

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

