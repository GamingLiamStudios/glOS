[bits 32]
[org 0x7e00]
_start_kernel:
    mov ebx, STRING
    call print

    ; Check for 64-bit Long mode compat
    call detect_cpuid
    call detect_lm
    call setup_paging_id
    call edit_gdt

    jmp codeseg:_start_kernel_64

    jmp $

%include "source/kernel/CPUID.asm"
%include "source/bootloader/gdt.asm"
%include "source/kernel/identity_paging.asm"

print:
    pusha
    mov edx, 0xb8000
    .loop:
        mov al, [ebx]
        mov ah, 0x0f
        cmp al, 0
        je .end
        mov [edx] , ax
        add ebx , 1
        add edx , 2
        jmp .loop
    .end:
    popa
    ret

STRING:
    db '32-bit mode! :D' , 0

[bits 64]

_start_kernel_64:
    mov edi, 0xb8000
    mov rax, 0x1f201f201f201f20
    mov ecx, 1000
    rep stosd

    jmp $

times 2048 - ($ - $$) db 0 ; Fill rest of next 4 sectors