U-Boot
=========================

# TFTP

If enabled, U-Boot provide a tftp utility that makes it possible to download 
files to your target system over LAN. This is helpful in the development phase, 
when you need to tweak kernel, dt or filesystems. Without this, you would have
to constantly insert/eject an sd card between your dev machine and your target.

## Install/run a tftp server ou your dev machine

If not already done, you can follow the following  link as an exemple for a 
linux machine.

[Installing and Configuring a TFTP Server on Linux](https://www.baeldung.com/linux/tftp-server-install-configure-test)

## Configure network on the target machine

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

## Transfering files

1. On your dev machine, point your tftp server to the folder to share.  
2. Copy/Move files you wish to share to that folder.  
3. From U-Boot, download a file using the following command :  
`tftp <ram_addr> <filename>`

NOTE : the last downloaded file will have its size saved in the '$filesize' variable

# Quad SPI flash programming

## Select the device

To select the device, use this command :  
`sf probe <bus>:<devnum>`

Note: for ZC706, it is 0:0

## Erase the memory

To erase the memory, use the following command :  
`sf erase <start_addr> <size_in_bytes>`

Note : for ZC706, the full size of the memory is 32MiB (0x2000000)

## Write to memory

To write to memory, use the following command :  
`sf write <ram_addr> <qspi_flash_addr> <size_in_bytes>`

- <ram_addr> is where the data we want to write (store in memory) is located.  
    For exemple, a previously downloaded from tftp FSBL binary.  
- <qspi_flash_addr> read from the datasheet, sometimes you need to leave an offset...  
- <size_in_bytes> if you previously downloaded through ftp, you can pass the '$filesize' variable,  
    which as been automatically set by tftp.

## Boot configuration

Make sur you set the right boot switches to boot from QUAD-SPI.

NOTE: for ZC706, the boot switches for QUAD-SPI is as followed -> 0b01000