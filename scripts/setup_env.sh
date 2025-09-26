#!/usr/bin/env bash

# Setup cross-compilation environment for ARM Cortex-A9 with NEON support
if [ -d "${HOME}/x-tools/arm-cortexa9_neon-linux-musleabihf/bin" ]; then
	echo "Purifing PATH an adding ${HOME}/x-tools/arm-cortexa9_neon-linux-musleabihf/bin"
	# PATH="${PATH:+${PATH}:}${HOME}/x-tools/arm-cortexa9_neon-linux-musleabihf/bin"
	PATH="${HOME}/x-tools/arm-cortexa9_neon-linux-musleabihf/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:"
	BUILDMACHINE="${HOSTTYPE}"
	export ARCH=arm
	export CC=arm-cortexa9_neon-linux-musleabihf-gcc
	export CXX=arm-cortexa9_neon-linux-musleabihf-g++
	export CHOST=arm-cortexa9_neon-linux-musleabihf
	export CROSS_COMPILE=arm-cortexa9_neon-linux-musleabihf-
	export BUILDMACHINE
else
	echo "${HOME}/x-tools/arm-cortexa9_neon-linux-musleabihf/bin doesn't exist"
	exit 1
fi

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

# Export useful environment variables
SCRIPT_DIR=$(get_script_dir)
PATH="${PATH:+${PATH}:}${SCRIPT_DIR}:"
TOP_DIR=$(dirname "${SCRIPT_DIR}")
ROOT_DIR="${TOP_DIR}/root"
SRC_DIR="${TOP_DIR}/sources"
export SCRIPT_DIR
export TOP_DIR
export ROOT_DIR
export SRC_DIR

echo -e "New environment is :\n\
	ARCH=${ARCH}\n\
	CC=${CC}\n\
	CXX=${CXX}\n\
	CHOST=${CHOST}\n\
	CROSS_COMPILE=${CROSS_COMPILE}\n\
	BUILDMACHINE=${BUILDMACHINE}\n\
	SCRIPT_DIR=${SCRIPT_DIR}\n\
	TOP_DIR=${TOP_DIR}\n\
	ROOT_DIR=${ROOT_DIR}\n\
	SRC_DIR=${SRC_DIR}\n\
	PATH=${PATH}"

# Clean up
unset get_script_dir
