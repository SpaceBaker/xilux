#!/usr/bin/env bash

# Setup cross-compilation environment for ARM Cortex-A9 with NEON support
if [ -d "${HOME}/x-tools/arm-cortexa9_neon-linux-musleabihf/bin" ]; then
	echo "Purifing PATH an add ${HOME}/x-tools/arm-cortexa9_neon-linux-musleabihf/bin"
	# PATH="${PATH:+${PATH}:}${HOME}/x-tools/arm-cortexa9_neon-linux-musleabihf/bin"
	PATH="${HOME}/x-tools/arm-cortexa9_neon-linux-musleabihf/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:"
	echo -e "Exporting ...\nARCH=arm\nCC=arm-cortexa9_neon-linux-musleabihf-gcc\nCHOST=arm-cortexa9_neon-linux-musleabihf\nCROSS_COMPILE=arm-cortexa9_neon-linux-musleabihf-"
	export ARCH=arm
	export CC=arm-cortexa9_neon-linux-musleabihf-gcc
	export CHOST=arm-cortexa9_neon-linux-musleabihf
	export CROSS_COMPILE=arm-cortexa9_neon-linux-musleabihf-
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
echo "SCRIPT_DIR=${SCRIPT_DIR}"
echo "TOP_DIR=${TOP_DIR}"
echo "ROOT_DIR=${ROOT_DIR}"
echo "SRC_DIR=${SRC_DIR}"
export SCRIPT_DIR
export TOP_DIR
export ROOT_DIR
export SRC_DIR

# Clean up
unset get_script_dir
