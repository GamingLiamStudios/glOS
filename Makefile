SHELL = /bin/sh
CFLAGS=-std=c99 -Ttext 0x7e00 -ffreestanding -m64 -Isource -O2 -c
LDFLAGS=-T"link.ld" -nostdlib
NFLAGS=-f
ifeq ($(OS),Windows_NT)
	NFLAGS += win64
	LDFLAGS += -mi386pep
else
	NFLAGS += elf64
	LDFLAGS += -melf_x86_64
endif

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

C_SOURCES = $(call rwildcard,source,*.c)
HEADERS = $(call rwildcard,source,*.h)
OBJ = ${C_SOURCES:%.c=build/%.o}
DIRS = $(sort $(dir ${OBJ}))

all: build

build: dirs build/boot.bin

# Compile Bootloader & append Kernel
build/boot.bin: source/boot/bootloader.asm build/kernel.bin
	@echo Combining...
	@nasm $< -f bin -o $@ \
	 && dd if=build/kernel.bin of=$@ status=none conv=notrunc oflag=append \
	 && rm build/kernel.bin

# Link Kernel
build/kernel.bin: build/kernel.o
	@echo Linking $@
	@objcopy -O binary $< $@
build/kernel.o: build/source/kernel/entry.o ${OBJ}
	@ld -o $@ $(LDFLAGS) $^

# Compile Kernel
build/source/kernel/entry.o: source/kernel/entry.asm
	@echo Compiling $<
	@nasm $< $(NFLAGS) -o $@
build/%.o: %.c $(HEADERS)
	@echo Compiling $<
	@gcc $(CFLAGS) $< -o $@

dirs:
	@mkdir -p ${DIRS}

.PHONY: clean
clean:
	@rm -r build/*.* build/source