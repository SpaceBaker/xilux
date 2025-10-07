Diary
===========================

# Preface

This file serve as a diary documenting the progress and process of building this project (namely xilux).

# Goal

Lorem ipsum

# Why the name

The name comes from combining Xilinx and Linux.

I wanted a short name for the project, and since I am using a Xilinx board, the name sounded cool enough.

# Procedures

## Creating the layout of the project

The layout of a project is an important, but overlooked, step.
The xilux project attempts to make a concise and logical work environment.
The structure will most probably changes in the course of its development, evolving as I learn.
Currently, the project is structured as followed :  
.  
├── bootgen  
├── doc  
├── fsbl  
├── initramfs  
├── kernel  
├── root  
├── scripts  
├── sources  
└── ssbl  

### bootgen

It only contains scripts (.bif) used by Xilinx's 'bootgen' tool and its bin output.

Note : might be moved in scripts in the future

### doc

All the documentation about this project.

### fsbl

The First Stage BootLoader sources and binaries.  
The FSBL is the code that enables the RAM and load the SSBL into it  
You should make it a (git) submodule of your FSBL code  
The FSBL can sometime be packaged with the SSBL, U-BOOT offers its "U-Boot SPL"

### initramfs

Optional, the target initramfs root...  
Contains all the necessary binaries

### kernel

The name is self explanatory.  
You can directly 'git clone' linux mainline (or your own fork) to this directory (makes it a submodule)

### root

This is the target 'root' that contains everything that will run on your target system.  
You can consider this the 'distro'.

### scripts

Scripts used by the project, to help build system.

Examples are :  
 - mkroot.sh : Create a basic/minimal structure for 'root'
 - mkcpio.sh : Wrapper to archive 'initramfs' to cpio format

### sources

The directory where all the target software sources will be downloaded and built.

### ssbl

The Second Stage BootLoader sources and binaries.  
The SSBL is the program that load the kernel in RAM and launch it.  
The most used SSBL are 'GRUB' and 'U-BOOT'  
You can directly 'git clone' u-boot mainline (or your own fork) to this directory (makes it a submodule)

## Adding submodules

### kernel

We will use the linux kernel for this project. To add it, do the following :

#### Through git

`git submodule add --depth 1 git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git kernel`  
- '--depth 1' means we won't download the whole history. Only the latest branch is fetched and checked out.

`git config -f .gitmodules submodule.kernel.shallow true`  
- This command tells submodule update to only do a shallow update (not really necessary if checking out a tag)

`cd kernel && git fetch origin tag <remote-tag> --no-tags`  
- This command fetch only the specified tag

`git checkout -b <your-new-branch-name> <remote-tag/branch>`  
- Create a new branch from the specified tag

Alternatively (to be tested)

`git submodule add --depth 1 --branch <remote-tag/branch> git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git`

`cd kernel && git checkout -b <your-new-branch-name> <remote-tag/branch>`

#### Through tarball

If you do not wish to use revision control, you can simply download the source code of the desired version and extract it under the 'kernel' folder.

`wget <linux-kernel-version.tar.gz> && tar -xzf <linux-kernel-version.tar.gz> kernel`

### ssbl (u-boot)

For this project we will be using u-boot for the ssbl. It is lightweight and popular amoung embedded systems.

Do the same as what was done with the linux kernel.

## Building the kernel

Prior to building anything, source the 'setup_env.sh' script. This make sure you are compiling for the correct target.

In the kernel dir, use 'make menuconfig' to enable/disable all the neccessary config points you need. This is a complex and tedious task. For my specific case, I used the 'xilinx_zynq_defconfig' found on Xilinx 'linux-xlnx' repo.

(Careful here, it might be trying to change unkown config points)

To find available defconfigs

`make help | grep defconfig`

To create a .config out of a defconfig

`make xxx_defconfig`

To build the kernel (with the maximum available cores)

`make -j$(nproc)`

## Adding sources

All the applications you want on your target system are layed out in 'sources/manifest'

Refer to 'doc/manifest.md' on how to add to it.
