#!/usr/bin/env bash

# WORKDIR="$PWD"
TOPDIR="sysroot"

case $1 in
  -n|--name)
    TOPDIR="$2"
    ;;
esac

FHS_SKELETON=( $TOPDIR/{bin,boot,dev,etc/{opt,init.d},home,lib,media,mnt,opt,root,run,sbin,srv,tmp,usr,var} )

mkdir -p "${FHS_SKELETON[@]}"

echo "Done."
