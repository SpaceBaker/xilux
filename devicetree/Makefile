ifndef KERNEL_DIR
$(warning "No kernel directory set")
$(error "Please provide a path to your kernel source code (defined in top-level Makefile)")
endif

DTC ?= dtc
CPP ?= cpp
DTS_FILES := $(shell find $(CURDIR) -name '*.dts')
DTB_FILES := $(DTS_FILES:.dts=.dtb)

CPPFLAGS := -nostdinc -Iinclude -I$(KERNEL_DIR)/include -undef -D__DTS__ -x assembler-with-cpp

# Target
all: $(DTB_FILES)

# Compile using the temporal file as input
%.dtb: %.dts.tmp
	dtc -O dtb -o $@ -b 0 -d $*.dep.tmp $<
	rm -rf *.tmp

# Generate temporal file using the C preprocessor
%.dts.tmp: %.dts
	$(CPP) -Wp,-MD,$*.dep.tmp $(CPPFLAGS) -o $@ $*.dts

# Clean dtb
clean:
	rm -rf *.dtb

.PHONY: all clean
