#!/usr/bin/env bash

ROOT="rootfs_staging"
TYPE="minimal"

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
		-h|--help)
			echo "Usage: $0 [-r|--root <root_directory>] [-t|--type <fhs|minimal>]"
			echo "	-r, --root	Specify the root directory to create (default: 'root')"
			echo "	-t, --type	Specify the type of root filesystem: 'fhs' or 'minimal' (default: 'minimal')"
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

echo "Done."
