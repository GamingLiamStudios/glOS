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
    mov edi, 0xB8000   ; Text Video Memory address
    mov eax, 0x1f201f20
    mov ecx, 1000
    rep stosd

    ; Test A20
    call test_A20
    jne .a20_enabled

    ; A20 is not enabled. Try again with a different method
    call A20_wait
    mov al,0xAD
    out 0x64,al

    call A20_wait
    mov al,0xD0
    out 0x64,al

    call A20_wait2
    in al,0x60
    push eax

    call A20_wait
    mov al,0xD1
    out 0x64,al

    call A20_wait
    pop eax
    or al,2
    out 0x60,al

    call A20_wait
    mov al,0xAE
    out 0x64,al

    call A20_wait
    call test_A20
    jne .a20_enabled

    ; If that STILL didn't work, then try one last time
    in al, 0x92
    test al, 2
    jnz .failed_A20 ; Probably
    or al, 2
    and al, 0xFE
    out 0x92, al

    .a20_enabled:
    ; Don't mind the placement of this
    mov edi, 0xB8000   ; text video memory
    mov ah, 0x1F ; Attribute
    mov si, A20_failed
    
    call test_A20
    je .failed_A20

    mov si, msg

    .failed_A20:
    call print_str
hang:
    jmp hang

test_A20:  ; Some magic that's not mine lol 
    pushad
    mov edi,0x112345
    mov esi,0x012345
    mov [esi], esi
    mov [edi], edi
    cmpsd
    popad
    ret

A20_wait:
    in      al,0x64
    test    al,2
    jnz     A20_wait
    ret

A20_wait2:
    in      al,0x64
    test    al,1
    jz      A20_wait2
    ret

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
A20_failed: db 'Unable to set A20.', 0

times 510 - ($ - $$) db 0 ; Ensures that the boot-sector doesn't go over 512 bytes
dw 0xAA55 ; This tells the BIOS that is the boot sector