###############################################################################
# Xilux Cross-Compilation Build System
# -----------------------------------------------------------------------------
# Description:
#   This top-level Makefile orchestrates the complete cross-compilation and
#   image generation process for the Xilux embedded Linux platform.
#
#   It manages the build flow for:
#     - Bootloader (U-Boot)
#     - Linux kernel and kernel modules
#     - Device Tree blobs
#     - User-space applications
#     - Third-party / external packages
#     - Root filesystem generation
#     - Initramfs generation
#     - Final bootable images (boot.bin, FIT image, etc.)
#
#   All components are cross-compiled using the configured toolchain and
#   assembled into a deployable embedded Linux image.
#
# Default Directory Layout:
#   apps/               - Project user-space applications source code
#   bootgen/			- bootgen image generation scripts
#   devicetree/			- Project device tree source files (.its, .dts, .dtsi)
#   fsbl/				- Project First Stage Bootloader source code
#   kernel/				- Kernel source code
#   modules/			- Project out-of-tree Kernel modules source code
#   output/             - Final rootfs, images and deployable binaries
#   packages/           - Third-party packages source code
#   scripts/            - Scripts for the target system
#   tools/              - Utilities used by the build system
#   u-boot/             - The U-boot Second Stage Bootloader source code
#
# Prerequisites:
#   - A toolchain for your target device
#   - A toolchain configuration file: 'env.mk'
#       See the provided 'env.mk' for the required variables to provide
#   - Kernel must be configured manually prior to building (menuconfig)
#   - U-boot must be configured manually prior to building (menuconfig)
#   - Packages must be configured manually prior to building (probably a ./configure script)
#
# Main Targets:
#   make build
#       Build all source code (fsbl, bootloader, kernel, modules, apps, pkgs).
#   make rootfs
#       Generate and populate the root filesystem.
#   make image
#       Assemble final bootable image(s).
#   make clean / make clean_workdir
#       Remove outputs (images, rootfs).
#   make clean_all
#       Remove build directories and outputs (images, rootfs).
#   make info
#       Display all environment variables.
#
#   Other useful targets are available. Inspect the Makefile to learn about them,
#   they should be self-explanatory.
#
# Design Goals:
#   - Deterministic and reproducible builds
#   - Modular component builds
#   - Minimal host contamination
#   - Scalable for CI/CD integration
#
# Notes:
#   - This Makefile assumes a POSIX-compatible host system.
#
# Maintainer: SpaceBaker (emile.forcier@gmail.com)
#
# License: GPLv2
#
###############################################################################

include env.mk
export

ifndef XILUX_ENV
$(warning "Your environment is not set!")
$(error "Please include a valid 'env.mk' file")
endif

override DATETIME		:= $(shell date +%Y%2m%2d-%H%M%S)
# Project directories
TOP_DIR    				:= $(CURDIR)
TOOLS_DIR				:= $(TOP_DIR)/tools
KERNEL_DIR				:= $(TOP_DIR)/kernel
BOOTGEN_DIR				:= $(TOP_DIR)/bootgen
UBOOT_DIR				:= $(TOP_DIR)/u-boot
APPS_DIR 				:= $(TOP_DIR)/apps
MODULES_DIR 			:= $(TOP_DIR)/modules
PKGS_DIR 				:= $(TOP_DIR)/packages
SCRIPT_DIR 				:= $(TOP_DIR)/scripts
# Targets
APPS					:= hello-userspace
MODULES					:= hello-kernel
PKGS					:= busybox
SCRIPTS					:= busybox
# Output/work directories
WORK_DIR				:= $(TOP_DIR)/output
IMG_DIR					:= $(WORK_DIR)/images
ROOTFS_STAGING_DIR		?= $(WORK_DIR)/rootfs_staging_$(DATETIME)
ROOTFS_BASENAME			:= $(notdir $(subst _staging,,$(ROOTFS_STAGING_DIR)))
# Indirect recipe lists
APPS_BUILD		  		 = $(addsuffix .build,$(APPS_DIR)/$(APPS))
APPS_INSTALL	  		 = $(addsuffix .install,$(APPS_DIR)/$(APPS))
APPS_CLEAN		 		 = $(addsuffix .clean,$(APPS_DIR)/$(APPS))
MODULES_BUILD		 	 = $(addsuffix .build,$(MODULES_DIR)/$(MODULES))
MODULES_INSTALL	 		 = $(addsuffix .install,$(MODULES_DIR)/$(MODULES))
MODULES_CLEAN		 	 = $(addsuffix .clean,$(MODULES_DIR)/$(MODULES))
PKGS_BUILD		 	 	 = $(addsuffix .build,$(PKGS_DIR)/$(PKGS))
PKGS_INSTALL	 		 = $(addsuffix .install,$(PKGS_DIR)/$(PKGS))
PKGS_CLEAN		 	 	 = $(addsuffix .clean,$(PKGS_DIR)/$(PKGS))
# Misc
VENDOR					?= xilinx
KERNELRELEASE 			 = $(shell make -sC $(KERNEL_DIR) kernelrelease)
PATH					:= $(PATH):$(TOOLS_DIR)

# Disable parallelism just to correctly display prints
.NOTPARALLEL:

# Main recipes ########################################################
.PHONY: build rootfs image clean clean_all clean_workdir info

build: 	fsbl u-boot kernel kernel_modules modules apps pkgs

rootfs:	build rootfs_prepare rootfs_install rootfs_compress

image: 	rootfs image_prepare image_add_kernel image_add_rootfs \
		image_add_initramfs image_add_bootbin image_add_fit

clean: clean_workdir

clean_all:  clean_pkgs clean_apps clean_modules \
			clean_kernel clean_u-boot clean_workdir

clean_workdir:
	rm -rf $(WORK_DIR)

info:
	@(env -0 | sort -z | tr '\0' '\n')


# External packages recipes ###########################################
.PHONY: pkgs pkgs_install clean_pkgs

pkgs: $(PKGS_BUILD)

pkgs_install: $(PKGS_INSTALL)

clean_pkgs: $(PKGS_CLEAN)


# Xilux apps recipes ##################################################
.PHONY: apps apps_install clean_apps

apps: $(APPS_BUILD)

apps_install: $(APPS_INSTALL)

clean_apps: $(APPS_CLEAN)


# Xilux kernel modules recipes ########################################
.PHONY: modules modules_install clean_modules

modules: $(MODULES_BUILD)

modules_install: $(MODULES_INSTALL)

clean_modules: $(MODULES_CLEAN)


# kernel recipes ######################################################
.PHONY: kernel kernel_modules kernel_modules_install clean_kernel

kernel: $(KERNEL_DIR)/arch/$(ARCH)/boot/Image

$(KERNEL_DIR)/arch/$(ARCH)/boot/Image:
	@boxed_echo.sh "Building 'kernel image'" green
	$(MAKE) -C $(KERNEL_DIR) Image

## TODO: own device tree
$(KERNEL_DIR)/arch/$(ARCH)/boot/dts/$(VENDOR)/%.dtb: $(KERNEL_DIR)/arch/$(ARCH)/boot/dts/$(VENDOR)/%.dts
	$(MAKE) -C $(KERNEL_DIR) dtbs

kernel_modules:
	@boxed_echo.sh "Building 'kernel modules'" green
	$(MAKE) -C $(KERNEL_DIR) modules

kernel_modules_install:
	@boxed_echo.sh "Installing 'kernel modules'" green
	$(MAKE) -C $(KERNEL_DIR) INSTALL_MOD_PATH=$(ROOTFS_STAGING_DIR) modules_install

clean_kernel: $(KERNEL_DIR).clean


# u-boot recipes ######################################################
.PHONY: u-boot clean_u-boot

u-boot: $(UBOOT_DIR)/u-boot.elf

$(UBOOT_DIR)/u-boot.elf: $(UBOOT_DIR)/.config
	@boxed_echo.sh "Building '$*'" green
	$(MAKE) -C u-boot u-boot.elf

clean_u-boot: $(UBOOT_DIR).clean


# fsbl recipes ########################################################
## NOTE : TEMPORARY! This is a static binary.
## 		  When src code will be added, FSBL recipes will need to be modified
.PHONY: fsbl

fsbl: fsbl/build/fsbl.elf

fsbl/build/fsbl.elf:
	@echo "No fsbl.elf detected, please provide one"


# rootfs staging recipes ##############################################
.PHONY: rootfs_prepare rootfs_install rootfs_install_kernel rootfs_install_modules rootfs_install_apps\
		rootfs_install_pkgs rootfs_install_libs rootfs_install_scripts rootfs_compress

rootfs_prepare: $(ROOTFS_STAGING_DIR)

$(ROOTFS_STAGING_DIR):
	@boxed_echo.sh "Creating '$(ROOTFS_STAGING_DIR)' skeleton" green
	mkroot.sh -r $(ROOTFS_STAGING_DIR) -t fhs

rootfs_install: rootfs_install_kmod rootfs_install_modules rootfs_install_apps\
				rootfs_install_pkgs rootfs_install_libs rootfs_install_scripts

rootfs_install_kmod: $(ROOTFS_STAGING_DIR).chkdir kernel_modules_install
	rm -f $(ROOTFS_STAGING_DIR)/lib/modules/$(KERNELRELEASE)/build

rootfs_install_modules: $(ROOTFS_STAGING_DIR).chkdir $(MODULES_INSTALL)

rootfs_install_apps: $(ROOTFS_STAGING_DIR).chkdir $(APPS_INSTALL)

rootfs_install_pkgs: $(ROOTFS_STAGING_DIR).chkdir $(PKGS_INSTALL)

rootfs_install_libs: $(ROOTFS_STAGING_DIR).chkdir
	@boxed_echo.sh "Adding libraries to $(ROOTFS_STAGING_DIR)-populated" green
	$(CROSS_COMPILE)populate -v -s $(ROOTFS_STAGING_DIR) -d $(ROOTFS_STAGING_DIR)-populated

rootfs_install_scripts: $(ROOTFS_STAGING_DIR)-populated.chkdir
	@boxed_echo.sh "Adding '$(SCRIPTS)' scripts to $(ROOTFS_STAGING_DIR)-populated" green
	@for SCR in $(SCRIPTS); do \
		cd $(SCRIPT_DIR); \
		if [ -d $$SCR ]; then cd $$SCR; fi; \
		find . -type f -exec install -Dm 755 "{}" "$(ROOTFS_STAGING_DIR)-populated/{}" \;; \
	done

rootfs_compress: $(WORK_DIR)/$(ROOTFS_BASENAME).tar.gz

# TO CHECK: is '-populated' necessary? crosstool-ng 'populate' tool cannot add libraries to the same dir it reads from...
$(WORK_DIR)/$(ROOTFS_BASENAME).tar.gz: $(ROOTFS_STAGING_DIR)-populated.chkdir
	@boxed_echo.sh "Compressing $(ROOTFS_STAGING_DIR)-populated" green
	tar -czf $(WORK_DIR)/$(ROOTFS_BASENAME).tar.gz -C $(ROOTFS_STAGING_DIR)-populated .

clean_rootfs:
	@boxed_echo.sh "Cleaning rootfs" green
	rm -rf $(WORK_DIR)/rootfs*


# initramfs recipes ###################################################
## TODO: Dedicated initramfs. For now, it is a copy of rootfs
.PHONY: initramfs clean_initramfs

initramfs: $(WORK_DIR)/initramfs.cpio.gz

$(WORK_DIR)/initramfs.cpio.gz: $(ROOTFS_STAGING_DIR)-populated.chkdir
	@boxed_echo.sh "Creating initramfs" green
	mkinitramfs.sh -r $(ROOTFS_STAGING_DIR)-populated -c gzip -o $(WORK_DIR)/initramfs

clean_initramfs:
	@boxed_echo.sh "Cleaning initramfs" green
	rm -f $(WORK_DIR)/initramfs.cpio.gz


# image recipes #######################################################
.PHONY: image_prepare image_prepare_msg image_bootbin image_fit clean_image

image_prepare: image_prepare_msg clean_image $(IMG_DIR)

image_prepare_msg:
	@boxed_echo.sh "Preparing images" green

$(IMG_DIR):
	mkdir -p $(IMG_DIR)

image_add_kernel: kernel
	gzip -k --best -c $(KERNEL_DIR)/arch/$(ARCH)/boot/Image > $(IMG_DIR)/Image.gz

image_add_rootfs: rootfs_compress
	mv $(WORK_DIR)/$(ROOTFS_BASENAME).tar.gz $(IMG_DIR)

image_add_initramfs: initramfs
	mv $(WORK_DIR)/initramfs.cpio.gz $(IMG_DIR)

image_add_bootbin: $(IMG_DIR)/boot.bin

$(IMG_DIR)/boot.bin: $(BOOTGEN_DIR)/uboot.bif u-boot fsbl
	bootgen -arch zynq -image $< -w -o $@

image_add_fit: $(IMG_DIR)/xilux.itb

## TODO: own device tree
$(IMG_DIR)/xilux.itb: $(KERNEL_DIR)/arch/$(ARCH)/boot/dts/$(VENDOR)/zynq-zc706.dtb $(KERNEL_DIR)/arch/$(ARCH)/boot/dts/$(VENDOR)/zynq-zc702.dtb devicetree/xilux.its
	cp $(KERNEL_DIR)/arch/$(ARCH)/boot/dts/$(VENDOR)/zynq-zc706.dtb $(KERNEL_DIR)/arch/$(ARCH)/boot/dts/$(VENDOR)/zynq-zc702.dtb $(IMG_DIR)
	cp devicetree/xilux.its $(IMG_DIR)
	mkimage -q -f $(IMG_DIR)/xilux.its $@
	@rm $(IMG_DIR)/xilux.its

clean_image:
	@boxed_echo.sh "Cleaning images" green
	rm -rf $(IMG_DIR)


# Generic recipes ####################################################
.PHONY:  %.build %.install %.clean %.chkdir

%.build:
	@boxed_echo.sh "Building '$*'" green
	$(MAKE) -C $*

%.install:
	@boxed_echo.sh "Installing '$*' into $(ROOTFS_STAGING_DIR)" green
	$(MAKE) -C $* install\
		DESTDIR=$(ROOTFS_STAGING_DIR)\
		CONFIG_PREFIX=$(ROOTFS_STAGING_DIR)

%.clean:
	@boxed_echo.sh "Cleaning '$*'" green
	$(MAKE) -C $* clean

%.chkdir:
	@if test ! -d $*; then \
		echo "'$*' directory does not exists."; \
		false; \
	fi
