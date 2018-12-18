#==============================================================================
# Makefile shared configuration settings
#==============================================================================

#------------------------------------------------------------------------------
# Project directories
#------------------------------------------------------------------------------
DIR_BOOT		:=	$(DIR_ROOT)/boot
DIR_BUILD		:=	$(DIR_ROOT)/build
DIR_DEPS		:=	$(DIR_ROOT)/deps
DIR_INCLUDE		:=	$(DIR_ROOT)/include
DIR_KERNEL		:=	$(DIR_ROOT)/kernel
DIR_LIBC		:=	$(DIR_ROOT)/libc

#------------------------------------------------------------------------------
# Tools
#------------------------------------------------------------------------------
TARGET			:=	i386-elf
AS				:=	nasm

AR				:=	$(TARGET)-ar
CC				:=	$(TARGET)-gcc
LD				:=	$(TARGET)-ld
NM				:=	$(TARGET)-nm
OBJCOPY			:=	$(TARGET)-objcopy
OBJDUMP			:=	$(TARGET)-objdump
RANLIB			:=	$(TARGET)-ranlib
STRIP			:=	$(TARGET)-strip

#------------------------------------------------------------------------------
# Tool configuration
#------------------------------------------------------------------------------
ASFLAGS			:=	-f elf

CCFLAGS			:=	-std=gnu11 -I$(DIR_INCLUDE) -Qn -g \
					-mno-red-zone -mno-mmx -msse2 -masm=intel \
					-ffreestanding -fno-asynchronous-unwind-tables \
					-Wall -Wextra -Wpedantic

CTAGS			:=	ctags

LDFLAGS			:=	-g -nostdlib -mno-red-zone -ffreestanding -lgcc -z \
					max-page-size=0x1000

MAKEFLAGS		+=	--quiet --no-print-directory
MAKE			+=	--quiet --no-print-directory

QEMU32			:=	qemu-system-i386
QEMU64			:=	qemu-system-x86_64

#------------------------------------------------------------------------------
# Display color macros
#------------------------------------------------------------------------------
BLUE			:=	\033[1;34m
YELLOW			:=	\033[1;33m
NORMAL			:=	\033[0m

SUCCESS			:=	$(YELLOW)SUCCESS$(NORMAL)