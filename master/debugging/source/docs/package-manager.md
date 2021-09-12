<table class="sphinxhide">
 <tr>
   <td align="center"><img src="https://www.xilinx.com/content/dam/xilinx/imgs/press/media-kits/corporate/xilinx-logo.png" width="30%"/><h1>Alveo Debug Guide</h1>
   </td>
 </tr>
</table>

# Package Manager

This page provides tips and tricks covering the interaction between XRT and platform packages and yum/apt. It is not intended to be used stand alone. If you are just starting to debug please consult the [main page](../README.md) to determine the best starting point for your needs.

## This Page Covers

This page covers some of the package manager issues we have had reported. If your issue is not covered, please do a web search.

## You Will Need

Before beginning debug, you need to:

- Have [Root/sudo permissions](common-steps.md#root-sudo-access)
- Confirm [System compatibility](check-system-compatibility.md)
- Determine which package(s) are failing and failure mode(s)

## Common Cases

### Installation package is not found

During installation, the package manager reports it can not find file(s) and a message similar to the following is displayed.

```
~]$ sudo apt install xrt_202010.2.6.655_18.04-amd64-xrt.deb
Reading package lists... Done
Building dependency tree
Reading state information... Done
E: Unable to locate package xrt_202010.2.6.655_18.04-amd64-xrt.deb
E: Couldn't find any package by glob 'xrt_202010.2.6.655_18.04-amd64-xrt.deb'
E: Couldn't find any package by regex 'xrt_202010.2.6.655_18.04-amd64-xrt.deb'
```

Although the file(s) exists, apt is unable to locate them.  This occurs when just `file_name.deb` is used instead of a complete path to the .deb file.

Next steps:

- Re-install using a complete path.
  - The simplest complete path is `./file_name.deb`
  - For example `sudo apt install ./file_name.deb`

---

### Package installation fails with permission denied

XRT or platform packages will fail to install if you don't have root permission.  Examples of the displayed error for apt and yum are shown below.

#### apt

```
~]$ sudo apt install ./xrt_202010.2.6.655_18.04-amd64-xrt.deb
E: Could not open lock file /var/lib/dpkg/lock-frontend - open (13: Permission denied)
E: Unable to acquire the dpkg frontend lock (/var/lib/dpkg/lock-frontend), are you root?
```

#### yum

```
~]$ sudo yum install xrt_202010.2.6.655_7.4.1708-x86_64-xrt.rpm
Loaded plugins: fastestmirror, langpacks
Repository 'UIM_install' is missing name in configuration, using id
Repository 'opencl' is missing name in configuration, using id
You need to be root to perform this command.
```

Next steps:

- [Confirm you have permission to install](common-steps.md#root-sudo-access)
- Repeat the install with `sudo command` or as root

---

### Installation package is not supported

The package manager says installation package is not supported as shown in the example below.

```
~]$ sudo apt install ./xrt_201920.2.3.1301_16.04-xrt.deb
Reading package lists... Done
E: Unsupported file ./xrt_201920.2.3.1301_16.04-xrt.deb given on commandline
```

This can occur if the provided installation package is not supported.

Next steps:

- Confirm the right version of the deb/rpm for the OS
- Confirm the right mix of apt/yum and file extension

---

### Installation package cannot be opened

The .deb/.rpm package is corrupt and there are errors indicating the package manager can not handle the file as shown in the examples below.

#### apt

```
~]$ sudo apt install ./foo.deb
Reading package lists... Error!
E: Sub-process Popen returned an error code (2)
E: Encountered a section with no Package: header
E: Problem with MergeList /scratch/alveo/platforms/foo.deb
E: The package lists or status file could not be parsed or opened.
```

#### yum

```
~]$ sudo yum install foo.rpm
Loaded plugins: fastestmirror, langpacks
Repository 'UIM_install' is missing name in configuration, using id
Repository 'opencl' is missing name in configuration, using id
Cannot open: foo.rpm. Skipping.
Error: Nothing to do
```

The file is not in the expected format or the file was corrupted during download.

Next steps:

- Compare the checksum on the suspect file against a re-downloaded file with:
    `md5sum file.deb/rpm`
- If the checksums do not match download the file onto the machine directly from the [Alveo landing page](https://www.xilinx.com/products/boards-and-kits/alveo.html)
- Regenerate and compare the checksum after download
- Re-install the packages

---

### Nothing to do error

During XRT installation, yum displays the message `Error: Nothing to do` as shown in the Red Hat example below.

```
~]$ sudo yum install ./xrt_202010.2.6.655_18.04-amd-xrt.deb
Loaded plugins: fastestmirror, langpacks
Repository 'UIM_install' is missing name in configuration, using id
Repository 'opencl' is missing name in configuration, using id
Determining fastest mirrors
 * centos-sclo-rh: mirrors.mit.edu
 * centos-sclo-sclo: mirror.facebook.net
UIM_install                                                                                                                               | 2.5 kB  00:00:00     
centos-sclo-rh                                                                                                                            | 3.0 kB  00:00:00     
<repos cut out>
(2/3): centos-sclo-sclo/x86_64/primary_db                                                                                                 | 292 kB  00:00:00     
(3/3): intel-tbb-repo/primary                                                                                                             |  27 kB  00:00:00     
intel-tbb-repo                                                                                                                                           274/274
No package ./xrt_202010.2.6.655_18.04-amd-xrt.deb available.
Error: Nothing to do
```

This message indicates there is nothing to install.

Next steps:

- Read the error message and if it ends in .deb, the wrong package is being used.
- Otherwise it could be a bad file see [Installation package can't be opened](#installation-package-cannot-be-opened).

---

### Installation package dependency error

 Installation fails with `"_ Error: Package: <name> Requires <dependency>"`.  Packages have dependencies on other packages and this occurs when one or more dependencies can not be found as shown below.  

```
~]$ sudo yum install ./xrt_202010.2.7.766_7.4.1708-x86_64-xrt.rpm
Loaded plugins: langpacks, product-id, search-disabled-repos, subscription-manager

This system is not registered with an entitlement server. You can use subscription-manager to register.

Repository 'UIM_install' is missing name in configuration, using id
Repository 'opencl' is missing name in configuration, using id
Examining ./xrt_202010.2.7.766_7.4.1708-x86_64-xrt.rpm: xrt-2.7.766-1.x86_64
Marking ./xrt_202010.2.7.766_7.4.1708-x86_64-xrt.rpm to be installed
Resolving Dependencies
--> Running transaction check
---> Package xrt.x86_64 0:2.7.766-1 will be installed
--> Processing Dependency: libyaml-devel >= 0.1.4 for package: xrt-2.7.766-1.x86_64
--> Processing Dependency: pkgconfig(yaml-0.1) >= 0.1.4 for package: xrt-2.7.766-1.x86_64
--> Processing Dependency: protobuf-compiler >= 2.5.0 for package: xrt-2.7.766-1.x86_64
--> Processing Dependency: protobuf-devel >= 2.5.0 for package: xrt-2.7.766-1.x86_64
--> Processing Dependency: libudev-devel for package: xrt-2.7.766-1.x86_64
--> Running transaction check
---> Package protobuf-compiler.x86_64 0:2.5.0-8.el7 will be installed
---> Package protobuf-devel.x86_64 0:2.5.0-8.el7 will be installed
---> Package systemd-devel.x86_64 0:219-73.el7.1 will be installed
---> Package xrt.x86_64 0:2.7.766-1 will be installed
--> Processing Dependency: libyaml-devel >= 0.1.4 for package: xrt-2.7.766-1.x86_64
--> Processing Dependency: pkgconfig(yaml-0.1) >= 0.1.4 for package: xrt-2.7.766-1.x86_64
--> Finished Dependency Resolution
Error: Package: xrt-2.7.766-1.x86_64 (/xrt_202010.2.7.766_7.4.1708-x86_64-xrt)
           Requires: pkgconfig(yaml-0.1) >= 0.1.4
Error: Package: xrt-2.7.766-1.x86_64 (/xrt_202010.2.7.766_7.4.1708-x86_64-xrt)
           Requires: libyaml-devel >= 0.1.4
 You could try using --skip-broken to work around the problem
 You could try running: rpm -Va --nofiles --nodigest
```

Next steps:

- Run [xrtdeps.sh](https://github.com/Xilinx/XRT/blob/master/src/runtime_src/tools/scripts/xrtdeps.sh)
  - XRT provides a build dependency install script.
  - It is a superset of the files needed to run
  - Easiest way to sync up the dependencies including epel-release on RHEL/CentOS
  - If a package can not be installed please work with your IT department

---

### Kernel header error

During XRT installation a message indicating kernel headers for the kernel have not been installed similar to the following is displayed.

```
 Building for 3.10.0-862.el7.x86_64
Module build for kernel 3.10.0-862.el7.x86_64 was skipped since the
kernel headers for this kernel does not seem to be installed.
```

This occurs when there is a mismatch between kernel and kernel headers installed on machine.  Part of XRT is compiled against the user kernel and the compiler needs the headers for that exact kernel version. In the above example the headers for `1127` are installed while `862` are needed.

Next steps:

- [Determine the Linux kernel version and headers](common-steps.md#determine-linux-kernel-and-header-information) required
- Confirm they match
- If they do not, run the [xrtdeps.sh](https://github.com/Xilinx/XRT/blob/master/src/runtime_src/tools/scripts/xrtdeps.sh) script to install dependencies

---

### Installation package is older

During package installation, yum fails with `does not update installed package` or apt indicates the package will be `DOWNGRADED` as shown below.

#### yum

```
~]$ sudo yum install alveo/platforms/2020.1_web/xrt/xrt_202010.2.6.655_7.4.1708-x86_64-xrt.rpm
Loaded plugins: fastestmirror, langpacks
Repository 'UIM_install' is missing name in configuration, using id
Repository 'opencl' is missing name in configuration, using id
Examining alveo/platforms/2020.1_web/xrt/xrt_202010.2.6.655_7.4.1708-x86_64-xrt.rpm: xrt-2.6.655-1.x86_64
alveo/platforms/2020.1_web/xrt/xrt_202010.2.6.655_7.4.1708-x86_64-xrt.rpm: does not update installed package.
```

#### apt

```
The following packages will be REMOVED:
  xilinx-u50lv-gen3x4-xdma-base xilinx-u50lv-gen3x4-xdma-validate
The following packages will be DOWNGRADED:
  xrt
0 upgraded, 0 newly installed, 1 downgraded, 2 to remove and 1 not upgraded.
Need to get 0 B/10.0 MB of archives.
After this operation, 2632 kB of additional disk space will be used.
Do you want to continue? [Y/n]
```

This occurs if there is a newer version of the package installed on the system.

If apt wants to downgrade a package, hit `n` and follow next steps.

Next steps:

- Confirm that a downgrade is wanted
- [Capture a list of platforms installed on the system](common-steps.md#determine-xrt-packages-using-the-package-manager)
- Remove items to be downgrade with `apt remove` or `yum remove`
- If this is for XRT, follow [remove XRT](common-steps.md#remove-xrt)
- Install desired packages with the desired versions with apt and yum

Notes:

- XRT needs to be installed before the platforms can be installed
- Deployment platforms need to be installed before development platforms can be installed

---

### No pyopencl error

During XRT installation a message similar to the following is displayed.

```
ImportError: No module named pyopencl
```

This occurs when XRT encounters issues installing third party libraries like numpy or pyopencl.

Next steps:

- Install the latest XRT via the [Alveo landing page](https://www.xilinx.com/products/boards-and-kits/alveo.html)
  - The latest XRT no longer has a dependency on numpy/pyopencl
- Otherwise refer to [AR 73055](https://www.xilinx.com/support/answers/73055.html)

---

### XRT installation fails with Linux kernel V5.xx

During XRT installation, on a Ubuntu system with Linux kernel 5.xx, an error message similar to the following is displayed.

 ```
 Module build for kernel 5.07.0xxxx.x86_64 was skipped since the
kernel headers for this kernel does not seem to be installed.
 ```

Next steps:

- Install XRT 2020.2 or later via the [Alveo landing page](https://www.xilinx.com/products/boards-and-kits/alveo.html)

---

### Held broken packages error

Incorrectly using the insallation package on the wrong OS can result in the error `you have held broken packages`, as shown below.

```
~]$ sudo apt install ./xrt_202010.2.7.761_16.04-amd64-xrt.deb
Reading package lists... Done
Building dependency tree
Reading state information... Done
Note, selecting 'xrt' instead of './xrt_202010.2.7.761_16.04-amd64-xrt.deb'
Some packages could not be installed. This may mean that you have
requested an impossible situation or if you are using the unstable
distribution that some required packages have not yet been created
or been moved out of Incoming.
The following information may help to resolve the situation:

The following packages have unmet dependencies:
 xrt : Depends: libboost-dev (< 1.59) but 1.65.1.0ubuntu1 is to be installed
       Depends: libboost-filesystem-dev (< 1.59) but 1.65.1.0ubuntu1 is to be installed
       Depends: libboost-program-options-dev (< 1.59) but 1.65.1.0ubuntu1 is to be installed
       Depends: libc6 (< 2.24) but 2.27-3ubuntu1 is to be installed
E: Unable to correct problems, you have held broken packages.
```

This occurs if you attempt to install a .rpm package using apt or a .deb package using yum. Ubuntu/apt only supports .deb files while RHEL/yum only supports .rpm files.

Next steps:

- Determine the [machine OS](common-steps.md#determine-linux-release)
- Use the correct set of OS and file type
  - Ubuntu: apt and .deb
  - RHEL/CentOS: yum and .rpm

---

### Installation package missing permissions

The package install fails with one of the following errors:

- `...couldn't be accessed by user '_apt'` or
- `..could not be parsed or opened` or
- `Cannot open:`

Examples of these errors are shown below.

#### apt

- Missing x permission

```
Setting up xilinx-cmc-u50 (1.0.20-2853996) ...
Setting up xilinx-u50lv-gen3x4-xdma-validate (2-2902115) ...
Setting up xilinx-sc-fw-u50 (5.0.27-2.e289be9) ...
Setting up xilinx-u50lv-gen3x4-xdma-base (2-2902115) ...
Partition package installed successfully.
Please flash card manually by running below command:
sudo /opt/xilinx/xrt/bin/xbmgmt flash --update --shell xilinx_u50lv_gen3x4_xdma_base_2
N: Download is performed unsandboxed as root as file '/scratch/alveo_cycle_test/xrt_shell_downloads/xilinx-cmc-u50_1.0.20-2853996_all_18.04.deb' couldn't be accessed by user '_apt'. - pkgAcquire::Run (13: Permission denied)

```

- Missing r permission

```
~]$ sudo apt install ./*deb
Reading package lists... Error!
E: Sub-process Popen returned an error code (2)
E: Encountered a section with no Package: header
E: Problem with MergeList /proj/xcoswmktg/username/alveo/platforms/2020.1_web/U50lv_gen3x4_base2/18.04/xilinx-cmc-u50_1.0.20-2853996_all_18.04.deb
E: The package lists or status file could not be parsed or opened.

```

#### yum

```
~]$ sudo yum install foo.rpm
Loaded plugins: fastestmirror, langpacks
Repository 'UIM_install' is missing name in configuration, using id
Repository 'opencl' is missing name in configuration, using id
Cannot open: foo.rpm. Skipping.
Error: Nothing to do
```

Note this looks the same as a corrupt file. See also [Installation package can't be opened](#installation-package-cannot-be-opened)

This can occur if there is a Linux file permissions issue with the package.  

Next steps:

- Use `ls -al <filename>` to check the file permissions
- If `rx` are missing update the file permissions with
  - Ubuntu: `chmod a+rx *.deb`
  - RHEL/Centos: `chmod a+rx *.rpm`

---
### Failed to create xsabin

When installing the deployment package, an error message similar to the following is displayed.

```
Failed to create xsabin,
install is incomplete
```

This error can occur if XRT is built from GitHub sources without Vitis software platform installed and `XILINX_VITIS` environment variable set.

Next steps:

- Prior to building XRT from GitHub sources, install the Vitis software platform and set up the Vitis environment.
- See [Vitis Unified Software Platform Documentation](https://www.xilinx.com/html_docs/xilinx2020_2/vitis_doc/index.html).

---

### Flash update fails with shell is not applicable

When flashing the card with the command `xbmgmt flash --update --shell` returns `shell is not applicable` as shown in the example below, it indicates that the name of the specified shell is not supported for the targeted card.  This may also occur if the specified shell name is spelled incorrectly.

```
~]$ xbmgmt flash --update --shell xilinx_u250_gen3x16_base_2
WARNING: Failed to flash Card[0000:05:00.0]: Specified shell is not applicable

```

Next steps:

- Confirm the correct shell name is installed and the correct name is used in the command.  To obtain the necessary shell name, run the `xbmgmt flash --scan` command. 

---

### Item not covered above

This guide is not comprehensive package manager and your error condition may not be covered.

Next steps:

- Do a web search for the error
- Look for a fix on a site like [StackOverflow](https://stackoverflow.com/), Ubuntu or Red Hat support
- Check for similar issues on [Xilinx forums](https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo)
- Post on the [Xilinx forums](https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo)

---


### Xilinx Support

For additional support resources such as Answers, Documentation, Downloads, and Alerts, see the [Xilinx Support pages](http://www.xilinx.com/support). For additional assistance, post your question on the Xilinx Community Forums – [Alveo Accelerator Card](https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo).

If you have a suggestion, or find an issue, send an email to alveo_cards_debugging@xilinx.com .

### License

All software including scripts in this distribution are licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

All images and documentation, including all debug and support documentation, are licensed under the Creative Commons (CC) Attribution 4.0 International License (the "CC-BY-4.0 License"); you may not use this file except in compliance with the CC-BY-4.0 License.

You may obtain a copy of the CC-BY-4.0 License at
[https://creativecommons.org/licenses/by/4.0/](https://creativecommons.org/licenses/by/4.0/)


Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

<p align="center"><sup>XD027 | &copy; Copyright 2021 Xilinx, Inc.</sup></p>
