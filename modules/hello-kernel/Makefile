ifndef KERNEL_DIR
$(warning "Your environment is not set!)
$(error "Please source 'scripts/setup_env.sh'")
endif

DESTDIR ?= "$(TOP_DIR)/rootfs_staging"
INSTALL_MOD_DIR  ?= test

obj-m += hello-kernel.o

.PHONY: build install clean

build:
	$(MAKE) -C $(KERNEL_DIR) M=$(CURDIR) modules

install:
	$(MAKE) -C $(KERNEL_DIR) M=$(CURDIR) INSTALL_MOD_PATH=$(DESTDIR) INSTALL_MOD_DIR=$(INSTALL_MOD_DIR) modules_install

clean:
	$(MAKE) -C $(KERNEL_DIR) M=$(CURDIR) clean