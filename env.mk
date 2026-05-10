###############################################################################
# env.mk
#
# Embedded Linux Make Build Environment Configuration
#
# This file defines the cross-compilation environment for the Xilux ARM embedded Linux target. 
# It configures:
#
#   - Target architecture and toolchain prefix
#   - Cross-compiler binaries (gcc, g++, ld, etc.)
#   - Sysroot location
#   - Flags (MAKEFLAGS, CPPFLAGS, CFLAGS, etc.)
#   - PATH
#
# Usage:
#   Include this file in your top-level Makefile:
#
#       include path/to/env.mk
#
# Customization:
#	- Adjust TARGET to your desired (and installed) toolchain triplet.
#	- Adjust ARCH to your targeted device architecture.
#   - Adjust CROSS_COMPILER_PATH to where your toolchain (TARGET) is installed.
#   - Uncomment and extend MAKEFLAGS/CPPFLAGS/CFLAGS/CXXFLAGS/LDFLAGS as needed.
#
# Notes:
#   - This file sets MAKEFLAGS to use all available CPU cores.
#   - PATH is prefixed with the toolchain's bin directory.
#
# Maintainer: SpaceBaker (emile.forcier@gmail.com)
# Project:    Xilux
# License:    GPLv2
###############################################################################

## Make flags
MAKEFLAGS := -j$(shell nproc) --no-print-directory

## Pre-processor flags
# CPPFLAGS := -I$(ROOTFS_DIR)/usr/include

## C flags
# CFLAGS := -I$(ROOTFS_DIR)/usr/include
CFLAGS := -mcpu=cortex-a9

## C++ flags
# CXXFLAGS := -I$(ROOTFS_DIR)/usr/include

## Linker flags
# LDFLAGS         := -L$(ROOTFS_DIR)/lib -L$(ROOTFS_DIR)/usr/lib
# LD_LIBRARY_PATH := $(ROOTFS_DIR)/usr/lib

# Misc
XILUX_ENV := 1