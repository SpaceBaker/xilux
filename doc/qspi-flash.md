# Quad SPI flash programming

This is a guide to install U-BOOT on the ZC706 FLASH.

It is assumed that you are already booted into U-BOOT through other means (e.i. SD card).

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