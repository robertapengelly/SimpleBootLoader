#==============================================================================
# Root makefile for project
#==============================================================================
DIR_ROOT		:=	.
include $(DIR_ROOT)/mk/config.mk

#------------------------------------------------------------------------------
# Recursively find files from the current working directory that
# match param1.
#------------------------------------------------------------------------------
findfiles	=	$(patsubst ./%, %, $(shell find . -name $(1)))

default: all

all: iso
	@echo "Root makefile"
	@echo $(SRC)

boot: .force
	@$(MAKE) --directory=$(DIR_BOOT)

kernel: .force libc
	@$(MAKE) --directory=$(DIR_KERNEL)

libc: .force
	@$(MAKE) --directory=$(DIR_LIBC)

#------------------------------------------------------------------------------
# Build images
#------------------------------------------------------------------------------
iso: boot
	@mkdir -p $(DIR_BUILD)/iso/boot
	@cp $(DIR_BUILD)/boot/isoboot.bin $(DIR_BUILD)/iso/boot
	@mkisofs -b boot/isoboot.bin -c boot/boot.cat \
	  -no-emul-boot -boot-load-size 4 -boot-info-table \
	  -input-charset iso8859-1 -o test.iso $(DIR_BUILD)/iso

#------------------------------------------------------------------------------
# Clean targets
#------------------------------------------------------------------------------
clean:
	@rm -rf $(DIR_BUILD)
	@echo "$(BLUE)[clean]$(NORMAL) Generated files deleted"

clean-deps:
	@rm -rf $(DIR_DEPS)
	@echo "$(BLUE)[clean]$(NORMAL) Dependency files deleted"

clean-images:
	@rm -rf *.iso
	@echo "$(BLUE)[clean]$(NORMAL) Image files deleted"

clean-incs:
	@rm -rf $(DIR_INCLUDE)
	@echo "$(BLUE)[clean]$(NORMAL) Include files deleted"

cleanall: clean clean-deps clean-images clean-incs

#------------------------------------------------------------------------------
# Test targets
#------------------------------------------------------------------------------
test32: iso
	@$(foreach file, $(call findfiles, '*.iso'), \
	  $(shell $(QEMU32) -cdrom $(file) -m 4M -boot d))

.force: