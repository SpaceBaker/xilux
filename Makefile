ifndef KERNEL_DIR
$(warning "Your environment is not set!")
$(error "Please source 'scripts/setup_env.sh'")
endif

TOP_DIR					:= $(CURDIR)
override DATETIME		:= $(shell date +%Y%2m%2d-%H%M%S)
APPS_SUBDIRS 			:= $(patsubst %/,%,$(dir $(wildcard apps/*/Makefile)))
APPS_BUILD		  		 = $(addsuffix .build,$(APPS_SUBDIRS))
APPS_INSTALL	  		 = $(addsuffix .install,$(APPS_SUBDIRS))
APPS_CLEAN		 		 = $(addsuffix .clean,$(APPS_SUBDIRS))
MODULES_SUBDIRS 		:= $(patsubst %/,%,$(dir $(wildcard modules/*/Makefile)))
MODULES_BUILD		 	 = $(addsuffix .build,$(MODULES_SUBDIRS))
MODULES_INSTALL	 		 = $(addsuffix .install,$(MODULES_SUBDIRS))
MODULES_CLEAN		 	 = $(addsuffix .clean,$(MODULES_SUBDIRS))
BOOTGEN_DIR				:= $(TOP_DIR)/bootgen
UBOOT_DIR				:= $(TOP_DIR)/u-boot
WORK_DIR				:= $(TOP_DIR)/output
IMG_DIR					:= $(WORK_DIR)/images
ROOTFS_STAGING_DIR		?= $(WORK_DIR)/rootfs_staging_$(DATETIME)
ROOTFS_BASENAME			:= $(notdir $(subst _staging,,$(ROOTFS_STAGING_DIR)))
VENDOR					?= xilinx
KERNELRELEASE 			 = $(shell make -sC $(KERNEL_DIR) kernelrelease)

# Disable parallelism just to correctly display prints
.NOTPARALLEL:

# Main recipes ########################################################
.PHONY: build rootfs image clean clean_all clean_workdir info test

test:
	@echo $($(MAKE) -C $(KERNEL_DIR) kernelrelease)

build: 	fsbl u-boot kernel kernel_modules modules apps

rootfs:	build rootfs_prepare rootfs_install rootfs_compress

image: 	rootfs image_prepare image_add_kernel image_add_rootfs \
		image_add_initramfs image_add_bootbin image_add_fit

clean: clean_workdir

clean_all:  clean_apps clean_modules clean_kernel \
			clean_u-boot clean_workdir

clean_workdir:
	rm -rf $(WORK_DIR)

info:
	@printf "TOP_DIR\033[20G= $(TOP_DIR)\n"
	@printf "DATETIME\033[20G= $(DATETIME)\n"
	@printf "APPS_SUBDIRS\033[20G= $(APPS_SUBDIRS)\n"
	@printf "APPS_BUILD\033[20G= $(APPS_BUILD)\n"
	@printf "APPS_INSTALL\033[20G= $(APPS_INSTALL)\n"
	@printf "APPS_CLEAN\033[20G= $(APPS_CLEAN)\n"
	@printf "MODULES_SUBDIRS\033[20G= $(MODULES_SUBDIRS)\n"
	@printf "MODULES_BUILD\033[20G= $(MODULES_BUILD)\n"
	@printf "MODULES_INSTALL\033[20G= $(MODULES_INSTALL)\n"
	@printf "MODULES_CLEAN\033[20G= $(MODULES_CLEAN)\n"
	@printf "BOOTGEN_DIR\033[20G= $(BOOTGEN_DIR)\n"
	@printf "UBOOT_DIR\033[20G= $(UBOOT_DIR)\n"
	@printf "WORK_DIR\033[20G= $(WORK_DIR)\n"
	@printf "IMG_DIR\033[20G= $(IMG_DIR)\n"
	@printf "ROOTFS_STAGING_DIR\033[20G= $(ROOTFS_STAGING_DIR)\n"
	@printf "ROOTFS_BASENAME\033[20G= $(ROOTFS_BASENAME)\n"


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
		rootfs_install_extra rootfs_install_libs rootfs_kernel_build_cleanup rootfs_compress

rootfs_prepare: $(ROOTFS_STAGING_DIR)

$(ROOTFS_STAGING_DIR):
	@boxed_echo.sh "Creating '$(ROOTFS_STAGING_DIR)' skeleton" green
	mkroot.sh -r $(ROOTFS_STAGING_DIR) -t fhs

rootfs_install: rootfs_install_kmod rootfs_install_modules rootfs_install_apps\
				rootfs_install_extra rootfs_install_libs

rootfs_install_kmod: $(ROOTFS_STAGING_DIR).chkdir kernel_modules_install
	rm -f $(ROOTFS_STAGING_DIR)/lib/modules/$(KERNELRELEASE)/build

rootfs_install_modules: $(ROOTFS_STAGING_DIR).chkdir $(MODULES_INSTALL)

rootfs_install_apps: $(ROOTFS_STAGING_DIR).chkdir $(APPS_INSTALL)

# TODO: add a better recipe for 'extra'
# Can be modified
rootfs_install_extra: $(ROOTFS_STAGING_DIR).chkdir
	@boxed_echo.sh "Installing 'busybox' into $(ROOTFS_STAGING_DIR)" green
	$(MAKE) -C $(SRC_DIR)/busybox CONFIG_PREFIX=$(ROOTFS_STAGING_DIR) install
	cp -r $(SCRIPT_DIR)/busybox_init/* $(ROOTFS_STAGING_DIR)

rootfs_install_libs: $(ROOTFS_STAGING_DIR).chkdir
	@boxed_echo.sh "Adding libraries to $(ROOTFS_STAGING_DIR)-populated" green
	$(CROSS_COMPILE)populate -v -s $(ROOTFS_STAGING_DIR) -d $(ROOTFS_STAGING_DIR)-populated

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
## TODO : need to find a better way to create images
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
	$(MAKE) -C $* install DESTDIR=$(ROOTFS_STAGING_DIR)

%.clean:
	@boxed_echo.sh "Cleaning '$*'" green
	$(MAKE) -C $* clean

%.chkdir:
	@if test ! -d $*; then \
		echo "'$*' directory does not exists."; \
		false; \
	fi
