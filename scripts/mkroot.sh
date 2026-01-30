#!/usr/bin/env bash

ROOT="root"
TYPE="minimal"
INITRAMFS=false

# Check args
while [[ $# -gt 0 ]]; do
	case $1 in
		-r|--root)
			ROOT="$2"
			shift # past argument
			shift # past value
			;;
		-t|--type)
			TYPE="$2"
			shift # past argument
			shift # past value
			;;
		--initramfs)
			INITRAMFS=true
			shift # past argument
			;;
		-h|--help)
			echo "Usage: $0 [-r|--root <root_directory>] [-t|--type <fhs|minimal>] [--initramfs]"
			echo "	-r, --root	Specify the root directory to create (default: 'root')"
			echo "	-t, --type	Specify the type of root filesystem: 'fhs' or 'minimal' (default: 'minimal')"
			echo "	--initramfs	Include a basic init script for initramfs (default: false)"
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

# Create the ROOT file structure based on TYPE
if [ "$TYPE" == "fhs" ]; then
	echo "Creating FHS root filesystem at ${ROOT}..."
	mkdir -v -p "${ROOT}"/{boot,dev,home,media,mnt,opt,proc,root,run,srv,sys,tmp} || exit 1
	mkdir -v -p "${ROOT}"/etc/init.d || exit 1
	mkdir -v -p "${ROOT}"/usr/{bin,include,lib,local,sbin,share,src} || exit 1
	mkdir -v -p "${ROOT}"/var/{cache,lock,log,opt,tmp} || exit 1
	ln -v -s usr/{bin,sbin,lib} "${ROOT}" || exit 1
	chmod -v a+rwxt "${ROOT}"/tmp || exit 1
elif [ "$TYPE" == "minimal" ]; then
	echo "Creating a minimal root filesystem at ${ROOT}..."
	mkdir -v -p "${ROOT}"/{boot,dev,proc,sys} || exit 1
	mkdir -v -p "${ROOT}"/usr/{bin,sbin,lib} || exit 1
	ln -v -s usr/{bin,sbin,lib} "${ROOT}" || exit 1
else
	echo "Error: Unsupported root filesystem type '${TYPE}'"
	exit 1
fi

# Remove PLACEHOLDER file if it exists (from git)
if [ -e "${ROOT}/PLACEHOLDER" ]; then
	rm -v "${ROOT}"/PLACEHOLDER
fi

# Write template init script. Runs as pid 1 from initramfs to set up and hand off system.
if [ "$INITRAMFS" = true ]; then
	echo "Adding initramfs init script..."
	cat <<- "EOF" >"${ROOT}"/init
	#!/bin/sh

	export HOME=/home PATH=/bin:/sbin

	# Mounts
	echo "Mounting filesystems..."
	mount -t devtmpfs dev dev || mdev -s
	mountpoint -q proc || mount -t proc proc proc
	mountpoint -q sys || mount -t sysfs sys sys

	# Networking
	## loopback device
	echo "Setting up loopback network interface..."
	ip link add lo type dummy
	ip addr add 127.0.0.1/32 dev lo
	ip link set lo up

	# Hand off to shell
	echo "Boot took $(cut -d' ' -f1 /proc/uptime) seconds"
	echo "Done init, starting shell..."
	exec /bin/sh
	EOF

	chmod +x "${ROOT}"/init
fi

#####################################################################

# Google's nameserver, passwd+group with special (root/nobody) accounts + guest
# echo "nameserver 8.8.8.8" > "${ROOT}"/etc/resolv.conf &&
# cat > "${ROOT}"/etc/passwd << 'EOF' &&
# root:x:0:0:root:/root:/bin/sh
# guest:x:500:500:guest:/home/guest:/bin/sh
# nobody:x:65534:65534:nobody:/proc/self:/dev/null
# EOF
# echo -e 'root:x:0:\nguest:x:500:\nnobody:x:65534:' > "${ROOT}"/etc/group || exit 1

# "${TARGET}-populate" -s "$(${CC} -print-sysroot)" -d "${ROOTFS_DIR}"

echo "Done."
