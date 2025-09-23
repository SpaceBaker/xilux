#!/usr/bin/env bash

if [ -d "${HOME}/x-tools/arm-cortexa9_neon-linux-musleabihf/bin" ]; then
	echo "Adding ${HOME}/x-tools/arm-cortexa9_neon-linux-musleabihf/bin"
	PATH="${PATH:+${PATH}:}${HOME}/x-tools/arm-cortexa9_neon-linux-musleabihf/bin"
	echo -e "Exporting ...\nARCH=arm\nCC=arm-cortexa9_neon-linux-musleabihf-gcc\nCHOST=arm-cortexa9_neon-linux-musleabihf\nCROSS_COMPILE=arm-cortexa9_neon-linux-musleabihf-"
	export ARCH=arm
	export CC=arm-cortexa9_neon-linux-musleabihf-gcc
	export CHOST=arm-cortexa9_neon-linux-musleabihf
	export CROSS_COMPILE=arm-cortexa9_neon-linux-musleabihf-
else
        echo "${HOME}/x-tools/arm-cortexa9_neon-linux-musleabihf/bin doesn't exists"
fi
