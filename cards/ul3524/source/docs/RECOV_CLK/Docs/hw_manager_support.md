<table class="sphinxhide" width="100%">
 <tr width="100%">
    <td align="center"><img src="https://raw.githubusercontent.com/Xilinx/Image-Collateral/main/xilinx-logo.png" width="30%"/><h1>UL3524 Ultra Low Latency Trading</h1>
    </td>
 </tr>
</table>

# GTF Recovery Clock Routing Operation in Hardware

This section provides steps to run the GTF Recovery Clock Routing design on the UL3524 via the Vivado HW Manager.

The key steps to run the design are:

1. Program the device
 * Program the UL3524 with the bitstream (.bit) and ILA (.ltx).
 * (Optional) Enable ILA to capture and view waveforms
2. Load the Tcl helper functions
3. Initialize the GTF's, configure the Jitter Cleaner, and enable and transfer a data stream
4. Check data integrity status

These steps are described in detail below.

## Programming the Device

It is necessary to program the device with the reference design prior to running the design.  Generate the design and create the bit file prior to following these steps.

1. [Connect to the card via the HW Manager and program the FPGA](../../Docs/programming_the_device.md) with the following files:
   * `./RECOV_CLK/Vivado_Project/<project_name>/<project_name>.runs/impl_1/clk_recov.bit`
   * `./RECOV_CLK/Vivado_Project/<project_name>/<project_name>.runs/impl_1/clk_recov.ltx`
2. In the Vivado Tcl console, change the working directory to the following:
   * `cd ./RECOV_CLK/scripts/HwMgr`
3. Use the following command to load the helper functions to control the board.
   * `source ./runme.tcl`

## Tcl Files

Once the project has been loaded, the design can be exercised using Tcl scripts found [here](../scripts/HwMgr/README.md).
The scripts include setup, loading Renesas settings and measuring clock frequencies.

## Support

For additional documentation, please refer to the [UL3524 product page](https://www.xilinx.com/products/boards-and-kits/alveo/ul3524.html) and the [UL3524 Lounge](https://www.xilinx.com/member/ull-ea.html).

For support, contact your FAE or refer to support resources at: <https://support.xilinx.com>

<p class="sphinxhide" align="center"><sub>Copyright © 2020–2023 Advanced Micro Devices, Inc</sub></p>

<p class="sphinxhide" align="center"><sup><a href="https://www.amd.com/en/corporate/copyright">Terms and Conditions</a></sup></p>
