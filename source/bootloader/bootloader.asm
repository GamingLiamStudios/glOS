[ORG 0x7c00]

main: ; Bootloader
    ; Init
    mov [BOOT_DISK], dl
    mov bp, 0x7c00
    mov sp, bp

    ; Hello World
    .str:
        db 'Hello World!' , 0
    mov si, .str
    call print

    ; Read Data
    call disk_read
    jmp PROGRAM_SPACE

    jmp $

%include "source/bootloader/io.asm"

times 510 - ($ - $$) db 0 ; Fill rest of sector
dw 0xaa55 ; Bootloader Identifier