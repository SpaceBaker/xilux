ifndef KERNEL_DIR
$(warning "Your environment is not set!)
$(error "Please source 'scripts/setup_env.sh'")
endif


obj-m += hello-kernel.o


all:
	$(MAKE) -C ${KERNEL_DIR} M=$(PWD) modules

clean:
	$(MAKE) -C ${KERNEL_DIR} M=$(PWD) clean