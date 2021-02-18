<table class="sphinxhide">
 <tr>
   <td align="center"><img src="https://www.xilinx.com/content/dam/xilinx/imgs/press/media-kits/corporate/xilinx-logo.png" width="30%"/><h1>Alveo Debug Guide</h1>
   </td>
 </tr>
</table>

# SC Troubleshooting

This can help to determine if any communication break has happened between SC<->CMC . It is part of the larger Alveo debug guide. If you are just starting to debug please consult [main page](../README.md).

## This Page Covers

This page covers issues observed when running the  `xbmgmt flash --scan` and  `xbutil query` commands and which can be related to SC issues.

## You Will Need
 
Before beginning debug, you need to:

- [Root/sudo permissions](common-steps.md#root-sudo-access)
- [Confirm System Compatibility](check-system-compatibility.md)
- [Determine XRT version](common-steps.md#determine-xrt-version) installed.
- [Determine platform and SC on card and system](common-steps.md#determine-platform-and-sc-on-card-and-system)
  - Card platform and SC must match that installed on system

## Common Cases

### Partition displayed under `Flashable partition running on FPGA` and `Flashable partitions installed in system` are identical.

When the platform has been installed correctly, the partition and SC version running on the FPGA and installed on the system will be identical.  The installed partitions can be displayed using the `xbmgmt flash --scan` command.  An example output is shown below.

 ```
 Card [0000:c3:00.0]
    Card type:          u50
    Flash type:         SPI
    Flashable partition running on FPGA:
        xilinx_u50_gen3x16_xdma_201920_3,[ID=0xf465b0a3ae8c64f6],[SC=5.0.27]
            Logic UUID:
            f465b0a3ae8c64f619bc150384ace69b
    Flashable partitions installed in system:
        xilinx_u50_gen3x16_xdma_201920_3,[ID=0xf465b0a3ae8c64f6],[SC=5.0.27]
 ```
Next step:
- None, this is expected output

- - -
### `xbmgmt flash --scan` Returns `bad magic number` Error

If `xbmgmt flash --scan` command returns `bad magic number` error as in the example below, there is a chance of a communication break between XRT and CMC.  The CMC is not reading the pre-programmed magic number (0x74736574), an on card self check hex string.

 ```
 read reg ERROR
 ERROR: Failed to detect XMC, bad magic number: 7fff
 read reg ERROR
 ERROR: Failed to detect XMC, bad magic number: 7fff
 Card [0000:af:00.0]
     Card type:                       u250
     Flash type:                      SPI
     Flashable partition running on FPGA:
         xilinx_u250_xdma_201830_2,[ID=0x5d14fbe6],[SC=INACTIVE]
     Flashable partitions installed in system:             
         xilinx_u250_xdma_201830_2,[ID=0x5d14fbe6],[SC=4.2.0]

 ```
Next steps:
- Cold boot the system
  - Perform `xbmgmt flash --scan`
- If issue persists
  - Pull power to the system
  - Perform `xbmgmt flash --scan`
- If issue persists
  - [Reinstall the platforms](modifying-xrt-platform.md#platform-re-install)
  - Perform `xbmgmt flash --scan`
- If these steps do not resolve the issue look on the [Xilinx forums](https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo)

- - -
### `xbmgmt flash --scan` Returns `XMC not loaded` Error

If `xbmgmt flash --scan` command returns `XMC not loaded` error as shown below ,there is communication break between XRT and CMC.

```
ERROR: Failed to detect XMC, xmc.bin not loaded
ERROR: Failed to detect XMC, xmc.bin not loaded
ERROR: Failed to detect XMC, xmc.bin not loaded
Card [0000:d8:00.0]
    Card type:        u250
    Flash type:       SPI
    Flashable partition running on FPGA:
        xilinx_u250_xdma_201830_2,[ID=0x5d14fbe6],[SC=INACTIVE]
    Flashable partitions installed in system:    
        xilinx_u250_xdma_201830_2,[ID=0x5d14fbe6],[SC=4.2.0]

 ```

Next steps:

 - [Reload XRT Drivers](common-steps.md#unloadreload-xrt-drivers)
 - If issue persists
   - Pull power to the system
   - Perform `xbmgmt flash --scan`
- If issue persists
  - [Reinstall the platforms](modifying-xrt-platform.md#platform-re-install)
  - Perform `xbmgmt flash --scan`
 - If these steps do not resolve the issue look on the [Xilinx forums](https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo)


- - -

### `xbmgmt flash --scan` Returns `XMC not ready` Error

If `xbmgmt flash --scan` command returns `XMC not ready` error as shown below, there is communication break between XRT and CMC.

 ```
 ERROR: XMC is not ready: 0x3
 ERROR: XMC is not ready: 0x3
 ERROR: XMC is not ready: 0x3
 Card [0000:a3:00.0]
     Card type:          u50
     Flash type:         SPI
     Flashable partition running on FPGA:
         xilinx_u50_gen3x16_xdma_201920_3,[ID=0xf465b0a3ae8c64f6],[SC=UNKNOWN]
             Logic UUID:
             f465b0a3ae8c64f619bc150384ace69b
     Flashable partitions installed in system:
         xilinx_u50_gen3x16_xdma_201920_3,[ID=0xf465b0a3ae8c64f6],[SC=5.0.27]
             Logic UUID:
             f465b0a3ae8c64f619bc150384ace69b
 ```
Next steps:
- Cold boot the system
- Perform `xbmgmt flash --scan`
- If issue persists
  - Pull power to the system
  - Perform `xbmgmt flash --scan`
- If issue persists
  - [Reinstall the platforms](modifying-xrt-platform.md#platform-re-install)
  - Perform `xbmgmt flash --scan`
- If these steps do not resolve the issue look on the [Xilinx forums](https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo)


- - -

### `xbmgmt flash --scan` Returns `SC is not ready` Error

If `xbmgmt flash --scan` command returns `SC is not ready ` error as shown below, there is communication break between SC and CMC.

 ```
 ERROR: SC is not ready: 0x0
  Card [0000:c3:00.0]
  Card type: u50lv
  Flash type: SPI
  Flashable partition running on FPGA:
  xilinx_u50lv_gen3x4_xdma_base_2,[ID=0xc74bda63fe95d0e8],[SC=UNKNOWN]
 ```

Next steps:
- Cold boot the system
- Perform `xbmgmt flash --scan`
- If issue persists
  - Pull power to the system
  - Perform `xbmgmt flash --scan`
- If issue persists
  - [Reinstall the platforms](modifying-xrt-platform.md#platform-re-install)
  - Perform `xbmgmt flash --scan`
- If these steps do not resolve the issue look on the [Xilinx forums](https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo)


- - -
### SC Only Displays Two Digits in `Flashable partition running on FPGA`
If `xbmgmt flash --scan` command returns different number of digits of SC versions for  `Flashable partition running on FPGA`, and `Flashable partitions installed in system`, there is a break in communication between XRT and CMC.

 ```
 Card [0000:07:00.0]
     Card type:          u50
     Flash type:         SPI
     Flashable partition running on FPGA:
         xilinx_u50_gen3x16_xdma_201920_3,[ID=0xf465b0a3ae8c64f6],[SC=5.0]
             Logic UUID:
             f465b0a3ae8c64f619bc150384ace69b
     Flashable partitions installed in system:
         xilinx_u50_gen3x16_xdma_201920_3,[ID=0xf465b0a3ae8c64f6],[SC=5.0.27]

 ```

Next steps:
- [Reinstall the platforms](modifying-xrt-platform.md#platform-re-install)
- Perform `xbmgmt flash --scan`
- If these steps do not resolve the issue look on the [Xilinx forums](https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo)


- - -

### The SC Version Displayed Under `Flashable partition running on FPGA` and `Flashable partitions installed in system` Do Not Match.

If `xbmgmt flash --scan` command returns different SC version displayed under  `Flashable partition running on FPGA`, and `Flashable partitions installed in system` sections as shown below, the card has not been flashed to the SC version used by in the system.  Both need to use the same SC version.

```
Card [0000:27:00.0]
    Card type:          u50
    Flash type:         SPI
    Flashable partition running on FPGA:
        xilinx_u50_gen3x16_xdma_201920_3,[ID=0xf465b0a3ae8c64f6],[SC=5.0.13]
            Logic UUID:
            f465b0a3ae8c64f619bc150384ace69b
    Flashable partitions installed in system:
        xilinx_u50_gen3x16_xdma_201920_3,[ID=0xf465b0a3ae8c64f6],[SC=5.0.27]

```

Next steps:
- Flash card with SC version installed on the system
- See [flashing the card with a deployment platform](common-steps.md#flash-the-card-with-a-deployment-platform)

- - -

### `Flashable partition running on FPGA` Displays GOLDEN and There is a Partition Displayed Under `Flashable partitions installed in system`

When `xbmgmt flash --scan` command returns `GOLDEN ` under `Flashable partition running on FPGA` as shown below, the card is fresh from the factory or the has been returned to factory state.

 ```
 Card [0000:d3:00.0]
     Card type:          u50
     Flash type:         SPI
     Flashable partition running on FPGA:
         xilinx_u50_GOLDEN_9,[SC=INACTIVE]
     Flashable partitions installed in system:
         xilinx_u50_gen3x16_xdma_201920_3,[ID=0xf465b0a3ae8c64f6],[SC=5.0.27]

 ```

Next step:
-  Go to [flashing the card with a deployment platform](common-steps.md#flash-the-card-with-a-deployment-platform)

- - -

### Partition Displayed Under `Flashable partition running on FPGA` While (None) Displayed Under `Flashable partitions installed in system`

If `xbmgmt flash --scan` command returns `Flashable partitions installed in system:   (None)` as shown below, it means the corresponding platform has not been installed in the system.

```
Card [0000:03:00.0]
    Card type:          u250
    Flash type:         SPI
    Flashable partition running on FPGA:
        xilinx_u250_xdma_201830_2,[ID=0x5d14fbe6]
    Flashable partitions installed in system:   (None)

```

Next step:
- Follow the steps to install the platform on the host in section [flashing the card with a deployment platform](common-steps.md#flash-the-card-with-a-deployment-platform)

- - -
### Card is Missing from `xbmgmt flash --scan output`

If xbmgmt flash command returns `No cards Found` output, as shown below, the OS or XRT is not able to find the card.

  ```
  No cards Found !
  ```

Next steps:
- Run  `sudo lspci -vd 10ee:`
- If this does not show any cards
- Go to [Card not recognized](card-not-recognized.md)
- Else go to [Modifying XRT/platform](modifying-xrt-platform.md)

- - -
### `xbutil query` Reports a Value of Zero for Voltage or Temperature

If the `xbutil query` command reports a zero value in `FPGA TEMP`, `12V PEX` or `3V3 PEX` as shown in the example below, there is a chance of communication break between in XRT/CMC/SC.

```
Temperature(C)
PCB TOP FRONT   PCB TOP REAR    PCB BTM FRONT   VCCINT TEMP
0               0               N/A             0
FPGA TEMP       TCRIT Temp      FAN Presence    FAN Speed(RPM)
0               0               P               N/A
QSFP 0          QSFP 1          QSFP 2          QSFP 3
N/A             N/A             N/A             N/A
HBM TEMP
N/A
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Electrical(mV|mA)
12V PEX         12V AUX         12V PEX Current 12V AUX Current
0               N/A             0               N/A
3V3 PEX         3V3 AUX         DDR VPP BOTTOM  DDR VPP TOP
0               N/A             N/A             N/A
```

Next steps:
- Cold boot the system
- Perform `xbmgmt flash --scan`
- If issue persists
  - Pull power to the system
  - Perform `xbmgmt flash --scan`
- If issue persists
  - [Reinstall the platforms](modifying-xrt-platform.md#platform-re-install)
  - Perform `xbmgmt flash --scan`
- If these steps do not resolve the issue look on the [Xilinx forums](https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo)


- - -

### Xilinx Support

For additional support resources such as Answers, Documentation, Downloads, and Alerts, see the [Xilinx Support pages](http://www.xilinx.com/support). For additional assistance, post your question on the Xilinx Community Forums – [Alveo Accelerator Card](https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo).

### License

All software including scripts in this distribution are licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

All images and documentation, including all debug and support documentation, are licensed under the Creative Commons (CC) Attribution 4.0 International License (the "CC-BY-4.0 License"); you may not use this file except in compliance with the CC-BY-4.0 License.

You may obtain a copy of the CC-BY-4.0 License at
[https://creativecommons.org/licenses/by/4.0/]( https://creativecommons.org/licenses/by/4.0/)


Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

<p align="center"><sup>XD027 | &copy; Copyright 2021 Xilinx, Inc.</sup></p>
