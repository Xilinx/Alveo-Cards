########################################################################################################################
UL3524 Design Support
########################################################################################################################


.. toctree::
   :maxdepth: 3
   :caption: UL3524
   :hidden:

   Home <https://pages.gitenterprise.xilinx.com/ACPI/Reference-Designs/>
   On GitHub <https://github.com/Xilinx/Alveo-Cards/tree/ul3524>




*********************************
Overview
*********************************


This repository provides AMD Alveo UL3524 card support including Vivado based reference designs targeting features of the card.





****************************************************
Reference Designs
****************************************************

Available reference designs are summarized in the following table.  Each reference design includes:

* High-level design overview including attributes, performance, limitations and usage
* Simulation waveform files with waveform descriptions to better understand the design
* Hardware design files along with ILA / VIO configuration files allowing greater control and visibility into the design  

Each reference design is located in their respective sub-directory.




.. list-table::  Available Reference Designs
   :widths: 30 70
   :header-rows: 1
   
   * - Reference Design
     - Summary
	 
   * - :doc:`GTF Latency Benchmark <./docs/GTF_Latency/README>`
     - Benchmark design used to measure and report GTF in MAC and RAW 10G latency.

   * - :doc:`GTF Recovery Clock <./docs/RECOV_CLK/README>`
     - Demonstrates how to setup the QSFP-DD Renesas device and route the GTF recovered clock through Bank 65.

   * - :doc:`PCIE DDR <./docs/PCIE_DDR/README>`
     - DDR I2C and MIG bring-up and validation through PCIe.

   * - :doc:`QDR MIG <./docs/QDR_MIG/README>`
     - Interface with the QDRII+ memory montroller through AXI.

   * - :doc:`QSFP I2C <./docs/QSFP_I2C/README>`
     - Enable QSFP module power planes and side-band signals via I2C interface.

   * - :doc:`Renesas I2C Programming <./docs/Renesas_I2C_Programming/README>`
     - Program the Renesas devices via I2C using a state machine. Includes script to convert Renesas programming script file to ``.coe`` BRAM file format.






Reference Design Support
=================================================

The following links provide support to use the reference designs.

* :doc:`Loading a reference design <./docs/Docs/loading_ref_proj>`
* :doc:`Simulating a reference design <./docs/Docs/simulating_a_design>`
* :doc:`Building a reference design <./docs/Docs/building_a_design>`
* :doc:`Programming a reference design to the card <./docs/Docs/programming_the_device>`



.. toctree::
   :maxdepth: 3
   :caption: Reference Designs
   :hidden:

   GTF Latency Benchmark <./docs/GTF_Latency/README>
   GTF Recovery Clock <./docs/RECOV_CLK/README>
   PCIE DDR <./docs/PCIE_DDR/README>
   QDR MIG <./docs/QDR_MIG/README>
   QSFP I2C <./docs/QSFP_I2C/README>
   Renesas I2C Programming <./docs/Renesas_I2C_Programming/README>


.. toctree::
   :maxdepth: 1
   :caption: Reference Design Support
   :hidden:

   Loading a design  <./docs/Docs/loading_ref_proj>
   Simulating a design  <./docs/Docs/simulating_a_design>
   Building a design  <./docs/Docs/building_a_design>
   Programming the device  <./docs/Docs/programming_the_device>






Supported Cards
=================================================

The following card is supported by the reference designs in this repository:

* UL3524




Vivado Design Support
=================================================



.. toctree::
   :maxdepth: 3
   :caption: Vivado Design Support
   :hidden:

   Vivado Design Flow <./docs/Docs/vivado_design_flow>



The reference designs require the following Vivado release:

* Vivado ©️ 2023.1 or greater



The following links provide support on the Vivado flow:

* :doc:`Vivado Design Flow <./docs/Docs/vivado_design_flow>`
* :download:`UL3524 XDC file <./docs/XDC/ul3524.xdc>`


The `UL3524 Master Answer Record <https://support.xilinx.com/s/article/000035539>`__ provides support resources such as known issues and release notes. For additional assistance, post your question on the AMD Community Forums - `Alveo Accelerator Card <https://support.xilinx.com/s/topic/0TO2E000000YKXlWAO/alveo-accelerator-cards>`_.





Hardware Requirements
=================================================

To program the device from the Vivado HW Manager, you need either of the following:

* Micro-B USB cable
* Alveo Debug Kit (ADK). See `Alveo Accessories <https://www.xilinx.com/products/boards-and-kits/alveo/accessories.html>`__ to purchase.



Support
===================================

For additional documentation, please refer to the `UL3524 product page <https://www.xilinx.com/products/boards-and-kits/alveo/ul3524.html>`__ and the `UL3524 Lounge <https://www.xilinx.com/member/ull-ea.html>`__.


For support, contact your FAE or refer to support resources at `support.xilinx.com <https://support.xilinx.com>`__.

