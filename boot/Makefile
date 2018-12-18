#----------------------------------------------------------------------------
# Makefile for the boot loaders
#----------------------------------------------------------------------------
DIR_ROOT		:=	..
include $(DIR_ROOT)/mk/config.mk

DIR_TARGET		:=	$(DIR_BUILD)/boot
DIR_DEPS 		:=	$(DIR_DEPS)/boot
ASFLAGS 		:=	-f bin

ASM_FILES		:=	$(wildcard *.asm)
BIN_FILES		:=	$(ASM_FILES:%.asm=$(DIR_TARGET)/%.bin)
DEP_FILES 		:=	$(ASM_FILES:%.asm=$(DIR_DEPS)/%.d)

TAG 			:= $(BLUE)[boot]$(NORMAL)

all: mkdir $(BIN_FILES)
	@echo "$(TAG) $(SUCCESS)"

mkdir:
	@mkdir -p $(DIR_TARGET) $(DIR_DEPS)

clean:
	@rm -f $(BIN_FILES)

$(BIN_FILES): $(DIR_TARGET)/%.bin: %.asm
	@echo "$(TAG) Assembling $<"
	@$(AS) $(ASFLAGS) $< -o $@

$(DEP_FILES): $(DIR_DEPS)/%.d: %.asm | mkdir
	@echo "$(TAG) Generating dependencies for $<"
	@set -e; \
	  rm -f $@; \
	  $(AS) -M $(ASFLAGS) $< -MT @@@ > $@.$$$$; \
	  sed 's,@@@[ :]*,$(DIR_BUILD)/$*.bin $@ : ,g' < $@.$$$$ > $@; \
	  rm -f $@.$$$$

.force:

-include $(DEP_FILES)