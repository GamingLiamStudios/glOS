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
OBJ = ${C_SOURCES:.c=.o}

all: build

build: build/boot.bin

# Compile Bootloader
build/boot.bin: source/boot/bootloader.asm build/kernel.bin
	nasm $< -f bin -o $@; dd if=build/kernel.bin of=$@ status=none conv=notrunc oflag=append

build/kernel.bin: build/kernel.tmp
	objcopy -O binary $< $@; rm -f build/kernel.tmp
build/kernel.tmp: build/entry.o ${OBJ}
	ld -o $@ $(LDFLAGS) $^; rm -f $^

build/entry.o: source/kernel/entry.asm
	nasm $< $(NFLAGS) -o $@
%.o: %.c $(HEADERS)
	gcc $(CFLAGS) $< -o $@

clean:
	rm -f build/*