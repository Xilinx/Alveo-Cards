<table class="sphinxhide" width="100%">
 <tr width="100%">
    <td align="center"><img src="https://raw.githubusercontent.com/Xilinx/Image-Collateral/main/xilinx-logo.png" width="30%"/><h1>UL3524 Ultra Low Latency Trading</h1>
    </td>
 </tr>
</table>

# Loading a Reference Design Vivado Project

## Overview

Details how to load a reference design and create the Vivado project.

## Instructions

Use the `setup.tcl` script to load a specific reference design.

The script will:

* Create the project
* Add source RTL files to the project
* Generate any IP needed
* Generate any IPI block design needed

NOTE: Ensure you have read/write access to the folders.

1. Open Vivado (either GUI or Tcl mode)
   * If opening the GUI, enter CTRL+Shift+T to open the Tcl console window
2. From within the Vivado Tcl command line, change directory to the **Vivado_Project** of the specific reference design to be loaded.

```bash
cd ./<reference_design_name>/Vivado_Project/
```

1. Run the following TCL script from within the Vivado TCL command line to create and load the design:

```bash
source ./setup.tcl
```

1. A directory with all the project files will be created in:

```bash
./<reference_design_name>/Vivado_Project/<project_name>
```

Once the script is complete, the following message will be displayed:

```bash
# ------------------------------------------------------
#
# Setup Complete...
#
# ------------------------------------------------------
```

Synthesis and implementation can be run through the GUI or Tcl command line.

## Next Steps

Next steps can include:

* [Simulating a design](simulating_a_design.md#Overview)
* [Building a design](building_a_design.md#Overview)

## Support

For additional documentation, please refer to the [UL3524 product page](https://www.xilinx.com/products/boards-and-kits/alveo/ul3524.html) and the [UL3524 Lounge](https://www.xilinx.com/member/ull-ea.html).

For support, contact your FAE or refer to support resources at: <https://support.xilinx.com>

<p class="sphinxhide" align="center"><sub>Copyright © 2020–2023 Advanced Micro Devices, Inc</sub></p>

<p class="sphinxhide" align="center"><sup><a href="https://www.amd.com/en/corporate/copyright">Terms and Conditions</a></sup></p>
