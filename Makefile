SHELL = /bin/sh
CFLAGS=-std=c99 -m64 -ffreestanding -mno-red-zone -Ttext 0x8000
LDFLAGS=-nostdlib -nodefaultlibs -Ttext 0x8000

build: prebuild build/boot.bin clean
	
prebuild:
	rm -f build/*

# Compile Bootloader
build/boot.bin: source/bootloader/bootloader.asm
	nasm $^ -f bin -o $@

clean:
	rm -f build/*.o; rm -f build/*.tmp; rm -f build/kernel.bin
