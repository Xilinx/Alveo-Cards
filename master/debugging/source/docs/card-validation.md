﻿<table class="sphinxhide">
 <tr>
   <td align="center"><img src="https://www.xilinx.com/content/dam/xilinx/imgs/press/media-kits/corporate/xilinx-logo.png" width="30%"/><h1>Alveo Debug Guide</h1>
   </td>
 </tr>
</table>

# Card Validation
The [xbutil utility](https://xilinx.github.io/XRT/master/html/xbutil.html#xbutil), which is installed with XRT, can be used to validate the [card installation](card-install.md) using the [xbutil validate](https://xilinx.github.io/XRT/master/html/xbutil.html#xbutil-validate) command. The command validates power connection, PCIe connection, SC version, as well as running various memory and bandwidth tests. Full details on this command can be found in the [XRT Documentation](https://xilinx.github.io/XRT/master/html/xbutil.html#xbutil-validate).  If validation fails, indicated by `Validation failed` in the command output, the errors need to be addressed before the card can be used.

## This Page Covers

This page covers issues encountered when using [xbutil validate](https://xilinx.github.io/XRT/master/html/xbutil.html#xbutil-validate).    If your issue is not covered, please post on the [Xilinx forums](https://support.xilinx.com/s/topic/0TO2E000000YKXlWAO/alveo-accelerator-cards).

## You Will Need

Before beginning debug:

- Ensure the card, XRT, and the deployment packages are installed as part of the [card install](card-install.md)
- Confirm the [platform and SC version](common-steps.md#display-card-and-host-platform-and-sc-versions) on the card and system match
- Determine any failure mode(s) from running [xbutil validate](https://xilinx.github.io/XRT/master/html/xbutil.html#xbutil-validate)


## Common Cases
- - -
### DMA test error
The `DMA test data integrity check failed` error, as shown below, can be caused by multiple conditions and may be spurrious. 

 ```
Test 4 [0000:83:00.1]     : DMA
    Details               : Host -> PCIe -> FPGA write bandwidth = 6669.4 MB/s
                            Host <- PCIe <- FPGA read bandwidth = 6226.3 MB/s
    Error(s)              : DMA test data integrity check failed.: Input/output error
                            DMA test data integrity check failed.: Input/output error
                            DMA test data integrity check failed.: Input/output error
                            DMA test data integrity check failed.: Input/output error
    Details               : Host -> PCIe -> FPGA write bandwidth = 5770.7 MB/s
                            Host <- PCIe <- FPGA read bandwidth = 5572.0 MB/s
    Error(s)              : DMA test data integrity check failed.: Input/output error
    Details               : Host -> PCIe -> FPGA write bandwidth = 6247.9 MB/s
                            Host <- PCIe <- FPGA read bandwidth = 5620.6 MB/s
                            Host -> PCIe -> FPGA write bandwidth = 6686.4 MB/s
                            Host <- PCIe <- FPGA read bandwidth = 6042.9 MB/s
    Error(s)              : DMA test data integrity check failed.: Input/output error
    Details               : Host -> PCIe -> FPGA write bandwidth = 6803.3 MB/s
                            Host <- PCIe <- FPGA read bandwidth = 6394.4 MB/s
    Error(s)              : DMA test data integrity check failed.: Input/output error
                            DMA test data integrity check failed.: Input/output error
                            DMA test data integrity check failed.: Input/output error
                            DMA test data integrity check failed.: Input/output error
                            DMA test data integrity check failed.: Input/output error
                            DMA test data integrity check failed.: Input/output error
    Details               : Host -> PCIe -> FPGA write bandwidth = 6520.6 MB/s
                            Host <- PCIe <- FPGA read bandwidth = 5507.2 MB/s
                            Host -> PCIe -> FPGA write bandwidth = 6949.5 MB/s
                            Host <- PCIe <- FPGA read bandwidth = 5795.6 MB/s
    Error(s)              : DMA test data integrity check failed.: Input/output error
...
-------------------------------------------------------------------------------
Validation failed. Please run the command '--verbose' option for more details
 ```


Next steps:

Follow the steps below to reset system state.

- Warm boot the machine
- Run [xbutil validate](https://xilinx.github.io/XRT/master/html/xbutil.html#xbutil-validate)
- If issues persist
  - Run `xbmgmt examine -r all`
  - See if the resulting output is covered in [SC troubleshooting](sc-troubleshooting.md)

- - -
### Hangs at start of validate test 	
If [xbutil validate](https://xilinx.github.io/XRT/master/html/xbutil.html#xbutil-validate) output displays `Verify kernel: Running Test` for more than a minute and the test is not displaying any progress, the kernel has not successfully loaded and the [xbutil validate](https://xilinx.github.io/XRT/master/html/xbutil.html#xbutil-validate) command has hung.  An example of the output is shown below.


Example Output:
```
Test 3 [0000:83:00.1]     : Verify kernel
[>                   ]  0%: Running Test... < 1s >

```

Next step:

- Reset the system state by following the steps in [DMA test error](card-validation.md#dma-test-error)


- - -
### Verify kernel test skipped

For [DFX-2RP platforms](https://xilinx.github.io/XRT/master/html/platforms_partitions.html#two-stage-platforms) (also know as two stage platforms), the base partition needs to be flashed and the shell partition needs to be loaded prior to running [xbutil validate](https://xilinx.github.io/XRT/master/html/xbutil.html#xbutil-validate).

For DFX-2RP platforms such as u250_gen3x16_base_3, the [xbutil validate](https://xilinx.github.io/XRT/master/html/xbutil.html#xbutil-validate) command will skip tests if the shell partition has not been first been loaded.  In the output below, Test 4 is skipped with Details given as: `Verify xclbin not available or shell partition is not programmed. Skipping validation.` 

 ```
/opt/xilinx/xrt/bin/xbutil validate --device <user BDF> --verbose

Verbose: Enabling Verbosity
Validate Device           : [0000:1a:00.1]
    Platform              : xilinx_u250_gen3x16_base_4
    SC Version            : 4.6.21
    Platform ID           : F8DAC62E-49D9-B0AA-E9FC-6F260D9D0DFB
-------------------------------------------------------------------------------
Test 1 [0000:1a:00.1]     : aux-connection 
    Description           : Check if auxiliary power is connected
    Test Status           : [PASSED]
-------------------------------------------------------------------------------
Test 2 [0000:1a:00.1]     : pcie-link 
    Description           : Check if PCIE link is active
    Test Status           : [PASSED]
-------------------------------------------------------------------------------
Test 3 [0000:1a:00.1]     : sc-version 
    Description           : Check if SC firmware is up-to-date
    Test Status           : [PASSED]
-------------------------------------------------------------------------------
Test 4 [0000:1a:00.1]     : verify 
    Description           : Run 'Hello World' kernel test
    Details               : Verify xclbin not available or shell partition is not
                            programmed. Skipping validation.
    Test Status           : [SKIPPED]
-------------------------------------------------------------------------------
 ```

Next step:
- Rerun validate inlcuding the `--verbose` switch. If the user shell is not loaded the output will indicate that Verify kernel and other tests are not supported
- Load the shell partition before running an application.  See [AR 75975](https://www.xilinx.com/support/answers/75975.html) details.

- - -
### PCIe link check PASSED with warning

If you encounter `PCIE link check PASSED with warning` or `Device trained to lower spec` when running [xbutil validate](https://xilinx.github.io/XRT/master/html/xbutil.html#xbutil-validate), XRT is encountering a PCIe link running slower than the platform limit. An example of these warnings is shown below.

```
...
Test 1 [0000:83:00.1]     : PCIE link
    Warning(s)            : Link is active
                            Please make sure that the device is plugged into Gen 3x16,
                            instead of Gen 3x8. Lower performance maybe experienced.
    Test Status           : [PASSED WITH WARNINGS]
```

Next steps:

- Ensure that the card is in a slot that supports the PCIe link speed
  -See section [Determine PCIe slot type and speed](common-steps.md#determine-pcie-slot-type-and-speed)
- If the card is in a full speed slot:
  - Reseat the card, in a different slot if possible
  - Reboot the server
  - Run [xbutil validate](https://xilinx.github.io/XRT/master/html/xbutil.html#xbutil-validate)
  - If issues persist go to next step
- BIOS may be limiting link speed

There are typically BIOS settings to control PCIe Generation (aka link speed). Many BIOSes support limiting a card to PCIe Gen 1, Gen 2, or Gen 3. The menu structure differs from vendor to vendor and may differ between servers and workstations. Please refer to the manufacturer's documentation for information on your BIOS settings.

- Go into the BIOS and confirm link speed is PCIe Gen3 or higher
  - If the BIOS settings were changed, cold boot and confirm link speed.
- - -
### SC firmware mismatch error

The platform installed on the host has a different SC firmware version than installed on the card.

 ```
xbutil validate -d 17:00.1
...
Test 3 [0000:17:00.1]     : SC version
    Warning(s)            : SC firmware mismatch
                            SC firmware version 4.6.6 is running on the board, but SC
                            firmware version 4.6.11 is expected from the installed
                            shell. Please use xbmgmt examine to check the installed
                            shell.
    Test Status           : [PASSED WITH WARNINGS]
.....
 ```


Next steps:

- [Display card and host platform and SC versions](common-steps.md#display-card-and-host-platform-and-sc-versions) and confirm they match
- [Flash the card with the deployment platform](common-steps.md#flash-the-card-with-a-deployment-platform) a second time to update the card's SC version to match the system

- - -

### AUX power not connected error
 For cards supporting >75W power, [xbutil validate](https://xilinx.github.io/XRT/master/html/xbutil.html#xbutil-validate) will display the following warning if the PCIe AUX power is not connected or not correctly delivering power.  Cards such as the U200/U250/U280 must have the PCIe AUX power connected to the card to deliver 225W required to run applications in the Vitis™ flow.

Example of [xbutil validate](https://xilinx.github.io/XRT/master/html/xbutil.html#xbutil-validate) command warning for card without PCIe AUX power connected.
 ```
 xbutil validate -d 17:00.1
...
Test 1 [0000:17:00.1]     : Aux connection
    Warning(s)            : Aux power is not connected
                            Device is not stable for heavy acceleration tasks
    Test Status           : [PASSED WITH WARNINGS]
 ```

Next steps:

- Confirm AUX power cable is hooked up
  - [Shutdown system and unplug/Pull power](#shutdown-and-unplug-pull-power)
  - Check for the presence of an AUX power cable at the card
    - See [Getting Started with Alveo Data Center Acceleration Cards (UG1301)](https://www.xilinx.com/cgi-bin/docs/bkdoc?k=accelerator-cards;v=latest;d=ug1301-getting-started-guide-alveo-accelerator-cards.pdf) for the location of the AUX power connector on card
    - If there is no cable, find an 8-pin cable and check the server connection
  - If cable is present
    - Remove the cable from card
    - Confirm it is an 8 pin PCIe AUX power connector
    - Reseat cable
    - Confirm there is a good connection at the motherboard side
  - Close up the system
  - Reboot
  - Confirm [expected power level](common-steps.md#monitor-card-power-and-temperature)
  - Confirm the card passes validation by running the following command
  `xbutil validate -d <user BDF>`
  - If power is not registering in XRT, there may be a communication issue between the SC and CMC, go to [SC troubleshooting](sc-troubleshooting.md#voltage-or-temperature-reports-zero)

- - -
### xclmgmt driver issues

If the following error is displayed when running [xbutil validate](https://xilinx.github.io/XRT/master/html/xbutil.html#xbutil-validate), it suggests the management driver is not working correctly.

```
Test 4 [0000:17:00.1]     : Verify kernel
    Error(s)              : /opt/xrt/tests/validate/common/includes/xcl2/xcl2.cpp:34
                            Error calling err = cl::Platform::get(&platforms), error
                            code is: -1001
                            XRT build version: 2.12.385
                            Build hash: daaee8839f2b1760d7715055e3d96630c0a3ae68
                            Build date: 2021-09-19 14:07:20
                            Git branch: master
                            PID: 7099
                            UID: 16119
                            [Tue Sep 21 00:15:24 2021 GMT]
                            HOST: 
                            EXE: /opt/xilinx/xrt/test/validate.exe
                            [XRT] ERROR: No devices found
                            [XRT] ERROR: No devices found
                            [XRT] ERROR: No devices found
    Test Status           : [FAILED]
```

Next steps:

- See if the machine is running a [supported hypervisor](common-steps.md#host-machine-and-hypervisor-information)
- Check to see if the drivers are present with
  - `lsmod | grep xclmgmt`
  - `lsmod | grep xocl`
- [Unload/reload XRT drivers](common-steps.md#unload-reload-xrt-drivers)
- See if a similar issue is posted on [Xilinx forums](https://support.xilinx.com/s/topic/0TO2E000000YKXlWAO/alveo-accelerator-cards)

- - -
### Failed to find xclbin

If the following message is displayed when running [xbutil validate](https://xilinx.github.io/XRT/master/html/xbutil.html#xbutil-validate) it suggests there is an issue with the installed deployment package.

 ```
Test 3 [0000:03:00.1]     : Verify kernel
Test 4 [0000:03:00.1]     : iops
Test 5 [0000:03:00.1]     : Bandwidth kernel
Test 6 [0000:03:00.1]     : vcu
Validation completed, but with warnings. Please run the command '--verbose' option for more details
 ```
 
 Rerun validate adding the `--verbose` switch and look for output including the following
  ```
Test 6 [0000:03:00.1]     : iops
    Description           : Run scheduler performance measure test
    Details               : verify.xclbin not available. Skipping validation
                            Verify xclbin not available or shell partition is not
                            programmed. Skipping validation.
    Test Status           : [SKIPPED]
-------------------------------------------------------------------------------
Test 7 [0000:03:00.1]     : Bandwidth kernel
    Description           : Run 'bandwidth kernel' and check the throughput
    Details               : bandwidth.xclbin not available. Skipping validation
                            Verify xclbin not available or shell partition is not
                            programmed. Skipping validation.
    Test Status           : [SKIPPED]
------------------------------------------
  ```
If either xclbin is not available, follow next steps below.

Next steps:

- [Determine packages installed on the system](common-steps.md#determine-xrt-packages-using-the-package-manager)
- Follow package install steps in [Modifying existing XRT or platform install](modifying-xrt-platform.md)

- - -
### xbmgmt commands not working

If `xbmgmt` commands are not working and there are no errors displayed, it may indicate an error with the XRT installation package.

Next Step:
- [Reinstall the XRT packages](modifying-xrt-platform.md#installing-an-older-xrt) with your existing XRT and platform packages

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