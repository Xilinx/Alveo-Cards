<table class="sphinxhide" width="100%">
 <tr width="100%">
    <td align="center"><img src="https://raw.githubusercontent.com/Xilinx/Image-Collateral/main/xilinx-logo.png" width="30%"/><h1>UL3422 Ultra Low Latency Trading</h1>
    </td>
 </tr>
</table>

# Vivado Design Flow

## Overview

Provides Vivado design flow support.

## Vivado XDC Files

The UL3422 Xilinx Design Constraints (XDC) file is located here [located here](../XDC/README.md).

## Creating a Vivado RTL Project

Currently with the XDC-based Vivado design flow, the UL3422 FPGA part is not currently visible via the Vivado GUI part selection window. Consequently, a project based on the UL3422 FPGA part must be created via the TCL command line.  Use the following steps to create a new project:

1. Launch Vivado tools.
2. In the Tcl console, run the following command:
`create_project <project> <path> -part <part number>`

where,
* `<project>` is the name of the project you want to create
* `<path>` is the path where you want to create the project
* `<part number>` is the Vivado FPGA part number: `XCVU2P-FSVJ2104-3-E`

## Device Configuration

The Alveo accelerator card supports two FPGA configuration modes:
* Quad SPI flash memory
* JTAG (over Micro-USB or ADK2 debug connector)

The FPGA bank 0 mode pins are hardwired to master SPI mode M[2:0] = 001 with pull-up/down resistors. At power up, the FPGA is configured by the QSPI flash device using the primary serial configuration mode. Refer to the XDC for recommended configuration parameters specified via the various BITSTREAM.CONFIG constraints.

For complete details on configuring the FPGA, see the [UltraScale Architecture Configuration User Guide (UG570)](https://docs.xilinx.com/v/u/en-US/ug570-ultrascale-configuration).

## MCS File Generation

This section outlines the steps to generate the MCS file.

The MCS file represents the PROM image which is loaded onto the FPGA at power on. It is generated using the *write_cfgmem* tool. This section outlines the steps to generate and program the MCS file. Prior to generating the MCS file, ensure your project XDC file sets the following properties. Recommended values are given in the XDC file.

```
CONFIG_VOLTAGE
BITSTREAM.CONFIG.CONFIGFALLBACK
BITSTREAM.GENERAL.COMPRESS
CONFIG_MODE
BITSTREAM.CONFIG.SPI_BUSWIDTH
BITSTREAM.CONFIG.CONFIGRATE
BITSTREAM.CONFIG.EXTMASTERCCLK_EN
BITSTREAM.CONFIG.SPI_FALL_EDGE
BITSTREAM.CONFIG.UNUSEDPIN
BITSTREAM.CONFIG.SPI_32BIT_ADDR
```

Use the following command with the parameters outlined in the following table to generate the MCS file.

`write_cfgmem -force -format mcs -interface <interface_type> -size <size> -loadbit "up <user_config_region_offset> <input_file.bit>" -file "<output_file.mcs>"`


| write_cfgmem Parameter | Setting |
|---|---|
| interface_type 				| spix4 |
| size 							| 256 |
| user_config_region_offset[1] 	| 0x01002000 |
| input_file.bit 				| Filename of the input .bit file |
| output_file.mcs 				| MCS output filename |

**TABLE**: write_cfgmem Parameter Settings


*[1] Address 0x00000000 through 0x01001FFF is a write protected region which holds the card's golden recovery image and cannot be written to. The user_config_region_offset setting cannot be within this range.*


For additional details on write_cfgmem, see the [UltraScale Architecture Configuration User Guide (UG570)](https://docs.xilinx.com/v/u/en-US/ug570-ultrascale-configuration).


## Card Programming

After the MCS file has been generated, use one of the following methods to flash the FPGA on the Alveo data center accelerator card.

### Programming via Vivado Hardware Manager

This section details how to flash the Alveo data center accelerator card FPGA using the Vivado hardware manager. Detailed steps for programming the FPGA are outlined in the chapter titled Programming the FPGA Device in the Vivado Design Suite User Guide: Programming and Debugging
(UG908).

1. Connect to the Alveo data center accelerator card using the Vivado hardware manager via the maintenance connector or micro USB port. Details on connecting to the Alveo card through the maintenance connector are provided in the Alveo Debug Kit User Guide (UG1538).
2. Right click on device xcvu2p_0, under the **Hardware** window, and select **Add Configuration Device** . Enter "mt25qu02g-spi-x1_x2_x4" in the search bar and select part mt25qu02g-spix1_x2_x4.
3. Select OK when prompted "Do you want to program the configuration memory device now?" or right-click the target to select **Program the Configuration Memory Device**.
	a. Select the MCS file target.
	b. Select Configuration File Only.
	c. Click OK.
4. After programming has completed, disconnect the card in the hardware manager, power off the server and card, and disconnect the JTAG programming cable from the Alveo accelerator card.
5. Perform a cold reboot on the host machine to complete the card update.

### Programming via xbflash2

This section details how to flash the Alveo data center accelerator card FPGA using the AMD board flash utility (xbflash2). Xbflash2 is a standalone command line utility used to flash a custom Vivado flow MCS image onto an Alveo card or to revert a card running a Vivado design back to its golden image over PCIe. Because it communicates directly with the card through the PCIe BAR, it does not require Xilinx Runtime (XRT) drivers (xocl/xclmgmt) to be installed or a programming cable. For xbflash2 command details, refer to the [xbflash2 command documentation](https://xilinx.github.io/XRT/master/html/xbflash2.html).

To program the card via the xbflash2 utility, a flashed and running design must have a flash controller (via the AXI Quad SPI IP) with proper configurations and mapping to the PCIe BAR.

**TIP:** *The manufacturing image (sometimes referred to as the golden image) comes pre-installed on new cards with the flash controller incorporated.*

Use the following to flash a card with xbflash2.

**Note:** The following steps assume the UL3422 card has the original manufacturing image installed.

When flashing a card with xbflash2 command, it is necessary to include the offset of the QUAD SPI IP/flash controller. The UL3422 manufacturing image offset is `0x1F06000`.

To flash a card with this offset, use the following command:

`sudo xbflash2 program --spi --image <MCS file> --bar-offset 0x1F06000 -d <Mgmt BDF>`

Where:
* MCS is the file to flash to the card.
* Mgmt BDF is the Management Bus:Device.Function assigned to the card being programmed.

After running this command, the new image will be flashed to your card.

Perform a cold reboot on the host machine to complete the card update.

See [Updating Vivado images via PCIe with xbflash](https://support.xilinx.com/s/article/Alveo-Updating-Vivado-images-via-PCIe-with-xbflash) for how to incorporate a flash controller in your design to enable xbflash.

## Accessing Card Details via UART

To identify information about your card, such as its revision, use the following steps to connect to the card SC via UART.

The following is required:

* Machine with terminal program
* Micro-B USB cable or ADK2 cable

1. Shut down and unplug power to the machine, and install the card (see Alveo UL3422 Installation Guide UG1643).
2. Connect the USB cable between the card (either front or rear USB port) and a laptop running a terminal program.
3. Power up the machine.
4. Within the terminal program, connect to the serial port attached to the SC:
	a. Open the terminal program.
	b. Connect to the serial com port using the following settings:
		i. 115200 baud
		ii. no parity
		iii. one stop bit
		
		***Note: You might have to try several com ports before selecting the correct one.***
c. After communication is connected, the following is displayed after pressing **Enter**.
```
--------------------------------------------------------------------
PERIPHERAL TESTS MAIN MENU
--------------------------------------------------------------------
1 Read Temperature
2 Read Voltage and Current
3 Read Power
4 Read ADC channels
5 Continuous Sensor Data Read
6 Print Board Info
7 Print Limits
8 Configure Limits
9 EEPROM Test
--------------------------------------------------------------------
```
Enter Option:
d. Enter `6` to display the board information. It will display an output similar to the following.
Card details, such as board Rev and base MAC address (MAC0), will be displayed.
```
------------------------------------------------
Product Name : ALVEO UL3422
Board Rev : C
Board Serial : xxxxxxxxxxxx
Num of MAC ID's (HEX): 64
Board MAC0 : 00:xx:xx:xx:xx:x
EEPROM Version : 3.0
Board A/P : P
Board Config : 07
PCIe Info : 10ee, 5098, 10ee, 000e
UUID : eda66f4a-c6a3-3d4a-9d40-db14ce957087
Memory Size : 16G
MFG DATE : 0b57d6
PART NUM : 05107-01
OEM ID : 000010da
FW Ver : 10.1.6
BSL vendor ver : 0100
BSL CI ver : 0400
BSL API ver : 0800
BSL PI ver : 0600
BSL build ID : 0016
------------------------------------------------
```

## Support

For additional documentation, please refer to the [UL3422 product page](https://www.xilinx.com/products/boards-and-kits/alveo/ul3422.html) and the [UL3422 Lounge](https://www.xilinx.com/member/ull-ea.html).

For support, contact your FAE or refer to support resources at: <https://support.xilinx.com>


<hr class="sphinxhide"></hr>

<p class="sphinxhide" align="center"><sub>Copyright © 2024 Advanced Micro Devices, Inc.</sub></p>

<p class="sphinxhide" align="center"><sup><a href="https://www.amd.com/en/corporate/copyright">Terms and Conditions</a></sup></p>
