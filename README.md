<table class="sphinxhide" width="100%">
 <tr width="100%">
    <td align="center"><img src="https://raw.githubusercontent.com/Xilinx/Image-Collateral/main/xilinx-logo.png" width="30%"/><h1>UL3524 Ultra Low Latency Trading</h1>
    </td>
 </tr>
</table>

# UL3524 Design Support

## Overview

This repository provides AMD Alveo UL3524 card support including Vivado based reference designs targeting features of the card.


## Reference Designs

Available reference designs are summarized in the following table.  Each reference design includes:

* High-level design overview including attributes, performance, limitations and usage
* Simulation waveform files with waveform descriptions to better understand the design
* Hardware design files along with ILA / VIO configuration files allowing greater control and visibility into the design  

Each reference design is located in their respective sub-directory.

| Reference Design | Summary |
|---|---|
| [GTF Latency Benchmark](./GTF_Latency/README.md) | Benchmark design used to measure and report GTF MAC and RAW 10G latency.|
| [GTF Recovery Clock](./RECOV_CLK/README.md) | Demonstrates how to setup the QSFP-DD Renesas device and route the GTF recovered clock through Bank 65|
| [PCIE DDR](./PCIE_DDR/) | DDR I2C and MIG bring-up and validation through PCIe |
| [QDR MIG](./QDR_MIG/) | Interface with the QDRII+ memory montroller through AXI. |
| [QSFP I2C](./QSFP_I2C/)  | Enable QSFP module power planes and side-band signals via I2C interface.|
| [Renesas I2C Programming](./Renesas_I2C_Programming/)  | Program the Renesas devices via I2C using a state machine.  Includes script to convert Renesas programming script file to .coe BRAM file format.|
| [FINN Latency Example Design](./FINN_Latency/README.md) | Example design which shows how to use a FINN-generated MLP IP block on the ULL |

**TABLE**: Available Reference Designs


### Reference Design Support

The follow links provide support to use the reference designs.

* [Loading a reference design](./Docs/loading_ref_proj.md)
* [Simulating a reference design](./Docs/simulating_a_design.md)
* [Building a reference design](./Docs/building_a_design.md)
* [Programming a reference design to the card](./Docs/programming_the_device.md)


## Supported Cards

The following card is supported by the reference designs in this repository.

* UL3524


## Vivado Design Support

The reference designs require the following Vivado release:

* Vivado ©️ 2023.1 or greater

The follow links provide Vivado flow support:

* [Vivado design flow](./Docs/vivado_design_flow.md)
* [UL3524 XDC file](./XDC/ul3524.xdc)

The [UL3524 Master Answer Record](https://support.xilinx.com/s/article/000035539) provides support resources such as known issues and release notes.  For additional assistance, post your question on the AMD Community Forums – [Alveo Accelerator Card](https://support.xilinx.com/s/topic/0TO2E000000YKXlWAO/alveo-accelerator-cards).


## Hardware Requirements

To program the device from the Vivado HW Manager:

* Micro-B USB cable or
* Alveo Debug Kit (ADK).  See [Alveo Accessories](https://www.xilinx.com/products/boards-and-kits/alveo/accessories.html) to purchase.

## Support

For additional documentation, please refer to the [UL3524 product page](https://www.xilinx.com/products/boards-and-kits/alveo/ul3524.html) and the [UL3524 Lounge](https://www.xilinx.com/member/ull-ea.html).

For support, contact your FAE or refer to support resources at: <https://support.xilinx.com>

<p class="sphinxhide" align="center"><sub>Copyright © 2020–2023 Advanced Micro Devices, Inc</sub></p>

<p class="sphinxhide" align="center"><sup><a href="https://www.amd.com/en/corporate/copyright">Terms and Conditions</a></sup></p>
