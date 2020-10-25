SHELL = /bin/sh
CFLAGS=-std=c99 -m64 -ffreestanding -mno-red-zone -Ttext 0x8000
LDFLAGS=-nostdlib -nodefaultlibs -Ttext 0x8000

build: prebuild build/ak.o build/kernel.o build/kernel.tmp build/kernel.bin build/boot.bin clean
	
prebuild:
	rm -f build/*

# Compile Kernel
build/ak.o: source/kernel/kernel.asm
	nasm $^ -f elf64 -o $@
build/kernel.o: source/kernel/*.c
	cc -c $(CFLAGS) $^ -o $@
build/kernel.tmp: build/ak.o build/kernel.o
	ld $(LDFLAGS) -o $@ $^
build/kernel.bin: build/kernel.tmp
	objcopy -O binary $^ $@

# Compile Bootloader
build/boot.bin: source/bootloader/bootloader.asm
	nasm $^ -f bin -o $@; dd if=build/kernel.bin of=$@ status=none conv=notrunc oflag=append

clean:
	rm -f build/*.o; rm -f build/*.tmp; rm -f build/kernel.bin
