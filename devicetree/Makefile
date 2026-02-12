DTC ?= dtc
CPP ?= cpp
DTS_FILES := $(shell find $(CURDIR) -name '*.dts')
DTB_FILES := $(DTS_FILES:.dts=.dtb)

CPPFLAGS := -nostdinc -Iinclude -undef -D__DTS__ -x assembler-with-cpp

test:
	@echo "DTS_FILES=$(DTS_FILES)"
	@echo "DTB_FILES=$(DTB_FILES)"

# Target
all: $(DTB_FILES)

# Compile using the temporal file as input
%.dtb: %.dts.tmp
	dtc -O dtb -o $@ -b 0 -d $*.dep.tmp $<
	rm -rf *.tmp

# Generate temporal file using the C preprocessor
%.dts.tmp:
	$(CPP) -Wp,-MD,$*.dep.tmp $(CPPFLAGS) -o $@ $*.dts

# Clean dtb
clean:
	rm -rf *.dtb

.PHONY: all clean clean_tmp test
