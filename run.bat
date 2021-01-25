@echo off

make build && start cmd.exe /k "C:/Program Files/qemu/qemu-system-x86_64.exe" build/boot.bin -no-reboot -no-shutdown -d cpu_reset,int