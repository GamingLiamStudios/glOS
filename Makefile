SHELL = /bin/sh
ifeq ($(OS),Windows_NT)
	LD=x86_64-elf-ld
	GCC=x86_64-elf-gcc
else
	LD=ld
	GCC=gcc
endif

CFLAGS=-std=c99 -ffreestanding -m64 -Isource -O2 -c
LDFLAGS=-T"link.ld" -nostdlib
NFLAGS=-f elf64

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

C_SOURCES = $(call rwildcard,source,*.c)
HEADERS = $(call rwildcard,source,*.h)
OBJ = ${C_SOURCES:%.c=build/%.o}
DIRS = $(sort $(dir ${OBJ}))

.PHONY: dirs build clean all

all: build
build: dirs build/boot.bin

# Compile Bootloader & append Kernel
build/boot.bin: source/bootloader.asm
	@nasm $< -f bin -o $@

#dirs:
#	@mkdir -p ${DIRS}

clean:
	@rm -r build/*.* build/source