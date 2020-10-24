[bits 16]
[ORG 0x7c00]

_entry_point: ; Bootloader
    ; Init
    mov [BOOT_DISK], dl
    mov bp, 0x9000 
    mov sp, bp
    call disk_read ; Load Kernel into mem

    mov ah, 0x0E ; Init
    mov al, 'X'
    int 0x10 ; Print char

    ; Enable A20
    in al, 0x92
    or al, 2
    out 0x92, al

    cli ; Disable interupts
    lgdt [gdt_descriptor] ; gdt

    ; Switch to 32-bit
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    jmp codeseg:_start_pm

    jmp $

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
    .error:
        db 'Disk Read Failed' , 0
    ; Print string
    mov si, .error
    mov ah, 0x0e ; Init
    .loop:
        mov al, [si] ; Move value of si to al
        int 0x10 ; Print char
        inc si ; Increment address of si
        or al, al ; Check for null termination
        jnz .loop

    .end:
    ret

PROGRAM_SPACE equ 0x7e00

BOOT_DISK:
    db 0

%include "source/bootloader/gdt.asm"

[bits 32]

_start_pm:
    mov ax, dataseg
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ebp, 0x90000
    mov esp, ebp

    jmp PROGRAM_SPACE

times 510 - ($ - $$) db 0 ; Fill rest of sector
dw 0xaa55 ; Bootloader Identifier