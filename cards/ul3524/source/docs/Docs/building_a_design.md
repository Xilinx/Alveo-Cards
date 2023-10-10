<table class="sphinxhide" width="100%">
 <tr width="100%">
    <td align="center"><img src="https://raw.githubusercontent.com/Xilinx/Image-Collateral/main/xilinx-logo.png" width="30%"/><h1>UL3524 Ultra Low Latency Trading</h1>
    </td>
 </tr>
</table>

# Building a Reference Design

## Overview

Details on how to build a reference design.

## Instructions

Synthesis, implementation, and bitstream generation can be run through the GUI or Tcl commands in Vivado.

Prior to following the below steps, ensure that the reference design has been successfully loaded and created (see [Loading a Reference Design Vivado Project](loading_ref_proj.md)).

1. Click on **Run Synthesis** in Vivado or run the following Tcl commands to synthesize the design.

```tcl
launch_runs synth_1
wait_on_run synth_1
```

2. Click on **Run Implementation** in Vivado or run the following Tcl commands to implement the design.

```tcl
launch_runs impl_1
wait_on_run impl_1
```

3. Click on **Generate Bitstream** in Vivado or run the following Tcl command to generate the bitstream for the design.

```tcl
write_bitstream 
```

## Next Steps

Next steps can include:

* [Simulating a design](simulating_a_design.md#Overview)
* [Programming the device](programming_the_device.md#Overview)

## Support

For additional documentation, please refer to the [UL3524 product page](https://www.xilinx.com/products/boards-and-kits/alveo/ul3524.html) and the [UL3524 Lounge](https://www.xilinx.com/member/ull-ea.html).

For support, contact your FAE or refer to support resources at: <https://support.xilinx.com>

<p class="sphinxhide" align="center"><sub>Copyright © 2020–2023 Advanced Micro Devices, Inc</sub></p>

<p class="sphinxhide" align="center"><sup><a href="https://www.amd.com/en/corporate/copyright">Terms and Conditions</a></sup></p>