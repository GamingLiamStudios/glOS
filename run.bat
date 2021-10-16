@echo off

make build && start cmd.exe /k qemu-system-i386 -hda build/boot.bin