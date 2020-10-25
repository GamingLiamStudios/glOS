[bits 16]
org 0x7c00

_entry_point: ; Bootloader
    jmp $

times 510 - ($ - $$) db 0 ; Fill rest of sector
dw 0xaa55 ; Bootloader Identifier