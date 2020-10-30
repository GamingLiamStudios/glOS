[bits 16]
org 0x7c00

_entry_point: ; Bootloader
    mov [BOOT_DRIVE], dl ; Store current disk

    ; Initalize Stack
    mov bp, 0x8000 
    mov sp, bp 

    ; Read 15 sectors infront of boot sector
    mov dh, 15
    mov bx, KERNEL_OFFSET
    mov dl, [BOOT_DRIVE]
    call disk_read

    ; Set VGA text mode 3
    mov ax, 0x3
    int 0x10

    ; Disable interupts    
    cli

    ; Enable A20 Line
    ; TODO: Implement better version
    in al, 0x92
    or al, 2
    out 0x92, al

    ; Put CPU in 32-bit protected mode
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

%include "source/boot/gdt.asm"

BOOT_DRIVE: db 0

KERNEL_OFFSET equ 0x1000

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

    ; Enter kernel
    call KERNEL_OFFSET

    jmp $

times 510 - ($ - $$) db 0 ; pad rest of bootsector
dw 0xaa55 ; Bootloader Identifier