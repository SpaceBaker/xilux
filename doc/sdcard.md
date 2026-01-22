# SD Card

This document explains how to format an SD card for a zynq board.

## Purpose

The SD card can be used to store any non-volatile data.  
However, the most common usage is as a storage for the boot components (fsbl, ssbl)  
as well as the rootfs.

Thus, the tutorial is demonstrating how to format the SD card for that purpose.

## Partitions

The layout of the partitions is as followed :

```sh
DEV       LABEL   TYPE   SIZE  
sdX  
├── sdX1: BOOT    FAT32  ~200MB  
└── sdX2: ROOT    EXT4   "remaining space"
```

## Clear the SD card

**Warning**: The following commands will use '/dev/sdX' to refer to the SD card device. Replace this with the actual device on your system.  
Executing the following commands on the wrong device may corrupt your data on other file systems.  
Also, all data on your SD card will be destroyed.

`dd if=/dev/zero of=/dev/sdX bs=1024 count=1`

## Partitioning

1. Enter the partitioning utility 'fdisk'

`fdisk /dev/sdX`

2. Create the first partition of 200MB

```sh
Command (m for help): n
Partition type:
 p primary (0 primary, 0 extended, 4 free)
 e extended
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-15759359, default 2048):
Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-15759359, default 15759359): +200M
```

3. Create the second partition containing the remaining space on the card.

```sh
Command (m for help): n
Partition type:
 p primary (1 primary, 0 extended, 3 free)
 e extended
Select (default p): p
Partition number (1-4, default 2): 2
First sector (411648-15759359, default 411648):
Using default value 411648
Last sector, +sectors or +size{K,M,G} (411648-15759359, default 15759359):
Using default value 15759359
```

4. Now set the bootable flag and type for partition 1

```sh
Command (m for help): a
Partition number (1-4): 1
  
Command (m for help): t
Partition number (1-4): 1
Hex code (type L to list codes): c
Changed system type of partition 1 to c (W95 FAT32 (LBA))
```

5. And the type for partition 2

```sh
Command (m for help): t
Partition number (1-4): 2
Hex code (type L to list codes): 83
Changed system type of partition 2 to 83 (EXT4 (linux))
```

6. Verify the new partition table

```sh
Command (m for help): p
  
Disk /dev/sdX: 8068 MB, 8068792320 bytes
249 heads, 62 sectors/track, 1020 cylinders, total 15759360 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x920c958b
  
 Device Boot Start End Blocks Id System
/dev/sdX1 * 2048 411647 204800 c W95 FAT32 (LBA)
/dev/sdX2 411648 15759359 7673856 83 Linux
```

7. Write the changes (WARNING: irreversible change)

```sh
Command (m for help): w
The partition table has been altered!
  
Calling ioctl() to re-read partition table.
  
WARNING: If you have created or modified any DOS 6.x
partitions, please see the fdisk manual page for additional
information.
Syncing disks.
```

8. Create file systems on the new partitions

```sh
mkfs.vfat -F 32 -n boot /dev/sdX1
mkfs.ext4 -L root /dev/sdX2
```

9. Mount the boot partition

```sh
mkdir -p /mnt/boot
mount /dev/sdX1 /mnt/boot
```

10. Copy the boot.bin or contents of the release archive to the SD card, e.g.

`cp boot.bin /mnt/boot/`

11. Unmount the SD card

`umount /mnt/boot`

## Testing

Make sure the board is powered off and connected to a host pc through a serial/usb port.

1. The SD card can now be removed and transferred over to the target platform.

2. On the board, configure the boot mode switches for the SD boot mode.

| SWITCHES |  VALUE  |
| ---------|---------|
|    SW1   |    0    |
|    SW2   |    0    |
|    SW3   |    1    |
|    SW4   |    1    |
|    SW5   |    0    |

3. Power up the board

4. Verify that board enter U-BOOT
