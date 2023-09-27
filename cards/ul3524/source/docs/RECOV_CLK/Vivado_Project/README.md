<table class="sphinxhide" width="100%">
 <tr width="100%">
    <td align="center"><img src="https://raw.githubusercontent.com/Xilinx/Image-Collateral/main/xilinx-logo.png" width="30%"/><h1>UL3524 Ultra Low Latency Trading</h1>
    </td>
 </tr>
</table>

# Vivado Project
This folder contains scripts for recreating reference design Vivado projects and for configuring the HW Manager elements (e.g., ILA, VIO, etc.). 

To load and create this reference design using the provided *setup.tcl* script, see [Loading a Reference Design Vivado Project](../../Docs/loading_ref_proj.md).

**NOTE**:  The design defaults to 4 channels.  This can be modified by changing the NUM_CHANNEL parameter in RTL/clk_recov.v shown below.

```bash
module clk_recov #(
    parameter SIMULATION = "false",
    parameter integer NUM_CHANNEL = 4
) (

```bash

<p class="sphinxhide" align="center"><sub>Copyright © 2020–2023 Advanced Micro Devices, Inc</sub></p>

<p class="sphinxhide" align="center"><sup><a href="https://www.amd.com/en/corporate/copyright">Terms and Conditions</a></sup></p>
