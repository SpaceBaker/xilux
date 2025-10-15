TOOLCHAIN
=========

# Purpose

A cross-compiler is necessary to generate code on a machine that is different than the one it will run on.  
For exemple, compiling code for an arm cpu on a x86\_64 machine.

Ample documentation is available online.  
[crosstool-NG](https://crosstool-ng.github.io/docs/) is a good starting point.

# Installation

Two installation method are available.

1. Pre-built cross-compiler : Easy but not tailor made. Available through vendors or distro packages  
2. Build your own : Complicated but cutomizable. Tools are availabe to make the process easier.

## Pre-built

Use this method to quickly get a working cross-compiler saving yourself from an headache.

However, you will definitely not get the newest tools.

### Through your distro package manager

If using a Linux system, your distro package manager might already have one readily available.

For exemple, with Ubuntu, you can install a cross-compiler targeting a hard-float arm for gLibC/Linux by entering the following cmd :
`sudo apt install gcc-arm-linux-gnueabihf`

### Through vendor

Vendors sometimes provide their own pre-built toolchain.
You will need to search their website for such download link and install it.

As an exemple, for arm you can find GNU toolchains at [https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)

## Build your own

You can build your own toolchain, but the process is complex and won't be explained here.  
Fortunately, tools are available that makes it simpler. Notably, buildroot and crosstool-NG.  
The Xilux project uses crosstool-NG.

### crosstool-NG

To build a toolchain using crosstool-NG, follow the following steps :

1. Download released version of crosstool-NG  
        `git clone https://github.com/crosstool-ng/crosstool-ng` and checkout the desired version.  
        or  
        `wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-xxx.xxx.xxx.tar.xz` and extract.  
2. Configure your desired toolchain (this is the complex step, refer to crosstool-NG doc for help)  
        `<path/to/crosstool-ng>/bin/ct-ng menuconfig`  
3. Build the toolchain  
        `<path/to/crosstool-ng>/bin/ct-ng build`  
4. Add the toolchain to your PATH  
        `PATH=<path/to/your/toolchain>/bin:$PATH`

The toolchain is now built and can be used.
