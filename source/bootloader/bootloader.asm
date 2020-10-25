[bits 16]
org 0x7c00

_entry_point: ; Bootloader
    mov [BOOT_DRIVE], dl ; Store current disk

    ; Initalize Stack
    mov bp, 0x8000 
    mov sp, bp 

    ;mov dh, 4      ; Attempt to read 4 sectors from disk
    ;mov bx, 0x7e00 ; into address 0x7E00, just after the bootsector
    ;mov dl, [BOOT_DRIVE] ; Set read drive to BOOT_DRIVE
    ;call disk_read

    ; Put CPU in 32-bit protected mode
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp codeseg:_entry_point_pm

    jmp $

disk_read:
    mov ah, 0x02 ; Read Sector Function
    mov al, dh ; Read dh sectors

    ; Index
    mov ch, 0  ; Cylinder 0
    mov dh, 0  ; Head     0
    mov cl, 2  ; Sector   2

    int 0x13 ; Call Sector Function. Sets carry flag if error occurs
    jnc .end ; Jump to end if carry flag is not set

    ; An error occured. Print an error message
    .str:
        db 'Disk Read Error', 0
    mov ah, 0x0e ; Write Char Function
    mov si, .str ; Store address of string in si
    mov al, [si] ; Move value of si to al
    .loop:
        int 0x10 ; Print char
        inc si ; Increment address of si
        mov al, [si] ; Move value of si to al
        or al, al ; Check for null termination
        jnz .loop

    .end:
    ret

%include "source/bootloader/gdt.asm"

BOOT_DRIVE: db 0

[bits 32]
_entry_point_pm:
    ; Init
    mov ax, dataseg
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ebp, 0x90000
    mov esp, ebp

    mov al, 'X'
    mov ah, 0x0f
    mov [0xb8000], ax

    jmp $

times 510 - ($ - $$) db 0 ; pad rest of bootsector
dw 0xaa55 ; Bootloader Identifier