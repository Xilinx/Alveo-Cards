<table class="sphinxhide" width="100%">
 <tr width="100%">
    <td align="center"><img src="https://raw.githubusercontent.com/Xilinx/Image-Collateral/main/xilinx-logo.png" width="30%"/><h1>UL3524 Ultra Low Latency Trading</h1>
    </td>
 </tr>
</table>

# GTF Latency Synchronized Design

## Description

The following two benchmark designs demonstrates the GTF latency operating in MAC & RAW mode with GTF operating in internal near-end loopback.  The benchmark designs are phase controlled with TXUSRCLK and RXUSRCLK operating at the same frequency but 180 degrees out of phase.

* [Synchronized MAC Reference Design](./GTFMAC_Latency_10G_Sync/README.md)

* [Synchronized RAW Reference Design](./GTFRAW_Latency_10G_Sync/README.md)

In addition to the reference design, each project contains a *Scripts* directory containing scripts to run benchmark design in Vivado H/W Manager to reproduce reported latencies.  Description of the scripts are given in the respective links:

* [Synchronized MAC Scripts](./GTFMAC_Latency_10G_Sync/Scripts/README.md)

* [Synchronized RAW Scripts](./GTFRAW_Latency_10G_Sync/Scripts/README.md)

## Support

For additional documentation, please refer to the [UL3524 product page](https://www.xilinx.com/products/boards-and-kits/alveo/ul3524.html) and the [UL3524 Lounge](https://www.xilinx.com/member/ull-ea.html).

For support, contact your FAE or refer to support resources at: <https://support.xilinx.com>

<p class="sphinxhide" align="center"><sub>Copyright © 2020–2023 Advanced Micro Devices, Inc</sub></p>

<p class="sphinxhide" align="center"><sup><a href="https://www.amd.com/en/corporate/copyright">Terms and Conditions</a></sup></p>
