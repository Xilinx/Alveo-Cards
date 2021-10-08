<table class="sphinxhide">
 <tr>
   <td align="center"><img src="https://www.xilinx.com/content/dam/xilinx/imgs/press/media-kits/corporate/xilinx-logo.png" width="30%"/><h1>Alveo Debug Guide</h1>
   </td>
 </tr>
</table>

# SC Troubleshooting

This can help to determine if any communication break has happened in the [SC](terminology.md#sc) <-> [CMC](terminology.md#cmc) path. It is part of the larger Alveo debug guide. If you are just starting to debug please consult [main page](../README.md).

## This Page Covers

This page covers issues observed when running the  `xbmgmt examine` and  `xbutil examine` commands and which can be related to SC issues.

## You Will Need
 
Before beginning debug, you need to:

- Have [root/sudo permissions](common-steps.md#root-sudo-access)
- [Confirm System Compatibility](check-system-compatibility.md)
- [Determine XRT version](common-steps.md#determine-xrt-version) installed.
- [Display card and host platform and SC versions](common-steps.md#display-card-and-host-platform-and-sc-versions)
  - Card platform and [SC](terminology.md#sc) version must match those installed on the host system

## Common Cases

### Partition displayed under `Flashable partition running on FPGA` and `Flashable partitions installed in system` are identical.

When the platform has been installed correctly, the partition and [SC](terminology.md#sc) version running on the FPGA and installed on the system will be identical.  The installed partitions can be displayed using the `xbmgmt examine -r platform` command.  An example output is shown below.

 ```
 ------------------------------------------------------
1/1 [0000:04:00.0] : xilinx_u50_gen3x16_xdma_201920_3
------------------------------------------------------
Flash properties
  Type                 : spi
  Serial Number        : 50121119CSPC

Device properties
  Type                 : u50
  Name                 : ALVEO U50 PQ
  Config Mode          : 7
  Max Power            : 75W

Flashable partitions running on FPGA
  Platform             : xilinx_u50_gen3x16_xdma_201920_3
  SC Version           : 5.2.6
  Platform UUID        : F465B0A3-AE8C-64F6-19BC-150384ACE69B
  Interface UUID       : 862C7020-A250-293E-3203-6F19956669E5

Flashable partitions installed in system
  Platform             : xilinx_u50_gen3x16_xdma_201920_3
  SC Version           : 5.2.6
  Platform UUID        : F465B0A3-AE8C-64F6-19BC-150384ACE69B


  Mac Address          : 00:0A:35:06:6E:96
                       : 00:0A:35:06:6E:97
                       : 00:0A:35:06:6E:98
                       : 00:0A:35:06:6E:99
 ```
Next step:
- None, this is expected output

- - -
### xbmgmt examine -r platform Returns `bad magic number` Error

If xbmgmt examine -r platform command returns `bad magic number` error as in the example below, there is a chance of a communication break between [XRT](terminology.md#xrt) and the [CMC](terminology.md#cmc).  The CMC is not reading the pre-programmed magic number (0x74736574), an on card self check hex string.

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
  - Perform `xbmgmt examine -r platform`
- If issue persists
  - [Pull power](terminology.md#shutdown-and-unplug-pull-power) to the system
  - Perform `xbmgmt examine -r platform`
- If issue persists
  - [Reinstall the platforms](modifying-xrt-platform.md#platform-re-install)
  - Perform `xbmgmt examine -r platform`
- If these steps do not resolve the issue look on the [Xilinx forums](https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo)

- - -
### XMC not loaded

If `xbmgmt examine -r platform` command returns `XMC not loaded` error as shown below, there is communication break between [XRT](terminology.md#xrt) and the [CMC](terminology.md#cmc).

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
   - [Pull power](terminology.md#shutdown-and-unplug-pull-power) to the system
   - Perform `xbmgmt examine -r platform`
- If issue persists
  - [Reinstall the platforms](modifying-xrt-platform.md#platform-re-install)
  - Perform `xbmgmt examine -r platform`
 - If these steps do not resolve the issue look on the [Xilinx forums](https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo)


- - -

### XMC not ready

If `xbmgmt examine -r platform` command returns `XMC not ready` error as shown below, there is communication break between [XRT](terminology.md#xrt) and the [CMC](terminology.md#cmc).

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
- Perform `xbmgmt examine -r platform`
- If issue persists
  - [Pull power](terminology.md#shutdown-and-unplug-pull-power) to the system
  - Perform `xbmgmt examine -r platform`
- If issue persists
  - [Reinstall the platforms](modifying-xrt-platform.md#platform-re-install)
  - Perform `xbmgmt examine -r platform`
- If these steps do not resolve the issue look on the [Xilinx forums](https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo)


- - -

### SC is not ready

If `xbmgmt examine -r platform` command returns `SC is not ready ` error as shown below, there is communication break between the [SC](terminology.md#sc) and the [CMC](terminology.md#cmc).

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
- Perform `xbmgmt examine -r platform`
- If issue persists
  - [Pull power](terminology.md#shutdown-and-unplug-pull-power) to the system
  - Perform `xbmgmt examine -r platform`
- If issue persists
  - [Reinstall the platforms](modifying-xrt-platform.md#platform-re-install)
  - Perform `xbmgmt examine -r platform`
- If these steps do not resolve the issue look on the [Xilinx forums](https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo)


- - -
### SC only displays two digits
If xbmgmt examine -r platform command returns different number of digits of between the [SC](terminology.md#sc) versions for  `Flashable partition running on FPGA`, and `Flashable partitions installed in system`, there is a break in communication between [XRT](terminology.md#xrt) and the [CMC](terminology.md#cmc).

 ```
------------------------------------------------------
1/1 [0000:04:00.0] : xilinx_u50_gen3x16_xdma_201920_3
------------------------------------------------------
Flash properties
  Type                 : spi
  Serial Number        : 50121119CSPC

Device properties
  Type                 : u50
  Name                 : ALVEO U50 PQ
  Config Mode          : 7
  Max Power            : 75W

Flashable partitions running on FPGA
  Platform             : xilinx_u50_gen3x16_xdma_201920_3
  SC Version           : 5.0
  Platform UUID        : F465B0A3-AE8C-64F6-19BC-150384ACE69B
  Interface UUID       : 862C7020-A250-293E-3203-6F19956669E5

Flashable partitions installed in system
  Platform             : xilinx_u50_gen3x16_xdma_201920_3
  SC Version           : 5.2.6
  Platform UUID        : F465B0A3-AE8C-64F6-19BC-150384ACE69B


  Mac Address          : 00:0A:35:06:6E:96
                       : 00:0A:35:06:6E:97
                       : 00:0A:35:06:6E:98
                       : 00:0A:35:06:6E:99

WARNING  : SC image on the device is not up-to-date.
 ```

Next steps:
- [Reinstall the platforms](modifying-xrt-platform.md#platform-re-install)
- Perform `xbmgmt examine -r platform`
- Flash the satellite controller with the version installed on the system: `xbmgmt program --base --device <management BDF>`
- If these steps do not resolve the issue look on the [Xilinx forums](https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo)


- - -

### SC versions do not match

If `xbmgmt examine -r platform` command returns different [SC](terminology.md#sc) version displayed under  `Flashable partition running on FPGA`, and `Flashable partitions installed in system` sections as shown below, the card has not been flashed to the SC version used by in the system.  Both need to use the same SC version.

```
------------------------------------------------------
1/1 [0000:04:00.0] : xilinx_u50_gen3x16_xdma_201920_3
------------------------------------------------------
Flash properties
  Type                 : spi
  Serial Number        : 50121119CSPC

Device properties
  Type                 : u50
  Name                 : ALVEO U50 PQ
  Config Mode          : 7
  Max Power            : 75W

Flashable partitions running on FPGA
  Platform             : xilinx_u50_gen3x16_xdma_201920_3
  SC Version           : 5.0.13
  Platform UUID        : F465B0A3-AE8C-64F6-19BC-150384ACE69B
  Interface UUID       : 862C7020-A250-293E-3203-6F19956669E5

Flashable partitions installed in system
  Platform             : xilinx_u50_gen3x16_xdma_201920_3
  SC Version           : 5.2.6
  Platform UUID        : F465B0A3-AE8C-64F6-19BC-150384ACE69B


  Mac Address          : 00:0A:35:06:6E:96
                       : 00:0A:35:06:6E:97
                       : 00:0A:35:06:6E:98
                       : 00:0A:35:06:6E:99

WARNING  : SC image on the device is not up-to-date.

```

Next steps:
- Flash the satellite controller with the version installed on the system: `xbmgmt program --base --device <management BDF>`
- See [flashing the card with a deployment platform](common-steps.md#flash-the-card-with-a-deployment-platform)

- - -

### GOLDEN partition running on FPGA 

When `xbmgmt examine -r platform` command returns `GOLDEN ` under `Flashable partition running on FPGA` as shown below, the card is fresh from the factory or the has been returned to factory state.  The partition displayed under `Flashable partitions installed in system` shows only the partitions available on the system.

 ```
---------------------------------------
1/1 [0000:04:00.0] : xilinx_u50_GOLDEN
---------------------------------------
Flash properties
  Type                 : spi
  Serial Number        : N/A

Device properties
  Type                 : u50
  Name                 : N/A
  Config Mode          : 0
  Max Power            : N/A

Flashable partitions running on FPGA
  Platform             : xilinx_u50_GOLDEN_9
  SC Version           : INACTIVE
  Platform ID          : N/A

Flashable partitions installed in system
  Platform             : xilinx_u50_gen3x16_xdma_201920_3
  SC Version           : 5.2.6
  Platform UUID        : F465B0A3-AE8C-64F6-19BC-150384ACE69B

WARNING  : Device is not up-to-date.

 ```

Next step:
-  Go to [flashing the card with a deployment platform](common-steps.md#flash-the-card-with-a-deployment-platform)

- - -

### Partition installed in system (None)

If `xbmgmt examine -r platform` command returns `Flashable partitions installed in system:   (None)` as shown below, it means the corresponding platform running on the FPGA has not been installed in the system. The partition displayed under `Flashable partitions running on FPGA` will show the partition flashed on the card.  The partitions on the card and system must match for applications to run.

```
------------------------------------------------------
1/1 [0000:04:00.0] : xilinx_u50_gen3x16_xdma_201920_3
------------------------------------------------------
Flash properties
  Type                 : spi
  Serial Number        : 50121B39AN35

Device properties
  Type                 : u50
  Name                 : ALVEO U50 PQ
  Config Mode          : 7
  Max Power            : 75W

Flashable partitions running on FPGA
  Platform             : xilinx_u50_gen3x16_xdma_201920_3
  SC Version           : 5.2.6
  Platform UUID        : F465B0A3-AE8C-64F6-19BC-150384ACE69B
  Interface UUID       : 862C7020-A250-293E-3203-6F19956669E5

Flashable partitions installed in system
  <none found>        


  Mac Address          : 00:0A:35:06:47:49
                       : 00:0A:35:06:47:4A
                       : 00:0A:35:06:47:4B
                       : 00:0A:35:06:47:4C

WARNING  : No shell is installed on the system.

```

Next step:
- Follow the steps to install the platform on the host in section [flashing the card with a deployment platform](common-steps.md#flash-the-card-with-a-deployment-platform)

- - -
### No cards found

If `xbmgmt examine -r platform` command returns `0 devices found` as shown below, the OS or [XRT](terminology.md#XRT) is unable to find the card.

  ```
 Devices present
  0 devices found
  ```

Next steps:
- Run  `sudo lspci -vd 10ee:`
- If this does not show any cards
  - Go to [Card not recognized](card-not-recognized.md)
- Else go to [Modifying XRT/platform](modifying-xrt-platform.md)

- - -
### Voltage or temperature reports zero

If `xbutil examine -r thermal electrical -d <user BDF>` command reports a zero value in `FPGA TEMP`, `12V PEX` or `3V3 PEX` as shown in the example below, there is a chance of communication break between the [XRT](terminology.md#xrt)/[CMC](terminology.md#cmc)/[SC](terminology.md#sc) components.

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


*mockup*
------------------------------------------------------
1/1 [0000:82:00.1] : xilinx_u50_gen3x16_xdma_201920_3
------------------------------------------------------
Thermals
  PCB Top Front          : 0 C
  PCB Top Rear           : 0 C
  Cage0                  : 0 C
  FPGA                   : 0 C
  Int Vcc                : 0 C

Electrical
  Max Power              : 75 Watts
  Power                  : N/A Watts
  Power Warning          : false

  Power Rails            : Voltage   Current
  12 Volts PCI Express   :  0 V,  	0 A
  3.3 Volts PCI Express  :  0 V,  	0 A
  Internal FPGA Vcc      :  0 V,  	0 A
  Internal FPGA Vcc IO   :  0 V,  	0 A
  5.5 Volts System       :  0 V
  1.8 Volts Top          :  0 V
  0.9 Volts Vcc          :  0 V
  Mgt Vtt                :  0 V
  3.3 Volts Vcc          :  0 V
  1.2 Volts HBM          :  0 V
  Vpp 2.5 Volts          :  0 V

```

Next steps:
- Cold boot the system
- Perform `xbutil examine -r thermal electrical -d <user BDF>`
- If issue persists
  - [Pull power](terminology.md#shutdown-and-unplug-pull-power) to the system
  - Perform `xbutil examine -r thermal electrical -d <user BDF>`
- If issue persists
  - [Reinstall the platforms](modifying-xrt-platform.md#platform-re-install)
  - Perform `xbutil examine -r thermal electrical -d <user BDF>`
- If these steps do not resolve the issue look on the [Xilinx forums](https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo)


- - -
### Failed to open device

If `xbmgmt examine -r platform` command returns `Failed to open device:` as shown below, it means the driver was not successfully loaded or the card was not successfully flashed.

```
Failed to open device: 0000:3b:00.0
INFO: Found total 1 card(s); 0 are usable.
```
Next steps:
- Cold boot the system
- Perform `xbmgmt examine -r platform`
- If issue persists
  - [Pull power](terminology.md#shutdown-and-unplug-pull-power) to the system
  - Perform `xbmgmt examine -r platform`
- If issue persists
  - [Reinstall the platforms](modifying-xrt-platform.md#platform-re-install)
  - Perform `xbmgmt examine -r platform`
- If these steps do not resolve the issue look on the [Xilinx forums](https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo)
- - -

### Xilinx Support

For additional support resources such as Answers, Documentation, Downloads, and Alerts, see the [Xilinx Support pages](http://www.xilinx.com/support). For additional assistance, post your question on the Xilinx Community Forums – [Alveo Accelerator Card](https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo). 

Have a suggestion, or found an issue please send an email to alveo_cards_debugging@xilinx.com .

### License

All software including scripts in this distribution are licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

All images and documentation, including all debug and support documentation, are licensed under the Creative Commons (CC) Attribution 4.0 International License (the "CC-BY-4.0 License"); you may not use this file except in compliance with the CC-BY-4.0 License.

You may obtain a copy of the CC-BY-4.0 License at
[https://creativecommons.org/licenses/by/4.0/]( https://creativecommons.org/licenses/by/4.0/)


Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

<p align="center"><sup>XD027 | &copy; Copyright 2021 Xilinx, Inc.</sup></p>
