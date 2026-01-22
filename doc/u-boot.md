# U-Boot

## Requirements

You must install the following packages on your host/build machine :

```bash
sudo apt-get install \
  bc bison build-essential coccinelle device-tree-compiler\
  dfu-util efitools flex gdisk graphviz imagemagick \
  libgnutls28-dev libguestfs-tools libncurses-dev \
  libpython3-dev libsdl2-dev libssl-dev lz4 lzma lzma-alone openssl \
  pkg-config python3 python3-asteval python3-coverage python3-filelock \
  python3-pkg-resources python3-pycryptodome python3-pyelftools \
  python3-pytest python3-pytest-xdist python3-sphinxcontrib.apidoc \
  python3-sphinx-rtd-theme python3-subunit python3-testtools \
  python3-venv swig uuid-dev
```

## Compiling

Make sure you source the environment first  
`source script/set_env.sh`

1. `cd u-boot`

2. `make xilinx_zynq_virt_defconfig`  
This step load the generic config for a zynq board

3. `make menuconfig`  
In this step, you can fine tune the config

4. `make`  
This step will produce the binary in multiple formats.  
In our case, we require 'u-boot.elf'.

## Installing on the target

To use U-BOOT in your embedded system, it must be install somewhere in its memory.

An SD card is often used for its convinience, as it is a removable device.  
Other options are available, such as FLASH (NOR / NAND), eMMC or EEPROM.

To install U-BOOT on an SD card, read the `sdcard.md` file located in `doc` folder of this project.

To install U-BOOT on the FLASH through QUAD-SPI, read the `qspi-flash.md` file located in `doc` folder of this project.

## TFTP

If enabled, U-Boot provide a tftp utility that makes it possible to download  
files to your target system over LAN. This is helpful in the development phase,  
when you need to tweak kernel, dt or filesystems. Without this, you would have  
to constantly insert/eject an sd card between your dev machine and your target.

### Install/run a tftp server ou your dev machine

If not already done, you can follow the following  link as an exemple for a linux machine.

[Installing and Configuring a TFTP Server on Linux](https://www.baeldung.com/linux/tftp-server-install-configure-test)

### Configure network on the target machine

If not done in a script, you can either manually give an ip address :  
`setenv ipaddr <ip-addr>`  
`setenv serverip <tftp-server-ip-addr>`

or use DHCP :  
`dhcp`

You can make sure everything is setup correctly by pinging the server :  
`ping <tftp-server-ip-addr>`

You can save these addresses into the U-Boot environement :  
`saveenv`  
You'll then be able to skip this step from now on.

### Transfering files

1. On your dev machine, point your tftp server to the folder to share.  
2. Copy/Move files you wish to share to that folder.  
3. From U-Boot, download a file using the following command :  
`tftp <ram_addr> <filename>`

NOTE : the last downloaded file will have its size saved in the '$filesize' variable
