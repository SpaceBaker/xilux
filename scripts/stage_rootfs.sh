#!/usr/bin/env bash

# Exit upon error
set -e

ROOTFS_DIR="${TOP_DIR}/rootfs_staging-$(date +%Y%2m%2d-%H%M%S)"

add_all_modules() {
    for module in ${TOP_DIR}/modules/*; do
        if [ -d "${module}" ]; then
            make -C ${module} INSTALL_MOD_PATH="${ROOTFS_DIR}" install
        fi
    done
}

add_all_apps() {
    local app_bin=""
    local app_name=""
    for app_dir in ${TOP_DIR}/apps/*; do
        if [ -d "${app_dir}" ]; then
            app_name="$(basename ${app_dir})"
            app_bin="${app_dir}/build/${app_name}"
            if [ -f "${app_bin}" ]; then
                install -v -D -m751 "${app_bin}" "${ROOTFS_DIR}/usr/local/bin/${app_name}"
            fi
        fi
    done
}

# Make rootfs directory structure
## Directory name is 'rootfs_staging-yearMonthDay-HourMinuteSecond'
mkroot.sh -t fhs -r "${ROOTFS_DIR}"


# Add all kernel modules from 'kernel'
## Use Makefile built-in script from linux
make -C ${KERNEL_DIR} INSTALL_MOD_PATH="${ROOTFS_DIR}" modules_install
## Add all kernel modules  from 'modules'
add_all_modules
## Cleanup unnecessary 'build' symlink directory
rm -v "${ROOTFS_DIR}/lib/modules/$(make -C ${KERNEL_DIR} kernelrelease)/build"

# Add userspace apps
add_all_apps

# Add all libraries
## Uses crosstool-ng built-in script "populate"
"${CROSS_COMPILE}populate" -v -s "${ROOTFS_DIR}" -d "${ROOTFS_DIR}-populated"