
==============================================================
Alveo Card Out-of-Band Management Specification for Server BMC
==============================================================


.. image:: ./images/amd.png
   :align: left

This document describes out-of-band (OoB) support available for the U200, U250, U280, U50x, U30, U55x, VCK5000, V70, Avalon UL3524 and MA35D Alveo™ Data Center Cards. Out-of-band support is implemented in the Satellite Controller (SC) firmware, which supports communication with the server Board Management Controller (BMC) over the SMBus/I2C interface on the PCIe® edge connector. The underlying protocols supported are Alveo I2C and PLDM Over MCTP Over SMBus.
	
---------------------------------------------------------------------------------------------------------------

.. toctree::
   :maxdepth: 1
   :caption: Introduction

   oob-intro.rst

.. toctree::
   :maxdepth: 1
   :caption: Alveo IPMI FRU

   alveo-fru.rst

.. toctree::
   :maxdepth: 1
   :caption: PMCI support

   pmci-support.rst

.. toctree::
   :maxdepth: 1
   :caption: PLDM telemetry

   pldm-t2-telemetry.rst

.. toctree::
   :maxdepth: 1
   :caption: MA35D IFWI update

   pldm-t5-update.rst

.. toctree::
   :maxdepth: 1
   :caption: SPDM attestation

   spdm-attestation.rst

.. toctree::
   :maxdepth: 1
   :caption: Alveo I2C Telemetry

   alveo-I2C-telemetry.rst

.. toctree::
   :maxdepth: 1
   :caption: SC FW update

   sc-firmware-update.rst

.. toctree::
   :maxdepth: 1
   :caption: U30 FPGA FW update

   fpga-firmware-update.rst

.. toctree::
   :maxdepth: 1
   :caption: PCIe and thermal info

   appendix-a.rst

.. toctree::
   :maxdepth: 1
   :caption: References

   references.rst

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
