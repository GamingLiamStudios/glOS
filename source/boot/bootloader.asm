[bits 16]
org 0x7c00

_entry_point: ; Bootloader
    mov [BOOT_DRIVE], dl ; Store current disk

    ; Enable A20 Line
    ; TODO: Implement better version
    in al, 0x92
    or al, 2
    out 0x92, al

    ; Initalize Stack
    mov bp, 0xc000
    mov sp, bp 

    ; Read 32 sectors infront of boot sector
    mov dh, 32
    mov bx, KERNEL_OFFSET
    mov dl, [BOOT_DRIVE]
    call disk_read

    ; Set VGA text mode 3
    mov ax, 0x3
    int 0x10

    ; Disable interupts    
    cli

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

KERNEL_OFFSET equ 0x7e00

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

    ; Clear VGA Memory
    mov edi, 0xb8000
    mov eax, 0x1f201f20
    mov ecx, 1000
    rep stosd

    ; Detect CPUID
    pushfd
    pop eax

    mov eax, ecx
    xor eax, 1 << 21
    push eax
    popfd

    pushfd
    pop eax

    push ecx
    popfd
    xor eax, ecx
    jnz KERNEL_OFFSET

    ; Print error message
    mov esi, cpuid_err
    mov cx, 19
    mov edi, 0xb8000
    cld
    rep movsw
    hlt

    jmp $

cpuid_err: ; 'CPUID not Supported'
    dw 0x1f43, 0x1f50, 0x1f55, 0x1f49, 0x1f44, 0x1f20, 0x1f6e, 0x1f6f, 0x1f74, 0x1f20, 0x1f53, 0x1f75, 0x1f70, 0x1f70, 0x1f6f, 0x1f72, 0x1f74, 0x1f65, 0x1f64
    
times 510 - ($ - $$) db 0 ; pad rest of bootsector
dw 0xaa55 ; Bootloader Identifier