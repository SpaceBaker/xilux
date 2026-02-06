#!/usr/bin/env bash

set -e

ROOTFS="rootfs_staging"
TYPE="none"
OUTPUT="initramfs"
compTypes=("bzip2" "gzip" "lz4" "lzma" "lzo" "none" "xc" "zstd")


# compression_type_check() {
# 	for compType in ${compTypes[@]}; do
# 		if [[ $1 == "${compType}" ]]; then
# 			echo 0
# 			return
# 		fi
# 	done

# 	echo 1
# }

# Check args
while [[ $# -gt 0 ]]; do
	case $1 in
		-r|--rootfs)
			ROOTFS="$2"
			shift # past argument
			shift # past value
			;;
		-c|--compression-type)
			TYPE="$2"
			
			# if [[ $(compression_type_check "${TYPE}") -ne 0  ]]; then
			# 	echo "Invalid compression type ${TYPE}"
			# 	echo "Supported are: ${compTypes[*]}"
			# 	exit 1
			# fi
			shift # past argument
			shift # past value
			;;
		-o|--output)
			if [ -z "$2" ]; then
				echo "output cannot be empty"
				exit 1
			fi
			TYPE="$2"
			shift # past argument
			shift # past value
			;;
		-h|--help)
			echo "Usage: $0 [-r|--rootfs <rootfs_directory>] [-t|--type <none|gz|xz>] [-o|--output <output_filename>]"
			echo "	-r, --root	Specify the rootfs directory to compress (default: 'rootfs_staging')"
			echo "	-t, --type	Specify the compression algorithm type for initramfs: 'none', 'gz', 'xz' (default: 'none')"
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

case "${TYPE}" in
	"bzip2")
		OUTPUT="${OUTPUT}.cpio.bz2"
		find . -print0 | cpio --null --create --format=newc | bzip2 -z --best > "../${OUTPUT}"
		;;
	"gzip")
		OUTPUT="${OUTPUT}.cpio.gzip"
		find . -print0 | cpio --null --create --format=newc | gzip --best > "../${OUTPUT}"
		;;
	"lz4")
		OUTPUT="${OUTPUT}.cpio.lz4"
		find . -print0 | cpio --null --create --format=newc | lz4 --best > "../${OUTPUT}"
		;;
	"lzma"|"xz")
		TYPE="lzma"
		OUTPUT="${OUTPUT}.cpio.xz"
		# TOCHECK do we need the --format="lzma" flag ?
		find . -print0 | cpio --null --create --format=newc | xz -z --best > "../${OUTPUT}"
		;;
	"lzo")
		OUTPUT="${OUTPUT}.cpio.lzo"
		find . -print0 | cpio --null --create --format=newc | lz0 --best > "../${OUTPUT}"
		;;
	"none")
		OUTPUT="${OUTPUT}.cpio"
		find . -print0 | cpio --null --create --format=newc > "../${OUTPUT}"
		;;
	"zstd")
		OUTPUT="${OUTPUT}.cpio.zst"
		find . -print0 | cpio --null --create --format=newc | zstd -19 -o "../${OUTPUT}"
		;;
	*)
		echo "Invalid compression type ${TYPE}"
		echo "Supported are: ${compTypes[*]}"
		exit 1
		;;
esac

cd ..
mkimage -n "Ramdisk Image" -A arm -O linux -T ramdisk -C "${TYPE}" -d "${OUTPUT}" "${OUTPUT}".ub
echo "done."

exit 0