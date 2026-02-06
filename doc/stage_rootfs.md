# stage_rootfs

The script stage_rootfs.sh will create a staging area for your target rootf.

The resulting directories are "rootfs_staging-{date-time}" and "rootfs_staging-{date-time}-populated".

The only difference between the two is that the "populated" directory contains all the libraires necessary.  
This last directory is the one to use for your target. Wrap it as an image or compress it.

## Functionning

These are the steps the script execute in order to produce the resulting rootfs.

1. Create the directory structure of rootfs (/bin,/lib,/usr ...)  
2. Install kernel modules from Linux (selected in the .config)  
3. Install all kernel modules from 'modules' directory  
4. Add all (userspace) binaries from 'apps' directory  
5. Install init scripts (mostly in /etc)  
6. Install init binary  
7. Install all NEEDED libraries
