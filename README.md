<table class="sphinxhide" width="100%">
 <tr width="100%">
    <td align="center"><img src="https://raw.githubusercontent.com/Xilinx/Image-Collateral/main/xilinx-logo.png" width="30%"/><h1>UL3524 Ultra Low Latency Trading</h1>
    </td>
 </tr>
</table>

# UL3524 Reference Designs

## Overview

This repository provides various Vivado based reference designs which target features of the card and can be used as a reference for subsequent designs.
Each reference design is located in a specific sub-folder in the repo and includes:

* High-level design overview
* Simulation waveform files with waveform descriptions to better understand the design
* Hardware design files along with ILA / VIO configuration files allowing greater control and visibility into the design  

Documentation includes a high level summary of the design’s attributes, performance, limitations and usage.

See [Next Steps](#next-steps) for details on loading, simulating, building and running a reference design in hardware.

## Available Reference Designs

Available reference designs, along with a high-level summary, are given in the following table.  Specific reference designs, including design files and documentation are located in the respective sub-directory.

| Reference Design | Summary |
|---|---|
| [GTF_LATENCY_BENCHMARK](./GTF_Latency/README.md) | Benchmark design used to measure and report GTF in MAC and RAW 10G latency.|
| [GTF_RECOV_CLK](./RECOV_CLK/README.md) | Demonstrates how to setup the QSFP-DD Renesas device and route the GTF recovered clock through Bank 65|
| [PCIE_DDR](./PCIE_DDR/) | DDR I2C and MIG bring-up and validation through PCIe |
| [QDR_MIG](./QDR_MIG/) | Interface with the QDRII+ Memory Controller through AXI. |
| [QSFP_I2C](./QSFP_I2C/)  | Enable QSFP module power planes and side-band signals via I2C interface.|
| [Renesas I2C Programming](./Renesas_I2C_Programming/)  | Program the Renesas devices via I2C using a state machine.  Includes script to convert Renesas programming script file to .coe BRAM file format.|

**TABLE**: Available Reference Designs

## Supported Cards

The following card is supported by the reference designs

* UL3524

## Requirements

The following are required to use any of the reference designs:

* Vivado ©️ 2023.1 or greater

To program the device from the Vivado HW Manager:

* Micro-B USB cable

## Next Steps

Follow the links to learn more on:

* [Loading a design](./Docs/loading_ref_proj.md)
* [Simulating a design](./Docs/simulating_a_design.md)
* [Building a design](./Docs/building_a_design.md)
* [Programming the device](./Docs/programming_the_device.md)

## Support

For additional documentation, please refer to the [UL3524 product page](https://www.xilinx.com/products/boards-and-kits/alveo/ul3524.html) and the [UL3524 Lounge](https://www.xilinx.com/member/ull-ea.html).

For support, contact your FAE or refer to support resources at: <https://support.xilinx.com>

<p class="sphinxhide" align="center"><sub>Copyright © 2020–2023 Advanced Micro Devices, Inc</sub></p>

<p class="sphinxhide" align="center"><sup><a href="https://www.amd.com/en/corporate/copyright">Terms and Conditions</a></sup></p>
