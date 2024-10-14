<table class="sphinxhide" width="100%">
 <tr width="100%">
    <td align="center"><img src="https://raw.githubusercontent.com/Xilinx/Image-Collateral/main/xilinx-logo.png" width="30%"/><h1>UL3422 Ultra Low Latency Trading</h1>
    </td>
 </tr>
</table>

# QSFP I2C Reference Design: HW Manager Support

This section provides instructions to observe the behavior of the design through the HW Manager.
In addition, the included script provides reference code demonstrating communication with the card.  Details of the script functions are detailed below.

## Programming the Device

1. [Connect to the card via the HW Manager and program the FPGA](../../Docs/programming_the_device.md) with the following files:

* `./QSFP_I2C/Vivado_Project/<project_name>/<project_name>.runs/impl_1/qsfp_i2c_top.bit`
* `./QSFP_I2C/Vivado_Project/<project_name>/<project_name>.runs/impl_1/qsfp_i2c_top.ltx`

2. (Optional) To enable ILA waveform capture, perform the following steps:

* Right click on the device (xcvu2p_0) and click on *Refresh Device*.
* Set up ILA trigger as desired.
* Trigger all the ILAs by clicking on *Run trigger for this ILA core*

## ILA

An ILA is included in the design to observe and verify the behavior of the design on HW.

**NOTE**: It is necessary to enable ILAs in order to capture and view the waveform.

## Tcl Script

A provided script (located at `Scripts/qsfp.tcl`) contains three top-level functions to help facilitate basic QSFP operations which are summarized in the following table.  

**Note**: All functions operate on QSFP 0 but can be modified or expanded to operate on any number of the four available QSFP ports.

| Name | Function | Summary |
|---|---|---|
| qsfp_enable_power | QSFP power domains | Enables power to QSFP 0 and takes it out of reset (disable_qsfp_power, enable_qsfp_power)|
| qsfp_scan_loop | I2C Routing | This function uses a polling loop to determine if the QSFP 0 module has been inserted or removed (select_qsfp_sb, select_qsfp_i2c) |
| qsfp_access_i2c | QSFP sideband peripherals access| Demonstrates how to access QSFP sideband peripherals by reading the supply voltage and temperature sensors of the QSFP module. |

**TABLE**: Top-level QSFP Tcl Functions

### Running the Scripts

Prior to running the script, ensure the bit file has been programmed.

1. In the Vivado Tcl console, change the working directory to the following:
   * `cd ./QSFP_I2C/Scripts`
2. Use the following command to load the demo functions.
   * `source ./qsfp.tcl -notrace`
3. Once completed, type in the desired demo function.

    For example, executing 'qsfp_enable_power' from the tcl console will generated the following output:

    ```console
    -- Deassert Resets to I2C I/O Expanders and Switches and I2C Controller
    
    -- Disable and re-enable QSFP power domains...
    -- Disable Power to QSFP 1-4  (set output value and output enable)
    [i2c_rd] 0x42 0x0 = 0x000000ff
    [i2c_wr] 0x42 0x1 = 0x00
    [i2c_wr] 0x42 0x3 = 0x55
    [i2c_rd] 0x42 0x0 = 0x00000000
    -- Enable Power to QSFP 1-4  (set output value and output enable)
    [i2c_rd] 0x42 0x0 = 0x00000000
    [i2c_wr] 0x42 0x1 = 0xAA
    [i2c_wr] 0x42 0x3 = 0x55
    [i2c_rd] 0x42 0x0 = 0x000000ff
    
    -- Enable QSFP 0...
    -- Select Gate Mux's to QSFP 0 SB
    [i2c_wr] 0xE0 0x01 = 0x01
    [i2c_wr] 0xE4 0x00 = 0x00
    -- Asserting QSFP Reset
    [i2c_wr] 0x40 0x01 = 0x00
    [i2c_wr] 0x40 0x03 = 0x06
    -- Deasserting QSFP Reset
    [i2c_wr] 0x40 0x01 = 0x10
    [i2c_wr] 0x40 0x03 = 0x06
    -- Reading QSFP SB Status
    [i2c_rd] 0x40 0x00 = 0x00000012
    0x00000012
    ```

   Executing 'qsfp_scan_loop' will continuously scan for module insertion status.  Once started, the log will resemble the following as the user physically removes or inserts a QSFP module in port 0.

    ```console
    Example Loop to Check for Module Insertion/Removal...
    QSFP Module Inserted...
    QSFP Module Removed...
    QSFP Module Inserted...
    ```

    Executing 'qsfp_access_i2c' will access a few registers in the QSFP module via it's I2C interface.  Below is an example of a few basic acceses for temperature and voltage measurements.  Actual register mapping may vary based on the modules used.

    ```console
    Example QSFP 0 MODULE I2C Access...
    -- Select Gate Mux's to QSFP 0 I2C
    [i2c_wr] 0xE0 0x02 = 0x02
    [i2c_wr] 0xE4 0x00 = 0x00
    
    -- Read Module State Register (Lower Page, Address 0x03)
    [i2c_rd] 0xA0 0x03 = 0x00000007
    
    -- Read Module Supply Voltage MSB (Lower Page, Address 0x10)
    [i2c_rd] 0xA0 0x10 = 0x00000081
    -- Read Module Supply Voltage LSB (Lower Page, Address 0x11)
    [i2c_rd] 0xA0 0x11 = 0x0000001b
    -- Calculated Supply Voltage : 3.305 Volts
    
    -- Read Module Temp MSB 1 (Lower Page, Address 0x18)
    [i2c_rd] 0xA0 0x18 = 0x00000020
    -- Read Module Temp LSB 1 (Lower Page, Address 0x19)
    [i2c_rd] 0xA0 0x19 = 0x00000000
    -- Calculated Module Temp 1 : 32.0 'C
    
    -- Read Module Temp MSB 2 (Page 3, Address 0x98)
    [i2c_wr] 0xA0 0x7F = 0x03
    [i2c_rd] 0xA0 0x98 = 0x0000001f
    -- Read Module Temp LSB 2 (Page 3, Address 0x99)
    [i2c_wr] 0xA0 0x7F = 0x03
    [i2c_rd] 0xA0 0x99 = 0x00000000
    -- Calculated Module Temp 2 : 31.0 'C
    
    -- Read Module Temp MSB 3 (Lower Page, Address 0x0E)
    [i2c_rd] 0xA0 0x0E = 0x00000020
    -- Read Module Temp LSB 3 (Lower Page, Address 0x0F)
    [i2c_rd] 0xA0 0x0F = 0x00000000
    -- Calculated Module Temp 3 : 32.0 'C
    
    -- Read Module Temp MSB 4 (Page 3, Address 0x9A)
    [i2c_wr] 0xA0 0x7F = 0x03
    [i2c_rd] 0xA0 0x9A = 0x00000020
    -- Read Module Temp LSB 4 (Page 3, Address 0x9B)
    [i2c_wr] 0xA0 0x7F = 0x03
    [i2c_rd] 0xA0 0x9B = 0x00000000
    -- Calculated Module Temp 4 : 32.0 'C
    ```

## Support

For additional documentation, please refer to the [UL3422 product page](https://www.xilinx.com/products/boards-and-kits/alveo/ul3422.html) and the [UL3422 Lounge](https://www.xilinx.com/member/ull-ea.html).

For support, contact your FAE or refer to support resources at: <https://support.xilinx.com>


<hr class="sphinxhide"></hr>

<p class="sphinxhide" align="center"><sub>Copyright © 2024 Advanced Micro Devices, Inc.</sub></p>

<p class="sphinxhide" align="center"><sup><a href="https://www.amd.com/en/corporate/copyright">Terms and Conditions</a></sup></p>
