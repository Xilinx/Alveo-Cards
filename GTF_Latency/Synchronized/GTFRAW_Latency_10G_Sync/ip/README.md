<table class="sphinxhide" width="100%">
 <tr width="100%">
    <td align="center"><img src="https://raw.githubusercontent.com/Xilinx/Image-Collateral/main/xilinx-logo.png" width="30%"/><h1>UL3524 Ultra Low Latency Trading</h1>
    </td>
 </tr>
</table>

# GTF RAW Synchronized Latency Measurement Design

![construction](docs/images/construction.png)

## Description
This design demonstrates the GTF latency operating in RAW mode with the GTF in internal near-end loopback.  

It is a phase controlled GTF latency design used with TXUSRCLK and RXUSRCLK operating at the same frequency but 180 degrees out of phase. 

For instructions to build/sim/test the design go to the [Vivado_Project](./Vivado_Project/) folder.

## Architecture

The high-level block diagram for the RAW GTF latency design is shown below.  It consists of the following key blocks:
•	GTF DUT Example (RAW) with changes/additions to…
o	PRBS Tx RawData Generator
o	PRBS Rx RawData Monitor
o	Error Injection Logic
•	Latency Monitor
•	GTF Link Status Logic
•	System Register Array with JTAG AXI interface module
•	System Clock/Reset Generation
•	System VIO for system status
![](../
 Running design consists of the following high-level operations:
The system is released from reset allowing the GTF to initialize in near-end loopback mode.
This includes enabling the PRBS Tx RawData generator to provide a constant stream of Tx to the GTF.
The PRBS Rx RawData monitor inspects the looped data from the GTF.  This involves sampling the RxRawData bus and performing bit alignment by regenerating the PRBS sequence.
The PRBS RxRawData monitor will report PRBS errors to the link status logic.  Once bit alignment has been achieved, the PRBS errors will disappear, and the link will stabilize.  
The software will enable the latency monitor and instruct the error injection logic to periodically invert the TxRawData bus.  This will result in a PRBS error detected in the RxRawData monitor.  
Note: a single PRBS error will not result in loss of link status.  The logic filters these events assuming they are related to the error injection logic.
The latency monitor observes the error injection and detection events and records their timestamps from a freerunning timer.
The software polls the latency monitor, pulls the timestamps when they are available, and computes the latency through the GTF.
Error detection and measurement activity can be captured using ILA’s.

## GTF RAW DUT
The GTF RAW DUT was generated using Vivado’s GTF wizard.  The GTF transceiver configuration preset field was set to GTF-10G-RAW in the GTF Wizard.  All preset wizard settings for this configuration were unchanged.  An image of the ‘Basic’ GTF Wizard tab is shown below for reference.

## Clock Routing
The GTF MAC DUT is slightly modified to redefine the RXUSRCLK and TXUSRCLK. By default, these clocks are generated independently from the GTF to drive the data paths in the programmable logic region. The modified RTL uses the RXOUTCLK as a source to both RXUSRCLK and TXUSRCLK. The two clocks are aligned with 180 degrees of phase.  

PRBS TxRawData Generator
The PRBS TxRawData generator module generates a continuous stream of 16bit PRBS values that are fed to the TxRawData port of the GTF.  The stream is used as a sync pattern used by the Rx Monitor to help determine when the system link is stable.
Error Injection Logic
The Tx generator creates a deterministic continuous data stream to the GTF.  To generate a Tx event for the latency monitor, the error injection logic will invert the TxRawData value for a single clock cycle.  This interruption will result in a PRBS error in the Rx Monitor.  
Software can control the number and rate of injection events by setting two control registers.  The logic is then enabled by setting a bit in the system control register.  Once the operation has been completed, the error injection logic disables and allows the Tx data stream to continue as normal.

PRBS RxRawData Monitor
The PRBS RxRawData monitor module continuously samples the RxRawData bus from the GTF.  This data sample is likely not bit-aligned and therefore does not immediately reflect the corresponding TxRawData stream.  The Rx monitor performs a sequence of bit shifting the sample data while attempting to recreate the PRBS stream.  If the data is bit aligned, the logic should be able to calculate the next Rx data sample.  Once the PRBS sequence is stable, the logic locks in the bit alignment and continues to monitor the incoming data stream.
The Rx Monitor outputs the PRBS lock status to the link status logic and latency monitor.  Before the system is finished initializing, PRBS error indicates that the GTF needs more time to complete its link initialization process.  After the system becomes stable, single PRBS errors indicate injected error events.  

Latency Monitor
The latency monitor captures the event markers from the error injection logic (Tx) and Rx monitor.  These events are used to sample timestamps that represent when a data pattern is latched into the GTF TxRawData port and when it’s detected back in the Rx Monitor.  
(need more here!!!!)
System Clock/Reset
This module a basic logic block to provide basic freerunning clocks and resets for the AXI interfaces.
VIO System
This module is a basic VIO to quickly display system status such as link status, reset settings, etc.

Detailed Rx Monitor Logic
The Rx Monitor is a register pipeline that samples and bit aligns the RxRawData bus while monitoring the expected PRBS data stream and reporting status for the system and latency monitor.  This pipeline is detailed in the following figure:

The RxRawData bus from the GTF will probably not be bit aligned which results in RxRawData not exactly matching TxRawData.  The pipeline starts by registering the RxRawData bus directly from the GTF (forces direct point to point routing without interference from other fabric resources).  The sampled 16-bit value is concatenated with the previous sampled value to create a single 32-bit value.  
The 32-bit value is then broken into sixteen 16-bit registers representing the possible bit shifts needed to bit align the incoming data stream.  This effectively creates sixteen parallel pipelines representing a different bit shift configuration.
A timer is used as a window control to mux through “parallel pipelines”.  Each pipeline is selected for 128 clocks before moving to the next pipeline.  The selected pipeline is sampled and passed through a PRBS calculation to predict the next data value  If the prbs output matches the next data stream value, the timer is halted thereby allowing the current selected pipeline to continue.  If the prbs output does not match the next data stream value, the timer will increment and eventually select the next pipeline.  
If the Tx/Rx data path is stable, eventually the Rx Monitor pipeline will converge on a bit shift pipeline that consistently generates correct PRBS values that match the next data stream value.
PRBS errors are reported to the system link status logic and latency monitor.  
Until the GTF link is stable, the Rx monitor will report a large number of PRBS errors.  Eventually, the Rx monitor will bit align the data stream and will stop reporting PRBS errors.  At this point, the status logic will monitor for errors and eventually declare that the link is stable.
During the latency measurements, PRBS errors are intentionally inserted into the TxRawData data stream.  Reporting these errors to the system link status logic will incorrectly result in resetting the GTF.   To prevent this, the Rx monitor filters out single event PRBS errors attributing them to intentional errors.  Only “large scale” PRBS errors are reported to the link status logic.
However, all PRBS errors are reported to the latency monitor.  Once the system is stable and the latency monitor is enabled, the PRBS errors are used to sample timestamps for Rx events.

Detailed Latency Monitor Logic

Clock Domain Crossing Considerations
Detailed Latency Calculations

## Support
For additional documentation, please refer to the [UL3524 product page](https://www.xilinx.com/products/boards-and-kits/alveo/ul3524.html) and the [UL3524 Lounge](https://www.xilinx.com/member/ull-ea.html).

For support, contact your FAE or refer to support resources at: https://support.xilinx.com

<p class="sphinxhide" align="center"><sub>Copyright © 2020–2023 Advanced Micro Devices, Inc</sub></p>

<p class="sphinxhide" align="center"><sup><a href="https://www.amd.com/en/corporate/copyright">Terms and Conditions</a></sup></p>
