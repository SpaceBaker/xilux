#!/usr/bin/env bash

##################################################################
# Setup a cross-compilation environment
# Uses crosstool-ng 'Option 3' for 'Assembling a root filesystem'
#  "Use separate staging and sysroot directories."
#
#    sysroot: is the directory that contains the toolchain's 
#						  libraries and headers, essential to a minimum 
#						  working linux system (e.g. ld.so or lib.c.so) 
#
#    rootfs: is the target root filesystem. It also provides extra
#						 librairies and headers (/usr/include).
#						 When generating the final rootfs image, it is
#						 possible to removes headers and unused libraires to 
#						 ower the image's size.
#
# See https://crosstool-ng.github.io/docs/toolchain-usage/
##################################################################

# This is the only variables you should have to modify
TARGET=arm-xilux-linux-gnueabihf
CROSS_COMPILER_PATH="/opt/x-tools/${TARGET}"
CROSS_COMPILER_SYSROOT="${CROSS_COMPILER_PATH}/${TARGET}/sysroot"

# Setup cross-compilation environment for ARM Cortex-A9 with NEON support
if [ ! -d "${CROSS_COMPILER_PATH}/bin" ]; then
	echo "ERROR: No cross compiler detected at ${CROSS_COMPILER_PATH}/bin" >&2
	exit 1
fi

# Disable and clear shell hash to ensure that updated PATH is always used
set +h
hash -r

# Make sure that newly created files/directories are writable only by the owner
umask 022

# Get the directory of this script, even if it's a symlink
get_script_dir()
{
    local SOURCE_PATH="${BASH_SOURCE[0]}"
    local SYMLINK_DIR
    local SCRIPT_DIR
    # Resolve symlinks recursively
    while [ -L "$SOURCE_PATH" ]; do
        # Get symlink directory
        SYMLINK_DIR="$( cd -P "$( dirname "$SOURCE_PATH" )" >/dev/null 2>&1 && pwd )"
        # Resolve symlink target (relative or absolute)
        SOURCE_PATH="$(readlink "$SOURCE_PATH")"
        # Check if candidate path is relative or absolute
        if [[ $SOURCE_PATH != /* ]]; then
            # Candidate path is relative, resolve to full path
            SOURCE_PATH=$SYMLINK_DIR/$SOURCE_PATH
        fi
    done
    # Get final script directory path from fully resolved source path
    SCRIPT_DIR="$(cd -P "$( dirname "$SOURCE_PATH" )" >/dev/null 2>&1 && pwd)"
    echo "$SCRIPT_DIR"
}

# Useful environment variables
SCRIPT_DIR=$(get_script_dir)
TOP_DIR=$(dirname "${SCRIPT_DIR}")
KERNEL_DIR="${TOP_DIR}/kernel"
ROOTFS_DIR="${TOP_DIR}/rootfs_staging"
SRC_DIR="${TOP_DIR}/sources"
PATH="${CROSS_COMPILER_PATH}/bin:${SCRIPT_DIR}:${PATH}"
CHOST="${TARGET}"
ARCH="$(echo "${TARGET}" | cut -d '-' -f1)"
CROSS_COMPILE="${TARGET}-"
# Binutils
CC="${TARGET}-gcc"
CXX="${TARGET}-g++"
CPP="${TARGET}-gcc -E"
AR="${TARGET}-ar"
AS="${TARGET}-as"
LD="${TARGET}-ld"
RANLIB="${TARGET}-ranlib"
READELF="${TARGET}-readelf"
STRIP="${TARGET}-strip"
# Make flags
MAKEFLAGS="--no-print-directory -j$(nproc)"
# Pre-processor flags
# CPPFLAGS="-I${ROOTFS_DIR}/usr/include"
# C flags
# CFLAGS="-I${ROOTFS_DIR}/usr/include"
# C++ flags
# CXXFLAGS="-I${ROOTFS_DIR}/usr/include"
# Linker flags
# LDFLAGS="-L${ROOTFS_DIR}/lib -L${ROOTFS_DIR}/usr/lib"
# LD_LIBRARY_PATH="${ROOTFS_DIR}/usr/lib"\

export	SCRIPT_DIR TOP_DIR KERNEL_DIR ROOTFS_DIR SRC_DIR PATH CHOST ARCH CROSS_COMPILE \
		CC CXX CPP AR AS LD RANLIB READELF STRIP MAKEFLAGS CPPFLAGS LDFLAGS

echo -e "New environment is :\n\
	TOP_DIR=${TOP_DIR}\n\
	SCRIPT_DIR=${SCRIPT_DIR}\n\
	KERNEL_DIR=${KERNEL_DIR}\n\
	ROOTFS_DIR=${ROOTFS_DIR}\n\
	SRC_DIR=${SRC_DIR}\n\
	TARGET=${TARGET}\n\
	CROSS_COMPILER_PATH=${CROSS_COMPILER_PATH}\n\
	CROSS_COMPILER_SYSROOT=${CROSS_COMPILER_SYSROOT}\n\
	ARCH=${ARCH}\n\
	CC=${CC}\n\
	CXX=${CXX}\n\
	LD=${LD}\n\
	CHOST=${CHOST}\n\
	CROSS_COMPILE=${CROSS_COMPILE}\n\
	MAKEFLAGS=${MAKEFLAGS}\n\
	CPPFLAGS=${CPPFLAGS}\n\
	CFLAGS=${CFLAGS}\n\
	CXXFLAGS=${CXXFLAGS}\n\
	LDFLAGS=${LDFLAGS}\n\
	PATH=${PATH}"
# LD_LIBRARY_PATH=${LD_LIBRARY_PATH}\n\

# Clean up
unset get_script_dir
