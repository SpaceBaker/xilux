#!/usr/bin/env bash

# manifest.sh: Download, extract/checkout, configure, and build packages from manifest.json
# Requires: jq, curl, tar, git

# Exit immediately if a command exits with a non-zero status
set -e

yellow='\033[1;33m'
nc='\033[0m' # No Color
MANIFEST="${SRC_DIR}/manifest.json"

if [[ ! -f "$MANIFEST" ]] ; then
	echo "Error: Manifest file '$MANIFEST' not found!" >&2
	exit 1
fi

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
	echo "	-h | --help"
	exit 0
}

declare -a ACTION
while [[ $# -gt 0 ]]; do
	case "$1" in
		-c|--configure)
			ACTION+=("configure")
			shift # past argument
			;;
		-b|--build)
			ACTION+=("build")
			shift # past argument
			;;
		-i|--install)
			ACTION+=("install")
			shift # past argument
			;;
		-a|--all)
			ACTION+=("all")
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


readarray -t packages < <(jq -c '.packages[]' "${MANIFEST}")
for pkg in "${packages[@]}"; do
	name=$(echo "${pkg}" | jq -r '.name')
	version=$(echo "${pkg}" | jq -r '.version')
	method=$(echo "${pkg}" | jq -r '.download_method')
	git_url=$(echo "${pkg}" | jq -r '.git_url')
	url=$(echo "${pkg}" | jq -r '.download_url')
	config_cmd=$(echo "${pkg}" | jq -r '.configuring_cmd | join(" ")')
	build_cmd=$(echo "${pkg}" | jq -r '.building_cmd | join(" ")')
	install_cmd=$(echo "${pkg}" | jq -r '.installing_cmd | join(" ")')
	pkg_dir="${SRC_DIR}/${name}-${version}"
	build_dir="${pkg_dir}-build"
	echo "=== Processing ${name} v${version} ==="
	if [ "${method}" = "git" ]; then
		if [ ! -d "${pkg_dir}/.git" ]; then
			echo "Cloning ${git_url} into ${pkg_dir}"
			git clone "${git_url}" "${pkg_dir}"
		fi
		cd "${pkg_dir}"
		echo "Checking out tag v${version} (if exists)"
		git fetch --tags
		if git rev-parse "v${version}" >/dev/null 2>&1; then
			git switch --detach "v${version}"
		fi
		if [[ -f "bootstrap" ]]; then
			echo "Running bootstrap for ${name}"
			eval bootstrap
		elif [[ -f "autogen.sh" ]]; then
			echo "Running autogen.sh for ${name}"
			eval autogen.sh
		fi
	else
		# Assume HTTPS tarball
		tarball_url="$(echo "${url}" | sed 's#[^/]$#&/#')${name}-${version}.tar.gz"
		tarball="${SRC_DIR}/${name}-${version}.tar.gz"
		# TODO : handle case where only uncompressed source is present
		# TODO : handle case where only .tar.gz is present
		if [[ ! -f "${tarball}" || ! -d "${pkg_dir}" ]]; then
			echo "Downloading ${tarball_url}"
			curl -L "${tarball_url}" -o "${tarball}"
			echo "Extracting ${tarball}"
			# mkdir -p "${pkg_dir}"
			# tar -xvzf "${tarball}" -C "${pkg_dir}"
			tar -xvzf "${tarball}"
			# Some tarballs extract to $name-$version, some to $name
			if [ ! -d "${pkg_dir}" ]; then
				mv "${SRC_DIR}/${name}" "${pkg_dir}"
			fi
		fi
	fi

	mkdir -p "${build_dir}" && cd "${build_dir}"

	if [[ " ${ACTION[*]} " =~ [[:space:]]configure[[:space:]] || " ${ACTION[*]} " =~ [[:space:]]all[[:space:]] ]]; then
		echo "Configuring ${name}"
		echo -e "${yellow}config_cmd = ${pkg_dir}/${config_cmd}${nc}"
		eval "${pkg_dir}/${config_cmd}"
	fi

	if [[ " ${ACTION[*]} " =~ [[:space:]]build[[:space:]] || " ${ACTION[*]} " =~ [[:space:]]all[[:space:]] ]]; then
		echo "Building ${name}"
		echo -e "${yellow}build_cmd = ${build_cmd}${nc}"
		eval "${build_cmd}"
	fi

	if [[ " ${ACTION[*]} " =~ [[:space:]]install[[:space:]] || " ${ACTION[*]} " =~ [[:space:]]all[[:space:]] ]]; then
		install_dir="$(echo "${install_cmd#*DESTDIR=}" | cut -d' ' -f1)"
		echo "Installing ${name} to '${install_dir}'"
		echo -e "${yellow}install_cmd = ${install_cmd}${nc}"
		eval "${install_cmd}"
	fi

	echo -e "=== Done ${name} ===\n"
	cd "${SRC_DIR}"
done
