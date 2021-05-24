############################################
Alveo Card Debug Guide
############################################

Quickly isolate, debug, and resolve a wide range of Alveo™ card related issues within the Vitis™/XRT flow, from card install through to hardware validation.


*****
Usage
*****

Similar issues are grouped into categories in the table below allowing
you to quickly narrow down the problem area. Click on the link matching
your issue to be taken to the category. Within each category, an
extensive list of encountered issues along with detailed error messages,
symptoms and resolution steps are provided.

.. sidebar:: Terminology
    :subtitle: This guide uses terms like reboot, shut down, cold boot, and unplug.

    For a list of defined terms, see :doc:`docs/terminology`.


***********************************
Supported Cards
***********************************

-  U50
-  U50LV
-  U200
-  U250
-  U280



***********************************
Issue Areas
***********************************


.. list-table:: 
   :widths: 20 80
   :header-rows: 1
   
   * - Issue Area
     - Topics Covered
	 
   * - :doc:`docs/card-install`
     - Recommended process for card installation

       - Available user guides
       - Common issues

   * - :doc:`docs/card-validation`
     - Common issues encountered while running ``xbutil validate``

   * - :doc:`docs/modifying-xrt-platform`
     - Recommended XRT and platform installation procedures

       - Upgrading XRT or a platform
       - Downgrading XRT or a platform
       - Uninstalling XRT

   * - :doc:`docs/card-not-recognized`
     - Common issues with BIOS, OS and ``lspci`` card recognition

       - System does not recognize card
       - BIOS settings
       - Usage of USB cable
       - LED status

   * - :doc:`docs/package-manager`
     - Package manager install issues

       - yum/apt
       - rpms/debs
       - pyopencl
       - Package manager install dependencies

   * - :doc:`docs/xrt-troubleshooting`
     - Common XRT issues

       - XRT drivers not recognizing the card

   * - :doc:`docs/sc-troubleshooting`
     - Common Satellite Controller (SC) issues

       - Bad XMC error
       - ``xbgmgmt flash --scan`` reporting SC version mismatches
       - ``xbutil query`` showing zero voltage or temperature
       - SC reporting UNKNOWN or INACTIVE

   * - :doc:`docs/application-crash`
     - Steps to determine if hardware is causing an application crash

   * - :doc:`docs/power-delivery`
     - Confirmation that hardware (server and card) can work together for heavy acceleration

   * - :doc:`docs/common-steps`
     - Reference procedures for all debugging sections

       - Sudo and root access
       - System details including OS release, PCIe™, and CPU status
       - XRT compatibility
       - Determining platform and SC on card and system
       - Monitoring card power and temperature


----------------------------------

****************************************
Xilinx Support
****************************************
For additional support resources such as Answers, Documentation, Downloads, and Alerts, see the `Xilinx Support pages <http://www.xilinx.com/support>`_. For additional assistance, post your question on the Xilinx Community Forums – `Alveo Accelerator Card <https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo>`_.

If you have a suggestion or find an issue, please email `alveo_cards_debugging@xilinx.com <alveo_cards_debugging@xilinx.com>`_.

****************************************
License
****************************************

All software including scripts in this distribution are licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at `http://www.apache.org/licenses/LICENSE-2.0 <http://www.apache.org/licenses/LICENSE-2.0>`_

All images and documentation, including all debug and support documentation, are licensed under the Creative Commons (CC) Attribution 4.0 International License (the "CC-BY-4.0 License"); you may not use this file except in compliance with the CC-BY-4.0 License.

You may obtain a copy of the CC-BY-4.0 License at
`https://creativecommons.org/licenses/by/4.0/ <https://creativecommons.org/licenses/by/4.0/>`_


Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.


.. toctree::
   :maxdepth: 3
   :caption: Home
   :hidden:

   Alveo Cards Landing Page <https://xilinx.github.io/Alveo-Cards/master/index.html>

.. toctree::
   :maxdepth: 3
   :caption: Issue Areas
   :hidden:

   docs/card-install
   docs/card-validation
   docs/modifying-xrt-platform
   docs/card-not-recognized
   docs/package-manager
   docs/xrt-troubleshooting
   docs/sc-troubleshooting
   docs/application-crash
   docs/power-delivery
   docs/common-steps

.. toctree::
   :maxdepth: 3
   :caption: Other Topics
   :hidden:
   
   docs/check-system-compatibility
   docs/terminology
   docs/alveo-system