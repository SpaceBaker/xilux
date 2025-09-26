#!/usr/bin/env bash

# pkgm.sh: Download, extract, configure, and build packages from packages.json
# Requires: jq, wget, tar

# Exit immediately if a command exits with a non-zero status
set -e

yellow='\033[1;33m'
nc='\033[0m' # No Color
PKGJSON="${SRC_DIR}/packages.json"

if ! command -v jq &>/dev/null; then
	echo "Error: jq is required." >&2
	exit 1
fi

usage() {
	echo "Usage: $0"
	echo "	-c | --configure"
	echo "	-b | --build"
	echo "	-i | --install"
	echo "	-a | --all"
	echo "	-f | --file <packages.json>"
	echo "	-l | --list"
	echo "	--clean"
	echo "	-h | --help"
	exit 0
}

declare -a name
declare -a version
declare -a url
declare -a config_cmd
declare -a build_cmd
declare -a install_cmd
declare -a tarball
declare -a pkg_dir
declare -a build_dir
declare -a tarball_url

declare -a ACTION
while [[ $# -gt 0 ]]; do
	case "$1" in
		-c | --configure)
			ACTION+=("configure")
			shift # past argument
			;;
		-b | --build)
			ACTION+=("build")
			shift # past argument
			;;
		-i | --install)
			ACTION+=("install")
			shift # past argument
			;;
		-a | --all)
			ACTION+=("all")
			shift # past argument
			;;
		-l | --list)
			ACTION+=("list")
			shift # past argument
			;;
		-f | --file)
			PKGJSON="$2"
			shift # past argument
			shift # past value
			;;
		--clean)
			ACTION=("clean")
			shift # past argument
			;;
		help|-h|--help)
		shift # past argument
			usage
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

# Check if PKGJSON file exists
if [[ ! -f "$PKGJSON" ]] ; then
	echo "Error: '$PKGJSON' file not found!" >&2
	exit 1
fi

# Parse packages from PKGJSON
readarray -t packages < <(jq -c '.packages[]' "${PKGJSON}")
for pkg in "${packages[@]}"; do
	# Parse package details
	name+=("$(echo "${pkg}" | jq -r '.name')")
	version+=("$(echo "${pkg}" | jq -r '.version')")
	url+=("$(echo "${pkg}" | jq -r '.download_url')")
	config_cmd+=("$(echo "${pkg}" | jq -r '.configuring_cmd | join(" ")')")
	build_cmd+=("$(echo "${pkg}" | jq -r '.building_cmd | join(" ")')")
	install_cmd+=("$(echo "${pkg}" | jq -r '.installing_cmd | join(" ")')")

	# Assume tar.gz tarball available
	tarball_url+=("$(echo "${url[@]: -1}" | sed 's#[^/]$#&/#')${name[@]: -1}-${version[@]: -1}.tar.gz")
	tarball+=("${SRC_DIR}/${name[@]: -1}-${version[@]: -1}.tar.gz")
	pkg_dir+=("${SRC_DIR}/${name[@]: -1}-${version[@]: -1}")
	build_dir+=("${pkg_dir[@]: -1}/build")
done

nb_pkgs=${#packages[@]}

# List packages
if [[ " ${ACTION[*]} " =~ [[:space:]]list[[:space:]] ]]; then
	echo "Found ${nb_pkgs} packages in ${PKGJSON}."
	echo "Packages: ${name[*]}"
	if [[ ${#ACTION[@]} -eq 1 ]]; then
		exit 0
	fi
fi

# Clean
if [[ " ${ACTION[*]} " =~ [[:space:]]clean[[:space:]] ]]; then
	for (( i=0; i<nb_pkgs; i++ )); do
		echo "=== Removing ${name[$i]} ==="
		rm -rf "${tarball[$i]}" "${pkg_dir[$i]}"
	done
	exit 0
fi

# Download
for (( i=0; i<nb_pkgs; i++ )); do
	if [[ ! -f "${tarball[$i]}" ]]; then
		echo "=== Downloading ${tarball_url[$i]} ==="
		wget -nc "${tarball_url[$i]}" -O "${tarball[$i]}"
	fi
done

# Extract
for (( i=0; i<nb_pkgs; i++ )); do
	if [[ ! -d "${pkg_dir[$i]}" ]]; then
		echo "=== Extracting ${tarball[$i]} ==="
		tar -xzf "${tarball[$i]}" -C "${SRC_DIR}"
		# Some tarballs extract to just $name instead of $name-$version
		if [ ! -d "${pkg_dir[$i]}" ]; then
			echo -e "Renaming \'${SRC_DIR}/${name[$i]}\' to \'${pkg_dir[$i]}\'"
			mv "${SRC_DIR}/${name[$i]}" "${pkg_dir[$i]}"
		fi
	fi
done

# Configure
if [[ " ${ACTION[*]} " =~ [[:space:]]configure[[:space:]] || " ${ACTION[*]} " =~ [[:space:]]all[[:space:]] ]]; then
	for (( i=0; i<nb_pkgs; i++ )); do
		if [[ ! -d "${build_dir[$i]}" ]]; then
			echo "=== Configuring ${name[$i]} ==="
			mkdir -p "${build_dir[$i]}" && cd "${build_dir[$i]}"
			eval "../${config_cmd[$i]}"
		fi
	done
fi

# Build
if [[ " ${ACTION[*]} " =~ [[:space:]]build[[:space:]] || " ${ACTION[*]} " =~ [[:space:]]all[[:space:]] ]]; then
	for (( i=0; i<nb_pkgs; i++ )); do
		cd "${build_dir[$i]}"
		echo "=== Building ${name[$i]} ==="
		echo -e "${yellow}eval ${build_cmd[$i]}${nc}"
		eval "${build_cmd[$i]}"
	done
fi

# Install
if [[ " ${ACTION[*]} " =~ [[:space:]]install[[:space:]] || " ${ACTION[*]} " =~ [[:space:]]all[[:space:]] ]]; then
	for (( i=0; i<nb_pkgs; i++ )); do
		install_dir="$(echo "${install_cmd#*DESTDIR=}" | cut -d' ' -f1)"
		cd "${build_dir[$i]}"
		echo "=== Installing ${name[$i]} to '${install_dir}' ==="
		echo -e "${yellow}eval ${install_cmd[$i]}${nc}"
	done
fi
