# bootgen

For mor information, visit the [AMD userguide](https://docs.amd.com/r/en-US/ug1283-bootgen-user-guide)

## Requirements

You must install the following packages on your host/build machine:

`libssl-dev`

## Fetching

Go to [Xilinx GitHub](https://github.com/Xilinx/bootgen) page for all the detail.  

`git clone --depth 1 --branch xilinx_v2025.2 org-3189299@github.com:Xilinx/bootgen.git`

## Building

You need to build the source code to use the application.

`cd bootgen`  
`make`

Once done, the binary can be found in ".../bootgen/build/bin/bootgen"

## Usage

Assuming bootgen is in your PATH, you can generate a boot image by executing the following command :

`bootgen -arch zynq -image <path/to/input/boot.bif> -w -o <path/to/output/boot.bin>`
