@echo off
"C:\Program Files\NASM\nasm.exe" bootloader.asm -f bin -o boot.bin
"C:/Program Files/qemu/qemu-system-x86_64.exe" boot.bin
