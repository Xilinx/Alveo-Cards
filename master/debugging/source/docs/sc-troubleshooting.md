<table class="sphinxhide">
 <tr>
   <td align="center"><img src="https://www.xilinx.com/content/dam/xilinx/imgs/press/media-kits/corporate/xilinx-logo.png" width="30%"/><h1>Alveo Debug Guide</h1>
   </td>
 </tr>
</table>

# SC Troubleshooting

This can help to determine if any communication break has happened in the [SC](terminology.md#sc) <-> [CMC](terminology.md#cmc) path. It is part of the larger Alveo debug guide. If you are just starting to debug please consult [main page](../README.md).

## This Page Covers

This page covers issues observed when running the  [xbmgmt examine](https://xilinx.github.io/XRT/master/html/xbmgmt.html#xbmgmt-examine) and  [xbutil examine](https://xilinx.github.io/XRT/master/html/xbutil.html#xbutil-examine) commands and which can be related to SC issues.

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
-------------------------------------------------
[0000:3b:00.0] : xilinx_u55c_gen3x16_xdma_base_3
-------------------------------------------------
Flash properties
  Type                 : spi
  Serial Number        : 

Device properties
  Type                 : u55c
  Name                 : ALVEO U55C
  Config Mode          : 0x7
  Max Power            : 225W

Flashable partitions running on FPGA
  Platform             : xilinx_u55c_gen3x16_xdma_base_3
  SC Version           : 7.1.22
  Platform UUID        : 97088961-FEAE-DA91-52A2-1D9DFD63CCEF
  Interface UUID       : B7AC1ABE-1E3E-1CB6-86D5-A81232452676

Flashable partitions installed in system
  Platform             : xilinx_u55c_gen3x16_xdma_base_3
  SC Version           : 7.1.22
  Platform UUID        : 97088961-FEAE-DA91-52A2-1D9DFD63CCEF


  Mac Address          : 00:0A:35:08:8C:AD
                       : 00:0A:35:08:8C:AE
                       : 00:0A:35:08:8C:AF
                       : 00:0A:35:08:8C:B0
                       : 00:0A:35:08:8C:B1
                       : 00:0A:35:08:8C:B2
                       : 00:0A:35:08:8C:B3
                       : 00:0A:35:08:8C:B4

 ```
Next step:
- None, this is expected output

- - -
### XMC not loaded

If `xbmgmt examine -d <BDF>` command returns `XMC not loaded` error as shown below, there is communication break between [XRT](terminology.md#xrt) and the [CMC](terminology.md#cmc).

```
-------------------------------------------------
[0000:01:00.0] : xilinx_u55c_gen3x16_xdma_base_3
-------------------------------------------------
ERROR: Failed to detect XMC, xmc.bin not loaded
ERROR: Failed to detect XMC, xmc.bin not loaded
Flash properties
  Type                 : spi
  Serial Number        : N/A
 
Device properties
  Type                 : N/A
  Name                 : N/A
  Config Mode          : 0x1175d80
  Max Power            : N/A

 
Flashable partitions running on FPGA
  Platform             : xilinx_u55c_gen3x16_xdma_base_3
  SC Version           : 7.1.22
  Platform UUID        : 97088961-FEAE-DA91-52A2-1D9DFD63CCEF
  Interface UUID       : B7AC1ABE-1E3E-1CB6-86D5-A81232452676

Flashable partitions installed in system
  Platform             : xilinx_u55c_gen3x16_xdma_base_3
  SC Version           : 7.1.22
  Platform UUID        : 97088961-FEAE-DA91-52A2-1D9DFD63CCEF



 ```

Next steps:

 - [Reload XRT Drivers](common-steps.md#unload-reload-xrt-drivers)
 - If issue persists
   - [Pull power](terminology.md#shutdown-and-unplug-pull-power) to the system
   - Perform `xbmgmt examine -d <BDF>`
- If issue persists
  - [Reinstall the platforms](modifying-xrt-platform.md#platform-re-install)
  - Perform `xbmgmt examine -d <BDF>`
 - If these steps do not resolve the issue look on the [Xilinx forums](https://support.xilinx.com/s/topic/0TO2E000000YKXlWAO/alveo-accelerator-cards)


- - -

### SC is not ready

If `xbmgmt examine -d <BDF>` command returns `SC is not ready ` error as shown below, there is communication break between the [SC](terminology.md#sc) and the [CMC](terminology.md#cmc).

 ```
-------------------------------------------------
[0000:1a:00.0] : xilinx_u55c_gen3x16_xdma_base_3
-------------------------------------------------
ERROR: SC is not ready: 0x0(NOT READY)
ERROR: SC is not ready: 0x0(NOT READY)
Flash properties
  Type                 : spi
  Serial Number        : N/A
 
Device properties
  Type                 : u55c
  Name                 : N/A
  Config Mode          : 0x154d060
 
Flashable partitions running on FPGA
  Platform             : xilinx_u55c_gen3x16_xdma_base_3
  SC Version           : N/A
  Platform UUID        : 97088961-FEAE-DA91-52A2-1D9DFD63CCEF
  Interface UUID       : B7AC1ABE-1E3E-1CB6-86D5-A81232452676

Flashable partitions installed in system
  Platform             : xilinx_u55c_gen3x16_xdma_base_3
  SC Version           : 7.1.22
  Platform UUID        : 97088961-FEAE-DA91-52A2-1D9DFD63CCEF

 ```

Next steps:
- Cold boot the system
- Perform `xbmgmt examine -d <BDF>`
- If issue persists
  - [Pull power](terminology.md#shutdown-and-unplug-pull-power) to the system
  - Perform `xbmgmt examine -d <BDF>`
- If issue persists
  - [Reinstall the platforms](modifying-xrt-platform.md#platform-re-install)
  - Perform `xbmgmt examine -d <BDF>`
- If these steps do not resolve the issue look on the [Xilinx forums](https://support.xilinx.com/s/topic/0TO2E000000YKXlWAO/alveo-accelerator-cards)


- - -
### SC only displays two digits
If xbmgmt examine -r platform command returns different number of digits of between the [SC](terminology.md#sc) versions for  `Flashable partition running on FPGA`, and `Flashable partitions installed in system`, there is a break in communication between [XRT](terminology.md#xrt) and the [CMC](terminology.md#cmc).

 ```
------------------------------------------------
[0000:04:00.0] : xilinx_u50_gen3x16_xdma_base_5
------------------------------------------------
Flash properties
  Type                 : spi
  Serial Number        : 

Device properties
  Type                 : u50
  Name                 : ALVEO U50 PQ
  Config Mode          : 7
  Max Power            : 75W

Flashable partitions running on FPGA
  Platform             : xilinx_u50_gen3x16_xdma_base_5
  SC Version           : 5.0
  Platform UUID        : 44654095-25B4-C06A-EC6D-0B479D3FEBE8
  Interface UUID       : 16E2362F-82D2-FEAB-3552-9DA27134B76D

Flashable partitions installed in system
  Platform             : xilinx_u50_gen3x16_xdma_base_5
  SC Version           : 5.2.20
  Platform UUID        : 44654095-25B4-C06A-EC6D-0B479D3FEBE8


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
- If these steps do not resolve the issue look on the [Xilinx forums](https://support.xilinx.com/s/topic/0TO2E000000YKXlWAO/alveo-accelerator-cards)


- - -

### SC versions do not match

If `xbmgmt examine -r platform` command returns different [SC](terminology.md#sc) version displayed under  `Flashable partition running on FPGA`, and `Flashable partitions installed in system` sections as shown below, the card has not been flashed to the SC version used by in the system.  Both need to use the same SC version.

```
-------------------------------------------------
[0000:3b:00.0] : xilinx_u55c_gen3x16_xdma_base_3
-------------------------------------------------
Flash properties
  Type                 : spi
  Serial Number        : 

Device properties
  Type                 : u55c
  Name                 : ALVEO U55C
  Config Mode          : 0x7
  Max Power            : 225W

Flashable partitions running on FPGA
  Platform             : xilinx_u55c_gen3x16_xdma_base_3
  SC Version           : 7.1.17
  Platform UUID        : 97088961-FEAE-DA91-52A2-1D9DFD63CCEF
  Interface UUID       : B7AC1ABE-1E3E-1CB6-86D5-A81232452676

Flashable partitions installed in system
  Platform             : xilinx_u55c_gen3x16_xdma_base_3
  SC Version           : 7.1.22
  Platform UUID        : 97088961-FEAE-DA91-52A2-1D9DFD63CCEF


  Mac Address          : 00:0A:35:08:8C:AD
                       : 00:0A:35:08:8C:AE
                       : 00:0A:35:08:8C:AF
                       : 00:0A:35:08:8C:B0
                       : 00:0A:35:08:8C:B1
                       : 00:0A:35:08:8C:B2
                       : 00:0A:35:08:8C:B3
                       : 00:0A:35:08:8C:B4

WARNING  : SC image on the device is not up-to-date.

```

Next steps:
- Flash the satellite controller with the version installed on the system: `xbmgmt program --base --device <management BDF>`
- See [flashing the card with a deployment platform](common-steps.md#flash-the-card-with-a-deployment-platform)

- - -

### GOLDEN partition running on FPGA 

When `xbmgmt examine -r platform` command returns `GOLDEN ` under `Flashable partition running on FPGA` as shown below, the card is fresh from the factory or the has been returned to factory state.  The partition displayed under `Flashable partitions installed in system` shows only the partitions available on the system.

 ```
-----------------------------------
[0000:5e:00.0] : xilinx_u50_GOLDEN
-----------------------------------
Warning: Device is not ready - Limited functionality available with XRT tools.
Flash properties
  Type                 : spi
  Serial Number        : N/A

Device properties
  Type                 : u50
  Name                 : N/A
  Config Mode          : 0x130d3a00

Flashable partitions running on FPGA
  Platform             : xilinx_u50_GOLDEN_9
  SC Version           : INACTIVE
  Platform ID          : N/A

Flashable partitions installed in system
  Platform             : xilinx_u50_gen3x16_xdma_base_5
  SC Version           : 5.2.20
  Platform UUID        : 44654095-25B4-C06A-EC6D-0B479D3FEBE8

WARNING  : Device is not up-to-date.

 ```

Next step:
-  Go to [flashing the card with a deployment platform](common-steps.md#flash-the-card-with-a-deployment-platform)

- - -

### Partition installed in system (None)

If `xbmgmt examine -r platform` command returns `Flashable partitions installed in system:   (None)` as shown below, it means the corresponding platform running on the FPGA has not been installed in the system. The partition displayed under `Flashable partitions running on FPGA` will show the partition flashed on the card.  The partitions on the card and system must match for applications to run.

```
-------------------------------------------------
[0000:3b:00.0] : xilinx_u55c_gen3x16_xdma_base_3
-------------------------------------------------
Flash properties
  Type                 : spi
  Serial Number        : XFL1P0345SA0

Device properties
  Type                 : u55c
  Name                 : ALVEO U55C
  Config Mode          : 0x7
  Max Power            : 225W

Flashable partitions running on FPGA
  Platform             : xilinx_u55c_gen3x16_xdma_base_3
  SC Version           : 7.1.22
  Platform UUID        : 97088961-FEAE-DA91-52A2-1D9DFD63CCEF
  Interface UUID       : B7AC1ABE-1E3E-1CB6-86D5-A81232452676

Flashable partitions installed in system
  <none found>        


  Mac Address          : 00:0A:35:08:8C:AD
                       : 00:0A:35:08:8C:AE
                       : 00:0A:35:08:8C:AF
                       : 00:0A:35:08:8C:B0
                       : 00:0A:35:08:8C:B1
                       : 00:0A:35:08:8C:B2
                       : 00:0A:35:08:8C:B3
                       : 00:0A:35:08:8C:B4

WARNING  : No shell is installed on the system.

```

Next step:
- Follow the steps to install the platform on the host in section [flashing the card with a deployment platform](common-steps.md#flash-the-card-with-a-deployment-platform)

- - -
### No cards found

If `xbmgmt examine -r platform` command returns `0 devices found` as shown below, the OS or [XRT](terminology.md#xrt) is unable to find the card.

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
-------------------------------------------------
[0000:3b:00.1] : xilinx_u55c_gen3x16_xdma_base_3
-------------------------------------------------
Thermals
  Temperature            : Celcius
  PCB Top Front          :     36 C
  PCB Top Rear           :     32 C
  FPGA                   :     38 C
  Int Vcc                :     41 C

Electrical
  Max Power              : 225 Watts
  Power                  : N/A Watts
  Power Warning          : false

  Power Rails            : Voltage   Current
  12 Volts Auxillary     :  0 V,  0 A
  12 Volts PCI Express   :  0 V,  0 A
  3.3 Volts PCI Express  :  0 V,  0 A
  Internal FPGA Vcc      :  0 V,  0 A
  Internal FPGA Vcc IO   :  0 V,  00 A
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
- If these steps do not resolve the issue look on the [Xilinx forums](https://support.xilinx.com/s/topic/0TO2E000000YKXlWAO/alveo-accelerator-cards)


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
- If these steps do not resolve the issue look on the [Xilinx forums](https://support.xilinx.com/s/topic/0TO2E000000YKXlWAO/alveo-accelerator-cards)
- - -

### Xilinx Support

For additional support resources such as Answers, Documentation, Downloads, and Alerts, see the [Xilinx Support pages](http://www.xilinx.com/support). For additional assistance, post your question on the Xilinx Community Forums – [Alveo Accelerator Card](https://support.xilinx.com/s/topic/0TO2E000000YKXlWAO/alveo-accelerator-cards). 

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
