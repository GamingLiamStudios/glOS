print: ; Print a null-terminated string stored in si
    mov ah, 0x0E ; Init
    .loop:
        mov al, [si] ; Move value of si to al
        int 0x10 ; Print char
        inc si ; Increment address of si
        or al, al ; Check for null termination
        jnz .loop
    ret

disk_read:
    mov ah, 0x02 ; Init

    ; Read info
    mov bx, PROGRAM_SPACE ; Memory for data
    mov dl, [BOOT_DISK] ; Disk
    mov al, 4 ; Length in sectors

    ; Index
    mov ch, 0 ; Cylinder
    mov dh, 0 ; Head
    mov cl, 2 ; Sector

    ; Read Data
    int 0x13
    jnc .end ; Error checking

    ; Error has occured
    .str:
        db 'Disk Read Failed' , 0
    mov si, .str
    call print

    .end:
    ret

PROGRAM_SPACE equ 0x7E00

BOOT_DISK
    db 0