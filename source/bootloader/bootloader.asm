[ORG 0x7C00]

main:
    ; Init
    mov [BOOT_DISK], dl

    ; Hello World
    .str:
        db 'Hello World!' , 0
    mov si, .str
    call print

    ; Read Data
    call disk_read
    mov si, PROGRAM_SPACE
    call print

    jmp $

%include "source/bootloader/io.asm"

times 510 - ($ - $$) db 0 ; Fill rest of sector
dw 0xAA55 ; Bootloader Identifier