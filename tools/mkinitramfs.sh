#!/usr/bin/env bash

set -e

ROOTFS="rootfs_staging"
COMPRESSION="none"
OUTPUT="../initramfs"
compTypes=("bzip2" "gzip" "lz4" "lzma" "lzo" "none" "xc" "zstd")

# Check args
while [[ $# -gt 0 ]]; do
	case $1 in
		-r|--rootfs)
			ROOTFS="$2"
			if [ -z "$2" ]; then
				echo "rootfs cannot be empty"
				exit 1
			fi
			shift # past argument
			shift # past value
			;;
		-c|--compression-type)
			COMPRESSION="$2"
			if [ -z "$2" ]; then
				echo "compression-type cannot be empty"
				exit 1
			fi
			shift # past argument
			shift # past value
			;;
		-o|--output)
			if [ -z "$2" ]; then
				echo "output cannot be empty"
				exit 1
			fi
			OUTPUT="$2"
			shift # past argument
			shift # past value
			;;
		-h|--help)
			echo "Usage: $0 [-r|--rootfs <rootfs_directory>] [-t|--type <none|gz|xz>] [-o|--output <output_filename>]"
			echo "	-r, --root	Specify the rootfs directory to compress (default: 'rootfs_staging')"
			echo "	-c, --compression-type	Specify the compression algorithm type for initramfs: ${compTypes[*]} (default: 'none')"
			echo "	-o, --output	Specify the output filename (without extensions) of the initramfs (default: 'initramfs')"
			exit 0
			;;
		-*)
			echo "Unknown option $1"
			exit 1
			;;
		*)
			POSITIONAL_ARGS+=("$1") # save positional arg
			shift # past argument
			;;
	esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

cd ${ROOTFS}

case "${COMPRESSION}" in
	"bzip2")
		OUTPUT="${OUTPUT}.cpio.bz2"
		find . -print0 | cpio --null --create --format=newc | bzip2 -z --best > "${OUTPUT}"
		;;
	"gzip")
		OUTPUT="${OUTPUT}.cpio.gz"
		find . -print0 | cpio --null --create --format=newc | gzip --best > "${OUTPUT}"
		;;
	"lz4")
		OUTPUT="${OUTPUT}.cpio.lz4"
		find . -print0 | cpio --null --create --format=newc | lz4 --best > "${OUTPUT}"
		;;
	"lzma"|"xz")
		COMPRESSION="lzma"
		OUTPUT="${OUTPUT}.cpio.lzma"
		find . -print0 | cpio --null --create --format=newc | xz -z --format="lzma" --best > "${OUTPUT}"
		;;
	"lzo")
		OUTPUT="${OUTPUT}.cpio.lzo"
		find . -print0 | cpio --null --create --format=newc | lz0 --best > "${OUTPUT}"
		;;
	"none")
		OUTPUT="${OUTPUT}.cpio"
		find . -print0 | cpio --null --create --format=newc > "${OUTPUT}"
		;;
	"zstd")
		OUTPUT="${OUTPUT}.cpio.zst"
		find . -print0 | cpio --null --create --format=newc | zstd -19 -o "${OUTPUT}"
		;;
	*)
		echo "Invalid compression type ${COMPRESSION}"
		echo "Supported are: ${compTypes[*]}"
		exit 1
		;;
esac

# cd ..
# mkimage -n "Ramdisk Image" -A arm -O linux -T ramdisk -C "${COMPRESSION}" -d "${OUTPUT}" "u${OUTPUT}"
# mkdir -p images
# mv "${OUTPUT}" "u${OUTPUT}" images/
# echo "done."

exit 0