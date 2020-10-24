@echo off
:: Compile asm files
nasm source/bootloader/bootloader.asm -f bin -o build/boot.bin
nasm source/kernel/kernel.asm -f bin -o build/kernel.bin

:: Combine compiled files
cd build
copy /b boot.bin+kernel.bin boot.bin

:: Run bootloader in qemu
"C:/Program Files/qemu/qemu-system-x86_64.exe" boot.bin