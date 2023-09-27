<table class="sphinxhide" width="100%">
 <tr width="100%">
    <td align="center"><img src="https://raw.githubusercontent.com/Xilinx/Image-Collateral/main/xilinx-logo.png" width="30%"/><h1>UL3524 Ultra Low Latency Trading</h1>
    </td>
 </tr>
</table>

# GTF Recovery Clock Hardware Manager Tcl Scripts
This folder contains the Tcl scripts used to exercise the design with the hardware manager.

## Tcl File Descriptions
The script 'runme.tcl' in the */scripts/HwMgr/* directory is the primary script that loads the other helper functions.  The following table provides a basic decription of the helper script file contents.

| Script Name | Description |
| --- | --- |
| runme.tcl | Primary script to load all helper functions |
| procs_gtf.tcl | Functions related to GTF reset, configuration, and data flow  |
| procs_renesas.tcl | Functions related to Renesas GPIO, reset, and I2C programming |
| procs_system.tcl | Common register access, user display, freq measurement functions |
| addr_register.tcl | Set a number of common system addresses accessible by the other functions |

## Common Helper Functions
The following table lists the primary helper functions as a starting point most useful to the user.  After loading the helper functions, the functions can be run from the Vivado Tcl console.

| Function Name | Description |
| --- | --- |
| setup <-help> <-n_chan 4> | Initializes the GTF's.  User can specify the number of channels (Default = 4). Use help parameter to print command usage. |
| runme <-help> <-n_chan 4> <-n_frames 0> <-n_cycles 1> <-delay 5000> | Initiates a data transfer. User can specify the number of channels, the number of packets sent (0 = continuous), number of test cycles, and the cycle duration (in ms). Use help parameter to print command usage. |
| load_renesas_i2c_bram <COE filename> | Programs the COE memory file into the FPGA BRAM to later be sent the to JC   |
| load_renesas_i2c_bram <config #> <enable I2C xfer> | Switches the Renesas config mode.  Setting the I2c xfer to 1 will transfer the BRAM contents to the JC |
| measure_frequency | Samples the clocks connected to the frequency monitor and displays their frequencies in Mhz |

**Table 1.** Helper function descriptionsa

## Example Default Usage
If desired, two prebuilt bitstreams (a 1 channel example, and a 4 channel example) are located in the projects 'Example' folder found here.  The default scripts assume a 4 channel design is loaded on the FPGA.  

Once the design's bitstream has been loaded into the FPGA, use the Tcl console to cd to the folder containing the HwMgr scripts shown in this folder.
In the Tcl Console, type 'source ./runme.tcl' to load the available helper functions.  Sourcing this file will automatically preload all the other include Tcl scripts.
Next type 'setup' to reset, initialize and link the 4 GTF channels.
If successful, type 'runme' to do a default transfer.  The default runme function will transmit 5 seconds of continuous data and will display a log similar to the following...

```bash
#
# Running Data Stream...
#
Num Channels     = 4
Num Cycles       = 1
Num Frames/Cycle = 0 (cont.)
Cycle Delay(ms)  = 5000
Cycle 1 Channel 0, Packets = 78309826, FIFO Wr Count = 587322522, FIFO RD Count = 587322522, FIFO ERR Count = 0
Cycle 1 Channel 1, Packets = 78309826, FIFO Wr Count = 587322503, FIFO RD Count = 587322503, FIFO ERR Count = 0
Cycle 1 Channel 2, Packets = 78309826, FIFO Wr Count = 587322501, FIFO RD Count = 587322501, FIFO ERR Count = 0
Cycle 1 Channel 3, Packets = 78309826, FIFO Wr Count = 587322507, FIFO RD Count = 587322507, FIFO ERR Count = 0
#
# Complete...
#
```

## Custom Test Runs
As detailed above, the setup and runme functions have default configurations for a 4 channel interface.  Using the command line parameter allows the user to generate different test configurations.

Note: Both commands have a '-help' parameter to display the their command line parameters in the Tcl Console.

***"setup" command***
| Parameter | Default Value | Description |
| --- | --- | --- |
| -help | N/A | Displays command usage |
| -n_chan | 4 | Specifies number of channels to initialize |

```bash
Example #1 : Display command line parameters

    setup -help

Example #2 : Configure and initialize two channels   

    setup -n_chan 2
```

***"runme" command***
| Parameter | Default Value | Description |
| --- | --- | --- |
| -help | N/A | Displays command usage |
| -n_chan | 4 | Specifies number of channels to use |
| -n_frames | 0 | If 0, use continuous data transfer until cycle delay time is complete.  Otherwise indicates nubmer of packets to transfer |
| -n_cycles | 1 | Specifies number of test iterations (cycles) to run |
| -dekay | 5000 | Specifies delay in ms to run at iteration |

```bash
Example #1 : Display command line parameters

    runme -help

Example #2 : Two channels operational with 3 iterations of 10 packets each.  

    runme -n_chan 2  -n_cycles 3  -n_frames 10

Example #3: Four channels operational (default) with five continuous(default) iterations of 1 minute (60000ms) each. 

    runme -n_cycles 5  -delay 60000
```

## Support
For additional documentation, please refer to the [UL3524 product page](https://www.xilinx.com/products/boards-and-kits/alveo/ul3524.html) and the [UL3524 Lounge](https://www.xilinx.com/member/ull-ea.html).

For support, contact your FAE or refer to support resources at: https://support.xilinx.com

<p class="sphinxhide" align="center"><sub>Copyright © 2020–2023 Advanced Micro Devices, Inc</sub></p>

<p class="sphinxhide" align="center"><sup><a href="https://www.amd.com/en/corporate/copyright">Terms and Conditions</a></sup></p>
