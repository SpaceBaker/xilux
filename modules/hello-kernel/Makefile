ifndef KERNEL_DIR
$(warning "No kernel directory set")
$(error "Please provide a path to your kernel source code (defined in top-level Makefile)")
endif

DESTDIR ?= $(CURDIR)/_install
INSTALL_MOD_DIR  ?= test

obj-m += hello-kernel.o

.PHONY: build install clean

build:
	$(MAKE) -C $(KERNEL_DIR) M=$(CURDIR) modules

install:
	$(MAKE) -C $(KERNEL_DIR) M=$(CURDIR) INSTALL_MOD_PATH=$(DESTDIR) INSTALL_MOD_DIR=$(INSTALL_MOD_DIR) modules_install

clean:
	$(MAKE) -C $(KERNEL_DIR) M=$(CURDIR) clean