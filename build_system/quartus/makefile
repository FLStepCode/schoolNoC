TOPLEVEL ?= toplevel
VARS_TCL_PATH := .cache/quartus/$(TOPLEVEL)/vars.tcl
FILES_RTL_PATH := $(CURDIR)/rtl/lists/files_rtl.lst

.PHONY: compile clean clean_all

compile: .cache/quartus/$(TOPLEVEL)/NoC.qpf

.cache/quartus/$(TOPLEVEL)/NoC.qpf: $(shell find rtl -type f | tr '\n' ' ')
	mkdir -p .cache/quartus/$(TOPLEVEL); \
	cp build_system/quartus/Setup_sh.tcl .cache/quartus/; \
	cp build_system/quartus/custom_assignments.tcl .cache/quartus/; \

	@echo set TOPLEVEL $(TOPLEVEL) > $(VARS_TCL_PATH)
	@echo set FILES_RTL_PATH $(FILES_RTL_PATH) >> $(VARS_TCL_PATH)

	cd .cache/quartus/$(TOPLEVEL); \
	quartus_sh -t ../Setup_sh.tcl

clean:
	rm -rf .cache/quartus/$(TOPLEVEL)

clean_all:
	rm -rf .cache/quartus