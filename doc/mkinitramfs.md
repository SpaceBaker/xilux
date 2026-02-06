# mkinitramfs

The mkinitramfs.sh script generates an initramfs image from a populated rootfs directory.  
This script does not generate the initramfs content (binaires and scripts), this is yours to do.

## What is an initramfs

Initramfs (Initial RAM Filesystem) is a compressed archive of a temporary root filesystem loaded into memory  
during the Linux boot process, acting as a bridge between the kernel boot and the mounting of the actual root filesystem.

It contains essential drivers, tools, and scripts needed to prepare the system,  
such as loading storage drivers or unlocking encrypted drives, before transitioning to the real system root.

## Options

```txt
-r|--rootfs                 The rootfs directory to compress (default: rootfs_staging)
-c|--compression-type       The compression type to use (default: none)
-o|--output                 The output file name without extensions (default: initramfs)
-h|--help                   Display a helper message
```

Supported compression types are :  

- bzip2
- gzip
- lz4
- lzma / xc
- lzo
- zstd

## Usage

Exemple:

`mkinitramfs -r test/rootfs -c gzip -o test_rootfs`
