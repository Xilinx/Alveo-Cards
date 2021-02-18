<table class="sphinxhide">
 <tr>
   <td align="center"><img src="https://www.xilinx.com/content/dam/xilinx/imgs/press/media-kits/corporate/xilinx-logo.png" width="30%"/><h1>Alveo Debug Guide</h1>
   </td>
 </tr>
</table>

# Modifying XRT or Platform
The Xilinx Runtime library (XRT) is an open-source easy to use software stack that facilitates management and usage of Alveo™ accelerator cards. Not all versions of XRT will work with all Alveo card deployment platforms, in some cases it may be necessary to modify the XRT or platform to meet overall requirements.
It is not intended to be used standalone. If you are just starting to debug please consult the [main page](../README.md)

## This Page Covers

Steps to modify XRT, deployment, and development package installations.

If you want to install:
  - A newer platform
    - Go to [Installing a new platform](#installing-a-new-platform)
  - An updated XRT
    - Go to [Installing an XRT update](#installing-an-xrt-update)
  - An older platform
    - Go to [Installing an older platform](#installing-an-older-platform)
  - An older XRT
      - Go to [Installing an older XRT](#installing-an-older-XRT)
  - A development platform to match a deployment platform
    - Go to [Installing a development platform](#installing-a-development-platform)

## You Will Need

Before modifying XRT, you need to:

- Have [Root/sudo permissions](common-steps.md#root-sudo-access)
-  Ensure the card(s), XRT, and the deployment packages are installed and working as expected as part of the [card install](card-install.md)

Next determine your starting state:
- [Determine XRT and platform packages installed on the system](common-steps.md#determine-xrt-packages-using-the-package-manager)
- [Determine platform running on the card](common-steps.md#determine-platform-and-sc-on-card-and-system)

## Common Cases

- - -

### Installing a new platform

If XRT is already installed and there is a new platform to be installed on the Alveo card, follow the below steps:

 - Download the new platform from the [Alveo landing page](https://www.xilinx.com/products/boards-and-kits/alveo.html)
 - [Confirm XRT/Platform compatibility](common-steps.md#confirm-xrtplatform-compatibility)
    - Download a new XRT if needed
 - [Return each card to golden](common-steps.md#reverting-the-card-to-factory-image)
 - Remove the old deployment package using
    - Ubuntu: `sudo apt remove installed_platform_name`
    - RHEL/CentOS: `sudo yum remove installed_platform_name`
- If a new XRT is needed, upgrade XRT using one of the commands below
    - Ubuntu: `sudo apt install ./xrt_package_name.deb`
    - RHEL/CentOS: `sudo yum install xrt_package_name.rpm`
- Install the new deployment package on the system using one of the commands below
    - Ubuntu: `sudo apt install ./platform_package_name.deb`
    - RHEL/CentOS: `sudo yum install platform_package_name.rpm`
- Flash the FPGA image onto the card(s) using `sudo xbmgmt flash --update --shell <name>`
    - If needed, you can determine the shell name with `sudo xbmgmt flash --scan --verbose`
- Cold boot the machine
- Use `sudo xbmgmt flash --scan --verbose` to make sure the platform and the SC image on card match those installed on the system
    - Some platforms require a second flash to update the SC image
    - If the SC image mismatches run the flash command a second time
- Run `xbutil validate` to determine install is working
- Optionally download and [install the development platform](#installing-a-development-platform)

- - -

### Installing an XRT update

If XRT is already installed and you want to install a newer XRT version, follow the below steps:

- Download the new XRT package from the [Alveo landing page](https://www.xilinx.com/products/boards-and-kits/alveo.html)
- Confirm the [host system is compatible](check-system-compatibility.md)
- Check which platforms are on card with `sudo xbmgmt flash --scan --verbose`
    - For each card that has a platform installed [Confirm XRT/Platform compatibility](common-steps.md#confirm-xrtplatform-compatibility)
    - If XRT does not support the new platform [Return the card to golden](common-steps.md#reverting-the-card-to-factory-image)
- Upgrade XRT using one of the commands below
  - Ubuntu: `sudo apt install ./xrt_package_name.deb`
  - RHEL/CentOS: `sudo yum install xrt_package_name.rpm`
- Warm boot the machine
- Run `xbutil version` to confirm the XRT version
- Run `xbutil validate` to determine install is working

- - -

### Installing an older platform

If XRT is already installed and there is a older platform to be installed on the Alveo card, follow the below steps:

- Download the platform package from the archive section of the [Alveo landing page](https://www.xilinx.com/products/boards-and-kits/alveo.html)
- [Confirm XRT/Platform compatibility](common-steps.md#confirm-xrtplatform-compatibility) to make sure XRT that will support the platform
    - Download XRT package if needed
- [Return each card to golden](common-steps.md#reverting-the-card-to-factory-image)
- If a different XRT is needed, [Remove XRT](common-steps.md#remove-xrt) and install the replacement XRT package on the system using one of the commands below
    - Ubuntu: `sudo apt install ./xrt_package_name.deb`
    - RHEL/CentOS: `sudo yum install xrt_package_name.rpm`
- Else remove the current deployment package with `sudo apt remove` or `sudo yum remove`
  - If needed use the package manager to find the installed [package names](common-steps.md#determine-xrt-packages-using-the-package-manager)
- Install the replacement deployment package on the system using one of the below
  - Ubuntu: `sudo apt install ./platform_package_name.deb`
  - RHEL/CentOS: `sudo yum install platform_package_name.rpm`
- Flash the card with the command given during package install
- Cold boot the machine to update the FPGA
- Confirm card validates using `xbutil validate`
- Optionally download and [install the development platform](#installing-a-development-platform)

- - -

### Installing an older XRT

If XRT is already installed and an older version of XRT is to be installed, follow the below steps:

- Download the XRT package from the archives section of the [Alveo landing page](https://www.xilinx.com/products/boards-and-kits/alveo.html)
- Determine which platform will be used
  - Make sure to have the package to re-install the platform
- Determine which platform is on the card
- If the platform is different
  - [Return each card to golden](common-steps.md#reverting-the-card-to-factory-image)
- [Remove XRT](common-steps.md#remove-xrt)
- Install the replacement xrt package on the system using one of commands the below
  - Ubuntu: `sudo apt install ./xrt_package_name.deb`
  - RHEL/CentOS: `sudo yum install xrt_package_name.rpm`
- Install the replacement deployment package on the system using one of commands the below
  - Ubuntu: `sudo apt install ./platform_package_name.deb`
  - RHEL/CentOS: `sudo yum install platform_package_name.rpm`
- Flash the card with the command given during package install
- Cold boot the machine to update the FPGA
- Confirm card validates using `xbutil validate`
- Optionally download and [install the development platform](#installing-a-development-platform)

- - -

### Installing a development platform

After XRT is installed and once it has been decided on the platform that will be used on the Alveo card, follow the below steps to install the development platform:

- Ensure XRT is installed
- [Determine platform running on the card](common-steps.md#determine-platform-and-sc-on-card-and-system)
- Go to the [Alveo landing page](https://www.xilinx.com/products/boards-and-kits/alveo.html) to download the matching development platform
- Use `apt install` or `yum install` to install the platform package

- - -

### Platform Re-Install

The steps to re-install a platform are given below.

 - Uninstall the packages first
    - `sudo yum remove ./<xrt_package_name>` (or)
    - `sudo apt remove ./<xrt_package_name>`
 - Go to [Installing an older XRT](#installing-an-older-xrt)

- - -

### Uninstalling XRT

Removing XRT will also remove any packages that depend on XRT, for example the platforms. Please follow the below link to remove XRT:

  - Go to [Remove XRT](common-steps.md#remove-xrt)

- - -

### No XRT installed
If you have Alveo cards in a system and no XRT drivers, treat this as a new install.
- Go to the [software install and card validation](card-install.md) of the appropriate install guide

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
