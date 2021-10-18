[org 0x7c00]
entry_point_16:
    ; Zero out registers
    xor ax, ax
    mov ds, ax
    mov di, ax
    cld

    ;; Enabling Protected Mode(32-bit)
    ; First, we set A20. This is only one method that we'll be using to ensure A20 is enabled.
    mov     ax, 2403h
    int     15h
    jb      .a20_bios_escape
    cmp     ah, 0
    jnz     .a20_bios_escape
    
    mov     ax, 2402h
    int     15h
    jb      .a20_bios_escape
    cmp     ah, 0
    jnz     .a20_bios_escape
    
    cmp     al, 1
    jz      .a20_bios_escape
    
    mov     ax, 2401h
    int     15h
    jb      .a20_bios_escape
    cmp     ah, 0
    jnz     .a20_bios_escape
    .a20_bios_escape:

    cli ; Disable interrupts
    lgdt [gdt_descriptor] ; Load GDT
    mov eax, cr0 
    or al, 1       ; set Protection Enable flag
    mov cr0, eax

    jmp codeseg:entry_point_32

%include "source/gdt.asm"

[bits 32]
entry_point_32:
    mov ax, dataseg
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ebp, 0xF0000
    mov esp, ebp

    ; Clear Screen
    mov edi, 0xB8000   ; text video memory
    mov eax, 0x1f201f20
    mov ecx, 1000
    rep stosd

    mov edi, 0xB8000   ; text video memory
    mov ah, 0x1F ; Attribute
    mov si, msg
    call print_str
hang:
    jmp hang

print_str:
    lodsb
    or al, al  ; Check for null-teminator
    jz .exit

    cmp al, 0x0A
    jne .write

    mov ebx, 0
    and di, 0x0FFF ; I believe this should be enough
    mov bx, 0xA0
    sub bx, di
    add di, bx
    or di, 0x8000

    jmp print_str

    .write:
    stosw

    jmp print_str
.exit:
    ret

msg: db 'Hello World!', 0x0A, 'New lines!', 0

times 510 - ($ - $$) db 0 ; Ensures that the boot-sector doesn't go over 512 bytes
dw 0xAA55 ; This tells the BIOS that is the boot sector