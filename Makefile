SHELL = /bin/sh
CFLAGS=-std=c99 -ffreestanding -m64 -Isource -O2 -c
LDFLAGS=-Ttext 0x7e00
NFLAGS=-f
ifeq ($(OS),Windows_NT)
	NFLAGS += win64
	LDFLAGS += -mi386pep
else
	NFLAGS += elf64
	LDFLAGS += -melf_x86_64
endif

C_SOURCES = $(wildcard source/kernel/*.c source/drivers/*.c)
HEADERS = $(wildcard source/kernel/*.h source/drivers/*.h)
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