[org 0x7c00]
    xor ax, ax ; make it zero
    mov ds, ax
    cld

    mov si, msg
    call print_str
hang:
    jmp hang

print_str:
    lodsb
    or al, al  ; Check for null-teminator
    jz .exit
    mov ah, 0x0E
    mov bh, 0
    int 0x10
    jmp print_str
.exit:
    ret

msg: db 'Hello World!', 0

times 510 - ($ - $$) db 0 ; Ensures that the boot-sector doesn't go over 512 bytes
dw 0xAA55 ; This tells the BIOS that is the boot sector