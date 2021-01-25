[bits 16]
org 0x7c00

_entry_point: ; Bootloader
    mov [BOOT_DRIVE], dl ; Store current disk

    ; Attempt to set A20 Bit using BIOS
    mov     ax,2403h
    int     15h
    jb      .after
    cmp     ah,0
    jnz     .after
 
    mov     ax,2402h
    int     15h
    jb      bperr
    cmp     ah,0
    jnz     bperr
 
    cmp     al,1
    jz      .after
 
    mov     ax,2401h
    int     15h
    jb      bperr
    cmp     ah,0
    jnz     bperr

    .after:
    ; Initalize Stack
    mov bp, 0xf000
    mov sp, bp 

    ; Read 25 sectors infront of boot sector
    mov dh, 25
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
        db 'Disk Error', 0
    mov si, .str ; Store address of string in si
    jmp bperr

    .end:
    ret

bperr:
    mov ah, 0x0e ; Write Char Function
    mov al, [si] ; Move value of si to al
    .loop:
        int 0x10 ; Print char
        inc si ; Increment address of si
        mov al, [si] ; Move value of si to al
        or al, al ; Check for null termination
        jnz .loop
    hlt

%include "source/boot/gdt.asm"

BOOT_DRIVE: db 0

KERNEL_OFFSET equ 0x7e00

[bits 32]

detect_a20:   
    pushad
    mov edi,0x112345
    mov esi,0x012345
    mov [esi],esi
    mov [edi],edi
    cmpsd
    popad
    ret

_entry_point_pm:
    ; Init
    mov ax, dataseg
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ebp, 0xf0000
    mov esp, ebp

    ; Enable A20 Line
    mov esi, a20_err ; Load Relevent Error Message

    ; First, check if already enabled
    call detect_a20
    jne .a20enabled

    ; Try Fast A20
    in al, 0x92
    or al, 2
    out 0x92, al

    ; Check if Fast A20 Worked
    call detect_a20
    je perr

    .a20enabled:
    ; Clear VGA Memory
    mov edi, 0xb8000
    mov eax, 0x1f201f20
    mov ecx, 1000
    rep stosd

    ; TODO: Support 32-bit

    ; Detect CPUID
    mov esi, cpuid_err ; Load Relevent Error Message
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
    jz perr

    mov esi, lm_err ; Load Relevent Error Message

    ; Check if Extended Functions exist
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb perr

    ; Check for Long Mode
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz perr

    call id_paging_setup

    ; Edit GDT for 64-bit usage
    mov [gdt_codedesc + 6], byte 10101111b
    mov [gdt_datadesc + 6], byte 10101111b

    jmp codeseg:KERNEL_OFFSET

    jmp $

perr:
    ; Print error message
    mov edi, 0xb8000
    mov ah, 0x1c
    .loop:
        mov al, [esi]
        mov [edi], ax
        add edi, 2
        inc esi
        or al, al
        jnz .loop
    hlt

%include "source/boot/id_paging.asm"

a20_err:
    db 'set A20 failed', 0

cpuid_err:
    db 'no CPUID', 0

lm_err:
    db 'no 64-bit CPU', 0
  
times 510 - ($ - $$) db 0 ; pad rest of bootsector
dw 0xaa55 ; Bootloader Identifier