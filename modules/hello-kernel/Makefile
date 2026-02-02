ifndef KERNEL_DIR
$(warning "Your environment is not set!)
$(error "Please source 'scripts/setup_env.sh'")
endif

INSTALL_MOD_PATH ?= "${TOP_DIR}/rootfs_staging"
INSTALL_MOD_DIR  = "test"

obj-m += hello-kernel.o


all:
	$(MAKE) -C ${KERNEL_DIR} M=$(PWD) modules

install:
	$(MAKE) -C ${KERNEL_DIR} M=$(PWD) INSTALL_MOD_PATH=${INSTALL_MOD_PATH} INSTALL_MOD_DIR=${INSTALL_MOD_DIR} modules_install

clean:
	$(MAKE) -C ${KERNEL_DIR} M=$(PWD) clean