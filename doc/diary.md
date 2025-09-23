# Preface
This file serve as a diary documenting the progress and process of building this project (namely xilux).

# Goal


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

### ssbl
The Second Stage BootLoader sources and binaries.
The SSBL is the program that load the kernel in RAM and launch it.
The most used SSBL are 'GRUB' and 'U-BOOT'
You can directly 'git clone' u-boot mainline (or your own fork) to this directory (makes it a submodule)
